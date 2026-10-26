@tool
extends StaticBody3D
class_name NoteWorld

@export var note: NoteData

@onready var mesh: MeshInstance3D = $CollisionShape3D/mesh

const HIGHLIGHT_SHADER = preload(
    "res://scripts/interaction_highlight.gdshader"
	
)

var highlight_material: ShaderMaterial
var original_overlay: Material


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	original_overlay = mesh.material_overlay

	# Create a material using the shader.
	highlight_material = ShaderMaterial.new()
	highlight_material.shader = HIGHLIGHT_SHADER


func set_highlight(value: bool) -> void:
	if not is_instance_valid(mesh):
		return

	if value:
		mesh.material_overlay = highlight_material
	else:
		mesh.material_overlay = original_overlay
