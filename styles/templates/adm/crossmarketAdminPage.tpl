{include file="overall_header.tpl"}

<style>
/* Estilos basados en tu panel de Wallet */
.astrocrossa_wrap { max-width: 1200px; margin: 20px auto; font-family: 'Segoe UI', sans-serif; color: #cbd5e1; }
.astrocrossa_panel { background: rgba(15, 23, 42, 0.75); border: 1px solid #1e293b; border-radius: 12px; padding: 20px; margin-bottom: 20px; }
.astrocrossa_title { font-size: 18px; font-weight: 800; color: #00e0ff; text-transform: uppercase; border-bottom: 1px solid #1e293b; padding-bottom: 10px; margin-bottom: 15px; }
.astrocrossa_tabs { display: flex; gap: 10px; margin-bottom: 20px; }
.astrocrossa_tab { padding: 10px 20px; background: rgba(30, 41, 59, 0.85); border: 1px solid #1e293b; border-radius: 8px; color: #94a3b8; font-weight: bold; text-decoration: none; cursor: pointer; transition: 0.2s; }
.astrocrossa_tab:hover, .astrocrossa_tab.active { background: rgba(0, 224, 255, 0.15); border-color: #00e0ff; color: #00e0ff; }
.astrocrossa_grid { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr; gap: 15px; margin-bottom: 20px; }
.astrocrossa_card { background: rgba(0,0,0,0.3); border: 1px solid #334155; border-radius: 8px; padding: 15px; text-align: center; }
.astrocrossa_card h3 { margin: 0 0 10px 0; color: #94a3b8; font-size: 11px; text-transform: uppercase; }
.astrocrossa_stat { font-size: 22px; font-weight: 800; }
.astrocrossa_stat.gold { color: #fbbf24; }
.astrocrossa_stat.cyan { color: #00e0ff; }
.astrocrossa_stat.green { color: #4aff88; }
.astrocrossa_table { width: 100%; border-collapse: collapse; margin-top: 10px; font-size: 12px; }
.astrocrossa_table th { background: #1e293b; padding: 10px; text-align: left; color: #00e0ff; font-weight: bold; }
.astrocrossa_table td { padding: 10px; border-bottom: 1px solid #1e293b; }
.astrocrossa_btn { background: #ef4444; color: white; padding: 6px 12px; border-radius: 4px; text-decoration: none; font-size: 11px; font-weight: bold; border: none; cursor: pointer; }
.astrocrossa_btn:hover { background: #dc2626; }
.astrocrossa_btn--cyan { background: #00e0ff; color: #000; }
.astrocrossa_btn--cyan:hover { background: #00b8d4; }
.astrocrossa_input { background: rgba(0,0,0,0.5); border: 1px solid #334155; padding: 10px; border-radius: 6px; color: white; font-size: 13px; width: 100%; box-sizing: border-box; margin-bottom: 10px; }
.astrocrossa_label { font-size: 10px; color: #94a3b8; text-transform: uppercase; margin-bottom: 4px; display: block; }
</style>

<div class="astrocrossa_wrap">
    
    {if $FEEDBACK_OK}
        <div style="background: rgba(74,255,136,0.15); border: 1px solid #4aff88; color: #4aff88; padding: 10px; border-radius: 8px; margin-bottom: 20px; font-weight: bold;">
            ✅ {$FEEDBACK_OK}
        </div>
    {/if}

    <div class="astrocrossa_panel">
        <div class="astrocrossa_title">🌐 Panel de Control — Mercado Cruzado</div>
        
        <!-- Pestañas (Usamos JavaScript simple para cambiar de vista) -->
        <div class="astrocrossa_tabs">
            <div class="astrocrossa_tab active" onclick="showTab('dashboard')">📊 Dashboard</div>
            <div class="astrocrossa_tab" onclick="showTab('rebalance')">⚖️ Conciliación QvaPay</div>
            <div class="astrocrossa_tab" onclick="showTab('history')">📜 Historial y Órdenes</div>
        </div>

        <!-- ═══════════════════════════════════════════════════════════ -->
        <!-- PESTAÑA 1: DASHBOARD                                       -->
        <!-- ═══════════════════════════════════════════════════════════ -->
        <div id="tab_dashboard" style="display: block;">
            <div class="astrocrossa_grid">
                <div class="astrocrossa_card">
                    <h3>Reserva Nacional (CUP)</h3>
                    <div class="astrocrossa_stat gold">{$balance_nac} CUP</div>
                </div>
                <div class="astrocrossa_card">
                    <h3>Reserva Internacional (UNTX)</h3>
                    <div class="astrocrossa_stat cyan">{$balance_int} UNTX</div>
                </div>
                <div class="astrocrossa_card">
                    <h3>Ganancia Spread (CUP)</h3>
                    <div class="astrocrossa_stat green">{$spread_nac} CUP</div>
                </div>
                <div class="astrocrossa_card">
                    <h3>Ganancia Spread (UNTX)</h3>
                    <div class="astrocrossa_stat green">{$spread_int} UNTX</div>
                </div>
            </div>

            <div class="astrocrossa_card" style="text-align: left; padding: 20px;">
                <h3 style="color: #fbbf24;">💳 Tasa de Cambio Actual (QvaPay)</h3>
                <p style="font-size: 24px; font-weight: bold; color: #fff; margin: 10px 0;">
                    1 USD = {$tasa_qvapay} CUP
                </p>
                <p style="font-size: 12px; color: #94a3b8;">
                    Esta tasa se obtiene automáticamente de la API de QvaPay (P2P Averages) al cargar esta página.
                </p>
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════════════════ -->
        <!-- PESTAÑA 2: CONCILIACIÓN QVAPAY                             -->
        <!-- ═══════════════════════════════════════════════════════════ -->
        <div id="tab_rebalance" style="display: none;">
            <div class="astrocrossa_card" style="text-align: left; margin-bottom: 20px;">
                <h3 style="color: #00e0ff; margin-bottom: 15px;">Registrar Movimiento Manual en QvaPay</h3>
                <p style="font-size: 12px; color: #94a3b8; margin-bottom: 15px;">
                    Usa este formulario cuando hayas movido dinero real en tu cuenta de QvaPay. 
                    El sistema ajustará las reservas del juego para que coincidan con tu saldo real.
                </p>

                <form method="POST" action="admin.php?page=crossmarketadmin">
                    <input type="hidden" name="action" value="rebalance">
                    
                    <div style="display: flex; gap: 15px; margin-bottom: 15px;">
                        <div style="flex: 1;">
                            <label class="astrocrossa_label">Desde (Reserva a descontar)</label>
                            <select name="from_currency" class="astrocrossa_input">
                                <option value="UNTX20_INT">UNTX-20 (QvaPay / Internacional)</option>
                                <option value="NTX20_NAC">NTX-20 (CUP / Nacional)</option>
                            </select>
                        </div>
                        <div style="flex: 1;">
                            <label class="astrocrossa_label">Cantidad a descontar</label>
                            <input type="number" name="amount_from" placeholder="Ej: 100" class="astrocrossa_input" required>
                        </div>
                    </div>

                    <div style="display: flex; gap: 15px; margin-bottom: 15px;">
                        <div style="flex: 1;">
                            <label class="astrocrossa_label">Hacia (Reserva a sumar)</label>
                            <select name="to_currency" class="astrocrossa_input">
                                <option value="NTX20_NAC">NTX-20 (CUP / Nacional)</option>
                                <option value="UNTX20_INT">UNTX-20 (QvaPay / Internacional)</option>
                            </select>
                        </div>
                        <div style="flex: 1;">
                            <label class="astrocrossa_label">Cantidad a sumar</label>
                            <input type="number" name="amount_to" placeholder="Ej: 82000" class="astrocrossa_input" required>
                        </div>
                    </div>

                    <div style="margin-bottom: 15px;">
                        <label class="astrocrossa_label">Nota / Referencia</label>
                        <input type="text" name="note" placeholder="Ej: Cambio con operador cubano #123" class="astrocrossa_input">
                    </div>

                    <button type="submit" class="astrocrossa_btn astrocrossa_btn--cyan" style="padding: 10px 20px; font-size: 13px;">
                        💾 Registrar Movimiento y Actualizar Reservas
                    </button>
                </form>
            </div>

            <div class="astrocrossa_card" style="text-align: left; padding: 20px;">
                <h3 style="color: #fbbf24; margin-bottom: 10px;">Últimos Movimientos Manuales</h3>
                {if $rebalance_events|@count > 0}
                    <table class="astrocrossa_table">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Admin</th>
                                <th>Movimiento</th>
                                <th>Nota</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach from=$rebalance_events item=re}
                                <tr>
                                    <td>{$re.date}</td>
                                    <td>{$re.admin_name}</td>
                                    <td>
                                        <span style="color: #ef4444;">-{$re.amount_from} {$re.from_currency}</span> 
                                        <span style="color: #94a3b8;">➜</span> 
                                        <span style="color: #4aff88;">+{$re.amount_to} {$re.to_currency}</span>
                                    </td>
                                    <td style="color: #94a3b8;">{$re.note}</td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                {else}
                    <p style="color: #94a3b8; font-size: 12px;">No hay movimientos registrados aún.</p>
                {/if}
            </div>
        </div>

        <!-- ═══════════════════════════════════════════════════════════ -->
        <!-- PESTAÑA 3: HISTORIAL Y ÓRDENES                             -->
        <!-- ═══════════════════════════════════════════════════════════ -->
        <div id="tab_history" style="display: none;">
            
            <!-- Órdenes Abiertas -->
            <div class="astrocrossa_card" style="text-align: left; padding: 20px; margin-bottom: 20px;">
                <h3 style="color: #00e0ff; margin-bottom: 10px;">Órdenes Abiertas en el Mercado</h3>
                {if $open_orders|@count > 0}
                    <table class="astrocrossa_table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Fecha</th>
                                <th>Jugador</th>
                                <th>Lado</th>
                                <th>Item</th>
                                <th>Cantidad</th>
                                <th>Precio</th>
                                <th>Acción</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach from=$open_orders item=o}
                                <tr>
                                    <td>#{$o.id}</td>
                                    <td>{$o.date}</td>
                                    <td>{$o.username}</td>
                                    <td style="color: {if $o.is_sell}#fbbf24{else}#00e0ff{/if}; font-weight: bold;">
                                        {$o.side_label}
                                    </td>
                                    <td>{$o.item_name}</td>
                                    <td>{$o.amount_fmt}</td>
                                    <td>{$o.price_fmt} {if $o.is_sell}CUP{else}UNTX{/if}</td>
                                    <td>
                                        <a href="admin.php?page=crossmarketadmin&mode=cancelOrder&id={$o.id}" 
                                           class="astrocrossa_btn" 
                                           onclick="return confirm('¿Seguro que querés cancelar la orden del jugador?');">
                                           Cancelar
                                        </a>
                                    </td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                {else}
                    <p style="color: #94a3b8; font-size: 12px;">No hay órdenes abiertas en este momento.</p>
                {/if}
            </div>

            <!-- Historial de Cruces -->
            <div class="astrocrossa_card" style="text-align: left; padding: 20px;">
                <h3 style="color: #4aff88; margin-bottom: 10px;">Historial de Cruces Completados (Últimos 50)</h3>
                {if $trades|@count > 0}
                    <table class="astrocrossa_table">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Comprador</th>
                                <th>Vendedor</th>
                                <th>Item</th>
                                <th>Cantidad</th>
                                <th>Pagó</th>
                                <th>Ganancia (Spread)</th>
                            </tr>
                        </thead>
                        <tbody>
                            {foreach from=$trades item=t}
                                <tr>
                                    <td>{$t.date}</td>
                                    <td style="color:#00e0ff;">{$t.buyer_name}</td>
                                    <td style="color:#fbbf24;">{$t.seller_name}</td>
                                    <td>{$t.item_name}</td>
                                    <td>{$t.amount_fmt}</td>
                                    <td>{$t.price_fmt} {$t.currency_buyer}</td>
                                    <td style="color:#4aff88; font-weight:bold;">+{$t.spread_fmt} {$t.spread_curr}</td>
                                </tr>
                            {/foreach}
                        </tbody>
                    </table>
                {else}
                    <p style="color: #94a3b8; font-size: 12px;">Aún no se han realizado cruces.</p>
                {/if}
            </div>
        </div>

    </div>
</div>

<script>
function showTab(tabName) {
    // Ocultar todas las pestañas
    document.getElementById('tab_dashboard').style.display = 'none';
    document.getElementById('tab_rebalance').style.display = 'none';
    document.getElementById('tab_history').style.display = 'none';
    
    // Quitar la clase 'active' de todos los botones
    var tabs = document.querySelectorAll('.astrocrossa_tab');
    for (var i = 0; i < tabs.length; i++) {
        tabs[i].classList.remove('active');
    }
    
    // Mostrar la pestaña seleccionada
    document.getElementById('tab_' + tabName).style.display = 'block';
    
    // Añadir la clase 'active' al botón clicado (usando el evento actual)
    event.currentTarget.classList.add('active');
}
</script>

{include file="overall_footer.tpl"}