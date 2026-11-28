<?php
/**
 * Panel de administración de inversiones.
 *
 * El admin puede:
 *  - Ver la cola de inversiones solicitadas (que no tienen admin asignado o que le asignaron a él).
 *  - Aceptar una inversión (la "bloquea": accepted_admin_id = él, status = aceptada).
 *    Al aceptar, le llegan al usuario los datos bancarios del admin.
 *  - Validar el código de transferencia que subió el usuario: aprobar (acredita saldo) o rechazar.
 *  - Ver historial.
 *
 * Regla de exclusividad: cuando un admin acepta una inversión, desaparece de la cola de los demás.
 */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Inversiones — ' . SITE_NAME;
$tab = 'inversiones';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    /* ---------- Aceptar inversión (bloqueo exclusivo) ---------- */
    if ($accion === 'aceptar') {
        $invId = (int)($_POST['inv_id'] ?? 0);
        $st = db()->prepare('SELECT * FROM investments WHERE id = ?');
        $st->execute([$invId]);
        $inv = $st->fetch();
        if (!$inv) { flash('Esa inversión no existe.', 'err'); }
        elseif ($inv['status'] !== 'solicitada') { flash('Esa inversión ya fue tomada o procesada.', 'err'); }
        elseif ($inv['target_admin_id'] && (int)$inv['target_admin_id'] !== (int)$admin['id']) { flash('El usuario eligió a otro administrador para esta inversión.', 'err'); }
        else {
            // Verifica que el admin tenga al menos una cuenta bancaria activa
            $st = db()->prepare('SELECT id FROM admin_bank_accounts WHERE admin_id = ? AND is_active = 1 LIMIT 1');
            $st->execute([$admin['id']]);
            if (!$st->fetch()) {
                flash('No tienes cuentas bancarias activas. Añádelas en «Mis datos bancarios».', 'err');
                redirect('mis-bancos.php');
            }
            // Bloqueo atómico: solo actualiza si sigue en 'solicitada' (evita carrera entre admins)
            $st = db()->prepare("UPDATE investments SET status = 'aceptada', accepted_admin_id = ?, accepted_at = ? WHERE id = ? AND status = 'solicitada'");
            $st->execute([$admin['id'], date('Y-m-d H:i:s'), $invId]);
            if ($st->rowCount() > 0) {
                // Aviso al usuario con los datos del admin
                notify((int)$inv['user_id'], 'Tu inversión fue aceptada', 'El administrador ' . $admin['name'] . ' aceptó tu inversión ' . $inv['code'] . ' de ' . money($inv['amount_cup']) . '. Entra a «Invertir» para ver sus datos bancarios, transfiere y sube el código de transferencia.', 'invertir.php?id=' . $invId);
                sec_log('inversion_aceptada', 'Inversión ' . $inv['code'] . ' aceptada', (int)$admin['id']);
                flash('Inversión aceptada. El usuario recibió tus datos bancarios y debe transferir ahora.', 'ok');
            } else {
                flash('Otro administrador aceptó esta inversión justo antes que tú.', 'err');
            }
        }
        redirect('inversiones.php');
    }

    /* ---------- Aprobar (validar código → acreditar saldo) ---------- */
    if ($accion === 'aprobar') {
        $invId = (int)($_POST['inv_id'] ?? 0);
        $note = mb_substr(trim($_POST['admin_note'] ?? ''), 0, 300);
        $st = db()->prepare('SELECT * FROM investments WHERE id = ?');
        $st->execute([$invId]);
        $inv = $st->fetch();
        if (!$inv) { flash('Esa inversión no existe.', 'err'); }
        elseif ((int)$inv['accepted_admin_id'] !== (int)$admin['id']) { flash('Esta inversión la gestiona otro administrador.', 'err'); }
        elseif (!in_array($inv['status'], ['transferida', 'aceptada'], true)) { flash('Esta inversión no se puede aprobar en su estado actual.', 'err'); }
        else {
            db()->beginTransaction();
            try {
                db()->prepare("UPDATE investments SET status = 'aprobada', admin_note = ?, processed_at = ? WHERE id = ?")
                    ->execute([$note, date('Y-m-d H:i:s'), $invId]);
                // Acredita el saldo al usuario
                db()->prepare('UPDATE users SET balance_cup = balance_cup + ? WHERE id = ?')->execute([(int)$inv['amount_cup'], (int)$inv['user_id']]);
                db()->commit();
            } catch (Throwable $e) {
                db()->rollBack();
                throw $e;
            }
            notify((int)$inv['user_id'], '¡Inversión aprobada!', 'Tu inversión ' . $inv['code'] . ' de ' . money($inv['amount_cup']) . ' fue aprobada. El saldo ya está en tu billetera.' . ($note ? ' Nota: ' . $note : ''), 'wallet.php');
            sec_log('inversion_aprobada', 'Inversión ' . $inv['code'] . ' acreditada ' . money($inv['amount_cup']), (int)$admin['id']);
            flash('Inversión aprobada. Se acreditó ' . money($inv['amount_cup']) . ' al usuario.', 'ok');
        }
        redirect('inversiones.php');
    }

    /* ---------- Rechazar (código inválido, etc.) ---------- */
    if ($accion === 'rechazar') {
        $invId = (int)($_POST['inv_id'] ?? 0);
        $note = mb_substr(trim($_POST['admin_note'] ?? ''), 0, 300);
        $st = db()->prepare('SELECT * FROM investments WHERE id = ?');
        $st->execute([$invId]);
        $inv = $st->fetch();
        if (!$inv) { flash('Esa inversión no existe.', 'err'); }
        elseif ((int)$inv['accepted_admin_id'] !== (int)$admin['id']) { flash('Esta inversión la gestiona otro administrador.', 'err'); }
        elseif (!in_array($inv['status'], ['transferida', 'aceptada', 'solicitada'], true)) { flash('Esta inversión no se puede rechazar en su estado actual.', 'err'); }
        else {
            db()->prepare("UPDATE investments SET status = 'rechazada', admin_note = ?, processed_at = ? WHERE id = ?")
                ->execute([$note, date('Y-m-d H:i:s'), $invId]);
            notify((int)$inv['user_id'], 'Inversión rechazada', 'Tu inversión ' . $inv['code'] . ' fue rechazada' . ($note ? ': ' . $note : '. Si crees que fue un error, vuelve a solicitarla.') , 'invertir.php?id=' . $invId);
            sec_log('inversion_rechazada', 'Inversión ' . $inv['code'] . ($note ? ': ' . $note : ''), (int)$admin['id']);
            flash('Inversión rechazada. Se le avisó al usuario.', 'ok');
        }
        redirect('inversiones.php');
    }

    /* ---------- Soltar (el admin decide no continuar) ---------- */
    if ($accion === 'soltar') {
        $invId = (int)($_POST['inv_id'] ?? 0);
        $st = db()->prepare('SELECT * FROM investments WHERE id = ?');
        $st->execute([$invId]);
        $inv = $st->fetch();
        if (!$inv) { flash('Esa inversión no existe.', 'err'); }
        elseif ((int)$inv['accepted_admin_id'] !== (int)$admin['id']) { flash('Esta inversión la gestiona otro administrador.', 'err'); }
        elseif ($inv['status'] !== 'aceptada') { flash('Solo puedes soltar inversiones que estén en espera de transferencia.', 'err'); }
        else {
            // Vuelve a 'solicitada' para que otro admin pueda tomarla
            db()->prepare("UPDATE investments SET status = 'solicitada', accepted_admin_id = NULL, accepted_at = NULL WHERE id = ?")->execute([$invId]);
            notify((int)$inv['user_id'], 'Inversión disponible de nuevo', 'El administrador liberó tu inversión ' . $inv['code'] . '. Otro administrador la tomará pronto.', 'invertir.php?id=' . $invId);
            // Reavisa a los demás admins
            foreach (db()->query("SELECT id FROM users WHERE role = 'admin' AND id != " . (int)$admin['id'])->fetchAll() as $a) {
                notify((int)$a['id'], 'Inversión disponible', 'La inversión ' . $inv['code'] . ' de ' . money($inv['amount_cup']) . ' está disponible de nuevo.', 'inversiones.php');
            }
            flash('Inversión liberada. Otro administrador podrá tomarla.', 'ok');
        }
        redirect('inversiones.php');
    }
}

// Cola de inversiones que este admin puede ver:
//  - Todas las 'solicitada' (sin admin asignado, o asignadas a él)
//  - Las que él tiene en gestión (aceptada, transferida)
$filtro = $_GET['filtro'] ?? 'cola';
if ($filtro === 'cola') {
    $st = db()->prepare("SELECT i.*, u.name AS user_name, u.phone AS user_phone, u.email AS user_email
                         FROM investments i JOIN users u ON u.id = i.user_id
                         WHERE i.status = 'solicitada' AND (i.target_admin_id IS NULL OR i.target_admin_id = ?)
                         ORDER BY (i.target_admin_id = ?) DESC, i.id ASC LIMIT 100");
    $st->execute([$admin['id'], $admin['id']]);
    $cola = $st->fetchAll();
} else {
    $cola = [];
}

// Mis inversiones en gestión
$st = db()->prepare("SELECT i.*, u.name AS user_name, u.phone AS user_phone
                     FROM investments i JOIN users u ON u.id = i.user_id
                     WHERE i.accepted_admin_id = ? AND i.status IN ('aceptada','transferida')
                     ORDER BY i.id ASC");
$st->execute([$admin['id']]);
$enGestion = $st->fetchAll();

// Historial (aprobadas/rechazadas/canceladas)
$st = db()->prepare("SELECT i.*, u.name AS user_name FROM investments i JOIN users u ON u.id = i.user_id WHERE i.accepted_admin_id = ? AND i.status IN ('aprobada','rechazada','cancelada') ORDER BY i.id DESC LIMIT 50");
$st->execute([$admin['id']]);
$historial = $st->fetchAll();

$estadosInv = [
    'solicitada' => 'b-info', 'aceptada' => 'b-ok', 'transferida' => 'b-info',
    'aprobada' => 'b-ok', 'rechazada' => 'b-warn', 'cancelada' => 'b-warn',
];

include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('trending-up', 26) ?> Inversiones</h1>
<p class="muted mb">Gestiona las solicitudes de inversión de los usuarios.</p>

<div class="pill-tabs mb">
  <a href="inversiones.php?filtro=cola" class="<?= $filtro === 'cola' ? 'on' : '' ?>">Cola (<?= count($cola) ?>)</a>
  <a href="inversiones.php?filtro=gestion" class="<?= $filtro === 'gestion' ? 'on' : '' ?>">En mi gestión (<?= count($enGestion) ?>)</a>
  <a href="inversiones.php?filtro=historial" class="<?= $filtro === 'historial' ? 'on' : '' ?>">Historial (<?= count($historial) ?>)</a>
</div>

<?php if ($filtro === 'cola'): ?>
  <?php if (!$cola): ?>
    <div class="card empty">No hay inversiones esperando. Cuando un usuario solicite una, recibirás una notificación.</div>
  <?php else: ?>
    <div class="table-wrap"><table class="tbl">
      <tr><th>Código</th><th>Usuario</th><th>Monto</th><th>Destinatario</th><th>Solicitada</th><th></th></tr>
      <?php foreach ($cola as $i): ?>
      <tr>
        <td><b><?= e($i['code']) ?></b></td>
        <td><?= e($i['user_name']) ?><br><span class="help">📞 <?= e($i['user_phone']) ?> · <?= e($i['user_email'] ?: '') ?></span></td>
        <td><b><?= money($i['amount_cup']) ?></b></td>
        <td><?= $i['target_admin_id'] ? ('A ti (elegido)') : 'Cualquier admin' ?></td>
        <td class="muted"><?= e(fdate($i['created_at'])) ?></td>
        <td>
          <form method="post"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="aceptar">
            <input type="hidden" name="inv_id" value="<?= (int)$i['id'] ?>">
            <button class="btn btn-violet btn-sm" type="submit" onclick="return confirmDel('¿Aceptar esta inversión? Se te asignará y el usuario recibirá tus datos bancarios.')"><?= icon('check', 14) ?> Aceptar</button>
          </form>
        </td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  <?php endif; ?>

<?php elseif ($filtro === 'gestion'): ?>
  <?php if (!$enGestion): ?>
    <div class="card empty">No tienes inversiones en gestión. Acepta alguna de la cola.</div>
  <?php else: foreach ($enGestion as $i): ?>
    <div class="card mb">
      <div class="row-between">
        <div>
          <b style="font-size:16px"><?= e($i['code']) ?></b>
          <span class="badge <?= $estadosInv[$i['status']] ?? 'b-warn' ?>"><?= ucfirst($i['status']) ?></span>
          <div class="help"><?= e($i['user_name']) ?> · 📞 <?= e($i['user_phone']) ?> · <?= money($i['amount_cup']) ?> · <?= e(fdate($i['created_at'])) ?></div>
        </div>
      </div>
      <?php if ($i['transfer_id']): ?>
        <div class="row mt"><b>Código de transferencia del usuario:</b><span class="badge b-ok"><?= e($i['transfer_id']) ?></span></div>
        <p class="help">Valida este código en tu banco. Si coincide con una transferencia recibida, aprueba. Si no, rechaza.</p>
      <?php else: ?>
        <p class="help mt">Esperando que el usuario suba el código de transferencia. Mientras, puedes soltarla para que otro admin la tome.</p>
      <?php endif; ?>

      <?php if ($i['status'] === 'transferida'): ?>
        <form method="post" class="form mt"><?= csrf_field() ?>
          <input type="hidden" name="inv_id" value="<?= (int)$i['id'] ?>">
          <div><label class="f">Nota (opcional)</label>
            <input class="input" name="admin_note" placeholder="Ej: Transferencia confirmada en BPA"></div>
          <div class="row" style="gap:8px">
            <button class="btn btn-violet" type="submit" name="accion" value="aprobar" onclick="return confirmDel('¿Aprobar y acreditar <?= money($i['amount_cup']) ?> al usuario?')"><?= icon('check', 16) ?> Aprobar y acreditar</button>
            <button class="btn btn-red" type="submit" name="accion" value="rechazar" onclick="return confirmDel('¿Rechazar esta inversión?')"><?= icon('x', 16) ?> Rechazar</button>
          </div>
        </form>
      <?php endif; ?>

      <?php if ($i['status'] === 'aceptada'): ?>
        <form method="post" class="mt"><?= csrf_field() ?>
          <input type="hidden" name="accion" value="soltar">
          <input type="hidden" name="inv_id" value="<?= (int)$i['id'] ?>">
          <button class="btn btn-outline btn-sm" type="submit"><?= icon('x', 14) ?> Soltar (otro admin la tomará)</button>
        </form>
      <?php endif; ?>
    </div>
  <?php endforeach; endif; ?>

<?php else: // historial ?>
  <?php if (!$historial): ?>
    <div class="card empty">Sin historial todavía.</div>
  <?php else: ?>
    <div class="table-wrap"><table class="tbl">
      <tr><th>Código</th><th>Usuario</th><th>Monto</th><th>Estado</th><th>Nota</th><th>Procesada</th></tr>
      <?php foreach ($historial as $i): ?>
      <tr>
        <td><b><?= e($i['code']) ?></b></td>
        <td><?= e($i['user_name']) ?></td>
        <td><?= money($i['amount_cup']) ?></td>
        <td><span class="badge <?= $estadosInv[$i['status']] ?? 'b-warn' ?>"><?= ucfirst($i['status']) ?></span></td>
        <td class="help"><?= e($i['admin_note'] ?: '—') ?></td>
        <td class="muted"><?= e(fdate($i['processed_at'])) ?></td>
      </tr>
      <?php endforeach; ?>
    </table></div>
  <?php endif; ?>
<?php endif; ?>

<?php include __DIR__ . '/admin-footer.php'; ?>
