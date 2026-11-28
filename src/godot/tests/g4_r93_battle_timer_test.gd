extends SceneTree
## G4 R93 BATTLE TIMER TEST — chay headless, khong can trinh duyet:
##   godot --headless --script tests/g4_r93_battle_timer_test.gd (tu src/godot)
## Vong 93: dong ho luot (10s) + AI delay (1,2s) cung tich delta khung
## hinh; truoc day het gio chay TRUOC khoi AI nen mot khung hinh giat
## (delta day _turn_elapsed qua 10s trong luc _ai_wait con < 1,2s)
## nuot tron luot dich — tren trinh duyet that doi B dung rai rac,
## khong danh nhu sim (V92: landed 9/37). Sua trong
## scripts/battle_scene.gd: AI di truoc khi xet het gio + khong het
## gio khi dang cho AI (_ai_pending); luat 10s/luot + delay 1,2s
## khong doi. Kiem tra: delta lon khong lam mat luot AI, AI van di
## du sau luot dich, expire_turn khong cuop luot AI dang cho,
## simulate_seconds van khop sim cu, luot nguoi choi van het gio
## dung 10s. In "G4 R93 BATTLE TIMER TEST: n/n PASS".

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
	_test_delta_9s_luot_b_moi()
	_test_tich_1s_roi_delta_9s()
	_test_delta_10_5s_luot_b_moi()
	_test_chuoi_giat_roi_delta_9s()
	_test_delta_30s_luot_b_moi()
	_test_luot_a_het_gio()
	_test_simulate_seconds_khop_sim()
	_test_ai_tat_van_het_gio()
	_test_het_gio_qua_nhieu_khung_nho()
	_test_ai_pending()
	print("G4 R93 BATTLE TIMER TEST: %d/%d PASS" % [_pass, _pass + _fail])
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


func _pos_of(scene: BattleScene, fid: String) -> Vector2i:
	var f: Dictionary = scene.mb.find_fighter(scene.battle, fid)
	return Vector2i(int(f.get("x", -1)), int(f.get("y", -1)))


func _turn_fighter(scene: BattleScene) -> String:
	return str(scene.battle_status().get("turn_fighter", ""))


## Dua tran ve luot B dau tien (doi-cho-npc-1): ban-1 Ket thuc luot.
func _to_b_turn(scene: BattleScene) -> void:
	scene.ai_enabled = true
	scene.end_turn_now()


## T1 doi chung: luot B moi, 1 delta 9s (9 < 10) -> AI di nhu sim.
func _test_delta_9s_luot_b_moi() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene._advance_timers(9.0)
	_check("9s luot B moi: npc-1 di toi (8,3) nhu sim",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("9s luot B moi: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))
	_check("9s luot B moi: luot moi con du 10s (khung giat khong an delta)",
		is_equal_approx(scene.turn_seconds_left(), 10.0),
		"con %ss" % str(scene.turn_seconds_left()))


## T2 tai hien chinh (probe P2): luot B tich 1,0s (0,5+0,5, AI chua
## du 1,2s) roi 1 khung 9s -> tong dung 10,0s: AI VAN DI, khong bi
## expire_turn nuot nhu truoc sua.
func _test_tich_1s_roi_delta_9s() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene._advance_timers(0.5)
	scene._advance_timers(0.5)
	_check("1,0s tich: AI chua di (chua du 1,2s)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(11, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	scene._advance_timers(9.0)
	_check("1,0s + delta 9s (=10,0s): npc-1 van di toi (8,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("1,0s + delta 9s: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))
	_check("1,0s + delta 9s: dong ho tran tick du 10s",
		int(scene.battle.get("elapsedSeconds", -1)) == 10,
		"elapsed=%s" % str(scene.battle.get("elapsedSeconds", "?")))
	_check("1,0s + delta 9s: luot moi con du 10s",
		is_equal_approx(scene.turn_seconds_left(), 10.0),
		"con %ss" % str(scene.turn_seconds_left()))


## T3: luot B moi, 1 delta 10,5s vuot moc ngay -> AI van di.
func _test_delta_10_5s_luot_b_moi() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene._advance_timers(10.5)
	_check("10,5s luot B moi: npc-1 van di toi (8,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("10,5s luot B moi: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))


## T4 chuoi giat (probe P4): 0,5+0,5+0,1 = 1,1s (AI van chua du
## 1,2s) roi 1 khung 9s -> tong 10,1s: AI van di.
func _test_chuoi_giat_roi_delta_9s() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene._advance_timers(0.5)
	scene._advance_timers(0.5)
	scene._advance_timers(0.1)
	_check("giat 1,1s: AI chua di",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(11, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	scene._advance_timers(9.0)
	_check("giat 1,1s + delta 9s (=10,1s): npc-1 van di toi (8,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("giat 1,1s + delta 9s: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))


## T5 khung treo dai: luot B moi, 1 delta 30s -> AI van di du luot.
func _test_delta_30s_luot_b_moi() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene._advance_timers(30.0)
	_check("30s luot B moi: npc-1 van di toi (8,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("30s luot B moi: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))
	_check("30s luot B moi: dong ho tran tick du 30s",
		int(scene.battle.get("elapsedSeconds", -1)) == 30,
		"elapsed=%s" % str(scene.battle.get("elapsedSeconds", "?")))


## T6 luat nguoi choi khong doi: luot A moi, 1 delta 10,5s -> het
## gio luot A (ve B, npc-1 chua di ngay trong khung do), roi 3 khung
## 0,5s -> AI B di, luot ve ban-2 (delta giat khong an mat luot B).
func _test_luot_a_het_gio() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.ai_enabled = true
	scene._advance_timers(10.5)
	_check("10,5s luot A: het gio sang luot npc-1",
		_turn_fighter(scene) == "doi-cho-npc-1", "turn=%s" % _turn_fighter(scene))
	_check("10,5s luot A: npc-1 chua di trong khung giat",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(11, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	scene._advance_timers(0.5)
	scene._advance_timers(0.5)
	scene._advance_timers(0.5)
	_check("sau 3x0,5s: npc-1 di toi (8,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("sau 3x0,5s: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))


## T7 simulate_seconds van khop sim cu (R92 probe): npc-1 (8,3).
func _test_simulate_seconds_khop_sim() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene.simulate_seconds(3.0)
	_check("simulate 3,0s: npc-1 (8,3) nhu sim",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("simulate 3,0s: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))


## T8 AI tat: luot B, delta 10,5s -> het gio binh thuong (ve A),
## npc-1 khong di; guard _ai_pending khong chan het gio khi AI tat.
func _test_ai_tat_van_het_gio() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.ai_enabled = false
	scene.end_turn_now()
	_check("AI tat: luot B la npc-1", _turn_fighter(scene) == "doi-cho-npc-1",
		"turn=%s" % _turn_fighter(scene))
	scene._advance_timers(10.5)
	_check("AI tat + 10,5s: het gio ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))
	_check("AI tat + 10,5s: npc-1 dung yen (11,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(11, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))


## T9 het gio qua nhieu khung nho: 20 khung 0,5s = 10s o luot A ->
## het gio sang B; +3 khung 0,5s -> AI di, luot ve ban-2.
func _test_het_gio_qua_nhieu_khung_nho() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	scene.ai_enabled = true
	for i in range(20):
		scene._advance_timers(0.5)
	_check("20x0,5s luot A: het gio sang npc-1",
		_turn_fighter(scene) == "doi-cho-npc-1", "turn=%s" % _turn_fighter(scene))
	scene._advance_timers(0.5)
	scene._advance_timers(0.5)
	scene._advance_timers(0.5)
	_check("20x0,5s + 3x0,5s: npc-1 di toi (8,3)",
		_pos_of(scene, "doi-cho-npc-1") == Vector2i(8, 3),
		"pos=%s" % str(_pos_of(scene, "doi-cho-npc-1")))
	_check("20x0,5s + 3x0,5s: luot ve ban-2",
		_turn_fighter(scene) == "ban-2", "turn=%s" % _turn_fighter(scene))


## T10 helper _ai_pending: dung khi dang cho AI, sai khi AI tat
## hoac khi luot da ve nguoi choi.
func _test_ai_pending() -> void:
	var mb := _new_mb()
	var scene := _new_scene(mb)
	_to_b_turn(scene)
	scene._advance_timers(0.5)
	_check("_ai_pending: true khi luot B chua du 1,2s",
		scene._ai_pending())
	var mb2 := _new_mb()
	var scene2 := _new_scene(mb2)
	scene2.ai_enabled = false
	scene2.end_turn_now()
	_check("_ai_pending: false khi AI tat",
		not scene2._ai_pending())
	scene.simulate_seconds(3.0)
	_check("_ai_pending: false khi luot da ve A",
		not scene._ai_pending())
