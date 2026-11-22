# seleccion.gd — pantalla de selección y creación de personaje.
#
# Recibe la lista de personajes del servidor (vía login_resp o lista_pj),
# muestra sus nombres en una ItemList, y permite:
#   - Jugar: enviar sel_pj con el personaje seleccionado.
#   - Volver al login: logout y volver a pantalla_login.tscn.
#   - Crear: enviar crear_pj con nombre, facción, raza y clase.
#
# Los selectores de facción/raza/clase se pueblan dinámicamente desde el
# caché de Red (facciones/razas/clases_disponibles, llegan en login_resp).
# La raza depende de la facción elegida; la clase depende de la raza
# (matriz raza-clase de WoW 3.3.5, validada también en el servidor).
extends Control

@onready var lista: ItemList = $Centro/Panel/Margen/VBox/ListaPersonajes
@onready var nombre_edit: LineEdit = $Centro/Panel/Margen/VBox/FilaCrear/Nombre
@onready var faccion_opt: OptionButton = $Centro/Panel/Margen/VBox/FilaCrear/Faccion
@onready var raza_opt: OptionButton = $Centro/Panel/Margen/VBox/FilaCrear/Raza
@onready var clase_opt: OptionButton = $Centro/Panel/Margen/VBox/FilaCrear/Clase
@onready var estado_lbl: Label = $Centro/Panel/Margen/VBox/Estado

var _personajes: Array = []  # Array de dicts {nombre, clase, nivel}

# Mapeo nombre mostrado → ID, para los selectores.
var _faccion_ids: Array = []   # paralelo a faccion_opt
var _raza_ids: Array = []      # paralelo a raza_opt (razas de la facción actual)
var _clase_ids: Array = []     # paralelo a clase_opt (clases de la raza actual)

func _ready() -> void:
	Red.mensaje_recibido.connect(_on_mensaje)
	_estado("Selecciona un personaje o crea uno nuevo.")
	lista.grab_focus()
	# Conectar señales de cambio de selección para repoblar dependencias.
	if faccion_opt.item_selected.is_connected(_on_faccion_cambio) == false:
		faccion_opt.item_selected.connect(_on_faccion_cambio)
	if raza_opt.item_selected.is_connected(_on_raza_cambio) == false:
		raza_opt.item_selected.connect(_on_raza_cambio)
	# Poblar selectores desde el caché de Red.
	_poblar_facciones()

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
			_poblar_facciones()

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

# ─── Poblado dinámico de selectores ───────────────────────────────────────

func _poblar_facciones() -> void:
	faccion_opt.clear()
	_faccion_ids.clear()
	var facs = Red.facciones_disponibles
	if facs.is_empty():
		# Fallback si no hay caché todavía.
		facs = [{"id": "alianza", "nombre": "Alianza"}, {"id": "horda", "nombre": "Horda"}]
	for f in facs:
		faccion_opt.add_item(f.get("nombre", "?"))
		_faccion_ids.append(f.get("id", ""))
	faccion_opt.selected = 0
	_on_faccion_cambio(0)

func _on_faccion_cambio(_idx: int) -> void:
	if faccion_opt.selected < 0 or faccion_opt.selected >= _faccion_ids.size():
		return
	var faccion_id = _faccion_ids[faccion_opt.selected]
	# Filtrar razas de esta facción.
	raza_opt.clear()
	_raza_ids.clear()
	for r in Red.razas_disponibles:
		if r.get("faccion", "") == faccion_id:
			raza_opt.add_item(r.get("nombre", "?"))
			_raza_ids.append(r.get("id", ""))
	if _raza_ids.is_empty():
		# Fallback: todas las razas (por si el caché está vacío).
		for r in _razas_fallback(faccion_id):
			raza_opt.add_item(r["nombre"])
			_raza_ids.append(r["id"])
	raza_opt.selected = 0
	_on_raza_cambio(0)

func _on_raza_cambio(_idx: int) -> void:
	if raza_opt.selected < 0 or raza_opt.selected >= _raza_ids.size():
		return
	var raza_id = _raza_ids[raza_opt.selected]
	# Buscar la raza en el caché para obtener sus clases permitidas.
	var clases_permitidas: Array = []
	for r in Red.razas_disponibles:
		if r.get("id", "") == raza_id:
			clases_permitidas = r.get("clases", [])
			break
	if clases_permitidas.is_empty():
		# Fallback: todas las clases conocidas.
		clases_permitidas = ["guerrero", "paladin", "cazador", "picaro", "sacerdote", "mago", "brujo"]
	# Poblar clase_opt con las clases permitidas, usando el nombre del caché.
	clase_opt.clear()
	_clase_ids.clear()
	for cid in clases_permitidas:
		var nombre = _nombre_clase(cid)
		clase_opt.add_item(nombre)
		_clase_ids.append(cid)
	clase_opt.selected = 0

# _nombre_clase busca el nombre legible de una clase en el caché.
func _nombre_clase(cid: String) -> String:
	for c in Red.clases_disponibles:
		if c.get("id", "") == cid:
			return c.get("nombre", cid)
	# Fallback de nombres conocidos.
	match cid:
		"guerrero": return "Guerrero"
		"paladin": return "Paladín"
		"cazador": return "Cazador"
		"picaro": return "Pícaro"
		"sacerdote": return "Sacerdote"
		"mago": return "Mago"
		"brujo": return "Brujo"
	return cid

# _razas_fallback devuelve razas hardcodeadas por facción (por si el caché
# de Red está vacío al cargar la pantalla).
func _razas_fallback(faccion_id: String) -> Array:
	if faccion_id == "horda":
		return [
			{"id": "orco", "nombre": "Orco"},
			{"id": "no_muerto", "nombre": "Renegado"},
			{"id": "tauren", "nombre": "Tauren"},
			{"id": "troll", "nombre": "Troll"},
			{"id": "elfo_de_sangre", "nombre": "Elfo de Sangre"},
		]
	return [
		{"id": "humano", "nombre": "Humano"},
		{"id": "enano", "nombre": "Enano"},
		{"id": "elfo_nocturno", "nombre": "Elfo Nocturno"},
		{"id": "gnomo", "nombre": "Gnomo"},
		{"id": "draenei", "nombre": "Draenei"},
	]

# ─── Acciones ────────────────────────────────────────────────────────────

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
	if faccion_opt.selected < 0 or raza_opt.selected < 0 or clase_opt.selected < 0:
		_estado("Selecciona facción, raza y clase.")
		return
	var faccion_id = _faccion_ids[faccion_opt.selected]
	var raza_id = _raza_ids[raza_opt.selected]
	var clase_id = _clase_ids[clase_opt.selected]
	Red.enviar_crear_pj(nombre, clase_id, faccion_id, raza_id)
	_estado("Creando %s (%s %s, %s)…" % [nombre, raza_opt.get_item_text(raza_opt.selected), clase_opt.get_item_text(clase_opt.selected), faccion_opt.get_item_text(faccion_opt.selected)])

func _on_logout() -> void:
	Red.enviar_logout()
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
