<?php

/**
 *  2Moons 
 *   by Jan-Otto Kröpke 2009-2016
 *
 * For the full copyright and license information, please view the LICENSE
 *
 * @package 2Moons
 * @author Jan-Otto Kröpke <slaver7@gmail.com>
 * @copyright 2009 Lucky
 * @copyright 2016 Jan-Otto Kröpke <slaver7@gmail.com>
 * @licence MIT
 * @version 1.8.0
 * @link https://github.com/jkroepke/2Moons
 */


class ShowScreensPage extends AbstractLoginPage
{
	public static $requireModule = 0;

	function __construct() 
	{
		parent::__construct();
        $this->setWindow('light');
	}
	
	function show() 
	{
		$screenshots = array();
		
		// 📁 Ruta corregida: Apunta directo a tu carpeta de imágenes
		$dir = 'styles/resource/images/screens/';
		
		// Verificamos que la carpeta exista para evitar errores
		if (is_dir($dir)) {
			
			$directoryIterator = new DirectoryIterator($dir);
			
			foreach ($directoryIterator as $fileInfo)
			{
				/** @var $fileInfo DirectoryIterator */
				if (!$fileInfo->isFile()) {
					continue;
				}
				
				// 🔍 Comprobamos que sea una imagen válida (jpg, png, gif)
				$extension = strtolower($fileInfo->getExtension());
				if (!in_array($extension, array('jpg', 'jpeg', 'png', 'gif'))) {
					continue; // Ignoramos archivos que no sean imágenes
				}
				
				$filename = $fileInfo->getFilename();
				
				// Ruta de la imagen original
				$path = $dir . $filename;
				
				// Ruta de la miniatura (por defecto es la misma imagen)
				$thumbnail = $path;
				
				// Si existe una miniatura en la carpeta "thumbnails", la usamos
				if (file_exists($dir . 'thumbnails/' . $filename)) {
					$thumbnail = $dir . 'thumbnails/' . $filename;
				}
				
				$screenshots[] = array(
					'path'      => $path,
					'thumbnail' => $thumbnail,
				);
			}
		}
		
		$this->assign(array(
			'screenshots' => $screenshots
		));

		$this->display('page.screens.default.tpl');
	}
}