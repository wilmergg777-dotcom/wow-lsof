{block name="title" prepend}{$LNG.siteTitleScreens}{/block}
{block name="content"}
{* === ASTROIO v3.1 - Galería de Imágenes (Estilo oscuro, borde naranja) === *}
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
/* ✅ FIX: Corregido el error de sintaxis del doble corchete */
@media (max-width:760px) { body { padding:6px; overflow-x:auto; } table { font-size:11px; } table th, table td { padding:5px 7px; } }
</style>
{/literal}


<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.1 — Galería de Imágenes (Screens)
   ✅ FIX: Eliminada la barra azul superior.
   ✅ FIX: Borde naranja y fondo oscuro igual al index.
   ═══════════════════════════════════════════════ */

:root {
    --bg-dark:       rgba(11, 16, 30, 0.55);
    --bg-card:       rgba(10, 15, 25, 0.9); /* Fondo oscuro igual al index */
    --bg-inner:      rgba(0, 0, 0, 0.35);
    --border-color:  #ff5e00; /* Borde naranja */
    --text-main:     #cbd5e1;
    --text-muted:    #94a3b8;
    --accent-cyan:   #00e0ff;
    --accent-orange: #ff5e00;
}

.astroscr_wrap {
    max-width: 1100px;
    margin: 40px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astroscr_panel {
    background: var(--bg-card) !important;
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    border: 1px solid var(--border-color) !important;
    border-radius: 12px !important;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.9) !important;
    overflow: hidden;
}

/* ✅ FIX: Ocultar la barra azul de "IMÁGENES DEL JUEGO" */
.astroscr_heading {
    display: none !important; 
}

.astroscr_body {
    padding: 30px 20px;
}

/* ═══ Grid de thumbnails ═══ */
.astroscr_grid {
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    justify-content: center;
}

.astroscr_item {
    flex: 0 0 auto;
    width: 160px;
    text-align: center;
}

/* Enlace (fancybox) */
.astroscr_item a.gallery {
    display: block;
    position: relative;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    background: rgba(0, 0, 0, 0.5) !important;
    transition: 0.25s ease;
    text-decoration: none;
}

.astroscr_item a.gallery:hover {
    border-color: var(--accent-orange) !important; /* Borde naranja al pasar el ratón */
    box-shadow: 0 0 20px rgba(255, 94, 0, 0.4) !important;
    transform: translateY(-3px);
}

.astroscr_item a.gallery::after {
    content: '🔍';
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%, -50%) scale(0);
    font-size: 24px;
    opacity: 0;
    transition: 0.25s ease;
    pointer-events: none;
    text-shadow: 0 0 10px rgba(255, 94, 0, 0.9);
}

.astroscr_item a.gallery:hover::after {
    transform: translate(-50%, -50%) scale(1);
    opacity: 1;
}

/* Imagen */
.astroscr_item a.gallery img {
    display: block;
    width: 100%;
    height: auto;
    border-radius: 8px;
    transition: 0.25s ease;
    filter: brightness(0.85) saturate(0.9);
}

.astroscr_item a.gallery:hover img {
    filter: brightness(1.1) saturate(1.1);
    transform: scale(1.05);
}

/* Responsive */
@media (max-width: 768px) {
    .astroscr_wrap {
        margin-top: 20px;
        padding: 0 6px;
    }
    .astroscr_body {
        padding: 20px 10px;
    }
    .astroscr_grid {
        gap: 10px;
    }
    .astroscr_item {
        width: 130px;
    }
}

@media (max-width: 480px) {
    .astroscr_item {
        width: 45%;
    }
}
</style>

<div class="container astroscr_wrap">
    <div class="panel panel-default astroscr_panel">
        <div class="panel-heading astroscr_heading">{$LNG.siteTitleScreens}</div>
        <div class="panel-body astroscr_body">
            <div class="row astroscr_grid">
            {foreach $screenshots as $screenshot}
                <div class="col-lg-4 astroscr_item">
                    <a class="gallery" href="{$screenshot.path}" target="_blank" rel="gallery">
                        <img src="{$screenshot.thumbnail}" alt="" width="120" height="120" class="img-rounded">
                    </a>
                </div>
            {/foreach}
            </div>
        </div>
    </div>
</div>

{/block}
{block name="script"}
<script>
$(function() {
	$(".gallery").fancybox();
});
</script>
{/block}