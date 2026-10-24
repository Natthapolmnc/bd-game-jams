class_name InsanityBar
extends ResourceBar


enum STAGE { NORMAL, ABNORMAL, INSANE }

var current_stage: STAGE = STAGE.NORMAL
@export_category("StageThreshold")
@export var min_ABNORMAL_value: float
@export var max_ABNORMAL_value: float

@export_category("DynamicFillSpeed")
@export var ABNORMAL_fill_speed: float
@export var INSANE_fill_speed: float

var current_fill_speed: float


func set_stage() -> void:
	if current_value < min_ABNORMAL_value:
		current_stage = STAGE.NORMAL
		return
	if current_value > max_ABNORMAL_value:
		current_stage = STAGE.INSANE
		return
	current_stage = STAGE.ABNORMAL


func check_stage() -> int:
	set_stage()
	if current_stage == STAGE.NORMAL:
		current_fill_speed = fill_speed
		return 0
	elif current_stage == STAGE.ABNORMAL:
		current_fill_speed = ABNORMAL_fill_speed
		return 1
	else:
		current_fill_speed = INSANE_fill_speed
		return 2


func continuous_fill(delta: float) -> void:
	check_stage()
	current_value = clampf(current_value + (current_fill_speed * delta), min_value, max_value)
	value_changed.emit(current_value)
