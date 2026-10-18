@tool
extends Interaction
class_name ContinuousInteraction

@export_category("Continuous Interaction")
@export_range(0.0, 2.0, 0.001)
var delta_period: float = 0.02

@export_range(0.0, 10.0, 0.05)
var refill_rate: float = 1.2

@export_range(0.01, 10.0, 0.01)
var max_buffer_time: float = 0.25

var active_time: float = 0.0


func wants_held_input() -> bool:
	return true


func request(delta: float) -> void:
	if is_cooldown():
		return

	if not is_active():
		activate()
		active_time = delta_period

	# Replenish the action's time buffer.
	active_time = minf(
		maxf(max_buffer_time, delta_period),
		active_time + refill_rate * delta
	)


func tick(delta: float) -> void:
	if not is_active():
		return

	perform(delta)

	if not _countdown(delta):
		deactivate()


func _countdown(delta: float) -> bool:
	active_time = maxf(
		0.0,
		active_time - delta
	)

	return active_time > 0.0


func deactivate() -> void:
	if not is_active():
		return

	active_time = 0.0
	super.deactivate()
