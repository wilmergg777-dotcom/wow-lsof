<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 */

class ShowIndexPage extends AbstractLoginPage
{
	function __construct() 
	{
		parent::__construct();
		$this->setWindow('light');
	}
	
	function show() 
	{
		global $LNG;
		
		$referralID		= HTTP::_GP('ref', 0);
		if(!empty($referralID))
		{
			$this->redirectTo('index.php?page=register&referralID='.$referralID);
		}
	
		// ═══════════════════════════════════════════════════════════
		// ✅ LECTURA DINÁMICA DE TODOS LOS UNIVERSOS Y SUS ESTADÍSTICAS
		// ═══════════════════════════════════════════════════════════
		$universeSelect	= array();
		$allUniversesStats = array();
		
		$uniClosedText = !empty($LNG['uni_closed']) ? $LNG['uni_closed'] : 'Cerrado';
		
		$dbUni = Database::get();
		
		// Un solo time() para todo el bucle (eficiencia + consistencia)
		$now = time();
		// Throttle: solo actualizamos last_seen_online si pasaron > 30 min
		$throttle = 1800;
		// Fecha fija original del Universo 1 (Andrómeda)
		$uni1StartDate = strtotime('2026-10-01');
		
		// Consultamos la tabla maestra de configuración para sacar TODOS los universos
		$sqlUni = "SELECT uni, uni_name, game_disable FROM uni1_config ORDER BY uni ASC";
		$resultUni = $dbUni->select($sqlUni);
		
		if (!empty($resultUni)) {
			foreach ($resultUni as $row) {
				$uniID    = (int)$row['uni'];
				$uniName  = $row['uni_name'];
				$isOnline = ($row['game_disable'] == 0);
				
				// 1. Agregamos al desplegable del login
				$suffix = ($isOnline) ? '' : ' ' . $uniClosedText;
				$universeSelect[$uniID] = $uniName . $suffix;

				// 2. Estadísticas de usuarios de ESTE universo
				$tableUsers = "uni{$uniID}_users";
				
				$usersOnline = 0;
				$users24h    = 0;
				
				try {
					// Jugadores online ahora (últimos 15 min)
					$queryOnline = $dbUni->selectSingle(
						"SELECT COUNT(*) as count FROM {$tableUsers} WHERE onlinetime >= :time;",
						array(':time' => ($now - 15 * 60))
					);
					$usersOnline = isset($queryOnline['count']) ? (int)$queryOnline['count'] : 0;

					// Jugadores últimas 24h
					$query24h = $dbUni->selectSingle(
						"SELECT COUNT(*) as count FROM {$tableUsers} WHERE onlinetime >= :time;",
						array(':time' => ($now - 24 * 60 * 60))
					);
					$users24h = isset($query24h['count']) ? (int)$query24h['count'] : 0;
				} catch (Exception $e) {
					$usersOnline = 0;
					$users24h    = 0;
				}

				// ═══════════════════════════════════════════════════════════
				// ✅ EDAD DEL UNIVERSO — CÁLCULO EN DB + CONGELACIÓN AUTOMÁTICA
				// ═══════════════════════════════════════════════════════════
				// La edad NO se guarda: se calcula en SQL con una resta.
				// La tabla solo guarda: cuándo nació, cuándo se pausó y cuánto
				// tiempo acumulado lleva pausado.
				// ═══════════════════════════════════════════════════════════
				$universeAge = 1;
				
				try {
					// Fecha de inicio al INSERTAR por primera vez:
					//  - Universo 1 (Andrómeda): 2026-10-01 (fecha original)
					//  - Resto: ahora → Día 1
					$startDateForInsert = ($uniID == 1) ? $uni1StartDate : $now;
					
					// UPSERT atómico.
					// Orden de asignaciones IMPORTANTE (MySQL las evalúa izq→der):
					//  1) total_paused  (usa paused_start ANTIGUO)
					//  2) paused_start  (usa last_seen_online ANTIGUO)
					//  3) last_seen_online (usa su propio valor ANTIGUO en el WHERE)
					$sqlUpsert = "INSERT INTO universe_age_state 
						(uni, start_date, last_seen_online, paused_start, total_paused) 
						VALUES (:uni, :start_date, :last_seen, :paused, 0)
						ON DUPLICATE KEY UPDATE
							total_paused = IF(:is_online_1 = 1 AND paused_start IS NOT NULL, 
							                 total_paused + (:now_1 - paused_start), 
							                 total_paused),
							paused_start = IF(:is_online_2 = 1, 
							                 NULL, 
							                 IF(paused_start IS NULL, COALESCE(last_seen_online, :now_2), paused_start)),
							last_seen_online = IF(:is_online_3 = 1 AND (last_seen_online IS NULL OR last_seen_online < :now_3 - :throttle_3), 
							                     :now_3, 
							                     last_seen_online)";
					
					$dbUni->select($sqlUpsert, array(
						':uni'         => $uniID,
						':start_date'  => $startDateForInsert,
						':last_seen'   => $now,
						':paused'      => $isOnline ? null : $now,
						':is_online_1' => $isOnline ? 1 : 0,
						':is_online_2' => $isOnline ? 1 : 0,
						':is_online_3' => $isOnline ? 1 : 0,
						':now_1'       => $now,
						':now_2'       => $now,
						':now_3'       => $now,
						':throttle_3'  => $throttle,
					));
					
					// Leemos la edad ya calculada desde la propia DB.
					// Si paused_start no es NULL → universo cerrado → usa ese instante.
					// Si paused_start es NULL     → universo online → usa "ahora".
					// El total_paused se resta siempre (tiempo pausado acumulado).
					$ageRow = $dbUni->selectSingle(
						"SELECT 
							FLOOR((COALESCE(paused_start, :now_calc) - start_date - total_paused) / 86400) + 1 AS age
						 FROM universe_age_state 
						 WHERE uni = :uni_sel",
						array(':now_calc' => $now, ':uni_sel' => $uniID)
					);
					
					$universeAge = isset($ageRow['age']) ? (int)$ageRow['age'] : 1;
				} catch (Exception $e) {
					// Fallback: si la tabla universe_age_state no existe todavía,
					// calculamos la edad sin persistencia (comportamiento antiguo).
					$fallbackStart = ($uniID == 1) ? $uni1StartDate : $now;
					$universeAge = (int)floor(($now - $fallbackStart) / 86400) + 1;
				}
				
				if ($universeAge < 1) { $universeAge = 1; }

				// Guardamos los datos en el array general
				$allUniversesStats[] = array(
					'id'          => $uniID,
					'name'        => $uniName,
					'isOnline'    => $isOnline,
					'usersOnline' => $usersOnline,
					'users24h'    => $users24h,
					'age'         => $universeAge
				);
			}
		} else {
			// Respaldo por si la tabla maestra falla
			$universeSelect[1] = 'Andrómeda';
		}
		
		$Code	= HTTP::_GP('code', 0);
		$loginCode	= false;
		if(isset($LNG['login_error_'.$Code]))
		{
			$loginCode	= $LNG['login_error_'.$Code];
		}

        $sql = "SELECT date, title, text, user FROM %%NEWS%% ORDER BY id DESC LIMIT 1;";
        $newsResult = Database::get()->select($sql);

        $newsList	= array();

        foreach ($newsResult as $newsRow)
        {
            $newsList[]	= array(
                'title' => $newsRow['title'],
                'from' 	=> sprintf($LNG['news_from'], _date($LNG['php_tdformat'], $newsRow['date']), $newsRow['user']),
                'text' 	=> makebr($newsRow['text']),
            );
        }

        // ═══════════════════════════════════════════════════════════
        // ✅ DATOS PARA EL UNIVERSO ACTUAL (Mantenemos esto por compatibilidad)
        // ═══════════════════════════════════════════════════════════
        $config = Config::get();
        $isOnlineCurrent = ($config->game_disable == 0);

        $onlineQueryCurrent = $dbUni->selectSingle(
            "SELECT COUNT(*) as count FROM %%USERS%% WHERE onlinetime >= :time;",
            array(':time' => ($now - 15 * 60))
        );
        $usersOnlineCurrent = isset($onlineQueryCurrent['count']) ? (int)$onlineQueryCurrent['count'] : 0;

        $query24hCurrent = $dbUni->selectSingle(
            "SELECT COUNT(*) as count FROM %%USERS%% WHERE onlinetime >= :time;",
            array(':time' => ($now - 24 * 60 * 60))
        );
        $users24hCurrent = isset($query24hCurrent['count']) ? (int)$query24hCurrent['count'] : 0;

        $universeNameCurrent = $config->uni_name;

        // Reutilizamos la edad ya calculada del universo actual (buscando por nombre)
        $universeAgeCurrent = 1;
        foreach ($allUniversesStats as $stats) {
            if ($stats['name'] === $universeNameCurrent) {
                $universeAgeCurrent = $stats['age'];
                break;
            }
        }

        // Enviamos TODO a la plantilla
        $this->assign(array(
            // 🟢 NUEVO ARRAY CON LAS ESTADÍSTICAS DE TODOS LOS UNIVERSOS
            'allUniversesStats' => $allUniversesStats,

            // Stats del universo actual
            'newsList'			=> $newsList,
            'isOnline'			=> $isOnlineCurrent,
            'usersOnline'		=> $usersOnlineCurrent,
            'users24h'			=> $users24hCurrent,
            'universeName'		=> $universeNameCurrent,
            'universeAge'		=> $universeAgeCurrent,

            // ✅ FIX v5.6 — PHP 8.2: definir 'page' para evitar
            // "Undefined array key 'page'" en el template index.default.tpl
            'page'				=> 'index',
            
            // Login / template base
            'universeSelect'	=> $universeSelect,
            'code'				=> $loginCode,
            'descHeader'		=> sprintf($LNG['loginWelcome'], $config->game_name),
            'descText'			=> sprintf($LNG['loginServerDesc'], $config->game_name),
            'gameInformations'	=> explode("\n", !empty($LNG['gameInformations']) ? $LNG['gameInformations'] : ''),
            'loginInfo'			=> sprintf($LNG['loginInfo'], '<a href="index.php?page=rules">'.$LNG['menu_rules'].'</a>')
        ));
		
		$this->display('page.index.default.tpl');
	}
}