{block name="title" prepend}{$LNG.lm_tourney} - Historial{/block}
{block name="content"}
{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/game/page.tourney.history.tpl === *}
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

<div id="achivment" class="container">
	<div class="ach_main_block">

		<div class="ach_head">
			<div class="ach_head_p">{$LNG.lm_tourney} - Historial de Ganadores</div>
			<div class="pull-right">
				<a href="game.php?page=tourney">Volver a los torneos</a>
			</div>
		</div>

		<div class="ach_main_content">
			<div class="ach_content_box" style="margin-left:14px;">

				<div class="ach_content" style="padding:10px;">

					<table class="tablesorter ally_ranks" style="width:100%;">
						<thead>
							<tr>
								<td style="text-align:center; color:#5ca6aa; background:#091d2e;">#</td>
								<td style="text-align:center; color:#5ca6aa; background:#091d2e;">Torneo</td>
								<td style="text-align:center; color:#5ca6aa; background:#091d2e;">Jugador</td>
								<td style="text-align:center; color:#5ca6aa; background:#091d2e;">Puntos</td>
							</tr>
						</thead>
						<tbody>
							{foreach $winnerList as $Winner}
								<tr>
									<td style="text-align:center;">#{$Winner@iteration}</td>
									<td style="text-align:center;">{$Winner.tourneyJoin}</td>
									<td style="text-align:center; color:#a9a9a9;">{$Winner.playerName}</td>
									<td style="text-align:center; color:#a9a9a9;">{$Winner.tourneyUnits}</td>
								</tr>
							{foreachelse}
								<tr>
									<td colspan="4" style="text-align:center;">Aún no hay ganadores registrados.</td>
								</tr>
							{/foreach}
						</tbody>
					</table>

				</div>

			</div>
		</div>
	</div>
</div>
{/block}