extends ContinuousInteraction
class_name ToggleADS


var gun_anim_player:AnimationPlayer
@export var ads_up_anim:String
@export var ads_down_anim:String

func _ready() -> void:
	var parent=get_parent()
	if (parent is GunInteractor):
		gun_anim_player=parent.gun_animation_player
		
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:PackedStringArray=[]
	var parent=get_parent()
	
	if (not parent is GunInteractor):
		warnings.append("Parent of ToggleADS required to be subclasses from GunInteractor")
		
	return warnings

func on_active()->void:
	gun_anim_player.play(ads_up_anim)

func on_deactive()->void:
	gun_anim_player.play(ads_down_anim)
