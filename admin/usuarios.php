<?php
/** Admin: usuarios (roles, bloqueo, saldo). */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Usuarios — Administración';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $uid = (int)($_POST['user_id'] ?? 0);
    $accion = $_POST['accion'] ?? '';
    if ($uid === (int)$admin['id'] && in_array($accion, ['bloquear', 'desbloquear', 'hacer_vendedor', 'hacer_cliente'])) {
        flash('No puedes cambiar tu propia cuenta desde aquí.', 'err');
        redirect('usuarios.php');
    }
    $st = db()->prepare('SELECT * FROM users WHERE id = ?');
    $st->execute([$uid]);
    $us = $st->fetch();
    if ($us) {
        if ($accion === 'bloquear') {
            db()->prepare('UPDATE users SET locked_until = ? WHERE id = ?')->execute([date('Y-m-d H:i:s', time() + 30 * 86400), $uid]);
            db()->prepare('DELETE FROM user_sessions WHERE user_id = ?')->execute([$uid]);
            notify($uid, 'Cuenta bloqueada', 'Tu cuenta fue bloqueada por el administrador. Contáctalo para resolverlo.', 'cuenta.php');
            flash('Cuenta de ' . $us['name'] . ' bloqueada 30 días y sus sesiones cerradas.', 'ok');
        }
        if ($accion === 'desbloquear') {
            db()->prepare('UPDATE users SET locked_until = NULL, failed_attempts = 0 WHERE id = ?')->execute([$uid]);
            flash('Cuenta de ' . $us['name'] . ' desbloqueada.', 'ok');
        }
        if ($accion === 'hacer_admin') {
            db()->prepare("UPDATE users SET role = 'admin' WHERE id = ?")->execute([$uid]);
            flash($us['name'] . ' ahora es administrador.', 'ok');
        }
        if ($accion === 'hacer_vendedor') {
            db()->prepare("UPDATE users SET role = 'seller' WHERE id = ?")->execute([$uid]);
            flash($us['name'] . ' ahora es vendedor.', 'ok');
        }
        if ($accion === 'hacer_cliente') {
            db()->prepare("UPDATE users SET role = 'customer' WHERE id = ?")->execute([$uid]);
            flash($us['name'] . ' ahora es cliente.', 'ok');
        }
        if ($accion === 'saldo') {
            $delta = (int)($_POST['delta'] ?? 0);
            db()->prepare('UPDATE users SET balance_cup = MAX(0, balance_cup + ?) WHERE id = ?')->execute([$delta, $uid]);
            notify($uid, 'Ajuste de saldo', ($delta >= 0 ? 'Se acreditaron ' : 'Se descontaron ') . money(abs($delta)) . ' de tu billetera por el administrador.', 'wallet.php');
            flash('Saldo de ' . $us['name'] . ' ajustado en ' . money($delta) . '.', 'ok');
        }
        sec_log('admin_usuario', 'Usuario ' . $us['name'] . ': ' . $accion . (isset($delta) ? ' (' . $delta . ')' : ''), (int)$admin['id']);
    }
    redirect('usuarios.php');
}

$q = trim($_GET['q'] ?? '');
if ($q !== '') {
    $st = db()->prepare('SELECT * FROM users WHERE name LIKE ? OR email LIKE ? OR phone LIKE ? ORDER BY id DESC LIMIT 100');
    $st->execute(['%' . $q . '%', '%' . $q . '%', '%' . $q . '%']);
    $users = $st->fetchAll();
} else {
    $users = db()->query('SELECT * FROM users ORDER BY id DESC LIMIT 100')->fetchAll();
}
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('users', 26) ?> Usuarios</h1>

<form method="get" class="row mb">
  <input class="input" style="max-width:340px" name="q" placeholder="Buscar por nombre, correo o teléfono…" value="<?= e($q) ?>">
  <button class="btn btn-violet btn-sm" type="submit">Buscar</button>
  <?php if ($q !== ''): ?><a class="btn btn-outline btn-sm" href="usuarios.php">Ver todos</a><?php endif; ?>
</form>

<div class="card">
  <div class="table-wrap"><table class="tbl">
    <tr><th>Usuario</th><th>Correo</th><th>Teléfono</th><th>Rol</th><th>Saldo</th><th>Estado</th><th>Acciones</th></tr>
    <?php foreach ($users as $us): $bloqueado = !empty($us['locked_until']) && strtotime($us['locked_until']) > time(); ?>
    <tr>
      <td><b><?= e($us['name']) ?></b><br><span class="help">#<?= (int)$us['id'] ?> · desde <?= e(fdate($us['created_at'])) ?></span></td>
      <td><?= e($us['email'] ?? '—') ?></td>
      <td><?= e($us['phone'] ?? '—') ?></td>
      <td>
        <?php if ($us['role'] === 'admin'): ?><span class="badge b-off">Admin</span>
        <?php elseif ($us['role'] === 'seller'): ?><span class="badge b-info">Vendedor</span>
        <?php else: ?><span class="badge b-agotado">Cliente</span><?php endif; ?>
      </td>
      <td><b><?= money($us['balance_cup']) ?></b></td>
      <td><?= $bloqueado ? '<span class="badge b-warn">Bloqueado</span>' : '<span class="badge b-ok">Activo</span>' ?></td>
      <td>
        <div class="row" style="gap:6px">
          <?php if ($us['id'] !== $admin['id']): ?>
            <form method="post" class="row" style="gap:4px"><?= csrf_field() ?>
              <input type="hidden" name="user_id" value="<?= (int)$us['id'] ?>">
              <input type="hidden" name="accion" value="saldo">
              <input class="input" style="width:74px;padding:6px" type="number" name="delta" value="0" step="50">
              <button class="btn btn-outline btn-sm" type="submit">Saldo ±</button>
            </form>
            <?php if ($bloqueado): ?>
              <form method="post"><?= csrf_field() ?>
                <input type="hidden" name="user_id" value="<?= (int)$us['id'] ?>">
                <button class="btn btn-green btn-sm" name="accion" value="desbloquear" type="submit">Desbloquear</button>
              </form>
            <?php else: ?>
              <form method="post" onsubmit="return confirmDel('¿Bloquear esta cuenta por 30 días?')"><?= csrf_field() ?>
                <input type="hidden" name="user_id" value="<?= (int)$us['id'] ?>">
                <button class="btn btn-red btn-sm" name="accion" value="bloquear" type="submit">Bloquear</button>
              </form>
            <?php endif; ?>
            <?php if ($us['role'] !== 'admin'): ?>
              <form method="post"><?= csrf_field() ?>
                <input type="hidden" name="user_id" value="<?= (int)$us['id'] ?>">
                <button class="btn btn-outline btn-sm" name="accion" value="<?= $us['role'] === 'seller' ? 'hacer_cliente' : 'hacer_vendedor' ?>" type="submit"><?= $us['role'] === 'seller' ? 'Hacer cliente' : 'Hacer vendedor' ?></button>
              </form>
            <?php endif; ?>
          <?php else: ?>
            <span class="help">Tu cuenta</span>
          <?php endif; ?>
        </div>
      </td>
    </tr>
    <?php endforeach; ?>
  </table></div>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
