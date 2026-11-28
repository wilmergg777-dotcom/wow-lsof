<?php
/** Admin: gestión de todos los productos. */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Productos — Administración';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $pid = (int)($_POST['product_id'] ?? 0);
    $accion = $_POST['accion'] ?? '';
    $st = db()->prepare('SELECT * FROM products WHERE id = ?');
    $st->execute([$pid]);
    $p = $st->fetch();
    if ($p) {
        if ($accion === 'ocultar') db()->prepare('UPDATE products SET status = "oculto" WHERE id = ?')->execute([$pid]);
        if ($accion === 'mostrar') db()->prepare('UPDATE products SET status = "active" WHERE id = ?')->execute([$pid]);
        if ($accion === 'borrar') {
            db()->prepare('DELETE FROM products WHERE id = ?')->execute([$pid]);
            db()->prepare('DELETE FROM cart_items WHERE product_id = ?')->execute([$pid]);
        }
        if ($accion === 'reponer') db()->prepare('UPDATE products SET stock = ? WHERE id = ?')->execute([max(0, (int)($_POST['qty'] ?? 0)), $pid]);
        sec_log('admin_producto', 'Producto ' . $p['title'] . ': ' . $accion, (int)$admin['id']);
        flash('Producto actualizado.', 'ok');
    }
    redirect('productos.php');
}

$q = trim($_GET['q'] ?? '');
if ($q !== '') {
    $st = db()->prepare('SELECT p.*, s.name AS store_name FROM products p LEFT JOIN stores s ON s.id = p.store_id WHERE p.title LIKE ? ORDER BY p.id DESC LIMIT 100');
    $st->execute(['%' . $q . '%']);
    $items = $st->fetchAll();
} else {
    $items = db()->query('SELECT p.*, s.name AS store_name FROM products p LEFT JOIN stores s ON s.id = p.store_id ORDER BY p.id DESC LIMIT 100')->fetchAll();
}
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('package', 26) ?> Productos de toda la tienda</h1>

<form method="get" class="row mb"><?= csrf_field() ?>
  <input class="input" style="max-width:340px" name="q" placeholder="Buscar producto por nombre…" value="<?= e($q) ?>">
  <button class="btn btn-violet btn-sm" type="submit">Buscar</button>
  <?php if ($q !== ''): ?><a class="btn btn-outline btn-sm" href="productos.php">Ver todos</a><?php endif; ?>
</form>

<div class="card">
  <div class="table-wrap"><table class="tbl">
    <tr><th>Producto</th><th>Tienda</th><th>Precio</th><th>Stock</th><th>Estado</th><th>Acciones</th></tr>
    <?php foreach ($items as $p): ?>
    <tr>
      <td class="row" style="gap:10px">
        <img class="thumb-sm" src="<?= e(photo_of($p['photos'])) ?>" alt="">
        <div><a class="t-title" href="../producto.php?id=<?= (int)$p['id'] ?>"><?= e($p['title']) ?></a></div>
      </td>
      <td><?= $p['store_name'] ? e($p['store_name']) : '<span class="badge b-info">KlikCuba (oficial)</span>' ?></td>
      <td style="white-space:nowrap"><b><?= money($p['price_cup']) ?></b></td>
      <td>
        <form method="post" class="row" style="gap:6px"><?= csrf_field() ?>
          <input type="hidden" name="product_id" value="<?= (int)$p['id'] ?>">
          <input type="hidden" name="accion" value="reponer">
          <input class="input" style="width:62px;padding:6px" type="number" name="qty" value="<?= (int)$p['stock'] ?>" min="0">
          <button class="btn btn-outline btn-sm" type="submit">OK</button>
        </form>
      </td>
      <td>
        <?php if ($p['status'] === 'active' && (int)$p['stock'] > 0): ?><span class="badge b-ok">A la venta</span>
        <?php elseif ($p['status'] === 'active'): ?><span class="badge b-agotado">Agotado</span>
        <?php else: ?><span class="badge b-warn">Oculto</span><?php endif; ?>
      </td>
      <td>
        <div class="row" style="gap:6px">
          <a class="btn btn-outline btn-sm" href="../publicar.php?id=<?= (int)$p['id'] ?>">Editar</a>
          <form method="post"><?= csrf_field() ?>
            <input type="hidden" name="product_id" value="<?= (int)$p['id'] ?>">
            <input type="hidden" name="accion" value="<?= $p['status'] === 'active' ? 'ocultar' : 'mostrar' ?>">
            <button class="btn btn-outline btn-sm" type="submit"><?= $p['status'] === 'active' ? 'Ocultar' : 'Mostrar' ?></button>
          </form>
          <form method="post" onsubmit="return confirmDel('¿Eliminar este producto para siempre?')"><?= csrf_field() ?>
            <input type="hidden" name="product_id" value="<?= (int)$p['id'] ?>">
            <input type="hidden" name="accion" value="borrar">
            <button class="btn btn-red btn-sm" type="submit">Eliminar</button>
          </form>
        </div>
      </td>
    </tr>
    <?php endforeach; ?>
  </table></div>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
