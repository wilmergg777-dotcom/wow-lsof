{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pvp.history.tpl === *}
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


<style>
/* ═══════════════════════════════════════════════════════════
   PvP — Historial
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_hist_

   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Bote en el riel del jugador (pool_ntx20 vs pool_untx20)
     - "NTX" hardcodeado reemplazado por {$moneda} dinámica
     - CSS preservado 100% + estilos para balance badge
   ═══════════════════════════════════════════════════════════ */

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

/* ─── RESET GLOBAL ──────────────────────────────────────── */
.astropvp_hist_wrap,
.astropvp_hist_wrap *,
.astropvp_hist_wrap *::before,
.astropvp_hist_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_hist_wrap {
    padding: 20px;
    color: #c8d6e5;
}

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_hist_title {
    color: #88bbff;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(100, 150, 255, 0.6);
    letter-spacing: 1px;
}

/* ─── 🆕 BALANCE BADGE (riel del jugador) ───────────────── */
.astropvp_balance_box {
    max-width: 900px;
    margin: 0 auto 18px;
    text-align: center;
}

.astropvp_balance_badge {
    display: inline-block;
    padding: 8px 20px;
    border-radius: 10px;
    font-size: 13px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    background: linear-gradient(135deg, rgba(0, 200, 100, 0.15), rgba(0, 150, 255, 0.10));
    color: #cbd5e1;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.astropvp_balance_badge b {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-weight: 800;
    letter-spacing: 0.5px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.4);
}

.astropvp_balance_badge .moneda {
    color: #88ddff;
    font-weight: 700;
    letter-spacing: 0.5px;
}

/* ─── TABS ──────────────────────────────────────────────── */
.astropvp_hist_tabs {
    max-width: 900px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_hist_tab {
    flex: 1;
    min-width: 120px;
    max-width: 160px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: bold;
    text-align: center;
    text-decoration: none;
    transition: 0.25s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    display: inline-block;
}
.astropvp_hist_tab:hover {
    transform: translateY(-2px);
}

.astropvp_hist_tab.main {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_hist_tab.main:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_hist_tab.arenas {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_hist_tab.arenas:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_hist_tab.tournaments {
    background: rgba(255, 200, 50, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(255, 200, 50, 0.5);
}
.astropvp_hist_tab.tournaments:hover {
    background: rgba(255, 200, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.4);
}

.astropvp_hist_tab.history {
    background: linear-gradient(135deg, #2244cc, #6688ff);
    color: #ffffff;
    border: 1px solid #6688ff;
    box-shadow: 0 4px 14px rgba(100, 150, 255, 0.5);
}
.astropvp_hist_tab.history:hover {
    box-shadow: 0 6px 20px rgba(100, 150, 255, 0.7);
}

.astropvp_hist_tab.achievements {
    background: rgba(255, 200, 50, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(255, 200, 50, 0.5);
}
.astropvp_hist_tab.achievements:hover {
    background: rgba(255, 200, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.4);
}

.astropvp_hist_tab.profile {
    background: rgba(200, 100, 255, 0.15);
    color: #dd99ff;
    border: 1px solid rgba(200, 100, 255, 0.5);
}
.astropvp_hist_tab.profile:hover {
    background: rgba(200, 100, 255, 0.25);
    box-shadow: 0 0 14px rgba(200, 100, 255, 0.4);
}

/* ─── PANELES ───────────────────────────────────────────── */
.astropvp_hist_panel {
    max-width: 900px;
    margin: 0 auto 25px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 100, 100, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_hist_panel.tourney {
    margin-bottom: 0;
    border-color: rgba(255, 200, 50, 0.4);
}

.astropvp_hist_panel_title {
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(0, 0, 0, 0.4);
}
.astropvp_hist_panel.arena .astropvp_hist_panel_title    { color: #ff8888; }
.astropvp_hist_panel.tourney .astropvp_hist_panel_title  { color: #ffdd88; }

/* ─── TABLAS ────────────────────────────────────────────── */
.astropvp_hist_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
}

.astropvp_hist_table thead tr {
    border-bottom: 1px solid rgba(255, 100, 100, 0.3);
}
.astropvp_hist_panel.tourney .astropvp_hist_table thead tr {
    border-bottom-color: rgba(255, 200, 50, 0.3);
}

.astropvp_hist_table th {
    padding: 8px;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_hist_panel.arena .astropvp_hist_table th    { color: #ff8888; }
.astropvp_hist_panel.tourney .astropvp_hist_table th  { color: #ffdd88; }

.astropvp_hist_table th.left    { text-align: left; }
.astropvp_hist_table th.center  { text-align: center; }
.astropvp_hist_table th.right   { text-align: right; }

.astropvp_hist_table tbody tr {
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    transition: 0.2s ease;
}
.astropvp_hist_table tbody tr:hover {
    background: rgba(255, 255, 255, 0.03);
}

.astropvp_hist_table td {
    padding: 10px 8px;
    font-size: 12px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    font-family: 'Courier New', monospace;
}
.astropvp_hist_table td.left    { text-align: left; }
.astropvp_hist_table td.center  { text-align: center; }
.astropvp_hist_table td.right   { text-align: right; }

.astropvp_hist_table td.id      { color: #c8d6e5; }
.astropvp_hist_table td.muted   { color: #aabbcc; }
.astropvp_hist_table td.winner  { color: #88ffbb; }
.astropvp_hist_table td.prize   { color: #ffee88; font-weight: bold; }
.astropvp_hist_table td.cancel  { color: #ff8888; font-style: italic; }

/* ─── EMPTY STATE ───────────────────────────────────────── */
.astropvp_hist_empty {
    text-align: center;
    color: #8899aa;
    font-size: 12px;
    padding: 20px 0;
    font-style: italic;
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_hist_panel {
        padding: 16px;
    }
}

@media (max-width: 720px) {
    .astropvp_hist_wrap {
        padding: 12px;
    }
    .astropvp_hist_title {
        font-size: 18px;
    }
    .astropvp_hist_tab {
        max-width: 100%;
        min-width: 100px;
        font-size: 11px;
        padding: 9px 12px;
    }
    .astropvp_hist_panel {
        padding: 12px;
        max-width: 100%;
    }
    .astropvp_hist_table th,
    .astropvp_hist_table td {
        padding: 6px 4px;
        font-size: 10px;
    }
    /* Ocultar columnas menos importantes en móvil */
    .astropvp_hist_table th.hide_mobile,
    .astropvp_hist_table td.hide_mobile {
        display: none;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_hist_wrap">
	<h1 class="astropvp_hist_title">
		📜 Historial PvP
	</h1>

	{* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
	<div class="astropvp_balance_box">
		<span class="astropvp_balance_badge">
			💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
			<span class="moneda">{$moneda}</span>
		</span>
	</div>

	{* MENÚ *}
	<div class="astropvp_hist_tabs">
		<a href="game.php?page=pvp" class="astropvp_hist_tab main">🏠 Panel</a>
		<a href="game.php?page=pvp&mode=arenas" class="astropvp_hist_tab arenas">🏟️ Arenas</a>
		<a href="game.php?page=pvp&mode=tournaments" class="astropvp_hist_tab tournaments">🏆 Torneos</a>
		<a href="game.php?page=pvp&mode=history" class="astropvp_hist_tab history">📜 Historial</a>
		<a href="game.php?page=pvp&mode=achievements" class="astropvp_hist_tab achievements">🏅 Logros</a>
		<a href="game.php?page=pvp&mode=profile" class="astropvp_hist_tab profile">👤 Perfil</a>
	</div>

	{* ÚLTIMAS ARENAS *}
	<div class="astropvp_hist_panel arena">
		<h2 class="astropvp_hist_panel_title">🏟️ Últimas 5 arenas</h2>

		{if $arena_history|@count > 0}
			<table class="astropvp_hist_table">
				<thead>
					<tr>
						<th class="left">Arena</th>
						<th class="center">Modo</th>
						<th class="center hide_mobile">Ganador</th>
						<th class="right">Bote</th>
					</tr>
				</thead>
				<tbody>
					{foreach $arena_history as $a}
						<tr>
							<td class="id left">
								#{$a.id}
								{if $a.status == 'cancelled'}<span class="cancel"> (cancelada)</span>{/if}
							</td>
							<td class="muted center">{$a.mode}</td>
							<td class="winner center hide_mobile">
								Equipo {$a.winner_team}
							</td>
							<td class="prize right">
								{if $es_internacional}
									{$a.pool_untx20|number_format} {$moneda}
								{else}
									{$a.pool_ntx20|number_format} {$moneda}
								{/if}
							</td>
						</tr>
					{/foreach}
				</tbody>
			</table>
		{else}
			<p class="astropvp_hist_empty">
				Aún no hay arenas finalizadas.
			</p>
		{/if}
	</div>

	{* ÚLTIMOS TORNEOS *}
	<div class="astropvp_hist_panel tourney">
		<h2 class="astropvp_hist_panel_title">🏆 Últimos 5 torneos</h2>

		{if $tourney_history|@count > 0}
			<table class="astropvp_hist_table">
				<thead>
					<tr>
						<th class="left">Torneo</th>
						<th class="center">Tipo</th>
						<th class="center hide_mobile">Modo</th>
						<th class="right">Bote</th>
					</tr>
				</thead>
				<tbody>
					{foreach $tourney_history as $t}
						<tr>
							<td class="id left">#{$t.id}</td>
							<td class="muted center">{$t.type}</td>
							<td class="muted center hide_mobile">{$t.mode}</td>
							<td class="prize right">
								{if $es_internacional}
									{$t.pool_untx20|number_format} {$moneda}
								{else}
									{$t.pool_ntx20|number_format} {$moneda}
								{/if}
							</td>
						</tr>
					{/foreach}
				</tbody>
			</table>
		{else}
			<p class="astropvp_hist_empty">
				Aún no hay torneos finalizados.
			</p>
		{/if}
	</div>
</div>
{/block}