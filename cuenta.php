<?php
/** Mi Cuenta: datos personales, contraseña y sesiones activas. */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('cuenta.php');
$page_title = 'Mi Cuenta — ' . SITE_NAME;
$tab = $_GET['tab'] ?? 'datos';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'datos') {
        if (!rate_limit('perfil', 15, 600)) { flash('Espera un momento antes de volver a guardar.', 'err'); }
        else {
            $name = trim($_POST['name'] ?? '');
            $phone = trim($_POST['phone'] ?? '');
            $email = strtolower(trim($_POST['email'] ?? ''));
            if (mb_strlen($name) < 3) flash('El nombre es demasiado corto.', 'err');
            elseif (mb_strlen($phone) < 8) flash('Escribe un teléfono válido.', 'err');
            elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) flash('Escribe un correo válido.', 'err');
            else {
                $st = db()->prepare('SELECT id FROM users WHERE email = ? AND id != ?');
                $st->execute([$email, $u['id']]);
                if ($st->fetch()) {
                    flash('Ese correo ya lo usa otra cuenta.', 'err');
                } else {
                    db()->prepare('UPDATE users SET name = ?, phone = ?, email = ? WHERE id = ?')->execute([$name, $phone, $email, $u['id']]);
                    sec_log('perfil_actualizado', 'Datos personales actualizados', (int)$u['id']);
                    flash('Datos guardados correctamente.', 'ok');
                }
            }
        }
        redirect('cuenta.php?tab=' . e($tab));
    }

    if ($accion === 'password') {
        $cur = $_POST['current'] ?? '';
        $new = $_POST['password'] ?? '';
        $new2 = $_POST['password2'] ?? '';
        if (mb_strlen($new) < 8) flash('La contraseña nueva necesita al menos 8 caracteres.', 'err');
        elseif ($new !== $new2) flash('Las contraseñas nuevas no coinciden.', 'err');
        elseif (!change_password((int)$u['id'], $cur, $new)) {
            sec_log('password_change_fallido', 'Contraseña actual incorrecta', (int)$u['id']);
            flash('La contraseña actual no es correcta.', 'err');
        } else {
            flash('Contraseña cambiada. Cerramos las demás sesiones por seguridad.', 'ok');
        }
        redirect('cuenta.php?tab=seguridad');
    }

    if ($accion === 'cerrar_otra') {
        $token = $_POST['token'] ?? '';
        db()->prepare('DELETE FROM user_sessions WHERE user_id = ? AND token = ?')->execute([$u['id'], $token]);
        flash('Sesión cerrada en ese dispositivo.', 'ok');
        redirect('cuenta.php?tab=seguridad');
    }
    if ($accion === 'cerrar_otras') {
        db()->prepare('DELETE FROM user_sessions WHERE user_id = ? AND token != ?')->execute([$u['id'], session_id()]);
        sec_log('sesiones_cerradas', 'Cerró manualmente las demás sesiones', (int)$u['id']);
        flash('Cerramos las sesiones de los demás dispositivos.', 'ok');
        redirect('cuenta.php?tab=seguridad');
    }

    if ($accion === 'ubicacion') {
        if (!rate_limit('perfil', 15, 600)) { flash('Espera un momento antes de volver a guardar.', 'err'); }
        else {
            $province = trim($_POST['default_province'] ?? '');
            $municipality = trim($_POST['default_municipality'] ?? '');
            $provs = cuba_provinces();
            if ($province !== '' && !isset($provs[$province])) { $province = ''; $municipality = ''; }
            if ($province !== '' && $municipality !== '' && !isset($provs[$province]['municipalities'][$municipality])) {
                $municipality = '';
            }
            db()->prepare('UPDATE users SET default_province = ?, default_municipality = ? WHERE id = ?')
                ->execute([$province ?: null, $municipality ?: null, $u['id']]);
            sec_log('ubicacion_actualizada', 'Ubicación por defecto: ' . province_name($province) . ' / ' . municipality_name($province, $municipality), (int)$u['id']);
            flash('Tu ubicación de búsqueda se guardó. Verás primero las ventas de tu zona.', 'ok');
        }
        redirect('cuenta.php?tab=datos');
    }
}

$st = db()->prepare('SELECT * FROM user_sessions WHERE user_id = ? ORDER BY last_seen DESC');
$st->execute([$u['id']]);
$sessions = $st->fetchAll();

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$myStore = $st->fetch();
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('user', 26) ?> Mi Cuenta</h1>
<p class="muted mb">Hola, <?= e($u['name']) ?>. Saldo de tu billetera: <b><?= money($u['balance_cup']) ?></b> · <a href="wallet.php">Ver billetera</a></p>

<div class="pill-tabs">
  <a href="cuenta.php?tab=datos" class="<?= $tab === 'datos' ? 'on' : '' ?>">Datos personales</a>
  <a href="cuenta.php?tab=seguridad" class="<?= $tab === 'seguridad' ? 'on' : '' ?>">Seguridad y sesiones</a>
  <?php if ($myStore): ?><a href="cuenta.php?tab=tienda" class="<?= $tab === 'tienda' ? 'on' : '' ?>">Mi mini tienda</a><?php endif; ?>
</div>

<?php if ($tab === 'datos'): ?>
  <div class="card" style="max-width:560px">
    <form method="post" class="form">
      <?= csrf_field() ?>
      <input type="hidden" name="accion" value="datos">
      <div><label class="f">Nombre</label><input class="input" name="name" value="<?= e($u['name']) ?>" required></div>
      <div><label class="f">Correo electrónico</label><input class="input" type="email" name="email" value="<?= e($u['email']) ?>" required></div>
      <div><label class="f">Teléfono</label><input class="input" name="phone" value="<?= e($u['phone']) ?>" required></div>
      <div><label class="f">Miembro desde</label><input class="input" value="<?= e(fdate($u['created_at'])) ?>" disabled></div>
      <button class="btn btn-violet" type="submit">Guardar datos</button>
    </form>
  </div>

  <div class="card mt" style="max-width:560px">
    <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:6px"><?= icon('map-pin', 20) ?> Mi ubicación de búsqueda</h2>
    <p class="help mb">Elige dónde compras normalmente. En la portada y el catálogo verás primero las ventas de tu municipio, luego de tu provincia y, si no hay, de las provincias cercanas.</p>
    <form method="post" class="form">
      <?= csrf_field() ?>
      <input type="hidden" name="accion" value="ubicacion">
      <div><label class="f">Provincia</label>
        <select class="input" name="default_province" id="user-province" onchange="fillUserMunis(this.value)">
          <option value="">— Toda Cuba (sin preferencia) —</option>
          <?php foreach (province_options() as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= ($u['default_province'] ?? '') === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div><label class="f">Municipio (opcional)</label>
        <select class="input" name="default_municipality" id="user-municipality">
          <option value="">— Toda la provincia —</option>
        </select>
      </div>
      <button class="btn btn-violet" type="submit"><?= icon('check', 16) ?> Guardar ubicación</button>
    </form>
  </div>
  <script>
  const CUBA_MUNIS2 = <?= json_encode(array_map(fn($p) => $p['municipalities'], cuba_provinces())) ?>;
  const SEL_USER_MUNI = <?= json_encode($u['default_municipality'] ?? '') ?>;
  function fillUserMunis(prov) {
    const sel = document.getElementById('user-municipality');
    sel.innerHTML = '<option value="">— Toda la provincia —</option>';
    const munis = CUBA_MUNIS2[prov] || {};
    for (const [slug, name] of Object.entries(munis)) {
      const o = document.createElement('option');
      o.value = slug; o.textContent = name;
      if (slug === SEL_USER_MUNI) o.selected = true;
      sel.appendChild(o);
    }
  }
  (function(){ const p = document.getElementById('user-province'); if (p && p.value) fillUserMunis(p.value); })();
  </script>

<?php elseif ($tab === 'seguridad'): ?>
  <div class="grid grid-cols-2">
    <div class="card">
      <h2 style="color:var(--violet-dark);font-size:17px">Cambiar contraseña</h2>
      <p class="help mb">Al cambiarla, se cierran automáticamente las sesiones de los demás dispositivos.</p>
      <form method="post" class="form" style="max-width:none">
        <?= csrf_field() ?>
        <input type="hidden" name="accion" value="password">
        <div><label class="f">Contraseña actual</label><input class="input" type="password" name="current" required></div>
        <div><label class="f">Contraseña nueva (mínimo 8)</label><input class="input" type="password" name="password" minlength="8" required></div>
        <div><label class="f">Repite la nueva</label><input class="input" type="password" name="password2" minlength="8" required></div>
        <button class="btn btn-violet" type="submit">Cambiar contraseña</button>
      </form>
    </div>

    <div class="card">
      <div class="row-between mb">
        <h2 style="color:var(--violet-dark);font-size:17px">Sesiones activas (<?= count($sessions) ?>)</h2>
        <form method="post"><?= csrf_field() ?>
          <input type="hidden" name="accion" value="cerrar_otras">
          <button class="btn btn-red btn-sm" type="submit" onclick="return confirmDel('¿Cerrar las sesiones de TODOS los demás dispositivos?')">Cerrar las demás</button>
        </form>
      </div>
      <div class="table-wrap"><table class="tbl">
        <tr><th>Dispositivo</th><th>Último uso</th><th></th></tr>
        <?php foreach ($sessions as $s): $esActual = $s['token'] === session_id(); ?>
        <tr>
          <td>
            <?= $esActual ? '<span class="badge b-ok">Este dispositivo</span>' : '<span class="badge b-info">Otro dispositivo</span>' ?><br>
            <span class="help"><?= e(mb_substr($s['user_agent'] ?? 'Dispositivo', 0, 60)) ?></span><br>
            <span class="help">IP: <?= e($s['ip']) ?></span>
          </td>
          <td class="muted" style="white-space:nowrap"><?= e(fdate($s['last_seen'])) ?></td>
          <td>
            <?php if (!$esActual): ?>
              <form method="post"><?= csrf_field() ?>
                <input type="hidden" name="accion" value="cerrar_otra">
                <input type="hidden" name="token" value="<?= e($s['token']) ?>">
                <button class="btn btn-outline btn-sm" type="submit">Cerrar</button>
              </form>
            <?php endif; ?>
          </td>
        </tr>
        <?php endforeach; ?>
      </table></div>
    </div>
  </div>

<?php else: ?>
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px">Mi mini tienda: <?= e($myStore['name']) ?></h2>
    <div class="row mb"><?= store_status_badge($myStore) ?></div>
    <?php $estado = store_status($myStore); ?>
    <?php if ($estado === 'suspendida'): ?>
      <div class="flash flash-warn">Tu prueba terminó y la suscripción no está pagada. Tus productos no se ven al público. Paga la suscripción de <?= money(SUBSCRIPTION_CUP) ?> al mes desde <a href="suscripcion.php">Suscripción</a>.</div>
    <?php elseif ($estado === 'prueba'): ?>
      <div class="flash flash-info">Estás en la prueba gratis hasta el <b><?= e($myStore['trial_until']) ?></b>. Después, la suscripción cuesta <?= money(SUBSCRIPTION_CUP) ?> al mes y se paga con tu saldo.</div>
    <?php else: ?>
      <div class="flash flash-ok">Suscripción al día hasta el <b><?= e($myStore['subscription_until']) ?></b>. ¡Gracias por apoyar la comunidad!</div>
    <?php endif; ?>
    <div class="row">
      <a class="btn btn-violet" href="vender.php">Ir al panel del vendedor</a>
      <a class="btn btn-outline" href="tienda.php?id=<?= (int)$myStore['id'] ?>">Ver mi tienda</a>
    </div>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
