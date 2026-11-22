{include file="overall_header.tpl"}

<style>
/* ═══════════════════════════════════════════════════════════
   ASTROIO — PANEL ADMIN PvE v4.3 (Glassmorphism v3.0)
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

body#menu {
    background: linear-gradient(180deg, rgba(15, 22, 36, 0.95) 0%, rgba(26, 35, 50, 0.95) 100%) !important;
}

.pveAdminWrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 12px;
    color: var(--text-main);
    font-family: 'Segoe UI', Roboto, sans-serif;
    font-size: 12px;
}

.pveAdminWrap h1 {
    color: #dd99ff;
    font-size: 18px;
    margin: 0 0 6px 0;
    text-shadow: 0 0 12px rgba(139, 92, 246, 0.5);
}

.pveAdminWrap .pveSub {
    color: var(--text-muted);
    font-size: 11px;
    margin-bottom: 12px;
}

/* ===== PESTAÑAS ===== */
.pveTabs {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    margin-bottom: 12px;
    padding-bottom: 8px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.15);
}

.pveTab {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    font-size: 11px;
    font-weight: 600;
    border-radius: 6px;
    text-decoration: none;
    color: var(--text-muted);
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(148, 163, 184, 0.2);
    transition: all 0.25s ease;
}

.pveTab:hover {
    color: var(--text-title);
    background: rgba(0, 224, 255, 0.1);
    border-color: rgba(0, 224, 255, 0.4);
    transform: translateY(-1px);
}

.pveTab.active {
    color: var(--text-title);
    background: linear-gradient(135deg, #0066cc, #0099ff);
    border-color: var(--accent-cyan);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
}

.pveTab.tab-purple.active {
    background: linear-gradient(135deg, #7700cc, #8b5cf6);
    border-color: var(--accent-purple);
    box-shadow: 0 0 12px rgba(139, 92, 246, 0.4);
}

.pveTab.tab-orange.active {
    background: linear-gradient(135deg, #cc5500, #fbbf24);
    border-color: var(--accent-gold);
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
}

.pveTab.tab-green.active {
    background: linear-gradient(135deg, #228833, #4aff88);
    border-color: var(--accent-green);
    box-shadow: 0 0 12px rgba(74, 255, 136, 0.4);
}

.pveTab.tab-yellow.active {
    background: linear-gradient(135deg, #cc9900, #fbbf24);
    border-color: var(--accent-gold);
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
}

.pveTab.tab-boss.active {
    background: linear-gradient(135deg, #4a0e4e, #a020a0);
    border-color: #ff66ff;
    box-shadow: 0 0 12px rgba(255, 100, 255, 0.6);
}

.pveTab.tab-boss:hover {
    background: rgba(255, 100, 255, 0.15);
    border-color: rgba(255, 100, 255, 0.5);
    color: #ffccff;
}

.pveTab.tab-bastion.active {
    background: linear-gradient(135deg, #1565c0, #42a5f5);
    border-color: #66ccff;
    box-shadow: 0 0 12px rgba(66, 165, 245, 0.6);
}

.pveTab.tab-bastion:hover {
    background: rgba(66, 165, 245, 0.15);
    border-color: rgba(100, 200, 255, 0.5);
    color: #ccddff;
}

/* ===== TARJETAS ===== */
.pveCard {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(0, 224, 255, 0.25);
    border-radius: 10px;
    padding: 12px 14px;
    margin-bottom: 10px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
    transition: 0.25s ease;
}

.pveCard:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 24px rgba(0, 0, 0, 0.5);
}

.pveCard.purple { border-color: rgba(139, 92, 246, 0.3); }
.pveCard.orange { border-color: rgba(251, 191, 36, 0.3); }
.pveCard.red    { border-color: rgba(239, 68, 68, 0.3); }
.pveCard.green  { border-color: rgba(74, 255, 136, 0.3); }
.pveCard.yellow { border-color: rgba(251, 191, 36, 0.3); }
.pveCard.cyan   { border-color: rgba(0, 224, 255, 0.35); }
.pveCard.bastion {
    border-color: rgba(66, 165, 245, 0.4);
    background: linear-gradient(135deg, rgba(10, 30, 60, 0.5), rgba(5, 15, 30, 0.5));
}
.pveCard.boss {
    border-color: rgba(255, 100, 255, 0.4);
    background: linear-gradient(135deg, rgba(40, 10, 60, 0.5), rgba(20, 5, 30, 0.5));
}

.pveCard h2 {
    font-size: 13px;
    margin: 0 0 10px 0;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.pveCard h2.purple { color: #dd99ff; text-shadow: 0 0 8px rgba(139, 92, 246, 0.3); }
.pveCard h2.orange { color: #ffaa66; text-shadow: 0 0 8px rgba(251, 191, 36, 0.3); }
.pveCard h2.red    { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.3); }
.pveCard h2.blue   { color: #88ddff; text-shadow: 0 0 8px rgba(0, 224, 255, 0.3); }
.pveCard h2.green  { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.3); }
.pveCard h2.yellow { color: #ffee88; text-shadow: 0 0 8px rgba(251, 191, 36, 0.3); }
.pveCard h2.cyan   { color: #88ffff; text-shadow: 0 0 8px rgba(0, 224, 255, 0.3); }
.pveCard h2.boss   { color: #ff88ff; text-shadow: 0 0 8px rgba(255, 100, 255, 0.3); }
.pveCard h2.bastion { color: #99ddff; text-shadow: 0 0 8px rgba(66, 165, 245, 0.3); }

/* ===== STATS GRID ===== */
.pveStatsGrid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
    gap: 8px;
    margin-bottom: 12px;
}

.pveStatBox {
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.3);
    border-radius: 6px;
    padding: 10px;
    text-align: center;
    transition: 0.25s ease;
}

.pveStatBox:hover {
    transform: translateY(-2px);
}

.pveStatBox.purple { border-color: rgba(139, 92, 246, 0.35); }
.pveStatBox.orange { border-color: rgba(251, 191, 36, 0.35); }
.pveStatBox.yellow { border-color: rgba(251, 191, 36, 0.35); }
.pveStatBox.green  { border-color: rgba(74, 255, 136, 0.35); }
.pveStatBox.red    { border-color: rgba(239, 68, 68, 0.35); }
.pveStatBox.boss   { border-color: rgba(255, 100, 255, 0.5); background: rgba(40, 10, 60, 0.4); }
.pveStatBox.bastion { border-color: rgba(66, 165, 245, 0.5); background: rgba(10, 30, 60, 0.4); }

.pveStatLabel {
    font-size: 10px;
    color: var(--text-muted);
    margin-bottom: 4px;
}

.pveStatValue {
    font-size: 18px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
}

.pveStatBox.purple .pveStatValue { color: #dd99ff; text-shadow: 0 0 8px rgba(139, 92, 246, 0.4); }
.pveStatBox.orange .pveStatValue { color: #ffaa66; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }
.pveStatBox.yellow .pveStatValue { color: #ffdd88; text-shadow: 0 0 8px rgba(251, 191, 36, 0.4); }
.pveStatBox.green  .pveStatValue { color: #88ffbb; text-shadow: 0 0 8px rgba(74, 255, 136, 0.4); }
.pveStatBox.red    .pveStatValue { color: #ff8888; text-shadow: 0 0 8px rgba(239, 68, 68, 0.4); }
.pveStatBox.boss   .pveStatValue { color: #ff88ff; text-shadow: 0 0 8px rgba(255, 100, 255, 0.4); }
.pveStatBox.bastion .pveStatValue { color: #99ddff; text-shadow: 0 0 8px rgba(66, 165, 245, 0.4); }

/* ===== FORM INPUTS ===== */
.pveInput {
    width: 100%;
    margin-top: 4px;
    padding: 6px 8px;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.3);
    color: var(--text-title);
    border-radius: 6px;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    box-sizing: border-box;
    transition: 0.25s ease;
}

.pveInput.purple { border-color: rgba(139, 92, 246, 0.4); }
.pveInput.orange { border-color: rgba(251, 191, 36, 0.4); }
.pveInput.green  { border-color: rgba(74, 255, 136, 0.4); }
.pveInput.yellow { border-color: rgba(251, 191, 36, 0.4); }
.pveInput.boss   { border-color: rgba(255, 100, 255, 0.5); background: rgba(20, 5, 30, 0.6); }
.pveInput.bastion { border-color: rgba(66, 165, 245, 0.5); background: rgba(5, 15, 30, 0.6); }

.pveInput:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
    transform: translateY(-1px);
}

.pveInput.boss:focus {
    border-color: #ff66ff;
    box-shadow: 0 0 8px rgba(255, 100, 255, 0.6);
}

.pveInput.bastion:focus {
    border-color: #66ccff;
    box-shadow: 0 0 8px rgba(66, 165, 245, 0.6);
}

.pveLabel {
    font-size: 11px;
    color: #aabbcc;
    display: block;
}

.pveGrid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.pveGrid3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 8px; }
.pveGrid4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 8px; }

@media (max-width: 700px) {
    .pveGrid2, .pveGrid3, .pveGrid4 { grid-template-columns: 1fr; }
}

/* ===== BOTONES ===== */
.pveBtn {
    display: inline-block;
    padding: 8px 16px;
    border: 1px solid transparent;
    border-radius: 6px;
    font-size: 12px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    text-align: center;
    transition: all 0.25s ease;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}

.pveBtn.blue {
    background: linear-gradient(135deg, #0066cc, #00aaff);
    color: var(--text-title);
    border-color: var(--accent-cyan);
    box-shadow: 0 3px 10px rgba(0, 170, 255, 0.4);
}
.pveBtn.blue:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(0, 170, 255, 0.6); }

.pveBtn.purple {
    background: linear-gradient(135deg, #7700cc, #8b5cf6);
    color: var(--text-title);
    border-color: var(--accent-purple);
    box-shadow: 0 3px 10px rgba(139, 92, 246, 0.4);
}
.pveBtn.purple:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(139, 92, 246, 0.6); }

.pveBtn.orange {
    background: linear-gradient(135deg, #cc5500, #fbbf24);
    color: #1a1000;
    border-color: var(--accent-gold);
    box-shadow: 0 3px 10px rgba(251, 191, 36, 0.4);
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.pveBtn.orange:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(251, 191, 36, 0.6); }

.pveBtn.red {
    background: linear-gradient(135deg, #aa2200, #ef4444);
    color: var(--text-title);
    border-color: var(--accent-red);
    box-shadow: 0 3px 10px rgba(239, 68, 68, 0.4);
}
.pveBtn.red:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(239, 68, 68, 0.6); }

.pveBtn.green {
    background: linear-gradient(135deg, #228833, #4aff88);
    color: var(--text-title);
    border-color: var(--accent-green);
    box-shadow: 0 3px 10px rgba(74, 255, 136, 0.4);
}
.pveBtn.green:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(74, 255, 136, 0.6); }

.pveBtn.yellow {
    background: linear-gradient(135deg, #cc9900, #fbbf24);
    color: #1a1000;
    border-color: var(--accent-gold);
    box-shadow: 0 3px 10px rgba(251, 191, 36, 0.4);
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.pveBtn.yellow:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(251, 191, 36, 0.6); }

.pveBtn.cyan {
    background: linear-gradient(135deg, #008888, #00dddd);
    color: var(--text-title);
    border-color: var(--accent-cyan);
    box-shadow: 0 3px 10px rgba(0, 224, 255, 0.4);
}
.pveBtn.cyan:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(0, 224, 255, 0.6); }

.pveBtn.boss {
    background: linear-gradient(135deg, #7700cc, #a020a0);
    color: var(--text-title);
    border-color: #ff66ff;
    box-shadow: 0 3px 10px rgba(255, 100, 255, 0.5);
}
.pveBtn.boss:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(255, 100, 255, 0.7); }

.pveBtn.bastion {
    background: linear-gradient(135deg, #1565c0, #42a5f5);
    color: var(--text-title);
    border-color: #66ccff;
    box-shadow: 0 3px 10px rgba(66, 165, 245, 0.5);
}
.pveBtn.bastion:hover { transform: translateY(-2px); box-shadow: 0 5px 14px rgba(66, 165, 245, 0.7); }

.pveBtn.small { padding: 4px 10px; font-size: 10px; }
.pveBtn.ghost {
    background: rgba(255, 255, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: var(--text-muted);
    border: 1px solid var(--border-color);
}
.pveBtn.ghost:hover { color: var(--text-title); border-color: var(--text-muted); transform: translateY(-2px); }

/* ===== TABLAS ===== */
.pveTable {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}

.pveTable thead th {
    padding: 6px 8px;
    text-align: left;
    color: #88ddff;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.pveTable thead.purple th { color: #dd99ff; border-bottom-color: rgba(139, 92, 246, 0.3); }
.pveTable thead.orange th { color: #ffaa66; border-bottom-color: rgba(251, 191, 36, 0.3); }
.pveTable thead.green  th { color: #88ffbb; border-bottom-color: rgba(74, 255, 136, 0.3); }
.pveTable thead.boss   th { color: #ff88ff; border-bottom-color: rgba(255, 100, 255, 0.4); }
.pveTable thead.bastion th { color: #99ddff; border-bottom-color: rgba(66, 165, 245, 0.4); }

.pveTable tbody td {
    padding: 6px 8px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-main);
}

.pveTable tbody tr:hover { background: rgba(0, 224, 255, 0.04); }
.pveTable tbody tr.boss-row:hover { background: rgba(255, 100, 255, 0.08); }
.pveTable tbody tr.bastion-row:hover { background: rgba(66, 165, 245, 0.08); }

.pveTable .center { text-align: center; }
.pveTable .right  { text-align: right; }

/* ===== HP BAR ===== */
.pveHpBar {
    height: 5px;
    background: rgba(0, 0, 0, 0.5);
    border-radius: 3px;
    overflow: hidden;
    margin-top: 3px;
}

.pveHpFill {
    height: 100%;
    background: linear-gradient(90deg, #ef4444, #fbbf24, #fde047);
    box-shadow: 0 0 6px rgba(251, 191, 36, 0.4) inset;
}

.pveHpBar.boss .pveHpFill {
    background: linear-gradient(90deg, #8b5cf6, #ff44ff, #ffaaff);
    box-shadow: 0 0 6px rgba(255, 100, 255, 0.5) inset;
}

.pveHpBar.bastion .pveHpFill {
    background: linear-gradient(90deg, #228833, #44ddaa, #88ffcc);
    box-shadow: 0 0 6px rgba(74, 255, 136, 0.5) inset;
}

/* ===== BADGES ===== */
.pveBadge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.3px;
}

.pveBadge.purple { background: rgba(139, 92, 246, 0.25); color: #dd99ff; border: 1px solid rgba(139, 92, 246, 0.5); }
.pveBadge.orange { background: rgba(251, 191, 36, 0.25); color: #ffaa66; border: 1px solid rgba(251, 191, 36, 0.5); }
.pveBadge.green  { background: rgba(74, 255, 136, 0.2);  color: #88ffbb; border: 1px solid rgba(74, 255, 136, 0.5); }
.pveBadge.red    { background: rgba(239, 68, 68, 0.25); color: #ff8888; border: 1px solid rgba(239, 68, 68, 0.5); }
.pveBadge.yellow { background: rgba(251, 191, 36, 0.25);color: #ffee88; border: 1px solid rgba(251, 191, 36, 0.5); }
.pveBadge.cyan   { background: rgba(0, 224, 255, 0.25); color: #88ffff; border: 1px solid rgba(0, 224, 255, 0.5); }
.pveBadge.boss   { background: rgba(255, 100, 255, 0.25);color: #ff88ff; border: 1px solid rgba(255, 100, 255, 0.6); }
.pveBadge.bastion { background: rgba(66, 165, 245, 0.25); color: #99ddff; border: 1px solid rgba(66, 165, 245, 0.6); }

/* ===== MENSAJES FLASH ===== */
.pveFlash {
    padding: 10px 14px;
    margin-bottom: 12px;
    border-radius: 8px;
    font-size: 12px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.pveFlash.success { background: rgba(74, 255, 136, 0.15); border: 1px solid rgba(74, 255, 136, 0.5); color: #88ffbb; }
.pveFlash.error   { background: rgba(239, 68, 68, 0.15); border: 1px solid rgba(239, 68, 68, 0.5); color: #ffbbbb; }
.pveFlash.info    { background: rgba(0, 224, 255, 0.15); border: 1px solid rgba(0, 224, 255, 0.5); color: #88ddff; }

/* ===== TEMPLATE MINI EDITOR ===== */
.tplShipRow {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 5px 8px;
    border-radius: 5px;
    background: rgba(0, 0, 0, 0.25);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    margin-bottom: 4px;
    font-size: 11px;
}

.tplShipRow label {
    flex: 1;
    color: #aabbcc;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
}

.tplShipRow input[type=checkbox] {
    width: 14px;
    height: 14px;
    cursor: pointer;
    accent-color: var(--accent-purple);
}

.tplShipRow input[type=number] {
    width: 90px;
    padding: 3px 6px;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(139, 92, 246, 0.3);
    color: var(--text-title);
    border-radius: 4px;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    text-align: right;
}

.tplShipsGrid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 6px;
}

.tplCard {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(139, 92, 246, 0.3);
    border-left: 3px solid #bb44ff;
    border-radius: 8px;
    padding: 10px 12px;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 12px;
    transition: all 0.25s ease;
}

.tplCard:hover {
    border-color: #cc66ff;
    box-shadow: 0 2px 10px rgba(139, 92, 246, 0.3);
    transform: translateY(-2px);
}

.tplCard.is-default {
    border-left-color: #ffee66;
    background: linear-gradient(135deg, rgba(50, 40, 0, 0.4), rgba(30, 20, 0, 0.4));
}

.tplCard.inactive {
    opacity: 0.55;
}

.tplCardInfo {
    flex: 1;
    min-width: 0;
}

.tplCardName {
    font-size: 13px;
    font-weight: 700;
    color: var(--text-title);
    margin-bottom: 2px;
}

.tplCardStats {
    font-size: 10px;
    color: var(--text-muted);
    font-family: 'Courier New', monospace;
}

.tplCardActions {
    display: flex;
    gap: 4px;
    flex-shrink: 0;
}

.rewardsBox {
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.25);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(251, 191, 36, 0.25);
    border-radius: 6px;
    margin-bottom: 8px;
}

.rewardsRadioRow {
    display: flex;
    gap: 8px;
    margin-bottom: 10px;
}

.rewardsRadioRow label {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.4);
    border: 2px solid rgba(148, 163, 184, 0.25);
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.25s ease;
    font-size: 12px;
}

.rewardsRadioRow label:hover {
    border-color: rgba(251, 191, 36, 0.5);
    transform: translateY(-1px);
}

.rewardsRadioRow input[type=radio] {
    width: 16px;
    height: 16px;
    cursor: pointer;
    accent-color: var(--accent-gold);
}

.rewardsRadioRow label.active {
    border-color: var(--accent-gold);
    background: rgba(251, 191, 36, 0.1);
    box-shadow: 0 0 10px rgba(251, 191, 36, 0.3);
}

.rewardsSection {
    padding: 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-gold);
    border-radius: 5px;
    margin-bottom: 10px;
}

.rewardsSection.hidden {
    display: none;
}

.pveCleanupCard {
    background: linear-gradient(135deg, rgba(0, 60, 60, 0.4), rgba(0, 40, 40, 0.4));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(0, 224, 255, 0.35);
    border-left: 3px solid #00dddd;
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 10px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

.pveCleanupCard h2 {
    color: #88ffff;
    font-size: 13px;
    margin: 0 0 10px 0;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
}

.pveCleanupList {
    list-style: none;
    margin: 8px 0 12px 0;
    padding: 0;
    font-size: 11px;
    color: #aabbcc;
}

.pveCleanupList li {
    padding: 4px 0;
    border-bottom: 1px dashed rgba(0, 224, 255, 0.1);
}

.pveCleanupList li:last-child {
    border-bottom: none;
}

.pveCleanupList li::before {
    content: '✓ ';
    color: #00dddd;
    font-weight: bold;
    margin-right: 4px;
}

.bossStatusBadge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.5px;
    margin-left: 6px;
}
.bossStatusBadge.scheduled    { background: rgba(148, 163, 184, 0.3); color: #cccccc; border: 1px solid rgba(180, 180, 180, 0.5); }
.bossStatusBadge.registration { background: rgba(0, 224, 255, 0.25); color: #88ddff; border: 1px solid rgba(0, 224, 255, 0.6); }
.bossStatusBadge.active       { background: rgba(239, 68, 68, 0.25); color: #ff8888; border: 1px solid rgba(239, 68, 68, 0.6); }
.bossStatusBadge.finished     { background: rgba(74, 255, 136, 0.25); color: #88ffbb; border: 1px solid rgba(74, 255, 136, 0.6); }
.bossStatusBadge.cancelled    { background: rgba(251, 191, 36, 0.25); color: #ffaa66; border: 1px solid rgba(251, 191, 36, 0.6); }

.bastionStatusBadge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.5px;
    margin-left: 6px;
}
.bastionStatusBadge.scheduled    { background: rgba(148, 163, 184, 0.3); color: #cccccc; border: 1px solid rgba(180, 180, 180, 0.5); }
.bastionStatusBadge.registration { background: rgba(0, 224, 255, 0.25); color: #88ddff; border: 1px solid rgba(0, 224, 255, 0.6); }
.bastionStatusBadge.active       { background: rgba(74, 255, 136, 0.25); color: #88ffbb; border: 1px solid rgba(74, 255, 136, 0.6); }
.bastionStatusBadge.finished     { background: rgba(100, 150, 255, 0.25); color: #99bbff; border: 1px solid rgba(150, 200, 255, 0.6); }
.bastionStatusBadge.cancelled    { background: rgba(251, 191, 36, 0.25); color: #ffaa66; border: 1px solid rgba(251, 191, 36, 0.6); }

.bossControlBar {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 12px;
    padding: 10px;
    background: rgba(20, 5, 30, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 100, 255, 0.3);
    border-radius: 6px;
    align-items: center;
}

.bossControlBar .label {
    color: #ff88ff;
    font-weight: 700;
    font-size: 11px;
    margin-right: 6px;
}

.bastionControlBar {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-bottom: 12px;
    padding: 10px;
    background: rgba(5, 15, 30, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(66, 165, 245, 0.3);
    border-radius: 6px;
    align-items: center;
}

.bastionControlBar .label {
    color: #99ddff;
    font-weight: 700;
    font-size: 11px;
    margin-right: 6px;
}

.bossEntryModeBox {
    display: flex;
    gap: 8px;
    margin-bottom: 12px;
}

.bossEntryModeBox label {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.4);
    border: 2px solid rgba(148, 163, 184, 0.25);
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.25s ease;
    font-size: 12px;
}

.bossEntryModeBox label:hover {
    border-color: rgba(255, 100, 255, 0.5);
    transform: translateY(-1px);
}

.bossEntryModeBox label.active {
    border-color: #ff66ff;
    background: rgba(255, 100, 255, 0.1);
    box-shadow: 0 0 10px rgba(255, 100, 255, 0.4);
}

.bossEntryModeBox input[type=radio] {
    accent-color: #ff66ff;
}

.bossEntrySection {
    padding: 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid #ff66ff;
    border-radius: 5px;
    margin-bottom: 10px;
}

.bossEntrySection.hidden {
    display: none;
}

.bossHelpText {
    color: var(--text-muted);
    font-size: 10px;
    margin-top: 6px;
    line-height: 1.4;
}

.scheduleCard {
    background: linear-gradient(135deg, rgba(40, 20, 60, 0.6), rgba(60, 30, 80, 0.6));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(255, 100, 255, 0.5);
    border-left: 4px solid #cc66ff;
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 10px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

.scheduleCard h2 {
    color: #ff88ff;
    font-size: 14px;
    margin: 0 0 10px 0;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(255, 100, 255, 0.25);
    text-shadow: 0 0 8px rgba(255, 100, 255, 0.3);
}

.scheduleCard.bastion {
    background: linear-gradient(135deg, rgba(20, 40, 70, 0.6), rgba(30, 60, 90, 0.6));
    border-color: rgba(100, 180, 255, 0.5);
    border-left-color: #66aaff;
}

.scheduleCard.bastion h2 {
    color: #99ddff;
    border-bottom-color: rgba(100, 180, 255, 0.25);
    text-shadow: 0 0 8px rgba(66, 165, 245, 0.3);
}

.scheduleToggleLabel {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 14px;
    background: rgba(255, 100, 255, 0.08);
    border: 2px solid rgba(255, 100, 255, 0.35);
    border-radius: 8px;
    cursor: pointer;
    margin-bottom: 14px;
    transition: all 0.25s ease;
}

.scheduleToggleLabel:hover {
    border-color: rgba(255, 100, 255, 0.65);
    background: rgba(255, 100, 255, 0.12);
    transform: translateY(-1px);
}

.scheduleToggleLabel.bastion {
    background: rgba(66, 165, 245, 0.08);
    border-color: rgba(100, 180, 255, 0.35);
}

.scheduleToggleLabel.bastion:hover {
    border-color: rgba(100, 180, 255, 0.65);
    background: rgba(66, 165, 245, 0.12);
}

.scheduleToggleLabel input[type=checkbox] {
    width: 20px;
    height: 20px;
    cursor: pointer;
    accent-color: #ff66ff;
}

.scheduleToggleLabel.bastion input[type=checkbox] {
    accent-color: #66aaff;
}

.scheduleNextBox {
    padding: 12px;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-gold);
    border-radius: 6px;
    margin-bottom: 12px;
}

.scheduleNextBox .scheduleLabel {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 4px;
}

.scheduleNextBox .scheduleValue {
    font-size: 18px;
    color: #ffee88;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.4);
}

.bastionEntryModeBox {
    display: flex;
    gap: 8px;
    margin-bottom: 12px;
}

.bastionEntryModeBox label {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 12px;
    background: rgba(0, 0, 0, 0.4);
    border: 2px solid rgba(148, 163, 184, 0.25);
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.25s ease;
    font-size: 12px;
}

.bastionEntryModeBox label:hover {
    border-color: rgba(66, 165, 245, 0.5);
    transform: translateY(-1px);
}

.bastionEntryModeBox label.active {
    border-color: #66ccff;
    background: rgba(66, 165, 245, 0.1);
    box-shadow: 0 0 10px rgba(66, 165, 245, 0.4);
}

.bastionEntryModeBox input[type=radio] {
    accent-color: #66aaff;
}

.bastionEntrySection {
    padding: 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid #66aaff;
    border-radius: 5px;
    margin-bottom: 10px;
}

.bastionEntrySection.hidden {
    display: none;
}

/* v4.3 — Hint inline para dual-riel en forms */
.rielHint {
    display: inline-block;
    padding: 2px 8px;
    margin-left: 4px;
    font-size: 10px;
    color: #88ddff;
    background: rgba(0, 224, 255, 0.1);
    border: 1px solid rgba(0, 224, 255, 0.25);
    border-radius: 4px;
    font-family: monospace;
}
.rielHint.cup     { color: #ffee88; background: rgba(251, 191, 36, 0.1); border-color: rgba(251, 191, 36, 0.3); }
.rielHint.qvapay  { color: #88ffff; background: rgba(0, 224, 255, 0.1); border-color: rgba(0, 224, 255, 0.3); }
</style>

<div class="pveAdminWrap">
	<h1>⚔️ PANEL ADMIN — SISTEMA PvE</h1>
	<p class="pveSub">
		Gestiona plantillas, crisis, imperios, torneos y bastiones. Los cambios se aplican en el próximo ciclo del cron (máx 5 min).
	</p>

	{if $message != ''}
		<div class="pveFlash {if $msgType == 'success'}success{elseif $msgType == 'error'}error{else}info{/if}">
			{$message}
		</div>
	{/if}

	<div class="pveTabs">
		<a href="admin.php?page=pveadmin&tab=dashboard"
		   class="pveTab {if $active_tab == 'dashboard'}active{/if}">
			📊 Dashboard
		</a>
		<a href="admin.php?page=pveadmin&tab=templates"
		   class="pveTab tab-purple {if $active_tab == 'templates'}active{/if}">
			🎨 Plantillas
		</a>
		<a href="admin.php?page=pveadmin&tab=empires"
		   class="pveTab tab-orange {if $active_tab == 'empires'}active{/if}">
			🏛️ Imperios
		</a>
		<a href="admin.php?page=pveadmin&tab=crisis"
		   class="pveTab tab-purple {if $active_tab == 'crisis'}active{/if}">
			🌌 Crisis
		</a>
		<a href="admin.php?page=pveadmin&tab=boss"
		   class="pveTab tab-boss {if $active_tab == 'boss'}active{/if}">
			🌌 Torneo del Devorador
		</a>
		<a href="admin.php?page=pveadmin&tab=bastion"
		   class="pveTab tab-bastion {if $active_tab == 'bastion'}active{/if}">
			⚓ Bastión Asediado
		</a>
		<a href="admin.php?page=pveadmin&tab=rewards"
		   class="pveTab tab-yellow {if $active_tab == 'rewards'}active{/if}">
			🎁 Recompensas
		</a>
		<a href="admin.php?page=pveadmin&tab=history"
		   class="pveTab tab-green {if $active_tab == 'history'}active{/if}">
			📜 Historial
		</a>
	</div>

	{if $active_tab == 'dashboard'}

		<div class="pveStatsGrid">
			<div class="pveStatBox purple">
				<div class="pveStatLabel">🌌 Crisis Totales</div>
				<div class="pveStatValue">{$stats.total_crisis}</div>
			</div>
			<div class="pveStatBox orange">
				<div class="pveStatLabel">🏛️ Imperios Totales</div>
				<div class="pveStatValue">{$stats.total_empires}</div>
			</div>
			<div class="pveStatBox yellow">
				<div class="pveStatLabel">🎁 Recompensas</div>
				<div class="pveStatValue">{$stats.total_rewards}</div>
			</div>
			<div class="pveStatBox green">
				<div class="pveStatLabel">✅ Reclamadas</div>
				<div class="pveStatValue">{$stats.rewards_claimed}</div>
			</div>
			<div class="pveStatBox red">
				<div class="pveStatLabel">⚔️ Ataques</div>
				<div class="pveStatValue">{$stats.total_attacks}</div>
			</div>
		</div>

		<div class="pveCleanupCard">
			<h2>🧹 Limpieza Automática — Forzar Ahora</h2>
			<p style="color:#aabbcc;font-size:11px;margin-bottom:8px;">
				Ejecuta manualmente las 3 capas de limpieza sin esperar al cron.
				Borra residuos huérfanos, crisis zombie, imperios expirados, logs viejos y más.
			</p>
			<ul class="pveCleanupList">
				<li><b>Capa 2 (huérfanos):</b> flotas pirata sin llegar · fleet_events huérfanos · waves sin crisis · crisis zombie · imperios expirados · ataques huérfanos · invitaciones ACS viejas</li>
				<li><b>Capa 3 (profunda):</b> logs +30 días · crisis terminadas +7 días · recompensas expiradas +7 días · imperios muertos +7 días · ataques +30 días · invitaciones +30 días</li>
			</ul>
			<div style="text-align:center;margin-top:10px;">
				<a href="admin.php?page=pveadmin&mode=runCleanup&tab=dashboard"
				   class="pveBtn cyan"
				   onclick="return confirm('🧹 ¿Ejecutar limpieza completa AHORA?\n\nSe borrarán residuos huérfanos y datos viejos. Esta acción es segura y no afecta a jugadores activos.');">
					🧹 Ejecutar Limpieza Ahora
				</a>
			</div>
		</div>

		<div class="pveCard">
			<h2 class="blue">⚙️ Configuración Global</h2>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveConfig&tab=dashboard">

				<div class="pveGrid3" style="margin-bottom: 12px;">
					<label style="display:flex;align-items:center;gap:8px;padding:8px 10px;background:rgba(0,224,255,0.05);border:1px solid rgba(0,224,255,0.25);border-radius:6px;cursor:pointer;">
						<input type="checkbox" name="pve_enabled" value="1" {if $config.pve_enabled}checked{/if} style="width:16px;height:16px;">
						<span style="color:#88ddff;font-weight:bold;font-size:12px;">🌐 Sistema PvE</span>
					</label>
					<label style="display:flex;align-items:center;gap:8px;padding:8px 10px;background:rgba(139,92,246,0.05);border:1px solid rgba(139,92,246,0.25);border-radius:6px;cursor:pointer;">
						<input type="checkbox" name="pve_crisis_enabled" value="1" {if $config.pve_crisis_enabled}checked{/if} style="width:16px;height:16px;">
						<span style="color:#dd99ff;font-weight:bold;font-size:12px;">🌌 Crisis</span>
					</label>
					<label style="display:flex;align-items:center;gap:8px;padding:8px 10px;background:rgba(251,191,36,0.05);border:1px solid rgba(251,191,36,0.25);border-radius:6px;cursor:pointer;">
						<input type="checkbox" name="pve_empire_enabled" value="1" {if $config.pve_empire_enabled}checked{/if} style="width:16px;height:16px;">
						<span style="color:#ffaa66;font-weight:bold;font-size:12px;">🏛️ Imperio</span>
					</label>
				</div>

				<h3 style="color:#dd99ff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(139,92,246,0.3);padding-bottom:4px;">
					🌌 Crisis de Fin de Mes
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">📅 Día
						<input type="number" name="crisis_day" min="1" max="28" value="{$config.crisis_day|default:25}" class="pveInput purple">
					</label>
					<label class="pveLabel">🕐 Hora
						<select name="crisis_hour" class="pveInput purple">
							<option value="0"  {if $config.crisis_hour == 0}selected{/if}>12 AM</option>
							<option value="1"  {if $config.crisis_hour == 1}selected{/if}>01 AM</option>
							<option value="2"  {if $config.crisis_hour == 2}selected{/if}>02 AM</option>
							<option value="3"  {if $config.crisis_hour == 3}selected{/if}>03 AM</option>
							<option value="4"  {if $config.crisis_hour == 4}selected{/if}>04 AM</option>
							<option value="5"  {if $config.crisis_hour == 5}selected{/if}>05 AM</option>
							<option value="6"  {if $config.crisis_hour == 6}selected{/if}>06 AM</option>
							<option value="7"  {if $config.crisis_hour == 7}selected{/if}>07 AM</option>
							<option value="8"  {if $config.crisis_hour == 8}selected{/if}>08 AM</option>
							<option value="9"  {if $config.crisis_hour == 9}selected{/if}>09 AM</option>
							<option value="10" {if $config.crisis_hour == 10}selected{/if}>10 AM</option>
							<option value="11" {if $config.crisis_hour == 11}selected{/if}>11 AM</option>
							<option value="12" {if $config.crisis_hour == 12}selected{/if}>12 PM</option>
							<option value="13" {if $config.crisis_hour == 13}selected{/if}>01 PM</option>
							<option value="14" {if $config.crisis_hour == 14}selected{/if}>02 PM</option>
							<option value="15" {if $config.crisis_hour == 15}selected{/if}>03 PM</option>
							<option value="16" {if $config.crisis_hour == 16}selected{/if}>04 PM</option>
							<option value="17" {if $config.crisis_hour == 17}selected{/if}>05 PM</option>
							<option value="18" {if $config.crisis_hour == 18}selected{/if}>06 PM</option>
							<option value="19" {if $config.crisis_hour == 19}selected{/if}>07 PM</option>
							<option value="20" {if $config.crisis_hour == 20}selected{/if}>08 PM</option>
							<option value="21" {if $config.crisis_hour == 21}selected{/if}>09 PM</option>
							<option value="22" {if $config.crisis_hour == 22}selected{/if}>10 PM</option>
							<option value="23" {if $config.crisis_hour == 23}selected{/if}>11 PM</option>
						</select>
					</label>
					<label class="pveLabel">⏰ Min
						<input type="number" name="crisis_minute" min="0" max="59" value="{$config.crisis_minute|default:30}" class="pveInput purple">
					</label>
					<label class="pveLabel">🌊 Oleadas
						<input type="number" name="crisis_waves" min="1" max="10" value="{$config.crisis_waves|default:5}" class="pveInput purple">
					</label>
					<label class="pveLabel">⏱️ Duración (h)
						<input type="number" name="crisis_duration_hours" min="1" max="168" value="{$config.crisis_duration_hours|default:24}" class="pveInput purple">
					</label>
					<label class="pveLabel">⏳ Intervalo (min)
						<input type="number" name="crisis_wave_interval_minutes" min="1" max="1440" value="{$config.crisis_wave_interval_minutes|default:60}" class="pveInput purple">
					</label>
				</div>

				<h3 style="color:#ffaa66;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(251,191,36,0.3);padding-bottom:4px;">
					🏛️ Imperio Caído
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">🏰 Por evento
						<input type="number" name="empire_count" min="1" max="10" value="{$config.empire_count|default:1}" class="pveInput orange">
					</label>
					<label class="pveLabel">⏱️ Duración (h)
						<input type="number" name="empire_duration_hours" min="1" max="168" value="{$config.empire_duration_hours|default:24}" class="pveInput orange">
					</label>
					<label class="pveLabel">⚔️ Ataques/jugador
						<input type="number" name="empire_attacks_per_user" min="1" max="50" value="{$config.empire_attacks_per_user|default:5}" class="pveInput orange">
					</label>
					<label class="pveLabel">🎲 % Contraataque
						<input type="number" name="empire_counterattack_pct" min="0" max="100" value="{$config.empire_counterattack_pct|default:30}" class="pveInput orange">
					</label>
				</div>

				<div style="text-align:center;">
					<button type="submit" class="pveBtn blue">💾 Guardar Configuración</button>
				</div>
			</form>
		</div>

		<div class="pveGrid2">
			<div class="pveCard red">
				<h2 class="red">🔴 Activar Crisis AHORA</h2>
				<form method="POST" action="admin.php?page=pveadmin&mode=activateCrisis&tab=dashboard">
					<label class="pveLabel">🌊 Oleadas (1-10)
						<input type="number" name="waves" min="1" max="10" value="{$config.crisis_waves|default:5}" class="pveInput">
					</label>
					<button type="submit" class="pveBtn red" style="width:100%;margin-top:8px;">🔴 Activar Ahora</button>
				</form>
			</div>

			<div class="pveCard purple">
				<h2 class="purple">📅 Programar Crisis</h2>
				<form method="POST" action="admin.php?page=pveadmin&mode=scheduleCrisis&tab=dashboard">
					<div class="pveGrid3" style="margin-bottom:6px;">
						<label class="pveLabel">Día
							<input type="number" name="day" min="1" max="28" value="25" class="pveInput purple">
						</label>
						<label class="pveLabel">Hora
							<select name="hour" class="pveInput purple">
								<option value="0">12 AM</option>
								<option value="1">01 AM</option>
								<option value="2">02 AM</option>
								<option value="3">03 AM</option>
								<option value="4">04 AM</option>
								<option value="5">05 AM</option>
								<option value="6">06 AM</option>
								<option value="7">07 AM</option>
								<option value="8">08 AM</option>
								<option value="9">09 AM</option>
								<option value="10" selected>10 AM</option>
								<option value="11">11 AM</option>
								<option value="12">12 PM</option>
								<option value="13">01 PM</option>
								<option value="14">02 PM</option>
								<option value="15">03 PM</option>
								<option value="16">04 PM</option>
								<option value="17">05 PM</option>
								<option value="18">06 PM</option>
								<option value="19">07 PM</option>
								<option value="20">08 PM</option>
								<option value="21">09 PM</option>
								<option value="22">10 PM</option>
								<option value="23">11 PM</option>
							</select>
						</label>
						<label class="pveLabel">Min
							<input type="number" name="minute" min="0" max="59" value="30" class="pveInput purple">
						</label>
					</div>
					<label class="pveLabel">🌊 Oleadas
						<input type="number" name="waves" min="1" max="10" value="{$config.crisis_waves|default:5}" class="pveInput purple">
					</label>
					<button type="submit" class="pveBtn purple" style="width:100%;margin-top:8px;">📅 Programar</button>
				</form>
			</div>
		</div>

	{/if}

	{* --------------------------------------------------------------
	 *  FIN DE LA PARTE 1 — continúa en la PARTE 2 con:
	 *    - Tab templates (editor + listado)
	 *    - Tab empires
	 *    - Tab crisis (con auto-schedule)
	 *    - Tab boss (stats con pools duales + cleanup + evento + ranking + ghosts)
	 * -------------------------------------------------------------- *}
	 
	 	{if $active_tab == 'templates'}

		{if $edit_mode && $edit_template}

			<div class="pveCard purple">
				<h2 class="purple">
					{if $edit_template.id > 0}
						✏️ Editar Plantilla #{$edit_template.id}: {$edit_template.name}
					{else}
						➕ Nueva Plantilla
					{/if}
				</h2>

				<form method="POST" action="admin.php?page=pveadmin&mode=saveTemplate&tab=templates">
					<input type="hidden" name="template_id" value="{$edit_template.id|default:0}">

					<div class="pveGrid3" style="margin-bottom:10px;">
						<label class="pveLabel">📝 Nombre *
							<input type="text" name="name" value="{$edit_template.name|default:''|escape:'html'}" required class="pveInput purple">
						</label>
						<label class="pveLabel">🔗 Slug (identificador)
							<input type="text" name="slug" value="{$edit_template.slug|default:''|escape:'html'}" class="pveInput purple" placeholder="ej: normal">
						</label>
						<label class="pveLabel">💥 HP Multiplier
							<input type="number" step="0.01" name="hp_mult" min="0.01" value="{$edit_template.hp_mult|default:5}" class="pveInput purple">
						</label>
					</div>

					<label class="pveLabel" style="margin-bottom:10px;">📄 Descripción
						<input type="text" name="description" value="{$edit_template.description|default:''|escape:'html'}" class="pveInput purple">
					</label>

					<div class="pveGrid3" style="margin-bottom:12px;">
						<label class="pveLabel">🔩 Metal
							<input type="number" name="res_metal" min="0" value="{$edit_template.res_metal|default:10000000}" class="pveInput purple">
						</label>
						<label class="pveLabel">💎 Cristal
							<input type="number" name="res_crystal" min="0" value="{$edit_template.res_crystal|default:5000000}" class="pveInput purple">
						</label>
						<label class="pveLabel">⚗️ Deuterio
							<input type="number" name="res_deuterium" min="0" value="{$edit_template.res_deuterium|default:2000000}" class="pveInput purple">
						</label>
					</div>

					<h3 style="color:#88ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(0,224,255,0.3);padding-bottom:4px;">
						🚀 Naves
						<span style="font-size:10px;color:#8899aa;font-weight:400;">(marca + cantidad)</span>
					</h3>
					<div class="tplShipsGrid" style="margin-bottom:12px;">
						{foreach $ships_catalog as $ship}
							{assign var=shipId value=$ship.id}
							{assign var=currentVal value=0}
							{if isset($edit_template.ships_parsed[$shipId])}
								{assign var=currentVal value=$edit_template.ships_parsed[$shipId]}
							{/if}
							<div class="tplShipRow">
								<label>
									<input type="checkbox"
										name="ship_id[]"
										value="{$shipId}"
										{if $currentVal > 0}checked{/if}>
									#{$shipId} {$ship.name}
								</label>
								<input type="number"
									name="ship_count[]"
									min="0"
									value="{$currentVal}"
									class="tplShipRow input">
							</div>
						{/foreach}
					</div>

					<h3 style="color:#88ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(0,224,255,0.3);padding-bottom:4px;">
						🛡️ Defensas
					</h3>
					<div class="tplShipsGrid" style="margin-bottom:12px;">
						{foreach $defenses_catalog as $def}
							{assign var=defId value=$def.id}
							{assign var=currentVal value=0}
							{if isset($edit_template.defenses_parsed[$defId])}
								{assign var=currentVal value=$edit_template.defenses_parsed[$defId]}
							{/if}
							<div class="tplShipRow">
								<label>
									<input type="checkbox"
										name="def_id[]"
										value="{$defId}"
										{if $currentVal > 0}checked{/if}>
									#{$defId} {$def.name}
								</label>
								<input type="number"
									name="def_count[]"
									min="0"
									value="{$currentVal}"
									class="tplShipRow input">
							</div>
						{/foreach}
					</div>

					<h3 style="color:#88ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(0,224,255,0.3);padding-bottom:4px;">
						⏱️ Tiempo de viaje
					</h3>
					<div class="pveGrid4" style="margin-bottom:12px;">
						<label class="pveLabel">Modo
							<select name="travel_mode" class="pveInput purple">
								<option value="instant"   {if $edit_template.travel_mode == 'instant'}selected{/if}>Inmediato</option>
								<option value="random"    {if $edit_template.travel_mode == 'random'}selected{/if}>Aleatorio</option>
								<option value="fixed"     {if $edit_template.travel_mode == 'fixed'}selected{/if}>Fijo</option>
								<option value="scheduled" {if $edit_template.travel_mode == 'scheduled'}selected{/if}>Programado</option>
							</select>
						</label>
						<label class="pveLabel">Mín (min)
							<input type="number" name="travel_min" min="0" value="{$edit_template.travel_min|default:30}" class="pveInput purple">
						</label>
						<label class="pveLabel">Máx (min)
							<input type="number" name="travel_max" min="0" value="{$edit_template.travel_max|default:120}" class="pveInput purple">
						</label>
						<label class="pveLabel">Fijo (min)
							<input type="number" name="travel_fixed" min="0" value="{$edit_template.travel_fixed|default:60}" class="pveInput purple">
						</label>
						<label class="pveLabel">Velocidad %
							<input type="number" name="fleet_speed_pct" min="10" max="500" value="{$edit_template.fleet_speed_pct|default:100}" class="pveInput purple">
						</label>
					</div>

					<h3 style="color:#88ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(0,224,255,0.3);padding-bottom:4px;">
						⚔️ Oleadas
					</h3>
					<div class="pveGrid3" style="margin-bottom:12px;">
						<label class="pveLabel">
							<input type="checkbox" name="waves_enabled" value="1" {if $edit_template.waves_enabled}checked{/if}>
							Activar oleadas
						</label>
						<label class="pveLabel">Número
							<input type="number" name="waves_count" min="1" max="20" value="{$edit_template.waves_count|default:1}" class="pveInput purple">
						</label>
						<label class="pveLabel">Separación (min)
							<input type="number" name="waves_delay_min" min="1" max="1440" value="{$edit_template.waves_delay_min|default:10}" class="pveInput purple">
						</label>
					</div>

					<h3 style="color:#88ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(0,224,255,0.3);padding-bottom:4px;">
						🔄 Regeneración de defensas
					</h3>
					<div class="pveGrid3" style="margin-bottom:12px;">
						<label class="pveLabel">
							<input type="checkbox" name="regen_enabled" value="1" {if $edit_template.regen_enabled}checked{/if}>
							Activar regeneración
						</label>
						<label class="pveLabel">Cada X min
							<input type="number" name="regen_interval_min" min="1" max="1440" value="{$edit_template.regen_interval_min|default:15}" class="pveInput purple">
						</label>
						<label class="pveLabel">Regenera %
							<input type="number" step="0.01" name="regen_pct" min="0" max="100" value="{$edit_template.regen_pct|default:10}" class="pveInput purple">
						</label>
					</div>

					<div class="pveGrid2" style="margin-bottom:12px;">
						<label class="pveLabel">
							<input type="checkbox" name="is_default" value="1" {if $edit_template.is_default}checked{/if}>
							⭐ Marcar como DEFAULT
						</label>
						<label class="pveLabel">
							<input type="checkbox" name="is_active" value="1" {if $edit_template.is_active}checked{/if}>
							✅ Plantilla activa
						</label>
					</div>

					<div style="text-align:center;">
						<button type="submit" class="pveBtn purple">💾 Guardar Plantilla</button>
						<a href="admin.php?page=pveadmin&tab=templates" class="pveBtn ghost">❌ Cancelar</a>
					</div>
				</form>
			</div>

		{else}

			<div style="text-align:right;margin-bottom:10px;">
				<a href="admin.php?page=pveadmin&tab=templates&new=1" class="pveBtn purple">
					➕ Nueva Plantilla
				</a>
			</div>

			{if $templates_list|@count > 0}
				{foreach $templates_list as $tpl}
					<div class="tplCard {if $tpl.is_default}is-default{/if} {if !$tpl.is_active}inactive{/if}">
						<div class="tplCardInfo">
							<div class="tplCardName">
								{if $tpl.is_default}⭐{/if}
								{$tpl.name}
								{if !$tpl.is_active}<span class="pveBadge red">INACTIVA</span>{/if}
							</div>
							<div class="tplCardStats">
								HP×{$tpl.hp_mult} · 
								{$tpl.ships_count} naves · 
								{$tpl.defenses_count} defensas · 
								Viaje {$tpl.travel_min}-{$tpl.travel_max}min
								{if $tpl.waves_enabled} · {$tpl.waves_count} oleadas{/if}
								{if $tpl.regen_enabled} · regen +{$tpl.regen_pct}%{/if}
							</div>
						</div>
						<div class="tplCardActions">
							<a href="admin.php?page=pveadmin&tab=templates&edit_id={$tpl.id}"
							   class="pveBtn small blue" title="Editar">✏️</a>
							<a href="admin.php?page=pveadmin&mode=duplicateTemplate&id={$tpl.id}&tab=templates"
							   class="pveBtn small ghost" title="Duplicar"
							   onclick="return confirm('¿Duplicar plantilla #{$tpl.id}?');">📋</a>
							{if !$tpl.is_default}
								<a href="admin.php?page=pveadmin&mode=setDefaultTemplate&id={$tpl.id}&tab=templates"
								   class="pveBtn small ghost" title="Marcar como default"
								   onclick="return confirm('¿Marcar como default?');">⭐</a>
							{/if}
							{if $tpl.is_active}
								<a href="admin.php?page=pveadmin&mode=toggleTemplate&id={$tpl.id}&active=0&tab=templates"
								   class="pveBtn small ghost" title="Desactivar">⏸️</a>
							{else}
								<a href="admin.php?page=pveadmin&mode=toggleTemplate&id={$tpl.id}&active=1&tab=templates"
								   class="pveBtn small ghost" title="Activar">▶️</a>
							{/if}
							{if !$tpl.is_default}
								<a href="admin.php?page=pveadmin&mode=deleteTemplate&id={$tpl.id}&tab=templates"
								   class="pveBtn small red" title="Eliminar"
								   onclick="return confirm('¿Eliminar plantilla #{$tpl.id}? Esta acción no se puede deshacer.');">🗑️</a>
							{/if}
						</div>
					</div>
				{/foreach}
			{else}
				<p style="text-align:center;color:#8899aa;padding:20px;">
					No hay plantillas. Crea la primera con el botón de arriba.
				</p>
			{/if}

		{/if}

	{/if}

	{if $active_tab == 'empires'}

		<div class="pveCard orange">
			<h2 class="orange">🏛️ Crear Imperios Caídos</h2>
			<form method="POST" action="admin.php?page=pveadmin&mode=spawnEmpires&tab=empires">
				<div class="pveGrid3" style="margin-bottom:8px;">
					<label class="pveLabel">🏰 Cantidad (1-10)
						<input type="number" name="count" min="1" max="10" value="{$config.empire_count|default:1}" class="pveInput orange">
					</label>
					<label class="pveLabel">⏱️ Duración (1-168h)
						<input type="number" name="duration" min="1" max="168" value="{$config.empire_duration_hours|default:24}" class="pveInput orange">
					</label>
					<label class="pveLabel">🎨 Plantilla
						<select name="template_id" class="pveInput orange">
							<option value="0">— Usar default —</option>
							{foreach $templates_list as $tpl}
								{if $tpl.is_active}
									<option value="{$tpl.id}">
										{$tpl.name} {if $tpl.is_default}(default){/if}
									</option>
								{/if}
							{/foreach}
						</select>
					</label>
				</div>
				<button type="submit" class="pveBtn orange">🚀 Crear Imperios</button>
			</form>
		</div>

		<div class="pveCard orange">
			<h2 class="orange">
				🏛️ Imperios Activos
				<span class="pveBadge orange" style="margin-left:6px;">{$empires|@count}</span>
			</h2>

			{if $empires|@count > 0}
				<table class="pveTable">
					<thead class="orange">
						<tr>
							<th>ID</th>
							<th>Nombre</th>
							<th class="center">Coord</th>
							<th class="center">HP</th>
							<th class="center">Ataques</th>
							<th class="center">Ghost</th>
							<th class="center">Fin</th>
							<th class="center">Acción</th>
						</tr>
					</thead>
					<tbody>
						{foreach $empires as $e}
							<tr>
								<td>#{$e.id}</td>
								<td style="color:#ffdd88;font-weight:bold;">{$e.name}</td>
								<td class="center" style="font-size:10px;color:#aabbcc;">
									[{$e.galaxy}:{$e.system}:{$e.planet}]
								</td>
								<td class="center">
									<span style="color:#ffdd88;font-weight:bold;">{$e.hp_fmt}</span>
									<span style="color:#8899aa;">/ {$e.hp_max_fmt}</span>
									<div class="pveHpBar">
										<div class="pveHpFill" style="width:{$e.hp_percent}%;"></div>
									</div>
								</td>
								<td class="center" style="color:#88ccff;">{$e.total_attacks}</td>
								<td class="center" style="font-size:10px;">
									{if $e.has_ghost}
										<span class="pveBadge green">{$e.ghost_label}</span>
									{else}
										<span style="color:#667788;">—</span>
									{/if}
								</td>
								<td class="center" style="font-size:10px;color:#aabbcc;">{$e.end_fmt}</td>
								<td class="center">
									<a href="admin.php?page=pveadmin&mode=destroyEmpire&id={$e.id}&tab=empires"
									   class="pveBtn small red"
									   onclick="return confirm('¿Marcar imperio #{$e.id} como destruido?');">
										💥 Destruir
									</a>
								</td>
							</tr>
						{/foreach}
					</tbody>
				</table>
			{else}
				<p style="text-align:center;color:#8899aa;padding:20px;">
					No hay imperios activos.
				</p>
			{/if}
		</div>

	{/if}

	{if $active_tab == 'crisis'}

		<div class="pveCard purple">
			<h2 class="purple">
				🌌 Crisis Activas / Programadas
				<span class="pveBadge purple" style="margin-left:6px;">{$crisis_list|@count}</span>
			</h2>

			{if $crisis_list|@count > 0}
				<table class="pveTable">
					<thead class="purple">
						<tr>
							<th>ID</th>
							<th>Facción</th>
							<th class="center">Estado</th>
							<th class="center">Oleadas</th>
							<th class="center">Inicio</th>
							<th class="center">Acción</th>
						</tr>
					</thead>
					<tbody>
						{foreach $crisis_list as $c}
							<tr>
								<td>#{$c.id}</td>
								<td>{$c.faction_name}</td>
								<td class="center">{$c.status_label}</td>
								<td class="center" style="color:#dd99ff;font-weight:bold;">{$c.wave_str}</td>
								<td class="center" style="font-size:10px;color:#aabbcc;">{$c.start_fmt}</td>
								<td class="center">
									<a href="admin.php?page=pveadmin&mode=cancelCrisis&id={$c.id}&tab=crisis"
									   class="pveBtn small red"
									   onclick="return confirm('¿Cancelar crisis #{$c.id}?');">
										🛑 Cancelar
									</a>
								</td>
							</tr>
						{/foreach}
					</tbody>
				</table>
			{else}
				<p style="text-align:center;color:#8899aa;padding:20px;">
					No hay crisis activas ni programadas.
				</p>
			{/if}
		</div>

		<div class="scheduleCard">
			<h2>📅 Auto-Programación Mensual de la Crisis</h2>
			<p style="color:#aabbcc;font-size:11px;margin-bottom:14px;">
				Si está activada, el sistema auto-programará una crisis cada mes según el <b>día/hora configurados arriba</b>
				(por defecto: día 25 a las 10:30). Si la desactivas, las crisis solo se crearán cuando tú las actives/programes manualmente.
			</p>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveCrisisAutoSchedule&tab=crisis">

				<label class="scheduleToggleLabel">
					<input type="checkbox" name="crisis_auto_schedule_enabled" value="1" {if $crisis_auto_schedule.enabled}checked{/if}>
					<span style="color:#dd99ff;font-weight:bold;font-size:13px;">
						🌌 Activar auto-programación mensual de la Crisis
					</span>
				</label>

				{if $crisis_auto_schedule.last_month > 0}
					<div class="scheduleNextBox">
						<div class="scheduleLabel">📌 Último mes auto-programado</div>
						<div style="color:#88ffbb;font-family:'Courier New',monospace;font-size:16px;font-weight:bold;">
							{$crisis_auto_schedule.last_month}
						</div>
						<div style="font-size:10px;color:#667788;margin-top:4px;">
							(Formato YYYYMM — sirve para no duplicar crisis en el mismo mes)
						</div>
					</div>
				{else}
					<div class="scheduleNextBox">
						<div class="scheduleLabel">📌 Estado</div>
						<div style="color:#8899aa;font-size:12px;">
							Aún no se ha auto-programado ninguna crisis.
						</div>
					</div>
				{/if}

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn purple">💾 Guardar Auto-Programación</button>
				</div>
			</form>
		</div>

	{/if}

	{if $active_tab == 'boss'}

		{if !$boss_helper_ok}
			<div class="pveFlash error">
				⚠️ El módulo <strong>PVEBossTournamentHelper</strong> no está instalado.
				Sube el archivo <code>includes/classes/PVEBossTournamentHelper.class.php</code> para activar el torneo.
			</div>
		{/if}

		<div class="pveStatsGrid">
			<div class="pveStatBox boss">
				<div class="pveStatLabel">🌌 Torneos Totales</div>
				<div class="pveStatValue">{$boss_stats.total_events|default:0}</div>
			</div>
			<div class="pveStatBox red">
				<div class="pveStatLabel">🔴 Activos</div>
				<div class="pveStatValue">{$boss_stats.total_events_active|default:0}</div>
			</div>
			<div class="pveStatBox purple">
				<div class="pveStatLabel">👻 Fantasmas Totales</div>
				<div class="pveStatValue">{$boss_stats.total_ghosts|default:0}</div>
			</div>
			<div class="pveStatBox green">
				<div class="pveStatLabel">💀 Eliminados</div>
				<div class="pveStatValue">{$boss_stats.total_ghosts_killed|default:0}</div>
			</div>
			<div class="pveStatBox yellow">
				<div class="pveStatLabel">💰 Pool NTX-20 (CUP)</div>
				<div class="pveStatValue">{$boss_stats.total_pool_ntx20|default:0}</div>
			</div>
			<div class="pveStatBox yellow">
				<div class="pveStatLabel">💰 Pool UNTX-20 (QVAPAY)</div>
				<div class="pveStatValue">{$boss_stats.total_pool_untx20|default:0}</div>
			</div>
		</div>

		<div class="pveCleanupCard" style="background: linear-gradient(135deg, rgba(60, 0, 60, 0.4), rgba(40, 0, 40, 0.4)); border-color: rgba(255, 100, 255, 0.35); border-left-color: #cc66ff;">
			<h2 style="color:#ff88ff; border-bottom-color: rgba(255, 100, 255, 0.2);">🧹 Limpieza del Torneo — Forzar Ahora</h2>
			<p style="color:#aabbcc;font-size:11px;margin-bottom:8px;">
				Ejecuta manualmente las 2 capas de limpieza del Torneo del Devorador sin esperar al cron.
				Borra fantasmas huérfanos, registros sin evento, daños viejos y eventos zombie.
			</p>
			<ul class="pveCleanupList" style="color:#aabbcc;">
				<li><b>Capa 2 (huérfanos):</b> fantasmas de eventos cerrados · registros sin evento · daños sin evento · eventos zombie · flotas atascadas</li>
				<li><b>Capa 3 (profunda):</b> fantasmas +30 días · daños +30 días · registros +30 días · eventos +30 días</li>
			</ul>
			<div style="text-align:center;margin-top:10px;">
				<a href="admin.php?page=pveadmin&mode=runBossCleanup&tab=boss"
				   class="pveBtn boss"
				   onclick="return confirm('🧹 ¿Ejecutar limpieza del Torneo AHORA?\n\nSe borrarán residuos huérfanos y datos viejos. Esta acción es segura y no afecta a jugadores activos.');">
					🧹 Limpiar Torneo Ahora
				</a>
			</div>
		</div>

		{if $boss_event}

			<div class="pveCard boss">
				<h2 class="boss">
					🌌 Evento #{$boss_event.id} — {$boss_event.boss_name}
					<span class="bossStatusBadge {$boss_event.status}">
						{if $boss_event.status == 'scheduled'}⏰ Programado
						{elseif $boss_event.status == 'registration'}📝 Registro Abierto
						{elseif $boss_event.status == 'active'}🔴 ACTIVO
						{elseif $boss_event.status == 'finished'}🏁 Finalizado
						{elseif $boss_event.status == 'cancelled'}🛑 Cancelado
						{/if}
					</span>
				</h2>

				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Modo de entrada
						<input type="text" value="{if $boss_event.entry_mode == 'paid'}💰 Pago{else}🆓 Gratis{/if}" class="pveInput boss" readonly>
					</label>
					<label class="pveLabel">Coste BASE NTX-20
						<input type="text" value="{$boss_event.entry_cost_ntx|default:0} NTX" class="pveInput boss" readonly>
					</label>
					<label class="pveLabel">Premio
						<input type="text" value="{$boss_event.prize_type|default:'ntx'|upper}" class="pveInput boss" readonly>
					</label>
					<label class="pveLabel">Fee proyecto
						<input type="text" value="{$boss_event.project_fee_pct|default:5}%" class="pveInput boss" readonly>
					</label>
					<label class="pveLabel">💰 Pool NTX-20 (CUP)
						<input type="text" value="{$boss_event.pool_ntx20|default:0} NTX" class="pveInput boss" readonly style="color:#ffee88;">
					</label>
					<label class="pveLabel">💰 Pool UNTX-20 (QVAPAY)
						<input type="text" value="{$boss_event.pool_untx20|default:0} UNTX" class="pveInput boss" readonly style="color:#88ffff;">
					</label>
					<label class="pveLabel">Duración
						<input type="text" value="{$boss_event.duration_hours|default:48}h" class="pveInput boss" readonly>
					</label>
					<label class="pveLabel">Alianzas
						<input type="text" value="min {$boss_event.min_alliances|default:2} / max {$boss_event.max_alliances|default:20}" class="pveInput boss" readonly>
					</label>
					<label class="pveLabel">Distribución
						<input type="text" value="{$boss_event.winner_distribution|default:'by_contribution'}" class="pveInput boss" readonly>
					</label>
				</div>

				<div class="bossControlBar">
					<span class="label">🎮 Control del Evento:</span>

					{if $boss_event.status == 'scheduled'}
						<a href="admin.php?page=pveadmin&mode=openBossRegistration&event_id={$boss_event.id}&tab=boss"
						   class="pveBtn boss small"
						   onclick="return confirm('¿Abrir registro para el torneo #{$boss_event.id}?');">
							📝 Abrir Registro
						</a>
					{/if}

					{if $boss_event.status == 'registration'}
						<a href="admin.php?page=pveadmin&mode=startBossEvent&event_id={$boss_event.id}&tab=boss"
						   class="pveBtn green small"
						   onclick="return confirm('🚀 ¿INICIAR el torneo AHORA?\n\nSe crearán los fantasmas para todas las alianzas inscritas y recibirán sus coordenadas.');">
							🚀 Iniciar Ahora
						</a>
					{/if}

					{if $boss_event.status == 'active'}
						<a href="admin.php?page=pveadmin&mode=finishBossEvent&event_id={$boss_event.id}&tab=boss"
						   class="pveBtn yellow small"
						   onclick="return confirm('🏁 ¿Finalizar el torneo AHORA?\n\nSe calculará el ganador y se repartirán los premios.');">
							🏁 Finalizar Ahora
						</a>
					{/if}

					{if $boss_event.status == 'scheduled' || $boss_event.status == 'registration' || $boss_event.status == 'active'}
						<a href="admin.php?page=pveadmin&mode=cancelBossEvent&event_id={$boss_event.id}&refund=1&tab=boss"
						   class="pveBtn red small"
						   onclick="return confirm('🛑 ¿CANCELAR el torneo?\n\n{if $boss_event.entry_mode == 'paid'}Se reembolsará a los líderes en su riel (CUP → NTX, QVAPAY → UNTX ×2).{/if}');">
							🛑 Cancelar + Refund
						</a>
					{/if}
				</div>

				<div class="bossHelpText">
					⏰ Registro: {$boss_event.registration_start|date_format:"%d/%m/%Y %H:%M"} → {$boss_event.registration_end|date_format:"%d/%m/%Y %H:%M"}<br>
					⚔️ Combate: {$boss_event.start_time|date_format:"%d/%m/%Y %H:%M"} → {$boss_event.end_time|date_format:"%d/%m/%Y %H:%M"}
					{if $boss_event.status == 'finished'} · Finalizado: {$boss_event.finished_at|date_format:"%d/%m/%Y %H:%M"}{/if}
				</div>
			</div>

			<div class="pveCard boss">
				<h2 class="boss">🏆 Ranking de Alianzas</h2>
				{if $boss_ranking|@count > 0}
					<table class="pveTable">
						<thead class="boss">
							<tr>
								<th class="center">#</th>
								<th>Alianza</th>
								<th class="center">Daño</th>
								<th class="center">% HP</th>
								<th class="center">Fantasmas</th>
								<th class="center">Miembros</th>
								<th class="center">Estado</th>
							</tr>
						</thead>
						<tbody>
							{foreach $boss_ranking as $idx => $r}
								<tr class="boss-row">
									<td class="center" style="color:#ffcc33;font-weight:bold;">{$idx+1}</td>
									<td style="color:#ff88ff;font-weight:bold;">
										[{if $r.ally_tag}{$r.ally_tag}{else}?{/if}] {if $r.ally_name}{$r.ally_name}{else}Alianza #{$r.ally_id}{/if}
									</td>
									<td class="center" style="color:#ffee88;">{$r.total_damage|default:0}</td>
									<td class="center" style="color:#ff88ff;font-weight:bold;">{$r.pct_damage_total|default:0}%</td>
									<td class="center" style="font-size:10px;color:#aabbcc;">
										💀 {$r.ghosts_killed|default:0} / 👻 {$r.ghosts_spawned|default:0}
									</td>
									<td class="center" style="color:#88ddff;">{$r.members_at_spawn|default:0}</td>
									<td class="center">
										{if $r.status == 'winner'}<span class="pveBadge yellow">🏆 Ganador</span>
										{elseif $r.status == 'lost'}<span class="pveBadge ghost" style="color:#8899aa;">Perdió</span>
										{elseif $r.status == 'registered'}<span class="pveBadge cyan">📝 Inscrita</span>
										{elseif $r.status == 'active'}<span class="pveBadge red">⚔️ Luchando</span>
										{elseif $r.status == 'cancelled'}<span class="pveBadge ghost">Cancelada</span>
										{elseif $r.status == 'refunded'}<span class="pveBadge orange">💸 Reembolsada</span>
										{else}{$r.status}{/if}
									</td>
								</tr>
							{/foreach}
						</tbody>
					</table>
				{else}
					<p style="text-align:center;color:#8899aa;padding:20px;">
						No hay alianzas inscritas todavía.
					</p>
				{/if}
			</div>

			<div class="pveCard boss">
				<h2 class="boss">
					👻 Fantasmas del Evento
					<span class="pveBadge boss" style="margin-left:6px;">{$boss_ghosts|@count}</span>
				</h2>
				{if $boss_ghosts|@count > 0}
					<table class="pveTable">
						<thead class="boss">
							<tr>
								<th>ID</th>
								<th>Alianza</th>
								<th class="center">Spawn #</th>
								<th class="center">Coord</th>
								<th class="center">HP</th>
								<th class="center">Fase</th>
								<th class="center">Estado</th>
								<th class="center">Acción</th>
							</tr>
						</thead>
						<tbody>
							{foreach $boss_ghosts as $g}
								{assign var=ghostHpPct value=0}
								{if $g.hp_max > 0}
									{assign var=ghostHpPct value=($g.hp_current / $g.hp_max * 100)|round:1}
								{/if}
								<tr class="boss-row">
									<td>#{$g.id}</td>
									<td style="color:#ff88ff;">{if $g.ally_name}{$g.ally_name}{else}Alianza #{$g.ally_id}{/if}</td>
									<td class="center" style="color:#ffcc33;">#{$g.spawn_number}</td>
									<td class="center" style="font-size:10px;color:#aabbcc;">
										[{$g.galaxy}:{$g.system}:{$g.planet}]
									</td>
									<td class="center">
										<span style="color:#ffdd88;font-weight:bold;">{$g.hp_current}</span>
										<span style="color:#8899aa;">/ {$g.hp_max}</span>
										<div class="pveHpBar boss">
											<div class="pveHpFill" style="width:{$ghostHpPct}%;"></div>
										</div>
									</td>
									<td class="center">
										{if $g.phase == 1}<span class="pveBadge green">I — Acecho</span>
										{elseif $g.phase == 2}<span class="pveBadge orange">II — Enfurecido</span>
										{elseif $g.phase == 3}<span class="pveBadge red">III — Último Aliento</span>
										{else}<span class="pveBadge">?</span>{/if}
									</td>
									<td class="center">
										{if $g.status == 'active'}<span class="pveBadge red">⚔️ Vivo</span>
										{elseif $g.status == 'killed'}<span class="pveBadge green">💀 Eliminado</span>
										{elseif $g.status == 'expired'}<span class="pveBadge ghost">⏰ Expirado</span>
										{else}{$g.status}{/if}
									</td>
									<td class="center">
										{if $g.status == 'active'}
											<a href="admin.php?page=pveadmin&mode=killBossGhostDebug&ghost_id={$g.id}&tab=boss"
											   class="pveBtn small red"
											   onclick="return confirm('💀 ¿Matar el fantasma #{$g.id} (debug)?');">
												💀 Matar
											</a>
										{elseif $g.status == 'killed'}
											<a href="admin.php?page=pveadmin&mode=forceBossRespawn&registration_id={$g.registration_id}&tab=boss"
											   class="pveBtn small cyan"
											   onclick="return confirm('♻️ ¿Forzar respawn para registration #{$g.registration_id}?');">
												♻️ Respawn
											</a>
										{else}
											<span style="color:#667788;">—</span>
										{/if}
									</td>
								</tr>
							{/foreach}
						</tbody>
					</table>
				{else}
					<p style="text-align:center;color:#8899aa;padding:20px;">
						No hay fantasmas en este evento.
					</p>
				{/if}
			</div>

		{else}
			<div class="pveFlash info">
				📭 No hay ningún torneo actualmente. Crea uno nuevo con el formulario de abajo.
			</div>
		{/if}

		<div class="scheduleCard">
			<h2>📅 Programación Automática del Torneo</h2>
			<p style="color:#aabbcc;font-size:11px;margin-bottom:14px;">
				Si está activada, el sistema auto-programará un nuevo torneo cada mes en el <b>día y hora que elijas aquí</b>.
				Esta fecha es cuándo <b>EMPIEZA el torneo activo</b> (los fantasmas se crean y las alianzas pueden atacar).
				El registro se abrirá automáticamente X horas antes y el torneo finalizará X horas después.
			</p>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveBossSchedule&tab=boss">

				<label class="scheduleToggleLabel">
					<input type="checkbox" name="boss_auto_schedule_enabled" value="1" {if $boss_schedule.enabled}checked{/if}>
					<span style="color:#ff88ff;font-weight:bold;font-size:13px;">
						🌌 Activar auto-programación mensual del Torneo
					</span>
				</label>

				<h3 style="color:#ff88ff;font-size:12px;margin:14px 0 8px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					⚔️ Fecha de INICIO del torneo (día del mes)
				</h3>
				<div class="pveGrid3" style="margin-bottom:14px;">
					<label class="pveLabel">📅 Día del mes (1-28)
						<input type="number" name="boss_schedule_day" min="1" max="28" value="{$boss_schedule.day|default:15}" class="pveInput boss">
					</label>
					<label class="pveLabel">🕐 Hora (AM/PM)
						<select name="boss_schedule_hour" class="pveInput boss">
							<option value="0"  {if $boss_schedule.hour == 0}selected{/if}>12 AM</option>
							<option value="1"  {if $boss_schedule.hour == 1}selected{/if}>01 AM</option>
							<option value="2"  {if $boss_schedule.hour == 2}selected{/if}>02 AM</option>
							<option value="3"  {if $boss_schedule.hour == 3}selected{/if}>03 AM</option>
							<option value="4"  {if $boss_schedule.hour == 4}selected{/if}>04 AM</option>
							<option value="5"  {if $boss_schedule.hour == 5}selected{/if}>05 AM</option>
							<option value="6"  {if $boss_schedule.hour == 6}selected{/if}>06 AM</option>
							<option value="7"  {if $boss_schedule.hour == 7}selected{/if}>07 AM</option>
							<option value="8"  {if $boss_schedule.hour == 8}selected{/if}>08 AM</option>
							<option value="9"  {if $boss_schedule.hour == 9}selected{/if}>09 AM</option>
							<option value="10" {if $boss_schedule.hour == 10}selected{/if}>10 AM</option>
							<option value="11" {if $boss_schedule.hour == 11}selected{/if}>11 AM</option>
							<option value="12" {if $boss_schedule.hour == 12}selected{/if}>12 PM</option>
							<option value="13" {if $boss_schedule.hour == 13}selected{/if}>01 PM</option>
							<option value="14" {if $boss_schedule.hour == 14}selected{/if}>02 PM</option>
							<option value="15" {if $boss_schedule.hour == 15}selected{/if}>03 PM</option>
							<option value="16" {if $boss_schedule.hour == 16}selected{/if}>04 PM</option>
							<option value="17" {if $boss_schedule.hour == 17}selected{/if}>05 PM</option>
							<option value="18" {if $boss_schedule.hour == 18}selected{/if}>06 PM</option>
							<option value="19" {if $boss_schedule.hour == 19}selected{/if}>07 PM</option>
							<option value="20" {if $boss_schedule.hour == 20}selected{/if}>08 PM</option>
							<option value="21" {if $boss_schedule.hour == 21}selected{/if}>09 PM</option>
							<option value="22" {if $boss_schedule.hour == 22}selected{/if}>10 PM</option>
							<option value="23" {if $boss_schedule.hour == 23}selected{/if}>11 PM</option>
						</select>
					</label>
					<label class="pveLabel">⏰ Minuto (0-59)
						<input type="number" name="boss_schedule_minute" min="0" max="59" value="{$boss_schedule.minute|default:0}" class="pveInput boss">
					</label>
				</div>

				<div class="scheduleNextBox">
					<div class="scheduleLabel">📅 Próximo inicio del torneo</div>
					<div class="scheduleValue">{$boss_schedule.next_scheduled_fmt|default:'—'}</div>
					<div style="font-size:10px;color:#667788;margin-top:6px;line-height:1.5;">
						💡 El torneo empezará <b>exactamente</b> en la fecha indicada.
						El registro se abre automáticamente <b>{$boss_config.boss_registration_hours|default:24}h antes</b>
						y el torneo finaliza <b>{$boss_config.boss_duration_hours|default:48}h después</b>.
					</div>
				</div>

				{if $boss_schedule.last_month > 0}
					<div class="scheduleNextBox">
						<div class="scheduleLabel">📌 Último mes auto-programado</div>
						<div style="color:#88ffbb;font-family:'Courier New',monospace;font-size:16px;font-weight:bold;">
							{$boss_schedule.last_month}
						</div>
						<div style="font-size:10px;color:#667788;margin-top:4px;">
							(Formato YYYYMM — sirve para no duplicar torneos en el mismo mes)
						</div>
					</div>
				{/if}

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn boss">💾 Guardar Programación</button>
				</div>
			</form>
		</div>

		<div class="pveCard boss">
			<h2 class="boss">🌌 Crear Nuevo Torneo del Devorador</h2>

			<form method="POST" action="admin.php?page=pveadmin&mode=createBossEvent&tab=boss">

				<div class="pveGrid3" style="margin-bottom:12px;">
					<label class="pveLabel">🌌 Nombre del Jefe
						<input type="text" name="boss_name" value="El Devorador Estelar" class="pveInput boss">
					</label>
					<label class="pveLabel">⏱️ Duración (horas)
						<input type="number" name="duration_hours" min="1" max="168" value="48" class="pveInput boss">
					</label>
					<label class="pveLabel">📝 Horas de registro previo
						<input type="number" name="registration_hours" min="1" max="168" value="24" class="pveInput boss">
					</label>
				</div>

				<div class="pveGrid3" style="margin-bottom:12px;">
					<label class="pveLabel">💚 HP por miembro
						<input type="number" name="hp_per_member" min="1000" value="500000" class="pveInput boss">
					</label>
					<label class="pveLabel">💚 HP mínimo total
						<input type="number" name="hp_min" min="100000" value="10000000" class="pveInput boss">
					</label>
					<label class="pveLabel">👥 Min alianzas
						<input type="number" name="min_alliances" min="1" max="50" value="2" class="pveInput boss">
					</label>
					<label class="pveLabel">👥 Max alianzas
						<input type="number" name="max_alliances" min="2" max="100" value="20" class="pveInput boss">
					</label>
				</div>

				<h3 style="color:#ff88ff;font-size:12px;margin:14px 0 6px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					💰 Modo de Inscripción
				</h3>
				<div class="bossEntryModeBox">
					<label id="lbl_entry_free" class="active">
						<input type="radio" name="entry_mode" value="free" checked onchange="toggleBossEntryMode('free')">
						<span style="color:#88ffbb;font-weight:bold;">🆓 Gratis</span>
						<span style="color:#8899aa;font-size:11px;">— premio del admin</span>
					</label>
					<label id="lbl_entry_paid">
						<input type="radio" name="entry_mode" value="paid" onchange="toggleBossEntryMode('paid')">
						<span style="color:#ffcc33;font-weight:bold;">💰 Pago</span>
						<span style="color:#8899aa;font-size:11px;">— pool acumulado</span>
					</label>
				</div>

				<div id="section_paid" class="bossEntrySection hidden">
					<label class="pveLabel" style="max-width:300px;">
						💎 Coste BASE NTX-20 por alianza
						<span class="rielHint cup">CUP paga ×1</span>
						<span class="rielHint qvapay">QVAPAY paga ×2 (UNTX-20)</span>
						<input type="number" name="entry_cost_ntx" min="0" max="1000000" value="50" class="pveInput boss">
					</label>
					<p class="bossHelpText">
						Cada líder paga esta cantidad en su riel (CUP → ntx20 ×1 · QVAPAY → untx20 ×2)
						al inscribir su alianza. Se acumula en el pool del riel correspondiente.
					</p>
					<label class="pveLabel" style="max-width:300px;margin-top:10px;">💸 Fee del proyecto (%)
						<input type="number" name="project_fee_pct" min="0" max="100" value="5" class="pveInput boss">
					</label>
					<p class="bossHelpText">
						Porcentaje del pool que se queda el servidor. El resto va a la alianza ganadora (por riel).
					</p>
				</div>

				<div id="section_free" class="bossEntrySection">
					<div style="margin-top:8px;">
						<span style="color:#ff88ff; font-weight:bold; font-size:12px;">🎁 Recompensas (Deja en 0 el recurso que NO quieras dar)</span>
						<span class="rielHint">Base NTX-20 · QVAPAY recibe ×2 al reclamar</span>
					</div>
					<div class="pveGrid2" style="margin-top:8px;">
						<label class="pveLabel">💎 NTX
							<input type="number" name="prize_ntx" min="0" value="500" class="pveInput boss">
						</label>
						<label class="pveLabel">🌑 Materia Oscura
							<input type="number" name="prize_dark_matter" min="0" value="0" class="pveInput boss">
						</label>
						<label class="pveLabel">🔩 Metal
							<input type="number" name="prize_metal" min="0" value="0" class="pveInput boss">
						</label>
						<label class="pveLabel">💠 Cristal
							<input type="number" name="prize_crystal" min="0" value="0" class="pveInput boss">
						</label>
						<label class="pveLabel">⚗️ Deuterio
							<input type="number" name="prize_deuterium" min="0" value="0" class="pveInput boss">
						</label>
						<label class="pveLabel">
							<input type="checkbox" name="prize_scales_with_allies" value="1">
							📈 Escalar con alianzas inscritas
						</label>
					</div>
				</div>

				<h3 style="color:#ff88ff;font-size:12px;margin:14px 0 6px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					🏆 Distribución del Premio
				</h3>
				<div class="pveGrid3" style="margin-bottom:12px;">
					<label class="pveLabel">Modo de reparto
						<select name="winner_distribution" class="pveInput boss">
							<option value="by_contribution">⚔️ Por contribución (daño)</option>
							<option value="leader">👑 Todo al líder</option>
							<option value="equal">🤝 Equitativo (miembros que atacaron)</option>
						</select>
					</label>
					<label class="pveLabel">—</label>
					<label class="pveLabel">—</label>
				</div>

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn boss">
						🌌 Crear Torneo
					</button>
				</div>
			</form>
		</div>

		<div class="pveCard boss">
			<h2 class="boss">⚙️ Configuración por Defecto del Torneo</h2>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveBossConfig&tab=boss">

				<div class="pveGrid3" style="margin-bottom:12px;">
					<label style="display:flex;align-items:center;gap:8px;padding:8px 10px;background:rgba(255,100,255,0.05);border:1px solid rgba(255,100,255,0.25);border-radius:6px;cursor:pointer;">
						<input type="checkbox" name="pve_boss_enabled" value="1" {if $boss_config.pve_boss_enabled}checked{/if} style="width:16px;height:16px;">
						<span style="color:#ff88ff;font-weight:bold;font-size:12px;">🌌 Torneo del Devorador activado</span>
					</label>
				</div>

				<h3 style="color:#ff88ff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					🎭 Fases del Jefe
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Fase II a % HP
						<input type="number" name="boss_phase2_threshold" min="1" max="99" value="{$boss_config.boss_phase2_threshold|default:70}" class="pveInput boss">
					</label>
					<label class="pveLabel">Fase III a % HP
						<input type="number" name="boss_phase3_threshold" min="1" max="99" value="{$boss_config.boss_phase3_threshold|default:30}" class="pveInput boss">
					</label>
					<label class="pveLabel">Intervalo Fase II (min)
						<input type="number" name="boss_phase2_counter_interval" min="1" max="1440" value="{$boss_config.boss_phase2_counter_interval|default:270}" class="pveInput boss">
					</label>
					<label class="pveLabel">Intervalo Fase III (min)
						<input type="number" name="boss_phase3_counter_interval" min="1" max="1440" value="{$boss_config.boss_phase3_counter_interval|default:240}" class="pveInput boss">
					</label>
				</div>

				<h3 style="color:#ff88ff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					⚔️ Contraataques
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Objetivos por ataque
						<input type="number" name="boss_counter_targets" min="1" max="10" value="{$boss_config.boss_counter_targets|default:1}" class="pveInput boss">
					</label>
					<label class="pveLabel">
						<input type="checkbox" name="boss_counter_skip_offline" value="1" {if $boss_config.boss_counter_skip_offline}checked{/if}>
						No atacar offline
					</label>
					<label class="pveLabel">
						<input type="checkbox" name="boss_counter_avoid_repeat" value="1" {if $boss_config.boss_counter_avoid_repeat}checked{/if}>
						Evitar repetir miembro
					</label>
					<label class="pveLabel">Flota mínima %
						<input type="number" name="boss_counter_min_fleet_pct" min="0" max="100" value="{$boss_config.boss_counter_min_fleet_pct|default:5}" class="pveInput boss">
					</label>
				</div>

				<h3 style="color:#ff88ff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					♻️ Respawn de Fantasmas
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">
						<input type="checkbox" name="boss_respawn_enabled" value="1" {if $boss_config.boss_respawn_enabled}checked{/if}>
						Respawn activado
					</label>
					<label class="pveLabel">Cooldown (min)
						<input type="number" name="boss_respawn_cooldown_min" min="1" max="1440" value="{$boss_config.boss_respawn_cooldown_min|default:5}" class="pveInput boss">
					</label>
					<label class="pveLabel">Máx respawns/alianza
						<input type="number" name="boss_max_respawns_per_ally" min="0" max="100" value="{$boss_config.boss_max_respawns_per_ally|default:0}" class="pveInput boss">
					</label>
					<label class="pveLabel">Bloquear si queda < X horas
						<input type="number" name="boss_respawn_block_last_hours" min="0" max="24" value="{$boss_config.boss_respawn_block_last_hours|default:1}" class="pveInput boss">
					</label>
				</div>

				<h3 style="color:#ff88ff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(255,100,255,0.3);padding-bottom:4px;">
					📋 Defaults para Nuevos Torneos
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Nombre por defecto
						<input type="text" name="boss_default_name" value="{$boss_config.boss_default_name|default:'El Devorador Estelar'}" class="pveInput boss">
					</label>
					<label class="pveLabel">Duración (h)
						<input type="number" name="boss_duration_hours" min="1" max="168" value="{$boss_config.boss_duration_hours|default:48}" class="pveInput boss">
					</label>
					<label class="pveLabel">Registro previo (h)
						<input type="number" name="boss_registration_hours" min="1" max="168" value="{$boss_config.boss_registration_hours|default:24}" class="pveInput boss">
					</label>
					<label class="pveLabel">Modo por defecto
						<select name="boss_default_entry_mode" class="pveInput boss">
							<option value="free" {if $boss_config.boss_default_entry_mode == 'free'}selected{/if}>🆓 Gratis</option>
							<option value="paid" {if $boss_config.boss_default_entry_mode == 'paid'}selected{/if}>💰 Pago</option>
						</select>
					</label>
					<label class="pveLabel">Coste BASE NTX-20 por defecto
						<input type="number" name="boss_default_entry_cost_ntx" min="0" value="{$boss_config.boss_default_entry_cost_ntx|default:50}" class="pveInput boss">
					</label>
					<div style="grid-column: 1 / -1; margin-top: 10px; margin-bottom: 5px; padding: 8px; background: rgba(255,100,255,0.1); border-left: 3px solid #ff88ff; border-radius: 4px;">
						<span style="color:#ff88ff; font-weight:bold; font-size:12px;">🎁 Recompensas del Torneo (Deja en 0 el recurso que NO quieras dar)</span>
						<span class="rielHint">Base NTX-20 · QVAPAY recibe ×2 al reclamar</span>
					</div>
					<label class="pveLabel">💎 NTX
						<input type="number" name="boss_default_prize_ntx" min="0" value="{$boss_config.boss_default_prize_ntx|default:500}" class="pveInput boss">
					</label>
					<label class="pveLabel">🌑 Materia Oscura
						<input type="number" name="boss_default_prize_dark_matter" min="0" value="{$boss_config.boss_default_prize_dark_matter|default:0}" class="pveInput boss">
					</label>
					<label class="pveLabel">🔩 Metal
						<input type="number" name="boss_default_prize_metal" min="0" value="{$boss_config.boss_default_prize_metal|default:0}" class="pveInput boss">
					</label>
					<label class="pveLabel">💠 Cristal
						<input type="number" name="boss_default_prize_crystal" min="0" value="{$boss_config.boss_default_prize_crystal|default:0}" class="pveInput boss">
					</label>
					<label class="pveLabel">⚗️ Deuterio
						<input type="number" name="boss_default_prize_deuterium" min="0" value="{$boss_config.boss_default_prize_deuterium|default:0}" class="pveInput boss">
					</label>
					<label class="pveLabel">HP por miembro
						<input type="number" name="boss_hp_per_member" min="1000" value="{$boss_config.boss_hp_per_member|default:500000}" class="pveInput boss">
					</label>
					<label class="pveLabel">HP mínimo
						<input type="number" name="boss_hp_min" min="100000" value="{$boss_config.boss_hp_min|default:10000000}" class="pveInput boss">
					</label>
					<label class="pveLabel">Fee proyecto (%)
						<input type="number" name="boss_project_fee_pct" min="0" max="100" value="{$boss_config.boss_project_fee_pct|default:5}" class="pveInput boss">
					</label>
					<label class="pveLabel">Distribución
						<select name="boss_winner_distribution" class="pveInput boss">
							<option value="by_contribution" {if $boss_config.boss_winner_distribution == 'by_contribution'}selected{/if}>Por contribución</option>
							<option value="leader" {if $boss_config.boss_winner_distribution == 'leader'}selected{/if}>Al líder</option>
							<option value="equal" {if $boss_config.boss_winner_distribution == 'equal'}selected{/if}>Equitativo</option>
						</select>
					</label>
					<label class="pveLabel">Min alianzas
						<input type="number" name="boss_min_alliances" min="1" max="50" value="{$boss_config.boss_min_alliances|default:2}" class="pveInput boss">
					</label>
					<label class="pveLabel">Max alianzas
						<input type="number" name="boss_max_alliances" min="2" max="100" value="{$boss_config.boss_max_alliances|default:20}" class="pveInput boss">
					</label>
					<label class="pveLabel">Refund al cancelar
						<input type="checkbox" name="boss_refund_on_cancel" value="1" {if $boss_config.boss_refund_on_cancel}checked{/if}>
					</label>
				</div>

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn boss">💾 Guardar Configuración</button>
				</div>
			</form>
		</div>

		{literal}
		<script type="text/javascript">
		function toggleBossEntryMode(mode) {
			var secFree = document.getElementById('section_free');
			var secPaid = document.getElementById('section_paid');
			var lblFree = document.getElementById('lbl_entry_free');
			var lblPaid = document.getElementById('lbl_entry_paid');

			if (mode === 'free') {
				secFree.classList.remove('hidden');
				secPaid.classList.add('hidden');
				lblFree.classList.add('active');
				lblPaid.classList.remove('active');
			} else {
				secFree.classList.add('hidden');
				secPaid.classList.remove('hidden');
				lblFree.classList.remove('active');
				lblPaid.classList.add('active');
			}
		}

		document.addEventListener('DOMContentLoaded', function() {
			var paid = document.querySelector('input[name="entry_mode"][value="paid"]');
			if (paid && paid.checked) toggleBossEntryMode('paid');
			else toggleBossEntryMode('free');
		});
		</script>
		{/literal}

	{/if}

	{* --------------------------------------------------------------
	 *  FIN DE LA PARTE 2 — continúa en la PARTE 3 con:
	 *    - Tab bastion (stats con pools duales + cleanup + evento + ranking + ghosts + waves + schedule + crear + config)
	 *    - Tab rewards (config recompensas crisis + imperio)
	 *    - Tab history
	 *    - Cierre del div + include footer
	 * -------------------------------------------------------------- *}
	 
	 	{if $active_tab == 'bastion'}

		{if !$bastion_helper_ok}
			<div class="pveFlash error">
				⚠️ El módulo <strong>PVEBastionHelper</strong> no está instalado.
				Sube el archivo <code>includes/classes/PVEBastionHelper.class.php</code> para activar el Bastión.
			</div>
		{/if}

		<div class="pveStatsGrid">
			<div class="pveStatBox bastion">
				<div class="pveStatLabel">⚓ Eventos Totales</div>
				<div class="pveStatValue">{$bastion_stats.total_events|default:0}</div>
			</div>
			<div class="pveStatBox red">
				<div class="pveStatLabel">🛡️ Activos</div>
				<div class="pveStatValue">{$bastion_stats.total_events_active|default:0}</div>
			</div>
			<div class="pveStatBox bastion">
				<div class="pveStatLabel">🏰 Bastiones Totales</div>
				<div class="pveStatValue">{$bastion_stats.total_bastions|default:0}</div>
			</div>
			<div class="pveStatBox red">
				<div class="pveStatLabel">💥 Caídos</div>
				<div class="pveStatValue">{$bastion_stats.total_bastions_breached|default:0}</div>
			</div>
			<div class="pveStatBox yellow">
				<div class="pveStatLabel">💰 Pool NTX-20 (CUP)</div>
				<div class="pveStatValue">{$bastion_stats.total_pool_ntx20|default:0}</div>
			</div>
			<div class="pveStatBox yellow">
				<div class="pveStatLabel">💰 Pool UNTX-20 (QVAPAY)</div>
				<div class="pveStatValue">{$bastion_stats.total_pool_untx20|default:0}</div>
			</div>
			<div class="pveStatBox green">
				<div class="pveStatLabel">☠️ Piratas Eliminados</div>
				<div class="pveStatValue">{$bastion_stats.total_pirates_killed|default:0}</div>
			</div>
		</div>

		<div class="pveCleanupCard" style="background: linear-gradient(135deg, rgba(0, 40, 70, 0.4), rgba(0, 20, 40, 0.4)); border-color: rgba(66, 165, 245, 0.35); border-left-color: #66aaff;">
			<h2 style="color:#99ddff; border-bottom-color: rgba(66, 165, 245, 0.2);">🧹 Limpieza del Bastión — Forzar Ahora</h2>
			<p style="color:#aabbcc;font-size:11px;margin-bottom:8px;">
				Ejecuta manualmente las 2 capas de limpieza del Bastión Asediado sin esperar al cron.
				Borra bastiones huérfanos, registros sin evento, contribuciones viejas y eventos zombie.
			</p>
			<ul class="pveCleanupList" style="color:#aabbcc;">
				<li><b>Capa 2 (huérfanos):</b> bastiones de eventos cerrados · registros sin evento · contribuciones sin evento · oleadas sin evento · eventos zombie · flotas atascadas</li>
				<li><b>Capa 3 (profunda):</b> bastiones +30 días · contribuciones +30 días · oleadas +30 días · registros +30 días · eventos +30 días</li>
			</ul>
			<div style="text-align:center;margin-top:10px;">
				<a href="admin.php?page=pveadmin&mode=runBastionCleanup&tab=bastion"
				   class="pveBtn bastion"
				   onclick="return confirm('🧹 ¿Ejecutar limpieza del Bastión AHORA?\n\nSe borrarán residuos huérfanos y datos viejos. Esta acción es segura y no afecta a jugadores activos.');">
					🧹 Limpiar Bastión Ahora
				</a>
			</div>
		</div>

		{if $bastion_event}

			<div class="pveCard bastion">
				<h2 class="bastion">
					⚓ Evento #{$bastion_event.id} — {$bastion_event.bastion_name}
					<span class="bastionStatusBadge {$bastion_event.status}">
						{if $bastion_event.status == 'scheduled'}⏰ Programado
						{elseif $bastion_event.status == 'registration'}📝 Registro Abierto
						{elseif $bastion_event.status == 'active'}🛡️ ACTIVO
						{elseif $bastion_event.status == 'finished'}🏁 Finalizado
						{elseif $bastion_event.status == 'cancelled'}🛑 Cancelado
						{/if}
					</span>
				</h2>

				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Modo de entrada
						<input type="text" value="{if $bastion_event.entry_mode == 'paid'}💰 Pago{else}🆓 Gratis{/if}" class="pveInput bastion" readonly>
					</label>
					<label class="pveLabel">Coste BASE NTX-20
						<input type="text" value="{$bastion_event.entry_cost_ntx|default:0} NTX" class="pveInput bastion" readonly>
					</label>
					<label class="pveLabel">Premio
						<input type="text" value="{$bastion_event.prize_type|default:'ntx'|upper}" class="pveInput bastion" readonly>
					</label>
					<label class="pveLabel">Fee proyecto
						<input type="text" value="{$bastion_event.project_fee_pct|default:5}%" class="pveInput bastion" readonly>
					</label>
					<label class="pveLabel">💰 Pool NTX-20 (CUP)
						<input type="text" value="{$bastion_event.pool_ntx20|default:0} NTX" class="pveInput bastion" readonly style="color:#ffee88;">
					</label>
					<label class="pveLabel">💰 Pool UNTX-20 (QVAPAY)
						<input type="text" value="{$bastion_event.pool_untx20|default:0} UNTX" class="pveInput bastion" readonly style="color:#88ffff;">
					</label>
					<label class="pveLabel">Duración
						<input type="text" value="{$bastion_event.duration_hours|default:48}h" class="pveInput bastion" readonly>
					</label>
					<label class="pveLabel">Alianzas
						<input type="text" value="min {$bastion_event.min_alliances|default:2} / max {$bastion_event.max_alliances|default:20}" class="pveInput bastion" readonly>
					</label>
					<label class="pveLabel">Modo Bastión
						<input type="text" value="{$bastion_event.bastion_mode|default:'standard'|upper}" class="pveInput bastion" readonly>
					</label>
				</div>

				<div class="bastionControlBar">
					<span class="label">🎮 Control del Evento:</span>

					{if $bastion_event.status == 'scheduled'}
						<a href="admin.php?page=pveadmin&mode=openBastionRegistration&event_id={$bastion_event.id}&tab=bastion"
						   class="pveBtn bastion small"
						   onclick="return confirm('¿Abrir registro para el Bastión #{$bastion_event.id}?');">
							📝 Abrir Registro
						</a>
					{/if}

					{if $bastion_event.status == 'registration'}
						<a href="admin.php?page=pveadmin&mode=startBastionEvent&event_id={$bastion_event.id}&tab=bastion"
						   class="pveBtn green small"
						   onclick="return confirm('🚀 ¿INICIAR el Bastión AHORA?\n\nSe crearán los bastiones para todas las alianzas inscritas y recibirán sus coordenadas.');">
							🚀 Iniciar Ahora
						</a>
					{/if}

					{if $bastion_event.status == 'active'}
						<a href="admin.php?page=pveadmin&mode=finishBastionEvent&event_id={$bastion_event.id}&tab=bastion"
						   class="pveBtn yellow small"
						   onclick="return confirm('🏁 ¿Finalizar el Bastión AHORA?\n\nSe calculará el ganador y se repartirán los premios.');">
							🏁 Finalizar Ahora
						</a>
					{/if}

					{if $bastion_event.status == 'scheduled' || $bastion_event.status == 'registration' || $bastion_event.status == 'active'}
						<a href="admin.php?page=pveadmin&mode=cancelBastionEvent&event_id={$bastion_event.id}&refund=1&tab=bastion"
						   class="pveBtn red small"
						   onclick="return confirm('🛑 ¿CANCELAR el Bastión?\n\n{if $bastion_event.entry_mode == 'paid'}Se reembolsará a los líderes en su riel (CUP → NTX, QVAPAY → UNTX ×2).{/if}');">
							🛑 Cancelar + Refund
						</a>
					{/if}
				</div>

				<div class="bossHelpText">
					⏰ Registro: {$bastion_event.registration_start|date_format:"%d/%m/%Y %H:%M"} → {$bastion_event.registration_end|date_format:"%d/%m/%Y %H:%M"}<br>
					🛡️ Asedio: {$bastion_event.start_time|date_format:"%d/%m/%Y %H:%M"} → {$bastion_event.end_time|date_format:"%d/%m/%Y %H:%M"}
					{if $bastion_event.status == 'finished'} · Finalizado: {$bastion_event.finished_at|date_format:"%d/%m/%Y %H:%M"}{/if}
				</div>
			</div>

			<div class="pveCard bastion">
				<h2 class="bastion">🏆 Ranking de Alianzas (por Score)</h2>
				{if $bastion_ranking|@count > 0}
					<table class="pveTable">
						<thead class="bastion">
							<tr>
								<th class="center">#</th>
								<th>Alianza</th>
								<th class="center">Score</th>
								<th class="center">Piratas</th>
								<th class="center">% HP</th>
								<th class="center">Bastiones</th>
								<th class="center">Miembros</th>
								<th class="center">Estado</th>
							</tr>
						</thead>
						<tbody>
							{foreach $bastion_ranking as $idx => $r}
								<tr class="bastion-row">
									<td class="center" style="color:#ffcc33;font-weight:bold;">{$idx+1}</td>
									<td style="color:#99ddff;font-weight:bold;">
										[{if $r.ally_tag}{$r.ally_tag}{else}?{/if}] {if $r.ally_name}{$r.ally_name}{else}Alianza #{$r.ally_id}{/if}
									</td>
									<td class="center" style="color:#ffee88;font-weight:bold;">{$r.score_total|default:0}</td>
									<td class="center" style="font-size:10px;color:#aabbcc;">
										☠️ {$r.pirates_killed|default:0}
										{if $r.boss_pirates_killed > 0}· 💀 {$r.boss_pirates_killed}{/if}
									</td>
									<td class="center" style="color:#88ffbb;font-weight:bold;">{$r.pct_hp_preserved|default:0}%</td>
									<td class="center" style="font-size:10px;">
										🛡️ {$r.bastions_spawned|default:0} / 💥 {$r.bastions_breached|default:0}
									</td>
									<td class="center" style="color:#88ddff;">{$r.members_at_spawn|default:0}</td>
									<td class="center">
										{if $r.status == 'winner'}<span class="pveBadge yellow">🏆 Ganador</span>
										{elseif $r.status == 'lost'}<span class="pveBadge red">💥 Caído</span>
										{elseif $r.status == 'registered'}<span class="pveBadge cyan">📝 Inscrita</span>
										{elseif $r.status == 'active'}<span class="pveBadge green">🛡️ Defendiendo</span>
										{elseif $r.status == 'cancelled'}<span class="pveBadge ghost">Cancelada</span>
										{elseif $r.status == 'refunded'}<span class="pveBadge orange">💸 Reembolsada</span>
										{else}{$r.status}{/if}
									</td>
								</tr>
							{/foreach}
						</tbody>
					</table>
				{else}
					<p style="text-align:center;color:#8899aa;padding:20px;">
						No hay alianzas inscritas todavía.
					</p>
				{/if}
			</div>

			<div class="pveCard bastion">
				<h2 class="bastion">
					⚓ Bastiones del Evento
					<span class="pveBadge bastion" style="margin-left:6px;">{$bastion_ghosts|@count}</span>
				</h2>
				{if $bastion_ghosts|@count > 0}
					<table class="pveTable">
						<thead class="bastion">
							<tr>
								<th>ID</th>
								<th>Alianza</th>
								<th class="center">Spawn #</th>
								<th class="center">Coord</th>
								<th class="center">HP</th>
								<th class="center">Fase</th>
								<th class="center">Estado</th>
								<th class="center">Acción</th>
							</tr>
						</thead>
						<tbody>
							{foreach $bastion_ghosts as $g}
								{assign var=ghostHpPct value=0}
								{if $g.hp_max > 0}
									{assign var=ghostHpPct value=($g.hp_current / $g.hp_max * 100)|round:1}
								{/if}
								<tr class="bastion-row">
									<td>#{$g.id}</td>
									<td style="color:#99ddff;">{if $g.ally_name}{$g.ally_name}{else}Alianza #{$g.ally_id}{/if}</td>
									<td class="center" style="color:#ffcc33;">#{$g.spawn_number}</td>
									<td class="center" style="font-size:10px;color:#aabbcc;">
										[{$g.galaxy}:{$g.system}:{$g.planet}]
									</td>
									<td class="center">
										<span style="color:#88ffbb;font-weight:bold;">{$g.hp_current}</span>
										<span style="color:#8899aa;">/ {$g.hp_max}</span>
										<div class="pveHpBar bastion">
											<div class="pveHpFill" style="width:{$ghostHpPct}%;"></div>
										</div>
									</td>
									<td class="center">
										{if $g.phase == 1}<span class="pveBadge green">I — CALMA</span>
										{elseif $g.phase == 2}<span class="pveBadge yellow">II — OLEADA</span>
										{elseif $g.phase == 3}<span class="pveBadge orange">III — ASEDIO</span>
										{elseif $g.phase == 4}<span class="pveBadge red">IV — INFIERNO</span>
										{else}<span class="pveBadge">?</span>{/if}
									</td>
									<td class="center">
										{if $g.status == 'active'}<span class="pveBadge green">🛡️ Defendiendo</span>
										{elseif $g.status == 'breached'}<span class="pveBadge red">💥 Caído</span>
										{elseif $g.status == 'destroyed'}<span class="pveBadge ghost">🗑️ Destruido</span>
										{elseif $g.status == 'expired'}<span class="pveBadge ghost">⏰ Expirado</span>
										{else}{$g.status}{/if}
									</td>
									<td class="center">
										<span style="color:#667788;">—</span>
									</td>
								</tr>
							{/foreach}
						</tbody>
					</table>
				{else}
					<p style="text-align:center;color:#8899aa;padding:20px;">
						No hay bastiones en este evento.
					</p>
				{/if}
			</div>

			<div class="pveCard bastion">
				<h2 class="bastion">
					🌊 Oleadas Piratas (últimas 40)
					<span class="pveBadge bastion" style="margin-left:6px;">{$bastion_waves|@count}</span>
				</h2>
				{if $bastion_waves|@count > 0}
					<table class="pveTable">
						<thead class="bastion">
							<tr>
								<th>ID</th>
								<th>Alianza</th>
								<th class="center">#</th>
								<th class="center">Fase</th>
								<th class="center">Naves</th>
								<th class="center">Resultado</th>
								<th class="center">Piratas</th>
								<th class="center">Daño</th>
								<th class="center">Llegada</th>
							</tr>
						</thead>
						<tbody>
							{foreach $bastion_waves as $w}
								<tr class="bastion-row">
									<td>#{$w.id}</td>
									<td style="color:#99ddff;">{if $w.ally_name}{$w.ally_name}{else}Alianza #{$w.ally_id}{/if}</td>
									<td class="center" style="color:#ffcc33;font-weight:bold;">
										{$w.wave_number}
										{if $w.is_boss_wave} 💀{/if}
									</td>
									<td class="center">
										{if $w.phase == 'calm'}<span class="pveBadge green">CALMA</span>
										{elseif $w.phase == 'surge'}<span class="pveBadge yellow">OLEADA</span>
										{elseif $w.phase == 'siege'}<span class="pveBadge orange">ASEDIO</span>
										{elseif $w.phase == 'hell'}<span class="pveBadge red">INFIERNO</span>
										{else}{$w.phase|upper}{/if}
									</td>
									<td class="center" style="color:#88ccff;">{$w.total_ships|default:0}</td>
									<td class="center">
										{if $w.result == 'defended'}<span class="pveBadge green">🛡️ Defendida</span>
										{elseif $w.result == 'breached'}<span class="pveBadge red">💥 Superado</span>
										{elseif $w.result == 'partial'}<span class="pveBadge orange">⚠️ Parcial</span>
										{elseif $w.resolved == 0}<span class="pveBadge yellow">⏳ Pendiente</span>
										{else}{$w.result}{/if}
									</td>
									<td class="center" style="font-size:10px;color:#aabbcc;">
										☠️ {$w.pirates_killed|default:0} / 🏴‍☠️ {$w.pirates_survived|default:0}
									</td>
									<td class="center" style="color:#ff8888;">{$w.damage_to_bastion|default:0}</td>
									<td class="center" style="font-size:10px;color:#aabbcc;">
										{if $w.arrival_time}{$w.arrival_time|date_format:"%d/%m %H:%M"}{else}—{/if}
									</td>
								</tr>
							{/foreach}
						</tbody>
					</table>
				{else}
					<p style="text-align:center;color:#8899aa;padding:20px;">
						No hay oleadas registradas todavía.
					</p>
				{/if}
			</div>

		{else}
			<div class="pveFlash info">
				📭 No hay ningún Bastión actualmente. Crea uno nuevo con el formulario de abajo.
			</div>
		{/if}

		<div class="scheduleCard bastion">
			<h2>📅 Programación Automática del Bastión</h2>
			<p style="color:#aabbcc;font-size:11px;margin-bottom:14px;">
				Si está activada, el sistema auto-programará un nuevo Bastión cada mes en el <b>día y hora que elijas aquí</b>.
				Esta fecha es cuándo <b>EMPIEZA el asedio</b> (los bastiones se crean y las alianzas pueden defender).
				El registro se abrirá automáticamente X horas antes y el evento finalizará X horas después.
			</p>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveBastionSchedule&tab=bastion">

				<label class="scheduleToggleLabel bastion">
					<input type="checkbox" name="bastion_auto_schedule_enabled" value="1" {if $bastion_schedule.enabled}checked{/if}>
					<span style="color:#99ddff;font-weight:bold;font-size:13px;">
						⚓ Activar auto-programación mensual del Bastión
					</span>
				</label>

				<h3 style="color:#99ddff;font-size:12px;margin:14px 0 8px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					🛡️ Fecha de INICIO del asedio (día del mes)
				</h3>
				<div class="pveGrid3" style="margin-bottom:14px;">
					<label class="pveLabel">📅 Día del mes (1-28)
						<input type="number" name="bastion_schedule_day" min="1" max="28" value="{$bastion_schedule.day|default:20}" class="pveInput bastion">
					</label>
					<label class="pveLabel">🕐 Hora (AM/PM)
						<select name="bastion_schedule_hour" class="pveInput bastion">
							<option value="0"  {if $bastion_schedule.hour == 0}selected{/if}>12 AM</option>
							<option value="1"  {if $bastion_schedule.hour == 1}selected{/if}>01 AM</option>
							<option value="2"  {if $bastion_schedule.hour == 2}selected{/if}>02 AM</option>
							<option value="3"  {if $bastion_schedule.hour == 3}selected{/if}>03 AM</option>
							<option value="4"  {if $bastion_schedule.hour == 4}selected{/if}>04 AM</option>
							<option value="5"  {if $bastion_schedule.hour == 5}selected{/if}>05 AM</option>
							<option value="6"  {if $bastion_schedule.hour == 6}selected{/if}>06 AM</option>
							<option value="7"  {if $bastion_schedule.hour == 7}selected{/if}>07 AM</option>
							<option value="8"  {if $bastion_schedule.hour == 8}selected{/if}>08 AM</option>
							<option value="9"  {if $bastion_schedule.hour == 9}selected{/if}>09 AM</option>
							<option value="10" {if $bastion_schedule.hour == 10}selected{/if}>10 AM</option>
							<option value="11" {if $bastion_schedule.hour == 11}selected{/if}>11 AM</option>
							<option value="12" {if $bastion_schedule.hour == 12}selected{/if}>12 PM</option>
							<option value="13" {if $bastion_schedule.hour == 13}selected{/if}>01 PM</option>
							<option value="14" {if $bastion_schedule.hour == 14}selected{/if}>02 PM</option>
							<option value="15" {if $bastion_schedule.hour == 15}selected{/if}>03 PM</option>
							<option value="16" {if $bastion_schedule.hour == 16}selected{/if}>04 PM</option>
							<option value="17" {if $bastion_schedule.hour == 17}selected{/if}>05 PM</option>
							<option value="18" {if $bastion_schedule.hour == 18}selected{/if}>06 PM</option>
							<option value="19" {if $bastion_schedule.hour == 19}selected{/if}>07 PM</option>
							<option value="20" {if $bastion_schedule.hour == 20}selected{/if}>08 PM</option>
							<option value="21" {if $bastion_schedule.hour == 21}selected{/if}>09 PM</option>
							<option value="22" {if $bastion_schedule.hour == 22}selected{/if}>10 PM</option>
							<option value="23" {if $bastion_schedule.hour == 23}selected{/if}>11 PM</option>
						</select>
					</label>
					<label class="pveLabel">⏰ Minuto (0-59)
						<input type="number" name="bastion_schedule_minute" min="0" max="59" value="{$bastion_schedule.minute|default:0}" class="pveInput bastion">
					</label>
				</div>

				<div class="scheduleNextBox">
					<div class="scheduleLabel">📅 Próximo inicio del asedio</div>
					<div class="scheduleValue">{$bastion_schedule.next_scheduled_fmt|default:'—'}</div>
					<div style="font-size:10px;color:#667788;margin-top:6px;line-height:1.5;">
						💡 El Bastión empezará <b>exactamente</b> en la fecha indicada.
						El registro se abre automáticamente <b>{$bastion_config.bastion_registration_hours|default:24}h antes</b>
						y el evento finaliza <b>{$bastion_config.bastion_duration_hours|default:48}h después</b>.
					</div>
				</div>

				{if $bastion_schedule.last_month > 0}
					<div class="scheduleNextBox">
						<div class="scheduleLabel">📌 Último mes auto-programado</div>
						<div style="color:#88ffbb;font-family:'Courier New',monospace;font-size:16px;font-weight:bold;">
							{$bastion_schedule.last_month}
						</div>
						<div style="font-size:10px;color:#667788;margin-top:4px;">
							(Formato YYYYMM — sirve para no duplicar bastiones en el mismo mes)
						</div>
					</div>
				{/if}

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn bastion">💾 Guardar Programación</button>
				</div>
			</form>
		</div>

		<div class="pveCard bastion">
			<h2 class="bastion">⚓ Crear Nuevo Bastión Asediado</h2>

			<form method="POST" action="admin.php?page=pveadmin&mode=createBastionEvent&tab=bastion">

				<div class="pveGrid3" style="margin-bottom:12px;">
					<label class="pveLabel">⚓ Nombre del Bastión
						<input type="text" name="bastion_name" value="El Bastión de la Alianza" class="pveInput bastion">
					</label>
					<label class="pveLabel">⏱️ Duración (horas)
						<input type="number" name="duration_hours" min="1" max="168" value="48" class="pveInput bastion">
					</label>
					<label class="pveLabel">📝 Horas de registro previo
						<input type="number" name="registration_hours" min="1" max="168" value="24" class="pveInput bastion">
					</label>
				</div>

				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">💚 HP por miembro
						<input type="number" name="bastion_hp_per_member" min="1000" value="500000" class="pveInput bastion">
					</label>
					<label class="pveLabel">💚 HP mínimo total
						<input type="number" name="bastion_hp_min" min="100000" value="10000000" class="pveInput bastion">
					</label>
					<label class="pveLabel">👥 Min alianzas
						<input type="number" name="min_alliances" min="1" max="50" value="2" class="pveInput bastion">
					</label>
					<label class="pveLabel">👥 Max alianzas
						<input type="number" name="max_alliances" min="2" max="100" value="20" class="pveInput bastion">
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:14px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					💰 Modo de Inscripción
				</h3>
				<div class="bastionEntryModeBox">
					<label id="lbl_bastion_entry_free" class="active">
						<input type="radio" name="entry_mode" value="free" checked onchange="toggleBastionEntryMode('free')">
						<span style="color:#88ffbb;font-weight:bold;">🆓 Gratis</span>
						<span style="color:#8899aa;font-size:11px;">— premio del admin</span>
					</label>
					<label id="lbl_bastion_entry_paid">
						<input type="radio" name="entry_mode" value="paid" onchange="toggleBastionEntryMode('paid')">
						<span style="color:#ffcc33;font-weight:bold;">💰 Pago</span>
						<span style="color:#8899aa;font-size:11px;">— pool acumulado</span>
					</label>
				</div>

				<div id="bastion_section_paid" class="bastionEntrySection hidden">
					<label class="pveLabel" style="max-width:300px;">
						💎 Coste BASE NTX-20 por alianza
						<span class="rielHint cup">CUP paga ×1</span>
						<span class="rielHint qvapay">QVAPAY paga ×2 (UNTX-20)</span>
						<input type="number" name="entry_cost_ntx" min="0" max="1000000" value="50" class="pveInput bastion">
					</label>
					<p class="bossHelpText">
						Cada líder paga esta cantidad en su riel (CUP → ntx20 ×1 · QVAPAY → untx20 ×2)
						al inscribir su alianza. Se acumula en el pool del riel correspondiente.
					</p>
					<label class="pveLabel" style="max-width:300px;margin-top:10px;">💸 Fee del proyecto (%)
						<input type="number" name="project_fee_pct" min="0" max="100" value="5" class="pveInput bastion">
					</label>
					<p class="bossHelpText">
						Porcentaje del pool que se queda el servidor. El resto va a la alianza ganadora (por riel).
					</p>
				</div>

				<div id="bastion_section_free" class="bastionEntrySection">
					<div style="margin-top:8px;">
						<span style="color:#99ddff; font-weight:bold; font-size:12px;">🎁 Recompensas (Deja en 0 el recurso que NO quieras dar)</span>
						<span class="rielHint">Base NTX-20 · QVAPAY recibe ×2 al reclamar</span>
					</div>
					<div class="pveGrid2" style="margin-top:8px;">
						<label class="pveLabel">💎 NTX
							<input type="number" name="prize_ntx" min="0" value="500" class="pveInput bastion">
						</label>
						<label class="pveLabel">🌑 Materia Oscura
							<input type="number" name="prize_dark_matter" min="0" value="0" class="pveInput bastion">
						</label>
						<label class="pveLabel">🔩 Metal
							<input type="number" name="prize_metal" min="0" value="0" class="pveInput bastion">
						</label>
						<label class="pveLabel">💠 Cristal
							<input type="number" name="prize_crystal" min="0" value="0" class="pveInput bastion">
						</label>
						<label class="pveLabel">⚗️ Deuterio
							<input type="number" name="prize_deuterium" min="0" value="0" class="pveInput bastion">
						</label>
						<label class="pveLabel">
							<input type="checkbox" name="prize_scales_with_allies" value="1">
							📈 Escalar con alianzas inscritas
						</label>
					</div>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:14px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					⚙️ Modo del Bastión
				</h3>
				<div class="pveGrid3" style="margin-bottom:12px;">
					<label class="pveLabel">Modo
						<select name="bastion_mode" class="pveInput bastion">
							<option value="standard">⚔️ Estándar</option>
							<option value="hardcore">💀 Hardcore (oleadas más fuertes)</option>
						</select>
					</label>
					<label class="pveLabel">Template (ID, 0=none)
						<input type="number" name="bastion_template_id" min="0" value="0" class="pveInput bastion">
					</label>
					<label class="pveLabel">—</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:14px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					🏆 Distribución del Premio
				</h3>
				<div class="pveGrid3" style="margin-bottom:12px;">
					<label class="pveLabel">Modo de reparto
						<select name="winner_distribution" class="pveInput bastion">
							<option value="by_contribution">⚔️ Por contribución (daño)</option>
							<option value="leader">👑 Todo al líder</option>
							<option value="equal">🤝 Equitativo (miembros que defendieron)</option>
						</select>
					</label>
					<label class="pveLabel">—</label>
					<label class="pveLabel">—</label>
				</div>

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn bastion">
						⚓ Crear Bastión
					</button>
				</div>
			</form>
		</div>

		<div class="pveCard bastion">
			<h2 class="bastion">⚙️ Configuración por Defecto del Bastión</h2>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveBastionConfig&tab=bastion">

				<div class="pveGrid3" style="margin-bottom:12px;">
					<label style="display:flex;align-items:center;gap:8px;padding:8px 10px;background:rgba(66,165,245,0.05);border:1px solid rgba(66,165,245,0.25);border-radius:6px;cursor:pointer;">
						<input type="checkbox" name="pve_bastion_enabled" value="1" {if $bastion_config.pve_bastion_enabled}checked{/if} style="width:16px;height:16px;">
						<span style="color:#99ddff;font-weight:bold;font-size:12px;">⚓ Bastión Asediado activado</span>
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					🎭 Fases por tiempo (horas desde el inicio)
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Fin Fase I — CALMA (h)
						<input type="number" name="bastion_phase_calm_end" min="1" max="72" value="{$bastion_config.bastion_phase_calm_end|default:6}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Fin Fase II — OLEADA (h)
						<input type="number" name="bastion_phase_surge_end" min="1" max="120" value="{$bastion_config.bastion_phase_surge_end|default:24}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Fin Fase III — ASEDIO (h)
						<input type="number" name="bastion_phase_siege_end" min="1" max="168" value="{$bastion_config.bastion_phase_siege_end|default:40}" class="pveInput bastion">
					</label>
					<label class="pveLabel">—</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					⏱️ Intervalo entre oleadas (minutos por fase)
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Calma
						<input type="number" name="bastion_wave_interval_calm" min="1" max="1440" value="{$bastion_config.bastion_wave_interval_calm|default:360}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Oleada
						<input type="number" name="bastion_wave_interval_surge" min="1" max="1440" value="{$bastion_config.bastion_wave_interval_surge|default:180}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Asedio
						<input type="number" name="bastion_wave_interval_siege" min="1" max="1440" value="{$bastion_config.bastion_wave_interval_siege|default:120}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Infierno
						<input type="number" name="bastion_wave_interval_hell" min="1" max="1440" value="{$bastion_config.bastion_wave_interval_hell|default:60}" class="pveInput bastion">
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					🌊 Tiempo de vuelo de los piratas (minutos)
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Mín
						<input type="number" name="bastion_pirate_flight_min" min="1" max="1440" value="{$bastion_config.bastion_pirate_flight_min|default:30}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Máx
						<input type="number" name="bastion_pirate_flight_max" min="1" max="1440" value="{$bastion_config.bastion_pirate_flight_max|default:90}" class="pveInput bastion">
					</label>
					<label class="pveLabel">—</label>
					<label class="pveLabel">—</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					⚔️ Multiplicador de potencia pirata por fase
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Calma ×
						<input type="number" name="bastion_pirate_mult_calm" min="1" max="100" value="{$bastion_config.bastion_pirate_mult_calm|default:1}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Oleada ×
						<input type="number" name="bastion_pirate_mult_surge" min="1" max="100" value="{$bastion_config.bastion_pirate_mult_surge|default:2}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Asedio ×
						<input type="number" name="bastion_pirate_mult_siege" min="1" max="100" value="{$bastion_config.bastion_pirate_mult_siege|default:4}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Infierno ×
						<input type="number" name="bastion_pirate_mult_hell" min="1" max="100" value="{$bastion_config.bastion_pirate_mult_hell|default:8}" class="pveInput bastion">
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					🚀 Composición de la flota pirata base (JSON)
				</h3>
				<div class="pveGrid2" style="margin-bottom:12px;">
					<label class="pveLabel" style="grid-column: span 2;">Flota base (JSON: {ldelim}"id":cantidad{rdelim})
						<input type="text" name="bastion_pirate_base_fleet_json" value="{$bastion_config.bastion_pirate_base_fleet_json|default:'{"204":100,"205":50,"206":25,"207":10}'|escape:'html'}" class="pveInput bastion">
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					💀 Oleadas Jefe (boss pirates)
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Chance Calma %
						<input type="number" name="bastion_boss_pirate_chance_calm" min="0" max="100" value="{$bastion_config.bastion_boss_pirate_chance_calm|default:0}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Chance Oleada %
						<input type="number" name="bastion_boss_pirate_chance_surge" min="0" max="100" value="{$bastion_config.bastion_boss_pirate_chance_surge|default:10}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Chance Asedio %
						<input type="number" name="bastion_boss_pirate_chance_siege" min="0" max="100" value="{$bastion_config.bastion_boss_pirate_chance_siege|default:20}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Chance Infierno %
						<input type="number" name="bastion_boss_pirate_chance_hell" min="0" max="100" value="{$bastion_config.bastion_boss_pirate_chance_hell|default:35}" class="pveInput bastion">
					</label>
				</div>
				<div class="pveGrid2" style="margin-bottom:12px;">
					<label class="pveLabel" style="grid-column: span 2;">Flota boss pirata (JSON)
						<input type="text" name="bastion_boss_pirate_fleet_json" value="{$bastion_config.bastion_boss_pirate_fleet_json|default:'{"204":500,"205":200,"211":50,"213":20}'|escape:'html'}" class="pveInput bastion">
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					🏆 Puntuación
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Puntos por pirata
						<input type="number" name="bastion_score_per_pirate" min="0" value="{$bastion_config.bastion_score_per_pirate|default:100}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Peso % HP preservado
						<input type="number" name="bastion_score_hp_pct_weight" min="0" value="{$bastion_config.bastion_score_hp_pct_weight|default:50}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Puntos por boss pirata
						<input type="number" name="bastion_score_per_boss_pirate" min="0" value="{$bastion_config.bastion_score_per_boss_pirate|default:500}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Ranking top show
						<input type="number" name="bastion_ranking_live_interval" min="1" max="60" value="{$bastion_config.bastion_ranking_live_interval|default:10}" class="pveInput bastion">
					</label>
				</div>

				<h3 style="color:#99ddff;font-size:12px;margin:10px 0 6px;border-bottom:1px solid rgba(66,165,245,0.3);padding-bottom:4px;">
					📋 Defaults para Nuevos Eventos
				</h3>
				<div class="pveGrid4" style="margin-bottom:12px;">
					<label class="pveLabel">Nombre por defecto
						<input type="text" name="bastion_default_name" value="{$bastion_config.bastion_default_name|default:'El Bastión de la Alianza'}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Duración (h)
						<input type="number" name="bastion_duration_hours" min="1" max="168" value="{$bastion_config.bastion_duration_hours|default:48}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Registro previo (h)
						<input type="number" name="bastion_registration_hours" min="1" max="168" value="{$bastion_config.bastion_registration_hours|default:24}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Modo por defecto
						<select name="bastion_default_entry_mode" class="pveInput bastion">
							<option value="free" {if $bastion_config.bastion_default_entry_mode == 'free'}selected{/if}>🆓 Gratis</option>
							<option value="paid" {if $bastion_config.bastion_default_entry_mode == 'paid'}selected{/if}>💰 Pago</option>
						</select>
					</label>
					<label class="pveLabel">Coste BASE NTX-20 por defecto
						<input type="number" name="bastion_default_entry_cost_ntx" min="0" value="{$bastion_config.bastion_default_entry_cost_ntx|default:50}" class="pveInput bastion">
					</label>
					<div style="grid-column: 1 / -1; margin-top: 10px; margin-bottom: 5px; padding: 8px; background: rgba(66,165,245,0.1); border-left: 3px solid #66aaff; border-radius: 4px;">
						<span style="color:#99ddff; font-weight:bold; font-size:12px;">🎁 Recompensas del Bastión (Deja en 0 el recurso que NO quieras dar)</span>
						<span class="rielHint">Base NTX-20 · QVAPAY recibe ×2 al reclamar</span>
					</div>
					<label class="pveLabel">💎 NTX
						<input type="number" name="bastion_default_prize_ntx" min="0" value="{$bastion_config.bastion_default_prize_ntx|default:500}" class="pveInput bastion">
					</label>
					<label class="pveLabel">🌑 Materia Oscura
						<input type="number" name="bastion_default_prize_dark_matter" min="0" value="{$bastion_config.bastion_default_prize_dark_matter|default:0}" class="pveInput bastion">
					</label>
					<label class="pveLabel">🔩 Metal
						<input type="number" name="bastion_default_prize_metal" min="0" value="{$bastion_config.bastion_default_prize_metal|default:0}" class="pveInput bastion">
					</label>
					<label class="pveLabel">💠 Cristal
						<input type="number" name="bastion_default_prize_crystal" min="0" value="{$bastion_config.bastion_default_prize_crystal|default:0}" class="pveInput bastion">
					</label>
					<label class="pveLabel">⚗️ Deuterio
						<input type="number" name="bastion_default_prize_deuterium" min="0" value="{$bastion_config.bastion_default_prize_deuterium|default:0}" class="pveInput bastion">
					</label>
					<label class="pveLabel">HP por miembro
						<input type="number" name="bastion_hp_per_member" min="1000" value="{$bastion_config.bastion_hp_per_member|default:500000}" class="pveInput bastion">
					</label>
					<label class="pveLabel">HP mínimo
						<input type="number" name="bastion_hp_min" min="100000" value="{$bastion_config.bastion_hp_min|default:10000000}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Fee proyecto (%)
						<input type="number" name="bastion_project_fee_pct" min="0" max="100" value="{$bastion_config.bastion_project_fee_pct|default:5}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Distribución
						<select name="bastion_winner_distribution" class="pveInput bastion">
							<option value="by_contribution" {if $bastion_config.bastion_winner_distribution == 'by_contribution'}selected{/if}>Por contribución</option>
							<option value="leader" {if $bastion_config.bastion_winner_distribution == 'leader'}selected{/if}>Al líder</option>
							<option value="equal" {if $bastion_config.bastion_winner_distribution == 'equal'}selected{/if}>Equitativo</option>
						</select>
					</label>
					<label class="pveLabel">Min alianzas
						<input type="number" name="bastion_min_alliances" min="1" max="50" value="{$bastion_config.bastion_min_alliances|default:2}" class="pveInput bastion">
					</label>
					<label class="pveLabel">Max alianzas
						<input type="number" name="bastion_max_alliances" min="2" max="100" value="{$bastion_config.bastion_max_alliances|default:20}" class="pveInput bastion">
					</label>
					<label class="pveLabel">
						<input type="checkbox" name="bastion_refund_on_cancel" value="1" {if $bastion_config.bastion_refund_on_cancel}checked{/if}>
						Refund al cancelar
					</label>
					<label class="pveLabel">
						<input type="checkbox" name="bastion_ships_return_on_end" value="1" {if $bastion_config.bastion_ships_return_on_end}checked{/if}>
						Devolver naves al final
					</label>
				</div>

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn bastion">💾 Guardar Configuración</button>
				</div>
			</form>
		</div>

		{literal}
		<script type="text/javascript">
		function toggleBastionEntryMode(mode) {
			var secFree = document.getElementById('bastion_section_free');
			var secPaid = document.getElementById('bastion_section_paid');
			var lblFree = document.getElementById('lbl_bastion_entry_free');
			var lblPaid = document.getElementById('lbl_bastion_entry_paid');

			if (mode === 'free') {
				secFree.classList.remove('hidden');
				secPaid.classList.add('hidden');
				lblFree.classList.add('active');
				lblPaid.classList.remove('active');
			} else {
				secFree.classList.add('hidden');
				secPaid.classList.remove('hidden');
				lblFree.classList.remove('active');
				lblPaid.classList.add('active');
			}
		}

		document.addEventListener('DOMContentLoaded', function() {
			var paid = document.querySelector('input[name="entry_mode"][value="paid"]');
			if (paid && paid.checked) toggleBastionEntryMode('paid');
			else toggleBastionEntryMode('free');
		});
		</script>
		{/literal}

	{/if}

	{if $active_tab == 'rewards'}

		<div class="pveCard yellow">
			<h2 class="yellow">🎁 Configuración de Recompensas</h2>
			<p style="color:#8899aa;font-size:11px;margin-bottom:14px;">
				Configura qué reciben los jugadores al sobrevivir a una crisis o al destruir un imperio.
				<span class="rielHint">Los montos NTX son BASE NTX-20 · QVAPAY recibe ×2 al reclamar (UNTX-20).</span>
			</p>

			<form method="POST" action="admin.php?page=pveadmin&mode=saveRewards&tab=rewards">

				<h3 style="color:#dd99ff;font-size:13px;margin:10px 0 8px;border-bottom:1px solid rgba(139,92,246,0.3);padding-bottom:6px;">
					🌌 Crisis de Fin de Mes
				</h3>

				<div class="rewardsBox">
					<p style="color:#aabbcc;font-size:11px;margin-bottom:10px;">
						<b>¿Qué recibe el jugador al sobrevivir a la crisis?</b>
					</p>

					<div class="rewardsRadioRow">
						<label id="lbl_type_ntx" class="{if $rewards_config.crisis_reward_type == 'ntx'}active{/if}">
							<input type="radio" name="crisis_reward_type" value="ntx"
								{if $rewards_config.crisis_reward_type == 'ntx'}checked{/if}
								onchange="toggleRewardType('ntx')">
							<span style="color:#ffee88;font-weight:bold;">💎 NTX-20</span>
							<span style="color:#8899aa;font-size:11px;">— moneda premium</span>
						</label>
						<label id="lbl_type_res" class="{if $rewards_config.crisis_reward_type == 'resources'}active{/if}">
							<input type="radio" name="crisis_reward_type" value="resources"
								{if $rewards_config.crisis_reward_type == 'resources'}checked{/if}
								onchange="toggleRewardType('resources')">
							<span style="color:#88ffbb;font-weight:bold;">💰 Recursos</span>
							<span style="color:#8899aa;font-size:11px;">— metal / cristal / deuterio</span>
						</label>
					</div>

					<div id="section_ntx" class="rewardsSection {if $rewards_config.crisis_reward_type != 'ntx'}hidden{/if}">
						<h4 style="color:#ffee88;font-size:12px;margin:0 0 8px;">
							💎 Cantidad de NTX-20 (BASE)
							<span class="rielHint cup">CUP recibe ×1</span>
							<span class="rielHint qvapay">QVAPAY recibe ×2 (UNTX-20)</span>
						</h4>
						<label class="pveLabel">NTX BASE por jugador
							<input type="number" name="crisis_reward_ntx" min="0" max="10000"
								value="{$rewards_config.crisis_reward_ntx|default:5}"
								class="pveInput yellow">
						</label>
						<p style="color:#8899aa;font-size:10px;margin-top:6px;">
							Ejemplo: si vale 10 y sobreviven 3 jugadores → CUP recibe 10 NTX cada uno · QVAPAY recibe 20 UNTX cada uno.
						</p>
					</div>

					<div id="section_res" class="rewardsSection {if $rewards_config.crisis_reward_type != 'resources'}hidden{/if}">
						<h4 style="color:#88ffbb;font-size:12px;margin:0 0 8px;">💰 Cantidad de recursos</h4>
						<div class="pveGrid3">
							<label class="pveLabel">🔩 Metal
								<input type="number" name="crisis_reward_metal" min="0"
									value="{$rewards_config.crisis_reward_metal|default:0}"
									class="pveInput green">
							</label>
							<label class="pveLabel">💎 Cristal
								<input type="number" name="crisis_reward_crystal" min="0"
									value="{$rewards_config.crisis_reward_crystal|default:0}"
									class="pveInput green">
							</label>
							<label class="pveLabel">⚗️ Deuterio
								<input type="number" name="crisis_reward_deuterium" min="0"
									value="{$rewards_config.crisis_reward_deuterium|default:0}"
									class="pveInput green">
							</label>
						</div>
					</div>

					<p style="color:#aabbcc;font-size:11px;margin:14px 0 8px;">
						<b>¿Cómo se reparte entre los supervivientes?</b>
					</p>
					<div class="rewardsRadioRow">
						<label id="lbl_split_pp" class="{if $rewards_config.crisis_reward_split == 'per_player'}active{/if}">
							<input type="radio" name="crisis_reward_split" value="per_player"
								{if $rewards_config.crisis_reward_split == 'per_player'}checked{/if}
								onchange="toggleSplit('per_player')">
							<span style="color:#88ddff;font-weight:bold;">👥 Por jugador</span>
							<span style="color:#8899aa;font-size:11px;">— cada uno recibe el total</span>
						</label>
						<label id="lbl_split_sh" class="{if $rewards_config.crisis_reward_split == 'shared'}active{/if}">
							<input type="radio" name="crisis_reward_split" value="shared"
								{if $rewards_config.crisis_reward_split == 'shared'}checked{/if}
								onchange="toggleSplit('shared')">
							<span style="color:#ffaa66;font-weight:bold;">🔀 Compartido</span>
							<span style="color:#8899aa;font-size:11px;">— se divide entre todos</span>
						</label>
					</div>

					<p id="split_hint_pp" style="color:#88ddff;font-size:10px;margin-top:6px;{if $rewards_config.crisis_reward_split != 'per_player'}display:none;{/if}">
						💡 Cada superviviente recibe la cantidad COMPLETA.
					</p>
					<p id="split_hint_sh" style="color:#ffaa66;font-size:10px;margin-top:6px;{if $rewards_config.crisis_reward_split != 'shared'}display:none;{/if}">
						💡 La cantidad se DIVIDE entre el número de supervivientes.
					</p>
				</div>

				<h3 style="color:#ffaa66;font-size:13px;margin:20px 0 8px;border-bottom:1px solid rgba(251,191,36,0.3);padding-bottom:6px;">
					🏛️ Imperio Caído
				</h3>

				<div class="rewardsBox">
					<p style="color:#aabbcc;font-size:11px;margin-bottom:10px;">
						<b>Al destruir un imperio</b>, se reparten los recursos del planeta fantasma entre los atacantes,
						proporcionalmente al daño hecho por cada uno.
					</p>

					<label class="pveLabel" style="max-width:300px;">💰 % del botín a repartir
						<input type="number" name="empire_loot_pct" min="0" max="100"
							value="{$rewards_config.empire_loot_pct|default:100}"
							class="pveInput orange">
					</label>
					<p style="color:#8899aa;font-size:10px;margin-top:6px;">
						<b>0</b> = nadie recibe recursos · <b>50</b> = la mitad · <b>100</b> = todo el botín.<br>
						El resto se pierde. Los recursos van al <b>planeta principal</b> del jugador.
					</p>
				</div>

				<div style="text-align:center;margin-top:16px;">
					<button type="submit" class="pveBtn yellow">💾 Guardar Recompensas</button>
				</div>
			</form>
		</div>

		{literal}
		<script type="text/javascript">
		function toggleRewardType(type) {
			var secNtx = document.getElementById('section_ntx');
			var secRes = document.getElementById('section_res');
			var lblNtx = document.getElementById('lbl_type_ntx');
			var lblRes = document.getElementById('lbl_type_res');

			if (type === 'ntx') {
				secNtx.classList.remove('hidden');
				secRes.classList.add('hidden');
				lblNtx.classList.add('active');
				lblRes.classList.remove('active');
			} else {
				secNtx.classList.add('hidden');
				secRes.classList.remove('hidden');
				lblNtx.classList.remove('active');
				lblRes.classList.add('active');
			}
		}

		function toggleSplit(mode) {
			var lblPp = document.getElementById('lbl_split_pp');
			var lblSh = document.getElementById('lbl_split_sh');
			var hintPp = document.getElementById('split_hint_pp');
			var hintSh = document.getElementById('split_hint_sh');

			if (mode === 'per_player') {
				lblPp.classList.add('active');
				lblSh.classList.remove('active');
				hintPp.style.display = 'block';
				hintSh.style.display = 'none';
			} else {
				lblPp.classList.remove('active');
				lblSh.classList.add('active');
				hintPp.style.display = 'none';
				hintSh.style.display = 'block';
			}
		}

		document.addEventListener('DOMContentLoaded', function() {
			var typeNtx = document.querySelector('input[name="crisis_reward_type"][value="ntx"]');
			var splitPp = document.querySelector('input[name="crisis_reward_split"][value="per_player"]');
			if (typeNtx && typeNtx.checked)      toggleRewardType('ntx');
			if (typeNtx && !typeNtx.checked)     toggleRewardType('resources');
			if (splitPp && splitPp.checked)      toggleSplit('per_player');
			if (splitPp && !splitPp.checked)     toggleSplit('shared');
		});
		</script>
		{/literal}

	{/if}

	{if $active_tab == 'history'}

		<div class="pveCard green">
			<h2 class="green">📜 Historial — Últimas crisis finalizadas</h2>

			{if $history|@count > 0}
				<table class="pveTable">
					<thead class="green">
						<tr>
							<th>ID</th>
							<th>Facción</th>
							<th class="center">Oleadas</th>
							<th class="center">Jugadores</th>
							<th class="center">Finalizó</th>
						</tr>
					</thead>
					<tbody>
						{foreach $history as $h}
							<tr>
								<td>#{$h.id}</td>
								<td>{$h.faction_name}</td>
								<td class="center" style="color:#aabbcc;">{$h.total_waves}</td>
								<td class="center" style="color:#88ffbb;">{$h.players_affected}</td>
								<td class="center" style="font-size:10px;color:#aabbcc;">{$h.end_fmt}</td>
							</tr>
						{/foreach}
					</tbody>
				</table>
			{else}
				<p style="text-align:center;color:#8899aa;padding:20px;">
					No hay crisis finalizadas todavía.
				</p>
			{/if}
		</div>

	{/if}

	<p style="text-align:center;font-size:10px;color:#8899aa;margin-top:16px;">
		🚧 Panel Admin PvE — AstroIO v4.3 · Crisis + Imperio + Torneo del Devorador + Bastión Asediado · Dual-Riel NTX-20 / UNTX-20 · 12h AM/PM
	</p>
</div>

{include file="overall_footer.tpl"}