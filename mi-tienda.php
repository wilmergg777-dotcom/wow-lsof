<?php
/** Crear o editar la mini tienda del usuario (gratis, con prueba de 5 días). */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('mi-tienda.php');
$page_title = 'Mi Mini Tienda — ' . SITE_NAME;

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$store = $st->fetch();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('tienda', 10, 600)) { flash('Espera un momento.', 'err'); redirect('mi-tienda.php'); }
    $name = trim($_POST['name'] ?? '');
    $desc = mb_substr(trim($_POST['description'] ?? ''), 0, 600);
    $province = trim($_POST['province'] ?? '');
    $municipality = trim($_POST['municipality'] ?? '');
    // Valida que la provincia y municipio existan en el catálogo de Cuba
    $provs = cuba_provinces();
    if ($province !== '' && !isset($provs[$province])) { $province = ''; $municipality = ''; }
    if ($province !== '' && $municipality !== '' && !isset($provs[$province]['municipalities'][$municipality])) {
        $municipality = '';
    }
    $photo = $store['photo'] ?? null;

    if (isset($_POST['photo_choice'])) {
        $choice = $_POST['photo_choice'];
        if ($choice === 'subida') {
            $up = upload_image($_FILES['photo_file'] ?? [], 'stores');
            if ($up) $photo = $up;
            elseif (!empty($_FILES['photo_file']['name'])) flash('No pudimos subir esa foto: usa JPG, PNG o WebP de hasta ' . MAX_UPLOAD_MB . ' MB.', 'err');
        } elseif (str_starts_with($choice, 'uploads/gallery/')) {
            $photo = $choice;
        }
    }

    if (mb_strlen($name) < 3) {
        flash('El nombre de la tienda necesita al menos 3 letras.', 'err');
    } elseif ($province === '') {
        flash('Selecciona la provincia donde está ubicada tu tienda (necesario para que te encuentren los compradores de tu zona).', 'err');
    } else {
        if ($store) {
            db()->prepare('UPDATE stores SET name = ?, description = ?, photo = ?, province = ?, municipality = ? WHERE id = ?')
                ->execute([$name, $desc, $photo, $province, $municipality, $store['id']]);
            flash('Datos de tu tienda actualizados.', 'ok');
        } else {
            $slug = slug($name);
            $st2 = db()->prepare('SELECT id FROM stores WHERE slug = ?');
            $st2->execute([$slug]);
            if ($st2->fetch()) $slug .= '-' . bin2hex(random_bytes(2));
            $trial = date('Y-m-d', time() + TRIAL_DAYS * 86400);
            db()->prepare('INSERT INTO stores (owner_id, name, slug, description, photo, province, municipality, trial_until, subscription_until, created_at) VALUES (?,?,?,?,?,?,?,?,NULL,?)')
                ->execute([$u['id'], $name, $slug, $desc, $photo, $province, $municipality, $trial, date('Y-m-d H:i:s')]);
            db()->prepare("UPDATE users SET role = 'seller' WHERE id = ?")->execute([$u['id']]);
            notify((int)$u['id'], '¡Tu mini tienda está abierta!', 'Tienes ' . TRIAL_DAYS . ' días de prueba gratis (hasta el ' . $trial . '). Publica productos y empieza a vender. Después, la suscripción cuesta ' . money(SUBSCRIPTION_CUP) . ' al mes.', 'vender.php');
            foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
                notify((int)$adm['id'], 'Nueva mini tienda', $u['name'] . ' abrió la tienda «' . $name . '» en ' . province_name($province) . (municipality_name($province, $municipality) !== '—' ? ', ' . municipality_name($province, $municipality) : '') . ' (prueba hasta ' . $trial . ').', 'admin/tiendas.php');
            }
            sec_log('tienda_creada', 'Nueva mini tienda: ' . $name . ' en ' . $province, (int)$u['id']);
            flash('¡Tu mini tienda está abierta! Ahora publica tu primer producto.', 'ok');
            redirect('vender.php');
        }
        redirect('mi-tienda.php');
    }
}

// Pre-selección para el formulario (lo que vino del POST o lo guardado)
$formProv = $_POST['province'] ?? ($store['province'] ?? '');
$formMuni = $_POST['municipality'] ?? ($store['municipality'] ?? '');

$galeria = array_slice(gallery_photos(), 0, 24);
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('store', 26) ?> <?= $store ? 'Editar mi mini tienda' : 'Abrir mi mini tienda' ?></h1>

<?php if (!$store): ?>
  <div class="flash flash-info mb">¡Es gratis! Al abrirla tienes <b><?= TRIAL_DAYS ?> días de prueba</b> para publicar y vender. Después la suscripción cuesta <b><?= money(SUBSCRIPTION_CUP) ?> al mes</b> (se paga con el saldo de tu billetera).</div>
<?php endif; ?>

<div class="card" style="max-width:640px">
  <form method="post" class="form form-wide" enctype="multipart/form-data">
    <?= csrf_field() ?>
    <div><label class="f">Nombre de la tienda *</label>
      <input class="input" name="name" required value="<?= e($store['name'] ?? '') ?>" placeholder="Ej: Cosas de María"></div>
    <div><label class="f">Descripción</label>
      <textarea class="input" name="description" placeholder="¿Qué vendes? ¿Cómo entregas? ¿Horarios?"><?= e($store['description'] ?? '') ?></textarea></div>

    <div class="row" style="gap:12px;align-items:flex-start">
      <div style="flex:1;min-width:200px">
        <label class="f">Provincia donde está tu tienda *</label>
        <select class="input" name="province" id="store-province" required onchange="fillMunicipalities(this.value)">
          <option value="">— Selecciona tu provincia —</option>
          <?php foreach (province_options() as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= $formProv === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div style="flex:1;min-width:200px">
        <label class="f">Municipio (opcional)</label>
        <select class="input" name="municipality" id="store-municipality">
          <option value="">— Cualquiera de la provincia —</option>
        </select>
      </div>
    </div>
    <p class="help">Tu tienda aparece primero en las búsquedas de quienes están en tu municipio y provincia. Si en tu zona no hay ventas, el sistema busca en las provincias cercanas.</p>
    <div>
      <label class="f">Foto / logo de la tienda</label>
      <input type="hidden" name="photo_choice" id="photo_choice" value="<?= $store ? e($store['photo']) : '' ?>">
      <div class="row">
        <label class="btn btn-outline" style="cursor:pointer;font-weight:600">Subir una foto</label>
        <input class="input" style="width:auto" type="file" name="photo_file" id="photo_file" accept=".jpg,.jpeg,.png,.webp,.gif">
      </div>
      <p class="help mb">O elige una de la galería incluida (toca la foto):</p>
      <div class="photo-pick">
        <?php foreach ($galeria as $i => $g): ?>
          <img src="<?= e($g) ?>" data-src="<?= e($g) ?>" onclick="
            document.getElementById('photo_choice').value='<?= e($g) ?>';
            document.querySelectorAll('.photo-pick img').forEach(function(x){x.classList.remove('on')});
            this.classList.add('on');
          " <?= $store && $store['photo'] === $g ? 'class="on"' : '' ?> alt="">
        <?php endforeach; ?>
      </div>
    </div>
    <button class="btn btn-violet" type="submit"><?= $store ? 'Guardar cambios' : icon('store', 18) . ' Abrir mi mini tienda gratis' ?></button>
    <?php if ($store): ?><a class="btn btn-outline" href="tienda.php?id=<?= (int)$store['id'] ?>">Ver mi tienda</a><?php endif; ?>
  </form>
</div>
<script>
// Mapa de provincias → municipios (inyectado desde PHP)
const CUBA_MUNIS = <?= json_encode(array_map(fn($p) => $p['municipalities'], cuba_provinces())) ?>;
const SELECTED_MUNI = <?= json_encode($formMuni) ?>;

function fillMunicipalities(prov) {
  const sel = document.getElementById('store-municipality');
  sel.innerHTML = '<option value="">— Cualquiera de la provincia —</option>';
  const munis = CUBA_MUNIS[prov] || {};
  for (const [slug, name] of Object.entries(munis)) {
    const o = document.createElement('option');
    o.value = slug; o.textContent = name;
    if (slug === SELECTED_MUNI) o.selected = true;
    sel.appendChild(o);
  }
}
// Al cargar, llena los municipios de la provincia ya elegida
(function(){
  const p = document.getElementById('store-province');
  if (p && p.value) fillMunicipalities(p.value);
})();
document.getElementById('photo_file').addEventListener('change', function () {
  if (this.value) document.getElementById('photo_choice').value = 'subida';
});
</script>

<?php include __DIR__ . '/includes/footer.php'; ?>
