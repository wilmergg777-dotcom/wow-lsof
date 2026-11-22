{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Admin · Miembros
   Prefijo: .astroalm_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tabla con header púrpura + hover
     - Selects con radius 8px + focus translateY
     - ⚠️ CRÍTICO: id="memberList", class="tablesorter", headerSortUp/Down intactos
     - ⚠️ CRÍTICO: AJAX .rankSelect + NotifyBox intactos
     - ⚠️ CRÍTICO: onclick Playercard/PM/kick + confirm + shortly_number + html_options intactos
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

.astroalm_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalm_panel {
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

.astroalm_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalm_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
    color: var(--text-main);
}

.astroalm_table thead th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 5px 6px;
    text-align: left;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 9.5px;
    letter-spacing: 0.5px;
    cursor: pointer;
    user-select: none;
    transition: 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroalm_table thead th:hover {
    background: linear-gradient(135deg, rgba(91, 33, 182, 0.95), rgba(124, 58, 237, 0.95));
    box-shadow: inset 0 0 12px rgba(170, 68, 255, 0.3);
}

.astroalm_table thead th.headerSortUp::after   { content: " ▲"; color: #00e0ff; font-size: 8px; }
.astroalm_table thead th.headerSortDown::after { content: " ▼"; color: #00e0ff; font-size: 8px; }

.astroalm_table tbody td {
    padding: 5px 6px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    height: 22px;
    vertical-align: middle;
    color: var(--text-main);
}

.astroalm_table tbody tr:hover {
    background: rgba(139, 92, 246, 0.06);
}
.astroalm_table tbody tr:nth-child(even) {
    background: rgba(255, 255, 255, 0.015);
}

/* Anchos fijos por columna (9 columnas, orden crítico para tablesorter) */
.astroalm_table thead th:nth-child(1) { width: 4%;  text-align: center; }
.astroalm_table thead th:nth-child(2) { width: 16%; }
.astroalm_table thead th:nth-child(3) { width: 5%;  text-align: center; }
.astroalm_table thead th:nth-child(4) { width: 18%; }
.astroalm_table thead th:nth-child(5) { width: 10%; text-align: right; }
.astroalm_table thead th:nth-child(6) { width: 12%; text-align: center; }
.astroalm_table thead th:nth-child(7) { width: 11%; text-align: center; }
.astroalm_table thead th:nth-child(8) { width: 12%; text-align: center; }
.astroalm_table thead th:nth-child(9) { width: 8%;  text-align: center; }

/* Enlaces dentro de la tabla */
.astroalm_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalm_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.6);
}

/* Enlace de miembro (Playercard) */
.astroalm_table td:nth-child(2) a { font-weight: 500; }

/* Icono PM (Font Awesome) */
.astroalm_pm_icon {
    font-size: 14px;
    color: #00e0ff;
    transition: 0.25s ease;
    display: inline-block;
}
.astroalm_pm_icon:hover {
    transform: scale(1.15);
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.8);
}

/* Selector de rango (html_options genera <select class="rankSelect">) */
.astroalm_table select.rankSelect {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 4px 6px;
    font-size: 10.5px;
    font-family: inherit;
    font-weight: 700;
    width: 100%;
    max-width: 150px;
    transition: 0.25s ease;
    outline: none;
    cursor: pointer;
}
.astroalm_table select.rankSelect:hover,
.astroalm_table select.rankSelect:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astroalm_table select.rankSelect option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}

/* Estados de conexión */
.astroalm_online  { color: #66ff99; font-weight: 500; text-shadow: 0 0 6px rgba(102, 255, 153, 0.35); }
.astroalm_away    { color: #ffaa33; }
.astroalm_offline { color: #ff4488; }

/* Botón kick */
.astroalm_kick {
    display: inline-block;
    width: 20px;
    height: 20px;
    line-height: 18px;
    text-align: center;
    border: 1px solid #ff4488;
    border-radius: 6px;
    background: rgba(255, 68, 136, 0.1);
    vertical-align: middle;
    transition: 0.25s ease;
}
.astroalm_kick:hover {
    background: rgba(255, 68, 136, 0.25);
    box-shadow: 0 0 10px rgba(255, 68, 136, 0.5);
    text-shadow: none;
    transform: translateY(-1px);
}
.astroalm_kick img { vertical-align: middle; }

/* Fila final (link "Volver") */
.astroalm_table tr > th[colspan="9"] {
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
.astroalm_table tr > th[colspan="9"] a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalm_table tr > th[colspan="9"] a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

/* Responsive */
@media (max-width: 720px) {
    .astroalm_wrap { padding: 10px; }
    .astroalm_panel { padding: 12px; }
    .astroalm_table { font-size: 9.5px; }
    .astroalm_table thead th:nth-child(3),
    .astroalm_table thead th:nth-child(7) { display: none; }
}
</style>

<div class="astroalm_wrap">
<div class="astroalm_panel">

    <div class="astroalm_title">{$al_users_list}</div>

    <form action="game.php?page=alliance&amp;mode=admin&amp;action=membersSave" method="post">
        <table id="memberList" class="tablesorter astroalm_table">
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
                <th>{$LNG.al_actions}</th>
            </tr>
            </thead>
            <tbody>
            {foreach $memberList as $userID => $memberListRow}
                <tr>
                    <td style="text-align:center;">{$memberListRow@iteration}</td>
                    <td><a href="#" onclick="return Dialog.Playercard({$userID},'{$memberListRow.username}');">{$memberListRow.username}</a></td>
                    <td style="text-align:center;">
                        <a href="#" onclick="return Dialog.PM({$userID});">
                            <i class="far fa-envelope astroalm_pm_icon" title="{$LNG.write_message}"></i>
                        </a>
                    </td>
                    <td>{if $memberListRow.rankID == -1}{$founder}{elseif !empty($rankSelectList)}{html_options class="rankSelect" name="rank[{$userID}]" options=$rankSelectList selected=$memberListRow.rankID}{else}{$rankList[$memberListRow.rankID]}{/if}</td>
                    <td style="text-align:right;"><span title="{$memberListRow.points|number}">{shortly_number($memberListRow.points)}</span></td>
                    <td style="text-align:center;"><a href="game.php?page=galaxy&amp;galaxy={$memberListRow.galaxy}&amp;system={$memberListRow.system}">[{$memberListRow.galaxy}:{$memberListRow.system}:{$memberListRow.planet}]</a></td>
                    <td style="text-align:center;">{$memberListRow.register_time}</td>
                    <td style="text-align:center;">{if $rights.ONLINESTATE}{if $memberListRow.onlinetime < 4}<span class="astroalm_online">{$LNG.al_memberlist_on}</span>{elseif $memberListRow.onlinetime >= 4 && $memberListRow.onlinetime <= 15}<span class="astroalm_away">{$memberListRow.onlinetime} {$LNG.al_memberlist_min}</span>{else}<span class="astroalm_offline">{$LNG.al_memberlist_off}</span>{/if}{else}-{/if}</td>
                    <td style="text-align:center;">{if $memberListRow.rankID != -1}
                            {if $canKick}<a class="astroalm_kick" href="game.php?page=alliance&amp;mode=admin&amp;action=membersKick&amp;id={$userID}" onclick="return confirm('{$memberListRow.kickQuestion}');"><img src="{$dpath}pic/abort.gif" border="0" alt=""></a>{/if}{else}-{/if}
                    </td>
                </tr>
            {/foreach}
            </tbody>
            <tr>
                <th colspan="9"><a href="game.php?page=alliance&amp;mode=admin">{$LNG.al_back}</a></th>
            </tr>
        </table>
    </form>

</div>
</div>

{/block}
{block name="script" append}
    <script src="scripts/base/jquery.tablesorter.js"></script>
    <script>$(function() {
            $("#memberList").tablesorter({
                headers: {
                    0: { sorter: false } ,
                    3: { sorter: false } ,
                    9: { sorter: false }
                },
                debug: false
            });

            $('.rankSelect').on('change', function () {
                $.post('game.php?page=alliance&mode=admin&action=rank&ajax=1', $(this).serialize(), function (data) {
                    NotifyBox(data);
                }, 'json');
            });
        });
    </script>
{/block}