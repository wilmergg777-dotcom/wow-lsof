<?php
/** Registro de cuenta nueva. */
require_once __DIR__ . '/includes/auth.php';

if (current_user()) redirect('index.php');

$errores = [];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    csrf_check();
    if (!rate_limit('registro', 8, 3600)) {
        $errores[] = 'Demasiados registros desde esta conexión. Espera un rato.';
    } else {
        $name = trim($_POST['name'] ?? '');
        $email = strtolower(trim($_POST['email'] ?? ''));
        $phone = trim($_POST['phone'] ?? '');
        $pass = $_POST['password'] ?? '';
        $pass2 = $_POST['password2'] ?? '';

        if (mb_strlen($name) < 3) $errores[] = 'Escribe tu nombre (mínimo 3 letras).';
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) $errores[] = 'Escribe un correo electrónico válido.';
        if (mb_strlen($phone) < 8) $errores[] = 'Escribe un teléfono de contacto válido.';
        if (mb_strlen($pass) < 8) $errores[] = 'La contraseña necesita al menos 8 caracteres.';
        if ($pass !== $pass2) $errores[] = 'Las dos contraseñas no coinciden.';

        if (!$errores) {
            $st = db()->prepare('SELECT id FROM users WHERE email = ?');
            $st->execute([$email]);
            if ($st->fetch()) {
                $errores[] = 'Ya existe una cuenta con ese correo. <a href="login.php">Inicia sesión</a> o <a href="recuperar.php">recupera tu contraseña</a>.';
            } else {
                $id = register_user($name, $email, $phone, $pass);
                $st = db()->prepare('SELECT * FROM users WHERE id = ?');
                $st->execute([$id]);
                login_user($st->fetch());
                notify($id, '¡Bienvenido a KlikCuba!', 'Ya puedes comprar en toda la tienda. Cuando quieras vender, abre tu mini tienda gratis desde el menú.', 'mi-tienda.php');
                flash('¡Cuenta creada! ¡Bienvenido, ' . $name . '!', 'ok');
                redirect('index.php');
            }
        }
    }
}
$page_title = 'Crear cuenta — ' . SITE_NAME;
include __DIR__ . '/includes/header.php';
?>
<div class="form-page">
  <div class="card">
    <h1>Crear mi cuenta</h1>
    <p class="help mb">Mirar es gratis. Con cuenta puedes comprar, guardar tu carrito, seguir tus pedidos y abrir tu mini tienda.</p>
    <?php foreach ($errores as $er): ?><div class="flash flash-err"><?= $er ?></div><?php endforeach; ?>
    <form method="post" class="form">
      <?= csrf_field() ?>
      <div><label class="f">Nombre y apellidos</label>
        <input class="input" name="name" placeholder="Ej: Wilmer García" required value="<?= e($_POST['name'] ?? '') ?>"></div>
      <div><label class="f">Correo electrónico</label>
        <input class="input" type="email" name="email" placeholder="tucorreo@ejemplo.com" required value="<?= e($_POST['email'] ?? '') ?>"></div>
      <div><label class="f">Teléfono</label>
        <input class="input" name="phone" placeholder="+53 5xxx xxxx" required value="<?= e($_POST['phone'] ?? '') ?>"></div>
      <div><label class="f">Contraseña (mínimo 8)</label>
        <input class="input" type="password" name="password" minlength="8" required></div>
      <div><label class="f">Repite la contraseña</label>
        <input class="input" type="password" name="password2" minlength="8" required></div>
      <button class="btn btn-yellow" type="submit" style="width:100%">Crear mi cuenta</button>
    </form>
    <p class="mt" style="font-size:14px">¿Ya tienes cuenta? <a href="login.php"><b>Inicia sesión</b></a></p>
  </div>
</div>
<?php include __DIR__ . '/includes/footer.php'; ?>
