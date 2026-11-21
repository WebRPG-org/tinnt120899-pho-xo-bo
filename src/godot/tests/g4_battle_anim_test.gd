extends SceneTree
## G4 BATTLE ANIM selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_anim_test.gd
## Kiem tra: animation tran MarketBattle (G4 buoc 10) — chi lop ve,
## KHONG sua luat PxbMarketBattle. Di chuyen: vi tri ve truot ve o
## logic (khong nhay tuc thi); danh: nguoi danh lao toi + muc tieu
## chop sang, fx het sau 0.45s; ho tro: vong xanh + "+N HP", fx het
## sau 0.6s; luot AI cung co fx (suy tu chenh lech HP); HP/sat thuong
## dung luat khong doi.
## In "G4 BATTLE ANIM SELFTEST: n/n PASS".

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
	_test_move_slides()
	_test_attack_fx()
	_test_support_fx()
	_test_ai_fx()
	print("G4 BATTLE ANIM SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
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


func _test_move_slides() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	# ban-1 o (0,3): vi tri ve ban dau trung tam o logic.
	var old_c := scene.tile_center(Vector2i(0, 3)) + Vector2(0, -4)
	var new_c := scene.tile_center(Vector2i(1, 3)) + Vector2(0, -4)
	_check("truot: vi tri ve ban dau trung o logic", scene.visual_pos_of("ban-1").distance_to(old_c) < 1.0)
	_check("truot: click di toi (1,3)", scene.click_tile(Vector2i(1, 3)) == "moved")
	_check("truot: o logic doi ngay", Vector2i(int(scene.active_fighter()["x"]), int(scene.active_fighter()["y"])) == Vector2i(1, 3))
	# Vi tri ve CHUA nhay theo ngay — van o o cu.
	_check("truot: vi tri ve van o o cu ngay sau click", scene.visual_pos_of("ban-1").distance_to(old_c) < 1.0,
		"pos=%s" % str(scene.visual_pos_of("ban-1")))
	# Sau 0.1s (truot 42px tren quang duong ~35.8px): dang giua duong,
	# gan o moi hon o cu nhung chua toi han.
	scene.simulate_seconds(0.1)
	var mid := scene.visual_pos_of("ban-1")
	_check("truot: sau 0.1s da roi o cu", mid.distance_to(old_c) > 5.0, "d=%.1f" % mid.distance_to(old_c))
	# Sau them 0.5s: ve dung o moi.
	scene.simulate_seconds(0.5)
	_check("truot: sau 0.6s ve dung o moi", scene.visual_pos_of("ban-1").distance_to(new_c) < 2.0,
		"d=%.1f" % scene.visual_pos_of("ban-1").distance_to(new_c))


func _test_attack_fx() -> void:
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
	scene.snap_visual_pos()
	_check("danh-fx: truoc khi danh khong co fx", scene.attack_fx().is_empty())
	_check("danh-fx: click cham dich thi danh", scene.click_tile(Vector2i(6, 4)) == "attacked")
	# B1 Tank HP 150: chao 12 -> 9 sat thuong (luat khong doi).
	_check("danh-fx: sat thuong van 9 dung luat", int(b1["hp"]) == 141, "hp=%d" % int(b1["hp"]))
	var fx := scene.attack_fx()
	_check("danh-fx: fx co dung nguoi danh/muc tieu",
		str(fx.get("attacker_id", "")) == "ban-1" and str(fx.get("target_id", "")) == "doi-cho-npc-1")
	_check("danh-fx: fx ghi dung 9 sat thuong", int(fx.get("damage", -1)) == 9)
	# Giua animation (t=0.2, gan dinh lao toi): vi tri ve cua nguoi
	# danh lech khoi vi tri truot > 8px ve phia muc tieu.
	scene.simulate_seconds(0.2)
	var lunge := scene.fighter_draw_pos(a1).distance_to(scene.visual_pos_of("ban-1"))
	_check("danh-fx: nguoi danh lao toi giua animation", lunge > 8.0, "lunge=%.1f" % lunge)
	# Muc tieu rung nhe: vi tri ve lech khoi vi tri truot.
	var shake := scene.fighter_draw_pos(b1).distance_to(scene.visual_pos_of("doi-cho-npc-1"))
	_check("danh-fx: muc tieu rung khi bi danh", shake > 0.1, "shake=%.2f" % shake)
	# Sau 0.45s: fx het, vi tri ve ve dung cho.
	scene.simulate_seconds(0.5)
	_check("danh-fx: het sau 0.45s", scene.attack_fx().is_empty())
	_check("danh-fx: HP muc tieu van 141 sau animation", int(b1["hp"]) == 141)


func _test_support_fx() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
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
	scene2.snap_visual_pos()
	_check("ho-tro-fx: truoc khi ho tro khong co fx", scene2.support_fx().is_empty())
	_check("ho-tro-fx: click dong doi thi ho tro", scene2.click_tile(Vector2i(5, 5)) == "supported")
	_check("ho-tro-fx: +12 HP dung luat", int(tank["hp"]) == 62, "hp=%d" % int(tank["hp"]))
	var fx := scene2.support_fx()
	_check("ho-tro-fx: fx dung muc tieu + 12 HP",
		str(fx.get("target_id", "")) == "tank-1" and int(fx.get("healed", -1)) == 12)
	scene2.simulate_seconds(0.7)
	_check("ho-tro-fx: het sau 0.6s", scene2.support_fx().is_empty())
	_check("ho-tro-fx: HP van 62 sau animation", int(tank["hp"]) == 62)


func _test_ai_fx() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.ai_enabled = true
	scene.ai_team = "B"
	# B1 (Tank, Chao tam 1) ke A1: B1 (2,4), A1 (1,4) — AI se danh.
	# (Doi ban-2/ban-3 ra xa khoi (1,4) de AI chi co 1 muc tieu.)
	var b1: Dictionary = mb.find_fighter(scene.battle, "doi-cho-npc-1")
	var a1: Dictionary = mb.find_fighter(scene.battle, "ban-1")
	var a2: Dictionary = mb.find_fighter(scene.battle, "ban-2")
	var a3: Dictionary = mb.find_fighter(scene.battle, "ban-3")
	b1["x"] = 2
	b1["y"] = 4
	a1["x"] = 1
	a1["y"] = 4
	a2["x"] = 0
	a2["y"] = 7
	a3["x"] = 0
	a3["y"] = 8
	_set_active(scene, "doi-cho-npc-1")
	scene.snap_visual_pos()
	var hp_before := int(a1["hp"])
	var saw_fx := false
	# Buoc nho 0.1s de bat duoc fx danh cua AI (chi ton tai 0.45s).
	for i in range(30):
		scene.simulate_seconds(0.1)
		if not scene.attack_fx().is_empty():
			saw_fx = true
		if not scene.is_fighting():
			break
	_check("ai-fx: luot AI danh trung A1 (HP giam)", int(a1["hp"]) < hp_before,
		"hp %d -> %d" % [hp_before, int(a1["hp"])])
	_check("ai-fx: thay fx danh cua AI trong luc chay", saw_fx)
	_check("ai-fx: sau luot AI, luot chuyen khoi B1",
		str(scene.active_fighter().get("id", "")) != "doi-cho-npc-1")
