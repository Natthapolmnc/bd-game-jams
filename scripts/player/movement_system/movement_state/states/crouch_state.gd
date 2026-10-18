@tool
extends MovementState
class_name CrouchState

@export_category("State Management")
@export var idle_state: MovementState
@export var walk_state: MovementState

@export_category("Scene References")
@export var character_mesh: MeshInstance3D
@export var capsule_collider: CollisionShape3D

@export_category("Camera Settings")
@export var camera_pivot: Node3D

@export_range(0.0, 1.5, 0.05)
var camera_drop: float = 0.5

@export_range(0.0, 1.0, 0.01)
var camera_transition_time: float = 0.2

var _standing_camera_position: Vector3
var _camera_tween: Tween

@export_category("Crouch Settings")
var crouch_ratio: float = 0.6

# Original transforms
var _standing_mesh_scale: Vector3
var _standing_mesh_position: Vector3
var _standing_collider_position: Vector3

var _standing_capsule: CapsuleShape3D
var _capsule: CapsuleShape3D

var _initialized: bool = false


func _initialize() -> bool:
	if _initialized:
		return true

	if not is_instance_valid(character_mesh):
		push_error("CrouchState: Missing character mesh.")
		return false

	if not is_instance_valid(capsule_collider):
		push_error("CrouchState: Missing collision shape.")
		return false

	if character_mesh.mesh == null:
		push_error("CrouchState: Mesh resource is missing.")
		return false
		
	if not is_instance_valid(camera_pivot):
		push_error("CrouchState: CameraPivot is missing.")
		return false

	_standing_camera_position = camera_pivot.position

	if not capsule_collider.shape is CapsuleShape3D:
		push_error("CrouchState requires CapsuleShape3D.")
		return false

	# Save original transforms.
	_standing_mesh_scale = character_mesh.scale
	_standing_mesh_position = character_mesh.position
	_standing_collider_position = capsule_collider.position

	# Keep separate copies to avoid modifying shared resources.
	_standing_capsule = capsule_collider.shape.duplicate(true)
	capsule_collider.shape = capsule_collider.shape.duplicate(true)
	_capsule = capsule_collider.shape as CapsuleShape3D

	_initialized = true
	return true


func enter() -> void:
	use_gravity = true
	allow_input = true

	if _initialize():
		_apply_crouch()


func exit() -> void:
	if _initialized:
		_restore_standing()


func can_jump() -> bool:
	return false


func physics_update(delta: float) -> void:
	super.physics_update(delta)

	if not player.is_on_floor():
		return

	if Input.is_action_just_pressed("crouch"):
		if not _can_stand():
			return

		if input_dir == Vector2.ZERO:
			switch_state.emit(idle_state)
		else:
			switch_state.emit(walk_state)


# -------------------------
# CROUCH
# -------------------------

func _apply_crouch() -> void:
	var standing_height := _standing_capsule.height
	var radius := _standing_capsule.radius

	# Capsule cannot be shorter than its diameter.
	var crouched_height := maxf(
		standing_height * crouch_ratio,
		radius * 2.0
	)

	var actual_ratio := crouched_height / standing_height
	var height_difference := standing_height - crouched_height

	# Reduce visual height.
	character_mesh.scale.y = (
		_standing_mesh_scale.y * actual_ratio
	)

	# Preserve the mesh's original bottom position.
	var mesh_bottom := (
		character_mesh.get_aabb().position.y
		* _standing_mesh_scale.y
	)

	character_mesh.position.y = (
		_standing_mesh_position.y
		+ mesh_bottom * (1.0 - actual_ratio)
	)

	# Shorten the collision capsule.
	_capsule.height = crouched_height

	# Lower its center so its bottom stays in place.
	capsule_collider.position.y = (
		_standing_collider_position.y
		- height_difference * 0.5
	)
	
	var crouched_camera_position := (
	_standing_camera_position
	- Vector3.UP * minf(camera_drop, height_difference)
	)

	_move_camera(crouched_camera_position)


# -------------------------
# STANDING
# -------------------------

func _restore_standing() -> void:
	print("RESTORING STANDING!")

	character_mesh.scale = _standing_mesh_scale
	character_mesh.position = _standing_mesh_position

	_capsule.height = _standing_capsule.height
	capsule_collider.position = _standing_collider_position

	_move_camera(_standing_camera_position)

func _move_camera(target_position: Vector3) -> void:
	if not is_instance_valid(camera_pivot):
		return

	# Stop any unfinished camera animation.
	if _camera_tween and _camera_tween.is_valid():
		_camera_tween.kill()

	_camera_tween = create_tween()

	_camera_tween.set_process_mode(
		Tween.TWEEN_PROCESS_PHYSICS
	)

	_camera_tween.set_trans(Tween.TRANS_SINE)
	_camera_tween.set_ease(Tween.EASE_IN_OUT)

	_camera_tween.tween_property(
		camera_pivot,
		"position",
		target_position,
		camera_transition_time
	)

func _can_stand() -> bool:
	if not _initialized:
		return false

	var query := PhysicsShapeQueryParameters3D.new()

	query.shape = _standing_capsule
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]

	# Check the capsule at its standing position.
	var standing_transform := capsule_collider.transform
	standing_transform.origin = (
		_standing_collider_position + Vector3.UP * 0.02
	)

	query.transform = (
		capsule_collider.get_parent().global_transform
		* standing_transform
	)

	var collisions := player.get_world_3d() \
		.direct_space_state.intersect_shape(query, 1)

	return collisions.is_empty()
