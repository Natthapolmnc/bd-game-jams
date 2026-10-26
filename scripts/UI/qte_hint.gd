extends Control
class_name SearchQTEUI


@export var search_interaction: SearchInteraction

@onready var prompt: Label = $VBoxContainer/Prompt
@onready var timer_bar: ProgressBar = $VBoxContainer/timebar


func _ready() -> void:
	hide()

	search_interaction.qte_started.connect(
		_on_qte_started
	)

	search_interaction.qte_progress_changed.connect(
		_on_qte_progress
	)

	search_interaction.qte_finished.connect(
		_on_qte_finished
	)


func _on_qte_started(
	action: StringName,
	_duration: float
) -> void:

	var button_name: String = String(action)
	button_name = button_name.trim_prefix("qte_")
	button_name = button_name.to_upper()

	prompt.text = "PRESS " + button_name + "!"

	timer_bar.value = timer_bar.max_value

	show()


func _on_qte_progress(remaining_ratio: float) -> void:
	timer_bar.value = (
		remaining_ratio * timer_bar.max_value
	)


func _on_qte_finished(_success: bool) -> void:
	hide()
