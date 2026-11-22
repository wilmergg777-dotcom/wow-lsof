# seleccion.gd — pantalla de selección y creación de personaje.
#
# Recibe la lista de personajes del servidor (vía login_resp o lista_pj),
# muestra sus nombres en una ItemList, y permite:
#   - Jugar: enviar sel_pj con el personaje seleccionado.
#   - Volver al login: logout y volver a pantalla_login.tscn.
#   - Crear: enviar crear_pj con nombre y clase; el servidor responde
#     lista_pj con la lista actualizada.
extends Control

@onready var lista: ItemList = $Centro/Panel/Margen/VBox/ListaPersonajes
@onready var nombre_edit: LineEdit = $Centro/Panel/Margen/VBox/FilaCrear/Nombre
@onready var clase_opt: OptionButton = $Centro/Panel/Margen/VBox/FilaCrear/Clase
@onready var faccion_opt: OptionButton = $Centro/Panel/Margen/VBox/FilaCrear/Faccion
@onready var estado_lbl: Label = $Centro/Panel/Margen/VBox/Estado

var _personajes: Array = []  # Array de dicts {nombre, clase, nivel}

func _ready() -> void:
	Red.mensaje_recibido.connect(_on_mensaje)
	# Si ya tenemos la lista del login, la mostramos.
	# Si no, el servidor no nos la manda de nuevo; el usuario puede crear.
	_estado("Selecciona un personaje o crea uno nuevo.")
	lista.grab_focus()

func _on_mensaje(msg: Dictionary) -> void:
	var tipo = msg.get("tipo", "")
	match tipo:
		"lista_pj":
			_refrescar_lista(msg.get("personajes", []))
		"sel_resp":
			_manejar_sel_resp(msg)
		"login_resp":
			# Si volvimos a esta pantalla tras logout, nos llegará un login_resp.
			_refrescar_lista(msg.get("personajes", []))

func _refrescar_lista(personajes: Array) -> void:
	_personajes = personajes
	lista.clear()
	for p in personajes:
		var texto = "%s — %s nivel %d" % [p.get("nombre", "?"), p.get("clase", "?"), p.get("nivel", 1)]
		lista.add_item(texto)
	if personajes.is_empty():
		_estado("No tienes personajes. Crea uno abajo.")
	else:
		_estado("%d personaje(s). Selecciona y pulsa Jugar." % personajes.size())

func _on_jugar() -> void:
	var idx = lista.get_selected_items()
	if idx.is_empty():
		_estado("Selecciona un personaje primero.")
		return
	var p = _personajes[idx[0]]
	var nombre = p.get("nombre", "")
	if nombre.is_empty():
		_estado("Personaje inválido.")
		return
	Red.enviar_sel_pj(nombre)
	_estado("Entrando al mundo como %s…" % nombre)

func _on_crear() -> void:
	var nombre = nombre_edit.text.strip_edges()
	if nombre.length() < 3 or nombre.length() > 16:
		_estado("El nombre debe tener 3-16 caracteres.")
		return
	var clase_texto = clase_opt.get_item_text(clase_opt.selected).to_lower()
	var clase_id = "guerrero"
	if clase_texto == "mago":
		clase_id = "mago"
	elif clase_texto == "sacerdote":
		clase_id = "sacerdote"
	var faccion_texto = faccion_opt.get_item_text(faccion_opt.selected).to_lower()
	var faccion_id = "forjasol"
	if faccion_texto == "lunagris":
		faccion_id = "lunagris"
	Red.enviar_crear_pj(nombre, clase_id, faccion_id)
	_estado("Creando %s (%s, %s)…" % [nombre, clase_texto, faccion_texto])

func _on_logout() -> void:
	Red.enviar_logout()
	# Esperar un frame a que el mensaje se envíe antes de cambiar de escena.
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://escenas/pantalla_login.tscn")

func _manejar_sel_resp(msg: Dictionary) -> void:
	if not msg.get("ok", false):
		_estado("No se pudo entrar: %s" % msg.get("error", "desconocido"))
		return
	var propio = msg.get("personaje_propio", {})
	_estado("Entrando como %s…" % propio.get("nombre", "?"))
	get_tree().change_scene_to_file("res://escenas/mundo.tscn")

func _estado(texto: String) -> void:
	estado_lbl.text = texto

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cerrar"):
		get_tree().quit()
