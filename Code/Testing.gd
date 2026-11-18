extends Node


const RIFLE_DATA = preload(
	"res://System/Item_system/Item_resource/Weapon/Rifle.tres")


func _ready() -> void:

	print("===== ITEM DATA =====")

	print("ID: ", RIFLE_DATA.item_id)
	print("Name: ", RIFLE_DATA.display_name)
	print("Type: ", RIFLE_DATA.item_type)
	print("Weight: ", RIFLE_DATA.weight)

	print("===== WEAPON DATA =====")

	var weapon: RangedWeaponData = RIFLE_DATA.weapon_data

	if weapon == null:
		print("Weapon Data is missing!")
		return

	print("Damage: ", weapon.damage)
	print("Fire Rate: ", weapon.fire_rate)
	print("Magazine: ", weapon.magazine_size)
	print("Reload Time: ", weapon.reload_time)
	print("Ammo ID: ", weapon.ammo_item_id)
