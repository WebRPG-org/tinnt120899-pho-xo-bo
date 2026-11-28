extends SceneTree
## G4 R92 BATTLE BRIDGE TEST — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r92_battle_bridge_test.gd
## Kiem tra: BattleScene.battle_status() (Vong 92) — dict day du de
## script browser-verify dong bo tung luot tran thay vi bam mu theo
## thoi gian (bai hoc V91: 34 luot replay mu khong trung don nao).
## Trang thai: mo/dang danh/het tran, luot ai, % HP 2 doi, vi tri +
## HP + co moved/acted tung dau si, o di duoc / muc tieu danh duoc.
## JSON.stringify(status) phai parse lai duoc (day la dang day qua
## JavaScriptBridge.eval len window.__pxb_battle tren web).
## In "G4 R92 BATTLE BRIDGE TEST: n/n PASS".

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
	_test_empty_scene()
	_test_fresh_battle_status()
	_test_move_updates_status()
	_test_attack_updates_status()
	_test_end_turn_and_ai()
	_test_match_end_status()
	_test_json_roundtrip()
	print("G4 R92 BATTLE BRIDGE TEST: %d/%d PASS" % [_pass, _pass + _fail])
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
		PxbMarketBattle.create_fighter("ban-1", "Bạn", "Do", "Chao",
			{"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-2", "Bạn Thân", "Xanh", "CaKho",
			{"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-3", "Cô Tư", "Vang", "Loa",
			{"the": 40, "tri": 50, "tam": 80}, []),
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


func _fighter_in(status: Dictionary, fighter_id: String) -> Dictionary:
	for f in (status.get("fighters", []) as Array):
		if str((f as Dictionary).get("id", "")) == fighter_id:
			return f
	return {}


func _test_empty_scene() -> void:
	var scene := BattleScene.new()
	_scenes.append(scene)
	var st := scene.battle_status()
	_check("rong: open=false", st.get("open") == false)
	_check("rong: over=false", st.get("over") == false)
	_check("rong: winner rong", str(st.get("winner", "")) == "")
	_check("rong: khong co dau si", (st.get("fighters", []) as Array).is_empty())
	_check("rong: khong co o di duoc", (st.get("reachable", []) as Array).is_empty())
	_check("rong: khong co muc tieu", (st.get("attackable", []) as Array).is_empty())
	# _push_bridge headless khong goi JavaScriptBridge (khong web) — khong crash.
	scene._push_bridge()
	scene._process(0.016)
	_check("rong: _push_bridge headless khong loi", true)


func _test_fresh_battle_status() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	var st := scene.battle_status()
	_check("moi: open=true", st.get("open") == true)
	_check("moi: over=false", st.get("over") == false)
	_check("moi: round=1", int(st.get("round", 0)) == 1)
	_check("moi: luot dau ban-1", str(st.get("turn_fighter", "")) == "ban-1")
	_check("moi: luot doi A", str(st.get("turn_team", "")) == "A")
	_check("moi: HP 2 doi 100%", float(st.get("hp_a_pct", 0.0)) == 1.0
		and float(st.get("hp_b_pct", 0.0)) == 1.0)
	_check("moi: 6 dau si", (st.get("fighters", []) as Array).size() == 6)
	var a1 := _fighter_in(st, "ban-1")
	_check("moi: ban-1 song, chua di/chua danh",
		not a1.is_empty() and bool(a1.get("alive", false))
		and not bool(a1.get("moved", true)) and not bool(a1.get("acted", true)))
	_check("moi: ban-1 co HP day", int(a1.get("hp", 0)) == int(a1.get("maxHp", 0))
		and int(a1.get("maxHp", 0)) > 0)
	_check("moi: ban-1 co o di duoc", not (st.get("reachable", []) as Array).is_empty())
	_check("moi: ban-1 chua co muc tieu (dich xa)",
		(st.get("attackable", []) as Array).is_empty())
	_check("moi: co last_action", str(st.get("last_action", "")) != "")


func _test_move_updates_status() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	var reach: Array = scene.battle_status().get("reachable", [])
	_check("di: co o de di", not reach.is_empty())
	var dest: Array = reach[0]
	var before := scene.battle_status()
	var a1_before := _fighter_in(before, "ban-1")
	_check("di: click o xanh thi moved",
		scene.click_tile(Vector2i(int(dest[0]), int(dest[1]))) == "moved")
	var after := scene.battle_status()
	var a1_after := _fighter_in(after, "ban-1")
	_check("di: vi tri ban-1 doi theo o dich",
		int(a1_after.get("x", -1)) == int(dest[0]) and int(a1_after.get("y", -1)) == int(dest[1]),
		"truoc=(%d,%d) sau=(%d,%d) dich=(%d,%d)" % [
			int(a1_before.get("x", -1)), int(a1_before.get("y", -1)),
			int(a1_after.get("x", -1)), int(a1_after.get("y", -1)),
			int(dest[0]), int(dest[1])])
	_check("di: co moved=true", bool(a1_after.get("moved", false)))
	_check("di: het o di duoc sau khi di",
		(after.get("reachable", []) as Array).is_empty())
	_check("di: luot van ban-1", str(after.get("turn_fighter", "")) == "ban-1")


func _test_attack_updates_status() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	var a1: Dictionary = mb.find_fighter(scene.battle, "ban-1")
	var b1: Dictionary = mb.find_fighter(scene.battle, "doi-cho-npc-1")
	a1["x"] = 5
	a1["y"] = 4
	b1["x"] = 6
	b1["y"] = 4
	_set_active(scene, "ban-1")
	var st0 := scene.battle_status()
	_check("danh: co 1 muc tieu trong tam", (st0.get("attackable", []) as Array).size() == 1)
	_check("danh: click dich thi attacked", scene.click_tile(Vector2i(6, 4)) == "attacked")
	var st1 := scene.battle_status()
	var b1_after := _fighter_in(st1, "doi-cho-npc-1")
	_check("danh: B1 mat 9 HP (tank giam thuong)", int(b1_after.get("hp", 0)) == 141,
		"hp=%d" % int(b1_after.get("hp", 0)))
	var a1_after := _fighter_in(st1, "ban-1")
	_check("danh: ban-1 co acted=true", bool(a1_after.get("acted", false)))
	_check("danh: % HP doi B giam duoi 100%",
		float(st1.get("hp_b_pct", 1.0)) < 1.0, "hp_b_pct=%s" % str(st1.get("hp_b_pct", 0.0)))
	_check("danh: het muc tieu sau khi danh",
		(st1.get("attackable", []) as Array).is_empty())


func _test_end_turn_and_ai() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.ai_enabled = true
	_check("luot: Ket thuc luot doi luot",
		scene.end_turn_now() and str(scene.battle_status().get("turn_fighter", "")) != "ban-1")
	var st_b := scene.battle_status()
	_check("luot: sau Ket thuc luot la luot doi B",
		str(st_b.get("turn_team", "")) == "B", "turn=%s/%s" % [
			str(st_b.get("turn_fighter", "")), str(st_b.get("turn_team", ""))])
	# AI doi B: cho 3s mo phong (delay 1,2s + tu ket thuc luot) -> ve luot doi A.
	scene.simulate_seconds(3.0)
	var st_a := scene.battle_status()
	_check("luot: AI di xong, ve luot doi A",
		str(st_a.get("turn_team", "")) == "A", "turn=%s/%s" % [
			str(st_a.get("turn_fighter", "")), str(st_a.get("turn_team", ""))])
	_check("luot: tran van dang danh", st_a.get("over") == false)


func _test_match_end_status() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.simulate_seconds(200.0)
	var st := scene.battle_status()
	_check("het tran: over=true", st.get("over") == true)
	_check("het tran: co winner", str(st.get("winner", "")) != "",
		"winner=%s" % str(st.get("winner", "")))
	_check("het tran: co result_text", str(st.get("result_text", "")) != "")
	_check("het tran: click sau khi xong thi none",
		scene.click_tile(Vector2i(5, 5)) == "none")


func _test_json_roundtrip() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	var st := scene.battle_status()
	var json_text := JSON.stringify(st)
	var parsed: Variant = JSON.parse_string(json_text)
	_check("json: stringify/parse duoc", parsed is Dictionary)
	if parsed is Dictionary:
		var d: Dictionary = parsed
		_check("json: giu dung turn_fighter",
			str(d.get("turn_fighter", "")) == "ban-1")
		_check("json: giu dung 6 dau si",
			(d.get("fighters", []) as Array).size() == 6)
