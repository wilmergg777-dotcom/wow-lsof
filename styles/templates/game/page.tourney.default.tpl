{block name="title" prepend}{$LNG.lm_tourney}{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.tourney.default.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
#content h1, #content h2, #content h3, #content h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
#content a { color:#00e0ff; text-decoration:none; transition:.2s ease }
#content a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
#content table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
#content table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
#content table tr:hover td { background:rgba(0,224,255,.04) }
#content input[type=text], #content input[type=password], #content input[type=email], #content input[type=number], #content input[type=date], #content select, #content textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
#content input[type=text]:focus, #content input[type=password]:focus, #content input[type=email]:focus, #content input[type=number]:focus, #content select:focus, #content textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
#content textarea { width:100%; resize:vertical; font-family:inherit }
#content button, #content input[type=submit], #content input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
#content button:hover, #content input[type=submit]:hover, #content input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
#content button:active, #content input[type=submit]:active, #content input[type=button]:active { transform:translateY(0) }
#content input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
#content select option { background:#0f172a; color:#cbd5e1 }
#content .globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { #content { padding:6px; overflow-x:auto } #content table { font-size:11px } #content table th, #content table td { padding:5px 7px } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════════════════
   MINI TORNEOS — Ver detalle + participar
   AstroIO v3.0 — Glassmorphism + Acento Cyan/Dorado
   Prefijo: .astrotourney_
   Estilo clonado de la página de Rifas
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

.astrotourney_wrap { max-width: 900px; margin: 0 auto; text-align: center; }

.astrotourney_panel {
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

.astrotourney_title {
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

/* ─── Menú de secciones (Alpha/Beta/...) ─── */
.astrotourney_menu {
    display: flex;
    justify-content: center;
    gap: 6px;
    flex-wrap: wrap;
    margin-bottom: 14px;
}
.astrotourney_menu_item {
    display: inline-block;
    padding: 8px 18px;
    background: rgba(15, 23, 42, 0.7);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    color: var(--text-muted);
    text-decoration: none;
    font-weight: bold;
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.25s ease;
}
.astrotourney_menu_item:hover {
    color: var(--accent-cyan);
    border-color: rgba(0, 224, 255, 0.5);
    background: rgba(0, 224, 255, 0.08);
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}
.astrotourney_menu_item.enable {
    color: #fff;
    border-color: var(--accent-cyan);
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.8), rgba(0, 153, 255, 0.8));
    box-shadow: 0 0 15px rgba(0, 224, 255, 0.5);
    text-shadow: 0 0 8px rgba(255, 255, 255, 0.4);
    cursor: default;
}

/* ─── Header del torneo ─── */
.astrotourney_head_name {
    font-size: 18px;
    color: var(--text-title);
    font-weight: bold;
    margin-bottom: 4px;
    text-shadow: 0 0 10px rgba(255, 255, 255, 0.2);
}
.astrotourney_desc {
    color: var(--text-muted);
    font-size: 11px;
    margin-bottom: 10px;
    line-height: 1.5;
}

/* ─── Countdown / Tiempo restante ─── */
.astrotourney_countdown {
    display: inline-block;
    background: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 6px 14px;
    font-size: 16px;
    color: var(--accent-cyan);
    font-weight: bold;
    letter-spacing: 1px;
    margin: 6px 0;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.25);
}
.astrotourney_countdown.warn {
    border-color: var(--accent-gold);
    color: var(--accent-gold);
    text-shadow: 0 0 10px rgba(251, 191, 36, 0.5);
    box-shadow: 0 0 14px rgba(251, 191, 36, 0.25);
}
.astrotourney_countdown.danger {
    border-color: var(--accent-red);
    color: var(--accent-red);
    text-shadow: 0 0 10px rgba(239, 68, 68, 0.5);
    box-shadow: 0 0 14px rgba(239, 68, 68, 0.3);
    animation: pulseCountdown 1.5s ease-in-out infinite;
}
@keyframes pulseCountdown {
    0%, 100% { opacity: 1; }
    50%      { opacity: 0.65; }
}

/* ─── Imagen de la división ─── */
.astrotourney_img_wrap {
    text-align: center;
    margin-bottom: 14px;
    padding: 12px;
    background: radial-gradient(ellipse at center, rgba(0, 102, 204, 0.15) 0%, rgba(0, 0, 0, 0.5) 100%);
    border-radius: 10px;
    border: 1px solid rgba(0, 224, 255, 0.2);
    box-shadow: inset 0 0 30px rgba(0, 0, 0, 0.5);
}
.astrotourney_img_wrap img {
    max-width: 100%;
    max-height: 160px;
    width: auto;
    height: auto;
    vertical-align: middle;
    filter: drop-shadow(0 0 15px rgba(0, 224, 255, 0.3));
}

/* ─── Lista de premios (LUGAR 1, LUGAR 2, LUGAR 3) ─── */
.astrotourney_prizes_list { margin: 8px 0; }
.astrotourney_prize_item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border-left: 3px solid var(--accent-gold);
    border-radius: 6px;
    padding: 8px 12px;
    margin-bottom: 6px;
    transition: all 0.25s ease;
}
.astrotourney_prize_item:hover {
    background: rgba(251, 191, 36, 0.08);
    box-shadow: 0 0 12px rgba(251, 191, 36, 0.2);
}
.astrotourney_prize_lugar {
    color: var(--accent-cyan);
    font-weight: bold;
    font-size: 11px;
    width: 90px;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
}
.astrotourney_prize_texto {
    color: var(--text-title);
    font-size: 12px;
    flex: 1;
    padding-left: 10px;
}
.astrotourney_prize_medal {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-left: 10px;
}
.astrotourney_prize_medal img {
    height: 40px !important;
    width: auto !important;
    max-height: 40px !important;
    filter: drop-shadow(0 2px 6px rgba(0, 0, 0, 0.5));
}
.astrotourney_prize_mo {
    color: var(--accent-gold);
    font-weight: bold;
    font-size: 13px;
    text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
    display: flex;
    align-items: center;
    gap: 4px;
}
.astrotourney_prize_mo img {
    height: 16px !important;
    width: 16px !important;
    border-radius: 3px;
    box-shadow: 0 0 6px rgba(251, 191, 36, 0.4);
}

/* ─── Estadísticas (4 cajas) ─── */
.astrotourney_stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
    margin: 10px 0;
}
.astrotourney_stat {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 10px;
    text-align: center;
    transition: 0.25s ease;
}
.astrotourney_stat:hover {
    border-color: rgba(0, 224, 255, 0.4);
    transform: translateY(-2px);
}
.astrotourney_stat_val {
    color: var(--accent-cyan);
    font-size: 16px;
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}
.astrotourney_stat_lbl {
    color: var(--text-muted);
    font-size: 9px;
    text-transform: uppercase;
    margin-top: 3px;
    letter-spacing: 0.5px;
}

/* ─── Botón Participar ─── */
.astrotourney_btn_box {
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 14px;
    text-align: center;
    margin-top: 10px;
}
.astrotourney_btn_info {
    color: var(--text-main);
    font-size: 11px;
    margin-bottom: 10px;
    line-height: 1.8;
}
.astrotourney_btn_info b { color: var(--text-title); }

.astrotourney_btn {
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
    border: 1px solid var(--accent-gold);
    padding: 10px 28px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 13px;
    cursor: pointer;
    transition: all 0.25s ease;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(255, 255, 255, 0.2);
    font-family: inherit;
}
.astrotourney_btn:hover {
    box-shadow: 0 0 20px rgba(251, 191, 36, 0.6);
    transform: translateY(-2px);
    background: linear-gradient(135deg, #fbbf24 0%, #fde047 100%);
}
.astrotourney_btn:active {
    transform: translateY(0);
}

.astrotourney_already {
    display: inline-block;
    background: rgba(74, 255, 136, 0.10);
    border: 1px solid var(--accent-green);
    color: var(--accent-green);
    padding: 10px 28px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 12px;
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(74, 255, 136, 0.4);
    box-shadow: 0 0 15px rgba(74, 255, 136, 0.2);
}

/* ─── Ranking (lista de participantes) ─── */
.astrotourney_participants {
    max-height: 350px;
    overflow-y: auto;
    background: rgba(0, 0, 0, 0.35);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 8px;
}
.astrotourney_participant {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 11px;
    color: var(--text-main);
    padding: 6px 10px;
    border-bottom: 1px solid var(--border-color);
    transition: 0.2s ease;
}
.astrotourney_participant:last-child { border-bottom: none; }
.astrotourney_participant:hover {
    background: rgba(0, 224, 255, 0.08);
}
.astrotourney_participant .pos {
    color: var(--accent-cyan);
    font-weight: bold;
    width: 40px;
    text-align: left;
    text-shadow: 0 0 6px rgba(0, 224, 255, 0.3);
}
.astrotourney_participant .name {
    color: var(--text-title);
    flex: 1;
    text-align: left;
    font-weight: 600;
}
.astrotourney_participant .pts {
    color: var(--accent-gold);
    font-weight: bold;
    font-family: 'Courier New', monospace;
    text-shadow: 0 0 6px rgba(251, 191, 36, 0.4);
}
.astrotourney_participant.empty {
    text-align: center;
    color: var(--text-muted);
    font-style: italic;
    font-size: 12px;
    padding: 25px 10px;
    justify-content: center;
}

/* ─── Scrollbar personalizada ─── */
.astrotourney_participants::-webkit-scrollbar { width: 6px; }
.astrotourney_participants::-webkit-scrollbar-track {
    background: rgba(0, 0, 0, 0.3);
    border-radius: 3px;
}
.astrotourney_participants::-webkit-scrollbar-thumb {
    background: linear-gradient(180deg, #0066cc, var(--accent-cyan));
    border-radius: 3px;
}
.astrotourney_participants::-webkit-scrollbar-thumb:hover {
    background: linear-gradient(180deg, var(--accent-cyan), #00e0ff);
}
</style>

<div class="astrotourney_wrap">

    {* ─── Menú de secciones (Alpha/Beta/Gamma/Delta/Epsilon) ─── *}
    <div class="astrotourney_menu">
        <a href="game.php?page=tourney&amp;group=1" class="astrotourney_menu_item {if $touneyGroup == 1}enable{/if}">Alpha</a>
        <a href="game.php?page=tourney&amp;group=2" class="astrotourney_menu_item {if $touneyGroup == 2}enable{/if}">Beta</a>
        <a href="game.php?page=tourney&amp;group=3" class="astrotourney_menu_item {if $touneyGroup == 3}enable{/if}">Gamma</a>
        <a href="game.php?page=tourney&amp;group=4" class="astrotourney_menu_item {if $touneyGroup == 4}enable{/if}">Delta</a>
        <a href="game.php?page=tourney&amp;group=5" class="astrotourney_menu_item {if $touneyGroup == 5}enable{/if}">Epsilon</a>
    </div>

    {* ─── Panel principal: nombre + descripción + countdown ─── *}
    <div class="astrotourney_panel">

        <div class="astrotourney_head_name">{$LNG.lm_tourney} — {$tourneyDetail.tourneyName}</div>

        {if $tourneyDescrip}
        <div class="astrotourney_desc">{$tourneyDescrip}</div>
        {/if}

        <div style="text-align:center;">
            {if $tourneyEnd > 0}
                <div id="astrotourney_countdown_box" class="astrotourney_countdown">
                    {$LNG.tourney_time}: <span id="astrotourney_timer">{$tourneyEnd|time}</span>
                </div>
            {else}
                <div class="astrotourney_countdown danger">{$LNG.tourney_end}</div>
            {/if}
        </div>

    </div>

    {* ─── Panel: imagen de la división ─── *}
    <div class="astrotourney_panel">
        <div class="astrotourney_title">División {$tourneyDetail.tourneyName}</div>
        <div class="astrotourney_img_wrap">
            <img alt="{$tourneyDetail.tourneyName}" src="{$dpath}tourney/divisions/{$touneyGroup}.png">
        </div>
    </div>

    {* ─── Panel: premios (3 lugares) ─── *}
    <div class="astrotourney_panel">
        <div class="astrotourney_title">Premios (3 lugares)</div>

        <div class="astrotourney_prizes_list">

            {* LUGAR 1 *}
            <div class="astrotourney_prize_item">
                <div class="astrotourney_prize_lugar">LUGAR 1</div>
                <div class="astrotourney_prize_texto">{$LNG.tourney_pts}</div>
                <div class="astrotourney_prize_medal">
                    <img alt="1" src="styles/theme/gow/premios/oro.png">
                    <span class="astrotourney_prize_mo">
                        {$tourneyDetail.priceOne|number}
                        <img src="{$dpath}img/resources/921f.png">
                    </span>
                </div>
            </div>

            {* LUGAR 2 *}
            <div class="astrotourney_prize_item">
                <div class="astrotourney_prize_lugar">LUGAR 2</div>
                <div class="astrotourney_prize_texto">{$LNG.tourney_pts}</div>
                <div class="astrotourney_prize_medal">
                    <img alt="2" src="styles/theme/gow/premios/plata.png">
                    <span class="astrotourney_prize_mo">
                        {$tourneyDetail.priceTwo|number}
                        <img src="{$dpath}img/resources/921f.png">
                    </span>
                </div>
            </div>

            {* LUGAR 3 *}
            <div class="astrotourney_prize_item">
                <div class="astrotourney_prize_lugar">LUGAR 3</div>
                <div class="astrotourney_prize_texto">{$LNG.tourney_pts}</div>
                <div class="astrotourney_prize_medal">
                    <img alt="3" src="styles/theme/gow/premios/bronce.png">
                    <span class="astrotourney_prize_mo">
                        {$tourneyDetail.priceThree|number}
                        <img src="{$dpath}img/resources/921f.png">
                    </span>
                </div>
            </div>

        </div>
    </div>

    {* ─── Panel: estadísticas ─── *}
    <div class="astrotourney_panel">
        <div class="astrotourney_title">Estadísticas</div>

        <div class="astrotourney_stats">
            <div class="astrotourney_stat">
                <div class="astrotourney_stat_val">{$playerList|count}</div>
                <div class="astrotourney_stat_lbl">Participantes</div>
            </div>
            <div class="astrotourney_stat">
                <div class="astrotourney_stat_val">500</div>
                <div class="astrotourney_stat_lbl">Premio 1ro</div>
            </div>
            <div class="astrotourney_stat">
                <div class="astrotourney_stat_val">300</div>
                <div class="astrotourney_stat_lbl">Premio 2do</div>
            </div>
            <div class="astrotourney_stat">
                <div class="astrotourney_stat_val">200</div>
                <div class="astrotourney_stat_lbl">Premio 3ro</div>
            </div>
        </div>

    </div>

    {* ─── Panel: botón participar ─── *}
    <div class="astrotourney_panel">
        <div class="astrotourney_title">Participar</div>

        {if $tourneyCheck == 0}
        <div class="astrotourney_btn_box">
            <div class="astrotourney_btn_info">
                Inscribite al torneo <b>{$tourneyDetail.tourneyName}</b><br>
                Acumulá puntos automáticamente con tus acciones en el juego
            </div>

            <form method="post" action="game.php?page=tourney">
                <input type="hidden" name="group" value="{$touneyGroup}">
                <button type="submit" class="astrotourney_btn">{$LNG.tourney_btn}</button>
            </form>
        </div>
        {else}
        <div class="astrotourney_btn_box">
            <div class="astrotourney_already">
                {if $tourneyEnd > 0}
                    ✓ Ya estás participando en este torneo
                {else}
                    {$LNG.tourney_end}
                {/if}
            </div>
        </div>
        {/if}
    </div>

    {* ─── Panel: ranking participantes ─── *}
    <div class="astrotourney_panel">
        <div class="astrotourney_title">Participantes ({$playerList|count})</div>

        <div class="astrotourney_participants">
            {foreach $playerList as $ID => $Player}
                <div class="astrotourney_participant">
                    <span class="pos">#{$Player@iteration}</span>
                    <span class="name">{$Player.playerName}</span>
                    <span class="pts">{$Player.tourneyUnits}</span>
                </div>
            {foreachelse}
                <div class="astrotourney_participant empty">{$LNG.tourney_noplayers}</div>
            {/foreach}
        </div>
    </div>

</div>

{* ─── SCRIPT PARA EL CONTADOR DINÁMICO ─── *}
<script type="text/javascript">
    document.addEventListener("DOMContentLoaded", function() {
        var timeLeft = parseInt("{$tourneyEnd|default:0}", 10);
        var timerSpan = document.getElementById("astrotourney_timer");
        var timerBox = document.getElementById("astrotourney_countdown_box");
        
        if (!timerSpan || !timerBox) return;
        
        function updateTimer() {
            if (timeLeft <= 0) {
                timerSpan.innerHTML = "FINALIZADO";
                timerBox.className = "astrotourney_countdown danger";
                // Recargar la pagina en 3 segundos para mostrar los resultados del cronjob
                setTimeout(function() { window.location.reload(); }, 3000);
                return;
            }
            
            var days = Math.floor(timeLeft / 86400);
            var hours = Math.floor((timeLeft % 86400) / 3600);
            var minutes = Math.floor((timeLeft % 3600) / 60);
            var seconds = Math.floor(timeLeft % 60);
            
            var display = "";
            if (days > 0) display += days + "d ";
            if (hours > 0 || days > 0) display += hours + "h ";
            if (minutes > 0 || hours > 0 || days > 0) display += minutes + "m ";
            display += seconds + "s";
            
            timerSpan.innerHTML = display;
            
            // Cambiar el color si falta menos de 1 hora o 2 horas
            if (timeLeft < 3600) {
                timerBox.className = "astrotourney_countdown danger";
            } else if (timeLeft < 7200) {
                timerBox.className = "astrotourney_countdown warn";
            } else {
                timerBox.className = "astrotourney_countdown";
            }
            
            timeLeft--;
        }
        
        // Ejecutamos la función inmediatamente y luego cada 1 segundo
        updateTimer();
        setInterval(updateTimer, 1000);
    });
</script>

{/block}