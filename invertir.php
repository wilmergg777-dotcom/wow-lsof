<?php
/**
 * ============================================================
 * INVERSIONES
 * ============================================================
 * Flujo:
 *  1. El usuario solicita una inversión (monto). Opcionalmente elige a qué admin
 *     transferir (de los admins con cuentas bancarias activas).
 *  2. Se notifica a TODOS los admins. El primero que la acepta la "bloquea"
 *     (accepted_admin_id), y a los demás les desaparece de su cola.
 *  3. Al usuario le llegan los datos bancarios del admin que aceptó.
 *  4. El usuario hace la transferencia bancaria y registra el código de transferencia.
 *  5. El admin valida el código: si coincide con su banco, aprueba; si no, cancela.
 *
 * Estados de una inversión:
 *  - solicitada   : recién pedida, esperando que un admin la acepte
 *  - aceptada      : un admin la tomó, esperando que el usuario transfiera y suba el código
 *  - transferida   : el usuario subió el código, esperando validación del admin
 *  - aprobada      : el admin validó el código → se acredita el saldo al usuario
 *  - rechazada     : el admin canceló (código inválido, etc.)
 *  - cancelada     : el usuario la canceló antes de transferir
 * ============================================================
 */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('invertir.php');
$page_title = 'Invertir — ' . SITE_NAME;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    /* ---------- Solicitar inversión ---------- */
    if ($accion === 'solicitar') {
        if (!rate_limit('inversion', 5, 600)) { flash('Espera unos minutos antes de otra solicitud.', 'err'); redirect('invertir.php'); }
        $amount = (int)($_POST['amount'] ?? 0);
        $targetAdmin = (int)($_POST['target_admin'] ?? 0);
        $note = mb_substr(trim($_POST['note'] ?? ''), 0, 300);

        if ($amount < 500) { flash('La inversión mínima es 500 CUP.', 'err'); redirect('invertir.php'); }
        if ($amount > 1000000) { flash('La inversión máxima es 1 000 000 CUP.', 'err'); redirect('invertir.php'); }

        // Valida que el admin destino exista y tenga al menos una cuenta activa
        $targetOk = false;
        if ($targetAdmin > 0) {
            $st = db()->prepare("SELECT u.id FROM users u WHERE u.id = ? AND u.role = 'admin'");
            $st->execute([$targetAdmin]);
            if ($st->fetch()) {
                $st = db()->prepare('SELECT id FROM admin_bank_accounts WHERE admin_id = ? AND is_active = 1 LIMIT 1');
                $st->execute([$targetAdmin]);
                $targetOk = (bool)$st->fetch();
            }
        }

        $code = 'INV-' . strtoupper(bin2hex(random_bytes(3)));
        db()->prepare('INSERT INTO investments (code, user_id, amount_cup, target_admin_id, status, created_at) VALUES (?,?,?,?,?,?)')
            ->execute([$code, $u['id'], $amount, $targetOk ? $targetAdmin : null, 'solicitada', date('Y-m-d H:i:s')]);
        $invId = (int)db()->lastInsertId();

        // Avisa a todos los admins
        $admins = db()->query("SELECT id, name FROM users WHERE role = 'admin'")->fetchAll();
        foreach ($admins as $adm) {
            notify((int)$adm['id'], 'Nueva solicitud de inversión', $u['name'] . ' solicita invertir ' . money($amount) . ($targetOk && (int)$adm['id'] === $targetAdmin ? ' y te eligió como destinatario' : '') . '. Entra al panel de inversiones para aceptarla.', 'admin/inversiones.php');
        }
        sec_log('inversion_solicitada', 'Inversión ' . $code . ' por ' . money($amount), (int)$u['id']);
        flash('Solicitud de inversión enviada. Te avisaremos cuando un administrador la acepte y te envíe sus datos bancarios.', 'ok');
        redirect('invertir.php?id=' . $invId);
    }

    /* ---------- Subir código de transferencia ---------- */
    if ($accion === 'subir_transfer') {
        $invId = (int)($_POST['inv_id'] ?? 0);
        $transferId = trim($_POST['transfer_id'] ?? '');
        $st = db()->prepare('SELECT * FROM investments WHERE id = ? AND user_id = ?');
        $st->execute([$invId, $u['id']]);
        $inv = $st->fetch();
        if (!$inv) { flash('Esa inversión no existe.', 'err'); redirect('invertir.php'); }
        if ($inv['status'] !== 'aceptada') { flash('Esta inversión no está lista para recibir la transferencia.', 'err'); redirect('invertir.php?id=' . $invId); }
        if (mb_strlen($transferId) < 4) { flash('Escribe el código de transferencia (mínimo 4 caracteres).', 'err'); redirect('invertir.php?id=' . $invId); }

        db()->prepare('UPDATE investments SET transfer_id = ?, status = "transferida" WHERE id = ?')->execute([$transferId, $invId]);
        notify((int)$inv['accepted_admin_id'], 'Código de transferencia recibido', $u['name'] . ' subió el código "' . $transferId . '" para la inversión ' . $inv['code'] . '. Revísalo en tu banco y aprueba o rechaza.', 'admin/inversiones.php');
        sec_log('inversion_transferida', 'Inversión ' . $inv['code'] . ' código ' . $transferId, (int)$u['id']);
        flash('Código de transferencia enviado. El administrador lo validará con su banco.', 'ok');
        redirect('invertir.php?id=' . $invId);
    }

    /* ---------- Cancelar inversión ---------- */
    if ($accion === 'cancelar') {
        $invId = (int)($_POST['inv_id'] ?? 0);
        $st = db()->prepare('SELECT * FROM investments WHERE id = ? AND user_id = ?');
        $st->execute([$invId, $u['id']]);
        $inv = $st->fetch();
        if (!$inv) { flash('Esa inversión no existe.', 'err'); redirect('invertir.php'); }
        if (!in_array($inv['status'], ['solicitada', 'aceptada'], true)) { flash('Esta inversión ya no se puede cancelar.', 'err'); redirect('invertir.php?id=' . $invId); }

        db()->prepare('UPDATE investments SET status = "cancelada", processed_at = ? WHERE id = ?')->execute([date('Y-m-d H:i:s'), $invId]);
        if ($inv['accepted_admin_id']) {
            notify((int)$inv['accepted_admin_id'], 'Inversión cancelada por el usuario', $u['name'] . ' canceló la inversión ' . $inv['code'] . ' antes de completarla.', 'admin/inversiones.php');
        }
        sec_log('inversion_cancelada', 'Inversión ' . $inv['code'], (int)$u['id']);
        flash('Inversión cancelada.', 'ok');
        redirect('invertir.php');
    }
}

// ¿Viene a ver una inversión específica?
$verInv = null;
if (isset($_GET['id'])) {
    $st = db()->prepare('SELECT * FROM investments WHERE id = ? AND user_id = ?');
    $st->execute([(int)$_GET['id'], $u['id']]);
    $verInv = $st->fetch();
}

// Lista de admins con cuentas bancarias activas (para que el usuario elija)
$st = db()->query("SELECT u.id, u.name, COUNT(b.id) AS n_cuentas
                   FROM users u LEFT JOIN admin_bank_accounts b ON b.admin_id = u.id AND b.is_active = 1
                   WHERE u.role = 'admin' GROUP BY u.id HAVING n_cuentas > 0 ORDER BY u.name");
$adminsConBanco = $st->fetchAll();

// Historial de inversiones del usuario
$st = db()->prepare('SELECT i.*, u.name AS admin_name FROM investments i LEFT JOIN users u ON u.id = i.accepted_admin_id WHERE i.user_id = ? ORDER BY i.id DESC LIMIT 50');
$st->execute([$u['id']]);
$historial = $st->fetchAll();

// Mapa de estados para badges (compartido entre el detalle y el historial)
$estadosInv = [
    'solicitada' => ['b-info', 'Esperando que un administrador acepte'],
    'aceptada' => ['b-ok', 'Aceptada — te toca transferir'],
    'transferida' => ['b-info', 'Código enviado — esperando validación'],
    'aprobada' => ['b-ok', 'Aprobada — saldo acreditado'],
    'rechazada' => ['b-warn', 'Rechazada por el administrador'],
    'cancelada' => ['b-warn', 'Cancelada'],
];

// Si está viendo una inversión aceptada, cargar los datos bancarios del admin
$adminBancos = [];
if ($verInv && $verInv['accepted_admin_id']) {
    $st = db()->prepare('SELECT * FROM admin_bank_accounts WHERE admin_id = ? AND is_active = 1 ORDER BY id');
    $st->execute([$verInv['accepted_admin_id']]);
    $adminBancos = $st->fetchAll();
}

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('trending-up', 26) ?> Invertir</h1>
<p class="muted mb">Solicita una inversión. Un administrador la aceptará, te enviará sus datos bancarios, transfieres y subes el código de transferencia para que lo valide.</p>

<?php if ($verInv): ?>
  <?php $est = $estadosInv[$verInv['status']] ?? ['b-warn', ucfirst($verInv['status'])]; ?>
  <div class="card" style="max-width:640px">
    <div class="row-between">
      <h2 style="color:var(--violet-dark);font-size:18px"><?= icon('trending-up', 20) ?> Inversión <?= e($verInv['code']) ?></h2>
      <span class="badge <?= $est[0] ?>"><?= ucfirst($verInv['status']) ?></span>
    </div>
    <div class="row"><b>Monto:</b><span style="font-size:18px;font-weight:800;color:var(--violet-dark)"><?= money($verInv['amount_cup']) ?></span></div>
    <div class="row"><b>Solicitada:</b><span class="muted"><?= e(fdate($verInv['created_at'])) ?></span></div>
    <?php if ($verInv['accepted_admin_id']): ?>
      <div class="row"><b>Aceptada por:</b><span><?= e($verInv['admin_name'] ?? 'Administrador') ?></span></div>
    <?php endif; ?>
    <?php if ($verInv['transfer_id']): ?>
      <div class="row"><b>Tu código de transferencia:</b><span class="badge b-ok"><?= e($verInv['transfer_id']) ?></span></div>
    <?php endif; ?>
    <?php if ($verInv['admin_note']): ?>
      <div class="flash flash-info mt">Nota del administrador: <?= e($verInv['admin_note']) ?></div>
    <?php endif; ?>

    <p class="mt" style="font-weight:600"><?= $est[1] ?></p>

    <?php if ($verInv['status'] === 'aceptada' && $adminBancos): ?>
      <div class="paydata mt">
        <h3>Datos bancarios de <?= e($verInv['admin_name'] ?? 'el administrador') ?></h3>
        <p class="help">Transfiere a una de estas cuentas y luego sube el código de transferencia abajo.</p>
        <?php foreach ($adminBancos as $b): ?>
          <div class="row" style="gap:12px;flex-wrap:wrap;border-top:1px dashed var(--violet-border);padding-top:8px;margin-top:8px">
            <div><span class="help">Etiqueta:</span><br><b><?= e($b['label']) ?></b></div>
            <div><span class="help">Banco:</span><br><b><?= e($b['bank_name']) ?></b></div>
            <div><span class="help">Cuenta:</span><br><b><?= e($b['account_number']) ?></b></div>
            <div><span class="help">Titular:</span><br><b><?= e($b['holder']) ?></b></div>
            <?php if ($b['phone']): ?><div><span class="help">Tel:</span><br><b><?= e($b['phone']) ?></b></div><?php endif; ?>
          </div>
        <?php endforeach; ?>
      </div>
      <form method="post" class="form mt"><?= csrf_field() ?>
        <input type="hidden" name="accion" value="subir_transfer">
        <input type="hidden" name="inv_id" value="<?= (int)$verInv['id'] ?>">
        <div><label class="f">Código de transferencia *</label>
          <input class="input" name="transfer_id" required placeholder="Ej: TB 0012345678 (del comprobante del banco)">
          <p class="help">Aparece en el comprobante del banco o de la app de transferencia (Transfermóvil, EnZona…).</p>
        </div>
        <button class="btn btn-violet" type="submit"><?= icon('send', 16) ?> Subir código de transferencia</button>
      </form>
    <?php endif; ?>

    <?php if (in_array($verInv['status'], ['solicitada', 'aceptada'], true)): ?>
      <form method="post" class="mt"><?= csrf_field() ?>
        <input type="hidden" name="accion" value="cancelar">
        <input type="hidden" name="inv_id" value="<?= (int)$verInv['id'] ?>">
        <button class="btn btn-red btn-sm" type="submit" onclick="return confirmDel('¿Cancelar esta inversión?')"><?= icon('x', 14) ?> Cancelar inversión</button>
      </form>
    <?php endif; ?>

    <div class="mt"><a class="btn btn-outline" href="invertir.php"><?= icon('arrow-left', 16) ?> Volver a mis inversiones</a></div>
  </div>

<?php else: ?>
  <div class="grid grid-cols-2 mt">
    <div class="card">
      <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('trending-up', 20) ?> Solicitar inversión</h2>
      <form method="post" class="form">
        <?= csrf_field() ?>
        <input type="hidden" name="accion" value="solicitar">
        <div><label class="f">Monto a invertir (CUP) *</label>
          <input class="input" type="number" name="amount" min="500" step="100" required placeholder="Mínimo 500 CUP"></div>
        <?php if ($adminsConBanco): ?>
          <div><label class="f">Transferir a (opcional)</label>
            <select class="input" name="target_admin">
              <option value="0">Cualquier administrador (el primero que acepte)</option>
              <?php foreach ($adminsConBanco as $a): ?>
                <option value="<?= (int)$a['id'] ?>"><?= e($a['name']) ?> (<?= (int)$a['n_cuentas'] ?> cuenta(s))</option>
              <?php endforeach; ?>
            </select>
            <p class="help">Si eliges un administrador, solo él podrá aceptar tu inversión. Si no eliges, la verán todos.</p>
          </div>
        <?php else: ?>
          <div class="flash flash-warn">Todavía ningún administrador configuró sus datos bancarios. Tu solicitud quedará en espera hasta que alguno lo haga.</div>
        <?php endif; ?>
        <button class="btn btn-violet" type="submit"><?= icon('send', 16) ?> Solicitar inversión</button>
      </form>
    </div>

    <div class="card">
      <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('info', 20) ?> ¿Cómo funciona?</h2>
      <ol style="padding-left:18px;line-height:1.8">
        <li>Solicitas la inversión con el monto que quieres (mínimo 500 CUP).</li>
        <li>Todos los administradores reciben una notificación.</li>
        <li>El primer administrador que la acepta la "bloquea": a los demás les desaparece.</li>
        <li>Te llegan los datos bancarios del administrador que la aceptó.</li>
        <li>Haces la transferencia bancaria y subes el código del comprobante.</li>
        <li>El administrador valida el código con su banco: si coincide, aprueba y se te acredita el saldo; si no, la rechaza.</li>
      </ol>
    </div>
  </div>

  <div class="card mt">
    <h2 style="color:var(--violet-dark);font-size:17px"><?= icon('history', 20) ?> Mis inversiones</h2>
    <?php if (!$historial): ?>
      <p class="muted">Todavía no has solicitado inversiones.</p>
    <?php else: ?>
      <div class="table-wrap"><table class="tbl">
        <tr><th>Código</th><th>Monto</th><th>Admin</th><th>Estado</th><th>Fecha</th><th></th></tr>
        <?php foreach ($historial as $h): ?>
        <tr>
          <td><b><?= e($h['code']) ?></b></td>
          <td><?= money($h['amount_cup']) ?></td>
          <td><?= e($h['admin_name'] ?? '—') ?></td>
          <td><span class="badge <?= ($estadosInv[$h['status']][0] ?? 'b-warn') ?>"><?= ucfirst($h['status']) ?></span></td>
          <td class="muted"><?= e(fdate($h['created_at'])) ?></td>
          <td><a class="btn btn-outline btn-sm" href="invertir.php?id=<?= (int)$h['id'] ?>"><?= icon('eye', 14) ?> Ver</a></td>
        </tr>
        <?php endforeach; ?>
      </table></div>
    <?php endif; ?>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
