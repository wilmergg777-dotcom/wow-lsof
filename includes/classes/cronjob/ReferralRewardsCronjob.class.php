<?php
/**
 * AstroIO - Cron de Recompensas por Referidos
 * Ruta: includes/classes/cronjob/ReferralRewardsCronjob.class.php
 */

class ReferralRewardsCronjob
{
    public static function run()
    {
        $db = $GLOBALS['DATABASE'];
        $time = time();

        // Buscar invitados que han alcanzado los puntos y cuyos invitadores no han recibido el premio aún
        $sql = "SELECT 
                    r.id AS reward_id,
                    r.reward_metal, r.reward_crystal, r.reward_deuterium, r.reward_ntx20, r.reward_darkmatter,
                    r.reward_cont_generic, r.reward_box_common, r.reward_box_rare, r.reward_box_legendary,
                    u.id AS invited_id,
                    u.username AS invited_name,
                    u.ref_id AS inviter_id,
                    p.id AS inviter_planet_id
                FROM `uni1_users` u
                INNER JOIN `uni1_statpoints` sp ON u.id = sp.id_owner AND sp.stat_type = 1
                INNER JOIN `uni1_referral_rewards` r ON sp.total_points >= r.points_required
                INNER JOIN `uni1_users` inviter ON inviter.id = u.ref_id
                INNER JOIN `uni1_planets` p ON p.id = inviter.id_planet AND p.planet_type = 1
                LEFT JOIN `uni1_referral_rewards_history` h ON h.reward_id = r.id AND h.inviter_id = u.ref_id AND h.invited_id = u.id
                WHERE 
                    u.ref_id > 0 
                    AND r.is_active = 1 
                    AND (r.is_permanent = 1 OR (r.start_time <= " . $time . " AND r.end_time >= " . $time . "))
                    AND h.id IS NULL";

        $result = $db->query($sql);

        while ($row = $db->fetch_array($result)) {
            $inviterId = (int)$row['inviter_id'];
            $invitedId = (int)$row['invited_id'];
            $rewardId = (int)$row['reward_id'];
            $planetId = (int)$row['inviter_planet_id'];

            // 1. Entregar Recursos al Planeta del Invitador
            if ($row['reward_metal'] > 0 || $row['reward_crystal'] > 0 || $row['reward_deuterium'] > 0) {
                $db->query("UPDATE `uni1_planets` SET 
                            `metal` = `metal` + " . (float)$row['reward_metal'] . ",
                            `crystal` = `crystal` + " . (float)$row['reward_crystal'] . ",
                            `deuterium` = `deuterium` + " . (float)$row['reward_deuterium'] . " 
                            WHERE `id` = " . $planetId);
            }

            // 2. Entregar NTX-20, MO y Contenedores al Usuario Invitador
            if ($row['reward_ntx20'] > 0 || $row['reward_darkmatter'] > 0 || $row['reward_cont_generic'] > 0) {
                $db->query("UPDATE `uni1_users` SET 
                            `ntx20` = `ntx20` + " . (int)$row['reward_ntx20'] . ",
                            `darkmatter` = `darkmatter` + " . (float)$row['reward_darkmatter'] . ",
                            `containers` = `containers` + " . (int)$row['reward_cont_generic'] . " 
                            WHERE `id` = " . $inviterId);
            }

            // 3. Entregar Cofres al Invitador (Tabla Market)
            if ($row['reward_box_common'] > 0 || $row['reward_box_rare'] > 0 || $row['reward_box_legendary'] > 0) {
                $db->query("UPDATE `uni1_users_market` SET 
                            `box_common` = `box_common` + " . (int)$row['reward_box_common'] . ",
                            `box_rare` = `box_rare` + " . (int)$row['reward_box_rare'] . ",
                            `box_legendary` = `box_legendary` + " . (int)$row['reward_box_legendary'] . " 
                            WHERE `user_id` = " . $inviterId);
            }

            // 4. Registrar en el Historial para no pagar dos veces
            $db->query("INSERT INTO `uni1_referral_rewards_history` 
                        (`reward_id`, `inviter_id`, `invited_id`, `claim_date`) 
                        VALUES 
                        (" . $rewardId . ", " . $inviterId . ", " . $invitedId . ", " . $time . ")");

            // 5. Enviar Mensaje Privado al Invitador
            $msgFrom = 'Sistema de Referidos';
            $msgSubject = '¡Recompensa de Referido Obtenida!';
            $msgText = '¡Felicidades! Tu referido ' . $row['invited_name'] . ' ha alcanzado la puntuación requerida. Has recibido las recompensas correspondientes.';
            
            PlayerUtil::sendMessage($inviterId, 0, $msgFrom, $subject = $msgSubject, $msgText, $time, null, 0, 0, 1);
        }
    }
}