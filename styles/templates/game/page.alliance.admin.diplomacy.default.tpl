{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.admin.diplomacy.default.tpl === *}
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
   AstroIO v3.0 — Alianza · Admin · Diplomacia
   Prefijo: .astroaldi_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Headers de tabla con gradiente púrpura
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - IDs, names, onclick, Smarty y clases funcionales intactos
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

.astroaldi_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroaldi_panel {
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

.astroaldi_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroaldi_section { margin-bottom: 14px; }
.astroaldi_section:last-child { margin-bottom: 0; }

.astroaldi_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
}

.astroaldi_table tr > th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 5px 10px;
    text-align: left;
    font-weight: normal;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroaldi_table tr > td {
    padding: 4px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    height: 22px;
    vertical-align: middle;
    color: var(--text-main);
}

.astroaldi_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

.astroaldi_name    { width: 85%; }
.astroaldi_actions { width: 15%; text-align: right; white-space: nowrap; }

.astroaldi_icon {
    display: inline-block;
    margin-left: 4px;
    transition: 0.2s ease;
    opacity: 0.85;
}
.astroaldi_icon:hover {
    opacity: 1;
    transform: scale(1.15);
}

.astroaldi_empty {
    color: var(--text-muted);
    font-style: italic;
    text-align: center;
    padding: 8px 10px;
}

.astroaldi_btn {
    display: inline-block;
    padding: 5px 14px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    cursor: pointer;
    text-decoration: none;
    transition: 0.25s ease;
    font-family: inherit;
}
.astroaldi_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astroaldi_btn:active {
    transform: translateY(0);
}

.astroaldi_back {
    display: inline-block;
    padding: 5px 16px;
    color: #00e0ff;
    text-decoration: none;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: 0.25s ease;
}
.astroaldi_back:hover {
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}

@media (max-width: 720px) {
    .astroaldi_wrap { padding: 10px; }
    .astroaldi_panel { padding: 12px; }
    .astroaldi_table { font-size: 10px; }
    .astroaldi_name    { width: 75%; }
    .astroaldi_actions { width: 25%; }
}
</style>

<div class="astroaldi_wrap">
<div class="astroaldi_panel">

    <div class="astroaldi_title">{$LNG.al_diplo_head}</div>

    <div class="astroaldi_section">
        <table class="astroaldi_table">
            <tr>
                <td colspan="2" class="astroaldi_empty">{$LNG.al_diplo_info}</td>
            </tr>
            {foreach $diploList.0 as $diploMode => $diploAlliances}
            <tr>
                <th colspan="2">{$LNG.al_diplo_level.$diploMode}</th>
            </tr>
            {foreach $diploAlliances as $diploID => $diploName}
            <tr>
                <td class="astroaldi_name">{$diploName}</td>
                <td class="astroaldi_actions">
                    <a class="astroaldi_icon" href="game.php?page=alliance&amp;mode=admin&amp;action=diplomacyDelete&amp;id={$diploID}" onclick="return confirm('{$LNG.al_diplo_confirm_delete}');">
                        <img src="styles/resource/images/false.png" alt="" width="16" height="16">
                    </a>
                </td>
            </tr>
            {foreachelse}
            <tr>
                <td colspan="2" class="astroaldi_empty">{$LNG.al_diplo_no_entry}</td>
            </tr>
            {/foreach}
            <tr>
                <td colspan="2">
                    <a class="astroaldi_btn" href="game.php?page=alliance&amp;mode=admin&amp;action=diplomacyCreate&amp;diploMode={$diploMode}" onclick="return Dialog.open(this.href, 650, 300);">{$LNG.al_diplo_create}</a>
                </td>
            </tr>
            {/foreach}
        </table>
    </div>

    <div class="astroaldi_section">
        <table class="astroaldi_table">
            <tr>
                <th colspan="2">{$LNG.al_diplo_accept}</th>
            </tr>
            {if array_filter($diploList.1)}
                {foreach $diploList.1 as $diploMode => $diploAlliances}
                {if !empty($diploAlliances)}
                <tr>
                    <th colspan="2">{$LNG.al_diplo_level.$diploMode}</th>
                </tr>
                {foreach $diploAlliances as $diploID => $diploName}
                <tr>
                    <td class="astroaldi_name">{$diploName}</td>
                    <td class="astroaldi_actions">
                        <a class="astroaldi_icon" href="game.php?page=alliance&amp;mode=admin&amp;action=diplomacyAccept&amp;id={$diploID}" onclick="return confirm('{$LNG.al_diplo_accept_yes_confirm}');">
                            <img src="styles/resource/images/true.png" alt="" width="16" height="16">
                        </a>
                        <a class="astroaldi_icon" href="game.php?page=alliance&amp;mode=admin&amp;action=diplomacyDelete&amp;id={$diploID}" onclick="return confirm('{$LNG.al_diplo_accept_no_confirm}');">
                            <img src="styles/resource/images/false.png" alt="" width="16" height="16">
                        </a>
                    </td>
                </tr>
                {/foreach}
                {/if}
                {/foreach}
            {else}
            <tr>
                <td colspan="2" class="astroaldi_empty">{$LNG.al_diplo_no_accept}</td>
            </tr>
            {/if}
        </table>
    </div>

    <div class="astroaldi_section">
        <table class="astroaldi_table">
            <tr>
                <th colspan="2">{$LNG.al_diplo_accept_send}</th>
            </tr>
            {if array_filter($diploList.2)}
                {foreach $diploList.2 as $diploMode => $diploAlliances}
                {if !empty($diploAlliances)}
                <tr>
                    <th colspan="2">{$LNG.al_diplo_level.$diploMode}</th>
                </tr>
                {foreach $diploAlliances as $diploID => $diploName}
                <tr>
                    <td class="astroaldi_name">{$diploName}</td>
                    <td class="astroaldi_actions">
                        <a class="astroaldi_icon" href="game.php?page=alliance&amp;mode=admin&amp;action=diplomacyDelete&amp;id={$diploID}" onclick="return confirm('{$LNG.al_diplo_confirm_delete}');">
                            <img src="styles/resource/images/false.png" alt="" width="16" height="16">
                        </a>
                    </td>
                </tr>
                {/foreach}
                {/if}
                {/foreach}
            {else}
            <tr>
                <td colspan="2" class="astroaldi_empty">{$LNG.al_diplo_no_accept}</td>
            </tr>
            {/if}
            <tr>
                <td colspan="2" style="text-align:center; padding-top:8px;">
                    <a class="astroaldi_back" href="game.php?page=alliance&amp;mode=admin">← {$LNG.al_back}</a>
                </td>
            </tr>
        </table>
    </div>

</div>
</div>

{/block}