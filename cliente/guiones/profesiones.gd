# profesiones.gd — panel de profesiones y crafteo.
#
# Muestra las profesiones conocidas (con barra de habilidad y botón para
# aprender el siguiente rango), permite aprender una profesión nueva, y
# lista las recetas crafteables con sus materiales (tener/necesario) y un
# botón Craftear. Se refresca al llegar craftear_resp / aprendido_resp.
extends Control

var _vbox: VBoxContainer
var _recetas_box: VBoxContainer

func _ready() -> void:
	_build_ui()
	Red.mensaje_recibido.connect(_on_mensaje)
	# Refrescar cuando entre al mundo (sel_resp ya llegó) o al abrir.
	call_deferred("refrescar")

func _build_ui() -> void:
	# Fondo.
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var marg = MarginContainer.new()
	marg.set_anchors_preset(Control.PRESET_FULL_RECT)
	marg.add_theme_constant_override("margin_left", 16)
	marg.add_theme_constant_override("margin_right", 16)
	marg.add_theme_constant_override("margin_top", 16)
	marg.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(marg)

	_vbox = VBoxContainer.new()
	marg.add_child(_vbox)

	# Cabecera.
	var head = HBoxContainer.new()
	var titulo = Label.new()
	titulo.text = "Profesiones"
	titulo.add_theme_font_size_override("font_size", 22)
	titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(titulo)
	var cerrar = Button.new()
	cerrar.text = "Cerrar (P)"
	cerrar.pressed.connect(_on_cerrar)
	head.add_child(cerrar)
	_vbox.add_child(head)

	# Sección profesiones (conocidas + aprender).
	var prof_label = Label.new()
	prof_label.text = "Tus profesiones"
	prof_label.add_theme_font_size_override("font_size", 16)
	_vbox.add_child(prof_label)

	var sep = HSeparator.new()
	_vbox.add_child(sep)

	# Sección recetas.
	var rec_label = Label.new()
	rec_label.text = "Recetas"
	rec_label.add_theme_font_size_override("font_size", 16)
	_vbox.add_child(rec_label)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_child(scroll)
	_recetas_box = VBoxContainer.new()
	_recetas_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_recetas_box)

func _on_mensaje(msg: Dictionary) -> void:
	var tipo = msg.get("tipo", "")
	if tipo == "craftear_resp" or tipo == "aprendido_resp" or tipo == "sel_resp":
		refrescar()
		if tipo == "craftear_resp":
			var c = msg.get("crafteo", {})
			if not c.get("ok", false):
				# Mostrar error brevemente como un Label temporal.
				_mostrar_error(c.get("error", "error al craftear"))

func _mostrar_error(texto: String) -> void:
	var l = Label.new()
	l.text = "⚠ " + texto
	l.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	_recetas_box.add_child(l)
	# Quitarlo tras 2.5s.
	get_tree().create_timer(2.5).timeout.connect(func(): if is_instance_valid(l): l.queue_free())

func refrescar() -> void:
	if _vbox == null:
		return
	_reconstruir()

# _reconstruir vuelve a poblar la sección de profesiones y recetas.
func _reconstruir() -> void:
	# Borrar todos los hijos de _vbox salvo la cabecera (índice 0).
	var hijos = _vbox.get_children()
	for i in range(1, hijos.size()):
		hijos[i].queue_free()
	# Borrar recetas.
	for c in _recetas_box.get_children():
		c.queue_free()
	# Esperar un frame para que se liberen... en su lugar, reconstruimos
	# sobre un contenedor nuevo para evitar conflictos de nodo libre.
	# Re-añadimos etiquetas y secciones.
	var prof_label = Label.new()
	prof_label.text = "Tus profesiones"
	prof_label.add_theme_font_size_override("font_size", 16)
	_vbox.add_child(prof_label)
	_poblar_profesiones()
	var sep = HSeparator.new()
	_vbox.add_child(sep)
	var rec_label = Label.new()
	rec_label.text = "Recetas"
	rec_label.add_theme_font_size_override("font_size", 16)
	_vbox.add_child(rec_label)
	_poblar_recetas()

# _poblar_profesiones añade las filas de profesiones conocidas + aprender.
func _poblar_profesiones() -> void:
	var estados = Red.estado_profesiones
	var cat_prof = Red.profesiones_disponibles
	if estados.is_empty():
		var l = Label.new()
		l.text = "No conoces ninguna profesión."
		l.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		_vbox.add_child(l)
		# Botones para aprender profesiones primarias disponibles.
		for p in cat_prof:
			if p.get("primaria", false):
				_fila_aprender_profesion(p)
		return
	for e in estados:
		_fila_profesion_conocida(e, cat_prof)

func _fila_aprender_profesion(p: Dictionary) -> void:
	var fila = HBoxContainer.new()
	var lbl = Label.new()
	lbl.text = "Aprender " + p.get("nombre", "?")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(lbl)
	var btn = Button.new()
	btn.text = "Aprender"
	btn.pressed.connect(func(): Red.enviar_aprender_profesion(p.get("id", "")))
	fila.add_child(btn)
	_vbox.add_child(fila)

func _fila_profesion_conocida(e: Dictionary, cat_prof: Array) -> void:
	var pid = e.get("profesion_id", "")
	var skill = e.get("skill", 0)
	var smax = e.get("skill_max", 0)
	var nombre = pid
	var rangos: Array = []
	var especializaciones: Array = []
	for p in cat_prof:
		if p.get("id", "") == pid:
			nombre = p.get("nombre", pid)
			rangos = p.get("rangos", [])
			especializaciones = p.get("especializaciones", [])
			break
	var fila = HBoxContainer.new()
	var lbl = Label.new()
	var esp_actual = e.get("especializacion", "")
	if esp_actual != "":
		lbl.text = "%s — %d / %d  [%s]" % [nombre, skill, smax, _nombre_especializacion(esp_actual, especializaciones)]
	else:
		lbl.text = "%s — %d / %d" % [nombre, skill, smax]
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(lbl)
	# Barra de progreso simple.
	var bar = ProgressBar.new()
	bar.min_value = 0
	bar.max_value = smax if smax > 0 else 1
	bar.value = skill
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(bar)
	# Botón aprender siguiente rango (el primero cuyo skill_req <= skill
	# y que no esté aprendido).
	var aprendidos: Array = e.get("rangos_aprendidos", [])
	for rg in rangos:
		var rid = rg.get("id", "")
		if rid in aprendidos:
			continue
		if skill >= rg.get("skill_req", 999):
			var btn = Button.new()
			btn.text = "Aprender " + rg.get("nombre", rid)
			btn.pressed.connect(func(): Red.enviar_aprender_rango(pid, rid))
			fila.add_child(btn)
			break
	_vbox.add_child(fila)
	# Especializaciones: si la profesión las tiene y el PJ no tiene ninguna,
	# mostrar las opciones a partir de skill_req (225). Si ya tiene una,
	# no se ofrecen más (solo se permite una).
	if especializaciones.is_empty():
		return
	var inv = _inv_map()
	for esp in especializaciones:
		var eid = esp.get("id", "")
		var req_esp = esp.get("skill_req", 225)
		if skill < req_esp:
			continue
		var efila = HBoxContainer.new()
		var elbl = Label.new()
		var mats_txt = ""
		var tiene = true
		for m in esp.get("materiales", []):
			var mid = m.get("item_id", "")
			var need = m.get("cantidad", 0)
			var have = inv.get(mid, 0)
			if have < need:
				tiene = false
			mats_txt += "%s (%d/%d)  " % [_nombre_item(mid), have, need]
		if esp_actual != "":
			if esp_actual == eid:
				elbl.text = "  ✓ " + esp.get("nombre", eid) + " (aprendida)"
				elbl.add_theme_color_override("font_color", Color(0.4, 1, 0.4))
			else:
				continue  # ya elegida otra; no mostrar
		else:
			elbl.text = "  " + esp.get("nombre", eid) + " — " + esp.get("descripcion", "") + "  [" + mats_txt + "]"
			elbl.add_theme_color_override("font_color",
				Color(0.4, 1, 0.4) if tiene else Color(0.7, 0.7, 0.7))
		elbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		efila.add_child(elbl)
		if esp_actual == "":
			var ebtn = Button.new()
			ebtn.text = "Elegir"
			ebtn.disabled = not tiene
			ebtn.pressed.connect(func(): Red.enviar_aprender_especializacion(pid, eid))
			efila.add_child(ebtn)
		_vbox.add_child(efila)

# _nombre_especializacion busca el nombre legible de una especialización.
func _nombre_especializacion(eid: String, especializaciones: Array) -> String:
	for esp in especializaciones:
		if esp.get("id", "") == eid:
			return esp.get("nombre", eid)
	return eid

# _poblar_recetas llena la lista de recetas de las profesiones conocidas.
func _poblar_recetas() -> void:
	var estados = Red.estado_profesiones
	var conocidas: Array = []
	for e in estados:
		conocidas.append(e.get("profesion_id", ""))
	var inv = _inv_map()
	for rc in Red.recetas_disponibles:
		var pid = rc.get("profesion_id", "")
		if pid not in conocidas:
			continue
		var skill = _skill_de(pid)
		var smax = _skillmax_de(pid)
		var req = rc.get("skill_req", 0)
		var craftable = skill >= req
		var tiene_mats = true
		var mats_txt = ""
		for m in rc.get("materiales", []):
			var mid = m.get("item_id", "")
			var need = m.get("cantidad", 0)
			var have = inv.get(mid, 0)
			if have < need:
				tiene_mats = false
			mats_txt += "%s (%d/%d)  " % [_nombre_item(mid), have, need]
		var fila = HBoxContainer.new()
		var nombre = Label.new()
		var prefijo = "● " if (craftable and tiene_mats) else ("○ " if craftable else "✕ ")
		nombre.text = prefijo + rc.get("nombre", "?")
		nombre.add_theme_color_override("font_color",
			Color(0.4, 1, 0.4) if (craftable and tiene_mats) else
			(Color(1, 0.9, 0.3) if craftable else Color(0.5, 0.5, 0.5)))
		nombre.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(nombre)
		var mats_lbl = Label.new()
		mats_lbl.text = mats_txt
		mats_lbl.add_theme_font_size_override("font_size", 12)
		mats_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		fila.add_child(mats_lbl)
		var btn = Button.new()
		btn.text = "Craftear"
		btn.disabled = not (craftable and tiene_mats)
		var receta_id = rc.get("id", "")
		btn.pressed.connect(func(): Red.enviar_craftear(receta_id))
		fila.add_child(btn)
		_recetas_box.add_child(fila)

# _inv_map convierte Red.inventario (lista de {item_id,cantidad}) a un dict.
func _inv_map() -> Dictionary:
	var d = {}
	for st in Red.inventario:
		d[st.get("item_id", "")] = st.get("cantidad", 0)
	return d

# _skill_de devuelve la habilidad actual del PJ en una profesión.
func _skill_de(pid: String) -> int:
	for e in Red.estado_profesiones:
		if e.get("profesion_id", "") == pid:
			return e.get("skill", 0)
	return 0

func _skillmax_de(pid: String) -> int:
	for e in Red.estado_profesiones:
		if e.get("profesion_id", "") == pid:
			return e.get("skill_max", 0)
	return 0

# _nombre_item busca el nombre legible de un ítem en el catálogo.
func _nombre_item(item_id: String) -> String:
	for it in Red.items_disponibles:
		if it.get("id", "") == item_id:
			return it.get("nombre", item_id)
	return item_id

func _on_cerrar() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("abrir_profesiones"):
		visible = not visible
		if visible:
			refrescar()
	if event.is_action_pressed("cerrar") and visible:
		visible = false
