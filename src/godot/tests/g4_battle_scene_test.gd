extends SceneTree
## G4 BATTLE SCENE selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_scene_test.gd
## Kiem tra: BattleScene (G4 §4) noi tren logic PxbMarketBattle —
## luoi 12x9 ve dung toa do iso, o di chuyen duoc, danh/ho tro qua
## click_tile, nut Ket thuc luot / Dong qua click_screen, dong ho
## luot 10s tu chuyen luot, dong ho tran 180s ket thuc bang % HP,
## ket qua tran + giu sap hien dung.
## In "G4 BATTLE SCENE SELFTEST: n/n PASS".

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
	_test_setup_and_grid()
	_test_reachable_and_move()
	_test_attack()
	_test_support()
	_test_end_turn_button()
	_test_turn_timeout()
	_test_match_timeout()
	_test_close_button()
	print("G4 BATTLE SCENE SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
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


func _set_active(scene: BattleScene, fighter_id: String) -> void:
	var order: Array = scene.battle.get("turnOrder", [])
	scene.battle["turnIndex"] = order.find(fighter_id)
	scene.battle["activeFighterId"] = fighter_id


func _test_setup_and_grid() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_check("setup: tran dang danh", scene.is_fighting())
	_check("setup: luot dau la ban-1 (A1)", str(scene.active_fighter().get("id", "")) == "ban-1")
	_check("setup: chua co ket qua", scene.result_text() == "")
	_check("setup: dong ho tran 180s", scene.match_seconds_left() == 180)
	_check("setup: dong ho luot 10s", absf(scene.turn_seconds_left() - 10.0) < 0.01)
	# Toa do iso di ve dung o: tam o (5,4) doi nguoc ra dung (5,4).
	var c := scene.tile_center(Vector2i(5, 4))
	_check("luoi: screen_to_tile nguoc dung", scene.screen_to_tile(c) == Vector2i(5, 4))
	_check("luoi: goc (0,0) doi nguoc dung", scene.screen_to_tile(scene.tile_center(Vector2i(0, 0))) == Vector2i(0, 0))
	_check("luoi: goc (11,8) doi nguoc dung", scene.screen_to_tile(scene.tile_center(Vector2i(11, 8))) == Vector2i(11, 8))


func _test_reachable_and_move() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# ban-1 (Do, tam 3) o (0,3); doi hinh A: (0,3),(1,4),(0,5).
	var reach := scene.reachable_tiles()
	_check("di chuyen: 13 o trong tam 3", reach.size() == 13, "got %d" % reach.size())
	_check("di chuyen: co (1,3)", reach.has(Vector2i(1, 3)))
	_check("di chuyen: co (0,6)", reach.has(Vector2i(0, 6)))
	_check("di chuyen: khong co (4,3) ngoai tam", not reach.has(Vector2i(4, 3)))
	_check("di chuyen: khong co (1,4) co dong doi", not reach.has(Vector2i(1, 4)))
	_check("di chuyen: chua di duoc danh", scene.attackable_targets().is_empty())
	_check("click: di toi (1,3)", scene.click_tile(Vector2i(1, 3)) == "moved")
	_check("di chuyen: ban-1 da sang (1,3)", Vector2i(int(scene.active_fighter()["x"]), int(scene.active_fighter()["y"])) == Vector2i(1, 3))
	_check("di chuyen: di roi thi het o", scene.reachable_tiles().is_empty())
	_check("click: di tiep cung luot bi chan", scene.click_tile(Vector2i(2, 3)) == "none")
	_check("click: o ngoai luoi la none", scene.click_tile(Vector2i(11, 8)) == "none")


func _test_attack() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# Dat A1 ke B1: A1 (5,4), B1 (6,4), luot A1.
	var a1: Dictionary = mb.find_fighter(scene.battle, "ban-1")
	var b1: Dictionary = mb.find_fighter(scene.battle, "doi-cho-npc-1")
	a1["x"] = 5
	a1["y"] = 4
	b1["x"] = 6
	b1["y"] = 4
	_set_active(scene, "ban-1")
	_check("danh: co 1 muc tieu trong tam chao", scene.attackable_targets().size() == 1)
	_check("click: cham dich ke ben thi danh", scene.click_tile(Vector2i(6, 4)) == "attacked")
	# B1 la Tank (Do, HP 150, giam thuong x0.8): chao 12 -> 9 sat thuong.
	_check("danh: B1 mat 9 HP (tank giam thuong)", int(b1["hp"]) == 141, "hp=%d" % int(b1["hp"]))
	_check("danh: danh roi thi het muc tieu", scene.attackable_targets().is_empty())
	# Dich ngoai tam: dat B2 xa, cham vao chi xem (selected), khong danh.
	var b2: Dictionary = mb.find_fighter(scene.battle, "doi-cho-npc-2")
	b2["x"] = 11
	b2["y"] = 8
	_check("click: dich ngoai tam chi xem", scene.click_tile(Vector2i(11, 8)) == "selected")
	_check("click: dich ngoai tam khong mat HP", int(b2["hp"]) == int(b2["maxHp"]))


func _test_support() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# Vang (ban-3) lam A1: dat (5,4), dong doi ban-1 o (5,5) mat 50 HP.
	var team_a: Dictionary = {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("vang-1", "Cô Tư", "Vang", "Loa", {"the": 40, "tri": 50, "tam": 80}, []),
		PxbMarketBattle.create_fighter("tank-1", "Bạn", "Do", "Chao", {"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("xanh-1", "Bạn Thân", "Xanh", "CaKho", {"the": 40, "tri": 80, "tam": 50}, []),
	]}
	var res: Dictionary = mb.create_battle({
		"teamA": team_a,
		"teamB": PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3),
	})
	var scene2 := BattleScene.new()
	scene2.setup(mb, res["battle"], load("res://DejaVuSans.ttf"), load("res://DejaVuSans-Bold.ttf"))
	_scenes.append(scene2)
	var vang: Dictionary = mb.find_fighter(scene2.battle, "vang-1")
	var tank: Dictionary = mb.find_fighter(scene2.battle, "tank-1")
	vang["x"] = 5
	vang["y"] = 4
	tank["x"] = 5
	tank["y"] = 5
	tank["hp"] = 50
	_set_active(scene2, "vang-1")
	_check("ho tro: co 1 dong doi ke ben", scene2.supportable_allies().size() == 1)
	_check("click: cham dong doi ke ben thi ho tro", scene2.click_tile(Vector2i(5, 5)) == "supported")
	_check("ho tro: +12 HP dung luat", int(tank["hp"]) == 62, "hp=%d" % int(tank["hp"]))
	_check("ho tro: ho tro roi thi het dong doi ho tro duoc", scene2.supportable_allies().is_empty())


func _test_end_turn_button() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# Nut "Ket thuc luot": tam rect (16,1120,330,70).
	_check("nut: bam Ket thuc luot", scene.click_screen(Vector2(181, 1155)) == "ended")
	_check("nut: luot chuyen sang B1", str(scene.active_fighter().get("id", "")) == "doi-cho-npc-1")
	_check("nut: dong ho luot reset 10s", absf(scene.turn_seconds_left() - 10.0) < 0.01)


func _test_turn_timeout() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.simulate_seconds(4.0)
	_check("dong ho: sau 4s con 6s luot", absf(scene.turn_seconds_left() - 6.0) < 0.01, "left=%.2f" % scene.turn_seconds_left())
	_check("dong ho: sau 4s tran con 176s", scene.match_seconds_left() == 176)
	# Them 7s nua (tong 11s): het luot 10s -> tu chuyen sang B1.
	scene.simulate_seconds(7.0)
	_check("dong ho: het 10s tu chuyen luot", str(scene.active_fighter().get("id", "")) == "doi-cho-npc-1")
	_check("dong ho: tran van dang danh", scene.is_fighting())


func _test_match_timeout() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.simulate_seconds(180.0)
	_check("dong ho: het 180s tran ket thuc", not scene.is_fighting())
	_check("dong ho: 2 doi 100% HP thi hoa", str(scene.battle.get("winner", "")) == "hoa")
	_check("dong ho: ket qua co chu Hoa", "Hòa" in scene.result_text())
	_check("dong ho: hoa thi khong giu sap", (scene.battle.get("hold", {}) as Dictionary).is_empty())
	_check("dong ho: het tran thi click la none", scene.click_tile(Vector2i(5, 4)) == "none")


func _test_close_button() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# Nut "Dong (B)": tam rect (374,1120,330,70).
	_check("nut: bam Dong (B)", scene.click_screen(Vector2(539, 1155)) == "close")
	_check("nut: bam ngoai panel duoi la none", scene.click_screen(Vector2(360, 1250)) == "none")
