{block name="title" prepend}{$LNG.lm_chat}{/block}
{block name="content"}

{* ============================================================
   ASTROIO CHAT v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrochat_   (aislado, no rompe otros módulos)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, sub-secciones 10px)
     - Sub-sección del iframe con borde cyan sutil + hover
     - Wrapper padding 15px
     - Iframe, src, ALLOWTRANSPARENCY y Smarty intactos
   ============================================================ *}

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

/* ====== Wrapper ====== */
.astrochat_wrap {
    width: 100%;
    padding: 15px;
    box-sizing: border-box;
}

/* ====== Panel principal ====== */
.astrochat_panel {
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    padding: 15px;
    color: var(--text-main);
    max-width: 1100px;
    margin: 0 auto;
    box-sizing: border-box;
}

/* ====== Título de sección ====== */
.astrochat_section_title {
    color: #00e0ff;
    font-weight: 700;
    font-size: 11px;
    letter-spacing: 0.6px;
    text-transform: uppercase;
    border-bottom: 1px solid rgba(0, 204, 255, 0.2);
    padding-bottom: 4px;
    margin-bottom: 10px;
    display: block;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.35);
}

/* ====== Contenedor del iframe ====== */
.astrochat_frame_wrap {
    border: 1px solid rgba(0, 204, 255, 0.15);
    border-radius: 10px;
    overflow: hidden;
    background: rgba(0, 0, 0, 0.3);
    box-shadow: 0 0 12px rgba(0, 204, 255, 0.1) inset;
    transition: 0.2s ease;
}
.astrochat_frame_wrap:hover {
    border-color: rgba(0, 204, 255, 0.3);
}

/* ====== Iframe ====== */
.astrochat_iframe {
    display: block;
    width: 100%;
    height: 800px;
    border: 0;
    background: #0f1624;
}

/* ====== Responsive ====== */
@media (max-width: 1200px) {
    .astrochat_panel { max-width: 100%; }
}
@media (max-width: 720px) {
    .astrochat_wrap { padding: 10px; }
    .astrochat_panel { padding: 12px; }
    .astrochat_iframe { height: 600px; }
}
</style>

<div class="astrochat_wrap">

	<div class="astrochat_panel">

		<span class="astrochat_section_title">💬 {$LNG.lm_chat}</span>

		<div class="astrochat_frame_wrap">
			<iframe
				src="./chat/index.php?action={$smarty.get.action|default:''|escape:'html'}"
				class="astrochat_iframe"
				ALLOWTRANSPARENCY="true"></iframe>
		</div>

	</div>

</div>

{/block}