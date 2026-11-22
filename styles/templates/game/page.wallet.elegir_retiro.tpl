{block name="title" prepend}Elegir Método de Retiro{/block}
{block name="content"}

<style>
/* Estilos para la pantalla de elección */
.rn-elegir-wrapper {
    background: rgba(15, 23, 42, 0.65);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    color: #ffffff;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    padding: 40px 20px;
    border-radius: 16px;
    max-width: 800px;
    margin: 40px auto;
    text-align: center;
    border: 1px solid rgba(255, 255, 255, 0.08);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
}

.rn-elegir-title {
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 10px;
    color: #00e0ff;
    text-shadow: 0 0 15px rgba(0, 224, 255, 0.4);
}

.rn-elegir-subtitle {
    font-size: 15px;
    color: #8b8c98;
    margin-bottom: 30px;
}

.rn-warning-box {
    background: rgba(251, 191, 36, 0.1);
    border: 1px solid rgba(251, 191, 36, 0.4);
    border-radius: 10px;
    padding: 15px;
    color: #fbbf24;
    font-size: 14px;
    margin-bottom: 40px;
    line-height: 1.6;
    text-align: left;
}

.rn-warning-box strong {
    color: #fff;
}

.rn-opciones-grid {
    display: flex;
    gap: 20px;
    justify-content: center;
    flex-wrap: wrap;
}

.rn-opcion-card {
    background: rgba(30, 41, 59, 0.8);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 30px 20px;
    flex: 1;
    min-width: 280px;
    max-width: 350px;
    transition: all 0.3s ease;
    cursor: pointer;
    display: flex;
    flex-direction: column;
    align-items: center;
}

.rn-opcion-card:hover {
    transform: translateY(-5px);
    border-color: #00e0ff;
    box-shadow: 0 10px 25px rgba(0, 224, 255, 0.2);
}

.rn-opcion-card.qvapay:hover {
    border-color: #4aff88;
    box-shadow: 0 10px 25px rgba(74, 255, 136, 0.2);
}

.rn-opcion-icon {
    font-size: 50px;
    margin-bottom: 15px;
}

.rn-opcion-title {
    font-size: 20px;
    font-weight: 700;
    margin-bottom: 10px;
}

.rn-opcion-card.cup .rn-opcion-title { color: #00e0ff; }
.rn-opcion-card.qvapay .rn-opcion-title { color: #4aff88; }

.rn-opcion-desc {
    font-size: 13px;
    color: #cbd5e1;
    margin-bottom: 25px;
    line-height: 1.5;
    flex-grow: 1;
}

.rn-btn-elegir {
    width: 100%;
    padding: 15px;
    border-radius: 30px;
    font-size: 14px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border: none;
    cursor: pointer;
    transition: 0.2s;
}

.rn-opcion-card.cup .rn-btn-elegir {
    background: rgba(0, 224, 255, 0.15);
    color: #00e0ff;
    border: 1px solid #00e0ff;
}
.rn-opcion-card.cup:hover .rn-btn-elegir {
    background: #00e0ff;
    color: #000;
}

.rn-opcion-card.qvapay .rn-btn-elegir {
    background: rgba(74, 255, 136, 0.15);
    color: #4aff88;
    border: 1px solid #4aff88;
}
.rn-opcion-card.qvapay:hover .rn-btn-elegir {
    background: #4aff88;
    color: #000;
}
</style>

<div class="rn-elegir-wrapper">
    <div class="rn-elegir-title">Configuración Inicial del Banco</div>
    <div class="rn-elegir-subtitle">Antes de empezar, necesitamos saber cómo querés operar.</div>

    <div class="rn-warning-box">
        ⚠️ <strong>ELECCIÓN PERMANENTE:</strong> Solo podés elegir tu método de retiro <strong>UNA SOLA VEZ</strong>. Una vez confirmado, el sistema bloqueará los retiros por el otro método. Si te equivocás, tendrás que contactar a un administrador para que te lo cambie manualmente.
    </div>

    <form method="POST" action="game.php?page=wallet&mode=guardar_metodo">
        <div class="rn-opciones-grid">
            
            <!-- OPCIÓN CUP -->
            <div class="rn-opcion-card cup" onclick="document.getElementById('btnCup').click();">
                <div class="rn-opcion-icon">🇨🇺</div>
                <div class="rn-opcion-title">Sistema Nacional (CUP)</div>
                <div class="rn-opcion-desc">
                    Retira tus ganancias en efectivo mediante transferencia bancaria nacional.<br><br>
                    <strong>⚠️ Requiere cargar tarjeta y teléfono cubano.</strong>
                </div>
                <button type="submit" name="metodo" value="CUP" class="rn-btn-elegir" id="btnCup">
                    Elegir CUP
                </button>
            </div>

            <!-- OPCIÓN QVAPAY -->
            <div class="rn-opcion-card qvapay" onclick="document.getElementById('btnQvapay').click();">
                <div class="rn-opcion-icon">🌐</div>
                <div class="rn-opcion-title">Internacional (QvaPay)</div>
                <div class="rn-opcion-desc">
                    Retira tus ganancias en divisas (USD/EUR) directo a tu cuenta de QvaPay.<br><br>
                    <strong>✅ No requiere datos bancarios cubanos.</strong>
                </div>
                <button type="submit" name="metodo" value="QVAPAY" class="rn-btn-elegir" id="btnQvapay">
                    Elegir QvaPay
                </button>
            </div>

        </div>
    </form>
</div>

{/block}