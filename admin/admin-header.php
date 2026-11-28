<?php
/** Cabecera del panel de administración (usa la plantilla general). */
if (!function_exists('e')) require_once __DIR__ . '/../includes/auth.php';
$adminMenu = [
    'index.php'      => [icon('bar-chart', 16), 'Resumen'],
    'pedidos.php'    => [icon('receipt', 16), 'Pedidos'],
    'productos.php'  => [icon('package', 16), 'Productos'],
    'tiendas.php'    => [icon('store', 16), 'Mini tiendas'],
    'usuarios.php'   => [icon('users', 16), 'Usuarios'],
    'inversiones.php' => [icon('trending-up', 16), 'Inversiones'],
    'mensajeros.php' => [icon('bike', 16), 'Mensajeros KYC'],
    'cobros.php'     => [icon('landmark', 16), 'Datos de cobro'],
    'mis-bancos.php' => [icon('credit-card', 16), 'Mis bancos'],
    'recargas.php'   => [icon('wallet', 16), 'Recargas'],
    'seguridad.php'  => [icon('shield', 16), 'Seguridad'],
];
$adminActual = basename($_SERVER['SCRIPT_NAME'] ?? '');
ob_start();
?>
<div class="admin-layout">
  <nav class="admin-nav">
    <?php foreach ($adminMenu as $f => $lbl): ?>
      <a href="<?= e($f) ?>" class="<?= $adminActual === $f ? 'on' : '' ?>"><?= $lbl[0] ?> <?= e($lbl[1]) ?></a>
    <?php endforeach; ?>
    <hr class="sep" style="border-color:rgba(255,255,255,.15)">
    <a href="../index.php">← Volver a la tienda</a>
  </nav>
  <div>
<?php
$__adminNavHtml = ob_get_clean();
$hide_nav = false;
include __DIR__ . '/../includes/header.php';
echo $__adminNavHtml;
