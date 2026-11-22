# jugador.gd — controla el personaje local del jugador.
#
# Movimiento: WASD relativo a la cámara. Cuerpo CharacterBody3D.
# Cámara: tercera persona, orbita con el mouse (capturado).
# Combate: Tab para targetear el mob más cercano, 1/2 para habilidades,
#          T para auto-ataque on/off.
# Sincronización: envía posición al servidor a 10 Hz; reconcilia con
#                 EstadoPJ.Pos del snapshot si la diferencia es grande.
extends CharacterBody3D

const VELOCIDAD: float = 7.0          # m/s
const VELOCIDAD_ROTACION: float = 12.0 # rad/s suavizado
const INTERVALO_ENVIO_MS: int = 100    # 10 Hz
const UMBRAL_RECONCILIACION: float = 3.0 # metros

var _ultimo_envio_ms: int = 0
var _yaw_camara: float = 0.0
var _pitch_camara: float = -0.4
var _rig_camara: Node3D
var _camara: Camera3D
var _label_nombre: Label3D

func _ready() -> void:
	_rig_camara = $RigCamara
	_camara = $RigCamara/SpringArm/Camara
	_label_nombre = $Nombre3D
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# El nombre se setea desde mundo.gd cuando llega el sel_resp.
	_label_nombre.text = ""

func set_nombre(nombre: String) -> void:
	_label_nombre.text = nombre

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw_camara -= event.relative.x * 0.005
		_pitch_camara = clamp(_pitch_camara - event.relative.y * 0.005, -1.2, -0.05)
		_aplicar_rotacion_camara()
	if event.is_action_pressed("cerrar"):
		# Liberar mouse para que el usuario pueda cerrar la ventana.
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _aplicar_rotacion_camara() -> void:
	_rig_camara.rotation = Vector3(_pitch_camara, _yaw_camara, 0)

func _physics_process(_delta: float) -> void:
	# Vector de entrada WASD relativo a la cámara.
	var input_dir = Vector2.ZERO
	if Input.is_action_pressed("mover_adelante"):
		input_dir.y -= 1
	if Input.is_action_pressed("mover_atras"):
		input_dir.y += 1
	if Input.is_action_pressed("mover_izquierda"):
		input_dir.x -= 1
	if Input.is_action_pressed("mover_derecha"):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	# Dirección 3D relativa al yaw de la cámara.
	var forward = Vector3(sin(_yaw_camara), 0, cos(_yaw_camara)).normalized()
	var right = Vector3(forward.z, 0, -forward.x)
	var dir_3d = (forward * -input_dir.y + right * input_dir.x)

	velocity = dir_3d * VELOCIDAD
	if dir_3d.length() > 0.01:
		# Rotar el cuerpo hacia la dirección de movimiento.
		var angulo_objetivo = atan2(dir_3d.x, dir_3d.z)
		rotation.y = lerp_angle(rotation.y, angulo_objetivo, VELOCIDAD_ROTACION * _delta)
	move_and_slide()

	# Enviar posición al servidor a 10 Hz.
	var ahora_ms = Time.get_ticks_msec()
	if ahora_ms - _ultimo_envio_ms >= INTERVALO_ENVIO_MS:
		Red.enviar_movimiento(global_position, Quaternion.from_euler(rotation))
		_ultimo_envio_ms = ahora_ms

	# Inputs de combate.
	if Input.is_action_just_pressed("targetear"):
		_targetear_cercano()
	if Input.is_action_just_pressed("habilidad_1"):
		_cast_habilidad(0)
	if Input.is_action_just_pressed("habilidad_2"):
		_cast_habilidad(1)
	if Input.is_action_just_pressed("auto_ataque"):
		_toggle_auto_ataque()

func reconciliar_pos(pos_servidor: Vector3) -> void:
	var d = global_position.distance_to(pos_servidor)
	if d > UMBRAL_RECONCILIACION:
		global_position = pos_servidor

func _targetear_cercano() -> void:
	# Buscar la entidad enemiga más cercana en el nodo Entidades.
	var entidades_node = get_node("../Entidades")
	var mejor_id = ""
	var mejor_dist = INF
	for hijo in entidades_node.get_children():
		if hijo.has_meta("es_jugador") and hijo.get_meta("es_jugador"):
			continue
		var d = global_position.distance_to(hijo.global_position)
		if d < mejor_dist:
			mejor_dist = d
			mejor_id = hijo.get_meta("id", "")
	if not mejor_id.is_empty():
		Red.enviar_cambiar_objetivo(mejor_id)

func _cast_habilidad(slot_idx: int) -> void:
	var mundo_node = get_node("../")
	var slots = mundo_node.hud_node().slot_habilidades
	if slot_idx >= slots.size() or slots[slot_idx].is_empty():
		return
	var objetivo = mundo_node.objetivo_actual()
	Red.enviar_habilidad(slots[slot_idx], objetivo)

func _toggle_auto_ataque() -> void:
	var mundo_node = get_node("../")
	var activo = not mundo_node.auto_ataque_activo()
	mundo_node.set_auto_ataque_activo(activo)
	Red.enviar_auto_ataque(activo)
