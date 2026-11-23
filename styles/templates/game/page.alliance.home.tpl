{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.home.tpl === *}
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
   AstroIO v3.0 — Alianza · Home (panel principal)
   Prefijo: .astroalh_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-secciones 10px)
     - Sub-secciones con borde cyan sutil + hover
     - Botones existentes con radius 8px + hover translateY
     - Wrapper padding 15px
     - IDs, names, Smarty, clases funcionales intactos
     - 🆕 v3.1: Límite de miembros fijo a 7 e indicador visual de "LLENA".
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

/* ====== Wrapper ====== */
.astroalh_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astroalh_panel {
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

/* ====== Título ====== */
.astroalh_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

/* ====== Tabla ====== */
.astroalh_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
}

.astroalh_table tr > td,
.astroalh_table tr > th {
    padding: 4px 8px;
    vertical-align: top;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
}

.astroalh_table tr > td:first-child {
    width: 35%;
    color: var(--text-muted);
}

.astroalh_table tr > td:last-child {
    width: 65%;
}

.astroalh_table tr > th {
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

.astroalh_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Imagen de la alianza */
.astroalh_img {
    display: block;
    margin: 0 auto;
    max-width: 100%;
    max-height: 220px;
    border: 1px solid var(--border-color);
    border-radius: 8px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    object-fit: contain;
}

/* Descripción / texto interno con bbcode */
.astroalh_bbcode {
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
.astroalh_bbcode:hover {
    border-color: rgba(139, 92, 246, 0.3);
}

/* Enlaces */
.astroalh_table a {
    color: var(--accent-cyan);
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalh_table a:hover {
    color: var(--text-title);
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* Fila de evento (flotas con countdown) */
.astroalh_table tr > td.fleets {
    color: var(--accent-gold);
    font-family: 'Courier New', monospace;
    font-size: 10.5px;
    white-space: nowrap;
}

/* Bloque diplomacia */
.astroalh_diplo {
    padding: 8px 10px;
    line-height: 1.7;
    color: var(--text-main);
}
.astroalh_diplo b u {
    color: var(--accent-cyan);
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-decoration: none;
    border-bottom: 1px solid rgba(0, 204, 255, 0.5);
    padding-bottom: 1px;
}

/* Estadísticas */
.astroalh_stat_label { color: var(--text-muted); }
.astroalh_stat_value { color: var(--accent-gold); font-weight: 500; }
.astroalh_stat_pct   { color: var(--accent-green); font-size: 9.5px; }

/* Bloque "abandonar alianza" */
.astroalh_leave_table {
    margin-top: 14px;
}

.astroalh_leave_table tr > th {
    background: linear-gradient(135deg, rgba(102, 17, 34, 0.9), rgba(170, 34, 68, 0.9));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-red);
    color: #ffffff;
    font-weight: normal;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    padding: 4px 8px;
    text-align: left;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroalh_leave_table tr > td {
    padding: 8px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
}

.astroalh_leave_btn {
    display: inline-block;
    padding: 6px 20px;
    background: linear-gradient(135deg, rgba(204, 34, 68, 0.9), rgba(255, 68, 136, 0.9));
    color: #ffffff;
    border: 1px solid #ff4488;
    border-radius: 8px;
    font-size: 10.5px;
    cursor: pointer;
    text-decoration: none;
    transition: 0.25s ease;
    font-family: inherit;
}
.astroalh_leave_btn:hover {
    background: linear-gradient(135deg, rgba(255, 68, 136, 0.95), rgba(255, 100, 150, 0.95));
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.6);
    transform: translateY(-2px);
}
.astroalh_leave_btn:active {
    transform: translateY(0);
}

/* ====== Botón del Banco de Alianza ====== */
.astroalh_bank_btn {
    display: inline-block;
    padding: 9px 24px;
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.9), rgba(119, 0, 204, 0.9));
    color: #ffffff !important;
    border: 1px solid #bb66ff;
    border-radius: 8px;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none !important;
    transition: 0.25s ease;
    box-shadow: 0 4px 14px rgba(119, 0, 204, 0.35);
}
.astroalh_bank_btn:hover {
    background: linear-gradient(135deg, rgba(187, 102, 255, 0.95), rgba(136, 0, 221, 0.95));
    box-shadow: 0 0 18px rgba(170, 68, 255, 0.7);
    color: #ffffff !important;
    transform: translateY(-2px);
    text-shadow: none !important;
}
.astroalh_bank_btn:active {
    transform: translateY(0);
}

/* ====== Botón del Árbol de Talentos ====== */
.astroalh_talent_btn {
    display: inline-block;
    padding: 9px 24px;
    background: linear-gradient(135deg, rgba(34, 204, 102, 0.9), rgba(17, 136, 51, 0.9));
    color: #ffffff !important;
    border: 1px solid #33dd77;
    border-radius: 8px;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none !important;
    transition: 0.25s ease;
    box-shadow: 0 4px 14px rgba(34, 204, 102, 0.35);
}
.astroalh_talent_btn:hover {
    background: linear-gradient(135deg, rgba(51, 221, 119, 0.95), rgba(17, 153, 68, 0.95));
    box-shadow: 0 0 18px rgba(34, 204, 102, 0.7);
    color: #ffffff !important;
    transform: translateY(-2px);
    text-shadow: none !important;
}
.astroalh_talent_btn:active {
    transform: translateY(0);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astroalh_wrap { padding: 10px; }
    .astroalh_panel { padding: 12px; }
    .astroalh_table { font-size: 10px; }
    .astroalh_table tr > td:first-child { width: 40%; }
    .astroalh_table tr > td:last-child  { width: 60%; }
    .astroalh_img { max-height: 150px; }
    .astroalh_bank_btn,
    .astroalh_talent_btn,
    .astroalh_leave_btn { width: 100%; text-align: center; box-sizing: border-box; }
}
</style>

<div class="astroalh_wrap">
<div class="astroalh_panel">

    <div class="astroalh_title">{$LNG.al_your_ally}</div>

    <table class="astroalh_table">
        {if $ally_image}
        <tr>
            <td colspan="2" style="text-align:center; padding:8px;">
                <img class="astroalh_img" src="{$ally_image}">
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
                {$ally_members} / {$ally_max_members}
                {if $ally_members >= $ally_max_members}
                    <span style="color: #ef4444; font-weight: 800; margin-left: 6px; text-shadow: 0 0 5px rgba(239, 68, 68, 0.5);">(LLENA)</span>
                {/if}
                {if $rights.MEMBERLIST} (<a href="?page=alliance&amp;mode=memberList">{$LNG.al_user_list}</a>){/if}
            </td>
        </tr>
        <tr>
            <td>{$LNG.al_rank}</td>
            <td>{$rankName}{if $rights.ADMIN} (<a href="?page=alliance&amp;mode=admin">{$LNG.al_manage_alliance}</a>){/if}</td>
        </tr>
        {if isModuleAvailable($smarty.const.MODULE_CHAT)}
        <tr>
            <td colspan="2"><a href="#" onclick="return Dialog.AllianceChat();">{$LNG.al_goto_chat}</a></td>
        </tr>
        {/if}

        {* NUEVO: Acceso al Banco de Alianza *}
        <tr>
            <th colspan="2">🏦 Banco de Alianza</th>
        </tr>
        <tr>
            <td colspan="2" style="text-align:center; padding:10px;">
                <a href="game.php?page=allianceBank" class="astroalh_bank_btn">
                    🏦 Abrir Banco de la Alianza
                </a>
                <div style="margin-top:6px; font-size:9.5px; color:#94a3b8;">
                    Deposita recursos y recibe bonuses para toda la alianza
                </div>
            </td>
        </tr>

        {* NUEVO: Acceso al Árbol de Talentos *}
        <tr>
            <th colspan="2">🌳 Árbol de Talentos</th>
        </tr>
        <tr>
            <td colspan="2" style="text-align:center; padding:10px;">
                <a href="game.php?page=allianceTalent" class="astroalh_talent_btn">
                    🌳 Abrir Árbol de Talentos
                </a>
                <div style="margin-top:6px; font-size:9.5px; color:#94a3b8;">
                    Elige 1 de 3 talentos por rango. Se sube con puntos de misiones de la alianza.
                </div>
            </td>
        </tr>

        {if $rights.SEEAPPLY && $applyCount > 0}
        <tr>
            <td>{$LNG.al_requests}</td>
            <td><a href="?page=alliance&amp;mode=admin&amp;action=mangeApply">{$requests}</a></td>
        </tr>
        {/if}
        {if $rights.ROUNDMAIL}
        <tr>
            <td>{$LNG.al_circular_message}</td>
            <td><a href="game.php?page=alliance&mode=circular" onclick="return Dialog.open(this.href, 650, 300);">{$LNG.al_send_circular_message}</a></td>
        </tr>
        {/if}
        {if $rights.EVENTS}
        <tr>
            <th colspan="2">{$LNG.al_events}</th>
        </tr>
        {if $ally_events}
            {foreach $ally_events as $member => $events}
            <tr>
                <td colspan="2">{$member}</td>
            </tr>
            {foreach $events as $index => $fleet}
            <tr>
                <td id="fleettime_{$index}" class="fleets" data-fleet-end-time="{$fleet.returntime}" data-fleet-time="{$fleet.resttime}">-</td>
                <td colspan="2">{$fleet.text}</td>
            </tr>
            {/foreach}
            {/foreach}
        {else}
            <tr>
                <td colspan="2">{$LNG.al_no_events}</td>
            </tr>
        {/if}
        {/if}
        <tr>
            <td colspan="2" class="bbcode astroalh_bbcode">{if $ally_description}{$ally_description}{else}{$LNG.al_description_message}{/if}</td>
        </tr>
        {if $ally_web}
        <tr>
            <td>{$LNG.al_web_text}</td>
            <td><a href="{$ally_web}">{$ally_web}</a></td>
        </tr>
        {/if}
        <tr>
            <th colspan="2">{$LNG.al_inside_section}</th>
        </tr>
        <tr>
            <td colspan="2" class="bbcode astroalh_bbcode">{$ally_text}</td>
        </tr>
        <tr>
            <th colspan="2">{$LNG.al_diplo}</th>
        </tr>
        <tr>
            <td colspan="2">
                <div class="astroalh_diplo">
                {if $DiploInfo}
                {if !empty($DiploInfo.0)}<b><u>{$LNG.al_diplo_level.0}</u></b><br><br>{foreach item=PaktInfo from=$DiploInfo.0}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($DiploInfo.1)}<b><u>{$LNG.al_diplo_level.1}</u></b><br><br>{foreach item=PaktInfo from=$DiploInfo.1}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($DiploInfo.2)}<b><u>{$LNG.al_diplo_level.2}</u></b><br><br>{foreach item=PaktInfo from=$DiploInfo.2}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($DiploInfo.3)}<b><u>{$LNG.al_diplo_level.3}</u></b><br><br>{foreach item=PaktInfo from=$DiploInfo.3}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {if !empty($DiploInfo.4)}<b><u>{$LNG.al_diplo_level.4}</u></b><br><br>{foreach item=PaktInfo from=$DiploInfo.4}<a href="?page=alliance&mode=info&amp;id={$PaktInfo.1}">{$PaktInfo.0}</a><br>{/foreach}<br>{/if}
                {else}
                    {$LNG.al_no_diplo}
                {/if}
                </div>
            </td>
        </tr>
        <tr>
            <th colspan="2">{$LNG.pl_fightstats}</th>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_totalfight}</td>
            <td class="astroalh_stat_value">{$totalfight|number}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_fightwon}</td>
            <td><span class="astroalh_stat_value">{$fightwon|number}</span> {if $totalfight}<span class="astroalh_stat_pct">({round($fightwon / $totalfight * 100, 2)}%)</span>{/if}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_fightlose}</td>
            <td><span class="astroalh_stat_value">{$fightlose|number}</span> {if $totalfight}<span class="astroalh_stat_pct">({round($fightlose / $totalfight * 100, 2)}%)</span>{/if}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_fightdraw}</td>
            <td><span class="astroalh_stat_value">{$fightdraw|number}</span> {if $totalfight}<span class="astroalh_stat_pct">({round($fightdraw / $totalfight * 100, 2)}%)</span>{/if}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_unitsshot}</td>
            <td class="astroalh_stat_value">{$unitsshot}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_unitslose}</td>
            <td class="astroalh_stat_value">{$unitslose}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_dermetal}</td>
            <td class="astroalh_stat_value">{$dermetal}</td>
        </tr>
        <tr>
            <td class="astroalh_stat_label">{$LNG.pl_dercrystal}</td>
            <td class="astroalh_stat_value">{$dercrystal}</td>
        </tr>
    </table>

    {if !$isOwner}
    <table class="astroalh_table astroalh_leave_table">
        <tr>
            <th>{$LNG.al_leave_alliance}</th>
        </tr>
        <tr>
            <td>
                <a href="game.php?page=alliance&amp;mode=close" onclick="return confirm('{$LNG.al_leave_ally}');">
                    <button class="astroalh_leave_btn">{$LNG.al_continue}</button>
                </a>
            </td>
        </tr>
    </table>
    {/if}

</div>
</div>

{/block}