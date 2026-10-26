@tool

class_name runState extends MovementState


@export_category("State Mangement")
@export var idle_state:MovementState=null:
	set(value):
		update_configuration_warnings()
		idle_state=value
		
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

@export_category("Reference")
@onready var resource_manager: ResourceManager = $"../../ResourceManager"

		

@export var AIR_GRACE_TIME := 0.6	
var air_grace_timer=0.0

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if idle_state == null:
		warnings.append("Idle state must be assigned.")
	if walk_state == null:
		warnings.append("Walk state must be assigned.")
	if run_state == null:
		warnings.append("Run state must be assigned.")
	if crouch_state == null:
		warnings.append("Crouch state must be assigned.")

	return warnings

func enter():
	print ("ENTER")
	resource_manager.toggle_stamina()
	use_gravity = true

func exit() -> void:
	print ("EXIT")
	super()
	resource_manager.toggle_stamina()
	
func can_jump() -> bool:
	return player.is_on_floor()

func _while_move(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if input_dir == Vector2.ZERO and player.is_on_floor() or (resource_manager.get_stamina()<=0):
		switch_state.emit(idle_state)
	if input_dir >= Vector2.ZERO and player.is_on_floor() and Input.is_action_pressed("shift"):
		switch_state.emit(run_state)
