extends Resource
class_name NoteData

@export var title: String = "Untitled"
@export_multiline var content: String = ""

@export_group("Appearance")
@export var background: Texture2D
@export var font: Font
@export var text_color: Color = Color.WHITE
