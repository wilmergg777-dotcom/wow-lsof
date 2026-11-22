{block name="title" prepend}Admin Wallet{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   ADMIN WALLET WEB3 (Estilo Ronin/Kriptomat) - COMPACTO
   Prefijo: .rn-admin
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

/* Reducimos el ancho máximo y el padding general */
.wallet-admin-wrapper {
    background: var(--rn-bg);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    color: var(--rn-text-main);
    padding: 16px 20px;
    border-radius: 16px;
    max-width: 1050px;
    margin: 15px auto 0 auto; 
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    box-sizing: border-box;
    border: 1px solid var(--rn-border);
}

/* Header más bajo y compacto */
.wallet-admin-title {
    color: var(--rn-text-main);
    font-size: 16px;
    font-weight: 700;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--rn-border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
}
.wallet-admin-title .admin-info {
    font-size: 11px;
    color: var(--rn-text-muted);
    font-weight: 500;
}

/* Alertas */
.wallet-bank-alert {
    background: rgba(251, 191, 36, 0.1);
    border-left: 3px solid var(--rn-gold);
    color: var(--rn-gold);
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-size: 11px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
}
.wallet-bank-alert a { color: var(--rn-cyan); text-decoration: underline; font-weight: bold; }

.wallet-msg-ok {
    background: rgba(74, 255, 136, 0.1);
    border-left: 3px solid var(--rn-green);
    color: var(--rn-green);
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-size: 11px;
}
.wallet-msg-error {
    background: rgba(239, 68, 68, 0.1);
    border-left: 3px solid var(--rn-red);
    color: var(--rn-red);
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-size: 11px;
}

/* Tabs - Altura reducida */
.wallet-tabs {
    display: flex;
    gap: 4px;
    margin-top: 8px; 
    margin-bottom: 16px; 
    flex-wrap: wrap;
}
.wallet-tab {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid transparent;
    color: var(--rn-text-muted);
    padding: 6px 12px;
    font-size: 11px;
    font-weight: 600;
    border-radius: 15px;
    text-decoration: none;
    transition: 0.2s;
    display: flex;
    align-items: center;
    gap: 6px;
}
.wallet-tab:hover { background: rgba(255, 255, 255, 0.1); color: var(--rn-text-main); }
.wallet-tab.active { background: var(--rn-blue); color: #fff; border-color: var(--rn-blue); }
.wallet-tab .tab-counter {
    background: var(--rn-red);
    color: #fff;
    font-size: 9px;
    padding: 1px 5px;
    border-radius: 10px;
    font-weight: 700;
}

/* Stats Grid - Tarjetas más chicas */
.wallet-stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
    gap: 8px;
    margin-bottom: 16px;
}
.wallet-stat-card {
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 10px;
    padding: 10px;
    text-align: left;
}
.wallet-stat-title {
    font-size: 9px;
    color: var(--rn-text-muted);
    margin-bottom: 4px;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.wallet-stat-value {
    font-size: 16px;
    font-weight: 700;
    color: var(--rn-cyan);
    font-family: 'Inter', monospace;
}
.wallet-stat-value.green  { color: var(--rn-green); }
.wallet-stat-value.orange { color: var(--rn-gold); }
.wallet-stat-value.red    { color: var(--rn-red); }
.wallet-stat-value.purple { color: var(--rn-purple); }
.wallet-stat-value.cup    { color: var(--rn-green); }

/* Secciones */
.wallet-section {
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 12px;
    padding: 12px;
    margin-bottom: 12px;
}
.wallet-section-title {
    color: var(--rn-text-main);
    font-size: 13px;
    font-weight: 600;
    margin: 0 0 10px 0;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--rn-border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
}

/* Gráfico */
.wallet-chart-box {
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 12px;
    padding: 12px;
    margin-bottom: 12px;
}
.wallet-chart-header-wrap {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 8px;
}
.wallet-chart-price-label {
    font-size: 10px;
    color: var(--rn-text-muted);
    font-weight: 500;
    margin-bottom: 2px;
}
.wallet-chart-price-value {
    font-size: 18px;
    font-weight: 700;
    color: var(--rn-text-main);
    font-family: 'Inter', monospace;
    line-height: 1.1;
}
.wallet-chart-price-value small {
    font-size: 10px;
    color: var(--rn-text-muted);
    font-weight: 500;
    margin-left: 4px;
}
.wallet-chart-times {
    display: flex;
    gap: 2px;
    background: rgba(0,0,0,0.3);
    padding: 2px;
    border-radius: 15px;
    border: 1px solid var(--rn-border);
    flex-wrap: wrap;
    justify-content: center;
}
.wallet-time-btn {
    background: transparent;
    border: none;
    color: var(--rn-text-muted);
    font-size: 9.5px;
    font-weight: 600;
    padding: 4px 8px;
    border-radius: 12px;
    cursor: pointer;
    transition: 0.2s;
}
.wallet-time-btn:hover { color: var(--rn-text-main); }
.wallet-time-btn.active { background: var(--rn-purple); color: #fff; }
.wallet-chart-note {
    font-size: 9px;
    color: var(--rn-text-muted);
    margin-top: 6px;
    text-align: right;
    font-style: italic;
}

/* Tablas más compactas */
.wallet-table-wrap { overflow-x: auto; }
.wallet-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    table-layout: auto;
}
.wallet-table thead th {
    background: rgba(0,0,0,0.2);
    border-bottom: 1px solid var(--rn-border);
    color: var(--rn-text-muted);
    text-align: left;
    padding: 8px 10px;
    font-size: 9.5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-weight: 500;
    white-space: nowrap;
}
.wallet-table tbody td {
    padding: 8px 10px;
    border-bottom: 1px solid var(--rn-border);
    color: var(--rn-text-main);
    vertical-align: middle;
}
.wallet-table tbody tr:hover td { background: rgba(255, 255, 255, 0.02); }
.wallet-table .num { font-family: 'Inter', monospace; font-weight: 600; }
.wallet-table .kyber  { color: var(--rn-cyan); }
.wallet-table .nxt    { color: var(--rn-purple); }
.wallet-table .ok     { color: var(--rn-green); }
.wallet-table .err    { color: var(--rn-red); }
.wallet-table .cup    { color: var(--rn-green); }
.wallet-table .proy   { color: var(--rn-gold); }
.wallet-table .pos    { color: var(--rn-green); }
.wallet-table .neg    { color: var(--rn-red); }
.wallet-table .gray   { color: var(--rn-text-muted); }

/* Detalle de Retiro (Fila expandida) */
.wallet-table tr.wallet-row-detail td {
    padding: 0 !important;
    background: rgba(139, 92, 246, 0.05) !important;
    border-bottom: 1px solid rgba(139, 92, 246, 0.3) !important;
}
.wallet-withdraw-detail {
    padding: 12px 14px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    border-left: 3px solid var(--rn-purple);
}
.wallet-withdraw-detail-title { color: var(--rn-purple); font-size: 10px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 2px; }
.wallet-withdraw-detail-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
    gap: 8px;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid var(--rn-border);
    border-radius: 8px;
    padding: 10px 12px;
}
.wallet-withdraw-detail-grid > div { font-size: 10.5px; color: var(--rn-text-main); line-height: 1.5; }
.wallet-withdraw-detail-grid > div strong { color: var(--rn-cyan); font-weight: bold; display: block; font-size: 9px; text-transform: uppercase; letter-spacing: 0.3px; margin-bottom: 2px; }
.wallet-withdraw-detail-grid > div span { font-family: 'Inter', monospace; color: #ffffff; font-size: 11px; word-break: break-all; }
.wallet-withdraw-detail-no-data { background: rgba(251, 191, 36, 0.1); border-left: 3px solid var(--rn-gold); border-radius: 6px; padding: 8px 12px; font-size: 10.5px; color: var(--rn-gold); margin-top: 4px; }
.wallet-withdraw-detail-amounts { background: rgba(74, 255, 136, 0.06); border: 1px solid rgba(74, 255, 136, 0.25); border-radius: 8px; padding: 8px 12px; font-size: 10.5px; color: var(--rn-text-main); line-height: 1.8; }
.wallet-withdraw-detail-amounts strong { color: var(--rn-green); font-family: 'Inter', monospace; font-size: 11px; }
.wallet-withdraw-detail-actions { display: flex; gap: 8px; flex-wrap: wrap; justify-content: flex-end; padding-top: 6px; border-top: 1px solid rgba(139, 92, 246, 0.2); }

/* Botones */
.wallet-btn {
    display: inline-block;
    padding: 5px 12px;
    border-radius: 20px;
    font-size: 10.5px;
    font-weight: 600;
    cursor: pointer;
    text-decoration: none;
    border: none;
    margin: 2px 2px;
    transition: 0.2s ease;
    text-align: center;
    white-space: nowrap;
    font-family: 'Inter', sans-serif;
}
.wallet-btn-approve { background: var(--rn-green); color: #000; }
.wallet-btn-approve:hover { background: #3be673; color: #000; }
.wallet-btn-reject { background: rgba(239, 68, 68, 0.15); color: var(--rn-red); border: 1px solid var(--rn-red); }
.wallet-btn-reject:hover { background: var(--rn-red); color: #fff; }
.wallet-btn-primary { background: var(--rn-blue); color: #fff; }
.wallet-btn-primary:hover { background: #1a5be0; color: #fff; }
.wallet-btn-warning { background: var(--rn-gold); color: #000; }
.wallet-btn-warning:hover { background: #e0a800; color: #000; }
.wallet-btn-info { background: var(--rn-purple); color: #fff; }
.wallet-btn-info:hover { background: #7c3aed; color: #fff; }
.wallet-btn-gray { background: rgba(255,255,255,0.1); color: var(--rn-text-main); border: 1px solid var(--rn-border); }
.wallet-btn-gray:hover { background: rgba(255,255,255,0.2); }
.wallet-btn-lg { padding: 8px 16px; font-size: 11px; }

/* Badges */
.wallet-badge { display: inline-block; padding: 2px 6px; border-radius: 20px; font-size: 9px; font-weight: 600; }
.wallet-badge.ok      { background: rgba(74, 255, 136, 0.2); color: var(--rn-green); }
.wallet-badge.no      { background: rgba(239, 68, 68, 0.2);  color: var(--rn-red); }
.wallet-badge.pending { background: rgba(251, 191, 36, 0.2); color: var(--rn-gold); }
.wallet-badge.info    { background: rgba(0, 224, 255, 0.2);  color: var(--rn-cyan); }
.wallet-badge.gray    { background: rgba(148, 163, 184, 0.2);color: var(--rn-text-muted); }
.wallet-badge.purple  { background: rgba(139, 92, 246, 0.2); color: var(--rn-purple); }
.wallet-badge.cup     { background: rgba(74, 255, 136, 0.2); color: var(--rn-green); }

/* Formularios */
.wallet-form-group { margin-bottom: 10px; }
.wallet-form-label { color: var(--rn-cyan); font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; display: block; font-weight: 600; }
.wallet-input-group { display: flex; background: rgba(0, 0, 0, 0.5); border: 1px solid var(--rn-border); border-radius: 8px; overflow: hidden; max-width: 350px; transition: 0.25s ease; }
.wallet-input-group:focus-within { border-color: var(--rn-blue); box-shadow: 0 0 10px rgba(43, 107, 243, 0.3); }
.wallet-input-group input, .wallet-input-group select { flex: 1; background: transparent; border: none; padding: 8px 10px; color: #ffffff; font-size: 11px; outline: none; font-family: 'Inter', monospace; }
.wallet-input-group select { font-family: 'Inter', sans-serif; cursor: pointer; }
.wallet-input-group select option { background: #0f1624; color: #ffffff; }
.wallet-input-suffix { padding: 8px 12px; background: rgba(43, 107, 243, 0.1); color: var(--rn-blue); font-weight: bold; display: flex; align-items: center; font-size: 9.5px; text-transform: uppercase; }

/* Cajas de Info */
.wallet-info-box { background: rgba(43, 107, 243, 0.05); border: 1px solid var(--rn-border); border-radius: 8px; padding: 10px 12px; margin: 8px 0; font-size: 10.5px; line-height: 1.5; }
.wallet-info-box strong { color: var(--rn-cyan); }
.wallet-info-box code { background: rgba(0, 0, 0, 0.3); padding: 2px 6px; border-radius: 4px; color: var(--rn-gold); font-family: 'Inter', monospace; font-size: 10.5px; letter-spacing: 0.5px; }

.wallet-empty { color: var(--rn-text-muted); text-align: center; padding: 16px; font-style: italic; font-size: 11px; }

/* Modales */
.wallet-modal-bg { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.8); backdrop-filter: blur(6px); z-index: 9999; text-align: center; }
.wallet-modal-bg:target { display: block; }
.wallet-modal { display: inline-block; background: var(--rn-card); border: 1px solid var(--rn-border); border-radius: 16px; padding: 20px; max-width: 450px; width: 90%; margin-top: 80px; box-shadow: 0 8px 30px rgba(0, 0, 0, 0.6); text-align: left; position: relative; }
.wallet-modal-title { color: var(--rn-text-main); font-size: 14px; font-weight: 700; margin: 0 0 10px 0; padding-bottom: 8px; border-bottom: 1px solid var(--rn-border); }
.wallet-modal textarea, .wallet-modal input[type="text"], .wallet-modal input[type="number"], .wallet-modal select { width: 100%; background: rgba(0, 0, 0, 0.5); border: 1px solid var(--rn-border); border-radius: 8px; padding: 8px; color: #ffffff; font-size: 11px; font-family: 'Inter', sans-serif; box-sizing: border-box; resize: vertical; outline: none; transition: 0.25s ease; }
.wallet-modal textarea:focus, .wallet-modal input:focus, .wallet-modal select:focus { border-color: var(--rn-blue); box-shadow: 0 0 10px rgba(43, 107, 243, 0.3); }
.wallet-modal-actions { margin-top: 12px; padding-top: 10px; border-top: 1px solid var(--rn-border); text-align: right; }
.wallet-modal-close { position: absolute; top: 12px; right: 14px; color: var(--rn-text-muted); text-decoration: none; font-size: 18px; font-weight: bold; line-height: 1; }
.wallet-modal-close:hover { color: var(--rn-red); }

/* En Vivo (Auditoria) */
.wallet-audit-status { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; background: rgba(74, 255, 136, 0.08); border: 1px solid rgba(74, 255, 136, 0.3); border-radius: 8px; padding: 8px 12px; margin-bottom: 12px; font-size: 10.5px; color: var(--rn-green); }
.wallet-audit-status .live-dot { display: inline-block; width: 6px; height: 6px; background: var(--rn-green); border-radius: 50%; margin-right: 6px; animation: pulse-dot 1.5s ease-in-out infinite; vertical-align: middle; }
.wallet-audit-status .last-update { color: var(--rn-text-muted); font-size: 9.5px; font-weight: normal; }
.wallet-audit-status .total-count { background: rgba(0, 224, 255, 0.15); color: var(--rn-cyan); padding: 2px 8px; border-radius: 6px; font-weight: bold; font-size: 10.5px; }
@keyframes pulse-dot { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.5; transform: scale(1.4); } }

.wallet-audit-group { background: var(--rn-card); border: 1px solid var(--rn-border); border-radius: 10px; margin-bottom: 10px; overflow: hidden; transition: 0.25s ease; }
.wallet-audit-group:hover { border-color: var(--rn-blue); }
.wallet-audit-group.is-me { border-color: var(--rn-cyan); box-shadow: 0 0 14px rgba(0, 224, 255, 0.15); }
.wallet-audit-group.is-unassigned { border-color: rgba(251, 191, 36, 0.4); }
.wallet-audit-header { background: rgba(0,0,0,0.2); border-bottom: 1px solid var(--rn-border); padding: 10px 12px; display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; }
.wallet-audit-group.is-unassigned .wallet-audit-header { background: rgba(120, 80, 0, 0.2); border-bottom-color: rgba(251, 191, 36, 0.35); }
.wallet-audit-header .admin-name { color: var(--rn-text-main); font-size: 11px; font-weight: 600; display: flex; align-items: center; gap: 8px; }
.wallet-audit-header .admin-name .avatar { display: inline-block; width: 20px; height: 20px; border-radius: 50%; background: var(--rn-blue); color: #ffffff; font-size: 10px; font-weight: bold; line-height: 20px; text-align: center; }
.wallet-audit-header .badge-me { background: rgba(0, 224, 255, 0.25); color: var(--rn-cyan); padding: 1px 6px; border-radius: 4px; font-size: 8px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.3px; }
.wallet-audit-header .count-badge { background: rgba(0, 0, 0, 0.5); color: var(--rn-cyan); padding: 2px 8px; border-radius: 10px; font-size: 9.5px; font-weight: bold; border: 1px solid rgba(0, 224, 255, 0.35); }
.wallet-audit-group.is-unassigned .wallet-audit-header .count-badge { color: var(--rn-gold); border-color: rgba(251, 191, 36, 0.35); }
.wallet-audit-body { padding: 0; }
.wallet-audit-row { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap; padding: 8px 12px; border-bottom: 1px solid var(--rn-border); transition: 0.2s ease; }
.wallet-audit-row:last-child { border-bottom: none; }
.wallet-audit-row:hover { background: rgba(255,255,255,0.02); }
.wallet-audit-row .row-left { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; flex: 1; min-width: 220px; }
.wallet-audit-row .tramite-id { font-family: 'Inter', monospace; font-size: 10px; color: var(--rn-text-muted); font-weight: bold; }
.wallet-audit-row .user-name { color: var(--rn-text-main); font-size: 11px; font-weight: 600; }
.wallet-audit-row .kyber-amount { color: var(--rn-cyan); font-family: 'Inter', monospace; font-size: 11px; font-weight: bold; background: rgba(0, 224, 255, 0.08); padding: 1px 6px; border-radius: 4px; }
.wallet-audit-row .kyber-amount.nxt { color: var(--rn-purple); background: rgba(139, 92, 246, 0.08); }
.wallet-audit-row .kyber-amount small { font-size: 8.5px; color: var(--rn-text-muted); font-weight: normal; margin-left: 2px; }
.wallet-audit-row .row-right { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; }
.wallet-audit-row .fecha { font-size: 9.5px; color: var(--rn-text-muted); font-family: 'Inter', monospace; }
.wallet-audit-empty { text-align: center; padding: 30px 16px; color: var(--rn-text-muted); font-style: italic; font-size: 12px; }
.wallet-audit-empty .big-icon { font-size: 32px; display: block; margin-bottom: 10px; opacity: 0.6; }

/* MODAL DETALLE DE RETIRO */
.astrowalad_modal_bg { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.75); backdrop-filter: blur(4px); z-index: 99999; text-align: center; overflow-y: auto; padding: 30px 0; }
.astrowalad_modal_bg:target { display: block; }
.astrowalad_panel { display: inline-block; width: 100%; max-width: 800px; background: var(--rn-card); border: 1px solid var(--rn-border); border-radius: 16px; padding: 20px; box-shadow: 0 8px 30px rgba(0,0,0,0.7); text-align: left; font-size: 11px; color: var(--rn-text-main); box-sizing: border-box; position: relative; }
.astrowalad_header { border-bottom: 1px solid var(--rn-border); padding-bottom: 10px; margin-bottom: 14px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
.astrowalad_title { font-size: 15px; font-weight: bold; color: var(--rn-blue); text-transform: uppercase; letter-spacing: 1px; margin: 0; }
.astrowalad_id { font-family: 'Inter', monospace; color: var(--rn-text-muted); font-size: 11px; margin-left: 6px; }
.astrowalad_badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 10px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
.astrowalad_badge.pendiente { background: rgba(255,170,51,0.2);  color: #ffaa33; border: 1px solid #ffaa33; }
.astrowalad_badge.info      { background: rgba(0,224,255,0.2);   color: #00e0ff; border: 1px solid #00e0ff; }
.astrowalad_badge.ok        { background: rgba(102,255,153,0.2); color: #66ff99; border: 1px solid #66ff99; }
.astrowalad_badge.error     { background: rgba(255,68,136,0.2);  color: #ff4488; border: 1px solid #ff4488; }
.astrowalad_badge.gray      { background: rgba(122,139,160,0.2); color: #7a8ba0; border: 1px solid #7a8ba0; }
.astrowalad_alerta { padding: 10px 12px; border-radius: 8px; margin-bottom: 12px; font-size: 11px; line-height: 1.6; }
.astrowalad_alerta_ok    { background: rgba(102,255,153,0.12); border-left: 3px solid #66ff99; color: #66ff99; }
.astrowalad_alerta_error { background: rgba(255,68,136,0.12);  border-left: 3px solid #ff4488; color: #ff4488; }
.astrowalad_alerta_info  { background: rgba(0,204,255,0.1);    border-left: 3px solid #00ccff; color: #00e0ff; }
.astrowalad_alerta_warn  { background: rgba(221,136,0,0.12);   border-left: 3px solid #dd8800; color: #ffaa33; }
.astrowalad_alerta strong { display: block; margin-bottom: 4px; font-size: 12px; }
.astrowalad_grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 8px; margin-bottom: 14px; }
.astrowalad_card { background: rgba(0,0,0,0.2); border: 1px solid var(--rn-border); border-radius: 8px; padding: 10px; }
.astrowalad_card_label { font-size: 9px; color: var(--rn-text-muted); text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
.astrowalad_card_value { font-size: 14px; font-weight: bold; font-family: 'Inter', monospace; color: #00e0ff; }
.astrowalad_card_value.nxt  { color: #aa44ff; }
.astrowalad_card_value.ok   { color: #66ff99; }
.astrowalad_card_value.err  { color: #ff4488; }
.astrowalad_card_value.gray { color: #7a8ba0; }
.astrowalad_section { background: rgba(0,0,0,0.2); border: 1px solid var(--rn-border); border-radius: 8px; padding: 14px; margin-bottom: 14px; }
.astrowalad_section_title { color: #00e0ff; font-size: 12px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; margin: 0 0 10px 0; padding-bottom: 6px; border-bottom: 1px solid var(--rn-border); }
.astrowalad_banco { background: rgba(43, 107, 243, 0.1); border: 1px solid var(--rn-border); border-radius: 8px; padding: 14px; margin-bottom: 14px; }
.astrowalad_banco_title { color: #00e0ff; font-size: 12px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; margin: 0 0 10px 0; text-align: center; }
.astrowalad_banco_row { display: flex; justify-content: space-between; align-items: center; padding: 6px 0; border-bottom: 1px dashed rgba(255,255,255,0.1); gap: 10px; flex-wrap: wrap; }
.astrowalad_banco_row:last-child { border-bottom: none; }
.astrowalad_banco_label { color: var(--rn-text-muted); font-size: 10px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: bold; }
.astrowalad_banco_value { color: #ffffff; font-family: 'Inter', monospace; font-size: 13px; font-weight: bold; background: rgba(0,0,0,0.3); padding: 5px 10px; border-radius: 6px; letter-spacing: 0.5px; user-select: all; }
.astrowalad_banco_value.highlight { color: #ffaa33; background: rgba(255,170,51,0.15); border: 1px solid rgba(255,170,51,0.4); }
.astrowalad_timeline { list-style: none; padding: 0; margin: 0; position: relative; padding-left: 20px; }
.astrowalad_timeline:before { content: ''; position: absolute; left: 6px; top: 6px; bottom: 6px; width: 2px; background: linear-gradient(180deg, #00ccff 0%, rgba(0,204,255,0.1) 100%); }
.astrowalad_timeline_item { position: relative; padding: 4px 0 10px 10px; font-size: 11px; }
.astrowalad_timeline_item:before { content: ''; position: absolute; left: -20px; top: 8px; width: 8px; height: 8px; border-radius: 50%; background: #00ccff; box-shadow: 0 0 8px rgba(0,224,255,0.6); border: 2px solid var(--rn-card); }
.astrowalad_timeline_accion { color: #00e0ff; font-weight: bold; text-transform: uppercase; font-size: 10px; letter-spacing: 0.5px; display: block; margin-bottom: 2px; }
.astrowalad_timeline_detalle { color: var(--rn-text-main); display: block; line-height: 1.4; }
.astrowalad_timeline_meta { color: var(--rn-text-muted); font-size: 9px; display: block; margin-top: 3px; font-style: italic; }
.astrowalad_actions { text-align: center; margin-top: 16px; padding-top: 14px; border-top: 1px solid var(--rn-border); }
.astrowalad_btn { display: inline-block; padding: 8px 18px; border-radius: 20px; font-size: 11px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; text-decoration: none; border: none; cursor: pointer; margin: 4px 4px; transition: 0.2s ease; box-shadow: 0 4px 14px rgba(0,0,0,0.4); font-family: 'Inter', sans-serif; }
.astrowalad_btn_primary { background: var(--rn-blue); color: #ffffff; }
.astrowalad_btn_primary:hover { background: #1a5be0; transform: translateY(-1px); }
.astrowalad_btn_ok { background: var(--rn-green); color: #000; }
.astrowalad_btn_ok:hover { background: #3be673; transform: translateY(-1px); }
.astrowalad_btn_danger { background: rgba(239, 68, 68, 0.15); color: var(--rn-red); border: 1px solid var(--rn-red); }
.astrowalad_btn_danger:hover { background: var(--rn-red); color: #fff; transform: translateY(-1px); }
.astrowalad_btn_warn { background: var(--rn-gold); color: #000; }
.astrowalad_btn_warn:hover { background: #e0a800; transform: translateY(-1px); }
.astrowalad_btn_gray { background: rgba(255,255,255,0.1); color: #fff; border: 1px solid var(--rn-border); }
.astrowalad_btn_gray:hover { background: rgba(255,255,255,0.2); transform: translateY(-1px); }
.astrowalad_close { position: absolute; top: 14px; right: 18px; color: var(--rn-text-muted); text-decoration: none; font-size: 22px; font-weight: bold; line-height: 1; z-index: 2; }
.astrowalad_close:hover { color: var(--rn-red); }

@media (max-width: 720px) {
    .wallet-admin-wrapper { padding: 12px 14px; margin-top: 10px; }
    .wallet-tab { padding: 5px 10px; font-size: 10px; }
    .wallet-stat-value { font-size: 14px; }
    .wallet-table { font-size: 10px; }
    .wallet-table thead th { padding: 5px 5px; font-size: 9px; }
    .wallet-table tbody td { padding: 5px 5px; }
    .wallet-audit-row { padding: 6px 8px; }
    .wallet-audit-row .user-name { font-size: 10px; }
    .wallet-chart-price-value { font-size: 18px; }
    .wallet-chart-times { width: 100%; justify-content: center; }
    .wallet-time-btn { flex: 1; padding: 4px 5px; }
    .wallet-withdraw-detail-grid { grid-template-columns: 1fr; }
    .astrowalad_panel { padding: 12px 14px; }
    .astrowalad_title { font-size: 12px; }
    .astrowalad_banco_value { font-size: 11px; padding: 4px 8px; }
}
@media (max-width: 480px) {
    .wallet-tab { display: block; width: 100%; text-align: center; }
    .wallet-stats-grid { grid-template-columns: 1fr 1fr; }
    .wallet-btn { display: block; width: 100%; margin: 3px 0; }
    .wallet-audit-row { flex-direction: column; align-items: flex-start; }
    .wallet-audit-row .row-right { width: 100%; justify-content: space-between; }
    .astrowalad_btn { display: block; width: 100%; margin: 4px 0; }
    .astrowalad_banco_row { flex-direction: column; align-items: flex-start; }
    .astrowalad_banco_value { width: 100%; text-align: center; }
}
</style>

<div class="wallet-admin-wrapper">

    {* ─── HEADER ─────────────────────────────────────────── *}
    <div class="wallet-admin-title">
        <span>👑 Panel de Administración del Banco</span>
        <span class="admin-info">Admin: <strong>{$username}</strong></span>
    </div>

    {* ─── ALERTA DATOS BANCARIOS ─────────────────────────── *}
    {if !$tiene_datos_banco}
        <div class="wallet-bank-alert">
            <span>⚠️ No tenés datos bancarios cargados. No podrás tomar solicitudes.</span>
            <a href="game.php?page=walletadmin&mode=setbankdata">Cargar ahora →</a>
        </div>
    {/if}

    {* ─── FEEDBACK ───────────────────────────────────────── *}
    {if $feedback_ok != ''}
        <div class="wallet-msg-ok">
            {if $feedback_ok == 'datos_guardados'}✅ Datos bancarios guardados correctamente.
            {elseif $feedback_ok == 'solicitud_tomada'}✅ Solicitud tomada. Los datos bancarios se enviaron AUTOMÁTICAMENTE al usuario.
            {elseif $feedback_ok == 'datos_enviados'}✅ Datos bancarios reenviados al usuario.
            {elseif $feedback_ok == 'inversion_confirmada'}✅ Inversión confirmada. 💲 NXT-20 entregados al usuario y 💰 CUP acreditado al admin.
            {elseif $feedback_ok == 'inversion_rechazada'}✅ Inversión rechazada.
            {elseif $feedback_ok == 'lock_liberado'}✅ Solicitud liberada. Vuelve a la cola de pendientes.
            {elseif $feedback_ok == 'solicitud_cancelada'}✅ Solicitud cancelada.
            {elseif $feedback_ok == 'solicitud_eliminada'}✅ Solicitud eliminada del sistema.
            {elseif $feedback_ok == 'retiro_aceptado'}✅ Retiro aceptado. Ahora transferí el dinero y confirmá.
            {elseif $feedback_ok == 'retiro_confirmado'}✅ Retiro CONFIRMADO. 💲 NXT-20 quemados, 💎 Kyber bajados del banco, 💰 CUP descontados.
            {elseif $feedback_ok == 'retiro_rechazado'}✅ Retiro rechazado. Se devolvieron los 💲 NXT-20 al usuario.
            {elseif $feedback_ok == 'retiro_cancelado'}✅ Retiro cancelado. Se devolvieron los 💲 NXT-20 al usuario.
            {elseif $feedback_ok == 'cambio_aprobado'}✅ Cambio de datos bancarios APROBADO. Datos actualizados.
            {elseif $feedback_ok == 'cambio_rechazado'}✅ Cambio de datos bancarios RECHAZADO.
            {elseif $feedback_ok == 'retiros_abiertos'}✅ Retiros abiertos.
            {elseif $feedback_ok == 'retiros_cerrados'}✅ Retiros cerrados.
            {elseif $feedback_ok == 'minimo_guardado'}✅ Mínimo de retiro guardado correctamente.
            {elseif $feedback_ok == 'fondo_retirado'}✅ Fondo del proyecto retirado y acreditado en tu 💰 cuenta CUP.
            {elseif $feedback_ok == 'transferencia_creada'}✅ Transferencia creada. El otro admin debe aceptarla.
            {elseif $feedback_ok == 'transferencia_aceptada'}✅ Transferencia aceptada. El saldo se movió correctamente.
            {elseif $feedback_ok == 'transferencia_rechazada'}✅ Transferencia rechazada. El saldo volvió al emisor.
            {elseif $feedback_ok == 'transferencia_cancelada'}✅ Transferencia cancelada.
            {elseif $feedback_ok == 'ajuste_aplicado'}✅ Ajuste manual aplicado al 💰 saldo CUP.
            {elseif $feedback_ok == 'ajuste_untx_aplicado'}✅ Ajuste manual aplicado al saldo UNTX-20 del jugador.
            {elseif $feedback_ok == 'rebalance_registrado'}✅ Movimiento registrado. Las reservas han sido actualizadas correctamente.
            {else}✅ Operación realizada.
            {/if}
        </div>
    {/if}

    {if $feedback_error != ''}
        <div class="wallet-msg-error">❌ {$feedback_error|escape:'html'}</div>
    {/if}

    {* ─── TABS ───────────────────────────────────────────── *}
    <div class="wallet-tabs">
        <a class="wallet-tab {if $tab == 'dashboard'}active{/if}" 
           href="game.php?page=walletadmin">
            📊 Dashboard
        </a>
        <a class="wallet-tab {if $tab == 'investments'}active{/if}" 
           href="game.php?page=walletadmin&mode=investments">
            📥 Sin asignar
            {if $count_sin_asignar > 0}<span class="tab-counter">{$count_sin_asignar}</span>{/if}
        </a>
        <a class="wallet-tab {if $tab == 'mis_pendientes'}active{/if}" 
           href="game.php?page=walletadmin&mode=misPendientes">
            👤 Mis pendientes
            {if $count_mis_pend > 0}<span class="tab-counter">{$count_mis_pend}</span>{/if}
        </a>
        <a class="wallet-tab {if $tab == 'verificar'}active{/if}" 
           href="game.php?page=walletadmin&mode=verificar">
            🔍 Verificar
            {if $count_mis_verif > 0}<span class="tab-counter">{$count_mis_verif}</span>{/if}
        </a>
        <a class="wallet-tab {if $tab == 'historial'}active{/if}" 
           href="game.php?page=walletadmin&mode=historial">
            📜 Historial
        </a>
        <a class="wallet-tab {if $tab == 'auditoria'}active{/if}" 
           href="game.php?page=walletadmin&mode=auditoria">
            👁️ En Vivo
        </a>
        <a class="wallet-tab {if $tab == 'cambios_bancarios'}active{/if}" 
           href="game.php?page=walletadmin&mode=solicitudesCambio">
            💳 Cambios bancarios
            {if isset($count_cambios) && $count_cambios > 0}<span class="tab-counter">{$count_cambios}</span>{/if}
        </a>
        <a class="wallet-tab {if $tab == 'cup' || $tab == 'cup_historial'}active{/if}" 
           href="game.php?page=walletadmin&mode=saldoCup">
            💰 Saldo CUP
            {if isset($count_trans_rec) && $count_trans_rec > 0}<span class="tab-counter">{$count_trans_rec}</span>{/if}
        </a>
        <a class="wallet-tab {if $tab == 'ganancias'}active{/if}" 
           href="game.php?page=walletadmin&mode=ganancias">
            💼 Ganancias
        </a>
        <a class="wallet-tab {if $tab == 'config'}active{/if}" 
           href="game.php?page=walletadmin&mode=config">
            ⚙️ Config
        </a>
        <a class="wallet-tab {if $tab == 'qvapay'}active{/if}" 
           href="game.php?page=walletadmin&mode=qvapay">
            💳 QvaPay
        </a>
        <a class="wallet-tab {if $tab == 'crossmarket'}active{/if}" 
           href="game.php?page=walletadmin&mode=crossMarket" style="border-color: rgba(0, 224, 255, 0.4);">
            🌐 Mercado Cruzado
        </a>
        <a class="wallet-tab {if $tab == 'ajuste_untx'}active{/if}" 
           href="game.php?page=walletadmin&mode=ajusteManualUntx" style="border-color: rgba(0, 224, 255, 0.4);">
            💲 Ajuste UNTX-20
        </a>
        <a class="wallet-tab {if $tab == 'setbankdata'}active{/if}" 
           href="game.php?page=walletadmin&mode=setbankdata">
            💳 Mis Datos
        </a>
    </div>

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 1 — DASHBOARD                                     *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'dashboard'}

        <div class="wallet-stats-grid">
            <!-- Kyber Global y Desglose -->
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💎 Kyber en el Banco (Total)</div>
                <div class="wallet-stat-value green">{$kyber_banco}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💎 Banco Sistema CUP</div>
                <div class="wallet-stat-value cyan">{$kyber_banco_cup}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💎 Banco Sistema QvaPay</div>
                <div class="wallet-stat-value purple">{$kyber_banco_qvapay}</div>
            </div>

            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💲 Total Invertido</div>
                <div class="wallet-stat-value green">{$total_invertido}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💲 Total Retirado</div>
                <div class="wallet-stat-value red">{$total_retirado}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💼 Fondo Proyecto</div>
                <div class="wallet-stat-value orange">{$fondo_proyecto}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Mín. Retiro 💲 NXT-20</div>
                <div class="wallet-stat-value red">{$min_retiro_nxt20}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💰 Mi Saldo CUP</div>
                <div class="wallet-stat-value cup">{$cup_saldo}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💰 Mi Disponible CUP</div>
                <div class="wallet-stat-value cup">{$cup_disponible}</div>
            </div>
            
            <!-- NXT-20 Y UNTX-20 EN CIRCULACIÓN -->
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💲 NXT-20 en Circulación</div>
                <div class="wallet-stat-value purple">{$total_ntx20_juego}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">🌐 UNTX-20 en Circulación</div>
                <div class="wallet-stat-value cyan">{$total_untx20_juego}</div>
            </div>

            <!-- Contadores de Tareas -->
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Sin asignar</div>
                <div class="wallet-stat-value {if $count_sin_asignar > 0}orange{else}green{/if}">{$count_sin_asignar}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Mis pendientes</div>
                <div class="wallet-stat-value {if $count_mis_pend > 0}orange{else}green{/if}">{$count_mis_pend}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Por verificar</div>
                <div class="wallet-stat-value {if $count_mis_verif > 0}orange{else}green{/if}">{$count_mis_verif}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Retiros pendientes</div>
                <div class="wallet-stat-value {if $count_pending_wd > 0}orange{else}green{/if}">{$count_pending_wd}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Cambios bancarios</div>
                <div class="wallet-stat-value {if isset($count_cambios) && $count_cambios > 0}orange{else}green{/if}">{if isset($count_cambios)}{$count_cambios}{else}0{/if}</div>
            </div>
			{* === Saldo QvaPay === *}
			<div class="wallet-stat-card">
                <div class="wallet-stat-title">Spread (CUP)</div>
                <div class="wallet-stat-value green">{$spread_nac} CUP</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">Spread (UNTX)</div>
                <div class="wallet-stat-value green">{$spread_int} UNTX</div>
            </div>
			{* ===================== *}
        </div>

        {* ─── GRÁFICO DEL BANCO ─── *}
        <div class="wallet-chart-box">
            <div class="wallet-chart-header-wrap">
                <div>
                    <div class="wallet-chart-price-label">💎 Kyber en el Banco (Total Global)</div>
                    <div class="wallet-chart-price-value">
                        <span class="wallet-chart-price-display">{$kyber_banco}</span><small>💎 Kyber</small>
                    </div>
                </div>
                <div class="wallet-chart-times">
                    <button type="button" class="wallet-time-btn" data-horas="24">24h</button>
                    <button type="button" class="wallet-time-btn active" data-horas="360">15d</button>
                    <button type="button" class="wallet-time-btn" data-horas="720">1m</button>
                    <button type="button" class="wallet-time-btn" data-horas="0">ALL</button>
                </div>
            </div>
            <div id="poolChart"></div>
            <div class="wallet-chart-note">
                ⏱️ Snapshot cada 1 hora · 🟣 Kyber banco
            </div>
        </div>

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📊 Estado del Sistema</span>
                <span class="wallet-badge {if $retiros_abiertos}ok{else}no{/if}">
                    {if $retiros_abiertos}🟢 RETIROS ABIERTOS{else}🔒 RETIROS CERRADOS{/if}
                </span>
            </h3>
            <div class="wallet-info-box">
                {if $retiros_abiertos}
                    Los usuarios VIP pueden retirar 💲 NXT-20 a cambio de 💎 Kyber (10% comisión).
                    {if $retiros_duracion > 0}Duración configurada: <strong>{$retiros_duracion} horas</strong>.{/if}
                {else}
                    Los retiros están cerrados. Abrilos desde 
                    <a href="game.php?page=walletadmin&mode=config" style="color:#00e0ff;">Configuración</a>.
                {/if}
            </div>
            <div class="wallet-info-box" style="border-color:rgba(139,92,246,0.3); background:rgba(139,92,246,0.05);">
                <strong>🛡️ Modelo 1:1 SIN AMM:</strong><br>
                <code>Inversión: 100 💎 Kyber = 100 💲 NXT-20 retirables</code><br>
                <code>Retiro: 100 💲 NXT-20 = 90 💎 Kyber netos (10% comisión)</code><br>
                El banco <strong>nunca quiebra</strong>: siempre hay 💎 Kyber para pagar retiros.
            </div>
        </div>

    {/if}
	
    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 2 — SIN ASIGNAR (Inversiones + Retiros)            *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'investments'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📥 Solicitudes Sin Asignar ({$solicitudes|@count})</span>
            </h3>

            <div class="wallet-info-box">
                <strong>ℹ️ Estas solicitudes no tienen admin asignado.</strong><br>
                Tomá una para bloquearla y empezar el proceso. Solo vos podrás terminarla.<br>
                Aquí se incluyen <strong>tanto inversiones como retiros</strong>.
            </div>

            {if $solicitudes|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Monto</th>
                            <th>Referidor</th>
                            <th>Fecha</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $solicitudes as $s}
                            <tr>
                                <td>#{$s.id}</td>
                                <td>
                                    <strong>{$s.username|escape:'html'}</strong>
                                    {if $s.tipo == 'retiro'}
                                        <span class="wallet-badge purple" style="margin-left:4px;">💲 RETIRO</span>
                                    {else}
                                        <span class="wallet-badge info" style="margin-left:4px;">💎 INVERSIÓN</span>
                                    {/if}
                                </td>
                                <td class="num {if $s.tipo == 'retiro'}nxt{else}kyber{/if}">
                                    {$s.cantidad_kyber} {if $s.tipo == 'retiro'}💲 NXT-20{else}💎 Kyber{/if}
                                </td>
                                <td>
                                    {if $s.tipo == 'inversion' && $s.referidor_id > 0}
                                        {$s.nxt20_referidor} 💲 NXT-20 <span style="color:#94a3b8;">(ID {$s.referidor_id})</span>
                                    {else}
                                        <span style="color:#94a3b8;">—</span>
                                    {/if}
                                </td>
                                <td>{$s.fecha}</td>
                                <td>
                                    {if $tiene_datos_banco}
                                        {if $s.tipo == 'retiro'}
                                            <a class="wallet-btn wallet-btn-approve" 
                                               href="game.php?page=walletadmin&mode=aceptarRetiro&id={$s.id}"
                                               onclick="return confirm('¿Aceptar este retiro?\n\nSe enviarán AUTOMÁTICAMENTE tus datos bancarios al usuario y la solicitud pasará a VERIFICAR.');">
                                                ✋ ACEPTAR RETIRO
                                            </a>
                                        {else}
                                            <a class="wallet-btn wallet-btn-approve" 
                                               href="game.php?page=walletadmin&mode=tomar&id={$s.id}"
                                               onclick="return confirm('¿Tomar esta inversión?\n\nSe enviarán AUTOMÁTICAMENTE tus datos bancarios al usuario.');">
                                                ✋ TOMAR INVERSIÓN
                                            </a>
                                        {/if}
                                    {else}
                                        <span style="color:#ef4444; font-size:10px;">
                                            Cargá tus datos primero
                                        </span>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay solicitudes sin asignar. 🎉</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 3 — MIS PENDIENTES (Inversiones + Retiros)         *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'mis_pendientes'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>👤 Mis Solicitudes Pendientes ({$solicitudes|@count})</span>
            </h3>

            <div class="wallet-info-box">
                <strong>ℹ️ Estas solicitudes las tomaste vos.</strong><br>
                Los datos bancarios se enviaron AUTOMÁTICAMENTE. Podés reenviar si el user perdió el mensaje, liberar el lock, o cancelar.
            </div>

            {if $solicitudes|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Monto</th>
                            <th>Estado</th>
                            <th>Tomada</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $solicitudes as $s}
                            <tr>
                                <td>#{$s.id}</td>
                                <td>
                                    <strong>{$s.username|escape:'html'}</strong>
                                    {if $s.tipo == 'retiro'}
                                        <span class="wallet-badge purple" style="margin-left:4px;">💲 RETIRO</span>
                                    {else}
                                        <span class="wallet-badge info" style="margin-left:4px;">💎 INVERSIÓN</span>
                                    {/if}
                                </td>
                                <td class="num {if $s.tipo == 'retiro'}nxt{else}kyber{/if}">
                                    {$s.cantidad_kyber} {if $s.tipo == 'retiro'}💲 NXT-20{else}💎 Kyber{/if}
                                </td>
                                <td><span class="wallet-badge {$s.estado_clase}">{$s.estado_label}</span></td>
                                <td>{$s.fecha_asignada}</td>
                                <td>
                                    {if $s.tipo == 'retiro'}
                                        <a class="wallet-btn wallet-btn-info" 
                                           href="game.php?page=walletadmin&mode=verRetiro&id={$s.id}">
                                            🔍 VER / CONFIRMAR
                                        </a>
                                    {else}
                                        {if $s.estado == 'datos_enviados'}
                                            <a class="wallet-btn wallet-btn-info" 
                                               href="game.php?page=walletadmin&mode=enviarDatos&id={$s.id}"
                                               onclick="return confirm('¿Reenviar tus datos bancarios al usuario?');">
                                                📨 REENVIAR
                                            </a>
                                        {/if}
                                        <a class="wallet-btn wallet-btn-warning" 
                                           href="game.php?page=walletadmin&mode=liberar&id={$s.id}"
                                           onclick="return confirm('¿Liberar esta solicitud?\n\nVolverá a la cola y otro admin podrá tomarla.');">
                                            🔓 LIBERAR
                                        </a>
                                        <a class="wallet-btn wallet-btn-reject" 
                                           href="#modal_cancelar_{$s.id}">
                                            🔴 CANCELAR
                                        </a>
                                        
                                        <div id="modal_cancelar_{$s.id}" class="wallet-modal-bg">
                                            <div class="wallet-modal">
                                                <a href="#" class="wallet-modal-close">×</a>
                                                <h4 class="wallet-modal-title">🔴 Cancelar Inversión #{$s.id}</h4>
                                                <p style="font-size:11px; color:#94a3b8; margin:0 0 10px 0;">
                                                    El usuario será notificado. Esta acción es irreversible.
                                                </p>
                                                <form method="post" action="game.php?page=walletadmin&mode=cancelarAdmin">
                                                    <input type="hidden" name="id" value="{$s.id}">
                                                    <textarea name="motivo" rows="3" placeholder="Motivo de la cancelación (opcional)" maxlength="300"></textarea>
                                                    <div class="wallet-modal-actions">
                                                        <a href="#" class="wallet-btn wallet-btn-gray">Cancelar</a>
                                                        <button type="submit" class="wallet-btn wallet-btn-reject">Sí, cancelar solicitud</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No tenés solicitudes pendientes. 🎉</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 4 — VERIFICAR (Inversiones + Retiros)              *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'verificar'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>🔍 Comprobantes por Verificar ({$solicitudes|@count})</span>
            </h3>

            <div class="wallet-info-box">
                <strong>ℹ️ Estos usuarios ya hicieron la transferencia.</strong><br>
                Verificá en tu banco que la transferencia sea real y el monto coincida. Luego confirmá o rechazá.
            </div>

            {if $solicitudes|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Monto</th>
                            <th>ID Transferencia</th>
                            <th>Fecha comp.</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $solicitudes as $s}
                            <tr>
                                <td>#{$s.id}</td>
                                <td>
                                    <strong>{$s.username|escape:'html'}</strong>
                                    {if $s.tipo == 'retiro'}
                                        <span class="wallet-badge purple" style="margin-left:4px;">💲 RETIRO</span>
                                    {else}
                                        <span class="wallet-badge info" style="margin-left:4px;">💎 INVERSIÓN</span>
                                    {/if}
                                </td>
                                <td class="num {if $s.tipo == 'retiro'}nxt{else}kyber{/if}">
                                    {$s.cantidad_kyber} {if $s.tipo == 'retiro'}💲 NXT-20{else}💎 Kyber{/if}
                                </td>
                                <td>
                                    {if $s.referencia}
                                        <code style="background:rgba(0,0,0,0.3); padding:3px 8px; border-radius:4px; color:#fbbf24; font-family:'Courier New',monospace;">
                                            {$s.referencia|escape:'html'}
                                        </code>
                                    {else}
                                        <span style="color:#94a3b8;">—</span>
                                    {/if}
                                </td>
                                <td>{$s.fecha_comprobante}</td>
                                <td>
                                    {if $s.tipo == 'retiro'}
                                        <a class="wallet-btn wallet-btn-approve" 
                                           href="game.php?page=walletadmin&mode=verRetiro&id={$s.id}">
                                            ✅ VER DATOS / CONFIRMAR
                                        </a>
                                    {else}
                                        <form method="POST" 
                                              action="game.php?page=walletadmin&mode=confirmar" 
                                              style="display:inline-block; margin:0;">
                                            <input type="hidden" name="id" value="{$s.id}">
                                            <button type="submit" 
                                                    class="wallet-btn wallet-btn-approve"
                                                    onclick="return window.confirm('¿CONFIRMAR esta inversión?\n\nSe entregarán 💲 NXT-20 retirables al usuario.\nSe acreditará 💰 CUP a tu cuenta.');">
                                                ✅ CONFIRMAR INVERSIÓN
                                            </button>
                                        </form>
                                    {/if}

                                    <a class="wallet-btn wallet-btn-reject" 
                                       href="#modal_rechazar_{$s.id}">
                                        ❌ RECHAZAR
                                    </a>

                                    <div id="modal_rechazar_{$s.id}" class="wallet-modal-bg">
                                        <div class="wallet-modal">
                                            <a href="#" class="wallet-modal-close">×</a>
                                            <h4 class="wallet-modal-title">❌ Rechazar {if $s.tipo == 'retiro'}Retiro{else}Inversión{/if} #{$s.id}</h4>
                                            <p style="font-size:11px; color:#94a3b8; margin:0 0 10px 0;">
                                                Usuario: <strong style="color:#cbd5e1;">{$s.username|escape:'html'}</strong><br>
                                                Monto: <strong style="color:#00e0ff;">{$s.cantidad_kyber}</strong><br>
                                                ID transferencia: <code>{$s.referencia|escape:'html'}</code>
                                            </p>
                                            <p style="font-size:11px; color:#ef4444; margin:0 0 10px 0;">
                                                ⚠️ El motivo es obligatorio. El usuario lo verá.
                                            </p>
                                            <form method="post" action="game.php?page=walletadmin&mode={if $s.tipo == 'retiro'}rechazarRetiro{else}rechazar{/if}">
                                                <input type="hidden" name="id" value="{$s.id}">
                                                <textarea name="motivo" rows="3" placeholder="Ej: El ID de transferencia no coincide, el monto no llegó, etc." maxlength="300" required></textarea>
                                                <div class="wallet-modal-actions">
                                                    <a href="#" class="wallet-btn wallet-btn-gray">Cancelar</a>
                                                    <button type="submit" class="wallet-btn wallet-btn-reject">Sí, rechazar</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay comprobantes por verificar. 🎉</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 5 — HISTORIAL (Unificado)                          *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'historial'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📜 Historial de Solicitudes ({$solicitudes|@count})</span>
                {if $es_superadmin}
                    <span class="wallet-badge info">👑 Viendo TODAS las solicitudes</span>
                {else}
                    <span class="wallet-badge gray">Viendo solo las mías</span>
                {/if}
            </h3>
            
            <div class="wallet-info-box">
                <strong>ℹ️ Aquí se muestran todas las solicitudes cerradas:</strong><br>
                Completadas, Rechazadas, Canceladas (por user o admin) y Expiradas.
            </div>

            {if $solicitudes|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>Admin</th>
                            <th>Monto</th>
                            <th>Estado</th>
                            <th>Resuelta</th>
                            <th>Motivo</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $solicitudes as $s}
                            <tr>
                                <td>#{$s.id}</td>
                                <td>
                                    <strong>{$s.username|escape:'html'}</strong>
                                    {if $s.tipo == 'retiro'}
                                        <span class="wallet-badge purple" style="margin-left:4px;">💲 RETIRO</span>
                                    {else}
                                        <span class="wallet-badge info" style="margin-left:4px;">💎 INVERSIÓN</span>
                                    {/if}
                                </td>
                                <td>
                                    {if $s.admin_username}
                                        {$s.admin_username|escape:'html'}
                                    {else}
                                        <span style="color:#94a3b8;">—</span>
                                    {/if}
                                </td>
                                <td class="num {if $s.tipo == 'retiro'}nxt{else}kyber{/if}">
                                    {$s.cantidad_kyber} {if $s.tipo == 'retiro'}💲 NXT-20{else}💎 Kyber{/if}
                                </td>
                                <td><span class="wallet-badge {$s.estado_clase}">{$s.estado_label}</span></td>
                                <td>{$s.fecha_resolucion}</td>
                                <td>
                                    {if $s.motivo}
                                        <span style="font-size:10px; color:#94a3b8;" title="{$s.motivo|escape:'html'}">
                                            {$s.motivo|escape:'html'|truncate:40:"...":true}
                                        </span>
                                    {else}
                                        <span style="color:#94a3b8;">—</span>
                                    {/if}
                                </td>
                                <td>
                                    {if $s.tipo == 'inversion'}
                                        <a class="wallet-btn wallet-btn-reject" 
                                           href="game.php?page=walletadmin&mode=eliminar&id={$s.id}"
                                           onclick="return confirm('¿Eliminar esta solicitud del sistema?\n\n(No se borra de la base de datos, solo se oculta)');">
                                            🗑️ ELIMINAR
                                        </a>
                                    {else}
                                        <span style="font-size:10px; color:#94a3b8;">—</span>
                                    {/if}
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay solicitudes en el historial. 📜</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 5B — EN VIVO (AUDITORIA)                           *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'auditoria'}

        <div class="wallet-audit-status">
            <div>
                <span class="live-dot"></span>
                <strong>EN VIVO</strong> — Trámites activos de todos los admins
                <span class="last-update" id="envivo-last-update">
                    · Cargando...
                </span>
            </div>
            <div>
                <span class="total-count" id="envivo-total-count">
                    Total: {$total_tramites}
                </span>
            </div>
        </div>

        <div class="wallet-info-box" style="border-color:rgba(0,224,255,0.4); background:rgba(0,224,255,0.05);">
            <strong>ℹ️ ¿Qué es esta vista?</strong><br>
            Muestra <strong>todos los trámites activos</strong> del banco, agrupados por admin. 
            Sirve para auditoría: ver quién tiene cuántos trámites pendientes en tiempo real.
            <br><br>
            <em>Se actualiza automáticamente cada <strong>30 segundos</strong> sin recargar la página.</em>
        </div>

        <div id="envivo-content">

            {if $grupos|@count > 0}
                {foreach $grupos as $g}
                    <div class="wallet-audit-group {if $g.admin_id == 0}is-unassigned{elseif $g.admin_id == $user_id}is-me{/if}">
                        <div class="wallet-audit-header">
                            <div class="admin-name">
                                <span class="avatar">
                                    {if $g.admin_id == 0}⚠{else}{$g.admin_name|substr:0:1|upper}{/if}
                                </span>
                                {if $g.admin_id == 0}
                                    SIN ASIGNAR
                                {else}
                                    Admin: {$g.admin_name|escape:'html'}
                                    {if $g.admin_id == $user_id}
                                        <span class="badge-me">TÚ</span>
                                    {/if}
                                {/if}
                            </div>
                            <span class="count-badge">{$g.total} {if $g.total == 1}trámite{else}trámites{/if}</span>
                        </div>
                        <div class="wallet-audit-body">
                            {foreach $g.tramites as $t}
                                <div class="wallet-audit-row">
                                    <div class="row-left">
                                        <span class="tramite-id">#{$t.id}</span>
                                        <span class="user-name">{$t.username|escape:'html'}</span>
                                        <span class="kyber-amount {if $t.tipo == 'retiro'}nxt{else}kyber{/if}">{$t.cantidad_kyber} <small>{if $t.tipo == 'retiro'}💲 NXT-20{else}💎 Kyber{/if}</small></span>
                                    </div>
                                    <div class="row-right">
                                        <span class="wallet-badge {$t.estado_clase}">{$t.estado_label}</span>
                                        {if $t.referencia}
                                            <span style="font-family:'Courier New',monospace; font-size:10px; color:#fbbf24;">
                                                {$t.referencia|escape:'html'}
                                            </span>
                                        {/if}
                                        <span class="fecha">{$t.fecha}</span>
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    </div>
                {/foreach}
            {else}
                <div class="wallet-audit-empty">
                    <span class="big-icon">✨</span>
                    No hay trámites activos en este momento.
                </div>
            {/if}

        </div>

    {/if}
	
	    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 6B — CAMBIOS BANCARIOS (v6.0)                      *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'cambios_bancarios'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>💳 Solicitudes de Cambio de Datos Bancarios ({$solicitudes_cambio|@count})</span>
            </h3>

            <div class="wallet-info-box">
                <strong>ℹ️ Los usuarios solicitaron cambiar sus datos bancarios.</strong><br>
                Revisá que los nuevos datos sean correctos y aprobá o rechazá.
                Mientras no resuelvas, el usuario mantiene sus datos actuales.
            </div>

            {if $solicitudes_cambio|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Usuario</th>
                            <th>💳 Nueva Tarjeta</th>
                            <th>📱 Nuevo Teléfono</th>
                            <th>👤 Titular</th>
                            <th>🏛️ Banco</th>
                            <th>Solicitado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $solicitudes_cambio as $sc}
                            <tr>
                                <td>#{$sc.id}</td>
                                <td><strong>{$sc.username|escape:'html'}</strong></td>
                                <td class="num">{$sc.tarjeta_magnetica|escape:'html'}</td>
                                <td class="num">{$sc.telefono|escape:'html'}</td>
                                <td>{if $sc.titular}{$sc.titular|escape:'html'}{else}<span style="color:#94a3b8;">—</span>{/if}</td>
                                <td>{if $sc.banco}{$sc.banco|escape:'html'}{else}<span style="color:#94a3b8;">—</span>{/if}</td>
                                <td>{$sc.fecha_creacion}</td>
                                <td>
                                    <form method="POST" 
                                          action="game.php?page=walletadmin&mode=aprobarCambioDatos" 
                                          style="display:inline-block; margin:0;">
                                        <input type="hidden" name="id" value="{$sc.id}">
                                        <button type="submit" 
                                                class="wallet-btn wallet-btn-approve"
                                                onclick="return window.confirm('¿APROBAR el cambio de datos bancarios de {$sc.username}?\n\nLos nuevos datos se guardarán en su cuenta.');">
                                            ✅ APROBAR
                                        </button>
                                    </form>

                                    <a class="wallet-btn wallet-btn-reject" href="#modal_rechazar_cambio_{$sc.id}">
                                        ❌ RECHAZAR
                                    </a>

                                    <div id="modal_rechazar_cambio_{$sc.id}" class="wallet-modal-bg">
                                        <div class="wallet-modal">
                                            <a href="#" class="wallet-modal-close">×</a>
                                            <h4 class="wallet-modal-title">❌ Rechazar cambio de datos</h4>
                                            <p style="font-size:11px; color:#94a3b8; margin:0 0 10px 0;">
                                                Usuario: <strong style="color:#cbd5e1;">{$sc.username|escape:'html'}</strong><br>
                                                Mantendrá sus datos actuales.
                                            </p>
                                            <form method="post" action="game.php?page=walletadmin&mode=rechazarCambioDatos">
                                                <input type="hidden" name="id" value="{$sc.id}">
                                                <textarea name="motivo" rows="3" placeholder="Motivo del rechazo (obligatorio, mínimo 3 caracteres)" maxlength="300" required></textarea>
                                                <div class="wallet-modal-actions">
                                                    <a href="#" class="wallet-btn wallet-btn-gray">Cancelar</a>
                                                    <button type="submit" class="wallet-btn wallet-btn-reject">Sí, rechazar</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay solicitudes de cambio pendientes. 🎉</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 6C — SALDO CUP                                     *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'cup'}

        <div class="wallet-stats-grid">
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💰 Saldo Total CUP</div>
                <div class="wallet-stat-value cup">{$cup_saldo}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💼 Proyecto Total</div>
                <div class="wallet-stat-value orange">{$cup_marca}</div>
            </div>
            <div class="wallet-stat-card">
                <div class="wallet-stat-title">💰 Disponible Total</div>
                <div class="wallet-stat-value green">{$cup_disponible}</div>
            </div>
        </div>

        <div class="wallet-info-box" style="border-color:rgba(74,255,136,0.3); background:rgba(74,255,136,0.05);">
            <strong>💰 ¿Qué es la Cuenta CUP?</strong><br>
            Es un registro de auditoría interno del servidor: registra quién tiene físicamente
            el dinero real (💰 CUP) que entró por las inversiones de los usuarios.<br>
            <br>
            • Al confirmar una inversión: tu 💰 saldo CUP sube por el monto total<br>
            • El 27%/30% se marca como <strong>💼 proyecto</strong> (no es tuyo, es del servidor)<br>
            • Solo podés transferir tu <strong>💰 disponible</strong> (saldo - proyecto)<br>
            • Al confirmar un retiro: se descuenta el NETO (dinero real que sale al usuario)
        </div>

        <div class="wallet-section">
            <h3 class="wallet-section-title"><span>⚡ Acciones</span></h3>
            <a class="wallet-btn wallet-btn-approve wallet-btn-lg" 
               href="game.php?page=walletadmin&mode=transferir">
                📤 TRANSFERIR A OTRO ADMIN
            </a>
            <a class="wallet-btn wallet-btn-info wallet-btn-lg" 
               href="game.php?page=walletadmin&mode=historialCup">
                📜 VER HISTORIAL COMPLETO
            </a>
            {if $es_superadmin}
                <a class="wallet-btn wallet-btn-warning wallet-btn-lg" 
                   href="game.php?page=walletadmin&mode=ajusteManual">
                    ⚙️ AJUSTE MANUAL (SUPERADMIN)
                </a>
            {/if}
        </div>

        {if $count_trans_rec > 0}
        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📬 Transferencias por Aceptar ({$count_trans_rec})</span>
            </h3>
            <div class="wallet-info-box" style="border-color:rgba(0,224,255,0.4); background:rgba(0,224,255,0.05);">
                <strong>ℹ️ Otros admins quieren transferirte 💰 CUP.</strong><br>
                Debés aceptar o rechazar. Si no respondés en 24h, expira automáticamente.
            </div>
            <div class="wallet-table-wrap">
            <table class="wallet-table">
                <thead>
                    <tr>
                        <th>De</th>
                        <th>Monto</th>
                        <th>Fecha</th>
                        <th>Expira</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $trans_recibidas as $t}
                        <tr>
                            <td><strong>{$t.from_username|escape:'html'}</strong></td>
                            <td class="num cup">{$t.monto} 💰 CUP</td>
                            <td>{$t.fecha}</td>
                            <td>{$t.expira}</td>
                            <td>
                                <form method="post" action="game.php?page=walletadmin&mode=aceptarTransferencia" style="display:inline;">
                                    <input type="hidden" name="id" value="{$t.id}">
                                    <button type="submit" class="wallet-btn wallet-btn-approve"
                                            onclick="return confirm('¿Aceptar esta transferencia de {$t.monto} 💰 CUP?');">
                                        ✅ ACEPTAR
                                    </button>
                                </form>
                                <form method="post" action="game.php?page=walletadmin&mode=rechazarTransferencia" style="display:inline;">
                                    <input type="hidden" name="id" value="{$t.id}">
                                    <button type="submit" class="wallet-btn wallet-btn-reject"
                                            onclick="return confirm('¿Rechazar esta transferencia?');">
                                        ❌ RECHAZAR
                                    </button>
                                </form>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
            </div>
        </div>
        {/if}

        {if $count_trans_env > 0}
        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📤 Transferencias Enviadas Pendientes ({$count_trans_env})</span>
            </h3>
            <div class="wallet-table-wrap">
            <table class="wallet-table">
                <thead>
                    <tr>
                        <th>Para</th>
                        <th>Monto</th>
                        <th>Fecha</th>
                        <th>Expira</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $trans_enviadas as $t}
                        <tr>
                            <td><strong>{$t.to_username|escape:'html'}</strong></td>
                            <td class="num cup">{$t.monto} 💰 CUP</td>
                            <td>{$t.fecha}</td>
                            <td>{$t.expira}</td>
                            <td>
                                <form method="post" action="game.php?page=walletadmin&mode=cancelarTransferencia" style="display:inline;">
                                    <input type="hidden" name="id" value="{$t.id}">
                                    <button type="submit" class="wallet-btn wallet-btn-warning"
                                            onclick="return confirm('¿Cancelar esta transferencia?');">
                                        ❌ CANCELAR
                                    </button>
                                </form>
                            </td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
            </div>
        </div>
        {/if}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>👥 Saldos de Todos los Admins</span>
                <span class="wallet-badge info">TODOS SE VEN ENTRE SÍ</span>
            </h3>
            {if $cuentas_admin|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>Admin</th>
                            <th>Nivel</th>
                            <th>💰 Saldo</th>
                            <th>💼 Marca Proyecto</th>
                            <th>💰 Disponible</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $cuentas_admin as $c}
                            <tr>
                                <td>
                                    <strong>{$c.username|escape:'html'}</strong>
                                    {if $c.es_yo}<span class="wallet-badge ok">TÚ</span>{/if}
                                </td>
                                <td>{$c.authlevel}</td>
                                <td class="num cup">{$c.saldo} 💰 CUP</td>
                                <td class="num proy">{$c.marca} 💼 CUP</td>
                                <td class="num green">{$c.disponible} 💰 CUP</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay cuentas 💰 CUP registradas.</div>
            {/if}
        </div>

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📜 Últimos Movimientos {if $es_superadmin}(Todos los Admins){/if}</span>
                <a href="game.php?page=walletadmin&mode=historialCup" class="wallet-btn wallet-btn-gray">
                    Ver todos →
                </a>
            </h3>
            {if $movimientos|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Tipo</th>
                            <th>Admin (Dueño)</th> <!-- NUEVA COLUMNA -->
                            <th>Monto</th>
                            <th>Saldo</th>
                            <th>Admin Rel.</th>
                            <th>Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $movimientos as $m}
                            <tr>
                                <td>{$m.fecha}</td>
                                <td><span class="wallet-badge gray">{$m.tipo}</span></td>
                                <td><strong style="color:#00e0ff;">{$m.admin_dueno|escape:'html'}</strong></td> <!-- NUEVA COLUMNA -->
                                <td class="num {if $m.monto_raw >= 0}pos{else}neg{/if}">
                                    {if $m.monto_raw >= 0}+{/if}{$m.monto}
                                </td>
                                <td class="num">{$m.saldo}</td>
                                <td>{if $m.admin_rel}{$m.admin_rel|escape:'html'}{else}—{/if}</td>
                                <td style="font-size:10px; color:#94a3b8;">{$m.detalle|escape:'html'}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay movimientos todavía.</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 6D — HISTORIAL CUP (con filtros)                   *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'cup_historial'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>📜 Historial de Movimientos 💰 CUP</span>
                <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-btn wallet-btn-gray">
                    ← Volver
                </a>
            </h3>

            <form method="GET" action="game.php" style="margin-bottom:12px;">
                <input type="hidden" name="page" value="walletadmin">
                <input type="hidden" name="mode" value="historialCup">
                <div class="wallet-stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));">
                    <div>
                        <label class="wallet-form-label">Tipo</label>
                        <select name="tipo" style="width:100%; background:rgba(0,0,0,0.5); border:1px solid var(--rn-border); border-radius:8px; padding:8px; color:#ffffff;">
                            <option value="">Todos</option>
                            <option value="inversion" {if $filtros.tipo == 'inversion'}selected{/if}>Inversión</option>
                            <option value="retiro" {if $filtros.tipo == 'retiro'}selected{/if}>Retiro</option>
                            <option value="transferencia_enviada" {if $filtros.tipo == 'transferencia_enviada'}selected{/if}>Transf. enviada</option>
                            <option value="transferencia_recibida" {if $filtros.tipo == 'transferencia_recibida'}selected{/if}>Transf. recibida</option>
                            <option value="retiro_proyecto" {if $filtros.tipo == 'retiro_proyecto'}selected{/if}>Retiro Proyecto</option>
                            <option value="ajuste_manual" {if $filtros.tipo == 'ajuste_manual'}selected{/if}>Ajuste manual</option>
                            <option value="transferencia_cancelada" {if $filtros.tipo == 'transferencia_cancelada'}selected{/if}>Transf. cancelada</option>
                        </select>
                    </div>
                    <div>
                        <label class="wallet-form-label">Desde</label>
                        <input type="date" name="desde" value="{$filtros.desde}" style="width:100%; background:rgba(0,0,0,0.5); border:1px solid var(--rn-border); border-radius:8px; padding:8px; color:#ffffff;">
                    </div>
                    <div>
                        <label class="wallet-form-label">Hasta</label>
                        <input type="date" name="hasta" value="{$filtros.hasta}" style="width:100%; background:rgba(0,0,0,0.5); border:1px solid var(--rn-border); border-radius:8px; padding:8px; color:#ffffff;">
                    </div>
                    <div style="display:flex; align-items:flex-end;">
                        <button type="submit" class="wallet-btn wallet-btn-primary wallet-btn-lg" style="width:100%;">
                            🔍 FILTRAR
                        </button>
                    </div>
                </div>
            </form>

            {if $movimientos|@count > 0}
                <div class="wallet-table-wrap">
                <table class="wallet-table">
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Tipo</th>
                            <th>Admin (Dueño)</th> <!-- NUEVA COLUMNA -->
                            <th>Monto</th>
                            <th>Saldo</th>
                            <th>Admin Rel.</th>
                            <th>Ref.</th>
                            <th>Detalle</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $movimientos as $m}
                            <tr>
                                <td>{$m.fecha}</td>
                                <td><span class="wallet-badge gray">{$m.tipo}</span></td>
                                <td><strong style="color:#00e0ff;">{$m.admin_dueno|escape:'html'}</strong></td> <!-- NUEVA COLUMNA -->
                                <td class="num {if $m.monto_raw >= 0}pos{else}neg{/if}">
                                    {if $m.monto_raw >= 0}+{/if}{$m.monto}
                                </td>
                                <td class="num">{$m.saldo}</td>
                                <td>{if $m.admin_rel}{$m.admin_rel|escape:'html'}{else}—{/if}</td>
                                <td>{if $m.referencia_id > 0}#{$m.referencia_id}{else}—{/if}</td>
                                <td style="font-size:10px; color:#94a3b8;">{$m.detalle|escape:'html'}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
                </div>
            {else}
                <div class="wallet-empty">No hay movimientos con esos filtros.</div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 7 — GANANCIAS (FONDO PROYECTO)                     *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'ganancias'}

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>💼 Ganancias del Proyecto</span>
            </h3>

            <div class="wallet-stats-grid">
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">💼 Fondo Proyecto Acumulado</div>
                    <div class="wallet-stat-value orange">{$fondo_proyecto}</div>
                </div>
            </div>

            <div class="wallet-info-box" style="border-color:rgba(251,191,36,0.3); background:rgba(251,191,36,0.05);">
                <strong>💰 ¿Cómo se acumula este fondo? (v6.0)</strong><br>
                • Inversión: <strong>{$pct_inv_proyecto}%</strong> del CUP va al proyecto 
                  (sin referidor: <strong>{$pct_inv_proyecto_sin_ref}%</strong>)<br>
                • Retiro: <strong>{$pct_ret_proyecto}%</strong> del bruto del retiro 
                  + <strong>{$pct_ret_referidor}%</strong> si el usuario no tiene referidor<br>
                <br>
                <em>Ejemplo:</em> inversión de 1000 💎 Kyber → <strong>270 💎 Kyber</strong> al proyecto (vía CUP).<br>
                Retiro de 100 💲 NXT-20 → <strong>7 💎 Kyber</strong> al proyecto (+3 si no hay referidor).
            </div>

            {if $es_superadmin}
                {if $admins_con_marca|@count > 0}
                    <form method="POST" action="game.php?page=walletadmin&mode=doRetirarProyecto">
                        <div class="wallet-form-group">
                            <label class="wallet-form-label">Admin del cual retirar (tiene 💼 marca proyecto)</label>
                            <div class="wallet-input-group" style="max-width:100%;">
                                <select name="target_admin_id" required>
                                    <option value="">— Elegir admin —</option>
                                    {foreach $admins_con_marca as $adm}
                                        <option value="{$adm.admin_id}" {if !$adm.tiene_fondo}disabled{/if}>
                                            {$adm.username|escape:'html'} — {$adm.marca_proyecto} 💼 CUP {if !$adm.tiene_fondo}(Sin fondo){/if}
                                        </option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                        <div class="wallet-form-group">
                            <label class="wallet-form-label">Cantidad a retirar</label>
                            <div class="wallet-input-group">
                                <input type="number" name="cantidad" min="1" placeholder="0" required>
                                <span class="wallet-input-suffix">💰 CUP</span>
                            </div>
                            <p style="font-size:10px; color:#94a3b8; margin:6px 0 0 0;">
                                Se descuenta exactamente del admin elegido. Se acredita a tu 💰 cuenta CUP.
                            </p>
                        </div>
                        <button type="submit" class="wallet-btn wallet-btn-warning wallet-btn-lg" 
                                onclick="return confirm('¿Retirar esta cantidad del fondo del proyecto?\n\nSe descontará del admin elegido y se acreditará a tu 💰 cuenta CUP.');">
                            💸 RETIRAR A MI CUENTA CUP
                        </button>
                    </form>

                    <div class="wallet-table-wrap" style="margin-top: 15px;">
                        <table class="wallet-table">
                            <thead>
                                <tr>
                                    <th>Admin</th>
                                    <th>Saldo Total</th>
                                    <th>Marca Proyecto (Disponible para retirar)</th>
                                </tr>
                            </thead>
                            <tbody>
                                {foreach $admins_con_marca as $adm}
                                    <tr>
                                        <td><strong>{$adm.username|escape:'html'}</strong></td>
                                        <td class="num cup">{$adm.saldo} 💰 CUP</td>
                                        <td class="num {if $adm.marca_raw > 0}proy{else}gray{/if}">
                                            {$adm.marca_proyecto} 💼 CUP
                                        </td>
                                    </tr>
                                {/foreach}
                            </tbody>
                        </table>
                    </div>
                {else}
                    <div class="wallet-empty">
                        No hay admins con 💼 marca proyecto registrada.
                    </div>
                {/if}
            {else}
                <div class="wallet-info-box" style="border-color:rgba(239,68,68,0.3); background:rgba(239,68,68,0.05);">
                    🔒 <strong>Solo el superadmin puede retirar el fondo del proyecto.</strong>
                </div>
            {/if}
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 8 — CONFIGURACIÓN                                  *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'config'}

        <div class="wallet-section">
            <h3 class="wallet-section-title"><span>⚙️ Estado del Banco (v6.0)</span></h3>

            <div class="wallet-stats-grid">
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">Estado Retiros</div>
                    <div class="wallet-stat-value {if $retiros_abiertos}green{else}red{/if}">
                        {if $retiros_abiertos}🟢 ABIERTO{else}🔒 CERRADO{/if}
                    </div>
                </div>
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">💎 Kyber en el Banco</div>
                    <div class="wallet-stat-value green">{$kyber_banco}</div>
                </div>
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">💲 Total Invertido</div>
                    <div class="wallet-stat-value green">{$total_invertido}</div>
                </div>
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">💲 Total Retirado</div>
                    <div class="wallet-stat-value red">{$total_retirado}</div>
                </div>
            </div>

            <div class="wallet-info-box">
                📅 Apertura: <strong>{$fecha_apertura}</strong><br>
                📅 Último cierre: <strong>{$fecha_cierre}</strong>
            </div>

            <div class="wallet-info-box" style="border-color:rgba(139,92,246,0.3); background:rgba(139,92,246,0.05);">
                <strong>🛡️ Modelo v6.0 (SIN AMM):</strong><br>
                <code>Inversión: 100 💎 Kyber = 100 💲 NXT-20 retirables</code><br>
                <code>Retiro: 100 💲 NXT-20 = 90 💎 Kyber netos (10% comisión)</code><br>
                • Al invertir: 100% del Kyber va al banco<br>
                • Al retirar: se descuenta el bruto del banco<br>
                • El banco <strong>nunca quiebra</strong>: siempre hay Kyber disponible.
            </div>
        </div>

        <div class="wallet-section">
            <h3 class="wallet-section-title">
                <span>🎯 Mínimo de Retiro (Configurable)</span>
            </h3>
            <div class="wallet-info-box">
                El usuario debe tener <strong>VIP activo</strong> y cumplir este mínimo 
                (sobre el monto <strong>bruto</strong> de 💲 NXT-20) para poder retirar.
            </div>
            <form method="POST" action="game.php?page=walletadmin&mode=doSaveMinimos">
                <div class="wallet-form-group">
                    <label class="wallet-form-label">Mínimo en 💲 NXT-20 (bruto)</label>
                    <div class="wallet-input-group">
                        <input type="number" name="min_retiro_nxt20" min="0" value="{$min_retiro_nxt20}">
                        <span class="wallet-input-suffix">💲 NXT-20</span>
                    </div>
                    <p style="font-size:10px; color:#94a3b8; margin:6px 0 0 0;">
                        Default: 300 💲 NXT-20. Este mínimo no puede ser menor a 1.
                    </p>
                </div>
                <button type="submit" class="wallet-btn wallet-btn-approve wallet-btn-lg">
                    💾 GUARDAR MÍNIMO
                </button>
            </form>
        </div>

        {if !$retiros_abiertos}
        <div class="wallet-section">
            <h3 class="wallet-section-title"><span>🟢 Abrir Retiros</span></h3>
            <form method="POST" action="game.php?page=walletadmin&mode=openWithdrawals">
                <div class="wallet-form-group">
                    <label class="wallet-form-label">Duración (horas, 0 = sin límite)</label>
                    <div class="wallet-input-group">
                        <input type="number" name="duracion" min="0" value="0">
                        <span class="wallet-input-suffix">HORAS</span>
                    </div>
                </div>
                <button type="submit" class="wallet-btn wallet-btn-approve wallet-btn-lg" 
                        onclick="return confirm('¿Abrir los retiros ahora?');">
                    🟢 ABRIR RETIROS
                </button>
            </form>
        </div>
        {else}
        <div class="wallet-section">
            <h3 class="wallet-section-title"><span>🔒 Cerrar Retiros</span></h3>
            <div class="wallet-info-box" style="border-color:rgba(239,68,68,0.4); background:rgba(239,68,68,0.05);">
                ⚠️ Al cerrar los retiros se detendrán las solicitudes hasta que los abras de nuevo.
            </div>
            <form method="POST" action="game.php?page=walletadmin&mode=closeWithdrawals">
                <button type="submit" class="wallet-btn wallet-btn-reject wallet-btn-lg" 
                        onclick="return confirm('¿Cerrar los retiros?');">
                    🔒 CERRAR RETIROS
                </button>
            </form>
        </div>
        {/if}

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 9 — CONFIGURACIÓN QVAPAY (NUEVO)                   *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'qvapay'}

        <div class="wallet-section" style="border-color: rgba(0, 224, 255, 0.4); background: rgba(0, 224, 255, 0.03);">
            <h3 class="wallet-section-title" style="color: #00e0ff;">
                <span>💳 Configuración de QvaPay (Pasarela de Pago)</span>
            </h3>

            {if $qp_msg}
                <div class="wallet-msg-ok">{$qp_msg}</div>
            {/if}
            {if $qp_err}
                <div class="wallet-msg-error">{$qp_err}</div>
            {/if}

            <div class="wallet-info-box">
                <strong>ℹ️ ¿Qué es esto?</strong><br>
                Acá configurás <b>tu propia cuenta de QvaPay</b> para recibir pagos por inversiones y pagar retiros de forma automática. 
                Si no tenés una App creada, andá al panel de desarrollador de QvaPay y creala.
            </div>

            <form method="post" action="game.php?page=walletadmin&mode=qvapay">
                <input type="hidden" name="qvapay_action" value="save">

                <div class="wallet-stats-grid" style="grid-template-columns: 1fr; gap: 10px; margin-bottom: 15px;">
                    <label style="color: #cbd5e1; font-weight: 600; font-size: 12px; cursor: pointer;">
                        <input type="checkbox" name="qvapay_enabled" value="1" {if $qp_cfg.enabled}checked{/if}>
                        <b>Activar QvaPay en mi cuenta</b> (Muestra los botones de pago en el juego)
                    </label>
                    <label style="color: #cbd5e1; font-weight: 600; font-size: 12px; cursor: pointer;">
                        <input type="checkbox" name="qvapay_habilitado_inversion" value="1" {if $global_cfg.qvapay_habilitado_inversion}checked{/if}>
                        Habilitar Compra de Kyber vía QvaPay (Global)
                    </label>
                    <label style="color: #cbd5e1; font-weight: 600; font-size: 12px; cursor: pointer;">
                        <input type="checkbox" name="qvapay_habilitado_retiro" value="1" {if $global_cfg.qvapay_habilitado_retiro}checked{/if}>
                        Habilitar Retiros Automáticos vía QvaPay (Global)
                    </label>
                </div>

                <div class="wallet-info-box" style="background: rgba(0,0,0,0.3);">
                    <div class="wallet-form-group">
                        <label class="wallet-form-label">App ID (Tu UUID):</label>
                        <div class="wallet-input-group" style="max-width: 100%;">
                            <input type="text" name="qvapay_app_id" value="{$qp_cfg.app_id}" placeholder="Ej: 00030a63-d376-46e8-ba7e-7845e9ecc3e2">
                        </div>
                    </div>
                    <div class="wallet-form-group">
                        <label class="wallet-form-label">App Secret (Tu Clave):</label>
                        <div class="wallet-input-group" style="max-width: 100%;">
                            <input type="password" name="qvapay_app_secret" placeholder="{if $qp_cfg.app_secret}•••••••••••••••• (Ya guardado){else}Sin configurar{/if}">
                        </div>
                    </div>
                    <div class="wallet-form-group">
                        <label class="wallet-form-label">Callback URL (Webhook):</label>
                        <div class="wallet-input-group" style="max-width: 100%;">
                            <input type="url" name="qvapay_callback_url" value="{if $qp_cfg.callback_url}{$qp_cfg.callback_url}{else}{$defaultCallback}{/if}">
                        </div>
                    </div>
                    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                        <div class="wallet-form-group" style="flex: 1; min-width: 150px;">
                            <label class="wallet-form-label">Tasa CUP por Kyber:</label>
                            <div class="wallet-input-group">
                                <input type="number" step="0.0001" name="qvapay_tasa_cup_por_kyber" value="{$qp_cfg.tasa_cup_por_kyber}">
                                <span class="wallet-input-suffix">CUP</span>
                            </div>
                        </div>
                        <div class="wallet-form-group" style="flex: 1; min-width: 150px;">
                            <label class="wallet-form-label">Fee Retiro (%):</label>
                            <div class="wallet-input-group">
                                <input type="number" step="0.01" name="qvapay_fee_retiro_pct" value="{$qp_cfg.fee_retiro_pct}">
                                <span class="wallet-input-suffix">%</span>
                            </div>
                        </div>
                    </div>
                </div>

                <button type="submit" class="wallet-btn wallet-btn-approve wallet-btn-lg" style="margin-top: 10px;">
                    💾 GUARDAR CONFIGURACIÓN QVAPAY
                </button>
            </form>

            <hr style="border-color: var(--rn-border); margin: 15px 0;">

            <form method="post" action="game.php?page=walletadmin&mode=qvapay">
                <input type="hidden" name="qvapay_action" value="test">
                <button type="submit" class="wallet-btn wallet-btn-warning wallet-btn-lg">
                    🔌 PROBAR CONEXIÓN CON QVAPAY
                </button>
            </form>
        </div>

    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 10 — MERCADO CRUZADO (NUEVO)                       *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'crossmarket'}
        <div class="wallet-section">
            <h3 class="wallet-section-title" style="color: #00e0ff;">
                <span>🌐 Panel del Mercado Cruzado</span>
            </h3>

            {if $feedback_ok}
                <div class="wallet-msg-ok">✅ {$feedback_ok}</div>
            {/if}
            {if $feedback_error}
                <div class="wallet-msg-error">❌ {$feedback_error}</div>
            {/if}

            <div class="wallet-stats-grid">
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">Reserva Nacional (CUP)</div>
                    <div class="wallet-stat-value gold">{$balance_nac} CUP</div>
                </div>
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">Reserva Internacional (UNTX)</div>
                    <div class="wallet-stat-value cyan">{$balance_int} UNTX</div>
                </div>
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">Spread (CUP)</div>
                    <div class="wallet-stat-value green">{$spread_nac} CUP</div>
                </div>
                <div class="wallet-stat-card">
                    <div class="wallet-stat-title">Spread (UNTX)</div>
                    <div class="wallet-stat-value green">{$spread_int} UNTX</div>
                </div>
            </div>

            <div class="wallet-info-box" style="border-color:rgba(0,224,255,0.4); background:rgba(0,224,255,0.05);">
                <strong>💱 Tasa de Cambio Actual:</strong> 1 USD = {$tasa_qvapay} CUP. <br>
                Esta tasa se obtiene automáticamente de QvaPay.
            </div>

            <!-- Formulario de Conciliación -->
            <div class="wallet-info-box" style="background: rgba(0,0,0,0.3); margin-top: 20px;">
                <h4 style="color: #fbbf24; margin: 0 0 10px 0;">⚖️ Registrar Movimiento en QvaPay (Rebalanceo)</h4>
                <p style="font-size: 11px; color: #94a3b8; margin-bottom: 15px;">
                    Usa este formulario cuando hayas movido dinero real en tu cuenta de QvaPay. 
                    El sistema ajustará las reservas del juego para que coincidan con tu saldo real.
                </p>
                
                <form method="POST" action="game.php?page=walletadmin&mode=doCrossRebalance">
                    <div style="display: flex; gap: 15px; margin-bottom: 15px; flex-wrap: wrap;">
                        <div style="flex: 1; min-width: 200px;">
                            <label class="wallet-form-label">Desde (Restar)</label>
                            <div class="wallet-input-group" style="max-width: 100%;">
                                <select name="from_currency" style="width: 100%;">
                                    <option value="UNTX20_INT">UNTX-20 (QvaPay)</option>
                                    <option value="NTX20_NAC">NTX-20 (CUP)</option>
                                </select>
                            </div>
                        </div>
                        <div style="flex: 1; min-width: 200px;">
                            <label class="wallet-form-label">Cantidad a restar</label>
                            <div class="wallet-input-group" style="max-width: 100%;">
                                <input type="number" name="amount_from" placeholder="Ej: 10" required>
                            </div>
                        </div>
                        <div style="flex: 1; min-width: 200px;">
                            <label class="wallet-form-label">Hacia (Sumar)</label>
                            <div class="wallet-input-group" style="max-width: 100%;">
                                <select name="to_currency" style="width: 100%;">
                                    <option value="NTX20_NAC">NTX-20 (CUP)</option>
                                    <option value="UNTX20_INT">UNTX-20 (QvaPay)</option>
                                </select>
                            </div>
                        </div>
                        <div style="flex: 1; min-width: 200px;">
                            <label class="wallet-form-label">Cantidad a sumar</label>
                            <div class="wallet-input-group" style="max-width: 100%;">
                                <input type="number" name="amount_to" placeholder="Ej: 8200" required>
                            </div>
                        </div>
                    </div>
                    
                    <div class="wallet-form-group">
                        <label class="wallet-form-label">Nota / Referencia</label>
                        <div class="wallet-input-group" style="max-width: 100%;">
                            <input type="text" name="note" placeholder="Ej: Cambio con operador #123">
                        </div>
                    </div>
                    
                    <button type="submit" class="wallet-btn wallet-btn-approve wallet-btn-lg">
                        💾 REGISTRAR MOVIMIENTO Y ACTUALIZAR RESERVAS
                    </button>
                </form>
            </div>

            <!-- Historial de Conciliaciones -->
            <div class="wallet-section" style="margin-top: 20px;">
                <h3 class="wallet-section-title" style="color: #fbbf24;">Últimos Movimientos Manuales</h3>
                {if $rebalance_events|@count > 0}
                    <div class="wallet-table-wrap">
                        <table class="wallet-table">
                            <thead>
                                <tr>
                                    <th>Fecha</th>
                                    <th>Admin</th>
                                    <th>Movimiento</th>
                                    <th>Nota</th>
                                </tr>
                            </thead>
                            <tbody>
                                {foreach $rebalance_events as $re}
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
                    </div>
                {else}
                    <div class="wallet-empty">No hay movimientos registrados aún.</div>
                {/if}
            </div>

            <!-- Órdenes y Cruces -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">
                <div class="wallet-section">
                    <h3 class="wallet-section-title" style="color: #00e0ff;">Órdenes Abiertas</h3>
                    {if $open_orders|@count > 0}
                        <div class="wallet-table-wrap">
                            <table class="wallet-table">
                                <thead>
                                    <tr>
                                        <th>Jugador</th>
                                        <th>Tipo</th>
                                        <th>Item</th>
                                        <th>Precio</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {foreach $open_orders as $o}
                                        <tr>
                                            <td>{$o.username}</td>
                                            <td style="color: {if $o.is_sell}#fbbf24{else}#00e0ff{/if};">{$o.side_label}</td>
                                            <td>{$o.item_name} x{$o.amount_fmt}</td>
                                            <td>{$o.price_fmt} {if $o.is_sell}CUP{else}UNTX{/if}</td>
                                        </tr>
                                    {/foreach}
                                </tbody>
                            </table>
                        </div>
                    {else}
                        <div class="wallet-empty">No hay órdenes abiertas.</div>
                    {/if}
                </div>

                <div class="wallet-section">
                    <h3 class="wallet-section-title" style="color: #4aff88;">Últimos Cruces</h3>
                    {if $trades|@count > 0}
                        <div class="wallet-table-wrap">
                            <table class="wallet-table">
                                <thead>
                                    <tr>
                                        <th>Item</th>
                                        <th>Comprador</th>
                                        <th>Vendedor</th>
                                        <th>Spread</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {foreach $trades as $t}
                                        <tr>
                                            <td>{$t.item_name}</td>
                                            <td style="color:#00e0ff;">{$t.buyer_name}</td>
                                            <td style="color:#fbbf24;">{$t.seller_name}</td>
                                            <td style="color:#4aff88;">+{$t.spread_fmt} {$t.spread_curr}</td>
                                        </tr>
                                    {/foreach}
                                </tbody>
                            </table>
                        </div>
                    {else}
                        <div class="wallet-empty">No hay cruces aún.</div>
                    {/if}
                </div>
            </div>

        </div>
    {/if}

    {* ═══════════════════════════════════════════════════════ *}
    {* TAB 11 — AJUSTE MANUAL UNTX-20 (NUEVO)                 *}
    {* ═══════════════════════════════════════════════════════ *}
    {if $tab == 'ajuste_untx'}
        <div class="wallet-section">
            <h3 class="wallet-section-title" style="color: #00e0ff;">
                <span>💲 Ajuste Manual de UNTX-20 (Sistema Internacional)</span>
            </h3>

            <div class="wallet-info-box" style="border-color:rgba(0,224,255,0.3); background:rgba(0,224,255,0.05);">
                <strong>ℹ️ Herramienta exclusiva del Superadmin.</strong><br>
                Usá este formulario para <strong>dar o quitar</strong> UNTX-20 a un jugador manualmente. 
                Si pones un número negativo (ej: -50), se le restará ese saldo (siempre que tenga suficiente).
            </div>

            <form method="POST" action="game.php?page=walletadmin&mode=doAjusteManualUntx">
                <div class="wallet-form-group">
                    <label class="wallet-form-label">Seleccionar Jugador</label>
                    <div class="wallet-input-group" style="max-width: 100%;">
                        <select name="user_id" required>
                            <option value="">— Elegir jugador —</option>
                            {foreach $jugadores as $j}
                                <option value="{$j.id}">
                                    {$j.username|escape:'html'} (ID: {$j.id}) — Actual: {$j.untx20} UNTX-20
                                </option>
                            {/foreach}
                        </select>
                    </div>
                </div>

                <div class="wallet-form-group">
                    <label class="wallet-form-label">Cantidad a Dar / Quitar</label>
                    <div class="wallet-input-group">
                        <input type="number" name="monto" placeholder="Ej: 500 (positivo) o -100 (negativo)" required>
                        <span class="wallet-input-suffix">UNTX-20</span>
                    </div>
                    <p style="font-size:10px; color:#94a3b8; margin:6px 0 0 0;">
                        Usá números positivos para dar saldo y negativos para quitarlo.
                    </p>
                </div>

                <div class="wallet-form-group">
                    <label class="wallet-form-label">Motivo del ajuste (obligatorio)</label>
                    <div class="wallet-input-group" style="max-width: 100%;">
                        <input type="text" name="motivo" placeholder="Ej: Compensación por error, regalo, etc." required>
                    </div>
                </div>

                <button type="submit" class="wallet-btn wallet-btn-approve wallet-btn-lg" 
                        onclick="return confirm('¿Aplicar este ajuste de UNTX-20 al jugador seleccionado?');">
                    💾 APLICAR AJUSTE UNTX-20
                </button>
            </form>
        </div>
    {/if}

</div>

<!-- ApexCharts desde CDN -->
<script src="https://cdn.jsdelivr.net/npm/apexcharts@3.45.0/dist/apexcharts.min.js"></script>

<script>
/* ─── Validación de motivo (para modales de rechazo/cancelación) ─── */
function validarMotivo(form) {
    if (!form.motivo.value || form.motivo.value.length < 3) {
        alert('El motivo debe tener al menos 3 caracteres.');
        return false;
    }
    return true;
}

window.addEventListener('load', function() {
    var chartEl = document.querySelector('#poolChart');

    if (!chartEl || typeof ApexCharts === 'undefined') {
        return;
    }

    // Forzar altura antes de renderizar
    chartEl.style.height = '220px';
    chartEl.style.minHeight = '220px';
    chartEl.style.width = '100%';

    var chart = null;
    var currentHoras = 360;

    // ANOTACIÓN ÚNICA (Línea punteada tipo Kriptomat)
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
                        fontSize: '10px',
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
                height: 220,
                background: 'transparent',
                toolbar: { show: false },
                zoom: { enabled: false },
                animations: { enabled: true, speed: 600 },
                fontFamily: 'inherit',
                parentHeightOffset: 0
            },
            series: [
                { name: '💎 Kyber en el Banco', data: kyberBanco, type: 'area' }
            ],
            xaxis: {
                categories: categorias,
                labels: {
                    style: { colors: '#64748b', fontSize: '9px' },
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
                    style: { colors: '#64748b', fontSize: '9px' },
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
            markers: {
                size: 0,
                strokeWidth: 2,
                hover: { size: 4, sizeOffset: 0 }
            },
            tooltip: {
                theme: 'dark',
                style: { fontSize: '11px' },
                x: { show: true },
                y: {
                    formatter: function(v) { return Number(v).toLocaleString('es-AR') + ' Kyber'; }
                },
                marker: { show: true },
                followCursor: true
            },
            annotations: buildAnnotation(ultimo),
            noData: {
                text: 'Aún no hay datos suficientes...',
                align: 'center',
                verticalAlign: 'middle',
                style: { color: '#94a3b8', fontSize: '12px' }
            },
            legend: { show: false }
        };
    }

    function cargarGrafico() {
        fetch('game.php?page=walletadmin&mode=getGrafico&horas=' + currentHoras)
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var categorias = data.map(function(d) { return d.fecha; });
                var kyberBanco = data.map(function(d) { return Number(d.kyber_banco) || 0; });

                var priceEls = document.querySelectorAll('.wallet-chart-price-display');
                if (kyberBanco.length > 0 && priceEls.length > 0) {
                    var ultimo = Number(kyberBanco[kyberBanco.length - 1]).toLocaleString('es-AR');
                    for (var j = 0; j < priceEls.length; j++) {
                        priceEls[j].textContent = ultimo;
                    }
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
                        { name: '💎 Kyber en el Banco', data: kyberBanco }
                    ]);
                }
            })
            .catch(function(err) {
                console.error('Error cargando gráfico admin:', err);
            });
    }

    var timeWraps = document.querySelectorAll('.wallet-chart-times');
    for (var i = 0; i < timeWraps.length; i++) {
        timeWraps[i].addEventListener('click', function(e) {
            var btn = e.target.closest('.wallet-time-btn');
            if (!btn) return;
            var horas = parseInt(btn.getAttribute('data-horas'), 10);
            if (isNaN(horas)) return;

            var hermanos = this.querySelectorAll('.wallet-time-btn');
            for (var k = 0; k < hermanos.length; k++) {
                hermanos[k].classList.remove('active');
            }
            btn.classList.add('active');

            currentHoras = horas;
            cargarGrafico();
        });
    }

    cargarGrafico();
    setInterval(cargarGrafico, 60 * 60 * 1000);
});

(function() {
    var contentEl = document.getElementById('envivo-content');
    if (!contentEl) return;

    var lastUpdateEl = document.getElementById('envivo-last-update');
    var totalCountEl = document.getElementById('envivo-total-count');

    var myUserId = parseInt('{$user_id|intval}', 10);

    function escapeHtml(str) {
        if (str === null || str === undefined) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    function renderGrupo(g) {
        var isMe         = (g.admin_id === myUserId && g.admin_id > 0);
        var isUnassigned = (g.admin_id === 0);

        var extraClass = '';
        if (isUnassigned) extraClass = 'is-unassigned';
        else if (isMe)    extraClass = 'is-me';

        var headerName = '';
        if (isUnassigned) {
            headerName = 'SIN ASIGNAR';
        } else {
            headerName = 'Admin: ' + escapeHtml(g.admin_name);
            if (isMe) headerName += ' <span class="badge-me">TÚ</span>';
        }

        var avatar = isUnassigned ? '⚠' : escapeHtml(g.admin_name.charAt(0).toUpperCase());
        var totalLabel = (g.total === 1) ? 'trámite' : 'trámites';

        var html = '';
        html += '<div class="wallet-audit-group ' + extraClass + '">';
        html +=   '<div class="wallet-audit-header">';
        html +=     '<div class="admin-name">';
        html +=       '<span class="avatar">' + avatar + '</span>';
        html +=       headerName;
        html +=     '</div>';
        html +=     '<span class="count-badge">' + g.total + ' ' + totalLabel + '</span>';
        html +=   '</div>';
        html +=   '<div class="wallet-audit-body">';

        for (var i = 0; i < g.tramites.length; i++) {
            var t = g.tramites[i];
            var moneda = (t.tipo === 'retiro') ? '💲 NXT-20' : '💎 Kyber';
            var claseMoneda = (t.tipo === 'retiro') ? 'nxt' : 'kyber';

            html += '<div class="wallet-audit-row">';
            html +=   '<div class="row-left">';
            html +=     '<span class="tramite-id">#' + t.id + '</span>';
            html +=     '<span class="user-name">' + escapeHtml(t.username) + '</span>';
            html +=     '<span class="kyber-amount ' + claseMoneda + '">' + escapeHtml(t.cantidad_kyber) + ' <small>' + moneda + '</small></span>';
            html +=   '</div>';
            html +=   '<div class="row-right">';
            html +=     '<span class="wallet-badge ' + escapeHtml(t.estado_clase) + '">' + escapeHtml(t.estado_label) + '</span>';
            if (t.referencia) {
                html += '<span style="font-family:\'Courier New\',monospace; font-size:10px; color:#fbbf24;">' 
                     + escapeHtml(t.referencia) + '</span>';
            }
            html +=     '<span class="fecha">' + escapeHtml(t.fecha) + '</span>';
            html +=   '</div>';
            html += '</div>';
        }

        html +=   '</div>';
        html += '</div>';

        return html;
    }

    function renderAll(data) {
        var grupos = data.grupos || [];

        if (grupos.length === 0) {
            contentEl.innerHTML = 
                '<div class="wallet-audit-empty">' +
                '  <span class="big-icon">✨</span>' +
                '  No hay trámites activos en este momento.' +
                '</div>';
            return;
        }

        var html = '';
        for (var i = 0; i < grupos.length; i++) {
            html += renderGrupo(grupos[i]);
        }
        contentEl.innerHTML = html;
    }

    function actualizar() {
        fetch('game.php?page=walletadmin&mode=getAuditoriaAjax')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data.ok) return;
                renderAll(data);
                if (lastUpdateEl) lastUpdateEl.textContent = '· Actualizado a las ' + data.timestamp;
                if (totalCountEl) totalCountEl.textContent = 'Total: ' + data.total_tramites;
            })
            .catch(function(err) {
                console.error('Error actualizando En Vivo:', err);
                if (lastUpdateEl) lastUpdateEl.textContent = '· Error al actualizar';
            });
    }

    setTimeout(actualizar, 2000);
    setInterval(actualizar, 30000);
})();
</script>

{/block}