class_name FiniteResource
extends Node


var loaded_bullets: int = 0
const max_loaded_bullet: int = 6
var reserve_bullets: int = 1


# -------------------------
# GUN
# -------------------------

func is_gun_reload_valid() -> bool:
	return (loaded_bullets < max_loaded_bullet) and (reserve_bullets > 0)

func gun_reload() -> void:
	var amount: int = mini(max_loaded_bullet - loaded_bullets, reserve_bullets)
	loaded_bullets += amount
	reserve_bullets -= amount

func is_gun_fire_valid() -> bool:
	return loaded_bullets > 0

func gun_fired() -> void:
	loaded_bullets -= 1

func gun_reserve_bullets_added(amount: int) -> void:
	reserve_bullets += amount

func gun_check_loaded() -> int:
	return loaded_bullets

func gun_check_reserve() -> int:
	return reserve_bullets


# -------------------------
# SOMETHING ELSE
# -------------------------




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
