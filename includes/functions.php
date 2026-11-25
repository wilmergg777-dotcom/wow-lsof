<?php
/**
 * Funciones auxiliares de Violetero: formato, seguridad, fotos, avisos.
 */
require_once __DIR__ . '/db.php';

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
