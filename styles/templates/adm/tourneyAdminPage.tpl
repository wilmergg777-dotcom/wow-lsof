{include file="overall_header.tpl"}

<style>
/* ============================================================== */
/* ====== ASTROIO ADMIN — Mini Torneos v1.1 ===================== */
/* Prefijo: .trn_  |  Acento: 🏆 Dorado + Cyan                   */
/* Estilo: glassmorphism, idéntico a PvP/PvE admin               */
/* ============================================================== */

:root {
	--trn-bg-card:       rgba(15, 23, 42, 0.75);
	--trn-bg-inner:      rgba(0, 0, 0, 0.35);
	--trn-border:        rgba(0, 224, 255, 0.2);
	--trn-text-main:     #cbd5e1;
	--trn-text-muted:    #94a3b8;
	--trn-text-title:    #ffffff;
	--trn-accent-cyan:   #00e0ff;
	--trn-accent-gold:   #fbbf24;
	--trn-accent-green:  #4aff88;
	--trn-accent-red:    #ef4444;
	--trn-accent-purple: #8b5cf6;
}

.trn_wrap {
	background: transparent !important;
	color: var(--trn-text-main) !important;
	padding: 12px 14px 40px 14px !important;
	font-family: 'Segoe UI', Tahoma, sans-serif !important;
	max-width: 1280px !important;
	margin: 0 auto !important;
}

.trn_title {
	text-align: center !important;
	margin: 6px 0 18px 0 !important;
	color: var(--trn-text-title) !important;
	font-size: 22px !important;
	font-weight: 800 !important;
	text-transform: uppercase !important;
	letter-spacing: 2px !important;
	text-shadow: 0 0 14px rgba(0, 224, 255, 0.6), 0 0 4px rgba(251, 191, 36, 0.5) !important;
}
.trn_title i { color: var(--trn-accent-gold) !important; margin-right: 8px !important; }

/* ============ TABS ============ */
.trn_tabs {
	display: flex !important;
	flex-wrap: wrap !important;
	gap: 6px !important;
	margin-bottom: 16px !important;
	justify-content: center !important;
}
.trn_tab {
	display: inline-block !important;
	padding: 9px 18px !important;
	background: rgba(15, 23, 42, 0.7) !important;
	border: 1px solid var(--trn-border) !important;
	border-radius: 10px !important;
	color: var(--trn-accent-cyan) !important;
	font-size: 12px !important;
	font-weight: 700 !important;
	text-decoration: none !important;
	text-transform: uppercase !important;
	letter-spacing: 0.8px !important;
	transition: all 0.25s ease !important;
	cursor: pointer !important;
}
.trn_tab:hover {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9)) !important;
	color: #fff !important;
	box-shadow: 0 0 14px rgba(0, 224, 255, 0.5) !important;
	transform: translateY(-1px) !important;
}
.trn_tab.active {
	background: linear-gradient(135deg, rgba(0, 102, 204, 1), rgba(0, 224, 255, 1)) !important;
	color: #001a26 !important;
	box-shadow: 0 0 18px rgba(0, 224, 255, 0.7) !important;
	border-color: var(--trn-accent-cyan) !important;
}

/* ============ CARDS ============ */
.trn_card {
	background: var(--trn-bg-card) !important;
	backdrop-filter: blur(8px) !important;
	-webkit-backdrop-filter: blur(8px) !important;
	border: 1px solid var(--trn-border) !important;
	border-radius: 12px !important;
	padding: 16px 18px !important;
	margin-bottom: 14px !important;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.55) !important;
}
.trn_card h3 {
	margin: 0 0 12px 0 !important;
	color: var(--trn-text-title) !important;
	font-size: 15px !important;
	font-weight: 700 !important;
	text-transform: uppercase !important;
	letter-spacing: 1px !important;
	border-bottom: 2px solid rgba(0, 224, 255, 0.35) !important;
	padding-bottom: 8px !important;
}
.trn_card h3 i { color: var(--trn-accent-gold) !important; margin-right: 6px !important; }

/* ============ MENSAJES ============ */
.trn_msg {
	padding: 12px 16px !important;
	border-radius: 10px !important;
	margin-bottom: 14px !important;
	font-size: 13px !important;
	font-weight: 600 !important;
}
.trn_msg.success {
	background: rgba(74, 255, 136, 0.15) !important;
	border: 1px solid rgba(74, 255, 136, 0.5) !important;
	color: var(--trn-accent-green) !important;
}
.trn_msg.error {
	background: rgba(239, 68, 68, 0.15) !important;
	border: 1px solid rgba(239, 68, 68, 0.5) !important;
	color: var(--trn-accent-red) !important;
}
.trn_msg.info {
	background: rgba(0, 224, 255, 0.12) !important;
	border: 1px solid rgba(0, 224, 255, 0.4) !important;
	color: var(--trn-accent-cyan) !important;
}

/* ============ STATS GRID ============ */
.trn_stats {
	display: grid !important;
	grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)) !important;
	gap: 12px !important;
	margin-bottom: 16px !important;
}
.trn_stat_box {
	background: var(--trn-bg-inner) !important;
	border: 1px solid var(--trn-border) !important;
	border-radius: 10px !important;
	padding: 14px !important;
	text-align: center !important;
	transition: all 0.25s ease !important;
}
.trn_stat_box:hover {
	border-color: var(--trn-accent-cyan) !important;
	box-shadow: 0 0 14px rgba(0, 224, 255, 0.35) !important;
	transform: translateY(-2px) !important;
}
.trn_stat_label {
	font-size: 10px !important;
	color: var(--trn-text-muted) !important;
	text-transform: uppercase !important;
	letter-spacing: 1px !important;
	margin-bottom: 6px !important;
}
.trn_stat_value {
	font-size: 22px !important;
	font-weight: 800 !important;
	color: var(--trn-accent-cyan) !important;
	text-shadow: 0 0 8px rgba(0, 224, 255, 0.4) !important;
}
.trn_stat_value.gold { color: var(--trn-accent-gold) !important; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4) !important; }
.trn_stat_value.green { color: var(--trn-accent-green) !important; text-shadow: 0 0 8px rgba(74, 255, 136, 0.4) !important; }
.trn_stat_value.red { color: var(--trn-accent-red) !important; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4) !important; }

/* ============ TABLA ============ */
.trn_table {
	width: 100% !important;
	border-collapse: collapse !important;
	font-size: 12px !important;
}
.trn_table th {
	background: rgba(0, 102, 204, 0.35) !important;
	color: var(--trn-accent-cyan) !important;
	text-transform: uppercase !important;
	letter-spacing: 0.8px !important;
	font-size: 10px !important;
	padding: 9px 10px !important;
	text-align: left !important;
	border-bottom: 2px solid rgba(0, 224, 255, 0.4) !important;
}
.trn_table td {
	padding: 9px 10px !important;
	border-bottom: 1px solid rgba(255, 255, 255, 0.06) !important;
	color: var(--trn-text-main) !important;
}
.trn_table tr:hover td {
	background: rgba(0, 224, 255, 0.08) !important;
}
.trn_table .highlight {
	color: var(--trn-accent-gold) !important;
	font-weight: 700 !important;
}
.trn_table .rank1 { color: #ffd700 !important; font-weight: 800 !important; }
.trn_table .rank2 { color: #c0c0c0 !important; font-weight: 700 !important; }
.trn_table .rank3 { color: #cd7f32 !important; font-weight: 700 !important; }

/* ============ TORNEO CARD ============ */
.trn_tourney {
	background: var(--trn-bg-inner) !important;
	border: 1px solid var(--trn-border) !important;
	border-left: 4px solid var(--trn-accent-gold) !important;
	border-radius: 10px !important;
	padding: 14px 16px !important;
	margin-bottom: 12px !important;
}
.trn_tourney_name {
	color: var(--trn-accent-gold) !important;
	font-size: 15px !important;
	font-weight: 800 !important;
	text-transform: uppercase !important;
	letter-spacing: 1px !important;
	margin-bottom: 4px !important;
}
.trn_tourney_meta {
	color: var(--trn-text-muted) !important;
	font-size: 11px !important;
	margin-bottom: 8px !important;
}
.trn_tourney_prizes {
	display: flex !important;
	flex-wrap: wrap !important;
	gap: 8px !important;
	margin-bottom: 10px !important;
}
.trn_prize {
	background: rgba(251, 191, 36, 0.12) !important;
	border: 1px solid rgba(251, 191, 36, 0.4) !important;
	border-radius: 6px !important;
	padding: 4px 10px !important;
	color: var(--trn-accent-gold) !important;
	font-size: 11px !important;
	font-weight: 700 !important;
}

/* ============ BOTONES ============ */
.trn_btn {
	display: inline-block !important;
	padding: 9px 18px !important;
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.85), rgba(0, 153, 255, 0.85)) !important;
	color: #fff !important;
	border: 1px solid var(--trn-accent-cyan) !important;
	border-radius: 8px !important;
	font-size: 12px !important;
	font-weight: 700 !important;
	text-decoration: none !important;
	text-transform: uppercase !important;
	letter-spacing: 0.8px !important;
	cursor: pointer !important;
	transition: all 0.25s ease !important;
}
.trn_btn:hover {
	background: linear-gradient(135deg, rgba(0, 153, 255, 1), rgba(0, 224, 255, 1)) !important;
	box-shadow: 0 0 16px rgba(0, 224, 255, 0.6) !important;
	transform: translateY(-1px) !important;
}
.trn_btn.danger {
	background: linear-gradient(135deg, rgba(139, 0, 0, 0.85), rgba(220, 38, 38, 0.85)) !important;
	border-color: var(--trn-accent-red) !important;
}
.trn_btn.danger:hover {
	background: linear-gradient(135deg, rgba(220, 38, 38, 1), rgba(239, 68, 68, 1)) !important;
	box-shadow: 0 0 16px rgba(239, 68, 68, 0.6) !important;
}
.trn_btn.gold {
	background: linear-gradient(135deg, rgba(180, 130, 0, 0.9), rgba(251, 191, 36, 0.9)) !important;
	border-color: var(--trn-accent-gold) !important;
	color: #1a1200 !important;
}
.trn_btn.gold:hover {
	background: linear-gradient(135deg, rgba(251, 191, 36, 1), rgba(255, 220, 80, 1)) !important;
	box-shadow: 0 0 16px rgba(251, 191, 36, 0.7) !important;
}

/* ============ TOGGLE ============ */
.trn_toggle_row {
	display: flex !important;
	align-items: center !important;
	justify-content: space-between !important;
	padding: 14px 18px !important;
	background: var(--trn-bg-inner) !important;
	border: 1px solid var(--trn-border) !important;
	border-radius: 10px !important;
	margin-bottom: 12px !important;
}
.trn_toggle_label {
	font-size: 14px !important;
	font-weight: 700 !important;
	color: var(--trn-text-title) !important;
}
.trn_toggle_status {
	font-size: 12px !important;
	font-weight: 800 !important;
	letter-spacing: 1px !important;
	padding: 5px 12px !important;
	border-radius: 6px !important;
}
.trn_toggle_status.on {
	background: rgba(74, 255, 136, 0.15) !important;
	color: var(--trn-accent-green) !important;
	border: 1px solid rgba(74, 255, 136, 0.5) !important;
}
.trn_toggle_status.off {
	background: rgba(239, 68, 68, 0.15) !important;
	color: var(--trn-accent-red) !important;
	border: 1px solid rgba(239, 68, 68, 0.5) !important;
}

/* ============ FORM ============ */
.trn_form_row {
	display: flex !important;
	align-items: center !important;
	gap: 12px !important;
	margin-bottom: 12px !important;
	flex-wrap: wrap !important;
}
.trn_form_row label {
	color: var(--trn-text-muted) !important;
	font-size: 12px !important;
	font-weight: 700 !important;
	text-transform: uppercase !important;
	letter-spacing: 0.8px !important;
	min-width: 130px !important;
}
.trn_input {
	background: rgba(0, 0, 0, 0.4) !important;
	border: 1px solid var(--trn-border) !important;
	border-radius: 6px !important;
	padding: 8px 12px !important;
	color: var(--trn-accent-cyan) !important;
	font-size: 13px !important;
	font-weight: 600 !important;
	min-width: 100px !important;
}
.trn_input:focus {
	outline: none !important;
	border-color: var(--trn-accent-cyan) !important;
	box-shadow: 0 0 10px rgba(0, 224, 255, 0.4) !important;
}

/* ============ EMPTY ============ */
.trn_empty {
	text-align: center !important;
	padding: 24px !important;
	color: var(--trn-text-muted) !important;
	font-style: italic !important;
	font-size: 13px !important;
}
</style>

<div class="trn_wrap">

	<div class="trn_title"><i>🏆</i> ADMIN — MINI TORNEOS <i>🏆</i></div>

	{* ═══════════════════════════════════════════════════════ *}
	{* MENSAJES                                                 *}
	{* ═══════════════════════════════════════════════════════ *}
	{if $message}
		<div class="trn_msg {$msgType}">{$message}</div>
	{/if}

	{* ═══════════════════════════════════════════════════════ *}
	{* TABS                                                     *}
	{* ═══════════════════════════════════════════════════════ *}
	<div class="trn_tabs">
		<a href="?page=tourneyadmin&amp;tab=dashboard" class="trn_tab {if $active_tab == 'dashboard'}active{/if}">📊 Dashboard</a>
		<a href="?page=tourneyadmin&amp;tab=tourneys"  class="trn_tab {if $active_tab == 'tourneys'}active{/if}">🏆 Torneos Activos</a>
		<a href="?page=tourneyadmin&amp;tab=history"   class="trn_tab {if $active_tab == 'history'}active{/if}">📜 Historial</a>
		<a href="?page=tourneyadmin&amp;tab=actions"   class="trn_tab {if $active_tab == 'actions'}active{/if}">⚙️ Acciones</a>
	</div>

{* ═══════════════════════════════════════════════════════════ *}
{* TAB 1 — DASHBOARD                                          *}
{* ═══════════════════════════════════════════════════════════ *}
{if $active_tab == 'dashboard'}

	{* Stats *}
	<div class="trn_stats">
		<div class="trn_stat_box">
			<div class="trn_stat_label">Torneos Activos</div>
			<div class="trn_stat_value gold">{$stats.total_tourneys}</div>
		</div>
		<div class="trn_stat_box">
			<div class="trn_stat_label">Jugadores Inscritos</div>
			<div class="trn_stat_value">{$stats.total_players}</div>
		</div>
		<div class="trn_stat_box">
			<div class="trn_stat_label">Registros de Historial</div>
			<div class="trn_stat_value">{$stats.total_history}</div>
		</div>
		<div class="trn_stat_box">
			<div class="trn_stat_label">Estado del Ciclo</div>
			<div class="trn_stat_value {if $cycle_info.is_active}green{else}red{/if}">
				{if $cycle_info.is_active}ACTIVO{else}INACTIVO{/if}
			</div>
		</div>
	</div>

	{* Estado del ciclo *}
	<div class="trn_card">
		<h3><i>⏱️</i> Estado del Ciclo Actual</h3>
		<div class="trn_stats">
			<div class="trn_stat_box">
				<div class="trn_stat_label">Fin del Ciclo</div>
				<div class="trn_stat_value" style="font-size:14px;">{$cycle_info.tourney_end_fmt}</div>
			</div>
			<div class="trn_stat_box">
				<div class="trn_stat_label">Tiempo Restante</div>
				<div class="trn_stat_value gold" style="font-size:14px;">{$cycle_info.remaining_fmt}</div>
			</div>
		</div>
	</div>

	{* Toggle del módulo *}
	<div class="trn_card">
		<h3><i>🔌</i> Estado del Módulo</h3>
		<div class="trn_toggle_row">
			<div class="trn_toggle_label">
				Mini Torneos (rotativos cada 7 días)
			</div>
			<div class="trn_toggle_status {if $cycle_info.module_enabled}on{else}off{/if}">
				{if $cycle_info.module_enabled}✅ ACTIVADO{else}⏸️ DESACTIVADO{/if}
			</div>
		</div>
		<form method="post" action="?page=tourneyadmin&amp;mode=saveConfig">
			<input type="hidden" name="tourney_enabled" value="{if $cycle_info.module_enabled}0{else}1{/if}">
			<button type="submit" class="trn_btn {if $cycle_info.module_enabled}danger{else}gold{/if}">
				{if $cycle_info.module_enabled}⏸️ Desactivar Módulo{else}✅ Activar Módulo{/if}
			</button>
		</form>
	</div>

{/if}

{* ═══════════════════════════════════════════════════════════ *}
{* TAB 2 — TORNEOS ACTIVOS                                    *}
{* ═══════════════════════════════════════════════════════════ *}
{if $active_tab == 'tourneys'}

	<div class="trn_card">
		<h3><i>🏆</i> Torneos Activos ({$stats.total_tourneys})</h3>

		{if $tourneys|@count == 0}
			<div class="trn_empty">📭 No hay torneos activos actualmente. El cronjob los sorteará en el próximo ciclo.</div>
		{else}
			{foreach $tourneys as $t}
				<div class="trn_tourney">
					<div class="trn_tourney_name">{$t.tourneyName} — {$t.event_label}</div>
					<div class="trn_tourney_meta">
						ID interno: #{$t.tourneyId} ·
						Evento: #{$t.tourneyEvent} ·
						Jugadores: {if $t.top3|@count > 0}{$t.top3|@count}{else}0{/if}
					</div>

					{* Premios *}
					<div class="trn_tourney_prizes">
						<span class="trn_prize">🥇 1º: {$t.priceOne_fmt} MO</span>
						<span class="trn_prize">🥈 2º: {$t.priceTwo_fmt} MO</span>
						<span class="trn_prize">🥉 3º: {$t.priceThree_fmt} MO</span>
					</div>

					{* Top 3 *}
					{if $t.top3|@count > 0}
						<table class="trn_table">
							<thead>
								<tr>
									<th style="width:50px;">#</th>
									<th>Jugador</th>
									<th style="text-align:right;">Puntos</th>
								</tr>
							</thead>
							<tbody>
								{foreach $t.top3 as $p name=top3loop}
									<tr>
										<td>
											{if $smarty.foreach.top3loop.index == 0}<span class="rank1">🥇 1</span>
											{elseif $smarty.foreach.top3loop.index == 1}<span class="rank2">🥈 2</span>
											{elseif $smarty.foreach.top3loop.index == 2}<span class="rank3">🥉 3</span>
											{else}{$smarty.foreach.top3loop.index + 1}{/if}
										</td>
										<td>{$p.username}</td>
										<td style="text-align:right;" class="highlight">{$p.units_fmt}</td>
									</tr>
								{/foreach}
							</tbody>
						</table>
					{else}
						<div class="trn_empty">Sin jugadores inscritos todavía.</div>
					{/if}
				</div>
			{/foreach}
		{/if}
	</div>

{/if}

{* ═══════════════════════════════════════════════════════════ *}
{* TAB 3 — HISTORIAL                                          *}
{* ═══════════════════════════════════════════════════════════ *}
{if $active_tab == 'history'}

	<div class="trn_card">
		<h3><i>📜</i> Historial de Ganadores (últimos 30)</h3>

		{if $history|@count == 0}
			<div class="trn_empty">📭 Todavía no hay registros en el historial.</div>
		{else}
			<table class="trn_table">
				<thead>
					<tr>
						<th style="width:60px;">Log ID</th>
						<th>Torneo</th>
						<th>Jugador</th>
						<th style="text-align:right;">Puntos Finales</th>
						<th style="text-align:right;">Fecha</th>
					</tr>
				</thead>
				<tbody>
					{foreach $history as $h}
						<tr>
							<td>#{$h.logId}</td>
							<td>{$h.tourneyName}</td>
							<td class="highlight">{$h.username}</td>
							<td style="text-align:right;">{$h.units_fmt}</td>
							<td style="text-align:right;font-size:11px;">{$h.join_fmt}</td>
						</tr>
					{/foreach}
				</tbody>
			</table>
		{/if}
	</div>

{/if}

{* ═══════════════════════════════════════════════════════════ *}
{* TAB 4 — ACCIONES                                           *}
{* ═══════════════════════════════════════════════════════════ *}
{if $active_tab == 'actions'}

	{* Forzar rotación *}
	<div class="trn_card">
		<h3><i>🔄</i> Forzar Rotación de Torneos</h3>
		<p style="font-size:12px;color:#94a3b8;margin:0 0 12px 0;">
			Ejecuta manualmente la rotación de los 5 torneos activos. Esta acción <strong>reparte los premios actuales</strong>,
			borra los torneos viejos y sortea 5 nuevos, igual que si el cronjob hubiera terminado el ciclo.
		</p>
		<form method="post" action="?page=tourneyadmin&amp;mode=forceRotation"
			  onsubmit="return confirm('¿Forzar la rotación de torneos ahora? Se repartirán los premios y se sortearán nuevos torneos.');">
			<button type="submit" class="trn_btn gold">🔄 Forzar Rotación</button>
		</form>
	</div>

	{* Limpiar historial *}
	<div class="trn_card">
		<h3><i>🧹</i> Limpiar Historial Antiguo</h3>
		<p style="font-size:12px;color:#94a3b8;margin:0 0 12px 0;">
			Elimina registros de <strong>uni1_tourney_logs</strong> con más antigüedad de la indicada.
			Los registros activos de participantes <strong>NO</strong> se ven afectados.
		</p>
		<form method="post" action="?page=tourneyadmin&amp;mode=cleanHistory"
			  onsubmit="return confirm('¿Eliminar registros antiguos del historial?');">
			<div class="trn_form_row">
				<label>Días a conservar</label>
				<input type="number" name="days" value="30" min="1" max="365" class="trn_input">
			</div>
			<button type="submit" class="trn_btn">🧹 Limpiar Historial</button>
		</form>
	</div>

	{* Resetear ciclo *}
	<div class="trn_card">
		<h3><i>⚠️</i> Resetear Ciclo Actual</h3>
		<p style="font-size:12px;color:#ef4444;margin:0 0 12px 0;font-weight:700;">
			⚠️ <strong>ACCIÓN PELIGROSA:</strong> Elimina TODOS los torneos activos y sus participantes actuales.
			Los jugadores perderán su progreso en el ciclo en curso. Úsalo solo si hay un bug o corrupción de datos.
		</p>
		<form method="post" action="?page=tourneyadmin&amp;mode=resetCycle"
			  onsubmit="return confirm('⚠️ ¿Estás SEGURO de resetear el ciclo actual? Se borrarán los torneos y participantes.');">
			<button type="submit" class="trn_btn danger">🗑️ Resetear Ciclo Actual</button>
		</form>
	</div>

	{* Info *}
	<div class="trn_card">
		<h3><i>ℹ️</i> Información del Sistema</h3>
		<table class="trn_table">
			<tbody>
				<tr>
					<td><strong>Constante del módulo</strong></td>
					<td><span class="highlight">MODULE_TOURNEY = 70</span></td>
				</tr>
				<tr>
					<td><strong>Módulo activo</strong></td>
					<td>{if $cycle_info.module_enabled}<span style="color:#4aff88;">✅ SÍ</span>{else}<span style="color:#ef4444;">⏸️ NO</span>{/if}</td>
				</tr>
				<tr>
					<td><strong>Tabla de torneos</strong></td>
					<td>uni1_tourney</td>
				</tr>
				<tr>
					<td><strong>Tabla de participantes</strong></td>
					<td>uni1_tourney_participante</td>
				</tr>
				<tr>
					<td><strong>Tabla de historial</strong></td>
					<td>uni1_tourney_logs</td>
				</tr>
				<tr>
					<td><strong>Cronjob</strong></td>
					<td>ID 28 — TournamentCronjob (cada hora)</td>
				</tr>
				<tr>
					<td><strong>Duración del ciclo</strong></td>
					<td>7 días</td>
				</tr>
				<tr>
					<td><strong>Torneos por ciclo</strong></td>
					<td>5 (Alpha, Beta, Gamma, Delta, Epsilon)</td>
				</tr>
			</tbody>
		</table>
	</div>

{/if}

</div>

{include file="overall_footer.tpl"}