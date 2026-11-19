class_name Marker
extends Node2D
## Marker — Diem tuong tac tren ban do iso: NPC / hotspot / goc che tao / cua.
## Ve bang code (placeholder toi khi co sprite that). Hotspot nhap nhay kieu Nadia.

var event_data: Dictionary = {}
var font: Font = null
var _pulse := 0.0

const NPC_COLORS := {
	"co-tu": Color(0.56, 0.27, 0.68, 1),
	"ban-than": Color(0.16, 0.50, 0.73, 1),
	"chi-le": Color(0.90, 0.45, 0.13, 1),
	"anh-hai": Color(0.09, 0.63, 0.52, 1),
}

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	if event_data.get("kind", "") == "hotspot":
		_pulse += delta
		queue_redraw()

func _draw() -> void:
	var kind := String(event_data.get("kind", ""))
	match kind:
		"npc":
			_draw_person(NPC_COLORS.get(String(event_data.get("id", "")), Color(0.5, 0.5, 0.5, 1)))
		"hotspot":
			_draw_hotspot()
		"craft":
			_draw_craft()
		"door":
			_draw_door()
	_draw_name()

func _draw_name() -> void:
	if font == null:
		return
	var text := String(event_data.get("name", ""))
	var size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	draw_string(font, Vector2(-size.x / 2.0, -52), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.15, 0.12, 0.08, 1))

func _draw_person(color: Color) -> void:
	draw_set_transform(Vector2(0, 16), 0.0, Vector2(1.0, 0.33))
	draw_circle(Vector2.ZERO, 16, Color(0, 0, 0, 0.20))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_rect(Rect2(-13, -18, 26, 32), color)
	draw_circle(Vector2(0, -28), 12, Color(0.96, 0.82, 0.66, 1))
	draw_arc(Vector2(0, -30), 12, PI, TAU, 12, Color(0.12, 0.1, 0.1, 1), 5.0)
	# Dau "!" goi tuong tac kieu Nadia.
	draw_circle(Vector2(16, -48), 9, Color(0.95, 0.75, 0.1, 1))
	if font != null:
		draw_string(font, Vector2(12, -41), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.2, 0.1, 0.0, 1))

func _draw_hotspot() -> void:
	var s := 1.0 + 0.18 * sin(_pulse * 4.0)
	var r := 14.0 * s
	var gold := Color(0.88, 0.66, 0.0, 1)
	var pts := PackedVector2Array([
		Vector2(0, -r), Vector2(r * 0.45, -r * 0.45), Vector2(r, 0),
		Vector2(r * 0.45, r * 0.45), Vector2(0, r),
		Vector2(-r * 0.45, r * 0.45), Vector2(-r, 0), Vector2(-r * 0.45, -r * 0.45),
	])
	draw_colored_polygon(pts, gold)
	draw_circle(Vector2(0, 0), 4.0, Color(1, 1, 1, 0.9))

func _draw_craft() -> void:
	draw_rect(Rect2(-16, -10, 32, 22), Color(0.55, 0.38, 0.22, 1))
	draw_rect(Rect2(-20, -16, 40, 8), Color(0.65, 0.48, 0.28, 1))
	draw_circle(Vector2(0, -26), 8, Color(0.95, 0.75, 0.1, 1))

func _draw_door() -> void:
	draw_rect(Rect2(-16, -30, 32, 44), Color(0.20, 0.55, 0.35, 1))
	draw_arc(Vector2(0, -30), 16, PI, TAU, 12, Color(0.20, 0.55, 0.35, 1), 6.0)
	draw_rect(Rect2(-8, -14, 16, 28), Color(0.85, 0.95, 0.9, 1))
