<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */

class ShowStatisticsPage extends AbstractGamePage
{
    public static $requireModule = MODULE_STATISTICS;

	function __construct() 
	{
		parent::__construct();
	}

    function show()
    {
        global $USER, $LNG;

        // Cargar puntos del usuario actual
        $db = Database::get();
        $sqlPoints = 'SELECT total_points FROM %%STATPOINTS%% WHERE id_owner = :userId AND stat_type = :statType';
        $statPoints = $db->selectSingle($sqlPoints, array(
            ':userId'   => $USER['id'],
            ':statType' => 1
        ));
        
        if (is_array($statPoints)) {
            $USER += $statPoints;
        } else {
            $USER['total_points'] = 0;
        }

        $who   	= HTTP::_GP('who', 1);
        $type  	= HTTP::_GP('type', 1);
        $range 	= HTTP::_GP('range', 1);

        switch ($type)
        {
            case 2:
                $Order   = "fleet_rank";
                $Points  = "fleet_points";
                $Rank    = "fleet_rank";
                $OldRank = "fleet_old_rank";
            break;
            case 3:
                $Order   = "tech_rank";
                $Points  = "tech_points";
                $Rank    = "tech_rank";
                $OldRank = "tech_old_rank";
            break;
            case 4:
                $Order   = "build_rank";
                $Points  = "build_points";
                $Rank    = "build_rank";
                $OldRank = "build_old_rank";
            break;
            case 5:
                $Order   = "defs_rank";
                $Points  = "defs_points";
                $Rank    = "defs_rank";
                $OldRank = "defs_old_rank";
            break;
            default:
                $Order   = "total_rank";
                $Points  = "total_points";
                $Rank    = "total_rank";
                $OldRank = "total_old_rank";
            break;
        }

        $RangeList  = array();
		$config	= Config::get();

        switch($who)
        {
            case 1:
                if ($config->stat == 2) {
                    $sqlCount = "SELECT COUNT(*) as state FROM %%STATPOINTS%% as s
                                 INNER JOIN %%USERS%% as u ON u.id = s.id_owner
                                 WHERE s.universe = :universe AND s.stat_type = 1 
                                   AND u.authlevel < :authLevel
                                   AND u.email NOT LIKE '%@noreply.local';";
                    $MaxUsers = (int) $db->selectSingle($sqlCount, array(
                        ':universe'  => Universe::current(),
                        ':authLevel' => $config->stat_level,
                    ), 'state');
                } else {
                    $sqlCount = "SELECT COUNT(*) as state FROM %%STATPOINTS%% as s
                                 INNER JOIN %%USERS%% as u ON u.id = s.id_owner
                                 WHERE s.universe = :universe AND s.stat_type = 1
                                   AND u.email NOT LIKE '%@noreply.local';";
                    $MaxUsers = (int) $db->selectSingle($sqlCount, array(
                        ':universe' => Universe::current(),
                    ), 'state');
                }

                if ($MaxUsers <= 0) {
                    $MaxUsers = 1;
                }

                $range		= min($range, $MaxUsers);
                $LastPage 	= max(1, ceil($MaxUsers / 100));

                for ($Page = 0; $Page < $LastPage; $Page++)
                {
                    $PageValue      				= ($Page * 100) + 1;
                    $PageRange      				= $PageValue + 99;
                    $Selector['range'][$PageValue] 	= $PageValue."-".$PageRange;
                }

                $start = max(floor(($range - 1) / 100) * 100, 0);

				if ($config->stat == 2) {
					$sql = "SELECT DISTINCT s.*, u.id, u.username, u.ally_id, a.ally_name FROM %%STATPOINTS%% as s
					INNER JOIN %%USERS%% as u ON u.id = s.id_owner
					LEFT JOIN %%ALLIANCE%% as a ON a.id = s.id_ally
					WHERE s.universe = :universe AND s.stat_type = 1 AND u.authlevel < :authLevel
					  AND u.email NOT LIKE '%@noreply.local'
					ORDER BY ".$Order." ASC LIMIT :offset, :limit;";
					$query = $db->select($sql, array(
						':universe'	=> Universe::current(),
						':authLevel'=> $config->stat_level,
						':offset'	=> $start,
						':limit'	=> 100,
					));
				} else {
					$sql = "SELECT DISTINCT s.*, u.id, u.username, u.ally_id, a.ally_name FROM %%STATPOINTS%% as s
					INNER JOIN %%USERS%% as u ON u.id = s.id_owner
					LEFT JOIN %%ALLIANCE%% as a ON a.id = s.id_ally
					WHERE s.universe = :universe AND s.stat_type = 1
					  AND u.email NOT LIKE '%@noreply.local'
					ORDER BY ".$Order." ASC LIMIT :offset, :limit;";
					$query = $db->select($sql, array(
						':universe'	=> Universe::current(),
						':offset'	=> $start,
						':limit'	=> 100,
					));
				}

				$RangeList	= array();

                foreach ($query as $StatRow)
                {
                    $RangeList[]	= array(
                        'id'		=> $StatRow['id'],
                        'name'		=> $StatRow['username'],
                        'points'	=> pretty_number($StatRow[$Points]),
                        'allyid'	=> $StatRow['ally_id'],
                        'rank'		=> $StatRow[$Rank],
                        'allyname'	=> $StatRow['ally_name'],
                        'ranking'	=> $StatRow[$OldRank] - $StatRow[$Rank],
                        'total_points' => $StatRow['total_points'], 
                    );
                }

                // VIP Check
                if (!empty($RangeList)) {
                    $prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
                    $userIds = array();
                    foreach ($RangeList as $row) {
                        if (!empty($row['id'])) {
                            $userIds[] = (int)$row['id'];
                        }
                    }

                    $vipUserIds = array();
                    if (!empty($userIds)) {
                        try {
                            $placeholders = implode(',', array_fill(0, count($userIds), '?'));
                            $sqlVip = "SELECT `user_id` FROM `".$prefix."users_vip` WHERE `user_id` IN (".$placeholders.") AND `vip_active` = 1 AND `vip_end` > ?";
                            $params = $userIds;
                            $params[] = TIMESTAMP;
                            $vipQuery = $db->select($sqlVip, $params);
                            if (!empty($vipQuery)) {
                                foreach ($vipQuery as $vipRow) {
                                    $vipUserIds[(int)$vipRow['user_id']] = true;
                                }
                            }
                        } catch (Exception $e) {
                            $vipUserIds = array();
                        }
                    }

                    foreach ($RangeList as $key => $row) {
                        $RangeList[$key]['is_vip'] = isset($vipUserIds[(int)$row['id']]);
                    }
                }

                // Relaciones (Diplomacia + Neovatao)
                if (!empty($RangeList)) {
                    $prefix   = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';
                    $myUserId = (int)$USER['id'];
                    $myAllyId = (int)$USER['ally_id'];

                    $buddyIds = array();
                    try {
                        $sqlBuddy = "SELECT `sender`, `owner` FROM `".$prefix."buddy` WHERE `owner` = :uid1 OR `sender` = :uid2";
                        $buddyRows = $db->select($sqlBuddy, array(':uid1' => $myUserId, ':uid2' => $myUserId));
                        if (!empty($buddyRows)) {
                            foreach ($buddyRows as $b) {
                                $other = ((int)$b['owner'] === $myUserId) ? (int)$b['sender'] : (int)$b['owner'];
                                $buddyIds[$other] = true;
                            }
                        }
                    } catch (Exception $e) {}

                    $warAllies = array();
                    $napAllies = array();
                    if ($myAllyId > 0) {
                        try {
                            $sqlDiplo = "SELECT `owner_1`, `owner_2`, `level` FROM `".$prefix."diplo` 
                                         WHERE (`owner_1` = :ally1 OR `owner_2` = :ally2) 
                                           AND `accept` = 1 
                                           AND `universe` = :uni";
                            $diploRows = $db->select($sqlDiplo, array(':ally1' => $myAllyId, ':ally2' => $myAllyId, ':uni' => Universe::current()));
                            if (!empty($diploRows)) {
                                foreach ($diploRows as $d) {
                                    $otherAlly = ((int)$d['owner_1'] === $myAllyId) ? (int)$d['owner_2'] : (int)$d['owner_1'];
                                    if ((int)$d['level'] === 1) $warAllies[$otherAlly] = true;
                                    elseif ((int)$d['level'] === 2) $napAllies[$otherAlly] = true;
                                }
                            }
                        } catch (Exception $e) {}
                    }

                    foreach ($RangeList as $key => $row) {
                        $rowId   = (int)$row['id'];
                        $rowAlly = (int)$row['allyid'];

                        if ($rowId === $myUserId) {
                            $RangeList[$key]['relation'] = 'yo';
                        } elseif ($myAllyId > 0 && $rowAlly === $myAllyId) {
                            // El nombre del jugador se queda blanco/normal
                            $RangeList[$key]['relation'] = 'default';
                        } elseif (isset($buddyIds[$rowId])) {
                            $RangeList[$key]['relation'] = 'amigo';
                        } elseif ($rowAlly > 0 && isset($warAllies[$rowAlly])) {
                            $RangeList[$key]['relation'] = 'guerra';
                        } elseif ($rowAlly > 0 && isset($napAllies[$rowAlly])) {
                            $RangeList[$key]['relation'] = 'nap';
                        } else {
                            // Lógica Neovatao
                            $multi = isset($config->noobprotectionmulti) && $config->noobprotectionmulti > 0 ? $config->noobprotectionmulti : 5;
                            $mis_puntos = isset($USER['total_points']) ? (int)$USER['total_points'] : 0;
                            $sus_puntos = isset($row['total_points']) ? (int)$row['total_points'] : 0;

                            if ($mis_puntos > 0) {
                                if ($sus_puntos > ($mis_puntos * $multi)) {
                                    $RangeList[$key]['relation'] = 'fuerte';
                                } elseif ($sus_puntos < ($mis_puntos / $multi)) {
                                    $RangeList[$key]['relation'] = 'debil';
                                } else {
                                    $RangeList[$key]['relation'] = 'default';
                                }
                            } else {
                                $RangeList[$key]['relation'] = 'default';
                            }
                        }
                    }
                }
            break;
            case 2:
                $sql = "SELECT COUNT(*) as state FROM %%ALLIANCE%% WHERE `ally_universe` = :universe;";
				$MaxAllys = $db->selectSingle($sql, array(':universe' => Universe::current()), 'state');
				if ($MaxAllys <= 0) $MaxAllys = 1;

				$range = min($range, $MaxAllys);
                $LastPage = max(1, ceil($MaxAllys / 100));
				
                for ($Page = 0; $Page < $LastPage; $Page++) {
                    $PageValue = ($Page * 100) + 1;
                    $PageRange = $PageValue + 99;
                    $Selector['range'][$PageValue] = $PageValue."-".$PageRange;
                }

                $start = max(floor(($range - 1) / 100) * 100, 0);

                $sql = 'SELECT DISTINCT s.*, a.id, a.ally_members, a.ally_name FROM %%STATPOINTS%% as s
                INNER JOIN %%ALLIANCE%% as a ON a.id = s.id_owner
                WHERE universe = :universe AND stat_type = 2
                ORDER BY '.$Order.' ASC LIMIT :offset, :limit;';
				$query = $db->select($sql, array(':universe' => Universe::current(), ':offset' => $start, ':limit' => 100));

				foreach ($query as $StatRow) {
                    $RangeList[]	= array(
                        'id'		=> $StatRow['id'],
                        'name'		=> $StatRow['ally_name'],
                        'members'	=> $StatRow['ally_members'],
                        'rank'		=> $StatRow[$Rank],
                        'mppoints'	=> pretty_number(floor($StatRow[$Points] / $StatRow['ally_members'])),
                        'points'	=> pretty_number($StatRow[$Points]),
                        'ranking'	=> $StatRow[$OldRank] - $StatRow[$Rank],
                    );
                }
            break;
        }

        $Selector['who'] 	= array(1 => $LNG['st_player'], 2 => $LNG['st_alliance']);
        $Selector['type']	= array(1 => $LNG['st_points'], 2 => $LNG['st_fleets'], 3 => $LNG['st_researh'], 4 => $LNG['st_buildings'], 5 => $LNG['st_defenses']);

		require_once 'includes/classes/Cronjob.class.php';

        $this->assign(array(
            'Selectors'				=> $Selector,
            'who'					=> $who,
            'type'					=> $type,
            'range'					=> floor(($range - 1) / 100) * 100 + 1,
            'RangeList'				=> $RangeList,
            'CUser_ally'			=> $USER['ally_id'],
            'CUser_id'				=> $USER['id'],
            'stat_date'				=> _date($LNG['php_tdformat'], Cronjob::getLastExecutionTime('statistic'), $USER['timezone']),
        ));

        $this->display('page.statistics.default.tpl');
    }
}