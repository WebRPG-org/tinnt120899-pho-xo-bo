extends SceneTree
## G4 R93 PLAYER ID test — chay headless, khong can trinh duyet hay server that:
##   godot --headless --script tests/g4_r93_player_id_test.gd
## (chay tu thu muc src/godot)
## Kiem tra (Vong 93 — sua docs/godot-g4.md §114.4 muc 1): player_id WS
## ben qua reload trang — sinh moi khi trong, khoi phuc dung id da luu
## qua save/load round-trip (PxbSaveCloud slot 1) + qua file ben
## user://pxb_player_id.txt (gia lap reload: node moi khong tai save),
## khong sinh moi khi da co id, id cu van dung duoc sau khi tai save
## cu (khong co truong ws_player_id → sinh moi 1 lan roi luu).
## In "G4 R93 PLAYER ID TEST: n/n PASS".
## Test don file user:// no tao sau khi xong (khong de rac).

var _pass := 0
var _fail := 0

var _nodes: Array = [] # node da tao — free o cuoi de log sach (khong leak resource)


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	_delete_player_id_file()
	_delete_slot_files()
	_test_sinh_moi_khi_trong()
	_test_save_load_round_trip()
	_test_khong_sinh_moi_khi_da_co_id()
	_test_save_cu_khong_co_truong()
	_delete_player_id_file()
	_delete_slot_files()
	print("G4 R93 PLAYER ID TEST: %d/%d PASS" % [_pass, _pass + _fail])
	for n in _nodes:
		n.free()
	quit(0 if _fail == 0 else 1)


func _new_online() -> PxbOnline:
	var node := PxbOnline.new()
	_nodes.append(node)
	return node


func _new_cloud() -> PxbSaveCloud:
	var cloud := PxbSaveCloud.new()
	_nodes.append(cloud)
	return cloud


func _delete_player_id_file() -> void:
	if FileAccess.file_exists(PxbOnline.PLAYER_ID_FILE):
		DirAccess.remove_absolute(PxbOnline.PLAYER_ID_FILE)


func _delete_slot_files() -> void:
	for slot in [1, 2, 3]:
		var path := PxbSaveCloud.slot_path(slot)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _read_player_id_file() -> String:
	if not FileAccess.file_exists(PxbOnline.PLAYER_ID_FILE):
		return ""
	return FileAccess.get_file_as_string(PxbOnline.PLAYER_ID_FILE)


# Nhom A — sinh moi khi trong (chua tung co id, chua co file ben).
func _test_sinh_moi_khi_trong() -> void:
	var node := _new_online()
	_check("R93: node moi co ws_player_id rong",
		node.ws_player_id.is_empty())
	var id1 := node.ensure_ws_player_id()
	_check("R93: ensure sinh id moi khong rong, dang pxb-<ms>-<rand>",
		not id1.is_empty() and id1.begins_with("pxb-"), id1)
	_check("R93: ensure gan id vao node",
		node.ws_player_id == id1)
	_check("R93: id moi ghi ngay vao file ben",
		_read_player_id_file() == id1,
		"file='" + _read_player_id_file() + "' id='" + id1 + "'")
	var id2 := node.ensure_ws_player_id()
	_check("R93: ensure lan 2 tra dung id cu (khong sinh moi)",
		id2 == id1)


# Nhom B — khoi phuc dung id da luu qua save/load round-trip
# (PxbSaveCloud slot 1) + qua file ben (gia lap reload trang).
func _test_save_load_round_trip() -> void:
	var node := _new_online()
	var id_x := node.ensure_ws_player_id()
	_check("R93: data() mang dung ws_player_id",
		String(node.data().get("ws_player_id", "")) == id_x)
	var cloud := _new_cloud()
	var sys := {
		"pxb_time": {"game_day": 1},
		"pxb_online": node.data(),
	}
	var saved := cloud.save_to_local(1, sys)
	_check("R93: save slot 1 ok", bool(saved.get("ok", false)), str(saved))
	var loaded := cloud.load_from_local(1)
	_check("R93: load slot 1 ok", bool(loaded.get("ok", false)), str(loaded))
	var node2 := _new_online()
	var save_dict: Dictionary = loaded.get("save", {})
	var gs: Dictionary = save_dict.get("gameSystem", {})
	node2.from_data(gs.get("pxb_online", {}))
	_check("R93: load save khoi phuc dung id da luu",
		node2.ws_player_id == id_x,
		"node2='" + node2.ws_player_id + "' goc='" + id_x + "'")
	_check("R93: ensure sau load khong sinh moi",
		node2.ensure_ws_player_id() == id_x)
	# Gia lap reload trang: node moi toanh, KHONG tai save — chi
	# goi ensure nhu connect_ws() se goi khi bam noi.
	var node3 := _new_online()
	_check("R93: node moi sau reload khoi phuc id tu file ben",
		node3.ensure_ws_player_id() == id_x,
		"node3='" + node3.ws_player_id + "' goc='" + id_x + "'")


# Nhom C — khong sinh moi khi da co id (gan tay / truyen vao connect_ws).
func _test_khong_sinh_moi_khi_da_co_id() -> void:
	var node := _new_online()
	node.ws_player_id = "pxb-111-222"
	_check("R93: ensure giu nguyen id da co",
		node.ensure_ws_player_id() == "pxb-111-222")
	_check("R93: id gan tay duoc dong bo xuong file ben",
		_read_player_id_file() == "pxb-111-222")
	# connect_ws truyen id ro rang: dung id do (khong sinh moi),
	# cong dong van tao socket nhu test client cu (khong can server).
	var res := node.connect_ws("ws://127.0.0.1:9", "pxb-rieng-7", "An")
	_check("R93: connect_ws dung id truyen vao, khong sinh moi",
		bool(res.get("ok", false)) and String(res.get("player_id", "")) == "pxb-rieng-7",
		str(res))
	_check("R93: connect_ws luu id truyen vao xuong file ben",
		_read_player_id_file() == "pxb-rieng-7")
	_check("R93: noi lan 2 khi dang noi thi bi chan (khong doi id)",
		not bool(node.connect_ws().get("ok", false)))
	node.disconnect_ws()
	_check("R93: sau ngat, id van giu nguyen",
		node.ws_player_id == "pxb-rieng-7")


# Nhom D — save cu khong co truong ws_player_id: id cu van dung
# duoc; chi khi that su chua co id moi sinh moi 1 lan roi luu.
func _test_save_cu_khong_co_truong() -> void:
	var node := _new_online()
	node.ws_player_id = "pxb-cu-999"
	node.ensure_ws_player_id() # dong bo "pxb-cu-999" xuong file ben
	node.from_data({})
	_check("R93: from_data({}) giu id hien co",
		node.ws_player_id == "pxb-cu-999", node.ws_player_id)
	node.from_data({"ws_url": "ws://localhost:8765"})
	_check("R93: from_data thieu truong ws_player_id giu id hien co",
		node.ws_player_id == "pxb-cu-999", node.ws_player_id)
	node.from_data({"ws_player_id": ""})
	_check("R93: from_data ws_player_id rong giu id hien co",
		node.ws_player_id == "pxb-cu-999", node.ws_player_id)
	node.from_data({"ws_player_id": "x".repeat(100)})
	_check("R93: from_data ws_player_id qua dai giu id hien co",
		node.ws_player_id == "pxb-cu-999", node.ws_player_id)
	# That su chua co id (file ben da xoa): sinh moi 1 lan roi luu.
	_delete_player_id_file()
	var node2 := _new_online()
	node2.from_data({"ws_display_name": "An"})
	_check("R93: tai save cu ma chua co id thi id van rong",
		node2.ws_player_id.is_empty())
	var id_z := node2.ensure_ws_player_id()
	_check("R93: sinh moi 1 lan khi that su chua co id",
		not id_z.is_empty() and id_z.begins_with("pxb-"), id_z)
	_check("R93: id moi sinh duoc luu vao file ben ngay",
		_read_player_id_file() == id_z)
	_check("R93: ensure lan sau tra dung id vua sinh",
		node2.ensure_ws_player_id() == id_z)
