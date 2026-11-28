extends SceneTree
## G4 R93 DOUBLE-CLICK TEST: 1 click chuot vao nut "Ket thuc luot"
## khong duoc goi end_turn_now 2 lan.
## Goc: project bat emulate_touch_from_mouse=true nen 1 click chuot
## sinh CA InputEventMouseButton LAN InputEventScreenTouch; truoc V93
## _unhandled_input goi click_screen 2 lan — click "Ket thuc luot"
## thu 2 bo qua luon luot dich vua toi (A -> B -> A ke trong cung 1
## khung, B dung yen ca tran — probe trinh duyet r93b). Sua: chan
## click lap cung vi tri trong 300ms (battle_scene.gd).

const BattleScene = preload("res://scripts/battle_scene.gd")
const MB = preload("res://scripts/pxb_marketbattle.gd")

var _mb: PxbMarketBattle
var _scene: BattleScene
var _passes := 0
var _fails := 0


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_passes += 1
		print("  PASS ", name)
	else:
		_fails += 1
		print("  FAIL ", name, " :: ", detail)


func _make_battle() -> void:
	if _scene != null:
		_scene.queue_free()
		_scene = null
	_mb = PxbMarketBattle.new()
	# Team A nhu Main mo tran demo (main.gd ~922).
	var team_a := {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("ban-1", "Bạn", "Do", "Chao", {"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-2", "Bạn Thân", "Xanh", "CaKho", {"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-3", "Cô Tư", "Vang", "Loa", {"the": 40, "tri": 50, "tam": 80}, []),
	]}
	var team_b: Dictionary = PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3)
	var res: Dictionary = _mb.create_battle({"teamA": team_a, "teamB": team_b,
		"stallId": "sap-cho-dau-moi", "gameDay": 1, "defenderTeam": "B"})
	assert(bool(res.get("ok", false)))
	_mb.set_current_battle(res["battle"])
	_scene = BattleScene.new()
	root.add_child(_scene)
	_scene.setup(_mb, res["battle"], null, null)
	_scene.ai_enabled = true


func _mouse_click(pos: Vector2) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = pos
	_scene._unhandled_input(ev)


func _touch_click(pos: Vector2) -> void:
	var ev := InputEventScreenTouch.new()
	ev.index = 0
	ev.pressed = true
	ev.position = pos
	_scene._unhandled_input(ev)


func _end_turn_click(double: bool) -> void:
	_mouse_click(Vector2(181, 1155))
	if double:
		_touch_click(Vector2(181, 1155))


func _init() -> void:
	print("G4 R93 DOUBLE-CLICK TEST")
	# --- Tran 1: click DON (chi chuot) — doi chieu ---
	_make_battle()
	_check("luot dau la ban-1", str(_scene.battle.get("activeFighterId", "")) == "ban-1",
		str(_scene.battle.get("activeFighterId", "")))
	_scene.click_screen(_scene.tile_center(Vector2i(2, 4)))
	_end_turn_click(false)
	_check("click chuot DON: luot sang B1 (doi-cho-npc-1)",
		str(_scene.battle.get("activeFighterId", "")) == "doi-cho-npc-1",
		str(_scene.battle.get("activeFighterId", "")))
	_scene.simulate_seconds(3.0)
	var b1: Dictionary = _mb.find_fighter(_scene.battle, "doi-cho-npc-1")
	_check("B1 da di khoi (11,3) sau 3s (chi chuot)",
		int(b1.get("x", -1)) != 11 or int(b1.get("y", -1)) != 3,
		"B1@(%d,%d)" % [int(b1.get("x", -1)), int(b1.get("y", -1))])
	_check("sau B1 la ban-2",
		str(_scene.battle.get("activeFighterId", "")) == "ban-2",
		str(_scene.battle.get("activeFighterId", "")))

	# --- Tran 2: click KEP (chuot + touch gia lap) — loi cu ---
	_make_battle()
	_scene.click_screen(_scene.tile_center(Vector2i(2, 4)))
	_end_turn_click(true)
	_check("click KEP: luot DUNG o B1, khong nhay qua sang ban-2",
		str(_scene.battle.get("activeFighterId", "")) == "doi-cho-npc-1",
		str(_scene.battle.get("activeFighterId", "")))
	_check("click KEP: last_action la 'Het luot — toi Tieu thuong'",
		str(_scene.battle_status().get("last_action", "")).begins_with("Hết lượt — tới Tiểu thương"),
		str(_scene.battle_status().get("last_action", "")))
	_scene.simulate_seconds(3.0)
	var b1b: Dictionary = _mb.find_fighter(_scene.battle, "doi-cho-npc-1")
	_check("click KEP: B1 da di khoi (11,3) sau 3s",
		int(b1b.get("x", -1)) != 11 or int(b1b.get("y", -1)) != 3,
		"B1@(%d,%d)" % [int(b1b.get("x", -1)), int(b1b.get("y", -1))])
	_check("click KEP: sau B1 la ban-2",
		str(_scene.battle.get("activeFighterId", "")) == "ban-2",
		str(_scene.battle.get("activeFighterId", "")))
	# --- Click khac vi tri ngay sau do van qua (debounce khong chan) ---
	_mouse_click(_scene.tile_center(Vector2i(4, 3)))
	var b2: Dictionary = _mb.find_fighter(_scene.battle, "ban-2")
	_check("click khac vi tri ngay sau: ban-2 di duoc toi (4,3)",
		int(b2.get("x", -1)) == 4 and int(b2.get("y", -1)) == 3,
		"ban-2@(%d,%d)" % [int(b2.get("x", -1)), int(b2.get("y", -1))])
	print("G4 R93 DOUBLE-CLICK TEST: %d/%d PASS" % [_passes, _passes + _fails])
	quit(1 if _fails > 0 else 0)
