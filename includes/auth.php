<?php
/**
 * Autenticación y seguridad de Violetero:
 * login con bloqueo tras N intentos, sesiones por dispositivo,
 * recuperación de contraseña por código y registro de seguridad.
 */
require_once __DIR__ . '/functions.php';

vlt_session_start();
security_headers();

// Si la base de datos no está instalada, manda al instalador (excepto en install.php y logout.php)
$__entry = basename($_SERVER['SCRIPT_NAME'] ?? '');
if ($__entry !== 'install.php' && $__entry !== 'logout.php' && !db_installed()) {
    header('Location: install.php');
    exit;
}
// Auto-migración de columnas de ubicación (provincia/municipio/lat/lng).
// Idempotente: solo ejecuta una vez por instalación.
if ($__entry !== 'install.php' && $__entry !== 'logout.php' && function_exists('auto_migrate_location')) {
    auto_migrate_location();
}

/* ---------- Usuario actual ---------- */
function current_user(): ?array {
    static $user = null;
    static $loaded = false;
    if ($loaded) return $user;
    $loaded = true;
    if (empty($_SESSION['user_id'])) return null;
    $st = db()->prepare('SELECT * FROM users WHERE id = ?');
    $st->execute([(int)$_SESSION['user_id']]);
    $user = $st->fetch() ?: null;
    if ($user) {
        db()->prepare('UPDATE user_sessions SET last_seen = ? WHERE token = ?')
            ->execute([date('Y-m-d H:i:s'), session_id()]);
        $user['cart_count'] = (int)(function_exists('cart_count') ? cart_count((int)$user['id']) : 0);
    }
    return $user;
}
function require_login(string $returnTo = ''): array {
    $u = current_user();
    if (!$u) {
        flash('Inicia sesión para continuar.', 'info');
        redirect('login.php' . ($returnTo ? '?volver=' . urlencode($returnTo) : ''));
    }
    return $u;
}
function require_admin(): array {
    $u = require_login();
    if ($u['role'] !== 'admin') { http_response_code(403); die('Solo para administradores.'); }
    return $u;
}
function require_seller(): array {
    $u = require_login();
    if (!in_array($u['role'], ['seller', 'admin'], true)) {
        flash('Necesitas una mini tienda para vender. ¡Créala gratis!', 'info');
        redirect('mi-tienda.php');
    }
    return $u;
}

/* ---------- Conteo del carrito ---------- */
function cart_count(int $userId): int {
    $st = db()->prepare('SELECT COALESCE(SUM(qty),0) c FROM cart_items WHERE user_id = ?');
    $st->execute([$userId]);
    return (int)$st->fetch()['c'];
}

/* ---------- Registro ---------- */
function register_user(string $name, string $email, string $phone, string $password): int {
    $hash = password_hash($password, PASSWORD_DEFAULT);
    db()->prepare('INSERT INTO users (name, email, phone, password_hash, role, created_at) VALUES (?,?,?,?,?,?)')
        ->execute([$name, $email ?: null, $phone, $hash, 'customer', date('Y-m-d H:i:s')]);
    $id = (int)db()->lastInsertId();
    sec_log('registro', 'Nueva cuenta: ' . $name . ' <' . $email . '>', $id);
    return $id;
}

/* ---------- Login ---------- */
function login_user(array $user): void {
    session_regenerate_id(true);
    $_SESSION['user_id'] = (int)$user['id'];
    db()->prepare('INSERT INTO user_sessions (user_id, token, ip, user_agent, created_at, last_seen) VALUES (?,?,?,?,?,?)')
        ->execute([(int)$user['id'], session_id(), $_SERVER['REMOTE_ADDR'] ?? '', mb_substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 250), date('Y-m-d H:i:s'), date('Y-m-d H:i:s')]);
    db()->prepare('UPDATE users SET failed_attempts = 0, locked_until = NULL, last_login = ? WHERE id = ?')
        ->execute([date('Y-m-d H:i:s'), (int)$user['id']]);
    sec_log('login', 'Sesión iniciada', (int)$user['id']);
}

function logout_user(): void {
    $u = current_user();
    if ($u) {
        db()->prepare('DELETE FROM user_sessions WHERE token = ?')->execute([session_id()]);
        sec_log('logout', 'Sesión cerrada', (int)$u['id']);
    }
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
    }
    session_destroy();
}

/* ---------- Intento de contraseña: bloqueo y registro ---------- */
function login_attempt_failed(int $userId): void {
    $st = db()->prepare('SELECT failed_attempts FROM users WHERE id = ?');
    $st->execute([$userId]);
    $fails = ((int)($st->fetch()['failed_attempts'] ?? 0)) + 1;
    $lockedUntil = null;
    if ($fails >= MAX_LOGIN_ATTEMPTS) {
        $lockedUntil = date('Y-m-d H:i:s', time() + LOCK_MINUTES * 60);
        $fails = 0;
    }
    db()->prepare('UPDATE users SET failed_attempts = ?, locked_until = ? WHERE id = ?')->execute([$fails, $lockedUntil, $userId]);
    if ($lockedUntil) sec_log('cuenta_bloqueada', 'Cuenta bloqueada ' . LOCK_MINUTES . ' min tras ' . MAX_LOGIN_ATTEMPTS . ' intentos fallidos', $userId);
}

/* ---------- Recuperación de contraseña ---------- */
function create_reset_code(int $userId): string {
    $code = (string)random_int(100000, 999999);
    db()->prepare('DELETE FROM password_resets WHERE user_id = ?')->execute([$userId]);
    db()->prepare('INSERT INTO password_resets (user_id, code, expires_at, used, created_at) VALUES (?,?,?,0,?)')
        ->execute([$userId, $code, date('Y-m-d H:i:s', time() + RESET_CODE_MINUTES * 60), date('Y-m-d H:i:s')]);
    sec_log('codigo_recuperacion', 'Código generado (vigencia ' . RESET_CODE_MINUTES . ' min)', $userId);
    return $code;
}
function verify_reset_code(int $userId, string $code): bool {
    $st = db()->prepare('SELECT * FROM password_resets WHERE user_id = ? AND code = ? AND used = 0');
    $st->execute([$userId, $code]);
    $row = $st->fetch();
    return $row && strtotime($row['expires_at']) >= time();
}
function complete_reset(int $userId, string $newPassword): void {
    db()->prepare('UPDATE users SET password_hash = ? WHERE id = ?')
        ->execute([password_hash($newPassword, PASSWORD_DEFAULT), $userId]);
    db()->prepare('UPDATE password_resets SET used = 1 WHERE user_id = ?')->execute([$userId]);
    // Cierra todas las sesiones por seguridad
    db()->prepare('DELETE FROM user_sessions WHERE user_id = ?')->execute([$userId]);
    sec_log('password_reset', 'Contraseña restablecida con código', $userId);
}

/* ---------- Cambiar contraseña (desde Mi Cuenta) ---------- */
function change_password(int $userId, string $current, string $new): bool {
    $st = db()->prepare('SELECT password_hash FROM users WHERE id = ?');
    $st->execute([$userId]);
    $row = $st->fetch();
    if (!$row || !password_verify($current, $row['password_hash'])) return false;
    db()->prepare('UPDATE users SET password_hash = ? WHERE id = ?')
        ->execute([password_hash($new, PASSWORD_DEFAULT), $userId]);
    // Cierra las demás sesiones (deja la actual)
    db()->prepare('DELETE FROM user_sessions WHERE user_id = ? AND token != ?')->execute([$userId, session_id()]);
    sec_log('password_change', 'Contraseña cambiada desde Mi Cuenta', $userId);
    return true;
}
