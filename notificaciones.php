<?php
/** Notificaciones internas del usuario. */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('notificaciones.php');
$page_title = 'Notificaciones — ' . SITE_NAME;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (($_POST['accion'] ?? '') === 'marcar_todas') {
        db()->prepare('UPDATE notifications SET is_read = 1 WHERE user_id = ?')->execute([$u['id']]);
        flash('Notificaciones marcadas como leídas.', 'ok');
    }
    if (($_POST['accion'] ?? '') === 'borrar_todas') {
        db()->prepare('DELETE FROM notifications WHERE user_id = ?')->execute([$u['id']]);
        flash('Bandeja de notificaciones vaciada.', 'ok');
    }
    redirect('notificaciones.php');
}

$st = db()->prepare('SELECT * FROM notifications WHERE user_id = ? ORDER BY id DESC LIMIT 100');
$st->execute([$u['id']]);
$notifs = $st->fetchAll();
include __DIR__ . '/includes/header.php';
?>
<div class="row-between mb">
  <h1 style="color:var(--violet-dark)">🔔 Notificaciones</h1>
  <form method="post" class="row"><?= csrf_field() ?>
    <button class="btn btn-outline btn-sm" name="accion" value="marcar_todas">Marcar todas como leídas</button>
    <button class="btn btn-red btn-sm" name="accion" value="borrar_todas" onclick="return confirmDel('¿Vaciar toda la bandeja?')">Vaciar</button>
  </form>
</div>

<?php if (!$notifs): ?>
  <div class="card empty"><div class="big">🔔</div>No tienes notificaciones todavía. Aquí verás avisos de tus pedidos, ventas y recargas.</div>
<?php else: ?>
  <?php foreach ($notifs as $n): ?>
    <div class="notif <?= (int)$n['is_read'] === 0 ? 'unread' : '' ?>">
      <div class="row-between">
        <div>
          <div class="t"><?= e($n['title']) ?></div>
          <div><?= e($n['body']) ?></div>
        </div>
        <div class="d" style="white-space:nowrap"><?= e(fdate($n['created_at'])) ?></div>
      </div>
      <?php if ($n['link']): ?><div class="mt"><a class="btn btn-outline btn-sm" href="<?= e($n['link']) ?>">Abrir →</a></div><?php endif; ?>
    </div>
  <?php endforeach; ?>
  <?php db()->prepare('UPDATE notifications SET is_read = 1 WHERE user_id = ?')->execute([$u['id']]); ?>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
