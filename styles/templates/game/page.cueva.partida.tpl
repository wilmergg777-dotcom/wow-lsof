{block name="content"}

<style>
{literal}
.cp_wrap { max-width: 1100px; margin: 20px auto; padding: 15px; font-family: 'Segoe UI', sans-serif; }
.cp_header { background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(6px); border: 1px solid #1e293b; border-radius: 12px; padding: 20px; margin-bottom: 20px; text-align: center; }
.cp_title { font-size: 22px; color: #00e0ff; font-weight: 800; margin-bottom: 10px; }
.cp_stats { display: flex; justify-content: center; gap: 30px; font-size: 14px; color: #cbd5e1; margin-bottom: 10px; }
.cp_stats b { color: #fbbf24; }
.cp_turno { padding: 10px 20px; border-radius: 8px; font-weight: bold; display: inline-block; margin-top: 10px; }
.cp_turno.mio { background: rgba(74, 255, 136, 0.2); color: #4aff88; border: 1px solid #4aff88; }
.cp_turno.suyo { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid #ef4444; }
.cp_turno.espera { background: rgba(148, 163, 184, 0.2); color: #94a3b8; border: 1px solid #94a3b8; }

/* RELOJ CONTADOR */
.cp_timer_box { background: rgba(0,0,0,0.5); border: 1px solid #1e293b; border-radius: 8px; padding: 10px 20px; margin-top: 15px; display: inline-block; }
.cp_timer_box span { color: #cbd5e1; font-weight: bold; font-size: 14px; }
#cp_timer { font-size: 24px; color: #fbbf24; margin-left: 10px; font-weight: bold; }

.cp_grids { display: flex; gap: 20px; justify-content: center; flex-wrap: wrap; }
.cp_box { background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(6px); border: 1px solid #1e293b; border-radius: 12px; padding: 20px; }
.cp_box h3 { margin: 0 0 15px 0; color: #cbd5e1; text-align: center; font-size: 16px; text-transform: uppercase; letter-spacing: 1px; }

.cp_grid { display: grid; grid-template-columns: 25px repeat(10, 32px); grid-template-rows: 25px repeat(10, 32px); gap: 3px; }
.cp_letra { display: flex; align-items: center; justify-content: center; color: #64748b; font-size: 11px; font-weight: bold; }
.cp_cell { width: 32px; height: 32px; border-radius: 4px; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: bold; transition: 0.2s; cursor: default; position: relative; }
.cp_cell.vacio { background: #1e293b; }

/* DISEÑO AZUL CON ANCLA */
.cp_cell.nave { 
    background: #3b82f6; 
    box-shadow: inset 0 0 5px rgba(255,255,255,0.5); 
}
.cp_cell.nave::after {
    content: "⚓";
    color: rgba(255,255,255,0.9);
    font-size: 16px;
    text-shadow: 0 0 3px #000;
}

.cp_cell.tocado { background: #ef4444; color: #fff; box-shadow: inset 0 0 10px #7f1d1d; }
.cp_cell.tocado::after { content: "X"; font-size: 20px; font-weight: 900; }
.cp_cell.hundido { background: #7f1d1d; color: #fca5a5; box-shadow: inset 0 0 10px #000; }
.cp_cell.hundido::after { content: "☠"; font-size: 16px; }
.cp_cell.agua { background: #0f172a; color: #64748b; }
.cp_cell.agua::after { content: "•"; font-size: 24px; }
.cp_cell.clickable { cursor: pointer; }
.cp_cell.clickable:hover { transform: scale(1.1); box-shadow: 0 0 10px #00e0ff; z-index: 10; }

.cp_actions { text-align: center; margin-top: 20px; }
.cp_btn { padding: 12px 24px; border: none; border-radius: 8px; font-weight: 700; font-size: 14px; cursor: pointer; color: #fff; text-transform: uppercase; transition: 0.2s; }
.cp_btn:hover { transform: translateY(-2px); }
.cp_btn_green { background: linear-gradient(135deg, #15803d, #22c55e); box-shadow: 0 0 15px rgba(34, 197, 94, 0.4); }
.cp_btn_blue { background: linear-gradient(135deg, #0066cc, #0099ff); box-shadow: 0 0 15px rgba(0, 153, 255, 0.4); }
.cp_btn_red { background: linear-gradient(135deg, #b91c1c, #ef4444); box-shadow: 0 0 15px rgba(239, 68, 68, 0.4); }
.cp_btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

.cp_alert { padding: 15px; border-radius: 8px; margin-bottom: 15px; font-weight: bold; text-align: center; display: none; }
.cp_alert_ok { background: rgba(74, 255, 136, 0.2); color: #4aff88; border: 1px solid #4aff88; }
.cp_alert_err { background: rgba(239, 68, 68, 0.2); color: #ef4444; border: 1px solid #ef4444; }

.cp_modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.85); z-index: 9999; backdrop-filter: blur(4px); align-items: center; justify-content: center; }
.cp_modal_caja { background: rgba(15, 23, 42, 0.95); padding: 40px; border-radius: 12px; border: 2px solid #fbbf24; text-align: center; }
.cp_modal_caja h2 { color: #fbbf24; font-size: 28px; margin-top: 0; }
.cp_modal_caja p { color: #cbd5e1; font-size: 16px; margin-bottom: 25px; }
{/literal}
</style>

<div class="cp_wrap">

    <!-- HEADER -->
    <div class="cp_header">
        <div class="cp_title">🏴‍☠️ Hundir la Flota - Sala #{$sala_id}</div>
        <div class="cp_stats">
            <span>Yo: <b>{$mi_nombre}</b></span>
            <span>Pozo: <b>{$pozo|number_format:0:',':'.'} {$moneda_label}</b></span>
            <span>Rival: <b>{if $rival_nombre}{$rival_nombre}{else}Esperando...{/if}</b></span>
        </div>
        <div class="cp_stats" style="margin-top: 10px;">
            <span>Impactos (Yo): <b style="color:#4aff88;">{$mis_impactos} / 20</b></span>
            <span>Impactos (Rival): <b style="color:#ef4444;">{$rival_impactos} / 20</b></span>
        </div>
        
        {if $fase == 'colocacion'}
            <div class="cp_turno espera">Colocando flota</div>
            {if $rival_nombre}
            <div class="cp_timer_box">
                <span>Tiempo para colocar naves:</span>
                <span id="cp_timer">02:00</span>
            </div>
            {/if}
        {elseif $mi_turno}
            <div class="cp_turno mio">🎯 Es tu turno</div>
            <div class="cp_timer_box">
                <span>Tiempo para disparar:</span>
                <span id="cp_timer">01:00</span>
            </div>
        {else}
            <div class="cp_turno suyo">⏳ Esperando al rival...</div>
            <div class="cp_timer_box">
                <span>Tiempo del rival:</span>
                <span id="cp_timer">01:00</span>
            </div>
        {/if}
    </div>

    <div id="cp_alert" class="cp_alert"></div>

    <!-- FASE DE COLOCACIÓN -->
    {if $en_colocacion}
        <div class="cp_grids">
            <div class="cp_box">
                <h3>Tu Flota</h3>
                <div class="cp_grid" id="grid_colocacion">
                    <div></div>
                    {foreach $letras as $letra}
                        <div class="cp_letra">{$letra}</div>
                    {/foreach}
                    {for $fila=1 to 10}
                        <div class="cp_letra">{$fila}</div>
                        {for $col=0 to 9}
                            {assign var=coord value="`$letras[$col]``$fila`"}
                            <div class="cp_cell vacio" data-coord="{$coord}"></div>
                        {/for}
                    {/for}
                </div>
                <div class="cp_actions">
                    {if !$ya_coloque}
                        <button class="cp_btn cp_btn_blue" id="btn_random">🎲 Generar Aleatoria</button>
                        <button class="cp_btn cp_btn_green" id="btn_confirmar" disabled>✅ Confirmar Flota</button>
                    {else}
                        <div class="cp_alert cp_alert_ok" style="display:block;">Flota confirmada. {if $rival_coloco}Iniciando partida...{else}Esperando rival...{/if}</div>
                    {/if}
                </div>
            </div>
        </div>
    {/if}

    <!-- FASE DE DISPAROS -->
    {if $fase == 'disparos' || $fase == 'fin'}
        <div class="cp_grids">
            <!-- Mi Tablero -->
            <div class="cp_box">
                <h3>Tu Tablero</h3>
                <div class="cp_grid">
                    <div></div>
                    {foreach $letras as $letra}
                        <div class="cp_letra">{$letra}</div>
                    {/foreach}
                    {foreach $mi_tablero as $idx => $c}
                        {if $idx % 10 == 0}
                            <div class="cp_letra">{($idx/10)|intval + 1}</div>
                        {/if}
                        <div class="cp_cell {$c.estado}" data-coord="{$c.coord}"></div>
                    {/foreach}
                </div>
            </div>

            <!-- Tablero Rival -->
            <div class="cp_box">
                <h3>Tablero Rival</h3>
                <div class="cp_grid" id="grid_rival">
                    <div></div>
                    {foreach $letras as $letra}
                        <div class="cp_letra">{$letra}</div>
                    {/foreach}
                    {foreach $tablero_rival as $idx => $c}
                        {if $idx % 10 == 0}
                            <div class="cp_letra">{($idx/10)|intval + 1}</div>
                        {/if}
                        <div class="cp_cell {$c.estado} {if $mi_turno && $c.estado == 'vacio'}clickable{/if}" data-coord="{$c.coord}"></div>
                    {/foreach}
                </div>
            </div>
        </div>
        {if $fase == 'disparos'}
            <div class="cp_actions">
                <button class="cp_btn cp_btn_red" id="btn_rendirse">🏳️ Rendirse</button>
            </div>
        {/if}
    {/if}

</div>

<!-- MODAL ESPERA (Aparece solo si aún no hay rival) -->
{if !$rival_nombre}
<div class="cp_modal" id="modal_espera" style="display: flex;">
    <div class="cp_modal_caja" style="border-color: #00e0ff;">
        <h2 style="color: #00e0ff;">⏳ Esperando Rival</h2>
        <p id="espera_texto">Tu sala se volverá pública en:</p>
        <div id="espera_contador" style="font-size: 3.5rem; color: #fbbf24; font-weight: bold; margin: 15px 0; text-shadow: 0 0 20px rgba(251, 191, 36, 0.6);">05:00</div>
        <p style="font-size: 14px; margin-top: 10px; color: #94a3b8;">No cierres esta ventana. Serás redirigido automáticamente cuando alguien se una.</p>
        <a href="game.php?page=cuevaFlota" class="cp_btn cp_btn_red" style="text-decoration:none;">❌ Cancelar y Volver</a>
    </div>
</div>
{/if}

<!-- MODAL FIN -->
<div class="cp_modal" id="modal_fin">
    <div class="cp_modal_caja">
        <h2 id="modal_titulo"></h2>
        <p id="modal_mensaje"></p>
        <a href="{$url_lobby}" class="cp_btn cp_btn_green" style="text-decoration:none;">Volver al Lobby</a>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
{literal}
(function(){
    var URL_AJAX = '{/literal}{$url_ajax}{literal}';
    var SALA_ID  = {/literal}{$sala_id}{literal};
    var FASE     = '{/literal}{$fase}{literal}';
    
    var MI_TURNO = {/literal}{if $mi_turno}true{else}false{/if}{literal};
    var TIENE_RIVAL = {/literal}{if $rival_nombre}true{else}false{/if}{literal};
    var YA_COLOQUE = {/literal}{if $ya_coloque}true{else}false{/if}{literal};
    
    // NUEVO: Recibir tiempo exacto y coordenadas de naves guardadas desde el PHP
    var TIEMPO_INICIAL = {/literal}{$time_left}{literal};
    var MIS_NAVES_GUARDADAS = [{/literal}{foreach from=$mi_flota_coords item=c}"{$c}",{/foreach}{literal}];

    var MI_FLOTA = [];
    var LETRAS = ['A','B','C','D','E','F','G','H','I','J'];
    var timerInterval = null;

    function alerta(tipo, texto) {
        var cls = tipo === 'ok' ? 'cp_alert_ok' : 'cp_alert_err';
        $('#cp_alert').attr('class', 'cp_alert ' + cls).html(texto).fadeIn();
        if (tipo === 'ok') setTimeout(function(){ $('#cp_alert').fadeOut(); }, 4000);
    }

    // --- GENERAR FLOTA ALEATORIA ---
    function generarFlota() {
        var ocupadas = {};
        var naves = [];
        var barcos = [
            {tipo: 'grande',  largo: 6, cant: 1},
            {tipo: 'mediana', largo: 4, cant: 2},
            {tipo: 'pequena', largo: 2, cant: 3}
        ];

        for (var b = 0; b < barcos.length; b++) {
            for (var n = 0; n < barcos[b].cant; n++) {
                var ok = false;
                while (!ok) {
                    var horiz = Math.random() < 0.5;
                    var col = Math.floor(Math.random() * 10);
                    var fila = Math.floor(Math.random() * 10);
                    var casillas = [];
                    var valido = true;

                    for (var i = 0; i < barcos[b].largo; i++) {
                        var c = horiz ? col + i : col;
                        var f = horiz ? fila : fila + i;
                        if (c > 9 || f > 9) { valido = false; break; }
                        var coord = LETRAS[c] + (f + 1);
                        if (ocupadas[coord]) { valido = false; break; }
                        casillas.push(coord);
                    }

                    if (valido) {
                        for (var k = 0; k < casillas.length; k++) ocupadas[casillas[k]] = true;
                        naves.push({tipo: barcos[b].tipo, casillas: casillas});
                        ok = true;
                    }
                }
            }
        }
        return naves;
    }

    function pintarFlota(naves) {
        $('#grid_colocacion .cp_cell').removeClass('nave').addClass('vacio');
        for (var i = 0; i < naves.length; i++) {
            for (var j = 0; j < naves[i].casillas.length; j++) {
                $('#grid_colocacion .cp_cell[data-coord="' + naves[i].casillas[j] + '"]').removeClass('vacio').addClass('nave');
            }
        }
    }

    $('#btn_random').on('click', function(){
        MI_FLOTA = generarFlota();
        pintarFlota(MI_FLOTA);
        $('#btn_confirmar').prop('disabled', false);
        alerta('ok', 'Flota generada. Revisá y confirmá.');
    });

    $('#btn_confirmar').on('click', function(){
        if (MI_FLOTA.length === 0) return;
        $(this).prop('disabled', true).text('Confirmando...');
        $.post(URL_AJAX, { accion: 'colocar_flota', sala: SALA_ID, flota: JSON.stringify(MI_FLOTA) })
        .done(function(r){
            if (r.ok) {
                alerta('ok', 'Flota confirmada. Esperando rival...');
                setTimeout(function(){ location.reload(); }, 1500);
            } else {
                alerta('err', r.error);
                $('#btn_confirmar').prop('disabled', false).text('✅ Confirmar Flota');
            }
        });
    });

    // --- DISPARAR ---
    $(document).on('click', '#grid_rival .cp_cell.clickable', function(){
        if (!MI_TURNO) return;
        var coord = $(this).data('coord');
        if (!confirm('¿Disparar a ' + coord + '?')) return;

        var $cell = $(this);
        $cell.removeClass('clickable');

        $.post(URL_AJAX, { accion: 'disparar', sala: SALA_ID, coord: coord })
        .done(function(r){
            if (!r.ok) {
                alerta('err', r.error);
                $cell.addClass('clickable');
                return;
            }

            $cell.removeClass('vacio');
            if (r.resultado === 'agua') {
                $cell.addClass('agua');
                alerta('ok', 'Agua en ' + coord);
            } else if (r.resultado === 'tocado') {
                $cell.addClass('tocado');
                alerta('ok', '¡Tocado en ' + coord + '!');
            } else if (r.resultado === 'hundido') {
                $cell.addClass('hundido');
                alerta('ok', '¡HUNDIDO en ' + coord + '!');
            }

            if (r.victoria) {
                setTimeout(function(){ finPartida(true); }, 800);
            } else {
                setTimeout(function(){ location.reload(); }, 1200);
            }
        });
    });

    // --- RENDIRSE ---
    $('#btn_rendirse').on('click', function(){
        if (!confirm('¿Rendirse? Perderás el pozo.')) return;
        $.post(URL_AJAX, { accion: 'rendirse', sala: SALA_ID })
        .done(function(r){
            if (r.ok) finPartida(false);
        });
    });

    // --- FIN DE PARTIDA ---
    function finPartida(gane) {
        $('#modal_titulo').text(gane ? '🏆 ¡VICTORIA!' : '💀 DERROTA');
        $('#modal_mensaje').html(gane 
            ? 'Has ganado el pozo de <b>{/literal}{$pozo|number_format:0:',':'.'}{literal} {/literal}{$moneda_label}{literal}</b>'
            : 'Has perdido el pozo de <b>{/literal}{$pozo|number_format:0:',':'.'}{literal} {/literal}{$moneda_label}{literal}</b>');
        $('#modal_fin').css('display', 'flex');
        if (timerInterval) clearInterval(timerInterval);
    }

    // --- FUNCIÓN PARA VERIFICAR TIMEOUT ---
    function verificarEstadoTimeout() {
        $.post(URL_AJAX, { accion: 'check_estado', sala: SALA_ID })
        .done(function(r){
            if (r.estado === 'cancelada') {
                alert('La partida ha sido cancelada por inactividad. Se ha devuelto el dinero.');
                location.href = 'game.php?page=cuevaFlota';
            } else if (r.estado === 'finalizada') {
                finPartida(r.gane_yo);
            } else {
                location.reload();
            }
        });
    }

    // --- LÓGICA DEL CONTADOR VISUAL BLINDADO ---
    function iniciarTimer(segundos) {
        if (timerInterval) clearInterval(timerInterval);
        
        var tiempo = parseInt(segundos);
        // BLINDAJE: Si el tiempo es negativo o inválido, forzar a 0
        if (isNaN(tiempo) || tiempo < 0) {
            tiempo = 0;
        }
        
        function updateUI() {
            var m = Math.floor(tiempo / 60);
            var s = tiempo % 60;
            $('#cp_timer').text((m<10?'0':'')+m+':'+(s<10?'0':'')+s);
            if (tiempo <= 10) $('#cp_timer').css('color', '#ef4444');
            else $('#cp_timer').css('color', '#fbbf24');
        }
        
        updateUI();
        
        // Si al cargar ya es 0 (o negativo), forzar verificación inmediata
        if (tiempo <= 0) {
            verificarEstadoTimeout();
            return;
        }
        
        timerInterval = setInterval(function() {
            tiempo--;
            updateUI();
            
            if (tiempo <= 0) {
                clearInterval(timerInterval);
                verificarEstadoTimeout();
            }
        }, 1000);
    }

    // --- INICIALIZACIÓN AL CARGAR LA PÁGINA ---
    $(document).ready(function() {
        // 1. Redibujar naves si el jugador recargó en la fase de colocación
        if (FASE === 'colocacion' && MIS_NAVES_GUARDADAS.length > 0) {
            for (var i = 0; i < MIS_NAVES_GUARDADAS.length; i++) {
                $('#grid_colocacion .cp_cell[data-coord="' + MIS_NAVES_GUARDADAS[i] + '"]').removeClass('vacio').addClass('nave');
            }
            // Habilitar el botón de confirmar en caso de que recargue y quiera confirmar
            if (!YA_COLOQUE) {
                $('#btn_confirmar').prop('disabled', false);
            }
        }

        // 2. Iniciar el reloj con el tiempo exacto del servidor
        if (TIENE_RIVAL) {
            if (TIEMPO_INICIAL > 0) {
                iniciarTimer(TIEMPO_INICIAL);
            } else {
                // Si el servidor dice que el tiempo es 0 o negativo, forzamos la verificación
                verificarEstadoTimeout();
            }
        }
    });

    // --- TIEMPO DE ESPERA (MODAL) ---
    if (!TIENE_RIVAL) {
        var llaveEspera = 'cueva_espera_' + SALA_ID;
        var start = localStorage.getItem(llaveEspera);
        if (!start) {
            start = Date.now();
            localStorage.setItem(llaveEspera, start);
        }

        var checkEspera = setInterval(function() {
            var ahora = Date.now();
            var pasado = Math.floor((ahora - start) / 1000);
            var restante = 300 - pasado;

            if (restante <= 0) {
                clearInterval(checkEspera);
                $('#espera_texto').html('<b style="color:#fbbf24;">Tu sala ahora es pública.</b><br>Esperando que alguien se una desde el lobby...');
                $('#espera_contador').hide();
            } else {
                var m = Math.floor(restante / 60);
                var s = restante % 60;
                $('#espera_contador').text((m<10?'0':'')+m+':'+(s<10?'0':'')+s);
            }

            $.post(URL_AJAX, { accion: 'check_estado', sala: SALA_ID })
            .done(function(r){
                if (r.ok && r.estado === 'jugando') {
                    clearInterval(checkEspera);
                    localStorage.removeItem(llaveEspera);
                    location.reload();
                }
                if (r.ok && r.estado === 'finalizada') {
                    location.href = 'game.php?page=cuevaFlota';
                }
            });
        }, 2000);
    }

    // --- POLLING (Recarga si cambia el turno o se cancela) ---
    if (FASE === 'disparos' && TIENE_RIVAL) {
        setInterval(function(){
            $.post(URL_AJAX, { accion: 'check_estado', sala: SALA_ID })
            .done(function(r){
                if (r.ok) {
                    if (r.estado === 'finalizada') {
                        finPartida(r.gane_yo);
                    } else if (r.estado === 'cancelada') {
                        alert('La partida ha sido cancelada por inactividad. Se ha devuelto el dinero.');
                        location.href = 'game.php?page=cuevaFlota';
                    } else if (r.mi_turno !== MI_TURNO) {
                        location.reload();
                    }
                }
            });
        }, 5000);
    }

    // --- AUTO-RECARGA EN COLOCACION ---
    if (FASE === 'colocacion' && TIENE_RIVAL) {
        setInterval(function(){
            $.post(URL_AJAX, { accion: 'check_estado', sala: SALA_ID })
            .done(function(r){
                if (r.ok) {
                    if (r.estado === 'cancelada') {
                        alert('La partida ha sido cancelada por inactividad. Se ha devuelto el dinero.');
                        location.href = 'game.php?page=cuevaFlota';
                    } else if (r.fase !== 'colocacion') {
                        location.reload();
                    }
                }
            });
        }, 4000);
    }
})();
{/literal}
</script>

{/block}