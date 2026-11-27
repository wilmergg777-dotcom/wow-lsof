{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/cueva_lobby.tpl === *}
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

{include file="overall_header.tpl"}

<style>
{literal}
.cueva-wrap { max-width: 1100px; margin: 20px auto; padding: 20px; }
.cueva-titulo { font-size: 24px; margin-bottom: 10px; color: #f0c060; text-shadow: 0 0 4px #000; }
.cueva-panel { background: rgba(20,20,30,0.85); border: 1px solid #4a4a5a; border-radius: 8px; padding: 16px; margin-bottom: 18px; }
.cueva-panel h3 { margin-top: 0; color: #f0c060; font-size: 16px; border-bottom: 1px solid #4a4a5a; padding-bottom: 6px; }
.cueva-saldo { font-size: 14px; padding: 8px 12px; background: #222a36; border-left: 3px solid #f0c060; margin-bottom: 12px; border-radius: 4px; }
.cueva-saldo b { color: #ffd76e; }
.cueva-form-row { margin-bottom: 10px; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.cueva-form-row label { min-width: 130px; font-weight: bold; }
.cueva-input, .cueva-select { padding: 6px 10px; background: #1a1f2a; color: #e0e0e0; border: 1px solid #4a4a5a; border-radius: 4px; font-size: 14px; }
.cueva-input:focus, .cueva-select:focus { outline: none; border-color: #f0c060; }
.cueva-btn { padding: 8px 18px; background: #3a5a8a; color: #fff; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 14px; }
.cueva-btn:hover { background: #4a6a9a; }
.cueva-btn:disabled { background: #444; cursor: not-allowed; opacity: 0.6; }
.cueva-btn-verde { background: #2d7a3e; }
.cueva-btn-verde:hover { background: #3d8a4e; }
.cueva-btn-rojo { background: #8a3a3a; }
.cueva-btn-rojo:hover { background: #9a4a4a; }
.cueva-btn-dorado { background: #8a6a1a; }
.cueva-btn-dorado:hover { background: #9a7a2a; }
.cueva-tabla { width: 100%; border-collapse: collapse; margin-top: 8px; }
.cueva-tabla th, .cueva-tabla td { padding: 8px 10px; text-align: left; border-bottom: 1px solid #333; font-size: 13px; }
.cueva-tabla th { background: #1a1f2a; color: #f0c060; font-weight: bold; }
.cueva-tabla tr:hover { background: rgba(240,192,96,0.05); }
.cueva-badge { display: inline-block; padding: 2px 8px; border-radius: 3px; font-size: 11px; font-weight: bold; }
.cueva-badge-ntx  { background: #2a4a8a; color: #a0c8ff; }
.cueva-badge-untx { background: #8a6a1a; color: #ffd76e; }
.cueva-badge-deut { background: #2d5a3e; color: #a0f0c0; }
.cueva-badge-dust { background: #5a2a6a; color: #e0a0ff; }
.cueva-badge-incompat { background: #444; color: #999; }
.cueva-alerta { padding: 10px 14px; border-radius: 4px; margin: 10px 0; }
.cueva-alerta-info    { background: #1a2a3a; border-left: 3px solid #4a8aff; }
.cueva-alerta-ok      { background: #1a3a1a; border-left: 3px solid #4aff6a; }
.cueva-alerta-error   { background: #3a1a1a; border-left: 3px solid #ff4a4a; }
.cueva-costo { font-size: 12px; color: #999; }
.cueva-costo b { color: #ffd76e; }
#cueva-msg { display: none; }
{/literal}
</style>

<div class="cueva-wrap">

  <div class="cueva-titulo">🏴‍☠️ La Cueva Pirata — Hundir la Flota</div>

  <!-- Saldo -->
  <div class="cueva-saldo">
    💲 Tu saldo: <b>{$saldo_riel|number_format:0:',':'.'} {$moneda_riel}</b>
    &nbsp;|&nbsp;
    🟣 Materia oscura: <b>{$saldo_darkmatter|number_format:0:',':'.'}</b>
    {if $factor_riel == 2}
      &nbsp;|&nbsp; <span style="color:#ffd76e;">Modo internacional (apuesta x2)</span>
    {/if}
  </div>

  <!-- Panel de mensajes dinámicos -->
  <div id="cueva-msg" class="cueva-alerta"></div>

  <!-- ============================================================
       CREAR MESA
       ============================================================ -->
  <div class="cueva-panel">
    <h3>⚓ Crear mesa</h3>

    <div class="cueva-form-row">
      <label>Tipo de apuesta:</label>
      <select id="cueva-tipo" class="cueva-select">
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

    <div class="cueva-form-row" id="cueva-row-planeta" style="display:none;">
      <label>Planeta (deuterio):</label>
      <select id="cueva-planeta" class="cueva-select">
        {foreach from=$planetas item=p}
          <option value="{$p.id}">
            {$p.name} — {$p.deuterium|number_format:0:',':'.'} deuterio
          </option>
        {/foreach}
      </select>
    </div>

    <div class="cueva-form-row">
      <label>Apuesta base:</label>
      <input type="number" id="cueva-apuesta" class="cueva-input" min="1" value="100" style="width:140px;">
      <span id="cueva-unidad">{$moneda_riel}</span>
      <span class="cueva-costo" id="cueva-costo"></span>
    </div>

    <div class="cueva-form-row">
      <button id="cueva-btn-crear" class="cueva-btn cueva-btn-verde">🎯 Crear mesa</button>
      <button id="cueva-btn-buscar" class="cueva-btn cueva-btn-dorado">⚡ Buscar partida rápida</button>
    </div>
  </div>

  <!-- ============================================================
       MIS PARTIDAS ACTIVAS
       ============================================================ -->
  {if $mis_partidas|@count > 0}
  <div class="cueva-panel">
    <h3>🚢 Mis partidas activas</h3>
    <table class="cueva-tabla">
      <tr>
        <th>Sala</th>
        <th>Rival</th>
        <th>Moneda</th>
        <th>Pozo</th>
        <th>Estado</th>
        <th>Acción</th>
      </tr>
      {foreach from=$mis_partidas item=pa}
        <tr>
          <td>#{$pa.sala_id}</td>
          <td>{if $pa.rival}{$pa.rival}{else}<i>Esperando rival...</i>{/if}</td>
          <td><span class="cueva-badge cueva-badge-{$pa.tipo_apuesta|lower}">{$pa.moneda_label}</span></td>
          <td>{$pa.pozo|number_format:0:',':'.'}</td>
          <td>
            {if $pa.fase == 'colocacion'}
              Colocando flota
            {elseif $pa.fase == 'disparos'}
              {if $pa.mi_turno}
                <span style="color:#4aff6a;">¡Tu turno!</span>
              {else}
                Turno del rival
              {/if}
            {/if}
          </td>
          <td>
            {if $pa.fase == 'colocacion' || $pa.mi_turno}
              <a href="game.php?page=cuevaPartida&sala={$pa.sala_id}" class="cueva-btn cueva-btn-verde" style="text-decoration:none;padding:5px 12px;font-size:12px;">
                Entrar
              </a>
            {else}
              <a href="game.php?page=cuevaPartida&sala={$pa.sala_id}" class="cueva-btn" style="text-decoration:none;padding:5px 12px;font-size:12px;">
                Ver tablero
              </a>
            {/if}
            {if $pa.fase == 'colocacion' && $pa.es_creador}
              <button class="cueva-btn cueva-btn-rojo btn-cancelar" data-sala="{$pa.sala_id}" style="padding:5px 12px;font-size:12px;">
                Cancelar
              </button>
            {/if}
          </td>
        </tr>
      {/foreach}
    </table>
  </div>
  {/if}

  <!-- ============================================================
       SALAS ABIERTAS
       ============================================================ -->
  <div class="cueva-panel">
    <h3>🌊 Salas abiertas</h3>

    {if $salas|@count == 0}
      <p style="color:#999;padding:10px;">No hay salas abiertas. ¡Creá una!</p>
    {else}
      <table class="cueva-tabla">
        <tr>
          <th>Creador</th>
          <th>Moneda</th>
          <th>Apuesta</th>
          <th>Pozo</th>
          <th>Creada</th>
          <th>Acción</th>
        </tr>
        {foreach from=$salas item=s}
          <tr>
            <td>{$s.creador}</td>
            <td><span class="cueva-badge cueva-badge-{$s.tipo_apuesta|lower}">{$s.moneda_label}</span></td>
            <td>{$s.apuesta_base|number_format:0:',':'.'}</td>
            <td>{$s.pozo|number_format:0:',':'.'}</td>
            <td>{$s.fecha_creacion}</td>
            <td>
              {if $s.compatible}
                {if $s.tipo_apuesta == 'DEUT'}
                  <button class="cueva-btn cueva-btn-verde btn-aceptar-deut" data-sala="{$s.id}" style="padding:5px 12px;font-size:12px;">
                    Aceptar (elegir planeta)
                  </button>
                {else}
                  <button class="cueva-btn cueva-btn-verde btn-aceptar" data-sala="{$s.id}" style="padding:5px 12px;font-size:12px;">
                    Aceptar
                  </button>
                {/if}
              {else}
                <span class="cueva-badge cueva-badge-incompat">Otra moneda</span>
              {/if}
            </td>
          </tr>
        {/foreach}
      </table>
    {/if}
  </div>

</div>

<!-- Selector de planeta oculto, reutilizable al aceptar sala de deuterio -->
<div id="cueva-modal-planeta" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.7);z-index:9999;">
  <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);background:#1a1f2a;padding:24px;border-radius:8px;border:1px solid #f0c060;min-width:340px;">
    <h3 style="margin-top:0;color:#f0c060;">Elegí un planeta para apostar deuterio</h3>
    <select id="cueva-modal-planeta-select" class="cueva-select" style="width:100%;margin-bottom:14px;">
      {foreach from=$planetas item=p}
        <option value="{$p.id}">{$p.name} — {$p.deuterium|number_format:0:',':'.'} deuterio</option>
      {/foreach}
    </select>
    <div style="text-align:right;">
      <button id="cueva-modal-cancelar" class="cueva-btn cueva-btn-rojo" style="margin-right:8px;">Cancelar</button>
      <button id="cueva-modal-confirmar" class="cueva-btn cueva-btn-verde">Confirmar</button>
    </div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
{literal}
(function(){
  var URL_AJAX = 'game.php?page=cuevaAjax';
  var FACTOR   = {/literal}{$factor_riel}{literal};
  var TIPO_RIEL = '{/literal}{$tipo_riel}{literal}';
  var MONEDA_RIEL = '{/literal}{$moneda_riel}{literal}';

  // ---------------------------------------------------------
  // Mostrar/ocultar selector de planeta al elegir DEUT
  // ---------------------------------------------------------
  function actualizarFormulario() {
    var tipo = $('#cueva-tipo').val();
    if (tipo === 'DEUT') {
      $('#cueva-row-planeta').show();
    } else {
      $('#cueva-row-planeta').hide();
    }
    var unidad = tipo === 'DEUT' ? 'Deuterio'
               : tipo === 'DUST' ? 'Materia Oscura'
               : MONEDA_RIEL;
    $('#cueva-unidad').text(unidad);

    // Costo real
    var base = parseInt($('#cueva-apuesta').val() || 0, 10);
    if (tipo === 'UNTX') {
      $('#cueva-costo').html('→ costo real: <b>' + (base*2) + ' UNTX-20</b>');
    } else if (tipo === 'NTX') {
      $('#cueva-costo').html('→ costo real: <b>' + base + ' NTX-20</b>');
    } else {
      $('#cueva-costo').html('');
    }
  }
  $('#cueva-tipo').on('change', actualizarFormulario);
  $('#cueva-apuesta').on('input', actualizarFormulario);
  actualizarFormulario();

  // ---------------------------------------------------------
  // Mostrar mensajes
  // ---------------------------------------------------------
  function msg(tipo, texto) {
    var cls = 'cueva-alerta-' + (tipo === 'error' ? 'error' : tipo === 'ok' ? 'ok' : 'info');
    $('#cueva-msg').attr('class', 'cueva-alerta ' + cls).html(texto).show();
    if (tipo !== 'error') setTimeout(function(){ $('#cueva-msg').fadeOut(); }, 4000);
    $('html, body').animate({ scrollTop: 0 }, 300);
  }

  // ---------------------------------------------------------
  // Crear sala
  // ---------------------------------------------------------
  $('#cueva-btn-crear').on('click', function(){
    var tipo    = $('#cueva-tipo').val();
    var apuesta = parseInt($('#cueva-apuesta').val() || 0, 10);
    var planeta = (tipo === 'DEUT') ? $('#cueva-planeta').val() : null;

    if (apuesta <= 0) { msg('error', 'Apuesta inválida'); return; }
    if (tipo === 'DEUT' && !planeta) { msg('error', 'Elegí un planeta'); return; }

    $(this).prop('disabled', true).text('Creando...');
    $.post(URL_AJAX, { accion: 'crear_sala', tipo: tipo, apuesta: apuesta, planeta: planeta })
      .done(function(r){
        if (r.ok) {
          msg('ok', '¡Sala creada! Esperando rival...');
          setTimeout(function(){ location.reload(); }, 1200);
        } else {
          msg('error', r.error || 'Error desconocido');
        }
      })
      .fail(function(){ msg('error', 'Error de conexión'); })
      .always(function(){ $('#cueva-btn-crear').prop('disabled', false).text('🎯 Crear mesa'); });
  });

  // ---------------------------------------------------------
  // Buscar partida rápida
  // ---------------------------------------------------------
  $('#cueva-btn-buscar').on('click', function(){
    var tipo    = $('#cueva-tipo').val();
    var apuesta = parseInt($('#cueva-apuesta').val() || 0, 10);
    var planeta = (tipo === 'DEUT') ? $('#cueva-planeta').val() : null;

    if (apuesta <= 0) { msg('error', 'Apuesta inválida'); return; }
    if (tipo === 'DEUT' && !planeta) { msg('error', 'Elegí un planeta'); return; }

    $(this).prop('disabled', true).text('Buscando...');
    $.post(URL_AJAX, { accion: 'buscar_rapida', tipo: tipo, apuesta: apuesta, planeta: planeta })
      .done(function(r){
        if (r.ok) {
          if (r.matcheada) {
            msg('ok', '¡Rival encontrado! Iniciando partida...');
            setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + r.sala_id; }, 1500);
          } else {
            msg('info', 'Búsqueda activa. Si en 5 min no aparece rival, se creará tu sala automáticamente.');
          }
        } else {
          msg('error', r.error || 'Error desconocido');
        }
      })
      .fail(function(){ msg('error', 'Error de conexión'); })
      .always(function(){ $('#cueva-btn-buscar').prop('disabled', false).text('⚡ Buscar partida rápida'); });
  });

  // ---------------------------------------------------------
  // Aceptar sala (misma moneda)
  // ---------------------------------------------------------
  $(document).on('click', '.btn-aceptar', function(){
    var sala = $(this).data('sala');
    if (!confirm('¿Aceptar la sala #' + sala + '?')) return;

    $(this).prop('disabled', true).text('Uniendo...');
    $.post(URL_AJAX, { accion: 'aceptar_sala', sala: sala })
      .done(function(r){
        if (r.ok) {
          msg('ok', '¡Partida iniciada! Yendo al tablero...');
          setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + sala; }, 1000);
        } else {
          msg('error', r.error || 'Error desconocido');
          $(this).prop('disabled', false).text('Aceptar');
        }
      })
      .fail(function(){ msg('error', 'Error de conexión'); });
  });

  // ---------------------------------------------------------
  // Aceptar sala de deuterio (requiere elegir planeta)
  // ---------------------------------------------------------
  var salaDeuterioPendiente = null;
  $(document).on('click', '.btn-aceptar-deut', function(){
    salaDeuterioPendiente = $(this).data('sala');
    $('#cueva-modal-planeta').show();
  });
  $('#cueva-modal-cancelar').on('click', function(){
    salaDeuterioPendiente = null;
    $('#cueva-modal-planeta').hide();
  });
  $('#cueva-modal-confirmar').on('click', function(){
    var planeta = $('#cueva-modal-planeta-select').val();
    if (!salaDeuterioPendiente || !planeta) return;

    var sala = salaDeuterioPendiente;
    $(this).prop('disabled', true).text('Uniendo...');
    $.post(URL_AJAX, { accion: 'aceptar_sala', sala: sala, planeta: planeta })
      .done(function(r){
        if (r.ok) {
          msg('ok', '¡Partida iniciada!');
          setTimeout(function(){ location.href = 'game.php?page=cuevaPartida&sala=' + sala; }, 1000);
        } else {
          msg('error', r.error || 'Error desconocido');
          $('#cueva-modal-confirmar').prop('disabled', false).text('Confirmar');
        }
      })
      .fail(function(){ msg('error', 'Error de conexión'); });
  });

  // ---------------------------------------------------------
  // Cancelar sala
  // ---------------------------------------------------------
  $(document).on('click', '.btn-cancelar', function(){
    var sala = $(this).data('sala');
    if (!confirm('¿Cancelar la sala #' + sala + '? Se te devolverá la apuesta.')) return;

    $(this).prop('disabled', true).text('Cancelando...');
    $.post(URL_AJAX, { accion: 'cancelar_sala', sala: sala })
      .done(function(r){
        if (r.ok) {
          msg('ok', 'Sala cancelada. Apuesta devuelta.');
          setTimeout(function(){ location.reload(); }, 1200);
        } else {
          msg('error', r.error || 'Error desconocido');
        }
      })
      .fail(function(){ msg('error', 'Error de conexión'); });
  });

})();
{/literal}
</script>

{include file="overall_footer.tpl"}