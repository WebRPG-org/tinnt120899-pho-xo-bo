extends SceneTree
## G4 ONLINE WS CLIENT selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_online_ws_client_test.gd
## Kiem tra: PxbOnline (G4 buoc 7) — client WebSocket that noi
## PxbServer qua loopback 127.0.0.1, hello + welcome + presence 2
## nguoi, chat A -> B nhan + A nhan echo, B ngat thi presence ve 1
## nguoi, gui chat khi chua noi / chat rong / chat qua 500 ky tu deu
## bi chan o client (khong toi server), noi cong dong thi khong
## ket noi, data()/from_data() giu ws_url + chat log, reset_state
## ngat WS. Socket la that (khong stub), server la PxbServer that.
## In "G4 ONLINE WS CLIENT TEST: n/n PASS".

const TEST_PORT := 18767
const BAD_PORT := 18768
const PHASE_TIMEOUT_MS := 8000
const GLOBAL_TIMEOUT_MS := 60000

var _pass := 0
var _fail := 0
var _server: PxbServer = null
var _ca: PxbOnline = null
var _cb: PxbOnline = null
var _cc: PxbOnline = null
var _phase := 0
var _step := 0
var _phase_deadline_ms := 0
var _wait_until_ms := 0
var _mark_log_b := 0
var _mark_chat_server := 0
var _started_ms := 0
var _finished := false


func _check(test_name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", test_name)
	else:
		_fail += 1
		print("  FAIL ", test_name, " ", detail)


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	_check("const: ws url mac dinh 8765", PxbOnline.DEFAULT_WS_URL == "ws://localhost:8765")
	_check("const: ws protocol v1", PxbOnline.WS_PROTOCOL_VERSION == 1)
	_check("const: ws chat toi da 500", PxbOnline.WS_MAX_CHAT_LEN == 500)
	_server = PxbServer.new()
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18767", bool(r.get("ok", false)), str(r))
	_ca = PxbOnline.new()
	root.add_child(_ca)
	_cb = PxbOnline.new()
	root.add_child(_cb)
	var ra: Dictionary = _ca.connect_ws("ws://127.0.0.1:%d" % TEST_PORT, "player-a", "An")
	_check("client A connect_ws tao socket", bool(ra.get("ok", false)), str(ra))
	var rb: Dictionary = _cb.connect_ws("ws://127.0.0.1:%d" % TEST_PORT, "player-b", "Bình")
	_check("client B connect_ws tao socket", bool(rb.get("ok", false)), str(rb))
	_check("A noi lan 2 thi bi chan", not bool(_ca.connect_ws().get("ok", false)))
	_cc = PxbOnline.new()
	root.add_child(_cc)
	var rc: Dictionary = _cc.connect_ws("ws://127.0.0.1:%d" % BAD_PORT, "player-c", "Chi")
	_check("client C connect_ws cong dong van tao socket", bool(rc.get("ok", false)), str(rc))
	_check("luc dau A chua ws_connected", not _ca.is_ws_connected())
	_check("gui chat khi chua noi thi loi", String(_ca.send_ws_chat("alo").get("reason", "")) == "chua-ket-noi-ws")
	_phase = 0
	_phase_deadline_ms = _started_ms + PHASE_TIMEOUT_MS


func _process(_delta: float) -> bool:
	if _finished:
		return true
	# Poll tay cho chac (xem g4_online_server_test.gd): node
	# _process co the khong chay khi SceneTree script override
	# _process; poll 2 lan/frame khong sao.
	_server.poll()
	_ca.poll_ws()
	_cb.poll_ws()
	_cc.poll_ws()
	var now := Time.get_ticks_msec()
	if now > _started_ms + GLOBAL_TIMEOUT_MS:
		_check("global timeout 60s (khong treo)", false,
			"phase=%d step=%d" % [_phase, _step])
		_finish()
		return true
	if now > _phase_deadline_ms:
		_check("phase %d xong truoc deadline" % _phase, false,
			"step=%d" % _step)
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
	return false


func _phase0(now: int) -> void:
	if _ca.is_ws_connected() and _cb.is_ws_connected():
		_check("A ws_connected sau welcome", true)
		_check("B ws_connected sau welcome", true)
		_check("A co peer_id > 0", _ca.ws_peer_id > 0)
		_check("A thay 2 nguoi online", _ca.ws_players.size() == 2)
		_check("B thay 2 nguoi online", _cb.ws_players.size() == 2)
		_check("server dem 2 nguoi choi", _server.player_count() == 2)
		_check("A status text co 2 nguoi", "2 người" in _ca.ws_status_text())
		_check("C cong dong khong ket noi", not _cc.is_ws_connected())
		_mark_log_b = _cb.ws_chat_log.size()
		_mark_chat_server = _server.chat_log.size()
		var res: Dictionary = _ca.send_ws_chat("HELLO-WS-CLIENT")
		_check("A gui chat ok", bool(res.get("ok", false)), str(res))
		_phase = 1
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase1(now: int) -> void:
	var chat_b := _find_chat(_cb.ws_chat_log, "HELLO-WS-CLIENT")
	var chat_a := _find_chat(_ca.ws_chat_log, "HELLO-WS-CLIENT")
	if chat_b.is_empty() or chat_a.is_empty():
		return
	_check("B nhan chat cua A", true)
	_check("chat B ghi dung player_id", String(chat_b.get("player_id", "")) == "player-a")
	_check("chat B ghi dung ten", String(chat_b.get("name", "")) == "An")
	_check("A nhan echo chat cua minh", true)
	_check("log B tang 1 tin", _cb.ws_chat_log.size() == _mark_log_b + 1)
	_check("server chi co 1 tin chat", _server.chat_log.size() == _mark_chat_server + 1)
	_check("phone text B co tin chat", "HELLO-WS-CLIENT" in _cb.ws_phone_text())
	_check("phone text B co ten An", "An" in _cb.ws_phone_text())
	_cb.disconnect_ws()
	_phase = 2
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase2(now: int) -> void:
	if _ca.ws_players.size() != 1:
		return
	_check("B roi: A thay 1 nguoi", true)
	_check("nguoi con lai la player-a",
		String((_ca.ws_players[0] as Dictionary).get("player_id", "")) == "player-a")
	_check("server dem 1 nguoi choi", _server.player_count() == 1)
	_check("B sau ngat thi het ws_connected", not _cb.is_ws_connected())
	_check("B gui chat sau ngat thi loi", String(_cb.send_ws_chat("alo").get("reason", "")) == "chua-ket-noi-ws")
	_phase = 3
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase3(now: int) -> void:
	# Loi o client: chat rong / qua dai bi chan truoc khi gui —
	# server khong nhan them tin nao.
	var before := _server.chat_log.size()
	_check("chat rong bi chan", String(_ca.send_ws_chat("   ").get("reason", "")) == "chat-trong")
	var long_text := ""
	for i in 501:
		long_text += "x"
	_check("chat 501 ky tu bi chan", String(_ca.send_ws_chat(long_text).get("reason", "")) == "chat-qua-dai")
	_check("chat loi khong toi server", _server.chat_log.size() == before)
	_check("chat 500 ky tu van gui duoc", bool(_ca.send_ws_chat(long_text.substr(0, 500)).get("ok", false)))
	_wait_until_ms = now + 800
	_step = 0
	_phase = 4
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase4(now: int) -> void:
	if now < _wait_until_ms:
		return
	match _step:
		0:
			var chat_a := _find_chat(_ca.ws_chat_log, "x".repeat(500))
			_check("chat 500 ky tu toi A (echo)", not chat_a.is_empty())
			# data()/from_data(): giu ws_url + id + ten + log chat.
			var d := _ca.data()
			_check("data giu ws_url", String(d.get("ws_url", "")) == "ws://127.0.0.1:%d" % TEST_PORT)
			_check("data giu ws_player_id", String(d.get("ws_player_id", "")) == "player-a")
			var d2 := PxbOnline.new()
			d2.from_data(d)
			_check("from_data khoi phuc ws_url", d2.ws_url == "ws://127.0.0.1:%d" % TEST_PORT)
			_check("from_data khoi phuc ws_player_id", d2.ws_player_id == "player-a")
			_check("from_data khoi phuc ten", d2.ws_display_name == "An")
			_check("from_data khoi phuc log chat", not _find_chat(d2.ws_chat_log, "HELLO-WS-CLIENT").is_empty())
			d2.free()
			# Du lieu ban: ten dai -> cat 30; tin chat qua dai -> bo.
			var d3 := PxbOnline.new()
			d3.from_data({
				"ws_display_name": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
				"ws_chat_log": [{"player_id": "x", "name": "Y", "text": "ok"},
					{"player_id": "x", "name": "Y", "text": "y".repeat(501)},
					{"player_id": "x", "name": "", "text": "thieu ten"}],
			})
			_check("from_data cat ten ve 30", d3.ws_display_name.length() == 30)
			_check("from_data chi giu tin chat hop le", d3.ws_chat_log.size() == 1)
			d3.free()
			_step = 1
			_wait_until_ms = now + 200
		1:
			# reset_state ngat WS + xoa log. Bye gui bat dong bo —
			# cho server poll xong (1 frame sau) roi moi kiem dem.
			_ca.reset_state()
			_check("reset_state ngat WS", not _ca.is_ws_connected())
			_check("reset_state xoa log chat", _ca.ws_chat_log.is_empty())
			_check("reset_state ve ws_url mac dinh", _ca.ws_url == PxbOnline.DEFAULT_WS_URL)
			_step = 2
			_wait_until_ms = now + 800
		2:
			_check("server chi con 0 nguoi (A reset)", _server.player_count() == 0)
			_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	print("G4 ONLINE WS CLIENT TEST: %d/%d PASS" % [_pass, _pass + _fail])
	_server.stop_server()
	quit(0 if _fail == 0 else 1)


func _find_chat(log: Array, text: String) -> Dictionary:
	for m in log:
		if m is Dictionary and String(m.get("text", "")) == text:
			return m
	return {}
