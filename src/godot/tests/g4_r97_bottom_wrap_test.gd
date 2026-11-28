extends SceneTree
## G4 R97 BOTTOM WRAP TEST — chay headless, khong can trinh duyet:
##   godot --headless --script tests/g4_r97_bottom_wrap_test.gd (tu src/godot)
## Vong 97: V96 sua panel ket qua giua (result_text_lines) nhung dong
## _last_action o panel duoi (_draw_bottom, y=1104, co 22) VAN bi cat
## mep phai — anh 122-r96b: "Đội Bạn thắng trận! Danh vọng: Đội Bạn
## +50, Đội Chợ Đầu Mố...". Sua: khi het tran thi wrap _last_action
## bang bottom_action_lines() — toi da 2 dong co 20 (xuong 18 neu
## thua), dong 1 o y=1078, cach nhau 28px, dong cuoi khong cham nut
## (nut bat dau y=1120). Khi dang danh thi giu 1 dong y=1104 nhu cu.
## Kiem tra: moi dong vua 656px o co chu da chon, <= 2 dong, khong
## mat tu, dong cuoi nam tren nut, chu ngan van 1 dong co 20.
## In "G4 R97 BOTTOM WRAP TEST: n/n PASS".

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
	_test_case_r96b()
	_test_case_r95()
	_test_case_long_names()
	_test_case_short()
	_test_case_empty()
	_test_panel_geometry()
	print("G4 R97 BOTTOM WRAP TEST: %d/%d PASS" % [_pass, _pass + _fail])
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
		if w > BattleScene.BOTTOM_TEXT_MAX_W + 0.5:
			return false
	return true


func _no_word_lost(text: String, wrapped: Dictionary) -> bool:
	var lines: PackedStringArray = wrapped["lines"]
	var joined := " ".join(lines)
	return joined == text


func _last_baseline(wrapped: Dictionary) -> float:
	var n := (wrapped["lines"] as PackedStringArray).size()
	return BattleScene.BOTTOM_TEXT_FIRST_Y + float(n - 1) * BattleScene.BOTTOM_TEXT_LINE_H


func _test_case_r96b() -> void:
	# Dung truong hop that o anh 122-r96b: doi A thang, hold den ngay 8.
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	_finish(scene, "Đội Bạn", 50, 10, 8)
	var raw := scene.result_text()
	_check("r96b: 1 dong co 22 vuot 656px (la bug cu)",
		scene.font.get_string_size(raw, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x > 656.0,
		"w=%.0f" % scene.font.get_string_size(raw, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x)
	var wrapped: Dictionary = scene.bottom_action_lines(raw)
	_check("r96b: <= 2 dong", (wrapped["lines"] as PackedStringArray).size() <= 2,
		"dong=%d" % (wrapped["lines"] as PackedStringArray).size())
	_check("r96b: moi dong vua 656px", _all_lines_fit(scene, wrapped))
	_check("r96b: khong mat tu", _no_word_lost(raw, wrapped))
	_check("r96b: dong cuoi tren nut 1120", _last_baseline(wrapped) <= 1110.0,
		"last_y=%.0f" % _last_baseline(wrapped))


func _test_case_r95() -> void:
	# Doi B thang, hold den ngay 34 — cau dai hon.
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	_finish(scene, "Đội Chợ Đầu Mối", 10, 50, 34)
	var raw := scene.result_text()
	var wrapped: Dictionary = scene.bottom_action_lines(raw)
	_check("r95: <= 2 dong", (wrapped["lines"] as PackedStringArray).size() <= 2,
		"dong=%d" % (wrapped["lines"] as PackedStringArray).size())
	_check("r95: moi dong vua 656px", _all_lines_fit(scene, wrapped))
	_check("r95: khong mat tu", _no_word_lost(raw, wrapped))
	_check("r95: dong cuoi tren nut 1120", _last_baseline(wrapped) <= 1110.0,
		"last_y=%.0f" % _last_baseline(wrapped))


func _test_case_long_names() -> void:
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài")
	_finish(scene, "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài", 10, 50, 34)
	var raw := scene.result_text()
	var wrapped: Dictionary = scene.bottom_action_lines(raw)
	_check("ten dai: <= 2 dong", (wrapped["lines"] as PackedStringArray).size() <= 2,
		"dong=%d size=%d" % [(wrapped["lines"] as PackedStringArray).size(), int(wrapped["size"])])
	_check("ten dai: moi dong vua 656px", _all_lines_fit(scene, wrapped))
	# Ten cuc dai thi cat co dau "…": phan giu lai phai la tien to
	# cua cau goc (khong mat tu o giua), chu day du da co o panel giua.
	var lines: PackedStringArray = wrapped["lines"]
	_check("ten dai: ket bang …", str(lines[lines.size() - 1]).ends_with("…"))
	_check("ten dai: phan giu la tien to cau goc",
		raw.begins_with(" ".join(lines).replace("…", "")))
	_check("ten dai: co chu >= 18", int(wrapped["size"]) >= 18)


func _test_case_short() -> void:
	# Dong hanh dong luc dang danh: ngan, van 1 dong co 20.
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	var wrapped: Dictionary = scene.bottom_action_lines("Bạn đánh Cô Tư −12 HP.")
	_check("ngan: 1 dong", (wrapped["lines"] as PackedStringArray).size() == 1,
		"dong=%d" % (wrapped["lines"] as PackedStringArray).size())
	_check("ngan: giu co 20", int(wrapped["size"]) == 20, "size=%d" % int(wrapped["size"]))
	_check("ngan: khong mat tu", _no_word_lost("Bạn đánh Cô Tư −12 HP.", wrapped))


func _test_case_empty() -> void:
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối")
	var wrapped: Dictionary = scene.bottom_action_lines("")
	_check("rong: 0 dong", (wrapped["lines"] as PackedStringArray).size() == 0)


func _test_panel_geometry() -> void:
	# Dong 1 (baseline 1078) nam duoi tieu de "Tran da ket thuc." o
	# y=1036 co 26, dong cuoi (toi da 2 dong) nam tren nut y=1120.
	var scene := _new_scene(_new_mb(), "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài")
	_finish(scene, "Đội Chợ Đầu Mối Siêu Dài Tên Thật Dài", 10, 50, 34)
	var wrapped: Dictionary = scene.bottom_action_lines(scene.result_text())
	var n := (wrapped["lines"] as PackedStringArray).size()
	_check("hinh hoc: dong 1 duoi tieu de", BattleScene.BOTTOM_TEXT_FIRST_Y > 1042.0)
	_check("hinh hoc: dong cuoi <= 1110", _last_baseline(wrapped) <= 1110.0,
		"last_y=%.0f dong=%d" % [_last_baseline(wrapped), n])
	_check("hinh hoc: 2 dong cach nhau 28px", BattleScene.BOTTOM_TEXT_LINE_H == 28.0)
