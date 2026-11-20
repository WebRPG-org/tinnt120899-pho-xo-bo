class_name NightGlow
extends Node2D
## NightGlow — Dom sang cua so nha vao khung Toi.
## Ve hao quang am + 2 o cua sang vang tren moi nha o hang tren
## (ty = 0) cua map. Chi bat khi khung Toi (Main goi set_lit).
## Nha van nhin thay: hao quang chi them anh sang, khong phu mo.
## Vong Nadia-style 20/11: ban dem them trang + sao tren dai troi
## + quang den duong (den long o goc phai duoi Map001).

var spots: Array[Vector2] = []
var lamps: Array[Vector2] = []  # Vi tri den duong (tam den).
var sky_top := Vector2.ZERO  # Goc tren-trai dai troi (he toa do IsoMap).
var lit := false
var moon_on := false  # Test doc duoc: true khi troi toi co trang.
var sky_in_image := false  # Map co anh nen dem rieng (1-2): trang/sao
	# da nam trong anh — NightGlow chi ve quang den long, khong ve
	# them trang/sao (trung) hay cua so sang (de lech vi tri).

func set_spots(s: Array[Vector2]) -> void:
	spots = s
	queue_redraw()

func set_sky(p: Vector2) -> void:
	sky_top = p

func set_lit(on: bool) -> void:
	if lit != on:
		lit = on
		moon_on = on
		visible = on
		queue_redraw()

func _draw() -> void:
	if not lit:
		return
	# Trang + sao chi ve khi troi KHONG nam trong anh nen (Map003+):
	# Map001-002 co trang/sao trong anh dem rieng roi.
	# Trang + sao (tren dai troi, tren ca anh nen). Dai troi chi hien
	# duoi HUD khi di len hang tren (HUD chiem game y 16..252) nen
	# trang/sao dat o NUA DUOI dai troi (gan mai nha) moi thay duoc:
	# trang o sky_top+(560,250) (the gioi y -58, ngay tren mai), sao
	# rai o 80px duoi cung cua dai troi.
	# MAU HDR (>1.0): lop overlay dem NHAN (0.42,0.52,0.85) nhan toi
	# moi thu duoi no — trang/sao/den la NGUON SANG phai xuyen qua
	# lop dem, nen ve bang mau >1 de sau khi nhan van sang (loi
	# 20/11 12:15: trang ve mau thuong bi nhan toi, chim vao troi dem).
	if not sky_in_image:
		var moon := sky_top + Vector2(560, 250)  # Giua dai troi (1120 rong).
		draw_circle(moon, 46.0, Color(2.0, 1.9, 1.5, 0.15))
		draw_circle(moon, 21.0, Color(2.2, 2.1, 1.8, 0.95))
		draw_circle(moon + Vector2(-6, -4), 4.0, Color(1.8, 1.7, 1.4, 0.9))
		draw_circle(moon + Vector2(6, 5), 3.0, Color(1.8, 1.7, 1.4, 0.9))
		for i in range(36):
			var sx := sky_top.x + fmod(float(i) * 197.0, 1120.0)
			var sy := sky_top.y + 200.0 + fmod(float(i) * 131.0, 80.0)
			var a := 0.35 + 0.45 * fmod(float(i) * 0.37, 1.0)
			draw_circle(Vector2(sx, sy), 2.0 + fmod(float(i) * 0.61, 2.0), Color(2.5, 2.5, 2.5, a))
	# Quang den duong (den long): quang lon + cham sang (HDR nhu tren).
	for p in lamps:
		draw_circle(p, 34.0, Color(2.0, 1.6, 0.7, 0.18))
		draw_circle(p, 5.0, Color(2.2, 1.9, 1.0, 0.95))
	# Cua so sang (HDR nhe de van am sau lop dem).
	for p in spots:
		# Hao quang am lan ra quanh cua so.
		draw_circle(p, 34.0, Color(1.3, 1.0, 0.45, 0.08))
		draw_circle(p, 20.0, Color(1.3, 1.0, 0.45, 0.14))
		# 2 o cua sang (khung cua toi, tam sang vang).
		draw_rect(Rect2(p + Vector2(-13, -7), Vector2(10, 14)), Color(0.35, 0.25, 0.15, 0.9))
		draw_rect(Rect2(p + Vector2(3, -7), Vector2(10, 14)), Color(0.35, 0.25, 0.15, 0.9))
		draw_rect(Rect2(p + Vector2(-12, -6), Vector2(8, 12)), Color(1.3, 1.1, 0.55, 0.95))
		draw_rect(Rect2(p + Vector2(4, -6), Vector2(8, 12)), Color(1.3, 1.1, 0.55, 0.95))
