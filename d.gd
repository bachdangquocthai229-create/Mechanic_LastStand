extends Button


# Đổi chữ "W" thành tên action tương ứng của nút này (ví dụ: "W", "A", "S", hoặc "D")
@export var action_name: String = "D"

func _on_button_down() -> void:
	# Kích hoạt action ngay lập tức giống như đang giữ phím
	Input.action_press(action_name)
	print("pressed")

func _on_button_up() -> void:
	# Giải phóng action khi nhấc tay ra
	Input.action_release(action_name)
