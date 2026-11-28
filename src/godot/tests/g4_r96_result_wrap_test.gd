extends SceneTree
## G4 R96 RESULT WRAP TEST — chay headless, khong can trinh duyet:
##   godot --headless --script tests/g4_r96_result_wrap_test.gd (tu src/godot)
## Vong 96: panel ket qua tran cat chu o mep phai (anh 96-r95) vi
## result_text() 1 dong o co 24 vuot 560px — draw_string co width
## khong wrap, chi cat. Sua trong scripts/battle_scene.gd:
## wrap_text() tham lam theo tu, do bang font that; result_text_lines()
## co co chu 24 -> 20 -> 18 neu qua 4 dong; _draw_result() ve tung
## dong cach nhau 32px. Kiem tra: moi dong vua 560px o co chu da
## chon, <= 4 dong, khong mat tu, dong cuoi nam trong panel (430..730),
## ten doi rat dai cung khong tran, tu don dai hon 560px bi cat cung.
## In "G4 R96 RESULT WRAP TEST: n/n PASS".

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
	_test_case_r95()
	_test_case_draw()
	_test_case_long_names()
	_test_case_single_long_word()
	_test_case_no_hold()
	_test_panel_geometry()
	print("G4 R96 RESULT WRAP TEST: %d/%d PASS" % [_pass, _pass + _fail])
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


func _new_scene(mb: PxbMarketBattle, team_b_name: String) -> BattleScene:
	var res: Dictionary = mb.create_battle({
		"teamA": _mk_team_a(),
		"teamB": PxbMarketBattle.seed_npc_team("doi-cho", team_b_name, 3),
		"stallId": "sap-cho-dau-moi", "gameDay": 27, "defenderTeam": "B",
	})
	var scene := BattleScene.new()
	scene.setup(mb, res["battle"], load("res://DejaVuSans.ttf"), load("res://DejaVuSans-Bold.ttf"))
	_scenes.append(scene)
	return scene


func _finish(scene: BattleScene, winner_team: String, fa: int, fb: int, hold_until: int) -> void:
	scene.battle["status"] = "finished"
	scene.battle["result"] = {
		"winner": "A" if winner_team == "Đội Bạn" else "B",
		"winnerTeamName": winner_team,
		"rewards": {"teamA": {"famePerFighter": fa}, "teamB": {"famePerFighter": fb}},
	}
	if hold_until > 0:
		scene.battle["hold"] = {"stallId": "sap-cho-dau-moi", "untilGameDay": hold_until}


func _all_lines_fit(scene: BattleScene, wrapped: Dictionary) -> bool:
	var lines: PackedStringArray = wrapped["lines"]
	var size: int = int(wrapped["size"])
	for line in lines:
		var w := scene.font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if w > BattleScene.RESULT_TEXT_MAX_W + 0.5:
			return false
	return true


func _no_word_lost(scene: BattleScene, wrapped: Dictionary) -> bool:
	var lines: PackedStringArray = wrapped["lines"]
	var joined := " ".join(lines)
	return joined == scene.result_text()


func _test_case_r95() -> void:
	# Dung truong hop that o anh 96-r95: doi B thang, hold den ngay 34.
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	_finish(scene, "Đội Chợ Đầu Mối", 10, 50, 34)
	var raw := scene.result_text()
	_check("r95: result_text khong rong", not raw.is_empty())
	_check("r95: 1 dong co 24 vuot 560px (la bug cu)",
		scene.font.get_string_size(raw, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x > 560.0,
		"w=%.0f" % scene.font.get_string_size(raw, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x)
	var wrapped: Dictionary = scene.result_text_lines()
	_check("r95: <= 4 dong", (wrapped["lines"] as PackedStringArray).size() <= 4,
		"dong=%d" % (wrapped["lines"] as PackedStringArray).size())
	_check("r95: moi dong vua 560px", _all_lines_fit(scene, wrapped))
	_check("r95: khong mat tu", _no_word_lost(scene, wrapped))
	_check("r95: giu co 24", int(wrapped["size"]) == 24, "size=%d" % int(wrapped["size"]))


func _test_case_draw() -> void:
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	_finish(scene, "Đội Bạn", 50, 10, 34)
	var wrapped: Dictionary = scene.result_text_lines()
	_check("thang A: <= 4 dong", (wrapped["lines"] as PackedStringArray).size() <= 4)
	_check("thang A: moi dong vua 560px", _all_lines_fit(scene, wrapped))
	_check("thang A: khong mat tu", _no_word_lost(scene, wrapped))


func _test_case_long_names() -> void:
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài")
	_finish(scene, "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài", 10, 50, 34)
	var wrapped: Dictionary = scene.result_text_lines()
	_check("ten dai: <= 4 dong", (wrapped["lines"] as PackedStringArray).size() <= 4,
		"dong=%d size=%d" % [(wrapped["lines"] as PackedStringArray).size(), int(wrapped["size"])])
	_check("ten dai: moi dong vua 560px", _all_lines_fit(scene, wrapped))
	_check("ten dai: khong mat tu", _no_word_lost(scene, wrapped))


func _test_case_single_long_word() -> void:
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	_finish(scene, "Đội Bạn", 50, 10, 0)
	scene.battle["hold"] = {"stallId": "sap-cho-dau-moi-sieu-dai-ten-khong-co-khoang-trang-nao-ca", "untilGameDay": 99}
	var wrapped: Dictionary = scene.result_text_lines()
	_check("tu don dai: <= 4 dong", (wrapped["lines"] as PackedStringArray).size() <= 4,
		"dong=%d" % (wrapped["lines"] as PackedStringArray).size())
	_check("tu don dai: moi dong vua 560px", _all_lines_fit(scene, wrapped))
	# Cat cung theo ky tu co the chen khoang trang giua tu dai: chi
	# kiem noi dung khong mat ky tu (bo khoang trang de so).
	var joined := " ".join(wrapped["lines"]).replace(" ", "")
	_check("tu don dai: khong mat ky tu", joined == scene.result_text().replace(" ", ""))


func _test_case_no_hold() -> void:
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	scene.battle["status"] = "finished"
	scene.battle["result"] = {
		"winner": "hoa", "winnerTeamName": "",
		"rewards": {"teamA": {"famePerFighter": 20}, "teamB": {"famePerFighter": 20}},
	}
	var wrapped: Dictionary = scene.result_text_lines()
	_check("hoa: <= 4 dong", (wrapped["lines"] as PackedStringArray).size() <= 4)
	_check("hoa: moi dong vua 560px", _all_lines_fit(scene, wrapped))
	_check("hoa: khong mat tu", _no_word_lost(scene, wrapped))


func _test_panel_geometry() -> void:
	# Dong cuoi (baseline) phai nam tren chan panel 730 - 40
	# (chu thich o y=690), ke ca khi du 4 dong o co 24.
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài")
	_finish(scene, "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài", 10, 50, 34)
	var wrapped: Dictionary = scene.result_text_lines()
	var n := (wrapped["lines"] as PackedStringArray).size()
	var last_y := 430.0 + 120.0 + float(n - 1) * BattleScene.RESULT_LINE_H
	_check("hinh hoc: dong cuoi <= 690", last_y <= 690.0, "last_y=%.0f dong=%d" % [last_y, n])
	_check("hinh hoc: co chu >= 18", int(wrapped["size"]) >= 18)
