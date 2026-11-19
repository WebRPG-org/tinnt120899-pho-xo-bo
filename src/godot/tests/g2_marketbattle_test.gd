extends SceneTree
## G2 MARKETBATTLE selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_marketbattle_test.gd
## Kiem tra: PxbMarketBattle (port PXB_MarketBattle.js) — luat DA CHOT
## 20/11 06:06 (design doc §11, 7 diem): luoi 12x9 / di chuyen 3 o;
## passive 6 vai + 4 vu khi; luot 10s / tran 180s / toi da 12 vong /
## thang bang % HP; giu sap 7 ngay (-10% si, -20% thue, +10 Danh
## vong/ngay); buff Tuong Cuop +10% sat thuong / Canh sat +10% Max HP
## khi thu sap; dieu kien mo tran 5 diem; Danh vong thang +50 / hoa
## +20 / thua +10. Tao tran, di chuyen, danh/ho tro, ket thuc tran,
## giu sap, save round-trip, signal.
## In "G2 MARKETBATTLE SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd (tranh xung dot voi luong song song).

var _pass := 0
var _fail := 0
var _mbs: Array = [] # battle node da tao — free o cuoi de log sach
var _finished_winner := ""
var _last_turn := ""


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _init() -> void:
	_test_constants()
	_test_roles()
	_test_create_fighter()
	_test_create_battle()
	_test_move()
	_test_attack()
	_test_support()
	_test_end_turn()
	_test_tick_timeout()
	_test_finish_rewards()
	_test_holds()
	_test_seed_npc()
	_test_save()
	_test_signals()
	_test_current_battle_wrappers()
	print("G2 MARKETBATTLE SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	for m in _mbs:
		m.free()
	quit(0 if _fail == 0 else 1)


func _on_battle_finished(winner: String) -> void:
	_finished_winner = winner


func _on_turn_changed(fighter_id: String) -> void:
	_last_turn = fighter_id


func _new_mb() -> PxbMarketBattle:
	var mb := PxbMarketBattle.new()
	mb.battle_finished.connect(_on_battle_finished)
	mb.turn_changed.connect(_on_turn_changed)
	_mbs.append(mb)
	return mb


func _mk_team(team_id: String, team_name: String, size: int) -> Dictionary:
	var roles: Array[String] = ["Do", "Xanh", "Vang", "Tim", "Cam"]
	var weapons: Array[String] = ["Chao", "CaKho", "GheNhua", "Loa", "Chao"]
	var fighters: Array = []
	for i in range(size):
		fighters.append(PxbMarketBattle.create_fighter(
			"%s-%d" % [team_id, i + 1],
			"Đấu sĩ %d" % (i + 1),
			roles[i % roles.size()],
			weapons[i % weapons.size()],
			{"the": 50, "tri": 50, "tam": 50}, []))
	return {"id": team_id, "name": team_name, "fighters": fighters}


func _mk_team_specs(team_id: String, team_name: String, specs: Array) -> Dictionary:
	var fighters: Array = []
	for s in specs:
		fighters.append(PxbMarketBattle.create_fighter(
			str(s[0]), str(s[1]), str(s[2]), str(s[3]),
			s[4] if s.size() > 4 else {},
			s[5] if s.size() > 5 else []))
	return {"id": team_id, "name": team_name, "fighters": fighters}


func _mk_battle(mb: PxbMarketBattle, size: int = 3, stall_id: String = "", game_day: int = 1, defender: String = "") -> Dictionary:
	var res: Dictionary = mb.create_battle({
		"teamA": _mk_team("ct-a", "Hợp tác xã A", size),
		"teamB": _mk_team("ct-b", "Hợp tác xã B", size),
		"stallId": stall_id, "gameDay": game_day, "defenderTeam": defender,
	})
	if not bool(res.get("ok", false)):
		_check("tao-tran-ok", false, str(res))
		return {}
	return res["battle"]


func _place(mb: PxbMarketBattle, battle: Dictionary, fighter_id: String, x: int, y: int) -> void:
	var f: Dictionary = mb.find_fighter(battle, fighter_id)
	f["x"] = x
	f["y"] = y


func _set_active(battle: Dictionary, fighter_id: String) -> void:
	battle["activeFighterId"] = fighter_id


# --- 1. Hang DA CHOT ---

func _test_constants() -> void:
	_check("luoi-12x9", PxbMarketBattle.GRID_W == 12 and PxbMarketBattle.GRID_H == 9)
	_check("hp-goc-100", PxbMarketBattle.BASE_HP == 100)
	_check("tank-x1.5-nhan-x0.8", PxbMarketBattle.TANK_HP_MULT == 1.5 and PxbMarketBattle.TANK_DMG_TAKEN_MULT == 0.8)
	_check("di-chuyen-3-o-xanh-+1", PxbMarketBattle.BASE_MOVE == 3 and PxbMarketBattle.TACTICIAN_MOVE_BONUS == 1)
	_check("luot-10s-tran-180s-12-vong", PxbMarketBattle.TURN_SECONDS == 10 and PxbMarketBattle.BATTLE_SECONDS == 180 and PxbMarketBattle.MAX_ROUNDS == 12)
	_check("giu-sap-7-ngay", PxbMarketBattle.HOLD_DAYS == 7)
	_check("si--10-thue--20-danh-vong-10", PxbMarketBattle.WHOLESALE_DISCOUNT_PERCENT == 10 and PxbMarketBattle.STALL_TAX_CUT_PERCENT == 20 and PxbMarketBattle.HOLD_FAME_PER_DAY == 10)
	_check("danh-vong-50-20-10", PxbMarketBattle.FAME_WIN == 50 and PxbMarketBattle.FAME_DRAW == 20 and PxbMarketBattle.FAME_LOSS == 10)
	_check("buff-10-10", PxbMarketBattle.BANDIT_DMG_BONUS_PERCENT == 10 and PxbMarketBattle.POLICE_HP_BONUS_PERCENT == 10)
	_check("ho-tro-12", PxbMarketBattle.SUPPORT_HEAL == 12)
	_check("tim-x1.25-cam-x2", PxbMarketBattle.SNIPER_DMG_MULT == 1.25 and PxbMarketBattle.BURST_FIRST_HIT_MULT == 2.0)
	var chao: Dictionary = PxbMarketBattle.WEAPONS["Chao"]
	_check("chao-12-tam-1", int(chao["dmg"]) == 12 and int(chao["range"]) == 1 and int(chao["knockback"]) == 0)
	var ca_kho: Dictionary = PxbMarketBattle.WEAPONS["CaKho"]
	_check("ca-kho-8-tam-2", int(ca_kho["dmg"]) == 8 and int(ca_kho["range"]) == 2)
	var ghe: Dictionary = PxbMarketBattle.WEAPONS["GheNhua"]
	_check("ghe-nhua-15-tam-1-day-1", int(ghe["dmg"]) == 15 and int(ghe["range"]) == 1 and int(ghe["knockback"]) == 1)
	var loa: Dictionary = PxbMarketBattle.WEAPONS["Loa"]
	_check("loa-10-tam-3", int(loa["dmg"]) == 10 and int(loa["range"]) == 3)
	_check("6-vai-du-ten", PxbMarketBattle.ROLES.size() == 6 and str(PxbMarketBattle.ROLES["Do"]["name"]) == "Tank" and str(PxbMarketBattle.ROLES["Xanh"]["name"]) == "Chiến thuật" and str(PxbMarketBattle.ROLES["Vang"]["name"]) == "Hỗ trợ" and str(PxbMarketBattle.ROLES["Tim"]["name"]) == "Chính xác" and str(PxbMarketBattle.ROLES["Cam"]["name"]) == "Burst" and str(PxbMarketBattle.ROLES["Luc"]["name"]) == "Mẹo")
	_check("co-doi-3-5", PxbMarketBattle.TEAM_SIZES == [3, 5])


# --- 2. Vai theo mau chi so ---

func _test_roles() -> void:
	_check("the-cao-nhat-do", PxbMarketBattle.role_from_stats({"the": 80, "tri": 40, "tam": 50}) == "Do")
	_check("tri-cao-nhat-xanh", PxbMarketBattle.role_from_stats({"the": 40, "tri": 80, "tam": 50}) == "Xanh")
	_check("tam-cao-nhat-vang", PxbMarketBattle.role_from_stats({"the": 40, "tri": 50, "tam": 80}) == "Vang")
	_check("the-tri-hoa-tim", PxbMarketBattle.role_from_stats({"the": 80, "tri": 80, "tam": 50}) == "Tim")
	_check("the-tam-hoa-cam", PxbMarketBattle.role_from_stats({"the": 80, "tri": 50, "tam": 80}) == "Cam")
	_check("tri-tam-hoa-luc", PxbMarketBattle.role_from_stats({"the": 50, "tri": 80, "tam": 80}) == "Luc")
	_check("can-bang-3-goc-tim", PxbMarketBattle.role_from_stats({"the": 50, "tri": 50, "tam": 50}) == "Tim")
	_check("the-vuot-troi-do-thang", PxbMarketBattle.role_from_stats({"the": 90, "tri": 60, "tam": 40}) == "Do")


# --- 3. Tao dau si + Max HP ---

func _test_create_fighter() -> void:
	var f: Dictionary = PxbMarketBattle.create_fighter("f1", "Tư", "", "Chao", {"the": 80, "tri": 40, "tam": 50}, [])
	_check("vai-tu-suy-the", str(f["role"]) == "Do")
	_check("vu-khi-la-ve-chao", str(PxbMarketBattle.create_fighter("f2", "X", "Do", "VuKhiLa", {}, []).get("weapon", "")) == "Chao")
	_check("mac-dinh-hp-100-song", int(f["hp"]) == 100 and int(f["maxHp"]) == 100 and bool(f["alive"]))
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb)
	var tank: Dictionary = mb.find_fighter(b, "ct-a-1") # Do
	_check("tank-max-hp-150", int(tank["maxHp"]) == 150)
	var mb2 := _new_mb()
	var b2: Dictionary = _mk_battle(mb2, 3, "", 1, "A")
	var police: Dictionary = PxbMarketBattle.create_fighter("p1", "Công an", "Xanh", "Chao", {}, ["Cảnh sát"])
	_check("canh-sat-thu-sap-+10%", PxbMarketBattle.compute_max_hp(police, true) == 110)
	_check("canh-sat-khong-thu-sap-khong-buff", PxbMarketBattle.compute_max_hp(police, false) == 100)
	var tank_police: Dictionary = PxbMarketBattle.create_fighter("p2", "Công an Tank", "Do", "Chao", {}, ["Cảnh sát"])
	_check("tank-canh-sat-thu-sap-165", PxbMarketBattle.compute_max_hp(tank_police, true) == 165)
	_check("tam-di-chuyen-xanh-4", PxbMarketBattle.move_range_of(mb.find_fighter(b, "ct-a-2")) == 4)
	_check("tam-di-chuyen-thuong-3", PxbMarketBattle.move_range_of(tank) == 3)


# --- 4. Tao tran: chan thieu nguoi / co doi ---

func _test_create_battle() -> void:
	var mb := _new_mb()
	var empty_a: Dictionary = mb.create_battle({"teamA": {"id": "a", "name": "A", "fighters": []}, "teamB": _mk_team("ct-b", "B", 3)})
	_check("doi-trong-chan", not bool(empty_a.get("ok", true)) and str(empty_a.get("reason", "")) == "doi-thieu-nguoi")
	var unequal: Dictionary = mb.create_battle({"teamA": _mk_team("ct-a", "A", 3), "teamB": _mk_team("ct-b", "B", 5)})
	_check("doi-khong-bang-chan", not bool(unequal.get("ok", true)) and str(unequal.get("reason", "")) == "doi-khong-bang-nhau")
	var size4: Dictionary = mb.create_battle({"teamA": _mk_team("ct-a", "A", 4), "teamB": _mk_team("ct-b", "B", 4)})
	_check("co-4-chan", not bool(size4.get("ok", true)) and str(size4.get("reason", "")) == "co-doi-khong-hop-le")
	var b: Dictionary = _mk_battle(mb, 3)
	_check("3v3-ok-trang-thai", str(b["status"]) == "dang-danh" and int(b["round"]) == 1)
	var a1: Dictionary = mb.find_fighter(b, "ct-a-1")
	_check("doi-a-xuat-phat-cot-0-1", int(a1["x"]) == 0 and int(a1["y"]) == 3)
	var b1: Dictionary = mb.find_fighter(b, "ct-b-1")
	_check("doi-b-xuat-phat-cot-10-11", int(b1["x"]) == 11 and int(b1["y"]) == 3)
	_check("thu-tu-xen-ke", (b["turnOrder"] as Array) == ["ct-a-1", "ct-b-1", "ct-a-2", "ct-b-2", "ct-a-3", "ct-b-3"])
	_check("luot-dau-a1", str(b["activeFighterId"]) == "ct-a-1")
	var b5: Dictionary = _mk_battle(mb, 5)
	_check("5v5-ok-10-dau-si", mb.all_fighters(b5).size() == 10)


# --- 5. Di chuyen ---

func _test_move() -> void:
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb)
	_check("di-3-o-ok", mb.move_fighter(b, "ct-a-1", 3, 3))
	_check("da-di-roi-chan", not mb.move_fighter(b, "ct-a-1", 3, 4))
	_set_active(b, "ct-a-2") # Xanh, tam 4, dang o (1,4)
	_check("xanh-di-4-o-ok", mb.move_fighter(b, "ct-a-2", 5, 4))
	var b2: Dictionary = _mk_battle(mb)
	_check("di-qua-tam-chan", not mb.move_fighter(b2, "ct-a-1", 4, 3))
	_check("di-ra-ngoai-luoi-chan", not mb.move_fighter(b2, "ct-a-1", -1, 3))
	_check("khong-phai-luot-chan", not mb.move_fighter(b2, "ct-b-1", 10, 3))
	_place(mb, b2, "ct-a-2", 1, 3)
	_check("o-co-nguoi-chan", not mb.move_fighter(b2, "ct-a-1", 1, 3))


# --- 6. Danh ---

func _custom_battle(mb: PxbMarketBattle, a_specs: Array, b_specs: Array) -> Dictionary:
	var res: Dictionary = mb.create_battle({
		"teamA": _mk_team_specs("ct-a", "Hợp tác xã A", a_specs),
		"teamB": _mk_team_specs("ct-b", "Hợp tác xã B", b_specs),
	})
	if not bool(res.get("ok", false)):
		_check("tao-tran-tuy-chinh-ok", false, str(res))
		return {}
	return res["battle"]


func _test_attack() -> void:
	var mb := _new_mb()
	# Chao 12 vao doi thu thuong.
	var b: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Chao", {"the": 50, "tri": 50, "tam": 50}, []],
		 ["a2", "A2", "Do", "Chao", {"the": 50, "tri": 50, "tam": 50}, []],
		 ["a3", "A3", "Vang", "Chao", {"the": 50, "tri": 50, "tam": 50}, []]],
		[["b1", "B1", "Xanh", "Chao", {"the": 50, "tri": 50, "tam": 50}, []],
		 ["b2", "B2", "Do", "Chao", {"the": 50, "tri": 50, "tam": 50}, []],
		 ["b3", "B3", "Vang", "Chao", {"the": 50, "tri": 50, "tam": 50}, []]])
	_place(mb, b, "a1", 5, 4)
	_place(mb, b, "b1", 6, 4)
	var r: Dictionary = mb.attack(b, "a1", "b1")
	_check("chao-danh-12", bool(r.get("ok", false)) and int(r.get("damage", -1)) == 12)
	_check("hp-tru-dung", int(mb.find_fighter(b, "b1")["hp"]) == 88)
	# Ngoai tam: tran moi (a1 o tran b da hanh dong roi nen khong dung lai duoc).
	var b2: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Chao", {}, []], ["a2", "A2", "Do", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b2, "a1", 5, 4)
	_place(mb, b2, "b1", 8, 4)
	var r2: Dictionary = mb.attack(b2, "a1", "b1")
	_check("ngoai-tam-chao-chan", not bool(r2.get("ok", true)) and str(r2.get("reason", "")) == "ngoai-tam")
	_place(mb, b2, "a2", 6, 4)
	_set_active(b2, "a1")
	var r3: Dictionary = mb.attack(b2, "a1", "a2")
	_check("cung-doi-chan", not bool(r3.get("ok", true)) and str(r3.get("reason", "")) == "cung-doi")
	# Tank nhan 12 * 0.8 = 9 (lam tron xuong).
	_place(mb, b2, "b2", 6, 4)
	var r4: Dictionary = mb.attack(b2, "a1", "b2")
	_check("tank-nhan-9", bool(r4.get("ok", false)) and int(r4.get("damage", -1)) == 9)
	# Tim x1.25: 12 * 1.25 = 15.
	var b3: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Tim", "Chao", {}, []], ["a2", "A2", "Do", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b3, "a1", 5, 4)
	_place(mb, b3, "b1", 6, 4)
	_check("tim-danh-15", int(mb.attack(b3, "a1", "b1").get("damage", -1)) == 15)
	# Cam don dau x2 = 24, don sau = 12.
	var b4: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Cam", "Chao", {}, []], ["a2", "A2", "Cam", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Xanh", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b4, "a1", 5, 4)
	_place(mb, b4, "b1", 6, 4)
	_place(mb, b4, "b2", 5, 5)
	_check("cam-don-dau-24", int(mb.attack(b4, "a1", "b1").get("damage", -1)) == 24)
	# Cung dau si Cam danh lan 2 (reset co actedThisTurn, giu
	# hasAttackedThisBattle) thi het x2.
	(mb.find_fighter(b4, "a1") as Dictionary)["actedThisTurn"] = false
	_check("cam-don-sau-12", int(mb.attack(b4, "a1", "b2").get("damage", -1)) == 12)
	# Tuong Cuop +10%: 12 * 1.1 = 13 (lam tron xuong); Tim + Tuong Cuop: 16.
	var b5: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Chao", {}, ["Tướng Cướp"]], ["a2", "A2", "Tim", "Chao", {}, ["Tướng Cướp"]], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Xanh", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b5, "a1", 5, 4)
	_place(mb, b5, "b1", 6, 4)
	_check("tuong-cuop-danh-13", int(mb.attack(b5, "a1", "b1").get("damage", -1)) == 13)
	_set_active(b5, "a2")
	_place(mb, b5, "a2", 5, 5)
	_place(mb, b5, "b2", 6, 5)
	_check("tim-tuong-cuop-danh-16", int(mb.attack(b5, "a2", "b2").get("damage", -1)) == 16)
	# Ghe nhua 15 + day lui 1 o.
	var b6: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "GheNhua", {}, []], ["a2", "A2", "Do", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b6, "a1", 5, 4)
	_place(mb, b6, "b1", 6, 4)
	var r6: Dictionary = mb.attack(b6, "a1", "b1")
	_check("ghe-nhua-danh-15-day-lui", bool(r6.get("ok", false)) and int(r6.get("damage", -1)) == 15 and bool(r6.get("pushed", false)) and int(mb.find_fighter(b6, "b1")["x"]) == 7)
	# Loa tam 3: danh 10; Ca kho tam 2: danh 8.
	var b7: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Loa", {}, []], ["a2", "A2", "Xanh", "CaKho", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Xanh", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b7, "a1", 5, 4)
	_place(mb, b7, "b1", 8, 4)
	_check("loa-tam-3-danh-10", int(mb.attack(b7, "a1", "b1").get("damage", -1)) == 10)
	_set_active(b7, "a2")
	_place(mb, b7, "a2", 5, 5)
	_place(mb, b7, "b2", 7, 5)
	_check("ca-kho-tam-2-danh-8", int(mb.attack(b7, "a2", "b2").get("damage", -1)) == 8)
	# Luc ne don dau moi vong.
	var b8: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Chao", {}, []], ["a2", "A2", "Xanh", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Luc", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b8, "a1", 5, 4)
	_place(mb, b8, "b1", 6, 4)
	var r8: Dictionary = mb.attack(b8, "a1", "b1")
	_check("luc-ne-don-dau", bool(r8.get("ok", false)) and int(r8.get("damage", -1)) == 0 and bool(r8.get("dodged", false)))
	_set_active(b8, "a2")
	(mb.find_fighter(b8, "a2") as Dictionary)["actedThisTurn"] = false
	_place(mb, b8, "a2", 5, 5)
	_place(mb, b8, "b1", 6, 5)
	var r8b: Dictionary = mb.attack(b8, "a2", "b1")
	_check("luc-don-thu-2-trung", bool(r8b.get("ok", false)) and int(r8b.get("damage", -1)) == 12 and not bool(r8b.get("dodged", true)))
	# KO: nga sap, hp 0, alive false.
	var b9: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Chao", {}, []], ["a2", "A2", "Do", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b9, "a1", 5, 4)
	_place(mb, b9, "b1", 6, 4)
	(mb.find_fighter(b9, "b1") as Dictionary)["hp"] = 5
	var r9: Dictionary = mb.attack(b9, "a1", "b1")
	_check("ko-nga-sap", bool(r9.get("ok", false)) and bool(r9.get("ko", false)) and int(mb.find_fighter(b9, "b1")["hp"]) == 0 and not bool(mb.find_fighter(b9, "b1")["alive"]))
	# JS kiem tra actedThisTurn TRUOC muc tieu nga — reset co roi moi
	# thay ly do "muc-tieu-nga".
	(mb.find_fighter(b9, "a1") as Dictionary)["actedThisTurn"] = false
	var r9b: Dictionary = mb.attack(b9, "a1", "b1")
	_check("danh-muc-tieu-nga-chan", not bool(r9b.get("ok", true)) and str(r9b.get("reason", "")) == "muc-tieu-nga")


# --- 7. Ho tro (Vang) ---

func _test_support() -> void:
	var mb := _new_mb()
	var b: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Vang", "Chao", {}, []], ["a2", "A2", "Do", "Chao", {}, []], ["a3", "A3", "Xanh", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b, "a1", 5, 4)
	_place(mb, b, "a2", 6, 4)
	(mb.find_fighter(b, "a2") as Dictionary)["hp"] = 50
	var r: Dictionary = mb.support(b, "a1", "a2")
	_check("vang-hoi-12", bool(r.get("ok", false)) and int(r.get("healed", -1)) == 12 and int(mb.find_fighter(b, "a2")["hp"]) == 62)
	# Hoi thua mat (kep Max HP): a2 la Tank, maxHp 150 — dat hp 145.
	(mb.find_fighter(b, "a1") as Dictionary)["actedThisTurn"] = false
	(mb.find_fighter(b, "a2") as Dictionary)["hp"] = 145
	var r2: Dictionary = mb.support(b, "a1", "a2")
	_check("hoi-kep-max-hp", bool(r2.get("ok", false)) and int(r2.get("healed", -1)) == 5)
	var b2: Dictionary = _custom_battle(mb,
		[["a1", "A1", "Xanh", "Chao", {}, []], ["a2", "A2", "Do", "Chao", {}, []], ["a3", "A3", "Vang", "Chao", {}, []]],
		[["b1", "B1", "Xanh", "Chao", {}, []], ["b2", "B2", "Do", "Chao", {}, []], ["b3", "B3", "Vang", "Chao", {}, []]])
	_place(mb, b2, "a1", 5, 4)
	_place(mb, b2, "b1", 6, 4)
	var r3: Dictionary = mb.support(b2, "a1", "b1")
	_check("khong-phai-vang-chan", not bool(r3.get("ok", true)) and str(r3.get("reason", "")) == "khong-phai-ho-tro")
	_set_active(b2, "a3")
	_place(mb, b2, "a3", 5, 5)
	_place(mb, b2, "b1", 6, 5)
	var r4: Dictionary = mb.support(b2, "a3", "b1")
	_check("ho-tro-doi-thu-chan", not bool(r4.get("ok", true)) and str(r4.get("reason", "")) == "khong-cung-doi")
	_place(mb, b2, "a2", 7, 5)
	var r5: Dictionary = mb.support(b2, "a3", "a2")
	_check("ho-tro-xa-chan", not bool(r5.get("ok", true)) and str(r5.get("reason", "")) == "ngoai-tam")


# --- 8. Ket thuc luot / vong ---

func _test_end_turn() -> void:
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb)
	_check("luot-dau-a1", str(b["activeFighterId"]) == "ct-a-1")
	_check("het-luot-sang-b1", mb.end_turn(b) and str(b["activeFighterId"]) == "ct-b-1")
	_check("het-luot-sang-a2", mb.end_turn(b) and str(b["activeFighterId"]) == "ct-a-2")
	# Bo qua dau si da nga.
	(mb.find_fighter(b, "ct-b-2") as Dictionary)["alive"] = false
	(mb.find_fighter(b, "ct-b-2") as Dictionary)["hp"] = 0
	_check("het-luot-bo-qua-da-nga", mb.end_turn(b) and str(b["activeFighterId"]) == "ct-a-3")
	# Het 1 vong: round 2, ne cua Luc dat lai.
	var b2: Dictionary = _mk_battle(mb)
	for f in mb.all_fighters(b2):
		(f as Dictionary)["dodgedThisRound"] = true
	for i in range(6):
		mb.end_turn(b2)
	_check("het-vong-sang-vong-2", int(b2["round"]) == 2)
	_check("het-vong-dat-lai-ne", not bool((mb.all_fighters(b2)[0] as Dictionary).get("dodgedThisRound", true)))
	_check("het-vong-luot-ve-a1", str(b2["activeFighterId"]) == "ct-a-1")
	_check("het-luot-tran-xong-false", not mb.end_turn({"status": "ket-thuc"}))


# --- 9. Dong ho tran / het gio ---

func _test_tick_timeout() -> void:
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb)
	_check("tick-chay", mb.tick(b, 30) and int(b["elapsedSeconds"]) == 30)
	_check("tick-am-khong-tru", mb.tick(b, -5) and int(b["elapsedSeconds"]) == 30)
	# Het 180s: thang bang % HP (B1 la Tank maxHp 150, dat hp 10:
	# doi B con 210/350 = 0.6).
	(mb.find_fighter(b, "ct-b-1") as Dictionary)["hp"] = 10
	_check("het-gio-thang-theo-%-hp", mb.tick(b, 150) and str(b["status"]) == "ket-thuc" and str(b["winner"]) == "A")
	_check("%-hp-b-0.6", abs(float((b["result"] as Dictionary)["hpPercentB"]) - 0.6) < 0.001)
	# Hoa khi % HP bang nhau.
	var b2: Dictionary = _mk_battle(mb)
	_check("het-gio-hoa", mb.tick(b2, 180) and str(b2["winner"]) == "hoa")
	_check("tick-tran-xong-false", not mb.tick(b2, 10))


# --- 10. Ket thuc tran: Danh vong + hoi day HP ---

func _ko_all_b(mb: PxbMarketBattle, battle: Dictionary) -> void:
	for i in range(3):
		var atk_id: String = "ct-a-%d" % (i + 1)
		var def_id: String = "ct-b-%d" % (i + 1)
		_set_active(battle, atk_id)
		_place(mb, battle, atk_id, 5, 4)
		_place(mb, battle, def_id, 6, 4)
		(mb.find_fighter(battle, def_id) as Dictionary)["hp"] = 5
		mb.attack(battle, atk_id, def_id)
		if str(battle.get("status", "")) != "ket-thuc":
			mb.end_turn(battle)


func _test_finish_rewards() -> void:
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb)
	_ko_all_b(mb, b)
	_check("ko-het-doi-b-a-thang", str(b["winner"]) == "A")
	var res: Dictionary = b["result"]
	_check("thang-+50-thua-+10", int(((res["rewards"] as Dictionary)["teamA"] as Dictionary)["famePerFighter"]) == 50 and int(((res["rewards"] as Dictionary)["teamB"] as Dictionary)["famePerFighter"]) == 10)
	_check("het-tran-hoi-day-hp", int(mb.find_fighter(b, "ct-b-1")["hp"]) == int(mb.find_fighter(b, "ct-b-1")["maxHp"]) and bool(mb.find_fighter(b, "ct-b-1")["alive"]))
	_check("giao-huu-khong-giu-sap", (b.get("hold", {}) as Dictionary).is_empty())
	var b2: Dictionary = _mk_battle(mb)
	_check("hoa-+20-ca-hai", mb.tick(b2, 180) and int((((b2["result"] as Dictionary)["rewards"] as Dictionary)["teamA"] as Dictionary)["famePerFighter"]) == 20 and int((((b2["result"] as Dictionary)["rewards"] as Dictionary)["teamB"] as Dictionary)["famePerFighter"]) == 20)


# --- 11. Giu sap ---

func _test_holds() -> void:
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb, 3, "sap-cho-dau-moi-1", 42)
	_ko_all_b(mb, b)
	_check("thang-tranh-sap-giu-7-ngay", str(b["winner"]) == "A" and int((b["hold"] as Dictionary)["untilGameDay"]) == 49)
	_check("dang-giu-sap-ngay-45", mb.is_holding_now("sap-cho-dau-moi-1", 45))
	_check("het-han-ngay-49", not mb.is_holding_now("sap-cho-dau-moi-1", 49))
	_check("doi-nao-giu-sap", mb.team_holds_stall_now("ct-a", 45) == "sap-cho-dau-moi-1")
	_check("doi-khac-khong-giu", mb.team_holds_stall_now("ct-b", 45) == "")
	var ben: Dictionary = mb.hold_benefits_now("ct-a", 45)
	_check("quyen-loi-sap-10-20-10", int(ben.get("wholesaleDiscountPercent", -1)) == 10 and int(ben.get("stallTaxCutPercent", -1)) == 20 and int(ben.get("famePerDay", -1)) == 10)
	_check("khong-giu-khong-quyen-loi", mb.hold_benefits_now("ct-b", 45).is_empty())
	var c1: Dictionary = mb.can_challenge_now("ct-a", "sap-khac", 45)
	_check("giu-sap-khac-chan-thach-dau", not bool(c1.get("ok", true)) and str(c1.get("reason", "")) == "dang-giu-sap-khac")
	var c2: Dictionary = mb.can_challenge_now("ct-a", "sap-cho-dau-moi-1", 45)
	_check("da-giu-sap-nay-chan", not bool(c2.get("ok", true)) and str(c2.get("reason", "")) == "da-giu-sap-nay")
	_check("doi-khac-thach-dau-duoc", bool(mb.can_challenge_now("ct-b", "sap-cho-dau-moi-1", 45).get("ok", false)))
	_check("chua-het-han-khong-don", mb.expire_holds_now(48) == 0)
	_check("het-han-don-1-sap", mb.expire_holds_now(49) == 1)
	_check("don-xong-het-giu", not mb.is_holding_now("sap-cho-dau-moi-1", 49))
	_check("lich-su-1-tran", mb.battle_history_now().size() == 1)


# --- 12. Doi NPC ---

func _test_seed_npc() -> void:
	var t3: Dictionary = PxbMarketBattle.seed_npc_team("npc-a", "Đội NPC A", 3)
	_check("npc-3-nguoi", (t3["fighters"] as Array).size() == 3)
	var t5: Dictionary = PxbMarketBattle.seed_npc_team("npc-b", "Đội NPC B", 5)
	_check("npc-5-nguoi", (t5["fighters"] as Array).size() == 5)
	var t4: Dictionary = PxbMarketBattle.seed_npc_team("npc-c", "Đội NPC C", 4)
	_check("npc-co-4-ve-3", (t4["fighters"] as Array).size() == 3)
	_check("npc-id-ten", str(((t3["fighters"] as Array)[0] as Dictionary)["id"]) == "npc-a-npc-1" and str(((t3["fighters"] as Array)[0] as Dictionary)["name"]) == "Tiểu thương 1")


# --- 13. Save round-trip ---

func _test_save() -> void:
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb, 3, "sap-cho-dau-moi-1", 42)
	_ko_all_b(mb, b)
	var mb2 := _new_mb()
	mb2.from_data(mb.data())
	_check("save-giu-sap", mb2.is_holding_now("sap-cho-dau-moi-1", 45))
	_check("save-lich-su", mb2.battle_history_now().size() == 1)
	var mb3 := _new_mb()
	mb3.from_data({"holds": {"sap-x": {"teamId": "ct-a"}}, "history": [{"result": "A"}, {"nope": 1}, "chuoi"], "extra": 1})
	_check("bo-sap-thieu-field", mb3.team_holds_stall_now("ct-a", 45) == "")
	_check("bo-lich-su-ban", mb3.battle_history_now().size() == 1)
	mb3.from_data({})
	_check("from-data-rong-reset", mb3.battle_history_now().is_empty())
	# Lich su cat o 50 tran.
	var st: Dictionary = {"holds": {}, "history": []}
	for i in range(55):
		PxbMarketBattle.record_battle(st, {"gameDay": 1, "stallId": "", "winner": "A", "round": 1, "elapsedSeconds": 10, "result": {"winnerTeamId": "ct-a"}})
	_check("lich-su-cat-50", (st["history"] as Array).size() == 50)


# --- 14. Signal ---

func _test_signals() -> void:
	_finished_winner = ""
	_last_turn = ""
	var mb := _new_mb()
	var b: Dictionary = _mk_battle(mb)
	mb.end_turn(b)
	_check("signal-doi-luot", _last_turn == "ct-b-1")
	_ko_all_b(mb, b)
	_check("signal-ket-thuc-tran", _finished_winner == "A")


# --- 15. Wrapper tran hien tai ---

func _test_current_battle_wrappers() -> void:
	var mb := _new_mb()
	_check("attack-khong-co-tran", str(mb.attack_now("a1", "b1").get("reason", "")) == "khong-co-tran")
	_check("end-turn-khong-co-tran", not mb.end_turn_now())
	_check("tick-khong-co-tran", not mb.tick_now(5))
	var b: Dictionary = _mk_battle(mb)
	mb.set_current_battle(b)
	_check("get-current-battle", mb.get_current_battle() == b)
	_place(mb, b, "ct-a-1", 5, 4)
	_place(mb, b, "ct-b-1", 6, 4)
	# ct-a-1 (Do, Chao) danh ct-b-1 (Do, Tank): 12 * 0.8 = 9.
	_check("attack-now-danh-9", int(mb.attack_now("ct-a-1", "ct-b-1").get("damage", -1)) == 9)
	_check("move-now-false-sai-luot", not mb.move_fighter_now("ct-b-1", 10, 3))
