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
	# Chi dung cho trang Map003+ (ve theo map); sao nay neo CAMERA.
var lit := false
var moon_on := false  # Test doc duoc: true khi troi toi co trang.
var stars_drawn := false  # Test doc duoc: true khi sao da duoc ve.
var star_screen_top := 0.0  # Test doc duoc: man hinh y tren cua dai sao.
var star_screen_bottom := 0.0  # Test doc duoc: man hinh y duoi cua dai sao.
var sky_in_image := false  # Map co anh nen dem rieng (1-2): trang/sao
	# da nam trong anh — NightGlow chi ve quang den long, khong ve
	# them trang/sao (trung) hay cua so sang (de lech vi tri).
var _last_cam := Vector2.INF  # Vi tri camera lan ve gan nhat.

## Sao neo theo CAMERA (giong SkyEffects._cam_anchor): toa do man
## hinh co dinh, khong neo theo map — neo map thi camera doi cho
## la sao troi khoi khung hoac roi xuong mai hien (vong 16).
func _cam_anchor(screen_pos: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return screen_pos
	var vp := get_viewport_rect().size
	var top_left := cam.get_screen_center_position() - vp / (2.0 * cam.zoom)
	return top_left + screen_pos / cam.zoom

func _process(_delta: float) -> void:
	# Sao neo camera: camera doi cho thi ve lai (nhu SkyEffects).
	if not lit:
		return
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var cp := cam.get_screen_center_position()
		if cp.distance_to(_last_cam) > 2.0:
			_last_cam = cp
			queue_redraw()

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
	# SAO — NEO CAMERA (vong 17, thay neo map theo sky_top):
	# Dai sao cu (sky_top.y+200..280 = the gioi y -108..-28) roi len
	# mai hien/bien hieu Map001 (anh nha ong cao khong co vung troi
	# that trong tam nhin — toan bo nua tren man hinh la mat tien),
	# nhin nhu bui sang tren mai hien (kiem live r16). Nay sao o
	# dai man hinh y 208..262: duoi HUD (~200), tren mai hien
	# (~280) — cung thu thuat nhu trang neo camera (400,240) cua
	# SkyEffects: "sao tren mai nha" doc duoc nhu troi dem. Map003+
	# dai nay la troi that (sky_band/sky_wide phu kin tren) nen
	# van dung. Giu nguyen so luong (64/36), co, mau HDR.
	var star_count := 64 if sky_in_image else 36
	star_screen_top = 208.0
	star_screen_bottom = 262.0
	for i in range(star_count):
		var sx := 24.0 + fmod(float(i) * 197.0, 672.0)
		var sy := 208.0 + fmod(float(i) * 131.0, 54.0)
		var a := 0.5 + 0.45 * fmod(float(i) * 0.37, 1.0)
		draw_circle(_cam_anchor(Vector2(sx, sy)), 2.5 + fmod(float(i) * 0.61, 2.0), Color(2.5, 2.5, 2.5, a))
	stars_drawn = true
	# Trang chi ve khi troi KHONG nam trong anh nen (Map003+):
	# Map001-002 co trang trong anh dem rieng roi.
	# Trang o sky_top+(560,250) (the gioi y -58): trung voi trang
	# neo camera (400,240) cua SkyEffects o luc spawn nen chi thay
	# 1 trang. Sao thi KHONG dung dai nay nua (xem tren — sao nay
	# neo camera o dai man hinh 208..262).
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
