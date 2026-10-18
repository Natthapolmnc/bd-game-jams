extends Interactor
class_name GunInteractor

@export_category("Gun")
@export var gun_visual: Node3D
@export var start_equipped: bool = true

var equipped: bool = false


func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	set_equipped(start_equipped)


func set_equipped(value: bool) -> void:
	equipped = value

	# Disabling the Interactor also stops ADS.
	set_enabled(equipped)

	if is_instance_valid(gun_visual):
		gun_visual.visible = equipped


func is_equipped() -> bool:
	return equipped
