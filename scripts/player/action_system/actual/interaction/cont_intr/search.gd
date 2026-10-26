@tool
extends RayInteraction
class_name SearchInteraction


# -------------------------
# SIGNALS
# -------------------------

signal qte_started(action: StringName, duration: float)
signal qte_progress_changed(remaining_ratio: float)
signal qte_finished(success: bool)


# -------------------------
# EXPORTS
# -------------------------

@export_category("References")
@export var utility_interactor: UtilityInteractor
@export var cursor_manager: CursorManager
@export var inventory_manager: InventoryManager


@export_category("Search Settings")

@export_range(0.1, 30.0, 0.1)
var search_duration: float = 5.0

@export_range(1, 100, 1)
var ticks: int = 12


@export_category("QTE Settings")

@export_range(0.0, 100.0, 0.1, "suffix:%")
var qte_chance: float = 5.0

@export_range(0.1, 10.0, 0.1)
var qte_duration: float = 1.5

@export var qte_actions: Array[StringName] = [
	&"qte_o",
	&"qte_space",
	&"qte_t",
	&"qte_m"
]

var is_searching: bool = false
# -------------------------
# VARIABLES
# -------------------------

var search_elapsed: float = 0.0
var last_step: int = 0

var qte_active: bool = false
var qte_triggered: bool = false
var qte_time_left: float = 0.0

var current_qte_action: StringName = &""

var rng := RandomNumberGenerator.new()


# -------------------------
# TARGET
# -------------------------

func get_container(
	target: CollisionObject3D
) -> ContainerInteractable:

	if not is_instance_valid(target):
		return null

	var node: Node = target

	while is_instance_valid(node):

		if node is ContainerInteractable:
			return node as ContainerInteractable

		node = node.get_parent()

	return null


func can_interact(target: CollisionObject3D) -> bool:

	var container: ContainerInteractable = get_container(target)

	return (
		is_instance_valid(container)
		and container.can_search()
	)


# -------------------------
# AIM VALIDATION
# -------------------------

func is_aiming_at_container() -> bool:

	if not is_instance_valid(utility_interactor):
		return false

	if not is_instance_valid(requested_target):
		return false

	var original_container: ContainerInteractable = get_container(
		requested_target
	)

	var current_container: ContainerInteractable = get_container(
		utility_interactor.get_target()
	)

	return (
		is_instance_valid(original_container)
		and original_container == current_container
		and original_container.can_search()
	)


# -------------------------
# REQUEST
# -------------------------

func request(_delta: float) -> void:
	activate()

# -------------------------
# ACTIVE CHECK
# -------------------------

func is_active() -> bool:
	return is_searching
# -------------------------
# ACTIVATION
# -------------------------

func on_active() -> void:
	is_searching = true
	blocks_movement = true
	# Validate target.
	if not is_aiming_at_container():
		deactivate()
		return

	# Validate cursor manager.
	if not is_instance_valid(cursor_manager):
		push_error(
			"SearchInteraction: CursorManager is not assigned."
		)
		deactivate()
		return

	# Block player movement.
	blocks_movement = true

	# Reset search state.
	search_elapsed = 0.0
	last_step = 0

	# Reset QTE state.
	qte_active = false
	qte_triggered = false
	qte_time_left = 0.0
	current_qte_action = &""

	# Set progress cursor.
	cursor_manager.set_cursor(
		CursorManager.CursorStyle.PROGRESS
	)

	cursor_manager.set_progress(0.0)


# -------------------------
# PROGRESS
# -------------------------

func perform(delta: float) -> void:
	# Cancel if the player looks away.
	if not is_aiming_at_container():
		deactivate()
		return

	# Respect the configured release policy.
	if (
		release_policy == ReleasePolicy.STOP_ON_RELEASE
		and not input_is_down()
	):
		deactivate()
		return

	# Pause search while QTE is active.
	if qte_active:
		_update_qte(delta)
		return

	# Ensure progress cursor remains active.
	if (
		cursor_manager.current_style
		!= CursorManager.CursorStyle.PROGRESS
	):
		cursor_manager.set_cursor(
			CursorManager.CursorStyle.PROGRESS
		)

	# Advance search time.
	search_elapsed = minf(
		search_elapsed + delta,
		search_duration
	)

	# Calculate normalized progress.
	var progress: float = clampf(
		search_elapsed / search_duration,
		0.0,
		1.0
	)

	# Update cursor EVERY FRAME.
	cursor_manager.set_progress(progress)

	# Calculate current search tick.
	var step: int = floori(progress * ticks)

	# Process newly crossed ticks.
	while last_step < step:

		last_step += 1

		# Only one QTE per search.
		if qte_triggered:
			continue

		# Skip QTE if no actions are configured.
		if qte_actions.is_empty():
			continue

		# Fixed QTE probability per tick.
		if rng.randf() < qte_chance / 100.0:

			qte_triggered = true

			# Preserve search progress
			# at the triggering tick.
			search_elapsed = (
				search_duration
				* float(last_step)
				/ float(ticks)
			)

			cursor_manager.set_progress(
				float(last_step) / float(ticks)
			)

			_start_qte()
			return

	# Complete search at 100%.
	if progress >= 1.0:
		_complete_search()


# -------------------------
# QTE START
# -------------------------

func _start_qte() -> void:

	if qte_actions.is_empty():
		return

	# Select a random QTE button.
	var index: int = rng.randi_range(
		0,
		qte_actions.size() - 1
	)

	current_qte_action = qte_actions[index]

	# Initialize QTE state.
	qte_active = true
	qte_time_left = qte_duration

	# Notify QTE UI.
	qte_started.emit(
		current_qte_action,
		qte_duration
	)

	qte_progress_changed.emit(1.0)


# -------------------------
# QTE UPDATE
# -------------------------

func _update_qte(delta: float) -> void:

	# Check all configured QTE buttons.
	for action: StringName in qte_actions:

		if Input.is_action_just_pressed(action):

			# Correct button succeeds.
			# Wrong button fails.
			_finish_qte(
				action == current_qte_action
			)
			return

	# Advance QTE countdown.
	qte_time_left = maxf(
		qte_time_left - delta,
		0.0
	)

	# Update QTE UI.
	qte_progress_changed.emit(
		qte_time_left / qte_duration
	)

	# Timeout means failure.
	if qte_time_left <= 0.0:
		_finish_qte(false)


# -------------------------
# QTE FINISH
# -------------------------

func _finish_qte(success: bool) -> void:

	qte_active = false
	qte_time_left = 0.0

	qte_finished.emit(success)

	# Failure cancels the search.
	if not success:
		deactivate()
		return

	# If QTE happened on the final tick,
	# complete the search immediately.
	if last_step >= ticks:
		_complete_search()


# -------------------------
# COMPLETION
# -------------------------

# -------------------------
# COMPLETION
# -------------------------

func _complete_search() -> void:

	var container: ContainerInteractable = get_container(
		requested_target
	)

	if not is_instance_valid(container):
		deactivate()
		return

	if not container.can_search():
		deactivate()
		return

	if not is_instance_valid(inventory_manager):
		push_warning("InventoryManager is not assigned.")
		deactivate()
		return
	print(
	"[SEARCH COMPLETE] ",
	container.get_path(),
	" | ID: ", container.get_instance_id(),
	" | Previously searched: ", container.was_searched,
	" | Loot: ", container.contained_item
)
	
	# Transfer loot into player inventory.
	if not inventory_manager.collect_loot(
		container.contained_item
	):
		deactivate()
		return

	# Mark container as searched and open it.
	container.complete_search()

	deactivate()


# -------------------------
# DEACTIVATION
# -------------------------

func on_deactive() -> void:

	# Close any unfinished QTE.
	if qte_active:
		qte_active = false
		qte_finished.emit(false)

	# Restore movement.
	blocks_movement = false
	is_searching=false
	# Reset search state.
	search_elapsed = 0.0
	last_step = 0

	# Reset QTE state.
	qte_active = false
	qte_triggered = false
	qte_time_left = 0.0
	current_qte_action = &""

	# Restore cursor.
	if is_instance_valid(cursor_manager):

		cursor_manager.set_progress(0.0)

		cursor_manager.set_cursor(
			CursorManager.CursorStyle.CROSSHAIR
		)
