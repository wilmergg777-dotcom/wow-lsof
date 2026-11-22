{block name="content"}

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