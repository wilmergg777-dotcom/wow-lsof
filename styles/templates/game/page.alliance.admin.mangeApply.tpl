{block name="title" prepend}{$LNG.lm_alliance}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Admin · Solicitudes
   Prefijo: .astroalama_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Tabla con header púrpura + hover
     - Wrapper padding 15px
     - foreach, foreachelse, links, colspan, Smarty intactos
     - 🆕 v3.1: Aviso visual del límite máximo de 7 miembros.
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

.astroalama_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalama_panel {
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

.astroalama_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalama_table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    font-size: 10.5px;
    color: var(--text-main);
}

.astroalama_table tr > th {
    background: linear-gradient(135deg, rgba(76, 29, 149, 0.85), rgba(109, 40, 217, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-purple);
    color: #ffffff;
    padding: 6px 10px;
    text-align: left;
    font-weight: 700;
    text-transform: uppercase;
    font-size: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroalama_table tr > td {
    padding: 6px 10px;
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
    height: 24px;
    vertical-align: middle;
    color: var(--text-main);
}

.astroalama_table tr:hover {
    background: rgba(139, 92, 246, 0.06);
}

/* Anchos fijos por columna */
.astroalama_table tr > th:nth-child(1) { width: 60%; }
.astroalama_table tr > th:nth-child(2) { width: 40%; text-align: center; }
.astroalama_table tr > td:nth-child(2) { text-align: center; }

/* Enlaces (candidato y fecha) */
.astroalama_table a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalama_table a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

/* Fila vacía */
.astroalama_empty {
    color: var(--text-muted);
    font-style: italic;
    text-align: center;
    padding: 12px;
}

/* Fila "Volver" */
.astroalama_table tr > th[colspan="2"] {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-top: 1px solid var(--accent-cyan);
    border-bottom: none;
    text-align: center;
    padding: 8px 10px;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 1px;
}
.astroalama_table tr > th[colspan="2"] a {
    color: #00e0ff;
    text-decoration: none;
    transition: 0.2s ease;
}
.astroalama_table tr > th[colspan="2"] a:hover {
    color: #ffffff;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.7);
}

@media (max-width: 480px) {
    .astroalama_wrap { padding: 10px; }
    .astroalama_panel { padding: 12px; }
    .astroalama_table { font-size: 10px; }
    .astroalama_table tr > td { padding: 5px 8px; }
}
</style>

<div class="astroalama_wrap">
<div class="astroalama_panel">

    <div class="astroalama_title">{$LNG.al_request_list}</div>
    
    <div style="background: rgba(251, 191, 36, 0.1); border: 1px solid #fbbf24; border-left: 4px solid #fbbf24; border-radius: 8px; padding: 10px; margin-bottom: 15px; color: #fbbf24; font-size: 11px; font-weight: 600; text-align: center;">
        ⚠️ Recuerda: El límite máximo de miembros de la alianza es de 7.
    </div>

    <table class="astroalama_table">
        <tr>
            <th>{$LNG.al_candidate}</th>
            <th>{$LNG.al_request_date}</th>
        </tr>
        {foreach $applyList as $applyRow}
        <tr>
            <td><a href="game.php?page=alliance&amp;mode=admin&amp;action=detailApply&amp;id={$applyRow.id}">{$applyRow.username}</a></td>
            <td><a href="game.php?page=alliance&amp;mode=admin&amp;action=detailApply&amp;id={$applyRow.id}">{$applyRow.time}</a></td>
        </tr>
        {foreachelse}
        <tr>
            <td colspan="2" class="astroalama_empty">{$LNG.al_no_requests}</td>
        </tr>
        {/foreach}
        <tr>
            <th colspan="2"><a href="game.php?page=alliance">{$LNG.al_back}</a></th>
        </tr>
    </table>

</div>
</div>

{/block}