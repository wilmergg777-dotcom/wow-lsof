<?php
/** Tarjeta de producto — espera $p (fila con photos, price_cup, old_price_cup, stock, store_name, store_slug). */
$pPhoto = photo_of($p['photos']);
$pOff = !empty($p['old_price_cup']) && (int)$p['old_price_cup'] > (int)$p['price_cup'];
$pPct = $pOff ? round((1 - $p['price_cup'] / $p['old_price_cup']) * 100) : 0;
?>
<a class="product-card" href="producto.php?id=<?= (int)$p['id'] ?>">
  <div class="ph">
    <img src="<?= e($pPhoto) ?>" alt="<?= e($p['title']) ?>" loading="lazy">
    <?php if ($pOff): ?><span class="badge b-off" style="position:absolute;top:10px;left:10px">-<?= $pPct ?>%</span><?php endif; ?>
    <?php if ((int)$p['stock'] <= 0): ?><span class="badge b-agotado" style="position:absolute;bottom:10px;left:10px">AGOTADO</span><?php endif; ?>
  </div>
  <div class="info">
    <span class="title"><?= e($p['title']) ?></span>
    <?php if ($pOff): ?>
      <div><span class="price"><?= money($p['price_cup']) ?></span> <span class="price-old"><?= money($p['old_price_cup']) ?></span></div>
    <?php else: ?>
      <div><span class="price"><?= money($p['price_cup']) ?></span></div>
    <?php endif; ?>
    <?php if (!empty($p['store_name'])): ?>
      <span class="seller-mini">Vendido por <b><?= e($p['store_name']) ?></b></span>
    <?php else: ?>
      <span class="seller-mini">Vendido por <b>KlikCuba</b></span>
    <?php endif; ?>
  </div>
</a>
