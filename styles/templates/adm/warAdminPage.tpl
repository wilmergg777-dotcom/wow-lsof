{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/warAdminPage.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

{include file="overall_header.tpl"}

{* ================================================== *}
{* ⚔️ ADMIN — GESTIÓN DE GUERRA WAR                    *}
{* ================================================== *}

<style>
.astrowara_wrap {
    max-width: 950px;
    margin: 0 auto;
    padding: 10px 0;
    text-align: center;
}
.astrowara_panel {
    display: inline-block;
    text-align: left;
    padding: 14px 18px;
    background: linear-gradient(180deg, #0f1624, #1a2332);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-radius: 8px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    color: #c8d6e5;
    font-size: 11.5px;
    min-width: 750px;
}
.astrowara_title {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    color: #00ccff;
    border-bottom: 1px solid rgba(0, 224, 255, 0.25);
    padding-bottom: 6px;
    margin-bottom: 12px;
    letter-spacing: 0.5px;
}
.astrowara_section {
    font-weight: 700;
    color: #00ccff;
    text-transform: uppercase;
    font-size: 11px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.2);
    padding-bottom: 4px;
    margin: 14px 0 8px;
    letter-spacing: 0.4px;
}
.astrowara_row {
    padding: 3px 0;
    font-size: 11.5px;
}
.astrowara_row b { color: #00e0ff; }

.astrowara_btn {
    display: inline-block;
    padding: 6px 14px;
    margin: 3px;
    font-weight: 700;
    font-size: 11px;
    color: #fff;
    background: linear-gradient(180deg, #7700cc, #aa44ff);
    border: none;
    border-radius: 6px;
    cursor: pointer;
    transition: 0.2s ease;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowara_btn:hover {
    box-shadow: 0 0 14px rgba(170, 68, 255, 0.55);
    transform: translateY(-1px);
}
.astrowara_btn-ok {
    background: linear-gradient(180deg, #008844, #00cc66);
}
.astrowara_btn-ok:hover { box-shadow: 0 0 14px rgba(0, 204, 102, 0.55); }
.astrowara_btn-warn {
    background: linear-gradient(180deg, #aa8800, #ddbb00);
    color: #221800;
}
.astrowara_btn-danger {
    background: linear-gradient(180deg, #aa0044, #ff4488);
}
.astrowara_btn-danger:hover { box-shadow: 0 0 14px rgba(255, 68, 136, 0.55); }

.astrowara_btn-tiny {
    padding: 3px 8px;
    font-size: 9.5px;
    margin: 1px;
}

.astrowara_form {
    padding: 10px;
    background: rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(0, 224, 255, 0.15);
    border-radius: 6px;
    margin-top: 6px;
}
.astrowara_form label {
    display: block;
    color: #8899aa;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
    margin: 6px 0 3px;
    font-weight: 600;
}
.astrowara_form input[type=text],
.astrowara_form input[type=number],
.astrowara_form select {
    padding: 5px 8px;
    background: #0f1624;
    color: #c8d6e5;
    border: 1px solid rgba(0, 224, 255, 0.4);
    border-radius: 4px;
    font-size: 11px;
    width: 100%;
    max-width: 320px;
}
.astrowara_form input[type=number] { max-width: 120px; }
.astrowara_form select { max-width: 220px; }

.astrowara_form_row {
    margin-bottom: 6px;
}
.astrowara_form_row_hint {
    font-size: 10px;
    color: #667788;
    font-style: italic;
    margin-top: 2px;
}

.astrowara_msg {
    padding: 8px 12px;
    margin-bottom: 10px;
    background: linear-gradient(180deg, #003a25, #005538);
    border-left: 3px solid #00ff88;
    border-radius: 6px;
    color: #aaffcc;
    font-weight: 600;
}

.astrowara_badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowara_badge-activa    { background: #00aa55; color: #fff; }
.astrowara_badge-pausada   { background: #ddaa00; color: #221800; }
.astrowara_badge-cerrada   { background: #aa3355; color: #fff; }
.astrowara_badge-win       { background: #00aa55; color: #fff; }
.astrowara_badge-lose      { background: #aa3355; color: #fff; }
.astrowara_badge-tie       { background: #ddaa00; color: #221800; }
.astrowara_badge-cancel    { background: #333a44; color: #8899aa; }

.astrowara_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    margin-top: 4px;
}
.astrowara_table th {
    background: linear-gradient(180deg, #004488, #0077cc);
    color: #fff;
    padding: 6px;
    text-align: left;
    border-bottom: 1px solid #00ccff;
    font-size: 10.5px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.astrowara_table td {
    padding: 5px 6px;
    border-bottom: 1px solid rgba(0, 224, 255, 0.08);
    color: #c8d6e5;
}
.astrowara_table tr:hover td {
    background: rgba(0, 224, 255, 0.05);
}

.astrowara_empty {
    padding: 10px;
    color: #8899aa;
    font-style: italic;
    font-size: 11px;
}

.astrowara_clima {
    padding: 8px 12px;
    margin: 6px 0;
    background: linear-gradient(180deg, #2a1a3a, #1a0f24);
    border-left: 3px solid #aa44ff;
    border-radius: 6px;
    color: #d0c8e5;
    font-size: 11px;
}
.astrowara_clima b { color: #c088ff; }

.astrowara_actions {
    text-align: center;
    padding: 12px 0;
    border-top: 1px solid rgba(0, 224, 255, 0.15);
    margin-top: 12px;
}

/* ============ PARTICIPANTES ============ */
.astrowara_participants_box {
    margin-top: 14px;
    padding: 12px 14px;
    background: linear-gradient(180deg, #1a2332, #0f1624);
    border: 1px solid rgba(255, 68, 68, 0.3);
    border-radius: 8px;
}
.astrowara_participants_title {
    font-size: 12px;
    font-weight: 800;
    color: #ff8888;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding-bottom: 6px;
    border-bottom: 1px solid rgba(255, 68, 68, 0.25);
    margin-bottom: 10px;
}
.astrowara_participant_row {
    padding: 6px 10px;
    margin-bottom: 4px;
    background: rgba(0, 0, 0, 0.25);
    border-radius: 5px;
    border-left: 3px solid;
}
.astrowara_participant_row.atacante {
    border-left-color: #ff6633;
}
.astrowara_participant_row.defensor {
    border-left-color: #3399ff;
}
.astrowara_participant_head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 4px;
    flex-wrap: wrap;
    gap: 6px;
}
.astrowara_participant_user {
    font-size: 11.5px;
    font-weight: 700;
    color: #fff;
}
.astrowara_participant_side {
    font-size: 9.5px;
    text-transform: uppercase;
    padding: 2px 8px;
    border-radius: 3px;
    letter-spacing: 0.3px;
    font-weight: 700;
}
.astrowara_participant_side.atacante { background: rgba(255, 102, 51, 0.2); color: #ff6633; }
.astrowara_participant_side.defensor { background: rgba(51, 153, 255, 0.2); color: #3399ff; }
.astrowara_participant_totals {
    font-size: 10.5px;
    color: #8899aa;
}
.astrowara_participant_totals b { color: #00e0ff; }
</style>

<div class="astrowara_wrap">
<div class="astrowara_panel">

    <div class="astrowara_title">⚔️ Gestión de Guerra WAR</div>

    {if $war_msg}
        <div class="astrowara_msg">✅ {$war_msg}</div>
    {/if}

    {* ============================================ *}
    {* ESTADO DE LA TEMPORADA                       *}
    {* ============================================ *}
    <div class="astrowara_section">📌 Estado de la Temporada</div>

    <div class="astrowara_row">
        Estado:
        {if $war_season.estado == 'activa' && !$war_season.pausada}
            <span class="astrowara_badge astrowara_badge-activa">✅ ACTIVA</span>
        {elseif $war_season.estado == 'activa' && $war_season.pausada}
            <span class="astrowara_badge astrowara_badge-pausada">⏸️ PAUSADA</span>
        {else}
            <span class="astrowara_badge astrowara_badge-cerrada">❌ SIN TEMPORADA</span>
        {/if}
    </div>

    <div class="astrowara_row">
        Nombre: <b>{if $war_season.nombre_temporada}{$war_season.nombre_temporada}{else}—{/if}</b>
    </div>
    <div class="astrowara_row">
        🗓️ Duración temporada: <b>{$war_season.duracion_horas} horas</b>
    </div>
    <div class="astrowara_row">
        ⚔️ Duración de cada batalla: <b>{$war_season.duracion_batalla_horas} horas</b>
    </div>
    <div class="astrowara_row">
        ⏱️ Cooldown entre guerras: <b>{$war_season.cooldown_horas} horas</b>
    </div>

    {if $war_season.fecha_inicio}
        <div class="astrowara_row">
            Inicio: <b>{$war_season.fecha_inicio|date_format:"%d/%m/%Y %H:%M"}</b>
        </div>
    {/if}

    {if $war_season.fecha_fin && $war_season.estado == 'activa'}
        <div class="astrowara_row">
            Finaliza: <b>{$war_season.fecha_fin|date_format:"%d/%m/%Y %H:%M"}</b>
        </div>
        <div class="astrowara_row">
            ⏳ Faltan: <b id="astrowara_countdown">calculando...</b>
        </div>
    {/if}

    <div class="astrowara_row">
        🏦 Retiros habilitados:
        <b>{if $war_season.retiros_habilitados}SÍ{else}NO{/if}</b>
    </div>

    {* ============================================ *}
    {* ACCIONES                                     *}
    {* ============================================ *}
    <div class="astrowara_section">🎮 Acciones</div>

    {if $war_season.estado != 'activa'}
        {* FORMULARIO: Activar temporada con 3 duraciones *}
        <form method="post" action="admin.php?page=war&mode=activate" class="astrowara_form">

            <div class="astrowara_form_row">
                <label>📛 Nombre de la temporada</label>
                <input type="text" name="nombre" value="Guerra Galactica" maxlength="80" placeholder="Ej: Guerra Galactica">
            </div>

            <div class="astrowara_form_row">
                <label>🗓️ Duración de la TEMPORADA</label>
                <select name="horas" id="astrowara_horas_select" onchange="astrowara_toggleCustom();">
                    <option value="7">7 horas (default)</option>
                    <option value="24">24 horas (1 día)</option>
                    <option value="48">48 horas (2 días)</option>
                    <option value="72">72 horas (3 días)</option>
                    <option value="168">168 horas (7 días)</option>
                    <option value="360">360 horas (15 días)</option>
                    <option value="720">720 horas (30 días)</option>
                    <option value="744">744 horas (31 días)</option>
                    <option value="840">840 horas (35 días)</option>
                    <option value="custom">Personalizado...</option>
                </select>
                <div id="astrowara_horas_custom_wrap" style="display:none;margin-top:6px;">
                    <input type="number" name="horas_custom" id="astrowara_horas_custom" value="7" min="1" max="840" placeholder="Horas (1-840)">
                    <div class="astrowara_form_row_hint">Rango: 1 hora a 840 horas (35 días)</div>
                </div>
            </div>

            <div class="astrowara_form_row">
                <label>⚔️ Duración de cada BATALLA (horas)</label>
                <input type="number" name="dur_batalla" value="7" min="1" max="168" placeholder="7">
                <div class="astrowara_form_row_hint">Default: 7h · Rango: 1h a 168h (7 días)</div>
            </div>

            <div class="astrowara_form_row">
                <label>⏱️ COOLDOWN entre guerras por alianza (horas)</label>
                <input type="number" name="cooldown" value="7" min="0" max="168" placeholder="7">
                <div class="astrowara_form_row_hint">Default: 7h · Rango: 0h a 168h (7 días)</div>
            </div>

            <div style="text-align:center;margin-top:12px;">
                <button type="submit" class="astrowara_btn astrowara_btn-ok">▶️ Activar temporada</button>
            </div>
        </form>
    {else}
        {* BOTONES: Pausar / Reanudar / Cerrar *}
        <div style="text-align:center;">
            {if $war_season.pausada}
                <a href="admin.php?page=war&mode=resume" class="astrowara_btn astrowara_btn-ok">▶️ Reanudar</a>
            {else}
                <a href="admin.php?page=war&mode=pause" class="astrowara_btn astrowara_btn-warn">⏸️ Pausar</a>
            {/if}
            <a href="admin.php?page=war&mode=close" class="astrowara_btn astrowara_btn-danger"
               onclick="return confirm('¿Cerrar la temporada? Se habilitaran los retiros.');">
                ⛔ Cerrar temporada
            </a>
        </div>
    {/if}

    {* BOTÓN RESET (siempre disponible) *}
    <div style="text-align:center;margin-top:6px;">
        <a href="admin.php?page=war&mode=reset" class="astrowara_btn astrowara_btn-danger"
           onclick="return confirm('¿RESETEAR TODO? Se borraran puntos, cofres, batallas e historial. NO se puede deshacer.');">
            🔄 Resetear todo
        </a>
    </div>

    {* ============================================ *}
    {* BATALLAS EN CURSO                            *}
    {* ============================================ *}
    <div class="astrowara_section">⚔️ Batallas en curso</div>

    {if count($war_battles) > 0}
        <table class="astrowara_table">
            <thead>
                <tr>
                    <th style="width:40px;">#</th>
                    <th>Atacante</th>
                    <th>Defensor</th>
                    <th style="width:140px;">Clima</th>
                    <th style="width:120px;">Finaliza</th>
                    <th style="width:180px;">Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $war_battles as $b}
                    <tr>
                        <td>#{$b.id}</td>
                        <td>🏰 {$b.atacante_nombre}</td>
                        <td>🏰 {$b.defensor_nombre}</td>
                        <td style="font-size:10px;">{if $b.clima_nombre}{$b.clima_nombre}{else}—{/if}</td>
                        <td style="font-size:10px;">{$b.fin|date_format:"%d/%m %H:%M"}</td>
                        <td>
                            <a href="admin.php?page=war&view={$b.id}#participants"
                               class="astrowara_btn astrowara_btn-tiny"
                               title="Ver participantes">
                                👁️ Ver ({$b.participants_count})
                            </a>
                            <a href="admin.php?page=war&mode=finish_battle&id={$b.id}"
                               class="astrowara_btn astrowara_btn-ok astrowara_btn-tiny"
                               onclick="return confirm('¿Forzar el fin de la batalla #{$b.id}? Se ejecutara el combate AHORA.');"
                               title="Forzar finalizacion inmediata">
                                ⚡ Finalizar
                            </a>
                            <a href="admin.php?page=war&mode=cancel_battle&id={$b.id}"
                               class="astrowara_btn astrowara_btn-danger astrowara_btn-tiny"
                               onclick="return confirm('¿Cancelar la batalla #{$b.id}? No se devolveran naves.');"
                               title="Cancelar batalla">
                                ❌ Cancelar
                            </a>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    {else}
        <div class="astrowara_empty">Sin batallas activas en este momento.</div>
    {/if}

    {* ============================================ *}
    {* PARTICIPANTES DE LA BATALLA SELECCIONADA     *}
    {* ============================================ *}
    {if $war_view_battle}
        <a name="participants"></a>
        <div class="astrowara_participants_box">
            <div class="astrowara_participants_title">
                👥 Participantes de la batalla #{$war_view_battle.id}
            </div>

            <div class="astrowara_row" style="margin-bottom:8px;">
                🏰 <b>{$war_view_battle.atacante_nombre}</b> vs 🏰 <b>{$war_view_battle.defensor_nombre}</b>
                &nbsp;·&nbsp;
                Estado:
                {if $war_view_battle.estado == 'en_curso'}
                    <span class="astrowara_badge astrowara_badge-activa">EN CURSO</span>
                {elseif $war_view_battle.estado == 'finalizada'}
                    <span class="astrowara_badge astrowara_badge-cerrada">FINALIZADA</span>
                {else}
                    <span class="astrowara_badge astrowara_badge-cancel">CANCELADA</span>
                {/if}
            </div>

            {if count($war_view_participants) > 0}
                {foreach $war_view_participants as $vp}
                    <div class="astrowara_participant_row {if $vp.es_atacante}atacante{else}defensor{/if}">
                        <div class="astrowara_participant_head">
                            <span class="astrowara_participant_user">
                                👤 {if $vp.username}{$vp.username}{else}User #{$vp.user_id}{/if}
                            </span>
                            <span class="astrowara_participant_side {if $vp.es_atacante}atacante{else}defensor{/if}">
                                {if $vp.es_atacante}ATACANTE{else}DEFENSOR{/if}
                            </span>
                        </div>
                        <div class="astrowara_participant_totals">
                            📦 Naves: <b>{$vp.total_naves}</b>
                            &nbsp;·&nbsp;
                            🛡️ Defensas: <b>{$vp.total_defensas}</b>
                            &nbsp;·&nbsp;
                            📅 {$vp.fecha_envio|date_format:"%d/%m %H:%M"}
                        </div>

                        {if count($vp.naves_arr) > 0}
                            <div style="font-size:10px;color:#8899aa;margin-top:3px;">
                                <b style="color:#00e0ff;">Naves:</b>
                                {foreach $vp.naves_arr as $k => $c}
                                    {$k|replace:'_':' '}: {$c}{if !$c@last}, {/if}
                                {/foreach}
                            </div>
                        {/if}

                        {if count($vp.defensas_arr) > 0}
                            <div style="font-size:10px;color:#8899aa;margin-top:2px;">
                                <b style="color:#00e0ff;">Defensas:</b>
                                {foreach $vp.defensas_arr as $k => $c}
                                    {$k|replace:'_':' '}: {$c}{if !$c@last}, {/if}
                                {/foreach}
                            </div>
                        {/if}
                    </div>
                {/foreach}
            {else}
                <div class="astrowara_empty">Ningun jugador ha enviado naves todavia.</div>
            {/if}

            <div style="text-align:center;margin-top:10px;">
                <a href="admin.php?page=war" class="astrowara_btn astrowara_btn-tiny">❌ Cerrar vista</a>
            </div>
        </div>
    {/if}

    {* ============================================ *}
    {* BATALLAS FINALIZADAS RECIENTES               *}
    {* ============================================ *}
    <div class="astrowara_section">📜 Batallas finalizadas (últimas 10)</div>

    {if count($war_battles_fin) > 0}
        <table class="astrowara_table">
            <thead>
                <tr>
                    <th style="width:40px;">#</th>
                    <th>Atacante</th>
                    <th>Defensor</th>
                    <th style="width:140px;">Resultado</th>
                    <th style="width:100px;">Particip.</th>
                    <th style="width:100px;">Acción</th>
                </tr>
            </thead>
            <tbody>
                {foreach $war_battles_fin as $b}
                    <tr>
                        <td>#{$b.id}</td>
                        <td>🏰 {$b.atacante_nombre}</td>
                        <td>🏰 {$b.defensor_nombre}</td>
                        <td>
                            {if $b.resultado_final == 'victoria_atacante'}
                                <span class="astrowara_badge astrowara_badge-win">Victoria A.</span>
                            {elseif $b.resultado_final == 'victoria_defensor'}
                                <span class="astrowara_badge astrowara_badge-win">Victoria D.</span>
                            {elseif $b.resultado_final == 'empate'}
                                <span class="astrowara_badge astrowara_badge-tie">Empate</span>
                            {elseif $b.resultado_final == 'cancelada'}
                                <span class="astrowara_badge astrowara_badge-cancel">Cancelada</span>
                            {else}
                                <span class="astrowara_badge astrowara_badge-cancel">—</span>
                            {/if}
                        </td>
                        <td>{$b.participants_count}</td>
                        <td>
                            <a href="admin.php?page=war&view={$b.id}#participants"
                               class="astrowara_btn astrowara_btn-tiny">
                                👁️ Ver
                            </a>
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    {else}
        <div class="astrowara_empty">Sin batallas finalizadas.</div>
    {/if}

    {* ============================================ *}
    {* TOP 10 RANKING                               *}
    {* ============================================ *}
    <div class="astrowara_section">🏆 Top 10 Ranking (temporada actual)</div>

    {if count($war_ranking) > 0}
        <table class="astrowara_table">
            <thead>
                <tr>
                    <th style="width:40px;">#</th>
                    <th>Jugador</th>
                    <th style="width:200px;">Alianza</th>
                    <th style="width:100px;">Puntos WAR</th>
                </tr>
            </thead>
            <tbody>
                {foreach $war_ranking as $i => $r}
                    <tr>
                        <td>{$i+1}</td>
                        <td>{$r.username}</td>
                        <td>{if $r.alliance_name}{$r.alliance_name}{else}<i style="color:#667;">Sin alianza</i>{/if}</td>
                        <td><b style="color:#ffaa33;">{$r.puntos}</b></td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    {else}
        <div class="astrowara_empty">Aún no hay jugadores con puntos WAR.</div>
    {/if}

    {* ============================================ *}
    {* HISTORIAL DE TEMPORADAS                      *}
    {* ============================================ *}
    <div class="astrowara_section">📜 Historial de temporadas</div>

    {if count($war_historial) > 0}
        <table class="astrowara_table">
            <thead>
                <tr>
                    <th style="width:40px;">#</th>
                    <th>Nombre</th>
                    <th style="width:140px;">Inicio</th>
                    <th style="width:140px;">Fin</th>
                    <th style="width:180px;">Estado final</th>
                </tr>
            </thead>
            <tbody>
                {foreach $war_historial as $h}
                    <tr>
                        <td>#{$h.id}</td>
                        <td>{$h.nombre}</td>
                        <td>{$h.inicio|date_format:"%d/%m/%Y"}</td>
                        <td>{$h.fin|date_format:"%d/%m/%Y"}</td>
                        <td>{$h.estado_final}</td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    {else}
        <div class="astrowara_empty">Sin temporadas cerradas todavía.</div>
    {/if}

    {* ============================================ *}
    {* BOTÓN VOLVER                                 *}
    {* ============================================ *}
    <div class="astrowara_actions">
        <a href="admin.php" class="astrowara_btn">◀️ Volver al panel</a>
    </div>

</div>
</div>

{* ================================================== *}
{* SCRIPT: Toggle custom + Countdown                 *}
{* ================================================== *}

<script type="text/javascript">
function astrowara_toggleCustom() {
    var sel  = document.getElementById('astrowara_horas_select');
    var wrap = document.getElementById('astrowara_horas_custom_wrap');
    if (!sel || !wrap) return;
    if (sel.value === 'custom') {
        wrap.style.display = 'block';
    } else {
        wrap.style.display = 'none';
    }
}

{if $war_season.fecha_fin && $war_season.estado == 'activa' && !$war_season.pausada}
(function () {
    var fin = {$war_season.fecha_fin} * 1000;
    var el  = document.getElementById('astrowara_countdown');
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
{/if}
</script>

{include file="overall_footer.tpl"}