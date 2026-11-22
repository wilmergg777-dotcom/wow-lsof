{block name="content"}

{* ============================================================ *}
{* 💎 RETIRAR PUNTOS WAR → NTX-20                                *}
{* ============================================================ *}

<div class="astrowallet_wrap">
<div class="astrowallet_panel">

    <div class="astrowallet_title">💎 Retirar Puntos WAR</div>

    {* Feedback *}
    {if $feedback_error}
        <div class="astrowallet_msg astrowallet_msg-error">
            <strong>❌ Error</strong>
            {$feedback_error}
        </div>
    {/if}

    {* Header con balance *}
    <div class="astrowallet_header">
        <div class="astrowallet_header_item">
            <div class="astrowallet_header_label">🎯 Tus Puntos WAR</div>
            <div class="astrowallet_header_value astrowallet_wp">{$war_points}</div>
        </div>
        <div class="astrowallet_header_arrow">→</div>
        <div class="astrowallet_header_item">
            <div class="astrowallet_header_label">💲 NTX-20 que recibirás</div>
            <div class="astrowallet_header_value astrowallet_ntx">{$nxt20_estimado}</div>
        </div>
    </div>

    {* Info *}
    <div class="astrowallet_info">
        <b>ℹ️ ¿Cómo funciona?</b><br>
        · El retiro convierte todos tus puntos WAR acumulados a <b>NTX-20</b>.<br>
        · Tasa de conversión: <b>1 punto WAR = 1 NTX-20</b>.<br>
        · Los NTX-20 se te acreditan en el <b>planeta principal</b>.<br>
        · El retiro es <b>único y total</b>: no se puede retirar parcialmente.<br>
        · <b>Solo se puede retirar cuando el admin cierra la temporada</b>.
    </div>

    {* Formulario *}
    {if $war_points_raw > 0}
        <form method="post" action="{$action_url}" class="astrowallet_form">
            <input type="hidden" name="confirm" value="1">

            <div class="astrowallet_confirm_box">
                <p style="margin: 0 0 10px; text-align: center; font-size: 13px; color: #fff;">
                    ¿Confirmás que querés retirar <b>{$war_points}</b> puntos WAR?
                </p>
                <p style="margin: 0; text-align: center; font-size: 12px; color: #8b8c98;">
                    Recibirás <b style="color:#4aff88;">{$nxt20_estimado} NTX-20</b> en tu planeta principal.
                </p>
            </div>

            <div style="text-align: center; margin-top: 16px;">
                <button type="submit"
                        class="astrowallet_btn astrowallet_btn-ok"
                        onclick="return confirm('¿Confirmás el retiro de TODOS tus puntos WAR? Esta accion no se puede deshacer.');">
                    💎 RETIRAR {$war_points} WAR → NTX-20
                </button>
                <a href="game.php?page=wallet" class="astrowallet_btn astrowallet_btn-gray">
                    ❌ Cancelar
                </a>
            </div>
        </form>
    {else}
        <div class="astrowallet_empty">
            ⚠️ No tenés puntos WAR para retirar.<br>
            <span style="font-size: 11.5px; color: #8b8c98; margin-top: 6px; display: inline-block;">
                Los puntos se ganan participando en batallas del sistema de Guerra WAR.
            </span>
        </div>

        <div style="text-align: center; margin-top: 16px;">
            <a href="game.php?page=war" class="astrowallet_btn">
                ⚔️ Ir a Guerra WAR
            </a>
            <a href="game.php?page=wallet" class="astrowallet_btn astrowallet_btn-gray">
                ◀️ Volver al Wallet
            </a>
        </div>
    {/if}

</div>
</div>

<style>
/* ═══════════════════════════════════════════════════════════
   RETIRAR PUNTOS WAR → NTX-20 — Estilo Web3 (Ronin/Kriptomat)
   ═══════════════════════════════════════════════════════════ */

@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
    --rn-bg:          rgba(15, 23, 42, 0.65);
    --rn-card:        rgba(15, 23, 42, 0.85);
    --rn-border:      rgba(255, 255, 255, 0.08);
    --rn-text-main:   #ffffff;
    --rn-text-muted:  #8b8c98;
    --rn-blue:        #2b6bf3;
    --rn-cyan:        #00e0ff;
    --rn-green:       #4aff88;
    --rn-red:         #ef4444;
    --rn-purple:      #8b5cf6;
    --rn-gold:        #fbbf24;
}

.astrowallet_wrap {
    max-width: 750px;
    margin: 15px auto 0 auto;
    padding: 0;
    text-align: center;
}

.astrowallet_panel {
    display: inline-block;
    text-align: left;
    padding: 20px;
    background: var(--rn-bg);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid var(--rn-border);
    border-radius: 16px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
    color: var(--rn-text-main);
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 12px;
    min-width: 100%;
    max-width: 700px;
    box-sizing: border-box;
}

.astrowallet_title {
    font-size: 18px;
    font-weight: 700;
    color: var(--rn-text-main);
    text-align: left;
    padding-bottom: 12px;
    margin-bottom: 16px;
    border-bottom: 1px solid var(--rn-border);
    display: flex;
    align-items: center;
    gap: 8px;
}

.astrowallet_msg {
    padding: 12px 16px;
    margin-bottom: 16px;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 600;
    border: 1px solid transparent;
}

.astrowallet_msg-error {
    background: rgba(239, 68, 68, 0.1);
    border-color: rgba(239, 68, 68, 0.3);
    color: var(--rn-red);
}

.astrowallet_msg-error strong {
    display: block;
    margin-bottom: 4px;
    font-size: 13px;
}

.astrowallet_header {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 24px;
    padding: 16px;
    margin-bottom: 16px;
    background: var(--rn-card);
    border: 1px solid var(--rn-border);
    border-radius: 12px;
    flex-wrap: wrap;
}

.astrowallet_header_item {
    text-align: center;
}

.astrowallet_header_label {
    font-size: 11px;
    color: var(--rn-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 6px;
    font-weight: 500;
}

.astrowallet_header_value {
    font-size: 24px;
    font-weight: 700;
    font-family: 'Inter', monospace;
}

.astrowallet_wp {
    color: var(--rn-gold);
}

.astrowallet_ntx {
    color: var(--rn-green);
}

.astrowallet_header_arrow {
    font-size: 22px;
    color: var(--rn-cyan);
    font-weight: 700;
}

.astrowallet_info {
    padding: 14px 16px;
    margin-bottom: 16px;
    background: rgba(0, 224, 255, 0.08);
    border-left: 3px solid var(--rn-cyan);
    border-radius: 10px;
    font-size: 12px;
    color: var(--rn-text-main);
    line-height: 1.6;
}

.astrowallet_info b { color: var(--rn-cyan); }

.astrowallet_form {
    margin-top: 12px;
}

.astrowallet_confirm_box {
    padding: 16px;
    background: rgba(0, 0, 0, 0.2);
    border: 1px dashed var(--rn-border);
    border-radius: 12px;
}

.astrowallet_empty {
    padding: 24px;
    text-align: center;
    background: rgba(251, 191, 36, 0.1);
    border: 1px solid rgba(251, 191, 36, 0.3);
    border-radius: 12px;
    color: var(--rn-gold);
    font-size: 13px;
    line-height: 1.6;
}

.astrowallet_btn {
    display: inline-block;
    padding: 10px 24px;
    margin: 6px 4px;
    font-weight: 600;
    font-size: 12px;
    color: #ffffff;
    background: var(--rn-blue);
    border: none;
    border-radius: 30px;
    cursor: pointer;
    transition: 0.25s ease;
    text-decoration: none;
    text-align: center;
    font-family: 'Inter', sans-serif;
}

.astrowallet_btn:hover {
    background: #1a5be0;
    color: #ffffff;
    transform: translateY(-1px);
}

.astrowallet_btn-ok {
    background: var(--rn-green);
    color: #000000;
}

.astrowallet_btn-ok:hover {
    background: #3be673;
    color: #000000;
}

.astrowallet_btn-gray {
    background: rgba(255, 255, 255, 0.1);
    border: 1px solid var(--rn-border);
    color: var(--rn-text-main);
}

.astrowallet_btn-gray:hover {
    background: rgba(255, 255, 255, 0.2);
    color: var(--rn-text-main);
    transform: translateY(-1px);
}
</style>

{/block}