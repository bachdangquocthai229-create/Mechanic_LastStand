extends Button

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Kích hoạt action giống như đang giữ phím
	Input.action_press("MENU")
	
	# Nếu action đó chỉ diễn ra tức thời (như click chuột/nhấn nhả), 
	# bạn có thể gọi action_release ngay sau đó:
	# Input.action_release(target_action)
	
	print("Đã kích hoạt action: ")
