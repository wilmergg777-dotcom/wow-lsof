{block name="title" prepend}{$LNG.siteTitleDisclamer}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.disclamer.default.tpl === *}
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
   AstroIO v3.0 — Contacto Modernizado
   Prefijo: .astrodisc_
   Acento: 🔷 Cyan (#00e0ff) + 🟢 Verde (links)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px (panel) / 10px (cards)
     - Variables --bg-card / --accent-cyan unificadas
     - Todos los emails/URLs/estructura intactos
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-card-solid: rgba(15, 23, 42, 0.85);
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-blue:   #3b82f6;
    --accent-cyan:   #00e0ff;
    --accent-purple: #8b5cf6;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

.astrodisc_wrap {
    max-width: 1000px;
    margin: 80px auto 20px;
    padding: 0 15px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrodisc_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astrodisc_heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 13px;
    font-weight: 700;
    padding: 12px 20px;
    text-transform: uppercase;
    letter-spacing: 2px;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
}

.astrodisc_body {
    padding: 30px;
    color: var(--text-main);
}

.astrodisc_lead {
    color: var(--accent-cyan);
    font-size: 16px;
    font-weight: 700;
    margin: 0 0 10px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}

.astrodisc_body p {
    color: var(--text-main);
    font-size: 14px;
    line-height: 1.6;
    margin: 0 0 15px;
}

.astrodisc_body hr {
    border: none;
    border-top: 1px solid var(--border-color);
    margin: 25px 0;
}

/* ═══ Grid de Contactos ═══ */
.astrodisc_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-top: 20px;
}

.astrodisc_card {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 25px 20px;
    text-align: center;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
    position: relative;
    overflow: hidden;
}

.astrodisc_card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 3px;
    background: linear-gradient(90deg, transparent, var(--accent-cyan), transparent);
    opacity: 0;
    transition: opacity 0.3s ease;
}

.astrodisc_card:hover {
    transform: translateY(-5px);
    border-color: var(--accent-cyan);
    box-shadow: 0 8px 25px rgba(0, 204, 255, 0.25);
}

.astrodisc_card:hover::before {
    opacity: 1;
}

.astrodisc_role {
    display: block;
    color: var(--accent-cyan);
    font-size: 15px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    margin-bottom: 15px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
}

.astrodisc_contact-item {
    margin-bottom: 12px;
    font-size: 14px;
    color: var(--text-main);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 5px;
}

.astrodisc_contact-item span {
    font-size: 18px;
}

.astrodisc_card a {
    display: inline-block;
    color: var(--accent-green);
    text-decoration: none;
    font-weight: 500;
    padding: 6px 14px;
    background: rgba(102, 255, 153, 0.05);
    border: 1px solid rgba(102, 255, 153, 0.2);
    border-radius: 8px;
    transition: all 0.25s ease;
    word-break: break-all;
    font-size: 13px;
}

.astrodisc_card a:hover {
    background: rgba(102, 255, 153, 0.15);
    border-color: var(--accent-green);
    color: #ffffff;
    box-shadow: 0 0 12px rgba(102, 255, 153, 0.4);
    transform: translateY(-2px);
}

@media (max-width: 768px) {
    .astrodisc_wrap {
        margin-top: 70px;
        padding: 0 10px;
    }
    .astrodisc_body {
        padding: 20px 15px;
    }
    .astrodisc_grid {
        grid-template-columns: 1fr;
    }
    .astrodisc_lead {
        font-size: 14px;
    }
}
</style>

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