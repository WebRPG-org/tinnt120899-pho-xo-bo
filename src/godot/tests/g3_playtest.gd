extends SceneTree
## G3 playtest — chay scene Main that headless, mo phong choi that chuoi 1-2-3-4-5-6-7-8-9-10-11-12-13-14-15-16-17-18:
##   godot --headless --path src/godot -s res://tests/g3_playtest.gd
## Buoc: Map001 -> cua (5,4) sang Map002 -> cua MOI (5,8) sang Map003 (ADDED_DOORS)
## -> noi chuyen Anh Ba -> cua (5,8) sang Map004 -> noi chuyen Bac Tai
## -> cua (5,8) sang Map005 -> noi chuyen Thay Giao -> cua (5,8) sang Map006
## -> noi chuyen Cu Dan Chung Cu -> cua (5,8) sang Map007 -> noi chuyen
## Nhan Vien Van Phong -> cua (5,8) sang Map008 -> noi chuyen Cu Dan Cao Cap
## -> cua (5,8) sang Map009 -> noi chuyen Chu Cua Hang -> cua (5,8) sang
## Map010 -> noi chuyen Lap Trinh Vien -> cua (5,8) sang Map011 -> noi
## chuyen Nhan Vien Le Tan -> cua (5,8) sang Map012 -> noi chuyen
## Bao Ve Biet Thu -> cua (5,8) sang Map013 -> noi chuyen Nhan Vien
## Ngan Hang -> cua (5,8) sang Map014 -> noi chuyen Quan Gia Dao
## -> cua MOI (5,8) sang Map015 (ADDED_DOORS, G3 buoc 5) -> noi chuyen
## Quan Ly Penthouse -> cua (5,8) sang Map016 -> noi chuyen Nhan Vien
## San Golf -> cua (5,8) sang Map017 -> noi chuyen Co Ban Banh
## -> cua (5,8) sang Map018 (map cuoi chuoi) -> noi chuyen Chu Sap Dem
## -> Map018 KHONG co cua di tiep: o (5,8) khong co event, buoc xuong van
## di duoc (o trong, lop 1 trong) nhung KHONG chuyen map, van o Map018
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
				_check("cua (5,8) Map008 -> sang Map009", _main.current_map_id == 9)
				_check("spawn o cua Map009 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc7: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Chu Cua Hang o (3,3)", String(npc7.get("name", "")) == "Chủ Cửa Hàng")
				_main._interact(npc7)
				_check("mo doi thoai Chu Cua Hang", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 9
		9:
			if not _main.player._moving:
				_check("cua (5,8) Map009 -> sang Map010", _main.current_map_id == 10)
				_check("spawn o cua Map010 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc8: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Lap Trinh Vien o (3,3)", String(npc8.get("name", "")) == "Lập Trình Viên")
				_main._interact(npc8)
				_check("mo doi thoai Lap Trinh Vien", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 10
		10:
			if not _main.player._moving:
				_check("cua (5,8) Map010 -> sang Map011", _main.current_map_id == 11)
				_check("spawn o cua Map011 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc9: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Nhan Vien Le Tan o (3,3)", String(npc9.get("name", "")) == "Nhân Viên Lễ Tân")
				_main._interact(npc9)
				_check("mo doi thoai Nhan Vien Le Tan", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 11
		11:
			if not _main.player._moving:
				_check("cua (5,8) Map011 -> sang Map012", _main.current_map_id == 12)
				_check("spawn o cua Map012 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc10: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Bao Ve Biet Thu o (3,3)", String(npc10.get("name", "")) == "Bảo Vệ Biệt Thự")
				_main._interact(npc10)
				_check("mo doi thoai Bao Ve Biet Thu", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 12
		12:
			if not _main.player._moving:
				_check("cua (5,8) Map012 -> sang Map013", _main.current_map_id == 13)
				_check("spawn o cua Map013 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc11: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Nhan Vien Ngan Hang o (3,3)", String(npc11.get("name", "")) == "Nhân Viên Ngân Hàng")
				_main._interact(npc11)
				_check("mo doi thoai Nhan Vien Ngan Hang", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 13
		13:
			if not _main.player._moving:
				_check("cua (5,8) Map013 -> sang Map014", _main.current_map_id == 14)
				_check("spawn o cua Map014 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc12: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Quan Gia Dao o (3,3)", String(npc12.get("name", "")) == "Quản Gia Đảo")
				_main._interact(npc12)
				_check("mo doi thoai Quan Gia Dao", _main.dialogue_open)
				_main.close_dialogue()
				# Map014 nay CO cua di tiep (cua MOI (5,8) them o G3 buoc 5).
				var fwd_door: Dictionary = _main.iso_map.event_at(Vector2i(5, 8))
				_check("cua moi Map014 la cua di Khu Penthouse",
					String(fwd_door.get("name", "")) == "Cửa đi Khu Penthouse" and int(fwd_door.get("to_map", 0)) == 15)
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 14
		14:
			if not _main.player._moving:
				_check("cua MOI (5,8) Map014 -> sang Map015", _main.current_map_id == 15)
				_check("spawn o cua Map015 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc13: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Quan Ly Penthouse o (3,3)", String(npc13.get("name", "")) == "Quản Lý Penthouse")
				_main._interact(npc13)
				_check("mo doi thoai Quan Ly Penthouse", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 15
		15:
			if not _main.player._moving:
				_check("cua (5,8) Map015 -> sang Map016", _main.current_map_id == 16)
				_check("spawn o cua Map016 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc14: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Nhan Vien San Golf o (3,3)", String(npc14.get("name", "")) == "Nhân Viên Sân Golf")
				_main._interact(npc14)
				_check("mo doi thoai Nhan Vien San Golf", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 16
		16:
			if not _main.player._moving:
				_check("cua (5,8) Map016 -> sang Map017", _main.current_map_id == 17)
				_check("spawn o cua Map017 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc15: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Co Ban Banh o (3,3)", String(npc15.get("name", "")) == "Cô Bán Bánh")
				_main._interact(npc15)
				_check("mo doi thoai Co Ban Banh", _main.dialogue_open)
				_main.close_dialogue()
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 17
		17:
			if not _main.player._moving:
				_check("cua (5,8) Map017 -> sang Map018", _main.current_map_id == 18)
				_check("spawn o cua Map018 (5,4)", _main.player.tile == Vector2i(5, 4))
				var npc16: Dictionary = _main.iso_map.event_at(Vector2i(3, 3))
				_check("NPC Chu Sap Dem o (3,3)", String(npc16.get("name", "")) == "Chủ Sạp Đêm")
				_main._interact(npc16)
				_check("mo doi thoai Chu Sap Dem", _main.dialogue_open)
				_main.close_dialogue()
				# Map018 la map cuoi chuoi: chi 1 cua ve Map017, khong co cua di tiep.
				var back_door: Dictionary = _main.iso_map.event_at(Vector2i(5, 4))
				_check("cua duy nhat Map018 la cua ve Cong Vien An Bình",
					String(back_door.get("name", "")) == "Cửa về Công Viên An Bình" and int(back_door.get("to_map", 0)) == 17)
				_check("o (5,8) Map018 khong co event cua", _main.iso_map.event_at(Vector2i(5, 8)).is_empty())
				_main.player.place(_main.iso_map, Vector2i(5, 7))
				_step_down_into_door()
				_state = 18
		18:
			if not _main.player._moving:
				_check("buoc vao (5,8) Map018 khong co cua: van o Map018",
					_main.current_map_id == 18)
				_check("player da buoc xuong (5,8)", _main.player.tile == Vector2i(5, 8))
				_main._transfer(17)
				_state = 19
		19:
			_check("di nguoc ve Map017", _main.current_map_id == 17)
			_check("spawn o cua Map017 (5,4)", _main.player.tile == Vector2i(5, 4))
			_main._transfer(16)
			_check("di nguoc ve Map016", _main.current_map_id == 16)
			_main._transfer(15)
			_check("di nguoc ve Map015", _main.current_map_id == 15)
			_main._transfer(14)
			_check("di nguoc ve Map014", _main.current_map_id == 14)
			_main._transfer(13)
			_check("di nguoc ve Map013", _main.current_map_id == 13)
			_main._transfer(12)
			_check("di nguoc ve Map012", _main.current_map_id == 12)
			_main._transfer(11)
			_check("di nguoc ve Map011", _main.current_map_id == 11)
			_main._transfer(10)
			_check("di nguoc ve Map010", _main.current_map_id == 10)
			_main._transfer(9)
			_check("di nguoc ve Map009", _main.current_map_id == 9)
			_main._transfer(8)
			_check("di nguoc ve Map008", _main.current_map_id == 8)
			_main._transfer(7)
			_state = 20
		20:
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
			_state = 21
		21:
			print("G3 PLAYTEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
