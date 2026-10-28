extends Interactor
class_name GunInteractor

@export_category("Gun")
@export var gun_visual: Node3D
@export var start_equipped: bool = true

var equipped: bool = false
var aiming: bool = false
var reloading: bool = false

@onready var inventory_manager: InventoryManager = $"../../InventoryManager"


func _ready() -> void:
	_collect_interactions()

	if Engine.is_editor_hint():
		return

	set_equipped(start_equipped)


func _collect_interactions() -> void:
	interactions.clear()

	for child in get_children():
		if child is Interaction:
			interactions.append(child)
		if child is ADSInteraction:
			child.toggle_aim.connect(toggle_ads)
			continue


func toggle_ads(state: bool) -> void:
	aiming = state


func set_equipped(value: bool) -> void:
	equipped = value

	# Disabling the Interactor also stops ADS.
	set_enabled(equipped)

	if is_instance_valid(gun_visual):
		gun_visual.visible = equipped


func is_equipped() -> bool:
	return equipped


func is_aiming() -> bool:
	return aiming


func _is_reload_valid() -> bool:
	return (inventory_manager.has_item("bullet")
			and inventory_manager.has_less_than("loaded_bullet", 6))


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

		if (
			(intrt is Shoot) and (intrt.input_requested()) and (not cur_act is Reload)
			and (is_aiming())):
			intrt.shot.connect(inventory_manager.remove_item.bind("loaded_bullet", 1), CONNECT_ONE_SHOT)
			cur_act = intrt

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
	
	if cur_act is Shoot:
		pending_act = get_child(0)
	
	if not cur_act.is_active():
		cur_act = null


func _start_pending(delta: float) -> void:
	if pending_act is ADSInteraction and aiming:
		pass
	elif not _is_pending_valid(pending_act):
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
