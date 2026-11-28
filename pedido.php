<?php
/** Detalle de un pedido del comprador: datos, pago y acciones. */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('pedidos.php');

$id = (int)($_GET['id'] ?? 0);
$st = db()->prepare('SELECT * FROM orders WHERE id = ? AND buyer_id = ?');
$st->execute([$id, $u['id']]);
$o = $st->fetch();
if (!$o) { flash('No encontramos ese pedido.', 'err'); redirect('pedidos.php'); }

$sti = db()->prepare('SELECT oi.*, s.name AS store_name, s.id AS sid FROM order_items oi LEFT JOIN stores s ON s.id = oi.store_id WHERE oi.order_id = ?');
$sti->execute([$id]);
$items = $sti->fetchAll();

// Enviar el ID de la transferencia más tarde
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'transfer') {
    csrf_check();
    $tid = mb_substr(trim($_POST['transfer_id'] ?? ''), 0, 80);
    if (mb_strlen($tid) < 4) {
        flash('Escribe el ID completo de la transferencia (aparece en el comprobante del banco).', 'err');
    } else {
        db()->prepare('UPDATE orders SET transfer_id = ? WHERE id = ?')->execute([$tid, $id]);
        foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
            notify((int)$adm['id'], 'ID de transferencia enviado', 'El cliente envió el ID de la transferencia del pedido ' . $o['code'] . ': ' . $tid, 'admin/pedidos.php');
        }
        sec_log('transferencia_enviada', 'Pedido ' . $o['code'] . ': ID ' . $tid, (int)$u['id']);
        flash('¡Listo! Guardamos el ID de tu transferencia. El administrador la verificará y confirmará tu pedido.', 'ok');
        redirect('pedido.php?id=' . $id);
    }
}
// Cancelar el pedido si sigue pendiente
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'cancelar') {
    csrf_check();
    if ($o['status'] === 'pendiente') {
        db()->prepare('UPDATE orders SET status = "cancelado" WHERE id = ?')->execute([$id]);
        foreach ($items as $it) if (!empty($it['product_id'])) {
            db()->prepare('UPDATE products SET stock = stock + ? WHERE id = ?')->execute([(int)$it['qty'], (int)$it['product_id']]);
        }
        notify((int)$u['id'], 'Pedido ' . $o['code'] . ' cancelado', 'Cancelaste tu pedido. El stock de los productos volvió a la tienda.', 'pedidos.php');
        sec_log('pedido_cancelado', 'Pedido ' . $o['code'], (int)$u['id']);
        flash('Pedido cancelado. Los productos volvieron al inventario.', 'ok');
        redirect('pedido.php?id=' . $id);
    }
}

$pay = payment_data();
$page_title = 'Pedido ' . $o['code'] . ' — ' . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="breadcrumb"><a href="pedidos.php">Mis Pedidos</a> › Pedido <?= e($o['code']) ?></div>
<h1 style="color:var(--violet-dark)"><?= icon('package', 26) ?> Pedido <?= e($o['code']) ?>
  <span class="state st-<?= e($o['status']) ?>" style="vertical-align:middle;margin-left:8px"><?= e(ucfirst($o['status'])) ?></span>
</h1>
<p class="muted mb">Creado el <?= e(fdate($o['created_at'])) ?></p>

<div class="grid grid-cols-2">
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:10px">Artículos</h2>
    <div class="table-wrap"><table class="tbl">
      <?php foreach ($items as $it): ?>
      <tr>
        <td class="row" style="gap:10px">
          <img class="thumb-sm" src="<?= e($it['photo'] ?: 'assets/img/no-foto.svg') ?>" alt="">
          <div>
            <b><?= e($it['title']) ?></b><br>
            <?php if (!empty($it['sid'])): ?><a class="help" href="tienda.php?id=<?= (int)$it['sid'] ?>">Tienda: <?= e($it['store_name']) ?></a><?php endif; ?>
          </div>
        </td>
        <td style="white-space:nowrap"><?= (int)$it['qty'] ?> × <?= money($it['price_cup']) ?></td>
      </tr>
      <?php endforeach; ?>
      <tr><td style="text-align:right;font-weight:800">TOTAL</td><td style="font-weight:800;color:var(--violet-dark)"><?= money($o['total_cup']) ?></td></tr>
    </table></div>
  </div>

  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:10px">Entrega y pago</h2>
    <div class="row"><b>Dirección:</b><span><?= e($o['address']) ?></span></div>
    <div class="row"><b>Ubicación:</b><span><?= e(province_name($o['province'] ?? null)) ?><?= $o['municipality'] ? ' · ' . e(municipality_name($o['province'] ?? null, $o['municipality'])) : '' ?></span></div>
    <?php
      $glink = maps_link($o['delivery_lat'] ?? null, $o['delivery_lng'] ?? null, $o['address'] ?? null, $o['province'] ?? null, $o['municipality'] ?? null);
    ?>
    <div class="row"><b>Mapa:</b><a href="<?= e($glink) ?>" target="_blank" rel="noopener" class="btn btn-outline btn-sm"><?= icon('map-pin', 14) ?> Ver en Google Maps</a></div>
    <?php if (($o['delivery_lat'] ?? null) && ($o['delivery_lng'] ?? null)): ?>
      <div id="mapa-pedido" style="height:240px;border-radius:10px;overflow:hidden;border:1px solid var(--violet-border);margin:10px 0"></div>
    <?php endif; ?>
    <div class="row"><b>Teléfono:</b><span><?= e($o['phone']) ?></span></div>
    <?php if ($o['note']): ?><div class="row"><b>Nota:</b><span><?= e($o['note']) ?></span></div><?php endif; ?>
    <div class="row"><b>Método:</b><span><?= $o['payment_method'] === 'transferencia' ? icon('landmark', 14) . ' Transferencia bancaria' : icon('banknote', 14) . ' Efectivo' ?></span></div>

    <?php if ($o['payment_method'] === 'transferencia'): ?>
      <div class="paydata">
        <h3>Datos para transferir</h3>
        <div class="row"><b>Banco:</b><span><?= e($pay['bank_name'] ?? '—') ?></span></div>
        <div class="row"><b>Tarjeta:</b><span><?= e($pay['card_number'] ?? '—') ?></span></div>
        <div class="row"><b>Titular:</b><span><?= e($pay['holder'] ?? '—') ?></span></div>
        <div class="row"><b>Teléfono:</b><span><?= e($pay['phone'] ?? '—') ?></span></div>
      </div>
      <div class="row mb">
        <b>ID de la transferencia:</b>
        <span><?= $o['transfer_id'] ? '<span class="badge b-ok">' . e($o['transfer_id']) . '</span>' : '<span class="badge b-warn">Sin enviar</span>' ?></span>
      </div>
      <?php if (!$o['transfer_id'] && $o['status'] === 'pendiente'): ?>
        <form method="post"><?= csrf_field() ?>
          <input type="hidden" name="accion" value="transfer">
          <label class="f">Envía el ID de tu transferencia</label>
          <div class="row">
            <input class="input" name="transfer_id" placeholder="Ej: TB 0012345678" required style="max-width:280px">
            <button class="btn btn-violet" type="submit">Guardar ID</button>
          </div>
          <p class="help mt">El ID aparece en el comprobante del banco o de la app de transferencia (Transfermóvil, EnZona…).</p>
        </form>
      <?php endif; ?>
    <?php endif; ?>

    <?php if ($o['status'] === 'pendiente'): ?>
      <hr class="sep">
      <form method="post" onsubmit="return confirmDel('¿Seguro que quieres cancelar este pedido?')"><?= csrf_field() ?>
        <input type="hidden" name="accion" value="cancelar">
        <button class="btn btn-red btn-sm" type="submit">Cancelar pedido</button>
        <span class="help">Solo puedes cancelar mientras esté pendiente.</span>
      </form>
    <?php endif; ?>
  </div>
</div>

<?php if (($o['delivery_lat'] ?? null) && ($o['delivery_lng'] ?? null)): ?>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="">
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<script>
(function(){
  const lat = <?= (float)$o['delivery_lat'] ?>, lng = <?= (float)$o['delivery_lng'] ?>;
  const m = L.map('mapa-pedido').setView([lat, lng], 15);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: '© OpenStreetMap' }).addTo(m);
  L.marker([lat, lng], { draggable: false }).addTo(m).bindTooltip('Ubicación de entrega').openTooltip();
  setTimeout(function(){ m.invalidateSize(); }, 200);
})();
</script>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
