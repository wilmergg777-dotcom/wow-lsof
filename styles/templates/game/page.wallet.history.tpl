{block name="title" prepend}Historial{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.wallet.history.tpl === *}
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
   HISTORIAL DE MOVIMIENTOS — Vista del usuario
   AstroIO v3.0 — Glassmorphism + Acento Cyan
   Prefijo: .wallet-
   ═══════════════════════════════════════════════════════════ */

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

.wallet-wrapper {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: var(--text-main);
    padding: 20px;
    border-radius: 12px;
    border: 1px solid var(--border-color);
    max-width: 950px;
    margin: 0 auto;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    box-sizing: border-box;
}
.wallet-title {
    color: var(--text-title);
    font-size: 22px;
    margin-bottom: 20px;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.35);
}
.wallet-tabs {
    display: flex;
    gap: 8px;
    margin-bottom: 20px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 10px;
    flex-wrap: wrap;
}
.wallet-tab {
    background: rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid transparent;
    color: var(--text-muted);
    padding: 10px 20px;
    cursor: pointer;
    font-weight: 600;
    border-radius: 6px;
    text-decoration: none;
    font-size: 14px;
    transition: 0.25s ease;
}
.wallet-tab.active {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
}
.wallet-tab:hover {
    background: rgba(0, 224, 255, 0.08);
    color: var(--text-main);
    border-color: rgba(0, 224, 255, 0.3);
    transform: translateY(-1px);
}
.wallet-tab.disabled {
    opacity: 0.4;
    cursor: not-allowed;
    pointer-events: none;
}
.wallet-section {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 20px;
}
.wallet-mov-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}
.wallet-mov-table th {
    text-align: left;
    padding: 10px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-muted);
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.wallet-mov-table td {
    padding: 10px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-main);
}
.wallet-mov-table tr:hover td {
    background: rgba(0, 224, 255, 0.05);
}
.wallet-badge {
    display: inline-block;
    padding: 3px 8px;
    border-radius: 4px;
    font-size: 11px;
    font-weight: bold;
}
.wallet-badge.in    { background: rgba(74, 255, 136, 0.2);  color: var(--accent-green); }
.wallet-badge.out   { background: rgba(239, 68, 68, 0.2);   color: var(--accent-red); }
.wallet-badge.info  { background: rgba(0, 224, 255, 0.2);   color: var(--accent-cyan); }
.wallet-badge.gray  { background: rgba(148, 163, 184, 0.2); color: var(--text-muted); }
</style>

<div class="wallet-wrapper">

    <div class="wallet-title">📜 Historial de Movimientos</div>

    <div class="wallet-tabs">
        <a class="wallet-tab" href="game.php?page=wallet">📊 Resumen</a>
        <a class="wallet-tab" href="game.php?page=wallet&mode=deposit">📥 Invertir</a>
        {if $es_vip && $retiros_abiertos}
            <a class="wallet-tab" href="game.php?page=wallet&mode=withdraw">📤 Retirar</a>
        {/if}
        <a class="wallet-tab active" href="game.php?page=wallet&mode=history">📜 Historial</a>
    </div>

    <div class="wallet-section">

        {if $movimientos|@count > 0}
            <table class="wallet-mov-table">
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
                            <td>{$mov.fecha}</td>
                            <td>
                                {if $mov.tipo == 'inversion'}
                                    <span class="wallet-badge in">Inversión</span>
                                {elseif $mov.tipo == 'retiro'}
                                    <span class="wallet-badge out">Retiro</span>
                                {elseif $mov.tipo == 'referido'}
                                    <span class="wallet-badge in">Ref. Inversión</span>
                                {elseif $mov.tipo == 'referido_retiro'}
                                    <span class="wallet-badge in">Ref. Retiro</span>
                                {elseif $mov.tipo == 'fondo_proyecto'}
                                    <span class="wallet-badge info">Fondo Proyecto</span>
                                {elseif $mov.tipo == 'ajuste'}
                                    <span class="wallet-badge gray">Ajuste</span>
                                {else}
                                    <span class="wallet-badge">{$mov.tipo}</span>
                                {/if}
                            </td>
                            <td>{$mov.moneda}</td>
                            <td>{$mov.cantidad}</td>
                            <td>{$mov.detalle|escape:'html'}</td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        {else}
            <div style="color: var(--text-muted); text-align: center; padding: 40px;">
                No hay movimientos registrados.
            </div>
        {/if}

    </div>

</div>

{/block}