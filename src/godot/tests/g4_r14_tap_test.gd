extends SceneTree
## Vong 14 — Tap-to-move di vong NPC + cham ngoai hinh thoi dat
## + nhan debug an khi mo dien thoai (loi live 21/11 14:55-15:20).
## (1) BFS: tap (1,5) tu (4,5) phai di VONG Ban Than o (3,5)
## (truoc day tham lam 2 huong thi bo dich ngay) — toi dich sau
## dung 5 buoc (duong ngan nhat tranh NPC), khong buoc vao (3,5),
## khong lac sang cua (5,4) gay chuyen map giua chung.
## (2) Cham ngoai hinh thoi: (200,750) + (500,700) luc spawn
## truoc day im lang (A van (-1,-1)); nay phai dang ky dich
## (kep ve o di duoc gan nhat) + ghi "cham (x,y)".
## (3) Nhan debug (24,200) de len tieu de "Dien thoai" (panel
## y=216): mo dien thoai thi an, dong lai thi hien tro lai.
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_r14_tap_test.gd

var _frame := 0
var _state := 0
var _wait := 0
var _pass := 0
var _fail := 0
var _main: Node = null
var _visited: Array[Vector2i] = []
var _arrived_wait := -1  # >=0: dem frame sau khi toi dich.

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _tap(pos: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.position = pos
	ev.pressed = true
	_main._unhandled_input(ev)

func _on_moved(tile: Vector2i) -> void:
	_visited.append(tile)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 2000:
		print("G4 R14-TAP: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_main._on_start_pressed()
				_check("spawn (4,5)", _main.player.tile == Vector2i(4, 5), str(_main.player.tile))
				# (2) Cham ngoai hinh thoi — dung dung toa do
				# kiem live 21/11 15:20 bao im lang.
				_tap(Vector2(200, 750))
				_check("cham (200,750) dang ky dich", _main.player._auto_target != Vector2i(-1, -1), str(_main.player._auto_target))
				_check("cham (200,750) ghi input", _main._last_input.begins_with("chạm"), _main._last_input)
				_check("dich cham la o di duoc", _main.iso_map.is_walkable(_main.player._auto_target), str(_main.player._auto_target))
				_tap(Vector2(500, 700))
				_check("cham (500,700) dang ky dich", _main.player._auto_target != Vector2i(-1, -1), str(_main.player._auto_target))
				# Dung tap-walk de bat dau BFS tu (4,5) sach.
				_main.player.place(_main.iso_map, Vector2i(4, 5))
				_visited.clear()
				_main.player.moved_to.connect(_on_moved)
				_main.player.set_auto_target(Vector2i(1, 5))
				_check("BFS tinh duong 5 buoc tranh NPC", _main.player._auto_path.size() == 5, str(_main.player._auto_path))
				_check("BFS khong di qua (3,5) Ban Than", not (Vector2i(3, 5) in _main.player._auto_path), str(_main.player._auto_path))
				_check("BFS khong qua cua (5,4)", not (Vector2i(5, 4) in _main.player._auto_path), str(_main.player._auto_path))
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _arrived_wait >= 0:
				_arrived_wait += 1
				if _arrived_wait >= 3:
					_check("BFS toi dich (1,5)", _main.player.tile == Vector2i(1, 5), str(_main.player.tile))
					_check("di dung 5 buoc", _visited.size() == 5, str(_visited))
					_check("khong buoc vao (3,5)", not (Vector2i(3, 5) in _visited), str(_visited))
					_check("khong chuyen map giua chung", _main.current_map_id == 1, str(_main.current_map_id))
					_check("toi dich thi xoa auto-target", _main.player._auto_target == Vector2i(-1, -1), str(_main.player._auto_target))
					# (3) Nhan debug vs dien thoai.
					_main._toggle_phone()
					_wait = 0
					_state = 2
			elif _main.player.tile == Vector2i(1, 5) and not _main.player._moving:
				# Da toi dich (tile dat ngay khi bat dau tween,
				# moved_to phat sau) — cho 3 frame de moved_to
				# cuoi + _step_toward_auto xoa auto-target.
				_arrived_wait = 0
			elif _wait >= 900:
				_check("BFS toi dich (1,5)", false, "ket o " + str(_main.player.tile) + " visited=" + str(_visited))
				_state = 99
		2:
			_wait += 1
			if _wait >= 3:
				_check("mo dien thoai: nhan debug AN", _main._dbg_label.visible == false, str(_main._dbg_label.visible))
				_main._toggle_phone()
				_wait = 0
				_state = 3
		3:
			_wait += 1
			if _wait >= 3:
				_check("dong dien thoai: nhan debug HIEN lai", _main._dbg_label.visible == true, str(_main._dbg_label.visible))
				_state = 4
		4:
			print("G4 R14-TAP: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
		99:
			print("G4 R14-TAP: %d/%d PASS" % [_pass, _pass + _fail])
			quit(1)
