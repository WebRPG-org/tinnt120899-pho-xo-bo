extends SceneTree
## Vong 12 — hoi quy Map002 + nhan debug mac dinh hien + D-pad:
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/artpass12_test.gd
## Kiem live 12:56 21/11 (pck a87a871d):
##  - Map002: nhan "Sap rau buoi sang" bay 212px len troi, "Cua di
##    Khu Cong Nhan" bay 606px len troi (resolver ap best_y xa);
##    dai toi ngang (khe 28px giua anh troi va anh dat); sap
##    chen nhau thanh dai hep (12 nha 64px chong 50%).
##  - Nhuan debug mac dinh an, checker khong biet F9.
## Khoa: nhan khong roi neo qua 120px (TRU nhan o y muon de len
## nut D-pad — duoc phep nhay xa de thoat nut, vd "Cua ra Cho
## Dau Moi" o (11,8): 931 -> 1052); khong co dai toi; nhan
## khong de len D-pad; khong co cap nhan nao chong nhau (luot
## tach + cascade vong 12b); tap o Map002 di duoc; D-pad bam
## nhanh 3 lan = 3 o (khong mat buoc).
## Thu tu test: tap TRUOC, bam Trai SAU — tap tu (5,4) toi
## (8,6) di ngang qua cua (5,4) neu bam Trai truoc (tu (4,4)
## di phai buoc vao (5,4) la cua -> transfer ve Map001, khong
## phai tap hong).

const DPAD_RECT := Rect2(48, 880, 160, 160)

var _frame := 0
var _state := 0
var _wait := 0
var _pass := 0
var _fail := 0
var _main: Node = null
var _vis_checked := false

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

func _labels_ok(tag: String) -> void:
	# Moi nhan hien: nam trong man hinh, khong roi neo qua
	# LABEL_MAX_DRIFT (120px), khong de len D-pad. Ngoai le:
	# nhan o y muon ma de len nhan vat chinh / nut D-pad duoc
	# phep roi neo toi da 200px (luat thoat vong 12b — vd "Cua
	# ra Cho Dau Moi" o (11,8) nhay 121px, "Hem tro buoi toi"
	# nhay 135px) — mien la sau khi dich thi khong con de len
	# nhan vat / D-pad.
	var ct := _main.get_viewport().get_canvas_transform()
	var p_rect: Rect2 = _main._sprite_obstacle_rect(ct * _main.player.position)
	var bad := ""
	for mk in _main.iso_map.markers:
		var ov: Rect2 = mk.label_override
		var want: Rect2 = mk.label_screen_rect()
		if ov.size == Vector2.ZERO:
			continue
		var nm := String(mk.event_data.get("name", "?"))
		if want.size != Vector2.ZERO and absf(ov.position.y - want.position.y) > 120.0 + 0.5:
			var escape_ok := absf(ov.position.y - want.position.y) <= 200.0 + 0.5 and (want.intersects(p_rect) or want.intersects(DPAD_RECT)) and not ov.intersects(p_rect) and not ov.intersects(DPAD_RECT)
			if not escape_ok:
				bad = "%s roi neo %.0fpx (want %s -> %s)" % [nm, ov.position.y - want.position.y, str(want), str(ov)]
		if ov.position.y < 190.0 - 0.5 or ov.end.y > 1200.0 + 0.5:
			bad = "%s vuot doc (%s)" % [nm, str(ov)]
		if ov.position.x < 16.0 - 0.5 or ov.end.x > 704.0 + 0.5:
			bad = "%s vuot ngang (%s)" % [nm, str(ov)]
		if ov.intersects(DPAD_RECT):
			bad = "%s de len D-pad (%s)" % [nm, str(ov)]
	# Khong co cap nhan nao chong nhau DANG KE (vong 12b: 2 nhan
	# cua Map002 cham nhau o (4,4) sau khi bam Trai — dung
	# repro). Nguong 1px: chong < 1px la sai so float cua phep
	# chieu camera (vd "Co Tu"/"Goc Che Tao" Map001 (11,8)
	# cham nhau 0,5px, mat thuong khong thay) — khong tinh.
	var ovs: Array = []
	for mk2 in _main.iso_map.markers:
		var ov2: Rect2 = mk2.label_override
		if ov2.size != Vector2.ZERO:
			ovs.append([String(mk2.event_data.get("name", "?")), ov2])
	for a in range(ovs.size()):
		for b in range(a + 1, ovs.size()):
			var inter2 := (ovs[a][1] as Rect2).intersection(ovs[b][1] as Rect2)
			if inter2.size.x >= 1.0 and inter2.size.y >= 1.0:
				bad = "%s chong %s" % [ovs[a][0], ovs[b][0]]
	_check(tag + ": nhan gan neo (<=120px), trong man hinh, khong de D-pad", bad == "", bad)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 2000:
		print("ARTPASS12: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("nhan debug mac dinh HIEN", _main._debug_labels_visible == true)
				_main._on_start_pressed()
				_main.load_map(2, Vector2i(5, 4))
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _wait == 5 and not _vis_checked:
				_vis_checked = true
				# _process da chay: nhan hien ngay sau start.
				_check("sau start: nhan debug hien", _main._dbg_label.visible)
			if _wait >= 60:
				_labels_ok("Map002 spawn (5,4)")
				# Khe troi/dat: mep tren anh dat <= day anh troi.
				var gtop := 9999.0
				for c in _main.get_children():
					var sp := c as Sprite2D
					# Vong 20: Map002 dung ground_map002.png ve tay
					# (Map001 ground_map001.png); van la cung sprite
					# dat 1440x900, chi doi texture — nhan ca 3 ten.
					if sp != null and sp.texture != null and ("ground_wide" in sp.texture.resource_path or "ground_map001" in sp.texture.resource_path or "ground_map002" in sp.texture.resource_path):
						gtop = sp.position.y - 450.0
				var bgbot := -9999.0
				if _main.iso_map._bg_sprite != null:
					bgbot = _main.iso_map._bg_sprite.position.y + 140.0
				_check("anh dat chong len day anh troi (khong dai toi)", gtop <= bgbot + 0.5, "dat tren %.0f, troi day %.0f" % [gtop, bgbot])
				# Tap toi (8,6) tu spawn (5,4): duong di
				# (6,4),(7,4),(8,4),(8,5),(8,6) — khong qua cua.
				_check("Map002 (8,6) di duoc", _main.iso_map.is_walkable(Vector2i(8, 6)))
				_main._unhandled_input(_click(_screen_of(Vector2i(8, 6)), true))
				_wait = 0
				_state = 2
		2:
			_wait += 1
			if _main.player.tile == Vector2i(8, 6) and not _main.player._moving and _main.player._auto_target == Vector2i(-1, -1) and _wait >= 5:
				_check("tap-to-move o Map002 toi (8,6)", true)
				_labels_ok("Map002 sau tap")
				# Bam Trai 1 lan o Map002 (nhu kiem live).
				_main._dpad_press(Vector2i(-1, 0))
				_wait = 0
				_state = 3
			elif _wait >= 400:
				_check("tap-to-move o Map002 toi (8,6)", false, "dung o " + str(_main.player.tile) + " A:" + str(_main.player._auto_target))
				_main._dpad_press(Vector2i(-1, 0))
				_wait = 0
				_state = 3
		3:
			_wait += 1
			if not _main.player._moving and _wait >= 5:
				_check("D-pad Trai o Map002: (8,6) -> (7,6)", _main.player.tile == Vector2i(7, 6), str(_main.player.tile))
				_labels_ok("Map002 sau Trai")
				# Repro vong 12 goc: vao Cho bang cua (5,4) roi
				# bam Trai -> (4,4); 2 nhan cua khong duoc chong
				# nhau o day (cascade luot tach vong 12b).
				_main.load_map(2, Vector2i(5, 4))
				_wait = 0
				_state = 7
			elif _wait >= 400:
				_check("D-pad Trai o Map002: (8,6) -> (7,6)", false, "ket o " + str(_main.player.tile))
				_main.load_map(2, Vector2i(5, 4))
				_wait = 0
				_state = 7
		7:
			_wait += 1
			if _wait >= 60:
				_main._dpad_press(Vector2i(-1, 0))
				_wait = 0
				_state = 8
		8:
			_wait += 1
			if not _main.player._moving and _wait >= 5:
				_check("D-pad Trai o Map002: (5,4) -> (4,4)", _main.player.tile == Vector2i(4, 4), str(_main.player.tile))
				_labels_ok("Map002 (4,4) sau Trai")
				# Goc duoi-phai Map001: nhan cua ra troi len, khong
				# duoc de len D-pad (duoc phep nhay xa de thoat).
				_main.load_map(1, Vector2i(11, 8))
				_wait = 0
				_state = 4
			elif _wait >= 400:
				_check("D-pad Trai o Map002: (5,4) -> (4,4)", false, "ket o " + str(_main.player.tile))
				_main.load_map(1, Vector2i(11, 8))
				_wait = 0
				_state = 4
		4:
			_wait += 1
			if _wait >= 60:
				_labels_ok("Map001 goc (11,8)")
				# D-pad bam nhanh 3 lan = 3 o (queue, khong mat buoc).
				_main.load_map(1, Vector2i(4, 5))
				_main._dpad_press(Vector2i(1, 0))
				_main._dpad_press(Vector2i(1, 0))
				_main._dpad_press(Vector2i(1, 0))
				_wait = 0
				_state = 5
		5:
			_wait += 1
			if not _main.player._moving and _wait >= 5:
				_check("D-pad Phai nhanh x3: (4,5) -> (7,5)", _main.player.tile == Vector2i(7, 5), str(_main.player.tile))
				# Bo dem tich luy ca test: 1 Trai (state 2) + 1 Trai
				# (state 7) + 3 Phai.
				_check("bo dem D-pad P:5", "P:5" in _main._dbg_label.text, _main._dbg_label.text)
				_state = 6
			elif _wait >= 400:
				_check("D-pad Phai nhanh x3: (4,5) -> (7,5)", false, "ket o " + str(_main.player.tile))
				_state = 6
		6:
			print("ARTPASS12: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
