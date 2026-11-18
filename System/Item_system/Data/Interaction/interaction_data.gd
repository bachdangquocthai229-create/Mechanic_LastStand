class_name InteractionData
extends Resource

enum InteractionType {
	PRYING,
	UNLOCKING,
	CHOPPING,
	BREAKING
}

@export_group("Interaction Properties")

@export var interaction_type: InteractionType

@export var interaction_name: String

@export var target_groups: Array[StringName] = []

@export var interaction_power: float = 1.0
