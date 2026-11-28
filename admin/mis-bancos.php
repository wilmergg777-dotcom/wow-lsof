<?php
/**
 * Mis datos bancarios (por admin).
 * Cada administrador puede tener varias cuentas bancarias para que los usuarios
 * puedan elegir a cuál transferir cuando hacen una inversión.
 */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Mis datos bancarios — ' . SITE_NAME;
$tab = 'mis-bancos';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'guardar') {
        if (!rate_limit('bancos', 15, 600)) { flash('Espera un momento.', 'err'); redirect('mis-bancos.php'); }
        $id = (int)($_POST['id'] ?? 0);
        $label = trim($_POST['label'] ?? '');
        $bank = trim($_POST['bank_name'] ?? '');
        $acc = trim($_POST['account_number'] ?? '');
        $holder = trim($_POST['holder'] ?? '');
        $phone = trim($_POST['phone'] ?? '');
        $active = isset($_POST['is_active']) ? 1 : 0;

        if (mb_strlen($label) < 3) flash('Pon una etiqueta (ej: "BPA principal").', 'err');
        elseif (mb_strlen($bank) < 3) flash('Escribe el nombre del banco.', 'err');
        elseif (mb_strlen($acc) < 8) flash('Escribe el número de cuenta (mínimo 8).', 'err');
        elseif (mb_strlen($holder) < 3) flash('Escribe el titular de la cuenta.', 'err');
        else {
            if ($id > 0) {
                // Solo el admin dueño puede editar
                db()->prepare('UPDATE admin_bank_accounts SET label=?, bank_name=?, account_number=?, holder=?, phone=?, is_active=? WHERE id=? AND admin_id=?')
                    ->execute([$label, $bank, $acc, $holder, $phone ?: null, $active, $id, $admin['id']]);
                flash('Cuenta bancaria actualizada.', 'ok');
            } else {
                db()->prepare('INSERT INTO admin_bank_accounts (admin_id, label, bank_name, account_number, holder, phone, is_active, created_at) VALUES (?,?,?,?,?,?,?,?)')
                    ->execute([$admin['id'], $label, $bank, $acc, $holder, $phone ?: null, $active, date('Y-m-d H:i:s')]);
                flash('Cuenta bancaria añadida. Los usuarios ya pueden elegirla al invertir.', 'ok');
            }
            sec_log('banco_guardado', 'Cuenta: ' . $label . ' (' . $bank . ')', (int)$admin['id']);
        }
        redirect('mis-bancos.php');
    }

    if ($accion === 'eliminar') {
        $id = (int)($_POST['id'] ?? 0);
        db()->prepare('DELETE FROM admin_bank_accounts WHERE id=? AND admin_id=?')->execute([$id, $admin['id']]);
        flash('Cuenta bancaria eliminada.', 'ok');
        redirect('mis-bancos.php');
    }

    if ($accion === 'toggle') {
        $id = (int)($_POST['id'] ?? 0);
        db()->prepare('UPDATE admin_bank_accounts SET is_active = 1 - is_active WHERE id=? AND admin_id=?')->execute([$id, $admin['id']]);
        flash('Estado de la cuenta cambiado.', 'ok');
        redirect('mis-bancos.php');
    }
}

// Lista de cuentas del admin
$st = db()->prepare('SELECT * FROM admin_bank_accounts WHERE admin_id = ? ORDER BY is_active DESC, id DESC');
$st->execute([$admin['id']]);
$cuentas = $st->fetchAll();

// Para editar
$editId = (int)($_GET['editar'] ?? 0);
$editCuenta = null;
if ($editId) {
    foreach ($cuentas as $c) if ((int)$c['id'] === $editId) $editCuenta = $c;
}

include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('landmark', 26) ?> Mis datos bancarios</h1>
<p class="muted mb">Tus cuentas para recibir inversiones. Cuando un usuario pide una inversión, elige a qué administrador transferir y verá los datos de la cuenta que selecciones.</p>

<div class="grid grid-cols-2 mt">
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px"><?= $editCuenta ? 'Editar cuenta' : 'Añadir cuenta' ?></h2>
    <form method="post" class="form">
      <?= csrf_field() ?>
      <input type="hidden" name="accion" value="guardar">
      <input type="hidden" name="id" value="<?= (int)($editCuenta['id'] ?? 0) ?>">
      <div><label class="f">Etiqueta *</label>
        <input class="input" name="label" required value="<?= e($editCuenta['label'] ?? '') ?>" placeholder="Ej: BPA principal, Bandec, etc."></div>
      <div><label class="f">Banco *</label>
        <input class="input" name="bank_name" required value="<?= e($editCuenta['bank_name'] ?? '') ?>" placeholder="Ej: Banco Popular de Ahorro"></div>
      <div><label class="f">Número de cuenta *</label>
        <input class="input" name="account_number" required value="<?= e($editCuenta['account_number'] ?? '') ?>"></div>
      <div><label class="f">Titular *</label>
        <input class="input" name="holder" required value="<?= e($editCuenta['holder'] ?? '') ?>"></div>
      <div><label class="f">Teléfono (opcional)</label>
        <input class="input" name="phone" value="<?= e($editCuenta['phone'] ?? '') ?>"></div>
      <label class="row" style="gap:8px;align-items:center">
        <input type="checkbox" name="is_active" <?= ($editCuenta['is_active'] ?? 1) ? 'checked' : '' ?>>
        <span>Activa (visible para los usuarios al invertir)</span>
      </label>
      <button class="btn btn-violet" type="submit"><?= icon('save', 16) ?> <?= $editCuenta ? 'Guardar cambios' : 'Añadir cuenta' ?></button>
      <?php if ($editCuenta): ?><a class="btn btn-outline" href="mis-bancos.php">Cancelar</a><?php endif; ?>
    </form>
  </div>

  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:17px">Mis cuentas (<?= count($cuentas) ?>)</h2>
    <?php if (!$cuentas): ?>
      <p class="muted">Todavía no has añadido cuentas bancarias. Añade al menos una para que los usuarios puedan transferirte cuando inviertan.</p>
    <?php else: foreach ($cuentas as $c): ?>
      <div class="card mt" style="border:1px solid var(--violet-border);padding:12px">
        <div class="row-between">
          <div>
            <b><?= e($c['label']) ?></b>
            <span class="badge <?= $c['is_active'] ? 'b-ok' : 'b-warn' ?>"><?= $c['is_active'] ? 'Activa' : 'Inactiva' ?></span>
          </div>
        </div>
        <div class="row mt" style="gap:12px;flex-wrap:wrap">
          <div><span class="help">Banco:</span><br><b><?= e($c['bank_name']) ?></b></div>
          <div><span class="help">Cuenta:</span><br><b><?= e($c['account_number']) ?></b></div>
          <div><span class="help">Titular:</span><br><b><?= e($c['holder']) ?></b></div>
          <?php if ($c['phone']): ?><div><span class="help">Tel:</span><br><b><?= e($c['phone']) ?></b></div><?php endif; ?>
        </div>
        <div class="row mt" style="gap:6px">
          <a class="btn btn-outline btn-sm" href="mis-bancos.php?editar=<?= (int)$c['id'] ?>"><?= icon('edit', 14) ?> Editar</a>
          <form method="post" style="display:inline"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="toggle">
            <input type="hidden" name="id" value="<?= (int)$c['id'] ?>">
            <button class="btn btn-outline btn-sm" type="submit"><?= $c['is_active'] ? 'Desactivar' : 'Activar' ?></button>
          </form>
          <form method="post" style="display:inline"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="eliminar">
            <input type="hidden" name="id" value="<?= (int)$c['id'] ?>">
            <button class="btn btn-red btn-sm" type="submit" onclick="return confirmDel('¿Eliminar esta cuenta bancaria?')"><?= icon('trash', 14) ?> Eliminar</button>
          </form>
        </div>
      </div>
    <?php endforeach; endif; ?>
  </div>
</div>

<?php include __DIR__ . '/admin-footer.php'; ?>
