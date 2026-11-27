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
</body>
</html>