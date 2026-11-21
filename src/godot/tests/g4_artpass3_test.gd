extends SceneTree
## G4 artpass3 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_artpass3_test.gd
## Kiem tra vong sua 20/11 12:30 (kiem live 12:28-12:32):
##  1. Anh moi ton tai (nen dem, troi dem, dat ve tay, troi mo rong).
##  2. Doi khung Toi doi anh nen sang ban dem + tint nhan vat toi.
##  3. Nhan khong chong nhau (cua/hotspot/che tao/NPC tach vi tri).
##  4. HUD gon + dien thoai khong de len dong stats cua HUD.
##  5. Mat troi hien theo khung (SkyEffects).

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
		print("G4 ARTPASS3 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Anh moi ton tai.
				_check("co bg_map001_night.png", ResourceLoader.exists("res://art/bg_map001_night.png"))
				_check("co sky_night.jpg", ResourceLoader.exists("res://art/sky_night.jpg"))
				_check("co ground_wide.jpg", ResourceLoader.exists("res://art/ground_wide.jpg"))
				_check("co sky_wide.jpg", ResourceLoader.exists("res://art/sky_wide.jpg"))
				# 2. Ground sprite cua Main ton tai, mep tren duoi chan mat tien.
				# Vong 17: Map001 dung ground_map001.png ve tay, map
				# khac moi dung ground_wide.jpg — chap nhan ca 2.
				var g: Sprite2D = null
				for c in _main.get_children():
					if c is Sprite2D and (c as Sprite2D).texture != null and ((c as Sprite2D).texture.resource_path.ends_with("ground_wide.jpg") or (c as Sprite2D).texture.resource_path.ends_with("ground_map001.png")):
						g = c
				_check("ground sprite ton tai", g != null)
				if g != null:
					var top := g.position.y - 450.0 * g.scale.y
					_check("mep tren dat (y~280) duoi chan mat tien", top > 200.0 and top < 340.0, str(top))
				# 3. HUD gon: panel cao thuc te ~157 (min-size cua noi
				# dung day tu size dat 124), day ~173.
				_check("HUD gon (cao <= 170)", _main._hud_map.get_parent().get_parent().size.y <= 170.0)
				# 4. Dien thoai o duoi HUD (y >= 189: day HUD 173 + 16).
				_check("panel dien thoai y >= 189", _main._phone_panel.position.y >= 189.0)
				# 5. SkyEffects ton tai, khung Sang co mat troi (frame 0).
				_check("skyfx ton tai", _main.iso_map.skyfx != null)
				# Vong 16: Map001 dung anh nha ong cao thay composite cu.
				_check("khung Sang: anh nen ngay", _main.iso_map._bg_sprite.texture.resource_path.ends_with("bg_map001_tall.png"))
				# Mat troi Sang o duoi HUD (the gioi y -140, man hinh
				# ~245) — khong bi HUD che nhu -195 cu.
				_check("mat troi Sang duoi HUD", _main.iso_map.skyfx.sun_pos.y > -160.0 and _main.iso_map.skyfx.sun_pos.y < -100.0)
				# Tat title de test nhu choi that.
				_main._on_start_pressed()
				_state = 1
		1:
			# Doi khung -> Chieu -> Toi.
			_main._advance_frame()
			_main._advance_frame()
			_check("doi khung -> Toi", _main.frame_idx == 2)
			_check("khung Toi: anh nen dem", _main.iso_map._bg_sprite.texture.resource_path.ends_with("bg_map001_tall_night.png"))
			# Vong 5: bo tint rieng nhan vat — lop overlay MUL
			# thong nhat toi ca nhan vat; tint rieng nhan doi lam
			# nhan vat thanh bong den (kiem live 14:34). Kiem tra
			# overlay Toi toi vua (r < 0.75) + nhan vat trang.
			_check("khung Toi: overlay toi (r < 0.75)", _main._daynight.color.r < 0.75)
			_check("khung Toi: nhan vat khong tint rieng (trang)", _main.player._sprite.modulate.r > 0.99)
			_check("khung Toi: night_glow bat", _main.iso_map.night_glow.visible)
			_check("khung Toi: trang/sao code tat (anh co san)", _main.iso_map.night_glow.sky_in_image)
			_state = 2
		2:
			# Cho camera smoothing on dinh (frame >= 30) roi moi
			# check nhan — luc moi load camera con truot tu (0,0)
			# nen rect man hinh chua dung vi tri that.
			if _frame < 30:
				return
			# Trang ve bang code phai nam trong vung troi thay duoc
			# luc spawn (the gioi x 100..600, y -300..-20).
			var mp: Vector2 = _main.iso_map.skyfx.moon_pos
			_check("khung Toi: trang o vi tri thay duoc luc spawn",
				mp.x > 100.0 and mp.x < 600.0 and mp.y > -300.0 and mp.y < -20.0)
			# Mo dien thoai: khoi Hom nay co noi dung, panel khong de HUD.
			_main._open_phone()
			_check("dien thoai mo", _main.phone_open)
			_check("khoi Hom nay co noi dung", _main._phone_today.text != "")
			_check("panel dien thoai duoi dong stats HUD",
				_main._phone_panel.position.y >= _main._hud_map.get_parent().get_parent().size.y + 26.0)
			# Nhan Map001 khong chong nhau: lay rect man hinh DA
			# RESOLVE cua cua ra / hotspot / goc che tao / Ban Than
			# (label_override neu co — cai nguoi choi thay that;
			# rect goc co the chong, resolver doi moi frame se
			# dich — vong 7: zoom 1.25 lam rect goc "Co Tu" vs
			# "Goc Che Tao" cham nhau, resolver dich ra).
			var rects := {}
			for mk in _main.iso_map.markers:
				var r: Rect2 = (mk.label_override if (mk.label_override as Rect2).size != Vector2.ZERO else mk.label_screen_rect())
				if r.size != Vector2.ZERO:
					rects[String(mk.event_data.get("name", ""))] = r
			var overlap := false
			var keys := rects.keys()
			for i in range(keys.size()):
				for j in range(i + 1, keys.size()):
					if (rects[keys[i]] as Rect2).intersects(rects[keys[j]] as Rect2):
						overlap = true
						print("  OVERLAP ", keys[i], " vs ", keys[j])
			_check("nhan Map001 khong chong nhau", not overlap)
			_main._close_phone()
			_state = 3
		3:
			# Ve Sang: anh nen ngay tro lai + tint trang.
			_main._advance_frame()
			_check("ve Sang: anh nen ngay", _main.iso_map._bg_sprite.texture.resource_path.ends_with("bg_map001_tall.png"))
			_check("ve Sang: tint trang tro lai", _main.player._sprite.modulate.r > 0.99)
			print("G4 ARTPASS3 TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
