extends Node


var BadDream: AudioStreamPlayer
var Dreamy: AudioStreamPlayer


var trap_placing_signal: AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BadDream = $Badplan
	Dreamy = $Dreamy
	trap_placing_signal = $MonsterTrapPlacingSignal
	Dreamy.play()


# -------------------------
# INTERFACE
# -------------------------

func toggle_badplan() -> void:
	if Dreamy.playing:
		Dreamy.stream_paused = true
		BadDream.play()
	else:
		BadDream.stop()
		Dreamy.stream_paused = false


func monster_place_trap() -> void:
	trap_placing_signal.play()
