{extends file="layout.full.tpl"}

{block name="content"}
{* AstroIO - MOP Raza y Facción v3.0 *}

<style>
/* ═══════════════════════════════════════════════════════════
   RAZA + FACCIÓN — AstroIO v3.0
   Glassmorphism + Acento Cyan
   Prefijo: .ra_
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

.ra_wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 20px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}
.ra_title {
    font-size: 26px;
    color: var(--accent-cyan);
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.6);
    margin-bottom: 6px;
    letter-spacing: 1px;
}
.ra_subtitle {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 22px;
}
.ra_msg {
    padding: 14px 18px;
    border-radius: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    border-left: 4px solid;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.ra_msg.success {
    background: rgba(74, 255, 136, 0.12);
    border-color: var(--accent-green);
    color: var(--accent-green);
}
.ra_msg.error {
    background: rgba(239, 68, 68, 0.12);
    border-color: var(--accent-red);
    color: var(--accent-red);
}
.ra_msg.info {
    background: rgba(0, 224, 255, 0.10);
    border-color: var(--accent-cyan);
    color: var(--accent-cyan);
}
.ra_section {
    margin-bottom: 34px;
}
.ra_section h2 {
    font-size: 18px;
    color: var(--accent-cyan);
    margin-bottom: 14px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    letter-spacing: 1px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.ra_grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 14px;
}
.ra_card {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    transition: all 0.25s ease;
    cursor: pointer;
    position: relative;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.ra_card:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 24px rgba(0, 224, 255, 0.35), 0 8px 24px rgba(0, 0, 0, 0.4);
    transform: translateY(-3px);
}
.ra_card.selected {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 22px rgba(0, 224, 255, 0.5);
    background: linear-gradient(135deg, rgba(18, 36, 58, 0.85), rgba(26, 48, 80, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.ra_card_header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 10px;
}
.ra_icon {
    font-size: 32px;
    line-height: 1;
}
.ra_name {
    font-size: 17px;
    color: var(--accent-cyan);
    font-weight: bold;
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}
.ra_desc {
    font-size: 12px;
    color: var(--text-muted);
    line-height: 1.5;
    margin-bottom: 12px;
    min-height: 48px;
}
.ra_bonuses {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
}
.ra_bonus {
    font-size: 11px;
    padding: 3px 8px;
    border-radius: 6px;
    background: rgba(0, 224, 255, 0.10);
    border: 1px solid rgba(0, 224, 255, 0.25);
    color: var(--text-main);
}
.ra_bonus.positive { color: var(--accent-green); border-color: rgba(74, 255, 136, 0.4); }
.ra_bonus.negative { color: var(--accent-red); border-color: rgba(239, 68, 68, 0.4); }
.ra_select_btn {
    margin-top: 14px;
    width: 100%;
    padding: 10px;
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #fff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.ra_select_btn:hover {
    background: linear-gradient(135deg, #0099ff 0%, #00ccff 100%);
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.ra_select_btn:active {
    transform: translateY(0);
}
.ra_mychoice {
    background: linear-gradient(135deg, rgba(10, 31, 46, 0.75), rgba(18, 48, 69, 0.75));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid var(--accent-cyan);
    border-radius: 14px;
    padding: 22px;
    box-shadow: 0 0 30px rgba(0, 224, 255, 0.3);
    margin-bottom: 30px;
    display: flex;
    gap: 22px;
    align-items: center;
    flex-wrap: wrap;
}
.ra_mychoice .ra_mc_icon {
    font-size: 56px;
    filter: drop-shadow(0 0 12px rgba(0, 224, 255, 0.6));
}
.ra_mychoice .ra_mc_info h3 {
    color: var(--accent-cyan);
    font-size: 20px;
    margin: 0 0 4px 0;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}
.ra_mychoice .ra_mc_info span {
    color: var(--text-muted);
    font-size: 13px;
    display: block;
    margin-bottom: 4px;
}
.ra_footer {
    text-align: center;
    margin-top: 30px;
    padding: 20px;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 12px;
    border: 1px solid var(--border-color);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}
.ra_footer .ra_hint {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 12px;
}
.ra_footer .ra_confirm {
    padding: 14px 40px;
    background: linear-gradient(135deg, #7700cc 0%, #8b5cf6 100%);
    color: #fff;
    border: 1px solid var(--accent-purple);
    border-radius: 10px;
    font-size: 15px;
    font-weight: bold;
    letter-spacing: 2px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.ra_footer .ra_confirm:hover:not(:disabled) {
    background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
    box-shadow: 0 0 26px rgba(139, 92, 246, 0.6);
    transform: translateY(-2px);
}
.ra_footer .ra_confirm:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    background: rgba(30, 41, 59, 0.85);
    border-color: var(--border-color);
}
@media (max-width: 700px) {
    .ra_wrap { padding: 8px !important; }
    .ra_title { font-size: 20px !important; }
    .ra_subtitle { font-size: 11px !important; margin-bottom: 15px !important; }

    /* 🆕 FORZAR 1x2 (2 COLUMNAS) */
    .ra_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; }
    .ra_card { padding: 8px !important; }
    .ra_card_header { flex-direction: column !important; text-align: center !important; gap: 4px !important; }
    .ra_icon { font-size: 24px !important; }
    .ra_name { font-size: 13px !important; }
    .ra_desc { font-size: 9px !important; line-height: 1.3 !important; min-height: 40px !important; margin-bottom: 8px !important; }

    /* Los bonuses en formato columna dentro de la tarjeta */
    .ra_bonuses { flex-direction: column !important; gap: 3px !important; }
    .ra_bonus { font-size: 8px !important; padding: 2px 4px !important; }

    .ra_select_btn { font-size: 9px !important; padding: 6px !important; margin-top: 8px !important; }
    .ra_footer { padding: 12px !important; margin-top: 15px !important; }
    .ra_footer .ra_hint { font-size: 11px !important; }
    .ra_footer .ra_confirm { font-size: 12px !important; padding: 10px 20px !important; width: 100% !important; }
    
    /* La tarjeta de "Mi Elección" se apila bien */
    .ra_mychoice { padding: 12px !important; gap: 12px !important; flex-direction: column !important; text-align: center !important; }
    .ra_mychoice .ra_mc_icon { font-size: 36px !important; }
    .ra_mychoice .ra_mc_info h3 { font-size: 16px !important; }
    .ra_mychoice .ra_mc_info span { font-size: 11px !important; }
}
</style>

<div class="ra_wrap">

    <div class="ra_title">🛸 {$ra_pageTitle}</div>
    <div class="ra_subtitle">Elige tu raza y facción. Esta decisión es permanente.</div>

    {if $message}
        <div class="ra_msg {$msgType}">{$message}</div>
    {/if}

    {* ============ MI ELECCIÓN ============ *}
    {if $hasChosen && $myRace && $myFaction}
        <div class="ra_mychoice">
            <div class="ra_mc_icon">{$myRace.race_icon}</div>
            <div class="ra_mc_info">
                <h3>{$myRace.race_name} · {$myFaction.faction_name}</h3>
                <span>{$myRace.race_desc}</span>
                <span>{$myFaction.faction_desc}</span>
            </div>
        </div>
    {/if}

    {* ============ FORMULARIO ============ *}
    {if !$hasChosen}
    <form method="post" action="game.php?page=racefaction" id="ra_form">
        <input type="hidden" name="action" value="select">
        <input type="hidden" name="race_id" id="ra_race_input" value="0">
        <input type="hidden" name="faction_id" id="ra_faction_input" value="0">

        {* --- RAZAS --- *}
        <div class="ra_section">
            <h2>🧬 Razas disponibles</h2>
            <div class="ra_grid">
                {foreach $races as $race}
                <div class="ra_card" data-type="race" data-id="{$race.race_id}">
                    <div class="ra_card_header">
                        <div class="ra_icon">{$race.race_icon}</div>
                        <div class="ra_name">{$race.race_name}</div>
                    </div>
                    <div class="ra_desc">{$race.race_desc}</div>
                    <div class="ra_bonuses">
                        {if $race.bonus_metal != 0}
                            <span class="ra_bonus {if $race.bonus_metal > 0}positive{else}negative{/if}">⛏️ Metal {$race.bonus_metal}%</span>
                        {/if}
                        {if $race.bonus_crystal != 0}
                            <span class="ra_bonus {if $race.bonus_crystal > 0}positive{else}negative{/if}">💎 Cristal {$race.bonus_crystal}%</span>
                        {/if}
                        {if $race.bonus_deuterium != 0}
                            <span class="ra_bonus {if $race.bonus_deuterium > 0}positive{else}negative{/if}">⚗️ Deuterio {$race.bonus_deuterium}%</span>
                        {/if}
                        {if $race.bonus_energy != 0}
                            <span class="ra_bonus {if $race.bonus_energy > 0}positive{else}negative{/if}">⚡ Energía {$race.bonus_energy}%</span>
                        {/if}
                        {if $race.bonus_attack != 0}
                            <span class="ra_bonus {if $race.bonus_attack > 0}positive{else}negative{/if}">⚔️ Ataque {$race.bonus_attack}%</span>
                        {/if}
                        {if $race.bonus_shield != 0}
                            <span class="ra_bonus {if $race.bonus_shield > 0}positive{else}negative{/if}">🛡️ Escudo {$race.bonus_shield}%</span>
                        {/if}
                        {if $race.bonus_speed != 0}
                            <span class="ra_bonus {if $race.bonus_speed > 0}positive{else}negative{/if}">🚀 Velocidad {$race.bonus_speed}%</span>
                        {/if}
                        {if $race.bonus_research != 0}
                            <span class="ra_bonus {if $race.bonus_research > 0}positive{else}negative{/if}">🔬 Investigación {$race.bonus_research}%</span>
                        {/if}
                    </div>
                    <button type="button" class="ra_select_btn">Seleccionar</button>
                </div>
                {/foreach}
            </div>
        </div>

        {* --- FACCIONES --- *}
        <div class="ra_section">
            <h2>⚔️ Facciones disponibles</h2>
            <div class="ra_grid">
                {foreach $factions as $faction}
                <div class="ra_card" data-type="faction" data-id="{$faction.faction_id}">
                    <div class="ra_card_header">
                        <div class="ra_icon">{$faction.faction_icon}</div>
                        <div class="ra_name" style="color:{$faction.faction_color};">{$faction.faction_name}</div>
                    </div>
                    <div class="ra_desc">{$faction.faction_desc}</div>
                    <div class="ra_bonuses">
                        {if $faction.bonus_metal != 0}
                            <span class="ra_bonus {if $faction.bonus_metal > 0}positive{else}negative{/if}">⛏️ Metal {$faction.bonus_metal}%</span>
                        {/if}
                        {if $faction.bonus_crystal != 0}
                            <span class="ra_bonus {if $faction.bonus_crystal > 0}positive{else}negative{/if}">💎 Cristal {$faction.bonus_crystal}%</span>
                        {/if}
                        {if $faction.bonus_deuterium != 0}
                            <span class="ra_bonus {if $faction.bonus_deuterium > 0}positive{else}negative{/if}">⚗️ Deuterio {$faction.bonus_deuterium}%</span>
                        {/if}
                        {if $faction.bonus_energy != 0}
                            <span class="ra_bonus {if $faction.bonus_energy > 0}positive{else}negative{/if}">⚡ Energía {$faction.bonus_energy}%</span>
                        {/if}
                        {if $faction.bonus_attack != 0}
                            <span class="ra_bonus {if $faction.bonus_attack > 0}positive{else}negative{/if}">⚔️ Ataque {$faction.bonus_attack}%</span>
                        {/if}
                        {if $faction.bonus_shield != 0}
                            <span class="ra_bonus {if $faction.bonus_shield > 0}positive{else}negative{/if}">🛡️ Escudo {$faction.bonus_shield}%</span>
                        {/if}
                        {if $faction.bonus_speed != 0}
                            <span class="ra_bonus {if $faction.bonus_speed > 0}positive{else}negative{/if}">🚀 Velocidad {$faction.bonus_speed}%</span>
                        {/if}
                        {if $faction.bonus_research != 0}
                            <span class="ra_bonus {if $faction.bonus_research > 0}positive{else}negative{/if}">🔬 Investigación {$faction.bonus_research}%</span>
                        {/if}
                    </div>
                    <button type="button" class="ra_select_btn">Seleccionar</button>
                </div>
                {/foreach}
            </div>
        </div>

        <div class="ra_footer">
            <div class="ra_hint" id="ra_hint">⚠️ Debes elegir una raza y una facción antes de confirmar.</div>
            <button type="submit" class="ra_confirm" id="ra_submit" disabled>Confirmar elección</button>
        </div>
    </form>
    {/if}

</div>

<script>
(function(){
    var raceInput    = document.getElementById('ra_race_input');
    var factionInput = document.getElementById('ra_faction_input');
    var submitBtn    = document.getElementById('ra_submit');
    var hint         = document.getElementById('ra_hint');

    if (!raceInput) return;

    document.querySelectorAll('.ra_card').forEach(function(card){
        card.addEventListener('click', function(){
            var type = card.dataset.type;
            var id   = card.dataset.id;

            document.querySelectorAll('.ra_card[data-type="'+type+'"]').forEach(function(c){
                c.classList.remove('selected');
            });
            card.classList.add('selected');

            if (type === 'race')    raceInput.value = id;
            if (type === 'faction') factionInput.value = id;

            if (raceInput.value > 0 && factionInput.value > 0) {
                hint.textContent = '✅ Listo. Pulsa "Confirmar elección".';
                hint.style.color = '#4aff88';
                submitBtn.disabled = false;
            } else {
                var falta = (raceInput.value == 0) ? 'una raza' : 'una facción';
                hint.textContent = '⚠️ Aún te falta elegir ' + falta + '.';
                hint.style.color = '#ef4444';
                submitBtn.disabled = true;
            }
        });
    });
})();
</script>
{/block}