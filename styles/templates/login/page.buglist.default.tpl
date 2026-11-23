{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/page.buglist.default.tpl === *}



{* ASTRO BUG LIST v3.0 — Lista publica de bugs (sin login) *}
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

/* Cabecera + tarjetas de bugs (nextgen) */
.astrobugl_wrap { max-width: 760px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; font-family: 'Rajdhani', 'Segoe UI', sans-serif; }
.astrobugl_header {
    background: rgba(0,0,0,.5); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border); border-radius: 15px;
    box-shadow: 0 0 40px rgba(0,0,0,.75);
    padding: 18px 20px; margin-bottom: 16px;
}
.astrobugl_title {
    color: #ffffff; font-family: 'Space Mono', monospace; font-size: 13px; font-weight: 700;
    letter-spacing: 2px; text-transform: uppercase; text-shadow: none;
}
.astrobugl_subtitle { color: var(--nx-muted); font-size: 13.5px; margin-top: 6px; }
.astrobugl_info {
    color: #e2e8f0; font-size: 12.5px; line-height: 1.6;
    background: rgba(255,255,255,.04); border: 1px solid var(--nx-border);
    border-left: 3px solid var(--nx-cyan); border-radius: 8px; padding: 10px 14px; margin-top: 12px;
}
.astrobugl_list { display: flex; flex-direction: column; gap: 10px; margin-top: 14px; }
.astrobugl_card {
    background: rgba(0,0,0,.5); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border); border-radius: 12px;
    padding: 14px 16px; transition: .2s ease;
}
.astrobugl_card:hover { border-color: rgba(255,255,255,.25); transform: translateY(-1px); }
.astrobugl_card_head { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; }
.astrobugl_card_id {
    color: var(--nx-purple); font-family: 'Space Mono', monospace; font-size: 12px; font-weight: 700;
}
.astrobugl_card_titulo { color: #ffffff; font-size: 15.5px; font-weight: 700; letter-spacing: .3px; }
.astrobugl_card_estado {
    font-family: 'Space Mono', monospace; font-size: 9.5px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 1.2px;
    padding: 3px 10px; border-radius: 20px;
    background: rgba(255,255,255,.06); border: 1px solid rgba(255,255,255,.18); color: #e2e8f0;
}
.astrobugl_card_estado.resuelto, .astrobugl_card_estado.resolved { color: var(--nx-green); border-color: rgba(53,255,143,.4); background: rgba(53,255,143,.07); }
.astrobugl_card_estado.en_proceso, .astrobugl_card_estado.proceso { color: var(--nx-gold); border-color: rgba(251,191,36,.4); background: rgba(251,191,36,.07); }
.astrobugl_card_meta { color: var(--nx-muted); font-family: 'Space Mono', monospace; font-size: 10px; letter-spacing: 1px; margin-top: 6px; }
.astrobugl_card_desc { color: #e2e8f0; font-size: 13.5px; line-height: 1.65; margin-top: 8px; }
.astrobugl_empty {
    background: rgba(0,0,0,.5); border: 1px solid var(--nx-border); border-radius: 12px;
    color: var(--nx-muted); text-align: center; padding: 30px 20px; font-size: 15px; font-style: italic;
}
.astrobugl_empty .icon { font-size: 26px; display: block; margin-bottom: 8px; }
.astrobugl_cta { margin-top: 16px; text-align: center; }
.astrobugl_cta a, .astrobugl_cta button {
    display: inline-block; padding: 11px 28px;
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
    color: #fff; border: 1px solid rgba(89,214,255,.55); border-radius: 8px;
    font-family: 'Rajdhani', sans-serif; font-size: 13px; font-weight: 700;
    text-transform: uppercase; letter-spacing: 2px; text-decoration: none; transition: .2s ease;
}
.astrobugl_cta a:hover, .astrobugl_cta button:hover {
    background: linear-gradient(180deg, #0077e6 0%, #00aaff 100%);
    box-shadow: 0 6px 24px rgba(0,136,255,.6); transform: translateY(-1px);
}

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astrobugl_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astrobugl_panel { border-radius: 12px; }
    .astrobugl_body { padding: 16px 14px !important; }
    .astrobugl_actions { text-align: center !important; }
    .astrobugl_actions .btn, .astrobugl_btn_register, .astrobugl_btn_submit { width: 100%; }
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