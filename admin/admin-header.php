<?php
/** Cabecera del panel de administración (usa la plantilla general). */
if (!function_exists('e')) require_once __DIR__ . '/../includes/auth.php';
$adminMenu = [
    'index.php' => '📊 Resumen',
    'pedidos.php' => '🧾 Pedidos',
    'productos.php' => '📦 Productos',
    'tiendas.php' => '🏪 Mini tiendas',
    'usuarios.php' => '👥 Usuarios',
    'cobros.php' => '🏦 Datos de cobro',
    'recargas.php' => '💰 Recargas',
    'seguridad.php' => '🛡️ Seguridad',
];
$adminActual = basename($_SERVER['SCRIPT_NAME'] ?? '');
ob_start();
?>
<div class="admin-layout">
  <nav class="admin-nav">
    <?php foreach ($adminMenu as $f => $lbl): ?>
      <a href="<?= e($f) ?>" class="<?= $adminActual === $f ? 'on' : '' ?>"><?= e($lbl) ?></a>
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
