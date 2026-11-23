{block name="title" prepend}{$LNG.fcm_info}{/block}
{block name="content"}
{* === ASTROIO v3.1 - Redirección POST (Estilo oscuro, borde naranja) === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(10, 15, 25, 0.9); border:1px solid rgba(255, 94, 0, 0.3); border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:rgba(0, 0, 0, 0.6); border-bottom:1px solid #ff5e00; color:#00e0ff; padding:8px 10px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; font-weight: 700; }
table td { padding:8px 10px; border-bottom:1px solid rgba(255,255,255,0.05); color:#cbd5e1 }
table tr:hover td { background:rgba(255, 94, 0, 0.05) }

/* Inputs blancos */
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { 
    background:#ffffff; color:#333333; 
    border:1px solid rgba(255,255,255,0.2); border-radius:6px; 
    padding:10px 12px; font-size:13px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease 
}
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { 
    outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); 
}
textarea { width:100%; resize:vertical; font-family:inherit }

/* Botones oscuros */
button, input[type=submit], input[type=button] { 
    background:#222c3c; color:#fff; 
    border:1px solid #444; border-radius:6px; 
    padding:10px 20px; font-size:13px; font-weight:700; 
    font-family:inherit; cursor:pointer; transition:.25s ease; 
    text-transform:uppercase; letter-spacing:.5px; 
}
button:hover, input[type=submit]:hover, input[type=button]:hover { 
    background:#2e3a4e; border-color:#ff5e00; 
    box-shadow:0 0 18px rgba(255, 94, 0, 0.4); transform:translateY(-2px) 
}
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }

input[type=reset] { background:#111; border-color:#333; color:#ccc; }
input[type=reset]:hover { background:#222; border-color:#555; }

select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }

/* ✅ FIX: Corregido el error de sintaxis del doble corchete */
@media (max-width:760px) { body { padding:6px; overflow-x:auto; } table { font-size:11px; } table th, table td { padding:5px 7px; } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.1 — Redirección POST (info)
   ✅ FIX: Fondo oscuro, borde naranja y sin barra azul.
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.9); /* Fondo oscuro igual al index */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --accent-cyan:   #00e0ff;
}

.astrorp_wrap {
    max-width: 700px;
    margin: 40px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrorp_panel {
    background: var(--bg-card) !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    overflow: hidden;
}

.astrorp_body {
    padding: 30px 40px;
    color: #e2e8f0 !important;
    font-size: 14px;
    line-height: 1.7;
}

/* ═══ Tabla table519 (preservada) ═══ */
.astrorp_table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
    background: transparent !important;
    border: none !important;
}

.astrorp_table tr > td {
    padding: 0 !important;
    color: #e2e8f0 !important;
    vertical-align: top;
    border: none !important;
}

/* ═══ Mensaje ═══ */
.astrorp_message {
    color: #e2e8f0 !important;
    font-size: 14px;
    line-height: 1.7;
    margin: 0 0 20px;
    padding: 15px 20px;
    background: rgba(0, 224, 255, 0.05) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-left: 3px solid var(--accent-cyan) !important;
    border-radius: 8px;
}

.astrorp_message p {
    margin: 0;
}

/* ═══ Botón Continuar (noscript) ═══ */
.astrorp_noscript {
    text-align: center;
    padding: 15px;
}

.astrorp_noscript button {
    display: inline-block;
    padding: 12px 30px;
    background: #222c3c !important;
    color: #ffffff !important;
    border: 1px solid #444 !important;
    border-radius: 6px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.astrorp_noscript button:hover {
    background: #2e3a4e !important;
    border-color: var(--border-color) !important;
    box-shadow: 0 0 18px rgba(255, 94, 0, 0.4) !important;
    transform: translateY(-2px);
}

.astrorp_noscript button:active {
    transform: translateY(0);
}

/* ═══ Responsive ═══ */
@media (max-width: 768px) {
    .astrorp_wrap {
        margin-top: 20px;
        padding: 0 6px;
    }
    .astrorp_body {
        padding: 20px 15px;
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