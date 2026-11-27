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
 * AstroIO v3.1:
 *  - DM Extras (701-707) se pagan con NTX-20 ($USER['ntx20'])
 *  - Oficiales (601-619) se pagan con Materia Oscura ($USER[$resource[921]])
 *    (615 Emperador, 616 Astrónomo, 617 Comerciante, 618 Navegante, 619 Supervisor)
 *  - El UPDATE guarda ntx20 y darkmatter en la BD para persistir
 *
 * AstroIO v3.2 (FIX):
 *  - Verificacion explicita de saldo NTX-20 antes de comprar DM Extras
 *  - Verificacion explicita de saldo MO antes de subir Oficiales
 *  - Uso de max(0, ...) como seguro adicional para nunca dejar negativos
 *
 * AstroIO v3.3 (FIX):
 *  - DM Extras: si no hay suficiente NTX-20, $buyable = false
 *    (asi el template NO muestra el boton de compra)
 *
 * AstroIO v3.4 (FIX):
 *  - DM Extras: se agrega variable 'is_active' al array $darkmatterList
 *    para que el template pueda OCULTAR el boton "Reclutar" cuando el
 *    potenciador ya esta activo (hasta que expire el tiempo).
 *
 * AstroIO v4.0 (MISTIC):
 *  - Se agrega la logica para el sistema de 15 Elementos Misticos.
 *  - Niveles 1 al 5 cuestan Materia Oscura (1.000 a 1.400 MO).
 *  - Niveles 6 al 10 cuestan NTX-20 (7, 10, 13, 16, 20 NTX-20).
 *
 * AstroIO v4.1 (DOBLE RIEL):
 *  - NEW: getPlayerMethod() detecta CUP o QVAPAY.
 *  - DM Extras: si es QVAPAY, el precio se duplica (x2) y se descuenta
 *    de `untx20`.
 *  - Misticos (niveles 6-10): si es QVAPAY, el precio se duplica (x2) y
 *    se descuenta de `untx20`.
 *  - show(): envia $moneda, $ntx_actual, y ajusta los precios al doble
 *    para el template.
 */

class ShowOfficierPage extends AbstractGamePage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
	}

	/**
	 * 🆕 v4.1 — Detecta el método de pago del jugador ('CUP' o 'QVAPAY').
	 */
	private function getPlayerMethod($userId)
	{
		$db = Database::get();
		$prefix = defined('DB_PREFIX') ? DB_PREFIX : 'uni1_';

		try {
			$row = $db->selectSingle(
				"SELECT metodo_retiro FROM `".$prefix."users` WHERE id = :uid LIMIT 1",
				array(':uid' => (int)$userId)
			);
			return ($row && $row['metodo_retiro'] === 'QVAPAY') ? 'QVAPAY' : 'CUP';
		} catch (Exception $e) {
			return 'CUP';
		}
	}

	public function UpdateExtra($Element)
	{
		global $PLANET, $USER, $resource, $pricelist;
		
		$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element);
		$method			= $this->getPlayerMethod($USER['id']);
		$isIntl			= ($method === 'QVAPAY');
		
		if (!BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources)) {
			return;
		}

		// ============================================
		// ASTROIO-FIX v3.2 — Verificacion explicita de saldo
		// ============================================
		$costNtx = isset($costResources[921]) ? (int)$costResources[921] : 0;
		$costNtxFinal = $isIntl ? ($costNtx * 2) : $costNtx;
		$colBalance = $isIntl ? 'untx20' : 'ntx20';

		if ($costNtxFinal > 0 && (int)$USER[$colBalance] < $costNtxFinal) {
			return;
		}
		// ============================================
			
		$USER[$resource[$Element]]	= max($USER[$resource[$Element]], TIMESTAMP) + $pricelist[$Element]['time'];
			
		if(isset($costResources[901])) { $PLANET[$resource[901]]	-= $costResources[901]; }
		if(isset($costResources[902])) { $PLANET[$resource[902]]	-= $costResources[902]; }
		if(isset($costResources[903])) { $PLANET[$resource[903]]	-= $costResources[903]; }
		
		if($costNtxFinal > 0) {
			$USER[$colBalance] = max(0, $USER[$colBalance] - $costNtxFinal);
		}
		if(isset($costResources[931]) && !empty($resource[931])) { $USER[$resource[931]]	-= $costResources[931]; }

		// ============================================
		// Guardar en la BD (ntx20 y untx20 segun metodo)
		// ============================================
		$sql	= 'UPDATE %%USERS%% SET
				'.$resource[$Element].' = :newTime,
				ntx20 = :ntx20,
				untx20 = :untx20,
				darkmatter = :darkmatter
				WHERE
				id = :userId;';

		Database::get()->update($sql, array(
			':newTime'		=> $USER[$resource[$Element]],
			':ntx20'		=> $USER['ntx20'] ?? 0,
			':untx20'		=> $USER['untx20'] ?? 0,
			':darkmatter'	=> $USER['darkmatter'],
			':userId'		=> $USER['id']
		));
	}

	public function UpdateOfficier($Element)
	{
		global $USER, $PLANET, $resource, $pricelist;
		
		$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element);
			
		if (!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $Element) 
			|| !BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources) 
			|| $pricelist[$Element]['max'] <= $USER[$resource[$Element]]) {
			return;
		}

		// Verificacion explicita de saldo MO
		if (isset($costResources[921]) && $USER[$resource[921]] < $costResources[921]) {
			return;
		}
		
		$USER[$resource[$Element]]	+= 1;
		
		if(isset($costResources[901])) { $PLANET[$resource[901]]	-= $costResources[901]; }
		if(isset($costResources[902])) { $PLANET[$resource[902]]	-= $costResources[902]; }
		if(isset($costResources[903])) { $PLANET[$resource[903]]	-= $costResources[903]; }
		if(isset($costResources[921])) { $USER[$resource[921]] = max(0, $USER[$resource[921]] - $costResources[921]); }

		$sql	= 'UPDATE %%USERS%% SET
		'.$resource[$Element].' = :newTime,
		darkmatter = :darkmatter
		WHERE
		id = :userId;';

		Database::get()->update($sql, array(
			':newTime'		=> $USER[$resource[$Element]],
			':darkmatter'	=> $USER['darkmatter'],
			':userId'		=> $USER['id']
		));
	}

	// ============================================
	// ASTROIO v4.1 — LÓGICA MÍSTICOS (DOBLE RIEL)
	// ============================================
		public function BuyMistic($itemID)
	{
		global $USER;
		$db = Database::get();

		// Verificar que el item exista
		$item = $db->selectSingle("SELECT * FROM %%MISTIC_ITEMS%% WHERE id = :id", array(':id' => $itemID));
		if (!$item) return;

		// Obtener nivel actual del jugador
		$userItem = $db->selectSingle("SELECT level FROM %%USERS_MISTIC%% WHERE user_id = :uid AND mistic_id = :mid", array(':uid' => $USER['id'], ':mid' => $itemID));
		$level = $userItem ? (int)$userItem['level'] : 0;

		if ($level >= 10) return;

		$nextLevel = $level + 1;
		
		// 🆕 Lógica de precios basada en el cost_base_mo (1000 o 800)
		if ($nextLevel <= 5) {
			// Niveles 1 al 5: MO escalando con 1.75
			$cost = floor($item['cost_base_mo'] * pow(1.75, $nextLevel - 1));
			
			if ($USER['darkmatter'] < $cost) return;
			
			$USER['darkmatter'] -= $cost;
			$db->update("UPDATE %%USERS%% SET darkmatter = darkmatter - :cost WHERE id = :uid", array(':cost' => $cost, ':uid' => $USER['id']));
		} else {
			// Niveles 6 al 10: NTX-20 escalando con 1.75
			// Si la base es 800, el NTX inicial es 19. Si es 1000, es 23.
			$ntxBase = ($item['cost_base_mo'] == 800) ? 19 : 23;
			$costBase = floor($ntxBase * pow(1.75, $nextLevel - 6));
			
			$method = $this->getPlayerMethod($USER['id']);
			$isIntl = ($method === 'QVAPAY');
			$colBalance = $isIntl ? 'untx20' : 'ntx20';
			
			$costFinal = $isIntl ? ($costBase * 2) : $costBase;
			
			if ((int)($USER[$colBalance] ?? 0) < $costFinal) return;
			
			$USER[$colBalance] = max(0, (int)$USER[$colBalance] - $costFinal);
			$db->update(
				"UPDATE %%USERS%% SET `".$colBalance."` = `".$colBalance."` - :cost WHERE id = :uid",
				array(':cost' => $costFinal, ':uid' => $USER['id'])
			);
		}

		// Guardar o actualizar el nivel
		if ($userItem) {
			$db->update("UPDATE %%USERS_MISTIC%% SET level = :lvl WHERE user_id = :uid AND mistic_id = :mid", array(':lvl' => $nextLevel, ':uid' => $USER['id'], ':mid' => $itemID));
		} else {
			$db->insert("INSERT INTO %%USERS_MISTIC%% (user_id, mistic_id, level) VALUES (:uid, :mid, :lvl)", array(':uid' => $USER['id'], ':mid' => $itemID, ':lvl' => $nextLevel));
		}
	}
	// ============================================
	
	public function show()
	{
		global $USER, $PLANET, $resource, $reslist, $LNG, $pricelist;
		
		$updateID	  = HTTP::_GP('id', 0);
		$action       = HTTP::_GP('action', '');
		$misticItemID = HTTP::_GP('item_id', 0);
				
		if ($_SERVER['REQUEST_METHOD'] === 'POST' && $USER['urlaubs_modus'] == 0)
		{
			// Lógica Oficiales y DM Extras
			if (!empty($updateID)) {
				if(isModuleAvailable(MODULE_OFFICIER) && in_array($updateID, $reslist['officier'])) {
					$this->UpdateOfficier($updateID);
				} elseif(isModuleAvailable(MODULE_DMEXTRAS) && in_array($updateID, $reslist['dmfunc'])) {
					$this->UpdateExtra($updateID);
				}
			}

			// Lógica Místicos
			if ($action === 'buy_mistic' && !empty($misticItemID)) {
				$this->BuyMistic($misticItemID);
			}
		}
		
		// 🆕 v4.1 — Detectar metodo y moneda
		$method = $this->getPlayerMethod($USER['id']);
		$moneda = ($method === 'QVAPAY') ? 'UNTX-20' : 'NTX-20';
		$isIntl = ($method === 'QVAPAY');
		$saldoActual = $isIntl ? (int)($USER['untx20'] ?? 0) : (int)($USER['ntx20'] ?? 0);
		
		$darkmatterList	= array();
		$officierList	= array();
		$misticList		= array();
		
		if(isModuleAvailable(MODULE_DMEXTRAS))
		{
			foreach($reslist['dmfunc'] as $Element)
			{
				if($USER[$resource[$Element]] > TIMESTAMP) {
					$this->tplObj->execscript("GetOfficerTime(".$Element.", ".($USER[$resource[$Element]] - TIMESTAMP).");");
				}
			
				$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element);
				$buyable			= BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources);
				$costOverflow		= BuildFunctions::getRestPrice($USER, $PLANET, $Element, $costResources);
				$elementBonus		= BuildFunctions::getAvalibleBonus($Element);

				// 🆕 v4.1 — Ajustar el precio del DM Extra al doble si es internacional
				// 🆕 FIX v4.4 — Cambiamos el ID de MO (921) a NTX (931)
				if (isset($costResources[921]) && $costResources[921] > 0) {
					$costNtxFinal = $isIntl ? ((int)$costResources[921] * 2) : (int)$costResources[921];
					
					unset($costResources[921]); // Quitamos la MO
					$costResources[931] = $costNtxFinal; // Ponemos el NTX-20 (931)

					// Movemos la validación del overflow asegurando que siempre exista la clave 931
					$costOverflow[931] = $costOverflow[921] ?? 0;
					unset($costOverflow[921]);

					if ((int)($USER[$isIntl ? 'untx20' : 'ntx20'] ?? 0) < $costNtxFinal) {
						$buyable = false;
					}
				}

				$isActive = ((int)$USER[$resource[$Element]] > (int)TIMESTAMP);

				$darkmatterList[$Element]	= array(
					'timeLeft'			=> max($USER[$resource[$Element]] - TIMESTAMP, 0),
					'costResources'		=> $costResources,
					'buyable'			=> $buyable,
					'time'				=> $pricelist[$Element]['time'],
					'costOverflow'		=> $costOverflow,
					'elementBonus'		=> $elementBonus,
					'is_active'			=> $isActive,
				);
			}
		}
		
		if(isModuleAvailable(MODULE_OFFICIER))
		{
			foreach($reslist['officier'] as $Element)
			{
				if (!BuildFunctions::isTechnologieAccessible($USER, $PLANET, $Element))
					continue;
					
				$costResources		= BuildFunctions::getElementPrice($USER, $PLANET, $Element);
				$buyable			= BuildFunctions::isElementBuyable($USER, $PLANET, $Element, $costResources);
				$costOverflow		= BuildFunctions::getRestPrice($USER, $PLANET, $Element, $costResources);
				$elementBonus		= BuildFunctions::getAvalibleBonus($Element);
				
				$shortDesc = isset($LNG['shortDescription'][$Element]) ? $LNG['shortDescription'][$Element] : '';
				
				if (!empty($shortDesc) && (strpos($shortDesc, '%s') !== false || strpos($shortDesc, '%d') !== false)) {
					
					$bonusValue = 0;
					if (!empty($elementBonus)) {
						$firstBonus = reset($elementBonus);
						$bonusValue = abs($firstBonus[0] * 100);
					}
					
					$maxLevel = $pricelist[$Element]['max'];
					
					$numPlaceholders = substr_count($shortDesc, '%s') + substr_count($shortDesc, '%d');
					
					if ($numPlaceholders >= 2) {
						$shortDesc = sprintf($shortDesc, $bonusValue, $maxLevel);
					} elseif ($numPlaceholders == 1) {
						$shortDesc = sprintf($shortDesc, $bonusValue);
					}
					
					$LNG['shortDescription'][$Element] = $shortDesc;
				}
				
				$officierList[$Element]	= array(
					'level'				=> $USER[$resource[$Element]],
					'maxLevel'			=> $pricelist[$Element]['max'],
					'costResources'		=> $costResources,
					'buyable'			=> $buyable,
					'costOverflow'		=> $costOverflow,
					'elementBonus'		=> $elementBonus,
				);
			}
		}

		// ============================================
		// ASTROIO v4.1 — CARGAR DATOS DE MÍSTICOS
		// ============================================
		$db = Database::get();
		$items = $db->select("SELECT * FROM %%MISTIC_ITEMS%% ORDER BY id ASC");
		
		if (!empty($items)) {
			$userItemsQuery = $db->select("SELECT mistic_id, level FROM %%USERS_MISTIC%% WHERE user_id = :uid", array(':uid' => $USER['id']));
			$userItems = array();
			foreach($userItemsQuery as $row) {
				$userItems[$row['mistic_id']] = (int)$row['level'];
			}
			foreach($items as $item) {
				$mId = $item['id'];
				$lvl = isset($userItems[$mId]) ? $userItems[$mId] : 0;
				
				$nextLevel = $lvl + 1;
				$costNext = 0;
				$currencyNext = '';
				
				if ($nextLevel <= 10) {
					if ($nextLevel <= 5) {
						$costNext = floor($item['cost_base_mo'] * pow(1.75, $nextLevel - 1));
						$currencyNext = '🌌'; // Materia Oscura
					} else {
						$ntxBase = ($item['cost_base_mo'] == 800) ? 19 : 23;
						$costBase = floor($ntxBase * pow(1.75, $nextLevel - 6));
						$costNext = $isIntl ? ($costBase * 2) : $costBase;
						$currencyNext = '💲'; // NTX-20 o UNTX-20
					}
				}

				$misticList[$mId] = array(
					'id'            => $mId,
					'name'          => $item['name'],
					'level'         => $lvl,
					'maxLevel'      => 10,
					'costNext'      => $costNext,
					'currencyNext'  => $currencyNext,
					'bonus'         => json_decode($item['bonus_json'], true),
					'is_max'        => ($lvl >= 10)
				);
			}
		}
		// ============================================
		
		$this->assign(array(
			'officierList'		=> $officierList,
			'darkmatterList'	=> $darkmatterList,
			'misticList'		=> $misticList,

			// 🆕 v4.1 — Doble riel
			'moneda'			=> $moneda,
			'metodo_retiro'		=> $method,
			'es_internacional'	=> $isIntl,
			'ntx_actual'		=> $saldoActual,

			'of_dm_trade'		=> 'Tienda de Bonus',
		));
		
		$this->display('page.officier.default.tpl');
	}
}
?>