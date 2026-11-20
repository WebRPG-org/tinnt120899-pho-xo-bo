extends SceneTree
## G4 BATTLE AI selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_ai_test.gd
## Kiem tra: AI luot dich (G4 buoc 2) — PxbMarketBattle.ai_take_turn
## (danh dich trong tam uu tien it HP nhat, Vang ho tro dong doi
## ke ben thieu HP nhat, di lai gan dich nhat roi danh, ket thuc
## luot; khong di khi khong phai luot / tran da xong) + BattleScene
## chay AI that khi ai_enabled (cho 1,2s roi di, tran tu chay het
## 180s). AI xac dinh, khong ngau nhien; khong sua luat.
## In "G4 BATTLE AI TEST: n/n PASS".

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
	_test_ai_attack_in_range()
	_test_ai_move_then_attack()
	_test_ai_support()
	_test_ai_lowest_hp_target()
	_test_ai_wrong_turn()
	_test_ai_finished_battle()
	_test_scene_ai_disabled_by_default()
	_test_scene_ai_acts_after_delay()
	_test_scene_ai_auto_battle()
	print("G4 BATTLE AI TEST: %d/%d PASS" % [_pass, _pass + _fail])
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


func _new_battle(mb: PxbMarketBattle) -> Dictionary:
	var res: Dictionary = mb.create_battle({
		"teamA": _mk_team_a(),
		"teamB": PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3),
		"stallId": "sap-cho-dau-moi", "gameDay": 1, "defenderTeam": "B",
	})
	return res["battle"]


func _new_scene(mb: PxbMarketBattle, battle: Dictionary) -> BattleScene:
	var scene := BattleScene.new()
	scene.setup(mb, battle, load("res://DejaVuSans.ttf"), load("res://DejaVuSans-Bold.ttf"))
	_scenes.append(scene)
	return scene


func _set_active(battle: Dictionary, fighter_id: String) -> void:
	var order: Array = battle.get("turnOrder", [])
	battle["turnIndex"] = order.find(fighter_id)
	battle["activeFighterId"] = fighter_id


func _test_ai_attack_in_range() -> void:
	var mb := _new_mb()
	var battle := _new_battle(mb)
	# B1 (Do, Chao tam 1) ke A1: B1 (6,4), A1 (5,4), luot B1.
	var a1: Dictionary = mb.find_fighter(battle, "ban-1")
	var b1: Dictionary = mb.find_fighter(battle, "doi-cho-npc-1")
	a1["x"] = 5
	a1["y"] = 4
	b1["x"] = 6
	b1["y"] = 4
	_set_active(battle, "doi-cho-npc-1")
	var res: Dictionary = mb.ai_take_turn(battle, "doi-cho-npc-1")
	_check("ai danh: ok", bool(res.get("ok", false)))
	_check("ai danh: co hanh dong danh", (res.get("actions", []) as Array).size() >= 1 and "đánh" in str((res.get("actions", []) as Array)[0]))
	# Chao 12, A1 Tank Do giam thuong x0.8 -> 9 sat thuong (150 -> 141).
	_check("ai danh: A1 mat 9 HP", int(a1["hp"]) == 141, "hp=%d" % int(a1["hp"]))
	_check("ai danh: ket thuc luot", bool(res.get("ended", false)))
	_check("ai danh: luot sang A2", str(battle.get("activeFighterId", "")) == "ban-2")


func _test_ai_move_then_attack() -> void:
	var mb := _new_mb()
	var battle := _new_battle(mb)
	# B2 (Xanh, CaKho tam 2, di 4) xa dich: (10,4); A gan nhat (1,4).
	var b2: Dictionary = mb.find_fighter(battle, "doi-cho-npc-2")
	_set_active(battle, "doi-cho-npc-2")
	var before := PxbMarketBattle.manhattan(10, 4, 1, 4)
	var res: Dictionary = mb.ai_take_turn(battle, "doi-cho-npc-2")
	_check("ai di: ok", bool(res.get("ok", false)))
	_check("ai di: B2 da roi vi tri cu", not (int(b2["x"]) == 10 and int(b2["y"]) == 4))
	_check("ai di: B2 tien toi (6,4)", int(b2["x"]) == 6 and int(b2["y"]) == 4, "(%d,%d)" % [int(b2["x"]), int(b2["y"])])
	var after := PxbMarketBattle.manhattan(int(b2["x"]), int(b2["y"]), 1, 4)
	_check("ai di: gan dich hon truoc", after < before, "%d -> %d" % [before, after])
	_check("ai di: chua danh (dich ngoai tam 2)", (res.get("actions", []) as Array).size() == 1 and "di chuyển" in str((res.get("actions", []) as Array)[0]))
	_check("ai di: ket thuc luot sang A3", str(battle.get("activeFighterId", "")) == "ban-3")


func _test_ai_support() -> void:
	var mb := _new_mb()
	var battle := _new_battle(mb)
	# B3 (Vang, GheNhua) lam luot: dat (5,4), B1 ke ben (5,5) mat 100 HP.
	var b1: Dictionary = mb.find_fighter(battle, "doi-cho-npc-1")
	var b3: Dictionary = mb.find_fighter(battle, "doi-cho-npc-3")
	b3["x"] = 5
	b3["y"] = 4
	b1["x"] = 5
	b1["y"] = 5
	b1["hp"] = 50
	_set_active(battle, "doi-cho-npc-3")
	var res: Dictionary = mb.ai_take_turn(battle, "doi-cho-npc-3")
	_check("ai ho tro: ok", bool(res.get("ok", false)))
	_check("ai ho tro: B1 +12 HP", int(b1["hp"]) == 62, "hp=%d" % int(b1["hp"]))
	_check("ai ho tro: het luot ve A1 vong 2", str(battle.get("activeFighterId", "")) == "ban-1" and int(battle.get("round", 1)) == 2)


func _test_ai_lowest_hp_target() -> void:
	var mb := _new_mb()
	var battle := _new_battle(mb)
	# B2 (CaKho tam 2) o (5,5); A1 hp 30 o (5,4), A2 hp 80 o (6,5).
	var a1: Dictionary = mb.find_fighter(battle, "ban-1")
	var a2: Dictionary = mb.find_fighter(battle, "ban-2")
	var b2: Dictionary = mb.find_fighter(battle, "doi-cho-npc-2")
	a1["x"] = 5
	a1["y"] = 4
	a1["hp"] = 30
	a2["x"] = 6
	a2["y"] = 5
	a2["hp"] = 80
	b2["x"] = 5
	b2["y"] = 5
	_set_active(battle, "doi-cho-npc-2")
	var res: Dictionary = mb.ai_take_turn(battle, "doi-cho-npc-2")
	_check("ai chon muc tieu: ok", bool(res.get("ok", false)))
	# CaKho 8, A1 Tank Do x0.8 -> 6 sat thuong (30 -> 24); A2 nguyen.
	_check("ai chon muc tieu: danh A1 it HP nhat", int(a1["hp"]) == 24, "hp=%d" % int(a1["hp"]))
	_check("ai chon muc tieu: A2 khong mat HP", int(a2["hp"]) == 80)


func _test_ai_wrong_turn() -> void:
	var mb := _new_mb()
	var battle := _new_battle(mb)
	# Luot dang la A1 (ban-1); goi AI cho B1 phai bi chan.
	var res: Dictionary = mb.ai_take_turn(battle, "doi-cho-npc-1")
	_check("ai sai luot: ok=false", not bool(res.get("ok", false)))
	_check("ai sai luot: reason khong-phai-luot", str(res.get("reason", "")) == "khong-phai-luot")
	_check("ai sai luot: luot van la A1", str(battle.get("activeFighterId", "")) == "ban-1")


func _test_ai_finished_battle() -> void:
	var mb := _new_mb()
	var battle := _new_battle(mb)
	battle["status"] = PxbMarketBattle.STATUS_FINISHED
	var res: Dictionary = mb.ai_take_turn(battle, "doi-cho-npc-1")
	_check("ai tran xong: ok=false", not bool(res.get("ok", false)))
	_check("ai tran xong: reason tran-xong", str(res.get("reason", "")) == "tran-xong")


func _test_scene_ai_disabled_by_default() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb, _new_battle(mb))
	_check("scene ai: mac dinh tat", not scene.ai_enabled)
	# Mo phong 11s: luot A1 het 10s -> B1, nhung AI tat nen B1 dung yen.
	scene.simulate_seconds(11.0)
	var b1: Dictionary = mb.find_fighter(scene.battle, "doi-cho-npc-1")
	_check("scene ai: tat thi B1 dung yen o (11,3)", int(b1["x"]) == 11 and int(b1["y"]) == 3, "(%d,%d)" % [int(b1["x"]), int(b1["y"])])
	_check("scene ai: tat thi luot van la B1", str(scene.active_fighter().get("id", "")) == "doi-cho-npc-1")


func _test_scene_ai_acts_after_delay() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb, _new_battle(mb))
	scene.ai_enabled = true
	# 10,5s: luot A1 het 10s -> B1, moi 0,5s luot dich (< 1,2s delay).
	scene.simulate_seconds(10.5)
	var b1: Dictionary = mb.find_fighter(scene.battle, "doi-cho-npc-1")
	_check("scene ai: chua het delay thi B1 chua di", int(b1["x"]) == 11 and int(b1["y"]) == 3, "(%d,%d)" % [int(b1["x"]), int(b1["y"])])
	_check("scene ai: chua het delay thi luot van B1", str(scene.active_fighter().get("id", "")) == "doi-cho-npc-1")
	# Them 1s (tong 11,5s): qua delay 1,2s -> AI di + ket thuc luot.
	scene.simulate_seconds(1.0)
	_check("scene ai: qua delay thi B1 da di toi (8,3)", int(b1["x"]) == 8 and int(b1["y"]) == 3, "(%d,%d)" % [int(b1["x"]), int(b1["y"])])
	_check("scene ai: qua delay thi luot sang A2", str(scene.active_fighter().get("id", "")) == "ban-2")


func _test_scene_ai_auto_battle() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb, _new_battle(mb))
	scene.ai_enabled = true
	# Tran tu chay: doi A dung yen, doi B do AI danh.
	# Sau 60s (giua tran, chua het): doi A phai mat HP — het tran
	# HP hoi day lai (luat: het tran hoi day) nen khong do sau 180s.
	scene.simulate_seconds(60.0)
	_check("scene ai: giua tran van dang danh", scene.is_fighting())
	var a_hp := 0
	for f in (scene.battle["teamA"]["fighters"] as Array):
		a_hp += int((f as Dictionary).get("hp", 0))
	_check("scene ai: doi A co mat HP (da bi danh)", a_hp < 350, "hp=%d" % a_hp)
	scene.simulate_seconds(120.0)
	_check("scene ai: het 180s tran ket thuc", not scene.is_fighting())
	_check("scene ai: co nguoi thang/hoa", str(scene.battle.get("winner", "")) in ["A", "B", "hoa"])
	var log_text := ""
	for line in (scene.battle.get("log", []) as Array):
		log_text += str(line) + "\n"
	_check("scene ai: log co don danh cua Tieu thuong", "Tiểu thương" in log_text and "đánh" in log_text)
