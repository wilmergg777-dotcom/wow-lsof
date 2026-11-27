{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/eventsAdminPage.tpl === *}
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
/* ═══════════════════════════════════════════════════════════
   ADMIN EVENTOS — AstroIO v3.0
   Glassmorphism + Acento Cyan
   Prefijo: .eva_
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

.eva_wrap {
    max-width: 1300px;
    margin: 0 auto;
    padding: 15px;
    color: var(--text-main);
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.eva_title {
    font-size: 22px;
    color: var(--accent-cyan);
    text-shadow: 0 0 12px rgba(0, 224, 255, 0.6);
    letter-spacing: 1px;
    margin: 0 0 6px 0;
    text-align: center;
}

.eva_subtitle {
    font-size: 12px;
    color: var(--text-muted);
    text-align: center;
    margin-bottom: 18px;
}

/* ---------- Mensajes ---------- */
.eva_msg {
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    font-weight: 600;
    border-left: 4px solid;
    font-size: 13px;
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
}
.eva_msg.success {
    background: rgba(74, 255, 136, 0.12);
    border-left-color: var(--accent-green);
    color: var(--accent-green);
}
.eva_msg.error {
    background: rgba(239, 68, 68, 0.12);
    border-left-color: var(--accent-red);
    color: var(--accent-red);
}

/* ---------- Título sección ---------- */
.eva_section_title {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: var(--text-title);
    padding: 8px 14px;
    border-radius: 8px;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 1.2px;
    text-transform: uppercase;
    border-left: 4px solid var(--accent-cyan);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.4);
    text-align: center;
    margin: 20px 0 12px 0;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

/* ---------- Formulario ---------- */
.eva_form {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    padding: 16px;
    margin-bottom: 20px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}

.eva_form_row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
    margin-bottom: 12px;
}

.eva_form_row.full {
    grid-template-columns: 1fr;
}

.eva_field {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.eva_field label {
    font-size: 11px;
    color: var(--accent-cyan);
    font-weight: 700;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}

.eva_field input,
.eva_field select,
.eva_field textarea {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    padding: 8px 10px;
    color: var(--text-main);
    font-size: 12px;
    font-family: inherit;
    transition: all 0.25s ease;
}

.eva_field input:focus,
.eva_field select:focus,
.eva_field textarea:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.5);
    transform: translateY(-1px);
}

.eva_field textarea {
    resize: vertical;
    min-height: 60px;
}

.eva_field .hint {
    font-size: 10px;
    color: var(--text-muted);
    font-style: italic;
}

/* ---------- Botones ---------- */
.eva_btn {
    padding: 10px 20px;
    border: 1px solid transparent;
    border-radius: 6px;
    font-weight: 700;
    font-size: 12px;
    letter-spacing: 1px;
    cursor: pointer;
    text-transform: uppercase;
    transition: all 0.25s ease;
    text-decoration: none;
    display: inline-block;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
    font-family: inherit;
}

.eva_btn.primary {
    background: linear-gradient(135deg, #0066cc 0%, #0099ff 100%);
    color: #fff;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 14px rgba(0, 153, 255, 0.4);
}
.eva_btn.primary:hover {
    background: linear-gradient(135deg, #0099ff 0%, #00ccff 100%);
    box-shadow: 0 0 22px rgba(0, 224, 255, 0.7);
    transform: translateY(-2px);
}

.eva_btn.success {
    background: linear-gradient(135deg, #228833 0%, #4aff88 100%);
    color: #fff;
    border-color: var(--accent-green);
}
.eva_btn.success:hover {
    background: linear-gradient(135deg, #4aff88 0%, #86ffb8 100%);
    box-shadow: 0 0 20px rgba(74, 255, 136, 0.6);
    transform: translateY(-2px);
}

.eva_btn.danger {
    background: linear-gradient(135deg, #880022 0%, #cc0044 100%);
    color: #fff;
    border-color: var(--accent-red);
}
.eva_btn.danger:hover {
    background: linear-gradient(135deg, #cc0044 0%, #ef4444 100%);
    box-shadow: 0 0 18px rgba(239, 68, 68, 0.6);
    transform: translateY(-2px);
}

.eva_btn.warning {
    background: linear-gradient(135deg, #aa6600 0%, #fbbf24 100%);
    color: #1a1000;
    border-color: var(--accent-gold);
}
.eva_btn.warning:hover {
    background: linear-gradient(135deg, #fbbf24 0%, #fde047 100%);
    box-shadow: 0 0 18px rgba(251, 191, 36, 0.6);
    transform: translateY(-2px);
    color: #1a1000;
}

.eva_btn.small {
    padding: 5px 10px;
    font-size: 10px;
}

.eva_actions_row {
    display: flex;
    gap: 8px;
    justify-content: flex-end;
    margin-top: 10px;
}

/* ---------- Tabla ---------- */
.eva_table_wrap {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.35);
}

.eva_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
}

.eva_table thead th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    color: var(--accent-cyan);
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 1px;
    padding: 10px 8px;
    text-align: left;
    border-bottom: 2px solid rgba(0, 224, 255, 0.3);
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.eva_table tbody td {
    padding: 8px;
    border-bottom: 1px solid var(--border-color);
    color: var(--text-main);
    vertical-align: middle;
}

.eva_table tbody tr:hover {
    background: rgba(0, 224, 255, 0.05);
}

.eva_table tbody tr.inactive {
    opacity: 0.5;
}

.eva_icon_cell {
    font-size: 20px;
    text-align: center;
    width: 40px;
}

.eva_name {
    font-weight: 700;
    color: var(--text-title);
}

.eva_desc {
    font-size: 11px;
    color: var(--text-muted);
    max-width: 220px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.eva_badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.5px;
    text-transform: uppercase;
}
.eva_badge.daily  { background: rgba(0, 224, 255, 0.15); color: var(--accent-cyan); }
.eva_badge.weekly { background: rgba(139, 92, 246, 0.15); color: var(--accent-purple); }
.eva_badge.elite  { background: rgba(251, 191, 36, 0.15); color: var(--accent-gold); }
.eva_badge.admin  { background: rgba(74, 255, 136, 0.15); color: var(--accent-green); }

.eva_active_y { color: var(--accent-green); font-weight: 700; }
.eva_active_n { color: var(--accent-red); font-weight: 700; }

.eva_stats {
    font-size: 10px;
    color: var(--text-muted);
    font-family: 'Courier New', monospace;
}

.eva_row_actions {
    display: flex;
    gap: 4px;
    flex-wrap: wrap;
}

/* ---------- Responsive ---------- */
@media (max-width: 900px) {
    .eva_form_row { grid-template-columns: 1fr; }
    .eva_table { font-size: 11px; }
    .eva_table thead th { font-size: 9px; padding: 6px 4px; }
}
</style>

<div class="eva_wrap">

    <h1 class="eva_title">🎉 Panel de Eventos</h1>
    <div class="eva_subtitle">Crear, editar y gestionar eventos del servidor</div>

    {if $message}
        <div class="eva_msg {$msgType}">{$message}</div>
    {/if}

    {* ============ FORMULARIO (crear o editar) ============ *}
    <div class="eva_section_title">
        {if $editing}✏️ Editando evento #{$editing.event_id}{else}➕ Crear nuevo evento{/if}
    </div>

    <form method="post" action="admin.php?page=events" class="eva_form">

        {if $editing}
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="event_id" value="{$editing.event_id}">
        {else}
            <input type="hidden" name="action" value="create">
        {/if}

        <div class="eva_form_row">
            <div class="eva_field">
                <label>Nombre</label>
                <input type="text" name="event_name" value="{if $editing}{$editing.event_name}{/if}" maxlength="80" required>
            </div>
            <div class="eva_field">
                <label>Icono (texto)</label>
                <select name="event_icon">
                    <option value="ATK"  {if $editing && $editing.event_icon == 'ATK'}selected{/if}>ATK → ⚔️</option>
                    <option value="REC"  {if $editing && $editing.event_icon == 'REC'}selected{/if}>REC → ♻️</option>
                    <option value="EXP"  {if $editing && $editing.event_icon == 'EXP'}selected{/if}>EXP → 🧭</option>
                    <option value="RES"  {if $editing && $editing.event_icon == 'RES'}selected{/if}>RES → 💰</option>
                    <option value="SHIP" {if $editing && $editing.event_icon == 'SHIP'}selected{/if}>SHIP → 🚀</option>
                    <option value="TEC"  {if $editing && $editing.event_icon == 'TEC'}selected{/if}>TEC → 🔬</option>
                    <option value="ELT"  {if $editing && $editing.event_icon == 'ELT'}selected{/if}>ELT → 👑</option>
                </select>
            </div>
            <div class="eva_field">
                <label>Color</label>
                <input type="text" name="event_color" value="{if $editing}{$editing.event_color}{else}#00ccff{/if}" placeholder="#00ccff">
            </div>
        </div>

        <div class="eva_form_row full">
            <div class="eva_field">
                <label>Descripción</label>
                <textarea name="event_desc" maxlength="500" required>{if $editing}{$editing.event_desc}{/if}</textarea>
            </div>
        </div>

        <div class="eva_form_row">
            <div class="eva_field">
                <label>Tipo de evento</label>
                <select name="event_type" id="event_type_select">
                    {foreach $eventTypes as $key => $label}
                        <option value="{$key}" {if $editing && $editing.event_type == $key}selected{/if}>{$label}</option>
                    {/foreach}
                </select>
            </div>
            <div class="eva_field">
                <label>Objetivo (cantidad)</label>
                <input type="number" name="event_target_value" value="{if $editing}{$editing.event_target_value}{/if}" min="1" required>
                <span class="hint">Cuántas unidades/acciones debe hacer el jugador</span>
            </div>
            <div class="eva_field">
                <label>Clase</label>
                <select name="event_class">
                    {foreach $eventClasses as $key => $label}
                        <option value="{$key}" {if $editing && $editing.event_class == $key}selected{/if}>{$label}</option>
                    {/foreach}
                </select>
            </div>
        </div>

        {* ============ NUEVO CAMPO: OBJETIVO ESPECÍFICO ============ *}
        <div class="eva_form_row full" id="ref_field_container" style="display: none;">
            <div class="eva_field">
                <label>Objetivo Específico (ID - Nombre)</label>
                <select name="event_target_ref" id="event_target_ref">
                    <option value="0" {if $editing && $editing.event_target_ref == 0}selected{/if}>0 - Cualquiera (Global)</option>
                    
                    <optgroup label="Naves">
                        <option value="202" {if $editing && $editing.event_target_ref == 202}selected{/if}>202 - Nave de carga pequeña</option>
                        <option value="203" {if $editing && $editing.event_target_ref == 203}selected{/if}>203 - Nave de carga grande</option>
                        <option value="204" {if $editing && $editing.event_target_ref == 204}selected{/if}>204 - Nave de carga pesada</option>
                        <option value="205" {if $editing && $editing.event_target_ref == 205}selected{/if}>205 - Explorador</option>
                        <option value="206" {if $editing && $editing.event_target_ref == 206}selected{/if}>206 - Cazador ligero</option>
                        <option value="207" {if $editing && $editing.event_target_ref == 207}selected{/if}>207 - Cazador pesado</option>
                        <option value="208" {if $editing && $editing.event_target_ref == 208}selected{/if}>208 - Crucero</option>
                        <option value="209" {if $editing && $editing.event_target_ref == 209}selected{/if}>209 - Reciclador</option>
                        <option value="210" {if $editing && $editing.event_target_ref == 210}selected{/if}>210 - Sonda de espionaje</option>
                        <option value="211" {if $editing && $editing.event_target_ref == 211}selected{/if}>211 - Bombardero</option>
                        <option value="212" {if $editing && $editing.event_target_ref == 212}selected{/if}>212 - Destructor</option>
                        <option value="213" {if $editing && $editing.event_target_ref == 213}selected{/if}>213 - Estrella de la muerte</option>
                        <option value="214" {if $editing && $editing.event_target_ref == 214}selected{/if}>214 - Acorazado</option>
                        <option value="215" {if $editing && $editing.event_target_ref == 215}selected{/if}>215 - Supernova</option>
                        <option value="219" {if $editing && $editing.event_target_ref == 219}selected{/if}>219 - Reciclador gigante</option>
                    </optgroup>

                    <optgroup label="Tecnologías">
                        <option value="115" {if $editing && $editing.event_target_ref == 115}selected{/if}>115 - Tecnología láser</option>
                        <option value="116" {if $editing && $editing.event_target_ref == 116}selected{/if}>116 - Tecnología iónica</option>
                        <option value="117" {if $editing && $editing.event_target_ref == 117}selected{/if}>117 - Tecnología de plasma</option>
                        <option value="118" {if $editing && $editing.event_target_ref == 118}selected{/if}>118 - Tecnología de espionaje</option>
                        <option value="120" {if $editing && $editing.event_target_ref == 120}selected{/if}>120 - Tecnología de blindaje</option>
                        <option value="121" {if $editing && $editing.event_target_ref == 121}selected{/if}>121 - Tecnología de armas</option>
                    </optgroup>
                </select>
                <span class="hint">Elige la nave/tech exacta. Si es un evento global, déjalo en "Cualquiera".</span>
            </div>
        </div>
        {* ========================================================== *}

        <div class="eva_form_row">
            <div class="eva_field">
                <label>Tipo de recompensa</label>
                <select name="reward_type">
                    {foreach $rewardTypes as $key => $label}
                        <option value="{$key}" {if $editing && $editing.reward_type == $key}selected{/if}>{$label}</option>
                    {/foreach}
                </select>
            </div>
            <div class="eva_field">
                <label>Valor de recompensa</label>
                <input type="number" name="reward_value" value="{if $editing}{$editing.reward_value}{/if}" min="1" required>
            </div>
            <div class="eva_field">
                <label>Activo</label>
                <select name="active">
                    <option value="1" {if !$editing || $editing.active == 1}selected{/if}>✅ Sí</option>
                    <option value="0" {if $editing && $editing.active == 0}selected{/if}>❌ No</option>
                </select>
            </div>
        </div>

        <div class="eva_actions_row">
            {if $editing}
                <a href="admin.php?page=events" class="eva_btn small">✖ Cancelar edición</a>
                <button type="submit" class="eva_btn primary">💾 Guardar cambios</button>
            {else}
                <button type="submit" class="eva_btn success">➕ Crear evento</button>
            {/if}
        </div>

    </form>

    {* ============ LISTA DE EVENTOS ============ *}
    <div class="eva_section_title">📋 Eventos ({count($events)})</div>

    <div class="eva_table_wrap">
        <table class="eva_table">
            <thead>
                <tr>
                    <th></th>
                    <th>Nombre</th>
                    <th>Clase</th>
                    <th>Tipo</th>
                    <th>Objetivo</th>
                    <th>Obj. Específico</th>
                    <th>Recompensa</th>
                    <th>Estadísticas</th>
                    <th>Activo</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                {foreach $events as $e}
                <tr class="{if $e.active == 0}inactive{/if}">
                    <td class="eva_icon_cell" style="color:{$e.event_color};">{$e.icon_emoji}</td>
                    <td>
                        <div class="eva_name">{$e.event_name}</div>
                        <div class="eva_desc">{$e.event_desc}</div>
                    </td>
                    <td><span class="eva_badge {$e.event_class}">{$e.event_class}</span></td>
                    <td>{$e.event_type}</td>
                    <td>{$e.event_target_value|number_format:0:',':'.'}</td>
                    <td>
                        {if $e.event_target_ref > 0}
                            <span style="color: var(--accent-gold); font-weight: bold;">ID: {$e.event_target_ref}</span>
                        {else}
                            <span style="color: var(--text-muted); font-style: italic;">Global</span>
                        {/if}
                    </td>
                    <td>{$e.reward_value|number_format:0:',':'.'} {$e.reward_type}</td>
                    <td class="eva_stats">
                        Iniciado: {$e.stats.started}<br>
                        Reclamado: {$e.stats.claimed}
                    </td>
                    <td>
                        {if $e.active == 1}<span class="eva_active_y">✅</span>{else}<span class="eva_active_n">❌</span>{/if}
                    </td>
                    <td>
                        <div class="eva_row_actions">
                            <a href="admin.php?page=events&edit={$e.event_id}" class="eva_btn small primary" title="Editar">✏️</a>
                            
                            <form method="post" action="admin.php?page=events" style="display:inline;" onsubmit="return confirm('¿Cambiar estado?');">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="event_id" value="{$e.event_id}">
                                <button type="submit" class="eva_btn small warning" title="Activar/Desactivar">🔄</button>
                            </form>
                            
                            <form method="post" action="admin.php?page=events" style="display:inline;" onsubmit="return confirm('¿Resetear progreso de TODOS los jugadores para este evento?');">
                                <input type="hidden" name="action" value="reset_progress">
                                <input type="hidden" name="event_id" value="{$e.event_id}">
                                <button type="submit" class="eva_btn small warning" title="Resetear progreso">♻️</button>
                            </form>
                            
                            <form method="post" action="admin.php?page=events" style="display:inline;" onsubmit="return confirm('¿BORRAR este evento? Se borrarán también los progresos de los jugadores.');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="event_id" value="{$e.event_id}">
                                <button type="submit" class="eva_btn small danger" title="Borrar">🗑️</button>
                            </form>
                        </div>
                    </td>
                </tr>
                {foreachelse}
                <tr>
                    <td colspan="10" style="text-align:center; padding: 20px; color: var(--text-muted); font-style: italic;">
                        No hay eventos creados todavía.
                    </td>
                </tr>
                {/foreach}
            </tbody>
        </table>
    </div>

</div>

{* ============ JAVASCRIPT PARA MOSTRAR/OCULTAR EL SELECTOR ============ *}
<script>
document.addEventListener("DOMContentLoaded", function() {
    var typeSelect = document.getElementById('event_type_select');
    var refContainer = document.getElementById('ref_field_container');

    function toggleRefField() {
        var type = typeSelect.value;
        // Mostrar solo si el evento es de naves o tecnologías
        if (type === 'destroy_units' || type === 'build_ships' || type === 'research_techs') {
            refContainer.style.display = 'grid'; // Grid para que respete el diseño
        } else {
            refContainer.style.display = 'none';
        }
    }

    // Escuchar cambios y ejecutar al cargar
    typeSelect.addEventListener('change', toggleRefField);
    toggleRefField();
});
</script>

{include file="overall_footer.tpl"}