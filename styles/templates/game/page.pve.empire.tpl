{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   PvE — Imperio Caído
   AstroIO v3.0 — Glassmorphism + Acento Naranja/Dorado
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
    --accent-gold:   #fbbf24;
    --accent-orange: #ff8822;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
}

.astropve_wrap {
    padding: 20px;
    color: var(--text-main);
}

.astropve_title {
    color: var(--accent-orange);
    text-align: center;
    font-size: 24px;
    margin-bottom: 10px;
    text-shadow: 0 0 14px rgba(255, 136, 34, 0.6);
    letter-spacing: 1px;
}

.astropve_subtitle {
    text-align: center;
    color: var(--text-muted);
    margin-bottom: 30px;
    font-size: 12px;
    line-height: 1.8;
}
.astropve_subtitle .warn  { color: #ffdd88; }
.astropve_subtitle .green { color: #88ffbb; }

/* ─── TABS ─────────────────────────────────────────────── */
.astropve_tabs {
    max-width: 900px;
    margin: 0 auto 25px;
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
}

.astropve_tab {
    flex: 1;
    min-width: 180px;
    max-width: 240px;
    padding: 12px 20px;
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
    background: linear-gradient(135deg, #cc5500, #ff8822);
    color: #fff;
    border: 1px solid var(--accent-orange);
    box-shadow: 0 4px 14px rgba(255, 136, 34, 0.5);
}
.astropve_tab.empire:hover {
    box-shadow: 0 6px 20px rgba(255, 136, 34, 0.7);
}

.astropve_tab.achievements {
    background: rgba(251, 191, 36, 0.15);
    color: #ffdd88;
    border: 1px solid rgba(251, 191, 36, 0.5);
}
.astropve_tab.achievements:hover {
    background: rgba(251, 191, 36, 0.25);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

/* ─── MENSAJES FLASH ────────────────────────────────────── */
.astropve_msg {
    max-width: 900px;
    margin: 0 auto 20px;
    padding: 15px 20px;
    border-radius: 10px;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropve_msg.error {
    background: rgba(239, 68, 68, 0.15);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: #ffbbbb;
}
.astropve_msg.success {
    background: rgba(74, 255, 136, 0.15);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: #88ffbb;
}

/* ─── INVITACIONES PENDIENTES ──────────────────────────── */
.astropve_invites {
    max-width: 900px;
    margin: 0 auto 25px;
    padding: 18px;
    background: rgba(0, 200, 255, 0.08);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 2px solid rgba(0, 200, 255, 0.5);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}
.astropve_invites_title {
    font-size: 15px;
    font-weight: bold;
    color: #88ddff;
    margin-bottom: 12px;
}
.astropve_invites_count {
    color: #ffffff;
    background: linear-gradient(135deg, #0066cc, #0099ff);
    padding: 2px 10px;
    border-radius: 10px;
    border: 1px solid var(--accent-cyan);
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astropve_invite_item {
    padding: 12px;
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-left: 3px solid #00aaff;
    border-radius: 8px;
    margin-bottom: 8px;
}
.astropve_invite_row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}
.astropve_invite_name {
    font-size: 13px;
    font-weight: bold;
    color: #88ddff;
    margin-bottom: 4px;
}
.astropve_invite_info {
    font-size: 11px;
    color: #aabbcc;
    line-height: 1.6;
}
.astropve_invite_info .inviter { color: #ffdd88; font-weight: bold; }
.astropve_invite_info .deadline { color: #ffaa66; font-weight: bold; }

.astropve_btn_accept {
    padding: 8px 16px;
    background: linear-gradient(135deg, #228833, #4aff88);
    color: #fff;
    border: 1px solid var(--accent-green);
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    display: inline-block;
}
.astropve_btn_accept:hover {
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(74, 255, 136, 0.5);
}

.astropve_btn_reject {
    padding: 8px 16px;
    background: rgba(239, 68, 68, 0.25);
    color: #ff8888;
    border: 1px solid rgba(239, 68, 68, 0.5);
    border-radius: 6px;
    font-size: 11px;
    font-weight: bold;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.25s ease;
    display: inline-block;
}
.astropve_btn_reject:hover {
    background: rgba(239, 68, 68, 0.35);
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(239, 68, 68, 0.4);
}

/* ─── SECCIÓN IMPERIOS ─────────────────────────────────── */
.astropve_empires {
    max-width: 900px;
    margin: 0 auto;
}
.astropve_empires_title {
    color: #ffdd88;
    font-size: 16px;
    margin-bottom: 15px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
.astropve_empires_count {
    display: inline-block;
    margin-left: 8px;
    padding: 2px 10px;
    background: rgba(251, 191, 36, 0.25);
    border: 1px solid rgba(251, 191, 36, 0.6);
    border-radius: 10px;
    font-size: 11px;
    color: #ffee88;
}

/* ─── CARD DE IMPERIO ─────────────────────────────────── */
.astropve_empire {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(251, 191, 36, 0.35);
    border-radius: 12px;
    padding: 18px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.25s ease;
}
.astropve_empire:hover {
    border-color: rgba(251, 191, 36, 0.6);
    box-shadow: 0 8px 30px rgba(251, 191, 36, 0.2), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astropve_empire_head {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 12px;
    flex-wrap: wrap;
    gap: 10px;
}
.astropve_empire_name {
    font-size: 17px;
    font-weight: bold;
    color: #ffdd88;
    margin-bottom: 4px;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}
.astropve_empire_coords {
    font-size: 11px;
    color: var(--text-muted);
}
.astropve_empire_coords .faction { color: #ffaa66; font-weight: bold; }

.astropve_empire_attacks {
    text-align: right;
}
.astropve_empire_attacks_lbl {
    font-size: 10px;
    color: var(--text-muted);
}
.astropve_empire_attacks_val {
    font-size: 14px;
    font-weight: bold;
}
.astropve_empire_attacks_val.ok  { color: #88ffbb; }
.astropve_empire_attacks_val.bad { color: #ff8888; }
.astropve_empire_expire {
    font-size: 10px;
    color: var(--text-muted);
    margin-top: 4px;
}
.astropve_empire_expire .time { color: #ffaa66; font-weight: bold; }

/* ─── BARRA HP ─────────────────────────────────────────── */
.astropve_hp_wrap {
    margin-bottom: 12px;
}
.astropve_hp_head {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
    color: #aabbcc;
    margin-bottom: 5px;
}
.astropve_hp_head .hp_val { color: #ffdd88; font-weight: bold; }
.astropve_hp_bar {
    height: 12px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid rgba(251, 191, 36, 0.3);
}
.astropve_hp_fill {
    height: 100%;
    background: linear-gradient(90deg, #ef4444, #fbbf24, #fde047);
    transition: width 0.5s;
    box-shadow: 0 0 8px rgba(251, 191, 36, 0.4) inset;
}

/* ─── STATS EMPIRE ─────────────────────────────────────── */
.astropve_empire_stats {
    display: flex;
    gap: 20px;
    font-size: 11px;
    color: #aabbcc;
    margin-bottom: 15px;
    flex-wrap: wrap;
}
.astropve_empire_stats .dmg   { color: #ff8888; font-weight: bold; }
.astropve_empire_stats .total { color: #88ccff; font-weight: bold; }

/* ─── CAJA DE BOTÍN ────────────────────────────────────── */
.astropve_loot {
    margin-bottom: 15px;
    padding: 12px 14px;
    background: linear-gradient(135deg, rgba(0, 100, 40, 0.15), rgba(0, 60, 20, 0.15));
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid #00cc66;
    border-radius: 8px;
}
.astropve_loot_title {
    font-size: 12px;
    font-weight: bold;
    color: #88ffbb;
    margin-bottom: 8px;
}
.astropve_loot_preview {
    display: flex;
    gap: 16px;
    font-size: 12px;
    flex-wrap: wrap;
    margin-bottom: 6px;
}
.astropve_loot_preview .metal   { color: #ffcc88; font-weight: bold; }
.astropve_loot_preview .crystal { color: #88ddff; font-weight: bold; }
.astropve_loot_preview .deut    { color: #aaffaa; font-weight: bold; }
.astropve_loot_info {
    font-size: 10px;
    color: var(--text-muted);
    line-height: 1.5;
}
.astropve_loot_info b { color: var(--text-title); }

/* ─── ACS ABIERTOS ─────────────────────────────────────── */
.astropve_acs {
    margin-bottom: 15px;
    padding: 12px;
    background: rgba(0, 200, 255, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 200, 255, 0.35);
    border-radius: 8px;
}
.astropve_acs_title {
    font-size: 12px;
    font-weight: bold;
    color: #88ddff;
    margin-bottom: 8px;
}
.astropve_acs_item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
    font-size: 11px;
    color: #aabbcc;
    border-top: 1px solid rgba(0, 200, 255, 0.15);
    flex-wrap: wrap;
    gap: 8px;
}
.astropve_acs_item:first-child { border-top: none; }
.astropve_acs_name { color: #88ddff; font-weight: bold; }

.astropve_btn_join {
    display: inline-block;
    padding: 5px 14px;
    background: linear-gradient(135deg, #0066cc, #00aaff);
    color: #fff;
    border: 1px solid var(--accent-cyan);
    border-radius: 5px;
    font-size: 10px;
    font-weight: bold;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropve_btn_join:hover {
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
}

/* ─── BOTONES DE ATAQUE ────────────────────────────────── */
.astropve_actions {
    border-top: 1px solid rgba(251, 191, 36, 0.25);
    padding-top: 15px;
}
.astropve_actions_row {
    display: flex;
    gap: 12px;
    flex-wrap: wrap;
    justify-content: center;
}

.astropve_btn_attack {
    display: inline-block;
    padding: 12px 32px;
    background: linear-gradient(135deg, #aa2200, #ef4444);
    color: #fff;
    border: 1px solid var(--accent-red);
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    box-shadow: 0 4px 14px rgba(239, 68, 68, 0.5);
    transition: all 0.25s ease;
    cursor: pointer;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropve_btn_attack:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(239, 68, 68, 0.7);
}

.astropve_btn_acs {
    display: inline-block;
    padding: 12px 32px;
    background: linear-gradient(135deg, #0066cc, #00aaff);
    color: #fff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 13px;
    font-weight: bold;
    text-decoration: none;
    box-shadow: 0 4px 14px rgba(0, 170, 255, 0.5);
    transition: all 0.25s ease;
    cursor: pointer;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropve_btn_acs:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 170, 255, 0.7);
}

.astropve_warning {
    padding: 12px 20px;
    background: rgba(251, 191, 36, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(251, 191, 36, 0.3);
    border-radius: 8px;
    font-size: 12px;
    color: #ffdd88;
    text-align: center;
}

.astropve_limit {
    text-align: center;
    padding: 10px;
    background: rgba(239, 68, 68, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: 8px;
    font-size: 12px;
    color: #ff8888;
}

/* ─── EMPTY STATE ──────────────────────────────────────── */
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

/* ─── NAV INFERIOR ─────────────────────────────────────── */
.astropve_nav_back {
    max-width: 900px;
    margin: 30px auto 0;
    text-align: center;
}
.astropve_btn_back {
    display: inline-block;
    padding: 10px 30px;
    background: rgba(139, 92, 246, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: #dd99ff;
    border: 1px solid rgba(139, 92, 246, 0.45);
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    text-decoration: none;
    transition: all 0.25s ease;
}
.astropve_btn_back:hover {
    background: rgba(139, 92, 246, 0.25);
    transform: translateY(-2px);
    box-shadow: 0 0 14px rgba(139, 92, 246, 0.4);
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
    /* 2 botones (Tabs) por fila */
    .astropve_tabs {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
		gap: 10px !important; /* Más espacio entre ellos */
		margin-bottom: 15px !important;
    }
    .astropve_tab {
        min-width: 0 !important;
        max-width: 100% !important;
        width: 100% !important;
        padding: 6px 3px !important;
        font-size: 10px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        text-align: center !important;
    }
	/* Hace que el botón huérfano (Logros) ocupe todo el ancho */
    .astropve_tab:last-child:nth-child(odd) {
        grid-column: 1 / -1 !important;
    }

    /* Cabecera del imperio apilada */
    .astropve_empire_head { 
        flex-direction: column; 
        align-items: flex-start;
    }
    .astropve_empire_attacks { 
        text-align: left; 
        margin-top: 10px;
    }

    /* Botones de ataque 2 por fila (1x2) y sin desbordar */
    .astropve_actions_row {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 10px !important;
        width: 100%;
    }
    .astropve_btn_attack, 
    .astropve_btn_acs {
        width: 100% !important;
        padding: 8px 5px !important;
        font-size: 11px !important;
        text-align: center !important;
        box-sizing: border-box !important; /* Evita que se salgan */
        word-break: break-word !important;
    }

    /* Ajustar botones de invitar/rechazar para que quepan */
    .astropve_invite_row {
        flex-direction: column !important;
        align-items: flex-start !important;
    }
    .astropve_invite_row > div:last-child {
        width: 100%;
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 8px;
        margin-top: 8px;
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
    .astropve_btn_accept, 
    .astropve_btn_reject {
        width: 100% !important;
        text-align: center !important;
        box-sizing: border-box !important;
        font-size: 10px !important;
        padding: 6px !important;
    }

    /* Botón de volver alineado */
    .astropve_btn_back {
        width: 100% !important;
        box-sizing: border-box !important;
        display: block;
    }
	/* HP head: permitir wrap si los números son largos */
    .astropve_hp_head { flex-wrap: wrap !important; gap: 4px !important; }

    /* Faction name largo en coords */
    .astropve_empire_coords { overflow-wrap: anywhere !important; }
}
</style>

<div class="astropve_wrap">
    <h1 class="astropve_title">🏛️ IMPERIO CAÍDO</h1>

    <p class="astropve_subtitle">
        Ataca los imperios caídos usando el sistema nativo de flotas de XNova.<br>
        <b class="warn">⚠️ Coordina con tu alianza usando ACS para maximizar el daño.</b><br>
        <b class="green">💰 Al destruir un imperio, sus recursos se reparten entre los atacantes según el daño hecho.</b>
    </p>

    {* ═══════════════════════════════════════════════════════════
     * MENÚ PESTAÑAS
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_tabs">
        <a href="game.php?page=pve" class="astropve_tab main">
            🏠 Panel Principal
        </a>
        <a href="game.php?page=pve&mode=empire" class="astropve_tab empire">
            🏛️ Imperio Caído
        </a>
        <a href="game.php?page=pve&mode=achievements" class="astropve_tab achievements">
            🏆 Logros
        </a>
    </div>

    {* ═══════════════════════════════════════════════════════════
     * MENSAJES FLASH
     * ═══════════════════════════════════════════════════════════ *}
    {if $attackError}
        <div class="astropve_msg error">
            {$attackError}
        </div>
    {/if}

    {if $attackResult}
        <div class="astropve_msg success">
            {if isset($attackResult.message)}{$attackResult.message}{/if}
        </div>
    {/if}

    {* ═══════════════════════════════════════════════════════════
     * INVITACIONES PENDIENTES
     * ═══════════════════════════════════════════════════════════ *}
    {if $pendingInvitesCount > 0}
        <div class="astropve_invites">
            <div class="astropve_invites_title">
                📥 Tienes <span class="astropve_invites_count">{$pendingInvitesCount}</span> invitación{if $pendingInvitesCount != 1}es{/if} pendiente{if $pendingInvitesCount != 1}s{/if} a ACS
            </div>

            {foreach $pendingInvites as $inv}
                <div class="astropve_invite_item">
                    <div class="astropve_invite_row">
                        <div>
                            <div class="astropve_invite_name">
                                🏛️ {$inv.empire_name} [{$inv.empire_galaxy}:{$inv.empire_system}:{$inv.empire_planet}]
                            </div>
                            <div class="astropve_invite_info">
                                👤 Invitado por: <b class="inviter">{$inv.inviter_name}</b><br>
                                {if $inv.invite_type == 'ally'}
                                    🏰 <b>Invitación de alianza</b><br>
                                {else}
                                    👥 <b>Invitación privada</b><br>
                                {/if}
                                ⏰ Unirse antes de: <b class="deadline">{$inv.ankunft|date_format:"%d/%m/%Y %H:%M"}</b>
                            </div>
                        </div>
                        <div style="display: flex; gap: 8px;">
                            <a href="game.php?page=pve&mode=acceptInvite&invite_id={$inv.id}"
                               onclick="return confirm('¿Aceptar esta invitación?\n\nLuego podrás seleccionar tus naves y unirte al ataque.');"
                               class="astropve_btn_accept">
                                ✅ Aceptar
                            </a>
                            <a href="game.php?page=pve&mode=rejectInvite&invite_id={$inv.id}"
                               onclick="return confirm('¿Rechazar esta invitación?');"
                               class="astropve_btn_reject">
                                ❌ Rechazar
                            </a>
                        </div>
                    </div>
                </div>
            {/foreach}
        </div>
    {/if}

    {* ═══════════════════════════════════════════════════════════
     * IMPERIOS ACTIVOS
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_empires">
        <h2 class="astropve_empires_title">
            ⚔️ Imperios Activos
            {if $empiresCount > 0}
                <span class="astropve_empires_count">{$empiresCount}</span>
            {/if}
        </h2>

        {if $empiresCount > 0}
            {foreach $empires as $e}
                <div class="astropve_empire">

                    {* ─── Cabecera del imperio ─── *}
                    <div class="astropve_empire_head">
                        <div>
                            <div class="astropve_empire_name">
                                🏛️ {$e.name}
                            </div>
                            <div class="astropve_empire_coords">
                                📍 [{$e.galaxy}:{$e.system}:{$e.planet}] • Facción: <b class="faction">{$e.faction_name}</b>
                            </div>
                        </div>
                        <div class="astropve_empire_attacks">
                            <div class="astropve_empire_attacks_lbl">Ataques restantes</div>
                            <div class="astropve_empire_attacks_val {if $e.can_attack}ok{else}bad{/if}">
                                {$e.max_attacks - $e.my_attacks} / {$e.max_attacks}
                            </div>
                            <div class="astropve_empire_expire">
                                Expira en: <b class="time">{$e.time_left_fmt}</b>
                            </div>
                        </div>
                    </div>

                    {* ─── Barra HP ─── *}
                    <div class="astropve_hp_wrap">
                        <div class="astropve_hp_head">
                            <span>❤️ HP del Imperio</span>
                            <span><b class="hp_val">{$e.hp_fmt}</b> / {$e.hp_max_fmt} ({$e.hp_percent}%)</span>
                        </div>
                        <div class="astropve_hp_bar">
                            <div class="astropve_hp_fill" style="width: {$e.hp_percent}%;"></div>
                        </div>
                    </div>

                    {* ─── Stats del imperio ─── *}
                    <div class="astropve_empire_stats">
                        <div>⚔️ Daño recibido: <b class="dmg">{$e.dmg_fmt}</b></div>
                        <div>🎯 Ataques totales: <b class="total">{$e.total_attacks}</b></div>
                    </div>

                    {* ─── 💰 BOTÍN DEL IMPERIO ─── *}
                    <div class="astropve_loot">
                        <div class="astropve_loot_title">
                            💰 Botín del Imperio
                        </div>

                        {* Preview opcional — solo si el controller pasa $e.loot_preview *}
                        {if isset($e.loot_preview) && ($e.loot_preview.metal > 0 || $e.loot_preview.crystal > 0 || $e.loot_preview.deuterium > 0)}
                            <div class="astropve_loot_preview">
                                {if $e.loot_preview.metal > 0}
                                    <div>🔩 Metal: <b class="metal">{$e.loot_preview.metal|number_format:0:',':'.'}</b></div>
                                {/if}
                                {if $e.loot_preview.crystal > 0}
                                    <div>💎 Cristal: <b class="crystal">{$e.loot_preview.crystal|number_format:0:',':'.'}</b></div>
                                {/if}
                                {if $e.loot_preview.deuterium > 0}
                                    <div>⚗️ Deuterio: <b class="deut">{$e.loot_preview.deuterium|number_format:0:',':'.'}</b></div>
                                {/if}
                            </div>
                        {/if}

                        <div class="astropve_loot_info">
                            Al destruirlo, sus recursos se reparten <b>proporcionalmente al daño</b> entre todos los atacantes.<br>
                            El botín va a tu <b>planeta principal</b> y se reclama desde el <b>Panel PvE</b>.
                        </div>
                    </div>

                    {* ─── ACS abiertos ─── *}
                    {if isset($openAcsByEmpire[$e.id]) && $openAcsByEmpire[$e.id]|@count > 0}
                        <div class="astropve_acs">
                            <div class="astropve_acs_title">
                                🤝 Ataques ACS abiertos:
                            </div>
                            {foreach $openAcsByEmpire[$e.id] as $acs}
                                <div class="astropve_acs_item">
                                    <div>
                                        <b class="astropve_acs_name">{$acs.name}</b> •
                                        {if $acs.visibility == 'public'}🌍 Público{elseif $acs.visibility == 'ally'}🏰 Alianza{else}👥 Invitados{/if} •
                                        {$acs.participants} jugador{if $acs.participants != 1}es{/if} •
                                        {$acs.total_ships|number_format:0:',':'.'} naves
                                    </div>
                                    <div>
                                        {* v4.4: URL directa a fleetTable con coords del imperio *}
                                        <a href="game.php?page=fleetTable&galaxy={$e.galaxy}&system={$e.system}&planet={$e.planet}&planettype=1&target_mission=1&acs_id={$acs.id}"
                                           class="astropve_btn_join">
                                            🤝 Unirse
                                        </a>
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    {/if}

                    {* ─── Botones de ataque ─── *}
                    {if $e.can_attack}
                        <div class="astropve_actions">
                            <div class="astropve_actions_row">

                                {* Botón: Atacar solo (v4.4: URL directa a fleetTable) *}
                                {if isset($e.ghost_planet_id) && $e.ghost_planet_id > 0}
                                    <a href="game.php?page=fleetTable&galaxy={$e.galaxy}&system={$e.system}&planet={$e.planet}&planettype=1&target_mission=1"
                                       class="astropve_btn_attack">
                                        🚀 Atacar
                                    </a>

                                    {* Botón: Atacar con ACS (abre configurador) — sin cambios *}
                                    <a href="game.php?page=pve&mode=acsSetup&empire_id={$e.id}"
                                       class="astropve_btn_acs">
                                        🤝 Atacar con ACS
                                    </a>
                                {else}
                                    <div class="astropve_warning">
                                        ⚠️ Este imperio aún no tiene cuenta fantasma asignada. Contacta al administrador.
                                    </div>
                                {/if}

                            </div>
                        </div>
                    {elseif !$e.can_attack}
                        <div class="astropve_limit">
                            ⛔ Has alcanzado el límite de ataques a este imperio.
                        </div>
                    {/if}

                </div>
            {/foreach}
        {else}
            <div class="astropve_empty">
                <span class="astropve_empty_icon">🏛️</span>
                <div class="astropve_empty_text">
                    No hay imperios activos en este momento.
                </div>
                <div class="astropve_empty_sub">
                    Los imperios aparecen cuando el administrador los activa.<br>
                    ¡Mantente atento a las notificaciones!
                </div>
            </div>
        {/if}
    </div>

    {* ═══════════════════════════════════════════════════════════
     * NAVEGACIÓN INFERIOR
     * ═══════════════════════════════════════════════════════════ *}
    <div class="astropve_nav_back">
        <a href="game.php?page=pve" class="astropve_btn_back">
            ← Volver al Panel PvE
        </a>
    </div>

    <p class="astropve_footer">
        🚧 Módulo Imperio Caído — AstroIO v4.4
    </p>
</div>

{/block}