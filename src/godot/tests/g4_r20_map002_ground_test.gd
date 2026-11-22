extends SceneTree
## G4 vong 20 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r20_map002_ground_test.gd
## Kiem tra dat ve tay Map002 (muc 3 §41.5):
##  1. Map002 dung ground_map002.png ve tay (san cho dau moi,
##     1440x900) thay cho ground_wide.jpg anh chup.
##  2. Map001 giu ground_map001.png; map khac (Map003) van
##     ground_wide.jpg; di Map002 -> Map001 doi dat dung.
##  3. Anh dat Map002 dung kich thuoc 1440x900 (cung scale voi
##     ground_map001 / ground_wide, khong lech khung hinh).

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

func _ground_path() -> String:
	if _main._ground_sprite == null:
		return ""
	if _main._ground_sprite.texture == null:
		return ""
	return _main._ground_sprite.texture.resource_path

func _on_frame() -> void:
	_frame += 1
	if _frame > 400:
		print("G4 R20 MAP002 GROUND TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("Map001: dat ve tay ground_map001.png",
					_ground_path().ends_with("ground_map001.png"), _ground_path())
				_main._on_start_pressed()
				_main.load_map(2, Vector2i(5, 4))
				_check("Map002: dat ve tay ground_map002.png",
					_ground_path().ends_with("ground_map002.png"), _ground_path())
				var tex = _main._ground_sprite.texture
				_check("Map002: anh dat 1440x900",
					tex != null and tex.get_size() == Vector2(1440, 900),
					"" if tex == null else str(tex.get_size()))
				_state = 1
		1:
			_main.load_map(3, Vector2i(5, 4))
			_check("Map003: dat van anh cu ground_wide.jpg",
				_ground_path().ends_with("ground_wide.jpg"), _ground_path())
			_main.load_map(2, Vector2i(5, 4))
			_check("ve Map002: dat lai ve tay ground_map002.png",
				_ground_path().ends_with("ground_map002.png"), _ground_path())
			_main.load_map(1, Vector2i(4, 5))
			_check("ve Map001: dat lai ve tay ground_map001.png",
				_ground_path().ends_with("ground_map001.png"), _ground_path())
			print("G4 R20 MAP002 GROUND TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
