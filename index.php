<?php
/** Portada de Violetero: carrusel, ofertas, categorías y mini tiendas. */
require_once __DIR__ . '/includes/auth.php';
$page_title = SITE_NAME . ' — Tu tienda online en Cuba';

// Ofertas destacadas (con descuento primero)
$featured = db()->query('SELECT p.*, s.name AS store_name, s.slug AS store_slug FROM products p LEFT JOIN stores s ON s.id = p.store_id WHERE p.status = "active" AND p.stock > 0 ORDER BY (p.old_price_cup IS NULL), (p.old_price_cup - p.price_cup) DESC, p.id DESC LIMIT 8')->fetchAll();

// Novedades
$latest = db()->query('SELECT p.*, s.name AS store_name, s.slug AS store_slug FROM products p LEFT JOIN stores s ON s.id = p.store_id WHERE p.status = "active" AND p.stock > 0 ORDER BY p.id DESC LIMIT 8')->fetchAll();

// Mini tiendas activas o en prueba
$stores = db()->query('SELECT s.*, (SELECT COUNT(*) FROM products p WHERE p.store_id = s.id AND p.status = "active") AS nprod FROM stores s ORDER BY s.id DESC LIMIT 6')->fetchAll();

$cats = top_categories(10);

$slides = [
    ['uploads/gallery/audifonos-1.jpg', 'Todo en pesos cubanos (CUP)', 'Compra en efectivo o por transferencia bancaria. Sin dolares, sin complicaciones.', 'productos.php', 'Ver el catálogo'],
    ['uploads/gallery/perfume-1.jpeg', 'Abre tu mini tienda gratis', 'Vende lo tuyo en Violetero: 5 días de prueba gratis y luego solo 200 CUP al mes.', 'mi-tienda.php', 'Crear mi tienda'],
    ['uploads/gallery/laptop-1.jpg', 'Ofertas de bienvenida', 'Precios con descuento en electrónica, hogar y más. ¡Aprovecha antes de que se agoten!', 'productos.php?ofertas=1', 'Ver ofertas'],
];
include __DIR__ . '/includes/header.php';
?>

<!-- Carrusel de portada -->
<div class="hero" id="hero">
  <?php foreach ($slides as $n => $sl): ?>
  <div class="slide <?= $n === 0 ? 'on' : '' ?>">
    <img src="<?= e($sl[0]) ?>" alt="">
    <div class="slide-txt">
      <h2><?= e($sl[1]) ?></h2>
      <p><?= e($sl[2]) ?></p>
      <div class="mt"><a class="btn btn-yellow" href="<?= e($sl[3]) ?>"><?= e($sl[4]) ?></a></div>
    </div>
  </div>
  <?php endforeach; ?>
  <div class="dots"><?php foreach ($slides as $n => $sl): ?><button aria-label="Diapositiva <?= $n + 1 ?>"></button><?php endforeach; ?></div>
</div>

<!-- Categorías -->
<div class="section-title"><h2>Categorías</h2></div>
<div class="grid grid-cats">
  <?php foreach ($cats as $c): ?>
    <a class="cat-card" href="productos.php?cat=<?= e($c['slug']) ?>"><div class="em"><?= e($c['emoji']) ?></div><?= e($c['name']) ?></a>
  <?php endforeach; ?>
</div>

<!-- Ofertas -->
<div class="section-title">
  <h2>🔥 Ofertas de la semana</h2>
  <a href="productos.php?ofertas=1">Ver todas las ofertas →</a>
</div>
<?php if (!$featured): ?>
  <div class="card empty"><div class="big">🌻</div>Aún no hay ofertas publicadas. ¡Vuelve pronto!</div>
<?php else: ?>
  <div class="grid grid-products">
    <?php foreach ($featured as $p) { include __DIR__ . '/includes/product-card.php'; } ?>
  </div>
<?php endif; ?>

<!-- Novedades -->
<div class="section-title"><h2>✨ Publicado hace poco</h2></div>
<div class="grid grid-products">
  <?php foreach ($latest as $p) { include __DIR__ . '/includes/product-card.php'; } ?>
</div>

<!-- Mini tiendas -->
<div class="section-title">
  <h2>🏪 Mini tiendas de la comunidad</h2>
  <a href="tiendas.php">Ver todas →</a>
</div>
<?php if (!$stores): ?>
  <div class="card empty"><div class="big">🌸</div>Todavía no hay mini tiendas. <a href="mi-tienda.php">Abre la tuya gratis</a>.</div>
<?php else: ?>
  <div class="grid grid-stores">
    <?php foreach ($stores as $s): if (store_status($s) === 'suspendida') continue; ?>
    <div class="store-card">
      <img class="logo" src="<?= e($s['photo'] ?: 'assets/img/no-foto.svg') ?>" alt="">
      <h3><?= e($s['name']) ?></h3>
      <p><?= e(mb_substr($s['description'] ?? '', 0, 90)) ?>…</p>
      <div class="row mb" style="justify-content:center">
        <?= store_status_badge($s) ?>
        <span class="badge b-info"><?= (int)$s['nprod'] ?> productos</span>
      </div>
      <a class="btn btn-violet btn-sm" href="tienda.php?id=<?= (int)$s['id'] ?>">Visitar la tienda</a>
    </div>
    <?php endforeach; ?>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
