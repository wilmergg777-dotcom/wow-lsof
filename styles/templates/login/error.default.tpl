{block name="title" prepend}{$LNG.fcm_info}{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Página de Error / Mensaje
   Prefijo: .astroerr_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px (panel) / 8px (message/buttons)
     - Variables --bg-card / --accent-cyan unificadas
     - Todos los IDs/classes/Smarty intactos
     - .table519 + .btn.btn-default preservados
   ═══════════════════════════════════════════════ */

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

.astroerr_wrap {
    max-width: 700px;
    margin: 80px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astroerr_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astroerr_heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 10px 16px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
}

.astroerr_body {
    padding: 20px 24px;
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.7;
}

/* ═══ Tabla table519 (preservada como referencia) ═══ */
.astroerr_table {
    width: 100%;
    border-collapse: collapse;
    margin: 0;
}

.astroerr_table tr > td {
    padding: 0;
    color: var(--text-main);
    vertical-align: top;
}

/* ═══ Mensaje ═══ */
.astroerr_message {
    color: var(--text-main);
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0 0 16px;
    padding: 12px 16px;
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 8px;
}

.astroerr_message p {
    margin: 0;
}

/* ═══ Botones de redirección ═══ */
.astroerr_buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 14px;
    padding-top: 14px;
    border-top: 1px solid var(--border-color);
    justify-content: flex-start;
}

.astroerr_buttons a {
    text-decoration: none;
    display: inline-block;
}

.astroerr_buttons .btn,
.astroerr_buttons button {
    display: inline-block;
    padding: 8px 22px;
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff !important;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroerr_buttons .btn:hover,
.astroerr_buttons button:hover {
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%);
    color: #ffffff !important;
}

.astroerr_buttons .btn:active,
.astroerr_buttons button:active {
    transform: translateY(0);
}

/* ═══ Responsive ═══ */
@media (max-width: 768px) {
    .astroerr_wrap {
        margin-top: 70px;
        padding: 0 6px;
    }
    .astroerr_body {
        padding: 16px 14px;
    }
    .astroerr_buttons {
        justify-content: center;
    }
    .astroerr_buttons .btn,
    .astroerr_buttons button {
        width: 100%;
        text-align: center;
    }
}
</style>

<div class="container astroerr_wrap">
    <div class="panel panel-default astroerr_panel">
        <div class="panel-heading astroerr_heading">{$LNG.fcm_info}</div>
        <div class="panel-body astroerr_body">
            <table class="table519 astroerr_table">
                <tr>
                    <td>
                        <p class="astroerr_message">{$message}</p>
                        {if !empty($redirectButtons)}
                        <p class="astroerr_buttons">
                            {foreach $redirectButtons as $button}
                                <a href="{$button.url}"><button class="btn btn-default">{$button.label}</button></a>
                            {/foreach}
                        </p>
                        {/if}
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>

{/block}