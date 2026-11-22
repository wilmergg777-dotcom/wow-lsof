<?php
/**
 * Webhook de QvaPay para AstroIO Banco (API Global)
 * Ubicación: Raíz del proyecto (junto a game.php)
 * AstroIO v7.5 — Doble escritura de UNTX-20 (Nacional / Internacional)
 */

// 1. Iniciar el buffer de salida para atrapar cualquier warning
ob_start();

// Forzamos que la respuesta sea siempre JSON
header('Content-Type: application/json; charset=utf-8');

// 2. Definir constantes necesarias para 2Moons
define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)) . '/');
set_include_path(ROOT_PATH);

// Permitir solo POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Método no permitido']);
    exit;
}

// 3. Cargar el entorno de 2Moons de forma segura
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

// 🆕 Cargar WalletFundHelper para la doble escritura y matemática correcta
$fundHelperFile = ROOT_PATH . 'includes/classes/WalletFundHelper.class.php';
if (file_exists($fundHelperFile)) {
    require_once $fundHelperFile;
}

// Limpiar buffer (por si 2Moons imprimió algo)
ob_clean();

try {
    $db = Database::get();

    // 4. Obtener el payload crudo
    $rawBody = file_get_contents('php://input');
    $payload = json_decode($rawBody, true);

    if (!$payload || !isset($payload['uuid'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Payload inválido o falta UUID']);
        exit;
    }

    $uuid = $payload['uuid'];
    $status = $payload['status'] ?? '';

    // Solo procesamos si QvaPay dice que está pagado
    if ($status !== 'paid' && $status !== 'completed') {
        http_response_code(200);
        echo json_encode(['status' => 'ignored', 'message' => 'No es un pago completado']);
        exit;
    }

    // 5. Buscar el depósito en nuestra BD (Concatenación directa para evitar error SQL)
    $uuidSeguro = addslashes($uuid);
    $deposit = $db->selectSingle("SELECT * FROM uni1_qvapay_deposits WHERE qvapay_uuid = '{$uuidSeguro}' LIMIT 1");

    if (!$deposit) {
        http_response_code(404);
        echo json_encode(['error' => 'Depósito no encontrado en la base de datos']);
        exit;
    }

    // Si ya fue procesado, salimos (Idempotencia)
    if ($deposit['status'] === 'paid') {
        http_response_code(200);
        echo json_encode(['status' => 'success', 'message' => 'El depósito ya estaba acreditado']);
        exit;
    }

    $userId = (int)$deposit['user_id'];
    $amountCup = (float)$deposit['amount_cup'];
    $amountKyber = (float)$deposit['amount_kyber'];

    // 6. Obtener las credenciales GLOBALES de QvaPay
    $globalConfig = $db->selectSingle("SELECT qvapay_app_id, qvapay_app_secret FROM uni1_config LIMIT 1");
    
    if (!$globalConfig || empty($globalConfig['qvapay_app_secret']) || empty($globalConfig['qvapay_app_id'])) {
        error_log("QvaPay Webhook Error: No hay credenciales globales configuradas.");
        http_response_code(500);
        echo json_encode(['error' => 'Configuración global de QvaPay no encontrada']);
        exit;
    }

    // 7. Validar la firma HMAC (Seguridad)
    $signatureHeader = $_SERVER['HTTP_X_QVAPAY_SIGNATURE'] ?? '';
    
    if (!empty($signatureHeader)) {
        $expectedSignature = hash_hmac('sha256', $rawBody, $globalConfig['qvapay_app_secret']);
        $signatureRecibida = str_replace('sha256=', '', $signatureHeader);
        
        if (!hash_equals($expectedSignature, $signatureRecibida)) {
            error_log("QvaPay Webhook Error: Firma inválida para UUID $uuid");
            http_response_code(401);
            echo json_encode(['error' => 'Firma inválida']);
            exit;
        }
    }

    // 8. Re-verificación con la API de QvaPay usando las credenciales globales
    $qp = new QvaPay($globalConfig['qvapay_app_id'], $globalConfig['qvapay_app_secret']);
    $apiTx = $qp->getTransaction($uuid);

    $apiStatus = $apiTx['data']['status'] ?? '';
    if ($apiStatus !== 'paid' && $apiStatus !== 'completed') {
        error_log("QvaPay Webhook Error: La API no confirma el pago para UUID $uuid");
        http_response_code(200); 
        echo json_encode(['error' => 'La API de QvaPay no confirma el estado pagado.']);
        exit;
    }

    // 9. Procesar el pago en la Base de Datos (Transacción Segura)
    $db->beginTransaction();

    try {
        // Actualizar depósito
        $db->query("UPDATE uni1_qvapay_deposits SET status = 'paid', paid_at = NOW() WHERE id = {$deposit['id']}");

        // Acreditar UNTX-20 (Internacional) al usuario en la tabla vieja (Global)
        $db->query("UPDATE uni1_users SET untx20 = untx20 + {$amountKyber}, untx20_inversion = untx20_inversion + {$amountKyber} WHERE id = {$userId}");

        // Acreditar UNTX-20 en la tabla nueva (Wallets) - Doble Escritura (Ledger)
        // Usamos INSERT ... ON DUPLICATE KEY UPDATE para asegurar que el wallet exista y se sume el saldo
        $db->query("INSERT INTO uni1_wallets (user_id, currency_code, balance_juego) 
                    VALUES ({$userId}, 'UNTX20_INT', {$amountKyber}) 
                    ON DUPLICATE KEY UPDATE balance_juego = balance_juego + {$amountKyber}");

        // Registrar en el Ledger de auditoría
        $walletIdQuery = $db->selectSingle("SELECT id FROM uni1_wallets WHERE user_id = {$userId} AND currency_code = 'UNTX20_INT' LIMIT 1");
        if ($walletIdQuery) {
            $walletId = (int)$walletIdQuery['id'];
            $db->query("INSERT INTO uni1_ledger_entries (wallet_id, user_id, currency_code, amount, tipo, reference_id, metadata) 
                        VALUES ({$walletId}, {$userId}, 'UNTX20_INT', {$amountKyber}, 'deposit', '{$uuid}', '{\"source\":\"qvapay\"}')");
        }

        // 🆕 CORRECCIÓN: Usar WalletFundHelper para la matemática correcta (solo 70% al banco)
        if (class_exists('WalletFundHelper')) {
            // Solo el 70% entra al banco como respaldo real
            $montoAlBanco = (int)floor($amountKyber * 0.70);
            WalletFundHelper::addToBanco($montoAlBanco, 'QVAPAY');
            WalletFundHelper::addToInvertidoHistorico($amountKyber); // El histórico sí es el total

            // Calcular y acreditar el Fondo Proyecto (27% del Kyber, o 30% si no hay referidor)
            $pctProyecto = 27;
            // Verificar Referidor (3% en UNTX-20)
            $userData = $db->selectSingle("SELECT ref_id FROM uni1_users WHERE id = {$userId} LIMIT 1");
            if (empty($userData['ref_id']) || $userData['ref_id'] <= 0) {
                $pctProyecto = 30;
            }
            $montoProyecto = (int)floor($amountKyber * $pctProyecto / 100);
            WalletFundHelper::addToProyecto($montoProyecto);

            // Si hay referidor, se le acredita el 3% en UNTX-20 (esto no toca el banco)
            if (!empty($userData['ref_id']) && $userData['ref_id'] > 0) {
                $refId = (int)$userData['ref_id'];
                $refAmount = (int)floor($amountKyber * 0.03);
                
                // Acreditar al referidor en la tabla global
                $db->query("UPDATE uni1_users SET untx20 = untx20 + {$refAmount} WHERE id = {$refId}");
                
                // Acreditar al referidor en la tabla nueva (Wallets) - Doble Escritura
                $db->query("INSERT INTO uni1_wallets (user_id, currency_code, balance_juego) 
                            VALUES ({$refId}, 'UNTX20_INT', {$refAmount}) 
                            ON DUPLICATE KEY UPDATE balance_juego = balance_juego + {$refAmount}");
                
                // Registrar en el Ledger del referidor
                $refWalletQuery = $db->selectSingle("SELECT id FROM uni1_wallets WHERE user_id = {$refId} AND currency_code = 'UNTX20_INT' LIMIT 1");
                if ($refWalletQuery) {
                    $refWalletId = (int)$refWalletQuery['id'];
                    $db->query("INSERT INTO uni1_ledger_entries (wallet_id, user_id, currency_code, amount, tipo, reference_id, metadata) 
                                VALUES ({$refWalletId}, {$refId}, 'UNTX20_INT', {$refAmount}, 'deposit', '{$uuid}', '{\"source\":\"referral_qvapay\"}')");
                }
            }
        } else {
            // Fallback si WalletFundHelper no está disponible (no debería pasar)
            error_log("QvaPay Webhook Error: WalletFundHelper no encontrado. Usando fallback.");
            $montoAlBanco = (int)floor($amountKyber * 0.70);
            $db->query("UPDATE uni1_wallet_fund SET 
                kyber_banco = kyber_banco + {$montoAlBanco}, 
                kyber_banco_qvapay = kyber_banco_qvapay + {$montoAlBanco}, 
                total_invertido_historico = total_invertido_historico + {$amountKyber} 
                WHERE id = 1");
        }

        $db->commit();
        error_log("QvaPay Webhook Éxito: User $userId, UNTX-20 $amountKyber, UUID $uuid");
        
        http_response_code(200);
        echo json_encode(['status' => 'success', 'message' => 'Pago procesado correctamente']);

    } catch (Exception $e) {
        $db->rollBack();
        error_log("QvaPay Webhook DB Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Error interno procesando el pago en la BD: ' . $e->getMessage()]);
    }

} catch (Throwable $e) {
    error_log("QvaPay Webhook General Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Error interno general: ' . $e->getMessage(),
        'linea' => $e->getLine(),
        'archivo' => basename($e->getFile())
    ]);
}