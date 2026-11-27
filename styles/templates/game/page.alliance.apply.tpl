{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.apply.tpl === *}
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


{* -----------------------------------------------
   AstroIO v3.0 — Alianza · Solicitud (Apply)
   Prefijo: .astroalap_
   Acento del módulo: ?? Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Textarea + submit con radius 8px + focus translateY
     - Overrides de TinyMCE actualizados (preservando estructura)
     - Wrapper padding 15px
     - form action, textarea, submit, TinyMCE JS: TODO intacto
     - ?? v3.1: Aviso visual del límite de 7 miembros y bloqueo de formulario.
   ----------------------------------------------- *}

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
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalap_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
}

.astroalap_table tr > td {
    padding: 8px 10px;
    vertical-align: top;
    color: var(--text-main);
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
}

.astroalap_table tr > td:first-child {
    width: 30%;
    color: var(--text-muted);
    padding-top: 10px;
}

.astroalap_table tr > td:last-child {
    width: 70%;
}

/* Label */
.astroalap_table label {
    color: var(--text-muted);
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* Textarea (TinyMCE lo reemplaza, pero por si acaso) */
.astroalap_table textarea {
    width: 100%;
    box-sizing: border-box;
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 8px 10px;
    font-size: 11px;
    font-family: inherit;
    transition: 0.25s ease;
    outline: none;
}
.astroalap_table textarea:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Submit */
.astroalap_submit {
    display: inline-block;
    padding: 8px 26px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.4px;
    text-transform: uppercase;
    font-family: inherit;
}
.astroalap_submit:hover:not(:disabled) {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astroalap_submit:active:not(:disabled) {
    transform: translateY(0);
}
.astroalap_submit:disabled {
    background: rgba(60, 70, 90, 0.5);
    border-color: rgba(90, 110, 140, 0.6);
    color: #94a3b8;
    cursor: not-allowed;
}

.astroalap_center {
    text-align: center;
    padding-top: 10px;
    border-bottom: none !important;
}

/* Aviso de límite */
.astroalap_warning {
    background: rgba(251, 191, 36, 0.1);
    border: 1px solid #fbbf24;
    border-left: 4px solid #fbbf24;
    border-radius: 8px;
    padding: 10px;
    margin-bottom: 15px;
    color: #fbbf24;
    font-size: 11px;
    font-weight: 600;
    text-align: center;
}

/* --- Override TinyMCE (afecta solo dentro del panel) --- */
.astroalap_panel .mceEditor,
.astroalap_panel .mceLayout {
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    overflow: hidden;
}
.astroalap_panel .mceToolbar {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
}
.astroalap_panel .mceButton {
    background: transparent !important;
    border: 1px solid transparent !important;
}
.astroalap_panel .mceButton:hover {
    background: rgba(0, 224, 255, 0.15) !important;
    border-color: #00ccff !important;
    border-radius: 6px !important;
}
.astroalap_panel .mceButtonActive {
    background: rgba(0, 224, 255, 0.25) !important;
    border-color: #00ccff !important;
    border-radius: 6px !important;
}
.astroalap_panel .mceStatusbar {
    background: rgba(0, 0, 0, 0.5) !important;
    color: var(--text-muted) !important;
    border-top: 1px solid rgba(0, 204, 255, 0.2) !important;
}
.astroalap_panel .mcePath {
    color: var(--text-muted) !important;
}

@media (max-width: 720px) {
    .astroalap_wrap { padding: 10px; }
    .astroalap_panel { padding: 12px; }
    .astroalap_table tr > td:first-child { width: 35%; }
    .astroalap_table tr > td:last-child  { width: 65%; }
    .astroalap_submit { width: 100%; }
}
</style>

<div class="astroalap_wrap">
<div class="astroalap_panel">

    <div class="astroalap_title">{$al_write_request}</div>

    <div class="astroalap_warning">
        ?? Recuerda: La alianza tiene un límite máximo de {$smarty.const.MAX_ALLIANCE_MEMBERS} miembros.
    </div>

    {if isset($ally_members) && $ally_members >= $smarty.const.MAX_ALLIANCE_MEMBERS}
        <div style="text-align: center; padding: 20px; background: rgba(239, 68, 68, 0.1); border: 1px solid #ef4444; border-radius: 8px; color: #ef4444; font-weight: bold;">
            La alianza ha alcanzado el límite máximo de miembros. No puedes enviar una solicitud.
        </div>
    {else}
        <form action="game.php?page=alliance&amp;mode=apply&amp;id={$allyid}" method="post">
            <table class="astroalap_table">
                <tr>
                    <td><label for="message">{$LNG.al_message}</label></td>
                    <td><textarea name="text" cols="40" rows="20" class="tinymce" id="message">{$applytext}</textarea></td>
                </tr>
                <tr>
                    <td colspan="2" class="astroalap_center">
                        <input class="astroalap_submit" type="submit" value="{$LNG.al_applyform_send}">
                    </td>
                </tr>
            </table>
        </form>
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