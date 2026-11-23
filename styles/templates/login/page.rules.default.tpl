{block name="title" prepend}{$LNG.siteTitleRules}{/block}
{block name="content"}

{* ============================================================
   ASTROIO RULES v3.0 — Estilo Xnova moderno (glassmorphism)
   Prefijo CSS: .astrorl_   (aislado, no rompe otros módulos)
   Acento del módulo: 🔷 Cyan (#00e0ff)
   FIX v3.0:
     - Patrón fleetDealer aplicado (panel glassmorphism, radius 12px)
     - Centrado con text-align + inline-block (Regla #14)
     - Contenido dinámico {$rules} con estilos extendidos
     - Wrapper padding 15px
     - block name="content", {$LNG}, {$rules} intactos
   ============================================================ *}

{literal}
<style>
/* ═══ ASTROIO v8.1 — reskin nextgen (tokens del índice v8.0) ═══ */
:root {
    --nx-muted:  #9a9a9a;
    --nx-cyan:   #59d6ff;
    --nx-green:  #35ff8f;
    --nx-red:    #ff5252;
    --nx-purple: #d946ef;
    --nx-gold:   #fbbf24;
    --nx-border: rgba(255, 255, 255, 0.1);
}

/* ═══ Tarjeta nextgen (idéntica a las del índice) ═══ */
.astrorl_panel, .panel-default.astrorl_panel {
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid var(--nx-border);
    border-radius: 15px;
    box-shadow: 0 0 40px rgba(0, 0, 0, 0.75);
    overflow: hidden;
}
.astrorl_section_title, .panel-heading.astrorl_heading, .astrorl_heading {
    display: block;
    background: transparent;
    color: #ffffff;
    font-family: 'Space Mono', monospace;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 2px;
    text-transform: uppercase;
    padding: 16px 20px;
    border-bottom: 1px solid var(--nx-border);
    text-shadow: none;
}
.astrorl_wrap {
    font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}

.astrorl_wrap { max-width: 760px; margin: 84px auto 40px; padding: 0 12px; box-sizing: border-box; }
.astrorl_content { padding: 18px 22px; color: #e2e8f0; font-size: 14px; line-height: 1.75; }
.astrorl_content h1, .astrorl_content h2, .astrorl_content h3, .astrorl_content h4 {
    color: #ffffff; font-family: 'Rajdhani', sans-serif; font-weight: 700;
    letter-spacing: .5px; text-shadow: none; margin: 18px 0 8px;
}
.astrorl_content h1 { font-size: 20px; }
.astrorl_content h2 { font-size: 17px; color: var(--nx-cyan); }
.astrorl_content h3 { font-size: 15px; color: var(--nx-purple); }
.astrorl_content a { color: var(--nx-cyan); text-decoration: none; }
.astrorl_content a:hover { color: #ffffff; }
.astrorl_content li { margin-bottom: 4px; color: #e2e8f0; }
.astrorl_content ul li::marker { color: var(--nx-cyan); }
.astrorl_content ol li::marker { color: var(--nx-cyan); font-weight: 700; }
.astrorl_content strong, .astrorl_content b { color: #ffffff; font-weight: 700; }
.astrorl_content em, .astrorl_content i { color: var(--nx-gold); font-style: italic; }
.astrorl_content code {
    background: rgba(0,0,0,.5); border: 1px solid var(--nx-border);
    border-radius: 4px; padding: 2px 8px;
    font-family: 'Space Mono', monospace; font-size: 12px; color: var(--nx-green);
}
.astrorl_content table { width: 100%; border-collapse: collapse; margin: 12px 0; font-size: 12.5px; border-radius: 10px; overflow: hidden; }
.astrorl_content table th {
    padding: 7px 12px; background: rgba(255,255,255,.06); color: #ffffff;
    font-family: 'Space Mono', monospace; font-size: 10px; text-transform: uppercase;
    letter-spacing: 1.5px; text-align: left; border-bottom: 1px solid var(--nx-border); text-shadow: none;
}
.astrorl_content table td { padding: 6px 12px; border-bottom: 1px solid rgba(255,255,255,.08); color: #e2e8f0; }
.astrorl_content table tr:hover td { background: rgba(255,255,255,.04); }
.astrorl_content blockquote {
    border-left: 3px solid var(--nx-cyan); background: rgba(89,214,255,.05);
    margin: 12px 0; padding: 10px 16px; border-radius: 0 10px 10px 0;
    color: #e2e8f0; font-style: italic;
}
.astrorl_content hr { border: none; border-top: 1px solid rgba(255,255,255,.12); margin: 16px 0; }
.astrorl_content img { max-width: 100%; height: auto; border-radius: 10px; border: 1px solid var(--nx-border); }

/* ═══ Móvil ═══ */
@media (max-width: 768px) {
    .astrorl_wrap { margin-top: 70px !important; padding: 0 10px !important; }
    .astrorl_panel { border-radius: 12px; }
    .astrorl_body { padding: 16px 14px !important; }
    .astrorl_actions { text-align: center !important; }
    .astrorl_actions .btn, .astrorl_btn_register, .astrorl_btn_submit { width: 100%; }
}
</style>
{/literal}

<div class="astrorl_wrap">

	<div class="astrorl_panel">

		<span class="astrorl_section_title">📜 {$LNG.siteTitleRules}</span>

		<div class="astrorl_content">
			{$rules}
		</div>

	</div>

</div>

{/block}