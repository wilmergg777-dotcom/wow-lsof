{* ==========================================================
   ASTROIO — Shared Information: Production v3.9
   FIX v3.9:
     - Eliminada la descripción duplicada (ya se muestra en page.information.default.tpl).
     - Eliminado el texto [file name] / [file content].
   ========================================================== *}

{$count = count($productionTable.usedResource)}

<style>
/* ─── RESET GLOBAL ─── */
.astroinfopop_prod,
.astroinfopop_prod *,
.astroinfopop_prod *::before,
.astroinfopop_prod *::after {
    box-sizing: border-box;
}

/* ─── TABLA EXTERNA (wrapper) ─── */
.astroinfopop_prod {
    width: 100%;
    background: transparent !important;
    border: none !important;
    margin-top: 12px;
    font-family: 'Segoe UI', Arial, sans-serif;
    border-collapse: collapse;
}
.astroinfopop_prod_outer_row {
    background: transparent !important;
}
.astroinfopop_prod_outer_cell {
    background: transparent !important;
    border: none !important;
    padding: 0 !important;
}

/* ─── Tabla interna ─── */
.astroinfopop_prod_inner {
    width: 100%;
    background: rgba(15, 23, 42, 0.7) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(0, 224, 255, 0.25) !important;
    border-collapse: collapse;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

/* ─── Cabecera principal ─── */
.astroinfopop_prod_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroinfopop_prod_th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    padding: 8px 10px !important;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    font-weight: 700;
    text-align: center;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroinfopop_prod_th_level {
    width: 60px;
    text-align: left;
}
.astroinfopop_prod_th_resource {
    text-align: center;
}

/* ─── Sub-cabecera ─── */
.astroinfopop_prod_subheader {
    background: rgba(0, 224, 255, 0.08) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astroinfopop_prod_subheader .astroinfopop_prod_th {
    background: rgba(0, 224, 255, 0.08) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: var(--accent-cyan) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.3) !important;
    font-size: 10px;
    padding: 6px 8px !important;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroinfopop_prod_th_empty {
    text-align: left;
}

/* ─── Filas de datos ─── */
.astroinfopop_prod_row {
    background: transparent !important;
}
.astroinfopop_prod_td {
    color: var(--text-main) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08) !important;
    padding: 6px 10px !important;
    font-size: 11.5px;
    vertical-align: middle;
    transition: 0.2s ease;
}
.astroinfopop_prod_row:hover .astroinfopop_prod_td {
    background: rgba(0, 224, 255, 0.04);
}

/* ─── Nivel ─── */
.astroinfopop_prod_level_cell {
    text-align: left;
}
.astroinfopop_prod_level {
    color: var(--text-main);
    font-weight: 500;
    font-family: 'Courier New', monospace;
}
.astroinfopop_prod_level_current {
    color: var(--accent-red) !important;
    font-weight: 700;
    text-shadow: 0 0 8px rgba(239, 68, 68, 0.5);
}

/* ─── Celdas de valores ─── */
.astroinfopop_prod_value_cell,
.astroinfopop_prod_diff_cell {
    text-align: center;
}
.astroinfopop_prod_value,
.astroinfopop_prod_diff {
    font-weight: 700;
    font-size: 11.5px;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    display: inline-block;
    max-width: 100%;
}

/* Producción positiva / negativa / cero */
.astroinfopop_prod_value_pos,
.astroinfopop_prod_diff_pos {
    color: var(--accent-green) !important;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.4);
}
.astroinfopop_prod_value_neg,
.astroinfopop_prod_diff_neg {
    color: var(--accent-red) !important;
    text-shadow: 0 0 6px rgba(239, 68, 68, 0.4);
}
.astroinfopop_prod_value_zero,
.astroinfopop_prod_diff_zero {
    color: var(--text-muted) !important;
}

/* ─── RESPONSIVE ─── */
@media (max-width: 1200px) {
    .astroinfopop_prod_th,
    .astroinfopop_prod_td {
        padding: 6px 6px !important;
    }
    .astroinfopop_prod_value,
    .astroinfopop_prod_diff {
        font-size: 10.5px;
    }
}

@media (max-width: 720px) {
    .astroinfopop_prod {
        margin-top: 2px;
        width: 100%;
    }
    .astroinfopop_prod_inner {
        border-radius: 6px;
        table-layout: fixed;
        width: 100%;
    }
    .astroinfopop_prod_th {
        font-size: 8px !important;
        padding: 3px 1px !important;
        letter-spacing: 0 !important;
        line-height: 1.1 !important;
    }
    .astroinfopop_prod_subheader .astroinfopop_prod_th {
        font-size: 7px !important;
        padding: 2px 1px !important;
        line-height: 1.1 !important;
    }
    .astroinfopop_prod_td {
        font-size: 8px !important;
        padding: 2px 1px !important;
        line-height: 1.15 !important;
    }
    .astroinfopop_prod_th_level,
    .astroinfopop_prod_level_cell {
        width: 24px !important;
        padding-left: 3px !important;
    }
    .astroinfopop_prod_value,
    .astroinfopop_prod_diff {
        font-size: 8px !important;
        padding: 0 !important;
    }
    .astroinfopop_prod_outer_cell {
        padding: 0 !important;
    }
}
</style>

{* ====== TABLA DE PRODUCCIÓN (SOLO TABLA) ====== *}
<table class="astroinfopop_prod">
    <tbody>
        <tr class="astroinfopop_prod_outer_row">
            <td colspan="2" class="astroinfopop_prod_outer_cell">

                <table class="astroinfopop_prod_inner">
                    <thead>
                        <tr class="astroinfopop_prod_header">
                            <th class="astroinfopop_prod_th astroinfopop_prod_th_level">{$LNG.in_level}</th>
                            {foreach $productionTable.usedResource as $resourceID}
                            <th class="astroinfopop_prod_th astroinfopop_prod_th_resource" colspan="2">{$LNG.tech.$resourceID}</th>
                            {/foreach}
                        </tr>

                        <tr class="astroinfopop_prod_subheader">
                            <th class="astroinfopop_prod_th astroinfopop_prod_th_empty">&nbsp;</th>
                            {foreach $productionTable.usedResource as $resourceID}
                            <th class="astroinfopop_prod_th astroinfopop_prod_th_ph">{$LNG.in_prod_p_hour}</th>
                            <th class="astroinfopop_prod_th astroinfopop_prod_th_diff">{$LNG.in_difference}</th>
                            {/foreach}
                        </tr>
                    </thead>

                    <tbody>
                        {foreach $productionTable.production as $elementLevel => $productionData}
                        <tr class="astroinfopop_prod_row">
                            <td class="astroinfopop_prod_td astroinfopop_prod_level_cell">
                                <span class="astroinfopop_prod_level{if $CurrentLevel == $elementLevel} astroinfopop_prod_level_current{/if}">{$elementLevel}</span>
                            </td>

                            {foreach $productionData as $resourceID => $production}
                            {$productionDiff = $production - $productionTable.production.$CurrentLevel.$resourceID}

                            <td class="astroinfopop_prod_td astroinfopop_prod_value_cell">
                                <span class="astroinfopop_prod_value {if $production > 0}astroinfopop_prod_value_pos{elseif $production < 0}astroinfopop_prod_value_neg{else}astroinfopop_prod_value_zero{/if}">{$production|number}</span>
                            </td>

                            <td class="astroinfopop_prod_td astroinfopop_prod_diff_cell">
                                <span class="astroinfopop_prod_diff {if $productionDiff > 0}astroinfopop_prod_diff_pos{elseif $productionDiff < 0}astroinfopop_prod_diff_neg{else}astroinfopop_prod_diff_zero{/if}">{$productionDiff|number}</span>
                            </td>
                            {/foreach}
                        </tr>
                        {/foreach}
                    </tbody>
                </table>

            </td>
        </tr>
    </tbody>
</table>