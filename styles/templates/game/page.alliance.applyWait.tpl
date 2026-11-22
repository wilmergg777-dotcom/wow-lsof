{block name="title" prepend}{$LNG.lm_research}{/block}
{block name="content"}

{* ═══════════════════════════════════════════════
   AstroIO v3.0 — Alianza · Solicitud Pendiente
   Prefijo: .astroalaw_
   Acento del módulo: 🟣 Púrpura (#8b5cf6)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism)
     - Bloque de texto con borde púrpura sutil + glassmorphism
     - Botón con radius 8px + hover translateY
     - Wrapper padding 15px
     - form action, textarea, submit y Smarty intactos
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

.astroalaw_wrap {
    text-align: center;
    padding: 15px;
    box-sizing: border-box;
}

.astroalaw_panel {
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

.astroalaw_title {
    text-transform: uppercase;
    color: var(--accent-purple);
    font-size: 11.5px;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(139, 92, 246, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    text-shadow: 0 0 8px rgba(139, 92, 246, 0.4);
}

.astroalaw_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}

.astroalaw_table tr > td {
    padding: 10px 12px;
    vertical-align: middle;
    color: var(--text-main);
    border-bottom: 1px solid rgba(30, 41, 59, 0.6);
}

.astroalaw_text {
    padding: 12px 14px;
    background: rgba(139, 92, 246, 0.04);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(139, 92, 246, 0.15);
    border-radius: 10px;
    color: var(--text-main);
    line-height: 1.5;
    transition: 0.2s ease;
}
.astroalaw_text:hover {
    border-color: rgba(139, 92, 246, 0.3);
}

.astroalaw_submit {
    display: inline-block;
    padding: 8px 26px;
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9), rgba(0, 153, 255, 0.9));
    color: #ffffff;
    border: 1px solid #00ccff;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 700;
    cursor: pointer;
    transition: 0.25s ease;
    letter-spacing: 0.4px;
    text-transform: uppercase;
    font-family: inherit;
}
.astroalaw_submit:hover {
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95), rgba(0, 204, 255, 0.95));
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astroalaw_submit:active {
    transform: translateY(0);
}

.astroalaw_center {
    text-align: center;
    padding-top: 8px;
    border-bottom: none !important;
}

@media (max-width: 480px) {
    .astroalaw_wrap { padding: 10px; }
    .astroalaw_panel { padding: 12px; }
    .astroalaw_submit { width: 100%; }
}
</style>

<div class="astroalaw_wrap">
<div class="astroalaw_panel">

    <div class="astroalaw_title">{$LNG.al_your_request_title}</div>

    <form action="game.php?page=alliance&amp;mode=cancelApply" method="post">
        <table class="astroalaw_table">
            <tr>
                <td>
                    <div class="astroalaw_text">{$request_text}</div>
                </td>
            </tr>
            <tr>
                <td class="astroalaw_center">
                    <input class="astroalaw_submit" type="submit" value="{$LNG.al_continue}">
                </td>
            </tr>
        </table>
    </form>

</div>
</div>

{/block}