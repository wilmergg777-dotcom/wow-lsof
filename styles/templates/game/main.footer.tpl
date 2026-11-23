{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Footer del Juego
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Estilo mínimo para #footer con variables del design system
     - Google Analytics intacto ({if $ga_active})
     - Debug intacto ({if $debug == 1})
     - Cierre de body/html intacto
   ═══════════════════════════════════════════════ *}

<style>
/* ═══ Footer del juego (AstroIO v3.0) ═══ */
#footer {
    margin-top: 20px;
    padding: 16px 20px;
    border-top: 1px solid var(--border-color, #1e293b);
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 12px;
    color: var(--text-muted, #94a3b8);
    text-align: center;
    background: transparent;
}

#footer a {
    color: var(--accent-cyan, #00e0ff);
    text-decoration: none;
    transition: 0.2s ease;
}

#footer a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

.clear {
    clear: both;
    height: 0;
    line-height: 0;
    overflow: hidden;
}
</style>

<div class="clear"></div>
<div id="footer">
	{if $ga_active}
	<script type="text/javascript">
	var _gaq = _gaq || [];
	_gaq.push(['_setAccount', '{$ga_key}']);
	_gaq.push(['_trackPageview']);

	(function() {
	var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	})();
	</script>
	{/if}
	{if $debug == 1}
	<script type="text/javascript">
	onerror = handleErr;
	</script>
	{/if}
</div>

{* ═══════════ ASTROIO v4.0 — CHAT FLOTANTE NATIVO (mockup8_3/8_4) ═══════════
   Botón flotante: SIN CAMBIOS (aprobado).
   Panel: ya NO usa el iframe del chat viejo — renderiza los mensajes
   nativamente con el estilo nuevo: pestañas General/Alianza, avatares
   circulares, nombres de colores, input y botones Telegram/Ver alianza.
   Backend nuevo: game.php?page=chat&action=messages (JSON) y action=send. ═══════════ *}
{literal}
<style>
/* ═══ ASTROIO v4.0 — chat flotante nativo (prefijo aiofc-) ═══ */
body.popup .aiofc-fab, body.popup .aiofc-pop, body#chat .aiofc-fab, body#chat .aiofc-pop { display:none !important }
.aiofc-fab { position:fixed; bottom:20px; right:20px; width:56px; height:56px; border-radius:50%; border:1px solid rgba(0,224,255,.5); background:linear-gradient(135deg,#0066cc,#0099ff); cursor:pointer; z-index:9999; display:flex; align-items:center; justify-content:center; box-shadow:0 8px 26px rgba(0,224,255,.35); transition:.2s ease; padding:0 }
.aiofc-fab:hover { transform:scale(1.06); box-shadow:0 10px 32px rgba(0,224,255,.5) }
.aiofc-fab img { width:30px; height:30px; object-fit:contain; filter:drop-shadow(0 0 6px rgba(0,224,255,.6)) }
.aiofc-badge { position:absolute; top:-5px; right:-5px; min-width:18px; height:18px; border-radius:9px; background:#ef4444; color:#fff; font-size:10px; font-weight:900; display:flex; align-items:center; justify-content:center; border:2px solid #0A1220; padding:0 4px; box-sizing:border-box }
.aiofc-badge[hidden] { display:none }

/* ═══ Panel nativo (estilo mockup8_3/8_4) ═══ */
.aiofc-pop { position:fixed; bottom:88px; right:20px; width:min(340px,calc(100vw - 24px)); background:rgba(10,14,22,.97); border:1px solid rgba(0,224,255,.28); border-radius:14px; z-index:9999; box-shadow:0 18px 50px rgba(0,0,0,.65); overflow:hidden; backdrop-filter:blur(10px); -webkit-backdrop-filter:blur(10px); font-family:'Segoe UI',Roboto,sans-serif }
.aiofc-pop[hidden] { display:none }
.aiofc-head { display:flex; align-items:center; gap:8px; padding:10px 12px; border-bottom:1px solid rgba(30,41,59,.9); background:rgba(0,224,255,.06) }
.aiofc-tabs { display:flex; gap:6px; align-items:center }
.aiofc-tab { border:1px solid #1e293b; background:rgba(255,255,255,.04); color:#94a3b8; font-weight:700; font-size:11px; border-radius:9px; padding:6px 10px; cursor:pointer; display:flex; align-items:center; gap:6px; text-transform:none; letter-spacing:0; font-family:inherit; white-space:nowrap }
.aiofc-tab[hidden] { display:none }
.aiofc-tab.on { border-color:rgba(0,224,255,.55); background:rgba(0,224,255,.12); color:#fff }
.aiofc-tab .aiofc-ic { width:12px; height:12px; fill:currentColor; flex:0 0 auto }
.aiofc-allyname { color:#c4b5fd; font-weight:800 }
.aiofc-tag { min-width:16px; height:16px; border-radius:8px; background:#ef4444; color:#fff; font-size:9px; font-weight:900; display:inline-flex; align-items:center; justify-content:center; padding:0 4px }
.aiofc-tag[hidden] { display:none }
.aiofc-grow { flex:1 }
.aiofc-close { background:none; border:none; color:#94a3b8; font-size:14px; cursor:pointer; padding:2px 6px; text-transform:none; box-shadow:none; font-family:inherit }
.aiofc-close:hover { color:#fff; box-shadow:none; transform:none }

/* ═══ Mensajes ═══ */
.aiofc-msgs { height:250px; overflow-y:auto; padding:12px 12px; display:flex; flex-direction:column; gap:10px; background:rgba(2,6,12,.5); scrollbar-width:thin; scrollbar-color:#243447 transparent }
.aiofc-row { display:flex; gap:9px; align-items:flex-start; text-align:left; animation:aiofc_in .18s ease }
@keyframes aiofc_in { from { opacity:0; transform:translateY(3px) } to { opacity:1; transform:none } }
.aiofc-av { flex:0 0 auto; width:26px; height:26px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:900; color:#06121f; box-shadow:0 0 8px rgba(0,0,0,.4) }
.aiofc-msgbox { min-width:0; flex:1 }
.aiofc-meta { display:flex; align-items:baseline; gap:6px }
.aiofc-name { font-size:12px; line-height:1.2 }
.aiofc-allyprefix { color:#8b5cf6; font-size:10px; font-weight:800; white-space:nowrap }
.aiofc-time { margin-left:auto; color:#64748b; font-size:9px; white-space:nowrap }
.aiofc-text { color:#e2e8f0; font-size:12.5px; line-height:1.35; overflow-wrap:break-word; white-space:pre-wrap; margin-top:1px }
.aiofc-sys { text-align:center; color:#64748b; font-size:11px; padding:4px 0 }

/* ═══ Input ═══ */
.aiofc-inputrow { display:flex; gap:8px; padding:10px 12px; border-top:1px solid rgba(30,41,59,.9); background:rgba(10,18,32,.8); align-items:center }
.aiofc-input { flex:1; min-width:0; background:rgba(2,6,12,.7); border:1px solid #243447; border-radius:10px; color:#e2e8f0; font-size:12.5px; padding:9px 11px; outline:none; font-family:inherit; text-align:left; box-shadow:none; text-transform:none; letter-spacing:0 }
.aiofc-input:focus { border-color:rgba(0,224,255,.6); box-shadow:0 0 0 2px rgba(0,224,255,.12) }
.aiofc-input::placeholder { color:#5b6b7f; text-transform:none }
.aiofc-send { flex:0 0 auto; width:34px; height:34px; border-radius:50%; border:none; background:linear-gradient(135deg,#0066cc,#0099ff); color:#fff; cursor:pointer; display:flex; align-items:center; justify-content:center; padding:0; box-shadow:0 4px 12px rgba(0,150,255,.35) }
.aiofc-send svg { width:15px; height:15px; fill:#fff }
.aiofc-send:hover { box-shadow:0 0 12px rgba(0,224,255,.55) }

/* ═══ Pie: Telegram + Ver alianza ═══ */
.aiofc-foot { display:flex; gap:8px; padding:9px 12px; border-top:1px solid rgba(30,41,59,.9); background:rgba(2,6,12,.4) }
.aiofc-wa, .aiofc-va { flex:1; text-align:center; border-radius:9px; padding:7px 10px; font-size:12px; font-weight:700; text-decoration:none !important; text-transform:none; letter-spacing:0; transition:.15s ease; font-family:inherit }
.aiofc-wa { background:rgba(37,99,235,.22); border:1px solid rgba(59,130,246,.45); color:#dbeafe !important }
.aiofc-wa:hover { background:rgba(37,99,235,.35); color:#fff !important; box-shadow:none; transform:none }
.aiofc-va { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.35); color:#ff8fa3 !important }
.aiofc-va:hover { background:rgba(239,68,68,.22); color:#fff !important; box-shadow:none; transform:none }

@media (max-width:760px) {
  .aiofc-fab { bottom:14px; right:14px; width:50px; height:50px }
  .aiofc-fab img { width:26px; height:26px }
  .aiofc-badge { top:-4px; right:-4px }
  .aiofc-pop { bottom:74px; right:12px; width:calc(100vw - 24px) }
  .aiofc-msgs { height:42vh }
}
</style>
{/literal}
<div id="aiofc-fab" class="aiofc-fab" title="Chat">
	<img src="{$dpath}images/icons8-aplicación-telegrama-48.png" alt="Chat">
	<span class="aiofc-badge" id="aiofc-badge" hidden>0</span>
</div>
<div id="aiofc-pop" class="aiofc-pop" hidden>
	<div class="aiofc-head">
		<div class="aiofc-tabs">
			<button type="button" class="aiofc-tab on" id="aiofc-tab-gen">
				<svg class="aiofc-ic" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M20 2H4a2 2 0 0 0-2 2v18l4-4h14a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2z"/></svg>
				General <span class="aiofc-tag" id="aiofc-tag-gen" hidden>0</span>
			</button>
			<button type="button" class="aiofc-tab" id="aiofc-tab-ally">
				<span class="aiofc-allyname">Alianza <span id="aiofc-allytag"></span></span> <span class="aiofc-tag" id="aiofc-tag-ally" hidden>0</span>
			</button>
		</div>
		<div class="aiofc-grow"></div>
		<button type="button" class="aiofc-close" id="aiofc-close">✕</button>
	</div>
	<div class="aiofc-msgs" id="aiofc-msgs"></div>
	<form class="aiofc-inputrow" id="aiofc-form" autocomplete="off">
		<input class="aiofc-input" id="aiofc-input" type="text" maxlength="300" autocomplete="off" placeholder="Escribe un mensaje al servidor...">
		<button class="aiofc-send" type="submit" title="Enviar">
			<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M2.01 21 23 12 2.01 3 2 10l15 2-15 2z"/></svg>
		</button>
	</form>
	<div class="aiofc-foot">
		<a class="aiofc-wa" href="https://t.me/+FwdrSAJU5rA5Yzcx" target="_blank" rel="noopener noreferrer">💬 Telegram</a>
		<a class="aiofc-va" href="game.php?page=alliance">Ver alianza</a>
	</div>
</div>
<script type="text/javascript">
{literal}
(function () {
	var lastTab = 'gen';
	var unread  = { latest: {gen:0, ally:0}, count: {gen:0, ally:0}, hasAlly: false };
	var latest  = { gen: 0, ally: 0 };
	var fab  = document.getElementById('aiofc-fab');
	var pop  = document.getElementById('aiofc-pop');
	var frame = null;
	var tGen  = document.getElementById('aiofc-tab-gen');
	var tAlly = document.getElementById('aiofc-tab-ally');
	var tagG  = document.getElementById('aiofc-tag-gen');
	var tagA  = document.getElementById('aiofc-tag-ally');
	var badge = document.getElementById('aiofc-badge');
	var msgs  = document.getElementById('aiofc-msgs');
	var input = document.getElementById('aiofc-input');
	var form  = document.getElementById('aiofc-form');
	var allyTagEl = document.getElementById('aiofc-allytag');
	var sending = false;
	var palette = ['#59d6ff', '#8b5cf6', '#fbbf24', '#4aff88', '#ff6b81', '#f97316', '#a78bfa', '#34d399', '#f472b6', '#38bdf8'];

	function colorFor(name) {
		var h = 0, i;
		for (i = 0; i < String(name).length; i++) { h = (h * 31 + String(name).charCodeAt(i)) >>> 0; }
		return palette[h % palette.length];
	}
	function addMessage(m) {
		var stick = msgs.scrollTop + msgs.clientHeight >= msgs.scrollHeight - 40;
		var row = document.createElement('div'); row.className = 'aiofc-row';
		var av = document.createElement('span'); av.className = 'aiofc-av';
		av.style.background = colorFor(m.name);
		av.textContent = String(m.name || '?').charAt(0).toUpperCase();
		var box = document.createElement('div'); box.className = 'aiofc-msgbox';
		var meta = document.createElement('div'); meta.className = 'aiofc-meta';
		var nm = document.createElement('b'); nm.className = 'aiofc-name';
		nm.style.color = m.staff ? '#fbbf24' : colorFor(m.name);
		nm.textContent = m.name;
		meta.appendChild(nm);
		if (lastTab === 'ally' && allyTagEl.textContent) {
			var tg = document.createElement('span'); tg.className = 'aiofc-allyprefix';
			tg.textContent = allyTagEl.textContent; meta.appendChild(tg);
		}
		var tm = document.createElement('span'); tm.className = 'aiofc-time'; tm.textContent = m.time;
		meta.appendChild(tm);
		var tx = document.createElement('div'); tx.className = 'aiofc-text'; tx.textContent = m.text;
		box.appendChild(meta); box.appendChild(tx);
		row.appendChild(av); row.appendChild(box);
		msgs.appendChild(row);
		if (stick || m.own) { msgs.scrollTop = msgs.scrollHeight; }
	}
	function systemLine(text) {
		var d = document.createElement('div'); d.className = 'aiofc-sys';
		d.textContent = text; msgs.appendChild(d); msgs.scrollTop = msgs.scrollHeight;
	}
	function loadMessages(reset) {
		if (pop.hidden) { return; }
		var after = reset ? 0 : latest[lastTab];
		fetch('game.php?page=chat&action=messages&channel=' + lastTab + '&after=' + after, { credentials: 'same-origin' })
			.then(function (r) { return r.json(); })
			.then(function (d) {
				if (!d || !d.ok) { return; }
				if (lastTab === 'ally' && d.allyTag) { allyTagEl.textContent = '[' + d.allyTag + ']'; }
				if (reset) { msgs.innerHTML = ''; latest[lastTab] = 0; }
				var list = d.messages || [];
				for (var i = 0; i < list.length; i++) {
					addMessage(list[i]);
					latest[lastTab] = Math.max(latest[lastTab], list[i].id);
				}
				if (reset && !list.length) { systemLine('Aún no hay mensajes. ¡Escribe el primero!'); }
			})
			.catch(function () {});
	}
	function markRead(t) {
		var latestId = unread.latest[t] || 0;
		if (latestId > 0) { try { localStorage.setItem('aiofc_last_' + t, String(latestId)); } catch (e) {} }
		unread.count[t] = 0;
		render();
	}
	function openTab(t) {
		lastTab = t;
		tGen.classList.toggle('on', t === 'gen');
		tAlly.classList.toggle('on', t === 'ally');
		input.placeholder = t === 'gen' ? 'Escribe un mensaje al servidor...' : 'Escribe un mensaje a la alianza...';
		loadMessages(true);
		markRead(t);
	}
	function render() {
		tAlly.hidden = !unread.hasAlly; /* sin alianza no se muestra la pestaña */
		tagG.textContent = unread.count.gen;
		tagG.hidden = !(unread.count.gen > 0);
		tagA.textContent = unread.count.ally;
		tagA.hidden = !(unread.count.ally > 0);
		var total = unread.count.gen + unread.count.ally;
		badge.textContent = total;
		badge.hidden = !(total > 0);
	}
	function poll() {
		var g = 0, a = 0;
		try {
			g = parseInt(localStorage.getItem('aiofc_last_gen') || '0', 10);
			a = parseInt(localStorage.getItem('aiofc_last_ally') || '0', 10);
		} catch (e) {}
		fetch('game.php?page=chat&action=unread&genLast=' + g + '&allyLast=' + a, { credentials: 'same-origin' })
			.then(function (r) { return r.json(); })
			.then(function (d) {
				unread.latest.gen = d.latestGen || 0;
				unread.latest.ally = d.latestAlly || 0;
				unread.count.gen = d.gen || 0;
				unread.count.ally = (d.hasAlly ? (d.ally || 0) : 0);
				unread.hasAlly = !!d.hasAlly;
				if (!pop.hidden) { markRead(lastTab); } /* el chat abierto marca la sección activa como leída */
				render();
			})
			.catch(function () {});
	}
	function pollMsgs() { if (!pop.hidden) { loadMessages(false); } }
	function sendMessage(text) {
		if (sending) { return; }
		sending = true;
		var fd = new FormData();
		fd.append('channel', lastTab);
		fd.append('text', text);
		fetch('game.php?page=chat&action=send', { method: 'POST', credentials: 'same-origin', body: fd })
			.then(function (r) { return r.json(); })
			.then(function (d) {
				if (d && d.ok) { input.value = ''; loadMessages(false); }
				else { systemLine('⚠ No se pudo enviar el mensaje.'); }
			})
			.catch(function () { systemLine('⚠ No se pudo enviar el mensaje.'); })
			.then(function () { sending = false; });
	}
	fab.addEventListener('click', function () {
		pop.hidden = !pop.hidden;
		if (!pop.hidden) { openTab(lastTab); setTimeout(function () { input.focus(); }, 60); }
	});
	document.getElementById('aiofc-close').addEventListener('click', function () { pop.hidden = true; });
	tGen.addEventListener('click', function () { if (lastTab !== 'gen') { openTab('gen'); } });
	tAlly.addEventListener('click', function () { if (lastTab !== 'ally') { openTab('ally'); } });
	form.addEventListener('submit', function (ev) {
		ev.preventDefault();
		var text = input.value.trim();
		if (text) { sendMessage(text); }
	});
	poll();
	setInterval(poll, 30000); /* consulta los no leídos cada 30 s */
	setInterval(pollMsgs, 4000); /* refresca los mensajes del canal abierto cada 4 s */
})();
{/literal}
</script>
</body>
</html>