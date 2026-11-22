{block name="content"}

{* ══════════════════════════════════════════════════════════════
   ASTRO BUG REPORT v3.0 — Lista de reportes del jugador
   Prefijo: .astrobug_
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Sub-cajas con borde cyan sutil + hover
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: styles inline dinámicos de estado intactos
     - IDs, foreach, if, Smarty y clases funcionales intactos
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
    max-width: 1100px;
    margin: 0 auto;
    text-align: center;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    padding: 15px;
    box-sizing: border-box;
}

/* Cabecera (glassmorphism + acento dorado) */
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
    font-size: 24px;
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
    margin-bottom: 15px;
}

/* Botón "nuevo reporte" */
.astrobug_btn_new {
    display: inline-block;
    background: linear-gradient(135deg, rgba(170, 102, 0, 0.9), rgba(255, 170, 51, 0.9));
    color: #fff;
    font-size: 14px;
    font-weight: 700;
    padding: 12px 28px;
    border-radius: 8px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.25s ease;
    box-shadow: 0 4px 12px rgba(255, 170, 51, 0.4);
    border: 1px solid #ffcc66;
}
.astrobug_btn_new:hover {
    background: linear-gradient(135deg, rgba(255, 170, 51, 0.95), rgba(255, 204, 102, 0.95));
    box-shadow: 0 0 20px rgba(255, 170, 51, 0.7);
    transform: translateY(-2px);
    color: #1a1000;
}
.astrobug_btn_new:active {
    transform: translateY(0);
}

/* Mensajes */
.astrobug_msg {
    padding: 12px 18px;
    border-radius: 10px;
    margin-bottom: 15px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astrobug_msg.success {
    background: rgba(102, 255, 153, 0.1);
    border: 1px solid rgba(102, 255, 153, 0.4);
    color: #66ff99;
}
.astrobug_msg.error {
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
}

/* Lista de reportes */
.astrobug_list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.astrobug_card {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 15px 20px;
    text-align: left;
    transition: all 0.25s ease;
    position: relative;
    overflow: hidden;
}
.astrobug_card:hover {
    border-color: rgba(0, 204, 255, 0.5);
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.3);
    transform: translateY(-2px);
}

.astrobug_card_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    margin-bottom: 8px;
}

.astrobug_card_id {
    color: #00ccff;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    font-size: 12px;
}

.astrobug_card_titulo {
    color: var(--text-title);
    font-size: 14px;
    font-weight: 700;
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.astrobug_card_estado {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

.astrobug_card_meta {
    display: flex;
    gap: 15px;
    font-size: 11px;
    color: var(--text-muted);
    margin-bottom: 10px;
    flex-wrap: wrap;
}

.astrobug_card_meta span {
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.astrobug_card_respuesta {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid #66ff99;
    border-radius: 8px;
    padding: 8px 12px;
    font-size: 11px;
    color: #88ffbb;
    margin-bottom: 10px;
}

.astrobug_card_footer {
    display: flex;
    justify-content: flex-end;
}

.astrobug_btn_ver {
    display: inline-block;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    padding: 7px 18px;
    border-radius: 8px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    transition: all 0.25s ease;
    border: 1px solid #00ccff;
}
.astrobug_btn_ver:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astrobug_btn_ver:active {
    transform: translateY(0);
}

/* Estado vacío */
.astrobug_empty {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px dashed rgba(0, 204, 255, 0.3);
    border-radius: 12px;
    padding: 40px 20px;
    text-align: center;
    color: var(--text-muted);
    font-size: 13px;
}

.astrobug_empty .astrobug_empty_icon {
    font-size: 42px;
    display: block;
    margin-bottom: 12px;
    opacity: 0.4;
}

/* Acciones */
.astrobug_actions {
    margin-top: 20px;
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
    .astrobug_title { font-size: 20px; }
    .astrobug_card { padding: 12px 15px; }
    .astrobug_card_titulo { white-space: normal; }
    .astrobug_btn_new,
    .astrobug_btn_ver,
    .astrobug_btn_gris { width: 100%; text-align: center; box-sizing: border-box; }
}
</style>

<div class="astrobug_wrap">

    {if $msgSuccess}
        <div class="astrobug_msg success">{$msgSuccess}</div>
    {/if}
    {if $msgError}
        <div class="astrobug_msg error">{$msgError}</div>
    {/if}

    <div class="astrobug_header">
        <div class="astrobug_title">🐛 MIS REPORTES DE BUG</div>
        <div class="astrobug_subtitle">Historial de bugs que has reportado</div>
        <a href="game.php?page=bugreport&mode=new" class="astrobug_btn_new">+ Crear Nuevo Reporte</a>
    </div>

    {if $reportes}
        <div class="astrobug_list">
            {foreach $reportes as $r}
                <div class="astrobug_card">
                    <div class="astrobug_card_head">
                        <span class="astrobug_card_id">#{$r.id}</span>
                        <span class="astrobug_card_titulo">{$r.titulo}</span>
                        <span class="astrobug_card_estado"
                              style="background: {$r.estado_info.color}22; color: {$r.estado_info.color}; border: 1px solid {$r.estado_info.color};">
                            {$r.estado_info.icono} {$r.estado_info.texto}
                        </span>
                    </div>

                    <div class="astrobug_card_meta">
                        <span>{$r.categoria_emoji} {$r.categoria_nombre}</span>
                        <span>📅 {$r.fecha_creacion|date_format:"%d/%m/%Y"}</span>
                    </div>

                    {if $r.respuesta_admin}
                        <div class="astrobug_card_respuesta">
                            💬 <strong>Respuesta del admin:</strong> {$r.respuesta_admin}
                        </div>
                    {/if}

                    <div class="astrobug_card_footer">
                        <a href="game.php?page=bugreport&mode=ver&id={$r.id}" class="astrobug_btn_ver">Ver Detalle →</a>
                    </div>
                </div>
            {/foreach}
        </div>
    {else}
        <div class="astrobug_empty">
            <span class="astrobug_empty_icon">📭</span>
            <strong>No tenés reportes visibles.</strong><br>
            <span style="font-size: 11px; margin-top: 8px; display: inline-block;">
                Los reportes en revisión aparecerán aquí una vez que un admin los acepte.
            </span>
        </div>
    {/if}

    <div class="astrobug_actions">
        <a href="game.php?page=overview" class="astrobug_btn_gris">↩ Volver al Inicio</a>
    </div>

</div>

{/block}