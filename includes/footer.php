<?php if (!function_exists('e')) require_once __DIR__ . '/auth.php';
$__dirName = trim(dirname($_SERVER['SCRIPT_NAME'] ?? ''), '/');
$__up = ($__dirName === 'admin') ? '../' : '';
?>
</main>
<footer class="footer">
  <div class="footer-inner">
    <div class="footer-brand">
      <img src="<?= $__up ?>assets/img/icon.svg" alt="KlikCuba" width="40" height="40">
      <div>
        <b>Klik<span style="color:var(--yellow)">Cuba</span></b>
        <p>Tu tienda online de confianza. Todo en pesos cubanos (CUP), pago en efectivo o por transferencia.</p>
      </div>
    </div>
    <div class="footer-cols">
      <div>
        <h4>Comprar</h4>
        <a href="<?= $__up ?>productos.php">Todo el catálogo</a>
        <a href="<?= $__up ?>productos.php?ofertas=1">Ofertas</a>
        <a href="<?= $__up ?>tiendas.php">Mini Tiendas</a>
        <a href="<?= $__up ?>pedidos.php">Mis Pedidos</a>
      </div>
      <div>
        <h4>Vender</h4>
        <a href="<?= $__up ?>mi-tienda.php">Abrir mi mini tienda</a>
        <a href="<?= $__up ?>vender.php">Panel del vendedor</a>
        <a href="<?= $__up ?>suscripcion.php">Suscripción</a>
      </div>
      <div>
        <h4>Ayuda</h4>
        <a href="<?= $__up ?>cuenta.php">Mi Cuenta</a>
        <a href="<?= $__up ?>wallet.php">Billetera y recargas</a>
        <a href="<?= $__up ?>recuperar.php">¿Olvidaste tu contraseña?</a>
      </div>
    </div>
  </div>
  <div class="footer-copy">© <?= date('Y') ?> <?= e(SITE_NAME) ?> — Todo en CUP. Hecho con flores violetas.</div>
</footer>
<script src="<?= $__up ?>assets/app.js"></script>
</body>
</html>
