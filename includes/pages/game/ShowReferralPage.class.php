<?php
/**
 * ShowReferralPage — Programa de Referidos
 * AstroIO v6.1 (LIMITADOR DE REFERIDOS + ESTADO DE RECOMPENSAS)
 * Router: ?page=referral
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowReferralPage extends AbstractGamePage
{
    public $defaultController = 'show';
    private $userId;

    public function __construct()
    {
        global $USER;
        parent::__construct();
        require_once ROOT_PATH.'includes/classes/ReferralHelper.class.php';
        $this->userId = (int)$USER['id'];
    }

    public function show()
    {
        global $USER;

        $stats     = ReferralHelper::getStats($this->userId);
        $referrals = ReferralHelper::getReferrals($this->userId);
        $referrer  = ReferralHelper::getMyReferrer($this->userId);
        $code      = ReferralHelper::getReferralCode($this->userId);

        // 1. Formatear lista de referidos
        $refList = array();
        foreach ($referrals as $r) {
            $points = (int)(isset($r['total_points']) ? $r['total_points'] : 0);
            $refList[] = array(
                'id'         => (int)$r['id'],
                'username'   => $r['username'],
                'points'     => number_format($points, 0, ',', '.'),
                'points_raw' => $points,
                'rank'       => (int)(isset($r['total_rank']) ? $r['total_rank'] : 0)
            );
        }

        // 2. Limitar a 5 jugadores y pasar el resto para el botón "Ver más"
        $totalReferralsRaw = count($refList);
        $firstFiveRefs = array_slice($refList, 0, 5);
        $moreRefs = array_slice($refList, 5);
        $hasMoreRefs = ($totalReferralsRaw > 5);

        // 3. Comisiones Recientes
        $commissions = array();
        try {
            $db     = Database::get();
            $prefix = 'uni1_';
            if (defined('DB_PREFIX'))      $prefix = DB_PREFIX;
            elseif (defined('PREFIX'))     $prefix = PREFIX;

            $sql = "SELECT referred_id, amount, created_at
                    FROM `".$prefix."wallet_referral_fund`
                    WHERE user_id = :uid
                    ORDER BY created_at DESC
                    LIMIT 10;";

            $rows = $db->select($sql, array(':uid' => $this->userId));

            if (is_array($rows)) {
                foreach ($rows as $row) {
                    $referredId = (int)$row['referred_id'];
                    $u = null;
                    try {
                        $u = $db->selectSingle("SELECT username FROM %%USERS%% WHERE id = :id LIMIT 1;", array(':id' => $referredId));
                    } catch (Exception $e) { $u = null; }
                    
                    $username = $u ? $u['username'] : ('Usuario #'.$referredId);
                    $amount   = number_format((float)$row['amount'], 0, ',', '.');
                    $fecha    = !empty($row['created_at']) ? date('d/m/Y H:i', (int)$row['created_at']) : '---';

                    $commissions[] = array(
                        'username' => $username,
                        'amount'   => $amount,
                        'fecha'    => $fecha
                    );
                }
            }
        } catch (Exception $e) { $commissions = array(); }

        // 4. Obtener Recompensas Activas y su Estado
        $activeRewards = array();
        $claimed_rewards = array();
        $max_referral_points = 0;

        try {
            $db     = Database::get();
            $prefix = 'uni1_';
            if (defined('DB_PREFIX'))      $prefix = DB_PREFIX;
            elseif (defined('PREFIX'))     $prefix = PREFIX;

            // 4.1 Obtener los IDs de las recompensas que el usuario YA reclamó
            $sqlClaimed = "SELECT DISTINCT reward_id FROM `".$prefix."referral_rewards_history` WHERE inviter_id = :uid";
            $resClaimed = $db->select($sqlClaimed, array(':uid' => $this->userId));
            if (is_array($resClaimed)) {
                foreach ($resClaimed as $row) {
                    $claimed_rewards[] = (int)$row['reward_id'];
                }
            }

            // 4.2 Obtener la máxima puntuación alcanzada por sus referidos
            $sqlMaxPts = "SELECT MAX(sp.total_points) as max_points 
                          FROM `".$prefix."statpoints` sp 
                          INNER JOIN `".$prefix."users` u ON sp.id_owner = u.id 
                          WHERE u.ref_id = :uid AND sp.stat_type = 1";
            $resMaxPts = $db->selectSingle($sqlMaxPts, array(':uid' => $this->userId));
            if ($resMaxPts && isset($resMaxPts['max_points'])) {
                $max_referral_points = (int)$resMaxPts['max_points'];
            }

            // 4.3 Obtener las recompensas activas
            $time = time();
            $sqlRewards = "SELECT * FROM `".$prefix."referral_rewards`
                           WHERE is_active = 1
                           AND (is_permanent = 1 OR (start_time <= :time AND end_time >= :time))
                           ORDER BY points_required ASC";
            
            $rowsRewards = $db->select($sqlRewards, array(':time' => $time));

            if (is_array($rowsRewards) && count($rowsRewards) > 0) {
                foreach ($rowsRewards as $row) {
                    $rewardsList = array();
                    
                    if ($row['reward_metal'] > 0)          $rewardsList[] = array('type' => 'Metal', 'amount' => number_format((float)$row['reward_metal'], 0, ',', '.'));
                    if ($row['reward_crystal'] > 0)        $rewardsList[] = array('type' => 'Cristal', 'amount' => number_format((float)$row['reward_crystal'], 0, ',', '.'));
                    if ($row['reward_deuterium'] > 0)      $rewardsList[] = array('type' => 'Deuterio', 'amount' => number_format((float)$row['reward_deuterium'], 0, ',', '.'));
                    if ($row['reward_ntx20'] > 0)          $rewardsList[] = array('type' => 'NTX-20', 'amount' => number_format((int)$row['reward_ntx20'], 0, ',', '.'));
                    if ($row['reward_darkmatter'] > 0)     $rewardsList[] = array('type' => 'Materia Oscura', 'amount' => number_format((float)$row['reward_darkmatter'], 0, ',', '.'));
                    if ($row['reward_cont_generic'] > 0)   $rewardsList[] = array('type' => 'Contenedor', 'amount' => number_format((int)$row['reward_cont_generic'], 0, ',', '.'));
                    if ($row['reward_box_common'] > 0)     $rewardsList[] = array('type' => 'Cofre Común', 'amount' => number_format((int)$row['reward_box_common'], 0, ',', '.'));
                    if ($row['reward_box_rare'] > 0)       $rewardsList[] = array('type' => 'Cofre Raro', 'amount' => number_format((int)$row['reward_box_rare'], 0, ',', '.'));
                    if ($row['reward_box_legendary'] > 0)  $rewardsList[] = array('type' => 'Cofre Legendario', 'amount' => number_format((int)$row['reward_box_legendary'], 0, ',', '.'));

                    // 4.4 Calcular estado de la recompensa
                    $status = 'in_progress';
                    $missing_pts = $row['points_required'] - $max_referral_points;
                    
                    if (in_array((int)$row['id'], $claimed_rewards)) {
                        $status = 'claimed'; // Ya lo reclamó antes
                    } elseif ($max_referral_points >= $row['points_required']) {
                        $status = 'ready'; // Tiene los puntos, pero el cron no ha pagado
                    }

                    $activeRewards[] = array(
                        'id'              => $row['id'],
                        'points_required' => number_format((int)$row['points_required'], 0, ',', '.'),
                        'points_raw'      => (int)$row['points_required'],
                        'is_permanent'    => (int)$row['is_permanent'],
                        'start_date'      => $row['start_time'] > 0 ? date('d/m/Y H:i', $row['start_time']) : '',
                        'end_date'        => $row['end_time'] > 0 ? date('d/m/Y H:i', $row['end_time']) : '',
                        'rewards'         => $rewardsList,
                        'status'          => $status,
                        'missing_pts'     => $missing_pts > 0 ? number_format($missing_pts, 0, ',', '.') : '0'
                    );
                }
            }
        } catch (Exception $e) { $activeRewards = array(); }

        // 5. Enviar al template
        $this->assign(array(
            'ref_code'         => $code,
            'total_referrals'  => number_format((int)$stats['total_referrals'], 0, ',', '.'),
            'paid_referrals'   => number_format((int)$stats['paid_referrals'], 0, ',', '.'),
            'total_earned'     => number_format((float)$stats['total_earned'], 0, ',', '.'),
            'referrals'        => $firstFiveRefs, // Solo los primeros 5
            'more_referrals'   => $moreRefs,      // El resto para el botón
            'has_more_refs'    => $hasMoreRefs,   // Bandera para mostrar el botón
            'commissions'      => $commissions,
            'active_rewards'   => $activeRewards,
            'has_referrer'     => ($referrer !== null),
            'referrer_name'    => $referrer ? $referrer['username'] : '',
            'username'         => $USER['username']
        ));

        $this->display('page.referral.default.tpl');
    }
}