{* ============================================================
   ASTROIO v8.2 — FOOTER LOGIN (Versión clickeable)
   - ✅ FIX: La versión ahora es un enlace que abre el CHANGES.md.
   ============================================================ *}
</div>
<footer class="dark-blur-bg footer-container box-shadow-large">
<a class="fs-6 m-0 rounded px-2 mb-1 text-white" href="index.php?page=index" title="AstroIO">AstroIO</a> 
<a href="CHANGES.md" target="_blank" title="Ver Changelog" style="color: #00e0ff; text-decoration: none; font-weight: bold; transition: 0.2s;" onmouseover="this.style.textShadow='0 0 10px rgba(0,224,255,.7)'" onmouseout="this.style.textShadow='none'">v{$gameVersion}</a> | Conquista el universo, construye tu imperio
| <a href="index.php?page=disclamer">{$LNG.menu_disclamer|default:'Contactar'}</a>

</footer>
</div>
<div id="dialog" style="display:none;"></div>
<script>
var LoginConfig = {
    'isMultiUniverse': {$isMultiUniverse|json},
	'unisWildcast': {$unisWildcast|json},
	'basePath' : {$basepath|json}
};
</script>
{if $analyticsEnable}
<script type="text/javascript" src="http://www.google-analytics.com/ga.js"></script>
<script type="text/javascript">
try{
var pageTracker = _gat._getTracker("{$analyticsUID}");
pageTracker._trackPageview();
} catch(err) {}</script>
{/if}
</body>
</html>