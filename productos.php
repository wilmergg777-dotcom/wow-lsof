<?php
/** Catálogo: búsqueda, categoría y ofertas. */
require_once __DIR__ . '/includes/auth.php';

$q = trim($_GET['q'] ?? '');
$catSlug = trim($_GET['cat'] ?? '');
$ofertas = isset($_GET['ofertas']);
$orden = $_GET['orden'] ?? 'recientes';

$cat = $catSlug ? category_by_slug($catSlug) : null;

$where = ['p.status = "active"', 'p.stock > 0'];
$params = [];
if ($cat) { $where[] = 'p.category_id = ?'; $params[] = (int)$cat['id']; }
if ($q !== '') {
    $where[] = '(p.title LIKE ? OR p.description LIKE ?)';
    $params[] = '%' . $q . '%';
    $params[] = '%' . $q . '%';
}
if ($ofertas) { $where[] = 'p.old_price_cup IS NOT NULL AND p.old_price_cup > p.price_cup'; }

$orderSql = match ($orden) {
    'baratos' => 'p.price_cup ASC',
    'caros' => 'p.price_cup DESC',
    'descuento' => '(p.old_price_cup IS NULL), (p.old_price_cup - p.price_cup) DESC',
    default => 'p.id DESC',
};

$sql = 'SELECT p.*, s.name AS store_name, s.slug AS store_slug, s.trial_until, s.subscription_until
        FROM products p
        LEFT JOIN stores s ON s.id = p.store_id
        WHERE ' . implode(' AND ', $where) . '
        ORDER BY ' . $orderSql . '
        LIMIT 60';
$st = db()->prepare($sql);
$st->execute($params);
$items = $st->fetchAll();

// Las tiendas suspendidas no muestran sus productos al público
$items = array_values(array_filter($items, function ($p) {
    if (empty($p['store_id'])) return true;
    return store_status(['trial_until' => $p['trial_until'], 'subscription_until' => $p['subscription_until']]) !== 'suspendida';
}));

$page_title = ($cat ? $cat['name'] . ' — ' : '') . ($ofertas ? 'Ofertas — ' : '') . ($q !== '' ? 'Buscar: ' . $q . ' — ' : '') . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="breadcrumb"><a href="index.php">Inicio</a> › Catálogo</div>

<div class="row-between mb">
  <h1 style="color:var(--violet-dark);font-size:22px">
    <?php
    if ($ofertas) echo '🔥 Ofertas de Violetero';
    elseif ($q !== '') echo 'Resultados de «' . e($q) . '»';
    elseif ($cat) echo e($cat['emoji'] . ' ' . $cat['name']);
    else echo 'Todo el catálogo';
    ?>
  </h1>
  <form method="get" class="row">
    <?php foreach ($_GET as $k => $v) if (!in_array($k, ['orden'])) echo '<input type="hidden" name="' . e($k) . '" value="' . e($v) . '">'; ?>
    <label class="f" style="margin:0">Ordenar:</label>
    <select class="input" name="orden" onchange="this.form.submit()" style="width:auto;padding:7px 10px">
      <option value="recientes" <?= $orden === 'recientes' ? 'selected' : '' ?>>Más recientes</option>
      <option value="baratos" <?= $orden === 'baratos' ? 'selected' : '' ?>>Menor precio</option>
      <option value="caros" <?= $orden === 'caros' ? 'selected' : '' ?>>Mayor precio</option>
      <option value="descuento" <?= $orden === 'descuento' ? 'selected' : '' ?>>Mayor descuento</option>
    </select>
  </form>
</div>

<div class="row mb">
  <span class="badge b-info"><?= count($items) ?> productos</span>
  <?php if ($cat): ?><a class="badge b-warn" href="productos.php">Quitar filtro de categoría ✕</a><?php endif; ?>
  <?php if ($ofertas): ?><a class="badge b-warn" href="productos.php">Ver todo el catálogo ✕</a><?php endif; ?>
</div>

<?php if (!$items): ?>
  <div class="card empty"><div class="big">🔍</div>No encontramos productos <?= $q !== '' ? 'para «' . e($q) . '»' : 'con esos filtros' ?>.<br class="mt"><a href="productos.php">Ver todo el catálogo</a></div>
<?php else: ?>
  <div class="grid grid-products">
    <?php foreach ($items as $p) { include __DIR__ . '/includes/product-card.php'; } ?>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
