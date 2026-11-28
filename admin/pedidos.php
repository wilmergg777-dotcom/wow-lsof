<?php
/** Admin: todos los pedidos con cambio de estado. */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Pedidos — Administración';

$estados = ['pendiente', 'confirmado', 'entregado', 'cancelado'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $oid = (int)($_POST['order_id'] ?? 0);
    $new = $_POST['status'] ?? '';
    $st = db()->prepare('SELECT * FROM orders WHERE id = ?');
    $st->execute([$oid]);
    $o = $st->fetch();
    if ($o && in_array($new, $estados, true)) {
        db()->prepare('UPDATE orders SET status = ? WHERE id = ?')->execute([$new, $oid]);
        // Si se cancela, devuelve el stock
        if ($new === 'cancelado' && $o['status'] !== 'cancelado') {
            $sti = db()->prepare('SELECT * FROM order_items WHERE order_id = ?');
            $sti->execute([$oid]);
            foreach ($sti->fetchAll() as $it) {
                if (!empty($it['product_id'])) db()->prepare('UPDATE products SET stock = stock + ? WHERE id = ?')->execute([(int)$it['qty'], (int)$it['product_id']]);
            }
        }
        notify((int)$o['buyer_id'], 'Tu pedido ' . $o['code'] . ': ' . ucfirst($new), 'El estado de tu pedido cambió a ' . ucfirst($new) . '. Revisa los detalles.', '../pedido.php?id=' . $oid);
        sec_log('admin_pedido', 'Pedido ' . $o['code'] . ' → ' . $new, (int)$admin['id']);
        flash('Pedido ' . $o['code'] . ' actualizado a «' . ucfirst($new) . '».', 'ok');
    }
    redirect('pedidos.php' . (!empty($_GET['f']) ? '?f=' . urlencode($_GET['f']) : ''));
}

$filtro = $_GET['f'] ?? '';
if (in_array($filtro, $estados, true)) {
    $st = db()->prepare('SELECT o.*, u.name AS buyer FROM orders o LEFT JOIN users u ON u.id = o.buyer_id WHERE o.status = ? ORDER BY o.id DESC LIMIT 200');
    $st->execute([$filtro]);
} else {
    $st = db()->prepare('SELECT o.*, u.name AS buyer FROM orders o LEFT JOIN users u ON u.id = o.buyer_id ORDER BY o.id DESC LIMIT 200');
    $st->execute();
}
$orders = $st->fetchAll();
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('receipt', 26) ?> Pedidos</h1>

<div class="pill-tabs">
  <a href="pedidos.php" class="<?= $filtro === '' ? 'on' : '' ?>">Todos</a>
  <?php foreach ($estados as $es): ?>
    <a href="pedidos.php?f=<?= e($es) ?>" class="<?= $filtro === $es ? 'on' : '' ?>"><?= ucfirst($es) ?></a>
  <?php endforeach; ?>
</div>

<?php if (!$orders): ?>
  <div class="card empty">No hay pedidos <?= $filtro ? 'en estado «' . e($filtro) . '»' : '' ?>.</div>
<?php else: ?>
  <div class="card">
    <div class="table-wrap"><table class="tbl">
      <tr><th>Pedido</th><th>Cliente</th><th>Fecha</th><th>Total</th><th>Pago</th><th>Entrega</th><th>ID transfer.</th><th>Estado</th><th>Cambiar a</th></tr>
      <?php foreach ($orders as $o): ?>
      <tr>
        <td><a href="../pedido.php?id=<?= (int)$o['id'] ?>"><b><?= e($o['code']) ?></b></a></td>
        <td><?= e($o['buyer'] ?? '—') ?><br><span class="help"><?= e($o['phone']) ?></span></td>
        <td class="muted" style="white-space:nowrap"><?= e(fdate($o['created_at'])) ?></td>
        <td><b><?= money($o['total_cup']) ?></b></td>
        <td><?= $o['payment_method'] === 'transferencia' ? icon('landmark', 14) : icon('banknote', 14) ?></td>
        <td class="help">
          <?= e($o['address'] ?: '—') ?><br>
          <?php if (!empty($o['province'])): ?>📍 <?= e(province_name($o['province'])) ?><?php if (!empty($o['municipality'])): ?> · <?= e(municipality_name($o['province'], $o['municipality'])) ?><?php endif; ?><br><?php endif; ?>
          <a href="<?= e(maps_link($o['delivery_lat'] ?? null, $o['delivery_lng'] ?? null, $o['address'] ?? null, $o['province'] ?? null, $o['municipality'] ?? null)) ?>" target="_blank" rel="noopener" style="font-size:12px"><?= icon('map-pin', 12) ?> Google Maps</a>
        </td>
        <td class="help"><?= e($o['transfer_id'] ?: '—') ?></td>
        <td><span class="state st-<?= e($o['status']) ?>"><?= e(ucfirst($o['status'])) ?></span></td>
        <td>
          <form method="post" class="row" style="gap:4px"><?= csrf_field() ?>
            <input type="hidden" name="order_id" value="<?= (int)$o['id'] ?>">
            <select class="input" name="status" style="width:auto;padding:6px">
              <?php foreach ($estados as $es): if ($es === $o['status']) continue; ?>
                <option value="<?= e($es) ?>"><?= ucfirst($es) ?></option>
              <?php endforeach; ?>
            </select>
            <button class="btn btn-outline btn-sm" type="submit">OK</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/admin-footer.php'; ?>
