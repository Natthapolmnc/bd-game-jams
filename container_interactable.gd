extends Node3D
class_name ContainerInteractable


# -------------------------
# SIGNALS
# -------------------------

signal search_completed
signal on_lid_move


# -------------------------
# EXPORTS
# -------------------------

@export_category("Search")

@export var one_time_search: bool = true

@export var is_bullet_box: bool = true


@export_category("Container Loot")

# Used only when is_bullet_box == false.
@export_enum(
	"book",
	"dogtag",
	"match",
	"picture",
	"bullet",
	"pocketwatch"
)
var selected_item: String = "book"

@export_range(0, 100, 1)
var selected_amount: int = 1


# -------------------------
# INVENTORY
# -------------------------

var contained_item: Dictionary[String, int] = {
	"book": 0,
	"dogtag": 0,
	"match": 0,
	"picture": 0,
	"bullet": 0,
	"pocketwatch": 0,
}


# -------------------------
# REFERENCES
# -------------------------

@onready var anim_player: AnimationPlayer = $animPlayer


# -------------------------
# STATE
# -------------------------

var was_searched: bool = false
var is_open: bool = false


# -------------------------
# HIGHLIGHT
# -------------------------

const HIGHLIGHT_SHADER = preload(
	"res://scripts/interaction_highlight.gdshader"
)

var highlight_material: ShaderMaterial

var highlight_meshes: Array[MeshInstance3D] = []
var original_overlays: Array[Material] = []


# -------------------------
# INITIALIZATION
# -------------------------

func _ready() -> void:
	_setup_highlight()
	_setup_loot()

	print(
		"[CONTAINER READY] ",
		get_path(),
		" | ID: ", get_instance_id(),
		" | Bullet Box: ", is_bullet_box,
		" | Selected: ", selected_item,
		" | Loot: ", contained_item
	)


# -------------------------
# LOOT INITIALIZATION
# -------------------------

func _setup_loot() -> void:

	# Reset all items.
	for item_name: String in contained_item:
		contained_item[item_name] = 0

	if is_bullet_box:
		_generate_bullets()
	else:
		_setup_selected_item()


# -------------------------
# RANDOM BULLET GENERATION
# -------------------------

func _generate_bullets() -> void:

	var possible_bullets: Array[int] = [0, 1, 2]

	var weights := PackedFloat32Array([
		0.7,
		0.2,
		0.1
	])

	var rng := RandomNumberGenerator.new()

	var selected_index: int = rng.rand_weighted(weights)

	contained_item["bullet"] = possible_bullets[selected_index]


# -------------------------
# SELECTED ITEM
# -------------------------

func _setup_selected_item() -> void:

	if not contained_item.has(selected_item):
		push_warning("Invalid item: " + selected_item)
		return

	contained_item[selected_item] = selected_amount

	print("Selected item: ", selected_item)
	print("Contained items: ", contained_item)


# -------------------------
# SEARCH
# -------------------------

func can_search() -> bool:
	return not one_time_search or not was_searched


func complete_search() -> void:

	if not can_search():
		return

	was_searched = true

	open_container()

	search_completed.emit()


# -------------------------
# LID CONTROL
# -------------------------

func open_container() -> void:
	set_open(true)


func close_container() -> void:
	set_open(false)


func toggle_interaction() -> void:
	set_open(not is_open)


func set_open(value: bool) -> void:

	if is_open == value:
		return

	is_open = value

	_update_lid_animation()

	on_lid_move.emit()


# -------------------------
# HIGHLIGHT INITIALIZATION
# -------------------------

func _setup_highlight() -> void:

	highlight_material = ShaderMaterial.new()
	highlight_material.shader = HIGHLIGHT_SHADER

	highlight_meshes.clear()
	original_overlays.clear()

	for node: Node in find_children(
		"*",
		"MeshInstance3D",
		true,
		false
	):

		var mesh: MeshInstance3D = node as MeshInstance3D

		highlight_meshes.append(mesh)
		original_overlays.append(mesh.material_overlay)


# -------------------------
# HIGHLIGHT CONTROL
# -------------------------

func set_highlight(value: bool) -> void:

	for i: int in range(highlight_meshes.size()):

		var mesh: MeshInstance3D = highlight_meshes[i]

		if not is_instance_valid(mesh):
			continue

		if value:
			mesh.material_overlay = highlight_material
		else:
			mesh.material_overlay = original_overlays[i]


# -------------------------
# ANIMATION
# -------------------------

func _update_lid_animation() -> void:

	if is_open:
		anim_player.play("open")
	else:
		anim_player.play("close")
