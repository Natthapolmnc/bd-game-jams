class_name GunAudioManager
extends Node3D


@export var reload_time: float

var gun_shot: AudioStreamPlayer3D
var cooldown: AudioStreamPlayer3D
var cooldown_done: AudioStreamPlayer3D

var cooldown_timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gun_shot = $GunShot
	cooldown = $Cooldown
	cooldown_done = $CooldownDone
	cooldown_timer = $CooldownTimer


func take_shot() -> void:
	gun_shot.play()


func reload() -> void:
	cooldown_timer.timeout.connect(reload_done, CONNECT_ONE_SHOT)
	cooldown.play()
	cooldown_timer.start(reload_time)


func reload_done() -> void:
	cooldown.stop()
	cooldown_done.play()
