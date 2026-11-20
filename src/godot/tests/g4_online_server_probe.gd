extends SceneTree
## Probe client 2 tien trinh cho PxbServer — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_online_server_probe.gd -- --port 18765 --player-id probe-a --name "Probe A" --chat "hello"
##   godot --headless --path src/godot -s res://tests/g4_online_server_probe.gd -- --port 18765 --player-id probe-b --name "Probe B" --listen 20
## --chat: sau welcome thi gui 1 tin chat, doi echo roi thoat (in
##   "PROBE OK"). --listen N: doi toi da N giay de nhan 1 tin chat tu
##   nguoi khac roi thoat. Khong co ca 2 thi chi hello + doi welcome.
## Timeout chung 25s -> "PROBE FAIL" + quit(1). Dung de kiem chung
## server_main.gd chay that o tien trinh rieng (khong phai stub).

var _client: WebSocketMultiplayerPeer = null
var _port := 8765
var _player_id := "probe"
var _pname := "Probe"
var _chat_text := ""
var _listen_secs := 0
var _phase := 0
var _deadline_ms := 0
var _started_ms := 0
var _finished := false


func _init() -> void:
	_started_ms = Time.get_ticks_msec()
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		match args[i]:
			"--port":
				if i + 1 < args.size():
					_port = int(args[i + 1])
					i += 2
				else:
					i += 1
			"--player-id":
				if i + 1 < args.size():
					_player_id = args[i + 1]
					i += 2
				else:
					i += 1
			"--name":
				if i + 1 < args.size():
					_pname = args[i + 1]
					i += 2
				else:
					i += 1
			"--chat":
				if i + 1 < args.size():
					_chat_text = args[i + 1]
					i += 2
				else:
					i += 1
			"--listen":
				if i + 1 < args.size():
					_listen_secs = int(args[i + 1])
					i += 2
				else:
					i += 1
			_:
				i += 1
	_client = WebSocketMultiplayerPeer.new()
	var err: Error = _client.create_client("ws://127.0.0.1:%d" % _port)
	if err != OK:
		print("PROBE FAIL: khong tao duoc client: ", err)
		quit(1)
		_finished = true
		return
	_deadline_ms = _started_ms + 25000


func _process(_delta: float) -> bool:
	if _finished:
		return true
	_client.poll()
	var now := Time.get_ticks_msec()
	if now > _deadline_ms:
		print("PROBE FAIL: timeout phase=%d" % _phase)
		quit(1)
		_finished = true
		return true
	while _client.get_available_packet_count() > 0:
		var raw: PackedByteArray = _client.get_packet()
		var v: Variant = JSON.parse_string(raw.get_string_from_utf8())
		if not (v is Dictionary):
			continue
		var msg: Dictionary = v
		match String(msg.get("type", "")):
			"welcome":
				print("PROBE: welcome peer_id=%d players=%d" % [
					int(msg.get("peer_id", 0)),
					(msg.get("players", []) as Array).size()])
				if not _chat_text.is_empty():
					_client.put_packet(JSON.stringify(
						{"type": "chat", "text": _chat_text}).to_utf8_buffer())
					_phase = 2
				elif _listen_secs > 0:
					_phase = 3
					_deadline_ms = now + _listen_secs * 1000
				else:
					print("PROBE OK: hello + welcome")
					quit(0)
					_finished = true
					return true
			"chat":
				print("PROBE: chat [%s] %s" % [
					String(msg.get("name", "?")), String(msg.get("text", ""))])
				if _phase == 2 and String(msg.get("player_id", "")) == _player_id:
					print("PROBE OK: echo chat")
					quit(0)
					_finished = true
					return true
				if _phase == 3:
					print("PROBE OK: nhan chat tu nguoi khac")
					quit(0)
					_finished = true
					return true
	if _phase == 0 \
			and _client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		_client.put_packet(JSON.stringify({"type": "hello", "protocol": 1,
			"player_id": _player_id, "name": _pname}).to_utf8_buffer())
		_phase = 1
	return false
