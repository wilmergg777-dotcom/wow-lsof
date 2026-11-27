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
 * AstroIO v1.1 (FIX ALIANZA):
 *  - Bloqueo: no se pueden lanzar misiles interplanetarios a miembros
 *    de tu propia alianza.
 *  - Añadida consulta a la BD para obtener ally_id del atacante y del
 *    defensor (la tabla de USERS no trae ally_id por defecto en
 *    GetUserByID()).
 *  - Excepciones:
 *      - Atacante sin alianza (ally_id = 0).
 *      - Defensor sin alianza (ally_id = 0).
 *      - Defensor fantasma PvE (id_owner >= 900M) — por seguridad.
 *      - Defensor es el propio atacante.
 *  - Mensaje: $LNG['fl_own_ally'] ('¡No puedes atacar a miembros de tu
 *    propia alianza!') — ya existe en language/es/INGAME.php.
 *
 * AstroIO v1.2 (SOPORTE MISIL 504 — ANTIMATERIA):
 *  - El misil 504 (Misil Antimateria) ahora se lanza desde esta misma
 *    página, igual que el 503 (Interplanetario clásico).
 *  - Detección automática: si el jugador tiene 504 disponibles y cumple
 *    sus requisitos, se lanza el 504 (más potente, destruye 3 defensas).
 *    Si no, se lanza el 503 (destruye 1 defensa).
 *  - Requisitos validados según el misil elegido:
 *      503 → Silo 4, Impulso 1
 *      504 → Silo 8, Impulso 5, Hiperespacial 3, Militar 12, Blindaje 10,
 *            Hangar 6
 *  - Rango calculado con la tech correcta:
 *      503 → Motor de Impulso (tech 117)
 *      504 → Propulsor Hiperespacial (tech 118)
 *  - El envío usa el ID del misil detectado ($misilID) en lugar de 503
 *    hardcodeado.
 *  - El 505 (Interceptor Avanzado) NO se toca aquí: es defensivo y no
 *    se lanza. Solo intercepta cuando te atacan.
 *  - El FIX ALIANZA de v1.1 queda 100% intacto.
 */

class ShowFleetMissilePage extends AbstractGamePage
{
	public static $requireModule = MODULE_MISSILEATTACK;

	function __construct() 
	{
		parent::__construct();
	}
	
	public function show()
	{	
		global $USER, $PLANET, $LNG, $reslist, $resource;
		
		// ============================================
		// ASTROIO v1.2 — DETECCIÓN AUTOMÁTICA DEL MISIL
		// ------------------------------------------------------------
		// Lee los contadores de misiles 503 y 504 del planeta.
		// Decide cuál lanzar según disponibilidad + requisitos.
		// Preferencia: 504 si está disponible, si no 503.
		// ============================================
		$missileCount503 = (int) $PLANET['interplanetary_misil'];
		$missileCount504 = (int) $PLANET['antimatter_misil'];

		// ¿Cumple TODOS los requisitos para lanzar el 504?
		$canLaunch504 = (
			$missileCount504 > 0
			&& $PLANET['silo'] >= 8
			&& $PLANET['hangar'] >= 6
			&& $USER['impulse_motor_tech'] >= 5
			&& $USER['hyperspace_motor_tech'] >= 3
			&& $USER['military_tech'] >= 12
			&& $USER['shield_tech'] >= 10
		);

		// ¿Cumple los requisitos para lanzar el 503?
		$canLaunch503 = (
			$missileCount503 > 0
			&& $PLANET['silo'] >= 4
			&& $USER['impulse_motor_tech'] >= 1
		);

		// Elegir el misil a lanzar
		if ($canLaunch504) {
			$misilID         = 504;
			$missileCount    = $missileCount504;
			$requiredSilo    = 8;
			$requiredHangar  = 6;
			$requiredImpulse = 5;
			$requiredHyper   = 3;
			$requiredMilitary= 12;
			$requiredShield  = 10;
			$rangeTechID     = 118; // Propulsor Hiperespacial
		} elseif ($canLaunch503) {
			$misilID         = 503;
			$missileCount    = $missileCount503;
			$requiredSilo    = 4;
			$requiredHangar  = 0;
			$requiredImpulse = 1;
			$requiredHyper   = 0;
			$requiredMilitary= 0;
			$requiredShield  = 0;
			$rangeTechID     = 117; // Motor de Impulso
		} else {
			// No tiene ningún misil lanzable: usar 503 como referencia
			// para que los mensajes de error sean los del 503 (los más
			// conocidos por el jugador) y mostrar el motivo correcto.
			$misilID         = 503;
			$missileCount    = max($missileCount503, $missileCount504);
			$requiredSilo    = 4;
			$requiredHangar  = 0;
			$requiredImpulse = 1;
			$requiredHyper   = 0;
			$requiredMilitary= 0;
			$requiredShield  = 0;
			$rangeTechID     = 117;
		}
		// ============================================
		// FIN ASTROIO v1.2 — DETECCIÓN
		// ============================================

		$targetGalaxy 		= HTTP::_GP('galaxy', 0);
		$targetSystem 		= HTTP::_GP('system', 0);
		$targetPlanet 		= HTTP::_GP('planet', 0);
		$targetType 		= HTTP::_GP('type', 0);
		$anz 				= min(HTTP::_GP('SendMI',0), $missileCount);
		$primaryTarget 		= HTTP::_GP('Target', 0);

        $db					= Database::get();

        $sql				= "SELECT id, id_owner FROM %%PLANETS%%
        WHERE universe = :universe AND galaxy = :targetGalaxy
        AND system = :targetSystem AND planet = :targetPlanet AND planet_type = :targetType;";

        $target = $db->selectSingle($sql, array(
            ':universe' => Universe::current(),
            ':targetGalaxy' => $targetGalaxy,
            ':targetSystem' => $targetSystem,
            ':targetPlanet' => $targetPlanet,
            ':targetType'   => $targetType
        ));

        // ============================================
        // ASTROIO v1.2 — Rango según tech del misil elegido
        // ============================================
        $Range				= FleetFunctions::GetMissileRange($USER[$resource[$rangeTechID]]);
		$systemMin			= $PLANET['system'] - $Range;
		$systemMax			= $PLANET['system'] + $Range;
		
		$error				= "";
		
		if (IsVacationMode($USER))
			$error = $LNG['fl_vacation_mode_active'];
		elseif ($PLANET['silo'] < $requiredSilo)
			$error = $LNG['ma_silo_level'];
		elseif ($USER['impulse_motor_tech'] < $requiredImpulse)
			$error = $LNG['ma_impulse_drive_required'];
		elseif ($targetGalaxy != $PLANET['galaxy'] || $targetSystem < $systemMin || $targetSystem > $systemMax)
			$error = $LNG['ma_not_send_other_galaxy'];
		elseif (!$target)
			$error = $LNG['ma_planet_doesnt_exists'];
		elseif (!in_array($primaryTarget, $reslist['defense']) && $primaryTarget != 0)
			$error = $LNG['ma_wrong_target'];
		elseif ($missileCount == 0)
			$error = $LNG['ma_no_missiles'];
		elseif ($anz <= 0)
			$error = $LNG['ma_add_missile_number'];

		$targetUser	   	= GetUserByID($target['id_owner'], array('onlinetime', 'banaday', 'urlaubs_modus', 'authattack'));
		
		if (Config::get()->adm_attack == 1 && $targetUser['authattack'] > $USER['authlevel'])
			$error = $LNG['fl_admin_attack'];	
		elseif($targetUser['urlaubs_modus'])
			$error = $LNG['fl_in_vacation_player'];

		// ============================================
		// ASTROIO v1.1 — FIX ALIANZA (misiles entre aliados)
		// ------------------------------------------------------------
		// Bloqueo: no se pueden lanzar misiles interplanetarios a
		// miembros de tu propia alianza.
		//
		// Excepciones:
		//   - Atacante sin alianza (ally_id = 0).
		//   - Defensor sin alianza (ally_id = 0).
		//   - Defensor fantasma PvE (id_owner >= 900M).
		//   - Defensor es el propio atacante (ya bloqueado antes, pero por seguridad).
		//
		// Nota: GetUserByID() NO trae ally_id, así que hacemos la
		// consulta directa a la tabla USERS.
		// ============================================
		if (
			empty($error)
			&& !empty($target['id_owner'])
			&& (int) $target['id_owner'] < 900000000
			&& (int) $target['id_owner'] !== (int) $USER['id']
		) {
			$sql = "SELECT ally_id FROM %%USERS%% WHERE id = :userId LIMIT 1;";

			$attackerAllyId = $db->selectSingle($sql, array(
				':userId' => (int) $USER['id']
			), 'ally_id');

			$defenderAllyId = $db->selectSingle($sql, array(
				':userId' => (int) $target['id_owner']
			), 'ally_id');

			if (
				!empty($attackerAllyId)
				&& (int) $attackerAllyId > 0
				&& !empty($defenderAllyId)
				&& (int) $defenderAllyId > 0
				&& (int) $attackerAllyId === (int) $defenderAllyId
			) {
				$error = isset($LNG['fl_own_ally']) ? $LNG['fl_own_ally'] : 'No puedes atacar a miembros de tu propia alianza.';
			}
		}
		// ============================================
		// FIN ASTROIO v1.1 — FIX ALIANZA
		// ============================================
			
		$sql = "SELECT total_points FROM %%STATPOINTS%% WHERE stat_type = '1' AND id_owner = :ownerId;";
        $User2Points = $db->selectSingle($sql, array(
            ':ownerId'  => $target['id_owner']
        ));

		$sql	= 'SELECT total_points
		FROM %%STATPOINTS%%
		WHERE id_owner = :userId AND stat_type = :statType';

		$USER	+= Database::get()->selectSingle($sql, array(
			':userId'	=> $USER['id'],
			':statType'	=> 1
		));

        $IsNoobProtec	= CheckNoobProtec($USER, $User2Points, $targetUser);
			
		if ($IsNoobProtec['NoobPlayer'])
			$error = $LNG['fl_week_player'];
		elseif ($IsNoobProtec['StrongPlayer'])
			$error = $LNG['fl_strong_player'];		
				
		if ($error != "")
		{
			$this->printMessage($error);
		}
		
		$Duration		= FleetFunctions::GetMIPDuration($PLANET['system'], $targetSystem);

		$DefenseLabel 	= ($primaryTarget == 0) ? $LNG['ma_all'] : $LNG['tech'][$primaryTarget];

		// ============================================
		// ASTROIO v1.2 — Enviar el misil detectado (503 o 504)
		// ------------------------------------------------------------
		// Antes estaba hardcodeado: array(503 => $anz)
		// Ahora usa el ID del misil que el jugador tiene disponible.
		// ============================================
		$fleetArray		= array($misilID => $anz);
		// ============================================
		
		$fleetStartTime	= TIMESTAMP + $Duration;
		$fleetStayTime	= $fleetStartTime;
		$fleetEndTime	= $fleetStartTime;
		
		$fleetResource	= array(
			901	=> 0,
			902	=> 0,
			903	=> 0,
		);
		
		FleetFunctions::sendFleet($fleetArray, 10, $USER['id'], $PLANET['id'], $PLANET['galaxy'], $PLANET['system'],
			$PLANET['planet'], $PLANET['planet_type'], $target['id_owner'], $target['id'], $targetGalaxy, $targetSystem,
			$targetPlanet, $targetType, $fleetResource, $fleetStartTime, $fleetStayTime, $fleetEndTime, 0, $primaryTarget);

		$this->printMessage("<b>".$anz."</b>". $LNG['ma_missiles_sended'].$DefenseLabel);
	}
}