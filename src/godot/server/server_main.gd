extends SceneTree
## Phố Xô Bồ — chạy PXB dedicated server headless:
##   godot --headless --path src/godot -s res://server/server_main.gd -- --port 8765
## Mặc định cổng 8765 khi không truyền --port. Server chạy cho tới
## khi bị kill hoặc hết --quit-after N (cờ của engine, để test).
## Log 1 dòng khi có người vào/ra/chat để quan sát bằng mắt thường.

var _server: PxbServer = null


func _init() -> void:
	var port := PxbServer.DEFAULT_PORT
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		if args[i] == "--port" and i + 1 < args.size():
			port = int(args[i + 1])
			i += 2
		else:
			i += 1
	_server = PxbServer.new()
	root.add_child(_server)
	_server.peer_joined.connect(_on_peer_joined)
	_server.peer_left.connect(_on_peer_left)
	_server.chat_received.connect(_on_chat_received)
	var res: Dictionary = _server.start_server(port)
	if not bool(res.get("ok", false)):
		printerr("PXB SERVER: khong khoi dong duoc: ", res)
		quit(1)
		return
	print("PXB SERVER: listening ws://0.0.0.0:%d protocol=%d" % [port, PxbServer.PROTOCOL_VERSION])


func _on_peer_joined(peer_id: int, player_id: String) -> void:
	print("PXB SERVER: + peer %d (%s), dang online: %d" % [peer_id, player_id, _server.player_count()])


func _on_peer_left(peer_id: int, player_id: String) -> void:
	print("PXB SERVER: - peer %d (%s), dang online: %d" % [peer_id, player_id, _server.player_count()])


func _on_chat_received(msg: Dictionary) -> void:
	print("PXB SERVER: chat [%s] %s" % [String(msg.get("name", "?")), String(msg.get("text", ""))])
