extends Interactor
class_name GunInteractor

@export_category("Gun")
@export var gun_visual: Node3D
@export var start_equipped: bool = true

var equipped: bool = false
var aiming: bool


func _ready() -> void:
	_collect_interactions()

	if Engine.is_editor_hint():
		return

	set_equipped(start_equipped)


func _collect_interactions() -> void:
	interactions.clear()

	for child in get_children():
		if child is Interaction:
			interactions.append(child)
		if child is ADSInteraction:
			child.toggle_aim.connect(toggle_ads)


func toggle_ads(state: bool) -> void:
	aiming = state


func set_equipped(value: bool) -> void:
	equipped = value

	# Disabling the Interactor also stops ADS.
	set_enabled(equipped)

	if is_instance_valid(gun_visual):
		gun_visual.visible = equipped


func is_equipped() -> bool:
	return equipped


func is_aiming() -> bool:
	return aiming
