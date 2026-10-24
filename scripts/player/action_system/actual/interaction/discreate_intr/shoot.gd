@tool
extends DiscreteInteraction
class_name Shoot

@export_category("Animation")
@export var animation_player: AnimationPlayer

@export var fire_ads: StringName = &"fire_ads"
@export var ads_down: StringName = &"ads_down"

@export_range(0.0, 0.5, 0.01)
var blend_time: float = 0.05


func activate()->void:
	if is_active() or is_cooldown():
		return

	var parent: GunInteractor = get_parent()

	if parent.is_aiming():
		on_active()
		cooldown_time=action_time


func on_active() -> void:
	if not is_instance_valid(animation_player):
		return

	if animation_player.has_animation(fire_ads):
		animation_player.play(fire_ads, blend_time)
