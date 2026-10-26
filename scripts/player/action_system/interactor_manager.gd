@tool
@icon("res://addons/at-icons/node3d/cog.svg")
extends Node3D
class_name InteractorManager

@export var auto_collect: bool = true
@export var assigned_interactors: Array[Interactor] = []

var interactors: Array[Interactor] = []

func is_movement_blocked() -> bool:
	for intrt in interactors:
		if not is_instance_valid(intrt):
			continue

		if not intrt.enabled:
			continue

		var action := intrt.cur_act

		if not is_instance_valid(action):
			continue

		if action.is_active() and action.blocks_movement:
			return true

	return false


func canceled_by_movement() -> void:
	pass


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	interactors.clear()

	for intrt in assigned_interactors:
		if is_instance_valid(intrt) and not interactors.has(intrt):
			interactors.append(intrt)

	if auto_collect:
		_collect_interactors(self)


func _collect_interactors(root: Node) -> void:
	for child in root.get_children():
		if child is Interactor:
			if not interactors.has(child):
				interactors.append(child)

		_collect_interactors(child)


func set_interactor_enabled(
	intrt: Interactor,
	value: bool
) -> void:
	if not is_instance_valid(intrt) or not interactors.has(intrt):
		push_warning("Interactor is not registered.")
		return

	intrt.set_enabled(value)


func set_all_enabled(value: bool) -> void:
	for intrt in interactors:
		if is_instance_valid(intrt):
			intrt.set_enabled(value)
