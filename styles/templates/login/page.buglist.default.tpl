{block name="content"}

{* ASTRO BUG LIST v3.0 — Lista publica de bugs (sin login) *}

{literal}
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

.astrobugl_wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 15px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    box-sizing: border-box;
}

/* Cabecera (glassmorphism) */
.astrobugl_header {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 30px 25px;
    margin-bottom: 25px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
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
    color: var(--text-muted);
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
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-left: 4px solid #00ccff;
    border-radius: 10px;
    padding: 16px 20px;
    transition: all 0.25s ease;
}

.astrobugl_card:hover {
    border-color: rgba(0, 204, 255, 0.5);
    border-left-color: #00e0ff;
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.3);
    transform: translateX(3px);
}

/* Estados funcionales (preservar) */
.astrobugl_card.aceptado     { border-left-color: #00ccff; }
.astrobugl_card.solucionado  { border-left-color: #ffaa33; }

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
    color: var(--text-title);
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
    color: var(--text-muted);
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
    border-top: 1px solid rgba(0, 204, 255, 0.1);
    color: #a8b8c8;
    font-size: 12px;
    line-height: 1.5;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

/* Estado vacio (glassmorphism) */
.astrobugl_empty {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px dashed rgba(0, 204, 255, 0.3);
    border-radius: 12px;
    padding: 60px 20px;
    text-align: center;
    color: var(--text-muted);
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
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #fff;
    font-size: 13px;
    font-weight: 700;
    padding: 12px 28px;
    border-radius: 8px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.25s ease;
    box-shadow: 0 4px 12px rgba(0, 102, 204, 0.4);
    border: 1px solid #00ccff;
}
.astrobugl_cta a:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astrobugl_cta a:active {
    transform: translateY(0);
}

/* Responsive */
@media (max-width: 720px) {
    .astrobugl_wrap { padding: 10px; }
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