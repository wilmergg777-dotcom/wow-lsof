{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.info.tpl === *}
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
   AstroIO v3.0 — Alianza · Info (externa)
   Prefijo: .astroali_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Headers con gradiente púrpura
     - Bloques de descripción/diplomacia con glassmorphism
     - Wrapper padding 15px
     - IDs, href, Smarty y clases funcionales intactos
     - 🆕 v3.1: Indicador visual "LLENA" cuando la alianza llega al límite de 7 miembros.
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

.astroali_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroali_panel {
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

.astroali_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroali_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
}

.astroali_table tr > td,
.astroali_table tr > th {
    padding: 4px 8px;
    vertical-align: top;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
}

.astroali_table tr > td:first-child {
    width: 30%;
    color: var(--text-muted);
}

.astroali_table tr > td:last-child {
    width: 70%;
}

.astroali_table tr > th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    font-weight: normal;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-align: left;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroali_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Imagen de la alianza */
.astroali_img {
    display: block;
    margin: 0 auto;
    max-width: 100%;
    max-height: 220px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    object-fit: contain;
}

/* Descripción */
.astroali_desc {
    min-height: 100px;
    padding: 10px 12px;
    background: rgba(139, 92, 246, 0.04);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(139, 92, 246, 0.15);
    border-radius: 10px;
    color: var(--text-main);
    line-height: 1.5;
    white-space: pre-wrap;
    word-wrap: break-word;
    transition: 0.2s ease;
}
.astroali_desc:hover {
    border-color: rgba(139, 92, 246, 0.3);
}

/* Enlaces */
.astroali_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroali_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* Bloque de diplomacia */
.astroali_diplo {
    padding: 8px 10px;
    line-height: 1.7;
    color: var(--text-main);
}
.astroali_diplo b u {
    color: var(--accent-cyan);
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-decoration: none;
    border-bottom: 1px solid rgba(0, 204, 255, 0.5);
    padding-bottom: 1px;
}
.astroali_diplo br { line-height: 1.5; }

/* Bloque de estadísticas */
.astroali_stat_label { color: var(--text-muted); }
.astroali_stat_value { color: var(--accent-gold); font-weight: 500; }
.astroali_stat_pct   { color: var(--accent-green); font-size: 9.5px; }

@media (max-width: 720px) {
    .astroali_wrap { padding: 10px; }
    .astroali_panel { padding: 12px; }
    .astroali_table { font-size: 10px; }
    .astroali_table tr > td:first-child { width: 40%; }
    .astroali_table tr > td:last-child  { width: 60%; }
    .astroali_img { max-height: 150px; }
}
</style>

<div class="astroali_wrap">
<div class="astroali_panel">

    <div class="astroali_title">{$LNG.al_ally_information}</div>

    <table class="astroali_table">
        {if $ally_image}
        <tr>
            <td colspan="2" style="text-align:center; padding:8px;">
                <img class="astroali_img" src="{$ally_image}" alt="{$ally_tag}">
            </td>
        </tr>
        {/if}
        <tr>
            <td>{$LNG.al_ally_info_tag}</td>
            <td>{$ally_tag}</td>
        </tr>
        <tr>
            <td>{$LNG.al_ally_info_name}</td>
            <td>{$ally_name}</td>
        </tr>
        <tr>
            <td>{$LNG.al_ally_info_members}</td>
            <td>
                {$ally_member_scount} / {$ally_max_members}
                {if $ally_member_scount >= $ally_max_members}
                    <span style="color: #ef4444; font-weight: 800; margin-left: 6px; text-shadow: 0 0 5px rgba(239, 68, 68, 0.5);">(LLENA)</span>
                {/if}
            </td>
        </tr>
        {if $ally_request}
        <tr>
            <td>{$LNG.al_request}</td>
            {if $ally_request_min_points}
            <td><a href="game.php?page=alliance&amp;mode=apply&amp;id={$ally_id}">{$LNG.al_click_to_send_request}</a></td>
            {else}
            <td>{$ally_request_min_points_info}</td>
            {/if}
        </tr>
        {/if}
        <tr>
            <td colspan="2" style="padding:8px;">
                <div class="astroali_desc">{if !empty($ally_description)}{$ally_description}{else}{$LNG.al_description_message}{/if}</div>
            </td>
        </tr>
        {if $ally_web}
        <tr>
            <td>{$LNG.al_web_text}</td>
            <td><a href="{$ally_web}">{$ally_web}</a></td>
        </tr>
        {/if}
        {if $diplomaticData}
        <tr>
            <th colspan="2">{$LNG.al_diplo}</th>
        </tr>
        <tr>
            <td colspan="2">
                <div class="astroali_diplo">
                {if $diplomaticData}
                {if !empty($diplomaticData.0)}<b><u>{$LNG.al_diplo_level.0}</u></b><br><br>{foreach item=PaktInfo from=$diplomaticData.0}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($diplomaticData.1)}<b><u>{$LNG.al_diplo_level.1}</u></b><br><br>{foreach item=PaktInfo from=$diplomaticData.1}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($diplomaticData.2)}<b><u>{$LNG.al_diplo_level.2}</u></b><br><br>{foreach item=PaktInfo from=$diplomaticData.2}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($diplomaticData.3)}<b><u>{$LNG.al_diplo_level.3}</u></b><br><br>{foreach item=PaktInfo from=$diplomaticData.3}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($diplomaticData.4)}<b><u>{$LNG.al_diplo_level.4}</u></b><br><br>{foreach item=PaktInfo from=$diplomaticData.4}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {else}
                    {$LNG.al_no_diplo}
                {/if}
                </div>
            </td>
        </tr>
        {/if}
        {if !empty($statisticData)}
        <tr>
            <th colspan="2">{$LNG.pl_fightstats}</th>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_totalfight}</td>
            <td class="astroali_stat_value">{$statisticData.totalfight|number}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_fightwon}</td>
            <td><span class="astroali_stat_value">{$statisticData.fightwon|number}</span>{if $statisticData.totalfight} <span class="astroali_stat_pct">({round($statisticData.fightwon / $statisticData.totalfight * 100, 2)}%)</span>{/if}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_fightlose}</td>
            <td><span class="astroali_stat_value">{$statisticData.fightlose|number}</span>{if $statisticData.totalfight} <span class="astroali_stat_pct">({round($statisticData.fightlose / $statisticData.totalfight * 100, 2)}%)</span>{/if}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_fightdraw}</td>
            <td><span class="astroali_stat_value">{$statisticData.fightdraw|number}</span>{if $statisticData.totalfight} <span class="astroali_stat_pct">({round($statisticData.fightdraw / $statisticData.totalfight * 100, 2)}%)</span>{/if}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_unitsshot}</td>
            <td class="astroali_stat_value">{$statisticData.unitsshot}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_unitslose}</td>
            <td class="astroali_stat_value">{$statisticData.unitslose}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_dermetal}</td>
            <td class="astroali_stat_value">{$statisticData.dermetal}</td>
        </tr>
        <tr>
            <td class="astroali_stat_label">{$LNG.pl_dercrystal}</td>
            <td class="astroali_stat_value">{$statisticData.dercrystal}</td>
        </tr>
        {/if}
    </table>

</div>
</div>

{/block}