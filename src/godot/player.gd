class_name Player
extends Node2D
## Player.gd — Nhan vat G1: di chuyen theo o tile (kieu MV) tren ban iso.
## WASD / mui ten: 1 o (len = -y, xuong = +y, trai = -x, phai = +x).
## Cham vao 1 o: tu buoc toi do (tham lam, tranh vat chan).
## Ve bang code (placeholder toi khi co sprite that).

signal moved_to(tile: Vector2i)

const MOVE_TIME := 0.18  # giay / o — nhanh nhu MV, khong le me

var tile := Vector2i(4, 5)
var iso_map: IsoMap = null
var input_blocked := false

var _moving := false
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _t := 0.0
var _auto_target := Vector2i(-1, -1)

func _ready() -> void:
	queue_redraw()

func place(p_map: IsoMap, p_tile: Vector2i) -> void:
	iso_map = p_map
	tile = p_tile
	position = iso_map.tile_center(tile)
	_moving = false
	_auto_target = Vector2i(-1, -1)

func set_auto_target(t: Vector2i) -> void:
	_auto_target = t

func _draw() -> void:
	draw_set_transform(Vector2(0, 14), 0.0, Vector2(1.0, 0.33))
	draw_circle(Vector2.ZERO, 15, Color(0, 0, 0, 0.20))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Than ao xanh la — mau Tri trong he 3 mau cua GDD.
	draw_rect(Rect2(-12, -18, 24, 30), Color(0.25, 0.65, 0.35, 1))
	draw_circle(Vector2(0, -28), 11, Color(0.96, 0.82, 0.66, 1))
	draw_arc(Vector2(0, -30), 11, PI, TAU, 12, Color(0.12, 0.1, 0.1, 1), 4.0)

func _process(delta: float) -> void:
	if _moving:
		_t += delta / MOVE_TIME
		if _t >= 1.0:
			_t = 1.0
			_moving = false
			position = _to
			moved_to.emit(tile)
		else:
			position = _from.lerp(_to, _t)
		return
	if input_blocked or iso_map == null:
		return
	var dir := Vector2i.ZERO
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector2i(0, -1)
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2i(0, 1)
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2i(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector2i(1, 0)
	if dir != Vector2i.ZERO:
		_auto_target = Vector2i(-1, -1)
		_try_step(dir)
	elif _auto_target != Vector2i(-1, -1):
		_step_toward_auto()

func _try_step(dir: Vector2i) -> bool:
	var nt := tile + dir
	if not iso_map.is_walkable(nt):
		return false
	tile = nt
	_from = position
	_to = iso_map.tile_center(nt)
	_t = 0.0
	_moving = true
	return true

func _step_toward_auto() -> void:
	if _auto_target == tile:
		_auto_target = Vector2i(-1, -1)
		return
	var dx := _auto_target.x - tile.x
	var dy := _auto_target.y - tile.y
	var dirs: Array[Vector2i] = []
	if absi(dx) >= absi(dy):
		dirs.append(Vector2i(signi(dx), 0))
		dirs.append(Vector2i(0, signi(dy)))
	else:
		dirs.append(Vector2i(0, signi(dy)))
		dirs.append(Vector2i(signi(dx), 0))
	for d in dirs:
		if d != Vector2i.ZERO and _try_step(d):
			return
	_auto_target = Vector2i(-1, -1)  # ket duong: dung lai
