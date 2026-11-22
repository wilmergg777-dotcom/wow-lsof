<style>
    /* Forzamos el fondo oscuro en el iframe del admin */
    html, body {
        background-color: #0b101e !important;
        margin: 0;
        padding: 0;
        height: 100%;
    }
</style>

<div class="admin_box" style="background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(6px); -webkit-backdrop-filter: blur(6px); color: #cbd5e1; padding: 20px; min-height: 100vh; font-family: Arial, sans-serif; box-sizing: border-box;">
    <h2 style="color: #00e0ff; border-bottom: 2px solid rgba(0, 224, 255, 0.3); padding-bottom: 10px; margin-top: 0;">🚀 Clonador de Universos</h2>
    
    <p style="color: #ef4444; font-weight: bold; margin-bottom: 20px;">
        ⚠️ ADVERTENCIA: Si el Universo Destino ya tiene jugadores, sus tablas serán borradas y recreadas desde cero.
    </p>

    {if $message}
        <div style="padding: 10px; margin-bottom: 20px;">
            {$message}
        </div>
    {/if}

    <form action="{$actionUrl}" method="POST" style="background: rgba(0, 0, 0, 0.35); padding: 20px; border-radius: 12px; border: 1px solid #1e293b;">
        <input type="hidden" name="action" value="clone">
        
        <div style="display: flex; gap: 20px; margin-bottom: 20px;">
            <div style="flex: 1;">
                <label style="display: block; margin-bottom: 5px; color: #00e0ff; font-weight: bold;">Universo Origen (Copiar de):</label>
                <select name="origen" style="width: 100%; padding: 10px; background: #0b101e; color: #ffffff; border: 1px solid #00e0ff; border-radius: 8px; outline: none;">
                    <option value="1">Universo 1</option>
                    <option value="2">Universo 2</option>
                    <option value="3">Universo 3</option>
                </select>
            </div>
            <div style="flex: 1;">
                <label style="display: block; margin-bottom: 5px; color: #00e0ff; font-weight: bold;">Universo Destino (Crear):</label>
                <select name="destino" style="width: 100%; padding: 10px; background: #0b101e; color: #ffffff; border: 1px solid #00e0ff; border-radius: 8px; outline: none;">
                    <option value="2">Universo 2</option>
                    <option value="3">Universo 3</option>
                    <option value="4">Universo 4</option>
                </select>
            </div>
        </div>

        <fieldset style="border: 1px solid #1e293b; padding: 15px; margin-bottom: 20px; border-radius: 8px; background: rgba(15, 23, 42, 0.5);">
            <legend style="color: #8b5cf6; font-weight: bold; padding: 0 5px;">Datos de la Base de Datos (Opcional)</legend>
            <p style="color: #94a3b8; font-size: 12px; margin-top: 0;">Si dejas estos campos vacíos, el juego usará su propia conexión segura automáticamente.</p>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <input type="text" name="db_host" placeholder="Host (ej. localhost)" style="flex: 1; padding: 10px; background: #0b101e; color: #ffffff; border: 1px solid #334155; border-radius: 8px; outline: none;">
                <input type="text" name="db_user" placeholder="Usuario" style="flex: 1; padding: 10px; background: #0b101e; color: #ffffff; border: 1px solid #334155; border-radius: 8px; outline: none;">
                <input type="password" name="db_pass" placeholder="Contraseña" style="flex: 1; padding: 10px; background: #0b101e; color: #ffffff; border: 1px solid #334155; border-radius: 8px; outline: none;">
                <input type="text" name="db_name" placeholder="Nombre de BD (ej. xnova_db)" style="flex: 1; padding: 10px; background: #0b101e; color: #ffffff; border: 1px solid #334155; border-radius: 8px; outline: none;">
            </div>
        </fieldset>

        <button type="submit" style="background: linear-gradient(135deg, #0066cc, #0099ff); color: #ffffff; padding: 12px 25px; border: 1px solid #00e0ff; border-radius: 8px; font-weight: bold; cursor: pointer; font-size: 14px; box-shadow: 0 0 15px rgba(0, 224, 255, 0.4); transition: all 0.2s;" onclick="return confirm('¿Estás SEGURO de sobrescribir el universo destino? Esto puede tardar unos minutos.');">
            🚀 Iniciar Clonación
        </button>
    </form>
</div>