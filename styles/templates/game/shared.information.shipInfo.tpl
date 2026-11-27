{* ==========================================================
   ASTROIO — Shared Information: Ship Info v3.2
   Estilo unificado (glassmorphism + acento cyan)
   FIX v3.2:
     - Eliminado el texto [file name] / [file content] que rompía el modal.
     - Este archivo controla TANTO Naves como Defensas.
   ========================================================== *}

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
.astroinfopop_ship,
.astroinfopop_ship *,
.astroinfopop_ship *::before,
.astroinfopop_ship *::after {
    box-sizing: border-box;
}

/* ─── TABLA PRINCIPAL ─── */
.astroinfopop_ship {
    width: 100%;
    background: rgba(15, 23, 42, 0.7) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(0, 224, 255, 0.25) !important;
    border-collapse: collapse;
    margin-top: 12px;
    border-radius: 12px;
    overflow: hidden;
    font-family: 'Segoe UI', Arial, sans-serif;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4);
}

/* ─── Filas ─── */
.astroinfopop_ship_row {
    background: transparent !important;
    transition: 0.2s ease;
}
.astroinfopop_ship_row:nth-child(even) {
    background: rgba(0, 224, 255, 0.03) !important;
}
.astroinfopop_ship_row:hover {
    background: rgba(0, 224, 255, 0.06) !important;
}

/* ─── Etiqueta (columna izquierda) ─── */
.astroinfopop_ship_label {
    width: 50%;
    color: var(--accent-cyan) !important;
    font-weight: 700;
    font-size: 11.5px;
    padding: 8px 14px !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08) !important;
    border-right: 1px solid rgba(0, 224, 255, 0.1) !important;
    vertical-align: middle;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.25);
}

/* ─── Valor (columna derecha) ─── */
.astroinfopop_ship_value {
    width: 50%;
    color: var(--text-main) !important;
    padding: 8px 14px !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08) !important;
    font-size: 11.5px;
    vertical-align: middle;
    overflow: hidden;
    text-overflow: ellipsis;
}

/* ─── Números destacados (estructura, ataque, escudo, etc.) ─── */
.astroinfopop_ship_num {
    color: var(--accent-green) !important;
    font-weight: 700;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.3);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    display: inline-block;
    max-width: 100%;
}

/* ─── Valores alternativos (speed2, consumption2, tech alt) ─── */
.astroinfopop_ship_alt {
    color: var(--accent-gold) !important;
    font-weight: 700;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(251, 191, 36, 0.3);
}

/* ─── Última fila sin borde inferior ─── */
.astroinfopop_ship_row:last-child .astroinfopop_ship_label,
.astroinfopop_ship_row:last-child .astroinfopop_ship_value {
    border-bottom: none !important;
}

/* ─── RESPONSIVE ─── */
@media (max-width: 1200px) {
    .astroinfopop_ship_label,
    .astroinfopop_ship_value {
        padding: 7px 10px !important;
        font-size: 11px;
    }
    .astroinfopop_ship_num {
        font-size: 11.5px;
    }
}

@media (max-width: 720px) {
    .astroinfopop_ship {
        margin-top: 8px;
        border-radius: 8px;
    }
    .astroinfopop_ship_label,
    .astroinfopop_ship_value {
        padding: 6px 8px !important;
        font-size: 10px;
    }
    .astroinfopop_ship_label {
        width: 45%;
        font-size: 9.5px;
        letter-spacing: 0.3px;
    }
    .astroinfopop_ship_value {
        width: 55%;
    }
    .astroinfopop_ship_num {
        font-size: 10px;
    }
    .astroinfopop_ship_alt {
        font-size: 9.5px;
    }
}
</style>

<table class="astroinfopop_ship">
    <tbody>

        {* ─── Motor (si aplica) ─── *}
        {if !empty($FleetInfo.tech)}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_engine}</td>
            <td class="astroinfopop_ship_value">
                {if $FleetInfo.tech == 1}
                    {$LNG.tech.115}
                {elseif $FleetInfo.tech == 2}
                    {$LNG.tech.117}
                {elseif $FleetInfo.tech == 3}
                    {$LNG.tech.118}
                {elseif $FleetInfo.tech == 4}
                    {$LNG.tech.115} <span class="astroinfopop_ship_alt">({$LNG.tech.117})</span>
                {elseif $FleetInfo.tech == 3}
                    {$LNG.tech.117} <span class="astroinfopop_ship_alt">({$LNG.tech.118})</span>
                {else}
                    -
                {/if}
            </td>
        </tr>
        {/if}

        {* ─── Estructura ─── *}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_struct_pt}</td>
            <td class="astroinfopop_ship_value astroinfopop_ship_num">{$FleetInfo.structure|number}</td>
        </tr>

        {* ─── Ataque ─── *}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_attack_pt}</td>
            <td class="astroinfopop_ship_value astroinfopop_ship_num">{$FleetInfo.attack|number}</td>
        </tr>

        {* ─── Escudo ─── *}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_shield_pt}</td>
            <td class="astroinfopop_ship_value astroinfopop_ship_num">{$FleetInfo.shield|number}</td>
        </tr>

        {* ─── Capacidad (si aplica) ─── *}
        {if !empty($FleetInfo.capacity)}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_capacity}</td>
            <td class="astroinfopop_ship_value astroinfopop_ship_num">{$FleetInfo.capacity|number}</td>
        </tr>
        {/if}

        {* ─── Velocidad base (si aplica) ─── *}
        {if !empty($FleetInfo.speed1)}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_base_speed}</td>
            <td class="astroinfopop_ship_value astroinfopop_ship_num">
                {$FleetInfo.speed1|number}{if $FleetInfo.speed1 != $FleetInfo.speed2} <span class="astroinfopop_ship_alt">({$FleetInfo.speed2|number})</span>{/if}
            </td>
        </tr>
        {/if}

        {* ─── Consumo (si aplica) ─── *}
        {if !empty($FleetInfo.consumption1)}
        <tr class="astroinfopop_ship_row">
            <td class="astroinfopop_ship_label">{$LNG.in_consumption}</td>
            <td class="astroinfopop_ship_value astroinfopop_ship_num">
                {$FleetInfo.consumption1|number}{if $FleetInfo.consumption1 != $FleetInfo.consumption2} <span class="astroinfopop_ship_alt">({$FleetInfo.consumption2|number})</span>{/if}
            </td>
        </tr>
        {/if}

    </tbody>
</table>