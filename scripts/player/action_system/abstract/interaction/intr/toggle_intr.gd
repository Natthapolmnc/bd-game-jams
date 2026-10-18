@tool
extends Interaction
class_name ToggleInteraction


func request(_delta: float) -> void:
	if is_active():
		deactivate()
	else:
		activate()
