extends SceneTree
## G4 vong 17 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r17_sky_test.gd
## Kiem tra vong sua 22/11 ~01:00 (nit §38.4 vong 16, xem anh r16-01/03):
##  1. Mat troi Sang doi sang phai (man hinh x 560): khong de len
##     mai hien trai + bien PHO BO luc spawn (anh nha ong cao khong
##     co vung troi that; ben phai chi co tuong tang tren).
##  2. Sao dem neo CAMERA o dai man hinh y 208..262: duoi HUD (~200),
##     tren mai hien (~280) — khong roi len mai hien/bien hieu nhu
##     dai cu (the gioi y -108..-28) nua.
##  3. Trang + mat troi Chieu khong doi (hoi quy).

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
		print("G4 R17 SKY TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				var sun: Vector2 = _main.iso_map.skyfx.sun_pos
				# Mat troi Sang van duoi HUD (y nhu cu) nhung sang
				# phai: the gioi x ~440 (man hinh ~560), khong con
				# o trai (~128, man hinh ~170) de len bien PHO BO.
				_check("mat troi Sang duoi HUD (y -160..-100)", sun.y > -160.0 and sun.y < -100.0, str(sun))
				_check("mat troi Sang sang phai (x > 350)", sun.x > 350.0, str(sun))
				_check("mat troi Sang khong qua phai (x < 550)", sun.x < 550.0, str(sun))
				# Vong 17: Map001 dung dat ve tay rieng.
				_check("Map001: dat ve tay ground_map001.png",
					_main._ground_sprite != null and _main._ground_sprite.texture.resource_path.ends_with("ground_map001.png"),
					"" if _main._ground_sprite == null else _main._ground_sprite.texture.resource_path)
				_main._on_start_pressed()
				# Sang Chieu ngay de state 1 (frame sau) doc duoc
				# sun_pos Chieu moi (sau _draw).
				_main._advance_frame()
				_state = 1
		1:
			# Frame sau _advance_frame: _draw cua SkyEffects da
			# chay, sun_pos moi cap nhat sang mat troi Chieu.
			var sun2: Vector2 = _main.iso_map.skyfx.sun_pos
			_check("mat troi Chieu giu vi tri cu (x 200..400)", sun2.x > 200.0 and sun2.x < 400.0, str(sun2))
			# Doi khung -> Toi.
			_main._advance_frame()
			_check("doi khung -> Toi", _main.frame_idx == 2)
			_check("khung Toi: night_glow bat", _main.iso_map.night_glow.visible and _main.iso_map.night_glow.lit)
			_state = 2
		2:
			if _frame < 30:
				return
			var ng = _main.iso_map.night_glow
			_check("Toi: sao dem da ve (stars_drawn)", ng.stars_drawn)
			# Dai sao neo camera: man hinh y 208..262 — duoi HUD
			# (~200), tren mai hien (~280).
			_check("dai sao duoi HUD (top >= 200)", ng.star_screen_top >= 200.0, str(ng.star_screen_top))
			_check("dai sao tren mai hien (bottom <= 275)", ng.star_screen_bottom <= 275.0, str(ng.star_screen_bottom))
			# Trang neo camera khong doi.
			var mp: Vector2 = _main.iso_map.skyfx.moon_pos
			_check("khung Toi: trang o vi tri thay duoc luc spawn",
				mp.x > 100.0 and mp.x < 600.0 and mp.y > -300.0 and mp.y < -20.0, str(mp))
			# Ve Sang.
			_main._advance_frame()
			_state = 3
		3:
			# Frame sau _advance_frame: sun_pos moi cap nhat ve
			# mat troi Sang.
			var sun3: Vector2 = _main.iso_map.skyfx.sun_pos
			_check("ve Sang: mat troi van sang phai (x > 350)", sun3.x > 350.0, str(sun3))
			# Doi dat theo map: sang Map002 ve dat ve tay rieng
			# (vong 20), ve Map001 lai dat ve tay.
			_main.load_map(2, Vector2i(5, 4))
			_check("Map002: dat ve tay ground_map002.png",
				_main._ground_sprite.texture.resource_path.ends_with("ground_map002.png"),
				_main._ground_sprite.texture.resource_path)
			_main.load_map(1, Vector2i(4, 5))
			_check("ve Map001: dat lai ve tay ground_map001.png",
				_main._ground_sprite.texture.resource_path.ends_with("ground_map001.png"),
				_main._ground_sprite.texture.resource_path)
			print("G4 R17 SKY TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
