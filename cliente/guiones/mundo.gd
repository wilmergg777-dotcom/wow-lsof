# mundo.gd — controla la escena 3D del mundo.
#
# Responsabilidades:
#   - Escuchar mensajes del servidor (snapshots, daño, muerte, buffs).
#   - Sincronizar entidades remotas via el nodo Entidades.
#   - Actualizar el HUD con el estado del personaje.
#   - Reconciliar la posición del jugador local con el servidor.
#   - Mostrar eventos de combate (números de daño, muertes).
extends Node3D

@onready var jugador: CharacterBody3D = $Jugador
@onready var entidades: Node3D = $Entidades
@onready var hud: CanvasLayer = $HUD

var _objetivo_actual: String = ""
var _auto_ataque_activo: bool = false
var _personaje_cargado: bool = false

# IDs de habilidades por slot. Se setean cuando llega el primer snapshot
# con cooldowns, o por defecto según la clase.
var _slots_habilidad: Array = ["golpe_heroico", "grito_guerra"]

func _ready() -> void:
	Red.mensaje_recibido.connect(_on_mensaje)
	Red.desconectado.connect(_on_desconectado)
	# El personaje_propio vino en el sel_resp antes de cargar esta escena.
	# Como el autoload Red guarda el último mensaje, lo podemos consultar.
	var propio = Red.ultimo_personaje_propio
	if propio.is_empty():
		# Si no lo tenemos, esperamos al primer snapshot.
		pass
	else:
		_cargar_personaje(propio)
	# Configurar slots del HUD.
	hud.set_slots(_slots_habilidad[0], _slots_habilidad[1])

func _cargar_personaje(propio: Dictionary) -> void:
	if _personaje_cargado:
		return
	_personaje_cargado = true
	var nombre = propio.get("nombre", "—")
	jugador.set_nombre(nombre)
	hud.set_nombre_pj(nombre)
	var clase = propio.get("clase", "guerrero")
	if clase == "mago":
		_slots_habilidad = ["flecha_de_hielo", "nova_de_escarcha"]
	hud.set_slots(_slots_habilidad[0], _slots_habilidad[1])

func _on_mensaje(msg: Dictionary) -> void:
	var tipo = msg.get("tipo", "")
	match tipo:
		"snapshot":
			_procesar_snapshot(msg)
		"dano":
			_procesar_dano(msg)
		"muerte":
			_procesar_muerte(msg)
		"respawn":
			hud.mostrar_mensaje("Has reaparecido.", 2.0)
		"buff":
			hud.mostrar_mensaje("Buff activo: %s" % msg.get("mensaje", ""), 2.0)
		"curacion":
			hud.mostrar_mensaje("+%d HP" % int(msg.get("cantidad", 0)), 1.5)
		"error":
			hud.mostrar_mensaje(msg.get("mensaje", "error"), 2.0)

func _procesar_snapshot(msg: Dictionary) -> void:
	if not _personaje_cargado:
		# Tomar el primer snapshot como señal de que estamos en el mundo.
		_personaje_cargado = true
	var entidades_arr = msg.get("entidades", [])
	entidades.sincronizar(entidades_arr)
	var estado = msg.get("estado_pj", {})
	if estado.is_empty():
		return
	hud.actualizar_estado(estado)
	# Reconciliar posición.
	var pos_dict = estado.get("pos", {})
	if pos_dict.has("x"):
		jugador.reconciliar_pos(Vector3(
			float(pos_dict.x), float(pos_dict.y), float(pos_dict.z)))
	# Actualizar objetivo.
	var obj_id = estado.get("objetivo_id", "")
	_objetivo_actual = obj_id
	if obj_id.is_empty():
		hud.ocultar_objetivo()
	else:
		var nodo = entidades.obtener_entidad(obj_id)
		if nodo:
			var label = nodo.get_node("Etiqueta") as Label3D
			var nombre = label.text.split("\n")[0] if label else "?"
			# Buscar HP del snapshot.
			var hp_actual = 0
			var hp_max = 1
			for e in entidades_arr:
				if e.get("id", "") == obj_id:
					hp_actual = int(e.get("hp_actual", 0))
					hp_max = int(e.get("hp_max", 1))
					nombre = e.get("nombre", nombre)
					break
			hud.mostrar_objetivo(obj_id, nombre, hp_actual, hp_max)
		else:
			hud.ocultar_objetivo()
	# Auto-ataque desde el estado del servidor.
	_auto_ataque_activo = bool(estado.get("auto_ataque_activo", false))

func _procesar_dano(msg: Dictionary) -> void:
	var cantidad = int(msg.get("cantidad", 0))
	var critico = bool(msg.get("critico", false))
	var txt = "-%d" % cantidad
	if critico:
		txt += "!"
	hud.mostrar_mensaje(txt, 0.8)

func _procesar_muerte(msg: Dictionary) -> void:
	var eid = msg.get("entidad_id", "")
	if eid == jugador.name:
		# La muerte del propio jugador la maneja el HUD via estado.muerto.
		return
	# Si era nuestro objetivo, mostrar mensaje.
	if eid == _objetivo_actual:
		hud.mostrar_mensaje("Objetivo eliminado.", 2.0)

func _on_desconectado(motivo: String) -> void:
	hud.mostrar_mensaje("Desconectado: %s" % motivo, 5.0)
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://escenas/pantalla_login.tscn")

# ─── API pública para jugador.gd ─────────────────────────────────────────

func hud_node() -> CanvasLayer:
	return hud

func objetivo_actual() -> String:
	return _objetivo_actual

func auto_ataque_activo() -> bool:
	return _auto_ataque_activo

func set_auto_ataque_activo(activo: bool) -> void:
	_auto_ataque_activo = activo
