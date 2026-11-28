<?php
/**
 * Ofertas de mensajería — vista del mensajero.
 * Lista todas las ofertas abiertas (priorizando su zona) y procesa las postulaciones.
 */
require_once __DIR__ . '/includes/auth.php';
$u = require_login('ofertas-mensajeros.php');
$page_title = 'Ofertas de mensajería — ' . SITE_NAME;

// El mensajero debe tener un perfil KYC aprobado para postularse
$st = db()->prepare('SELECT * FROM messengers WHERE user_id = ? ORDER BY id DESC LIMIT 1');
$st->execute([$u['id']]);
$perfil = $st->fetch();

/* ---------- POST: postularse ---------- */
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['accion'] ?? '') === 'postular') {
    csrf_check();
    if (!$perfil || $perfil['status'] !== 'aprobado') {
        flash('Tu perfil de mensajero debe estar aprobado para postularte. Complétalo en «Perfil de mensajero».', 'err');
        redirect('mensajero-kyc.php');
    }
    if (!rate_limit('postular', 10, 600)) { flash('Espera un momento antes de otra postulación.', 'err'); redirect('ofertas-mensajeros.php'); }
    $oid = (int)($_POST['offer_id'] ?? 0);
    $msg = mb_substr(trim($_POST['message'] ?? ''), 0, 500);

    // Verifica que la oferta exista y esté abierta
    $st = db()->prepare('SELECT o.*, s.name AS store_name, u.name AS owner_name FROM messenger_offers o LEFT JOIN stores s ON s.id = o.store_id LEFT JOIN users u ON u.id = o.owner_id WHERE o.id = ?');
    $st->execute([$oid]);
    $o = $st->fetch();
    if (!$o || $o['status'] !== 'abierta') {
        flash('Esa oferta ya no está disponible.', 'err');
    } else {
        // ¿Ya se postuló?
        $st = db()->prepare('SELECT id FROM messenger_applications WHERE offer_id = ? AND messenger_id = ?');
        $st->execute([$oid, $perfil['id']]);
        if ($st->fetch()) {
            flash('Ya te postulaste a esta oferta.', 'info');
        } else {
            db()->prepare('INSERT INTO messenger_applications (offer_id, messenger_id, message, status, created_at) VALUES (?,?,?,?,?)')
                ->execute([$oid, $perfil['id'], $msg ?: null, 'pendiente', date('Y-m-d H:i:s')]);
            // Aviso al dueño de la tienda
            notify((int)$o['owner_id'], 'Nueva postulación a tu oferta', $perfil['full_name'] . ' se postuló a «' . $o['title'] . '». Revisa su perfil KYC y decide.', 'buscar-mensajeros.php?tab=mis-ofertas');
            sec_log('postulacion_enviada', 'Oferta ' . $o['title'] . ' - mensajero ' . $perfil['full_name'], (int)$u['id']);
            flash('¡Postulación enviada! El dueño de la tienda te avisará si te acepta.', 'ok');
        }
    }
    redirect('ofertas-mensajeros.php');
}

// Filtro de provincia (el mensajero puede ver ofertas de cualquier provincia)
$fProv = trim($_GET['prov'] ?? ($perfil['province'] ?? ''));
$provs = cuba_provinces();
if ($fProv !== '' && !isset($provs[$fProv])) $fProv = '';

// Ofertas abiertas, ordenadas por cercanía a la zona del mensajero
$sql = "SELECT o.*, s.name AS store_name, u.name AS owner_name,
        (SELECT COUNT(*) FROM messenger_applications a WHERE a.offer_id = o.id AND a.messenger_id = ?) AS ya_postulado
        FROM messenger_offers o
        LEFT JOIN stores s ON s.id = o.store_id
        LEFT JOIN users u ON u.id = o.owner_id
        WHERE o.status = 'abierta'";
$params = [$perfil['id'] ?? 0];
if ($fProv) {
    $nearby = nearby_provinces($fProv, 1);
    $ph = implode(',', array_fill(0, count($nearby), '?'));
    $sql .= " AND o.province IN ($ph)";
    $params = array_merge($params, $nearby);
    $sql .= " ORDER BY (o.province = ?) DESC, o.id DESC";
    $params[] = $fProv;
} else {
    $sql .= " ORDER BY o.id DESC";
}
$sql .= " LIMIT 50";
$st = db()->prepare($sql);
$st->execute($params);
$ofertas = $st->fetchAll();

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('megaphone', 26) ?> Ofertas de mensajería</h1>
<p class="muted mb">Trabajos de mensajería publicados por los dueños de tienda.</p>

<?php if (!$perfil): ?>
  <div class="flash flash-warn mb">Para postularte necesitas completar tu <a href="mensajero-kyc.php"><b>perfil de mensajero</b></a> (verificación KYC). Puedes ver las ofertas mientras tanto.</div>
<?php elseif ($perfil['status'] !== 'aprobado'): ?>
  <div class="flash flash-info mb">Tu perfil de mensajero está <b><?= ucfirst($perfil['status']) ?></b>. Cuando un administrador lo apruebe podrás postularte a las ofertas.</div>
<?php endif; ?>

<div class="card mb" style="padding:12px 14px">
  <form method="get" class="row" style="gap:8px;align-items:center">
    <label class="f" style="margin:0"><?= icon('map-pin', 14) ?> Ver ofertas en:</label>
    <select class="input" name="prov" onchange="this.form.submit()" style="width:auto;padding:8px 12px">
      <option value="">Todo el país</option>
      <?php foreach (province_options() as $slug => $nm): ?>
        <option value="<?= e($slug) ?>" <?= $fProv === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
      <?php endforeach; ?>
    </select>
    <?php if ($fProv): ?><span class="help">Mostrando ofertas en <?= e(province_name($fProv)) ?> y provincias cercanas.</span><?php endif; ?>
  </form>
</div>

<?php if (!$ofertas): ?>
  <div class="card empty"><div class="big"><?= icon('megaphone', 44) ?></div>No hay ofertas de mensajería <?= $fProv ? 'en ' . e(province_name($fProv)) : 'publicadas' ?> en este momento. Vuelve a revisar en unos días.</div>
<?php else: ?>
  <div class="grid grid-products">
    <?php foreach ($ofertas as $o): ?>
      <div class="card" style="padding:14px;display:flex;flex-direction:column">
        <b style="font-size:15px"><?= e($o['title']) ?></b>
        <div class="help"><?= e($o['store_name'] ?? $o['owner_name'] ?? 'Tienda') ?> · <?= e(fdate($o['created_at'])) ?></div>
        <div class="mt" style="display:flex;gap:6px;flex-wrap:wrap">
          <span class="badge b-info"><?= icon('map-pin', 13) ?> <?= e(province_name($o['province'])) ?><?= $o['municipality'] ? ' · ' . e(municipality_name($o['province'], $o['municipality'])) : '' ?></span>
          <?php if ($o['pay_cup']): ?><span class="badge b-ok"><?= money($o['pay_cup']) ?></span><?php endif; ?>
        </div>
        <?php if (!empty($o['description'])): ?><p class="help mt" style="flex:1"><?= e(mb_substr($o['description'], 0, 180)) ?><?= mb_strlen($o['description']) > 180 ? '…' : '' ?></p><?php endif; ?>
        <div class="mt" style="margin-top:auto">
          <?php if (!$perfil || $perfil['status'] !== 'aprobado'): ?>
            <span class="badge b-warn"><?= icon('lock', 13) ?> Perfil no aprobado</span>
          <?php elseif ($o['ya_postulado']): ?>
            <span class="badge b-info"><?= icon('check', 13) ?> Ya postulado</span>
          <?php else: ?>
            <form method="post"><?= csrf_field() ?>
              <input type="hidden" name="accion" value="postular">
              <input type="hidden" name="offer_id" value="<?= (int)$o['id'] ?>">
              <input class="input" name="message" placeholder="Mensaje opcional" style="margin-bottom:6px;font-size:13px">
              <button class="btn btn-violet btn-sm" type="submit" style="width:100%"><?= icon('send', 14) ?> Postularme</button>
            </form>
          <?php endif; ?>
        </div>
      </div>
    <?php endforeach; ?>
  </div>
<?php endif; ?>

<?php include __DIR__ . '/includes/footer.php'; ?>
