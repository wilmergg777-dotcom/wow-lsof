<?php
/**
 * Recuperar contraseña en 3 pasos:
 *  1) Pide el correo → genera un código de 6 dígitos (15 min de vigencia)
 *  2) Verifica el código
 *  3) Nueva contraseña (cierra todas las sesiones)
 * Modo demostración: si el servidor no tiene correo configurado,
 * el código se muestra en pantalla con un aviso.
 */
require_once __DIR__ . '/includes/auth.php';

$paso = 1;
$error = '';
$demoCode = null;
$userId = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    $accion = $_POST['accion'] ?? '';

    if ($accion === 'pedir') {
        if (!rate_limit('reset', 5, 3600)) {
            $error = 'Demasiados intentos. Espera un rato y prueba otra vez.';
        } else {
            $email = strtolower(trim($_POST['email'] ?? ''));
            $st = db()->prepare('SELECT * FROM users WHERE email = ?');
            $st->execute([$email]);
            $user = $st->fetch();
            if ($user) {
                $code = create_reset_code((int)$user['id']);
                $enviado = false;
                // Intenta enviarlo por correo si el servidor tiene la función mail()
                if (function_exists('mail') && !empty($user['email'])) {
                    $enviado = @mail($user['email'], 'Código para recuperar tu contraseña en ' . SITE_NAME,
                        'Tu código es: ' . $code . "\n\nVence en " . RESET_CODE_MINUTES . ' minutos. Si no fuiste tú, ignora este mensaje.',
                        'From: ' . SITE_NAME . ' <no-reply@violetero.cu>');
                }
                if (!$enviado && DEMO_CODES) {
                    $demoCode = $code; // Modo demostración: se muestra en pantalla
                }
                $_SESSION['reset_uid'] = (int)$user['id'];
                $paso = 2;
            } else {
                // Respuesta genérica anti-enumeración
                sec_log('reset_no_encontrado', 'Intento de recuperación con correo inexistente: ' . $email);
                flash('Si ese correo existe, te enviamos un código. Revisa también tu bandeja de correo.', 'info');
                $paso = 2;
                $_SESSION['reset_uid'] = 0;
            }
        }
    }

    if ($accion === 'verificar') {
        $userId = (int)($_SESSION['reset_uid'] ?? 0);
        $code = trim($_POST['code'] ?? '');
        if ($userId && verify_reset_code($userId, $code)) {
            $paso = 3;
        } else {
            $error = 'El código no es válido o ya venció. Pide otro código.';
            $paso = 2;
        }
    }

    if ($accion === 'cambiar') {
        $userId = (int)($_SESSION['reset_uid'] ?? 0);
        $pass = $_POST['password'] ?? '';
        $pass2 = $_POST['password2'] ?? '';
        if (mb_strlen($pass) < 8) $error = 'La contraseña necesita al menos 8 caracteres.';
        elseif ($pass !== $pass2) $error = 'Las dos contraseñas no coinciden.';
        else {
            complete_reset($userId, $pass);
            unset($_SESSION['reset_uid']);
            flash('¡Contraseña restablecida! Ya puedes entrar con tu nueva contraseña. Por seguridad cerramos todas tus sesiones.', 'ok');
            redirect('login.php');
        }
        $paso = 3;
    }
}

$page_title = 'Recuperar contraseña — ' . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="form-page">
  <div class="card">
    <h1>🔑 Recuperar mi contraseña</h1>

    <?php if ($error): ?><div class="flash flash-err"><?= e($error) ?></div><?php endif; ?>

    <?php if ($paso === 1): ?>
      <p class="help mb">Escribe el correo de tu cuenta y te damos un código de 6 dígitos para crear una contraseña nueva.</p>
      <form method="post" class="form">
        <?= csrf_field() ?>
        <input type="hidden" name="accion" value="pedir">
        <div><label class="f">Correo de la cuenta</label>
          <input class="input" type="email" name="email" placeholder="tucorreo@ejemplo.com" required autofocus></div>
        <button class="btn btn-violet" type="submit" style="width:100%">Pedir código</button>
      </form>
      <p class="mt" style="font-size:14px"><a href="login.php">← Volver a iniciar sesión</a></p>

    <?php elseif ($paso === 2): ?>
      <?php if ($demoCode): ?>
        <div class="demo-code mb">
          <div style="font-weight:700;margin-bottom:4px">MODO DEMOSTRACIÓN (sin correo configurado en el servidor)</div>
          Tu código es: <b><?= e($demoCode) ?></b>
          <div class="help mt">En producción, configura el correo del servidor y el código llegará al buzón del usuario.</div>
        </div>
      <?php endif; ?>
      <p class="help mb">Escribe el código de 6 dígitos que recibiste. Vence en <?= RESET_CODE_MINUTES ?> minutos.</p>
      <form method="post" class="form">
        <?= csrf_field() ?>
        <input type="hidden" name="accion" value="verificar">
        <div><label class="f">Código</label>
          <input class="input" name="code" placeholder="000000" maxlength="6" required autofocus style="letter-spacing:6px;font-size:20px;text-align:center"></div>
        <button class="btn btn-violet" type="submit" style="width:100%">Verificar código</button>
      </form>
      <p class="mt" style="font-size:14px"><a href="recuperar.php">Pedir otro código</a></p>

    <?php else: ?>
      <p class="help mb">Paso final: escribe tu contraseña nueva (mínimo 8 caracteres). Al guardarla se cierran todas tus sesiones abiertas.</p>
      <form method="post" class="form">
        <?= csrf_field() ?>
        <input type="hidden" name="accion" value="cambiar">
        <div><label class="f">Contraseña nueva</label>
          <input class="input" type="password" name="password" minlength="8" required autofocus></div>
        <div><label class="f">Repite la contraseña</label>
          <input class="input" type="password" name="password2" minlength="8" required></div>
        <button class="btn btn-yellow" type="submit" style="width:100%">Guardar contraseña</button>
      </form>
    <?php endif; ?>
  </div>
</div>
<?php include __DIR__ . '/includes/footer.php'; ?>
