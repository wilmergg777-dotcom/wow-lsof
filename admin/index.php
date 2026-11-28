<?php
/** Panel de administración: estadísticas generales. */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Administración — ' . SITE_NAME;
$tab = 'inicio';

$stats = db()->query('SELECT
    (SELECT COUNT(*) FROM users) AS usuarios,
    (SELECT COUNT(*) FROM stores) AS tiendas,
    (SELECT COUNT(*) FROM products WHERE status = "active") AS productos,
    (SELECT COUNT(*) FROM products WHERE stock <= 0 AND status = "active") AS agotados,
    (SELECT COUNT(*) FROM orders) AS pedidos,
    (SELECT COUNT(*) FROM orders WHERE status = "pendiente") AS pendientes,
    (SELECT COUNT(*) FROM topups WHERE status = "pendiente") AS recargas_pend,
    (SELECT COALESCE(SUM(total_cup),0) FROM orders WHERE status = "entregado") AS vendido,
    (SELECT COUNT(*) FROM notifications WHERE title LIKE "%bloqueada%") AS bloqueos')->fetch();

$ultimos = db()->query('SELECT o.*, u.name AS buyer FROM orders o LEFT JOIN users u ON u.id = o.buyer_id ORDER BY o.id DESC LIMIT 8')->fetchAll();
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('bar-chart', 26) ?> Resumen general</h1>

<div class="stat-grid">
  <div class="stat"><div class="n"><?= (int)$stats['usuarios'] ?></div><div class="l">Usuarios registrados</div></div>
  <div class="stat"><div class="n"><?= (int)$stats['tiendas'] ?></div><div class="l">Mini tiendas</div></div>
  <div class="stat"><div class="n"><?= (int)$stats['productos'] ?></div><div class="l">Productos a la venta</div>
    <?php if ((int)$stats['agotados'] > 0): ?><div class="sub"><?= (int)$stats['agotados'] ?> agotados</div><?php endif; ?></div>
  <div class="stat"><div class="n"><?= (int)$stats['pedidos'] ?></div><div class="l">Pedidos totales</div>
    <?php if ((int)$stats['pendientes'] > 0): ?><div class="sub"><?= (int)$stats['pendientes'] ?> pendientes</div><?php endif; ?></div>
  <div class="stat"><div class="n"><?= money($stats['vendido']) ?></div><div class="l">Total vendido y entregado</div></div>
  <div class="stat"><div class="n"><?= (int)$stats['recargas_pend'] ?></div><div class="l">Recargas por verificar</div></div>
  <div class="stat"><div class="n"><?= (int)$stats['bloqueos'] ?></div><div class="l">Cuentas bloqueadas (histórico)</div></div>
</div>

<?php if ((int)$stats['recargas_pend'] > 0 || (int)$stats['pendientes'] > 0): ?>
  <div class="flash flash-warn">Tienes tareas pendientes: <b><?= (int)$stats['pendientes'] ?></b> pedidos sin atender y <b><?= (int)$stats['recargas_pend'] ?></b> recargas por verificar.</div>
<?php endif; ?>

<div class="card">
  <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:10px">Últimos pedidos</h2>
  <div class="table-wrap"><table class="tbl">
    <tr><th>Pedido</th><th>Cliente</th><th>Fecha</th><th>Total</th><th>Pago</th><th>Estado</th></tr>
    <?php foreach ($ultimos as $o): ?>
    <tr>
      <td><a href="pedidos.php?id=<?= (int)$o['id'] ?>"><b><?= e($o['code']) ?></b></a></td>
      <td><?= e($o['buyer'] ?? '—') ?></td>
      <td class="muted" style="white-space:nowrap"><?= e(fdate($o['created_at'])) ?></td>
      <td><b><?= money($o['total_cup']) ?></b></td>
      <td><?= $o['payment_method'] === 'transferencia' ? icon('landmark', 14) : icon('banknote', 14) ?> <?= e($o['payment_method']) ?></td>
      <td><span class="state st-<?= e($o['status']) ?>"><?= e(ucfirst($o['status'])) ?></span></td>
    </tr>
    <?php endforeach; ?>
  </table></div>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
