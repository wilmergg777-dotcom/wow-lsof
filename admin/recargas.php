<?php
/** Admin: verificar y aprobar/rechazar recargas de billetera. */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Recargas — Administración';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $tid = (int)($_POST['topup_id'] ?? 0);
    $accion = $_POST['accion'] ?? '';
    $st = db()->prepare('SELECT t.*, u.name AS uname FROM topups t LEFT JOIN users u ON u.id = t.user_id WHERE t.id = ?');
    $st->execute([$tid]);
    $t = $st->fetch();
    if ($t && $t['status'] === 'pendiente') {
        if ($accion === 'aprobar') {
            db()->prepare('UPDATE topups SET status = "aprobada", processed_at = ?, admin_note = ? WHERE id = ?')
                ->execute([date('Y-m-d H:i:s'), mb_substr(trim($_POST['nota'] ?? ''), 0, 300), $tid]);
            db()->prepare('UPDATE users SET balance_cup = balance_cup + ? WHERE id = ?')->execute([(int)$t['amount_cup'], (int)$t['user_id']]);
            notify((int)$t['user_id'], '¡Recarga aprobada!', 'Acreditamos ' . money($t['amount_cup']) . ' en tu billetera. ¡Buenas compras!', 'wallet.php');
            flash('Recarga aprobada: se acreditaron ' . money($t['amount_cup']) . ' a ' . $t['uname'] . '.', 'ok');
        }
        if ($accion === 'rechazar') {
            db()->prepare('UPDATE topups SET status = "rechazada", processed_at = ?, admin_note = ? WHERE id = ?')
                ->execute([date('Y-m-d H:i:s'), mb_substr(trim($_POST['nota'] ?? 'No pudimos verificar la transferencia.'), 0, 300), $tid]);
            notify((int)$t['user_id'], 'Recarga rechazada', 'No pudimos verificar tu recarga de ' . money($t['amount_cup']) . ' (ID: ' . $t['transfer_id'] . '). Revisa la nota del administrador en tu billetera.', 'wallet.php');
            flash('Recarga rechazada.', 'ok');
        }
        sec_log('admin_recarga', 'Recarga #' . $tid . ': ' . $accion . ' (' . money($t['amount_cup']) . ')', (int)$admin['id']);
    }
    redirect('recargas.php');
}

$pend = db()->query('SELECT t.*, u.name AS uname, u.phone AS uphone FROM topups t LEFT JOIN users u ON u.id = t.user_id WHERE t.status = "pendiente" ORDER BY t.id ASC')->fetchAll();
$hist = db()->query('SELECT t.*, u.name AS uname FROM topups t LEFT JOIN users u ON u.id = t.user_id WHERE t.status != "pendiente" ORDER BY t.id DESC LIMIT 50')->fetchAll();
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('wallet', 26) ?> Recargas de billetera</h1>

<?php if ($pend): ?>
  <div class="flash flash-warn">Tienes <b><?= count($pend) ?></b> recarga(s) por verificar. Comprueba el ID de la transferencia en el banco antes de aprobar.</div>
<?php endif; ?>

<h2 style="color:var(--violet-dark);font-size:17px;margin:10px 0">Pendientes de verificar</h2>
<?php if (!$pend): ?>
  <div class="card empty"><?= icon('check', 20) ?> No hay recargas pendientes. Todo al día.</div>
<?php else: ?>
  <?php foreach ($pend as $t): ?>
  <div class="card mb">
    <div class="row-between">
      <div>
        <b><?= e($t['uname']) ?></b> pide <b style="color:var(--violet-dark)"><?= money($t['amount_cup']) ?></b>
        <div class="help">Solicitada el <?= e(fdate($t['created_at'])) ?> · ID de transferencia: <b><?= e($t['transfer_id']) ?></b> · Tel: <?= e($t['uphone'] ?? '—') ?></div>
      </div>
    </div>
    <form method="post" class="row mt"><?= csrf_field() ?>
      <input type="hidden" name="topup_id" value="<?= (int)$t['id'] ?>">
      <input class="input" style="max-width:340px" name="nota" placeholder="Nota (opcional al aprobar / obligatoria al rechazar)">
      <button class="btn btn-green" name="accion" value="aprobar" type="submit" onclick="return confirmDel('¿Aprobar y acreditar <?= money($t['amount_cup']) ?> a <?= e($t['uname']) ?>?')"><?= icon('check', 16) ?> Aprobar y acreditar</button>
      <button class="btn btn-red" name="accion" value="rechazar" type="submit" onclick="return confirmDel('¿Rechazar esta recarga?')"><?= icon('x', 16) ?> Rechazar</button>
    </form>
  </div>
  <?php endforeach; ?>
<?php endif; ?>

<h2 style="color:var(--violet-dark);font-size:17px;margin:18px 0 10px">Historial reciente</h2>
<div class="card">
  <?php if (!$hist): ?>
    <div class="empty">Sin historial todavía.</div>
  <?php else: ?>
    <div class="table-wrap"><table class="tbl">
      <tr><th>Fecha</th><th>Usuario</th><th>Monto</th><th>ID transfer.</th><th>Estado</th><th>Nota</th></tr>
      <?php foreach ($hist as $t): ?>
      <tr>
        <td class="muted" style="white-space:nowrap"><?= e(fdate($t['created_at'])) ?></td>
        <td><?= e($t['uname'] ?? '—') ?></td>
        <td><b><?= money($t['amount_cup']) ?></b></td>
        <td class="help"><?= e($t['transfer_id']) ?></td>
        <td><span class="state st-<?= e($t['status']) ?>"><?= e(ucfirst($t['status'])) ?></span></td>
        <td class="help"><?= e($t['admin_note'] ?? '') ?></td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  <?php endif; ?>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
