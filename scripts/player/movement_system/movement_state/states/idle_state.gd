@tool
class_name idleState extends MovementState



@export_category("State Mangement")
@export var walk_state:MovementState=null:
	set(value):
		update_configuration_warnings()
		walk_state=value
@export var run_state:MovementState=null:
	set(value):
		update_configuration_warnings()
		run_state=value
@export var crouch_state: MovementState=null:
	set(value):
		update_configuration_warnings()
		crouch_state=value

@export var AIR_GRACE_TIME := 0.6
var air_grace_timer=0.0

@export_category("Reference")
@onready var resource_manager: ResourceManager = $"../../ResourceManager"


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if walk_state == null:
		warnings.append("Walk state must be assigned.")
	if run_state == null:
		warnings.append("Run state must be assigned.")
	if crouch_state == null:
		warnings.append("Crouch state must be assigned.")

	return warnings


func enter():
	max_speed = 0.0
	accel = 0.0
	use_gravity = true

func can_jump() -> bool:
	return player.is_on_floor()

func _while_move(delta):
	if Engine.is_editor_hint():
		return

	# Crouch takes priority.
	if Input.is_action_just_pressed("crouch"):
		switch_state.emit(crouch_state)
		return

	if input_dir != Vector2.ZERO and player.is_on_floor():
		switch_state.emit(walk_state)
	if input_dir != Vector2.ZERO and player.is_on_floor() and Input.is_action_pressed("shift") and resource_manager.get_stamina()>10:
		switch_state.emit(run_state)
