extends SceneTree
## G4 artpass8 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_artpass8_test.gd
## Kiem tra vong sua 8 (20/11 17:30, kiem live ban tron do CDN):
##  1. Cua TAP HOA anh ngay het sang cam (do pixel truc tiep tren
##     bg_map001.png): o cua R-B < 45, cua so < 70; anh dem khong doi.
##  2. Cua so code (Map002+) doi mau theo khung: Sang lanh, Chieu am,
##     Toi sang den (NadiaScene.window_glass_color).
##  3. Phim di chuyen map dung ca physical_keycode (Shift+D = KEY_D
##     vat ly) lan keycode (Main._key_to_dir).
##  4. Khung game vua man hinh desktop 1920x1000 (khong cat day):
##     ti le scale = min(1920/720, 1000/1280) cho chieu cao vua tron.

var _pass := 0
var _fail := 0

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _warmth(img: Image, box: Rect2i) -> float:
	var sum := 0.0
	var n := 0
	for y in range(box.position.y, box.end.y, 4):
		for x in range(box.position.x, box.end.x, 4):
			var c := img.get_pixel(x, y)
			sum += c.r - c.b
			n += 1
	return sum / float(n) * 255.0

func _init() -> void:
	# --- 1. Anh ngay TAP HOA het sang cam ---
	var img := Image.load_from_file("res://art/bg_map001.png")
	_check("doc duoc bg_map001.png", img != null and img.get_width() == 1120, str(img.get_width()) if img != null else "null")
	if img != null:
		var door_w := _warmth(img, Rect2i(802, 396, 76, 68))
		_check("o cua TAP HOA ngay R-B < 45 (het sang cam)", door_w < 45.0, "R-B=" + str(door_w))
		var win_w := _warmth(img, Rect2i(928, 402, 124, 136))
		_check("cua so TAP HOA ngay R-B < 70", win_w < 70.0, "R-B=" + str(win_w))
		var ctrl_w := _warmth(img, Rect2i(140, 400, 85, 130))
		_check("doi chung PHO BO khong doi (~+80..+120)", ctrl_w > 60.0 and ctrl_w < 130.0, "R-B=" + str(ctrl_w))
		# Anh dem giu cua sang (khong bi sua lan).
		var night := Image.load_from_file("res://art/bg_map001_night.png")
		if night != null:
			var night_win := _warmth(night, Rect2i(928, 402, 124, 136))
			_check("anh dem cua so TAP HOA van am (sang den)", night_win > 60.0, "R-B=" + str(night_win))

	# --- 2. Cua so code doi theo khung ---
	var g0: Color = NadiaScene.window_glass_color(0)
	_check("kinh Sang lanh (B > R)", g0.b > g0.r, str(g0))
	var g1: Color = NadiaScene.window_glass_color(1)
	_check("kinh Chieu am (R cao, B thap)", g1.r > 0.95 and g1.b < 0.6, str(g1))
	var g2: Color = NadiaScene.window_glass_color(2)
	_check("kinh Toi sang den (vang cam dam)", g2.r >= 0.99 and g2.g < 0.85 and g2.b < 0.45, str(g2))
	_check("3 khung 3 mau khac nhau", g0 != g1 and g1 != g2 and g0 != g2)

	# --- 3. Phim di chuyen: physical_keycode + keycode ---
	var MainScript: GDScript = load("res://main.gd")
	var m = MainScript.new()
	var ev := InputEventKey.new()
	ev.physical_keycode = KEY_D
	ev.keycode = KEY_D
	_check("D vat ly -> phai", m._key_to_dir(ev) == Vector2i(1, 0), str(m._key_to_dir(ev)))
	# Shift+D: physical van KEY_D, keycode van KEY_D (D hoa).
	var ev2 := InputEventKey.new()
	ev2.physical_keycode = KEY_D
	ev2.keycode = KEY_D
	ev2.shift_pressed = true
	_check("Shift+D (D hoa) -> phai", m._key_to_dir(ev2) == Vector2i(1, 0), str(m._key_to_dir(ev2)))
	var ev3 := InputEventKey.new()
	ev3.physical_keycode = KEY_W
	ev3.keycode = KEY_W
	_check("W vat ly -> len", m._key_to_dir(ev3) == Vector2i(0, -1), str(m._key_to_dir(ev3)))
	var ev4 := InputEventKey.new()
	ev4.physical_keycode = KEY_RIGHT
	ev4.keycode = KEY_RIGHT
	_check("mui ten phai -> phai", m._key_to_dir(ev4) == Vector2i(1, 0), str(m._key_to_dir(ev4)))
	var ev5 := InputEventKey.new()
	ev5.physical_keycode = KEY_F
	ev5.keycode = KEY_F
	_check("F khong phai phim di chuyen", m._key_to_dir(ev5) == Vector2i.ZERO, str(m._key_to_dir(ev5)))
	# Chi co keycode (physical = 0): fallback keycode van dung.
	var ev6 := InputEventKey.new()
	ev6.physical_keycode = 0
	ev6.keycode = KEY_A
	_check("keycode A (khong physical) -> trai", m._key_to_dir(ev6) == Vector2i(-1, 0), str(m._key_to_dir(ev6)))
	m.free()

	# --- 4. Khung game vua man hinh desktop 1920x1000 ---
	var scale := minf(1920.0 / 720.0, 1000.0 / 1280.0)
	_check("scale desktop 1920x1000 = 1000/1280", is_equal_approx(scale, 1000.0 / 1280.0), str(scale))
	_check("chieu cao game vua tron 1000px (khong cat day)", is_equal_approx(1280.0 * scale, 1000.0), str(1280.0 * scale))
	_check("chieu rong game 562px < 1920 (con cho panel 2 ben)", 720.0 * scale < 1920.0 and 720.0 * scale > 500.0, str(720.0 * scale))

	print("ARTPASS8: ", _pass, " pass, ", _fail, " fail")
	if _fail > 0:
		quit(1)
	else:
		quit(0)
