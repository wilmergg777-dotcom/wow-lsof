<?php
/**
 * Limpiador Automático de Depósitos QvaPay Pendientes
 * Ubicación: Raíz del proyecto
 */

define('MODE', 'INGAME');
define('ROOT_PATH', str_replace('\\', '/', dirname(__FILE__)) . '/');
set_include_path(ROOT_PATH);

// Cargar el entorno de 2Moons
$commonFile = ROOT_PATH . 'includes/common.php';
if (!file_exists($commonFile)) {
    exit; // Si no está el common, salimos silenciosamente
}
require_once $commonFile;

$db = Database::get();
$prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';

try {
    // Aquí defines el tiempo: 
    // Para 30 minutos: INTERVAL 30 MINUTE
    // Para 1 hora: INTERVAL 1 HOUR
    // Para 2 horas: INTERVAL 2 HOUR
    $sql = "DELETE FROM {$prefix}qvapay_deposits 
            WHERE status = 'pending' 
            AND created_at < DATE_SUB(NOW(), INTERVAL 2 HOUR)";
            
    $db->query($sql);
    
} catch (Exception $e) {
    // Si falla, que no rompa el cron
    error_log("Error en cron_qvapay_clean: " . $e->getMessage());
}