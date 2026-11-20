extends SceneTree
## Artpass test — chay scene Main that headless, kiem tra 5 diem sua xau 20/11:
##   godot --headless --path src/godot -s res://tests/artpass_test.gd
## 1. Title screen mo san + nut Bat dau mo khoa input.
## 2. Camera ton tai, current, zoom 1.6, bam theo player.
## 3. Giu phim di lien tuc: tu (4,5) giu ui_right -> toi (7,5) trong <60 frame.
## 4. Panel dien thoai full man hinh 720x1280, nen duc.
## 5. HUD nam trong panel (khong text tran) + nhan NPC co sprite.

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null
var _hold_start := 0

func _check(name: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 600:
		print("ARTPASS TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("title mo san", _main.title_open)
				_check("panel title hien", _main._title_panel.visible)
				_check("input bi khoa khi title mo", _main.player.input_blocked)
				_check("camera ton tai", _main._camera != null)
				_check("camera current", _main._camera.is_current())
				_check("camera zoom 1.6", _main._camera.zoom == Vector2(1.6, 1.6))
				_check("HUD trong panel", _main._hud_gold.get_parent().get_parent() is PanelContainer)
				var has_sprite := false
				for mk in _main.iso_map.markers:
					if String(mk.event_data.get("id", "")) == "co-tu":
						for ch in mk.get_children():
							if ch is CharacterSprite:
								has_sprite = true
				_check("NPC Co Tu co sprite chibi", has_sprite)
				_main._on_start_pressed()
				_check("bam Bat dau -> het title", not _main.title_open)
				_check("panel title an", not _main._title_panel.visible)
				_check("input mo lai", not _main.player.input_blocked)
				Input.action_press("ui_right")
				_hold_start = _frame
				_state = 1
		1:
			# Giu phim: 3 o x 0.15s = 27 frame (60fps) + du phong.
			if _main.player.tile.x >= 7:
				Input.action_release("ui_right")
				_check("giu phim di lien tuc den (7,5)", _main.player.tile == Vector2i(7, 5))
				_check("3 o trong <%d frame" % (_frame - _hold_start), _frame - _hold_start < 60)
				_state = 2
			elif _frame - _hold_start > 90:
				Input.action_release("ui_right")
				_check("giu phim di lien tuc den (7,5)", false)
				_state = 2
		2:
			_main._open_phone("")
			_check("panel dien thoai hien", _main._phone_panel.visible)
			_check("dien thoai full man hinh", _main._phone_panel.size == Vector2(720, 1280))
			_main._close_phone()
			_check("dong dien thoai", not _main._phone_panel.visible)
			# Buoi 2: overlay ngay/dem + thu tu layer.
			_check("overlay ton tai", _main._daynight != null)
			_check("overlay duoi HUD", _main._overlay_layer.layer < _main._ui_layer.layer)
			_check("overlay phu kin man hinh", _main._daynight.size == Vector2(720, 1280))
			_check("overlay khong chan click", _main._daynight.mouse_filter == Control.MOUSE_FILTER_IGNORE)
			_check("khung Sang trong suot", _main._daynight.color.a == 0.0)
			_main._advance_frame()
			_check("khung Chieu vang cam", _main._daynight.color.r > 0.9 and _main._daynight.color.g > 0.6 and _main._daynight.color.a > 0.0)
			_main._advance_frame()
			_check("khung Toi xanh dam", _main._daynight.color.b > _main._daynight.color.r and _main._daynight.color.a >= 0.25)
			print("ARTPASS TEST: %d PASS / %d FAIL" % [_pass, _fail])
			quit(1 if _fail > 0 else 0)
