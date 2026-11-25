<?php
/** Checkout: datos de entrega y método de pago (efectivo o transferencia, todo en CUP). */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('checkout.php');
$page_title = 'Finalizar compra — ' . SITE_NAME;

// Productos del carrito (vivos y con stock)
$st = db()->prepare('SELECT ci.qty, p.id, p.title, p.price_cup, p.stock, p.photos, p.store_id, s.owner_id AS store_owner, s.name AS store_name, s.trial_until, s.subscription_until
                     FROM cart_items ci
                     JOIN products p ON p.id = ci.product_id
                     LEFT JOIN stores s ON s.id = p.store_id
                     WHERE ci.user_id = ? ORDER BY ci.id DESC');
$st->execute([$u['id']]);
$raw = $st->fetchAll();
$items = [];
foreach ($raw as $it) {
    $suspended = !empty($it['store_id']) && store_status(['trial_until' => $it['trial_until'], 'subscription_until' => $it['subscription_until']]) === 'suspendida';
    if ((int)$it['stock'] <= 0 || $suspended) continue;
    $items[] = $it;
}
$total = array_sum(array_map(fn($i) => $i['price_cup'] * $i['qty'], $items));

if (!$items) {
    flash('Tu carrito está vacío.', 'info');
    redirect('carrito.php');
}

$pay = payment_data();
$payOk = payment_is_set();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('checkout', 20, 600)) { flash('Demasiadas operaciones seguidas. Espera unos minutos.', 'err'); redirect('checkout.php'); }

    $metodo = $_POST['metodo'] === 'transferencia' ? 'transferencia' : 'efectivo';
    $address = trim($_POST['address'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $note = mb_substr(trim($_POST['note'] ?? ''), 0, 300);
    $transferId = mb_substr(trim($_POST['transfer_id'] ?? ''), 0, 80);

    $errores = [];
    if (mb_strlen($address) < 10) $errores[] = 'Escribe la dirección de entrega completa (calle, número, municipio).';
    if (mb_strlen($phone) < 8) $errores[] = 'Escribe un teléfono de contacto válido.';
    if ($metodo === 'transferencia' && !$payOk) $errores[] = 'El administrador todavía no configuró los datos de cobro. Elige efectivo o avisa al administrador.';

    if ($errores) {
        foreach ($errores as $er) flash($er, 'err');
    } else {
        // Verifica el stock otra vez justo antes de crear el pedido
        $falla = false;
        foreach ($items as $it) {
            $st2 = db()->prepare('SELECT stock, title FROM products WHERE id = ?');
            $st2->execute([(int)$it['id']]);
            $row = $st2->fetch();
            if (!$row || (int)$row['stock'] < (int)$it['qty']) { flash('«' . $row['title'] . '» ya no tiene stock suficiente.', 'err'); $falla = true; }
        }
        if (!$falla) {
            $code = 'VL-' . strtoupper(bin2hex(random_bytes(3)));
            db()->beginTransaction();
            try {
                db()->prepare('INSERT INTO orders (code, buyer_id, total_cup, payment_method, transfer_id, status, address, phone, note, created_at) VALUES (?,?,?,?,?,?,?,?,?,?)')
                    ->execute([$code, $u['id'], $total, $metodo, $metodo === 'transferencia' ? ($transferId ?: null) : null, 'pendiente', $address, $phone, $note, date('Y-m-d H:i:s')]);
                $orderId = (int)db()->lastInsertId();

                foreach ($items as $it) {
                    db()->prepare('INSERT INTO order_items (order_id, product_id, store_id, title, price_cup, qty, photo) VALUES (?,?,?,?,?,?,?)')
                        ->execute([$orderId, (int)$it['id'], $it['store_id'] ? (int)$it['store_id'] : null, $it['title'], (int)$it['price_cup'], (int)$it['qty'], photo_of($it['photos'])]);
                    db()->prepare('UPDATE products SET stock = stock - ? WHERE id = ?')->execute([(int)$it['qty'], (int)$it['id']]);
                    db()->prepare('DELETE FROM cart_items WHERE user_id = ? AND product_id = ?')->execute([$u['id'], (int)$it['id']]);
                }
                db()->commit();
            } catch (Throwable $e) {
                db()->rollBack();
                throw $e;
            }

            // Avisos: comprador, vendedores implicados y administradores
            notify((int)$u['id'], 'Pedido ' . $code . ' creado', 'Tu pedido por ' . money($total) . ' (' . $metodo . ') quedó pendiente. ' . ($metodo === 'transferencia' ? 'Si aún no enviaste la transferencia, guarda el ID en el detalle del pedido.' : 'Coordinarás el pago en efectivo al entregar.'), 'pedido.php?id=' . $orderId);
            $sellerIds = [];
            foreach ($items as $it) if (!empty($it['store_owner'])) $sellerIds[(int)$it['store_owner']] = true;
            foreach (array_keys($sellerIds) as $sid) {
                notify($sid, '¡Nueva venta en tu mini tienda!', 'Te compraron productos para el pedido ' . $code . '. Revísalo en Ventas recibidas.', 'ventas.php');
            }
            foreach (db()->query("SELECT id FROM users WHERE role = 'admin'")->fetchAll() as $adm) {
                notify((int)$adm['id'], 'Nuevo pedido ' . $code, 'Compra de ' . money($total) . ' por ' . $metodo . '. Revisa el pedido en el panel.', 'admin/pedidos.php');
            }
            sec_log('pedido', 'Pedido ' . $code . ' por ' . money($total) . ' (' . $metodo . ')', (int)$u['id']);
            flash('¡Pedido ' . $code . ' creado! Revisa los detalles y el pago.', 'ok');
            redirect('pedido.php?id=' . $orderId);
        }
    }
}

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)">🧾 Finalizar compra</h1>

<div class="grid grid-cols-2 mt">
  <div class="card">
    <h2 style="color:var(--violet-dark);font-size:18px;margin-bottom:10px">Resumen del pedido</h2>
    <div class="table-wrap"><table class="tbl">
      <?php foreach ($items as $it): ?>
      <tr>
        <td class="t-title"><?= e($it['title']) ?> <?php if (!empty($it['store_name'])): ?><span class="muted">(<?= e($it['store_name']) ?>)</span><?php endif; ?></td>
        <td style="white-space:nowrap"><?= (int)$it['qty'] ?> × <?= money($it['price_cup']) ?></td>
      </tr>
      <?php endforeach; ?>
      <tr><td style="text-align:right;font-weight:800">TOTAL</td><td style="font-size:18px;font-weight:800;color:var(--violet-dark)"><?= money($total) ?></td></tr>
    </table></div>
    <p class="help mt">Todo el pago es en pesos cubanos (CUP). Puedes pagar en efectivo al recibir o por transferencia bancaria.</p>
  </div>

  <div class="card">
    <form method="post">
      <?= csrf_field() ?>
      <h2 style="color:var(--violet-dark);font-size:18px;margin-bottom:10px">Entrega</h2>
      <div class="form" style="max-width:none">
        <div>
          <label class="f">Dirección de entrega *</label>
          <input class="input" name="address" placeholder="Calle, número, entre calles, municipio" value="<?= e($_POST['address'] ?? '') ?>" required>
        </div>
        <div>
          <label class="f">Teléfono de contacto *</label>
          <input class="input" name="phone" placeholder="+53 5xxx xxxx" value="<?= e($_POST['phone'] ?? ($u['phone'] ?? '')) ?>" required>
        </div>
        <div>
          <label class="f">Nota para el vendedor (opcional)</label>
          <textarea class="input" name="note" placeholder="Color, talla, momento preferido para la entrega…"><?= e($_POST['note'] ?? '') ?></textarea>
        </div>
      </div>

      <h2 style="color:var(--violet-dark);font-size:18px;margin:16px 0 4px">Método de pago</h2>
      <div class="pay-methods">
        <div class="pay-method <?= ($_POST['metodo'] ?? 'efectivo') === 'efectivo' ? 'on' : '' ?>" onclick="pickMethod(this, 'efectivo')">
          <span class="rad"></span>
          <div><b>💵 Efectivo</b><small>Pagas en CUP al recibir el pedido.</small></div>
        </div>
        <div class="pay-method <?= ($_POST['metodo'] ?? '') === 'transferencia' ? 'on' : '' ?>" onclick="pickMethod(this, 'transferencia')">
          <span class="rad"></span>
          <div><b>🏦 Transferencia bancaria</b><small>Transfiere a los datos del vendedor y guarda el ID.</small></div>
        </div>
      </div>
      <input type="radio" name="metodo" value="efectivo" id="efectivo" <?= ($_POST['metodo'] ?? 'efectivo') === 'efectivo' ? 'checked' : '' ?> style="display:none">
      <input type="radio" name="metodo" value="transferencia" id="transferencia" <?= ($_POST['metodo'] ?? '') === 'transferencia' ? 'checked' : '' ?> style="display:none">

      <div id="box-transferencia" style="display:<?= ($_POST['metodo'] ?? '') === 'transferencia' ? '' : 'none' ?>">
        <?php if ($payOk): ?>
          <div class="paydata">
            <h3>Transfiere a estos datos y guarda el ID de la operación</h3>
            <div class="row"><b>Banco:</b><span><?= e($pay['bank_name']) ?></span></div>
            <div class="row"><b>Tarjeta:</b><span><?= e($pay['card_number']) ?></span></div>
            <div class="row"><b>Titular:</b><span><?= e($pay['holder']) ?></span></div>
            <div class="row"><b>Teléfono:</b><span><?= e($pay['phone']) ?></span></div>
          </div>
          <label class="f">ID de la transferencia (si ya la hiciste)</label>
          <input class="input" name="transfer_id" placeholder="Ej: TB 0012345678" value="<?= e($_POST['transfer_id'] ?? '') ?>">
          <p class="help">Si aún no la hiciste, puedes dejarlo vacío y enviar el ID después desde el detalle del pedido.</p>
        <?php else: ?>
          <div class="flash flash-warn">El administrador todavía no configuró los datos de cobro para transferencias.</div>
        <?php endif; ?>
      </div>

      <div id="box-efectivo" style="display:<?= ($_POST['metodo'] ?? 'efectivo') === 'efectivo' ? '' : 'none' ?>">
        <div class="paydata">
          <h3>Pago en efectivo</h3>
          <p style="font-size:14.5px">Al entregar tu pedido pagarás <b><?= money($total) ?></b> en efectivo. Ten el dinero listo y confirma la entrega con el vendedor.</p>
        </div>
      </div>

      <button class="btn btn-yellow mt" type="submit" style="width:100%">✅ Confirmar pedido de <?= money($total) ?></button>
    </form>
  </div>
</div>

<?php include __DIR__ . '/includes/footer.php'; ?>
