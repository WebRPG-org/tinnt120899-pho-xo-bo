extends SceneTree
## §29.3 (sua vong 12) — Nhan debug mac dinh HIEN, bat/tat bang F9:
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_debug_toggle_test.gd
## Vong 12 dao mac dinh: HIEN thay vi an — checker 12:56 21/11
## khong biet bam F9 nen mat cong cu doc o; nhan la cong cu chan
## doan duy nhat cua checker. Chi an lai sau khi di chuyen da qua
## kiem live (luat AGENTS.md 21/11). F9 van bat/tat; text van cap
## nhat ke ca khi an.

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

func _press_f9() -> void:
	Input.parse_input_event(_key(KEY_F9, true))
	Input.parse_input_event(_key(KEY_F9, false))

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 1500:
		print("G4 DEBUG TOGGLE: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# Truoc khi start: nhan debug an (title mo) nhung
				# text da co o spawn (cap nhat ke ca khi an).
				_check("truoc start: nhan debug an", not _main._dbg_label.visible)
				_check("truoc start: text co o spawn (4,5)", "(4,5)" in _main._dbg_label.text, _main._dbg_label.text)
				_check("co mac dinh HIEN (vong 12)", _main._debug_labels_visible == true)
				_main._on_start_pressed()
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _wait >= 3:
				# Sau start: HIEN (mac dinh moi) — D-pad thi hien.
				_check("sau start: nhan debug HIEN (mac dinh)", _main._dbg_label.visible)
				_check("sau start: D-pad hien", _main._dpad.visible)
				_press_f9()
				_wait = 0
				_state = 2
		2:
			_wait += 1
			if _wait >= 3:
				_check("F9 lan 1: nhan debug an", not _main._dbg_label.visible)
				_check("F9 lan 1: text van co (4,5)", "(4,5)" in _main._dbg_label.text, _main._dbg_label.text)
				_press_f9()
				_wait = 0
				_state = 3
		3:
			_wait += 1
			if _wait >= 3:
				_check("F9 lan 2: nhan debug hien lai", _main._dbg_label.visible)
				# D-pad phai 1 lan KHI nhan dang hien -> van di duoc.
				_dpad_btn(2).emit_signal("button_down")
				_state = 4
		4:
			_dpad_btn(2).emit_signal("button_up")
			_wait = 0
			_state = 5
		5:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("D-pad khi nhan hien -> van di (5,5)", _main.player.tile == Vector2i(5, 5), str(_main.player.tile))
				_check("text cap nhat (5,5) du dang hien", "(5,5)" in _main._dbg_label.text, _main._dbg_label.text)
				_check("bo dem D-pad P:1", "P:1" in _main._dbg_label.text, _main._dbg_label.text)
				_check("D-pad khong bi toggle anh huong", _main._dpad.visible)
				_main.set_debug_labels_visible(true)
				_wait = 0
				_state = 6
			elif _wait >= 400:
				_check("D-pad khi nhan hien -> van di (5,5)", false, "ket o " + str(_main.player.tile))
				_state = 99
		6:
			_wait += 1
			if _wait >= 3:
				_check("set_debug_labels_visible(true): hien", _main._dbg_label.visible)
				_check("bat truc tiep: text (5,5)", "(5,5)" in _main._dbg_label.text, _main._dbg_label.text)
				_main.set_debug_labels_visible(false)
				_wait = 0
				_state = 7
		7:
			_wait += 1
			if _wait >= 3:
				_check("set_debug_labels_visible(false): an", not _main._dbg_label.visible)
				_state = 8
		8:
			print("G4 DEBUG TOGGLE: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
		99:
			print("G4 DEBUG TOGGLE: %d/%d PASS" % [_pass, _pass + _fail])
			quit(1)
