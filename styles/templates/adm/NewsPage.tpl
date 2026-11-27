{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/adm/NewsPage.tpl === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }
table { background:rgba(15,23,42,.55); border:1px solid #1e293b; border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:linear-gradient(135deg,rgba(0,68,136,.85),rgba(0,119,204,.85)); border-bottom:1px solid rgba(0,224,255,.5); color:#fff; padding:6px 9px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
table td { padding:6px 9px; border-bottom:1px solid rgba(30,41,59,.7); color:#cbd5e1 }
table tr:hover td { background:rgba(0,224,255,.04) }
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { background:rgba(0,0,0,.5); color:#fff; border:1px solid rgba(0,204,255,.35); border-radius:8px; padding:5px 9px; font-size:12px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease }
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); background:rgba(0,0,0,.65) }
textarea { width:100%; resize:vertical; font-family:inherit }
button, input[type=submit], input[type=button] { background:linear-gradient(180deg,#0066cc,#0099ff); color:#fff; border:1px solid #00e0ff; border-radius:8px; padding:5px 16px; font-size:11.5px; font-weight:600; font-family:inherit; cursor:pointer; transition:.25s ease; text-transform:uppercase; letter-spacing:.5px; text-shadow:0 1px 2px rgba(0,0,0,.4) }
button:hover, input[type=submit]:hover, input[type=button]:hover { box-shadow:0 0 18px rgba(0,224,255,.5); transform:translateY(-2px) }
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }
input[type=reset] { background:linear-gradient(180deg,#444,#666); border-color:#888 }
select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }
@media (max-width:760px) { { padding:6px; overflow-x:auto } table { font-size:11px } table th, table td { padding:5px 7px } }
</style>
{/literal}

{include file="overall_header.tpl"}
{nocache}{if isset($mode)}
<form method="POST" action="?page=news&amp;action=send&amp;mode={$mode}">
{if isset($news_id)}<input name="id" type="hidden" value="{$news_id}">{/if}
<table>
<tr>
	<th colspan="2">{$nws_head}</th>
</tr>
<tr>
<tr>
	<td width="25%">{$nws_title}</td><td><input type="text" name="title" value="{$news_title}"></td>
</tr>
<tr>
	<td>{$nws_content}</td><td><textarea cols="70" rows="10" name="text">{$news_text}</textarea></td>
</tr>
<tr>
	<td colspan="2"><input type="submit" name="Submit" value="{$button_submit}"></td>
</tr>
</table>
</form>
{/if}{/nocache}
<table width="450">
<tr>
	<th colspan="5">{$nws_news}</thd>
</tr>
<tr>
	<td>{$nws_id}</td>
	<td>{$nws_title}</td>
	<td>{$nws_date}</td>
	<td>{$nws_from}</td>
	<td>{$nws_del}</td>
</tr>
{foreach name=NewsList item=NewsRow from=$NewsList}<tr>
<td><a href="?page=news&amp;action=edit&amp;id={$NewsRow.id}">{$NewsRow.id}</a></td>
<td><a href="?page=news&amp;action=edit&amp;id={$NewsRow.id}">{$NewsRow.title}</a></td>
<td><a href="?page=news&amp;action=edit&amp;id={$NewsRow.id}">{$NewsRow.date}</a></td>
<td><a href="?page=news&amp;action=edit&amp;id={$NewsRow.id}">{$NewsRow.user}</a></td>
<td><a href="?page=news&amp;action=delete&amp;id={$NewsRow.id}" onclick="return confirm('{$NewsRow.confirm}');"><img border="0" src="./styles/resource/images/alliance/CLOSE.png" width="16" height="16"></a></td>
</tr>
{/foreach}
<tr><td colspan="5"><a href="?page=news&amp;action=create">{$nws_create}</a></td></tr>
<tr><td colspan="5">{$nws_total}</td></tr>
</table>
{include file="overall_footer.tpl"}