{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.raffles.view.tpl === *}
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
   RIFAS — Ver detalle + comprar boleto
   AstroIO v3.1 (DUAL RIEL) — Glassmorphism + Acento Cyan
   Prefijo: .astroraffle_
   v3.1 (2026-10-30):
     - Añadido badge de saldo del jugador con {$moneda}
     - Precio del boleto usa {$precio_real} (ya ajustado ×2 si QVAPAY)
     - Premios y moneda ya vienen ajustados del Helper
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
.astroraffle_back {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 11px;
    display: inline-block;
    margin-bottom: 10px;
    transition: all 0.25s ease;
}
.astroraffle_back:hover {
    color: var(--accent-cyan);
    text-decoration: none;
    transform: translateX(-3px);
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
}

.astroraffle_head_name {
    font-size: 18px;
    color: var(--text-title);
    font-weight: bold;
    margin-bottom: 4px;
    text-shadow: 0 0 10px rgba(255, 255, 255, 0.2);
}
.astroraffle_desc {
    color: var(--text-muted);
    font-size: 11px;
    margin-bottom: 10px;
    line-height: 1.5;
}

.astroraffle_prizes_list { margin: 8px 0; }
.astroraffle_prize_item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-gold);
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 6px;
}
.astroraffle_prize_item.first { border-left-color: var(--accent-gold); }
.astroraffle_prize_item.winner {
    background: rgba(251, 191, 36, 0.08);
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.2);
}
.astroraffle_prize_lugar {
    color: var(--accent-cyan);
    font-weight: bold;
    font-size: 11px;
    width: 90px;
}
.astroraffle_prize_texto {
    color: var(--text-title);
    font-size: 12px;
    flex: 1;
}
.astroraffle_prize_winner {
    color: var(--accent-gold);
    font-size: 10.5px;
    text-align: right;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}
.astroraffle_prize_winner .winner_name {
    display: block;
    color: #4aff88;
    font-weight: bold;
    font-size: 11px;
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.4);
}

.astroraffle_stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
    margin: 10px 0;
}
.astroraffle_stat {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px;
    text-align: center;
    transition: 0.25s ease;
}
.astroraffle_stat:hover {
    border-color: rgba(0, 224, 255, 0.4);
    transform: translateY(-2px);
}
.astroraffle_stat_val {
    color: var(--accent-cyan);
    font-size: 16px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroraffle_stat_lbl {
    color: var(--text-muted);
    font-size: 9px;
    text-transform: uppercase;
    margin-top: 3px;
    letter-spacing: 0.5px;
}

.astroraffle_buy_box {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 14px;
    text-align: center;
    margin-top: 10px;
}
.astroraffle_buy_info {
    color: var(--text-main);
    font-size: 11px;
    margin-bottom: 10px;
    line-height: 1.8;
}
.astroraffle_buy_info b { color: var(--text-title); }

.astroraffle_btn_buy {
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
    border: 1px solid var(--accent-gold);
    padding: 10px 28px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 13px;
    cursor: pointer;
    transition: all 0.25s ease;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
    font-family: inherit;
}
.astroraffle_btn_buy:hover {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(135deg, #fbbf24 0%, #fde047 100%);
}
.astroraffle_btn_buy:active {
    transform: translateY(0);
}
.astroraffle_btn_buy:disabled {
    background: rgba(30, 41, 59, 0.85);
    border-color: var(--border-color);
    color: var(--text-muted);
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
}

.astroraffle_alert {
    padding: 10px 14px;
    border-radius: 8px;
    font-size: 11px;
    margin: 10px 0;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astroraffle_alert.warn {
    background: rgba(251, 191, 36, 0.12);
    border-left: 3px solid var(--accent-gold);
    color: var(--accent-gold);
}
.astroraffle_alert.success {
    background: rgba(74, 255, 136, 0.12);
    border-left: 3px solid var(--accent-green);
    color: var(--accent-green);
}
.astroraffle_alert.error {
    background: rgba(239, 68, 68, 0.12);
    border-left: 3px solid var(--accent-red);
    color: var(--accent-red);
}

.astroraffle_my_ticket {
    background: rgba(74, 255, 136, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-green);
    border-radius: 8px;
    padding: 10px 14px;
    margin: 10px 0;
    font-size: 11.5px;
    color: var(--accent-green);
    text-align: center;
}

.astroraffle_countdown {
    display: inline-block;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 6px 14px;
    font-size: 16px;
    color: var(--accent-cyan);
    font-weight: bold;
    letter-spacing: 1px;
    margin: 6px 0;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
}
.astroraffle_countdown.danger {
    border-color: var(--accent-red);
    color: var(--accent-red);
    text-shadow: 0 0 10px rgba(239, 68, 68, 0.5);
    box-shadow: 0 0 14px rgba(239, 68, 68, 0.3);
    animation: pulseCountdown 1.5s ease-in-out infinite;
}
.astroraffle_countdown.warn {
    border-color: var(--accent-gold);
    color: var(--accent-gold);
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.5);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
}
@keyframes pulseCountdown {
    0%, 100% { opacity: 1; }
    50%      { opacity: 0.65; }
}

.astroraffle_msg {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-size: 11.5px;
    text-align: left;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astroraffle_msg.success {
    background: rgba(74, 255, 136, 0.10);
    border-left: 3px solid var(--accent-green);
    color: var(--accent-green);
}
.astroraffle_msg.error {
    background: rgba(239, 68, 68, 0.10);
    border-left: 3px solid var(--accent-red);
    color: var(--accent-red);
}

.astroraffle_participants {
    max-height: 200px;
    overflow-y: auto;
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 8px;
}
.astroraffle_participant {
    display: flex;
    justify-content: space-between;
    font-size: 10.5px;
    color: var(--text-main);
    padding: 4px 8px;
    border-bottom: 1px solid var(--border-color);
}
.astroraffle_participant:last-child { border-bottom: none; }
.astroraffle_participant b {
    color: var(--text-title);
    font-family: 'Courier New', monospace;
}

.astroraffle_bar_wrap {
    background: rgba(0, 0, 0, 0.5);
    border-radius: 4px;
    height: 8px;
    overflow: hidden;
    margin: 6px 0;
    position: relative;
    border: 1px solid var(--border-color);
}
.astroraffle_bar {
    background: linear-gradient(90deg, #0066cc, var(--accent-cyan));
    height: 100%;
    border-radius: 4px;
    transition: width 0.4s ease;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.5) inset;
}
.astroraffle_bar_txt {
    font-size: 9.5px;
    color: var(--text-muted);
    text-align: right;
}
</style>

<div class="astroraffle_wrap">

    {* 🆕 v3.1 — BADGE DE SALDO DEL JUGADOR *}
    <div class="astroraffle_balance_box">
        <span class="astroraffle_balance_badge">
            💲 Tu saldo: <strong>{$saldo_actual|number_format:0:',,':'.'}</strong> {$moneda}
        </span>
    </div>

    <a href="game.php?page=raffles" class="astroraffle_back">&larr; Volver a Rifas</a>

    {if $msg}
    <div class="astroraffle_msg {$msg_type}">{$msg}</div>
    {/if}

    <div class="astroraffle_panel">

        <div class="astroraffle_head_name">{$raffle.titulo}</div>
        {if $raffle.descripcion}
        <div class="astroraffle_desc">{$raffle.descripcion}</div>
        {/if}

        {if $raffle.estado == 'activo'}
        <div style="text-align:center;">
            <div class="astroraffle_countdown {if $raffle.tiempo_restante == 'SORTEANDO...'}danger{/if}">
                {$raffle.tiempo_restante}
            </div>
        </div>
        {/if}

    </div>

    <div class="astroraffle_panel">
        <div class="astroraffle_title">Premios ({$raffle.cantidad_lugares} lugares)</div>

        <div class="astroraffle_prizes_list">
            {foreach $raffle_premios_por_lugar as $grupo}
            <div class="astroraffle_prize_item {if $grupo.lugar == 1}first{/if} {if $grupo.ganador_id}winner{/if}">
                <div class="astroraffle_prize_lugar">LUGAR {$grupo.lugar}{if $grupo.cantidad_premios > 1} ({$grupo.cantidad_premios} premios){/if}</div>
                {foreach $grupo.textos as $texto}
                <div class="astroraffle_prize_texto">{$texto}</div>
                {/foreach}
                {if $grupo.ganador_id}
                <div class="astroraffle_prize_winner">
                    {if $grupo.ganador_username}<span class="winner_name">{$grupo.ganador_username}</span>{/if}
                    Boleto #{$grupo.boleto_ganador}
                </div>
                {/if}
            </div>
            {/foreach}
        </div>
    </div>

    <div class="astroraffle_panel">
        <div class="astroraffle_title">Estadisticas</div>

        <div class="astroraffle_stats">
            <div class="astroraffle_stat">
                <div class="astroraffle_stat_val">{$raffle.boletos_vendidos}</div>
                <div class="astroraffle_stat_lbl">Boletos</div>
            </div>
            <div class="astroraffle_stat">
                <div class="astroraffle_stat_val">{$raffle.max_boletos}</div>
                <div class="astroraffle_stat_lbl">Maximo</div>
            </div>

            {* 🆕 v3.1 — Precio ajustado al riel del jugador *}
            <div class="astroraffle_stat">
                <div class="astroraffle_stat_val">{$precio_real|number_format:0:',,':'.'}</div>
                <div class="astroraffle_stat_lbl">{$raffle.moneda_nombre}</div>
            </div>

            <div class="astroraffle_stat">
                <div class="astroraffle_stat_val">{$raffle.boletos_restantes}</div>
                <div class="astroraffle_stat_lbl">Restantes</div>
            </div>
        </div>

        <div class="astroraffle_bar_wrap">
            <div class="astroraffle_bar" style="width: {$raffle.pct}%"></div>
        </div>
        <div class="astroraffle_bar_txt">{$raffle.boletos_vendidos} / {$raffle.max_boletos} ({$raffle.pct}%)</div>
    </div>

    {if $raffle.estado == 'activo'}
    <div class="astroraffle_panel">
        <div class="astroraffle_title">Comprar Boleto</div>

        {if $mi_boleto}
        <div class="astroraffle_my_ticket">
            Ya tenes un boleto en esta rifa. Maximo 1 por jugador.
        </div>
        {elseif $raffle.boletos_vendidos >= $raffle.max_boletos}
        <div class="astroraffle_alert warn">Se vendieron todos los boletos</div>
        {elseif $raffle.fecha_fin < $time_now}
        <div class="astroraffle_alert warn">La rifa ya cerro</div>

        {* 🆕 v3.1 — Comparar contra $precio_real (ya ajustado ×2 si QVAPAY) *}
        {elseif $mi_saldo < $precio_real}
        <div class="astroraffle_alert error">
            No tenes suficiente {$raffle.moneda_nombre}.
            Necesitas {$precio_real|number_format:0:',,':'.'} y tenes {$mi_saldo|number_format:0:',,':'.'}.
        </div>

        {else}
        <div class="astroraffle_buy_box">
            {* 🆕 v3.1 — Precio con $precio_real en lugar de $raffle.precio_boleto *}
            <div class="astroraffle_buy_info">
                Precio por boleto: <b>{$precio_real|number_format:0:',,':'.'} {$raffle.moneda_nombre}</b><br>
                Tu saldo: <b>{$mi_saldo|number_format:0:',,':'.'} {$raffle.moneda_nombre}</b><br>
                Maximo por jugador: <b>1 boleto</b>
            </div>

            <form method="POST" action="game.php?page=raffles&mode=comprar">
                <input type="hidden" name="id" value="{$raffle.id}">
                <input type="hidden" name="token" value="{$token}">
                <button type="submit" class="astroraffle_btn_buy">COMPRAR BOLETO</button>
            </form>
        </div>
        {/if}
    </div>
    {/if}

    {if $hay_ganadores}
    <div class="astroraffle_panel">
        <div class="astroraffle_title">Ganadores</div>
        {foreach $raffle_ganadores_por_lugar as $grupo}
        <div class="astroraffle_prize_item winner">
            <div class="astroraffle_prize_lugar">LUGAR {$grupo.lugar}{if $grupo.cantidad_premios > 1} ({$grupo.cantidad_premios} premios){/if}</div>
            {foreach $grupo.textos as $texto}
            <div class="astroraffle_prize_texto">{$texto}</div>
            {/foreach}
            <div class="astroraffle_prize_winner">
                {if $grupo.ganador_username}<span class="winner_name">{$grupo.ganador_username}</span>{/if}
                Boleto #{$grupo.boleto_ganador}
            </div>
        </div>
        {/foreach}
    </div>
    {/if}

    {if $raffle_tickets && $raffle.estado == 'activo'}
    <div class="astroraffle_panel">
        <div class="astroraffle_title">Participantes ({$raffle.boletos_vendidos})</div>
        <div class="astroraffle_participants">
            {foreach $raffle_tickets as $t}
            <div class="astroraffle_participant">
                <span><b>#{$t.boleto_numero}</b> - {$t.username|default:'Anonimo'}</span>
            </div>
            {/foreach}
        </div>
    </div>
    {/if}

</div>

{/block}