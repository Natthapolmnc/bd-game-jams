@tool
extends MovementState
class_name walkState

@export_category("State Management")
@export var idle_state: MovementState=null:
	set(value):
		update_configuration_warnings()
		idle_state=value
		
@export var run_state: MovementState=null:
	set(value):
		update_configuration_warnings()
		run_state=value
		
@export var crouch_state:MovementState=null:
	set(value):
		update_configuration_warnings()
		crouch_state=value


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if idle_state == null:
		warnings.append("Idle state must be assigned.")

	if run_state == null:
		warnings.append("Run state must be assigned.")

	if crouch_state == null:
		warnings.append("Crouch state must be assigned.")

	return warnings


func enter() -> void:
	max_speed = 4.0
	accel = 10.0
	use_gravity = true


func can_jump() -> bool:
	return player.is_on_floor()


func _while_move(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not player.is_on_floor():
		return

	if input_dir == Vector2.ZERO:
		switch_state.emit(idle_state)

	elif Input.is_action_pressed("shift"):
		switch_state.emit(run_state)
