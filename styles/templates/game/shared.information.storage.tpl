{* ==========================================================
   ASTROIO — Shared Information: Storage v3.1
   Estilo unificado (glassmorphism + acento cyan)
   FIX v3.1:
     - Eliminado el texto [file name] / [file content] que rompía el modal.
     - Lógica Smarty y CSS original intactos.
   ========================================================== *}

{$count = $productionTable.usedResource}

<style>
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

/* ─── RESET GLOBAL ─── */
.astroinfopop_store,
.astroinfopop_store *,
.astroinfopop_store *::before,
.astroinfopop_store *::after {
    box-sizing: border-box;
}

/* ─── TABLA EXTERNA (wrapper) ─── */
.astroinfopop_store {
    width: 100%;
    background: transparent !important;
    border: none !important;
    margin-top: 12px;
    font-family: 'Segoe UI', Arial, sans-serif;
    border-collapse: collapse;
}
.astroinfopop_store_outer_row {
    background: transparent !important;
}
.astroinfopop_store_outer_cell {
    background: transparent !important;
    border: none !important;
    padding: 0 !important;
}

/* ─── Tabla interna ─── */
.astroinfopop_store_inner {
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
.astroinfopop_store_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroinfopop_store_th {
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
.astroinfopop_store_th_level {
    width: 60px;
    text-align: left;
}
.astroinfopop_store_th_resource {
    text-align: center;
}

/* ─── Sub-cabecera ─── */
.astroinfopop_store_subheader {
    background: rgba(0, 224, 255, 0.08) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astroinfopop_store_subheader .astroinfopop_store_th {
    background: rgba(0, 224, 255, 0.08) !important;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    color: var(--accent-cyan) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.3) !important;
    font-size: 10px;
    padding: 6px 8px !important;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroinfopop_store_th_empty {
    text-align: left;
}

/* ─── Filas de datos ─── */
.astroinfopop_store_row {
    background: transparent !important;
}
.astroinfopop_store_td {
    color: var(--text-main) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08) !important;
    padding: 6px 10px !important;
    font-size: 11.5px;
    vertical-align: middle;
    transition: 0.2s ease;
}
.astroinfopop_store_row:hover .astroinfopop_store_td {
    background: rgba(0, 224, 255, 0.04);
}

/* ─── Nivel ─── */
.astroinfopop_store_level_cell {
    text-align: left;
}
.astroinfopop_store_level {
    color: var(--text-main);
    font-weight: 500;
    font-family: 'Courier New', monospace;
}
.astroinfopop_store_level_current {
    color: var(--accent-red) !important;
    font-weight: 700;
    text-shadow: 0 0 8px rgba(239, 68, 68, 0.5);
}

/* ─── Celdas de valores ─── */
.astroinfopop_store_value_cell,
.astroinfopop_store_diff_cell {
    text-align: center;
}
.astroinfopop_store_value,
.astroinfopop_store_diff {
    font-weight: 700;
    font-size: 11.5px;
    font-family: 'Courier New', monospace;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    display: inline-block;
    max-width: 100%;
}

/* Almacenamiento positivo / negativo / cero */
.astroinfopop_store_value_pos,
.astroinfopop_store_diff_pos {
    color: var(--accent-green) !important;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.4);
}
.astroinfopop_store_value_neg,
.astroinfopop_store_diff_neg {
    color: var(--accent-red) !important;
    text-shadow: 0 0 6px rgba(239, 68, 68, 0.4);
}
.astroinfopop_store_value_zero,
.astroinfopop_store_diff_zero {
    color: var(--text-muted) !important;
}

/* ─── RESPONSIVE ─── */
@media (max-width: 1200px) {
    .astroinfopop_store_th,
    .astroinfopop_store_td {
        padding: 6px 6px !important;
    }
    .astroinfopop_store_value,
    .astroinfopop_store_diff {
        font-size: 10.5px;
    }
}

@media (max-width: 720px) {
    .astroinfopop_store {
        margin-top: 8px;
    }
    .astroinfopop_store_inner {
        border-radius: 8px;
    }
    .astroinfopop_store_th {
        font-size: 9.5px;
        padding: 5px 4px !important;
        letter-spacing: 0.4px;
    }
    .astroinfopop_store_subheader .astroinfopop_store_th {
        font-size: 9px;
        padding: 4px 3px !important;
    }
    .astroinfopop_store_td {
        font-size: 10px;
        padding: 5px 4px !important;
    }
    .astroinfopop_store_th_level {
        width: 40px;
    }
    .astroinfopop_store_value,
    .astroinfopop_store_diff {
        font-size: 9.5px;
    }
}
</style>

<table class="astroinfopop_store">
    <tbody>
        <tr class="astroinfopop_store_outer_row">
            <td colspan="2" class="astroinfopop_store_outer_cell">

                <table class="astroinfopop_store_inner">
                    <thead>
                        {* ─── Fila de cabecera: "Nivel" + recursos ─── *}
                        <tr class="astroinfopop_store_header">
                            <th class="astroinfopop_store_th astroinfopop_store_th_level">{$LNG.in_level}</th>
                        {if $count > 1}
                            {foreach $productionTable.usedResource as $resourceID}
                            <th class="astroinfopop_store_th astroinfopop_store_th_resource" colspan="2">{$LNG.tech.$resourceID}</th>
                            {/foreach}
                        </tr>

                        {* ─── Sub-cabecera: "almacén" + "diferencia" ─── *}
                        <tr class="astroinfopop_store_subheader">
                            <th class="astroinfopop_store_th astroinfopop_store_th_empty">&nbsp;</th>
                        {/if}
                            {foreach $productionTable.usedResource as $resourceID}
                            <th class="astroinfopop_store_th astroinfopop_store_th_storage">{$LNG.in_storage}</th>
                            <th class="astroinfopop_store_th astroinfopop_store_th_diff">{$LNG.in_difference}</th>
                            {/foreach}
                        </tr>
                    </thead>

                    <tbody>
                        {* ─── Filas de niveles ─── *}
                        {foreach $productionTable.storage as $elementLevel => $productionData}
                        <tr class="astroinfopop_store_row">

                            {* Nivel actual resaltado *}
                            <td class="astroinfopop_store_td astroinfopop_store_level_cell">
                                <span class="astroinfopop_store_level{if $CurrentLevel == $elementLevel} astroinfopop_store_level_current{/if}">{$elementLevel}</span>
                            </td>

                            {foreach $productionData as $resourceID => $storage}
                            {$storageDiff = $storage - $productionTable.storage.$CurrentLevel.$resourceID}

                            {* Capacidad de almacenamiento *}
                            <td class="astroinfopop_store_td astroinfopop_store_value_cell">
                                <span class="astroinfopop_store_value {if $storage > 0}astroinfopop_store_value_pos{elseif $storage < 0}astroinfopop_store_value_neg{else}astroinfopop_store_value_zero{/if}">{$storage|number}</span>
                            </td>

                            {* Diferencia respecto al nivel actual *}
                            <td class="astroinfopop_store_td astroinfopop_store_diff_cell">
                                <span class="astroinfopop_store_diff {if $storageDiff > 0}astroinfopop_store_diff_pos{elseif $storageDiff < 0}astroinfopop_store_diff_neg{else}astroinfopop_store_diff_zero{/if}">{$storageDiff|number}</span>
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