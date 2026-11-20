extends SceneTree
## G4 coord+WASD test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_coord_wasd_test.gd
## Kiem tra 2 loi phat hien 20/11 12:20 (art pass 2):
##  1. WASD khong di duoc (chi co ui_* = mui ten).
##  2. Map003+ lech toa do: TileMapLayer dung layout STACKED mac dinh
##     nen tile ve sai cho so voi marker/nguoi choi (offset+raw).

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
	# Chay _process tay cho toi khi buoc di xong (MOVE_TIME 0.15s).
	for i in range(30):
		p._process(0.02)
		if not p._moving:
			break

func _init() -> void:
	# --- 1. Action WASD ton tai, co ca phim chu + mui ten ---
	for a in ["move_up", "move_down", "move_left", "move_right"]:
		_check("co action " + a, InputMap.has_action(a))
	_check("move_up co W + Up", InputMap.action_get_events("move_up").size() == 2)
	_check("move_down co S + Down", InputMap.action_get_events("move_down").size() == 2)
	_check("move_left co A + Left", InputMap.action_get_events("move_left").size() == 2)
	_check("move_right co D + Right", InputMap.action_get_events("move_right").size() == 2)

	# --- 2. Nhan WASD di chuyen duoc; mui ten van di duoc ---
	var font: Font = load("res://DejaVuSans.ttf")
	var raw := FileAccess.get_file_as_string("res://data/maps.json")
	var data: Dictionary = JSON.parse_string(raw)
	var m1: Dictionary = {}
	var m3: Dictionary = {}
	for m in data["maps"]:
		if int(m["id"]) == 1:
			m1 = m
		if int(m["id"]) == 3:
			m3 = m
	var iso1 := IsoMap.new()
	root.add_child(iso1)
	iso1.build(m1, Marker, font, null)
	var p := Player.new()
	root.add_child(p)
	p.place(iso1, Vector2i(4, 5))
	_check("player spawn (4,5)", p.tile == Vector2i(4, 5))
	Input.action_press("move_up")
	_step_player(p)
	Input.action_release("move_up")
	_check("nhan W di len -> (4,4)", p.tile == Vector2i(4, 4), str(p.tile))
	Input.action_press("move_right")
	_step_player(p)
	Input.action_release("move_right")
	_check("nhan D di phai -> (5,4)", p.tile == Vector2i(5, 4), str(p.tile))
	Input.action_press("ui_left")
	_step_player(p)
	Input.action_release("ui_left")
	_check("mui ten trai van di duoc -> (4,4)", p.tile == Vector2i(4, 4), str(p.tile))
	# Giu phim di lien tuc: giu W 2 buoc.
	Input.action_press("move_up")
	_step_player(p)
	_step_player(p)
	Input.action_release("move_up")
	_check("giu W di lien tuc 2 o -> (4,2)", p.tile == Vector2i(4, 2), str(p.tile))

	# --- 3. Map003: lop tile khop he toa do marker/nguoi choi ---
	var iso3 := IsoMap.new()
	root.add_child(iso3)
	iso3.build(m3, Marker, font, null)
	_check("tile_layout DIAMOND_DOWN",
		iso3.ground_layer.tile_set.tile_layout == TileSet.TILE_LAYOUT_DIAMOND_DOWN)
	var bad := 0
	var bad_detail := ""
	for ty in range(9):
		for tx in range(12):
			var t := Vector2i(tx, ty)
			var want: Vector2 = iso3.tile_center(t)
			var g: Vector2 = iso3.ground_layer.position + iso3.ground_layer.map_to_local(t) + Vector2(32, 16)
			var o: Vector2 = iso3.object_layer.position + iso3.object_layer.map_to_local(t) + Vector2(32, 16)
			if (g - want).length() > 0.5 or (o - want).length() > 0.5:
				bad += 1
				if bad_detail == "":
					bad_detail = "tile " + str(t) + " want " + str(want) + " ground " + str(g)
			if iso3.world_to_tile(want) != t:
				bad += 1
				if bad_detail == "":
					bad_detail = "world_to_tile sai o " + str(t)
	_check("108 o Map003: tam tile lop ground/object trung tile_center", bad == 0, bad_detail)
	var mbad := 0
	for mk in iso3.markers:
		var et: Array = mk.event_data.get("tile", [])
		if et.size() == 2:
			var want: Vector2 = iso3.tile_center(Vector2i(int(et[0]), int(et[1])))
			if (mk.position - want).length() > 0.5:
				mbad += 1
	_check("marker Map003 dung tren tile cua minh", mbad == 0, str(mbad) + " lech")
	print("G4 COORD+WASD TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)
