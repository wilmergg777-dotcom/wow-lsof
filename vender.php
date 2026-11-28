<?php
/** Panel del vendedor: resumen de su mini tienda. */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller();
$page_title = 'Panel del Vendedor — ' . SITE_NAME;

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$store = $st->fetch();

if (!$store) {
    flash('Primero crea tu mini tienda (es gratis).', 'info');
    redirect('mi-tienda.php');
}
$status = store_status($store);

$stats = db()->prepare('SELECT
    (SELECT COUNT(*) FROM products WHERE store_id = ? AND status = "active") AS activos,
    (SELECT COUNT(*) FROM products WHERE store_id = ? AND stock <= 0) AS agotados,
    (SELECT COALESCE(SUM(qty * price_cup), 0) FROM order_items oi JOIN orders o ON o.id = oi.order_id WHERE oi.store_id = ? AND o.status = "pendiente") AS pendiente,
    (SELECT COALESCE(SUM(qty * price_cup), 0) FROM order_items oi JOIN orders o ON o.id = oi.order_id WHERE oi.store_id = ? AND o.status = "entregado") AS vendido');
$stats->execute([$store['id'], $store['id'], $store['id'], $store['id']]);
$s = $stats->fetch();
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('store', 26) ?> <?= e($store['name']) ?></h1>
<div class="row mb"><?= store_status_badge($store) ?>
  <?php if ($status === 'prueba'): ?><span class="help">Prueba gratis hasta el <?= e($store['trial_until']) ?></span><?php endif; ?>
  <?php if ($status === 'activa'): ?><span class="help">Suscripción al día hasta el <?= e($store['subscription_until']) ?></span><?php endif; ?>
</div>

<?php if ($status === 'suspendida'): ?>
  <div class="flash flash-warn"><b>¡Tu prueba de <?= TRIAL_DAYS ?> días terminó!</b> Tu tienda está suspendida para el público. Paga la suscripción de <b><?= money(SUBSCRIPTION_CUP) ?> al mes</b> con tu saldo (tienes <?= money($u['balance_cup']) ?>) desde <a href="suscripcion.php">Suscripción</a>.</div>
<?php endif; ?>

<div class="stat-grid">
  <div class="stat"><div class="n"><?= (int)$s['activos'] ?></div><div class="l">Productos a la venta</div></div>
  <div class="stat"><div class="n"><?= (int)$s['agotados'] ?></div><div class="l">Productos agotados</div></div>
  <div class="stat"><div class="n"><?= money($s['pendiente']) ?></div><div class="l">Ventas por cobrar (pedidos pendientes)</div></div>
  <div class="stat"><div class="n"><?= money($s['vendido']) ?></div><div class="l">Total vendido y entregado</div></div>
</div>

<div class="grid grid-cols-2">
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:10px">Gestionar</h2>
    <div class="row">
      <a class="btn btn-yellow" href="publicar.php"><?= icon('shopping-cart', 16) ?> Publicar producto</a>
      <a class="btn btn-violet" href="mis-productos.php"><?= icon('package', 16) ?> Inventario</a>
      <a class="btn btn-outline" href="ventas.php"><?= icon('receipt', 16) ?> Ventas recibidas</a>
    </div>
    <div class="row mt">
      <a class="btn btn-outline" href="mi-tienda.php"><?= icon('store', 16) ?> Datos de mi tienda</a>
      <a class="btn btn-outline" href="suscripcion.php"><?= icon('wallet', 16) ?> Suscripción</a>
      <a class="btn btn-outline" href="tienda.php?id=<?= (int)$store['id'] ?>"><?= icon('search', 16) ?> Ver mi tienda</a>
    </div>
  </div>
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:10px">Cómo funciona la venta</h2>
    <ol style="margin-left:18px;font-size:14.5px;line-height:1.9">
      <li>Publicas productos con fotos y precio en CUP.</li>
      <li>Alguien compra: te llega un aviso y ves la venta en <b>Ventas recibidas</b>.</li>
      <li>El pago llega en efectivo o por transferencia (los datos de cobro los pone el administrador).</li>
      <li>Entregas y marcas el pedido como <b>entregado</b>.</li>
      <li>El stock se descuenta solo al comprar y vuelve si se cancela.</li>
    </ol>
  </div>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
