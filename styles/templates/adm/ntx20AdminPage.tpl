{include file="overall_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   ASTROIO — Auditoria NTX-20 (Admin)
   Prefijo CSS: .ntx_
   ═══════════════════════════════════════════════ */

.ntx_wrap {
    padding: 18px;
    color: #cbd5e1;
    font-family: 'Segoe UI', Tahoma, sans-serif;
    font-size: 12px;
}

.ntx_title {
    font-size: 22px;
    font-weight: 800;
    color: #00e0ff;
    margin-bottom: 18px;
    text-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    letter-spacing: 0.5px;
}

/* ═══ PANEL BASE ═══ */
.ntx_panel {
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid #1e293b;
    border-radius: 12px;
    padding: 15px 18px;
    margin-bottom: 18px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.ntx_panel_title {
    color: #00e0ff;
    font-weight: 800;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1.3px;
    margin-bottom: 14px;
    padding-bottom: 8px;
    border-bottom: 1px solid #1e293b;
}

/* ═══ SELECTOR DE JUGADOR ═══ */
.ntx_selector_row {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    align-items: center;
    margin-bottom: 12px;
}

.ntx_selector_row label {
    font-size: 11px;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    font-weight: 700;
    margin-right: 6px;
}

.ntx_select,
.ntx_input {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid #1e293b;
    color: #cbd5e1;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 12px;
    font-family: 'Segoe UI', sans-serif;
    outline: none;
    transition: all 0.2s ease;
}

.ntx_select {
    min-width: 240px;
}

.ntx_select:hover,
.ntx_select:focus,
.ntx_input:hover,
.ntx_input:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.35);
}

.ntx_btn {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    border: 1px solid #00e0ff;
    color: #fff;
    padding: 8px 18px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    cursor: pointer;
    transition: all 0.2s ease;
    text-decoration: none;
    display: inline-block;
}

.ntx_btn:hover {
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
    color: #fff;
}

.ntx_btn_clear {
    background: rgba(30, 41, 59, 0.7);
    border-color: #475569;
    color: #94a3b8;
    padding: 7px 14px;
    font-size: 10px;
    text-decoration: none;
}

.ntx_btn_clear:hover {
    border-color: #ef4444;
    color: #ef4444;
    box-shadow: 0 0 12px rgba(239, 68, 68, 0.4);
}

/* ═══ HEADER DEL JUGADOR SELECCIONADO ═══ */
.ntx_user_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.6), rgba(0, 119, 204, 0.6));
    border: 1px solid #00e0ff;
    border-left: 4px solid #00e0ff;
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 15px;
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.2);
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.ntx_user_header_name {
    font-size: 18px;
    font-weight: 800;
    color: #ffffff;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.8);
}

.ntx_user_header_id {
    font-size: 12px;
    color: #a8c4e0;
    margin-right: auto;
}

/* ✅ v1.2 — BADGES DE RIEL */
.ntx_badge {
    padding: 4px 10px;
    border-radius: 6px;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 0.8px;
    text-transform: uppercase;
}
.ntx_badge_ntx {
    background: rgba(251, 191, 36, 0.2);
    border: 1px solid #fbbf24;
    color: #fbbf24;
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.3);
}
.ntx_badge_untx {
    background: rgba(0, 224, 255, 0.2);
    border: 1px solid #00e0ff;
    color: #00e0ff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}

/* ✅ v1.2 — AVISO QVAPAY */
.ntx_warning_box {
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid #ef4444;
    border-left: 4px solid #ef4444;
    border-radius: 8px;
    padding: 12px 15px;
    margin-bottom: 15px;
    color: #fca5a5;
    font-size: 12px;
    line-height: 1.5;
}
.ntx_warning_box b {
    color: #fff;
}

/* ═══ STATS CARDS ═══ */
.ntx_stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 15px;
}

.ntx_stat {
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    border: 1px solid #1e293b;
    border-radius: 10px;
    padding: 12px 15px;
    text-align: center;
}

.ntx_stat_lbl {
    font-size: 9px;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    margin-bottom: 6px;
    font-weight: 700;
}

.ntx_stat_val {
    font-size: 18px;
    font-weight: 800;
    font-family: 'Courier New', monospace;
}

.ntx_stat_val.cyan  { color: #00e0ff; }
.ntx_stat_val.red   { color: #ef4444; }
.ntx_stat_val.green { color: #4aff88; }
.ntx_stat_val.gold  { color: #fbbf24; }

/* ═══ FILTROS ═══ */
.ntx_filters {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    align-items: center;
    margin-bottom: 14px;
    padding: 10px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 8px;
}

.ntx_filters select {
    min-width: 140px;
}

/* ═══ TABLA HISTORIAL ═══ */
.ntx_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    table-layout: fixed;
}

.ntx_table th {
    background: linear-gradient(135deg, #004488, #0077cc);
    color: #ffffff;
    padding: 10px 10px;
    text-align: left;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    border-bottom: 2px solid #00e0ff;
}

.ntx_table td {
    padding: 9px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.7);
    vertical-align: middle;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.ntx_table tr:nth-child(even) td {
    background: rgba(0, 0, 0, 0.15);
}

.ntx_table tr:hover td {
    background: rgba(0, 224, 255, 0.06);
}

.ntx_table .num {
    text-align: right;
    font-family: 'Courier New', monospace;
}

.ntx_table .spend {
    color: #ef4444;
    font-weight: 700;
}

.ntx_table .earn {
    color: #4aff88;
    font-weight: 700;
}

.ntx_table .date {
    color: #94a3b8;
    font-size: 11px;
    font-family: 'Courier New', monospace;
}

.ntx_table .icon {
    font-size: 15px;
    text-align: center;
    width: 40px;
}

.ntx_table .balance {
    color: #94a3b8;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    text-align: right;
}

.ntx_table .ip {
    color: #64748b;
    font-size: 10px;
    font-family: 'Courier New', monospace;
}

/* ═══ EMPTY STATE ═══ */
.ntx_empty {
    text-align: center;
    padding: 30px;
    color: #64748b;
    font-size: 13px;
    font-style: italic;
}

/* ═══ PAGINACION ═══ */
.ntx_pagination {
    text-align: center;
    margin-top: 15px;
    padding-top: 12px;
    border-top: 1px solid #1e293b;
}

.ntx_pagination a,
.ntx_pagination span {
    display: inline-block;
    padding: 6px 13px;
    margin: 0 3px;
    background: rgba(15, 23, 42, 0.75);
    border: 1px solid #1e293b;
    color: #cbd5e1;
    border-radius: 6px;
    text-decoration: none;
    font-size: 11px;
    font-weight: 700;
    transition: all 0.2s ease;
}

.ntx_pagination a:hover {
    border-color: #00e0ff;
    color: #00e0ff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}

.ntx_pagination .cur {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #ffffff;
    border-color: #00e0ff;
}

.ntx_pagination .info {
    background: transparent;
    border: none;
    color: #64748b;
    font-size: 10px;
}

/* ═══ RESPONSIVE ═══ */
@media (max-width: 900px) {
    .ntx_stats {
        grid-template-columns: repeat(2, 1fr);
    }
}
@media (max-width: 600px) {
    .ntx_stats {
        grid-template-columns: 1fr;
    }
}

/* ═══ 🆕 v1.1 — FLASH MESSAGES ═══ */
.ntx_flash {
    padding: 12px 15px;
    margin-bottom: 15px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 700;
    border-left: 4px solid;
}
.ntx_flash.success {
    background: rgba(74, 255, 136, 0.15);
    border-color: #4aff88;
    color: #4aff88;
}
.ntx_flash.error {
    background: rgba(239, 68, 68, 0.15);
    border-color: #ef4444;
    color: #ef4444;
}
.ntx_flash.info {
    background: rgba(0, 224, 255, 0.15);
    border-color: #00e0ff;
    color: #00e0ff;
}

/* ═══ 🆕 v1.1 — CONFIG BOX ═══ */
.ntx_config_box {
    background: rgba(0, 0, 0, 0.25);
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
}

.ntx_config_title {
    color: #00e0ff;
    margin: 0 0 10px 0;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    font-weight: 800;
}

.ntx_config_note {
    color: #94a3b8;
    font-size: 12px;
    margin: 0 0 12px 0;
    line-height: 1.5;
}

.ntx_btn_warn {
    background: linear-gradient(135deg, #dd8800, #ffaa33) !important;
    border-color: #ffaa33 !important;
}

.ntx_btn_warn:hover {
    box-shadow: 0 0 16px rgba(255, 170, 51, 0.7) !important;
}

/* ═══ 🆕 v1.1 — DANGER ZONE ═══ */
.ntx_danger {
    background: rgba(239, 68, 68, 0.08);
    border: 1px solid #ef4444;
    border-left: 4px solid #ef4444;
    border-radius: 10px;
    padding: 15px;
}

.ntx_danger_title {
    color: #ef4444;
    margin: 0 0 10px 0;
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    font-weight: 800;
}

.ntx_danger_note {
    color: #fca5a5;
    font-size: 12px;
    margin: 0 0 12px 0;
    line-height: 1.5;
}

.ntx_danger_confirm {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid #ef4444;
    color: #fff;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    min-width: 200px;
    outline: none;
}

.ntx_btn_danger {
    background: linear-gradient(135deg, #991b1b, #ef4444);
    border: 1px solid #ef4444;
    color: #fff;
    padding: 10px 20px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: all 0.2s;
}

.ntx_btn_danger:hover {
    box-shadow: 0 0 20px rgba(239, 68, 68, 0.7);
}
</style>

<div class="ntx_wrap">

    <div class="ntx_title">👑 Auditoría NTX-20 — Historial por Jugador</div>

    {* 🆕 v1.1 — Flash message *}
    {if isset($flashMessage) && $flashMessage}
        <div class="ntx_flash {$flashType}">
            {$flashMessage}
        </div>
    {/if}

    {* ═══════════════════════════════════════════════
       SELECTOR DE JUGADOR
       ═══════════════════════════════════════════════ *}
    <div class="ntx_panel">
        <div class="ntx_panel_title">🔍 Seleccionar Jugador</div>

        <form method="get" action="admin.php" class="ntx_selector_row">
            <input type="hidden" name="page" value="ntx20admin">

            <label>Jugador:</label>
            <select name="user_id" class="ntx_select" onchange="this.form.submit()">
                {foreach $userList as $u}
                    <option value="{$u.id}" {if $u.id == $selectedUser}selected{/if}>
                        {$u.username} (#{$u.id})
                    </option>
                {/foreach}
            </select>

            <button type="submit" class="ntx_btn">🔍 Ver</button>
        </form>

        <form method="get" action="admin.php" class="ntx_selector_row">
            <input type="hidden" name="page" value="ntx20admin">

            <label>O escribí el ID:</label>
            <input type="number" name="user_id" class="ntx_input" placeholder="Ej: 2"
                   value="{if $selectedUser}{$selectedUser}{/if}" style="width:120px;">

            <button type="submit" class="ntx_btn">🔍 Buscar</button>

            {if $selectedUser}
                <a href="admin.php?page=ntx20admin" class="ntx_btn ntx_btn_clear">✕ Limpiar</a>
            {/if}
        </form>
    </div>

    {* ═══════════════════════════════════════════════
       DATOS DEL JUGADOR SELECCIONADO
       ═══════════════════════════════════════════════ *}
    {if $userData}

        {* Header con nombre + ID + RIEL *}
        <div class="ntx_user_header">
            <span class="ntx_user_header_name">👤 {$userData.username}</span>
            <span class="ntx_user_header_id">#{$userData.id}</span>
            
            {* ✅ v1.2 — Badge del Riel (Blindado con isset) *}
            {if isset($isQvapay) && $isQvapay}
                <span class="ntx_badge ntx_badge_untx">UNTX-20 (QVAPAY)</span>
            {else}
                <span class="ntx_badge ntx_badge_ntx">NTX-20 (CUP)</span>
            {/if}
        </div>

        {* ✅ v1.2 — Aviso especial si el jugador es QVAPAY (Blindado) *}
        {if isset($isQvapay) && $isQvapay}
            <div class="ntx_warning_box">
                ⚠️ <b>Atención:</b> Este jugador opera en el riel <b>UNTX-20</b> (QVAPAY). 
                La auditoría actual <b>solo registra movimientos del riel CUP (NTX-20)</b>, 
                por lo que este historial puede aparecer vacío o no reflejar sus movimientos reales en UNTX-20.
            </div>
        {/if}

        {* Cards de stats *}
        <div class="ntx_stats">
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">💰 Total Gastado</div>
                <div class="ntx_stat_val red">{$stats.total_spent_fmt}</div>
            </div>
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">📈 Total Ganado</div>
                <div class="ntx_stat_val green">{$stats.total_earned_fmt}</div>
            </div>
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">⚖️ Balance</div>
                <div class="ntx_stat_val {if $stats.balance < 0}red{else}green{/if}">
                    {$stats.balance_fmt}
                </div>
            </div>
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">📊 Movimientos</div>
                <div class="ntx_stat_val cyan">{$stats.total_movements}</div>
            </div>
        </div>

        {* ═══════════════════════════════════════════════
           FILTROS + TABLA DE HISTORIAL
           ═══════════════════════════════════════════════ *}
        <div class="ntx_panel">
            <div class="ntx_panel_title">📜 Historial ({$totalRows} registros)</div>

            <form method="get" action="admin.php" class="ntx_filters">
                <input type="hidden" name="page"    value="ntx20admin">
                <input type="hidden" name="user_id" value="{$selectedUser}">

                <label style="font-size:10px;color:#94a3b8;text-transform:uppercase;letter-spacing:0.8px;font-weight:700;">
                    Fecha:
                </label>
                <select name="days" class="ntx_input">
                    <option value="0"  {if $filterDays==0}selected{/if}>Todo el tiempo</option>
                    <option value="1"  {if $filterDays==1}selected{/if}>Últimas 24h</option>
                    <option value="7"  {if $filterDays==7}selected{/if}>Últimos 7 días</option>
                    <option value="30" {if $filterDays==30}selected{/if}>Últimos 30 días</option>
                    <option value="90" {if $filterDays==90}selected{/if}>Últimos 90 días</option>
                </select>

                <label style="font-size:10px;color:#94a3b8;text-transform:uppercase;letter-spacing:0.8px;font-weight:700;">
                    Tipo:
                </label>
                <select name="type" class="ntx_input">
                    <option value="">— Todos —</option>
                    {foreach $typesList as $t}
                        <option value="{$t.value}" {if $filterType==$t.value}selected{/if}>
                            {$t.icon} {$t.label}
                        </option>
                    {/foreach}
                </select>

                <label style="font-size:10px;color:#94a3b8;text-transform:uppercase;letter-spacing:0.8px;font-weight:700;">
                    Dirección:
                </label>
                <select name="direction" class="ntx_input">
                    <option value=""      {if $filterDir==""}selected{/if}>— Todo —</option>
                    <option value="spend" {if $filterDir=="spend"}selected{/if}>Solo gastos</option>
                    <option value="earn"  {if $filterDir=="earn"}selected{/if}>Solo ingresos</option>
                </select>

                <button type="submit" class="ntx_btn">🔍 Aplicar</button>

                {if $filterType || $filterDir || $filterDays}
                    <a href="admin.php?page=ntx20admin&user_id={$selectedUser}"
                       class="ntx_btn ntx_btn_clear">✕ Limpiar</a>
                {/if}
            </form>

            {if $history|@count > 0}
                <table class="ntx_table">
                    <thead>
                        <tr>
                            <th style="width:130px;">📅 Fecha</th>
                            <th style="width:50px;text-align:center;">Icono</th>
                            <th style="width:180px;">Categoría</th>
                            <th>Descripción</th>
                            <th style="width:110px;" class="num">Monto</th>
                            <th style="width:100px;" class="num">Saldo</th>
                            <th style="width:130px;">IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $history as $h}
                        <tr>
                            <td class="date">{$h.date}</td>
                            <td class="icon">{$h.icon}</td>
                            <td><b>{$h.label}</b></td>
                            <td style="color:#94a3b8;font-size:11px;">{$h.description}</td>
                            <td class="num {if $h.is_spend}spend{else}earn{/if}">
                                {* ✅ v1.2 — Aclaramos que este monto siempre es NTX-20 *}
                                {$h.sign}{$h.amount_fmt} NTX-20
                            </td>
                            <td class="balance">{$h.balance_fmt}</td>
                            <td class="ip">{$h.ip_legible}</td>
                        </tr>
                        {/foreach}
                    </tbody>
                </table>

                {* Paginación *}
                {if $totalPages > 1}
                <div class="ntx_pagination">
                    {if $page > 1}
                        <a href="admin.php?page=ntx20admin&user_id={$selectedUser}&type={$filterType}&direction={$filterDir}&days={$filterDays}&page_num={$page-1}">← Anterior</a>
                    {/if}

                    <span class="cur">{$page} / {$totalPages}</span>

                    {if $page < $totalPages}
                        <a href="admin.php?page=ntx20admin&user_id={$selectedUser}&type={$filterType}&direction={$filterDir}&days={$filterDays}&page_num={$page+1}">Siguiente →</a>
                    {/if}

                    <br>
                    <span class="info">Mostrando {$history|@count} de {$totalRows} registros</span>
                </div>
                {/if}

            {else}
                <div class="ntx_empty">
                    📭 Sin movimientos para mostrar con los filtros aplicados
                </div>
            {/if}
        </div>

    {else}
        <div class="ntx_panel">
            <div class="ntx_empty">
                👆 Seleccioná un jugador para ver su historial
            </div>
        </div>
    {/if}

    {* ═══════════════════════════════════════════════════════
       🆕 v1.1 — CONFIGURACIÓN DE RETENCIÓN + MANTENIMIENTO
       ═══════════════════════════════════════════════════════ *}
    <div class="ntx_panel" style="margin-top: 20px;">
        <div class="ntx_panel_title">⚙️ Configuración de Retención y Mantenimiento</div>

        {* Stats del log actual *}
        <div class="ntx_stats" style="margin-bottom: 20px;">
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">📊 Total Registros</div>
                <div class="ntx_stat_val cyan">{$logStats.total|number_format}</div>
            </div>
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">📅 Más Antiguo</div>
                <div class="ntx_stat_val" style="font-size: 12px; color: #94a3b8;">
                    {$logStats.oldest_fmt}
                </div>
            </div>
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">📅 Más Reciente</div>
                <div class="ntx_stat_val" style="font-size: 12px; color: #94a3b8;">
                    {$logStats.newest_fmt}
                </div>
            </div>
            <div class="ntx_stat">
                <div class="ntx_stat_lbl">💾 Tamaño Aprox.</div>
                <div class="ntx_stat_val gold">{$logStats.size_mb} MB</div>
            </div>
        </div>

        {* Formulario: Retención *}
        <div class="ntx_config_box">
            <h4 class="ntx_config_title">🗓️ Retención automática</h4>

            <p class="ntx_config_note">
                Los registros más antiguos que esta cantidad serán <b style="color: #ef4444;">eliminados automáticamente</b>
                por el cron cada 24 horas.
            </p>

            <form method="post" action="admin.php?page=ntx20admin"
                  style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                <input type="hidden" name="action" value="saveRetention">

                <label style="color: #cbd5e1; font-weight: 700; font-size: 12px;">
                    Mantener logs de:
                </label>

                <select name="retention_months" class="ntx_input" style="min-width: 220px;">
                    <option value="1"  {if $retentionMonths == 1}selected{/if}>1 mes</option>
                    <option value="2"  {if $retentionMonths == 2}selected{/if}>2 meses</option>
                    <option value="3"  {if $retentionMonths == 3}selected{/if}>3 meses</option>
                    <option value="6"  {if $retentionMonths == 6}selected{/if}>6 meses</option>
                    <option value="12" {if $retentionMonths == 12}selected{/if}>1 año</option>
                    <option value="24" {if $retentionMonths == 24}selected{/if}>2 años</option>
                    <option value="0"  {if $retentionMonths == 0}selected{/if}>∞ Ilimitado (nunca borrar)</option>
                </select>

                <button type="submit" class="ntx_btn">💾 Guardar</button>

                <button type="submit" name="action" value="cleanupNow"
                        class="ntx_btn ntx_btn_warn"
                        onclick="return confirm('¿Ejecutar limpieza manual AHORA? Se borrarán los logs viejos según la configuración actual.');">
                    🔄 Limpiar ahora
                </button>
            </form>

            {if $retentionMonths == 0}
                <p style="color: #fbbf24; font-size: 11px; margin: 10px 0 0 0;">
                    ⚠️ <b>Modo ilimitado activo:</b> los logs NUNCA se borrarán automáticamente.
                    El tamaño de la BD crecerá con el tiempo.
                </p>
            {/if}
        </div>

        {* Formulario: Borrar TODO *}
        <div class="ntx_danger">
            <h4 class="ntx_danger_title">⚠️ Zona Peligrosa</h4>

            <p class="ntx_danger_note">
                <b>Borra TODOS los registros del log de NTX-20</b> de forma permanente.
                Esta acción <b>NO se puede deshacer</b>.
                Útil cuando la tabla creció demasiado o querés empezar de cero.
            </p>

            <form method="post" action="admin.php?page=ntx20admin"
                  onsubmit="return confirm('⚠️ ÚLTIMA ADVERTENCIA ⚠️\n\n¿Estás SEGURO de borrar TODOS los registros?\n\nEsta acción NO se puede deshacer.');">
                <input type="hidden" name="action" value="clearAll">

                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap; margin-bottom: 10px;">
                    <label style="color: #fca5a5; font-weight: 700; font-size: 12px;">
                        Escribí exactamente <code style="background: rgba(0,0,0,0.4); padding: 2px 6px; border-radius: 4px; color: #fff;">BORRAR TODO</code> para confirmar:
                    </label>
                    <input type="text" name="confirm_text"
                           class="ntx_danger_confirm"
                           placeholder="BORRAR TODO"
                           autocomplete="off">
                </div>

                <button type="submit" class="ntx_btn_danger">
                    🗑️ BORRAR TODO EL LOG
                </button>
            </form>
        </div>
    </div>

</div>

{include file="overall_footer.tpl"}