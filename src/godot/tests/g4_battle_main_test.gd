extends SceneTree
## G4 BATTLE MAIN test — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_main_test.gd
## Kiem tra: phim B trong Main mo/dong scene tran demo 3v3 that
## (BattleScene tren CanvasLayer 2, khoa input map, an HUD); dong
## tran thi tra lai map + HUD; tran van chay duoc trong scene Main
## (dong ho luot tu chuyen khi het 10s). Cho theo thoi gian thuc
## (headless chay frame nhanh hon 60fps nen khong dem frame).
## In "G4 BATTLE MAIN TEST: n/n PASS".

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null
var _t0 := 0  # ms, moc bat dau cho dong ho luot


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


func _on_frame() -> void:
	_frame += 1
	if Time.get_ticks_msec() > 90000:
		print("G4 BATTLE MAIN TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("main chay duoc", _main.current_map_id == 1)
				_check("ban dau chua mo tran", not _main.battle_open)
				_main._on_start_pressed()
				_key_b()
				_state = 1
		1:
			if _frame >= 6:
				_check("phim B mo tran", _main.battle_open)
				_check("battle scene ton tai", _main.battle_scene != null)
				_check("battle scene dang danh", _main.battle_scene.is_fighting())
				_check("input map bi khoa", _main.player.input_blocked)
				_check("HUD an khi danh tran", not _main._ui_layer.visible)
				_check("doi ban 3 dau si", (_main.battle_scene.battle["teamA"]["fighters"] as Array).size() == 3)
				_check("doi cho 3 dau si", (_main.battle_scene.battle["teamB"]["fighters"] as Array).size() == 3)
				_t0 = Time.get_ticks_msec()
				_state = 2
		2:
			# Cho _process cua BattleScene chay dong ho 11s that:
			# luot phai tu chuyen khoi ban-1.
			if Time.get_ticks_msec() - _t0 >= 11500:
				_check("dong ho that: het 10s tu chuyen luot",
					str(_main.battle_scene.active_fighter().get("id", "")) != "ban-1",
					"active=%s" % str(_main.battle_scene.active_fighter().get("id", "")))
				_key_b()
				_state = 3
		3:
			_check("phim B dong tran", not _main.battle_open)
			_check("battle scene da free", _main.battle_scene == null)
			_check("input map mo lai", not _main.player.input_blocked)
			_check("HUD hien lai", _main._ui_layer.visible)
			_check("van o Map001 sau khi dong tran", _main.current_map_id == 1)
			print("G4 BATTLE MAIN TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
