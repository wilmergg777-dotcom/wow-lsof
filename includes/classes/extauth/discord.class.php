<?php

/**
 * AstroIO - Discord External Auth
 * Auto-registro reutilizando el sistema de validación de 2Moons
 * + Vinculación de cuenta existente (link mode)
 * 
 * ✅ OPCIÓN B: Identificación por discord_ID (no por email)
 *    - account en uni1_users_to_extauth = "discord_<ID>"
 *    - El ID de Discord NUNCA cambia
 *    - No depende del email del usuario
 */

// ═══ AUTOLOADER PSR-4 ═══
spl_autoload_register(function ($class) {
    $prefixes = [
        'Wohali\\OAuth2\\Client\\'   => [__DIR__ . '/libs/oauth2-discord-new/src/'],
        'League\\OAuth2\\Client\\'   => [__DIR__ . '/libs/oauth2-client/src/'],
        'GuzzleHttp\\'               => [__DIR__ . '/libs/guzzle/src/'],
        'GuzzleHttp\\Promise\\'      => [__DIR__ . '/libs/guzzle-promises/src/'],
        'GuzzleHttp\\Psr7\\'         => [__DIR__ . '/libs/guzzle-psr7/src/'],
        'Psr\\Http\\Client\\'        => [__DIR__ . '/libs/psr-http-client/src/'],
        'Psr\\Http\\Message\\'       => [
            __DIR__ . '/libs/psr-http-message/src/',
            __DIR__ . '/libs/psr-http-factory/src/',
        ],
        'Ralouphie\\GetAllHeaders\\' => [__DIR__ . '/libs/getallheaders/src/'],
    ];

    foreach ($prefixes as $prefix => $dirs) {
        $len = strlen($prefix);
        if (strncmp($prefix, $class, $len) !== 0) {
            continue;
        }
        $relative = substr($class, $len);
        $relativePath = str_replace('\\', '/', $relative) . '.php';

        foreach ($dirs as $baseDir) {
            $file = $baseDir . $relativePath;
            if (file_exists($file)) {
                require_once $file;
                return;
            }
        }
    }
});

use Wohali\OAuth2\Client\Provider\Discord;

class DiscordAuth implements externalAuth
{
    private $provider;
    private $userData = null;

    const TABLE_OAUTH       = 'uni1_discord_oauth';
    const TABLE_USERS       = 'uni1_users';
    const TABLE_USERS_VALID = 'uni1_users_valid';
    const TABLE_EXTAUTH     = 'uni1_users_to_extauth';

    public function __construct()
    {
        global $config;

        $this->provider = new Discord([
            'clientId'     => $config->discord_apikey,
            'clientSecret' => $config->discord_skey,
            'redirectUri'  => HTTP_PATH . 'index.php?page=ExternalAuth&method=discord',
        ]);
    }

    public function isActiveMode()
    {
        global $config;
        return !empty($config->discord_on);
    }

    public function isValid()
    {
        global $config;
        return !empty($config->discord_apikey) && !empty($config->discord_skey);
    }

    // ═══════════════════════════════════════════════════════════
    // MODO VINCULACIÓN — Fase 1: usuario logueado pulsa "Vincular"
    // ═══════════════════════════════════════════════════════════
    public function linkAccount($userID)
    {
        $db = Database::get();

        // 1. Generar URL de autorización con state
        $authUrl = $this->provider->getAuthorizationUrl([
            'scope' => ['identify', 'email']
        ]);
        $state = $this->provider->getState();

        // 2. Guardar state + userID en BD (data = JSON con link_user)
        $stateSafe = preg_replace('/[^a-zA-Z0-9_]/', '', $state);
        $dataJson  = json_encode(['link_user' => (int) $userID]);
        $dataSafe  = addslashes($dataJson);
        $time      = time();

        $sql = "INSERT INTO " . self::TABLE_OAUTH . " (state, data, created_at) "
             . "VALUES ('$stateSafe', '$dataSafe', $time)";
        $db->query($sql);

        // 3. Redirigir a Discord
        header('Location: ' . $authUrl);
        exit;
    }

    // ═══════════════════════════════════════════════════════════
    // MODO VINCULACIÓN — Fase 2: vuelve de Discord con code+state
    // ═══════════════════════════════════════════════════════════
    private function completeLink($stateRow)
    {
        $db = Database::get();

        // 1. Parsear data (JSON con link_user)
        $data = json_decode($stateRow['data'], true);
        if (empty($data['link_user'])) {
            throw new Exception('Vinculación inválida: no se encontró el usuario.');
        }
        $userID = (int) $data['link_user'];

        // 2. Intercambiar code por token
        try {
            $token = $this->provider->getAccessToken('authorization_code', [
                'code' => $_GET['code']
            ]);
            $owner = $this->provider->getResourceOwner($token);
            $this->userData = $owner->toArray();
        } catch (Exception $e) {
            throw new Exception('Error al obtener datos de Discord: ' . $e->getMessage());
        }

        // 3. Determinar account = discord_<ID>
        $account = $this->buildAccountName();

        // 4. ¿Ya está vinculado a OTRO usuario?
        $existing = $db->selectSingle(
            "SELECT id FROM " . self::TABLE_EXTAUTH . " 
             WHERE account = :account AND mode = 'discord' LIMIT 1",
            [':account' => $account]
        );

        if (!empty($existing) && (int) $existing['id'] !== $userID) {
            // Está vinculado a otra cuenta → error
            throw new Exception('Esta cuenta de Discord ya está vinculada a otro usuario de AstroIO.');
        }

        // 5. Borrar vinculaciones previas de ESTE usuario
        $db->query(
            "DELETE FROM " . self::TABLE_EXTAUTH . " 
             WHERE id = " . (int) $userID . " AND mode = 'discord'"
        );

        // 6. Insertar vinculación
        $db->query(
            "INSERT INTO " . self::TABLE_EXTAUTH . " (id, account, mode) 
             VALUES (" . (int) $userID . ", '" . addslashes($account) . "', 'discord')"
        );

        // 7. Redirigir a settings
        HTTP::redirectTo('game.php?page=settings');
        exit;
    }

    public function getLoginData()
    {
        $db = Database::get();

        // 1. Si no hay código, redirigir a Discord
        if (!isset($_GET['code'])) {
            $authUrl = $this->provider->getAuthorizationUrl([
                'scope' => ['identify', 'email']
            ]);
            $state = $this->provider->getState();
            $this->insertState($db, $state, '');
            header('Location: ' . $authUrl);
            exit;
        }

        // 2. Verificar el state
        $state = isset($_GET['state']) ? $_GET['state'] : '';
        $stateSafe = preg_replace('/[^a-zA-Z0-9_]/', '', $state);

        $sql = "SELECT * FROM " . self::TABLE_OAUTH . " WHERE state = :state LIMIT 1;";
        $row = $db->selectSingle($sql, [':state' => $stateSafe]);

        if (empty($row)) {
            throw new Exception('Estado OAuth2 inválido. Posible ataque CSRF.');
        }

        $db->query("DELETE FROM " . self::TABLE_OAUTH . " WHERE state = '" . addslashes($stateSafe) . "'");

        // ═══ AstroIO — Detectar modo vinculación ═══
        if (!empty($row['data'])) {
            $data = json_decode($row['data'], true);
            if (!empty($data['link_user'])) {
                // Es modo vinculación → ejecutar y salir
                $this->completeLink($row);
                // completeLink hace redirect y exit
            }
        }
        // ═══ Fin AstroIO ═══

        // 3. Intercambiar código por token y obtener datos de Discord
        try {
            $token = $this->provider->getAccessToken('authorization_code', [
                'code' => $_GET['code']
            ]);
            $owner = $this->provider->getResourceOwner($token);
            $this->userData = $owner->toArray();
        } catch (Exception $e) {
            throw new Exception('Error al obtener datos de Discord: ' . $e->getMessage());
        }

        // 4. Buscar usuario existente por account = discord_<ID>
        $account = $this->buildAccountName();

        $sql = "SELECT u.id FROM " . self::TABLE_USERS . " u
                INNER JOIN " . self::TABLE_EXTAUTH . " e ON u.id = e.id
                WHERE e.account = :account
                LIMIT 1;";
        $existing = $db->selectSingle($sql, [':account' => $account]);

        if (!empty($existing)) {
            // Usuario ya existe → iniciar sesión
            return ['id' => (int) $existing['id']];
        }

        // 5. No existe → crear entrada de validación y redirigir a vertify
        $this->createValidationEntry($db);

        // Nunca llega aquí (redirectTo hace exit)
        return [];
    }

    public function getAccount()
    {
        return $this->buildAccountName();
    }

    public function getAccountData()
    {
        return $this->userData;
    }

    public function register()
    {
        return true;
    }

    /**
     * Inserta en uni1_users_valid como lo hace ShowRegisterPage.send()
     * y redirige a vertify, que creará el usuario y el planeta.
     */
    private function createValidationEntry($db)
    {
        if (empty($this->userData)) {
            throw new Exception('No hay datos de Discord para registrar.');
        }

        $discordId = $this->userData['id'];
        $discordU  = $this->userData['username'];

        // Email interno único (no choca con emails existentes)
        $email = 'discord_' . $discordId . '@astroio.local';

        // Cuenta externa = discord_<ID>
        $accountName = $this->buildAccountName();

        // Username único
        $baseUsername = preg_replace('/[^a-zA-Z0-9_]/', '', $discordU);
        if (strlen($baseUsername) < 3) {
            $baseUsername = 'player' . substr($discordId, -6);
        }
        $baseUsername = substr($baseUsername, 0, 20);

        $username = $baseUsername;
        $suffix   = 1;
        while (true) {
            $check1 = $db->selectSingle(
                "SELECT id FROM " . self::TABLE_USERS . " WHERE username = :u LIMIT 1",
                [':u' => $username]
            );
            $check2 = $db->selectSingle(
                "SELECT validationID FROM " . self::TABLE_USERS_VALID . " WHERE userName = :u LIMIT 1",
                [':u' => $username]
            );
            if (empty($check1) && empty($check2)) {
                break;
            }
            $username = $baseUsername . $suffix;
            $suffix++;
            if ($suffix > 500) {
                $username = 'player_' . time();
                break;
            }
        }

        // Password aleatoria encriptada
        $plainPassword   = md5(uniqid('discord_', true));
        $cryptedPassword = PlayerUtil::cryptPassword($plainPassword);

        $validationKey = md5(uniqid('2m'));

        // Insertar en users_valid con el mismo patrón que ShowRegisterPage
        $sql = "INSERT INTO %%USERS_VALID%% SET
                `userName`             = :userName,
                `validationKey`        = :validationKey,
                `password`             = :password,
                `email`                = :mailAddress,
                `date`                 = :timestamp,
                `ip`                   = :remoteAddr,
                `language`             = :language,
                `universe`             = :universe,
                `referralID`           = :referralID,
                `externalAuthUID`      = :externalAuthUID,
                `externalAuthMethod`   = :externalAuthMethod;";

        $db->insert($sql, [
            ':userName'             => $username,
            ':validationKey'        => $validationKey,
            ':password'             => $cryptedPassword,
            ':mailAddress'          => $email,
            ':timestamp'            => TIMESTAMP,
            ':remoteAddr'           => Session::getClientIp(),
            ':language'             => 'es',
            ':universe'             => Universe::current(),
            ':referralID'           => 0,
            ':externalAuthUID'      => $accountName,
            ':externalAuthMethod'   => 'discord'
        ]);

        $validationID = $db->lastInsertId();

        if (empty($validationID)) {
            throw new Exception('No se pudo crear la entrada de validación.');
        }

        // Redirigir a vertify
        $verifyURL = 'index.php?page=vertify&i=' . $validationID . '&k=' . urlencode($validationKey);
        HTTP::redirectTo($verifyURL);
        exit;
    }

    private function insertState($db, $state, $data)
    {
        $stateSafe = preg_replace('/[^a-zA-Z0-9_]/', '', $state);
        $dataSafe  = addslashes($data);
        $time      = time();

        $sql = "INSERT INTO " . self::TABLE_OAUTH . " (state, data, created_at) "
             . "VALUES ('$stateSafe', '$dataSafe', $time)";
        $db->query($sql);
    }

    /**
     * ✅ OPCIÓN B: SIEMPRE devuelve "discord_<ID>"
     * El ID de Discord nunca cambia, así que es más robusto que el email.
     */
    private function buildAccountName()
    {
        if (empty($this->userData)) {
            return '';
        }
        return 'discord_' . $this->userData['id'];
    }
}