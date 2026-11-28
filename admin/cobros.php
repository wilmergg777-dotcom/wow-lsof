<?php
/**
 * Admin: datos de cobro para transferencias (tarjeta, titular, teléfono).
 * Guardar exige confirmación (Cambio 4) y avisa a TODOS los administradores.
 */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Datos de Cobro — Administración';

$pay = payment_data();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'guardar') {
    csrf_check();
    if (!rate_limit('cobros', 10, 600)) { flash('Espera un momento antes de volver a guardar.', 'err'); redirect('cobros.php'); }
    $bank = mb_substr(trim($_POST['bank_name'] ?? ''), 0, 120);
    $card = mb_substr(trim($_POST['card_number'] ?? ''), 0, 60);
    $holder = mb_substr(trim($_POST['holder'] ?? ''), 0, 120);
    $phone = mb_substr(trim($_POST['phone'] ?? ''), 0, 40);
    if (mb_strlen($card) < 8 || mb_strlen($holder) < 3 || mb_strlen($phone) < 8) {
        flash('Completa la tarjeta, el titular y el teléfono correctamente.', 'err');
    } else {
        if ($pay) {
            db()->prepare('UPDATE payment_settings SET bank_name=?, card_number=?, holder=?, phone=?, updated_by=?, updated_at=? WHERE id=?')
                ->execute([$bank, $card, $holder, $phone, $admin['id'], date('Y-m-d H:i:s'), (int)$pay['id']]);
        } else {
            db()->prepare('INSERT INTO payment_settings (bank_name, card_number, holder, phone, updated_by, updated_at) VALUES (?,?,?,?,?,?)')
                ->execute([$bank, $card, $holder, $phone, $admin['id'], date('Y-m-d H:i:s')]);
        }
        // Aviso a todos los administradores (incluido el que guarda)
        foreach (db()->query("SELECT id, name FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
            notify((int)$adm['id'], 'Datos de cobro actualizados', $admin['name'] . ' actualizó los datos de cobro para transferencias (' . mb_substr($card, 0, 4) . '••••). Revisa que todo esté correcto.', 'cobros.php');
        }
        sec_log('cobros_actualizados', 'Datos de cobro guardados por ' . $admin['name'], (int)$admin['id']);
        flash('Datos de cobro guardados. Todos los administradores recibieron el aviso.', 'ok');
        redirect('cobros.php');
    }
}
include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('landmark', 26) ?> Datos de cobro (transferencias)</h1>
<p class="muted mb">Estos datos se muestran SOLO cuando un cliente elige pagar por transferencia (checkout, recarga) o cuando ya hizo un pedido con transferencia. Nadie más los ve.</p>

<div class="card" style="max-width:640px">
  <?php if ($pay): ?>
    <div class="paydata">
      <h3>Datos actuales (actualizados <?= e(fdate($pay['updated_at'] ?? null)) ?> por <?= e($pay['updated_by'] ? ($admin['name'] === '' ? 'un administrador' : '') : '') ?>)</h3>
      <div class="row"><b>Banco:</b><span><?= e($pay['bank_name'] ?: '—') ?></span></div>
      <div class="row"><b>Tarjeta:</b><span><?= e($pay['card_number'] ?: '—') ?></span></div>
      <div class="row"><b>Titular:</b><span><?= e($pay['holder'] ?: '—') ?></span></div>
      <div class="row"><b>Teléfono:</b><span><?= e($pay['phone'] ?: '—') ?></span></div>
    </div>
  <?php endif; ?>

  <form method="post" class="form form-wide" onsubmit="return confirmDel('¿Guardar estos datos de cobro? Se enviará un aviso a TODOS los administradores.')">
    <?= csrf_field() ?>
    <input type="hidden" name="accion" value="guardar">
    <div><label class="f">Banco / vía (Ej: BPA, Transfermóvil, EnZona)</label>
      <input class="input" name="bank_name" value="<?= e($pay['bank_name'] ?? '') ?>" placeholder="Ej: BPA — cuenta en CUP"></div>
    <div><label class="f">Número de tarjeta / cuenta *</label>
      <input class="input" name="card_number" required value="<?= e($pay['card_number'] ?? '') ?>" placeholder="Ej: 9227 9598 1234 5678"></div>
    <div><label class="f">Titular de la cuenta *</label>
      <input class="input" name="holder" required value="<?= e($pay['holder'] ?? '') ?>" placeholder="Nombre completo del titular"></div>
    <div><label class="f">Teléfono asociado *</label>
      <input class="input" name="phone" required value="<?= e($pay['phone'] ?? '') ?>" placeholder="+53 5xxx xxxx"></div>
    <button class="btn btn-violet" type="submit"><?= icon('save', 18) ?> Guardar datos de cobro</button>
    <p class="help">Al guardar se te pedirá confirmar y se avisará a todos los administradores automáticamente.</p>
  </form>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
