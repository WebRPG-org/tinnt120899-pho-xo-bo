extends SceneTree
## Artpass test — chay scene Main that headless, kiem tra 5 diem sua xau 20/11:
##   godot --headless --path src/godot -s res://tests/artpass_test.gd
## 1. Title screen mo san + nut Bat dau mo khoa input.
## 2. Camera ton tai, current, zoom 1.6, bam theo player.
## 3. Giu phim di lien tuc: tu (4,5) giu ui_right -> toi (7,5) trong <60 frame.
## 4. Panel dien thoai KHUNG RIENG 680x900 can giua doc tren lop mo toi, co chan
##    trang + goi y tien trinh + meo xoay theo ngay; noi dung dung ten
##    tieng Viet (khong ma noi bo).
## 5. HUD nam trong panel (khong text tran) + nhan NPC co sprite.
## 6. (20/11 10:30) Overlay ngay/dem dang NHAN: Sang trang (khong doi),
##    Chieu vang cam, Toi xanh dem dam + dom sang cua so bat; toast doi
##    khung o ngay duoi HUD; moi nhan kep duoi HUD va cach mep ~20px.
## 7. (20/11 vong Nadia-style) Nhan vat + nen dung ANH VE TAY (res://art),
##    nhan tren CanvasLayer rieng (tren nhan vat, duoi HUD), troi toi co
##    trang + sao + den duong, dien thoai co notch/home bar + danh ba
##    khong lap "Bạn thân — Bạn thân", nut Bat dau lon 620x110.

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

func _find_button(node: Node, text_part: String) -> Button:
	for ch in node.get_children():
		if ch is Button and String((ch as Button).text).contains(text_part):
			return ch as Button
		var found := _find_button(ch, text_part)
		if found != null:
			return found
	return null

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
				_check("camera zoom 1.4", _main._camera.zoom == Vector2(1.4, 1.4))
				_check("HUD trong panel", _main._hud_gold.get_parent().get_parent() is PanelContainer)
				var has_sprite := false
				var has_tex := false
				for mk in _main.iso_map.markers:
					if String(mk.event_data.get("id", "")) == "co-tu":
						for ch in mk.get_children():
							if ch is CharacterSprite:
								has_sprite = true
								has_tex = (ch as CharacterSprite).texture != null
				_check("NPC Co Tu co sprite chibi", has_sprite)
				_check("NPC Co Tu dung anh ve tay", has_tex)
				_check("nguoi choi dung anh ve tay", _main.player._sprite.texture != null)
				# Anh nen composite Map001 + troi Map002 da nap.
				var bg_ok := false
				for ch in _main.iso_map.get_children():
					if ch is Sprite2D and (ch as Sprite2D).texture != null:
						bg_ok = true
				_check("anh nen ve tay da nap (Map001)", bg_ok)
				# Title co anh nen + nut Bat dau lon.
				var title_bg := false
				for ch in _main._title_panel.get_children():
					if ch is TextureRect and (ch as TextureRect).texture != null:
						title_bg = true
				_check("title co anh nen", title_bg)
				var btn := _find_button(_main._title_panel, "Bắt đầu chơi")
				_check("nut Bat dau ton tai", btn != null)
				if btn != null:
					_check("nut Bat dau lon 620x110", btn.custom_minimum_size == Vector2(620, 110))
				_check("lop nhan ton tai", _main._label_layer != null)
				_check("lop nhan duoi lop HUD", _main._label_layer.get_index() < _main._ui_layer.get_index())
				# Nhan cua hotspot ngoai man hinh (hs-tro-toi o (10,3),
				# camera o spawn) phai AN, hoac neu hien thi phai nam
				# gon trong man hinh (khong troi ra mep). Tu vong
				# artpass3 (zoom 1.4 + look-up -320) hotspot nay da
				# vao trong tam nhin luc spawn nen hien la dung.
				var hs_r := Rect2()
				for mk in _main.iso_map.markers:
					if String(mk.event_data.get("id", "")) == "hs-tro-toi":
						hs_r = (mk as Marker).label_screen_rect()
				var hs_ok := hs_r.size == Vector2.ZERO or (
					hs_r.position.x >= 16.0 and hs_r.end.x <= 704.0
					and hs_r.position.y >= 190.0 and hs_r.end.y <= 1264.0)
				_check("nhan hotspot ngoai man hinh bi an", hs_ok)
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
			_check("dien thoai khung rieng 680x900", _main._phone_panel.size == Vector2(680, 900))
			_check("dien thoai cach mep 20/216 (duoi nut Dien thoai (P))", _main._phone_panel.position == Vector2(20, 216))
			_check("dien thoai co notch", _main._phone_notch.visible)
			_check("dien thoai co thanh home", _main._phone_homebar.visible)
			var txt: String = str(_main._phone_content.text)
			_check("noi dung khong ma noi bo QuenBiet", not txt.contains("QuenBiet"))
			_check("noi dung khong ma noi bo BestFriend", not txt.contains("BestFriend"))
			_check("giai doan tieng Viet Quen biết", txt.contains("Quen biết"))
			_check("chan trang co ngay/vi", _main._phone_footer.text.contains("Ngày 1") and _main._phone_footer.text.contains("Ví"))
			_check("dien thoai co goi y tien trinh", _main._phone_hint.text.contains("Chương"))
			_check("ending hien tieng Viet, khong ID", _main._phone_hint.text.contains("Tự do") and not _main._phone_hint.text.contains("TuDo"))
			_check("dien thoai co meo xoay theo ngay", _main._phone_tip.text.begins_with("Mẹo: "))
			var soc: String = _main._social_text()
			_check("danh ba khong lap 'Bạn thân — Bạn thân'", not soc.contains("Bạn thân — Bạn thân"))
			_check("danh ba co Ban than 1 lan", soc.contains("Bạn thân"))
			_check("danh ba liet ke NPC chua quen", soc.contains("Cô Tư") and soc.contains("chưa quen"))
			_main._close_phone()
			_check("dong dien thoai", not _main._phone_panel.visible)
			_check("lop mo an theo", not _main._phone_dim.visible)
			_check("notch an theo", not _main._phone_notch.visible)
			_check("thanh home an theo", not _main._phone_homebar.visible)
			# Buoi 2: overlay ngay/dem + thu tu layer. Vong 5: overlay
			# len CanvasLayer layer 1 (tren canvas mac dinh) nhung
			# tao TRUOC lop nhan + lop HUD (cung layer 1) -> phu
			# deu toan bo the gioi, duoi nhan/HUD.
			_check("overlay ton tai", _main._daynight != null)
			_check("overlay tren canvas mac dinh (layer 1)", _main._overlay_layer.layer == 1)
			_check("overlay truoc lop nhan (ve duoi nhan)", _main._overlay_layer.get_index() < _main._label_layer.get_index())
			_check("overlay truoc lop HUD (ve duoi HUD)", _main._overlay_layer.get_index() < _main._ui_layer.get_index())
			_check("overlay phu kin man hinh", _main._daynight.size == Vector2(720, 1280))
			_check("overlay khong chan click", _main._daynight.mouse_filter == Control.MOUSE_FILTER_IGNORE)
			var mat := _main._daynight.material as CanvasItemMaterial
			_check("overlay che do NHAN", mat != null and mat.blend_mode == CanvasItemMaterial.BLEND_MODE_MUL)
			_check("khung Sang trang khong doi", _main._daynight.color == Color(1, 1, 1, 1))
			# Toast o GOC DUOI-TRAI (y=1216, chu 24, vong 5): y=720
			# cu che cua/cua so giua man hinh vai giay sau khi bam
			# F (kiem live 13:53); goc duoi khong de mat troi/trang.
			_check("toast goc duoi-trai, khong de mat troi/trang", _main._toast.position.y >= 1200.0)
			_main._advance_frame()
			_check("khung Chieu vang cam (nhan)", _main._daynight.color == Color(1.0, 0.82, 0.55, 1.0))
			_main._advance_frame()
			# Toi: Map001 co anh nen dem rieng (bg_map001_night.png,
			# doi tu .jpg sang .png vong 6 de feather mep duoi),
			# da toi san ~0.65) nen MUL nhe (0.7,0.78,0.95) de nhan
			# vat con ~0.7 do sang, thay ro mat/quan ao — quyet dinh
			# live-check 20/11 14:34 (khong phai 0.55 nhu test cu ghi:
			# 0.55 chi dung cho map KHONG co anh nen dem).
			_check("Map001 co anh nen dem rieng", _main.iso_map.has_night_bg)
			_check("khung Toi xanh dem dam (nhan)", _main._daynight.color == Color(0.7, 0.78, 0.95, 1.0))
			_check("Toi: dom sang cua so bat", _main.iso_map.night_glow != null and _main.iso_map.night_glow.visible and _main.iso_map.night_glow.lit)
			# Map001-002: diem sang cua so nam TRONG anh nen dem
			# (sky_in_image), khong con spots code nua.
			_check("Toi: co diem sang nha", _main.iso_map.night_glow.sky_in_image or _main.iso_map.night_glow.spots.size() > 0)
			_check("Toi: co trang (moon_on)", _main.iso_map.night_glow.moon_on)
			_check("Toi: co den duong", _main.iso_map.night_glow.lamps.size() > 0)
			_state = 3
		3:
			# Moi nhan (toa do man hinh 720x1280): nam duoi HUD gon
			# (y >= 190, day HUD thuc te ~173) va cach mep >= 16px
			# — kiem tra tren label_screen_rect() cua lop CanvasLayer.
			var all_ok := true
			var worst := ""
			var any_label := false
			for mk in _main.iso_map.markers:
				var r := (mk as Marker).label_screen_rect()
				if r.size == Vector2.ZERO:
					continue
				any_label = true
				var ok: bool = r.position.x >= 16.0 - 0.5 \
					and r.end.x <= 720.0 - 16.0 + 0.5 \
					and r.position.y >= 190.0 - 0.5 \
					and r.end.y <= 1200.0 + 0.5
				if not ok:
					all_ok = false
					worst = "%s %s" % [String(mk.event_data.get("name", "?")), str(r)]
			_check("co nhan CanvasLayer hien", any_label)
			_check("moi nhan duoi HUD + cach mep (man hinh)", all_ok)
			if not all_ok:
				print("  nhan vi pham: ", worst)
			print("ARTPASS TEST: %d PASS / %d FAIL" % [_pass, _fail])
			quit(1 if _fail > 0 else 0)
