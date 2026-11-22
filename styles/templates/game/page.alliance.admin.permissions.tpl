{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{$countRank = count($availableRanks)}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Admin · Permisos/Rangos
   Prefijo: .astroalap_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tabla con header púrpura + hover
     - Inputs/checkboxes con radius 8px + focus translateY
     - ⚠️ CRÍTICO: #create_new_alliance_rank + #new_alliance_rank + .ui-dialog-* intactos
     - ⚠️ CRÍTICO: checkboxes custom (appearance:none + ✓) intactos
     - ⚠️ CRÍTICO: colspan dinámico {$countRank + 2} intacto
     - ⚠️ CRÍTICO: disabled {$ownRights[$rankName]} + checked {$rankRow[$rankName]} intactos
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

.astroalap_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalap_panel {
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

.astroalap_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

/* Botón "+" (crear nuevo rango) */
#create_new_alliance_rank {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 26px;
    height: 26px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    line-height: 1;
    padding: 0;
    transition: 0.25s ease;
}
#create_new_alliance_rank:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px) scale(1.05);
}
#create_new_alliance_rank:active {
    transform: translateY(0) scale(1);
}

.astroalap_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    table-layout: auto;
}

.astroalap_table tr > th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 6px 10px;
    text-align: left;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroalap_table tr > td {
    padding: 5px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    vertical-align: middle;
    color: var(--text-main);
}

.astroalap_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Primera fila (cabecera con iconos de permisos) */
.astroalap_table tr:first-child > td {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 700;
    padding: 8px 10px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

/* Inputs de texto */
.astroalap_table input[type="text"] {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 5px 8px;
    font-size: 10.5px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    width: 100%;
    box-sizing: border-box;
    transition: 0.25s ease;
    outline: none;
}
.astroalap_table input[type="text"]:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Checkboxes custom */
.astroalap_table input[type="checkbox"] {
    appearance: none;
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    transition: 0.25s ease;
    vertical-align: middle;
}
.astroalap_table input[type="checkbox"]:hover {
    border-color: #00ccff;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroalap_table input[type="checkbox"]:checked {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.6);
}
.astroalap_table input[type="checkbox"]:checked::after {
    content: '✓';
    position: absolute;
    top: -1px;
    left: 3px;
    color: #ffffff;
    font-size: 13px;
    font-weight: bold;
}
.astroalap_table input[type="checkbox"]:disabled {
    opacity: 0.3;
    cursor: not-allowed;
    background: rgba(26, 35, 50, 0.6);
}
.astroalap_table input[type="checkbox"]:disabled:hover {
    box-shadow: none;
    border-color: rgba(0, 204, 255, 0.35);
}

/* Botón submit */
.astroalap_btn {
    display: inline-block;
    padding: 7px 20px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    margin: 4px 0;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-family: inherit;
}
.astroalap_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astroalap_btn:active {
    transform: translateY(0);
}

/* Imágenes de permisos */
.astroalap_table img {
    vertical-align: middle;
    filter: drop-shadow(0 0 3px rgba(0, 224, 255, 0.3));
}

/* Icono delete (columna 1) */
.astroalap_table td:first-child a {
    display: inline-block;
    transition: 0.25s ease;
}
.astroalap_table td:first-child a:hover {
    transform: scale(1.2);
    filter: drop-shadow(0 0 6px rgba(255, 68, 136, 0.8));
}

/* Enlaces */
.astroalap_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalap_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* Fila "sin rangos" */
.astroalap_empty {
    color: var(--text-muted);
    font-style: italic;
    text-align: center;
    padding: 12px;
}

/* Fila legend (título) */
.astroalap_table tr.title > th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 6px 10px;
    text-align: left;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

/* Fila "Volver" (última fila) */
.astroalap_table tr > th a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalap_table tr > th a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

/* ═══ Diálogo #new_alliance_rank (jQuery UI) ═══ */
#new_alliance_rank {
    background: var(--bg-card) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    color: var(--text-main) !important;
    font-size: 11px !important;
    padding: 10px 14px !important;
}
#new_alliance_rank .ui-dialog-titlebar {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border-bottom: 1px solid var(--accent-purple) !important;
    color: #ffffff !important;
    border-radius: 10px 10px 0 0 !important;
    padding: 8px 12px !important;
    font-size: 11px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
#new_alliance_rank .ui-dialog-content {
    background: transparent !important;
    color: var(--text-main) !important;
    padding: 12px !important;
}
#new_alliance_rank table {
    width: 100%;
    border-collapse: collapse;
}
#new_alliance_rank table tr > td {
    padding: 5px 8px;
    color: var(--text-main);
    vertical-align: middle;
}
#new_alliance_rank table tr > th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85)) !important;
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 6px 10px;
    font-weight: 700;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
#new_alliance_rank input[type="text"] {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 6px 8px;
    font-size: 10.5px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    width: 100%;
    box-sizing: border-box;
    transition: 0.25s ease;
    outline: none;
}
#new_alliance_rank input[type="text"]:focus {
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
#new_alliance_rank input[type="checkbox"] {
    appearance: none;
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    transition: 0.25s ease;
    vertical-align: middle;
}
#new_alliance_rank input[type="checkbox"]:hover {
    border-color: #00ccff;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
#new_alliance_rank input[type="checkbox"]:checked {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.6);
}
#new_alliance_rank input[type="checkbox"]:checked::after {
    content: '✓';
    position: absolute;
    top: -1px;
    left: 3px;
    color: #ffffff;
    font-size: 13px;
    font-weight: bold;
}
#new_alliance_rank input[type="submit"] {
    display: inline-block;
    padding: 7px 20px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-family: inherit;
}
#new_alliance_rank input[type="submit"]:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
#new_alliance_rank input[type="submit"]:active {
    transform: translateY(0);
}

/* Responsive */
@media (max-width: 720px) {
    .astroalap_wrap { padding: 10px; }
    .astroalap_panel { padding: 12px; }
    .astroalap_table { font-size: 10px; }
    .astroalap_table tr > td,
    .astroalap_table tr > th { padding: 4px 6px; }
}
</style>

<div class="astroalap_wrap">
<div class="astroalap_panel">

    <div class="astroalap_title">
        <span>{$LNG.al_configura_ranks}</span>
        <button id="create_new_alliance_rank">+</button>
    </div>

    <form action="game.php?page=alliance&amp;mode=admin&amp;action=permissionsSend" method="post">
    <input type="hidden" value="1" name="send">
        <table class="astroalap_table">
        <tr>
            <td>{$LNG.al_dlte}</td>
            <td>{$LNG.al_rank_name}</td>
            {foreach $availableRanks as $rankName}
            <td><img src="styles/resource/images/alliance/{$rankName}.png" alt="" width="16" height="16"></td>
            {/foreach}
        </tr>
        {foreach $rankList as $rowId => $rankRow}
        <tr>
            <td><a href="game.php?page=alliance&amp;mode=admin&amp;action=permissionsSend&amp;deleteRank={$rowId}"><img src="styles/resource/images/alliance/CLOSE.png" alt="" width="16" height="16"></a></td>
            <td><input type="text" name="rank[{$rowId}][rankName]" value="{$rankRow.rankName}"></td>
            {foreach $availableRanks as $rankId => $rankName}
            <td><input type="checkbox" name="rank[{$rowId}][{$rankId}]" value="1"{if $rankRow[$rankName]} checked{/if}{if !$ownRights[$rankName]} disabled{/if}></td>
            {/foreach}
        </tr>
        {foreachelse}
        <tr>
            <td colspan="{$countRank + 2}" class="astroalap_empty">{$LNG.al_no_ranks_defined}</td>
        </tr>
        {/foreach}
        <tr>
            <td colspan="{$countRank + 2}"><input class="astroalap_btn" type="submit" value="{$LNG.al_save}"></td>
        </tr>
        <tr class="title">
            <th colspan="{$countRank + 2}">{$LNG.gl_legend}</th>
        </tr>
        {foreach $availableRanks as $rankName}
        <tr>
            <td><img src="styles/resource/images/alliance/{$rankName}.png" alt="" width="16" height="16"></td>
            <td colspan="{$countRank + 1}">{$LNG.al_rank_desc[$rankName]}</td>
        </tr>
        {/foreach}
        <tr>
            <th colspan="{$countRank + 2}"><a href="game.php?page=alliance&amp;mode=admin">{$LNG.al_back}</a></th>
        </tr>
        </table>
    </form>

</div>
</div>

<div id="new_alliance_rank" title="{$LNG.al_create_new_rank}" style="display:none;">
    <form action="game.php?page=alliance&amp;mode=admin&amp;action=permissionsSend" method="post">
        <table>
        <tr>
            <td><label for="rankName">{$LNG.al_rank_name}</label></td>
            <td><input type="text" name="newrank[rankName]" size="20" maxlength="32" id="rankName" required></td>
        </tr>
        <tr>
            <th colspan="{$countRank + 2}">&nbsp;</th>
        </tr>
        {foreach $availableRanks as $rankId => $rankName}
        <tr>
            <td><img src="styles/resource/images/alliance/{$rankName}.png" alt="{$rankName}" width="16" height="16">&nbsp;<label for="rank_{$rankId}">{$LNG.al_rank_desc[$rankName]}</label></td>
            <td><input type="checkbox" name="newrank[{$rankId}]" value="1" id="rank_{$rankId}" title="{$LNG.al_rank_desc[$rankName]}"></td>
        </tr>
        {/foreach}
        <tr>
            <td colspan="{$countRank + 2}"><input type="submit" value="{$LNG.al_create}"></td>
        </tr>
        </table>
    </form>
</div>
{/block}