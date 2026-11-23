{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.bugreport.newform.tpl === *}
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


{* ══════════════════════════════════════════════════════════════
   ASTRO BUG REPORT v3.0 — Nuevo Reporte (Paso 2: Formulario)
   Prefijo: .astrobug_
   Acento del módulo: 🟡 Dorado (#ffaa33)
   FIX v3.0:
     - Patrón fleetDealer aplicado (glassmorphism, radius 10-12px)
     - Inputs/textarea con radius 8px + focus translateY
     - Botones con radius 8px + hover translateY
     - Wrapper padding 15px
     - form, inputs, names, placeholder, required y Smarty intactos
   ══════════════════════════════════════════════════════════════ *}

<style>
/* ====== Variables globales ====== */
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

.astrobug_wrap {
    max-width: 900px;
    margin: 0 auto;
    color: var(--text-main);
    font-family: 'Segoe UI', Tahoma, sans-serif;
    padding: 15px;
    box-sizing: border-box;
}

/* Cabecera (glassmorphism) */
.astrobug_header {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    padding: 25px 20px;
    margin-bottom: 20px;
    text-align: center;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.astrobug_title {
    font-size: 22px;
    font-weight: bold;
    color: #ffaa33;
    text-shadow: 0 0 14px rgba(255, 170, 51, 0.5);
    margin-bottom: 8px;
    letter-spacing: 1px;
}

.astrobug_subtitle {
    font-size: 12px;
    color: var(--text-muted);
    font-style: italic;
    margin-bottom: 8px;
}

.astrobug_step {
    display: inline-block;
    background: rgba(0, 204, 255, 0.15);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.4);
    color: #00ccff;
    padding: 4px 14px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 0 6px rgba(0, 204, 255, 0.4);
}

.astrobug_msg_error {
    background: rgba(255, 68, 136, 0.1);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(255, 68, 136, 0.4);
    color: #ff4488;
    padding: 12px 18px;
    border-radius: 10px;
    margin-bottom: 15px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
}

/* Formulario (glassmorphism) */
.astrobug_form {
    background: rgba(0, 0, 0, 0.3);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    padding: 25px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    transition: 0.2s ease;
}
.astrobug_form:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* Caja de categoría */
.astrobug_categoria_box {
    background: rgba(0, 204, 255, 0.08);
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 10px;
    padding: 14px 18px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 12px;
}

.astrobug_categoria_box .emoji {
    font-size: 28px;
    line-height: 1;
    filter: drop-shadow(0 0 6px rgba(0, 224, 255, 0.5));
}

.astrobug_categoria_box .info {
    flex: 1;
}

.astrobug_categoria_box .label {
    font-size: 10px;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 1px;
    margin-bottom: 2px;
}

.astrobug_categoria_box .valor {
    font-size: 14px;
    color: #00e0ff;
    font-weight: 700;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.4);
}

.astrobug_categoria_box a {
    color: #66ccff;
    font-size: 11px;
    text-decoration: none;
    padding: 5px 12px;
    border: 1px solid rgba(0, 204, 255, 0.3);
    border-radius: 8px;
    transition: all 0.25s ease;
    white-space: nowrap;
}
.astrobug_categoria_box a:hover {
    background: rgba(0, 204, 255, 0.15);
    color: #00e0ff;
    border-color: #00ccff;
    box-shadow: 0 0 10px rgba(0, 224, 255, 0.4);
    transform: translateY(-1px);
}

/* Campos del formulario */
.astrobug_field {
    margin-bottom: 20px;
}

.astrobug_label {
    display: block;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    color: #00ccff;
    margin-bottom: 8px;
}

.astrobug_label .req {
    color: #ff4488;
    margin-left: 3px;
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.5);
}

.astrobug_label .hint {
    color: #667788;
    font-size: 10px;
    font-weight: 400;
    margin-left: 6px;
    text-transform: none;
    letter-spacing: 0;
}

/* Inputs + Textarea */
.astrobug_input,
.astrobug_textarea {
    width: 100%;
    background: rgba(0, 0, 0, 0.5);
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    color: #ffffff;
    padding: 10px 14px;
    font-size: 13px;
    font-family: inherit;
    transition: all 0.25s ease;
    box-sizing: border-box;
    outline: none;
}

.astrobug_input:focus,
.astrobug_textarea:focus {
    border-color: #00e0ff;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrobug_input::placeholder,
.astrobug_textarea::placeholder {
    color: #556677;
}

.astrobug_textarea {
    min-height: 150px;
    resize: vertical;
    line-height: 1.5;
    font-family: inherit;
}

/* Acciones */
.astrobug_actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    margin-top: 20px;
    flex-wrap: wrap;
}

.astrobug_btn {
    border: none;
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    font-weight: bold;
    padding: 11px 26px;
    cursor: pointer;
    transition: all 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-decoration: none;
    display: inline-block;
    font-family: inherit;
}
.astrobug_btn:active {
    transform: translateY(0) !important;
}

.astrobug_btn.primary {
    background: linear-gradient(135deg, rgba(170, 102, 0, 0.9), rgba(255, 170, 51, 0.9));
    border: 1px solid #ffcc66;
}
.astrobug_btn.primary:hover {
    background: linear-gradient(135deg, rgba(255, 170, 51, 0.95), rgba(255, 204, 102, 0.95));
    box-shadow: 0 0 20px rgba(255, 170, 51, 0.6);
    color: #1a1000;
    transform: translateY(-2px);
}

.astrobug_btn.gris {
    background: linear-gradient(135deg, rgba(51, 68, 85, 0.9), rgba(85, 102, 119, 0.9));
    border: 1px solid #667788;
}
.astrobug_btn.gris:hover {
    background: linear-gradient(135deg, rgba(85, 102, 119, 0.95), rgba(102, 119, 136, 0.95));
    box-shadow: 0 0 14px rgba(100, 120, 140, 0.5);
    transform: translateY(-2px);
}

/* Responsive */
@media (max-width: 720px) {
    .astrobug_wrap { padding: 10px; }
    .astrobug_header { padding: 20px 15px; }
    .astrobug_title { font-size: 18px; }
    .astrobug_form { padding: 18px; }
    .astrobug_categoria_box { flex-wrap: wrap; }
    .astrobug_categoria_box a { width: 100%; text-align: center; box-sizing: border-box; }
    .astrobug_actions { flex-direction: column-reverse; }
    .astrobug_btn { width: 100%; text-align: center; box-sizing: border-box; }
}
</style>

<div class="astrobug_wrap">

    {if $msgError}
        <div class="astrobug_msg_error">{$msgError}</div>
    {/if}

    <div class="astrobug_header">
        <div class="astrobug_step">Paso 2 de 2</div>
        <div class="astrobug_title">🐛 NUEVO REPORTE DE BUG</div>
        <div class="astrobug_subtitle">Completá los datos del reporte</div>
    </div>

    <form method="post" action="game.php?page=bugreport&mode=doNew" class="astrobug_form">

        <div class="astrobug_categoria_box">
            <span class="emoji">{$categoria.emoji}</span>
            <div class="info">
                <div class="label">Categoría seleccionada</div>
                <div class="valor">{$categoria.nombre}</div>
            </div>
            <a href="game.php?page=bugreport&mode=new">← Cambiar</a>
        </div>

        <input type="hidden" name="categoria" value="{$categoria.clave}">

        <div class="astrobug_field">
            <label class="astrobug_label">
                Título del reporte <span class="req">*</span>
                <span class="hint">(mínimo 5 caracteres)</span>
            </label>
            <input type="text" name="titulo" class="astrobug_input" 
                   placeholder="Ej: Error al construir edificios"
                   maxlength="200" required>
        </div>

        <div class="astrobug_field">
            <label class="astrobug_label">
                Explicación del problema <span class="req">*</span>
                <span class="hint">(mínimo 30 caracteres — explicá qué pasa y cómo reproducirlo)</span>
            </label>
            <textarea name="descripcion" class="astrobug_textarea" 
                      placeholder="Explicá con el mayor detalle posible qué estabas haciendo cuando ocurrió el bug, qué esperabas que pasara y qué pasó en realidad..." required></textarea>
        </div>

        <div class="astrobug_actions">
            <a href="game.php?page=bugreport&mode=new" class="astrobug_btn gris">← Volver</a>
            <button type="submit" class="astrobug_btn primary">📨 Enviar Reporte</button>
        </div>

    </form>

</div>

{/block}