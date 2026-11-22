extends SceneTree
## G4 vong 24 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r24_smoke_sign_test.gd
## Kiem tra bien pho dung dua + khoi noi pho (muc 1 §45.5, §42.5.5):
##  1. Bien treo "PHỞ BÒ" lac nhu con lac: goc 0 o t=0, cuc dai
##     +AMP o t=PI/(2*SPEED), cuc tieu -AMP o t=3*PI/(2*SPEED),
##     goc doi theo thoi gian (nhin thay duoc khi doi anh).
##  2. Khoi bep: 4 cum, bay len (y giam theo t), mo dan
##     (alpha giam theo do cao), lac ngang doi theo t.
##  3. Chu bien vua bang go 46px o co 10.
##  4. Canh Map001 ve that khong loi: NadiaScene ton tai, map_id
##     1, chay 60 frame (gom _draw ve lai theo khoi bep + bien
##     lac) khong crash, _t chay that.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null
var _t0 := 0.0

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 400:
		print("G4 R24 SMOKE SIGN TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Bien lac nhu con lac.
				_check("bien dung ve 0 o t=0",
					absf(NadiaScene.food_cart_sign_angle(0.0)) < 0.001)
				var tq := PI / (2.0 * NadiaScene.SIGN_SWAY_SPEED)
				_check("bien cuc dai +AMP o t=PI/(2*SPEED)",
					absf(NadiaScene.food_cart_sign_angle(tq) - NadiaScene.SIGN_SWAY_AMP) < 0.001,
					"angle=%.4f" % NadiaScene.food_cart_sign_angle(tq))
				var t3q := 3.0 * PI / (2.0 * NadiaScene.SIGN_SWAY_SPEED)
				_check("bien cuc tieu -AMP o t=3*PI/(2*SPEED)",
					absf(NadiaScene.food_cart_sign_angle(t3q) + NadiaScene.SIGN_SWAY_AMP) < 0.001,
					"angle=%.4f" % NadiaScene.food_cart_sign_angle(t3q))
				_check("bien doi goc theo thoi gian",
					absf(NadiaScene.food_cart_sign_angle(0.5) - NadiaScene.food_cart_sign_angle(2.0)) > 0.02)
				_check("bien do lac vua phai (0.05..0.10 rad)",
					NadiaScene.SIGN_SWAY_AMP >= 0.05 and NadiaScene.SIGN_SWAY_AMP <= 0.10)
				# 2. Khoi bep.
				_check("khoi co 4 cum", NadiaScene.SMOKE_PUFFS == 4)
				var p0: Dictionary = NadiaScene.food_cart_smoke_puff(0.0, 0)
				var p1: Dictionary = NadiaScene.food_cart_smoke_puff(0.5, 0)
				_check("khoi bay len (y giam theo t)",
					float(p1["pos"].y) < float(p0["pos"].y),
					"y0=%.1f y1=%.1f" % [float(p0["pos"].y), float(p1["pos"].y)])
				_check("khoi mo dan (alpha giam theo do cao)",
					float(p1["alpha"]) < float(p0["alpha"]),
					"a0=%.2f a1=%.2f" % [float(p0["alpha"]), float(p1["alpha"])])
				var px0: Dictionary = NadiaScene.food_cart_smoke_puff(0.0, 0)
				var px1: Dictionary = NadiaScene.food_cart_smoke_puff(0.8, 0)
				_check("khoi lac ngang doi theo t",
					absf(float(px1["pos"].x) - float(px0["pos"].x)) > 1.0)
				_check("khoi khong qua dam (alpha<=0.5, ban kinh<=9)",
					float(p0["alpha"]) <= 0.5 and float(p0["radius"]) <= 9.0)
				# 3. Chu bien vua bang.
				var font: Font = load("res://DejaVuSans.ttf")
				var w := font.get_string_size(NadiaScene.SIGN_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
				_check("chu 'PHỞ BÒ' co 10 vua bang 46 (rong %.1f)" % w,
					w <= NadiaScene.SIGN_BOARD.x - 4.0)
				# Vi tri xe do an (de script trinh duyet biet cho chup).
				_check("xe do an o o (6,12)", NadiaScene.FOOD_CART_TILE == Vector2i(6, 12))
				_state = 1
		1:
			# 4. Canh Map001 ve that.
			_main._on_start_pressed()
			_main.load_map(1, Vector2i(4, 5))
			var ns = _main.iso_map.nadia_scene
			_check("Map001: co NadiaScene", ns != null)
			if ns != null:
				_check("Map001: nadia map_id 1", ns.map_id == 1)
				_t0 = ns._t
			_state = 2
		2:
			if _frame >= 90:
				# Da chay ~60 frame o Map001 (gom _draw ve lai).
				var ns1 = _main.iso_map.nadia_scene
				_check("Map001: _t chay that sau 60 frame",
					ns1 != null and ns1._t > _t0 + 0.2,
					"t0=%.2f t1=%.2f" % [_t0, ns1._t if ns1 != null else -1.0])
				print("G4 R24 SMOKE SIGN TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
