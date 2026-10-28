class_name ResourceManager
extends Node


var insanity_bar: InsanityBar
var stamina_bar: StaminaBar
var finite_resource: FiniteResource


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finite_resource = $FiniteResource
	insanity_bar = $InsanityBar
	stamina_bar = $StaminaBar


# -------------------------
# INTERFACE
# -------------------------

# > > > > > > > > > > Resource Bar < < < < < < < < < <

func get_stamina()->float:
	return stamina_bar.current_value

func get_insanity()->float:
	return insanity_bar.current_value

func toggle_stamina() -> void:
	stamina_bar.toggle_activity()


func toggle_insanity() -> void:
	insanity_bar.toggle_activity()


func check_insanity_stage() -> void:
	return insanity_bar.check_stage() # Return 0, 1, 2 | { NORMAL, ABNORMAL, INSANE }


# > > > > > > > > > > Finite Resource < < < < < < < < < <




# -------------------------
# MAIN LOOP
# -------------------------

func _physics_process(delta: float) -> void:
	for bar in get_children():
		if (bar is ResourceBar):
			if bar.active and bar.activity_valid():
				if bar.start_value == bar.max_value:
					bar.continuous_deplete(delta)
				else:
					bar.continuous_fill(delta)
				continue
			
			if not bar.active and bar.current_value == bar.start_value:
				continue
			
			if not bar.active and bar.cooldown_remaining > 0.0:
				bar.tick_cooldown(delta)
			
			if not bar.active and bar.cooldown_remaining == 0.0:
				bar.value_regress(delta)
