@tool
@icon("res://addons/at-icons/node3d/tap.svg")
extends Node
class_name Interactor

@export var enabled: bool = true

var interactions: Array[Interaction] = []

var cur_act: Interaction
var pending_act: Interaction



# -------------------------
# EDITOR
# -------------------------



func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	var has_interaction := false

	for child in get_children():
		if child is Interaction:
			has_interaction = true
			break

	if not has_interaction:
		warnings.append(
            "There needs to be at least one Interaction child."
		)

	return warnings


func _notification(what: int) -> void:
	if what != NOTIFICATION_CHILD_ORDER_CHANGED:
		return

	if not is_inside_tree():
		return

	if Engine.is_editor_hint():
		call_deferred("update_configuration_warnings")
	elif is_node_ready():
		call_deferred("_collect_interactions")


# -------------------------
# INITIALIZATION
# -------------------------

func _ready() -> void:
	_collect_interactions()


func _collect_interactions() -> void:
	interactions.clear()

	for child in get_children():
		if child is Interaction:
			interactions.append(child)


# -------------------------
# INPUT REQUESTS
# -------------------------

func _state_handling(delta: float) -> void:
	if not _is_pending_valid(pending_act):
		pending_act = null

	var best_request: Interaction = null

	for intrt in interactions:
		if not is_instance_valid(intrt):
			continue

		if not intrt.input_requested():
			continue

		# Current interaction receives its own input.
		if intrt == cur_act:
			intrt.request(delta)
			continue

		if intrt.is_active() or intrt.is_cooldown():
			continue

		# Lowest tag has the highest priority.
		if best_request == null or intrt.tag < best_request.tag:
			best_request = intrt

	if best_request == null:
		return

	# Store the best request until the current action finishes.
	if pending_act == null or best_request.tag < pending_act.tag:
		pending_act = best_request


func _is_pending_valid(action: Interaction) -> bool:
	if not is_instance_valid(action):
		return false

	if not interactions.has(action):
		return false

	if action.is_active() or action.is_cooldown():
		return false

	# Held actions must still have their input held.
	if action.wants_held_input():
		return action.input_is_down()

	# Press actions may be queued after release unless
	# their release policy explicitly forbids it.
	if action.release_policy == Interaction.ReleasePolicy.STOP_ON_RELEASE:
		return action.input_is_down()

	return true


# -------------------------
# ACTION LIFECYCLE
# -------------------------

func _action_handling(delta: float) -> void:
	if not is_instance_valid(cur_act):
		cur_act = null
		return

	if (
		cur_act.release_policy == Interaction.ReleasePolicy.STOP_ON_RELEASE
		and cur_act.input_released()
	):
		cur_act.deactivate()

	if cur_act.is_active():
		cur_act.tick(delta)

	if not cur_act.is_active():
		cur_act = null


func _start_pending(delta: float) -> void:
	if not _is_pending_valid(pending_act):
		pending_act = null
		return

	cur_act = pending_act
	pending_act = null

	cur_act.request(delta)

	if not cur_act.is_active():
		cur_act = null


# -------------------------
# ENABLE / DISABLE
# -------------------------

func set_enabled(value: bool) -> void:
	enabled = value

	if not enabled:
		_stop_current()


func _stop_current() -> void:
	if is_instance_valid(cur_act):
		cur_act.deactivate()

	cur_act = null
	pending_act = null


# -------------------------
# MAIN LOOP
# -------------------------

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not enabled:
		_stop_current()
		return

	# Update cooldowns for every interaction.
	for intrt in interactions:
		if is_instance_valid(intrt):
			intrt.tick_cooldown(delta)

	# Remove invalid references.
	if not is_instance_valid(cur_act):
		cur_act = null

	# Collect and prioritize input.
	_state_handling(delta)

	# Update the current action.
	_action_handling(delta)

	# Start the next action only after the current one ends.
	if cur_act == null:
		_start_pending(delta)
