<?php
/** Admin: gestión de mini tiendas (suscripción, estado). */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Mini Tiendas — Administración';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $sid = (int)($_POST['store_id'] ?? 0);
    $accion = $_POST['accion'] ?? '';
    $st = db()->prepare('SELECT s.*, u.name AS owner FROM stores s LEFT JOIN users u ON u.id = s.owner_id WHERE s.id = ?');
    $st->execute([$sid]);
    $s = $st->fetch();
    if ($s) {
        if ($accion === 'activar') {
            // Regala 30 días de suscripción (cortesía del administrador)
            $base = !empty($s['subscription_until']) && strtotime($s['subscription_until']) > time() ? strtotime($s['subscription_until']) : time();
            $until = date('Y-m-d', $base + 30 * 86400);
            db()->prepare('UPDATE stores SET subscription_until = ? WHERE id = ?')->execute([$until, $sid]);
            notify((int)$s['owner_id'], 'Suscripción activada por el administrador', 'Tu tienda «' . $s['name'] . '» tiene la suscripción al día hasta el ' . $until . '.', 'vender.php');
            flash('Suscripción de «' . $s['name'] . '» activada hasta el ' . $until . '.', 'ok');
        }
        if ($accion === 'cancelar') {
            db()->prepare('UPDATE stores SET subscription_until = NULL WHERE id = ?')->execute([$sid]);
            flash('Suscripción de «' . $s['name'] . '» cancelada.', 'ok');
        }
        if ($accion === 'extender_prueba') {
            $until = date('Y-m-d', time() + (int)($_POST['days'] ?? 5) * 86400);
            db()->prepare('UPDATE stores SET trial_until = ? WHERE id = ?')->execute([$until, $sid]);
            notify((int)$s['owner_id'], 'Prueba extendida', 'El administrador extendió tu prueba gratis hasta el ' . $until . '.', 'vender.php');
            flash('Prueba de «' . $s['name'] . '» extendida hasta el ' . $until . '.', 'ok');
        }
        sec_log('admin_tienda', 'Tienda ' . $s['name'] . ': ' . $accion, (int)$admin['id']);
    }
    redirect('tiendas.php');
}

$stores = db()->query('SELECT s.*, u.name AS owner, (SELECT COUNT(*) FROM products p WHERE p.store_id = s.id) AS nprod FROM stores s LEFT JOIN users u ON u.id = s.owner_id ORDER BY s.id DESC')->fetchAll();
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('store', 26) ?> Mini tiendas</h1>
<p class="muted mb">Prueba gratis: <?= TRIAL_DAYS ?> días · Suscripción: <?= money(SUBSCRIPTION_CUP) ?>/mes (<?= SUBSCRIPTION_DAYS ?> días)</p>

<?php if (!$stores): ?>
  <div class="card empty">Todavía no hay mini tiendas.</div>
<?php else: ?>
  <div class="card">
    <div class="table-wrap"><table class="tbl">
      <tr><th>Tienda</th><th>Dueño</th><th>Productos</th><th>Prueba hasta</th><th>Suscripción</th><th>Estado</th><th>Acciones</th></tr>
      <?php foreach ($stores as $s): $estado = store_status($s); ?>
      <tr>
        <td><a href="../tienda.php?id=<?= (int)$s['id'] ?>"><b><?= e($s['name']) ?></b></a></td>
        <td><?= e($s['owner'] ?? '—') ?></td>
        <td><?= (int)$s['nprod'] ?></td>
        <td style="white-space:nowrap"><?= e($s['trial_until'] ?: '—') ?></td>
        <td style="white-space:nowrap"><?= e($s['subscription_until'] ?: '—') ?></td>
        <td><span class="badge <?= $estado === 'activa' ? 'b-ok' : ($estado === 'prueba' ? 'b-info' : 'b-warn') ?>"><?= $estado === 'activa' ? 'Al día' : ($estado === 'prueba' ? 'En prueba' : 'Suspendida') ?></span></td>
        <td>
          <div class="row" style="gap:6px">
            <form method="post"><?= csrf_field() ?>
              <input type="hidden" name="store_id" value="<?= (int)$s['id'] ?>">
              <button class="btn btn-green btn-sm" name="accion" value="activar" type="submit">Activar 30 días</button>
            </form>
            <form method="post" class="row" style="gap:4px"><?= csrf_field() ?>
              <input type="hidden" name="store_id" value="<?= (int)$s['id'] ?>">
              <input class="input" style="width:56px;padding:6px" type="number" name="days" value="5" min="1">
              <button class="btn btn-outline btn-sm" name="accion" value="extender_prueba" type="submit">+Prueba</button>
            </form>
            <?php if ($estado === 'activa'): ?>
              <form method="post" onsubmit="return confirmDel('¿Cancelar la suscripción de esta tienda?')"><?= csrf_field() ?>
                <input type="hidden" name="store_id" value="<?= (int)$s['id'] ?>">
                <button class="btn btn-red btn-sm" name="accion" value="cancelar" type="submit">Cancelar</button>
              </form>
            <?php endif; ?>
          </div>
        </td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/admin-footer.php'; ?>
