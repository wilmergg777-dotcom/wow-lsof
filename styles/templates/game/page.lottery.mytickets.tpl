{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.lottery.mytickets.tpl === *}
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
   LOTERÍA — Mis Tickets (Simplificado Extremo)
   ═══════════════════════════════════════════════════════════ */
:root {
    --bg-card: rgba(15, 23, 42, 0.75);
    --border-color: #1e293b;
    --text-main: #cbd5e1;
    --text-muted: #94a3b8;
    --accent-cyan: #00e0ff;
    --accent-green: #4aff88;
    --accent-gold: #fbbf24;
}

.astrolot_wrap { max-width: 900px; margin: 0 auto; text-align: center; }

.astrolot_balance_box {
    margin-bottom: 12px; padding: 8px 14px;
    background: rgba(0, 40, 20, 0.35);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px; text-align: center;
}
.astrolot_balance_badge { color: #66ff99; font-size: 12px; font-weight: 600; }
.astrolot_balance_badge strong { color: #88ffbb; font-family: 'Courier New', monospace; font-size: 14px; }

.astrolot_nav { margin-bottom: 12px; text-align: left; }
.astrolot_nav a {
    color: var(--accent-cyan); text-decoration: none; font-size: 11px;
    margin-right: 14px; padding: 4px 10px; border-radius: 6px;
    transition: all 0.25s ease; border: 1px solid transparent;
}
.astrolot_nav a:hover { background: rgba(0, 224, 255, 0.1); border-color: rgba(0, 224, 255, 0.4); text-decoration: none; }
.astrolot_nav a.active { background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); border-color: var(--accent-cyan); }

.astrolot_panel {
    background: var(--bg-card); border: 1px solid var(--border-color);
    border-radius: 10px; padding: 14px 16px; margin-bottom: 14px; text-align: left;
}
.astrolot_title {
    text-transform: uppercase; color: var(--accent-cyan); font-size: 13px;
    font-weight: bold; border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 6px; margin-bottom: 10px;
}

.astrolot_stats { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px; margin-bottom: 12px; }
.astrolot_stat { background: rgba(0, 0, 0, 0.35); border: 1px solid var(--border-color); border-radius: 8px; padding: 12px; text-align: center; }
.astrolot_stat_val { color: var(--accent-cyan); font-size: 22px; font-weight: bold; font-family: 'Courier New', monospace; }
.astrolot_stat_val.gold { color: var(--accent-gold); }
.astrolot_stat_lbl { color: var(--text-muted); font-size: 9px; text-transform: uppercase; margin-top: 3px; }

.astrolot_ticket {
    background: rgba(0, 0, 0, 0.35); border: 1px solid var(--border-color);
    border-left: 3px solid var(--accent-cyan); border-radius: 8px;
    padding: 10px 14px; margin-bottom: 8px;
}
.astrolot_ticket.win { border-left-color: var(--accent-gold); background: rgba(251, 191, 36, 0.05); }
.astrolot_ticket.lose { border-left-color: var(--text-muted); opacity: 0.7; }

.astrolot_ticket_head { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
.astrolot_ticket_name { color: #fff; font-weight: bold; font-size: 11.5px; }
.astrolot_ticket_badge { font-size: 9px; padding: 2px 8px; border-radius: 10px; background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); text-transform: uppercase; }
.astrolot_ticket_badge.win { background: rgba(251, 191, 36, 0.15); color: var(--accent-gold); }
.astrolot_ticket_badge.end { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); }

.astrolot_ticket_nums { display: flex; gap: 4px; flex-wrap: wrap; margin: 6px 0; }
.astrolot_ticket_num {
    display: inline-flex; align-items: center; justify-content: center;
    width: 28px; height: 28px; background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff; border-radius: 6px; font-weight: bold; font-family: 'Courier New', monospace; font-size: 12px;
}

.astrolot_ticket_info { font-size: 10.5px; color: var(--text-main); line-height: 1.7; margin-top: 6px; }
.astrolot_ticket_info b { color: #fff; }
.astrolot_ticket_info .green { color: var(--accent-green); }
.astrolot_ticket_info .gold { color: var(--accent-gold); }
.astrolot_ticket_info .grey { color: var(--text-muted); }

.astrolot_empty { color: var(--text-muted); font-size: 11px; text-align: center; padding: 30px; font-style: italic; }
</style>

<div class="astrolot_wrap">

    <div class="astrolot_balance_box">
        <span class="astrolot_balance_badge">
            💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}
        </span>
    </div>

    <div class="astrolot_nav">
        <a href="game.php?page=lottery">Lotería</a>
        <a href="game.php?page=lottery&mode=myTickets" class="active">Mis Tickets</a>
        <a href="game.php?page=lottery&mode=history">Historial</a>
    </div>

    <div class="astrolot_panel">
        <div class="astrolot_title">📊 Resumen</div>
        <div class="astrolot_stats">
            <div class="astrolot_stat">
                <div class="astrolot_stat_val">{$tickets|@count}</div>
                <div class="astrolot_stat_lbl">Tickets Totales</div>
            </div>
            <div class="astrolot_stat">
                <div class="astrolot_stat_val gold">{$ganadores}</div>
                <div class="astrolot_stat_lbl">Tickets Ganadores</div>
            </div>
        </div>
    </div>

    <div class="astrolot_panel">
        <div class="astrolot_title">🎟️ Mis Tickets</div>

        {foreach from=$tickets item=tkt}
            <div class="astrolot_ticket">
                <div class="astrolot_ticket_head">
                    <span class="astrolot_ticket_name">Sorteo #{$tkt.numero_sorteo}</span>
                    {if $tkt.estado == 'abierto'}
                        <span class="astrolot_ticket_badge">Abierto</span>
                    {elseif $tkt.tipo_premio == 'jackpot'}
                        <span class="astrolot_ticket_badge win">🏆 Jackpot</span>
                    {elseif $tkt.tipo_premio == '3_aciertos' || $tkt.tipo_premio == '2_aciertos'}
                        <span class="astrolot_ticket_badge win">Ganador</span>
                    {elseif $tkt.estado == 'sorteado'}
                        <span class="astrolot_ticket_badge end">Sorteado</span>
                    {else}
                        <span class="astrolot_ticket_badge">-</span>
                    {/if}
                </div>

                <div class="astrolot_ticket_info">
                    <div>💰 Pagado: <b>{$tkt.precio_pagado|number_format:0:',,':'.'} {$tkt.moneda_pagada_label}</b> · 📅 {$tkt.fecha_compra|date_format:"%d/%m/%Y %H:%M"}</div>

                    {if $tkt.estado == 'sorteado'}
                        <div>
                            🎯 Aciertos: <b>{$tkt.aciertos}</b>
                            {if $tkt.tipo_premio == 'jackpot'}
                                · <span class="gold">🏆 GANADOR DEL JACKPOT: +{$tkt.premio_ganado_display|number_format:0:',,':'.'} {$tkt.moneda_pagada_label}</span>
                            {elseif $tkt.tipo_premio == '3_aciertos' || $tkt.tipo_premio == '2_aciertos'}
                                · <span class="green">🎉 Premio: +{$tkt.premio_ganado_display|number_format:0:',,':'.'} {$tkt.moneda_pagada_label}</span>
                            {else}
                                · <span class="grey">Sin premio</span>
                            {/if}
                        </div>
                        {if $tkt.numeros_sorteados}
                            <div>🎰 Números sorteados: <b>{$tkt.numeros_sorteados}</b></div>
                        {/if}
                    {elseif $tkt.estado == 'abierto'}
                        <div class="grey">⏳ Esperando el sorteo</div>
                    {/if}
                </div>
            </div>
        {foreachelse}
            <div class="astrolot_empty">
                🎟️ No tenés tickets todavía.<br>
                <small>Andá a la <a href="game.php?page=lottery" style="color:var(--accent-cyan);">Lotería</a> y comprá uno.</small>
            </div>
        {/foreach}
    </div>

</div>

{/block}