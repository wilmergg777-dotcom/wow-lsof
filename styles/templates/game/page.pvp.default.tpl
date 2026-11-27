{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.pvp.default.tpl === *}
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
   PvP — Panel Principal
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_
   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Textos "NTX-20" dinámicos con {$moneda}
     - CSS preservado 100% + nuevos estilos para balance badge
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

/* ─── RESET GLOBAL ──────────────────────────────────────── */
.astropvp_wrap *,
.astropvp_wrap *::before,
.astropvp_wrap *::after {
    box-sizing: border-box;
}

/* ─── WRAPPER ───────────────────────────────────────────── */
.astropvp_wrap {
    padding: 20px;
    color: var(--text-main);
}

/* ─── TÍTULOS ───────────────────────────────────────────── */
.astropvp_title {
    color: #ff6666;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(239, 68, 68, 0.6);
    letter-spacing: 1px;
}

.astropvp_subtitle {
    text-align: center;
    color: var(--text-muted);
    margin-bottom: 30px;
    font-size: 12px;
}

/* ─── 🆕 BALANCE BADGE (riel del jugador) ───────────────── */
.astropvp_balance_box {
    text-align: center;
    margin-bottom: 18px;
}

.astropvp_balance_badge {
    display: inline-block;
    padding: 8px 20px;
    border-radius: 10px;
    font-size: 13px;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    background: linear-gradient(135deg, rgba(0, 200, 100, 0.15), rgba(0, 150, 255, 0.10));
    color: #cbd5e1;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.astropvp_balance_badge b {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-weight: 800;
    letter-spacing: 0.5px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.4);
}

.astropvp_balance_badge .moneda {
    color: #88ddff;
    font-weight: 700;
    letter-spacing: 0.5px;
}

/* ─── TABS ──────────────────────────────────────────────── */
.astropvp_tabs {
    max-width: 900px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropvp_tab {
    flex: 1;
    min-width: 140px;
    max-width: 180px;
    padding: 12px 18px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
    text-decoration: none;
    transition: all 0.25s ease;
    display: inline-block;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_tab:hover {
    transform: translateY(-2px);
}

/* Variantes de tabs */
.astropvp_tab.main {
    background: linear-gradient(135deg, #aa2222, #ef4444);
    color: var(--text-title);
    border: 1px solid var(--accent-red);
    box-shadow: 0 4px 14px rgba(239, 68, 68, 0.5);
}
.astropvp_tab.main:hover {
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.7);
}

.astropvp_tab.arenas {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_tab.arenas:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_tab.tournaments {
    background: rgba(251, 191, 36, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(251, 191, 36, 0.5);
}
.astropvp_tab.tournaments:hover {
    background: rgba(251, 191, 36, 0.25);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

.astropvp_tab.history {
    background: rgba(100, 150, 255, 0.15);
    color: #88bbff;
    border: 1px solid rgba(100, 150, 255, 0.5);
}
.astropvp_tab.history:hover {
    background: rgba(100, 150, 255, 0.25);
    box-shadow: 0 0 14px rgba(100, 150, 255, 0.4);
}

.astropvp_tab.achievements {
    background: rgba(251, 191, 36, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(251, 191, 36, 0.5);
}
.astropvp_tab.achievements:hover {
    background: rgba(251, 191, 36, 0.25);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

.astropvp_tab.profile {
    background: rgba(204, 100, 255, 0.15);
    color: #dd99ff;
    border: 1px solid rgba(204, 100, 255, 0.5);
}
.astropvp_tab.profile:hover {
    background: rgba(204, 100, 255, 0.25);
    box-shadow: 0 0 14px rgba(204, 100, 255, 0.4);
}

/* ─── CARDS GRID ────────────────────────────────────────── */
.astropvp_cards_grid {
    max-width: 900px;
    margin: 0 auto 25px;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 15px;
}

.astropvp_card {
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 14px;
    padding: 20px;
    text-align: center;
    transition: 0.25s ease;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astropvp_card:hover {
    transform: translateY(-3px);
}

.astropvp_card.arenas {
    background: linear-gradient(160deg, rgba(60, 15, 15, 0.75) 0%, rgba(90, 25, 25, 0.75) 100%);
    border: 2px solid rgba(239, 68, 68, 0.5);
}
.astropvp_card.arenas:hover {
    box-shadow: 0 8px 30px rgba(239, 68, 68, 0.4), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_card.tournaments {
    background: linear-gradient(160deg, rgba(60, 40, 10, 0.75) 0%, rgba(90, 60, 15, 0.75) 100%);
    border: 2px solid rgba(251, 191, 36, 0.5);
}
.astropvp_card.tournaments:hover {
    box-shadow: 0 8px 30px rgba(251, 191, 36, 0.4), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_card.myarena {
    background: linear-gradient(160deg, rgba(30, 30, 60, 0.75) 0%, rgba(40, 40, 90, 0.75) 100%);
    border: 2px solid rgba(100, 150, 255, 0.5);
}
.astropvp_card.myarena:hover {
    box-shadow: 0 8px 30px rgba(100, 150, 255, 0.4), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_card.achievements {
    background: linear-gradient(160deg, rgba(60, 20, 60, 0.75) 0%, rgba(90, 30, 90, 0.75) 100%);
    border: 2px solid rgba(204, 100, 255, 0.5);
}
.astropvp_card.achievements:hover {
    box-shadow: 0 8px 30px rgba(204, 100, 255, 0.4), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_card_icon {
    font-size: 32px;
    margin-bottom: 8px;
    display: block;
}

.astropvp_card_title {
    font-size: 14px;
    font-weight: bold;
    margin-bottom: 12px;
    letter-spacing: 0.5px;
}
.astropvp_card.arenas .astropvp_card_title       { color: #ff8888; }
.astropvp_card.tournaments .astropvp_card_title  { color: #ffdd88; }
.astropvp_card.myarena .astropvp_card_title      { color: #88bbff; }
.astropvp_card.achievements .astropvp_card_title { color: #dd99ff; }

.astropvp_card_body {
    font-size: 11px;
    color: #aabbcc;
    line-height: 1.6;
}
.astropvp_card_body b { font-family: 'Courier New', monospace; }
.astropvp_card.arenas .astropvp_card_body b       { color: #ffaa88; }
.astropvp_card.tournaments .astropvp_card_body b  { color: #ffee88; }
.astropvp_card.myarena .astropvp_card_body b      { color: #88bbff; }
.astropvp_card.achievements .astropvp_card_body b { color: #dd99ff; }

.astropvp_card_body b.hi-red    { color: #ff6666; }
.astropvp_card_body b.hi-gold   { color: #ffee88; }
.astropvp_card_body b.hi-green  { color: #88ffbb; }
.astropvp_card_body b.hi-blue   { color: #88bbff; }
.astropvp_card_body b.hi-purple { color: #dd99ff; }

.astropvp_card_empty {
    font-size: 12px;
    color: var(--text-muted);
    padding: 10px 0;
    font-style: italic;
}

/* ─── BOTONES DE CARD ───────────────────────────────────── */
.astropvp_btn {
    display: inline-block;
    margin-top: 12px;
    padding: 8px 20px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    text-decoration: none;
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astropvp_btn.arenas {
    background: linear-gradient(135deg, #aa2222, #ef4444);
    color: var(--text-title);
    border: 1px solid var(--accent-red);
}
.astropvp_btn.arenas:hover {
    box-shadow: 0 0 14px rgba(239, 68, 68, 0.5);
    transform: translateY(-2px);
}

.astropvp_btn.tournaments {
    background: linear-gradient(135deg, #ccaa22, #fbbf24);
    color: #1a1000;
    border: 1px solid var(--accent-gold);
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astropvp_btn.tournaments:hover {
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.5);
    transform: translateY(-2px);
}

.astropvp_btn.myarena {
    background: linear-gradient(135deg, #2244cc, #6688ff);
    color: var(--text-title);
    border: 1px solid #6688ff;
}
.astropvp_btn.myarena:hover {
    box-shadow: 0 0 14px rgba(102, 136, 255, 0.5);
    transform: translateY(-2px);
}

.astropvp_btn.achievements {
    background: linear-gradient(135deg, #aa44ff, #dd88ff);
    color: var(--text-title);
    border: 1px solid #dd88ff;
}
.astropvp_btn.achievements:hover {
    box-shadow: 0 0 14px rgba(221, 136, 255, 0.5);
    transform: translateY(-2px);
}

/* ─── STATS BOX ─────────────────────────────────────────── */
.astropvp_stats_box {
    max-width: 900px;
    margin: 0 auto;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(239, 68, 68, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_stats_box_title {
    color: #ff8888;
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
}

.astropvp_stats_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(0, 1fr));
    gap: 12px;
}

.astropvp_stat {
    padding: 10px;
    border-radius: 8px;
    text-align: center;
    transition: 0.25s ease;
    cursor: help;
    min-width: 0;
}
.astropvp_stat:hover {
    transform: translateY(-2px);
}

.astropvp_stat.points       { background: rgba(255, 100, 100, 0.08); border: 1px solid rgba(239, 68, 68, 0.3); }
.astropvp_stat.wins         { background: rgba(0, 200, 100, 0.08);  border: 1px solid rgba(74, 255, 136, 0.3); }
.astropvp_stat.losses       { background: rgba(255, 50, 50, 0.08);  border: 1px solid rgba(239, 68, 68, 0.3); }
.astropvp_stat.ntx          { background: rgba(251, 191, 36, 0.08); border: 1px solid rgba(251, 191, 36, 0.3); }
.astropvp_stat.tournaments  { background: rgba(100, 150, 255, 0.08); border: 1px solid rgba(100, 150, 255, 0.3); }
.astropvp_stat.streak       { background: rgba(204, 100, 255, 0.08); border: 1px solid rgba(204, 100, 255, 0.3); }

.astropvp_stat_label {
    font-size: 11px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astropvp_stat_value {
    font-size: 20px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    margin-top: 4px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_stat.points .astropvp_stat_value       { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.astropvp_stat.wins .astropvp_stat_value         { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.4); }
.astropvp_stat.losses .astropvp_stat_value       { color: #ff6666; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.astropvp_stat.ntx .astropvp_stat_value          { color: #ffee88; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }
.astropvp_stat.tournaments .astropvp_stat_value  { color: #88bbff; text-shadow: 0 0 8px rgba(100, 150, 255, 0.4); }
.astropvp_stat.streak .astropvp_stat_value       { color: #dd99ff; text-shadow: 0 0 8px rgba(204, 100, 255, 0.4); }

/* ─── FOOTER ────────────────────────────────────────────── */
.astropvp_footer {
    text-align: center;
    font-size: 11px;
    color: var(--text-muted);
    margin-top: 30px;
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_cards_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media (max-width: 720px) {
    .astropvp_wrap {
        padding: 12px;
    }
    .astropvp_title {
        font-size: 18px;
    }
    .astropvp_tab {
        max-width: 100%;
        min-width: 100px;
        font-size: 12px;
        padding: 10px 12px;
    }
    .astropvp_cards_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_stats_grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
    .astropvp_stat_value {
        font-size: 16px;
    }
    .astropvp_stats_box {
        padding: 14px;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_wrap">
    <h1 class="astropvp_title">⚔️ SISTEMA PvP — AstroIO</h1>

    {* 🆕 BADGE DE SALDO DEL RIEL DEL JUGADOR *}
    <div class="astropvp_balance_box">
        <span class="astropvp_balance_badge">
            💲 Tu saldo: <b>{$saldo_actual|number_format}</b>
            <span class="moneda">{$moneda}</span>
        </span>
    </div>

    {* MENÚ DE PESTAÑAS *}
    <div class="astropvp_tabs">
        <a href="game.php?page=pvp" class="astropvp_tab main">
            🏠 Panel
        </a>
        <a href="game.php?page=pvp&mode=arenas" class="astropvp_tab arenas">
            🏟️ Arenas
        </a>
        <a href="game.php?page=pvp&mode=tournaments" class="astropvp_tab tournaments">
            🏆 Torneos
        </a>
        <a href="game.php?page=pvp&mode=history" class="astropvp_tab history">
            📜 Historial
        </a>
        <a href="game.php?page=pvp&mode=achievements" class="astropvp_tab achievements">
            🏅 Logros
        </a>
        <a href="game.php?page=pvp&mode=profile" class="astropvp_tab profile">
            👤 Perfil
        </a>
    </div>

    <p class="astropvp_subtitle">
        Bienvenido al sistema PvP. Participa en arenas y torneos para ganar {$moneda} y escalar en el ranking.
    </p>

    {* CARDS DE RESUMEN *}
    <div class="astropvp_cards_grid">

        {* CARD ARENAS *}
        <div class="astropvp_card arenas">
            <span class="astropvp_card_icon">🏟️</span>
            <div class="astropvp_card_title">ARENAS</div>
            <div class="astropvp_card_body">
                <div>Esperando: <b>{$pvp.arenas_waiting}</b></div>
                <div>Activas: <b class="hi-red">{$pvp.arenas_active}</b></div>
            </div>
            <a href="game.php?page=pvp&mode=arenas" class="astropvp_btn arenas">
                Ver arenas
            </a>
        </div>

        {* CARD TORNEOS *}
        <div class="astropvp_card tournaments">
            <span class="astropvp_card_icon">🏆</span>
            <div class="astropvp_card_title">TORNEOS</div>
            {if $active_tournament}
                <div class="astropvp_card_body">
                    <div>Tipo: <b class="hi-gold">{$active_tournament.type}</b></div>
                    <div>Estado: <b>{$active_tournament.status}</b></div>
                    <div>Jugadores: <b class="hi-gold">{$active_tournament.current_players}/{$active_tournament.max_players}</b></div>
                </div>
            {else}
                <div class="astropvp_card_empty">
                    No hay torneo activo
                </div>
            {/if}
            <a href="game.php?page=pvp&mode=tournaments" class="astropvp_btn tournaments">
                Ver torneos
            </a>
        </div>

        {* CARD MI ARENA *}
        <div class="astropvp_card myarena">
            <span class="astropvp_card_icon">⚔️</span>
            <div class="astropvp_card_title">MI ARENA</div>
            {if $my_arena}
                <div class="astropvp_card_body">
                    <div>Modo: <b class="hi-blue">{$my_arena.mode_label}</b></div>
                    <div>Estado: <b>{$my_arena.status}</b></div>
                    <div>Tiempo: <b class="hi-green">{$my_arena.time_left_fmt}</b></div>
                </div>
            {else}
                <div class="astropvp_card_empty">
                    No estás en ninguna arena
                </div>
            {/if}
            <a href="game.php?page=pvp&mode=arenas" class="astropvp_btn myarena">
                Ir a arenas
            </a>
        </div>

        {* CARD LOGROS *}
        <div class="astropvp_card achievements">
            <span class="astropvp_card_icon">🏅</span>
            <div class="astropvp_card_title">LOGROS</div>
            <div class="astropvp_card_body">
                <div>Desbloqueados: <b class="hi-purple">{$ach_unlocked}</b> / {$ach_total}</div>
            </div>
            <a href="game.php?page=pvp&mode=achievements" class="astropvp_btn achievements">
                Ver logros
            </a>
        </div>

    </div>

    {* ESTADÍSTICAS DEL JUGADOR *}
    <div class="astropvp_stats_box">
        <h2 class="astropvp_stats_box_title">📊 Mis estadísticas</h2>
        <div class="astropvp_stats_grid">
            <div class="astropvp_stat points">
                <div class="astropvp_stat_label">Puntos PvP</div>
                <div class="astropvp_stat_value">{$my_stats.points}</div>
            </div>
            <div class="astropvp_stat wins">
                <div class="astropvp_stat_label">Victorias</div>
                <div class="astropvp_stat_value">{$my_stats.wins}</div>
            </div>
            <div class="astropvp_stat losses">
                <div class="astropvp_stat_label">Derrotas</div>
                <div class="astropvp_stat_value">{$my_stats.losses}</div>
            </div>
            <div class="astropvp_stat ntx">
                <div class="astropvp_stat_label">{$moneda} ganados</div>
                <div class="astropvp_stat_value">{$my_stats.ntx_won}</div>
            </div>
            <div class="astropvp_stat tournaments">
                <div class="astropvp_stat_label">Torneos</div>
                <div class="astropvp_stat_value">{$my_stats.tournaments_won}</div>
            </div>
            <div class="astropvp_stat streak">
                <div class="astropvp_stat_label">Mejor racha</div>
                <div class="astropvp_stat_value">{$my_stats.best_streak}</div>
            </div>
        </div>
    </div>

    <p class="astropvp_footer">
        ⚔️ Sistema PvP v2.0 — AstroIO · Doble Riel (NTX-20 / UNTX-20)
    </p>
</div>

{/block}