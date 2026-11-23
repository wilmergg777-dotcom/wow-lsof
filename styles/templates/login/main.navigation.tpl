{* ============================================================
   ASTROIO v8.0 — NAV LOGIN (clon del main.navigation.tpl de
   ultimateXnova, tema nextgen): barra translúcida con logo SVG
   grande a la izquierda, menú Rajdhani a la derecha (ÍNDICE,
   REGISTRO, NOTICIAS, REGLAS), icono Discord y dropdown Language.
   Menú móvil offcanvas igual que ultimate.
   ============================================================ *}
<header>
	<div class="dark-blur-bg menu-container box-shadow-large">
		<div class="uk-container">

		<nav id="navbar" class="uk-navbar">
			<div class="uk-navbar-left"><img class="logo" src="styles/resource/images/astroio.svg" alt="AstroIO"></div>
				<div class="uk-navbar-right">
				<ul class="uk-navbar-nav">
					<li class="menu-item">
						<a class="uk-preserve-width {if $page == 'index'}uk-active{/if} {if $page == ''}uk-active{/if}" href="index.php?page=index">{$LNG.menu_index|default:'ÍNDICE'}</a>
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
						<a class="uk-preserve-width" href="https://discord.gg/bDMjbKSw9j" target="_blank" rel="noopener noreferrer" title="Discord"><img src="styles/theme/gow/ultimate/img/social/discord-mark-white.svg" width="30px" alt="Discord"></a>
					</li>
				</ul>

				{if count($languages) > 1}
				<i class="bi bi-list d-flex d-md-none px-3 text-white fs-2 menu_icon" data-bs-toggle="offcanvas" data-bs-target="#phoneMenu"></i>

				<div class="dropdown">
				<button style="width:120px;height:32px;" class="btn btn-secondary dropdown-toggle p-1 menu-item justify-content-center" type="button" id="dropdownMenuButton1" data-bs-toggle="dropdown">
					Language
				</button>
				<ul style="width:auto;" class="dropdown-menu flex-column bg-dark p-0" aria-labelledby="dropdownMenuButton1">
						{foreach $languages as $langID}
						<li class="d-flex w-100">
								<a class="text-decoration-none hover-bg-color-grey menu-item w-100 px-2" href="?lang={$langID}" rel="alternate" hreflang="{$langID}" title="{$langID|strtoupper}">
									<span class="">{$langID|strtoupper}</span>
								</a>
							</li>
						{/foreach}
				</ul>
				</div>
				{/if}

				</div>

			</nav>
		</div>
	</div>

	<div class="offcanvas offcanvas-start dark-blur-bg box-shadow" id="phoneMenu">
	  <div class="offcanvas-header">
	    <span class="offcanvas-title fs-2">{$gameName}</span>
	    <button type="button" class="btn-close btn-close-white" aria-label="Close" data-bs-dismiss="offcanvas"></button>
	  </div>
	  <div class="offcanvas-body p-0" >

	    <ul style="list-style:none;" class="main-menu p-0 m-0">
					<li class="menu-item">
  					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'index'}active{/if}" href="index.php?page=index">{$LNG.menu_index|default:'ÍNDICE'}</a>
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
  					<a class="fs-6 w-100 hover-color-yellow text-decoration-none py-2 border-light {if $page == 'disclamer'}active{/if}" href="index.php?page=disclamer">{$LNG.menu_disclamer|default:'CONTACTAR'}</a>
  				</li>
  	      </ul>
	  </div>
	</div>

</header>
<div class="uk-container">
