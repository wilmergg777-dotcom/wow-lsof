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
 * ✅ AstroIO v5.5 (REFERIDOS UNIFICADOS — SOLO CÓDIGO):
 *   - CRON NATIVO DESACTIVADO.
 *   - Antes: buscaba usuarios con `ref_bonus = 1` que hubieran alcanzado
 *     `ref_minpoints` y le pagaba `ref_bonus` (DM) al referidor, marcaba
 *     `ref_bonus = 0` y le enviaba un mensaje interno.
 *   - Ahora: NO HACE NADA. Se dejó la clase y la interfaz para que el
 *     cronjob registrado en `uni1_cronjobs` (name='referral') no rompa.
 *   - El nuevo sistema de referidos (ReferralHelper v5.0) paga
 *     3% NXT-20 al referidor al confirmar una inversión, y 3% al retirar.
 *   - Este archivo se puede eliminar en el futuro junto con la fila
 *     correspondiente en `uni1_cronjobs`.
 */

require_once 'includes/classes/cronjob/CronjobTask.interface.php';

class ReferralCronJob implements CronjobTask
{
	/**
	 * Cronjob nativo DESACTIVADO en AstroIO v5.5.
	 *
	 * El pago de bonos por referidos ahora lo maneja el sistema Wallet
	 * (WalletHelper / ReferralHelper v5.0), que acredita automáticamente
	 * el 3% en NXT-20 al referidor cuando su referido confirma una inversión.
	 *
	 * @return bool
	 */
	function run()
	{
		// ✅ v5.5: No-op intencional. El sistema viejo de referidos fue eliminado.
		return true;
	}
}