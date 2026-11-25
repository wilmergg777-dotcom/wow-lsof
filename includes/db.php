<?php
/**
 * Conexión a la base de datos (PDO) y utilidades básicas.
 * Funciona con MySQL (VPS) y SQLite (pruebas locales).
 */
if (!defined('SITE_NAME')) { require_once __DIR__ . '/config.php'; }

function db(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        try {
            if (DB_DRIVER === 'mysql') {
                $pdo = new PDO(
                    'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4',
                    DB_USER,
                    DB_PASS,
                    [
                        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                        PDO::ATTR_EMULATE_PREPARES => false,
                    ]
                );
            } else {
                @mkdir(dirname(DB_SQLITE_PATH), 0775, true);
                $pdo = new PDO('sqlite:' . DB_SQLITE_PATH, null, null, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ]);
                $pdo->exec('PRAGMA foreign_keys = ON');
            }
        } catch (PDOException $e) {
            http_response_code(500);
            die('<div style="font-family:sans-serif;max-width:640px;margin:60px auto;padding:24px;border:2px solid #7C3AED;border-radius:14px">'
                . '<h1 style="color:#4C1D95">No se pudo conectar a la base de datos</h1>'
                . '<p>Revisa los datos de conexión en <b>includes/config.php</b>.</p>'
                . (DEBUG ? '<pre style="background:#F5F3FF;padding:10px;border-radius:8px">' . htmlspecialchars($e->getMessage()) . '</pre>' : '')
                . '<p>Si es la primera vez, abre <b>install.php</b> para instalar la tienda.</p></div>');
        }
    }
    return $pdo;
}

/** Comprueba si las tablas ya están instaladas. */
function db_installed(): bool {
    try {
        if (DB_DRIVER === 'mysql') {
            $r = db()->query("SHOW TABLES LIKE 'users'")->fetch();
        } else {
            $r = db()->query("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")->fetch();
        }
        return (bool)$r;
    } catch (Throwable $e) { return false; }
}

/** Limita consultas al motor: devuelve SQL nativo según el driver. */
function db_now(): string {
    return DB_DRIVER === 'mysql' ? 'NOW()' : "datetime('now','localtime')";
}
