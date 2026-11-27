{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.war.ranking.tpl === *}
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
{* ⚔️ TAB: RANKING COMPLETO                    *}
{* ============================================ *}

<div class="astrowar_section">🌍 Ranking de Guerra WAR</div>

{* ============================================ *}
{* FILTROS                                       *}
{* ============================================ *}
<div class="astrowar_rank_filters">
    <a href="game.php?page=war&amp;tab=ranking&amp;filter=global"
       class="astrowar_rank_filter {if $war_rank_filter == 'global'}active{/if}">
        🌍 Global
    </a>
    <a href="game.php?page=war&amp;tab=ranking&amp;filter=ally"
       class="astrowar_rank_filter {if $war_rank_filter == 'ally'}active{/if}">
        🏰 Mi Alianza
    </a>
</div>

{* ============================================ *}
{* INFO TOTAL                                    *}
{* ============================================ *}
<div class="astrowar_rank_info">
    {if $war_rank_filter == 'global'}
        Mostrando <b>{$war_rank_total}</b> jugadores con puntos WAR.
    {else}
        Mostrando <b>{$war_rank_total}</b> jugadores de tu alianza.
    {/if}
    {if $war_rank_pages > 1}
        &nbsp;·&nbsp;
        Página <b>{$war_rank_page}</b> de <b>{$war_rank_pages}</b>
    {/if}
</div>

{* ============================================ *}
{* TABLA                                         *}
{* ============================================ *}
{if $war_rank_total > 0}

    <table class="astrowar_table astrowar_rank_table">
        <thead>
            <tr>
                <th style="width:50px;">#</th>
                <th>Jugador</th>
                <th style="width:200px;">Alianza</th>
                <th style="width:100px;">Puntos WAR</th>
            </tr>
        </thead>
        <tbody>
            {foreach $war_full_ranking as $r}
                <tr class="{if $r.es_mi_alianza}astrowar_rank_mine{/if} {if $r.pos <= 3}astrowar_rank_top{/if}">
                    <td>
                        {if $r.pos == 1}
                            <span class="rank-1">🥇 1</span>
                        {elseif $r.pos == 2}
                            <span class="rank-2">🥈 2</span>
                        {elseif $r.pos == 3}
                            <span class="rank-3">🥉 3</span>
                        {else}
                            {$r.pos}
                        {/if}
                    </td>
                    <td>
                        {if $r.es_mi_alianza}
                            <b style="color:#00e0ff;">{$r.username}</b>
                        {else}
                            {$r.username}
                        {/if}
                    </td>
                    <td>
                        {if $r.alliance_name}
                            {if $r.ally_tag}
                                <span style="color:#8899aa;">[{$r.ally_tag}]</span>
                            {/if}
                            {$r.alliance_name}
                        {else}
                            <i style="color:#667;">Sin alianza</i>
                        {/if}
                    </td>
                    <td>
                        <b style="color:#ffaa33;font-size:12px;">{$r.puntos}</b>
                    </td>
                </tr>
            {/foreach}
        </tbody>
    </table>

    {* ============================================ *}
    {* PAGINACIÓN                                    *}
    {* ============================================ *}
    {if $war_rank_pages > 1}
        <div class="astrowar_rank_pagination">

            {* Botón anterior *}
            {if $war_rank_page > 1}
                <a href="game.php?page=war&amp;tab=ranking&amp;filter={$war_rank_filter}&amp;p={$war_rank_page-1}"
                   class="astrowar_rank_page_btn">
                    « Anterior
                </a>
            {else}
                <span class="astrowar_rank_page_btn disabled">« Anterior</span>
            {/if}

            {* Números *}
            {foreach $war_rank_pagination as $p}
                {if $p === '...'}
                    <span class="astrowar_rank_page_dots">...</span>
                {else}
                    <a href="game.php?page=war&amp;tab=ranking&amp;filter={$war_rank_filter}&amp;p={$p}"
                       class="astrowar_rank_page_btn {if $p == $war_rank_page}active{/if}">
                        {$p}
                    </a>
                {/if}
            {/foreach}

            {* Botón siguiente *}
            {if $war_rank_page < $war_rank_pages}
                <a href="game.php?page=war&amp;tab=ranking&amp;filter={$war_rank_filter}&amp;p={$war_rank_page+1}"
                   class="astrowar_rank_page_btn">
                    Siguiente »
                </a>
            {else}
                <span class="astrowar_rank_page_btn disabled">Siguiente »</span>
            {/if}

        </div>
    {/if}

{else}

    <div class="astrowar_empty">
        📭 Todavía no hay jugadores con puntos WAR.
        <br><br>
        Los puntos se otorgan al finalizar las batallas.
    </div>

{/if}

<style>
/* ============================================
   RANKING
   ============================================ */

.astrowar_rank_filters {
    display: flex;
    gap: 6px;
    margin: 8px 0;
    justify-content: center;
}
.astrowar_rank_filter {
    display: inline-block;
    padding: 6px 16px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 6px;
    color: #c8d6e5;
    text-decoration: none;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    transition: 0.2s ease;
}
.astrowar_rank_filter:hover {
    color: #00e0ff;
    border-color: rgba(0, 224, 255, 0.5);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}
.astrowar_rank_filter.active {
    background: linear-gradient(180deg, #7700cc, #aa44ff);
    color: #fff;
    border-color: #aa44ff;
    box-shadow: 0 0 14px rgba(170, 68, 255, 0.45);
}

.astrowar_rank_info {
    padding: 6px 10px;
    margin: 10px 0;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 6px;
    font-size: 10.5px;
    color: #8899aa;
    text-align: center;
}
.astrowar_rank_info b { color: #00e0ff; }

/* ============ TABLA ============ */
.astrowar_rank_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    margin-top: 8px;
}
.astrowar_rank_table th {
    background: linear-gradient(180deg, #004488, #0077cc);
    color: #fff;
    padding: 6px;
    text-align: left;
    border-bottom: 1px solid #00ccff;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowar_rank_table td {
    padding: 6px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08);
    color: #c8d6e5;
}
.astrowar_rank_table tr:hover td {
    background: rgba(0, 224, 255, 0.08);
}

.astrowar_rank_table tr.astrowar_rank_top td {
    background: rgba(255, 170, 51, 0.04);
}

.astrowar_rank_table tr.astrowar_rank_mine td {
    background: rgba(0, 224, 255, 0.08);
    border-left: 3px solid #00e0ff;
}

.astrowar_rank_table .rank-1 { color: #ffdd44; font-weight: 700; }
.astrowar_rank_table .rank-2 { color: #ccddff; font-weight: 700; }
.astrowar_rank_table .rank-3 { color: #dd9955; font-weight: 700; }

/* ============ PAGINACIÓN ============ */
.astrowar_rank_pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 4px;
    margin-top: 14px;
    padding: 8px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 6px;
    flex-wrap: wrap;
}
.astrowar_rank_page_btn {
    display: inline-block;
    padding: 6px 12px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 5px;
    color: #66ccff;
    text-decoration: none;
    font-size: 11px;
    font-weight: 700;
    transition: 0.2s ease;
    min-width: 34px;
    text-align: center;
}
.astrowar_rank_page_btn:hover {
    color: #00e0ff;
    border-color: #00ccff;
    background: linear-gradient(180deg, #0066cc, #0099ff);
    color: #fff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}
.astrowar_rank_page_btn.active {
    background: linear-gradient(180deg, #7700cc, #aa44ff);
    color: #fff;
    border-color: #aa44ff;
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.5);
}
.astrowar_rank_page_btn.disabled {
    opacity: 0.35;
    cursor: not-allowed;
    color: #556677;
}
.astrowar_rank_page_dots {
    color: #556677;
    padding: 0 4px;
    font-weight: 700;
}
</style>