{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/page.admin.cloneuniverse.tpl === *}
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