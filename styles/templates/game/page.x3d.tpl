{block name="title" prepend}XNOVA 3D{/block}
{block name="content"}

{* ============================================================
   XNOVA 3D — ESCRITORIO 3D COMPLETO (rama xnova3d)
   El juego entero en un app 3D con las IMÁGENES REALES del
   proyecto (styles/theme/gow/gebaeude + planeten):
     · BASE     -> tu planeta + edificios (como Overview/Buildings)
     · NAVES    -> hangar de naves y defensas (Shipyard)
     · INVESTIGACIÓN -> laboratorio (Research)
     · IMPERIO  -> tus planetas y lunas (Imperium)
     · FLOTAS   -> flotas en vuelo (fleetTable/events)
     · MÓDULOS  -> TODOS los módulos del juego abren aquí como
                   paneles dentro del 3D (nada se queda fuera)
     · GALAXIA 3D -> visor de galaxia (page=galaxy&vista=3d)
   Acciones reales por POST a las páginas clásicas.
   ============================================================ *}

{literal}
<style>
/* ====== app 3D ====== */
#x3d_app {
    position: relative; width: 100%;
    height: calc(100vh - 150px); min-height: 540px;
    background: #0a101e; border-radius: 12px; overflow: hidden;
    font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    color: #cbd5e1; border: 1px solid #1e293b;
}
#x3d_app::after {
    content: ''; position: absolute; inset: 0; pointer-events: none; z-index: 30;
    background:
        repeating-linear-gradient(0deg, rgba(255,255,255,0.012) 0 1px, transparent 1px 3px),
        radial-gradient(ellipse at center, transparent 55%, rgba(5,8,16,0.5) 100%);
}
#x3d_canvas { position: absolute; inset: 0; z-index: 1; }
#x3d_canvas canvas { width: 100%; height: 100%; display: block; }

/* ====== topbar: planeta + recursos reales ====== */
#x3d_top {
    position: absolute; top: 0; left: 0; right: 0; z-index: 40;
    display: flex; align-items: center; gap: 8px 14px; flex-wrap: wrap;
    padding: 8px 12px;
    background: linear-gradient(180deg, rgba(7,12,24,.92), rgba(7,12,24,.55) 75%, transparent);
}
#x3d_tit { font-size: clamp(14px, 2.2vw, 18px); font-weight: 700; color: #7dd3fc; letter-spacing: .5px; }
#x3d_tit .mono { color: #64748b; font-size: .8em; }
.x3d_rec {
    display: flex; align-items: center; gap: 6px;
    background: rgba(10,18,34,.8); border: 1px solid #1e3a5f; border-radius: 8px;
    padding: 3px 9px; font-size: clamp(11px, 1.6vw, 13px);
}
.x3d_rec b { color: #fbbf24; }
.x3d_rec em { font-style: normal; color: #64748b; font-size: .85em; }
.x3d_rec img { width: 16px; height: 16px; }

/* ====== dock de escenas ====== */
#x3d_dock {
    position: absolute; left: 10px; top: 64px; z-index: 45;
    display: flex; flex-direction: column; gap: 6px;
}
#x3d_dock button, #x3d_dock a {
    display: flex; align-items: center; gap: 8px;
    background: rgba(10,18,34,.85); border: 1px solid #1e3a5f; color: #cbd5e1;
    border-radius: 9px; padding: 7px 12px; cursor: pointer;
    font-size: clamp(11px, 1.5vw, 13px); font-weight: 600; text-decoration: none;
    transition: border-color .15s, background .15s;
}
#x3d_dock button:hover, #x3d_dock a:hover { border-color: #00e0ff; background: rgba(12,24,44,.95); }
#x3d_dock button.activo { border-color: #00e0ff; color: #7dd3fc; box-shadow: 0 0 10px rgba(0,224,255,.25); }

/* ====== panel de detalle (derecha) ====== */
#x3d_det {
    position: absolute; right: 10px; top: 64px; bottom: 92px; z-index: 44;
    width: min(320px, 78vw); overflow-y: auto;
    background: rgba(9,15,30,.93); border: 1px solid #1e3a5f; border-radius: 12px;
    padding: 12px; backdrop-filter: blur(4px);
}
#x3d_det::-webkit-scrollbar { width: 8px; }
#x3d_det::-webkit-scrollbar-thumb { background: #1e3a5f; border-radius: 4px; }
.x3d_oculto { display: none !important; }
#x3d_det .x3d_dt-titulo {
    font-size: 13px; font-weight: 700; color: #7dd3fc; letter-spacing: 1px;
    border-bottom: 1px solid #1e3a5f; padding-bottom: 6px; margin-bottom: 8px;
    display: flex; align-items: center; gap: 8px;
}
#x3d_det img.x3d_det-img { width: 58px; height: 58px; border-radius: 10px; border: 1px solid rgba(0,224,255,.4); }
#x3d_det .kv { display: flex; justify-content: space-between; gap: 8px; padding: 3px 0; font-size: clamp(12px, 1.6vw, 13px); }
#x3d_det .kv span { color: #64748b; }
#x3d_det .kv b { color: #e2e8f0; text-align: right; }
#x3d_det .kv b.ok { color: #4aff88; }
#x3d_det .kv b.mal { color: #ff6b7a; }
#x3d_det .acciones { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 10px; }
#x3d_det .btn-x {
    flex: 1 1 auto; background: rgba(12,24,44,.9); border: 1px solid #2a4a75; color: #e2e8f0;
    border-radius: 8px; padding: 7px 10px; cursor: pointer; font-size: 12px; font-weight: 600;
    transition: border-color .15s;
}
#x3d_det .btn-x:hover { border-color: #00e0ff; }
#x3d_det .btn-x.pri { border-color: #00e0ff; color: #7dd3fc; }
#x3d_det .btn-x:disabled { opacity: .45; cursor: not-allowed; }
#x3d_det input.x3d_qty {
    width: 84px; background: #0a1220; border: 1px solid #2a4a75; color: #e2e8f0;
    border-radius: 8px; padding: 6px 8px; font-size: 13px;
}
#x3d_det .nota { color: #64748b; font-size: 11px; margin-top: 8px; }

/* ====== cola inferior ====== */
#x3d_cola {
    position: absolute; left: 10px; right: 10px; bottom: 10px; z-index: 44;
    display: flex; gap: 8px; overflow-x: auto; padding: 6px;
    background: rgba(9,15,30,.85); border: 1px solid #1e3a5f; border-radius: 12px;
    min-height: 58px; align-items: center;
}
#x3d_cola::-webkit-scrollbar { height: 6px; }
#x3d_cola::-webkit-scrollbar-thumb { background: #1e3a5f; border-radius: 3px; }
.x3d_cola-item {
    display: flex; align-items: center; gap: 7px; flex: 0 0 auto;
    background: rgba(12,24,44,.9); border: 1px solid #2a4a75; border-radius: 9px; padding: 5px 9px;
    font-size: 12px;
}
.x3d_cola-item img { width: 26px; height: 26px; border-radius: 6px; }
.x3d_cola-item .t { color: #fbbf24; font-weight: 700; }
.x3d_cola-item .n { color: #cbd5e1; max-width: 130px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.x3d_cola-item .cancelar {
    background: none; border: none; color: #ff6b7a; cursor: pointer; font-size: 14px; padding: 0 2px;
}
.x3d_cola-vacia { color: #475569; font-size: 12px; padding: 0 6px; }

/* ====== catálogo de MÓDULOS (todo el juego dentro del 3D) ====== */
#x3d_mods {
    position: absolute; inset: 0; z-index: 60;
    background: rgba(5,8,16,.9); backdrop-filter: blur(5px);
    display: flex; align-items: center; justify-content: center; padding: 16px;
}
#x3d_mods .x3d_mods-caja {
    width: min(860px, 96%); max-height: 86%; overflow-y: auto;
    background: rgba(9,15,30,.97); border: 1px solid #2a4a75; border-radius: 14px; padding: 16px;
}
#x3d_mods h3 { color: #7dd3fc; font-size: 15px; letter-spacing: 1px; margin: 12px 0 8px; }
#x3d_mods .grupo { display: flex; flex-wrap: wrap; gap: 6px; }
#x3d_mods .x3d_mod {
    display: inline-flex; align-items: center; gap: 6px;
    background: rgba(12,24,44,.9); border: 1px solid #1e3a5f; color: #cbd5e1;
    border-radius: 8px; padding: 6px 11px; cursor: pointer; font-size: 12.5px; font-weight: 600;
}
#x3d_mods .x3d_mod:hover { border-color: #00e0ff; }
#x3d_mods_cerrar {
    position: sticky; top: 0; float: right;
    background: none; border: 1px solid #2a4a75; color: #ff6b7a; border-radius: 8px;
    padding: 4px 10px; cursor: pointer; font-size: 13px;
}

/* ====== panel de módulo clásico (iframe) dentro del 3D ====== */
#x3d_panel {
    position: absolute; inset: 0; z-index: 70;
    background: rgba(5,8,16,.82); backdrop-filter: blur(4px);
    display: flex; flex-direction: column; padding: 12px;
}
#x3d_panel .x3d_panel-caja {
    flex: 1; display: flex; flex-direction: column;
    background: #0c1424; border: 1px solid #2a4a75; border-radius: 14px; overflow: hidden;
}
#x3d_panel header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 8px 12px; background: rgba(7,12,24,.9); border-bottom: 1px solid #1e3a5f;
}
#x3d_panel header b { color: #7dd3fc; font-size: 13.5px; letter-spacing: 1px; }
#x3d_panel header button {
    background: none; border: 1px solid #2a4a75; color: #ff6b7a; border-radius: 8px;
    padding: 4px 12px; cursor: pointer; font-size: 13px;
}
#x3d_panel iframe { flex: 1; width: 100%; border: 0; background: #0c1424; }

/* ====== toasts + carga ====== */
#x3d_toasts {
    position: absolute; top: 64px; left: 50%; transform: translateX(-50%);
    z-index: 80; display: flex; flex-direction: column; gap: 6px; pointer-events: none;
}
.x3d_toast {
    background: rgba(9,15,30,.95); border: 1px solid #00e0ff; color: #cbd5e1;
    border-radius: 10px; padding: 8px 14px; font-size: 13px;
    box-shadow: 0 0 14px rgba(0,224,255,.2);
}
.x3d_toast.mal { border-color: #ff6b7a; box-shadow: 0 0 14px rgba(255,107,122,.2); }
#x3d_carga {
    position: absolute; inset: 0; z-index: 90; display: flex; flex-direction: column;
    align-items: center; justify-content: center; gap: 14px;
    background: rgba(5,8,16,.86); color: #7dd3fc; font-size: 14px; letter-spacing: 2px;
}
#x3d_carga .aro {
    width: 42px; height: 42px; border-radius: 50%;
    border: 3px solid #1e3a5f; border-top-color: #00e0ff;
    animation: x3d_giro 1s linear infinite;
}
@keyframes x3d_giro { to { transform: rotate(360deg); } }

/* ====== móvil ====== */
@media (max-width: 640px) {
    #x3d_dock { top: auto; bottom: 76px; left: 8px; right: 8px; flex-direction: row; flex-wrap: wrap; justify-content: center; }
    #x3d_dock button, #x3d_dock a { padding: 6px 10px; }
    #x3d_det { top: auto; bottom: 130px; max-height: 46%; }
    #x3d_cola { bottom: 8px; max-height: 60px; }
    #x3d_app { min-height: 480px; }
}
</style>
{/literal}

<div id="x3d_app">
    <div id="x3d_canvas"></div>

    <!-- TOPBAR: planeta + recursos reales del juego -->
    <div id="x3d_top">
        <span id="x3d_tit">🪐 XNOVA <b style="color:#00e0ff">3D</b> <span class="mono" id="x3d_planeta_txt"></span></span>
        <span class="x3d_rec">⛏️ <b id="x3d_r_metal">0</b><em id="x3d_r_metal_max"></em></span>
        <span class="x3d_rec">💎 <b id="x3d_r_cristal">0</b><em id="x3d_r_cristal_max"></em></span>
        <span class="x3d_rec">⛽ <b id="x3d_r_deuterio">0</b><em id="x3d_r_deuterio_max"></em></span>
        <span class="x3d_rec">⚡ <b id="x3d_r_energia">0</b></span>
        <span class="x3d_rec">🌑 <b id="x3d_r_dm">0</b></span>
    </div>

    <!-- DOCK de escenas -->
    <div id="x3d_dock">
        <button data-esc="base" class="activo">🪐 Base</button>
        <button data-esc="hangar">🚀 Naves</button>
        <button data-esc="lab">🔬 Investigación</button>
        <button data-esc="imperio">🛰 Imperio</button>
        <button data-esc="flotas">⚓ Flotas</button>
        <a href="game.php?page=galaxy&amp;vista=3d" title="Visor 3D de galaxia">🧭 Galaxia 3D</a>
        <button id="x3d_btn_mods">☰ Módulos</button>
        <a href="game.php?page=overview" title="Versión clásica">🖥 Clásico</a>
    </div>

    <!-- DETALLE (derecha) -->
    <div id="x3d_det">
        <div class="x3d_dt-titulo">SELECCIONA EN LA ESCENA</div>
        <p style="color:#64748b;font-size:12.5px">Haz clic en un edificio, nave, investigación o planeta de la escena 3D para ver sus datos reales y actuar.</p>
    </div>

    <!-- COLA (inferior) -->
    <div id="x3d_cola"><span class="x3d_cola-vacia">—</span></div>

    <!-- CATÁLOGO DE MÓDULOS: TODO el juego dentro del 3D.
         Incluido aparte (page.x3d.mods.tpl) para poder añadir/quitar
         módulos del catálogo sin tocar esta plantilla. -->
    {include file="page.x3d.mods.tpl"}

    <!-- PANEL de módulo clásico dentro del 3D -->
    <div id="x3d_panel" class="x3d_oculto">
        <div class="x3d_panel-caja">
            <header><b id="x3d_panel_tit">MÓDULO</b><button id="x3d_panel_cerrar">✕ Cerrar</button></header>
            <iframe id="x3d_iframe" title="Módulo clásico"></iframe>
        </div>
    </div>

    <div id="x3d_toasts"></div>
    <div id="x3d_carga"><div class="aro"></div><div>CARGANDO XNOVA 3D…</div></div>
</div>

<script type="text/javascript">
    window.X3D_DATA = {$x3d|json};
    window.X3D_DPATH = '{$dpath}';
    // arranque del núcleo 3D: los módulos ya se registraron (x3d/*.js)
    if (window.X3D && X3D.iniciar) { X3D.iniciar(); }
</script>

{/block}
