{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.bugreport.ver.tpl === *}
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
   ASTRO BUG REPORT v3.0 — Ver detalle del reporte
   Prefijo: .astrobug_
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Sub-secciones con borde cyan sutil + hover
     - Timeline con dots con glow
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: style inline dinámico de estado intacto
     - if, foreach, Smarty y clases funcionales intactos
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
    max-width: 900px;
    margin: 0 auto;
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
    padding: 22px 24px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;
}

.astrobug_header_left {
    flex: 1;
    min-width: 200px;
}

.astrobug_id {
    color: #00ccff;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    margin-bottom: 4px;
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.4);
}

.astrobug_titulo {
    color: var(--text-title);
    font-size: 18px;
    font-weight: 700;
    margin-bottom: 8px;
}

.astrobug_meta {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
    font-size: 11px;
    color: var(--text-muted);
}

.astrobug_meta span {
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.astrobug_estado {
    display: inline-block;
    padding: 6px 14px;
    border-radius: 14px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

/* Sub-secciones (glassmorphism) */
.astrobug_section {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 18px 22px;
    margin-bottom: 15px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.3);
    transition: 0.2s ease;
}
.astrobug_section:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

.astrobug_section_title {
    color: #00ccff;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 10px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.3);
}

.astrobug_section_content {
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.6;
    white-space: pre-wrap;
    word-wrap: break-word;
}

.astrobug_respuesta {
    background: rgba(0, 40, 20, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(102, 255, 153, 0.35);
    border-radius: 10px;
    padding: 14px 18px;
    color: #88ffbb;
    font-size: 13px;
    line-height: 1.6;
    white-space: pre-wrap;
    word-wrap: break-word;
}

/* Timeline */
.astrobug_timeline {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.astrobug_timeline_item {
    display: flex;
    gap: 12px;
    align-items: flex-start;
    padding-left: 12px;
    border-left: 2px solid rgba(0, 204, 255, 0.3);
}

.astrobug_timeline_dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #00ccff;
    margin-top: 6px;
    flex-shrink: 0;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.6);
}

.astrobug_timeline_content {
    flex: 1;
}

.astrobug_timeline_accion {
    color: #00e0ff;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.3);
}

.astrobug_timeline_detalle {
    color: var(--text-muted);
    font-size: 11px;
    margin-top: 2px;
}

.astrobug_timeline_fecha {
    color: #667788;
    font-size: 10px;
    font-family: 'Courier New', monospace;
    margin-top: 3px;
}

/* Acciones */
.astrobug_actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    flex-wrap: wrap;
    margin-top: 20px;
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
    .astrobug_header { padding: 18px 16px; }
    .astrobug_titulo { font-size: 16px; }
    .astrobug_section { padding: 14px 16px; }
    .astrobug_btn_gris { width: 100%; text-align: center; box-sizing: border-box; }
}
</style>

<div class="astrobug_wrap">

    <div class="astrobug_header">
        <div class="astrobug_header_left">
            <div class="astrobug_id">Reporte #{$reporte.id}</div>
            <div class="astrobug_titulo">{$reporte.titulo}</div>
            <div class="astrobug_meta">
                <span>{$reporte.categoria_emoji} {$reporte.categoria_nombre}</span>
                <span>📅 {$reporte.fecha_creacion|date_format:"%d/%m/%Y - %H:%M"}</span>
            </div>
        </div>
        <span class="astrobug_estado"
              style="background: {$reporte.estado_info.color}22; color: {$reporte.estado_info.color}; border: 1px solid {$reporte.estado_info.color};">
            {$reporte.estado_info.icono} {$reporte.estado_info.texto}
        </span>
    </div>

    <div class="astrobug_section">
        <div class="astrobug_section_title">📄 Descripción del problema</div>
        <div class="astrobug_section_content">{$reporte.descripcion}</div>
    </div>

    {if $reporte.respuesta_admin}
        <div class="astrobug_section">
            <div class="astrobug_section_title">💬 Respuesta del administrador</div>
            <div class="astrobug_respuesta">{$reporte.respuesta_admin}</div>
        </div>
    {/if}

    {if $log}
        <div class="astrobug_section">
            <div class="astrobug_section_title">🕐 Historial del reporte</div>
            <div class="astrobug_timeline">
                {foreach $log as $l}
                    <div class="astrobug_timeline_item">
                        <div class="astrobug_timeline_dot"></div>
                        <div class="astrobug_timeline_content">
                            <div class="astrobug_timeline_accion">{$l.accion}</div>
                            {if $l.detalle}
                                <div class="astrobug_timeline_detalle">{$l.detalle}</div>
                            {/if}
                            <div class="astrobug_timeline_fecha">{$l.fecha|date_format:"%d/%m/%Y - %H:%M"}</div>
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
    {/if}

    <div class="astrobug_actions">
        <a href="game.php?page=bugreport" class="astrobug_btn_gris">← Volver a Mis Reportes</a>
    </div>

</div>

{/block}