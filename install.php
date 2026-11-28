<?php
/**
 * ============================================================
 * INSTALADOR DE VIOLETERO
 * ============================================================
 * Crea TODAS las tablas y llena la tienda con datos de ejemplo
 * (usuarios, mini tiendas, ofertas con fotos y datos de cobro)
 * para que puedas probar todo desde el primer minuto.
 *
 * Se abre solo: si la base de datos no está instalada, cualquier
 * página te manda aquí. Al terminar se autodesactiva y te deja
 * entrar con las cuentas de prueba que se muestran al final.
 * ============================================================
 */
require_once __DIR__ . '/includes/functions.php';
require_once __DIR__ . '/includes/auth.php';

vlt_session_start();
security_headers();

$error = '';
$done = false;
// ¿Ya está instalada la tienda (tablas + fecha de instalación)?
$alreadyFullyInstalled = false;
try {
    if (db_installed() && setting_get('installed_at') !== '') $alreadyFullyInstalled = true;
} catch (Throwable $e) { $alreadyFullyInstalled = false; }
$alreadyInstalled = db_installed();

/* ---------- Esquema según el motor ---------- */
function create_tables(): void {
    if (DB_DRIVER === 'mysql') {
        $sql = [
            "CREATE TABLE IF NOT EXISTS users (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(160) NULL UNIQUE,
                phone VARCHAR(40) NULL,
                password_hash VARCHAR(255) NOT NULL,
                role VARCHAR(20) NOT NULL DEFAULT 'customer',
                balance_cup INT NOT NULL DEFAULT 0,
                default_province VARCHAR(60) NULL,
                default_municipality VARCHAR(80) NULL,
                failed_attempts INT NOT NULL DEFAULT 0,
                locked_until DATETIME NULL,
                last_login DATETIME NULL,
                created_at DATETIME NOT NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS user_sessions (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NOT NULL,
                token VARCHAR(128) NOT NULL,
                ip VARCHAR(45) NULL,
                user_agent VARCHAR(250) NULL,
                created_at DATETIME NOT NULL,
                last_seen DATETIME NULL,
                INDEX (user_id), INDEX (token)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS password_resets (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NOT NULL,
                code VARCHAR(10) NOT NULL,
                expires_at DATETIME NOT NULL,
                used TINYINT(1) NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL,
                INDEX (user_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS stores (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                owner_id INT UNSIGNED NOT NULL,
                name VARCHAR(120) NOT NULL,
                slug VARCHAR(140) NOT NULL,
                description TEXT NULL,
                photo VARCHAR(300) NULL,
                province VARCHAR(60) NULL,
                municipality VARCHAR(80) NULL,
                trial_until DATE NULL,
                subscription_until DATE NULL,
                created_at DATETIME NOT NULL,
                INDEX (owner_id), INDEX (slug), INDEX (province), INDEX (municipality)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS categories (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(80) NOT NULL,
                slug VARCHAR(90) NOT NULL,
                emoji VARCHAR(10) NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS products (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                store_id INT UNSIGNED NULL,
                category_id INT UNSIGNED NULL,
                title VARCHAR(160) NOT NULL,
                description TEXT NULL,
                price_cup INT NOT NULL,
                old_price_cup INT NULL,
                stock INT NOT NULL DEFAULT 0,
                photos TEXT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'active',
                views INT NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL,
                INDEX (store_id), INDEX (category_id), INDEX (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS cart_items (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NOT NULL,
                product_id INT UNSIGNED NOT NULL,
                qty INT NOT NULL DEFAULT 1,
                UNIQUE KEY uq_cart (user_id, product_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS orders (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                code VARCHAR(20) NOT NULL,
                buyer_id INT UNSIGNED NOT NULL,
                total_cup INT NOT NULL,
                payment_method VARCHAR(20) NOT NULL DEFAULT 'efectivo',
                transfer_id VARCHAR(80) NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pendiente',
                address VARCHAR(240) NULL,
                province VARCHAR(60) NULL,
                municipality VARCHAR(80) NULL,
                delivery_lat DECIMAL(10,7) NULL,
                delivery_lng DECIMAL(10,7) NULL,
                phone VARCHAR(40) NULL,
                note VARCHAR(300) NULL,
                created_at DATETIME NOT NULL,
                INDEX (buyer_id), INDEX (status), INDEX (code), INDEX (province), INDEX (municipality)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS order_items (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                order_id INT UNSIGNED NOT NULL,
                product_id INT UNSIGNED NULL,
                store_id INT UNSIGNED NULL,
                title VARCHAR(160) NOT NULL,
                price_cup INT NOT NULL,
                qty INT NOT NULL DEFAULT 1,
                photo VARCHAR(300) NULL,
                INDEX (order_id), INDEX (store_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS topups (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NOT NULL,
                amount_cup INT NOT NULL,
                transfer_id VARCHAR(80) NOT NULL,
                status VARCHAR(20) NOT NULL DEFAULT 'pendiente',
                admin_note VARCHAR(300) NULL,
                created_at DATETIME NOT NULL,
                processed_at DATETIME NULL,
                INDEX (user_id), INDEX (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS payment_settings (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                bank_name VARCHAR(120) NULL,
                card_number VARCHAR(60) NULL,
                holder VARCHAR(120) NULL,
                phone VARCHAR(40) NULL,
                updated_by INT UNSIGNED NULL,
                updated_at DATETIME NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS notifications (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NOT NULL,
                title VARCHAR(160) NOT NULL,
                body VARCHAR(600) NULL,
                link VARCHAR(240) NULL,
                is_read TINYINT(1) NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL,
                INDEX (user_id, is_read)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS security_log (
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                user_id INT UNSIGNED NULL,
                ip VARCHAR(45) NULL,
                event VARCHAR(60) NOT NULL,
                detail VARCHAR(500) NULL,
                created_at DATETIME NOT NULL,
                INDEX (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS rate_limits (
                ip_action VARCHAR(100) PRIMARY KEY,
                count INT NOT NULL DEFAULT 0,
                window_start DATETIME NOT NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
            "CREATE TABLE IF NOT EXISTS settings (
                k VARCHAR(80) PRIMARY KEY,
                value VARCHAR(400) NOT NULL
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",
        ];
        foreach ($sql as $q) db()->exec($q);
    } else {
        $sql = [
            "CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT UNIQUE,
                phone TEXT,
                password_hash TEXT NOT NULL,
                role TEXT NOT NULL DEFAULT 'customer',
                balance_cup INTEGER NOT NULL DEFAULT 0,
                default_province TEXT,
                default_municipality TEXT,
                failed_attempts INTEGER NOT NULL DEFAULT 0,
                locked_until DATETIME,
                last_login DATETIME,
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS user_sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                token TEXT NOT NULL,
                ip TEXT,
                user_agent TEXT,
                created_at DATETIME NOT NULL,
                last_seen DATETIME
            )",
            "CREATE TABLE IF NOT EXISTS password_resets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                code TEXT NOT NULL,
                expires_at DATETIME NOT NULL,
                used INTEGER NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS stores (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                owner_id INTEGER NOT NULL,
                name TEXT NOT NULL,
                slug TEXT NOT NULL,
                description TEXT,
                photo TEXT,
                province TEXT,
                municipality TEXT,
                trial_until DATE,
                subscription_until DATE,
                created_at DATETIME NOT NULL
            )",
            "CREATE INDEX IF NOT EXISTS idx_stores_province ON stores(province)",
            "CREATE INDEX IF NOT EXISTS idx_stores_municipality ON stores(municipality)",
            "CREATE TABLE IF NOT EXISTS categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                slug TEXT NOT NULL,
                emoji TEXT
            )",
            "CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                store_id INTEGER,
                category_id INTEGER,
                title TEXT NOT NULL,
                description TEXT,
                price_cup INTEGER NOT NULL,
                old_price_cup INTEGER,
                stock INTEGER NOT NULL DEFAULT 0,
                photos TEXT,
                status TEXT NOT NULL DEFAULT 'active',
                views INTEGER NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS cart_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                product_id INTEGER NOT NULL,
                qty INTEGER NOT NULL DEFAULT 1,
                UNIQUE (user_id, product_id)
            )",
            "CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                code TEXT NOT NULL,
                buyer_id INTEGER NOT NULL,
                total_cup INTEGER NOT NULL,
                payment_method TEXT NOT NULL DEFAULT 'efectivo',
                transfer_id TEXT,
                status TEXT NOT NULL DEFAULT 'pendiente',
                address TEXT,
                province TEXT,
                municipality TEXT,
                delivery_lat REAL,
                delivery_lng REAL,
                phone TEXT,
                note TEXT,
                created_at DATETIME NOT NULL
            )",
            "CREATE INDEX IF NOT EXISTS idx_orders_province ON orders(province)",
            "CREATE INDEX IF NOT EXISTS idx_orders_municipality ON orders(municipality)",
            "CREATE TABLE IF NOT EXISTS order_items (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                order_id INTEGER NOT NULL,
                product_id INTEGER,
                store_id INTEGER,
                title TEXT NOT NULL,
                price_cup INTEGER NOT NULL,
                qty INTEGER NOT NULL DEFAULT 1,
                photo TEXT
            )",
            "CREATE TABLE IF NOT EXISTS topups (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                amount_cup INTEGER NOT NULL,
                transfer_id TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'pendiente',
                admin_note TEXT,
                created_at DATETIME NOT NULL,
                processed_at DATETIME
            )",
            "CREATE TABLE IF NOT EXISTS payment_settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                bank_name TEXT,
                card_number TEXT,
                holder TEXT,
                phone TEXT,
                updated_by INTEGER,
                updated_at DATETIME
            )",
            "CREATE TABLE IF NOT EXISTS notifications (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT NOT NULL,
                body TEXT,
                link TEXT,
                is_read INTEGER NOT NULL DEFAULT 0,
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS security_log (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                ip TEXT,
                event TEXT NOT NULL,
                detail TEXT,
                created_at DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS rate_limits (
                ip_action TEXT PRIMARY KEY,
                count INTEGER NOT NULL DEFAULT 0,
                window_start DATETIME NOT NULL
            )",
            "CREATE TABLE IF NOT EXISTS settings (
                k TEXT PRIMARY KEY,
                value TEXT NOT NULL
            )",
        ];
        foreach ($sql as $q) db()->exec($q);
    }
}

/* ---------- Datos de ejemplo ---------- */
function seed_data(): void {
    $g = function (string $name): string { return 'uploads/gallery/' . $name; };

    // Categorías
    $cats = [
        ['Electrónica', 'electronica', '📻'], ['Computadoras', 'computadoras', '💻'],
        ['Hogar y cocina', 'hogar-y-cocina', '🏠'], ['Ropa', 'ropa', '👗'],
        ['Calzado', 'calzado', '👟'], ['Belleza', 'belleza', '💄'],
        ['Deportes', 'deportes', '⚽'], ['Juguetes', 'juguetes', '🧸'],
        ['Herramientas', 'herramientas', '🔧'], ['Música', 'musica', '🎸'],
    ];
    $catId = [];
    $st = db()->prepare('INSERT INTO categories (name, slug, emoji) VALUES (?,?,?)');
    foreach ($cats as $c) { $st->execute($c); $catId[$c[1]] = (int)db()->lastInsertId(); }

    // Usuarios de prueba
    $u = db()->prepare('INSERT INTO users (name, email, phone, password_hash, role, balance_cup, created_at) VALUES (?,?,?,?,?,?,?)');
    $pw = password_hash('Violetero2026', PASSWORD_DEFAULT);
    $now = date('Y-m-d H:i:s');
    $u->execute(['Administrador', 'admin@violetero.cu', '+53 5555 0001', $pw, 'admin', 0, $now]);
    $adminId = (int)db()->lastInsertId();
    $u->execute(['María la Tiendita', 'maria@violetero.cu', '+53 5555 0002', $pw, 'seller', 350, $now]);
    $mariaId = (int)db()->lastInsertId();
    $u->execute(['Carlos Repuestos', 'carlos@violetero.cu', '+53 5555 0003', $pw, 'seller', 120, $now]);
    $carlosId = (int)db()->lastInsertId();
    $u->execute(['Cliente de Prueba', 'cliente@violetero.cu', '+53 5555 0004', $pw, 'customer', 500, $now]);
    $clienteId = (int)db()->lastInsertId();

    // Mini tiendas (con 5 días de prueba gratis y ubicación en Cuba)
    $s = db()->prepare('INSERT INTO stores (owner_id, name, slug, description, photo, province, municipality, trial_until, subscription_until, created_at) VALUES (?,?,?,?,?,?,?,?,?,?)');
    $t5 = date('Y-m-d', time() + TRIAL_DAYS * 86400);
    $s->execute([$mariaId, 'Cosas de María', 'cosas-de-maria', 'Ropa, perfumes y detalles para el hogar. ¡Todo fresquito y barato!', $g('perfume-1.jpeg'), 'la-habana', 'centro-habana', $t5, null, $now]);
    $mariaStore = (int)db()->lastInsertId();
    $s->execute([$carlosId, 'Repuestos Carlos', 'repuestos-carlos', 'Audífonos, altavoces y todo para tu computadora. Garantía de 30 días.', $g('audifonos-1.jpg'), 'artemisa', 'artemisa', $t5, null, $now]);
    $carlosStore = (int)db()->lastInsertId();
    db()->prepare('UPDATE users SET role = ?, default_province = ?, default_municipality = ? WHERE id = ?')->execute(['seller', 'la-habana', 'centro-habana', $mariaId]);
    db()->prepare('UPDATE users SET role = ?, default_province = ?, default_municipality = ? WHERE id = ?')->execute(['seller', 'artemisa', 'artemisa', $carlosId]);
    db()->prepare('UPDATE users SET balance_cup = ? WHERE id = ?')->execute([350, $mariaId]);
    db()->prepare('UPDATE users SET balance_cup = ? WHERE id = ?')->execute([120, $carlosId]);
    // El cliente de prueba vive en La Habana (Vedado)
    db()->prepare('UPDATE users SET default_province = ?, default_municipality = ? WHERE id = ?')->execute(['la-habana', 'plaza-de-la-revolucion', $clienteId]);

    // Ofertas de bienvenida: la web NUNCA arranca vacía
    $p = db()->prepare('INSERT INTO products (store_id, category_id, title, description, price_cup, old_price_cup, stock, photos, status, created_at) VALUES (?,?,?,?,?,?,?,?,?,?)');
    $offers = [
        [null, 'electronica', 'Audífonos inalámbricos TWS', 'Audífonos Bluetooth con estuche de carga, sonido claro y llamadas sin cables. Ideales para música, estudios y trabajo. Entrega a domicilio en toda la ciudad.', 3500, 4200, 12, ['audifonos-1.jpg', 'audifonos-2.jpg'], $carlosStore],
        [null, 'electronica', 'Altavoz Bluetooth portátil', 'Altavoz resistente con buen volumen y batería de larga duración. Perfecto para fiestas, la playa o el patio de la casa.', 4800, null, 10, ['altavoz-1.jpg', 'altavoz-2.jpg'], $carlosStore],
        [null, 'computadoras', 'Laptop lista para trabajar', 'Computadora portátil ligera con buena batería, ideal para estudiar, trabajar y navegar. Se entrega con su cargador.', 32000, 36000, 5, ['laptop-1.jpg'], null],
        [null, 'computadoras', 'Teclado mecánico retroiluminado', 'Teclado mecánico con luces, teclas resistentes y cable reforzado. Muy cómodo para escribir y jugar.', 5600, null, 8, ['teclado-1.webp'], null],
        [null, 'hogar-y-cocina', 'Cafetera espresso 20 bares', 'Cafetera con presión profesional, vaporizador para leche y portafiltro. Un café rico cada mañana sin salir de casa.', 12500, 15000, 6, ['cafetera-1.jpg'], null],
        [null, 'hogar-y-cocina', 'Batidora de pie profesional', 'Batidora con bol de acero, varias velocidades y motor potente. Para panadería, repostería y las mejores recetas de la casa.', 8900, null, 7, ['batidora-1.jpg'], null],
        [$mariaStore, 'belleza', 'Perfume floral 100 ml', 'Fragancia fresca y duradera para el día a día o para regalar. Viene en su caja original con sellado.', 4200, 5000, 15, ['perfume-1.jpeg'], null],
        [$mariaStore, 'ropa', 'Vestido de verano', 'Vestido fresco de tela ligera, corte bonito y colores alegres. Tallas disponibles al confirmar el pedido.', 3200, 3900, 10, ['vestido-1.jpg'], null],
        [$mariaStore, 'calzado', 'Zapatillas de correr', 'Zapatillas ligeras con buena suela y plantilla cómoda. Para correr, caminar o usarlas todos los días.', 6800, null, 9, ['zapatillas-1.jpg'], null],
        [null, 'juguetes', 'Peluche grande de regalo', 'Peluche suave y grande, ideal para cumpleaños, San Valentín o cualquier detalle. Se entrega limpio y en bolsa.', 1900, null, 14, ['juguete-1.jpg'], null],
    ];
    foreach ($offers as $o) {
        $photos = [];
        foreach ($o[7] as $f) $photos[] = $g($f);
        $p->execute([$o[0], $catId[$o[1]], $o[2], $o[3], $o[4], $o[5], $o[6], json_encode(array_values($photos)), 'active', $now]);
    }

    // Datos de cobro de ejemplo (el administrador los cambia en el panel)
    db()->prepare('INSERT INTO payment_settings (bank_name, card_number, holder, phone, updated_by, updated_at) VALUES (?,?,?,?,?,?)')
        ->execute(['Banco de ejemplo (cámbialo en Administración)', '9227 9598 0000 0000 (EJEMPLO)', 'Titular de EJEMPLO', '+53 5 000 0000 (EJEMPLO)', $adminId, $now]);

    // Aviso de bienvenida
    notify($adminId, '¡Bienvenido a Violetero!', 'Tu tienda está instalada con datos de ejemplo. Revisa Administración para cambiar los datos de cobro y gestionar el catálogo.', 'admin/index.php');
    notify($mariaId, 'Tu mini tienda está lista', '¡Tu tienda "Cosas de María" ya está abierta! Tienes 5 días de prueba gratis. Después la suscripción cuesta 200 CUP al mes.', 'vender.php');
    notify($carlosId, 'Tu mini tienda está lista', '¡Tu tienda "Repuestos Carlos" ya está abierta! Tienes 5 días de prueba gratis. Después la suscripción cuesta 200 CUP al mes.', 'vender.php');

    setting_set('catalog_seeded', '1');
    setting_set('installed_at', $now);
    sec_log('instalacion', 'Base de datos instalada con datos de ejemplo');
}

/* ---------- Procesar ---------- */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    try {
        if (!$alreadyInstalled) {
            create_tables();
            seed_data();
        }
        $done = true;
    } catch (Throwable $e) {
        $error = $e->getMessage();
        if (!DEBUG) $error = 'Ocurrió un error durante la instalación. Activa DEBUG en includes/config.php para ver el detalle.';
    }
    if ($done && DB_DRIVER === 'mysql') {
        // Verifica una tabla para confirmar
        try { db()->query('SELECT 1 FROM users LIMIT 1')->fetch(); } catch (Throwable $e) { $done = false; $error = 'No se pudieron crear las tablas en MySQL: ' . (DEBUG ? $e->getMessage() : '(activa DEBUG para ver el detalle)'); }
    }
}

// Si ya está instalada, el instalador queda bloqueado (solo sirve para instalar una vez)
if ($alreadyFullyInstalled && !$done) {
    flash('La tienda ya está instalada. Por seguridad, borra el archivo install.php del servidor.', 'warn');
    redirect('index.php');
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Instalación de <?= e(SITE_NAME) ?></title>
<link rel="icon" type="image/svg+xml" href="assets/img/icon.svg">
<link rel="stylesheet" href="assets/style.css">
</head>
<body>
<div style="max-width:680px;margin:40px auto;padding:0 16px">
  <div class="card" style="max-width:none">
    <div class="row" style="gap:14px;margin-bottom:14px">
      <img src="assets/img/icon.svg" width="56" height="56" alt="Violetero">
      <div>
        <h1 style="color:var(--violet-dark);font-size:24px">Instalación de <?= e(SITE_NAME) ?></h1>
        <p class="muted">Base de datos: <b><?= e(DB_DRIVER === 'mysql' ? 'MySQL (' . e(DB_HOST) . ' / ' . e(DB_NAME) . ')' : 'SQLite (pruebas)') ?></b></p>
      </div>
    </div>

    <?php if ($error): ?><div class="flash flash-err"><?= e($error) ?></div><?php endif; ?>

    <?php if ($done): ?>
      <div class="flash flash-ok">¡Instalación terminada! Tu tienda ya está lista con datos de ejemplo.</div>
      <h2 style="color:var(--violet-dark);font-size:17px;margin:14px 0 8px">Cuentas de prueba (contraseña: <code>Violetero2026</code>)</h2>
      <div class="table-wrap"><table class="tbl">
        <tr><th>Cuenta</th><th>Correo</th><th>Para qué sirve</th></tr>
        <tr><td><b>Administrador</b></td><td>admin@violetero.cu</td><td>Gestionar todo: productos, pedidos, cobros, recargas y seguridad</td></tr>
        <tr><td><b>María la Tiendita</b></td><td>maria@violetero.cu</td><td>Vendedora con mini tienda (Cosas de María)</td></tr>
        <tr><td><b>Carlos Repuestos</b></td><td>carlos@violetero.cu</td><td>Vendedor con mini tienda (Repuestos Carlos)</td></tr>
        <tr><td><b>Cliente de Prueba</b></td><td>cliente@violetero.cu</td><td>Comprar, carrito, pedidos y billetera</td></tr>
      </table></div>
      <div class="flash flash-warn mt">Importante: <b>borra el archivo install.php del servidor</b> (o renómbralo) y cambia la contraseña del administrador desde Mi Cuenta.</div>
      <div class="row mt">
        <a class="btn btn-violet" href="index.php">Abrir la tienda</a>
        <a class="btn btn-outline" href="login.php">Iniciar sesión</a>
      </div>
    <?php else: ?>
      <p>Este asistente crea las tablas de la base de datos y llena la tienda con <b>datos de ejemplo</b> (categorías, ofertas con fotos, mini tiendas y cuentas de prueba) para que puedas probar todo enseguida.</p>
      <ul style="margin:14px 0 14px 20px;font-size:14.5px;line-height:1.9">
        <li>Motor: <b><?= e(DB_DRIVER === 'mysql' ? 'MySQL' : 'SQLite') ?></b></li>
        <li>Después podrás borrar o editar todos los datos de ejemplo desde la Administración.</li>
        <li>Al terminar, <b>borra este archivo (install.php)</b> por seguridad.</li>
      </ul>
      <form method="post"><?= csrf_field() ?>
        <button class="btn btn-violet" type="submit">Instalar <?= e(SITE_NAME) ?> ahora</button>
      </form>
      <p class="help mt">Si da error de conexión, revisa los datos en <b>includes/config.php</b> (servidor, base de datos, usuario y contraseña de MySQL).</p>
    <?php endif; ?>
  </div>
</div>
</body>
</html>
