extends Control
class_name FPSCrosshair


@export_category("Crosshair Appearance")
@export var normal_color: Color = Color.WHITE
@export var interact_color: Color = Color.YELLOW

@export var line_length: float = 6.0
@export var line_gap: float = 4.0
@export var line_width: float = 2.0


@export_category("Pixel Progress Bar")
@export var progress_color: Color = Color.YELLOW
@export var progress_empty_color: Color = Color(0.2, 0.2, 0.2)
@export var progress_border_color: Color = Color.BLACK

@export_range(1, 30, 1)
var progress_segments: int = 12

@export_range(1, 20, 1)
var segment_width: int = 6

@export_range(1, 20, 1)
var segment_height: int = 8

@export_range(0, 10, 1)
var segment_gap: int = 2

@export_range(0, 10, 1)
var border_width: int = 2


var is_interact: bool = false
var is_progress: bool = false
var progress: float = 0.0


# -------------------------
# CURSOR STATE
# -------------------------

func set_interact(value: bool) -> void:
	if is_interact == value and not is_progress:
		return

	is_interact = value
	is_progress = false
	queue_redraw()


func set_progress_mode(value: bool) -> void:
	if is_progress == value:
		return

	is_progress = value
	queue_redraw()


func set_progress(value: float) -> void:
	var new_progress: float = clampf(value, 0.0, 1.0)

	if is_equal_approx(progress, new_progress):
		return

	progress = new_progress
	queue_redraw()


# -------------------------
# DRAW
# -------------------------

func _draw() -> void:
	if is_progress:
		_draw_progress_bar()
	else:
		_draw_crosshair()


# -------------------------
# CROSSHAIR
# -------------------------

func _draw_crosshair() -> void:
	var center: Vector2 = size / 2.0

	var color: Color = (
		interact_color if is_interact else normal_color
	)

	# Left
	draw_line(
		center + Vector2(-line_gap - line_length, 0),
		center + Vector2(-line_gap, 0),
		color,
		line_width
	)

	# Right
	draw_line(
		center + Vector2(line_gap, 0),
		center + Vector2(line_gap + line_length, 0),
		color,
		line_width
	)

	# Top
	draw_line(
		center + Vector2(0, -line_gap - line_length),
		center + Vector2(0, -line_gap),
		color,
		line_width
	)

	# Bottom
	draw_line(
		center + Vector2(0, line_gap),
		center + Vector2(0, line_gap + line_length),
		color,
		line_width
	)


# -------------------------
# PIXEL PROGRESS BAR
# -------------------------

func _draw_progress_bar() -> void:
	var total_width: float = float(
		progress_segments * segment_width
		+ (progress_segments - 1) * segment_gap
	)

	var bar_size: Vector2 = Vector2(
		total_width,
		float(segment_height)
	)

	# Center the bar on screen.
	var start: Vector2 = ((size - bar_size) / 2.0).round()

	# Black border.
	var border: Vector2 = Vector2(
		float(border_width),
		float(border_width)
	)

	draw_rect(
		Rect2(
			start - border,
			bar_size + border * 2.0
		),
		progress_border_color
	)

	# Number of filled segments.
	var filled_segments: int = ceili(
		progress * float(progress_segments)
	)

	for i in range(progress_segments):
		var segment_position: Vector2 = start + Vector2(
			float(i * (segment_width + segment_gap)),
			0.0
		)

		var color: Color = (
			progress_color
			if i < filled_segments
			else progress_empty_color
		)

		draw_rect(
			Rect2(
				segment_position,
				Vector2(
					float(segment_width),
					float(segment_height)
				)
			),
			color
		)
