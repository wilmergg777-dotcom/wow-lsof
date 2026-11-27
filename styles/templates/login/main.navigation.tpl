{* ============================================================
   ASTROIO v8.3 — NAV LOGIN (Menú unificado)
   - ✅ FIX: Enlace de Descargas corregido para usar el motor.
   ============================================================ *}
<header>
	<div class="dark-blur-bg menu-container box-shadow-large">
		<div class="uk-container">

		<nav id="navbar" class="uk-navbar">
			<div class="uk-navbar-left">
				<img class="logo" src="styles/resource/images/astroio.svg" alt="AstroIO">
			</div>
			<div class="uk-navbar-right">
				<ul class="uk-navbar-nav">
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'index' || $page == ''}uk-active{/if}" href="index.php?page=index">{$LNG.menu_index|default:'ÍNDICE'}</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'register'}uk-active{/if}" href="index.php?page=register">{$LNG.siteTitleRegister|default:'REGISTRO'}</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'news'}uk-active{/if}" href="index.php?page=news">{$LNG.menu_news|default:'NOTICIAS'}</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'rules'}uk-active{/if}" href="index.php?page=rules">{$LNG.menu_rules|default:'REGLAS'}</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'battleHall'}uk-active{/if}" href="index.php?page=battleHall">Salón de la Fama</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'banList'}uk-active{/if}" href="index.php?page=banList">Baneados</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'disclamer'}uk-active{/if}" href="index.php?page=disclamer">Contactar</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'buglist'}uk-active{/if}" href="index.php?page=buglist">Reportes de Bug</a>
					</li>
					<li class="menu-item">
						{* ✅ FIX: Enlace correcto para el motor del juego *}
						<a class="uk-preserve-width {if $page == 'downloads'}uk-active{/if}" href="index.php?page=downloads">Descargas</a>
					</li>
					<li class="menu-item">
						<a class="uk-preserve-width" href="https://discord.gg/bDMjbKSw9j" target="_blank" rel="noopener noreferrer" title="Discord">
							<img src="styles/theme/gow/ultimate/img/social/discord-mark-white.svg" width="30px" alt="Discord">
						</a>
					</li>
				</ul>

				<i class="bi bi-list d-flex d-md-none px-3 text-white fs-2 menu_icon" data-bs-toggle="offcanvas" data-bs-target="#phoneMenu"></i>

			</div>
		</nav>
		</div>
	</div>

	{* Menú móvil (Offcanvas) *}
	<div class="offcanvas offcanvas-start dark-blur-bg box-shadow" id="phoneMenu">
		<div class="offcanvas-header">
			<span class="offcanvas-title fs-2">{$gameName}</span>
			<button type="button" class="btn-close btn-close-white" aria-label="Close" data-bs-dismiss="offcanvas"></button>
		</div>
		<div class="offcanvas-body p-0">
			<ul style="list-style:none;" class="main-menu p-0 m-0">
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'index' || $page == ''}active{/if}" href="index.php?page=index">{$LNG.menu_index|default:'ÍNDICE'}</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'register'}active{/if}" href="index.php?page=register">{$LNG.siteTitleRegister|default:'REGISTRO'}</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'news'}active{/if}" href="index.php?page=news">{$LNG.menu_news|default:'NOTICIAS'}</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'rules'}active{/if}" href="index.php?page=rules">{$LNG.menu_rules|default:'REGLAS'}</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'battleHall'}active{/if}" href="index.php?page=battleHall">Salón de la Fama</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'banList'}active{/if}" href="index.php?page=banList">Baneados</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'disclamer'}active{/if}" href="index.php?page=disclamer">Contactar</a>
				</li>
				<li class="menu-item">
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'buglist'}active{/if}" href="index.php?page=buglist">Reportes de Bug</a>
				</li>
				<li class="menu-item">
					{* ✅ FIX: Enlace correcto para el motor del juego *}
					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'downloads'}active{/if}" href="index.php?page=downloads">Descargas</a>
				</li>
			</ul>
		</div>
	</div>
</header>
<div class="uk-container">