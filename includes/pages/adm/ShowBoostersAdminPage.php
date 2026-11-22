<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * ============================================
 *  ASTROIO - Panel Admin de Boosters
 *  Archivo: includes/pages/adm/ShowBoostersAdminPage.php
 * ============================================
 */

if (!allowedTo(str_replace(array(dirname(__FILE__), '\\', '/', '.php'), '', __FILE__))) throw new Exception("Permission error!");

function ShowBoostersAdmin()
{
    global $LNG;

    $template = new template();
    $db       = Database::get();
    $action   = HTTP::_GP('action', '');

    $message = '';
    $msgType = 'info';

    // ============================================
    // PREFIJO DE TABLAS
    // ============================================
    $prefix = 'uni1_';
    if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
    elseif (defined('PREFIX')) $prefix = PREFIX;

    // ============================================
    // PROCESAR ACCIÓN: REGALAR BOOSTERS
    // ============================================
    if ($action == 'send') {

        $userId     = (int) HTTP::_GP('user_id', 0);
        $hours      = (int) HTTP::_GP('hours', 24);
        $boosterIds = (isset($_POST['boosters']) && is_array($_POST['boosters']))
                        ? array_map('intval', $_POST['boosters'])
                        : array();

        // Validaciones
        if ($hours < 1)   $hours = 1;
        if ($hours > 720) $hours = 720;

        $boosterIds = array_filter($boosterIds, function($id) { return $id > 0; });

        if (empty($boosterIds)) {
            $message = '❌ No seleccionaste ningún potenciador.';
            $msgType = 'error';
        } elseif ($userId === 0) {
            $message = '❌ Seleccioná un destinatario válido.';
            $msgType = 'error';
        } else {

            $expiresAt = TIMESTAMP + ($hours * 3600);

            // Lista de destinatarios
            if ($userId === -1) {
                // TODOS los jugadores
                $targets = $db->select("SELECT id, username FROM `".$prefix."users`");
                if (!is_array($targets)) $targets = array();
            } else {
                // Un jugador específico
                $targets = $db->select(
                    "SELECT id, username FROM `".$prefix."users` WHERE id = :id",
                    array(':id' => $userId)
                );
                if (!is_array($targets)) $targets = array();
            }

            if (empty($targets)) {
                $message = '❌ No se encontraron destinatarios.';
                $msgType = 'error';
            } else {
                $totalAssigned = 0;

                foreach ($targets as $u) {
                    foreach ($boosterIds as $bid) {
                        // Evitar duplicado exacto (mismo user + booster + expires_at)
                        // Si ya tiene ese booster, actualizamos expiración
                        $existing = $db->selectSingle(
                            "SELECT id, expires_at FROM `".$prefix."users_boosters` 
                             WHERE user_id = :uid AND booster_id = :bid 
                             ORDER BY id DESC LIMIT 1",
                            array(':uid' => (int)$u['id'], ':bid' => $bid)
                        );

                        if (is_array($existing) && isset($existing['id'])) {
                            // Extender expiración
                            $newExpires = max((int)$existing['expires_at'], TIMESTAMP) + ($hours * 3600);
                            $db->update(
                                "UPDATE `".$prefix."users_boosters` 
                                 SET expires_at = :exp, applied_at = :now 
                                 WHERE id = :id",
                                array(
                                    ':exp' => $newExpires,
                                    ':now' => TIMESTAMP,
                                    ':id'  => (int)$existing['id'],
                                )
                            );
                            $totalAssigned++;
                        } else {
                            // Insertar nuevo
                            $db->insert(
                                "INSERT INTO `".$prefix."users_boosters` 
                                 (user_id, booster_id, expires_at, applied_at)
                                 VALUES (:uid, :bid, :exp, :now)",
                                array(
                                    ':uid' => (int)$u['id'],
                                    ':bid' => $bid,
                                    ':exp' => $expiresAt,
                                    ':now' => TIMESTAMP,
                                )
                            );
                            $totalAssigned++;
                        }
                    }
                }

                $countUsers = count($targets);
                $countBoosters = count($boosterIds);
                $message = '✅ Se asignaron ' . $totalAssigned . ' potenciadores '
                         . '(' . $countBoosters . ' por usuario × ' . $countUsers . ' usuario/s) '
                         . 'durante ' . $hours . 'h.';
                $msgType = 'success';
            }
        }
    }

    // ============================================
    // CARGAR DATOS PARA LA VISTA
    // ============================================

    // ─── Lista de usuarios (para el select) ───
    $users = $db->select(
        "SELECT id, username FROM `".$prefix."users` ORDER BY username ASC"
    );
    if (!is_array($users)) $users = array();

    // ─── Catálogo de boosters (FILTRADO PARA OCULTAR LOS 3 VIP) ───
    $boosters = $db->select(
        "SELECT booster_id, booster_name, booster_desc, booster_icon, booster_color,
                booster_type, booster_value, booster_duration
         FROM `".$prefix."boosters` 
         WHERE booster_name != 'Bonus VIP Semanal' 
           AND booster_name != 'Bonus VIP Quincenal' 
           AND booster_name != 'Bonus VIP Mensual'
         ORDER BY booster_id ASC"
    );
    if (!is_array($boosters)) $boosters = array();

    foreach ($boosters as &$b) {
        // Icono emoji (usar el campo booster_icon tal cual)
        $b['icon_emoji'] = !empty($b['booster_icon']) ? $b['booster_icon'] : '⚡';

        // Valor formateado
        $b['booster_value'] = rtrim(rtrim(number_format((float)$b['booster_value'], 2, '.', ''), '0'), '.');
    }
    unset($b);

    // ============================================
    // ASIGNAR VARIABLES Y MOSTRAR
    // ============================================
    $template->assign_vars(array(
        'users'    => $users,
        'boosters' => $boosters,
        'message'  => $message,
        'msgType'  => $msgType,
    ));

    $template->show("boostersAdminPage.tpl");
}