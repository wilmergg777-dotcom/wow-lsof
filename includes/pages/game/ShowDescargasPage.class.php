<?php
/**
 * ShowDescargasPage — Página de descargas DENTRO del juego
 * AstroIO v2.4.11
 *
 * URL: game.php?page=descargas
 *
 * Muestra al jugador los enlaces oficiales para descargar:
 *   - APK para Android (AstroIO.apk)
 *   - Launcher para Windows — Setup recomendado + portable
 *     (AstroIO-Setup-Windows.exe / AstroIO-Launcher-windows.exe)
 *   - Launcher para Linux + el script instalar-linux.sh
 *     (AstroIO-Launcher-linux / instalar-linux.sh)
 *
 * ✅ La versión de la APK y de los launchers se lee DIRECTO de
 *    apk/version.json (igual que la página de descargas del login,
 *    ShowDownloadsPage: las dos trabajan a la par). El workflow de
 *    GitHub Actions genera ese archivo con versiones, URLs y
 *    SHA-256 correctos en cada compilación, así que esta página
 *    SIEMPRE muestra lo publicado sin tocar código.
 *    Si el archivo no existe (servidor sin la carpeta apk/), se usan
 *    los valores de respaldo definidos más abajo.
 *
 * Además:
 *   - Detecta el dispositivo del jugador (Android / Windows / Linux) para
 *     resaltar la tarjeta de descarga que le corresponde.
 *   - Muestra el tamaño real de cada archivo si está en el servidor.
 */

if (!defined('MODE')) die('Hacking attempt');

class ShowDescargasPage extends AbstractGamePage
{
	// Sin módulo asociado: siempre disponible para todos los jugadores
	public static $requireModule = 0;

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
		$this->setWindow('normal');
	}

	public function show()
	{
		// ─────────────────────────────────────────────────────────
		// 1) Leer apk/version.json de la raíz del dominio
		// ─────────────────────────────────────────────────────────
		$data = array(
			'apkVersion'   => self::$DEFAULTS['apkVersion'],
			'apkUrl'       => self::$DEFAULTS['apkUrl'],
			'winVersion'   => self::$DEFAULTS['winVersion'],
			'setupUrl'     => self::$DEFAULTS['setupUrl'],
			'winUrl'       => self::$DEFAULTS['winUrl'],
			'linuxVersion' => self::$DEFAULTS['linuxVersion'],
			'linuxUrl'     => self::$DEFAULTS['linuxUrl'],
		);

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

		// ─────────────────────────────────────────────────────────
		// 3) Detectar el dispositivo del jugador (User-Agent)
		// ─────────────────────────────────────────────────────────
		$ua = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '';
		if (stripos($ua, 'android') !== false) {
			$data['device'] = 'android';
		} elseif (stripos($ua, 'windows') !== false) {
			$data['device'] = 'windows';
		} elseif (stripos($ua, 'linux') !== false && stripos($ua, 'android') === false) {
			$data['device'] = 'linux';
		} else {
			$data['device'] = 'otro';
		}

		$this->assign($data);
		$this->display('page.descargas.default.tpl');
	}

	/**
	 * Devuelve el tamaño del archivo en MB (texto), o '' si no existe.
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
