{block name="content"}

<style>
{literal}
:root {
    --cueva-bg: rgba(15, 23, 42, 0.75);
    --cueva-bg-hover: rgba(30, 41, 59, 0.85);
    --cueva-border: #1e293b;
    --cueva-cyan: #00e0ff;
    --cueva-gold: #fbbf24;
    --cueva-green: #4aff88;
    --cueva-red: #ef4444;
    --cueva-purple: #8b5cf6;
}

.cueva_wrap { max-width: 1200px; margin: 20px auto; padding: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }

/* HEADER TOP (Botón Volver + Título) */
.cueva_header_top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.btn_volver {
    display: inline-flex; align-items: center; gap: 8px;
    background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(6px);
    border: 1px solid #1e293b; color: #00e0ff;
    padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 700;
    text-decoration: none; text-transform: uppercase; transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
}
.btn_volver:hover {
    background: rgba(0, 224, 255, 0.15); border-color: #00e0ff;
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.4); transform: translateX(-3px);
}
.cueva_titulo { font-size: 24px; color: #fff; text-shadow: 0 0 10px rgba(0, 224, 255, 0.5); font-weight: 800; display: flex; align-items: center; gap: 10px; }

/* Tarjetas Glassmorphism */
.cueva_card {
    background: var(--cueva-bg);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--cueva-border);
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.cueva_card_header {
    font-size: 16px; color: var(--cueva-cyan); font-weight: 700;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 10px; margin-bottom: 15px;
    display: flex; justify-content: space-between; align-items: center;
}

/* Saldos */
.cueva_saldos { display: flex; gap: 20px; font-size: 14px; color: #cbd5e1; }
.cueva_saldos span { background: rgba(0, 0, 0, 0.3); padding: 5px 12px; border-radius: 6px; border-left: 3px solid var(--cueva-cyan); }
.cueva_saldos b { color: var(--cueva-gold); }

/* Formulario */
.cueva_form_row { display: flex; gap: 15px; align-items: flex-end; flex-wrap: wrap; }
.cueva_input_group { display: flex; flex-direction: column; gap: 5px; }
.cueva_input_group label { font-size: 12px; color: #94a3b8; font-weight: 600; text-transform: uppercase; }
.cueva_input, .cueva_select {
    background: rgba(0, 0, 0, 0.4); border: 1px solid var(--cueva-border);
    color: #fff; padding: 10px 15px; border-radius: 8px; font-size: 14px;
    outline: none; transition: all 0.2s;
}
.cueva_input:focus, .cueva_select:focus { border-color: var(--cueva-cyan); box-shadow: 0 0 10px rgba(0, 224, 255, 0.3); }
.cueva_input { width: 120px; }

/* Botones */
.cueva_btn {
    padding: 10px 20px; border: none; border-radius: 8px; cursor: pointer;
    font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 1px;
    transition: all 0.2s; display: inline-flex; align-items: center; gap: 8px;
}
.cueva_btn:hover { transform: translateY(-2px); }
.cueva_btn_cyan { background: linear-gradient(135deg, #0066cc, #0099ff); color: #fff; box-shadow: 0 0 15px rgba(0, 153, 255, 0.4); }
.cueva_btn_gold { background: linear-gradient(135deg, #b45309, #f59e0b); color: #fff; box-shadow: 0 0 15px rgba(245, 158, 11, 0.4); }
.cueva_btn_green { background: linear-gradient(135deg, #15803d, #22c55e); color: #fff; box-shadow: 0 0 15px rgba(34, 197, 94, 0.4); }
.cueva_btn_red { background: linear-gradient(135deg, #b91c1c, #ef4444); color: #fff; box-shadow: 0 0 15px rgba(239, 68, 68, 0.4); }
.cueva_btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

/* Tablas */
.cueva_table { width: 100%; border-collapse: collapse; font-size: 13px; }
.cueva_table th { text-align: left; padding: 10px; color: #94a3b8; border-bottom: 1px solid var(--cueva-border); font-size: 12px; text-transform: uppercase; }
.cueva_table td { padding: 12px 10px; border-bottom: 1px solid rgba(30, 41, 59, 0.5); color: #cbd5e1; vertical-align: middle; }
.cueva_table tr:hover { background: rgba(255, 255, 255, 0.03); }

/* Badges */
.cueva_badge { padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
.badge_ntx { background: rgba(59, 130, 246, 0.2); color: #93c5fd; border: 1px solid #3b82f6; }
.badge_untx { background: rgba(251, 191, 36, 0.2); color: #fde047; border: 1px solid #fbbf24; }
.badge_deut { background: rgba(74, 255, 136, 0.2); color: #86efac; border: 1px solid #4aff88; }
.badge_dust { background: rgba(139, 92, 246, 0.2); color: #c4b5fd; border: 1px solid #8b5cf6; }
.badge_blocked { background: rgba(255, 255, 255, 0.1); color: #94a3b8; border: 1px solid #475569; }

/* Alertas */
.cueva_alert { padding: 12px; border-radius: 8px; margin-bottom: 15px; font-weight: 600; display: none; font-size: 14px; }
.alert_error { background: rgba(239, 68, 68, 0.2); border: 1px solid #ef4444; color: #fca5a5; }
.alert_success { background: rgba(74, 255, 136, 0.2); border: 1px solid #4aff88; color: #86efac; }
.alert_info { background: rgba(0, 224, 255, 0.2); border: 1px solid #00e0ff; color: #67e8f9; }

/* Modal Planeta */
.cueva_modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.8); z-index: 9999; backdrop-filter: blur(4px); align-items: center; justify-content: center; }
.cueva_modal_content { background: var(--cueva-bg); padding: 25px; border-radius: 12px; border: 1px solid var(--cueva-cyan); width: 350px; text-align: center; box-shadow: 0 0 30px rgba(0, 224, 255, 0.2); }
.cueva_modal_content h3 { color: var(--cueva-cyan); margin-top: 0; }

/* Pantalla de Búsqueda */
.cueva_search_screen {
    text-align: center; padding: 40px 20px;
    background: rgba(0, 0, 0, 0.4); border-radius: 12px; border: 1px dashed var(--cueva-cyan);
}
.cueva_timer {
    font-size: 3.5rem; font-weight: 800; color: var(--cueva-gold);
    text-shadow: 0 0 20px rgba(251, 191, 36, 0.6); margin: 15px 0;
}
</style>
{/literal}

<div class="cueva_wrap">

    <!-- HEADER CON BOTÓN VOLVER -->
    <div class="cueva_header_top">
        <a href="game.php?page=cueva" class="btn_volver">
            <span>⬅️</span> Volver al Mercado
        </a>
        <div class="cueva_titulo">
            <span>🚢</span> Hundir la Flota
        </div>
    </div>

    <!-- ALERTAS -->
    <div id="cueva_alert" class="cueva_alert"></div>

    <!-- SALDOS -->
    <div class="cueva_card" style="padding: 15px 20px;">
        <div class="cueva_saldos">
            <span>Tu saldo: <b>{$saldo_riel|number_format:0:',':'.'} {$moneda_riel}</b></span>
            <span>Materia Oscura: <b>{$saldo_darkmatter|number_format:0:',':'.'}</b></span>
            {if $factor_riel == 2}
                <span style="border-left-color: var(--cueva-gold); color: var(--cueva-gold);">Modo Internacional (Apuesta x2)</span>
            {/if}
        </div>
    </div>

    <!-- CREAR MESA (FORMULARIO) -->
    <div class="cueva_card" id="cueva_card_crear">
        <div class="cueva_card_header">
            <span>⚓ Crear Mesa</span>
        </div>
        
        <div class="cueva_form_row">
            <div class="cueva_input_group">
                <label>Tipo de Apuesta</label>
                <select id="cueva_tipo" class="cueva_select">
                    {if $tipo_riel == 'NTX'}
                        <option value="NTX">NTX-20</option>
                    {else}
                        <option value="UNTX">UNTX-20</option>
                    {/if}
                    {if $planetas|@count > 0}
                        <option value="DEUT">Deuterio</option>
                    {/if}
                    <option value="DUST">Materia Oscura</option>
                </select>
            </div>

            <div class="cueva_input_group" id="cueva_box_planeta" style="display:none;">
                <label>Planeta (Deuterio)</label>
                <select id="cueva_planeta" class="cueva_select">
                    {foreach from=$planetas item=p}
                        <option value="{$p.id}">{$p.name} - {$p.deuterium|number_format:0:',':'.'}</option>
                    {/foreach}
                </select>
            </div>

            <div class="cueva_input_group">
                <label>Apuesta Base</label>
                <input type="number" id="cueva_apuesta" class="cueva_input" min="1" value="100">
            </div>

            <div class="cueva_input_group">
                <label>&nbsp;</label>
                <div style="font-size: 13px; color: #94a3b8; padding-bottom: 10px;" id="cueva_costo"></div>
            </div>

            <div class="cueva_input_group">
                <label>&nbsp;</label>
                <button id="cueva_btn_crear" class="cueva_btn cueva_btn_green">🎯 Crear Mesa</button>
            </div>
            
            <div class="cueva_input_group">
                <label>&nbsp;</label>
                <button id="cueva_btn_buscar" class="cueva_btn cueva_btn_gold">⚡ Búsqueda Rápida</button>
            </div>
        </div>
    </div>

    <!-- PANTALLA DE BÚSQUEDA (OCULTA POR DEFECTO) -->
    <div class="cueva_card" id="cueva_pantalla_busqueda" style="display: none;">
        <div class="cueva_card_header" style="justify-content: center; border-bottom: none;">
            <span>🔍 Buscando Partida...</span>
        </div>
        <div class="cueva_search_screen">
            <p style="color: #cbd5e1; font-size: 1.1rem; margin-bottom: 0;">Si no encontramos rival, tu sala se volverá pública en:</p>
            <div class="cueva_timer" id="cueva_timer_contador">05:00</div>
            <p style="color: #94a3b8; font-size: 13px; margin-bottom: 25px;">No cierres esta ventana.</p>
            <button id="cueva_btn_cancelar_busqueda" class="cueva_btn cueva_btn_red">❌ Cancelar Búsqueda</button>
        </div>
    </div>

    <!-- MIS PARTIDAS -->
    {if $mis_partidas|@count > 0}
    <div class="cueva_card">
        <div class="cueva_card_header">
            <span>🚢 Mis Partidas Activas</span>
        </div>
        <table class="cueva_table">
            <thead>
                <tr>
                    <th>Sala</th>
                    <th>Rival</th>
                    <th>Moneda</th>
                    <th>Pozo</th>
                    <th>Estado</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$mis_partidas item=pa}
                <tr>
                    <td>#{$pa.sala_id}</td>
                    <td>{if $pa.rival}{$pa.rival}{else}<i>Esperando rival...</i>{/if}</td>
                    <td><span class="cueva_badge badge_{$pa.tipo_apuesta|lower}">{$pa.moneda_label}</span></td>
                    <td style="color: var(--cueva_gold); font-weight: bold;">{$pa.pozo|number_format:0:',':'.'}</td>
                    <td>
                        {if $pa.fase == 'colocacion'}
                            Colocando flota
                        {elseif $pa.fase == 'disparos'}
                            {if $pa.mi_turno}
                                <span style="color: var(--cueva-green); font-weight: bold;">¡Tu Turno!</span>
                            {else}
                                Turno del Rival
                            {/if}
                        {/if}
                    </td>
                    <td>
                        {if $pa.fase == 'colocacion' || $pa.mi_turno}
                            <a href="game.php?page=cuevaPartida&sala={$pa.sala_id}" class="cueva_btn cueva_btn_cyan" style="padding: 6px 12px; font-size: 11px; text-decoration: none;">Entrar</a>
                        {else}
                            <a href="game.php?page=cuevaPartida&sala={$pa.sala_id}" class="cueva_btn" style="padding: 6px 12px; font-size: 11px; background: #334155; color: #fff; text-decoration: none;">Ver Tablero</a>
                        {/if}
                        {if $pa.fase == 'colocacion' && $pa.es_creador}
                            <button class="cueva_btn cueva_btn_red btn-cancelar" data-sala="{$pa.sala_id}" style="padding: 6px 12px; font-size: 11px;">Cancelar</button>
                        {/if}
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {/if}

    <!-- SALAS ABIERTAS -->
    <div class="cueva_card">
        <div class="cueva_card_header">
            <span>🌊 Salas Abiertas</span>
        </div>
        
        {if $salas|@count == 0}
            <div style="text-align: center; color: #94a3b8; padding: 20px;">No hay salas abiertas. ¡Creá una!</div>
        {else}
        <table class="cueva_table">
            <thead>
                <tr>
                    <th>Creador</th>
                    <th>Moneda</th>
                    <th>Apuesta</th>
                    <th>Pozo</th>
                    <th>Creada</th>
                    <th>Acción</th>
                </tr>
            </thead>
            <tbody>
                {foreach from=$salas item=s}
                <tr>
                    <td style="font-weight: bold; color: #fff;">{$s.creador}</td>
                    <td><span class="cueva_badge badge_{$s.tipo_apuesta|lower}">{$s.moneda_label}</span></td>
                    <td>{$s.apuesta_base|number_format:0:',':'.'}</td>
                    <td style="color: var(--cueva_gold); font-weight: bold;">{$s.pozo|number_format:0:',':'.'}</td>
                    <td style="font-size: 11px; color: #64748b;">{$s.fecha_creacion}</td>
                    <td>
                        {if $s.compatible}
                            {if $s.tipo_apuesta == 'DEUT'}
                                <button class="cueva_btn cueva_btn_green btn-aceptar-deut" data-sala="{$s.id}" style="padding: 6px 12px; font-size: 11px;">Aceptar (Elegir Planeta)</button>
                            {else}
                                <button class="cueva_btn cueva_btn_green btn-aceptar" data-sala="{$s.id}" style="padding: 6px 12px; font-size: 11px;">Aceptar</button>
                            {/if}
                        {else}
                            <span class="cueva_badge badge_blocked">Otra Moneda</span>
                        {/if}
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {/if}
    </div>

</div>

<!-- MODAL PARA ELEGIR PLANETA AL ACEPTAR DEUTERIO -->
<div id="cueva_modal_planeta" class="cueva_modal">
    <div class="cueva_modal_content">
        <h3>Elegir Planeta</h3>
        <p style="color: #cbd5e1; font-size: 13px; margin-bottom: 15px;">Selecciona desde qué planeta vas a apostar el deuterio.</p>
        <select id="cueva_modal_select_planeta" class="cueva_select" style="width: 100%; margin-bottom: 15px;">
            {foreach from=$planetas item=p}
                <option value="{$p.id}">{$p.name} - {$p.deuterium|number_format:0:',':'.'}</option>
            {/foreach}
        </select>
        <div style="display: flex; gap: 10px; justify-content: center;">
            <button id="cueva_modal_cancelar" class="cueva_btn cueva_btn_red" style="padding: 8px 15px;">Cancelar</button>
            <button id="cueva_modal_confirmar" class="cueva_btn cueva_btn_green" style="padding: 8px 15px;">Confirmar</button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
{literal}
(function(){
    var URL_AJAX = 'game.php?page=cuevaAjax';
    var FACTOR   = {/literal}{$factor_riel}{literal};
    var MONEDA   = '{/literal}{$moneda_riel}{literal}';

    // Variables para el control de la búsqueda
    var intervaloPolling = null;
    var intervaloContador = null;
    var salaBusquedaActual = null;

    // Mostrar/ocultar selector de planeta
    function actualizarFormulario() {
        var tipo = $('#cueva_tipo').val();
        
        if (tipo === 'DEUT') {
            $('#cueva_box_planeta').show();
        } else {
            $('#cueva_box_planeta').hide();
        }

        var base = parseInt($('#cueva_apuesta').val() || 0, 10);
        if (tipo === 'UNTX') {
            $('#cueva_costo').html('Costo real: <b style="color:var(--cueva-gold)">' + (base*2) + ' UNTX-20</b>');
        } else if (tipo === 'NTX') {
            $('#cueva_costo').html('Costo real: <b style="color:var(--cueva-cyan)">' + base + ' NTX-20</b>');
        } else {
            $('#cueva_costo').html('');
        }
    }
    $('#cueva_tipo').on('change', actualizarFormulario);
    $('#cueva_apuesta').on('input', actualizarFormulario);
    actualizarFormulario();

    // Mostrar alertas
    function msg(tipo, texto) {
        var cls = 'alert_info';
        if (tipo === 'error') cls = 'alert_error';
        if (tipo === 'success') cls = 'alert_success';
        
        $('#cueva_alert').attr('class', 'cueva_alert ' + cls).html(texto).fadeIn();
        if (tipo !== 'error') {
            setTimeout(function(){ $('#cueva_alert').fadeOut(); }, 4000);
        }
        $('html, body').animate({ scrollTop: 0 }, 300);
    }

    // Función para iniciar la búsqueda con contador
    function iniciarBusquedaUI(salaId) {
        salaBusquedaActual = salaId;
        $('#cueva_card_crear').slideUp();
        $('#cueva_pantalla_busqueda').slideDown();

        var tiempoRestante = 300; // 5 minutos

        // Contador visual
        intervaloContador = setInterval(function() {
            tiempoRestante--;
            var minutos = Math.floor(tiempoRestante / 60);
            var segundos = tiempoRestante % 60;
            var formato = (minutos < 10 ? "0" : "") + minutos + ":" + (segundos < 10 ? "0" : "") + segundos;
            
            $('#cueva_timer_contador').text(formato);

            if (tiempoRestante <= 0) {
                clearInterval(intervaloContador);
            }
        }, 1000);

        // Polling al servidor cada 5 segundos
        intervaloPolling = setInterval(function() {
            $.post(URL_AJAX, { accion: 'check_busqueda' })
            .done(function(res) {
                if (res.status === 'matched') {
                    detenerBusqueda();
                    msg('success', '¡Rival encontrado! Iniciando partida...');
                    setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + res.sala_id; }, 1500);
                } 
                else if (res.status === 'now_public') {
                    detenerBusqueda();
                    msg('info', 'No se encontró rival. Tu sala ahora es pública.');
                    setTimeout(function(){ location.reload(); }, 2500);
                } 
                else if (res.status === 'not_found') {
                    detenerBusqueda();
                    msg('error', 'La búsqueda fue cancelada.');
                    setTimeout(function(){ location.reload(); }, 2000);
                }
            });
        }, 5000);
    }

    // Función para detener los intervalos
    function detenerBusqueda() {
        if (intervaloPolling) clearInterval(intervaloPolling);
        if (intervaloContador) clearInterval(intervaloContador);
    }

    // EVENTO: Crear Sala
    $('#cueva_btn_crear').on('click', function(){
        var tipo = $('#cueva_tipo').val();
        var apuesta = $('#cueva_apuesta').val();
        var planeta = (tipo === 'DEUT') ? $('#cueva_planeta').val() : null;

        if (apuesta <= 0) { msg('error', 'Apuesta inválida'); return; }

        var $btn = $(this);
        $btn.prop('disabled', true).text('Creando...');
        
        $.post(URL_AJAX, { accion: 'crear_sala', tipo: tipo, apuesta: apuesta, planeta: planeta })
        .done(function(r){
            if (r.ok) {
                msg('success', '¡Sala creada! Esperando rival...');
                setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + r.sala_id; }, 1200);
            } else {
                msg('error', r.error || 'Error desconocido');
                $btn.prop('disabled', false).text('🎯 Crear Mesa');
            }
        })
        .fail(function(){
            msg('error', 'Error de conexión');
            $btn.prop('disabled', false).text('🎯 Crear Mesa');
        });
    });

    // EVENTO: Búsqueda Rápida
    $('#cueva_btn_buscar').on('click', function(){
        var tipo = $('#cueva_tipo').val();
        var apuesta = $('#cueva_apuesta').val();
        var planeta = (tipo === 'DEUT') ? $('#cueva_planeta').val() : null;

        if (apuesta <= 0) { msg('error', 'Apuesta inválida'); return; }

        var $btn = $(this);
        $btn.prop('disabled', true).text('Buscando...');

        $.post(URL_AJAX, { accion: 'buscar_rapida', tipo: tipo, apuesta: apuesta, planeta: planeta })
        .done(function(r){
            if (r.ok) {
                if (r.matcheada) {
                    msg('success', '¡Rival encontrado! Iniciando partida...');
                    setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + r.sala_id; }, 1500);
                } else {
                    // Activamos la pantalla de búsqueda con contador
                    iniciarBusquedaUI(r.sala_id);
                }
            } else {
                msg('error', r.error || 'Error desconocido');
                $btn.prop('disabled', false).text('⚡ Búsqueda Rápida');
            }
        })
        .fail(function(){
            msg('error', 'Error de conexión');
            $btn.prop('disabled', false).text('⚡ Búsqueda Rápida');
        });
    });

    // EVENTO: Cancelar Búsqueda (cuando está en el contador)
    $('#cueva_btn_cancelar_busqueda').on('click', function(){
        if (!salaBusquedaActual) return;
        
        var $btn = $(this);
        $btn.prop('disabled', true).text('Cancelando...');
        
        $.post(URL_AJAX, { accion: 'cancelar_sala', sala: salaBusquedaActual })
        .done(function(r){
            detenerBusqueda();
            if (r.ok) {
                msg('success', 'Búsqueda cancelada. Apuesta devuelta.');
                setTimeout(function(){ location.reload(); }, 1200);
            } else {
                msg('error', r.error || 'No se pudo cancelar.');
                setTimeout(function(){ location.reload(); }, 2000);
            }
        })
        .fail(function(){
            detenerBusqueda();
            msg('error', 'Error de conexión');
            setTimeout(function(){ location.reload(); }, 2000);
        });
    });

    // Aceptar Sala (Moneda Normal)
    $(document).on('click', '.btn-aceptar', function(){
        var sala = $(this).data('sala');
        if (!confirm('¿Aceptar la sala #' + sala + '?')) return;

        var $btn = $(this);
        $btn.prop('disabled', true).text('Uniendo...');

        $.post(URL_AJAX, { accion: 'aceptar_sala', sala: sala })
        .done(function(r){
            if (r.ok) {
                msg('success', '¡Partida iniciada! Yendo al tablero...');
                setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + sala; }, 1000);
            } else {
                msg('error', r.error || 'Error desconocido');
                $btn.prop('disabled', false).text('Aceptar');
            }
        })
        .fail(function(){
            msg('error', 'Error de conexión');
            $btn.prop('disabled', false).text('Aceptar');
        });
    });

    // Aceptar Sala (Deuterio - Pide Planeta)
    var salaDeuterioPendiente = null;
    $(document).on('click', '.btn-aceptar-deut', function(){
        salaDeuterioPendiente = $(this).data('sala');
        $('#cueva_modal_planeta').css('display', 'flex');
    });

    $('#cueva_modal_cancelar').on('click', function(){
        salaDeuterioPendiente = null;
        $('#cueva_modal_planeta').hide();
    });

    $('#cueva_modal_confirmar').on('click', function(){
        var planeta = $('#cueva_modal_select_planeta').val();
        if (!salaDeuterioPendiente || !planeta) return;

        var sala = salaDeuterioPendiente;
        var $btn = $(this);
        $btn.prop('disabled', true).text('Uniendo...');

        $.post(URL_AJAX, { accion: 'aceptar_sala', sala: sala, planeta: planeta })
        .done(function(r){
            if (r.ok) {
                msg('success', '¡Partida iniciada!');
                setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + sala; }, 1000);
            } else {
                msg('error', r.error || 'Error desconocido');
                $btn.prop('disabled', false).text('Confirmar');
            }
        })
        .fail(function(){
            msg('error', 'Error de conexión');
            $btn.prop('disabled', false).text('Confirmar');
        });
    });

    // Cancelar Sala (en la lista de partidas)
    $(document).on('click', '.btn-cancelar', function(){
        var sala = $(this).data('sala');
        if (!confirm('¿Cancelar la sala #' + sala + '? Se te devolverá la apuesta.')) return;

        var $btn = $(this);
        $btn.prop('disabled', true).text('Cancelando...');

        $.post(URL_AJAX, { accion: 'cancelar_sala', sala: sala })
        .done(function(r){
            if (r.ok) {
                msg('success', 'Sala cancelada. Apuesta devuelta.');
                setTimeout(function(){ location.reload(); }, 1200);
            } else {
                msg('error', r.error || 'Error desconocido');
                $btn.prop('disabled', false).text('Cancelar');
            }
        })
        .fail(function(){
            msg('error', 'Error de conexión');
            $btn.prop('disabled', false).text('Cancelar');
        });
    });
})();
{/literal}
</script>

{/block}