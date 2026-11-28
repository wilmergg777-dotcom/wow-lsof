<?php
/** Catálogo: búsqueda, categoría, ofertas y filtrado por ubicación (Cuba). */
require_once __DIR__ . '/includes/auth.php';

$q = trim($_GET['q'] ?? '');
$catSlug = trim($_GET['cat'] ?? '');
$ofertas = isset($_GET['ofertas']);
$orden = $_GET['orden'] ?? 'recientes';

/* ---------- Ubicación de búsqueda ----------
   Prioridad: ?prov= (selector explícito) > cuenta del usuario > sesión.
   El usuario puede quitar el filtro con ?prov=todas. */
$locProv = trim($_GET['prov'] ?? '');
$locMuni = trim($_GET['muni'] ?? '');
if ($locProv === '' && !isset($_GET['prov'])) {
    // Sin parámetro en URL: usa la ubicación de la cuenta/sesión
    $loc = user_location();
    $locProv = $loc['province'] ?? '';
    $locMuni = $loc['municipality'] ?? '';
}
if ($locProv === 'todas' || $locProv === '') { $locProv = ''; $locMuni = ''; }
// Valida que existan
$provs = cuba_provinces();
if ($locProv !== '' && !isset($provs[$locProv])) { $locProv = ''; $locMuni = ''; }
if ($locProv !== '' && $locMuni !== '' && !isset($provs[$locProv]['municipalities'][$locMuni])) { $locMuni = ''; }

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

$whereSql = implode(' AND ', $where);

/* Consulta por capas de ubicación:
   1) mismo municipio (si hay)  2) misma provincia  3) provincias cercanas  4) todo el país.
   Se van acumulando hasta tener al menos 24 resultados, etiquetando cada producto
   con su "zona" para poder ordenar por cercanía. */
function fetch_layered(array $whereSql, array $params, string $orderSql, string $locProv, ?string $locMuni): array {
    $base = "SELECT p.*, s.name AS store_name, s.slug AS store_slug, s.trial_until, s.subscription_until,
                    s.province AS store_province, s.municipality AS store_municipality
             FROM products p
             LEFT JOIN stores s ON s.id = p.store_id
             WHERE $whereSql";
    $items = [];
    $seen = [];
    $add = function($rows, $zone) use (&$items, &$seen) {
        foreach ($rows as $r) {
            if (isset($seen[$r['id']])) continue;
            $seen[$r['id']] = true;
            $r['loc_zone'] = $zone; // 0=municipio, 1=provincia, 2=cercana, 3=resto
            $items[] = $r;
        }
    };

    // 1) municipio
    if ($locProv && $locMuni) {
        $sql = $base . " AND s.municipality = ? ORDER BY $orderSql LIMIT 60";
        $st = db()->prepare($sql); $st->execute(array_merge($params, [$locMuni]));
        $add($st->fetchAll(), 0);
    }
    // 2) provincia (incluye los que no tienen municipio asignado en esa provincia)
    if ($locProv && count($items) < 24) {
        $sql = $base . " AND s.province = ? ORDER BY $orderSql LIMIT 60";
        $st = db()->prepare($sql); $st->execute(array_merge($params, [$locProv]));
        $add($st->fetchAll(), 1);
    }
    // 3) provincias cercanas
    if ($locProv && count($items) < 24) {
        $nearby = nearby_provinces($locProv, 1);
        $nearby = array_values(array_diff($nearby, [$locProv]));
        if ($nearby) {
            $ph = implode(',', array_fill(0, count($nearby), '?'));
            $sql = $base . " AND s.province IN ($ph) ORDER BY $orderSql LIMIT 60";
            $st = db()->prepare($sql); $st->execute(array_merge($params, $nearby));
            $add($st->fetchAll(), 2);
        }
    }
    // 4) resto del país (productos oficiales sin tienda + otras provincias)
    if (count($items) < 24) {
        $sql = $base . " ORDER BY $orderSql LIMIT 60";
        $st = db()->prepare($sql); $st->execute($params);
        $add($st->fetchAll(), 3);
    }
    // Ordena por zona (cercanía) y luego por el criterio elegido
    usort($items, function($a, $b) use ($orderSql) {
        if ($a['loc_zone'] !== $b['loc_zone']) return $a['loc_zone'] <=> $b['loc_zone'];
        // si el orden es por precio, aplica dentro de la misma zona
        if (str_contains($orderSql, 'price_cup ASC')) return $a['price_cup'] <=> $b['price_cup'];
        if (str_contains($orderSql, 'price_cup DESC')) return $b['price_cup'] <=> $a['price_cup'];
        return $b['id'] <=> $a['id']; // recientes por defecto
    });
    return array_slice($items, 0, 60);
}

$items = fetch_layered($whereSql, $params, $orderSql, $locProv, $locMuni);

// Las tiendas suspendidas no muestran sus productos al público
$items = array_values(array_filter($items, function ($p) {
    if (empty($p['store_id'])) return true;
    return store_status(['trial_until' => $p['trial_until'], 'subscription_until' => $p['subscription_until']]) !== 'suspendida';
}));

// Etiqueta de la zona activa para mostrar al usuario
if ($locProv && $locMuni) $locLabel = municipality_name($locProv, $locMuni) . ' · ' . province_name($locProv);
elseif ($locProv) $locLabel = 'Provincia de ' . province_name($locProv);
else $locLabel = 'Todo el país';

$page_title = ($cat ? $cat['name'] . ' — ' : '') . ($ofertas ? 'Ofertas — ' : '') . ($q !== '' ? 'Buscar: ' . $q . ' — ' : '') . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="breadcrumb"><a href="index.php">Inicio</a> › Catálogo</div>

<div class="row-between mb" style="gap:10px;flex-wrap:wrap">
  <h1 style="color:var(--violet-dark);font-size:22px;margin:0">
    <?php
    if ($ofertas) echo icon('flame', 22) . ' Ofertas de KlikCuba';
    elseif ($q !== '') echo 'Resultados de «' . e($q) . '»';
    elseif ($cat) echo category_icon($cat['slug'], $cat['emoji'], 22) . ' ' . e($cat['name']);
    else echo 'Todo el catálogo';
    ?>
  </h1>
  <form method="get" class="row" style="gap:8px">
    <?php foreach ($_GET as $k => $v) if (!in_array($k, ['orden','prov','muni'])) echo '<input type="hidden" name="' . e($k) . '" value="' . e($v) . '">'; ?>
    <label class="f" style="margin:0">Ordenar:</label>
    <select class="input" name="orden" onchange="this.form.submit()" style="width:auto;padding:7px 10px">
      <option value="recientes" <?= $orden === 'recientes' ? 'selected' : '' ?>>Más recientes</option>
      <option value="baratos" <?= $orden === 'baratos' ? 'selected' : '' ?>>Menor precio</option>
      <option value="caros" <?= $orden === 'caros' ? 'selected' : '' ?>>Mayor precio</option>
      <option value="descuento" <?= $orden === 'descuento' ? 'selected' : '' ?>>Mayor descuento</option>
    </select>
  </form>
</div>

<!-- Selector de ubicación -->
<div class="card mb" style="padding:12px 14px">
  <div class="row" style="gap:10px;flex-wrap:wrap;align-items:flex-end">
    <div>
      <label class="f" style="font-size:12px"><?= icon('map-pin', 14) ?> Comprar en</label>
      <form method="get" class="row" style="gap:6px" id="loc-form">
        <?php foreach ($_GET as $k => $v) if (!in_array($k, ['prov','muni'])) echo '<input type="hidden" name="' . e($k) . '" value="' . e($v) . '">'; ?>
        <select class="input" name="prov" id="loc-prov" onchange="document.getElementById('loc-muni').value=''; this.form.submit()" style="width:auto;padding:7px 10px">
          <option value="todas" <?= $locProv === '' ? 'selected' : '' ?>>Todo el país</option>
          <?php foreach (province_options() as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= $locProv === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; ?>
        </select>
        <select class="input" name="muni" id="loc-muni" onchange="this.form.submit()" style="width:auto;padding:7px 10px" <?= $locProv === '' ? 'disabled' : '' ?>>
          <option value=""><?= $locProv ? 'Toda la provincia' : '—' ?></option>
          <?php if ($locProv): foreach (municipality_options($locProv) as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= $locMuni === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; endif; ?>
        </select>
      </form>
    </div>
    <div class="help" style="margin-left:auto">
      <?php if ($locProv && $locMuni): ?>Mostrando primero ventas en <b><?= e(municipality_name($locProv, $locMuni)) ?></b>, luego <?= e(province_name($locProv)) ?> y provincias cercanas.
      <?php elseif ($locProv): ?>Mostrando primero ventas en <b><?= e(province_name($locProv)) ?></b> y provincias cercanas.
      <?php else: ?>Mostrando ventas de todo el país. Elige tu provincia para ver primero las de tu zona.
      <?php endif; ?>
    </div>
  </div>
</div>

<div class="row mb">
  <span class="badge b-info"><?= count($items) ?> productos</span>
  <span class="badge b-ok"><?= icon('map-pin', 13) ?> <?= e($locLabel) ?></span>
  <?php if ($cat): ?><a class="badge b-warn" href="productos.php?prov=<?= e($locProv) ?>&muni=<?= e($locMuni) ?>">Quitar categoría <?= icon('x', 13) ?></a><?php endif; ?>
  <?php if ($ofertas): ?><a class="badge b-warn" href="productos.php?prov=<?= e($locProv) ?>&muni=<?= e($locMuni) ?>">Ver todo el catálogo <?= icon('x', 13) ?></a><?php endif; ?>
  <?php if ($locProv): ?><a class="badge b-warn" href="productos.php">Ver de todo el país <?= icon('x', 13) ?></a><?php endif; ?>
</div>

<?php if (!$items): ?>
  <div class="card empty"><div class="big"><?= icon('search', 44) ?></div>No encontramos productos <?= $q !== '' ? 'para «' . e($q) . '»' : 'con esos filtros' ?> en <?= e($locLabel) ?>.<br class="mt"><a href="productos.php">Ver todo el catálogo del país</a></div>
<?php else: ?>
  <div class="grid grid-products">
    <?php foreach ($items as $p) { include __DIR__ . '/includes/product-card.php'; } ?>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
