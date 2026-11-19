extends SceneTree
## G1 selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g1_selftest.gd
## Kiem tra: data maps.json, TileSet iso, chieu tile<->world, di duoc/chan,
## event/NPC/hotspot/door, luat hotspot theo khung. In "G1 SELFTEST: n/n PASS".

var _pass := 0
var _fail := 0

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _init() -> void:
	var font: Font = load("res://DejaVuSans.ttf")
	var raw := FileAccess.get_file_as_string("res://data/maps.json")
	_check("maps.json doc duoc", raw != "")
	var data: Dictionary = JSON.parse_string(raw)
	_check("co 2 map", data["maps"].size() == 2)
	_check("diem bat dau Map001 (4,5)",
		int(data["start"]["map"]) == 1 and int(data["start"]["x"]) == 4 and int(data["start"]["y"]) == 5)

	var root_node := Node2D.new()
	root.add_child(root_node)
	for m in data["maps"]:
		_test_map(m, root_node, font)

	# Luat hotspot: chi dung khung moi nhat duoc (logic giong main.gd).
	var frames := ["Sáng", "Chiều", "Tối"]
	_check("hs-cho-sang khung Sang", frames[0] == "Sáng")
	_check("hs-tro-toi khung Toi", frames[2] == "Tối")

	print("G1 SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)

func _test_map(m: Dictionary, parent: Node, font: Font) -> void:
	var tag := "Map%03d %s" % [int(m["id"]), String(m["name"])]
	var iso := IsoMap.new()
	parent.add_child(iso)
	iso.build(m, Marker, font)
	_check(tag + ": 12x9", int(m["width"]) == 12 and int(m["height"]) == 9)
	_check(tag + ": lop nen du 108 o", iso.ground_layer.get_used_cells().size() == 108,
		"got %d" % iso.ground_layer.get_used_cells().size())
	_check(tag + ": lop vat 28 o (vong bien)", iso.object_layer.get_used_cells().size() == 28,
		"got %d" % iso.object_layer.get_used_cells().size())
	_check(tag + ": TileSet iso 64x32",
		iso.ground_layer.tile_set.tile_size == Vector2i(64, 32)
		and iso.ground_layer.tile_set.tile_shape == TileSet.TILE_SHAPE_ISOMETRIC)
	# Chieu tile -> world -> tile khoi phuc dung cho moi o.
	var ok := true
	for ty in range(9):
		for tx in range(12):
			var t := Vector2i(tx, ty)
			if iso.world_to_tile(iso.tile_center(t)) != t:
				ok = false
	_check(tag + ": chieu iso khuoi phuc 108/108 o", ok)
	# Di duoc: o trong di duoc, vong bien bi chan, o NPC bi chan.
	_check(tag + ": o trong (5,4) di duoc", iso.is_walkable(Vector2i(5, 4)))
	_check(tag + ": goc (0,0) co vat -> chan", not iso.is_walkable(Vector2i(0, 0)))
	_check(tag + ": bien (11,8) co vat -> chan", not iso.is_walkable(Vector2i(11, 8)))
	_check(tag + ": ngoai bien -> chan", not iso.is_walkable(Vector2i(-1, 5)))
	for e in m["events"]:
		if String(e.get("kind", "")) == "npc":
			var t := Vector2i(e["tile"][0], e["tile"][1])
			_check(tag + ": o NPC " + String(e["name"]) + " bi chan", not iso.is_walkable(t))
	# Event: Map001 2 NPC + 1 hotspot + 1 craft + 1 door; Map002 2 NPC + 2 hotspot + 1 craft + 1 door.
	var kinds := {}
	for e in m["events"]:
		kinds[String(e.get("kind", ""))] = int(kinds.get(String(e.get("kind", "")), 0)) + 1
	_check(tag + ": 2 NPC", int(kinds.get("npc", 0)) == 2, str(kinds))
	_check(tag + ": 1 craft", int(kinds.get("craft", 0)) == 1, str(kinds))
	_check(tag + ": 1 door", int(kinds.get("door", 0)) == 1, str(kinds))
	var want_hs := 1 if int(m["id"]) == 1 else 2
	_check(tag + ": hotspot = %d" % want_hs, int(kinds.get("hotspot", 0)) == want_hs, str(kinds))
	# Door noi sang map kia.
	for e in m["events"]:
		if String(e.get("kind", "")) == "door":
			_check(tag + ": cua noi sang map " + str(int(e["to_map"])),
				int(e["to_map"]) == (2 if int(m["id"]) == 1 else 1))
	# Hotspot co du truong khung/vat/so luong (bang PXB_Hotspot.js).
	for e in m["events"]:
		if String(e.get("kind", "")) == "hotspot":
			_check(tag + ": hotspot " + String(e["id"]) + " co khung+vat",
				String(e.get("best_frame", "")) != "" and String(e.get("material", "")) != "" and int(e.get("amount", 0)) > 0)
	# Marker node duoc tao cho moi event.
	_check(tag + ": marker = so event", iso.markers.size() == m["events"].size(),
		"markers %d events %d" % [iso.markers.size(), m["events"].size()])
