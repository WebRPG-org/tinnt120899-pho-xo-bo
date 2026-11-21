extends SceneTree
## Vong 6 test (20/11) — chay scene Main that headless:
##   godot --headless --path src/godot -s res://tests/v6_overlay_test.gd
## 1. Overlay ngay/dem PHAI o khong gian man hinh (follow_viewport =
##    false): luc camera o cuoi map (600,174), hinh chu nhat toan cuc
##    cua ColorRect van (0,0)-(720,1280) — loi goc vong 6: follow_
##    viewport=true bien overlay thanh hinh chu nhat THE GIOI
##    x 0..720 nen mep phai man hinh thoat lop phu, dai doc sang
##    nhu ban ngay o Toi/Chieu (ran gioi do duoc x=527).
## 2. Anh nen dem la PNG co alpha feather (bg_map001_night.png),
##    khong con .jpg cu.
## 3. Mat troi/trang neo man hinh o vung troi trong (y ~240, khong
##    de mai nha/bien hieu), ve shading mem (_draw_soft_disc).
## 4. Dao cu mép duoi (xe dap, xe day) doi xuong 2 o, khong con
##    bi cat nua luc spawn.
## 5. web_shell.html co watchdog nut tai + anh tieu de ve tay;
##    build_gh_pages.py chunk anh tieu de.

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name)

func _file_has(path: String, needle: String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false
	var s := f.get_as_text()
	return s.contains(needle)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	match _state:
		0:
			if _frame < 5:
				return
			# 1. Overlay o khong gian man hinh.
			_check("overlay khong follow_viewport", not _main._overlay_layer.follow_viewport_enabled)
			_check("overlay layer 1", _main._overlay_layer.layer == 1)
			# Dua camera ra cuoi map nhu nguoi choi dung o (10,1).
			_main._camera.position = Vector2(600, 174)
			_main._camera.reset_smoothing()
			_state = 1
		1:
			if _frame < 8:
				return
			var r: Rect2 = _main._daynight.get_global_rect()
			_check("overlay phu kin man hinh o cuoi map", r.position.distance_to(Vector2.ZERO) < 1.0 and r.size.distance_to(Vector2(720, 1280)) < 1.0)
			if not (r.position.distance_to(Vector2.ZERO) < 1.0):
				print("  overlay rect o cuoi map: ", r)
			# Ve lai spawn cho cac kiem tra sau.
			_main._camera.position = _main.player.position + Vector2(0, -320)
			_main._camera.reset_smoothing()
			_state = 2
		2:
			# 2. Anh nen dem PNG (feather) thay JPG.
			_check("anh nen dem PNG ton tai", ResourceLoader.exists("res://art/bg_map001_night.png"))
			_check("anh nen dem JPG cu da xoa", not ResourceLoader.exists("res://art/bg_map001_night.jpg"))
			_check("Map001 co anh nen dem rieng", _main.iso_map.has_night_bg)
			# 3. Mat troi/trang mem + o vung troi trong (y~240).
			_check("sky ve shading mem", _file_has("res://scripts/sky_effects.gd", "_draw_soft_disc"))
			var sky: SkyEffects = _main.iso_map.skyfx
			var cam: Camera2D = _main._camera
			var vp := Vector2(720, 1280)
			var top_left := cam.get_screen_center_position() - vp / (2.0 * cam.zoom)
			# Khung Sang: mat troi o (560,240) man hinh.
			# Vong 17: doi tu (170,240) sang phai — (170,240) cu de
			# len mai hien trai + bien PHO BO luc spawn (anh nha ong
			# cao khong co vung troi that; xem r16-01).
			var sun_screen: Vector2 = (sky.sun_pos - top_left) * cam.zoom
			_check("mat troi Sang o vung troi trong (560,240)", sun_screen.distance_to(Vector2(560, 240)) < 4.0)
			if sun_screen.distance_to(Vector2(560, 240)) >= 4.0:
				print("  sun_screen: ", sun_screen)
			_main._advance_frame()
			_main._advance_frame()
			_state = 3
		3:
			# Khung Toi: trang o (400,240) man hinh.
			var sky: SkyEffects = _main.iso_map.skyfx
			var cam: Camera2D = _main._camera
			var vp := Vector2(720, 1280)
			var top_left := cam.get_screen_center_position() - vp / (2.0 * cam.zoom)
			var moon_screen: Vector2 = (sky.moon_pos - top_left) * cam.zoom
			_check("mat trang Toi o vung troi trong (400,240)", moon_screen.distance_to(Vector2(400, 240)) < 4.0)
			if moon_screen.distance_to(Vector2(400, 240)) >= 4.0:
				print("  moon_screen: ", moon_screen)
			# 4. Dao cu mep duoi doi xuong.
			_check("xe dap doi xuong (12,11)", _file_has("res://scripts/nadia_scene.gd", "Vector2i(12, 11)"))
			_check("xe day doi xuong (8,15)", _file_has("res://scripts/nadia_scene.gd", "Vector2i(8, 15)"))
			_check("khong con xe dap cu (12,9)", not _file_has("res://scripts/nadia_scene.gd", "Vector2i(12, 9)"))
			_check("khong con xe day cu (8,13)", not _file_has("res://scripts/nadia_scene.gd", "Vector2i(8, 13)"))
			# 5. DOM shell + deploy.
			_check("shell co watchdog nut tai", _file_has("res://web_shell.html", "Đang khởi động game…") and _file_has("res://web_shell.html", "Đang tải chậm"))
			_check("shell co anh tieu de + nhan vat", _file_has("res://web_shell.html", "loadTitleArt") and _file_has("res://web_shell.html", "title-char-player"))
			_check("deploy chunk anh tieu de", _file_has("/home/hatch/workspace/pho-xo-bo/tools/godot/build_gh_pages.py", "IMG_PARTS"))
			print("V6 TEST: %d PASS / %d FAIL" % [_pass, _fail])
			quit(1 if _fail > 0 else 0)
