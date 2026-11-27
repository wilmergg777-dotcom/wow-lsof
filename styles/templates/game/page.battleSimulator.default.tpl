{block name="title" prepend}{$LNG.lm_battlesim}{/block}
{block name="content"}

{* ============================================================
   ASTROIO BATTLE SIMULATOR v3.4 — Estilo Xnova (glassmorphism)
   Prefijo CSS: .astrobs_
   Acento del módulo: 🔴 Rojo (#ef4444)
   FIX v3.4:
     - Se integra selector de Clima.
     - Se mantienen intactos todos los names y sections.
   ============================================================ *}

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

/* ====== Wrapper ====== */
.astrobs_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrobs_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 1050px;
    margin: 0 auto;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

/* ====== Header (acento rojo) ====== */
.astrobs_header {
    text-align: center;
    color: #ffffff;
    font-size: 16px;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    padding: 6px 0 10px 0;
    text-shadow: 0 0 14px rgba(239, 68, 68, 0.5);
    border-bottom: 1px solid var(--border-color);
    margin-bottom: 14px;
}

/* ====== Steal row (glassmorphism) ====== */
.astrobs_steal_row {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px 14px;
    margin-bottom: 10px;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 14px;
    font-size: 11.5px;
    transition: 0.2s ease;
}
.astrobs_steal_row:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrobs_steal_row label {
    color: #ffaa33;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    font-size: 11px;
}
.astrobs_steal_item {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: var(--text-muted);
    font-weight: 600;
}

/* ====== Inputs ====== */
.astrobs_input {
    width: 90px;
    padding: 6px 10px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    font-size: 12px;
    outline: none;
    transition: 0.25s ease;
    text-align: right;
    box-sizing: border-box;
}
.astrobs_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* ====== Botón añadir ACS slot ====== */
.astrobs_add_btn {
    display: inline-block;
    padding: 8px 20px;
    background: linear-gradient(135deg, rgba(10, 95, 138, 0.9), rgba(0, 168, 216, 0.9));
    border: 1px solid #00ccff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 800;
    font-size: 11.5px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 1px;
    font-family: inherit;
    box-shadow: 0 3px 10px rgba(0, 168, 216, 0.4);
    text-transform: uppercase;
    margin-bottom: 12px;
}
.astrobs_add_btn:hover {
    background: linear-gradient(135deg, rgba(0, 168, 216, 0.95), rgba(0, 224, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astrobs_add_btn:active {
    transform: translateY(0);
}

/* ====== Tabs (jQuery UI) ====== */
#tabs {
    background: transparent;
    border: none;
    padding: 0;
    margin-top: 6px;
}

#tabs ul {
    list-style: none;
    padding: 0;
    margin: 0 0 10px 0;
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    padding-bottom: 8px;
}
#tabs ul li { margin: 0; padding: 0; }
#tabs ul li a {
    display: inline-block;
    padding: 8px 18px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 8px;
    color: var(--text-muted);
    font-weight: 800;
    font-size: 11.5px;
    text-decoration: none;
    letter-spacing: 0.8px;
    transition: 0.25s ease;
    text-transform: uppercase;
    cursor: pointer;
}
#tabs ul li a:hover {
    background: rgba(0, 204, 255, 0.1);
    color: #00e0ff;
    border-color: rgba(0, 204, 255, 0.5);
    transform: translateY(-1px);
}
#tabs ul li.ui-tabs-active a,
#tabs ul li.ui-state-active a,
#tabs ul li a.ui-state-active {
    background: linear-gradient(135deg, rgba(10, 95, 138, 0.9), rgba(0, 168, 216, 0.9));
    color: #ffffff;
    border-color: #00e0ff;
    box-shadow: 0 4px 14px rgba(0, 168, 216, 0.5);
}

#tabs > div {
    background: transparent;
    border: none;
    padding: 0;
    color: var(--text-main);
}

/* ====== Columnas Atacante / Defensor ====== */
.astrobs_columns {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
    margin-bottom: 14px;
}

.astrobs_col {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    overflow: hidden;
    transition: 0.2s ease;
}
.astrobs_col:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* Columna Atacante (roja) */
.astrobs_col--att { border-color: rgba(239, 68, 68, 0.4); }
.astrobs_col--att:hover { border-color: rgba(239, 68, 68, 0.6); }
.astrobs_col--att .astrobs_col_header {
    background: linear-gradient(135deg, rgba(74, 13, 30, 0.9), rgba(138, 21, 56, 0.9));
    border-bottom: 1px solid var(--accent-red);
    color: #ffffff;
    text-shadow: 0 0 12px rgba(239, 68, 68, 0.6);
}
.astrobs_col--att .astrobs_tech_header,
.astrobs_col--att .astrobs_ships_header {
    color: #ff4488;
    border-bottom-color: rgba(255, 68, 136, 0.3);
}

/* Columna Defensor (cyan) */
.astrobs_col--def { border-color: rgba(0, 224, 255, 0.4); }
.astrobs_col--def:hover { border-color: rgba(0, 224, 255, 0.6); }
.astrobs_col--def .astrobs_col_header {
    background: linear-gradient(135deg, rgba(10, 58, 82, 0.9), rgba(10, 95, 138, 0.9));
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.6);
}
.astrobs_col--def .astrobs_tech_header,
.astrobs_col--def .astrobs_ships_header {
    color: #00e0ff;
    border-bottom-color: rgba(0, 224, 255, 0.3);
}

.astrobs_col_header {
    padding: 10px 14px;
    font-size: 13.5px;
    font-weight: 800;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    text-align: center;
}

.astrobs_col_body {
    padding: 12px 14px;
}

.astrobs_tech_header,
.astrobs_ships_header {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 6px 0 5px 0;
    margin-bottom: 8px;
    border-bottom: 1px solid;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

/* ====== Filas de elemento ====== */
.astrobs_row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 5px 0;
    font-size: 11.5px;
    gap: 8px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.5);
}
.astrobs_row:last-child { border-bottom: none; }

.astrobs_row_name {
    color: var(--text-muted);
    font-weight: 600;
    flex: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size: 11.5px;
}

/* ====== Botones reset pequeños ====== */
.astrobs_reset_mini {
    padding: 4px 10px;
    background: rgba(255, 68, 136, 0.1);
    border: 1px solid rgba(255, 68, 136, 0.4);
    border-radius: 6px;
    color: #ff4488;
    font-size: 9.5px;
    font-weight: 800;
    cursor: pointer;
    font-family: inherit;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    transition: 0.25s ease;
}
.astrobs_reset_mini:hover {
    background: rgba(255, 68, 136, 0.25);
    color: #ffffff;
    box-shadow: 0 0 8px rgba(255, 68, 136, 0.5);
    transform: translateY(-1px);
}

/* ====== Botones submit / reset ====== */
.astrobs_submit_row {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding-top: 14px;
    margin-top: 10px;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}

.astrobs_submit_btn {
    display: inline-block;
    padding: 11px 34px;
    background: linear-gradient(135deg, rgba(10, 95, 138, 0.9) 0%, rgba(0, 168, 216, 0.9) 100%);
    border: 1px solid #00e0ff;
    border-radius: 8px;
    color: #ffffff;
    font-weight: 800;
    font-size: 12.5px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 1.2px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    box-shadow: 0 4px 14px rgba(0, 168, 216, 0.45);
    text-transform: uppercase;
}
.astrobs_submit_btn:hover {
    background: linear-gradient(135deg, rgba(0, 168, 216, 0.95) 0%, rgba(0, 224, 255, 0.95) 100%);
    box-shadow: 0 6px 20px rgba(0, 224, 255, 0.7);
    transform: translateY(-2px);
}
.astrobs_submit_btn:active {
    transform: translateY(0);
}

.astrobs_reset_btn {
    display: inline-block;
    padding: 11px 26px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 8px;
    color: var(--text-muted);
    font-weight: 800;
    font-size: 12.5px;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 1.2px;
    font-family: inherit;
    text-transform: uppercase;
}
.astrobs_reset_btn:hover {
    background: rgba(255, 68, 136, 0.1);
    border-color: #ff4488;
    color: #ff4488;
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.5);
    transform: translateY(-2px);
}

/* ====== Fila de espera ====== */
.astrobs_wait {
    text-align: center;
    padding: 16px;
    background: rgba(255, 170, 51, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 170, 51, 0.4);
    border-radius: 10px;
    color: #ffaa33;
    font-weight: 800;
    font-size: 12.5px;
    margin-top: 10px;
    letter-spacing: 0.6px;
    text-shadow: 0 0 8px rgba(255, 170, 51, 0.5);
}

/* ====== Responsive ====== */
@media (max-width: 900px) {
    .astrobs_wrap { padding: 10px; }
    .astrobs_panel { padding: 12px; }
    .astrobs_columns { grid-template-columns: 1fr; gap: 10px; }
    .astrobs_submit_btn,
    .astrobs_reset_btn {
        width: 100%;
        padding: 11px 18px;
    }
    .astrobs_submit_row { flex-direction: column-reverse; }
    .astrobs_input { width: 80px; font-size: 11.5px; }
    .astrobs_header { font-size: 14px; }
    .astrobs_col_header { font-size: 12px; padding: 8px 10px; }
    .astrobs_row { font-size: 11px; }
    .astrobs_row_name { font-size: 11px; }
}
</style>

<div class="astrobs_wrap">

    <div class="astrobs_panel">

        <div class="astrobs_header">⚔ {$LNG.lm_battlesim}</div>

        <form id="form" name="battlesim">
            <input type="hidden" name="slots" id="slots" value="{$Slots + 1}">

            {* ============ SELECTOR DE CLIMA (NUEVO) ============ *}
            <div class="astrobs_steal_row" style="border-color: rgba(0, 224, 255, 0.4);">
                <label style="color: #00e0ff;">🌦️ {$LNG.tech.0|default:'Clima'}:</label>
                <select name="clima_id" id="clima_id" class="astrobs_input" style="width: 300px; text-align: left; padding: 6px 10px;">
                    <option value="0">Sin clima (Normal)</option>
                    {foreach $climasList as $clima}
                        <option value="{$clima.id}" {if $clima.id == $climaId}selected{/if}>
                            {if $clima.clave == 'despejado'}☀️ Cielo Despejado
                            {elseif $clima.clave == 'brisa_solar'}🌤️ Brisa Solar
                            {elseif $clima.clave == 'viento_estelar'}🍃 Viento Estelar Suave
                            {elseif $clima.clave == 'cristalino'}✨ Cielo Cristalino
                            {elseif $clima.clave == 'niebla'}🌫️ Niebla Densísima
                            {elseif $clima.clave == 'tormenta_solar'}⚡ Tormenta Solar
                            {elseif $clima.clave == 'meteoros'}☄️ Lluvia de Meteoros
                            {elseif $clima.clave == 'nebulosa'}💰 Nebulosa Mineral
                            {elseif $clima.clave == 'plasma'}🌌 Nube de Plasma
                            {elseif $clima.clave == 'eclipse'}🌓 Eclipse Solar
                            {elseif $clima.clave == 'campo_mag'}🌀 Campo Magnético
                            {elseif $clima.clave == 'aurora'}🌈 Aurora Cósmica
                            {elseif $clima.clave == 'agujero'}🕳️ Agujero de Gusano
                            {elseif $clima.clave == 'singularidad'}⚫ Singularidad
                            {else}{$clima.nombre}{/if}
                            
                            {if $clima.factor_ataque != 1} (Atk: {if $clima.factor_ataque > 1}+{/if}{math equation="round((x-1)*100)" x=$clima.factor_ataque}%){/if}
                            {if $clima.factor_defensa != 1} (Def: {if $clima.factor_defensa > 1}+{/if}{math equation="round((x-1)*100)" x=$clima.factor_defensa}%){/if}
                        </option>
                    {/foreach}
                </select>
            </div>

            {* ============ RECURSOS ROBADOS (STEAL) ============ *}
            <div class="astrobs_steal_row">
                <label>💎 {$LNG.bs_steal}</label>
                <span class="astrobs_steal_item">
                    {$LNG.tech.901}:
                    <input type="text" size="10" value="{if isset($battleinput.0.1.901)}{$battleinput.0.1.901}{else}0{/if}" name="battleinput[0][1][901]" class="astrobs_input">
                </span>
                <span class="astrobs_steal_item">
                    {$LNG.tech.902}:
                    <input type="text" size="10" value="{if isset($battleinput.0.1.902)}{$battleinput.0.1.902}{else}0{/if}" name="battleinput[0][1][902]" class="astrobs_input">
                </span>
                <span class="astrobs_steal_item">
                    {$LNG.tech.903}:
                    <input type="text" size="10" value="{if isset($battleinput.0.1.903)}{$battleinput.0.1.903}{else}0{/if}" name="battleinput[0][1][903]" class="astrobs_input">
                </span>
            </div>

            {* ============ BOTÓN AÑADIR SLOT ============ *}
            <div>
                <input type="button" onClick="return add();" value="+ {$LNG.bs_add_acs_slot}" class="astrobs_add_btn">
            </div>

            {* ============ TABS (jQuery UI) ============ *}
            <div class="astrobs_tabs">
                <div id="tabs">
                    <ul>
                        {section name=tab start=0 loop=$Slots}
                            <li><a href="#tabs-{$smarty.section.tab.index}">{$LNG.bs_acs_slot} {$smarty.section.tab.index + 1}</a></li>
                        {/section}
                    </ul>

                    {section name=content start=0 loop=$Slots}
                    <div id="tabs-{$smarty.section.content.index}">

                        <div class="astrobs_columns">

                            {* ══════════════════════════════════════════
                               COLUMNA ATACANTE
                               ══════════════════════════════════════════ *}
                            <div class="astrobs_col astrobs_col--att">

                                <div class="astrobs_col_header">⚔ {$LNG.bs_atter}</div>

                                <div class="astrobs_col_body">

                                    {* ── Tecnologías ── *}
                                    <div class="astrobs_tech_header">
                                        <span>🔬 {$LNG.bs_techno}</span>
                                        <button type="button" class="reset astrobs_reset_mini">{$LNG.bs_reset}</button>
                                    </div>

                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.109}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.0.109)}{$battleinput.{$smarty.section.content.index}.0.109}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][0][109]" class="astrobs_input">
                                    </div>
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.110}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.0.110)}{$battleinput.{$smarty.section.content.index}.0.110}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][0][110]" class="astrobs_input">
                                    </div>
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.111}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.0.111)}{$battleinput.{$smarty.section.content.index}.0.111}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][0][111]" class="astrobs_input">
                                    </div>

                                    {* ── Naves ── *}
                                    <div class="astrobs_ships_header" style="margin-top:12px;">
                                        <span>🚀 {$LNG.bs_names}</span>
                                        <button type="button" class="reset astrobs_reset_mini">{$LNG.bs_reset}</button>
                                    </div>

                                    {foreach $fleetList as $id}
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.$id}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.0.$id)}{$battleinput.{$smarty.section.content.index}.0.$id}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][0][{$id}]" class="astrobs_input">
                                    </div>
                                    {/foreach}

                                </div>
                            </div>

                            {* ══════════════════════════════════════════
                               COLUMNA DEFENSOR
                               ══════════════════════════════════════════ *}
                            <div class="astrobs_col astrobs_col--def">

                                <div class="astrobs_col_header">🛡 {$LNG.bs_deffer}</div>

                                <div class="astrobs_col_body">

                                    {* ── Tecnologías ── *}
                                    <div class="astrobs_tech_header">
                                        <span>🔬 {$LNG.bs_techno}</span>
                                        <button type="button" class="reset astrobs_reset_mini">{$LNG.bs_reset}</button>
                                    </div>

                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.109}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.1.109)}{$battleinput.{$smarty.section.content.index}.1.109}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][1][109]" class="astrobs_input">
                                    </div>
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.110}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.1.110)}{$battleinput.{$smarty.section.content.index}.1.110}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][1][110]" class="astrobs_input">
                                    </div>
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.111}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.1.111)}{$battleinput.{$smarty.section.content.index}.1.111}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][1][111]" class="astrobs_input">
                                    </div>

                                    {* ── Naves ── *}
                                    <div class="astrobs_ships_header" style="margin-top:12px;">
                                        <span>🚀 {$LNG.bs_names}</span>
                                        <button type="button" class="reset astrobs_reset_mini">{$LNG.bs_reset}</button>
                                    </div>

                                    {foreach $fleetList as $id}
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.$id}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.1.$id)}{$battleinput.{$smarty.section.content.index}.1.$id}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][1][{$id}]" class="astrobs_input">
                                    </div>
                                    {/foreach}

                                    {* ── Defensas (solo en slot 0) ── *}
                                    {if $smarty.section.content.index == 0}
                                    <div class="astrobs_ships_header" style="margin-top:12px;">
                                        <span>🛡 {$LNG.bs_names}</span>
                                        <button type="button" class="reset astrobs_reset_mini">{$LNG.bs_reset}</button>
                                    </div>

                                    {foreach $defensiveList as $id}
                                    <div class="astrobs_row">
                                        <span class="astrobs_row_name">{$LNG.tech.$id}:</span>
                                        <input type="text" size="10" value="{if isset($battleinput.{$smarty.section.content.index}.1.$id)}{$battleinput.{$smarty.section.content.index}.1.$id}{else}0{/if}" name="battleinput[{$smarty.section.content.index}][1][{$id}]" class="astrobs_input">
                                    </div>
                                    {/foreach}
                                    {/if}

                                </div>
                            </div>

                        </div>

                    </div>
                    {/section}
                </div>
            </div>

            {* ============ BOTONES SUBMIT / RESET ============ *}
            <div id="submit" class="astrobs_submit_row">
                <input type="reset" value="{$LNG.bs_cancel}" class="astrobs_reset_btn">
                <input type="button" onClick="return check();" value="⚔ {$LNG.bs_send}" class="astrobs_submit_btn">
            </div>

            {* ============ FILA DE ESPERA ============ *}
            <div id="wait" style="display:none;">
                <div class="astrobs_wait">⏳ {$LNG.bs_wait}</div>
            </div>

        </form>

    </div>

</div>

{/block}