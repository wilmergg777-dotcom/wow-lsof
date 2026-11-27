{include file="overall_header.tpl"}

{* ============================================================
   ASTROIO - PANEL ADMIN: BOOST DE FIN DE SEMANA
   ============================================================ *}

<style>
/* ══════════════════════════════════════════════════════════
   CONTENEDOR PRINCIPAL
   ══════════════════════════════════════════════════════════ */
.astro_wb_wrap {
    max-width: 1100px;
    margin: 20px auto;
    padding: 0 15px 40px 15px;
    font-family: 'Segoe UI', Tahoma, sans-serif;
    color: #cbd5e1;
    font-size: 13px;
}

/* ══════════════════════════════════════════════════════════
   HEADER
   ══════════════════════════════════════════════════════════ */
.astro_wb_header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.9), rgba(15, 23, 42, 0.9));
    border: 1px solid #1e293b;
    border-left: 4px solid #8b5cf6;
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 18px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astro_wb_title {
    font-size: 18px;
    font-weight: 800;
    color: #ffffff;
    letter-spacing: 0.5px;
}
.astro_wb_status {
    font-size: 12px;
    font-weight: 700;
    padding: 5px 14px;
    border-radius: 20px;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astro_wb_on {
    background: rgba(74, 255, 136, 0.15);
    color: #4aff88;
    border: 1px solid #4aff88;
    box-shadow: 0 0 12px rgba(74, 255, 136, 0.4);
}
.astro_wb_off {
    background: rgba(148, 163, 184, 0.15);
    color: #94a3b8;
    border: 1px solid #94a3b8;
}

/* ══════════════════════════════════════════════════════════
   MENSAJES
   ══════════════════════════════════════════════════════════ */
.astro_wb_msg {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-weight: 700;
    font-size: 13px;
}
.astro_wb_ok {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid #4aff88;
    color: #4aff88;
}
.astro_wb_err {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid #ef4444;
    color: #ef4444;
}

/* ══════════════════════════════════════════════════════════
   CARDS
   ══════════════════════════════════════════════════════════ */
.astro_wb_card {
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid #1e293b;
    border-radius: 12px;
    padding: 18px 20px;
    margin-bottom: 18px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}
.astro_wb_card_title {
    font-size: 13px;
    font-weight: 800;
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    padding-bottom: 10px;
    margin-bottom: 16px;
}

/* ══════════════════════════════════════════════════════════
   ESTADO ACTUAL
   ══════════════════════════════════════════════════════════ */
.astro_wb_state_tbl {
    width: 100%;
    border-collapse: collapse;
}
.astro_wb_state_tbl td {
    padding: 8px 0;
    font-size: 13px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}
.astro_wb_state_tbl td:first-child {
    color: #94a3b8;
    font-weight: 600;
    width: 200px;
}
.astro_wb_state_tbl td:last-child {
    color: #ffffff;
    font-weight: 700;
}

/* ══════════════════════════════════════════════════════════
   FORMULARIO
   ══════════════════════════════════════════════════════════ */
.astro_wb_check_row {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 14px;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 8px;
    border: 1px solid #1e293b;
    margin-bottom: 6px;
}
.astro_wb_check_row input[type="checkbox"] {
    width: 20px;
    height: 20px;
    cursor: pointer;
    accent-color: #00e0ff;
}
.astro_wb_check_row label {
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
    color: #ffffff;
    user-select: none;
}
.astro_wb_hint {
    font-size: 11px;
    color: #94a3b8;
    margin-top: 6px;
    font-style: italic;
}

/* ══════════════════════════════════════════════════════════
   VENTANA (INICIO/FIN)
   ══════════════════════════════════════════════════════════ */
.astro_wb_window {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-top: 10px;
}
.astro_wb_window_block {
    padding: 14px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid #1e293b;
    border-radius: 8px;
}
.astro_wb_window_block.start {
    border-left: 4px solid #4aff88;
}
.astro_wb_window_block.end {
    border-left: 4px solid #ef4444;
}
.astro_wb_window_label {
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 12px;
}
.astro_wb_window_block.start .astro_wb_window_label { color: #4aff88; }
.astro_wb_window_block.end   .astro_wb_window_label { color: #ef4444; }

.astro_wb_select_row {
    display: flex;
    gap: 10px;
    align-items: center;
}
.astro_wb_select_row select {
    flex: 1;
    padding: 8px 10px;
    background: rgba(15, 23, 42, 0.9);
    border: 1px solid #1e293b;
    border-radius: 6px;
    color: #ffffff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    outline: none;
    transition: border-color 0.2s;
}
.astro_wb_select_row select:hover,
.astro_wb_select_row select:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.25);
}

/* ══════════════════════════════════════════════════════════
   TABLA DE VALORES
   ══════════════════════════════════════════════════════════ */
.astro_wb_tbl {
    width: 100%;
    border-collapse: collapse;
    margin-top: 8px;
}
.astro_wb_tbl th {
    padding: 10px 8px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    color: #ffffff;
    font-size: 11px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    text-align: center;
    border-bottom: 1px solid #00e0ff;
}
.astro_wb_tbl th:first-child {
    text-align: left;
    border-top-left-radius: 8px;
}
.astro_wb_tbl th:last-child {
    border-top-right-radius: 8px;
}
.astro_wb_tbl td {
    padding: 8px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    font-size: 13px;
    text-align: center;
}
.astro_wb_tbl td:first-child {
    text-align: left;
    color: #cbd5e1;
    font-weight: 600;
}
.astro_wb_tbl input[type="number"] {
    width: 90px;
    padding: 6px 8px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid #1e293b;
    border-radius: 5px;
    color: #ffffff;
    font-size: 13px;
    font-weight: 700;
    text-align: center;
    outline: none;
    transition: all 0.2s;
}
.astro_wb_tbl input[type="number"]:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}
.astro_wb_tbl .col-normal input {
    border-color: rgba(148, 163, 184, 0.4);
    color: #cbd5e1;
}
.astro_wb_tbl .col-weekend input {
    border-color: rgba(74, 255, 136, 0.4);
    color: #4aff88;
    background: rgba(74, 255, 136, 0.05);
}
.astro_wb_tbl .col-current {
    color: #fbbf24;
    font-weight: 800;
    font-size: 14px;
}
.astro_wb_missing {
    color: #ef4444;
    font-size: 11px;
    font-weight: 700;
}

/* ══════════════════════════════════════════════════════════
   BOTONES
   ══════════════════════════════════════════════════════════ */
.astro_wb_btn_row {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    margin-top: 16px;
}
.astro_wb_btn {
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    cursor: pointer;
    border: 1px solid transparent;
    transition: all 0.2s ease;
    text-decoration: none;
    display: inline-block;
    color: #ffffff;
    font-family: inherit;
}
.astro_wb_btn:hover {
    transform: translateY(-2px);
}
.astro_wb_btn_save {
    background: linear-gradient(135deg, #008844, #00cc66);
    border-color: #00ff88;
}
.astro_wb_btn_save:hover {
    box-shadow: 0 0 18px rgba(0, 255, 136, 0.5);
}
.astro_wb_btn_apply {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    border-color: #00e0ff;
}
.astro_wb_btn_apply:hover {
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.5);
}
.astro_wb_btn_weekend {
    background: linear-gradient(135deg, #aa2200, #ff5500);
    border-color: #ff8844;
}
.astro_wb_btn_weekend:hover {
    box-shadow: 0 0 18px rgba(255, 136, 68, 0.5);
}
.astro_wb_btn_normal {
    background: linear-gradient(135deg, #334155, #475569);
    border-color: #94a3b8;
}
.astro_wb_btn_normal:hover {
    box-shadow: 0 0 18px rgba(148, 163, 184, 0.5);
}

/* ══════════════════════════════════════════════════════════
   DIAGNÓSTICO
   ══════════════════════════════════════════════════════════ */
.astro_wb_diag_tbl {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    margin-top: 8px;
}
.astro_wb_diag_tbl th {
    padding: 8px;
    background: rgba(0, 0, 0, 0.4);
    color: #00e0ff;
    font-weight: 800;
    text-align: left;
    font-size: 11px;
    text-transform: uppercase;
}
.astro_wb_diag_tbl td {
    padding: 6px 8px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    font-family: 'Courier New', monospace;
}
.astro_wb_diag_ok  { color: #4aff88; font-weight: 700; }
.astro_wb_diag_err { color: #ef4444; font-weight: 700; }

/* ══════════════════════════════════════════════════════════
   RESPONSIVE
   ══════════════════════════════════════════════════════════ */
@media (max-width: 720px) {
    .astro_wb_window { grid-template-columns: 1fr; }
    .astro_wb_btn    { width: 100%; text-align: center; }
}
</style>

<div class="astro_wb_wrap">

    {* ══════════════════════════════════════════════════════
       HEADER
       ══════════════════════════════════════════════════════ *}
    <div class="astro_wb_header">
        <span class="astro_wb_title">🎉 Boost de Fin de Semana</span>
        <span class="astro_wb_status {if $is_weekend}astro_wb_on{else}astro_wb_off{/if}">
            {if $is_weekend}🟢 BOOST ACTIVO{else}⚪ MODO NORMAL{/if}
        </span>
    </div>

    {* ══════════════════════════════════════════════════════
       MENSAJES
       ══════════════════════════════════════════════════════ *}
    {if $message}<div class="astro_wb_msg astro_wb_ok">{$message}</div>{/if}
    {if $error}<div class="astro_wb_msg astro_wb_err">{$error}</div>{/if}

    {* ══════════════════════════════════════════════════════
       ESTADO ACTUAL
       ══════════════════════════════════════════════════════ *}
    <div class="astro_wb_card">
        <div class="astro_wb_card_title">📊 Estado Actual</div>

        <table class="astro_wb_state_tbl">
            <tr>
                <td>Programación automática:</td>
                <td>
                    {if $cfg.enabled}
                        <span style="color:#4aff88;">✅ ACTIVADA</span>
                    {else}
                        <span style="color:#94a3b8;">⚪ DESACTIVADA</span>
                    {/if}
                </td>
            </tr>
            <tr>
                <td>Modo actual en el juego:</td>
                <td>
                    {if $is_weekend}
                        <span style="color:#4aff88;">🎉 FIN DE SEMANA (boost aplicado)</span>
                    {else}
                        <span style="color:#cbd5e1;">⚪ NORMAL (entre semana)</span>
                    {/if}
                </td>
            </tr>
            <tr>
                <td>Próximo cambio:</td>
                <td>
                    {if $cfg.enabled}
                        <strong style="color:#00e0ff;">{$next_change_what}</strong>
                        &nbsp;→&nbsp; {$next_change_time}
                    {else}
                        <span style="color:#94a3b8;">— (sistema desactivado)</span>
                    {/if}
                </td>
            </tr>
            <tr>
                <td>Último cambio aplicado:</td>
                <td>
                    {if $cfg.last_change > 0}
                        {$cfg.last_change|date_format:"%d/%m/%Y %H:%M"}
                    {else}
                        <span style="color:#94a3b8;">— (nunca)</span>
                    {/if}
                </td>
            </tr>
            <tr>
                <td>Último chequeo:</td>
                <td>
                    {if $cfg.last_check > 0}
                        {$cfg.last_check|date_format:"%d/%m/%Y %H:%M"}
                    {else}
                        <span style="color:#94a3b8;">— (nunca)</span>
                    {/if}
                </td>
            </tr>
        </table>
    </div>

    {* ══════════════════════════════════════════════════════
       FORMULARIO PRINCIPAL
       ══════════════════════════════════════════════════════ *}
    <form method="post" action="admin.php?page=weekendboost">

        {* ── CONTROL PRINCIPAL ── *}
        <div class="astro_wb_card">
            <div class="astro_wb_card_title">⚙️ Control Principal</div>

            <div class="astro_wb_check_row">
                <input type="checkbox"
                       name="enabled"
                       id="enabled"
                       value="1"
                       {if $cfg.enabled}checked{/if}>
                <label for="enabled">
                    🎉 Activar programación automática de fin de semana
                </label>
            </div>
            <div class="astro_wb_hint">
                Si desmarcas esta opción, el sistema dejará de cambiar las velocidades automáticamente.
                Los valores actuales se quedan como estén hasta que los cambies manualmente.
            </div>
        </div>

        {* ── VENTANA DE FIN DE SEMANA ── *}
        <div class="astro_wb_card">
            <div class="astro_wb_card_title">🗓️ Ventana de Fin de Semana</div>

            <div class="astro_wb_window">

                {* INICIO *}
                <div class="astro_wb_window_block start">
                    <div class="astro_wb_window_label">🟢 Inicio del Boost</div>
                    <div class="astro_wb_select_row">
                        <select name="start_day">
                            {foreach $days as $dayNum => $dayName}
                                <option value="{$dayNum}"
                                        {if $cfg.start_day == $dayNum}selected{/if}>
                                    {$dayName}
                                </option>
                            {/foreach}
                        </select>
                        <select name="start_hour">
                            {foreach $hours as $hourNum => $hourLabel}
                                <option value="{$hourNum}"
                                        {if $cfg.start_hour == $hourNum}selected{/if}>
                                    {$hourLabel}
                                </option>
                            {/foreach}
                        </select>
                    </div>
                </div>

                {* FIN *}
                <div class="astro_wb_window_block end">
                    <div class="astro_wb_window_label">🔴 Fin del Boost</div>
                    <div class="astro_wb_select_row">
                        <select name="end_day">
                            {foreach $days as $dayNum => $dayName}
                                <option value="{$dayNum}"
                                        {if $cfg.end_day == $dayNum}selected{/if}>
                                    {$dayName}
                                </option>
                            {/foreach}
                        </select>
                        <select name="end_hour">
                            {foreach $hours as $hourNum => $hourLabel}
                                <option value="{$hourNum}"
                                        {if $cfg.end_hour == $hourNum}selected{/if}>
                                    {$hourLabel}
                                </option>
                            {/foreach}
                        </select>
                    </div>
                </div>

            </div>
        </div>

        {* ── TABLA DE VALORES ── *}
        <div class="astro_wb_card">
            <div class="astro_wb_card_title">🎚️ Valores de Velocidad</div>

            <table class="astro_wb_tbl">
                <thead>
                    <tr>
                        <th style="width: 35%;">Stat</th>
                        <th style="width: 20%;">Normal (L-J)</th>
                        <th style="width: 20%;">Fin de semana</th>
                        <th style="width: 25%;">Aplicado ahora</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $rows_values as $r}
                        <tr>
                            <td>
                                {$r.label}
                                {if !$r.exists}
                                    <div class="astro_wb_missing">
                                        ⚠️ Columna "{$r.real}" no existe en BD
                                    </div>
                                {/if}
                            </td>
                            <td class="col-normal">
                                <input type="number"
                                       name="normal_{$r.logical}"
                                       value="{$r.normal}"
                                       step="0.01"
                                       min="0.01"
                                       max="9999">
                            </td>
                            <td class="col-weekend">
                                <input type="number"
                                       name="weekend_{$r.logical}"
                                       value="{$r.weekend}"
                                       step="0.01"
                                       min="0.01"
                                       max="9999">
                            </td>
                            <td class="col-current">
                                {if $r.exists}
                                    {$r.current}
                                {else}
                                    <span style="color:#ef4444;">✖</span>
                                {/if}
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>

            <div class="astro_wb_hint" style="margin-top:14px;">
                💡 Los valores con decimales se aceptan (ej: 1.5 = +50%). El multiplicador debe ser &gt; 0.
            </div>
        </div>

        {* ── BOTÓN GUARDAR ── *}
        <div class="astro_wb_btn_row">
            <button type="submit"
                    name="action"
                    value="save"
                    class="astro_wb_btn astro_wb_btn_save">
                💾 Guardar Configuración
            </button>
        </div>

    </form>

    {* ══════════════════════════════════════════════════════
       ACCIONES MANUALES
       ══════════════════════════════════════════════════════ *}
    <div class="astro_wb_card">
        <div class="astro_wb_card_title">🎛️ Acciones Manuales</div>

        <div class="astro_wb_hint" style="margin-bottom: 14px;">
            Estas acciones <strong>ignoran la ventana</strong> y aplican el cambio inmediatamente.
            Úsalas para probar o para corregir el estado manualmente.
        </div>

        <div class="astro_wb_btn_row">

            {* Aplicar estado calculado *}
            <form method="post" action="admin.php?page=weekendboost" style="display:inline;">
                <button type="submit"
                        name="action"
                        value="apply"
                        class="astro_wb_btn astro_wb_btn_apply">
                    🔄 Aplicar Estado Calculado
                </button>
            </form>

            {* Forzar BOOST *}
            <form method="post" action="admin.php?page=weekendboost" style="display:inline;"
                  onsubmit="return confirm('¿Forzar BOOST de fin de semana AHORA?');">
                <button type="submit"
                        name="action"
                        value="force_weekend"
                        class="astro_wb_btn astro_wb_btn_weekend">
                    🎉 Forzar BOOST Ahora
                </button>
            </form>

            {* Forzar NORMAL *}
            <form method="post" action="admin.php?page=weekendboost" style="display:inline;"
                  onsubmit="return confirm('¿Volver a modo NORMAL AHORA?');">
                <button type="submit"
                        name="action"
                        value="force_normal"
                        class="astro_wb_btn astro_wb_btn_normal">
                    ⚪ Forzar NORMAL Ahora
                </button>
            </form>

        </div>
    </div>

    {* ══════════════════════════════════════════════════════
       DIAGNÓSTICO (solo si hay columnas faltantes)
       ✅ CORREGIDO: usa $has_missing calculado en PHP
       ══════════════════════════════════════════════════════ *}
    {if $has_missing}
        <div class="astro_wb_card" style="border-left: 4px solid #ef4444;">
            <div class="astro_wb_card_title" style="color:#ef4444; border-bottom-color: rgba(239,68,68,0.3);">
                ⚠️ Diagnóstico: Columnas Faltantes en BD
            </div>

            <p style="color:#ef4444; font-weight:700; margin-bottom:12px;">
                Algunas columnas no existen en <code>uni1_config</code>. Revisa los nombres reales abajo
                y edita el archivo <code>WeekendBoostHelper.class.php</code> en la constante <code>CFG_COLUMNS</code>.
            </p>

            <table class="astro_wb_diag_tbl">
                <thead>
                    <tr>
                        <th>Stat</th>
                        <th>Columna esperada</th>
                        <th>¿Existe?</th>
                        <th>Valor actual</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $diag.columns as $col}
                        <tr>
                            <td>{$col.label}</td>
                            <td>{$col.real}</td>
                            <td>
                                {if $col.exists}
                                    <span class="astro_wb_diag_ok">✅ SÍ</span>
                                {else}
                                    <span class="astro_wb_diag_err">❌ NO</span>
                                {/if}
                            </td>
                            <td>
                                {if $col.exists && $col.current_value !== null}
                                    {$col.current_value}
                                {else}
                                    —
                                {/if}
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    {/if}

    {* ══════════════════════════════════════════════════════
       INFO DEL SISTEMA
       ══════════════════════════════════════════════════════ *}
    <div class="astro_wb_card" style="font-size: 12px; color: #94a3b8;">
        <div class="astro_wb_card_title" style="font-size: 12px;">ℹ️ Información del Sistema</div>

        <table class="astro_wb_state_tbl">
            <tr>
                <td>Zona horaria del servidor:</td>
                <td style="color:#00e0ff; font-family: 'Courier New', monospace;">
                    {$diag.timezone}
                </td>
            </tr>
            <tr>
                <td>Hora actual del servidor:</td>
                <td style="color:#00e0ff; font-family: 'Courier New', monospace;">
                    {$diag.now_formatted}
                </td>
            </tr>
            <tr>
                <td>Día de la semana:</td>
                <td style="color:#00e0ff;">
                    {$diag.day_name} ({$diag.day_of_week})
                </td>
            </tr>
            <tr>
                <td>Hora:</td>
                <td style="color:#00e0ff;">
                    {$diag.hour}:00
                </td>
            </tr>
        </table>

        <div class="astro_wb_hint" style="margin-top: 14px;">
            El sistema se ejecuta mediante un cron global cada 5 minutos.
            Para forzar el chequeo inmediatamente, añade <code>?force_wb_cron=1</code> a cualquier URL del juego.
        </div>
    </div>

</div>

{include file="overall_footer.tpl"}