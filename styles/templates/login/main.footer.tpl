{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/main.footer.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.2 — Footer (Login/Index)
   Prefijo: .astrofoot_
   Acento: 🔷 Cyan (#00e0ff) + 🔵 Telegram + 🟣 Discord
   ═══════════════════════════════════════════════ */

.astrofoot_wrap {
    max-width: 1100px; margin: 20px auto 0;
    padding: 16px 20px 20px;
    border-top: 1px solid var(--border-color);
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 12px;
    color: var(--text-muted);
}

.astrofoot_row {
    display: flex; align-items: center;
    justify-content: space-between;
    flex-wrap: wrap; gap: 12px;
}

.astrofoot_copy {
    color: var(--text-muted);
    font-size: 12px;
    margin: 0;
}

.astrofoot_socials {
    display: flex; gap: 10px;
    align-items: center; flex-wrap: wrap;
}

.astrofoot_btn {
    display: inline-flex; align-items: center; gap: 8px; /* Espacio entre imagen y texto */
    padding: 6px 14px; border-radius: 20px;
    font-weight: 700; font-size: 11.5px;
    text-decoration: none !important;
    transition: 0.25s ease;
    border: 1px solid transparent;
    line-height: 1;
    letter-spacing: 0.3px;
}

/* Estilo para las imágenes de los iconos */
.astrofoot_icon {
    width: 18px;
    height: 18px;
    object-fit: contain;
    display: block;
}

/* Telegram */
.astrofoot_btn--tg {
    background: linear-gradient(180deg, #0088cc 0%, #00aaee 100%);
    color: #ffffff !important;
    border-color: #00ccff;
}
.astrofoot_btn--tg:hover {
    background: linear-gradient(180deg, #00aaee 0%, #00ccff 100%);
    box-shadow: 0 0 16px rgba(0, 204, 255, 0.6);
    transform: translateY(-2px);
    color: #ffffff !important;
}

/* Discord */
.astrofoot_btn--dc {
    background: linear-gradient(180deg, #4752C4 0%, #5865F2 100%);
    color: #ffffff !important;
    border-color: #5865F2;
}
.astrofoot_btn--dc:hover {
    background: linear-gradient(180deg, #5865F2 0%, #7983F5 100%);
    box-shadow: 0 0 16px rgba(88, 101, 242, 0.6);
    transform: translateY(-2px);
    color: #ffffff !important;
}

.astrofoot_top {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 11.5px;
    transition: 0.2s ease;
}
.astrofoot_top:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

@media (max-width: 600px) {
    .astrofoot_row { flex-direction: column; text-align: center; }
    .astrofoot_socials { justify-content: center; }
}
</style>

<div class="container">
    <footer class="astrofoot_wrap">
        <div class="astrofoot_row">

            <p class="astrofoot_copy">
                <a href="#" class="astrofoot_top">Volver arriba</a>
                &nbsp;·&nbsp;
                © 2026 2Moons AstroIO
            </p>

            <div class="astrofoot_socials">

                <!-- ═══ BOTÓN TELEGRAM ═══ -->
                <a class="astrofoot_btn astrofoot_btn--tg"
                   href="https://t.me/+FwdrSAJU5rA5Yzcx"
                   target="_blank"
                   rel="noopener noreferrer">
                    <img src="styles/theme/gow/mercado/telegram.png" alt="Telegram" class="astrofoot_icon">
                    Únete a Telegram
                </a>

                <!-- ═══ BOTÓN DISCORD ═══ -->
                <a class="astrofoot_btn astrofoot_btn--dc"
                   href="https://discord.gg/bDMjbKSw9j"
                   target="_blank"
                   rel="noopener noreferrer">
                    <img src="styles/theme/gow/mercado/discord.png" alt="Discord" class="astrofoot_icon">
                    Únete a Discord
                </a>

            </div>
        </div>
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