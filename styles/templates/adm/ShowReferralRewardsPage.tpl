<style>
    /* Fondo oscuro para el iframe del admin */
    body {
        background-color: #0b101e !important;
        color: #cbd5e1 !important;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        padding: 20px;
        margin: 0;
    }
    
    /* Contenedor principal estilo tarjeta */
    .content {
        background: rgba(15, 23, 42, 0.75);
        backdrop-filter: blur(6px);
        -webkit-backdrop-filter: blur(6px);
        border: 1px solid #1e293b;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
        max-width: 1000px;
        margin: 0 auto;
    }

    h2 {
        color: #00e0ff;
        border-bottom: 1px solid #1e293b;
        padding-bottom: 10px;
        margin-top: 0;
    }

    h3 {
        color: #cbd5e1;
        margin-top: 20px;
    }

    /* Estilos de la tabla */
    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 20px;
    }
    
    th, td {
        padding: 10px;
        border-bottom: 1px solid #1e293b;
        color: #cbd5e1;
    }

    th {
        background: rgba(0, 0, 0, 0.3);
        color: #00e0ff;
        text-align: left;
    }

    tr:hover {
        background: rgba(255, 255, 255, 0.05);
    }

    /* Inputs y Selects */
    input[type="number"], 
    input[type="datetime-local"], 
    select {
        background: rgba(0, 0, 0, 0.35);
        border: 1px solid #1e293b;
        color: #fff;
        padding: 8px;
        border-radius: 6px;
        width: 100%;
        box-sizing: border-box;
    }

    input:focus, select:focus {
        border-color: #00e0ff;
        outline: none;
        box-shadow: 0 0 8px rgba(0, 224, 255, 0.3);
    }

    /* Botón Guardar */
    button[type="submit"] {
        background: linear-gradient(135deg, #0066cc, #0099ff) !important;
        color: #fff !important;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        font-weight: bold;
        cursor: pointer;
        transition: all 0.2s;
    }

    button[type="submit"]:hover {
        background: linear-gradient(135deg, #0099ff, #00ccff) !important;
        box-shadow: 0 0 14px rgba(0, 224, 255, 0.5);
    }

    /* Enlaces de acción */
    a {
        text-decoration: none;
        font-weight: bold;
    }
    
    a:hover {
        text-decoration: underline;
    }
</style>

<div class="content">
    <h2>Configuración de Recompensas por Referidos</h2>

    {if $msg == 'created'}
        <div style="background: #155724; color: #d4edda; padding: 10px; margin-bottom: 15px; border-radius: 5px; border: 1px solid #28a745;">
            Recompensa creada con éxito.
        </div>
    {elseif $msg == 'toggled'}
        <div style="background: #004085; color: #cce5ff; padding: 10px; margin-bottom: 15px; border-radius: 5px; border: 1px solid #007bff;">
            Estado de la recompensa actualizado.
        </div>
    {elseif $msg == 'deleted'}
        <div style="background: #721c24; color: #f8d7da; padding: 10px; margin-bottom: 15px; border-radius: 5px; border: 1px solid #dc3545;">
            Recompensa eliminada correctamente.
        </div>
    {/if}

    <h3>Crear Nueva Recompensa</h3>
    <form action="admin.php?page=referral_rewards&action=save" method="POST">
        <table>
            <tr>
                <td style="width: 40%;"><strong>Puntuación Global Requerida:</strong></td>
                <td><input type="number" name="points_required" value="1000" required></td>
            </tr>
            <tr>
                <td>Metal:</td>
                <td><input type="number" name="reward_metal" value="0" step="any"></td>
            </tr>
            <tr>
                <td>Cristal:</td>
                <td><input type="number" name="reward_crystal" value="0" step="any"></td>
            </tr>
            <tr>
                <td>Deuterio:</td>
                <td><input type="number" name="reward_deuterium" value="0" step="any"></td>
            </tr>
            <tr>
                <td>NTX-20:</td>
                <td><input type="number" name="reward_ntx20" value="0"></td>
            </tr>
            <tr>
                <td>Materia Oscura:</td>
                <td><input type="number" name="reward_darkmatter" value="0" step="any"></td>
            </tr>
            <tr>
                <td>Contenedor Genérico:</td>
                <td><input type="number" name="reward_cont_generic" value="0"></td>
            </tr>
            <tr>
                <td>Cofre Común:</td>
                <td><input type="number" name="reward_box_common" value="0"></td>
            </tr>
            <tr>
                <td>Cofre Raro:</td>
                <td><input type="number" name="reward_box_rare" value="0"></td>
            </tr>
            <tr>
                <td>Cofre Legendario:</td>
                <td><input type="number" name="reward_box_legendary" value="0"></td>
            </tr>
            <tr>
                <td><strong>Tipo de Recompensa:</strong></td>
                <td>
                    <select name="is_permanent">
                        <option value="1">Permanente</option>
                        <option value="0">Temporal</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Inicio (Si es temporal):</td>
                <td><input type="datetime-local" name="start_time"></td>
            </tr>
            <tr>
                <td>Fin (Si es temporal):</td>
                <td><input type="datetime-local" name="end_time"></td>
            </tr>
            <tr>
                <td colspan="2" style="text-align: center; padding-top: 20px;">
                    <button type="submit">Guardar Recompensa</button>
                </td>
            </tr>
        </table>
    </form>

    <hr style="margin: 40px 0; border-color: #1e293b;">

    <h3>Recompensas Creadas</h3>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Puntos Req.</th>
                <th>Recompensas</th>
                <th>Tipo</th>
                <th>Estado</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            {foreach $rewards as $r}
            <tr>
                <td>{$r.id}</td>
                <td>{$r.points_required}</td>
                <td>
                    {if $r.reward_metal > 0} Metal: {$r.reward_metal}<br>{/if}
                    {if $r.reward_crystal > 0} Cristal: {$r.reward_crystal}<br>{/if}
                    {if $r.reward_deuterium > 0} Deuterio: {$r.reward_deuterium}<br>{/if}
                    {if $r.reward_ntx20 > 0} NTX-20: {$r.reward_ntx20}<br>{/if}
                    {if $r.reward_darkmatter > 0} MO: {$r.reward_darkmatter}<br>{/if}
                    {if $r.reward_cont_generic > 0} Contenedor: {$r.reward_cont_generic}<br>{/if}
                    {if $r.reward_box_common > 0} Caja Común: {$r.reward_box_common}<br>{/if}
                    {if $r.reward_box_rare > 0} Caja Rara: {$r.reward_box_rare}<br>{/if}
                    {if $r.reward_box_legendary > 0} Caja Legendaria: {$r.reward_box_legendary}<br>{/if}
                    {if $r.reward_metal == 0 && $r.reward_crystal == 0 && $r.reward_deuterium == 0 && $r.reward_ntx20 == 0 && $r.reward_darkmatter == 0 && $r.reward_cont_generic == 0 && $r.reward_box_common == 0 && $r.reward_box_rare == 0 && $r.reward_box_legendary == 0}
                        <span style="color: #ef4444;">Sin recompensas configuradas</span>
                    {/if}
                </td>
                <td>
                    {if $r.is_permanent == 1} 
                        Permanente 
                    {else} 
                        Temporal<br>
                        <small style="color: #94a3b8;">({$r.start_date_str} al {$r.end_date_str})</small>
                    {/if}
                </td>
                <td>
                    {if $r.is_active == 1} 
                        <span style="color: #4aff88; font-weight: bold;">Activa</span> 
                    {else} 
                        <span style="color: #ef4444; font-weight: bold;">Pausada</span> 
                    {/if}
                </td>
                <td>
                    <a href="admin.php?page=referral_rewards&action=toggle&id={$r.id}" style="color: #fbbf24;">
                        {if $r.is_active == 1} Pausar {else} Activar {/if}
                    </a> | 
                    <a href="admin.php?page=referral_rewards&action=delete&id={$r.id}" onclick="return confirm('¿Seguro que quieres eliminar esta recompensa?');" style="color: #ef4444;">Eliminar</a>
                </td>
            </tr>
            {foreachelse}
            <tr>
                <td colspan="6" style="text-align: center;">No hay recompensas creadas todavía.</td>
            </tr>
            {/foreach}
        </tbody>
    </table>
</div>