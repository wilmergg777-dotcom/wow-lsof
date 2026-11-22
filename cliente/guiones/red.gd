# red.gd — Autoload singleton para la conexión TCP con el servidor.
#
# Protocolo: frames de longitud prefijada (4 bytes uint32 LE + JSON).
# Signals:
#   conectado()                       — conexión establecida
#   desconectado(motivo: String)      — conexión cerrada
#   mensaje_recibido(msg: Dictionary) — un mensaje decodificado
#
# Uso:
#   Red.conectar("127.0.0.1", 7777)
#   Red.enviar({"tipo": "login", "usuario": "x", "password": "y"})
extends Node

signal conectado
signal desconectado(motivo)
signal mensaje_recibido(msg)

const LONGITUD_MAXIMA: int = 1 << 20  # 1 MiB

var _peer: StreamPeerTCP = null
var _buffer: PackedByteArray = PackedByteArray()
var _estado: String = "desconectado"  # "desconectado" | "conectando" | "conectado"
var _host: String = ""
var _puerto: int = 0

# Cache del último personaje propio recibido en sel_resp. Lo leen las escenas
# al cargarse (mundo.gd lo usa para setear el nombre del jugador local).
var ultimo_personaje_propio: Dictionary = {}
# Cachés de facciones/masmoras/arenas (vienen en login_resp/sel_resp).
var facciones_disponibles: Array = []
var masmoras_disponibles: Array = []
var arenas_disponibles: Array = []

func _ready() -> void:
	mensaje_recibido.connect(_on_mensaje_recibido)

func _on_mensaje_recibido(msg: Dictionary) -> void:
	var tipo = msg.get("tipo", "")
	match tipo:
		"sel_resp":
			if msg.get("ok", false):
				ultimo_personaje_propio = msg.get("personaje_propio", {})
				if msg.has("masmoras"):
					masmoras_disponibles = msg.get("masmoras", [])
				if msg.has("arenas"):
					arenas_disponibles = msg.get("arenas", [])
		"login_resp":
			if msg.has("facciones"):
				facciones_disponibles = msg.get("facciones", [])
		"logout":
			ultimo_personaje_propio = {}
			masmoras_disponibles = []
			arenas_disponibles = []

func conectar(host: String, puerto: int) -> bool:
	if _estado == "conectado" or _estado == "conectando":
		return false
	_host = host
	_puerto = puerto
	_peer = StreamPeerTCP.new()
	var err = _peer.connect_to_host(host, puerto)
	if err != OK:
		push_error("[Red] error al conectar: %d" % err)
		_estado = "desconectado"
		return false
	_estado = "conectando"
	print("[Red] conectando a %s:%d…" % [host, puerto])
	return true

func desconectar() -> void:
	if _peer:
		_peer.disconnect_from_host()
	_peer = null
	_estado = "desconectado"
	_buffer.clear()
	emit_signal("desconectado", "desconexión local")

func esta_conectado() -> bool:
	return _estado == "conectado"

func enviar(msg: Dictionary) -> void:
	if not esta_conectado():
		push_warning("[Red] intentar enviar sin conexión: %s" % msg.get("tipo", "?"))
		return
	var data = JSON.stringify(msg).to_utf8_buffer()
	if data.size() > LONGITUD_MAXIMA:
		push_error("[Red] mensaje demasiado grande: %d bytes" % data.size())
		return
	var cab = PackedByteArray()
	cab.resize(4)
	cab.encode_u32(0, data.size())
	var ok1 = _peer.put_data(cab)
	var ok2 = _peer.put_data(data)
	if ok1 != OK or ok2 != OK:
		push_error("[Red] error enviando mensaje: cab=%d data=%d" % [ok1, ok2])
		_forzar_desconexion("error de escritura")

func _process(_delta: float) -> void:
	if _estado == "desconectado" or _peer == null:
		return
	if _estado == "conectando":
		_peer.poll()
		var st = _peer.get_status()
		if st == StreamPeerTCP.STATUS_CONNECTED:
			_estado = "conectado"
			print("[Red] conectado.")
			emit_signal("conectado")
		elif st == StreamPeerTCP.STATUS_ERROR:
			_estado = "desconectado"
			emit_signal("desconectado", "error de conexión")
			return
		else:
			return  # sigue conectando
	# Estado: conectado. Leer bytes disponibles.
	var disp = _peer.get_available_bytes()
	if disp > 0:
		var leidos = _peer.get_partial_data(disp)
		if leidos[0] != OK:
			_forzar_desconexion("error de lectura")
			return
		_buffer.append_array(leidos[1])
		_procesar_buffer()
	elif _peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		_forzar_desconexion("el servidor cerró la conexión")

func _procesar_buffer() -> void:
	while true:
		if _buffer.size() < 4:
			return
		var n = _buffer.decode_u32(0)
		if n == 0:
			# Frame vacío: descartar los 4 bytes de cabecera.
			_buffer = _buffer.slice(4)
			continue
		if n > LONGITUD_MAXIMA:
			push_error("[Red] frame demasiado grande (%d), reseteando buffer" % n)
			_buffer.clear()
			return
		if _buffer.size() < 4 + n:
			return  # esperar más datos
		var payload = _buffer.slice(4, 4 + n)
		_buffer = _buffer.slice(4 + n)
		var txt = payload.get_string_from_utf8()
		var json = JSON.new()
		var err = json.parse(txt)
		if err != OK:
			push_error("[Red] JSON inválido: %s (línea %d)" % [json.get_error_message(), json.get_error_line()])
			continue
		var msg = json.get_data()
		if typeof(msg) != TYPE_DICTIONARY:
			push_warning("[Red] mensaje no es dict: %s" % str(msg))
			continue
		emit_signal("mensaje_recibido", msg)

func _forzar_desconexion(motivo: String) -> void:
	if _peer:
		_peer.disconnect_from_host()
	_peer = null
	_estado = "desconectado"
	_buffer.clear()
	emit_signal("desconectado", motivo)

# ─── Helpers de envío ────────────────────────────────────────────────────

func enviar_login(usuario: String, password: String) -> void:
	enviar({"tipo": "login", "usuario": usuario, "password": password})

func enviar_registro(usuario: String, password: String) -> void:
	enviar({"tipo": "registro", "usuario": usuario, "password": password})

func enviar_crear_pj(nombre: String, clase: String, faccion: String) -> void:
	enviar({"tipo": "crear_pj", "nombre": nombre, "clase": clase, "faccion": faccion})

func enviar_sel_pj(nombre: String) -> void:
	enviar({"tipo": "sel_pj", "nombre": nombre})

func enviar_movimiento(pos: Vector3, rot: Quaternion) -> void:
	enviar({
		"tipo": "mov",
		"pos": {"x": pos.x, "y": pos.y, "z": pos.z},
		"rot": {"x": rot.x, "y": rot.y, "z": rot.z, "w": rot.w},
	})

func enviar_cambiar_objetivo(objetivo_id: String) -> void:
	enviar({"tipo": "cambiar_obj", "objetivo": objetivo_id})

func enviar_habilidad(habilidad_id: String, objetivo_id: String) -> void:
	enviar({"tipo": "habilidad", "habilidad": habilidad_id, "objetivo": objetivo_id})

func enviar_auto_ataque(activo: bool) -> void:
	enviar({"tipo": "auto_ataque", "activo": activo})

func enviar_logout() -> void:
	enviar({"tipo": "logout"})

# ─── Buscador de masmorras / PvP ──────────────────────────────────────────

func enviar_cola_pve_entrar(masmora_id: String) -> void:
	enviar({"tipo": "cola_pve_entrar", "masmora_id": masmora_id})

func enviar_cola_pve_salir() -> void:
	enviar({"tipo": "cola_pve_salir"})

func enviar_cola_pvp_entrar(arena_id: String) -> void:
	enviar({"tipo": "cola_pvp_entrar", "arena_id": arena_id})

func enviar_cola_pvp_salir() -> void:
	enviar({"tipo": "cola_pvp_salir"})
