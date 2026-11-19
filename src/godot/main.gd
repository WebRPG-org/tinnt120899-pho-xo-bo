extends Node2D
## Main.gd — Scene gốc G0 của Phố Xô Bồ (Godot).
## Vẽ nền phố (màu trưa nắng vàng nhạt) + giữ player ở giữa màn hình lúc khởi động.

const STREET_COLOR := Color(0.98, 0.93, 0.81, 1) # vàng nhạt như nắng trưa Sài Gòn

func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)
	var player := $Player
	player.position = get_viewport_rect().size * Vector2(0.5, 0.55)

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), STREET_COLOR)
	# Vạch vỉa hè đơn giản để thấy được tỉ lệ màn hình 9:16.
	var sidewalk := Rect2(0, size.y * 0.62, size.x, size.y * 0.38)
	draw_rect(sidewalk, Color(0.85, 0.82, 0.76, 1))
	draw_line(Vector2(0, size.y * 0.62), Vector2(size.x, size.y * 0.62), Color(0.7, 0.66, 0.58, 1), 4.0)
