{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.crossmarket.default.tpl === *}
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
.astrocross_wrap {
    max-width: 1100px;
    margin: 0 auto;
    font-family: 'Segoe UI', sans-serif;
    color: #cbd5e1;
}
.astrocross_panel {
    background: rgba(15, 23, 42, 0.75);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid #1e293b;
    border-radius: 12px;
    padding: 14px;
    margin-bottom: 14px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astrocross_header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #1e293b;
    padding-bottom: 8px;
    margin-bottom: 12px;
}
.astrocross_title {
    font-size: 16px;
    font-weight: 700;
    color: #00e0ff;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astrocross_balances {
    display: flex;
    gap: 12px;
    font-size: 12px;
}
.astrocross_balance_box {
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid #1e293b;
    border-radius: 8px;
    padding: 4px 10px;
}
.astrocross_balance_nac { color: #fbbf24; font-weight: 700; }
.astrocross_balance_int { color: #00e0ff; font-weight: 700; }

.astrocross_tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 12px;
    flex-wrap: wrap;
    align-items: center;
}
.astrocross_tab {
    background: rgba(30, 41, 59, 0.85);
    border: 1px solid #1e293b;
    color: #00e0ff;
    padding: 6px 14px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.2s;
}
.astrocross_tab:hover {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
}
.astrocross_tab.active {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border-color: #00e0ff;
}

/* Botón de unificación al Mercado Nacional */
.astrocross_tab_nacional {
    margin-left: auto;
    background: rgba(251, 191, 36, 0.1);
    border-color: #fbbf24;
    color: #fbbf24;
}
.astrocross_tab_nacional:hover {
    background: linear-gradient(135deg, #92400e, #fbbf24);
    color: #fff;
    border-color: #fbbf24;
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
}

.astrocross_feedback_ok {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid #4aff88;
    color: #4aff88;
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 10px;
    font-size: 12px;
}
.astrocross_feedback_err {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid #ef4444;
    color: #ef4444;
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 10px;
    font-size: 12px;
}
.astrocross_feedback_warn {
    background: rgba(251, 191, 36, 0.15);
    border: 1px solid #fbbf24;
    color: #fbbf24;
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 10px;
    font-size: 12px;
}

.astrocross_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}
.astrocross_table th {
    background: linear-gradient(135deg, #004488, #0077cc);
    color: #fff;
    padding: 6px 8px;
    text-align: left;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astrocross_table td {
    padding: 6px 8px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
}
.astrocross_table tr:hover td {
    background: rgba(0, 224, 255, 0.05);
}
.astrocross_side_sell { color: #fbbf24; font-weight: 700; }
.astrocross_side_buy  { color: #00e0ff; font-weight: 700; }

.astrocross_btn {
    background: linear-gradient(135deg, rgba(30, 41, 59, 0.85), rgba(15, 23, 42, 0.85));
    border: 1px solid #1e293b;
    color: #00e0ff;
    padding: 5px 10px;
    border-radius: 6px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
    transition: all 0.2s;
}
.astrocross_btn:hover {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
}
.astrocross_btn_danger {
    color: #ef4444;
    border-color: #ef4444;
}
.astrocross_btn_danger:hover {
    background: linear-gradient(135deg, #991b1b, #ef4444);
    color: #fff;
    border-color: #ef4444;
    box-shadow: 0 0 12px rgba(239, 68, 68, 0.4);
}
.astrocross_btn_gold {
    color: #fbbf24;
    border-color: #fbbf24;
}
.astrocross_btn_gold:hover {
    background: linear-gradient(135deg, #92400e, #fbbf24);
    color: #fff;
    border-color: #fbbf24;
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
}

.astrocross_form_row {
    display: flex;
    gap: 10px;
    margin-bottom: 10px;
    flex-wrap: wrap;
}
.astrocross_form_group {
    flex: 1;
    min-width: 160px;
}
.astrocross_form_group label {
    display: block;
    font-size: 10px;
    text-transform: uppercase;
    color: #94a3b8;
    margin-bottom: 4px;
    letter-spacing: 0.5px;
}
.astrocross_form_group input,
.astrocross_form_group select {
    width: 100%;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid #1e293b;
    border-radius: 6px;
    padding: 6px 8px;
    color: #cbd5e1;
    font-size: 12px;
    box-sizing: border-box;
}
.astrocross_form_group input:focus,
.astrocross_form_group select:focus {
    outline: none;
    border-color: #00e0ff;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}

/* ═══════════════════════════════════════════════════════════
   FIX DEFINITIVO PARA EL SELECT (Sin padding)
   ═══════════════════════════════════════════════════════════ */
.astrocross_select {
    width: 100%;
    padding: 12px 30px 12px 14px !important;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 204, 255, 0.5);
    border-radius: 8px;
    color: #ffffff !important; 
    font-weight: 700; 
    font-size: 14px !important;
    font-family: inherit; 
    cursor: pointer; 
    outline: none;
    transition: 0.25s ease;
    
    height: auto !important;
    line-height: 1.5 !important;
    
    appearance: none; 
    -webkit-appearance: none; 
    -moz-appearance: none;
    
    background-image:
        linear-gradient(45deg, transparent 50%, #00e0ff 50%),
        linear-gradient(135deg, #00e0ff 50%, transparent 50%) !important;
    background-position: calc(100% - 16px) center, calc(100% - 11px) center !important;
    background-size: 5px 5px, 5px 5px !important;
    background-repeat: no-repeat !important;
    box-sizing: border-box;
}
.astrocross_select:hover, 
.astrocross_select:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    transform: translateY(-1px);
}
.astrocross_select option,
.astrocross_select optgroup {
    background: #0f1624 !important;
    color: #ffffff !important;
    /* ELIMINADO EL PADDING AQUI PARA QUE NO SE CORTE EL TEXTO */
}

.astrocross_hint {
    font-size: 10px;
    color: #94a3b8;
    margin-top: 4px;
}
.astrocross_warning {
    background: rgba(251, 191, 36, 0.1);
    border-left: 4px solid #fbbf24;
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 11px;
    color: #fbbf24;
    margin-bottom: 10px;
}
.astrocross_empty {
    text-align: center;
    padding: 20px;
    color: #94a3b8;
    font-size: 12px;
}
</style>

<div class="astrocross_wrap">

    {* ── FEEDBACK ── *}
    {if $feedback_ok}
        <div class="astrocross_feedback_ok">{$feedback_ok}</div>
    {/if}
    {if $feedback_error}
        <div class="{if $feedback_error_type == 'autocancelled'}astrocross_feedback_warn{else}astrocross_feedback_err{/if}">
            {$feedback_error}
        </div>
    {/if}

    {* ── CABECERA + BALANCES ── *}
    <div class="astrocross_panel">
        <div class="astrocross_header">
            <div class="astrocross_title">🌐 Mercado Cruzado (Internacional)</div>
            <div class="astrocross_balances">
                <div class="astrocross_balance_box">
                    NTX-20: <span class="astrocross_balance_nac">{$balance_nac}</span>
                </div>
                <div class="astrocross_balance_box">
                    UNTX-20: <span class="astrocross_balance_int">{$balance_int}</span>
                </div>
            </div>
        </div>

        <div class="astrocross_hint" style="margin-bottom:8px;">
            Tasa QvaPay: <strong>{$tasa_qvapay}</strong> CUP/USD · 
            Spread: <strong>{$spread_pct}%</strong> · 
            1 UNTX-20 = <strong>{$unit_usd} USD</strong>
        </div>

        {* ── PESTAÑAS ── *}
        <div class="astrocross_tabs">
            <a class="astrocross_tab {if $tab_active == 'explore'}active{/if}"
               href="{$action_url}&tab=explore">🔍 Explorar</a>
            <a class="astrocross_tab {if $tab_active == 'sell'}active{/if}"
               href="{$action_url}&tab=sell">📤 Vender</a>
            <a class="astrocross_tab {if $tab_active == 'buy'}active{/if}"
               href="{$action_url}&tab=buy">📥 Comprar</a>
            <a class="astrocross_tab {if $tab_active == 'mine'}active{/if}"
               href="{$action_url}&tab=mine">📋 Mis órdenes</a>
            <a class="astrocross_tab {if $tab_active == 'history'}active{/if}"
               href="{$action_url}&tab=history">📜 Historial</a>
            
            {* BOTÓN DE UNIFICACIÓN *}
            <a class="astrocross_tab astrocross_tab_nacional" href="game.php?page=market">
                🌍 Ir al Mercado Nacional
            </a>
        </div>
    </div>

    {* ══════════════════════════════════════════════════════ *}
    {* PESTAÑA: EXPLORAR                                    *}
    {* ══════════════════════════════════════════════════════ *}
    {if $tab_active == 'explore'}
        <div class="astrocross_panel">
            <div class="astrocross_title" style="font-size:13px; margin-bottom:10px;">🔍 Órdenes abiertas</div>

            {if $orders|@count > 0}
                <table class="astrocross_table">
                    <thead>
                        <tr>
                            <th>Lado</th>
                            <th>Jugador</th>
                            <th>Item</th>
                            <th>Cantidad</th>
                            <th>Precio</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$orders item=o}
                            <tr>
                                <td class="{if $o.side == 'sell'}astrocross_side_sell{else}astrocross_side_buy{/if}">
                                    {$o.side_label}
                                </td>
                                <td>{$o.owner_name}</td>
                                <td>{$o.item_name}</td>
                                <td>{$o.amount_fmt}</td>
                                <td>{$o.price_fmt} {if $o.side == 'sell'}CUP{else}UNTX{/if}</td>
                                <td>
                                    {if $o.is_mine}
                                        <span class="astrocross_hint">Tu orden</span>
                                    {elseif $o.side == 'sell'}
                                        <a class="astrocross_btn astrocross_btn_gold"
                                           href="{$action_url}&mode=buy&id={$o.id}"
                                           onclick="return confirm('¿Comprar esta orden?');">
                                            Comprar
                                        </a>
                                    {else}
                                        <a class="astrocross_btn"
                                           href="{$action_url}&mode=fulfill&id={$o.id}"
                                           onclick="return confirm('¿Aceptar esta orden y entregar el item?');">
                                            Aceptar
                                        </a>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div class="astrocross_empty">No hay órdenes abiertas.</div>
            {/if}
        </div>
    {/if}

    {* ══════════════════════════════════════════════════════ *}
    {* PESTAÑA: VENDER (nacional)                           *}
    {* ══════════════════════════════════════════════════════ *}
    {if $tab_active == 'sell'}
        <div class="astrocross_panel">
            <div class="astrocross_title" style="font-size:13px; margin-bottom:10px;">📤 Publicar orden de venta</div>

            <div class="astrocross_warning">
                Tus items NO se guardan en el mercado. Siguen en tu planeta y son vulnerables a ataques.
                Si te atacan y los destruyen, la orden se cancelará automáticamente cuando alguien intente comprarla.
            </div>

            <form method="post" action="{$action_url}&mode=publishSell">
                <div class="astrocross_form_row">
                    <div class="astrocross_form_group">
                        <label>¿Qué quieres vender?</label>
                        <select id="cross_sell_type" class="astrocross_select" onchange="crossUpdateHiddenFields('sell')">
                            <option value="">--- Selecciona un ítem ---</option>
                            <optgroup label="💎 Recursos">
                                <option value="metal|0">Metal</option>
                                <option value="crystal|0">Cristal</option>
                                <option value="deuterium|0">Deuterio</option>
                                <option value="dark_matter|0">Materia Oscura</option>
                            </optgroup>
                            <optgroup label="🚀 Naves">
                                <option value="ship|202">Nave pequeña de carga</option>
                                <option value="ship|203">Nave grande de carga</option>
                                <option value="ship|204">Cazador ligero</option>
                                <option value="ship|205">Cazador pesado</option>
                                <option value="ship|206">Crucero</option>
                                <option value="ship|207">Acorazado</option>
                                <option value="ship|208">Colonizador</option>
                                <option value="ship|209">Reciclador</option>
                                <option value="ship|210">Sonda de espionaje</option>
                                <option value="ship|211">Bombardero</option>
                                <option value="ship|212">Satélite solar</option>
                                <option value="ship|213">Destructor</option>
                                <option value="ship|214">Estrella de la muerte</option>
                                <option value="ship|215">Crucero de batalla</option>
                                <option value="ship|216">Luna negra</option>
                                <option value="ship|217">Transporte espacial</option>
                                <option value="ship|218">Rompeestrellas</option>
                                <option value="ship|219">Reciclador gigante</option>
                                <option value="ship|220">Nave de materia oscura</option>
                                <option value="ship|221">Estación orbital</option>
                                <option value="ship|222">Coloso de Guerra</option>
                                <option value="ship|223">Acorazado de Elite</option>
                                <option value="ship|224">Fragata Pesada</option>
                            </optgroup>
                            <optgroup label="🛡️ Defensas">
                                <option value="defense|401">Lanzamisiles</option>
                                <option value="defense|402">Láser pequeño</option>
                                <option value="defense|403">Láser grande</option>
                                <option value="defense|404">Cañón Gauss</option>
                                <option value="defense|405">Cañón iónico</option>
                                <option value="defense|406">Cañón de plasma</option>
                                <option value="defense|407">Cúpula pequeña de protección</option>
                                <option value="defense|408">Protector planetario</option>
                                <option value="defense|409">Cúpula grande de protección</option>
                                <option value="defense|410">Cañón de Gravitón</option>
                                <option value="defense|411">Plataforma de Defensa Orbital</option>
                                <option value="defense|412">Torreta de Riel</option>
                                <option value="defense|413">Cañón de Antimateria</option>
                                <option value="defense|414">Bastión Estelar</option>
                                <option value="defense|415">Escudo Deflector</option>
                            </optgroup>
                            <optgroup label="📦 Cofres">
                                <option value="box|1">Cofre Común</option>
                                <option value="box|2">Cofre Raro</option>
                                <option value="box|3">Cofre Legendario</option>
                                <option value="box_climate|1">Cofre Climático Menor</option>
                                <option value="box_climate|2">Cofre Climático Mayor</option>
                                <option value="box_climate|3">Cofre Climático Dominio</option>
                                <option value="container|0">Cofre Genérico</option>
                            </optgroup>
                        </select>
                        <input type="hidden" name="item_type" id="cross_sell_item_type" value="">
                        <input type="hidden" name="item_id" id="cross_sell_item_id" value="">
                    </div>
                    <div class="astrocross_form_group">
                        <label>Cantidad</label>
                        <input type="number" name="item_amount" min="1" value="1" required>
                    </div>
                    <div class="astrocross_form_group">
                        <label>Precio total (CUP)</label>
                        <input type="number" name="amount_cup" min="1" value="100" required>
                    </div>
                </div>

                <div class="astrocross_hint" style="margin-bottom:10px;">
                    Disponible: Metal {$metal|number_format:0:",":"."} · 
                    Cristal {$crystal|number_format:0:",":"."} · 
                    Deuterio {$deuterium|number_format:0:",":"."} · 
                    Cofres genéricos {$containers}
                </div>

                <button type="submit" class="astrocross_btn astrocross_btn_gold">
                    Publicar venta
                </button>
            </form>
        </div>
    {/if}

    {* ══════════════════════════════════════════════════════ *}
    {* PESTAÑA: COMPRAR (internacional)                     *}
    {* ══════════════════════════════════════════════════════ *}
    {if $tab_active == 'buy'}
        <div class="astrocross_panel">
            <div class="astrocross_title" style="font-size:13px; margin-bottom:10px;">📥 Publicar orden de compra</div>

            <div class="astrocross_warning">
                Tu UNTX-20 NO se guarda en el mercado. Sigue en tu cuenta.
                Si lo gastas antes de que alguien acepte, la orden se cancelará automáticamente.
            </div>

            <form method="post" action="{$action_url}&mode=publishBuy">
                <div class="astrocross_form_row">
                    <div class="astrocross_form_group">
                        <label>¿Qué quieres comprar?</label>
                        <select id="cross_buy_type" class="astrocross_select" onchange="crossUpdateHiddenFields('buy')">
                            <option value="">--- Selecciona un ítem ---</option>
                            <optgroup label="💎 Recursos">
                                <option value="metal|0">Metal</option>
                                <option value="crystal|0">Cristal</option>
                                <option value="deuterium|0">Deuterio</option>
                                <option value="dark_matter|0">Materia Oscura</option>
                            </optgroup>
                            <optgroup label="🚀 Naves">
                                <option value="ship|202">Nave pequeña de carga</option>
                                <option value="ship|203">Nave grande de carga</option>
                                <option value="ship|204">Cazador ligero</option>
                                <option value="ship|205">Cazador pesado</option>
                                <option value="ship|206">Crucero</option>
                                <option value="ship|207">Acorazado</option>
                                <option value="ship|208">Colonizador</option>
                                <option value="ship|209">Reciclador</option>
                                <option value="ship|210">Sonda de espionaje</option>
                                <option value="ship|211">Bombardero</option>
                                <option value="ship|212">Satélite solar</option>
                                <option value="ship|213">Destructor</option>
                                <option value="ship|214">Estrella de la muerte</option>
                                <option value="ship|215">Crucero de batalla</option>
                                <option value="ship|216">Luna negra</option>
                                <option value="ship|217">Transporte espacial</option>
                                <option value="ship|218">Rompeestrellas</option>
                                <option value="ship|219">Reciclador gigante</option>
                                <option value="ship|220">Nave de materia oscura</option>
                                <option value="ship|221">Estación orbital</option>
                                <option value="ship|222">Coloso de Guerra</option>
                                <option value="ship|223">Acorazado de Elite</option>
                                <option value="ship|224">Fragata Pesada</option>
                            </optgroup>
                            <optgroup label="🛡️ Defensas">
                                <option value="defense|401">Lanzamisiles</option>
                                <option value="defense|402">Láser pequeño</option>
                                <option value="defense|403">Láser grande</option>
                                <option value="defense|404">Cañón Gauss</option>
                                <option value="defense|405">Cañón iónico</option>
                                <option value="defense|406">Cañón de plasma</option>
                                <option value="defense|407">Cúpula pequeña de protección</option>
                                <option value="defense|408">Protector planetario</option>
                                <option value="defense|409">Cúpula grande de protección</option>
                                <option value="defense|410">Cañón de Gravitón</option>
                                <option value="defense|411">Plataforma de Defensa Orbital</option>
                                <option value="defense|412">Torreta de Riel</option>
                                <option value="defense|413">Cañón de Antimateria</option>
                                <option value="defense|414">Bastión Estelar</option>
                                <option value="defense|415">Escudo Deflector</option>
                            </optgroup>
                            <optgroup label="📦 Cofres">
                                <option value="box|1">Cofre Común</option>
                                <option value="box|2">Cofre Raro</option>
                                <option value="box|3">Cofre Legendario</option>
                                <option value="box_climate|1">Cofre Climático Menor</option>
                                <option value="box_climate|2">Cofre Climático Mayor</option>
                                <option value="box_climate|3">Cofre Climático Dominio</option>
                                <option value="container|0">Cofre Genérico</option>
                            </optgroup>
                        </select>
                        <input type="hidden" name="item_type" id="cross_buy_item_type" value="">
                        <input type="hidden" name="item_id" id="cross_buy_item_id" value="">
                    </div>
                    <div class="astrocross_form_group">
                        <label>Cantidad</label>
                        <input type="number" name="item_amount" min="1" value="1" required>
                    </div>
                    <div class="astrocross_form_group">
                        <label>Precio total (UNTX)</label>
                        <input type="number" name="untx_amount" min="1" value="10" required>
                    </div>
                </div>

                <div class="astrocross_hint" style="margin-bottom:10px;">
                    UNTX disponible: <strong>{$balance_int}</strong>
                </div>

                <button type="submit" class="astrocross_btn">
                    Publicar compra
                </button>
            </form>
        </div>
    {/if}

    {* ══════════════════════════════════════════════════════ *}
    {* PESTAÑA: MIS ÓRDENES                                 *}
    {* ══════════════════════════════════════════════════════ *}
    {if $tab_active == 'mine'}
        <div class="astrocross_panel">
            <div class="astrocross_title" style="font-size:13px; margin-bottom:10px;">📋 Mis órdenes</div>

            {if $my_orders|@count > 0}
                <table class="astrocross_table">
                    <thead>
                        <tr>
                            <th>Lado</th>
                            <th>Item</th>
                            <th>Cantidad</th>
                            <th>Precio</th>
                            <th>Estado</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$my_orders item=o}
                            <tr>
                                <td class="{if $o.is_sell}astrocross_side_sell{else}astrocross_side_buy{/if}">
                                    {$o.side_label}
                                </td>
                                <td>{$o.item_name}</td>
                                <td>{$o.amount_fmt}</td>
                                <td>{$o.price_fmt} {if $o.is_sell}CUP{else}UNTX{/if}</td>
                                <td>{$o.status_label}</td>
                                <td>
                                    {if $o.status == 'open'}
                                        <a class="astrocross_btn astrocross_btn_danger"
                                           href="{$action_url}&mode=cancel&id={$o.id}"
                                           onclick="return confirm('¿Cancelar esta orden?');">
                                            Cancelar
                                        </a>
                                    {else}
                                        <span class="astrocross_hint">—</span>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div class="astrocross_empty">No tienes órdenes.</div>
            {/if}
        </div>
    {/if}

    {* ══════════════════════════════════════════════════════ *}
    {* PESTAÑA: HISTORIAL                                   *}
    {* ══════════════════════════════════════════════════════ *}
    {if $tab_active == 'history'}
        <div class="astrocross_panel">
            <div class="astrocross_title" style="font-size:13px; margin-bottom:10px;">📜 Historial de cruces</div>

            {if $trades|@count > 0}
                <table class="astrocross_table">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Rol</th>
                            <th>Item</th>
                            <th>Cantidad</th>
                            <th>Moneda</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach from=$trades item=t}
                            <tr>
                                <td>{$t.date}</td>
                                <td>{$t.role_label}</td>
                                <td>{$t.item_name}</td>
                                <td>{$t.amount_fmt}</td>
                                <td>
                                    {if $t.is_buyer}
                                        {$t.amount_buyer} {$t.currency_buyer}
                                    {else}
                                        {$t.amount_seller} {$t.currency_seller}
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div class="astrocross_empty">No hay cruces todavía.</div>
            {/if}
        </div>
    {/if}

</div>

{literal}
<script>
function crossUpdateHiddenFields(mode) {
    var prefix = (mode === 'sell') ? 'cross_sell' : 'cross_buy';
    var sel = document.getElementById(prefix + '_type');
    var typeInput = document.getElementById(prefix + '_item_type');
    var idInput = document.getElementById(prefix + '_item_id');

    if (sel && typeInput && idInput) {
        var val = sel.value;
        if (val) {
            var parts = val.split('|');
            typeInput.value = parts[0];
            idInput.value = parts[1];
        } else {
            typeInput.value = '';
            idInput.value = '0';
        }
    }
}

document.addEventListener('DOMContentLoaded', function() {
    crossUpdateHiddenFields('sell');
    crossUpdateHiddenFields('buy');
});
</script>
{/literal}

{/block}