class_name MeleeWeaponData
extends WeaponData

@export_group("Melee Weapon Properties")

@export var attack_rate: float = 1.0

@export var attack_range: float = 30.0

@export_range(0.0, 360.0) var attack_arc: float = 90.0

@export var knockback: float = 0.0
