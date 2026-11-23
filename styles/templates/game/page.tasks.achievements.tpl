{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.tasks.achievements.tpl === *}
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


<style>
/* ═══════════════════════════════════════════════════════════
   LOGROS — AstroIO v3.0
   Glassmorphism + Acento Púrpura
   Prefijo: .astroach_
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

.astroach_wrap {
    max-width: 900px;
    margin: 0 auto;
    padding: 10px;
}

.astroach_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 18px 22px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astroach_header {
    text-align: center;
    border-bottom: 1px solid rgba(139, 92, 246, 0.2);
    padding-bottom: 14px;
    margin-bottom: 18px;
}

.astroach_title {
    color: var(--accent-purple);
    font-size: 22px;
    font-weight: bold;
    margin: 0 0 6px 0;
    text-transform: uppercase;
    letter-spacing: 2px;
    text-shadow: 0 0 10px rgba(139, 92, 246, 0.5);
}

.astroach_subtitle {
    color: var(--text-main);
    font-size: 12px;
    margin: 0 0 10px 0;
}

.astroach_balance {
    color: var(--accent-purple);
    font-size: 13px;
    margin-top: 6px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.35);
}

.astroach_balance b {
    color: #cc66ff;
    font-weight: 700;
    text-shadow: 0 0 10px rgba(139, 92, 246, 0.5);
}

.astroach_tabs {
    display: flex;
    gap: 8px;
    margin-bottom: 18px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.15);
    padding-bottom: 8px;
}

.astroach_tab {
    display: inline-block;
    padding: 8px 20px;
    border-radius: 6px 6px 0 0;
    background: rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-bottom: none;
    color: var(--text-muted);
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none;
    transition: all 0.25s ease;
}

.astroach_tab:hover {
    background: rgba(139, 92, 246, 0.08);
    color: var(--accent-purple);
    border-color: rgba(139, 92, 246, 0.4);
    transform: translateY(-1px);
}

.astroach_tab.active {
    background: linear-gradient(135deg, #7700cc 0%, #8b5cf6 100%);
    color: #ffffff;
    border-color: var(--accent-purple);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.35);
}

.astroach_msg {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 12px;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astroach_msg.success {
    background: rgba(74, 255, 136, 0.12);
    border: 1px solid var(--accent-green);
    color: var(--accent-green);
}

.astroach_msg.error {
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid var(--accent-red);
    color: var(--accent-red);
}

.astroach_section_title {
    color: var(--accent-purple);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.15);
    padding-bottom: 6px;
    margin-bottom: 14px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.3);
}

.astroach_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
}

.astroach_card {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 14px 12px;
    text-align: center;
    transition: all 0.25s ease;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}

.astroach_card:hover {
    border-color: var(--accent-purple);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.35), 0 4px 20px rgba(0, 0, 0, 0.35);
    transform: translateY(-2px);
}

.astroach_card.completed {
    border-color: var(--accent-gold);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.35), 0 4px 20px rgba(0, 0, 0, 0.35);
}

.astroach_card.claimed {
    border-color: var(--accent-green);
    opacity: 0.7;
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.25), 0 4px 20px rgba(0, 0, 0, 0.35);
}

.astroach_badge {
    display: inline-block;
    background: rgba(251, 191, 36, 0.15);
    color: var(--accent-gold);
    border: 1px solid var(--accent-gold);
    border-radius: 10px;
    padding: 2px 10px;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 10px;
    align-self: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astroach_badge.done {
    background: rgba(74, 255, 136, 0.15);
    color: var(--accent-green);
    border-color: var(--accent-green);
}

.astroach_name {
    color: var(--accent-purple);
    font-size: 13px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
    line-height: 1.3;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.3);
}

.astroach_req {
    color: var(--text-muted);
    font-size: 11px;
    line-height: 1.5;
    margin-bottom: 10px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 5px;
    padding: 8px 10px;
    text-align: left;
}

.astroach_req .req_title {
    color: var(--text-main);
    font-weight: 700;
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.astroach_req .req_level {
    color: var(--text-muted);
    margin-bottom: 4px;
}

.astroach_req .req_progress {
    color: var(--text-muted);
}

.astroach_req .req_progress b {
    color: var(--accent-cyan);
    font-weight: 700;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.4);
}

.astroach_progress {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 4px;
    height: 6px;
    overflow: hidden;
    margin-bottom: 10px;
}

.astroach_progress_bar {
    height: 100%;
    background: linear-gradient(90deg, #7700cc 0%, #8b5cf6 100%);
    transition: width 0.3s ease;
    box-shadow: 0 0 6px rgba(139, 92, 246, 0.6) inset;
}

.astroach_reward_box {
    background: rgba(139, 92, 246, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(139, 92, 246, 0.35);
    border-radius: 6px;
    padding: 8px 10px;
    margin-bottom: 12px;
}

.astroach_reward_label {
    color: var(--text-muted);
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 3px;
}

.astroach_reward_value {
    color: #cc66ff;
    font-size: 14px;
    font-weight: 700;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroach_btn {
    display: inline-block;
    min-width: 160px;
    max-width: 95%;
    padding: 8px 16px;
    border-radius: 6px;
    border: 1px solid var(--accent-gold);
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
    font-size: 11.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.25s ease;
    text-align: center;
    margin: 0 auto;
    align-self: center;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}

.astroach_btn:hover {
    background: linear-gradient(135deg, #fbbf24 0%, #fde047 100%);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.55);
    color: #1a1000;
    transform: translateY(-2px);
}

.astroach_btn:active {
    transform: translateY(0);
}

.astroach_btn_done {
    display: inline-block;
    min-width: 160px;
    max-width: 95%;
    padding: 8px 16px;
    border-radius: 6px;
    border: 1px solid var(--accent-green);
    background: rgba(74, 255, 136, 0.12);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: var(--accent-green);
    font-size: 11.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-align: center;
    cursor: default;
    margin: 0 auto;
    align-self: center;
}

.astroach_notes {
    background: rgba(139, 92, 246, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(139, 92, 246, 0.2);
    border-radius: 8px;
    padding: 12px 16px;
    margin-top: 18px;
}

.astroach_notes h3 {
    color: var(--accent-purple);
    font-size: 12px;
    margin: 0 0 8px 0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.3);
}

.astroach_notes ul {
    margin: 0;
    padding-left: 18px;
    color: var(--text-main);
    font-size: 11px;
    line-height: 1.7;
}

.astroach_notes ul li {
    margin-bottom: 3px;
}

@media (max-width: 720px) {
    .astroach_wrap { padding: 5px !important; }
    .astroach_panel { padding: 10px !important; }
    .astroach_header { padding-bottom: 10px !important; margin-bottom: 12px !important; }
    .astroach_title { font-size: 18px !important; }
    .astroach_subtitle { font-size: 11px !important; }
    .astroach_balance { font-size: 11px !important; }

    /* Pestañas */
    .astroach_tabs { gap: 4px !important; padding-bottom: 6px !important; }
    .astroach_tab { padding: 6px 10px !important; font-size: 10px !important; flex: 1; text-align: center; }

    .astroach_section_title { font-size: 11px !important; margin-bottom: 8px !important; }

    /* 🆕 FORZAR 1x2 EN LAS TARJETAS */
    .astroach_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; }
    .astroach_card { padding: 8px 6px !important; border-radius: 8px !important; }

    /* Contenido de la tarjeta */
    .astroach_badge { font-size: 8px !important; padding: 1px 6px !important; margin-bottom: 6px !important; }
    .astroach_name { font-size: 10px !important; margin-bottom: 4px !important; line-height: 1.1 !important; }

    /* Requisitos y Barra de progreso */
    .astroach_req { padding: 4px 6px !important; margin-bottom: 6px !important; font-size: 9px !important; line-height: 1.2 !important; }
    .astroach_req .req_title { font-size: 9px !important; }
    .astroach_req .req_level { font-size: 9px !important; }
    .astroach_req .req_progress { font-size: 9px !important; }
    .astroach_progress { height: 4px !important; margin-bottom: 6px !important; }

    /* Caja de recompensa */
    .astroach_reward_box { padding: 5px 4px !important; margin-bottom: 8px !important; }
    .astroach_reward_label { font-size: 8px !important; }
    .astroach_reward_value { font-size: 10px !important; }

    /* Botones */
    .astroach_btn, .astroach_btn_done { 
        min-width: 100% !important; 
        padding: 6px 2px !important; 
        font-size: 9px !important; 
        letter-spacing: 0 !important; 
        line-height: 1.2 !important;
    }

    /* Notas al pie */
    .astroach_notes { padding: 8px !important; font-size: 10px !important; }
    .astroach_notes h3 { font-size: 11px !important; }
    .astroach_notes ul { font-size: 10px !important; line-height: 1.4 !important; padding-left: 14px !important; }
}
</style>

<div class="astroach_wrap">
    <div class="astroach_panel">

        <div class="astroach_header">
            <h1 class="astroach_title">⭐ Logros ⭐</h1>
            <p class="astroach_subtitle">Completa logros y recibe Materia Oscura.</p>
            <div class="astroach_balance">
                Materia Oscura: <b>🌌 {$user_darkmatter|number_format} MO</b>
            </div>
        </div>

        <div class="astroach_tabs">
            <a href="game.php?page=tasks" class="astroach_tab">Tareas</a>
            <a href="game.php?page=tasks&tab=achievements" class="astroach_tab active">Logros</a>
        </div>

        {if $message}
            <div class="astroach_msg {$message_type}">{$message}</div>
        {/if}

        <div class="astroach_section_title">Logros disponibles</div>
        <div class="astroach_grid">
            {foreach $achievements as $ach}
                <div class="astroach_card {if $ach.is_claimed}claimed{elseif $ach.is_completed}completed{/if}">

                    {if $ach.is_completed}
                        <div class="astroach_badge">Completado</div>
                    {elseif $ach.is_claimed}
                        <div class="astroach_badge done">Reclamado</div>
                    {else}
                        <div class="astroach_badge">Nivel {$ach.level}</div>
                    {/if}

                    <div class="astroach_name">{$ach.title}</div>

                    <div class="astroach_req">
                        <div class="req_title">{$ach.requirement_name}</div>
                        <div class="req_level">Nivel {$ach.requirement_value}</div>
                        <div class="req_progress">Progreso: <b>{$ach.current_value} / {$ach.requirement_value}</b></div>
                    </div>

                    {if !$ach.is_claimed}
                        <div class="astroach_progress">
                            <div class="astroach_progress_bar" style="width: {if $ach.requirement_value > 0}{math equation="(x/y)*100" x=$ach.current_value y=$ach.requirement_value}{else}0{/if}%;"></div>
                        </div>
                    {/if}

                    <div class="astroach_reward_box">
                        <div class="astroach_reward_label">Recompensa</div>
                        <div class="astroach_reward_value">🌌 {$ach.reward_text}</div>
                    </div>

                    {if $ach.is_completed}
                        <a href="game.php?page=tasks&tab=achievements&mode=claimAch&code={$ach.code}" class="astroach_btn">Reclamar logro</a>
                    {elseif $ach.is_claimed}
                        <span class="astroach_btn_done">Completado</span>
                    {/if}

                </div>
            {/foreach}
        </div>

        <div class="astroach_notes">
            <h3>Notas importantes</h3>
            <ul>
                <li>Cada cadena tiene 10 niveles. Solo se muestra el nivel actual.</li>
                <li>Al reclamar un logro, se desbloquea el siguiente nivel de esa cadena.</li>
                <li>Las recompensas se entregan en Materia Oscura (MO).</li>
                <li>Los logros se verifican automaticamente al entrar a esta pestana.</li>
            </ul>
        </div>

    </div>
</div>

{/block}