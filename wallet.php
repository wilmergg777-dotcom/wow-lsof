<?php
/** Billetera: saldo en CUP, recargas por transferencia e historial. */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('wallet.php');
$page_title = 'Mi Billetera — ' . SITE_NAME;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('recarga', 8, 3600)) {
        flash('Demasiadas solicitudes de recarga. Espera un rato.', 'err');
        redirect('wallet.php');
    }
    $amount = (int)($_POST['amount'] ?? 0);
    $tid = mb_substr(trim($_POST['transfer_id'] ?? ''), 0, 80);
    if ($amount < 100) flash('La recarga mínima es de 100 CUP.', 'err');
    elseif (mb_strlen($tid) < 4) flash('Escribe el ID de la transferencia del comprobante del banco.', 'err');
    else {
        db()->prepare('INSERT INTO topups (user_id, amount_cup, transfer_id, status, created_at) VALUES (?,?,?,"pendiente",?)')
            ->execute([$u['id'], $amount, $tid, date('Y-m-d H:i:s')]);
        foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
            notify((int)$adm['id'], 'Nueva recarga pendiente de verificar', $u['name'] . ' recargó ' . money($amount) . ' (ID: ' . $tid . '). Revísala en Recargas.', 'admin/recargas.php');
        }
        sec_log('recarga_solicitada', 'Recarga de ' . money($amount) . ' ID ' . $tid, (int)$u['id']);
        flash('¡Solicitud enviada! Cuando el administrador verifique la transferencia, tu saldo se acredita.', 'ok');
        redirect('wallet.php');
    }
}

$st = db()->prepare('SELECT * FROM topups WHERE user_id = ? ORDER BY id DESC LIMIT 50');
$st->execute([$u['id']]);
$topups = $st->fetchAll();
$pay = payment_data();
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)">💰 Mi Billetera</h1>

<div class="grid grid-cols-2 mt">
  <div>
    <div class="card mb" style="background:linear-gradient(135deg,var(--violet-light),var(--violet-dark));color:#fff">
      <div class="help" style="color:#DDD6FE">Saldo disponible</div>
      <div style="font-size:36px;font-weight:800"><?= money($u['balance_cup']) ?></div>
      <div class="help" style="color:#DDD6FE">Todo en pesos cubanos (CUP)</div>
    </div>

    <div class="card">
      <h2 style="color:var(--violet-dark);font-size:17px">Recargar saldo</h2>
      <p class="help mb">Transfiere a los datos de la tienda y envía tu solicitud. El administrador verifica la transferencia y acredita tu saldo.</p>
      <?php if (payment_is_set()): ?>
        <div class="paydata">
          <h3>Transfiere a:</h3>
          <div class="row"><b>Banco:</b><span><?= e($pay['bank_name']) ?></span></div>
          <div class="row"><b>Tarjeta:</b><span><?= e($pay['card_number']) ?></span></div>
          <div class="row"><b>Titular:</b><span><?= e($pay['holder']) ?></span></div>
          <div class="row"><b>Teléfono:</b><span><?= e($pay['phone']) ?></span></div>
        </div>
        <form method="post" class="form" style="max-width:none">
          <?= csrf_field() ?>
          <div><label class="f">Monto a recargar (CUP)</label>
            <input class="input" type="number" name="amount" min="100" step="50" placeholder="Ej: 2000" required></div>
          <div><label class="f">ID de la transferencia</label>
            <input class="input" name="transfer_id" placeholder="Ej: TB 0012345678" required></div>
          <button class="btn btn-yellow" type="submit">Enviar solicitud de recarga</button>
        </form>
      <?php else: ?>
        <div class="flash flash-warn">El administrador todavía no configuró los datos de cobro. Avisa al administrador de la tienda.</div>
      <?php endif; ?>
    </div>
  </div>

  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px;margin-bottom:10px">Historial de recargas</h2>
    <?php if (!$topups): ?>
      <div class="empty"><div class="big">🏦</div>Todavía no has pedido recargas.</div>
    <?php else: ?>
      <div class="table-wrap"><table class="tbl">
        <tr><th>Fecha</th><th>Monto</th><th>ID transferencia</th><th>Estado</th><th>Nota</th></tr>
        <?php foreach ($topups as $t): ?>
        <tr>
          <td class="muted" style="white-space:nowrap"><?= e(fdate($t['created_at'])) ?></td>
          <td><b><?= money($t['amount_cup']) ?></b></td>
          <td><?= e($t['transfer_id']) ?></td>
          <td><span class="state st-<?= e($t['status']) ?>"><?= e(ucfirst($t['status'])) ?></span></td>
          <td class="help"><?= e($t['admin_note'] ?? '') ?></td>
        </tr>
        <?php endforeach; ?>
      </table></div>
    <?php endif; ?>
  </div>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
