{* ============================================ *}
{* ⚔️ TAB: HISTORIAL DE BATALLAS               *}
{* ============================================ *}

<div class="astrowar_section">📜 Historial de Batallas</div>

{if $war_history|@count > 0}

    <div class="astrowar_hist_list">

        {foreach $war_history as $h}
            <div class="astrowar_hist_card astrowar_hist-{$h.mi_resultado}">

                {* --- Cabecera: resultado + clima --- *}
                <div class="astrowar_hist_head">
                    {if $h.mi_resultado == 'victoria'}
                        <span class="astrowar_hist_badge astrowar_hist_badge-win">🏆 VICTORIA</span>
                    {elseif $h.mi_resultado == 'derrota'}
                        <span class="astrowar_hist_badge astrowar_hist_badge-lose">💔 DERROTA</span>
                    {elseif $h.mi_resultado == 'empate'}
                        <span class="astrowar_hist_badge astrowar_hist_badge-tie">🤝 EMPATE</span>
                    {else}
                        <span class="astrowar_hist_badge astrowar_hist_badge-cancel">⛔ CANCELADA</span>
                    {/if}

                    {if $h.clima_nombre}
                        <span class="astrowar_hist_clima">🌦️ {$h.clima_nombre}</span>
                    {/if}
                </div>

                {* --- Enfrentamiento --- *}
                <div class="astrowar_hist_match">
                    {if $h.es_atacante}
                        🏰 <b>{$h.atacante_nombre}</b> <span class="astrowar_hist_arrow">vs</span> 🏰 {$h.defensor_nombre}
                    {else}
                        🏰 {$h.atacante_nombre} <span class="astrowar_hist_arrow">vs</span> 🏰 <b>{$h.defensor_nombre}</b>
                    {/if}
                    <span class="astrowar_hist_mi">({if $h.es_atacante}atacante{else}defensor{/if})</span>
                </div>

                {* --- Fecha --- *}
                <div class="astrowar_hist_date">
                    📅 Inicio: <b>{$h.inicio|date_format:"%d/%m/%Y %H:%M"}</b>
                    &nbsp;·&nbsp;
                    Fin: <b>{$h.fin|date_format:"%d/%m/%Y %H:%M"}</b>
                </div>

                {* --- Botón ver informe --- *}
                <div class="astrowar_hist_action">
                    <a href="game.php?page=war&amp;mode=report&amp;id={$h.id}"
                       class="astrowar_btn astrowar_btn-view">
                        📋 VER INFORME DETALLADO
                    </a>
                </div>

            </div>
        {/foreach}

    </div>

    <div style="text-align:center;font-size:10px;color:#8899aa;margin-top:10px;">
        Mostrando las últimas {$war_history|@count} batallas de tu alianza.
    </div>

{else}

    <div class="astrowar_empty">
        📭 Tu alianza no tiene batallas registradas todavía.
        <br><br>
        Cuando tu alianza participe en una guerra, aparecerá aquí.
    </div>

{/if}

<style>
.astrowar_hist_list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    margin-top: 8px;
}
.astrowar_hist_card {
    padding: 12px 14px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-left: 4px solid #556677;
    border-radius: 8px;
    transition: 0.2s ease;
}
.astrowar_hist_card:hover {
    border-color: rgba(0, 224, 255, 0.4);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.15);
    transform: translateX(2px);
}
.astrowar_hist-victoria  { border-left-color: #00ff88; }
.astrowar_hist-derrota   { border-left-color: #ff4488; }
.astrowar_hist-empate    { border-left-color: #ffaa33; }
.astrowar_hist-cancelada { border-left-color: #556677; opacity: 0.7; }

.astrowar_hist_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
    flex-wrap: wrap;
    gap: 6px;
}

.astrowar_hist_badge {
    padding: 3px 10px;
    border-radius: 5px;
    font-size: 10px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrowar_hist_badge-win    { background: linear-gradient(135deg, #008844, #00cc66); color: #fff; }
.astrowar_hist_badge-lose   { background: linear-gradient(135deg, #aa0044, #ff4488); color: #fff; }
.astrowar_hist_badge-tie    { background: linear-gradient(135deg, #aa8800, #ffaa33); color: #221800; }
.astrowar_hist_badge-cancel { background: #333a44; color: #8899aa; }

.astrowar_hist_clima {
    font-size: 10px;
    color: #c088ff;
    background: rgba(170, 68, 255, 0.1);
    padding: 2px 8px;
    border-radius: 4px;
    border: 1px solid rgba(170, 68, 255, 0.3);
}

.astrowar_hist_match {
    font-size: 12px;
    color: #c8d6e5;
    padding: 6px 0;
    margin-bottom: 4px;
}
.astrowar_hist_match b { color: #00e0ff; }
.astrowar_hist_arrow {
    color: #ff4488;
    font-weight: 700;
    margin: 0 4px;
    font-size: 11px;
}
.astrowar_hist_mi {
    color: #8899aa;
    font-size: 10px;
    font-style: italic;
    margin-left: 6px;
}

.astrowar_hist_date {
    font-size: 10.5px;
    color: #8899aa;
    margin-bottom: 8px;
}
.astrowar_hist_date b { color: #c8d6e5; }

.astrowar_hist_action {
    text-align: right;
    padding-top: 6px;
    border-top: 1px solid rgba(0, 224, 255, 0.08);
}

.astrowar_btn-view {
    background: linear-gradient(180deg, #004488, #0066cc) !important;
    padding: 6px 14px !important;
    font-size: 10.5px !important;
}
.astrowar_btn-view:hover {
    background: linear-gradient(180deg, #0066cc, #0099ff) !important;
    box-shadow: 0 0 14px rgba(0, 150, 255, 0.5) !important;
}
</style>