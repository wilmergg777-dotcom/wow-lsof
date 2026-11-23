{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/layout.light.tpl === *}
{literal}
<style>
/* ═══ ASTROIO v8.1 — layout.light nextgen (tokens del índice v8.0) ═══
   Cada página lleva ahora su propia tarjeta dark-blur; la tabla legacy
   box-out/box-inner queda transparente y el título duplicado oculto. */
:root {
    --nx-muted:  #9a9a9a;
    --nx-cyan:   #59d6ff;
    --nx-green:  #35ff8f;
    --nx-red:    #ff5252;
    --nx-purple: #d946ef;
    --nx-gold:   #fbbf24;
    --nx-border: rgba(255, 255, 255, 0.1);
}
html, body { background: #000; }
a { color: var(--nx-cyan); text-decoration: none; transition: .2s ease; }
a:hover { color: #ffffff; }
.globalWarning {
    background: rgba(255, 82, 82, 0.1); border: 1px solid rgba(255, 82, 82, 0.35);
    color: #fecaca; border-radius: 10px; padding: 8px 14px; text-align: center;
}
#content {
    max-width: 1100px; margin: 12px auto 30px; padding: 0 12px;
    box-sizing: border-box; font-family: 'Rajdhani', 'Segoe UI', sans-serif;
}
#content section { display: block; width: 100%; }
/* wrapper legacy (box-out/box-inner) transparente universal */
.box-out, .box-inner {
    width: 100%; border-collapse: collapse;
    background: none; backdrop-filter: none; -webkit-backdrop-filter: none;
    border: none; box-shadow: none; border-radius: 0;
}
tr.box-out-header, tr.box-out-footer, tr.box-inner-header, tr.box-inner-footer,
td.box-out-content-left, td.box-out-content-right,
td.box-inner-content-left, td.box-inner-content-right { display: none; }
td.box-out-content-center, td.box-inner-content-center { display: block; padding: 0; }
@media (max-width: 768px) {
    #content { margin: 8px auto 24px; padding: 0 8px; }
}
</style>
{/literal}

<div id="content">
<section>
	<table class="box-out astrolay_box_out">
		<tr class="box-out-header">
			<td class="box-out-header-left"></td>
			<td class="box-out-header-center"></td>
			<td class="box-out-header-right"></td>
		</tr>
		<tr class="box-out-content">
			<td class="box-out-content-left"></td>
			<td class="box-out-content-center">
				<table class="box-inner astrolay_box_inner">
					<tr class="box-inner-header">
						<td class="box-inner-header-left"></td>
						<td class="box-inner-header-center"><h1>{block name=title}{/block}</h1></td>
						<td class="box-inner-header-right"></td>
					</tr>
					<tr class="box-inner-content">
						<td class="box-inner-content-left"></td>
						<td class="box-inner-content-center">{block name=content}{/block}</td>
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