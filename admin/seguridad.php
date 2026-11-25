<?php
/** Admin: seguridad — registro de eventos y cuentas bloqueadas. */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Seguridad — Administración';

$bloqueadas = db()->query('SELECT * FROM users WHERE locked_until IS NOT NULL AND locked_until > ' . db_now() . ' ORDER BY locked_until DESC')->fetchAll();
$log = db()->query('SELECT l.*, u.name AS uname FROM security_log l LEFT JOIN users u ON u.id = l.user_id ORDER BY l.id DESC LIMIT 120')->fetchAll();
$sesiones = db()->query('SELECT us.*, u.name AS uname FROM user_sessions us LEFT JOIN users u ON u.id = us.user_id ORDER BY us.last_seen DESC LIMIT 60')->fetchAll();
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)">🛡️ Seguridad</h1>

<h2 style="color:var(--violet-dark);font-size:17px;margin:10px 0">Cuentas bloqueadas ahora mismo</h2>
<?php if (!$bloqueadas): ?>
  <div class="card empty">Ninguna cuenta bloqueada en este momento. ✅</div>
<?php else: ?>
  <div class="card">
    <div class="table-wrap"><table class="tbl">
      <tr><th>Usuario</th><th>Correo</th><th>Bloqueada hasta</th><th></th></tr>
      <?php foreach ($bloqueadas as $b): ?>
      <tr>
        <td><b><?= e($b['name']) ?></b></td>
        <td><?= e($b['email'] ?? '—') ?></td>
        <td><?= e(fdate($b['locked_until'])) ?></td>
        <td>
          <form method="post" action="usuarios.php"><?= csrf_field() ?>
            <input type="hidden" name="user_id" value="<?= (int)$b['id'] ?>">
            <input type="hidden" name="accion" value="desbloquear">
            <button class="btn btn-green btn-sm" type="submit">Desbloquear ya</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  </div>
<?php endif; ?>

<h2 style="color:var(--violet-dark);font-size:17px;margin:18px 0 10px">Sesiones activas (últimas <?= count($sesiones) ?>)</h2>
<div class="card">
  <div class="table-wrap"><table class="tbl">
    <tr><th>Usuario</th><th>IP</th><th>Dispositivo</th><th>Último uso</th></tr>
    <?php foreach ($sesiones as $s): ?>
    <tr>
      <td><b><?= e($s['uname'] ?? '—') ?></b></td>
      <td class="help"><?= e($s['ip']) ?></td>
      <td class="help"><?= e(mb_substr($s['user_agent'] ?? '', 0, 70)) ?></td>
      <td class="muted" style="white-space:nowrap"><?= e(fdate($s['last_seen'])) ?></td>
    </tr>
    <?php endforeach; ?>
  </table></div>
</div>

<h2 style="color:var(--violet-dark);font-size:17px;margin:18px 0 10px">Registro de seguridad y bandeja de salida auditable</h2>
<div class="card">
  <div class="table-wrap"><table class="tbl">
    <tr><th>Fecha</th><th>Evento</th><th>Usuario</th><th>IP</th><th>Detalle</th></tr>
    <?php foreach ($log as $l): ?>
    <tr>
      <td class="muted" style="white-space:nowrap"><?= e(fdate($l['created_at'])) ?></td>
      <td><span class="badge b-info"><?= e(str_replace('_', ' ', $l['event'])) ?></span></td>
      <td><?= e($l['uname'] ?? '—') ?></td>
      <td class="help"><?= e($l['ip']) ?></td>
      <td class="help"><?= e($l['detail']) ?></td>
    </tr>
    <?php endforeach; ?>
  </table></div>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
