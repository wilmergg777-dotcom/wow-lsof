<?php
/**
 * chat_bridge.php
 * Puente entre el Chat Flotante (nuevo) y AJAX Chat (oficial)
 * Soporta: canal Global (0) y canal Alianza (ally_id + 100)
 * AstroIO 2026 - v1.3
 *   - Fix nombres (fallback si userName viene vacío)
 *   - Validación de canal ANTES de la purga
 *   - Filtro de mensajes de sistema (/login, /logout, /kick, /ban, etc.)
 *   - Tiempo de retención configurable desde el Panel Admin (chat_retention_minutes)
 *   - Filtro por tiempo en el SELECT (los mensajes viejos no se muestran)
 *   - Purga selectiva: borra SOLO los mensajes expirados (no todo)
 */

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)).'/');
set_include_path(ROOT_PATH);
chdir(ROOT_PATH);

require 'includes/config.php';
require 'includes/common.php';

header('Content-Type: application/json; charset=UTF-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');

// ═══════════════════════════════════════════════
// 1. Verificar sesión
// ═══════════════════════════════════════════════
$session = Session::load();
if (!$session->isValidSession()) {
    echo json_encode(['error' => 'not_logged_in']);
    exit;
}

$db     = Database::get();
$userId = intval($session->userId);

// ═══════════════════════════════════════════════
// 2. Datos del usuario (incluye ally_id)
// ═══════════════════════════════════════════════
$userData = $db->selectSingle(
    "SELECT authlevel, username, ally_id FROM %%USERS%% WHERE id = :userId",
    [':userId' => $userId]
);

if (!$userData) {
    echo json_encode(['error' => 'user_not_found']);
    exit;
}

$userName   = $userData['username'];
$userAllyId = intval($userData['ally_id']);

$userRole = 1;
if ($userData['authlevel'] == AUTH_ADM)    $userRole = 3;
elseif ($userData['authlevel'] > AUTH_USR) $userRole = 2;

$action = isset($_REQUEST['action']) ? $_REQUEST['action'] : 'get';

// ═══════════════════════════════════════════════
// 2.b Leer configuración de retención del universo
//     0 = sin borrado automático
// ═══════════════════════════════════════════════
$retentionMinutes = 60; // valor por defecto (1 hora)
try {
    $cfg = Config::get(Universe::getEmulated());
    if (isset($cfg->chat_retention_minutes)) {
        $retentionMinutes = (int)$cfg->chat_retention_minutes;
    }
} catch (Exception $e) {
    // Si falla, dejamos 60 minutos por defecto
}
if ($retentionMinutes < 0) $retentionMinutes = 0;

// ═══════════════════════════════════════════════
// 3. VALIDACIÓN DE CANAL (antes de la purga)
// ═══════════════════════════════════════════════
/**
 * Reglas:
 *  - Canal 0 → permitido siempre (chat global)
 *  - Canal ally_id + 100 → solo si el usuario pertenece a esa alianza
 */
function isValidChannel($channel, $userAllyId) {
    if ($channel === 0) return true;

    if ($userAllyId > 0 && $channel === ($userAllyId + 100)) {
        return true;
    }

    return false;
}

$channel = isset($_REQUEST['channel']) ? intval($_REQUEST['channel']) : 0;

if (!isValidChannel($channel, $userAllyId)) {
    echo json_encode(['error' => 'channel_not_allowed']);
    exit;
}

// ═══════════════════════════════════════════════
// 3.b Filtro SQL para excluir mensajes de sistema
//     (AJAX Chat guarda /login, /logout, /kick, etc.
//      como mensajes reales en la tabla)
// ═══════════════════════════════════════════════
$systemCommands = [
    '/login',
    '/logout',
    '/kick',
    '/ban',
    '/unban',
    '/banip',
    '/unbanip',
    '/mute',
    '/unmute',
    '/delete',
    '/shutdown',
    '/reload',
    '/debug',
    '/notice',
    '/me',
    '/privmsg',
    '/msg',
    '/whois',
    '/ignore',
    '/unignore',
    '/quit',
    '/join',
    '/part',
    '/away',
    '/back',
];

$sysFilter = '';
foreach ($systemCommands as $cmd) {
    // Escapamos por seguridad (aunque son literales nuestros)
    $safeCmd = str_replace("'", "''", $cmd);
    $sysFilter .= " AND text NOT LIKE '" . $safeCmd . " %'";
    $sysFilter .= " AND text <> '" . $safeCmd . "'";
}
// NOTA: filtramos tanto "cmd algo" como "cmd" solo.

// ═══════════════════════════════════════════════
// 3.c Filtro de tiempo (según config del admin)
//     Si retentionMinutes = 0 → sin filtro (chat sin borrado)
// ═══════════════════════════════════════════════
$timeFilter = '';
if ($retentionMinutes > 0) {
    $timeFilter = " AND dateTime > DATE_SUB(NOW(), INTERVAL " . $retentionMinutes . " MINUTE) ";
}

// ═══════════════════════════════════════════════
// 4. PURGA AUTOMÁTICA DEL CHAT
//    - Ya NO borra todo cada 6h.
//    - Ahora borra SOLO los mensajes expirados.
//    - Corre cada 6 horas (suficiente, porque el SELECT ya filtra).
//    - Si retentionMinutes = 0 → no purga nada.
// ═══════════════════════════════════════════════
if ($retentionMinutes > 0) {

    $purgeFile     = ROOT_PATH . '.chat_purge_last';
    $purgeInterval = 6 * 3600;   // 21600 seg = 6 horas

    $lastPurge = 0;
    if (file_exists($purgeFile)) {
        $lastPurge = (int)@file_get_contents($purgeFile);
    }

    if ((time() - $lastPurge) >= $purgeInterval) {

        // Bloqueo exclusivo para evitar que dos usuarios purguen a la vez
        $lockFile = ROOT_PATH . '.chat_purge.lock';
        $fp = @fopen($lockFile, 'c');
        if ($fp && @flock($fp, LOCK_EX | LOCK_NB)) {

            try {
                // Borrar SOLO los mensajes más viejos que la retención
                $sqlPurge = "DELETE FROM %%CHAT_MES%%
                             WHERE dateTime <= DATE_SUB(NOW(), INTERVAL " . $retentionMinutes . " MINUTE)";

                if (method_exists($db, 'delete')) {
                    $db->delete($sqlPurge);
                } elseif (method_exists($db, 'query')) {
                    $db->query($sqlPurge);
                } elseif (method_exists($db, 'nativeQuery')) {
                    $db->nativeQuery(str_replace('%%CHAT_MES%%', 'uni1_chat_messages', $sqlPurge));
                }

                // Marcar la hora de esta purga
                file_put_contents($purgeFile, time());

                // Log opcional
                file_put_contents(
                    ROOT_PATH . 'chat_purge.log',
                    '[' . date('Y-m-d H:i:s') . "] Purga OK (retención: {$retentionMinutes} min)\n",
                    FILE_APPEND
                );

            } catch (Exception $e) {
                file_put_contents(
                    ROOT_PATH . 'chat_purge.log',
                    '[' . date('Y-m-d H:i:s') . "] ERROR: " . $e->getMessage() . "\n",
                    FILE_APPEND
                );
            }

            @flock($fp, LOCK_UN);
            @fclose($fp);
        }
    }
}

// ═══════════════════════════════════════════════
// 5. GET — Leer mensajes
// ═══════════════════════════════════════════════
if ($action === 'get') {
    $lastId = isset($_GET['last_id']) ? intval($_GET['last_id']) : 0;

    try {
        if ($lastId > 0) {
            $messages = $db->select(
                "SELECT id, userID, userName, userRole, channel, dateTime, text
                 FROM %%CHAT_MES%%
                 WHERE id > :lastId AND channel = :channel
                 " . $sysFilter . "
                 " . $timeFilter . "
                 ORDER BY id ASC
                 LIMIT 50",
                [
                    ':lastId'  => $lastId,
                    ':channel' => $channel,
                ]
            );
        } else {
            $messages = $db->select(
                "SELECT * FROM (
                    SELECT id, userID, userName, userRole, channel, dateTime, text
                    FROM %%CHAT_MES%%
                    WHERE channel = :channel
                    " . $sysFilter . "
                    " . $timeFilter . "
                    ORDER BY id DESC
                    LIMIT 50
                 ) AS sub
                 ORDER BY id ASC",
                [':channel' => $channel]
            );
        }
    } catch (Exception $e) {
        echo json_encode([
            'error' => 'db_error',
            'msg'   => $e->getMessage()
        ]);
        exit;
    }

    // Garantizar array (por si el driver devuelve null/false)
    if (!is_array($messages)) {
        $messages = [];
    }

    // Garantizar que CADA mensaje lleva userName y userRole
    // (importante para que el chat flotante pinte el nombre del emisor)
    foreach ($messages as &$m) {
        if (!isset($m['userName']) || $m['userName'] === null || $m['userName'] === '') {
            // Fallback: buscar el nombre del usuario en la tabla users
            $fallbackName = $db->selectSingle(
                "SELECT username FROM %%USERS%% WHERE id = :uid",
                [':uid' => intval($m['userID'])]
            );
            $m['userName'] = $fallbackName ? $fallbackName['username'] : 'Desconocido';
        }

        if (!isset($m['userRole']) || $m['userRole'] === null) {
            $m['userRole'] = 1;
        }

        if (!isset($m['channel']) || $m['channel'] === null) {
            $m['channel'] = $channel;
        }

        if (!isset($m['dateTime']) || $m['dateTime'] === null) {
            $m['dateTime'] = date('Y-m-d H:i:s');
        }

        // Asegurar que id/userID son ints
        $m['id']     = intval($m['id']);
        $m['userID'] = intval($m['userID']);
    }
    unset($m);

    echo json_encode([
        'success'           => true,
        'userId'            => $userId,
        'userName'          => $userName,
        'userRole'          => $userRole,
        'userAllyId'        => $userAllyId,
        'channel'           => $channel,
        'retentionMinutes'  => $retentionMinutes,
        'messages'          => $messages
    ]);
    exit;
}

// ═══════════════════════════════════════════════
// 6. SEND — Enviar mensaje
// ═══════════════════════════════════════════════
if ($action === 'send') {
    $text = isset($_POST['text']) ? trim($_POST['text']) : '';

    if ($text === '') {
        echo json_encode(['error' => 'empty_message']);
        exit;
    }

    if (mb_strlen($text) > 500) {
        $text = mb_substr($text, 0, 500);
    }

    $textEncoded = htmlspecialchars($text, ENT_QUOTES, 'UTF-8');

    // IP binaria (varbinary(16))
    $ipBinary = @inet_pton($_SERVER['REMOTE_ADDR']);
    if ($ipBinary === false) {
        $ipBinary = inet_pton('0.0.0.0');
    }

    $params = [
        ':userId'   => $userId,
        ':userName' => $userName,
        ':userRole' => $userRole,
        ':channel'  => $channel,
        ':ip'       => $ipBinary,
        ':text'     => $textEncoded,
    ];

    $sql = "INSERT INTO %%CHAT_MES%%
                (userID, userName, userRole, channel, dateTime, ip, text)
            VALUES
                (:userId, :userName, :userRole, :channel, NOW(), :ip, :text)";

    try {
        // ─── Intento 1: método insert() de 2Moons ───
        if (method_exists($db, 'insert')) {
            $db->insert($sql, $params);
            echo json_encode(['success' => true, 'channel' => $channel, 'via' => 'insert']);
            exit;
        }

        // ─── Intento 2: query() (si existe) ───
        if (method_exists($db, 'query')) {
            $db->query($sql, $params);
            echo json_encode(['success' => true, 'channel' => $channel, 'via' => 'query']);
            exit;
        }

        // ─── Intento 3: nativeQuery() (escapando a mano) ───
        if (method_exists($db, 'nativeQuery')) {
            $safeText   = addslashes($textEncoded);
            $safeName   = addslashes($userName);
            $sqlRaw     = "INSERT INTO uni1_chat_messages
                            (userID, userName, userRole, channel, dateTime, ip, text)
                           VALUES
                            ($userId, '$safeName', $userRole, $channel, NOW(),
                             UNHEX('" . bin2hex($ipBinary) . "'), '$safeText')";
            $db->nativeQuery($sqlRaw);
            echo json_encode(['success' => true, 'channel' => $channel, 'via' => 'nativeQuery']);
            exit;
        }

        // ─── Ningún método disponible → diagnóstico ───
        echo json_encode([
            'error'   => 'no_insert_method',
            'methods' => get_class_methods($db)
        ]);
        exit;

    } catch (Exception $e) {
        echo json_encode([
            'error' => 'db_error',
            'msg'   => $e->getMessage(),
            'sql'   => $sql,
            'debug' => [
                'userId'   => $userId,
                'userName' => $userName,
                'userRole' => $userRole,
                'channel'  => $channel,
                'ip_len'   => strlen($ipBinary),
            ],
        ]);
    }
    exit;
}

// ═══════════════════════════════════════════════
// 7. Acción desconocida
// ═══════════════════════════════════════════════
echo json_encode(['error' => 'unknown_action']);