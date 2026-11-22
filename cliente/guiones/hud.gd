# hud.gd — Heads-Up Display: HP, energía, objetivo, barra de habilidades.
#
# Métodos públicos (llamados por mundo.gd al recibir snapshots):
#   actualizar_estado(estado: Dictionary)
#   mostrar_objetivo(id, nombre, hp_actual, hp_max)
#   ocultar_objetivo()
#   mostrar_mensaje(texto, duracion)
extends CanvasLayer

@onready var lbl_nombre_pj: Label = $Root/TopCentro/LblNombrePJ
@onready var barra_hp: ProgressBar = $Root/TopCentro/BarraHP
@onready var lbl_hp: Label = $Root/TopCentro/LblHP
@onready var barra_energia: ProgressBar = $Root/TopCentro/BarraEnergia
@onready var lbl_energia: Label = $Root/TopCentro/LblEnergia
@onready var target_frame: VBoxContainer = $Root/TopCentro/TargetFrame
@onready var lbl_target_nombre: Label = $Root/TopCentro/TargetFrame/LblTargetNombre
@onready var barra_target_hp: ProgressBar = $Root/TopCentro/TargetFrame/BarraTargetHP
@onready var lbl_target_hp: Label = $Root/TopCentro/TargetFrame/LblTargetHP
@onready var cd1: Label = $Root/BottomCentro/Slot1/Margen1/VBox1/CD1
@onready var cd2: Label = $Root/BottomCentro/Slot2/Margen2/VBox2/CD2
@onready var flash: Label = $Root/MensajeFlash

var _nombre_pj: String = ""
var _flash_hasta: float = 0.0

# IDs de habilidades del slot 1 y 2. Lo setea mundo.gd al cargar.
var slot_habilidades: Array = ["", ""]  # index 0 = slot 1, index 1 = slot 2

func _ready() -> void:
	flash.text = ""

func set_nombre_pj(nombre: String) -> void:
	_nombre_pj = nombre
	lbl_nombre_pj.text = nombre

func set_slots(hab1_id: String, hab2_id: String) -> void:
	slot_habilidades = [hab1_id, hab2_id]

func actualizar_estado(estado: Dictionary) -> void:
	var hp_actual = int(estado.get("hp_actual", 0))
	var hp_max = int(estado.get("hp_max", 1))
	barra_hp.max_value = max(hp_max, 1)
	barra_hp.value = hp_actual
	lbl_hp.text = "%d / %d" % [hp_actual, hp_max]
	var en_actual = int(estado.get("energia_actual", 0))
	var en_max = int(estado.get("energia_max", 1))
	barra_energia.max_value = max(en_max, 1)
	barra_energia.value = en_actual
	lbl_energia.text = "%d / %d" % [en_actual, en_max]
	# Cooldowns.
	var cds: Dictionary = estado.get("cooldowns", {})
	_actualizar_cd_slot(0, cds)
	_actualizar_cd_slot(1, cds)
	# Muerto.
	if estado.get("muerto", false):
		var respawn = int(estado.get("respawn_ms", 0))
		mostrar_mensaje("Has muerto. Reapareciendo en %.1fs…" % (respawn / 1000.0), 0.1)
	elif flash.text.begins_with("Has muerto"):
		flash.text = ""

func _actualizar_cd_slot(slot_idx: int, cds: Dictionary) -> void:
	var hab_id = slot_habilidades[slot_idx]
	var lbl = cd1 if slot_idx == 0 else cd2
	if hab_id.is_empty() or not cds.has(hab_id):
		lbl.text = ""
		return
	var ms_restante = int(cds[hab_id])
	if ms_restante <= 0:
		lbl.text = ""
	else:
		lbl.text = "%.1fs" % (ms_restante / 1000.0)

func mostrar_objetivo(id: String, nombre: String, hp_actual: int, hp_max: int) -> void:
	target_frame.visible = true
	lbl_target_nombre.text = nombre
	barra_target_hp.max_value = max(hp_max, 1)
	barra_target_hp.value = max(hp_actual, 0)
	lbl_target_hp.text = "%d / %d" % [hp_actual, hp_max]

func ocultar_objetivo() -> void:
	target_frame.visible = false

func mostrar_mensaje(texto: String, duracion: float = 2.0) -> void:
	flash.text = texto
	_flash_hasta = Time.get_ticks_msec() / 1000.0 + duracion

func _process(_delta: float) -> void:
	if not flash.text.is_empty() and Time.get_ticks_msec() / 1000.0 > _flash_hasta:
		flash.text = ""
