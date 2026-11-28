<?php
/** Mis pedidos (comprador). */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('pedidos.php');
$page_title = 'Mis Pedidos — ' . SITE_NAME;

$st = db()->prepare('SELECT o.*, (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.id) AS nitems
                     FROM orders o WHERE o.buyer_id = ? ORDER BY o.id DESC');
$st->execute([$u['id']]);
$orders = $st->fetchAll();
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('package', 26) ?> Mis Pedidos</h1>
<p class="muted mb">Aquí aparecen todas tus compras en KlikCuba.</p>

<?php if (!$orders): ?>
  <div class="card empty"><div class="big"><?= icon('package', 44) ?></div>Todavía no has hecho pedidos.<div class="mt"><a class="btn btn-violet" href="productos.php">Empezar a comprar</a></div></div>
<?php else: ?>
  <div class="card">
    <div class="table-wrap"><table class="tbl">
      <tr><th>Pedido</th><th>Fecha</th><th>Artículos</th><th>Total</th><th>Pago</th><th>Estado</th><th></th></tr>
      <?php foreach ($orders as $o): ?>
      <tr>
        <td><b><?= e($o['code']) ?></b></td>
        <td class="muted" style="white-space:nowrap"><?= e(fdate($o['created_at'])) ?></td>
        <td><?= (int)$o['nitems'] ?> art.</td>
        <td><b><?= money($o['total_cup']) ?></b></td>
        <td><?= $o['payment_method'] === 'transferencia' ? icon('landmark', 14) . ' Transferencia' : icon('banknote', 14) . ' Efectivo' ?></td>
        <td><span class="state st-<?= e($o['status']) ?>"><?= e(ucfirst($o['status'])) ?></span></td>
        <td><a class="btn btn-outline btn-sm" href="pedido.php?id=<?= (int)$o['id'] ?>">Ver detalles</a></td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
