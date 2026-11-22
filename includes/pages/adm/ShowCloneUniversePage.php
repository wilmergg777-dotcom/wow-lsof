<?php

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");

function ShowCloneUniversePage()
{
    global $LNG;
    
    $message = '';
    
    // Si el formulario fue enviado
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] == 'clone') {
        $origen  = (int)$_POST['origen'];
        $destino = (int)$_POST['destino'];
        
        if ($origen == $destino) {
            $message = "<div style='color:#ff4444; font-weight:bold; padding:10px; background:#2a0000; border:1px solid #ff4444; border-radius:5px;'>❌ El universo Origen y Destino no pueden ser el mismo.</div>";
        } else {
            // Quitamos el límite de tiempo para que no se caiga el servidor
            set_time_limit(0); 
            ini_set('memory_limit', '512M');
            
            $message = procesarClonacion($origen, $destino);
        }
    }
    
    $template = new template();
    $template->assign_vars(array(
        'message'   => $message,
        'actionUrl' => 'admin.php?page=cloneuniverse'
    ));
    
    $template->show('page.admin.cloneuniverse.tpl');
}

function procesarClonacion($origen, $destino)
{
    // --- OBTENER CREDENCIALES ---
    // Intentamos usar las credenciales del formulario o las globales del juego
    $dbHost = !empty($_POST['db_host']) ? $_POST['db_host'] : (isset($GLOBALS['database']['host']) ? $GLOBALS['database']['host'] : '');
    $dbUser = !empty($_POST['db_user']) ? $_POST['db_user'] : (isset($GLOBALS['database']['user']) ? $GLOBALS['database']['user'] : '');
    $dbPass = !empty($_POST['db_pass']) ? $_POST['db_pass'] : (isset($GLOBALS['database']['password']) ? $GLOBALS['database']['password'] : '');
    $dbName = !empty($_POST['db_name']) ? $_POST['db_name'] : (isset($GLOBALS['database']['dbname']) ? $GLOBALS['database']['dbname'] : '');

    if (empty($dbHost) || empty($dbUser) || empty($dbName)) {
        return "<div style='color:#ff4444; padding:10px; background:#2a0000; border:1px solid #ff4444; border-radius:5px;'>❌ No se pudieron obtener las credenciales de la base de datos. Por favor, rellena los campos de conexión en el formulario.</div>";
    }

    try {
        $pdo = new PDO("mysql:host=$dbHost;dbname=$dbName;charset=utf8mb4", $dbUser, $dbPass);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    } catch (PDOException $e) {
        return "<div style='color:#ff4444; padding:10px; background:#2a0000; border:1px solid #ff4444; border-radius:5px;'>❌ Error de conexión a la BD: " . $e->getMessage() . "</div>";
    }
    
    // --- LISTAS PARA EL RESUMEN ---
    $copiadas = [];
    $errores  = [];
    $omitidas = [];

    $log = "<h3 style='color:#00e0ff;'>Clonando Universo $origen a Universo $destino...</h3>";
    $log .= "<div style='max-height:400px; overflow-y:auto; background:#000; padding:15px; border:1px solid #00e0ff; font-family:monospace; font-size:12px; border-radius:5px;'>";
    
    $stmt = $pdo->prepare("SHOW TABLES LIKE 'uni{$origen}_%'");
    $stmt->execute();
    $tablas = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($tablas)) {
        return "<div style='color:#ff4444;'>❌ No se encontraron tablas del Universo $origen.</div>";
    }

    // LISTA NEGRA DE TUS TABLAS (Vacías)
    $tablasVacias = [
        'users', 'users_auth', 'users_bank_data', 'users_bank_data_requests', 
        'users_boosters', 'users_clima_buff', 'users_coord_favorites', 'users_events', 
        'users_faction_missions', 'users_fleet_presets', 'users_improvements_eq', 
        'users_improvements_inv', 'users_market', 'users_mistic', 'users_tasks', 
        'users_to_acs', 'users_to_extauth', 'users_to_topkb', 'users_valid', 
        'users_vip', 'users_wallet', 'users_achievements', 'planets', 'fleets', 
        'messages', 'session', 'buddy', 'buddy_request', 'notes', 'statpoints', 
        'banned', 'multi', 'lostpassword', 'alliance', 'alliance_bank', 
        'alliance_bank_daily', 'alliance_bank_log', 'alliance_bank_tesorero_log', 
        'alliance_ranks', 'alliance_request', 'alliance_talent_log', 
        'alliance_talent_points', 'alliance_talent_ranks', 'aks', 'raports', 'log', 
        'log_fleets', 'topkb', 'records', 'bug_log', 'bug_reports', 'clima_log', 
        'clima_planeta', 'cronjobs_log', 'fleettools_log', 'bp_log', 'ntx20_log', 
        'improvements_log', 'events_history', 'faction_missions_log', 
        'faction_global_contributions', 'referral_rewards_history', 'ledger_entries',
        'admin_bank_movements', 'admin_bank_transfers', 'admin_bank_accounts', 'admin_bank_data',
        'chat_bans', 'chat_invitations', 'chat_messages', 'chat_online', 
        'ticket', 'ticket_answer', 'broadcast_queue', 'telegram_links',
        'market_fund', 'market_log', 'market_offers', 'market_stats', 
        'lottery_draws', 'lottery_log', 'lottery_tickets', 'raffle_log', 'raffle_tickets',
        'blackmarket_listings', 'cross_orders', 'cross_trades', 'war_battles', 
        'war_chests', 'war_history', 'war_log', 'war_participants', 'war_points',
        'pve_acs_invites', 'pve_bastion_damage', 'pve_bastion_event', 'pve_bastion_ghosts', 
        'pve_bastion_registrations', 'pve_bastion_waves', 'pve_boss_damage', 'pve_boss_event', 
        'pve_boss_ghosts', 'pve_boss_registrations', 'pve_crisis', 'pve_crisis_attacks', 
        'pve_crisis_waves', 'pve_empire_attacks', 'pve_empires', 'pve_ghosts', 'pve_log',
        'pvp_arena_attacks', 'pvp_arena_players', 'pvp_arenas', 'pvp_log', 'pvp_tournament_attacks', 
        'pvp_tournament_matches', 'pvp_tournament_players', 'pvp_tournament_rounds', 'pvp_tournaments',
        'tourney', 'tourney_logs', 'tourney_participante', 'cueva_ajedrez', 'cueva_disparos', 
        'cueva_flota', 'cueva_movimientos', 'cueva_partidas', 'cueva_salas',
        'gamedu', 'gamedu_tokens', 'withdraw_requests', 'wallet_banco_historial', 
        'wallet_investment_log', 'wallet_investments', 'wallet_stats_daily', 
        'wallet_tasa_historial', 'wallet_transactions', 'wallet_transfers_log', 
        'wallet_withdrawals', 'wallets', 'wallet_fund', 'wallet_referral_fund',
        'qvapay_accounts', 'qvapay_deposits', 'qvapay_webhook_log', 'qvapay_withdrawals',
        'shop_autosave', 'shop_purchases', 'asteroids', 'reserves', 'shortcuts', 
        'fleet_event', 'boosters', 'bp_users', 'system', 'improvements_seasons'
    ];

    $tablasIgnorar = ['universe_age_state', 'events_backup_v1', 'events_backup_v12'];
    
    // Procesamos cada tabla de forma independiente (try/catch por tabla)
    foreach ($tablas as $tablaVieja) {
        $sufijo = str_replace("uni{$origen}_", '', $tablaVieja);
        $tablaNueva = "uni{$destino}_{$sufijo}";

        if (in_array($sufijo, $tablasIgnorar)) {
            $omitidas[] = $tablaNueva;
            $log .= "<div style='color:#888;'>⏭️ Ignorada: $tablaNueva</div>";
            continue;
        }

        try {
            $pdo->exec("DROP TABLE IF EXISTS {$tablaNueva}");
            $pdo->exec("CREATE TABLE {$tablaNueva} LIKE {$tablaVieja}");

            if (!in_array($sufijo, $tablasVacias)) {
                $pdo->exec("INSERT INTO {$tablaNueva} SELECT * FROM {$tablaVieja}");
                $copiadas[] = $tablaNueva;
                $log .= "<div style='color:#00ff00;'>✅ $tablaNueva (Copiada con datos)</div>";
            } else {
                $copiadas[] = $tablaNueva; // También cuenta como copiada (pero vacía)
                $log .= "<div style='color:#ffff00;'>🟢 $tablaNueva (Creada vacía)</div>";
            }
        } catch (Exception $e) {
            $errores[] = $tablaNueva . " - " . $e->getMessage();
            $log .= "<div style='color:#ff4444;'>❌ $tablaNueva (ERROR: " . $e->getMessage() . ")</div>";
        }

        // Forzar a que el navegador muestre el progreso en tiempo real
        if (ob_get_level() > 0) { ob_flush(); }
        flush();
    }

    // Actualizar el nombre del universo destino
    try {
        $pdo->exec("UPDATE uni{$destino}_config SET uni_name = 'Nuevo Universo {$destino}', game_disable = 1");
    } catch (Exception $e) {
        $log .= "<div style='color:#ff4444;'>❌ Error al actualizar configuración: " . $e->getMessage() . "</div>";
    }

    $log .= "</div>";

    // --- RESUMEN FINAL ---
    $log .= "<div style='margin-top:20px; padding:15px; background:rgba(0,224,255,0.1); border:1px solid #00e0ff; border-radius:8px;'>";
    $log .= "<h4 style='color:#00e0ff; margin-top:0;'>📊 Resumen de la operación</h4>";
    $log .= "<p style='color:#00ff00;'><b>✅ Tablas copiadas correctamente:</b> " . count($copiadas) . "</p>";
    if (count($copiadas) > 0) {
        $log .= "<ul style='color:#00ff00; margin-top:5px;'>";
        foreach ($copiadas as $t) { $log .= "<li>$t</li>"; }
        $log .= "</ul>";
    }

    $log .= "<p style='color:#ff4444;'><b>❌ Tablas con errores:</b> " . count($errores) . "</p>";
    if (count($errores) > 0) {
        $log .= "<ul style='color:#ff4444; margin-top:5px;'>";
        foreach ($errores as $t) { $log .= "<li>$t</li>"; }
        $log .= "</ul>";
    }

    $log .= "<p style='color:#888;'><b>⏭️ Tablas omitidas:</b> " . count($omitidas) . "</p>";
    if (count($omitidas) > 0) {
        $log .= "<ul style='color:#888; margin-top:5px;'>";
        foreach ($omitidas as $t) { $log .= "<li>$t</li>"; }
        $log .= "</ul>";
    }
    $log .= "</div>";

    return $log;
}