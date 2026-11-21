extends SceneTree
## Vong 11 — tap-to-move + loi bien Map002 + nhan debug stale:
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_r11_dbg_test.gd
## Kiem live 21/11 bao 2 loi (tap chi doi nhan, khong keo sprite;
## bam phai tai (9,4) Map002 lui ve (7,4)) — probe Chromium vong 11
## KHONG tai hien duoc loi nao: tap di dung o + camera cuon theo,
## (9,4)->(10,4) dung, (11,4) chan dung. Nguyen nhan that tim ra:
## nhan debug STALE — _update_dbg() chi goi tu moved_to, chay TRUOC
## khi queue pop / auto-target clear, nen A:/Q: cu hien gia tri cu
## sau khi toi dich, lam checker tuong tap ket. Test nay khoa:
## - Nhan debug mac dinh AN + o goc tren-trai (24,200), khong bi
##   nhan cua Map002 che (truoc day o (24,1172) cuoi canvas).
## - Map002: (10,4) di duoc, (11,4) chan.
## - D-pad phai tai (9,4) -> (10,4); phai nua -> van (10,4).
## - Tap toi (10,6): toi noi + nhan cap nhat tuoi A:(-1,-1).

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
	if _frame > 1500:
		print("G4 R11-DBG: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("spawn (4,5)", _main.player.tile == Vector2i(4, 5), str(_main.player.tile))
				_check("nhan debug mac dinh AN", _main._debug_labels_visible == false)
				_check("nhan debug o goc tren-trai (24,200)", _main._dbg_label.position == Vector2(24, 200), str(_main._dbg_label.position))
				_main._on_start_pressed()
				_main.load_map(2, Vector2i(9, 4))
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _wait >= 3:
				_check("load Map002 tai (9,4)", _main.player.tile == Vector2i(9, 4), str(_main.player.tile))
				_check("Map002 (10,4) di duoc", _main.iso_map.is_walkable(Vector2i(10, 4)))
				_check("Map002 (11,4) chan (bien)", not _main.iso_map.is_walkable(Vector2i(11, 4)))
				_main._dpad_press(Vector2i(1, 0))
				_wait = 0
				_state = 2
		2:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("D-pad phai tai (9,4) -> (10,4)", _main.player.tile == Vector2i(10, 4), str(_main.player.tile))
				_main._dpad_press(Vector2i(1, 0))
				_wait = 0
				_state = 3
			elif _wait >= 400:
				_check("D-pad phai tai (9,4) -> (10,4)", false, "ket o " + str(_main.player.tile))
				_state = 3
		3:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("D-pad phai tai (10,4) -> van (10,4) [(11,4) chan]", _main.player.tile == Vector2i(10, 4), str(_main.player.tile))
				# Tap toi (10,6): 2 o xuong.
				_main._unhandled_input(_click(_screen_of(Vector2i(10, 6)), true))
				_wait = 0
				_state = 4
			elif _wait >= 400:
				_check("D-pad phai tai (10,4) -> van (10,4)", false, "ket o " + str(_main.player.tile))
				_state = 4
		4:
			_wait += 1
			if _main.player.tile == Vector2i(10, 6) and not _main.player._moving and _main.player._auto_target == Vector2i(-1, -1) and _wait >= 5:
				_check("tap-to-move toi (10,6)", true)
				# Doi them 3 frame: Main._process cap nhat nhan SAU
				# khi Player._process clear A (cha chay truoc con),
				# nen frame dau tien thay A da clear thi nhan van
				# con gia tri cu — khong phai loi, chi la thu tu.
				_wait = 0
				_state = 5
			elif _wait >= 400:
				_check("tap-to-move toi (10,6)", false, "dung o " + str(_main.player.tile) + " A:" + str(_main.player._auto_target))
				_state = 6
		5:
			_wait += 1
			if _wait >= 3:
				# Nhan phai tuoi: A da clear, khong con hien dich cu.
				_check("nhan debug tuoi sau tap (A:(-1,-1))", "A:(-1, -1)" in _main._dbg_label.text, _main._dbg_label.text)
				_check("nhan debug hien dung o (10,6)", _main._dbg_label.text.begins_with("Ô (10,6)"), _main._dbg_label.text)
				_state = 6
		6:
			print("G4 R11-DBG: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
