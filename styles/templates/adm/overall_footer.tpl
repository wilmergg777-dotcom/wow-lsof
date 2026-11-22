{* ══════════════════════════════════════════════════════════════
   ASTROIO ADMIN FOOTER v3.0
   - Sin cambios visuales (el cierre lo maneja overall_header)
   - Preserva 100% la lógica de reload (top/left/right frames)
   ══════════════════════════════════════════════════════════════ *}
{if isset($smarty.get.reload)}
{if $smarty.get.reload == 't'}
<script type="text/javascript">
parent.topFrame.document.location.reload();
</script>
{elseif $smarty.get.reload == 'l'}
<script type="text/javascript">
parent.rightFrame.document.location.reload();
</script>
{elseif $smarty.get.reload == 'r'}
<script type="text/javascript">
top.document.location.reload();
</script>
{/if}
{/if}
</body>
</html>