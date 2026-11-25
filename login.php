<?php
/** Iniciar sesión con bloqueo tras 5 intentos fallidos. */
require_once __DIR__ . '/includes/auth.php';

if (current_user()) redirect('index.php');

$error = '';
$volver = $_GET['volver'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('login', 10, 600)) {
        $error = 'Demasiados intentos desde esta conexión. Espera 10 minutos e inténtalo otra vez.';
    } else {
        $email = trim($_POST['email'] ?? '');
        $pass = $_POST['password'] ?? '';
        $st = db()->prepare('SELECT * FROM users WHERE email = ?');
        $st->execute([$email]);
        $user = $st->fetch();

        // Respuesta genérica anti-enumeración: no se revela si el correo existe
        // Primero se comprueba el bloqueo, antes de verificar la contraseña
        if ($user && !empty($user['locked_until']) && strtotime($user['locked_until']) > time()) {
            $min = (int)ceil((strtotime($user['locked_until']) - time()) / 60);
            $error = 'Tu cuenta está bloqueada temporalmente por seguridad. Prueba en ' . $min . ' minuto' . ($min === 1 ? '' : 's') . '.';
            sec_log('login_bloqueado', 'Intento con cuenta bloqueada: ' . $email, (int)$user['id']);
        } elseif (!$user || !password_verify($pass, $user['password_hash'])) {
            if ($user) login_attempt_failed((int)$user['id']);
            sec_log('login_fallido', 'Contraseña incorrecta para ' . $email);
            $error = 'Correo o contraseña incorrectos.';
        } else {
            login_user($user);
            flash('¡Hola, ' . $user['name'] . '! Bienvenido de vuelta. 🌸', 'ok');
            $dest = $volver && str_starts_with($volver, 'http') === false && !str_contains($volver, '//') ? $volver : 'index.php';
            redirect($dest);
        }
    }
}
$page_title = 'Iniciar sesión — ' . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="form-page">
  <div class="card">
    <h1>Entrar a mi cuenta</h1>
    <?php if ($error): ?><div class="flash flash-err"><?= e($error) ?></div><?php endif; ?>
    <form method="post" class="form">
      <?= csrf_field() ?>
      <div><label class="f">Correo electrónico</label>
        <input class="input" type="email" name="email" placeholder="tucorreo@ejemplo.com" required autofocus value="<?= e($_POST['email'] ?? '') ?>"></div>
      <div><label class="f">Contraseña</label>
        <input class="input" type="password" name="password" placeholder="Tu contraseña" required></div>
      <button class="btn btn-violet" type="submit" style="width:100%">Entrar</button>
    </form>
    <div class="row mt" style="justify-content:space-between">
      <a href="recuperar.php" style="font-size:14px">¿Olvidaste tu contraseña?</a>
      <a href="registro.php" style="font-size:14px;font-weight:700">Crear cuenta →</a>
    </div>
  </div>
</div>
<?php include __DIR__ . '/includes/footer.php'; ?>
