extends ContinuousInteraction
class_name ADSInteraction

@export_category("Animation")
@export var animation_player: AnimationPlayer

@export var ads_up: StringName = &"ADS_up"
@export var ads_down: StringName = &"ADS_down"

@export_range(0.0, 0.5, 0.01)
var blend_time: float = 0.05

# toggle aim
signal toggle_aim(state: bool)


func on_active() -> void:
	if not is_instance_valid(animation_player):
		return

	

	if animation_player.has_animation(ads_up):
		animation_player.play(ads_up, blend_time)
	toggle_aim.emit(_active)


func on_deactive() -> void:
	if not is_instance_valid(animation_player):
		return

	

	if animation_player.has_animation(ads_down):
		animation_player.play(ads_down, blend_time)
	toggle_aim.emit(_active)
