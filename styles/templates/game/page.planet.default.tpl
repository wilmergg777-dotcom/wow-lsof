{block name="content"}

{* ============================================================
   ASTROIO PLANETARIO v4.0 — Estilo Xnova moderno + Doble Riel
   Prefijo CSS: .astropl_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Fondo semi-transparente con backdrop-filter
     - Variables :root
     - Bordes redondeados 12px
     - Hover con glow cyan
     - Todos los IDs, forms, mode, JS intactos
   FIX v3.8 (2026-10-13):
     - Ocultar bloque "Crear Luna" si el planeta YA tiene luna
       (usa la variable {$has_moon} del controlador)
   FIX v4.0 (2026-10-30) — DUAL RIEL:
     - Badge de saldo con la moneda del riel ({$moneda})
     - Droides y Crear Luna muestran {$moneda} y {$moneda_fiat}
     - Precios vienen YA multiplicados desde el controlador
     - Cero hardcodeos de "NTX-20" / "UNTX-20" / "CUP" / "USD"
     - Secciones MO intactas (Campos, Diámetro, Teletransportar)
   ============================================================ *}

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

/* ====== Tarjeta principal ====== */
.astropl_card {
    max-width: 720px;
    margin: 0 auto;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, Verdana, sans-serif;
    font-size: 11px;
    overflow: hidden;
}

/* ====== Header ====== */
.astropl_header {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
}
.astropl_header_icon {
    width: 42px;
    height: 42px;
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid var(--accent-cyan);
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.35);
}
.astropl_header_info { flex: 1; }
.astropl_header_title {
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-size: 14px;
    font-weight: 800;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.6), 0 0 15px rgba(0, 224, 255, 0.4);
}
.astropl_header_sub {
    color: #cbd5e1;
    font-size: 10.5px;
    margin-top: 3px;
    font-weight: 600;
    letter-spacing: 0.3px;
}

/* ====== Body ====== */
.astropl_body {
    padding: 12px 16px;
}

/* ====== 🆕 v4.0 — Badge de saldo ====== */
.astropl_balance_box {
    text-align: center;
    margin-bottom: 12px;
}
.astropl_balance_badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 6px 18px;
    background: rgba(0, 40, 20, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(74, 255, 136, 0.5);
    border-radius: 10px;
    font-size: 13px;
    font-weight: 700;
    color: var(--accent-green);
    box-shadow: 0 0 16px rgba(74, 255, 136, 0.25);
}
.astropl_balance_badge strong {
    color: #88ffbb;
    font-family: 'Courier New', monospace;
    font-size: 15px;
    letter-spacing: 0.5px;
}

/* ====== 🆕 v4.0 — Precio con subtítulo fiat ====== */
.astropl_price_wrap {
    display: inline-flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 1px;
    white-space: nowrap;
}
.astropl_price_main {
    color: var(--accent-gold);
    font-size: 11px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(251, 191, 36, 0.4);
}
.astropl_price_fiat {
    color: var(--accent-green);
    font-size: 9.5px;
    font-weight: 600;
    font-family: 'Courier New', monospace;
    opacity: 0.85;
}

/* ====== Mensajes ====== */
.astropl_msg {
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 10px;
    font-size: 11px;
    font-weight: 700;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astropl_msg.ok {
    background: rgba(74, 255, 136, 0.1);
    border: 1px solid rgba(74, 255, 136, 0.5);
    color: var(--accent-green);
    box-shadow: 0 0 12px rgba(74, 255, 136, 0.2);
}
.astropl_msg.err {
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.5);
    color: var(--accent-red);
    box-shadow: 0 0 12px rgba(239, 68, 68, 0.2);
}

/* ====== Secciones ====== */
.astropl_section {
    color: var(--accent-cyan);
    text-transform: uppercase;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 1.2px;
    margin: 14px 0 8px 0;
    padding-left: 8px;
    border-left: 3px solid var(--accent-cyan);
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astropl_section:first-child { margin-top: 0; }

/* ====== Bloques internos ====== */
.astropl_block {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-radius: 10px;
    padding: 10px 12px;
    margin-bottom: 8px;
    transition: 0.2s ease;
}
.astropl_block:hover {
    border-color: rgba(0, 224, 255, 0.35);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.1);
}
.astropl_row {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}
.astropl_row + .astropl_row {
    margin-top: 8px;
    padding-top: 8px;
    border-top: 1px solid rgba(0, 224, 255, 0.1);
}
.astropl_label {
    color: var(--text-muted);
    font-size: 10.5px;
    text-transform: uppercase;
    flex: 1;
    min-width: 120px;
    letter-spacing: 0.4px;
}
.astropl_value {
    color: var(--text-main);
    font-size: 11px;
    font-weight: 700;
    font-family: 'Courier New', monospace;
}
.astropl_value.good { color: var(--accent-green); }
.astropl_value.warn { color: var(--accent-gold); }
.astropl_value.max  { color: var(--accent-red); }

/* ====== Inputs ====== */
.astropl_input {
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 224, 255, 0.3);
    border-radius: 6px;
    color: #ffffff;
    padding: 6px 10px;
    font-size: 11px;
    width: 90px;
    font-family: 'Courier New', monospace;
    font-weight: 700;
    outline: none;
    transition: 0.25s ease;
    text-align: center;
}
.astropl_input:focus {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
}
.astropl_input.small { width: 55px; }
.astropl_input.wide  { width: 200px; text-align: left; }

/* ====== Botones ====== */
.astropl_btn {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.9), rgba(0, 153, 255, 0.9));
    border: 1px solid rgba(0, 224, 255, 0.5);
    color: #ffffff;
    padding: 7px 16px;
    border-radius: 8px;
    cursor: pointer;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    transition: 0.25s ease;
    font-family: inherit;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astropl_btn:hover {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.95), rgba(0, 224, 255, 0.95));
    box-shadow: 0 0 16px rgba(0, 224, 255, 0.6);
    transform: translateY(-2px);
}
.astropl_btn:active {
    transform: translateY(0);
}
.astropl_btn:disabled {
    background: rgba(30, 41, 59, 0.6);
    color: #64748b;
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
    border-color: rgba(100, 116, 139, 0.3);
}
.astropl_btn.alt {
    background: linear-gradient(135deg, rgba(119, 0, 204, 0.9), rgba(170, 68, 255, 0.9));
    border-color: rgba(204, 102, 255, 0.5);
}
.astropl_btn.alt:hover {
    background: linear-gradient(135deg, rgba(170, 68, 255, 0.95), rgba(204, 102, 255, 0.95));
    box-shadow: 0 0 16px rgba(170, 68, 255, 0.6);
}
.astropl_btn.ghost {
    background: rgba(0, 224, 255, 0.1);
    border: 1px solid rgba(0, 224, 255, 0.35);
    color: var(--accent-cyan);
}
.astropl_btn.ghost:hover {
    background: rgba(0, 224, 255, 0.2);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
    color: #ffffff;
}
.astropl_btn.danger {
    background: linear-gradient(135deg, rgba(136, 0, 34, 0.9), rgba(204, 0, 51, 0.9));
    border-color: rgba(239, 68, 68, 0.5);
}
.astropl_btn.danger:hover {
    background: linear-gradient(135deg, rgba(204, 0, 51, 0.95), rgba(239, 68, 68, 0.95));
    box-shadow: 0 0 16px rgba(239, 68, 68, 0.6);
}

/* ====== Footer ====== */
.astropl_footer {
    padding: 10px 16px;
    background: rgba(0, 0, 0, 0.3);
    border-top: 1px solid rgba(0, 224, 255, 0.15);
    color: var(--text-muted);
    font-size: 10px;
    text-align: center;
    letter-spacing: 0.4px;
}

/* ====== Info de cola ====== */
.astropl_queue {
    color: var(--accent-green);
    font-size: 10px;
    background: rgba(74, 255, 136, 0.08);
    border: 1px solid rgba(74, 255, 136, 0.35);
    padding: 2px 8px;
    border-radius: 6px;
    margin-left: 6px;
    display: inline-block;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(74, 255, 136, 0.4);
}

/* ====== Cooldown ====== */
.astropl_cd {
    color: var(--accent-gold);
    font-size: 10px;
    background: rgba(251, 191, 36, 0.1);
    border: 1px solid rgba(251, 191, 36, 0.35);
    padding: 2px 8px;
    border-radius: 6px;
    display: inline-block;
    margin-top: 4px;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(251, 191, 36, 0.4);
}

/* ====== Responsive ====== */
@media (max-width: 720px) {
    .astropl_card { max-width: 100%; border-radius: 0; }
    .astropl_body { padding: 10px; }
    .astropl_row { flex-direction: column; align-items: stretch; }
    .astropl_row form { width: 100%; }
    .astropl_input { width: 100%; }
    .astropl_input.small { width: 100%; }
    .astropl_input.wide { width: 100%; }
    .astropl_btn { width: 100%; }
    .astropl_price_wrap { align-items: flex-start; }
}
</style>

<div class="astropl_card">

    <!-- HEADER -->
    <div class="astropl_header">
        <div class="astropl_header_icon">🌌</div>
        <div class="astropl_header_info">
            <div class="astropl_header_title">Planetario</div>
            <div class="astropl_header_sub">{$planet_name} · [{$planet_galaxy}:{$planet_system}:{$planet_planet}]</div>
        </div>
    </div>

    <!-- BODY -->
    <div class="astropl_body">

        {* 🆕 v4.0 — Badge de saldo con moneda del riel *}
        <div class="astropl_balance_box">
            <span class="astropl_balance_badge">
                💲 Tu saldo: <strong>{$saldo_actual|number_format}</strong> {$moneda}
            </span>
        </div>

        {if $message}
            <div class="astropl_msg ok">✓ {$message}</div>
        {/if}
        {if $error}
            <div class="astropl_msg err">✗ {$error}</div>
        {/if}

        <!-- ==================== DROIDES ==================== -->
        <div class="astropl_section">🤖 Droides</div>

        <!-- Constructor -->
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label">
                    Droide Constructor <span class="astropl_value">{$droid_builder}/{$builder_max}</span>
                    <span class="astropl_queue">+{$build_queues} colas edificios</span>
                </div>
                {if $droid_builder < $builder_max}
                    {* 🆕 v4.0 — Precio con moneda dinámica *}
                    <span class="astropl_price_wrap">
                        <span class="astropl_price_main">{$builder_price|number_format} {$moneda}</span>
                        <span class="astropl_price_fiat">≈ {$builder_price|number_format} {$moneda_fiat}</span>
                    </span>
                    <form method="post" action="game.php?page=planet" style="margin:0;">
                        <input type="hidden" name="mode" value="buyBuilder">
                        <button type="submit" class="astropl_btn">Clonar</button>
                    </form>
                {else}
                    <span class="astropl_value max">MÁXIMO</span>
                {/if}
            </div>
        </div>

        <!-- Ingeniero -->
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label">
                    Droide Ingeniero <span class="astropl_value">{$droid_engineer}/{$engineer_max}</span>
                    <span class="astropl_queue">+{$tech_queues} colas investigación</span>
                </div>
                {if $droid_engineer < $engineer_max}
                    {* 🆕 v4.0 — Precio con moneda dinámica *}
                    <span class="astropl_price_wrap">
                        <span class="astropl_price_main">{$engineer_price|number_format} {$moneda}</span>
                        <span class="astropl_price_fiat">≈ {$engineer_price|number_format} {$moneda_fiat}</span>
                    </span>
                    <form method="post" action="game.php?page=planet" style="margin:0;">
                        <input type="hidden" name="mode" value="buyEngineer">
                        <button type="submit" class="astropl_btn">Clonar</button>
                    </form>
                {else}
                    <span class="astropl_value max">MÁXIMO</span>
                {/if}
            </div>
        </div>

        <!-- ==================== CREAR LUNA ==================== -->
        {if $planet_type == 1 && !$has_moon}
        <div class="astropl_section">🌕 Crear Luna</div>
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label">
                    Añadir una luna<br>
                    <span style="color:#667788;font-size:10px;text-transform:none;">Diámetro aleatorio 1000-15000</span>
                </div>
                {* 🆕 v4.0 — Precio con moneda dinámica *}
                <span class="astropl_price_wrap">
                    <span class="astropl_price_main">{$moon_price|number_format} {$moneda}</span>
                    <span class="astropl_price_fiat">≈ {$moon_price|number_format} {$moneda_fiat}</span>
                </span>
                <form method="post" action="game.php?page=planet" style="margin:0;">
                    <input type="hidden" name="mode" value="createMoon">
                    <button type="submit" class="astropl_btn">Crear Luna</button>
                </form>
            </div>
        </div>
        {/if}

        <!-- ==================== AUMENTAR CAMPOS (MO — sin cambios) ==================== -->
        <div class="astropl_section">⚙️ Aumentar Campos</div>
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label">
                    Campos actuales <span class="astropl_value">{$planet_fields} / {$field_max}</span>
                </div>
                <form method="post" action="game.php?page=planet" style="display:flex;gap:6px;align-items:center;margin:0;">
                    <input type="hidden" name="mode" value="increaseFields">
                    <input type="number" name="amount" value="1" min="1" max="500" class="astropl_input">
                    <span class="astropl_value warn" style="white-space:nowrap;">{$field_price} MO/campo</span>
                    <button type="submit" class="astropl_btn">Incrementar</button>
                </form>
            </div>
        </div>

        <!-- ==================== AUMENTAR DIÁMETRO (MO — sin cambios) ==================== -->
        <div class="astropl_section">📏 Aumentar Diámetro</div>
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label">
                    Diámetro actual <span class="astropl_value">{$planet_diameter} / {$diameter_max}</span>
                </div>
                <form method="post" action="game.php?page=planet" style="display:flex;gap:6px;align-items:center;margin:0;">
                    <input type="hidden" name="mode" value="increaseDiameter">
                    <input type="number" name="amount" value="1" min="1" max="5000" class="astropl_input">
                    <span class="astropl_value warn" style="white-space:nowrap;">{$diameter_price} MO/ud</span>
                    <button type="submit" class="astropl_btn">Incrementar</button>
                </form>
            </div>
        </div>

        <!-- ==================== TELETRANSPORTAR (MO — sin cambios) ==================== -->
        <div class="astropl_section">🚀 Teletransportar Planeta</div>
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label" style="flex:0 0 100%;">
                    Nueva posición
                    {if $teleport_cd > 0}
                        <span class="astropl_cd">⏳ Cooldown: {$teleport_cd|floor} seg</span>
                    {/if}
                </div>
            </div>
            <div class="astropl_row">
                <form method="post" action="game.php?page=planet" style="display:flex;gap:6px;align-items:center;width:100%;margin:0;">
                    <input type="hidden" name="mode" value="teleport">
                    <span style="color:#8899aa;font-size:10px;">GALAXIA</span>
                    <input type="number" name="galaxy" value="{$planet_galaxy}" min="1" class="astropl_input small">
                    <span style="color:#8899aa;font-size:10px;">SISTEMA</span>
                    <input type="number" name="system" value="{$planet_system}" min="1" class="astropl_input small">
                    <span style="color:#8899aa;font-size:10px;">POS</span>
                    <input type="number" name="planet" value="{$planet_planet}" min="1" class="astropl_input small">
                    <span class="astropl_value warn" style="margin-left:auto;white-space:nowrap;">{$teleport_price} MO</span>
                    <button type="submit" class="astropl_btn" {if $teleport_cd > 0}disabled{/if}>Teletransportar</button>
                </form>
            </div>
        </div>

        <!-- ==================== RENOMBRAR (gratis — sin cambios) ==================== -->
        <div class="astropl_section">✏️ Renombrar</div>
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label" style="flex:0 0 100%;">
                    Nuevo nombre
                    {if $rename_cd > 0}
                        <span class="astropl_cd">⏳ Cooldown: {$rename_cd} seg</span>
                    {/if}
                </div>
            </div>
            <div class="astropl_row">
                <form method="post" action="game.php?page=planet" style="display:flex;gap:6px;align-items:center;width:100%;margin:0;">
                    <input type="hidden" name="mode" value="rename">
                    <input type="text" name="new_name" id="newNameInput" maxlength="20" value="{$planet_name}" class="astropl_input wide">
                    <button type="button" class="astropl_btn ghost" onclick="genName()">🎲 Generar</button>
                    <button type="submit" class="astropl_btn alt" {if $rename_cd > 0}disabled{/if}>Renombrar</button>
                </form>
            </div>
        </div>

        <!-- ==================== ABANDONAR (gratis — sin cambios) ==================== -->
        <div class="astropl_section">❌ Abandonar Planeta</div>
        <div class="astropl_block">
            <div class="astropl_row">
                <div class="astropl_label">
                    Abandonar este planeta<br>
                    <span style="color:#ff4488;font-size:10px;text-transform:none;">⚠ Se pierden todos los recursos, naves, defensas y droides.</span>
                </div>
                <form method="post" action="game.php?page=planet" onsubmit="return confirm('¿Estás SEGURO de que quieres abandonar este planeta? Esta acción NO se puede deshacer.');" style="margin:0;">
                    <input type="hidden" name="mode" value="abandon">
                    <button type="submit" class="astropl_btn danger">Abandonar</button>
                </form>
            </div>
        </div>

    </div>

    <!-- FOOTER -->
    <div class="astropl_footer">
        Planetario AstroIO · Droides y mejoras planetarias
    </div>

</div>

<script>
function genName() {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'game.php?page=planet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function() {
        if (xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                document.getElementById('newNameInput').value = data.name;
            } catch(e) {}
        }
    };
    xhr.send('mode=generateName');
}
</script>

{/block}