{block name="title" prepend}{$LNG.fcm_info}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/info.redirectPost.tpl === *}
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
   AstroIO v3.0 — Redirección POST (info)
   Prefijo: .astrorp_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px (panel) / 8px (botón)
     - Variables --bg-card / --accent-cyan unificadas
     - Form, postFields, noscript y auto-submit intactos
     - .table519 preservada
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

.astrorp_wrap {
    max-width: 700px;
    margin: 80px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrorp_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astrorp_body {
    padding: 20px 24px;
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.7;
}

/* ═══ Tabla table519 (preservada) ═══ */
.astrorp_table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
}

.astrorp_table tr > td {
    padding: 0;
    color: var(--text-main);
    vertical-align: top;
}

/* ═══ Mensaje ═══ */
.astrorp_message {
    color: var(--text-main);
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0 0 16px;
    padding: 12px 16px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 8px;
}

.astrorp_message p {
    margin: 0;
}

/* ═══ Botón Continuar (noscript) ═══ */
.astrorp_noscript {
    text-align: center;
    padding: 10px;
}

.astrorp_noscript button {
    display: inline-block;
    padding: 8px 22px;
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrorp_noscript button:hover {
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%);
}

.astrorp_noscript button:active {
    transform: translateY(0);
}

/* ═══ Responsive ═══ */
@media (max-width: 768px) {
    .astrorp_wrap {
        margin-top: 70px;
        padding: 0 6px;
    }
    .astrorp_body {
        padding: 16px 14px;
    }
    .astrorp_noscript button {
        width: 100%;
        text-align: center;
    }
}
</style>

<div class="container astrorp_wrap">
    <div class="panel panel-default astrorp_panel">
        <div class="panel-body astrorp_body">

            <form action="{$url}" method="post" id="redirectPostForm">
                <table class="table519 astrorp_table">
                    <tr>
                        <td><p class="astrorp_message">{$LNG.redirectPostMessage}</p></td>
                    </tr>
                </table>
                {foreach $postFields as $key => $value}
                    <input type="hidden" name="{$key}" value="{$value}">
                {/foreach}
                <noscript>
                    <div class="astrorp_noscript">
                        <button type="submit">Continuar</button>
                    </div>
                </noscript>
            </form>

        </div>
    </div>
</div>

<script>document.getElementById('redirectPostForm').submit();</script>
{/block}