@tool
extends Interaction

class_name DiscreteInteraction

@export var action_time:float

func is_active()->bool:
	return cooldown_time>0
	
func activate()->void:
	super()
	cooldown_time=action_time

		
func perform(delta_tf:float)->void:
	pass 
