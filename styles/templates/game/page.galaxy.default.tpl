{block name="title" prepend}{$LNG.lm_galaxy}{/block}
{block name="content"}

{* ============================================================
   GALAXIA 3D (rama xnova3d) — la galaxia es un visor 3D a
   pantalla completa. La tabla antigua desaparece; sus datos
   pasan a un panel HUD con DOS tablas:
     1. TABLA DE GALAXIA · POSICIONES 1-16 (del sistema actual)
     2. PUNTUACIÓN · TOP DEL UNIVERSO (%%STATPOINTS%% del juego)
   En móvil, las dos tablas cambian con pestañas.
   Acciones reales: doit()/doitAst() (galaxy.js) y fleetTable.
   Navegación sin recargar: game.php?page=galaxy&mode=fetch
   (misma base de datos que el cliente clásico).
   ============================================================ *}

{literal}
<style>
/* ====== contenedor 3D ====== */
#ag3d_app {
    position: relative; width: 100%;
    height: calc(100vh - 150px); min-height: 540px;
    background: #0a101e; border-radius: 12px; overflow: hidden;
    font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    color: #cbd5e1;
    border: 1px solid #1e293b;
}
#ag3d_app::after {
    content: ''; position: absolute; inset: 0; pointer-events: none; z-index: 30;
    background:
        repeating-linear-gradient(0deg, rgba(255,255,255,0.014) 0 1px, transparent 1px 3px),
        radial-gradient(ellipse at center, transparent 55%, rgba(5,8,16,0.55) 100%);
}
#ag3d_canvas { position: absolute; inset: 0; z-index: 1; }
#ag3d_canvas canvas { width: 100%; height: 100%; display: block; }

/* ====== topbar HUD ====== */
#ag3d_top {
    position: absolute; top: 0; left: 0; right: 0; z-index: 40;
    display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
    padding: 8px 14px;
    background: rgba(11,16,30,0.72);
    backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px);
    border-bottom: 2px solid #00ccff;
    box-shadow: 0 4px 20px rgba(0,0,0,.5);
}
#ag3d_marca { font-weight: 700; letter-spacing: 2px; font-size: 15px; color: #fff; white-space: nowrap; }
#ag3d_marca .cian { color: #00e0ff; }
#ag3d_marca .sub { font-size: 9px; letter-spacing: 3px; color: #94a3b8; font-weight: 400; margin-left: 8px; }
.ag3d_chip {
    font-family: 'Courier New', monospace; font-size: 11px; color: #fbbf24;
    background: rgba(0,0,0,.35); border: 1px solid #1e293b;
    border-radius: 8px; padding: 4px 10px; white-space: nowrap;
}
.ag3d_cnts { display: flex; gap: 12px; flex-wrap: wrap; font-size: 10.5px; color: #94a3b8; font-weight: 600; }
.ag3d_cnts b { color: #66ff99; font-family: 'Courier New', monospace; }
#ag3d_top .der { margin-left: auto; display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
.ag3d_btn {
    background: linear-gradient(180deg, #004488, #00aaff);
    border: 1px solid #00e0ff; color: #fff; cursor: pointer;
    font-size: 11px; font-weight: 700; letter-spacing: .5px;
    padding: 5px 12px; border-radius: 7px; white-space: nowrap;
    font-family: inherit; transition: all .18s;
}
.ag3d_btn:hover { box-shadow: 0 0 12px rgba(0,224,255,.5); }
.ag3d_btn-oro { background: linear-gradient(180deg, #7a5200, #b8860b); border-color: #fbbf24; }
.ag3d_toggle { display: none; }

/* ====== paneles HUD ====== */
.ag3d_panel {
    position: absolute; z-index: 35;
    background: rgba(15,23,42,0.80);
    backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);
    border: 1px solid #1e293b; border-radius: 10px;
    box-shadow: 0 4px 20px rgba(0,0,0,.5);
    padding: 12px; overflow-y: auto;
    scrollbar-width: thin; scrollbar-color: rgba(0,224,255,.35) transparent;
}
.ag3d_panel::before, .ag3d_panel::after { content: ''; position: absolute; width: 14px; height: 14px; pointer-events: none; }
.ag3d_panel::before { top: -1px; left: -1px; border-top: 2px solid #00e0ff; border-left: 2px solid #00e0ff; border-top-left-radius: 10px; }
.ag3d_panel::after { bottom: -1px; right: -1px; border-bottom: 2px solid #00e0ff; border-right: 2px solid #00e0ff; border-bottom-right-radius: 10px; }

#ag3d_pos { top: 56px; left: 12px; bottom: 12px; width: clamp(300px, 25vw, 356px); display: flex; flex-direction: column; }
#ag3d_det { top: 56px; right: 12px; width: clamp(272px, 22vw, 322px); max-height: calc(100% - 70px); }

.ag3d_pt-titulo {
    font-size: 11px; letter-spacing: 2px; color: #00e0ff;
    border-bottom: 1px solid rgba(0,204,255,.2);
    padding-bottom: 6px; margin-bottom: 8px;
    display: flex; justify-content: space-between; align-items: center; gap: 6px; flex-wrap: wrap;
}
.ag3d_pt-titulo .mono { font-family: 'Courier New', monospace; letter-spacing: 1px; }
.ag3d_orden { display: inline-flex; gap: 4px; }

/* navegación G/S */
.ag3d_nav { display: flex; flex-wrap: wrap; gap: 5px; align-items: center; margin-bottom: 10px; }
.ag3d_mini {
    background: rgba(0, 68, 136, 0.8); border: 1px solid #00e0ff; color: #fff;
    border-radius: 5px; cursor: pointer; padding: 5px 8px;
    font-size: 11px; font-weight: 700; font-family: inherit; letter-spacing: .5px;
    transition: all .15s; white-space: nowrap;
}
.ag3d_mini:hover { background: rgba(0, 119, 204, 0.9); box-shadow: 0 0 8px rgba(0,224,255,.45); }
.ag3d_mini.activo { background: #00e0ff; color: #001522; }
.ag3d_nav input {
    width: 48px; background: #000; color: #0ff; border: 1px solid #00ccff;
    border-radius: 4px; text-align: center; padding: 4px 2px;
    font-family: 'Courier New', monospace; font-size: 12px;
}
.ag3d_nav .sep { width: 6px; }
.ag3d_ir {
    background: linear-gradient(180deg, #0066cc, #0099ff);
    border: 1px solid #00e0ff; color: #fff; font-weight: 700;
    border-radius: 5px; cursor: pointer; padding: 5px 14px; font-size: 11px; letter-spacing: 1px;
    font-family: inherit;
}
.ag3d_ir:hover { box-shadow: 0 0 10px rgba(0,204,255,.5); }

/* dos tablas */
.ag3d_sub {
    font-size: 10px; letter-spacing: 1.5px; color: #00e0ff;
    margin: 6px 0 6px; display: flex; justify-content: space-between; align-items: center;
    flex-wrap: wrap; gap: 4px;
}
.ag3d_bloque { display: flex; flex-direction: column; min-height: 0; }
#ag3d_bloque_gal { flex: 1 1 auto; }
#ag3d_bloque_score { flex: 0 0 auto; margin-top: 8px; }
#ag3d_bloque_score .ag3d_twrap { flex: none; max-height: 172px; }
.ag3d_tabsmv { display: none; gap: 6px; margin-bottom: 8px; }
.ag3d_tabsmv .ag3d_mini { flex: 1; text-align: center; padding: 7px 4px; }

.ag3d_twrap {
    flex: 1; overflow: auto; border-radius: 8px; min-height: 0;
    border: 1px solid rgba(0,204,255,.15); background: rgba(0,0,0,.3);
}
table.ag3d_table { width: 100%; min-width: 292px; border-collapse: collapse; font-size: 10.5px; }
table.ag3d_table th {
    position: sticky; top: 0; z-index: 2;
    background: linear-gradient(135deg, #003366, #005599);
    color: #fff; padding: 4px 5px; font-size: 9px; letter-spacing: .5px; text-align: left;
    white-space: nowrap;
}
table.ag3d_table th:last-child, table.ag3d_table td:last-child { text-align: center; }
table.ag3d_table td { padding: 3px 4px; border-bottom: 1px solid rgba(0,204,255,.07); white-space: nowrap; }
table.ag3d_table td b { font-weight: 600; }
tr.fila { cursor: pointer; }
tr.fila:hover { background: rgba(0,204,255,.09); }
tr.sel { background: rgba(0,224,255,.14) !important; outline: 1px solid rgba(0,224,255,.4); outline-offset: -1px; }
tr.propio { box-shadow: inset 3px 0 0 #4a9eff; background: rgba(74,158,255,.10); }
td.pos { font-family: 'Courier New', monospace; color: #94a3b8; }
td.pts { text-align: right; font-family: 'Courier New', monospace; color: #fbbf24; }
td.rk { text-align: center; font-family: 'Courier New', monospace; font-size: 9px; color: #94a3b8; }
tr.vacia { cursor: pointer; }
tr.vacia td { color: #475569; font-style: italic; }
.dot { display: inline-block; width: 9px; height: 9px; border-radius: 50%; margin-right: 5px; vertical-align: middle; box-shadow: 0 0 6px currentColor; }
.tag-ally { color: #8fa3bf; font-size: 8.5px; }
.ico { font-size: 9px; margin-left: 2px; }
.tu-chip {
    font-size: 8px; letter-spacing: 1px; color: #001522; background: #4a9eff;
    border-radius: 6px; padding: 1px 5px; margin-left: 5px; font-weight: 700;
}

.ag3d_leyenda { display: flex; flex-wrap: wrap; gap: 5px 10px; padding-top: 8px; font-size: 9.5px; color: #94a3b8; }
.ag3d_leyenda i { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 3px; }
.ag3d_leyenda .ico { margin: 0 2px 0 0; }

/* panel detalle */
.kv { font-size: 12px; padding: 3px 0; display: flex; justify-content: space-between; gap: 8px; color: #e2e8f0; flex-wrap: wrap; }
.kv b { color: #00e0ff; font-family: 'Courier New', monospace; }
.kv .est { font-weight: 700; }
.acciones { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-top: 10px; }
.btn-accion {
    padding: 7px 4px; border-radius: 7px; border: 1px solid; font-size: 11px;
    cursor: pointer; background: rgba(0,0,0,.35); color: #fff; font-family: inherit; font-weight: 600;
    transition: all .15s;
}
.btn-accion:hover { filter: brightness(1.25); box-shadow: 0 0 8px rgba(0,224,255,.3); }
.acc-espia { border-color: #00e0ff; }
.acc-ataca { border-color: #ff4488; }
.acc-trans { border-color: #4aff88; }
.acc-recic { border-color: #fbbf24; }
.acc-gestion { border-color: #4a9eff; }
.acc-exped { border-color: #b06cff; }
.acc-colon { border-color: #4aff88; }
.ag3d_nota { font-size: 9.5px; color: #94a3b8; margin-top: 10px; line-height: 1.5; }
.ag3d_nota a { color: #00e0ff; text-decoration: none; }
.ag3d_back {
    display: none; width: 100%; margin-bottom: 8px;
    background: rgba(0, 68, 136, 0.8); border: 1px solid #00e0ff; color: #fff;
    border-radius: 6px; cursor: pointer; padding: 6px; font-size: 11px; font-weight: 700;
    font-family: inherit;
}

/* hint + toasts + carga */
#ag3d_hint {
    position: absolute; bottom: 12px; left: 50%; transform: translateX(-50%);
    z-index: 34; font-size: 10.5px; color: #94a3b8;
    background: rgba(11,16,30,.6); border: 1px solid #1e293b;
    padding: 5px 14px; border-radius: 14px; white-space: nowrap;
}
#ag3d_toasts { position: absolute; top: 56px; left: 50%; transform: translateX(-50%); z-index: 50; display: flex; flex-direction: column; gap: 6px; pointer-events: none; width: max-content; max-width: 92%; }
.ag3d_toast {
    background: rgba(11,16,30,.9); border: 1px solid #00e0ff; color: #fff;
    padding: 8px 18px; border-radius: 20px; font-size: 12px;
    box-shadow: 0 0 18px rgba(0,224,255,.25);
    opacity: 0; transition: opacity .3s; text-align: center;
}
.ag3d_toast.visible { opacity: 1; }
#ag3d_carga {
    position: absolute; inset: 0; z-index: 60; background: #0a101e;
    display: flex; flex-direction: column; gap: 16px; align-items: center; justify-content: center;
    color: #00e0ff; letter-spacing: 3px; font-size: 12px; transition: opacity .5s;
}
.ag3d_aro { width: 44px; height: 44px; border: 3px solid rgba(0,224,255,.2); border-top-color: #00e0ff; border-radius: 50%; animation: ag3d_girar 1s linear infinite; }
@keyframes ag3d_girar { to { transform: rotate(360deg); } }

/* formulario de misiles (overlay dentro del visor) */
#ag3d_mis {
    position: absolute; top: 64px; left: 50%; transform: translateX(-50%);
    z-index: 45; width: min(420px, 94%);
    background: rgba(255, 68, 136, 0.08);
    backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 68, 136, 0.4);
    border-radius: 10px; padding: 10px 12px; font-size: 10.5px;
}
#ag3d_mis table { width: 100%; border-collapse: collapse; }
#ag3d_mis th {
    padding: 4px 6px; background: linear-gradient(135deg, #770022, #aa0044);
    color: #fff; font-weight: 700; font-size: 10.5px; border-bottom: 1px solid #ff4488;
}
#ag3d_mis td { padding: 4px 6px; color: #cbd5e1; }
#ag3d_mis input[type="text"] {
    padding: 3px 6px; background: rgba(0,0,0,.5); border: 1px solid rgba(255,68,136,.4);
    border-radius: 6px; color: #fff; font-family: 'Courier New', monospace; width: 50px;
}
#ag3d_mis select {
    padding: 3px 8px; background: rgba(0,0,0,.5); border: 1px solid rgba(255,68,136,.4);
    border-radius: 6px; color: #fff; font-weight: 600; cursor: pointer;
}
#ag3d_mis input[type="submit"] {
    padding: 6px 18px; background: linear-gradient(135deg, rgba(170,0,68,.9), rgba(204,34,102,.9));
    border: 1px solid #ff4488; border-radius: 8px; color: #fff; font-weight: 700; cursor: pointer;
    font-family: inherit;
}

/* ====== móvil ====== */
@media (max-width: 900px) {
    #ag3d_app { height: calc(100vh - 120px); min-height: 480px; }
    .ag3d_cnts { display: none; }
    .ag3d_toggle { display: inline-block; }
    #ag3d_pos { top: auto; bottom: 8px; left: 8px; right: 8px; width: auto; max-height: 46%; }
    #ag3d_det {
        top: auto; bottom: 8px; left: 8px; right: 8px; width: auto;
        max-height: 56%; display: none;
    }
    #ag3d_app.det-open #ag3d_det { display: block; }
    #ag3d_app.det-open #ag3d_pos { display: none; }
    #ag3d_app.pos-off #ag3d_pos { display: none; }
    .ag3d_back { display: block; }
    .ag3d_tabsmv { display: flex; }
    #ag3d_app.score-mv #ag3d_bloque_gal { display: none; }
    #ag3d_app:not(.score-mv) #ag3d_bloque_score { display: none; }
    #ag3d_app.score-mv #ag3d_bloque_score { flex: 1 1 auto; margin-top: 0; }
    #ag3d_app.score-mv #ag3d_bloque_score .ag3d_twrap { flex: 1; max-height: none; }
    #ag3d_hint { display: none; }
    #ag3d_toasts { top: 96px; }
}

    /* ===== imágenes REALES del juego en el HUD (xnova3d) ===== */
    .thumb { width: 16px; height: 16px; border-radius: 50%; vertical-align: middle;
             margin: 0 4px 2px 0; border: 1px solid rgba(0,224,255,.35); }
    .det-img { width: 54px; height: 54px; border-radius: 10px; object-fit: cover;
               border: 1px solid rgba(0,224,255,.4); float: right; margin: 0 0 4px 8px; }
</style>
{/literal}

<div id="ag3d_app">

    <div id="ag3d_canvas"></div>

    <!-- ====== TOPBAR HUD ====== -->
    <div id="ag3d_top">
        <div id="ag3d_marca"><span class="cian">▲ ASTRO</span>IO<span class="sub">GALAXIA 3D</span></div>
        <span class="ag3d_chip">💰 {$astro3d.me.pts|number_format} pts · #{$astro3d.me.rank}</span>
        <div class="ag3d_cnts">
            <span>👁 <b id="elementID210">{$spyprobes|number_format}</b></span>
            <span>♻ <b id="elementID209">{$recyclers|number_format}</b></span>
            <span>♻️ <b id="elementID219">{$grecyclers|number_format}</b></span>
            <span>🚀 <b id="slots">{$maxfleetcount}</b>/{$fleetmax}</span>
            <span>💣 <b id="missiles">{$currentmip|number_format}</b></span>
        </div>
        <div class="der">
            <button class="ag3d_btn ag3d_btn-oro" id="ag3d_home" title="Ir al sistema de tu planeta">⌂ MI PLANETA [{$current_galaxy}:{$current_system}:{$current_planet}]</button>
            <button class="ag3d_btn" id="ag3d_clasico" title="Cambiar a la vista clásica (tabla) conservando galaxia:sistema">🖥 CLÁSICO</button>
            <button class="ag3d_btn ag3d_toggle" id="ag3d_tgl_pos">☰ POSICIONES</button>
            <button class="ag3d_btn ag3d_toggle" id="ag3d_tgl_det">ℹ DETALLE</button>
        </div>
    </div>

    <!-- ====== FORMULARIO DE MISILES (acción sendMissle clásica) ====== -->
    {if $action == 'sendMissle'}
    <div id="ag3d_mis">
        <form action="?page=fleetMissile" method="post">
            <input type="hidden" name="galaxy" value="{$galaxy}">
            <input type="hidden" name="system" value="{$system}">
            <input type="hidden" name="planet" value="{$planet}">
            <input type="hidden" name="type" value="{$type}">
            <table class="table569">
                <tr>
                    <th colspan="2">🚀 {$LNG.gl_missil_launch} [{$galaxy}:{$system}:{$planet}]</th>
                </tr>
                <tr>
                    <td>{$missile_count} <input type="text" name="SendMI" size="2" maxlength="7"></td>
                    <td>{$LNG.gl_objective}:
                        {html_options name=Target options=$missileSelector}
                    </td>
                </tr>
                <tr>
                    <th colspan="2" style="text-align:center;">
                        <input type="submit" value="{$LNG.gl_missil_launch_action}">
                    </th>
                </tr>
            </table>
        </form>
    </div>
    {/if}

    <!-- ====== PANEL IZQUIERDO: NAV + DOS TABLAS ====== -->
    <div class="ag3d_panel" id="ag3d_pos">
        <div class="ag3d_pt-titulo">
            <span>GALAXIA · <span class="mono" id="ag3d_tit_sistema">{$galaxy}:{$system}</span></span>
        </div>
        <div class="ag3d_nav">
            <button class="ag3d_mini" id="ag3d_gm" title="Galaxia anterior">G«</button>
            <input id="ag3d_in_g" value="{$galaxy}" inputmode="numeric" aria-label="Galaxia">
            <button class="ag3d_mini" id="ag3d_gp" title="Galaxia siguiente">G»</button>
            <span class="sep"></span>
            <button class="ag3d_mini" id="ag3d_sm" title="Sistema anterior">S«</button>
            <input id="ag3d_in_s" value="{$system}" inputmode="numeric" aria-label="Sistema">
            <button class="ag3d_mini" id="ag3d_sp" title="Sistema siguiente">S»</button>
            <button class="ag3d_ir" id="ag3d_ir">IR</button>
        </div>
        <div class="ag3d_tabsmv">
            <button class="ag3d_mini activo" id="ag3d_tab_gal">GALAXIA</button>
            <button class="ag3d_mini" id="ag3d_tab_score">PUNTUACIÓN</button>
        </div>
        <div class="ag3d_bloque" id="ag3d_bloque_gal">
            <div class="ag3d_sub">
                <span>TABLA DE GALAXIA · POSICIONES 1-{$max_planets}</span>
                <span class="ag3d_orden">
                    <button class="ag3d_mini activo" id="ag3d_ord_pos" title="Orden por posición">1-{$max_planets}</button>
                    <button class="ag3d_mini" id="ag3d_ord_pts" title="Cambiar a orden por puntuación">Pts</button>
                </span>
            </div>
            <div class="ag3d_twrap">
                <table class="ag3d_table">
                    <thead><tr><th>Pos</th><th>Planeta</th><th>Jugador</th><th>Puntos</th><th>#</th></tr></thead>
                    <tbody id="ag3d_tbody"></tbody>
                </table>
            </div>
        </div>
        <div class="ag3d_bloque" id="ag3d_bloque_score">
            <div class="ag3d_sub"><span>PUNTUACIÓN · TOP DEL UNIVERSO</span></div>
            <div class="ag3d_twrap wrap-score">
                <table class="ag3d_table">
                    <thead><tr><th>#</th><th>Jugador</th><th>Alianza</th><th>Puntos</th></tr></thead>
                    <tbody id="ag3d_score_tbody"></tbody>
                </table>
            </div>
        </div>
        <div class="ag3d_leyenda">
            <span><i style="background:#4a9eff"></i>Propio</span>
            <span><i style="background:#66ff99"></i>Novato</span>
            <span><i style="background:#ff4488"></i>Fuerte</span>
            <span><i style="background:#8899aa"></i>Inactivo</span>
            <span><i style="background:#ffaa33"></i>Vacaciones</span>
            <span><span class="ico">🌙</span>Luna</span>
            <span><span class="ico">♻️</span>Escombros</span>
            <span><span class="ico">☄️</span>Asteroide</span>
            <span><span class="ico">🚀</span>Libre · colonizable</span>
            <span><span class="ico">💀</span>Ruinas</span>
            <span><span class="ico">⚔️</span>Ataque</span>
            <span><span class="ico">🏦</span>Depósito</span>
        </div>
    </div>

    <!-- ====== PANEL DERECHO: DETALLE + ACCIONES REALES ====== -->
    <div class="ag3d_panel" id="ag3d_det">
        <button class="ag3d_back" id="ag3d_back">← Volver a posiciones</button>
        <div id="ag3d_detbody"></div>
    </div>

    <div id="ag3d_hint">Arrastrar: girar · Rueda / pellizco: zoom · ← → cambiar sistema · Clic: seleccionar</div>
    <div id="ag3d_toasts"></div>
    <div id="ag3d_carga"><div class="ag3d_aro"></div><div>CARGANDO GALAXIA…</div></div>

    <!-- tabla de estado de flotas oculta: galaxy.js (fleetAjax) escribe aquí
         y actualiza los contadores #slots / #elementID210 / #elementID209 / #elementID219 -->
    <div style="display:none">
        <table><tbody>
            <tr id="fleetstatusrow"><th colspan="8"></th></tr>
        </tbody></table>
    </div>

</div>

<script type="text/javascript">
    window.ASTRO_G3D = {$astro3d|json};
    status_ok               = '{$LNG.gl_ajax_status_ok}';
    status_fail             = '{$LNG.gl_ajax_status_fail}';
    MaxFleetSetting         = {$settings_fleetactions};
</script>

{/block}
