class_name PxbServer
extends Node
## Phố Xô Bồ — PXB_Server (Godot G4, bước 6).
## Dedicated server headless + WebSocket cho bản online thật.
## Quyết Bậc 1 (docs/godot-g4.md §12.5): online dùng Godot headless
## dedicated server thay cho server .NET 8 làm đường chính — web export
## bắt buộc WebSocket (trình duyệt không mở được UDP thô), VM này
## không có dotnet SDK nên server .NET không build/chạy/verify được,
## còn dedicated server chạy + verify được ngay bằng cùng binary 4.7.2.
## Server .NET trong src/server/ giữ lại làm tham chiếu, không xóa.
##
## Giao thức JSON v1 qua WebSocket (mỗi gói là 1 object JSON):
##   Client -> server:
##     {"type":"hello","protocol":1,"player_id":"...","name":"..."}
##       đăng ký presence; server trả welcome + broadcast presence.
##     {"type":"chat","text":"..."}  gửi chat (phải hello trước,
##       text 1..500 ký tự); server broadcast lại cho mọi người.
##     {"type":"bye"}  rời presence (đóng socket cũng rời).
##   Server -> client:
##     {"type":"welcome","peer_id":N,"protocol":1,"players":[...]}
##     {"type":"presence","players":[{"peer_id","player_id","name"}]}
##     {"type":"chat","from_peer":N,"player_id":"...","name":"...",
##       "text":"...","at_ms":N}
##     {"type":"error","reason":"..."}  hello sai (protocol / thiếu
##       player_id / server đầy) — không đăng ký.
## Gói sai JSON / không phải object / type lạ / chat khi chưa hello /
## text rỗng hoặc quá dài đều bị bỏ lặng (đếm dropped_packets),
## server không crash, không broadcast — client độc không phá được
## phòng của người khác.
##
## Chạy thật:  godot --headless --path src/godot
##               -s res://server/server_main.gd -- --port 8765
## (server_main.gd tự tạo node này; xem file đó). Trong game, node
## này chỉ chạy ở tiến trình server — client Godot KHÔNG tạo nó.
##
## PROVISIONAL — chưa chốt, đổi thì sửa ở đây + docs/godot-g4.md:
##   - Cổng mặc định 8765; tối đa 64 người chơi cùng lúc.
##   - Tên hiển thị tối đa 30 ký tự (dài hơn thì cắt); player_id
##     tối đa 64 ký tự; chat tối đa 500 ký tự.
##   - Chat log giữ 100 tin gần nhất (chỉ để quan sát/log, chưa
##     có endpoint đọc lại lịch sử cho client mới vào).
##   - CHƯA có auth: player_id do client tự khai, chỉ dùng nội bộ
##     cho tới khi server có auth. Server KHÔNG quyết tiền/đồ của
##     ai — chat + presence chỉ là relay, sổ cái vẫn là việc sau.

# Cổng mặc định — PROVISIONAL.
const DEFAULT_PORT := 8765
# Phiên bản giao thức — client gửi khác số này thì bị từ chối.
const PROTOCOL_VERSION := 1
# Tối đa 64 người chơi cùng lúc — PROVISIONAL.
const MAX_PLAYERS := 64
# Tên hiển thị tối đa 30 ký tự — PROVISIONAL.
const MAX_NAME_LEN := 30
# player_id tối đa 64 ký tự — PROVISIONAL.
const MAX_PLAYER_ID_LEN := 64
# Chat tối đa 500 ký tự — PROVISIONAL.
const MAX_CHAT_LEN := 500
# Chat log giữ 100 tin gần nhất — PROVISIONAL.
const CHAT_LOG_MAX := 100

## Phát khi 1 client hello thành công (đã vào presence).
signal peer_joined(peer_id: int, player_id: String)
## Phát khi 1 client đã đăng ký rời đi (bye hoặc mất kết nối).
signal peer_left(peer_id: int, player_id: String)
## Phát khi 1 tin chat đã broadcast.
signal chat_received(msg: Dictionary)

var peer: WebSocketMultiplayerPeer = null
var port: int = 0
var running: bool = false
## peer_id (int) -> {peer_id, player_id, name, joined_at_ms}.
var players: Dictionary = {}
## 100 tin chat gần nhất, mỗi tin như gói broadcast.
var chat_log: Array = []
## Số gói bỏ vì sai định dạng / sai luật — để quan sát, không crash.
var dropped_packets: int = 0


static func _now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


# Mở cổng WebSocket và bắt đầu nhận client. Trả {ok:true, port}
# hoặc {ok:false, reason[, error]}. Gọi 2 lần khi đang chạy thì
# trả {ok:false, reason:"server-dang-chay"}.
func start_server(p_port: int = DEFAULT_PORT) -> Dictionary:
	if running:
		return {"ok": false, "reason": "server-dang-chay"}
	if p_port < 1 or p_port > 65535:
		return {"ok": false, "reason": "cong-khong-hop-le"}
	var ws := WebSocketMultiplayerPeer.new()
	var err: Error = ws.create_server(p_port)
	if err != OK:
		return {"ok": false, "reason": "khong-mo-duoc-cong", "error": err}
	peer = ws
	port = p_port
	players = {}
	chat_log = []
	dropped_packets = 0
	peer.peer_connected.connect(_on_peer_connected)
	peer.peer_disconnected.connect(_on_peer_disconnected)
	running = true
	return {"ok": true, "port": p_port}


# Dừng server: đóng cổng, xóa presence. Client đang nối sẽ thấy
# mất kết nối. Gọi khi chưa chạy cũng an toàn.
func stop_server() -> void:
	if peer != null:
		peer.close()
		peer = null
	players.clear()
	port = 0
	running = false


func _process(_delta: float) -> void:
	if running:
		poll()


# Một nhịp mạng: poll peer + xử lý hết gói đang chờ. _process gọi
# sẵn khi node trong cây; test headless gọi trực tiếp cũng được
# (poll 2 lần/frame cũng không sao).
func poll() -> void:
	if peer == null:
		return
	peer.poll()
	while peer.get_available_packet_count() > 0:
		var from_peer: int = peer.get_packet_peer()
		var raw: PackedByteArray = peer.get_packet()
		_handle_packet(from_peer, raw)


# Số người chơi đã đăng ký presence.
func player_count() -> int:
	return players.size()


# Danh sách presence, xếp theo peer_id tăng dần — dạng gửi cho client.
func presence_list() -> Array:
	var ids: Array = players.keys()
	ids.sort()
	var out: Array = []
	for id in ids:
		var info: Dictionary = players[id]
		out.append({
			"peer_id": int(id),
			"player_id": String(info["player_id"]),
			"name": String(info["name"]),
		})
	return out


# Trạng thái quan sát được (log / test): không chứa socket.
func data() -> Dictionary:
	return {
		"port": port,
		"running": running,
		"player_count": players.size(),
		"players": presence_list(),
		"chat_count": chat_log.size(),
		"dropped_packets": dropped_packets,
	}


func _send_to(target_peer: int, msg: Dictionary) -> void:
	if peer == null:
		return
	peer.set_target_peer(target_peer)
	peer.put_packet(JSON.stringify(msg).to_utf8_buffer())


# Gửi cho mọi client ĐÃ ĐĂNG KÝ (target 0 = broadcast sẽ gửi cả cho
# socket vừa ngắt — engine báo lỗi ready_state; gửi từng peer đã
# đăng ký thì sạch log và client chưa hello cũng không nhận presence).
func _broadcast(msg: Dictionary) -> void:
	if peer == null:
		return
	var payload := JSON.stringify(msg).to_utf8_buffer()
	for target_peer in players.keys():
		peer.set_target_peer(int(target_peer))
		peer.put_packet(payload)


func _handle_packet(from_peer: int, raw: PackedByteArray) -> void:
	var text := raw.get_string_from_utf8().strip_edges()
	# Chặn rác không phải JSON object trước khi parse — JSON.parse_string
	# in ERROR ra log mỗi lần gặp chuỗi sai (client độc spam sẽ ngập
	# log); object hợp lệ luôn bắt đầu "{" và kết thúc "}".
	if not text.begins_with("{") or not text.ends_with("}"):
		dropped_packets += 1
		return
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		dropped_packets += 1
		return
	var msg: Dictionary = parsed
	match String(msg.get("type", "")):
		"hello":
			_handle_hello(from_peer, msg)
		"chat":
			_handle_chat(from_peer, msg)
		"bye":
			_handle_bye(from_peer)
		_:
			dropped_packets += 1


func _handle_hello(from_peer: int, msg: Dictionary) -> void:
	var proto: Variant = msg.get("protocol", PROTOCOL_VERSION)
	if (proto is int or proto is float) and int(proto) != PROTOCOL_VERSION:
		_send_to(from_peer, {"type": "error", "reason": "protocol-khong-ho-tro"})
		dropped_packets += 1
		return
	var player_id := String(msg.get("player_id", "")).strip_edges()
	if player_id.is_empty() or player_id.length() > MAX_PLAYER_ID_LEN:
		_send_to(from_peer, {"type": "error", "reason": "thieu-player-id"})
		dropped_packets += 1
		return
	var pname := String(msg.get("name", "")).strip_edges()
	if pname.is_empty():
		pname = "Người chơi"
	if pname.length() > MAX_NAME_LEN:
		pname = pname.substr(0, MAX_NAME_LEN)
	if players.size() >= MAX_PLAYERS and not players.has(from_peer):
		_send_to(from_peer, {"type": "error", "reason": "server-day"})
		dropped_packets += 1
		return
	players[from_peer] = {
		"peer_id": from_peer,
		"player_id": player_id,
		"name": pname,
		"joined_at_ms": _now_ms(),
	}
	_send_to(from_peer, {"type": "welcome", "peer_id": from_peer,
		"protocol": PROTOCOL_VERSION, "players": presence_list()})
	_broadcast({"type": "presence", "players": presence_list()})
	peer_joined.emit(from_peer, player_id)


func _handle_chat(from_peer: int, msg: Dictionary) -> void:
	if not players.has(from_peer):
		dropped_packets += 1
		return
	var text := String(msg.get("text", "")).strip_edges()
	if text.is_empty() or text.length() > MAX_CHAT_LEN:
		dropped_packets += 1
		return
	var info: Dictionary = players[from_peer]
	var chat_msg := {
		"type": "chat",
		"from_peer": from_peer,
		"player_id": String(info["player_id"]),
		"name": String(info["name"]),
		"text": text,
		"at_ms": _now_ms(),
	}
	chat_log.append(chat_msg)
	while chat_log.size() > CHAT_LOG_MAX:
		chat_log.pop_front()
	_broadcast(chat_msg)
	chat_received.emit(chat_msg)


func _handle_bye(from_peer: int) -> void:
	if not players.has(from_peer):
		return
	var player_id := String(players[from_peer]["player_id"])
	players.erase(from_peer)
	_broadcast({"type": "presence", "players": presence_list()})
	peer_left.emit(from_peer, player_id)


# Client mới nối socket: chưa làm gì — chờ nó gửi hello.
func _on_peer_connected(_peer_id: int) -> void:
	pass


# Client mất kết nối: nếu đã đăng ký thì xóa khỏi presence +
# broadcast cho mọi người còn lại.
func _on_peer_disconnected(peer_id: int) -> void:
	if not players.has(peer_id):
		return
	var player_id := String(players[peer_id]["player_id"])
	players.erase(peer_id)
	_broadcast({"type": "presence", "players": presence_list()})
	peer_left.emit(peer_id, player_id)
