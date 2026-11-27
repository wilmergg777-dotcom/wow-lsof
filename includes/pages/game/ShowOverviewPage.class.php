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
 *
 * ✅ AstroIO v5.0 (Carga segura + Admin ONLINE verde + Cron Asteroides GLOBAL)
 * ✅ AstroIO v5.1 (Torneo del Devorador)
 * ✅ AstroIO v5.2 (AUTO-PROGRAMACIÓN)
 * ✅ AstroIO v5.3 (BASTIÓN ASEDIADO)
 * ✅ AstroIO v5.4 (FIX FANTASMAS PvE/PvP — por email)
 * ✅ AstroIO v5.5 (REFERIDOS UNIFICADOS — SOLO CÓDIGO)
 * ✅ AstroIO v5.6 (CONTADOR JUGADORES + ADMINS)
 * ✅ AstroIO v5.7 (WIDGET BOOST FIN DE SEMANA)
 * ✅ AstroIO v5.8 (CRON AUDITORÍA NTX-20)
 * ✅ AstroIO v5.9 (COLAS SEPARADAS - NAVES Y DEFENSAS)
 * ✅ AstroIO v6.0 (CRON INTERNO AUTOMÁTICO — Solución 2)
 * ✅ AstroIO v6.1 (PATH DINÁMICO del cron interno)
 * ✅ AstroIO v6.2 (BANCO v6.0 — sin AMM)
 * ✅ AstroIO v6.3 (MERCADO v2.6 — Anti-exploit "almacén seguro")
 * ✅ AstroIO v6.4 (FIX OVERVIEW RADAR FLOTAS)
 * ✅ AstroIO v6.5 (SISTEMA DE CLIMA):
 *   - Se carga ClimaEngine.
 *   - Se obtiene el clima actual y la predicción del planeta y de la luna.
 *   - Se pasan al template.
 * ✅ AstroIO v6.6 (BUFF CLIMÁTICO):
 *   - Se obtiene el buff climático activo del jugador.
 *   - Se pasan los datos del buff al template.
 */

// ============================================
// ASTROIO - Cargador seguro de helpers
// ============================================
function astroio_load_helper($className, $fileName) {
    if (class_exists($className)) {
        return true;
    }
    $filePath = __DIR__ . '/../../classes/' . $fileName;
    if (file_exists($filePath)) {
        require_once $filePath;
        return true;
    }
    return false;
}

// Cargar todos los helpers de forma segura
astroio_load_helper('EventHelper', 'EventHelper.class.php');
astroio_load_helper('VIPHelper', 'VIPHelper.class.php');
astroio_load_helper('MarketHelper', 'MarketHelper.class.php');
astroio_load_helper('WalletHelper', 'WalletHelper.class.php');
astroio_load_helper('WalletFundHelper', 'WalletFundHelper.class.php');
astroio_load_helper('AdminBankHelper', 'AdminBankHelper.class.php');
astroio_load_helper('RaffleHelper', 'RaffleHelper.class.php');
astroio_load_helper('LotteryHelper', 'LotteryHelper.class.php');
astroio_load_helper('WarProcessor', 'WarProcessor.class.php');
astroio_load_helper('PVEHelper', 'PVEHelper.class.php');
astroio_load_helper('PVECrisisHelper', 'PVECrisisHelper.class.php');
astroio_load_helper('PVEEmpireHelper', 'PVEEmpireHelper.class.php');
astroio_load_helper('PVEBossTournamentHelper', 'PVEBossTournamentHelper.class.php');
astroio_load_helper('PVEBastionHelper', 'PVEBastionHelper.class.php');
astroio_load_helper('PVEBastionWaveHelper', 'PVEBastionWaveHelper.class.php');
astroio_load_helper('PVPHelper', 'PVPHelper.class.php');
astroio_load_helper('PVPArenaHelper', 'PVPArenaHelper.class.php');
astroio_load_helper('PVPTournamentHelper', 'PVPTournamentHelper.class.php');
astroio_load_helper('PVPProcessor', 'PVPProcessor.class.php');
astroio_load_helper('AsteroidHelper', 'AsteroidHelper.class.php');
astroio_load_helper('WeekendBoostHelper', 'WeekendBoostHelper.class.php');
astroio_load_helper('NTX20LogHelper', 'NTX20LogHelper.class.php');
astroio_load_helper('ClimaEngine', 'ClimaEngine.class.php'); // ASTROIO v6.5

class ShowOverviewPage extends AbstractGamePage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
	}
	
	private function GetTeamspeakData()
	{
		global $USER, $LNG;

		$config = Config::get();

		if ($config->ts_modon == 0)
		{
			return false;
		}
		
		Cache::get()->add('teamspeak', 'TeamspeakBuildCache');
		$tsInfo	= Cache::get()->getData('teamspeak', false);
		
		if(empty($tsInfo))
		{
			return array(
				'error'	=> $LNG['ov_teamspeak_not_online']
			);
		}

		$url = '';

		switch($config->ts_version)
		{
			case 2:
				$url = 'teamspeak://%s:%s?nickname=%s';
			break;
			case 3:
				$url = 'ts3server://%s?port=%d&amp;nickname=%s&amp;password=%s';
			break;
		}
		
		return array(
			'url'		=> sprintf($url, $config->ts_server, $config->ts_tcpport, $USER['username'], $tsInfo['password']),
			'current'	=> $tsInfo['current'],
			'max'		=> $tsInfo['maxuser'],
			'error'		=> false,
		);
	}

	private function GetFleets() {
		global $USER, $LNG;
		$db = Database::get();
		
		$sql = "SELECT * FROM %%FLEETS%% 
		        WHERE (
		            (fleet_owner = :userID AND fleet_mission <> 10)
		            OR (fleet_target_owner = :userID AND fleet_mission IN (1, 2, 20, 21, 22, 23) AND fleet_mess = 0)
		        )
		        ORDER BY fleet_end_time ASC;";
		$fleetResult = $db->select($sql, array(
		    ':userID'   => $USER['id']
		));

		$FlyingFleetList = array();
		
		foreach ($fleetResult as $fleetsRow)
		{
			$FleetList = FleetFunctions::unserialize($fleetsRow['fleet_array']);
			
			if($fleetsRow['fleet_mission'] == 4 && $fleetsRow['fleet_mess'] == FLEET_OUTWARD)
			{
				$returnTime	= $fleetsRow['fleet_start_time'];
			}
			else
			{
				$returnTime	= $fleetsRow['fleet_end_time'];
			}

			$isIncoming = ((int) $fleetsRow['fleet_owner'] === 0)
			           && ((int) $fleetsRow['fleet_target_owner'] === (int) $USER['id'])
			           && in_array((int) $fleetsRow['fleet_mission'], array(1, 2, 20, 21, 22, 23));

			$missionLabel = isset($LNG['type_mission_'.$fleetsRow['fleet_mission']])
				? $LNG['type_mission_'.$fleetsRow['fleet_mission']]
				: '';
			if ($missionLabel === '') {
				switch ((int) $fleetsRow['fleet_mission']) {
					case 1:  $missionLabel = 'Ataque'; break;
					case 2:  $missionLabel = 'Ataque Grupal'; break;
					case 20: $missionLabel = 'Ataque Pirata'; break;
					case 21: $missionLabel = 'Ataque a Imperio'; break;
					case 22: $missionLabel = 'Contraataque'; break;
					case 23: $missionLabel = 'Ataque al Devorador'; break;
					case 32: $missionLabel = 'Reciclaje de Asteroide'; break;
					default: $missionLabel = 'Misión #'.$fleetsRow['fleet_mission']; break;
				}
			}
			
			$FlyingFleetList[] = array(
				'id'            => $fleetsRow['fleet_id'],
				'mission'       => $fleetsRow['fleet_mission'],
				'mission_label' => $missionLabel,
				'state'         => $fleetsRow['fleet_mess'],
				'startGalaxy'   => $fleetsRow['fleet_start_galaxy'],
				'startSystem'   => $fleetsRow['fleet_start_system'],
				'startPlanet'   => $fleetsRow['fleet_start_planet'],
				'startTime'     => _date($LNG['php_tdformat'], $fleetsRow['fleet_start_time'], $USER['timezone']),
				'endGalaxy'     => $fleetsRow['fleet_end_galaxy'],
				'endSystem'     => $fleetsRow['fleet_end_system'],
				'endPlanet'     => $fleetsRow['fleet_end_planet'],
				'endTime'       => _date($LNG['php_tdformat'], $fleetsRow['fleet_end_time'], $USER['timezone']),
				'amount'        => pretty_number($fleetsRow['fleet_amount']),
				'returntime'    => $returnTime,
				'resttime'      => $returnTime - TIMESTAMP,
				'FleetList'     => $FleetList,
				'is_incoming'   => $isIncoming ? 1 : 0,
				
				'ships_array'               => $FleetList,
				'fleet_resource_metal'      => $fleetsRow['fleet_resource_metal'],
				'fleet_resource_crystal'    => $fleetsRow['fleet_resource_crystal'],
				'fleet_resource_deuterium'  => $fleetsRow['fleet_resource_deuterium'],
				'fleet_resource_darkmatter' => $fleetsRow['fleet_resource_darkmatter'],
				
				'start_type'    => $fleetsRow['fleet_start_type'],
				'end_type'      => $fleetsRow['fleet_end_type'],
			);
		}
		
		return $FlyingFleetList;
	}
	
	function savePlanetAction()
	{
		global $USER, $PLANET, $LNG;
		$password =	HTTP::_GP('password', '', true);
		if (!empty($password))
		{
			$db = Database::get();
            $sql = "SELECT COUNT(*) as state FROM %%FLEETS%% WHERE
                      (fleet_owner = :userID AND (fleet_start_id = :planetID OR fleet_start_id = :lunaID)) OR
                      (fleet_target_owner = :userID AND (fleet_end_id = :planetID OR fleet_end_id = :lunaID));";
            $IfFleets = $db->selectSingle($sql, array(
                ':userID'   => $USER['id'],
                ':planetID' => $PLANET['id'],
                ':lunaID'   => $PLANET['id_luna']
            ), 'state');

            if ($IfFleets > 0)
				exit(json_encode(array('message' => $LNG['ov_abandon_planet_not_possible'])));
			elseif ($USER['id_planet'] == $PLANET['id'])
				exit(json_encode(array('message' => $LNG['ov_principal_planet_cant_abanone'])));
			elseif (PlayerUtil::cryptPassword($password) != $USER['password'])
				exit(json_encode(array('message' => $LNG['ov_wrong_pass'])));
			else
			{
				if($PLANET['planet_type'] == 1) {
					$sql = "UPDATE %%PLANETS%% SET destruyed = :time WHERE id = :planetID;";
                    $db->update($sql, array(
                        ':time'   => TIMESTAMP + 86400,
                        ':planetID' => $PLANET['id'],
                    ));
                    $sql = "DELETE FROM %%PLANETS%% WHERE id = :lunaID;";
                    $db->delete($sql, array(
                        ':lunaID' => $PLANET['id_luna']
                    ));
                } else {
                    $sql = "UPDATE %%PLANETS%% SET id_luna = 0 WHERE id_luna = :planetID;";
                    $db->update($sql, array(
                        ':planetID' => $PLANET['id'],
                    ));
                    $sql = "DELETE FROM %%PLANETS%% WHERE id = :planetID;";
                    $db->delete($sql, array(
                        ':planetID' => $PLANET['id'],
                    ));
                }
				
				$PLANET['id']	= $USER['id_planet'];
				exit(json_encode(array('ok' => true, 'message' => $LNG['ov_planet_abandoned'])));
			}
		}
	}
		
	function show()
	{
		// ✅ AstroIO v6.3 — Añadido $resource (necesario para el hook de auto-cancelación del mercado)
		global $LNG, $PLANET, $USER, $resource;
		
		// ═══════════════════════════════════════════════════════════
		// 🆕 ASTROIO v6.0 — CRON INTERNO AUTOMÁTICO (Solución 2)
		// -----------------------------------------------------------
		// Dispara una petición HTTP asíncrona al cron.php con la clave
		// "internal" para que el cronjob se ejecute cada ~55s sin
		// depender de cron-job.org ni del crontab SSH.
		//
		// CARACTERÍSTICAS:
		//   - No bloqueante: la página carga sin esperar la respuesta.
		//   - Detecta HTTP/HTTPS automáticamente vía PROTOCOL.
		//   - Detecta el puerto automáticamente (80 o 443).
		//   - Lock propio (cache/.internal_cron_lock) de 55s para no
		//     spamear. Se coordina con el cron externo vía el doble
		//     candado de cron.php (flock + timestamp).
		//   - Try/catch(Throwable): si falla, la página sigue cargando.
		//   - v6.1: path dinámico calculado con HTTP_PATH (funciona en
		//     producción Y en local sin cambios).
		// ═══════════════════════════════════════════════════════════
		try {
			$internalCronLockFile = ROOT_PATH . 'cache/.internal_cron_lock';
			$internalCronInterval = 55; // segundos entre disparos

			$needRunInternalCron = true;

			if (file_exists($internalCronLockFile)) {
				$lastRun = (int) @file_get_contents($internalCronLockFile);
				if (TIMESTAMP - $lastRun < $internalCronInterval) {
					$needRunInternalCron = false;
				}
			}

			if ($needRunInternalCron) {
				// Marcar ANTES de disparar (evita concurrencia si 2 jugadores
				// cargan el overview a la vez)
				@file_put_contents($internalCronLockFile, TIMESTAMP);

				// ─── Detección automática de protocolo y puerto ───
				// PROTOCOL está definida en constants.php como:
				//   HTTPS ? 'https://' : 'http://'
				// Así que funciona igual en HTTPS y HTTP sin cambios.
				$protocol = defined('PROTOCOL') ? PROTOCOL : 'http://';
				$isHttps  = (strpos($protocol, 'https') === 0);
				$port     = $isHttps ? 443 : 80;
				$scheme   = $isHttps ? 'ssl://' : '';

				// Host (sin puerto, sin protocolo)
				$host = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : 'localhost';
				$host = preg_replace('/:\d+$/', '', $host); // quitar ":puerto" si lo trae

				// ─── v6.1: PATH DINÁMICO ───
				// HTTP_PATH está definida en constants.php y apunta a la
				// ruta base del juego:
				//   Producción: https://astroio.duckdns.org/       → / 
				//   Local:      http://localhost/2Moons/           → /2Moons/
				// Con esto el fsockopen acierta en raíz Y en subcarpeta.
				$basePath = defined('HTTP_PATH') ? parse_url(HTTP_PATH, PHP_URL_PATH) : '/';
				$basePath = rtrim($basePath, '/') . '/';
				$cronPath = $basePath . 'cron.php?key=internal&t=' . TIMESTAMP;

				// ─── Disparo asíncrono (no bloqueante) ───
				$fp = @fsockopen($scheme . $host, $port, $errno, $errstr, 2);

				if ($fp) {
					// Cabeceras HTTP
					$out  = "GET {$cronPath} HTTP/1.1\r\n";
					$out .= "Host: {$host}\r\n";
					$out .= "User-Agent: AstroIO-InternalCron/1.0\r\n";
					$out .= "Connection: Close\r\n\r\n";

					@fwrite($fp, $out);

					// No esperar respuesta (modo no bloqueante)
					@stream_set_blocking($fp, 0);
					@fclose($fp);
				}
			}
		} catch (Throwable $e) {
			// Silencioso: si falla el cron interno, la página sigue cargando
			@file_put_contents(
				ROOT_PATH . 'cache/cron_internal_error.log',
				'[' . date('Y-m-d H:i:s') . '] ' . $e->getMessage()
				. ' en ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL,
				FILE_APPEND
			);
		}
		// ═══════════════════════════════════════════════════════════
		// FIN CRON INTERNO
		// ═══════════════════════════════════════════════════════════
		
		// ============================================
		// ASTROIO - HOOK VIP: Recompensa diaria automática
		// ============================================
		if (class_exists('VIPHelper') && !empty($USER['id'])) {
			$vipUserId = (int)$USER['id'];
			if (VIPHelper::isVIP($vipUserId)) {
				VIPHelper::claimDailyReward($vipUserId);
			}
		}
		
		// ============================================
		// ASTROIO - HOOK MERCADO: Expiración de ofertas
		// ============================================
		if (class_exists('MarketHelper') && !empty($USER['id'])) {
			$cacheKey = 'market_expire_last';
			$now      = TIMESTAMP;
			$last     = isset($_SESSION[$cacheKey]) ? (int)$_SESSION[$cacheKey] : 0;

			if (($now - $last) > 300) {
				MarketHelper::expireOffers();
				$_SESSION[$cacheKey] = $now;
			}
		}
		
		// ============================================
		// 🆕 ASTROIO v6.3 - HOOK MERCADO: Auto-cancelación de ofertas inválidas
		// ------------------------------------------------------------
		// Recorre las ofertas activas con planet_id > 0 (creadas con
		// la v2.6 del MarketHelper, donde los items NO se quitaban
		// del planeta) y cancela automáticamente las que ya no pueden
		// completarse:
		//   · SELL: el vendedor ya no tiene los items en su planeta
		//           (probablemente fue atacado y los perdió)
		//   · BUY:  el comprador ya no tiene el NTX-20
		//           (probablemente lo gastó en otra cosa)
		//
		// Las ofertas LEGACY (planet_id = 0), creadas con la v2.5 y
		// anteriores, NO se tocan: sus items estaban "en limbo" y se
		// resuelven solos al comprarse, cancelarse o expirar.
		//
		// Se ejecuta cada 5 minutos, o al forzar con ?force_market_autocancel=1
		// ============================================
		if (class_exists('MarketHelper') && !empty($USER['id'])) {
			$cacheKeyMktAuto = 'market_autocancel_last';
			$nowMktAuto      = TIMESTAMP;
			$lastMktAuto     = isset($_SESSION[$cacheKeyMktAuto]) ? (int)$_SESSION[$cacheKeyMktAuto] : 0;
			$forceMktAuto    = isset($_GET['force_market_autocancel']) && (int)$_GET['force_market_autocancel'] === 1;

			if ($forceMktAuto || ($nowMktAuto - $lastMktAuto) > 300) {
				try {
					$mktDb     = Database::get();
					$mktPrefix = defined('DB_PREFIX') ? DB_PREFIX : (defined('PREFIX') ? PREFIX : 'uni1_');
					
					// ─────── SELL ORDERS (vendedor puede haber perdido items) ───────
					$sellOrders = $mktDb->select(
						"SELECT offer_id, seller_id, planet_id, item_type, item_id, amount
						 FROM `".$mktPrefix."market_offers`
						 WHERE status = 'active'
						   AND offer_type = 'sell'
						   AND admin_offer = 0
						   AND planet_id > 0
						 LIMIT 100"
					);
					
					if (is_array($sellOrders)) {
						foreach ($sellOrders as $so) {
							$soOfferId   = (int)$so['offer_id'];
							$soSellerId  = (int)$so['seller_id'];
							$soPlanetId  = (int)$so['planet_id'];
							$soItemType  = $so['item_type'];
							$soItemId    = (int)$so['item_id'];
							$soAmount    = (int)$so['amount'];
							
							if ($soAmount <= 0 || $soPlanetId <= 0) continue;
							
							$hasItems = false;
							
							// Recursos metal/crystal/deuterium
							if (in_array($soItemType, array('metal','crystal','deuterium'), true)) {
								$row = $mktDb->selectSingle(
									"SELECT `".$soItemType."` AS qty 
									 FROM `".$mktPrefix."planets`
									 WHERE id = :pid AND id_owner = :uid",
									array(':pid' => $soPlanetId, ':uid' => $soSellerId)
								);
								$hasItems = ($row && (float)$row['qty'] >= $soAmount);
							}
							// MO (global)
							elseif ($soItemType === 'dark_matter') {
								$row = $mktDb->selectSingle(
									"SELECT darkmatter AS qty FROM `".$mktPrefix."users` WHERE id = :uid",
									array(':uid' => $soSellerId)
								);
								$hasItems = ($row && (float)$row['qty'] >= $soAmount);
							}
							// Naves/defensas (columna dinámica vía $resource)
							elseif ($soItemType === 'ship' || $soItemType === 'defense') {
								$col = (is_array($resource) && isset($resource[$soItemId])) ? $resource[$soItemId] : null;
								if ($col) {
									$row = $mktDb->selectSingle(
										"SELECT `".$col."` AS qty 
										 FROM `".$mktPrefix."planets`
										 WHERE id = :pid AND id_owner = :uid",
										array(':pid' => $soPlanetId, ':uid' => $soSellerId)
									);
									$hasItems = ($row && (int)$row['qty'] >= $soAmount);
								} else {
									// No se pudo mapear el item — no tocar (por seguridad)
									continue;
								}
							}
							// Cofres
							elseif ($soItemType === 'box') {
								$boxKey = ($soItemId === 1) ? 'box_common' : (($soItemId === 2) ? 'box_rare' : (($soItemId === 3) ? 'box_legendary' : null));
								if ($boxKey) {
									$row = $mktDb->selectSingle(
										"SELECT `".$boxKey."` AS qty 
										 FROM `".$mktPrefix."users_market`
										 WHERE user_id = :uid",
										array(':uid' => $soSellerId)
									);
									$hasItems = ($row && (int)$row['qty'] >= $soAmount);
								}
							}
							// Mejoras
							elseif ($soItemType === 'improvement') {
								$row = $mktDb->selectSingle(
									"SELECT quantity AS qty 
									 FROM `".$mktPrefix."users_improvements_inv`
									 WHERE user_id = :uid AND item_id = :iid",
									array(':uid' => $soSellerId, ':iid' => $soItemId)
								);
								$hasItems = ($row && (int)$row['qty'] >= $soAmount);
							}
							else {
								// Tipo desconocido: no tocar (por seguridad)
								continue;
							}
							
							if (!$hasItems) {
								$mktDb->update(
									"UPDATE `".$mktPrefix."market_offers`
									 SET status = 'cancelled', cancel_reason = 'seller_no_resources'
									 WHERE offer_id = :oid AND status = 'active'",
									array(':oid' => $soOfferId)
								);
							}
						}
					}
					
					// ─────── BUY ORDERS (buyer puede haber gastado el NTX) ───────
					$buyOrders = $mktDb->select(
						"SELECT offer_id, seller_id, price_ntx
						 FROM `".$mktPrefix."market_offers`
						 WHERE status = 'active'
						   AND offer_type = 'buy'
						   AND admin_offer = 0
						   AND planet_id > 0
						 LIMIT 100"
					);
					
					if (is_array($buyOrders)) {
						foreach ($buyOrders as $bo) {
							$boOfferId  = (int)$bo['offer_id'];
							$boBuyerId  = (int)$bo['seller_id']; // 'seller_id' = buyer en buy orders
							$boPrice    = (int)$bo['price_ntx'];
							
							if ($boPrice <= 0) continue;
							
							$row = $mktDb->selectSingle(
								"SELECT ntx20 AS qty FROM `".$mktPrefix."users` WHERE id = :uid",
								array(':uid' => $boBuyerId)
							);
							
							if (!$row || (int)$row['qty'] < $boPrice) {
								$mktDb->update(
									"UPDATE `".$mktPrefix."market_offers`
									 SET status = 'cancelled', cancel_reason = 'buyer_no_ntx'
									 WHERE offer_id = :oid AND status = 'active'",
									array(':oid' => $boOfferId)
								);
							}
						}
					}
					
					$_SESSION[$cacheKeyMktAuto] = $nowMktAuto;
				} catch (Exception $eMktAuto) {
					error_log('[MARKET AUTOCANCEL] ' . $eMktAuto->getMessage() . ' @ ' . $eMktAuto->getFile() . ':' . $eMktAuto->getLine());
				}
			}
		}
		
		// ============================================
		// ASTROIO - HOOK WALLET: Timeouts de inversiones (48h) + retiros (72h)
		// ------------------------------------------------------------
		// v6.0: processTimeouts() ahora procesa:
		//   - Inversiones: 48h (pendiente_sin_asignar, pendiente_asignada, datos_enviados)
		//   - Retiros: 72h (pendiente, aceptada)
		// ============================================
		if (class_exists('WalletHelper') && !empty($USER['id'])) {
			$cacheKeyWallet = 'wallet_timeout_last';
			$nowWallet      = TIMESTAMP;
			$lastWallet     = isset($_SESSION[$cacheKeyWallet]) ? (int)$_SESSION[$cacheKeyWallet] : 0;

			if (($nowWallet - $lastWallet) > 300) {
				if (method_exists('WalletHelper', 'processTimeouts')) {
					try {
						WalletHelper::processTimeouts();
						$_SESSION[$cacheKeyWallet] = $nowWallet;
					} catch (Exception $e) {}
				}
			}
		}
		
		// ============================================
		// 🆕 ASTROIO v5.0 - HOOK ADMIN BANK: Timeouts de transferencias CUP (24h)
		// ============================================
		if (class_exists('AdminBankHelper') && !empty($USER['id'])) {
			$cacheKeyCup = 'admin_bank_timeout_last';
			$nowCup      = TIMESTAMP;
			$lastCup     = isset($_SESSION[$cacheKeyCup]) ? (int)$_SESSION[$cacheKeyCup] : 0;

			if (($nowCup - $lastCup) > 300) {
				if (method_exists('AdminBankHelper', 'processTimeouts')) {
					try {
						AdminBankHelper::processTimeouts();
						$_SESSION[$cacheKeyCup] = $nowCup;
					} catch (Exception $e) {}
				}
			}
		}
		
		// ============================================
		// 🆕 ASTROIO v6.2 - HOOK GRÁFICO BANCO: Snapshot cada 1 hora
		// ------------------------------------------------------------
		// El gráfico v6.0 (3 series: kyber_banco, total_invertido, total_retirado)
		// necesita puntos continuos para verse bien.
		// Actualmente solo se guarda un punto cuando alguien invierte/retira.
		// Este hook guarda un snapshot cada 1 hora aunque no haya operaciones,
		// así la línea del gráfico queda fluida y realista.
		//
		// v6.2: reemplaza guardarPuntoHistorial() (AMM viejo, ya no existe)
		//       por guardarSnapshotBanco() (v6.0, 3 series).
		// ============================================
		if (class_exists('WalletHelper') && !empty($USER['id'])) {
			$cacheKeyChart = 'wallet_chart_last';
			$nowChart      = TIMESTAMP;
			$lastChart     = isset($_SESSION[$cacheKeyChart]) ? (int)$_SESSION[$cacheKeyChart] : 0;

			if (($nowChart - $lastChart) > 3600) { // 1 hora = 3600 segundos
				if (method_exists('WalletHelper', 'guardarSnapshotBanco')) {
					try {
						WalletHelper::guardarSnapshotBanco();
						$_SESSION[$cacheKeyChart] = $nowChart;
					} catch (Exception $e) {}
				}
			}
		}
		
		// ============================================
		// ASTROIO - HOOK RIFAS: Sorteo automático
		// ============================================
		if (class_exists('RaffleHelper') && !empty($USER['id'])) {
			$cacheKeyRaffle = 'raffles_last_check';
			$nowRaffle      = TIMESTAMP;
			$lastRaffle     = isset($_SESSION[$cacheKeyRaffle]) ? (int)$_SESSION[$cacheKeyRaffle] : 0;

			if (($nowRaffle - $lastRaffle) > 300) {
				if (method_exists('RaffleHelper', 'processExpired')) {
					try {
						RaffleHelper::processExpired();
						$_SESSION[$cacheKeyRaffle] = $nowRaffle;
					} catch (Exception $e) {}
				}
			}
		}
		
		// ============================================
		// ASTROIO - HOOK LOTERIA
		// ============================================
		if (class_exists('LotteryHelper') && !empty($USER['id'])) {
			$cacheKeyLot = 'lottery_last_check';
			$nowLot      = TIMESTAMP;
			$lastLot     = isset($_SESSION[$cacheKeyLot]) ? (int)$_SESSION[$cacheKeyLot] : 0;

			if (($nowLot - $lastLot) > 300) {
				if (method_exists('LotteryHelper', 'processExpired')) {
					try {
						LotteryHelper::processExpired();
						$_SESSION[$cacheKeyLot] = $nowLot;
					} catch (Exception $e) {}
				}
			}
		}
		
		// ============================================
		// ASTROIO - HOOK WAR
		// ============================================
		if (class_exists('WarProcessor') && !empty($USER['id'])) {
			$cacheKeyWar = 'war_last_run';
			$nowWar      = TIMESTAMP;
			$lastWar     = isset($_SESSION[$cacheKeyWar]) ? (int)$_SESSION[$cacheKeyWar] : 0;

			if (($nowWar - $lastWar) > 300) {
				try {
					WarProcessor::process();
					$_SESSION[$cacheKeyWar] = $nowWar;
				} catch (Exception $e) {}
			}
		}
		
		// ============================================
		// ASTROIO - HOOK PVE: Crisis + Imperio Caído + Torneo del Devorador + Bastión Asediado
		// ============================================
		if (class_exists('PVEHelper') && class_exists('PVECrisisHelper') && !empty($USER['id'])) {
			$cacheKeyPve = 'pve_last_run';
			$nowPve      = TIMESTAMP;
			$lastPve     = isset($_SESSION[$cacheKeyPve]) ? (int)$_SESSION[$cacheKeyPve] : 0;

			$forcePveCron = isset($_GET['force_pve_cron']) && (int) $_GET['force_pve_cron'] === 1;

			if ($forcePveCron || ($nowPve - $lastPve) > 300) {
				try {
					$db = Database::get();

					PVEHelper::log('cron', 0, 'start', 0, 0, array(
						'force' => $forcePveCron ? 1 : 0,
						'now'   => $nowPve,
					));

					// ═══════════════════════════════════════════════════
					// 🆕 v5.2 — AUTO-PROGRAMACIÓN DE CRISIS
					// Se ejecuta ANTES de procesar crisis existentes.
					// Si el toggle está activo y toca, crea una crisis nueva
					// que se activará en este mismo ciclo del cron.
					// ═══════════════════════════════════════════════════
					if (PVEHelper::isEnabled() && PVEHelper::isCrisisEnabled()
						&& class_exists('PVECrisisHelper')
						&& method_exists('PVECrisisHelper', 'autoScheduleIfNeeded')) {
						try {
							$crisisAutoScheduled = PVECrisisHelper::autoScheduleIfNeeded();
							if ($crisisAutoScheduled) {
								PVEHelper::log('cron', 0, 'crisis_auto_schedule_ok', 0, 0, null);
							}
						} catch (Exception $eAutoCrisis) {
							PVEHelper::log('cron', 0, 'crisis_auto_schedule_exception', 0, 0, array(
								'error' => $eAutoCrisis->getMessage(),
								'file'  => $eAutoCrisis->getFile(),
								'line'  => $eAutoCrisis->getLine(),
							));
						}
					}

					// 1) CRISIS
					if (PVEHelper::isEnabled() && PVEHelper::isCrisisEnabled()) {

						$sql = "SELECT id FROM %%PVE_CRISIS%%
								WHERE status = 'scheduled'
								  AND start_time <= :now
								  AND processing = 0
								ORDER BY start_time ASC LIMIT 1;";
						$rowCrisis = $db->selectSingle($sql, array(':now' => $nowPve));
						$crisisToStart = !empty($rowCrisis) ? (int) $rowCrisis['id'] : 0;

						if ($crisisToStart > 0) {
							PVEHelper::log('cron', 0, 'executing_scheduled', $crisisToStart, 0, null);
							PVECrisisHelper::executeNextWave($crisisToStart);
						} else {
							$sql = "SELECT c.id,
										   (SELECT MAX(executed_at) FROM %%PVE_CRISIS_WAVES%%
											WHERE crisis_id = c.id AND executed = 1) AS last_wave_at
									FROM %%PVE_CRISIS%% c
									WHERE c.status = 'active'
									  AND c.current_wave < c.total_waves
									  AND c.processing = 0
									  AND c.start_time <= :now
									  AND c.end_time   >  :now
									ORDER BY c.start_time ASC LIMIT 1;";
							$activeCrisis = $db->selectSingle($sql, array(':now' => $nowPve));

							if (!empty($activeCrisis)) {
								$intervalMin = (int) PVEHelper::get('crisis_wave_interval_minutes', 60);
								$interval    = max(60, $intervalMin * 60);
								$lastAt      = (int) $activeCrisis['last_wave_at'];

								PVEHelper::log('cron', 0, 'crisis_check', (int) $activeCrisis['id'], 0, array(
									'last_wave_at' => $lastAt,
									'now'          => $nowPve,
									'interval'     => $interval,
									'diff'         => $nowPve - $lastAt,
								));

								if (($nowPve - $lastAt) >= $interval) {
									PVEHelper::log('cron', 0, 'executing_active', (int) $activeCrisis['id'], 0, null);
									PVECrisisHelper::executeNextWave((int) $activeCrisis['id']);
								}
							} else {
								PVEHelper::log('cron', 0, 'no_crisis_to_process', 0, 0, null);
							}
						}

						$sql = "SELECT id, end_time FROM %%PVE_CRISIS%%
								WHERE status = 'active'
								  AND processing = 0
								  AND (
									(current_wave >= total_waves)
									OR (end_time <= :now)
								  )
								ORDER BY start_time ASC LIMIT 5;";
						$crisisToFinish = $db->select($sql, array(':now' => $nowPve));

						if (is_array($crisisToFinish) && count($crisisToFinish) > 0) {
							foreach ($crisisToFinish as $rowFinish) {
								$cidFin = (int) $rowFinish['id'];
								$endFin = (int) $rowFinish['end_time'];

								try {
									if ($endFin > 0 && $endFin <= $nowPve) {
										$db->update(
											"UPDATE %%PVE_CRISIS%% 
											 SET status = 'finished', processing = 0 
											 WHERE id = :id AND status = 'active';",
											array(':id' => $cidFin)
										);
										PVEHelper::log('crisis', $cidFin, 'force_finished_by_cron', 0, 0, array(
											'end_time' => $endFin,
										));
									} else {
										PVECrisisHelper::tryFinishCrisis($cidFin);
									}
								} catch (Exception $e) {}
							}
						}
					}

					// 2) IMPERIO CAÍDO
					if (PVEHelper::isEnabled() && PVEHelper::isEmpireEnabled()) {
						if (class_exists('PVEEmpireHelper') && method_exists('PVEEmpireHelper', 'processExpiredEmpires')) {
							PVEEmpireHelper::processExpiredEmpires();
						}
					}

					// ═══════════════════════════════════════════════════
					// 🆕 v5.2 — AUTO-PROGRAMACIÓN DEL TORNEO
					// Se ejecuta ANTES del cron del torneo.
					// Si el toggle está activo y toca, crea un evento
					// 'scheduled' con schedule_start_time en la fecha calculada.
					// ═══════════════════════════════════════════════════
					if (class_exists('PVEBossTournamentHelper')
						&& method_exists('PVEBossTournamentHelper', 'autoScheduleIfNeeded')) {
						try {
							$bossAutoScheduled = PVEBossTournamentHelper::autoScheduleIfNeeded();
							if ($bossAutoScheduled) {
								PVEHelper::log('cron', 0, 'boss_auto_schedule_ok', 0, 0, null);
							}
						} catch (Exception $eAutoBoss) {
							PVEHelper::log('cron', 0, 'boss_auto_schedule_exception', 0, 0, array(
								'error' => $eAutoBoss->getMessage(),
								'file'  => $eAutoBoss->getFile(),
								'line'  => $eAutoBoss->getLine(),
							));
						}
					}

					// 3) TORNEO DEL DEVORADOR (Boss Tournament)
					//    Procesa: estados scheduled→registration→active,
					//    contraataques de fases II/III, respawn de fantasmas,
					//    finalización automática por tiempo.
					if (class_exists('PVEBossTournamentHelper') && method_exists('PVEBossTournamentHelper', 'cron')) {
						try {
							PVEBossTournamentHelper::cron();
						} catch (Exception $eBoss) {
							PVEHelper::log('cron', 0, 'boss_cron_error', 0, 0, array(
								'error' => $eBoss->getMessage(),
								'file'  => $eBoss->getFile(),
								'line'  => $eBoss->getLine(),
							));
						}
					}

					// ═══════════════════════════════════════════════════
					// 🆕 v5.3 — AUTO-PROGRAMACIÓN DEL BASTIÓN
					// Se ejecuta ANTES del cron del bastión.
					// Si el toggle está activo y toca, crea un evento
					// 'scheduled' con schedule_start_time en la fecha calculada.
					// ═══════════════════════════════════════════════════
					if (class_exists('PVEBastionHelper')
						&& method_exists('PVEBastionHelper', 'autoScheduleIfNeeded')) {
						try {
							$bastionAutoScheduled = PVEBastionHelper::autoScheduleIfNeeded();
							if ($bastionAutoScheduled) {
								PVEHelper::log('cron', 0, 'bastion_auto_schedule_ok', 0, 0, null);
							}
						} catch (Exception $eAutoBastion) {
							PVEHelper::log('cron', 0, 'bastion_auto_schedule_exception', 0, 0, array(
								'error' => $eAutoBastion->getMessage(),
								'file'  => $eAutoBastion->getFile(),
								'line'  => $eAutoBastion->getLine(),
							));
						}
					}

					// 4) BASTIÓN ASEDIADO (torneo defensivo)
					//    Procesa: estados scheduled→registration→active,
					//    oleadas piratas programadas, resolución de combates,
					//    finalización automática por tiempo.
					if (class_exists('PVEBastionHelper') && method_exists('PVEBastionHelper', 'cron')) {
						try {
							PVEBastionHelper::cron();
						} catch (Exception $eBastion) {
							PVEHelper::log('cron', 0, 'bastion_cron_error', 0, 0, array(
								'error' => $eBastion->getMessage(),
								'file'  => $eBastion->getFile(),
								'line'  => $eBastion->getLine(),
							));
						}
					}

					// Limpieza automática (Capas 2 y 3)
					if (class_exists('PVECrisisHelper')) {
						try {
							PVECrisisHelper::cleanupOrphans();
							PVECrisisHelper::cleanupDeep($forcePveCron);
						} catch (Exception $eCleanup) {
							PVEHelper::log('cron', 0, 'cleanup_hook_error', 0, 0, array(
								'error' => $eCleanup->getMessage(),
								'file'  => $eCleanup->getFile(),
								'line'  => $eCleanup->getLine(),
							));
						}
					}

					PVEHelper::log('cron', 0, 'end', 0, 0, null);
					$_SESSION[$cacheKeyPve] = $nowPve;

				} catch (Exception $e) {
					error_log('[PVE CRON] ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
					if (class_exists('PVEHelper')) {
						try {
							PVEHelper::log('cron', 0, 'error', 0, 0, array(
								'error' => $e->getMessage(),
								'file'  => $e->getFile(),
								'line'  => $e->getLine(),
							));
						} catch (Exception $e2) {}
					}
				}
			}
		}
		
		// ============================================
		// 🆕 ASTROIO v2.6 - HOOK PVP: Arenas + Torneos
		// ✅ v3.8 — El gate real es el lock global en pvp_config
		// (PVPProcessor::shouldRun, UPDATE condicional + rowCount). Antes el
		// gate era $_SESSION POR USUARIO: con N usuarios online corría N veces
		// solapado cada 5 min, y cualquier jugador podía forzar la ejecución
		// global a voluntad con ?force_pvp_cron=1 (ahora solo admins).
		// ============================================
		if (class_exists('PVPHelper') && class_exists('PVPProcessor') && !empty($USER['id'])) {
			$forcePvpCron = isset($_GET['force_pvp_cron'])
				&& (int) $_GET['force_pvp_cron'] === 1
				&& (int) ($USER['authlevel'] ?? 0) >= 1;

			// ✅ v3.8 — El gate ÚNICO vive dentro de run() (shouldRun con lock
			// global en pvp_config). No se consulta fuera para no consumir el
			// lock dos veces: si la página ganara el UPDATE y run() lo
			// reintentara, devolvería "skipped" y el cron nunca correría.
			try {
				PVPProcessor::run($forcePvpCron);
			} catch (Exception $e) {
				error_log('[PVP CRON] ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
				if (class_exists('PVPHelper')) {
					try {
						PVPHelper::log('cron', 0, 'cron_error', 0, array(
							'error' => $e->getMessage(),
							'file'  => $e->getFile(),
							'line'  => $e->getLine(),
						));
					} catch (Exception $e2) {}
				}
			}
		}
		
		// ============================================
		// 🆕 ASTROIO v5.8 - HOOK AUDITORÍA NTX-20: Limpieza automática
		// ------------------------------------------------------------
		// Borra los logs de auditoría de NTX-20 más viejos que los
		// meses configurados por el admin en ?page=ntx20admin.
		// Se ejecuta cada 24h (o cuando se fuerza con ?force_ntx_cleanup=1).
		// ============================================
		if (class_exists('NTX20LogHelper') && !empty($USER['id'])) {
			$cacheKeyNtx    = 'ntx20_cleanup_last_run';
			$nowNtx         = TIMESTAMP;
			$lastNtx        = isset($_SESSION[$cacheKeyNtx]) ? (int)$_SESSION[$cacheKeyNtx] : 0;

			$forceNtxCron = isset($_GET['force_ntx_cleanup']) && (int) $_GET['force_ntx_cleanup'] === 1;

			if ($forceNtxCron || ($nowNtx - $lastNtx) > 86400) { // 24h
				try {
					if (method_exists('NTX20LogHelper', 'cleanupOldLogs')) {
						$deleted = NTX20LogHelper::cleanupOldLogs();
						$_SESSION[$cacheKeyNtx] = $nowNtx;

						if ($deleted > 0) {
							error_log('[NTX20 CLEANUP] Borrados ' . $deleted . ' registros viejos del log de auditoria');
						}
					}
				} catch (Exception $e) {
					error_log('[NTX20 CLEANUP] ' . $e->getMessage());
				}
			}
		}
		
		// ============================================
		// NOTA: El cron de asteroides vive ahora en AbstractGamePage
		// (se ejecuta en cualquier página del juego, no solo aquí)
		// ============================================
		
		$AdminsOnline 	= array();
		$chatOnline 	= array();
		$AllPlanets		= array();
		$Moon 			= array();

        $db = Database::get();
		
		foreach($USER['PLANETS'] as $ID => $CPLANET)
		{		
			if ($ID == $PLANET['id'] || $CPLANET['planet_type'] == 3)
				continue;

			if (!empty($CPLANET['b_building']) && $CPLANET['b_building'] > TIMESTAMP) {
				$Queue				= unserialize($CPLANET['b_building_id']);
				$BuildPlanet		= $LNG['tech'][$Queue[0][0]]." (".$Queue[0][1].")<br><span style=\"color:#7F7F7F;\">(".pretty_time($Queue[0][3] - TIMESTAMP).")</span>";
			} else {
				$BuildPlanet     = $LNG['ov_free'];
			}
			
			$AllPlanets[] = array(
				'id'	=> $CPLANET['id'],
				'name'	=> $CPLANET['name'],
				'image'	=> $CPLANET['image'],
				'build'	=> $BuildPlanet,
			);
		}
		
		if ($PLANET['id_luna'] != 0) {
			$sql = "SELECT id, name FROM %%PLANETS%% WHERE id = :lunaID;";
            $Moon = $db->selectSingle($sql, array(
                ':lunaID'   => $PLANET['id_luna']
            ));
            if (empty($Moon)) {
                $Moon = array();
            }
        }
			
		if ($PLANET['b_building'] - TIMESTAMP > 0) {
			$Queue			= unserialize($PLANET['b_building_id']);
			$buildInfo['buildings']	= array(
				'id'		=> $Queue[0][0],
				'level'		=> $Queue[0][1],
				'timeleft'	=> $PLANET['b_building'] - TIMESTAMP,
				'time'		=> $PLANET['b_building'],
				'starttime'	=> pretty_time($PLANET['b_building'] - TIMESTAMP),
			);
		}
		else {
			$buildInfo['buildings']	= false;
		}
		
		// ============================================
		// ✅ AstroIO v5.9 - COLA DE NAVES (b_hangar_id / b_hangar)
		// ============================================
		if (!empty($PLANET['b_hangar_id'])) {
			$Queue	= unserialize($PLANET['b_hangar_id']);
			$time	= BuildFunctions::getBuildingTime($USER, $PLANET, $Queue[0][0]) * $Queue[0][1];
			$buildInfo['fleet']	= array(
				'id'		=> $Queue[0][0],
				'level'		=> $Queue[0][1],
				'timeleft'	=> $time - $PLANET['b_hangar'],
				'time'		=> $time,
				'starttime'	=> pretty_time($time - $PLANET['b_hangar']),
			);
		}
		else {
			$buildInfo['fleet']	= false;
		}
		
		// ============================================
		// ✅ AstroIO v5.9 - COLA DE DEFENSAS (b_defense_id / b_defense)
		// ------------------------------------------------------------
		// Espejo exacto de la cola de naves pero usando las columnas
		// nuevas b_defense_id / b_defense. Independiente de la de naves.
		// ============================================
		if (!empty($PLANET['b_defense_id'])) {
			$Queue	= unserialize($PLANET['b_defense_id']);
			$time	= BuildFunctions::getBuildingTime($USER, $PLANET, $Queue[0][0]) * $Queue[0][1];
			$buildInfo['defense']	= array(
				'id'		=> $Queue[0][0],
				'level'		=> $Queue[0][1],
				'timeleft'	=> $time - $PLANET['b_defense'],
				'time'		=> $time,
				'starttime'	=> pretty_time($time - $PLANET['b_defense']),
			);
		}
		else {
			$buildInfo['defense']	= false;
		}
		
		if ($USER['b_tech'] - TIMESTAMP > 0) {
			$Queue			= unserialize($USER['b_tech_queue']);
			$buildInfo['tech']	= array(
				'id'		=> $Queue[0][0],
				'level'		=> $Queue[0][1],
				'timeleft'	=> $USER['b_tech'] - TIMESTAMP,
				'time'		=> $USER['b_tech'],
				'starttime'	=> pretty_time($USER['b_tech'] - TIMESTAMP),
			);
		}
		else {
			$buildInfo['tech']	= false;
		}
		
		
		// ═══════════════════════════════════════════════════════════
		// ASTROIO v5.4/v5.6 — Admins Online (filtrado de fantasmas por email)
		// ═══════════════════════════════════════════════════════════
		$sql = "SELECT id,username FROM %%USERS%% 
		        WHERE universe = :universe 
		          AND onlinetime >= :onlinetime 
		          AND authlevel > :authlevel
		          AND email NOT LIKE '%@noreply.local';";
        $onlineAdmins = $db->select($sql, array(
            ':universe'     => Universe::current(),
            ':onlinetime'   => TIMESTAMP-10*60,
            ':authlevel'    => AUTH_USR
        ));

        // ============================================
        // ✅ ASTROIO v5.6 - Admins Online:
        //   - ONLINE (verde) / OFFLINE (gris)  → $AdminsOnline (visual)
        //   - Número real de admins online     → $adminsOnlineCount (para el contador)
        // ============================================
        $adminsOnlineCount = 0;
        if (is_array($onlineAdmins) && count($onlineAdmins) > 0) {
            $adminsOnlineCount = count($onlineAdmins);
            $AdminsOnline[] = '<span style="color:#00ff66;font-weight:bold;">ONLINE</span>';
        } else {
            $AdminsOnline[] = '<span style="color:#888888;">OFFLINE</span>';
        }

        $sql = "SELECT userName FROM %%CHAT_ON%% WHERE dateTime > DATE_SUB(NOW(), interval 2 MINUTE) AND channel = 0";
        $chatUsers = $db->select($sql);

        if (is_array($chatUsers)) {
            foreach ($chatUsers as $chatRow) {
                $chatOnline[]	= $chatRow['userName'];
            }
        }

		$Messages		= $USER['messages'];
		
		// ═══════════════════════════════════════════════════════════
		// ✅ ASTROIO v5.5 — REFERIDOS: ELIMINADO el sistema nativo
		// ------------------------------------------------------------
		// Antes acá se hacía:
		//   1) Query RefLinksRAW (referidos del usuario)
		//   2) if($config->ref_active) { llenar $RefLinks }
		//   3) assign('ref_active', 'ref_minpoints', 'RefLinks')
		//
		// TODO ELIMINADO. El sistema de referidos ahora es SOLO por
		// código (ReferralHelper v5.0) y se gestiona en:
		//   - game.php?page=referral  (vista del usuario)
		//   - index.php?page=register (registro con código)
		//
		// El overview ya NO muestra el bloque "ENLACE REF."
		// ═══════════════════════════════════════════════════════════

		$config	= Config::get();

		// ============================================
		// 🆕 ASTROIO v5.7 - WIDGET BOOST FIN DE SEMANA
		// ------------------------------------------------------------
		// Calcula el estado del boost de fin de semana para que el
		// template pueda mostrar la cuenta regresiva entre "XNOVA
		// AstroIO" y "Planeta Principal".
		//
		// 3 estados posibles:
		//   - enabled = 1  → El sistema está activo
		//   - active  = 1  → El boost está APLICADO ahora
		//   - show    = 1  → El banner debe mostrarse (faltan ≤24h O activo)
		//
		// phase:
		//   - 'active'    → El banner dice "BOOST ACTIVO ×N — Termina en..."
		//   - 'countdown' → El banner dice "Boost Fin de Semana en..."
		// ============================================
		$weekendBoost = array(
			'enabled'         => 0,
			'active'          => 0,
			'show'            => 0,
			'phase'           => '',
			'multiplier'      => 0,
			'seconds_left'    => 0,
		);

		if (class_exists('WeekendBoostHelper') && !empty($USER['id'])) {
			try {
				$wbCfg = WeekendBoostHelper::getConfig();

				if (!empty($wbCfg) && !empty($wbCfg['enabled'])) {
					$weekendBoost['enabled'] = 1;

					$isActive = WeekendBoostHelper::isWeekendNow($wbCfg) ? 1 : 0;
					$weekendBoost['active'] = $isActive;

					// Multiplicador a mostrar (velocidad general del finde)
					$weekendBoost['multiplier'] = isset($wbCfg['weekend_game_speed'])
						? (float) $wbCfg['weekend_game_speed']
						: 2.0;

					// Próximo cambio (timestamp)
					$nextChange  = (int) WeekendBoostHelper::getNextChangeTime($wbCfg);
					$secondsLeft = max(0, $nextChange - TIMESTAMP);

					if ($isActive === 1) {
						// Boost ACTIVO → siempre mostrar
						$weekendBoost['show']         = 1;
						$weekendBoost['phase']        = 'active';
						$weekendBoost['seconds_left'] = $secondsLeft;
					} else {
						// No está activo → mostrar SOLO si falta ≤ 24h
						if ($secondsLeft > 0 && $secondsLeft <= 86400) {
							$weekendBoost['show']         = 1;
							$weekendBoost['phase']        = 'countdown';
							$weekendBoost['seconds_left'] = $secondsLeft;
						}
					}
				}
			} catch (Exception $e) {
				// Silencioso: si falla, el banner no se muestra
			}
		}

		$sql	= 'SELECT total_points, total_rank
		FROM %%STATPOINTS%%
		WHERE id_owner = :userId AND stat_type = :statType';

		$statData	= Database::get()->selectSingle($sql, array(
			':userId'	=> $USER['id'],
			':statType'	=> 1
		));

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v5.4 — Conteo real de jugadores (sin fantasmas)
		// Se usa para "Lugar 1 de X" en lugar de $config->users_amount
		// ═══════════════════════════════════════════════════════════
		$rowRealUsers = $db->selectSingle(
			"SELECT COUNT(*) AS cnt FROM %%USERS%% 
			 WHERE universe = :universe 
			   AND email NOT LIKE '%@noreply.local';",
			array(':universe' => Universe::current()),
			'cnt'
		);
		$realUsersAmount = !empty($rowRealUsers) ? (int) $rowRealUsers : 1;
		if ($realUsersAmount <= 0) {
			$realUsersAmount = 1;
		}

		if (empty($statData) || !isset($statData['total_rank']) || $statData['total_rank'] == 0) {
			$rankInfo	= "-";
		} else {
			$rankInfo	= sprintf($LNG['ov_userrank_info'], pretty_number($statData['total_points']), $LNG['ov_place'],
				$statData['total_rank'], $statData['total_rank'], $LNG['ov_of'], $realUsersAmount);
		}

		// ═══════════════════════════════════════════════════════════
		// ASTROIO v5.4 — Jugadores en línea (filtrado por email)
		// ═══════════════════════════════════════════════════════════
		$onlineUserResult = $db->select("SELECT * FROM %%USERS%% 
		                                 WHERE onlinetime > :timeUser 
		                                   AND authlevel < :auth 
		                                   AND email NOT LIKE '%@noreply.local';", array(
			':timeUser' => TIMESTAMP - 15*60,
			':auth' => AUTH_ADM,
		));
		$onlineUser = $db->rowCount();

		// ============================================
		// ASTROIO - Cargar TODOS los potenciadores
		// ============================================
		$prefix = 'uni1_';
		if (defined('DB_PREFIX')) $prefix = DB_PREFIX;
		elseif (defined('PREFIX')) $prefix = PREFIX;

		$iconEmojiMap = array(
			'EXP' => '🧭',
			'MO'  => '💎',
			'PRO' => '⛏️',
			'SPY' => '🔍',
			'ENE' => '⚡',
			'BLD' => '🏗️',
			'TEC' => '🔬',
			'HNG' => '🔧',
		);

		$allBoosters = $db->select(
			"SELECT * FROM `".$prefix."boosters` ORDER BY booster_id ASC;"
		);

		if (!is_array($allBoosters)) {
			$allBoosters = array();
		}

		$activeRows = $db->select(
			"SELECT booster_id, expires_at 
			 FROM `".$prefix."users_boosters` 
			 WHERE user_id = :uid AND expires_at > :now;",
			array(':uid' => $USER['id'], ':now' => TIMESTAMP)
		);

		$activeMap = array();
		if (is_array($activeRows)) {
			foreach ($activeRows as $row) {
				$activeMap[(int)$row['booster_id']] = (int)$row['expires_at'];
			}
		}

		$allBoostersList = array();
		$activeCount = 0;

		foreach ($allBoosters as $booster) {
			$bid = (int)$booster['booster_id'];
			$isActive = isset($activeMap[$bid]);

			$item = array(
				'booster_id'    => $bid,
				'booster_name'  => $booster['booster_name'],
				'booster_desc'  => $booster['booster_desc'],
				'booster_icon'  => $booster['booster_icon'],
				'booster_color' => $booster['booster_color'],
				'booster_type'  => $booster['booster_type'],
				'booster_value' => (int)$booster['booster_value'],
				'active'        => $isActive,
				'remaining_str' => '',
				'icon_emoji'    => isset($iconEmojiMap[$booster['booster_icon']]) 
									? $iconEmojiMap[$booster['booster_icon']] 
									: '🎁',
			);

			if ($isActive) {
				$remaining = max(0, $activeMap[$bid] - TIMESTAMP);
				$days    = floor($remaining / 86400);
				$hours   = floor(($remaining % 86400) / 3600);
				$minutes = floor(($remaining % 3600) / 60);

				$timeStr = '';
				if ($days > 0)    $timeStr .= $days . 'd ';
				if ($hours > 0)   $timeStr .= $hours . 'h ';
				$timeStr .= $minutes . 'm';

				$item['remaining_str'] = $timeStr;
				$activeCount++;
			}

			$allBoostersList[] = $item;
		}

		$db->delete(
			"DELETE FROM `".$prefix."users_boosters` WHERE user_id = :uid AND expires_at <= :now;",
			array(':uid' => $USER['id'], ':now' => TIMESTAMP)
		);

		// ============================================
		// ASTROIO - Cargar 3 eventos (overview)
		// ============================================
		$ovEvents = array(
			'daily'  => null,
			'weekly' => null,
			'elite'  => null,
		);

		if (class_exists('EventHelper')) {
			$ovEventsRaw = EventHelper::getOverviewEvents($USER['id']);

			$evIconMap = array(
				'ATK'  => '⚔️',
				'REC'  => '♻️',
				'EXP'  => '🧭',
				'RES'  => '💰',
				'SHIP' => '🚀',
				'TEC'  => '🔬',
				'ELT'  => '👑',
			);

			if (is_array($ovEventsRaw)) {
				foreach ($ovEventsRaw as $key => $ev) {
					if (!$ev) {
						$ovEvents[$key] = null;
						continue;
					}

					$target = max(1, (int)$ev['event_target_value']);
					$prog   = (int)$ev['progress'];

					$ev['icon_emoji']   = isset($evIconMap[$ev['event_icon']]) ? $evIconMap[$ev['event_icon']] : '🎯';
					$ev['progress_pct'] = min(100, round(($prog / $target) * 100));
					$ev['is_complete']  = ($prog >= $target);
					$ev['is_claimed']   = ($ev['claimed'] == 1);
					$ev['can_claim']    = ($ev['is_complete'] && !$ev['is_claimed']);
					$ev['progress_fmt'] = number_format($prog);
					$ev['target_fmt']   = number_format($target);

					$rewardValue = (int)$ev['reward_value'];
					$rewardType  = $ev['reward_type'];

					switch ($rewardType) {
						case 'metal':      $ev['reward_text'] = '🪙 '.number_format($rewardValue).' Metal'; break;
						case 'crystal':    $ev['reward_text'] = '💎 '.number_format($rewardValue).' Cristal'; break;
						case 'deuterium':  $ev['reward_text'] = '🧪 '.number_format($rewardValue).' Deuterio'; break;
						case 'containers': $ev['reward_text'] = '📦 '.number_format($rewardValue).' Cont.'; break;
						default:           $ev['reward_text'] = '🎁 '.number_format($rewardValue).' '.$rewardType; break;
					}

					$ovEvents[$key] = $ev;
				}
			}
		}

		// ============================================
		// ASTROIO - Widget de Rifas activas (Overview)
		// ============================================
		$rafflesWidget = array();
		$rafflesCount  = 0;

		if (class_exists('RaffleHelper')) {
			try {
				$rafflesWidget = RaffleHelper::getWidgetData(3);
				$rafflesCount  = RaffleHelper::countActive();
			} catch (Exception $e) {
				$rafflesWidget = array();
				$rafflesCount  = 0;
			}
		}

		// ============================================
		// ASTROIO - Widget de Loteria (Overview)
		// ============================================
		$lotteryWidget = null;

		if (class_exists('LotteryHelper')) {
			try {
				$lotteryWidget = LotteryHelper::getWidgetData();
			} catch (Exception $e) {
				$lotteryWidget = null;
			}
		}

		// ============================================
		// ASTROIO - Widget PvE (Overview)
		// ============================================
		$pveWidget = array(
			'enabled'         => false,
			'show_widget'     => false,
			'crisis_active'   => 0,
			'crisis_time'     => 0,
			'crisis_end'      => 0,
			'empire_active'   => 0,
			'empire_time'     => 0,
			'empire_end'      => 0,
			'empire_count'    => 0,
			'pending_rewards' => 0,
			// 🆕 Torneo del Devorador
			'boss_enabled'    => 0,
			'boss_active'     => 0,
			'boss_status'     => '',
			'boss_time'       => 0,
			'boss_end'        => 0,
			'boss_ghosts'     => 0,
			// 🆕 Bastión Asediado
			'bastion_enabled' => 0,
			'bastion_active'  => 0,
			'bastion_status'  => '',
			'bastion_time'    => 0,
			'bastion_end'     => 0,
			'bastion_ghosts'  => 0,
			'bastion_waves'   => 0,
		);

		if (class_exists('PVEHelper') && method_exists('PVEHelper', 'isEnabled') && PVEHelper::isEnabled()) {
			$pveWidget['enabled'] = true;

			try {
				$crisisState = PVEHelper::getEventState('crisis');

				$pveWidget['crisis_active'] = !empty($crisisState['active'])    ? 1 : 0;
				$pveWidget['crisis_time']   = !empty($crisisState['next_time']) ? (int) $crisisState['next_time'] : 0;
				$pveWidget['crisis_end']    = !empty($crisisState['end_time'])  ? (int) $crisisState['end_time']  : 0;
			} catch (Exception $e) {}

			try {
				$empireState = PVEHelper::getEventState('empire');

				$pveWidget['empire_active'] = !empty($empireState['active'])    ? 1 : 0;
				$pveWidget['empire_time']   = !empty($empireState['next_time']) ? (int) $empireState['next_time'] : 0;
				$pveWidget['empire_end']    = !empty($empireState['end_time'])  ? (int) $empireState['end_time']  : 0;

				if ($pveWidget['empire_active'] === 1) {
					$rowEmp = $db->selectSingle(
						"SELECT COUNT(*) AS cnt FROM %%PVE_EMPIRES%%
						 WHERE status = 'active' AND end_time > :now;",
						array(':now' => TIMESTAMP),
						'cnt'
					);
					$pveWidget['empire_count'] = !empty($rowEmp) ? (int) $rowEmp : 0;
				}
			} catch (Exception $e) {}

			// 🆕 Torneo del Devorador
			try {
				if (class_exists('PVEBossTournamentHelper') && method_exists('PVEBossTournamentHelper', 'getEventState')) {
					$bossState = PVEBossTournamentHelper::getEventState();

					$pveWidget['boss_enabled'] = !empty($bossState['enabled'])    ? 1 : 0;
					$pveWidget['boss_active']  = !empty($bossState['active'])     ? 1 : 0;
					$pveWidget['boss_status']  = !empty($bossState['status'])     ? (string) $bossState['status'] : '';
					$pveWidget['boss_time']    = !empty($bossState['next_time'])  ? (int) $bossState['next_time']  : 0;
					$pveWidget['boss_end']     = !empty($bossState['end_time'])   ? (int) $bossState['end_time']   : 0;

					if (!empty($bossState['has_event']) && $pveWidget['boss_active'] === 1) {
						$rowBoss = $db->selectSingle(
							"SELECT COUNT(*) AS cnt FROM %%PVE_BOSS_GHOSTS%%
							 WHERE event_id = :eid AND status = 'active';",
							array(':eid' => (int) $bossState['event_id']),
							'cnt'
						);
						$pveWidget['boss_ghosts'] = !empty($rowBoss) ? (int) $rowBoss : 0;
					}
				}
			} catch (Exception $e) {}

			// 🆕 Bastión Asediado
			try {
				if (class_exists('PVEBastionHelper') && method_exists('PVEBastionHelper', 'getEventState')) {
					$bastionState = PVEBastionHelper::getEventState();

					$pveWidget['bastion_enabled'] = !empty($bastionState['enabled'])    ? 1 : 0;
					$pveWidget['bastion_active']  = !empty($bastionState['active'])     ? 1 : 0;
					$pveWidget['bastion_status']  = !empty($bastionState['status'])     ? (string) $bastionState['status'] : '';
					$pveWidget['bastion_time']    = !empty($bastionState['next_time'])  ? (int) $bastionState['next_time']  : 0;
					$pveWidget['bastion_end']     = !empty($bastionState['end_time'])   ? (int) $bastionState['end_time']   : 0;

					if (!empty($bastionState['has_event']) && $pveWidget['bastion_active'] === 1) {
						$rowBastion = $db->selectSingle(
							"SELECT COUNT(*) AS cnt FROM %%PVE_BASTION_GHOSTS%%
							 WHERE event_id = :eid AND status = 'active';",
							array(':eid' => (int) $bastionState['event_id']),
							'cnt'
						);
						$pveWidget['bastion_ghosts'] = !empty($rowBastion) ? (int) $rowBastion : 0;

						$rowWaves = $db->selectSingle(
							"SELECT COUNT(*) AS cnt FROM %%PVE_BASTION_WAVES%%
							 WHERE event_id = :eid AND resolved = 0;",
							array(':eid' => (int) $bastionState['event_id']),
							'cnt'
						);
						$pveWidget['bastion_waves'] = !empty($rowWaves) ? (int) $rowWaves : 0;
					}
				}
			} catch (Exception $e) {}

			try {
				if (class_exists('PVEHelper') && method_exists('PVEHelper', 'getPendingRewardsCount')) {
					$pveWidget['pending_rewards'] = (int) PVEHelper::getPendingRewardsCount($USER['id']);
				} else {
					$rowRew = $db->selectSingle(
						"SELECT COUNT(*) AS cnt FROM %%PVE_REWARDS%%
						 WHERE user_id = :uid AND claimed = 0;",
						array(':uid' => $USER['id']),
						'cnt'
					);
					$pveWidget['pending_rewards'] = (int) $rowRew;
				}
			} catch (Exception $e) {
				$pveWidget['pending_rewards'] = 0;
			}

			$pveWidget['show_widget'] = (
				$pveWidget['crisis_active']   === 1 ||
				$pveWidget['crisis_time']     > 0 ||
				$pveWidget['empire_active']   === 1 ||
				$pveWidget['empire_time']     > 0 ||
				$pveWidget['pending_rewards'] > 0 ||
				$pveWidget['boss_active']     === 1 ||
				$pveWidget['boss_time']       > 0 ||
				$pveWidget['bastion_active']  === 1 ||
				$pveWidget['bastion_time']    > 0
			);
		}

		// ============================================
		// 🆕 ASTROIO v2.6 - Widget PvP (Overview)
		// ============================================
		$pvpWidget = array(
			'enabled'              => 0,
			'show_widget'          => 0,
			'arenas_waiting'       => 0,
			'arenas_active'        => 0,
			'my_arena'             => null,
			'tournament_active'    => 0,
			'tournament_status'    => '',
			'tournament_time'      => 0,
			'tournament_players'   => 0,
			'tournament_max'       => 0,
			'tournament_pool'      => 0,
			'my_pvp_points'        => 0,
			'my_pvp_wins'          => 0,
			'my_pvp_losses'        => 0,
			'ach_unlocked'         => 0,
			'ach_total'            => 0,
		);

		if (class_exists('PVPHelper') && method_exists('PVPHelper', 'isArenaEnabled')) {
			$pvpWidget['enabled'] = (
				(PVPHelper::isArenaEnabled() || PVPHelper::isTournamentEnabled())
			) ? 1 : 0;

			if ($pvpWidget['enabled'] === 1) {

				try {
					$row = $db->selectSingle(
						"SELECT `pvp_points` FROM %%USERS%% WHERE `id` = :uid LIMIT 1;",
						array(':uid' => $USER['id'])
					);
					$pvpWidget['my_pvp_points'] = empty($row) ? 0 : (int) $row['pvp_points'];
				} catch (Exception $e) {}

				try {
					if (class_exists('PVPArenaHelper')) {
						$row = $db->selectSingle(
							"SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` = 'waiting';"
						);
						$pvpWidget['arenas_waiting'] = empty($row) ? 0 : (int) $row['c'];

						$row = $db->selectSingle(
							"SELECT COUNT(*) AS c FROM %%PVP_ARENAS%% WHERE `status` IN ('active','extra_time');"
						);
						$pvpWidget['arenas_active'] = empty($row) ? 0 : (int) $row['c'];

						$row = $db->selectSingle(
							"SELECT a.* 
							 FROM %%PVP_ARENAS%% a
							 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
							 WHERE ap.`user_id` = :uid 
							   AND a.`status` IN ('waiting','active','extra_time')
							 LIMIT 1;",
							array(':uid' => $USER['id'])
						);
						if (!empty($row)) {
							$timeLeft = 0;
							if ($row['status'] === 'waiting') {
								$expire = PVPArenaHelper::getExpire();
								$timeLeft = max(0, ((int) $row['created_at'] + $expire) - TIMESTAMP);
							} elseif ($row['status'] === 'active') {
								$timeLeft = max(0, (int) $row['ends_at'] - TIMESTAMP);
							} elseif ($row['status'] === 'extra_time') {
								$timeLeft = max(0, (int) $row['extra_time_ends_at'] - TIMESTAMP);
							}

							$pvpWidget['my_arena'] = array(
								'id'          => (int) $row['id'],
								'mode'        => $row['mode'],
								'mode_label'  => strtoupper($row['mode']),
								'status'      => $row['status'],
								'time_left'   => $timeLeft,
								'time_fmt'    => PVPHelper::formatCountdown($timeLeft),
								'players'     => (int) $row['current_players'],
								'max'         => (int) $row['max_players'],
								'pool'        => (int) $row['prize_pool'],
							);
						}
					}
				} catch (Exception $e) {}

				try {
					if (class_exists('PVPTournamentHelper')) {
						$t = PVPTournamentHelper::getActiveTournament();
						if (!empty($t)) {
							$pvpWidget['tournament_active']  = 1;
							$pvpWidget['tournament_status']  = isset($t['status']) ? $t['status'] : '';
							$pvpWidget['tournament_players'] = isset($t['current_players']) ? (int) $t['current_players'] : 0;
							$pvpWidget['tournament_max']     = isset($t['max_players'])     ? (int) $t['max_players']     : 0;
							$pvpWidget['tournament_pool']    = isset($t['prize_pool'])      ? (int) $t['prize_pool']      : 0;

							if ($pvpWidget['tournament_status'] === 'registration' && !empty($t['registration_ends_at'])) {
								$pvpWidget['tournament_time'] = (int) $t['registration_ends_at'];
							} elseif ($pvpWidget['tournament_status'] === 'running' && !empty($t['starts_at'])) {
								$pvpWidget['tournament_time'] = (int) $t['starts_at'];
							}
						}
					}
				} catch (Exception $e) {}

				try {
					$row = $db->selectSingle(
						"SELECT COUNT(*) AS c 
						 FROM %%PVP_ARENAS%% a
						 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
						 WHERE ap.`user_id` = :uid 
						   AND a.`status` = 'finished'
						   AND ap.`team` = a.`winner_team';",
						array(':uid' => $USER['id'])
					);
					$pvpWidget['my_pvp_wins'] = empty($row) ? 0 : (int) $row['c'];

					$row = $db->selectSingle(
						"SELECT COUNT(*) AS c 
						 FROM %%PVP_ARENAS%% a
						 INNER JOIN %%PVP_ARENA_PLAYERS%% ap ON ap.`arena_id` = a.`id`
						 WHERE ap.`user_id` = :uid 
						   AND a.`status` = 'finished'
						   AND ap.`team` != a.`winner_team';",
						array(':uid' => $USER['id'])
					);
					$pvpWidget['my_pvp_losses'] = empty($row) ? 0 : (int) $row['c'];
				} catch (Exception $e) {}

				try {
					if (class_exists('PVPAchievementHelper')) {
						$row = $db->selectSingle(
							"SELECT COUNT(*) AS c FROM %%PVP_ACHIEVEMENTS%% WHERE `user_id` = :uid;",
							array(':uid' => $USER['id'])
						);
						$pvpWidget['ach_unlocked'] = empty($row) ? 0 : (int) $row['c'];
						$pvpWidget['ach_total']    = 8;
					}
				} catch (Exception $e) {}

				$pvpWidget['show_widget'] = (
					$pvpWidget['arenas_waiting']     > 0 ||
					$pvpWidget['arenas_active']      > 0 ||
					$pvpWidget['my_arena']           !== null ||
					$pvpWidget['tournament_active']  === 1 ||
					$pvpWidget['my_pvp_points']      > 0
				) ? 1 : 0;
			}
		}
		
		// ============================================
		// 🆕 ASTROIO v6.5 (SISTEMA DE CLIMA) - Clima del planeta y la luna
		// ============================================
		$climaPlaneta         = null;
		$climaPlanetaPrevisto = null;
		$climaLuna            = null;
		$climaLunaPrevisto    = null;

		if (class_exists('ClimaEngine') && !empty($PLANET['id'])) {
			try {
				// Clima del planeta actual
				$climaPlaneta         = ClimaEngine::getClimaPlaneta((int)$PLANET['id']);
				$climaPlanetaPrevisto = ClimaEngine::getPrediccionPlaneta((int)$PLANET['id']);

				// Clima de la luna (si existe)
				if (!empty($PLANET['id_luna']) && (int)$PLANET['id_luna'] > 0) {
					$climaLuna         = ClimaEngine::getClimaPlaneta((int)$PLANET['id_luna']);
					$climaLunaPrevisto = ClimaEngine::getPrediccionPlaneta((int)$PLANET['id_luna']);
				}
			} catch (Exception $e) {
				// Silencioso: si falla el clima, el overview sigue funcionando
			}
		}

		// ============================================
		// 🆕 ASTROIO v6.6 (BUFF CLIMÁTICO) - Buff activo
		// ============================================
		$buffActivo             = null;
		$buffSegundosRestantes  = 0;
		$buffHorasRestantes     = 0;
		$buffMinutosRestantes   = 0;
		$buffNombreLegible      = '';

		if (class_exists('ClimaEngine') && !empty($USER['id'])) {
			try {
				$buffActivo = ClimaEngine::getActiveBuff((int)$USER['id']);
				if (!empty($buffActivo) && isset($buffActivo['segundos_restantes'])) {
					$buffSegundosRestantes = (int)$buffActivo['segundos_restantes'];
					$buffHorasRestantes    = (int)floor($buffSegundosRestantes / 3600);
					$buffMinutosRestantes  = (int)floor(($buffSegundosRestantes % 3600) / 60);
					$buffInfo              = ClimaEngine::getBuffInfo($buffActivo['buff_id']);
					$buffNombreLegible     = $buffInfo ? $buffInfo['nombre'] : $buffActivo['buff_type'];
				}
			} catch (Exception $e) {
				// Silencioso
			}
		}

		$this->assign(array(
			'rankInfo'					=> $rankInfo,
			'is_news'					=> $config->OverviewNewsFrame,
			'news'						=> makebr($config->OverviewNewsText),
			'planetname'				=> $PLANET['name'],
			'planetimage'				=> $PLANET['image'],
			'galaxy'					=> $PLANET['galaxy'],
			'system'					=> $PLANET['system'],
			'planet'					=> $PLANET['planet'],
			'planet_type'				=> $PLANET['planet_type'],
			'userid'					=> $USER['id'],
			'onlineUser'				=> $onlineUser,
			'buildInfo'					=> $buildInfo,
			'Moon'						=> $Moon,
			'fleets'					=> $this->GetFleets(),
			'AllPlanets'				=> $AllPlanets,
			'AdminsOnline'				=> $AdminsOnline,
			'AdminsOnlineCount'			=> $adminsOnlineCount,
			'teamspeakData'				=> $this->GetTeamspeakData(),
			'messages'					=> ($Messages > 0) ? (($Messages == 1) ? $LNG['ov_have_new_message'] : sprintf($LNG['ov_have_new_messages'], pretty_number($Messages))): false,
			'planet_diameter'			=> pretty_number($PLANET['diameter']),
			'planet_field_current' 		=> $PLANET['field_current'],
			'planet_field_max' 			=> CalculateMaxPlanetFields($PLANET),
			'planet_temp_min' 			=> $PLANET['temp_min'],
			'planet_temp_max' 			=> $PLANET['temp_max'],
			// ✅ v5.5: ELIMINADO ref_active, ref_minpoints, RefLinks
			'chatOnline'				=> $chatOnline,
			'path'						=> HTTP_PATH,
			'allBoosters'				=> $allBoostersList,
			'activeBoosters'			=> $activeCount,
			'ovEvents'					=> $ovEvents,
			'raffles_widget'			=> $rafflesWidget,
			'raffles_count'				=> $rafflesCount,
			'raffles_hay'				=> count($rafflesWidget) > 0,
			'lottery_widget'			=> $lotteryWidget,
			'lottery_hay'				=> ($lotteryWidget !== null),
			'pve_widget'				=> $pveWidget,
			'pvp_widget'				=> $pvpWidget,
			'weekend_boost'				=> $weekendBoost,
			
			// ASTROIO v6.5 — Variables de Clima
			'clima_planeta'				=> $climaPlaneta,
			'clima_planeta_previsto'	=> $climaPlanetaPrevisto,
			'clima_luna'				=> $climaLuna,
			'clima_luna_previsto'		=> $climaLunaPrevisto,
			
			// ASTROIO v6.6 — Buff Climático
			'buff_activo'				=> $buffActivo,
			'buff_segundos_restantes'	=> $buffSegundosRestantes,
			'buff_horas_restantes'		=> $buffHorasRestantes,
			'buff_minutos_restantes'	=> $buffMinutosRestantes,
			'buff_nombre_legible'		=> $buffNombreLegible,
		));
		
		$this->display('page.overview.default.tpl');
	}
	
	function actions() 
	{
		global $LNG, $PLANET;

		$this->initTemplate();
		$this->setWindow('popup');

		$this->assign(array(
			'ov_security_confirm'		=> sprintf($LNG['ov_security_confirm'], $PLANET['name'].' ['.$PLANET['galaxy'].':'.$PLANET['system'].':'.$PLANET['planet'].']'),
		));
		$this->display('page.overview.actions.tpl');
	}
	
	function rename() 
	{
		global $LNG, $PLANET;

		$newname        = HTTP::_GP('name', '', UTF8_SUPPORT);
		if (!empty($newname))
		{
			if (!PlayerUtil::isNameValid($newname)) {
				$this->sendJSON(array('message' => $LNG['ov_newname_specialchar'], 'error' => true));
			} else {
				$db = Database::get();
                $sql = "UPDATE %%PLANETS%% SET name = :newName WHERE id = :planetID;";
                $db->update($sql, array(
                    ':newName'  => $newname,
                    ':planetID' => $PLANET['id']
                ));

                $this->sendJSON(array('message' => $LNG['ov_newname_done'], 'error' => false));
			}
		}
	}
	
	function delete() 
	{
		global $LNG, $PLANET, $USER;
		$password	= HTTP::_GP('password', '', true);
		
		if (!empty($password))
		{
            $db = Database::get();
            $sql = "SELECT COUNT(*) as state FROM %%FLEETS%% WHERE
                      (fleet_owner = :userID AND (fleet_start_id = :planetID OR fleet_start_id = :lunaID)) OR
                      (fleet_target_owner = :userID AND (fleet_end_id = :planetID OR fleet_end_id = :lunaID));";
            $IfFleets = $db->selectSingle($sql, array(
                ':userID'   => $USER['id'],
                ':planetID' => $PLANET['id'],
                ':lunaID'   => $PLANET['id_luna']
            ), 'state');

			if ($IfFleets > 0) {
				$this->sendJSON(array('message' => $LNG['ov_abandon_planet_not_possible']));
			} elseif ($USER['id_planet'] == $PLANET['id']) {
				$this->sendJSON(array('message' => $LNG['ov_principal_planet_cant_abanone']));
			} elseif (PlayerUtil::cryptPassword($password) != $USER['password']) {
				$this->sendJSON(array('message' => $LNG['ov_wrong_pass']));
			} else {
                if($PLANET['planet_type'] == 1) {
                    $sql = "UPDATE %%PLANETS%% SET destruyed = :time WHERE id = :planetID;";
                    $db->update($sql, array(
                        ':time'   => TIMESTAMP+ 86400,
                        ':planetID' => $PLANET['id'],
                    ));
                    $sql = "DELETE FROM %%PLANETS%% WHERE id = :lunaID;";
                    $db->delete($sql, array(
                        ':lunaID' => $PLANET['id_luna']
                    ));
                } else {
                    $sql = "UPDATE %%PLANETS%% SET id_luna = 0 WHERE id_luna = :planetID;";
                    $db->update($sql, array(
                        ':planetID' => $PLANET['id'],
                    ));
                    $sql = "DELETE FROM %%PLANETS%% WHERE id = :planetID;";
                    $db->delete($sql, array(
                        ':planetID' => $PLANET['id'],
                    ));
                }

                Session::load()->planetId     = $USER['id_planet'];
				$this->sendJSON(array('ok' => true, 'message' => $LNG['ov_planet_abandoned']));
			}
		}
	}
}