class_name AmbientLife
extends Node2D
## AmbientLife — Vong 19 (22/11): su song nho trong khung hinh.
## Muc (3) cua Claude (§35.6): 3-5 chuyen dong nho cho map bot tinh.
## Lam 2 thu, ca 2 neo theo CAMERA (toa do man hinh -> the gioi nhu
## NightGlow/SkyEffects) nen phu kin khung nhin bat ke camera o dau:
##  1. La roi: 14 la vang-xanh roi cham + lac ngang, lap lai tu tren
##     xuong — co o ca 3 khung (ban ngay ro nhat).
##  2. Dom dom: 10 cham sang am bay lang thang, CHI khung Toi.
## Vi tri dung RandomNumberGenerator seed co dinh (20261122) de test
## on dinh. sim_step(delta) la buoc mo phong that — _process goi no
## moi frame, test goi truc tiep de do chinh xac khong phu thuoc
## toc do frame headless.

const LEAF_COUNT := 14
const FLY_COUNT := 10
const SCREEN_W := 720.0
const SCREEN_H := 1280.0

var frame_idx := 0  # 0 Sang, 1 Chieu, 2 Toi.
var leaf_positions: Array[Vector2] = []  # Test doc duoc (man hinh).
var fly_positions: Array[Vector2] = []  # Test doc duoc (man hinh).
var fly_visible := false  # Test doc duoc: true chi khi khung Toi.
var _leaf_speed: Array[float] = []
var _leaf_phase: Array[float] = []
var _leaf_size: Array[float] = []
var _fly_phase: Array[float] = []
var _time := 0.0
var _rng := RandomNumberGenerator.new()

func _init() -> void:
	z_index = 10
	_rng.seed = 20261122
	for i in range(LEAF_COUNT):
		leaf_positions.append(Vector2(_rng.randf_range(0.0, SCREEN_W), _rng.randf_range(-40.0, SCREEN_H)))
		_leaf_speed.append(_rng.randf_range(24.0, 42.0))
		_leaf_phase.append(_rng.randf_range(0.0, TAU))
		_leaf_size.append(_rng.randf_range(4.5, 8.0))
	for i in range(FLY_COUNT):
		fly_positions.append(Vector2(_rng.randf_range(20.0, SCREEN_W - 20.0), _rng.randf_range(500.0, 1150.0)))
		_fly_phase.append(_rng.randf_range(0.0, TAU))

func set_frame(f: int) -> void:
	frame_idx = f
	fly_visible = (f == 2)
	queue_redraw()

func leaf_count() -> int:
	return leaf_positions.size()

## Neo man hinh -> the gioi (nhu SkyEffects._cam_anchor).
func _cam_anchor(screen_pos: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return screen_pos
	var vp := get_viewport_rect().size
	var top_left := cam.get_screen_center_position() - vp / (2.0 * cam.zoom)
	return top_left + screen_pos / cam.zoom

func _process(delta: float) -> void:
	sim_step(delta)

func sim_step(delta: float) -> void:
	_time += delta
	for i in range(LEAF_COUNT):
		var p: Vector2 = leaf_positions[i]
		p.y += _leaf_speed[i] * delta
		p.x += sin(_time * 0.9 + _leaf_phase[i]) * 14.0 * delta
		if p.y > SCREEN_H + 20.0:
			p.y = -30.0
			p.x = _rng.randf_range(0.0, SCREEN_W)
		if p.x < -20.0:
			p.x = SCREEN_W + 10.0
		elif p.x > SCREEN_W + 20.0:
			p.x = -10.0
		leaf_positions[i] = p
	if fly_visible:
		for i in range(FLY_COUNT):
			var p: Vector2 = fly_positions[i]
			p.x += sin(_time * 0.7 + _fly_phase[i]) * 10.0 * delta
			p.y += cos(_time * 0.55 + _fly_phase[i] * 1.7) * 8.0 * delta
			p.x = clampf(p.x, 20.0, SCREEN_W - 20.0)
			p.y = clampf(p.y, 480.0, 1180.0)
			fly_positions[i] = p
	queue_redraw()

func _draw() -> void:
	# La roi: ellipse mem vang-xanh, xoay theo pha.
	for i in range(LEAF_COUNT):
		var p: Vector2 = _cam_anchor(leaf_positions[i])
		var rot := sin(_time * 0.9 + _leaf_phase[i]) * 0.6
		draw_set_transform(p, rot, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, _leaf_size[i], Color(0.78, 0.68, 0.28, 0.7))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Dom dom chi khung Toi: cham sang am + quang mem, nhap nhay.
	if fly_visible:
		for i in range(FLY_COUNT):
			var p: Vector2 = _cam_anchor(fly_positions[i])
			var pulse := 0.35 + 0.55 * absf(sin(_time * 2.0 + _fly_phase[i]))
			draw_circle(p, 9.0, Color(1.6, 1.4, 0.6, 0.10 * pulse))
			draw_circle(p, 3.0, Color(1.8, 1.5, 0.7, 0.85 * pulse))
