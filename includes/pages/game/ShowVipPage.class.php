<?php
/**
 * AstroIO — Página VIP (?page=vip)
 * Archivo: includes/pages/game/ShowVipPage.class.php
 *
 * v2.0 — Compatible con los 3 packs nuevos: weekly (7d) · biweekly (15d) · monthly (30d)
 * v2.1 — UPDATE de ntx20 con guard "AND ntx20 >= :p" (evita condicion de carrera)
 * v2.2 — Envía al template: lastReward, nextRewardTime, nextRewardCountdown
 * v2.3 — Recompensa basada en 24h exactas desde el último reclamo
 * v2.4 — Recompensa diaria INSTANTÁNEA al comprar el VIP
 * v2.5 — Nuevo hook NTX20LogHelper::log() al comprar VIP
 * v2.6 — Doble Riel (CUP / QvaPay): Compra con NTX-20 o UNTX-20, 
 *        envía $vipMoneda y $vipSaldo al template.
 */

class ShowVipPage extends AbstractGamePage
{
    public function __construct()
    {
        parent::__construct();
        require_once ROOT_PATH . 'includes/classes/VIPHelper.class.php';

        // 🆕 ASTROIO v2.5 — Helper de auditoría NTX-20
        if (file_exists(ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php')) {
            require_once ROOT_PATH . 'includes/classes/NTX20LogHelper.class.php';
        }
    }

    /**
     * Prefijo de tablas
     */
    private function prefix(): string
    {
        if (defined('DB_PREFIX')) return DB_PREFIX;
        if (defined('PREFIX'))    return PREFIX;
        return 'uni1_';
    }

    public function show(): void
    {
        global $USER, $db;

        $prefix  = $this->prefix();
        $userId  = (int)$USER['id'];
        $action  = HTTP::_GP('action', '');
        $packId  = HTTP::_GP('pack', '');
        $message = '';
        $msgType = 'info';

        // 🆕 v2.6: Detectar el método de pago y el saldo actual
        $metodo = isset($USER['metodo_retiro']) ? $USER['metodo_retiro'] : 'CUP';
        $vipMoneda = ($metodo === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';
        $vipSaldo = ($metodo === 'QVAPAY') ? (int)($USER['untx20'] ?? 0) : (int)($USER['ntx20'] ?? 0);

        // ═══════════════════════════════════════════
        // COMPRAR PACK VIP
        // ═══════════════════════════════════════════
        if ($action === 'buy' && !empty($packId)) {
            $packs = VIPHelper::getPacks();
            if (isset($packs[$packId])) {
                $price = (int)$packs[$packId]['ntx'];

                // 🆕 v2.6: Llamar al nuevo método del Helper que maneja el Doble Riel
                $result = VIPHelper::buyVIP($userId, $packId);

                if (isset($result['error'])) {
                    $message = '❌ ' . $result['error'];
                    $msgType = 'error';
                } else {
                    // Éxito: El Helper ya descontó el saldo y activó el VIP

                    // 🆕 ASTROIO v2.5 — Registrar el gasto (solo si es NTX-20)
                    if ($metodo === 'CUP' && class_exists('NTX20LogHelper')) {
                        try {
                            NTX20LogHelper::log(
                                $userId,
                                -$price,
                                'vip_purchase',
                                $packs[$packId]['name'],
                                (int)$packs[$packId]['booster_id']
                            );
                        } catch (Exception $e) {
                            // silencioso
                        }
                    }

                    // 🆕 ASTROIO v2.4 — Dar la recompensa diaria AL INSTANTE al comprar
                    $firstReward = null;
                    try {
                        $firstReward = VIPHelper::claimDailyReward($userId);
                    } catch (Exception $e) {
                        // silencioso: si falla, el hook del Overview la dará después
                    }

                    // Construir mensaje de éxito
                    $message = '✅ ¡VIP ' . $packs[$packId]['name'] . ' activado! Pagaste ' . $result['paid'] . ' ' . $result['currency'] . '.';
                    
                    if ($firstReward) {
                        $message .= ' 🎁 Recompensa inicial: ';
                        $message .= number_format($firstReward['metal'])     . ' Metal · ';
                        $message .= number_format($firstReward['crystal'])   . ' Cristal · ';
                        $message .= number_format($firstReward['deuterium']) . ' Deuterio';
                        if (!empty($firstReward['bonus_applied'])) {
                            $message .= ' · Bonus +' . $firstReward['bonus_value'] . '% (24h)';
                        }
                        if (!empty($firstReward['chests']) && $firstReward['chests'] > 0) {
                            $message .= ' · ' . $firstReward['chests'] . ' cofre' . ($firstReward['chests'] > 1 ? 's' : '');
                        }
                    }
                    $msgType = 'success';
                }
            } else {
                $message = '❌ Pack inválido.';
                $msgType = 'error';
            }
        }

        // ═══════════════════════════════════════════
        // RECLAMAR RECOMPENSA DIARIA
        // ═══════════════════════════════════════════
        if ($action === 'daily') {
            $r = VIPHelper::claimDailyReward($userId);
            if ($r) {
                $msg = '🎁 Has recibido: ';
                $msg .= number_format($r['metal']) . ' Metal, ';
                $msg .= number_format($r['crystal']) . ' Cristal, ';
                $msg .= number_format($r['deuterium']) . ' Deuterio';

                if ($r['bonus_applied']) {
                    $msg .= ' + Bonus +' . $r['bonus_value'] . '% (24h)';
                }
                if ($r['chests'] > 0) {
                    $msg .= ' + ' . $r['chests'] . ' cofre' . ($r['chests'] > 1 ? 's' : '');
                }

                $message = $msg;
                $msgType = 'success';
            } else {
                $message = '⏳ Aún no han pasado 24h desde tu última recompensa. Revisa el temporizador.';
                $msgType = 'info';
            }
        }

        // ═══════════════════════════════════════════
        // CARGAR DATOS PARA LA VISTA
        // ═══════════════════════════════════════════
        $isVip   = VIPHelper::isVIP($userId);
        $vipData = $isVip ? VIPHelper::getVIPData($userId) : null;
        $packs   = VIPHelper::getPacks();
        $benefits= VIPHelper::getBenefits();

        // Días restantes
        $daysLeft = 0;
        if ($isVip && $vipData) {
            $daysLeft = max(0, (int)(($vipData['vip_end'] - TIMESTAMP) / 86400));
        }

        // ¿Puede reclamar ahora? (basado en 24h exactas desde el último reclamo)
        $canClaimDaily = $isVip ? VIPHelper::canClaimDaily($userId) : false;

        // Datos de la última recompensa y countdown de la próxima
        $lastReward       = $isVip ? VIPHelper::getLastReward($userId) : null;
        $nextRewardTime   = $isVip ? VIPHelper::getNextRewardTime($userId) : 0;
        $nextRewardRemain = ($nextRewardTime > 0) ? max(0, $nextRewardTime - TIMESTAMP) : 0;

        $this->assign([
            'isVip'               => $isVip,
            'vipData'             => $vipData,
            'vipPacks'            => $packs,
            'vipBenefits'         => $benefits,
            'vipMessage'          => $message,
            'vipMsgType'          => $msgType,
            'vipDaysLeft'         => $daysLeft,
            
            // 🆕 v2.6: Variables para el Doble Riel
            'vipSaldo'            => $vipSaldo,
            'vipMoneda'           => $vipMoneda,

            'vipCanClaim'         => $canClaimDaily,
            'lastReward'          => $lastReward,
            'nextRewardTime'      => $nextRewardTime,
            'nextRewardCountdown' => $nextRewardRemain,
            'pageTitle'           => 'VIP Prime',
        ]);

        $this->display('page.vip.default.tpl');
    }
}