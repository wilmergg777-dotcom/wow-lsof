<?php
/** Publicar o editar un producto de la mini tienda (con fotos y precio en CUP). */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller();
$page_title = 'Publicar producto — ' . SITE_NAME;

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$store = $st->fetch();
if (!$store) { flash('Primero crea tu mini tienda.', 'info'); redirect('mi-tienda.php'); }

$editing = null;
$pid = (int)($_GET['id'] ?? 0);
if ($pid) {
    $st = db()->prepare('SELECT * FROM products WHERE id = ? AND store_id = ?');
    $st->execute([$pid, $store['id']]);
    $editing = $st->fetch();
    if (!$editing && $u['role'] === 'admin') {
        $st = db()->prepare('SELECT * FROM products WHERE id = ?');
        $st->execute([$pid]);
        $editing = $st->fetch();
    }
    if (!$editing) { flash('No encontramos ese producto en tu tienda.', 'err'); redirect('mis-productos.php'); }
}

$cats = db()->query('SELECT * FROM categories ORDER BY id')->fetchAll();
$galeria = gallery_photos();
$existing = $editing ? photos_of($editing['photos']) : [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('publicar', 30, 600)) { flash('Demasiadas publicaciones seguidas. Espera un momento.', 'err'); redirect('publicar.php'); }

    $title = trim($_POST['title'] ?? '');
    $desc = mb_substr(trim($_POST['description'] ?? ''), 0, 2000);
    $price = (int)($_POST['price_cup'] ?? 0);
    $oldPrice = (int)($_POST['old_price_cup'] ?? 0);
    $stock = max(0, (int)($_POST['stock'] ?? 0));
    $catId = (int)($_POST['category_id'] ?? 0) ?: null;

    // Fotos: las elegidas (JSON) + las subidas ahora
    $photos = [];
    $chosen = json_decode($_POST['photos'] ?? '[]', true);
    if (is_array($chosen)) {
        foreach ($chosen as $c) {
            $c = trim((string)$c);
            if (str_starts_with($c, 'uploads/') && !str_contains($c, '..') && file_exists(__DIR__ . '/' . $c)) $photos[] = $c;
        }
    }
    if (!empty($_FILES['photo_files']) && is_array($_FILES['photo_files']['name'])) {
        $n = count($_FILES['photo_files']['name']);
        for ($i = 0; $i < min($n, 6); $i++) {
            $f = ['name' => $_FILES['photo_files']['name'][$i], 'type' => $_FILES['photo_files']['type'][$i], 'tmp_name' => $_FILES['photo_files']['tmp_name'][$i], 'error' => $_FILES['photo_files']['error'][$i], 'size' => $_FILES['photo_files']['size'][$i]];
            $up = upload_image($f, 'products');
            if ($up) $photos[] = $up;
        }
    }
    $photos = array_slice(array_values(array_unique($photos)), 0, 6);

    $errores = [];
    if (mb_strlen($title) < 3) $errores[] = 'Escribe el nombre del producto.';
    if ($price <= 0) $errores[] = 'El precio debe ser mayor que 0 CUP.';
    if ($oldPrice > 0 && $oldPrice <= $price) $errores[] = 'El precio anterior (tachado) debe ser MAYOR que el precio actual, así se ve el descuento.';
    if (!$photos) $errores[] = 'Elige al menos una foto: sube una o elige de la galería incluida.';

    if ($errores) {
        foreach ($errores as $er) flash($er, 'err');
        $existing = $photos;
    } else {
        if ($editing) {
            db()->prepare('UPDATE products SET title=?, description=?, price_cup=?, old_price_cup=?, stock=?, category_id=?, photos=? WHERE id=?')
                ->execute([$title, $desc, $price, $oldPrice > 0 ? $oldPrice : null, $stock, $catId, json_encode($photos), $editing['id']]);
            if ((int)$editing['stock'] <= 0 && $stock > 0) {
                db()->prepare('UPDATE products SET status = "active" WHERE id = ?')->execute([$editing['id']]);
            }
            flash('Producto actualizado.', 'ok');
        } else {
            db()->prepare('INSERT INTO products (store_id, category_id, title, description, price_cup, old_price_cup, stock, photos, status, created_at) VALUES (?,?,?,?,?,?,?,?,?,?)')
                ->execute([$store['id'], $catId, $title, $desc, $price, $oldPrice > 0 ? $oldPrice : null, $stock, json_encode($photos), 'active', date('Y-m-d H:i:s')]);
            foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
                notify((int)$adm['id'], 'Nuevo producto publicado', '«' . $title . '» en la tienda ' . $store['name'] . ' por ' . money($price), 'producto.php?id=' . (int)db()->lastInsertId());
            }
            flash('¡Producto publicado! Ya se ve en tu tienda y en el catálogo.', 'ok');
        }
        redirect('mis-productos.php');
    }
}

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= $editing ? icon('save', 24) . ' Editar producto' : icon('shopping-cart', 24) . ' Publicar producto' ?></h1>
<p class="muted mb">Tienda: <b><?= e($store['name']) ?></b> · Todo en CUP</p>

<div class="card" style="max-width:680px">
  <form method="post" id="form-publicar" class="form form-wide" enctype="multipart/form-data">
    <?= csrf_field() ?>
    <div><label class="f">Nombre del producto *</label>
      <input class="input" name="title" required value="<?= e($editing['title'] ?? ($_POST['title'] ?? '')) ?>" placeholder="Ej: Audífonos inalámbricos TWS"></div>
    <div><label class="f">Descripción</label>
      <textarea class="input" name="description" placeholder="Detalles, medidas, cómo se entrega…"><?= e($editing['description'] ?? ($_POST['description'] ?? '')) ?></textarea></div>
    <div class="row">
      <div style="flex:1;min-width:130px"><label class="f">Precio actual (CUP) *</label>
        <input class="input" type="number" name="price_cup" min="1" required value="<?= e($editing['price_cup'] ?? ($_POST['price_cup'] ?? '')) ?>"></div>
      <div style="flex:1;min-width:130px"><label class="f">Precio anterior (opcional)</label>
        <input class="input" type="number" name="old_price_cup" min="0" value="<?= e($editing['old_price_cup'] ?? ($_POST['old_price_cup'] ?? '')) ?>">
        <p class="help">Si lo pones mayor al actual, se muestra tachado con el % de descuento.</p></div>
    </div>
    <div class="row">
      <div style="flex:1;min-width:130px"><label class="f">Cantidad en stock *</label>
        <input class="input" type="number" name="stock" min="0" required value="<?= e($editing['stock'] ?? ($_POST['stock'] ?? '1')) ?>"></div>
      <div style="flex:1;min-width:180px"><label class="f">Categoría</label>
        <select class="input" name="category_id">
          <option value="">— Sin categoría —</option>
          <?php foreach ($cats as $c): ?>
            <option value="<?= (int)$c['id'] ?>" <?= ((int)($editing['category_id'] ?? 0)) === (int)$c['id'] ? 'selected' : '' ?>><?= e($c['emoji'] . ' ' . $c['name']) ?></option>
          <?php endforeach; ?>
        </select></div>
    </div>

    <div>
      <label class="f">Fotos del producto * (hasta 6)</label>
      <input type="hidden" name="photos" id="photos_input" value="<?= e(json_encode($existing)) ?>">
      <input class="input" style="width:auto" type="file" name="photo_files[]" id="photo_files" accept=".jpg,.jpeg,.png,.webp,.gif" multiple>
      <p class="help">Mantén Ctrl (o Cmd) para elegir varias a la vez.</p>

      <?php if ($existing): ?>
        <p class="help mb">Fotos actuales (botón ✕ para quitar):</p>
        <div class="upload-list" id="upload-list">
          <?php foreach ($existing as $ph): ?>
            <div class="up"><img src="<?= e($ph) ?>" data-src="<?= e($ph) ?>" alt=""><button type="button" class="del" onclick="removeUpload(this)" aria-label="Quitar"><?= icon('x', 12) ?></button></div>
          <?php endforeach; ?>
        </div>
        <p class="help">Si quitas fotos, pulsa en el botón ✕ y guarda; se eliminan del producto.</p>
      <?php endif; ?>

      <p class="help mb" style="margin-top:8px">O toca las fotos de la galería incluida para usarlas:</p>
      <div class="photo-pick">
        <?php foreach ($galeria as $g): ?>
          <img src="<?= e($g) ?>" data-src="<?= e($g) ?>" onclick="togglePhoto(this, 'photos_input')" alt="">
        <?php endforeach; ?>
      </div>
    </div>

    <button class="btn btn-yellow" type="submit"><?= $editing ? 'Guardar cambios' : icon('package', 18) . ' Publicar producto' ?></button>
    <a class="btn btn-outline" href="mis-productos.php">Cancelar</a>
  </form>
</div>
<script>
// Marca en el input JSON las fotos actuales al cargar
(function () {
  var inp = document.getElementById('photos_input');
  if (!inp) return;
  try {
    var arr = JSON.parse(inp.value || '[]');
    document.querySelectorAll('#upload-list img').forEach(function (im) {
      var s = im.getAttribute('data-src');
      if (arr.indexOf(s) === -1) arr.push(s);
    });
    inp.value = JSON.stringify(arr);
  } catch (e) { inp.value = '[]'; }
})();
</script>
<?php include __DIR__ . '/includes/footer.php'; ?>
