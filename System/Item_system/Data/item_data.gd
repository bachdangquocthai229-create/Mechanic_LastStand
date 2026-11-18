class_name ItemData
extends Resource

enum ItemType {
	WEAPON,
	EQUIPMENT,
	CONSUMABLE,
	BACKPACK,
	AMMO,
	MATERIAL,
	KEY,
	TOOL,
	GENERAL
}


@export_group("Basic Information")

@export var item_id: StringName

@export var display_name: String

@export_multiline var description: String


@export_group("Visual")

@export var icon: Texture2D

@export var world_scene: PackedScene


@export_group("Item Properties")

@export var item_type: ItemType = ItemType.GENERAL

@export_range(1, 999) var max_stack: int = 1

@export_range(0.0, 9999.0, 0.01) var weight: float = 0.0


@export_group("Capabilities")

@export var weapon_data: WeaponData

@export var interactions: Array[InteractionData] = []


func is_stackable() -> bool:
	return max_stack > 1
