<?php
/**
 * Ver el perfil KYC completo de un mensajero.
 * Visible para dueños de tienda (role seller/admin) que buscan mensajeros.
 * Muestra datos personales, fotos del carnet (frente/dorso) y selfie facial.
 */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller('ver-mensajero.php');
$page_title = 'Perfil de mensajero — ' . SITE_NAME;

$id = (int)($_GET['id'] ?? 0);
$st = db()->prepare('SELECT m.*, u.email, u.role AS user_role, u.created_at AS user_since
                     FROM messengers m JOIN users u ON u.id = m.user_id WHERE m.id = ?');
$st->execute([$id]);
$m = $st->fetch();
if (!$m) { flash('Ese perfil de mensajero no existe.', 'err'); redirect('buscar-mensajeros.php'); }

// Solo dueños de tienda y admins pueden ver el KYC completo
if (($u['role'] ?? '') !== 'admin' && ($u['role'] ?? '') !== 'seller') {
    flash('No tienes permiso para ver este perfil.', 'err'); redirect('index.php');
}

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('bike', 26) ?> Perfil de mensajero</h1>
<p class="muted mb">Datos de verificación KYC. Esta información es confidencial y se guarda para resolver cualquier incidencia futura con las entregas.</p>

<div class="grid grid-cols-2 mt">
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('user', 20) ?> Datos personales</h2>
    <div class="row"><b>Nombre completo:</b><span><?= e($m['full_name']) ?></span></div>
    <div class="row"><b>Carné de identidad:</b><span><?= e($m['id_number'] ?: '—') ?></span></div>
    <div class="row"><b>Teléfono:</b><span><a href="tel:<?= e($m['phone']) ?>"><?= e($m['phone']) ?></a></span></div>
    <div class="row"><b>Correo:</b><span><?= e($m['email'] ?: '—') ?></span></div>
    <div class="row"><b>Dirección:</b><span><?= e($m['address'] ?: '—') ?></span></div>
    <div class="row"><b>Zona de trabajo:</b><span><?= e(province_name($m['province'])) ?><?= $m['municipality'] ? ' · ' . e(municipality_name($m['province'], $m['municipality'])) : '' ?></span></div>
    <div class="row"><b>Medio de transporte:</b><span><?= e(['bicicleta' => '🚲 Bicicleta', 'motocicleta' => '🛵 Motocicleta', 'automovil' => '🚗 Automóvil', 'a_pie' => '🚶 A pie'][$m['vehicle']] ?? $m['vehicle']) ?></span></div>
    <div class="row"><b>Estado del perfil:</b>
      <span class="badge <?= $m['status'] === 'aprobado' ? 'b-ok' : ($m['status'] === 'pendiente' ? 'b-info' : 'b-warn') ?>"><?= ucfirst($m['status']) ?></span>
    </div>
    <div class="row"><b>En KlikCuba desde:</b><span class="muted"><?= e(fdate($m['user_since'])) ?></span></div>
  </div>

  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('camera', 20) ?> Verificación de identidad (KYC)</h2>
    <div class="grid grid-cols-2" style="gap:10px">
      <div>
        <label class="f">Carné — frente</label>
        <?php if ($m['id_front']): ?>
          <img src="<?= e($m['id_front']) ?>" alt="Carné frente" style="width:100%;border-radius:8px;border:1px solid var(--violet-border" onclick="this.requestFullscreen?.()">
        <?php else: ?><p class="muted">Sin foto</p><?php endif; ?>
      </div>
      <div>
        <label class="f">Carné — dorso</label>
        <?php if ($m['id_back']): ?>
          <img src="<?= e($m['id_back']) ?>" alt="Carné dorso" style="width:100%;border-radius:8px;border:1px solid var(--violet-border)" onclick="this.requestFullscreen?.()">
        <?php else: ?><p class="muted">Sin foto</p><?php endif; ?>
      </div>
      <div style="grid-column:1/-1">
        <label class="f">Selfie (verificación facial)</label>
        <?php if ($m['face_photo']): ?>
          <img src="<?= e($m['face_photo']) ?>" alt="Selfie" style="width:160px;border-radius:8px;border:1px solid var(--violet-border)" onclick="this.requestFullscreen?.()">
        <?php else: ?><p class="muted">Sin foto</p><?php endif; ?>
      </div>
    </div>
    <p class="help mt">Las fotos se guardan en el servidor como plantilla de verificación. Si hay un problema con una entrega, sirven para identificar al mensajero.</p>
  </div>
</div>

<div class="card mt">
  <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('phone', 20) ?> Contactar</h2>
  <div class="row" style="gap:8px">
    <a class="btn btn-violet" href="tel:<?= e($m['phone']) ?>"><?= icon('phone', 16) ?> Llamar por teléfono</a>
    <?php if (!empty($m['email'])): ?><a class="btn btn-outline" href="mailto:<?= e($m['email']) ?>"><?= icon('mail', 16) ?> Enviar correo</a><?php endif; ?>
    <a class="btn btn-outline" href="buscar-mensajeros.php"><?= icon('arrow-left', 16) ?> Volver a la lista</a>
  </div>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
