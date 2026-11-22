# login.gd — controla la pantalla de login y registro.
#
# Flujo:
#   1. El usuario introduce host, puerto, usuario y password.
#   2. Click "Entrar" (login) o "Registrar" (crear cuenta nueva).
#   3. Red envía el mensaje correspondiente.
#   4. Cuando llega login_resp OK, cargamos pantalla_seleccion.tscn.
extends Control

@onready var host_edit: LineEdit = $Centro/Panel/Margen/VBox/FilaServidor/Host
@onready var puerto_edit: LineEdit = $Centro/Panel/Margen/VBox/FilaServidor/Puerto
@onready var usuario_edit: LineEdit = $Centro/Panel/Margen/VBox/Usuario
@onready var password_edit: LineEdit = $Centro/Panel/Margen/VBox/Password
@onready var estado_lbl: Label = $Centro/Panel/Margen/VBox/Estado

func _ready() -> void:
	Red.conectado.connect(_on_conectado)
	Red.desconectado.connect(_on_desconectado)
	Red.mensaje_recibido.connect(_on_mensaje)
	usuario_edit.grab_focus()

func _on_conectado() -> void:
	_estado("Conectado al servidor. Autentícate.")

func _on_desconectado(motivo: String) -> void:
	_estado("Desconectado: %s" % motivo)

func _on_mensaje(msg: Dictionary) -> void:
	var tipo = msg.get("tipo", "")
	match tipo:
		"login_resp":
			_manejar_login_resp(msg)
		"registro_resp":
			_manejar_registro_resp(msg)

func _on_entrar() -> void:
	if not Red.esta_conectado():
		var host = host_edit.text.strip_edges()
		var puerto = int(puerto_edit.text.strip_edges())
		if host.is_empty() or puerto <= 0:
			_estado("Host/puerto inválidos.")
			return
		_estado("Conectando a %s:%d…" % [host, puerto])
		Red.conectar(host, puerto)
		# Esperamos al signal conectado para mandar login.
		_login_pendiente = true
		return
	_enviar_login()

var _login_pendiente: bool = false

func _process(_delta: float) -> void:
	if _login_pendiente and Red.esta_conectado():
		_login_pendiente = false
		_enviar_login()

func _enviar_login() -> void:
	var usuario = usuario_edit.text.strip_edges()
	var password = password_edit.text
	if usuario.is_empty() or password.is_empty():
		_estado("Usuario y contraseña son obligatorios.")
		return
	Red.enviar_login(usuario, password)
	_estado("Autenticando…")

func _on_registrar() -> void:
	if not Red.esta_conectado():
		var host = host_edit.text.strip_edges()
		var puerto = int(puerto_edit.text.strip_edges())
		if host.is_empty() or puerto <= 0:
			_estado("Host/puerto inválidos.")
			return
		_estado("Conectando a %s:%d…" % [host, puerto])
		Red.conectar(host, puerto)
		_registro_pendiente = true
		return
	_enviar_registro()

var _registro_pendiente: bool = false

# Segundo _process para no pisar el del login pendiente.
func _physics_process(_delta: float) -> void:
	if _registro_pendiente and Red.esta_conectado():
		_registro_pendiente = false
		_enviar_registro()

func _enviar_registro() -> void:
	var usuario = usuario_edit.text.strip_edges()
	var password = password_edit.text
	if usuario.is_empty() or password.is_empty():
		_estado("Usuario y contraseña son obligatorios.")
		return
	if usuario.length() < 3:
		_estado("Usuario muy corto (mínimo 3).")
		return
	if password.length() < 6:
		_estado("Contraseña muy corta (mínimo 6).")
		return
	Red.enviar_registro(usuario, password)
	_estado("Registrando…")

func _manejar_login_resp(msg: Dictionary) -> void:
	if not msg.get("ok", false):
		_estado("Login fallido: %s" % msg.get("error", "desconocido"))
		return
	var personajes = msg.get("personajes", [])
	_estado("Login ok. Personajes: %d" % personajes.size())
	# Ir a pantalla de selección.
	get_tree().change_scene_to_file("res://escenas/pantalla_seleccion.tscn")

func _manejar_registro_resp(msg: Dictionary) -> void:
	if not msg.get("ok", false):
		_estado("Registro fallido: %s" % msg.get("error", "desconocido"))
		return
	_estado("Registro ok. Ahora pulsa Entrar.")

func _estado(texto: String) -> void:
	estado_lbl.text = texto

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if usuario_edit.has_focus() or password_edit.has_focus():
			_on_entrar()
	if event.is_action_pressed("cerrar"):
		get_tree().quit()
