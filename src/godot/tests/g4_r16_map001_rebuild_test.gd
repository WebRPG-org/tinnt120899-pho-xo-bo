extends SceneTree
## G4 vong 16 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r16_map001_rebuild_test.gd
## Kiem tra Map001 dung lai buoc 1 (22/11, theo Claude viec 1):
##  1. Anh nha ong cao ton tai, dung co 864x1536 (9:16).
##  2. Ban dem ton tai, toi hon ban ngay ro (mean < 0.65x).
##  3. Map001 dung anh cao (has_tall_bg), day neo o offset.y+20,
##     dinh vuot tam nhin hang tren (offset.y-777) — phu kin 9:16.
##  4. Map001 KHONG ve dai troi sky_wide nua (se de len tang tren).
##  5. Doi khung Toi doi sang anh dem, ve Sang doi lai anh ngay.
##  6. Map002 khong doi: van sky_band + sky_wide (khong hoi quy).

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

func _mean_sample(img: Image) -> float:
	var total := 0.0
	var n := 0
	for y in range(0, img.get_height(), 16):
		for x in range(0, img.get_width(), 16):
			var c := img.get_pixel(x, y)
			total += (c.r + c.g + c.b) / 3.0
			n += 1
	return total / float(n)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 400:
		print("G4 R16 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Anh ton tai + dung co.
				_check("co bg_map001_tall.png", ResourceLoader.exists("res://art/bg_map001_tall.png"))
				_check("co bg_map001_tall_night.png", ResourceLoader.exists("res://art/bg_map001_tall_night.png"))
				var day := Image.load_from_file("res://art/bg_map001_tall.png")
				var night := Image.load_from_file("res://art/bg_map001_tall_night.png")
				_check("anh ngay 864x1536", day != null and day.get_width() == 864 and day.get_height() == 1536,
					"ngay: %s" % [str(day.get_size()) if day != null else "null"])
				_check("anh dem 864x1536", night != null and night.get_width() == 864 and night.get_height() == 1536,
					"dem: %s" % [str(night.get_size()) if night != null else "null"])
				# 2. Ban dem toi hon ro.
				if day != null and night != null:
					var md := _mean_sample(day)
					var mn := _mean_sample(night)
					_check("dem toi hon ngay (mean %.1f < 0.65 x %.1f)" % [mn, md], mn < md * 0.65,
						"ti le %.2f" % (mn / md))
				_state = 1
		1:
			if _frame >= 6:
				# 3-4. Map001 dung anh cao, khong sky_wide.
				var iso = _main.iso_map
				_check("Map001 has_tall_bg", iso.has_tall_bg)
				_check("bg sprite la anh cao", iso._bg_sprite != null and iso._bg_sprite.texture != null
					and iso._bg_sprite.texture.resource_path.ends_with("bg_map001_tall.png"),
					str(iso._bg_sprite.texture.resource_path) if iso._bg_sprite != null and iso._bg_sprite.texture != null else "null")
				var off: Vector2 = iso.offset
				var expect_y := off.y + 20.0 - 768.0
				_check("day anh neo offset.y+20", iso._bg_sprite != null
					and absf((iso._bg_sprite.position.y + 768.0) - (off.y + 20.0)) < 1.0,
					"pos.y=%.1f off.y=%.1f" % [iso._bg_sprite.position.y, off.y])
				_check("dinh anh vuot tam nhin hang tren", iso._bg_sprite != null
					and (iso._bg_sprite.position.y - 768.0) < (off.y - 777.0),
					"dinh=%.1f moc=%.1f" % [iso._bg_sprite.position.y - 768.0, off.y - 777.0])
				_check("Map001 khong co sky_wide", iso._sky_ext_sprite == null)
				_check("Map001 co anh dem rieng", iso.has_night_bg)
				# 5. Doi khung doi anh.
				iso.set_frame(2)
				_check("Toi -> anh dem", iso._bg_sprite.texture.resource_path.ends_with("bg_map001_tall_night.png"))
				iso.set_frame(0)
				_check("Sang -> anh ngay", iso._bg_sprite.texture.resource_path.ends_with("bg_map001_tall.png"))
				_state = 2
		2:
			if _frame >= 9:
				# 6. Map002 khong doi.
				_main.load_map(2, Vector2i(5, 4))
				var iso2 = _main.iso_map
				_check("Map002 khong dung anh cao", not iso2.has_tall_bg)
				_check("Map002 bg la sky_band", iso2._bg_sprite != null and iso2._bg_sprite.texture != null
					and iso2._bg_sprite.texture.resource_path.ends_with("sky_band.png"))
				_check("Map002 van co sky_wide", iso2._sky_ext_sprite != null)
				print("G4 R16 TEST: %d PASS, %d FAIL" % [_pass, _fail])
				quit(1 if _fail > 0 else 0)
