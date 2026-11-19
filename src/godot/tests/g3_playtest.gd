extends SceneTree
## G3 playtest — chay scene Main that headless, mo phong choi that chuoi 1-2-3-4-5-6-7-8:
##   godot --headless --path src/godot -s res://tests/g3_playtest.gd
## Buoc: Map001 -> cua (5,4) sang Map002 -> cua MOI (5,8) sang Map003 (ADDED_DOORS)
## -> noi chuyen Anh Ba -> cua (5,8) sang Map004 -> noi chuyen Bac Tai
## -> cua (5,8) sang Map005 -> noi chuyen Thay Giao -> cua (5,8) sang Map006
## -> noi chuyen Cu Dan Chung Cu -> cua (5,8) sang Map007 -> noi chuyen
## Nhan Vien Van Phong -> cua (5,8) sang Map008 -> noi chuyen Cu Dan Cao Cap
## -> cua (5,8) di Map009 (chua port) BI CHAN, van o Map008
## -> di nguoc ve Map001 qua cac cua (5,4).

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

func _step_down_into_door() -> void:
	# Player dang dung o (5,7); buoc xuong 1 o vao cua (5,8).
	_main.player._try_step(Vector2i(0, 1))

func _on_frame() -> void:
	_frame += 1
	if _frame > 900:
		print("G3 PLAYTEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("bat dau Map001", _main.current_map_id == 1)
				_check("player o (4,5) nhu System.json", _main.player.tile == Vector2i(4, 5))
				_main.player.place(_main.iso_map, Vector2i(5, 3))
				_main.player._try_step(Vector2i(0, 1))
				_state = 1
		1:
			if not _main.player._moving:
				_check("buoc vao cua -> sang Map002", _main.current_map_id == 2)
				_check("spawn o cua Map002 (5,4)", _main.player.tile == Vector2i(5, 4))
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 2
		2:
			if not _main.player._moving:
				_check("cua MOI (5,8) Map002 -> sang Map003", _main.current_map_id == 3)
				_check("spawn o cua Map003 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc: Dictionary = _main.iso_map.event_at(Vector2i(4, 6))
				_check("NPC Anh Ba o (4,6)", String(npc.get("name", "")) == "Anh Ba")
				_main._interact(npc)
				_check("mo doi thoai Anh Ba", _main.dialogue_open)
				_main.close_dialogue()
				_check("dong doi thoai", not _main.dialogue_open)
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 3
		3:
			if not _main.player._moving:
				_check("cua (5,8) Map003 -> sang Map004", _main.current_map_id == 4)
				_check("spawn o cua Map004 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc2: Dictionary = _main.iso_map.event_at(Vector2i(3, 2))
				_check("NPC Bac Tai o (3,2)", String(npc2.get("name", "")) == "Bác Tài")
				_main._interact(npc2)
				_check("mo doi thoai Bac Tai", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 4
		4:
			if not _main.player._moving:
				_check("cua (5,8) Map004 -> sang Map005", _main.current_map_id == 5)
				_check("spawn o cua Map005 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc3: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Thay Giao o (3,3)", String(npc3.get("name", "")) == "Thầy Giáo")
				_main._interact(npc3)
				_check("mo doi thoai Thay Giao", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 5
		5:
			if not _main.player._moving:
				_check("cua (5,8) Map005 -> sang Map006", _main.current_map_id == 6)
				_check("spawn o cua Map006 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc4: Dictionary = _main.iso_map.event_at(Vector2i(3, 6))
				_check("NPC Cu Dan Chung Cu o (3,6)", String(npc4.get("name", "")) == "Cư Dân Chung Cư")
				_main._interact(npc4)
				_check("mo doi thoai Cu Dan Chung Cu", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 6
		6:
			if not _main.player._moving:
				_check("cua (5,8) Map006 -> sang Map007", _main.current_map_id == 7)
				_check("spawn o cua Map007 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc5: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Nhan Vien Van Phong o (3,3)", String(npc5.get("name", "")) == "Nhân Viên Văn Phòng")
				_main._interact(npc5)
				_check("mo doi thoai Nhan Vien Van Phong", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 7
		7:
			if not _main.player._moving:
				_check("cua (5,8) Map007 -> sang Map008", _main.current_map_id == 8)
				_check("spawn o cua Map008 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc6: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Cu Dan Cao Cap o (3,3)", String(npc6.get("name", "")) == "Cư Dân Cao Cấp")
				_main._interact(npc6)
				_check("mo doi thoai Cu Dan Cao Cap", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 8
		8:
			if not _main.player._moving:
				_check("cua (5,8) Map008 di Map009 chua port: van o Map008",
					_main.current_map_id == 8)
				_check("player van o cua (5,8)", _main.player.tile == Vector2i(5, 8))
				_main._transfer(7)
				_state = 9
		9:
			_check("di nguoc ve Map007", _main.current_map_id == 7)
			_check("spawn o cua Map007 (5,4)", _main.player.tile == Vector2i(5, 4))
			_main._transfer(6)
			_check("di nguoc ve Map006", _main.current_map_id == 6)
			_main._transfer(5)
			_check("di nguoc ve Map005", _main.current_map_id == 5)
			_main._transfer(4)
			_check("di nguoc ve Map004", _main.current_map_id == 4)
			_check("spawn o cua Map004 (5,4)", _main.player.tile == Vector2i(5, 4))
			_main._transfer(3)
			_check("di nguoc ve Map003", _main.current_map_id == 3)
			_main._transfer(2)
			_check("di nguoc ve Map002", _main.current_map_id == 2)
			_check("spawn o cua Map002 (5,4) - cua ve, khong phai cua moi (5,8)",
				_main.player.tile == Vector2i(5, 4))
			_main._transfer(1)
			_check("di nguoc ve Map001", _main.current_map_id == 1)
			_state = 10
		10:
			print("G3 PLAYTEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
