extends SceneTree
## G4 BATTLE NAMES selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_names_test.gd
## Kiem tra: BattleScene.fighter_name_rects() (G4 buoc 9) — nhan ten
## dau si khong chong nhau khi dung ke nhau, giu gan diem neo, khep
## tren panel hanh dong. Loi goc: ten rong 120px, 2 dau si ke nhau
## (cach 32px ngang) de nhau du da lech theo chan/le x — thay tren
## anh browser-verify 13 ("Co Tu"/"Ban Than").
## In "G4 BATTLE NAMES SELFTEST: n/n PASS".

var _pass := 0
var _fail := 0
var _scenes: Array = []
var _mbs: Array = []


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _init() -> void:
	_test_spawn_no_overlap()
	_test_adjacent_pair()
	_test_cluster_six()
	_test_long_names()
	_test_near_anchor_and_bounds()
	print("G4 BATTLE NAMES SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	for s in _scenes:
		s.free()
	for m in _mbs:
		m.free()
	quit(0 if _fail == 0 else 1)


func _new_mb() -> PxbMarketBattle:
	var mb := PxbMarketBattle.new()
	_mbs.append(mb)
	return mb


func _mk_team_a() -> Dictionary:
	return {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("ban-1", "Bạn", "Do", "Chao", {"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-2", "Bạn Thân", "Xanh", "CaKho", {"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-3", "Cô Tư", "Vang", "Loa", {"the": 40, "tri": 50, "tam": 80}, []),
	]}


func _new_scene(mb: PxbMarketBattle) -> BattleScene:
	var res: Dictionary = mb.create_battle({
		"teamA": _mk_team_a(),
		"teamB": PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3),
		"stallId": "sap-cho-dau-moi", "gameDay": 1, "defenderTeam": "B",
	})
	var scene := BattleScene.new()
	scene.setup(mb, res["battle"], load("res://DejaVuSans.ttf"), load("res://DejaVuSans-Bold.ttf"))
	_scenes.append(scene)
	return scene


func _rects(scene: BattleScene) -> Array:
	return scene.fighter_name_rects()


func _no_overlap(rects: Array) -> bool:
	for i in range(rects.size()):
		var a: Rect2 = rects[i]["rect"]
		for j in range(i + 1, rects.size()):
			var b: Rect2 = rects[j]["rect"]
			if a.grow(2.0).intersects(b):
				return false
	return true


func _rect_of(rects: Array, fighter_id: String) -> Rect2:
	for nr in rects:
		if str(nr["id"]) == fighter_id:
			return nr["rect"]
	return Rect2()


func _test_spawn_no_overlap() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	var rects := _rects(scene)
	_check("ten: du 6 nhan luc spawn", rects.size() == 6, "got %d" % rects.size())
	_check("ten: luc spawn khong chong nhau", _no_overlap(rects))
	# Ten ngan ("Bạn") lay dung do rong chu, khong phai luc nao cung 120.
	var r_ban1 := _rect_of(rects, "ban-1")
	_check("ten: 'Bạn' hep hon 120px", r_ban1.size.x < 120.0, "w=%.1f" % r_ban1.size.x)
	_check("ten: 'Bạn' van du rong hien chu", r_ban1.size.x > 30.0, "w=%.1f" % r_ban1.size.x)


func _test_adjacent_pair() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# Dung cap gay loi tren anh that: A1 (5,4) + A2 (6,4) — ten cu
	# (leech chan/le x) chong nhau vi cach nhau chi 32px ngang.
	var a1: Dictionary = mb.find_fighter(scene.battle, "ban-1")
	var a2: Dictionary = mb.find_fighter(scene.battle, "ban-2")
	a1["x"] = 5
	a1["y"] = 4
	a2["x"] = 6
	a2["y"] = 4
	var rects := _rects(scene)
	_check("ten: cap ke (5,4)-(6,4) khong chong nhau", _no_overlap(rects))
	var r1 := _rect_of(rects, "ban-1")
	var r2 := _rect_of(rects, "ban-2")
	_check("ten: cap ke tach doc >= 4px", absf(r1.position.y - r2.position.y) >= 4.0 or not r1.grow(2.0).intersects(r2),
		"y1=%.1f y2=%.1f" % [r1.position.y, r2.position.y])


func _test_cluster_six() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# Cum 6 dau si tren 6 o lien ke — truong hop xau nhat.
	var spots: Array[Vector2i] = [Vector2i(5, 4), Vector2i(6, 4), Vector2i(5, 5),
		Vector2i(6, 5), Vector2i(5, 6), Vector2i(6, 6)]
	var ids: Array[String] = ["ban-1", "ban-2", "ban-3",
		"doi-cho-npc-1", "doi-cho-npc-2", "doi-cho-npc-3"]
	for k in range(6):
		var f: Dictionary = mb.find_fighter(scene.battle, ids[k])
		f["x"] = spots[k].x
		f["y"] = spots[k].y
	var rects := _rects(scene)
	_check("ten: cum 6 o ke khong chong nhau", _no_overlap(rects))
	var all_above := true
	for nr in rects:
		if (nr["rect"] as Rect2).end.y > BattleScene.FIGHTER_NAME_MAX_Y:
			all_above = false
	_check("ten: cum 6 van tren panel hanh dong", all_above)


func _test_long_names() -> void:
	var mb := _new_mb()
	var team_a: Dictionary = {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("a-1", "Tiểu thương 3", "Do", "Chao", {"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("a-2", "Tiểu thương 12", "Xanh", "CaKho", {"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("a-3", "Bạn Thân Chiến", "Vang", "Loa", {"the": 40, "tri": 50, "tam": 80}, []),
	]}
	var res: Dictionary = mb.create_battle({
		"teamA": team_a,
		"teamB": PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3),
	})
	var scene := BattleScene.new()
	scene.setup(mb, res["battle"], load("res://DejaVuSans.ttf"), load("res://DejaVuSans-Bold.ttf"))
	_scenes.append(scene)
	var f1: Dictionary = mb.find_fighter(scene.battle, "a-1")
	var f2: Dictionary = mb.find_fighter(scene.battle, "a-2")
	f1["x"] = 5
	f1["y"] = 4
	f2["x"] = 6
	f2["y"] = 4
	var rects := _rects(scene)
	_check("ten: ten dai ke nhau khong chong", _no_overlap(rects))
	var capped := true
	for nr in rects:
		if (nr["rect"] as Rect2).size.x > 120.0:
			capped = false
	_check("ten: rong ten cap o 120px", capped)


func _test_near_anchor_and_bounds() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	var rects := _rects(scene)
	var near := true
	var inside := true
	for nr in rects:
		var r: Rect2 = nr["rect"]
		var f: Dictionary = mb.find_fighter(scene.battle, str(nr["id"]))
		var c := scene.tile_center(Vector2i(int(f["x"]), int(f["y"])))
		# Tam nhan cach tam dau si <= 110px (day xuong toi da ~3 nac).
		if r.get_center().distance_to(c) > 110.0:
			near = false
		if r.position.x < 0.0 or r.end.x > 720.0 or r.end.y > BattleScene.FIGHTER_NAME_MAX_Y:
			inside = false
	_check("ten: nhan giu gan dau si (<=110px)", near)
	_check("ten: nhan trong man hinh + tren panel", inside)
