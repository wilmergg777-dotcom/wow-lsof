{* ============================================================
   page.market.default.tpl — Mercado AstroIO v4.9 (Colonias)
   ============================================================
   v4.7 — NUEVO (Unificación con Mercado Cruzado)
   v4.8 — NUEVO (Soporte Cofres Climáticos)
   v4.9 — NUEVO (Mercado Negro de Colonias):
      - Añadida pestaña "🏴‍☠️ Colonias"
      - Bloque {if $tab_active == 'colonies'} con:
        · Formulario publicar colonia
        · Tabla "mis colonias en venta"
        · Grid "colonias disponibles" con preview
   ============================================================ *}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   ASTROIO MARKET v4.8 — Glassmorphism Ecosystem
   Prefijo: .astromkt_
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
    --accent-orange: #ff8800;
}

.astromkt_wrap {
	text-align: center;
	color: var(--text-main);
	font-family: 'Segoe UI', Roboto, sans-serif;
	font-size: 12px;
	background: transparent;
}

.astromkt_panel {
	display: inline-block;
	text-align: left;
	width: 1240px;
	max-width: 100%;
}

/* ===== HEADER ===== */
.astromkt_header {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 16px 20px;
	margin-bottom: 14px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	gap: 14px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astromkt_title {
	font-size: 22px;
	font-weight: 800;
	color: var(--text-title);
	letter-spacing: 1.5px;
	text-transform: uppercase;
	margin: 0;
	display: flex;
	align-items: center;
	gap: 10px;
}

.astromkt_title .icon { color: var(--accent-cyan); font-size: 24px; }

.astromkt_balance_box {
	display: flex;
	gap: 24px;
	align-items: center;
}

.astromkt_balance_item {
	text-align: center;
	padding: 6px 14px;
	background: rgba(0, 0, 0, 0.35);
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border-radius: 10px;
	border: 1px solid rgba(0, 224, 255, 0.15);
}

.astromkt_balance_item .label {
	font-size: 9px;
	color: var(--text-muted);
	text-transform: uppercase;
	letter-spacing: 1px;
	font-weight: 700;
}

.astromkt_balance_item .value {
	font-size: 18px;
	font-weight: 800;
	color: var(--accent-cyan);
	font-family: 'Courier New', monospace;
	text-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
}

.astromkt_balance_item .value.vip {
	color: #ff88aa;
	text-shadow: 0 0 12px rgba(255, 136, 170, 0.5);
}

/* ===== FEEDBACK ===== */
.astromkt_feedback {
	padding: 12px 16px;
	border-radius: 10px;
	margin-bottom: 14px;
	font-weight: 700;
	font-size: 12px;
	border-left: 3px solid;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	line-height: 1.5;
}
.astromkt_feedback.ok {
	background: rgba(74, 255, 136, 0.08);
	border-color: var(--accent-green);
	color: var(--accent-green);
}
.astromkt_feedback.err {
	background: rgba(239, 68, 68, 0.08);
	border-color: var(--accent-red);
	color: var(--accent-red);
}

/* v3.3 — Aviso de AUTO-CANCELACIÓN (amarillo/dorado) */
.astromkt_feedback.warn {
	background: rgba(251, 191, 36, 0.10);
	border-left: 4px solid var(--accent-gold);
	color: #ffdd77;
	animation: astromkt_pulse_warn 2s ease-in-out infinite;
}

@keyframes astromkt_pulse_warn {
	0%, 100% {
		box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
	}
	50% {
		box-shadow: 0 0 22px rgba(251, 191, 36, 0.55);
	}
}

/* ===== v3.3 — BANNER ANTI-EXPLOIT (aviso grande) ===== */
.astromkt_warning_banner {
	background: linear-gradient(135deg, rgba(251, 191, 36, 0.10), rgba(255, 136, 0, 0.06));
	border: 1px solid rgba(251, 191, 36, 0.4);
	border-left: 4px solid var(--accent-gold);
	border-radius: 10px;
	padding: 14px 18px;
	margin-bottom: 18px;
	color: #ffe6a0;
	font-size: 11.5px;
	line-height: 1.7;
	font-weight: 600;
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	box-shadow: 0 0 16px rgba(251, 191, 36, 0.15);
	animation: astromkt_pulse_warn 3s ease-in-out infinite;
}

.astromkt_warning_banner b {
	color: var(--accent-gold);
	font-weight: 900;
}

.astromkt_warning_banner .astromkt_warning_icon {
	display: inline-block;
	font-size: 18px;
	margin-right: 8px;
	vertical-align: middle;
}

/* ===== TABS ===== */
.astromkt_tabs {
	display: flex;
	flex-wrap: wrap;
	gap: 6px;
	margin-bottom: 14px;
}

.astromkt_tab {
	padding: 10px 18px;
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 10px;
	color: var(--text-muted);
	font-weight: 700;
	font-size: 11px;
	text-decoration: none;
	transition: all 0.25s ease;
	letter-spacing: 0.8px;
	text-transform: uppercase;
}

.astromkt_tab:hover {
	background: rgba(30, 41, 59, 0.85);
	color: var(--accent-cyan);
	border-color: var(--accent-cyan);
	box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
	transform: translateY(-1px);
}

.astromkt_tab.active {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 168, 216, 0.9));
	color: #fff;
	border-color: var(--accent-cyan);
	box-shadow: 0 4px 14px rgba(0, 168, 216, 0.4);
}

/* v4.9 — Pestaña Colonias (acento dorado-pirata) */
.astromkt_tab--colonies {
	background: linear-gradient(135deg, rgba(80, 20, 20, 0.5), rgba(30, 10, 10, 0.5));
	border-color: rgba(255, 215, 0, 0.5);
	color: #ffd700;
}
.astromkt_tab--colonies:hover {
	background: linear-gradient(135deg, rgba(255, 215, 0, 0.2), rgba(80, 20, 20, 0.7));
	border-color: #ffd700;
	color: #ffffff;
	box-shadow: 0 0 14px rgba(255, 215, 0, 0.5);
}
.astromkt_tab--colonies.active {
	background: linear-gradient(135deg, #b8860b, #ffd700);
	border-color: #ffd700;
	color: #1a1000;
	box-shadow: 0 4px 14px rgba(255, 215, 0, 0.5);
}

/* v4.7 — Botón unificación al Mercado Cruzado */
.astromkt_tab--cross {
	margin-left: auto;
	background: linear-gradient(135deg, rgba(251, 191, 36, 0.1), rgba(255, 136, 0, 0.05));
	border-color: var(--accent-gold);
	color: var(--accent-gold);
}
.astromkt_tab--cross:hover {
	background: linear-gradient(135deg, #aa6600, #ffaa33);
	color: #1a1000;
	box-shadow: 0 0 14px rgba(251, 191, 36, 0.4);
}

/* ===== FILTROS ===== */
.astromkt_filters {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 14px 16px;
	margin-bottom: 14px;
	display: flex;
	gap: 12px;
	flex-wrap: wrap;
	align-items: center;
}

.astromkt_search {
	flex: 1;
	min-width: 200px;
	padding: 10px 14px;
	background: rgba(0, 0, 0, 0.5);
	border: 1px solid rgba(0, 204, 255, 0.35);
	border-radius: 8px;
	color: #ffffff;
	font-size: 12px;
	outline: none;
	transition: 0.25s ease;
}
.astromkt_search:focus {
	border-color: var(--accent-cyan);
	box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
	background: rgba(0, 0, 0, 0.65);
	transform: translateY(-1px);
}

.astromkt_cats {
	display: flex;
	gap: 5px;
	flex-wrap: wrap;
}
.astromkt_cat {
	padding: 8px 14px;
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 8px;
	color: var(--text-muted);
	font-size: 11px;
	font-weight: 700;
	text-decoration: none;
	transition: all 0.25s ease;
	text-transform: uppercase;
	letter-spacing: 0.5px;
	cursor: pointer;
}
.astromkt_cat:hover { background: rgba(30, 41, 59, 0.85); color: var(--accent-cyan); border-color: var(--accent-cyan); }
.astromkt_cat.active {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 168, 216, 0.9));
	color: #fff;
	border-color: var(--accent-cyan);
}

.astromkt_sort {
	padding: 10px 12px;
	background: rgba(0, 0, 0, 0.5);
	border: 1px solid rgba(0, 204, 255, 0.35);
	border-radius: 8px;
	color: #ffffff !important;
	font-size: 11px;
	outline: none;
	cursor: pointer;
}
.astromkt_sort option {
	background: #0f1624 !important;
	color: #ffffff !important;
}

.astromkt_counter {
	padding: 10px 0;
	color: var(--text-muted);
	font-size: 11px;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

/* ===== GRID DE TARJETAS ===== */
.astromkt_grid {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 16px;
	margin-bottom: 20px;
}

/* ═══════════════════════════════════════════════════════════
   TARJETA ESTILO ASTROIO v3.0
   ═══════════════════════════════════════════════════════════ */
.astromkt_card {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	overflow: hidden;
	position: relative;
	transition: all 0.3s ease;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
	display: flex;
	flex-direction: column;
}

.astromkt_card:hover {
	border-color: rgba(0, 224, 255, 0.7);
	box-shadow: 0 8px 30px rgba(0, 224, 255, 0.25), 0 4px 20px rgba(0, 0, 0, 0.5);
	transform: translateY(-4px);
}

.astromkt_card.is-admin {
	border-color: rgba(251, 191, 36, 0.5);
}
.astromkt_card.is-admin:hover {
	border-color: var(--accent-gold);
	box-shadow: 0 8px 30px rgba(251, 191, 36, 0.35), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astromkt_card.is-improvement {
	border-color: rgba(139, 92, 246, 0.4);
}
.astromkt_card.is-improvement:hover {
	border-color: #cc88ff;
	box-shadow: 0 8px 30px rgba(170, 68, 255, 0.35), 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* v4.6 — Cofre Genérico (color morado como las mejoras) */
.astromkt_card.is-container {
	border-color: rgba(139, 92, 246, 0.4);
}
.astromkt_card.is-container:hover {
	border-color: #cc88ff;
	box-shadow: 0 8px 30px rgba(170, 68, 255, 0.35), 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* v4.9 — Carta de colonia (acento dorado) */
.astromkt_card.is-colony {
	border-color: rgba(255, 215, 0, 0.4);
}
.astromkt_card.is-colony:hover {
	border-color: #ffd700;
	box-shadow: 0 8px 30px rgba(255, 215, 0, 0.35), 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* ===== IMAGEN GRANDE ===== */
.astromkt_imgwrap {
	position: relative;
	width: 100%;
	height: 160px;
	background: radial-gradient(circle at center, rgba(30, 41, 59, 0.5) 0%, rgba(0, 0, 0, 0.5) 100%);
	overflow: hidden;
	display: flex;
	align-items: center;
	justify-content: center;
}

.astromkt_imgwrap img {
	max-height: 130px;
	max-width: 85%;
	object-fit: contain;
	filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.6));
	transition: transform 0.3s ease;
}

.astromkt_card:hover .astromkt_imgwrap img {
	transform: scale(1.08);
}

/* Badges sobre la imagen */
.astromkt_badge_tl {
	position: absolute;
	top: 10px;
	left: 10px;
	padding: 4px 10px;
	background: rgba(0, 0, 0, 0.75);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid rgba(0, 224, 255, 0.35);
	border-radius: 6px;
	color: var(--accent-cyan);
	font-size: 9px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.8px;
}

.astromkt_badge_tl.resource   { border-color: rgba(0, 224, 255, 0.4);  color: var(--accent-cyan); }
.astromkt_badge_tl.ship       { border-color: rgba(74, 255, 136, 0.4);  color: var(--accent-green); }
.astromkt_badge_tl.defense    { border-color: rgba(102, 204, 255, 0.4); color: #66ccff; }
.astromkt_badge_tl.box        { border-color: rgba(139, 92, 246, 0.4);  color: #cc88ff; }
.astromkt_badge_tl.box_climate{ border-color: rgba(139, 92, 246, 0.4);  color: #cc88ff; }
.astromkt_badge_tl.container  { border-color: rgba(139, 92, 246, 0.4);  color: #cc88ff; }
.astromkt_badge_tl.mo         { border-color: rgba(139, 92, 246, 0.4);  color: #cc88ff; }
.astromkt_badge_tl.improvement{ border-color: rgba(139, 92, 246, 0.4);  color: #cc88ff; }
.astromkt_badge_tl.admin      { border-color: rgba(251, 191, 36, 0.5);  color: var(--accent-gold); }
.astromkt_badge_tl.buy        { border-color: rgba(74, 255, 136, 0.4);  color: var(--accent-green); }
.astromkt_badge_tl.colony     { border-color: rgba(255, 215, 0, 0.5);   color: #ffd700; }

.astromkt_badge_tr {
	position: absolute;
	top: 10px;
	right: 10px;
	padding: 4px 10px;
	background: rgba(0, 0, 0, 0.75);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid rgba(251, 191, 36, 0.4);
	border-radius: 6px;
	color: var(--accent-gold);
	font-size: 10px;
	font-weight: 800;
	font-family: 'Courier New', monospace;
}

/* ===== TIMER ===== */
.astromkt_timer_badge {
	position: absolute;
	bottom: 8px;
	right: 8px;
	padding: 3px 8px;
	background: rgba(0, 0, 0, 0.75);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border-radius: 5px;
	font-family: 'Courier New', monospace;
	font-size: 9.5px;
	font-weight: 700;
}
.astromkt_timer_badge.ok        { color: var(--accent-green); }
.astromkt_timer_badge.attention { color: var(--accent-gold); }
.astromkt_timer_badge.warning   { color: #dd8800; }
.astromkt_timer_badge.critical  { color: var(--accent-red); animation: pulse 1s infinite; }
.astromkt_timer_badge.infinite  { color: #ffcc66; }
.astromkt_timer_badge.expired   { color: var(--text-muted); }

@keyframes pulse {
	0%, 100% { opacity: 1; }
	50%      { opacity: 0.5; }
}

/* ===== BODY DE LA TARJETA ===== */
.astromkt_body {
	padding: 14px 16px 16px 16px;
	display: flex;
	flex-direction: column;
	flex: 1;
}

.astromkt_name {
	font-size: 15px;
	font-weight: 800;
	color: var(--text-title);
	margin: 0 0 4px 0;
	letter-spacing: 0.3px;
	line-height: 1.2;
}

.astromkt_seller {
	font-size: 10.5px;
	color: var(--text-muted);
	margin-bottom: 10px;
	font-weight: 500;
}
.astromkt_seller b {
	color: var(--accent-cyan);
	font-weight: 700;
}

.astromkt_stat_text {
	display: block;
	font-size: 10px;
	color: var(--accent-green);
	font-weight: 700;
	background: rgba(74, 255, 136, 0.08);
	border-left: 2px solid var(--accent-green);
	padding: 4px 10px;
	border-radius: 4px;
	margin-bottom: 10px;
	letter-spacing: 0.3px;
}
.astromkt_stat_text.defense {
	color: #66ccff;
	border-left-color: #66ccff;
	background: rgba(102, 204, 255, 0.08);
}

/* Price row */
.astromkt_price_row {
	display: flex;
	justify-content: space-between;
	align-items: flex-end;
	margin-bottom: 12px;
	padding-bottom: 10px;
	border-bottom: 1px solid var(--border-color);
}

.astromkt_price_main {
	font-size: 22px;
	font-weight: 800;
	color: var(--accent-cyan);
	font-family: 'Courier New', monospace;
	line-height: 1;
	text-shadow: 0 0 16px rgba(0, 224, 255, 0.4);
}

.astromkt_price_main .unit {
	font-size: 11px;
	color: var(--text-muted);
	font-weight: 600;
	margin-left: 4px;
	text-shadow: none;
}

.astromkt_price_sub {
	text-align: right;
	font-size: 11px;
	color: var(--accent-gold);
	font-weight: 700;
	font-family: 'Courier New', monospace;
}

.astromkt_fee_text {
	font-size: 9.5px;
	color: var(--accent-red);
	font-weight: 700;
	text-align: right;
	margin-bottom: 10px;
}
.astromkt_fee_text.free { color: var(--accent-green); }

.astromkt_total_text {
	font-size: 10px;
	color: var(--text-muted);
	text-align: right;
	margin-bottom: 10px;
}
.astromkt_total_text b { color: var(--accent-gold); }

/* ===== BOTÓN FULL-WIDTH ===== */
.astromkt_btn_full {
	display: block;
	width: 100%;
	padding: 12px 14px;
	border-radius: 8px;
	font-weight: 800;
	font-size: 12.5px;
	text-decoration: none;
	text-align: center;
	text-transform: uppercase;
	letter-spacing: 1px;
	transition: all 0.25s ease;
	border: none;
	cursor: pointer;
	box-sizing: border-box;
	margin-top: auto;
	color: #fff;
	text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astromkt_btn_full--cyan {
	background: linear-gradient(135deg, #0066cc, #0099ff);
	border: 1px solid var(--accent-cyan);
	box-shadow: 0 4px 14px rgba(0, 168, 216, 0.35);
}
.astromkt_btn_full--cyan:hover {
	box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
	transform: translateY(-2px);
}

.astromkt_btn_full--green {
	background: linear-gradient(135deg, #228833, #66ff99);
	border: 1px solid var(--accent-green);
	box-shadow: 0 4px 14px rgba(34, 136, 51, 0.35);
}
.astromkt_btn_full--green:hover {
	box-shadow: 0 0 18px rgba(102, 255, 153, 0.6);
	transform: translateY(-2px);
}

.astromkt_btn_full--purple {
	background: linear-gradient(135deg, #7700cc, #aa44ff);
	border: 1px solid var(--accent-purple);
	box-shadow: 0 4px 14px rgba(122, 0, 204, 0.35);
}
.astromkt_btn_full--purple:hover {
	box-shadow: 0 0 18px rgba(170, 68, 255, 0.6);
	transform: translateY(-2px);
}

.astromkt_btn_full--gold {
	background: linear-gradient(135deg, #aa6600, #ffaa33);
	color: #1a1000;
	border: 1px solid var(--accent-gold);
	box-shadow: 0 4px 14px rgba(255, 170, 51, 0.35);
}
.astromkt_btn_full--gold:hover {
	box-shadow: 0 0 18px rgba(255, 200, 80, 0.6);
	transform: translateY(-2px);
}

.astromkt_btn_full--disabled {
	background: rgba(30, 41, 59, 0.85);
	color: var(--text-muted);
	cursor: not-allowed;
	box-shadow: none;
	border: 1px solid var(--border-color);
}

/* ===== EMPTY ===== */
.astromkt_empty {
	padding: 50px 20px;
	text-align: center;
	color: var(--text-muted);
	font-size: 13px;
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
}

/* ===== PAGINACIÓN ===== */
.astromkt_pagination {
	display: flex;
	justify-content: center;
	gap: 5px;
	margin-top: 16px;
}
.astromkt_pagination a {
	padding: 8px 14px;
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 8px;
	color: var(--text-muted);
	text-decoration: none;
	font-size: 11px;
	font-weight: 700;
	transition: all 0.25s ease;
}
.astromkt_pagination a:hover,
.astromkt_pagination a.active {
	background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 168, 216, 0.9));
	color: #fff;
	border-color: var(--accent-cyan);
}

/* ===== FORMULARIO ===== */
.astromkt_form {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 24px;
	max-width: 640px;
	margin: 0 auto;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astromkt_section_title {
	font-size: 14px;
	font-weight: 800;
	color: var(--accent-cyan);
	text-transform: uppercase;
	letter-spacing: 1.5px;
	border-bottom: 1px solid var(--border-color);
	padding-bottom: 12px;
	margin-bottom: 18px;
}

.astromkt_field { margin-bottom: 16px; }
.astromkt_field label {
	display: block;
	font-size: 10px;
	color: var(--text-muted);
	text-transform: uppercase;
	letter-spacing: 1px;
	margin-bottom: 6px;
	font-weight: 700;
}

.astromkt_input {
	width: 100%;
	padding: 11px 14px;
	background: rgba(0, 0, 0, 0.5);
	border: 1px solid rgba(0, 204, 255, 0.35);
	border-radius: 8px;
	color: #ffffff;
	font-size: 13px;
	outline: none;
	box-sizing: border-box;
	transition: all 0.25s ease;
}

.astromkt_input:focus {
	border-color: var(--accent-cyan);
	box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
	background: rgba(0, 0, 0, 0.65);
	transform: translateY(-1px);
}

/* ═══════════════════════════════════════════════════════════
   FIX DEFINITIVO SELECT (v4.5) - Forzar altura de línea
   ═══════════════════════════════════════════════════════════ */
.astromkt_select {
    width: 100%;
    padding: 12px 30px 12px 14px !important;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 204, 255, 0.5);
    border-radius: 8px;
    color: #ffffff !important; 
    font-weight: 700; 
    font-size: 14px !important;
    font-family: inherit; 
    cursor: pointer; 
    outline: none;
    transition: 0.25s ease;
    height: auto !important;
    line-height: 1.5 !important;
    appearance: none; 
    -webkit-appearance: none; 
    -moz-appearance: none;
    background-image:
        linear-gradient(45deg, transparent 50%, #00e0ff 50%),
        linear-gradient(135deg, #00e0ff 50%, transparent 50%) !important;
    background-position: calc(100% - 16px) center, calc(100% - 11px) center !important;
    background-size: 5px 5px, 5px 5px !important;
    background-repeat: no-repeat !important;
    box-sizing: border-box;
}

.astromkt_select:hover, 
.astromkt_select:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    transform: translateY(-1px);
}

.astromkt_select option,
.astromkt_select optgroup {
    background: #0f1624 !important;
    color: #ffffff !important;
    padding: 10px !important;
    font-size: 14px;
}

.astromkt_input.error {
	border-color: var(--accent-red);
	box-shadow: 0 0 12px rgba(239, 68, 68, 0.3);
}

.astromkt_row {
	display: flex;
	gap: 10px;
	align-items: flex-end;
	margin-bottom: 14px;
}
.astromkt_row > * { flex: 1; }

.astromkt_quick {
	display: flex;
	gap: 6px;
	margin-top: 8px;
}
.astromkt_quick button {
	padding: 6px 14px;
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 6px;
	color: var(--text-muted);
	font-size: 11px;
	font-weight: 700;
	cursor: pointer;
	transition: all 0.25s ease;
}
.astromkt_quick button:hover {
	background: rgba(30, 41, 59, 0.85);
	color: var(--accent-cyan);
	border-color: var(--accent-cyan);
	transform: translateY(-1px);
}

.astromkt_hint {
	font-size: 10px;
	color: var(--text-muted);
	margin-top: 5px;
}
.astromkt_hint.warn { color: var(--accent-gold); }
.astromkt_hint.error { color: var(--accent-red); font-weight: 700; }

.astromkt_hint--miles {
	background: rgba(0, 224, 255, 0.08);
	border-left: 2px solid var(--accent-cyan);
	padding: 6px 12px;
	border-radius: 4px;
	margin-top: 8px;
	font-size: 10.5px;
	color: #88ddff;
	font-weight: 600;
}

.astromkt_summary {
	background: rgba(0, 0, 0, 0.35);
	backdrop-filter: blur(4px);
	-webkit-backdrop-filter: blur(4px);
	border-radius: 10px;
	padding: 14px;
	margin: 16px 0;
	border-left: 3px solid var(--accent-cyan);
}
.astromkt_summary_row {
	display: flex;
	justify-content: space-between;
	font-size: 12px;
	margin-bottom: 6px;
	color: var(--text-main);
}
.astromkt_summary_row.total {
	border-top: 1px solid var(--border-color);
	padding-top: 8px;
	margin-top: 8px;
	font-weight: 800;
	font-size: 14px;
	color: var(--accent-cyan);
}
.astromkt_summary_note {
	font-size: 10px;
	color: var(--text-muted);
	margin-top: 8px;
	padding-top: 8px;
	border-top: 1px dashed rgba(255, 255, 255, 0.08);
	font-style: italic;
}

.astromkt_submit {
	width: 100%;
	padding: 14px;
	background: linear-gradient(135deg, #0066cc, #0099ff);
	border: 1px solid var(--accent-cyan);
	border-radius: 8px;
	color: #fff;
	font-size: 13px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 1.5px;
	cursor: pointer;
	transition: all 0.25s ease;
	text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astromkt_submit:hover {
	box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
	transform: translateY(-2px);
}
.astromkt_submit:disabled {
	background: rgba(30, 41, 59, 0.85);
	color: var(--text-muted);
	cursor: not-allowed;
	box-shadow: none;
	transform: none;
	border-color: var(--border-color);
}
.astromkt_submit.buy {
	background: linear-gradient(135deg, #7700cc, #aa44ff);
	border-color: var(--accent-purple);
}
.astromkt_submit.buy:hover {
	box-shadow: 0 0 18px rgba(170, 68, 255, 0.6);
}

/* ===== DURACIÓN ===== */
.astromkt_durations {
	display: flex;
	gap: 12px;
	margin-bottom: 16px;
}
.astromkt_duration {
	flex: 1;
	padding: 14px;
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 2px solid var(--border-color);
	border-radius: 10px;
	text-align: center;
	cursor: pointer;
	transition: all 0.25s ease;
}
.astromkt_duration:hover { border-color: var(--accent-cyan); }
.astromkt_duration.selected {
	background: rgba(0, 224, 255, 0.1);
	border-color: var(--accent-cyan);
	box-shadow: 0 0 16px rgba(0, 224, 255, 0.3);
}
.astromkt_duration .time {
	font-size: 18px;
	font-weight: 800;
	color: var(--accent-cyan);
}
.astromkt_duration .fee {
	font-size: 10.5px;
	color: var(--accent-gold);
	margin-top: 4px;
	font-weight: 600;
}

/* ===== MIS LISTADOS ===== */
.astromkt_mycard {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 14px;
	margin-bottom: 12px;
	position: relative;
	transition: all 0.25s ease;
}
.astromkt_mycard--critical  { border-color: var(--accent-red); }
.astromkt_mycard--warning   { border-color: #dd8800; }
.astromkt_mycard--attention { border-color: var(--accent-gold); }
.astromkt_mycard--ok        { border-color: var(--accent-cyan); }
.astromkt_mycard--inactive  { opacity: 0.55; }

/* v3.3 — Oferta AUTO-CANCELADA (por ataque o por falta de NTX) */
.astromkt_mycard--autocancelled {
	border-color: rgba(251, 191, 36, 0.55);
	background: linear-gradient(135deg, rgba(251, 191, 36, 0.05), var(--bg-card));
}

/* v4.9 — Mis colonias en venta */
.astromkt_mycard--colony {
	border-color: rgba(255, 215, 0, 0.55);
	background: linear-gradient(135deg, rgba(255, 215, 0, 0.05), var(--bg-card));
}

.astromkt_myhead {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10px;
}

.astromkt_progress {
	position: relative;
	height: 8px;
	background: rgba(0, 0, 0, 0.5);
	border-radius: 6px;
	overflow: hidden;
	margin: 12px 0 8px 0;
}
.astromkt_progress_bar {
	height: 100%;
	background: linear-gradient(90deg, #00ccff, #66ff99);
	border-radius: 6px;
	transition: width 1s linear;
}
.astromkt_progress_bar.critical  { background: linear-gradient(90deg, #ef4444, #aa0044); }
.astromkt_progress_bar.warning   { background: linear-gradient(90deg, #dd8800, #ffaa33); }
.astromkt_progress_bar.attention { background: linear-gradient(90deg, #ffaa33, #ffcc66); }

.astromkt_progress_text {
	position: absolute;
	right: 8px;
	top: -18px;
	font-size: 10px;
	color: var(--text-muted);
}

.astromkt_cancel {
	display: inline-block;
	padding: 8px 16px;
	background: rgba(239, 68, 68, 0.1);
	border: 1px solid rgba(239, 68, 68, 0.4);
	border-radius: 8px;
	color: var(--accent-red);
	font-size: 11px;
	font-weight: 700;
	text-decoration: none;
	text-transform: uppercase;
	transition: all 0.25s ease;
}
.astromkt_cancel:hover {
	background: rgba(239, 68, 68, 0.25);
	box-shadow: 0 0 14px rgba(239, 68, 68, 0.4);
	transform: translateY(-1px);
}

.astromkt_status_badge {
	display: inline-block;
	padding: 4px 12px;
	border-radius: 6px;
	font-size: 10px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}
.astromkt_status_badge.active    { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); }
.astromkt_status_badge.sold      { background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); }
.astromkt_status_badge.expired   { background: rgba(239, 68, 68, 0.15); color: var(--accent-red); }
.astromkt_status_badge.cancelled { background: rgba(148, 163, 184, 0.15); color: var(--text-muted); }

/* v3.3 — Motivo de cancelación visible */
.astromkt_cancel_reason {
	margin-top: 10px;
	padding: 10px 14px;
	background: rgba(251, 191, 36, 0.08);
	border-left: 3px solid var(--accent-gold);
	border-radius: 6px;
	font-size: 11px;
	color: #ffdd77;
	font-weight: 600;
	line-height: 1.5;
}

.astromkt_cancel_reason.autocancelled {
	background: rgba(255, 136, 0, 0.10);
	border-left-color: var(--accent-orange);
	color: #ffaa66;
}

.astromkt_cancel_reason .astromkt_cancel_icon {
	display: inline-block;
	font-size: 14px;
	margin-right: 6px;
	vertical-align: middle;
}

/* ===== TENDENCIAS ===== */
.astromkt_trends_grid {
	display: grid;
	grid-template-columns: 1fr 1fr;
	gap: 14px;
	margin-bottom: 20px;
}

.astromkt_trend_box {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 16px;
}

.astromkt_trend_head {
	font-size: 12px;
	font-weight: 800;
	color: var(--accent-cyan);
	text-transform: uppercase;
	letter-spacing: 1px;
	border-bottom: 1px solid var(--border-color);
	padding-bottom: 10px;
	margin-bottom: 14px;
}

.astromkt_trend_row {
	display: flex;
	align-items: center;
	gap: 10px;
	margin-bottom: 10px;
	font-size: 12px;
}

.astromkt_trend_pos {
	color: var(--accent-gold);
	font-weight: 800;
	width: 22px;
	text-align: center;
	font-family: 'Courier New', monospace;
}

.astromkt_trend_img {
	width: 30px;
	height: 30px;
	display: flex;
	align-items: center;
	justify-content: center;
	background: rgba(0, 0, 0, 0.4);
	border-radius: 6px;
}
.astromkt_trend_img img { max-width: 26px; max-height: 26px; }

.astromkt_trend_name {
	color: var(--text-main);
	width: 120px;
	font-weight: 600;
	white-space: nowrap;
	overflow: hidden;
	text-overflow: ellipsis;
}

.astromkt_trend_bar {
	flex: 1;
	height: 8px;
	background: rgba(0, 0, 0, 0.5);
	border-radius: 4px;
	overflow: hidden;
}
.astromkt_trend_fill {
	display: block;
	height: 100%;
	background: linear-gradient(90deg, #0066cc, #00e0ff);
	border-radius: 4px;
	transition: 0.4s ease;
}

.astromkt_trend_val {
	color: var(--accent-gold);
	font-weight: 800;
	width: 50px;
	text-align: right;
	font-family: 'Courier New', monospace;
}

.astromkt_chart_box {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 16px;
	margin-bottom: 20px;
}

.astromkt_chart_head {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 14px;
	flex-wrap: wrap;
	gap: 10px;
}

.astromkt_chart_container {
	position: relative;
	height: 240px;
}

.astromkt_chart_footer {
	margin-top: 12px;
	padding-top: 12px;
	border-top: 1px solid var(--border-color);
	display: flex;
	justify-content: space-between;
	align-items: center;
	font-size: 12px;
	color: var(--text-main);
}
.astromkt_chart_footer b { color: var(--accent-cyan); }

.astromkt_trend_up    { color: var(--accent-green); font-weight: 800; }
.astromkt_trend_down  { color: var(--accent-red); font-weight: 800; }
.astromkt_trend_flat  { color: var(--text-muted); font-weight: 800; }

/* ===== WIDGET ===== */
.astromkt_widget {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 12px;
	padding: 12px 18px;
	margin-bottom: 14px;
	display: flex;
	justify-content: space-between;
	align-items: center;
	flex-wrap: wrap;
	gap: 14px;
	font-size: 12px;
}
.astromkt_widget_title {
	color: var(--accent-gold);
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 1px;
	font-size: 11px;
}
.astromkt_widget_item {
	display: flex;
	align-items: center;
	gap: 8px;
}
.astromkt_widget_item .name { color: var(--text-main); font-weight: 600; }
.astromkt_widget_item .val  { color: var(--accent-cyan); font-weight: 800; }

/* ===== CAJAS ===== */
.astromkt_boxes {
	display: grid;
	grid-template-columns: repeat(3, 1fr);
	gap: 16px;
	margin-bottom: 20px;
}
.astromkt_box {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 2px solid var(--border-color);
	border-radius: 12px;
	padding: 20px;
	text-align: center;
	transition: all 0.3s ease;
}
.astromkt_box.common    { border-color: var(--accent-cyan); }
.astromkt_box.rare      { border-color: var(--accent-purple); }
.astromkt_box.legendary { border-color: var(--accent-gold); }
.astromkt_box:hover {
	transform: translateY(-4px);
	box-shadow: 0 12px 30px rgba(0, 0, 0, 0.7);
}
.astromkt_box_img {
	height: 90px;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 12px;
}
.astromkt_box_img img { max-height: 90px; }
.astromkt_box_name {
	font-size: 14px;
	font-weight: 800;
	color: var(--text-title);
	margin-bottom: 6px;
}
.astromkt_box_desc {
	font-size: 11px;
	color: var(--text-muted);
	margin-bottom: 12px;
}
.astromkt_box_count {
	font-size: 24px;
	font-weight: 800;
	color: var(--accent-cyan);
	font-family: 'Courier New', monospace;
	text-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
}

/* ===== HISTORIAL ===== */
.astromkt_history { display: grid; gap: 8px; }
.astromkt_hrow {
	background: var(--bg-card);
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
	border: 1px solid var(--border-color);
	border-radius: 10px;
	padding: 12px 16px;
	display: flex;
	align-items: center;
	gap: 14px;
	font-size: 12px;
	transition: all 0.25s ease;
}
.astromkt_hrow:hover {
	border-color: var(--accent-cyan);
	box-shadow: 0 0 12px rgba(0, 224, 255, 0.2);
	transform: translateY(-1px);
}
.astromkt_hrow_img {
	width: 38px;
	height: 38px;
	display: flex;
	align-items: center;
	justify-content: center;
	background: rgba(0, 0, 0, 0.4);
	border-radius: 7px;
	flex-shrink: 0;
}
.astromkt_hrow_img img { max-width: 32px; max-height: 32px; }

.astromkt_hrow_main { flex: 1; }
.astromkt_hrow_name { color: var(--text-title); font-weight: 700; }
.astromkt_hrow_meta { color: var(--text-muted); font-size: 10.5px; margin-top: 2px; }

.astromkt_hrow_price {
	color: var(--accent-gold);
	font-weight: 800;
	font-family: 'Courier New', monospace;
}

.astromkt_hrow_role {
	padding: 4px 10px;
	border-radius: 6px;
	font-size: 9.5px;
	font-weight: 800;
	text-transform: uppercase;
	letter-spacing: 0.5px;
}
.astromkt_hrow_role.buyer  { background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); }
.astromkt_hrow_role.seller { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); }

/* ===== RESPONSIVE ===== */
@media (max-width: 1100px) {
	.astromkt_grid { grid-template-columns: repeat(2, 1fr); }
	.astromkt_trends_grid { grid-template-columns: 1fr; }
}
@media (max-width: 720px) {
    .astromkt_header { flex-direction: column !important; align-items: stretch !important; padding: 10px !important; gap: 10px !important; }
    .astromkt_title { font-size: 18px !important; justify-content: center; }
    .astromkt_balance_box { width: 100% !important; justify-content: space-between !important; flex-wrap: wrap !important; gap: 5px !important; }
    .astromkt_balance_item { flex: 1 !important; padding: 4px !important; min-width: 80px !important; }
    .astromkt_balance_item .value { font-size: 14px !important; }
    .astromkt_balance_item .label { font-size: 8px !important; }

    .astromkt_tabs { 
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important;
        gap: 4px !important; 
    }
    .astromkt_tab { 
        flex: 0 0 calc(33.333% - 4px) !important;
        padding: 8px 2px !important; 
        font-size: 9.5px !important; 
        text-align: center !important; 
        box-sizing: border-box !important;
    }
    .astromkt_tab--cross {
        flex: 0 0 100% !important;
        margin-left: 0 !important;
        margin-top: 4px !important;
    }

    .astromkt_filters { 
        flex-direction: column !important; 
        align-items: stretch !important; 
        padding: 8px !important; 
        gap: 8px !important; 
        box-sizing: border-box !important;
        width: 100% !important;
    }
    
    .astromkt_search { 
        width: 100% !important; 
        font-size: 12px !important; 
        box-sizing: border-box !important; 
    }
    
    .astromkt_cats { 
        display: flex !important;
        flex-wrap: wrap !important;
        justify-content: center !important; 
        gap: 4px !important; 
        width: 100% !important;
    }
    
    .astromkt_cat {
        padding: 6px 8px !important;
        font-size: 9px !important;
        flex: 1 1 auto !important;
        text-align: center !important;
        box-sizing: border-box !important;
    }
    
    .astromkt_filters button[type="submit"] {
        width: 100% !important;
        padding: 10px !important;
        font-size: 11px !important;
        box-sizing: border-box !important;
        background: linear-gradient(135deg, #0066cc, #00a8d8) !important;
        border: 1px solid #00e0ff !important;
        border-radius: 8px !important;
        color: #fff !important;
        text-transform: uppercase !important;
        cursor: pointer !important;
        margin-top: 4px !important;
    }
    
    .astromkt_sort { 
        width: 100% !important; 
        padding: 8px !important; 
        box-sizing: border-box !important;
    }

    .astromkt_select {
        font-size: 12px !important; 
        padding: 10px !important;
        height: auto !important;
        line-height: normal !important;
        box-sizing: border-box !important;
    }
    .astromkt_select option,
    .astromkt_select optgroup {
        font-size: 13px !important;
        padding: 6px !important;
    }
}
</style>

<style>
/* ═══════════════════════════════════════════════════════════
   ASTROIO MARKET v5.0 — RESKIN "MERCADO NEGRO" estilo
   pixel-art cálido (referencia: marketplace Sunflower Land):
   crema/naranja, bordes gruesos marrón, sombras duras, badges
   verdes, botones naranja. Override por encima del tema
   glassmorphism v4.8 (mismas clases .astromkt_*, sin tocar HTML).
   Las variables se re-declaran SOLO dentro de .astromkt_wrap
   para no filtrar a otras páginas.
   ═══════════════════════════════════════════════════════════ */

.astromkt_wrap {
    /* Paleta Sunflower-Land */
    --mk-cream:      #FFF3D6;   /* tarjetas */
    --mk-cream-dark: #F7E3B8;   /* paneles internos / cabeceras de fila */
    --mk-tan:        #E9B76D;   /* panel exterior */
    --mk-tan-deep:   #D89A45;   /* franjas */
    --mk-green:      #4F7A38;   /* header/banner */
    --mk-green-deep: #35572B;
    --mk-badge:      #7AB648;   /* badges/pills verdes */
    --mk-orange:     #F49F33;   /* botones */
    --mk-orange-hi:  #FFB84D;
    --mk-brown:      #663F19;   /* texto y bordes */
    --mk-brown-soft: #8A6135;
    --mk-red:        #C0392B;
    --mk-blue:       #4A78B8;
    --mk-border:     3px solid var(--mk-brown);
    --mk-border-2:   2px solid var(--mk-brown);
    --mk-shadow:     3px 3px 0 rgba(102, 63, 25, .28);
    --mk-shadow-sm:  2px 2px 0 rgba(102, 63, 25, .22);

    /* Re-map de variables del tema v4.8 usadas por las reglas viejas */
    --bg-dark:       rgba(233, 183, 109, 0);
    --bg-card:       var(--mk-cream);
    --bg-card-solid: var(--mk-cream);
    --bg-inner:      var(--mk-cream-dark);
    --border-color:  var(--mk-brown);
    --text-main:     var(--mk-brown);
    --text-muted:    var(--mk-brown-soft);
    --text-title:    var(--mk-brown);
    --accent-blue:   var(--mk-blue);
    --accent-cyan:   var(--mk-green);
    --accent-purple: var(--mk-brown-soft);
    --accent-gold:   var(--mk-orange);
    --accent-green:  var(--mk-badge);
    --accent-red:    var(--mk-red);
    --accent-orange: var(--mk-orange);

    color: var(--mk-brown);
    font-family: 'Trebuchet MS', 'Segoe UI', Verdana, sans-serif;
    font-size: 13px;
    background: transparent;
}

/* Quita el blur glass del tema viejo */
.astromkt_wrap * {
    backdrop-filter: none !important;
    -webkit-backdrop-filter: none !important;
}

/* ===== PANEL EXTERIOR ===== */
.astromkt_wrap .astromkt_panel {
    width: 1240px;
    max-width: 100%;
    background: var(--mk-tan);
    border: var(--mk-border);
    border-radius: 10px;
    box-shadow: 5px 5px 0 rgba(102, 63, 25, .30);
    padding: 10px;
}

/* ===== HEADER — banner verde con title crema ===== */
.astromkt_wrap .astromkt_header {
    background:
        repeating-linear-gradient(135deg,
            rgba(255,255,255,.06) 0 14px,
            rgba(0,0,0,.05) 14px 28px),
        var(--mk-green);
    border: var(--mk-border);
    border-radius: 8px;
    box-shadow: var(--mk-shadow);
    padding: 14px 18px;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
}

.astromkt_wrap .astromkt_title {
    color: #FFF6DC;
    font-size: clamp(18px, 2.4vw, 26px);
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    text-shadow: 2px 2px 0 rgba(53, 87, 43, .95);
    margin: 0;
    display: flex;
    align-items: baseline;
    gap: 10px;
    flex-wrap: wrap;
}

.astromkt_wrap .astromkt_subtitle {
    font-size: clamp(11px, 1.3vw, 13px);
    font-weight: 700;
    letter-spacing: 0;
    text-transform: none;
    color: #CFE3A8;
    text-shadow: 1px 1px 0 rgba(53, 87, 43, .9);
}

.astromkt_wrap .astromkt_title .icon { text-shadow: none; }

/* Saldo: chips crema */
.astromkt_wrap .astromkt_balance_box { display: flex; gap: 8px; flex-wrap: wrap; }
.astromkt_wrap .astromkt_balance_item {
    background: var(--mk-cream);
    border: var(--mk-border-2);
    border-radius: 6px;
    box-shadow: var(--mk-shadow-sm);
    padding: 6px 12px;
    min-width: 110px;
}
.astromkt_wrap .astromkt_balance_item .label {
    color: var(--mk-brown-soft);
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: .5px;
}
.astromkt_wrap .astromkt_balance_item .value {
    color: var(--mk-brown);
    font-size: 16px;
    font-weight: 800;
    text-shadow: none;
}

/* ===== FEEDBACK ===== */
.astromkt_wrap .astromkt_feedback {
    border: var(--mk-border-2);
    border-radius: 6px;
    box-shadow: var(--mk-shadow-sm);
    background: var(--mk-cream);
    color: var(--mk-brown);
    font-weight: 700;
    padding: 10px 14px;
    margin-top: 10px;
    border-left-width: 8px;
}
.astromkt_wrap .astromkt_feedback.ok   { border-left-color: var(--mk-badge); }
.astromkt_wrap .astromkt_feedback.err  { border-left-color: var(--mk-red); }
.astromkt_wrap .astromkt_feedback.warn { border-left-color: var(--mk-orange); }

/* ===== TABS — chips como la sidebar de Sunflower Land ===== */
.astromkt_wrap .astromkt_tabs {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: 12px;
}
.astromkt_wrap .astromkt_tab {
    background: var(--mk-cream);
    color: var(--mk-brown);
    border: var(--mk-border-2);
    border-radius: 6px;
    box-shadow: var(--mk-shadow-sm);
    padding: 7px 12px;
    font-weight: 800;
    font-size: 12px;
    text-decoration: none;
    transition: transform .08s ease;
}
.astromkt_wrap .astromkt_tab:hover { transform: translate(-1px, -1px); box-shadow: var(--mk-shadow); }
.astromkt_wrap .astromkt_tab.active {
    background: var(--mk-badge);
    color: #fff;
    text-shadow: 1px 1px 0 rgba(53, 87, 43, .7);
}
.astromkt_wrap .astromkt_tab--cross,
.astromkt_wrap .astromkt_tab--colonies { background: var(--mk-orange); color: #5b3a12; }

/* ===== WIDGET TENDENCIAS / SECCIONES ===== */
.astromkt_wrap .astromkt_widget,
.astromkt_wrap .astromkt_filters {
    background: var(--mk-cream);
    border: var(--mk-border);
    border-radius: 8px;
    box-shadow: var(--mk-shadow);
    padding: 12px;
    margin-top: 12px;
}
.astromkt_wrap .astromkt_widget_title,
.astromkt_wrap .astromkt_section_title {
    display: inline-block;
    background: var(--mk-badge);
    color: #fff;
    text-shadow: 1px 1px 0 rgba(53,87,43,.7);
    border: var(--mk-border-2);
    border-radius: 5px;
    padding: 4px 10px;
    font-weight: 800;
    font-size: 12px;
    letter-spacing: .4px;
    margin-bottom: 8px;
}
.astromkt_wrap .astromkt_widget_item {
    color: var(--mk-brown);
    padding: 4px 0;
    font-weight: 600;
}
.astromkt_wrap .astromkt_widget_item .val { font-weight: 800; }

/* ===== BUSCADOR / CATEGORÍAS ===== */
.astromkt_wrap .astromkt_search {
    width: 100%;
    box-sizing: border-box;
    background: #fff;
    border: var(--mk-border-2);
    border-radius: 6px;
    padding: 9px 12px;
    color: var(--mk-brown);
    font-weight: 600;
    font-size: 13px;
}
.astromkt_wrap .astromkt_search:focus { outline: 3px solid var(--mk-badge); outline-offset: 0; }
.astromkt_wrap .astromkt_cats { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 10px; }
.astromkt_wrap .astromkt_cat {
    background: var(--mk-cream-dark);
    color: var(--mk-brown);
    border: var(--mk-border-2);
    border-radius: 6px;
    padding: 5px 12px;
    font-weight: 800;
    font-size: 12px;
    text-decoration: none;
}
.astromkt_wrap .astromkt_cat.active {
    background: var(--mk-badge);
    color: #fff;
    text-shadow: 1px 1px 0 rgba(53,87,43,.7);
}
.astromkt_wrap .astromkt_sort {
    background: #fff;
    border: var(--mk-border-2);
    border-radius: 6px;
    color: var(--mk-brown);
    font-weight: 700;
    padding: 6px 10px;
}

/* ===== GRID DE TARJETAS (ofertas) ===== */
.astromkt_wrap .astromkt_card,
.astromkt_wrap .astromkt_mycard {
    background: var(--mk-cream);
    border: var(--mk-border);
    border-radius: 8px;
    box-shadow: var(--mk-shadow);
    padding: 10px;
    color: var(--mk-brown);
    transition: transform .08s ease, box-shadow .08s ease;
    position: relative;
    overflow: hidden;
}
.astromkt_wrap .astromkt_card:hover,
.astromkt_wrap .astromkt_mycard:hover {
    transform: translate(-2px, -2px);
    box-shadow: 5px 5px 0 rgba(102, 63, 25, .30);
}
.astromkt_wrap .astromkt_imgwrap {
    background: var(--mk-cream-dark);
    border: var(--mk-border-2);
    border-radius: 6px;
    padding: 8px;
}

/* Badge de precio estilo Sunflower Land (esquina superior izquierda) */
.astromkt_wrap .astromkt_badge_tl {
    background: var(--mk-badge);
    color: #fff;
    text-shadow: 1px 1px 0 rgba(53,87,43,.7);
    border: var(--mk-border-2);
    border-radius: 5px;
    font-weight: 800;
    font-size: 11px;
    padding: 3px 8px;
    box-shadow: var(--mk-shadow-sm);
}

/* Badge de estado */
.astromkt_wrap .astromkt_status_badge {
    border: var(--mk-border-2);
    border-radius: 5px;
    font-weight: 800;
    padding: 2px 8px;
    box-shadow: var(--mk-shadow-sm);
}
.astromkt_wrap .astromkt_status_badge.active    { background: var(--mk-badge);    color: #fff; }
.astromkt_wrap .astromkt_status_badge.sold      { background: var(--mk-orange);   color: #5b3a12; }
.astromkt_wrap .astromkt_status_badge.expired   { background: #C8B489;            color: var(--mk-brown); }
.astromkt_wrap .astromkt_status_badge.cancelled { background: var(--mk-red);      color: #fff; }

/* Timer badge (expira en...) */
.astromkt_wrap .astromkt_timer_badge {
    background: var(--mk-cream-dark);
    border: var(--mk-border-2);
    border-radius: 5px;
    color: var(--mk-brown);
    font-weight: 800;
    font-size: 11px;
    padding: 2px 8px;
}

/* ===== BOTONES ===== */
.astromkt_wrap .astromkt_btn_full,
.astromkt_wrap .astromkt_submit,
.astromkt_wrap .astromkt_pick,
.astromkt_wrap .astromkt_cat_btn {
    display: inline-block;
    background: linear-gradient(180deg, var(--mk-orange-hi), var(--mk-orange));
    color: #5b3a12;
    border: var(--mk-border-2);
    border-radius: 6px;
    box-shadow: var(--mk-shadow-sm);
    font-weight: 800;
    font-size: 13px;
    padding: 9px 16px;
    cursor: pointer;
    text-decoration: none;
    transition: transform .08s ease, box-shadow .08s ease;
    text-shadow: 1px 1px 0 rgba(255,255,255,.4);
}
.astromkt_wrap .astromkt_btn_full:hover,
.astromkt_wrap .astromkt_submit:hover,
.astromkt_wrap .astromkt_pick:hover {
    transform: translate(-1px, -1px);
    box-shadow: var(--mk-shadow);
}
.astromkt_wrap .astromkt_btn_full:active,
.astromkt_wrap .astromkt_submit:active { transform: translate(1px, 1px); box-shadow: none; }

/* ===== FORMULARIOS ===== */
.astromkt_wrap .astromkt_field { margin: 8px 0; }
.astromkt_wrap .astromkt_input,
.astromkt_wrap .astromkt_select {
    background: #fff;
    border: var(--mk-border-2);
    border-radius: 6px;
    color: var(--mk-brown);
    font-weight: 600;
    padding: 8px 10px;
    width: 100%;
    box-sizing: border-box;
}
.astromkt_wrap .astromkt_input:focus,
.astromkt_wrap .astromkt_select:focus { outline: 3px solid var(--mk-badge); }
.astromkt_wrap .astromkt_duration {
    background: var(--mk-cream-dark);
    border: var(--mk-border-2);
    border-radius: 6px;
    color: var(--mk-brown);
    font-weight: 700;
    padding: 8px 10px;
    cursor: pointer;
}
.astromkt_wrap .astromkt_duration.on {
    background: var(--mk-badge);
    color: #fff;
    text-shadow: 1px 1px 0 rgba(53,87,43,.7);
}

/* ===== TABLAS / LISTADOS (historial, mis listados, order book) ===== */
.astromkt_wrap table { border-collapse: separate; border-spacing: 0 4px; width: 100%; }
.astromkt_wrap th {
    background: var(--mk-cream-dark);
    color: var(--mk-brown);
    border: var(--mk-border-2);
    font-weight: 800;
    text-transform: uppercase;
    font-size: 11px;
    padding: 6px 10px;
}
.astromkt_wrap td {
    background: var(--mk-cream);
    color: var(--mk-brown);
    border-top: var(--mk-border-2);
    border-bottom: var(--mk-border-2);
    padding: 7px 10px;
    font-weight: 600;
}
.astromkt_wrap tr td:first-child { border-left: var(--mk-border-2); border-radius: 6px 0 0 6px; }
.astromkt_wrap tr td:last-child  { border-right: var(--mk-border-2); border-radius: 0 6px 6px 0; }

/* ===== VARIOS ===== */
.astromkt_wrap .astromkt_hint,
.astromkt_wrap .astromkt_empty {
    color: var(--mk-brown-soft);
    font-weight: 600;
}
.astromkt_wrap .astromkt_empty {
    background: var(--mk-cream);
    border: var(--mk-border-2);
    border-radius: 8px;
    padding: 16px;
    text-align: center;
}
.astromkt_wrap .astromkt_fmt { color: var(--mk-brown); font-weight: 800; }
.astromkt_wrap .astromkt_warning_banner {
    background: var(--mk-cream);
    border: var(--mk-border-2);
    border-left: 8px solid var(--mk-orange);
    border-radius: 6px;
    color: var(--mk-brown);
    font-weight: 700;
    padding: 10px 14px;
    box-shadow: var(--mk-shadow-sm);
}
.astromkt_wrap .astromkt_progress_bar { background: var(--mk-cream-dark); border: var(--mk-border-2); border-radius: 5px; }
.astromkt_wrap .astromkt_progress_bar > div { background: var(--mk-badge); }
.astromkt_wrap .astromkt_summary_row { color: var(--mk-brown); font-weight: 700; }
.astromkt_wrap .astromkt_total_text  { color: var(--mk-brown); font-weight: 800; }
.astromkt_wrap .astromkt_stat_text   { color: var(--mk-brown-soft); }

/* Enlaces genéricos dentro del mercado */
.astromkt_wrap a { color: var(--mk-blue); font-weight: 700; }

/* ===== RESPONSIVE ===== */
@media (max-width: 740px) {
    .astromkt_wrap .astromkt_panel { padding: 6px; }
    .astromkt_wrap .astromkt_header { padding: 10px; }
    .astromkt_wrap .astromkt_tabs { overflow-x: auto; flex-wrap: nowrap; padding-bottom: 4px; }
    .astromkt_wrap .astromkt_tab { white-space: nowrap; }
    .astromkt_wrap .astromkt_card,
    .astromkt_wrap .astromkt_mycard { width: 100% !important; box-sizing: border-box; }
    .astromkt_wrap table { display: block; overflow-x: auto; }
}
</style>

<div class="astromkt_wrap">
<div class="astromkt_panel">

	{* ===== HEADER ===== *}
	<div class="astromkt_header">
		<h1 class="astromkt_title">
			<span class="icon">🏴‍☠️</span> Mercado Negro
			<span class="astromkt_subtitle">Compra · Intercambia · Vende</span>
			{if $is_vip}<span style="color:#ffd94a; font-size:13px;">⭐ VIP</span>{/if}
		</h1>
		<div class="astromkt_balance_box">
			<div class="astromkt_balance_item">
				<div class="label">Saldo NTX-20</div>
				<div class="value">{$balance_ntx}</div>
			</div>
			{if $balance_frozen != '0'}
			<div class="astromkt_balance_item">
				<div class="label">Congelado</div>
				<div class="value" style="color:#94a3b8; text-shadow:none;">{$balance_frozen}</div>
			</div>
			{/if}
			<div class="astromkt_balance_item">
				<div class="label">Ofertas hoy</div>
				<div class="value {if $is_vip}vip{/if}">{$offers_today} / {$daily_limit_txt}</div>
			</div>
		</div>
	</div>

	{* ===== FEEDBACK ===== *}
	{if $feedback_ok}
		<div class="astromkt_feedback ok">✅ {$feedback_ok}</div>
	{/if}
	{if $feedback_error}
		{if $feedback_error_type == 'autocancelled'}
			<div class="astromkt_feedback warn">⚠️ {$feedback_error}</div>
		{else}
			<div class="astromkt_feedback err">⚠️ {$feedback_error}</div>
		{/if}
	{/if}

	{* ===== TABS ===== *}
	<div class="astromkt_tabs">
		<a href="game.php?page=market&tab=explore" class="astromkt_tab {if $tab_active=='explore'}active{/if}">🔍 Explorar</a>
		<a href="game.php?page=market&tab=sell"    class="astromkt_tab {if $tab_active=='sell'}active{/if}">➕ Vender</a>
		<a href="game.php?page=market&tab=buy"     class="astromkt_tab {if $tab_active=='buy'}active{/if}">🛒 Comprar</a>
		<a href="game.php?page=market&tab=boxes"   class="astromkt_tab {if $tab_active=='boxes'}active{/if}">📦 Cajas</a>
		<a href="game.php?page=market&tab=trends"  class="astromkt_tab {if $tab_active=='trends'}active{/if}">📈 Tendencias</a>
		<a href="game.php?page=market&tab=mine"    class="astromkt_tab {if $tab_active=='mine'}active{/if}">📋 Mis Listados</a>
		<a href="game.php?page=market&tab=history" class="astromkt_tab {if $tab_active=='history'}active{/if}">📜 Historial</a>
		<a href="game.php?page=market&tab=colonies" class="astromkt_tab astromkt_tab--colonies {if $tab_active=='colonies'}active{/if}">🏴‍☠️ Colonias</a>
		
		{* BOTÓN DE UNIFICACIÓN AL MERCADO INTERNACIONAL *}
		<a href="game.php?page=crossmarket" class="astromkt_tab astromkt_tab--cross">🌐 Mercado Internacional</a>
	</div>

	{* ============================================================
	   PESTAÑA EXPLORAR
	   ============================================================ *}
	{if $tab_active == 'explore'}
		{if $widget.top_sold || $widget.top_demanded}
		<div class="astromkt_widget">
			<div class="astromkt_widget_title">🔥 Tendencias hoy</div>
			{if $widget.top_sold}
			<div class="astromkt_widget_item">
				<span class="name">💰 Más vendido:</span>
				<span class="val">{$widget.top_sold.name} ({$widget.top_sold.total})</span>
				<span class="astromkt_trend_{$widget.top_sold.trend.class}">
					{$widget.top_sold.trend.icon} {$widget.top_sold.trend.pct}%
				</span>
			</div>
			{/if}
			{if $widget.top_demanded}
			<div class="astromkt_widget_item">
				<span class="name">🔥 Más demandado:</span>
				<span class="val">{$widget.top_demanded.name} ({$widget.top_demanded.total})</span>
				<span class="astromkt_trend_{$widget.top_demanded.trend.class}">
					{$widget.top_demanded.trend.icon} {$widget.top_demanded.trend.pct}%
				</span>
			</div>
			{/if}
		</div>
		{/if}

		<form method="get" action="game.php" class="astromkt_filters">
			<input type="hidden" name="page" value="market">
			<input type="hidden" name="tab" value="explore">
			<input type="text" name="q" value="{$filters.q}" placeholder="🔍 Buscar por ítem o vendedor..." class="astromkt_search">
			<div class="astromkt_cats">
				<a href="game.php?page=market&tab=explore&cat=all"          class="astromkt_cat {if $filters.cat=='all'}active{/if}">Todos</a>
				<a href="game.php?page=market&tab=explore&cat=resource"     class="astromkt_cat {if $filters.cat=='resource'}active{/if}">Recursos</a>
				<a href="game.php?page=market&tab=explore&cat=ship"         class="astromkt_cat {if $filters.cat=='ship'}active{/if}">Naves</a>
				<a href="game.php?page=market&tab=explore&cat=defense"      class="astromkt_cat {if $filters.cat=='defense'}active{/if}">Defensas</a>
				<a href="game.php?page=market&tab=explore&cat=box"          class="astromkt_cat {if $filters.cat=='box'}active{/if}">Cofres</a>
				<a href="game.php?page=market&tab=explore&cat=improvement"  class="astromkt_cat {if $filters.cat=='improvement'}active{/if}">🔧 Mejoras</a>
			</div>
			<select name="sort" class="astromkt_sort" onchange="this.form.submit()">
				<option value="recent"     {if $filters.sort=='recent'}selected{/if}>Más recientes</option>
				<option value="price_asc"  {if $filters.sort=='price_asc'}selected{/if}>Precio ↑</option>
				<option value="price_desc" {if $filters.sort=='price_desc'}selected{/if}>Precio ↓</option>
				<option value="expires"    {if $filters.sort=='expires'}selected{/if}>Expira antes</option>
			</select>
			<button type="submit" class="astromkt_cat">Buscar</button>
		</form>

		<div class="astromkt_counter">
			<span>Mostrando <b style="color:#00e0ff;">{$shown}</b> de <b style="color:#00e0ff;">{$total}</b> ofertas</span>
			{if $pages > 1}<span>Página {$page} de {$pages}</span>{/if}
		</div>

		{if $offers|@count > 0}
		<div class="astromkt_grid">
			{foreach $offers as $o}
			<div class="astromkt_card {if $o.is_admin}is-admin{/if}{if $o.is_improvement} is-improvement{/if}{if $o.item_type == 'container' || $o.item_type == 'box_climate'} is-container{/if}">
				<div class="astromkt_imgwrap">
					{if $o.item_type == 'metal'}
						<img src="styles/theme/gow/mercado/metal.gif" alt="{$o.item_name}">
					{elseif $o.item_type == 'crystal'}
						<img src="styles/theme/gow/mercado/cristal.gif" alt="{$o.item_name}">
					{elseif $o.item_type == 'deuterium'}
						<img src="styles/theme/gow/mercado/dulterio.gif" alt="{$o.item_name}">
					{elseif $o.item_type == 'dark_matter' || $o.item_type == 'mo'}
						<img src="styles/theme/gow/mercado/materia oscura.gif" alt="{$o.item_name}">
					{else}
						<img src="{$o.image}" alt="{$o.item_name}">
					{/if}
					{if $o.is_admin}
						<span class="astromkt_badge_tl admin">🛡️ ADMIN</span>
					{elseif $o.is_buy}
						<span class="astromkt_badge_tl buy">COMPRA</span>
					{elseif $o.is_improvement}
						<span class="astromkt_badge_tl improvement">🔧 {$o.category}</span>
					{else}
						<span class="astromkt_badge_tl {$o.item_type}">{$o.category}</span>
					{/if}
					<span class="astromkt_badge_tr">x{$o.amount_fmt}</span>
					{if !$o.is_admin}
						<span class="astromkt_timer_badge {$o.timer_cls}" data-expires="{$o.expires}" data-duration="{$o.duration}">⏱ {$o.timer_text}</span>
					{/if}
				</div>
				<div class="astromkt_body">
					<div class="astromkt_name">{$o.item_name}</div>
					<div class="astromkt_seller">
						{if $o.is_admin} Vendedor: <b style="color:#fbbf24;">Sistema AstroIO</b> {else} Vendedor: <b>{$o.seller_name}</b> {/if}
					</div>
					{if $o.is_improvement && $o.stat_text}
						<span class="astromkt_stat_text {if $o.item_cat == 'defense'}defense{/if}">
							{$o.stat_text}
							{if $o.item_cat == 'ship'} · 🚀 NAVE{else} · 🛡️ DEF{/if}
						</span>
					{/if}
					<div class="astromkt_price_row">
						<div class="astromkt_price_main">{$o.price_fmt}<span class="unit">NTX-20</span></div>
					</div>
					{if $o.show_fee_info}
						<div class="astromkt_fee_text {if $o.fee_pct==0}free{/if}">
							{$o.fee_label}: {$o.fee_pct}% ({$o.fee_amt_fmt} NTX-20)
						</div>
					{/if}
					{if $o.is_mine && !$o.is_buy && !$o.is_admin && $o.show_fee_info}
						<div class="astromkt_total_text">✅ Recibirás al vender: <b style="color:#66ff99;">{$o.net_receive_fmt} NTX-20</b></div>
					{elseif !$o.is_mine && $o.is_buy && !$o.is_admin && $o.show_fee_info}
						<div class="astromkt_total_text">✅ Recibirás si aceptás: <b style="color:#66ff99;">{$o.net_receive_fmt} NTX-20</b></div>
					{else}
						<div class="astromkt_total_text">Total a pagar: <b>{$o.buyer_pays_fmt} NTX-20</b></div>
					{/if}
					{if $o.is_mine}
						<span class="astromkt_btn_full astromkt_btn_full--disabled">Tu oferta</span>
					{elseif $o.is_buy}
						<a href="game.php?page=market&mode=fulfill&id={$o.offer_id}" class="astromkt_btn_full astromkt_btn_full--green" onclick="return confirm('¿Entregar {$o.amount_fmt} x {$o.item_name}?');">💰 Aceptar</a>
					{elseif $o.is_admin}
						<a href="game.php?page=market&mode=buy&id={$o.offer_id}" class="astromkt_btn_full astromkt_btn_full--gold" onclick="return confirm('¿Comprar {$o.item_name} por {$o.buyer_pays_fmt} NTX-20?');">🛒 Comprar</a>
					{elseif $o.item_type == 'ship' || $o.item_type == 'defense'}
						<a href="game.php?page=market&mode=buy&id={$o.offer_id}" class="astromkt_btn_full astromkt_btn_full--green" onclick="return confirm('¿Comprar {$o.item_name} por {$o.buyer_pays_fmt} NTX-20?');">🛒 Comprar</a>
					{elseif $o.item_type == 'box' || $o.item_type == 'mo' || $o.is_improvement || $o.item_type == 'container' || $o.item_type == 'box_climate'}
						<a href="game.php?page=market&mode=buy&id={$o.offer_id}" class="astromkt_btn_full astromkt_btn_full--purple" onclick="return confirm('¿Comprar {$o.item_name} por {$o.buyer_pays_fmt} NTX-20?');">🛒 Comprar</a>
					{else}
						<a href="game.php?page=market&mode=buy&id={$o.offer_id}" class="astromkt_btn_full astromkt_btn_full--cyan" onclick="return confirm('¿Comprar {$o.item_name} por {$o.buyer_pays_fmt} NTX-20?');">🛒 Comprar</a>
					{/if}
				</div>
			</div>
			{/foreach}
		</div>
		{if $pages > 1}
		<div class="astromkt_pagination">
			{if $page > 1}<a href="game.php?page=market&tab=explore&cat={$filters.cat}&sort={$filters.sort}&p={$page-1}">« Anterior</a>{/if}
			{foreach $pagination as $p}
				<a href="game.php?page=market&tab=explore&cat={$filters.cat}&sort={$filters.sort}&p={$p}" class="{if $p==$page}active{/if}">{$p}</a>
			{/foreach}
			{if $page < $pages}<a href="game.php?page=market&tab=explore&cat={$filters.cat}&sort={$filters.sort}&p={$page+1}">Siguiente »</a>{/if}
		</div>
		{/if}
		{else}
			<div class="astromkt_empty">😕 No hay ofertas disponibles con esos filtros.</div>
		{/if}
	{/if}

	{* ============================================================
	   PESTAÑA VENDER
	   ============================================================ *}
	{if $tab_active == 'sell'}
		<div class="astromkt_form">
			<div class="astromkt_section_title">➕ Publicar Oferta de Venta</div>
			{if $warning_no_storage}
			<div class="astromkt_warning_banner">
				<span class="astromkt_warning_icon">⚠️</span> <b>ATENCIÓN:</b> {$warning_text}
			</div>
			{/if}
			<div class="astromkt_hint--miles" style="margin-bottom:16px;">💡 <b>Publicar es GRATIS.</b> La comisión se descuenta solo cuando alguien compre tu oferta.</div>
			{if $offers_remaining == 0}
				<div class="astromkt_feedback err">⚠️ Has alcanzado el límite diario de ofertas. Hazte <a href="game.php?page=vip" style="color:#ff88aa;">⭐ VIP</a> para más.</div>
			{/if}
			<form method="post" action="game.php?page=market&mode=publishSell" id="astromktSellForm">
				<input type="hidden" name="item_type" id="sellItemType" value="metal">
				<input type="hidden" name="item_id"   id="sellItemId"   value="0">
				<input type="hidden" name="is_penalized" id="sellIsPenalized" value="0">
				<div class="astromkt_field">
					<label>¿Qué quieres vender?</label>
					<select id="sellType" class="astromkt_select">
						<option value="">--- Selecciona un recurso ---</option>
						<optgroup label="💎 Recursos">
							{foreach $sell_items as $item}
								{if $item.type == 'metal' || $item.type == 'crystal' || $item.type == 'deuterium'}
									<option value="{$item.type}|{$item.id}" data-avail="{$item.available}" data-name="{$item.name}" data-pen="0" data-resource="1">{$item.name} ({$item.available|number_format:0:',':'.'})</option>
								{elseif $item.type == 'dark_matter'}
									<option value="{$item.type}|{$item.id}" data-avail="{$item.available}" data-name="{$item.name}" data-pen="0" data-resource="0">{$item.name} ({$item.available|number_format:0:',':'.'})</option>
								{/if}
							{/foreach}
						</optgroup>
						<optgroup label="🚀 Naves">
							{foreach $sell_items as $item}
								{if $item.type == 'ship'}
									<option value="{$item.type}|{$item.id}" data-avail="{$item.available}" data-name="{$item.name}" data-pen="0" data-resource="0">{$item.name} ({$item.available|number_format:0:',':'.'})</option>
								{/if}
							{/foreach}
						</optgroup>
						<optgroup label="🛡️ Defensas">
							{foreach $sell_items as $item}
								{if $item.type == 'defense'}
									<option value="{$item.type}|{$item.id}" data-avail="{$item.available}" data-name="{$item.name}" data-pen="0" data-resource="0">{$item.name} ({$item.available|number_format:0:',':'.'})</option>
								{/if}
							{/foreach}
						</optgroup>
						<optgroup label="📦 Cofres">
							{foreach $sell_items as $item}
								{if $item.type == 'box' || $item.type == 'container' || $item.type == 'box_climate'}
									<option value="{$item.type}|{$item.id}" data-avail="{$item.available}" data-name="{$item.name}" data-pen="0" data-resource="0">{$item.name} ({$item.available|number_format:0:',':'.'})</option>
								{/if}
							{/foreach}
						</optgroup>
						{if $has_improvements}
						<optgroup label="🔧 Mejoras">
							{foreach $improvement_items as $imp}
								<option value="improvement|{$imp.id}" data-avail="{$imp.available}" data-name="{$imp.name}" data-pen="{$imp.is_penalized}" data-cat="{$imp.category}" data-stat="{$imp.stat_text}" data-resource="0">
									{if $imp.category == 'ship'}🚀{else}🛡️{/if} {$imp.name} ({$imp.available}) — {$imp.stat_text}
								</option>
							{/foreach}
						</optgroup>
						{/if}
					</select>
				</div>
				<div id="sellItemInfo" style="display:none; margin-bottom:16px;"><div class="astromkt_stat_text" id="sellItemStat"></div></div>
				<div class="astromkt_field">
					<label id="sellAmountLabel">Cantidad</label>
					<div class="astromkt_row"><input type="number" name="amount" id="sellAmount" min="1" value="1" class="astromkt_input"></div>
					<div class="astromkt_quick">
						<button type="button" onclick="astromkt_setAmount(0.25)">25%</button>
						<button type="button" onclick="astromkt_setAmount(0.5)">50%</button>
						<button type="button" onclick="astromkt_setAmount(1)">MAX</button>
					</div>
					<div class="astromkt_hint">Disponible: <b id="sellAvail">0</b></div>
					<div class="astromkt_hint--miles" id="sellMilesHint" style="display:none;">💡 <b>Recursos en miles:</b> Escribe <b>1</b> para vender <b>1.000 unidades</b>, <b>10</b> para <b>10.000</b>, etc.</div>
				</div>
				<div class="astromkt_field">
					<label>Precio (NTX-20)</label>
					<div class="astromkt_row"><input type="number" name="price_ntx" id="sellPrice" min="1" value="1" class="astromkt_input"></div>
					<div class="astromkt_quick"><button type="button" onclick="astromkt_suggestPrice()">💡 Sugerir precio</button></div>
					<div class="astromkt_hint" id="sellPriceHint">Precio mínimo: calculando...</div>
				</div>
				<div class="astromkt_field">
					<label>Duración</label>
					<div class="astromkt_durations">
						<div class="astromkt_duration selected" data-duration="24" onclick="astromkt_pickDuration(this)"><div class="time">24h</div><div class="fee">Comisión al vender: {$fee_24}%</div></div>
						<div class="astromkt_duration" data-duration="48" onclick="astromkt_pickDuration(this)"><div class="time">48h</div><div class="fee">Comisión al vender: {$fee_48}%</div></div>
					</div>
					<input type="hidden" name="duration" id="sellDuration" value="24">
				</div>
				<div class="astromkt_summary" id="sellSummary">
					<div class="astromkt_summary_row"><span>Precio de venta:</span><span id="sumPrice">1 NTX-20</span></div>
					<div class="astromkt_summary_row"><span>Comisión al vender:</span><span id="sumFee" style="color:#ef4444;">-0 NTX-20</span></div>
					<div class="astromkt_summary_row total"><span>Recibirás al vender:</span><span id="sumNet">1 NTX-20</span></div>
					<div class="astromkt_summary_note">💰 Publicar es gratis. La comisión se cobra solo al vender.</div>
				</div>
				<button type="submit" class="astromkt_submit" {if $offers_remaining == 0}disabled{/if}>✅ Publicar Oferta (Gratis)</button>
			</form>
		</div>
	{/if}

	{* ============================================================
	   PESTAÑA COMPRAR
	   ============================================================ *}
	{if $tab_active == 'buy'}
		<div class="astromkt_form">
			<div class="astromkt_section_title">🛒 Publicar Orden de Compra</div>
			{if $warning_no_storage}
			<div class="astromkt_warning_banner">
				<span class="astromkt_warning_icon">⚠️</span> <b>ATENCIÓN:</b> {$warning_text}
			</div>
			{/if}
			<div class="astromkt_hint--miles" style="margin-bottom:16px;">💡 <b>Publicar es GRATIS.</b> La comisión la paga el aceptador cuando te entregue el ítem.</div>
			{if $offers_remaining == 0}
				<div class="astromkt_feedback err">⚠️ Has alcanzado el límite diario. Hazte <a href="game.php?page=vip" style="color:#ff88aa;">⭐ VIP</a> para más.</div>
			{/if}
			<form method="post" action="game.php?page=market&mode=publishBuy" id="astromktBuyForm">
				<input type="hidden" name="item_type" id="buyItemType" value="metal">
				<input type="hidden" name="item_id"   id="buyItemId"   value="0">
				<div class="astromkt_field">
					<label>Quiero comprar</label>
					<select id="buyType" class="astromkt_select">
						<option value="">--- Selecciona un recurso ---</option>
						<optgroup label="💎 Recursos">
							{foreach $buy_items as $item}
								{if $item.type == 'metal' || $item.type == 'crystal' || $item.type == 'deuterium'}
									<option value="{$item.type}|{$item.id}" data-name="{$item.name}" data-resource="1">{$item.name}</option>
								{elseif $item.type == 'dark_matter'}
									<option value="{$item.type}|{$item.id}" data-name="{$item.name}" data-resource="0">{$item.name}</option>
								{/if}
							{/foreach}
						</optgroup>
						<optgroup label="🚀 Naves">
							{foreach $buy_items as $item}
								{if $item.type == 'ship'}
									<option value="{$item.type}|{$item.id}" data-name="{$item.name}" data-resource="0">{$item.name}</option>
								{/if}
							{/foreach}
						</optgroup>
						<optgroup label="🛡️ Defensas">
							{foreach $buy_items as $item}
								{if $item.type == 'defense'}
									<option value="{$item.type}|{$item.id}" data-name="{$item.name}" data-resource="0">{$item.name}</option>
								{/if}
							{/foreach}
						</optgroup>
						<optgroup label="📦 Cofres">
							{foreach $buy_items as $item}
								{if $item.type == 'box' || $item.type == 'container' || $item.type == 'box_climate'}
									<option value="{$item.type}|{$item.id}" data-name="{$item.name}" data-resource="0">{$item.name}</option>
								{/if}
							{/foreach}
						</optgroup>
						{if $has_improvement_catalog}
						<optgroup label="🔧 Mejoras">
							{foreach $improvement_catalog as $imp}
								<option value="improvement|{$imp.id}" data-name="{$imp.name}" data-resource="0">
									{if $imp.category == 'ship'}🚀{else}🛡️{/if} {$imp.name} — {$imp.stat_text}
								</option>
							{/foreach}
						</optgroup>
						{/if}
					</select>
				</div>
				<div class="astromkt_field">
					<label id="buyAmountLabel">Cantidad</label>
					<input type="number" name="amount" id="buyAmount" min="1" value="1" class="astromkt_input">
					<div class="astromkt_hint--miles" id="buyMilesHint" style="display:none;">💡 <b>Recursos en miles:</b> Escribe <b>1</b> para comprar <b>1.000 unidades</b>, <b>10</b> para <b>10.000</b>, etc.</div>
				</div>
				<div class="astromkt_field">
					<label>Precio que ofrezco (NTX-20)</label>
					<input type="number" name="price_ntx" min="1" value="1" class="astromkt_input">
					<div class="astromkt_hint">El precio se verifica al ejecutarse. Sin comisión para ti.</div>
				</div>
				<div class="astromkt_field">
					<label>Duración</label>
					<div class="astromkt_durations">
						<div class="astromkt_duration selected" data-duration="24" onclick="astromkt_pickDurationBuy(this)"><div class="time">24h</div><div class="fee">Fee aceptador: {$fee_24}%</div></div>
						<div class="astromkt_duration" data-duration="48" onclick="astromkt_pickDurationBuy(this)"><div class="time">48h</div><div class="fee">Fee aceptador: {$fee_48}%</div></div>
					</div>
					<input type="hidden" name="duration" value="24">
				</div>
				<div class="astromkt_summary">
					<div class="astromkt_summary_row"><span>Saldo disponible:</span><span>{$balance_available} NTX-20</span></div>
					<div class="astromkt_summary_row total"><span>Se verificará al ejecutar:</span><span id="buyFrozen">1 NTX-20</span></div>
					<div class="astromkt_summary_note">💰 Publicar es gratis. El NTX-20 sigue en tu cuenta y se verifica al momento en que alguien acepte tu orden. La comisión la paga el vendedor que te entregue el ítem.</div>
				</div>
				<button type="submit" class="astromkt_submit buy" {if $offers_remaining == 0}disabled{/if}>💰 Publicar Orden de Compra</button>
			</form>
		</div>
	{/if}

	{* ============================================================
	   PESTAÑA CAJAS
	   ============================================================ *}
	{if $tab_active == 'boxes'}
		<div class="astromkt_section_title">📦 Cajas de Suministro</div>
		<div class="astromkt_boxes">
			{foreach $boxes as $box}
			<div class="astromkt_box {$box.color}">
				<div class="astromkt_box_img"><img src="{$box.image}" alt="{$box.name}"></div>
				<div class="astromkt_box_name">{$box.name}</div>
				<div class="astromkt_box_desc">{$box.desc}</div>
				<div class="astromkt_box_count">x{$box.count}</div>
			</div>
			{/foreach}
		</div>
		<div class="astromkt_empty">💡 Las cajas se pueden vender o comprar en el mercado. ¡Próximamente abrir cajas!</div>
	{/if}

	{* ============================================================
	   PESTAÑA TENDENCIAS
	   ============================================================ *}
	{if $tab_active == 'trends'}
		<div class="astromkt_section_title">📈 Tendencias del Mercado (7 días)</div>
		<div class="astromkt_trends_grid">
			<div class="astromkt_trend_box">
				<div class="astromkt_trend_head">💰 Más vendidos</div>
				{if $top_sold|@count > 0}
					{foreach $top_sold as $i => $t}
					<div class="astromkt_trend_row">
						<span class="astromkt_trend_pos">{$i+1}.</span>
						<span class="astromkt_trend_img">
							{if isset($t.item_type) && $t.item_type == 'metal'}<img src="styles/theme/gow/mercado/metal.gif">
							{elseif isset($t.item_type) && $t.item_type == 'crystal'}<img src="styles/theme/gow/mercado/cristal.gif">
							{elseif isset($t.item_type) && $t.item_type == 'deuterium'}<img src="styles/theme/gow/mercado/dulterio.gif">
							{elseif isset($t.item_type) && ($t.item_type == 'dark_matter' || $t.item_type == 'mo')}<img src="styles/theme/gow/mercado/materia oscura.gif">
							{else}<img src="{$t.image}">{/if}
						</span>
						<span class="astromkt_trend_name">{$t.item_name}</span>
						<span class="astromkt_trend_bar"><span class="astromkt_trend_fill" style="width:{$t.pct}%"></span></span>
						<span class="astromkt_trend_val">{$t.total}</span>
					</div>
					{/foreach}
				{else}<div class="astromkt_empty">Sin datos aún</div>{/if}
			</div>
			<div class="astromkt_trend_box">
				<div class="astromkt_trend_head">🔥 Más demandados</div>
				{if $top_demanded|@count > 0}
					{foreach $top_demanded as $i => $t}
					<div class="astromkt_trend_row">
						<span class="astromkt_trend_pos">{$i+1}.</span>
						<span class="astromkt_trend_img">
							{if isset($t.item_type) && $t.item_type == 'metal'}<img src="styles/theme/gow/mercado/metal.gif">
							{elseif isset($t.item_type) && $t.item_type == 'crystal'}<img src="styles/theme/gow/mercado/cristal.gif">
							{elseif isset($t.item_type) && $t.item_type == 'deuterium'}<img src="styles/theme/gow/mercado/dulterio.gif">
							{elseif isset($t.item_type) && ($t.item_type == 'dark_matter' || $t.item_type == 'mo')}<img src="styles/theme/gow/mercado/materia oscura.gif">
							{else}<img src="{$t.image}">{/if}
						</span>
						<span class="astromkt_trend_name">{$t.item_name}</span>
						<span class="astromkt_trend_bar"><span class="astromkt_trend_fill" style="width:{$t.pct}%"></span></span>
						<span class="astromkt_trend_val">{$t.demand}</span>
					</div>
					{/foreach}
				{else}<div class="astromkt_empty">Sin datos aún</div>{/if}
			</div>
		</div>
		{if $chart_item}
		<div class="astromkt_chart_box">
			<div class="astromkt_chart_head">
				<div style="font-weight:800; color:#00e0ff; font-size:13px;">📊 Evolución de precios: <b style="color:#fff;">{$chart_item.name}</b></div>
				<select class="astromkt_sort" onchange="location.href='game.php?page=market&tab=trends&ct='+this.value.split('|')[0]+'&ci='+this.value.split('|')[1];">
					{foreach $trendable_items as $t}
						<option value="{$t.item_type}|{$t.item_id}" {if $t.item_type==$chart_item.type && $t.item_id==$chart_item.id}selected{/if}>{$t.item_name}</option>
					{/foreach}
				</select>
			</div>
			<div class="astromkt_chart_container"><canvas id="astromktChart"></canvas></div>
			<div class="astromkt_chart_footer">
				<span>Tendencia:</span>
				<span class="astromkt_trend_{$chart_trend.class}">{$chart_trend.icon} {$chart_trend.pct}%</span>
			</div>
		</div>
		{else}<div class="astromkt_empty">Aún no hay suficientes datos para mostrar gráficos.</div>{/if}
	{/if}

	{* ============================================================
	   PESTAÑA MIS LISTADOS
	   ============================================================ *}
	{if $tab_active == 'mine'}
		<div class="astromkt_section_title">📋 Mis Listados ({$my_offers|@count})</div>
		{if $my_offers|@count > 0}
			{foreach $my_offers as $o}
			<div class="astromkt_mycard astromkt_mycard--{$o.urgency}{if $o.is_autocancelled} astromkt_mycard--autocancelled{/if}">
				<div class="astromkt_myhead">
					{if $o.status == 'active'}
						<span class="astromkt_timer_badge {$o.timer_cls}" style="position:static;" data-expires="{$o.expires}" data-duration="{$o.duration}">⏱ {$o.timer_text}</span>
					{else}
						<span class="astromkt_status_badge {$o.status}">{$o.status_label}</span>
					{/if}
					<span class="astromkt_badge_tl {$o.item_type}" style="position:static;">{$o.category}</span>
					<span class="astromkt_badge_tr" style="position:static;">x{$o.amount_fmt}</span>
				</div>
				<div style="display:flex; gap:14px; align-items:center;">
					<div class="astromkt_imgwrap" style="width:90px; height:90px; border-radius:10px; flex-shrink:0;">
						{if $o.item_type == 'metal'}<img src="styles/theme/gow/mercado/metal.gif" style="max-height:75px;">
						{elseif $o.item_type == 'crystal'}<img src="styles/theme/gow/mercado/cristal.gif" style="max-height:75px;">
						{elseif $o.item_type == 'deuterium'}<img src="styles/theme/gow/mercado/dulterio.gif" style="max-height:75px;">
						{elseif $o.item_type == 'dark_matter' || $o.item_type == 'mo'}<img src="styles/theme/gow/mercado/materia oscura.gif" style="max-height:75px;">
						{else}<img src="{$o.image}" style="max-height:75px;">{/if}
					</div>
					<div style="flex:1;">
						<div class="astromkt_name">{$o.item_name}</div>
						<div style="color:#00e0ff; font-weight:800; font-family:'Courier New', monospace; font-size:18px; text-shadow: 0 0 12px rgba(0,224,255,0.4);">{$o.price_fmt} NTX-20</div>
						{if $o.is_admin}
							<div style="font-size:11px; color:#fbbf24; margin-top:4px;">🛡️ Oferta admin — sin comisión</div>
						{elseif $o.is_buy}
							<div style="font-size:11px; color:#94a3b8; margin-top:4px;">💰 Orden de compra — el aceptador pagará {$o.fee_pct}% de comisión</div>
						{elseif $o.show_fee_info}
							<div style="font-size:11px; color:#94a3b8; margin-top:4px;">{$o.fee_label}: {$o.fee_pct}% ({$o.fee_amt_fmt} NTX-20)</div>
							<div style="font-size:11.5px; color:#66ff99; margin-top:2px; font-weight:700;">✅ Recibirás al vender: {$o.net_receive_fmt} NTX-20</div>
						{/if}
					</div>
				</div>
				{if $o.cancel_reason_label}
					<div class="astromkt_cancel_reason {if $o.is_autocancelled}autocancelled{/if}">
						<span class="astromkt_cancel_icon">ℹ️</span> {$o.cancel_reason_label}
					</div>
				{/if}
				{if $o.status == 'active'}
					<div class="astromkt_progress">
						<div class="astromkt_progress_bar {$o.urgency}" style="width:{$o.progress}%"></div>
						<span class="astromkt_progress_text">{$o.progress}% restante</span>
					</div>
					<div style="text-align:right; margin-top:10px;">
						<a href="game.php?page=market&mode=cancel&id={$o.offer_id}" class="astromkt_cancel" onclick="return confirm('¿Cancelar esta oferta? Tus naves y recursos siguen en tu planeta (nunca se quitaron). No perderás nada.');">❌ Cancelar</a>
					</div>
				{/if}
			</div>
			{/foreach}
		{else}
			<div class="astromkt_empty">📭 No tienes ofertas. <a href="game.php?page=market&tab=sell" style="color:#00e0ff;">Publicar una</a></div>
		{/if}
	{/if}

	{* ============================================================
	   PESTAÑA HISTORIAL
	   ============================================================ *}
	{if $tab_active == 'history'}
		<div class="astromkt_section_title">📜 Historial de Operaciones</div>
		{if $history|@count > 0}
		<div class="astromkt_history">
			{foreach $history as $h}
			<div class="astromkt_hrow">
				<div class="astromkt_hrow_img">
					{if isset($h.item_type) && $h.item_type == 'metal'}<img src="styles/theme/gow/mercado/metal.gif">
					{elseif isset($h.item_type) && $h.item_type == 'crystal'}<img src="styles/theme/gow/mercado/cristal.gif">
					{elseif isset($h.item_type) && $h.item_type == 'deuterium'}<img src="styles/theme/gow/mercado/dulterio.gif">
					{elseif isset($h.item_type) && ($h.item_type == 'dark_matter' || $h.item_type == 'mo')}<img src="styles/theme/gow/mercado/materia oscura.gif">
					{else}<img src="{$h.image}">{/if}
				</div>
				<div class="astromkt_hrow_main">
					<div class="astromkt_hrow_name">{$h.item_name} x{$h.amount_fmt}</div>
					<div class="astromkt_hrow_meta">{$h.date}</div>
				</div>
				<div class="astromkt_hrow_price">{if $h.is_buy}-{else}+{/if}{$h.price_fmt} NTX-20</div>
				<span class="astromkt_hrow_role {$h.role_class}">{$h.role}</span>
			</div>
			{/foreach}
		</div>
		{else}
			<div class="astromkt_empty">📭 Aún no has hecho ninguna operación.</div>
		{/if}
	{/if}

	{* ============================================================
	   v4.9 — PESTAÑA COLONIAS (Mercado Negro)
	   ============================================================ *}
	{if $tab_active == 'colonies'}
		{* HERO *}
		<div style="background:linear-gradient(135deg, rgba(80,20,20,0.4), rgba(30,10,10,0.4)); border:1px solid rgba(255,215,0,0.4); border-radius:12px; padding:18px 22px; margin-bottom:20px; text-align:center;">
			<h2 style="margin:0 0 8px; color:#ffd700; font-size:20px; font-weight:800; letter-spacing:1px; text-shadow:0 0 14px rgba(255,215,0,0.5);">🏴‍☠️ Mercado Negro de Colonias</h2>
			<p style="margin:0 0 12px; color:#b8a878; font-size:11.5px; line-height:1.5;">
				Compra y vende colonias entre jugadores. El <b style="color:#ffd700;">planeta principal nunca se vende</b>.
				Al comprar, recibes <b style="color:#ffd700;">todo</b>: edificios, defensas, naves y recursos.
			</p>
			<div style="display:flex; justify-content:center; gap:20px; flex-wrap:wrap; font-size:11px; color:#cbd5e1;">
				<span>💰 Saldo: <b style="color:#ffd700;">{$balance_available} NTX-20</b></span>
				<span>🪐 Planetas: <b style="color:#ffd700;">{$col_my_planets}/{$col_max_planets}</b></span>
				<span>📊 Comisión: <b style="color:#ffd700;">{$col_fee_pct}%</b></span>
			</div>
		</div>

		{* PUBLICAR *}
		<div class="astromkt_form" style="max-width:100%; margin-bottom:20px;">
			<div class="astromkt_section_title">📤 Poner una colonia en venta</div>

			{if $col_sellable|@count == 0}
				<div class="astromkt_empty">No tienes colonias vendibles. Solo se venden colonias, nunca el planeta principal.</div>
			{else}
				<form method="post" action="game.php?page=market&mode=publishColony">
					<div class="astromkt_row" style="align-items:flex-end;">
						<div class="astromkt_field" style="flex:2; margin-bottom:0;">
							<label>Colonia</label>
							<select name="planet_id" required class="astromkt_select">
								{foreach $col_sellable as $p}
									<option value="{$p.id}">{$p.name} — {$p.coords}</option>
								{/foreach}
							</select>
						</div>
						<div class="astromkt_field" style="flex:1; margin-bottom:0;">
							<label>Precio (NTX-20)</label>
							<input type="number" name="price" min="{$col_min_price}" max="{$col_max_price}" required class="astromkt_input" placeholder="{$col_min_price}-{$col_max_price}">
						</div>
						<div style="flex:1;">
							<button type="submit" class="astromkt_submit" style="background:linear-gradient(135deg,#b8860b,#ffd700); border-color:#ffd700; color:#1a1000;">🏴‍☠️ Publicar</button>
						</div>
					</div>
					<div class="astromkt_hint--miles" style="margin-top:12px;">
						⚠️ Se vende TODO lo que hay dentro: edificios, defensas, naves y recursos.<br>
						💡 Asegúrate de no tener flotas en vuelo ni estacionadas en esa colonia.<br>
						💰 Comisión del servidor: <b>{$col_fee_pct}%</b> (menos si eres VIP).
					</div>
				</form>
			{/if}
		</div>

		{* MIS COLONIAS EN VENTA *}
		{if $col_my_listings|@count > 0}
		<div style="margin-bottom:20px;">
			<div class="astromkt_section_title">📋 Mis colonias en venta ({$col_my_listings|@count})</div>
			{foreach $col_my_listings as $l}
			<div class="astromkt_mycard astromkt_mycard--colony">
				<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:14px;">
					<div style="flex:1; min-width:180px;">
						<div class="astromkt_name" style="color:#ffd700;">🪐 {$l.planet_name}</div>
						<div style="color:#00e0ff; font-family:'Courier New', monospace; font-size:11px;">{$l.coords}</div>
						<div style="font-size:10.5px; color:#94a3b8; margin-top:4px;">Publicada: {$l.created|date_format:"%d/%m/%Y"}</div>
					</div>
					<div style="text-align:right;">
						<div style="color:#ffd700; font-weight:800; font-family:'Courier New', monospace; font-size:20px; text-shadow:0 0 14px rgba(255,215,0,0.5);">{$l.price_fmt} NTX-20</div>
						<div style="font-size:10.5px; color:#94a3b8;">Fee {$l.fee_pct}% · Recibirás <b style="color:#66ff99;">{$l.net|number_format:0:',"':'.'} NTX-20</b></div>
					</div>
					<a href="game.php?page=market&mode=cancelColony&id={$l.id}" class="astromkt_cancel" onclick="return confirm('¿Cancelar la venta de {$l.planet_name}? Tu colonia seguirá siendo tuya.');">❌ Cancelar</a>
				</div>
			</div>
			{/foreach}
		</div>
		{/if}

		{* COLONIAS DISPONIBLES *}
		<div style="margin-bottom:20px;">
			<div class="astromkt_section_title">🛒 Colonias en venta</div>

			{if $col_listings|@count > 0}
				<div class="astromkt_grid">
					{foreach $col_listings as $l}
					<div class="astromkt_card is-colony">
						<div class="astromkt_imgwrap" style="height:130px;">
							<span style="font-size:70px; filter:drop-shadow(0 0 22px rgba(255,215,0,0.6));">🪐</span>
							<span class="astromkt_badge_tl colony">Colonia</span>
							{if $l.seller_vip}
								<span class="astromkt_badge_tr">⭐ VIP</span>
							{/if}
						</div>
						<div class="astromkt_body">
							<div class="astromkt_name" style="color:#ffd700;">{$l.planet_name}</div>
							<div class="astromkt_seller">
								📍 <b style="color:#00e0ff;">{$l.coords}</b> · Vendedor: <b>{$l.seller_name}</b>
							</div>

							<div class="astromkt_price_row" style="border-bottom:1px solid rgba(255,215,0,0.2);">
								<div class="astromkt_price_main" style="color:#ffd700; text-shadow:0 0 16px rgba(255,215,0,0.5);">{$l.price_fmt}<span class="unit">NTX-20</span></div>
							</div>

							{if $l.preview}
							<details style="margin-bottom:10px; font-size:11px;">
								<summary style="cursor:pointer; color:#00e0ff; font-weight:700; padding:6px 0;">🔍 Ver qué incluye</summary>
								<div style="padding:8px 0 4px; border-top:1px dashed rgba(255,255,255,0.1); margin-top:4px;">
									<div style="display:flex; justify-content:space-between; padding:3px 0;"><span>🔩 Metal:</span><b style="color:#00e0ff;">{$l.preview.metal|number_format:0:',"':'.'}</b></div>
									<div style="display:flex; justify-content:space-between; padding:3px 0;"><span>💎 Cristal:</span><b style="color:#00e0ff;">{$l.preview.crystal|number_format:0:',"':'.'}</b></div>
									<div style="display:flex; justify-content:space-between; padding:3px 0;"><span>⚗️ Deuterio:</span><b style="color:#00e0ff;">{$l.preview.deuterium|number_format:0:',"':'.'}</b></div>
									<div style="display:flex; justify-content:space-between; padding:3px 0;"><span>🚀 Naves:</span><b style="color:#00e0ff;">{$l.preview.ships_count|number_format:0:',"':'.'}</b></div>
									<div style="display:flex; justify-content:space-between; padding:3px 0;"><span>🛡️ Defensas:</span><b style="color:#00e0ff;">{$l.preview.defs_count|number_format:0:',"':'.'}</b></div>
								</div>
							</details>
							{/if}

							<a href="game.php?page=market&mode=buyColony&id={$l.id}"
							   class="astromkt_btn_full astromkt_btn_full--gold"
							   onclick="return confirm('¿Comprar {$l.planet_name} por {$l.price_fmt} NTX-20? Se te cobrarán ahora.');">
								🛒 Comprar
							</a>
						</div>
					</div>
					{/foreach}
				</div>
			{else}
				<div class="astromkt_empty">🏴‍☠️ No hay colonias en venta ahora mismo. ¡Sé el primero en publicar una!</div>
			{/if}
		</div>
	{/if}

</div>
</div>

{* ============================================================
   JAVASCRIPT
   ============================================================ *}
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
function astromkt_fmt(n) {
	n = Math.floor(n);
	return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

function astromkt_tickCountdown() {
	document.querySelectorAll('[data-expires]').forEach(function(el) {
		var expires  = parseInt(el.dataset.expires);
		var duration = parseInt(el.dataset.duration) * 3600;
		if (!expires || expires === 0) return;

		var now = Math.floor(Date.now() / 1000);
		var rem = expires - now;

		if (rem <= 0) {
			el.textContent = '⏱ Expirada';
			el.className = 'astromkt_timer_badge expired';
			return;
		}

		var h = Math.floor(rem / 3600);
		var m = Math.floor((rem % 3600) / 60);
		var s = rem % 60;

		el.textContent = '⏱ ' +
			String(h).padStart(2,'0') + 'h ' +
			String(m).padStart(2,'0') + 'm ' +
			String(s).padStart(2,'0') + 's';

		var cls = 'ok';
		if (rem < 3600)      cls = 'critical';
		else if (rem < 10800) cls = 'warning';
		else if (rem < 21600) cls = 'attention';

		el.classList.remove('ok','attention','warning','critical','infinite','expired');
		el.classList.add(cls);

		var bar = el.parentElement.parentElement.querySelector('.astromkt_progress_bar');
		if (bar && duration > 0) {
			var pct = Math.max(0, Math.round((rem / duration) * 100));
			bar.style.width = pct + '%';
			bar.className = 'astromkt_progress_bar ' + cls;
			var txt = el.parentElement.parentElement.querySelector('.astromkt_progress_text');
			if (txt) txt.textContent = pct + '% restante';
		}
	});
}
setInterval(astromkt_tickCountdown, 1000);
astromkt_tickCountdown();

function astromkt_setAmount(ratio) {
	var availEl  = document.getElementById('sellAvail');
	var amountEl = document.getElementById('sellAmount');
	if (!availEl || !amountEl) return;
	var avail = parseInt(availEl.textContent.replace(/\./g,'')) || 0;
	amountEl.value = Math.max(1, Math.floor(avail * ratio));
	astromkt_recalcSell();
}

function astromkt_pickDuration(el) {
	document.querySelectorAll('.astromkt_duration').forEach(function(d) {
		d.classList.remove('selected');
	});
	el.classList.add('selected');
	var input = document.getElementById('sellDuration');
	if (input) input.value = el.dataset.duration;
	astromkt_recalcSell();
}

function astromkt_pickDurationBuy(el) {
	document.querySelectorAll('.astromkt_duration').forEach(function(d) {
		d.classList.remove('selected');
	});
	el.classList.add('selected');
	var form = document.getElementById('astromktBuyForm');
	if (form) {
		form.querySelector('input[name="duration"]').value = el.dataset.duration;
	}
}

function astromkt_onItemChange() {
	var sel = document.getElementById('sellType');
	if (!sel) return;

	var opt = sel.options[sel.selectedIndex];
	if (!opt) return;

	var avail = parseInt(opt.dataset.avail) || 0;
	var isResource = (opt.dataset.resource === '1');

	var availDisplay = isResource ? Math.floor(avail / 1000) : avail;

	var availEl = document.getElementById('sellAvail');
	if (availEl) availEl.textContent = astromkt_fmt(availDisplay) + (isResource ? ' (miles)' : '');

	var labelEl = document.getElementById('sellAmountLabel');
	var hintEl  = document.getElementById('sellMilesHint');
	if (labelEl) {
		labelEl.textContent = isResource ? 'Cantidad (en miles)' : 'Cantidad';
	}
	if (hintEl) {
		hintEl.style.display = isResource ? 'block' : 'none';
	}

	var parts = sel.value.split('|');
	var hiddenType = document.getElementById('sellItemType');
	var hiddenId   = document.getElementById('sellItemId');
	var hiddenPen  = document.getElementById('sellIsPenalized');
	if (hiddenType) hiddenType.value = parts[0] || 'metal';
	if (hiddenId)   hiddenId.value   = parts[1] || 0;
	if (hiddenPen)  hiddenPen.value  = opt.dataset.pen || '0';

	var infoBox = document.getElementById('sellItemInfo');
	var statEl  = document.getElementById('sellItemStat');
	if (infoBox && statEl) {
		if (parts[0] === 'improvement' && opt.dataset.stat) {
			statEl.textContent = opt.dataset.stat + ' · ' +
				(opt.dataset.cat === 'ship' ? '🚀 NAVE' : '🛡️ DEFENSA');
			statEl.className = 'astromkt_stat_text ' +
				(opt.dataset.cat === 'defense' ? 'defense' : 'ship');
			infoBox.style.display = 'block';
		} else {
			infoBox.style.display = 'none';
		}
	}

	astromkt_recalcSell();
	astromkt_checkMinPrice();
}

function astromkt_onBuyItemChange() {
	var sel = document.getElementById('buyType');
	if (!sel) return;

	var opt = sel.options[sel.selectedIndex];
	var isResource = opt && (opt.dataset.resource === '1');

	var labelEl = document.getElementById('buyAmountLabel');
	var hintEl  = document.getElementById('buyMilesHint');
	if (labelEl) {
		labelEl.textContent = isResource ? 'Cantidad (en miles)' : 'Cantidad';
	}
	if (hintEl) {
		hintEl.style.display = isResource ? 'block' : 'none';
	}

	var parts = sel.value.split('|');
	var hiddenType = document.getElementById('buyItemType');
	var hiddenId   = document.getElementById('buyItemId');
	if (hiddenType) hiddenType.value = parts[0] || 'metal';
	if (hiddenId)   hiddenId.value   = parts[1] || 0;
}

function astromkt_recalcSell() {
	var priceEl = document.getElementById('sellPrice');
	var durEl   = document.getElementById('sellDuration');
	if (!priceEl || !durEl) return;

	var price = parseInt(priceEl.value) || 0;

	var feePct = 5;
	var durDiv = document.querySelector('#astromktSellForm .astromkt_duration.selected');
	if (durDiv) {
		var txt = durDiv.querySelector('.fee').textContent;
		var m = txt.match(/(\d+)%/);
		if (m) feePct = parseInt(m[1]);
	}

	var fee = Math.ceil(price * feePct / 100);
	var net = price - fee;

	var pEl = document.getElementById('sumPrice');
	var fEl = document.getElementById('sumFee');
	var nEl = document.getElementById('sumNet');
	if (pEl) pEl.textContent = astromkt_fmt(price) + ' NTX-20';
	if (fEl) fEl.textContent = '-' + astromkt_fmt(fee) + ' NTX-20 (' + feePct + '%)';
	if (nEl) nEl.textContent = astromkt_fmt(net) + ' NTX-20';
}

function astromkt_recalcBuy() {
	var priceEl = document.querySelector('#astromktBuyForm input[name="price_ntx"]');
	var frozenEl = document.getElementById('buyFrozen');
	if (!priceEl || !frozenEl) return;

	var price = parseInt(priceEl.value) || 0;
	frozenEl.textContent = astromkt_fmt(price) + ' NTX-20';
}

function astromkt_checkMinPrice() {
	var sel = document.getElementById('sellType');
	var priceEl = document.getElementById('sellPrice');
	var hintEl = document.getElementById('sellPriceHint');
	if (!sel || !priceEl || !hintEl) return;

	var parts = sel.value.split('|');
	var type = parts[0] || 'metal';
	var id = parseInt(parts[1]) || 0;

	var url = 'game.php?page=market&mode=suggest&item_type=' +
	          encodeURIComponent(type) + '&item_id=' + id;

	fetch(url)
		.then(function(r){ return r.json(); })
		.then(function(data){
			if (data.min > 0) {
				var minPrice = data.min;
				hintEl.textContent = '💡 Precio mínimo: ' + astromkt_fmt(minPrice) +
				                     ' NTX-20 · Sugerido: ' + astromkt_fmt(data.avg);
				hintEl.className = 'astromkt_hint';
				if (parseInt(priceEl.value) < minPrice) {
					priceEl.classList.add('error');
					hintEl.className = 'astromkt_hint error';
				} else {
					priceEl.classList.remove('error');
				}
			} else {
				hintEl.textContent = '💡 Sé el primero en vender este ítem';
				hintEl.className = 'astromkt_hint';
				priceEl.classList.remove('error');
			}
		})
		.catch(function(){
			hintEl.textContent = 'Precio mínimo: sin datos';
		});
}

function astromkt_suggestPrice() {
	var sel = document.getElementById('sellType');
	var priceEl = document.getElementById('sellPrice');
	if (!sel || !priceEl) return;

	var parts = sel.value.split('|');
	var type = parts[0] || 'metal';
	var id = parseInt(parts[1]) || 0;

	fetch('game.php?page=market&mode=suggest&item_type=' +
	      encodeURIComponent(type) + '&item_id=' + id)
		.then(function(r){ return r.json(); })
		.then(function(data){
			if (data.avg > 0) {
				priceEl.value = data.avg;
				astromkt_recalcSell();
				astromkt_checkMinPrice();
			} else {
				alert('No hay ofertas similares para sugerir un precio.');
			}
		})
		.catch(function(){
			alert('Error al consultar el precio sugerido.');
		});
}

document.addEventListener('DOMContentLoaded', function() {
	var sel = document.getElementById('sellType');
	if (sel) {
		sel.addEventListener('change', astromkt_onItemChange);
		astromkt_onItemChange();
	}

	var priceEl = document.getElementById('sellPrice');
	if (priceEl) {
		priceEl.addEventListener('input', function(){
			astromkt_recalcSell();
			astromkt_checkMinPrice();
		});
	}

	var amtEl = document.getElementById('sellAmount');
	if (amtEl) amtEl.addEventListener('input', astromkt_recalcSell);

	var selBuy = document.getElementById('buyType');
	if (selBuy) {
		selBuy.addEventListener('change', astromkt_onBuyItemChange);
		astromkt_onBuyItemChange();
	}

	var buyPriceEl = document.querySelector('#astromktBuyForm input[name="price_ntx"]');
	if (buyPriceEl) {
		buyPriceEl.addEventListener('input', astromkt_recalcBuy);
		astromkt_recalcBuy();
	}

	if (document.getElementById('astromktChart')) {
		var ctx = document.getElementById('astromktChart').getContext('2d');
		new Chart(ctx, {
			type: 'line',
			data: {
				labels: {$chart_labels_json nofilter},
				datasets: [{
					label: 'Precio medio',
					data: {$chart_prices_json nofilter},
					borderColor: '#00e0ff',
					backgroundColor: 'rgba(0,224,255,0.15)',
					tension: 0.3,
					fill: true,
					pointBackgroundColor: '#00ccff',
					pointBorderColor: '#001a22',
					pointRadius: 4,
				}]
			},
			options: {
				responsive: true,
				maintainAspectRatio: false,
				plugins: { legend: { display: false } },
				scales: {
					y: {
						grid: { color: '#1e293b' },
						ticks: { color: '#94a3b8' }
					},
					x: {
						grid: { color: '#1e293b' },
						ticks: { color: '#94a3b8' }
					}
				}
			}
		});
	}
});
</script>
{/block}