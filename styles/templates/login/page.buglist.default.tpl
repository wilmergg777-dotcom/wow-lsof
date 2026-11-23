{block name="content"}
{* === ASTROIO v3.1 - Lista de Bugs (Estilo oscuro, borde naranja) === *}
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
/* ✅ FIX: Corregido el error de sintaxis del doble corchete */
@media (max-width:760px) { body { padding:6px; overflow-x:auto; } table { font-size:11px; } table th, table td { padding:5px 7px; } }
</style>
{/literal}


{* ASTRO BUG LIST v3.1 — Lista publica de bugs (sin login) *}

{literal}
<style>
/* ====== Variables globales ====== */
:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.9); /* Fondo oscuro igual al index */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --text-title:    #ffffff;
    --accent-cyan:   #00e0ff;
    --accent-orange: #ff5e00;
}

.astrobugl_wrap {
    max-width: 1100px;
    margin: 40px auto 20px;
    padding: 15px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    box-sizing: border-box;
}

/* Cabecera (glassmorphism) */
.astrobugl_header {
    background: var(--bg-card) !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px;
    padding: 30px 25px;
    margin-bottom: 25px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    text-align: center;
}

.astrobugl_title {
    font-size: 28px;
    font-weight: bold;
    color: #ffaa33;
    text-shadow: 0 0 14px rgba(255, 170, 51, 0.5);
    letter-spacing: 1.5px;
    margin-bottom: 8px;
}

.astrobugl_subtitle {
    font-size: 13px;
    color: #94a3b8 !important;
    font-style: italic;
    margin-bottom: 15px;
}

.astrobugl_info {
    display: inline-block;
    background: rgba(0, 204, 255, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 20px;
    padding: 8px 18px;
    font-size: 12px;
    color: #00ccff;
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.4);
}

/* Lista de reportes */
.astrobugl_list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.astrobugl_card {
    background: rgba(0, 0, 0, 0.5) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    border-left: 4px solid var(--border-color) !important; /* Borde naranja izquierdo */
    border-radius: 10px;
    padding: 16px 20px;
    transition: all 0.25s ease;
}

.astrobugl_card:hover {
    border-color: var(--border-color) !important;
    box-shadow: 0 0 20px rgba(255, 94, 0, 0.3) !important;
    transform: translateX(3px);
}

/* Estados funcionales */
.astrobugl_card.aceptado     { border-left-color: #00ccff !important; }
.astrobugl_card.solucionado  { border-left-color: #4aff88 !important; }

.astrobugl_card_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 10px;
}

.astrobugl_card_left {
    display: flex;
    align-items: center;
    gap: 10px;
    flex: 1;
    min-width: 0;
}

.astrobugl_card_id {
    color: #00ccff;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 13px;
    white-space: nowrap;
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.4);
}

.astrobugl_card_titulo {
    color: var(--text-title) !important;
    font-size: 15px;
    font-weight: 700;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.astrobugl_card_estado {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 14px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

.astrobugl_card_meta {
    display: flex;
    gap: 18px;
    font-size: 12px;
    color: #94a3b8 !important;
    flex-wrap: wrap;
}

.astrobugl_card_meta span {
    display: inline-flex;
    align-items: center;
    gap: 5px;
}

.astrobugl_card_desc {
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px solid rgba(255, 94, 0, 0.2) !important; /* Línea naranja tenue */
    color: #a8b8c8 !important;
    font-size: 12px;
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Estado vacio */
.astrobugl_empty {
    background: rgba(0, 0, 0, 0.5) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px dashed var(--border-color) !important; /* Borde naranja discontinuo */
    border-radius: 12px;
    padding: 60px 20px;
    text-align: center;
    color: #94a3b8 !important;
    font-size: 14px;
}

.astrobugl_empty .icon {
    font-size: 52px;
    display: block;
    margin-bottom: 15px;
    opacity: 0.4;
}

/* CTA */
.astrobugl_cta {
    margin-top: 25px;
    text-align: center;
}

.astrobugl_cta a {
    display: inline-block;
    background: #222c3c !important;
    color: #fff !important;
    font-size: 13px;
    font-weight: 700;
    padding: 12px 28px;
    border-radius: 8px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.25s ease;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4) !important;
    border: 1px solid #444 !important;
}
.astrobugl_cta a:hover {
    background: #2e3a4e !important;
    border-color: var(--border-color) !important;
    box-shadow: 0 0 20px rgba(255, 94, 0, 0.4) !important;
    transform: translateY(-2px);
}
.astrobugl_cta a:active {
    transform: translateY(0);
}

/* Responsive */
@media (max-width: 720px) {
    .astrobugl_wrap { padding: 10px; margin-top: 20px; }
    .astrobugl_header { padding: 20px 15px; }
    .astrobugl_title { font-size: 20px; }
    .astrobugl_card { padding: 12px 14px; }
    .astrobugl_card_titulo { font-size: 13px; }
    .astrobugl_card_meta { font-size: 10px; gap: 10px; }
    .astrobugl_cta a { width: 100%; text-align: center; box-sizing: border-box; }
}
</style>
{/literal}

<div class="astrobugl_wrap">

    <div class="astrobugl_header">
        <div class="astrobugl_title">🐛 BUGS REPORTADOS</div>
        <div class="astrobugl_subtitle">Estado actual de los bugs conocidos en AstroIO</div>
        <div class="astrobugl_info">
            📋 Total: {$reportes|count} reporte(s) público(s)
        </div>
    </div>

    {if $reportes}
        <div class="astrobugl_list">
            {foreach $reportes as $r}
                <div class="astrobugl_card {$r.estado}">
                    <div class="astrobugl_card_head">
                        <div class="astrobugl_card_left">
                            <span class="astrobugl_card_id">#{$r.id}</span>
                            <span class="astrobugl_card_titulo">{$r.titulo}</span>
                        </div>
                        <span class="astrobugl_card_estado"
                              style="background: {$r.estado_info.color}22; color: {$r.estado_info.color}; border: 1px solid {$r.estado_info.color};">
                            {$r.estado_info.icono} {$r.estado_info.texto}
                        </span>
                    </div>

                    <div class="astrobugl_card_meta">
                        <span>{$r.categoria_emoji} {$r.categoria_nombre}</span>
                        <span>📅 {$r.fecha_creacion|date_format:"%d/%m/%Y"}</span>
                    </div>

                    <div class="astrobugl_card_desc">
                        {$r.descripcion|truncate:200:"..."}
                    </div>
                </div>
            {/foreach}
        </div>
    {else}
        <div class="astrobugl_empty">
            <span class="icon">🎉</span>
            <strong>¡No hay bugs reportados actualmente!</strong>
            <br>
            <span style="font-size: 12px; margin-top: 10px; display: inline-block;">
                Todos los reportes han sido resueltos o aún no se han reportado bugs.
            </span>
        </div>
    {/if}

    <div class="astrobugl_cta">
        <a href="index.php">← Volver al Inicio</a>
    </div>

</div>

{/block}