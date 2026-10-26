@tool
extends Interactor
class_name UtilityInteractor

# -------------------------
# SIGNALS
# -------------------------

signal target_changed(
	previous: CollisionObject3D,
	current: CollisionObject3D
)


# -------------------------
# EXPORTS
# -------------------------

@export_category("Raycast")
@export var interaction_ray: RayCast3D

@export_category("Target")
@export_range(0.1, 20.0, 0.1)
var max_distance: float = 3.0


# -------------------------
# VARIABLES
# -------------------------

var current_target: CollisionObject3D = null


# -------------------------
# INITIALIZATION
# -------------------------

func _ready() -> void:
	super._ready()

	if Engine.is_editor_hint():
		return

	target_changed.connect(_on_target_changed)

	if is_instance_valid(interaction_ray):
		interaction_ray.target_position = Vector3(
			0.0,
			0.0,
			-max_distance
		)
	else:
		push_warning(
			"UtilityInteractor: Interaction Ray is not assigned."
		)


# -------------------------
# MAIN LOOP
# -------------------------

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not enabled:
		_set_target(null)
		super._process(delta)
		return

	_update_raycast()

	# Preserve the original Interactor lifecycle.
	super._process(delta)


# -------------------------
# RAYCAST
# -------------------------

func _update_raycast() -> void:
	if not is_instance_valid(interaction_ray):
		_set_target(null)
		return

	# Update raycast immediately.
	interaction_ray.force_raycast_update()

	if not interaction_ray.is_colliding():
		_set_target(null)
		return

	var collider := interaction_ray.get_collider()

	if collider is CollisionObject3D:
		_set_target(collider)
	else:
		_set_target(null)


# -------------------------
# TARGET MANAGEMENT
# -------------------------

func _set_target(target: CollisionObject3D) -> void:
	# Ensure the new target exists.
	if not is_instance_valid(target):
		target = null

	# Check whether the previous target still exists.
	if not is_instance_valid(current_target):
		current_target = null

	# No change means no signal.
	if target == current_target:
		return

	var previous := current_target

	current_target = target

	target_changed.emit(
		previous,
		current_target
	)


func get_target() -> CollisionObject3D:
	if not is_instance_valid(current_target):
		return null

	return current_target


func has_target() -> bool:
	return get_target() != null


# -------------------------
# INTERACTION VALIDATION
# -------------------------

func _is_pending_valid(action: Interaction) -> bool:
	if not super._is_pending_valid(action):
		return false

	# Ray interactions must still target
	# the same object that requested them.
	if action is RayInteraction:
		return action.is_target_valid()

	return true


# -------------------------
# TARGET HIGHLIGHT
# -------------------------

# -------------------------
# TARGET HIGHLIGHT
# -------------------------

func _on_target_changed(
	previous: CollisionObject3D,
	current: CollisionObject3D
) -> void:

	# Remove previous highlight.
	_set_target_highlight(previous, false)

	# Apply new highlight.
	_set_target_highlight(current, true)
	
	
# -------------------------
# HIGHLIGHT TARGET
# -------------------------

func _set_target_highlight(
	target: CollisionObject3D,
	value: bool
) -> void:

	if not is_instance_valid(target):
		return

	# Note highlighting.
	if target is NoteWorld:
		target.set_highlight(value)
		return

	# Find a container in the target's parents.
	var node: Node = target.get_parent()

	while is_instance_valid(node):

		if node is ContainerInteractable:
			node.set_highlight(value)
			return

		node = node.get_parent()


# -------------------------
# ENABLE / DISABLE
# -------------------------

func set_enabled(value: bool) -> void:
	super.set_enabled(value)

	if not value:
		_set_target(null)


# -------------------------
# CLEANUP
# -------------------------

func _exit_tree() -> void:
	_set_target(null)
