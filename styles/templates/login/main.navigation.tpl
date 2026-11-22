<style>
/* ═══════════════════════════════════════════════
   AstroIO v3.0 — Navegación Superior (Login/Público)
   Prefijo: .astronav_
   Acento: 🔷 Cyan (#00e0ff)
   ═══════════════════════════════════════════════ */

/* ═══ Variables globales ═══ */
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

/* ═══ BARRA PRINCIPAL (glassmorphism) ═══ */
nav.navbar.navbar-default.navbar-inverse.navbar-fixed-top {
    background: rgba(15, 23, 42, 0.75) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border: none !important;
    border-bottom: 1px solid var(--border-color) !important;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5) !important;
    font-family: 'Segoe UI', Roboto, sans-serif !important;
    border-radius: 0 !important;
    min-height: 52px !important;
}

nav.navbar > .container {
    padding: 0 15px !important;
}

/* ═══ MARCA (Brand) ═══ */
nav.navbar .navbar-brand {
    color: #00e0ff !important;
    font-size: 17px !important;
    font-weight: 700 !important;
    letter-spacing: 1px !important;
    text-shadow: 0 0 14px rgba(0, 224, 255, 0.5) !important;
    padding: 15px 15px !important;
    height: auto !important;
    transition: 0.25s ease !important;
    text-transform: uppercase !important;
}
nav.navbar .navbar-brand:hover,
nav.navbar .navbar-brand:focus {
    color: #ffffff !important;
    text-shadow: 0 0 20px rgba(0, 224, 255, 0.9) !important;
    background: transparent !important;
}

/* ═══ BOTÓN HAMBURGUESA (móvil) ═══ */
nav.navbar .navbar-toggle {
    background: linear-gradient(135deg, rgba(0, 102, 204, 0.9) 0%, rgba(0, 153, 255, 0.9) 100%) !important;
    border: 1px solid #00ccff !important;
    border-radius: 8px !important;
    margin-top: 9px !important;
    transition: 0.25s ease !important;
}
nav.navbar .navbar-toggle:hover,
nav.navbar .navbar-toggle:focus {
    box-shadow: 0 0 14px rgba(0, 224, 255, 0.5) !important;
    background: linear-gradient(135deg, rgba(0, 153, 255, 0.95) 0%, rgba(0, 204, 255, 0.95) 100%) !important;
    transform: translateY(-1px) !important;
}
nav.navbar .navbar-toggle .icon-bar {
    background-color: #ffffff !important;
    border-radius: 2px !important;
}

/* ═══ LISTA DE ENLACES ═══ */
nav.navbar .nav.navbar-nav {
    display: flex !important;
    align-items: center !important;
    margin: 0 !important;
    padding: 0 !important;
    list-style: none !important;
}

nav.navbar .nav.navbar-nav > li {
    float: none !important;
    margin: 0 !important;
    padding: 0 !important;
}

nav.navbar .nav.navbar-nav > li > a {
    display: block !important;
    color: #66ccff !important;
    background: transparent !important;
    font-size: 12.5px !important;
    font-weight: 600 !important;
    text-transform: uppercase !important;
    letter-spacing: 0.8px !important;
    padding: 16px 14px !important;
    line-height: 20px !important;
    transition: 0.25s ease !important;
    position: relative !important;
    text-decoration: none !important;
    border-radius: 0 !important;
}

/* Línea cyan inferior al hacer hover */
nav.navbar .nav.navbar-nav > li > a::after {
    content: '';
    position: absolute;
    left: 14px; right: 14px;
    bottom: 8px; height: 2px;
    background: #00e0ff;
    transform: scaleX(0);
    transform-origin: center;
    transition: transform 0.25s ease;
    border-radius: 2px;
}

nav.navbar .nav.navbar-nav > li > a:hover,
nav.navbar .nav.navbar-nav > li > a:focus {
    color: #00e0ff !important;
    background: rgba(0, 200, 255, 0.08) !important;
    text-shadow: 0 0 10px rgba(0, 224, 255, 0.6) !important;
}

nav.navbar .nav.navbar-nav > li > a:hover::after,
nav.navbar .nav.navbar-nav > li > a:focus::after {
    transform: scaleX(1);
}

/* Activo (si Bootstrap lo añade) */
nav.navbar .nav.navbar-nav > li.active > a,
nav.navbar .nav.navbar-nav > li.active > a:hover,
nav.navbar .nav.navbar-nav > li.active > a:focus {
    color: #ffffff !important;
    background: rgba(0, 200, 255, 0.15) !important;
}
nav.navbar .nav.navbar-nav > li.active > a::after {
    transform: scaleX(1);
}

/* ═══ COLAPSO ABIERTO EN MÓVIL (glassmorphism) ═══ */
nav.navbar .navbar-collapse {
    border-top: none !important;
    box-shadow: none !important;
    background: transparent !important;
}
nav.navbar .navbar-collapse.in,
nav.navbar .navbar-collapse.collapsing {
    background: rgba(15, 23, 42, 0.85) !important;
    backdrop-filter: blur(6px) !important;
    -webkit-backdrop-filter: blur(6px) !important;
    border-top: 1px solid var(--border-color) !important;
}

/* En móvil, alineación vertical de los links */
@media (max-width: 767px) {
    nav.navbar .nav.navbar-nav {
        display: block !important;
    }
    nav.navbar .nav.navbar-nav > li > a {
        padding: 12px 15px !important;
        border-bottom: 1px solid var(--border-color) !important;
    }
    nav.navbar .nav.navbar-nav > li > a::after {
        display: none !important;
    }
    nav.navbar .nav.navbar-nav > li:last-child > a {
        border-bottom: none !important;
    }
}

/* ═══ AJUSTE PARA CONTENIDO DEBAJO (navbar-fixed-top) ═══ */
body { padding-top: 52px !important; }
</style>

<nav class="navbar navbar-default navbar-inverse navbar-fixed-top " role="navigation" style="border-color: #333;">
	<div class="container">
		<!-- Brand and toggle get grouped for better mobile display -->
		<div class="navbar-header">
			<button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-ex1-collapse">
				<span class="sr-only">Toggle navigation</span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="#">{$gameName}</a>
		</div>

		<!-- Collect the nav links, forms, and other content for toggling -->
		<div class="collapse navbar-collapse navbar-ex1-collapse">
			<ul class="nav navbar-nav">
				<li><a href="index.php">{$LNG.menu_index}</a></li>
				<li><a href="index.php?page=news">{$LNG.menu_news}</a></li>
				<li><a href="index.php?page=rules">{$LNG.menu_rules}</a></li>
				<li><a href="index.php?page=battleHall">{$LNG.menu_battlehall}</a></li>
				<li><a href="index.php?page=banList">{$LNG.menu_banlist}</a></li>
				<li><a href="index.php?page=disclamer">{$LNG.menu_disclamer}</a></li>
				<li><a href="index.php?page=buglist">Reportes de BUG</a></li>
				
				<!-- ✅ NUEVO BOTÓN DE DESCARGAS AÑADIDO AQUÍ -->
				<li><a href="descargas.php" style="color: #00e0ff !important; font-weight: 700 !important;">DESCARGAS 📥</a></li>
				
			</ul>
		</div><!-- /.navbar-collapse -->
	</div>
</nav>

<!-- ✅ FIX ASTROIO: Script para que el botón hamburguesa funcione sin Bootstrap JS -->
<script type="text/javascript">
$(document).ready(function() {
    $('.navbar-toggle').on('click', function(e) {
        e.preventDefault();
        var target = $($(this).data('target'));
        
        // Alternar la clase 'in' que muestra/oculta el menú
        target.toggleClass('in');
        
        // Actualizar el estado del botón
        $(this).attr('aria-expanded', target.hasClass('in'));
        $(this).toggleClass('collapsed');
    });

    // Opcional: Cerrar el menú al hacer clic en un enlace (mejor UX en móvil)
    $('.navbar-collapse .nav > li > a').on('click', function() {
        if ($(window).width() < 768) {
            $('.navbar-collapse').removeClass('in');
            $('.navbar-toggle').attr('aria-expanded', 'false').addClass('collapsed');
        }
    });
});
</script>
<!-- ✅ FIN FIX ASTROIO -->