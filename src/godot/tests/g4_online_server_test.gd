extends SceneTree
## G4 ONLINE SERVER selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_online_server_test.gd
## Kiem tra: PxbServer (G4 buoc 6) — mo cong / cong sai / cong trung,
## 2 client WebSocket that noi qua loopback 127.0.0.1, hello + welcome
## + presence 2 nguoi, chat A -> B nhan + A nhan echo, B ngat ket noi
## thi presence ve 1 nguoi, client C chat khi chua hello / goi sai
## JSON / type la / chat rong deu bi bo khong toi A, ten dai 40 ky tu
## cat ve 30, server van chay + dem dung. Socket la that (khong stub).
## In "G4 ONLINE SERVER TEST: n/n PASS".

const TEST_PORT := 18765
const PHASE_TIMEOUT_MS := 8000
const GLOBAL_TIMEOUT_MS := 40000

var _pass := 0
var _fail := 0
var _server: PxbServer = null
var _ca: WebSocketMultiplayerPeer = null
var _cb: WebSocketMultiplayerPeer = null
var _cc: WebSocketMultiplayerPeer = null
var _inbox_a: Array = []
var _inbox_b: Array = []
var _inbox_c: Array = []
var _phase := 0
var _step := 0
var _phase_deadline_ms := 0
var _wait_until_ms := 0
var _mark_a := 0
var _mark_dropped := 0
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
	_check("const: cong mac dinh 8765", PxbServer.DEFAULT_PORT == 8765)
	_check("const: protocol v1", PxbServer.PROTOCOL_VERSION == 1)
	_server = PxbServer.new()
	root.add_child(_server)
	var r: Dictionary = _server.start_server(TEST_PORT)
	_check("server mo cong 18765", bool(r.get("ok", false)), str(r))
	var s2 := PxbServer.new()
	var r2: Dictionary = s2.start_server(TEST_PORT)
	_check("server thu 2 cung cong thi loi", not bool(r2.get("ok", false)), str(r2))
	s2.free()
	var s3 := PxbServer.new()
	_check("cong 0 thi loi", not bool(s3.start_server(0).get("ok", false)))
	_check("cong 70000 thi loi", not bool(s3.start_server(70000).get("ok", false)))
	s3.free()
	_check("luc dau 0 nguoi choi", _server.player_count() == 0)
	_check("luc dau presence rong", _server.presence_list().is_empty())
	_ca = WebSocketMultiplayerPeer.new()
	_cb = WebSocketMultiplayerPeer.new()
	_check("client A tao ket noi", _ca.create_client("ws://127.0.0.1:%d" % TEST_PORT) == OK)
	_check("client B tao ket noi", _cb.create_client("ws://127.0.0.1:%d" % TEST_PORT) == OK)
	_phase = 0
	_phase_deadline_ms = _started_ms + PHASE_TIMEOUT_MS


func _process(_delta: float) -> bool:
	if _finished:
		return true
	# Tu poll server (node _process co the khong chay khi script
	# SceneTree nay override _process — poll tay thi chac chan).
	_server.poll()
	_drain(_ca, _inbox_a)
	_drain(_cb, _inbox_b)
	if _cc != null:
		_drain(_cc, _inbox_c)
	var now := Time.get_ticks_msec()
	if now > _started_ms + GLOBAL_TIMEOUT_MS:
		_check("global timeout 40s (khong treo)", false,
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
	if _ca.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED \
			and _cb.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_check("client A ket noi", true)
		_check("client B ket noi", true)
		_send(_ca, {"type": "hello", "protocol": 1, "player_id": "player-a", "name": "An"})
		_send(_cb, {"type": "hello", "protocol": 1, "player_id": "player-b", "name": "Bình"})
		_phase = 1
		_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase1(now: int) -> void:
	var wa := _find(_inbox_a, "welcome")
	var wb := _find(_inbox_b, "welcome")
	if wa.is_empty() or wb.is_empty():
		return
	_check("A nhan welcome, peer_id > 0", int(wa.get("peer_id", 0)) > 0)
	_check("welcome B co 2 nguoi choi", (wb.get("players", []) as Array).size() == 2)
	var pres_a := _find_presence(_inbox_a, 2)
	_check("A nhan presence 2 nguoi choi", not pres_a.is_empty())
	_check("server dem 2 nguoi choi", _server.player_count() == 2)
	_send(_ca, {"type": "chat", "text": "Xin chào Chợ Đầu Mối"})
	_phase = 2
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase2(now: int) -> void:
	var chat_b := _find_chat(_inbox_b, "Xin chào Chợ Đầu Mối")
	var chat_a := _find_chat(_inbox_a, "Xin chào Chợ Đầu Mối")
	if chat_b.is_empty() or chat_a.is_empty():
		return
	_check("B nhan chat cua A", true)
	_check("chat ghi dung player_id", String(chat_b.get("player_id", "")) == "player-a")
	_check("chat ghi dung ten", String(chat_b.get("name", "")) == "An")
	_check("A nhan lai chat cua minh (broadcast)", true)
	_cb.close()
	_phase = 3
	_phase_deadline_ms = now + PHASE_TIMEOUT_MS


func _phase3(now: int) -> void:
	var pres := _find_presence(_inbox_a, 1)
	if pres.is_empty():
		return
	var plist: Array = pres.get("players", [])
	_check("B roi: A nhan presence 1 nguoi", plist.size() == 1)
	_check("nguoi con lai la player-a",
		String(plist[0].get("player_id", "")) == "player-a")
	_check("server dem 1 nguoi choi", _server.player_count() == 1)
	_cc = WebSocketMultiplayerPeer.new()
	_cc.create_client("ws://127.0.0.1:%d" % TEST_PORT)
	_step = 0
	_phase = 4
	_phase_deadline_ms = now + 15000


func _phase4(now: int) -> void:
	match _step:
		0:
			if _cc.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
				_check("client C ket noi", true)
				_mark_a = _inbox_a.size()
				_mark_dropped = _server.dropped_packets
				_send(_cc, {"type": "chat", "text": "chua hello"})
				_wait_until_ms = now + 500
				_step = 1
		1:
			if now < _wait_until_ms:
				return
			_check("chat khi chua hello bi bo", _server.dropped_packets > _mark_dropped)
			_check("chat chua hello khong toi A", _inbox_a.size() == _mark_a)
			_mark_dropped = _server.dropped_packets
			_cc.put_packet("khong-phai-json{".to_utf8_buffer())
			_wait_until_ms = now + 500
			_step = 2
		2:
			if now < _wait_until_ms:
				return
			_check("goi sai JSON bi bo", _server.dropped_packets > _mark_dropped)
			_check("goi sai JSON khong toi A", _inbox_a.size() == _mark_a)
			_mark_dropped = _server.dropped_packets
			_send(_cc, {"type": "la-gi-do"})
			_wait_until_ms = now + 500
			_step = 3
		3:
			if now < _wait_until_ms:
				return
			_check("type la bi bo", _server.dropped_packets > _mark_dropped)
			_check("type la khong toi A", _inbox_a.size() == _mark_a)
			_send(_cc, {"type": "hello", "protocol": 1, "player_id": "player-c",
				"name": "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"})
			_wait_until_ms = now + 500
			_step = 4
		4:
			if now < _wait_until_ms:
				return
			var wc := _find(_inbox_c, "welcome")
			_check("C hello xong nhan welcome", not wc.is_empty())
			var pres := _find_presence_with_player(_inbox_a, "player-c")
			var cname := _presence_name(pres, "player-c")
			_check("ten C dai 40 ky tu bi cat ve 30", cname.length() == 30, cname)
			_mark_a = _inbox_a.size()
			_mark_dropped = _server.dropped_packets
			_send(_cc, {"type": "chat", "text": "   "})
			_wait_until_ms = now + 500
			_step = 5
		5:
			if now < _wait_until_ms:
				return
			_check("chat rong bi bo", _server.dropped_packets > _mark_dropped)
			_check("chat rong khong toi A", _inbox_a.size() == _mark_a)
			var d := _server.data()
			_check("server dem 2 nguoi choi (A+C)", int(d.get("player_count", -1)) == 2)
			_check("chi co 1 tin chat duoc broadcast", int(d.get("chat_count", -1)) == 1)
			_check("server van chay", bool(d.get("running", false)))
			_finish()


func _finish() -> void:
	if _finished:
		return
	_finished = true
	print("G4 ONLINE SERVER TEST: %d/%d PASS" % [_pass, _pass + _fail])
	_server.stop_server()
	quit(0 if _fail == 0 else 1)


func _send(c: WebSocketMultiplayerPeer, d: Dictionary) -> void:
	c.put_packet(JSON.stringify(d).to_utf8_buffer())


func _drain(c: WebSocketMultiplayerPeer, inbox: Array) -> void:
	c.poll()
	while c.get_available_packet_count() > 0:
		var raw: PackedByteArray = c.get_packet()
		var v: Variant = JSON.parse_string(raw.get_string_from_utf8())
		if v is Dictionary:
			inbox.append(v)


func _find(inbox: Array, mtype: String) -> Dictionary:
	for m in inbox:
		if m is Dictionary and String(m.get("type", "")) == mtype:
			return m
	return {}


func _find_presence(inbox: Array, count: int) -> Dictionary:
	for m in inbox:
		if m is Dictionary and String(m.get("type", "")) == "presence":
			var plist: Array = m.get("players", [])
			if plist.size() == count:
				return m
	return {}


func _find_chat(inbox: Array, text: String) -> Dictionary:
	for m in inbox:
		if m is Dictionary and String(m.get("type", "")) == "chat" \
				and String(m.get("text", "")) == text:
			return m
	return {}


func _find_presence_with_player(inbox: Array, player_id: String) -> Dictionary:
	var found := {}
	for m in inbox:
		if m is Dictionary and String(m.get("type", "")) == "presence":
			for p in (m.get("players", []) as Array):
				if p is Dictionary and String(p.get("player_id", "")) == player_id:
					found = m
	return found


func _presence_name(pres: Dictionary, player_id: String) -> String:
	for p in (pres.get("players", []) as Array):
		if p is Dictionary and String(p.get("player_id", "")) == player_id:
			return String(p.get("name", ""))
	return ""
