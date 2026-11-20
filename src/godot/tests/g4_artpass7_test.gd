extends SceneTree
## G4 artpass7 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_artpass7_test.gd
## Kiem tra vong sua 7 (20/11 16:26, kiem live):
##  1. Nhan hotspot doi tu "buoi" theo khung (goc: ten tinh
##     "Hem tro buoi toi", khong phai nhan ket do save/load).
##  2. Di chuyen bang EVENT phim (press_dir): nhan cham o FPS thap
##     van di; Shift+D (D hoa) van la KEY_D vat ly.
##  3. Camera thay het map luc spawn (zoom 1.25 + look-up -265):
##     dinh mat tien (-308) toi day dat + xe dap (~702).
##  4. Bong do nhan vat doi theo khung (Chieu dai, Toi mo).
##  5. Hotspot tat quang duoi dat khi nguoi choi dung tren o do.

var _pass := 0
var _fail := 0

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _step_player(p: Player) -> void:
	for i in range(30):
		p._process(0.02)
		if not p._moving:
			break

func _init() -> void:
	var font: Font = load("res://DejaVuSans.ttf")

	# --- 1. Nhan hotspot doi theo khung ---
	var mk := Marker.new()
	mk.event_data = {"kind": "hotspot", "name": "Hẻm trọ buổi tối",
		"id": "hs-tro-toi", "tile": [10, 3], "best_frame": "Tối"}
	mk.font = font
	root.add_child(mk)
	_check("nhan goc la 'buoi toi'", mk._display_name() == "Hẻm trọ buổi tối", mk._display_name())
	mk.set_frame_name("Sáng")
	_check("doi Sang -> 'buoi sang'", mk._display_name() == "Hẻm trọ buổi sáng", mk._display_name())
	mk.set_frame_name("Chiều")
	_check("doi Chieu -> 'buoi chieu'", mk._display_name() == "Hẻm trọ buổi chiều", mk._display_name())
	mk.set_frame_name("Tối")
	_check("doi Toi -> 'buoi toi'", mk._display_name() == "Hẻm trọ buổi tối", mk._display_name())
	mk.set_frame_name("Sáng")
	_check("quay lai Sang dung", mk._display_name() == "Hẻm trọ buổi sáng", mk._display_name())

	var mk2 := Marker.new()
	mk2.event_data = {"kind": "hotspot", "name": "Sạp rau buổi sáng",
		"id": "hs-cho-sang", "tile": [5, 4], "best_frame": "Sáng"}
	mk2.font = font
	root.add_child(mk2)
	mk2.set_frame_name("Tối")
	_check("sap rau doi Toi -> 'buoi toi'", mk2._display_name() == "Sạp rau buổi tối", mk2._display_name())

	var mk3 := Marker.new()
	mk3.event_data = {"kind": "npc", "name": "Cô Tư", "id": "co-tu", "tile": [3, 3]}
	mk3.font = font
	root.add_child(mk3)
	mk3.set_frame_name("Chiều")
	_check("nhan NPC khong doi theo khung", mk3._display_name() == "Cô Tư", mk3._display_name())

	var mk4 := Marker.new()
	mk4.event_data = {"kind": "hotspot", "name": "Góc phế liệu chợ",
		"id": "hs-cho-chieu", "tile": [6, 4], "best_frame": "Chiều"}
	mk4.font = font
	root.add_child(mk4)
	mk4.set_frame_name("Tối")
	_check("nhan khong co tu 'buoi' thi giu nguyen", mk4._display_name() == "Góc phế liệu chợ", mk4._display_name())

	# --- 5. Hotspot tat quang khi nguoi choi dung tren o ---
	mk.set_player_on(true)
	_check("player_on bat", mk._player_on == true)
	mk.set_player_on(false)
	_check("player_on tat", mk._player_on == false)

	# --- 4. Bong do nhan vat theo khung ---
	var cs := CharacterSprite.new()
	root.add_child(cs)
	cs.set_frame(0)
	_check("bong Sang ngan + lech phai", cs._shadow_rx == 14.0 and cs._shadow_off == Vector2(8, 3),
		str(cs._shadow_rx) + " " + str(cs._shadow_off))
	cs.set_frame(1)
	_check("bong Chieu dai ve trai", cs._shadow_rx == 26.0 and cs._shadow_off == Vector2(-22, 3),
		str(cs._shadow_rx) + " " + str(cs._shadow_off))
	cs.set_frame(2)
	_check("bong Toi mo", cs._shadow_alpha == 0.12, str(cs._shadow_alpha))

	# --- 2. Di chuyen bang EVENT phim ---
	var raw := FileAccess.get_file_as_string("res://data/maps.json")
	var data: Dictionary = JSON.parse_string(raw)
	var m1: Dictionary = {}
	for m in data["maps"]:
		if int(m["id"]) == 1:
			m1 = m
	var iso1 := IsoMap.new()
	root.add_child(iso1)
	iso1.build(m1, Marker, font, null)
	var p := Player.new()
	root.add_child(p)
	p.place(iso1, Vector2i(4, 5))
	_check("player spawn (4,5)", p.tile == Vector2i(4, 5))
	p.press_dir(Vector2i(0, -1))
	_step_player(p)
	_check("press_dir len -> (4,4)", p.tile == Vector2i(4, 4), str(p.tile))
	p.release_dir(Vector2i(0, -1))
	p.press_dir(Vector2i(1, 0))
	_step_player(p)
	_check("press_dir phai -> (5,4)", p.tile == Vector2i(5, 4), str(p.tile))
	p.release_dir(Vector2i(1, 0))
	p.press_dir(Vector2i(-1, 0))
	_step_player(p)
	_check("press_dir trai -> (4,4)", p.tile == Vector2i(4, 4), str(p.tile))
	p.release_dir(Vector2i(-1, 0))
	_check("release_dir xoa huong giu", p._held_dir() == Vector2i.ZERO, str(p._held_dir()))
	var held_tile := p.tile
	for i in range(10):
		p._process(0.02)
	_check("nha phim roi thi dung yen", p.tile == held_tile, str(p.tile))
	p.input_blocked = true
	p.press_dir(Vector2i(1, 0))
	_step_player(p)
	_check("input_blocked thi khong buoc", p.tile == held_tile, str(p.tile))
	p.input_blocked = false
	p.clear_held_dirs()
	_check("clear_held_dirs sach", p._held_dir() == Vector2i.ZERO)

	# --- 3. Camera thay het map luc spawn ---
	# main.gd khong co class_name — doc const qua script resource.
	var MainScript: GDScript = load("res://main.gd")
	var cam_zoom: float = MainScript.CAMERA_ZOOM
	var look_up: Vector2 = MainScript.CAMERA_LOOK_UP
	_check("CAMERA_ZOOM 1.25", cam_zoom == 1.25, str(cam_zoom))
	_check("CAMERA_LOOK_UP -265", look_up == Vector2(0, -265), str(look_up))
	var spawn_y := p.position.y  # (4,4) hien tai; spawn (4,5) y 462.
	spawn_y = iso1.tile_center(Vector2i(4, 5)).y
	var half_h := 1280.0 / (2.0 * cam_zoom)
	var cam_y := spawn_y + look_up.y
	_check("tam nhin tren thay dinh mat tien (-308)", cam_y - half_h <= -308.0,
		"top=" + str(cam_y - half_h))
	_check("tam nhin duoi thay day dat + xe dap (702)", cam_y + half_h >= 702.0,
		"bottom=" + str(cam_y + half_h))

	print("ARTPASS7: ", _pass, " pass, ", _fail, " fail")
	if _fail > 0:
		quit(1)
	else:
		quit(0)
