{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Admin · Overview
   Prefijo: .astroalao_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tabla con header púrpura + hover
     - Inputs/selects/textarea con radius 8px + focus translateY
     - Botones con radius 8px + hover translateY
     - ⚠️ CRÍTICO: TinyMCE (init + overrides .mce*) intactos
     - ⚠️ CRÍTICO: forms, inputs, names, hrefs, {if}, {assign} intactos
     - 🆕 v3.1: Límite de miembros fijado en 7 (solo lectura).
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

.astroalao_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalao_panel {
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

.astroalao_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalao_section { margin-bottom: 14px; }
.astroalao_section:last-child { margin-bottom: 0; }

/* ═══ Tabla base ═══ */
.astroalao_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
}

.astroalao_table tr > th {
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

.astroalao_table tr > td {
    padding: 6px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    vertical-align: middle;
    color: var(--text-main);
}

.astroalao_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Fila de navegación (permissions/members/diplomacy) */
.astroalao_nav_td {
    text-align: center;
    padding: 10px !important;
}

.astroalao_nav_link {
    display: inline-block;
    padding: 7px 20px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff !important;
    text-decoration: none;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 700;
}
.astroalao_nav_link:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
    text-shadow: none;
}
.astroalao_nav_link:active {
    transform: translateY(0);
}

/* ═══ Inputs de texto ═══ */
.astroalao_table input[type="text"],
.astroalao_table input[type="number"] {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 6px 10px;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    width: 100%;
    box-sizing: border-box;
    transition: 0.25s ease;
    outline: none;
}
.astroalao_table input[type="text"]:focus,
.astroalao_table input[type="number"]:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* ═══ Selects (html_options) ═══ */
.astroalao_table select {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 6px 10px;
    font-size: 11px;
    font-family: inherit;
    font-weight: 700;
    transition: 0.25s ease;
    max-width: 100%;
    outline: none;
    cursor: pointer;
}
.astroalao_table select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astroalao_table select option {
    background: #0f1624;
    color: #ffffff;
    padding: 4px;
}
.astroalao_table select[multiple] {
    min-height: 90px;
    padding: 4px;
}
.astroalao_table select[multiple] option {
    padding: 4px 8px;
    background: #0f1624;
    color: #cbd5e1;
    border-radius: 4px;
}
.astroalao_table select[multiple] option:checked {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
}

/* ═══ Textarea (TinyMCE lo reemplaza) ═══ */
.astroalao_table textarea {
    width: 100%;
    box-sizing: border-box;
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 8px 10px;
    font-size: 11px;
    font-family: inherit;
    resize: vertical;
    transition: 0.25s ease;
    outline: none;
}
.astroalao_table textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* ═══ Botones ═══ */
.astroalao_btn {
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
    margin: 0 4px;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-family: inherit;
}
.astroalao_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astroalao_btn:active {
    transform: translateY(0);
}

.astroalao_btn--reset {
    background: linear-gradient(135deg, rgba(68, 68, 68, 0.9), rgba(102, 102, 102, 0.9));
    border-color: #888888;
}
.astroalao_btn--reset:hover {
    background: linear-gradient(135deg, rgba(102, 102, 102, 0.95), rgba(136, 136, 136, 0.95));
    box-shadow: 0 0 12px rgba(150, 150, 150, 0.4);
}

.astroalao_btn--danger {
    background: linear-gradient(135deg, rgba(204, 34, 68, 0.9), rgba(255, 68, 136, 0.9));
    border-color: #ff4488;
}
.astroalao_btn--danger:hover {
    background: linear-gradient(135deg, rgba(255, 68, 136, 0.95), rgba(255, 100, 150, 0.95));
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.6);
}

.astroalao_actions {
    text-align: center;
    padding: 10px 0;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}

/* ═══ Enlaces normales ═══ */
.astroalao_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
    font-weight: 600;
}
.astroalao_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* ═══ Bloque danger (disolver/transferir) ═══ */
.astroalao_table.astroalao_danger tr > th {
    background: linear-gradient(135deg, rgba(102, 17, 34, 0.9), rgba(170, 34, 68, 0.9));
    border-bottom: 1px solid var(--accent-red);
}
.astroalao_table.astroalao_transfer tr > th {
    background: linear-gradient(135deg, rgba(85, 51, 0, 0.9), rgba(170, 102, 0, 0.9));
    border-bottom: 1px solid var(--accent-gold);
}

/* ═══ Override TinyMCE (afecta solo dentro del panel) ═══ */
.astroalao_panel .mceEditor,
.astroalao_panel .mceLayout {
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    overflow: hidden;
}
.astroalao_panel .mceToolbar {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
}
.astroalao_panel .mceButton {
    background: transparent !important;
    border: 1px solid transparent !important;
}
.astroalao_panel .mceButton:hover {
    background: rgba(0, 224, 255, 0.15) !important;
    border-color: #00ccff !important;
    border-radius: 6px !important;
}
.astroalao_panel .mceButtonActive {
    background: rgba(0, 224, 255, 0.25) !important;
    border-color: #00ccff !important;
    border-radius: 6px !important;
}
.astroalao_panel .mceStatusbar {
    background: rgba(0, 0, 0, 0.5) !important;
    color: var(--text-muted) !important;
    border-top: 1px solid rgba(0, 204, 255, 0.2) !important;
}
.astroalao_panel .mcePath {
    color: var(--text-muted) !important;
}

/* ═══ Responsive ═══ */
@media (max-width: 720px) {
    .astroalao_wrap { padding: 10px; }
    .astroalao_panel { padding: 12px; }
    .astroalao_table { font-size: 10px; }
    .astroalao_table tr > td { padding: 5px 8px; }
    .astroalao_nav_link { padding: 6px 14px; font-size: 9.5px; }
    .astroalao_btn { width: 100%; margin: 4px 0; box-sizing: border-box; }
    .astroalao_actions { padding: 10px 0; }
}
</style>

<div class="astroalao_wrap">
<div class="astroalao_panel">

    <div class="astroalao_title">{$LNG.al_manage_alliance}</div>

    <!-- ═══ Navegación rápida ═══ -->
    <div class="astroalao_section">
        <table class="astroalao_table">
            <tr style="text-align: center;">
                <td class="astroalao_nav_td"><a class="astroalao_nav_link" href="game.php?page=alliance&amp;mode=admin&amp;action=permissions">{$LNG.al_manage_ranks}</a></td>
                <td class="astroalao_nav_td"><a class="astroalao_nav_link" href="game.php?page=alliance&amp;mode=admin&amp;action=members">{$LNG.al_manage_members}</a></td>
                {if $rights.DIPLOMATIC}
                    <td class="astroalao_nav_td"><a class="astroalao_nav_link" href="game.php?page=alliance&amp;mode=admin&amp;action=diplomacy">{$LNG.al_manage_diplo}</a></td>
                {/if}
            </tr>
        </table>
    </div>

    <form action="game.php?page=alliance&mode=admin" method="post">
    <input type="hidden" name="textMode" value="{$textMode}">
    <input type="hidden" name="send" value="1">

    <!-- ═══ Textos (TinyMCE) ═══ -->
    <div class="astroalao_section">
        <table class="astroalao_table">
            <tr>
                <th colspan="3">{$LNG.al_texts}</th>
            </tr>
            <tr style="text-align: center;">
                <td class="astroalao_nav_td"><a href="game.php?page=alliance&amp;mode=admin&amp;textMode=external">{$LNG.al_outside_text}</a></td>
                <td class="astroalao_nav_td"><a href="game.php?page=alliance&amp;mode=admin&amp;textMode=internal">{$LNG.al_inside_text}</a></td>
                <td class="astroalao_nav_td"><a href="game.php?page=alliance&amp;mode=admin&amp;textMode=apply">{$LNG.al_request_text}</a></td>
            </tr>
            <tr>
                <td colspan="3">
                    <textarea name="text" id="text" cols="70" rows="15" class="tinymce">{$text}</textarea>
                </td>
            </tr>
            <tr>
                <td colspan="3" class="astroalao_actions">
                    <input class="astroalao_btn astroalao_btn--reset" type="reset" value="{$LNG.al_circular_reset}">
                    <input class="astroalao_btn" type="submit" value="{$LNG.al_save}">
                </td>
            </tr>
        </table>
    </div>

    <!-- ═══ Opciones generales ═══ -->
    <div class="astroalao_section">
        <table class="astroalao_table">
            <tr>
                <th colspan="2">{$LNG.al_manage_options}</th>
            </tr>
            <tr>
                <td>{$LNG.al_tag}</td>
                <td><input type="text" name="ally_tag" value="{$ally_tag}" size="8" maxlength="8" required></td>
            </tr>
            <tr>
                <td>{$LNG.al_name}</td>
                <td><input type="text" name="ally_name" value="{$ally_name}" size="20" maxlength="30" required></td>
            </tr>
            <tr>
                <td>{$LNG.al_manage_founder_rank}</td>
                <td><input type="text" name="owner_range" value="{$ally_owner_range}" size="30"></td>
            </tr>
            <tr>
                <td>{$LNG.al_web_site}</td>
                <td><input type="text" name="web" value="{$ally_web}" size="70"></td>
            </tr>
            <tr>
                <td>{$LNG.al_manage_image}</td>
                <td><input type="text" name="image" value="{$ally_image}" size="70"></td>
            </tr>
            <tr>
                <td>{$LNG.al_view_stats}</td>
                <td>{html_options name=stats options=$YesNoSelector selected=$ally_stats_data}</td>
            </tr>
            <tr>
                <td>{$LNG.al_view_diplo}</td>
                <td>{html_options name=diplo options=$YesNoSelector selected=$ally_diplo_data}</td>
            </tr>
            <tr>
                <td>{$LNG.al_view_events}</td>
                <td>
                    <select name="events[]" size="{$available_events|@count}" multiple>
                        {foreach $available_events as $id => $mission}
                            {foreach $ally_events as $selected_events}
                                {if $selected_events == $id}
                                    {assign var=selected value=selected}
                                    {break}
                                {else}
                                    {assign var=selected value=''}
                                {/if}
                            {/foreach}
                            <option value="{$id}" {$selected}>{$mission}</option>
                        {/foreach}
                    </select>
                </td>
            </tr>
        </table>
    </div>

    <!-- ═══ Solicitudes ═══ -->
    <div class="astroalao_section">
        <table class="astroalao_table">
            <tr>
                <th colspan="2">{$LNG.al_manage_requests}</th>
            </tr>
            <tr>
                <td>{$LNG.al_manage_requests}</td>
                <td>{html_options name=request_notallow options=$RequestSelector selected=$ally_request_notallow}</td>
            </tr>
            <tr>
                <td>{$LNG.al_set_max_members}</td>
                <td>
                    {$ally_members} / 
                    <input type="number" min="1" max="7" name="ally_max_members" value="7" size="8" readonly style="background: rgba(0, 0, 0, 0.3); color: #fbbf24; cursor: not-allowed; border: 1px solid #fbbf24; pointer-events: none; width: 60px;" title="El límite máximo del servidor es de 7 miembros">
                    <span style="color: #94a3b8; font-size: 10px;">(Límite Fijo)</span>
                </td>
            </tr>
            <tr>
                <td>{$LNG.al_manage_request_min_points}</td>
                <td><input type="number" min="0" name="request_min_points" value="{$ally_request_min_points}" size="30"></td>
            </tr>
            <tr>
                <td colspan="3" class="astroalao_actions">
                    <input class="astroalao_btn astroalao_btn--reset" type="reset" value="{$LNG.al_circular_reset}">
                    <input class="astroalao_btn" type="submit" value="{$LNG.al_save}">
                </td>
            </tr>
        </table>
    </div>
    </form>

    {if $AllianceOwner}
    <!-- ═══ Disolver alianza (DANGER) ═══ -->
    <div class="astroalao_section">
        <table class="astroalao_table astroalao_danger">
            <tr>
                <th>{$LNG.al_disolve_alliance}</th>
            </tr>
            <tr>
                <td style="text-align:center;">
                    <form action="game.php?page=alliance&amp;mode=admin&amp;action=close" method="post">
                        <input class="astroalao_btn astroalao_btn--danger" type="submit" value="{$LNG.al_continue}" onclick="return confirm('{$LNG.al_close_ally}');">
                    </form>
                </td>
            </tr>
        </table>
    </div>

    <!-- ═══ Transferir alianza (WARNING) ═══ -->
    <div class="astroalao_section">
        <table class="astroalao_table astroalao_transfer">
            <tr>
                <th>{$LNG.al_transfer_alliance}</th>
            </tr>
            <tr>
                <td style="text-align:center;">
                    <form action="game.php?page=alliance&amp;mode=admin&amp;action=transfer" method="post">
                        <input class="astroalao_btn" type="submit" value="{$LNG.al_continue}">
                    </form>
                </td>
            </tr>
        </table>
    </div>
    {/if}

</div>
</div>

{/block}
{block name="script" append}
<script type="text/javascript" src="scripts/base/tinymce/tiny_mce_gzip.js"></script>
<script type="text/javascript">
$(function() {
	tinyMCE_GZ.init({
		plugins : 'bbcode,fullscreen',
		themes : 'advanced',
		languages : '{$lang}',
		disk_cache : true,
		debug : false
	}, function() {
		tinyMCE.init({
			language : '{$lang}',
			script_url : 'scripts/base/tinymce/tiny_mce.js',
			theme : "advanced",
			mode : "textareas",
			plugins : "bbcode,fullscreen",
			theme_advanced_buttons1 : "bold,italic,underline,undo,redo,link,unlink,image,forecolor,styleselect,removeformat,cleanup,code,fullscreen",
			theme_advanced_buttons2 : "",
			theme_advanced_buttons3 : "",
			theme_advanced_toolbar_location : "bottom",
			theme_advanced_toolbar_align : "center",
			theme_advanced_styles : "Code=codeStyle;Quote=quoteStyle",
			content_css : "{$dpath}formate.css",
			entity_encoding : "raw",
			add_unload_trigger : false,
			remove_linebreaks : false,
			fullscreen_new_window : false,
			fullscreen_settings : {
				theme_advanced_path_location : "top"
			}
		});
	});
});
</script>
{/block}