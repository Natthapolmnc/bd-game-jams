extends Control
class_name InventoryUI


# -------------------------
# REFERENCES
# -------------------------

@export var inv_manager: InventoryManager

@onready var bullet_label: Label = $inventory/bullet_ui/Label
@onready var match_label: Label = $inventory/match/Label

@onready var pocketwatch: TextureRect = $inventory/pocketwatch
@onready var dogtag: TextureRect = $inventory/doctag
@onready var book: TextureRect = $inventory/book
@onready var picture: TextureRect = $inventory/picture


# -------------------------
# ITEM UI DICTIONARY
# -------------------------

@onready var itm_text_dict: Dictionary[String, TextureRect] = {
	"picture": picture,
	"dogtag": dogtag,
	"book": book,
	"pocketwatch": pocketwatch
}


# -------------------------
# INITIALIZATION
# -------------------------

func _ready() -> void:

	if not is_instance_valid(inv_manager):
		push_error("InventoryManager is not assigned.")
		return

	inv_manager.inventory_changed.connect(
		_on_inventory_changed
	)

	update_inventory_ui()


# -------------------------
# INVENTORY SIGNAL
# -------------------------

func _on_inventory_changed(
	_item_name: String,
	_new_amount: int
) -> void:

	update_inventory_ui()


# -------------------------
# UPDATE UI
# -------------------------

func update_inventory_ui() -> void:

	if not is_instance_valid(inv_manager):
		return

	# Update quantity labels.
	bullet_label.text = str(
		inv_manager.get_amount("bullet")
	)

	match_label.text = str(
		inv_manager.get_amount("match")
	)

	# Update item visibility.
	for item_name: String in itm_text_dict:

		var item_ui: TextureRect = itm_text_dict[item_name]

		if not is_instance_valid(item_ui):
			continue

		item_ui.visible = inv_manager.has_item(item_name)
