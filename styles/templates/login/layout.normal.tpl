{* ============================================================
   ASTROIO v8.0 — LAYOUT NORMAL LOGIN (clon del layout.normal.tpl
   de ultimateXnova): wrapper transparente — las tarjetas flotan
   sobre el fondo. Para páginas internas (news/rules/screens/etc.)
   se da estilo dark-blur a la caja SOLO fuera de body#index,
   igual que hacía la v4.1.
   ============================================================ *}
{literal}
<style>
/* Caja interna con estilo solo en páginas que NO son el índice
   (el índice usa las tarjetas flotantes de ultimateXnova) */
body:not(#index) #content { max-width: 1100px; margin: 0 auto; }
body:not(#index) .box-out,
body:not(#index) .box-inner { border-collapse: collapse; width: 100%; }
body:not(#index) .box-out tr.box-out-header,
body:not(#index) .box-out tr.box-out-footer,
body:not(#index) .box-out td.box-out-content-left,
body:not(#index) .box-out td.box-out-content-right,
body:not(#index) .box-inner td.box-inner-content-left,
body:not(#index) .box-inner td.box-inner-content-right,
body:not(#index) .box-inner tr.box-inner-footer { display: none; }
body:not(#index) td.box-inner-content-center {
    background: rgba(0,0,0,0.5);
    backdrop-filter: blur(10px);
    -webkit-backdrop-filter: blur(10px);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 15px;
    box-shadow: 0px 0px 40px 0px rgba(0,0,0,0.75);
    color: #fff;
    padding: 20px;
    font-family: "Space Mono", monospace;
}
body:not(#index) td.box-inner-content-center h1,
body:not(#index) td.box-inner-content-center h2,
body:not(#index) td.box-inner-content-center h3 { font-family: "Rajdhani", sans-serif; color: #fff; }
body:not(#index) td.box-inner-content-center a { color: rgba(255,255,255,0.8); text-decoration: none; }
body:not(#index) td.box-inner-content-center a:hover { color: #fff; }
body:not(#index) td.box-inner-content-center table { border-collapse: collapse; width: 100%; }
body:not(#index) td.box-inner-content-center table td { padding: 6px 9px; border-bottom: 1px solid rgba(255,255,255,0.1); }
body:not(#index) td.box-inner-content-center input,
body:not(#index) td.box-inner-content-center select,
body:not(#index) td.box-inner-content-center textarea {
    background: rgba(0,0,0,0.5); color: #fff;
    border: 1px solid rgba(255,255,255,0.1); border-radius: 8px;
    padding: 6px 10px; font-family: "Space Mono", monospace; box-sizing: border-box;
}
body:not(#index) td.box-inner-content-center button,
body:not(#index) td.box-inner-content-center input[type=submit] {
    background-color: rgba(0,0,0,0.545); border: 1px solid rgba(255,255,255,0.1);
    color: #fff; border-radius: 25px; padding: 6px 25px;
    font-family: "Rajdhani", sans-serif; font-weight: 700; font-size: 1.1em; cursor: pointer;
}
@media (max-width: 760px) {
    body:not(#index) #content { margin: 0 8px; }
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
