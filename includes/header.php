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
      <button type="submit" aria-label="Buscar">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></svg>
      </button>
    </form>
    <nav class="topnav-actions">
      <?php if ($__user): ?>
        <a class="icon-link" href="<?= $__up ?>notificaciones.php" title="Notificaciones">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8a6 6 0 10-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 01-3.4 0"/></svg>
          <?php if ($__unread > 0): ?><span class="dot"><?= $__unread > 9 ? '9+' : $__unread ?></span><?php endif; ?>
        </a>
        <a class="icon-link" href="<?= $__up ?>carrito.php" title="Carrito">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="9" cy="21" r="1.6"/><circle cx="19" cy="21" r="1.6"/><path d="M2 3h3l2.6 12.6a2 2 0 002 1.6h9.7a2 2 0 002-1.6L23 7H6"/></svg>
          <?php if ($__cart > 0): ?><span class="dot"><?= $__cart ?></span><?php endif; ?>
        </a>
        <div class="user-menu">
          <a href="<?= $__up ?>cuenta.php" class="user-chip"><b><?= e(mb_substr($__user['name'], 0, 1)) ?></b><span><?= e($__user['name']) ?></span></a>
          <div class="user-dropdown">
            <a href="<?= $__up ?>cuenta.php">Mi Cuenta</a>
            <a href="<?= $__up ?>pedidos.php">Mis Pedidos</a>
            <a href="<?= $__up ?>wallet.php">Mi Billetera</a>
            <a href="<?= $__up ?>vender.php">Mi Mini Tienda</a>
            <?php if ($__is_admin): ?><a href="index.php">Administración</a><?php endif; ?>
            <a href="<?= $__up ?>logout.php">Salir</a>
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
