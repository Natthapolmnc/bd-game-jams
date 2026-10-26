extends CanvasLayer

class_name NoteManager

signal note_opened
signal note_closed

enum ReadingMode {
	NORMAL,
	SLOW_MOTION,
	PAUSE
}

@export_category("Time Settings")
@export_range(0.01, 1.0, 0.01)
var slow_motion_scale: float = 0.15

@onready var note_ui: Control = $NoteUI
@onready var paper: TextureRect = $NoteUI/NotePanel/PaperTexture
@onready var title_label: Label = $NoteUI/NotePanel/PaperTexture/Title
@onready var content_label: RichTextLabel = $NoteUI/NotePanel/Content
@onready var close_button: Button = $NoteUI/NotePanel/CloseButton

var current_note: NoteData
var is_reading: bool = false

var current_mode: ReadingMode = ReadingMode.NORMAL

var previous_time_scale: float = 1.0
var previous_pause_state: bool = false
var previous_mouse_mode: Input.MouseMode


func _ready() -> void:
	# This manager must remain responsive while paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	note_ui.hide()
	close_button.pressed.connect(close_note)


# -------------------------
# OPEN NOTE
# -------------------------

func open_note(
	note: NoteData,
	mode: ReadingMode = ReadingMode.PAUSE
) -> void:
	if note == null or is_reading:
		return

	current_note = note
	current_mode = mode

	# Save previous gameplay state.
	previous_time_scale = Engine.time_scale
	previous_pause_state = get_tree().paused
	previous_mouse_mode = Input.mouse_mode

	_apply_note_data(note)

	is_reading = true
	note_ui.show()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	note_opened.emit()

	_apply_reading_mode()


# -------------------------
# APPLY RESOURCE
# -------------------------

func _apply_note_data(note: NoteData) -> void:
	title_label.text = note.title
	content_label.text = note.content

	paper.texture = note.background

	title_label.add_theme_color_override(
		"font_color",
		note.text_color
	)

	content_label.add_theme_color_override(
		"default_color",
		note.text_color
	)

	if note.font:
		title_label.add_theme_font_override(
			"font", note.font
		)

		content_label.add_theme_font_override(
			"normal_font", note.font
		)
	else:
		title_label.remove_theme_font_override("font")
		content_label.remove_theme_font_override("normal_font")

	content_label.scroll_to_line(0)


# -------------------------
# TIME MANAGEMENT
# -------------------------

func _apply_reading_mode() -> void:
	match current_mode:
		ReadingMode.NORMAL:
			pass

		ReadingMode.SLOW_MOTION:
			Engine.time_scale = slow_motion_scale

		ReadingMode.PAUSE:
			get_tree().paused = true


func _restore_game_state() -> void:
	Engine.time_scale = previous_time_scale
	get_tree().paused = previous_pause_state
	Input.mouse_mode = previous_mouse_mode


# -------------------------
# CLOSE NOTE
# -------------------------

func close_note() -> void:
	if not is_reading:
		return

	is_reading = false
	note_ui.hide()

	_restore_game_state()

	current_note = null
	current_mode = ReadingMode.NORMAL

	note_closed.emit()


# -------------------------
# INPUT
# -------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not is_reading:
		return

	if event.is_action_pressed("ui_cancel"):
		close_note()
		get_viewport().set_input_as_handled()
