
extends Node2D

@export_group("Arm References")
@export var shoulder: Marker2D
@export var upper_arm: Sprite2D
@export var forearm: Sprite2D
@export var target: Node2D

@export_group("Arm Dimensions")
@export var upper_length: float = 12.0
@export var forearm_length: float = 12.0

@export_group("Elbow Direction")
@export_range(-1.0, 1.0, 2.0)
var bend_direction: float = 1.0


func _process(_delta: float) -> void:
	if not is_instance_valid(target):
		return

	solve_ik()


func solve_ik() -> void:
	# Global positions of shoulder and hand
	var a: Vector2 = shoulder.global_position
	var b: Vector2 = target.global_position

	# Direction from shoulder to hand
	var distance_vector: Vector2 = b - a
	var distance: float = distance_vector.length()

	if distance < 0.001:
		return

	# Prevent unreachable arm positions
	var min_distance: float = abs(upper_length - forearm_length) + 0.001
	var max_distance: float = upper_length + forearm_length - 0.001

	var clamped_distance: float = clampf(
		distance,
		min_distance,
		max_distance
	)

	var direction: Vector2 = distance_vector.normalized()

	# Calculate elbow position using 2-Bone IK
	var x: float = (
		upper_length * upper_length
		- forearm_length * forearm_length
		+ clamped_distance * clamped_distance
	) / (2.0 * clamped_distance)

	var h: float = sqrt(
		maxf(0.0, upper_length * upper_length - x * x)
	)

	# Perpendicular direction
	var perpendicular := Vector2(-direction.y, direction.x)

	# Final elbow position
	var elbow: Vector2 = (
		a
		+ direction * x
		+ perpendicular * h * bend_direction
	)

	# Adjust hand position if target is outside arm reach
	var hand_position: Vector2 = a + direction * clamped_distance

	# Position and rotate upper arm
	update_segment(upper_arm, a, elbow)

	# Position and rotate forearm
	update_segment(forearm, elbow, hand_position)


func update_segment(
	sprite: Sprite2D,
	start: Vector2,
	finish: Vector2
) -> void:

	var segment: Vector2 = finish - start

	sprite.global_position = (start + finish) * 0.5
	sprite.global_rotation = segment.angle()
