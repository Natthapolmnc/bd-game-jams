extends VBoxContainer
class_name Bars

@onready var insanity_bar: ProgressBar = $insanity/ProgressBar
@onready var stamina_bar: ProgressBar = $stamina/ProgressBar
@onready var resource_manager: ResourceManager = $"../../Manager/ResourceManager"


func _process(delta: float) -> void:
	stamina_bar.value=resource_manager.get_stamina()
	insanity_bar.value=resource_manager.get_insanity()
	
