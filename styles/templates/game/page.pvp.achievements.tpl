{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   PvP — Logros
   AstroIO v3.1 — Badge de saldo (coherencia visual PvP)
   Prefijo: .astropvp_ach_

   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Recompensas siguen siendo Materia Oscura (DM), NO NTX/UNTX
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
.astropvp_ach_wrap,
.astropvp_ach_wrap *,
.astropvp_ach_wrap *::before,
.astropvp_ach_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_ach_wrap {
    padding: 20px;
    color: #c8d6e5;
}

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_ach_title {
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
.astropvp_ach_tabs {
    max-width: 900px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_ach_tab {
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
.astropvp_ach_tab:hover {
    transform: translateY(-2px);
}

.astropvp_ach_tab.main {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_ach_tab.main:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_ach_tab.arenas {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_ach_tab.arenas:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_ach_tab.tournaments {
    background: rgba(255, 200, 50, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(255, 200, 50, 0.5);
}
.astropvp_ach_tab.tournaments:hover {
    background: rgba(255, 200, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 200, 50, 0.4);
}

.astropvp_ach_tab.history {
    background: rgba(100, 150, 255, 0.15);
    color: #88bbff;
    border: 1px solid rgba(100, 150, 255, 0.5);
}
.astropvp_ach_tab.history:hover {
    background: rgba(100, 150, 255, 0.25);
    box-shadow: 0 0 14px rgba(100, 150, 255, 0.4);
}

.astropvp_ach_tab.achievements {
    background: linear-gradient(135deg, #aa44ff, #dd88ff);
    color: #ffffff;
    border: 1px solid #dd88ff;
    box-shadow: 0 4px 14px rgba(170, 50, 255, 0.5);
}
.astropvp_ach_tab.achievements:hover {
    box-shadow: 0 6px 20px rgba(170, 50, 255, 0.7);
}

.astropvp_ach_tab.profile {
    background: rgba(200, 100, 255, 0.15);
    color: #dd99ff;
    border: 1px solid rgba(200, 100, 255, 0.5);
}
.astropvp_ach_tab.profile:hover {
    background: rgba(200, 100, 255, 0.25);
    box-shadow: 0 0 14px rgba(200, 100, 255, 0.4);
}

/* ─── RESUMEN ───────────────────────────────────────────── */
.astropvp_ach_summary_wrap {
    max-width: 900px;
    margin: 0 auto 25px;
    text-align: center;
}

.astropvp_ach_summary {
    display: inline-block;
    padding: 15px 30px;
    background: linear-gradient(160deg, rgba(60, 20, 60, 0.85) 0%, rgba(90, 30, 90, 0.85) 100%);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(200, 100, 255, 0.5);
    border-radius: 14px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_ach_summary_label {
    font-size: 12px;
    color: #8899aa;
    margin-bottom: 5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astropvp_ach_summary_value {
    font-size: 28px;
    color: #dd99ff;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 14px rgba(200, 100, 255, 0.5);
}

/* ─── GRID DE LOGROS ────────────────────────────────────── */
.astropvp_ach_grid {
    max-width: 900px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 15px;
}

/* ─── CARD DE LOGRO ─────────────────────────────────────── */
.astropvp_ach_card {
    padding: 25px 18px 20px;
    border-radius: 14px;
    text-align: center;
    transition: 0.25s ease;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    min-width: 0;
    /* Colores dinámicos via CSS custom property */
    border: 2px solid var(--ach-color, rgba(120, 120, 120, 0.4));
}
.astropvp_ach_card:hover {
    transform: translateY(-3px);
}

/* Estado: desbloqueado */
.astropvp_ach_card.unlocked {
    background: linear-gradient(160deg, rgba(60, 20, 60, 0.85) 0%, rgba(90, 30, 90, 0.85) 100%);
}
.astropvp_ach_card.unlocked:hover {
    box-shadow: 0 8px 30px var(--ach-color, rgba(200, 100, 255, 0.4)),
                0 4px 20px rgba(0, 0, 0, 0.5);
}

/* Estado: bloqueado */
.astropvp_ach_card.locked {
    background: rgba(30, 30, 40, 0.6);
}
.astropvp_ach_card.locked:hover {
    box-shadow: 0 8px 30px rgba(120, 120, 120, 0.25),
                0 4px 20px rgba(0, 0, 0, 0.5);
}

/* ─── ICONO ─────────────────────────────────────────────── */
.astropvp_ach_icon {
    font-size: 48px;
    line-height: 1;
    margin-bottom: 25px;
    filter: drop-shadow(0 0 12px var(--ach-color, transparent));
}
.astropvp_ach_card.locked .astropvp_ach_icon {
    filter: grayscale(100%);
    opacity: 0.4;
}

/* ─── LABEL ─────────────────────────────────────────────── */
.astropvp_ach_label {
    font-size: 14px;
    font-weight: bold;
    margin-bottom: 12px;
    color: var(--ach-color, #667788);
    text-shadow: 0 0 8px var(--ach-color, transparent);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

/* ─── DESCRIPCIÓN ───────────────────────────────────────── */
.astropvp_ach_desc {
    font-size: 11px;
    color: #8899aa;
    margin-bottom: 14px;
    min-height: 30px;
    line-height: 1.5;
}

/* ─── ESTADO DESBLOQUEADO ───────────────────────────────── */
.astropvp_ach_unlocked_at {
    font-size: 11px;
    color: #88ffbb;
    margin-bottom: 10px;
}

.astropvp_ach_reward {
    font-size: 12px;
    color: #ffee88;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

/* ─── BARRA DE PROGRESO ─────────────────────────────────── */
.astropvp_ach_progress_wrap {
    margin-bottom: 10px;
}

.astropvp_ach_progress_info {
    display: flex;
    justify-content: space-between;
    font-size: 10px;
    color: #8899aa;
    margin-bottom: 5px;
    font-family: 'Courier New', monospace;
}

.astropvp_ach_progress_bar {
    height: 6px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 3px;
    overflow: hidden;
}

.astropvp_ach_progress_fill {
    height: 100%;
    background: linear-gradient(90deg, #aa44ff, #dd88ff);
    transition: width 0.3s ease;
    border-radius: 3px;
    box-shadow: 0 0 8px rgba(170, 68, 255, 0.6);
}

/* ─── RECOMPENSA (locked) ───────────────────────────────── */
.astropvp_ach_reward_locked {
    font-size: 11px;
    color: #ffee88;
    font-family: 'Courier New', monospace;
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_ach_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 720px) {
    .astropvp_ach_wrap {
        padding: 12px;
    }
    .astropvp_ach_title {
        font-size: 18px;
    }
    .astropvp_ach_tab {
        max-width: 100%;
        min-width: 100px;
        font-size: 11px;
        padding: 9px 12px;
    }
    .astropvp_ach_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_ach_summary {
        padding: 12px 20px;
    }
    .astropvp_ach_summary_value {
        font-size: 22px;
    }
    .astropvp_ach_card {
        padding: 20px 14px 16px;
    }
    .astropvp_ach_icon {
        font-size: 40px;
        margin-bottom: 18px;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_ach_wrap">
	<h1 class="astropvp_ach_title">
		🏅 Logros PvP
	</h1>

	{* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
	<div class="astropvp_balance_box">
		<span class="astropvp_balance_badge">
			💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
			<span class="moneda">{$moneda}</span>
		</span>
	</div>

	{* MENÚ *}
	<div class="astropvp_ach_tabs">
		<a href="game.php?page=pvp" class="astropvp_ach_tab main">🏠 Panel</a>
		<a href="game.php?page=pvp&mode=arenas" class="astropvp_ach_tab arenas">🏟️ Arenas</a>
		<a href="game.php?page=pvp&mode=tournaments" class="astropvp_ach_tab tournaments">🏆 Torneos</a>
		<a href="game.php?page=pvp&mode=history" class="astropvp_ach_tab history">📜 Historial</a>
		<a href="game.php?page=pvp&mode=achievements" class="astropvp_ach_tab achievements">🏅 Logros</a>
		<a href="game.php?page=pvp&mode=profile" class="astropvp_ach_tab profile">👤 Perfil</a>
	</div>

	{* RESUMEN *}
	<div class="astropvp_ach_summary_wrap">
		<div class="astropvp_ach_summary">
			<div class="astropvp_ach_summary_label">Logros desbloqueados</div>
			<div class="astropvp_ach_summary_value">
				{$ach_data.unlocked} / {$ach_data.total}
			</div>
		</div>
	</div>

	{* LISTA DE LOGROS *}
	<div class="astropvp_ach_grid">
		{foreach $ach_data.achievements as $a}
			<div class="astropvp_ach_card {if $a.unlocked}unlocked{else}locked{/if}"
			     style="--ach-color: {if $a.unlocked}{$a.color}{else}rgba(120, 120, 120, 0.4){/if};">

				<div class="astropvp_ach_icon">
					{$a.icon}
				</div>

				<div class="astropvp_ach_label">
					{$a.label}
				</div>

				<div class="astropvp_ach_desc">
					{$a.description}
				</div>

				{if $a.unlocked}
					<div class="astropvp_ach_unlocked_at">
						✅ Desbloqueado: {$a.unlocked_fmt}
					</div>
					<div class="astropvp_ach_reward">
						🌌 +{$a.reward_dm|number_format:0:'.':','} Materia Oscura
					</div>
				{else}
					<div class="astropvp_ach_progress_wrap">
						<div class="astropvp_ach_progress_info">
							<span>{$a.progress} / {$a.target}</span>
							<span>{$a.progress_pct}%</span>
						</div>
						<div class="astropvp_ach_progress_bar">
							<div class="astropvp_ach_progress_fill" style="width: {$a.progress_pct}%;"></div>
						</div>
					</div>
					<div class="astropvp_ach_reward_locked">
						Recompensa: 🌌 +{$a.reward_dm|number_format:0:'.':','} Materia Oscura
					</div>
				{/if}

			</div>
		{/foreach}
	</div>
</div>
{/block}