{block name="title" prepend}{$LNG.siteTitleDisclamer}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.disclamer.default.tpl === *}



{literal}
<style>
/* ═══ ASTROIO v8.1 — reskin nextgen (tokens del índice v8.0) ═══ */
:root {
    --nx-muted:  #9a9a9a;
    --nx-cyan:   #59d6ff;
    --nx-green:  #35ff8f;
    --nx-red:    #ff5252;
    --nx-purple: #d946ef;
    --nx-gold:   #fbbf24;
    --nx-border: rgba(255, 255, 255, 0.1);
}

.astrodisc_wrap { max-width: 760px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; font-family: 'Rajdhani', 'Segoe UI', sans-serif; }
.astrodisc_panel {
    background: rgba(0,0,0,.5); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border); border-radius: 15px;
    box-shadow: 0 0 40px rgba(0,0,0,.75); overflow: hidden;
}
.astrodisc_heading {
    display: block; background: transparent; color: #ffffff;
    font-family: 'Space Mono', monospace; font-size: 13px; font-weight: 700;
    letter-spacing: 2px; text-transform: uppercase;
    padding: 16px 20px; border-bottom: 1px solid var(--nx-border); text-shadow: none;
}
.astrodisc_body { padding: 20px 22px; color: #e2e8f0; }
.astrodisc_lead { color: #e2e8f0; font-size: 15px; line-height: 1.7; }
.astrodisc_grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin-top: 14px; }
.astrodisc_card {
    background: rgba(255,255,255,.04); border: 1px solid var(--nx-border);
    border-radius: 12px; padding: 14px 16px; transition: .2s ease;
}
.astrodisc_card:hover { border-color: rgba(255,255,255,.25); transform: translateY(-1px); }
.astrodisc_role { color: #ffffff; font-weight: 700; font-size: 15px; letter-spacing: .3px; }
.astrodisc_card a, .astrodisc_contact a { color: var(--nx-cyan); text-decoration: none; }
.astrodisc_card a:hover, .astrodisc_contact a:hover { color: #ffffff; }
.astrodisc_contact { color: var(--nx-muted); font-size: 13px; margin-top: 14px; padding-top: 12px; border-top: 1px solid var(--nx-border); }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astrodisc_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astrodisc_panel { border-radius: 12px; }
    .astrodisc_body { padding: 16px 14px !important; }
    .astrodisc_actions { text-align: center !important; }
    .astrodisc_actions .btn, .astrodisc_btn_register, .astrodisc_btn_submit { width: 100%; }
}
</style>
{/literal}

<div class="container astrodisc_wrap">
    <div class="panel panel-default astrodisc_panel">
        <div class="panel-heading astrodisc_heading">{$LNG.siteTitleDisclamer}</div>
        <div class="panel-body astrodisc_body">

            <p class="lead astrodisc_lead">Información de Contacto</p>
            <p>Si tienes problemas para conectarte al juego o necesitas ayuda, puedes contactar a nuestro equipo usando la siguiente información:</p>

            <hr>

            <div class="astrodisc_grid">
                
                <!-- Contacto 1 -->
                <div class="astrodisc_card">
                    <strong class="astrodisc_role">👨‍💻 Desarrollador</strong>
                    <div class="astrodisc_contact-item">
                        <span>📧</span>
                        <a href="mailto:wilmer777gg@gmail.com">wilmer777gg@gmail.com</a>
                    </div>
                    <div class="astrodisc_contact-item">
                        <span>💬</span>
                        <a href="https://wa.me/5358631855" target="_blank">WhatsApp: +53 58631855</a>
                    </div>
                </div>
                
                <!-- Contacto 2 -->
                <div class="astrodisc_card">
                    <strong class="astrodisc_role">👨‍💻 Desarrollador</strong>
                    <div class="astrodisc_contact-item">
                        <span>📧</span>
                        <a href="mailto:danyer9712@gmail.com">danyer9712@gmail.com</a>
                    </div>
                    <div class="astrodisc_contact-item">
                        <span>💬</span>
                        <a href="https://wa.me/5355882116" target="_blank">WhatsApp: +53 55882116</a>
                    </div>
                </div>
                
                <!-- Contacto 3 -->
                <div class="astrodisc_card">
                    <strong class="astrodisc_role">👑 Administrador</strong>
                    <div class="astrodisc_contact-item">
                        <span>📧</span>
                        <a href="mailto:ernestodeltoro41@gmail.com">ernestodeltoro41@gmail.com</a>
                    </div>
                    <div class="astrodisc_contact-item">
                        <span>💬</span>
                        <a href="https://wa.me/5354923027" target="_blank">WhatsApp: +53 54923027</a>
                    </div>
                </div>

            </div>

        </div>
    </div>
</div>

{/block}