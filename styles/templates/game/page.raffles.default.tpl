{block name="content"}

<style>
/* ═══════════════════════════════════════════════════════════
   RIFAS — AstroIO v3.0
   Glassmorphism + Acento Cyan
   Prefijo: .astroraffle_
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

.astroraffle_wrap {
    max-width: 900px;
    margin: 0 auto;
    text-align: center;
}
.astroraffle_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 14px;
    text-align: left;
    display: inline-block;
    width: 100%;
    box-sizing: border-box;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}
.astroraffle_title {
    text-transform: uppercase;
    color: var(--accent-cyan);
    font-size: 13px;
    font-weight: bold;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 6px;
    margin-bottom: 10px;
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.astroraffle_grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
}
.astroraffle_card {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-left: 3px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 10px 12px;
    transition: all 0.25s ease;
    cursor: pointer;
    text-align: left;
}
.astroraffle_card:hover {
    border-left-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.35);
    transform: translateY(-2px);
}
.astroraffle_card.urgent { border-left-color: var(--accent-gold); }
.astroraffle_card.danger { border-left-color: var(--accent-red); }
.astroraffle_card_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 6px;
}
.astroraffle_card_name {
    color: var(--text-title);
    font-weight: bold;
    font-size: 11.5px;
}
.astroraffle_icon {
    display: inline-block;
    width: 22px;
    height: 22px;
    background: linear-gradient(135deg, #0066cc 0%, #00ccff 100%);
    color: #000;
    border-radius: 4px;
    text-align: center;
    line-height: 22px;
    font-weight: bold;
    font-size: 12px;
    margin-right: 6px;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astroraffle_bar_wrap {
    background: rgba(0, 0, 0, 0.5);
    border-radius: 4px;
    height: 8px;
    overflow: hidden;
    margin: 6px 0;
    position: relative;
    border: 1px solid var(--border-color);
}
.astroraffle_bar {
    background: linear-gradient(90deg, #0066cc, var(--accent-cyan));
    height: 100%;
    border-radius: 4px;
    transition: width 0.4s ease;
    box-shadow: 0 0 8px rgba(0, 224, 255, 0.5) inset;
}
.astroraffle_bar_txt {
    font-size: 9.5px;
    color: var(--text-muted);
    text-align: right;
}
.astroraffle_row {
    display: flex;
    justify-content: space-between;
    font-size: 10.5px;
    color: var(--text-main);
    margin: 3px 0;
}
.astroraffle_row b { color: var(--text-title); }
.astroraffle_prize {
    color: var(--accent-gold);
    font-weight: bold;
    font-size: 11px;
    margin: 4px 0;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.3);
}
.astroraffle_winner {
    color: var(--accent-green);
    font-weight: bold;
    font-size: 11px;
    margin: 4px 0;
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.4);
}
.astroraffle_btn {
    display: block;
    text-align: center;
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #fff;
    text-decoration: none;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 10.5px;
    font-weight: bold;
    margin-top: 8px;
    transition: all 0.25s ease;
    border: 1px solid var(--accent-cyan);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}
.astroraffle_btn:hover {
    background: linear-gradient(135deg, #0099ff 0%, #00ccff 100%);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.55);
    color: #fff;
    text-decoration: none;
    transform: translateY(-2px);
}
.astroraffle_btn:active {
    transform: translateY(0);
}
.astroraffle_msg {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 12px;
    font-size: 11.5px;
    text-align: left;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.astroraffle_msg.success {
    background: rgba(74, 255, 136, 0.10);
    border-left: 3px solid var(--accent-green);
    color: var(--accent-green);
}
.astroraffle_msg.error {
    background: rgba(239, 68, 68, 0.10);
    border-left: 3px solid var(--accent-red);
    color: var(--accent-red);
}
.astroraffle_msg.info {
    background: rgba(0, 224, 255, 0.10);
    border-left: 3px solid var(--accent-cyan);
    color: var(--accent-cyan);
}
.astroraffle_empty {
    color: var(--text-muted);
    font-size: 11px;
    text-align: center;
    padding: 20px;
    font-style: italic;
}
.astroraffle_nav {
    margin-bottom: 12px;
    text-align: left;
}
.astroraffle_nav a {
    color: var(--accent-cyan);
    text-decoration: none;
    font-size: 11px;
    margin-right: 14px;
    padding: 4px 8px;
    border-radius: 6px;
    transition: all 0.25s ease;
    border: 1px solid transparent;
}
.astroraffle_nav a:hover {
    background: rgba(0, 224, 255, 0.1);
    border-color: rgba(0, 224, 255, 0.4);
    text-decoration: none;
    transform: translateY(-1px);
}
.astroraffle_nav a.active {
    background: rgba(0, 224, 255, 0.15);
    color: var(--accent-cyan);
    border-color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}
</style>

<div class="astroraffle_wrap">

    {if $msg}
    <div class="astroraffle_msg {$msg_type}">{$msg}</div>
    {/if}

    <div class="astroraffle_nav">
        <a href="game.php?page=raffles" class="active">Rifas Activas</a>
        <a href="game.php?page=raffles&mode=misBoletos">Mis Boletos</a>
    </div>

    <div class="astroraffle_panel">
        <div class="astroraffle_title">Rifas Activas</div>

        {if $hay_activas}
        <div class="astroraffle_grid">
            {foreach $raffles_activas as $r}
            <div class="astroraffle_card {if $r.tiempo_restante == 'SORTEANDO...'}danger{/if}">
                <div class="astroraffle_card_head">
                    <span class="astroraffle_card_name">
                        <span class="astroraffle_icon">R</span>{$r.titulo}
                    </span>
                </div>

                <div class="astroraffle_prize">{$r.premio_principal}</div>

                <div class="astroraffle_bar_wrap">
                    <div class="astroraffle_bar" style="width: {$r.pct}%"></div>
                </div>
                <div class="astroraffle_bar_txt">{$r.boletos_vendidos} / {$r.max_boletos} boletos</div>

                <div class="astroraffle_row">
                    <span>Tiempo:</span>
                    <b>{$r.tiempo_restante}</b>
                </div>
                <div class="astroraffle_row">
                    <span>Precio:</span>
                    <b>{$r.precio_boleto} {$r.moneda_nombre}</b>
                </div>

                <a href="game.php?page=raffles&mode=view&id={$r.id}" class="astroraffle_btn">VER RIFA</a>
            </div>
            {/foreach}
        </div>
        {else}
        <div class="astroraffle_empty">No hay rifas activas por el momento</div>
        {/if}
    </div>

    {if $hay_finalizadas}
    <div class="astroraffle_panel">
        <div class="astroraffle_title">Rifas Finalizadas</div>
        <div class="astroraffle_grid">
            {foreach $raffles_finalizadas as $r}
            <div class="astroraffle_card">
                <div class="astroraffle_card_head">
                    <span class="astroraffle_card_name">
                        <span class="astroraffle_icon">R</span>{$r.titulo}
                    </span>
                </div>
                <div class="astroraffle_row">
                    <span>Boletos:</span>
                    <b>{$r.boletos_vendidos}</b>
                </div>
                <div class="astroraffle_row">
                    <span>Premio:</span>
                    <b>{$r.premio_principal}</b>
                </div>
                {if isset($r.premios.0.ganador_username) && $r.premios.0.ganador_username}
                <div class="astroraffle_winner">
                    Ganador: {$r.premios.0.ganador_username}
                </div>
                {/if}
                <a href="game.php?page=raffles&mode=view&id={$r.id}" class="astroraffle_btn">VER RESULTADO</a>
            </div>
            {/foreach}
        </div>
    </div>
    {/if}

</div>

{/block}