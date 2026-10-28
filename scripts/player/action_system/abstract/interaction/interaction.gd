@tool
@icon("res://addons/at-icons/node3d/tap.svg")
extends Node
class_name Interaction

enum ReleasePolicy {
	FINISH,
	STOP_ON_RELEASE
}

@export_category("Interaction")
@export var tag: GlobalConstants.INTR_TAG
@export var activate_key: StringName
@export var release_policy: ReleasePolicy = ReleasePolicy.FINISH
@export_category("Restrictions")
@export var blocks_movement: bool = false

@export_category("Cooldown")
@export_range(0.0, 30.0, 0.01)
var cooldown_time: float = 0.0

var cooldown_remaining: float = 0.0
var _active: bool = false


# -------------------------
# INPUT
# -------------------------



func wants_held_input() -> bool:
	return false


func input_requested() -> bool:
	if not _has_valid_input():
		return false

	if wants_held_input():
		return Input.is_action_pressed(activate_key)

	return Input.is_action_just_pressed(activate_key)


func input_is_down() -> bool:
	return (
		_has_valid_input()
		and Input.is_action_pressed(activate_key)
	)


func input_released() -> bool:
	return (
		_has_valid_input()
		and Input.is_action_just_released(activate_key)
	)


func _has_valid_input() -> bool:
	return (
		activate_key != &""
		and InputMap.has_action(activate_key)
	)


# -------------------------
# STATE
# -------------------------

func is_active() -> bool:
	return _active


func is_cooldown() -> bool:
	return cooldown_remaining > 0.0


# -------------------------
# LIFECYCLE
# -------------------------

func request(_delta: float) -> void:
	activate()


func activate() -> void:
	if is_active() or is_cooldown():
		return
	
	_active = true
	on_active()


func deactivate() -> void:
	if not is_active():
		return

	_active = false
	on_deactive()

	cooldown_remaining = cooldown_time


func tick(delta: float) -> void:
	if is_active():
		perform(delta)


func tick_cooldown(delta: float) -> void:
	cooldown_remaining = maxf(
		0.0,
		cooldown_remaining - delta
	)


# -------------------------
# OVERRIDABLE CALLBACKS
# -------------------------

func on_active() -> void:
	pass


func on_deactive() -> void:
	pass


func perform(_delta: float) -> void:
	pass
