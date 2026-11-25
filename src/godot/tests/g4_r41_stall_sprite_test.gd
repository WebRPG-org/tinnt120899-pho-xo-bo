extends SceneTree
## G4 vong 41 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r41_stall_sprite_test.gd
## Kiem tra sprite sap tach rieng Map002 (§45.1, §62.5):
##  1. Hang 0: sap chan [0,2,4,6,8,10] khong doi; o le
##     [1,3,5,7,9,11] nay de trong (khong tuong/mai/cua so);
##     2 tap khong giao nhau.
##  2. Anh xa bien -> loai sprite: 5 bien co sprite (RAU CU->rau,
##     TRAI CAY + HOA QUA->trai-cay, CA TUOI + THIT HEO->ca-thit);
##     3 bien con lai (BANH MI, GIA VI, DO KHO) co sprite tu vong 42
##     (xem g4_r42_stall_sprite_test.gd) — test nay chi khoa 5 bien goc.
##  3. Duong dan sprite + kich thuoc canvas 64x96 + day y +14.
##  4. Canh Map002 ve that khong loi; trang thai sprite khop file
##     tren dia (co file -> texture 64x96; thieu file -> null va
##     ve bang code nhu cu); ve Map001 van map_id 1.

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
		print("G4 R41 STALL SPRITE TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Nhip sap + o trong.
				_check("hang 0 co 6 sap chan [0,2,4,6,8,10]",
					NadiaScene.market_stall_tiles() == [0, 2, 4, 6, 8, 10])
				_check("o le hang 0 de trong [1,3,5,7,9,11]",
					NadiaScene.market_gap_tiles() == [1, 3, 5, 7, 9, 11])
				var overlap := false
				for t in NadiaScene.market_gap_tiles():
					if t in NadiaScene.market_stall_tiles():
						overlap = true
				_check("o trong khong giao o sap", not overlap)
				# 2. Bien -> loai sprite.
				var want := {
					"RAU CỦ": "rau", "TRÁI CÂY": "trai-cay",
					"HOA QUẢ": "trai-cay", "CÁ TƯƠI": "ca-thit",
					"THỊT HEO": "ca-thit",
				}
				var kinds_ok := true
				for sign in want.keys():
					if NadiaScene.stall_sprite_kind(sign) != want[sign]:
						kinds_ok = false
				_check("5 bien co sprite dung loai", kinds_ok)
				# Vong 42: 3 bien con lai nay cung co sprite (khoa o r42).
				var new_ok := true
				for sign in ["BÁNH MÌ", "GIA VỊ", "ĐỒ KHÔ"]:
					if NadiaScene.stall_sprite_kind(sign) == "":
						new_ok = false
				_check("3 bien vong 42 cung co sprite", new_ok)
				# 3. Duong dan + kich thuoc.
				_check("duong dan sprite rau/trai-cay/ca-thit",
					NadiaScene.stall_sprite_path("rau") == "res://art/stall_rau.png"
					and NadiaScene.stall_sprite_path("trai-cay") == "res://art/stall_traicay.png"
					and NadiaScene.stall_sprite_path("ca-thit") == "res://art/stall_cathit.png")
				_check("duong dan rong / loai la tra ve ''",
					NadiaScene.stall_sprite_path("") == ""
					and NadiaScene.stall_sprite_path("khong-co") == "")
				_check("dung 6 sprite dang ky (3 vong 41 + 3 vong 42)",
					NadiaScene.STALL_SPRITE_FILES.size() == 6)
				_check("canvas sprite 64x96, day y +14",
					NadiaScene.STALL_SPRITE_SIZE == Vector2(64, 96)
					and NadiaScene.STALL_SPRITE_BOTTOM_Y == 14.0)
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
				var ns = _main.iso_map.nadia_scene
				var present := 0
				var state_ok := true
				for kind in ["rau", "trai-cay", "ca-thit"]:
					var path := NadiaScene.stall_sprite_path(kind)
					var on_disk := ResourceLoader.exists(path, "Texture2D")
					var tex: Texture2D = ns.stall_sprite_texture(kind)
					if on_disk:
						present += 1
						if tex == null or tex.get_size() != Vector2(64, 96):
							state_ok = false
					else:
						if tex != null:
							state_ok = false
				print("  INFO sprites tren dia: %d/3 (3 goc vong 41)" % present)
				_check("sprite khop file tren dia (co->64x96, thieu->null)",
					state_ok)
				_main.load_map(1, Vector2i(4, 5))
				var ns1 = _main.iso_map.nadia_scene
				_check("ve Map001: nadia map_id 1", ns1 != null and ns1.map_id == 1)
				print("G4 R41 STALL SPRITE TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
