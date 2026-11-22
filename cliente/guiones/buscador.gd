# buscador.gd — panel del buscador de masmorras (PvE) y arenas (PvP).
#
# Se instancia como hijo del HUD. Se muestra/oculta con la tecla B.
# Muestra las masmorras y arenas disponibles (caché en Red tras sel_resp),
# permite unirse/salir de la cola, y refleja el estado de la cola y los
# matches recibidos.
extends Control

var _panel: PanelContainer
var _estado_lbl: Label
var _contenedor_masmoras: VBoxContainer
var _contenedor_arenas: VBoxContainer
var _btn_salir_cola: Button

# Cachés locales de defs (vienen en sel_resp, se guardan en Red).
var _masmoras: Array = []  # [{id, nombre, nivel_min, tamano_grupo}]
var _arenas: Array = []    # [{id, nombre, tamano_equipo}]
var _en_cola: bool = false

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_construir_ui()
	Red.mensaje_recibido.connect(_on_mensaje)
	_masmoras = Red.masmoras_disponibles
	_arenas = Red.arenas_disponibles
	_poblar_listas()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			visible = not visible
			if visible:
				_estado("Abre el panel con B para alternar.")
		elif event.keycode == KEY_ESCAPE and visible:
			visible = false

func _construir_ui() -> void:
	# Fondo semi-transparente que cubre toda la pantalla.
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.55)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var centro = CenterContainer.new()
	centro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(centro)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(560, 0)
	centro.add_child(_panel)

	var margen = MarginContainer.new()
	margen.add_theme_constant_override("margin_left", 20)
	margen.add_theme_constant_override("margin_top", 20)
	margen.add_theme_constant_override("margin_right", 20)
	margen.add_theme_constant_override("margin_bottom", 20)
	_panel.add_child(margen)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margen.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "BUSCADOR DE MASMORRAS Y ARENAS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 20)
	vbox.add_child(titulo)

	var sub = Label.new()
	sub.text = "Cross-facción: tu grupo puede mezclar Forjasol y Lunagris."
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 12)
	vbox.add_child(sub)

	# Sección masmorras.
	var lbl_pve = Label.new()
	lbl_pve.text = "Masmorras (PvE)"
	vbox.add_child(lbl_pve)
	_contenedor_masmoras = VBoxContainer.new()
	_contenedor_masmoras.add_theme_constant_override("separation", 6)
	vbox.add_child(_contenedor_masmoras)

	vbox.add_child(HSeparator.new())

	# Sección arenas.
	var lbl_pvp = Label.new()
	lbl_pvp.text = "Arenas (PvP)"
	vbox.add_child(lbl_pvp)
	_contenedor_arenas = VBoxContainer.new()
	_contenedor_arenas.add_theme_constant_override("separation", 6)
	vbox.add_child(_contenedor_arenas)

	vbox.add_child(HSeparator.new())

	_btn_salir_cola = Button.new()
	_btn_salir_cola.text = "Salir de la cola"
	_btn_salir_cola.pressed.connect(_on_salir_cola)
	vbox.add_child(_btn_salir_cola)

	_estado_lbl = Label.new()
	_estado_lbl.text = "Pulsa B para abrir/cerrar este panel."
	_estado_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_estado_lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	vbox.add_child(_estado_lbl)

	var cerrar = Button.new()
	cerrar.text = "Cerrar (B)"
	cerrar.pressed.connect(func(): visible = false)
	vbox.add_child(cerrar)

func _poblar_listas() -> void:
	for c in _contenedor_masmoras.get_children():
		c.queue_free()
	for c in _contenedor_arenas.get_children():
		c.queue_free()
	if _masmoras.is_empty() and _arenas.is_empty():
		_estado("No hay masmorras/arenas disponibles (¿conectado?).")
		return
	for m in _masmoras:
		_contenedor_masmoras.add_child(_fila_masmora(m))
	for a in _arenas:
		_contenedor_arenas.add_child(_fila_arena(a))

func _fila_masmora(m: Dictionary) -> Control:
	var fila = HBoxContainer.new()
	fila.add_theme_constant_override("separation", 8)
	var info = Label.new()
	info.text = "%s  (nivel min %d, grupo %d)" % [m.get("nombre", "?"), int(m.get("nivel_min", 1)), int(m.get("tamano_grupo", 3))]
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(info)
	var btn = Button.new()
	btn.text = "Unirse"
	var mid = m.get("id", "")
	btn.pressed.connect(func(): _on_unirse_pve(mid))
	fila.add_child(btn)
	return fila

func _fila_arena(a: Dictionary) -> Control:
	var fila = HBoxContainer.new()
	fila.add_theme_constant_override("separation", 8)
	var info = Label.new()
	info.text = "%s  (%dv%d)" % [a.get("nombre", "?"), int(a.get("tamano_equipo", 2)), int(a.get("tamano_equipo", 2))]
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(info)
	var btn = Button.new()
	btn.text = "Unirse"
	var aid = a.get("id", "")
	btn.pressed.connect(func(): _on_unirse_pvp(aid))
	fila.add_child(btn)
	return fila

func _on_unirse_pve(masmora_id: String) -> void:
	Red.enviar_cola_pve_entrar(masmora_id)
	_estado("Encolando para %s…" % masmora_id)

func _on_unirse_pvp(arena_id: String) -> void:
	Red.enviar_cola_pvp_entrar(arena_id)
	_estado("Encolando para %s…" % arena_id)

func _on_salir_cola() -> void:
	Red.enviar_cola_pve_salir()
	Red.enviar_cola_pvp_salir()
	_estado("Has salido de la cola.")

func _on_mensaje(msg: Dictionary) -> void:
	var tipo = msg.get("tipo", "")
	match tipo:
		"cola_estado":
			_procesar_cola_estado(msg)
		"buscador_match":
			_procesar_match(msg)
		"instancia_fin":
			_procesar_fin(msg)

func _procesar_cola_estado(msg: Dictionary) -> void:
	_en_cola = bool(msg.get("en_cola", false))
	if not _en_cola:
		_estado("Fuera de cola.")
		return
	var t = int(msg.get("tiempo_cola_ms", 0))
	var n = int(msg.get("jugadores_en_cola", 0))
	var destino = msg.get("mensaje", "")
	_estado("En cola (%s): %d jugador(es), %.0fs" % [destino, n, t / 1000.0])

func _procesar_match(msg: Dictionary) -> void:
	var destino = msg.get("mensaje", "")
	var tipo_inst = msg.get("instancia_tipo", "")
	var grupo = msg.get("grupo", [])
	var eq = int(msg.get("equipo", -1))
	var eq_txt = "" if eq < 0 else " (equipo %d)" % (eq + 1)
	_estado("¡Match encontrado! %s%s — grupo: %s" % [destino, eq_txt, ", ".join(grupo)])
	visible = false

func _procesar_fin(msg: Dictionary) -> void:
	var res = msg.get("resultado", "")
	var razon = msg.get("razon", "")
	_estado("Instancia terminada: %s (%s)" % [res, razon])

func _estado(texto: String) -> void:
	if _estado_lbl:
		_estado_lbl.text = texto
