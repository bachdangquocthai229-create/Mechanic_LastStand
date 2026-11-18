
class_name ItemInstance
extends RefCounted


var item_data: ItemData
var quantity: int = 1

# Runtime state riêng của từng bản thể.
var runtime_state: Dictionary = {}


static func create(
	data: ItemData,
	amount: int = 1
) -> ItemInstance:

	if data == null:
		push_error("Cannot create ItemInstance: ItemData is null.")
		return null

	if amount < 1:
		push_error("Cannot create ItemInstance: Invalid quantity.")
		return null

	if amount > data.max_stack:
		push_error("Cannot create ItemInstance: Quantity exceeds max_stack.")
		return null

	var instance := ItemInstance.new()

	instance.item_data = data
	instance.quantity = amount

	return instance


func can_stack_with(other: ItemInstance) -> bool:

	if other == null:
		return false

	if item_data == null or other.item_data == null:
		return false

	if not item_data.is_stackable():
		return false

	return item_data == other.item_data
