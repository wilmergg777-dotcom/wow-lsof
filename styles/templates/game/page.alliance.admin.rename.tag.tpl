{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.admin.rename.tag.tpl === *}
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
   AstroIO v3.0 — Alianza · Admin · Renombrar Tag
   Prefijo: .astroalart_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado vía overrides !important (core .content_page / .title)
     - Inputs con radius 8px + focus translateY
     - Botón con radius 8px + hover translateY
     - form, inputs, names, links, colspan, Smarty intactos
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

/* ====== Override content_page ====== */
.content_page {
    color: var(--text-main);
    max-width: 700px;
    margin: 0 auto;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Título (acento púrpura) ====== */
.content_page > .title {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-bottom: 1px solid var(--accent-purple) !important;
    border-radius: 12px 12px 0 0 !important;
    color: #ffffff !important;
    padding: 12px 16px !important;
    font-weight: 700 !important;
    font-size: 12.5px !important;
    letter-spacing: 0.8px !important;
    text-transform: uppercase !important;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4), 0 0 10px rgba(139, 92, 246, 0.4) !important;
}

/* ====== Cuerpo del panel ====== */
.content_page > div > form > table,
.content_page > form > table {
    background: var(--bg-card) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: 1px solid var(--border-color) !important;
    border-top: none !important;
    border-radius: 0 0 12px 12px !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    width: 100% !important;
    border-collapse: collapse !important;
    font-size: 11px !important;
}

.content_page > div > form > table tr > td,
.content_page > form > table tr > td {
    padding: 10px 16px !important;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6) !important;
    color: var(--text-main) !important;
    vertical-align: middle !important;
}

.content_page > div > form > table tr:hover,
.content_page > form > table tr:hover {
    background: rgba(139, 92, 246, 0.06) !important;
}

.content_page > div > form > table tr > td:first-child,
.content_page > form > table tr > td:first-child {
    color: var(--text-muted) !important;
    font-weight: 600 !important;
    width: 40% !important;
}

/* Fila "Volver" */
.content_page > div > form > table tr > th[colspan="2"],
.content_page > form > table tr > th[colspan="2"] {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border-top: 1px solid var(--accent-cyan) !important;
    border-bottom: none !important;
    text-align: center !important;
    padding: 10px !important;
    font-size: 10.5px !important;
    text-transform: uppercase !important;
    letter-spacing: 1px !important;
}
.content_page > div > form > table tr > th[colspan="2"] a,
.content_page > form > table tr > th[colspan="2"] a {
    color: #00e0ff !important;
    text-decoration: none !important;
    transition: 0.2s ease !important;
}
.content_page > div > form > table tr > th[colspan="2"] a:hover,
.content_page > form > table tr > th[colspan="2"] a:hover {
    color: #ffffff !important;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7) !important;
}

/* ====== Inputs ====== */
.content_page input[type="text"] {
    padding: 7px 12px !important;
    background: rgba(0, 0, 0, 0.5) !important;
    border: 1px solid rgba(0, 204, 255, 0.35) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-family: 'Courier New', monospace !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    outline: none !important;
    transition: 0.25s ease !important;
    box-sizing: border-box !important;
    min-width: 220px !important;
}
.content_page input[type="text"]:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5) !important;
    background: rgba(0, 0, 0, 0.65) !important;
    transform: translateY(-1px) !important;
}

/* ====== Botón submit ====== */
.content_page input[type="submit"] {
    padding: 8px 22px !important;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9) 0%, rgba(0, 153, 255, 0.9) 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    font-weight: 700 !important;
    font-size: 11px !important;
    cursor: pointer !important;
    transition: 0.25s ease !important;
    letter-spacing: 0.4px !important;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4) !important;
    text-transform: uppercase !important;
    font-family: inherit !important;
    margin-left: 8px !important;
    box-shadow: 0 3px 10px rgba(0, 102, 204, 0.4) !important;
}
.content_page input[type="submit"]:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%) !important;
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6), 0 3px 10px rgba(0, 102, 204, 0.5) !important;
    transform: translateY(-2px) !important;
}
.content_page input[type="submit"]:active {
    transform: translateY(0) !important;
}

/* ====== Responsive ====== */
@media (max-width: 480px) {
    .content_page { padding: 10px; }
    .content_page input[type="text"] {
        width: 100% !important;
        min-width: 0 !important;
        margin-bottom: 6px !important;
    }
    .content_page input[type="submit"] {
        width: 100% !important;
        margin-left: 0 !important;
    }
}
</style>

<div class="content_page">
	<div class="title">
		{$LNG.al_tag} {$LNG.al_change_title}
	</div>

	<div>
		<form action="game.php?page=alliance&amp;mode=admin&amp;action=changeTag" method="post">
			<table style="width: 100%;">
				<tr>
					<td>{$LNG.al_new_tag}</td>
					<td><input type="text" name="newname"> <input type="submit" value="{$LNG.al_change_submit}"></td>
				</tr>
				<tr>
					<th colspan="2"><a href="game.php?page=alliance&amp;mode=admin">{$LNG.al_back}</a></th>
				</tr>
			</table>
		</form>
	</div>
</div>

{/block}