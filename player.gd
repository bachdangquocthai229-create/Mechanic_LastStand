extends CharacterBody2D

# Tốc độ di chuyển của nhân vật (có thể chỉnh sửa trực tiếp trong Inspector)
@export var speed: float = 300.0
@export var acceleration: float = 1200.0   # Tốc độ gia tốc (càng lớn tăng tốc càng nhanh)
@export var friction: float = 1000.0       # Độ ma sát / giảm tốc khi thả phím

func _physics_process(delta: float) -> void:
	# Lấy hướng đầu vào từ bàn phím (WASD hoặc Phím mũi tên)
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if direction != Vector2.ZERO:
		# Khi đang nhấn phím: Tăng dần vận tốc về phía hướng mong muốn
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		# Khi thả phím: Giảm dần vận tốc về 0 (tạo hiệu ứng trượt)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Thực hiện di chuyển và tự động xử lý va chạm với tường/vật cản
	move_and_slide()
	
func _process(_delta: float) -> void:
	# Xoay node hướng về vị trí của con trỏ chuột
	look_at(get_global_mouse_position())
