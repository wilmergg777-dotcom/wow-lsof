{block name="content"}

<style>
/* ============================================================
   ASTROIO — MINIJUEGO TOPO (Golpea al Topo)
   Prefijo: .astrotopo_
   ============================================================ */

.astrotopo_wrap {
	background: rgba(15, 23, 42, 0.75);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid #1e293b;
	border-radius: 12px;
	padding: 15px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
	max-width: 900px;
	margin: 15px auto;
	color: #cbd5e1;
	font-family: 'Segoe UI', Roboto, sans-serif;
}

.astrotopo_header {
	background: linear-gradient(135deg, rgba(148, 163, 184, 0.85), rgba(100, 116, 139, 0.85));
	border-left: 4px solid #cbd5e1;
	border-radius: 10px;
	padding: 12px 18px;
	font-weight: 700;
	font-size: 15px;
	letter-spacing: 1.2px;
	text-transform: uppercase;
	color: #ffffff;
	margin-bottom: 15px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.5);
	text-align: center;
}

/* ═══ STATS DEL JUGADOR ═══ */
.astrotopo_stats {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 10px;
	margin-bottom: 15px;
}

.astrotopo_stat_card {
	background: rgba(0, 0, 0, 0.35);
	border: 1px solid rgba(148, 163, 184, 0.3);
	border-radius: 10px;
	padding: 10px;
	text-align: center;
}

.astrotopo_stat_label {
	font-size: 10px;
	color: #94a3b8;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	margin-bottom: 4px;
}

.astrotopo_stat_value {
	font-size: 16px;
	font-weight: 700;
	color: #cbd5e1;
	font-family: 'Courier New', monospace;
}

.astrotopo_stat_value.gold {
	color: #fbbf24;
}

.astrotopo_stat_value.cyan {
	color: #00e0ff;
}

.astrotopo_stat_value.green {
	color: #4aff88;
}

/* ═══ COOLDOWN ═══ */
.astrotopo_cooldown {
	background: rgba(239, 68, 68, 0.15);
	border: 1px solid #ef4444;
	border-left: 4px solid #ef4444;
	border-radius: 10px;
	padding: 15px;
	margin-bottom: 15px;
	text-align: center;
	animation: astrotopo_pulse 2s infinite;
}

@keyframes astrotopo_pulse {
	0%, 100% { box-shadow: 0 0 15px rgba(239, 68, 68, 0.5); }
	50%      { box-shadow: 0 0 25px rgba(239, 68, 68, 0.85); }
}

.astrotopo_cooldown_title {
	color: #ef4444;
	font-weight: 700;
	font-size: 13px;
	text-transform: uppercase;
	letter-spacing: 1px;
	margin-bottom: 6px;
}

.astrotopo_cooldown_time {
	font-family: 'Courier New', monospace;
	font-size: 24px;
	font-weight: 700;
	color: #ffffff;
}

/* ═══ PANEL DEL JUEGO ═══ */
.astrotopo_game_panel {
	background: rgba(0, 0, 0, 0.4);
	border: 1px solid #1e293b;
	border-radius: 10px;
	padding: 15px;
	margin-bottom: 15px;
}

.astrotopo_controls {
	display: flex;
	justify-content: space-between;
	align-items: center;
	gap: 15px;
	margin-bottom: 15px;
	flex-wrap: wrap;
}

.astrotopo_control_item {
	display: flex;
	align-items: center;
	gap: 8px;
	font-size: 12px;
	font-weight: 600;
	color: #94a3b8;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}

.astrotopo_control_value {
	font-family: 'Courier New', monospace;
	font-size: 20px;
	font-weight: 700;
	color: #00e0ff;
	min-width: 40px;
	text-align: center;
}

.astrotopo_control_value.warning {
	color: #fbbf24;
}

.astrotopo_control_value.danger {
	color: #ef4444;
	animation: astrotopo_pulse 0.8s infinite;
}

/* ═══ BOTÓN START ═══ */
.astrotopo_start_btn {
	background: linear-gradient(135deg, rgba(74, 255, 136, 0.85), rgba(0, 200, 100, 0.85));
	color: #0f1624;
	border: 2px solid #4aff88;
	border-radius: 8px;
	padding: 10px 25px;
	font-size: 13px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 1px;
	cursor: pointer;
	transition: all 0.25s ease;
	box-shadow: 0 0 20px rgba(74, 255, 136, 0.4);
	font-family: 'Segoe UI', sans-serif;
}

.astrotopo_start_btn:hover:not(:disabled) {
	background: linear-gradient(135deg, #4aff88, #00ff88);
	transform: translateY(-2px);
	box-shadow: 0 0 30px rgba(74, 255, 136, 0.8);
}

.astrotopo_start_btn:disabled {
	background: rgba(100, 116, 139, 0.4);
	border-color: #64748b;
	color: #94a3b8;
	cursor: not-allowed;
	box-shadow: none;
	opacity: 0.6;
}

/* ═══ TABLERO 6x2 ═══ */
.astrotopo_board {
	display: grid;
	grid-template-columns: repeat(6, 1fr);
	gap: 10px;
	max-width: 700px;
	margin: 0 auto;
	padding: 10px;
	background: rgba(0, 0, 0, 0.3);
	border-radius: 10px;
}

.astrotopo_hole {
	position: relative;
	width: 100%;
	padding-bottom: 100%; /* cuadrado perfecto */
	background: radial-gradient(circle, #1e293b 0%, #0f172a 100%);
	border: 2px solid #334155;
	border-radius: 50%;
	overflow: hidden;
	cursor: pointer;
	box-shadow: inset 0 5px 15px rgba(0, 0, 0, 0.8);
	transition: border-color 0.2s ease;
	user-select: none;
	-webkit-user-select: none;
	-webkit-tap-highlight-color: transparent;
	touch-action: manipulation;
}

.astrotopo_hole:hover {
	border-color: #64748b;
}

.astrotopo_mole {
	position: absolute;
	bottom: -100%;
	left: 0;
	width: 100%;
	height: 100%;
	background-image: url('styles/theme/gow/minijuego/topo.png');
	background-size: 70%;
	background-position: center bottom;
	background-repeat: no-repeat;
	transition: bottom 0.2s ease;
	pointer-events: none;
}

.astrotopo_hole.up .astrotopo_mole {
	bottom: 0;
}

.astrotopo_hole.hit {
	background: radial-gradient(circle, rgba(74, 255, 136, 0.5) 0%, rgba(0, 100, 50, 0.5) 100%);
	border-color: #4aff88;
	animation: astrotopo_hit_flash 0.3s ease;
}

@keyframes astrotopo_hit_flash {
	0%   { box-shadow: 0 0 30px rgba(74, 255, 136, 1); }
	100% { box-shadow: inset 0 5px 15px rgba(0, 0, 0, 0.8); }
}

/* ═══ RESULTADO ═══ */
.astrotopo_result {
	background: linear-gradient(135deg, rgba(74, 255, 136, 0.15), rgba(0, 200, 100, 0.15));
	border: 2px solid #4aff88;
	border-radius: 10px;
	padding: 20px;
	margin-top: 15px;
	text-align: center;
	animation: astrotopo_pulse 2s infinite;
}

.astrotopo_result.error {
	background: linear-gradient(135deg, rgba(239, 68, 68, 0.15), rgba(180, 50, 50, 0.15));
	border-color: #ef4444;
}

.astrotopo_result_title {
	font-size: 18px;
	font-weight: 800;
	color: #4aff88;
	margin-bottom: 10px;
	text-transform: uppercase;
	letter-spacing: 1.5px;
}

.astrotopo_result.error .astrotopo_result_title {
	color: #ef4444;
}

.astrotopo_result_body {
	font-size: 13px;
	color: #cbd5e1;
	line-height: 1.8;
}

.astrotopo_result_reward {
	font-size: 15px;
	color: #fbbf24;
	font-weight: 700;
	margin-top: 10px;
}

.hidden {
	display: none !important;
}

/* ═══ TIERS DE PREMIOS ═══ */
.astrotopo_tiers {
	background: rgba(0, 0, 0, 0.35);
	border: 1px solid rgba(251, 191, 36, 0.3);
	border-radius: 10px;
	padding: 12px;
	margin-bottom: 15px;
}

.astrotopo_section_title {
	font-size: 11px;
	text-transform: uppercase;
	letter-spacing: 1.2px;
	color: #fbbf24;
	font-weight: 700;
	margin-bottom: 10px;
	padding-bottom: 5px;
	border-bottom: 1px solid rgba(251, 191, 36, 0.3);
}

.astrotopo_tier_row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 6px 10px;
	margin-bottom: 4px;
	background: rgba(0, 0, 0, 0.25);
	border-radius: 6px;
	font-size: 12px;
}

.astrotopo_tier_range {
	font-family: 'Courier New', monospace;
	color: #00e0ff;
	font-weight: 700;
	min-width: 100px;
}

.astrotopo_tier_reward {
	color: #fbbf24;
	font-weight: 700;
}

.astrotopo_tier_bonus {
	color: #8b5cf6;
	font-size: 10px;
	margin-left: 8px;
}

/* ═══ RANKING ═══ */
.astrotopo_ranking {
	background: rgba(0, 0, 0, 0.35);
	border: 1px solid rgba(0, 224, 255, 0.3);
	border-radius: 10px;
	padding: 12px;
}

.astrotopo_ranking_row {
	display: grid;
	grid-template-columns: 40px 1fr auto;
	gap: 10px;
	padding: 6px 10px;
	margin-bottom: 4px;
	background: rgba(0, 0, 0, 0.25);
	border-radius: 6px;
	font-size: 12px;
	align-items: center;
}

.astrotopo_ranking_row.top1 {
	background: linear-gradient(90deg, rgba(251, 191, 36, 0.2), rgba(0, 0, 0, 0.25));
	border-left: 3px solid #fbbf24;
}

.astrotopo_ranking_row.top2 {
	background: linear-gradient(90deg, rgba(148, 163, 184, 0.2), rgba(0, 0, 0, 0.25));
	border-left: 3px solid #cbd5e1;
}

.astrotopo_ranking_row.top3 {
	background: linear-gradient(90deg, rgba(180, 83, 9, 0.2), rgba(0, 0, 0, 0.25));
	border-left: 3px solid #b45309;
}

.astrotopo_ranking_pos {
	font-weight: 800;
	color: #94a3b8;
	text-align: center;
	font-family: 'Courier New', monospace;
}

.astrotopo_ranking_name {
	color: #cbd5e1;
	font-weight: 600;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.astrotopo_ranking_score {
	color: #00e0ff;
	font-family: 'Courier New', monospace;
	font-weight: 700;
}

/* ═══ RESPONSIVE ═══ */
@media (max-width: 720px) {
	.astrotopo_stats { grid-template-columns: 1fr; }
	.astrotopo_controls { flex-direction: column; }
	.astrotopo_board { grid-template-columns: repeat(4, 1fr); }
}
</style>

<div class="astrotopo_wrap">

	{* ═══ HEADER ═══ *}
	<div class="astrotopo_header">
		🐹 Golpea al Topo
	</div>

	{* ═══ STATS DEL JUGADOR ═══ *}
	<div class="astrotopo_stats">
		<div class="astrotopo_stat_card">
			<div class="astrotopo_stat_label">Última partida</div>
			<div class="astrotopo_stat_value cyan">
				{if $topo_stats.last_play > 0}
					Hace {$topo_stats.last_play|date_format:"%H:%M"}
				{else}
					Nunca
				{/if}
			</div>
		</div>
		<div class="astrotopo_stat_card">
			<div class="astrotopo_stat_label">Partidas hoy</div>
			<div class="astrotopo_stat_value">{$topo_stats.plays_today}</div>
		</div>
		<div class="astrotopo_stat_card">
			<div class="astrotopo_stat_label">Tu récord</div>
			<div class="astrotopo_stat_value gold">{$topo_stats.best_score} pts</div>
		</div>
	</div>

	{* ═══ COOLDOWN (si aplica) ═══ *}
	<div id="topo_cooldown_box" class="astrotopo_cooldown {if $topo_stats.can_play}hidden{/if}">
		<div class="astrotopo_cooldown_title">⏰ Cooldown activo</div>
		<div class="astrotopo_cooldown_time" id="topo_cooldown_timer">{$topo_stats.cooldown_text}</div>
		<div style="font-size: 11px; margin-top: 8px; color: #94a3b8;">
			Podés volver a jugar cuando termine el contador
		</div>
	</div>

	{* ═══ PANEL DEL JUEGO ═══ *}
	<div class="astrotopo_game_panel">

		{* Controles *}
		<div class="astrotopo_controls">
			<div class="astrotopo_control_item">
				⏱️ Tiempo: <span class="astrotopo_control_value" id="topo_timer">{$topo_config.duration}</span>s
			</div>
			<div class="astrotopo_control_item">
				🎯 Score: <span class="astrotopo_control_value" id="topo_score">0</span>
			</div>
			<button 
				id="topo_start_btn" 
				class="astrotopo_start_btn"
				{if !$topo_stats.can_play}disabled{/if}>
				▶ Game Start
			</button>
		</div>

		{* Tablero *}
		<div class="astrotopo_board" id="topo_board">
			{* Los 12 huecos se generan por JS *}
		</div>

		{* Resultado *}
		<div id="topo_result" class="astrotopo_result hidden">
			<div class="astrotopo_result_title" id="topo_result_title">¡Fin del juego!</div>
			<div class="astrotopo_result_body" id="topo_result_body"></div>
			<div class="astrotopo_result_reward" id="topo_result_reward"></div>
		</div>

	</div>

	{* ═══ TABLA DE PREMIOS ═══ *}
	<div class="astrotopo_tiers">
		<div class="astrotopo_section_title">🏆 Premios por puntaje</div>
		{foreach $topo_tiers as $tier}
			{if $tier.score > 0}
				<div class="astrotopo_tier_row">
					<span class="astrotopo_tier_range">
						{if $tier.tier == 5}{$tier.score}+{else}{$tier.score}{/if} pts
					</span>
					<span class="astrotopo_tier_reward">
						💰 {$tier.mo} MO
					</span>
					{if $tier.chest_fixed > 0 || $tier.chest > 0}
						<span class="astrotopo_tier_bonus">
							{if $tier.tier == 4}
								🎁 1 Cofre Fijo {if $tier.chest > 0}+ {$tier.chest}% extra{/if}
							{elseif $tier.tier == 5}
								🎁 2 Cofres Fijos {if $tier.chest > 0}+ {$tier.chest}% extra{/if}
							{elseif $tier.chest > 0}
								🎁 {$tier.chest}% cofre
							{/if}
						</span>
					{/if}
				</div>
			{/if}
		{/foreach}
	</div>

	{* ═══ RANKING ═══ *}
	<div class="astrotopo_ranking">
		<div class="astrotopo_section_title">🏅 Top 10 Histórico</div>
		{if $topo_ranking|@count > 0}
			{foreach $topo_ranking as $rank}
				<div class="astrotopo_ranking_row top{$rank@iteration}">
					<span class="astrotopo_ranking_pos">
						{if $rank@iteration == 1}🥇{elseif $rank@iteration == 2}🥈{elseif $rank@iteration == 3}🥉{else}{$rank@iteration}{/if}
					</span>
					<span class="astrotopo_ranking_name">{$rank.username}</span>
					<span class="astrotopo_ranking_score">{$rank.score} pts</span>
				</div>
			{/foreach}
		{else}
			<div style="text-align: center; padding: 15px; color: #64748b; font-size: 12px;">
				Aún no hay partidas registradas
			</div>
		{/if}
	</div>

</div>

{/block}


{block name="script" append}
<script>
/* ============================================================
   ASTROIO — MINIJUEGO TOPO v1.3
   Fix v1.3: listener global en DOCUMENT (capture phase)
   → Captura el clic ANTES que cualquier otro handler de la página
   ============================================================ */
(function() {
	'use strict';

	console.log('[TOPO] Script v1.3 cargado');

	// ═══ Config del juego (inyectada desde PHP) ═══
	var CONFIG = {$topo_config_json};
	console.log('[TOPO] CONFIG:', CONFIG);

	// ═══ Estado del juego ═══
	var gameState = {
		running:    false,
		score:      0,
		timeLeft:   CONFIG.duration,
		token:      null,
		boardEl:    null,
		holes:      [],
		moleTimer:  null,
		gameTimer:  null,
		cooldownTimer: null
	};

	// ═══ Referencias DOM (se rellenan en init() cuando el DOM está listo) ═══
	var elTimer         = null;
	var elScore         = null;
	var elStartBtn      = null;
	var elBoard         = null;
	var elResult        = null;
	var elResultTitle   = null;
	var elResultBody    = null;
	var elResultReward  = null;
	var elCooldownBox   = null;
	var elCooldownTimer = null;


	// ════════════════════════════════════════════════
	// UTILIDADES
	// ════════════════════════════════════════════════

	function formatCooldown(seconds) {
		seconds = parseInt(seconds, 10) || 0;
		if (seconds <= 0) return '0s';

		var h = Math.floor(seconds / 3600);
		var m = Math.floor((seconds % 3600) / 60);
		var s = seconds % 60;

		if (h > 0) return h + 'h ' + m + 'm';
		if (m > 0) return m + 'm ' + s + 's';
		return s + 's';
	}

	function showResult(title, body, reward, isError) {
		elResultTitle.textContent = title;
		elResultBody.innerHTML    = body;
		elResultReward.innerHTML  = reward || '';
		elResult.classList.remove('hidden');
		if (isError) {
			elResult.classList.add('error');
		} else {
			elResult.classList.remove('error');
		}
	}

	function hideResult() {
		elResult.classList.add('hidden');
	}


	// ════════════════════════════════════════════════
	// CREAR TABLERO (12 huecos)
	// ════════════════════════════════════════════════

	function createBoard() {
		elBoard.innerHTML = '';
		gameState.holes = [];

		for (var i = 0; i < 12; i++) {
			var hole = document.createElement('div');
			hole.className = 'astrotopo_hole';
			hole.dataset.hit = '';

			var mole = document.createElement('div');
			mole.className = 'astrotopo_mole';
			hole.appendChild(mole);

			elBoard.appendChild(hole);
			gameState.holes.push(hole);
		}
	}


	// ════════════════════════════════════════════════
	// LÓGICA DEL JUEGO
	// ════════════════════════════════════════════════

	function hitMole(hole) {
		console.log('[TOPO] hitMole llamado. running:', gameState.running, '| up:', hole.classList.contains('up'), '| hit:', hole.dataset.hit);

		if (!gameState.running) {
			console.log('[TOPO] ❌ Rechazado: no running');
			return;
		}
		if (!hole.classList.contains('up')) {
			console.log('[TOPO] ❌ Rechazado: no hay topo arriba');
			return;
		}
		if (hole.dataset.hit === '1') {
			console.log('[TOPO] ❌ Rechazado: ya golpeado');
			return;
		}

		hole.dataset.hit = '1';                  // marcar como golpeado

		// Registrar golpe
		hole.classList.remove('up');
		hole.classList.add('hit');
		setTimeout(function() {
			hole.classList.remove('hit');
		}, 300);

		// Sumar puntos
		gameState.score += CONFIG.pointsPerHit;
		elScore.textContent = gameState.score;

		console.log('[TOPO] ✅ SUMADO. Score:', gameState.score);

		// Flash visual en el score
		elScore.classList.add('warning');
		setTimeout(function() {
			elScore.classList.remove('warning');
		}, 100);
	}

	function startMoles() {
		gameState.moleTimer = setInterval(function() {
			if (!gameState.running) return;

			// Elegir un hueco random
			var idx = Math.floor(Math.random() * gameState.holes.length);
			var hole = gameState.holes[idx];

			// Si ya está arriba, ignorar
			if (hole.classList.contains('up')) return;

			// Mostrar topo
			hole.classList.add('up');
			hole.dataset.hit = '';   // reset flag al aparecer

			// Ocultar después de X ms
			setTimeout(function() {
				hole.classList.remove('up');
				hole.dataset.hit = '';   // limpiar flag al ocultar
			}, CONFIG.moleVisible);

		}, CONFIG.moleInterval);
	}

	function startTimer() {
		gameState.gameTimer = setInterval(function() {
			if (!gameState.running) return;

			gameState.timeLeft--;
			elTimer.textContent = gameState.timeLeft;

			// Cambiar color según tiempo
			elTimer.classList.remove('warning', 'danger');
			if (gameState.timeLeft <= 5) {
				elTimer.classList.add('danger');
			} else if (gameState.timeLeft <= 10) {
				elTimer.classList.add('warning');
			}

			if (gameState.timeLeft <= 0) {
				endGame();
			}
		}, 1000);
	}

	function stopAllTimers() {
		if (gameState.moleTimer) { clearInterval(gameState.moleTimer); gameState.moleTimer = null; }
		if (gameState.gameTimer) { clearInterval(gameState.gameTimer); gameState.gameTimer = null; }
	}

	function resetBoard() {
		for (var i = 0; i < gameState.holes.length; i++) {
			gameState.holes[i].classList.remove('up');
			gameState.holes[i].classList.remove('hit');
			gameState.holes[i].dataset.hit = '';
		}
	}


	// ════════════════════════════════════════════════
	// AJAX — INICIAR PARTIDA
	// ════════════════════════════════════════════════

	function startGame() {
		// Bloquear botón mientras carga
		elStartBtn.disabled = true;
		elStartBtn.textContent = '⏳ Cargando...';
		hideResult();

		// Petición AJAX
		var xhr = new XMLHttpRequest();
		xhr.open('GET', 'game.php?page=minijuegotopo&mode=start', true);
		xhr.onreadystatechange = function() {
			if (xhr.readyState !== 4) return;

			if (xhr.status !== 200) {
				onStartError('Error de conexión');
				return;
			}

			var data;
			try {
				data = JSON.parse(xhr.responseText);
			} catch (e) {
				onStartError('Respuesta inválida del servidor');
				return;
			}

			if (!data.success) {
				if (data.error === 'cooldown') {
					onStartError('Cooldown activo: ' + (data.cooldown_text || ''));
				} else {
					onStartError('Error: ' + data.error);
				}
				return;
			}

			// Guardar token
			gameState.token = data.token;
			beginGame();
		};
		xhr.send();
	}

	function onStartError(msg) {
		elStartBtn.disabled = false;
		elStartBtn.textContent = '▶ Game Start';
		showResult('❌ Error', msg, '', true);
	}

	function beginGame() {
		// Reset estado
		gameState.running  = true;
		gameState.score    = 0;
		gameState.timeLeft = CONFIG.duration;

		elTimer.textContent = CONFIG.duration;
		elScore.textContent = '0';
		elTimer.classList.remove('warning', 'danger');
		elStartBtn.textContent = '🎮 Jugando...';

		resetBoard();
		createBoard();

		startTimer();
		startMoles();
	}


	// ════════════════════════════════════════════════
	// AJAX — TERMINAR PARTIDA
	// ════════════════════════════════════════════════

	function endGame() {
		if (!gameState.running) return;

		gameState.running = false;
		stopAllTimers();
		resetBoard();

		elStartBtn.disabled = true;
		elStartBtn.textContent = '⏳ Guardando...';

		var finalScore = gameState.score;

		// POST AJAX
		var xhr = new XMLHttpRequest();
		xhr.open('POST', 'game.php?page=minijuegotopo&mode=finish', true);
		xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
		xhr.onreadystatechange = function() {
			if (xhr.readyState !== 4) return;

			if (xhr.status !== 200) {
				onEndError('Error de conexión');
				return;
			}

			var data;
			try {
				data = JSON.parse(xhr.responseText);
			} catch (e) {
				onEndError('Respuesta inválida del servidor');
				return;
			}

			if (!data.success) {
				onEndError('Error: ' + data.error);
				return;
			}

			onEndSuccess(data);
		};
		xhr.send('token=' + encodeURIComponent(gameState.token) + '&score=' + finalScore);
	}

	function onEndError(msg) {
		elStartBtn.textContent = '▶ Game Start';
		showResult('❌ Error al guardar', msg, '', true);

		// Aun así mostramos cooldown por si acaso (usando la config dinámica)
		startCooldownCountdown(CONFIG.cooldownHours * 3600);
	}

	function onEndSuccess(data) {
		var reward = data.reward || {};
		var mo     = reward.mo     || 0;
		var chests = reward.chests || 0;

		// Construir mensaje
		var bodyHtml = 'Puntaje final: <strong style="color:#00e0ff;">' + data.score + ' pts</strong>';

		var rewardHtml = '';
		if (mo > 0) {
			rewardHtml += '💰 <strong>' + mo + ' MO</strong> ';
		}
		if (chests > 0) {
			rewardHtml += '🎁 <strong>' + chests + ' cofre' + (chests > 1 ? 's' : '') + '</strong>';
		}
		if (!rewardHtml) {
			rewardHtml = '<span style="color:#94a3b8;">No alcanzaste el mínimo para premio</span>';
		}

		showResult('🎉 ¡Fin del juego!', bodyHtml, rewardHtml, false);

		// Arrancar cooldown dinámico (según config en BD)
		var cooldownHours = parseInt(CONFIG.cooldownHours, 10) || 2;
		startCooldownCountdown(cooldownHours * 3600);

		// Refrescar la página después de 5 segundos para actualizar stats
		setTimeout(function() {
			window.location.reload();
		}, 5000);

		elStartBtn.textContent = '✅ Completado';
	}


	// ════════════════════════════════════════════════
	// COOLDOWN COUNTDOWN (JS)
	// ════════════════════════════════════════════════

	function startCooldownCountdown(seconds) {
		// Mostrar el box de cooldown
		elCooldownBox.classList.remove('hidden');

		var remaining = parseInt(seconds, 10) || 0;

		if (gameState.cooldownTimer) {
			clearInterval(gameState.cooldownTimer);
		}

		function tick() {
			if (remaining <= 0) {
				clearInterval(gameState.cooldownTimer);
				elCooldownTimer.textContent = '¡Listo!';
				elStartBtn.disabled = false;
				elStartBtn.textContent = '▶ Game Start';
				return;
			}

			elCooldownTimer.textContent = formatCooldown(remaining);
			remaining--;
		}

		tick();
		gameState.cooldownTimer = setInterval(tick, 1000);
	}


	// ════════════════════════════════════════════════
	// INICIALIZACIÓN
	// ════════════════════════════════════════════════

	function init() {
		// ═══ Recolectar referencias DOM AHORA (el DOM ya está listo) ═══
		elTimer         = document.getElementById('topo_timer');
		elScore         = document.getElementById('topo_score');
		elStartBtn      = document.getElementById('topo_start_btn');
		elBoard         = document.getElementById('topo_board');
		elResult        = document.getElementById('topo_result');
		elResultTitle   = document.getElementById('topo_result_title');
		elResultBody    = document.getElementById('topo_result_body');
		elResultReward  = document.getElementById('topo_result_reward');
		elCooldownBox   = document.getElementById('topo_cooldown_box');
		elCooldownTimer = document.getElementById('topo_cooldown_timer');

		console.log('[TOPO] init() — refs DOM:', {
			board: elBoard,
			startBtn: elStartBtn,
			score: elScore
		});

		// ═══ Crear tablero inicial ═══
		createBoard();

		// ════════════════════════════════════════════════
		// LISTENER GLOBAL EN DOCUMENT (CAPTURE PHASE)
		// Fase de captura = se ejecuta ANTES que cualquier otro handler
		// de la página (modal, overlay, etc.) → imposible de bloquear
		// ════════════════════════════════════════════════
		document.addEventListener('pointerdown', function(e) {
			if (!elBoard) return;

			var hole = e.target.closest ? e.target.closest('.astrotopo_hole') : null;

			// Solo nos interesan clics DENTRO del tablero
			if (!hole) return;
			if (!elBoard.contains(hole)) return;

			console.log('[TOPO] pointerdown capturado en hole');

			e.preventDefault();
			hitMole(hole);
		}, true); // true = capture phase

		// Fallback para navegadores sin PointerEvent (muy viejos)
		if (!window.PointerEvent) {
			document.addEventListener('mousedown', function(e) {
				if (!elBoard) return;
				var hole = e.target.closest ? e.target.closest('.astrotopo_hole') : null;
				if (!hole) return;
				if (!elBoard.contains(hole)) return;
				e.preventDefault();
				hitMole(hole);
			}, true);
		}

		// ═══ Botón START ═══
		elStartBtn.addEventListener('click', function() {
			if (!elStartBtn.disabled) {
				startGame();
			}
		});

		// ═══ Si está en cooldown, arrancar countdown ═══
		{if !$topo_stats.can_play}
			startCooldownCountdown({$topo_stats.cooldown_left});
		{/if}
	}

	// Arrancar cuando el DOM esté listo
	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}

})();
</script>
{/block}