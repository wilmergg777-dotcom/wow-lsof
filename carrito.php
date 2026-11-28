<?php
/** Carrito de compras. */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('carrito.php');
$page_title = 'Mi Carrito — ' . SITE_NAME;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';
    $pid = (int)($_POST['product_id'] ?? 0);
    if ($accion === 'quitar' && $pid) {
        db()->prepare('DELETE FROM cart_items WHERE user_id = ? AND product_id = ?')->execute([$u['id'], $pid]);
        flash('Producto quitado del carrito.', 'ok');
    }
    if ($accion === 'cantidad' && $pid) {
        $qty = max(0, min((int)($_POST['qty'] ?? 1), 99));
        if ($qty === 0) {
            db()->prepare('DELETE FROM cart_items WHERE user_id = ? AND product_id = ?')->execute([$u['id'], $pid]);
        } else {
            $st = db()->prepare('SELECT stock FROM products WHERE id = ?');
            $st->execute([$pid]);
            $max = (int)($st->fetch()['stock'] ?? 0);
            db()->prepare('UPDATE cart_items SET qty = ? WHERE user_id = ? AND product_id = ?')->execute([min($qty, max($max, 1)), $u['id'], $pid]);
        }
        flash('Carrito actualizado.', 'ok');
    }
    redirect('carrito.php');
}

$st = db()->prepare('SELECT ci.qty, p.id, p.title, p.price_cup, p.old_price_cup, p.stock, p.photos, p.store_id, s.name AS store_name, s.trial_until, s.subscription_until
                     FROM cart_items ci
                     JOIN products p ON p.id = ci.product_id
                     LEFT JOIN stores s ON s.id = p.store_id
                     WHERE ci.user_id = ? ORDER BY ci.id DESC');
$st->execute([$u['id']]);
$items = $st->fetchAll();

// Quita de la vista los productos agotados o de tiendas suspendidas
$valid = [];
$removed = [];
foreach ($items as $it) {
    $suspended = !empty($it['store_id']) && store_status(['trial_until' => $it['trial_until'], 'subscription_until' => $it['subscription_until']]) === 'suspendida';
    if ((int)$it['stock'] <= 0 || $suspended) { $removed[] = $it['title']; continue; }
    $valid[] = $it;
}
$total = array_sum(array_map(fn($i) => $i['price_cup'] * $i['qty'], $valid));
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('shopping-cart', 26) ?> Mi Carrito</h1>

<?php if ($removed): ?>
  <div class="flash flash-warn">Quitamos del carrito: <?= e(implode(', ', $removed)) ?> (agotado o tienda suspendida).</div>
<?php endif; ?>

<?php if (!$valid): ?>
  <div class="card empty"><div class="big"><?= icon('shopping-cart', 44) ?></div>Tu carrito está vacío.<div class="mt"><a class="btn btn-violet" href="productos.php">Ver productos</a></div></div>
<?php else: ?>
  <div class="card">
    <div class="table-wrap"><table class="tbl">
      <tr><th>Producto</th><th>Precio</th><th>Cantidad</th><th>Subtotal</th><th></th></tr>
      <?php foreach ($valid as $it): ?>
      <tr>
        <td class="row" style="gap:10px">
          <img class="thumb-sm" src="<?= e(photo_of($it['photos'])) ?>" alt="">
          <a class="t-title" href="producto.php?id=<?= (int)$it['id'] ?>"><?= e($it['title']) ?></a>
        </td>
        <td><b><?= money($it['price_cup']) ?></b></td>
        <td>
          <form method="post" class="row" style="gap:6px"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="cantidad">
            <input type="hidden" name="product_id" value="<?= (int)$it['id'] ?>">
            <input type="number" class="input" style="width:66px;padding:6px" name="qty" value="<?= (int)$it['qty'] ?>" min="1" max="<?= (int)$it['stock'] ?>">
            <button class="btn btn-outline btn-sm" type="submit">OK</button>
          </form>
          <div class="help">Máx: <?= (int)$it['stock'] ?></div>
        </td>
        <td><b style="color:var(--violet-dark)"><?= money($it['price_cup'] * $it['qty']) ?></b></td>
        <td>
          <form method="post"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="quitar">
            <input type="hidden" name="product_id" value="<?= (int)$it['id'] ?>">
            <button class="btn btn-red btn-sm" type="submit">Quitar</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
      <tr>
        <td colspan="3" style="text-align:right;font-weight:700">Total a pagar:</td>
        <td style="font-size:19px;font-weight:800;color:var(--violet-dark)"><?= money($total) ?></td>
        <td></td>
      </tr>
    </table></div>
    <div class="row mt" style="justify-content:flex-end">
      <a class="btn btn-outline" href="productos.php">Seguir comprando</a>
      <a class="btn btn-yellow" href="checkout.php">Continuar al pago →</a>
    </div>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
