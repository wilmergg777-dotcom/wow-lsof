{block name="content"}

{* ============================================================
 * BANCO DE ALIANZA - AstroIO v2.0 (DUAL RIEL)
 * Prefijo CSS: .astrobank_
 * FIX: Eliminados TODOS los caracteres especiales y emojis
 * para evitar errores de codificacion (??).
 *
 * v2.0 (2026-10-30) - DUAL RIEL:
 *  - Badge de saldo con la moneda del riel ({$moneda})
 *  - Tarjeta de moneda usa {$bank_visible} (solo el bolsillo
 *    del riel del jugador, NUNCA el otro)
 *  - Selectores de deposito/retiro muestran {$moneda} y {$moneda_fiat}
 *  - Botones de upgrade muestran {$moneda}
 *  - Historial usa {$h.recurso_label} (dinamico)
 *  - Cero hardcodeos de "NTX-20", "UNTX-20", "CUP", "USD"
 *  - Secciones de metales y MO intactas (sin dual riel)
 * ============================================================ *}

<style>
/* ====== Variables globales ====== */
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

.astrobank_wrap { text-align: center; padding: 15px; box-sizing: border-box; }

.astrobank_ {
    width: 900px;
    max-width: 100%;
    display: inline-block;
    text-align: left;
    font-family: Verdana, Arial, sans-serif;
    font-size: 11px;
    color: var(--text-main);
}

/* Cajas generales (glassmorphism) */
.astrobank_box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 14px;
    margin-bottom: 12px;
    transition: 0.2s ease;
}
.astrobank_box:hover {
    border-color: rgba(0, 204, 255, 0.3);
}
.astrobank_title {
    color: #00e0ff;
    font-size: 12px;
    font-weight: bold;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 12px;
    letter-spacing: 0.5px;
}
.astrobank_subtitle {
    color: var(--text-muted);
    font-size: 10px;
    margin-bottom: 8px;
}

/* Mensajes flash */
.astrobank_msg_ok {
    background: linear-gradient(180deg, rgba(0, 51, 34, 0.7), rgba(0, 34, 17, 0.7));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #66ff99;
    padding: 10px 14px;
    border-radius: 10px;
    border: 1px solid rgba(102, 255, 153, 0.3);
    border-left: 3px solid #66ff99;
    margin-bottom: 12px;
}
.astrobank_msg_err {
    background: linear-gradient(180deg, rgba(51, 0, 17, 0.7), rgba(34, 0, 8, 0.7));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #ff4488;
    padding: 10px 14px;
    border-radius: 10px;
    border: 1px solid rgba(255, 68, 136, 0.3);
    border-left: 3px solid #ff4488;
    margin-bottom: 12px;
}

/* 🆕 v2.0 — Badge de saldo del jugador */
.astrobank_balance_box {
    text-align: center;
    margin-bottom: 12px;
    padding: 8px 14px;
    background: rgba(0, 40, 20, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.2);
}
.astrobank_balance_badge {
    color: #66ff99;
    font-size: 12px;
    font-weight: 600;
}
.astrobank_balance_badge strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    letter-spacing: 0.5px;
}

/* Boton volver a la alianza */
.astrobank_back_btn {
    display: inline-block;
    padding: 7px 18px;
    background: linear-gradient(135deg, rgba(0, 119, 204, 0.9), rgba(0, 68, 136, 0.9));
    color: #fff !important;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none !important;
    transition: 0.25s ease;
}
.astrobank_back_btn:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 85, 170, 0.95));
    box-shadow: 0 0 14px rgba(0, 204, 255, 0.5);
    color: #fff !important;
    transform: translateY(-2px);
}
.astrobank_back_btn:active {
    transform: translateY(0);
}

/* Boton del arbol de Talentos */
.astrobank_talent_btn {
    display: inline-block;
    padding: 7px 18px;
    background: linear-gradient(135deg, rgba(34, 204, 102, 0.9), rgba(17, 136, 51, 0.9));
    color: #fff !important;
    border: 1px solid #33dd77;
    border-radius: 8px;
    font-size: 10.5px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-decoration: none !important;
    transition: 0.25s ease;
}
.astrobank_talent_btn:hover {
    background: linear-gradient(135deg, rgba(51, 221, 119, 0.95), rgba(17, 153, 68, 0.95));
    box-shadow: 0 0 14px rgba(34, 204, 102, 0.5);
    color: #fff !important;
    transform: translateY(-2px);
}
.astrobank_talent_btn:active {
    transform: translateY(0);
}

/* Cabecera con nombre alianza (acento Purpura) */
.astrobank_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(85, 0, 170, 0.9));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(187, 102, 255, 0.4);
    border-radius: 12px;
    padding: 12px 16px;
    margin-bottom: 12px;
    box-shadow: 0 4px 20px rgba(119, 0, 204, 0.4);
}
.astrobank_header h2 {
    margin: 0;
    color: #fff;
    font-size: 15px;
    text-transform: uppercase;
    text-shadow: 0 2px 6px rgba(0, 0, 0, 0.4);
}
.astrobank_header .lvl {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    padding: 4px 12px;
    border-radius: 6px;
    color: #fff;
    font-weight: bold;
    font-size: 12px;
}

/* Grid de recursos */
.astrobank_resources {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 10px;
}
.astrobank_res_card {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 10px;
    text-align: center;
    transition: 0.25s ease;
}
.astrobank_res_card:hover {
    border-color: rgba(0, 204, 255, 0.4);
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.25);
    transform: translateY(-2px);
}
.astrobank_res_card h4 {
    margin: 0 0 6px 0;
    color: var(--text-muted);
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrobank_res_card .val {
    color: #fff;
    font-size: 13px;
    font-weight: bold;
    word-break: break-all;
}
.astrobank_res_card .cap {
    color: #5a6a7a;
    font-size: 9px;
    margin-top: 4px;
}
.astrobank_bar {
    width: 100%;
    height: 4px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 2px;
    margin-top: 6px;
    overflow: hidden;
}
.astrobank_bar_fill {
    height: 100%;
    background: linear-gradient(90deg, #00ccff, #00e0ff);
    border-radius: 2px;
    transition: 0.3s ease;
}
.astrobank_bar_fill.high { background: linear-gradient(90deg, #ffaa33, #ffcc44); }
.astrobank_bar_fill.full { background: linear-gradient(90deg, #ff4488, #ff66aa); }

/* Formularios */
.astrobank_form {
    display: flex;
    gap: 8px;
    align-items: center;
    flex-wrap: wrap;
}
.astrobank_input, .astrobank_select {
    background: rgba(0, 0, 0, 0.5);
    color: #fff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 8px 10px;
    font-size: 11px;
    font-family: inherit;
    outline: none;
    transition: 0.25s ease;
}
.astrobank_input:focus, .astrobank_select:focus {
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}
.astrobank_input { flex: 1; min-width: 100px; }
.astrobank_select { min-width: 180px; cursor: pointer; }
.astrobank_select option { background: #0f1624; color: #fff; }

.astrobank_btn {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.9), rgba(119, 0, 204, 0.9));
    color: #fff;
    padding: 8px 18px;
    border: 1px solid #bb66ff;
    border-radius: 8px;
    font-weight: bold;
    font-size: 11px;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-family: inherit;
}
.astrobank_btn:hover {
    background: linear-gradient(135deg, rgba(187, 102, 255, 0.95), rgba(136, 0, 221, 0.95));
    box-shadow: 0 0 14px rgba(170, 68, 255, 0.6);
    transform: translateY(-2px);
}
.astrobank_btn:active {
    transform: translateY(0);
}
.astrobank_btn_danger {
    background: linear-gradient(135deg, rgba(204, 34, 85, 0.9), rgba(136, 0, 51, 0.9));
    border-color: #ee3377;
}
.astrobank_btn_danger:hover {
    background: linear-gradient(135deg, rgba(221, 51, 119, 0.95), rgba(153, 0, 68, 0.95));
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.6);
}
.astrobank_btn_ok {
    background: linear-gradient(135deg, rgba(34, 204, 102, 0.9), rgba(17, 136, 51, 0.9));
    border-color: #33dd77;
}
.astrobank_btn_ok:hover {
    background: linear-gradient(135deg, rgba(51, 221, 119, 0.95), rgba(17, 153, 68, 0.95));
    box-shadow: 0 0 14px rgba(34, 204, 102, 0.6);
}
.astrobank_btn:disabled {
    opacity: 0.4;
    cursor: not-allowed;
    background: #333 !important;
    border-color: #444 !important;
    transform: none !important;
    box-shadow: none !important;
}

/* Configuracion */
.astrobank_config_row {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-bottom: 8px;
    padding: 8px;
    background: rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 204, 255, 0.1);
    border-radius: 10px;
    transition: 0.2s ease;
}
.astrobank_config_row:hover {
    border-color: rgba(0, 204, 255, 0.25);
}
.astrobank_config_row label {
    min-width: 120px;
    color: var(--text-muted);
    font-size: 10px;
    text-transform: uppercase;
}

/* Historial */
.astrobank_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}
.astrobank_table th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #fff;
    padding: 6px 8px;
    text-align: left;
    border-bottom: 1px solid var(--accent-cyan);
    font-size: 10px;
    text-transform: uppercase;
}
.astrobank_table td {
    padding: 6px 8px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    color: var(--text-main);
}
.astrobank_table tr:hover td {
    background: rgba(0, 204, 255, 0.05);
}
.astrobank_table .tag {
    display: inline-block;
    padding: 1px 6px;
    border-radius: 4px;
    font-size: 9px;
    font-weight: bold;
    text-transform: uppercase;
}
.astrobank_table .tag.deposit { background: rgba(0, 51, 34, 0.8); color: #66ff99; }
.astrobank_table .tag.withdraw { background: rgba(51, 0, 17, 0.8); color: #ff4488; }
.astrobank_table .tag.upgrade { background: rgba(51, 0, 102, 0.8); color: #aa88ff; }
.astrobank_table .tag.bonus_set { background: rgba(0, 51, 85, 0.8); color: #66ccff; }
.astrobank_table .tag.bonus_change { background: rgba(51, 34, 0, 0.8); color: #ffcc44; }
.astrobank_table .tag.tesorero_change { background: rgba(34, 0, 51, 0.8); color: #cc88ff; }
.astrobank_table .tag.admin { background: rgba(34, 34, 34, 0.8); color: #aaa; }
.astrobank_table .tag.dissolve { background: rgba(68, 0, 0, 0.8); color: #ff6666; }

/* Botones tabs */
.astrobank_tabs {
    display: flex;
    gap: 4px;
    margin-bottom: 12px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    padding-bottom: 6px;
}
.astrobank_tab {
    padding: 7px 16px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 8px 8px 0 0;
    color: var(--text-muted);
    font-size: 11px;
    font-weight: bold;
    cursor: pointer;
    text-transform: uppercase;
    transition: 0.25s ease;
}
.astrobank_tab:hover {
    color: #00e0ff;
    border-color: rgba(0, 204, 255, 0.5);
    transform: translateY(-1px);
}
.astrobank_tab.active {
    background: rgba(15, 23, 42, 0.75);
    color: #00e0ff;
    border-color: #00ccff;
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.3);
}
.astrobank_section { display: none; }
.astrobank_section.active { display: block; }

/* Responsive */
@media (max-width: 720px) {
    .astrobank_wrap { padding: 10px; }
    .astrobank_ { width: 100%; }
    .astrobank_box { padding: 12px; }
    .astrobank_resources { grid-template-columns: repeat(2, 1fr); }
    .astrobank_header { flex-direction: column; gap: 8px; text-align: center; }
    .astrobank_form { flex-direction: column; align-items: stretch; }
    .astrobank_select, .astrobank_input, .astrobank_btn { width: 100%; }
}
</style>

<div class="astrobank_wrap">
<div class="astrobank_">

    {* ============ MENSAJES FLASH ============ *}
    {if $msg}
        <div class="{if $msg_type == 'ok'}astrobank_msg_ok{else}astrobank_msg_err{/if}">
            {$msg|escape:'html'}
        </div>
    {/if}

    {* ============ BOTON VOLVER + ARBOL ============ *}
    <div style="text-align:left; margin-bottom:8px;">
        <a href="game.php?page=alliance" class="astrobank_back_btn">&lt;- Volver a la Alianza</a>
        <a href="game.php?page=allianceTalent" class="astrobank_talent_btn" style="margin-left:8px;">Arbol de Talentos</a>
    </div>

    {* 🆕 v2.0 — BADGE DE SALDO DEL JUGADOR *}
    <div class="astrobank_balance_box">
        <span class="astrobank_balance_badge">
            💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}
        </span>
    </div>

    {* ============ CABECERA ============ *}
    <div class="astrobank_header">
        <h2>Banco de la Alianza - [{$alliance_tag}] {$alliance_name}</h2>
        <div class="lvl">Nivel {$bank.level} / 25</div>
    </div>

    {* ============ SALDO ACTUAL ============ *}
    <div class="astrobank_box">
        <div class="astrobank_title">Saldo actual - Capacidad: {$capacity_fmt} por recurso</div>

        <div class="astrobank_resources">
            {* Metal *}
            {assign var="pct_metal" value=0}
            {if $capacity > 0}{assign var="pct_metal" value=($bank.metal/$capacity*100)}{/if}
            <div class="astrobank_res_card">
                <h4>Metal</h4>
                <div class="val">{$bank.metal|number_format:0:',,':'.'}</div>
                <div class="cap">/ {$capacity_fmt}</div>
                <div class="astrobank_bar">
                    <div class="astrobank_bar_fill{if $pct_metal > 90} full{elseif $pct_metal > 70} high{/if}" style="width:{$pct_metal|number_format:0}%"></div>
                </div>
            </div>

            {* Cristal *}
            {assign var="pct_crystal" value=0}
            {if $capacity > 0}{assign var="pct_crystal" value=($bank.crystal/$capacity*100)}{/if}
            <div class="astrobank_res_card">
                <h4>Cristal</h4>
                <div class="val">{$bank.crystal|number_format:0:',,':'.'}</div>
                <div class="cap">/ {$capacity_fmt}</div>
                <div class="astrobank_bar">
                    <div class="astrobank_bar_fill{if $pct_crystal > 90} full{elseif $pct_crystal > 70} high{/if}" style="width:{$pct_crystal|number_format:0}%"></div>
                </div>
            </div>

            {* Deuterio *}
            {assign var="pct_deut" value=0}
            {if $capacity > 0}{assign var="pct_deut" value=($bank.deuterium/$capacity*100)}{/if}
            <div class="astrobank_res_card">
                <h4>Deuterio</h4>
                <div class="val">{$bank.deuterium|number_format:0:',,':'.'}</div>
                <div class="cap">/ {$capacity_fmt}</div>
                <div class="astrobank_bar">
                    <div class="astrobank_bar_fill{if $pct_deut > 90} full{elseif $pct_deut > 70} high{/if}" style="width:{$pct_deut|number_format:0}%"></div>
                </div>
            </div>

            {* MO *}
            {assign var="pct_mo" value=0}
            {if $capacity > 0}{assign var="pct_mo" value=($bank.darkmatter/$capacity*100)}{/if}
            <div class="astrobank_res_card">
                <h4>Materia Oscura</h4>
                <div class="val">{$bank.darkmatter|number_format:0:',,':'.'}</div>
                <div class="cap">/ {$capacity_fmt}</div>
                <div class="astrobank_bar">
                    <div class="astrobank_bar_fill{if $pct_mo > 90} full{elseif $pct_mo > 70} high{/if}" style="width:{$pct_mo|number_format:0}%"></div>
                </div>
            </div>

            {* 🆕 v2.0 — Moneda del jugador (NTX-20 o UNTX-20) *}
            {assign var="pct_ntx" value=0}
            {if $capacity > 0}{assign var="pct_ntx" value=($bank_visible/$capacity*100)}{/if}
            <div class="astrobank_res_card">
                <h4>{$moneda}</h4>
                <div class="val">{$bank_visible|number_format:0:',,':'.'}</div>
                <div class="cap">/ {$capacity_fmt}</div>
                <div class="astrobank_bar">
                    <div class="astrobank_bar_fill{if $pct_ntx > 90} full{elseif $pct_ntx > 70} high{/if}" style="width:{$pct_ntx|number_format:0}%"></div>
                </div>
            </div>
        </div>
    </div>

    {* ============ TABS ============ *}
    <div class="astrobank_tabs">
        <div class="astrobank_tab active" data-tab="deposit">Depositar</div>
        {if $can_withdraw}
            <div class="astrobank_tab" data-tab="withdraw">Retirar</div>
        {/if}
        {if $is_leader}
            <div class="astrobank_tab" data-tab="config">Configuracion</div>
        {/if}
        <div class="astrobank_tab" data-tab="historial">Historial</div>
    </div>

    {* ============ SECCION: DEPOSITAR ============ *}
    <div class="astrobank_section active" id="tab-deposit">
        <div class="astrobank_box">
            <div class="astrobank_title">Depositar recursos</div>
            <div class="astrobank_subtitle">Los recursos van directo al pozo de la alianza. Esta accion es irreversible.</div>

            <form method="post" action="game.php?page=allianceBank&mode=doDeposit">
                <div class="astrobank_form">
                    <select name="recurso" class="astrobank_select">
                        <option value="metal">Metal (planeta: {$current_planet.metal|number_format:0:',,':'.'})</option>
                        <option value="crystal">Cristal (planeta: {$current_planet.crystal|number_format:0:',,':'.'})</option>
                        <option value="deuterium">Deuterio (planeta: {$current_planet.deuterium|number_format:0:',,':'.'})</option>
                        <option value="darkmatter">Materia Oscura (tienes: {$user_darkmatter|number_format:0:',,':'.'})</option>
                        {* 🆕 v2.0 — Moneda dinámica del jugador *}
                        <option value="ntx20">{$moneda} (tienes: {$saldo_actual|number_format:0:',,':'.'})</option>
                    </select>
                    <input type="number" name="cantidad" class="astrobank_input" min="1" placeholder="Cantidad" required>
                    <button type="submit" class="astrobank_btn astrobank_btn_ok">Depositar</button>
                </div>
            </form>
        </div>
    </div>

    {* ============ SECCION: RETIRAR ============ *}
    {if $can_withdraw}
    <div class="astrobank_section" id="tab-withdraw">
        <div class="astrobank_box">
            <div class="astrobank_title">Retirar recursos</div>
            <div class="astrobank_subtitle">
                {if $has_daily_limit}
                    Limite diario: {$daily_limit_fmt} - Usado: {$daily_used_fmt} - Disponible: <span style="color:#66ff99;">{$daily_left_fmt}</span>
                {else}
                    Sin limite diario configurado.
                {/if}
            </div>

            <form method="post" action="game.php?page=allianceBank&mode=doWithdraw">
                <div class="astrobank_form">
                    <select name="recurso" class="astrobank_select">
                        <option value="metal">Metal (pozo: {$bank.metal|number_format:0:',,':'.'})</option>
                        <option value="crystal">Cristal (pozo: {$bank.crystal|number_format:0:',,':'.'})</option>
                        <option value="deuterium">Deuterio (pozo: {$bank.deuterium|number_format:0:',,':'.'})</option>
                        <option value="darkmatter">Materia Oscura (pozo: {$bank.darkmatter|number_format:0:',,':'.'})</option>
                        {* 🆕 v2.0 — Moneda dinámica del jugador *}
                        <option value="ntx20">{$moneda} (pozo: {$bank_visible|number_format:0:',,':'.'})</option>
                    </select>
                    <input type="number" name="cantidad" class="astrobank_input" min="1" placeholder="Cantidad" required>
                </div>
                <div class="astrobank_form" style="margin-top:8px;">
                    <select name="planet_id" class="astrobank_select" style="flex:2;">
                        {foreach from=$planets item=pl}
                            <option value="{$pl.id}" {if $pl.id == $current_planet.id}selected{/if}>
                                Destino: {$pl.name} [{$pl.galaxy}:{$pl.system}:{$pl.planet}]
                            </option>
                        {/foreach}
                    </select>
                    <button type="submit" class="astrobank_btn astrobank_btn_danger" style="flex:1;">Retirar</button>
                </div>
                <div class="astrobank_subtitle" style="margin-top:6px;">
                    Nota: MO y {$moneda} van a tu cuenta (no al planeta).
                </div>
            </form>
        </div>
    </div>
    {/if}

    {* ============ SECCION: CONFIGURACION (solo lider) ============ *}
    {if $is_leader}
    <div class="astrobank_section" id="tab-config">
        <div class="astrobank_box">
            <div class="astrobank_title">Configuracion del banco</div>

            {* Ampliar capacidad - con eleccion de fuente de pago *}
            <div class="astrobank_config_row" style="flex-direction:column; align-items:stretch;">

                <div style="display:flex; align-items:center; margin-bottom:10px;">
                    <label style="flex:0 0 120px;">Ampliar banco</label>
                    <div style="flex:1;">
                        {if $is_max_level}
                            <span style="color:#66ff99;">Nivel maximo alcanzado (25)</span>
                        {else}
                            <span>
                                Subir a Nivel <b style="color:#00e0ff;">{$bank.level+1}</b>
                                cuesta <b style="color:#ffcc44;">{$upgrade_cost_user|number_format:0:',,':'.'} {$moneda}</b>
                            </span>
                        {/if}
                    </div>
                </div>

                {if !$is_max_level}
                <div style="display:flex; gap:10px;">

                    {* 🆕 v2.0 — Boton "Pagar del Banco" con moneda dinámica *}
                    <form method="post" action="game.php?page=allianceBank&mode=upgrade" style="flex:1; margin:0;">
                        <input type="hidden" name="source" value="bank">
                        <button type="submit" class="astrobank_btn astrobank_btn_ok"
                            style="width:100%; display:flex; flex-direction:column; align-items:center; padding:10px 8px; line-height:1.3;"
                            {if $bank_visible < $upgrade_cost_user}disabled title="El banco no tiene suficiente {$moneda} en tu moneda"{/if}>
                            <span style="font-size:11px;">Pagar del Banco</span>
                            <span style="font-size:9px; opacity:0.85; text-transform:none; letter-spacing:0;">
                                Tiene: {$bank_visible|number_format:0:',,':'.'} {$moneda}
                            </span>
                        </button>
                    </form>

                    {* 🆕 v2.0 — Boton "Pagar de mi Cuenta" con moneda dinámica *}
                    <form method="post" action="game.php?page=allianceBank&mode=upgrade" style="flex:1; margin:0;">
                        <input type="hidden" name="source" value="user">
                        <button type="submit" class="astrobank_btn"
                            style="width:100%; display:flex; flex-direction:column; align-items:center; padding:10px 8px; line-height:1.3;"
                            {if $saldo_actual < $upgrade_cost_user}disabled title="No tienes suficiente {$moneda}"{/if}>
                            <span style="font-size:11px;">Pagar de mi Cuenta</span>
                            <span style="font-size:9px; opacity:0.85; text-transform:none; letter-spacing:0;">
                                Tienes: {$saldo_actual|number_format:0:',,':'.'} {$moneda}
                            </span>
                        </button>
                    </form>

                </div>

                <div class="astrobank_subtitle" style="margin-top:8px; text-align:center;">
                    Elige de donde sale el pago. El nivel sube igual, solo cambia de donde sale.
                </div>
                {/if}

            </div>

            {* Tesorero *}
            <div class="astrobank_config_row" style="flex-direction:column; align-items:stretch;">

                <div style="display:flex; align-items:center; margin-bottom:10px;">
                    <label style="flex:0 0 120px;">Tesorero</label>
                    <div style="flex:1; font-size:10px; color:#94a3b8;">
                        {if $tesorero_id > 0}
                            Asignado actualmente: <b style="color:#00e0ff;">{$members[$tesorero_id].username|default:'-'}</b>
                        {else}
                            Ningun miembro tiene permiso de retiro.
                        {/if}
                    </div>
                </div>

                <div style="display:flex; gap:8px; align-items:center;">

                    <form method="post" action="game.php?page=allianceBank&mode=setTesorero" style="display:flex;gap:8px;flex:1;margin:0;">
                        <select name="tesorero_id" class="astrobank_select" style="flex:1;">
                            <option value="0" {if $tesorero_id == 0}selected{/if}>- Sin tesorero -</option>
                            {foreach from=$members item=m}
                                <option value="{$m.id}" {if $m.id == $tesorero_id}selected{/if}>
                                    {$m.username} {if $m.ally_rank_id == 2}(Lider){/if}
                                </option>
                            {/foreach}
                        </select>
                        <button type="submit" class="astrobank_btn">Guardar</button>
                    </form>

                    {if $tesorero_id > 0}
                        <form method="post" action="game.php?page=allianceBank&mode=removeTesorero" style="margin:0;" onsubmit="return confirm('Estas seguro que quieres quitarle el permiso de tesorero a este jugador?');">
                            <button type="submit" class="astrobank_btn astrobank_btn_danger">Quitar Tesorero</button>
                        </form>
                    {/if}

                </div>

                <div class="astrobank_subtitle" style="margin-top:8px;">
                    El tesorero puede retirar recursos del banco (con el limite diario configurado). Solo puede haber 1 tesorero a la vez.
                </div>

            </div>

            {* Limite diario *}
            <div class="astrobank_config_row">
                <label>Limite diario</label>
                <form method="post" action="game.php?page=allianceBank&mode=setDailyLimit" style="display:flex;gap:8px;flex:1;margin:0;">
                    <input type="number" name="daily_limit" class="astrobank_input" min="0" value="{$daily_limit}" placeholder="0 = sin limite" style="flex:1;">
                    <button type="submit" class="astrobank_btn">Guardar</button>
                </form>
            </div>
            <div class="astrobank_subtitle">
                El limite diario es <b>global</b> (suma de todos los recursos retirados en un dia por usuario autorizado).
            </div>
        </div>
    </div>
    {/if}

    {* ============ SECCION: HISTORIAL ============ *}
    <div class="astrobank_section" id="tab-historial">
        <div class="astrobank_box">
            <div class="astrobank_title">Historial (ultimas 100 transacciones)</div>

            {if $history && $history|@count > 0}
                <table class="astrobank_table">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Jugador</th>
                            <th>Accion</th>
                            <th>Recurso</th>
                            <th>Cantidad</th>
                            <th>Balance</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$history item=h}
                            <tr>
                                <td>{$h.fecha|date_format:"%d/%m/%Y %H:%M"}</td>
                                <td>{$h.username|default:'-'}</td>
                                <td><span class="tag {$h.accion}">{$h.accion}</span></td>
                                {* 🆕 v2.0 — recurso_label dinámico (NTX-20 o UNTX-20) *}
                                <td>{$h.recurso_label|default:$h.recurso}</td>
                                <td>{$h.cantidad|number_format:0:',,':'.'}</td>
                                <td>{$h.balance_after|number_format:0:',,':'.'}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div style="color:#94a3b8;text-align:center;padding:20px;">
                    No hay movimientos todavia.
                </div>
            {/if}
        </div>
    </div>

</div>
</div>

{* ============ JAVASCRIPT TABS ============ *}
<script>
(function(){
    var tabs = document.querySelectorAll('.astrobank_tab');
    var sections = document.querySelectorAll('.astrobank_section');

    tabs.forEach(function(tab){
        tab.addEventListener('click', function(){
            var target = this.getAttribute('data-tab');

            tabs.forEach(function(t){ t.classList.remove('active'); });
            sections.forEach(function(s){ s.classList.remove('active'); });

            this.classList.add('active');
            var targetEl = document.getElementById('tab-' + target);
            if (targetEl) targetEl.classList.add('active');
        });
    });
})();
</script>

{/block}