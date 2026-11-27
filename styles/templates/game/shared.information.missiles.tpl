[file name]: shared.information.missiles.tpl
[file content begin]
{* ==========================================================
   ASTROIO — Shared Information: Missiles v3.0
   Estilo unificado (glassmorphism + acento cyan)
   FIX v3.0:
     - backdrop-filter + rgba en tabla
     - border-radius 12px
     - Variables --bg-card / --accent-cyan unificadas
     - box-sizing global
     - breakpoints 1200px / 720px
     - font-family monospace en números
     - 🔒 TODOS los hooks JS preservados:
       * id="missile_502" + id="missile_503"
       * class="missile" (en los 2 inputs)
       * name="missile[502]" + name="missile[503]"
       * onclick="DestroyMissiles();"
     - TODA la lógica Smarty preservada al 100%
   Mantiene TODA la lógica original de 2Moons
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
.astroinfopop_missiles,
.astroinfopop_missiles *,
.astroinfopop_missiles *::before,
.astroinfopop_missiles *::after {
    box-sizing: border-box;
}

/* ─── TABLA PRINCIPAL ─── */
.astroinfopop_missiles {
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

/* ─── Cabecera ─── */
.astroinfopop_missiles_header {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
}
.astroinfopop_missiles_th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85)) !important;
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: #ffffff !important;
    border-bottom: 1px solid var(--accent-cyan) !important;
    padding: 8px 12px !important;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 700;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroinfopop_missiles_th_type {
    text-align: left;
    width: 45%;
}
.astroinfopop_missiles_th_amount {
    text-align: center;
    width: 25%;
}
.astroinfopop_missiles_th_destroy {
    text-align: center;
    width: 30%;
}

/* ─── Filas ─── */
.astroinfopop_missiles_row {
    background: transparent !important;
    transition: 0.2s ease;
}
.astroinfopop_missiles_td {
    color: var(--text-main) !important;
    border-bottom: 1px solid rgba(0, 224, 255, 0.1) !important;
    padding: 8px 12px !important;
    font-size: 11.5px;
    vertical-align: middle;
}
.astroinfopop_missiles_row:hover .astroinfopop_missiles_td {
    background: rgba(0, 224, 255, 0.04);
}

/* ─── Nombre del misil ─── */
.astroinfopop_missiles_name {
    color: var(--text-main) !important;
    font-weight: 500;
}

/* ─── Cantidad disponible ─── */
.astroinfopop_missiles_count_cell {
    text-align: center;
}
.astroinfopop_missiles_count {
    color: var(--accent-green);
    font-weight: 700;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.4);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    display: inline-block;
    max-width: 100%;
}

/* ─── Input de destrucción ─── */
.astroinfopop_missiles_input_cell {
    text-align: center;
}
.astroinfopop_missiles_input {
    background: rgba(15, 23, 42, 0.95) !important;
    border: 1px solid rgba(0, 224, 255, 0.4) !important;
    border-radius: 6px !important;
    color: var(--accent-cyan) !important;
    padding: 6px 10px !important;
    font-size: 11.5px !important;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    text-align: center;
    width: 80px;
    outline: none;
    transition: all 0.25s ease;
}
.astroinfopop_missiles_input:focus {
    border-color: var(--accent-cyan) !important;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5) !important;
    background: rgba(15, 23, 42, 1) !important;
}
.astroinfopop_missiles_input::placeholder {
    color: rgba(200, 214, 229, 0.4);
    font-weight: 400;
}

/* ─── Fila del botón destruir ─── */
.astroinfopop_missiles_submit_row {
    background: rgba(239, 68, 68, 0.04) !important;
}
.astroinfopop_missiles_submit_cell {
    text-align: center;
    padding: 12px !important;
}
.astroinfopop_missiles_submitbtn {
    background: linear-gradient(135deg, #aa0044 0%, #ef4444 100%) !important;
    border: 1px solid var(--accent-red) !important;
    border-radius: 8px !important;
    color: #ffffff !important;
    padding: 9px 32px !important;
    font-size: 12px !important;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    cursor: pointer;
    transition: all 0.25s ease;
    box-shadow: 0 4px 14px rgba(239, 68, 68, 0.3);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}
.astroinfopop_missiles_submitbtn:hover {
    box-shadow: 0 0 22px rgba(239, 68, 68, 0.7) !important;
    transform: translateY(-2px);
    background: linear-gradient(135deg, #ef4444 0%, #ff6666 100%) !important;
}

/* ─── RESPONSIVE ─── */
@media (max-width: 1200px) {
    .astroinfopop_missiles_th,
    .astroinfopop_missiles_td {
        padding: 7px 8px !important;
        font-size: 11px;
    }
    .astroinfopop_missiles_input {
        width: 70px;
    }
}

@media (max-width: 720px) {
    .astroinfopop_missiles {
        margin-top: 8px;
        border-radius: 8px;
    }
    .astroinfopop_missiles_th {
        font-size: 9.5px;
        padding: 6px 6px !important;
        letter-spacing: 0.5px;
    }
    .astroinfopop_missiles_td {
        font-size: 10px;
        padding: 6px 6px !important;
    }
    .astroinfopop_missiles_th_type {
        width: 50%;
    }
    .astroinfopop_missiles_th_amount {
        width: 22%;
    }
    .astroinfopop_missiles_th_destroy {
        width: 28%;
    }
    .astroinfopop_missiles_count {
        font-size: 11px;
    }
    .astroinfopop_missiles_input {
        width: 50px;
        font-size: 10px !important;
        padding: 5px 6px !important;
    }
    .astroinfopop_missiles_submitbtn {
        width: 100%;
        padding: 10px 16px !important;
        font-size: 11px !important;
        letter-spacing: 1px;
    }
}
</style>

<table class="astroinfopop_missiles">
    <thead>
        <tr class="astroinfopop_missiles_header">
            <th class="astroinfopop_missiles_th astroinfopop_missiles_th_type">{$LNG.in_missilestype}</th>
            <th class="astroinfopop_missiles_th astroinfopop_missiles_th_amount">{$LNG.in_missilesamount}</th>
            <th class="astroinfopop_missiles_th astroinfopop_missiles_th_destroy">{$LNG.in_destroy}</th>
        </tr>
    </thead>
    <tbody>
        {* ─── Misil de Intercepción (502) ─── *}
        <tr class="astroinfopop_missiles_row">
            <td class="astroinfopop_missiles_td astroinfopop_missiles_name">{$LNG.tech.502}</td>
            <td class="astroinfopop_missiles_td astroinfopop_missiles_count_cell">
                <span id="missile_502" class="astroinfopop_missiles_count">{$MissileList.502|number}</span>
            </td>
            <td class="astroinfopop_missiles_td astroinfopop_missiles_input_cell">
                <input class="missile astroinfopop_missiles_input"
                       type="text"
                       name="missile[502]"
                       placeholder="0">
            </td>
        </tr>

        {* ─── Misil Interplanetario (503) ─── *}
        <tr class="astroinfopop_missiles_row">
            <td class="astroinfopop_missiles_td astroinfopop_missiles_name">{$LNG.tech.503}</td>
            <td class="astroinfopop_missiles_td astroinfopop_missiles_count_cell">
                <span id="missile_503" class="astroinfopop_missiles_count">{$MissileList.503|number}</span>
            </td>
            <td class="astroinfopop_missiles_td astroinfopop_missiles_input_cell">
                <input class="missile astroinfopop_missiles_input"
                       type="text"
                       name="missile[503]"
                       placeholder="0">
            </td>
        </tr>

        {* ─── Botón destruir ─── *}
        <tr class="astroinfopop_missiles_submit_row">
            <td colspan="3" class="astroinfopop_missiles_submit_cell">
                <input class="astroinfopop_missiles_submitbtn"
                       type="button"
                       value="{$LNG.in_destroy}"
                       onclick="DestroyMissiles();">
            </td>
        </tr>
    </tbody>
</table>
[file content end]