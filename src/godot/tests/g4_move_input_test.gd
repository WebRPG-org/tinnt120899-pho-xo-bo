extends SceneTree
## G4 move-input test — di chuyen qua PIPELINE INPUT THAT (vong 9+):
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_move_input_test.gd
## Loi live 22:05 20/11: nhan D/d/mui ten + tap-to-move deu khong di
## duoc (chi giu phim moi di duoc chut it). Test cu (g4_coord_wasd)
## chi goi Input.action_press + _try_step truc tiep nen khong thay
## loi nay.
## - Phim: gui InputEventKey that qua Input.parse_input_event()
##   (di qua GUI -> Main._unhandled_input -> Player.press_dir).
## - Chuot: Input.parse_input_event() BIEN DANG toa do chuot o
##   headless (nhan ~20x — probe g4_mouse_probe), nen tap-to-move
##   goi thang Main._unhandled_input (logic tap that, bo qua GUI);
##   duong GUI that duoc kiem bang trinh duyet (check_move_single.py).
## - Queue (vong 9+): 3 phim nhan nhanh trong 1 tween van du 3 o.
## - Tap bien (vong 9+): tap o bi chan -> di toi o di duoc gan nhat.

var _frame := 0
var _state := 0
var _wait := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _key(k: int, pressed: bool) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.physical_keycode = k
	ev.keycode = k
	ev.pressed = pressed
	ev.echo = false
	return ev

func _click(pos: Vector2, pressed: bool) -> InputEventMouseButton:
	var ev := InputEventMouseButton.new()
	ev.position = pos
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = pressed
	return ev

func _screen_of(tile: Vector2i) -> Vector2:
	return _main.get_viewport().get_canvas_transform() * _main.iso_map.tile_center(tile)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 1200:
		print("G4 MOVE-INPUT: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("spawn (4,5)", _main.player.tile == Vector2i(4, 5), str(_main.player.tile))
				_main._on_start_pressed()
				_check("sau start: input mo", not _main.player.input_blocked)
				# Queue: 3 lan nhan-nha D that nhanh, moi lan cach nhau
				# 1 frame (ca 3 deu roi vao 1 tween) — van phai du 3 o.
				Input.parse_input_event(_key(KEY_D, true))
				_state = 1
		1:
			Input.parse_input_event(_key(KEY_D, false))
			Input.parse_input_event(_key(KEY_D, true))
			_state = 2
		2:
			Input.parse_input_event(_key(KEY_D, false))
			Input.parse_input_event(_key(KEY_D, true))
			_state = 3
		3:
			Input.parse_input_event(_key(KEY_D, false))
			_wait = 0
			_state = 4
		4:
			# Cho ca 3 buoc queue xong (moi buoc 0.15s).
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("3 phim D nhan nhanh -> (7,5) [queue]", _main.player.tile == Vector2i(7, 5), str(_main.player.tile))
				_state = 5
			elif _wait >= 400:
				_check("3 phim D nhan nhanh -> (7,5) [queue]", false, "ket o " + str(_main.player.tile))
				_state = 5
		5:
			# Nhan D 1 lan (nhan-nha nhanh, khong giu — giu thi di
			# lien tuc nhieu o theo thiet ke) -> +1 o.
			Input.parse_input_event(_key(KEY_D, true))
			_state = 6
		6:
			Input.parse_input_event(_key(KEY_D, false))
			_wait = 0
			_state = 7
		7:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("nhan D 1 lan (giu) -> (8,5)", _main.player.tile == Vector2i(8, 5), str(_main.player.tile))
				# Mui ten phai 1 lan.
				Input.parse_input_event(_key(KEY_RIGHT, true))
				_state = 8
			elif _wait >= 400:
				_check("nhan D 1 lan (giu) -> (8,5)", false, "ket o " + str(_main.player.tile))
				_state = 8
		8:
			Input.parse_input_event(_key(KEY_RIGHT, false))
			_wait = 0
			_state = 9
		9:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("mui ten phai 1 lan -> (9,5)", _main.player.tile == Vector2i(9, 5), str(_main.player.tile))
				_state = 10
			elif _wait >= 400:
				_check("mui ten phai 1 lan -> (9,5)", false, "ket o " + str(_main.player.tile))
				_state = 10
		10:
			# Tap-to-move vao o di duoc (9,7): goi _unhandled_input
			# truc tiep (parse_input_event bien dang toa do chuot
			# o headless — xem ghi chu dau file).
			_main._unhandled_input(_click(_screen_of(Vector2i(9, 7)), true))
			_wait = 0
			_state = 11
		11:
			_wait += 1
			if _main.player.tile == Vector2i(9, 7):
				_check("tap-to-move toi (9,7)", true)
				_state = 12
			elif _wait >= 400:
				_check("tap-to-move toi (9,7)", false, "dung o " + str(_main.player.tile))
				_state = 12
		12:
			# Tap vao o BIEN BI CHAN (11,2) -> phai di toi o di
			# duoc gan nhat (10,2) thay vi dung yen.
			_main._unhandled_input(_click(_screen_of(Vector2i(11, 2)), true))
			_wait = 0
			_state = 13
		13:
			_wait += 1
			if _main.player.tile == Vector2i(10, 2):
				_check("tap o bien (11,2) -> di toi (10,2) gan nhat", true)
				_state = 14
			elif _wait >= 400:
				_check("tap o bien (11,2) -> di toi (10,2) gan nhat", false, "dung o " + str(_main.player.tile))
				_state = 14
		14:
			# F / P — gui event roi doi vai frame (parse_input_event
			# co the xu ly tre 1-2 frame).
			Input.parse_input_event(_key(KEY_F, true))
			Input.parse_input_event(_key(KEY_F, false))
			_wait = 0
			_state = 15
		15:
			_wait += 1
			if _wait >= 5:
				_check("phim F doi khung -> Chieu", _main.frame_idx == 1, str(_main.frame_idx))
				Input.parse_input_event(_key(KEY_P, true))
				Input.parse_input_event(_key(KEY_P, false))
				_wait = 0
				_state = 16
		16:
			_wait += 1
			if _wait >= 5:
				_check("phim P mo dien thoai", _main.phone_open)
				_state = 17
		17:
			print("G4 MOVE-INPUT: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
