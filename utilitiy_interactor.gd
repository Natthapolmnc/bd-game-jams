@tool
extends Interactor
class_name UtilityInteractor

@export_category("Raycast")
@export var interaction_ray: RayCast3D

@export_category("Target")
@export var max_distance: float = 3.0

var current_target: CollisionObject3D


func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	if interaction_ray:
		interaction_ray.target_position = Vector3(
			0.0, 0.0, -max_distance
		)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not enabled:
		current_target = null
		super._process(delta)
		return

	if NoteManager.is_reading:
		current_target = null
	else:
		_update_raycast()

	# Use the existing Interactor lifecycle.
	super._process(delta)


func _update_raycast() -> void:
	current_target = null

	if not is_instance_valid(interaction_ray):
		return

	interaction_ray.force_raycast_update()

	if not interaction_ray.is_colliding():
		return

	var collider := interaction_ray.get_collider()

	if collider is CollisionObject3D:
		current_target = collider


func get_target() -> CollisionObject3D:
	if not is_instance_valid(current_target):
		return null

	return current_target


func get_note_target() -> NoteWorld:
	var target := get_target()

	if target is NoteWorld:
		return target

	return null


func _is_pending_valid(action: Interaction) -> bool:
	if not super._is_pending_valid(action):
		return false

	# A queued note interaction should not open a different
	# note if the player looks elsewhere while waiting.
	if action is NoteInteraction:
		return action.can_interact()

	return true
