<?php
/**
 * ============================================================
 * PERFIL DE MENSAJERO (KYC)
 * ============================================================
 * El usuario se promociona como mensajero rellenando un formulario KYC:
 *  - Datos personales (nombre completo, carné de identidad, teléfono, dirección)
 *  - Provincia y municipio donde trabaja
 *  - Foto del carnet de identidad (anverso y reverso)
 *  - Foto de la cara (selfie, para reconocimiento facial / verificación)
 *
 * La "plantilla" se guarda en el servidor (tabla messengers + uploads/kyc/).
 * El dueño de tienda la ve cuando busca mensajeros o cuando alguien se
 * postula a su oferta. Sirve para futuras verificaciones en caso de problemas.
 *
 * Estados del perfil KYC:
 *  - pendiente : recién enviado, a la espera de aprobación de un admin
 *  - aprobado  : el admin validó la identidad, aparece en búsquedas
 *  - rechazado : el admin pidió reenviar (con nota)
 * ============================================================
 */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('mensajero-kyc.php');
$page_title = 'Perfil de mensajero — ' . SITE_NAME;

// ¿Ya tiene un perfil KYC de mensajero?
$st = db()->prepare('SELECT * FROM messengers WHERE user_id = ? ORDER BY id DESC LIMIT 1');
$st->execute([$u['id']]);
$perfil = $st->fetch();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('kyc', 5, 600)) { flash('Espera unos minutos antes de volver a enviar.', 'err'); redirect('mensajero-kyc.php'); }

    $accion = $_POST['accion'] ?? 'enviar';

    if ($accion === 'enviar' || $accion === 'reenviar') {
        $fullName = trim($_POST['full_name'] ?? '');
        $idNumber = trim($_POST['id_number'] ?? '');
        $phone = trim($_POST['phone'] ?? '');
        $province = trim($_POST['province'] ?? '');
        $municipality = trim($_POST['municipality'] ?? '');
        $address = trim($_POST['address'] ?? '');
        $vehicle = $_POST['vehicle'] ?? 'bicicleta';

        $provs = cuba_provinces();
        $errores = [];
        if (mb_strlen($fullName) < 5) $errores[] = 'Escribe tu nombre completo (al menos 5 letras).';
        if (mb_strlen($idNumber) < 6) $errores[] = 'Escribe tu número de carné de identidad.';
        if (mb_strlen($phone) < 8) $errores[] = 'Escribe un teléfono válido.';
        if ($province === '' || !isset($provs[$province])) $errores[] = 'Selecciona la provincia donde trabajas.';
        if ($province !== '' && $municipality !== '' && !isset($provs[$province]['municipalities'][$municipality])) $municipality = '';
        if (!in_array($vehicle, ['bicicleta', 'motocicleta', 'automovil', 'a_pie'], true)) $vehicle = 'bicicleta';

        // Subida de fotos (carnet frente, carnet dorso, cara)
        $idFront = $perfil['id_front'] ?? null;
        $idBack = $perfil['id_back'] ?? null;
        $face = $perfil['face_photo'] ?? null;

        $up1 = upload_image($_FILES['id_front'] ?? [], 'kyc');
        if ($up1) $idFront = $up1;
        elseif (!empty($_FILES['id_front']['name'])) $errores[] = 'La foto del carnet (frente) no se pudo subir. Usa JPG, PNG o WebP de hasta ' . MAX_UPLOAD_MB . ' MB.';

        $up2 = upload_image($_FILES['id_back'] ?? [], 'kyc');
        if ($up2) $idBack = $up2;
        elseif (!empty($_FILES['id_back']['name'])) $errores[] = 'La foto del carnet (dorso) no se pudo subir.';

        $up3 = upload_image($_FILES['face_photo'] ?? [], 'kyc');
        if ($up3) $face = $up3;
        elseif (!empty($_FILES['face_photo']['name'])) $errores[] = 'La foto de tu cara no se pudo subir.';

        // Si es primer envío, las 3 fotos son obligatorias
        if (!$perfil) {
            if (!$idFront) $errores[] = 'Sube la foto del frente de tu carné.';
            if (!$idBack) $errores[] = 'Sube la foto del dorso de tu carné.';
            if (!$face) $errores[] = 'Sube una foto de tu cara (selfie) para verificación facial.';
        }

        if ($errores) {
            foreach ($errores as $er) flash($er, 'err');
        } else {
            $now = date('Y-m-d H:i:s');
            if ($perfil && $accion === 'reenviar') {
                // Reenvío tras rechazo: vuelve a pendiente
                db()->prepare('UPDATE messengers SET full_name=?, id_number=?, phone=?, province=?, municipality=?, address=?, vehicle=?, id_front=?, id_back=?, face_photo=?, status="pendiente", submitted_at=?, reviewed_at=NULL WHERE id=?')
                    ->execute([$fullName, $idNumber, $phone, $province, $municipality ?: null, $address ?: null, $vehicle, $idFront, $idBack, $face, $now, $perfil['id']]);
                flash('Perfil reenviado para revisión. Te avisaremos al aprobarlo.', 'ok');
            } elseif ($perfil) {
                // Edición de un perfil ya existente (mantiene el estado salvo que fuera rechazado)
                db()->prepare('UPDATE messengers SET full_name=?, id_number=?, phone=?, province=?, municipality=?, address=?, vehicle=?, id_front=?, id_back=?, face_photo=? WHERE id=?')
                    ->execute([$fullName, $idNumber, $phone, $province, $municipality ?: null, $address ?: null, $vehicle, $idFront, $idBack, $face, $perfil['id']]);
                flash('Perfil de mensajero actualizado.', 'ok');
            } else {
                db()->prepare('INSERT INTO messengers (user_id, full_name, id_number, phone, province, municipality, address, vehicle, id_front, id_back, face_photo, status, submitted_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)')
                    ->execute([$u['id'], $fullName, $idNumber, $phone, $province, $municipality ?: null, $address ?: null, $vehicle, $idFront, $idBack, $face, $now]);
                // Avisar a los admins para que revisen el KYC
                foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
                    notify((int)$adm['id'], 'Nuevo perfil de mensajero pendiente', $fullName . ' se postuló como mensajero en ' . province_name($province) . ($municipality ? ', ' . municipality_name($province, $municipality) : '') . '. Revisa su KYC.', 'admin/mensajeros.php');
                }
                notify((int)$u['id'], 'Perfil de mensajero enviado', 'Recibimos tu perfil de mensajero. Un administrador revisará tus datos y te avisaremos al aprobarlo. Mientras, no aparecerás en las búsquedas de dueños de tienda.', 'mensajero-kyc.php');
                sec_log('kyc_enviado', 'Perfil de mensajero: ' . $fullName . ' en ' . $province, (int)$u['id']);
                flash('¡Perfil enviado! Un administrador revisará tu identidad. Te avisaremos al aprobarlo.', 'ok');
            }
            redirect('mensajero-kyc.php');
        }
    }
}

// Pre-selección del formulario
$fProv = $_POST['province'] ?? ($perfil['province'] ?? ($u['default_province'] ?? ''));
$fMuni = $_POST['municipality'] ?? ($perfil['municipality'] ?? ($u['default_municipality'] ?? ''));

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('bike', 26) ?> Perfil de mensajero</h1>
<p class="muted mb">Promocionate como mensajero para que los dueños de tienda te encuentren cuando necesiten entregar pedidos. Tus datos se guardan como plantilla en el servidor (verificación KYC) y solo los ven los dueños de tienda y administradores.</p>

<?php if ($perfil): ?>
  <div class="flash flash-info mb">
    <b>Estado de tu perfil:</b>
    <?php if ($perfil['status'] === 'pendiente'): ?>
      <span class="badge b-info">En revisión</span> Un administrador está revisando tu identidad. Te avisaremos al aprobarlo.
    <?php elseif ($perfil['status'] === 'aprobado'): ?>
      <span class="badge b-ok">Aprobado</span> Tu perfil está activo y aparece en las búsquedas de dueños de tienda. <?= $perfil['reviewed_at'] ? 'Aprobado el ' . e(fdate($perfil['reviewed_at'])) : '' ?>
    <?php else: ?>
      <span class="badge b-warn">Rechazado</span> <?= e($perfil['review_note'] ?? 'Tu perfil fue rechazado. Revisa tus datos y vuelve a enviarlo.') ?>
    <?php endif; ?>
  </div>
<?php endif; ?>

<div class="card" style="max-width:720px">
  <form method="post" class="form form-wide" enctype="multipart/form-data">
    <?= csrf_field() ?>
    <input type="hidden" name="accion" value="<?= $perfil && $perfil['status'] === 'rechazado' ? 'reenviar' : 'enviar' ?>">

    <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('user', 20) ?> Datos personales</h2>
    <div><label class="f">Nombre completo *</label>
      <input class="input" name="full_name" required value="<?= e($_POST['full_name'] ?? ($perfil['full_name'] ?? $u['name'])) ?>"></div>
    <div class="row" style="gap:12px">
      <div style="flex:1"><label class="f">Carné de identidad *</label>
        <input class="input" name="id_number" required value="<?= e($_POST['id_number'] ?? ($perfil['id_number'] ?? '')) ?>" placeholder="Ej: 99010112345"></div>
      <div style="flex:1"><label class="f">Teléfono *</label>
        <input class="input" name="phone" required value="<?= e($_POST['phone'] ?? ($perfil['phone'] ?? $u['phone'] ?? '')) ?>"></div>
    </div>

    <h2 style="color:var(--violet-dark);font-size:17px;margin-top:18px"><?= icon('map-pin', 20) ?> Zona de trabajo</h2>
    <div class="row" style="gap:12px;align-items:flex-start">
      <div style="flex:1;min-width:200px">
        <label class="f">Provincia donde trabajas *</label>
        <select class="input" name="province" id="m-province" required onchange="fillMunis(this.value)">
          <option value="">— Selecciona —</option>
          <?php foreach (province_options() as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= $fProv === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div style="flex:1;min-width:200px">
        <label class="f">Municipio (opcional)</label>
        <select class="input" name="municipality" id="m-municipality">
          <option value="">— Toda la provincia —</option>
        </select>
      </div>
    </div>
    <div><label class="f">Dirección de casa</label>
      <input class="input" name="address" value="<?= e($_POST['address'] ?? ($perfil['address'] ?? '')) ?>" placeholder="Calle, número, entre calles"></div>
    <div><label class="f">Medio de transporte</label>
      <select class="input" name="vehicle">
        <?php
        $vehis = ['bicicleta' => 'Bicicleta', 'motocicleta' => 'Motocicleta', 'automovil' => 'Automóvil', 'a_pie' => 'A pie'];
        $selV = $_POST['vehicle'] ?? ($perfil['vehicle'] ?? 'bicicleta');
        foreach ($vehis as $k => $v): ?>
          <option value="<?= e($k) ?>" <?= $selV === $k ? 'selected' : '' ?>><?= e($v) ?></option>
        <?php endforeach; ?>
      </select></div>

    <h2 style="color:var(--violet-dark);font-size:17px;margin-top:18px"><?= icon('camera', 20) ?> Verificación de identidad (KYC)</h2>
    <p class="help mb">Sube fotos nítidas de tu carné de identidad (anverso y reverso) y una selfie de tu cara para verificación facial. Quedan guardadas en el servidor y solo las ven los dueños de tienda y administradores.</p>
    <div class="grid grid-cols-3" style="gap:12px">
      <div>
        <label class="f">Carné — frente *</label>
        <?php if (!empty($perfil['id_front'])): ?>
          <img src="<?= e($perfil['id_front']) ?>" alt="Carné frente" style="width:100%;max-height:140px;object-fit:cover;border-radius:8px;border:1px solid var(--violet-border)">
        <?php endif; ?>
        <input type="file" name="id_front" accept="image/jpeg,image/png,image/webp" <?= $perfil ? '' : 'required' ?> style="margin-top:6px">
      </div>
      <div>
        <label class="f">Carné — dorso *</label>
        <?php if (!empty($perfil['id_back'])): ?>
          <img src="<?= e($perfil['id_back']) ?>" alt="Carné dorso" style="width:100%;max-height:140px;object-fit:cover;border-radius:8px;border:1px solid var(--violet-border)">
        <?php endif; ?>
        <input type="file" name="id_back" accept="image/jpeg,image/png,image/webp" <?= $perfil ? '' : 'required' ?> style="margin-top:6px">
      </div>
      <div>
        <label class="f">Tu cara (selfie) *</label>
        <?php if (!empty($perfil['face_photo'])): ?>
          <img src="<?= e($perfil['face_photo']) ?>" alt="Selfie" style="width:100%;max-height:140px;object-fit:cover;border-radius:8px;border:1px solid var(--violet-border)">
        <?php endif; ?>
        <input type="file" name="face_photo" accept="image/jpeg,image/png,image/webp" <?= $perfil ? '' : 'required' ?> style="margin-top:6px" capture="user">
      </div>
    </div>
    <p class="help mt">La foto de la cara se usa para reconocimiento facial (verificación tipo KYC). Si ya subiste una foto y no la cambias, se mantiene la anterior.</p>

    <button class="btn btn-violet" type="submit" style="width:100%;margin-top:14px">
      <?= icon('check', 18) ?> <?= $perfil ? 'Actualizar perfil' : 'Enviar perfil para revisión' ?>
    </button>
  </form>
</div>

<?php if ($perfil && $perfil['status'] === 'aprobado'): ?>
<div class="card mt" style="max-width:720px">
  <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('search', 20) ?> Ofertas de mensajería disponibles</h2>
  <p class="help">Estas son las ofertas que han publicado los dueños de tienda. Puedes postularte a las que te interesen.</p>
  <?php
  // Ofertas abiertas, priorizando las de la provincia del mensajero
  $nearby = nearby_provinces($perfil['province'], 1);
  $ph = implode(',', array_fill(0, count($nearby), '?'));
  $st = db()->prepare("SELECT o.*, s.name AS store_name, s.slug AS store_slug,
          (SELECT COUNT(*) FROM messenger_applications a WHERE a.offer_id = o.id AND a.messenger_id = ?) AS ya_postulado
          FROM messenger_offers o LEFT JOIN stores s ON s.id = o.store_id
          WHERE o.status = 'abierta' ORDER BY (o.province = ?) DESC, (o.province IN ($ph)) DESC, o.id DESC LIMIT 30");
  $st->execute(array_merge([$perfil['id'], $perfil['province']], $nearby));
  $ofertas = $st->fetchAll();
  if (!$ofertas): ?>
    <p class="muted">Todavía no hay ofertas de mensajería. Vuelve a revisar en unos días.</p>
  <?php else: foreach ($ofertas as $o): ?>
    <div class="card mb" style="border:1px solid var(--violet-border)">
      <div class="row-between">
        <div>
          <b><?= e($o['title']) ?></b>
          <span class="badge b-info"><?= e($o['store_name'] ?? 'Tienda') ?></span>
          <?php if ($o['pay_cup']): ?><span class="badge b-ok"><?= money($o['pay_cup']) ?></span><?php endif; ?>
          <div class="help"><?= icon('map-pin', 13) ?> <?= e(province_name($o['province'])) ?><?= $o['municipality'] ? ' · ' . e(municipality_name($o['province'], $o['municipality'])) : '' ?> · <?= e(fdate($o['created_at'])) ?></div>
        </div>
      </div>
      <?php if (!empty($o['description'])): ?><p class="mt" style="margin-bottom:8px"><?= e($o['description']) ?></p><?php endif; ?>
      <?php if ($o['ya_postulado']): ?>
        <span class="badge b-info"><?= icon('check', 13) ?> Ya te postulaste</span>
      <?php else: ?>
        <form method="post" action="ofertas-mensajeros.php"><?= csrf_field() ?>
          <input type="hidden" name="accion" value="postular">
          <input type="hidden" name="offer_id" value="<?= (int)$o['id'] ?>">
          <input class="input" name="message" placeholder="Mensaje opcional para el dueño de la tienda (disponibilidad, experiencia…)" style="margin-bottom:8px">
          <button class="btn btn-violet btn-sm" type="submit"><?= icon('send', 14) ?> Postularme</button>
        </form>
      <?php endif; ?>
    </div>
  <?php endforeach; endif; ?>
</div>
<?php endif; ?>

<script>
const CUBA_MUNIS_M = <?= json_encode(array_map(fn($p) => $p['municipalities'], cuba_provinces())) ?>;
const SEL_M_MUNI = <?= json_encode($fMuni) ?>;
function fillMunis(prov) {
  const sel = document.getElementById('m-municipality');
  sel.innerHTML = '<option value="">— Toda la provincia —</option>';
  const munis = CUBA_MUNIS_M[prov] || {};
  for (const [slug, name] of Object.entries(munis)) {
    const o = document.createElement('option');
    o.value = slug; o.textContent = name;
    if (slug === SEL_M_MUNI) o.selected = true;
    sel.appendChild(o);
  }
}
(function(){ const p = document.getElementById('m-province'); if (p && p.value) fillMunis(p.value); })();
</script>

<?php include __DIR__ . '/includes/footer.php'; ?>
