{block name="content"}
{* === ASTROIO v3.1 - Estilos para respuestas AJAX (Fondo oscuro, borde naranja) === *}
{literal}
<style>
/* === ASTROIO v3.0 === */
h1, h2, h3, h4 { color:#fff; letter-spacing:.5px; text-shadow:0 1px 3px rgba(0,0,0,.5) }
a { color:#00e0ff; text-decoration:none; transition:.2s ease }
a:hover { color:#fff; text-shadow:0 0 10px rgba(0,224,255,.7) }

/* Tablas con fondo oscuro y borde naranja tenue */
table { background:rgba(10, 15, 25, 0.9); border:1px solid rgba(255, 94, 0, 0.3); border-radius:10px; border-collapse:collapse; overflow:hidden }
table th { background:rgba(0, 0, 0, 0.6); border-bottom:1px solid #ff5e00; color:#00e0ff; padding:8px 10px; text-align:left; text-transform:uppercase; font-size:10px; letter-spacing:.5px; font-weight: 700; }
table td { padding:8px 10px; border-bottom:1px solid rgba(255,255,255,0.05); color:#cbd5e1 }
table tr:hover td { background:rgba(255, 94, 0, 0.05) }

/* Inputs blancos con letra negra */
input[type=text], input[type=password], input[type=email], input[type=number], input[type=date], select, textarea { 
    background:#ffffff; color:#333333; 
    border:1px solid rgba(255,255,255,0.2); border-radius:6px; 
    padding:10px 12px; font-size:13px; font-family:inherit; box-sizing:border-box; max-width:100%; transition:.25s ease 
}
input[type=text]:focus, input[type=password]:focus, input[type=email]:focus, input[type=number]:focus, select:focus, textarea:focus { 
    outline:none; border-color:#00e0ff; box-shadow:0 0 12px rgba(0,224,255,.5); 
}
textarea { width:100%; resize:vertical; font-family:inherit }

/* Botones estilo oscuro */
button, input[type=submit], input[type=button] { 
    background:#222c3c; color:#fff; 
    border:1px solid #444; border-radius:6px; 
    padding:10px 20px; font-size:13px; font-weight:700; 
    font-family:inherit; cursor:pointer; transition:.25s ease; 
    text-transform:uppercase; letter-spacing:.5px; 
}
button:hover, input[type=submit]:hover, input[type=button]:hover { 
    background:#2e3a4e; border-color:#ff5e00; 
    box-shadow:0 0 18px rgba(255, 94, 0, 0.4); transform:translateY(-2px) 
}
button:active, input[type=submit]:active, input[type=button]:active { transform:translateY(0) }

input[type=reset] { background:#111; border-color:#333; color:#ccc; }
input[type=reset]:hover { background:#222; border-color:#555; }

select option { background:#0f172a; color:#cbd5e1 }
.globalWarning { background:rgba(239,68,68,.12); border:1px solid rgba(239,68,68,.45); color:#fecaca; border-radius:10px; padding:8px 14px; text-align:center }

/* ✅ FIX: Corregido el error de sintaxis del doble corchete */
@media (max-width:760px) { body { padding:6px; overflow-x:auto; } table { font-size:11px; } table th, table td { padding:5px 7px; } }
</style>
{/literal}
{/block}