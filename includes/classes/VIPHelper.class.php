<?php
/**
 * AstroIO — VIPHelper v2.8
 * Gestor del sistema VIP Prime con Doble Riel (CUP / QvaPay)
 * Archivo: includes/classes/VIPHelper.class.php
 *
 * v2.0 — 3 packs: Semanal (7d) · Quincenal (15d) · Mensual (30d)
 * v2.1 — Descuentos + POPULAR rotativo semanal
 * v2.2 — Última recompensa diaria en JSON + countdown próxima recompensa
 * v2.3 — Recompensa basada en 24h exactas desde el último reclamo
 * v2.4 — IDs de boosters VIP cambiados de 6/7/8 a 14/15/16
 * v2.5 — Cofres: 1 cofre GARANTIZADO + extra por probabilidad (acumulativo)
 * v2.6 — Añadido buyVIP() para cobrar en NTX-20 o UNTX-20 según metodo_retiro
 * v2.7 — El precio en UNTX-20 es el DOBLE (x2) del precio en NTX-20
 * v2.8 — Precios rebajados (65 / 165 / 260) + ntx_old para mostrar oferta
 *         + helpers getDiscountPercent() y getSavings()
 */

class VIPHelper
{
    /**
     * Configuración de los packs VIP
     */
    public static function getPacks(): array
    {
        // 🔥 Detectar cuál pack es POPULAR esta semana
        $popularPack = self::getWeeklyPopularPack();

        return [
            'weekly' => [
                'id' => 'weekly', 'name' => 'VIP Semanal', 'days' => 7,
                'ntx' => 65, 'ntx_old' => 75, 'usd' => 65,
                'price_month' => '-13%', 'popular' => ($popularPack === 'weekly'),
                'booster_id' => 14,
                'bonus' => [
                    'attack' => 0.10, 'defense' => 0.10, 'shield' => 0.10,
                    'build_time' => -0.05, 'research_time' => -0.05,
                    'production' => 0.08, 'flight_time' => -0.05,
                    'expedition_slots' => 1,
                ],
                'daily_res_min' => 1000, 'daily_res_max' => 2500,
                'daily_bonus_chance' => 20, 'daily_bonus_value' => 3,
                'daily_chest_chance' => 15, 'daily_chest_min' => 1, 'daily_chest_max' => 3,
            ],
            'biweekly' => [
                'id' => 'biweekly', 'name' => 'VIP Quincenal', 'days' => 15,
                'ntx' => 165, 'ntx_old' => 190, 'usd' => 165,
                'price_month' => '-13%', 'popular' => ($popularPack === 'biweekly'),
                'booster_id' => 15,
                'bonus' => [
                    'attack' => 0.15, 'defense' => 0.15, 'shield' => 0.15,
                    'build_time' => -0.07, 'research_time' => -0.07,
                    'production' => 0.10, 'flight_time' => -0.07,
                    'expedition_slots' => 1,
                ],
                'daily_res_min' => 2000, 'daily_res_max' => 3500,
                'daily_bonus_chance' => 25, 'daily_bonus_value' => 4,
                'daily_chest_chance' => 20, 'daily_chest_min' => 2, 'daily_chest_max' => 4,
            ],
            'monthly' => [
                'id' => 'monthly', 'name' => 'VIP Mensual', 'days' => 30,
                'ntx' => 260, 'ntx_old' => 300, 'usd' => 260,
                'price_month' => '★ Mejor valor', 'popular' => ($popularPack === 'monthly'),
                'booster_id' => 16,
                'bonus' => [
                    'attack' => 0.25, 'defense' => 0.25, 'shield' => 0.25,
                    'build_time' => -0.10, 'research_time' => -0.10,
                    'production' => 0.15, 'flight_time' => -0.10,
                    'expedition_slots' => 2,
                ],
                'daily_res_min' => 3000, 'daily_res_max' => 5000,
                'daily_bonus_chance' => 30, 'daily_bonus_value' => 5,
                'daily_chest_chance' => 25, 'daily_chest_min' => 2, 'daily_chest_max' => 5,
            ],
        ];
    }

    /**
     * 🔥 Devuelve el pack más comprado en los últimos 7 días.
     * Se usa para rotar el badge POPULAR cada semana.
     */
    public static function getWeeklyPopularPack(): string
    {
        global $db;
        $prefix = self::prefix();

        try {
            $row = $db->selectSingle(
                "SELECT `vip_type`, COUNT(*) AS total
                 FROM `".$prefix."users_vip`
                 WHERE `vip_start` >= (UNIX_TIMESTAMP() - 604800)
                 GROUP BY `vip_type`
                 ORDER BY total DESC
                 LIMIT 1"
            );

            if ($row && !empty($row['vip_type'])) {
                $type = (string)$row['vip_type'];
                if (in_array($type, ['weekly', 'biweekly', 'monthly'], true)) {
                    return $type;
                }
            }
        } catch (Exception $e) {
            // Si falla la consulta, usamos el default
        }

        return 'monthly';
    }

    /**
     * 🆕 v2.8 — Descuento aplicado en % (entero, redondeado).
     * Devuelve 0 si el pack no tiene oferta activa.
     */
    public static function getDiscountPercent(string $packId): int
    {
        $packs = self::getPacks();
        if (!isset($packs[$packId])) return 0;

        $new = (int)$packs[$packId]['ntx'];
        $old = isset($packs[$packId]['ntx_old']) ? (int)$packs[$packId]['ntx_old'] : 0;

        if ($old <= 0 || $old <= $new) return 0;

        return (int)round((($old - $new) / $old) * 100);
    }

    /**
     * 🆕 v2.8 — Ahorro absoluto en NTX-20 (precio antiguo - precio nuevo).
     */
    public static function getSavings(string $packId): int
    {
        $packs = self::getPacks();
        if (!isset($packs[$packId])) return 0;

        $new = (int)$packs[$packId]['ntx'];
        $old = isset($packs[$packId]['ntx_old']) ? (int)$packs[$packId]['ntx_old'] : 0;

        return max(0, $old - $new);
    }

    /**
     * Lista de beneficios para mostrar en la página
     */
    public static function getBenefits(): array
    {
        return [
            ['icon' => '⚔️', 'text' => '<b>+10% a +25%</b> de ataque según tu plan'],
            ['icon' => '🛡️', 'text' => '<b>+10% a +25%</b> de defensa según tu plan'],
            ['icon' => '🔰', 'text' => '<b>+10% a +25%</b> de escudo según tu plan'],
            ['icon' => '🏗️', 'text' => '<b>-5% a -10%</b> tiempo de construcción'],
            ['icon' => '🔬', 'text' => '<b>-5% a -10%</b> tiempo de investigación'],
            ['icon' => '📦', 'text' => '<b>+8% a +15%</b> producción de recursos'],
            ['icon' => '🚀', 'text' => '<b>-5% a -10%</b> tiempo de vuelo (acumulable con Almirante)'],
            ['icon' => '🛸', 'text' => '<b>+1 a +2</b> slots de expedición'],
            ['icon' => '💰', 'text' => '<b>1.000 a 5.000</b> recursos aleatorios <b>cada 24h</b>'],
            ['icon' => '🎁', 'text' => '<b>1 cofre garantizado + extras</b> cada 24h'],
            ['icon' => '💎', 'text' => '<b>+3% a +5%</b> bonus pasivo temporal (24h)'],
            ['icon' => '⭐', 'text' => 'Icono VIP junto al nombre + color especial en el chat'],
        ];
    }

    /**
     * Prefijo de tablas
     */
    private static function prefix(): string
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    /**
     * v2.7 — COMPRA DE VIP CON DOBLE RIEL
     * Detecta el método de pago y cobra en NTX-20 o UNTX-20.
     * REGLA: UNTX-20 cuesta el DOBLE (x2) que NTX-20.
     */
    public static function buyVIP($userId, $packId): array
    {
        global $db, $USER;

        $packs = self::getPacks();
        if (!isset($packs[$packId])) {
            return ['error' => 'El pack VIP seleccionado no existe.'];
        }

        $pack  = $packs[$packId];
        $precioBase = (int)$pack['ntx']; // Precio base para NTX-20
        $userId = (int)$userId;
        $prefix = self::prefix();

        // 1. Leer datos del jugador para saber su riel y saldo
        $userRow = $db->selectSingle(
            "SELECT metodo_retiro, ntx20, untx20 FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
            [':uid' => $userId]
        );

        if (!$userRow) {
            return ['error' => 'Usuario no encontrado.'];
        }

        $metodo = isset($userRow['metodo_retiro']) ? $userRow['metodo_retiro'] : 'CUP';
        $saldoNtx = (int)$userRow['ntx20'];
        $saldoUntx = isset($userRow['untx20']) ? (int)$userRow['untx20'] : 0;

        $columnaPago = 'ntx20';
        $saldoActual = $saldoNtx;
        $monedaLabel = 'NTX-20';
        $sourceDb    = 'ntx20';
        $precioFinal = $precioBase; // Por defecto es el precio normal

        if ($metodo === 'QVAPAY') {
            $columnaPago = 'untx20';
            $saldoActual = $saldoUntx;
            $monedaLabel = 'UNTX-20';
            $sourceDb    = 'qvapay';
            $precioFinal = $precioBase * 2; // 🔥 EL DOBLE PARA UNTX-20
        }

        // 2. Verificar saldo suficiente
        if ($saldoActual < $precioFinal) {
            return ['error' => 'No tienes suficiente ' . $monedaLabel . '. Necesitas ' . number_format($precioFinal, 0, ',', '.') . ' y tienes ' . number_format($saldoActual, 0, ',', '.') . '.'];
        }

        // 3. Descontar saldo de la tabla global
        $db->update(
            "UPDATE `".$prefix."users` SET `".$columnaPago."` = `".$columnaPago."` - :price WHERE id = :uid",
            [':price' => $precioFinal, ':uid' => $userId]
        );

        // 4. Actualizar la sesión global para que el Topnav se actualice al instante
        if (isset($GLOBALS['USER']['id']) && (int)$GLOBALS['USER']['id'] === $userId) {
            if ($columnaPago === 'untx20') {
                $GLOBALS['USER']['untx20'] = $saldoUntx - $precioFinal;
            } else {
                $GLOBALS['USER']['ntx20'] = $saldoNtx - $precioFinal;
            }
        }

        // 5. Activar el VIP
        self::activate($userId, $packId, $sourceDb);

        return [
            'success' => true,
            'currency' => $monedaLabel,
            'paid' => $precioFinal
        ];
    }

    /**
     * ¿El usuario tiene VIP activo? (con lazy expiration)
     */
    public static function isVIP($userId): bool
    {
        global $db;
        $userId = (int)$userId;
        $prefix = self::prefix();

        $row = $db->selectSingle(
            "SELECT * FROM `".$prefix."users_vip`
             WHERE `user_id` = :uid AND `vip_active` = 1
             ORDER BY `vip_end` DESC LIMIT 1;",
            [':uid' => $userId]
        );

        if (!$row) return false;

        // Expiración lazy
        if ((int)$row['vip_end'] < TIMESTAMP) {
            $db->update(
                "UPDATE `".$prefix."users_vip` SET `vip_active` = 0 WHERE `vip_id` = :vid;",
                [':vid' => (int)$row['vip_id']]
            );
            return false;
        }
        return true;
    }

    /**
     * Devuelve los datos del VIP activo (o null)
     */
    public static function getVIPData($userId): ?array
    {
        global $db;
        $userId = (int)$userId;
        $prefix = self::prefix();

        return $db->selectSingle(
            "SELECT * FROM `".$prefix."users_vip`
             WHERE `user_id` = :uid AND `vip_active` = 1
             ORDER BY `vip_end` DESC LIMIT 1;",
            [':uid' => $userId]
        );
    }

    /**
     * Activa el VIP para un usuario
     */
    public static function activate($userId, $packId, $source = 'ntx20'): bool
    {
        global $db;
        $packs = self::getPacks();
        if (!isset($packs[$packId])) return false;

        $userId = (int)$userId;
        $prefix = self::prefix();
        $days   = (int)$packs[$packId]['days'];
        $now    = TIMESTAMP;
        $end    = $now + ($days * 86400);

        // Desactivar VIP previo
        $db->update(
            "UPDATE `".$prefix."users_vip` SET `vip_active` = 0 WHERE `user_id` = :uid;",
            [':uid' => $userId]
        );

        // Insertar nuevo VIP
        $db->insert(
            "INSERT INTO `".$prefix."users_vip`
             (`user_id`, `vip_type`, `vip_start`, `vip_end`, `vip_source`, `vip_active`)
             VALUES (:uid, :type, :start, :end, :src, 1);",
            [
                ':uid'   => $userId,
                ':type'  => $packId,
                ':start' => $now,
                ':end'   => $end,
                ':src'   => $source,
            ]
        );
        return true;
    }

    /**
     * Desactiva el VIP (admin)
     */
    public static function expire($userId): bool
    {
        global $db;
        $userId = (int)$userId;
        $prefix = self::prefix();

        $db->update(
            "UPDATE `".$prefix."users_vip` SET `vip_active` = 0 WHERE `user_id` = :uid;",
            [':uid' => $userId]
        );
        return true;
    }

    /**
     * Devuelve el bonus de un tipo (0.10 = +10%)
     */
    public static function getBonus($userId, $type): float
    {
        if (!self::isVIP($userId)) return 0.0;

        $data = self::getVIPData($userId);
        if (!$data) return 0.0;

        $packs = self::getPacks();
        $vip   = $data['vip_type'];

        if (!isset($packs[$vip]['bonus'][$type])) return 0.0;

        return (float)$packs[$vip]['bonus'][$type];
    }

    /**
     * Devuelve los datos de la última recompensa diaria (o null).
     */
    public static function getLastReward($userId): ?array
    {
        $data = self::getVIPData($userId);
        if (!$data || empty($data['last_reward_json'])) return null;

        $decoded = json_decode($data['last_reward_json'], true);
        if (!is_array($decoded)) return null;

        return $decoded;
    }

    /**
     * Devuelve el timestamp UNIX de cuándo estará disponible la próxima recompensa
     */
    public static function getNextRewardTime($userId): int
    {
        $data = self::getVIPData($userId);
        if (!$data) return 0;

        $last = (int)$data['last_daily_reward'];

        if ($last <= 0) return TIMESTAMP;

        $next = $last + 86400;

        return ($next <= TIMESTAMP) ? TIMESTAMP : $next;
    }

    /**
     * ¿El usuario puede reclamar la recompensa ahora mismo?
     */
    public static function canClaimDaily($userId): bool
    {
        $data = self::getVIPData($userId);
        if (!$data) return false;

        $last = (int)$data['last_daily_reward'];

        if ($last <= 0) return true;

        return (TIMESTAMP - $last) >= 86400;
    }

    /**
     * Reclama la recompensa diaria (cada 24h exactas)
     */
    public static function claimDailyReward($userId): ?array
    {
        global $db, $PLANET;
        if (!self::isVIP($userId)) return null;

        $data = self::getVIPData($userId);
        if (!$data) return null;

        $last = (int)$data['last_daily_reward'];

        if ($last > 0 && (TIMESTAMP - $last) < 86400) {
            return null;
        }

        $packs  = self::getPacks();
        $pack   = $packs[$data['vip_type']];
        $prefix = self::prefix();
        $userId = (int)$userId;

        // 1. RECURSOS
        $total     = mt_rand($pack['daily_res_min'], $pack['daily_res_max']);
        $metal     = mt_rand(0, $total);
        $rest      = $total - $metal;
        $crystal   = mt_rand(0, $rest);
        $deuterium = $rest - $crystal;

        if (isset($PLANET['id'])) {
            $newMetal     = $PLANET['metal']     + $metal;
            $newCrystal   = $PLANET['crystal']   + $crystal;
            $newDeuterium = $PLANET['deuterium'] + $deuterium;

            $db->update(
                "UPDATE `".$prefix."planets` SET
                    metal     = :m,
                    crystal   = :c,
                    deuterium = :d,
                    last_update = :now
                 WHERE id = :pid;",
                [
                    ':m'   => $newMetal,
                    ':c'   => $newCrystal,
                    ':d'   => $newDeuterium,
                    ':now' => TIMESTAMP,
                    ':pid' => (int)$PLANET['id'],
                ]
            );

            $PLANET['metal']       = $newMetal;
            $PLANET['crystal']     = $newCrystal;
            $PLANET['deuterium']   = $newDeuterium;
            $PLANET['last_update'] = TIMESTAMP;

            if (isset($GLOBALS['PLANET'])) {
                $GLOBALS['PLANET']['metal']       = $newMetal;
                $GLOBALS['PLANET']['crystal']     = $newCrystal;
                $GLOBALS['PLANET']['deuterium']   = $newDeuterium;
                $GLOBALS['PLANET']['last_update'] = TIMESTAMP;
            }
        }

        // 2. BONUS PASIVO
        $bonusApplied = false;
        $bonusValue   = 0;

        if (mt_rand(1, 100) <= $pack['daily_bonus_chance']) {
            $boosterId = (int)$pack['booster_id'];
            $expiresAt = TIMESTAMP + 86400;

            $existing = $db->selectSingle(
                "SELECT id FROM `".$prefix."users_boosters`
                 WHERE user_id = :uid AND booster_id = :bid;",
                [':uid' => $userId, ':bid' => $boosterId]
            );

            if ($existing) {
                $db->update(
                    "UPDATE `".$prefix."users_boosters`
                     SET expires_at = :exp, applied_at = :app
                     WHERE id = :id;",
                    [':exp' => $expiresAt, ':app' => TIMESTAMP, ':id' => (int)$existing['id']]
                );
            } else {
                $db->insert(
                    "INSERT INTO `".$prefix."users_boosters`
                     (user_id, booster_id, expires_at, applied_at)
                     VALUES (:uid, :bid, :exp, :app);",
                    [':uid' => $userId, ':bid' => $boosterId,
                     ':exp' => $expiresAt, ':app' => TIMESTAMP]
                );
            }

            $bonusApplied = true;
            $bonusValue   = (int)$pack['daily_bonus_value'];
        }

        // 3. COFRES
        $chestsGiven = 1;
        if (mt_rand(1, 100) <= $pack['daily_chest_chance']) {
            $chestsGiven += mt_rand($pack['daily_chest_min'], $pack['daily_chest_max']);
        }

        $db->update(
            "UPDATE `".$prefix."users` SET containers = containers + :c WHERE id = :uid;",
            [':c' => $chestsGiven, ':uid' => $userId]
        );

        if (isset($GLOBALS['USER']['containers'])) {
            $GLOBALS['USER']['containers'] += $chestsGiven;
        }

        // 4. GUARDAR JSON
        $rewardData = [
            'metal'         => (int)$metal,
            'crystal'       => (int)$crystal,
            'deuterium'     => (int)$deuterium,
            'total'         => (int)$total,
            'bonus_applied' => (bool)$bonusApplied,
            'bonus_value'   => (int)$bonusValue,
            'chests'        => (int)$chestsGiven,
            'claimed_at'    => TIMESTAMP,
        ];

        $db->update(
            "UPDATE `".$prefix."users_vip`
             SET `last_daily_reward` = :now,
                 `last_reward_json`  = :json
             WHERE `vip_id` = :vid;",
            [
                ':now'  => TIMESTAMP,
                ':json' => json_encode($rewardData, JSON_UNESCAPED_UNICODE),
                ':vid'  => (int)$data['vip_id'],
            ]
        );

        return $rewardData;
    }
}