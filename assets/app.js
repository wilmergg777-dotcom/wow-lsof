/* Violetero — scripts pequeños */
// Carrusel de portada
(function () {
  var hero = document.querySelector('.hero');
  if (!hero) return;
  var slides = hero.querySelectorAll('.slide');
  var dots = hero.querySelectorAll('.dots button');
  var i = 0, timer;
  function show(n) {
    slides.forEach(function (s) { s.classList.remove('on'); });
    dots.forEach(function (d) { d.classList.remove('on'); });
    if (slides[n]) slides[n].classList.add('on');
    if (dots[n]) dots[n].classList.add('on');
    i = n;
  }
  function next() { show((i + 1) % Math.max(slides.length, 1)); }
  slides.forEach(function (s, n) {
    s.addEventListener('click', function (e) {
      if (e.target.closest('a')) return;
      next();
    });
  });
  dots.forEach(function (d, n) {
    d.addEventListener('click', function () { show(n); reset(); });
  });
  function reset() { clearInterval(timer); timer = setInterval(next, 6000); }
  reset();
})();

// Galería del detalle de producto
function galShow(src, el) {
  var main = document.getElementById('gal-main');
  if (main) main.src = src;
  document.querySelectorAll('.gallery-thumbs img').forEach(function (t) { t.classList.remove('on'); });
  if (el) el.classList.add('on');
}

// Métodos de pago en el checkout
function pickMethod(el, id) {
  document.querySelectorAll('.pay-method').forEach(function (m) { m.classList.remove('on'); });
  el.classList.add('on');
  document.getElementById(id).checked = true;
  var boxT = document.getElementById('box-transferencia');
  var boxC = document.getElementById('box-efectivo');
  if (boxT) boxT.style.display = id === 'transferencia' ? '' : 'none';
  if (boxC) boxC.style.display = id === 'efectivo' ? '' : 'none';
}

// Copiar al portapapeles
function copyTxt(el) {
  var txt = el.getAttribute('data-copy') || '';
  if (navigator.clipboard) navigator.clipboard.writeText(txt);
  var old = el.textContent;
  el.textContent = '¡Copiado!';
  setTimeout(function () { el.textContent = old; }, 1500);
}

// Confirmación antes de enviar (usar con onsubmit="return confirmDel('...')")
function confirmDel(msg) {
  return confirm(msg || '¿Seguro que quieres hacer esto?');
}

// Selector de fotos de galería / subidas
function togglePhoto(img, inputId) {
  img.classList.toggle('on');
  var input = document.getElementById(inputId);
  if (!input) return;
  var arr = [];
  document.querySelectorAll('#' + input.closest('form').id + ' .photo-pick img.on, #' + input.closest('form').id + ' .upload-list img').forEach(function (im) {
    if (im.getAttribute('data-src')) arr.push(im.getAttribute('data-src'));
  });
  input.value = JSON.stringify(arr);
}
function removeUpload(btn) {
  var wrap = btn.parentElement;
  var src = wrap.querySelector('img').getAttribute('data-src');
  var input = document.querySelector('#' + btn.closest('form').id + ' input[name="photos"]');
  var arr = [];
  try { arr = JSON.parse(input.value || '[]'); } catch (e) {}
  arr = arr.filter(function (x) { return x !== src; });
  input.value = JSON.stringify(arr);
  wrap.remove();
}
