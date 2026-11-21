extends SceneTree
## G4 artpass5 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_artpass5_test.gd
## Kiem tra vong sua 20/11 14:40 (kiem live 14:34-14:40):
##  1. LOI GOC: overlay ngay/dem o CanvasLayer layer 1, truoc lop
##     nhan + lop HUD (cung layer 1) -> phu DEU len toan bo the
##     gioi, khong con chia doi sang/toi theo vung.
##  2. Nhan vat Toi khong con bong den: bo tint rieng, overlay
##     Toi (0.7,0.78,0.95) -> nhan vat con ~0.7 do sang.
##  3. Mat troi/trang neo theo camera (luon trong khung khi di
##     sang phai khu TAP HOA).
##  4. Nhan: khe ho >= 12px, khong de len dau nhan vat / bieu
##     tuong, day nhan <= 1200.
##  5. Toast o goc duoi-trai, chu 24.
##  6. Dien thoai: content scroll 238 (dong Anh Ba tron), actions
##     scroll 192.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null
var _moon_before := Vector2.INF

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
		print("G4 ARTPASS5 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Overlay thong nhat tren toan bo the gioi.
				_check("overlay layer 1 (tren canvas mac dinh)", _main._overlay_layer.layer == 1)
				_check("overlay truoc lop nhan", _main._overlay_layer.get_index() < _main._label_layer.get_index())
				_check("overlay truoc lop HUD", _main._overlay_layer.get_index() < _main._ui_layer.get_index())
				_check("overlay phu kin man hinh", _main._daynight.size == Vector2(720, 1280))
				var mat := _main._daynight.material as CanvasItemMaterial
				_check("overlay che do NHAN", mat != null and mat.blend_mode == CanvasItemMaterial.BLEND_MODE_MUL)
				# 5. Toast goc duoi-trai, chu nho.
				_check("toast y >= 1200 (goc duoi)", _main._toast.position.y >= 1200.0)
				_check("toast x <= 60 (goc trai)", _main._toast.position.x <= 60.0)
				_check("toast chu 24", _main._toast.get_theme_font_size("font_size") == 24)
				# 6. Dien thoai: scroll cao moi.
				_check("content scroll 238", _main._phone_content_scroll.custom_minimum_size.y == 238.0)
				_check("actions scroll 192", _main._phone_act_scroll.custom_minimum_size.y == 192.0)
				_main._on_start_pressed()
				_state = 1
		1:
			# Sang: mat troi neo camera — dich chuyen NGUOI CHOI
			# sang phai (camera bam theo, Main._process dat lai
			# camera moi frame nen khong set truc tiep camera),
			# mat troi phai o cung vi tri MAN HINH.
			var ct0 := _main.get_viewport().get_canvas_transform()
			_moon_before = ct0 * _main.iso_map.skyfx.sun_pos
			_main.player.place(_main.iso_map, Vector2i(10, 5))
			_state = 2
		2:
			if _frame < 60:
				return
			var ct1 := _main.get_viewport().get_canvas_transform()
			var sun1: Vector2 = ct1 * _main.iso_map.skyfx.sun_pos
			# Mat troi o cung vi tri man hinh sau khi di phai
			# (sai so smoothing camera < 40px).
			_check("mat troi neo camera (cung vi tri man hinh)", sun1.distance_to(_moon_before) < 40.0,
				"%s -> %s" % [str(_moon_before), str(sun1)])
			# 3. Doi khung -> Toi, trang neo camera.
			_main._advance_frame()
			_main._advance_frame()
			_check("doi khung -> Toi", _main.frame_idx == 2)
			# 2. Khong tint rieng + overlay nhe.
			_check("Toi: nhan vat trang (khong tint rieng)", _main.player._sprite.modulate.r > 0.99)
			_check("Toi: overlay (0.7,0.78,0.95)", _main._daynight.color == Color(0.7, 0.78, 0.95, 1.0))
			_state = 3
		3:
			if _frame < 90:
				return
			# Trang o vi tri man hinh co dinh (400,300): doi ra
			# world qua canvas transform, phai nam duoi HUD
			# (y man hinh 190..400) va trong khung (x 100..650).
			var ct := _main.get_viewport().get_canvas_transform()
			var moon_screen: Vector2 = ct * _main.iso_map.skyfx.moon_pos
			_check("trang trong khung hinh (duoi HUD, tren mai)",
				moon_screen.x > 100.0 and moon_screen.x < 650.0
				and moon_screen.y > 190.0 and moon_screen.y < 420.0, str(moon_screen))
			# Ve lai spawn: trang van o cung vi tri man hinh.
			_moon_before = moon_screen
			_main.player.place(_main.iso_map, Vector2i(4, 5))
			_state = 4
		4:
			if _frame < 150:
				return
			var ct2 := _main.get_viewport().get_canvas_transform()
			var moon_screen2: Vector2 = ct2 * _main.iso_map.skyfx.moon_pos
			_check("trang van o cung vi tri man hinh sau khi ve spawn",
				moon_screen2.distance_to(_moon_before) < 40.0,
				"%s -> %s" % [str(_moon_before), str(moon_screen2)])
			# 4. Nhan: khong chong nhau, khe ho >= 12px theo truc
			# doc khi x chong lap, khong de len dau nhan vat /
			# bieu tuong, day <= 1200.
			var ct3 := _main.get_viewport().get_canvas_transform()
			var obstacles: Array[Rect2] = []
			obstacles.append(_main._sprite_obstacle_rect(ct3 * _main.player.position))
			for mk in _main.iso_map.markers:
				if String(mk.event_data.get("kind", "")) == "npc":
					obstacles.append(_main._sprite_obstacle_rect(ct3 * mk.global_position))
			var rects := {}
			for mk in _main.iso_map.markers:
				# Vong 15: nhan NPC trong the gioi khong co override
				# (resolver khong dich) — lay rect man hinh that
				# cua Label con (label_screen_rect) nhu polish test.
				var ov: Rect2 = mk.label_override if mk.label_override.size != Vector2.ZERO else mk.label_screen_rect()
				if ov.size != Vector2.ZERO:
					rects[String(mk.event_data.get("name", ""))] = ov
			var bad := ""
			var keys := rects.keys()
			for i in range(keys.size()):
				var ri: Rect2 = rects[keys[i]]
				if ri.end.y > 1200.0 + 0.5:
					bad = "%s vuot day 1200 (%s)" % [keys[i], str(ri)]
				for o in obstacles:
					if ri.intersects(o):
						bad = "%s de len dau/bieu tuong" % keys[i]
				for j in range(i + 1, keys.size()):
					var rj: Rect2 = rects[keys[j]]
					if ri.intersects(rj):
						bad = "%s chong %s" % [keys[i], keys[j]]
					elif ri.end.x > rj.position.x and rj.end.x > ri.position.x:
						# X chong lap: khe doc phai >= 10px.
						var gap := 0.0
						if ri.end.y <= rj.position.y:
							gap = rj.position.y - ri.end.y
						elif rj.end.y <= ri.position.y:
							gap = ri.position.y - rj.end.y
						if gap < 10.0:
							bad = "%s sat %s (khe %.1f)" % [keys[i], keys[j], gap]
			_check("nhan: khong chong, khe >= 10, day <= 1200", bad == "", bad)
			print("G4 ARTPASS5 TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
