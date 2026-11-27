{block name="title" prepend}Wallet{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.default.tpl === *}
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
/* ═══════════════════════════════════════════════════════════
   DISEÑO WEB3 (Estilo Kriptomat / Ronin) - COMPACTO
   Prefijo: .rn-wallet
   ═══════════════════════════════════════════════════════════ */

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
    --rn-bg:          rgba(15, 23, 42, 0.65);
    --rn-card:        rgba(15, 23, 42, 0.85);
    --rn-card-hover:  rgba(30, 41, 59, 0.9);
    --rn-border:      rgba(255, 255, 255, 0.08);
    --rn-text-main:   #ffffff;
    --rn-text-muted:  #8b8c98;
    --rn-blue:        #2b6bf3;
    --rn-cyan:        #00e0ff;
    --rn-green:       #4aff88;
    --rn-red:         #ef4444;
    --rn-purple:      #8b5cf6;
    --rn-gold:        #fbbf24;
}

/* Panel principal */
.rn-wallet-wrapper {
    background: var(--rn-bg);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    color: var(--rn-text-main);
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    padding: 10px 14px;
    border-radius: 12px;
    max-width: 98%;
    width: 100%;
    margin: 10px auto 0 auto;
    box-sizing: border-box;
    display: grid;
    grid-template-columns: 220px 1fr;
    gap: 12px;
    border: 1px solid var(--rn-border);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
}

/* ─── SIDEBAR ─── */
.rn-sidebar {
    display: flex;
    flex-direction: column;
    gap: 8px;
    height: fit-content;
}

.rn-profile-card {
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 10px;
    padding: 10px;
    text-align: center;
}

.rn-avatar {
    width: 40px;
    height: 40px;
    background: linear-gradient(135deg, #1e293b, #0f172a);
    border-radius: 50%;
    margin: 0 auto 6px auto;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 700;
    color: var(--rn-text-muted);
    border: 2px solid var(--rn-border);
}

.rn-username { font-size: 13px; font-weight: 700; margin-bottom: 2px; }
.rn-user-tag { font-size: 9px; color: var(--rn-text-muted); margin-bottom: 8px; }

.rn-tabs { display: flex; gap: 12px; justify-content: center; border-top: 1px solid var(--rn-border); padding-top: 6px; margin-top: 6px; }
.rn-tab { color: var(--rn-text-muted); font-size: 10px; font-weight: 600; cursor: pointer; transition: 0.2s; text-decoration: none; }
.rn-tab:hover, .rn-tab.active { color: var(--rn-text-main); }

.rn-balance-card {
    background: linear-gradient(135deg, #2b6bf3 0%, #1a4bb5 100%);
    border-radius: 10px;
    padding: 10px;
    color: #fff;
    box-shadow: 0 4px 10px rgba(43, 107, 243, 0.3);
}

.rn-balance-label { font-size: 9px; font-weight: 500; opacity: 0.8; margin-bottom: 2px; }
.rn-balance-value { font-size: 16px; font-weight: 700; font-family: 'Inter', monospace; margin-bottom: 8px; letter-spacing: -0.5px; }

/* Separadores de Sistema */
.rn-system-title {
    font-size: 9px;
    color: var(--rn-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-top: 8px;
    margin-bottom: 4px;
    font-weight: 700;
    text-align: left;
}
.rn-system-divider {
    height: 1px;
    background: rgba(255, 255, 255, 0.1);
    margin: 8px 0;
}

.rn-btn-group { display: flex; gap: 4px; flex-wrap: wrap; }
.rn-btn-circle {
    flex: 1 1 45%; background: rgba(255, 255, 255, 0.15); border: none; border-radius: 6px;
    padding: 4px 0; color: #fff; font-size: 9.5px; font-weight: 600; cursor: pointer;
    transition: 0.2s; text-decoration: none; display: inline-block; text-align: center;
}
.rn-btn-circle:hover { background: rgba(255, 255, 255, 0.25); color: #fff;}

/* BOTÓN QVAPAY NUEVO (Estilo integrado) */
.rn-btn-qvapay {
    flex: 1 1 45%;
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid rgba(74, 255, 136, 0.4);
    border-radius: 6px;
    padding: 6px 0;
    color: var(--rn-green);
    font-size: 9.5px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.2s;
    display: inline-block;
    text-align: center;
    text-decoration: none;
}
.rn-btn-qvapay:hover {
    background: rgba(74, 255, 136, 0.25);
    border-color: var(--rn-green);
    box-shadow: 0 0 10px rgba(74, 255, 136, 0.3);
}

/* ─── MAIN CONTENT (Columna Derecha) ─── */
.rn-main { display: flex; flex-direction: column; gap: 8px; min-width: 0; width: 100%; }

.rn-header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px; }
.rn-header h1 { font-size: 14px; font-weight: 700; margin: 0; }
.rn-header-actions { display: flex; gap: 6px; }

.rn-btn-outline {
    background: transparent; color: #fff; border: 1px solid var(--rn-border);
    padding: 4px 10px; border-radius: 20px; font-size: 10px; font-weight: 600; cursor: pointer; transition: 0.2s; text-decoration: none;
}
.rn-btn-outline:hover { background: var(--rn-card-hover); border-color: var(--rn-text-muted); color: #fff; }

/* ─── TARJETAS DE ESTADÍSTICAS ─── */
.rn-stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 6px; margin-bottom: 8px; }
.rn-stat-card { background: var(--rn-card); border: 1px solid var(--rn-border); border-radius: 8px; padding: 8px; text-align: left; }
.rn-stat-label { font-size: 8.5px; color: var(--rn-text-muted); margin-bottom: 2px; font-weight: 500; }
.rn-stat-value { font-size: 14px; font-weight: 700; color: var(--rn-text-main); }

.rn-stat-value.cyan   { color: var(--rn-cyan); }
.rn-stat-value.green  { color: var(--rn-green); }
.rn-stat-value.red    { color: var(--rn-red); }
.rn-stat-value.purple { color: var(--rn-purple); }
.rn-stat-value.gold   { color: var(--rn-gold); }

/* ─── GRÁFICO ─── */
.rn-chart-box { background: var(--rn-card); border: 1px solid var(--rn-border); border-radius: 10px; padding: 8px 10px; margin-bottom: 8px; }
.rn-chart-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 8px; flex-wrap: wrap; margin-bottom: 6px; }
.rn-chart-price { font-size: 16px; font-weight: 700; color: #fff; }
.rn-chart-price small { font-size: 9px; color: var(--rn-text-muted); font-weight: 500; margin-left: 4px; }
.rn-chart-times { display: flex; gap: 2px; background: rgba(0,0,0,0.3); padding: 2px; border-radius: 20px; border: 1px solid var(--rn-border); }
.rn-time-btn { background: transparent; border: none; color: var(--rn-text-muted); font-size: 8.5px; font-weight: 600; padding: 2px 6px; border-radius: 12px; cursor: pointer; transition: 0.2s; }
.rn-time-btn:hover { color: #fff; }
.rn-time-btn.active { background: var(--rn-purple); color: #fff; }
#walletPoolChart { min-height: 180px; width: 100%; display: block; }

/* ─── TABLAS QUE OCUPAN TODO EL ANCHO ─── */
.rn-panel-full {
    grid-column: 1 / -1; 
    background: var(--rn-card); 
    border: 1px solid var(--rn-border); 
    border-radius: 10px; 
    padding: 10px 12px; 
    margin-top: 4px;
}

.rn-panel-title { font-size: 11px; font-weight: 600; margin: 0 0 8px 0; display: flex; justify-content: space-between; align-items: center; }

.rn-table { width: 100%; border-collapse: collapse; }
.rn-table th { text-align: left; color: var(--rn-text-muted); font-size: 9px; font-weight: 500; padding-bottom: 4px; border-bottom: 1px solid var(--rn-border); }
.rn-table td { padding: 6px 0; border-bottom: 1px solid var(--rn-border); font-size: 10px; }
.rn-table tr:last-child td { border-bottom: none; }

.rn-alert { padding: 6px 8px; border-radius: 6px; font-size: 9.5px; line-height: 1.4; margin-bottom: 6px; border: 1px solid transparent; }
.rn-alert.ok    { background: rgba(74, 255, 136, 0.1); border-color: rgba(74, 255, 136, 0.3); color: var(--rn-green); }
.rn-alert.err   { background: rgba(239, 68, 68, 0.1);  border-color: rgba(239, 68, 68, 0.3); color: var(--rn-red); }
.rn-alert.info  { background: rgba(0, 224, 255, 0.1);  border-color: rgba(0, 224, 255, 0.3); color: var(--rn-cyan); }
.rn-alert.warn  { background: rgba(251, 191, 36, 0.1); border-color: rgba(251, 191, 36, 0.3); color: var(--rn-gold); }
.rn-alert.purp  { background: rgba(139, 92, 246, 0.1); border-color: rgba(139, 92, 246, 0.3); color: var(--rn-purple); }

.rn-badge { display: inline-block; padding: 1px 5px; border-radius: 20px; font-size: 8px; font-weight: 600; }
.rn-badge.pendiente { background: rgba(251, 191, 36, 0.2); color: var(--rn-gold); }
.rn-badge.info      { background: rgba(0, 224, 255, 0.2);  color: var(--rn-cyan); }
.rn-badge.ok        { background: rgba(74, 255, 136, 0.2); color: var(--rn-green); }
.rn-badge.error     { background: rgba(239, 68, 68, 0.2);  color: var(--rn-red); }
.rn-badge.gray      { background: rgba(139, 140, 152, 0.2);color: var(--rn-text-muted); }

.rn-btn { display: inline-block; padding: 4px 8px; border-radius: 20px; font-size: 9.5px; font-weight: 600; cursor: pointer; text-decoration: none; border: none; transition: 0.2s; text-align: center; }
.rn-btn.sm { padding: 2px 6px; font-size: 8.5px; }
.rn-btn.disabled { opacity: 0.5; cursor: not-allowed; pointer-events: none; }
.rn-btn.gray { background: var(--rn-border); color: #fff; }
.rn-btn.red  { background: rgba(239, 68, 68, 0.15); color: var(--rn-red); border: 1px solid var(--rn-red); }
.rn-btn.red:hover { background: var(--rn-red); color: #fff; }

.rn-btn-upload { display: inline-block; background: var(--rn-green); color: #000; padding: 4px 8px; border-radius: 20px; font-size: 9.5px; font-weight: 700; cursor: pointer; text-decoration: none; transition: 0.2s; box-shadow: 0 0 8px rgba(74, 255, 136, 0.3); }
.rn-btn-upload:hover { box-shadow: 0 0 15px rgba(74, 255, 136, 0.6); color: #000; }

.rn-sol-list { display: flex; flex-direction: column; gap: 4px; }
.rn-sol { background: rgba(0,0,0,0.2); border: 1px solid var(--rn-border); border-radius: 8px; padding: 6px 8px; display: flex; justify-content: space-between; align-items: center; gap: 8px; flex-wrap: wrap; }
.rn-sol.datos_enviados { border-color: rgba(74, 255, 136, 0.4); background: rgba(74, 255, 136, 0.05); }
.rn-sol-left { flex: 1; min-width: 140px; }
.rn-sol-id { font-family: monospace; font-size: 8.5px; color: var(--rn-text-muted); }
.rn-sol-amount { font-size: 11px; font-weight: 700; color: var(--rn-cyan); margin: 1px 0; }
.rn-sol-meta { font-size: 8.5px; color: var(--rn-text-muted); }
.rn-sol-right { display: flex; flex-direction: column; align-items: flex-end; gap: 4px; }

@media (max-width: 900px) { .rn-wallet-wrapper { grid-template-columns: 1fr; } }
@media (max-width: 480px) {
    .rn-header { flex-direction: column; align-items: flex-start; }
    .rn-btn-group { flex-direction: column; }
    .rn-btn-circle, .rn-btn-qvapay { width: 100%; flex: 1 1 100%; }
    .rn-sol { flex-direction: column; align-items: stretch; }
    .rn-sol-right { align-items: stretch; }
    .rn-chart-times { width: 100%; justify-content: center; }
    .rn-time-btn { flex: 1; }
}
</style>

<div class="rn-wallet-wrapper">
    <!-- SIDEBAR (Columna Izquierda) -->
    <div class="rn-sidebar">
        <div class="rn-profile-card">
            <div class="rn-avatar">{$username|substr:0:1|upper}</div>
            <div class="rn-username">{$username}</div>
            <div class="rn-user-tag">Usuario Verificado</div>
            <!-- Botón Historial -->
            <div class="rn-tabs">
                <a href="game.php?page=wallet&mode=history" class="rn-tab active">Historial</a>
            </div>
        </div>
        
        <div class="rn-balance-card">
            <div class="rn-balance-label">Balance NXT-20 Total</div>
            <div class="rn-balance-value">{$nxt20_total} 💲</div>
            
            {* ═══════════════════════════════════════════════════════ *}
            {* LÓGICA DE MÉTODOS DE RETIRO Y CONFIG GLOBAL           *}
            {* ═══════════════════════════════════════════════════════ *}
            
            {if $metodo_retiro == 'CUP'}
                <!-- SISTEMA NACIONAL (CUP) COMPLETO -->
                <div class="rn-system-title">🇨🇺 Sistema Nacional (CUP)</div>
                <div class="rn-btn-group">
                    <a href="game.php?page=wallet&mode=deposit" class="rn-btn-circle">Invertir</a>
                    <a href="game.php?page=wallet&mode=withdraw" class="rn-btn-circle">Retirar</a>
                </div>
                {* 🆕 REGLA: Si es CUP, NO SE MUESTRA NADA DE QVAPAY (ni compra ni retiro) *}
                
            {elseif $metodo_retiro == 'QVAPAY'}
                {if $qvapay_compra_activa || $qvapay_retiro_activa}
                    <!-- SISTEMA INTERNACIONAL (QVAPAY) COMPLETO -->
                    <div class="rn-system-title">🌐 Internacional (QvaPay)</div>
                    <div class="rn-btn-group">
                        {if $qvapay_compra_activa}
                        <a href="game.php?page=wallet&mode=deposit_qvapay" class="rn-btn-qvapay">
                            💎 Comprar
                        </a>
                        {/if}
                        {if $qvapay_retiro_activa}
                        <a href="game.php?page=wallet&mode=withdraw_qvapay" class="rn-btn-qvapay">
                            💸 Retirar
                        </a>
                        {/if}
                    </div>
                {else}
                    <div class="rn-alert err" style="margin-top: 10px; text-align: center;">
                        ⚠️ El sistema QvaPay está temporalmente deshabilitado por el administrador.
                    </div>
                {/if}
            {/if}
            
        </div>
    </div>

    <!-- MAIN CONTENT (Columna Derecha) -->
    <div class="rn-main">
        <div class="rn-header">
            <h1>Portfolio</h1>
            <div class="rn-header-actions">
                {if $metodo_retiro == 'CUP'}
                    <a href="game.php?page=wallet&mode=setbankdata" class="rn-btn-outline">💳 Datos Bancarios</a>
                {/if}
            </div>
        </div>

        {if $feedback_ok == 'inversion_creada' || $feedback_ok == 'inversion_pendiente'}
            <div class="rn-alert ok">✅ Solicitud de inversión creada. Un admin la revisará pronto.</div>
        {elseif $feedback_ok == 'retiro_solicitado'}
            <div class="rn-alert ok">✅ Retiro solicitado. Los NXT-20 quedaron BLOQUEADOS hasta que el admin lo procese.</div>
        {elseif $feedback_ok == 'retiro_cancelado'}
            <div class="rn-alert ok">✅ Retiro cancelado. Se te devolvieron los NXT-20.</div>
        {elseif $feedback_ok == 'solicitud_cancelada'}
            <div class="rn-alert ok">✅ Solicitud cancelada correctamente.</div>
        {elseif $feedback_ok == 'datos_guardados'}
            <div class="rn-alert ok">✅ Datos bancarios guardados correctamente.</div>
        {elseif $feedback_ok == 'cambio_solicitado'}
            <div class="rn-alert ok">✅ Solicitud de cambio de datos enviada. El admin la revisará.</div>
        {/if}

        {if $feedback_error != ''}
            <div class="rn-alert err">❌ {$feedback_error|escape:'html'}</div>
        {/if}

        <!-- Tarjetas: Kyber, Total Retirado y Mínimo de Retiro -->
        <div class="rn-stats-grid">
            <div class="rn-stat-card">
                <div class="rn-stat-label">💎 Kyber en el Banco</div>
                <div class="rn-stat-value cyan">{$kyber_banco} 💎</div>
            </div>
            <div class="rn-stat-card">
                <div class="rn-stat-label">💲 Total Retirado</div>
                <div class="rn-stat-value red">{$total_retirado} 💲</div>
            </div>
            <div class="rn-stat-card">
                <div class="rn-stat-label">📉 Mínimo de Retiro</div>
                <div class="rn-stat-value gold">{$min_retiro_nxt20} 💲</div>
            </div>
        </div>

        {if $retiro_pendiente}
            <div class="rn-panel" style="border-color: rgba(251, 191, 36, 0.4);">
                <div class="rn-panel-title" style="color: var(--rn-gold);">
                    <span>⏳ Retiro pendiente #{if $retiro_pendiente.id}{$retiro_pendiente.id}{/if}</span>
                    {if $retiro_pendiente.estado == 'pendiente'}
                        <span class="rn-badge pendiente">Esperando admin</span>
                    {elseif $retiro_pendiente.estado == 'aceptada'}
                        <span class="rn-badge info">Aceptado</span>
                    {/if}
                </div>
                <div style="font-size: 10px; line-height: 1.4;">
                    🔒 NXT-20 bloqueados: <strong>{$retiro_pendiente.nxt20}</strong><br>
                    💰 Neto a recibir: <strong>{$retiro_pendiente.neto} CUP</strong><br>
                    📅 Solicitado: <strong>{$retiro_pendiente.fecha}</strong>
                </div>
                {if $retiro_pendiente.cancelable}
                    <div style="margin-top: 6px; text-align: right;">
                        <form method="POST" action="game.php?page=wallet&mode=cancelarRetiro" style="display: inline;">
                            <input type="hidden" name="id" value="{$retiro_pendiente.id}">
                            <button type="submit" class="rn-btn red sm" onclick="return confirm('¿Cancelar el retiro? Se te devolverán los NXT-20.');">
                                🔴 Cancelar retiro
                            </button>
                        </form>
                    </div>
                {/if}
            </div>
        {/if}

        <div class="rn-chart-box">
            <div class="rn-chart-header">
                <div>
                    <div style="font-size: 9px; color: var(--rn-text-muted); font-weight: 500; margin-bottom: 2px;">💎 Kyber en el Banco</div>
                    <div class="rn-chart-price">
                        <span id="walletChartPrice">{$kyber_banco}</span><small>💎 Kyber</small>
                    </div>
                </div>
                <div class="rn-chart-times" id="walletChartTimes">
                    <button type="button" class="rn-time-btn" data-horas="24">24h</button>
                    <button type="button" class="rn-time-btn active" data-horas="360">15d</button>
                    <button type="button" class="rn-time-btn" data-horas="720">1m</button>
                    <button type="button" class="rn-time-btn" data-horas="0">ALL</button>
                </div>
            </div>
            <div id="chart-error-msg" style="display:none; color: #ef4444; font-size: 10px; text-align: center; padding: 16px;"></div>
            <div id="walletPoolChart"></div>
            <div style="font-size: 8.5px; color: var(--rn-text-muted); text-align: right; margin-top: 4px;">
                ⏱️ Snapshot cada 1 hora · 🟣 Kyber banco
            </div>
        </div>
    </div> <!-- Fin del .rn-main -->
	    <!-- TABLAS FULL WIDTH (Ocupan todo el ancho) -->
    <div class="rn-panel-full">
        <div class="rn-panel-title">
            <span>📋 Mis Solicitudes Activas</span>
            <span style="font-size: 9px; color: var(--rn-text-muted); font-weight: 400;">{$solicitudes_count} / {$max_solicitudes}</span>
        </div>

        {if $solicitudes_count >= $max_solicitudes}
            <div class="rn-alert warn">
                ⚠️ Tenés el máximo de <strong>{$max_solicitudes} solicitudes activas</strong>. Cancelá una para poder crear otra.
            </div>
        {/if}

        {if $solicitudes|@count > 0}
            <div class="rn-sol-list">
                {foreach $solicitudes as $s}
                    <div class="rn-sol {if $s.estado == 'datos_enviados'}datos_enviados{/if}">
                        <div class="rn-sol-left">
                            <div class="rn-sol-id">SOLICITUD #{$s.id}</div>
                            <div class="rn-sol-amount">
                                {$s.cantidad_kyber} <small>💎 Kyber</small>
                            </div>
                            <div class="rn-sol-meta">
                                📅 {$s.fecha}
                                {if $s.referidor_id > 0}
                                    · 🔗 Ref: {$s.nxt20_referidor} 💲 NXT-20
                                {/if}
                            </div>
                        </div>
                        <div class="rn-sol-right">
                            <span class="rn-badge {$s.estado_clase}">
                                {$s.estado_label}
                            </span>
                            <div style="display:flex; gap:4px; flex-wrap:wrap; justify-content:flex-end;">
                                {if $s.estado == 'datos_enviados'}
                                    <a class="rn-btn-upload" href="game.php?page=wallet&mode=verSolicitud&id={$s.id}">
                                        📤 SUBIR COMPROBANTE
                                    </a>
                                {/if}
                                {if $s.estado == 'pendiente_sin_asignar' || $s.estado == 'pendiente_asignada' || $s.estado == 'datos_enviados'}
                                    <a class="rn-btn gray sm" href="game.php?page=wallet&mode=verSolicitud&id={$s.id}#modal_cancelar">
                                        🔴 Cancelar
                                    </a>
                                {/if}
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        {else}
            <div style="text-align:center; padding: 8px; color: var(--rn-text-muted); font-size: 10px;">
                No tenés solicitudes activas. ¡Podés crear una nueva! 🎉
            </div>
        {/if}
    </div>

    <div class="rn-panel-full">
        <div class="rn-panel-title">📜 Movimientos recientes</div>

        {if $movimientos|@count > 0}
            <table class="rn-table">
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Tipo</th>
                        <th>Moneda</th>
                        <th>Cantidad</th>
                        <th>Detalle</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $movimientos as $mov}
                        <tr>
                            <td style="color: var(--rn-text-muted); font-size: 9px;">{$mov.fecha}</td>
                            <td>
                                {if $mov.tipo == 'inversion'}
                                    <span class="rn-badge ok">Inversión</span>
                                {elseif $mov.tipo == 'retiro'}
                                    <span class="rn-badge error">Retiro</span>
                                {elseif $mov.tipo == 'referido_inv'}
                                    <span class="rn-badge info">Ref. Inversión</span>
                                {elseif $mov.tipo == 'referido_ret'}
                                    <span class="rn-badge info">Ref. Retiro</span>
                                {elseif $mov.tipo == 'fondo_proyecto'}
                                    <span class="rn-badge info">Fondo Proyecto</span>
                                {elseif $mov.tipo == 'ajuste'}
                                    <span class="rn-badge gray">Ajuste</span>
                                {else}
                                    <span class="rn-badge">{$mov.tipo}</span>
                                {/if}
                            </td>
                            <td style="font-size: 9px;">
                                {if $mov.moneda == 'KYBER'}💎 KYBER
                                {elseif $mov.moneda == 'NXT20'}💲 NXT-20
                                {else}{$mov.moneda}{/if}
                            </td>
                            <td style="font-family: monospace; font-weight: 600; font-size: 9px;">{$mov.cantidad}</td>
                            <td style="color: var(--rn-text-muted); font-size: 9px;">{$mov.detalle|escape:'html'}</td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {else}
            <div style="text-align:center; padding: 8px; color: var(--rn-text-muted); font-size: 10px;">
                No hay movimientos todavía.
            </div>
        {/if}
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/apexcharts@3.45.0/dist/apexcharts.min.js"></script>

<script>
window.addEventListener('load', function() {
    var chartEl = document.querySelector('#walletPoolChart');
    var priceEl = document.querySelector('#walletChartPrice');
    var timeWrap = document.querySelector('#walletChartTimes');
    var errorMsg = document.querySelector('#chart-error-msg');

    if (typeof ApexCharts === 'undefined') {
        if (errorMsg) {
            errorMsg.style.display = 'block';
            errorMsg.innerHTML = '⚠️ Error: No se pudo cargar la librería ApexCharts.';
        }
        return;
    }

    if (!chartEl) return;

    chartEl.style.height = '180px';
    chartEl.style.minHeight = '180px';
    chartEl.style.width = '100%';

    var chart = null;
    var currentHoras = 360; 

    function buildAnnotation(lastValue) {
        if (!lastValue) return {};
        return {
            yaxis: [{
                y: lastValue,
                borderColor: 'rgba(139, 92, 246, 0.6)',
                strokeDashArray: 4,
                label: {
                    text: Number(lastValue).toLocaleString('es-AR'),
                    position: 'left',
                    style: {
                        background: '#8b5cf6',
                        color: '#ffffff',
                        fontSize: '9px',
                        fontWeight: 'bold',
                        padding: { left: 4, right: 4, top: 2, bottom: 2 }
                    }
                }
            }]
        };
    }

    function buildOptions(categorias, kyberBanco) {
        var ultimo = kyberBanco.length > 0 ? kyberBanco[kyberBanco.length - 1] : null;

        return {
            chart: {
                type: 'line',
                height: 180,
                background: 'transparent',
                toolbar: { show: false },
                zoom: { enabled: false },
                animations: { enabled: true, speed: 600 },
                fontFamily: 'inherit',
                parentHeightOffset: 0
            },
            series: [
                { name: '💎 Kyber', data: kyberBanco, type: 'area' }
            ],
            xaxis: {
                categories: categorias,
                labels: {
                    style: { colors: '#64748b', fontSize: '8.5px' },
                    rotate: 0,
                    hideOverlappingLabels: true,
                    trim: true
                },
                axisBorder: { show: false },
                axisTicks: { show: false },
                tooltip: { enabled: false }
            },
            yaxis: {
                labels: {
                    style: { colors: '#64748b', fontSize: '8.5px' },
                    formatter: function(v) { return Number(v).toLocaleString('es-AR'); }
                },
                axisBorder: { show: false },
                axisTicks: { show: false }
            },
            stroke: {
                curve: 'smooth',
                width: 2,
                colors: ['#8b5cf6'],
                dashArray: [0]
            },
            fill: {
                type: ['gradient'],
                gradient: {
                    shade: 'dark',
                    type: 'vertical',
                    shadeIntensity: 0.3,
                    gradientToColors: ['#8b5cf6'],
                    inverseColors: false,
                    opacityFrom: 0.4,
                    opacityTo: 0.0,
                    stops: [0, 100]
                }
            },
            colors: ['#8b5cf6'],
            grid: {
                borderColor: 'rgba(148, 163, 184, 0.15)',
                strokeDashArray: 3,
                xaxis: { lines: { show: true } },
                yaxis: { lines: { show: true } },
                padding: { top: 0, right: 0, bottom: 0, left: 0 }
            },
            dataLabels: { enabled: false },
            markers: { size: 0, strokeWidth: 2, hover: { size: 4, sizeOffset: 0 } },
            tooltip: {
                theme: 'dark',
                style: { fontSize: '10px' },
                x: { show: true },
                y: {
                    formatter: function(v) {
                        return Number(v).toLocaleString('es-AR') + ' Kyber';
                    }
                },
                marker: { show: true },
                followCursor: true
            },
            annotations: buildAnnotation(ultimo),
            noData: {
                text: 'Aún no hay datos suficientes...',
                align: 'center',
                verticalAlign: 'middle',
                style: { color: '#94a3b8', fontSize: '11px' }
            },
            legend: { show: false }
        };
    }

    function cargarGrafico() {
        fetch('game.php?page=wallet&mode=getGrafico&horas=' + currentHoras)
            .then(function(r) { 
                if(!r.ok) throw new Error('Error HTTP: ' + r.status);
                return r.json(); 
            })
            .then(function(data) {
                var categorias = data.map(function(d) { return d.fecha; });
                var kyberBanco = data.map(function(d) { return Number(d.kyber_banco) || 0; });

                if (kyberBanco.length > 0 && priceEl) {
                    var ultimo = kyberBanco[kyberBanco.length - 1];
                    priceEl.textContent = Number(ultimo).toLocaleString('es-AR');
                }

                if (!chart) {
                    chart = new ApexCharts(chartEl, buildOptions(categorias, kyberBanco));
                    chart.render();
                } else {
                    var ultimoVal = kyberBanco.length > 0 ? kyberBanco[kyberBanco.length - 1] : null;
                    chart.updateOptions({
                        xaxis: { categories: categorias },
                        annotations: buildAnnotation(ultimoVal)
                    }, false, false);
                    chart.updateSeries([
                        { name: '💎 Kyber', data: kyberBanco }
                    ]);
                }
            })
            .catch(function(err) {
                console.error('Error cargando gráfico:', err);
                if (errorMsg) {
                    errorMsg.style.display = 'block';
                    errorMsg.innerHTML = '⚠️ Error: ' + err.message;
                }
            });
    }

    if (timeWrap) {
        timeWrap.addEventListener('click', function(e) {
            var btn = e.target.closest('.rn-time-btn');
            if (!btn) return;
            var horas = parseInt(btn.getAttribute('data-horas'), 10);
            if (isNaN(horas)) return;

            var hermanos = timeWrap.querySelectorAll('.rn-time-btn');
            for (var i = 0; i < hermanos.length; i++) {
                hermanos[i].classList.remove('active');
            }
            btn.classList.add('active');

            currentHoras = horas;
            cargarGrafico();
        });
    }

    cargarGrafico();
    setInterval(cargarGrafico, 60 * 60 * 1000); 
});
</script>

{/block}