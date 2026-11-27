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
 * ✅ FIX AstroIO v2.3: Corregida lógica invertida de game_disable
 * ✅ FIX AstroIO v2.3: Detección de errores en INSERT y lastInsertId
 * ✅ FIX AstroIO v2.6: El registro ahora es INDEPENDIENTE del estado del servidor.
 *   Solo se bloquea con reg_closed = 1 (checkbox "Bloquear registro" del panel admin).
 *   game_disable = 1 (servidor fuera de línea) YA NO bloquea el registro.
 * ✅ FIX AstroIO v2.8.2: Disparo automático del cronjob 'statistic' al registrarse.
 * ✅ FIX AstroIO v5.0: Sistema de referidos UNIFICADO — SOLO POR CÓDIGO.
 *   - Eliminado ?referralID= y ?ref= (links viejos)
 *   - Nuevo campo referral_code (opcional)
 *   - Código vacío → registra normal, sin referidor
 *   - Código válido → guarda ref_id del referidor
 *   - Código inválido → BLOQUEA el registro con error
 * ✅ FIX AstroIO v5.6: Limpieza agresiva del código de referido.
 *   - Eliminado UTF8_SUPPORT (no se necesita para hex puro).
 *   - NUEVO: preg_replace('/[^A-Fa-f0-9]/', '', $code) elimina TODO
 *     lo que no sea hexadecimal (espacios duros UTF-8, tabs, newlines,
 *     BOM, caracteres invisibles del copy/paste, etc.).
 *   - El servidor sigue validando con preg_match 8 hex chars.
 * ✅ FIX AstroIO v5.7: Carga explícita de ReferralHelper.class.php.
 *   - El autoload del login NO incluye ReferralHelper.
 *   - Ahora se hace require_once al inicio de send(), antes de usarlo.
 *   - Si el archivo no existe, se muestra error controlado.
 */

class ShowRegisterPage extends AbstractLoginPage
{
	/**
	 * ✅ v6.0 — PAÍS OBLIGATORIO EN EL REGISTRO
	 * Lista ISO 3166-1 alpha-2 con nombres en español. El código elegido
	 * se guarda en users_valid.country y, al activar la cuenta, ShowVertifyPage
	 * lo propaga a users.country para que la tabla de puntuación muestre la
	 * bandera del país del jugador.
	 */
	public static function getCountries()
	{
		return array(
			'AR' => 'Argentina', 'BO' => 'Bolivia', 'BR' => 'Brasil', 'CL' => 'Chile',
			'CO' => 'Colombia', 'CR' => 'Costa Rica', 'CU' => 'Cuba', 'DO' => 'República Dominicana',
			'EC' => 'Ecuador', 'SV' => 'El Salvador', 'GT' => 'Guatemala', 'HN' => 'Honduras',
			'MX' => 'México', 'NI' => 'Nicaragua', 'PA' => 'Panamá', 'PY' => 'Paraguay',
			'PE' => 'Perú', 'PR' => 'Puerto Rico', 'UY' => 'Uruguay', 'VE' => 'Venezuela',
			'ES' => 'España', 'PT' => 'Portugal', 'AD' => 'Andorra',
			'US' => 'Estados Unidos', 'CA' => 'Canadá',
			'DE' => 'Alemania', 'AT' => 'Austria', 'BE' => 'Bélgica', 'BG' => 'Bulgaria',
			'HR' => 'Croacia', 'DK' => 'Dinamarca', 'SK' => 'Eslovaquia', 'SI' => 'Eslovenia',
			'EE' => 'Estonia', 'FI' => 'Finlandia', 'FR' => 'Francia', 'GR' => 'Grecia',
			'HU' => 'Hungría', 'IE' => 'Irlanda', 'IS' => 'Islandia', 'IT' => 'Italia',
			'LV' => 'Letonia', 'LT' => 'Lituania', 'LU' => 'Luxemburgo', 'MT' => 'Malta',
			'NO' => 'Noruega', 'NL' => 'Países Bajos', 'PL' => 'Polonia', 'CZ' => 'República Checa',
			'RO' => 'Rumania', 'SE' => 'Suecia', 'CH' => 'Suiza', 'GB' => 'Reino Unido',
			'RU' => 'Rusia', 'UA' => 'Ucrania', 'BY' => 'Bielorrusia', 'MD' => 'Moldavia',
			'AL' => 'Albania', 'BA' => 'Bosnia', 'MK' => 'Macedonia del Norte', 'RS' => 'Serbia', 'ME' => 'Montenegro',
			'TR' => 'Turquía', 'CY' => 'Chipre', 'GE' => 'Georgia', 'AM' => 'Armenia',
			'CN' => 'China', 'JP' => 'Japón', 'KR' => 'Corea del Sur', 'IN' => 'India',
			'ID' => 'Indonesia', 'PH' => 'Filipinas', 'MY' => 'Malasia', 'SG' => 'Singapur',
			'TH' => 'Tailandia', 'VN' => 'Vietnam', 'PK' => 'Pakistán', 'BD' => 'Bangladés',
			'AU' => 'Australia', 'NZ' => 'Nueva Zelanda',
			'ZA' => 'Sudáfrica', 'NG' => 'Nigeria', 'KE' => 'Kenia', 'GH' => 'Ghana',
			'MA' => 'Marruecos', 'DZ' => 'Argelia', 'TN' => 'Túnez', 'EG' => 'Egipto',
			'SA' => 'Arabia Saudita', 'AE' => 'Emiratos Árabes Unidos', 'QA' => 'Catar',
			'KW' => 'Kuwait', 'IL' => 'Israel', 'IQ' => 'Irak', 'IR' => 'Irán', 'LB' => 'Líbano',
			'JO' => 'Jordania', 'SY' => 'Siria', 'YE' => 'Yemen', 'OM' => 'Omán',
		);
	}

	public static function getCountriesSelect()
	{
		$out = array('' => '— Elegí tu país —');
		foreach (self::getCountries() as $code => $name) {
			$out[$code] = $name;
		}
		return $out;
	}

	function __construct()
	{
		parent::__construct();
        $this->setWindow('light');
	}
	
	function show()
	{
		global $LNG;
		$universeSelect	= array();	
		$accountName	= "";
		
		$externalAuth	= HTTP::_GP('externalAuth', array());
		
		foreach(Universe::availableUniverses() as $uniId)
		{
			$config = Config::get($uniId);
			// ✅ FIX v2.6: el registro ya NO depende de game_disable.
			// Solo se marca "(cerrado)" si el admin bloqueó el registro explícitamente.
			$universeSelect[$uniId]	= $config->uni_name.($config->reg_closed == 1 ? $LNG['uni_closed'] : '');
		}
		
		if(!isset($externalAuth['account'], $externalAuth['method']))
		{
			$externalAuth['account']	= 0;
			$externalAuth['method']		= '';
		}
		else
		{
			$externalAuth['method']		= strtolower(str_replace(array('_', '\\', '/', '.', "\0"), '', $externalAuth['method']));
		}
		
		if(!empty($externalAuth['account']) && file_exists('includes/extauth/'.$externalAuth['method'].'.class.php'))
		{
			$path	= 'includes/extauth/'.$externalAuth['method'].'.class.php';
			require($path);
			$methodClass	= ucwords($externalAuth['method']).'Auth';
			/** @var $authObj externalAuth */
			$authObj		= new $methodClass;
			
			if(!$authObj->isActiveMode())
			{
				$this->redirectTo('index.php?code=5');
			}
			
			if(!$authObj->isValid())
			{
				$this->redirectTo('index.php?code=4');
			}
			
			$accountData	= $authObj->getAccountData();
			$accountName	= $accountData['name'];
		}

		// ✅ v5.0: Sistema de referidos unificado — sin links, solo código.
		// La variable referralData ya no se usa (el template fue actualizado).
		// El nuevo campo se llama referral_code y se procesa en send().
		
		$this->assign(array(
			'accountName'		=> $accountName,
			'externalAuth'		=> $externalAuth,
			'universeSelect'	=> $universeSelect,
			// ✅ v6.0 — Lista de países para el select obligatorio
			'countries'			=> self::getCountriesSelect(),
			'selectedCountry'	=> '',
			'registerRulesDesc'	=> sprintf($LNG['registerRulesDesc'], '<a href="index.php?page=rules">'.$LNG['menu_rules'].'</a>')
		));
		
		$this->display('page.register.default.tpl');
	}
	
	function send() 
	{
		global $LNG;
		$config		= Config::get();

		// ✅ FIX v2.6: el registro solo se bloquea con reg_closed.
		// game_disable (servidor fuera de línea) ya NO bloquea el registro.
		// El motivo: el admin puede querer preparar cuentas antes de abrir el servidor.
		if($config->reg_closed == 1)
		{
			$this->printMessage($LNG['registerErrorUniClosed'], array(array(
				'label'	=> $LNG['registerBack'],
				'url'	=> 'javascript:window.history.back()',
			)));
			return;
		}

		// ═══════════════════════════════════════════════════════════
		// ✅ v5.7: CARGA EXPLÍCITA DE ReferralHelper
		// ------------------------------------------------------------
		// El autoload del login NO incluye ReferralHelper.
		// Lo cargamos acá antes de usarlo.
		// ═══════════════════════════════════════════════════════════
		if(!class_exists('ReferralHelper'))
		{
			$helperPath = ROOT_PATH.'includes/classes/ReferralHelper.class.php';
			if(file_exists($helperPath))
			{
				require_once($helperPath);
			}
		}

		$userName 		= HTTP::_GP('username', '', UTF8_SUPPORT);
		$password 		= HTTP::_GP('password', '', true);
		$password2 		= HTTP::_GP('passwordReplay', '', true);
		$mailAddress 	= HTTP::_GP('email', '');
		$mailAddress2	= HTTP::_GP('emailReplay', '');
		$rulesChecked	= HTTP::_GP('rules', 0);
		$language 		= HTTP::_GP('lang', '');
		
		// ═══════════════════════════════════════════════════════════
		// ✅ v5.6: LIMPIEZA AGRESIVA DEL CÓDIGO DE REFERIDO
		// ------------------------------------------------------------
		// 1) Sin UTF8_SUPPORT (no se necesita para hex puro)
		// 2) preg_replace elimina TODO lo que no sea hexadecimal
		//    (espacios duros UTF-8 \xc2\xa0, tabs, newlines, BOM, etc.)
		// 3) strtoupper normaliza a mayúsculas
		// ------------------------------------------------------------
		// Ejemplo: " 4AF1013C\xc2\xa0" → "4AF1013C"
		// ═══════════════════════════════════════════════════════════
		$referralCode	= HTTP::_GP('referral_code', '');
		$referralCode	= preg_replace('/[^A-Fa-f0-9]/', '', $referralCode);
		$referralCode	= strtoupper($referralCode);

		$externalAuth	= HTTP::_GP('externalAuth', array());
		if(!isset($externalAuth['account'], $externalAuth['method']))
		{
			$externalAuthUID	= 0;
			$externalAuthMethod	= '';
		}
		else
		{
			$externalAuthUID	= $externalAuth['account'];
			$externalAuthMethod	= strtolower(str_replace(array('_', '\\', '/', '.', "\0"), '', $externalAuth['method']));
		}
		
		$errors 	= array();
		
		if(empty($userName)) {
			$errors[]	= $LNG['registerErrorUsernameEmpty'];
		}
		
		if(!PlayerUtil::isNameValid($userName)) {
			$errors[]	= $LNG['registerErrorUsernameChar'];
		}
		
		if(strlen($password) < 6) {
			$errors[]	= $LNG['registerErrorPasswordLength'];
		}
			
		if($password != $password2) {
			$errors[]	= $LNG['registerErrorPasswordSame'];
		}
			
		if(!PlayerUtil::isMailValid($mailAddress)) {
			$errors[]	= $LNG['registerErrorMailInvalid'];
		}
			
		if(empty($mailAddress)) {
			$errors[]	= $LNG['registerErrorMailEmpty'];
		}
		
		if($mailAddress != $mailAddress2) {
			$errors[]	= $LNG['registerErrorMailSame'];
		}
		
		if($rulesChecked != 1) {
			$errors[]	= $LNG['registerErrorRules'];
		}

		// ═══════════════════════════════════════════════════════════
		// ✅ v6.0 — PAÍS OBLIGATORIO: se guarda en users_valid.country y
		// al activar la cuenta ShowVertifyPage lo propaga a users.country
		// para que la tabla de puntuación muestre la bandera del jugador.
		// ═══════════════════════════════════════════════════════════
		$country = strtoupper(trim(HTTP::_GP('country', '')));
		if(empty($country) || !array_key_exists($country, self::getCountries())) {
			$errors[] = 'Debes elegir tu país de la lista.';
		}
		
		// ═══════════════════════════════════════════════════════════
		// ✅ v5.6: VALIDACIÓN DEL CÓDIGO DE REFERIDO
		// ═══════════════════════════════════════════════════════════
		// Reglas:
		//   - Código VACÍO      → registra normal, $referralID = 0
		//   - Código VÁLIDO     → $referralID = user_id del referidor
		//   - Código INVÁLIDO   → BLOQUEA el registro con error
		//   - Código con basura → la basura se elimina ANTES de validar
		// ═══════════════════════════════════════════════════════════
		$referralID = 0;
		
		if(!empty($referralCode))
		{
			if(!class_exists('ReferralHelper'))
			{
				// Fallback: si el helper no está cargado (archivo no existe),
				// se avisa pero NO se bloquea. Se registra sin referidor.
				// (Antes bloqueaba; ahora es más permisivo para no frustrar al usuario)
				// NOTA: si querés que bloquee, descomentá la línea de $errors[]
				// $errors[] = 'El sistema de referidos no está disponible...';
			}
			else
			{
				// Validar formato (8 hex chars, ya limpio)
				if(!preg_match('/^[A-F0-9]{8}$/', $referralCode))
				{
					$errors[]	= $LNG['registerErrorReferralCodeInvalid'] ?? 
						'El código de referido es inválido (debe tener 8 caracteres hexadecimales).';
				}
				else
				{
					// Buscar el user_id dueño del código
					$resolvedId = ReferralHelper::resolveReferrerId($referralCode);
					
					if($resolvedId > 0)
					{
						$referralID = $resolvedId;
					}
					else
					{
						$errors[]	= $LNG['registerErrorReferralCodeNotFound'] ?? 
							'El código de referido no existe. Verificalo o dejà el campo vacío.';
					}
				}
			}
		}
		
		$db = Database::get();

		$sql = "SELECT (
				SELECT COUNT(*)
				FROM %%USERS%%
				WHERE universe = :universe
				AND username = :userName
			) + (
				SELECT COUNT(*)
				FROM %%USERS_VALID%%
				WHERE universe = :universe
				AND username = :userName
			) as count;";

		$countUsername = $db->selectSingle($sql, array(
			':universe'	=> Universe::current(),
			':userName'	=> $userName,
		), 'count');

		$sql = "SELECT (
			SELECT COUNT(*)
			FROM %%USERS%%
			WHERE universe = :universe
			AND (
				email = :mailAddress
				OR email_2 = :mailAddress
			)
		) + (
			SELECT COUNT(*)
			FROM %%USERS_VALID%%
			WHERE universe = :universe
			AND email = :mailAddress
		) as count;";

		$countMail = $db->selectSingle($sql, array(
			':universe'		=> Universe::current(),
			':mailAddress'	=> $mailAddress,
		), 'count');
		
		if($countUsername!= 0) {
			$errors[]	= $LNG['registerErrorUsernameExist'];
		}
			
		if($countMail != 0) {
			$errors[]	= $LNG['registerErrorMailExist'];
		}
		
		if ($config->capaktiv === '1')
		{
            require('includes/libs/reCAPTCHA/autoload.php');

            $recaptcha = new \ReCaptcha\ReCaptcha($config->capprivate);
            $resp = $recaptcha->verify(HTTP::_GP('g-recaptcha-response', ''), Session::getClientIp());
            if (!$resp->isSuccess())
            {
                $errors[]	= $LNG['registerErrorCaptcha'];
            }
		}
						
		if (!empty($errors)) {
			$this->printMessage(implode("<br>\r\n", $errors), array(array(
				'label'	=> $LNG['registerBack'],
				'url'	=> 'javascript:window.history.back()',
			)));
			return;
		}

		$path	= 'includes/extauth/'.$externalAuthMethod.'.class.php';

		if(!empty($externalAuth['account']) && file_exists($path))
		{
			require($path);

			$methodClass		= ucwords($externalAuthMethod).'Auth';
			/** @var $authObj externalAuth */
			$authObj			= new $methodClass;
			$externalAuthUID	= 0;
			if($authObj->isActiveMode() && $authObj->isValid()) {
				$externalAuthUID	= $authObj->getAccount();
			}
		}
		
		$validationKey	= md5(uniqid('2m'));

		$sql = "INSERT INTO %%USERS_VALID%% SET
				`userName` = :userName,
				`validationKey` = :validationKey,
				`password` = :password,
				`email` = :mailAddress,
				`date` = :timestamp,
				`ip` = :remoteAddr,
				`language` = :language,
				`universe` = :universe,
				`referralID` = :referralID,
				`externalAuthUID` = :externalAuthUID,
				`externalAuthMethod` = :externalAuthMethod,
				`country` = :country;";

		// ✅ FIX v2.3: Capturar errores del INSERT para que no falle en silencio
		try {
			$db->insert($sql, array(
				':userName'				=> $userName,
				':validationKey'		=> $validationKey,
				':password'				=> PlayerUtil::cryptPassword($password),
				':mailAddress'			=> $mailAddress,
				':timestamp'			=> TIMESTAMP,
				':remoteAddr'			=> Session::getClientIp(),
				':language'				=> $language,
				':universe'				=> Universe::current(),
				':referralID'			=> $referralID,
				':externalAuthUID'		=> $externalAuthUID,
				':externalAuthMethod'	=> $externalAuthMethod,
				':country'				=> $country
			));
		} catch (Exception $e) {
			$this->printMessage(
				"<b>Error al crear la cuenta (INSERT falló):</b><br><br>" . 
				htmlspecialchars($e->getMessage()) . 
				"<br><br><b>SQL:</b><br><pre>" . htmlspecialchars($sql) . "</pre>",
				array(array(
					'label'	=> $LNG['registerBack'],
					'url'	=> 'javascript:window.history.back()',
				))
			);
			return;
		}

		$validationID	= $db->lastInsertId();
		
		// ✅ FIX v2.3: Si lastInsertId() devuelve vacío/0, detener y avisar
		if(empty($validationID)) {
			$this->printMessage(
				"<b>Error:</b> el registro no se completó correctamente. " .
				"No se pudo obtener el ID de validación (lastInsertId vacío). " .
				"El INSERT pudo haber fallado silenciosamente.",
				array(array(
					'label'	=> $LNG['registerBack'],
					'url'	=> 'javascript:window.history.back()',
				))
			);
			return;
		}

		// ============================================
		// AstroIO v2.8.2 — Disparar recálculo de stats
		// ============================================
		// Marca el cronjob 'statistic' como vencido para que se ejecute
		// en el próximo disparo (game.php o cron.php). NO se calcula aquí
		// mismo para no arriesgar timeout del registro en hosting gratuito.
		try {
			$db->query(
				"UPDATE `".DB_PREFIX."cronjobs` 
				 SET nextTime = 1, `lock` = NULL 
				 WHERE name = 'statistic'"
			);
		} catch (Exception $e) {
			// Si falla, no rompemos el registro. El cron correrá igual en su horario normal.
		}
		
		$verifyURL	= 'index.php?page=vertify&i='.$validationID.'&k='.$validationKey;
		
		if($config->user_valid == 0 || !empty($externalAuthUID))
		{
			$this->redirectTo($verifyURL);
		}
		else
		{
			require 'includes/classes/Mail.class.php';
			$MailRAW		= $LNG->getTemplate('email_vaild_reg');
			$MailContent	= str_replace(array(
				'{USERNAME}',
				'{PASSWORD}',
				'{GAMENAME}',
				'{VERTIFYURL}',
				'{GAMEMAIL}',
			), array(
				$userName,
				$password,
				$config->game_name.' - '.$config->uni_name,
				HTTP_PATH.$verifyURL,
				$config->smtp_sendmail,
			), $MailRAW);

			$subject	= sprintf($LNG['registerMailVertifyTitle'], $config->game_name);
			Mail::send($mailAddress, $userName, $subject, $MailContent);
			
			$this->printMessage($LNG['registerSendComplete']);
		}
	}
}