<?php
/**
 * Funciones auxiliares de KlikCuba: formato, seguridad, fotos, avisos.
 */
require_once __DIR__ . '/db.php';
require_once __DIR__ . '/cuba.php';

/* ---------- Sesión segura ---------- */
function vlt_session_start(): void {
    if (session_status() === PHP_SESSION_NONE) {
        session_set_cookie_params([
            'lifetime' => 60 * 60 * 24 * 30,
            'path' => '/',
            'httponly' => true,
            'samesite' => 'Lax',
            'secure' => (($_SERVER['HTTPS'] ?? '') === 'on'),
        ]);
        session_start();
    }
}

/* ---------- Escapar salida (anti XSS) ---------- */
function e(?string $s): string {
    return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8');
}

/* ---------- Dinero en CUP ---------- */
function money(int|float|null $n): string {
    return number_format((float)$n, 0, ',', ' ') . ' CUP';
}

/* ---------- Fecha legible ---------- */
function fdate(?string $dt): string {
    if (!$dt) return '—';
    $meses = [1=>'enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    $t = strtotime($dt);
    if (!$t) return '—';
    return date('j', $t) . ' de ' . $meses[(int)date('n', $t)] . ' de ' . date('Y', $t) . ', ' . date('H:i', $t);
}

/* ---------- Slug ---------- */
function slug(string $s): string {
    $s = strtolower(trim($s));
    $s = iconv('UTF-8', 'ASCII//TRANSLIT', $s) ?: $s;
    $s = preg_replace('/[^a-z0-9]+/', '-', $s);
    return trim($s, '-') ?: 'tienda';
}

/* ---------- Cabeceras de seguridad ---------- */
function security_headers(): void {
    if (headers_sent()) return;
    header('X-Frame-Options: SAMEORIGIN');
    header('X-Content-Type-Options: nosniff');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=(self)');
    if (($_SERVER['HTTPS'] ?? '') === 'on') header('Strict-Transport-Security: max-age=31536000');
}

/* ---------- CSRF ---------- */
function csrf_token(): string {
    vlt_session_start();
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf'];
}
function csrf_field(): string {
    return '<input type="hidden" name="csrf" value="' . csrf_token() . '">';
}
function csrf_check(): void {
    vlt_session_start();
    $t = $_POST['csrf'] ?? '';
    if (!$t || !hash_equals($_SESSION['csrf'] ?? '', $t)) {
        http_response_code(419);
        die('Sesión caducada: vuelve atrás y prueba otra vez.');
    }
}

/* ---------- Mensajes flash ---------- */
function flash(string $msg, string $type = 'ok'): void {
    vlt_session_start();
    $_SESSION['flash'][] = ['msg' => $msg, 'type' => $type];
}
function flash_get(): array {
    vlt_session_start();
    $f = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $f;
}

/* ---------- Redirección ---------- */
function redirect(string $url): void {
    header('Location: ' . $url);
    exit;
}

/* ---------- Registro de seguridad ---------- */
function sec_log(string $event, string $detail = '', ?int $userId = null): void {
    try {
        db()->prepare('INSERT INTO security_log (user_id, ip, event, detail, created_at) VALUES (?,?,?,?,?)')
            ->execute([$userId, $_SERVER['REMOTE_ADDR'] ?? '', $event, mb_substr($detail, 0, 500), date('Y-m-d H:i:s')]);
    } catch (Throwable $e) { /* el registro de seguridad nunca debe romper la web */ }
}

/* ---------- Límite de peticiones (rate limit) por IP ---------- */
function rate_limit(string $action, int $max, int $windowSeconds): bool {
    $ip = $_SERVER['REMOTE_ADDR'] ?? '0';
    $key = $ip . '|' . $action;
    $st = db()->prepare('SELECT count, window_start FROM rate_limits WHERE ip_action = ?');
    $st->execute([$key]);
    $row = $st->fetch();
    $now = time();
    if (!$row || (strtotime($row['window_start']) + $windowSeconds) < $now) {
        db()->prepare('REPLACE INTO rate_limits (ip_action, count, window_start) VALUES (?,?,?)')
            ->execute([$key, 1, date('Y-m-d H:i:s', $now)]);
        return true;
    }
    if ($row['count'] >= $max) return false;
    db()->prepare('UPDATE rate_limits SET count = count + 1 WHERE ip_action = ?')->execute([$key]);
    return true;
}

/* ---------- Notificaciones internas ---------- */
function notify(int $userId, string $title, string $body, string $link = ''): void {
    db()->prepare('INSERT INTO notifications (user_id, title, body, link, is_read, created_at) VALUES (?,?,?,?,0,?)')
        ->execute([$userId, $title, $body, $link, date('Y-m-d H:i:s')]);
}
function unread_count(int $userId): int {
    $st = db()->prepare('SELECT COUNT(*) c FROM notifications WHERE user_id = ? AND is_read = 0');
    $st->execute([$userId]);
    return (int)($st->fetch()['c'] ?? 0);
}

/* ---------- Estado de una mini tienda ---------- */
// 'activa' (suscripción pagada) | 'prueba' (dentro de los días gratis) | 'suspendida'
function store_status(array $store): string {
    // Los admins con tienda están exentos de pagar suscripción
    if (!empty($store['admin_exempt'])) return 'activa';
    $today = date('Y-m-d');
    if (!empty($store['subscription_until']) && $store['subscription_until'] >= $today) return 'activa';
    if (!empty($store['trial_until']) && $store['trial_until'] >= $today) return 'prueba';
    return 'suspendida';
}
function store_status_badge(array $store): string {
    $s = store_status($store);
    return $s === 'activa' ? '<span class="badge b-ok">Suscripción al día</span>'
         : ($s === 'prueba' ? '<span class="badge b-info">Prueba gratis</span>'
         : '<span class="badge b-warn">Suscripción pendiente</span>');
}

/* ---------- Fotos: JSON en la columna photos ---------- */
function photos_of(?string $json): array {
    $a = json_decode((string)$json, true);
    return is_array($a) ? array_values(array_filter($a)) : [];
}
function photo_of(?string $json): string {
    $p = photos_of($json);
    return $p[0] ?? 'assets/img/no-foto.svg';
}

/* ---------- Subir una foto ---------- */
function upload_image(array $file, string $folder): ?string {
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) return null;
    if (($file['size'] ?? 0) > MAX_UPLOAD_MB * 1024 * 1024) return null;
    $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));
    if (!in_array($ext, explode(',', ALLOWED_IMAGE_EXT), true)) return null;
    // Verifica que sea una imagen de verdad
    $info = @getimagesize($file['tmp_name']);
    if ($info === false) return null;
    $dir = __DIR__ . '/../uploads/' . $folder;
    if (!is_dir($dir)) mkdir($dir, 0775, true);
    $name = $folder . '-' . date('Ymd-His') . '-' . bin2hex(random_bytes(4)) . '.' . $ext;
    if (!move_uploaded_file($file['tmp_name'], $dir . '/' . $name)) return null;
    return 'uploads/' . $folder . '/' . $name;
}

/* ---------- Lista de fotos de la galería incluida ---------- */
function gallery_photos(): array {
    $dir = __DIR__ . '/../uploads/gallery';
    if (!is_dir($dir)) return [];
    $out = [];
    foreach (scandir($dir) ?: [] as $f) {
        if (preg_match('/\.(jpe?g|png|webp|gif)$/i', $f)) $out[] = 'uploads/gallery/' . $f;
    }
    sort($out, SORT_NATURAL | SORT_FLAG_CASE);
    return $out;
}

/* ---------- Ajustes clave/valor ---------- */
function setting_get(string $key, string $default = ''): string {
    $st = db()->prepare('SELECT value FROM settings WHERE k = ?');
    $st->execute([$key]);
    $v = $st->fetch();
    return $v ? $v['value'] : $default;
}
function setting_set(string $key, string $value): void {
    if (DB_DRIVER === 'mysql') {
        db()->prepare('INSERT INTO settings (k, value) VALUES (?,?) ON DUPLICATE KEY UPDATE value = VALUES(value)')->execute([$key, $value]);
    } else {
        db()->prepare('INSERT INTO settings (k, value) VALUES (?,?) ON CONFLICT(k) DO UPDATE SET value = excluded.value')->execute([$key, $value]);
    }
}

/* ---------- Datos de cobro del administrador (para transferencias) ---------- */
function payment_data(): array {
    $row = db()->query('SELECT * FROM payment_settings LIMIT 1')->fetch();
    return $row ?: [];
}
function payment_is_set(): bool {
    $p = payment_data();
    return !empty($p['card_number']);
}

/* ---------- Auto-migración de columnas de ubicación ----------
   Idempotente: si ya está marcada como migrada en settings, no hace nada.
   Se llama desde auth.php al inicio de cada página. */
function migrate_location_columns(): void {
    $defs = [
        'users'  => ['default_province VARCHAR(60) NULL', 'default_municipality VARCHAR(80) NULL'],
        'stores' => ['province VARCHAR(60) NULL', 'municipality VARCHAR(80) NULL'],
        'orders' => ['province VARCHAR(60) NULL', 'municipality VARCHAR(80) NULL',
                     'delivery_lat DECIMAL(10,7) NULL', 'delivery_lng DECIMAL(10,7) NULL'],
    ];
    foreach ($defs as $table => $cols) {
        try {
            $existing = [];
            if (DB_DRIVER === 'mysql') {
                $rs = db()->query("SHOW COLUMNS FROM `$table`");
                while ($r = $rs->fetch()) $existing[] = strtolower($r['Field']);
            } else {
                $rs = db()->query("PRAGMA table_info($table)");
                while ($r = $rs->fetch()) $existing[] = strtolower($r['name']);
            }
        } catch (Throwable $e) { $existing = []; }
        foreach ($cols as $colDef) {
            $colName = strtolower(preg_split('/\s+/', trim($colDef))[0]);
            if (!in_array($colName, $existing, true)) {
                try { db()->exec("ALTER TABLE `$table` ADD COLUMN $colDef"); } catch (Throwable $e) { /* ya existe */ }
            }
        }
    }
    if (DB_DRIVER === 'mysql') {
        foreach (['stores' => ['province', 'municipality'], 'orders' => ['province', 'municipality']] as $t => $cols) {
            foreach ($cols as $c) {
                try { db()->exec("CREATE INDEX `idx_{$t}_{$c}` ON `$t` (`$c`)"); } catch (Throwable $e) {}
            }
        }
    }
}

function auto_migrate_location(): void {
    static $done = false;
    if ($done) return;
    $done = true;
    if (!db_installed()) return;
    if (setting_get('location_migrated') === '1') return;
    try {
        migrate_location_columns();
        setting_set('location_migrated', '1');
    } catch (Throwable $e) { /* la migración nunca debe romper la web */ }
}

/* ---------- Migración de mensajeros KYC + inversiones + datos bancarios por admin ----------
   Crea las tablas nuevas con CREATE TABLE IF NOT EXISTS (idempotente).
   Se ejecuta una sola vez por instalación mediante el flag 'features_v2_migrated'. */
function migrate_features_v2(): void {
    $sql = [];
    if (DB_DRIVER === 'mysql') {
        $sql = [
            // Perfil KYC de mensajero (1 fila por usuario que se postula como mensajero)
            "CREATE TABLE IF NOT EXISTS messengers (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NOT NULL,
                full_name VARCHAR(120) NOT NULL,
                id_number VARCHAR(40) NULL,
                phone VARCHAR(40) NOT NULL,
                province VARCHAR(60) NOT NULL,
                municipality VARCHAR(80) NULL,
                address VARCHAR(240) NULL,
                vehicle VARCHAR(40) NULL DEFAULT 'bicicleta',
                id_front VARCHAR(300) NULL,
                id_back VARCHAR(300) NULL,
                face_photo VARCHAR(300) NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pendiente',
                submitted_at DATETIME NOT NULL,
                reviewed_at DATETIME NULL,
                INDEX (user_id), INDEX (status), INDEX (province), INDEX (municipality)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            // Ofertas de mensajería publicadas por dueños de tienda
            "CREATE TABLE IF NOT EXISTS messenger_offers (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                store_id INT UNSIGNED NOT NULL,
                owner_id INT UNSIGNED NOT NULL,
                title VARCHAR(160) NOT NULL,
                description TEXT NULL,
                province VARCHAR(60) NULL,
                municipality VARCHAR(80) NULL,
                pay_cup INT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'abierta',
                created_at DATETIME NOT NULL,
                INDEX (store_id), INDEX (owner_id), INDEX (status), INDEX (province), INDEX (municipality)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            // Postulaciones de mensajeros a ofertas
            "CREATE TABLE IF NOT EXISTS messenger_applications (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                offer_id INT UNSIGNED NOT NULL,
                messenger_id INT UNSIGNED NOT NULL,
                message VARCHAR(500) NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pendiente',
                created_at DATETIME NOT NULL,
                reviewed_at DATETIME NULL,
                INDEX (offer_id), INDEX (messenger_id), INDEX (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            // Datos bancarios múltiples por admin (sustituye al payment_settings global para inversiones)
            "CREATE TABLE IF NOT EXISTS admin_bank_accounts (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                admin_id INT UNSIGNED NOT NULL,
                label VARCHAR(80) NOT NULL,
                bank_name VARCHAR(120) NOT NULL,
                account_number VARCHAR(60) NOT NULL,
                holder VARCHAR(120) NOT NULL,
                phone VARCHAR(40) NULL,
                is_active TINYINT NOT NULL DEFAULT 1,
                created_at DATETIME NOT NULL,
                INDEX (admin_id), INDEX (is_active)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            // Solicitudes de inversión
            "CREATE TABLE IF NOT EXISTS investments (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                code VARCHAR(20) NOT NULL,
                user_id INT UNSIGNED NOT NULL,
                amount_cup INT NOT NULL,
                target_admin_id INT UNSIGNED NULL,
                accepted_admin_id INT UNSIGNED NULL,
                transfer_id VARCHAR(80) NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'solicitada',
                admin_note VARCHAR(300) NULL,
                created_at DATETIME NOT NULL,
                accepted_at DATETIME NULL,
                processed_at DATETIME NULL,
                INDEX (user_id), INDEX (status), INDEX (code), INDEX (target_admin_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
        ];
    } else {
        $sql = [
            "CREATE TABLE IF NOT EXISTS messengers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                full_name TEXT NOT NULL,
                id_number TEXT,
                phone TEXT NOT NULL,
                province TEXT NOT NULL,
                municipality TEXT,
                address TEXT,
                vehicle TEXT DEFAULT 'bicicleta',
                id_front TEXT, id_back TEXT, face_photo TEXT,
                status TEXT NOT NULL DEFAULT 'pendiente',
                submitted_at DATETIME NOT NULL,
                reviewed_at DATETIME
            )",
            "CREATE TABLE IF NOT EXISTS messenger_offers (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                store_id INTEGER NOT NULL,
                owner_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                description TEXT,
                province TEXT, municipality TEXT,
                pay_cup INTEGER,
                status TEXT NOT NULL DEFAULT 'abierta',
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS messenger_applications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                offer_id INTEGER NOT NULL,
                messenger_id INTEGER NOT NULL,
                message TEXT,
                status TEXT NOT NULL DEFAULT 'pendiente',
                created_at DATETIME NOT NULL,
                reviewed_at DATETIME
            )",
            "CREATE TABLE IF NOT EXISTS admin_bank_accounts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                admin_id INTEGER NOT NULL,
                label TEXT NOT NULL,
                bank_name TEXT NOT NULL,
                account_number TEXT NOT NULL,
                holder TEXT NOT NULL,
                phone TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS investments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                code TEXT NOT NULL,
                user_id INTEGER NOT NULL,
                amount_cup INTEGER NOT NULL,
                target_admin_id INTEGER,
                accepted_admin_id INTEGER,
                transfer_id TEXT,
                status TEXT NOT NULL DEFAULT 'solicitada',
                admin_note TEXT,
                created_at DATETIME NOT NULL,
                accepted_at DATETIME,
                processed_at DATETIME
            )",
        ];
    }
    foreach ($sql as $q) {
        try { db()->exec($q); } catch (Throwable $e) { /* ya existe */ }
    }
    // Columna review_note en messengers (nota del admin al rechazar)
    try {
        $has = false;
        if (DB_DRIVER === 'mysql') {
            $rs = db()->query("SHOW COLUMNS FROM messengers LIKE 'review_note'");
            $has = $rs && $rs->fetch();
        } else {
            $rs = db()->query("PRAGMA table_info(messengers)");
            while ($r = $rs->fetch()) if (strtolower($r['name']) === 'review_note') $has = true;
        }
        if (!$has) db()->exec("ALTER TABLE messengers ADD COLUMN review_note VARCHAR(300) NULL");
    } catch (Throwable $e) {}
    // Columna para eximir a los admins del pago de suscripción de tienda
    try {
        $has = false;
        if (DB_DRIVER === 'mysql') {
            $rs = db()->query("SHOW COLUMNS FROM stores LIKE 'admin_exempt'");
            $has = $rs && $rs->fetch();
        } else {
            $rs = db()->query("PRAGMA table_info(stores)");
            while ($r = $rs->fetch()) if (strtolower($r['name']) === 'admin_exempt') $has = true;
        }
        if (!$has) db()->exec("ALTER TABLE stores ADD COLUMN admin_exempt TINYINT NOT NULL DEFAULT 0");
    } catch (Throwable $e) {}
}

function auto_migrate_features_v2(): void {
    static $done = false;
    if ($done) return;
    $done = true;
    if (!db_installed()) return;
    if (setting_get('features_v2_migrated') === '1') return;
    try {
        migrate_features_v2();
        setting_set('features_v2_migrated', '1');
    } catch (Throwable $e) { /* la migración nunca debe romper la web */ }
}

/* ---------- Helpers de ubicación ---------- */

/* Determina la ubicación de búsqueda del visitante actual (sesión + cuenta).
   Devuelve ['province'=>slug|null, 'municipality'=>slug|null, 'source'=>texto]. */
function user_location(): array {
    $u = current_user();
    if ($u && !empty($u['default_province'])) {
        return ['province' => $u['default_province'], 'municipality' => $u['default_municipality'] ?? null, 'source' => 'cuenta'];
    }
    if (!empty($_SESSION['loc_province'])) {
        return ['province' => $_SESSION['loc_province'], 'municipality' => $_SESSION['loc_municipality'] ?? null, 'source' => 'sesion'];
    }
    return ['province' => null, 'municipality' => null, 'source' => 'ninguna'];
}

/* Construye la cláusula SQL de filtrado por ubicación para productos con store.
   Prioridad: municipio → provincia → provincias cercanas → todas.
   Devuelve ['sql' => string, 'params' => array, 'label' => string]. */
function location_filter_products(string $locProv, ?string $locMuni): array {
    if (!$locProv) return ['sql' => '', 'params' => [], 'label' => 'Todo el país'];
    if ($locMuni) {
        // mismo municipio primero, luego resto de la provincia
        return [
            'sql' => ' AND s.municipality = ?',
            'params' => [$locMuni],
            'label' => municipality_name($locProv, $locMuni) . ' (' . province_name($locProv) . ')',
        ];
    }
    return [
        'sql' => ' AND s.province = ?',
        'params' => [$locProv],
        'label' => province_name($locProv),
    ];
}

/* Genera enlace a Google Maps con coordenadas o dirección. */
function maps_link(?string $lat, ?string $lng, ?string $address = null, ?string $province = null, ?string $municipality = null): string {
    if ($lat !== null && $lat !== '' && $lng !== null && $lng !== '') {
        return 'https://www.google.com/maps/search/?api=1&query=' . urlencode($lat . ',' . $lng);
    }
    $q = trim(($address ?? '') . ', ' . municipality_name($province, $municipality) . ', ' . province_name($province) . ', Cuba', ', ');
    if ($q === '—') $q = 'Cuba';
    return 'https://www.google.com/maps/search/?api=1&query=' . urlencode($q);
}

/* ---------- URL relativa para enlaces ---------- */
function url(string $path = ''): string {
    return $path;
}

/* ---------- Categorías ---------- */
function top_categories(int $limit = 6): array {
    return db()->query('SELECT * FROM categories ORDER BY id LIMIT ' . (int)$limit)->fetchAll();
}
function category_by_slug(string $slug): ?array {
    $st = db()->prepare('SELECT * FROM categories WHERE slug = ?');
    $st->execute([$slug]);
    return $st->fetch() ?: null;
}

/* ============================================================
   ICONOS SVG (estilo Lucide / Feather — limpio y profesional,
   como el que usan Amazon, Shopify y tiendas modernas).
   Sustituyen a los emojis Unicode para una imagen más realista.
   ============================================================ */
function icon(string $name, int $size = 20, ?string $class = null): string {
    static $paths = [
        'shopping-cart' => '<circle cx="8" cy="21" r="1"/><circle cx="19" cy="21" r="1"/><path d="M2.05 2.05h2l2.66 12.42a2 2 0 0 0 2 1.58h9.78a2 2 0 0 0 1.95-1.57l1.65-7.43H5.12"/>',
        'wallet' => '<path d="M3 7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M16 12h.01"/><path d="M3 9h18"/>',
        'store' => '<path d="M2 7l1-4h18l1 4"/><path d="M4 7v13a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V7"/><path d="M2 7a3 3 0 0 0 6 0 3 3 0 0 0 6 0 3 3 0 0 0 6 0"/>',
        'flame' => '<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>',
        'sparkles' => '<path d="M9.94 14.06A2 2 0 0 0 8.5 12.62l-5.13-1.32a.5.5 0 0 1 0-.96L8.5 8.94A2 2 0 0 0 9.94 7.5l1.32-5.13a.5.5 0 0 1 .96 0L13.5 7.5a2 2 0 0 0 1.44 1.44l5.13 1.32a.5.5 0 0 1 0 .96l-5.13 1.32a2 2 0 0 0-1.44 1.44l-1.32 5.13a.5.5 0 0 1-.96 0z"/>',
        'sprout' => '<path d="M7 20h10"/><path d="M10 20c5.5-2.5.8-6.4 3-10"/><path d="M9.5 9.4c1.1.8 1.8 2.2 2.3 3.7-2 .4-3.5.4-4.8-.3-1.2-.6-2.3-1.9-3-4.2 2.8-.5 4.4 0 5.5.8z"/><path d="M14.1 6a7 7 0 0 0-1.1 4c1.9-.1 3.3-.6 4.3-1.4 1-1 1.6-2.3 1.7-4.6-2.7.1-4 1-4.9 2z"/>',
        'leaf' => '<path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/><path d="M2 21c0-3 1.85-5.36 5.08-6"/>',
        'receipt' => '<path d="M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2l-2 1-2-1-2 1-2-1-2 1-2-1-2 1Z"/><path d="M8 7h8"/><path d="M8 11h8"/><path d="M8 15h5"/>',
        'banknote' => '<rect width="20" height="12" x="2" y="6" rx="2"/><circle cx="12" cy="12" r="2"/><path d="M6 12h.01M18 12h.01"/>',
        'landmark' => '<line x1="3" x2="21" y1="22" y2="22"/><line x1="6" x2="6" y1="18" y2="11"/><line x1="10" x2="10" y1="18" y2="11"/><line x1="14" x2="14" y1="18" y2="11"/><line x1="18" x2="18" y1="18" y2="11"/><polygon points="12 2 20 7 4 7"/>',
        'user' => '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
        'users' => '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
        'phone' => '<path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>',
        'map-pin' => '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>',
        'message-circle' => '<path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/>',
        'package' => '<path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/>',
        'bar-chart' => '<line x1="12" x2="12" y1="20" y2="10"/><line x1="18" x2="18" y1="20" y2="4"/><line x1="6" x2="6" y1="20" y2="16"/>',
        'shield' => '<path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/>',
        'key' => '<path d="m15.5 7.5 2.3 2.3a1 1 0 0 0 1.4 0l2.1-2.1a1 1 0 0 0 0-1.4L19 4"/><path d="m21 2-9.6 9.6"/><circle cx="7.5" cy="15.5" r="5.5"/>',
        'check' => '<polyline points="20 6 9 17 4 12"/>',
        'x' => '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
        'laptop' => '<path d="M20 16V7a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v9m16 0H4m16 0 1.28 2.55a1 1 0 0 1-.9 1.45H3.62a1 1 0 0 1-.9-1.45L4 16"/>',
        'home' => '<path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>',
        'shirt' => '<path d="M20.38 3.46 16 2a4 4 0 0 1-8 0L3.62 3.46a2 2 0 0 0-1.34 2.23l.58 3.47a1 1 0 0 0 .99.84H6v10c0 1.1.9 2 2 2h8a2 2 0 0 0 2-2V10h2.15a1 1 0 0 0 .99-.84l.58-3.47a2 2 0 0 0-1.34-2.23z"/>',
        'footprints' => '<path d="M4 16v-2.38C4 11.5 2.97 10.5 3 8c.03-2.72 1.49-6 4.5-6C9.37 2 10 3.8 10 5.5c0 3.11-2 5.66-2 7.68V16a2 2 0 1 1-4 0Z"/><path d="M20 20v-2.38c0-2.12 2-4.57 2-7.68 0-1.7-.63-3.5-2.5-3.5-3.03 0-4.47 3.28-4.5 6-.03 2.5 1 4.5 1 6.38a2 2 0 1 0 4 0Z"/><path d="M16 17h4"/><path d="M4 13h4"/>',
        'wrench' => '<path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/>',
        'music' => '<path d="M9 18V5l12-2v13"/><circle cx="6" cy="18" r="3"/><circle cx="18" cy="16" r="3"/>',
        'tv' => '<rect x="2" y="7" width="20" height="15" rx="2" ry="2"/><polyline points="17 2 12 7 7 2"/>',
        'gamepad' => '<line x1="6" x2="10" y1="11" y2="11"/><line x1="8" x2="8" y1="9" y2="13"/><line x1="15" x2="15.01" y1="12" y2="12"/><line x1="18" x2="18.01" y1="10" y2="10"/><path d="M17.32 5H6.68a4 4 0 0 0-3.98 3.59c-.01.05-.01.1-.02.15C2.6 9.42 2 14.46 2 16a3 3 0 0 0 3 3c1 0 1.5-.5 2-1l1.41-1.41A2 2 0 0 1 9.83 16h4.34a2 2 0 0 1 1.42.59L17 18c.5.5 1 1 2 1a3 3 0 0 0 3-3c0-1.55-.6-6.58-.68-7.26-.01-.05-.01-.1-.02-.15A4 4 0 0 0 17.32 5z"/>',
        'palette' => '<circle cx="13.5" cy="6.5" r=".5" fill="currentColor"/><circle cx="17.5" cy="10.5" r=".5" fill="currentColor"/><circle cx="8.5" cy="7.5" r=".5" fill="currentColor"/><circle cx="6.5" cy="12.5" r=".5" fill="currentColor"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.93 0 1.65-.75 1.65-1.69 0-.44-.18-.83-.44-1.13-.29-.29-.44-.65-.44-1.12a1.64 1.64 0 0 1 1.67-1.67h1.99c3.05 0 5.55-2.5 5.55-5.55C21.97 6.01 17.46 2 12 2z"/>',
        'dribbble' => '<circle cx="12" cy="12" r="10"/><path d="M19.13 5.09C15.22 9.14 10 10.44 2.25 10.94"/><path d="M21.75 12.84c-6.62-1.41-12.14 1-16.38 6.32"/><path d="M8.56 2.75c4.37 6 6 9.42 8 17.72"/>',
        'tag' => '<path d="M12.59 2.59A2 2 0 0 0 11.17 2H4a2 2 0 0 0-2 2v7.17a2 2 0 0 0 .59 1.42l8.7 8.7a2.43 2.43 0 0 0 3.42 0l6.58-6.58a2.43 2.43 0 0 0 0-3.42z"/><circle cx="7.5" cy="7.5" r=".5" fill="currentColor"/>',
        'save' => '<path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/>',
        'search' => '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/>',
        'bell' => '<path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>',
        'alert' => '<path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" x2="12" y1="9" y2="13"/><line x1="12" x2="12.01" y1="17" y2="17"/>',
        'trending-up' => '<polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/>',
        'bike' => '<circle cx="5.5" cy="17.5" r="3.5"/><circle cx="18.5" cy="17.5" r="3.5"/><path d="M15 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm-3 11.5V14l-3-3 4-3 2 3h2"/>',
        'megaphone' => '<path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/>',
        'credit-card' => '<rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/>',
        'camera' => '<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/>',
        'mail' => '<rect width="20" height="16" x="2" y="4" rx="2"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/>',
        'history' => '<path d="M3 3v5h5"/><path d="M3.05 13A9 9 0 1 0 6 5.3L3 8"/><path d="M12 7v5l4 2"/>',
        'info' => '<circle cx="12" cy="12" r="10"/><path d="M12 16v-4"/><path d="M12 8h.01"/>',
        'edit' => '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.12 2.12 0 0 1 3 3L12 15l-4 1 1-4Z"/>',
        'trash' => '<path d="M3 6h18"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>',
        'arrow-left' => '<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>',
        'lock' => '<rect width="18" height="11" x="3" y="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
        'send' => '<path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/>',
        'eye' => '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
    ];
    $body = $paths[$name] ?? $paths['tag'];
    $cls = $class !== null ? ' class="' . htmlspecialchars($class, ENT_QUOTES) . '"' : '';
    return '<svg width="' . $size . '" height="' . $size . '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"' . $cls . '>' . $body . '</svg>';
}

/* Mapeo de categorías (por slug) a icono SVG; si no hay, usa el emoji de la BD. */
function category_icon(?string $slug, ?string $emoji = null, int $size = 26): string {
    $map = [
        'electronica' => 'tv', 'computadoras' => 'laptop', 'hogar-y-cocina' => 'home',
        'ropa' => 'shirt', 'calzado' => 'footprints', 'belleza' => 'palette',
        'deportes' => 'dribbble', 'juguetes' => 'gamepad', 'herramientas' => 'wrench',
        'musica' => 'music',
    ];
    if ($slug && isset($map[$slug])) {
        return '<span class="cat-ic">' . icon($map[$slug], $size) . '</span>';
    }
    return '<span class="cat-ic">' . icon('tag', $size) . '</span>';
}
