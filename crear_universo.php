<?php
// ═══════════════════════════════════════════════════════════
// SCRIPT DE CLONACIÓN AUTOMÁTICA PARA XVAPAY / 2MOONS CUSTOM
// ═══════════════════════════════════════════════════════════

// 1. CONFIGURACIÓN
$universoOrigen = 1; // Copiaremos del uni1
$universoNuevo  = 2; // El número del universo que vas a crear

// ⚠️ CONEXIÓN A LA BASE DE DATOS (Cámbialo por los tuyos)
$dbHost = 'localhost';
$dbUser = 'AstroIO';
$dbPass = 'AstroIO*97';
$dbName = 'xnova_db'; // Tu base de datos según la captura

try {
    $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Error de conexión: " . $e->getMessage());
}

echo "<h2>Iniciando clonación del Universo $universoOrigen al Universo $universoNuevo...</h2>";

// 2. OBTENER TODAS LAS TABLAS DEL UNIVERSO ORIGEN
$stmt = $pdo->prepare("SHOW TABLES LIKE 'uni{$universoOrigen}_%'");
$stmt->execute();
$tablasOrigen = $stmt->fetchAll(PDO::FETCH_COLUMN);

if (empty($tablasOrigen)) {
    die("No se encontraron tablas del Universo $universoOrigen.");
}

// 3. LISTA NEGRA: TABLAS QUE SE CREARÁN VACÍAS (Solo estructura, sin datos)
// Aquí están los jugadores, logs, transacciones, batallas activas, etc.
$tablasVacias = [
    // Jugadores y sus pertenencias
    'users', 'users_auth', 'users_bank_data', 'users_bank_data_requests', 
    'users_boosters', 'users_clima_buff', 'users_coord_favorites', 'users_events', 
    'users_faction_missions', 'users_fleet_presets', 'users_improvements_eq', 
    'users_improvements_inv', 'users_market', 'users_mistic', 'users_tasks', 
    'users_to_acs', 'users_to_extauth', 'users_to_topkb', 'users_valid', 
    'users_vip', 'users_wallet', 'users_achievements', 'planets', 'fleets', 
    'messages', 'session', 'buddy', 'buddy_request', 'notes', 'statpoints', 
    'banned', 'multi', 'lostpassword',
    
    // Alianzas
    'alliance', 'alliance_bank', 'alliance_bank_daily', 'alliance_bank_log', 
    'alliance_bank_tesorero_log', 'alliance_ranks', 'alliance_request', 
    'alliance_talent_log', 'alliance_talent_points', 'alliance_talent_ranks', 'aks',
    
    // Logs y reportes
    'raports', 'log', 'log_fleets', 'topkb', 'records', 'bug_log', 'bug_reports',
    'clima_log', 'clima_planeta', 'cronjobs_log', 'fleettools_log', 'bp_log',
    'ntx20_log', 'improvements_log', 'events_history', 'faction_missions_log', 
    'faction_global_contributions', 'referral_rewards_history', 'ledger_entries',
    'admin_bank_movements', 'admin_bank_transfers', 'admin_bank_accounts', 'admin_bank_data',
    
    // Chat y tickets
    'chat_bans', 'chat_invitations', 'chat_messages', 'chat_online', 
    'ticket', 'ticket_answer', 'broadcast_queue', 'telegram_links',

    // Mercado, Ruletas, Apuestas y Bancos (Dinámico)
    'market_fund', 'market_log', 'market_offers', 'market_stats', 
    'lottery_draws', 'lottery_log', 'lottery_tickets', 'raffle_log', 'raffle_tickets',
    'blackmarket_listings', 'cross_orders', 'cross_trades', 'war_battles', 
    'war_chests', 'war_history', 'war_log', 'war_participants', 'war_points',
    
    // PvE y PvP Activo
    'pve_acs_invites', 'pve_bastion_damage', 'pve_bastion_event', 'pve_bastion_ghosts', 
    'pve_bastion_registrations', 'pve_bastion_waves', 'pve_boss_damage', 'pve_boss_event', 
    'pve_boss_ghosts', 'pve_boss_registrations', 'pve_crisis', 'pve_crisis_attacks', 
    'pve_crisis_waves', 'pve_empire_attacks', 'pve_empires', 'pve_ghosts', 'pve_log',
    'pvp_arena_attacks', 'pvp_arena_players', 'pvp_arenas', 'pvp_log', 'pvp_tournament_attacks', 
    'pvp_tournament_matches', 'pvp_tournament_players', 'pvp_tournament_rounds', 'pvp_tournaments',
    'tourney', 'tourney_logs', 'tourney_participante',
    
    // Torneos, Cueva, Sistemas y Billeteras
    'cueva_ajedrez', 'cueva_disparos', 'cueva_flota', 'cueva_movimientos', 'cueva_partidas', 'cueva_salas',
    'gamedu', 'gamedu_tokens', 'withdraw_requests', 'wallet_banco_historial', 
    'wallet_investment_log', 'wallet_investments', 'wallet_stats_daily', 
    'wallet_tasa_historial', 'wallet_transactions', 'wallet_transfers_log', 
    'wallet_withdrawals', 'wallets', 'wallet_fund', 'wallet_referral_fund',
    'qvapay_accounts', 'qvapay_deposits', 'qvapay_webhook_log', 'qvapay_withdrawals',
    'shop_autosave', 'shop_purchases', 'asteroids', 'reserves', 'shortcuts', 
    'fleet_event', 'boosters', 'bp_users', 'system', 'improvements_seasons'
];

// 4. TABLAS QUE IGNORAREMOS POR COMPLETO (No se tocan)
$tablasIgnorar = [
    'universe_age_state', // Global para edades
    'events_backup_v1',   // Backups tuyos
    'events_backup_v12'   // Backups tuyos
];

$pdo->beginTransaction();

try {
    foreach ($tablasOrigen as $tablaVieja) {
        // Extraemos el sufijo. Ej: 'uni1_users' -> 'users'
        $sufijo = str_replace("uni{$universoOrigen}_", '', $tablaVieja);
        $tablaNueva = "uni{$universoNuevo}_{$sufijo}";

        // Si la tabla está en la lista de ignorar, pasamos a la siguiente
        if (in_array($sufijo, $tablasIgnorar)) {
            echo "⏭️ Ignorada (Global/Backup): <b>{$sufijo}</b><br>";
            continue;
        }

        // A. Borrar si ya existe
        $pdo->exec("DROP TABLE IF EXISTS {$tablaNueva}");

        // B. Crear la tabla nueva clonando la estructura
        $pdo->exec("CREATE TABLE {$tablaNueva} LIKE {$tablaVieja}");

        // C. Copiar datos si NO está en la lista de vacías
        if (!in_array($sufijo, $tablasVacias)) {
            $pdo->exec("INSERT INTO {$tablaNueva} SELECT * FROM {$tablaVieja}");
            echo "✅ <b>{$tablaNueva}</b> creada y copiada.<br>";
        } else {
            echo "🟢 <b>{$tablaNueva}</b> creada vacía.<br>";
        }
    }

    // 5. CONFIGURACIÓN INICIAL DEL NUEVO UNIVERSO
    // Lo ponemos Offline por defecto (game_disable = 1) para que lo configures antes de abrirlo
    $pdo->exec("UPDATE uni{$universoNuevo}_config SET uni_name = 'Nuevo Universo {$universoNuevo}', game_disable = 1");
    
    $pdo->commit();
    echo "<h3>🎉 ¡Universo $universoNuevo clonado perfectamente!</h3>";
    echo "<p>Ve a tu tabla <b>uni1_config</b> y añade una nueva fila para el universo $universoNuevo con su nombre para que aparezca en el login.</p>";

} catch (Exception $e) {
    $pdo->rollBack();
    die("<h3>❌ Error al clonar:</h3><p>" . $e->getMessage() . "</p>");
}