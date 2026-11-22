{block name="content"}

<style>
{literal}
/* Estilos del Hub Pirata - Inspirado en PvP y VIP de AstroIO */
.hub_wrap { max-width: 1000px; margin: 20px auto; padding: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; }
.hub_title { font-size: 32px; color: #fff; margin-bottom: 10px; text-shadow: 0 0 15px rgba(0, 224, 255, 0.8), 0 0 5px #00e0ff; font-weight: 800; letter-spacing: 2px; }
.hub_subtitle { color: #a4b0c2; font-size: 14px; margin-bottom: 20px; }

.hub_balance { display: inline-flex; gap: 20px; background: rgba(0, 0, 0, 0.4); border: 1px solid #00e0ff; border-radius: 20px; padding: 8px 25px; margin-bottom: 30px; font-size: 14px; font-weight: 700; color: #00e0ff; box-shadow: 0 0 15px rgba(0, 224, 255, 0.3); }
.hub_balance span { color: #fbbf24; }

/* Grilla de Juegos */
.hub_grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 20px; }

/* Tarjetas */
.hub_card {
    background: linear-gradient(180deg, rgba(15, 23, 42, 0.85) 0%, rgba(10, 15, 26, 0.95) 100%);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid #2a3a5a;
    border-radius: 12px;
    padding: 25px 20px;
    position: relative;
    overflow: hidden;
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    min-height: 250px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4);
}

.hub_card:hover {
    transform: translateY(-5px);
    border-color: #00e0ff;
    box-shadow: 0 10px 30px rgba(0, 224, 255, 0.2);
}

.hub_card.locked:hover {
    border-color: #4a4a5a;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    transform: none;
}

/* CORRECCIÓN DEL ICONO Y TÍTULO AQUÍ */
.hub_card_icon { 
    font-size: 50px; 
    margin-bottom: 15px; 
    filter: drop-shadow(0 0 10px rgba(255,255,255,0.2)); 
    display: block; 
    line-height: 1; 
    text-align: center;
}
.hub_card_title { 
    font-size: 20px; 
    font-weight: 800; 
    color: #fff; 
    margin-bottom: 10px; 
    letter-spacing: 1px; 
    text-transform: uppercase; 
    display: block;
}
.hub_card_desc { 
    font-size: 13px; 
    color: #94a3b8; 
    margin-bottom: 20px; 
    flex-grow: 1; 
    line-height: 1.5; 
}

/* Botones de las tarjetas */
.hub_btn {
    display: block; width: 100%; padding: 14px 0; border-radius: 8px; border: none;
    font-size: 14px; font-weight: 800; text-transform: uppercase; text-decoration: none;
    transition: all 0.3s ease; cursor: pointer; letter-spacing: 1px;
}

/* Botón Activo (Juego Principal) */
.hub_btn_gold { background: linear-gradient(135deg, #b45309, #f59e0b); color: #fff; box-shadow: 0 4px 15px rgba(245, 158, 11, 0.4); }
.hub_btn_gold:hover { background: linear-gradient(135deg, #f59e0b, #fbbf24); box-shadow: 0 6px 20px rgba(251, 191, 36, 0.6); transform: scale(1.02); }

/* Botón Bloqueado */
.hub_btn_locked { background: rgba(255, 255, 255, 0.05); color: #64748b; cursor: not-allowed; border: 1px solid rgba(255,255,255,0.05); }

/* Tarjeta Activa */
.hub_card.active {
    border-color: #fbbf24;
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.15);
}
.hub_card.active .hub_card_icon { filter: drop-shadow(0 0 15px rgba(251, 191, 36, 0.6)); }
.hub_card.active:hover { border-color: #fbbf24; box-shadow: 0 10px 30px rgba(251, 191, 36, 0.3); }

/* Etiqueta de "Próximamente" */
.hub_badge_soon {
    position: absolute; top: 15px; right: -30px; background: #ef4444; color: white;
    font-size: 10px; font-weight: bold; padding: 3px 30px; transform: rotate(45deg);
    box-shadow: 0 2px 5px rgba(0,0,0,0.5); letter-spacing: 1px; z-index: 10;
}

@media (max-width: 768px) {
    .hub_grid { grid-template-columns: 1fr; }
    .hub_title { font-size: 24px; }
}
</style>
{/literal}

<div class="hub_wrap">
    
    <div class="hub_title">🏴‍☠️ LA CUEVA PIRATA 🏴‍☠️</div>
    <div class="hub_subtitle">Bienvenido al Mercado Pirata. Elegí tu juego y demostrá quién manda en los mares.</div>
    
    <div class="hub_balance">
        <div>💲 Saldo: <span>{$saldo_riel|number_format:0:',':'.'} {$moneda_riel}</span></div>
        <div>🟣 MO: <span>{$saldo_darkmatter|number_format:0:',':'.'}</span></div>
    </div>

    <div class="hub_grid">
        
        <!-- JUEGO 1: Hundir la Flota (ACTIVO) -->
        <div class="hub_card active">
            <div>
                <div class="hub_card_icon">🚢</div>
                <div class="hub_card_title">Hundir la Flota</div>
                <div class="hub_card_desc">Duelo 1v1 por turnos. Apostá tus NTX-20, posicioná tu flota y destruí las 20 casillas de tu rival.</div>
            </div>
            <a href="game.php?page=cuevaFlota" class="hub_btn hub_btn_gold">Jugar Ahora</a>
        </div>

        <!-- JUEGO 2: Ajedrez (ACTIVO) -->
        <div class="hub_card active">
            <div>
                <div class="hub_card_icon">♟️</div>
                <div class="hub_card_title">Ajedrez Pirata</div>
                <div class="hub_card_desc">Duelo 1v1 clásico. Jugá con blancas o negras, demostrá tu estrategia y llevate el pozo con un jaque mate.</div>
            </div>
            <a href="game.php?page=cuevaFlota&juego=ajedrez" class="hub_btn hub_btn_gold">Jugar Ahora</a>
        </div>

        <!-- JUEGO 3: Dados (BLOQUEADO) -->
        <div class="hub_card locked">
            <div class="hub_badge_soon">PRONTO</div>
            <div>
                <div class="hub_card_icon" style="opacity: 0.5;">🎲</div>
                <div class="hub_card_title" style="color: #94a3b8;">Dados del Capitán</div>
                <div class="hub_card_desc">Tirá los dados contra la casa. Adiviná el número y duplicá tu apuesta al instante.</div>
            </div>
            <button class="hub_btn hub_btn_locked" disabled>Próximamente</button>
        </div>

        <!-- JUEGO 4: Blackjack (BLOQUEADO) -->
        <div class="hub_card locked">
            <div class="hub_badge_soon">PRONTO</div>
            <div>
                <div class="hub_card_icon" style="opacity: 0.5;">🃏</div>
                <div class="hub_card_title" style="color: #94a3b8;">Blackjack Pirata</div>
                <div class="hub_card_desc">El clásico juego de cartas. Sumá 21 sin pasarte y vencé al crupier para llevarte el pozo.</div>
            </div>
            <button class="hub_btn hub_btn_locked" disabled>Próximamente</button>
        </div>

    </div>

</div>

{/block}