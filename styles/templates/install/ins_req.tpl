{include file="ins_header.tpl"}

<style>
/* ═══════════════════════════════════════════════
   AstroIO v2.2 — Installer Requirements
   Prefijo: .astroins_req_
   ═══════════════════════════════════════════════ */

.astroins_req_wrap {
    padding: 12px 0;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}

/* ─── Cabecera h2 ─── */
.astroins_req_header {
    color: #00ccff;
    font-size: 15px;
    font-weight: 700;
    margin: 0 0 10px 0;
    text-transform: uppercase;
    letter-spacing: 1.2px;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.35);
}

.astroins_req_desc {
    color: #c8d6e5;
    font-size: 13px;
    line-height: 1.7;
    margin: 0 0 16px 0;
}

/* ─── Tabla de requisitos ─── */
.astroins_req_table {
    width: 100%;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
    border-collapse: collapse;
    overflow: hidden;
    margin-bottom: 18px;
}

.astroins_req_table tr > td {
    padding: 12px 16px !important;
    border-bottom: 1px solid rgba(0, 204, 255, 0.08);
    color: #c8d6e5;
    font-size: 12.5px;
    vertical-align: middle;
}

.astroins_req_table tr:last-child > td {
    border-bottom: none;
}

.astroins_req_table tr:hover > td {
    background: rgba(0, 204, 255, 0.04);
}

.astroins_req_table tr > td.left {
    text-align: left;
}

/* ─── Texto del requisito ─── */
.astroins_req_table tr > td p {
    color: #c8d6e5;
    font-size: 13px;
    font-weight: 500;
    margin: 0 0 4px 0;
    line-height: 1.5;
}

.astroins_req_table tr > td p.desc {
    color: #8899aa;
    font-size: 11.5px;
    font-weight: 400;
    font-style: italic;
    margin: 0;
}

/* ─── Columna de resultado (PHP, PDO, GD...) ─── */
.astroins_req_table tr > td.astroins_req_result {
    text-align: right;
    width: 40%;
    white-space: nowrap;
}

/* ─── Verificación OK / Error ─── */
.astroins_req_table .yes,
.astroins_req_table .ok,
.astroins_req_table .success {
    color: #66ff99 !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(102, 255, 153, 0.3);
}
.astroins_req_table .no,
.astroins_req_table .error,
.astroins_req_table .fatalerror {
    color: #ff4488 !important;
    font-weight: 700;
    text-shadow: 0 0 6px rgba(255, 68, 136, 0.3);
}

/* ─── Bloques generados por PHP ({$dir}, {$config}, {$done}) ─── */
.astroins_req_table tr.astroins_req_php_row > td {
    background: rgba(0, 204, 255, 0.03);
    border-bottom: 1px solid rgba(0, 204, 255, 0.08);
}

.astroins_req_table a {
    color: #00ccff !important;
    text-decoration: none;
    transition: 0.25s ease;
}
.astroins_req_table a:hover {
    color: #00e0ff !important;
    text-shadow: 0 0 8px rgba(0, 224, 255, 0.5);
}

/* ─── Cabecera del FTP ─── */
.astroins_req_ftp_th {
    background: linear-gradient(180deg, #004488 0%, #0077cc 100%) !important;
    border-bottom: 1px solid #00ccff !important;
    color: #ffffff !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    padding: 10px 16px !important;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    text-align: left;
}

/* ─── Formulario FTP ─── */
.astroins_req_ftp_form {
    width: 100%;
    background: linear-gradient(135deg, #0f1624 0%, #1a2332 100%);
    border: 1px solid #1e3a5f;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
    border-collapse: collapse;
    overflow: hidden;
    margin-top: 12px;
}

.astroins_req_ftp_form tr > td {
    padding: 10px 16px !important;
    border-bottom: 1px solid rgba(0, 204, 255, 0.08);
    color: #c8d6e5;
    font-size: 12.5px;
    vertical-align: middle;
}

.astroins_req_ftp_form tr:last-child > td {
    border-bottom: none;
}

.astroins_req_ftp_form tr > td.left {
    color: #00ccff;
    font-weight: 600;
    width: 30%;
    letter-spacing: 0.3px;
}

.astroins_req_ftp_form tr > td.astroins_req_ftp_desc_cell {
    color: #c8d6e5;
    font-size: 12.5px;
    line-height: 1.6;
    padding: 14px 16px !important;
}

/* ─── Inputs del FTP ─── */
.astroins_req_ftp_form input[type="text"],
.astroins_req_ftp_form input[type="password"] {
    width: 100%;
    max-width: 340px;
    background: rgba(15, 22, 36, 0.95) !important;
    border: 1px solid #1e3a5f !important;
    border-radius: 6px !important;
    color: #c8d6e5 !important;
    padding: 8px 12px !important;
    font-size: 12px !important;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif !important;
    outline: none;
    transition: 0.25s ease;
    box-sizing: border-box;
}
.astroins_req_ftp_form input[type="text"]:focus,
.astroins_req_ftp_form input[type="password"]:focus {
    border-color: #00ccff !important;
    box-shadow: 0 0 12px rgba(0, 224, 255, 0.4);
}

/* ─── Botón FTP ─── */
.astroins_req_ftp_btn {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 6px !important;
    color: #ffffff !important;
    padding: 10px 28px !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: 0.25s ease;
    font-family: 'Segoe UI', Roboto, Arial, sans-serif;
}
.astroins_req_ftp_btn:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}
.astroins_req_ftp_btn:active {
    transform: translateY(0);
}

/* ─── Botón "Continuar" del bloque {$done} ─── */
.astroins_req_table button,
.astroins_req_table input[type="submit"],
.astroins_req_table input[type="button"] {
    background: linear-gradient(180deg, #0066cc 0%, #0099ff 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 6px !important;
    color: #ffffff !important;
    padding: 10px 28px !important;
    font-size: 12px !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1px;
    cursor: pointer;
    transition: 0.25s ease;
}
.astroins_req_table button:hover,
.astroins_req_table input[type="submit"]:hover,
.astroins_req_table input[type="button"]:hover {
    background: linear-gradient(180deg, #0099ff 0%, #00ccff 100%) !important;
    box-shadow: 0 0 18px rgba(0, 224, 255, 0.6);
    transform: translateY(-1px);
}

/* ─── Responsive ─── */
@media (max-width: 768px) {
    .astroins_req_table tr > td {
        padding: 10px 12px !important;
        font-size: 12px;
    }
    .astroins_req_table tr > td.astroins_req_result {
        width: auto;
        text-align: left;
    }
    .astroins_req_ftp_form tr > td {
        padding: 8px 12px !important;
    }
    .astroins_req_ftp_form tr > td.left {
        width: auto;
    }
    .astroins_req_ftp_form input[type="text"],
    .astroins_req_ftp_form input[type="password"] {
        max-width: 100%;
    }
    .astroins_req_ftp_btn {
        width: 100%;
        box-sizing: border-box;
    }
}
</style>

<tr>
    <td class="left">
        <div class="installcontent astroins_req_wrap">

            <h2 class="astroins_req_header">{$LNG.req_head}</h2>
            <p class="astroins_req_desc">{$LNG.req_desc}</p>

            {* ═══ Tabla de requisitos ═══ *}
            <table class="req border astroins_req_table">
                <tr>
                    <td class="transparent left"><p>{$LNG.req_php_need}</p><p class="desc">{$LNG.req_php_need_desc}</p></td>
                    <td class="transparent astroins_req_result">{$PHP}</td>
                </tr>
                <tr>
                    <td class="transparent left"><p>{$LNG.reg_global_need}</p><p class="desc">{$LNG.reg_global_desc}</p></td>
                    <td class="transparent astroins_req_result">{$global}</td>
                </tr>
                <tr>
                    <td class="transparent left"><p>{$LNG.reg_pdo_active}</p><p class="desc">{$LNG.reg_pdo_desc}</p></td>
                    <td class="transparent astroins_req_result">{$pdo}</td>
                </tr>
                <tr>
                    <td class="transparent left"><p>{$LNG.reg_gd_need}</p><p class="desc">{$LNG.reg_gd_desc}</p></td>
                    <td class="transparent astroins_req_result">{$gdlib}</td>
                </tr>
                <tr>
                    <td class="transparent left"><p>{$LNG.reg_json_need}</p></td>
                    <td class="transparent astroins_req_result">{$json}</td>
                </tr>
                <tr>
                    <td class="transparent left"><p>{$LNG.reg_iniset_need}</p></td>
                    <td class="transparent astroins_req_result">{$iniset}</td>
                </tr>

                {* ─── Bloques generados por PHP (carpetas + config + botón continuar) ─── *}
                {$dir}
                {$config}
                {$done}
            </table>

        </div>
    </td>
</tr>

{if $ftp != 0}
<tr>
    <td class="transparent" colspan="2"><p>&nbsp;</p></td>
</tr>
<tr>
    <th colspan="2" class="astroins_req_ftp_th">{$LNG.req_ftp_head}</th>
</tr>
<tr>
    <td>
        <form name="ftp" id="ftp" action="" onsubmit="return false;">
        <table class="req astroins_req_ftp_form">
            <tr>
                <td class="transparent left astroins_req_ftp_desc_cell" colspan="2">
                    <p>{$LNG.req_ftp_desc}</p>
                </td>
            </tr>
            <tr>
                <td class="transparent left">{$LNG.req_ftp_host}:</td>
                <td class="transparent"><input type="text" name="host"></td>
            </tr>
            <tr>
                <td class="transparent left">{$LNG.req_ftp_username}:</td>
                <td class="transparent"><input type="text" name="user"></td>
            </tr>
            <tr>
                <td class="transparent left">{$LNG.req_ftp_password}:</td>
                <td class="transparent"><input type="password" name="pass"></td>
            </tr>
            <tr>
                <td class="transparent left">{$LNG.req_ftp_dir}:</td>
                <td class="transparent"><input type="text" name="path"></td>
            </tr>
            <tr class="noborder">
                <td class="transparent right" colspan="2">
                    <input type="button" class="astroins_req_ftp_btn" value="{$LNG.req_ftp_send}" onclick="submitftp();">
                </td>
            </tr>
        </table>
        </form>
    </td>
</tr>
{/if}

{include file="ins_footer.tpl"}