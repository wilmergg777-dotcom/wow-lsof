<?php

/**
 * AstroIO - Minijuego Navidad (Memoria Navideña)
 * Controlador del juego
 *
 * @package AstroIO
 * @version 1.1
 */

require_once ROOT_PATH.'includes/classes/MinijuegoNavidadHelper.class.php';

class ShowMinijuegonavidadPage extends AbstractGamePage
{
    public static $requireModule = 0;
    public $defaultController = 'show';

    public function __construct()
    {
        parent::__construct();
    }

    public function show()
    {
        global $USER, $LNG;

        $userId   = (int) $USER['id'];
        $username = $USER['username'];

        if (!MinijuegoNavidadHelper::isEnabled()) {
            $this->printMessage(
                'El Minijuego Navideño está deshabilitado.',
                [['label' => 'Volver', 'url' => 'game.php?page=overview']]
            );
            return;
        }

        MinijuegoNavidadHelper::cleanupOldTokens();

        $stats = MinijuegoNavidadHelper::getPlayerStats($userId);

        $config = [
            'duration'      => (int) MinijuegoNavidadHelper::getConfig('navidad_duration', 60),
            'pointsPerPair' => (int) MinijuegoNavidadHelper::getConfig('navidad_points_per_pair', 100),
            'cooldownHours' => (int) MinijuegoNavidadHelper::getConfig('navidad_cooldown_hours', 5),
        ];

        $this->tplObj->assign_vars([
            'navidad_stats'       => $stats,
            'navidad_config'      => $config,
            'navidad_config_json' => json_encode($config),
            'navidad_username'    => $username,
            'navidad_user_id'     => $userId,
            'navidad_image_url'   => 'styles/theme/gow/minijuego/navidad/'
        ]);

        $this->display('page.minijuegonavidad.default.tpl');
    }

    public function start()
    {
        global $USER;
        header('Content-Type: application/json; charset=UTF-8');

        $userId   = (int) $USER['id'];
        $username = $USER['username'];

        $result = MinijuegoNavidadHelper::startGame($userId, $username);

        if (!$result['success']) {
            $cooldownLeft = MinijuegoNavidadHelper::getCooldownLeft($userId);
            echo json_encode([
                'success'       => false,
                'error'         => $result['error'],
                'cooldown_left' => $cooldownLeft,
                'cooldown_text' => MinijuegoNavidadHelper::formatTimeLeft($cooldownLeft)
            ]);
            exit;
        }

        echo json_encode(['success' => true, 'token' => $result['token']]);
        exit;
    }

    public function finish()
    {
        global $USER;
        header('Content-Type: application/json; charset=UTF-8');

        $userId = (int) $USER['id'];
        $token = isset($_POST['token']) ? trim((string) $_POST['token']) : '';
        $parejas = isset($_POST['parejas']) ? $_POST['parejas'] : [];

        if (empty($token)) {
            echo json_encode(['success' => false, 'error' => 'missing_token']);
            exit;
        }

        $result = MinijuegoNavidadHelper::finishGame($userId, $token, $parejas);

        if (!$result['success']) {
            echo json_encode(['success' => false, 'error' => $result['error']]);
            exit;
        }

        echo json_encode([
            'success'     => true,
            'score'       => $result['score'],
            'parejas'     => $result['parejas'],
            'recompensas' => $result['recompensas']
        ]);
        exit;
    }
}