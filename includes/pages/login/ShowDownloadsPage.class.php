<?php
/**
 * ShowDownloadsPage — Página de descargas de la PORTADA / LOGIN
 * AstroIO v2.4.11
 *
 * URL: index.php?page=downloads
 *
 * ✅ v2.4.11 — LEE apk/version.json DIRECTO, igual que la página de
 *    descargas del juego (ShowDescargasPage): las versiones y URLs de
 *    la APK y de los launchers (Setup Windows, launcher portable,
 *    launcher Linux y el script instalar-linux.sh) salen del JSON en
 *    cada render.
 *
 *    Antes las versiones estaban ESCRITAS A MANO en el .tpl y se
 *    quedaban viejas (se anunciaba una versión anterior a la
 *    publicada). Ahora el workflow de GitHub Actions regenera
 *    apk/version.json en cada compilación con versiones, URLs y
 *    SHA-256 reales, así que esta página SIEMPRE muestra lo publicado
 *    sin tocar código. Si el JSON no existe en el servidor, se usan
 *    los valores de respaldo definidos más abajo.
 *
 *    Además muestra el tamaño real de cada archivo si está en el
 *    servidor (mismo criterio que la página del juego).
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowDownloadsPage extends AbstractLoginPage
{
	// Valores de respaldo si el servidor no tiene apk/version.json
	private static $DEFAULTS = array(
		'apkVersion'   => '2.4.4',
		'apkUrl'       => 'https://astroio.duckdns.org/apk/AstroIO.apk',
		'winVersion'   => '2.4.11',
		'setupUrl'     => 'https://astroio.duckdns.org/launcher/AstroIO-Setup-Windows.exe',
		'winUrl'       => 'https://astroio.duckdns.org/launcher/AstroIO-Launcher-windows.exe',
		'linuxVersion' => '2.4.11',
		'linuxUrl'     => 'https://astroio.duckdns.org/launcher/AstroIO-Launcher-linux',
	);

	public function __construct()
	{
		parent::__construct();
		$this->setWindow('normal'); // fondo y menú del login
	}

	public function show()
	{
		$data = self::$DEFAULTS;

		// ─────────────────────────────────────────────────────────
		// 1) Leer apk/version.json de la raíz del dominio
		//    (la misma carpeta donde están game.php e index.php)
		// ─────────────────────────────────────────────────────────
		$jsonFile = ROOT_PATH.'apk/version.json';
		if (is_file($jsonFile)) {
			$json = json_decode((string) @file_get_contents($jsonFile), true);
			if (is_array($json)) {
				// Versión y URL de la APK (bloque principal del JSON)
				if (!empty($json['versionName'])) {
					$data['apkVersion'] = (string) $json['versionName'];
				}
				if (!empty($json['url'])) {
					$data['apkUrl'] = (string) $json['url'];
				}
				// Versión de los launchers (bloque "launcher", INDEPENDIENTE
				// de la APK: Windows y Linux van siempre a la par)
				if (!empty($json['launcher']['versionName'])) {
					$data['winVersion']   = (string) $json['launcher']['versionName'];
					$data['linuxVersion'] = (string) $json['launcher']['versionName'];
				}
				// Setup recomendado en Windows (instalador completo)
				if (!empty($json['launcher']['windowsInstaller']['url'])) {
					$data['setupUrl'] = (string) $json['launcher']['windowsInstaller']['url'];
				}
				// Launcher portable de Windows (sin instalar)
				if (!empty($json['launcher']['windows']['url'])) {
					$data['winUrl'] = (string) $json['launcher']['windows']['url'];
				}
				// Launcher Linux
				if (!empty($json['launcher']['linux']['url'])) {
					$data['linuxUrl'] = (string) $json['launcher']['linux']['url'];
				}
			}
		}

		// instalar-linux.sh vive en la MISMA carpeta del servidor que el
		// launcher Linux: se deriva de su URL (no está en version.json).
		$data['linuxShUrl'] = preg_replace(
			'#/AstroIO-Launcher-linux([?#].*)?$#',
			'/instalar-linux.sh',
			$data['linuxUrl']
		);

		// ─────────────────────────────────────────────────────────
		// 2) Tamaño real de cada archivo si está en el servidor
		// ─────────────────────────────────────────────────────────
		$data['apkSize']     = self::fileSizeMB(ROOT_PATH.'apk/AstroIO.apk');
		$data['setupSize']   = self::fileSizeMB(ROOT_PATH.'launcher/AstroIO-Setup-Windows.exe');
		$data['winSize']     = self::fileSizeMB(ROOT_PATH.'launcher/AstroIO-Launcher-windows.exe');
		$data['linuxSize']   = self::fileSizeMB(ROOT_PATH.'launcher/AstroIO-Launcher-linux');
		$data['linuxShSize'] = self::fileSizeKB(ROOT_PATH.'launcher/instalar-linux.sh');

		$this->assign($data);
		$this->display('page.downloads.default.tpl');
	}

	/**
	 * Devuelve el tamaño del archivo en MB (texto), o '' si no existe.
	 * (Mismo criterio que ShowDescargasPage en el juego.)
	 */
	private static function fileSizeMB($path)
	{
		if (!is_file($path)) {
			return '';
		}
		$bytes = (int) filesize($path);
		if ($bytes <= 0) {
			return '';
		}
		return round($bytes / 1048576, 1).' MB';
	}

	/**
	 * Devuelve el tamaño del archivo en KB (texto), o '' si no existe.
	 */
	private static function fileSizeKB($path)
	{
		if (!is_file($path)) {
			return '';
		}
		$bytes = (int) filesize($path);
		if ($bytes <= 0) {
			return '';
		}
		return round($bytes / 1024, 0).' KB';
	}
}
