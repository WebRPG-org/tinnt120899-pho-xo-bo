extends SceneTree
## Vong 10 — D-pad + nhan debug test:
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_dpad_test.gd
## Loi live 23:14 20/11: nhan vat dung yen du phim/tap chay tot tren
## Chromium local (ca press nhanh, giu, tap, synthetic dispatch) —
## khong tai hien duoc loi live. Them DUONG INPUT THU 2 khong phu
## thuoc ban phim: 4 nut mui ten tren man hinh (button_down ->
## press_dir, button_up -> release_dir) + nhan debug hien o hien
## tai + input cuoi, de lan kiem live sau doc duoc ngay input co
## toi game khong.

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

func _dpad_btn(idx: int) -> Button:
	return _main._dpad.get_child(idx) as Button

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 1500:
		print("G4 DPAD: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# Truoc khi start: D-pad + nhan debug an (title mo).
				_check("truoc start: D-pad an", not _main._dpad.visible)
				_check("truoc start: nhan debug an", not _main._dbg_label.visible)
				_check("nhan debug hien o spawn (4,5)", "(4,5)" in _main._dbg_label.text, _main._dbg_label.text)
				_main._on_start_pressed()
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _wait >= 3:
				_check("sau start: D-pad hien", _main._dpad.visible)
				# §29.3: nhan debug mac dinh AN — bat bang F9 truoc
				# khi cac buoc sau doc o/input tu nhan.
				_check("sau start: nhan debug AN mac dinh", not _main._dbg_label.visible)
				Input.parse_input_event(_key(KEY_F9, true))
				Input.parse_input_event(_key(KEY_F9, false))
				_wait = 0
				_state = 11
		11:
			_wait += 1
			if _wait >= 3:
				_check("F9 bat nhan debug", _main._dbg_label.visible)
				# Cham nhanh nut PHAI (down+up) -> di 1 o.
				_dpad_btn(2).emit_signal("button_down")
				_state = 2
		2:
			_dpad_btn(2).emit_signal("button_up")
			_wait = 0
			_state = 3
		3:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("D-pad phai 1 lan -> (5,5)", _main.player.tile == Vector2i(5, 5), str(_main.player.tile))
				_check("nhan debug cap nhat o (5,5)", "(5,5)" in _main._dbg_label.text, _main._dbg_label.text)
				_check("nhan debug ghi input ▶", "▶" in _main._dbg_label.text, _main._dbg_label.text)
				# Vong 10b — button_up BI MAT (chi down, khong up, chuot
				# that da nha): poll phai nha huong, chi di dung 1 o
				# (kiem Chromium 20/11: khong co poll thi 1 tap di
				# lien tuc 4-7 o + doi ca map).
				_dpad_btn(2).emit_signal("button_down")
				_wait = 0
				_state = 4
			elif _wait >= 400:
				_check("D-pad phai 1 lan -> (5,5)", false, "ket o " + str(_main.player.tile))
				_state = 99
		4:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("mat button_up -> chi di 1 o (6,5)", _main.player.tile == Vector2i(6, 5), str(_main.player.tile))
				_wait = 0
				_state = 5
			elif _wait >= 400:
				_check("mat button_up -> chi di 1 o (6,5)", false, "ket o " + str(_main.player.tile))
				_state = 99
		5:
			# Vong 10b — D-pad la tap-per-tile: du button_up co mat
			# hay khong, sau 40 frame nhan vat van dung yen o (6,5)
			# (khong di lien tuc). Giu nut khong con di lien tuc.
			_wait += 1
			if _wait >= 40:
				_check("giu nut (mat up) -> van dung yen (6,5)", _main.player.tile == Vector2i(6, 5), str(_main.player.tile))
				# Bam nhanh 3 lan nut PHAI -> di dung 3 o (queue).
				_dpad_btn(2).emit_signal("button_down")
				_dpad_btn(2).emit_signal("button_down")
				_dpad_btn(2).emit_signal("button_down")
				_wait = 0
				_state = 6
		6:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("bam nhanh 3 lan -> di dung 3 o (9,5)", _main.player.tile == Vector2i(9, 5), str(_main.player.tile))
				# Nut TRAI 1 lan -> lui 1 o.
				var x0: int = _main.player.tile.x
				_dpad_btn(1).emit_signal("button_down")
				_dpad_btn(1).emit_signal("button_up")
				_wait = 0
				_state = 7
				_main.set_meta("x0", x0)
			elif _wait >= 400:
				_check("bam nhanh 3 lan -> di dung 3 o (9,5)", false, "ket o " + str(_main.player.tile))
				_state = 99
		7:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("D-pad trai 1 lan -> lui 1 o", _main.player.tile.x == int(_main.get_meta("x0")) - 1, str(_main.player.tile))
				# Mo dien thoai -> D-pad phai an.
				Input.parse_input_event(_key(KEY_P, true))
				Input.parse_input_event(_key(KEY_P, false))
				_wait = 0
				_state = 8
			elif _wait >= 400:
				_check("D-pad trai 1 lan -> lui 1 o", false, "ket o " + str(_main.player.tile))
				_state = 99
		8:
			_wait += 1
			if _wait >= 5:
				_check("mo dien thoai -> D-pad an", not _main._dpad.visible)
				Input.parse_input_event(_key(KEY_P, true))
				Input.parse_input_event(_key(KEY_P, false))
				_wait = 0
				_state = 9
		9:
			_wait += 1
			if _wait >= 5:
				_check("dong dien thoai -> D-pad hien lai", _main._dpad.visible)
				_state = 10
		10:
			print("G4 DPAD: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
		99:
			print("G4 DPAD: %d/%d PASS" % [_pass, _pass + _fail])
			quit(1)
