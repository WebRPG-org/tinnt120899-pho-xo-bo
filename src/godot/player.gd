class_name Player
extends Node2D
## Player.gd — Nhan vat G1: di chuyen theo o tile (kieu MV) tren ban iso.
## WASD / mui ten: 1 o (len = -y, xuong = +y, trai = -x, phai = +x).
## Cham vao 1 o: tu buoc toi do (tham lam, tranh vat chan).
## Ve bang CharacterSprite (chibi Viet: mat, toc, tay, chan, bong do,
## animation di) thay cho hinh chu nhat placeholder.
## Giu phim de di lien tuc: 1 o / 0.15s (~6.7 o/s, qua map 12 o ~1.8s).

signal moved_to(tile: Vector2i)

const MOVE_TIME := 0.15  # giay / o

var tile := Vector2i(4, 5)
var iso_map: IsoMap = null
var input_blocked := false

var _moving := false
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _t := 0.0
var _auto_target := Vector2i(-1, -1)
var _sprite: CharacterSprite = null

func _ready() -> void:
	_sprite = CharacterSprite.new()
	_sprite.setup({
		"shirt": Color(0.18, 0.44, 0.69, 1),  # Ao xanh duong — mau Tri.
		"pants": Color(0.16, 0.18, 0.24, 1),
		"hair_style": "ngan",
		"player": true,
		"texture": "res://art/char_player.png",  # Anh ve tay (fallback ve code neu thieu file).
	})
	add_child(_sprite)

func place(p_map: IsoMap, p_tile: Vector2i) -> void:
	iso_map = p_map
	tile = p_tile
	position = iso_map.tile_center(tile)
	_moving = false
	_auto_target = Vector2i(-1, -1)
	if _sprite != null:
		_sprite.moving = false

func set_auto_target(t: Vector2i) -> void:
	_auto_target = t

func _try_step(dir: Vector2i) -> bool:
	var nt := tile + dir
	if iso_map == null or not iso_map.is_walkable(nt):
		return false
	tile = nt
	_from = position
	_to = iso_map.tile_center(nt)
	_t = 0.0
	_moving = true
	if _sprite != null:
		_sprite.moving = true
		if dir.x < 0:
			_sprite.facing = -1
		elif dir.x > 0:
			_sprite.facing = 1
	return true

func _process(delta: float) -> void:
	if _moving:
		_t += delta / MOVE_TIME
		if _t >= 1.0:
			_t = 1.0
			_moving = false
			position = _to
			if _sprite != null:
				_sprite.moving = false
			moved_to.emit(tile)
		else:
			position = _from.lerp(_to, _t)
		return
	if input_blocked or iso_map == null:
		return
	# Giu phim de di lien tuc (khong chi nhan 1 lan / lan bam).
	var dir := _held_dir()
	if dir != Vector2i.ZERO:
		_auto_target = Vector2i(-1, -1)
		_try_step(dir)
	elif _auto_target != Vector2i(-1, -1):
		_step_toward_auto()

func _held_dir() -> Vector2i:
	if Input.is_action_pressed("ui_up"):
		return Vector2i(0, -1)
	if Input.is_action_pressed("ui_down"):
		return Vector2i(0, 1)
	if Input.is_action_pressed("ui_left"):
		return Vector2i(-1, 0)
	if Input.is_action_pressed("ui_right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO

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
