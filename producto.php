<?php
/** Detalle de producto + agregar al carrito. */
require_once __DIR__ . '/includes/auth.php';

$id = (int)($_GET['id'] ?? 0);
$st = db()->prepare('SELECT p.*, s.name AS store_name, s.slug AS store_slug, s.owner_id AS store_owner, s.trial_until, s.subscription_until, c.name AS cat_name, c.slug AS cat_slug, c.emoji AS cat_emoji
                     FROM products p
                     LEFT JOIN stores s ON s.id = p.store_id
                     LEFT JOIN categories c ON c.id = p.category_id
                     WHERE p.id = ?');
$st->execute([$id]);
$p = $st->fetch();
if (!$p || $p['status'] !== 'active') {
    $page_title = 'Producto no encontrado';
    include __DIR__ . '/includes/header.php';
    echo '<div class="card empty"><div class="big">' . icon('leaf', 44) . '</div>Este producto no existe o ya no está disponible.<div class="mt"><a class="btn btn-violet" href="productos.php">Ver el catálogo</a></div></div>';
    include __DIR__ . '/includes/footer.php';
    exit;
}
// Tiendas suspendidas: el público no puede ver sus productos
if (!empty($p['store_id']) && store_status(['trial_until' => $p['trial_until'], 'subscription_until' => $p['subscription_until']]) === 'suspendida') {
    $me = current_user();
    $canView = $me && ($me['role'] === 'admin' || (int)$me['id'] === (int)$p['store_owner']);
    if (!$canView) {
        flash('La tienda de este producto está suspendida temporalmente. Vuelve más tarde.', 'warn');
        redirect('productos.php');
    }
}

db()->prepare('UPDATE products SET views = views + 1 WHERE id = ?')->execute([$id]);

$photos = photos_of($p['photos']);
$off = !empty($p['old_price_cup']) && (int)$p['old_price_cup'] > (int)$p['price_cup'];
$pct = $off ? round((1 - $p['price_cup'] / $p['old_price_cup']) * 100) : 0;

// Agregar al carrito
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'agregar') {
    csrf_check();
    $u = require_login('producto.php?id=' . $id);
    $qty = max(1, min((int)($_POST['qty'] ?? 1), 99));
    if ((int)$p['stock'] <= 0) {
        flash('Este producto está agotado.', 'err');
    } else {
        $qty = min($qty, (int)$p['stock']);
        if (DB_DRIVER === 'mysql') {
            db()->prepare('INSERT INTO cart_items (user_id, product_id, qty) VALUES (?,?,?) ON DUPLICATE KEY UPDATE qty = LEAST(qty + ?, ?)')
                ->execute([$u['id'], $id, $qty, $qty, (int)$p['stock']]);
        } else {
            db()->prepare('INSERT INTO cart_items (user_id, product_id, qty) VALUES (?,?,?) ON CONFLICT(user_id, product_id) DO UPDATE SET qty = MIN(qty + ?, ?)')
                ->execute([$u['id'], $id, $qty, $qty, (int)$p['stock']]);
        }
        flash('Agregado al carrito: ' . $p['title'], 'ok');
        redirect('carrito.php');
    }
}

$page_title = $p['title'] . ' — ' . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="breadcrumb">
  <a href="index.php">Inicio</a> ›
  <?php if (!empty($p['cat_name'])): ?><a href="productos.php?cat=<?= e($p['cat_slug']) ?>"><?= e($p['cat_emoji'] . ' ' . $p['cat_name']) ?></a> ›<?php endif; ?>
  <?= e(mb_substr($p['title'], 0, 40)) ?>
</div>

<div class="card product-detail">
  <div>
    <div class="gallery-main"><img id="gal-main" src="<?= e($photos[0] ?? 'assets/img/no-foto.svg') ?>" alt="<?= e($p['title']) ?>"></div>
    <?php if (count($photos) > 1): ?>
      <div class="gallery-thumbs">
        <?php foreach ($photos as $n => $ph): ?>
          <img src="<?= e($ph) ?>" class="<?= $n === 0 ? 'on' : '' ?>" onclick="galShow('<?= e($ph) ?>', this)" alt="Foto <?= $n + 1 ?>">
        <?php endforeach; ?>
      </div>
    <?php endif; ?>
  </div>

  <div class="detail-box">
    <h1><?= e($p['title']) ?></h1>
    <?php if (!empty($p['cat_name'])): ?><span class="badge b-info"><?= e($p['cat_emoji'] . ' ' . $p['cat_name']) ?></span><?php endif; ?>

    <div class="detail-price">
      <?= money($p['price_cup']) ?>
      <?php if ($off): ?>
        <span class="price-old" style="font-size:16px"><?= money($p['old_price_cup']) ?></span>
        <span class="pct" style="font-size:15px">Ahorra <?= $pct ?>%</span>
      <?php endif; ?>
    </div>

    <div class="row mb">
      <?php if ((int)$p['stock'] > 0): ?>
        <span class="stock-ok"><?= icon('check', 15) ?> Disponible: <?= (int)$p['stock'] ?> unidad<?= (int)$p['stock'] === 1 ? '' : 'es' ?></span>
      <?php else: ?>
        <span class="stock-out"><?= icon('x', 15) ?> Agotado</span>
      <?php endif; ?>
    </div>

    <form method="post" class="qty-row" <?php if ((int)$p['stock'] <= 0) echo 'style="opacity:.5"'; ?>>
      <?= csrf_field() ?>
      <input type="hidden" name="accion" value="agregar">
      <input type="number" name="qty" value="1" min="1" max="<?= max(1, (int)$p['stock']) ?>" <?= (int)$p['stock'] <= 0 ? 'disabled' : '' ?>>
      <button class="btn btn-yellow" type="submit" <?= (int)$p['stock'] <= 0 ? 'disabled' : '' ?>><?= icon('shopping-cart', 18) ?> Agregar al carrito</button>
      <a class="btn btn-outline" href="carrito.php">Ir al carrito</a>
    </form>

    <hr class="sep">
    <h3 style="color:var(--violet-dark);margin-bottom:6px">Descripción</h3>
    <p class="desc"><?= e($p['description'] ?: 'Sin descripción.') ?></p>

    <div class="detail-seller">
      <?php if (!empty($p['store_id'])): ?>
        Vendido por <b><a href="tienda.php?id=<?= (int)$p['store_id'] ?>"><?= e($p['store_name']) ?></a></b><br>
        <span class="muted">Al comprar, el vendedor recibe un aviso y te contacta para coordinar la entrega.</span>
      <?php else: ?>
        Vendido por <b>Violetero</b> (tienda oficial)<br>
        <span class="muted">Al comprar recibes un aviso con el resumen de tu pedido.</span>
      <?php endif; ?>
      <div class="mt" style="font-size:13.5px;color:var(--muted)"><?= icon('wallet', 15) ?> Pago: efectivo o transferencia bancaria — todo en CUP.</div>
    </div>
  </div>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
