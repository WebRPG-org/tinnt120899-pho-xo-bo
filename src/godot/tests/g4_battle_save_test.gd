extends SceneTree
## G4 BATTLE SAVE test — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_save_test.gd
## Kiem tra (G4 buoc 5): ket thuc tran (thang/hoa/thua) -> Main ghi
## giu sap + lich su vao battle_state + cong Danh vong vao fame;
## save slot 1 -> load lai khoi phuc dung giu sap + fame; giu sap
## het han sau 7 ngay game (expire_holds / is_holding); from_data
## loai hold rac. In "G4 BATTLE SAVE TEST: n/n PASS".

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null
var _fame_before := 0
var _until_day := 0


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)


func _key_b() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_B
	ev.pressed = true
	ev.echo = false
	_main._unhandled_input(ev)


func _finish_current(winner: String) -> void:
	_main.battle_mb._finish_battle(_main.battle_scene.battle, winner)


func _holds() -> Dictionary:
	return (_main.battle_state.get("holds", {}) as Dictionary)


func _on_frame() -> void:
	_frame += 1
	if Time.get_ticks_msec() > 90000:
		print("G4 BATTLE SAVE TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("main chay duoc", _main.current_map_id == 1)
				_check("ban dau chua co giu sap", _holds().is_empty())
				_check("fame ban dau 0", _main.fame == 0)
				_main._on_start_pressed()
				_key_b()
				_state = 1
		1:
			if _frame >= 6:
				_check("phim B mo tran", _main.battle_open)
				_fame_before = _main.fame
				_finish_current("A")
				_state = 2
		2:
			if _frame >= 8:
				var holds := _holds()
				_check("thang: giu sap-cho-dau-moi",
					holds.has("sap-cho-dau-moi"),
					"holds=%s" % str(holds.keys()))
				var hold: Dictionary = holds.get("sap-cho-dau-moi", {})
				_check("thang: doi-ban giu sap",
					str(hold.get("teamId", "")) == "doi-ban",
					"hold=%s" % str(hold))
				_until_day = int(hold.get("untilGameDay", 0))
				_check("thang: giu 7 ngay game",
					_until_day == int(_main.day) + 7,
					"until=%d day=%d" % [_until_day, int(_main.day)])
				_check("thang: fame +50",
					_main.fame == _fame_before + 50,
					"fame=%d" % _main.fame)
				_check("thang: lich su 1 tran",
					(_main.battle_state.get("history", []) as Array).size() == 1)
				var res: Dictionary = _main.save_game(1)
				_check("save slot 1 ok", bool(res.get("ok", false)),
					"res=%s" % str(res))
				# Xoa trang state roi tai lai: kiem tra khoi phuc.
				_main.battle_state = {}
				_main.fame = 0
				_main.load_game(1)
				_state = 3
		3:
			if _frame >= 10:
				var holds := _holds()
				_check("load: giu sap khoi phuc",
					holds.has("sap-cho-dau-moi"))
				var hold: Dictionary = holds.get("sap-cho-dau-moi", {})
				_check("load: doi-ban giu den ngay cu",
					str(hold.get("teamId", "")) == "doi-ban"
					and int(hold.get("untilGameDay", 0)) == _until_day,
					"hold=%s" % str(hold))
				_check("load: fame khoi phuc 50", _main.fame == 50,
					"fame=%d" % _main.fame)
				_check("load: lich su khoi phuc 1 tran",
					(_main.battle_state.get("history", []) as Array).size() == 1)
				_key_b()
				_state = 4
		4:
			if _frame >= 12:
				_check("phim B dong tran sau load", not _main.battle_open)
				_key_b()
				_state = 5
		5:
			if _frame >= 15:
				_check("mo tran lai sau load", _main.battle_open)
				_fame_before = _main.fame
				_finish_current("hoa")
				_state = 6
		6:
			if _frame >= 17:
				_check("hoa: fame +20",
					_main.fame == _fame_before + 20,
					"fame=%d" % _main.fame)
				var hold: Dictionary = _holds().get("sap-cho-dau-moi", {})
				_check("hoa: giu sap khong doi chu",
					str(hold.get("teamId", "")) == "doi-ban",
					"hold=%s" % str(hold))
				_check("hoa: lich su 2 tran",
					(_main.battle_state.get("history", []) as Array).size() == 2)
				_key_b()
				_state = 7
		7:
			if _frame >= 20:
				_check("dong tran sau hoa", not _main.battle_open)
				_key_b()
				_state = 8
		8:
			if _frame >= 23:
				_check("mo tran lan 3", _main.battle_open)
				_fame_before = _main.fame
				_finish_current("B")
				_state = 9
		9:
			if _frame >= 25:
				_check("thua: fame +10",
					_main.fame == _fame_before + 10,
					"fame=%d" % _main.fame)
				var hold: Dictionary = _holds().get("sap-cho-dau-moi", {})
				_check("thua: doi-cho giu sap thay doi-ban",
					str(hold.get("teamId", "")) == "doi-cho",
					"hold=%s" % str(hold))
				_check("thua: lich su 3 tran",
					(_main.battle_state.get("history", []) as Array).size() == 3)
				# Het han: truoc untilGameDay thi con giu, den ngay do thi het.
				_check("het han: con giu truoc ngay het",
					PxbMarketBattle.is_holding(_main.battle_state,
						"sap-cho-dau-moi", _until_day - 1))
				_check("het han: het giu dung ngay het",
					not PxbMarketBattle.is_holding(_main.battle_state,
						"sap-cho-dau-moi", _until_day))
				var removed: int = PxbMarketBattle.expire_holds(
					_main.battle_state, _until_day)
				_check("het han: expire don 1 sap", removed == 1,
					"removed=%d" % removed)
				_check("het han: holds rong sau expire", _holds().is_empty())
				# from_data loai hold rac (thieu teamId / ngay).
				var mb := PxbMarketBattle.new()
				mb.from_data({"holds": {
					"sap-rac": {"teamName": "Khong ro"},
					"sap-tot": {"teamId": "doi-ban", "teamName": "Đội Bạn",
						"startGameDay": 1, "untilGameDay": 8},
				}, "history": [{"result": "A"}, {"khong-co-result": 1}]})
				var clean: Dictionary = mb.data()
				_check("from_data: loai hold rac, giu hold tot",
					(clean.get("holds", {}) as Dictionary).size() == 1
					and (clean["holds"] as Dictionary).has("sap-tot"),
					"holds=%s" % str((clean.get("holds", {}) as Dictionary).keys()))
				_check("from_data: lich su chi giu entry co result",
					(clean.get("history", []) as Array).size() == 1)
				mb.free()
				_key_b()
				_state = 10
		10:
			if _frame >= 27:
				_check("dong tran cuoi", not _main.battle_open)
				print("G4 BATTLE SAVE TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
