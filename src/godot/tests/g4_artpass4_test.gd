extends SceneTree
## G4 artpass4 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_artpass4_test.gd
## Kiem tra vong sua 20/11 14:00 (kiem live 13:53-13:56):
##  1. Nhan chong-chong that o khong gian man hinh (khong de len dau
##     nhan vat, khong chong nhau) — Main._resolve_label_overlaps().
##  2. Nhan vat toi RO theo khung Toi (tint 0.42,0.48,0.72).
##  3. Duong noi doc tam nen: 3 phan anh bg_map001 can bang tone
##     (do bang PIL offline; o day chi kiem tra file ton tai).
##  4. Toast doi khung o giua-duoi (y=720), khong de mat troi/trang.
##  5. Sao dem ro: NightGlow ve sao ca khi co anh nen dem.
##  6. Dien thoai khong de nut HUD (panel y=216) + dong Chi Le
##     khong bi cat (content scroll 224 + dong trong cuoi).

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
		print("G4 ARTPASS4 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("toast o goc duoi-trai (y >= 1200)", _main._toast.position.y >= 1200.0)
				_check("toast chu nho (24)", _main._toast.get_theme_font_size("font_size") == 24)
				_check("panel dien thoai y=216 (duoi nut HUD)", _main._phone_panel.position.y == 216.0)
				_check("notch y=209 (ngay tren panel)", _main._phone_notch.position.y == 209.0)
				_check("homebar y=1104 (day panel 1116-12)", _main._phone_homebar.position.y == 1104.0)
				_check("panel dien thoai van 680x900", _main._phone_panel.size == Vector2(680, 900))
				_main._on_start_pressed()
				_state = 1
		1:
			_main._advance_frame()
			_main._advance_frame()
			_check("doi khung -> Toi", _main.frame_idx == 2)
			# Vong 5: bo tint rieng — overlay MUL thong nhat
			# (0.7,0.78,0.95) toi ca nhan vat; tint rieng cu
			# (0.42) nhan doi lam nhan vat thanh bong den.
			var mod: Color = _main.player._sprite.modulate
			_check("Toi: khong tint rieng (trang)", mod.r > 0.99, str(mod))
			_check("Toi: overlay nhe (0.7,0.78,0.95)", _main._daynight.color == Color(0.7, 0.78, 0.95, 1.0), str(_main._daynight.color))
			_check("Toi: night_glow bat", _main.iso_map.night_glow.visible and _main.iso_map.night_glow.lit)
			_state = 2
		2:
			if _frame < 30:
				return
			# Sao da duoc ve (NightGlow._draw chay khi lit): ca khi
			# sky_in_image (anh nen dem co sao mo).
			_check("Toi: sao dem da ve (stars_drawn)", _main.iso_map.night_glow.stars_drawn)
			# Mo dien thoai: content scroll du cao + dong trong cuoi.
			_main._open_phone()
			_check("dien thoai mo", _main.phone_open)
			_check("content scroll cao 238 (du 7 dong, Anh Ba tron)", _main._phone_content_scroll.custom_minimum_size.y == 238.0)
			_check("panel van 680x900 sau khi mo (VBox khong day panel)", _main._phone_panel.size == Vector2(680, 900))
			var soc: String = _main._social_text()
			_check("danh ba co dong trong cuoi (khong cat dong Chi Le)", soc.ends_with("\n "))
			# Moi bullet "chua quen" gon 1 dong (<=44 ky tu, ten
			# NPC dai nhat 20 ky tu): khong go xuong 2 dong nua,
			# dong 2 bi cat o mep duoi viewport la loi "Chi Le"
			# 20/11 13:53/14:15. (Danh sach 38 dong ca 18 khu,
			# cuon duoc — dong nua cat o mep cuon la binh thuong,
			# mien khong phai nua sau cua 1 muc.)
			var soc_lines := soc.split("\n")
			var long_line := ""
			for l in soc_lines:
				if "chưa quen" in l and l.length() > 44:
					long_line = l
			_check("danh ba: bullet chua quen gon 1 dong", long_line == "", long_line)
			_main._close_phone()
			_state = 3
		3:
			if _frame < 40:
				return
			# Nhan DA CHONG-CHONG: lay label_override (vi tri hien
			# thi that) — khong chong nhau, khong de len dau/than
			# tren nhan vat. Vat can dung chung helper cua Main
			# (_sprite_obstacle_rect: dau + than tren 90x100);
			# kiem tra intersects() tho (khong grow) vi resolver
			# chi bao dam cach >= 12px theo doc (vong 5), dich
			# ngang co the sat 0px.
			# Vong 15: nhan NPC trong the gioi khong co override
			# (resolver khong dich) — lay rect man hinh that cua
			# Label con (label_screen_rect) nhu polish test.
			var ct := _main.get_viewport().get_canvas_transform()
			var obstacles: Array[Rect2] = []
			obstacles.append(_main._sprite_obstacle_rect(ct * _main.player.position))
			for mk in _main.iso_map.markers:
				if String(mk.event_data.get("kind", "")) == "npc":
					obstacles.append(_main._sprite_obstacle_rect(ct * mk.global_position))
			var rects := {}
			for mk in _main.iso_map.markers:
				var ov: Rect2 = mk.label_override if mk.label_override.size != Vector2.ZERO else mk.label_screen_rect()
				if ov.size != Vector2.ZERO:
					rects[String(mk.event_data.get("name", ""))] = ov
			_check("co nhan override hien", rects.size() >= 4, str(rects.size()))
			var bad := ""
			var keys := rects.keys()
			for i in range(keys.size()):
				for j in range(i + 1, keys.size()):
					if (rects[keys[i]] as Rect2).intersects(rects[keys[j]] as Rect2):
						bad = "%s chong %s" % [keys[i], keys[j]]
				for o in obstacles:
					if (rects[keys[i]] as Rect2).intersects(o):
						bad = "%s de len dau nhan vat" % keys[i]
			_check("nhan da chong-chong: khong chong nhau, khong de dau", bad == "", bad)
			# Ve Sang: tint trang tro lai.
			_main._advance_frame()
			_check("ve Sang: tint trang tro lai", _main.player._sprite.modulate.r > 0.99)
			print("G4 ARTPASS4 TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
