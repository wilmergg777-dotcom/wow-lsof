<?php
/** Portada de KlikCuba: carrusel, ofertas, categorías y mini tiendas. */
require_once __DIR__ . '/includes/auth.php';
$page_title = SITE_NAME . ' — Tu tienda online en Cuba';

/* ---------- Ubicación de la portada ----------
   El visitante elige provincia (y municipio) en la portada; se guarda en sesión
   y se usa también en el catálogo. Por defecto, la de la cuenta. */
$loc = user_location();
$locProv = $_GET['prov'] ?? $loc['province'];
$locMuni = $_GET['muni'] ?? $loc['municipality'];
if (($_GET['prov'] ?? null) !== null) {
    // El usuario cambió la ubicación explícitamente: la guardamos en sesión
    $_SESSION['loc_province'] = $locProv === 'todas' ? '' : $locProv;
    $_SESSION['loc_municipality'] = $locMuni ?: '';
}
$provs = cuba_provinces();
if ($locProv !== '' && $locProv !== 'todas' && !isset($provs[$locProv])) $locProv = '';
if ($locProv === 'todas') $locProv = '';
if ($locProv !== '' && $locMuni !== '' && !isset($provs[$locProv]['municipalities'][$locMuni])) $locMuni = '';
$effectiveProv = $locProv;
$effectiveMuni = $locMuni;

/* Helper para ordenar productos por cercanía (municipio → provincia → cercanas → resto). */
function sort_by_location(array $items, ?string $prov, ?string $muni): array {
    if (!$prov) return $items;
    $nearby = $prov ? nearby_provinces($prov, 1) : [];
    foreach ($items as &$p) {
        if ($muni && ($p['store_municipality'] ?? null) === $muni) $p['loc_zone'] = 0;
        elseif (($p['store_province'] ?? null) === $prov) $p['loc_zone'] = 1;
        elseif (in_array($p['store_province'] ?? '', $nearby, true)) $p['loc_zone'] = 2;
        else $p['loc_zone'] = 3;
    }
    unset($p);
    usort($items, fn($a, $b) => ($a['loc_zone'] ?? 3) <=> ($b['loc_zone'] ?? 3));
    return $items;
}

// Ofertas destacadas (con descuento primero) — incluye provincia/municipio de la tienda
$featured = db()->query('SELECT p.*, s.name AS store_name, s.slug AS store_slug, s.province AS store_province, s.municipality AS store_municipality FROM products p LEFT JOIN stores s ON s.id = p.store_id WHERE p.status = "active" AND p.stock > 0 ORDER BY (p.old_price_cup IS NULL), (p.old_price_cup - p.price_cup) DESC, p.id DESC LIMIT 8')->fetchAll();
$featured = sort_by_location($featured, $effectiveProv, $effectiveMuni);

// Novedades
$latest = db()->query('SELECT p.*, s.name AS store_name, s.slug AS store_slug, s.province AS store_province, s.municipality AS store_municipality FROM products p LEFT JOIN stores s ON s.id = p.store_id WHERE p.status = "active" AND p.stock > 0 ORDER BY p.id DESC LIMIT 8')->fetchAll();
$latest = sort_by_location($latest, $effectiveProv, $effectiveMuni);

// Mini tiendas activas o en prueba (filtradas por provincia del visitante si hay)
if ($effectiveProv) {
    $stores = db()->prepare('SELECT s.*, (SELECT COUNT(*) FROM products p WHERE p.store_id = s.id AND p.status = "active") AS nprod FROM stores s WHERE s.province = ? OR s.province IS NULL ORDER BY (s.province = ?) DESC, s.id DESC LIMIT 6');
    $stores->execute([$effectiveProv, $effectiveProv]);
} else {
    $stores = db()->query('SELECT s.*, (SELECT COUNT(*) FROM products p WHERE p.store_id = s.id AND p.status = "active") AS nprod FROM stores s ORDER BY s.id DESC LIMIT 6');
}
$stores = $stores->fetchAll();

$cats = top_categories(10);

$slides = [
    ['uploads/gallery/audifonos-1.jpg', 'Todo en pesos cubanos (CUP)', 'Compra en efectivo o por transferencia bancaria. Sin dolares, sin complicaciones.', 'productos.php', 'Ver el catálogo'],
    ['uploads/gallery/perfume-1.jpeg', 'Abre tu mini tienda gratis', 'Vende lo tuyo en KlikCuba: 5 días de prueba gratis y luego solo 200 CUP al mes.', 'mi-tienda.php', 'Crear mi tienda'],
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

<!-- Selector de ubicación -->
<div class="card mb" style="padding:14px 16px">
  <div class="row" style="gap:12px;flex-wrap:wrap;align-items:center">
    <div style="display:inline-flex;align-items:center;gap:8px;color:var(--violet-dark);font-weight:700">
      <?= icon('map-pin', 20) ?> Comprar en:
    </div>
    <form method="get" class="row" style="gap:8px;flex:1;min-width:240px" id="loc-portada">
      <select class="input" name="prov" id="portada-prov" onchange="fillPortadaMunis(this.value); this.form.submit()" style="width:auto;padding:8px 12px">
        <option value="todas" <?= $effectiveProv === '' ? 'selected' : '' ?>>Todo el país</option>
        <?php foreach (province_options() as $slug => $nm): ?>
          <option value="<?= e($slug) ?>" <?= $effectiveProv === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
        <?php endforeach; ?>
      </select>
      <select class="input" name="muni" id="portada-muni" onchange="this.form.submit()" style="width:auto;padding:8px 12px" <?= $effectiveProv === '' ? 'disabled' : '' ?>>
        <option value=""><?= $effectiveProv ? 'Toda la provincia' : '—' ?></option>
        <?php if ($effectiveProv): foreach (municipality_options($effectiveProv) as $slug => $nm): ?>
          <option value="<?= e($slug) ?>" <?= $effectiveMuni === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
        <?php endforeach; endif; ?>
      </select>
    </form>
    <div class="help" style="text-align:right">
      <?php if ($effectiveProv && $effectiveMuni): ?>Viendo primero lo de <b><?= e(municipality_name($effectiveProv, $effectiveMuni)) ?></b> y alrededores.
      <?php elseif ($effectiveProv): ?>Viendo primero lo de <b><?= e(province_name($effectiveProv)) ?></b> y provincias cercanas.
      <?php else: ?>Elige tu provincia para ver primero las ventas de tu zona.
      <?php endif; ?>
    </div>
  </div>
</div>

<!-- Categorías -->
<div class="section-title"><h2>Categorías</h2></div>
<div class="grid grid-cats">
  <?php foreach ($cats as $c): ?>
    <a class="cat-card" href="productos.php?cat=<?= e($c['slug']) ?>"><?= category_icon($c['slug'], $c['emoji']) ?><?= e($c['name']) ?></a>
  <?php endforeach; ?>
</div>

<!-- Ofertas -->
<div class="section-title">
  <h2><?= icon('flame', 22) ?> Ofertas de la semana</h2>
  <a href="productos.php?ofertas=1">Ver todas las ofertas →</a>
</div>
<?php if (!$featured): ?>
  <div class="card empty"><div class="big"><?= icon('sprout', 44) ?></div>Aún no hay ofertas publicadas. ¡Vuelve pronto!</div>
<?php else: ?>
  <div class="grid grid-products">
    <?php foreach ($featured as $p) { include __DIR__ . '/includes/product-card.php'; } ?>
  </div>
<?php endif; ?>

<!-- Novedades -->
<div class="section-title"><h2><?= icon('sparkles', 22) ?> Publicado hace poco</h2></div>
<div class="grid grid-products">
  <?php foreach ($latest as $p) { include __DIR__ . '/includes/product-card.php'; } ?>
</div>

<!-- Mini tiendas -->
<div class="section-title">
  <h2><?= icon('store', 22) ?> Mini tiendas de la comunidad</h2>
  <a href="tiendas.php">Ver todas →</a>
</div>
<?php if (!$stores): ?>
  <div class="card empty"><div class="big"><?= icon('leaf', 44) ?></div>Todavía no hay mini tiendas. <a href="mi-tienda.php">Abre la tuya gratis</a>.</div>
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
