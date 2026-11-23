{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/improvementsAdminPage.tpl === *}
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

<style>
.astroimpa_container {
    max-width: 1100px;
    margin: 0 auto;
    background: linear-gradient(180deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #00ccff33;
    border-radius: 8px;
    padding: 16px;
    color: #c8d6e5;
    font-size: 12px;
    text-align: center;
}
.astroimpa_title {
    text-transform: uppercase;
    color: #00ccff;
    border-bottom: 1px solid #00ccff33;
    padding-bottom: 6px;
    margin-bottom: 14px;
    font-size: 16px;
    letter-spacing: 1px;
    text-align: left;
    display: block;
}
.astroimpa_msg_success {
    display: block;
    background: #0a2a1a;
    border: 1px solid #66ff99;
    color: #66ff99;
    padding: 10px;
    border-radius: 6px;
    margin-bottom: 12px;
    text-align: center;
}
.astroimpa_msg_error {
    display: block;
    background: #2a0a1a;
    border: 1px solid #ff4488;
    color: #ff4488;
    padding: 10px;
    border-radius: 6px;
    margin-bottom: 12px;
    text-align: center;
}
.astroimpa_stats {
    display: inline-block;
    background: #0a0f1a;
    border: 1px solid #00ccff33;
    border-radius: 8px;
    padding: 12px 24px;
    margin-bottom: 16px;
    font-size: 13px;
}
.astroimpa_stats strong {
    color: #00ccff;
    font-size: 16px;
}
.astroimpa_grid {
    display: inline-block;
    width: 100%;
    text-align: center;
}
.astroimpa_card {
    display: inline-block;
    width: 480px;
    margin: 8px;
    padding: 14px;
    background: #0a0f1a;
    border: 1px solid #0077cc;
    border-radius: 8px;
    vertical-align: top;
    text-align: left;
    box-sizing: border-box;
}
.astroimpa_card.active {
    border-color: #66ff99;
    box-shadow: 0 0 14px rgba(102,255,153,0.25);
}
.astroimpa_card.inactive {
    border-color: #334455;
    opacity: 0.75;
}
.astroimpa_card_header {
    display: block;
    margin-bottom: 10px;
    border-bottom: 1px solid #00ccff22;
    padding-bottom: 8px;
}
.astroimpa_card_title {
    display: inline-block;
    color: #00ccff;
    font-size: 14px;
    font-weight: bold;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}
.astroimpa_card_badge {
    display: inline-block;
    float: right;
    padding: 3px 10px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: bold;
    text-transform: uppercase;
}
.astroimpa_badge_on {
    background: #66ff99;
    color: #0f1624;
}
.astroimpa_badge_off {
    background: #334455;
    color: #c8d6e5;
}
.astroimpa_card_desc {
    display: block;
    color: #8899aa;
    font-size: 11px;
    margin-bottom: 10px;
}
.astroimpa_card_info {
    display: block;
    margin-bottom: 8px;
    font-size: 11px;
}
.astroimpa_card_info span {
    color: #ffaa33;
    font-weight: bold;
}
.astroimpa_actions {
    display: block;
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid #00ccff22;
}
.astroimpa_btn {
    display: inline-block;
    padding: 6px 14px;
    border: none;
    border-radius: 4px;
    font-size: 11px;
    font-weight: bold;
    cursor: pointer;
    text-decoration: none;
    margin: 2px;
    transition: 0.2s ease;
}
.astroimpa_btn_on {
    background: #66ff99;
    color: #0f1624;
}
.astroimpa_btn_on:hover {
    background: #88ffbb;
    box-shadow: 0 0 10px rgba(102,255,153,0.5);
}
.astroimpa_btn_off {
    background: #ff4488;
    color: #fff;
}
.astroimpa_btn_off:hover {
    background: #ff66aa;
    box-shadow: 0 0 10px rgba(255,68,136,0.5);
}
.astroimpa_btn_blue {
    background: #004488;
    color: #fff;
    border: 1px solid #0077cc;
}
.astroimpa_btn_blue:hover {
    background: #0099ff;
    box-shadow: 0 0 10px rgba(0,224,255,0.4);
}
.astroimpa_form_inline {
    display: inline-block;
    margin: 0;
    padding: 0;
}
.astroimpa_input {
    display: inline-block;
    padding: 5px 8px;
    background: #121821;
    color: #c8d6e5;
    border: 1px solid #00ccff33;
    border-radius: 4px;
    font-size: 11px;
    margin: 2px;
    width: 130px;
    box-sizing: border-box;
}
.astroimpa_input:focus {
    outline: none;
    border-color: #00ccff;
}
.astroimpa_label {
    display: block;
    font-size: 10px;
    color: #8899aa;
    margin: 8px 0 4px 0;
    text-transform: uppercase;
}
.astroimpa_empty {
    display: block;
    color: #556677;
    font-style: italic;
    padding: 40px;
    text-align: center;
}
</style>

<div class="astroimpa_container">

    <div class="astroimpa_title">
        🏆 ADMIN — Temporadas de Mejoras
        <a href="admin.php?page=menu" style="float:right;color:#00ccff;font-size:11px;text-decoration:none;text-transform:none;">← Volver al Menu</a>
    </div>

    {if $astroimpa_msg_success}
        <div class="astroimpa_msg_success">{$astroimpa_msg_success}</div>
    {/if}

    {if $astroimpa_msg_error}
        <div class="astroimpa_msg_error">{$astroimpa_msg_error}</div>
    {/if}

    <div class="astroimpa_stats">
        Temporadas totales: <strong>{$astroimpa_stats.total_seasons}</strong>
        &nbsp;|&nbsp;
        Temporadas activas: <strong>{$astroimpa_stats.active_seasons}</strong>
    </div>

    <div class="astroimpa_grid">
        {foreach $astroimpa_seasons as $season}
            <div class="astroimpa_card {if $season.active}active{else}inactive{/if}">

                <div class="astroimpa_card_header">
                    <span class="astroimpa_card_title">
                        T{$season.season_number} — {$season.name}
                    </span>
                    {if $season.active}
                        <span class="astroimpa_card_badge astroimpa_badge_on">ACTIVA</span>
                    {else}
                        <span class="astroimpa_card_badge astroimpa_badge_off">INACTIVA</span>
                    {/if}
                </div>

                <span class="astroimpa_card_desc">{$season.description}</span>

                <div class="astroimpa_card_info">
                    Modo actual: <span>{$season.mode|upper}</span>
                </div>

                {if $season.mode == 'auto'}
                    <div class="astroimpa_card_info">
                        Inicio: <span>{if $season.date_start > 0}{$season.date_start|date_format:"%d/%m/%Y %H:%M"}{else}—{/if}</span>
                    </div>
                    <div class="astroimpa_card_info">
                        Fin: <span>{if $season.date_end > 0}{$season.date_end|date_format:"%d/%m/%Y %H:%M"}{else}—{/if}</span>
                    </div>
                {/if}

                <div class="astroimpa_actions">

                    {* Botón Activar / Desactivar *}
                    <form method="post" action="admin.php?page=improvementsadmin" class="astroimpa_form_inline">
                        <input type="hidden" name="season_number" value="{$season.season_number}">
                        {if $season.active}
                            <input type="hidden" name="action" value="desactivar">
                            <button type="submit" class="astroimpa_btn astroimpa_btn_off">❌ Desactivar</button>
                        {else}
                            <input type="hidden" name="action" value="activar">
                            <button type="submit" class="astroimpa_btn astroimpa_btn_on">✅ Activar</button>
                        {/if}
                    </form>

                    {* Botón Manual / Auto *}
                    <form method="post" action="admin.php?page=improvementsadmin" class="astroimpa_form_inline">
                        <input type="hidden" name="season_number" value="{$season.season_number}">
                        <input type="hidden" name="action" value="modo">
                        {if $season.mode == 'auto'}
                            <input type="hidden" name="mode" value="manual">
                            <button type="submit" class="astroimpa_btn astroimpa_btn_blue">🔧 Pasar a Manual</button>
                        {else}
                            <input type="hidden" name="mode" value="auto">
                            <button type="submit" class="astroimpa_btn astroimpa_btn_blue">⏰ Pasar a Auto</button>
                        {/if}
                    </form>

                    {* Fechas (solo si está en modo auto) *}
                    {if $season.mode == 'auto'}
                        <form method="post" action="admin.php?page=improvementsadmin" style="margin-top:8px;">
                            <input type="hidden" name="season_number" value="{$season.season_number}">
                            <input type="hidden" name="action" value="fechas">

                            <span class="astroimpa_label">Fecha inicio</span>
                            <input type="datetime-local" name="date_start" class="astroimpa_input"
                                value="{if $season.date_start > 0}{$season.date_start|date_format:"%Y-%m-%dT%H:%M"}{/if}">

                            <span class="astroimpa_label">Fecha fin</span>
                            <input type="datetime-local" name="date_end" class="astroimpa_input"
                                value="{if $season.date_end > 0}{$season.date_end|date_format:"%Y-%m-%dT%H:%M"}{/if}">

                            <button type="submit" class="astroimpa_btn astroimpa_btn_blue" style="margin-top:4px;">💾 Guardar Fechas</button>
                        </form>
                    {/if}

                </div>

            </div>
        {/foreach}
    </div>

    {if $astroimpa_seasons|@count == 0}
        <div class="astroimpa_empty">No hay temporadas registradas.</div>
    {/if}

</div>

{include file="overall_footer.tpl"}