/* ═══ ASTROIO v7.1 — Selector de diseño: Fotos (por defecto) / Clásico (emojis) ═══
   El diseño por defecto usa las imágenes reales (gebaeude/{ID}.gif).
   El modo Clásico muestra el icono emoji del elemento (diseño clásico del juego).
   La preferencia se guarda en localStorage('aio_design') y se aplica como
   clase body.aio-classic en todas las páginas. */
(function() {
	'use strict';

	/* Mapa de emojis por ID de elemento (edificios, investigaciones, naves, defensas) */
	var EMOJI = {
		/* Edificios */
		1:'⛏️',2:'⛏️',3:'💧',4:'⚛️',5:'☀️',6:'🔋',7:'🏭',8:'🤖',9:'🏭',10:'🛰️',
		11:'🛰️',12:'🗄️',13:'🏛️',14:'🧪',15:'🚉',16:'🛡️',17:'🏷️',18:'🏢',21:'🏠',22:'🧲',
		23:'🚀',24:'🌄',31:'📡',33:'🏭',34:'🏦',41:'🌑',42:'🌑',43:'🛰️',44:'💠',
		/* Investigaciones */
		106:'🔭',108:'🧠',109:'🏠',110:'🚀',111:'🔥',113:'🔋',114:'🧲',115:'🧲',118:'📡',120:'🛡️',
		121:'🛰️',122:'🛰️',123:'🧲',124:'🚀',125:'🚀',126:'❄️',127:'🧭',128:'🤖',131:'🤖',132:'🧪',
		133:'🧪',135:'🏰',136:'🏰',138:'☄️',139:'☄️',140:'☄️',141:'☄️',142:'☄️',143:'☄️',
		150:'🌀',151:'💥',152:'💠',153:'💠',154:'🌀',155:'🌀',199:'🌐',
		/* Naves */
		202:'✈️',203:'🚛',204:'🚀',205:'🚀',206:'✈️',207:'🚀',208:'🚢',209:'♻️',210:'📡',211:'💣',
		212:'🎈',213:'🚀',214:'💀',215:'⚔️',216:'🚀',
		/* Defensas */
		401:'🔫',402:'🔫',403:'🔫',404:'🎯',405:'🎯',406:'🎯',407:'🛡️',408:'🛡️',
		502:'🚀',503:'🚀'
	};

	function apply() {
		var d = 'fotos';
		try { d = localStorage.getItem('aio_design') || 'fotos'; } catch (e) {}
		document.body.classList.toggle('aio-classic', d === 'clasico');
		document.querySelectorAll('.astrobd_card_img, .astrorc_card_img').forEach(function(el) {
			var m = (el.getAttribute('style') || '').match(/gebaeude\/(\d+)\.(?:gif|jpg|png)/);
			el.setAttribute('data-emoji', m && EMOJI[m[1]] ? EMOJI[m[1]] : '✨');
		});
		var bf = document.getElementById('aio_dbtn_fotos'), bc = document.getElementById('aio_dbtn_clasico');
		if (bf) bf.classList.toggle('aio_dactive', d !== 'clasico');
		if (bc) bc.classList.toggle('aio_dactive', d === 'clasico');
	}

	window.ASTROIO_setDesign = function(mode) {
		if (mode !== 'fotos' && mode !== 'clasico') mode = 'fotos';
		try { localStorage.setItem('aio_design', mode); } catch (e) {}
		apply();
	};

	if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', apply);
	else apply();
})();
