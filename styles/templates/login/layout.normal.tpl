{* ============================================================
   ASTROIO v8.2 — LAYOUT NORMAL LOGIN 
   - ✅ FIX: Añadidos los includes de header y navigation.
   - Ocultada la barra azul superior (.box-inner-header).
   - Borde naranja y fondo oscuro idénticos al index.
   ============================================================ *}
   
{include file="main.header.tpl"}
{include file="main.navigation.tpl"}

{literal}
<style>
/* Caja interna con estilo solo en páginas que NO son el índice */
body:not(#index) #content { max-width: 1100px; margin: 0 auto; padding-top: 20px; }
body:not(#index) .box-out,
body:not(#index) .box-inner { border-collapse: collapse; width: 100%; }

/* ✅ FIX: Ocultar cabeceras, footers y laterales (incluyendo la barra azul) */
body:not(#index) .box-out tr.box-out-header,
body:not(#index) .box-out tr.box-out-footer,
body:not(#index) .box-out td.box-out-content-left,
body:not(#index) .box-out td.box-out-content-right,
body:not(#index) .box-inner tr.box-inner-header, /* 🔥 Oculta la barra azul "REGISTRO" */
body:not(#index) .box-inner td.box-inner-header-center,
body:not(#index) .box-inner td.box-inner-content-left,
body:not(#index) .box-inner td.box-inner-content-right,
body:not(#index) .box-inner tr.box-inner-footer { 
    display: none !important; 
}

/* ✅ FIX: Estilo idéntico al index (fondo oscuro y borde naranja) */
body:not(#index) td.box-inner-content-center {
    background: rgba(10, 15, 25, 0.9) !important;
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid #ff5e00 !important; /* Borde naranja */
    border-radius: 12px;
    box-shadow: 0px 10px 40px 0px rgba(0,0,0,0.8);
    color: #cbd5e1;
    padding: 30px 40px;
    font-family: "Space Mono", monospace;
    margin: 30px auto;
    max-width: 900px;
}

body:not(#index) td.box-inner-content-center h1,
body:not(#index) td.box-inner-content-center h2,
body:not(#index) td.box-inner-content-center h3 { 
    font-family: "Rajdhani", sans-serif; 
    color: #fff; 
    border-bottom: 1px solid rgba(255, 94, 0, 0.3);
    padding-bottom: 10px;
    margin-bottom: 20px;
}

body:not(#index) td.box-inner-content-center a { 
    color: #00e0ff; 
    text-decoration: none; 
}
body:not(#index) td.box-inner-content-center a:hover { 
    color: #fff; 
}

body:not(#index) td.box-inner-content-center table { 
    border-collapse: collapse; 
    width: 100%; 
}
body:not(#index) td.box-inner-content-center table td { 
    padding: 8px 10px; 
    border-bottom: 1px solid rgba(255,255,255,0.05); 
}

body:not(#index) td.box-inner-content-center input,
body:not(#index) td.box-inner-content-center select,
body:not(#index) td.box-inner-content-center textarea {
    background: #ffffff; color: #333;
    border: 1px solid rgba(255,255,255,0.2); border-radius: 6px;
    padding: 10px 12px; font-family: "Space Mono", monospace; box-sizing: border-box;
    margin-bottom: 10px;
    width: 100%;
}

body:not(#index) td.box-inner-content-center button,
body:not(#index) td.box-inner-content-center input[type=submit] {
    background: #222c3c; 
    border: 1px solid #444;
    color: #fff; 
    border-radius: 6px; 
    padding: 12px 25px;
    font-family: "Rajdhani", sans-serif; 
    font-weight: 700; 
    font-size: 1.1em; 
    cursor: pointer;
    transition: 0.3s;
}
body:not(#index) td.box-inner-content-center button:hover,
body:not(#index) td.box-inner-content-center input[type=submit]:hover {
    background: #2e3a4e;
    border-color: #ff5e00;
}

@media (max-width: 760px) {
    body:not(#index) #content { margin: 0 8px; }
    body:not(#index) td.box-inner-content-center { padding: 15px; margin: 15px auto; }
}

/* Índice: sin caja, tarjetas flotando sobre el fondo */
#index #content { max-width: none; }
#index .box-out, #index .box-inner { border-collapse: collapse; width: 100%; }
#index tr.box-out-header, #index tr.box-out-footer,
#index tr.box-inner-header, #index tr.box-inner-footer,
#index td.box-out-content-left, #index td.box-out-content-right,
#index td.box-inner-content-left, #index td.box-inner-content-right { display: none; }
#index td.box-out-content-center, #index td.box-inner-content-center { padding: 0; }
</style>
{/literal}

<div id="content">
<section>
	<table class="box-out">
		<tr class="box-out-header">
			<td class="box-out-header-left"></td>
			<td class="box-out-header-center"></td>
			<td class="box-out-header-right"></td>
		</tr>
		<tr class="box-out-content">
			<td class="box-out-content-left"></td>
			<td class="box-out-content-center">
				<table class="box-inner">
					<tr class="box-inner-header">
						<td class="box-inner-header-left"></td>
						<td class="box-inner-header-center"><h1>{block name=title}{/block}</h1></td>
						<td class="box-inner-header-right"></td>
					</tr>
					<tr class="box-inner-content">
						<td class="box-inner-content-left"></td>
						<td class="box-inner-content-center">{block name=content} {/block}</td>
						<td class="box-inner-content-right"></td>
					</tr>
					<tr class="box-inner-footer">
						<td class="box-inner-footer-left"></td>
						<td class="box-inner-footer-center"></td>
						<td class="box-inner-footer-right"></td>
					</tr>
				</table>
			</td>
			<td class="box-out-content-right"></td>
		</tr>
		<tr class="box-out-footer">
			<td class="box-out-footer-left"></td>
			<td class="box-out-footer-center"></td>
			<td class="box-out-footer-right"></td>
		</tr>
	</table>
</section>
</div>
{include file="main.footer.tpl" nocache}