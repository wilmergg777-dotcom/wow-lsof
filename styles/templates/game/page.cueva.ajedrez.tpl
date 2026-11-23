{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.cueva.ajedrez.tpl === *}
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
{literal}
.cp_wrap { max-width: 1100px; margin: 20px auto; padding: 15px; font-family: 'Segoe UI', sans-serif; }
.cp_header { background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(6px); border: 1px solid #1e293b; border-radius: 12px; padding: 20px; margin-bottom: 20px; text-align: center; }
.cp_title { font-size: 22px; color: #00e0ff; font-weight: 800; margin-bottom: 10px; }
.cp_stats { display: flex; justify-content: center; gap: 30px; font-size: 14px; color: #cbd5e1; margin-bottom: 10px; flex-wrap: wrap; }
.cp_stats b { color: #fbbf24; }
.cp_turno { padding: 10px 20px; border-radius: 8px; font-weight: bold; display: inline-block; margin-top: 10px; }
.cp_turno.mio { background: rgba(74, 255, 136, 0.2); color: #4aff88; border: 1px solid #4aff88; }
.cp_turno.suyo { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid #ef4444; }
.cp_turno.espera { background: rgba(148, 163, 184, 0.2); color: #94a3b8; border: 1px solid #94a3b8; }
.cp_turno.fin { background: rgba(251, 191, 36, 0.2); color: #fbbf24; border: 1px solid #fbbf24; }

.cp_timer_box { background: rgba(0,0,0,0.5); border: 1px solid #1e293b; border-radius: 8px; padding: 10px 20px; margin-top: 15px; display: inline-block; }
.cp_timer_box span { color: #cbd5e1; font-weight: bold; font-size: 14px; }
#cp_timer { font-size: 24px; color: #fbbf24; margin-left: 10px; font-weight: bold; }

.cp_grids { display: flex; gap: 20px; justify-content: center; flex-wrap: wrap; }
.cp_box { background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(6px); border: 1px solid #1e293b; border-radius: 12px; padding: 20px; }
.cp_box h3 { margin: 0 0 15px 0; color: #cbd5e1; text-align: center; font-size: 16px; text-transform: uppercase; letter-spacing: 1px; }

#chessboard { margin: 0 auto; }
.chessboard-brd { border-radius: 8px; overflow: hidden; box-shadow: 0 0 20px rgba(0, 224, 255, 0.2); }

.cp_mov_box { background: rgba(15, 23, 42, 0.75); border: 1px solid #1e293b; border-radius: 12px; padding: 15px; margin-top: 20px; max-width: 800px; margin-left: auto; margin-right: auto; }
.cp_mov_box h3 { color: #cbd5e1; margin: 0 0 10px 0; font-size: 14px; text-transform: uppercase; letter-spacing: 1px; }
#movimientos { color: #94a3b8; font-family: 'Courier New', monospace; font-size: 13px; background: rgba(0,0,0,0.4); padding: 10px; border-radius: 6px; max-height: 120px; overflow-y: auto; line-height: 1.5; }

.cp_actions { text-align: center; margin-top: 20px; }
.cp_btn { padding: 12px 24px; border: none; border-radius: 8px; font-weight: 700; font-size: 14px; cursor: pointer; color: #fff; text-transform: uppercase; transition: 0.2s; }
.cp_btn:hover { transform: translateY(-2px); }
.cp_btn_green { background: linear-gradient(135deg, #15803d, #22c55e); box-shadow: 0 0 15px rgba(34, 197, 94, 0.4); }
.cp_btn_red { background: linear-gradient(135deg, #b91c1c, #ef4444); box-shadow: 0 0 15px rgba(239, 68, 68, 0.4); }
.cp_btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

.cp_alert { padding: 15px; border-radius: 8px; margin-bottom: 15px; font-weight: bold; text-align: center; display: none; }
.cp_alert_ok { background: rgba(74, 255, 136, 0.2); color: #4aff88; border: 1px solid #4aff88; }
.cp_alert_err { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid #ef4444; }

.cp_modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.85); z-index: 9999; backdrop-filter: blur(4px); align-items: center; justify-content: center; }
.cp_modal_caja { background: rgba(15, 23, 42, 0.95); padding: 40px; border-radius: 12px; border: 2px solid #fbbf24; text-align: center; max-width: 500px; }
.cp_modal_caja h2 { color: #fbbf24; font-size: 28px; margin-top: 0; }
.cp_modal_caja p { color: #cbd5e1; font-size: 16px; margin-bottom: 25px; line-height: 1.6; }
{/literal}
</style>

<div class="cp_wrap">

    <!-- HEADER -->
    <div class="cp_header">
        <div class="cp_title">♟️ Ajedrez - Sala #{$sala_id}</div>
        <div class="cp_stats">
            <span>Yo: <b>{$mi_nombre}</b> ({if $soy_blancas}Blancas{else}Negras{/if})</span>
            <span>Pozo: <b>{$pozo|number_format:0:',':'.'} {$moneda_label}</b></span>
            <span>Rival: <b>{$rival_nombre}</b></span>
        </div>

        {if $estado == 'jugando' && $sala_estado == 'jugando'}
            {if $mi_turno}
                <div class="cp_turno mio">🎯 Es tu turno</div>
            {else}
                <div class="cp_turno suyo">⏳ Esperando al rival...</div>
            {/if}
            <div class="cp_timer_box">
                <span>Tiempo de turno:</span>
                <span id="cp_timer">01:00</span>
            </div>
        {else}
            <div class="cp_turno fin">🏁 Partida finalizada</div>
        {/if}
    </div>

    <div id="cp_alert" class="cp_alert"></div>

    <!-- TABLERO -->
    <div class="cp_grids">
        <div class="cp_box" style="padding: 30px;">
            <h3>Tablero</h3>
            <div id="chessboard" style="width: 480px; height: 480px;"></div>
        </div>
    </div>

    <!-- MOVIMIENTOS -->
    <div class="cp_mov_box">
        <h3>Movimientos</h3>
        <div id="movimientos">{$historial}</div>
    </div>

    <!-- ACCIONES -->
    {if $estado == 'jugando' && $sala_estado == 'jugando'}
    <div class="cp_actions">
        <button class="cp_btn cp_btn_red" id="btn_rendirse">🏳️ Rendirse</button>
    </div>
    {/if}

</div>

<!-- MODAL FIN -->
<div class="cp_modal" id="modal_fin">
    <div class="cp_modal_caja">
        <h2 id="modal_titulo"></h2>
        <p id="modal_mensaje"></p>
        <a href="{$url_lobby}" class="cp_btn cp_btn_green" style="text-decoration:none;">Volver al Lobby</a>
    </div>
</div>

<!-- CDNs: jQuery + chessboard.js + chess.js -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet" href="https://unpkg.com/@chrisoakman/chessboardjs@1.0.0/dist/chessboard-1.0.0.min.css">
<script src="https://unpkg.com/@chrisoakman/chessboardjs@1.0.0/dist/chessboard-1.0.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/chess.js/0.10.3/chess.min.js"></script>

<script>
{literal}
(function(){
    var URL_AJAX     = '{/literal}{$url_ajax}{literal}';
    var SALA_ID      = {/literal}{$sala_id}{literal};
    var MI_ID        = {/literal}{$mi_id}{literal};
    var RIVAL_ID     = {/literal}{$rival_id}{literal};
    var SOY_BLANCAS  = {/literal}{if $soy_blancas}true{else}false{/if}{literal};
    var FEN_INICIAL  = '{/literal}{$fen}{literal}';
    var ESTADO       = '{/literal}{$estado}{literal}';
    var GANADOR      = {/literal}{if $ganador !== null}{$ganador}{else}null{/if}{literal};
    var TIEMPO_INICIAL = {/literal}{$time_left}{literal};
    var POZO         = {/literal}{$pozo}{literal};
    var MONEDA       = '{/literal}{$moneda_label}{literal}';

    var STATE = {
        miTurno: {/literal}{if $mi_turno}true{else}false{/if}{literal},
        enJuego: (ESTADO === 'jugando')
    };

    var board = null;
    var game  = new Chess(FEN_INICIAL);
    var timerInterval = null;

    function alerta(tipo, texto) {
        var cls = (tipo === 'ok') ? 'cp_alert_ok' : 'cp_alert_err';
        $('#cp_alert').attr('class', 'cp_alert ' + cls).html(texto).fadeIn();
        if (tipo === 'ok') setTimeout(function(){ $('#cp_alert').fadeOut(); }, 4000);
    }

    function actualizarHistorial(pgn) {
        $('#movimientos').text(pgn || '—');
        $('#movimientos').scrollTop($('#movimientos')[0].scrollHeight);
    }

    function onDrop(source, target) {
        if (!STATE.enJuego || !STATE.miTurno) return 'snapback';

        // Promoción automática a Dama (simplificación)
        var move = game.move({ from: source, to: target, promotion: 'q' });
        if (move === null) return 'snapback';

        board.position(game.fen(), false);
        actualizarHistorial(game.pgn());

        var estado  = 'jugando';
        var ganador = null;
        var motivo  = null;

        if (game.in_checkmate()) {
            estado = 'jaque_mate';
            var winnerColor = (game.turn() === 'w') ? 'b' : 'w';
            if (winnerColor === 'w') {
                ganador = SOY_BLANCAS ? MI_ID : RIVAL_ID;
            } else {
                ganador = SOY_BLANCAS ? RIVAL_ID : MI_ID;
            }
            motivo = 'Jaque mate';
        } else if (game.in_stalemate()) {
            estado = 'ahogado';
            motivo = 'Rey ahogado';
        } else if (game.in_threefold_repetition()) {
            estado = 'tablas';
            motivo = 'Triple repetición';
        } else if (game.insufficient_material()) {
            estado = 'tablas';
            motivo = 'Material insuficiente';
        } else if (game.in_draw()) {
            estado = 'tablas';
            motivo = 'Tablas';
        }

        var payload = {
            accion:    'mover_ajedrez',
            sala:      SALA_ID,
            fen:       game.fen(),
            historial: game.pgn(),
            estado:    estado
        };
        if (ganador !== null) payload.ganador = ganador;
        if (motivo  !== null) payload.motivo  = motivo;

        STATE.miTurno = false;

        $.post(URL_AJAX, payload)
        .done(function(r){
            if (!r.ok) {
                alerta('err', r.error || 'Movimiento rechazado');
                game.undo();
                board.position(game.fen(), false);
                STATE.miTurno = true;
                return;
            }
            if (estado !== 'jugando') {
                finalizarPartida(estado, ganador);
            }
        })
        .fail(function(){
            alerta('err', 'Error de conexión');
            game.undo();
            board.position(game.fen(), false);
            STATE.miTurno = true;
        });
    }

    function iniciarTimer(segundos) {
        if (timerInterval) clearInterval(timerInterval);
        var tiempo = parseInt(segundos);
        if (isNaN(tiempo) || tiempo < 0) tiempo = 0;

        function pintar() {
            var m = Math.floor(tiempo / 60);
            var s = tiempo % 60;
            var txt = (m < 10 ? '0' : '') + m + ':' + (s < 10 ? '0' : '') + s;
            $('#cp_timer').text(txt);
            if (tiempo <= 10) {
                $('#cp_timer').css('color', '#ef4444');
            } else {
                $('#cp_timer').css('color', '#fbbf24');
            }
        }
        pintar();

        if (tiempo <= 0) { verificarTimeout(); return; }

        timerInterval = setInterval(function(){
            tiempo--;
            pintar();
            if (tiempo <= 0) {
                clearInterval(timerInterval);
                verificarTimeout();
            }
        }, 1000);
    }

    function verificarTimeout() {
        $.post(URL_AJAX, { accion: 'check_ajedrez', sala: SALA_ID })
        .done(function(r){
            if (r.ok && r.estado !== 'jugando') {
                finalizarPartida(r.estado, r.ganador);
            } else {
                location.reload();
            }
        });
    }

    function finalizarPartida(estado, ganador) {
        STATE.enJuego = false;
        STATE.miTurno = false;
        if (timerInterval) clearInterval(timerInterval);

        var gane = (ganador !== null && parseInt(ganador) === parseInt(MI_ID));
        var titulo = '🏁 Partida finalizada';
        var mensaje = '';

        if (estado === 'jaque_mate') {
            titulo  = gane ? '🏆 ¡JAQUE MATE - VICTORIA!' : '💀 JAQUE MATE - DERROTA';
            mensaje = gane ? 'Has ganado el pozo de <b>' + POZO + '</b> ' + MONEDA
                           : 'Has perdido el pozo de <b>' + POZO + '</b> ' + MONEDA;
        } else if (estado === 'timeout') {
            titulo  = gane ? '⏰ ¡VICTORIA POR TIMEOUT!' : '⏰ DERROTA POR TIMEOUT';
            mensaje = gane ? 'El rival no movió a tiempo. Ganaste <b>' + POZO + '</b> ' + MONEDA
                           : 'No moviste a tiempo. Perdiste <b>' + POZO + '</b> ' + MONEDA;
        } else if (estado === 'rendicion') {
            titulo  = gane ? '🏆 ¡VICTORIA!' : '🏳️ TE RENDISTE';
            mensaje = gane ? 'El rival se rindió. Ganaste <b>' + POZO + '</b> ' + MONEDA
                           : 'Has perdido el pozo de <b>' + POZO + '</b> ' + MONEDA;
        } else if (estado === 'tablas') {
            titulo  = '🤝 TABLAS';
            mensaje = 'La partida terminó en tablas. Se devuelve la apuesta a ambos jugadores.';
        } else if (estado === 'ahogado') {
            titulo  = '🤝 REY AHOGADO (TABLAS)';
            mensaje = 'Rey ahogado. Se devuelve la apuesta a ambos jugadores.';
        } else if (estado === 'cancelada') {
            titulo  = '⚠️ PARTIDA CANCELADA';
            mensaje = 'La partida fue cancelada. Se devuelve la apuesta a ambos jugadores.';
        } else {
            mensaje = 'La partida ha finalizado.';
        }

        $('#modal_titulo').text(titulo);
        $('#modal_mensaje').html(mensaje);
        $('#modal_fin').css('display', 'flex');
    }

    function polling() {
        if (!STATE.enJuego) return;

        $.post(URL_AJAX, { accion: 'check_ajedrez', sala: SALA_ID })
        .done(function(r){
            if (!r.ok) return;

            if (r.estado !== 'jugando' || r.sala_estado !== 'jugando') {
                finalizarPartida(r.estado, r.ganador);
                return;
            }

            if (r.fen !== game.fen()) {
                game.load(r.fen);
                board.position(r.fen, true);
                if (r.historial) actualizarHistorial(r.historial);
                STATE.miTurno = r.mi_turno;
                iniciarTimer(r.time_left);
            }
        });
    }

    $('#btn_rendirse').on('click', function(){
        if (!confirm('¿Rendirse? Perderás el pozo de ' + POZO + ' ' + MONEDA + '.')) return;
        $.post(URL_AJAX, { accion: 'rendirse', sala: SALA_ID })
        .done(function(r){
            if (r.ok) {
                finalizarPartida('rendicion', RIVAL_ID);
            } else {
                alerta('err', r.error || 'No se pudo procesar la rendición');
            }
        });
    });

    $(document).ready(function(){
        board = Chessboard('chessboard', {
            position: FEN_INICIAL,
            orientation: SOY_BLANCAS ? 'white' : 'black',
            draggable: true,
            onDrop: onDrop,
            pieceTheme: 'https://chessboardjs.com/img/chesspieces/wikipedia/{piece}.png',
            showNotation: true
        });

        $(window).on('resize', function(){ if (board) board.resize(); });

        actualizarHistorial(game.pgn());

        if (ESTADO !== 'jugando') {
            finalizarPartida(ESTADO, GANADOR);
            return;
        }

        if (TIEMPO_INICIAL > 0) {
            iniciarTimer(TIEMPO_INICIAL);
        } else {
            verificarTimeout();
        }

        setInterval(polling, 3000);
    });
})();
{/literal}
</script>

{/block}