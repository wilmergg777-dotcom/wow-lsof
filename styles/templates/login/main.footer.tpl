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