{extends file="layout.full.tpl"}

{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.faction.default.tpl === *}
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

{* AstroIO - Página de Facciones v4.0 (Diseño idéntico a Eventos) *}

<style>
/* ═══════════════════════════════════════════════════════════
   FACCIONES + EVENTOS — AstroIO v4.0
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
.ev_msg.success { background: rgba(74, 255, 136, 0.12); border-color: var(--accent-green); color: var(--accent-green); }
.ev_msg.error   { background: rgba(239, 68, 68, 0.12); border-color: var(--accent-red); color: var(--accent-red); }
.ev_msg.info    { background: rgba(0, 224, 255, 0.10); border-color: var(--accent-cyan); color: var(--accent-cyan); }

/* ============ PESTAÑAS ============ */
.ev_tabs { display: flex; gap: 10px; margin-bottom: 20px; border-bottom: 1px solid var(--border-color); padding-bottom: 10px; }
.ev_tab_btn { padding: 10px 20px; background: rgba(15, 23, 42, 0.6); border: 1px solid var(--border-color); border-radius: 8px; color: var(--text-muted); text-decoration: none; font-size: 14px; font-weight: bold; transition: all 0.2s ease; display: flex; align-items: center; gap: 8px; }
.ev_tab_btn:hover { background: rgba(139, 92, 246, 0.15); color: var(--text-title); border-color: var(--accent-purple); }
.ev_tab_btn.active { background: linear-gradient(135deg, #7700cc 0%, #8b5cf6 100%); color: #fff; border-color: var(--accent-purple); box-shadow: 0 0 15px rgba(139, 92, 246, 0.4); }

/* ============ SELECCIÓN DE FACCIÓN ============ */
.fp_grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px; }
.fp_card { background: var(--bg-card); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); border: 1px solid var(--border-color); border-radius: 12px; padding: 16px; transition: all 0.25s ease; cursor: pointer; position: relative; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35); }
.fp_card:hover { border-color: var(--accent-purple); box-shadow: 0 0 24px rgba(139, 92, 246, 0.35), 0 8px 24px rgba(0, 0, 0, 0.4); transform: translateY(-3px); }
.fp_card.selected { border-color: var(--accent-purple); box-shadow: 0 0 22px rgba(139, 92, 246, 0.5); background: linear-gradient(135deg, rgba(31, 18, 58, 0.85), rgba(48, 26, 80, 0.85)); }
.fp_card.current { border-color: var(--accent-green); box-shadow: 0 0 22px rgba(74, 255, 136, 0.5); background: linear-gradient(135deg, rgba(15, 36, 48, 0.85), rgba(20, 64, 47, 0.85)); }
.fp_card_header { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; padding-bottom: 10px; border-bottom: 1px solid rgba(139, 92, 246, 0.15); }
.fp_icon { font-size: 14px; font-weight: 700; letter-spacing: 1px; padding: 6px 10px; border-radius: 8px; background: rgba(139, 92, 246, 0.15); border: 1px solid rgba(139, 92, 246, 0.3); color: var(--accent-purple); min-width: 60px; text-align: center; }
.fp_name { font-size: 18px; font-weight: bold; letter-spacing: 1px; }
.fp_desc { font-size: 12px; color: var(--text-muted); line-height: 1.5; margin-bottom: 12px; min-height: 32px; }
.fp_bonuses { display: grid; grid-template-columns: 1fr 1fr; gap: 5px; margin-bottom: 14px; }
.fp_bonus { font-size: 11px; padding: 5px 8px; border-radius: 6px; background: rgba(74, 255, 136, 0.08); border: 1px solid rgba(74, 255, 136, 0.25); color: #a8e8c0; display: flex; align-items: center; gap: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0; }
.fp_bonus .bval { color: var(--accent-green); font-weight: 700; font-family: 'Courier New', monospace; margin-left: auto; }
.fp_select_btn { width: 100%; padding: 10px; background: linear-gradient(135deg, #7700cc 0%, #8b5cf6 100%); color: #fff; border: 1px solid var(--accent-purple); border-radius: 8px; font-size: 12px; font-weight: bold; letter-spacing: 1.5px; cursor: pointer; transition: all 0.25s ease; text-transform: uppercase; font-family: inherit; }
.fp_select_btn:hover { background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%); box-shadow: 0 0 20px rgba(139, 92, 246, 0.5); transform: translateY(-2px); }
.fp_select_btn:disabled { opacity: 0.5; cursor: not-allowed; background: rgba(30, 41, 59, 0.85); border-color: var(--border-color); color: var(--text-muted); transform: none; box-shadow: none; }
.fp_select_btn.current_btn { background: linear-gradient(135deg, #228833 0%, #4aff88 100%); border-color: var(--accent-green); cursor: default; color: #fff; }

/* ============ MISIONES (ESTILO EVENTOS) ============ */
.ev_section { margin-bottom: 30px; }
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
.ev_section_title.personal { background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)); border-left: 4px solid var(--accent-cyan); }
.ev_section_title.global { background: linear-gradient(135deg, rgba(119, 0, 204, 0.85), rgba(139, 92, 246, 0.85)); border-left: 4px solid var(--accent-purple); }
.ev_section_title .count { font-size: 11px; color: #cceeff; background: rgba(0, 0, 0, 0.3); padding: 2px 8px; border-radius: 10px; text-shadow: none; }

.ev_grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; }
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
.ev_card:hover { border-color: var(--accent-cyan); box-shadow: 0 4px 20px rgba(0, 224, 255, 0.3), 0 4px 20px rgba(0, 0, 0, 0.35); transform: translateY(-2px); }
.ev_card.complete { border-color: var(--accent-green); box-shadow: 0 0 20px rgba(74, 255, 136, 0.3), 0 4px 20px rgba(0, 0, 0, 0.35); }
.ev_card.claimed { opacity: 0.5; border-color: #555; }
.ev_card.claimed:hover { transform: none; box-shadow: none; }

.ev_card_header { display: flex; align-items: center; gap: 10px; padding-bottom: 8px; border-bottom: 1px solid rgba(0, 224, 255, 0.15); }
.ev_card_icon { font-size: 28px; line-height: 1; flex-shrink: 0; }
.ev_card_name { font-size: 14px; font-weight: 700; letter-spacing: 0.5px; flex: 1; min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.ev_card_badge { font-size: 10px; padding: 2px 8px; border-radius: 6px; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); border: 1px solid rgba(0, 224, 255, 0.3); }
.ev_card_badge.complete { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); border-color: rgba(74, 255, 136, 0.4); }
.ev_card_desc { font-size: 12px; color: var(--text-muted); line-height: 1.4; min-height: 34px; }

.ev_progress_wrap { display: flex; flex-direction: column; gap: 4px; }
.ev_progress_info { display: flex; justify-content: space-between; font-size: 11px; color: var(--text-muted); font-family: 'Courier New', monospace; }
.ev_progress_bar { height: 12px; background: rgba(0, 0, 0, 0.5); border-radius: 6px; overflow: hidden; border: 1px solid rgba(0, 224, 255, 0.2); position: relative; }
.ev_progress_fill { height: 100%; background: linear-gradient(90deg, #0066cc, var(--accent-cyan)); transition: width 0.5s ease; box-shadow: 0 0 8px rgba(0, 224, 255, 0.6) inset; }
.ev_progress_fill.complete { background: linear-gradient(90deg, #228833, var(--accent-green)); box-shadow: 0 0 8px rgba(74, 255, 136, 0.6) inset; }
.ev_progress_fill.global_bar { background: linear-gradient(90deg, #cc0000, #ff4444); box-shadow: 0 0 8px rgba(255, 68, 68, 0.6) inset; }

.ev_reward_box { display: flex; align-items: center; justify-content: space-between; background: rgba(0, 0, 0, 0.3); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px); border-radius: 6px; padding: 8px 10px; border: 1px dashed rgba(0, 224, 255, 0.25); }
.ev_reward_label { font-size: 11px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; }
.ev_reward_value { font-size: 13px; color: var(--accent-gold); font-weight: 700; font-family: 'Courier New', monospace; text-shadow: 0 0 8px rgba(251, 191, 36, 0.3); }

.ev_claim_btn { width: 100%; padding: 10px; background: linear-gradient(135deg, #228833 0%, #4aff88 100%); color: #fff; border: 1px solid var(--accent-green); border-radius: 6px; font-size: 12px; font-weight: 700; letter-spacing: 1.5px; cursor: pointer; text-transform: uppercase; transition: all 0.25s ease; text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4); font-family: inherit; }
.ev_claim_btn:hover { background: linear-gradient(135deg, #4aff88 0%, #86ffb8 100%); box-shadow: 0 0 20px rgba(74, 255, 136, 0.6); transform: translateY(-2px); }
.ev_claimed_btn { width: 100%; padding: 10px; background: rgba(0, 0, 0, 0.4); color: #555; border: 1px solid #444; border-radius: 6px; font-size: 12px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; text-align: center; backdrop-filter: blur(4px); }
.ev_pending_btn { width: 100%; padding: 10px; background: rgba(0, 0, 0, 0.4); color: var(--text-muted); border: 1px solid var(--border-color); border-radius: 6px; font-size: 12px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; text-align: center; backdrop-filter: blur(4px); }

/* Inputs para entregar recursos */
.ev_input_group { display: flex; gap: 8px; margin-top: 5px; }
.ev_input_text { flex: 1; padding: 10px; border-radius: 6px; background: rgba(0,0,0,0.5); border: 1px solid #1e293b; color: #fff; font-family: inherit; font-size: 12px; }
.ev_input_text:focus { border-color: var(--accent-cyan); outline: none; }

@media (max-width: 700px) {
    .ev_wrap { padding: 8px !important; }
    .ev_title { font-size: 20px !important; }
    .ev_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; }
    .ev_card { padding: 8px !important; border-radius: 8px !important; gap: 6px !important; }
    .ev_card_header { flex-direction: column !important; align-items: center !important; text-align: center !important; gap: 4px !important; padding-bottom: 6px !important; }
    .ev_card_icon { font-size: 24px !important; }
    .ev_card_name { font-size: 11px !important; white-space: normal !important; line-height: 1.1 !important; }
    .ev_card_badge { font-size: 8px !important; padding: 1px 4px !important; }
    .ev_card_desc { font-size: 9px !important; line-height: 1.3 !important; min-height: 35px !important; }
    .ev_progress_info { font-size: 9px !important; flex-direction: column !important; align-items: center !important; gap: 2px !important;}
    .ev_progress_bar { height: 8px !important; }
    .ev_reward_box { flex-direction: column !important; align-items: center !important; padding: 6px 4px !important; gap: 2px !important; }
    .ev_reward_label { font-size: 8px !important; }
    .ev_reward_value { font-size: 10px !important; text-align: center !important; }
    .ev_claim_btn, .ev_claimed_btn, .ev_pending_btn { padding: 6px 2px !important; font-size: 9px !important; letter-spacing: 0px !important; }
    .ev_input_group { flex-direction: column; }
}
</style>

<div class="ev_wrap">

    <div class="ev_title">⚔️ Facciones</div>
    <div class="ev_subtitle">Elige tu facción. La primera elección es gratuita; los cambios cuestan {$changeCost} de Materia Oscura.</div>

    {* ============ ESTADO ============ *}
    <div class="ev_msg info" style="display:flex; justify-content:space-between; align-items:center;">
        <span><strong>FACCIÓN ACTUAL:</strong> {$myFaction.faction_name|default:'Ninguna'}</span>
        <span><strong>TU MO:</strong> {$currentDM}</span>
    </div>

    {* ============ PESTAÑAS ============ *}
    <div class="ev_tabs">
        <a href="game.php?page=faction" class="ev_tab_btn {if $tab_active == 'default'}active{/if}">
            🛡️ Elegir Facción
        </a>
        {if $hasChosen}
            <a href="game.php?page=faction&tab=missions" class="ev_tab_btn {if $tab_active == 'missions'}active{/if}">
                🎯 Misiones
            </a>
        {/if}
    </div>

    {if $message}
        <div class="ev_msg {$msgType}">{$message}</div>
    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* PESTAÑA 1: SELECCIÓN DE FACCIÓN                        *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab_active == 'default'}
        <form method="post" action="game.php?page=faction" id="fp_form">
            <input type="hidden" name="action" value="select">
            <input type="hidden" name="faction_id" id="fp_faction_input" value="0">

            <div class="fp_grid">
                {foreach $factions as $faction}
                <div class="fp_card{if $hasChosen && $myFaction && $myFaction.faction_id == $faction.faction_id} current{/if}"
                     data-id="{$faction.faction_id}">
                    <div class="fp_card_header">
                        <div class="fp_icon">{$faction.faction_icon}</div>
                        <div class="fp_name" style="color:{$faction.faction_color};">{$faction.faction_name}</div>
                    </div>
                    <div class="fp_desc">{$faction.faction_desc}</div>

                    <div class="fp_bonuses">
                        {if $faction.bonus_ship_time != 0}<div class="fp_bonus">🚀 T. naves<span class="bval">{$faction.bonus_ship_time}%</span></div>{/if}
                        {if $faction.bonus_build_time != 0}<div class="fp_bonus">🏗️ T. construcción<span class="bval">{$faction.bonus_build_time}%</span></div>{/if}
                        {if $faction.bonus_defense_time != 0}<div class="fp_bonus">🛡️ T. defensas<span class="bval">{$faction.bonus_defense_time}%</span></div>{/if}
                        {if $faction.bonus_research_time != 0}<div class="fp_bonus">🔬 T. investigación<span class="bval">{$faction.bonus_research_time}%</span></div>{/if}
                        {if $faction.bonus_flight_time != 0}<div class="fp_bonus">💨 T. de vuelo<span class="bval">{$faction.bonus_flight_time}%</span></div>{/if}
                        {if $faction.bonus_fuel != 0}<div class="fp_bonus">⛽ Combustible<span class="bval">{$faction.bonus_fuel}%</span></div>{/if}
                        {if $faction.bonus_resources != 0}<div class="fp_bonus">⛏️ Producción<span class="bval">+{$faction.bonus_resources}%</span></div>{/if}
                        {if $faction.bonus_defense_cost != 0}<div class="fp_bonus">💰 Coste defensas<span class="bval">{$faction.bonus_defense_cost}%</span></div>{/if}
                        {if $faction.bonus_research_cost != 0}<div class="fp_bonus">💎 Coste investigación<span class="bval">{$faction.bonus_research_cost}%</span></div>{/if}
                        {if $faction.bonus_ship_cost != 0}<div class="fp_bonus">⚙️ Coste naves<span class="bval">{$faction.bonus_ship_cost}%</span></div>{/if}
                        {if $faction.bonus_trader_cost != 0}<div class="fp_bonus">⚖️ Coste mercantes<span class="bval">{$faction.bonus_trader_cost}%</span></div>{/if}
                        {if $faction.bonus_expeditions != 0}<div class="fp_bonus">🧭 Expediciones<span class="bval">+{$faction.bonus_expeditions}</span></div>{/if}
                        {if $faction.bonus_exp_resources != 0}<div class="fp_bonus">💎 Rec. expedición<span class="bval">+{$faction.bonus_exp_resources}%</span></div>{/if}
                    </div>

                    {if $hasChosen && $myFaction && $myFaction.faction_id == $faction.faction_id}
                        <button type="button" class="fp_select_btn current_btn" disabled>✔ Facción actual</button>
                    {else}
                        <button type="button" class="fp_select_btn">Seleccionar</button>
                    {/if}
                </div>
                {/foreach}
            </div>

            <div style="text-align: center; margin-top: 30px; padding: 20px; background: var(--bg-card); border-radius: 12px; border: 1px solid var(--border-color);">
                <div style="font-size: 13px; color: var(--text-muted); margin-bottom: 12px;" id="fp_hint">
                    {if $hasChosen}
                        Elige otra facción y pulsa confirmar. Se descontarán <strong>{$changeCost}</strong> MO.
                    {else}
                        ⚠️ Selecciona una facción para continuar.
                    {/if}
                </div>
                {if $hasChosen}
                    <div style="font-size: 14px; color: var(--accent-purple); font-weight: 700; margin-bottom: 10px;">Coste del cambio: {$changeCost} MO · Tienes: {$currentDM}</div>
                {/if}
                <button type="submit" class="ev_claim_btn" id="fp_submit" disabled style="width: auto; padding: 14px 40px; font-size: 15px;">
                    {if $hasChosen}Cambiar facción{else}Confirmar elección{/if}
                </button>
            </div>
        </form>
    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* PESTAÑA 2: MISIONES (ESTILO EVENTOS)                   *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab_active == 'missions'}
        
        {* ============ MISIÓN PERSONAL ============ *}
        <div class="ev_section">
            <div class="ev_section_title personal">
                <span>🎯 Misión Personal (Diaria)</span>
                <span class="count">Reset 24h</span>
            </div>
            <div class="ev_grid">
                <div class="ev_card{if $personalProgress.claimed} claimed{elseif $personalProgress.progress >= $personalMission.target_amount} complete{/if}">
                    <div class="ev_card_header">
                        <div class="ev_card_icon">{$personalMission.icon|default:'🎯'}</div>
                        <div class="ev_card_name">{$personalMission.name|default:'Misión sin nombre'}</div>
                        {if $personalProgress.claimed}
                            <div class="ev_card_badge">✔ Hecho</div>
                        {elseif $personalProgress.progress >= $personalMission.target_amount}
                            <div class="ev_card_badge complete">⚡ Listo</div>
                        {/if}
                    </div>
                    
                    <div class="ev_card_desc">{$personalMission.description|default:'Completa esta misión para obtener una recompensa.'}</div>

                    {assign var="p_prog" value=$personalProgress.progress|default:0}
                    {assign var="p_target" value=$personalMission.target_amount|default:1}
                    {math equation="min(100, (p/t)*100)" p=$p_prog t=$p_target assign="p_pct"}
                    {assign var="p_done" value=($p_prog >= $p_target)}

                    <div class="ev_progress_wrap">
                        <div class="ev_progress_info">
                            <span>Progreso</span>
                            <span>{$p_prog|number} / {$p_target|number}</span>
                        </div>
                        <div class="ev_progress_bar">
                            <div class="ev_progress_fill{if $p_done} complete{/if}" style="width:{$p_pct}%;"></div>
                        </div>
                    </div>

                    <div class="ev_reward_box">
                        <span class="ev_reward_label">Recompensa</span>
                        <span class="ev_reward_value">
                            {if $personalMission.reward_type == 'ntx20'}
                                {$personalRewardData.amount|default:0} NTX-20
                            {elseif $personalMission.reward_type == 'darkmatter'}
                                {$personalRewardData.amount|default:0} MO
                            {elseif $personalMission.reward_type == 'container'}
                                {$personalRewardData.amount|default:1} Cofre(s)
                            {elseif $personalMission.reward_type == 'ship'}
                                {$personalRewardData.amount|default:1} Nave(s)
                            {elseif $personalMission.reward_type == 'defense'}
                                {$personalRewardData.amount|default:1} Defensa(s)
                            {elseif $personalMission.reward_type == 'resource'}
                                {if $personalRewardData.metal > 0}{$personalRewardData.metal|number} Metal {/if}
                                {if $personalRewardData.crystal > 0}{$personalRewardData.crystal|number} Cristal {/if}
                                {if $personalRewardData.deuterium > 0}{$personalRewardData.deuterium|number} Deuterio{/if}
                            {else}
                                Recursos
                            {/if}
                        </span>
                    </div>

                    {if $personalProgress.claimed}
                        <div class="ev_claimed_btn">✔ Ya reclamado</div>
                    {elseif $p_done}
                        <form method="post" action="game.php?page=faction&tab=missions" style="margin:0;">
                            <input type="hidden" name="action" value="claimPersonal">
                            <input type="hidden" name="mission_id" value="{$personalMission.id|default:0}">
                            <button type="submit" class="ev_claim_btn">🎁 Reclamar</button>
                        </form>
                    {else}
                        {assign var="p_act" value=$personalMission.action_type|default:''}
                        {if $p_act == 'deliver_metal' || $p_act == 'deliver_crystal' || $p_act == 'deliver_deuterium'}
                            {assign var="res_name" value=$p_act|replace:'deliver_':''}
                            <form method="post" action="game.php?page=faction&tab=missions" class="ev_input_group">
                                <input type="hidden" name="action" value="deliver">
                                <input type="hidden" name="res_type" value="{$res_name}">
                                <input type="number" name="amount" min="1" placeholder="Cant. de {$res_name}..." class="ev_input_text" required>
                                <button type="submit" class="ev_claim_btn" style="width:auto; padding:10px 20px;">ENTREGAR</button>
                            </form>
                        {elseif $p_act == 'deliver_all'}
                            <form method="post" action="game.php?page=faction&tab=missions" style="margin:0;">
                                <input type="hidden" name="action" value="deliver_all">
                                <button type="submit" class="ev_claim_btn">📦 Entregar {$personalMission.target_amount|number} de C/U</button>
                            </form>
                        {else}
                            <div class="ev_pending_btn">⏳ En progreso</div>
                        {/if}
                    {/if}
                </div>
            </div>
        </div>

        {* ============ MISIÓN GLOBAL ============ *}
        <div class="ev_section">
            <div class="ev_section_title global">
                <span>🌍 Misión Global de la Facción</span>
                <span class="count">Buff de 5 días</span>
            </div>
            <div class="ev_grid">
                <div class="ev_card{if $globalMission.status == 'bonus_active'} complete{/if}">
                    <div class="ev_card_header">
                        <div class="ev_card_icon">{$globalMission.icon|default:'🌍'}</div>
                        <div class="ev_card_name">{$globalMission.name|default:'Misión Global'}</div>
                        {if $globalMission.status == 'bonus_active'}
                            <div class="ev_card_badge complete" style="color:var(--accent-gold); border-color:var(--accent-gold);">BONUS ACTIVO</div>
                        {/if}
                    </div>

                    <div class="ev_card_desc">{$globalMission.description|default:'Toda la facción debe aportar para completar la barra.'}</div>

                    {if $globalMission.status == 'bonus_active'}
                        <div class="ev_reward_box" style="justify-content:center; background:rgba(251, 191, 36, 0.1); border-color:var(--accent-gold);">
                            <span class="ev_reward_value" style="color:var(--accent-gold); font-size: 15px;">
                                🎁 Buff activo: {$globalMission.bonus_type|capitalize} (+{$globalMission.bonus_value}%)
                            </span>
                        </div>
                        <div style="font-size: 11px; color: var(--text-muted); text-align: center;">
                            Termina el: {$globalMission.bonus_end|date_format:"%d/%m/%Y a las %H:%M"}
                        </div>
                    {else}
                        {assign var="g_prog" value=$globalMission.progress|default:0}
                        {assign var="g_target" value=$globalMission.target|default:1}
                        {math equation="min(100, (p/t)*100)" p=$g_prog t=$g_target assign="g_pct"}

                        <div class="ev_progress_wrap">
                            <div class="ev_progress_info">
                                <span>HP de la Facción</span>
                                <span>{$g_prog|number} / {$g_target|number}</span>
                            </div>
                            <div class="ev_progress_bar">
                                <div class="ev_progress_fill global_bar" style="width:{$g_pct}%;"></div>
                            </div>
                        </div>

                        <div class="ev_reward_box">
                            <span class="ev_reward_label">Recompensa</span>
                            <span class="ev_reward_value" title="{$globalBuffPool}">1 Buff (Aleatorio)</span>
                        </div>
                        
                        {if $globalBuffPool}
                            <div style="font-size:10px; color:var(--text-muted); margin-top:-4px; text-align:center;">
                                Posibles buffs: {$globalBuffPool}
                            </div>
                        {/if}

                        {if $globalMission.action_type|default:'' == 'deliver_metal'}
                            <form method="post" action="game.php?page=faction&tab=missions" class="ev_input_group">
                                <input type="hidden" name="action" value="deliver">
                                <input type="hidden" name="res_type" value="metal">
                                <input type="number" name="amount" min="1" placeholder="Cant. de metal..." class="ev_input_text" required>
                                <button type="submit" class="ev_claim_btn" style="width:auto; padding:10px 20px;">APORTAR</button>
                            </form>
                        {else}
                            <div class="ev_pending_btn">⏳ En progreso</div>
                        {/if}
                    {/if}
                </div>
            </div>
        </div>
    {/if}

</div>

<script>
(function(){
    var input     = document.getElementById('fp_faction_input');
    var submit    = document.getElementById('fp_submit');
    var hint      = document.getElementById('fp_hint');
    var hasChosen = {if $hasChosen}true{else}false{/if};
    var cost      = {$changeCost};

    if (!input) return; 

    document.querySelectorAll('.fp_card').forEach(function(card){
        card.addEventListener('click', function(){
            if (card.classList.contains('current')) return;

            var id = card.dataset.id;

            document.querySelectorAll('.fp_card').forEach(function(c){
                if (!c.classList.contains('current')) c.classList.remove('selected');
            });
            card.classList.add('selected');
            input.value = id;

            if (!hasChosen) {
                hint.textContent = '✅ Listo. Pulsa "Confirmar elección".';
                hint.style.color = '#4aff88';
            } else {
                hint.innerHTML = '✅ Vas a cambiar de facción. Se descontarán <strong>' + cost + '</strong> MO.';
                hint.style.color = '#8b5cf6';
            }
            submit.disabled = false;
        });
    });
})();
</script>
{/block}