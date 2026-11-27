{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.lottery.history.tpl === *}
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

/* 🆕 Barra de Navegación (Lotería / Mis Tickets / Historial) */
.astrolot_nav {
    margin-bottom: 12px;
    text-align: left;
}
.astrolot_nav a {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 11px;
    margin-right: 14px;
    padding: 4px 10px;
    border-radius: 6px;
    transition: all 0.25s ease;
    border: 1px solid transparent;
}
.astrolot_nav a:hover {
    background: rgba(0, 224, 255, 0.1);
    border-color: rgba(0, 224, 255, 0.4);
    text-decoration: none;
    transform: translateY(-1px);
}
.astrolot_nav a.active {
    background: rgba(0, 224, 255, 0.15);
    color: var(--accent-cyan);
    border-color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}

.astrolot_panel { 
    background: var(--bg-card); 
    border: 1px solid var(--border-color); 
    border-radius: 10px; 
    padding: 14px 16px; 
    margin-bottom: 14px; 
    text-align: left; 
}
.astrolot_title { 
    text-transform: uppercase; 
    color: var(--accent-cyan); 
    font-size: 13px; 
    font-weight: bold; 
    border-bottom: 1px solid rgba(0, 224, 255, 0.2); 
    padding-bottom: 6px; 
    margin-bottom: 10px; 
}
.astrolot_hist_item { 
    background: rgba(0, 0, 0, 0.35); 
    border: 1px solid var(--border-color); 
    border-left: 3px solid var(--accent-cyan); 
    border-radius: 8px; 
    padding: 10px 14px; 
    margin-bottom: 8px; 
}
.astrolot_hist_head { 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    margin-bottom: 6px; 
}
.astrolot_hist_name { 
    color: #fff; 
    font-weight: bold; 
    font-size: 12px; 
}
.astrolot_hist_badge { 
    font-size: 9px; 
    padding: 2px 8px; 
    border-radius: 10px; 
    text-transform: uppercase; 
}
.astrolot_hist_badge.abierto { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); border: 1px solid rgba(74, 255, 136, 0.3); }
.astrolot_hist_badge.sorteado { background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); border: 1px solid rgba(0, 224, 255, 0.3); }
.astrolot_hist_badge.jackpot { background: rgba(251, 191, 36, 0.15); color: var(--accent-gold); border: 1px solid rgba(251, 191, 36, 0.4); }
.astrolot_hist_badge.rollover { background: rgba(251, 191, 36, 0.15); color: var(--accent-gold); border: 1px solid rgba(251, 191, 36, 0.4); }

.astrolot_hist_nums { display: flex; gap: 5px; flex-wrap: wrap; margin: 8px 0; }
.astrolot_hist_num { 
    display: inline-flex; 
    align-items: center; 
    justify-content: center; 
    width: 32px; 
    height: 32px; 
    background: linear-gradient(135deg, #0066cc, #0099ff); 
    color: #fff; 
    border-radius: 6px; 
    font-weight: bold; 
    font-family: 'Courier New', monospace; 
    font-size: 13px; 
}
.astrolot_hist_info { font-size: 10.5px; color: var(--text-main); line-height: 1.7; }
.astrolot_hist_info b { color: #fff; }
.astrolot_hist_info .gold { color: var(--accent-gold); }
.astrolot_hist_info .green { color: var(--accent-green); }
.astrolot_hist_info .grey { color: var(--text-muted); }
.astrolot_hist_info .warn { color: var(--accent-gold); }
.astrolot_empty { color: var(--text-muted); font-size: 11px; text-align: center; padding: 30px; font-style: italic; }
</style>

<div class="astrolot_wrap">

    <div class="astrolot_panel" style="text-align: center; margin-bottom: 12px;">
        <span style="color: #66ff99;">💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}</span>
    </div>

    {* 🆕 MENÚ DE NAVEGACIÓN RESTAURADO *}
    <div class="astrolot_nav">
        <a href="game.php?page=lottery">Lotería</a>
        <a href="game.php?page=lottery&mode=myTickets">Mis Tickets</a>
        <a href="game.php?page=lottery&mode=history" class="active">Historial</a>
    </div>

    <div class="astrolot_panel">
        <div class="astrolot_title">📜 Historial de Sorteos</div>

        {if $hay_sorteos}
            {foreach from=$sorteos item=item}
                <div class="astrolot_hist_item">
                    <div class="astrolot_hist_head">
                        <span class="astrolot_hist_name">Sorteo #{$item.numero_sorteo}</span>
                        {if $item.estado == 'abierto'}
                            <span class="astrolot_hist_badge abierto">🟢 Abierto</span>
                        {elseif $item.estado == 'sorteado'}
                            {if $item.hubo_ganador_jackpot}
                                <span class="astrolot_hist_badge jackpot">🏆 Jackpot Ganado</span>
                            {else}
                                <span class="astrolot_hist_badge rollover">🔄 Rollover</span>
                            {/if}
                        {else}
                            <span class="astrolot_hist_badge sorteado">{$item.estado|upper}</span>
                        {/if}
                    </div>

                    {if $item.estado == 'sorteado' && $item.numeros_sorteados_arr}
                        <div class="astrolot_hist_nums">
                            {foreach from=$item.numeros_sorteados_arr item=num}
                                <span class="astrolot_hist_num">{$num}</span>
                            {/foreach}
                        </div>
                    {/if}

                    <div class="astrolot_hist_info">
                        <div>
                            💰 Jackpot: <b>{$item.jackpot_display|default:0|number_format:0:',,':'.'} {$item.moneda_label|default:$moneda}</b>
                            · 🎟️ Tickets: <b>{$item.tickets_vendidos}</b>
                            · 📅 {$item.fecha_inicio|date_format:"%d/%m/%Y"}
                        </div>

                        {if $item.estado == 'sorteado'}
                            <div>
                                {if $item.hubo_ganador_jackpot}
                                    🏆 <span class="gold">Ganador del Jackpot: User #{$item.ganador_jackpot_id}</span>
                                {else}
                                    🔄 <span class="warn">Sin ganador — acumulado al próximo sorteo.</span>
                                {/if}
                            </div>
                        {elseif $item.estado == 'abierto'}
                            <div class="grey">⏳ En curso</div>
                        {/if}
                    </div>
                </div>
            {/foreach}
        {else}
            <div class="astrolot_empty">
                📜 No hay sorteos en el historial todavía.
            </div>
        {/if}
    </div>

</div>

{/block}