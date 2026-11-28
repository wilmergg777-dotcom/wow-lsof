<?php
/** Inventario del vendedor: sus productos con stock, estado y acciones rápidas. */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller();
$page_title = 'Inventario — ' . SITE_NAME;

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$store = $st->fetch();
if (!$store) { flash('Primero crea tu mini tienda.', 'info'); redirect('mi-tienda.php'); }

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $pid = (int)($_POST['product_id'] ?? 0);
    $accion = $_POST['accion'] ?? '';
    // Solo productos de su tienda
    $st = db()->prepare('SELECT * FROM products WHERE id = ? AND store_id = ?');
    $st->execute([$pid, $store['id']]);
    $p = $st->fetch();
    if (!$p) { flash('Ese producto no es de tu tienda.', 'err'); redirect('mis-productos.php'); }

    if ($accion === 'ocultar') {
        db()->prepare('UPDATE products SET status = "oculto" WHERE id = ?')->execute([$pid]);
        flash('«' . $p['title'] . '» ocultado del catálogo.', 'ok');
    }
    if ($accion === 'mostrar') {
        db()->prepare('UPDATE products SET status = "active" WHERE id = ?')->execute([$pid]);
        flash('«' . $p['title'] . '» vuelve a estar a la venta.', 'ok');
    }
    if ($accion === 'stock') {
        $q = max(0, (int)($_POST['qty'] ?? 0));
        db()->prepare('UPDATE products SET stock = ?, status = CASE WHEN ? > 0 AND status = "active" THEN "active" WHEN ? <= 0 THEN "active" ELSE status END WHERE id = ?')
            ->execute([$q, $q, $q, $pid]);
        flash('Stock actualizado a ' . $q . ' unidades.', 'ok');
    }
    if ($accion === 'borrar' && ($_POST['confirm'] ?? '') === 'si') {
        db()->prepare('DELETE FROM products WHERE id = ?')->execute([$pid]);
        db()->prepare('DELETE FROM cart_items WHERE product_id = ?')->execute([$pid]);
        flash('Producto eliminado.', 'ok');
    }
    redirect('mis-productos.php');
}

$st = db()->prepare('SELECT p.*, c.name AS cat_name, c.emoji AS cat_emoji FROM products p LEFT JOIN categories c ON c.id = p.category_id WHERE p.store_id = ? ORDER BY p.id DESC');
$st->execute([$store['id']]);
$items = $st->fetchAll();
include __DIR__ . '/includes/header.php';
?>
<div class="row-between mb">
  <h1 style="color:var(--violet-dark)"><?= icon('package', 26) ?> Inventario de <?= e($store['name']) ?></h1>
  <a class="btn btn-yellow" href="publicar.php"><?= icon('shopping-cart', 16) ?> Publicar producto</a>
</div>

<?php if (!$items): ?>
  <div class="card empty"><div class="big"><?= icon('package', 44) ?></div>Tu inventario está vacío.<div class="mt"><a class="btn btn-violet" href="publicar.php">Publicar el primer producto</a></div></div>
<?php else: ?>
  <div class="card">
    <div class="table-wrap"><table class="tbl">
      <tr><th>Producto</th><th>Precio</th><th>Stock</th><th>Estado</th><th>Vistas</th><th>Acciones</th></tr>
      <?php foreach ($items as $p): $off = !empty($p['old_price_cup']) && (int)$p['old_price_cup'] > (int)$p['price_cup']; ?>
      <tr>
        <td class="row" style="gap:10px">
          <img class="thumb-sm" src="<?= e(photo_of($p['photos'])) ?>" alt="">
          <div>
            <a class="t-title" href="producto.php?id=<?= (int)$p['id'] ?>"><?= e($p['title']) ?></a><br>
            <span class="help"><?= $p['cat_emoji'] ? e($p['cat_emoji'] . ' ' . $p['cat_name']) : 'Sin categoría' ?></span>
          </div>
        </td>
        <td style="white-space:nowrap">
          <b><?= money($p['price_cup']) ?></b>
          <?php if ($off): ?><br><span class="price-old"><?= money($p['old_price_cup']) ?></span><?php endif; ?>
        </td>
        <td>
          <form method="post" class="row" style="gap:6px"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="stock">
            <input type="hidden" name="product_id" value="<?= (int)$p['id'] ?>">
            <input class="input" style="width:64px;padding:6px" type="number" name="qty" value="<?= (int)$p['stock'] ?>" min="0">
            <button class="btn btn-outline btn-sm" type="submit">OK</button>
          </form>
          <?php if ((int)$p['stock'] <= 0): ?><span class="badge b-agotado">AGOTADO</span><?php endif; ?>
        </td>
        <td>
          <?php if ($p['status'] === 'active'): ?><span class="badge b-ok">A la venta</span>
          <?php else: ?><span class="badge b-warn">Oculto</span><?php endif; ?>
        </td>
        <td class="muted"><?= (int)$p['views'] ?></td>
        <td>
          <div class="row" style="gap:6px">
            <a class="btn btn-outline btn-sm" href="publicar.php?id=<?= (int)$p['id'] ?>">Editar</a>
            <form method="post"><?= csrf_field() ?>
              <input type="hidden" name="product_id" value="<?= (int)$p['id'] ?>">
              <input type="hidden" name="accion" value="<?= $p['status'] === 'active' ? 'ocultar' : 'mostrar' ?>">
              <button class="btn btn-outline btn-sm" type="submit"><?= $p['status'] === 'active' ? 'Ocultar' : 'Mostrar' ?></button>
            </form>
            <form method="post" onsubmit="return confirmDel('¿Eliminar «<?= e($p['title']) ?>» para siempre?')"><?= csrf_field() ?>
              <input type="hidden" name="product_id" value="<?= (int)$p['id'] ?>">
              <input type="hidden" name="accion" value="borrar">
              <input type="hidden" name="confirm" value="si">
              <button class="btn btn-red btn-sm" type="submit">Eliminar</button>
            </form>
          </div>
        </td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
