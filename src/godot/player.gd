extends Node2D
## Player.gd — Nhân vật test G0: di chuyển bằng WASD / phím mũi tên / chạm-kéo.
## Vẽ bằng code (chưa có sprite thật): đầu tròn + thân áo — placeholder tới G1.

const SPEED := 260.0
const RADIUS := 34.0

var touch_target: Vector2 = Vector2.INF

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Bóng dưới chân (hình tròn bẹt bằng transform).
	draw_set_transform(Vector2(0, 44), 0.0, Vector2(1.0, 0.33))
	draw_circle(Vector2.ZERO, 30, Color(0, 0, 0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Thân áo (xanh lá — màu Trí trong hệ 3 màu của GDD).
	draw_rect(Rect2(-24, -6, 48, 52), Color(0.25, 0.65, 0.35, 1))
	# Đầu.
	draw_circle(Vector2(0, -26), 22, Color(0.96, 0.82, 0.66, 1))
	# Tóc.
	draw_arc(Vector2(0, -28), 22, PI, TAU, 16, Color(0.12, 0.1, 0.1, 1), 8.0)

func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dir.length() > 0.0:
		touch_target = Vector2.INF
		position += dir.normalized() * SPEED * delta
	elif touch_target != Vector2.INF:
		var to_target := touch_target - position
		if to_target.length() < 8.0:
			touch_target = Vector2.INF
		else:
			position += to_target.normalized() * SPEED * delta
	_clamp_to_viewport()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		touch_target = event.position
	elif event is InputEventScreenDrag:
		touch_target = event.position

func _clamp_to_viewport() -> void:
	var size := get_viewport_rect().size
	position.x = clampf(position.x, RADIUS, size.x - RADIUS)
	position.y = clampf(position.y, RADIUS, size.y - RADIUS)
