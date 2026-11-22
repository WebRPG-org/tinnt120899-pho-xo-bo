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
# Vong 14 — Duong BFS con lai toi _auto_target (khong gom o hien
# tai, gom dich). Truoc day _step_toward_auto chi thu 2 huong
# tham lam (theo |dx|/|dy|) nen gap NPC chan 1 trong 2 huong la
# bo dich ngay (kiem live 21/11 15:20: tap (1,5) tu (4,5) chet
# o (3,5) — Ban Than dung do). Nay BFS 4 huong tranh vat chan
# that (NPC/tuong) roi di theo duong ngan nhat.
var _auto_path: Array[Vector2i] = []
# Hang buoc da queue: phim nhan trong luc dang buoc (tween 0.15s) —
# neu khong ghi lai, keyup den truoc khi tween xong se xoa held
# va buoc do mat han (nhan nhanh lien tiep chi di duoc 1 o).
# Keyup KHONG xoa queue (xem release_dir): nhan 1 lan = di 1 o.
# Hang (toi da 8): 2+ phim nhan trong cung 1 tween van du buoc.
var _queued_dirs: Array[Vector2i] = []
var _sprite: CharacterSprite = null
# Huong dang giu — ghi bang EVENT phim (Main._unhandled_input),
# khong chi poll Input.is_action_pressed trong _process.
# GOC LOI (20/11 16:26): o FPS thap (swiftshader ~5fps) phim
# nhan nhanh lot giua 2 frame nen poll khong thay — F/P chay vi
# event-driven. Ghi event thi nhan cham cung di duoc ngay.
var _held_dirs: Dictionary = {}

func _ready() -> void:
	_sprite = CharacterSprite.new()
	_sprite.setup({
		"shirt": Color(0.18, 0.44, 0.69, 1),  # Ao xanh duong — mau Tri.
		"pants": Color(0.16, 0.18, 0.24, 1),
		"hair_style": "ngan",
		"player": true,
		"texture": "res://art/char_player.png",  # Anh ve tay (fallback ve code neu thieu file).
		# Vong 18 — walk cycle 6 khung (thieu file thi ve anh don
		# o tren, khong crash — CharacterSprite tu fallback).
		"frames": [
			"res://art/walk_player_f0.png",
			"res://art/walk_player_f1.png",
			"res://art/walk_player_f2.png",
			"res://art/walk_player_f3.png",
			"res://art/walk_player_f4.png",
			"res://art/walk_player_f5.png",
		],
	})
	add_child(_sprite)

func place(p_map: IsoMap, p_tile: Vector2i) -> void:
	iso_map = p_map
	tile = p_tile
	position = iso_map.tile_center(tile)
	_moving = false
	_auto_target = Vector2i(-1, -1)
	_auto_path.clear()
	_queued_dirs.clear()
	if _sprite != null:
		_sprite.moving = false

func set_auto_target(t: Vector2i) -> void:
	_auto_target = t
	_auto_path = _find_path(tile, t)

## BFS 4 huong tu `from` toi `to`, chi qua o is_walkable (tranh
## NPC/tuong). Tra danh sach buoc (khong gom `from`, gom `to`);
## rong = khong toi duoc (vd dich bi vay kin) hoac da o dich.
## Luoi 12x9 nen BFS re — chay moi lan dat dich / tinh lai duong.
func _find_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if from == to or iso_map == null or not iso_map.is_walkable(to):
		return path
	var prev := {from: Vector2i(-999, -999)}
	var frontier: Array[Vector2i] = [from]
	while not frontier.is_empty():
		var nxt: Array[Vector2i] = []
		for c in frontier:
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = c + d
				if prev.has(n) or not iso_map.is_walkable(n):
					continue
				prev[n] = c
				if n == to:
					var cur := n
					while cur != from:
						path.push_front(cur)
						cur = prev[cur]
					return path
				nxt.append(n)
		frontier = nxt
	return path

## Xoa ca dich tu dong lan duong BFS (phim/D-pad bam tay thi huy
## tap-to-move — truoc day chi xoa _auto_target, duong cu van
## con (du chua dung toi vi _step_toward_auto chi chay khi co
## dich, nhung de thong nhat thi xoa ca hai).
func _clear_auto() -> void:
	_auto_target = Vector2i(-1, -1)
	_auto_path.clear()

## Tint theo khung gio — chuyen tiep xuong CharacterSprite.
func set_tint(c: Color) -> void:
	if _sprite != null:
		_sprite.set_tint(c)

## Bong do theo khung gio — chuyen tiep xuong CharacterSprite.
func set_frame(f: int) -> void:
	if _sprite != null:
		_sprite.set_frame(f)

## Event phim di chuyen (Main goi tu _unhandled_input): nhan ->
## ghi huong giu + buoc ngay 1 o (khong cho den frame _process
## sau — nhan cham o FPS thap van di); nha -> xoa huong giu.
## Nhan 1 lan = di 1 o: neu dang buoc (tween 0.15s) thi QUEUE buoc
## lai, buoc ngay khi tween xong — keyup khong huy queue (xem
## release_dir) nen phim nhan-nha nhanh khong bi mat buoc.
func press_dir(d: Vector2i) -> void:
	_held_dirs[d] = true
	if input_blocked or iso_map == null:
		return
	_clear_auto()
	if _moving:
		if _queued_dirs.size() < 8:
			_queued_dirs.append(d)
		return
	_try_step(d)

## Vong 10b — Buoc 1 o cho D-pad (khong giu): button_down tren web
## export khong co button_up dang tin — kiem Chromium 20/11:
## giu nut ▶ (CDP down 800ms + up, ca mouseup tong hop bang JS)
## nhan vat van di lien tuc den tuong (6,5)->(10,5), khong dung.
## Ca Input.is_mouse_button_pressed cung ket (mouseup khong toi
## engine) nen poll 10b cung vo dung. Vi vay D-pad CHI buoc 1 o
## moi lan bam (giong phim nhan-nha): giu de di lien tuc chi co
## tren ban phim (keydown/keyup qua _unhandled_input chay tot)
## va tap-to-move cho quang duong dai.
func step_dir(d: Vector2i) -> void:
	if input_blocked or iso_map == null:
		return
	_clear_auto()
	if _moving:
		if _queued_dirs.size() < 8:
			_queued_dirs.append(d)
		return
	_try_step(d)

func release_dir(d: Vector2i) -> void:
	_held_dirs.erase(d)
	# Co tinh KHONG xoa _queued_dirs: phim nhan-nha nhanh (down+up
	# trong 1 tween) van phai di du 1 o — xoa o day se lam mat buoc.

func clear_held_dirs() -> void:
	_held_dirs.clear()

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
			# Buoc da queue tu phim nhan trong luc tween: buoc ngay
			# (nhan 1 lan = di 1 o, khong mat buoc khi nhan nhanh).
			if not _queued_dirs.is_empty():
				var q: Vector2i = _queued_dirs.pop_front()
				_clear_auto()
				_try_step(q)
		else:
			position = _from.lerp(_to, _t)
		return
	if input_blocked or iso_map == null:
		return
	# Giu phim de di lien tuc (khong chi nhan 1 lan / lan bam).
	var dir := _held_dir()
	if dir != Vector2i.ZERO:
		_clear_auto()
		_try_step(dir)
	elif _auto_target != Vector2i(-1, -1):
		_step_toward_auto()

func _held_dir() -> Vector2i:
	# 1. Huong ghi bang event (uu tien): nhan cham / giu phim o
	# FPS thap van thay — poll Input co the lo.
	for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		if _held_dirs.has(d):
			return d
	# 2. Fallback: poll Input.is_action_pressed (phim giu truoc
	# khi focus / event bi lo).
	# WASD (action move_*, project.godot) + mui ten (ui_* mac dinh):
	# truoc day chi co ui_* nen phim WASD khong di duoc du hint ghi
	# "WASD / mui ten" (loi 20/11 12:20).
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("ui_up"):
		return Vector2i(0, -1)
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("ui_down"):
		return Vector2i(0, 1)
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"):
		return Vector2i(-1, 0)
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO

func _step_toward_auto() -> void:
	if _auto_target == tile:
		_clear_auto()
		return
	if _auto_path.is_empty():
		# Tinh lai duong (vd vua chuyen map / NPC doi cho).
		_auto_path = _find_path(tile, _auto_target)
	if _auto_path.is_empty():
		_clear_auto()  # khong co duong: dung lai
		return
	# An toan: _try_step dat `tile` = dich ngay khi bat dau tween
	# nen `tile` luon la o dang buoc toi — duong BFS tinh tu
	# `tile` khong bao gio lech do dat dich giua chung. Neu duong
	# cu lech (vd place() quen xoa — khong xay ra, place xoa roi)
	# thi tinh lai thay vi buoc cheo 2 o.
	if _tile_dist(_auto_path[0], tile) != 1:
		_auto_path = _find_path(tile, _auto_target)
		if _auto_path.is_empty():
			_clear_auto()
			return
	var next_tile: Vector2i = _auto_path[0]
	if not _try_step(next_tile - tile):
		# Buoc ke bi chan dot ngot: tinh lai 1 lan roi moi bo.
		_auto_path = _find_path(tile, _auto_target)
		if _auto_path.is_empty() or not _try_step(_auto_path[0] - tile):
			_clear_auto()
			return
	_auto_path.pop_front()

## Khoang cach Manhattan (dung kiem tra ke o).
func _tile_dist(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
