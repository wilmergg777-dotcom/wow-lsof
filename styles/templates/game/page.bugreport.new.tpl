{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.bugreport.new.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}


{* ══════════════════════════════════════════════════════════════
   ASTRO BUG REPORT v3.0 — Nuevo Reporte (Paso 1: Categoría)
   Prefijo: .astrobug_
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Sub-cajas con borde cyan sutil + hover translateY
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - foreach, href, class, Smarty intactos
   ══════════════════════════════════════════════════════════════ *}

<style>
/* ====== Variables globales ====== */
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

.astrobug_wrap {
    max-width: 1000px;
    margin: 0 auto;
    text-align: center;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    padding: 15px;
    box-sizing: border-box;
}

/* Cabecera (glassmorphism) */
.astrobug_header {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 25px 20px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astrobug_title {
    font-size: 22px;
    font-weight: bold;
    color: #ffaa33;
    text-shadow: 0 0 14px rgba(255, 170, 51, 0.5);
    margin-bottom: 8px;
    letter-spacing: 1px;
}

.astrobug_subtitle {
    font-size: 12px;
    color: var(--text-muted);
    font-style: italic;
    margin-bottom: 8px;
}

.astrobug_step {
    display: inline-block;
    background: rgba(0, 204, 255, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.4);
    color: #00ccff;
    padding: 4px 14px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 20px;
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.4);
}

.astrobug_msg_error {
    background: rgba(255, 68, 136, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
    padding: 12px 18px;
    border-radius: 10px;
    margin-bottom: 15px;
    font-size: 13px;
    font-weight: bold;
}

/* Grid de categorías */
.astrobug_cat_grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 12px;
    margin-bottom: 20px;
}

.astrobug_cat_btn {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 20px 10px;
    text-decoration: none;
    color: var(--text-main);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
    transition: all 0.25s ease;
    cursor: pointer;
    position: relative;
    overflow: hidden;
}

.astrobug_cat_btn:hover {
    border-color: rgba(0, 204, 255, 0.5);
    background: rgba(0, 204, 255, 0.08);
    box-shadow: 0 0 20px rgba(0, 204, 255, 0.4);
    transform: translateY(-3px);
}

.astrobug_cat_emoji {
    font-size: 36px;
    line-height: 1;
    filter: drop-shadow(0 0 6px rgba(0, 224, 255, 0.4));
    transition: all 0.25s ease;
}

.astrobug_cat_btn:hover .astrobug_cat_emoji {
    transform: scale(1.15);
    filter: drop-shadow(0 0 12px rgba(0, 224, 255, 0.8));
}

.astrobug_cat_nombre {
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    color: var(--text-main);
    transition: all 0.25s ease;
}

.astrobug_cat_btn:hover .astrobug_cat_nombre {
    color: #00e0ff;
}

.astrobug_actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
}

.astrobug_btn_gris {
    background: linear-gradient(135deg, rgba(51, 68, 85, 0.9), rgba(85, 102, 119, 0.9));
    color: #fff;
    font-size: 13px;
    font-weight: bold;
    padding: 10px 24px;
    border-radius: 8px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.25s ease;
    display: inline-block;
    border: 1px solid #667788;
}
.astrobug_btn_gris:hover {
    background: linear-gradient(135deg, rgba(85, 102, 119, 0.95), rgba(102, 119, 136, 0.95));
    box-shadow: 0 0 14px rgba(100, 120, 140, 0.5);
    transform: translateY(-2px);
    color: #fff;
}
.astrobug_btn_gris:active {
    transform: translateY(0);
}

/* Responsive */
@media (max-width: 720px) {
    .astrobug_wrap { padding: 10px; }
    .astrobug_header { padding: 20px 15px; }
    .astrobug_title { font-size: 18px; }
    .astrobug_cat_grid { grid-template-columns: repeat(auto-fill, minmax(130px, 1fr)); gap: 10px; }
    .astrobug_cat_btn { padding: 15px 8px; }
    .astrobug_cat_emoji { font-size: 30px; }
    .astrobug_btn_gris { width: 100%; text-align: center; box-sizing: border-box; }
}
</style>

<div class="astrobug_wrap">

    {if $msgError}
        <div class="astrobug_msg_error">{$msgError}</div>
    {/if}

    <div class="astrobug_header">
        <div class="astrobug_step">Paso 1 de 2</div>
        <div class="astrobug_title">🐛 NUEVO REPORTE DE BUG</div>
        <div class="astrobug_subtitle">¿Dónde encontraste el bug? Seleccioná el área:</div>
    </div>

    <div class="astrobug_cat_grid">
        {foreach $categorias as $cat}
            <a href="game.php?page=bugreport&mode=newForm&cat={$cat.clave}" class="astrobug_cat_btn">
                <span class="astrobug_cat_emoji">{$cat.emoji}</span>
                <span class="astrobug_cat_nombre">{$cat.nombre}</span>
            </a>
        {/foreach}
    </div>

    <div class="astrobug_actions">
        <a href="game.php?page=bugreport" class="astrobug_btn_gris">← Cancelar</a>
    </div>

</div>

{/block}