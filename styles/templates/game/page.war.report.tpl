{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.war.report.tpl === *}
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

{* ============================================ *}
{* ⚔️ TAB: INFORME DETALLADO DE BATALLA        *}
{* ============================================ *}

<div class="astrowar_section">📋 Informe de Batalla #{$war_battle.id}</div>

{* ============================================ *}
{* 1) CABECERA: ATACANTE vs DEFENSOR            *}
{* ============================================ *}
<div class="astrowar_report_head">
    <div class="astrowar_report_side astrowar_report_side-atk">
        <div class="astrowar_report_label">👤 ATACANTE</div>
        <div class="astrowar_report_name">🏰 {$war_battle.atacante_nombre}</div>
    </div>

    <div class="astrowar_report_vs">VS</div>

    <div class="astrowar_report_side astrowar_report_side-def">
        <div class="astrowar_report_label">👤 DEFENSOR</div>
        <div class="astrowar_report_name">🏰 {$war_battle.defensor_nombre}</div>
    </div>
</div>

{* ============================================ *}
{* 2) DATOS GENERALES                           *}
{* ============================================ *}
<div class="astrowar_report_meta">
    <div class="astrowar_report_meta_item">
        📅 Inicio: <b>{$war_battle.inicio|date_format:"%d/%m/%Y %H:%M"}</b>
    </div>
    <div class="astrowar_report_meta_item">
        📅 Fin: <b>{$war_battle.fin|date_format:"%d/%m/%Y %H:%M"}</b>
    </div>
    <div class="astrowar_report_meta_item">
        📊 Rondas jugadas: <b>{$war_report.rondas|@count}</b>
    </div>
    <div class="astrowar_report_meta_item">
        📌 Estado:
        <b>
        {if $war_battle.estado == 'finalizada'}
            FINALIZADA
        {elseif $war_battle.estado == 'cancelada'}
            CANCELADA
        {else}
            EN CURSO
        {/if}
        </b>
    </div>
</div>

{* ============================================ *}
{* 3) CLIMA                                     *}
{* ============================================ *}
{if $war_clima}
<div class="astrowar_clima" style="margin:12px 0;">
    <b>{$war_clima.emoji} {$war_clima.nombre}</b><br>
    <span style="font-size:10.5px;color:#aab;">{$war_clima.descripcion}</span><br>
    📉 Ataque: <b>{($war_clima.atk * 100)|round}%</b>
    &nbsp;|&nbsp;
    🛡️ Defensa: <b>{($war_clima.def * 100)|round}%</b>
</div>
{/if}

{* ============================================ *}
{* 4) RESULTADO FINAL                           *}
{* ============================================ *}
<div class="astrowar_report_result">
    {if $war_battle.resultado_final == 'victoria_atacante'}
        <div class="astrowar_report_resbox astrowar_report_resbox-atk">
            🏆 VICTORIA DEL ATACANTE
            <div class="astrowar_report_resbox_sub">
                🏰 {$war_battle.atacante_nombre}
            </div>
        </div>
    {elseif $war_battle.resultado_final == 'victoria_defensor'}
        <div class="astrowar_report_resbox astrowar_report_resbox-def">
            🏆 VICTORIA DEL DEFENSOR
            <div class="astrowar_report_resbox_sub">
                🏰 {$war_battle.defensor_nombre}
            </div>
        </div>
    {elseif $war_battle.resultado_final == 'empate'}
        <div class="astrowar_report_resbox astrowar_report_resbox-tie">
            🤝 EMPATE
            <div class="astrowar_report_resbox_sub">
                Nadie se llevó la victoria
            </div>
        </div>
    {else}
        <div class="astrowar_report_resbox astrowar_report_resbox-cancel">
            ⛔ BATALLA CANCELADA
        </div>
    {/if}
</div>

{* ============================================ *}
{* 5) BONUSES DEL BANCO APLICADOS               *}
{* ============================================ *}
{if $war_report.bonusA.attack > 0 || $war_report.bonusA.defense > 0 || $war_report.bonusD.attack > 0 || $war_report.bonusD.defense > 0}
<div class="astrowar_section">✨ Bonuses del Banco aplicados</div>
<div class="astrowar_report_bonus_grid">
    <div class="astrowar_report_bonus_col astrowar_report_bonus_col-atk">
        <div class="astrowar_report_bonus_title">🏰 {$war_battle.atacante_nombre}</div>
        <div class="astrowar_report_bonus_row">
            ⚔️ Ataque: <b>+{$war_report.bonusA.attack}%</b>
        </div>
        <div class="astrowar_report_bonus_row">
            🛡️ Defensa: <b>+{$war_report.bonusA.defense}%</b>
        </div>
    </div>
    <div class="astrowar_report_bonus_col astrowar_report_bonus_col-def">
        <div class="astrowar_report_bonus_title">🏰 {$war_battle.defensor_nombre}</div>
        <div class="astrowar_report_bonus_row">
            ⚔️ Ataque: <b>+{$war_report.bonusD.attack}%</b>
        </div>
        <div class="astrowar_report_bonus_row">
            🛡️ Defensa: <b>+{$war_report.bonusD.defense}%</b>
        </div>
    </div>
</div>
{/if}

{* ============================================ *}
{* 6) RONDAS DEL COMBATE                        *}
{* ============================================ *}
<div class="astrowar_section">⚔️ Rondas del combate</div>

{if $war_report.rondas|@count > 0}

    <div class="astrowar_report_rounds">

        {foreach $war_report.rondas as $r}
            <div class="astrowar_report_round">

                <div class="astrowar_report_round_head">
                    📊 RONDA {$r.ronda}
                </div>

                <div class="astrowar_report_round_grid">

                    {* --- Atacante --- *}
                    <div class="astrowar_report_round_side astrowar_report_round_side-atk">
                        <div class="astrowar_report_round_title">
                            🚀 ATACANTE
                        </div>
                        <div class="astrowar_report_round_power">
                            Poder: <b>{$r.poderA}</b>
                        </div>

                        {if $r.bajasA|@count > 0}
                            <div class="astrowar_report_round_bajas_title">💀 Bajas:</div>
                            <div class="astrowar_report_round_bajas">
                                {foreach $r.bajasA as $unit => $cant}
                                    <div class="astrowar_report_round_baja">
                                        ⚔️ {$unit|replace:'_':' '}: <b>{$cant}</b>
                                    </div>
                                {/foreach}
                            </div>
                        {else}
                            <div class="astrowar_report_round_nobajas">Sin bajas</div>
                        {/if}
                    </div>

                    {* --- Defensor --- *}
                    <div class="astrowar_report_round_side astrowar_report_round_side-def">
                        <div class="astrowar_report_round_title">
                            🛡️ DEFENSOR
                        </div>
                        <div class="astrowar_report_round_power">
                            Poder: <b>{$r.poderD}</b>
                        </div>

                        {if $r.bajasD|@count > 0}
                            <div class="astrowar_report_round_bajas_title">💀 Bajas:</div>
                            <div class="astrowar_report_round_bajas">
                                {foreach $r.bajasD as $unit => $cant}
                                    <div class="astrowar_report_round_baja">
                                        ⚔️ {$unit|replace:'_':' '}: <b>{$cant}</b>
                                    </div>
                                {/foreach}
                            </div>
                        {else}
                            <div class="astrowar_report_round_nobajas">Sin bajas</div>
                        {/if}
                    </div>

                </div>

            </div>
        {/foreach}

    </div>

{else}

    <div class="astrowar_empty">
        No hay rondas registradas (la batalla se canceló o no tuvo participantes).
    </div>

{/if}

{* ============================================ *}
{* 7) BAJAS TOTALES                             *}
{* ============================================ *}
{if $war_report.bajasA|@count > 0 || $war_report.bajasD|@count > 0}
<div class="astrowar_section">💀 Bajas totales</div>

<div class="astrowar_report_totales_grid">
    <div class="astrowar_report_totales_col astrowar_report_totales_col-atk">
        <div class="astrowar_report_totales_title">
            🚀 {$war_battle.atacante_nombre}
        </div>
        {if $war_report.bajasA|@count > 0}
            {foreach $war_report.bajasA as $unit => $cant}
                <div class="astrowar_report_totales_row">
                    {$unit|replace:'_':' '}: <b>{$cant}</b>
                </div>
            {/foreach}
        {else}
            <div class="astrowar_report_totales_row" style="color:#66ff99;">
                Sin bajas
            </div>
        {/if}
    </div>
    <div class="astrowar_report_totales_col astrowar_report_totales_col-def">
        <div class="astrowar_report_totales_title">
            🛡️ {$war_battle.defensor_nombre}
        </div>
        {if $war_report.bajasD|@count > 0}
            {foreach $war_report.bajasD as $unit => $cant}
                <div class="astrowar_report_totales_row">
                    {$unit|replace:'_':' '}: <b>{$cant}</b>
                </div>
            {/foreach}
        {else}
            <div class="astrowar_report_totales_row" style="color:#66ff99;">
                Sin bajas
            </div>
        {/if}
    </div>
</div>
{/if}

{* ============================================ *}
{* 8) BOTÓN VOLVER                              *}
{* ============================================ *}
<div style="text-align:center;padding-top:12px;border-top:1px solid rgba(0,224,255,0.15);margin-top:16px;">
    <a href="game.php?page=war&amp;tab=historial" class="astrowar_tab">◀️ Volver al Historial</a>
</div>

<style>
/* ============================================
   INFORME DE BATALLA
   ============================================ */

.astrowar_report_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin: 10px 0;
    flex-wrap: wrap;
}
.astrowar_report_side {
    flex: 1;
    min-width: 200px;
    padding: 10px 14px;
    border-radius: 8px;
    text-align: center;
    border: 2px solid;
}
.astrowar_report_side-atk {
    background: linear-gradient(180deg, #3a1a0a, #1a0a05);
    border-color: #ff6633;
}
.astrowar_report_side-def {
    background: linear-gradient(180deg, #0a1a3a, #050a1a);
    border-color: #3399ff;
}
.astrowar_report_label {
    font-size: 9.5px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 4px;
    font-weight: 700;
}
.astrowar_report_name {
    font-size: 13px;
    font-weight: 800;
    color: #fff;
}
.astrowar_report_side-atk .astrowar_report_name { color: #ffaa88; }
.astrowar_report_side-def .astrowar_report_name { color: #88ccff; }

.astrowar_report_vs {
    font-size: 20px;
    font-weight: 900;
    color: #ff4488;
    text-shadow: 0 0 12px rgba(255, 68, 136, 0.6);
    padding: 0 6px;
}

.astrowar_report_meta {
    display: flex;
    gap: 14px;
    flex-wrap: wrap;
    justify-content: center;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 6px;
    margin-bottom: 12px;
    font-size: 10.5px;
}
.astrowar_report_meta_item {
    color: #8899aa;
}
.astrowar_report_meta_item b {
    color: #00e0ff;
}

.astrowar_report_result {
    margin: 12px 0;
    text-align: center;
}
.astrowar_report_resbox {
    padding: 14px 20px;
    border-radius: 10px;
    font-size: 16px;
    font-weight: 900;
    letter-spacing: 1px;
    border: 2px solid;
}
.astrowar_report_resbox-atk {
    background: linear-gradient(135deg, #006633, #00cc66);
    border-color: #00ff88;
    color: #fff;
    box-shadow: 0 0 20px rgba(0, 204, 102, 0.4);
}
.astrowar_report_resbox-def {
    background: linear-gradient(135deg, #003366, #0066cc);
    border-color: #3399ff;
    color: #fff;
    box-shadow: 0 0 20px rgba(51, 153, 255, 0.4);
}
.astrowar_report_resbox-tie {
    background: linear-gradient(135deg, #664400, #cc8800);
    border-color: #ffaa33;
    color: #221800;
    box-shadow: 0 0 20px rgba(255, 170, 51, 0.4);
}
.astrowar_report_resbox-cancel {
    background: #333a44;
    border-color: #556677;
    color: #aabbcc;
}
.astrowar_report_resbox_sub {
    font-size: 11px;
    font-weight: 500;
    margin-top: 4px;
    opacity: 0.85;
}

/* ============ BONUSES ============ */
.astrowar_report_bonus_grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
}
.astrowar_report_bonus_col {
    padding: 10px 14px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border-left: 3px solid;
    border-radius: 6px;
}
.astrowar_report_bonus_col-atk { border-left-color: #ff6633; }
.astrowar_report_bonus_col-def { border-left-color: #3399ff; }
.astrowar_report_bonus_title {
    font-size: 11px;
    font-weight: 800;
    color: #fff;
    margin-bottom: 6px;
}
.astrowar_report_bonus_row {
    font-size: 11px;
    color: #c8d6e5;
    padding: 2px 0;
}
.astrowar_report_bonus_row b { color: #00e0ff; }

/* ============ RONDAS ============ */
.astrowar_report_rounds {
    display: flex;
    flex-direction: column;
    gap: 10px;
}
.astrowar_report_round {
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-radius: 8px;
    overflow: hidden;
}
.astrowar_report_round_head {
    padding: 6px 12px;
    background: linear-gradient(180deg, #004488, #0066cc);
    color: #fff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.8px;
    text-transform: uppercase;
}
.astrowar_report_round_grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    padding: 10px;
}
.astrowar_report_round_side {
    padding: 8px 10px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 6px;
    border-left: 3px solid;
}
.astrowar_report_round_side-atk { border-left-color: #ff6633; }
.astrowar_report_round_side-def { border-left-color: #3399ff; }

.astrowar_report_round_title {
    font-size: 10.5px;
    font-weight: 800;
    color: #fff;
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowar_report_round_power {
    font-size: 10.5px;
    color: #8899aa;
    margin-bottom: 6px;
}
.astrowar_report_round_power b {
    color: #ffaa33;
    font-family: 'Courier New', monospace;
    font-size: 12px;
}
.astrowar_report_round_bajas_title {
    font-size: 9.5px;
    color: #ff8888;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    margin-bottom: 2px;
}
.astrowar_report_round_bajas {
    font-size: 10px;
}
.astrowar_report_round_baja {
    color: #c8d6e5;
    padding: 1px 0;
}
.astrowar_report_round_baja b { color: #ff4488; }
.astrowar_report_round_nobajas {
    font-size: 10px;
    color: #66ff99;
    font-style: italic;
}

/* ============ BAJAS TOTALES ============ */
.astrowar_report_totales_grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-top: 8px;
}
.astrowar_report_totales_col {
    padding: 10px 14px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border-left: 3px solid;
    border-radius: 6px;
}
.astrowar_report_totales_col-atk { border-left-color: #ff6633; }
.astrowar_report_totales_col-def { border-left-color: #3399ff; }
.astrowar_report_totales_title {
    font-size: 11px;
    font-weight: 800;
    color: #fff;
    margin-bottom: 6px;
    padding-bottom: 4px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.1);
}
.astrowar_report_totales_row {
    font-size: 10.5px;
    color: #c8d6e5;
    padding: 2px 0;
}
.astrowar_report_totales_row b { color: #ff4488; }

/* ============ RESPONSIVE ============ */
@media (max-width: 720px) {
    .astrowar_report_bonus_grid,
    .astrowar_report_round_grid,
    .astrowar_report_totales_grid {
        grid-template-columns: 1fr;
    }
    .astrowar_report_head {
        flex-direction: column;
    }
    .astrowar_report_vs {
        padding: 6px 0;
    }
}
</style>