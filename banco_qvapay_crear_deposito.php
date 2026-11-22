<?php
/**
 * Generador de Depósitos QvaPay (API Global)
 * Ubicación: Raíz del proyecto (junto a game.php)
 * CORREGIDO: 1 USD = Tasa de cambio en UNTX-20.
 */

ob_start();
header('Content-Type: application/json; charset=utf-8');

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)) . '/');
set_include_path(ROOT_PATH);

$commonFile = ROOT_PATH . 'includes/common.php';
if (!file_exists($commonFile)) {
    echo json_encode(['error' => 'Error Crítico: No se encontró includes/common.php']);
    exit;
}
require_once $commonFile;

$classFile = ROOT_PATH . 'includes/qvapay.class.php';
if (!file_exists($classFile)) {
    echo json_encode(['error' => 'Error Crítico: No se encontró includes/qvapay.class.php']);
    exit;
}
require_once $classFile;

ob_clean();

if (!isset($USER) || empty($USER['id'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Debes iniciar sesión para comprar']);
    exit;
}

$userId = (int)$USER['id'];
$untx20ToBuy = 0;

// Leer la variable (el formulario dice 'kyber', pero ahora representa UNTX-20)
if (isset($_POST['kyber'])) {
    $untx20ToBuy = (float)$_POST['kyber'];
} elseif (isset($_GET['kyber'])) {
    $untx20ToBuy = (float)$_GET['kyber'];
}

if ($untx20ToBuy <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'La cantidad de UNTX-20 debe ser mayor a 0']);
    exit;
}
if ($untx20ToBuy < 10) {
    http_response_code(400);
    echo json_encode(['error' => 'La compra mínima es de 10 UNTX-20']);
    exit;
}
if ($untx20ToBuy > 500000) { 
    http_response_code(400);
    echo json_encode(['error' => 'La compra máxima es de 500,000 UNTX-20']);
    exit;
}

try {
    $db = Database::get();

    $globalConfig = $db->selectSingle("SELECT qvapay_app_id, qvapay_app_secret, qvapay_callback_url, qvapay_tasa_cup_por_kyber FROM uni1_config LIMIT 1");

    if (!$globalConfig) {
        throw new Exception("No se encontró la configuración del juego.");
    }
    if (empty($globalConfig['qvapay_app_id']) || empty($globalConfig['qvapay_app_secret'])) {
        throw new Exception("La API de QvaPay no está configurada globalmente por el Superadmin.");
    }

    $superAdmin = $db->selectSingle("SELECT id FROM uni1_users WHERE authlevel >= 3 LIMIT 1");
    $adminId = $superAdmin ? (int)$superAdmin['id'] : 1;

    $tasa = (float)$globalConfig['qvapay_tasa_cup_por_kyber'];
    if ($tasa <= 0) $tasa = 820.0;

    // 🆕 FÓRMULA CORREGIDA: Si el jugador quiere 820 UNTX-20, y la tasa es 820, paga $1 USD.
    // Monto USD = Cantidad UNTX-20 / Tasa
    $amountUsd = round($untx20ToBuy / $tasa, 2);

    if ($amountUsd < 0.01) {
        throw new Exception("El monto mínimo a pagar es de $0.01 USD.");
    }

    $qp = new QvaPay($globalConfig['qvapay_app_id'], $globalConfig['qvapay_app_secret']);
    
    $remoteId = 'dep_' . $userId . '_' . time();
    $description = "Compra de " . number_format($untx20ToBuy, 0) . " UNTX-20 en AstroIO";
    $callbackUrl = !empty($globalConfig['qvapay_callback_url']) ? $globalConfig['qvapay_callback_url'] : 'https://astroio.duckdns.org/banco_qvapay_webhook.php';

    $invoice = $qp->createInvoice($amountUsd, $description, $remoteId, $callbackUrl);

    if (isset($invoice['error'])) {
        throw new Exception("QvaPay API Error: " . $invoice['error']);
    }

    $uuid = $invoice['transaction_uuid'] ?? null;
    $payUrl = $invoice['url'] ?? null;

    if (!$uuid || !$payUrl) {
        throw new Exception("Respuesta inválida de QvaPay: " . json_encode($invoice));
    }

    // Guardamos la cantidad de UNTX-20 a entregar en amount_kyber
    $uuidSeguro = addslashes($uuid);
    
    $sql = "INSERT INTO uni1_qvapay_deposits 
            (admin_id, user_id, qvapay_uuid, amount_cup, amount_kyber, status) 
            VALUES ($adminId, $userId, '$uuidSeguro', $amountUsd, $untx20ToBuy, 'pending')";
            
    $db->query($sql);

    echo json_encode([
        'success' => true,
        'url' => $payUrl,
        'uuid' => $uuid
    ]);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Fallo en el servidor: ' . $e->getMessage(),
        'linea' => $e->getLine(),
        'archivo' => basename($e->getFile())
    ]);
}