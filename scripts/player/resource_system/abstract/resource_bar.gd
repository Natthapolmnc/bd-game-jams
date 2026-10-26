class_name ResourceBar
extends Node


@export_range(0.0, 100.0, 100.0)
var start_value: float

@export var fill_speed: float
@export var deplete_speed: float

@export var regress_cooldown: float = 3.5
var cooldown_remaining: float

var max_value: float = 100.0
var min_value: float = 0.0

var current_value: float

var active: bool = false


signal value_changed(value: float)


# -------------------------
# INTERFACE
# -------------------------

func toggle_activity() -> void:
	if active:
		active = false
		cooldown_remaining = regress_cooldown
	else:
		active = true


# -------------------------
# INITIALIZATION
# -------------------------

func _ready() -> void:
	current_value = start_value


# -------------------------
# HELPER
# -------------------------

func continuous_fill(delta: float) -> void:
	current_value = clampf(current_value + (fill_speed * delta), min_value, max_value)
	value_changed.emit(current_value)


func continuous_deplete(delta: float) -> void:
	current_value = clampf(current_value - (deplete_speed * delta), min_value, max_value)
	value_changed.emit(current_value)


func value_regress(delta: float) -> void:
	if start_value == max_value:
		continuous_fill(delta)
	else:
		continuous_deplete(delta)


func value_active(delta: float) -> void:
	if start_value == min_value:
		continuous_fill(delta)
	else:
		continuous_deplete(delta)


func tick_cooldown(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)


func activity_valid() -> bool:

	if start_value == 100.0 and current_value > 0.0:
		return true
	
	if start_value == 0.0 and current_value < 100.0:
		return true
	
	return false
