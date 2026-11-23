<?php

class ShowDownloadsPage extends AbstractLoginPage
{
	public function __construct() 
	{
		parent::__construct();
		$this->setWindow('normal'); // Usa 'normal' para que tenga el fondo y el menú
	}
	
	public function show() 
	{
		$this->display('page.downloads.default.tpl');
	}
}