{* === ASTROIO v3.0 - estilo nuevo aplicado archivo por archivo: styles/templates/login/layout.light.tpl === *}
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

{include file="main.header.tpl"}
{include file="main.navigation.tpl"}

<style>
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

#content {
    max-width: 1100px;
    margin: 20px auto;
    padding: 0 10px;
    box-sizing: border-box;
    font-family: 'Segoe UI', Roboto, sans-serif;
}

#content section {
    display: block;
    width: 100%;
}

.astrolay_box_out {
    width: 100%;
    border-collapse: collapse;
    background: var(--bg-card);
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border: 1px solid var(--border-color);
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
    overflow: hidden;
}

.astrolay_box_out tr.box-out-header,
.astrolay_box_out tr.box-out-footer {
    display: none;
}

.astrolay_box_out td.box-out-content-left,
.astrolay_box_out td.box-out-content-right {
    display: none;
}

.astrolay_box_out td.box-out-content-center {
    padding: 0;
}

.astrolay_box_inner {
    width: 100%;
    border-collapse: collapse;
}

.astrolay_box_inner tr.box-inner-header {
    display: block;
}

.astrolay_box_inner td.box-inner-header-left,
.astrolay_box_inner td.box-inner-header-right {
    display: none;
}

.astrolay_box_inner td.box-inner-header-center {
    display: block;
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    padding: 10px 16px;
    text-align: left;
}

.astrolay_box_inner td.box-inner-header-center h1 {
    color: #ffffff;
    font-size: 13px;
    font-weight: 700;
    margin: 0;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrolay_box_inner tr.box-inner-content {
    display: block;
}

.astrolay_box_inner td.box-inner-content-left,
.astrolay_box_inner td.box-inner-content-right {
    display: none;
}

.astrolay_box_inner td.box-inner-content-center {
    display: block;
    padding: 16px 20px;
    color: var(--text-main);
    font-size: 13px;
    line-height: 1.6;
}

.astrolay_box_inner tr.box-inner-footer {
    display: none;
}

.astrolay_box_inner td.box-inner-content-center h1,
.astrolay_box_inner td.box-inner-content-center h2,
.astrolay_box_inner td.box-inner-content-center h3 {
    color: var(--accent-cyan);
    margin-top: 0;
    letter-spacing: 0.5px;
}

.astrolay_box_inner td.box-inner-content-center h1 {
    font-size: 20px;
    border-bottom: 1px solid var(--border-color);
    padding-bottom: 8px;
}

.astrolay_box_inner td.box-inner-content-center h2 { font-size: 16px; }
.astrolay_box_inner td.box-inner-content-center h3 { font-size: 14px; }

.astrolay_box_inner td.box-inner-content-center p {
    color: var(--text-main);
    line-height: 1.7;
}

.astrolay_box_inner td.box-inner-content-center a {
    color: var(--accent-cyan);
    text-decoration: none;
    transition: 0.2s ease;
}

.astrolay_box_inner td.box-inner-content-center a:hover {
    color: #ffffff;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.7);
}

.astrolay_box_inner td.box-inner-content-center table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px;
    color: var(--text-main);
}

.astrolay_box_inner td.box-inner-content-center table th {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    padding: 6px 10px;
    text-align: left;
    font-weight: normal;
    text-transform: uppercase;
    font-size: 10.5px;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrolay_box_inner td.box-inner-content-center table td {
    padding: 6px 10px;
    border-bottom: 1px solid var(--border-color);
}

.astrolay_box_inner td.box-inner-content-center table tr:hover {
    background: rgba(0, 224, 255, 0.04);
}

.astrolay_box_inner td.box-inner-content-center input[type="text"],
.astrolay_box_inner td.box-inner-content-center input[type="password"],
.astrolay_box_inner td.box-inner-content-center input[type="email"],
.astrolay_box_inner td.box-inner-content-center input[type="number"],
.astrolay_box_inner td.box-inner-content-center select,
.astrolay_box_inner td.box-inner-content-center textarea {
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 1px solid rgba(0, 204, 255, 0.35);
    border-radius: 8px;
    padding: 6px 10px;
    font-size: 12px;
    transition: 0.25s ease;
    box-sizing: border-box;
}

.astrolay_box_inner td.box-inner-content-center input:focus,
.astrolay_box_inner td.box-inner-content-center select:focus,
.astrolay_box_inner td.box-inner-content-center textarea:focus {
    outline: none;
    border-color: var(--accent-cyan);
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.5);
    background: rgba(0, 0, 0, 0.65);
    transform: translateY(-1px);
}

.astrolay_box_inner td.box-inner-content-center button,
.astrolay_box_inner td.box-inner-content-center input[type="submit"] {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%);
    color: #ffffff;
    border: 1px solid var(--accent-cyan);
    border-radius: 8px;
    padding: 6px 18px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    transition: 0.25s ease;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrolay_box_inner td.box-inner-content-center button:hover,
.astrolay_box_inner td.box-inner-content-center input[type="submit"]:hover {
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.5);
    transform: translateY(-2px);
}

.astrolay_box_inner td.box-inner-content-center button:active,
.astrolay_box_inner td.box-inner-content-center input[type="submit"]:active {
    transform: translateY(0);
}

.astrolay_box_inner td.box-inner-content-center .panel,
.astrolay_box_inner td.box-inner-content-center .card {
    background: rgba(0, 224, 255, 0.03);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 12px 14px;
    margin-bottom: 12px;
}

.astrolay_box_inner td.box-inner-content-center .panel-heading {
    background: linear-gradient(135deg, rgba(0, 68, 136, 0.85), rgba(0, 119, 204, 0.85));
    backdrop-filter: blur(6px);
    -webkit-backdrop-filter: blur(6px);
    border-bottom: 1px solid var(--accent-cyan);
    color: #ffffff;
    padding: 8px 14px;
    margin: -12px -14px 12px;
    border-radius: 8px 8px 0 0;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1px;
    text-shadow: 0 1px 2px rgba(0, 0, 0, 0.4);
}

.astrolay_box_inner td.box-inner-content-center hr {
    border: none;
    border-top: 1px solid var(--border-color);
    margin: 16px 0;
}

@media (max-width: 768px) {
    #content {
        margin: 10px auto;
        padding: 0 6px;
    }
    .astrolay_box_inner td.box-inner-content-center {
        padding: 12px 14px;
    }
}
</style>

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