extends SceneTree
## Artpass test — chay scene Main that headless, kiem tra 5 diem sua xau 20/11:
##   godot --headless --path src/godot -s res://tests/artpass_test.gd
## 1. Title screen mo san + nut Bat dau mo khoa input.
## 2. Camera ton tai, current, zoom 1.6, bam theo player.
## 3. Giu phim di lien tuc: tu (4,5) giu ui_right -> toi (7,5) trong <60 frame.
## 4. Panel dien thoai KHUNG RIENG 640x1100 tren lop mo toi, co chan
##    trang; noi dung dung ten tieng Viet (khong ma noi bo).
## 5. HUD nam trong panel (khong text tran) + nhan NPC co sprite.
## 6. (20/11 10:30) Overlay ngay/dem dang NHAN: Sang trang (khong doi),
##    Chieu vang cam, Toi xanh dem dam + dom sang cua so bat; toast doi
##    khung o ngay duoi HUD; moi nhan kep duoi HUD va cach mep ~20px.

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
				# Nhan cua hotspot ngoai man hinh (hs-tro-toi o (10,3),
				# camera o spawn) phai AN, khong troi vao man hinh.
				var hs_hidden := true
				for mk in _main.iso_map.markers:
					if String(mk.event_data.get("id", "")) == "hs-tro-toi":
						hs_hidden = (mk as Marker).label_rect().size == Vector2.ZERO
				_check("nhan hotspot ngoai man hinh bi an", hs_hidden)
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
			_check("lop mo dien thoai hien", _main._phone_dim.visible)
			_check("dien thoai khung rieng 680x1100", _main._phone_panel.size == Vector2(680, 1100))
			_check("dien thoai cach mep 20/90", _main._phone_panel.position == Vector2(20, 90))
			var txt: String = str(_main._phone_content.text)
			_check("noi dung khong ma noi bo QuenBiet", not txt.contains("QuenBiet"))
			_check("noi dung khong ma noi bo BestFriend", not txt.contains("BestFriend"))
			_check("giai doan tieng Viet Quen biet", txt.contains("Quen biết"))
			_check("chan trang co ngay/vi", _main._phone_footer.text.contains("Ngày 1") and _main._phone_footer.text.contains("Ví"))
			_check("dien thoai co goi y tien trinh", _main._phone_hint.text.contains("Chương"))
			_main._close_phone()
			_check("dong dien thoai", not _main._phone_panel.visible)
			_check("lop mo an theo", not _main._phone_dim.visible)
			# Buoi 2: overlay ngay/dem + thu tu layer.
			_check("overlay ton tai", _main._daynight != null)
			_check("overlay duoi HUD", _main._overlay_layer.layer < _main._ui_layer.layer)
			_check("overlay phu kin man hinh", _main._daynight.size == Vector2(720, 1280))
			_check("overlay khong chan click", _main._daynight.mouse_filter == Control.MOUSE_FILTER_IGNORE)
			var mat := _main._daynight.material as CanvasItemMaterial
			_check("overlay che do NHAN", mat != null and mat.blend_mode == CanvasItemMaterial.BLEND_MODE_MUL)
			_check("khung Sang trang khong doi", _main._daynight.color == Color(1, 1, 1, 1))
			_check("toast ngay duoi HUD", _main._toast.position.y >= 260 and _main._toast.position.y <= 280)
			_main._advance_frame()
			_check("khung Chieu vang cam (nhan)", _main._daynight.color == Color(1.0, 0.82, 0.55, 1.0))
			_main._advance_frame()
			_check("khung Toi xanh dem dam (nhan)", _main._daynight.color == Color(0.42, 0.52, 0.85, 1.0))
			_check("Toi: dom sang cua so bat", _main.iso_map.night_glow != null and _main.iso_map.night_glow.visible and _main.iso_map.night_glow.lit)
			_check("Toi: co diem sang nha", _main.iso_map.night_glow.spots.size() > 0)
			_state = 3
		3:
			# Moi nhan: nam duoi HUD (268px man hinh) va cach mep >=13
			# world (~20px man hinh) — kiem tra theo camera that.
			var cam: Camera2D = _main._camera
			var half: Vector2 = _main.get_viewport_rect().size / (2.0 * cam.zoom)
			var center: Vector2 = cam.get_screen_center_position()
			var vis_min: Vector2 = center - half
			var vis_max: Vector2 = center + half
			var top_min: float = vis_min.y + 268.0 / cam.zoom.y
			var all_ok := true
			var worst := ""
			for mk in _main.iso_map.markers:
				var r := (mk as Marker).label_rect()
				if r.size == Vector2.ZERO:
					continue
				var wr := Rect2(mk.global_position + r.position, r.size)
				var ok: bool = wr.position.x >= vis_min.x + 13.0 - 0.5 \
					and wr.end.x <= vis_max.x - 13.0 + 0.5 \
					and wr.position.y >= top_min - 0.5 \
					and wr.end.y <= vis_max.y - 13.0 + 0.5
				if not ok:
					all_ok = false
					worst = "%s %s (top_min %.1f)" % [String(mk.event_data.get("name", "?")), str(wr), top_min]
			_check("moi nhan duoi HUD + cach mep", all_ok)
			if not all_ok:
				print("  nhan vi pham: ", worst)
			print("ARTPASS TEST: %d PASS / %d FAIL" % [_pass, _fail])
			quit(1 if _fail > 0 else 0)
