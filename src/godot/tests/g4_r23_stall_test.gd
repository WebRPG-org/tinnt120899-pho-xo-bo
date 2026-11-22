extends SceneTree
## G4 vong 23 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r23_stall_test.gd
## Kiem tra sap cho Map002 (muc 1 §44.6, §42.5.3):
##  1. 8 bien SIGNS_MAP2 deu anh xa dung loai hang (khong roi
##     ve mac dinh "rau" tru RAU CU); mau bien moi loai khac
##     nhau, alpha 1.
##  2. Chu bien vua bang: bien hang 0 co 11px <= 58 (bang 62),
##     bien sap ben co 10px <= 48 (bang 52).
##  3. Nhịp sap: hang 0 chan [0,2,4,6,8,10] (6 sap), tuong ben
##     chan hang [2,4,6] (3 sap ben moi ben).
##  4. Canh Map002 ve that khong loi: NadiaScene ton tai, map_id
##     2, chay 60 frame (gom _draw ve lai theo khoi bep) khong
##     crash; ve Map001 van map_id 1.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null

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
		print("G4 R23 STALL TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Anh xa bien -> loai hang.
				var want := {
					"RAU CỦ": "rau", "CÁ TƯƠI": "ca", "THỊT HEO": "thit",
					"TRÁI CÂY": "trai-cay", "BÁNH MÌ": "banh-mi",
					"GIA VỊ": "gia-vi", "HOA QUẢ": "trai-cay", "ĐỒ KHÔ": "do-kho",
				}
				var kinds_ok := true
				for sign in want.keys():
					if NadiaScene.stall_goods_kind(sign) != want[sign]:
						kinds_ok = false
				_check("8 bien anh xa dung loai hang", kinds_ok)
				_check("bien la tra ve rau (mac dinh)",
					NadiaScene.stall_goods_kind("KHÔNG CÓ") == "rau")
				# Mau bien: moi loai 1 mau, khac nhau, alpha 1.
				var cols := {}
				var cols_ok := true
				for kind in ["rau", "ca", "thit", "trai-cay", "banh-mi", "gia-vi", "hoa-qua", "do-kho"]:
					var c: Color = NadiaScene.STALL_KIND_COLORS[kind]
					if c.a != 1.0 or cols.has(c):
						cols_ok = false
					cols[c] = true
				_check("8 mau bien khac nhau, alpha 1", cols_ok)
				_check("mau bien theo bien dung loai",
					NadiaScene.stall_sign_color("CÁ TƯƠI") == NadiaScene.STALL_KIND_COLORS["ca"]
					and NadiaScene.stall_sign_color("BÁNH MÌ") == NadiaScene.STALL_KIND_COLORS["banh-mi"])
				# 2. Chu bien vua bang (font DejaVuSans nhu game).
				var font: Font = load("res://DejaVuSans.ttf")
				var fit_ok := true
				var widest := 0.0
				var widest_sign := ""
				for sign in NadiaScene.SIGNS_MAP2:
					var w := font.get_string_size(sign, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
					if w > widest:
						widest = w
						widest_sign = sign
					if w > 58.0:
						fit_ok = false
					var w10 := font.get_string_size(sign, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
					if w10 > 48.0:
						fit_ok = false
				_check("chu bien hang 0 co 11 vua bang 62 (rong nhat %.1f: %s)" % [widest, widest_sign], fit_ok)
				# 3. Nhip sap.
				_check("hang 0 co 6 sap chan [0,2,4,6,8,10]",
					NadiaScene.market_stall_tiles() == [0, 2, 4, 6, 8, 10])
				_check("tuong ben co sap hang chan [2,4,6]",
					NadiaScene.side_stall_rows() == [2, 4, 6])
				_state = 1
		1:
			# 4. Canh Map002 ve that.
			_main._on_start_pressed()
			_main.load_map(2, Vector2i(5, 4))
			var ns = _main.iso_map.nadia_scene
			_check("Map002: co NadiaScene", ns != null)
			if ns != null:
				_check("Map002: nadia map_id 2", ns.map_id == 2)
			_state = 2
		2:
			if _frame >= 90:
				# Da chay ~60 frame o Map002 (gom _draw ve lai).
				_main.load_map(1, Vector2i(4, 5))
				var ns1 = _main.iso_map.nadia_scene
				_check("ve Map001: nadia map_id 1", ns1 != null and ns1.map_id == 1)
				print("G4 R23 STALL TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
