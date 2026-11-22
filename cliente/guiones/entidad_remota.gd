# entidad_remota.gd — gestiona las entidades remotas (mobs y otros jugadores).
#
# El nodo "Entidades" en mundo.tscn tiene este script. Recibe la lista de
# entidades del snapshot y:
#   - Crea nodos nuevos para las que no conoce.
#   - Actualiza posición/HP/nombre de las existentes.
#   - Elimina las que ya no están en el snapshot.
#
# Cada entidad se renderiza como un MeshInstance3D con una Label3D arriba
# mostrando nombre y HP. En el MVP usamos primitivas: cápsula para jugadores
# (color rojo/azul según facción) y caja para mobs (color gris/marrón).
extends Node3D

var _entidades: Dictionary = {}  # id → Node3D

func sincronizar(snapshots: Array) -> void:
	var ids_vistas: Dictionary = {}
	for e in snapshots:
		var id = e.get("id", "")
		if id.is_empty():
			continue
		ids_vistas[id] = true
		if _entidades.has(id):
			_actualizar_nodo(_entidades[id], e)
		else:
			var nodo = _crear_nodo(e)
			_entidades[id] = nodo
			add_child(nodo)
			_actualizar_nodo(nodo, e)

	# Eliminar las que ya no están.
	var a_borrar: Array = []
	for id in _entidades.keys():
		if not ids_vistas.has(id):
			_entidades[id].queue_free()
			a_borrar.append(id)
	for id in a_borrar:
		_entidades.erase(id)

func _crear_nodo(e: Dictionary) -> Node3D:
	var nodo = Node3D.new()
	nodo.name = e.get("id", "ent")
	var es_jugador = bool(e.get("es_jugador", false))
	nodo.set_meta("es_jugador", es_jugador)
	nodo.set_meta("id", e.get("id", ""))

	# Cuerpo: cápsula para jugadores, caja para mobs.
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = "Cuerpo"
	if es_jugador:
		var mesh = CapsuleMesh.new()
		mesh.radius = 0.4
		mesh.height = 1.6
		mesh_inst.mesh = mesh
		# Material rojo para otros jugadores.
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 0.5, 0.9, 1)
		mesh_inst.material_override = mat
	else:
		var mesh = BoxMesh.new()
		mesh.size = Vector2(1.0, 1.0)
		mesh_inst.mesh = mesh
		# Material marrón para mobs.
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.5, 0.3, 0.2, 1)
		mesh_inst.material_override = mat
	nodo.add_child(mesh_inst)

	# Label3D con nombre y HP.
	var label = Label3D.new()
	label.name = "Etiqueta"
	label.position = Vector3(0, 2.0, 0)
	label.billboard = 1
	label.no_depth_test = true
	label.font_size = 32
	label.modulate = Color(1, 1, 1, 0.9)
	nodo.add_child(label)

	return nodo

func _actualizar_nodo(nodo: Node3D, e: Dictionary) -> void:
	var pos_dict = e.get("pos", {})
	nodo.global_position = Vector3(
		float(pos_dict.get("x", 0)),
		float(pos_dict.get("y", 0)),
		float(pos_dict.get("z", 0))
	)
	# Rotación (quaternion).
	var rot_dict = e.get("rot", {})
	if rot_dict.has("w"):
		nodo.quaternion = Quaternion(
			float(rot_dict.get("x", 0)),
			float(rot_dict.get("y", 0)),
			float(rot_dict.get("z", 0)),
			float(rot_dict.get("w", 1))
		)

	var nombre = e.get("nombre", "?")
	var hp_actual = int(e.get("hp_actual", 0))
	var hp_max = int(e.get("hp_max", 1))
	var nivel = int(e.get("nivel", 1))
	var label = nodo.get_node("Etiqueta") as Label3D
	if label:
		var vivo = hp_actual > 0
		var texto = "%s (nv %d)\n%d/%d" % [nombre, nivel, hp_actual, hp_max]
		if not vivo:
			texto = "%s (nv %d)\n— MUERTO —" % [nombre, nivel]
		label.text = texto
		label.modulate = Color(1, 0.4, 0.4, 1) if not vivo else Color(1, 1, 1, 0.9)

	# Escala grisácea al morir.
	var mesh_inst = nodo.get_node("Cuerpo") as MeshInstance3D
	if mesh_inst:
		var vivo = hp_actual > 0
		var mat = mesh_inst.material_override as StandardMaterial3D
		if mat:
			if vivo:
				mat.albedo_color = mat.albedo_color.linear_to_srgb()
			else:
				mat.albedo_color = Color(0.3, 0.3, 0.3, 0.5)

func limpiar() -> void:
	for id in _entidades.keys():
		_entidades[id].queue_free()
	_entidades.clear()

func obtener_entidad(id: String) -> Node3D:
	return _entidades.get(id, null)
