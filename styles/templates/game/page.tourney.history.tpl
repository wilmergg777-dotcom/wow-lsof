{block name="title" prepend}{$LNG.lm_tourney} - Historial{/block}
{block name="content"}
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