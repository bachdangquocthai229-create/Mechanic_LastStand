
extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1200.0
@export var friction: float = 1000.0

@onready var ui_mobile = $Camera2D/CanvasLayer

@onready var detection_area: Area2D = $DetectionArea

@export var bullet_scene: PackedScene
@onready var gun: Node2D = $Item_holder/Gun_1
@onready var bullet_spawn: Marker2D = $Item_holder/Gun_1/Marker2D


var is_mobile: bool = false
var is_desktop: bool = true

# Hướng di chuyển gần nhất khác Vector2.ZERO
var last_move_direction: Vector2 = Vector2.RIGHT

# Enemy đang được chọn làm mục tiêu
var current_target: Node2D = null


func _ready() -> void:
	var current_os := OS.get_name()

	is_mobile = current_os in ["Android", "iOS"]
	is_desktop = not is_mobile
	if current_os == "Android" or current_os == "iOS":
		ui_mobile.show()
	else:
		ui_mobile.queue_free()


func _physics_process(delta: float) -> void:
	# Đọc input di chuyển
	var direction: Vector2 = Input.get_vector(
		"A", "D", "W", "S"
	)

	# Cập nhật hướng di chuyển gần nhất
	if direction != Vector2.ZERO:
		last_move_direction = direction

		velocity = velocity.move_toward(
			direction * speed,
			acceleration * delta
		)
	else:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			friction * delta
		)

	move_and_slide()

	# Chỉ tự động chọn mục tiêu trên mobile
	if is_mobile:
		current_target = _find_closest_enemy_in_area()


func _process(_delta: float) -> void:
	if is_desktop:
		# PC: Ngắm theo vị trí chuột
		look_at(get_global_mouse_position())

	elif is_mobile:
		if is_instance_valid(current_target):
			# Có enemy: Ưu tiên ngắm enemy gần nhất
			look_at(current_target.global_position)
		else:
			# Không có enemy: Hướng theo hướng di chuyển gần nhất
			rotation = last_move_direction.angle()

	if Input.is_action_just_pressed("Attack"):
		shoot()



func _find_closest_enemy_in_area() -> Node2D:
	var closest_enemy: Node2D = null
	var min_distance_squared: float = INF

	for body in detection_area.get_overlapping_bodies():
		if not body.is_in_group("Enemy"):
			continue

		var enemy := body as Node2D

		if enemy == null:
			continue

		var distance_squared := global_position.distance_squared_to(
			enemy.global_position
		)

		if distance_squared < min_distance_squared:
			min_distance_squared = distance_squared
			closest_enemy = enemy

	return closest_enemy


func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = bullet_spawn.global_position

	# Hướng bắn theo hướng của súng
	bullet.direction = Vector2.RIGHT.rotated(gun.global_rotation)
	bullet.rotation = bullet.direction.angle()
