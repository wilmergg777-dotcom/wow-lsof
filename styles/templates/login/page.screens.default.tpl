{block name="title" prepend}{$LNG.siteTitleScreens}{/block}
{block name="content"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Galería de Imágenes (Screens)
   Prefijo: .astroscr_
   Acento: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Glassmorphism real (backdrop-filter + rgba)
     - border-radius 12px (panel) / 8px (items)
     - Variables --bg-card / --accent-cyan unificadas
     - Todos los IDs/classes/Smarty intactos
     - .gallery (fancybox) preservado
   ═══════════════════════════════════════════════ */

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

.astroscr_wrap {
    max-width: 1100px;
    margin: 80px auto 20px;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

.astroscr_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astroscr_heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    font-size: 12px;
    font-weight: 700;
    padding: 10px 16px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
}

.astroscr_body {
    padding: 20px 16px;
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
    border: 1px solid var(--border-color);
    background: rgba(0, 0, 0, 0.4);
    transition: 0.25s ease;
    text-decoration: none;
}

.astroscr_item a.gallery:hover {
    border-color: var(--accent-cyan);
    box-shadow: 0 0 20px rgba(0, 224, 255, 0.5);
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
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.9);
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
        margin-top: 70px;
        padding: 0 6px;
    }
    .astroscr_body {
        padding: 14px 10px;
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