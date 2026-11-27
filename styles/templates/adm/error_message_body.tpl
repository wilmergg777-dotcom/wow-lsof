{include file="overall_header.tpl"}

{* ══════════════════════════════════════════════════════════════
   ASTROIO ERROR MESSAGE BODY (admin) v3.0
   Prefijo: .astroerr_
   Acento del módulo: 🔴 Rojo (#ef4444) — Error
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Sub-cajas con borde cyan sutil + hover
     - Wrapper padding 15px
     - ⚠️ CRÍTICO: overall_header/footer intactos
     - ⚠️ CRÍTICO: #content + {$fcm_info} + {$mes} intactos
   ══════════════════════════════════════════════════════════════ *}

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

/* ====== Wrapper ====== */
.astroerr_wrap {
    max-width: 700px;
    margin: 60px auto 40px;
    padding: 0 15px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

/* ====== Panel principal (glassmorphism) ====== */
.astroerr_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

/* ====== Header con acento rojo (error) ====== */
.astroerr_heading {
    background: linear-gradient(135deg, rgba(120, 20, 40, 0.9), rgba(180, 30, 60, 0.9));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-red);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 12px 18px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 0 10px rgba(239, 68, 68, 0.5);
}

/* ====== Body ====== */
.astroerr_body {
    padding: 20px 24px;
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.7;
}

/* ====== Mensaje (sub-caja con borde-left rojo) ====== */
.astroerr_message {
    color: var(--text-main);
    font-size: 13.5px;
    line-height: 1.7;
    margin: 0;
    padding: 14px 18px;
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(239, 68, 68, 0.25);
    border-left: 3px solid var(--accent-red);
    border-radius: 10px;
    transition: 0.2s ease;
}
.astroerr_message:hover {
    border-color: rgba(239, 68, 68, 0.5);
    background: rgba(0, 0, 0, 0.4);
}

/* ═══ Responsive ═══ */
@media (max-width: 768px) {
    .astroerr_wrap {
        margin-top: 50px;
        padding: 0 10px;
    }
    .astroerr_heading {
        font-size: 11px;
        padding: 10px 14px;
    }
    .astroerr_body {
        padding: 16px 14px;
    }
    .astroerr_message {
        padding: 12px 14px;
        font-size: 12.5px;
    }
}
</style>

<div id="content">
    <div class="astroerr_wrap">
        <div class="astroerr_panel">
            <div class="astroerr_heading">{$fcm_info}</div>
            <div class="astroerr_body">
                <p class="astroerr_message">{$mes}</p>
            </div>
        </div>
    </div>
</div>

{include file="overall_footer.tpl"}