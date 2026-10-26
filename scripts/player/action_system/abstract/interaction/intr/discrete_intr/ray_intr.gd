@tool
@icon("res://addons/at-icons/node3d/tap.svg")
extends DiscreteInteraction

class_name RayInteraction

@onready var utility: UtilityInteractor = \
	get_parent() as UtilityInteractor

var requested_target: CollisionObject3D


# -------------------------
# TARGET
# -------------------------

func get_target() -> CollisionObject3D:
	if not is_instance_valid(utility):
		return null

	return utility.get_target()


func can_interact(_target: CollisionObject3D) -> bool:
	return false


func is_target_valid() -> bool:
	if not is_instance_valid(requested_target):
		return false

	return (
		requested_target == get_target()
		and can_interact(requested_target)
	)


# -------------------------
# INPUT
# -------------------------

func input_requested() -> bool:
	if not super.input_requested():
		return false

	var target := get_target()

	if target == null:
		return false

	if not can_interact(target):
		return false

	requested_target = target
	return true


# -------------------------
# LIFECYCLE
# -------------------------

func on_active() -> void:
	if not is_target_valid():
		deactivate()
		return

	interact(requested_target)


func interact(_target: CollisionObject3D) -> void:
	pass


func deactivate() -> void:
	if not is_active():
		return

	super.deactivate()
	blocks_movement = false
	requested_target = null
