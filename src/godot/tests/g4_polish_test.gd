extends SceneTree
## G4 polish test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_polish_test.gd
## Kiem tra G4 buoc 4 (polish §8.5, 20/11 ~14:00):
##  1. Nen troi mac dinh cho Map003+ (sky_band + sky_wide, ngay + dem).
##  2. HUD co chu theo ten map (ten dai khong bi cat o panel 452px).
##  3. Nhan khong chong nhau tren MOI map (Map002/Map003 co 2 cua day map).

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null
var _wait_until := 0

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _check_fit(name: String) -> void:
	# Bat bien cua _fit_hud_map: vua panel (<= 412px) VA co lon nhat
	# co the (co +2 thi vuot 412, tru khi da o co toi da 30).
	var sz: int = _main._hud_map.get_theme_font_size("font_size")
	var w: float = _main.font_bold.get_string_size(_main._hud_map.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
	_check(name + ": ten vua panel 412px", w <= 412.0, str(w))
	if sz < 30:
		var w2: float = _main.font_bold.get_string_size(_main._hud_map.text, HORIZONTAL_ALIGNMENT_LEFT, -1, sz + 2).x
		_check(name + ": co lon nhat co the", w2 > 412.0, "co %d vua, co %d cung vua" % [sz, sz + 2])
	else:
		_check(name + ": co toi da 30", true)

func _labels_overlap() -> String:
	# Tra ve "" neu khong co cap nhan hien nao chong nhau, neu khong
	# tra ve ten cap chong nhau dau tien (de in ra khi FAIL).
	var rects := {}
	for mk in _main.iso_map.markers:
		var r: Rect2 = mk.label_screen_rect()
		if r.size != Vector2.ZERO:
			rects[String(mk.event_data.get("name", ""))] = r
	var keys := rects.keys()
	for i in range(keys.size()):
		for j in range(i + 1, keys.size()):
			if (rects[keys[i]] as Rect2).intersects(rects[keys[j]] as Rect2):
				return "%s vs %s" % [keys[i], keys[j]]
	return ""

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 600:
		print("G4 POLISH TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 2. HUD Map001: "Xóm Trọ Cũ" o co 30 do 415px > 412
				# (HUD cu tran ca ten ngan, khong chi ten dai) nen
				# _fit_hud_map phai co xuong 28 — bat bien vua + lon nhat.
				_check_fit("Map001")
				# 1. Map001 van co anh composite + sky_wide rieng.
				_check("Map001: bg composite", _main.iso_map._bg_sprite.texture.resource_path.ends_with("bg_map001.png"))
				_check("Map001: co sky_wide", _main.iso_map._sky_ext_sprite != null)
				_main._on_start_pressed()
				_main.load_map(18, Vector2i(5, 4))
				_state = 1
		1:
			# 2. Ten dai nhat "Phố Đi Bộ – Chợ Đêm": co nho xuong
			# nhung van >= 20, do rong vua long panel 412px.
			_check_fit("Map018")
			_main.load_map(3, Vector2i(5, 4))
			_wait_until = _frame + 40
			_state = 2
		2:
			if _frame < _wait_until:
				return
			# 1. Map003 co nen troi mac dinh: sky_band + sky_wide.
			_check("Map003: co bg sprite", _main.iso_map._bg_sprite != null)
			if _main.iso_map._bg_sprite != null:
				_check("Map003: bg la sky_band",
					_main.iso_map._bg_sprite.texture.resource_path.ends_with("sky_band.png"))
				_check("Map003: bg o dung vi tri (offset.y-190)",
					absf(_main.iso_map._bg_sprite.position.y - (_main.iso_map.offset.y - 190.0)) < 1.0)
			_check("Map003: co sky_wide", _main.iso_map._sky_ext_sprite != null)
			if _main.iso_map._sky_ext_sprite != null:
				_check("Map003: sky_wide o dung vi tri (offset.y-530)",
					absf(_main.iso_map._sky_ext_sprite.position.y - (_main.iso_map.offset.y - 530.0)) < 1.0)
			_check("Map003: co anh dem", _main.iso_map.has_night_bg)
			# 3. Nhan Map003 khong chong nhau (2 cua + 2 NPC).
			_check("Map003: nhan khong chong nhau", _labels_overlap() == "", _labels_overlap())
			# 1. Doi khung -> Toi: Map003 doi sang anh dem.
			_main._advance_frame()
			_main._advance_frame()
			_check("Map003 Toi: bg doi sky_night",
				_main.iso_map._bg_sprite.texture.resource_path.ends_with("sky_night.jpg"))
			_main.load_map(2, Vector2i(5, 4))
			_wait_until = _frame + 40
			_state = 3
		3:
			if _frame < _wait_until:
				return
			# 2. HUD Map002 ("Chợ Đầu Mối") vua panel, co lon nhat co the.
			_check_fit("Map002")
			# 3. Nhan Map002 khong chong nhau (2 cua day map + NPC + hotspot + che tao).
			_check("Map002: nhan khong chong nhau", _labels_overlap() == "", _labels_overlap())
			# Ve Sang: anh ngay tro lai.
			_main._advance_frame()
			_check("Map002 ve Sang: bg sky_band ngay",
				_main.iso_map._bg_sprite.texture.resource_path.ends_with("sky_band.png"))
			print("G4 POLISH TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
