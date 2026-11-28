<?php
/**
 * Panel de administración de mensajeros (KYC).
 * El admin aprueba o rechaza los perfiles de mensajero. Solo los aprobados
 * aparecen en las búsquedas de los dueños de tienda y pueden postularse a ofertas.
 */
require_once __DIR__ . '/../includes/auth.php';
$admin = require_admin();
$page_title = 'Mensajeros — ' . SITE_NAME;
$tab = 'mensajeros';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'decidir') {
        $mid = (int)($_POST['messenger_id'] ?? 0);
        $decision = $_POST['decision'] === 'aprobar' ? 'aprobado' : 'rechazado';
        $note = mb_substr(trim($_POST['review_note'] ?? ''), 0, 300);
        $st = db()->prepare('SELECT * FROM messengers WHERE id = ?');
        $st->execute([$mid]);
        $m = $st->fetch();
        if (!$m) { flash('Ese perfil no existe.', 'err'); }
        elseif ($m['status'] === $decision) { flash('Ese perfil ya está ' . $decision . '.', 'err'); }
        else {
            db()->prepare('UPDATE messengers SET status = ?, reviewed_at = ?, review_note = ? WHERE id = ?')
                ->execute([$decision, date('Y-m-d H:i:s'), $note ?: null, $mid]);
            notify((int)$m['user_id'],
                $decision === 'aprobado' ? '¡Perfil de mensajero aprobado!' : 'Perfil de mensajero rechazado',
                $decision === 'aprobado'
                    ? 'Tu perfil de mensajero fue aprobado. Ya apareces en las búsquedas de los dueños de tienda y puedes postularte a ofertas.'
                    : 'Tu perfil de mensajero fue rechazado.' . ($note ? ' Motivo: ' . $note . '. Corrige tus datos y vuelve a enviarlo.' : ' Revisa tus datos y vuelve a enviarlo.'),
                'mensajero-kyc.php');
            sec_log('kyc_' . $decision, 'Mensajero ' . $m['full_name'] . ($note ? ': ' . $note : ''), (int)$admin['id']);
            flash($decision === 'aprobado' ? 'Perfil aprobado. El mensajero ya aparece en búsquedas.' : 'Perfil rechazado. Se le avisó con el motivo.', 'ok');
        }
        redirect('mensajeros.php');
    }
}

$filtro = $_GET['filtro'] ?? 'pendientes';
$where = "1=1";
$params = [];
if ($filtro === 'pendientes') { $where = "m.status = 'pendiente'"; }
elseif ($filtro === 'aprobados') { $where = "m.status = 'aprobado'"; }
elseif ($filtro === 'rechazados') { $where = "m.status = 'rechazado'"; }

$st = db()->prepare("SELECT m.*, u.email, u.name AS user_name FROM messengers m JOIN users u ON u.id = m.user_id WHERE $where ORDER BY m.id DESC LIMIT 200");
$st->execute($params);
$lista = $st->fetchAll();

include __DIR__ . '/admin-header.php';
?>
<h1 style="color:var(--violet-dark)"><?= icon('bike', 26) ?> Mensajeros (KYC)</h1>
<p class="muted mb">Revisa y aprueba los perfiles de mensajero. Solo los aprobados aparecen en las búsquedas y pueden postularse a ofertas.</p>

<div class="pill-tabs mb">
  <a href="mensajeros.php?filtro=pendientes" class="<?= $filtro === 'pendientes' ? 'on' : '' ?>">Pendientes</a>
  <a href="mensajeros.php?filtro=aprobados" class="<?= $filtro === 'aprobados' ? 'on' : '' ?>">Aprobados</a>
  <a href="mensajeros.php?filtro=rechazados" class="<?= $filtro === 'rechazados' ? 'on' : '' ?>">Rechazados</a>
  <a href="mensajeros.php?filtro=todos" class="<?= $filtro === 'todos' ? 'on' : '' ?>">Todos</a>
</div>

<?php if (!$lista): ?>
  <div class="card empty">No hay perfiles de mensajero en este estado.</div>
<?php else: foreach ($lista as $m): ?>
  <div class="card mb">
    <div class="row-between">
      <div>
        <b style="font-size:16px"><?= e($m['full_name']) ?></b>
        <span class="badge <?= $m['status'] === 'aprobado' ? 'b-ok' : ($m['status'] === 'pendiente' ? 'b-info' : 'b-warn') ?>"><?= ucfirst($m['status']) ?></span>
        <div class="help">CI: <?= e($m['id_number'] ?: '—') ?> · 📞 <?= e($m['phone']) ?> · <?= e($m['email'] ?: '—') ?></div>
        <div class="help"><?= e(province_name($m['province'])) ?><?= $m['municipality'] ? ' · ' . e(municipality_name($m['province'], $m['municipality'])) : '' ?> · <?= e(['bicicleta' => 'Bicicleta', 'motocicleta' => 'Moto', 'automovil' => 'Auto', 'a_pie' => 'A pie'][$m['vehicle']] ?? $m['vehicle']) ?></div>
        <div class="help">Enviado: <?= e(fdate($m['submitted_at'])) ?><?= $m['reviewed_at'] ? ' · Revisado: ' . e(fdate($m['reviewed_at'])) : '' ?></div>
      </div>
    </div>

    <?php if ($m['address']): ?><div class="row mt"><b>Dirección:</b><span><?= e($m['address']) ?></span></div><?php endif; ?>

    <div class="grid grid-cols-3 mt" style="gap:10px">
      <?php if ($m['id_front']): ?>
        <div><span class="help">Carné frente</span><br><img src="<?= e($m['id_front']) ?>" alt="" style="width:100%;max-height:160px;object-fit:cover;border-radius:8px;border:1px solid var(--violet-border)"></div>
      <?php endif; ?>
      <?php if ($m['id_back']): ?>
        <div><span class="help">Carné dorso</span><br><img src="<?= e($m['id_back']) ?>" alt="" style="width:100%;max-height:160px;object-fit:cover;border-radius:8px;border:1px solid var(--violet-border)"></div>
      <?php endif; ?>
      <?php if ($m['face_photo']): ?>
        <div><span class="help">Selfie (facial)</span><br><img src="<?= e($m['face_photo']) ?>" alt="" style="width:100%;max-height:160px;object-fit:cover;border-radius:8px;border:1px solid var(--violet-border)"></div>
      <?php endif; ?>
    </div>

    <?php if ($m['status'] === 'pendiente' || $m['status'] === 'rechazado'): ?>
      <form method="post" class="form mt"><?= csrf_field() ?>
        <input type="hidden" name="accion" value="decidir">
        <input type="hidden" name="messenger_id" value="<?= (int)$m['id'] ?>">
        <div><label class="f">Nota de revisión (visible para el mensajero si rechazas)</label>
          <input class="input" name="review_note" placeholder="Ej: La foto del carnet no se ve clara. Vuelve a subirla."></div>
        <div class="row" style="gap:8px">
          <button class="btn btn-violet" type="submit" name="decision" value="aprobar" onclick="return confirmDel('¿Aprobar este mensajero?')"><?= icon('check', 16) ?> Aprobar</button>
          <button class="btn btn-red" type="submit" name="decision" value="rechazar"><?= icon('x', 16) ?> Rechazar</button>
        </div>
      </form>
    <?php endif; ?>
  </div>
<?php endforeach; endif; ?>

<?php include __DIR__ . '/admin-footer.php'; ?>
