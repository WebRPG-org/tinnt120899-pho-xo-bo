class_name NightGlow
extends Node2D
## NightGlow — Dom sang cua so nha vao khung Toi.
## Ve hao quang am + 2 o cua sang vang tren moi nha o hang tren
## (ty = 0) cua map. Chi bat khi khung Toi (Main goi set_lit).
## Nha van nhin thay: hao quang chi them anh sang, khong phu mo.

var spots: Array[Vector2] = []
var lit := false

func set_spots(s: Array[Vector2]) -> void:
	spots = s
	queue_redraw()

func set_lit(on: bool) -> void:
	if lit != on:
		lit = on
		visible = on
		queue_redraw()

func _draw() -> void:
	if not lit:
		return
	for p in spots:
		# Hao quang am lan ra quanh cua so.
		draw_circle(p, 34.0, Color(1.0, 0.8, 0.35, 0.08))
		draw_circle(p, 20.0, Color(1.0, 0.8, 0.35, 0.14))
		# 2 o cua sang (khung cua toi, tam sang vang).
		draw_rect(Rect2(p + Vector2(-13, -7), Vector2(10, 14)), Color(0.35, 0.25, 0.15, 0.9))
		draw_rect(Rect2(p + Vector2(3, -7), Vector2(10, 14)), Color(0.35, 0.25, 0.15, 0.9))
		draw_rect(Rect2(p + Vector2(-12, -6), Vector2(8, 12)), Color(1.0, 0.85, 0.4, 0.95))
		draw_rect(Rect2(p + Vector2(4, -6), Vector2(8, 12)), Color(1.0, 0.85, 0.4, 0.95))
