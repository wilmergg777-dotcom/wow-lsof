{block name="title" prepend}Ajuste Manual CUP{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   AJUSTE MANUAL CUP — Formulario Superadmin
   AstroIO v3.0 — Glassmorphism + Acento Dorado
   Prefijo: .wallet-ajuste_
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

.wallet-ajuste_wrapper {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: var(--text-main);
    padding: 16px 20px;
    border-radius: 12px;
    border: 1px solid var(--border-color);
    max-width: 720px;
    margin: 0 auto;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    box-sizing: border-box;
}

.wallet-ajuste_title {
    color: var(--accent-gold);
    font-size: 16px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 14px;
    padding-bottom: 10px;
    border-bottom: 1px solid rgba(251, 191, 36, 0.3);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    flex-wrap: wrap;
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.35);
}
.wallet-ajuste_title .admin-info {
    font-size: 11px;
    color: var(--text-muted);
    font-weight: normal;
    text-transform: none;
    letter-spacing: 0;
    text-shadow: none;
}

/* ─── BOTÓN VOLVER ───────────────────────────────────────── */
.wallet-ajuste_back {
    display: inline-block;
    color: var(--text-muted);
    font-size: 11px;
    text-decoration: none;
    margin-bottom: 14px;
    transition: 0.25s ease;
    padding: 4px 10px;
    border-radius: 5px;
    border: 1px solid var(--border-color);
    background: rgba(0, 0, 0, 0.2);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.wallet-ajuste_back:hover {
    color: var(--accent-cyan);
    border-color: rgba(0, 224, 255, 0.5);
    background: rgba(0, 224, 255, 0.08);
    transform: translateY(-1px);
}

/* ─── FEEDBACK ───────────────────────────────────────────── */
.wallet-ajuste_msg_error {
    background: rgba(239, 68, 68, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-red);
    color: var(--accent-red);
    padding: 10px 14px;
    border-radius: 6px;
    margin-bottom: 14px;
    font-size: 11px;
}

/* ─── AVISO SUPERADMIN ───────────────────────────────────── */
.wallet-ajuste_warn {
    background: linear-gradient(135deg, rgba(251, 191, 36, 0.15) 0%, rgba(139, 92, 246, 0.08) 100%);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(251, 191, 36, 0.4);
    border-radius: 10px;
    padding: 12px 16px;
    margin-bottom: 16px;
    font-size: 11px;
    line-height: 1.7;
    color: var(--accent-gold);
}
.wallet-ajuste_warn strong {
    color: var(--accent-gold);
    display: block;
    margin-bottom: 4px;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* ─── INFO BOX ───────────────────────────────────────────── */
.wallet-ajuste_info {
    background: rgba(0, 224, 255, 0.05);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 8px;
    padding: 10px 14px;
    margin-bottom: 16px;
    font-size: 11px;
    line-height: 1.7;
}
.wallet-ajuste_info strong {
    color: var(--accent-cyan);
    display: block;
    margin-bottom: 4px;
}
.wallet-ajuste_info code {
    background: rgba(0, 0, 0, 0.3);
    padding: 2px 6px;
    border-radius: 4px;
    color: var(--accent-gold);
    font-family: 'Courier New', monospace;
    font-size: 11px;
}

/* ─── FORM BOX ───────────────────────────────────────────── */
.wallet-ajuste_form_box {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 18px 20px;
}

.wallet-ajuste_label {
    color: var(--accent-gold);
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
    display: block;
    font-weight: bold;
}
.wallet-ajuste_label .required {
    color: var(--accent-red);
    font-size: 11px;
    margin-left: 3px;
}

/* ─── SELECT E INPUT ─────────────────────────────────────── */
.wallet-ajuste_input_group {
    display: flex;
    align-items: stretch; /* Fuerza a que el input y select tengan la misma altura */
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(251, 191, 36, 0.4);
    border-radius: 8px;
    margin-bottom: 16px;
    transition: 0.25s ease;
    min-height: 46px; /* Altura mínima para que no se aplaste */
}

.wallet-ajuste_input_group:focus-within {
    border-color: var(--accent-gold);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.35);
}

.wallet-ajuste_input_group input {
    flex: 1;
    background: transparent;
    border: none;
    padding: 0 16px; /* Padding solo horizontal, la altura la da el flex */
    color: var(--text-main);
    font-size: 15px;
    font-family: 'Courier New', monospace;
    outline: none;
    font-weight: bold;
    letter-spacing: 0.5px;
    min-width: 0;
    box-sizing: border-box;
}

/* 🔥 FIX: Select con fondo sólido, altura controlada y texto centrado */
.wallet-ajuste_input_group select {
    flex: 1;
    padding: 0 40px 0 16px; /* Padding derecho para la flecha */
    background-color: #0f1624 !important; 
    border: none !important;
    color: #ffffff !important;
    font-weight: 700;
    font-size: 13px;
    font-family: inherit;
    cursor: pointer;
    outline: none;
    
    /* Ocultar flecha por defecto del navegador */
    appearance: none;
    -webkit-appearance: none;
    -moz-appearance: none;
    
    /* Poner flecha personalizada */
    background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23fbbf24'%3e%3cpath d='M7 10l5 5 5-5z'/%3e%3c/svg%3e");
    background-repeat: no-repeat;
    background-position: right 12px center;
    background-size: 20px;
    
    width: 100%;
    line-height: normal; /* Centra el texto verticalmente */
    box-sizing: border-box;
}

.wallet-ajuste_input_group select:focus {
    color: #ffffff !important;
    background-color: #0f1624 !important;
}

.wallet-ajuste_input_group select option {
    background-color: #0f1624 !important;
    color: #ffffff !important;
    padding: 10px;
}

.wallet-ajuste_input_group input::placeholder {
    color: #4a5a72;
    font-style: italic;
    letter-spacing: 0;
    font-family: 'Segoe UI', sans-serif;
    font-weight: normal;
}

.wallet-ajuste_input_suffix {
    padding: 0 18px;
    background: rgba(251, 191, 36, 0.1);
    color: var(--accent-gold);
    font-weight: bold;
    display: flex;
    align-items: center;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    white-space: nowrap;
}

/* ─── TEXTAREA ───────────────────────────────────────────── */
.wallet-ajuste_textarea {
    width: 100%;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 12px 14px;
    color: var(--text-main);
    font-size: 12px;
    font-family: 'Segoe UI', sans-serif;
    box-sizing: border-box;
    resize: vertical;
    min-height: 80px;
    outline: none;
    margin-bottom: 16px;
    transition: 0.25s ease;
}
.wallet-ajuste_textarea:focus {
    border-color: var(--accent-gold);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.35);
}
.wallet-ajuste_textarea::placeholder {
    color: #4a5a72;
    font-style: italic;
}

/* ─── HELP TEXT ──────────────────────────────────────────── */
.wallet-ajuste_help {
    font-size: 10.5px;
    color: var(--text-muted);
    font-style: italic;
    margin-top: -10px;
    margin-bottom: 16px;
    line-height: 1.5;
}
.wallet-ajuste_help strong {
    color: var(--accent-cyan);
    font-style: normal;
}

/* ─── SIGN HELPERS ───────────────────────────────────────── */
.wallet-ajuste_signs {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 16px;
}
.wallet-ajuste_sign_card {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 11px;
    line-height: 1.6;
}
.wallet-ajuste_sign_card.pos {
    border-color: rgba(74, 255, 136, 0.3);
    background: rgba(74, 255, 136, 0.05);
}
.wallet-ajuste_sign_card.neg {
    border-color: rgba(239, 68, 68, 0.3);
    background: rgba(239, 68, 68, 0.05);
}
.wallet-ajuste_sign_card .title {
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    font-size: 10px;
    margin-bottom: 4px;
    display: block;
}
.wallet-ajuste_sign_card.pos .title { color: var(--accent-green); }
.wallet-ajuste_sign_card.neg .title { color: var(--accent-red); }
.wallet-ajuste_sign_card .example {
    font-family: 'Courier New', monospace;
    color: var(--text-main);
    font-size: 12px;
    font-weight: bold;
}

/* ─── BOTONES ────────────────────────────────────────────── */
.wallet-ajuste_btn {
    display: block;
    width: 100%;
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
    border: 1px solid var(--accent-gold);
    padding: 14px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: bold;
    cursor: pointer;
    text-align: center;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: 0.25s ease;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    box-sizing: border-box;
    margin-top: 6px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
}
.wallet-ajuste_btn:hover {
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.55);
    transform: translateY(-2px);
    color: #1a1000;
}

.wallet-ajuste_btn_cancel {
    display: block;
    width: 100%;
    background: rgba(30, 41, 59, 0.85);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    color: var(--text-main);
    padding: 12px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: bold;
    text-decoration: none;
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    transition: 0.25s ease;
    margin-top: 10px;
    box-sizing: border-box;
}
.wallet-ajuste_btn_cancel:hover {
    box-shadow: 0 0 14px rgba(148, 163, 184, 0.35);
    transform: translateY(-2px);
    color: var(--text-main);
}

/* ─── EMPTY ──────────────────────────────────────────────── */
.wallet-ajuste_empty {
    text-align: center;
    padding: 30px 20px;
    color: var(--text-muted);
    font-size: 12px;
    font-style: italic;
}
.wallet-ajuste_empty .icon {
    font-size: 32px;
    margin-bottom: 10px;
    display: block;
}

/* ─── RESPONSIVE ─────────────────────────────────────────── */
@media (max-width: 720px) {
    .wallet-ajuste_wrapper { padding: 12px 14px; }
    .wallet-ajuste_title { font-size: 13px; }
    .wallet-ajuste_input_group input { font-size: 14px; padding: 0 12px; }
    .wallet-ajuste_input_group select { font-size: 13px; padding: 0 30px 0 12px; }
    .wallet-ajuste_input_suffix { padding: 0 12px; font-size: 10px; }
    .wallet-ajuste_signs { grid-template-columns: 1fr; }
}
</style>

<div class="wallet-ajuste_wrapper">

    {* ─── HEADER ─────────────────────────────────────────── *}
    <div class="wallet-ajuste_title">
        <span>⚙️ Ajuste Manual de CUP</span>
        <span class="admin-info">Superadmin: <strong>{$username}</strong></span>
    </div>

    {* ─── BOTÓN VOLVER ───────────────────────────────────── *}
    <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-ajuste_back">
        ← Volver a Saldo CUP
    </a>

    {* ─── FEEDBACK ERROR ─────────────────────────────────── *}
    {if $feedback_error != ''}
        <div class="wallet-ajuste_msg_error">
            ❌ {$feedback_error|escape:'html'}
        </div>
    {/if}

    {* ─── AVISO SUPERADMIN ───────────────────────────────── *}
    <div class="wallet-ajuste_warn">
        <strong>⚠️ Zona restringida — Solo Superadmin</strong>
        Esta acción modifica el saldo CUP directamente. 
        Queda registrada en el historial con tu nombre y el motivo. 
        Ninguna operación de ajuste puede ser eliminada ni revertida sin dejar rastro.
    </div>

    {* ─── INFO ───────────────────────────────────────────── *}
    <div class="wallet-ajuste_info">
        <strong>ℹ️ ¿Qué es un ajuste manual?</strong>
        Es una corrección contable directa al saldo CUP de un admin. Se usa para:
        <br>• Corregir errores de cálculo
        <br>• Compensar transferencias fallidas
        <br>• Autorizar créditos o débitos extraordinarios
        <br><br>
        El movimiento queda registrado con tipo <code>ajuste_manual</code>.
    </div>

    {* ─── FORMULARIO ─────────────────────────────────────── *}
    <div class="wallet-ajuste_form_box">

        {if $admins|@count > 0}

            <form method="POST" action="{$action_url}" id="wallet_ajuste_form">

                {* ─── ADMIN DESTINO ─── *}
                <label class="wallet-ajuste_label">
                    👤 Admin a ajustar <span class="required">*</span>
                </label>
                <div class="wallet-ajuste_input_group">
                    <select name="admin_id" required>
                        <option value="" style="color: #94a3b8;">— Elegí un admin —</option>
                        {foreach $admins as $adm}
                            <option value="{$adm.admin_id}">{$adm.username|escape:'html'} (Nivel {$adm.authlevel}) — Saldo: {$adm.saldo} CUP</option>
                        {/foreach}
                    </select>
                </div>

                {* ─── MONTO ─── *}
                <label class="wallet-ajuste_label">
                    💰 Monto del ajuste <span class="required">*</span>
                </label>
                <div class="wallet-ajuste_input_group">
                    <input
                        type="number"
                        name="monto"
                        id="wallet_ajuste_monto"
                        step="0.01"
                        placeholder="Ej: 500.00 o -250.00"
                        required
                        autocomplete="off"
                    >
                    <span class="wallet-ajuste_input_suffix">CUP</span>
                </div>

                {* ─── AYUDA DE SIGNO ─── *}
                <div class="wallet-ajuste_signs">
                    <div class="wallet-ajuste_sign_card pos">
                        <span class="title">✚ Positivo = Suma</span>
                        <span class="example">+500.00 → saldo sube 500</span>
                    </div>
                    <div class="wallet-ajuste_sign_card neg">
                        <span class="title">− Negativo = Resta</span>
                        <span class="example">-250.00 → saldo baja 250</span>
                    </div>
                </div>

                <div class="wallet-ajuste_help">
                    💡 Podés dejar el saldo en <strong>negativo</strong> si lo forzás (útil para registrar deudas).
                </div>

                {* ─── MOTIVO ─── *}
                <label class="wallet-ajuste_label">
                    📝 Motivo del ajuste <span class="required">*</span>
                </label>
                <textarea
                    name="motivo"
                    class="wallet-ajuste_textarea"
                    placeholder="Ej: Corrección de inversión #42 mal acreditada. Verificado con el usuario."
                    maxlength="255"
                    minlength="3"
                    required
                ></textarea>
                <div class="wallet-ajuste_help">
                    Mínimo <strong>3 caracteres</strong> · Máximo <strong>255 caracteres</strong> · Queda en el historial
                </div>

                {* ─── BOTÓN CONFIRMAR ─── *}
                <button type="submit" class="wallet-ajuste_btn"
                        onclick="return confirm('¿Confirmar el ajuste manual?\n\nEsta acción modifica el saldo CUP del admin seleccionado.\nQueda registrada en el historial con tu nombre.\n\n¿Continuar?');">
                    ⚙️ Aplicar ajuste
                </button>

                {* ─── BOTÓN CANCELAR ─── *}
                <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-ajuste_btn_cancel">
                    ← Cancelar y volver
                </a>

            </form>

        {else}

            <div class="wallet-ajuste_empty">
                <span class="icon">👥</span>
                No hay admins registrados en el sistema.<br>
                Necesitás al menos un admin con cuenta CUP para hacer ajustes.
            </div>
            <a href="game.php?page=walletadmin&mode=saldoCup" class="wallet-ajuste_btn_cancel">
                ← Volver al panel
            </a>

        {/if}

    </div>

</div>

{/block}