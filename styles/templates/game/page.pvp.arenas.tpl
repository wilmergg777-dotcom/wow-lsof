{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   PvP — Arenas
   AstroIO v3.1 — Doble Riel (NTX-20 / UNTX-20)
   Prefijo: .astropvp_
   FIX v3.1:
     - Badge de saldo del riel del jugador arriba
     - Precios y botes con {$moneda} dinámica (ya calculados en PHP)
     - Textos "NTX-20" hardcodeados reemplazados por {$moneda}
     - CSS preservado 100% + estilos para balance badge
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

/* ─── TÍTULO ────────────────────────────────────────────── */
.astropvp_title {
    color: #ff6666;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(239, 68, 68, 0.6);
    letter-spacing: 1px;
}

/* ─── 🆕 BALANCE BADGE (riel del jugador) ───────────────── */
.astropvp_balance_box {
    max-width: 900px;
    margin: 0 auto 18px;
    text-align: center;
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
    min-width: 120px;
    max-width: 160px;
    padding: 10px 16px;
    border-radius: 10px;
    font-size: 12px;
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

.astropvp_tab.main {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropvp_tab.main:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropvp_tab.arenas {
    background: linear-gradient(135deg, #aa2222, #ef4444);
    color: var(--text-title);
    border: 1px solid var(--accent-red);
    box-shadow: 0 4px 14px rgba(239, 68, 68, 0.5);
}
.astropvp_tab.arenas:hover {
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.7);
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

/* ─── FLASH MESSAGE ─────────────────────────────────────── */
.astropvp_flash {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 12px 18px;
    border-radius: 10px;
    text-align: center;
    font-size: 13px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropvp_flash.success {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffbb;
}
.astropvp_flash.error {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: #ff8888;
}

/* ─── BOTÓN CREAR ARENA ────────────────────────────────── */
.astropvp_create_wrap {
    max-width: 900px;
    margin: 0 auto 20px;
    text-align: center;
}
.astropvp_btn_create {
    display: inline-block;
    padding: 14px 40px;
    background: linear-gradient(135deg, #aa2222, #ef4444);
    color: var(--text-title);
    border: 1px solid var(--accent-red);
    border-radius: 10px;
    font-size: 14px;
    font-weight: bold;
    text-decoration: none;
    box-shadow: 0 4px 14px rgba(239, 68, 68, 0.5);
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropvp_btn_create:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.7);
}

/* ─── PANELES ───────────────────────────────────────────── */
.astropvp_panel {
    max-width: 900px;
    margin: 0 auto 30px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(239, 68, 68, 0.4);
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropvp_panel.available {
    margin: 0 auto;
    border-color: rgba(251, 191, 36, 0.4);
}

.astropvp_panel_title {
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(0, 0, 0, 0.4);
}
.astropvp_panel.mine .astropvp_panel_title       { color: #ff8888; }
.astropvp_panel.available .astropvp_panel_title  { color: #ffdd88; }

/* ─── GRID DE ARENAS ────────────────────────────────────── */
.astropvp_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 12px;
}

.astropvp_item {
    padding: 14px;
    border-radius: 10px;
    transition: 0.25s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    cursor: help;
    min-width: 0;
    overflow: hidden;
}
.astropvp_item:hover {
    transform: translateY(-2px);
}

.astropvp_item.mine {
    background: rgba(255, 100, 100, 0.06);
    border-left: 3px solid #ff6666;
}
.astropvp_item.mine:hover {
    box-shadow: 0 4px 16px rgba(239, 68, 68, 0.25);
}

.astropvp_item.available {
    background: rgba(251, 191, 36, 0.06);
    border-left: 3px solid var(--accent-gold);
}
.astropvp_item.available:hover {
    box-shadow: 0 4px 16px rgba(251, 191, 36, 0.25);
}

.astropvp_item_head {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}

.astropvp_item_name {
    font-weight: bold;
    font-family: 'Courier New', monospace;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.astropvp_item.mine .astropvp_item_name      { color: #ff8888; text-shadow: 0 0 6px rgba(239, 68, 68, 0.3); }
.astropvp_item.available .astropvp_item_name { color: #ffdd88; text-shadow: 0 0 6px rgba(251, 191, 36, 0.3); }

.astropvp_item_mode {
    font-size: 11px;
    color: #aabbcc;
    white-space: nowrap;
    flex-shrink: 0;
}

.astropvp_item_body {
    font-size: 12px;
    color: #aabbcc;
    line-height: 1.7;
}
.astropvp_item_body b {
    font-family: 'Courier New', monospace;
}
.astropvp_item_body b.status    { color: #ffee88; }
.astropvp_item_body b.players   { color: #88ffbb; }
.astropvp_item_body b.pool      { color: #ffee88; }
.astropvp_item_body b.entry     { color: #ffee88; }
/* NOTA: b.time tiene color dinámico inline (countdown_color) */

.astropvp_item_actions {
    margin-top: 12px;
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

/* ─── BOTONES DE ACCIÓN ─────────────────────────────────── */
.astropvp_action_btn {
    flex: 1;
    min-width: 100px;
    padding: 7px 12px;
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
    text-decoration: none;
    text-align: center;
    cursor: pointer;
    transition: all 0.25s ease;
    font-family: inherit;
    border: 1px solid transparent;
    display: inline-block;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astropvp_action_btn.view {
    background: rgba(100, 150, 255, 0.2);
    color: #88bbff;
    border-color: rgba(100, 150, 255, 0.5);
}
.astropvp_action_btn.view:hover {
    background: rgba(100, 150, 255, 0.3);
    box-shadow: 0 0 10px rgba(100, 150, 255, 0.4);
    transform: translateY(-1px);
}

.astropvp_action_btn.cancel {
    background: rgba(239, 68, 68, 0.2);
    color: #ff8888;
    border-color: rgba(239, 68, 68, 0.5);
    width: 100%;
}
.astropvp_action_btn.cancel:hover {
    background: rgba(239, 68, 68, 0.3);
    box-shadow: 0 0 10px rgba(239, 68, 68, 0.4);
    transform: translateY(-1px);
}

.astropvp_action_btn.claim {
    background: linear-gradient(135deg, #ccaa22, #fbbf24);
    color: #1a1000;
    border-color: var(--accent-gold);
    width: 100%;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.astropvp_action_btn.claim:hover {
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.5);
    transform: translateY(-2px);
}

.astropvp_action_btn.join {
    width: 100%;
    padding: 8px 12px;
    font-size: 12px;
    background: linear-gradient(135deg, #aa2222, #ef4444);
    color: var(--text-title);
    border-color: var(--accent-red);
}
.astropvp_action_btn.join:hover {
    box-shadow: 0 0 12px rgba(239, 68, 68, 0.5);
    transform: translateY(-2px);
}

/* ─── FORM INLINE ───────────────────────────────────────── */
.astropvp_inline_form {
    flex: 1;
    min-width: 100px;
    margin: 0;
}

.astropvp_inline_form.full {
    flex: 1 1 100%;
    margin-top: 12px;
    margin-bottom: 0;
}

/* ─── EMPTY STATE ───────────────────────────────────────── */
.astropvp_empty {
    text-align: center;
    color: var(--text-muted);
    font-size: 13px;
    padding: 30px 0;
}
.astropvp_empty_sub {
    font-size: 11px;
    color: #667788;
}

/* ─── FOOTER ────────────────────────────────────────────── */
.astropvp_footer {
    text-align: center;
    font-size: 11px;
    color: var(--text-muted);
    margin-top: 30px;
}

/* ─── RESPONSIVE ────────────────────────────────────────── */
@media (max-width: 1200px) {
    .astropvp_grid {
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
        font-size: 11px;
        padding: 9px 12px;
    }
    .astropvp_grid {
        grid-template-columns: 1fr;
    }
    .astropvp_panel {
        padding: 14px;
        max-width: 100%;
    }
    .astropvp_btn_create {
        width: 100%;
        padding: 12px 20px;
    }
    .astropvp_action_btn {
        min-width: 80px;
        font-size: 10px;
    }
    .astropvp_balance_badge {
        font-size: 12px;
        padding: 6px 14px;
    }
}
</style>

<div class="astropvp_wrap">
    <h1 class="astropvp_title">🏟️ Arenas PvP</h1>

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

    {* FLASH MESSAGE *}
    {if $flash}
        <div class="astropvp_flash {if $flash.type == 'success'}success{else}error{/if}">
            {$flash.msg}
        </div>
    {/if}

    {* BOTÓN CREAR ARENA *}
    {if $can_create}
        <div class="astropvp_create_wrap">
            <a href="game.php?page=pvp&mode=createArena" class="astropvp_btn_create">
                ➕ Crear nueva arena
            </a>
        </div>
    {/if}

    {* MIS ARENAS *}
    {if $my_arenas|@count > 0}
        <div class="astropvp_panel mine">
            <h2 class="astropvp_panel_title">⚔️ Mis arenas</h2>
            <div class="astropvp_grid">
                {foreach $my_arenas as $a}
                    <div class="astropvp_item mine">
                        <div class="astropvp_item_head">
                            <b class="astropvp_item_name">Arena #{$a.id}</b>
                            <span class="astropvp_item_mode">{$a.mode_label}</span>
                        </div>
                        <div class="astropvp_item_body">
                            <div>Estado: <b class="status">{$a.status}</b></div>
                            <div>Jugadores: <b class="players">{$a.current_players}/{$a.max_players}</b></div>
                            <div>Bote: <b class="pool">{$a.pool_fmt} {$moneda}</b></div>
                            <div>Tiempo: <b style="color: {$a.countdown_color};">{$a.time_left_fmt}</b></div>
                        </div>
                        <div class="astropvp_item_actions">
                            <a href="game.php?page=pvp&mode=viewArena&arena_id={$a.id}" class="astropvp_action_btn view">
                                🔍 Ver
                            </a>
                            {if $a.can_cancel}
                                <form method="POST" action="game.php?page=pvp&mode=cancelArena" class="astropvp_inline_form">
                                    <input type="hidden" name="arena_id" value="{$a.id}">
                                    <button type="submit" class="astropvp_action_btn cancel" onclick="return confirm('¿Cancelar esta arena? Se devolverá el {$moneda} a todos.');">
                                        ❌ Cancelar
                                    </button>
                                </form>
                            {/if}
                            {if $a.i_can_claim}
                                <form method="POST" action="game.php?page=pvp&mode=claimPrize" class="astropvp_inline_form">
                                    <input type="hidden" name="arena_id" value="{$a.id}">
                                    <button type="submit" class="astropvp_action_btn claim">
                                        🎁 Reclamar
                                    </button>
                                </form>
                            {/if}
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
    {/if}

    {* ARENAS DISPONIBLES *}
    <div class="astropvp_panel available">
        <h2 class="astropvp_panel_title">🏟️ Arenas disponibles</h2>

        {if $available_arenas|@count > 0}
            <div class="astropvp_grid">
                {foreach $available_arenas as $a}
                    <div class="astropvp_item available">
                        <div class="astropvp_item_head">
                            <b class="astropvp_item_name">Arena #{$a.id}</b>
                            <span class="astropvp_item_mode">{$a.mode_label}</span>
                        </div>
                        <div class="astropvp_item_body">
                            <div>Jugadores: <b class="players">{$a.current_players}/{$a.max_players}</b></div>
                            <div>Entrada: <b class="entry">{$a.fee_fmt} {$moneda}</b></div>
                            <div>Tiempo: <b style="color: {$a.countdown_color};">{$a.time_left_fmt}</b></div>
                        </div>
                        <form method="POST" action="game.php?page=pvp&mode=joinArena" class="astropvp_inline_form full">
                            <input type="hidden" name="arena_id" value="{$a.id}">
                            <button type="submit" class="astropvp_action_btn join">
                                ⚔️ Unirse ({$a.fee_fmt} {$moneda})
                            </button>
                        </form>
                    </div>
                {/foreach}
            </div>
        {else}
            <p class="astropvp_empty">
                No hay arenas abiertas en este momento.<br>
                <span class="astropvp_empty_sub">Crea la primera arena y espera a que se una alguien.</span>
            </p>
        {/if}
    </div>

    <p class="astropvp_footer">
        🏟️ Precios: 1v1 libre ({$prices.1v1_min}-{$prices.1v1_max} {$moneda}) · 2v2: {$prices.2v2} {$moneda} · 3v3: {$prices.3v3} {$moneda}
    </p>
</div>

{/block}