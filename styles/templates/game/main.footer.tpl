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

{* ═══════════ ASTROIO v3.0 — CHAT FLOTANTE: estilo, icono y lógica de este archivo ═══════════ *}
{literal}
<style>
/* ═══ ASTROIO v3.0 — burbuja de chat flotante (prefijo aiofc-) ═══ */
body.popup .aiofc-fab, body.popup .aiofc-pop, body#chat .aiofc-fab, body#chat .aiofc-pop { display:none !important }
.aiofc-fab { position:fixed; bottom:20px; right:20px; width:56px; height:56px; border-radius:50%; border:1px solid rgba(0,224,255,.5); background:linear-gradient(135deg,#0066cc,#0099ff); cursor:pointer; z-index:9999; display:flex; align-items:center; justify-content:center; box-shadow:0 8px 26px rgba(0,224,255,.35); transition:.2s ease; padding:0 }
.aiofc-fab:hover { transform:scale(1.06); box-shadow:0 10px 32px rgba(0,224,255,.5) }
.aiofc-fab img { width:30px; height:30px; object-fit:contain; filter:drop-shadow(0 0 6px rgba(0,224,255,.6)) }
.aiofc-badge { position:absolute; top:-5px; right:-5px; min-width:18px; height:18px; border-radius:9px; background:#ef4444; color:#fff; font-size:10px; font-weight:900; display:flex; align-items:center; justify-content:center; border:2px solid #0A1220; padding:0 4px; box-sizing:border-box }
.aiofc-badge[hidden] { display:none }
.aiofc-pop { position:fixed; bottom:88px; right:20px; width:min(330px,calc(100vw - 24px)); background:rgba(10,18,32,.96); border:1px solid #1e293b; border-radius:16px; z-index:9999; box-shadow:0 18px 50px rgba(0,0,0,.6); overflow:hidden; backdrop-filter:blur(8px); -webkit-backdrop-filter:blur(8px) }
.aiofc-pop[hidden] { display:none }
.aiofc-head { display:flex; align-items:center; gap:8px; padding:10px 12px; border-bottom:1px solid rgba(30,41,59,.8); background:rgba(0,224,255,.05) }
.aiofc-head img { width:18px; height:18px; object-fit:contain }
.aiofc-tabs { display:flex; gap:6px }
.aiofc-tab { border:1px solid #1e293b; background:rgba(255,255,255,.04); color:#94a3b8; font-weight:700; font-size:11px; border-radius:9px; padding:6px 10px; cursor:pointer; display:flex; align-items:center; gap:6px; text-transform:none; letter-spacing:0; font-family:inherit }
.aiofc-tab[hidden] { display:none }
.aiofc-tab.on { border-color:rgba(0,224,255,.55); background:rgba(0,224,255,.1); color:#fff }
.aiofc-tag { min-width:16px; height:16px; border-radius:8px; background:#ef4444; color:#fff; font-size:9px; font-weight:900; display:inline-flex; align-items:center; justify-content:center; padding:0 4px }
.aiofc-tag[hidden] { display:none }
.aiofc-grow { flex:1 }
.aiofc-close { background:none; border:none; color:#94a3b8; font-size:14px; cursor:pointer; padding:2px 6px; text-transform:none; box-shadow:none; font-family:inherit }
.aiofc-close:hover { color:#fff; box-shadow:none; transform:none }
.aiofc-frame { width:100%; height:340px; border:none; background:#0A1220; display:block }
@media (max-width:760px) {
  .aiofc-fab { bottom:14px; right:14px; width:50px; height:50px }
  .aiofc-fab img { width:26px; height:26px }
  .aiofc-badge { top:-4px; right:-4px }
  .aiofc-pop { bottom:74px; right:12px; width:calc(100vw - 24px) }
  .aiofc-frame { height:62vh }
}
</style>
{/literal}
<div id="aiofc-fab" class="aiofc-fab" title="Chat">
	<img src="{$dpath}images/icons8-aplicación-telegrama-48.png" alt="Chat">
	<span class="aiofc-badge" id="aiofc-badge" hidden>0</span>
</div>
<div id="aiofc-pop" class="aiofc-pop" hidden>
	<div class="aiofc-head">
		<img src="{$dpath}images/icons8-aplicación-telegrama-48.png" alt="">
		<div class="aiofc-tabs">
			<button type="button" class="aiofc-tab on" id="aiofc-tab-gen">General <span class="aiofc-tag" id="aiofc-tag-gen" hidden>0</span></button>
			<button type="button" class="aiofc-tab" id="aiofc-tab-ally">Alianza <span class="aiofc-tag" id="aiofc-tag-ally" hidden>0</span></button>
		</div>
		<div class="aiofc-grow"></div>
		<button type="button" class="aiofc-close" id="aiofc-close">✕</button>
	</div>
	<iframe class="aiofc-frame" id="aiofc-frame" title="Chat AstroIO" src="about:blank"></iframe>
</div>
<script type="text/javascript">
{literal}
(function () {
	var lastTab = 'gen';
	var unread  = { latest: {gen:0, ally:0}, count: {gen:0, ally:0}, hasAlly: false };
	var fab  = document.getElementById('aiofc-fab');
	var pop  = document.getElementById('aiofc-pop');
	var frame = document.getElementById('aiofc-frame');
	var tGen = document.getElementById('aiofc-tab-gen');
	var tAlly = document.getElementById('aiofc-tab-ally');

	function tabURL(t) {
		return t === 'gen' ? 'game.php?page=chat' : 'game.php?page=chat&action=alliance';
	}
	function render() {
		var tagG = document.getElementById('aiofc-tag-gen');
		var tagA = document.getElementById('aiofc-tag-ally');
		var badge = document.getElementById('aiofc-badge');
		tAlly.hidden = !unread.hasAlly; /* sin alianza no se muestra la pestaña */
		tagG.textContent = unread.count.gen;
		tagG.hidden = !(unread.count.gen > 0);
		tagA.textContent = unread.count.ally;
		tagA.hidden = !(unread.count.ally > 0);
		var total = unread.count.gen + unread.count.ally;
		badge.textContent = total;
		badge.hidden = !(total > 0);
	}
	function markRead(t) {
		var latest = unread.latest[t] || 0;
		if (latest > 0) { try { localStorage.setItem('aiofc_last_' + t, String(latest)); } catch (e) {} }
		unread.count[t] = 0;
		render();
	}
	function openTab(t) {
		lastTab = t;
		tGen.classList.toggle('on', t === 'gen');
		tAlly.classList.toggle('on', t === 'ally');
		frame.src = tabURL(t); /* recarga el iframe al cambiar de sección */
		markRead(t);
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
	fab.addEventListener('click', function () {
		pop.hidden = !pop.hidden;
		if (!pop.hidden) { openTab(lastTab); }
	});
	document.getElementById('aiofc-close').addEventListener('click', function () { pop.hidden = true; });
	tGen.addEventListener('click', function () { openTab('gen'); });
	tAlly.addEventListener('click', function () { openTab('ally'); });
	poll();
	setInterval(poll, 30000); /* consulta los no leídos cada 30 s */
})();
{/literal}
</script>
</body>
</html>