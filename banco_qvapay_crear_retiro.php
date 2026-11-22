<?php
/**
 * Solicitud de Retiro vía QvaPay
 * Ubicación: Raíz del proyecto
 * CORREGIDO: Usa UNTX-20 y la función centralizada de WalletHelper.
 */

ob_start();
header('Content-Type: application/json; charset=utf-8');

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)) . '/');
set_include_path(ROOT_PATH);

require_once ROOT_PATH . 'includes/common.php';
ob_clean();

if (!isset($USER) || empty($USER['id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Debes iniciar sesión']);
    exit;
}

$userId = (int)$USER['id'];
$untx20 = isset($_POST['nxt20']) ? (int)$_POST['nxt20'] : 0;
$qvapayUsername = isset($_POST['qvapay_username']) ? trim($_POST['qvapay_username']) : '';

if ($untx20 <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'La cantidad de UNTX-20 debe ser mayor a 0']);
    exit;
}

if (empty($qvapayUsername)) {
    http_response_code(400);
    echo json_encode(['error' => 'Debes ingresar tu usuario de QvaPay']);
    exit;
}

$db = Database::get();
$prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';

// Cargar WalletHelper para usar la lógica centralizada
$walletHelperFile = ROOT_PATH . 'includes/classes/WalletHelper.class.php';
if (!file_exists($walletHelperFile)) {
    http_response_code(500);
    echo json_encode(['error' => 'Error crítico: No se encontró WalletHelper.class.php']);
    exit;
}
require_once $walletHelperFile;

try {
    // 1. Verificar que el método de retiro del usuario sea QVAPAY
    $userMetodo = $db->selectSingle("SELECT metodo_retiro FROM {$prefix}users WHERE id = {$userId} LIMIT 1");
    if (!$userMetodo || $userMetodo['metodo_retiro'] !== 'QVAPAY') {
        throw new Exception("Tu método de retiro no es QvaPay. No podés usar esta función.");
    }

    // 2. Guardar el username de QvaPay antes de procesar
    $qvapayUsernameSeguro = addslashes($qvapayUsername);
    $db->query("INSERT INTO {$prefix}qvapay_accounts (user_id, qvapay_username) 
                VALUES ({$userId}, '{$qvapayUsernameSeguro}') 
                ON DUPLICATE KEY UPDATE qvapay_username = '{$qvapayUsernameSeguro}'");

    // 3. Llamar a la función centralizada que hace TODAS las validaciones:
    //    - VIP
    //    - Retiros abiertos
    //    - Mínimo
    //    - Pendientes
    //    - Saldo retirable de UNTX-20
    //    - Liquidez del banco (97% del bruto)
    //    - Bloqueo de UNTX-20
    //    - Doble escritura (uni1_wallets + ledger)
    $result = WalletHelper::solicitarRetiro($userId, $untx20);

    if (isset($result['error'])) {
        throw new Exception($result['error']);
    }

    // 4. Éxito
    echo json_encode([
        'success' => true,
        'message' => 'Solicitud de retiro enviada. Los UNTX-20 quedaron bloqueados.',
        'neto' => $result['neto'],
        'withdrawal_id' => $result['withdrawal_id']
    ]);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => $e->getMessage()]);
}