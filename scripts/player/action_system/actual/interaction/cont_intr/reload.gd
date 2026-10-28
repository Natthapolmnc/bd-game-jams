@tool
class_name Reload
extends DiscreteInteraction


func wants_held_input() -> bool:
	return false


@export_category("Animation")
@export var animation_player: AnimationPlayer

@export var reload: StringName = &"reload"
@export var idle: StringName = &"idle"

@export_range(0.0, 0.5, 0.01)
var blend_time: float = 0.05


signal will_reload()


func on_active() -> void:
	if not is_instance_valid(animation_player):
		return

	will_reload.emit()

	if animation_player.has_animation(reload):
		animation_player.play(reload, blend_time)


func on_deactive() -> void:
	if not is_instance_valid(animation_player):
		return

	if animation_player.has_animation(idle):
		animation_player.play(idle, blend_time)


func perform(delta:float)->void:
	if cooldown_remaining <= 0:
		cooldown_remaining = cooldown_time
	else:
		cooldown_remaining -= 1
		print(cooldown_remaining)
	
	if cooldown_remaining <= 0:
		deactivate()
