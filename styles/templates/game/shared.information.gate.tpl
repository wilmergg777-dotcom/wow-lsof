[file name]: shared.information.gate.tpl
[file content begin]
{* ==========================================================
   ASTROIO — Shared Information: Jump Gate v3.0
   Estilo unificado (glassmorphism + acento cyan)
   FIX v3.0:
     - backdrop-filter + rgba en tabla
     - border-radius 12px
     - Variables --bg-card / --accent-cyan unificadas
     - box-sizing global
     - breakpoints 1200px / 720px
     - font-family monospace en inputs numéricos
     - 🔒 TODOS los hooks JS preservados:
       * class="countdown" + data-time
       * id="ship{$fleetID}_value" + id="ship{$fleetID}_input"
       * class="jumpgate" + name="ship[{$fleetID}]"
       * onclick="Gate.max({$fleetID})" + onclick="Gate.submit()"
       * {html_options name="jmpto" class="jumpgate"}
     - TODA la lógica Smarty preservada al 100%
   Mantiene TODA la lógica original de 2Moons
   ========================================================== *}

<style>
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

/* ─── RESET GLOBAL ─── */
.astroinfopop_gate,
.astroinfopop_gate *,
.astroinfopop_gate *::before,
.astroinfopop_gate *::after {
    box-sizing: border-box;
}

/* ─── TABLA PRINCIPAL ─── */
.astroinfopop_gate {
    width: 100%;
    background: rgba(15, 23, 42, 0.7) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(0, 224, 255, 0.25) !important;
    border-collapse: collapse;
    margin-top: 12px;
    border-radius: 12px;
    overflow: hidden;
    font-family: 'Segoe UI', Arial, sans-serif;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

/* ─── Cabecera principal ─── */
.astroinfopop_gate_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroinfopop_gate_th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    padding: 8px 12px !important;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 700;
    text-align: left;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroinfopop_gate_th_ship,
.astroinfopop_gate_th_avail,
.astroinfopop_gate_th_send {
    text-align: center;
}

/* ─── Filas generales ─── */
.astroinfopop_gate_row {
    background: transparent !important;
    transition: 0.2s ease;
}
.astroinfopop_gate_td {
    color: var(--text-main) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.1) !important;
    padding: 7px 12px !important;
    font-size: 11.5px;
    vertical-align: middle;
}
.astroinfopop_gate_row:hover .astroinfopop_gate_td {
    background: rgba(0, 224, 255, 0.04);
}

/* ─── Celdas específicas ─── */
.astroinfopop_gate_label_cell {
    color: var(--accent-cyan) !important;
    font-weight: 700;
    width: 33%;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.25);
}
.astroinfopop_gate_value_cell {
    color: var(--text-main) !important;
}

/* ─── Countdown ─── */
.astroinfopop_gate_countdown_cell {
    text-align: center;
    padding: 14px !important;
}
.astroinfopop_gate_label {
    color: var(--accent-cyan);
    font-weight: 700;
    margin-right: 6px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.astroinfopop_gate_time {
    color: var(--accent-gold);
    font-weight: 700;
    font-family: 'Courier New', monospace;
}
.astroinfopop_gate_countdown {
    color: var(--accent-gold);
    font-weight: 700;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.5);
}

/* ─── Cabecera de naves (segunda fila de th) ─── */
.astroinfopop_gate_ships_header {
    background: rgba(0, 224, 255, 0.08) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astroinfopop_gate_ships_header .astroinfopop_gate_th {
    background: rgba(0, 224, 255, 0.08) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: var(--accent-cyan) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.3) !important;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}

/* ─── Filas de naves ─── */
.astroinfopop_gate_ship_name {
    color: var(--text-main) !important;
    font-weight: 500;
}
.astroinfopop_gate_ship_avail {
    text-align: center;
}
.astroinfopop_gate_ship_count {
    color: var(--accent-green);
    font-weight: 700;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.3);
}
.astroinfopop_gate_ship_send {
    text-align: center;
}

/* ─── Input numérico de naves ─── */
.astroinfopop_gate_input {
    background: rgba(15, 23, 42, 0.95) !important;
    border: 1px solid rgba(0, 224, 255, 0.4) !important;
    border-radius: 6px !important;
    color: var(--accent-cyan) !important;
    padding: 5px 8px !important;
    font-size: 11px !important;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    text-align: center;
    width: 60px;
    outline: none;
    transition: all 0.25s ease;
}
.astroinfopop_gate_input:focus {
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5) !important;
    background: rgba(15, 23, 42, 1) !important;
}

/* ─── Botón MAX ─── */
.astroinfopop_gate_maxbtn {
    background: linear-gradient(135deg, #ff8800 0%, #ffaa33 100%) !important;
    border: 1px solid var(--accent-gold) !important;
    border-radius: 6px !important;
    color: #ffffff !important;
    padding: 5px 10px !important;
    font-size: 10px !important;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    cursor: pointer;
    margin-left: 6px;
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.astroinfopop_gate_maxbtn:hover {
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.6) !important;
    transform: translateY(-2px);
    background: linear-gradient(135deg, #ffaa33 0%, #ffcc66 100%) !important;
}

/* ─── Botón de saltar (grande) ─── */
.astroinfopop_gate_submit_row {
    background: rgba(0, 224, 255, 0.05) !important;
}
.astroinfopop_gate_submit_cell {
    text-align: center;
    padding: 12px !important;
}
.astroinfopop_gate_submitbtn {
    background: linear-gradient(135deg, #0066cc 0%, #00a8e0 100%) !important;
    border: 1px solid var(--accent-cyan) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    padding: 10px 32px !important;
    font-size: 12px !important;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    cursor: pointer;
    transition: all 0.25s ease;
    box-shadow: 0 4px 14px rgba(0, 224, 255, 0.3);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.astroinfopop_gate_submitbtn:hover {
    box-shadow: 0 0 22px rgba(0, 224, 255, 0.7) !important;
    transform: translateY(-2px);
    background: linear-gradient(135deg, #00a8e0 0%, #00e0ff 100%) !important;
}

/* ─── Mensaje de error (sin luna destino) ─── */
.astroinfopop_gate_empty_cell {
    text-align: center;
    padding: 14px !important;
}
.astroinfopop_gate_error {
    color: var(--accent-red);
    font-weight: 700;
    text-shadow: 0 0 8px rgba(239, 68, 68, 0.4);
}

/* ─── Selector de luna (html_options) ─── */
.astroinfopop_gate_value_cell select {
    background: rgba(15, 23, 42, 0.95) !important;
    border: 1px solid rgba(0, 224, 255, 0.4) !important;
    border-radius: 6px !important;
    color: var(--text-main) !important;
    padding: 6px 10px !important;
    font-size: 11.5px !important;
    font-family: 'Segoe UI', Arial, sans-serif;
    outline: none;
    min-width: 180px;
    cursor: pointer;
    transition: 0.25s ease;
}
.astroinfopop_gate_value_cell select:focus {
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5) !important;
}

/* ─── RESPONSIVE ─── */
@media (max-width: 1200px) {
    .astroinfopop_gate_th,
    .astroinfopop_gate_td {
        padding: 6px 8px !important;
        font-size: 11px;
    }
    .astroinfopop_gate_submitbtn {
        padding: 9px 24px !important;
        font-size: 11.5px !important;
    }
}

@media (max-width: 720px) {
    .astroinfopop_gate {
        margin-top: 8px;
        border-radius: 8px;
    }
    .astroinfopop_gate_th {
        font-size: 9.5px;
        padding: 6px 6px !important;
        letter-spacing: 0.5px;
    }
    .astroinfopop_gate_td {
        font-size: 10px;
        padding: 6px 6px !important;
    }
    .astroinfopop_gate_label_cell {
        width: 40%;
        font-size: 10px;
    }
    .astroinfopop_gate_ship_count {
        font-size: 11px;
    }
    .astroinfopop_gate_input {
        width: 50px;
        font-size: 10px !important;
        padding: 4px 6px !important;
    }
    .astroinfopop_gate_maxbtn {
        padding: 4px 8px !important;
        font-size: 9px !important;
        margin-left: 4px;
    }
    .astroinfopop_gate_submitbtn {
        width: 100%;
        padding: 10px 16px !important;
        font-size: 11px !important;
        letter-spacing: 1px;
    }
    .astroinfopop_gate_value_cell select {
        min-width: 100%;
        font-size: 11px !important;
    }
    .astroinfopop_gate_countdown_cell {
        padding: 10px !important;
    }
}
</style>

<table class="astroinfopop_gate">
    <tbody>
        <tr class="astroinfopop_gate_header">
            <th colspan="3" class="left astroinfopop_gate_th">{$LNG.in_jump_gate_select_ships}</th>
        </tr>

        {if $gateData.restTime != 0}
        {* ─── Puerta recargando ─── *}
        <tr class="astroinfopop_gate_row">
            <td colspan="3" class="astroinfopop_gate_td astroinfopop_gate_countdown_cell">
                <span class="astroinfopop_gate_label">{$LNG.in_jump_gate_wait_time}</span>
                <span class="astroinfopop_gate_time">{$gateData.nextTime}</span>
                &nbsp;(<span class="countdown astroinfopop_gate_countdown" data-time="{$gateData.restTime}">{pretty_fly_time($gateData.restTime)}</span>)
            </td>
        </tr>
        {else}
            {* ─── Luna origen ─── *}
            <tr class="astroinfopop_gate_row">
                <td class="astroinfopop_gate_td astroinfopop_gate_label_cell">{$LNG.in_jump_gate_start_moon}</td>
                <td colspan="2" class="astroinfopop_gate_td astroinfopop_gate_value_cell">{$gateData.startLink}</td>
            </tr>

            {if !empty($gateData.gateList)}
                {* ─── Selector de luna destino ─── *}
                <tr class="astroinfopop_gate_row">
                    <td class="astroinfopop_gate_td astroinfopop_gate_label_cell">{$LNG.in_jump_gate_finish_moon}</td>
                    <td colspan="2" class="astroinfopop_gate_td astroinfopop_gate_value_cell">{html_options options=$gateData.gateList name="jmpto" class="jumpgate"}</td>
                </tr>

                {* ─── Cabecera de naves ─── *}
                <tr class="astroinfopop_gate_ships_header">
                    <th class="astroinfopop_gate_th astroinfopop_gate_th_ship">{$LNG.fl_ship_type}</th>
                    <th class="astroinfopop_gate_th astroinfopop_gate_th_avail">{$LNG.fl_ship_available}</th>
                    <th class="astroinfopop_gate_th astroinfopop_gate_th_send"></th>
                </tr>

                {* ─── Lista de naves ─── *}
                {foreach $gateData.fleetList as $fleetID => $amount}
                <tr class="astroinfopop_gate_row astroinfopop_gate_ship_row">
                    <td class="astroinfopop_gate_td astroinfopop_gate_ship_name">{$LNG.tech.$fleetID}</td>
                    <td class="astroinfopop_gate_td astroinfopop_gate_ship_avail">
                        <span id="ship{$fleetID}_value" class="astroinfopop_gate_ship_count">{$amount|number}</span>
                    </td>
                    <td class="astroinfopop_gate_td astroinfopop_gate_ship_send">
                        <input class="jumpgate astroinfopop_gate_input"
                               name="ship[{$fleetID}]"
                               id="ship{$fleetID}_input"
                               size="7"
                               value="0"
                               type="text">
                        <input class="astroinfopop_gate_maxbtn"
                               onclick="Gate.max({$fleetID});"
                               value="max"
                               type="button">
                    </td>
                </tr>
                {/foreach}

                {* ─── Botón de saltar ─── *}
                <tr class="astroinfopop_gate_row astroinfopop_gate_submit_row">
                    <td colspan="3" class="astroinfopop_gate_td astroinfopop_gate_submit_cell">
                        <input class="astroinfopop_gate_submitbtn"
                               value="{$LNG.in_jump_gate_jump}"
                               type="button"
                               onclick="Gate.submit();">
                    </td>
                </tr>
            {else}
                {* ─── Sin luna destino ─── *}
                <tr class="astroinfopop_gate_row">
                    <td colspan="3" class="astroinfopop_gate_td astroinfopop_gate_empty_cell">
                        <span class="astroinfopop_gate_error">{$LNG.in_jump_gate_no_target}</span>
                    </td>
                </tr>
            {/if}
        {/if}
    </tbody>
</table>
[file content end]