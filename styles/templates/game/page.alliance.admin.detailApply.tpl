{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Admin · Detalle Solicitud
   Prefijo: .astroalada_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Tablas con header púrpura + hover
     - Textarea con radius 8px + focus translateY
     - Botones yes/no con radius 8px + hover translateY
     - ⚠️ CRÍTICO: TinyMCE (init + overrides .mce*) intactos
     - ⚠️ CRÍTICO: form, textarea, buttons, onclick, {if}, colspan intactos
     - 🆕 v3.1: Botón "Aceptar" deshabilitado y advertencia si la alianza está llena (7/7).
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

.astroalada_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalada_panel {
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

.astroalada_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalada_section { margin-bottom: 14px; }
.astroalada_section:last-child { margin-bottom: 0; }

.astroalada_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    color: var(--text-main);
}

.astroalada_table tr > th {
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

.astroalada_table tr > td {
    padding: 5px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    height: 24px;
    vertical-align: middle;
    color: var(--text-main);
}

.astroalada_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Columna izquierda (labels) */
.astroalada_table tr > td[colspan="2"]:first-child {
    color: var(--text-muted);
    font-weight: 600;
}

/* Enlaces */
.astroalada_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalada_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* ═══ Tabla de respuesta (table519) ═══ */
.astroalada_reply {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    color: var(--text-main);
    margin-top: 12px;
}

.astroalada_reply tr > th {
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

.astroalada_reply tr > td {
    padding: 6px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    vertical-align: top;
    color: var(--text-main);
}

.astroalada_reply label {
    color: #ffffff;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 700;
}

.astroalada_reply textarea {
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
.astroalada_reply textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Botones yes/no */
.astroalada_btn {
    display: inline-block;
    padding: 7px 22px;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    margin: 0 4px;
    color: #ffffff;
    border: 1px solid transparent;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-family: inherit;
}

.astroalada_btn--yes {
    background: linear-gradient(135deg, rgba(34, 136, 51, 0.9), rgba(102, 255, 153, 0.9));
    border-color: #66ff99;
    color: #0f1624;
    font-weight: 700;
    text-shadow: none;
}
.astroalada_btn--yes:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(102, 255, 153, 0.95), rgba(140, 255, 180, 0.95));
    box-shadow: 0 0 14px rgba(102, 255, 153, 0.6);
    transform: translateY(-2px);
}
.astroalada_btn--yes:active:not(:disabled) {
    transform: translateY(0);
}
.astroalada_btn--yes:disabled {
    background: rgba(60, 70, 90, 0.5);
    border-color: rgba(90, 110, 140, 0.6);
    color: #94a3b8;
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
}

.astroalada_btn--no {
    background: linear-gradient(135deg, rgba(204, 34, 68, 0.9), rgba(255, 68, 136, 0.9));
    border-color: #ff4488;
}
.astroalada_btn--no:hover {
    background: linear-gradient(135deg, rgba(255, 68, 136, 0.95), rgba(255, 100, 150, 0.95));
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.6);
    transform: translateY(-2px);
}
.astroalada_btn--no:active {
    transform: translateY(0);
}

.astroalada_actions {
    text-align: center;
    padding: 10px 0;
    border-top: 1px solid rgba(0, 204, 255, 0.15);
}

/* ═══ Override TinyMCE (afecta solo dentro del panel) ═══ */
.astroalada_panel .mceEditor,
.astroalada_panel .mceLayout {
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    overflow: hidden;
}
.astroalada_panel .mceToolbar {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
}
.astroalada_panel .mceButton {
    background: transparent !important;
    border: 1px solid transparent !important;
}
.astroalada_panel .mceButton:hover {
    background: rgba(0, 224, 255, 0.15) !important;
    border-color: #00ccff !important;
    border-radius: 6px !important;
}
.astroalada_panel .mceButtonActive {
    background: rgba(0, 224, 255, 0.25) !important;
    border-color: #00ccff !important;
    border-radius: 6px !important;
}
.astroalada_panel .mceStatusbar {
    background: rgba(0, 0, 0, 0.5) !important;
    color: var(--text-muted) !important;
    border-top: 1px solid rgba(0, 204, 255, 0.2) !important;
}
.astroalada_panel .mcePath {
    color: var(--text-muted) !important;
}

/* ═══ Responsive ═══ */
@media (max-width: 720px) {
    .astroalada_wrap { padding: 10px; }
    .astroalada_panel { padding: 12px; }
    .astroalada_table { font-size: 10px; }
    .astroalada_reply { font-size: 10px; }
    .astroalada_btn { width: 100%; margin: 4px 0; box-sizing: border-box; }
}
</style>

<div class="astroalada_wrap">
<div class="astroalada_panel">

    <div class="astroalada_title">{$LNG.al_request_from} {$apply_time}</div>

    <div class="astroalada_section">
        <table class="astroalada_table">
            <tr>
                <th colspan="4">&nbsp;</th>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_name}</td>
                <td colspan="2">{$applyDetail.username}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_homeplanet}</td>
                <td colspan="2">{$applyDetail.name} <a href="#" onclick="parent.location = 'game.php?page=galaxy&galaxy={$applyDetail.galaxy}&system={$applyDetail.system}';return false;">[{$applyDetail.coordinates}]</a></td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.al_request_register_time}</td>
                <td colspan="2">{$register_time}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.al_request_last_onlinetime}</td>
                <td colspan="2">{$onlinetime}</td>
            </tr>
            <tr>
                <th colspan="2" style="text-align:center;">&nbsp;</th>
                <th colspan="1" style="text-align:center;">{$LNG.pl_points}</th>
                <th colspan="1" style="text-align:center;">{$LNG.pl_range}</th>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_tech}</td>
                <td colspan="1">{$applyDetail.tech_points}</td>
                <td colspan="1">{$applyDetail.tech_rank}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_builds}</td>
                <td colspan="1">{$applyDetail.build_points}</td>
                <td colspan="1">{$applyDetail.build_rank}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_def}</td>
                <td colspan="1">{$applyDetail.defs_points}</td>
                <td colspan="1">{$applyDetail.defs_rank}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_fleet}</td>
                <td colspan="1">{$applyDetail.fleet_points}</td>
                <td colspan="1">{$applyDetail.fleet_rank}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_total}</td>
                <td colspan="1">{$applyDetail.total_points}</td>
                <td colspan="1">{$applyDetail.total_rank}</td>
            </tr>
            <tr>
                <th colspan="4">{$LNG.pl_fightstats}</th>
            </tr>
            <tr>
                <td colspan="2">&nbsp;</td>
                <td colspan="1">{$LNG.pl_fights}</td>
                <td colspan="1">{$LNG.pl_fprocent}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_fightwon}</td>
                <td colspan="1">{$applyDetail.wons}</td>
                <td colspan="1">{$applyDetail.wons_percentage} %</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_fightdraw}</td>
                <td colspan="1">{$applyDetail.draws}</td>
                <td colspan="1">{$applyDetail.draws_percentage} %</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_fightlose}</td>
                <td colspan="1">{$applyDetail.loos}</td>
                <td colspan="1">{$applyDetail.loos_percentage} %</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_totalfight}</td>
                <td colspan="1">{$applyDetail.total_fights}</td>
                <td colspan="1">100 %</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_unitsshot}</td>
                <td colspan="2">{$applyDetail.desunits}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_unitslose}</td>
                <td colspan="2">{$applyDetail.lostunits}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_dermetal}</td>
                <td colspan="2">{$applyDetail.kbmetal}</td>
            </tr>
            <tr>
                <td colspan="2">{$LNG.pl_dercrystal}</td>
                <td colspan="2">{$applyDetail.kbcrystal}</td>
            </tr>
            {if !empty($applyDetail.text)}
            <tr>
                <th colspan="4">{$LNG.al_message}</th>
            </tr>
            <tr>
                <td colspan="4">{$applyDetail.text}</td>
            </tr>
            {/if}
        </table>
    </div>

    <br>

    <div class="astroalada_section">
        <form action="game.php?page=alliance&amp;mode=admin&amp;action=sendAnswerToApply&amp;id={$applyDetail.applyID}" method="post">
            <table class="table519 astroalada_reply">
                <tr>
                    <th colspan="4"><label for="message">{$LNG.al_reply_to_request}</label></th>
                </tr>
                <tr>
                    <td colspan="4"><textarea name="text" cols="40" rows="10" class="tinymce" id="message"></textarea></td>
                </tr>
                <tr>
                    <td colspan="4" class="astroalada_actions">
                        {if !isset($ally_members) || $ally_members < $smarty.const.MAX_ALLIANCE_MEMBERS}
                            <button class="astroalada_btn astroalada_btn--yes" type="submit" name="answer" value="yes">{$LNG.al_acept_request}</button>
                        {else}
                            <button class="astroalada_btn astroalada_btn--yes" type="button" disabled title="La alianza ha alcanzado el límite de {$smarty.const.MAX_ALLIANCE_MEMBERS} miembros">
                                Alianza Llena (7/7)
                            </button>
                        {/if}
                        <button class="astroalada_btn astroalada_btn--no" type="submit" name="answer" value="no">{$LNG.al_decline_request}</button>
                    </td>
                </tr>
            </table>
        </form>
    </div>

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
			script_url : 'scripts/base/tinymce/tiny_mce.js',
			theme : "advanced",
			mode : "textareas",
			plugins : "bbcode,fullscreen",
			theme_advanced_buttons1 : "bold,italic,underline,undo,redo,link,unlink,image,forecolor,removeformat,cleanup,code,fullscreen",
			theme_advanced_buttons2 : "",
			theme_advanced_buttons3 : "",
			theme_advanced_toolbar_location : "top",
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