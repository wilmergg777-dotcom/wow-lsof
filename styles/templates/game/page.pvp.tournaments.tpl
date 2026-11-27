{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pvp.tournaments.tpl === *}
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
   PvP — Torneos
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_tour_

   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Bote en el riel del jugador (pool_ntx20 vs pool_untx20)
     - Precios de entrada en el riel del jugador ($entry_fee_real / $alliance_entry_fee_real)
     - Saldo del banco con la moneda correcta ($alliance_bank_moneda)
     - Comparación banco vs fee en el mismo riel
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
.astropvp_tour_wrap,
.astropvp_tour_wrap *,
.astropvp_tour_wrap *::before,
.astropvp_tour_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_tour_wrap {
    padding: 20px;
    color: #c8d6e5;
}

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_tour_title {
    color: #ffdd88;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(251, 191, 36, 0.6);
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
.astropvp_tour_tabs {
    max-width: 900px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_tour_tab {
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
.astropvp_tour_tab:hover {
    transform: translateY(-2px);
}

.astropvp_tour_tab.main {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_tour_tab.main:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_tour_tab.arenas {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_tour_tab.arenas:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_tour_tab.tournaments {
    background: linear-gradient(135deg, #ccaa22, #ffdd88);
    color: #111111;
    border: 1px solid #ffdd88;
    box-shadow: 0 4px 14px rgba(255, 200, 50, 0.5);
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astropvp_tour_tab.tournaments:hover {
    box-shadow: 0 6px 20px rgba(255, 200, 50, 0.7);
}

.astropvp_tour_tab.history {
    background: rgba(100, 150, 255, 0.15);
    color: #88bbff;
    border: 1px solid rgba(100, 150, 255, 0.5);
}
.astropvp_tour_tab.history:hover {
    background: rgba(100, 150, 255, 0.25);
    box-shadow: 0 0 14px rgba(100, 150, 255, 0.4);
}

.astropvp_tour_tab.achievements {
    background: rgba(255, 200, 50, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(255, 200, 50, 0.5);
}
.astropvp_tour_tab.achievements:hover {
    background: rgba(255, 200, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.4);
}

.astropvp_tour_tab.profile {
    background: rgba(200, 100, 255, 0.15);
    color: #dd99ff;
    border: 1px solid rgba(200, 100, 255, 0.5);
}
.astropvp_tour_tab.profile:hover {
    background: rgba(200, 100, 255, 0.25);
    box-shadow: 0 0 14px rgba(200, 100, 255, 0.4);
}

/* ─── FLASH MESSAGE ─────────────────────────────────────── */
.astropvp_tour_flash {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 12px 18px;
    border-radius: 10px;
    text-align: center;
    font-size: 13px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropvp_tour_flash.success {
    background: rgba(0, 200, 100, 0.15);
    border: 1px solid rgba(0, 255, 130, 0.5);
    color: #88ffbb;
}
.astropvp_tour_flash.error {
    background: rgba(255, 50, 50, 0.15);
    border: 1px solid rgba(255, 100, 100, 0.5);
    color: #ff8888;
}

/* ─── PANEL INFO TORNEO ─────────────────────────────────── */
.astropvp_tour_info_panel {
    max-width: 900px;
    margin: 0 auto 20px;
    background: linear-gradient(160deg, rgba(60, 40, 10, 0.85) 0%, rgba(90, 60, 15, 0.85) 100%);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(255, 200, 50, 0.5);
    border-radius: 14px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_tour_info_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 15px;
}

.astropvp_tour_info_item {
    min-width: 0;
}

.astropvp_tour_info_label {
    font-size: 11px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.astropvp_tour_info_value {
    font-size: 18px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_tour_info_value.type      { color: #ffdd88; }
.astropvp_tour_info_value.mode      { color: #ffee88; }
.astropvp_tour_info_value.status    { color: #ffaa88; }
.astropvp_tour_info_value.players   { color: #88ffbb; }
.astropvp_tour_info_value.pool      { color: #ffee88; }
.astropvp_tour_info_value.comm      { color: #ff8888; }

/* ─── REGISTRO ──────────────────────────────────────────── */
.astropvp_tour_register_wrap {
    max-width: 900px;
    margin: 0 auto 20px;
    text-align: center;
}

.astropvp_tour_btn_register {
    padding: 14px 40px;
    background: linear-gradient(135deg, #ccaa22, #ffdd88);
    color: #111111;
    border: 1px solid #ffdd88;
    border-radius: 10px;
    font-size: 14px;
    font-weight: bold;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(255, 200, 50, 0.5);
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astropvp_tour_btn_register:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 200, 50, 0.7);
}

.astropvp_tour_notice {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 15px 20px;
    border-radius: 10px;
    text-align: center;
    font-size: 13px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropvp_tour_notice.success {
    background: rgba(0, 200, 100, 0.15);
    border: 1px solid rgba(0, 255, 130, 0.5);
    color: #88ffbb;
}

/* ─── REGISTRO ALIANZA ──────────────────────────────────── */
.astropvp_tour_ally_panel {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 20px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 200, 50, 0.4);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_tour_ally_title {
    color: #ffdd88;
    font-size: 14px;
    margin-bottom: 15px;
    text-align: center;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}

.astropvp_tour_ally_bank {
    text-align: center;
    font-size: 12px;
    color: #aabbcc;
    margin-bottom: 15px;
}
.astropvp_tour_ally_bank b {
    color: #ffee88;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

.astropvp_tour_ally_form {
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_tour_btn_bank {
    padding: 12px 25px;
    background: linear-gradient(135deg, #2244cc, #6688ff);
    color: #ffffff;
    border: 1px solid #6688ff;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_tour_btn_bank:hover {
    box-shadow: 0 0 14px rgba(102, 136, 255, 0.6);
    transform: translateY(-2px);
}

.astropvp_tour_btn_user {
    padding: 12px 25px;
    background: linear-gradient(135deg, #ccaa22, #ffdd88);
    color: #111111;
    border: 1px solid #ffdd88;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astropvp_tour_btn_user:hover {
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.6);
    transform: translateY(-2px);
}

/* ─── PARTICIPANTES ─────────────────────────────────────── */
.astropvp_tour_panel {
    max-width: 900px;
    margin: 0 auto 20px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 200, 50, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_tour_panel.blue {
    border-color: rgba(100, 150, 255, 0.4);
}

.astropvp_tour_panel_title {
    color: #ffdd88;
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
.astropvp_tour_panel.blue .astropvp_tour_panel_title {
    color: #88bbff;
    text-shadow: 0 0 10px rgba(100, 150, 255, 0.4);
}

.astropvp_tour_players_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 10px;
}

.astropvp_tour_player {
    padding: 10px;
    background: rgba(255, 200, 50, 0.06);
    border-radius: 8px;
    font-size: 12px;
    min-width: 0;
    overflow: hidden;
}
.astropvp_tour_player b {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    display: inline-block;
    max-width: 100%;
    vertical-align: middle;
}
.astropvp_tour_player b.ally {
    color: #88bbff;
}
.astropvp_tour_player b.user {
    color: #ffee88;
}

.astropvp_tour_badge {
    margin-left: 5px;
}
.astropvp_tour_badge.win    { color: #ffdd88; }
.astropvp_tour_badge.lose   { color: #ff6666; }

/* ─── BRACKET ───────────────────────────────────────────── */
.astropvp_tour_round {
    margin-bottom: 20px;
}

.astropvp_tour_round_title {
    font-size: 13px;
    color: #88bbff;
    font-weight: bold;
    margin-bottom: 10px;
    padding-bottom: 5px;
    border-bottom: 1px solid rgba(100, 150, 255, 0.3);
}

.astropvp_tour_match {
    padding: 10px;
    background: rgba(100, 150, 255, 0.06);
    border-radius: 8px;
    margin-bottom: 8px;
    font-size: 12px;
    border-left: 3px solid rgba(100, 150, 255, 0.4);
    transition: 0.25s ease;
}
.astropvp_tour_match:hover {
    background: rgba(100, 150, 255, 0.12);
    transform: translateX(2px);
}

.astropvp_tour_match_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}

.astropvp_tour_match_player {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_tour_match_player.winner { color: #88ffbb; }
.astropvp_tour_match_player.loser  { color: #aabbcc; }

.astropvp_tour_match_vs {
    color: #8899aa;
    font-size: 10px;
    flex-shrink: 0;
}

/* ─── EMPTY STATE ───────────────────────────────────────── */
.astropvp_tour_empty {
    max-width: 900px;
    margin: 0 auto;
    padding: 40px 20px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 200, 50, 0.4);
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_tour_empty_icon {
    font-size: 40px;
    margin-bottom: 15px;
}

.astropvp_tour_empty_title {
    font-size: 15px;
    color: #ffdd88;
    font-weight: bold;
    margin-bottom: 10px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}

.astropvp_tour_empty_text {
    font-size: 12px;
    color: #8899aa;
    line-height: 1.6;
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_tour_info_grid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
    }
    .astropvp_tour_players_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 720px) {
    .astropvp_tour_wrap {
        padding: 12px;
    }
    .astropvp_tour_title {
        font-size: 18px;
    }
    .astropvp_tour_tab {
        max-width: 100%;
        min-width: 100px;
        font-size: 11px;
        padding: 9px 12px;
    }
    .astropvp_tour_info_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px;
    }
    .astropvp_tour_info_value {
        font-size: 14px;
    }
    .astropvp_tour_players_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_tour_ally_form {
        flex-direction: column;
    }
    .astropvp_tour_btn_bank,
    .astropvp_tour_btn_user {
        width: 100%;
    }
    .astropvp_tour_btn_register {
        width: 100%;
        padding: 12px 20px;
    }
    .astropvp_tour_panel,
    .astropvp_tour_ally_panel,
    .astropvp_tour_info_panel {
        padding: 14px;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_tour_wrap">
	<h1 class="astropvp_tour_title">
		🏆 Torneos PvP
	</h1>

	{* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
	<div class="astropvp_balance_box">
		<span class="astropvp_balance_badge">
			💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
			<span class="moneda">{$moneda}</span>
		</span>
	</div>

	{* MENÚ *}
	<div class="astropvp_tour_tabs">
		<a href="game.php?page=pvp" class="astropvp_tour_tab main">🏠 Panel</a>
		<a href="game.php?page=pvp&mode=arenas" class="astropvp_tour_tab arenas">🏟️ Arenas</a>
		<a href="game.php?page=pvp&mode=tournaments" class="astropvp_tour_tab tournaments">🏆 Torneos</a>
		<a href="game.php?page=pvp&mode=history" class="astropvp_tour_tab history">📜 Historial</a>
		<a href="game.php?page=pvp&mode=achievements" class="astropvp_tour_tab achievements">🏅 Logros</a>
		<a href="game.php?page=pvp&mode=profile" class="astropvp_tour_tab profile">👤 Perfil</a>
	</div>

	{* FLASH *}
	{if $flash}
		<div class="astropvp_tour_flash {if $flash.type == 'success'}success{else}error{/if}">
			{$flash.msg}
		</div>
	{/if}

	{if $active_tournament}

		{* INFO DEL TORNEO *}
		<div class="astropvp_tour_info_panel">
			<div class="astropvp_tour_info_grid">
				<div class="astropvp_tour_info_item">
					<div class="astropvp_tour_info_label">Tipo</div>
					<div class="astropvp_tour_info_value type">{$active_tournament.type}</div>
				</div>
				<div class="astropvp_tour_info_item">
					<div class="astropvp_tour_info_label">Modo</div>
					<div class="astropvp_tour_info_value mode">{if $active_tournament.mode == 'double_elimination'}Doble oportunidad{else}Eliminación simple{/if}</div>
				</div>
				<div class="astropvp_tour_info_item">
					<div class="astropvp_tour_info_label">Estado</div>
					<div class="astropvp_tour_info_value status">{$active_tournament.status}</div>
				</div>
				<div class="astropvp_tour_info_item">
					<div class="astropvp_tour_info_label">Jugadores</div>
					<div class="astropvp_tour_info_value players">{$active_tournament.current_players}/{$active_tournament.max_players}</div>
				</div>
				<div class="astropvp_tour_info_item">
					<div class="astropvp_tour_info_label">Bote</div>
					<div class="astropvp_tour_info_value pool">
						{if $es_internacional}
							{$active_tournament.pool_untx20|number_format} {$moneda}
						{else}
							{$active_tournament.pool_ntx20|number_format} {$moneda}
						{/if}
					</div>
				</div>
				<div class="astropvp_tour_info_item">
					<div class="astropvp_tour_info_label">Comisión</div>
					<div class="astropvp_tour_info_value comm">{$active_tournament.commission_pct}%</div>
				</div>
			</div>
		</div>

		{* INSCRIPCIÓN *}
		{if $active_tournament.status == 'registration'}

			{if $can_register_1v1}
				<div class="astropvp_tour_register_wrap">
					<form method="POST" action="game.php?page=pvp&mode=registerTournament" style="display: inline;">
						<input type="hidden" name="tournament_id" value="{$active_tournament.id}">
						<button type="submit" class="astropvp_tour_btn_register">
							🎟️ Inscribirme ({$entry_fee_real|number_format} {$moneda})
						</button>
					</form>
				</div>
			{elseif $my_registration}
				<div class="astropvp_tour_notice success">
					✅ Ya estás inscrito en este torneo.
				</div>
			{/if}

			{if $can_register_ally}
				<div class="astropvp_tour_ally_panel">
					<h3 class="astropvp_tour_ally_title">
						🛡️ Inscribir mi alianza — {$alliance_entry_fee_real|number_format} {$moneda}
					</h3>
					<div class="astropvp_tour_ally_bank">
						Banco de mi alianza: <b>{$alliance_bank_ntx|number_format} {$alliance_bank_moneda}</b>
					</div>
					<form method="POST" action="game.php?page=pvp&mode=registerAlliance" class="astropvp_tour_ally_form">
						<input type="hidden" name="tournament_id" value="{$active_tournament.id}">

						{if $alliance_bank_ntx >= $alliance_entry_fee_real}
							<button type="submit" name="source" value="bank" class="astropvp_tour_btn_bank">
								🏦 Pagar del banco
							</button>
						{/if}

						<button type="submit" name="source" value="user" class="astropvp_tour_btn_user">
							👤 Pagar de mi cuenta
						</button>
					</form>
				</div>
			{elseif $my_alliance_reg}
				<div class="astropvp_tour_notice success">
					✅ Tu alianza ya está inscrita en este torneo.
				</div>
			{/if}

		{/if}

		{* JUGADORES INSCRITOS *}
		<div class="astropvp_tour_panel">
			<h2 class="astropvp_tour_panel_title">👥 Participantes ({$registered_players|@count})</h2>
			<div class="astropvp_tour_players_grid">
				{foreach $registered_players as $rp}
					<div class="astropvp_tour_player">
						{if $rp.is_alliance == 1}
							<b class="ally">🛡️ [{$rp.ally_tag}] {$rp.ally_name}</b>
						{else}
							<b class="user">⚔️ {$rp.username}</b>
						{/if}
						{if $rp.final_position > 0}
							<span class="astropvp_tour_badge win">🏆 #{$rp.final_position}</span>
						{/if}
						{if $rp.eliminated == 1}
							<span class="astropvp_tour_badge lose">❌</span>
						{/if}
					</div>
				{/foreach}
			</div>
		</div>

		{* BRACKET VISUAL *}
		{if $rounds|@count > 0}
			<div class="astropvp_tour_panel blue">
				<h2 class="astropvp_tour_panel_title">🎯 Bracket</h2>

				{foreach $rounds as $r}
					<div class="astropvp_tour_round">
						<div class="astropvp_tour_round_title">
							Ronda {$r.round_number} — {if $r.status == 'active'}🔴 En curso{elseif $r.status == 'finished'}✅ Terminada{else}⏳ Pendiente{/if}
						</div>

						{if isset($matches_by_round[$r.id])}
							{foreach $matches_by_round[$r.id] as $m}
								<div class="astropvp_tour_match">
									<div class="astropvp_tour_match_row">
										<span class="astropvp_tour_match_player {if $m.winner_id == $m.player1_id && $m.winner_id > 0}winner{else}loser{/if}">
											Player #{$m.player1_id}
										</span>
										<span class="astropvp_tour_match_vs">vs</span>
										<span class="astropvp_tour_match_player {if $m.winner_id == $m.player2_id && $m.winner_id > 0}winner{else}loser{/if}">
											Player #{$m.player2_id}
										</span>
									</div>
								</div>
							{/foreach}
						{/if}
					</div>
				{/foreach}
			</div>
		{/if}

	{else}
		<div class="astropvp_tour_empty">
			<div class="astropvp_tour_empty_icon">🏆</div>
			<div class="astropvp_tour_empty_title">No hay torneo activo</div>
			<div class="astropvp_tour_empty_text">
				El administrador programará un torneo próximamente.<br>
				Mantente atento a las notificaciones.
			</div>
		</div>
	{/if}

</div>
{/block}