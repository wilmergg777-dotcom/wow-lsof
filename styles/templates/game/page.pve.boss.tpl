{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pve.boss.tpl === *}
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
   PvE — Torneo del Devorador
   AstroIO v4.0 — Glassmorphism + Acento Magenta + Dual-Riel
   Prefijo: .pveBoss / .boss*
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
    --accent-magenta:#ff88ff;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

.pveBossWrap {
    max-width: 1000px;
    margin: 0 auto;
    padding: 16px;
    color: var(--text-main);
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 13px;
}

.pveBossWrap h1 {
    color: var(--accent-magenta);
    text-align: center;
    font-size: 22px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(255, 136, 255, 0.6);
    letter-spacing: 1px;
}

/* ─── v4.0 — BADGE DE SALDO ────────────────────────────── */
.bossBalanceBar {
    display: flex;
    justify-content: center;
    margin-bottom: 18px;
}

.bossBalanceBadge {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 10px 22px;
    background: rgba(0, 0, 0, 0.55);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 14px;
    font-family: 'Courier New', monospace;
    transition: all 0.25s ease;
}
.bossBalanceBadge:hover { transform: translateY(-1px); }

.bossBalanceBadge.cup {
    border: 1px solid rgba(251, 191, 36, 0.6);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
    color: #ffee88;
}
.bossBalanceBadge.cup:hover {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.5);
}

.bossBalanceBadge.qvapay {
    border: 1px solid rgba(0, 224, 255, 0.6);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
    color: #88ffff;
}
.bossBalanceBadge.qvapay:hover {
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
}

.bossBalanceLabel {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.bossBalanceValue {
    font-size: 17px;
    font-weight: bold;
    letter-spacing: 0.5px;
}

.bossBalanceCurrency {
    font-size: 12px;
    opacity: 0.9;
    font-weight: bold;
    letter-spacing: 0.5px;
}

/* ─── Tabs ─────────────────────────────────────────────── */
.bossTabs {
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.bossTab {
    padding: 10px 18px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    color: #dd99ff;
    background: rgba(139, 92, 246, 0.15);
    border: 1px solid rgba(139, 92, 246, 0.5);
    transition: all 0.25s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.bossTab:hover {
    background: rgba(139, 92, 246, 0.3);
    color: #fff;
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.4);
}

.bossTab.active {
    background: linear-gradient(135deg, #8b5cf6, #a78bfa);
    color: #fff;
    border-color: var(--accent-purple);
    box-shadow: 0 4px 14px rgba(139, 92, 246, 0.5);
}

/* ─── Cards ────────────────────────────────────────────── */
.bossCard {
    background: linear-gradient(160deg, rgba(40, 10, 60, 0.75), rgba(20, 5, 30, 0.75));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(255, 136, 255, 0.5);
    border-radius: 14px;
    padding: 18px;
    margin-bottom: 16px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.25s ease;
}
.bossCard:hover {
    border-color: rgba(255, 136, 255, 0.7);
    box-shadow: 0 8px 30px rgba(255, 136, 255, 0.2), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.bossCard.crisis {
    background: linear-gradient(160deg, rgba(30, 15, 60, 0.75), rgba(50, 20, 90, 0.75));
    border-color: rgba(139, 92, 246, 0.5);
}

.bossCard.empire {
    background: linear-gradient(160deg, rgba(60, 30, 10, 0.75), rgba(90, 45, 15, 0.75));
    border-color: rgba(251, 191, 36, 0.5);
}

.bossCard.rewards {
    background: linear-gradient(160deg, rgba(20, 40, 20, 0.75), rgba(30, 60, 30, 0.75));
    border-color: rgba(74, 255, 136, 0.5);
}

.bossCard h2 {
    margin: 0 0 12px 0;
    font-size: 15px;
    color: var(--accent-magenta);
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
    text-shadow: 0 0 8px rgba(255, 136, 255, 0.3);
}

/* ─── Badge de estado ──────────────────────────────────── */
.bossStatus {
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: bold;
    white-space: nowrap;
}

.bossStatus.scheduled {
    background: rgba(148, 163, 184, 0.3);
    color: #cccccc;
    border: 1px solid rgba(180, 180, 180, 0.5);
}

.bossStatus.registration {
    background: rgba(0, 224, 255, 0.25);
    color: #88ddff;
    border: 1px solid rgba(0, 224, 255, 0.6);
}

.bossStatus.active {
    background: rgba(239, 68, 68, 0.25);
    color: #ff8888;
    border: 1px solid rgba(239, 68, 68, 0.6);
    animation: bossPulse 1.4s infinite;
}

.bossStatus.finished {
    background: rgba(74, 255, 136, 0.25);
    color: #88ffbb;
    border: 1px solid rgba(74, 255, 136, 0.6);
}

.bossStatus.cancelled {
    background: rgba(251, 191, 36, 0.25);
    color: #ffaa66;
    border: 1px solid rgba(251, 191, 36, 0.6);
}

@keyframes bossPulse {
    0%, 100% { opacity: 1; transform: scale(1); }
    50%      { opacity: 0.65; transform: scale(1.03); }
}

/* ─── Grid de datos ────────────────────────────────────── */
.bossGrid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 10px;
    margin-bottom: 14px;
}

.bossGridItem {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px 12px;
}

.bossGridLabel {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.bossGridValue {
    font-size: 14px;
    color: #ffee88;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}

.bossGridValue.cup    { color: #ffee88; }
.bossGridValue.qvapay { color: #88ffff; text-shadow: 0 0 8px rgba(0, 224, 255, 0.3); }
.bossGridValue.mine   { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.3); }

/* ─── Countdown box ────────────────────────────────────── */
.bossCountdown {
    text-align: center;
    padding: 18px 10px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    margin: 14px 0;
}

.bossCountdownLabel {
    font-size: 11px;
    color: var(--text-muted);
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-bottom: 8px;
}

.bossCountdownValue {
    font-size: 32px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    color: #ffee88;
    line-height: 1.1;
    text-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

/* ─── Botones grandes ──────────────────────────────────── */
.bossBtnBig {
    display: block;
    width: 100%;
    max-width: 400px;
    margin: 16px auto 0;
    padding: 16px 24px;
    background: linear-gradient(135deg, #7700cc, #8b5cf6);
    color: #fff;
    border: 1px solid var(--accent-purple);
    border-radius: 10px;
    font-size: 16px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    text-align: center;
    box-shadow: 0 6px 20px rgba(139, 92, 246, 0.5);
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
    letter-spacing: 0.5px;
}

.bossBtnBig:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 26px rgba(139, 92, 246, 0.7);
    background: linear-gradient(135deg, #8b5cf6, #a78bfa);
}

.bossBtnBig.green {
    background: linear-gradient(135deg, #228833, #4aff88);
    border-color: var(--accent-green);
    box-shadow: 0 6px 20px rgba(74, 255, 136, 0.5);
}

.bossBtnBig.green:hover {
    box-shadow: 0 8px 26px rgba(74, 255, 136, 0.7);
    background: linear-gradient(135deg, #4aff88, #86ffb8);
    color: #1a1000;
}

.bossBtnBig.red {
    background: linear-gradient(135deg, #aa2200, #ef4444);
    border-color: var(--accent-red);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.5);
}

/* ─── HP bar ───────────────────────────────────────────── */
.bossHpBar {
    height: 14px;
    background: rgba(0, 0, 0, 0.6);
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid rgba(255, 136, 255, 0.4);
    margin: 6px 0;
}

.bossHpFill {
    height: 100%;
    background: linear-gradient(90deg, #8b5cf6, #ff88ff, #ffaaff);
    transition: width 0.5s ease;
    box-shadow: 0 0 10px rgba(255, 136, 255, 0.5) inset;
}

/* ─── Tabla ranking ────────────────────────────────────── */
.bossTable {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    margin-top: 8px;
}

.bossTable thead th {
    padding: 8px 6px;
    text-align: left;
    color: var(--accent-magenta);
    font-size: 10px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid rgba(255, 136, 255, 0.3);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.bossTable tbody td {
    padding: 8px 6px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-main);
}

.bossTable tbody tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

.bossTable tbody tr.my-ally {
    background: rgba(251, 191, 36, 0.08);
    border-left: 3px solid var(--accent-gold);
}

.bossTable .center { text-align: center; }
.bossTable .right  { text-align: right; }

.bossTable .pos {
    color: var(--accent-gold);
    font-weight: bold;
    font-size: 14px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
}

.bossTable .damage {
    color: #ffee88;
    font-family: 'Courier New', monospace;
}

.bossTable .pct {
    color: var(--accent-magenta);
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(255, 136, 255, 0.3);
}

/* ─── Fases ────────────────────────────────────────────── */
.phase-badge {
    display: inline-block;
    padding: 3px 9px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: bold;
}

.phase-1 { background: rgba(74, 255, 136, 0.2); color: #88ffbb; border: 1px solid var(--accent-green); }
.phase-2 { background: rgba(251, 191, 36, 0.2); color: #ffaa66; border: 1px solid var(--accent-gold); }
.phase-3 { background: rgba(239, 68, 68, 0.25); color: #ff8888; border: 1px solid var(--accent-red); }

/* ─── Flash ────────────────────────────────────────────── */
.bossFlash {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-size: 13px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.bossFlash.success {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffbb;
}

.bossFlash.error {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: #ffbbbb;
}

.bossFlash.info {
    background: rgba(0, 224, 255, 0.15);
    border: 1px solid rgba(0, 224, 255, 0.5);
    color: #88ddff;
}

/* ─── Coord box ────────────────────────────────────────── */
.bossCoords {
    display: inline-block;
    background: rgba(0, 0, 0, 0.6);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 2px solid var(--accent-gold);
    border-radius: 8px;
    padding: 8px 16px;
    font-size: 20px;
    color: var(--accent-gold);
    font-weight: bold;
    font-family: 'Courier New', monospace;
    letter-spacing: 2px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.5);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
}

/* ─── Empty state ──────────────────────────────────────── */
.bossEmpty {
    text-align: center;
    color: var(--text-muted);
    padding: 40px 20px;
    font-size: 13px;
}

.bossEmpty .big {
    font-size: 40px;
    display: block;
    margin-bottom: 12px;
    opacity: 0.5;
}

@media (max-width: 700px) {
    .bossGrid { grid-template-columns: 1fr; }
    .bossCountdownValue { font-size: 26px; }
}
</style>

<div class="pveBossWrap">

    <h1>🌌 Torneo del Devorador</h1>

    {* ─── v4.0 — BADGE DE SALDO ─── *}
    {if isset($moneda) && isset($saldo_actual)}
        <div class="bossBalanceBar">
            <div class="bossBalanceBadge {if $es_internacional}qvapay{else}cup{/if}">
                <span class="bossBalanceLabel">💰 Saldo:</span>
                <span class="bossBalanceValue">{$saldo_actual|number_format}</span>
                <span class="bossBalanceCurrency">{$moneda}</span>
            </div>
        </div>
    {/if}

    {* ─── TABS ─── *}
    <div class="bossTabs">
        <a href="game.php?page=pve" class="bossTab">🏠 Panel Principal</a>
        <a href="game.php?page=pve&mode=empire" class="bossTab">🏛️ Imperio Caído</a>
        <a href="game.php?page=pve&mode=bastion" class="bossTab">⚓ Bastión Asediado</a>
        <a href="game.php?page=pve&mode=achievements" class="bossTab">🏆 Logros</a>
        <a href="game.php?page=pve&mode=boss" class="bossTab active">🌌 Torneo del Devorador</a>
    </div>

    {* ─── FLASH MESSAGES ─── *}
    {if $bossResult}
        <div class="bossFlash success">
            ✅ {$bossResult.message|escape:'html'}
        </div>
    {/if}

    {if $bossError}
        <div class="bossFlash error">
            ❌ {$bossError|escape:'html'}
        </div>
    {/if}

    {* ─── SI NO HAY EVENTO ─── *}
    {if !$pve_boss.event}
        <div class="bossCard">
            <div class="bossEmpty">
                <span class="big">🌌</span>
                <strong style="color:#ff88ff;font-size:16px;">No hay ningún torneo activo ahora mismo</strong>
                <br><br>
                El Torneo del Devorador es un evento por alianzas que se celebra periódicamente.
                <br>
                Cuando se programe el próximo torneo, aparecerá aquí y podrás inscribir tu alianza.
                <br><br>
                <span style="font-size:11px;color:#667788;">
                    Mantente atento a las notificaciones.
                </span>
            </div>
        </div>
    {else}

        {assign var=event value=$pve_boss.event}
        {assign var=pp    value=$pve_boss.pool_preview}

        {* ─── CARD DEL EVENTO ─── *}
        <div class="bossCard">
            <h2>
                <span>🌌 {$event.boss_name|escape:'html'}</span>
                <span class="bossStatus {$event.status}">
                    {if $event.status == 'scheduled'}⏰ Programado
                    {elseif $event.status == 'registration'}📝 Registro Abierto
                    {elseif $event.status == 'active'}🔴 ACTIVO
                    {elseif $event.status == 'finished'}🏁 Finalizado
                    {elseif $event.status == 'cancelled'}🛑 Cancelado
                    {/if}
                </span>
            </h2>

            <div class="bossGrid">
                <div class="bossGridItem">
                    <div class="bossGridLabel">Modo de entrada</div>
                    <div class="bossGridValue">
                        {if $event.entry_mode == 'paid'}💰 Pago{else}🆓 Gratis{/if}
                    </div>
                </div>
                <div class="bossGridItem">
                    <div class="bossGridLabel">Premio</div>
                    <div class="bossGridValue">
                        {if $event.prize_type == 'ntx'}💎 NTX-20
                        {elseif $event.prize_type == 'metal'}🔩 Metal
                        {elseif $event.prize_type == 'crystal'}💠 Cristal
                        {elseif $event.prize_type == 'deuterium'}⚗️ Deuterio
                        {elseif $event.prize_type == 'dark_matter'}🌑 Mat. Oscura
                        {elseif $event.prize_type == 'mixed'}🎁 Mixto
                        {else}{$event.prize_type|upper}{/if}
                    </div>
                </div>
                <div class="bossGridItem">
                    <div class="bossGridLabel">Duración</div>
                    <div class="bossGridValue">{$event.duration_hours|default:48}h</div>
                </div>
                <div class="bossGridItem">
                    <div class="bossGridLabel">Alianzas</div>
                    <div class="bossGridValue">min {$event.min_alliances|default:2} / max {$event.max_alliances|default:20}</div>
                </div>
            </div>

            {* ─── v4.0 — POOLS / PREMIOS DUALES ─── *}
            {if $event.entry_mode == 'paid'}

                {* PAID: mostrar pools separados por riel *}
                <div class="bossGrid" style="margin-top:4px;">
                    <div class="bossGridItem">
                        <div class="bossGridLabel">💰 Pool NTX-20 (CUP)</div>
                        <div class="bossGridValue cup">{$pp.pool_ntx20|default:0|number_format}</div>
                    </div>
                    <div class="bossGridItem">
                        <div class="bossGridLabel">💰 Pool UNTX-20 (QVAPAY)</div>
                        <div class="bossGridValue qvapay">{$pp.pool_untx20|default:0|number_format}</div>
                    </div>
                    <div class="bossGridItem">
                        <div class="bossGridLabel">💎 Premio NTX-20 (CUP)</div>
                        <div class="bossGridValue cup">{$pp.prize_ntx20|default:0|number_format}</div>
                    </div>
                    <div class="bossGridItem">
                        <div class="bossGridLabel">💎 Premio UNTX-20 (QVAPAY)</div>
                        <div class="bossGridValue qvapay">{$pp.prize_untx20|default:0|number_format}</div>
                    </div>
                    <div class="bossGridItem">
                        <div class="bossGridLabel">📊 Fee del proyecto</div>
                        <div class="bossGridValue">{$pp.fee_pct|default:5}%</div>
                    </div>
                </div>

                {* Vista del jugador: lo que TÚ vas a cobrar/cobrar según tu riel *}
                <div class="bossGrid" style="margin-top:4px;">
                    <div class="bossGridItem" style="grid-column: 1 / -1; background: rgba(74,255,136,0.08); border-color: rgba(74,255,136,0.4);">
                        <div class="bossGridLabel">🎯 Tu premio si ganas (riel {$pp.my_currency|default:$moneda}):</div>
                        <div class="bossGridValue mine">
                            {$pp.my_prize|default:0|number_format} {$pp.my_currency|default:$moneda}
                            <span style="font-size:10px;color:#8899aa;font-weight:normal;margin-left:8px;">
                                (pool {$pp.my_pool|default:0|number_format} − fee {$pp.my_fee|default:0|number_format})
                            </span>
                        </div>
                    </div>
                </div>

            {else}

                {* FREE: premio fijo, mostrar el riel del jugador *}
                {if $pp.my_prize > 0}
                    <div class="bossGrid" style="margin-top:4px;">
                        <div class="bossGridItem" style="grid-column: 1 / -1; background: rgba(74,255,136,0.08); border-color: rgba(74,255,136,0.4);">
                            <div class="bossGridLabel">🎁 Tu premio si ganas (riel {$pp.my_currency|default:$moneda}):</div>
                            <div class="bossGridValue mine">
                                {$pp.my_prize|default:0|number_format} {$pp.my_currency|default:$moneda}
                            </div>
                        </div>
                    </div>
                {/if}

                {* Recursos adicionales del premio mixto (universales) *}
                {if $event.prize_metal > 0 || $event.prize_crystal > 0 || $event.prize_deuterium > 0 || $event.prize_dark_matter > 0}
                    <div class="bossGrid" style="margin-top:4px;">
                        {if $event.prize_metal > 0}
                            <div class="bossGridItem">
                                <div class="bossGridLabel">🔩 Metal</div>
                                <div class="bossGridValue">{$event.prize_metal|number_format}</div>
                            </div>
                        {/if}
                        {if $event.prize_crystal > 0}
                            <div class="bossGridItem">
                                <div class="bossGridLabel">💠 Cristal</div>
                                <div class="bossGridValue">{$event.prize_crystal|number_format}</div>
                            </div>
                        {/if}
                        {if $event.prize_deuterium > 0}
                            <div class="bossGridItem">
                                <div class="bossGridLabel">⚗️ Deuterio</div>
                                <div class="bossGridValue">{$event.prize_deuterium|number_format}</div>
                            </div>
                        {/if}
                        {if $event.prize_dark_matter > 0}
                            <div class="bossGridItem">
                                <div class="bossGridLabel">🌑 Materia Oscura</div>
                                <div class="bossGridValue">{$event.prize_dark_matter|number_format}</div>
                            </div>
                        {/if}
                    </div>
                {/if}

            {/if}

            {* ─── COUNTDOWN ─── *}
            {if $event.status == 'scheduled'}
                <div class="bossCountdown" id="bossCountdown">
                    <div class="bossCountdownLabel">⏱️ El torneo comienza en:</div>
                    <div class="bossCountdownValue" id="bossCountdownValue">--</div>
                </div>
            {elseif $event.status == 'registration'}
                <div class="bossCountdown" id="bossCountdown">
                    <div class="bossCountdownLabel">📝 El registro cierra en:</div>
                    <div class="bossCountdownValue" id="bossCountdownValue">--</div>
                </div>
            {elseif $event.status == 'active'}
                <div class="bossCountdown" id="bossCountdown">
                    <div class="bossCountdownLabel">🔴 El torneo termina en:</div>
                    <div class="bossCountdownValue" id="bossCountdownValue">--</div>
                </div>
            {/if}

            {* Fechas exactas *}
            <div style="font-size:11px;color:#8899aa;text-align:center;margin-top:10px;">
                ⏰ Registro: {$event.registration_start|date_format:"%d/%m/%Y %H:%M"} → {$event.registration_end|date_format:"%d/%m/%Y %H:%M"}<br>
                ⚔️ Combate: {$event.start_time|date_format:"%d/%m/%Y %H:%M"} → {$event.end_time|date_format:"%d/%m/%Y %H:%M"}
            </div>
        </div>

        {* ─── INSCRIPCIÓN ─── *}
        {if $event.status == 'registration'}

            {if $pve_boss.my_ally_id == 0}
                <div class="bossCard crisis">
                    <h2>📝 Inscripción</h2>
                    <div class="bossEmpty">
                        ⚠️ <strong>Debes pertenecer a una alianza</strong> para participar.
                        <br><br>
                        Únete a una alianza para poder inscribirte en el torneo.
                    </div>
                </div>
            {elseif $pve_boss.my_registration}
                <div class="bossCard crisis">
                    <h2>✅ Tu alianza está inscrita</h2>
                    <div style="text-align:center;padding:14px;">
                        <span style="color:#88ffbb;font-size:15px;font-weight:bold;">
                            [{if $pve_boss.my_ally_tag}{$pve_boss.my_ally_tag}{else}?{/if}] {$pve_boss.my_ally_name}
                        </span>
                        <br><br>
                        <span style="color:#8899aa;font-size:12px;">
                            Esperando a que empiece el torneo. Serás notificado con las coordenadas del Devorador.
                        </span>
                    </div>
                </div>
            {elseif $pve_boss.can_register}
                <div class="bossCard crisis">
                    <h2>📝 Inscribe tu alianza</h2>
                    <div style="text-align:center;padding:10px 0;">
                        <p style="color:#aabbcc;margin-bottom:16px;">
                            Como <strong style="color:#ffcc33;">líder</strong> de tu alianza, puedes inscribirla en el torneo.
                            <br>

                            {* v4.0 — Coste dual-riel *}
                            {if $event.entry_mode == 'paid'}
                                {if $pp.entry_cost_real > 0}
                                    <span style="color:#ffee88;">
                                        💰 Coste en tu riel (<strong>{$pp.entry_cost_currency|default:$moneda}</strong>):
                                        <strong>{$pp.entry_cost_real|number_format}</strong>
                                    </span>
                                    <br>
                                    <span style="font-size:10px;color:#8899aa;">
                                        (Base NTX-20: {$pp.entry_cost_base|default:0|number_format})
                                    </span>
                                {else}
                                    <span style="color:#ffee88;">💰 Coste: <strong>{$event.entry_cost_ntx|default:50} NTX-20</strong> (base)</span>
                                {/if}
                            {else}
                                <span style="color:#88ffbb;">🆓 Inscripción gratuita</span>
                            {/if}
                        </p>

                        <form method="POST" action="game.php?page=pve&mode=registerAlliance">
                            <button type="submit" class="bossBtnBig">
                                📝 Inscribir mi alianza
                            </button>
                        </form>
                    </div>
                </div>
            {else}
                <div class="bossCard crisis">
                    <h2>📝 Inscripción</h2>
                    <div class="bossEmpty">
                        ℹ️ Solo el <strong>líder</strong> de la alianza puede inscribirla en el torneo.
                        <br><br>
                        <span style="font-size:11px;color:#667788;">
                            Pide a tu líder que la inscriba antes de que cierre el registro.
                        </span>
                    </div>
                </div>
            {/if}
        {/if}

        {* ─── FANTASMA ACTIVO DE MI ALIANZA ─── *}
        {if $event.status == 'active'}

            {if $pve_boss.my_active_ghost}
                {assign var=g value=$pve_boss.my_active_ghost}
                {assign var=hpPct value=0}
                {if $g.hp_max > 0}
                    {assign var=hpPct value=($g.hp_current / $g.hp_max * 100)|round:1}
                {/if}

                <div class="bossCard">
                    <h2>
                        <span>👻 Tu Devorador</span>
                        <span class="phase-badge phase-{$g.phase|default:1}">
                            {if $g.phase == 1}I — Acecho
                            {elseif $g.phase == 2}II — Enfurecido
                            {elseif $g.phase == 3}III — Último Aliento
                            {/if}
                        </span>
                    </h2>

                    <div style="text-align:center;padding:16px 0;">
                        <div class="bossGridLabel">📍 Coordenadas</div>
                        <div class="bossCoords">
                            [{$g.galaxy}:{$g.system}:{$g.planet}]
                        </div>
                    </div>

                    <div style="margin-top:14px;">
                        <div style="display:flex;justify-content:space-between;font-size:11px;color:#8899aa;margin-bottom:4px;">
                            <span>💚 HP del Jefe</span>
                            <span><strong style="color:#ff88ff;">{$g.hp_current|number_format}</strong> / {$g.hp_max|number_format} ({$hpPct}%)</span>
                        </div>
                        <div class="bossHpBar">
                            <div class="bossHpFill" style="width:{$hpPct}%;"></div>
                        </div>
                    </div>

                    {if $pve_boss.can_attack}
                        <a href="game.php?page=pve&mode=attackBossPrepare" class="bossBtnBig green">
                            🚀 ATACAR AL DEVORADOR
                        </a>
                    {else}
                        <div style="text-align:center;color:#8899aa;font-size:12px;margin-top:14px;">
                            ⚠️ No puedes atacar en este momento.
                        </div>
                    {/if}
                </div>
            {elseif $pve_boss.my_registration}
                <div class="bossCard">
                    <h2>♻️ Esperando respawn</h2>
                    <div class="bossEmpty">
                        Tu alianza ha destruido al Devorador.
                        <br><br>
                        Un nuevo Devorador aparecerá en breve. Recibirás un mensaje con las coordenadas.
                    </div>
                </div>
            {/if}
        {/if}

        {* ─── RANKING EN VIVO ─── *}
        <div class="bossCard">
            <h2>
                <span>🏆 Ranking de Alianzas</span>
                <span style="font-size:10px;color:#8899aa;font-weight:normal;">
                    (Actualización automática cada 10s)
                </span>
            </h2>

            {if $pve_boss.ranking|@count > 0}
                <table class="bossTable">
                    <thead>
                        <tr>
                            <th class="center" style="width:40px;">#</th>
                            <th>Alianza</th>
                            <th class="center">Daño</th>
                            <th class="center">% HP</th>
                            <th class="center">👻</th>
                            <th class="center">👥</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $pve_boss.ranking as $idx => $r}
                            <tr {if $r.ally_id == $pve_boss.my_ally_id}class="my-ally"{/if}>
                                <td class="center pos">{$idx+1}</td>
                                <td>
                                    <span style="color:#ff88ff;font-weight:bold;">
                                        [{if $r.ally_tag}{$r.ally_tag}{else}?{/if}]
                                    </span>
                                    {if $r.ally_name}{$r.ally_name|escape:'html'}{else}Alianza #{$r.ally_id}{/if}
                                    {if $r.ally_id == $pve_boss.my_ally_id}
                                        <span style="color:#ffcc33;font-size:10px;">← Tu alianza</span>
                                    {/if}
                                </td>
                                <td class="center damage">{$r.total_damage|default:0|number_format}</td>
                                <td class="center pct">{$r.pct_damage_total|default:0}%</td>
                                <td class="center" style="font-size:10px;color:#aabbcc;">
                                    💀 {$r.ghosts_killed|default:0} / {$r.ghosts_spawned|default:0}
                                </td>
                                <td class="center" style="color:#88ddff;">{$r.members_at_spawn|default:0}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {else}
                <div class="bossEmpty">
                    Aún no hay alianzas inscritas en este torneo.
                </div>
            {/if}
        </div>

        {* ─── CONTRIBUCIÓN INTERNA DE MI ALIANZA ─── *}
        {if $event.status == 'active' && $pve_boss.my_registration && $pve_boss.my_ally_contrib|@count > 0}
            <div class="bossCard">
                <h2>👥 Contribución de tu alianza</h2>
                <table class="bossTable">
                    <thead>
                        <tr>
                            <th>Jugador</th>
                            <th class="center">Daño</th>
                            <th class="center">Ataques</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $pve_boss.my_ally_contrib as $c}
                            <tr>
                                <td style="color:#88ddff;">{$c.username|escape:'html'}</td>
                                <td class="center damage">{$c.damage_done|default:0|number_format}</td>
                                <td class="center" style="color:#aabbcc;">{$c.attacks_count|default:0}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {/if}

    {/if}

    {* ─── INFO AL PIE ─── *}
    <p style="text-align:center;font-size:11px;color:#8899aa;margin-top:20px;">
        🚧 Torneo del Devorador — AstroIO v4.0 · Dual-Riel NTX-20 / UNTX-20 · Evento por alianzas
    </p>
</div>

{* ═══════════════════════════════════════════════════════════
 * JAVASCRIPT — Countdown + AJAX ranking
 * ✅ FIX v4.0: literal cerrado ANTES de {if}, reabierto DESPUÉS
 * ═══════════════════════════════════════════════════════════ *}
{if $pve_boss.event}
{literal}
<script type="text/javascript">
(function() {
	// ─── Countdown ───
	var countdownEl = document.getElementById('bossCountdownValue');

	if (countdownEl) {
		var endTime = 0;
{/literal}
		{if $pve_boss.event.status == 'scheduled'}
			endTime = {$pve_boss.event.registration_start|default:0};
		{elseif $pve_boss.event.status == 'registration'}
			endTime = {$pve_boss.event.registration_end|default:0};
		{elseif $pve_boss.event.status == 'active'}
			endTime = {$pve_boss.event.end_time|default:0};
		{/if}
{literal}

		function pad(n) { return (n < 10 ? '0' : '') + n; }

		function fmt(sec) {
			if (sec <= 0) return '¡Ahora!';
			var d = Math.floor(sec / 86400);
			var h = Math.floor((sec % 86400) / 3600);
			var m = Math.floor((sec % 3600) / 60);
			var s = sec % 60;

			if (d > 0) return d + 'd ' + pad(h) + 'h ' + pad(m) + 'm';
			if (h > 0) return pad(h) + 'h ' + pad(m) + 'm ' + pad(s) + 's';
			return pad(m) + 'm ' + pad(s) + 's';
		}

		function tick() {
			var now = Math.floor(Date.now() / 1000);
			var rem = endTime - now;
			countdownEl.textContent = fmt(rem);
			if (rem < 3600)       countdownEl.style.color = '#ff8888';
			else if (rem < 86400) countdownEl.style.color = '#ffee88';
			else                  countdownEl.style.color = '#ffee88';
		}

		tick();
		setInterval(tick, 1000);
	}

	// ─── AJAX: Ranking en vivo (opcional, dejamos hook para futuro) ───
	var eventId = {/literal}{$pve_boss.event.id|default:0}{literal};
	if (eventId > 0 && document.querySelector('.bossTable')) {
		setInterval(function() {
			var xhr = new XMLHttpRequest();
			xhr.open('GET', 'game.php?page=pve&mode=bossRankingJson&event_id=' + eventId, true);
			xhr.onreadystatechange = function() {
				if (xhr.readyState === 4 && xhr.status === 200) {
					// Hook reservado: en el futuro se puede parsear el JSON
					// y actualizar el DOM del ranking sin recargar la página.
				}
			};
			xhr.send();
		}, 10000);
	}
})();
</script>
{/literal}
{/if}

{/block}