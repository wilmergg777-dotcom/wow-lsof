<?php
/** Ventas recibidas del vendedor: pedidos que incluyen productos de su tienda. */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller();
$page_title = 'Ventas Recibidas — ' . SITE_NAME;

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$store = $st->fetch();
if (!$store) { flash('Primero crea tu mini tienda.', 'info'); redirect('mi-tienda.php'); }
$sid = (int)$store['id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $orderId = (int)($_POST['order_id'] ?? 0);
    $new = $_POST['status'] ?? '';
    // El vendedor solo puede tocar pedidos donde participan sus productos
    $chk = db()->prepare('SELECT COUNT(*) c FROM order_items WHERE order_id = ? AND store_id = ?');
    $chk->execute([$orderId, $sid]);
    if ((int)$chk->fetch()['c'] === 0) { flash('Ese pedido no tiene productos de tu tienda.', 'err'); redirect('ventas.php'); }

    $validos = ['pendiente' => 'pendiente', 'confirmado' => 'confirmado', 'entregado' => 'entregado'];
    if (isset($validos[$new])) {
        // Cambia el estado global del pedido (el comprador lo ve)
        db()->prepare('UPDATE orders SET status = ? WHERE id = ?')->execute([$new, $orderId]);
        $st2 = db()->prepare('SELECT o.*, u.id AS buyer_id FROM orders o JOIN users u ON u.id = o.buyer_id WHERE o.id = ?');
        $st2->execute([$orderId]);
        $o = $st2->fetch();
        if ($o) {
            $txt = ['confirmado' => 'El vendedor confirmó tu pedido ' . $o['code'] . '. Prepara el pago o espera la verificación de la transferencia.',
                    'entregado' => 'Tu pedido ' . $o['code'] . ' fue entregado. ¡Gracias por comprar en Violetero!',
                    'pendiente' => 'Tu pedido ' . $o['code'] . ' volvió a pendiente.'];
            notify((int)$o['buyer_id'], 'Tu pedido ' . $o['code'] . ': ' . ucfirst($new), $txt[$new], 'pedido.php?id=' . $orderId);
            if ($new === 'entregado') sec_log('pedido_entregado', 'Pedido ' . $o['code'] . ' marcado entregado por ' . $store['name'], (int)$u['id']);
        }
        flash('Pedido actualizado a «' . ucfirst($new) . '». El comprador recibió un aviso.', 'ok');
    }
    redirect('ventas.php');
}

// Pedidos con productos de esta tienda
$orders = db()->prepare('SELECT DISTINCT o.*, (SELECT COALESCE(SUM(qty * price_cup),0) FROM order_items oi WHERE oi.order_id = o.id AND oi.store_id = ?) AS mi_parte,
                            (SELECT COUNT(*) FROM order_items oi WHERE oi.order_id = o.id AND oi.store_id = ?) AS mis_items
                         FROM orders o JOIN order_items oi ON oi.order_id = o.id
                         WHERE oi.store_id = ? ORDER BY o.id DESC LIMIT 100');
$orders->execute([$sid, $sid, $sid]);
$pedidos = $orders->fetchAll();
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('receipt', 26) ?> Ventas recibidas — <?= e($store['name']) ?></h1>
<p class="muted mb">Pedidos de la comunidad que incluyen productos tuyos. Cambia el estado para avisar al comprador.</p>

<?php if (!$pedidos): ?>
  <div class="card empty"><div class="big"><?= icon('receipt', 44) ?></div>Todavía no te han comprado. Publica más productos y comparte tu tienda.<div class="mt"><a class="btn btn-violet" href="publicar.php">Publicar producto</a></div></div>
<?php else: ?>
  <?php foreach ($pedidos as $o): ?>
    <?php
    $sti = db()->prepare('SELECT oi.*, u.name AS buyer_name, u.phone AS buyer_phone, u.email AS buyer_email FROM order_items oi JOIN orders o ON o.id = oi.order_id JOIN users u ON u.id = o.buyer_id WHERE oi.order_id = ? AND oi.store_id = ?');
    $sti->execute([(int)$o['id'], $sid]);
    $mis = $sti->fetchAll();
    ?>
    <div class="card mb">
      <div class="row-between">
        <div>
          <b style="font-size:16px"><?= e($o['code']) ?></b>
          <span class="state st-<?= e($o['status']) ?>" style="margin-left:8px"><?= e(ucfirst($o['status'])) ?></span>
          <div class="help"><?= e(fdate($o['created_at'])) ?> · <?= $o['payment_method'] === 'transferencia' ? icon('landmark', 14) . ' Transferencia' . (!empty($o['transfer_id']) ? ' (ID: ' . e($o['transfer_id']) . ')' : ' (sin ID aún)') : icon('banknote', 14) . ' Efectivo' ?></div>
        </div>
        <div style="text-align:right">
          <div class="help">Tu parte</div>
          <div style="font-weight:800;color:var(--violet-dark)"><?= money($o['mi_parte']) ?></div>
        </div>
      </div>
      <div class="table-wrap mt"><table class="tbl">
        <tr><th>Producto</th><th>Cant.</th><th>Importe</th></tr>
        <?php foreach ($mis as $it): ?>
        <tr><td class="t-title"><?= e($it['title']) ?></td><td><?= (int)$it['qty'] ?></td><td><?= money((int)$it['qty'] * (int)$it['price_cup']) ?></td></tr>
        <?php endforeach; ?>
      </table></div>
      <div class="row mt" style="gap:8px">
        <span class="badge b-info"><?= icon('user', 14) ?> <?= e($mis[0]['buyer_name'] ?? 'Cliente') ?></span>
        <span class="badge b-info"><?= icon('phone', 14) ?> <?= e($o['phone']) ?></span>
        <span class="badge b-info"><?= icon('map-pin', 14) ?> <?= e($o['address']) ?><?php if (!empty($o['province'])): ?> · <?= e(province_name($o['province'])) ?><?php if (!empty($o['municipality'])): ?>, <?= e(municipality_name($o['province'], $o['municipality'])) ?><?php endif; endif; ?></span>
        <a class="badge b-ok" href="<?= e(maps_link($o['delivery_lat'] ?? null, $o['delivery_lng'] ?? null, $o['address'] ?? null, $o['province'] ?? null, $o['municipality'] ?? null)) ?>" target="_blank" rel="noopener"><?= icon('map-pin', 14) ?> Cómo llegar (Google Maps)</a>
        <?php if ($o['note']): ?><span class="badge b-info"><?= icon('message-circle', 14) ?> <?= e($o['note']) ?></span><?php endif; ?>
      </div>
      <div class="row mt">
        <form method="post" class="row"><?= csrf_field() ?>
          <input type="hidden" name="order_id" value="<?= (int)$o['id'] ?>">
          <label class="f" style="margin:0">Cambiar estado:</label>
          <select class="input" name="status" style="width:auto;padding:7px">
            <option value="pendiente" <?= $o['status'] === 'pendiente' ? 'selected' : '' ?>>Pendiente</option>
            <option value="confirmado" <?= $o['status'] === 'confirmado' ? 'selected' : '' ?>>Confirmado</option>
            <option value="entregado" <?= $o['status'] === 'entregado' ? 'selected' : '' ?>>Entregado</option>
          </select>
          <button class="btn btn-violet btn-sm" type="submit">Actualizar</button>
        </form>
      </div>
    </div>
  <?php endforeach; ?>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
