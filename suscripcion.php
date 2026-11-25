<?php
/** Suscripción de la mini tienda: 5 días de prueba gratis, luego 200 CUP al mes con el saldo. */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller();
$page_title = 'Suscripción — ' . SITE_NAME;

$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$store = $st->fetch();
if (!$store) { flash('Primero crea tu mini tienda.', 'info'); redirect('mi-tienda.php'); }

if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'pagar') {
    csrf_check();
    if ((int)$u['balance_cup'] < SUBSCRIPTION_CUP) {
        flash('No tienes saldo suficiente. Recarga tu billetera primero (necesitas ' . money(SUBSCRIPTION_CUP) . ').', 'err');
        redirect('wallet.php');
    }
    // Paga la suscripción con el saldo y extiende 30 días
    db()->prepare('UPDATE users SET balance_cup = balance_cup - ? WHERE id = ?')->execute([SUBSCRIPTION_CUP, $u['id']]);
    $base = !empty($store['subscription_until']) && strtotime($store['subscription_until']) > time() ? strtotime($store['subscription_until']) : time();
    $until = date('Y-m-d', $base + SUBSCRIPTION_DAYS * 86400);
    db()->prepare('UPDATE stores SET subscription_until = ? WHERE id = ?')->execute([$until, $store['id']]);
    notify((int)$u['id'], 'Suscripción pagada 🌸', 'Tu tienda «' . $store['name'] . '» está al día hasta el ' . $until . '. ¡A vender!', 'vender.php');
    foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
        notify((int)$adm['id'], 'Suscripción pagada', $store['name'] . ' pagó ' . money(SUBSCRIPTION_CUP) . ' de suscripción (hasta ' . $until . ').', 'admin/tiendas.php');
    }
    sec_log('suscripcion_pagada', 'Tienda ' . $store['name'] . ': ' . money(SUBSCRIPTION_CUP) . ' hasta ' . $until, (int)$u['id']);
    flash('¡Pago realizado! Tu suscripción está al día hasta el ' . $until . '.', 'ok');
    redirect('suscripcion.php');
}

$estado = store_status($store);
include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)">💳 Suscripción de mi mini tienda</h1>

<div class="card" style="max-width:620px">
  <div class="row-between mb">
    <h2 style="color:var(--violet-dark);font-size:18px"><?= e($store['name']) ?></h2>
    <?= store_status_badge($store) ?>
  </div>

  <?php if ($estado === 'activa'): ?>
    <div class="flash flash-ok">Tu suscripción está al día hasta el <b><?= e($store['subscription_until']) ?></b>. Si la renuevas ahora, los días se suman al final del período actual.</div>
  <?php elseif ($estado === 'prueba'): ?>
    <div class="flash flash-info">Estás en la <b>prueba gratis</b> hasta el <b><?= e($store['trial_until']) ?></b>. Puedes pagar la suscripción ahora mismo y los 30 días se suman al terminar la prueba.</div>
  <?php else: ?>
    <div class="flash flash-warn">¡Tu prueba terminó! Tu tienda está <b>suspendida para el público</b> hasta que pagues la suscripción.</div>
  <?php endif; ?>

  <div class="paydata">
    <h3>Plan mensual</h3>
    <div class="row"><b>Precio:</b><span><?= money(SUBSCRIPTION_CUP) ?> al mes</span></div>
    <div class="row"><b>Duración:</b><span><?= SUBSCRIPTION_DAYS ?> días por cada pago</span></div>
    <div class="row"><b>Tu saldo disponible:</b><span><?= money($u['balance_cup']) ?></span></div>
    <div class="row"><b>Se paga con:</b><span>El saldo de tu billetera (<a href="wallet.php">recargar</a>)</span></div>
  </div>

  <?php if ((int)$u['balance_cup'] >= SUBSCRIPTION_CUP): ?>
    <form method="post" onsubmit="return confirmDel('¿Pagar <?= money(SUBSCRIPTION_CUP) ?> de tu saldo para la suscripción mensual?')"><?= csrf_field() ?>
      <input type="hidden" name="accion" value="pagar">
      <button class="btn btn-yellow" type="submit" style="width:100%">Pagar <?= money(SUBSCRIPTION_CUP) ?> con mi saldo</button>
    </form>
  <?php else: ?>
    <div class="flash flash-err">Te faltan <b><?= money(SUBSCRIPTION_CUP - (int)$u['balance_cup']) ?></b> de saldo. Recarga tu billetera para poder pagar la suscripción.</div>
    <a class="btn btn-violet" href="wallet.php" style="width:100%">Ir a recargar mi billetera</a>
  <?php endif; ?>

  <hr class="sep">
  <p class="help">La suscripción mantiene tu tienda visible en Violetero. Si se vence, tus productos no se muestran al público (no se borran: cuando pagues, vuelven a verse igual que estaban).</p>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
