@icon ("res://addons/at-icons/node3d/film_cartridge.svg")
extends Node3D

class_name CameraContrl

@export var player:CharacterBody3D
@export var cam:Camera3D

@export_category("HEAD BOBBING SETTING")
@export_subgroup("HORIZONTAL BOB")
@export var BOB_FREQ := 8.0
@export var  BOB_AMP := 0.05
@export var  BOB_SIDE_AMP := 0.03
var walk_weight := 0.0
@export var WALK_BOB_SMOOTH := 8.0


@export_category("HEAD TILT SETTINGS")

@export var ENABLE_HEAD_TILT := true

@export_subgroup("MOVEMENT TILT")
@export var ENABLE_MOVEMENT_TILT := true
@export_range(0.0, 20.0, 0.5) var MOVE_TILT_ANGLE := 4.0

@export_subgroup("MANUAL TILT")
@export var ENABLE_MANUAL_TILT := false
@export_range(0.0, 30.0, 0.5) var MANUAL_TILT_ANGLE := 12.0

@export_subgroup("SMOOTHING")
@export var TILT_SMOOTH := 8.0

var current_tilt := 0.0

@export_subgroup("VERTICAL BOB")
@export var AIR_BOB_AMP := 0.08
@export var AIR_BOB_SMOOTH := 7
@export var LAND_DIP_STRENGTH := 0.3
@export var LAND_DIP_SPEED := 12

@export var LAND_RECOVERY_DELAY_TIME := 0.05

var landing_recovery_delay := 0.0
var fall_start_y := 0.0
var max_fall_distance := 0.0


var vertical_offset := 0.0
var landing_offset := 0.0
var previous_state

var bob_time := 0.0
var base_cam_position := Vector3.ZERO


@export_category("MOUSE SETTING")
# Look
@export var MOUSE_SENS := 0.002
@export var MAX_LOOK_UP := deg_to_rad(70)
@export var MAX_LOOK_DOWN := deg_to_rad(-70)

@export_category("JOY SETTING")
@export var DEADZONE :=0.2
@export var JOY_SENS :=3

var yaw := 0.0
var pitch := 0.0
var air_offset := 0.0

@export_category("Interaction Integration")
@export var interactor_manager: InteractorManager

# -------------------------
# INPUT BLOCKING
# -------------------------

func is_look_blocked() -> bool:
	if not is_instance_valid(interactor_manager):
		return false

	return interactor_manager.is_movement_blocked()

# -------------------------
# LOOK INPUT
# -------------------------

func _unhandled_input(event: InputEvent) -> void:

	# Block camera rotation during interactions.
	if is_look_blocked():
		return

	# Only look around when mouse is captured.
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return

	if event is InputEventMouseMotion:
		yaw -= event.relative.x * MOUSE_SENS
		pitch -= event.relative.y * MOUSE_SENS

		pitch = clampf(
			pitch,
			MAX_LOOK_DOWN,
			MAX_LOOK_UP
		)

		_apply_look()

func _handle_head_tilt(delta: float) -> void:
	var target_tilt := 0.0

	if ENABLE_HEAD_TILT:
		# -------------------------
		# MOVEMENT TILT
		# -------------------------
		if ENABLE_MOVEMENT_TILT and player.is_on_floor():
			var local_velocity: Vector3 = (
				player.global_basis.inverse() * player.velocity
			)

			var strafe_factor: float = clampf(
				local_velocity.x / 5.0,
				-1.0,
				1.0
			)

			target_tilt -= strafe_factor * deg_to_rad(MOVE_TILT_ANGLE)

		# -------------------------
		# MANUAL TILT
		# -------------------------
		if ENABLE_MANUAL_TILT:
			var lean_input: float = (
				Input.get_action_strength("lean_right")
				- Input.get_action_strength("lean_left")
			)

			target_tilt -= lean_input * deg_to_rad(MANUAL_TILT_ANGLE)

	# -------------------------
	# SMOOTH INTERPOLATION
	# -------------------------
	current_tilt = lerp_angle(
		current_tilt,
		target_tilt,
		1.0 - exp(-TILT_SMOOTH * delta)
	)

	cam.rotation.z = current_tilt
		
func _handle_headbob(delta):
	var horizontal_speed = Vector2(player.velocity.x, player.velocity.z).length()
	var is_moving = horizontal_speed > 0.1
	var is_on_floor = player.is_on_floor()

	# -------------------------
	# WALK BOB
	# -------------------------
	var walk_offset = Vector3.ZERO
	
#
	# Smoothly blend walk bob in/out
	var target_weight = 1.0 if (is_on_floor and is_moving) else 0.0
	if is_on_floor and is_moving:
		walk_weight = lerp(walk_weight, 1.0, WALK_BOB_SMOOTH * delta)
	else:
		# Only fade out when near zero-crossing for clean finish
		if abs(sin(bob_time)) < 0.1:
			walk_weight = lerp(walk_weight, 0.0, WALK_BOB_SMOOTH * delta)


	if walk_weight > 0.001:
		bob_time += delta * BOB_FREQ * (horizontal_speed / 5.0)

		var vertical = sin(bob_time) * BOB_AMP
		var horizontal = cos(bob_time * 0.5) * BOB_SIDE_AMP

		walk_offset = Vector3(horizontal, vertical, 0) * walk_weight


	# -------------------------
	# AIR BOB
	# -------------------------

	var target_air_offset := 0.0

	# Falling
	if player.velocity.y < 0.0:
		var fall_speed :float = abs(player.velocity.y)

		target_air_offset = clamp(
			fall_speed * 0.01,
			0.0,
			AIR_BOB_AMP
		)

		# Camera moves downward while falling
		target_air_offset = -target_air_offset

	# Rising / jumping
	elif player.velocity.y > 0.0:
		var rise_speed := player.velocity.y

		target_air_offset = clamp(
			rise_speed * 0.005,
			0.0,
			AIR_BOB_AMP * 0.5
		)

		# Slight upward movement while rising
		target_air_offset = target_air_offset


	air_offset = lerp(
		air_offset,
		target_air_offset,
		AIR_BOB_SMOOTH * delta
	)


	# -------------------------
	# LANDING RECOVERY
	# -------------------------
	if landing_recovery_delay > 0.0:
		landing_recovery_delay -= delta
	else:
		if landing_offset < 0.0:
			landing_offset = lerp(landing_offset, 0.0, LAND_DIP_SPEED * delta)

			if abs(landing_offset) < 0.001:
				landing_offset = 0.0

	# -------------------------
	# FINAL POSITION
	# -------------------------
	var final_offset = walk_offset
	final_offset.y += vertical_offset + landing_offset

	cam.position = base_cam_position + final_offset
	#previous_state = move_state.name



func _apply_look():
	
	player.rotation.y = yaw          # Horizontal rotation
	cam.rotation.x = pitch   # Vertical rotation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_cam_position = cam.position
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	_handle_headbob(delta)
	_handle_head_tilt(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Block joystick rotation during interactions.
	if is_look_blocked():
		return

	var joy_x: float = (
		Input.get_action_strength("look_right")
		- Input.get_action_strength("look_left")
	)

	var joy_y: float = (
		Input.get_action_strength("look_down")
		- Input.get_action_strength("look_up")
	)

	var joy_vec := Vector2(joy_x, joy_y)

	if joy_vec.length() > DEADZONE:
		yaw -= joy_vec.x * JOY_SENS * delta
		pitch -= joy_vec.y * JOY_SENS * delta

		pitch = clampf(
			pitch,
			MAX_LOOK_DOWN,
			MAX_LOOK_UP
		)

		_apply_look()
