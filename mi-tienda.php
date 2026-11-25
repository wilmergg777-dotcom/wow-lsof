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
    } else {
        if ($store) {
            db()->prepare('UPDATE stores SET name = ?, description = ?, photo = ? WHERE id = ?')
                ->execute([$name, $desc, $photo, $store['id']]);
            flash('Datos de tu tienda actualizados.', 'ok');
        } else {
            $slug = slug($name);
            $st2 = db()->prepare('SELECT id FROM stores WHERE slug = ?');
            $st2->execute([$slug]);
            if ($st2->fetch()) $slug .= '-' . bin2hex(random_bytes(2));
            $trial = date('Y-m-d', time() + TRIAL_DAYS * 86400);
            db()->prepare('INSERT INTO stores (owner_id, name, slug, description, photo, trial_until, subscription_until, created_at) VALUES (?,?,?,?,?,?,NULL,?)')
                ->execute([$u['id'], $name, $slug, $desc, $photo, $trial, date('Y-m-d H:i:s')]);
            db()->prepare("UPDATE users SET role = 'seller' WHERE id = ?")->execute([$u['id']]);
            notify((int)$u['id'], '¡Tu mini tienda está abierta! 🌸', 'Tienes ' . TRIAL_DAYS . ' días de prueba gratis (hasta el ' . $trial . '). Publica productos y empieza a vender. Después, la suscripción cuesta ' . money(SUBSCRIPTION_CUP) . ' al mes.', 'vender.php');
            foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
                notify((int)$adm['id'], 'Nueva mini tienda', $u['name'] . ' abrió la tienda «' . $name . '» (prueba hasta ' . $trial . ').', 'admin/tiendas.php');
            }
            sec_log('tienda_creada', 'Nueva mini tienda: ' . $name, (int)$u['id']);
            flash('¡Tu mini tienda está abierta! Ahora publica tu primer producto.', 'ok');
            redirect('vender.php');
        }
        redirect('mi-tienda.php');
    }
}

$galeria = array_slice(gallery_photos(), 0, 24);
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)">🌸 <?= $store ? 'Editar mi mini tienda' : 'Abrir mi mini tienda' ?></h1>

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
    <button class="btn btn-violet" type="submit"><?= $store ? 'Guardar cambios' : '🌸 Abrir mi mini tienda gratis' ?></button>
    <?php if ($store): ?><a class="btn btn-outline" href="tienda.php?id=<?= (int)$store['id'] ?>">Ver mi tienda</a><?php endif; ?>
  </form>
</div>
<script>
document.getElementById('photo_file').addEventListener('change', function () {
  if (this.value) document.getElementById('photo_choice').value = 'subida';
});
</script>

<?php include __DIR__ . '/includes/footer.php'; ?>
