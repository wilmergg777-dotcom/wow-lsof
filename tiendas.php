<?php
/** Listado de mini tiendas de la comunidad. */
require_once __DIR__ . '/includes/auth.php';
$page_title = 'Mini Tiendas — ' . SITE_NAME;

$stores = db()->query('SELECT s.*, (SELECT COUNT(*) FROM products p WHERE p.store_id = s.id AND p.status = "active") AS nprod FROM stores s ORDER BY s.id DESC')->fetchAll();
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('store', 26) ?> Mini Tiendas de la comunidad</h1>
<p class="muted mb">Vendedores independientes de KlikCuba. Cada tienda tiene 5 días de prueba gratis y luego una suscripción de <?= money(SUBSCRIPTION_CUP) ?> al mes.</p>

<?php if (!$stores): ?>
  <div class="card empty"><div class="big"><?= icon('leaf', 44) ?></div>Todavía no hay mini tiendas.<div class="mt"><a class="btn btn-violet" href="mi-tienda.php">Abrir mi mini tienda gratis</a></div></div>
<?php else: ?>
  <div class="grid grid-stores">
    <?php foreach ($stores as $s): ?>
      <?php $st = store_status($s); if ($st === 'suspendida'): ?>
        <div class="store-card" style="opacity:.55">
          <img class="logo" src="<?= e($s['photo'] ?: 'assets/img/no-foto.svg') ?>" alt="">
          <h3><?= e($s['name']) ?></h3>
          <p>Esta tienda está suspendida temporalmente.</p>
          <?= store_status_badge($s) ?>
        </div>
      <?php else: ?>
        <div class="store-card">
          <img class="logo" src="<?= e($s['photo'] ?: 'assets/img/no-foto.svg') ?>" alt="">
          <h3><?= e($s['name']) ?></h3>
          <p><?= e(mb_substr($s['description'] ?? '', 0, 110)) ?></p>
          <div class="row mb" style="justify-content:center">
            <?= store_status_badge($s) ?>
            <span class="badge b-info"><?= (int)$s['nprod'] ?> productos</span>
          </div>
          <a class="btn btn-violet btn-sm" href="tienda.php?id=<?= (int)$s['id'] ?>">Visitar la tienda</a>
        </div>
      <?php endif; ?>
    <?php endforeach; ?>
  </div>
<?php endif; ?>

<div class="card mt" style="text-align:center">
  <h2 style="color:var(--violet-dark)">¿Quieres vender lo tuyo?</h2>
  <p class="muted mb">Abre tu mini tienda gratis: publicas productos con fotos, recibes los pedidos aquí mismo y las gestionas desde tu panel.</p>
  <a class="btn btn-yellow" href="mi-tienda.php"><?= icon('store', 18) ?> Abrir mi mini tienda</a>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
