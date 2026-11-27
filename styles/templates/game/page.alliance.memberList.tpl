{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.memberList.tpl === *}
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


{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Lista de Miembros (Jugador)
   Prefijo: .astroalml_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Headers de tabla con gradiente púrpura
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: id="memberList", class="tablesorter", headerSortUp/Down intactos
     - ⚠️ CRÍTICO: data-points, data-postion, onclick, Smarty intactos
     - 🆕 v3.1: Indicador de límite de 7 miembros alcanzado.
   ═══════════════════════════════════════════════ *}

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

.astroalml_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalml_panel {
    display: inline-block;
    text-align: left;
    width: 900px;
    max-width: 100%;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    font-size: 11px;
    color: var(--text-main);
}

.astroalml_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalml_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
    color: var(--text-main);
}

.astroalml_table thead th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 5px 6px;
    text-align: left;
    font-weight: normal;
    text-transform: uppercase;
    font-size: 9.5px;
    letter-spacing: 0.5px;
    cursor: pointer;
    user-select: none;
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroalml_table thead th:hover {
    background: linear-gradient(135deg, rgba(91, 33, 182, 0.95), rgba(124, 58, 237, 0.95));
    box-shadow: inset 0 0 12px rgba(170, 68, 255, 0.3);
}

.astroalml_table thead th.headerSortUp::after   { content: " ▲"; color: #00e0ff; font-size: 8px; }
.astroalml_table thead th.headerSortDown::after { content: " ▼"; color: #00e0ff; font-size: 8px; }

.astroalml_table tbody td {
    padding: 4px 6px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    height: 22px;
    vertical-align: middle;
    color: var(--text-main);
}

.astroalml_table tbody tr:hover {
    background: rgba(139, 92, 246, 0.06);
}
.astroalml_table tbody tr:nth-child(even) {
    background: rgba(255, 255, 255, 0.015);
}

/* Anchos fijos por columna (8 columnas) */
.astroalml_table thead th:nth-child(1) { width: 4%;  text-align: center; }
.astroalml_table thead th:nth-child(2) { width: 20%; }
.astroalml_table thead th:nth-child(3) { width: 5%;  text-align: center; }
.astroalml_table thead th:nth-child(4) { width: 18%; }
.astroalml_table thead th:nth-child(5) { width: 12%; text-align: right; }
.astroalml_table thead th:nth-child(6) { width: 13%; text-align: center; }
.astroalml_table thead th:nth-child(7) { width: 14%; text-align: center; }
.astroalml_table thead th:nth-child(8) { width: 14%; text-align: center; }

/* Enlaces */
.astroalml_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalml_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.6);
}

/* Enlace Playercard (columna 2) */
.astroalml_table td:nth-child(2) a {
    font-weight: 500;
}

/* Icono PM (Font Awesome) */
.astroalml_pm_icon {
    font-size: 14px;
    color: #00e0ff;
    transition: 0.25s ease;
    display: inline-block;
}
.astroalml_pm_icon:hover {
    transform: scale(1.15);
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.8);
}

/* Estados de conexión */
.astroalml_online  { color: #66ff99; font-weight: 500; text-shadow: 0 0 6px rgba(102, 255, 153, 0.35); }
.astroalml_away    { color: #ffaa33; }
.astroalml_offline { color: #ff4488; }

/* Fila final (link "Volver") */
.astroalml_table tr > th[colspan="8"] {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-top: 1px solid var(--accent-cyan);
    border-bottom: none;
    text-align: center;
    padding: 8px 10px;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astroalml_table tr > th[colspan="8"] a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalml_table tr > th[colspan="8"] a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

@media (max-width: 720px) {
    .astroalml_wrap { padding: 10px; }
    .astroalml_panel { padding: 12px; }
    .astroalml_table { font-size: 9.5px; }
    .astroalml_table thead th:nth-child(3),
    .astroalml_table thead th:nth-child(7) { display: none; }
}
</style>

<div class="astroalml_wrap">
<div class="astroalml_panel">

    <div class="astroalml_title">
        {$al_users_list}
        {if $memberList|@count >= $smarty.const.MAX_ALLIANCE_MEMBERS}
            <span style="color: #ef4444; font-size: 10px; margin-left: 8px; font-weight: bold; text-shadow: 0 0 5px rgba(239, 68, 68, 0.5);">(LÍMITE ALCANZADO)</span>
        {/if}
    </div>

    <table id="memberList" class="tablesorter astroalml_table">
        <thead>
            <tr>
                <th>{$LNG.al_num}</th>
                <th>{$LNG.al_member}</th>
                <th>{$LNG.al_message}</th>
                <th>{$LNG.al_position}</th>
                <th>{$LNG.al_points}</th>
                <th>{$LNG.al_coords}</th>
                <th>{$LNG.al_member_since}</th>
                <th>{$LNG.al_estate}</th>
            </tr>
        </thead>
        <tbody>
        {foreach $memberList as $userID => $memberListRow}
        <tr>
            <td style="text-align:center;">{$memberListRow@iteration}</td>
            <td><a href="#" onclick="return Dialog.Playercard({$userID}, '{$memberListRow.username}');">{$memberListRow.username}</a></td>
            <td style="text-align:center;">
                <a href="#" onclick="return Dialog.PM({$userID});">
                    <i class="far fa-envelope astroalml_pm_icon" title="{$LNG.write_message}"></i>
                </a>
            </td>
            <td>{$memberListRow.rankName}</td>
            <td data-points="{$memberListRow.points}" style="text-align:right;">{$memberListRow.points|number}</td>
            <td style="text-align:center;"><a href="game.php?page=galaxy&amp;galaxy={$memberListRow.galaxy}&amp;system={$memberListRow.system}" data-postion="{$memberListRow.galaxy}:{$memberListRow.system}:{$memberListRow.planet}">[{$memberListRow.galaxy}:{$memberListRow.system}:{$memberListRow.planet}]</a></td>
            <td style="text-align:center;">{$memberListRow.register_time}</td>
            <td style="text-align:center;">{if $rights.ONLINESTATE}{if $memberListRow.onlinetime < 4}<span class="astroalml_online">{$LNG.al_memberlist_on}</span>{elseif $memberListRow.onlinetime <= 15}<span class="astroalml_away">{$memberListRow.onlinetime} {$LNG.al_memberlist_min}</span>{else}<span class="astroalml_offline">{$LNG.al_memberlist_off}</span>{/if}{else}-{/if}</td>
        </tr>
        {/foreach}
        </tbody>
        <tr>
            <th colspan="8"><a href="game.php?page=alliance">{$LNG.al_back}</a></th>
        </tr>
    </table>

</div>
</div>

{/block}
{block name="script" append}
<script src="scripts/base/jquery.tablesorter.js"></script>
<script>$(function() {
    $("#memberList").tablesorter({
		headers: { 
			0: { sorter: false } ,
			3: { sorter: false } 
		},
		debug: false
	}); 
});</script>
{/block}