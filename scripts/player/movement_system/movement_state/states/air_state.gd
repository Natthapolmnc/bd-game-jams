@tool
class_name airState extends MovementState

@export_category("State Mangement")
@export var floor_idle:MovementState

func enter():
	use_gravity = true

func _while_move(delta):
	
	if Engine.is_editor_hint():
		return
		
	if player.is_on_floor():
		switch_state.emit()
		return
