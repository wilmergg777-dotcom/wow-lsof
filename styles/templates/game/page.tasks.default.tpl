{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.tasks.default.tpl === *}
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
   TAREAS — AstroIO v3.0
   Glassmorphism + Acento Cyan
   Prefijo: .astrotask_
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

.astrotask_wrap {
    max-width: 900px;
    margin: 0 auto;
    padding: 10px;
}

.astrotask_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 18px 22px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astrotask_header {
    text-align: center;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 14px;
    margin-bottom: 18px;
}

.astrotask_title {
    color: var(--accent-cyan);
    font-size: 22px;
    font-weight: bold;
    margin: 0 0 6px 0;
    text-transform: uppercase;
    letter-spacing: 2px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}

.astrotask_subtitle {
    color: var(--text-main);
    font-size: 12px;
    margin: 0 0 10px 0;
}

.astrotask_ntx_balance {
    color: var(--accent-purple);
    font-size: 13px;
    margin-top: 6px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.35);
}

.astrotask_ntx_balance b {
    color: #cc88ff;
    font-weight: 700;
    text-shadow: 0 0 10px rgba(139, 92, 246, 0.5);
}

.astrotask_tabs {
    display: flex;
    gap: 8px;
    margin-bottom: 18px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.15);
    padding-bottom: 8px;
}

.astrotask_tab {
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

.astrotask_tab:hover {
    background: rgba(0, 224, 255, 0.08);
    color: var(--accent-cyan);
    border-color: rgba(0, 224, 255, 0.4);
    transform: translateY(-1px);
}

.astrotask_tab.active {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
}

.astrotask_msg {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 12px;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astrotask_msg.success {
    background: rgba(74, 255, 136, 0.12);
    border: 1px solid var(--accent-green);
    color: var(--accent-green);
}

.astrotask_msg.error {
    background: rgba(239, 68, 68, 0.12);
    border: 1px solid var(--accent-red);
    color: var(--accent-red);
}

.astrotask_section {
    margin-bottom: 18px;
}

.astrotask_section_title {
    color: var(--accent-cyan);
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.15);
    padding-bottom: 6px;
    margin-bottom: 14px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}

.astrotask_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
}

.astrotask_card {
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

.astrotask_card:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35), 0 4px 20px rgba(0, 0, 0, 0.35);
    transform: translateY(-2px);
}

.astrotask_card.done {
    border-color: var(--accent-green);
    opacity: 0.85;
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.25), 0 4px 20px rgba(0, 0, 0, 0.35);
}

.astrotask_badge {
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

.astrotask_badge.done {
    background: rgba(74, 255, 136, 0.15);
    color: var(--accent-green);
    border-color: var(--accent-green);
}

.astrotask_name {
    color: var(--accent-cyan);
    font-size: 13px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
    line-height: 1.3;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}

.astrotask_desc {
    color: var(--text-muted);
    font-size: 11px;
    line-height: 1.5;
    margin-bottom: 12px;
    flex-grow: 1;
}

.astrotask_reward_box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: 8px 10px;
    margin-bottom: 12px;
}

.astrotask_reward_label {
    color: var(--text-muted);
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 3px;
}

.astrotask_reward_value {
    color: var(--accent-gold);
    font-size: 14px;
    font-weight: 700;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}

.astrotask_btn {
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

.astrotask_btn:hover {
    background: linear-gradient(135deg, #fbbf24 0%, #fde047 100%);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.55);
    color: #1a1000;
    transform: translateY(-2px);
}

.astrotask_btn:active {
    transform: translateY(0);
}

.astrotask_btn_done {
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

.astrotask_notes {
    background: rgba(0, 224, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 8px;
    padding: 12px 16px;
    margin-top: 18px;
}

.astrotask_notes h3 {
    color: var(--accent-cyan);
    font-size: 12px;
    margin: 0 0 8px 0;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}

.astrotask_notes ul {
    margin: 0;
    padding-left: 18px;
    color: var(--text-main);
    font-size: 11px;
    line-height: 1.7;
}

.astrotask_notes ul li {
    margin-bottom: 3px;
}

@media (max-width: 720px) {
    .astrotask_wrap { padding: 5px !important; }
    .astrotask_panel { padding: 10px !important; }
    .astrotask_header { padding-bottom: 10px !important; margin-bottom: 12px !important; }
    .astrotask_title { font-size: 18px !important; }
    .astrotask_subtitle { font-size: 11px !important; }
    .astrotask_ntx_balance { font-size: 11px !important; }

    /* Pestañas */
    .astrotask_tabs { gap: 4px !important; padding-bottom: 6px !important; }
    .astrotask_tab { padding: 6px 10px !important; font-size: 10px !important; flex: 1; text-align: center; }

    .astrotask_section_title { font-size: 11px !important; margin-bottom: 8px !important; }

    /* 🆕 FORZAR 1x2 EN LAS TARJETAS */
    .astrotask_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; }
    .astrotask_card { padding: 8px 6px !important; border-radius: 8px !important; }

    /* Contenido de la tarjeta */
    .astrotask_badge { font-size: 8px !important; padding: 1px 6px !important; margin-bottom: 6px !important; }
    .astrotask_name { font-size: 10px !important; margin-bottom: 4px !important; line-height: 1.1 !important; }
    .astrotask_desc { font-size: 9px !important; line-height: 1.2 !important; margin-bottom: 8px !important; flex-grow: 1; }

    /* Caja de recompensa */
    .astrotask_reward_box { padding: 5px 4px !important; margin-bottom: 8px !important; }
    .astrotask_reward_label { font-size: 8px !important; }
    .astrotask_reward_value { font-size: 10px !important; }

    /* Botones */
    .astrotask_btn, .astrotask_btn_done { 
        min-width: 100% !important; 
        padding: 6px 2px !important; 
        font-size: 9px !important; 
        letter-spacing: 0 !important; 
        line-height: 1.2 !important;
    }

    /* Notas al pie */
    .astrotask_notes { padding: 8px !important; font-size: 10px !important; }
    .astrotask_notes h3 { font-size: 11px !important; }
    .astrotask_notes ul { font-size: 10px !important; line-height: 1.4 !important; padding-left: 14px !important; }
}
</style>

<div class="astrotask_wrap">
    <div class="astrotask_panel">

        <div class="astrotask_header">
            <h1 class="astrotask_title">⭐ Tareas ⭐</h1>
            <p class="astrotask_subtitle">Completa las tareas y recibe recompensas exclusivas.</p>
            <div class="astrotask_ntx_balance">
                Tu saldo: <b>🌌 {$user_darkmatter} MO</b>
            </div>
        </div>

        <div class="astrotask_tabs">
            <a href="game.php?page=tasks" class="astrotask_tab {if $active_tab == 'tasks'}active{/if}">Tareas</a>
            <a href="game.php?page=tasks&tab=achievements" class="astrotask_tab {if $active_tab == 'achievements'}active{/if}">Logros</a>
        </div>

        {if $message}
            <div class="astrotask_msg {$message_type}">{$message}</div>
        {/if}

        <div class="astrotask_section">
            <h2 class="astrotask_section_title">Tareas disponibles</h2>
            <div class="astrotask_grid">
                {foreach $tasks as $task}
                    <div class="astrotask_card {if $task.is_done}done{/if}">

                        {if $task.can_do}
                            <div class="astrotask_badge">Pendiente</div>
                        {else}
                            <div class="astrotask_badge done">Completada</div>
                        {/if}

                        <div class="astrotask_name">{$task.title}</div>
                        <div class="astrotask_desc">{$task.description}</div>

                        <div class="astrotask_reward_box">
                            <div class="astrotask_reward_label">Recompensa</div>
                            <div class="astrotask_reward_value">
                                {if $task.reward_type == 'darkmatter'}
                                    🌌 {$task.reward_text} MO
                                {elseif $task.reward_type == 'ntx20'}
                                    💰 {$task.reward_text} NTX-20
                                {elseif $task.reward_type == 'metal'}
                                    🔩 {$task.reward_text} Metal
                                {elseif $task.reward_type == 'crystal'}
                                    💎 {$task.reward_text} Cristal
                                {elseif $task.reward_type == 'deuterium'}
                                    ⚗️ {$task.reward_text} Deuterio
                                {elseif $task.reward_type == 'none'}
                                    {$task.reward_text}
                                {else}
                                    {$task.reward_text} {$task.reward_type|upper}
                                {/if}
                            </div>
                        </div>

                        {if $task.can_do}
                            <a href="game.php?page=tasks&mode=doTask&id={$task.id}" class="astrotask_btn">Completar mision</a>
                        {else}
                            <span class="astrotask_btn_done">Completada</span>
                        {/if}

                    </div>
                {/foreach}
            </div>
        </div>

        <div class="astrotask_notes">
            <h3>Notas importantes</h3>
            <ul>
                <li>Las tareas se completan una sola vez. No se reinician.</li>
                <li>Al completar la tarea de vinculacion con el Bot de Telegram se desbloquea el Banco y el Mercado Negro.</li>
                <li>Al hacer clic en "Completar mision" seras redirigido al enlace correspondiente.</li>
                <li>Las recompensas se entregan al instante al completar la mision.</li>
            </ul>
        </div>

    </div>
</div>

{/block}