{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Selección (crear/buscar)
   Prefijo: .astroalcs_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-cajas 10px)
     - Sub-cajas con borde cyan sutil + hover
     - Wrapper padding 15px
     - href, Smarty y clases funcionales intactos
   ═══════════════════════════════════════════════ *}

<style>
/* ====== Variables globales ====== */
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

.astroalcs_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalcs_panel {
    display: inline-block;
    text-align: left;
    width: 700px;
    max-width: 100%;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    font-size: 11px;
    color: var(--text-main);
}

.astroalcs_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalcs_grid {
    width: 100%;
    border-collapse: separate;
    border-spacing: 10px 0;
}

.astroalcs_grid td {
    width: 50%;
    vertical-align: middle;
    text-align: center;
    padding: 16px 12px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    transition: 0.25s ease;
}

.astroalcs_grid td:hover {
    background: rgba(139, 92, 246, 0.08);
    border-color: rgba(139, 92, 246, 0.5);
    box-shadow: 0 0 16px rgba(139, 92, 246, 0.35);
    transform: translateY(-3px);
}

.astroalcs_grid td a {
    display: block;
    color: #00e0ff;
    text-decoration: none;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 500;
    transition: 0.25s ease;
}
.astroalcs_grid td a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.8);
}

@media (max-width: 480px) {
    .astroalcs_wrap { padding: 10px; }
    .astroalcs_panel { padding: 12px; }
    .astroalcs_grid { border-spacing: 6px 0; }
    .astroalcs_grid td { padding: 12px 8px; }
    .astroalcs_grid td a { font-size: 11px; }
}
</style>

<div class="astroalcs_wrap">
<div class="astroalcs_panel">

    <div class="astroalcs_title">{$LNG.al_alliance}</div>

    <table class="astroalcs_grid">
        <tr>
            <td><a href="game.php?page=alliance&amp;mode=create">{$LNG.al_alliance_make}</a></td>
            <td><a href="game.php?page=alliance&amp;mode=search">{$LNG.al_alliance_search}</a></td>
        </tr>
    </table>

</div>
</div>

{/block}