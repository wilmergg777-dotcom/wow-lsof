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
 *
 * FIX 2026-10-11:
 *   - DSN ahora incluye ";charset=utf8mb4"
 *   - INIT_COMMAND cambiado de "utf8" a "utf8mb4"
 *   Permite leer/guardar emojis (4 bytes). Antes los convertia a "?"
 *   al leer de la BD porque la conexion PDO usaba utf8mb3 (3 bytes max).
 *
 * ✅ FIX AstroIO v1.1 (PHP 8.2) - 2026-10-11:
 *   - selectSingle() ahora maneja correctamente el caso en que la
 *     consulta NO devuelve ninguna fila (resultado = false).
 *     Antes, cuando $field estaba definido y no había fila, intentaba
 *     hacer $res[$field] sobre un booleano false → error fatal
 *     "Trying to access array offset on value of type bool".
 *   - Se cambió `is_null($res)` por `!is_array($res)` para cubrir
 *     tanto null como false.
 *   - Se añadió isset() al acceder a $res[$field] por seguridad.
 * 
 * ✅ FIX AstroIO v1.2 (Emojis) - 2026-10-18:
 *   - INIT_COMMAND corregido. "SET NAMES utf8mb4, CHARACTER SET utf8mb4" 
 *     era sintaxis inválida y rompía la conexión. Ahora solo usa 
 *     "SET sql_mode = 'STRICT_ALL_TABLES'" (el charset ya está en el DSN).
 */

class Database
{
	protected $dbHandle = NULL;
	protected $dbTableNames = array();
	protected $lastInsertId = false;
	protected $rowCount = false;
	protected $queryCounter = 0;
	protected static $instance = NULL;


	public static function get()
	{
		if (!isset(self::$instance))
			self::$instance = new self();

		return self::$instance;
	}

	public function getDbTableNames()
	{
		return $this->dbTableNames;
	}

	private function __clone()
	{

	}

	protected function __construct()
	{
		$database = array();
		require 'includes/config.php';
		//Connect
		$db = new PDO("mysql:host=".$database['host'].";port=".$database['port'].";dbname=".$database['databasename'].";charset=utf8mb4", $database['user'], $database['userpw'], array(
		    PDO::MYSQL_ATTR_INIT_COMMAND => "SET sql_mode = 'STRICT_ALL_TABLES'"
		));
		//error behaviour
		$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
		$db->setAttribute(PDO::MYSQL_ATTR_USE_BUFFERED_QUERY, true);
		$this->dbHandle = $db;

		$dbTableNames = array();

		include 'includes/dbtables.php';

		foreach($dbTableNames as $key => $name)
		{
			$this->dbTableNames['keys'][]	= '%%'.$key.'%%';
			$this->dbTableNames['names'][]	= $name;
		}
	}

	public function disconnect()
	{
		$this->dbHandle = NULL;
	}

	public function getHandle()
	{
		return $this->dbHandle;
	}

	public function lastInsertId()
	{
		return $this->lastInsertId;
	}

	public function rowCount()
	{
		return $this->rowCount;
	}
	
	protected function _query($qry, array $params, $type)
	{
		if (in_array($type, array("insert", "select", "update", "delete", "replace")) === false)
		{
			throw new Exception("Unsupported Query Type");
		}

		$this->lastInsertId = false;
		$this->rowCount = false;
		
		$qry	= str_replace($this->dbTableNames['keys'], $this->dbTableNames['names'], $qry);

		/** @var $stmt PDOStatement */
		$stmt	= $this->dbHandle->prepare($qry);

		if (isset($params[':limit']) || isset($params[':offset']))
		{
			foreach($params as $param => $value)
			{
				if($param == ':limit' || $param == ':offset')
				{
					$stmt->bindValue($param, (int) $value, PDO::PARAM_INT);
				}
				else
				{
					$stmt->bindValue($param, (int) $value, PDO::PARAM_STR);
				}
			}
		}

		try {
			$success = (count($params) !== 0 && !isset($params[':limit']) && !isset($params[':offset'])) ? $stmt->execute($params) : $stmt->execute();
		}
		catch (PDOException $e) {
			throw new Exception($e->getMessage()."<br>\r\n<br>\r\nQuery-Code:".str_replace(array_keys($params), array_values($params), $qry));
		}

		$this->queryCounter++;

		if (!$success)
			return false;

		if ($type === "insert")
			$this->lastInsertId = $this->dbHandle->lastInsertId();
		$this->rowCount = $stmt->rowCount();

		return ($type === "select") ? $stmt : true;
	}

	protected function getQueryType($qry)
	{
		if(!preg_match('!^(\S+)!', $qry, $match))
        {
            throw new Exception("Invalid query $qry!");
        }

		if(!isset($match[1]))
        {
            throw new Exception("Invalid query $qry!");
        }

		return strtolower($match[1]);
	}

	public function delete($qry, array $params = array())
	{
		if (($type = $this->getQueryType($qry)) !== "delete")
			throw new Exception("Incorrect Delete Query");

		return $this->_query($qry, $params, $type);
	}

	public function replace($qry, array $params = array())
	{
		if (($type = $this->getQueryType($qry)) !== "replace")
			throw new Exception("Incorrect Replace Query");

		return $this->_query($qry, $params, $type);
	}

	public function update($qry, array $params = array())
	{
		if (($type = $this->getQueryType($qry)) !== "update")
			throw new Exception("Incorrect Update Query");

		return $this->_query($qry, $params, $type);
	}

	public function insert($qry, array $params = array())
	{
		if (($type = $this->getQueryType($qry)) !== "insert")
			throw new Exception("Incorrect Insert Query");

		return $this->_query($qry, $params, $type);
	}

	public function select($qry, array $params = array())
	{
		if (($type = $this->getQueryType($qry)) !== "select")
			throw new Exception("Incorrect Select Query");

		$stmt = $this->_query($qry, $params, $type);
		return $stmt->fetchAll(PDO::FETCH_ASSOC);
	}

	/**
	 * ✅ FIX AstroIO v1.1 (PHP 8.2)
	 * ------------------------------------------------------------
	 * selectSingle() devuelve una fila (o un campo específico de ella).
	 * 
	 * Cambios respecto al original:
	 *   - ANTES: `return ($field === false || is_null($res)) ? $res : $res[$field];`
	 *     Si $res era `false` (sin filas) y $field estaba definido,
	 *     intentaba hacer `false[$field]` → error fatal en PHP 8.2.
	 *   - AHORA: `!is_array($res)` cubre tanto `null` como `false`.
	 *     Y al acceder a $res[$field], se verifica con isset().
	 */
	public function selectSingle($qry, array $params = array(), $field = false)
	{
		if (($type = $this->getQueryType($qry)) !== "select")
			throw new Exception("Incorrect Select Query");

		$stmt = $this->_query($qry, $params, $type);
		$res = $stmt->fetch(PDO::FETCH_ASSOC);

		// ✅ FIX PHP 8.2: Si no hay fila (false) o no es un array,
		// devolver directamente $res (que será false).
		if ($field === false || !is_array($res)) {
			return $res;
		}

		// ✅ FIX PHP 8.2: Comprobar que la columna exista antes de acceder.
		return isset($res[$field]) ? $res[$field] : false;
	}
	
	/**
	 * Lists column values of a table
	 * with desired key from the
	 * database as an array.
	 *
	 * @param  string 		$table
	 * @param  string 		$column
	 * @param  string|null 	$key
	 * @return array
	 */
	public function lists($table, $column, $key = null)
	{
		$selects = implode(', ', is_null($key) ? array($column) : array($column, $key));
		
		$qry = "SELECT {$selects} FROM %%{$table}%%;";
		$stmt = $this->_query($qry, array(), 'select');

		$results = array();
		if (is_null($key))
		{
			while ($row = $stmt->fetch(PDO::FETCH_ASSOC))
			{
				$results[] = $row[$column];
			}
		}
		else
		{
			while ($row = $stmt->fetch(PDO::FETCH_ASSOC))
			{
				$results[$row[$key]] = $row[$column];
			}
		}

		return $results;
	}

	public function query($qry)
	{
		$this->lastInsertId = false;
		$this->rowCount = false;
		$this->rowCount = $this->dbHandle->exec($qry);
		$this->queryCounter++;
	}

	public function nativeQuery($qry)
	{
		$this->lastInsertId = false;
		$this->rowCount = false;

		$qry	= str_replace($this->dbTableNames['keys'], $this->dbTableNames['names'], $qry);

		/** @var $stmt PDOStatement */
		$stmt	= $this->dbHandle->query($qry);

		$this->rowCount = $stmt->rowCount();

		$this->queryCounter++;
		return in_array($this->getQueryType($qry), array('select', 'show')) ? $stmt->fetchAll(PDO::FETCH_ASSOC) : true;
	}

	public function getQueryCounter()
	{
		return $this->queryCounter;
	}

	static public function formatDate($time)
	{
		return date('Y-m-d H:i:s', $time);
	}

	public function quote($str)
	{
		return $this->dbHandle->quote($str);
	}
}