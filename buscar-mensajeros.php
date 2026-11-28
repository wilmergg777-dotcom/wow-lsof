<?php
/**
 * ============================================================
 * BUSCAR MENSAJEROS + PUBLICAR OFERTAS DE MENSAJERÍA
 * ============================================================
 * Página para dueños de tienda (y admins):
 *  1. Buscar mensajeros aprobados, filtrando por municipio → provincia → cercanas.
 *     Al abrir un perfil, se ven los datos KYC (carnet frente/dorso + selfie).
 *  2. Publicar ofertas de mensajería ("Busco mensajero en X para Y").
 *  3. Ver postulaciones a sus ofertas y aceptarlas/rechazarlas (notifica al mensajero).
 * ============================================================
 */
require_once __DIR__ . '/includes/auth.php';
$u = require_seller('buscar-mensajeros.php');
$page_title = 'Mensajeros — ' . SITE_NAME;

// ¿Tiene tienda el usuario? (los admins también pueden aunque no tengan)
$st = db()->prepare('SELECT * FROM stores WHERE owner_id = ? LIMIT 1');
$st->execute([$u['id']]);
$myStore = $st->fetch();
$esAdmin = ($u['role'] ?? '') === 'admin';

/* ---------- POST: publicar / cerrar oferta ---------- */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'publicar_oferta') {
        if (!rate_limit('oferta', 10, 600)) { flash('Espera un momento.', 'err'); redirect('buscar-mensajeros.php'); }
        $title = trim($_POST['title'] ?? '');
        $desc = mb_substr(trim($_POST['description'] ?? ''), 0, 600);
        $province = trim($_POST['province'] ?? '');
        $municipality = trim($_POST['municipality'] ?? '');
        $pay = (int)($_POST['pay_cup'] ?? 0);
        $provs = cuba_provinces();
        if (mb_strlen($title) < 5) { flash('Escribe un título descriptivo (mínimo 5 letras).', 'err'); }
        elseif ($province === '' || !isset($provs[$province])) { flash('Selecciona la provincia de la oferta.', 'err'); }
        else {
            if ($municipality !== '' && !isset($provs[$province]['municipalities'][$municipality])) $municipality = '';
            $storeId = $myStore ? (int)$myStore['id'] : 0;
            db()->prepare('INSERT INTO messenger_offers (store_id, owner_id, title, description, province, municipality, pay_cup, status, created_at) VALUES (?,?,?,?,?,?,?,?)')
                ->execute([$storeId, $u['id'], $title, $desc, $province, $municipality ?: null, $pay > 0 ? $pay : null, 'abierta', date('Y-m-d H:i:s')]);
            // Avisar a los mensajeros aprobados de la zona (municipio primero, luego provincia, luego cercanas)
            $nearby = nearby_provinces($province, 1);
            $ph = implode(',', array_fill(0, count($nearby), '?'));
            $st = db()->prepare("SELECT DISTINCT user_id FROM messengers WHERE status='aprobado' AND (municipality=? OR province=? OR province IN ($ph))");
            $st->execute(array_merge([$municipality, $province], $nearby));
            $n = 0;
            foreach ($st->fetchAll() as $m) {
                if ((int)$m['user_id'] === (int)$u['id']) continue;
                notify((int)$m['user_id'], 'Nueva oferta de mensajería cerca de ti', '«' . $title . '» en ' . province_name($province) . ($municipality ? ', ' . municipality_name($province, $municipality) : '') . ($pay > 0 ? ' · paga ' . money($pay) : '') . '. Postúlate si te interesa.', 'mensajero-kyc.php');
                $n++;
            }
            sec_log('oferta_publicada', 'Oferta: ' . $title . ' en ' . $province . ' (' . $n . ' mensajeros avisados)', (int)$u['id']);
            flash('Oferta publicada. Se avisó a ' . $n . ' mensajero(s) de la zona.', 'ok');
        }
        redirect('buscar-mensajeros.php?tab=mis-ofertas');
    }

    if ($accion === 'cerrar_oferta') {
        $oid = (int)($_POST['offer_id'] ?? 0);
        db()->prepare("UPDATE messenger_offers SET status='cerrada' WHERE id=? AND owner_id=?")->execute([$oid, $u['id']]);
        flash('Oferta cerrada.', 'ok');
        redirect('buscar-mensajeros.php?tab=mis-ofertas');
    }

    if ($accion === 'decidir_postulacion') {
        $aid = (int)($_POST['application_id'] ?? 0);
        $decision = $_POST['decision'] === 'aceptar' ? 'aceptada' : 'rechazada';
        // Carga la postulación y verifica que la oferta sea del usuario
        $st = db()->prepare('SELECT a.*, o.owner_id, o.title FROM messenger_applications a JOIN messenger_offers o ON o.id = a.offer_id WHERE a.id = ?');
        $st->execute([$aid]);
        $app = $st->fetch();
        if (!$app || (int)$app['owner_id'] !== (int)$u['id']) {
            flash('Esa postulación no es tuya.', 'err');
        } elseif ($app['status'] !== 'pendiente') {
            flash('Esa postulación ya fue decidida.', 'err');
        } else {
            db()->prepare('UPDATE messenger_applications SET status=?, reviewed_at=? WHERE id=?')
                ->execute([$decision, date('Y-m-d H:i:s'), $aid]);
            notify((int)$app['messenger_id'],
                $decision === 'aceptada' ? '¡Aceptaste como mensajero!' : 'Postulación rechazada',
                $decision === 'aceptada'
                    ? 'Te aceptaron para la oferta «' . $app['title'] . '». El dueño de la tienda se pondrá en contacto contigo para coordinar las entregas.'
                    : 'Tu postulación a la oferta «' . $app['title'] . '» fue rechazada. Sigue revisando otras ofertas.',
                'mensajero-kyc.php');
            sec_log('postulacion_' . $decision, 'Oferta ' . $app['title'] . ' - postulación ' . $aid, (int)$u['id']);
            flash($decision === 'aceptada' ? 'Aceptaste al mensajero. Se le avisó.' : 'Rechazaste la postulación. Se le avisó.', 'ok');
        }
        redirect('buscar-mensajeros.php?tab=mis-ofertas');
    }
}

/* ---------- Búsqueda de mensajeros ---------- */
$tab = $_GET['tab'] ?? 'buscar';
$fProv = trim($_GET['prov'] ?? '');
$fMuni = trim($_GET['muni'] ?? '');
$provs = cuba_provinces();
if ($fProv !== '' && !isset($provs[$fProv])) $fProv = '';
if ($fProv !== '' && $fMuni !== '' && !isset($provs[$fProv]['municipalities'][$fMuni])) $fMuni = '';

// Mensajeros aprobados, ordenados por cercanía (mismo municipio → provincia → cercanas → resto)
$messengerList = [];
if ($fProv) {
    $nearby = nearby_provinces($fProv, 1);
    $ph = implode(',', array_fill(0, count($nearby), '?'));
    $sql = "SELECT m.*, u.name AS user_name, u.email, u.phone AS user_phone, u.role
            FROM messengers m JOIN users u ON u.id = m.user_id
            WHERE m.status = 'aprobado'";
    $params = [];
    if ($fMuni) { $sql .= " AND m.municipality = ?"; $params[] = $fMuni; }
    elseif ($fProv) { $sql .= " AND m.province = ?"; $params[] = $fProv; }
    $sql .= " ORDER BY m.id DESC LIMIT 60";
    $st = db()->prepare($sql);
    $st->execute($params);
    $messengerList = $st->fetchAll();
    // Si hay pocos en el municipio/provincia, amplía a cercanas
    if (count($messengerList) < 6 && $nearby) {
        $sql2 = "SELECT m.*, u.name AS user_name, u.email, u.phone AS user_phone, u.role
                 FROM messengers m JOIN users u ON u.id = m.user_id
                 WHERE m.status = 'aprobado' AND m.province IN ($ph)";
        $st2 = db()->prepare($sql2);
        $st2->execute($nearby);
        $existentes = array_column($messengerList, 'id');
        foreach ($st2->fetchAll() as $m) {
            if (!in_array($m['id'], $existentes, true)) { $messengerList[] = $m; $existentes[] = $m['id']; }
        }
    }
}

// Mis ofertas (del dueño de tienda) + postulaciones
$misOfertas = [];
if ($myStore || $esAdmin) {
    $st = db()->prepare('SELECT o.*, (SELECT COUNT(*) FROM messenger_applications a WHERE a.offer_id = o.id AND a.status="pendiente") AS pendientes FROM messenger_offers o WHERE o.owner_id = ? ORDER BY o.id DESC LIMIT 50');
    $st->execute([$u['id']]);
    $misOfertas = $st->fetchAll();
}

include __DIR__ . '/includes/header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('bike', 26) ?> Mensajeros</h1>
<p class="muted mb">Busca mensajeros verificados en tu zona, publica ofertas de mensajería y revisa quién se postula.</p>

<div class="pill-tabs">
  <a href="buscar-mensajeros.php?tab=buscar" class="<?= $tab === 'buscar' ? 'on' : '' ?>">Buscar mensajeros</a>
  <?php if ($myStore || $esAdmin): ?>
    <a href="buscar-mensajeros.php?tab=publicar" class="<?= $tab === 'publicar' ? 'on' : '' ?>">Publicar oferta</a>
    <a href="buscar-mensajeros.php?tab=mis-ofertas" class="<?= $tab === 'mis-ofertas' ? 'on' : '' ?>">Mis ofertas <?= $misOfertas && array_sum(array_column($misOfertas, 'pendientes')) ? '<span class="dot">' . array_sum(array_column($misOfertas, 'pendientes')) . '</span>' : '' ?></a>
  <?php endif; ?>
</div>

<?php if ($tab === 'buscar'): ?>
  <div class="card mb" style="padding:14px 16px">
    <form method="get" class="row" style="gap:8px;align-items:flex-end">
      <input type="hidden" name="tab" value="buscar">
      <div>
        <label class="f" style="font-size:12px"><?= icon('map-pin', 14) ?> Buscar en</label>
        <select class="input" name="prov" onchange="fillMunis(this.value); this.form.submit()" style="width:auto;padding:8px 12px">
          <option value="">— Toda Cuba —</option>
          <?php foreach (province_options() as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= $fProv === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; ?>
        </select>
      </div>
      <div>
        <label class="f" style="font-size:12px">Municipio</label>
        <select class="input" name="muni" id="bus-muni" onchange="this.form.submit()" style="width:auto;padding:8px 12px" <?= $fProv === '' ? 'disabled' : '' ?>>
          <option value=""><?= $fProv ? 'Toda la provincia' : '—' ?></option>
          <?php if ($fProv): foreach (municipality_options($fProv) as $slug => $nm): ?>
            <option value="<?= e($slug) ?>" <?= $fMuni === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
          <?php endforeach; endif; ?>
        </select>
      </div>
    </form>
  </div>

  <?php if (!$fProv): ?>
    <div class="card empty"><div class="big"><?= icon('map-pin', 44) ?></div>Selecciona tu provincia para ver los mensajeros verificados de tu zona.</div>
  <?php elseif (!$messengerList): ?>
    <div class="card empty"><div class="big"><?= icon('search', 44) ?></div>No hay mensajeros verificados en <?= e(municipality_name($fProv, $fMuni) !== '—' ? municipality_name($fProv, $fMuni) : province_name($fProv)) ?> todavía. <?php if ($myStore || $esAdmin): ?>Publica una oferta y los mensajeros de la zona te verán.<div class="mt"><a class="btn btn-violet" href="buscar-mensajeros.php?tab=publicar">Publicar oferta</a></div><?php endif; ?></div>
  <?php else: ?>
    <p class="help mb"><?= count($messengerList) ?> mensajero(s) verificado(s) en <?= e($fProv && $fMuni ? municipality_name($fProv, $fMuni) . ' · ' . province_name($fProv) : province_name($fProv)) ?>.</p>
    <div class="grid grid-products">
      <?php foreach ($messengerList as $m): ?>
        <div class="card" style="padding:14px">
          <div class="row" style="gap:10px;align-items:center">
            <img src="<?= e($m['face_photo'] ?: 'assets/img/no-photo.svg') ?>" alt="" style="width:64px;height:64px;border-radius:50%;object-fit:cover;border:2px solid var(--violet-border)">
            <div style="flex:1;min-width:0">
              <b><?= e($m['full_name']) ?></b>
              <div class="help"><?= e(province_name($m['province'])) ?><?= $m['municipality'] ? ' · ' . e(municipality_name($m['province'], $m['municipality'])) : '' ?></div>
              <span class="badge b-info"><?= e(['bicicleta' => '🚲 Bicicleta', 'motocicleta' => '🛵 Moto', 'automovil' => '🚗 Auto', 'a_pie' => '🚶 A pie'][$m['vehicle']] ?? $m['vehicle']) ?></span>
            </div>
          </div>
          <div class="mt" style="display:flex;gap:6px;flex-wrap:wrap">
            <a class="btn btn-outline btn-sm" href="ver-mensajero.php?id=<?= (int)$m['id'] ?>"><?= icon('eye', 14) ?> Ver perfil KYC</a>
            <a class="btn btn-violet btn-sm" href="tel:<?= e($m['phone']) ?>"><?= icon('phone', 14) ?> Llamar</a>
          </div>
        </div>
      <?php endforeach; ?>
    </div>
  <?php endif; ?>

<?php elseif ($tab === 'publicar' && ($myStore || $esAdmin)): ?>
  <div class="card" style="max-width:640px">
    <h2 style="color:var(--violet-dark);font-size:18px"><?= icon('megaphone', 20) ?> Publicar oferta de mensajería</h2>
    <p class="help mb">Los mensajeros verificados de la zona recibirán una notificación automática.</p>
    <form method="post" class="form">
      <?= csrf_field() ?>
      <input type="hidden" name="accion" value="publicar_oferta">
      <div><label class="f">Título *</label>
        <input class="input" name="title" required placeholder="Ej: Mensajero para repartir pedidos en El Vedado"></div>
      <div><label class="f">Descripción</label>
        <textarea class="input" name="description" placeholder="Horario, frecuencia, tipo de paquetes, zona exacta…"></textarea></div>
      <div class="row" style="gap:12px;align-items:flex-start">
        <div style="flex:1;min-width:160px"><label class="f">Provincia *</label>
          <select class="input" name="province" id="pub-province" required onchange="fillPubMunis(this.value)">
            <option value="">— Selecciona —</option>
            <?php foreach (province_options() as $slug => $nm): ?>
              <option value="<?= e($slug) ?>" <?= ($myStore['province'] ?? '') === $slug ? 'selected' : '' ?>><?= e($nm) ?></option>
            <?php endforeach; ?>
          </select>
        </div>
        <div style="flex:1;min-width:160px"><label class="f">Municipio</label>
          <select class="input" name="municipality" id="pub-municipality">
            <option value="">— Toda la provincia —</option>
          </select>
        </div>
      </div>
      <div><label class="f">Pago por entrega (CUP, opcional)</label>
        <input class="input" type="number" name="pay_cup" min="0" step="10" placeholder="Ej: 200"></div>
      <button class="btn btn-violet" type="submit"><?= icon('send', 16) ?> Publicar oferta</button>
    </form>
  </div>

<?php elseif ($tab === 'mis-ofertas' && ($myStore || $esAdmin)): ?>
  <?php if (!$misOfertas): ?>
    <div class="card empty"><div class="big"><?= icon('megaphone', 44) ?></div>Todavía no has publicado ofertas de mensajería.<div class="mt"><a class="btn btn-violet" href="buscar-mensajeros.php?tab=publicar">Publicar oferta</a></div></div>
  <?php else: foreach ($misOfertas as $o):
    // Postulaciones de esta oferta
    $st = db()->prepare('SELECT a.*, m.full_name, m.face_photo, m.province, m.municipality, m.vehicle, m.phone, u.email FROM messenger_applications a JOIN messengers m ON m.id = a.messenger_id JOIN users u ON u.id = m.user_id WHERE a.offer_id = ? ORDER BY (a.status="pendiente") DESC, a.id DESC');
    $st->execute([(int)$o['id']]);
    $apps = $st->fetchAll();
  ?>
    <div class="card mb">
      <div class="row-between">
        <div>
          <b style="font-size:16px"><?= e($o['title']) ?></b>
          <span class="badge <?= $o['status'] === 'abierta' ? 'b-ok' : 'b-warn' ?>"><?= $o['status'] === 'abierta' ? 'Abierta' : 'Cerrada' ?></span>
          <?php if ($o['pendientes'] > 0): ?><span class="badge b-info"><?= (int)$o['pendientes'] ?> postulación(es) nueva(s)</span><?php endif; ?>
          <div class="help"><?= icon('map-pin', 13) ?> <?= e(province_name($o['province'])) ?><?= $o['municipality'] ? ' · ' . e(municipality_name($o['province'], $o['municipality'])) : '' ?> · <?= e(fdate($o['created_at'])) ?></div>
        </div>
        <?php if ($o['status'] === 'abierta'): ?>
          <form method="post"><?= csrf_field() ?>
            <input type="hidden" name="accion" value="cerrar_oferta">
            <input type="hidden" name="offer_id" value="<?= (int)$o['id'] ?>">
            <button class="btn btn-outline btn-sm" type="submit" onclick="return confirmDel('¿Cerrar esta oferta?')">Cerrar oferta</button>
          </form>
        <?php endif; ?>
      </div>
      <?php if (!empty($o['description'])): ?><p class="mt" style="margin-bottom:10px"><?= e($o['description']) ?></p><?php endif; ?>

      <?php if (!$apps): ?>
        <p class="muted mt">Sin postulaciones todavía.</p>
      <?php else: ?>
        <h3 style="font-size:14px;margin-top:14px"><?= icon('users', 16) ?> Postulaciones (<?= count($apps) ?>)</h3>
        <?php foreach ($apps as $a): ?>
          <div class="card mt" style="border:1px solid var(--violet-border);padding:12px">
            <div class="row" style="gap:10px;align-items:flex-start">
              <img src="<?= e($a['face_photo'] ?: 'assets/img/no-photo.svg') ?>" alt="" style="width:48px;height:48px;border-radius:50%;object-fit:cover">
              <div style="flex:1;min-width:0">
                <b><?= e($a['full_name']) ?></b>
                <span class="badge <?= $a['status'] === 'pendiente' ? 'b-info' : ($a['status'] === 'aceptada' ? 'b-ok' : 'b-warn') ?>"><?= ucfirst($a['status']) ?></span>
                <div class="help"><?= e(province_name($a['province'])) ?><?= $a['municipality'] ? ' · ' . e(municipality_name($a['province'], $a['municipality'])) : '' ?> · 📞 <?= e($a['phone']) ?></div>
                <?php if (!empty($a['message'])): ?><p class="help" style="margin-top:6px;font-style:italic">"<?= e($a['message']) ?>"</p><?php endif; ?>
              </div>
            </div>
            <div class="row mt" style="gap:6px">
              <a class="btn btn-outline btn-sm" href="ver-mensajero.php?id=<?= (int)$a['messenger_id'] ?>"><?= icon('eye', 14) ?> Ver perfil KYC completo</a>
              <?php if ($a['status'] === 'pendiente'): ?>
                <form method="post" style="display:inline"><?= csrf_field() ?>
                  <input type="hidden" name="accion" value="decidir_postulacion">
                  <input type="hidden" name="application_id" value="<?= (int)$a['id'] ?>">
                  <input type="hidden" name="decision" value="aceptar">
                  <button class="btn btn-violet btn-sm" type="submit" onclick="return confirmDel('¿Aceptar a este mensajero?')"><?= icon('check', 14) ?> Aceptar</button>
                </form>
                <form method="post" style="display:inline"><?= csrf_field() ?>
                  <input type="hidden" name="accion" value="decidir_postulacion">
                  <input type="hidden" name="application_id" value="<?= (int)$a['id'] ?>">
                  <input type="hidden" name="decision" value="rechazar">
                  <button class="btn btn-red btn-sm" type="submit"><?= icon('x', 14) ?> Rechazar</button>
                </form>
              <?php endif; ?>
            </div>
          </div>
        <?php endforeach; ?>
      <?php endif; ?>
    </div>
  <?php endforeach; endif; ?>
<?php endif; ?>

<script>
const CUBA_MUNIS_BUS = <?= json_encode(array_map(fn($p) => $p['municipalities'], cuba_provinces())) ?>;
function fillPubMunis(prov) {
  const sel = document.getElementById('pub-municipality');
  if (!sel) return;
  sel.innerHTML = '<option value="">— Toda la provincia —</option>';
  const munis = CUBA_MUNIS_BUS[prov] || {};
  for (const [slug, name] of Object.entries(munis)) {
    const o = document.createElement('option'); o.value = slug; o.textContent = name;
    sel.appendChild(o);
  }
}
(function(){ const p = document.getElementById('pub-province'); if (p && p.value) fillPubMunis(p.value); })();
</script>

<?php include __DIR__ . '/includes/footer.php'; ?>
