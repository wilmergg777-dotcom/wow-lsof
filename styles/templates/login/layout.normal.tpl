{* ============================================================
   ASTROIO v8.0 — LAYOUT NORMAL LOGIN (clon del layout.normal.tpl
   de ultimateXnova): wrapper transparente — las tarjetas flotan
   sobre el fondo. Para páginas internas (news/rules/screens/etc.)
   se da estilo dark-blur a la caja SOLO fuera de body#index,
   igual que hacía la v4.1.
   ============================================================ *}
{literal}
<style>
/* ═══ ASTROIO v8.1 — wrapper transparente universal:
   TODAS las páginas del login (índice + sub-vistas) llevan ahora
   sus propias tarjetas nextgen dark-blur; la tabla box-out/box-inner
   legacy se desactiva para no crear cajas dobles. ═══ */
#content { max-width: 1100px; margin: 0 auto; }
.box-out, .box-inner { border-collapse: collapse; width: 100%; }
tr.box-out-header, tr.box-out-footer,
tr.box-inner-header, tr.box-inner-footer,
td.box-out-content-left, td.box-out-content-right,
td.box-inner-content-left, td.box-inner-content-right { display: none; }
td.box-out-content-center, td.box-inner-content-center { padding: 0; background: none; border: none; }
@media (max-width: 760px) {
    #content { margin: 0 8px; }
}
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
