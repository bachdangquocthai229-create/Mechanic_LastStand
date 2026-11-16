extends Node2D

# NODE REFERENCES
@onready var item_motion: Node2D = get_node("../Item_motion")
@onready var item_holder: Node2D = item_motion.get_node("Item_holder")
@onready var elbow_pole: Marker2D = $Elbow_pole
@onready var shoulder: Marker2D = $Shoulder
@onready var upper_arm: Sprite2D = $Right_arm/Upper_arm
@onready var forearm: Sprite2D = $Right_arm/Forearm

@export var test_item_scene: PackedScene

# ARM CONFIGURATION
@export_group("Arm Length")
@export var upper_arm_length: float = 21.0
@export var forearm_length: float = 20.0

@export_group("IK Settings")
@export var ik_epsilon: float = 0.001

var right_hand_marker: Marker2D = null

var right_hand_target: Vector2 = Vector2.ZERO
var previous_target: Vector2 = Vector2.INF

# INITIALIZATION
func _ready() -> void:
	item_holder.child_entered_tree.connect(
		_on_item_entered_tree
	)

	item_holder.child_exiting_tree.connect(
		_on_item_exiting_tree
	)

	refresh_grip_point()

# FIND GRIP POINT
func refresh_grip_point() -> bool:
	right_hand_marker = null

	if item_holder.get_child_count() == 0:
		print("Item_holder hiện không có vật phẩm.")
		return false

	var equipped_item: Node = item_holder.get_child(0)

	var candidate: Node = equipped_item.get_node_or_null(
        "Grip_point/Right_hand"
	)

	if not candidate is Marker2D:
		push_warning("Không tìm thấy Marker2D Right_hand.")
		return false

	right_hand_marker = candidate as Marker2D

	previous_target = Vector2.INF

	print("Đã tìm thấy Right_hand: ", right_hand_marker.get_path())

	return true

# UPDATE IK
func _process(_delta: float) -> void:

	if not is_instance_valid(right_hand_marker):
		return

	# Chuyển Right_hand sang hệ tọa độ Arm_rig
	right_hand_target = to_local(
		right_hand_marker.global_position
	)

	if right_hand_target.is_equal_approx(previous_target):
		return

	previous_target = right_hand_target

	calculate_ik()

# TWO-BONE IK


func calculate_ik() -> void:
	var start: Vector2 = shoulder.position
	var target: Vector2 = right_hand_target

	var direction_vector: Vector2 = target - start
	var distance: float = direction_vector.length()

	# Tránh trường hợp vai và bàn tay trùng vị trí
	if distance < ik_epsilon:
		print("IK không hợp lệ: khoảng cách quá nhỏ.")
		return

	# Giới hạn khoảng cách để hai đoạn tay luôn có chiều dài cố định
	var min_distance: float = abs(
		upper_arm_length - forearm_length
	) + ik_epsilon

	var max_distance: float = (
		upper_arm_length + forearm_length
	) - ik_epsilon

	var clamped_distance: float = clampf(
		distance,
		min_distance,
		max_distance
	)

	var direction: Vector2 = direction_vector.normalized()

	var reachable_target: Vector2 = (
		start + direction * clamped_distance
	)

	# CALCULATE ELBOW GEOMETRY
	var a: float = (
		upper_arm_length * upper_arm_length
		- forearm_length * forearm_length
		+ clamped_distance * clamped_distance
	) / (2.0 * clamped_distance)

	var h_squared: float = (
		upper_arm_length * upper_arm_length
		- a * a
	)

	var h: float = sqrt(maxf(h_squared, 0.0))

	var midpoint: Vector2 = start + direction * a

	# Vector vuông góc với hướng vai -> bàn tay
	var perpendicular: Vector2 = Vector2(
		-direction.y,
		direction.x
	)

	# Hai nghiệm khuỷu tay
	var elbow_candidate_1: Vector2 = (
		midpoint + perpendicular * h
	)

	var elbow_candidate_2: Vector2 = (
		midpoint - perpendicular * h
	)

	# ELBOW SELECTION
	var hand_direction: Vector2 = direction
	var desired_elbow_direction: Vector2

	if hand_direction.x < 0.0:
		# Tay cầm ở phía sau.
		desired_elbow_direction = Vector2(-1.0, 1.0).normalized()
	else:
		# Tay cầm ở phía trước.
		desired_elbow_direction = Vector2.DOWN

	var side_1: float = (
		(elbow_candidate_1 - start).normalized()
		.dot(desired_elbow_direction)
	)

	var side_2: float = (
		(elbow_candidate_2 - start).normalized()
		.dot(desired_elbow_direction)
	)

	var final_elbow: Vector2

	if side_1 >= side_2:
		final_elbow = elbow_candidate_1
	else:
		final_elbow = elbow_candidate_2

	# APPLY ARM POSE
	apply_arm_pose(final_elbow, reachable_target)


	# DEBUG OUTPUT
	print("-----------------------------")
	print("Shoulder: ", start)
	print("Right_hand: ", target)
	print("Requested distance: ", distance)
	print("Reachable target: ", reachable_target)
	print("Elbow candidate 1: ", elbow_candidate_1)
	print("Elbow candidate 2: ", elbow_candidate_2)
	print("Desired elbow direction: ", desired_elbow_direction)
	print("Selected elbow: ", final_elbow)

	if not is_equal_approx(distance, clamped_distance):
		print("WARNING: Target nằm ngoài tầm với.")


func apply_arm_pose(elbow_position: Vector2, hand_position: Vector2) -> void:
	# Đặt gốc Upper_arm tại vai.
	upper_arm.position = shoulder.position

	# Xoay Upper_arm theo hướng từ vai đến khuỷu tay.
	var upper_direction: Vector2 = elbow_position - shoulder.position
	upper_arm.rotation = upper_direction.angle()

	# Đặt gốc Forearm tại khuỷu tay.
	forearm.position = elbow_position

	# Xoay Forearm theo hướng từ khuỷu tay đến bàn tay.
	var forearm_direction: Vector2 = hand_position - elbow_position
	forearm.rotation = forearm_direction.angle()

func _on_item_entered_tree(_node: Node) -> void:
	# Đợi vật phẩm vào SceneTree hoàn chỉnh rồi mới tìm Marker2D.
	refresh_grip_point.call_deferred()

func _on_item_exiting_tree(node: Node) -> void:
	# Nếu vật phẩm đang rời đi chứa Right_hand hiện tại,
	# xóa tham chiếu cũ.
	if is_instance_valid(right_hand_marker):
		if node == right_hand_marker or node.is_ancestor_of(right_hand_marker):
			right_hand_marker = null
			previous_target = Vector2.INF

func equip_item(new_item_scene: PackedScene) -> void:
	if new_item_scene == null:
		push_warning("Chưa gán scene vật phẩm mới.")
		return

	# Xóa vật phẩm hiện tại.
	for child in item_holder.get_children():
		item_holder.remove_child(child)
		child.queue_free()

	# Tạo và thêm vật phẩm mới.
	var new_item: Node2D = new_item_scene.instantiate()
	item_holder.add_child(new_item)

	print("Đã thay vật phẩm: ", new_item.name)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_F6:
				equip_item(test_item_scene)
