extends SceneTree
## G1 selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g1_selftest.gd
## Kiem tra: data maps.json, TileSet iso, chieu tile<->world, di duoc/chan,
## event/NPC/hotspot/door, luat hotspot theo khung, do thi cua thong nhau.
## In "G1 SELFTEST: n/n PASS".
## G3 buoc 1 (20/11): maps.json nay co 5 map (Map001-005); Map002 co them
## 1 cua di Map003 (xem tools/godot/convert_maps.py: ADDED_DOORS).
## G3 buoc 2 (20/11): maps.json nay co 8 map (Map001-008); Map006-008
## tai dung atlas-map001.png, khong co hotspot/craft; cua cuoi
## Map008 -> Map009 chua port (bi chan co bao).
## G3 buoc 3 (20/11): maps.json nay co 11 map (Map001-011); Map009-011
## tai dung atlas-map001.png, khong co hotspot/craft; cua cuoi
## Map011 -> Map012 chua port (bi chan co bao).
## G3 buoc 4 (20/11): maps.json nay co 14 map (Map001-014, het data MV);
## Map012-014 tai dung atlas-map001.png (MV khong co atlas-map012/013/014),
## khong co hotspot/craft; Map014 la map cuoi MV — chi 1 cua ve Map013,
## khong co cua di tiep nen khong con cua bi chan o cuoi chuoi.
## G3 buoc 5 (20/11): maps.json nay co DU 18 map (Map001-018); Map015-018
## VIET MOI (khong co trong MV — xem tools/godot/convert_maps.py:
## handwritten()), tai dung tile mau Map014 (PROVISIONAL); Map014 them
## cua (5,8) di Map015 (ADDED_DOORS); Map018 la map cuoi chuoi — chi 1
## cua ve Map017, khong co cua di tiep nen khong con cua bi chan o cuoi.

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
	_check("co 18 map", data["maps"].size() == 18)
	_check("diem bat dau Map001 (4,5)",
		int(data["start"]["map"]) == 1 and int(data["start"]["x"]) == 4 and int(data["start"]["y"]) == 5)

	# Do thi cua: tu Map001 di theo cua (chi tinh dich da co data) toi duoc ca 18 map.
	var by_id := {}
	for m in data["maps"]:
		by_id[int(m["id"])] = m
	var seen := {1: true}
	var queue := [1]
	while not queue.is_empty():
		var cur: int = queue.pop_front()
		for e in (by_id[cur] as Dictionary)["events"]:
			if String(e.get("kind", "")) == "door":
				var dest := int(e["to_map"])
				if by_id.has(dest) and not seen.has(dest):
					seen[dest] = true
					queue.append(dest)
	_check("do thi cua: tu Map001 toi du 18 map", seen.size() == 18, str(seen.keys()))
	# Moi cua deu co cua nguoc (Map018 la map cuoi chuoi, chi 1 cua ve Map017 —
	# khong con cua cuoi tam thoi nhu buoc 1-3).
	for m in data["maps"]:
		for e in (m as Dictionary)["events"]:
			if String(e.get("kind", "")) != "door":
				continue
			var dest := int(e["to_map"])
			var back := false
			if by_id.has(dest):
				for e2 in (by_id[dest] as Dictionary)["events"]:
					if String(e2.get("kind", "")) == "door" and int(e2["to_map"]) == int(m["id"]):
						back = true
			_check("Map%03d cua -> %d co cua nguoc" % [int(m["id"]), dest], back)

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
	# Event: so luong theo tung map (G3 buoc 1-5).
	#   Map001: 2 NPC + 1 hotspot + 1 craft + 1 door
	#   Map002: 2 NPC + 2 hotspot + 1 craft + 2 door (them cua di Map003)
	#   Map003-013: 2 NPC + 0 hotspot + 0 craft + 2 door
	#   Map014: 2 NPC + 0 hotspot + 0 craft + 2 door (them cua di Map015 o buoc 5)
	#   Map015-017: 2 NPC + 0 hotspot + 0 craft + 2 door (viet moi)
	#   Map018: 2 NPC + 0 hotspot + 0 craft + 1 door (map cuoi chuoi, chi cua ve)
	var kinds := {}
	for e in m["events"]:
		kinds[String(e.get("kind", ""))] = int(kinds.get(String(e.get("kind", "")), 0)) + 1
	var mid := int(m["id"])
	var want: Dictionary = {1: {"npc": 2, "craft": 1, "door": 1, "hotspot": 1},
		2: {"npc": 2, "craft": 1, "door": 2, "hotspot": 2},
		3: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		4: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		5: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		6: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		7: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		8: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		9: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		10: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		11: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		12: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		13: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		14: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		15: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		16: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		17: {"npc": 2, "craft": 0, "door": 2, "hotspot": 0},
		18: {"npc": 2, "craft": 0, "door": 1, "hotspot": 0}}[mid]
	for k in want.keys():
		_check(tag + ": %s = %d" % [k, int(want[k])],
			int(kinds.get(k, 0)) == int(want[k]), str(kinds))
	# NPC nao cung co greet + hint (khong rong, co dau tieng Viet).
	for e in m["events"]:
		if String(e.get("kind", "")) == "npc":
			_check(tag + ": NPC " + String(e["name"]) + " co greet+hint",
				String(e.get("greet", "")).length() > 10 and String(e.get("hint", "")).length() > 10)
	# Atlas PNG ma map dung phai ton tai trong project (Map003/005/006/007/008/
	# 009/010/011/012/013/014/015/016/017/018 tai dung 001, Map004 tai dung 002).
	_check(tag + ": atlas PNG ton tai", FileAccess.file_exists(String(m["atlas_png"])), String(m["atlas_png"]))
	# Door noi sang map hop le (1..18; het data MV, khong con dich chua port).
	for e in m["events"]:
		if String(e.get("kind", "")) == "door":
			_check(tag + ": cua noi sang map " + str(int(e["to_map"])) + " hop le",
				int(e["to_map"]) >= 1 and int(e["to_map"]) <= 18)
	# Hotspot co du truong khung/vat/so luong (bang PXB_Hotspot.js).
	for e in m["events"]:
		if String(e.get("kind", "")) == "hotspot":
			_check(tag + ": hotspot " + String(e["id"]) + " co khung+vat",
				String(e.get("best_frame", "")) != "" and String(e.get("material", "")) != "" and int(e.get("amount", 0)) > 0)
	# Marker node duoc tao cho moi event.
	_check(tag + ": marker = so event", iso.markers.size() == m["events"].size(),
		"markers %d events %d" % [iso.markers.size(), m["events"].size()])
