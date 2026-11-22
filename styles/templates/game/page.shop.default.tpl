{block name="content"}

<style>
/* ============================================================
   ASTROIO - TIENDA NTX-20 (JUGADOR) v3.2
   Prefijo CSS: .astroshop_
   Acento: 🟡 Dorado (#fbbf24)
   v3.2 — Soporte de imágenes para los 3 cofres del Mercado
   ============================================================ */

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

.astroshop_wrap {
    max-width: 1200px;
    margin: 0 auto;
    padding: 10px;
    font-family: 'Segoe UI', Roboto, sans-serif;
    color: var(--text-main);
    font-size: 14px;
}

/* ===== PANEL PRINCIPAL ===== */
.astroshop_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 22px 24px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

/* ===== HEADER ===== */
.astroshop_header {
    text-align: center;
    padding-bottom: 18px;
    border-bottom: 1px solid var(--border-color);
    margin-bottom: 18px;
}

.astroshop_title {
    font-size: 26px;
    font-weight: 700;
    color: var(--accent-gold);
    text-shadow: 0 0 16px rgba(251, 191, 36, 0.5);
    letter-spacing: 1.5px;
    margin-bottom: 8px;
}

.astroshop_sub {
    color: var(--text-muted);
    font-size: 14px;
    margin-bottom: 12px;
}

.astroshop_balance {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    padding: 8px 18px;
    background: rgba(0, 40, 20, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    font-size: 15px;
    font-weight: 700;
    color: var(--accent-green);
    box-shadow: 0 0 16px rgba(74, 255, 136, 0.25);
    flex-wrap: wrap;
    justify-content: center;
}

.astroshop_balance strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 17px;
    letter-spacing: 0.5px;
}

.astroshop_vip_badge {
    display: inline-block;
    margin-left: 10px;
    padding: 4px 12px;
    background: linear-gradient(135deg, #ef4444, #ff88aa);
    color: #fff;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 0.5px;
    box-shadow: 0 0 12px rgba(239, 68, 68, 0.5);
    animation: astroshop_vip_pulse 2s infinite;
}

@keyframes astroshop_vip_pulse {
    0%, 100% { box-shadow: 0 0 12px rgba(239, 68, 68, 0.5); }
    50%      { box-shadow: 0 0 20px rgba(239, 68, 68, 0.9); }
}

/* ===== MENSAJES ===== */
.astroshop_msg {
    padding: 14px 18px;
    border-radius: 8px;
    margin-bottom: 18px;
    font-weight: 600;
    font-size: 15px;
    border-left: 4px solid;
    text-align: center;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astroshop_msg.success {
    background: rgba(74, 255, 136, 0.12);
    border-color: var(--accent-green);
    color: #88ffbb;
}

.astroshop_msg.error {
    background: rgba(239, 68, 68, 0.12);
    border-color: var(--accent-red);
    color: #ff99bb;
}

.astroshop_msg.info {
    background: rgba(0, 224, 255, 0.12);
    border-color: var(--accent-cyan);
    color: #88ddff;
}

/* ===== SECCIÓN ===== */
.astroshop_section {
    display: flex;
    align-items: center;
    gap: 14px;
    margin: 22px 0 16px 0;
}

.astroshop_line {
    flex: 1;
    height: 1px;
    background: linear-gradient(90deg, transparent, rgba(251, 191, 36, 0.5), transparent);
}

.astroshop_section_title {
    color: var(--accent-gold);
    font-size: 15px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 2px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
    white-space: nowrap;
}

/* ===== GRID ===== */
.astroshop_grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 18px;
}

/* ===== TARJETA ===== */
.astroshop_card {
    position: relative;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 24px 22px 22px 22px;
    display: flex;
    flex-direction: column;
    transition: all 0.3s ease;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    min-height: 380px;
}

.astroshop_card:hover {
    border-color: rgba(0, 224, 255, 0.7);
    box-shadow: 0 8px 30px rgba(0, 224, 255, 0.25), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}

.astroshop_card.popular {
    border-color: rgba(251, 191, 36, 0.7);
    box-shadow: 0 4px 20px rgba(251, 191, 36, 0.35), 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astroshop_card.popular:hover {
    border-color: var(--accent-gold);
    box-shadow: 0 8px 30px rgba(251, 191, 36, 0.6), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}

/* Badge POPULAR */
.astroshop_popular {
    position: absolute;
    top: -12px;
    right: 16px;
    padding: 5px 16px;
    background: linear-gradient(135deg, #fbbf24, #ffee66);
    color: #1a1000;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 0.8px;
    box-shadow: 0 2px 12px rgba(251, 191, 36, 0.8);
    text-transform: uppercase;
    z-index: 2;
}

/* Badge TIPO */
.astroshop_type_badge {
    display: inline-block;
    padding: 5px 14px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    margin-bottom: 14px;
    align-self: flex-start;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astroshop_type_badge.tipo-recurso         { background: rgba(251, 191, 36, 0.18);  color: #ffcc66; border: 1px solid rgba(251, 191, 36, 0.45); }
.astroshop_type_badge.tipo-nave            { background: rgba(0, 224, 255, 0.18);   color: #66ddff; border: 1px solid rgba(0, 224, 255, 0.45); }
.astroshop_type_badge.tipo-defensa         { background: rgba(74, 255, 136, 0.18);  color: #88ffbb; border: 1px solid rgba(74, 255, 136, 0.45); }
.astroshop_type_badge.tipo-misil           { background: rgba(239, 68, 68, 0.18);   color: #ff8888; border: 1px solid rgba(239, 68, 68, 0.45); }
.astroshop_type_badge.tipo-cofre           { background: rgba(139, 92, 246, 0.18);  color: #cc88ff; border: 1px solid rgba(139, 92, 246, 0.45); }
.astroshop_type_badge.tipo-booster         { background: rgba(251, 191, 36, 0.18);  color: #ffee88; border: 1px solid rgba(251, 191, 36, 0.45); }

/* 3 cofres nuevos del Mercado */
.astroshop_type_badge.tipo-cofre_common    { background: rgba(0, 224, 255, 0.18);   color: #66ddff; border: 1px solid rgba(0, 224, 255, 0.45); }
.astroshop_type_badge.tipo-cofre_rare      { background: rgba(139, 92, 246, 0.18);  color: #cc88ff; border: 1px solid rgba(139, 92, 246, 0.45); }
.astroshop_type_badge.tipo-cofre_legendary { background: rgba(251, 191, 36, 0.18);  color: #ffee88; border: 1px solid rgba(251, 191, 36, 0.45); }

/* ===== OFERTA TEMPORAL (countdown) ===== */
.astroshop_temporal_badge {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 14px;
    font-family: 'Courier New', monospace;
    border-left: 3px solid;
    transition: all 0.3s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astroshop_temporal_badge .tb_icon {
    font-size: 15px;
    line-height: 1;
    flex-shrink: 0;
}

.astroshop_temporal_badge .tb_label {
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.3px;
    text-transform: uppercase;
}

.astroshop_temporal_badge .tb_time {
    font-weight: 800;
    letter-spacing: 0.5px;
}

.astroshop_temporal_badge.urgency-far {
    background: rgba(74, 255, 136, 0.10);
    border-left-color: var(--accent-green);
    color: #88ffbb;
}

.astroshop_temporal_badge.urgency-soon {
    background: rgba(251, 191, 36, 0.12);
    border-left-color: var(--accent-gold);
    color: #ffee88;
    animation: astroshop_tb_soon 2s infinite;
}

.astroshop_temporal_badge.urgency-urgent {
    background: rgba(239, 68, 68, 0.15);
    border-left-color: var(--accent-red);
    color: #ffbbbb;
    animation: astroshop_tb_urgent 1s infinite;
}

.astroshop_temporal_badge.urgency-expired {
    background: rgba(120, 120, 120, 0.15);
    border-left-color: #666;
    color: #999;
    text-decoration: line-through;
    opacity: 0.7;
}

@keyframes astroshop_tb_soon {
    0%, 100% { box-shadow: 0 0 0 rgba(251, 191, 36, 0); }
    50%      { box-shadow: 0 0 12px rgba(251, 191, 36, 0.4); }
}

@keyframes astroshop_tb_urgent {
    0%, 100% { box-shadow: 0 0 8px rgba(239, 68, 68, 0.5); }
    50%      { box-shadow: 0 0 18px rgba(239, 68, 68, 0.9); }
}

/* ===== CABECERA DE LA CARD ===== */
.astroshop_card_top {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}

.astroshop_icon {
    font-size: 38px;
    line-height: 1;
    flex-shrink: 0;
    filter: drop-shadow(0 0 6px rgba(0, 224, 255, 0.4));
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 56px;
    height: 56px;
}

.astroshop_icon img {
    max-width: 56px;
    max-height: 56px;
    width: auto;
    height: auto;
    object-fit: contain;
    display: block;
    filter: drop-shadow(0 2px 6px rgba(0, 0, 0, 0.6));
}

.astroshop_name {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-title);
    line-height: 1.3;
    flex: 1;
    min-width: 0;
    word-wrap: break-word;
    overflow-wrap: break-word;
}

/* ===== NOMBRE REAL DEL ITEM ===== */
.astroshop_real_name {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 14px;
    font-weight: 600;
    color: #66ddff;
    line-height: 1.4;
    padding: 8px 12px;
    background: rgba(0, 224, 255, 0.08);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 6px;
    margin-bottom: 14px;
    word-wrap: break-word;
    overflow-wrap: break-word;
}

.astroshop_real_name .rn_icon {
    font-size: 16px;
    flex-shrink: 0;
    line-height: 1;
}

.astroshop_real_name .rn_text {
    flex: 1;
    min-width: 0;
    color: #66ddff;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.3);
}

/* ===== INFO EXTRA ===== */
.astroshop_info_extra {
    display: inline-block;
    padding: 6px 12px;
    background: rgba(251, 191, 36, 0.12);
    border: 1px solid rgba(251, 191, 36, 0.35);
    border-radius: 6px;
    font-size: 13px;
    font-weight: 700;
    color: #ffee88;
    margin-bottom: 12px;
    font-family: 'Courier New', monospace;
    align-self: flex-start;
}

/* ===== Cantidad ===== */
.astroshop_qty {
    display: inline-block;
    background: rgba(0, 224, 255, 0.12);
    border: 1px solid rgba(0, 224, 255, 0.3);
    color: #66ddff;
    padding: 5px 12px;
    border-radius: 6px;
    font-size: 13px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    margin-bottom: 12px;
    align-self: flex-start;
}

/* ===== Descripción ===== */
.astroshop_desc {
    color: var(--text-muted);
    font-size: 13px;
    line-height: 1.6;
    margin-bottom: 14px;
    min-height: 24px;
    padding: 4px 0;
    font-style: italic;
}

/* ===== PRECIO ===== */
.astroshop_price_block {
    margin-top: auto;
    padding-top: 14px;
    border-top: 1px solid var(--border-color);
    text-align: center;
}

.astroshop_price_row {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-bottom: 12px;
    flex-wrap: wrap;
}

.astroshop_price_old {
    color: #ff6688;
    font-size: 15px;
    font-weight: 700;
    text-decoration: line-through;
    font-family: 'Courier New', monospace;
    opacity: 0.85;
}

.astroshop_price_final {
    color: var(--accent-gold);
    font-size: 26px;
    font-weight: 800;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 12px rgba(251, 191, 36, 0.5);
    letter-spacing: 0.5px;
}

.astroshop_price_currency {
    color: var(--text-muted);
    font-size: 13px;
    font-weight: 600;
}

.astroshop_discount_badge {
    display: inline-block;
    padding: 3px 10px;
    background: linear-gradient(135deg, #ef4444, #ff88aa);
    color: #fff;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 800;
    letter-spacing: 0.5px;
    box-shadow: 0 0 10px rgba(239, 68, 68, 0.5);
    animation: astroshop_vip_pulse 2s infinite;
}

/* ===== BOTÓN COMPRAR ===== */
.astroshop_btn_buy {
    display: block;
    width: 100%;
    padding: 14px 18px;
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    font-size: 15px;
    font-weight: 800;
    letter-spacing: 1px;
    text-transform: uppercase;
    cursor: pointer;
    transition: all 0.25s ease;
    font-family: 'Segoe UI', Roboto, sans-serif;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astroshop_btn_buy:hover {
    background: linear-gradient(135deg, #0099ff, #00ccff);
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.7);
    transform: translateY(-2px);
}

.astroshop_btn_buy:active {
    transform: translateY(0);
}

.astroshop_btn_buy.disabled,
.astroshop_btn_buy:disabled {
    background: rgba(30, 41, 59, 0.85);
    border-color: var(--border-color);
    color: var(--text-muted);
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
    text-shadow: none;
}

/* ===== ESTADO VACÍO ===== */
.astroshop_empty {
    text-align: center;
    padding: 70px 30px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.astroshop_empty_icon {
    display: block;
    font-size: 80px;
    line-height: 1;
    margin-bottom: 30px;
    opacity: 0.55;
    filter: grayscale(40%);
}

.astroshop_empty_title {
    display: block;
    font-size: 22px;
    font-weight: 700;
    color: var(--accent-gold);
    text-shadow: 0 0 12px rgba(251, 191, 36, 0.4);
    margin-bottom: 14px;
    letter-spacing: 0.8px;
    line-height: 1.2;
}

.astroshop_empty_text {
    display: block;
    color: var(--text-muted);
    font-size: 14px;
    line-height: 1.7;
    max-width: 500px;
    margin: 0 auto;
}

@media (max-width: 720px) {
    /* 🆕 FORZAR 1x2 EN LA TIENDA */
    .astroshop_grid {
        grid-template-columns: repeat(2, 1fr) !important;
        gap: 8px !important;
    }
    .astroshop_card {
        padding: 10px !important;
        min-height: 280px !important;
    }
    .astroshop_header { padding-bottom: 10px !important; margin-bottom: 12px !important; }
    .astroshop_title { font-size: 18px !important; }
    .astroshop_sub { font-size: 11px !important; }
    
    /* Ajustar iconos y textos para que quepan en media pantalla */
    .astroshop_icon {
        width: 40px !important;
        height: 40px !important;
        font-size: 24px !important;
    }
    .astroshop_icon img {
        max-width: 40px !important;
        max-height: 40px !important;
    }
    .astroshop_name { font-size: 12px !important; }
    .astroshop_type_badge {
        font-size: 9px !important;
        padding: 2px 6px !important;
        margin-bottom: 8px !important;
    }
    .astroshop_price_final { font-size: 16px !important; }
    .astroshop_btn_buy {
        padding: 8px !important;
        font-size: 11px !important;
    }
    .astroshop_real_name {
        font-size: 10px !important;
        padding: 4px 6px !important;
        margin-bottom: 8px !important;
    }
    .astroshop_desc { font-size: 10px !important; }
    .astroshop_info_extra, .astroshop_qty {
        font-size: 10px !important;
        padding: 2px 6px !important;
    }
    .astroshop_temporal_badge {
        font-size: 10px !important;
        padding: 4px 6px !important;
    }
}
</style>

<div class="astroshop_wrap">

    <div class="astroshop_panel">

        {* ===== HEADER ===== *}
        <div class="astroshop_header">
            <div class="astroshop_title">⭐ TIENDA {$moneda} ⭐</div>
            <div class="astroshop_sub">Compra cofres, naves, defensas, misiles, recursos y boosters</div>
            <div class="astroshop_balance">
                💰 Tu saldo: <strong>{$saldo}</strong> {$moneda}
                {if $is_vip}
                    <span class="astroshop_vip_badge">⭐ VIP · -{$vip_discount_pct}%</span>
                {/if}
            </div>
        </div>

        {* ===== MENSAJES ===== *}
        {if $message}
            <div class="astroshop_msg {$msgType}">{$message}</div>
        {/if}

        {* ===== SIN OFERTAS ===== *}
        {if !$has_offer}

            <div class="astroshop_empty">
                <div class="astroshop_empty_icon">🛒</div>
                <div class="astroshop_empty_title">No hay ofertas activas</div>
                <div class="astroshop_empty_text">
                    El administrador todavía no ha publicado ninguna oferta en la tienda.<br>
                    Vuelve más tarde para ver las novedades.
                </div>
            </div>

        {else}

            {* ===== TÍTULO DE SECCIÓN ===== *}
            <div class="astroshop_section">
                <span class="astroshop_line"></span>
                <span class="astroshop_section_title">OFERTAS DISPONIBLES</span>
                <span class="astroshop_line"></span>
            </div>

            {* ===== GRID DE OFERTAS ===== *}
            <div class="astroshop_grid">
                {foreach $offers as $o}
                    <div class="astroshop_card {if $o.popular}popular{/if}">

                        {if $o.popular}
                            <div class="astroshop_popular">⭐ Popular</div>
                        {/if}

                        {* Badge del TIPO *}
                        <span class="astroshop_type_badge tipo-{$o.tipo}">
                            {$o.tipo_icon} {$o.tipo_label}
                        </span>

                        {* ===== COUNTDOWN (solo si es temporal) ===== *}
                        {if $o.es_temporal}
                            <div class="astroshop_temporal_badge urgency-{$o.urgencia}"
                                 data-expira="{$o.expira_en}">
                                <span class="tb_icon">⏰</span>
                                <span class="tb_label">Termina en:</span>
                                <span class="tb_time" data-role="countdown">{$o.tiempo_texto}</span>
                            </div>
                        {/if}

                        {* Icono + Nombre de la oferta (lo que puso el admin) *}
                        {* v3.2: nofilter → permite mostrar <img> de los cofres *}
                        <div class="astroshop_card_top">
                            <span class="astroshop_icon">{$o.icono_item nofilter}</span>
                            <span class="astroshop_name">{$o.nombre}</span>
                        </div>

                        {* Nombre REAL del item (lo que se entrega) *}
                        {if $o.nombre_real && $o.nombre_real != '—'}
                            <div class="astroshop_real_name">
                                <span class="rn_icon">📌</span>
                                <span class="rn_text">{$o.nombre_real}</span>
                            </div>
                        {/if}

                        {* Info extra (duración booster / contenido cofre) *}
                        {if $o.info_extra}
                            <span class="astroshop_info_extra">⏱️ {$o.info_extra}</span>
                        {/if}

                        {* Cantidad *}
                        {if $o.cantidad > 1}
                            <span class="astroshop_qty">× {$o.cantidad_txt}</span>
                        {/if}

                        {* Descripción (si existe) *}
                        {if $o.tiene_desc}
                            <div class="astroshop_desc">"{$o.descripcion}"</div>
                        {/if}

                        <div class="astroshop_price_block">

                            <div class="astroshop_price_row">
                                {if $o.muestra_desc}
                                    {* Es VIP → mostrar precio tachado + descuento *}
                                    <span class="astroshop_price_old">{$o.precio_base}</span>
                                    <span class="astroshop_price_final">{$o.precio_final}</span>
                                    <span class="astroshop_price_currency">{$moneda}</span>
                                    <span class="astroshop_discount_badge">-{$vip_discount_pct}% VIP</span>
                                {else}
                                    {* No VIP → solo precio final *}
                                    <span class="astroshop_price_final">{$o.precio_final}</span>
                                    <span class="astroshop_price_currency">{$moneda}</span>
                                {/if}
                            </div>

                            <form method="post" action="{$shop_url}" style="margin:0;">
                                <input type="hidden" name="action" value="buy">
                                <input type="hidden" name="item_id" value="{$o.id}">
                                {if $saldo >= $o.precio_final}
                                    <button type="submit" class="astroshop_btn_buy"
                                            onclick="return confirm('¿Comprar «{$o.nombre}» por {$o.precio_final} {$moneda}?');">
                                        🛒 Comprar
                                    </button>
                                {else}
                                    <button type="button" class="astroshop_btn_buy disabled" disabled
                                            title="No tienes suficiente {$moneda}">
                                        ❌ Sin saldo
                                    </button>
                                {/if}
                            </form>

                        </div>

                    </div>
                {/foreach}
            </div>

        {/if}

    </div>

</div>

{* ============================================================
   JS: Countdown de ofertas temporales
   Actualiza cada segundo los badges con data-expira
   ============================================================ *}
<script>
(function() {
    function formatCountdown(seconds) {
        if (seconds <= 0) return '0s';
        var d = Math.floor(seconds / 86400);
        var h = Math.floor((seconds % 86400) / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = seconds % 60;
        var parts = [];
        if (d > 0) parts.push(d + 'd');
        if (h > 0) parts.push(h + 'h');
        if (m > 0) parts.push(m + 'm');
        if (s > 0 || parts.length === 0) parts.push(s + 's');
        return parts.join(' ');
    }

    function getUrgency(seconds) {
        if (seconds <= 0) return 'expired';
        if (seconds < 86400) return 'urgent';
        if (seconds < 3 * 86400) return 'soon';
        return 'far';
    }

    function tick() {
        var now = Math.floor(Date.now() / 1000);
        var badges = document.querySelectorAll('.astroshop_temporal_badge');
        for (var i = 0; i < badges.length; i++) {
            var el = badges[i];
            var expira = parseInt(el.getAttribute('data-expira') || '0', 10);
            if (expira <= 0) continue;

            var remaining = expira - now;
            var timeEl = el.querySelector('[data-role="countdown"]');
            if (timeEl) {
                timeEl.textContent = formatCountdown(Math.max(0, remaining));
            }

            // Actualizar urgencia (color)
            var urgency = getUrgency(remaining);
            el.className = 'astroshop_temporal_badge urgency-' + urgency;

            // Si expiró → desactivar botón de compra
            if (remaining <= 0) {
                var card = el.closest ? el.closest('.astroshop_card') : null;
                if (card) {
                    var btn = card.querySelector('.astroshop_btn_buy');
                    if (btn && !btn.disabled) {
                        btn.disabled = true;
                        btn.classList.add('disabled');
                        btn.innerHTML = '⏰ Expirada';
                    }
                }
            }
        }
    }

    // Ejecutar al cargar + cada segundo
    tick();
    setInterval(tick, 1000);
})();
</script>

{/block}