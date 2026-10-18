@tool
@icon ("res://addons/at-icons/node3d/cog.svg")
extends Node3D

class_name MovementStateMachine


@export_category("Interaction Integration")
@export var interactor_manager: InteractorManager

@export_category("Movement State")
@export var default_movement_state:MovementState:
	set(value):
		update_configuration_warnings()
		default_movement_state=value



func is_movement_blocked() -> bool:
	if not is_instance_valid(interactor_manager):
		return false

	return interactor_manager.is_movement_blocked()

func _get_configuration_warnings() -> PackedStringArray:

	var warnings := PackedStringArray()
	
	# Inject references into states
	var not_have_ms:bool=true;
	for child in get_children():
		not_have_ms = not_have_ms and (not child is MovementState)
		
	if not_have_ms:
		warnings.append("Needed at least one state as a child of this node.")
		
	if player == null:
		warnings.append("Target player CharacterBody3D needed to be assigned.")
		
	if default_movement_state == null:
		warnings.append("Default MovementState needed to be assigned.")
	
	return warnings

# -------------------------
# REFERENCES
# -------------------------
@export var player: CharacterBody3D:
	set(value):
		update_configuration_warnings()
		player=value
		

var active_state: MovementState

# =========================
# INITIALIZE
# =========================
func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if player == null:
		push_error("MovementStateMachine requires a player.")
		set_physics_process(false)
		return

	for child in get_children():
		if child is MovementState:
			child.player = player

			child.switch_state.connect(
				on_switch_state_signal
			)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if default_movement_state:
		on_switch_state_signal(default_movement_state)
			
func get_move_state() -> MovementState:
	return active_state

# ========================
# signal handler
# ========================

## Change the active state to new state.
## [param new_state] is the target state which we wanted to change to.
func on_switch_state_signal(new_state: MovementState) -> void:
	if new_state == active_state:
		return

	if active_state:
		active_state.exit()

	active_state = new_state

	if active_state:
		active_state.enter()


func _blocked_movement(delta: float) -> void:
	player.velocity.x = 0.0
	player.velocity.z = 0.0

	if not player.is_on_floor():
		var gravity: float = float(
			ProjectSettings.get_setting(
                "physics/3d/default_gravity"
			)
		)

		player.velocity.y -= gravity * delta

	elif player.velocity.y < 0.0:
		player.velocity.y = 0.0
# =========================
# MAIN PHYSICS LOOP
# =========================
func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not is_instance_valid(player):
		return

	if is_movement_blocked():
		_blocked_movement(delta)

	elif is_instance_valid(active_state):
		active_state.physics_update(delta)

	player.move_and_slide()
