extends SceneTree
## G1 playtest — chay scene Main that headless, mo phong choi that:
##   godot --headless --path src/godot -s res://tests/g1_playtest.gd
## Buoc: di chuyen -> qua cua sang Map002 -> nhat hotspot dung khung ->
## nhat lai (chan) -> doi khung -> nhat hotspot khung Chieu -> mo doi thoai
## NPC -> ve Map001 khung Toi -> nhat hotspot hs-tro-toi.

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 600:
		print("G1 PLAYTEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("bat dau Map001", _main.current_map_id == 1)
				_check("player o (4,5) nhu System.json", _main.player.tile == Vector2i(4, 5))
				_main.player._try_step(Vector2i(0, -1))
				_state = 1
		1:
			if not _main.player._moving:
				_check("di len 1 o -> (4,4)", _main.player.tile == Vector2i(4, 4))
				_main.player.place(_main.iso_map, Vector2i(5, 3))
				_main.player._try_step(Vector2i(0, 1))
				_state = 2
		2:
			if not _main.player._moving:
				_check("buoc vao cua -> sang Map002", _main.current_map_id == 2)
				_check("spawn o cua Map002 (5,4)", _main.player.tile == Vector2i(5, 4))
				var ev: Dictionary = _main.iso_map.event_at(Vector2i(3, 1))
				_main._collect_hotspot(ev)
				_check("nhat hs-cho-sang khung Sang: la-chuoi x2",
					int(_main.inventory.get("la-chuoi", 0)) == 2)
				_main._collect_hotspot(ev)
				_check("nhat lai cung ngay bi chan", int(_main.inventory.get("la-chuoi", 0)) == 2)
				_state = 3
		3:
			_main._advance_frame()
			_check("doi khung -> Chieu", _main.frame_idx == 1)
			var ev2: Dictionary = _main.iso_map.event_at(Vector2i(10, 2))
			_main._collect_hotspot(ev2)
			_check("nhat hs-cho-chieu khung Chieu: sat-vun x1",
				int(_main.inventory.get("sat-vun", 0)) == 1)
			_state = 4
		4:
			var npc: Dictionary = _main.iso_map.event_at(Vector2i(2, 2))
			_main._interact(npc)
			_check("mo doi thoai Chi Le", _main.dialogue_open)
			_main.close_dialogue()
			_check("dong doi thoai", not _main.dialogue_open)
			_state = 5
		5:
			_main._advance_frame()
			_check("doi khung -> Toi", _main.frame_idx == 2)
			_main._transfer(1)
			_check("ve Map001", _main.current_map_id == 1)
			var ev3: Dictionary = _main.iso_map.event_at(Vector2i(10, 3))
			_main._collect_hotspot(ev3)
			_check("nhat hs-tro-toi khung Toi: chai-nhua x2",
				int(_main.inventory.get("chai-nhua", 0)) == 2)
			_state = 6
		6:
			print("G1 PLAYTEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
