<?php
/** Mini tienda pública del vendedor. */
require_once __DIR__ . '/includes/auth.php';

$id = (int)($_GET['id'] ?? 0);
$st = db()->prepare('SELECT s.*, u.name AS owner_name FROM stores s LEFT JOIN users u ON u.id = s.owner_id WHERE s.id = ?');
$st->execute([$id]);
$store = $st->fetch();

if (!$store) {
    $page_title = 'Tienda no encontrada';
    include __DIR__ . '/includes/header.php';
    echo '<div class="card empty"><div class="big">' . icon('leaf', 44) . '</div>Esa tienda no existe.<div class="mt"><a class="btn btn-violet" href="tiendas.php">Ver todas las tiendas</a></div></div>';
    include __DIR__ . '/includes/footer.php';
    exit;
}

$status = store_status($store);
$me = current_user();
$isOwnerOrAdmin = $me && ($me['role'] === 'admin' || (int)$me['id'] === (int)$store['owner_id']);
$visible = $status !== 'suspendida' || $isOwnerOrAdmin;

$page_title = $store['name'] . ' — Mini Tienda en ' . SITE_NAME;
include __DIR__ . '/includes/header.php';

$items = [];
if ($visible) {
    $st2 = db()->prepare('SELECT p.* FROM products p WHERE p.store_id = ? AND p.status = "active" AND p.stock > 0 ORDER BY p.id DESC LIMIT 60');
    $st2->execute([$id]);
    $items = $st2->fetchAll();
}
?>
<div class="store-hero">
  <img src="<?= e($store['photo'] ?: 'assets/img/no-foto.svg') ?>" alt="<?= e($store['name']) ?>">
  <div style="flex:1;min-width:240px">
    <h1><?= icon('store', 26) ?> <?= e($store['name']) ?></h1>
    <p><?= e($store['description'] ?: 'Tienda de la comunidad de KlikCuba.') ?></p>
    <div class="row" style="margin-top:8px">
      <?= store_status_badge($store) ?>
      <span class="badge b-info">Vendedor: <?= e($store['owner_name']) ?></span>
    </div>
  </div>
</div>

<?php if ($status === 'suspendida' && $isOwnerOrAdmin): ?>
  <div class="flash flash-warn">Tu tienda está suspendida para el público. Paga la suscripción de <?= money(SUBSCRIPTION_CUP) ?> desde <a href="suscripcion.php">Suscripción</a> para que tus productos vuelvan a verse.</div>
<?php endif; ?>

<?php if (!$visible): ?>
  <div class="card empty"><div class="big"><?= icon('leaf', 44) ?></div>Esta tienda está suspendida temporalmente. Vuelve más tarde.</div>
<?php elseif (!$items): ?>
  <div class="card empty"><div class="big"><?= icon('shopping-cart', 44) ?></div>Esta tienda todavía no tiene productos publicados.</div>
<?php else: ?>
  <div class="section-title"><h2>Productos de la tienda (<?= count($items) ?>)</h2></div>
  <div class="grid grid-products">
    <?php foreach ($items as $p): $p['store_name'] = $store['name']; include __DIR__ . '/includes/product-card.php'; endforeach; ?>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
