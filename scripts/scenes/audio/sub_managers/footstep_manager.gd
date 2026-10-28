class_name FootstepAudioManager
extends Node3D


var walking: bool = false
var running: bool = false
var crouching: bool = false
var current_state: String

@export var STEP_DELAY_WALKING = 0.5
@export var STEP_DELAY_RUNNING = 0.3
@export var STEP_DELAY_CROUCHING = 0.8

var timer: Timer
var audio: AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = $FootstepTimer
	audio = $Footstep


# -------------------------
# INTERFACE
# -------------------------

func make_sound(state: String) -> void:
	if not timer.is_stopped():
		return
	current_state = state
	
	audio.play()
	
	match current_state:
		"walking":
			timer.start(STEP_DELAY_WALKING)
		"running":
			timer.start(STEP_DELAY_RUNNING)
		"crouching":
			timer.start(STEP_DELAY_CROUCHING)
		"idle":
			timer.stop()
