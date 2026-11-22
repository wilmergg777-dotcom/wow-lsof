{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   PvP — Perfil + Ranking
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_prof_

   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Labels "NTX ganados/perdidos" → "{$moneda} ganados/perdidos"
     - Ranking muestra columna de saldo (cada fila en su riel)
     - CSS preservado 100% + estilos para balance badge y columna saldo
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
.astropvp_prof_wrap,
.astropvp_prof_wrap *,
.astropvp_prof_wrap *::before,
.astropvp_prof_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_prof_wrap {
    padding: 20px;
    color: #c8d6e5;
}

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_prof_title {
    color: #dd99ff;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(200, 100, 255, 0.6);
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
.astropvp_prof_tabs {
    max-width: 900px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_prof_tab {
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
.astropvp_prof_tab:hover {
    transform: translateY(-2px);
}

.astropvp_prof_tab.main {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_prof_tab.main:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_prof_tab.arenas {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_prof_tab.arenas:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_prof_tab.tournaments {
    background: rgba(255, 200, 50, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(255, 200, 50, 0.5);
}
.astropvp_prof_tab.tournaments:hover {
    background: rgba(255, 200, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.4);
}

.astropvp_prof_tab.history {
    background: rgba(100, 150, 255, 0.15);
    color: #88bbff;
    border: 1px solid rgba(100, 150, 255, 0.5);
}
.astropvp_prof_tab.history:hover {
    background: rgba(100, 150, 255, 0.25);
    box-shadow: 0 0 14px rgba(100, 150, 255, 0.4);
}

.astropvp_prof_tab.achievements {
    background: rgba(255, 200, 50, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(255, 200, 50, 0.5);
}
.astropvp_prof_tab.achievements:hover {
    background: rgba(255, 200, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.4);
}

.astropvp_prof_tab.profile {
    background: linear-gradient(135deg, #aa44ff, #dd88ff);
    color: #ffffff;
    border: 1px solid #dd88ff;
    box-shadow: 0 4px 14px rgba(170, 50, 255, 0.5);
}
.astropvp_prof_tab.profile:hover {
    box-shadow: 0 6px 20px rgba(170, 50, 255, 0.7);
}

/* ─── PANEL BASE ────────────────────────────────────────── */
.astropvp_prof_panel {
    max-width: 900px;
    margin: 0 auto 25px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(200, 100, 255, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_prof_panel.ranking {
    margin-bottom: 0;
    border-color: rgba(255, 200, 50, 0.4);
}

.astropvp_prof_panel_title {
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(0, 0, 0, 0.4);
}
.astropvp_prof_panel.stats .astropvp_prof_panel_title    { color: #dd99ff; }
.astropvp_prof_panel.ranking .astropvp_prof_panel_title  { color: #ffdd88; }

/* ─── STATS GRID ────────────────────────────────────────── */
.astropvp_prof_stats_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 12px;
}

.astropvp_prof_stat {
    padding: 12px;
    border-radius: 8px;
    text-align: center;
    transition: 0.25s ease;
    min-width: 0;
    overflow: hidden;
}
.astropvp_prof_stat:hover {
    transform: translateY(-2px);
}

.astropvp_prof_stat.points       { background: rgba(255, 100, 100, 0.08); }
.astropvp_prof_stat.wins         { background: rgba(0, 200, 100, 0.08); }
.astropvp_prof_stat.losses       { background: rgba(255, 50, 50, 0.08); }
.astropvp_prof_stat.ntx_won      { background: rgba(255, 200, 50, 0.08); }
.astropvp_prof_stat.ntx_lost     { background: rgba(255, 150, 50, 0.08); }
.astropvp_prof_stat.tournaments  { background: rgba(100, 150, 255, 0.08); }
.astropvp_prof_stat.streak       { background: rgba(200, 100, 255, 0.08); }

.astropvp_prof_stat_label {
    font-size: 11px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.astropvp_prof_stat_value {
    font-size: 22px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_prof_stat.points .astropvp_prof_stat_value       { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.astropvp_prof_stat.wins .astropvp_prof_stat_value         { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.4); }
.astropvp_prof_stat.losses .astropvp_prof_stat_value       { color: #ff6666; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.astropvp_prof_stat.ntx_won .astropvp_prof_stat_value      { color: #ffee88; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }
.astropvp_prof_stat.ntx_lost .astropvp_prof_stat_value     { color: #ffaa88; text-shadow: 0 0 8px rgba(255, 150, 50, 0.4); }
.astropvp_prof_stat.tournaments .astropvp_prof_stat_value  { color: #88bbff; text-shadow: 0 0 8px rgba(100, 150, 255, 0.4); }
.astropvp_prof_stat.streak .astropvp_prof_stat_value       { color: #dd99ff; text-shadow: 0 0 8px rgba(200, 100, 255, 0.4); }

/* ─── SECCIÓN ARENAS POR MODALIDAD ──────────────────────── */
.astropvp_prof_arena_section {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.astropvp_prof_arena_title {
    color: #ffdd88;
    font-size: 13px;
    margin-bottom: 10px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

.astropvp_prof_arena_grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 10px;
}

.astropvp_prof_arena_item {
    text-align: center;
    padding: 10px;
    border-radius: 8px;
    transition: 0.25s ease;
    min-width: 0;
}
.astropvp_prof_arena_item:hover {
    transform: translateY(-2px);
}

.astropvp_prof_arena_item.mode_1v1 { background: rgba(255, 100, 100, 0.06); }
.astropvp_prof_arena_item.mode_2v2 { background: rgba(255, 150, 100, 0.06); }
.astropvp_prof_arena_item.mode_3v3 { background: rgba(255, 200, 100, 0.06); }

.astropvp_prof_arena_label {
    font-size: 11px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astropvp_prof_arena_value {
    font-size: 20px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_prof_arena_item.mode_1v1 .astropvp_prof_arena_value { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.astropvp_prof_arena_item.mode_2v2 .astropvp_prof_arena_value { color: #ffaa88; text-shadow: 0 0 8px rgba(255, 150, 100, 0.4); }
.astropvp_prof_arena_item.mode_3v3 .astropvp_prof_arena_value { color: #ffcc88; text-shadow: 0 0 8px rgba(255, 200, 100, 0.4); }

/* ─── TABLA RANKING ─────────────────────────────────────── */
.astropvp_prof_table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
}

.astropvp_prof_table thead tr {
    border-bottom: 1px solid rgba(255, 200, 50, 0.3);
}

.astropvp_prof_table th {
    padding: 8px;
    font-size: 11px;
    color: #ffdd88;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_prof_table th.center { text-align: center; }
.astropvp_prof_table th.left   { text-align: left; }
.astropvp_prof_table th.right  { text-align: right; }

.astropvp_prof_table th.col_pos     { width: 60px; }
.astropvp_prof_table th.col_points  { width: 100px; }
/* 🆕 Columna saldo */
.astropvp_prof_table th.col_saldo   { width: 160px; }

.astropvp_prof_table tbody tr {
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    transition: 0.2s ease;
}
.astropvp_prof_table tbody tr:hover {
    background: rgba(255, 255, 255, 0.03);
}

.astropvp_prof_table td {
    padding: 10px 8px;
    font-size: 12px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

/* Columna posición */
.astropvp_prof_pos {
    text-align: center;
    font-size: 14px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astropvp_prof_pos.pos-1 { color: #ffd700; text-shadow: 0 0 8px rgba(255, 215, 0, 0.5); }
.astropvp_prof_pos.pos-2 { color: #c0c0c0; text-shadow: 0 0 8px rgba(192, 192, 192, 0.5); }
.astropvp_prof_pos.pos-3 { color: #cd7f32; text-shadow: 0 0 8px rgba(205, 127, 50, 0.5); }
.astropvp_prof_pos.pos-other { color: #8899aa; }

/* Columna jugador */
.astropvp_prof_username {
    color: #c8d6e5;
    font-size: 12px;
}

/* Columna puntos */
.astropvp_prof_points {
    text-align: center;
    color: #ff8888;
    font-size: 13px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}

/* 🆕 Columna saldo del riel de cada jugador */
.astropvp_prof_saldo {
    text-align: right;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    font-size: 12px;
    color: #88ffbb;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.3);
}
.astropvp_prof_saldo .prof_moneda {
    color: #88ddff;
    font-weight: 700;
    font-size: 11px;
    margin-left: 3px;
    text-shadow: none;
}

/* ─── EMPTY STATE ───────────────────────────────────────── */
.astropvp_prof_empty {
    text-align: center;
    color: #8899aa;
    font-size: 12px;
    padding: 20px 0;
    font-style: italic;
}

/* ─── FOOTER ────────────────────────────────────────────── */
.astropvp_prof_footer {
    text-align: center;
    font-size: 11px;
    color: #8899aa;
    margin-top: 30px;
    line-height: 1.6;
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_prof_panel {
        padding: 16px;
    }
    .astropvp_prof_table th.col_saldo { width: 140px; }
}

@media (max-width: 720px) {
    .astropvp_prof_wrap {
        padding: 12px;
    }
    .astropvp_prof_title {
        font-size: 18px;
    }
    .astropvp_prof_tab {
        max-width: 100%;
        min-width: 100px;
        font-size: 11px;
        padding: 9px 12px;
    }
    .astropvp_prof_panel {
        padding: 12px;
        max-width: 100%;
    }
    .astropvp_prof_stats_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 8px;
    }
    .astropvp_prof_stat_value {
        font-size: 16px;
    }
    .astropvp_prof_arena_grid {
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 6px;
    }
    .astropvp_prof_arena_value {
        font-size: 15px;
    }
    .astropvp_prof_table th,
    .astropvp_prof_table td {
        padding: 6px 4px;
        font-size: 10px;
    }
    .astropvp_prof_pos {
        font-size: 12px;
    }
    .astropvp_prof_points {
        font-size: 11px;
    }
    /* 🆕 Ocultar saldo en móvil para que no se amontone */
    .astropvp_prof_table th.col_saldo,
    .astropvp_prof_table td.astropvp_prof_saldo {
        display: none;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_prof_wrap">
	<h1 class="astropvp_prof_title">
		👤 Perfil y Ranking PvP
	</h1>

	{* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
	<div class="astropvp_balance_box">
		<span class="astropvp_balance_badge">
			💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
			<span class="moneda">{$moneda}</span>
		</span>
	</div>

	{* MENÚ *}
	<div class="astropvp_prof_tabs">
		<a href="game.php?page=pvp" class="astropvp_prof_tab main">🏠 Panel</a>
		<a href="game.php?page=pvp&mode=arenas" class="astropvp_prof_tab arenas">🏟️ Arenas</a>
		<a href="game.php?page=pvp&mode=tournaments" class="astropvp_prof_tab tournaments">🏆 Torneos</a>
		<a href="game.php?page=pvp&mode=history" class="astropvp_prof_tab history">📜 Historial</a>
		<a href="game.php?page=pvp&mode=achievements" class="astropvp_prof_tab achievements">🏅 Logros</a>
		<a href="game.php?page=pvp&mode=profile" class="astropvp_prof_tab profile">👤 Perfil</a>
	</div>

	{* MIS ESTADÍSTICAS *}
	<div class="astropvp_prof_panel stats">
		<h2 class="astropvp_prof_panel_title">📊 Mis estadísticas</h2>

		<div class="astropvp_prof_stats_grid">

			<div class="astropvp_prof_stat points">
				<div class="astropvp_prof_stat_label">Puntos PvP</div>
				<div class="astropvp_prof_stat_value">{$my_stats.points}</div>
			</div>

			<div class="astropvp_prof_stat wins">
				<div class="astropvp_prof_stat_label">Victorias</div>
				<div class="astropvp_prof_stat_value">{$my_stats.wins}</div>
			</div>

			<div class="astropvp_prof_stat losses">
				<div class="astropvp_prof_stat_label">Derrotas</div>
				<div class="astropvp_prof_stat_value">{$my_stats.losses}</div>
			</div>

			<div class="astropvp_prof_stat ntx_won">
				<div class="astropvp_prof_stat_label">{$moneda} ganados</div>
				<div class="astropvp_prof_stat_value">{$my_stats.ntx_won|number_format}</div>
			</div>

			<div class="astropvp_prof_stat ntx_lost">
				<div class="astropvp_prof_stat_label">{$moneda} perdidos</div>
				<div class="astropvp_prof_stat_value">{$my_stats.ntx_lost|number_format}</div>
			</div>

			<div class="astropvp_prof_stat tournaments">
				<div class="astropvp_prof_stat_label">Torneos ganados</div>
				<div class="astropvp_prof_stat_value">{$my_stats.tournaments_won}</div>
			</div>

			<div class="astropvp_prof_stat streak">
				<div class="astropvp_prof_stat_label">Mejor racha</div>
				<div class="astropvp_prof_stat_value">{$my_stats.best_streak}</div>
			</div>

		</div>

		<div class="astropvp_prof_arena_section">
			<h3 class="astropvp_prof_arena_title">🏟️ Victorias en arenas por modalidad</h3>
			<div class="astropvp_prof_arena_grid">
				<div class="astropvp_prof_arena_item mode_1v1">
					<div class="astropvp_prof_arena_label">1v1</div>
					<div class="astropvp_prof_arena_value">{$my_stats.arena_wins_1v1}</div>
				</div>
				<div class="astropvp_prof_arena_item mode_2v2">
					<div class="astropvp_prof_arena_label">2v2</div>
					<div class="astropvp_prof_arena_value">{$my_stats.arena_wins_2v2}</div>
				</div>
				<div class="astropvp_prof_arena_item mode_3v3">
					<div class="astropvp_prof_arena_label">3v3</div>
					<div class="astropvp_prof_arena_value">{$my_stats.arena_wins_3v3}</div>
				</div>
			</div>
		</div>
	</div>

	{* RANKING *}
	<div class="astropvp_prof_panel ranking">
		<h2 class="astropvp_prof_panel_title">🏆 Ranking PvP (Top 25)</h2>

		{if $ranking|@count > 0}
			<table class="astropvp_prof_table">
				<thead>
					<tr>
						<th class="center col_pos">#</th>
						<th class="left">Jugador</th>
						<th class="center col_points">Puntos</th>
						<th class="right col_saldo">Saldo</th>
					</tr>
				</thead>
				<tbody>
					{foreach $ranking as $r}
						<tr>
							<td class="astropvp_prof_pos {if $r.position == 1}pos-1{elseif $r.position == 2}pos-2{elseif $r.position == 3}pos-3{else}pos-other{/if}">
								{if $r.position == 1}🥇{elseif $r.position == 2}🥈{elseif $r.position == 3}🥉{else}{$r.position}{/if}
							</td>
							<td class="astropvp_prof_username">
								{$r.username}
							</td>
							<td class="astropvp_prof_points">
								{$r.pvp_points}
							</td>
							<td class="astropvp_prof_saldo">
								{$r.saldo_riel|number_format}<span class="prof_moneda">{$r.moneda}</span>
							</td>
						</tr>
					{/foreach}
				</tbody>
			</table>
		{else}
			<p class="astropvp_prof_empty">
				Aún no hay jugadores en el ranking.
			</p>
		{/if}
	</div>

	<p class="astropvp_prof_footer">
		👤 Puntos: +1 por victoria en arena · +1 por ronda de torneo · +5 por ganar torneo
	</p>
</div>
{/block}