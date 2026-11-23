{block name="title" prepend}{$LNG.lm_overview}{/block}
{block name="script" append}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════════════════════════
   ASTROIO v7.0 — VISTA PRINCIPAL "CENTRO DE MANDO" (mockup8_3/8_4)
   Layout aprobado: header Centro de mando, banner BOOST x3, tarjeta
   Planeta Principal con botones de acción, radar táctico de flotas,
   clima del planeta con chips de factores, próximos pasos (colas),
   eventos/PvE/PvP/rifas/lotería, y sidebar: Potenciadores, Tu
   comandante y Lotería. Todos los IDs/vars del overview v6.6 intactos
   (xb_banner, traveler_*, ov_pve_*, ov_pvp_*, ov_buff_timer, .timer).
   ═══════════════════════════════════════════════════════════════════ *}

<style>
/* ═══ CENTRO DE MANDO (mockup8_3) — prefijo cm_ ═══ */
:root {
    --cm-bg:      rgba(13, 20, 38, 0.92);
    --cm-bg2:     rgba(17, 26, 46, 0.85);
    --cm-border:  #22314f;
    --cm-cyan:    #38bdf8;
    --cm-cyan2:   #00e0ff;
    --cm-blue:    #3b82f6;
    --cm-purple:  #8b5cf6;
    --cm-gold:    #fbbf24;
    --cm-green:   #4aff88;
    --cm-red:     #ef4444;
    --cm-text:    #e2e8f0;
    --cm-muted:   #94a3b8;
}
.cm_shell { display:flex; gap:16px; align-items:flex-start; width:100%; box-sizing:border-box; padding:4px 2px 20px; min-width:0 }
.cm_shell > div, .cm_shell > aside { min-width:0 }
.cm_main  { flex:1 1 auto; min-width:0; display:flex; flex-direction:column; gap:14px }
.cm_side  { flex:0 0 300px; width:300px; min-width:0; display:flex; flex-direction:column; gap:14px }
.cm_card  { background:var(--cm-bg); border:1px solid var(--cm-border); border-radius:14px; padding:16px; box-shadow:0 8px 24px rgba(0,0,0,.35); box-sizing:border-box }

/* ═══ Cabecera ═══ */
.cm_head { display:flex; flex-direction:column; gap:2px; padding:2px 4px 8px }
.cm_head h1 { margin:0; color:#fff; font-size:26px; font-weight:900; letter-spacing:.4px; text-shadow:none }
.cm_head h1 b { color:var(--cm-cyan) }
.cm_head p { margin:0; color:var(--cm-muted); font-size:12.5px }

/* ═══ Banner BOOST x3 ═══ */
.cm_boost { display:flex; align-items:center; gap:14px; background:linear-gradient(90deg, rgba(139,92,246,.28), rgba(59,130,246,.18) 60%, rgba(13,20,38,.6)); border:1px solid rgba(139,92,246,.55); border-radius:14px; padding:14px 16px; position:relative; overflow:hidden }
.cm_boost > div { min-width:0; overflow-wrap:break-word }
.cm_boost:before { content:''; position:absolute; inset:0; background:radial-gradient(circle at 12% 50%, rgba(139,92,246,.35), transparent 45%); pointer-events:none }
.cm_boost .b_icon { flex:0 0 44px; width:44px; height:44px; border-radius:12px; background:rgba(139,92,246,.3); border:1px solid rgba(139,92,246,.6); display:flex; align-items:center; justify-content:center; font-size:22px }
.cm_boost .b_title { color:#fff; font-weight:900; font-size:14px; letter-spacing:.4px }
.cm_boost .b_title b { color:#c4b5fd }
.cm_boost .b_sub { color:var(--cm-muted); font-size:11px; margin-top:2px }
.cm_boost .b_grow { flex:1 }
.cm_boost .b_chip { background:rgba(251,191,36,.15); border:1px solid rgba(251,191,36,.55); color:var(--cm-gold); font-size:10px; font-weight:900; letter-spacing:1px; border-radius:999px; padding:5px 12px; white-space:nowrap }
.cm_boost .b_timerbox { background:rgba(2,6,12,.65); border:1px solid var(--cm-border); border-radius:10px; padding:7px 13px; color:#fff; font-weight:900; font-size:16px; font-family:'Courier New', monospace; letter-spacing:1px; white-space:nowrap }
.cm_boost .xb_close { position:absolute; top:8px; right:8px; background:rgba(2,6,12,.5); border:1px solid var(--cm-border); color:var(--cm-muted); border-radius:8px; width:24px; height:24px; font-size:11px; cursor:pointer; padding:0; line-height:1 }
.cm_boost .xb_close:hover { color:#fff; border-color:var(--cm-cyan) }
.cm_boost[data-phase="active"] { background:linear-gradient(90deg, rgba(74,255,136,.22), rgba(56,189,248,.14) 60%, rgba(13,20,38,.6)); border-color:rgba(74,255,136,.5) }

/* ═══ Planeta Principal ═══ */
.cm_planet .p_top { display:flex; align-items:center; gap:10px; flex-wrap:wrap }
.cm_planet .p_title { color:#fff; font-weight:900; font-size:17px; letter-spacing:1.2px }
.cm_planet .p_coords { display:inline-flex; align-items:center; gap:6px; background:rgba(56,189,248,.12); border:1px solid rgba(56,189,248,.45); color:var(--cm-cyan); font-size:11px; font-weight:800; border-radius:999px; padding:4px 11px; text-decoration:none }
.cm_planet .p_coords b { color:#fff }
.cm_planet .p_type { display:inline-flex; background:rgba(0,224,255,.08); border:1px solid rgba(0,224,255,.3); color:#67e8f9; font-size:10px; font-weight:800; border-radius:999px; padding:4px 10px; letter-spacing:.6px; text-transform:uppercase }
.cm_planet .p_grow { flex:1 }
.cm_planet .p_body { display:flex; gap:16px; margin-top:14px; align-items:stretch }
.cm_planet .p_img { flex:0 0 150px; width:150px; min-height:112px; border-radius:12px; border:1px solid var(--cm-border); background-color:#0a0f1c; background-size:cover; background-position:center; position:relative; overflow:hidden }
.cm_planet .p_img span { position:absolute; left:8px; bottom:8px; background:rgba(2,6,12,.75); color:#fff; font-size:9px; font-weight:800; letter-spacing:1px; border-radius:6px; padding:3px 8px; text-transform:uppercase }
.cm_stats { flex:1; display:grid; grid-template-columns:repeat(auto-fit, minmax(min(150px, 100%), 1fr)); gap:10px }
.cm_stat { background:var(--cm-bg2); border:1px solid var(--cm-border); border-radius:10px; padding:10px 12px; display:flex; align-items:center; gap:10px; transition:.2s ease }
.cm_stat:hover { border-color:rgba(56,189,248,.5) }
.cm_stat .ic { flex:0 0 30px; width:30px; height:30px; border-radius:9px; background:rgba(56,189,248,.12); display:flex; align-items:center; justify-content:center; font-size:14px; color:var(--cm-cyan) }
.cm_stat .lbl { color:var(--cm-muted); font-size:9.5px; text-transform:uppercase; letter-spacing:.8px }
.cm_stat .val { color:#fff; font-size:13px; font-weight:800; margin-top:1px }
.cm_stat .val a { color:#fff }
.cm_planet .p_actions { display:flex; gap:10px; margin-top:14px; flex-wrap:wrap }
.cm_btn_grad { flex:1; min-width:0; display:inline-flex; align-items:center; justify-content:center; gap:8px; background:linear-gradient(90deg,#3b82f6,#60a5fa); border:1px solid rgba(96,165,250,.7); color:#fff !important; border-radius:11px; padding:11px 16px; font-weight:800; font-size:12.5px; text-decoration:none !important; cursor:pointer; transition:.2s ease; text-transform:none; letter-spacing:.3px; box-shadow:0 6px 18px rgba(59,130,246,.35); font-family:inherit }
.cm_btn_grad:hover { box-shadow:0 8px 24px rgba(59,130,246,.5); transform:translateY(-1px); filter:brightness(1.06) }
.cm_btn_ghost { flex:0 0 auto; display:inline-flex; align-items:center; justify-content:center; gap:8px; background:rgba(56,189,248,.08); border:1px solid rgba(56,189,248,.45); color:var(--cm-cyan) !important; border-radius:11px; padding:11px 16px; font-weight:800; font-size:12.5px; text-decoration:none !important; transition:.2s ease; text-transform:none; letter-spacing:.3px; font-family:inherit }
.cm_btn_ghost:hover { background:rgba(56,189,248,.16); color:#fff !important }

/* ═══ Fila radar + clima ═══ */
.cm_row2 { display:grid; grid-template-columns:1.25fr 1fr; gap:14px; align-items:stretch }
.cm_sec_title { display:flex; align-items:center; gap:9px; margin-bottom:12px }
.cm_sec_title h2 { margin:0; color:#fff; font-size:14px; font-weight:900; letter-spacing:.4px }
.cm_sec_title .t_grow { flex:1 }
.cm_sec_title .t_btn { background:linear-gradient(90deg,#3b82f6,#60a5fa); color:#fff !important; border:none; border-radius:9px; padding:8px 14px; font-weight:800; font-size:11.5px; text-decoration:none !important; text-transform:none; letter-spacing:.3px; box-shadow:0 4px 14px rgba(59,130,246,.35); font-family:inherit; cursor:pointer }
.cm_sec_title .t_link { color:var(--cm-cyan); font-size:11px; font-weight:700; text-decoration:none; text-transform:none }

/* Radar táctico (reusa fleet-card del overview) */
.cm_fleetlist { display:flex; flex-direction:column; gap:12px }
.fleet-card { background:var(--cm-bg2); border:1px solid var(--cm-border); border-left:3px solid var(--cm-blue); border-radius:12px; padding:12px 14px; transition:.2s ease }
.fleet-card.is-attack    { border-left-color:var(--cm-red) }
.fleet-card.is-expedition{ border-left-color:var(--cm-green) }
.fleet-card.is-incoming  { border-left-color:var(--cm-red); background:rgba(239,68,68,.07) }
.fleet-card.is-transport { border-left-color:var(--cm-cyan) }
.fleet-card.is-espionage { border-left-color:var(--cm-purple) }
.fleet-card.is-deploy    { border-left-color:var(--cm-gold) }
.fleet-header { margin-bottom:8px }
.fleet-mission { color:#fff; font-size:12.5px; font-weight:800 }
.fleet-card.is-attack .fleet-mission { color:#fca5a5 }
.fleet-card.is-expedition .fleet-mission { color:#86efac }
.fleet-radar { position:relative; height:64px; margin:6px 0 4px }
.radar-line { position:absolute; left:4%; right:4%; top:50%; height:2px; background:linear-gradient(90deg, rgba(56,189,248,.15), rgba(56,189,248,.55), rgba(56,189,248,.15)); transform:translateY(-50%) }
.planet-node { position:absolute; top:50%; transform:translateY(-50%); display:flex; flex-direction:column; align-items:center; gap:1px; z-index:2 }
.planet-node.start-node { left:0 }
.planet-node.center-node { left:50%; transform:translate(-50%,-50%) }
.planet-node.end-node { right:0 }
.planet-node .planet-icon { font-size:15px; filter:drop-shadow(0 0 5px rgba(56,189,248,.6)) }
.planet-node .planet-name { color:var(--cm-muted); font-size:8.5px; letter-spacing:.5px; text-transform:uppercase }
.planet-node .planet-coords { color:#cbd5e1; font-size:9.5px; font-weight:700 }
.traveler-container { position:absolute; top:50%; left:3%; transform:translate(-50%,-50%); z-index:3; display:flex; flex-direction:column; align-items:center; gap:3px }
.traveler-ship { width:26px; height:26px; border-radius:50%; background:rgba(2,6,12,.85); border:1px solid rgba(56,189,248,.6); display:flex; align-items:center; justify-content:center; font-size:12px; box-shadow:0 0 10px rgba(56,189,248,.35) }
.traveler-timer { background:rgba(2,6,12,.85); border:1px solid rgba(56,189,248,.5); color:var(--cm-cyan); border-radius:7px; font-size:9.5px; font-weight:900; padding:2px 6px; font-family:'Courier New', monospace; white-space:nowrap }
.hud-tooltip { display:none; position:absolute; bottom:calc(100% + 6px); left:50%; transform:translateX(-50%); z-index:9; width:190px; background:rgba(10,14,22,.97); border:1px solid var(--cm-border); border-radius:10px; padding:9px 11px; box-shadow:0 10px 26px rgba(0,0,0,.55); text-align:left }
.traveler-container:hover .hud-tooltip { display:block }
.hud-tooltip .tooltip-title { color:var(--cm-cyan); font-size:10px; font-weight:900; letter-spacing:.6px; text-transform:uppercase; margin-bottom:5px }
.hud-tooltip .tooltip-section-title { color:var(--cm-muted); font-size:9px; font-weight:800; text-transform:uppercase; letter-spacing:.7px; margin:6px 0 3px }
.hud-tooltip .tooltip-row { display:flex; justify-content:space-between; gap:8px; color:var(--cm-text); font-size:10.5px; padding:1.5px 0 }
.fleet_ships { display:flex; flex-wrap:wrap; gap:6px; margin-top:8px }
.fleet_ships .ship-chip { background:rgba(56,189,248,.08); border:1px solid rgba(56,189,248,.3); color:#bae6fd; font-size:10px; font-weight:700; border-radius:7px; padding:3px 8px }
.cm_fleet_empty { text-align:center; color:var(--cm-muted); font-size:11.5px; padding:22px 10px; border:1px dashed var(--cm-border); border-radius:12px }

/* ═══ Clima ═══ */
.cm_clima { display:flex; flex-direction:column; gap:10px }
.cm_clima .cl_head { display:flex; align-items:center; gap:10px }
.cm_clima .cl_emoji { font-size:26px; filter:drop-shadow(0 0 6px rgba(56,189,248,.4)) }
.cm_clima .cl_name { color:#fff; font-weight:900; font-size:14px }
.cm_clima .cl_desc { color:var(--cm-muted); font-size:11px; font-style:italic; margin-top:1px }
.cm_clima .cl_factors { display:flex; flex-wrap:wrap; gap:7px; margin-top:11px }
.cm_clima .cl_factor { border-radius:8px; padding:5px 10px; font-size:10.5px; font-weight:800; border:1px solid }
.cm_clima .cl_factor.positive { background:rgba(74,255,136,.1); border-color:rgba(74,255,136,.4); color:var(--cm-green) }
.cm_clima .cl_factor.negative { background:rgba(239,68,68,.1); border-color:rgba(239,68,68,.4); color:#fca5a5 }
.cm_clima .cl_factor.neutral  { background:rgba(148,163,184,.08); border-color:rgba(148,163,184,.3); color:var(--cm-muted) }
.cm_clima .cl_predict { display:flex; align-items:center; gap:8px; background:rgba(56,189,248,.07); border:1px solid rgba(56,189,248,.28); border-radius:10px; padding:8px 11px; color:var(--cm-text); font-size:11.5px }
.cm_clima .cl_alert { border-radius:10px; padding:8px 11px; font-size:11px; font-weight:700; border:1px solid }
.cm_clima .cl_alert.danger  { background:rgba(239,68,68,.1); border-color:rgba(239,68,68,.4); color:#fecaca }
.cm_clima .cl_alert.success { background:rgba(74,255,136,.08); border-color:rgba(74,255,136,.35); color:#bbf7d0 }
.cm_clima .cl_luna { border-top:1px dashed var(--cm-border); padding-top:10px; display:flex; align-items:flex-start; gap:10px }
.cm_buff { display:flex; align-items:center; justify-content:space-between; gap:10px; background:rgba(74,255,136,.1); border:1px solid rgba(74,255,136,.4); border-radius:10px; padding:9px 12px }
.cm_buff .bf_name { color:var(--cm-green); font-weight:900; font-size:11.5px; text-transform:uppercase; letter-spacing:.5px }
.cm_buff .bf_desc { color:#fff; font-size:11px; margin-top:1px }
.cm_buff .bf_time { text-align:right }
.cm_buff .bf_lbl { color:var(--cm-muted); font-size:8.5px; text-transform:uppercase; letter-spacing:1px }
.cm_buff .bf_val { color:var(--cm-green); font-size:14px; font-weight:900; font-family:'Courier New', monospace }

/* ═══ Estado: online + admins + boleto ═══ */
.cm_status { display:flex; flex-wrap:wrap; gap:8px; align-items:center; padding:0 4px; margin-top:-6px }
.cm_status .st_chip { display:inline-flex; align-items:center; gap:6px; background:var(--cm-bg); border:1px solid var(--cm-border); border-radius:999px; padding:6px 12px; color:var(--cm-muted); font-size:11px; font-weight:700; text-decoration:none; text-transform:none; letter-spacing:0 }
.cm_status .st_chip i { font-style:normal }
.cm_status .st_chip b { color:#4aff88; font-weight:900 }
.cm_status .st_chip a { color:var(--cm-cyan); text-decoration:none; font-weight:800 }
.cm_status .st_ticket { border-color:rgba(56,189,248,.45); color:var(--cm-cyan) }
.cm_status .st_ticket:hover { background:rgba(56,189,248,.1); color:#fff }

/* ═══ Próximos pasos (colas de construcción) ═══ */
.cm_steps { display:grid; grid-template-columns:repeat(auto-fit, minmax(min(210px, 100%), 1fr)); gap:12px }
.cm_step { background:var(--cm-bg2); border:1px solid var(--cm-border); border-radius:12px; padding:13px 14px; display:flex; flex-direction:column; gap:7px; transition:.2s ease }
.cm_step:hover { border-color:rgba(56,189,248,.5) }
.cm_step .st_top { display:flex; align-items:center; gap:9px }
.cm_step .st_ic { flex:0 0 32px; width:32px; height:32px; border-radius:10px; background:rgba(56,189,248,.12); display:flex; align-items:center; justify-content:center; font-size:15px }
.cm_step .st_name { color:#fff; font-weight:800; font-size:12.5px }
.cm_step .st_status { color:var(--cm-muted); font-size:11px; line-height:1.5; min-height:30px }
.cm_step .st_status b { color:#fff }
.cm_step .st_status .timer { color:var(--cm-cyan); font-weight:900; font-family:'Courier New', monospace; font-size:11.5px }
.cm_step .st_btn { margin-top:auto; text-align:center; background:rgba(56,189,248,.1); border:1px solid rgba(56,189,248,.45); color:var(--cm-cyan) !important; border-radius:9px; padding:8px 10px; font-weight:800; font-size:11.5px; text-decoration:none !important; text-transform:none; transition:.2s ease; font-family:inherit }
.cm_step .st_btn:hover { background:rgba(56,189,248,.18); color:#fff !important }
.cm_step.busy { border-color:rgba(251,191,36,.45) }
.cm_step.busy .st_ic { background:rgba(251,191,36,.12) }

/* ═══ Eventos en curso (ov_ev) ═══ */
.ov_events_grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(min(230px, 100%), 1fr)); gap:12px }
.ov_ev_card { background:var(--cm-bg2); border:1px solid var(--cm-border); border-radius:12px; padding:12px 14px; text-decoration:none; transition:.2s ease; display:block }
.ov_ev_card:hover { border-color:rgba(56,189,248,.5); transform:translateY(-1px) }
.ov_ev_header { display:flex; align-items:center; gap:9px; margin-bottom:9px }
.ov_ev_icon { width:30px; height:30px; border-radius:9px; display:flex; align-items:center; justify-content:center; font-size:14px; border:1px solid }
.ov_ev_name { color:#fff; font-weight:800; font-size:12.5px }
.ov_ev_progress_bar { height:7px; border-radius:4px; background:rgba(2,6,12,.7); overflow:hidden; border:1px solid rgba(148,163,184,.15) }
.ov_ev_progress_fill { height:100%; background:linear-gradient(90deg,#3b82f6,#60a5fa); border-radius:4px; transition:width .3s ease }
.ov_ev_progress_fill.complete { background:linear-gradient(90deg,#22c55e,#4aff88) }
.ov_ev_footer { display:flex; justify-content:space-between; gap:8px; margin-top:8px; font-size:10.5px }
.ov_ev_progress { color:var(--cm-muted); font-weight:700 }
.ov_ev_reward { color:var(--cm-gold); font-weight:800 }

/* ═══ Widgets PvE / PvP / rifas / lotería (reusar lógica, piel nueva) ═══ */
.ov_pve_grid, .ov_pvp_grid, .ov_raffles_grid, .ov_lottery_grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(min(210px, 100%), 1fr)); gap:12px }
.ov_pve_card, .ov_pvp_card, .ov_raf_card, .ov_lot_card { background:var(--cm-bg2); border:1px solid var(--cm-border); border-radius:12px; padding:12px 14px; text-decoration:none; display:block; transition:.2s ease }
.ov_pve_card:hover, .ov_pvp_card:hover, .ov_raf_card:hover, .ov_lot_card:hover { border-color:rgba(56,189,248,.5); transform:translateY(-1px) }
.ov_pve_card.state-active, .ov_pvp_card.state-active { border-color:rgba(239,68,68,.55); background:rgba(239,68,68,.06) }
.ov_pve_header, .ov_pvp_header, .ov_raf_header, .ov_lot_header { display:flex; align-items:center; gap:8px; margin-bottom:7px }
.ov_pve_icon, .ov_pvp_icon, .ov_raf_icon, .ov_lot_icon { font-size:15px }
.ov_pve_name, .ov_pvp_name, .ov_raf_name, .ov_lot_name { color:#fff; font-weight:800; font-size:12px }
.ov_pve_status, .ov_pvp_status, .ov_raf_prize { color:var(--cm-text); font-size:11px; margin-bottom:7px }
.ov_pve_status.highlight, .ov_pvp_status.highlight { color:var(--cm-gold); font-weight:800 }
.ov_pve_footer, .ov_pvp_footer, .ov_raf_footer, .ov_lot_footer { display:flex; justify-content:space-between; gap:8px; font-size:10.5px }
.ov_pve_time, .ov_pvp_time { font-weight:800; color:var(--cm-cyan); font-family:'Courier New', monospace }
.ov_pve_time.off, .ov_pvp_time.off { color:var(--cm-muted) }
.ov_pve_time.warn, .ov_pvp_time.warn { color:var(--cm-gold) }
.ov_pve_time.danger, .ov_pvp_time.danger { color:#fca5a5 }
.ov_raf_time, .ov_lot_time { color:var(--cm-cyan); font-weight:800; font-family:'Courier New', monospace }
.ov_raf_time.warn, .ov_lot_time.warn { color:var(--cm-gold) }
.ov_raf_time.danger, .ov_lot_time.danger { color:#fca5a5 }
.ov_raf_price, .ov_lot_price, .ov_lot_jackpot { color:var(--cm-gold); font-weight:800 }
.ov_raf_progress_bar, .ov_lot_progress_bar { height:7px; border-radius:4px; background:rgba(2,6,12,.7); overflow:hidden; border:1px solid rgba(148,163,184,.15); margin-bottom:7px }
.ov_raf_progress_fill, .ov_lot_progress_fill { height:100%; background:linear-gradient(90deg,#f59e0b,#fbbf24); border-radius:4px }

/* ═══ Novedades ═══ */
.cm_news .xnova-card-body { color:var(--cm-text) }

/* ═══ Sidebar derecha ═══ */
.cm_side .sec_title { color:#fff; font-weight:900; font-size:13px; letter-spacing:.4px; margin-bottom:11px; display:flex; align-items:center; gap:8px }
.cm_side .sec_title .t_grow { flex:1 }
.cm_side .sec_title .t_link { color:var(--cm-cyan); font-size:10.5px; font-weight:700; text-decoration:none; text-transform:none }
.booster_card { display:flex; align-items:center; gap:10px; background:var(--cm-bg2); border:1px solid var(--cm-border); border-radius:11px; padding:9px 11px; margin-bottom:8px }
.booster_card.inactive { opacity:.55; filter:grayscale(.4) }
.booster_card .booster_icon { flex:0 0 30px; width:30px; height:30px; border-radius:9px; background:rgba(56,189,248,.1); display:flex; align-items:center; justify-content:center; font-size:14px }
.booster_card .booster_name { color:#fff; font-weight:800; font-size:11.5px }
.booster_card .booster_bonus { color:var(--cm-cyan); font-size:10px; font-weight:800 }
.booster_card .booster_state { margin-left:auto; text-align:right }
.booster_card .state_active { color:var(--cm-green); font-size:10px; font-weight:800; font-family:'Courier New', monospace }
.booster_card .state_inactive { color:var(--cm-muted); font-size:10px; font-weight:700 }
.cmd_card { display:flex; align-items:center; gap:12px }
.cmd_card .cmd_avatar { flex:0 0 46px; width:46px; height:46px; border-radius:50%; background:linear-gradient(135deg,#1d4ed8,#60a5fa); display:flex; align-items:center; justify-content:center; font-size:20px; box-shadow:0 0 14px rgba(59,130,246,.45) }
.cmd_card .cmd_name { color:#fff; font-weight:900; font-size:14px }
.cmd_card .cmd_rank { color:var(--cm-gold); font-size:9.5px; font-weight:900; letter-spacing:1px; text-transform:uppercase; margin-top:2px }
.cmd_stats { display:flex; gap:8px; margin-top:12px }
.cmd_stats .cs { flex:1; background:var(--cm-bg2); border:1px solid var(--cm-border); border-radius:10px; padding:8px 6px; text-align:center }
.cmd_stats .cs b { display:block; color:#fff; font-size:13px }
.cmd_stats .cs span { color:var(--cm-muted); font-size:8.5px; text-transform:uppercase; letter-spacing:.7px }

/* ═══ Responsive ═══ */
@media (max-width:1250px) {
  .cm_shell { flex-direction:column; align-items:stretch }
  .cm_main { width:100% }
  .cm_side { width:100%; flex:1 1 auto }
  .cm_row2 { grid-template-columns:1fr }
}
@media (max-width:760px) {
  .cm_shell { padding:2px 0 14px; gap:12px }
  .cm_card { padding:12px; border-radius:12px }
  .cm_head h1 { font-size:21px }
  .cm_planet .p_body { flex-direction:column }
  .cm_planet .p_img { width:100%; flex:1 1 auto; min-height:130px }
  .cm_boost { flex-direction:column; align-items:stretch; gap:9px; padding:12px }
  .cm_boost .b_grow { display:none }
  .cm_boost .b_title, .cm_boost .b_sub { white-space:normal !important }
  .cm_boost .b_timerbox { width:100%; text-align:center; font-size:12px; padding:5px 6px; box-sizing:border-box; letter-spacing:.5px }
  .cm_boost .b_chip { align-self:flex-start }
  .cm_boost .b_title { font-size:12.5px }
  .planet-node.center-node { display:none }
  .planet-node.end-node { display:none }
  .cm_btn_grad { min-width:0 }
  .booster_card .state_active, .booster_card .state_inactive { white-space:normal }
  .cm_step, .cm_stat, .cm_card, .fleet-card { overflow-wrap:anywhere }
  .cm_planet .p_actions { flex-direction:column }
  .cmd_card { flex-direction:row }
}
</style>

{* ═══════════════════════ CONTENIDO: CENTRO DE MANDO ═══════════════════════ *}

<div class="cm_shell">
	<div class="cm_main">

		{* ─── Cabecera ─── *}
		<div class="cm_head">
			<h1>Centro de <b>mando</b></h1>
			<p>Tus objetivos y la actividad de tu imperio.</p>
		</div>

		{* ─── Estado: jugadores en línea, administradores y soporte (v6.6 intacto) ─── *}
		<div class="cm_status">
			<span class="st_chip"><i>&#128100;</i> {$LNG.ov_online_user}: <b>{$onlineUser + $AdminsOnline|@count|number}</b></span>
			<span class="st_chip"><i>&#128101;</i> {$LNG.ov_admins_online}: {foreach $AdminsOnline as $ID => $Name}{if !$Name@first}&nbsp;&bull;&nbsp;{/if}<a href="#" onclick="return Dialog.PM({$ID})">{$Name}</a>{foreachelse}{$LNG.ov_no_admins_online}{/foreach}</span>
			<a href="game.php?page=ticket" class="st_chip st_ticket"><i>&#127915;</i> {$LNG.ov_ticket}</a>
		</div>

		{* ═══════════ BANNER BOOST FIN DE SEMANA (mockup8_3) ═══════════ *}
		{if isset($weekend_boost) && $weekend_boost.show == 1}
		<div class="cm_boost"
		     id="xb_banner"
		     data-phase="{$weekend_boost.phase}"
		     data-seconds="{$weekend_boost.seconds_left}"
		     data-multiplier="{$weekend_boost.multiplier}">
			<div class="b_icon">🎉</div>
			<div>
				<div class="b_title">
					{if $weekend_boost.phase == 'active'}
						BOOST ACTIVO <b>&times;{$weekend_boost.multiplier}</b>
					{else}
						BOOST FIN DE SEMANA <b>&times;{$weekend_boost.multiplier}</b>
					{/if}
				</div>
				<div class="b_sub">Se notifica cuando empieza y mientras avanza &middot; comunidad el s&aacute;bado a las 20:00</div>
			</div>
			<div class="b_grow"></div>
			{if $weekend_boost.phase != 'active'}<span class="b_chip">PR&Oacute;XIMAMENTE</span>{else}<span class="b_chip" style="background:rgba(74,255,136,.12); border-color:rgba(74,255,136,.5); color:#4aff88">ACTIVO</span>{/if}
			<span class="b_timerbox" id="xb_timer">--</span>
			<button type="button" class="xb_close" onclick="xbDismiss(); return false;" title="Cerrar">&#10006;</button>
		</div>
		{/if}

		{* ═══════════ TARJETA PLANETA PRINCIPAL ═══════════ *}
		<div class="cm_card cm_planet">
			<div class="p_top">
				<span class="p_title">PLANETA PRINCIPAL</span>
				<span class="p_type">{$LNG["type_planet_{$planet_type}"]}</span>
				<a href="game.php?page=galaxy&amp;galaxy={$galaxy}&amp;system={$system}" class="p_coords">&#128205; <b>[{$galaxy}:{$system}:{$planet}]</b></a>
				<div class="p_grow"></div>
			</div>
			<div class="p_body">
				<div class="p_img" style="background-image: url({$dpath}planeten/{$planetimage}.jpg);"><span>PLANETA</span></div>
				<div class="cm_stats">
					<div class="cm_stat">
						<div class="ic">&#128207;</div>
						<div class="info"><div class="lbl">{$LNG.ov_diameter}</div><div class="val">{$planet_diameter} {$LNG.ov_distance_unit}</div></div>
					</div>
					<div class="cm_stat">
						<div class="ic">&#9641;</div>
						<div class="info"><div class="lbl">Campos</div><div class="val">{$planet_field_current} / {$planet_field_max}</div></div>
					</div>
					<div class="cm_stat">
						<div class="ic">&#127777;</div>
						<div class="info"><div class="lbl">{$LNG.ov_temperature}</div><div class="val">{$planet_temp_min}&deg;C ~ {$planet_temp_max}&deg;C</div></div>
					</div>
					<div class="cm_stat">
						<div class="ic">&#128205;</div>
						<div class="info"><div class="lbl">{$LNG.ov_position}</div><div class="val"><a href="game.php?page=galaxy&amp;galaxy={$galaxy}&amp;system={$system}">[{$galaxy}:{$system}:{$planet}]</a></div></div>
					</div>
				</div>
			</div>
			<div class="p_actions">
				<a href="#" onclick="return Dialog.PlanetAction();" class="cm_btn_grad">&#128293; Renombra planeta</a>
				<a href="game.php?page=galaxy&amp;galaxy={$galaxy}&amp;system={$system}" class="cm_btn_ghost">&#128640; Ver galaxia</a>
			</div>
		</div>

		{* ═══════════ FILA: RADAR TÁCTICO + CLIMA ═══════════ *}
		<div class="cm_row2">
			<div class="cm_card xnova-fleet-card">
				<div class="cm_sec_title">
					<h2>&#128640; Flotas activas &mdash; radar t&aacute;ctico</h2>
					<div class="t_grow"></div>
					<a href="game.php?page=fleet" class="t_btn">Enviar flota &rsaquo;</a>
				</div>
				{if $fleets}
				<div class="cm_fleetlist">
					{foreach $fleets as $index => $fleet}

						{* Lógica de Misión, Iconos, Colores y Fase (v6.6 intacta) *}
						{assign var="fleetClass" value="is-transport"}
						{assign var="shipIcon"   value="&#128640;"}
						{assign var="destIcon"   value="&#129691;"}
						{assign var="fase"       value="IDA"}

						{if $fleet.is_incoming}
							{assign var="fleetClass" value="is-incoming"}
						{/if}

						{if $fleet.mission == 1 || $fleet.mission == 2 || ($fleet.mission >= 20 && $fleet.mission <= 23)}
							{assign var="fleetClass" value="is-attack"}
							{assign var="shipIcon"   value="&#9876;&#65039;"}
						{elseif $fleet.mission == 15}
							{assign var="fleetClass" value="is-expedition"}
							{assign var="shipIcon"   value="&#128640;"}
							{assign var="destIcon"   value="&#127756;"}
						{elseif $fleet.mission == 8}
							{assign var="fleetClass" value="is-transport"}
							{assign var="destIcon"   value="&#9851;&#65039;"}
						{elseif $fleet.mission == 6}
							{assign var="fleetClass" value="is-espionage"}
							{assign var="shipIcon"   value="&#128379;&#65039;"}
						{elseif $fleet.mission == 4}
							{assign var="fleetClass" value="is-deploy"}
							{assign var="shipIcon"   value="&#128737;&#65039;"}
						{/if}

						{if $fleet.state == 1}
							{assign var="fase"     value="VUELTA"}
							{assign var="shipIcon" value="&#128640;"}
						{/if}

						{assign var="startIcon" value="&#129691;"}
						{if isset($fleet.start_type) && $fleet.start_type == 3}{assign var="startIcon" value="&#127761;"}{/if}
						{if isset($fleet.end_type) && $fleet.end_type == 3}
							{assign var="destIcon" value="&#127761;"}
						{elseif isset($fleet.end_type) && $fleet.end_type == 2}
							{assign var="destIcon" value="&#9732;&#65039;"}
						{/if}

						<div class="fleet-card {$fleetClass}">
							<div class="fleet-header">
								<div class="fleet-mission">{$shipIcon} {$fleet.mission_label} ({$fase})</div>
							</div>
							<div class="fleet-radar">
								<div class="radar-line"></div>
								<div class="planet-node start-node">
									<span class="planet-icon">{$startIcon}</span>
									<span class="planet-name">Origen</span>
									<span class="planet-coords">[{$fleet.startGalaxy}:{$fleet.startSystem}:{$fleet.startPlanet}]</span>
								</div>
								<div class="planet-node center-node">
									<span class="planet-icon">{$destIcon}</span>
									<span class="planet-name">Destino</span>
									<span class="planet-coords">[{$fleet.endGalaxy}:{$fleet.endSystem}:{$fleet.endPlanet}]</span>
								</div>
								<div class="planet-node end-node">
									<span class="planet-icon">{$startIcon}</span>
									<span class="planet-name">Retorno</span>
									<span class="planet-coords">[{$fleet.startGalaxy}:{$fleet.startSystem}:{$fleet.startPlanet}]</span>
								</div>
								<div class="traveler-container" id="traveler_{$index}"
								     data-fleet-id="{$fleet.id}"
								     data-fleet-total-time="{$fleet.resttime}"
								     data-fleet-state="{$fleet.state|default:0}">
									<div class="traveler-ship">{$shipIcon}</div>
									<div class="traveler-timer" id="timer_{$index}">
										{pretty_fly_time({$fleet.resttime})}
									</div>
									<div class="hud-tooltip">
										<div class="tooltip-title">Informaci&oacute;n de Flota</div>
										{if isset($fleet.ships_array) && $fleet.ships_array|@count > 0}
											{foreach $fleet.ships_array as $shipId => $count}
												{if $count > 0}
													<div class="tooltip-row"><span>{$LNG.tech[$shipId]}:</span><span>{$count|number}</span></div>
												{/if}
											{/foreach}
										{else}
											<div class="tooltip-row"><span>Total Naves:</span><span>{$fleet.amount|number}</span></div>
										{/if}
										{if isset($fleet.fleet_resource_metal) && ($fleet.fleet_resource_metal > 0 || $fleet.fleet_resource_crystal > 0 || $fleet.fleet_resource_deuterium > 0)}
											<div class="tooltip-section-title">Recursos</div>
											{if $fleet.fleet_resource_metal > 0}<div class="tooltip-row"><span>Metal:</span><span style="color:var(--cm-cyan)">{$fleet.fleet_resource_metal|number}</span></div>{/if}
											{if $fleet.fleet_resource_crystal > 0}<div class="tooltip-row"><span>Cristal:</span><span style="color:var(--cm-cyan)">{$fleet.fleet_resource_crystal|number}</span></div>{/if}
											{if $fleet.fleet_resource_deuterium > 0}<div class="tooltip-row"><span>Deuterio:</span><span style="color:var(--cm-cyan)">{$fleet.fleet_resource_deuterium|number}</span></div>{/if}
										{/if}
									</div>
								</div>
							</div>
							{if isset($fleet.ships_array) && $fleet.ships_array|@count > 0}
							<div class="fleet_ships">
								{foreach $fleet.ships_array as $shipId => $count}
									{if $count > 0}<span class="ship-chip">{$LNG.tech[$shipId]} x{$count|number}</span>{/if}
								{/foreach}
							</div>
							{/if}
						</div>
					{/foreach}
				</div>
				{else}
					<div class="cm_fleet_empty">[ SIN FLOTAS ACTIVAS ]</div>
				{/if}
			</div>

			<div class="cm_card cm_clima">
				{if isset($clima_planeta) && $clima_planeta}
				<div class="cm_sec_title"><h2>&#127777;&#65039; Clima del planeta</h2></div>

				{* ─── Clima actual del planeta (lógica v6.6 intacta) ─── *}
				{assign var="cp_emoji" value="&#10067;"}
				{if $clima_planeta.clave == 'despejado'}{assign var="cp_emoji" value="&#9728;&#65039;"}
				{elseif $clima_planeta.clave == 'brisa_solar'}{assign var="cp_emoji" value="&#127780;&#65039;"}
				{elseif $clima_planeta.clave == 'viento_estelar'}{assign var="cp_emoji" value="&#127787;&#65039;"}
				{elseif $clima_planeta.clave == 'cristalino'}{assign var="cp_emoji" value="&#10024;"}
				{elseif $clima_planeta.clave == 'niebla'}{assign var="cp_emoji" value="&#127787;&#65039;"}
				{elseif $clima_planeta.clave == 'tormenta_solar'}{assign var="cp_emoji" value="&#9889;"}
				{elseif $clima_planeta.clave == 'meteoros'}{assign var="cp_emoji" value="&#9788;&#65039;"}
				{elseif $clima_planeta.clave == 'nebulosa'}{assign var="cp_emoji" value="&#128176;"}
				{elseif $clima_planeta.clave == 'plasma'}{assign var="cp_emoji" value="&#127756;"}
				{elseif $clima_planeta.clave == 'eclipse'}{assign var="cp_emoji" value="&#127765;"}
				{elseif $clima_planeta.clave == 'campo_mag'}{assign var="cp_emoji" value="&#127744;"}
				{elseif $clima_planeta.clave == 'aurora'}{assign var="cp_emoji" value="&#127752;"}
				{elseif $clima_planeta.clave == 'agujero'}{assign var="cp_emoji" value="&#128371;&#65039;"}
				{elseif $clima_planeta.clave == 'singularidad'}{assign var="cp_emoji" value="&#9878;&#65039;"}
				{/if}
				<div class="cl_head">
					<div class="cl_emoji">{$cp_emoji}</div>
					<div>
						<div class="cl_name">{$clima_planeta.nombre}</div>
						<div class="cl_desc">&quot;{$clima_planeta.descripcion}&quot;</div>
					</div>
				</div>
				<div class="cl_factors">
					<span class="cl_factor {if $clima_planeta.factor_ataque > 1}positive{elseif $clima_planeta.factor_ataque < 1}negative{else}neutral{/if}">
						&#9876;&#65039; {if $clima_planeta.factor_ataque > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_ataque format="%d"}% ataque
					</span>
					<span class="cl_factor {if $clima_planeta.factor_defensa > 1}positive{elseif $clima_planeta.factor_defensa < 1}negative{else}neutral{/if}">
						&#128737;&#65039; {if $clima_planeta.factor_defensa > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_defensa format="%d"}% defensa
					</span>
					<span class="cl_factor {if $clima_planeta.factor_bajas > 1}negative{elseif $clima_planeta.factor_bajas < 1}positive{else}neutral{/if}">
						&#128128; {if $clima_planeta.factor_bajas > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_bajas format="%d"}% bajas
					</span>
					<span class="cl_factor {if $clima_planeta.factor_botin > 1}positive{elseif $clima_planeta.factor_botin < 1}negative{else}neutral{/if}">
						&#128176; {if $clima_planeta.factor_botin > 1}+{/if}{math equation="round((x-1)*100)" x=$clima_planeta.factor_botin format="%d"}% bot&iacute;n
					</span>
				</div>

				{* ─── Predicción para mañana ─── *}
				{if isset($clima_planeta_previsto) && $clima_planeta_previsto}
				{assign var="cpp_emoji" value="&#10067;"}
				{if $clima_planeta_previsto.clave == 'despejado'}{assign var="cpp_emoji" value="&#9728;&#65039;"}
				{elseif $clima_planeta_previsto.clave == 'brisa_solar'}{assign var="cpp_emoji" value="&#127780;&#65039;"}
				{elseif $clima_planeta_previsto.clave == 'viento_estelar'}{assign var="cpp_emoji" value="&#127787;&#65039;"}
				{elseif $clima_planeta_previsto.clave == 'cristalino'}{assign var="cpp_emoji" value="&#10024;"}
				{elseif $clima_planeta_previsto.clave == 'niebla'}{assign var="cpp_emoji" value="&#127787;&#65039;"}
				{elseif $clima_planeta_previsto.clave == 'tormenta_solar'}{assign var="cpp_emoji" value="&#9889;"}
				{elseif $clima_planeta_previsto.clave == 'meteoros'}{assign var="cpp_emoji" value="&#9788;&#65039;"}
				{elseif $clima_planeta_previsto.clave == 'nebulosa'}{assign var="cpp_emoji" value="&#128176;"}
				{elseif $clima_planeta_previsto.clave == 'plasma'}{assign var="cpp_emoji" value="&#127756;"}
				{elseif $clima_planeta_previsto.clave == 'eclipse'}{assign var="cpp_emoji" value="&#127765;"}
				{elseif $clima_planeta_previsto.clave == 'campo_mag'}{assign var="cpp_emoji" value="&#127744;"}
				{elseif $clima_planeta_previsto.clave == 'aurora'}{assign var="cpp_emoji" value="&#127752;"}
				{elseif $clima_planeta_previsto.clave == 'agujero'}{assign var="cpp_emoji" value="&#128371;&#65039;"}
				{elseif $clima_planeta_previsto.clave == 'singularidad'}{assign var="cpp_emoji" value="&#9878;&#65039;"}
				{/if}
				<div class="cl_predict"><span>{$cpp_emoji}</span><span><b>&#128302; Ma&ntilde;ana:</b> {$clima_planeta_previsto.nombre}</span></div>
				{/if}

				{* ─── Aviso según el clima ─── *}
				{if $clima_planeta.factor_defensa < 1}
				<div class="cl_alert danger">&#9888;&#65039; Tu defensa est&aacute; debilitada hoy. Refuerza o haz fleetsave.</div>
				{elseif $clima_planeta.factor_defensa > 1}
				<div class="cl_alert success">&#9989; Tu defensa est&aacute; reforzada hoy. Buen d&iacute;a para resistir ataques.</div>
				{/if}

				{* ─── Clima de la Luna (si existe) ─── *}
				{if isset($clima_luna) && $clima_luna}
				<div class="cl_luna">
					{assign var="cl_emoji" value="&#10067;"}
					{if $clima_luna.clave == 'despejado'}{assign var="cl_emoji" value="&#9728;&#65039;"}
					{elseif $clima_luna.clave == 'brisa_solar'}{assign var="cl_emoji" value="&#127780;&#65039;"}
					{elseif $clima_luna.clave == 'viento_estelar'}{assign var="cl_emoji" value="&#127787;&#65039;"}
					{elseif $clima_luna.clave == 'cristalino'}{assign var="cl_emoji" value="&#10024;"}
					{elseif $clima_luna.clave == 'niebla'}{assign var="cl_emoji" value="&#127787;&#65039;"}
					{elseif $clima_luna.clave == 'tormenta_solar'}{assign var="cl_emoji" value="&#9889;"}
					{elseif $clima_luna.clave == 'meteoros'}{assign var="cl_emoji" value="&#9788;&#65039;"}
					{elseif $clima_luna.clave == 'nebulosa'}{assign var="cl_emoji" value="&#128176;"}
					{elseif $clima_luna.clave == 'plasma'}{assign var="cl_emoji" value="&#127756;"}
					{elseif $clima_luna.clave == 'eclipse'}{assign var="cl_emoji" value="&#127765;"}
					{elseif $clima_luna.clave == 'campo_mag'}{assign var="cl_emoji" value="&#127744;"}
					{elseif $clima_luna.clave == 'aurora'}{assign var="cl_emoji" value="&#127752;"}
					{elseif $clima_luna.clave == 'agujero'}{assign var="cl_emoji" value="&#128371;&#65039;"}
					{elseif $clima_luna.clave == 'singularidad'}{assign var="cl_emoji" value="&#9878;&#65039;"}
					{/if}
					<div class="cl_emoji" style="font-size:22px">{$cl_emoji}</div>
					<div>
						<div class="cl_name">&#127765; Luna: {$clima_luna.nombre}</div>
						<div class="cl_desc">&quot;{$clima_luna.descripcion}&quot;</div>
						{if isset($clima_luna_previsto) && $clima_luna_previsto}
							{assign var="clp_emoji" value="&#10067;"}
							{if $clima_luna_previsto.clave == 'despejado'}{assign var="clp_emoji" value="&#9728;&#65039;"}
							{elseif $clima_luna_previsto.clave == 'brisa_solar'}{assign var="clp_emoji" value="&#127780;&#65039;"}
							{elseif $clima_luna_previsto.clave == 'viento_estelar'}{assign var="clp_emoji" value="&#127787;&#65039;"}
							{elseif $clima_luna_previsto.clave == 'cristalino'}{assign var="clp_emoji" value="&#10024;"}
							{elseif $clima_luna_previsto.clave == 'niebla'}{assign var="clp_emoji" value="&#127787;&#65039;"}
							{elseif $clima_luna_previsto.clave == 'tormenta_solar'}{assign var="clp_emoji" value="&#9889;"}
							{elseif $clima_luna_previsto.clave == 'meteoros'}{assign var="clp_emoji" value="&#9788;&#65039;"}
							{elseif $clima_luna_previsto.clave == 'nebulosa'}{assign var="clp_emoji" value="&#128176;"}
							{elseif $clima_luna_previsto.clave == 'plasma'}{assign var="clp_emoji" value="&#127756;"}
							{elseif $clima_luna_previsto.clave == 'eclipse'}{assign var="clp_emoji" value="&#127765;"}
							{elseif $clima_luna_previsto.clave == 'campo_mag'}{assign var="clp_emoji" value="&#127744;"}
							{elseif $clima_luna_previsto.clave == 'aurora'}{assign var="clp_emoji" value="&#127752;"}
							{elseif $clima_luna_previsto.clave == 'agujero'}{assign var="clp_emoji" value="&#128371;&#65039;"}
							{elseif $clima_luna_previsto.clave == 'singularidad'}{assign var="clp_emoji" value="&#9878;&#65039;"}
							{/if}
							<div class="cl_predict" style="margin-top:6px"><span>{$clp_emoji}</span><span><b>&#128302; Ma&ntilde;ana:</b> {$clima_luna_previsto.nombre}</span></div>
						{/if}
					</div>
				</div>
				{/if}

				{* ─── Buff climático activo (v6.6 intacto) ─── *}
				{if isset($buff_activo) && $buff_activo}
				<div class="cm_buff">
					<div>
						<div class="bf_name">&#9889; Buff clim&aacute;tico activo</div>
						<div class="bf_desc">{$buff_nombre_legible}</div>
					</div>
					<div class="bf_time">
						<div class="bf_lbl">Tiempo restante</div>
						<div id="ov_buff_timer" class="bf_val" data-expires="{$buff_activo.expires_at}">
							{$buff_horas_restantes}h {$buff_minutos_restantes}m
						</div>
					</div>
				</div>
				{/if}
				{else}
				<div class="cm_fleet_empty">Sin datos de clima para este planeta</div>
				{/if}
			</div>
		</div>

		{* ═══════════ PRÓXIMOS PASOS (COLAS DE CONSTRUCCIÓN) ═══════════ *}
		<div class="cm_sec_title" style="margin:6px 2px 0"><h2>&#127919; Pr&oacute;ximos pasos</h2></div>
		<div class="cm_steps">
			<div class="cm_step {if $buildInfo.buildings}busy{/if}">
				<div class="st_top"><div class="st_ic">&#127960;&#65039;</div><div class="st_name">{$LNG.ov_list_title_build}</div></div>
				<div class="st_status">
					{if $buildInfo.buildings}
						{$LNG.tech[$buildInfo.buildings['id']]} <b>({$buildInfo.buildings['level']})</b><br>
						<span class="timer" data-time="{$buildInfo.buildings['timeleft']}">{$buildInfo.buildings['starttime']}</span>
					{else}
						Tu cola de construcci&oacute;n est&aacute; vac&iacute;a. Cada minuto parado es producci&oacute;n perdida.
					{/if}
				</div>
				<a href="game.php?page=buildings" class="st_btn">{if $buildInfo.buildings}Ver construcci&oacute;n &rsaquo;{else}Construir &rsaquo;{/if}</a>
			</div>
			<div class="cm_step {if $buildInfo.tech}busy{/if}">
				<div class="st_top"><div class="st_ic">&#128300;</div><div class="st_name">Investigaciones</div></div>
				<div class="st_status">
					{if $buildInfo.tech}
						{$LNG.tech[$buildInfo.tech['id']]} <b>({$buildInfo.tech['level']})</b><br>
						<span class="timer" data-time="{$buildInfo.tech['timeleft']}">{$buildInfo.tech['starttime']}</span>
					{else}
						Sin investigaci&oacute;n activa. La tecnolog&iacute;a desbloquea naves, defensas y m&aacute;s producci&oacute;n.
					{/if}
				</div>
				<a href="game.php?page=research" class="st_btn">{if $buildInfo.tech}Ver laboratorio &rsaquo;{else}Investigar &rsaquo;{/if}</a>
			</div>
			<div class="cm_step {if $buildInfo.fleet}busy{/if}">
				<div class="st_top"><div class="st_ic">&#128640;</div><div class="st_name">Hangar</div></div>
				<div class="st_status">
					{if $buildInfo.fleet}
						{$LNG.tech[$buildInfo.fleet['id']]} <b>({$buildInfo.fleet['level']})</b><br>
						<span class="timer" data-time="{$buildInfo.fleet['timeleft']}">{$buildInfo.fleet['starttime']}</span>
					{else}
						Tu hangar no est&aacute; produciendo naves. Ampl&iacute;a tu flota para no quedarte atr&aacute;s.
					{/if}
				</div>
				<a href="game.php?page=shipyard" class="st_btn">{if $buildInfo.fleet}Ver hangar &rsaquo;{else}Construir naves &rsaquo;{/if}</a>
			</div>
			<div class="cm_step {if $buildInfo.defense}busy{/if}">
				<div class="st_top"><div class="st_ic">&#128737;&#65039;</div><div class="st_name">Defensa</div></div>
				<div class="st_status">
					{if $buildInfo.defense}
						{$LNG.tech[$buildInfo.defense['id']]} <b>({$buildInfo.defense['level']})</b><br>
						<span class="timer" data-time="{$buildInfo.defense['timeleft']}">{$buildInfo.defense['starttime']}</span>
					{else}
						Sin defensas en producci&oacute;n. Un planeta sin torretas es un bot&iacute;n f&aacute;cil.
					{/if}
				</div>
				<a href="game.php?page=shipyard&amp;mode=defense" class="st_btn">{if $buildInfo.defense}Ver defensas &rsaquo;{else}Construir defensas &rsaquo;{/if}</a>
			</div>
		</div>

		{* ═══════════ EVENTOS EN CURSO (mockup8_3) ═══════════ *}
		{if $ovEvents && ($ovEvents.daily || $ovEvents.weekly || $ovEvents.elite)}
		<div class="cm_sec_title" style="margin:6px 2px 0">
			<h2>&#127881; Eventos en curso</h2><div class="t_grow"></div>
			<a href="game.php?page=events" class="t_link">Ver todos &rsaquo;</a>
		</div>
		<div class="ov_events_grid">
			{foreach $ovEvents as $ev}
				{if $ev}
				<a href="game.php?page=events" class="ov_ev_card ov_ev_{$ev.event_class}">
					<div class="ov_ev_header">
						<span class="ov_ev_icon" style="background: {$ev.event_color}22; color: {$ev.event_color}; border-color: {$ev.event_color};">{$ev.icon_emoji}</span>
						<span class="ov_ev_name">{$ev.event_name}</span>
					</div>
					<div class="ov_ev_progress_bar">
						<div class="ov_ev_progress_fill{if $ev.is_complete} complete{/if}" style="width:{$ev.progress_pct}%;"></div>
					</div>
					<div class="ov_ev_footer">
						<span class="ov_ev_progress">{$ev.progress_fmt} / {$ev.target_fmt}</span>
						<span class="ov_ev_reward">{$ev.reward_text}</span>
					</div>
				</a>
				{/if}
			{/foreach}
		</div>
		{/if}

		{* ═══════════ WIDGET PvE (v6.6 intacto) ═══════════ *}
		{if isset($pve_widget) && $pve_widget.enabled && $pve_widget.show_widget}
		<div class="cm_sec_title" style="margin:6px 2px 0">
			<h2>&#9876;&#65039; Eventos PvE</h2><div class="t_grow"></div>
			<a href="game.php?page=pve" class="t_link">Ver todos &rsaquo;</a>
		</div>
		<div class="ov_pve_grid">
			{if $pve_widget.crisis_active || $pve_widget.crisis_time > 0}
			<a href="game.php?page=pve" class="ov_pve_card ov_pve_crisis" id="ov_pve_crisis_card" data-active="{$pve_widget.crisis_active|default:0}" data-time="{$pve_widget.crisis_time|default:0}" data-end="{$pve_widget.crisis_end|default:0}">
				<div class="ov_pve_header"><span class="ov_pve_icon">&#127756;</span><span class="ov_pve_name">Crisis de Fin de Mes</span></div>
				<div class="ov_pve_status" data-role="status">Cargando&hellip;</div>
				<div class="ov_pve_footer"><span class="ov_pve_time off" data-role="time">--</span></div>
			</a>
			{/if}
			{if $pve_widget.boss_active || $pve_widget.boss_time > 0}
			<a href="game.php?page=pve&mode=boss" class="ov_pve_card ov_pve_boss {if $pve_widget.boss_active}state-active{/if}" id="ov_pve_boss_card" data-active="{$pve_widget.boss_active|default:0}" data-status="{$pve_widget.boss_status|default:''}" data-time="{$pve_widget.boss_time|default:0}" data-end="{$pve_widget.boss_end|default:0}" data-ghosts="{$pve_widget.boss_ghosts|default:0}">
				<div class="ov_pve_header"><span class="ov_pve_icon">&#127760;&#65039;</span><span class="ov_pve_name">Torneo del Devorador</span></div>
				<div class="ov_pve_status" data-role="status">Cargando&hellip;</div>
				<div class="ov_pve_footer"><span class="ov_pve_time off" data-role="time">--</span></div>
			</a>
			{/if}
			{if $pve_widget.empire_active || $pve_widget.empire_time > 0}
			<a href="game.php?page=pve&mode=empire" class="ov_pve_card ov_pve_empire" id="ov_pve_empire_card" data-active="{$pve_widget.empire_active|default:0}" data-time="{$pve_widget.empire_time|default:0}" data-end="{$pve_widget.empire_end|default:0}" data-count="{$pve_widget.empire_count|default:0}">
				<div class="ov_pve_header"><span class="ov_pve_icon">&#127963;&#65039;</span><span class="ov_pve_name">Imperio Ca&iacute;do</span></div>
				<div class="ov_pve_status" data-role="status">Cargando&hellip;</div>
				<div class="ov_pve_footer"><span class="ov_pve_time off" data-role="time">--</span></div>
			</a>
			{/if}
			{if $pve_widget.pending_rewards > 0}
			<a href="game.php?page=pve" class="ov_pve_card ov_pve_rewards">
				<div class="ov_pve_header"><span class="ov_pve_icon">&#127873;</span><span class="ov_pve_name">Recompensas PvE</span></div>
				<div class="ov_pve_status highlight">{$pve_widget.pending_rewards} pendiente(s)</div>
				<div class="ov_pve_footer"><span class="ov_pve_time">Reclamar &rarr;</span></div>
			</a>
			{/if}
		</div>
		{/if}

		{* ═══════════ WIDGET PvP (v6.6 intacto) ═══════════ *}
		{if isset($pvp_widget) && $pvp_widget.enabled && $pvp_widget.show_widget}
		<div class="cm_sec_title" style="margin:6px 2px 0">
			<h2>&#9876;&#65039; Sistema PvP</h2><div class="t_grow"></div>
			<a href="game.php?page=pvp" class="t_link">Ver todo &rsaquo;</a>
		</div>
		<div class="ov_pvp_grid">
			{if $pvp_widget.arenas_waiting > 0}
			<a href="game.php?page=pvp&mode=arenas" class="ov_pvp_card ov_pvp_arenas">
				<div class="ov_pvp_header"><span class="ov_pvp_icon">&#127970;&#65039;</span><span class="ov_pvp_name">Arenas abiertas</span></div>
				<div class="ov_pvp_status highlight">{$pvp_widget.arenas_waiting} esperando</div>
				<div class="ov_pvp_footer"><span class="ov_pvp_time">Unirse &rarr;</span></div>
			</a>
			{/if}
			{if $pvp_widget.arenas_active > 0}
			<a href="game.php?page=pvp&mode=arenas" class="ov_pvp_card ov_pvp_arenas state-active">
				<div class="ov_pvp_header"><span class="ov_pvp_icon">&#9876;&#65039;</span><span class="ov_pvp_name">Arenas activas</span></div>
				<div class="ov_pvp_status highlight">{$pvp_widget.arenas_active} en curso</div>
				<div class="ov_pvp_footer"><span class="ov_pvp_time danger">Ver &rarr;</span></div>
			</a>
			{/if}
			{if $pvp_widget.my_arena}
			<a href="game.php?page=pvp&mode=viewArena&arena_id={$pvp_widget.my_arena.id}" class="ov_pvp_card ov_pvp_myarena" id="ov_pvp_myarena_card" data-end="{$pvp_widget.my_arena.time_left}" data-status="{$pvp_widget.my_arena.status}">
				<div class="ov_pvp_header"><span class="ov_pvp_icon">&#127919;</span><span class="ov_pvp_name">Mi arena</span></div>
				<div class="ov_pvp_status">{$pvp_widget.my_arena.mode_label} &middot; {$pvp_widget.my_arena.players}/{$pvp_widget.my_arena.max}</div>
				<div class="ov_pvp_footer"><span class="ov_pvp_time" data-role="time">{$pvp_widget.my_arena.time_fmt}</span></div>
			</a>
			{/if}
			{if $pvp_widget.tournament_active === 1}
			<a href="game.php?page=pvp&mode=tournaments" class="ov_pvp_card ov_pvp_tournament {if $pvp_widget.tournament_status == 'running'}state-active{/if}" id="ov_pvp_tournament_card" data-status="{$pvp_widget.tournament_status}" data-time="{$pvp_widget.tournament_time}">
				<div class="ov_pvp_header"><span class="ov_pvp_icon">&#127942;</span><span class="ov_pvp_name">Torneo</span></div>
				<div class="ov_pvp_status">
					{if $pvp_widget.tournament_status == 'registration'}Inscripci&oacute;n abierta &middot; {$pvp_widget.tournament_players}/{$pvp_widget.tournament_max}
					{elseif $pvp_widget.tournament_status == 'running'}En curso &middot; {$pvp_widget.tournament_players} jugadores
					{else}{$pvp_widget.tournament_status}{/if}
				</div>
				<div class="ov_pvp_footer"><span class="ov_pvp_time" data-role="time">--</span></div>
			</a>
			{/if}
			{if $pvp_widget.my_pvp_points > 0 || $pvp_widget.my_pvp_wins > 0}
			<a href="game.php?page=pvp&mode=profile" class="ov_pvp_card ov_pvp_stats">
				<div class="ov_pvp_header"><span class="ov_pvp_icon">&#128202;</span><span class="ov_pvp_name">Mis stats PvP</span></div>
				<div class="ov_pvp_status">{$pvp_widget.my_pvp_points} pts &middot; {$pvp_widget.my_pvp_wins}V/{$pvp_widget.my_pvp_losses}D</div>
				<div class="ov_pvp_footer"><span class="ov_pvp_time">Logros {$pvp_widget.ach_unlocked}/{$pvp_widget.ach_total} &rarr;</span></div>
			</a>
			{/if}
		</div>
		{/if}

		{* ═══════════ NOVEDADES ═══════════ *}
		{if $is_news}
		<div class="cm_card cm_news">
			<div class="cm_sec_title" style="margin-bottom:8px"><h2>&#128240; {$LNG.ov_news}</h2></div>
			<div class="cm_news_body" style="color:var(--cm-text); font-size:12px; line-height:1.6;">{$news}</div>
		</div>
		{/if}

	</div>{* /cm_main *}

	{* ═══════════ SIDEBAR DERECHA (mockup8_3) ═══════════ *}
	<aside class="cm_side">

		{* ─── POTENCIADORES (lógica v6.6 intacta) ─── *}
		{if $allBoosters}
		<div class="cm_card">
			<div class="sec_title">&#9889; Potenciadores {if $activeBoosters > 0}<span style="color:#4aff88">&middot; {$activeBoosters} activos</span>{/if}</div>
			{foreach $allBoosters as $booster}
				{if $booster.booster_name != 'Bonus VIP Semanal' && $booster.booster_name != 'Bonus VIP Quincenal' && $booster.booster_name != 'Bonus VIP Mensual'}
				<div class="booster_card {if $booster.active}active{else}inactive{/if}">
					<div class="booster_icon">{$booster.icon_emoji}</div>
					<div>
						<div class="booster_name">{$booster.booster_name}</div>
						<div class="booster_bonus">+{$booster.booster_value}%</div>
					</div>
					<div class="booster_state">
						{if $booster.active}
							<span class="state_active">&#9201; {$booster.remaining_str}</span>
						{else}
							<span class="state_inactive">Inactivo</span>
						{/if}
					</div>
				</div>
				{/if}
			{/foreach}
		</div>
		{/if}

		{* ─── TU COMANDANTE (datos de la Carta de Usuario) ─── *}
		<div class="cm_card">
			{assign var="rankInfo_clean" value=$rankInfo|strip_tags|trim}
			{assign var="points_part" value=$rankInfo_clean|regex_replace:'/^([0-9\.,]+).*/':'$1'}
			{assign var="rank_part" value=$rankInfo_clean|regex_replace:'/^[0-9\.,]+\s*/':''}
			<div class="sec_title">&#128081; Tu comandante</div>
			<div class="cmd_card">
				<div class="cmd_avatar">&#128081;</div>
				<div>
					<div class="cmd_name">Comandante</div>
					<div class="cmd_rank">Rango: {$rank_part}</div>
				</div>
			</div>
			<div class="cmd_stats">
				<div class="cs"><b>{$points_part}</b><span>Puntos</span></div>
				<div class="cs"><b>{if isset($fleet_count)}{$fleet_count|number}{else}0{/if}</b><span>Naves</span></div>
				<div class="cs"><b>{if isset($defense_count)}{$defense_count|number}{else}0{/if}</b><span>Defensa</span></div>
			</div>
		</div>

		{* ─── LOTERÍA (lógica v6.6 intacta) ─── *}
		{if $lottery_hay && $lottery_widget}
		<div class="cm_card">
			<div class="sec_title">&#127903; Loter&iacute;a <span style="color:#94a3b8">&middot; Sorteo #{$lottery_widget.numero_sorteo}</span></div>
			<a href="game.php?page=lottery" class="ov_lot_card" style="padding:0; border:none; background:transparent">
				<div class="ov_lot_jackpot">&#127942; {$lottery_widget.jackpot_fmt} NTX-20</div>
				{assign var=lot_pct value=0}
				{if $lottery_widget.max_tickets > 0}
					{assign var=lot_pct value=($lottery_widget.tickets_vendidos / $lottery_widget.max_tickets * 100)|round}
				{/if}
				<div class="ov_lot_progress_bar" style="margin-top:8px">
					<div class="ov_lot_progress_fill" style="width:{$lot_pct}%;"></div>
				</div>
				<div class="ov_lot_footer">
					<span class="ov_lot_time" data-fin="{$lottery_widget.fecha_sorteo}">{$lottery_widget.tiempo_restante}</span>
					<span class="ov_lot_price">&#127903; {$lottery_widget.precio_ticket} NTX-20</span>
				</div>
			</a>
		</div>
		{/if}

		{* ─── RIFAS (lógica v6.6 intacta) ─── *}
		{if $raffles_hay}
		<div class="cm_card">
			<div class="sec_title">&#127920; Rifas activas {if $raffles_count > 0}<span style="color:#94a3b8">&middot; {$raffles_count}</span>{/if}</div>
			{foreach $raffles_widget as $r}
			<a href="game.php?page=raffles&mode=view&id={$r.id}" class="ov_raf_card" style="padding:10px 0 6px; border:none; border-bottom:1px solid var(--cm-border); border-radius:0; background:transparent">
				<div class="ov_raf_name">&#127920; {$r.titulo}</div>
				<div class="ov_raf_prize">&#127942; {$r.premio_texto}</div>
				<div class="ov_raf_footer" style="margin-top:5px">
					<span class="ov_raf_time" data-fin="{$r.fecha_fin}">{$r.tiempo_restante}</span>
					<span class="ov_raf_price">&#127903; {$r.precio_boleto} {$r.moneda_nombre}</span>
				</div>
			</a>
			{/foreach}
		</div>
		{/if}

	</aside>{* /cm_side *}

</div>{* /cm_shell *}

<script>
/* ============================================================
 * Cuenta atrás en vivo para Rifas + Lotería
 * ============================================================ */
(function() {
	function actualizarContadores() {
		var ahora = Math.floor(Date.now() / 1000);
		document.querySelectorAll('.ov_raf_time[data-fin]').forEach(function(el) {
			var fin = parseInt(el.getAttribute('data-fin'), 10);
			var restante = fin - ahora;
			if (restante <= 0) { el.textContent = 'SORTEANDO...'; el.className = 'ov_raf_time danger'; return; }
			var d = Math.floor(restante / 86400), h = Math.floor((restante % 86400) / 3600), m = Math.floor((restante % 3600) / 60), s = restante % 60;
			var texto = d > 0 ? d + 'd ' + h + 'h ' + m + 'm' : (h > 0 ? h + 'h ' + m + 'm ' + s + 's' : (m > 0 ? m + 'm ' + s + 's' : s + 's'));
			el.textContent = texto;
			el.className = restante < 21600 ? 'ov_raf_time danger' : (restante < 86400 ? 'ov_raf_time warn' : 'ov_raf_time');
		});
		document.querySelectorAll('.ov_lot_time[data-fin]').forEach(function(el) {
			var fin = parseInt(el.getAttribute('data-fin'), 10);
			var restante = fin - ahora;
			if (restante <= 0) { el.textContent = 'SORTEANDO...'; el.className = 'ov_lot_time danger'; return; }
			var d = Math.floor(restante / 86400), h = Math.floor((restante % 86400) / 3600), m = Math.floor((restante % 3600) / 60), s = restante % 60;
			var texto = d > 0 ? d + 'd ' + h + 'h ' + m + 'm' : (h > 0 ? h + 'h ' + m + 'm ' + s + 's' : (m > 0 ? m + 'm ' + s + 's' : s + 's'));
			el.textContent = texto;
			el.className = restante < 21600 ? 'ov_lot_time danger' : (restante < 86400 ? 'ov_lot_time warn' : 'ov_lot_time');
		});
	}
	actualizarContadores();
	setInterval(actualizarContadores, 1000);
})();

/* PvE */
(function() {
	var crisis = document.getElementById('ov_pve_crisis_card');
	var empire = document.getElementById('ov_pve_empire_card');
	var boss   = document.getElementById('ov_pve_boss_card');
	if (!crisis && !empire && !boss) return;
	function fmt(sec) {
		if (sec <= 0) return '0s';
		var d = Math.floor(sec / 86400), h = Math.floor((sec % 86400) / 3600), m = Math.floor((sec % 3600) / 60), s = sec % 60;
		if (d > 0) return d + 'd ' + h + 'h ' + m + 'm'; if (h > 0) return h + 'h ' + m + 'm ' + s + 's'; if (m > 0) return m + 'm ' + s + 's'; return s + 's';
	}
	function updateCrisis() {
		if (!crisis) return;
		var active = parseInt(crisis.getAttribute('data-active') || '0', 10), time = parseInt(crisis.getAttribute('data-time') || '0', 10), end = parseInt(crisis.getAttribute('data-end') || '0', 10);
		var status = crisis.querySelector('[data-role="status"]'), tEl = crisis.querySelector('[data-role="time"]'), now = Math.floor(Date.now() / 1000);
		if (active === 1) {
			crisis.classList.add('state-active'); status.textContent = '🔴 ACTIVA';
			if (end > 0) { var rem = end - now; if (rem > 0) { tEl.textContent = '⏱ Termina en ' + fmt(rem); tEl.className = 'ov_pve_time danger'; } else { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pve_time warn'; } } else { tEl.textContent = 'En curso'; tEl.className = 'ov_pve_time danger'; } return;
		}
		crisis.classList.remove('state-active');
		if (time > now) { var diff = time - now; if (diff < 3600) { status.textContent = '⚡ Inminente'; tEl.className = 'ov_pve_time danger'; } else if (diff < 86400) { status.textContent = '⏰ Próxima'; tEl.className = 'ov_pve_time warn'; } else { status.textContent = '✅ Programada'; tEl.className = 'ov_pve_time'; } tEl.textContent = 'Empieza en ' + fmt(diff); } else { status.textContent = '— Sin programar'; tEl.textContent = '--'; tEl.className = 'ov_pve_time off'; }
	}
	function updateBoss() {
		if (!boss) return;
		var active = parseInt(boss.getAttribute('data-active') || '0', 10), status = (boss.getAttribute('data-status') || '').trim(), time = parseInt(boss.getAttribute('data-time') || '0', 10), end = parseInt(boss.getAttribute('data-end') || '0', 10), ghosts = parseInt(boss.getAttribute('data-ghosts') || '0', 10);
		var statusE = boss.querySelector('[data-role="status"]'), tEl = boss.querySelector('[data-role="time"]'), now = Math.floor(Date.now() / 1000);
		if (active === 1) { boss.classList.add('state-active'); statusE.textContent = ghosts > 0 ? ('🔴 EN CURSO · ' + ghosts + ' jefe' + (ghosts === 1 ? '' : 's')) : '🔴 EN CURSO'; if (end > 0) { var rem = end - now; if (rem > 0) { tEl.textContent = '⏱ Termina en ' + fmt(rem); tEl.className = 'ov_pve_time danger'; } else { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pve_time warn'; } } else { tEl.textContent = 'Atacar ya →'; tEl.className = 'ov_pve_time danger'; } return; }
		boss.classList.remove('state-active');
		if (status === 'registration') { if (time > now) { var diffReg = time - now; statusE.textContent = '📝 Inscripción abierta'; tEl.textContent = 'Cierra en ' + fmt(diffReg); tEl.className = diffReg < 3600 ? 'ov_pve_time danger' : 'ov_pve_time warn'; } else { statusE.textContent = '📝 Cerrando…'; tEl.textContent = 'Iniciando…'; tEl.className = 'ov_pve_time warn'; } return; }
		if (status === 'scheduled') { if (time > now) { var diffSch = time - now; statusE.textContent = diffSch < 3600 ? '⚡ Inminente' : '✅ Programado'; tEl.textContent = 'Comienza en ' + fmt(diffSch); tEl.className = diffSch < 3600 ? 'ov_pve_time danger' : 'ov_pve_time'; } else { statusE.textContent = '✅ Programado'; tEl.textContent = 'Iniciando…'; tEl.className = 'ov_pve_time warn'; } return; }
		if (time > now) { var diffFut = time - now; statusE.textContent = '✅ Próximo evento'; tEl.textContent = 'Comienza en ' + fmt(diffFut); tEl.className = 'ov_pve_time'; } else { statusE.textContent = '— Sin torneo'; tEl.textContent = '--'; tEl.className = 'ov_pve_time off'; }
	}
	function updateEmpire() {
		if (!empire) return;
		var active = parseInt(empire.getAttribute('data-active') || '0', 10), time = parseInt(empire.getAttribute('data-time') || '0', 10), end = parseInt(empire.getAttribute('data-end') || '0', 10), count = parseInt(empire.getAttribute('data-count') || '0', 10);
		var status = empire.querySelector('[data-role="status"]'), tEl = empire.querySelector('[data-role="time"]'), now = Math.floor(Date.now() / 1000);
		if (active === 1) { empire.classList.add('state-active'); status.textContent = count > 0 ? ('🏛️ ' + count + ' imperio' + (count === 1 ? '' : 's') + ' activo' + (count === 1 ? '' : 's')) : '🏛️ ACTIVO'; if (end > 0) { var rem = end - now; if (rem > 0) { tEl.textContent = '⏱ Termina en ' + fmt(rem); tEl.className = 'ov_pve_time danger'; } else { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pve_time warn'; } } else { tEl.textContent = 'Atacar ya →'; tEl.className = 'ov_pve_time danger'; } return; }
		empire.classList.remove('state-active');
		if (time > now) { var diff = time - now; status.textContent = '⏰ Programado'; tEl.textContent = 'Empieza en ' + fmt(diff); tEl.className = diff < 3600 ? 'ov_pve_time danger' : 'ov_pve_time warn'; } else { status.textContent = '— Sin imperios'; tEl.textContent = '--'; tEl.className = 'ov_pve_time off'; }
	}
	function tickPvE() { updateCrisis(); updateBoss(); updateEmpire(); }
	tickPvE(); setInterval(tickPvE, 1000);
})();

/* PvP */
(function() {
	var myArena = document.getElementById('ov_pvp_myarena_card');
	var tournament = document.getElementById('ov_pvp_tournament_card');
	if (!myArena && !tournament) return;
	function fmt(sec) { if (sec <= 0) return '0s'; var d = Math.floor(sec / 86400), h = Math.floor((sec % 86400) / 3600), m = Math.floor((sec % 3600) / 60), s = sec % 60; if (d > 0) return d + 'd ' + h + 'h ' + m + 'm'; if (h > 0) return h + 'h ' + m + 'm ' + s + 's'; if (m > 0) return m + 'm ' + s + 's'; return s + 's'; }
	function updateMyArena() {
		if (!myArena) return;
		var status = (myArena.getAttribute('data-status') || '').trim(), end = parseInt(myArena.getAttribute('data-end') || '0', 10), tEl = myArena.querySelector('[data-role="time"]');
		if (!tEl) return;
		if (!myArena._startedAt) { myArena._startedAt = Math.floor(Date.now() / 1000); myArena._initialLeft = end; }
		var elapsed = Math.floor(Date.now() / 1000) - myArena._startedAt, remaining = Math.max(0, myArena._initialLeft - elapsed);
		if (remaining <= 0) { tEl.textContent = 'Finalizando…'; tEl.className = 'ov_pvp_time warn'; return; }
		tEl.textContent = fmt(remaining);
		if (status === 'active' || status === 'extra_time') { tEl.className = remaining < 3600 ? 'ov_pvp_time danger' : 'ov_pvp_time'; } else if (status === 'waiting') { tEl.className = remaining < 3600 ? 'ov_pvp_time warn' : 'ov_pvp_time'; } else { tEl.className = 'ov_pvp_time off'; }
	}
	function updateTournament() {
		if (!tournament) return;
		var status = (tournament.getAttribute('data-status') || '').trim(), time = parseInt(tournament.getAttribute('data-time') || '0', 10), tEl = tournament.querySelector('[data-role="time"]');
		if (!tEl) return;
		var now = Math.floor(Date.now() / 1000);
		if (status === 'registration') { if (time > now) { var diff = time - now; tEl.textContent = 'Cierra en ' + fmt(diff); tEl.className = diff < 3600 ? 'ov_pvp_time danger' : 'ov_pvp_time warn'; } else { tEl.textContent = 'Cerrando…'; tEl.className = 'ov_pvp_time warn'; } return; }
		if (status === 'running') { tEl.textContent = 'En curso ⚔️'; tEl.className = 'ov_pvp_time danger'; return; }
		tEl.textContent = '--'; tEl.className = 'ov_pvp_time off';
	}
	function tickPvP() { updateMyArena(); updateTournament(); }
	tickPvP(); setInterval(tickPvP, 1000);
})();

/* ============================================================
 * 🆕 BANNER BOOST FIN DE SEMANA
 * ============================================================ */
(function() {
    var banner = document.getElementById('xb_banner');
    if (!banner) return;

    try {
        var dismissedUntil = localStorage.getItem('xb_dismissed_until');
        if (dismissedUntil) {
            var until = parseInt(dismissedUntil, 10);
            if (until > Math.floor(Date.now() / 1000)) {
                banner.style.display = 'none';
                return;
            }
        }
    } catch (e) { }

    var timerEl   = document.getElementById('xb_timer');
    var seconds   = parseInt(banner.getAttribute('data-seconds') || '0', 10);
    var endAt     = Math.floor(Date.now() / 1000) + seconds;
    var reloading = false;

    function fmt(sec) {
        if (sec < 0) sec = 0;
        var d = Math.floor(sec / 86400);
        var h = Math.floor((sec % 86400) / 3600);
        var m = Math.floor((sec % 3600) / 60);
        var s = sec % 60;
        var parts = [];
        if (d > 0) parts.push(d + 'd');
        if (d > 0 || h > 0) parts.push((h < 10 ? '0' : '') + h + 'h');
        parts.push((m < 10 ? '0' : '') + m + 'm');
        parts.push((s < 10 ? '0' : '') + s + 's');
        return parts.join(' ');
    }

    function tick() {
        var left = endAt - Math.floor(Date.now() / 1000);
        if (timerEl) timerEl.textContent = fmt(left);

        if (left <= 0 && !reloading) {
            reloading = true;
            setTimeout(function() {
                try { location.reload(); } catch (e) {}
            }, 1500);
        }
    }

    tick();
    setInterval(tick, 1000);
})();

function xbDismiss() {
    var banner = document.getElementById('xb_banner');
    if (!banner) return;

    try {
        var until = Math.floor(Date.now() / 1000) + 21600;
        localStorage.setItem('xb_dismissed_until', until);
    } catch (e) { }

    banner.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
    banner.style.opacity    = '0';
    banner.style.transform  = 'translateY(-10px)';

    setTimeout(function() {
        banner.style.display = 'none';
    }, 300);
}

/* ============================================================
 * 🚀 RADAR DE FLOTAS EN EL OVERVIEW (v4 - ANTI-BUCLE)
 * ------------------------------------------------------------
 * - Usa SOLO 'resttime' (totalTime) para el contador.
 * - Evita desincronización de reloj.
 * - Animación: Ida (3% -> 50%) / Vuelta (50% -> 97%).
 * - Se añade sessionStorage para evitar bucle de recargas si el 
 *   cron se retrasa, mostrando "Procesando..." en rojo.
 * ============================================================ */
(function() {
    var travelers = document.querySelectorAll('.xnova-fleet-card .traveler-container');
    if (travelers.length === 0) return;

    var pageLoadTime = Math.floor(Date.now() / 1000);
    var reloading = false;

    // --- SISTEMA ANTI-BUCLE ---
    function getReloadedList() {
        try { return JSON.parse(sessionStorage.getItem('fleet_reloaded_et') || '[]'); }
        catch (e) { return []; }
    }
    function markReloaded(id) {
        var arr = getReloadedList();
        if (arr.indexOf(id) === -1) {
            arr.push(id);
            try { sessionStorage.setItem('fleet_reloaded_et', JSON.stringify(arr)); } catch (e) {}
        }
    }
    function wasReloaded(id) {
        return getReloadedList().indexOf(id) !== -1;
    }
    // --------------------------

    function updateRadar() {
        if (reloading) return;
        var now = Math.floor(Date.now() / 1000);
        var shouldReload = false;

        travelers.forEach(function(traveler) {
            var totalTime = parseInt(traveler.getAttribute('data-fleet-total-time'), 10);
            var state     = parseInt(traveler.getAttribute('data-fleet-state'), 10);
            var fleetId   = traveler.getAttribute('data-fleet-id');

            var index   = traveler.id.replace('traveler_', '');
            var timerEl = document.getElementById('timer_' + index);

            if (isNaN(totalTime)) return;

            // Usamos un endTime local para evitar desincronización
            var endTime = parseInt(traveler.getAttribute('data-fleet-local-end-time'), 10);
            if (isNaN(endTime) || endTime === 0) {
                endTime = pageLoadTime + totalTime;
                traveler.setAttribute('data-fleet-local-end-time', endTime);
            }

            var left = endTime - now;
            var percent = 3;

            if (totalTime > 0) {
                var progress = (totalTime - left) / totalTime;
                if (state === 0) {
                    percent = 3 + (progress * 47); // IDA: 3% a 50%
                    if (percent < 3)  percent = 3;
                    if (percent > 50) percent = 50;
                } else {
                    percent = 50 + (progress * 47); // VUELTA: 50% a 97%
                    if (percent < 50) percent = 50;
                    if (percent > 97) percent = 97;
                }
            }
            traveler.style.left = percent + '%';

            if (left <= 0) {
                if (!wasReloaded(fleetId)) {
                    // Primera vez que llega a 0: Recargar
                    if (timerEl) timerEl.textContent = '00:00:00';
                    traveler.style.left = (state === 0) ? '50%' : '97%';
                    markReloaded(fleetId);
                    shouldReload = true;
                } else {
                    // Ya recargamos y sigue en 0: Mostrar Procesando...
                    if (timerEl) {
                        timerEl.textContent = 'Procesando...';
                        timerEl.style.color = '#ef4444'; // Color rojo
                        timerEl.style.borderColor = '#ef4444';
                    }
                    traveler.style.left = (state === 0) ? '50%' : '97%';
                }
            } else {
                if (timerEl) {
                    var h = Math.floor(left / 3600);
                    var m = Math.floor((left % 3600) / 60);
                    var s = left % 60;
                    timerEl.textContent = (h < 10 ? '0' : '') + h + ':' +
                                          (m < 10 ? '0' : '') + m + ':' +
                                          (s < 10 ? '0' : '') + s;
                    // Restaurar estilos por si acaso
                    timerEl.style.color = '';
                    timerEl.style.borderColor = '';
                }
            }
        });

        if (shouldReload && !reloading) {
            reloading = true;
            setTimeout(function() { window.location.reload(); }, 1500);
        }
    }

    updateRadar();
    setInterval(updateRadar, 1000);
})();

/* ============================================================
 * 🆕 ASTROIO v6.6 - BUFF CLIMÁTICO (Cuenta atrás)
 * ============================================================ */
(function() {
    var timerEl = document.getElementById('ov_buff_timer');
    if (!timerEl) return;
    var expiresAt = parseInt(timerEl.getAttribute('data-expires'), 10);
    if (isNaN(expiresAt) || expiresAt <= 0) return;
    
    function updateBuffTimer() {
        var now = Math.floor(Date.now() / 1000);
        var diff = expiresAt - now;
        if (diff <= 0) {
            timerEl.textContent = '❌ Expirado';
            timerEl.style.color = '#ef4444';
            timerEl.style.textShadow = '0 0 8px rgba(239, 68, 68, 0.5)';
            return;
        }
        var h = Math.floor(diff / 3600);
        var m = Math.floor((diff % 3600) / 60);
        var s = diff % 60;
        timerEl.textContent = (h < 10 ? '0' : '') + h + 'h ' + (m < 10 ? '0' : '') + m + 'm ' + (s < 10 ? '0' : '') + s + 's';
    }
    updateBuffTimer();
    setInterval(updateBuffTimer, 1000);
})();
</script>
{/block}
{block name="script" append}
<script src="scripts/game/overview.js"></script>
{/block}
