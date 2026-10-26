@tool
extends RayInteraction
class_name NoteInteraction

@export_category("Note Settings")
@export var note_manager: NoteManager

@export var reading_mode: NoteManager.ReadingMode = \
	NoteManager.ReadingMode.PAUSE


func can_interact(target: CollisionObject3D) -> bool:
	if not is_instance_valid(note_manager):
		return false

	if note_manager.is_reading:
		return false

	return (
		target is NoteWorld
		and target.note != null
	)



func interact(target: CollisionObject3D) -> void:
	var note := target as NoteWorld

	if note == null:
		return

	if not is_instance_valid(note_manager):
		return

	note_manager.open_note(
		note.note,
		reading_mode
	)
