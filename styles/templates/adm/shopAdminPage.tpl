{include file="overall_header.tpl"}

<style>
/* ============================================================
   ASTROIO - ADMIN TIENDA NTX-20
   Prefijo CSS: .astroshopadmin_
   v1.5 - Cofres climáticos añadidos
   ============================================================ */

.astroshopadmin_wrap {
    max-width: 1200px;
    margin: 0 auto;
    padding: 10px;
    font-family: 'Segoe UI', Roboto, sans-serif;
    color: #c8d6e5;
    font-size: 12px;
}

/* ===== HEADER ===== */
.astroshopadmin_header {
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 14px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 10px;
}

.astroshopadmin_title {
    font-size: 18px;
    font-weight: 700;
    color: #ffdd88;
    text-shadow: 0 0 12px rgba(255, 200, 0, 0.5);
    letter-spacing: 1px;
}

.astroshopadmin_subtitle {
    color: #8aa0b5;
    font-size: 11px;
    margin-top: 3px;
}

/* ===== MENSAJES ===== */
.astroshopadmin_msg {
    padding: 10px 14px;
    border-radius: 8px;
    margin-bottom: 14px;
    font-weight: 600;
    font-size: 12px;
    border-left: 4px solid;
}

.astroshopadmin_msg.success {
    background: rgba(0, 200, 100, 0.12);
    border-color: #00ff88;
    color: #88ffbb;
}

.astroshopadmin_msg.error {
    background: rgba(255, 68, 136, 0.12);
    border-color: #ff4488;
    color: #ff99bb;
}

.astroshopadmin_msg.info {
    background: rgba(0, 200, 255, 0.12);
    border-color: #00ccff;
    color: #88ddff;
}

/* ===== PESTAÑAS ===== */
.astroshopadmin_tabs {
    display: flex;
    gap: 6px;
    margin-bottom: 14px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.15);
    padding-bottom: 6px;
    flex-wrap: wrap;
}

.astroshopadmin_tab {
    padding: 8px 18px;
    border-radius: 8px 8px 0 0;
    background: rgba(0, 0, 0, 0.3);
    color: #8aa0b5;
    font-weight: 700;
    font-size: 12px;
    text-decoration: none;
    border: 1px solid transparent;
    border-bottom: none;
    transition: all 0.25s ease;
    cursor: pointer;
}

.astroshopadmin_tab:hover {
    color: #00e0ff;
    background: rgba(0, 200, 255, 0.1);
}

.astroshopadmin_tab.active {
    background: linear-gradient(135deg, #004488, #0077cc);
    color: #fff;
    border-color: #00ccff;
    box-shadow: 0 -2px 8px rgba(0, 204, 255, 0.3);
}

/* ===== PANEL ===== */
.astroshopadmin_panel {
    background: linear-gradient(135deg, #0f1624, #1a2332);
    border: 1px solid rgba(0, 204, 255, 0.2);
    border-radius: 10px;
    padding: 16px;
    margin-bottom: 14px;
}

.astroshopadmin_panel_title {
    color: #00e0ff;
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 8px;
    margin-bottom: 12px;
}

/* ===== FORMULARIO ===== */
.astroshopadmin_form {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}

.astroshopadmin_form .full {
    grid-column: 1 / -1;
}

.astroshopadmin_field {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.astroshopadmin_field label {
    color: #8aa0b5;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.astroshopadmin_field input[type="text"],
.astroshopadmin_field input[type="number"],
.astroshopadmin_field select,
.astroshopadmin_field textarea {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 6px;
    color: #00e0ff;
    padding: 8px 10px;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    transition: all 0.25s ease;
}

.astroshopadmin_field input:focus,
.astroshopadmin_field select:focus,
.astroshopadmin_field textarea:focus {
    outline: none;
    border-color: #00e0ff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
}

.astroshopadmin_field textarea {
    resize: vertical;
    min-height: 60px;
}

.astroshopadmin_field input[type="checkbox"] {
    width: auto;
    margin-right: 6px;
    accent-color: #00ccff;
}

.astroshopadmin_checkbox_row {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 6px 0;
}

.astroshopadmin_checkbox_row label {
    color: #c8d6e5;
    font-size: 12px;
    text-transform: none;
    letter-spacing: 0;
    cursor: pointer;
}

/* ===== HINT / HINT TEXT ===== */
.astroshopadmin_hint {
    color: #6a7a90;
    font-size: 10px;
    font-style: italic;
    margin-top: 2px;
}

/* ===== BOTONES ===== */
.astroshopadmin_btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
    border: 1px solid transparent;
    cursor: pointer;
    transition: all 0.25s ease;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astroshopadmin_btn.primary {
    background: linear-gradient(135deg, #0066cc, #0099ff);
    color: #fff;
    border-color: #00ccff;
}

.astroshopadmin_btn.primary:hover {
    background: linear-gradient(135deg, #0099ff, #00ccff);
    box-shadow: 0 0 14px rgba(0, 204, 255, 0.6);
    transform: translateY(-1px);
}

.astroshopadmin_btn.success {
    background: linear-gradient(135deg, #008844, #00cc66);
    color: #fff;
    border-color: #00ff88;
}

.astroshopadmin_btn.success:hover {
    background: linear-gradient(135deg, #00cc66, #00ff88);
    box-shadow: 0 0 14px rgba(0, 255, 136, 0.6);
    transform: translateY(-1px);
}

.astroshopadmin_btn.danger {
    background: linear-gradient(135deg, #aa0044, #cc2266);
    color: #fff;
    border-color: #ff4488;
}

.astroshopadmin_btn.danger:hover {
    background: linear-gradient(135deg, #cc2266, #ff4488);
    box-shadow: 0 0 14px rgba(255, 68, 136, 0.6);
    transform: translateY(-1px);
}

.astroshopadmin_btn.warning {
    background: linear-gradient(135deg, #aa6600, #cc8800);
    color: #fff;
    border-color: #ffaa33;
}

.astroshopadmin_btn.warning:hover {
    background: linear-gradient(135deg, #cc8800, #ffaa33);
    box-shadow: 0 0 14px rgba(255, 170, 51, 0.6);
    transform: translateY(-1px);
}

.astroshopadmin_btn.small {
    padding: 5px 10px;
    font-size: 11px;
}

/* ===== TABLA ===== */
.astroshopadmin_table {
    width: 100%;
    border-collapse: collapse;
    font-size: 11px;
    table-layout: fixed;
}

.astroshopadmin_table th {
    background: linear-gradient(135deg, #004488, #0077cc);
    color: #fff;
    padding: 8px 6px;
    text-align: left;
    font-weight: 700;
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    border-bottom: 1px solid #00ccff;
}

.astroshopadmin_table td {
    padding: 8px 6px;
    border-bottom: 1px solid rgba(0, 204, 255, 0.1);
    color: #c8d6e5;
    word-wrap: break-word;
    overflow: hidden;
    text-overflow: ellipsis;
    vertical-align: middle;
}

.astroshopadmin_table tr:hover td {
    background: rgba(0, 204, 255, 0.05);
}

.astroshopadmin_table tr.inactive td {
    opacity: 0.5;
    background: rgba(0, 0, 0, 0.15);
}

.astroshopadmin_badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}

.astroshopadmin_badge.tipo-recurso         { background: rgba(255, 170, 51, 0.2);  color: #ffcc66; border: 1px solid rgba(255, 170, 51, 0.5); }
.astroshopadmin_badge.tipo-nave            { background: rgba(0, 204, 255, 0.2);   color: #66ddff; border: 1px solid rgba(0, 204, 255, 0.5); }
.astroshopadmin_badge.tipo-defensa         { background: rgba(102, 255, 153, 0.2); color: #88ffbb; border: 1px solid rgba(102, 255, 153, 0.5); }
.astroshopadmin_badge.tipo-misil           { background: rgba(255, 100, 100, 0.2); color: #ff8888; border: 1px solid rgba(255, 100, 100, 0.5); }
.astroshopadmin_badge.tipo-cofre_common    { background: rgba(0, 204, 255, 0.2);   color: #66ddff; border: 1px solid rgba(0, 204, 255, 0.5); }
.astroshopadmin_badge.tipo-cofre_rare      { background: rgba(170, 68, 255, 0.2);  color: #cc88ff; border: 1px solid rgba(170, 68, 255, 0.5); }
.astroshopadmin_badge.tipo-cofre_legendary { background: rgba(255, 200, 0, 0.25);  color: #ffee88; border: 1px solid rgba(255, 220, 50, 0.6); }
.astroshopadmin_badge.tipo-cofre           { background: rgba(170, 68, 255, 0.2);  color: #cc88ff; border: 1px solid rgba(170, 68, 255, 0.5); }
.astroshopadmin_badge.tipo-booster         { background: rgba(255, 221, 51, 0.2);  color: #ffee88; border: 1px solid rgba(255, 221, 51, 0.5); }

/* 🆕 v1.5 - Cofres climáticos */
.astroshopadmin_badge.tipo-cofre_climate_minor    { background: rgba(74, 255, 136, 0.15);  color: #88ffbb; border: 1px solid rgba(74, 255, 136, 0.5); }
.astroshopadmin_badge.tipo-cofre_climate_major    { background: rgba(0, 224, 255, 0.15);   color: #66ddff; border: 1px solid rgba(0, 224, 255, 0.5); }
.astroshopadmin_badge.tipo-cofre_climate_dominion { background: rgba(139, 92, 246, 0.15);  color: #cc88ff; border: 1px solid rgba(139, 92, 246, 0.5); }

.astroshopadmin_badge.active   { background: rgba(0, 255, 136, 0.2); color: #88ffbb; border: 1px solid rgba(0, 255, 136, 0.5); }
.astroshopadmin_badge.inactive { background: rgba(120, 120, 120, 0.2); color: #99aabb; border: 1px solid rgba(120, 120, 120, 0.5); }
.astroshopadmin_badge.popular  { background: rgba(255, 200, 0, 0.25); color: #ffee88; border: 1px solid rgba(255, 220, 50, 0.6); }

/* ===== BADGES DE TEMPORAL / URGENCIA ===== */
.astroshopadmin_badge.temporal-far    { background: rgba(0, 200, 100, 0.2); color: #88ffbb; border: 1px solid rgba(0, 255, 136, 0.5); }
.astroshopadmin_badge.temporal-soon   { background: rgba(255, 200, 0, 0.2); color: #ffee88; border: 1px solid rgba(255, 220, 50, 0.6); }
.astroshopadmin_badge.temporal-urgent { background: rgba(255, 50, 50, 0.25); color: #ffbbbb; border: 1px solid rgba(255, 80, 80, 0.7); animation: astroshopadmin_pulse_red 1s infinite; }
.astroshopadmin_badge.temporal-expired{ background: rgba(120, 120, 120, 0.2); color: #999; border: 1px solid rgba(120, 120, 120, 0.5); text-decoration: line-through; }
.astroshopadmin_badge.temporal-permanent { background: rgba(120, 120, 120, 0.12); color: #8aa0b5; border: 1px solid rgba(120, 120, 120, 0.3); }

@keyframes astroshopadmin_pulse_red {
    0%, 100% { box-shadow: 0 0 6px rgba(255, 50, 50, 0.5); }
    50%      { box-shadow: 0 0 14px rgba(255, 50, 50, 0.9); }
}

.astroshopadmin_expira_fecha {
    display: block;
    font-size: 9px;
    color: #6a7a90;
    margin-top: 3px;
    font-family: 'Courier New', monospace;
}

.astroshopadmin_actions {
    display: flex;
    gap: 4px;
    flex-wrap: wrap;
}

/* ===== ESTADO VACÍO ===== */
.astroshopadmin_empty {
    text-align: center;
    padding: 40px 20px;
    color: #8aa0b5;
}

.astroshopadmin_empty_icon {
    font-size: 48px;
    margin-bottom: 12px;
    filter: grayscale(50%);
    opacity: 0.6;
}

.astroshopadmin_empty_title {
    color: #00e0ff;
    font-size: 15px;
    font-weight: 700;
    margin-bottom: 6px;
}

.astroshopadmin_empty_text {
    color: #6a7a90;
    font-size: 12px;
    line-height: 1.6;
}

/* ===== TARJETAS DE PLANTILLA ===== */
.astroshopadmin_tpl_grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 12px;
}

.astroshopadmin_tpl_card {
    background: linear-gradient(135deg, #0f1624, #1a2332);
    border: 1px solid rgba(0, 204, 255, 0.25);
    border-radius: 10px;
    padding: 12px 14px;
    transition: all 0.25s ease;
}

.astroshopadmin_tpl_card:hover {
    border-color: #00e0ff;
    box-shadow: 0 4px 16px rgba(0, 224, 255, 0.3);
    transform: translateY(-2px);
}

.astroshopadmin_tpl_name {
    font-size: 13px;
    font-weight: 700;
    color: #00e0ff;
    margin-bottom: 4px;
}

.astroshopadmin_tpl_desc {
    font-size: 11px;
    color: #8aa0b5;
    margin-bottom: 8px;
    line-height: 1.4;
}

.astroshopadmin_tpl_meta {
    font-size: 10px;
    color: #6a7a90;
    font-family: 'Courier New', monospace;
    margin-bottom: 10px;
    padding-top: 8px;
    border-top: 1px solid rgba(0, 204, 255, 0.1);
}

.astroshopadmin_tpl_actions {
    display: flex;
    gap: 6px;
    flex-wrap: wrap;
}

/* ===== AUTO-SNAPSHOT INFO ===== */
.astroshopadmin_autosave {
    background: rgba(255, 170, 51, 0.08);
    border: 1px solid rgba(255, 170, 51, 0.4);
    border-radius: 8px;
    padding: 10px 14px;
    margin-bottom: 14px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 10px;
}

.astroshopadmin_autosave_info {
    font-size: 11px;
    color: #ffcc66;
}

.astroshopadmin_autosave_info strong {
    color: #ffee88;
}

/* ===== RESPONSIVE ===== */
@media (max-width: 900px) {
    .astroshopadmin_form {
        grid-template-columns: 1fr;
    }
    .astroshopadmin_table {
        font-size: 10px;
    }
    .astroshopadmin_table th,
    .astroshopadmin_table td {
        padding: 5px 3px;
    }
}
</style>

<div class="astroshopadmin_wrap">

    {* ===== HEADER ===== *}
    <div class="astroshopadmin_header">
        <div>
            <div class="astroshopadmin_title">🛒 ADMIN — TIENDA NTX-20</div>
            <div class="astroshopadmin_subtitle">Gestiona ofertas, plantillas e historial de compras</div>
        </div>
        <div>
            <a href="admin.php" class="astroshopadmin_btn small">← Volver al panel</a>
        </div>
    </div>

    {* ===== MENSAJES ===== *}
    {if $message}
        <div class="astroshopadmin_msg {$msgType}">{$message}</div>
    {/if}

    {* ===== AUTO-SNAPSHOT (ROLLBACK) ===== *}
    {if $has_auto}
        <div class="astroshopadmin_autosave">
            <div class="astroshopadmin_autosave_info">
                🔄 <strong>Último auto-snapshot:</strong> {$last_auto_accion} — {$last_auto_fecha}
            </div>
            <a href="admin.php?page=shopadmin&mode=rollback&tab=offers"
               class="astroshopadmin_btn warning small"
               onclick="return confirm('¿Seguro que quieres deshacer el último cambio?');">
                ↩️ Deshacer último cambio
            </a>
        </div>
    {/if}

    {* ===== PESTAÑAS ===== *}
    <div class="astroshopadmin_tabs">
        <a href="admin.php?page=shopadmin&tab=offers" class="astroshopadmin_tab {if $tab == 'offers'}active{/if}">
            📦 Ofertas ({$offers_count})
        </a>
        <a href="admin.php?page=shopadmin&tab=templates" class="astroshopadmin_tab {if $tab == 'templates'}active{/if}">
            💾 Plantillas ({$templates_count})
        </a>
        <a href="admin.php?page=shopadmin&tab=history" class="astroshopadmin_tab {if $tab == 'history'}active{/if}">
            📜 Historial
        </a>
    </div>

    {* ============================================================ *}
    {* PESTAÑA: OFERTAS *}
    {* ============================================================ *}
    {if $tab == 'offers'}

        {* ===== FORMULARIO (NUEVA / EDITAR OFERTA) ===== *}
        <div class="astroshopadmin_panel">
            <div class="astroshopadmin_panel_title">
                {if $is_editing}
                    ✏️ Editar Oferta #{$edit_offer.id}
                {else}
                    ➕ Crear Nueva Oferta
                {/if}
            </div>

            <!-- FIX: accept-charset="UTF-8" agregado aquí -->
            <form method="post" action="admin.php?page=shopadmin" accept-charset="UTF-8">
                <input type="hidden" name="mode" value="{if $is_editing}update{else}create{/if}">
                {if $is_editing}
                    <input type="hidden" name="id" value="{$edit_offer.id}">
                {/if}

                <div class="astroshopadmin_form">

                    <div class="astroshopadmin_field">
                        <label>Nombre de la oferta *</label>
                        <input type="text" name="nombre" required maxlength="150"
                               value="{if $is_editing}{$edit_offer.nombre}{/if}"
                               placeholder="Ej: Titán Estelar">
                    </div>

                    <div class="astroshopadmin_field">
                        <label>Tipo *</label>
                        <select name="tipo" id="shop_tipo" required onchange="shopAdminChangeTipo()">
                            <option value="recurso"  {if $is_editing && $edit_offer.tipo == 'recurso'}selected{/if}>💰 Recurso</option>
                            <option value="nave"     {if $is_editing && $edit_offer.tipo == 'nave'}selected{/if}>🚀 Nave</option>
                            <option value="defensa"  {if $is_editing && $edit_offer.tipo == 'defensa'}selected{/if}>🛡️ Defensa</option>
                            <option value="misil"    {if $is_editing && $edit_offer.tipo == 'misil'}selected{/if}>🎯 Misil</option>
                            <option value="cofre_common"    {if $is_editing && $edit_offer.tipo == 'cofre_common'}selected{/if}>📦 Cofre Común</option>
                            <option value="cofre_rare"      {if $is_editing && $edit_offer.tipo == 'cofre_rare'}selected{/if}>💎 Cofre Raro</option>
                            <option value="cofre_legendary" {if $is_editing && $edit_offer.tipo == 'cofre_legendary'}selected{/if}>👑 Cofre Legendario</option>
                            {* 🆕 v1.5 - Cofres climáticos *}
                            <option value="cofre_climate_minor"    {if $is_editing && $edit_offer.tipo == 'cofre_climate_minor'}selected{/if}>🌤️ Cofre Climático Menor</option>
                            <option value="cofre_climate_major"    {if $is_editing && $edit_offer.tipo == 'cofre_climate_major'}selected{/if}>🌈 Cofre Climático Mayor</option>
                            <option value="cofre_climate_dominion" {if $is_editing && $edit_offer.tipo == 'cofre_climate_dominion'}selected{/if}>⚡ Cofre Climático Legendario</option>
                            <option value="booster"  {if $is_editing && $edit_offer.tipo == 'booster'}selected{/if}>⚡ Potenciador</option>
                        </select>
                    </div>

                    <div class="astroshopadmin_field full">
                        <label>Producto</label>
                        <select name="item_id" id="shop_item_id">
                            {* Se rellena con JS según el tipo *}
                        </select>
                    </div>

                    <div class="astroshopadmin_field">
                        <label>Cantidad a entregar *</label>
                        <input type="number" name="cantidad" min="1" required
                               value="{if $is_editing}{$edit_offer.cantidad}{else}1{/if}">
                    </div>

                    <div class="astroshopadmin_field">
                        <label>Precio (NTX-20) *</label>
                        <input type="number" name="precio_ntx" min="0" required
                               value="{if $is_editing}{$edit_offer.precio_ntx}{else}0{/if}">
                    </div>

                    <div class="astroshopadmin_field">
                        <label>Icono (opcional)</label>
                        <input type="text" name="icono" maxlength="20"
                               value="{if $is_editing}{$edit_offer.icono}{/if}"
                               placeholder="Ej: 🚀 o vacío para auto">
                    </div>

                    <div class="astroshopadmin_field">
                        <label>Orden</label>
                        <input type="number" name="orden"
                               value="{if $is_editing}{$edit_offer.orden}{else}0{/if}">
                    </div>

                    <div class="astroshopadmin_field full">
                        <label>Descripción (opcional)</label>
                        <textarea name="descripcion" maxlength="255"
                                  placeholder="Ej: Nave de élite con ataque devastador">{if $is_editing}{$edit_offer.descripcion}{/if}</textarea>
                    </div>

                    {* ===== DURACIÓN ===== *}
                    <div class="astroshopadmin_field full">
                        <label>⏰ Duración de la oferta</label>
                        <select name="duracion">
                            {foreach $duraciones_disponibles as $dur => $durLabel}
                                <option value="{$dur}"
                                        {if $is_editing && $edit_offer.duracion_dias == $dur}selected{/if}
                                        {if !$is_editing && $dur == 0}selected{/if}>
                                    {$durLabel}
                                </option>
                            {/foreach}
                        </select>
                        <small class="astroshopadmin_hint">
                            Si eliges una duración temporal, la oferta se elimina automáticamente al expirar.
                            {if $is_editing && $edit_offer.expira_en > 0}
                                <br>Expira el: <strong>{$edit_offer.expira_fmt}</strong>
                            {/if}
                        </small>
                    </div>

                    <div class="astroshopadmin_field">
                        <div class="astroshopadmin_checkbox_row">
                            <input type="checkbox" name="popular" value="1" id="shop_popular"
                                   {if $is_editing && $edit_offer.popular}checked{/if}>
                            <label for="shop_popular">⭐ Marcar como POPULAR</label>
                        </div>
                    </div>

                    <div class="astroshopadmin_field">
                        <div class="astroshopadmin_checkbox_row">
                            <input type="checkbox" name="activo" value="1" id="shop_activo"
                                   {if !$is_editing || $edit_offer.activo}checked{/if}>
                            <label for="shop_activo">✅ Oferta activa (visible al jugador)</label>
                        </div>
                    </div>

                    <div class="astroshopadmin_field full" style="flex-direction: row; gap: 10px; margin-top: 6px;">
                        <button type="submit" class="astroshopadmin_btn success">
                            {if $is_editing}💾 Guardar cambios{else}➕ Crear oferta{/if}
                        </button>
                        {if $is_editing}
                            <a href="admin.php?page=shopadmin&tab=offers" class="astroshopadmin_btn">❌ Cancelar</a>
                        {/if}
                    </div>

                </div>
            </form>
        </div>

        {* ===== TABLA DE OFERTAS ===== *}
        <div class="astroshopadmin_panel">
            <div class="astroshopadmin_panel_title">📋 Ofertas Existentes ({$offers_count})</div>

            {if $offers_count == 0}
                <div class="astroshopadmin_empty">
                    <div class="astroshopadmin_empty_icon">🛒</div>
                    <div class="astroshopadmin_empty_title">No hay ofertas creadas</div>
                    <div class="astroshopadmin_empty_text">
                        Usa el formulario de arriba para crear la primera oferta.<br>
                        Recuerda: las ofertas no expiran y todos los jugadores pueden comprarlas mientras estén activas.
                    </div>
                </div>
            {else}
                <table class="astroshopadmin_table">
                    <thead>
                        <tr>
                            <th style="width:40px;">ID</th>
                            <th>Nombre</th>
                            <th style="width:80px;">Tipo</th>
                            <th style="width:110px;">Producto</th>
                            <th style="width:55px;">Cant.</th>
                            <th style="width:80px;">Precio</th>
                            <th style="width:70px;">Estado</th>
                            <th style="width:130px;">⏰ Expira</th>
                            <th style="width:180px;">Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $offers as $o}
                            <tr class="{if !$o.activo}inactive{/if}">
                                <td>#{$o.id}</td>
                                <td>
                                    {if $o.popular}<span class="astroshopadmin_badge popular">⭐ POPULAR</span> {/if}
                                    {$o.nombre}
                                </td>
                                <td>
                                    <span class="astroshopadmin_badge tipo-{$o.tipo}">
                                        {$o.tipo_icon} {$o.tipo_label}
                                    </span>
                                </td>
                                <td>{$o.item_name}</td>
                                <td>{$o.cantidad}</td>
                                <td><strong style="color:#ffdd88;">{$o.precio_ntx} NTX</strong></td>
                                <td>
                                    {if $o.activo}
                                        <span class="astroshopadmin_badge active">✅ Activa</span>
                                    {else}
                                        <span class="astroshopadmin_badge inactive">⏸️ Inactiva</span>
                                    {/if}
                                </td>
                                <td>
                                    {if $o.es_temporal}
                                        <span class="astroshopadmin_badge temporal-{$o.urgencia}">
                                            {$o.tiempo_restante_txt}
                                        </span>
                                        <span class="astroshopadmin_expira_fecha">{$o.expira_fmt}</span>
                                    {else}
                                        <span class="astroshopadmin_badge temporal-permanent">— Permanente</span>
                                    {/if}
                                </td>
                                <td>
                                    <div class="astroshopadmin_actions">
                                        <a href="admin.php?page=shopadmin&tab=offers&mode=edit&id={$o.id}"
                                           class="astroshopadmin_btn small primary">✏️ Editar</a>

                                        <a href="admin.php?page=shopadmin&mode=toggle&id={$o.id}&tab=offers"
                                           class="astroshopadmin_btn small warning">
                                            {if $o.activo}⏸️{else}▶️{/if}
                                        </a>

                                        <a href="admin.php?page=shopadmin&mode=delete&id={$o.id}&tab=offers"
                                           class="astroshopadmin_btn small danger"
                                           onclick="return confirm('¿Seguro que quieres borrar la oferta «{$o.nombre}»?');">
                                            🗑️
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {/if}
        </div>

    {* ============================================================ *}
    {* PESTAÑA: PLANTILLAS *}
    {* ============================================================ *}
    {elseif $tab == 'templates'}

        {* ===== GUARDAR NUEVA PLANTILLA ===== *}
        <div class="astroshopadmin_panel">
            <div class="astroshopadmin_panel_title">💾 Guardar Configuración Actual como Plantilla</div>

            <!-- FIX: accept-charset="UTF-8" agregado aquí -->
            <form method="post" action="admin.php?page=shopadmin&tab=templates" accept-charset="UTF-8">
                <input type="hidden" name="mode" value="saveTemplate">

                <div class="astroshopadmin_form">
                    <div class="astroshopadmin_field">
                        <label>Nombre de la plantilla *</label>
                        <input type="text" name="template_nombre" required maxlength="100"
                               placeholder="Ej: Precios Normales">
                    </div>

                    <div class="astroshopadmin_field">
                        <label>Descripción (opcional)</label>
                        <input type="text" name="template_desc" maxlength="255"
                               placeholder="Ej: Configuración base sin eventos">
                    </div>

                    <div class="astroshopadmin_field full">
                        <button type="submit" class="astroshopadmin_btn success">
                            💾 Guardar plantilla
                        </button>
                    </div>
                </div>
            </form>
        </div>

        {* ===== LISTA DE PLANTILLAS ===== *}
        <div class="astroshopadmin_panel">
            <div class="astroshopadmin_panel_title">📚 Plantillas Guardadas ({$templates_count})</div>

            {if $templates_count == 0}
                <div class="astroshopadmin_empty">
                    <div class="astroshopadmin_empty_icon">💾</div>
                    <div class="astroshopadmin_empty_title">No hay plantillas guardadas</div>
                    <div class="astroshopadmin_empty_text">
                        Guarda la configuración actual como plantilla para poder restaurarla después.<br>
                        Útil para eventos temporales (Halloween, Navidad, etc.).
                    </div>
                </div>
            {else}
                <div class="astroshopadmin_tpl_grid">
                    {foreach $templates as $t}
                        <div class="astroshopadmin_tpl_card">
                            <div class="astroshopadmin_tpl_name">🟢 {$t.nombre}</div>
                            <div class="astroshopadmin_tpl_desc">{$t.descripcion|default:'Sin descripción'}</div>
                            <div class="astroshopadmin_tpl_meta">
                                📅 Creada: {$t.fecha_creacion_fmt}<br>
                                🔄 Actualizada: {$t.fecha_actualizacion_fmt}
                            </div>
                            <div class="astroshopadmin_tpl_actions">
                                <a href="admin.php?page=shopadmin&mode=loadTemplate&id={$t.id}&tab=templates"
                                   class="astroshopadmin_btn small primary"
                                   onclick="return confirm('¿Cargar «{$t.nombre}»? Esto SOBRESCRIBIRÁ todas las ofertas actuales. El historial de compras se conserva.');">
                                    📥 Cargar
                                </a>
                                <a href="admin.php?page=shopadmin&mode=deleteTemplate&id={$t.id}&tab=templates"
                                   class="astroshopadmin_btn small danger"
                                   onclick="return confirm('¿Borrar la plantilla «{$t.nombre}»?');">
                                    🗑️ Borrar
                                </a>
                            </div>
                        </div>
                    {/foreach}
                </div>
            {/if}
        </div>

    {* ============================================================ *}
    {* PESTAÑA: HISTORIAL *}
    {* ============================================================ *}
    {elseif $tab == 'history'}

        <div class="astroshopadmin_panel">
            <div class="astroshopadmin_panel_title">📜 Historial de Compras ({$history_count})</div>

            {if $history_count == 0}
                <div class="astroshopadmin_empty">
                    <div class="astroshopadmin_empty_icon">📜</div>
                    <div class="astroshopadmin_empty_title">No hay compras registradas</div>
                    <div class="astroshopadmin_empty_text">
                        Cuando los jugadores empiecen a comprar en la tienda, aquí verás el historial completo.
                    </div>
                </div>
            {else}
                <table class="astroshopadmin_table">
                    <thead>
                        <tr>
                            <th style="width:40px;">ID</th>
                            <th style="width:140px;">Jugador</th>
                            <th>Oferta</th>
                            <th style="width:90px;">Tipo</th>
                            <th style="width:70px;">Cant.</th>
                            <th style="width:90px;">Precio Base</th>
                            <th style="width:90px;">Precio Final</th>
                            <th style="width:60px;">VIP</th>
                            <th style="width:130px;">Fecha</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $history as $h}
                            <tr>
                                <td>#{$h.id}</td>
                                <td>
                                    <strong>{$h.username|default:'(eliminado)'}</strong>
                                    <span style="color:#6a7a90;font-size:10px;">(ID {$h.user_id})</span>
                                </td>
                                <td>{$h.item_nombre}</td>
                                <td>
                                    <span class="astroshopadmin_badge tipo-{$h.item_tipo}">
                                        {if $h.item_tipo == 'booster'}Potenciador{else}{$h.item_tipo|capitalize}{/if}
                                    </span>
                                </td>
                                <td>{$h.item_cantidad}</td>
                                <td>{$h.precio_base} NTX</td>
                                <td><strong style="color:#ffdd88;">{$h.precio_final} NTX</strong></td>
                                <td>
                                    {if $h.vip_aplicado}
                                        <span class="astroshopadmin_badge popular">⭐ VIP</span>
                                    {else}
                                        —
                                    {/if}
                                </td>
                                <td style="font-size:10px;color:#6a7a90;">{$h.fecha_fmt}</td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            {/if}
        </div>

    {/if}

</div>

{* ============================================================ *}
{* JS: desplegable dinámico del producto según el tipo *}
{* ============================================================ *}
<script type="text/javascript">
// Catálogos desde PHP
var SHOP_CATALOGS = {
    recurso: [
        { id: 1, name: 'Metal' },
        { id: 2, name: 'Cristal' },
        { id: 3, name: 'Deuterio' },
        { id: 0, name: 'Metal + Cristal + Deuterio' }
    ],
    nave:    [ {foreach $ships_catalog as $s} { id: {$s.id}, name: '{$s.name|escape:"javascript"}' },{/foreach} ],
    defensa: [ {foreach $defenses_catalog as $d} { id: {$d.id}, name: '{$d.name|escape:"javascript"}' },{/foreach} ],
    misil:   [ {foreach $missiles_catalog as $m} { id: {$m.id}, name: '{$m.name|escape:"javascript"}' },{/foreach} ],

    // 3 cofres nuevos del Mercado
    cofre_common:    [ { id: 0, name: 'Cofre Común' } ],
    cofre_rare:      [ { id: 0, name: 'Cofre Raro' } ],
    cofre_legendary: [ { id: 0, name: 'Cofre Legendario' } ],

    // 🆕 v1.5 - 3 cofres climáticos
    cofre_climate_minor:    [ { id: 0, name: 'Cofre Climático Menor' } ],
    cofre_climate_major:    [ { id: 0, name: 'Cofre Climático Mayor' } ],
    cofre_climate_dominion: [ { id: 0, name: 'Cofre Climático Legendario' } ],

    booster: [ {foreach $boosters_catalog as $b} { id: {$b.id}, name: '{$b.name|escape:"javascript"}' },{/foreach} ]
};

var SHOP_CURRENT_ITEM_ID = {if $is_editing}{$edit_offer.item_id}{else}0{/if};

function shopAdminChangeTipo() {
    var tipo = document.getElementById('shop_tipo').value;
    var sel  = document.getElementById('shop_item_id');

    // Limpiar
    sel.innerHTML = '';

    var list = SHOP_CATALOGS[tipo] || [];

    if (list.length === 0) {
        var opt = document.createElement('option');
        opt.value = 0;
        opt.textContent = '(sin productos disponibles)';
        sel.appendChild(opt);
        return;
    }

    // Rellenar
    for (var i = 0; i < list.length; i++) {
        var opt = document.createElement('option');
        opt.value = list[i].id;
        opt.textContent = list[i].name;
        if (SHOP_CURRENT_ITEM_ID && parseInt(SHOP_CURRENT_ITEM_ID) === parseInt(list[i].id)) {
            opt.selected = true;
        }
        sel.appendChild(opt);
    }
}

// Inicializar al cargar la página
(function() {
    var tipoSelect = document.getElementById('shop_tipo');
    if (tipoSelect) {
        tipoSelect.addEventListener('change', shopAdminChangeTipo);
        shopAdminChangeTipo();
    }
})();
</script>

{include file="overall_footer.tpl"}