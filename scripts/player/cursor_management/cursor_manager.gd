@icon("res://addons/at-icons/node/click.svg")
extends CanvasLayer
class_name CursorManager


# -------------------------
# ENUMS
# -------------------------

enum CursorStyle {
	NONE,
	CROSSHAIR,
	INTERACT,
	PROGRESS,
	ARROW
}


# -------------------------
# EXPORTS
# -------------------------

@export_category("Cursor Settings")

@export var default_cursor: CursorStyle = CursorStyle.CROSSHAIR

@export_category("Debug")

@export var debug_progress_preview: bool = false


# -------------------------
# REFERENCES
# -------------------------

@onready var crosshair: FPSCrosshair = $Crosshair


# -------------------------
# VARIABLES
# -------------------------

var current_style: CursorStyle = CursorStyle.CROSSHAIR

var current_mouse_mode: Input.MouseMode = \
	Input.MOUSE_MODE_CAPTURED


# -------------------------
# INITIALIZATION
# -------------------------

func _ready() -> void:

	set_cursor(default_cursor)

	# Test progress cursor independently.
	if debug_progress_preview:
		set_cursor(CursorStyle.PROGRESS)
		set_progress(0.5)

		print(
			"Progress cursor test: ",
			current_style
		)

		print(
			"Crosshair visible: ",
			crosshair.visible
		)


# -------------------------
# CURSOR STYLE
# -------------------------

func set_cursor(style: CursorStyle) -> void:

	if not is_instance_valid(crosshair):
		return

	var entering_progress: bool = (
		style == CursorStyle.PROGRESS
		and current_style != CursorStyle.PROGRESS
	)

	current_style = style

	match style:

		CursorStyle.NONE:
			crosshair.hide()

			set_mouse_mode(
				Input.MOUSE_MODE_HIDDEN
			)


		CursorStyle.CROSSHAIR:
			crosshair.set_interact(false)
			crosshair.show()

			set_mouse_mode(
				Input.MOUSE_MODE_CAPTURED
			)


		CursorStyle.INTERACT:
			crosshair.set_interact(true)
			crosshair.show()

			set_mouse_mode(
				Input.MOUSE_MODE_CAPTURED
			)


		CursorStyle.PROGRESS:
			crosshair.set_interact(false)

			if entering_progress:
				crosshair.set_progress(0.0)

			crosshair.show()

			set_mouse_mode(
				Input.MOUSE_MODE_CAPTURED
			)


		CursorStyle.ARROW:
			crosshair.hide()

			set_mouse_mode(
				Input.MOUSE_MODE_VISIBLE
			)

	# Synchronize progress mode LAST.
	# This prevents set_interact() from
	# potentially overriding progress mode.
	crosshair.set_progress_mode(
		style == CursorStyle.PROGRESS
	)


# -------------------------
# MOUSE MODE
# -------------------------

func set_mouse_mode(mode: Input.MouseMode) -> void:

	current_mouse_mode = mode
	Input.mouse_mode = mode


# -------------------------
# PROGRESS
# -------------------------

func set_progress(value: float) -> void:

	if not is_instance_valid(crosshair):
		return

	crosshair.set_progress(
		clampf(value, 0.0, 1.0)
	)


# -------------------------
# CURSOR RESET
# -------------------------

func reset_cursor() -> void:

	set_progress(0.0)

	set_cursor(
		default_cursor
	)
