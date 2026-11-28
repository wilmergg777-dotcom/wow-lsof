<?php
/**
 * Cabecera común de Violetero.
 * Detecta si la página está dentro de admin/ y ajusta las rutas.
 * Variables opcionales antes de incluir:
 *   $page_title  (título de la página)
 *   $hide_nav    (oculta la barra de navegación)
 */
if (!function_exists('e')) require_once __DIR__ . '/auth.php';
$__dirName = trim(dirname($_SERVER['SCRIPT_NAME'] ?? ''), '/');
$__up = ($__dirName === 'admin') ? '../' : '';
$__user = current_user();
$__unread = $__user ? unread_count((int)$__user['id']) : 0;
$__cart = $__user ? cart_count((int)$__user['id']) : 0;
$__is_admin = $__user && $__user['role'] === 'admin';
$__is_seller = $__user && in_array($__user['role'], ['seller', 'admin'], true);
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?= e($page_title ?? SITE_NAME . ' — Tu tienda online en Cuba') ?></title>
<link rel="icon" type="image/svg+xml" href="<?= $__up ?>assets/img/icon.svg">
<link rel="stylesheet" href="<?= $__up ?>assets/style.css">
</head>
<body>
<header class="topbar">
  <div class="topbar-inner">
    <a class="brand" href="<?= $__up ?>index.php">
      <img src="<?= $__up ?>assets/img/icon.svg" alt="Violetero" width="34" height="34">
      <span>Violetero</span>
    </a>
    <form class="searchbar" action="<?= $__up ?>productos.php" method="get">
      <input type="search" name="q" placeholder="Buscar productos en Violetero…" value="<?= e($_GET['q'] ?? '') ?>">
      <button type="submit" aria-label="Buscar"><?= icon('search', 18) ?></button>
    </form>
    <nav class="topnav-actions">
      <?php if ($__user): ?>
        <!-- Saldo del usuario arriba (visible siempre, como en Amazon/eBay) -->
        <a class="balance-chip" href="<?= $__up ?>wallet.php" title="Ver mi billetera">
          <?= icon('wallet', 18) ?>
          <span class="balance-chip-lbl">Saldo</span>
          <b><?= money($__user['balance_cup'] ?? 0) ?></b>
        </a>
        <a class="icon-link" href="<?= $__up ?>notificaciones.php" title="Notificaciones">
          <?= icon('bell', 20) ?>
          <?php if ($__unread > 0): ?><span class="dot"><?= $__unread > 9 ? '9+' : $__unread ?></span><?php endif; ?>
        </a>
        <a class="icon-link" href="<?= $__up ?>carrito.php" title="Carrito">
          <?= icon('shopping-cart', 20) ?>
          <?php if ($__cart > 0): ?><span class="dot"><?= $__cart ?></span><?php endif; ?>
        </a>
        <div class="user-menu">
          <a href="<?= $__up ?>cuenta.php" class="user-chip"><b><?= e(mb_substr($__user['name'], 0, 1)) ?></b><span><?= e($__user['name']) ?></span></a>
          <div class="user-dropdown">
            <a href="<?= $__up ?>cuenta.php"><?= icon('user', 16) ?> Mi Cuenta</a>
            <a href="<?= $__up ?>pedidos.php"><?= icon('package', 16) ?> Mis Pedidos</a>
            <a href="<?= $__up ?>wallet.php"><?= icon('wallet', 16) ?> Mi Billetera</a>
            <a href="<?= $__up ?>invertir.php"><?= icon('trending-up', 16) ?> Invertir</a>
            <a href="<?= $__up ?>vender.php"><?= icon('store', 16) ?> Mi Mini Tienda</a>
            <a href="<?= $__up ?>mensajero-kyc.php"><?= icon('bike', 16) ?> Perfil de mensajero</a>
            <a href="<?= $__up ?>ofertas-mensajeros.php"><?= icon('megaphone', 16) ?> Ofertas de mensajería</a>
            <?php if ($__is_seller ?? false): ?><a href="<?= $__up ?>buscar-mensajeros.php"><?= icon('bike', 16) ?> Buscar mensajeros</a><?php endif; ?>
            <?php if ($__is_admin): ?><a href="<?= $__up ?>admin/index.php"><?= icon('bar-chart', 16) ?> Administración</a><?php endif; ?>
            <a href="<?= $__up ?>logout.php"><?= icon('x', 16) ?> Salir</a>
          </div>
        </div>
      <?php else: ?>
        <a class="btn btn-ghost" href="<?= $__up ?>login.php">Entrar</a>
        <a class="btn btn-yellow" href="<?= $__up ?>registro.php">Crear cuenta</a>
      <?php endif; ?>
    </nav>
  </div>
  <?php if (empty($hide_nav)): ?>
  <nav class="catbar">
    <a href="<?= $__up ?>productos.php">Todo</a>
    <a href="<?= $__up ?>tiendas.php">Mini Tiendas</a>
    <a href="<?= $__up ?>productos.php?ofertas=1">Ofertas</a>
    <?php foreach (top_categories(6) as $c): ?>
      <a href="<?= $__up ?>productos.php?cat=<?= e($c['slug']) ?>"><?= e($c['name']) ?></a>
    <?php endforeach; ?>
  </nav>
  <?php endif; ?>
</header>
<main class="container">
<?php foreach (flash_get() as $f): ?>
  <div class="flash flash-<?= e($f['type']) ?>"><?= e($f['msg']) ?></div>
<?php endforeach; ?>
