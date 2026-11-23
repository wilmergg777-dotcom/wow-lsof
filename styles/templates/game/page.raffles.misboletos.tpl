{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.raffles.misboletos.tpl === *}
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
   RIFAS — Mis Boletos
   AstroIO v3.1 (DUAL RIEL) — Glassmorphism + Acento Cyan
   Prefijo: .astroraffle_
   v3.1 (2026-10-30):
     - Añadido badge de saldo del jugador con {$moneda}
     - Usa {$t.moneda_pagada_label} (NTX-20 / UNTX-20 ya mapeada)
     - Precio con number_format
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

.astroraffle_wrap { max-width: 900px; margin: 0 auto; text-align: center; }

/* 🆕 v3.1 — Badge de saldo del jugador */
.astroraffle_balance_box {
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
.astroraffle_balance_badge {
    color: #66ff99;
    font-size: 12px;
    font-weight: 600;
}
.astroraffle_balance_badge strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    letter-spacing: 0.5px;
}

.astroraffle_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 14px;
    text-align: left;
    display: inline-block;
    width: 100%;
    box-sizing: border-box;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astroraffle_title {
    text-transform: uppercase;
    color: var(--accent-cyan);
    font-size: 13px;
    font-weight: bold;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.astroraffle_nav {
    margin-bottom: 12px;
    text-align: left;
}
.astroraffle_nav a {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 11px;
    margin-right: 14px;
    padding: 4px 8px;
    border-radius: 6px;
    transition: all 0.25s ease;
    border: 1px solid transparent;
}
.astroraffle_nav a:hover {
    background: rgba(0, 224, 255, 0.1);
    border-color: rgba(0, 224, 255, 0.4);
    text-decoration: none;
    transform: translateY(-1px);
}
.astroraffle_nav a.active {
    background: rgba(0, 224, 255, 0.15);
    color: var(--accent-cyan);
    border-color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}

.astroraffle_ticket {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 10px 14px;
    margin-bottom: 8px;
    transition: all 0.25s ease;
}
.astroraffle_ticket:hover {
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.2);
    transform: translateY(-2px);
}
.astroraffle_ticket.win {
    border-left-color: var(--accent-gold);
    background: rgba(251, 191, 36, 0.05);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.2);
}
.astroraffle_ticket.lose {
    border-left-color: var(--text-muted);
    opacity: 0.75;
}
.astroraffle_ticket_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
}
.astroraffle_ticket_name {
    color: var(--text-title);
    font-weight: bold;
    font-size: 11.5px;
}
.astroraffle_ticket_badge {
    font-size: 9px;
    padding: 2px 8px;
    border-radius: 10px;
    background: rgba(0, 224, 255, 0.15);
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border: 1px solid rgba(0, 224, 255, 0.3);
}
.astroraffle_ticket_badge.win {
    background: rgba(251, 191, 36, 0.15);
    color: var(--accent-gold);
    border-color: rgba(251, 191, 36, 0.4);
}
.astroraffle_ticket_badge.end {
    background: rgba(74, 255, 136, 0.15);
    color: var(--accent-green);
    border-color: rgba(74, 255, 136, 0.4);
}
.astroraffle_ticket_info {
    font-size: 10.5px;
    color: var(--text-main);
    line-height: 1.7;
}
.astroraffle_ticket_info b { color: var(--text-title); }
.astroraffle_ticket_info .num {
    color: var(--accent-cyan);
    font-weight: bold;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroraffle_empty {
    color: var(--text-muted);
    font-size: 11px;
    text-align: center;
    padding: 24px;
    font-style: italic;
}
.astroraffle_btn {
    display: inline-block;
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #fff;
    text-decoration: none;
    padding: 4px 12px;
    border-radius: 6px;
    font-size: 10px;
    font-weight: bold;
    margin-top: 6px;
    transition: all 0.25s ease;
    border: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroraffle_btn:hover {
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.55);
    color: #fff;
    text-decoration: none;
    transform: translateY(-2px);
    background: linear-gradient(135deg, #0099ff 0%, #00ccff 100%);
}
.astroraffle_btn:active {
    transform: translateY(0);
}
</style>

<div class="astroraffle_wrap">

    {* 🆕 v3.1 — BADGE DE SALDO DEL JUGADOR *}
    <div class="astroraffle_balance_box">
        <span class="astroraffle_balance_badge">
            💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}
        </span>
    </div>

    <div class="astroraffle_nav">
        <a href="game.php?page=raffles">Rifas Activas</a>
        <a href="game.php?page=raffles&mode=misBoletos" class="active">Mis Boletos</a>
    </div>

    <div class="astroraffle_panel">
        <div class="astroraffle_title">Mis Boletos</div>

        {if $hay_tickets}
        {foreach $tickets as $t}
        <div class="astroraffle_ticket {if $t.estado == 'finalizado' && $t.ganador_id == $t.user_id}win{elseif $t.estado == 'finalizado'}lose{/if}">
            <div class="astroraffle_ticket_head">
                <span class="astroraffle_ticket_name">{$t.titulo}</span>
                {if $t.estado == 'activo'}
                    <span class="astroraffle_ticket_badge">Activa</span>
                {elseif $t.ganador_id == $t.user_id}
                    <span class="astroraffle_ticket_badge win">Ganaste</span>
                {else}
                    <span class="astroraffle_ticket_badge end">Finalizada</span>
                {/if}
            </div>

            <div class="astroraffle_ticket_info">
                Boleto: <span class="num">#{$t.boleto_numero}</span><br>

                {* 🆕 v3.1 — Moneda mapeada (NTX-20 / UNTX-20 / Metal / etc) *}
                Pagado: <b>{$t.precio_pagado|number_format:0:',,':'.'} {$t.moneda_pagada_label}</b><br>

                Comprado: <b>{$t.fecha_compra|date_format:"%d/%m/%Y %H:%M"}</b>
                {if $t.estado == 'activo'}
                <br>Termina en: <b>{$t.fecha_fin|date_format:"%d/%m/%Y %H:%M"}</b>
                {/if}
            </div>

            <a href="game.php?page=raffles&mode=view&id={$t.raffle_id}" class="astroraffle_btn">Ver Rifa</a>
        </div>
        {/foreach}
        {else}
        <div class="astroraffle_empty">No tenes boletos todavia</div>
        {/if}
    </div>

</div>

{/block}