{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   PvE — Logros
   AstroIO v4.0 — Glassmorphism + Acento Dorado + Dual-Riel
   Prefijo: .astropve_
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

.astropve_wrap {
    padding: 20px;
    color: var(--text-main);
}

.astropve_title {
    color: #ffdd88;
    text-align: center;
    font-size: 24px;
    margin-bottom: 20px;
    text-shadow: 0 0 14px rgba(251, 191, 36, 0.6);
    letter-spacing: 1px;
}

/* ─── v4.0 — BADGE DE SALDO ────────────────────────────── */
.astropve_balance_bar {
    max-width: 900px;
    margin: 0 auto 18px;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.astropve_balance_badge {
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
.astropve_balance_badge:hover { transform: translateY(-1px); }

.astropve_balance_badge.cup {
    border: 1px solid rgba(251, 191, 36, 0.6);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
    color: #ffee88;
}
.astropve_balance_badge.cup:hover {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.5);
}

.astropve_balance_badge.qvapay {
    border: 1px solid rgba(0, 224, 255, 0.6);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
    color: #88ffff;
}
.astropve_balance_badge.qvapay:hover {
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
}

.astropve_balance_label {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astropve_balance_value {
    font-size: 17px;
    font-weight: bold;
    letter-spacing: 0.5px;
}

.astropve_balance_currency {
    font-size: 12px;
    opacity: 0.9;
    font-weight: bold;
    letter-spacing: 0.5px;
}

/* ─── TABS ─────────────────────────────────────────────── */
.astropve_tabs {
    max-width: 1100px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropve_tab {
    flex: 1;
    min-width: 160px;
    max-width: 220px;
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
.astropve_tab:hover {
    transform: translateY(-2px);
}

.astropve_tab.main {
    background: rgba(139, 92, 246, 0.15);
    color: #dd99ff;
    border: 1px solid rgba(139, 92, 246, 0.5);
}
.astropve_tab.main:hover {
    background: rgba(139, 92, 246, 0.25);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.4);
}

.astropve_tab.empire {
    background: rgba(255, 100, 50, 0.15);
    color: #ffaa88;
    border: 1px solid rgba(255, 100, 50, 0.5);
}
.astropve_tab.empire:hover {
    background: rgba(255, 100, 50, 0.25);
    box-shadow: 0 0 14px rgba(255, 100, 50, 0.4);
}

.astropve_tab.boss {
    background: rgba(80, 180, 255, 0.15);
    color: #88ccff;
    border: 1px solid rgba(80, 180, 255, 0.5);
}
.astropve_tab.boss:hover {
    background: rgba(80, 180, 255, 0.25);
    box-shadow: 0 0 14px rgba(80, 180, 255, 0.4);
}

.astropve_tab.bastion {
    background: rgba(50, 150, 255, 0.15);
    color: #99ddff;
    border: 1px solid rgba(50, 150, 255, 0.5);
}
.astropve_tab.bastion:hover {
    background: rgba(50, 150, 255, 0.25);
    box-shadow: 0 0 14px rgba(50, 150, 255, 0.4);
}

.astropve_tab.achievements {
    background: linear-gradient(135deg, #aa6600, #fbbf24);
    color: #1a1000;
    border: 1px solid var(--accent-gold);
    box-shadow: 0 4px 14px rgba(251, 191, 36, 0.5);
}
.astropve_tab.achievements:hover {
    box-shadow: 0 6px 20px rgba(251, 191, 36, 0.7);
}

/* ─── STATS GRID ───────────────────────────────────────── */
.astropve_stats_grid {
    max-width: 900px;
    margin: 0 auto 25px;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 15px;
}

.astropve_stat {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-radius: 12px;
    padding: 18px;
    text-align: center;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.25s ease;
}
.astropve_stat:hover {
    transform: translateY(-2px);
}

.astropve_stat.streak  { border: 1px solid rgba(251, 191, 36, 0.4); }
.astropve_stat.total   { border: 1px solid rgba(74, 255, 136, 0.4); }
.astropve_stat.last    { border: 1px solid rgba(0, 224, 255, 0.4); }

.astropve_stat.streak:hover  { box-shadow: 0 8px 24px rgba(251, 191, 36, 0.25); }
.astropve_stat.total:hover   { box-shadow: 0 8px 24px rgba(74, 255, 136, 0.25); }
.astropve_stat.last:hover    { box-shadow: 0 8px 24px rgba(0, 224, 255, 0.25); }

.astropve_stat_label {
    font-size: 11px;
    color: var(--text-muted);
    margin-bottom: 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astropve_stat_value {
    font-size: 32px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}
.astropve_stat.streak .astropve_stat_value { color: #ffdd44; text-shadow: 0 0 14px rgba(251, 191, 36, 0.5); }
.astropve_stat.total  .astropve_stat_value { color: #88ffbb; text-shadow: 0 0 14px rgba(74, 255, 136, 0.4); }
.astropve_stat.last   .astropve_stat_value { color: #88ddff; font-size: 22px; margin-top: 4px; text-shadow: 0 0 12px rgba(0, 224, 255, 0.4); }

.astropve_stat_sub {
    font-size: 11px;
    color: var(--text-muted);
    margin-top: 6px;
}

/* ─── SECCIÓN LOGROS ───────────────────────────────────── */
.astropve_section {
    max-width: 900px;
    margin: 0 auto;
}
.astropve_section_title {
    color: #ffdd88;
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
.astropve_section_count {
    display: inline-block;
    margin-left: 8px;
    padding: 2px 10px;
    background: rgba(251, 191, 36, 0.25);
    border: 1px solid rgba(251, 191, 36, 0.6);
    border-radius: 10px;
    font-size: 11px;
    color: #ffee88;
}

/* ─── SUB-HEADER POR TIPO ──────────────────────────────── */
.astropve_subheader {
    margin: 22px 0 14px;
    padding: 10px 16px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: bold;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astropve_subheader.survival {
    background: rgba(139, 92, 246, 0.12);
    border-left: 4px solid #dd99ff;
    color: #dd99ff;
}
.astropve_subheader.tournament {
    background: rgba(255, 136, 255, 0.12);
    border-left: 4px solid var(--accent-magenta);
    color: var(--accent-magenta);
}
.astropve_subheader.bastion {
    background: rgba(50, 150, 255, 0.12);
    border-left: 4px solid #99ddff;
    color: #99ddff;
}
.astropve_subheader.other {
    background: rgba(148, 163, 184, 0.12);
    border-left: 4px solid var(--text-muted);
    color: var(--text-muted);
}

/* ─── CARD LOGRO ───────────────────────────────────────── */
.astropve_ach {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 18px;
    margin-bottom: 15px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.25s ease;
}
.astropve_ach:hover {
    transform: translateY(-2px);
}
.astropve_ach.unlocked {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.15), 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astropve_ach.unlocked:hover {
    box-shadow: 0 0 30px rgba(251, 191, 36, 0.3), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropve_ach_head {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
    gap: 12px;
    flex-wrap: wrap;
}

.astropve_ach_left {
    display: flex;
    align-items: center;
    gap: 15px;
    flex: 1;
    min-width: 0;
}

.astropve_ach_icon {
    font-size: 40px;
    line-height: 1;
    flex-shrink: 0;
    transition: 0.25s ease;
}
.astropve_ach_icon.locked {
    filter: grayscale(100%);
    opacity: 0.4;
}

.astropve_ach_info {
    min-width: 0;
}

.astropve_ach_name {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 3px;
    word-break: break-word;
}
.astropve_ach_name.locked { color: var(--text-muted); }

.astropve_ach_desc {
    font-size: 12px;
    color: var(--text-muted);
    margin-top: 3px;
    line-height: 1.5;
}

.astropve_ach_status_wrap {
    text-align: right;
    flex-shrink: 0;
}

.astropve_ach_status {
    display: inline-block;
    padding: 6px 14px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropve_ach_status.unlocked {
    background: rgba(74, 255, 136, 0.2);
    border: 1px solid rgba(74, 255, 136, 0.6);
    color: #88ffbb;
}
.astropve_ach_status.locked {
    background: rgba(148, 163, 184, 0.15);
    border: 1px solid rgba(148, 163, 184, 0.4);
    color: var(--text-muted);
}

.astropve_ach_unlocked_date {
    font-size: 10px;
    color: var(--text-muted);
    margin-top: 6px;
}

/* ─── PROGRESO ─────────────────────────────────────────── */
.astropve_ach_progress {
    margin-bottom: 10px;
}
.astropve_ach_progress_head {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
    color: #aabbcc;
    margin-bottom: 5px;
}
.astropve_ach_progress_head b {
    font-family: 'Courier New', monospace;
}
.astropve_ach_progress_head .cyan { color: #88ddff; }
.astropve_ach_progress_head .gold { color: var(--accent-gold); }

.astropve_ach_progress_bar {
    height: 12px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid var(--border-color);
}
.astropve_ach_progress_bar.unlocked {
    border-color: var(--accent-green);
}
.astropve_ach_progress_bar.locked {
    border-color: rgba(148, 163, 184, 0.3);
}

.astropve_ach_progress_fill {
    height: 100%;
    background: linear-gradient(90deg, #445566, #66aacc);
    transition: width 0.5s ease;
    box-shadow: 0 0 8px rgba(102, 170, 204, 0.4) inset;
}
.astropve_ach_progress_fill.unlocked {
    background: linear-gradient(90deg, var(--accent-green), #ffdd44);
    box-shadow: 0 0 10px rgba(74, 255, 136, 0.5) inset;
}

/* ─── RECOMPENSA ───────────────────────────────────────── */
.astropve_ach_reward {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    color: var(--text-muted);
    margin-top: 10px;
    flex-wrap: wrap;
    gap: 8px;
}
.astropve_ach_reward_dm {
    color: #ffdd88;
    font-weight: bold;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}
.astropve_ach_reward_missing {
    color: #88ddff;
}
.astropve_ach_reward_missing b {
    font-family: 'Courier New', monospace;
    color: #aae8ff;
}
.astropve_ach_reward_done {
    color: #88ffbb;
}

/* ─── EMPTY ────────────────────────────────────────────── */
.astropve_empty {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(251, 191, 36, 0.3);
    border-radius: 12px;
    padding: 40px 20px;
    text-align: center;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astropve_empty_icon {
    font-size: 40px;
    margin-bottom: 15px;
    display: block;
}
.astropve_empty_text {
    font-size: 14px;
    color: var(--text-muted);
    margin-bottom: 8px;
}
.astropve_empty_sub {
    font-size: 11px;
    color: #667788;
    line-height: 1.6;
}

/* ─── INFO / AYUDA ─────────────────────────────────────── */
.astropve_info {
    max-width: 900px;
    margin: 25px auto 0;
    padding: 15px 20px;
    background: rgba(0, 224, 255, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.3);
    border-radius: 10px;
    font-size: 12px;
    color: #88ddff;
    line-height: 1.8;
}
.astropve_info_title {
    font-weight: bold;
    margin-bottom: 8px;
}
.astropve_info ul {
    margin: 0;
    padding-left: 20px;
    line-height: 1.8;
}
.astropve_info li {
    margin-bottom: 4px;
}
.astropve_info b {
    color: var(--text-title);
}

.astropve_footer {
    text-align: center;
    font-size: 11px;
    color: var(--text-muted);
    margin-top: 30px;
}

/* ─── RESPONSIVE ───────────────────────────────────────── */
@media (max-width: 720px) {
    /* Wrap padding global */
    .astropve_wrap { padding: 12px; }

    /* Tabs → grid 2×N + huérfano full-width */
    .astropve_tabs {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 10px !important;
        margin-bottom: 15px !important;
    }
    .astropve_tab {
        min-width: 0 !important;
        max-width: 100% !important;
        width: 100% !important;
        padding: 8px 4px !important;
        font-size: 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
    }
    .astropve_tab:last-child:nth-child(odd) {
        grid-column: 1 / -1 !important;
    }

    /* Balance badge */
    .astropve_balance_bar { flex-direction: column !important; gap: 8px; }
    .astropve_balance_badge {
        width: 100% !important;
        max-width: 100% !important;
        padding: 11px 10px !important;
        justify-content: center !important;
        box-sizing: border-box !important;
    }

    /* Stats grid (racha / total / última) */
    .astropve_stat_value { font-size: 26px !important; }

    /* Card de logro */
    .astropve_ach_head { flex-direction: column; }
    .astropve_ach_status_wrap { text-align: left; }
    .astropve_ach_icon { font-size: 32px !important; }
    .astropve_ach_left { gap: 10px !important; }

    /* Subheaders de sección */
    .astropve_subheader {
        font-size: 12px !important;
        padding: 8px 12px !important;
        margin: 18px 0 10px !important;
    }
}
</style>

<div class="astropve_wrap">
    <h1 class="astropve_title">🏆 LOGROS</h1>

    {* ─── v4.0 — BADGE DE SALDO ─── *}
    {if isset($moneda) && isset($saldo_actual)}
        <div class="astropve_balance_bar">
            <div class="astropve_balance_badge {if $es_internacional}qvapay{else}cup{/if}">
                <span class="astropve_balance_label">💰 Saldo:</span>
                <span class="astropve_balance_value">{$saldo_actual|number_format}</span>
                <span class="astropve_balance_currency">{$moneda}</span>
            </div>
        </div>
    {/if}

    {* ═══════════════════════════════════════════════════════════
     * MENÚ DE PESTAÑAS
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_tabs">
        <a href="game.php?page=pve" class="astropve_tab main">
            🏠 Panel Principal
        </a>
        <a href="game.php?page=pve&mode=empire" class="astropve_tab empire">
            🏛️ Imperio Caído
        </a>
        <a href="game.php?page=pve&mode=boss" class="astropve_tab boss">
            🌌 Torneo del Devorador
        </a>
        <a href="game.php?page=pve&mode=bastion" class="astropve_tab bastion">
            ⚓ Bastión Asediado
        </a>
        <a href="game.php?page=pve&mode=achievements" class="astropve_tab achievements">
            🏆 Logros
        </a>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * ESTADÍSTICAS PERSONALES
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_stats_grid">
        <div class="astropve_stat streak">
            <div class="astropve_stat_label">🔥 RACHA ACTUAL</div>
            <div class="astropve_stat_value">
                {$achievements_data.consecutive}
            </div>
            <div class="astropve_stat_sub">
                mes{if $achievements_data.consecutive != 1}es{/if} consecutiv{if $achievements_data.consecutive == 1}o{else}os{/if}
            </div>
        </div>

        <div class="astropve_stat total">
            <div class="astropve_stat_label">📊 TOTAL HISTÓRICO</div>
            <div class="astropve_stat_value">
                {$achievements_data.total}
            </div>
            <div class="astropve_stat_sub">
                mes{if $achievements_data.total != 1}es{/if} sobrevivido{if $achievements_data.total != 1}s{/if}
            </div>
        </div>

        <div class="astropve_stat last">
            <div class="astropve_stat_label">📅 ÚLTIMA SUPERVIVENCIA</div>
            <div class="astropve_stat_value">
                {if $achievements_data.last_month != ''}
                    {$achievements_data.last_month}
                {else}
                    —
                {/if}
            </div>
            <div class="astropve_stat_sub">
                {literal}Formato YYYY-MM{/literal}
            </div>
        </div>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * LISTA DE LOGROS
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_section">
        <h2 class="astropve_section_title">
            🎖️ Logros Disponibles
            <span class="astropve_section_count">
                {$achievements_data.achievements|@count}
            </span>
        </h2>

        {if $achievements_data.achievements|@count > 0}
            {assign var=prev_type value=''}
            {foreach $achievements_data.achievements as $ach}

                {* ─── Sub-cabecera de sección por tipo ─── *}
                {if $ach.type != $prev_type}
                    {assign var=prev_type value=$ach.type}
                    <div class="astropve_subheader {if $ach.type == 'survival'}survival{elseif $ach.type == 'tournament'}tournament{elseif $ach.type == 'bastion'}bastion{else}other{/if}">
                        {if $ach.type == 'survival'}🌌 Crisis de Fin de Mes
                        {elseif $ach.type == 'tournament'}🌌 Torneo del Devorador
                        {elseif $ach.type == 'bastion'}⚓ Bastión Asediado
                        {else}{$ach.type|upper}{/if}
                    </div>
                {/if}

                <div class="astropve_ach {if $ach.unlocked}unlocked{/if}"
                     style="border-color: {if $ach.unlocked}{$ach.color}{else}rgba(120, 120, 120, 0.3){/if};">

                    <div class="astropve_ach_head">
                        <div class="astropve_ach_left">
                            <div class="astropve_ach_icon {if !$ach.unlocked}locked{/if}">
                                {$ach.icon}
                            </div>
                            <div class="astropve_ach_info">
                                <div class="astropve_ach_name {if !$ach.unlocked}locked{/if}"
                                     style="color: {if $ach.unlocked}{$ach.color}{else}#8899aa{/if};">
                                    {$ach.label}
                                </div>
                                <div class="astropve_ach_desc">
                                    {if $ach.type == 'survival'}
                                        {$ach.months_required} mes{if $ach.months_required != 1}es{/if} consecutiv{if $ach.months_required == 1}o{else}os{/if}
                                    {elseif $ach.id == 101}
                                        Matar 1 fantasma del torneo
                                    {elseif $ach.id == 102}
                                        Matar 10 fantasmas del torneo
                                    {elseif $ach.id == 103}
                                        Causar 10.000.000 de daño al Devorador
                                    {elseif $ach.id == 104}
                                        Ganar un torneo con tu alianza
                                    {elseif $ach.id == 201}
                                        Participar en 5 eventos del Bastión Asediado
                                    {elseif $ach.id == 202}
                                        Eliminar 5.000 piratas en el Bastión
                                    {elseif $ach.id == 203}
                                        Eliminar 10 capitanes piratas (jefes)
                                    {elseif $ach.id == 204}
                                        Ganar 5 eventos del Bastión con tu alianza
                                    {else}
                                        Logro PvE
                                    {/if}
                                </div>
                            </div>
                        </div>

                        <div class="astropve_ach_status_wrap">
                            {if $ach.unlocked}
                                <div class="astropve_ach_status unlocked">
                                    ✅ DESBLOQUEADO
                                </div>
                                <div class="astropve_ach_unlocked_date">
                                    {$ach.unlocked_fmt}
                                </div>
                            {else}
                                <div class="astropve_ach_status locked">
                                    🔒 BLOQUEADO
                                </div>
                            {/if}
                        </div>
                    </div>

                    {* ─── Barra de progreso ─── *}
                    <div class="astropve_ach_progress">
                        <div class="astropve_ach_progress_head">
                            <span>Progreso</span>
                            <span>
                                {if $ach.unlocked}
                                    <b class="gold" style="color: {$ach.color};">Completado</b>
                                {elseif $ach.type == 'survival'}
                                    <b class="cyan">{$achievements_data.consecutive}</b> / {$ach.months_required} meses
                                {else}
                                    <b class="cyan">{$ach.current|number_format}</b> / {$ach.target|number_format}
                                {/if}
                            </span>
                        </div>
                        <div class="astropve_ach_progress_bar {if $ach.unlocked}unlocked{else}locked{/if}"
                             style="border-color: {if $ach.unlocked}{$ach.color}{else}rgba(120, 120, 120, 0.3){/if};">
                            <div class="astropve_ach_progress_fill {if $ach.unlocked}unlocked{/if}"
                                 style="width: {if $ach.unlocked}100{else}{$ach.progress}{/if}%;
                                        background: linear-gradient(90deg, {if $ach.unlocked}{$ach.color}, #ffdd44{else}#445566, #66aacc{/if});"></div>
                        </div>
                    </div>

                    {* ─── Recompensa ─── *}
                    <div class="astropve_ach_reward">
                        <div>
                            🌌 <b class="astropve_ach_reward_dm">+{$ach.reward_dm|number_format}</b> Materia Oscura
                        </div>
                        {if !$ach.unlocked}
                            <div class="astropve_ach_reward_missing">
                                {if $ach.type == 'survival'}
                                    Faltan <b>{$ach.months_required - $achievements_data.consecutive}</b> mes{if ($ach.months_required - $achievements_data.consecutive) != 1}es{/if}
                                {else}
                                    Faltan <b>{$ach.target - $ach.current|number_format}</b> para completarlo
                                {/if}
                            </div>
                        {else}
                            <div class="astropve_ach_reward_done">
                                ✓ Recompensa ya entregada
                            </div>
                        {/if}
                    </div>

                </div>
            {/foreach}
        {else}
            <div class="astropve_empty">
                <span class="astropve_empty_icon">🏆</span>
                <div class="astropve_empty_text">
                    No hay logros disponibles.
                </div>
                <div class="astropve_empty_sub">
                    Sobrevive a las Crisis de Fin de Mes, participa en el Torneo del Devorador y defiende el Bastión Asediado para desbloquear logros.
                </div>
            </div>
        {/if}
    </div>

    {* ═══════════════════════════════════════════════════════════
     * INFO / AYUDA
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_info">
        <div class="astropve_info_title">💡 ¿Cómo funcionan los logros?</div>
        <ul>
            <li>Cada vez que sobrevives una <b>Crisis de Fin de Mes</b> completa, tu racha aumenta en 1 mes.</li>
            <li>Si fallas una crisis (pierdes todas las naves de un planeta), tu racha se resetea a 0.</li>
            <li>Los <b>meses consecutivos</b> desbloquean logros de <b>Supervivencia</b> automáticamente.</li>
            <li>Los <b>logros del Torneo del Devorador</b> se desbloquean matando fantasmas, causando daño al Devorador o ganando torneos con tu alianza.</li>
            <li>Los <b>logros del Bastión Asediado</b> se desbloquean participando en eventos, eliminando piratas (incluidos los <b>capitanes jefe</b>) y ganando asedios con tu alianza.</li>
            <li>Las recompensas se entregan <b>directamente como Materia Oscura 🌌</b> a tu cuenta en el momento de desbloquear el logro.</li>
        </ul>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * FOOTER
     * ═══════════════════════════════════════════════════════════ *}
    <p class="astropve_footer">
        🚧 Módulo Logros — AstroIO v4.0 · Dual-Riel NTX-20 / UNTX-20
    </p>
</div>

{/block}