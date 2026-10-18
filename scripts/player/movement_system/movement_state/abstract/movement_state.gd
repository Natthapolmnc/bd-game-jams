@icon ("res://addons/at-icons/node3d/move.svg")
extends Node3D

class_name MovementState

signal switch_state(state:MovementState)

var player: CharacterBody3D

# --- Shared Movement Parameters ---
@export_category("Parameters Setting")

@export var jump_velocity: float = 4.5
@export var max_speed: float = 5.0
@export var accel: float = 5.0
@export var friction: float = 8.0
@export var use_gravity: bool = true
@export var allow_input: bool = true

@export_category("State Management")

@export var air_state:MovementState

## return the boolean whether to enable to jump from [method _handle_jump]
func can_jump() -> bool:
	return false  # default: cannot jump

func enter() -> void:
	pass

func exit() -> void:
	pass

func _while_move(delta):
	pass

func physics_update(delta: float) -> void:
	_input_handler()
	_apply_horizontal(delta)
	_while_move(delta)
	_input_state_reset()
	
	if use_gravity:
		_apply_gravity(delta)

var input_dir:Vector2

func _input_handler() -> void:
	if not allow_input:
		return
	
	input_dir = Input.get_vector("left", "right", "down", "up")
	
func _input_state_reset() -> void:
	input_dir = Vector2.ZERO
	

func _apply_horizontal(delta: float) -> void:	
	if input_dir == Vector2.ZERO:
		# Apply friction
		player.velocity.x = lerp(player.velocity.x, 0.0, friction * delta)
		player.velocity.z = lerp(player.velocity.z, 0.0, friction * delta)
		return

	var direction: Vector3 = _get_move_direction(input_dir)
	var target_velocity: Vector3 = direction * max_speed

	player.velocity.x = lerp(player.velocity.x, target_velocity.x, accel * delta)
	player.velocity.z = lerp(player.velocity.z, target_velocity.z, accel * delta)

## transform the [param input_dir] to match camera direction.
func _get_move_direction(input_dir: Vector2) -> Vector3:
	var forward: Vector3 = -player.transform.basis.z
	var right: Vector3 = player.transform.basis.x

	return (forward * input_dir.y + right * input_dir.x).normalized()

## apply gravity to the player velocity.
func _apply_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta


## handle jumping on special action. On press "jump".
func _handle_jump():

	if not Input.is_action_just_pressed("jump"):
		return

	# State-specific condition
	if not can_jump():
		return

	player.velocity.y = jump_velocity
	switch_state.emit(air_state)
