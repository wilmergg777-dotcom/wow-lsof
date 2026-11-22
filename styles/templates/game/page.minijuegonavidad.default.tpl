{block name="content"}

<style>
/* Estilos idénticos a los que te pasé antes, pero SIN la sección de Ranking */
.astronavidad_wrap {
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
.astronavidad_header {
    background: linear-gradient(135deg, rgba(200, 30, 30, 0.85), rgba(150, 20, 20, 0.85));
    border-left: 4px solid #ffdd88;
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
.astronavidad_stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    margin-bottom: 15px;
}
.astronavidad_stat_card {
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(148, 163, 184, 0.3);
    border-radius: 10px;
    padding: 10px;
    text-align: center;
}
.astronavidad_stat_label {
    font-size: 10px;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}
.astronavidad_stat_value {
    font-size: 16px;
    font-weight: 700;
    color: #cbd5e1;
    font-family: 'Courier New', monospace;
}
.astronavidad_stat_value.cyan { color: #00e0ff; }
.astronavidad_cooldown {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid #ef4444;
    border-left: 4px solid #ef4444;
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
    text-align: center;
    animation: astronavidad_pulse 2s infinite;
}
@keyframes astronavidad_pulse {
    0%, 100% { box-shadow: 0 0 15px rgba(239, 68, 68, 0.5); }
    50%      { box-shadow: 0 0 25px rgba(239, 68, 68, 0.85); }
}
.astronavidad_cooldown_title {
    color: #ef4444;
    font-weight: 700;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 6px;
}
.astronavidad_cooldown_time {
    font-family: 'Courier New', monospace;
    font-size: 24px;
    font-weight: 700;
    color: #ffffff;
}
.astronavidad_game_panel {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid #1e293b;
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
}
.astronavidad_controls {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    margin-bottom: 15px;
    flex-wrap: wrap;
}
.astronavidad_control_item {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 12px;
    font-weight: 600;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astronavidad_control_value {
    font-family: 'Courier New', monospace;
    font-size: 20px;
    font-weight: 700;
    color: #00e0ff;
    min-width: 40px;
    text-align: center;
}
.astronavidad_control_value.warning { color: #fbbf24; }
.astronavidad_control_value.danger { color: #ef4444; animation: astronavidad_pulse 0.8s infinite; }
.astronavidad_start_btn {
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
.astronavidad_start_btn:hover:not(:disabled) {
    background: linear-gradient(135deg, #4aff88, #00ff88);
    transform: translateY(-2px);
    box-shadow: 0 0 30px rgba(74, 255, 136, 0.8);
}
.astronavidad_start_btn:disabled {
    background: rgba(100, 116, 139, 0.4);
    border-color: #64748b;
    color: #94a3b8;
    cursor: not-allowed;
    box-shadow: none;
    opacity: 0.6;
}
.astronavidad_board {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    max-width: 500px;
    margin: 0 auto;
    padding: 10px;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 10px;
}
.astronavidad_card {
    position: relative;
    width: 100%;
    padding-bottom: 100%;
    perspective: 600px;
    cursor: pointer;
}
.astronavidad_card_inner {
    position: absolute;
    inset: 0;
    transition: transform 0.6s;
    transform-style: preserve-3d;
}
.astronavidad_card.flipped .astronavidad_card_inner {
    transform: rotateY(180deg);
}
.astronavidad_card_face {
    position: absolute;
    inset: 0;
    backface-visibility: hidden;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    border: 2px solid #334155;
    box-shadow: inset 0 4px 12px rgba(0,0,0,0.6);
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
}
.astronavidad_card_back {
    background-color: #1e293b;
    color: #64748b;
}
.astronavidad_card_front {
    background-color: #2d1b00;
    transform: rotateY(180deg);
    border-color: #fbbf24;
}
.astronavidad_card.matched .astronavidad_card_front {
    border-color: #4aff88;
    box-shadow: 0 0 20px rgba(74, 255, 136, 0.6);
}
.astronavidad_result {
    background: linear-gradient(135deg, rgba(74, 255, 136, 0.15), rgba(0, 200, 100, 0.15));
    border: 2px solid #4aff88;
    border-radius: 10px;
    padding: 20px;
    margin-top: 15px;
    text-align: center;
    animation: astronavidad_pulse 2s infinite;
}
.astronavidad_result.error {
    background: linear-gradient(135deg, rgba(239, 68, 68, 0.15), rgba(180, 50, 50, 0.15));
    border-color: #ef4444;
}
.astronavidad_result_title {
    font-size: 18px;
    font-weight: 800;
    color: #4aff88;
    margin-bottom: 10px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
}
.astronavidad_result.error .astronavidad_result_title { color: #ef4444; }
.astronavidad_result_body {
    font-size: 13px;
    color: #cbd5e1;
    line-height: 1.8;
}
.astronavidad_result_reward {
    font-size: 14px;
    color: #fbbf24;
    font-weight: 700;
    margin-top: 8px;
}
.hidden { display: none !important; }
@media (max-width: 720px) {
    .astronavidad_stats { grid-template-columns: 1fr; }
    .astronavidad_controls { flex-direction: column; }
    .astronavidad_board { grid-template-columns: repeat(4, 1fr); gap: 5px; }
    .astronavidad_card_face { font-size: 24px; }
}
</style>

<div class="astronavidad_wrap">

    <div class="astronavidad_header">🎄 Memoria Navideña</div>

    <div class="astronavidad_stats">
        <div class="astronavidad_stat_card">
            <div class="astronavidad_stat_label">Última partida</div>
            <div class="astronavidad_stat_value cyan">
                {if $navidad_stats.last_play > 0}
                    Hace {$navidad_stats.last_play|date_format:"%H:%M"}
                {else}
                    Nunca
                {/if}
            </div>
        </div>
        <div class="astronavidad_stat_card">
            <div class="astronavidad_stat_label">Partidas hoy</div>
            <div class="astronavidad_stat_value">{$navidad_stats.plays_today}</div>
        </div>
        <div class="astronavidad_stat_card">
            <div class="astronavidad_stat_label">Partidas totales</div>
            <div class="astronavidad_stat_value">{$navidad_stats.total_plays}</div>
        </div>
    </div>

    <div id="navidad_cooldown_box" class="astronavidad_cooldown {if $navidad_stats.can_play}hidden{/if}">
        <div class="astronavidad_cooldown_title">⏰ Cooldown activo</div>
        <div class="astronavidad_cooldown_time" id="navidad_cooldown_timer">{$navidad_stats.cooldown_text}</div>
        <div style="font-size: 11px; margin-top: 8px; color: #94a3b8;">Podés volver a jugar cuando termine el contador</div>
    </div>

    <div class="astronavidad_game_panel">
        <div class="astronavidad_controls">
            <div class="astronavidad_control_item">
                ⏱️ Tiempo: <span class="astronavidad_control_value" id="navidad_timer">{$navidad_config.duration}</span>s
            </div>
            <div class="astronavidad_control_item">
                🎯 Parejas: <span class="astronavidad_control_value" id="navidad_pairs">0</span>/8
            </div>
            <button id="navidad_start_btn" class="astronavidad_start_btn" {if !$navidad_stats.can_play}disabled{/if}>▶ Iniciar Juego</button>
        </div>

        <div class="astronavidad_board" id="navidad_board"></div>

        <div id="navidad_result" class="astronavidad_result hidden">
            <div class="astronavidad_result_title" id="navidad_result_title">¡Fin del juego!</div>
            <div class="astronavidad_result_body" id="navidad_result_body"></div>
            <div class="astronavidad_result_reward" id="navidad_result_reward"></div>
        </div>
    </div>
</div>

{/block}

{block name="script" append}
<script>
(function() {
    'use strict';
    
    var CONFIG = {$navidad_config_json};
    var PAIRS = 8;
    var BASE_PATH = 'styles/theme/gow/minijuego/navidad/';
    var IMAGES = { 
        1: BASE_PATH + 'metal.png', 
        2: BASE_PATH + 'cristal.png', 
        3: BASE_PATH + 'deuterio.png', 
        4: BASE_PATH + 'nave.png', 
        5: BASE_PATH + 'defensa.png', 
        6: BASE_PATH + 'mo.png', 
        7: BASE_PATH + 'cofres.png', 
        8: BASE_PATH + 'especial.png' 
    };
    var IMAGE_REVERSO = BASE_PATH + 'reverso.png';

    // Copiado exactamente del Topo: cooldownTimer dentro de gameState
    var gameState = {
        running: false, 
        pairsFound: 0, 
        timeLeft: CONFIG.duration, 
        token: null,
        cards: [], 
        flipped: [], 
        matched: [], 
        lock: false, 
        timer: null,
        cooldownTimer: null
    };
    
    var elTimer, elPairs, elStartBtn, elBoard, elResult, elResultTitle, elResultBody, elResultReward, elCooldownBox, elCooldownTimer;

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
        elResultBody.innerHTML = body;
        elResultReward.innerHTML = reward || '';
        elResult.classList.remove('hidden');
        if (isError) elResult.classList.add('error');
        else elResult.classList.remove('error');
    }

    function hideResult() { elResult.classList.add('hidden'); }

    function createBoard() {
        elBoard.innerHTML = '';
        gameState.cards = [];
        gameState.flipped = [];
        gameState.matched = [];
        gameState.lock = false;

        var deck = [];
        for (var i = 1; i <= PAIRS; i++) { deck.push(i); deck.push(i); }
        for (var j = deck.length - 1; j > 0; j--) {
            var k = Math.floor(Math.random() * (j + 1));
            var tmp = deck[j]; deck[j] = deck[k]; deck[k] = tmp;
        }

        for (var idx = 0; idx < deck.length; idx++) {
            var pairId = deck[idx];
            var card = document.createElement('div');
            card.className = 'astronavidad_card';
            card.dataset.pair = pairId;

            var inner = document.createElement('div'); inner.className = 'astronavidad_card_inner';
            
            var back = document.createElement('div'); back.className = 'astronavidad_card_face astronavidad_card_back';
            back.style.backgroundImage = 'url(' + IMAGE_REVERSO + ')';
            
            var front = document.createElement('div'); front.className = 'astronavidad_card_face astronavidad_card_front';
            if (IMAGES[pairId]) {
                front.style.backgroundImage = 'url(' + IMAGES[pairId] + ')';
            }

            inner.appendChild(back); inner.appendChild(front); card.appendChild(inner); elBoard.appendChild(card);
            gameState.cards.push(card);
        }
    }

    function flipCard(card) {
        if (!gameState.running || gameState.lock) return;
        if (card.classList.contains('flipped') || card.classList.contains('matched')) return;
        card.classList.add('flipped');
        gameState.flipped.push(card);
        if (gameState.flipped.length === 2) checkMatch();
    }

    function checkMatch() {
        gameState.lock = true;
        var c1 = gameState.flipped[0], c2 = gameState.flipped[1];
        if (c1.dataset.pair === c2.dataset.pair) {
            c1.classList.add('matched'); c2.classList.add('matched');
            gameState.matched.push(c1.dataset.pair);
            gameState.pairsFound++;
            elPairs.textContent = gameState.pairsFound;
            gameState.flipped = [];
            gameState.lock = false;
            if (gameState.pairsFound === PAIRS) endGame(true);
        } else {
            setTimeout(function() {
                c1.classList.remove('flipped'); c2.classList.remove('flipped');
                gameState.flipped = [];
                gameState.lock = false;
            }, 1000);
        }
    }

    function startTimer() {
        gameState.timer = setInterval(function() {
            if (!gameState.running) return;
            gameState.timeLeft--;
            elTimer.textContent = gameState.timeLeft;
            elTimer.classList.remove('warning', 'danger');
            if (gameState.timeLeft <= 5) elTimer.classList.add('danger');
            else if (gameState.timeLeft <= 10) elTimer.classList.add('warning');
            if (gameState.timeLeft <= 0) endGame(false);
        }, 1000);
    }

    function stopTimers() {
        if (gameState.timer) { clearInterval(gameState.timer); gameState.timer = null; }
    }

    function startGame() {
        elStartBtn.disabled = true;
        elStartBtn.textContent = '⏳ Cargando...';
        hideResult();
        var xhr = new XMLHttpRequest();
        xhr.open('GET', 'game.php?page=minijuegonavidad&mode=start', true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200) { onStartError('Error de conexión'); return; }
            var data; try { data = JSON.parse(xhr.responseText); } catch (e) { onStartError('Respuesta inválida'); return; }
            if (!data.success) {
                if (data.error === 'cooldown') onStartError('Cooldown activo: ' + (data.cooldown_text || ''));
                else onStartError('Error: ' + data.error);
                return;
            }
            gameState.token = data.token;
            beginGame();
        };
        xhr.send();
    }

    function onStartError(msg) {
        elStartBtn.disabled = false;
        elStartBtn.textContent = '▶ Iniciar Juego';
        showResult('❌ Error', msg, '', true);
    }

    function beginGame() {
        gameState.running = true;
        gameState.pairsFound = 0;
        gameState.timeLeft = CONFIG.duration;
        elTimer.textContent = CONFIG.duration;
        elPairs.textContent = '0';
        elTimer.classList.remove('warning', 'danger');
        elStartBtn.textContent = '🎮 Jugando...';
        createBoard();
        startTimer();
    }

    function endGame(won) {
        if (!gameState.running) return;
        gameState.running = false;
        stopTimers();
        elStartBtn.disabled = true;
        elStartBtn.textContent = '⏳ Guardando...';
        var parejas = gameState.matched;
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'game.php?page=minijuegonavidad&mode=finish', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            if (xhr.status !== 200) { onEndError('Error de conexión'); return; }
            var data; try { data = JSON.parse(xhr.responseText); } catch (e) { onEndError('Respuesta inválida'); return; }
            if (!data.success) { onEndError('Error: ' + data.error); return; }
            onEndSuccess(data, won);
        };
        var body = 'token=' + encodeURIComponent(gameState.token);
        for (var i = 0; i < parejas.length; i++) body += '&parejas[]=' + encodeURIComponent(parejas[i]);
        xhr.send(body);
    }

    function onEndError(msg) {
        elStartBtn.textContent = '▶ Iniciar Juego';
        showResult('❌ Error al guardar', msg, '', true);
        startCooldownCountdown(CONFIG.cooldownHours * 3600);
    }

    function onEndSuccess(data, won) {
        var bodyHtml = 'Parejas encontradas: <strong style="color:#00e0ff;">' + data.parejas + '/8</strong>';
        var rewardHtml = '';
        if (data.recompensas && data.recompensas.length > 0) {
            rewardHtml = '<div style="margin-top:8px;">';
            for (var i = 0; i < data.recompensas.length; i++) rewardHtml += '<div style="color:#fbbf24; font-weight:700;">🎁 ' + data.recompensas[i].texto + '</div>';
            rewardHtml += '</div>';
        } else {
            rewardHtml = '<span style="color:#94a3b8;">No encontraste ninguna pareja</span>';
        }
        var title = won ? '🎉 ¡Completaste todas las parejas!' : '⏰ ¡Fin del tiempo!';
        showResult(title, bodyHtml, rewardHtml, false);
        startCooldownCountdown(CONFIG.cooldownHours * 3600);
        setTimeout(function() { window.location.reload(); }, 5000);
        elStartBtn.textContent = '✅ Completado';
    }

    // ─── FUNCIÓN DEL COOLDOWN EXACTAMENTE IGUAL AL TOPO ───
    function startCooldownCountdown(seconds) {
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
                elStartBtn.textContent = '▶ Iniciar Juego';
                return;
            }
            elCooldownTimer.textContent = formatCooldown(remaining);
            remaining--;
        }
        
        tick();
        gameState.cooldownTimer = setInterval(tick, 1000);
    }

    function init() {
        elTimer = document.getElementById('navidad_timer');
        elPairs = document.getElementById('navidad_pairs');
        elStartBtn = document.getElementById('navidad_start_btn');
        elBoard = document.getElementById('navidad_board');
        elResult = document.getElementById('navidad_result');
        elResultTitle = document.getElementById('navidad_result_title');
        elResultBody = document.getElementById('navidad_result_body');
        elResultReward = document.getElementById('navidad_result_reward');
        elCooldownBox = document.getElementById('navidad_cooldown_box');
        elCooldownTimer = document.getElementById('navidad_cooldown_timer');

        createBoard();

        document.addEventListener('pointerdown', function(e) {
            if (!elBoard) return;
            var card = e.target.closest ? e.target.closest('.astronavidad_card') : null;
            if (!card) return;
            if (!elBoard.contains(card)) return;
            e.preventDefault();
            flipCard(card);
        }, true);

        if (!window.PointerEvent) {
            document.addEventListener('mousedown', function(e) {
                if (!elBoard) return;
                var card = e.target.closest ? e.target.closest('.astronavidad_card') : null;
                if (!card) return;
                if (!elBoard.contains(card)) return;
                e.preventDefault();
                flipCard(card);
            }, true);
        }

        elStartBtn.addEventListener('click', function() { if (!elStartBtn.disabled) startGame(); });
        
        // Arrancar countdown si está en cooldown
        {if !$navidad_stats.can_play}
            startCooldownCountdown({$navidad_stats.cooldown_left});
        {/if}
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
    else init();
})();
</script>
{/block}