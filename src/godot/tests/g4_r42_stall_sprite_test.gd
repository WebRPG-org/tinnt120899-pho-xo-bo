extends SceneTree
## G4 vong 42 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r42_stall_sprite_test.gd
## Kiem tra 3 sprite sap con lai Map002 (§63.5 muc 1):
##  1. Anh xa bien -> loai sprite: ca 8 bien SIGNS_MAP2 deu co
##     sprite (BANH MI->banh-mi, GIA VI->gia-vi, DO KHO->do-kho;
##     5 bien cu giu nguyen nhu vong 41).
##  2. Duong dan 3 sprite moi + dung 6 sprite dang ky.
##  3. Canh Map002 ve that khong loi; trang thai sprite khop file
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
		print("G4 R42 STALL SPRITE TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Bien -> loai sprite (ca 8 bien).
				var want := {
					"RAU CỦ": "rau", "TRÁI CÂY": "trai-cay",
					"HOA QUẢ": "trai-cay", "CÁ TƯƠI": "ca-thit",
					"THỊT HEO": "ca-thit", "BÁNH MÌ": "banh-mi",
					"GIA VỊ": "gia-vi", "ĐỒ KHÔ": "do-kho",
				}
				var kinds_ok := true
				for sign in want.keys():
					if NadiaScene.stall_sprite_kind(sign) != want[sign]:
						kinds_ok = false
				_check("8 bien co sprite dung loai", kinds_ok)
				var none_left := true
				for sign in NadiaScene.SIGNS_MAP2:
					if NadiaScene.stall_sprite_kind(sign) == "":
						none_left = false
				_check("khong bien nao tra ve '' nua", none_left)
				# 2. Duong dan + so luong dang ky.
				_check("duong dan 3 sprite moi",
					NadiaScene.stall_sprite_path("banh-mi") == "res://art/stall_banhmi.png"
					and NadiaScene.stall_sprite_path("gia-vi") == "res://art/stall_giavi.png"
					and NadiaScene.stall_sprite_path("do-kho") == "res://art/stall_dokho.png")
				_check("duong dan cu van dung",
					NadiaScene.stall_sprite_path("rau") == "res://art/stall_rau.png"
					and NadiaScene.stall_sprite_path("trai-cay") == "res://art/stall_traicay.png"
					and NadiaScene.stall_sprite_path("ca-thit") == "res://art/stall_cathit.png")
				_check("dung 6 sprite dang ky",
					NadiaScene.STALL_SPRITE_FILES.size() == 6)
				_check("canvas sprite 64x96, day y +14",
					NadiaScene.STALL_SPRITE_SIZE == Vector2(64, 96)
					and NadiaScene.STALL_SPRITE_BOTTOM_Y == 14.0)
				_state = 1
		1:
			# 3. Canh Map002 ve that.
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
				for kind in ["rau", "trai-cay", "ca-thit", "banh-mi", "gia-vi", "do-kho"]:
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
				print("  INFO sprites tren dia: %d/6" % present)
				_check("sprite khop file tren dia (co->64x96, thieu->null)",
					state_ok)
				_main.load_map(1, Vector2i(4, 5))
				var ns1 = _main.iso_map.nadia_scene
				_check("ve Map001: nadia map_id 1", ns1 != null and ns1.map_id == 1)
				print("G4 R42 STALL SPRITE TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
