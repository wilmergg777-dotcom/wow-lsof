{include file="overall_header.tpl"}

<style>
.astrogames_wrap { max-width: 1100px; margin: 0 auto; text-align: center; }

/* Tabs principales */
.astrogames_tabs {
    display: flex;
    gap: 4px;
    margin-bottom: 14px;
    border-bottom: 2px solid #2a3548;
    text-align: left;
}
.astrogames_tab {
    display: inline-block;
    padding: 8px 18px;
    color: #8899aa;
    text-decoration: none;
    font-size: 11.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 3px solid transparent;
    margin-bottom: -2px;
    transition: all 0.2s ease;
}
.astrogames_tab:hover {
    color: #00ccff;
    text-decoration: none;
    background: rgba(0,204,255,0.05);
}
.astrogames_tab.active {
    color: #fff;
    border-bottom-color: #00ccff;
    background: rgba(0,204,255,0.08);
}

/* Sub tabs */
.astrogames_subtabs {
    display: flex;
    gap: 6px;
    margin-bottom: 12px;
    text-align: left;
    flex-wrap: wrap;
}
.astrogames_subtab {
    display: inline-block;
    padding: 5px 12px;
    color: #00ccff;
    text-decoration: none;
    font-size: 10.5px;
    border: 1px solid #2a3548;
    border-radius: 5px;
    transition: all 0.2s ease;
}
.astrogames_subtab:hover {
    background: rgba(0,204,255,0.08);
    text-decoration: none;
    border-color: #00ccff;
}
.astrogames_subtab.active {
    background: rgba(0,204,255,0.15);
    border-color: #00e0ff;
    color: #00e0ff;
}

/* Paneles */
.astrogames_panel {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #2a3548;
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 14px;
    text-align: left;
    display: inline-block;
    width: 100%;
    box-sizing: border-box;
    box-shadow: 0 4px 14px rgba(0,0,0,0.4);
}
.astrogames_title {
    text-transform: uppercase;
    color: #00ccff;
    font-size: 13px;
    font-weight: bold;
    border-bottom: 1px solid #2a3548;
    padding-bottom: 6px;
    margin-bottom: 10px;
    letter-spacing: 0.5px;
}

/* Stats */
.astrogames_stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
    margin: 10px 0;
}
.astrogames_stat {
    background: #0a1018;
    border: 1px solid #2a3548;
    border-radius: 6px;
    padding: 12px;
    text-align: center;
}
.astrogames_stat_val {
    color: #00ccff;
    font-size: 22px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astrogames_stat_val.gold { color: #ffcc00; }
.astrogames_stat_val.green { color: #66ff99; }
.astrogames_stat_lbl {
    color: #8899aa;
    font-size: 9px;
    text-transform: uppercase;
    margin-top: 4px;
    letter-spacing: 0.5px;
}

/* Botones */
.astrogames_btn {
    display: inline-block;
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    text-decoration: none;
    padding: 8px 16px;
    border-radius: 5px;
    font-size: 11px;
    font-weight: bold;
    margin-right: 8px;
    margin-bottom: 6px;
    transition: all 0.2s ease;
    border: none;
    cursor: pointer;
}
.astrogames_btn:hover {
    box-shadow: 0 0 14px rgba(0,224,255,0.35);
    color: #fff;
    text-decoration: none;
}
.astrogames_btn.gold {
    background: linear-gradient(135deg, #dd8800, #ffcc00);
    color: #000;
}
.astrogames_btn.gold:hover { box-shadow: 0 0 14px rgba(255,204,0,0.5); color: #000; }
.astrogames_btn.green {
    background: linear-gradient(135deg, #00aa44, #66ff99);
    color: #000;
}
.astrogames_btn.green:hover { box-shadow: 0 0 14px rgba(102,255,153,0.5); color: #000; }
.astrogames_btn.red {
    background: linear-gradient(135deg, #aa0022, #ff4488);
    color: #fff;
}
.astrogames_btn.red:hover { box-shadow: 0 0 14px rgba(255,68,136,0.5); color: #fff; }

/* Tablas */
.astrogames_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    background: #0a1018;
    border-radius: 6px;
    overflow: hidden;
}
.astrogames_table th {
    background: linear-gradient(135deg, #004488, #0077cc);
    color: #fff;
    padding: 8px 10px;
    text-align: left;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid #00ccff;
}
.astrogames_table td {
    padding: 8px 10px;
    color: #c8d6e5;
    border-bottom: 1px solid #1a2332;
}
.astrogames_table tr:hover td { background: rgba(0,204,255,0.05); }
.astrogames_table tr:last-child td { border-bottom: none; }

/* Empty */
.astrogames_empty {
    color: #8899aa;
    font-size: 11px;
    text-align: center;
    padding: 24px;
    font-style: italic;
}

/* Mensajes */
.astrogames_msg {
    padding: 10px 14px;
    border-radius: 6px;
    margin-bottom: 12px;
    font-size: 11.5px;
    text-align: left;
}
.astrogames_msg.success { background: rgba(102,255,153,0.1); border-left: 3px solid #66ff99; color: #66ff99; }
.astrogames_msg.error   { background: rgba(255,68,136,0.1); border-left: 3px solid #ff4488; color: #ff4488; }
.astrogames_msg.info    { background: rgba(0,204,255,0.1);  border-left: 3px solid #00ccff; color: #00ccff; }

/* Formularios */
.astrogames_form_group { margin-bottom: 12px; }
.astrogames_form_group label {
    display: block;
    color: #00ccff;
    font-size: 11px;
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrogames_form_group input[type=text],
.astrogames_form_group input[type=number],
.astrogames_form_group textarea,
.astrogames_form_group select {
    width: 100%;
    background: #0a1018;
    border: 1px solid #2a3548;
    color: #fff;
    padding: 8px 10px;
    border-radius: 5px;
    font-size: 11px;
    box-sizing: border-box;
}
.astrogames_form_group input:focus,
.astrogames_form_group textarea:focus,
.astrogames_form_group select:focus {
    outline: none;
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0,224,255,0.3);
}
.astrogames_form_row {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
}
.astrogames_form_row_3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}
.astrogames_radio_group {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}
.astrogames_radio_group label {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #c8d6e5;
    font-size: 11px;
    cursor: pointer;
    padding: 6px 10px;
    border: 1px solid #2a3548;
    border-radius: 5px;
    transition: all 0.2s ease;
    text-transform: none;
    letter-spacing: 0;
}
.astrogames_radio_group label:hover { border-color: #00ccff; }
.astrogames_radio_group input[type=radio] { accent-color: #00ccff; }

/* Checkbox */
.astrogames_checkbox {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    color: #c8d6e5;
    font-size: 11px;
    cursor: pointer;
}
.astrogames_checkbox input { accent-color: #00ccff; }

/* Badge */
.astrogames_badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 9px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrogames_badge.activo     { background: rgba(0,204,255,0.15);   color: #00ccff; }
.astrogames_badge.abierto    { background: rgba(102,255,153,0.15); color: #66ff99; }
.astrogames_badge.finalizado { background: rgba(102,255,153,0.15); color: #66ff99; }
.astrogames_badge.sorteado   { background: rgba(0,204,255,0.15);   color: #00ccff; }
.astrogames_badge.urgent     { background: rgba(255,170,51,0.15);  color: #ffaa33; }
.astrogames_badge.pending    { background: rgba(136,153,170,0.15); color: #8899aa; }
.astrogames_badge.gold       { background: rgba(255,204,0,0.15);   color: #ffcc00; }

/* Premios - Filas dinamicas */
.astrogames_premio_row {
    display: grid;
    grid-template-columns: 80px 1fr 120px 40px;
    gap: 8px;
    align-items: center;
    padding: 8px;
    background: #0a1018;
    border: 1px solid #2a3548;
    border-radius: 5px;
    margin-bottom: 6px;
}
.astrogames_premio_orden {
    color: #00ccff;
    font-weight: bold;
    font-size: 11px;
    text-align: center;
    white-space: nowrap;
}
.astrogames_premio_row select,
.astrogames_premio_row input[type=number] {
    background: #0f1624;
    border: 1px solid #2a3548;
    color: #fff;
    padding: 6px 8px;
    border-radius: 4px;
    font-size: 11px;
    width: 100%;
    box-sizing: border-box;
}
.astrogames_premio_row select:focus,
.astrogames_premio_row input:focus {
    outline: none;
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0,224,255,0.3);
}
.astrogames_premio_del {
    background: linear-gradient(135deg, #aa0022, #ff4488);
    color: #fff;
    border: none;
    padding: 6px 10px;
    border-radius: 4px;
    font-weight: bold;
    cursor: pointer;
    font-size: 11px;
    transition: all 0.2s ease;
}
.astrogames_premio_del:hover {
    box-shadow: 0 0 14px rgba(255,68,136,0.5);
}

/* Tramos - Estilos */
.astrogames_tramo_pct {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-family: 'Courier New', monospace;
    font-weight: bold;
    font-size: 11px;
}
.astrogames_tramo_pct.jp { background: rgba(255,204,0,0.15); color: #ffcc00; }
.astrogames_tramo_pct.a3 { background: rgba(102,255,153,0.15); color: #66ff99; }
.astrogames_tramo_pct.a2 { background: rgba(0,204,255,0.15);   color: #00ccff; }

.astrogames_tramo_info {
    background: rgba(255,204,0,0.08);
    border-left: 3px solid #ffcc00;
    border-radius: 6px;
    padding: 10px 14px;
    margin-bottom: 12px;
    font-size: 11px;
    color: #ffeeaa;
}
.astrogames_tramo_info b { color: #fff; }

/* Formula de suma */
.astrogames_sum_box {
    background: #0a1018;
    border: 1px solid #2a3548;
    border-radius: 6px;
    padding: 10px 14px;
    margin-top: 8px;
    font-family: 'Courier New', monospace;
    font-size: 12px;
    text-align: center;
}
.astrogames_sum_box.ok   { border-color: #66ff99; color: #66ff99; }
.astrogames_sum_box.fail { border-color: #ff4488; color: #ff4488; }
</style>

<div class="astrogames_wrap">

    {* TABS PRINCIPALES *}
    <div class="astrogames_tabs">
        <a href="admin.php?page=gamesadmin" class="astrogames_tab {if $ga_tab_activa == 'dashboard'}active{/if}">Dashboard</a>
        <a href="admin.php?page=gamesadmin&tab=rifas" class="astrogames_tab {if $ga_tab_activa == 'rifas'}active{/if}">Rifas</a>
        <a href="admin.php?page=gamesadmin&tab=loteria" class="astrogames_tab {if $ga_tab_activa == 'loteria'}active{/if}">Loteria</a>
        <a href="admin.php?page=gamesadmin&tab=log" class="astrogames_tab {if $ga_tab_activa == 'log'}active{/if}">Log</a>
    </div>

    {if isset($ga_msg) && $ga_msg}
    <div class="astrogames_msg {$ga_msg_type|default:'info'}">{$ga_msg}</div>
    {/if}

    {* ==================== DASHBOARD ==================== *}
    {if $ga_tab_activa == 'dashboard'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Rifas</div>
        <div class="astrogames_stats">
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_ra_activas|default:0}</div>
                <div class="astrogames_stat_lbl">Activas</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_ra_max_activas|default:5}</div>
                <div class="astrogames_stat_lbl">Maximo</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_ra_finalizadas|default:0}</div>
                <div class="astrogames_stat_lbl">Finalizadas</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_ra_boletos|default:0}</div>
                <div class="astrogames_stat_lbl">Boletos</div>
            </div>
        </div>
    </div>

    <div class="astrogames_panel">
        <div class="astrogames_title">Loteria</div>
        <div class="astrogames_stats">
            <div class="astrogames_stat">
                <div class="astrogames_stat_val {if $ga_lot_activo|default:0}green{/if}">{if $ga_lot_activo|default:0}Activo{else}--{/if}</div>
                <div class="astrogames_stat_lbl">Sorteo Actual</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val gold">{$ga_lot_jackpot|default:0|number_format}</div>
                <div class="astrogames_stat_lbl">Jackpot</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_lot_sorteos_terminados|default:0}</div>
                <div class="astrogames_stat_lbl">Sorteos Finalizados</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_lot_tickets|default:0}</div>
                <div class="astrogames_stat_lbl">Tickets Vendidos</div>
            </div>
        </div>
    </div>

    <div class="astrogames_panel">
        <div class="astrogames_title">Rifas Activas</div>
        {if $ga_hay_activas|default:false}
        <table class="astrogames_table">
            <thead>
                <tr>
                    <th>ID</th><th>Titulo</th><th>Boletos</th><th>Precio</th><th>Termina</th><th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $ga_lista_activas as $r}
                <tr>
                    <td>#{$r.id}</td>
                    <td>{$r.titulo}</td>
                    <td>{$r.boletos_vendidos} / {$r.max_boletos}</td>
                    <td>{$r.precio_boleto} {$r.moneda_nombre}</td>
                    <td>{$r.tiempo_restante}</td>
                    <td><a href="admin.php?page=gamesadmin&tab=rifas&mode=ver&id={$r.id}" class="astrogames_btn">Ver</a></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">No hay rifas activas</div>
        {/if}
    </div>
    {/if}

    {* ==================== RIFAS ==================== *}
    {if $ga_tab_activa == 'rifas'}

    <div class="astrogames_subtabs">
        <a href="admin.php?page=gamesadmin&tab=rifas&mode=activas" class="astrogames_subtab {if $ga_sub_activa == 'activas'}active{/if}">Activas</a>
        <a href="admin.php?page=gamesadmin&tab=rifas&mode=finalizadas" class="astrogames_subtab {if $ga_sub_activa == 'finalizadas'}active{/if}">Finalizadas</a>
        <a href="admin.php?page=gamesadmin&tab=rifas&mode=crear" class="astrogames_subtab {if $ga_sub_activa == 'crear'}active{/if}">+ Crear Rifa</a>
    </div>

    {* Rifas - Activas *}
    {if $ga_sub_activa == 'activas'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Rifas Activas</div>
        {if $ga_hay_activas|default:false}
        <table class="astrogames_table">
            <thead>
                <tr>
                    <th>ID</th><th>Titulo</th><th>Boletos</th><th>Precio</th><th>Termina</th><th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $ga_activas as $r}
                <tr>
                    <td>#{$r.id}</td>
                    <td>{$r.titulo}</td>
                    <td>{$r.boletos_vendidos} / {$r.max_boletos}</td>
                    <td>{$r.precio_boleto} {$r.moneda_nombre}</td>
                    <td>{$r.tiempo_restante}</td>
                    <td>
                        <a href="admin.php?page=gamesadmin&tab=rifas&mode=ver&id={$r.id}" class="astrogames_btn">Ver</a>
                        <a href="admin.php?page=gamesadmin&tab=rifas&mode=forzar&id={$r.id}" class="astrogames_btn gold" onclick="return confirm('Forzar sorteo ahora?');">Sortear</a>
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">No hay rifas activas</div>
        {/if}
    </div>
    {/if}

    {* Rifas - Finalizadas *}
    {if $ga_sub_activa == 'finalizadas'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Rifas Finalizadas</div>
        {if $ga_hay_finalizadas|default:false}
        <table class="astrogames_table">
            <thead>
                <tr>
                    <th>ID</th><th>Titulo</th><th>Boletos</th><th>Ganador</th><th>Fecha</th><th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $ga_finalizadas as $r}
                <tr>
                    <td>#{$r.id}</td>
                    <td>{$r.titulo}</td>
                    <td>{$r.boletos_vendidos}</td>
                    <td>{if $r.ganador_id}User #{$r.ganador_id}{else}-{/if}</td>
                    <td>{$r.fecha_sorteo|date_format:"%d/%m/%Y"}</td>
                    <td><a href="admin.php?page=gamesadmin&tab=rifas&mode=ver&id={$r.id}" class="astrogames_btn">Ver</a></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">No hay rifas finalizadas</div>
        {/if}
    </div>
    {/if}

    {* Rifas - Crear *}
    {if $ga_sub_activa == 'crear'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Crear Nueva Rifa</div>

        <form method="POST" action="admin.php?page=gamesadmin&tab=rifas&mode=doCrear" id="astrogames_form_crear">

            <div class="astrogames_form_group">
                <label>Titulo</label>
                <input type="text" name="titulo" maxlength="200" required>
            </div>

            <div class="astrogames_form_group">
                <label>Descripcion</label>
                <textarea name="descripcion" rows="3"></textarea>
            </div>

            <div class="astrogames_form_group">
                <label>Moneda de pago</label>
                <div class="astrogames_radio_group">
                    {foreach $ga_monedas as $m}
                    <label>
                        <input type="radio" name="moneda" value="{$m.id}" {if $m.id == 'ntx20'}checked{/if}>
                        {$m.nombre}
                    </label>
                    {/foreach}
                </div>
            </div>

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Precio por boleto</label>
                    <input type="number" name="precio_boleto" min="1" value="5" required>
                </div>
                <div class="astrogames_form_group">
                    <label>Maximo de boletos</label>
                    <input type="number" name="max_boletos" min="1" value="100" required>
                </div>
            </div>

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Cantidad de lugares</label>
                    <input type="number" name="cantidad_lugares" min="1" max="20" value="1" id="astrogames_lugares" required>
                </div>
                <div class="astrogames_form_group">
                    <label>Duracion</label>
                    <div class="astrogames_radio_group">
                        {foreach $ga_duraciones as $d}
                        <label>
                            <input type="radio" name="duracion" value="{$d.id}" {if $d.id == '7d'}checked{/if}>
                            {$d.nombre}
                        </label>
                        {/foreach}
                    </div>
                </div>
            </div>

            <div class="astrogames_form_group">
                <label>Premios (con su lugar)</label>
                <div id="astrogames_premios_wrap">
                    <div class="astrogames_premio_row">
                        <span class="astrogames_premio_orden">PREMIO 1</span>
                        <select name="premio_tipo[]">
                            {foreach $ga_tipos_premio as $tp}
                            <option value="{$tp.id}">{$tp.nombre}</option>
                            {/foreach}
                        </select>
                        <input type="number" name="premio_cantidad[]" min="1" value="100" placeholder="Cantidad">
                        <input type="number" name="premio_lugar[]" min="1" max="20" value="1" placeholder="Lugar" title="Lugar del premio: varios premios con el mismo lugar se los lleva el mismo ganador">
                        <button type="button" class="astrogames_premio_del" title="Eliminar">X</button>
                    </div>
                </div>
                <div style="text-align:center;margin-top:10px;">
                    <button type="button" class="astrogames_btn green" id="astrogames_add_premio">+ Agregar Premio</button>
                </div>
                <small style="color:#8899aa;font-size:10px;display:block;margin-top:8px;">
                    ✅ v4.0 — Cada premio lleva su número de LUGAR. Puedes poner VARIOS premios con el MISMO lugar:
                    todos se los lleva el mismo ganador de ese lugar. Se sortea un boleto ganador por lugar.
                </small>
            </div>

            <div style="text-align:center; margin-top:14px;">
                <button type="submit" class="astrogames_btn gold">CREAR RIFA</button>
            </div>

        </form>
    </div>

    <script>
    /* ============================================================
     * ASTROIO - Agregar/Eliminar premios dinamicamente
     * ============================================================ */
    (function() {
        var wrap = document.getElementById('astrogames_premios_wrap');
        var btnAdd = document.getElementById('astrogames_add_premio');
        if (!wrap || !btnAdd) return;

        var tiposOptions = '';
        {foreach $ga_tipos_premio as $tp}
        tiposOptions += '<option value="{$tp.id}">{$tp.nombre}</option>';
        {/foreach}

        function actualizarOrdenes() {
            var rows = wrap.querySelectorAll('.astrogames_premio_row');
            for (var i = 0; i < rows.length; i++) {
                var span = rows[i].querySelector('.astrogames_premio_orden');
                if (span) span.textContent = 'PREMIO ' + (i + 1);
                var lug = rows[i].querySelector('input[name="premio_lugar[]"]');
                if (lug && (parseInt(lug.value, 10) < 1 || isNaN(parseInt(lug.value, 10)))) lug.value = 1;
            }
            // ✅ v4.0 — Cantidad de lugares = cantidad de lugares DISTINTOS
            // (varios premios pueden compartir el mismo lugar)
            var lugaresSet = {};
            var allLug = wrap.querySelectorAll('input[name="premio_lugar[]"]');
            for (var j = 0; j < allLug.length; j++) {
                var v = parseInt(allLug[j].value, 10);
                if (v >= 1) lugaresSet[v] = true;
            }
            var inputLugares = document.getElementById('astrogames_lugares');
            if (inputLugares) inputLugares.value = Object.keys(lugaresSet).length || rows.length;
        }

        function bindDelete(btn) {
            btn.addEventListener('click', function() {
                var rows = wrap.querySelectorAll('.astrogames_premio_row');
                if (rows.length <= 1) {
                    alert('Debe haber al menos 1 premio');
                    return;
                }
                btn.parentNode.parentNode.removeChild(btn.parentNode);
                actualizarOrdenes();
            });
        }

        var botonesDel = wrap.querySelectorAll('.astrogames_premio_del');
        for (var i = 0; i < botonesDel.length; i++) {
            bindDelete(botonesDel[i]);
        }

        btnAdd.addEventListener('click', function() {
            var rows = wrap.querySelectorAll('.astrogames_premio_row');
            if (rows.length >= 20) {
                alert('Maximo 20 premios');
                return;
            }

            var html = '<div class="astrogames_premio_row">';
            html += '<span class="astrogames_premio_orden">PREMIO ' + (rows.length + 1) + '</span>';
            html += '<select name="premio_tipo[]">' + tiposOptions + '</select>';
            html += '<input type="number" name="premio_cantidad[]" min="1" value="100" placeholder="Cantidad">';
            html += '<input type="number" name="premio_lugar[]" min="1" max="20" value="' + (rows.length + 1) + '" placeholder="Lugar">';
            html += '<button type="button" class="astrogames_premio_del" title="Eliminar">X</button>';
            html += '</div>';

            var temp = document.createElement('div');
            temp.innerHTML = html;
            var newRow = temp.firstChild;
            wrap.appendChild(newRow);

            bindDelete(newRow.querySelector('.astrogames_premio_del'));
            actualizarOrdenes();
        });

        actualizarOrdenes();
    })();
    </script>
    {/if}

    {* Rifas - Ver *}
    {if $ga_sub_activa == 'ver' && isset($ga_raffle)}
    <div class="astrogames_panel">
        <div class="astrogames_title">Rifa #{$ga_raffle.id}</div>
        <table class="astrogames_table">
            <tr><th style="width:200px;">Titulo</th><td>{$ga_raffle.titulo}</td></tr>
            <tr><th>Descripcion</th><td>{$ga_raffle.descripcion}</td></tr>
            <tr><th>Moneda</th><td>{$ga_raffle.moneda_nombre}</td></tr>
            <tr><th>Precio boleto</th><td>{$ga_raffle.precio_boleto}</td></tr>
            <tr><th>Boletos</th><td>{$ga_raffle.boletos_vendidos} / {$ga_raffle.max_boletos}</td></tr>
            <tr><th>Lugares</th><td>{$ga_raffle.cantidad_lugares}</td></tr>
            <tr><th>Duracion</th><td>{$ga_raffle.duracion}</td></tr>
            <tr><th>Estado</th><td><span class="astrogames_badge {$ga_raffle.estado}">{$ga_raffle.estado}</span></td></tr>
            <tr><th>Termina</th><td>{$ga_raffle.tiempo_restante}</td></tr>
        </table>
    </div>

    <div class="astrogames_panel">
        <div class="astrogames_title">Premios</div>
        <table class="astrogames_table">
            <thead><tr><th>Lugar</th><th>Premio</th><th>Ganador</th><th>Boleto</th></tr></thead>
            <tbody>
                {foreach $ga_premios as $p}
                <tr>
                    <td>#{$p.orden}</td>
                    <td>{$p.texto}</td>
                    <td>{if $p.ganador_username}<b style="color:#66ff99;">{$p.ganador_username}</b>{elseif $p.ganador_id}User #{$p.ganador_id}{else}-{/if}</td>
                    <td>{if $p.boleto_ganador}#{$p.boleto_ganador}{else}-{/if}</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>

    <div class="astrogames_panel">
        <div class="astrogames_title">Boletos Vendidos ({$ga_raffle.boletos_vendidos})</div>
        {if $ga_hay_tickets|default:false}
        <table class="astrogames_table">
            <thead><tr><th>#</th><th>Jugador</th><th>Pagado</th><th>Fecha</th></tr></thead>
            <tbody>
                {foreach $ga_tickets as $t}
                <tr>
                    <td>#{$t.boleto_numero}</td>
                    <td>{$t.username|default:'Anonimo'}</td>
                    <td>{$t.precio_pagado} {$t.moneda_pagada}</td>
                    <td>{$t.fecha_compra|date_format:"%d/%m/%Y %H:%M"}</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">Sin boletos vendidos</div>
        {/if}
    </div>

    <div style="text-align:center;">
        <a href="admin.php?page=gamesadmin&tab=rifas&mode=activas" class="astrogames_btn">Volver</a>
        {if $ga_raffle.estado == 'activo'}
        <a href="admin.php?page=gamesadmin&tab=rifas&mode=forzar&id={$ga_raffle.id}" class="astrogames_btn gold" onclick="return confirm('Forzar sorteo ahora?');">Forzar Sorteo</a>
        {/if}
    </div>
    {/if}

    {/if}

    {* ==================== LOTERIA ==================== *}
    {if $ga_tab_activa == 'loteria'}

    <div class="astrogames_subtabs">
        <a href="admin.php?page=gamesadmin&tab=loteria&mode=sorteos" class="astrogames_subtab {if $ga_sub_activa == 'sorteos'}active{/if}">Sorteos</a>
        <a href="admin.php?page=gamesadmin&tab=loteria&mode=crear" class="astrogames_subtab {if $ga_sub_activa == 'crear'}active{/if}">+ Crear Sorteo</a>
        <a href="admin.php?page=gamesadmin&tab=loteria&mode=config" class="astrogames_subtab {if $ga_sub_activa == 'config'}active{/if}">Configuracion</a>
        <a href="admin.php?page=gamesadmin&tab=loteria&mode=tramos" class="astrogames_subtab {if $ga_sub_activa == 'tramos'}active{/if}">Porcentajes</a>
    </div>

    {* -------- LOTERIA - LISTA DE SORTEOS -------- *}
    {if $ga_sub_activa == 'sorteos'}

    {if $ga_lot_hay_draw|default:false}
    <div class="astrogames_panel">
        <div class="astrogames_title">Sorteo Actual</div>
        <div class="astrogames_stats">
            <div class="astrogames_stat">
                <div class="astrogames_stat_val green">#{$ga_lot_draw.numero_sorteo}</div>
                <div class="astrogames_stat_lbl">Numero</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val gold">{$ga_lot_draw.jackpot_total|number_format}</div>
                <div class="astrogames_stat_lbl">Jackpot</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_lot_draw.tickets_vendidos}</div>
                <div class="astrogames_stat_lbl">Tickets</div>
            </div>
            <div class="astrogames_stat">
                <div class="astrogames_stat_val">{$ga_lot_draw.tiempo_restante}</div>
                <div class="astrogames_stat_lbl">Termina en</div>
            </div>
        </div>
        <div style="text-align:center; margin-top:10px;">
            <a href="admin.php?page=gamesadmin&tab=loteria&mode=ver&id={$ga_lot_draw.id}" class="astrogames_btn">Ver Detalles</a>
            <a href="admin.php?page=gamesadmin&tab=loteria&mode=forzar&id={$ga_lot_draw.id}" class="astrogames_btn gold" onclick="return confirm('Forzar sorteo ahora?');">Forzar Sorteo</a>
        </div>
    </div>
    {else}
    <div class="astrogames_panel">
        <div class="astrogames_empty">No hay sorteo activo. Crea uno en "+ Crear Sorteo"</div>
    </div>
    {/if}

    <div class="astrogames_panel">
        <div class="astrogames_title">Sorteos Anteriores</div>
        {if $ga_lot_hay_sorteos|default:false}
        <table class="astrogames_table">
            <thead>
                <tr>
                    <th>#</th><th>Jackpot</th><th>Tickets</th><th>Numeros</th><th>Estado</th><th>Ganador</th><th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $ga_lot_sorteos as $s}
                <tr>
                    <td>#{$s.numero_sorteo}</td>
                    <td>{$s.jackpot_total|number_format}</td>
                    <td>{$s.tickets_vendidos}</td>
                    <td>{$s.numeros_sorteados|default:'-'}</td>
                    <td><span class="astrogames_badge {$s.estado}">{$s.estado}</span></td>
                    <td>{if $s.ganador_jackpot_id}User #{$s.ganador_jackpot_id}{elseif $s.estado == 'sorteado'}Nadie{else}-{/if}</td>
                    <td><a href="admin.php?page=gamesadmin&tab=loteria&mode=ver&id={$s.id}" class="astrogames_btn">Ver</a></td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">No hay sorteos registrados</div>
        {/if}
    </div>
    {/if}

    {* -------- LOTERIA - CREAR SORTEO -------- *}
    {if $ga_sub_activa == 'crear'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Crear Nuevo Sorteo</div>

        {if $ga_lot_hay_rollover|default:false}
        <div class="astrogames_msg info">
            <b>Rollover disponible:</b> {$ga_lot_rollover|number_format} NTX-20 del sorteo anterior.
            Podes NO poner fondo o agregar extra.
        </div>
        {else}
        <div class="astrogames_msg info">
            <b>Sin rollover:</b> Es el primer sorteo o alguien gano el anterior.
            Debes poner un fondo inicial.
        </div>
        {/if}

        <form method="POST" action="admin.php?page=gamesadmin&tab=loteria&mode=doCrear">

            <div class="astrogames_form_group">
                <label>Fondo del admin {if $ga_lot_hay_rollover|default:false}(opcional){else}(obligatorio){/if}</label>
                <input type="number" name="fondo_admin" min="{if $ga_lot_hay_rollover|default:false}0{else}1{/if}" value="{if $ga_lot_hay_rollover|default:false}0{else}{$ga_lot_config.fondo_admin|default:1000}{/if}" required>
                <small style="color:#8899aa;font-size:10px;">NTX-20 que agrega el admin al jackpot</small>
            </div>

            <div style="text-align:center; margin-top:14px;">
                <button type="submit" class="astrogames_btn gold">CREAR SORTEO</button>
            </div>

        </form>
    </div>
    {/if}

    {* -------- LOTERIA - CONFIGURACION -------- *}
    {if $ga_sub_activa == 'config'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Configuracion de Loteria</div>

        <form method="POST" action="admin.php?page=gamesadmin&tab=loteria&mode=doConfig">

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Precio del ticket (NTX-20)</label>
                    <input type="number" name="precio_ticket" min="1" value="{$ga_lot_config.precio_ticket|default:57}" required>
                </div>
                <div class="astrogames_form_group">
                    <label>Descuento VIP (%)</label>
                    <input type="number" name="descuento_vip" min="0" max="100" value="{$ga_lot_config.descuento_vip|default:50}">
                </div>
            </div>

            <div class="astrogames_form_group">
                <label>Duracion del sorteo</label>
                <div class="astrogames_radio_group">
                    {foreach $ga_lot_duraciones as $d}
                    <label>
                        <input type="radio" name="duracion_sorteo" value="{$d.id}" {if $d.id == $ga_lot_config.duracion_sorteo|default:'7d'}checked{/if}>
                        {$d.nombre}
                    </label>
                    {/foreach}
                </div>
            </div>

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Rango maximo (1 a N)</label>
                    <input type="number" name="rango_max" min="10" max="100" value="{$ga_lot_config.rango_max|default:30}" required>
                </div>
                <div class="astrogames_form_group">
                    <label>Numeros a elegir</label>
                    <input type="number" name="numeros_a_elegir" min="2" max="10" value="{$ga_lot_config.numeros_a_elegir|default:4}" required>
                </div>
            </div>

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Fondo del admin por defecto</label>
                    <input type="number" name="fondo_admin" min="0" value="{$ga_lot_config.fondo_admin|default:1000}">
                </div>
                <div class="astrogames_form_group">
                    <label>Jackpot minimo</label>
                    <input type="number" name="jackpot_minimo" min="0" value="{$ga_lot_config.jackpot_minimo|default:1000}">
                </div>
            </div>

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Premio 3 aciertos (NTX-20)</label>
                    <input type="number" name="premio_3_aciertos" min="1" value="{$ga_lot_config.premio_3_aciertos|default:169}">
                </div>
                <div class="astrogames_form_group">
                    <label>Premio 2 aciertos (NTX-20)</label>
                    <input type="number" name="premio_2_aciertos" min="1" value="{$ga_lot_config.premio_2_aciertos|default:114}">
                </div>
            </div>

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Max tickets por jugador</label>
                    <input type="number" name="max_tickets_por_jugador" min="1" value="{$ga_lot_config.max_tickets_por_jugador|default:4}">
                </div>
                <div class="astrogames_form_group">
                    <label>Max tickets totales</label>
                    <input type="number" name="max_tickets_totales" min="1" value="{$ga_lot_config.max_tickets_totales|default:1000}">
                </div>
            </div>

            <div class="astrogames_form_group">
                <label class="astrogames_checkbox">
                    <input type="checkbox" name="jackpot_acumula" value="1" {if $ga_lot_config.jackpot_acumula|default:1}checked{/if}>
                    Acumular jackpot si nadie gana (rollover)
                </label>
            </div>

            <div class="astrogames_form_group">
                <label class="astrogames_checkbox">
                    <input type="checkbox" name="activo" value="1" {if $ga_lot_config.activo|default:1}checked{/if}>
                    Loteria activa
                </label>
            </div>

            <div style="text-align:center; margin-top:14px;">
                <button type="submit" class="astrogames_btn gold">GUARDAR CONFIGURACION</button>
            </div>

        </form>
    </div>
    {/if}

    {* -------- LOTERIA - PORCENTAJES (TRAMOS) -------- *}
    {if $ga_sub_activa == 'tramos'}

    {* Vista de listado general *}
    {if !isset($ga_tramo_edit) || $ga_tramo_edit === false}

    <div class="astrogames_panel">
        <div class="astrogames_title">Escalado de Porcentajes por Jackpot</div>

        <div class="astrogames_tramo_info">
            <b>Como funciona:</b><br>
            Cada ticket se divide en 3 pozos segun el <b>jackpot acumulado actual</b> del sorteo.<br>
            Los tramos se aplican de <b>menor a mayor</b> jackpot. El primer tramo cuya condicion se cumple se aplica.<br>
            <b>La suma de los 3 porcentajes debe dar 100%.</b>
        </div>

        {if $ga_lot_hay_tramos|default:false}
        <table class="astrogames_table">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Jackpot Desde</th>
                    <th>Jackpot Hasta</th>
                    <th>Jackpot</th>
                    <th>3 Aciertos</th>
                    <th>2 Aciertos</th>
                    <th>Suma</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $ga_lot_tramos as $t}
                <tr>
                    <td>{$t.orden|default:'-'}</td>
                    <td>{$t.jackpot_desde|number_format}</td>
                    <td>{if $t.jackpot_hasta == 0}Sin limite{else}{$t.jackpot_hasta|number_format}{/if}</td>
                    <td><span class="astrogames_tramo_pct jp">{$t.pct_jackpot}%</span></td>
                    <td><span class="astrogames_tramo_pct a3">{$t.pct_3_aciertos}%</span></td>
                    <td><span class="astrogames_tramo_pct a2">{$t.pct_2_aciertos}%</span></td>
                    <td>
                        {if ($t.pct_jackpot + $t.pct_3_aciertos + $t.pct_2_aciertos) == 100}
                            <span style="color:#66ff99;font-weight:bold;">100%</span>
                        {else}
                            <span style="color:#ff4488;font-weight:bold;">{$t.pct_jackpot + $t.pct_3_aciertos + $t.pct_2_aciertos}%</span>
                        {/if}
                    </td>
                    <td>
                        <a href="admin.php?page=gamesadmin&tab=loteria&mode=tramoEditar&id={$t.id}" class="astrogames_btn">Editar</a>
                        <a href="admin.php?page=gamesadmin&tab=loteria&mode=tramoDelete&id={$t.id}" class="astrogames_btn red" onclick="return confirm('Eliminar este tramo?');">Eliminar</a>
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">No hay tramos configurados</div>
        {/if}

        <div style="text-align:center; margin-top:14px;">
            <a href="admin.php?page=gamesadmin&tab=loteria&mode=tramoNew" class="astrogames_btn green">+ Agregar Tramo</a>
        </div>
    </div>

    {/if}

    {* Vista de edicion *}
    {if isset($ga_tramo_edit) && $ga_tramo_edit === true && isset($ga_tramo)}
    <div class="astrogames_panel">
        <div class="astrogames_title">Editar Tramo #{$ga_tramo.id}</div>

        <form method="POST" action="admin.php?page=gamesadmin&tab=loteria&mode=tramoDoEdit">
            <input type="hidden" name="id" value="{$ga_tramo.id}">

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Jackpot Desde (inclusive)</label>
                    <input type="number" name="jackpot_desde" min="0" value="{$ga_tramo.jackpot_desde}" required>
                </div>
                <div class="astrogames_form_group">
                    <label>Jackpot Hasta (0 = sin limite)</label>
                    <input type="number" name="jackpot_hasta" min="0" value="{$ga_tramo.jackpot_hasta}">
                </div>
            </div>

            <div class="astrogames_form_row_3">
                <div class="astrogames_form_group">
                    <label>% Jackpot</label>
                    <input type="number" name="pct_jackpot" min="0" max="100" value="{$ga_tramo.pct_jackpot}" required>
                </div>
                <div class="astrogames_form_group">
                    <label>% 3 Aciertos</label>
                    <input type="number" name="pct_3_aciertos" min="0" max="100" value="{$ga_tramo.pct_3_aciertos}" required>
                </div>
                <div class="astrogames_form_group">
                    <label>% 2 Aciertos</label>
                    <input type="number" name="pct_2_aciertos" min="0" max="100" value="{$ga_tramo.pct_2_aciertos}" required>
                </div>
            </div>

            <div class="astrogames_form_group">
                <label>Orden (1 = primer tramo)</label>
                <input type="number" name="orden" min="1" value="{$ga_tramo.orden}" required>
            </div>

            <div style="text-align:center; margin-top:14px;">
                <button type="submit" class="astrogames_btn gold">GUARDAR CAMBIOS</button>
                <a href="admin.php?page=gamesadmin&tab=loteria&mode=tramos" class="astrogames_btn">Cancelar</a>
            </div>

        </form>
    </div>
    {/if}

    {* Vista de crear nuevo *}
    {if !isset($ga_tramo) && !isset($ga_tramo_edit)}
    <div class="astrogames_panel">
        <div class="astrogames_title">Crear Nuevo Tramo</div>

        <div class="astrogames_tramo_info">
            <b>Recordatorio:</b> Los porcentajes deben sumar <b>100%</b>. Los tramos se aplican de menor a mayor jackpot.<br>
            El <b>jackpot hasta = 0</b> significa que no hay limite superior (ultimo tramo).
        </div>

        <form method="POST" action="admin.php?page=gamesadmin&tab=loteria&mode=tramoDoNew">

            <div class="astrogames_form_row">
                <div class="astrogames_form_group">
                    <label>Jackpot Desde (inclusive)</label>
                    <input type="number" name="jackpot_desde" min="0" value="0" required>
                </div>
                <div class="astrogames_form_group">
                    <label>Jackpot Hasta (0 = sin limite)</label>
                    <input type="number" name="jackpot_hasta" min="0" value="0">
                </div>
            </div>

            <div class="astrogames_form_row_3">
                <div class="astrogames_form_group">
                    <label>% Jackpot</label>
                    <input type="number" name="pct_jackpot" min="0" max="100" value="70" required>
                </div>
                <div class="astrogames_form_group">
                    <label>% 3 Aciertos</label>
                    <input type="number" name="pct_3_aciertos" min="0" max="100" value="20" required>
                </div>
                <div class="astrogames_form_group">
                    <label>% 2 Aciertos</label>
                    <input type="number" name="pct_2_aciertos" min="0" max="100" value="10" required>
                </div>
            </div>

            <div class="astrogames_form_group">
                <label>Orden (1 = primer tramo)</label>
                <input type="number" name="orden" min="1" value="1" required>
            </div>

            <div style="text-align:center; margin-top:14px;">
                <button type="submit" class="astrogames_btn gold">CREAR TRAMO</button>
                <a href="admin.php?page=gamesadmin&tab=loteria&mode=tramos" class="astrogames_btn">Cancelar</a>
            </div>

        </form>
    </div>
    {/if}

    {/if}

    {* -------- LOTERIA - VER SORTEO -------- *}
    {if $ga_sub_activa == 'ver' && isset($ga_lot_draw)}
    <div class="astrogames_panel">
        <div class="astrogames_title">Sorteo #{$ga_lot_draw.numero_sorteo}</div>
        <table class="astrogames_table">
            <tr><th style="width:200px;">Estado</th><td><span class="astrogames_badge {$ga_lot_draw.estado}">{$ga_lot_draw.estado}</span></td></tr>
            <tr><th>Jackpot</th><td><b style="color:#ffcc00;">{$ga_lot_draw.jackpot_total|number_format} NTX-20</b></td></tr>
            <tr><th>Fondo admin</th><td>{$ga_lot_draw.fondo_admin|number_format}</td></tr>
            <tr><th>Rollover anterior</th><td>{$ga_lot_draw.jackpot_anterior|number_format}</td></tr>
            <tr><th>Pozo Jackpot</th><td>{$ga_lot_draw.pozo_jackpot|default:0|number_format}</td></tr>
            <tr><th>Pozo 3 Aciertos</th><td>{$ga_lot_draw.pozo_3_aciertos|default:0|number_format}</td></tr>
            <tr><th>Pozo 2 Aciertos</th><td>{$ga_lot_draw.pozo_2_aciertos|default:0|number_format}</td></tr>
            <tr><th>Rollover 3 (anterior)</th><td>{$ga_lot_draw.rollover_3|default:0|number_format}</td></tr>
            <tr><th>Rollover 2 (anterior)</th><td>{$ga_lot_draw.rollover_2|default:0|number_format}</td></tr>
            <tr><th>Recaudado tickets</th><td>{$ga_lot_draw.tickets_recaudado|number_format}</td></tr>
            <tr><th>Tickets vendidos</th><td>{$ga_lot_draw.tickets_vendidos}</td></tr>
            <tr><th>Numeros sorteados</th><td>{$ga_lot_draw.numeros_sorteados|default:'-'}</td></tr>
            <tr><th>Hubo ganador</th><td>{if $ga_lot_draw.hubo_ganador_jackpot}<span style="color:#66ff99;">SI</span>{else}<span style="color:#ffaa33;">NO (rollover)</span>{/if}</td></tr>
            {if $ga_lot_draw.ganador_jackpot_id}
            <tr><th>Ganador jackpot</th><td>User #{$ga_lot_draw.ganador_jackpot_id}</td></tr>
            {/if}
            <tr><th>% Jackpot aplicado</th><td>{$ga_lot_draw.pct_jackpot_aplicado|default:70}%</td></tr>
            <tr><th>% 3 Aciertos aplicado</th><td>{$ga_lot_draw.pct_3_aplicado|default:20}%</td></tr>
            <tr><th>% 2 Aciertos aplicado</th><td>{$ga_lot_draw.pct_2_aplicado|default:10}%</td></tr>
            <tr><th>Fecha creacion</th><td>{$ga_lot_draw.fecha_inicio|date_format:"%d/%m/%Y %H:%M"}</td></tr>
            <tr><th>Fecha sorteo</th><td>{$ga_lot_draw.fecha_sorteo|date_format:"%d/%m/%Y %H:%M"}</td></tr>
        </table>
    </div>

    <div class="astrogames_panel">
        <div class="astrogames_title">Tickets Vendidos ({$ga_lot_draw.tickets_vendidos})</div>
        {if $ga_lot_hay_tickets|default:false}
        <table class="astrogames_table">
            <thead>
                <tr><th>#</th><th>Jugador</th><th>Numeros</th><th>Aciertos</th><th>Premio</th><th>Pagado</th></tr>
            </thead>
            <tbody>
                {foreach $ga_lot_tickets as $t}
                <tr>
                    <td>{$t.id}</td>
                    <td>{$t.username|default:'Anonimo'}</td>
                    <td>{$t.numeros}</td>
                    <td>{$t.aciertos|default:'-'}</td>
                    <td>{if $t.premio_ganado > 0}<b style="color:#ffcc00;">{$t.premio_ganado|number_format}</b>{else}-{/if}</td>
                    <td>{$t.precio_pagado}</td>
                </tr>
                {/foreach}
            </tbody>
        </table>
        {else}
        <div class="astrogames_empty">Sin tickets vendidos</div>
        {/if}
    </div>

    <div style="text-align:center;">
        <a href="admin.php?page=gamesadmin&tab=loteria&mode=sorteos" class="astrogames_btn">Volver</a>
        {if $ga_lot_draw.estado == 'abierto'}
        <a href="admin.php?page=gamesadmin&tab=loteria&mode=forzar&id={$ga_lot_draw.id}" class="astrogames_btn gold" onclick="return confirm('Forzar sorteo ahora?');">Forzar Sorteo</a>
        {/if}
    </div>
    {/if}

    {/if}

    {* ==================== LOG ==================== *}
    {if $ga_tab_activa == 'log'}
    <div class="astrogames_panel">
        <div class="astrogames_title">Auditoria (ultimos 100)</div>
        <table class="astrogames_table">
            <thead>
                <tr><th>Tipo</th><th>Ref</th><th>User</th><th>Accion</th><th>Detalle</th><th>Fecha</th></tr>
            </thead>
            <tbody>
                {foreach $ga_log_rows as $l}
                <tr>
                    <td><span class="astrogames_badge {if $l.tipo == 'rifas'}activo{else}urgent{/if}">{$l.tipo}</span></td>
                    <td>#{$l.ref_id}</td>
                    <td>{if $l.user_id}#{$l.user_id}{else}-{/if}</td>
                    <td>{$l.accion}</td>
                    <td style="font-size:10px;">{$l.detalle}</td>
                    <td>{$l.fecha|date_format:"%d/%m/%Y %H:%M"}</td>
                </tr>
                {foreachelse}
                <tr><td colspan="6" class="astrogames_empty">Sin registros</td></tr>
                {/foreach}
            </tbody>
        </table>
    </div>
    {/if}

</div>

{include file="overall_footer.tpl"}