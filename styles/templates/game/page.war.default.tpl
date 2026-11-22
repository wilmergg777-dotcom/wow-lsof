{block name="content"}

{* ============================================ *}
{* ⚔️ GUERRA WAR — Página del jugador           *}
{* ============================================ *}

<style>
.astrowar_wrap {
    max-width: 950px;
    margin: 0 auto;
    padding: 8px 0;
    text-align: center;
}
.astrowar_panel {
    display: inline-block;
    text-align: left;
    padding: 12px 16px;
    background: linear-gradient(180deg, #0f1624, #1a2332);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-radius: 8px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    color: #c8d6e5;
    font-size: 11.5px;
    min-width: 750px;
    max-width: 920px;
}
.astrowar_title {
    font-size: 14px;
    font-weight: 700;
    text-transform: uppercase;
    color: #00ccff;
    text-align: center;
    padding-bottom: 8px;
    margin-bottom: 10px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    letter-spacing: 0.5px;
    text-shadow: 0 0 8px rgba(0, 204, 255, 0.5);
}
.astrowar_section {
    font-weight: 700;
    color: #00ccff;
    text-transform: uppercase;
    font-size: 11px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 4px;
    margin: 14px 0 8px;
    letter-spacing: 0.4px;
}
.astrowar_row {
    padding: 3px 0;
    font-size: 11.5px;
}
.astrowar_row b { color: #00e0ff; }

/* ============ TABS ============ */
.astrowar_tabs {
    display: flex;
    gap: 4px;
    padding: 6px 0;
    margin-bottom: 6px;
    justify-content: center;
    flex-wrap: wrap;
}
.astrowar_tab {
    display: inline-block;
    padding: 6px 14px;
    font-size: 11px;
    font-weight: 700;
    color: #c8d6e5;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(0, 224, 255, 0.2);
    border-radius: 6px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    transition: 0.2s ease;
}
.astrowar_tab:hover {
    color: #00e0ff;
    border-color: rgba(0, 224, 255, 0.5);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.3);
}
.astrowar_tab-active {
    background: linear-gradient(180deg, #7700cc, #aa44ff);
    color: #fff;
    border-color: #aa44ff;
    box-shadow: 0 0 14px rgba(170, 68, 255, 0.45);
}
.astrowar_tab-declare {
    background: linear-gradient(180deg, #3a0010, #5a0015);
    border-color: rgba(255, 68, 68, 0.4);
    color: #ff8888;
}
.astrowar_tab-declare:hover {
    color: #ffcccc;
    border-color: #ff4444;
    box-shadow: 0 0 10px rgba(255, 68, 68, 0.4);
}
.astrowar_tab-declare.astrowar_tab-active {
    background: linear-gradient(180deg, #aa0000, #ff2222);
    color: #fff;
    border-color: #ff4444;
    box-shadow: 0 0 14px rgba(255, 68, 68, 0.6);
}

/* ============ BADGES ============ */
.astrowar_badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowar_badge-activa  { background: #00aa55; color: #fff; }
.astrowar_badge-pausada { background: #ddaa00; color: #221800; }
.astrowar_badge-cerrada { background: #aa3355; color: #fff; }
.astrowar_badge-warn    { background: #dd8800; color: #fff; }
.astrowar_badge-info    { background: #0066cc; color: #fff; }

/* ============ CLIMA ============ */
.astrowar_clima {
    padding: 10px 14px;
    margin: 8px 0;
    background: linear-gradient(180deg, #2a1a3a, #1a0f24);
    border-left: 3px solid #aa44ff;
    border-radius: 6px;
    color: #d0c8e5;
    font-size: 11.5px;
    box-shadow: 0 0 12px rgba(170, 68, 255, 0.15);
}
.astrowar_clima b { color: #c088ff; }

/* ============ BATALLA ACTIVA ============ */
.astrowar_battle {
    padding: 10px 14px;
    margin: 8px 0;
    background: linear-gradient(180deg, #2a0f1a, #1a0a10);
    border-left: 3px solid #ff4488;
    border-radius: 6px;
    color: #e5c8d0;
    font-size: 11.5px;
    box-shadow: 0 0 12px rgba(255, 68, 136, 0.15);
}
.astrowar_battle b { color: #ff88aa; }

/* ============ SIN ALIANZA ============ */
.astrowar_noally {
    padding: 20px;
    text-align: center;
    background: linear-gradient(180deg, #2a1a0a, #1a0f05);
    border: 1px solid rgba(255, 170, 51, 0.3);
    border-radius: 8px;
    color: #ffcc88;
    font-size: 12px;
    margin: 10px 0;
}

/* ============ PUNTOS ============ */
.astrowar_stats {
    display: flex;
    gap: 10px;
    margin: 8px 0;
    flex-wrap: wrap;
}
.astrowar_stat {
    flex: 1;
    min-width: 140px;
    padding: 8px 12px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-radius: 6px;
    text-align: center;
}
.astrowar_stat-label {
    font-size: 10px;
    color: #8899aa;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    margin-bottom: 4px;
}
.astrowar_stat-value {
    font-size: 16px;
    font-weight: 700;
    color: #ffaa33;
}
.astrowar_stat-value-small {
    font-size: 12px;
    font-weight: 700;
    color: #00e0ff;
}

/* ============ TABLA RANKING ============ */
.astrowar_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    margin-top: 4px;
}
.astrowar_table th {
    background: linear-gradient(180deg, #004488, #0077cc);
    color: #fff;
    padding: 6px;
    text-align: left;
    border-bottom: 1px solid #00ccff;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowar_table td {
    padding: 5px 6px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08);
    color: #c8d6e5;
}
.astrowar_table tr:hover td {
    background: rgba(0, 224, 255, 0.05);
}
.astrowar_table .rank-1 { color: #ffdd44; font-weight: 700; }
.astrowar_table .rank-2 { color: #ccddff; font-weight: 700; }
.astrowar_table .rank-3 { color: #dd9955; font-weight: 700; }

/* ============ AVISOS ============ */
.astrowar_warn {
    padding: 8px 12px;
    margin: 8px 0;
    background: linear-gradient(180deg, #3a2500, #1a1000);
    border-left: 3px solid #ffaa33;
    border-radius: 6px;
    color: #ffcc88;
    font-size: 11px;
}
.astrowar_ok {
    padding: 8px 12px;
    margin: 8px 0;
    background: linear-gradient(180deg, #003a25, #005538);
    border-left: 3px solid #00ff88;
    border-radius: 6px;
    color: #aaffcc;
    font-size: 11px;
}
.astrowar_empty {
    padding: 15px;
    color: #8899aa;
    font-style: italic;
    font-size: 11px;
    text-align: center;
}
.astrowar_soon {
    padding: 20px;
    text-align: center;
    background: rgba(0, 0, 0, 0.15);
    border: 1px dashed rgba(0, 224, 255, 0.25);
    border-radius: 8px;
    color: #8899aa;
    font-size: 12px;
    font-style: italic;
}
</style>

<div class="astrowar_wrap">
<div class="astrowar_panel">

    <div class="astrowar_title">⚔️ GUERRA WAR</div>

    {* ============================================ *}
    {* TABS                                          *}
    {* ============================================ *}
    <div class="astrowar_tabs">
        <a href="game.php?page=war&tab=temporada"
           class="astrowar_tab {if $war_tab == 'temporada'}astrowar_tab-active{/if}">📌 Temporada</a>

        {if $war_is_admin && $war_activa && $war_can_declare.ok}
        <a href="game.php?page=war&tab=declarar"
           class="astrowar_tab astrowar_tab-declare {if $war_tab == 'declarar'}astrowar_tab-active{/if}">⚔️ Declarar</a>
        {/if}

        <a href="game.php?page=war&tab=enviar"
           class="astrowar_tab {if $war_tab == 'enviar'}astrowar_tab-active{/if}">🚀 Enviar</a>
        <a href="game.php?page=war&tab=ranking"
           class="astrowar_tab {if $war_tab == 'ranking'}astrowar_tab-active{/if}">🌍 Ranking</a>
        <a href="game.php?page=war&tab=historial"
           class="astrowar_tab {if $war_tab == 'historial'}astrowar_tab-active{/if}">📜 Historial</a>
        <a href="game.php?page=war&tab=cofres"
           class="astrowar_tab {if $war_tab == 'cofres'}astrowar_tab-active{/if}">🎁 Cofres</a>
    </div>

    {* ============================================ *}
    {* MENSAJE SIN ALIANZA                           *}
    {* ============================================ *}
    {if $war_no_ally}
        <div class="astrowar_noally">
            ⚠️ <b>No perteneces a ninguna alianza</b><br><br>
            Para participar en las Guerras WAR necesitas formar parte de una alianza con al menos 3 miembros.<br><br>
            <a href="game.php?page=alliance" style="color:#00e0ff;">→ Ir a la sección de Alianzas</a>
        </div>
    {else}

        {* ============================================ *}
        {* TAB: TEMPORADA                                *}
        {* ============================================ *}
        {if $war_tab == 'temporada'}

            {* --- Estado de la temporada --- *}
            <div class="astrowar_section">📌 Estado de la Temporada</div>

            <div class="astrowar_row">
                Estado:
                {if $war_season.estado == 'activa' && !$war_season.pausada}
                    <span class="astrowar_badge astrowar_badge-activa">✅ ACTIVA</span>
                {elseif $war_season.estado == 'activa' && $war_season.pausada}
                    <span class="astrowar_badge astrowar_badge-pausada">⏸️ PAUSADA</span>
                {else}
                    <span class="astrowar_badge astrowar_badge-cerrada">❌ SIN TEMPORADA</span>
                {/if}
            </div>

            {if $war_season.estado == 'activa'}
                <div class="astrowar_row">
                    Nombre: <b>{if $war_season.nombre_temporada}{$war_season.nombre_temporada}{else}—{/if}</b>
                </div>
                <div class="astrowar_row">
                    🗓️ Duración temporada: <b>{$war_season.duracion_horas} horas</b>
                </div>
                <div class="astrowar_row">
                    ⚔️ Duración de cada batalla: <b>{$war_season.duracion_batalla_horas} horas</b>
                </div>
                <div class="astrowar_row">
                    ⏱️ Cooldown entre guerras: <b>{$war_season.cooldown_horas} horas</b>
                </div>

                {if $war_season.fecha_fin}
                    <div class="astrowar_row">
                        ⏳ Faltan: <b id="astrowar_countdown">calculando...</b>
                    </div>
                {/if}
            {else}
                <div class="astrowar_row" style="color:#8899aa;font-style:italic;">
                    No hay ninguna temporada de guerra activa en este momento.
                </div>
            {/if}

            {* --- Clima activo (si hay batalla) --- *}
            {if $war_clima}
                <div class="astrowar_clima">
                    <b>{$war_clima.emoji} {$war_clima.nombre}</b><br>
                    <span style="font-size:10.5px;color:#aab;">{$war_clima.descripcion}</span><br>
                    📉 Ataque: <b>{($war_clima.atk * 100)|round}%</b>
                    &nbsp;|&nbsp;
                    🛡️ Defensa: <b>{($war_clima.def * 100)|round}%</b>
                </div>
            {/if}

            {* --- Batalla activa de mi alianza --- *}
            <div class="astrowar_section">⚔️ Tu Batalla</div>

            {if $war_battle}
                <div class="astrowar_battle">
                    🏰 <b>{$war_battle.atacante_nombre}</b> vs 🏰 <b>{$war_battle.defensor_nombre}</b><br>
                    <span style="font-size:10.5px;">
                        Inicio: {$war_battle.inicio|date_format:"%d/%m %H:%M"}
                        &nbsp;|&nbsp;
                        Fin: {$war_battle.fin|date_format:"%d/%m %H:%M"}
                    </span><br>
                    <span style="font-size:10.5px;color:#ff88aa;">
                        💥 ¡Envía tus flotas desde la pestaña "Enviar"!
                    </span>
                </div>
            {else}
                <div class="astrowar_empty">
                    Tu alianza no está en una guerra activa en este momento.
                </div>

                {* --- Info para admins de alianza --- *}
                {if $war_is_admin && $war_activa}
                    {if $war_cooldown > 0}
                        <div class="astrowar_warn">
                            ⏱️ <b>Cooldown activo:</b> tu alianza debe esperar antes de declarar una nueva guerra.<br>
                            <span id="astrowar_cooldown" style="font-size:11px;">{$war_cooldown} segundos restantes</span>
                        </div>
                    {elseif $war_can_declare.ok}
                        <div class="astrowar_ok">
                            ✅ <b>Tu alianza puede declarar guerra.</b>
                            <br><a href="game.php?page=war&tab=declarar" style="color:#aaffcc;">→ Ir a declarar guerra</a>
                        </div>
                    {else}
                        <div class="astrowar_warn">
                            ⚠️ <b>No puedes declarar guerra:</b> {$war_can_declare.motivo}
                        </div>
                    {/if}
                {/if}
            {/if}

            {* --- Stats del jugador --- *}
            <div class="astrowar_section">📊 Tus Estadísticas</div>

            <div class="astrowar_stats">
                <div class="astrowar_stat">
                    <div class="astrowar_stat-label">🏰 Alianza</div>
                    <div class="astrowar_stat-value-small">{$war_ally_name}</div>
                </div>
                <div class="astrowar_stat">
                    <div class="astrowar_stat-label">🎯 Mis Puntos WAR</div>
                    <div class="astrowar_stat-value">{$war_my_pts}</div>
                </div>
                <div class="astrowar_stat">
                    <div class="astrowar_stat-label">🏰 Puntos Alianza</div>
                    <div class="astrowar_stat-value">{$war_ally_pts}</div>
                </div>
            </div>

            {* --- Mini ranking top 5 --- *}
            {if count($war_ranking) > 0}
                <div class="astrowar_section">🏆 Top 5 Ranking Global</div>
                <table class="astrowar_table">
                    <thead>
                        <tr>
                            <th style="width:40px;">#</th>
                            <th>Jugador</th>
                            <th style="width:200px;">Alianza</th>
                            <th style="width:100px;">Puntos</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $war_ranking as $i => $r}
                            {if $i < 5}
                                <tr>
                                    <td class="rank-{$i+1}">{$i+1}</td>
                                    <td>{$r.username}</td>
                                    <td>{if $r.alliance_name}{$r.alliance_name}{else}<i style="color:#667;">—</i>{/if}</td>
                                    <td><b style="color:#ffaa33;">{$r.puntos}</b></td>
                                </tr>
                            {/if}
                        {/foreach}
                    </tbody>
                </table>
            {/if}

        {/if}

        {* ============================================ *}
        {* TAB: DECLARAR GUERRA                          *}
        {* ============================================ *}
        {if $war_tab == 'declarar'}
            {if $war_is_admin && $war_activa && $war_can_declare.ok}
                {include file="page.war.declare.tpl"}
            {else}
                <div class="astrowar_section">⚔️ Declarar Guerra</div>
                <div class="astrowar_warn">
                    ⚠️ Solo los administradores de la alianza pueden declarar guerra.
                </div>
            {/if}
        {/if}

        {* ============================================ *}
        {* TAB: ENVIAR FLOTAS                            *}
        {* ============================================ *}
        {if $war_tab == 'enviar'}
            {include file="page.war.send.tpl"}
        {/if}

        {* ============================================ *}
        {* TAB: RANKING                                  *}
        {* ============================================ *}
        {if $war_tab == 'ranking'}
            {include file="page.war.ranking.tpl"}
        {/if}

        {* ============================================ *}
        {* TAB: HISTORIAL                                *}
        {* ============================================ *}
        {if $war_tab == 'historial'}
            {include file="page.war.history.tpl"}
        {/if}

        {* ============================================ *}
        {* TAB: COFRES                                   *}
        {* ============================================ *}
        {if $war_tab == 'cofres'}
            {include file="page.war.chests.tpl"}
        {/if}

    {/if}

    {* ============================================ *}
    {* BOTÓN VOLVER                                  *}
    {* ============================================ *}
    <div style="text-align:center;padding-top:12px;border-top:1px solid rgba(0,224,255,0.15);margin-top:12px;">
        <a href="game.php?page=overview" class="astrowar_tab">◀️ Volver al Resumen</a>
    </div>

</div>
</div>

{* ============================================ *}
{* SCRIPTS: Countdown en vivo                    *}
{* ============================================ *}
{if $war_season.fecha_fin && $war_season.estado == 'activa' && !$war_season.pausada}
<script type="text/javascript">
(function () {
    var fin = {$war_season.fecha_fin} * 1000;
    var el  = document.getElementById('astrowar_countdown');
    if (!el) return;

    function update() {
        var now = new Date().getTime();
        var diff = Math.max(0, Math.floor((fin - now) / 1000));
        if (diff <= 0) {
            el.innerHTML = '<span style="color:#ff4488;">¡Terminada!</span>';
            return;
        }
        var d = Math.floor(diff / 86400);
        var h = Math.floor((diff % 86400) / 3600);
        var m = Math.floor((diff % 3600) / 60);
        var s = diff % 60;
        var txt = '';
        if (d > 0) txt += d + 'd ';
        txt += (h < 10 ? '0' : '') + h + 'h ';
        txt += (m < 10 ? '0' : '') + m + 'm ';
        txt += (s < 10 ? '0' : '') + s + 's';
        el.innerHTML = txt;
    }
    update();
    setInterval(update, 1000);
})();
</script>
{/if}

{/block}