{block name="title" prepend}{$pageTitle}{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════════ */
/* REPORTE DE BATALLA — Estilo AstroIO / Althar-Nova  */
/* Prefijo: .astrorap_                                */
/* v1.2 - Añadido visual para Buff Climático          */
/* ═══════════════════════════════════════════════════ */

.astrorap_wrap {
    max-width: 980px;
    margin: 0 auto;
    padding: 18px 12px 40px;
    font-family: Verdana, Arial, sans-serif;
    font-size: 11px;
    color: #c8d6e5;
    min-height: 100vh;
    position: relative;
    text-align: center;

    background-image: url('./styles/theme/gow/img/battle_report.jpg');
    background-size: cover;
    background-position: center top;
    background-attachment: fixed;
    background-repeat: no-repeat;
    background-color: #050810;
}

/* Capa oscura encima para leer el texto */
.astrorap_wrap::before {
    content: "";
    position: fixed;
    inset: 0;
    background: radial-gradient(
        ellipse at center,
        rgba(5,8,16,0.35) 0%,
        rgba(5,8,16,0.80) 65%,
        rgba(5,8,16,0.95) 100%
    );
    pointer-events: none;
    z-index: 0;
}
.astrorap_wrap > * { position: relative; z-index: 1; }

/* ═══════════ CABECERA VS ═══════════ */
.astrorap_vs {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    gap: 12px;
    align-items: center;
    margin-bottom: 18px;
    padding: 10px 0;
    border-bottom: 1px solid rgba(0,204,255,0.15);
}
.astrorap_vs_name {
    font-size: 18px;
    font-weight: bold;
    color: #7a8aa0;
    letter-spacing: 0.5px;
    padding: 6px 10px;
    border-radius: 6px;
    background: rgba(0,0,0,0.3);
    transition: 0.2s ease;
}
.astrorap_vs_name.winner {
    color: #4aff88;
    text-shadow: 0 0 14px rgba(74,255,136,0.6);
}
.astrorap_vs_name.loser { color: #ff6b7a; }
.astrorap_vs_label {
    font-size: 14px;
    color: #4a9eff;
    font-weight: bold;
    letter-spacing: 2px;
    text-shadow: 0 0 8px rgba(74,158,255,0.5);
}

/* Fecha */
.astrorap_date {
    text-align: center;
    color: #7a8aa0;
    font-size: 11px;
    margin-bottom: 20px;
    letter-spacing: 0.5px;
    line-height: 1.6;
}
.astrorap_date b { color: #c8d6e5; }

/* ═══════════ ETIQUETA DE RONDA ═══════════ */
.astrorap_round_label {
    text-align: center;
    margin: 22px 0 10px;
    color: #4a9eff;
    font-size: 13px;
    font-weight: bold;
    text-shadow: 0 0 10px rgba(74,158,255,0.5);
    letter-spacing: 1px;
    position: relative;
}
.astrorap_round_label::before,
.astrorap_round_label::after {
    content: "";
    position: absolute;
    top: 50%;
    width: 30%;
    height: 1px;
    background: linear-gradient(to right, transparent, #1e3a5a, transparent);
}
.astrorap_round_label::before { left: 0; }
.astrorap_round_label::after  { right: 0; }
.astrorap_round_label span {
    display: block;
    color: #4a5568;
    font-size: 9px;
    font-weight: normal;
    letter-spacing: 2px;
    text-transform: uppercase;
    text-shadow: none;
}

/* ═══════════ FILA DE RONDA ═══════════ */
.astrorap_round {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
    align-items: start;
    position: relative;
}
.astrorap_side {
    display: flex;
    flex-direction: column;
    gap: 10px;
    min-width: 0;
}

/* ═══════════ TARJETA DE JUGADOR ═══════════ */
.astrorap_card {
    background: linear-gradient(135deg, rgba(15,30,50,0.88), rgba(8,20,35,0.96));
    border: 1px solid #1e3a5a;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 14px rgba(0,0,0,0.5);
    text-align: left;
}
.astrorap_card.attacker  { border-left: 3px solid #4a9eff; }
.astrorap_card.defender  { border-left: 3px solid #4a9eff; }
.astrorap_card.defeated  { border-left: 3px solid #ff3355 !important; opacity: 0.75; }

/* Cabecera tarjeta */
.astrorap_card_head {
    padding: 7px 10px;
    background: linear-gradient(135deg, rgba(74,158,255,0.15), rgba(74,158,255,0.04));
    border-bottom: 1px solid #1e3a5a;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: pointer;
    user-select: none;
}
.astrorap_card.defeated .astrorap_card_head {
    background: linear-gradient(135deg, #4a1520, #6a2030);
}
.astrorap_card_name {
    color: #4a9eff;
    font-size: 11px;
    font-weight: bold;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.astrorap_card.defeated .astrorap_card_name { color: #ff6b7a; }
.astrorap_toggle {
    color: #4a9eff;
    font-size: 16px;
    font-weight: bold;
    line-height: 1;
    padding: 0 6px;
    background: rgba(74,158,255,0.12);
    border-radius: 4px;
    min-width: 20px;
    text-align: center;
}
.astrorap_card.defeated .astrorap_toggle {
    color: #ff6b7a;
    background: rgba(255,51,85,0.15);
}

/* Bonos */
.astrorap_card_bonus {
    padding: 4px 10px;
    font-size: 9.5px;
    color: #7a8aa0;
    background: rgba(0,0,0,0.25);
    border-bottom: 1px solid #142a40;
    text-align: center;
    letter-spacing: 0.3px;
}

/* Vista previa cuando está cerrado */
.astrorap_summary {
    text-align: center;
    padding: 8px 10px;
    font-size: 10px;
    color: #7a8aa0;
    background: rgba(0,0,0,0.15);
    border-bottom: 1px solid #142a40;
}
.astrorap_summary b {
    color: #4a9eff;
    font-weight: bold;
    font-size: 11px;
}
.astrorap_summary .red {
    color: #ff3355;
    font-weight: bold;
}

/* Grid de naves */
.astrorap_ships {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1px;
    background: #0a1828;
    padding: 1px;
}
.astrorap_ship {
    display: grid;
    grid-template-columns: 44px 1fr auto;
    gap: 6px;
    align-items: center;
    padding: 5px 7px;
    background: rgba(10,25,45,0.6);
    transition: background 0.15s ease;
}
.astrorap_ship:hover { background: rgba(20,45,75,0.85); }
.astrorap_ship_img {
    width: 44px;
    height: 36px;
    object-fit: contain;
    filter: drop-shadow(0 0 3px rgba(74,158,255,0.35));
}
.astrorap_ship_info { min-width: 0; }
.astrorap_ship_name {
    color: #c8d6e5;
    font-size: 10px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    line-height: 1.2;
}
.astrorap_ship_count {
    color: #fff;
    font-size: 11px;
    font-weight: bold;
    margin-top: 1px;
}
.astrorap_ship_stats {
    font-size: 9px;
    color: #7a8aa0;
    text-align: right;
    line-height: 1.4;
    min-width: 44px;
}
.astrorap_ship_stats b { color: #c8d6e5; font-weight: normal; }

/* Tarjeta destruida */
.astrorap_empty {
    text-align: center;
    padding: 22px 10px;
    color: #ff3355;
    font-size: 12px;
    font-weight: bold;
    letter-spacing: 2px;
    text-transform: uppercase;
    text-shadow: 0 0 8px rgba(255,51,85,0.5);
}

/* ═══════════ BARRA DE BALANCE ═══════════ */
.astrorap_balance {
    margin: 12px auto 4px;
    max-width: 620px;
    height: 12px;
    background: #0a1828;
    border: 1px solid #1e3a5a;
    border-radius: 6px;
    overflow: hidden;
    position: relative;
    box-shadow: inset 0 2px 4px rgba(0,0,0,0.5);
}
.astrorap_balance_fill {
    height: 100%;
    background: linear-gradient(90deg, #4a9eff 0%, #4aff88 100%);
    box-shadow: 0 0 10px rgba(74,255,136,0.4);
    transition: width 0.6s ease;
}
.astrorap_balance_marker {
    position: absolute;
    right: 3px;
    top: 50%;
    transform: translateY(-50%);
    width: 6px;
    height: 6px;
    background: #fff;
    border-radius: 50%;
    box-shadow: 0 0 6px rgba(255,255,255,0.9);
}

/* Info de daños bajo la barra */
.astrorap_round_info {
    text-align: center;
    font-size: 9.5px;
    color: #7a8aa0;
    margin-bottom: 6px;
    line-height: 1.6;
}
.astrorap_round_info b { color: #4a9eff; }
.astrorap_round_info .def { color: #ff6b7a; }

/* ═══════════ RESULTADO FINAL (MEJORADO) ═══════════ */
.astrorap_result {
    text-align: center;
    font-size: 24px;
    font-weight: bold;
    padding: 22px 12px;
    margin: 35px auto 20px;
    max-width: 680px;
    letter-spacing: 2px;
    line-height: 1.4;
    text-transform: uppercase;
    border-radius: 10px;
    border: 1px solid #1e3a5a;
    background: radial-gradient(ellipse at center, rgba(74,158,255,0.1) 0%, rgba(10,25,45,0.85) 100%);
    box-shadow: 0 0 25px rgba(0,0,0,0.6), inset 0 0 15px rgba(74,158,255,0.1);
}
.astrorap_result.a, .astrorap_result.r {
    color: #4aff88;
    text-shadow: 0 0 18px rgba(74,255,136,0.8), 0 0 35px rgba(74,255,136,0.4);
    border-color: rgba(74,255,136,0.3);
}
.astrorap_result.draw {
    color: #ffaa33;
    text-shadow: 0 0 18px rgba(255,170,51,0.8), 0 0 35px rgba(255,170,51,0.4);
    border-color: rgba(255,170,51,0.3);
}

/* Barra final (verde al 100%) */
.astrorap_balance.final .astrorap_balance_fill {
    width: 100% !important;
    background: linear-gradient(90deg, #4aff88 0%, #4aff88 100%);
}

/* ═══════════ NUEVO PANEL DE ESTADÍSTICAS (GRID) ═══════════ */
.astrorap_stats_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
    max-width: 820px;
    margin: 20px auto;
}

.astrorap_stat_card {
    background: linear-gradient(180deg, rgba(15,30,50,0.9), rgba(8,20,35,0.95));
    border: 1px solid #1e3a5a;
    border-radius: 8px;
    padding: 16px 12px;
    text-align: center;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 15px rgba(0,0,0,0.6);
    transition: transform 0.2s ease, border-color 0.2s ease;
}
.astrorap_stat_card:hover {
    transform: translateY(-3px);
    border-color: #4a9eff;
}
.astrorap_stat_card::before {
    content: "";
    position: absolute;
    top: 0; left: 0; right: 0; height: 3px;
}
.astrorap_stat_card.card-attacker::before { background: #ff6b7a; box-shadow: 0 0 10px #ff6b7a; }
.astrorap_stat_card.card-defender::before { background: #4a9eff; box-shadow: 0 0 10px #4a9eff; }
.astrorap_stat_card.card-debris::before   { background: #ffaa33; box-shadow: 0 0 10px #ffaa33; }
.astrorap_stat_card.card-loot::before     { background: #4aff88; box-shadow: 0 0 10px #4aff88; }

/* Forzamos a que la tarjeta de Saqueo se vaya a la columna del medio */
.astrorap_stat_card.card-loot {
    grid-column: 2;
}

.astrorap_stat_icon {
    font-size: 20px;
    margin-bottom: 6px;
}
.astrorap_stat_title {
    color: #7a8aa0;
    font-size: 9px;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 8px;
}
.astrorap_stat_value {
    color: #fff;
    font-size: 15px;
    font-weight: bold;
    line-height: 1.5;
}
.astrorap_stat_value .m { color: #4a9eff; }
.astrorap_stat_value .c { color: #4aff88; }
.astrorap_stat_value .d { color: #a078ff; }
.astrorap_stat_value .red { color: #ff6b7a; }

/* ═══════════ CAJA DE LUNA (MÍSTICA) ═══════════ */
.astrorap_moon_box {
    max-width: 720px;
    margin: 20px auto;
    padding: 16px 20px;
    background: linear-gradient(135deg, rgba(20,10,35,0.8), rgba(10,5,20,0.9));
    border: 1px solid #4a2a6a;
    border-radius: 10px;
    text-align: center;
    color: #c8b0e8;
    font-size: 11px;
    line-height: 1.8;
    box-shadow: 0 0 20px rgba(74,42,106,0.3), inset 0 0 15px rgba(74,42,106,0.1);
    position: relative;
}
.astrorap_moon_box::before {
    content: "🌑";
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 24px;
    filter: drop-shadow(0 0 8px rgba(160,120,255,0.8));
}
.astrorap_moon_box b {
    color: #d0b0ff;
    font-size: 13px;
    text-shadow: 0 0 10px rgba(160,120,255,0.6);
}

/* ═══════════ RESPONSIVE ═══════════ */
@media (max-width: 720px) {
    .astrorap_wrap { font-size: 10.5px; padding: 12px 8px 30px; }
    .astrorap_round { grid-template-columns: 1fr; gap: 8px; }
    .astrorap_ships { grid-template-columns: 1fr; }
    .astrorap_ship { grid-template-columns: 38px 1fr auto; padding: 4px 6px; }
    .astrorap_ship_img { width: 38px; height: 30px; }
    .astrorap_vs_name { font-size: 14px; }
    .astrorap_result { font-size: 17px; padding: 15px 10px; }
    .astrorap_round_label::before,
    .astrorap_round_label::after { width: 20%; }
    .astrorap_stats_grid { grid-template-columns: 1fr; gap: 10px; }
    .astrorap_moon_box::before { display: none; } /* Ocultar luna en móviles pequeños para no romper */
    
    /* En móviles, quitamos la regla para que el saqueo se ponga uno debajo del otro */
    .astrorap_stat_card.card-loot { grid-column: auto; }
}
</style>

<div class="astrorap_wrap">

    {* ═══════════ CABECERA VS (modo topkb) ═══════════ *}
    {if isset($Info)}
        <div class="astrorap_vs">
            <div class="astrorap_vs_name attacker {if $Raport.result == 'a'}winner{elseif $Raport.result == 'r'}loser{/if}">{$Info.0}</div>
            <div class="astrorap_vs_label">VS</div>
            <div class="astrorap_vs_name defender {if $Raport.result == 'r'}winner{elseif $Raport.result == 'a'}loser{/if}">{$Info.1}</div>
        </div>
    {/if}

    {* ═══════════ TÍTULO Y FECHA ═══════════ *}
    <div class="astrorap_date">
        {if $Raport.mode == 1}{$LNG.sys_destruc_title}{else}{$LNG.sys_attack_title}{/if}<br>
        <b>{$Raport.time}</b>
    </div>

    {* ═══════════ CLIMA DE LA BATALLA (NUEVO) ═══════════ *}
    {if isset($climaInfo) && $climaInfo}
    <div style="margin: 10px auto 20px; padding: 12px; background: linear-gradient(135deg, rgba(15,30,50,0.9), rgba(8,20,35,0.95)); border: 1px solid #4a9eff; border-radius: 8px; max-width: 680px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.5);">
        <b style="color: #4a9eff; font-size: 14px; letter-spacing: 1px;">🌦️ CLIMA DURANTE LA BATALLA</b><br>
        <span style="font-size: 16px; font-weight: bold; color: #fff; display: block; margin: 6px 0;">
            {if $climaInfo.clave == 'despejado'}☀️ Cielo Despejado
            {elseif $climaInfo.clave == 'brisa_solar'}🌤️ Brisa Solar
            {elseif $climaInfo.clave == 'viento_estelar'}🍃 Viento Estelar Suave
            {elseif $climaInfo.clave == 'cristalino'}✨ Cielo Cristalino
            {elseif $climaInfo.clave == 'niebla'}🌫️ Niebla Densísima
            {elseif $climaInfo.clave == 'tormenta_solar'}⚡ Tormenta Solar
            {elseif $climaInfo.clave == 'meteoros'}☄️ Lluvia de Meteoros
            {elseif $climaInfo.clave == 'nebulosa'}💰 Nebulosa Mineral
            {elseif $climaInfo.clave == 'plasma'}🌌 Nube de Plasma
            {elseif $climaInfo.clave == 'eclipse'}🌓 Eclipse Solar
            {elseif $climaInfo.clave == 'campo_mag'}🌀 Campo Magnético
            {elseif $climaInfo.clave == 'aurora'}🌈 Aurora Cósmica
            {elseif $climaInfo.clave == 'agujero'}🕳️ Agujero de Gusano
            {elseif $climaInfo.clave == 'singularidad'}⚫ Singularidad
            {/if}
        </span>
        <i style="font-size: 11px; color: #9ca3af;">"{$climaInfo.descripcion}"</i><br>
        
        <div style="margin-top: 8px; font-size: 11px; color: #cbd5e1; background: rgba(0,0,0,0.3); padding: 6px; border-radius: 4px;">
            <b>Ataque:</b> {if $climaInfo.factor_ataque > 1}+{/if}{math equation="round((x-1)*100)" x=$climaInfo.factor_ataque format="%d"}% | 
            <b>Defensa:</b> {if $climaInfo.factor_defensa > 1}+{/if}{math equation="round((x-1)*100)" x=$climaInfo.factor_defensa format="%d"}% | 
            <b>Bajas:</b> {if $climaInfo.factor_bajas > 1}+{/if}{math equation="round((x-1)*100)" x=$climaInfo.factor_bajas format="%d"}% | 
            <b>Botín:</b> {if $climaInfo.factor_botin > 1}+{/if}{math equation="round((x-1)*100)" x=$climaInfo.factor_botin format="%d"}%
        </div>

        {* 🆕 v1.2 — BUFF CLIMÁTICO APLICADO *}
        {if isset($buffInfo) && $buffInfo}
        <div style="margin-top: 8px; padding: 8px; background: rgba(74,255,136,0.1); border: 1px solid rgba(74,255,136,0.3); border-radius: 4px; font-size: 12px; color: #4aff88; text-align: center; box-shadow: inset 0 0 10px rgba(74,255,136,0.05);">
            <b>⚡ BUFF APLICADO:</b> 
            {if $buffInfo.clave == 'estabilizador_menor'}🌤️ Estabilizador Menor (-50% penalización)
            {elseif $buffInfo.clave == 'estabilizador_mayor'}🌈 Estabilizador Mayor (Neutraliza penalización)
            {elseif $buffInfo.clave == 'dominio'}⚡ Dominio Climático (Invierte penalización a bonus)
            {else}{$buffInfo.nombre}{/if}
        </div>
        {/if}
        {* FIN BUFF *}

    </div>
    {/if}
    {* ═══════════ FIN CLIMA ═══════════ *}

    {* ═══════════ RONDAS ═══════════ *}
    {foreach $Raport.rounds as $Round => $RoundInfo}

        <div class="astrorap_round_label">
            <span>Ronda</span>
            {$Round}
        </div>

        <div class="astrorap_round">

            {* ─── LADO ATACANTE ─── *}
            <div class="astrorap_side">
                {foreach $RoundInfo.attacker as $Player}
                    {$PlayerInfo = $Raport.players[$Player.userID]}
                    <div class="astrorap_card attacker {if empty($Player.ships)}defeated{/if}">
                        <div class="astrorap_card_head" onclick="astrorapToggle(this)">
                            <span class="astrorap_card_name">
                                {$LNG.sys_attack_attacker_pos} {$PlayerInfo.name}
                                {if isset($Info)}
                                    ([XX:XX:XX])
                                {else}
                                    ([{$PlayerInfo.koords[0]}:{$PlayerInfo.koords[1]}:{$PlayerInfo.koords[2]}]{if isset($PlayerInfo.koords[3])} ({$LNG["type_planet_short_{$PlayerInfo.koords[3]}"]}){/if})
                                {/if}
                            </span>
                            <span class="astrorap_toggle">+</span>
                        </div>

                        <div class="astrorap_card_bonus">
                            {$LNG.sys_ship_weapon} +{$PlayerInfo.tech[0]}% &middot;
                            {$LNG.sys_ship_shield} +{$PlayerInfo.tech[1]}% &middot;
                            {$LNG.sys_ship_armour} +{$PlayerInfo.tech[2]}%
                        </div>

                        <div class="astrorap_summary">
                            {if !empty($Player.ships)}
                                {assign var="totalShips" value=0}
                                {foreach $Player.ships as $ShipID => $ShipData}
                                    {assign var="totalShips" value=$totalShips + $ShipData[0]}
                                {/foreach}
                                <b>{$totalShips|number}</b> {$LNG.sys_units}
                            {else}
                                <span class="red">{$LNG.sys_destroyed}</span>
                            {/if}
                        </div>

                        {if !empty($Player.ships)}
                            <div class="astrorap_ships" style="display:none">
                                {foreach $Player.ships as $ShipID => $ShipData}
                                    <div class="astrorap_ship">
                                        <img class="astrorap_ship_img"
                                             src="./styles/theme/gow/gebaeude/{$ShipID}.gif"
                                             alt=""
                                             onerror="this.style.display='none'">
                                        <div class="astrorap_ship_info">
                                            <div class="astrorap_ship_name">{$LNG.shortNames.{$ShipID}}</div>
                                            <div class="astrorap_ship_count">{$ShipData[0]|number}</div>
                                        </div>
                                        <div class="astrorap_ship_stats">
                                            <b>{$ShipData[1]|number}</b><br>
                                            <b>{$ShipData[2]|number}</b><br>
                                            <b>{$ShipData[3]|number}</b>
                                        </div>
                                    </div>
                                {/foreach}
                            </div>
                        {else}
                            <div class="astrorap_empty" style="display:none">{$LNG.sys_destroyed}</div>
                        {/if}
                    </div>
                {/foreach}
            </div>

            {* ─── LADO DEFENSOR ─── *}
            <div class="astrorap_side">
                {foreach $RoundInfo.defender as $Player}
                    {$PlayerInfo = $Raport.players[$Player.userID]}
                    <div class="astrorap_card defender {if empty($Player.ships)}defeated{/if}">
                        <div class="astrorap_card_head" onclick="astrorapToggle(this)">
                            <span class="astrorap_card_name">
                                {$LNG.sys_attack_defender_pos} {$PlayerInfo.name}
                                {if isset($Info)}
                                    ([XX:XX:XX])
                                {else}
                                    ([{$PlayerInfo.koords[0]}:{$PlayerInfo.koords[1]}:{$PlayerInfo.koords[2]}]{if isset($PlayerInfo.koords[3])} ({$LNG.type_planet_short[$PlayerInfo.koords[3]]}){/if})
                                {/if}
                            </span>
                            <span class="astrorap_toggle">+</span>
                        </div>

                        <div class="astrorap_card_bonus">
                            {$LNG.sys_ship_weapon} +{$PlayerInfo.tech[0]}% &middot;
                            {$LNG.sys_ship_shield} +{$PlayerInfo.tech[1]}% &middot;
                            {$LNG.sys_ship_armour} +{$PlayerInfo.tech[2]}%
                        </div>

                        <div class="astrorap_summary">
                            {if !empty($Player.ships)}
                                {assign var="totalShips" value=0}
                                {foreach $Player.ships as $ShipID => $ShipData}
                                    {assign var="totalShips" value=$totalShips + $ShipData[0]}
                                {/foreach}
                                <b>{$totalShips|number}</b> {$LNG.sys_units}
                            {else}
                                <span class="red">{$LNG.sys_destroyed}</span>
                            {/if}
                        </div>

                        {if !empty($Player.ships)}
                            <div class="astrorap_ships" style="display:none">
                                {foreach $Player.ships as $ShipID => $ShipData}
                                    <div class="astrorap_ship">
                                        <img class="astrorap_ship_img"
                                             src="./styles/theme/gow/gebaeude/{$ShipID}.gif"
                                             alt=""
                                             onerror="this.style.display='none'">
                                        <div class="astrorap_ship_info">
                                            <div class="astrorap_ship_name">{$LNG.shortNames.{$ShipID}}</div>
                                            <div class="astrorap_ship_count">{$ShipData[0]|number}</div>
                                        </div>
                                        <div class="astrorap_ship_stats">
                                            <b>{$ShipData[1]|number}</b><br>
                                            <b>{$ShipData[2]|number}</b><br>
                                            <b>{$ShipData[3]|number}</b>
                                        </div>
                                    </div>
                                {/foreach}
                            </div>
                        {else}
                            <div class="astrorap_empty" style="display:none">{$LNG.sys_destroyed}</div>
                        {/if}
                    </div>
                {/foreach}
            </div>

        </div>

        {* ─── BARRA DE BALANCE DE LA RONDA ─── *}
        {if !$RoundInfo@last && isset($RoundInfo.info)}
            {assign var="att_dmg" value=$RoundInfo.info[3]}
            {assign var="def_dmg" value=$RoundInfo.info[1]}
            {assign var="total_dmg" value=$att_dmg + $def_dmg}
            {if $total_dmg > 0}
                {math equation="(a/(a+b))*100" a=$att_dmg b=$def_dmg assign=balance}
            {else}
                {assign var="balance" value=50}
            {/if}
            <div class="astrorap_balance">
                <div class="astrorap_balance_fill" style="width: {$balance|round}%"></div>
                <div class="astrorap_balance_marker"></div>
            </div>
            <div class="astrorap_round_info">
                {$LNG.fleet_attack_1} <b>{$RoundInfo.info[0]|number}</b> {$LNG.fleet_attack_2} <b>{$RoundInfo.info[3]|number}</b> {$LNG.damage} &middot;
                {$LNG.fleet_defs_1} <span class="def">{$RoundInfo.info[2]|number}</span> {$LNG.fleet_defs_2} <span class="def">{$RoundInfo.info[1]|number}</span> {$LNG.damage}
            </div>
        {/if}

    {/foreach}

    {* ═══════════ RESULTADO FINAL (NUEVO DISEÑO) ═══════════ *}
    <div class="astrorap_result {if $Raport.result == 'a'}a{elseif $Raport.result == 'r'}r{else}draw{/if}">
        {if $Raport.result == "a"}{$LNG.sys_attacker_won}
        {elseif $Raport.result == "r"}{$LNG.sys_defender_won}
        {else}{$LNG.sys_both_won}{/if}
    </div>

    <div class="astrorap_balance final">
        <div class="astrorap_balance_fill" style="width: 100%"></div>
        <div class="astrorap_balance_marker"></div>
    </div>

    {* ═══════════ NUEVO PANEL DE ESTADÍSTICAS (GRID) ═══════════ *}
    <div class="astrorap_stats_grid">
        
        {* 1. Tarjeta: Pérdidas Atacante *}
        <div class="astrorap_stat_card card-attacker">
            <div class="astrorap_stat_icon">⚔️</div>
            <div class="astrorap_stat_title">{$LNG.sys_attacker_lostunits}</div>
            <div class="astrorap_stat_value red">
                <b>{$Raport['units'][0]|number}</b> {$LNG.sys_units}
            </div>
        </div>

        {* 2. Tarjeta: Pérdidas Defensor *}
        <div class="astrorap_stat_card card-defender">
            <div class="astrorap_stat_icon">🛡️</div>
            <div class="astrorap_stat_title">{$LNG.sys_defender_lostunits}</div>
            <div class="astrorap_stat_value red">
                <b>{$Raport['units'][1]|number}</b> {$LNG.sys_units}
            </div>
        </div>

        {* 3. Tarjeta: Escombros (Movida a la primera fila) *}
        <div class="astrorap_stat_card card-debris">
            <div class="astrorap_stat_icon">💥</div>
            <div class="astrorap_stat_title">{$LNG.debree_field_1}</div>
            <div class="astrorap_stat_value">
                {if !empty($Raport.debris)}
                    {foreach $Raport.debris as $elementID => $amount}
                        <span class="{if $elementID == 901}m{elseif $elementID == 902}c{elseif $elementID == 903}d{/if}">
                            {$amount|number}
                        </span>
                        <span style="font-size:10px; color:#7a8aa0;">{$LNG.tech.$elementID}</span>
                        {if !$amount@last}<br>{/if}
                    {/foreach}
                {else}
                    <span style="color:#4a5568;">-</span>
                {/if}
            </div>
        </div>

        {* 4. Tarjeta: Saqueo (Botín) - Forzada al centro de la segunda fila *}
        <div class="astrorap_stat_card card-loot">
            <div class="astrorap_stat_icon">💰</div>
            <div class="astrorap_stat_title">Saqueo</div>
            <div class="astrorap_stat_value">
                {if !empty($Raport.loot)}
                    {foreach $Raport.loot as $elementID => $amount}
                        <span class="{if $elementID == 901}m{elseif $elementID == 902}c{elseif $elementID == 903}d{/if}">
                            {$amount|number}
                        </span>
                        <span style="font-size:10px; color:#7a8aa0;">{$LNG.tech.$elementID}</span>
                        {if !$amount@last}<br>{/if}
                    {/foreach}
                {elseif !empty($Raport.steal)}
                    {* Algunos motores usan steal en vez de loot *}
                    {foreach $Raport.steal as $elementID => $amount}
                        <span class="{if $elementID == 901}m{elseif $elementID == 902}c{elseif $elementID == 903}d{/if}">
                            {$amount|number}
                        </span>
                        <span style="font-size:10px; color:#7a8aa0;">{$LNG.tech.$elementID}</span>
                        {if !$amount@last}<br>{/if}
                    {/foreach}
                {else}
                    <span style="color:#4a5568;">-</span>
                {/if}
            </div>
        </div>

    </div>

    {* ═══════════ INFO DE LUNA (NUEVO DISEÑO MÍSTICO) ═══════════ *}
    {if $Raport.mode == 1}
        <div class="astrorap_moon_box">
            {if $Raport.moon.moonDestroySuccess == -1}
                {$LNG.sys_destruc_stop}
            {else}
                {sprintf($LNG.sys_destruc_lune, "{$Raport.moon.moonDestroyChance}")}<br>
                {$LNG.sys_destruc_mess1}
                {if $Raport.moon.moonDestroySuccess == 1}
                    &mdash; {$LNG.sys_destruc_reussi}
                {elseif $Raport.moon.moonDestroySuccess == 0}
                    &mdash; {$LNG.sys_destruc_null}
                {/if}
                <br>
                {sprintf($LNG.sys_destruc_rip, "{$Raport.moon.fleetDestroyChance}")}
                {if $Raport.moon.fleetDestroySuccess == 1}
                    <br>{$LNG.sys_destruc_echec}
                {/if}
            {/if}
        </div>
    {else}
        {if isset($Raport.moon.moonChance)}
            <div class="astrorap_moon_box">
                {$LNG.sys_moonproba} <b>{$Raport.moon.moonChance} %</b>
                {if !empty($Raport.moon.moonName)}
                    <br>
                    {if isset($Info)}
                        {sprintf($LNG.sys_moonbuilt, "{$Raport.moon.moonName}", "XX", "XX", "XX")}
                    {else}
                        {sprintf($LNG.sys_moonbuilt, "{$Raport.moon.moonName}", "{$Raport.koords[0]}", "{$Raport.koords[1]}", "{$Raport.koords[2]}")}
                    {/if}
                {/if}
            </div>
        {/if}
    {/if}

    {* ═══════════ INFO ADICIONAL ═══════════ *}
    {if !empty($Raport.additionalInfo)}
        <div class="astrorap_info_box" style="max-width:720px; margin:12px auto; padding:12px 16px; background:rgba(10,25,45,0.65); border:1px solid #1e3a5a; border-radius:8px; text-align:center; color:#7a8aa0; font-size:10.5px; line-height:1.9;">
            {$Raport.additionalInfo}
        </div>
    {/if}

</div>

<script>
/* ═══════════ ACORDEÓN DE TARJETAS ═══════════ */
function astrorapToggle(head) {
    var card = head.parentNode;
    var target = card.querySelector('.astrorap_ships, .astrorap_empty');
    var summary = card.querySelector('.astrorap_summary');
    var toggle = head.querySelector('.astrorap_toggle');
    if (!target) return;
    if (target.style.display === 'none') {
        target.style.display = '';
        if (summary) summary.style.display = 'none';
        toggle.textContent = '\u2212';
    } else {
        target.style.display = 'none';
        if (summary) summary.style.display = '';
        toggle.textContent = '+';
    }
}
</script>

{/block}