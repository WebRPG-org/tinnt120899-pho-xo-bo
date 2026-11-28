extends SceneTree
## G4 R95 HOLD SERVER DAY test — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_r95_hold_server_day_test.gd
## Kiem tra (Vong 95 — neo cua so hold theo ngay server, docs/godot-g4.md §115.4 muc 1):
## (A) reanchor_hold_window thuan: [1,8) neo ve 17 -> [17,24), giu stall/team;
##     hold rong / thieu stall / neo < 1 -> {}.
## (B) Main + PxbServer that qua loopback 127.0.0.1: thang offline -> hold [1,8);
##     noi server ngay 17 -> hold cu duoc gui len server (server xet han, vong 81)
##     -> ack het-han-giu-sap + toast + hold cu bi don; mo tran moi -> thang
##     -> hold local [17,24), toast "den ngay 24", quyen loi -10% con, server
##     chap nhan (ack ok, discount 10, holds tren server co entry [17,24))
##     -> mua dien-thoai-cu qua server duoc gia si -10% (tra 4.500.000 thay vi
##     5.000.000, vi 10M -> 5,5M) -> mo tran lai bi chan (dang giu sap den ngay 24).
## In "G4 R95 HOLD SERVER DAY TEST: n/n PASS".

const TEST_PORT := 18796
const SERVER_DAY := 17
const PHASE_TIMEOUT_MS := 15000
const GLOBAL_TIMEOUT_MS := 150000

var _pass := 0
var _fail := 0
var _server: PxbServer = null
var _main: Node = null
var _frame := 0
var _phase := 0
var _phase_deadline_ms := 0
var _started_ms := 0
var _finished := false


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _holds() -> Dictionary:
	return (_main.battle_state.get("holds", {}) as Dictionary)


func _hold() -> Dictionary:
	return (_holds().get("sap-cho-dau-moi", {}) as Dictionary)


func _key_b() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_B
	ev.pressed = true
	ev.echo = false
	_main._unhandled_input(ev)


func _finish_current(winner: String) -> void:
	_main.battle_mb._finish_battle(_main.battle_scene.battle, winner)


func _server_hold() -> Dictionary:
	return (_server.holds.get("player-r95", {}) as Dictionary)


func _server_owned() -> Dictionary:
	var entry: Dictionary = (_server.ledger.get("player-r95", {}) as Dictionary)
	return (entry.get("owned", {}) as Dictionary)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	if _main != null:
		_main.queue_free()
	if _server != null:
		_server.stop_server()
		_server.queue_free()
	print("G4 R95 HOLD SERVER DAY TEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	# (A) Thuan: reanchor_hold_window.
	_check("reanchor: [1,8) ve 17 -> [17,24)",
		PxbMarketBattle.reanchor_hold_window(
			{"stallId": "sap-cho-dau-moi", "teamId": "doi-ban", "teamName": "Đội Bạn",
				"startGameDay": 1, "untilGameDay": 8}, 17)
		== {"stallId": "sap-cho-dau-moi", "teamId": "doi-ban", "teamName": "Đội Bạn",
			"startGameDay": 17, "untilGameDay": 24})
	_check("reanchor: hold rong -> {}",
		PxbMarketBattle.reanchor_hold_window({}, 17).is_empty())
	_check("reanchor: thieu stallId -> {}",
		PxbMarketBattle.reanchor_hold_window(
			{"teamId": "doi-ban", "startGameDay": 1, "untilGameDay": 8}, 17).is_empty())
	_check("reanchor: neo < 1 -> {}",
		PxbMarketBattle.reanchor_hold_window(
			{"stallId": "sap-cho-dau-moi", "teamId": "doi-ban",
				"startGameDay": 1, "untilGameDay": 8}, 0).is_empty())
	_check("reanchor: giu nguyen doi thang B",
		PxbMarketBattle.reanchor_hold_window(
			{"stallId": "sap-x", "teamId": "doi-cho", "teamName": "Đội Chợ",
				"startGameDay": 3, "untilGameDay": 10}, 20)
		== {"stallId": "sap-x", "teamId": "doi-cho", "teamName": "Đội Chợ",
			"startGameDay": 20, "untilGameDay": 27})
	# (B) Server that, ngay 17.
	_server = PxbServer.new()
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18796", bool(r.get("ok", false)), str(r))
	_server.debug_set_server_day(SERVER_DAY)
	_check("server ngay 17", _server.server_day() == SERVER_DAY,
		"day=%d" % _server.server_day())
	# Main that.
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)
	_phase = 0
	_phase_deadline_ms = _started_ms + PHASE_TIMEOUT_MS


func _process(_delta: float) -> bool:
	if _finished:
		return true
	_frame += 1
	# Poll tay cho chac (xem g4_online_ws_client_test.gd).
	if _server != null:
		_server.poll()
	if _main != null and _main.online != null:
		_main.online.poll_ws()
	var now := Time.get_ticks_msec()
	if now > _started_ms + GLOBAL_TIMEOUT_MS:
		_check("global timeout 150s (khong treo)", false,
			"phase=%d frame=%d" % [_phase, _frame])
		_finish()
		return true
	if now > _phase_deadline_ms:
		_check("phase %d xong truoc deadline" % _phase, false,
			"frame=%d" % _frame)
		_finish()
		return true
	match _phase:
		0:
			_phase0(now)
		1:
			_phase1(now)
		2:
			_phase2(now)
		3:
			_phase3(now)
		4:
			_phase4(now)
		5:
			_phase5(now)
		6:
			_phase6(now)
	return false


# Phase 0: Main san sang, thang OFFLINE -> hold [1,8) nhu cu.
func _phase0(now: int) -> void:
	if _frame < 3:
		return
	_check("main chay duoc, ngay local 1", _main.current_map_id == 1 and _main.day == 1)
	_check("offline: moc neo giu sap = ngay local 1", _main._hold_anchor_day() == 1)
	_check("offline: chua noi WS", not _main.online.is_ws_connected())
	_main._on_start_pressed()
	_key_b()
	_phase = 1
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase1(now: int) -> void:
	if not _main.battle_open:
		return
	_finish_current("A")
	_phase = 2
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase2(now: int) -> void:
	var hold := _hold()
	if hold.is_empty():
		return
	_check("offline thang: giu sap-cho-dau-moi", _holds().has("sap-cho-dau-moi"))
	_check("offline thang: hold [1,8) theo ngay local",
		int(hold.get("startGameDay", 0)) == 1 and int(hold.get("untilGameDay", 0)) == 8,
		"hold=%s" % str(hold))
	_check("offline thang: toast den ngay 8", "đến ngày 8" in _main._toast.text,
		"toast=%s" % _main._toast.text)
	_check("offline thang: fame +50", _main.fame == 50, "fame=%d" % _main.fame)
	# Tien de mua dien-thoai-cu sau (10M), dong bo vi truoc khi noi.
	_main.jobs.gold = 10000000
	_main._wallet_to_economy()
	# Dong tran (phim B) roi noi server ngay 17.
	_key_b()
	var rc: Dictionary = _main.online.connect_ws(
		"ws://127.0.0.1:%d" % TEST_PORT, "player-r95", "Test95")
	_check("connect_ws tao socket", bool(rc.get("ok", false)), str(rc))
	_phase = 3
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# Phase 3: cho welcome — biet ngay server 17; hold cu [1,8) duoc
# dong bo len server ngay khi biet ngay (theo hop dong vong 81:
# server moi xet han) -> ack het-han-giu-sap + toast + hold cu bi
# don khoi battle_state (vong 95: khong chan theo quyen loi nua).
func _phase3(now: int) -> void:
	if not _main.online.is_ws_connected():
		return
	var ack: Dictionary = _main.online.ws_last_hold_ack
	if ack.is_empty():
		return
	_check("noi WS sau welcome", true)
	_check("biet ngay server 17", _main.online.ws_server_day == SERVER_DAY,
		"ws_server_day=%d" % _main.online.ws_server_day)
	_check("moc neo giu sap doi sang ngay server 17",
		_main._hold_anchor_day() == SERVER_DAY,
		"anchor=%d" % _main._hold_anchor_day())
	_check("hold cu [1,8) gui len server, ack het-han-giu-sap",
		not bool(ack.get("ok", true))
		and String(ack.get("reason", "")) == "het-han-giu-sap",
		"ack=%s" % str(ack))
	_check("toast bao giu sap het han theo may chu",
		"hết hạn" in _main._toast.text, "toast=%s" % _main._toast.text)
	_check("hold cu het han bi don khoi battle_state", _holds().is_empty(),
		"holds=%s" % str(_holds()))
	_main.online.send_ws_ledger_sync()
	_phase = 4
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# Phase 4: vi 10M da len server -> mo tran moi, thang, hold neo ve [17,24).
func _phase4(now: int) -> void:
	if int(_main.online.ws_ledger_authoritative_money) != 10000000:
		return
	_check("vi 10M da dong bo len server", true)
	if not _main.battle_open:
		_key_b()
		return
	_finish_current("A")
	# Doi 1 frame cho _on_battle_finished + goi sync chay xong.
	_phase = 5
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# Phase 5: cho ack hold-sync, kiem tra hold 2 ben + mua gia si.
func _phase5(now: int) -> void:
	var ack: Dictionary = _main.online.ws_last_hold_ack
	if ack.is_empty() or not bool(ack.get("ok", false)):
		return
	var hold := _hold()
	_check("thang online: hold local [17,24)",
		int(hold.get("startGameDay", 0)) == 17 and int(hold.get("untilGameDay", 0)) == 24,
		"hold=%s" % str(hold))
	_check("thang online: toast den ngay 24", "đến ngày 24" in _main._toast.text,
		"toast=%s" % _main._toast.text)
	var ben: Dictionary = _main._hold_benefits_now()
	_check("thang online: quyen loi -10% con voi ngay local 1",
		not ben.is_empty() and int(ben.get("wholesaleDiscountPercent", 0)) == 10,
		"ben=%s" % str(ben))
	_check("thang online: server ack ok, discount 10",
		int(ack.get("discount_percent", 0)) == 10, "ack=%s" % str(ack))
	var sh := _server_hold()
	_check("thang online: server co hold [17,24)",
		int(sh.get("start_day", 0)) == 17 and int(sh.get("until_day", 0)) == 24,
		"server_hold=%s" % str(sh))
	_check("thang online: fame tong 100 (50 offline + 50 online)",
		_main.fame == 100, "fame=%d" % _main.fame)
	# Mua dien-thoai-cu: gia goc 5M, gia si -10% -> tra 4,5M.
	var res: Dictionary = _main.buy_item("dien-thoai-cu")
	_check("mua dien-thoai-cu: gui len server cho ack",
		bool(res.get("pending", false)), "res=%s" % str(res))
	_phase = 6
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


# Phase 6: cho ack mua -> vi 5,5M + toast gia si, roi B lai bi chan.
func _phase6(now: int) -> void:
	if not _main._pending_shop_buy.is_empty():
		return
	_check("mua xong: vi 10M -> 5,5M (tra 4,5M gia si)",
		_main.jobs.gold == 5500000, "gold=%d" % _main.jobs.gold)
	_check("mua xong: toast gia si -10% 4.500.000",
		"4.500.000" in _main._toast.text and "−10%" in _main._toast.text,
		"toast=%s" % _main._toast.text)
	_check("mua xong: server ghi owned dien-thoai-cu x1",
		int(_server_owned().get("dien-thoai-cu", 0)) == 1,
		"owned=%s" % str(_server_owned()))
	# Dong tran ket qua (B) roi mo lai -> bi chan vi dang giu sap.
	_key_b()
	_key_b()
	_check("dang giu sap den ngay 24 thi B khong mo tran moi",
		not _main.battle_open, "battle_open=%s" % str(_main.battle_open))
	_check("chan mo tran: toast bao da giu den ngay 24",
		"đến ngày 24" in _main._toast.text, "toast=%s" % _main._toast.text)
	_finish()
