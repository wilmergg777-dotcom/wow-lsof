<?php
/**
 * ShowDescargasPage — Página de descargas DENTRO del juego
 * AstroIO v2.4.1
 *
 * URL: game.php?page=descargas
 *
 * Muestra al jugador los enlaces oficiales para descargar:
 *   - APK para Android (AstroIO.apk)
 *   - Launcher para Windows (AstroIO-Launcher-windows.exe)
 *   - Launcher para Linux (AstroIO-Launcher-linux)
 *
 * Los datos se leen del archivo apk/version.json que vive en la RAÍZ del
 * dominio (la misma carpeta donde están game.php e index.php). Como el
 * workflow de GitHub Actions genera ese archivo con la versión y los
 * SHA-256 correctos en cada compilación, esta página SIEMPRE muestra la
 * versión y las URLs reales sin necesidad de tocar código.
 * Si el archivo no existe (servidor sin la carpeta apk/), se usan los
 * valores de respaldo definidos más abajo.
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
		'versionName' => '2.4.1',
		'apkUrl'      => 'https://astroio.duckdns.org/apk/AstroIO.apk',
		'winUrl'      => 'https://astroio.duckdns.org/launcher/AstroIO-Launcher-windows.exe',
		'linuxUrl'    => 'https://astroio.duckdns.org/launcher/AstroIO-Launcher-linux',
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
			'versionName' => self::$DEFAULTS['versionName'],
			'apkUrl'      => self::$DEFAULTS['apkUrl'],
			'winUrl'      => self::$DEFAULTS['winUrl'],
			'linuxUrl'    => self::$DEFAULTS['linuxUrl'],
		);

		$jsonFile = ROOT_PATH.'apk/version.json';
		if (is_file($jsonFile)) {
			$json = json_decode((string) @file_get_contents($jsonFile), true);
			if (is_array($json)) {
				if (!empty($json['versionName'])) {
					$data['versionName'] = (string) $json['versionName'];
				}
				if (!empty($json['url'])) {
					$data['apkUrl'] = (string) $json['url'];
				}
				if (!empty($json['launcher']['windows']['url'])) {
					$data['winUrl'] = (string) $json['launcher']['windows']['url'];
				}
				if (!empty($json['launcher']['linux']['url'])) {
					$data['linuxUrl'] = (string) $json['launcher']['linux']['url'];
				}
			}
		}

		// ─────────────────────────────────────────────────────────
		// 2) Tamaño real de cada archivo si está en el servidor
		// ─────────────────────────────────────────────────────────
		$data['apkSize']   = self::fileSizeMB(ROOT_PATH.'apk/AstroIO.apk');
		$data['winSize']   = self::fileSizeMB(ROOT_PATH.'launcher/AstroIO-Launcher-windows.exe');
		$data['linuxSize'] = self::fileSizeMB(ROOT_PATH.'launcher/AstroIO-Launcher-linux');

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
}
