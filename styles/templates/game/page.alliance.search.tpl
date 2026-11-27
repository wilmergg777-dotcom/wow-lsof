{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.alliance.search.tpl === *}
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
   AstroIO v3.0 — Alianza · Buscar Alianzas
   Prefijo: .astroalsrch_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-tablas 10px)
     - Headers de tabla con gradiente púrpura
     - Input + botón con radius 8px + hover translateY
     - Wrapper padding 15px
     - IDs, names, href, Smarty y clases funcionales intactos
     - 🆕 v3.1: Validación visual de alianzas llenas (7/7).
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

.astroalsrch_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalsrch_panel {
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

.astroalsrch_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalsrch_section { margin-bottom: 14px; }
.astroalsrch_section:last-child { margin-bottom: 0; }

.astroalsrch_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 10.5px;
    table-layout: fixed;
}

.astroalsrch_table tr > th {
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

.astroalsrch_table tr > td {
    padding: 4px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    height: 22px;
    vertical-align: middle;
    color: var(--text-main);
}

.astroalsrch_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Formulario de búsqueda: columna izquierda con label, derecha con input + botón */
.astroalsrch_form_table tr > td:first-child {
    width: 40%;
    color: var(--text-muted);
}
.astroalsrch_form_table tr > td:last-child {
    width: 60%;
}

/* Input de texto */
.astroalsrch_input {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 6px 10px;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    width: 60%;
    max-width: 300px;
    box-sizing: border-box;
    transition: 0.25s ease;
    vertical-align: middle;
    outline: none;
}
.astroalsrch_input:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

/* Botón submit */
.astroalsrch_submit {
    display: inline-block;
    padding: 6px 18px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    vertical-align: middle;
    margin-left: 8px;
    text-transform: uppercase;
    letter-spacing: 0.4px;
    font-family: inherit;
}
.astroalsrch_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astroalsrch_submit:active {
    transform: translateY(0);
}

/* Tabla de resultados — anchos fijos por columna */
.astroalsrch_results_table th:nth-child(1) { width: 20%; }
.astroalsrch_results_table th:nth-child(2) { width: 55%; }
.astroalsrch_results_table th:nth-child(3) { width: 25%; text-align: center; }
.astroalsrch_results_table td:nth-child(3) { text-align: center; }

/* Enlaces */
.astroalsrch_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalsrch_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* Mensaje "sin resultados" */
.astroalsrch_empty {
    color: var(--text-muted);
    font-style: italic;
    text-align: center;
    padding: 10px;
}

@media (max-width: 720px) {
    .astroalsrch_wrap { padding: 10px; }
    .astroalsrch_panel { padding: 12px; }
    .astroalsrch_table { font-size: 10px; }
    .astroalsrch_form_table tr > td:first-child { width: 35%; }
    .astroalsrch_form_table tr > td:last-child  { width: 65%; }
    .astroalsrch_input { width: 100%; max-width: none; margin-bottom: 4px; }
    .astroalsrch_submit { margin-left: 0; width: 100%; }
    .astroalsrch_results_table th:nth-child(1) { width: 25%; }
    .astroalsrch_results_table th:nth-child(2) { width: 45%; }
    .astroalsrch_results_table th:nth-child(3) { width: 30%; }
}
</style>

<div class="astroalsrch_wrap">
<div class="astroalsrch_panel">

    <div class="astroalsrch_title">{$LNG.lm_alliance}</div>

    <div class="astroalsrch_section">
        <form action="game.php?page=alliance&amp;mode=search" method="post">
            <table class="astroalsrch_table astroalsrch_form_table">
                <tr>
                    <th colspan="2">{$LNG.al_find_alliances}</th>
                </tr>
                <tr>
                    <td>{$LNG.al_find_text}</td>
                    <td>
                        <input class="astroalsrch_input" type="text" name="searchtext" value="{$searchText}">
                        <input class="astroalsrch_submit" type="submit" value="{$LNG.al_find_submit}">
                    </td>
                </tr>
            </table>
        </form>
    </div>

    {if !empty($searchList)}
    <div class="astroalsrch_section">
        <table class="astroalsrch_table astroalsrch_results_table">
            <tr>
                <th>{$LNG.al_ally_info_tag}</th>
                <th>{$LNG.al_ally_info_name}</th>
                <th>{$LNG.al_ally_info_members}</th>
            </tr>
            {foreach $searchList as $seachRow}
            <tr>
                {if $seachRow.members >= 7}
                    <td style="color: #ef4444; font-weight: bold;">{$seachRow.tag}</td>
                    <td style="color: #ef4444; font-weight: bold;">{$seachRow.name}</td>
                    <td style="color: #ef4444; font-weight: bold;">{$seachRow.members} / 7 (LLENA)</td>
                {else}
                    <td><a href="game.php?page=alliance&amp;mode=apply&amp;id={$seachRow.id}">{$seachRow.tag}</a></td>
                    <td><a href="game.php?page=alliance&amp;mode=apply&amp;id={$seachRow.id}">{$seachRow.name}</a></td>
                    <td><a href="game.php?page=alliance&amp;mode=apply&amp;id={$seachRow.id}">{$seachRow.members} / 7</a></td>
                {/if}
            </tr>
            {foreachelse}
            <tr>
                <td colspan="3" class="astroalsrch_empty">{$LNG.al_find_no_alliances}</td>
            </tr>
            {/foreach}
        </table>
    </div>
    {/if}

</div>
</div>

{/block}