{extends file="layout.full.tpl"}

{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.events.default.tpl === *}
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

{* AstroIO - Página de Eventos v3.0 *}

<style>
/* ═══════════════════════════════════════════════════════════
   EVENTOS — AstroIO v3.0
   Glassmorphism + Acento Púrpura
   Prefijo: .ev_
   ═══════════════════════════════════════════════════════════ */

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

.ev_wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 20px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}
.ev_title {
    font-size: 26px;
    color: var(--accent-purple);
    text-shadow: 0 0 12px rgba(139, 92, 246, 0.6);
    margin-bottom: 6px;
    letter-spacing: 1px;
}
.ev_subtitle {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 22px;
}

/* ============ MENSAJES ============ */
.ev_msg {
    padding: 14px 18px;
    border-radius: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    border-left: 4px solid;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.ev_msg.success {
    background: rgba(74, 255, 136, 0.12);
    border-color: var(--accent-green);
    color: var(--accent-green);
}
.ev_msg.error {
    background: rgba(239, 68, 68, 0.12);
    border-color: var(--accent-red);
    color: var(--accent-red);
}
.ev_msg.info {
    background: rgba(0, 224, 255, 0.10);
    border-color: var(--accent-cyan);
    color: var(--accent-cyan);
}

/* ============ SECCIONES ============ */
.ev_section {
    margin-bottom: 30px;
}
.ev_section_title {
    font-size: 16px;
    color: var(--text-title);
    padding: 8px 14px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-weight: 700;
    letter-spacing: 1.2px;
    text-transform: uppercase;
    display: flex;
    align-items: center;
    justify-content: space-between;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.4);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.ev_section_title.daily {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    border-left: 4px solid var(--accent-cyan);
}
.ev_section_title.weekly {
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.85), rgba(139, 92, 246, 0.85));
    border-left: 4px solid var(--accent-purple);
}
.ev_section_title.elite {
    background: linear-gradient(135deg, rgba(170, 68, 0, 0.85), rgba(221, 119, 0, 0.85));
    border-left: 4px solid var(--accent-gold);
}
.ev_section_title.admin {
    background: linear-gradient(135deg, rgba(0, 102, 51, 0.85), rgba(0, 153, 85, 0.85));
    border-left: 4px solid var(--accent-green);
}
.ev_section_title .count {
    font-size: 11px;
    color: #cceeff;
    background: rgba(0, 0, 0, 0.3);
    padding: 2px 8px;
    border-radius: 10px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: none;
}

/* ============ GRID ============ */
.ev_grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
}

/* ============ TARJETAS ============ */
.ev_card {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 14px;
    transition: all 0.25s ease;
    position: relative;
    display: flex;
    flex-direction: column;
    gap: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.ev_card:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 4px 20px rgba(0, 224, 255, 0.3), 0 4px 20px rgba(0, 0, 0, 0.35);
    transform: translateY(-2px);
}
.ev_card.complete {
    border-color: var(--accent-green);
    box-shadow: 0 0 20px rgba(74, 255, 136, 0.3), 0 4px 20px rgba(0, 0, 0, 0.35);
}
.ev_card.claimed {
    opacity: 0.5;
    border-color: #555;
}
.ev_card.claimed:hover {
    transform: none;
    box-shadow: none;
}

.ev_card_header {
    display: flex;
    align-items: center;
    gap: 10px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.15);
}
.ev_card_icon {
    font-size: 28px;
    line-height: 1;
    flex-shrink: 0;
}
.ev_card_name {
    font-size: 14px;
    font-weight: 700;
    letter-spacing: 0.5px;
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.ev_card_badge {
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 6px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    background: rgba(0, 224, 255, 0.15);
    color: var(--accent-cyan);
    border: 1px solid rgba(0, 224, 255, 0.3);
}
.ev_card_badge.complete {
    background: rgba(74, 255, 136, 0.15);
    color: var(--accent-green);
    border-color: rgba(74, 255, 136, 0.4);
}

.ev_card_desc {
    font-size: 12px;
    color: var(--text-muted);
    line-height: 1.4;
    min-height: 34px;
}

/* ============ BARRA DE PROGRESO ============ */
.ev_progress_wrap {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.ev_progress_info {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
    color: var(--text-muted);
    font-family: 'Courier New', monospace;
}
.ev_progress_bar {
    height: 12px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid rgba(0, 224, 255, 0.2);
    position: relative;
}
.ev_progress_fill {
    height: 100%;
    background: linear-gradient(90deg, #0066cc, var(--accent-cyan));
    transition: width 0.5s ease;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.6) inset;
}
.ev_progress_fill.complete {
    background: linear-gradient(90deg, #228833, var(--accent-green));
    box-shadow: 0 0 8px rgba(74, 255, 136, 0.6) inset;
}

/* ============ RECOMPENSA ============ */
.ev_reward_box {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-radius: 6px;
    padding: 8px 10px;
    border: 1px dashed rgba(0, 224, 255, 0.25);
}
.ev_reward_label {
    font-size: 11px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
}
.ev_reward_value {
    font-size: 13px;
    color: var(--accent-gold);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}

/* ============ BOTÓN RECLAMAR ============ */
.ev_claim_btn {
    width: 100%;
    padding: 10px;
    background: linear-gradient(135deg, #228833 0%, #4aff88 100%);
    color: #fff;
    border: 1px solid var(--accent-green);
    border-radius: 6px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 1.5px;
    cursor: pointer;
    text-transform: uppercase;
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.ev_claim_btn:hover {
    background: linear-gradient(135deg, #4aff88 0%, #86ffb8 100%);
    box-shadow: 0 0 20px rgba(74, 255, 136, 0.6);
    transform: translateY(-2px);
}
.ev_claim_btn:active {
    transform: translateY(0);
}

.ev_claimed_btn {
    width: 100%;
    padding: 10px;
    background: rgba(0, 0, 0, 0.4);
    color: #555;
    border: 1px solid #444;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.ev_pending_btn {
    width: 100%;
    padding: 10px;
    background: rgba(0, 0, 0, 0.4);
    color: var(--text-muted);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

/* ============ HISTORIAL ============ */
.ev_history {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    margin-top: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.ev_history h3 {
    font-size: 14px;
    color: var(--accent-cyan);
    margin: 0 0 12px 0;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.ev_hist_row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    margin-bottom: 6px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-radius: 6px;
    border-left: 3px solid var(--accent-cyan);
    font-size: 12px;
    transition: all 0.2s ease;
}
.ev_hist_row:hover {
    background: rgba(0, 224, 255, 0.08);
    transform: translateX(3px);
}
.ev_hist_row.daily   { border-left-color: var(--accent-cyan); }
.ev_hist_row.weekly  { border-left-color: var(--accent-purple); }
.ev_hist_row.elite   { border-left-color: var(--accent-gold); }
.ev_hist_row.admin   { border-left-color: var(--accent-green); }
.ev_hist_row .hist_name { flex: 1; color: var(--text-main); }
.ev_hist_row .hist_reward { color: var(--accent-green); font-weight: 700; font-family: 'Courier New', monospace; margin-right: 10px; }
.ev_hist_row .hist_date { color: var(--text-muted); font-size: 10px; }

.ev_empty {
    text-align: center;
    padding: 30px;
    color: var(--text-muted);
    font-style: italic;
    font-size: 13px;
}

@media (max-width: 700px) {
    .ev_wrap { padding: 8px !important; }
    .ev_title { font-size: 20px !important; }
    .ev_subtitle { font-size: 11px !important; margin-bottom: 15px !important; }

    /* 🆕 FORZAR 1x2 EN LAS TARJETAS */
    .ev_grid { 
        grid-template-columns: repeat(2, 1fr) !important; 
        gap: 8px !important; 
    }
    .ev_card { 
        padding: 8px !important; 
        border-radius: 8px !important; 
        gap: 6px !important;
    }

    /* Cabecera de la tarjeta (Icono + Nombre) */
    .ev_card_header { 
        flex-direction: column !important; 
        align-items: center !important; 
        text-align: center !important; 
        gap: 4px !important; 
        padding-bottom: 6px !important;
    }
    .ev_card_icon { font-size: 24px !important; }
    .ev_card_name { 
        font-size: 11px !important; 
        white-space: normal !important; 
        line-height: 1.1 !important;
    }
    .ev_card_badge { font-size: 8px !important; padding: 1px 4px !important; }

    /* Descripción y progreso */
    .ev_card_desc { font-size: 9px !important; line-height: 1.3 !important; min-height: 35px !important; }
    .ev_progress_info { font-size: 9px !important; flex-direction: column !important; align-items: center !important; gap: 2px !important;}
    .ev_progress_bar { height: 8px !important; }

    /* Caja de recompensa */
    .ev_reward_box { 
        flex-direction: column !important; 
        align-items: center !important; 
        padding: 6px 4px !important; 
        gap: 2px !important;
    }
    .ev_reward_label { font-size: 8px !important; }
    .ev_reward_value { font-size: 10px !important; text-align: center !important; }

    /* Botones */
    .ev_claim_btn, .ev_claimed_btn, .ev_pending_btn { 
        padding: 6px 2px !important; 
        font-size: 9px !important; 
        letter-spacing: 0px !important; 
    }

    /* Historial */
    .ev_hist_row { flex-wrap: wrap !important; gap: 4px !important; padding: 6px !important; }
    .ev_hist_row .hist_name { flex: 1 1 100% !important; font-size: 11px !important; }
    .ev_hist_row .hist_reward { font-size: 11px !important; }
    .ev_hist_row .hist_date { font-size: 9px !important; }
}
</style>

<div class="ev_wrap">

    <div class="ev_title">🎯 Eventos en Curso</div>
    <div class="ev_subtitle">Completa eventos para ganar recompensas. Los eventos se reinician automáticamente.</div>

    {* ============ MENSAJE ============ *}
    {if $message}
        <div class="ev_msg {$msgType}">{$message}</div>
    {/if}

    {* ============ DIARIOS ============ *}
    {if $totalDaily > 0}
    <div class="ev_section">
        <div class="ev_section_title daily">
            <span>🟢 Eventos Diarios</span>
            <span class="count">{$totalDaily} misiones · reset 24h</span>
        </div>
        <div class="ev_grid">
            {foreach $dailyEvents as $event}
            <div class="ev_card{if $event.is_claimed} claimed{elseif $event.is_complete} complete{/if}">
                <div class="ev_card_header">
                    <div class="ev_card_icon">{$event.icon_emoji}</div>
                    <div class="ev_card_name" style="color:{$event.event_color};">{$event.event_name}</div>
                    {if $event.is_claimed}
                        <div class="ev_card_badge">✔ Hecho</div>
                    {elseif $event.is_complete}
                        <div class="ev_card_badge complete">⚡ Listo</div>
                    {/if}
                </div>
                <div class="ev_card_desc">{$event.event_desc}</div>

                <div class="ev_progress_wrap">
                    <div class="ev_progress_info">
                        <span>Progreso</span>
                        <span>{$event.progress_fmt} / {$event.target_fmt}</span>
                    </div>
                    <div class="ev_progress_bar">
                        <div class="ev_progress_fill{if $event.is_complete} complete{/if}" style="width:{$event.progress_pct}%;"></div>
                    </div>
                </div>

                <div class="ev_reward_box">
                    <span class="ev_reward_label">Recompensa</span>
                    <span class="ev_reward_value">{$event.reward_text}</span>
                </div>

                {if $event.is_claimed}
                    <div class="ev_claimed_btn">✔ Ya reclamado</div>
                {elseif $event.is_complete}
                    <form method="post" action="game.php?page=events" style="margin:0;">
                        <input type="hidden" name="action" value="claim">
                        <input type="hidden" name="event_id" value="{$event.event_id}">
                        <button type="submit" class="ev_claim_btn">🎁 Reclamar</button>
                    </form>
                {else}
                    <div class="ev_pending_btn">⏳ En progreso</div>
                {/if}
            </div>
            {/foreach}
        </div>
    </div>
    {/if}

    {* ============ SEMANALES ============ *}
    {if $totalWeekly > 0}
    <div class="ev_section">
        <div class="ev_section_title weekly">
            <span>🔵 Eventos Semanales</span>
            <span class="count">{$totalWeekly} misiones · reset 5 días</span>
        </div>
        <div class="ev_grid">
            {foreach $weeklyEvents as $event}
            <div class="ev_card{if $event.is_claimed} claimed{elseif $event.is_complete} complete{/if}">
                <div class="ev_card_header">
                    <div class="ev_card_icon">{$event.icon_emoji}</div>
                    <div class="ev_card_name" style="color:{$event.event_color};">{$event.event_name}</div>
                    {if $event.is_claimed}
                        <div class="ev_card_badge">✔ Hecho</div>
                    {elseif $event.is_complete}
                        <div class="ev_card_badge complete">⚡ Listo</div>
                    {/if}
                </div>
                <div class="ev_card_desc">{$event.event_desc}</div>

                <div class="ev_progress_wrap">
                    <div class="ev_progress_info">
                        <span>Progreso</span>
                        <span>{$event.progress_fmt} / {$event.target_fmt}</span>
                    </div>
                    <div class="ev_progress_bar">
                        <div class="ev_progress_fill{if $event.is_complete} complete{/if}" style="width:{$event.progress_pct}%;"></div>
                    </div>
                </div>

                <div class="ev_reward_box">
                    <span class="ev_reward_label">Recompensa</span>
                    <span class="ev_reward_value">{$event.reward_text}</span>
                </div>

                {if $event.is_claimed}
                    <div class="ev_claimed_btn">✔ Ya reclamado</div>
                {elseif $event.is_complete}
                    <form method="post" action="game.php?page=events" style="margin:0;">
                        <input type="hidden" name="action" value="claim">
                        <input type="hidden" name="event_id" value="{$event.event_id}">
                        <button type="submit" class="ev_claim_btn">🎁 Reclamar</button>
                    </form>
                {else}
                    <div class="ev_pending_btn">⏳ En progreso</div>
                {/if}
            </div>
            {/foreach}
        </div>
    </div>
    {/if}

    {* ============ ÉLITE ============ *}
    {if $totalElite > 0}
    <div class="ev_section">
        <div class="ev_section_title elite">
            <span>🟠 Evento Élite</span>
            <span class="count">{$totalElite} misión · reset 17 días</span>
        </div>
        <div class="ev_grid">
            {foreach $eliteEvents as $event}
            <div class="ev_card{if $event.is_claimed} claimed{elseif $event.is_complete} complete{/if}">
                <div class="ev_card_header">
                    <div class="ev_card_icon">{$event.icon_emoji}</div>
                    <div class="ev_card_name" style="color:{$event.event_color};">{$event.event_name}</div>
                    {if $event.is_claimed}
                        <div class="ev_card_badge">✔ Hecho</div>
                    {elseif $event.is_complete}
                        <div class="ev_card_badge complete">⚡ Listo</div>
                    {/if}
                </div>
                <div class="ev_card_desc">{$event.event_desc}</div>

                <div class="ev_progress_wrap">
                    <div class="ev_progress_info">
                        <span>Progreso</span>
                        <span>{$event.progress_fmt} / {$event.target_fmt}</span>
                    </div>
                    <div class="ev_progress_bar">
                        <div class="ev_progress_fill{if $event.is_complete} complete{/if}" style="width:{$event.progress_pct}%;"></div>
                    </div>
                </div>

                <div class="ev_reward_box">
                    <span class="ev_reward_label">Recompensa</span>
                    <span class="ev_reward_value">{$event.reward_text}</span>
                </div>

                {if $event.is_claimed}
                    <div class="ev_claimed_btn">✔ Ya reclamado</div>
                {elseif $event.is_complete}
                    <form method="post" action="game.php?page=events" style="margin:0;">
                        <input type="hidden" name="action" value="claim">
                        <input type="hidden" name="event_id" value="{$event.event_id}">
                        <button type="submit" class="ev_claim_btn">🎁 Reclamar</button>
                    </form>
                {else}
                    <div class="ev_pending_btn">⏳ En progreso</div>
                {/if}
            </div>
            {/foreach}
        </div>
    </div>
    {/if}

    {* ============ ADMIN ============ *}
    {if $totalAdmin > 0}
    <div class="ev_section">
        <div class="ev_section_title admin">
            <span>🟢 Eventos Especiales</span>
            <span class="count">{$totalAdmin} misiones</span>
        </div>
        <div class="ev_grid">
            {foreach $adminEvents as $event}
            <div class="ev_card{if $event.is_claimed} claimed{elseif $event.is_complete} complete{/if}">
                <div class="ev_card_header">
                    <div class="ev_card_icon">{$event.icon_emoji}</div>
                    <div class="ev_card_name" style="color:{$event.event_color};">{$event.event_name}</div>
                    {if $event.is_claimed}
                        <div class="ev_card_badge">✔ Hecho</div>
                    {elseif $event.is_complete}
                        <div class="ev_card_badge complete">⚡ Listo</div>
                    {/if}
                </div>
                <div class="ev_card_desc">{$event.event_desc}</div>

                <div class="ev_progress_wrap">
                    <div class="ev_progress_info">
                        <span>Progreso</span>
                        <span>{$event.progress_fmt} / {$event.target_fmt}</span>
                    </div>
                    <div class="ev_progress_bar">
                        <div class="ev_progress_fill{if $event.is_complete} complete{/if}" style="width:{$event.progress_pct}%;"></div>
                    </div>
                </div>

                <div class="ev_reward_box">
                    <span class="ev_reward_label">Recompensa</span>
                    <span class="ev_reward_value">{$event.reward_text}</span>
                </div>

                {if $event.is_claimed}
                    <div class="ev_claimed_btn">✔ Ya reclamado</div>
                {elseif $event.is_complete}
                    <form method="post" action="game.php?page=events" style="margin:0;">
                        <input type="hidden" name="action" value="claim">
                        <input type="hidden" name="event_id" value="{$event.event_id}">
                        <button type="submit" class="ev_claim_btn">🎁 Reclamar</button>
                    </form>
                {else}
                    <div class="ev_pending_btn">⏳ En progreso</div>
                {/if}
            </div>
            {/foreach}
        </div>
    </div>
    {/if}

    {* ============ HISTORIAL ============ *}
    <div class="ev_history">
        <h3>📜 Historial de Recompensas</h3>
        {if $history}
            {foreach $history as $h}
            <div class="ev_hist_row {$h.event_class}">
                <span class="hist_name">{$h.event_name}</span>
                <span class="hist_reward">{$h.reward_text}</span>
                <span class="hist_date">{$h.date_formatted}</span>
            </div>
            {/foreach}
        {else}
            <div class="ev_empty">Aún no has reclamado ninguna recompensa.</div>
        {/if}
    </div>

</div>
{/block}