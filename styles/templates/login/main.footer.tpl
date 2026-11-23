{* ============================================================
   ASTROIO v8.1 — FOOTER LOGIN (clon del main.footer.tpl de
   ultimateXnova): barra fija abajo-izquierda con versión y
   contacto. Cierra uk-container y #page, y conserva LoginConfig
   y el analytics del juego.
   ✅ AstroIO v8.1 — Versión dinámica leída desde CHANGES.md
   ============================================================ *}
</div>
<footer class="dark-blur-bg footer-container box-shadow-large">
<a class="fs-6 m-0 rounded px-2 mb-1 text-white" href="index.php?page=index" title="AstroIO">AstroIO</a> v{$gameVersion} | Conquista el universo, construye tu imperio
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