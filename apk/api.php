<?php
/**
 * AstroIO — API de la app Android (VPS)
 * ------------------------------------------------------------------
 * Endpoint:  https://TU-DOMINIO/AstroIO3.4/apk/api.php?action=check
 *
 * Devuelve a la APK dos bloques:
 *
 *  app    → versión de la APLICACIÓN que exige el servidor.
 *           Se lee de apk/release/version.json (el admin lo edita).
 *           Si existe apk/release/AstroIO.apk, se le calculan tamaño y
 *           SHA-256 automáticamente (con caché) y se arma la URL.
 *
 *  assets → MANIFIESTO de archivos del juego publicados en apk/files/
 *           (misma ruta relativa que en el servidor del juego).
 *           La APK compara MD5 y solo descarga los archivos que
 *           cambiaron (actualización incremental con porcentaje).
 *
 * La respuesta es JSON puro; nunca expone rutas internas del VPS.
 */

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate');
header('X-Content-Type-Options: nosniff');

$action = isset($_GET['action']) ? (string) $_GET['action'] : 'check';

function astroio_fail($msg) {
    http_response_code(400);
    echo json_encode(array('error' => $msg));
    exit;
}

if ($action !== 'check') {
    astroio_fail('bad_action');
}

$dir = __DIR__;
$cacheDir = $dir . '/cache';
if (!is_dir($cacheDir)) { @mkdir($cacheDir, 0755, true); }

// ─────────────────────────────────────────────────────────────────
// Utilidades de URL pública (sin exponer el disco del servidor)
// ─────────────────────────────────────────────────────────────────
function astroio_base_url() {
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (isset($_SERVER['SERVER_PORT']) && (int) $_SERVER['SERVER_PORT'] === 443)
        || (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https');
    $scheme = $https ? 'https' : 'http';
    $host = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST']
        : (isset($_SERVER['SERVER_NAME']) ? $_SERVER['SERVER_NAME'] : 'localhost');
    // dirname de /AstroIO3.4/apk/api.php → /AstroIO3.4/apk
    $dirUrl = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
    return $scheme . '://' . $host . $dirUrl;
}

// ─────────────────────────────────────────────────────────────────
// 1) Bloque APP (versión de la aplicación exigida por el servidor)
// ─────────────────────────────────────────────────────────────────
$releaseDir = $dir . '/release';
$verFile    = $releaseDir . '/version.json';
$apkFile    = $releaseDir . '/AstroIO.apk';

$app = array('versionCode' => 1, 'versionName' => '1.0.0', 'url' => '', 'sha256' => '', 'size' => 0);

if (is_file($verFile)) {
    $v = json_decode((string) file_get_contents($verFile), true);
    if (is_array($v)) {
        $app['versionCode'] = (int) (isset($v['versionCode']) ? $v['versionCode'] : 1);
        $app['versionName'] = (string) (isset($v['versionName']) ? $v['versionName'] : '1.0.0');
    }
}

if (is_file($apkFile) && is_readable($apkFile)) {
    $mtime = (int) filemtime($apkFile);
    $size  = (int) filesize($apkFile);
    $hashCache = $cacheDir . '/apk_hash.cache.json';

    $sha = '';
    if (is_file($hashCache)) {
        $c = json_decode((string) file_get_contents($hashCache), true);
        if (is_array($c) && isset($c['mtime'], $c['size'], $c['sha256'])
            && (int) $c['mtime'] === $mtime && (int) $c['size'] === $size) {
            $sha = (string) $c['sha256'];
        }
    }
    if ($sha === '') {
        $sha = hash_file('sha256', $apkFile);
        @file_put_contents($hashCache, json_encode(array(
            'mtime' => $mtime, 'size' => $size, 'sha256' => $sha,
        )), LOCK_EX);
    }

    $app['url']    = astroio_base_url() . '/release/AstroIO.apk';
    $app['sha256'] = $sha;
    $app['size']   = $size;
}

// ─────────────────────────────────────────────────────────────────
// 2) Bloque ASSETS (manifiesto incremental de apk/files/)
// ─────────────────────────────────────────────────────────────────
$filesDir = $dir . '/files';
$assets = array('version' => '', 'totalBytes' => 0, 'files' => array());

if (is_dir($filesDir)) {
    $manifestCache = $cacheDir . '/manifest.cache.json';

    // Escaneo barato: nº de archivos + mtime máximo (sin leer contenido)
    $scanState = array('count' => 0, 'maxMtime' => 0);
    $rit = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($filesDir, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::LEAVES_ONLY
    );
    foreach ($rit as $f) {
        if ($f->isFile()) {
            $scanState['count']++;
            $m = (int) $f->getMTime();
            if ($m > $scanState['maxMtime']) { $scanState['maxMtime'] = $m; }
        }
    }

    $manifest = null;
    if (is_file($manifestCache)) {
        $c = json_decode((string) file_get_contents($manifestCache), true);
        if (is_array($c) && isset($c['scan']) && $c['scan'] == $scanState) {
            $manifest = $c;
        }
    }

    if ($manifest === null) {
        // Manifiesto completo: path, md5, size (con caché)
        $files = array();
        $total = 0;
        $rit2 = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($filesDir, FilesystemIterator::SKIP_DOTS),
            RecursiveIteratorIterator::LEAVES_ONLY
        );
        foreach ($rit2 as $f) {
            if (!$f->isFile()) { continue; }
            $name = $f->getFilename();
            if ($name[0] === '.' || substr($name, -10) === '.astro.tmp') { continue; }
            $rel = str_replace('\\', '/', substr($f->getPathname(), strlen($filesDir) + 1));
            if (strpos($rel, '/.') !== false || strpos($rel, '..') !== false) { continue; }
            $size = (int) $f->getSize();
            $files[] = array(
                'path' => $rel,
                'md5'  => md5_file($f->getPathname()),
                'size' => $size,
            );
            $total += $size;
        }
        usort($files, function ($a, $b) { return strcmp($a['path'], $b['path']); });

        $manifest = array(
            'scan'    => $scanState,
            'version' => (string) $scanState['maxMtime'],
            'total'   => $total,
            'files'   => $files,
        );
        @file_put_contents($manifestCache, json_encode($manifest), LOCK_EX);
    }

    $baseUrl = astroio_base_url();
    $outFiles = array();
    foreach ($manifest['files'] as $f) {
        $outFiles[] = array(
            'path' => $f['path'],
            'md5'  => $f['md5'],
            'size' => $f['size'],
            'url'  => $baseUrl . '/files/' . $f['path'],
        );
    }
    $assets = array(
        'version'    => $manifest['version'],
        'totalBytes' => (int) $manifest['total'],
        'files'      => $outFiles,
    );
}

// ─────────────────────────────────────────────────────────────────
// Respuesta
// ─────────────────────────────────────────────────────────────────
echo json_encode(array(
    'serverTime' => time(),
    'app'        => $app,
    'assets'     => $assets,
), JSON_UNESCAPED_SLASHES);
