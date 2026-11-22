{block name="content"}

<div class="astrovip_wrap">
  <div class="astrovip_panel">

    <!-- ═══════════ HEADER ═══════════ -->
    <div class="astrovip_header">
      <h1 class="astrovip_title">⭐ VIP Prime ⭐</h1>
      <p class="astrovip_subtitle">Recibe comisiones mensuales del pool de transacciones del jugador.</p>

      {if $vipMessage}
        <div class="astrovip_msg astrovip_msg_{$vipMsgType}">{$vipMessage}</div>
      {/if}

      {if $isVip}
        <div class="astrovip_status">
          🟢 VIP activo — <b>{$vipDaysLeft} días restantes</b> — Plan: <b>{$vipData.vip_type|capitalize}</b>
        </div>
      {/if}

      <div class="astrovip_ntx_balance">
        💲 Tu saldo: <b>{$vipSaldo|number_format} {$vipMoneda}</b>
      </div>
    </div>

    <!-- ═══════════ BENEFICIOS ═══════════ -->
    <div class="astrovip_section">
      <h2 class="astrovip_section_title">⚡ Beneficios VIP</h2>
      <div class="astrovip_benefits_grid">
        {foreach $vipBenefits as $b}
          <div class="astrovip_benefit_item">
            <span class="astrovip_benefit_icon">{$b.icon}</span>
            <span class="astrovip_benefit_text">{$b.text}</span>
          </div>
        {/foreach}
      </div>
    </div>

    <!-- ═══════════ PLANES ═══════════ -->
    <div class="astrovip_section">
      <h2 class="astrovip_section_title astrovip_section_title_center">Elige tu plan</h2>
      <div class="astrovip_plans_grid">
        {foreach $vipPacks as $p}
          <div class="astrovip_plan {if $p.popular}astrovip_plan_popular{/if}">
            {if $p.popular}<div class="astrovip_plan_badge">⭐ POPULAR</div>{/if}

            <div class="astrovip_plan_name">⭐ {$p.name}</div>

            <div class="astrovip_plan_row">
              <span class="astrovip_plan_label">Duración</span>
              <span class="astrovip_plan_value">
                {if $p.days == 7}7 días
                {elseif $p.days == 15}15 días
                {elseif $p.days == 30}1 mes
                {/if}
              </span>
            </div>

            <div class="astrovip_plan_row">
              <span class="astrovip_plan_label">Descuento</span>
              <span class="astrovip_plan_value astrovip_plan_value_cyan">{$p.price_month}</span>
            </div>

            <a href="game.php?page=vip&action=buy&pack={$p.id}" class="astrovip_plan_buy_link">
              <div class="astrovip_plan_price_box">

                {* 🆕 ETIQUETA DE OFERTA — solo si hay precio antiguo *}
                {if $p.ntx_old}
                  {math equation="round((o-n)/o*100)" o=$p.ntx_old n=$p.ntx assign=vip_pct}
                  <div class="astrovip_plan_offer_tag">🔥 OFERTA -{$vip_pct}%</div>
                {/if}

                {if $vipMoneda == 'UNTX-20'}
                    {* 🆕 PRECIO ANTIGUO TACHADO (UNTX-20 = x2) *}
                    {if $p.ntx_old}
                      <div class="astrovip_plan_price_old">{$p.ntx_old * 2|number_format} {$vipMoneda}</div>
                    {/if}
                    <!-- Si es internacional, mostramos el DOBLE (x2) -->
                    <div class="astrovip_plan_price_main">{$p.ntx * 2|number_format} {$vipMoneda}</div>
                    <div class="astrovip_plan_price_cup">≈ {$p.ntx * 2|number_format} USD</div>
                {else}
                    {* 🆕 PRECIO ANTIGUO TACHADO (NTX-20 normal) *}
                    {if $p.ntx_old}
                      <div class="astrovip_plan_price_old">{$p.ntx_old|number_format} {$vipMoneda}</div>
                    {/if}
                    <!-- Si es nacional, mostramos el precio normal -->
                    <div class="astrovip_plan_price_main">{$p.ntx|number_format} {$vipMoneda}</div>
                    <div class="astrovip_plan_price_cup">≈ {$p.ntx|number_format} CUP</div>
                {/if}
              </div>
            </a>

            <div class="astrovip_plan_features">
              <div class="astrovip_plan_features_title">Incluye</div>
              <ul>
                <li><b>{$p.bonus.attack*100|string_format:"%d"}%</b> Ataque</li>
                <li><b>{$p.bonus.defense*100|string_format:"%d"}%</b> Defensa</li>
                <li><b>{$p.bonus.shield*100|string_format:"%d"}%</b> Escudo</li>
                <li><b>{$p.bonus.production*100|string_format:"%d"}%</b> Producción</li>
                <li><b>{$p.daily_res_min|number_format} - {$p.daily_res_max|number_format}</b> recursos/día</li>
                <li><b>{$p.daily_chest_chance}%</b> de drop: <b>{$p.daily_chest_min}-{$p.daily_chest_max}</b> cofres/día</li>
                <li><b>{$p.daily_bonus_chance}%</b> de drop: <b>+{$p.daily_bonus_value}%</b> bonus (24h)</li>
              </ul>
            </div>

          </div>
        {/foreach}
      </div>
    </div>

    <!-- ═══════════ RECOMPENSA DIARIA AUTOMÁTICA ═══════════ -->
    {if $isVip}
    <div class="astrovip_section">
      <div class="astrovip_daily_box">
        <div class="astrovip_daily_icon">🎁</div>
        <div class="astrovip_daily_text">
          <b>Recompensa diaria automática</b><br>
          Recibes <b>recursos, bonus pasivo y cofres</b> automáticamente cada día al entrar al juego.<br>
          Los cofres se acumulan en tu inventario — ábrelos en <a href="game.php?page=containers" class="astrovip_link_containers">📦 Contenedores</a>.
        </div>
        <div class="astrovip_daily_status {if $vipCanClaim}astrovip_status_pending{else}astrovip_status_done{/if}">
          {if $vipCanClaim}
            ⏳ Pendiente hoy
          {else}
            ✅ Recibido hoy
          {/if}
        </div>
      </div>

      {* 🆕 ÚLTIMA RECOMPENSA RECIBIDA *}
      {if $lastReward}
      <div class="astrovip_last_reward">
        <div class="astrovip_lr_title">
          <span>📜</span>
          <span>Última recompensa recibida</span>
        </div>
        <div class="astrovip_lr_grid">
          <div class="astrovip_lr_item">
            <span class="astrovip_lr_icon">🔩</span>
            <span class="astrovip_lr_val">{$lastReward.metal|number_format}</span>
            <span class="astrovip_lr_label">Metal</span>
          </div>
          <div class="astrovip_lr_item">
            <span class="astrovip_lr_icon">💎</span>
            <span class="astrovip_lr_val">{$lastReward.crystal|number_format}</span>
            <span class="astrovip_lr_label">Cristal</span>
          </div>
          <div class="astrovip_lr_item">
            <span class="astrovip_lr_icon">⚗️</span>
            <span class="astrovip_lr_val">{$lastReward.deuterium|number_format}</span>
            <span class="astrovip_lr_label">Deuterio</span>
          </div>
          {if $lastReward.bonus_applied}
          <div class="astrovip_lr_item astrovip_lr_bonus">
            <span class="astrovip_lr_icon">💎</span>
            <span class="astrovip_lr_val">+{$lastReward.bonus_value}%</span>
            <span class="astrovip_lr_label">Bonus (24h)</span>
          </div>
          {/if}
          {if $lastReward.chests > 0}
          <div class="astrovip_lr_item astrovip_lr_chest">
            <span class="astrovip_lr_icon">🎁</span>
            <span class="astrovip_lr_val">+{$lastReward.chests}</span>
            <span class="astrovip_lr_label">Cofres</span>
          </div>
          {/if}
        </div>
      </div>
      {/if}

      {* 🆕 COUNTDOWN PRÓXIMA RECOMPENSA *}
      {if $nextRewardTime > 0}
      <div class="astrovip_next_reward" data-next-reward="{$nextRewardTime}">
        <span class="astrovip_nr_icon">⏰</span>
        <span class="astrovip_nr_label">Próxima recompensa automática en:</span>
        <span class="astrovip_nr_countdown" id="astrovip_countdown">--:--:--</span>
      </div>
      {/if}
    </div>
    {/if}

    <!-- ═══════════ FOOTER NOTE ═══════════ -->
    <div class="astrovip_footer_note">
      💡 Se utiliza para realizar los pagos de <b>guerras WAR</b> y <b>mantenimiento al servidor</b>.
    </div>

  </div>
</div>

<style type="text/css">
/* ═══════════════════════════════════════════════════════════
   ASTROIO VIP v3.1 — Glassmorphism + Acento Dorado + Ofertas
   Prefijo: .astrovip_
   ═══════════════════════════════════════════════════════════ */

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

.astrovip_wrap {
    text-align: center;
    padding: 20px 10px;
}
.astrovip_panel {
    display: inline-block;
    text-align: left;
    width: 1150px;
    max-width: 100%;
    vertical-align: top;
    box-sizing: border-box;
    padding: 24px 28px;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    color: var(--text-main);
    font-size: 11.5px;
}

.astrovip_header {
    text-align: center;
    padding: 8px 0 22px;
    border-bottom: 1px solid var(--border-color);
    margin-bottom: 26px;
}
.astrovip_title {
    margin: 0 0 8px;
    font-size: 26px;
    font-weight: 700;
    color: var(--accent-gold);
    letter-spacing: 0.5px;
    text-shadow: 0 0 22px rgba(251, 191, 36, 0.4);
}
.astrovip_subtitle {
    margin: 0;
    font-size: 12px;
    color: var(--text-muted);
    font-style: italic;
}
.astrovip_status {
    margin-top: 12px;
    display: inline-block;
    padding: 6px 16px;
    background: rgba(0, 224, 255, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.35);
    border-radius: 6px;
    color: var(--accent-cyan);
    font-size: 11px;
}
.astrovip_ntx_balance {
    margin-top: 10px;
    font-size: 12px;
    color: var(--accent-green);
}
.astrovip_ntx_balance b {
    font-family: 'Courier New', monospace;
    font-weight: 700;
    letter-spacing: 0.5px;
}

.astrovip_msg {
    display: inline-block;
    padding: 10px 18px;
    margin-top: 12px;
    border-radius: 8px;
    font-size: 12px;
    border-left: 4px solid;
    max-width: 700px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astrovip_msg_success { background: rgba(74, 255, 136, 0.10); border-color: var(--accent-green); color: var(--accent-green); }
.astrovip_msg_error   { background: rgba(239, 68, 68, 0.10);  border-color: var(--accent-red);   color: var(--accent-red); }
.astrovip_msg_info    { background: rgba(0, 224, 255, 0.10);  border-color: var(--accent-cyan);  color: var(--accent-cyan); }

.astrovip_section { margin-bottom: 28px; }
.astrovip_section_title {
    margin: 0 0 16px;
    font-size: 13.5px;
    font-weight: 700;
    color: var(--accent-cyan);
    text-transform: uppercase;
    letter-spacing: 1.2px;
    padding-bottom: 10px;
    border-bottom: 1px solid var(--border-color);
}
.astrovip_section_title_center {
    text-align: center;
    border-bottom: none;
    color: var(--accent-gold);
    margin-bottom: 10px;
}

.astrovip_benefits_grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px 36px;
}
.astrovip_benefit_item {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    font-size: 11.5px;
    line-height: 1.5;
}
.astrovip_benefit_icon {
    flex: 0 0 22px;
    font-size: 15px;
    text-align: center;
    line-height: 1.3;
}
.astrovip_benefit_text { flex: 1; color: var(--text-main); }
.astrovip_benefit_text b { color: var(--accent-cyan); font-weight: 600; }

.astrovip_plans_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
    margin-top: 16px;
    align-items: stretch;
}
.astrovip_plan {
    position: relative;
    display: flex;
    flex-direction: column;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 18px 14px 16px;
    transition: all 0.3s ease;
    box-sizing: border-box;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astrovip_plan:hover {
    border-color: rgba(0, 224, 255, 0.7);
    box-shadow: 0 8px 30px rgba(0, 224, 255, 0.25), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: translateY(-4px);
}
.astrovip_plan_popular {
    border: 2px solid var(--accent-gold);
    box-shadow: 0 8px 30px rgba(251, 191, 36, 0.35), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: scale(1.02);
}
.astrovip_plan_popular:hover {
    box-shadow: 0 12px 40px rgba(251, 191, 36, 0.60), 0 4px 20px rgba(0, 0, 0, 0.5);
    transform: scale(1.02) translateY(-4px);
}
.astrovip_plan_badge {
    position: absolute;
    top: -11px;
    left: 50%;
    transform: translateX(-50%);
    background: linear-gradient(180deg, #fbbf24 0%, #aa6600 100%);
    color: #0f1624;
    font-size: 9.5px;
    font-weight: 800;
    letter-spacing: 0.8px;
    padding: 4px 14px;
    border-radius: 12px;
    white-space: nowrap;
    box-shadow: 0 3px 12px rgba(251, 191, 36, 0.5);
}
.astrovip_plan_name {
    font-size: 13.5px;
    font-weight: 700;
    color: var(--text-title);
    text-align: center;
    margin-bottom: 14px;
    padding-bottom: 12px;
    border-bottom: 1px solid var(--border-color);
}
.astrovip_plan_row {
    display: flex;
    justify-content: space-between;
    font-size: 10.5px;
    margin-bottom: 6px;
}
.astrovip_plan_label { color: var(--text-muted); }
.astrovip_plan_value { color: var(--text-main); font-weight: 600; }
.astrovip_plan_value_cyan { color: var(--accent-cyan); font-weight: 700; }

.astrovip_plan_buy_link {
    text-decoration: none;
    display: block;
    margin: 12px 0;
    transition: all 0.2s ease;
    cursor: pointer;
}
.astrovip_plan_buy_link:hover .astrovip_plan_price_box {
    background: rgba(0, 224, 255, 0.15);
    border-color: rgba(0, 224, 255, 0.8);
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.3);
}

.astrovip_plan_price_box {
    position: relative;
    padding: 10px 8px;
    background: rgba(0, 224, 255, 0.06);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.40);
    border-radius: 8px;
    text-align: center;
    transition: all 0.2s ease;
}

/* 🆕 ETIQUETA DE OFERTA (dentro de la caja de precio) */
.astrovip_plan_offer_tag {
    display: inline-block;
    margin: 0 auto 6px;
    padding: 3px 10px;
    background: linear-gradient(180deg, #ef4444 0%, #991b1b 100%);
    color: #ffffff;
    font-size: 9.5px;
    font-weight: 800;
    letter-spacing: 0.6px;
    border-radius: 10px;
    box-shadow: 0 3px 10px rgba(239, 68, 68, 0.55);
    animation: astrovip_offer_pulse 1.8s infinite;
}
@keyframes astrovip_offer_pulse {
    0%, 100% { transform: scale(1);    box-shadow: 0 3px 10px rgba(239, 68, 68, 0.55); }
    50%      { transform: scale(1.08); box-shadow: 0 3px 16px rgba(239, 68, 68, 0.90); }
}

/* 🆕 PRECIO ANTIGUO TACHADO */
.astrovip_plan_price_old {
    font-size: 10.5px;
    color: #94a3b8;
    text-decoration: line-through;
    text-decoration-color: #ef4444;
    text-decoration-thickness: 2px;
    font-weight: 600;
    margin-bottom: 2px;
    opacity: 0.85;
    letter-spacing: 0.2px;
}

.astrovip_plan_price_main {
    font-size: 13px;
    font-weight: 800;
    color: var(--accent-cyan);
    letter-spacing: 0.5px;
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
}
.astrovip_plan_price_cup {
    font-size: 10.5px;
    color: var(--accent-green);
    margin-top: 4px;
    font-weight: 600;
    font-family: 'Courier New', monospace;
}

.astrovip_plan_features {
    flex: 1;
    margin: 8px 0 12px;
    padding: 8px 0;
    border-top: 1px dashed var(--border-color);
}
.astrovip_plan_features_title {
    font-size: 9.5px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.8px;
    margin-bottom: 6px;
    font-weight: 700;
}
.astrovip_plan_features ul {
    list-style: none;
    padding: 0;
    margin: 0;
    font-size: 10px;
    line-height: 1.7;
    color: var(--text-main);
}
.astrovip_plan_features li:before {
    content: "▸ ";
    color: var(--accent-cyan);
    font-weight: 700;
}
.astrovip_plan_features b { color: var(--accent-gold); font-weight: 700; }

.astrovip_daily_box {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 14px 18px;
    background: linear-gradient(90deg, rgba(0, 224, 255, 0.06) 0%, rgba(251, 191, 36, 0.06) 100%);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
}
.astrovip_daily_icon { font-size: 30px; }
.astrovip_daily_text {
    flex: 1;
    font-size: 11.5px;
    color: var(--text-main);
    line-height: 1.5;
}
.astrovip_daily_text b { color: var(--accent-gold); }
.astrovip_link_containers {
    color: var(--accent-cyan) !important;
    text-decoration: none;
    font-weight: 700;
    transition: all 0.2s ease;
}
.astrovip_link_containers:hover {
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
    text-decoration: underline;
}

.astrovip_daily_status {
    padding: 8px 16px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 700;
    white-space: nowrap;
    letter-spacing: 0.3px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astrovip_status_pending {
    background: rgba(251, 191, 36, 0.10);
    border: 1px solid rgba(251, 191, 36, 0.40);
    color: var(--accent-gold);
}
.astrovip_status_done {
    background: rgba(74, 255, 136, 0.10);
    border: 1px solid rgba(74, 255, 136, 0.40);
    color: var(--accent-green);
}

/* ===== ÚLTIMA RECOMPENSA RECIBIDA ===== */
.astrovip_last_reward {
    margin-top: 14px;
    padding: 16px 18px;
    background: linear-gradient(135deg, rgba(74, 255, 136, 0.06), rgba(0, 224, 255, 0.06));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(74, 255, 136, 0.35);
    border-radius: 12px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.3), 0 0 20px rgba(74, 255, 136, 0.1);
}

.astrovip_lr_title {
    font-size: 12.5px;
    font-weight: 800;
    color: #88ffbb;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 12px;
    text-shadow: 0 0 10px rgba(74, 255, 136, 0.4);
    display: flex;
    align-items: center;
    gap: 8px;
}

.astrovip_lr_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
    gap: 10px;
}

.astrovip_lr_item {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    padding: 10px 8px;
    background: rgba(0, 0, 0, 0.35);
    border: 1px solid rgba(0, 224, 255, 0.25);
    border-radius: 8px;
    transition: all 0.25s ease;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}

.astrovip_lr_item:hover {
    border-color: rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 224, 255, 0.3);
}

.astrovip_lr_item.astrovip_lr_bonus {
    border-color: rgba(251, 191, 36, 0.5);
}
.astrovip_lr_item.astrovip_lr_bonus:hover {
    border-color: #fbbf24;
    box-shadow: 0 4px 12px rgba(251, 191, 36, 0.4);
}

.astrovip_lr_item.astrovip_lr_chest {
    border-color: rgba(139, 92, 246, 0.5);
}
.astrovip_lr_item.astrovip_lr_chest:hover {
    border-color: #cc88ff;
    box-shadow: 0 4px 12px rgba(139, 92, 246, 0.4);
}

.astrovip_lr_icon {
    font-size: 22px;
    line-height: 1;
    filter: drop-shadow(0 0 6px rgba(255, 255, 255, 0.4));
}

.astrovip_lr_val {
    font-family: 'Courier New', monospace;
    font-size: 15px;
    font-weight: 800;
    color: #ffffff;
    letter-spacing: 0.3px;
    text-shadow: 0 0 8px rgba(255, 255, 255, 0.3);
}

.astrovip_lr_label {
    font-size: 10px;
    font-weight: 600;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* ===== COUNTDOWN PRÓXIMA RECOMPENSA ===== */
.astrovip_next_reward {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 14px;
    padding: 14px 18px;
    background: linear-gradient(90deg, rgba(251, 191, 36, 0.10), rgba(0, 224, 255, 0.10));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid rgba(251, 191, 36, 0.4);
    border-radius: 12px;
    box-shadow: 0 0 18px rgba(251, 191, 36, 0.15);
}

.astrovip_nr_icon {
    font-size: 22px;
    line-height: 1;
    animation: astrovip_nr_pulse 2s infinite;
}

@keyframes astrovip_nr_pulse {
    0%, 100% { transform: scale(1); }
    50%      { transform: scale(1.15); }
}

.astrovip_nr_label {
    font-size: 12.5px;
    font-weight: 700;
    color: #cbd5e1;
    letter-spacing: 0.5px;
}

.astrovip_nr_countdown {
    font-family: 'Courier New', monospace;
    font-size: 17px;
    font-weight: 800;
    color: #fbbf24;
    letter-spacing: 2px;
    text-shadow: 0 0 12px rgba(251, 191, 36, 0.6);
    padding: 3px 12px;
    background: rgba(0, 0, 0, 0.4);
    border-radius: 6px;
    min-width: 110px;
    text-align: center;
}

.astrovip_nr_countdown.ready {
    color: #4aff88;
    text-shadow: 0 0 14px rgba(74, 255, 136, 0.8);
    animation: astrovip_nr_ready 1s infinite;
}

@keyframes astrovip_nr_ready {
    0%, 100% { box-shadow: 0 0 0 rgba(74, 255, 136, 0); }
    50%      { box-shadow: 0 0 16px rgba(74, 255, 136, 0.6); }
}

.astrovip_footer_note {
    margin-top: 20px;
    padding: 14px 20px;
    background: rgba(0, 224, 255, 0.06);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    font-size: 11.5px;
    color: var(--text-main);
    text-align: center;
    line-height: 1.6;
}
.astrovip_footer_note b {
    color: var(--accent-cyan);
    font-weight: 700;
}

@media (max-width: 1100px) {
    .astrovip_plans_grid { grid-template-columns: repeat(3, 1fr); }
}
@media (max-width: 720px) {
    .astrovip_wrap { padding: 8px 4px !important; }
    .astrovip_panel { padding: 12px 8px !important; }
    .astrovip_title { font-size: 18px !important; }
    .astrovip_subtitle { font-size: 10px !important; }
    .astrovip_benefits_grid { grid-template-columns: 1fr !important; gap: 8px !important; }
    .astrovip_daily_box { flex-direction: column !important; text-align: center !important; padding: 10px !important; }
    .astrovip_lr_grid { grid-template-columns: repeat(2, 1fr) !important; gap: 6px !important; }
    .astrovip_next_reward { flex-direction: column !important; gap: 6px !important; text-align: center !important; padding: 10px !important; }
    .astrovip_nr_label { font-size: 10px !important; }

    /* FORZAR 1x3 EN LOS PLANES VIP */
    .astrovip_plans_grid {
        grid-template-columns: repeat(3, 1fr) !important;
        gap: 4px !important;
        margin-top: 10px !important;
    }
    .astrovip_plan {
        padding: 8px 4px 6px 4px !important;
        border-radius: 8px !important;
    }

    /* Badge POPULAR más pequeño */
    .astrovip_plan_badge {
        font-size: 7px !important;
        padding: 2px 6px !important;
        top: -8px !important;
        white-space: nowrap !important;
    }

    /* Nombres y Filas */
    .astrovip_plan_name {
        font-size: 9px !important;
        margin-bottom: 6px !important;
        padding-bottom: 6px !important;
        line-height: 1.2 !important;
    }
    .astrovip_plan_row {
        flex-direction: column !important; /* Apila el label y el valor para ganar espacio horizontal */
        align-items: center !important;
        gap: 2px !important;
        margin-bottom: 6px !important;
    }
    .astrovip_plan_label { font-size: 7px !important; }
    .astrovip_plan_value { font-size: 8px !important; }

    /* Caja de precio */
    .astrovip_plan_price_box { padding: 6px 2px !important; margin: 6px 0 !important; }
    .astrovip_plan_price_main { font-size: 9px !important; }
    .astrovip_plan_price_cup { font-size: 7px !important; margin-top: 2px !important; }

    /* 🆕 Oferta en móvil — compacta */
    .astrovip_plan_offer_tag { font-size: 6.5px !important; padding: 2px 5px !important; margin-bottom: 3px !important; }
    .astrovip_plan_price_old { font-size: 7.5px !important; margin-bottom: 1px !important; }

    /* Lista de características */
    .astrovip_plan_features { margin: 4px 0 !important; padding: 4px 0 !important; }
    .astrovip_plan_features_title { font-size: 7px !important; text-align: center !important; margin-bottom: 2px !important; }
    .astrovip_plan_features ul {
        font-size: 7px !important;
        line-height: 1.2 !important;
        text-align: center !important;
        padding: 0 !important;
    }
    .astrovip_plan_features li:before {
        display: none !important; /* Ocultamos el puntito "▸" porque quita mucho espacio */
    }

    /* Ajustes finales del pie de página */
    .astrovip_footer_note { font-size: 10px !important; padding: 10px !important; }
}
</style>

{* ============================================================
   JS: Countdown para la próxima recompensa VIP diaria
   ============================================================ *}
<script>
(function() {
    var el = document.getElementById('astrovip_countdown');
    if (!el) return;
    var box = el.closest('.astrovip_next_reward');
    if (!box) return;

    var nextTime = parseInt(box.getAttribute('data-next-reward') || '0', 10);
    if (nextTime <= 0) return;

    function pad(n) { return n < 10 ? '0' + n : n; }

    function formatCountdown(seconds) {
        if (seconds <= 0) return 'Listo';
        var d = Math.floor(seconds / 86400);
        var h = Math.floor((seconds % 86400) / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        var s = seconds % 60;
        if (d > 0) return d + 'd ' + pad(h) + ':' + pad(m) + ':' + pad(s);
        return pad(h) + ':' + pad(m) + ':' + pad(s);
    }

    function tick() {
        var now = Math.floor(Date.now() / 1000);
        var diff = nextTime - now;
        if (diff <= 0) {
            el.textContent = '✅ ¡Disponible ahora!';
            el.classList.add('ready');
            return;
        }
        el.textContent = formatCountdown(diff);
    }

    tick();
    setInterval(tick, 1000);
})();
</script>

{/block}