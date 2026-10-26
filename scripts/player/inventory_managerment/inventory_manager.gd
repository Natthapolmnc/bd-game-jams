extends Node3D
class_name InventoryManager

signal inventory_changed(item_name: String, new_amount: int)

var inventory: Dictionary[String, int] = {
	"book": 0,
	"dogtag": 0,
	"match":0,
	"picture":0,
	"bullet": 0,
	"pocketwatch": 0,
}


# -------------------------
# ITEM QUANTITY
# -------------------------

func get_amount(item_name: String) -> int:
	return int(inventory.get(item_name, 0))


func is_valid_item(item_name: String) -> bool:
	return inventory.has(item_name)


# -------------------------
# BOOLEAN CHECKS
# -------------------------

func has_item(item_name: String) -> bool:
	return get_amount(item_name) > 0


func has_at_least(item_name: String, amount: int) -> bool:
	return amount > 0 and get_amount(item_name) >= amount


func has_less_than(item_name: String, amount: int) -> bool:
	return get_amount(item_name) < amount


func has_exactly(item_name: String, amount: int) -> bool:
	return get_amount(item_name) == amount


func is_empty(item_name: String) -> bool:
	return get_amount(item_name) == 0


# -------------------------
# INVENTORY ACTIONS
# -------------------------

func add_item(item_name: String, amount: int = 1) -> bool:
	if not is_valid_item(item_name) or amount <= 0:
		return false

	inventory[item_name] = get_amount(item_name) + amount

	inventory_changed.emit(item_name, inventory[item_name])

	return true


func remove_item(item_name: String, amount: int = 1) -> bool:
	if not has_at_least(item_name, amount):
		return false

	inventory[item_name] = get_amount(item_name) - amount

	inventory_changed.emit(item_name, inventory[item_name])

	return true
	
# -------------------------
# LOOT COLLECTION
# -------------------------

func collect_loot(items: Dictionary[String, int]) -> bool:

	# Validate items before transferring anything.
	for item_name: String in items:

		if items[item_name] <= 0:
			continue

		if not is_valid_item(item_name):
			push_warning("Invalid inventory item: " + item_name)
			return false

	# Transfer items.
	for item_name: String in items:

		var amount: int = items[item_name]

		if amount <= 0:
			continue

		if add_item(item_name, amount):

			# Empty the source container.
			items[item_name] = 0

	return true
