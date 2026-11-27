{extends file="layout.full.tpl"}

{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.race.default.tpl === *}
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

{* AstroIO - Página de Razas v3.0 *}

<style>
/* ═══════════════════════════════════════════════════════════
   RAZAS — AstroIO v3.0
   Glassmorphism + Acento Cyan
   Prefijo: .rp_
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

.rp_wrap {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
}
.rp_title {
    font-size: 26px;
    color: var(--accent-cyan);
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.6);
    margin-bottom: 6px;
    letter-spacing: 1px;
}
.rp_subtitle {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 20px;
}
.rp_status {
    display: flex;
    gap: 14px;
    align-items: center;
    flex-wrap: wrap;
    background: linear-gradient(135deg, rgba(10, 31, 46, 0.75), rgba(18, 48, 69, 0.75));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(0, 224, 255, 0.3);
    border-radius: 10px;
    padding: 12px 18px;
    margin-bottom: 22px;
    font-size: 13px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.rp_status .badge {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #fff;
    padding: 4px 10px;
    border-radius: 6px;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 1px;
    border: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.rp_status .value-dm {
    color: var(--accent-purple);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 10px rgba(139, 92, 246, 0.4);
}
.rp_msg {
    padding: 14px 18px;
    border-radius: 10px;
    margin-bottom: 20px;
    font-size: 14px;
    border-left: 4px solid;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.rp_msg.success { background: rgba(74, 255, 136, 0.12); border-color: var(--accent-green); color: var(--accent-green); }
.rp_msg.error   { background: rgba(239, 68, 68, 0.12); border-color: var(--accent-red); color: var(--accent-red); }
.rp_msg.info    { background: rgba(0, 224, 255, 0.10); border-color: var(--accent-cyan); color: var(--accent-cyan); }

.rp_grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
}
.rp_card {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    transition: all 0.25s ease;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}
.rp_card:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 24px rgba(0, 224, 255, 0.35), 0 8px 24px rgba(0, 0, 0, 0.4);
    transform: translateY(-3px);
}
.rp_card.selected {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 22px rgba(0, 224, 255, 0.5);
    background: linear-gradient(135deg, rgba(18, 36, 58, 0.85), rgba(26, 48, 80, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.rp_card.current {
    border-color: var(--accent-green);
    box-shadow: 0 0 22px rgba(74, 255, 136, 0.5);
    background: linear-gradient(135deg, rgba(15, 36, 48, 0.85), rgba(20, 64, 47, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.rp_card_header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 10px;
    padding-bottom: 10px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.15);
}
.rp_icon {
    font-size: 14px;
    font-weight: 700;
    letter-spacing: 1px;
    padding: 6px 10px;
    border-radius: 8px;
    background: rgba(0, 224, 255, 0.15);
    border: 1px solid rgba(0, 224, 255, 0.3);
    color: var(--accent-cyan);
    min-width: 60px;
    text-align: center;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
/* v2.4.10 - Foto de la raza (columna race_img, migration_10).
   Si race_img esta vacio, la plantilla muestra el icono de texto. */
.rp_icon img {
    display: block;
    width: 100%;
    height: 64px;
    object-fit: cover;
    border-radius: 6px;
    margin: 2px 0;
}
.rp_name {
    font-size: 18px;
    font-weight: bold;
    letter-spacing: 1px;
}
.rp_desc {
    font-size: 12px;
    color: var(--text-muted);
    line-height: 1.5;
    margin-bottom: 12px;
    min-height: 32px;
}
.rp_bonuses {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 5px;
    margin-bottom: 14px;
}
.rp_bonus {
    font-size: 11px;
    padding: 5px 8px;
    border-radius: 6px;
    background: rgba(74, 255, 136, 0.08);
    border: 1px solid rgba(74, 255, 136, 0.25);
    color: #a8e8c0;
    display: flex;
    align-items: center;
    gap: 4px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    min-width: 0;
}
.rp_bonus .bval {
    color: var(--accent-green);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    margin-left: auto;
}
.rp_select_btn {
    width: 100%;
    padding: 10px;
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #fff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    letter-spacing: 1.5px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.rp_select_btn:hover {
    background: linear-gradient(135deg, #0099ff 0%, #00ccff 100%);
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.rp_select_btn:active {
    transform: translateY(0);
}
.rp_select_btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    background: rgba(30, 41, 59, 0.85);
    border-color: var(--border-color);
    color: var(--text-muted);
    transform: none;
    box-shadow: none;
}
.rp_select_btn.current_btn {
    background: linear-gradient(135deg, #228833 0%, #4aff88 100%);
    border-color: var(--accent-green);
    cursor: default;
    color: #fff;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.rp_footer {
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
.rp_footer .rp_hint {
    font-size: 13px;
    color: var(--text-muted);
    margin-bottom: 12px;
}
.rp_footer .rp_cost {
    font-size: 14px;
    color: var(--accent-purple);
    font-weight: 700;
    margin-bottom: 10px;
    text-shadow: 0 0 10px rgba(139, 92, 246, 0.3);
}
.rp_footer .rp_confirm {
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
.rp_footer .rp_confirm:hover:not(:disabled) {
    background: linear-gradient(135deg, #8b5cf6 0%, #a78bfa 100%);
    box-shadow: 0 0 26px rgba(139, 92, 246, 0.6);
    transform: translateY(-2px);
}
.rp_footer .rp_confirm:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    background: rgba(30, 41, 59, 0.85);
    border-color: var(--border-color);
}
@media (max-width: 900px) {
    .rp_wrap { padding: 8px !important; }
    .rp_title { font-size: 20px !important; }
    .rp_subtitle { font-size: 11px !important; margin-bottom: 15px !important; }
    .rp_status { padding: 8px 12px !important; font-size: 11px !important; gap: 8px !important; }

    /* 🆕 FORZAR 1x2 (2 COLUMNAS) */
    .rp_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 8px !important; }
    .rp_card { padding: 8px !important; }
    .rp_card_header { flex-direction: column !important; text-align: center !important; gap: 4px !important; padding-bottom: 6px !important; margin-bottom: 6px !important; }
    .rp_icon { min-width: 100% !important; font-size: 11px !important; padding: 4px !important; }
    .rp_name { font-size: 13px !important; }

    .rp_desc { font-size: 9px !important; line-height: 1.3 !important; min-height: 45px !important; margin-bottom: 8px !important; }

    /* Los bonuses internos a 1 columna */
    .rp_bonuses { grid-template-columns: 1fr !important; gap: 3px !important; }
    .rp_bonus { font-size: 8px !important; padding: 3px 5px !important; }
    .rp_bonus .bval { font-size: 8px !important; }

    .rp_select_btn { font-size: 9px !important; padding: 6px !important; letter-spacing: 0px !important; }
    .rp_footer { padding: 12px !important; margin-top: 15px !important; }
    .rp_footer .rp_hint { font-size: 11px !important; }
    .rp_footer .rp_cost { font-size: 11px !important; }
    .rp_footer .rp_confirm { font-size: 12px !important; padding: 10px 20px !important; width: 100% !important; }
}
</style>

<div class="rp_wrap">

    <div class="rp_title">🧬 Elegir Raza</div>
    <div class="rp_subtitle">Elige tu raza. La primera elección es gratuita; los cambios cuestan {$changeCost} de Materia Oscura.</div>

    {* ============ ESTADO ============ *}
    <div class="rp_status">
        <span class="badge">ESTADO</span>
        {if $hasChosen}
            <span>Raza actual: <strong style="color:var(--accent-cyan);">{$myRace.race_name}</strong></span>
            <span>·</span>
            <span>Tu MO: <span class="value-dm">{$currentDM}</span></span>
        {else}
            <span style="color:var(--accent-green);">✅ Aún no has elegido. ¡Esta primera vez es gratis!</span>
        {/if}
    </div>

    {if $message}
        <div class="rp_msg {$msgType}">{$message}</div>
    {/if}

    {* ASTROIO v2.4.10 (base v2.6) — Acceso al Arbol de Talentos de la Raza *}
    {if $hasChosen}
    <div style="margin-top:12px; text-align:center;">
        <a href="game.php?page=raceTalent" style="display:inline-flex; align-items:center; gap:8px; padding:10px 22px; border-radius:12px; text-decoration:none; font-weight:800; font-size:13px; letter-spacing:.5px; color:#fff; background:linear-gradient(135deg, rgba(0,90,160,.95), rgba(0,140,220,.9)); border:1px solid rgba(0,224,255,.5); box-shadow:0 6px 18px rgba(0,140,220,.35); transition:.2s ease;"
           onmouseover="this.style.transform='translateY(-2px)';this.style.boxShadow='0 8px 24px rgba(0,224,255,.45)';"
           onmouseout="this.style.transform='none';this.style.boxShadow='0 6px 18px rgba(0,140,220,.35)';">
            <span style="font-size:15px;"> &#127806;</span> Arbol de Talentos de tu Raza
            <span style="font-size:9px; opacity:.85; font-weight:600;">(11 puntos · estilo WoW · se reinician desde 0 al cambiar de raza)</span>
        </a>
    </div>
    {/if}

    {* ============ FORMULARIO ============ *}
    <form method="post" action="game.php?page=race" id="rp_form">
        <input type="hidden" name="action" value="select">
        <input type="hidden" name="race_id" id="rp_race_input" value="0">

        <div class="rp_grid">
            {foreach $races as $race}
            <div class="rp_card{if $hasChosen && $myRace && $myRace.race_id == $race.race_id} current{/if}"
                 data-id="{$race.race_id}">
                <div class="rp_card_header">
                    <div class="rp_icon">{if $race.race_img}<img src="{$dpath}{$race.race_img}" alt="{$race.race_name}">{else}{$race.race_icon}{/if}</div>
                    <div class="rp_name" style="color:{$race.race_color};">{$race.race_name}</div>
                </div>
                <div class="rp_desc">{$race.race_desc}</div>

                <div class="rp_bonuses">
                    {if $race.bonus_attack != 0}<div class="rp_bonus">⚔️ Ataque<span class="bval">+{$race.bonus_attack}%</span></div>{/if}
                    {if $race.bonus_defense != 0}<div class="rp_bonus">🛡️ Defensa<span class="bval">+{$race.bonus_defense}%</span></div>{/if}
                    {if $race.bonus_shield != 0}<div class="rp_bonus">🔰 Escudo<span class="bval">+{$race.bonus_shield}%</span></div>{/if}
                    {if $race.bonus_resources != 0}<div class="rp_bonus">⛏️ Recursos<span class="bval">+{$race.bonus_resources}%</span></div>{/if}
                    {if $race.bonus_energy != 0}<div class="rp_bonus">⚡ Energía<span class="bval">+{$race.bonus_energy}%</span></div>{/if}
                    {if $race.bonus_storage != 0}<div class="rp_bonus">📦 Almacén<span class="bval">+{$race.bonus_storage}%</span></div>{/if}
                    {if $race.bonus_fleet_storage != 0}<div class="rp_bonus">🚀 Alm. flota<span class="bval">+{$race.bonus_fleet_storage}%</span></div>{/if}
                    {if $race.bonus_fleet_capacity != 0}<div class="rp_bonus">📊 Cap. carga<span class="bval">+{$race.bonus_fleet_capacity}%</span></div>{/if}
                    {if $race.bonus_fleet_slots != 0}<div class="rp_bonus">🎯 Slots flota<span class="bval">+{$race.bonus_fleet_slots}</span></div>{/if}
                    {if $race.bonus_speed != 0}<div class="rp_bonus">💨 Velocidad<span class="bval">+{$race.bonus_speed}%</span></div>{/if}
                    {if $race.bonus_fuel != 0}<div class="rp_bonus">⛽ Combustible<span class="bval">{$race.bonus_fuel}%</span></div>{/if}
                    {if $race.bonus_expeditions != 0}<div class="rp_bonus">🧭 Expediciones<span class="bval">+{$race.bonus_expeditions}</span></div>{/if}
                    {if $race.bonus_exp_resources != 0}<div class="rp_bonus">💎 Rec. exp.<span class="bval">+{$race.bonus_exp_resources}%</span></div>{/if}
                    {if $race.bonus_exp_darkmatter != 0}<div class="rp_bonus">💜 MO exp.<span class="bval">+{$race.bonus_exp_darkmatter}%</span></div>{/if}
                    {if $race.bonus_spy != 0}<div class="rp_bonus">🔍 Espionaje<span class="bval">+{$race.bonus_spy}%</span></div>{/if}
                    {if $race.bonus_jumpgate != 0}<div class="rp_bonus">⚡ Salto cuánt.<span class="bval">{$race.bonus_jumpgate}%</span></div>{/if}
                    {if $race.bonus_debris != 0}<div class="rp_bonus">♻️ Escombros<span class="bval">+{$race.bonus_debris}%</span></div>{/if}
                    {if $race.bonus_trade_ratio != 0}<div class="rp_bonus">💱 Comercio<span class="bval">+{$race.bonus_trade_ratio}%</span></div>{/if}
                </div>

                {if $hasChosen && $myRace && $myRace.race_id == $race.race_id}
                    <button type="button" class="rp_select_btn current_btn" disabled>✔ Raza actual</button>
                {else}
                    <button type="button" class="rp_select_btn">Seleccionar</button>
                {/if}
            </div>
            {/foreach}
        </div>

        <div class="rp_footer">
            <div class="rp_hint" id="rp_hint">
                {if $hasChosen}
                    Elige otra raza y pulsa confirmar. Se descontarán <strong>{$changeCost}</strong> MO.
                {else}
                    ⚠️ Selecciona una raza para continuar.
                {/if}
            </div>
            {if $hasChosen}
                <div class="rp_cost">Coste del cambio: {$changeCost} Materia Oscura · Tienes: {$currentDM}</div>
            {/if}
            <button type="submit" class="rp_confirm" id="rp_submit" disabled>
                {if $hasChosen}Cambiar raza{else}Confirmar elección{/if}
            </button>
        </div>
    </form>

</div>

<script>
(function(){
    var input    = document.getElementById('rp_race_input');
    var submit   = document.getElementById('rp_submit');
    var hint     = document.getElementById('rp_hint');
    var hasChosen = {if $hasChosen}true{else}false{/if};
    var myRaceId = {if $myRace}{$myRace.race_id}{else}0{/if};
    var cost     = {$changeCost};

    if (!input) return;

    document.querySelectorAll('.rp_card').forEach(function(card){
        card.addEventListener('click', function(){
            if (card.classList.contains('current')) return;

            var id = card.dataset.id;

            document.querySelectorAll('.rp_card').forEach(function(c){
                if (!c.classList.contains('current')) c.classList.remove('selected');
            });
            card.classList.add('selected');
            input.value = id;

            if (!hasChosen) {
                hint.textContent = '✅ Listo. Pulsa "Confirmar elección".';
                hint.style.color = '#4aff88';
            } else {
                hint.innerHTML = '✅ Vas a cambiar de raza. Se descontarán <strong>' + cost + '</strong> MO.';
                hint.style.color = '#8b5cf6';
            }
            submit.disabled = false;
        });
    });
})();
</script>
{/block}