class_name PlayerAudioManager
extends Node3D


var footstep_manager: FootstepAudioManager

var heart_beat: AudioStreamPlayer3D
var heart_beat_timer: Timer

var gun: GunAudioManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	footstep_manager = $Footstep
	
	heart_beat = $HeartBeating
	heart_beat_timer = $HeartBeating/HeartBeatTimer
	gun = $Gun
	
	


# -------------------------
# INTERFACE
# -------------------------

# > > > > > > > > > > _process call < < < < < < < < < <

func let_me_hear_your_footstep(state: String) -> void:
	footstep_manager.make_sound(state)


func so_scary() -> void:
	heart_beating()


# > > > > > > > > > > event call < < < < < < < < < <

func who_place_this_here(minus: float) -> void: ## max duration = 15
	$TrapDisarming.play(minus)


func shiny() -> void:
	$KeyItemPickup.play()


func need_some_cleaning() -> void:
	$CurseCleansing.play()


func who_left_this_here() -> void:
	$ItemPickup.play()


func look_what_I_got() -> void: ## Only call this on successfully opened the container
	$ContainerInteract.play()


func you_damn_beast() -> void:
	gun.take_shot()


func wait_a_bit() -> void:
	gun.reload()


func gotta_hide_here() -> void:
	$HidingInLocker.play()


func I_can_see_its_feet() -> void:
	$HidingUnderBed.play()



# -------------------------
# Looper
# -------------------------

func heart_beating() -> void:
	if not heart_beat_timer.is_stopped():
		return
	
	heart_beat.play()
	
	heart_beat_timer.start(0.8)








	
