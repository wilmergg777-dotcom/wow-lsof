{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/climasAdminPage.tpl === *}
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
:root {
    --bg-card:       rgba(15, 23, 42, 0.75);
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #1e293b;
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --accent-cyan:   #00e0ff;
    --accent-gold:   #fbbf24;
    --accent-green:  #4aff88;
    --accent-red:    #ef4444;
    --accent-purple: #8b5cf6;
}

.clima_wrap {
    max-width: 1100px;
    margin: 0 auto;
    padding: 15px;
    font-family: 'Segoe UI', Roboto, sans-serif;
    color: var(--text-main);
}
.clima_panel {
    background: var(--bg-card);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 15px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.5);
    backdrop-filter: blur(6px);
}
.clima_header {
    text-align: center;
    color: #fff;
    font-size: 18px;
    font-weight: 800;
    letter-spacing: 2px;
    text-transform: uppercase;
    padding: 10px 0 15px;
    border-bottom: 1px solid var(--border-color);
    margin-bottom: 15px;
    text-shadow: 0 0 15px rgba(0,224,255,0.6);
}
.clima_alert {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 15px;
    font-size: 12px;
    font-weight: 600;
    line-height: 1.5;
}
.clima_alert.success { background: rgba(74,255,136,0.1); border: 1px solid rgba(74,255,136,0.5); color: #88ffaa; }
.clima_alert.error   { background: rgba(239,68,68,0.1); border: 1px solid rgba(239,68,68,0.5); color: #ff8f8f; }
.clima_alert.info    { background: rgba(0,224,255,0.1); border: 1px solid rgba(0,224,255,0.5); color: #88eeff; }

/* Tabs */
.clima_tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 15px;
    flex-wrap: wrap;
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 10px;
}
.clima_tab {
    padding: 8px 16px;
    background: rgba(0,0,0,0.3);
    border: 1px solid rgba(0,224,255,0.15);
    border-radius: 8px;
    color: var(--text-muted);
    font-weight: 700;
    font-size: 11px;
    text-decoration: none;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    transition: 0.25s ease;
}
.clima_tab:hover { background: rgba(0,224,255,0.1); color: var(--accent-cyan); border-color: rgba(0,224,255,0.5); }
.clima_tab.active {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 15px rgba(0,224,255,0.4);
}

/* Stats cards */
.clima_stats_grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 12px;
    margin-bottom: 20px;
}
.clima_stat_card {
    background: rgba(0,0,0,0.3);
    border: 1px solid rgba(0,224,255,0.15);
    border-radius: 10px;
    padding: 14px;
    text-align: center;
    transition: 0.2s ease;
}
.clima_stat_card:hover { border-color: rgba(0,224,255,0.5); transform: translateY(-2px); }
.clima_stat_value { font-size: 22px; font-weight: 800; color: var(--accent-cyan); text-shadow: 0 0 10px rgba(0,224,255,0.4); }
.clima_stat_label { font-size: 10px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; margin-top: 4px; }

/* Tabla catálogo */
.clima_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    margin-bottom: 15px;
}
.clima_table thead tr {
    background: linear-gradient(135deg, #004488, #0077cc);
}
.clima_table thead th {
    padding: 8px 6px;
    color: #fff;
    font-weight: 700;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid var(--accent-cyan);
    text-align: center;
}
.clima_table tbody tr {
    background: rgba(0,0,0,0.2);
    border-bottom: 1px solid rgba(0,224,255,0.06);
    transition: 0.15s ease;
}
.clima_table tbody tr:hover { background: rgba(0,224,255,0.07); }
.clima_table tbody td {
    padding: 8px 6px;
    text-align: center;
    vertical-align: middle;
    color: var(--text-main);
}
.clima_table input[type="text"],
.clima_table input[type="number"],
.clima_table select {
    padding: 4px 6px;
    background: rgba(0,0,0,0.5);
    border: 1px solid rgba(0,224,255,0.3);
    border-radius: 6px;
    color: #fff;
    font-size: 11px;
    font-family: 'Courier New', monospace;
    text-align: right;
    outline: none;
    width: 60px;
}
.clima_table input:focus, .clima_table select:focus {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 8px rgba(0,224,255,0.5);
}
.clima_table select { text-align: left; width: auto; font-family: inherit; }
.clima_table .clima_emoji { font-size: 18px; }
.clima_table .clima_neg { color: var(--accent-red); font-weight: 700; }
.clima_table .clima_pos { color: var(--accent-green); font-weight: 700; }
.clima_table .clima_neu { color: var(--text-muted); font-weight: 700; }

/* Botones */
.clima_btn {
    padding: 6px 14px;
    border-radius: 6px;
    border: 1px solid;
    font-weight: 700;
    font-size: 10px;
    cursor: pointer;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    transition: 0.25s ease;
    font-family: inherit;
    text-decoration: none;
    display: inline-block;
}
.clima_btn_save {
    background: linear-gradient(135deg, rgba(0,102,204,0.9), rgba(0,153,255,0.9));
    border-color: var(--accent-cyan);
    color: #fff;
}
.clima_btn_save:hover { box-shadow: 0 0 15px rgba(0,224,255,0.6); transform: translateY(-1px); }
.clima_btn_danger {
    background: rgba(239,68,68,0.15);
    border-color: var(--accent-red);
    color: var(--accent-red);
}
.clima_btn_danger:hover { background: var(--accent-red); color: #fff; }
.clima_btn_success {
    background: rgba(74,255,136,0.15);
    border-color: var(--accent-green);
    color: var(--accent-green);
}
.clima_btn_success:hover { background: var(--accent-green); color: #000; }
.clima_btn_gold {
    background: linear-gradient(135deg, rgba(251,191,36,0.9), rgba(245,158,11,0.9));
    border-color: var(--accent-gold);
    color: #000;
}
.clima_btn_gold:hover { box-shadow: 0 0 15px rgba(251,191,36,0.6); transform: translateY(-1px); }

/* Formularios */
.clima_form_box {
    background: rgba(0,0,0,0.3);
    border: 1px solid rgba(0,224,255,0.15);
    border-radius: 10px;
    padding: 15px;
    margin-bottom: 15px;
}
.clima_form_title {
    color: var(--accent-cyan);
    font-weight: 800;
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(0,224,255,0.2);
    padding-bottom: 8px;
    margin-bottom: 12px;
}
.clima_form_row {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
    flex-wrap: wrap;
}
.clima_form_row label {
    color: var(--text-muted);
    font-weight: 600;
    font-size: 11px;
    min-width: 100px;
}
.clima_form_row input[type="text"],
.clima_form_row input[type="number"],
.clima_form_row select {
    padding: 6px 10px;
    background: rgba(0,0,0,0.5);
    border: 1px solid rgba(0,224,255,0.3);
    border-radius: 6px;
    color: #fff;
    font-size: 11px;
    outline: none;
    min-width: 180px;
}
.clima_form_row input:focus, .clima_form_row select:focus {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 8px rgba(0,224,255,0.5);
}

/* Log tabla */
.clima_log {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
}
.clima_log thead th {
    padding: 8px 6px;
    background: rgba(0,224,255,0.1);
    color: var(--accent-cyan);
    font-weight: 700;
    font-size: 10px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0,224,255,0.3);
}
.clima_log tbody td {
    padding: 6px;
    border-bottom: 1px solid rgba(0,224,255,0.06);
    color: var(--text-main);
}
.clima_log tbody tr:hover { background: rgba(0,224,255,0.05); }

@media (max-width: 720px) {
    .clima_wrap { padding: 8px; }
    .clima_panel { padding: 10px; }
    .clima_table { font-size: 9px; }
    .clima_table input[type="number"] { width: 45px; font-size: 10px; }
    .clima_tabs { flex-direction: column; }
    .clima_tab { text-align: center; }
}
</style>

<div class="clima_wrap">
    <div class="clima_panel">

        <div class="clima_header">🌦️ Panel Admin — Sistema de Clima</div>

        {if $message}
        <div class="clima_alert {$msgType}">{$message}</div>
        {/if}

        {* ─── Stats rápidas ─── *}
        <div class="clima_stats_grid">
            <div class="clima_stat_card">
                <div class="clima_stat_value">{$stats.total_climas}</div>
                <div class="clima_stat_label">Climas en catálogo</div>
            </div>
            <div class="clima_stat_card">
                <div class="clima_stat_value">{$stats.climas_activos}</div>
                <div class="clima_stat_label">Climas activos</div>
            </div>
            <div class="clima_stat_card">
                <div class="clima_stat_value">{$stats.total_planetas}</div>
                <div class="clima_stat_label">Planetas/Lunas</div>
            </div>
            <div class="clima_stat_card">
                <div class="clima_stat_value">{if $stats.planetas_sin_clima > 0}<span style="color:var(--accent-red);">{$stats.planetas_sin_clima}</span>{else}0{/if}</div>
                <div class="clima_stat_label">Sin clima</div>
            </div>
            <div class="clima_stat_card">
                <div class="clima_stat_value" style="font-size:14px;">{$stats.ultima_rotacion}</div>
                <div class="clima_stat_label">Última rotación</div>
            </div>
        </div>

        {* ─── Tabs ─── *}
        <div class="clima_tabs">
            <a href="admin.php?page=climas&tab=catalogo" class="clima_tab {if $active_tab == 'catalogo'}active{/if}">📋 Catálogo</a>
            <a href="admin.php?page=climas&tab=forzar" class="clima_tab {if $active_tab == 'forzar'}active{/if}">⚡ Forzar Clima</a>
            <a href="admin.php?page=climas&tab=acciones" class="clima_tab {if $active_tab == 'acciones'}active{/if}">🔧 Acciones</a>
            <a href="admin.php?page=climas&tab=log" class="clima_tab {if $active_tab == 'log'}active{/if}">📜 Log</a>
            <a href="admin.php?page=climas&tab=estado" class="clima_tab {if $active_tab == 'estado'}active{/if}">📊 Estado Global</a>
        </div>

        {* ═══════════════════════════════════════════════════════════ *}
        {* TAB: CATÁLOGO *}
        {* ═══════════════════════════════════════════════════════════ *}
        {if $active_tab == 'catalogo'}
        <div class="clima_form_box">
            <div class="clima_form_title">📋 Catálogo de Climas</div>
            <table class="clima_table">
                <thead>
                    <tr>
                        <th>Emoji</th>
                        <th>Nombre</th>
                        <th>Atk</th>
                        <th>Def</th>
                        <th>Bajas</th>
                        <th>Botín</th>
                        <th>Peso</th>
                        <th>Categoría</th>
                        <th>Activo</th>
                        <th>Acción</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $catalogo_climas as $clima}
                    <tr>
                        <td class="clima_emoji">{$clima.emoji}</td>
                        <td style="text-align:left;">
                            <form action="admin.php?page=climas" method="post" style="display:flex;gap:4px;align-items:center;">
                                <input type="hidden" name="mode" value="guardarClima">
                                <input type="hidden" name="clima_id" value="{$clima.id}">
                                <input type="hidden" name="descripcion" value="{$clima.descripcion|escape:'html'}">
                                <input type="hidden" name="categoria" value="{$clima.categoria}">
                                <input type="hidden" name="activo" value="{$clima.activo}">
                                <input type="text" name="nombre" value="{$clima.nombre|escape:'html'}" style="width:120px;text-align:left;">
                        </td>
                        <td>
                                <input type="number" name="factor_ataque" value="{$clima.factor_ataque}" step="0.05" min="0" max="3">
                        </td>
                        <td>
                                <input type="number" name="factor_defensa" value="{$clima.factor_defensa}" step="0.05" min="0" max="3">
                        </td>
                        <td>
                                <input type="number" name="factor_bajas" value="{$clima.factor_bajas}" step="0.05" min="0" max="1.25">
                        </td>
                        <td>
                                <input type="number" name="factor_botin" value="{$clima.factor_botin}" step="0.05" min="0" max="3">
                        </td>
                        <td>
                                <input type="number" name="peso" value="{$clima.peso}" step="1" min="0" max="255">
                        </td>
                        <td>
                            <span style="font-size:9px;text-transform:uppercase;color:var(--text-muted);">{$clima.categoria}</span>
                        </td>
                        <td>
                            {if $clima.clave == 'despejado'}
                                <span style="color:var(--accent-green);font-weight:700;">✓ Forzado</span>
                            {else}
                                {if $clima.activo == 1}
                                    <a href="admin.php?page=climas&mode=toggleClima&clima_id={$clima.id}&activo=0&tab=catalogo" class="clima_btn clima_btn_danger" onclick="return confirm('¿Desactivar este clima? No se volverá a sortear.');">Desactivar</a>
                                {else}
                                    <a href="admin.php?page=climas&mode=toggleClima&clima_id={$clima.id}&activo=1&tab=catalogo" class="clima_btn clima_btn_success">Activar</a>
                                {/if}
                            {/if}
                        </td>
                        <td>
                                <button type="submit" class="clima_btn clima_btn_save">Guardar</button>
                            </form>
                        </td>
                    </tr>
                    {/foreach}
                </tbody>
            </table>
            <p style="color:var(--text-muted);font-size:10px;margin-top:10px;">
                ⚠️ Reglas: factores entre 0.00 y 3.00. <strong>factor_bajas máximo 1.25</strong>. "Cielo Despejado" no se puede desactivar (es el neutro de seguridad).
            </p>
        </div>
        {/if}

        {* ═══════════════════════════════════════════════════════════ *}
        {* TAB: FORZAR CLIMA *}
        {* ═══════════════════════════════════════════════════════════ *}
        {if $active_tab == 'forzar'}
        
        {* ─── Forzar a un planeta/luna ─── *}
        <div class="clima_form_box">
            <div class="clima_form_title">⚡ Forzar Clima a un Planeta/Luna</div>
            <form action="admin.php?page=climas" method="post">
                <input type="hidden" name="mode" value="forzarPlaneta">
                <div class="clima_form_row">
                    <label>ID del planeta/luna:</label>
                    <input type="number" name="planeta_id" placeholder="Ej: 123" required>
                </div>
                <div class="clima_form_row">
                    <label>Clima a aplicar:</label>
                    <select name="clima_id" required>
                        <option value="">-- Selecciona --</option>
                        {foreach $catalogo_climas as $clima}
                            {if $clima.activo == 1}
                                <option value="{$clima.id}">{$clima.emoji} {$clima.nombre}</option>
                            {/if}
                        {/foreach}
                    </select>
                </div>
                <div class="clima_form_row">
                    <button type="submit" class="clima_btn clima_btn_gold">Forzar Clima</button>
                </div>
            </form>
            <p style="color:var(--text-muted);font-size:10px;margin-top:8px;">
                💡 Tip: puedes encontrar el ID del planeta en la URL de la galaxia o en el espionaje.
            </p>
        </div>

        {* ─── Forzar a una galaxia entera ─── *}
        <div class="clima_form_box">
            <div class="clima_form_title">🌌 Forzar Clima a una Galaxia Entera</div>
            <form action="admin.php?page=climas" method="post" onsubmit="return confirm('¿Forzar este clima a TODOS los planetas y lunas de la galaxia? Se aplicará inmediatamente.');">
                <input type="hidden" name="mode" value="forzarGalaxia">
                <div class="clima_form_row">
                    <label>Número de galaxia:</label>
                    <input type="number" name="galaxia" placeholder="Ej: 3" min="1" required>
                </div>
                <div class="clima_form_row">
                    <label>Clima a aplicar:</label>
                    <select name="clima_id" required>
                        <option value="">-- Selecciona --</option>
                        {foreach $catalogo_climas as $clima}
                            {if $clima.activo == 1}
                                <option value="{$clima.id}">{$clima.emoji} {$clima.nombre}</option>
                            {/if}
                        {/foreach}
                    </select>
                </div>
                <div class="clima_form_row">
                    <button type="submit" class="clima_btn clima_btn_gold">Forzar a Galaxia</button>
                </div>
            </form>
            <p style="color:var(--text-muted);font-size:10px;margin-top:8px;">
                ⚠️ <strong>Usar con precaución.</strong> Fuerza el clima a todos los cuerpos celestes de esa galaxia. Útil para eventos especiales.
            </p>
        </div>
        {/if}

        {* ═══════════════════════════════════════════════════════════ *}
        {* TAB: ACCIONES *}
        {* ═══════════════════════════════════════════════════════════ *}
        {if $active_tab == 'acciones'}
        <div class="clima_form_box">
            <div class="clima_form_title">🔧 Acciones Manuales</div>
            <p style="color:var(--text-muted);font-size:11px;margin-bottom:15px;">
                Estas acciones ejecutan el cron manualmente. Úsalas para testear o si el cron automático falló.
            </p>

            <div class="clima_form_row">
                <form action="admin.php?page=climas" method="post" style="display:inline-block;margin-right:10px;">
                    <input type="hidden" name="mode" value="rotarAhora">
                    <button type="submit" class="clima_btn clima_btn_save" onclick="return confirm('¿Ejecutar rotación manual AHORA? Afectará a todos los planetas/lunas.');">🔄 Rotar Ahora</button>
                </form>
                <form action="admin.php?page=climas" method="post" style="display:inline-block;margin-right:10px;">
                    <input type="hidden" name="mode" value="predecirAhora">
                    <button type="submit" class="clima_btn clima_btn_success" onclick="return confirm('¿Ejecutar predicción manual AHORA? Asignará clima previsto a todos los planetas sin predicción.');">🔮 Predecir Ahora</button>
                </form>
                <form action="admin.php?page=climas" method="post" style="display:inline-block;">
                    <input type="hidden" name="mode" value="limpiarHuerfanos">
                    <button type="submit" class="clima_btn clima_btn_danger" onclick="return confirm('¿Limpiar registros huérfanos de clima_planeta?');">🧹 Limpiar Huérfanos</button>
                </form>
            </div>
        </div>

        <div class="clima_form_box">
            <div class="clima_form_title">ℹ️ Información del Sistema</div>
            <table class="clima_log" style="font-size:11px;">
                <tbody>
                    <tr>
                        <td style="color:var(--text-muted);">Cron de rotación:</td>
                        <td><strong>03:00 UTC</strong> (integrado en cron.php)</td>
                    </tr>
                    <tr>
                        <td style="color:var(--text-muted);">Cron de predicción:</td>
                        <td><strong>21:00 UTC</strong> (integrado en cron.php)</td>
                    </tr>
                    <tr>
                        <td style="color:var(--text-muted);">Planetas sin clima:</td>
                        <td>
                            {if $stats.planetas_sin_clima > 0}
                                <span style="color:var(--accent-red);">{$stats.planetas_sin_clima} pendientes</span>
                                <form action="admin.php?page=climas" method="post" style="display:inline;">
                                    <input type="hidden" name="mode" value="rotarAhora">
                                    <button type="submit" class="clima_btn clima_btn_success" style="padding:2px 8px;font-size:9px;">Asignar ahora</button>
                                </form>
                            {else}
                                <span style="color:var(--accent-green);">✓ Todos tienen clima</span>
                            {/if}
                        </td>
                    </tr>
                    <tr>
                        <td style="color:var(--text-muted);">Última rotación:</td>
                        <td>{$stats.ultima_rotacion}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        {/if}

        {* ═══════════════════════════════════════════════════════════ *}
        {* TAB: LOG *}
        {* ═══════════════════════════════════════════════════════════ *}
        {if $active_tab == 'log'}
        <div class="clima_form_box">
            <div class="clima_form_title">📜 Log de Rotaciones (últimas 30)</div>
            <table class="clima_log">
                <thead>
                    <tr>
                        <th>Fecha</th>
                        <th>Tipo</th>
                        <th>Afectados</th>
                        <th>Duración</th>
                        <th>Admin</th>
                        <th>Detalle</th>
                    </tr>
                </thead>
                <tbody>
                    {if $log_reciente}
                        {foreach $log_reciente as $log}
                        <tr>
                            <td>{$log.created_fmt}</td>
                            <td>{$log.tipo_label}</td>
                            <td><strong>{$log.planetas_afectados}</strong></td>
                            <td>{$log.duracion_fmt}</td>
                            <td>{if $log.admin_id > 0}#{$log.admin_id}{else}—{/if}</td>
                            <td style="font-size:10px;color:var(--text-muted);">{$log.detalle|escape:'html'}</td>
                        </tr>
                        {/foreach}
                    {else}
                        <tr>
                            <td colspan="6" style="text-align:center;color:var(--text-muted);padding:20px;">No hay registros todavía.</td>
                        </tr>
                    {/if}
                </tbody>
            </table>
        </div>
        {/if}

        {* ═══════════════════════════════════════════════════════════ *}
        {* TAB: ESTADO GLOBAL *}
        {* ═══════════════════════════════════════════════════════════ *}
        {if $active_tab == 'estado'}
        <div class="clima_form_box">
            <div class="clima_form_title">📊 Distribución Global de Climas</div>
            <p style="color:var(--text-muted);font-size:11px;margin-bottom:15px;">
                Total de planetas/lunas con clima activo: <strong style="color:var(--accent-cyan);">{$total_climas_activos}</strong>
            </p>
            <table class="clima_log">
                <thead>
                    <tr>
                        <th>Emoji</th>
                        <th>Clima</th>
                        <th>Categoría</th>
                        <th>Cantidad</th>
                        <th>Porcentaje</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $distribucion as $dist}
                    <tr>
                        <td style="font-size:18px;">{$dist.emoji}</td>
                        <td>
                            <strong>{$dist.nombre}</strong>
                            {if $dist.activo != 1}
                                <span style="color:var(--accent-red);font-size:9px;"> (desactivado)</span>
                            {/if}
                        </td>
                        <td>
                            {if $dist.categoria == 'suave'}
                                <span style="color:var(--accent-green);font-size:10px;">Suave</span>
                            {elseif $dist.categoria == 'medio'}
                                <span style="color:var(--accent-gold);font-size:10px;">Medio</span>
                            {else}
                                <span style="color:var(--accent-red);font-size:10px;">Raro</span>
                            {/if}
                        </td>
                        <td><strong>{$dist.count_fmt}</strong></td>
                        <td>
                            <div style="background:rgba(0,0,0,0.4);border-radius:4px;height:16px;overflow:hidden;position:relative;">
                                <div style="background:linear-gradient(90deg,var(--accent-cyan),var(--accent-purple));height:100%;width:{$dist.pct}%;"></div>
                                <span style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);font-size:9px;font-weight:700;color:#fff;text-shadow:0 1px 2px #000;">{$dist.pct}%</span>
                            </div>
                        </td>
                    </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
        {/if}

    </div>
</div>

{include file="overall_footer.tpl"}