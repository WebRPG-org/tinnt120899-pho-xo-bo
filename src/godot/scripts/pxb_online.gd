class_name PxbOnline
extends Node
## Phố Xô Bồ — PXB_Online (Godot G2, bước 6/17 + G4 bước 7).
## Port trung thực PXB_Online.js (src/nadia/www/js/plugins/
## PXB_Online.js) — client online: health check, số dư + tặng tiền
## qua server .NET, hàng đợi outbox khi offline; trade / đấu giá /
## công ty=guild CHƯA có endpoint nên luôn trả server-chua-co-endpoint.
##
## G4 bước 7 — CHAT ONLINE QUA SERVER GODOT (protocol v1, xem
## server/pxb_server.gd): client WebSocket trong game này, dùng
## chung giao thức hello/chat/presence với PxbServer. Đường HTTP
## .NET giữ nguyên làm fallback cho tới khi WS ổn định (quyết
## docs/godot-g4.md §12.5). WS chỉ là chat + presence — KHÔNG
## quyết tiền/đồ của ai (sổ cái vẫn qua HTTP .NET như cũ).
##
## - Endpoint THẬT đã có trên server (src/server/src/Program.cs):
##   GET  /health
##   GET  /ledger/balance/{playerId}
##   POST /ledger/gift (body FromPlayerId, ToPlayerId, AmountVnd,
##   GameDay, IdempotencyKey; trùng key → 409, không tặng lần 2).
## - CHƯA có auth: endpoint /ledger/gift hiện tin playerId trong
##   body, chỉ dùng nội bộ cho tới khi server có auth. File này
##   KHÔNG tự thêm auth giả — khi server có auth thì bổ sung sau.
## - Tặng tiền: mỗi lần tặng sinh IdempotencyKey riêng
##   ("pxb-" + epoch-ms + "-" + số ngẫu nhiên); key đã gửi rồi thì
##   KHÔNG gửi lần 2 (trả {ok:false, reason:"trung-idempotency-key"}).
## - Offline: tặng tiền khi không tới được server thì lưu vào hàng
##   đợi outbox trong state và gửi lại khi online (flush_outbox).
##   Server trả 409 (đã có key này) thì coi như đã gửi xong, xóa
##   khỏi outbox — không tặng lần 2.
## - Mọi giao dịch tiền phải qua server, sổ cái EconomyLedger là
##   nguồn sự thật. Client không bao giờ tự quyết tiền/đồ của người
##   khác. Số tiền lấy từ PxbBalance (phí đấu giá, vốn lập công ty…)
##   — file này không hardcode số tiền nào khác. Riêng tặng tiền
##   chưa có giới hạn trong PxbBalance (PROVISIONAL: chưa có cap).
##
## HTTP (Godot dùng HTTPRequest, bất đồng bộ): các hàm mạng là async
## func trả Dictionary. Để test headless được, node có property
## http_transport: Callable — mặc định rỗng (= đường HTTPRequest thật);
## test gán stub Callable(method, url, body) -> Dictionary đồng bộ thì
## await hoàn thành ngay trong frame, không cần server thật. Stub
## phải trả đúng dạng _request(): {ok, status, data, reason}.
## Đường HTTPRequest thật chỉ chạy khi node đã vào cây scene (cần
## get_tree()); ngoài cây thì trả khong-toi-duoc-server — không giả
## vờ đã gọi.
##
## QUIRK / LỆCH ĐÃ GHI NHẬN (theo @help của JS — không bịa số mới):
## - JS lưu state trong $gameSystem.pxbOnline (đi theo save MV);
##   GDScript giữ state trong instance này + data() / from_data()
##   để lưu (save thật là việc SaveCloud, bước sau).
## - Tên hàm/thuộc tính: GDScript không cho trùng tên biến và hàm
##   nên base_url là thuộc tính đọc trực tiếp (node.base_url), còn
##   set_base_url(url) / is_online() là hàm — đúng danh sách state
##   trong task (base_url, online, …).
## - flush_outbox() của JS ghi chú "dừng gửi các món sau" khi gặp
##   lỗi mạng nhưng chuỗi Promise thật ra không kiểm tra cờ dừng nên
##   vẫn thử hết các món còn lại. Bản GDScript dừng thật (break):
##   kết quả {sent, kept, failed} giống hệt nhau (món lỗi mạng nào
##   cũng giữ lại trong outbox), chỉ bớt lần gọi HTTP vô ích.
## - GDScript không có exception — các hàm trả Dictionary
##   {ok, reason, …} thay vì throw; hàm không-endpoint trả
##   Dictionary đồng bộ (không phải async) vì không gọi mạng.
## - Signal online_changed / outbox_changed là thêm mới theo quy
##   ước GDScript của repo (JS không có): chỉ phát khi giá trị đổi
##   (online) / khi outbox đổi (thêm/xóa món), để lớp UI bind.
##
## PROVISIONAL — chưa chốt, đổi thì sửa ở đây + server +
## docs/architecture-nadia.md §7 cùng lúc:
##   - Base URL mặc định http://localhost:5000 (server chạy local;
##     URL deploy thật chưa có).
##   - Timeout mỗi lần gọi API: 5000 ms.
##   - Outbox giữ tối đa 50 món chờ; key đã gửi giữ tối đa 200 key.
##   - Số dư cache trong state chỉ để hiển thị, hết hạn sau 60 giây.

# Base URL mặc định — server .NET chạy local; URL deploy thật chưa có.
const DEFAULT_BASE_URL := "http://localhost:5000"
# Timeout mỗi lần gọi API — PROVISIONAL.
const REQUEST_TIMEOUT_MS := 5000
# Outbox giữ tối đa 50 món chờ — PROVISIONAL.
const OUTBOX_MAX := 50
# Key tặng tiền đã gửi giữ tối đa 200 key — PROVISIONAL.
const SENT_KEYS_MAX := 200
# Số dư cache chỉ để hiển thị, hết hạn sau 60 giây — PROVISIONAL.
const BALANCE_CACHE_MS := 60000
# URL mặc định của server chat Godot (chạy local; URL deploy thật
# chưa có — server chưa có địa chỉ công khai).
const DEFAULT_WS_URL := "ws://localhost:8765"
# Phiên bản giao thức WS — phải khớp PxbServer.PROTOCOL_VERSION.
const WS_PROTOCOL_VERSION := 1
# Chat WS tối đa 500 ký tự — khớp giới hạn server (PxbServer).
const WS_MAX_CHAT_LEN := 500
# Chat log WS giữ 100 tin gần nhất — khớp server (CHAT_LOG_MAX).
const WS_CHAT_LOG_MAX := 100
# Tên hiển thị WS tối đa 30 ký tự — khớp server (cắt ở server).
const WS_MAX_NAME_LEN := 30
# player_id WS tối đa 64 ký tự — khớp server.
const WS_MAX_PLAYER_ID_LEN := 64

# Lý do trả về khi server chưa có endpoint — dùng chung cho trade /
# đấu giá / công ty=guild để event / QC bắt được bằng test tĩnh.
const REASON_NO_ENDPOINT := "server-chua-co-endpoint"

## Phát khi trạng thái online đổi (health check / tặng tiền offline).
signal online_changed(is_online: bool)
## Phát khi số món trong outbox đổi (thêm món chờ / gửi xong món).
signal outbox_changed(count: int)
## Phát khi trạng thái kết nối chat WS đổi (G4 bước 7).
signal ws_status_changed(connected: bool)
## Phát khi danh sách người online đổi (welcome / presence).
signal ws_presence_changed(players: Array)
## Phát khi nhận 1 tin chat WS (kể cả echo tin của chính mình).
signal ws_chat_received(msg: Dictionary)

## Đường gọi HTTP có thể thay thế (test headless gán stub Callable
## trả Dictionary đồng bộ). Rỗng = dùng HTTPRequest thật.
var http_transport: Callable = Callable()

var base_url: String = DEFAULT_BASE_URL
var online: bool = false # lần health check gần nhất có tới được server không
var last_health_check_at: int = 0 # epoch-ms lúc health check gần nhất
var last_health_ok: bool = false # health check gần nhất trả ok không
var outbox: Array = [] # món tặng tiền đang chờ gửi lại khi online
var sent_gift_keys: Array = [] # IdempotencyKey đã gửi (chống gửi lần 2)
var last_balance: Dictionary = {} # {player_id, cash_vnd, savings_vnd} cache để hiển thị
var last_balance_at: int = 0 # epoch-ms lúc lấy số dư gần nhất

# --- Chat online qua server Godot (G4 bước 7, protocol v1) ---
var ws_url: String = DEFAULT_WS_URL
var ws_player_id: String = "" # rỗng → tự sinh "pxb-<ms>-<rand>" lúc nối
var ws_display_name: String = "Người chơi"
var ws_connected: bool = false # đã hello + nhận welcome chưa
var ws_peer_id: int = 0 # peer_id server cấp trong welcome (0 = chưa có)
var ws_players: Array = [] # presence hiện tại [{peer_id, player_id, name}]
var ws_chat_log: Array = [] # 100 tin chat gần nhất {player_id, name, text, at_ms}
var ws_last_error: String = "" # lý do lỗi WS gần nhất ("" = chưa lỗi)
var ws_peer: WebSocketMultiplayerPeer = null # null = chưa nối / đã ngắt
var _ws_hello_sent: bool = false # đã gửi hello sau khi socket nối chưa
var _ws_was_connecting: bool = false # đang trong quá trình nối (để báo lỗi)


static func default_data() -> Dictionary:
	return {
		"base_url": DEFAULT_BASE_URL,
		"online": false,
		"last_health_check_at": 0,
		"last_health_ok": false,
		"outbox": [],
		"sent_gift_keys": [],
		"last_balance": {},
		"last_balance_at": 0,
		"ws_url": DEFAULT_WS_URL,
		"ws_player_id": "",
		"ws_display_name": "Người chơi",
		"ws_chat_log": [],
	}


# --- Tiện ích nội bộ ---

# Epoch-ms (tương đương Date.now() của JS).
static func _now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


func _set_online(value: bool) -> void:
	if online == value:
		return
	online = value
	online_changed.emit(value)


# --- Đổi base URL / đọc trạng thái ---

# Đổi base URL lúc chạy (event/test dùng khi server đổi địa chỉ).
# Trả false khi URL rỗng. Ghi PROVISIONAL: URL deploy thật chưa có.
func set_base_url(url: String) -> bool:
	if url.is_empty():
		return false
	var cleaned := url
	while cleaned.ends_with("/") and cleaned.length() > 1:
		cleaned = cleaned.substr(0, cleaned.length() - 1)
	base_url = cleaned
	return true


func is_online() -> bool:
	return online


# --- Lớp gọi HTTP ---

# Gọi HTTP, trả {ok:true, status, data} hoặc
# {ok:false, status, reason, data} — không throw ra ngoài.
# Khi http_transport hợp lệ thì gọi stub đồng bộ (test headless);
# ngược lại dùng HTTPRequest thật (bất đồng bộ).
func _request(method: String, url: String, body: Dictionary = {}) -> Dictionary:
	if http_transport.is_valid():
		var res: Variant = http_transport.call(method, url, body)
		if res is Dictionary:
			return res
		return {"ok": false, "status": 0, "reason": "transport-tra-ve-sai"}
	return await _request_real(method, url, body)


# Đường HTTPRequest thật. Cần node đã vào cây scene để HTTPRequest
# chạy được; ngoài cây thì trả khong-toi-duoc-server.
func _request_real(method: String, url: String, body: Dictionary = {}) -> Dictionary:
	if get_tree() == null:
		return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
	var http := HTTPRequest.new()
	http.timeout = REQUEST_TIMEOUT_MS / 1000.0
	add_child(http)
	var err: Error
	if method == "POST":
		err = http.request(url, ["Content-Type: application/json"],
			HTTPClient.METHOD_POST, JSON.stringify(body))
	else:
		err = http.request(url, [], HTTPClient.METHOD_GET, "")
	if err != OK:
		http.queue_free()
		return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
	var result: Array = await http.request_completed
	var response_code: int = int(result[1])
	var raw_body: PackedByteArray = result[3]
	http.queue_free()
	if int(result[0]) != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
	var parsed: Variant = JSON.parse_string(raw_body.get_string_from_utf8())
	var data: Dictionary = parsed if parsed is Dictionary else {}
	if response_code >= 200 and response_code < 300:
		return {"ok": true, "status": response_code, "data": data}
	return {"ok": false, "status": response_code,
		"reason": "http-%d" % response_code, "data": data}


# --- Health check + số dư (endpoint thật) ---

# GET /health — cập nhật online / last_health_check_at /
# last_health_ok. Trả {ok:true, status, game, version} khi server
# trả status "ok", ngược lại {ok:false, reason}.
func health_check() -> Dictionary:
	var res: Dictionary = await _request("GET", base_url + "/health", {})
	last_health_check_at = _now_ms()
	if bool(res.get("ok", false)):
		var data: Dictionary = res.get("data", {})
		if String(data.get("status", "")) == "ok":
			_set_online(true)
			last_health_ok = true
			return {
				"ok": true,
				"status": String(data.get("status", "")),
				"game": String(data.get("game", "")),
				"version": String(data.get("version", "")),
			}
	_set_online(false)
	last_health_ok = false
	return {"ok": false, "reason": String(res.get("reason", "health-khong-ok"))}


# GET /ledger/balance/{playerId} — số dư tiền mặt + tiết kiệm từ
# sổ cái server (nguồn sự thật). Cache vào last_balance để hiển thị;
# cache hết hạn sau 60 giây (PROVISIONAL).
# Trả {ok:true, player_id, cash_vnd, savings_vnd} hoặc {ok:false, reason}.
func balance_of(player_id: String) -> Dictionary:
	if player_id.is_empty():
		return {"ok": false, "reason": "thieu-player-id"}
	var res: Dictionary = await _request("GET",
		base_url + "/ledger/balance/" + player_id.uri_encode(), {})
	if not bool(res.get("ok", false)):
		return {"ok": false, "reason": String(res.get("reason", "khong-lay-duoc-so-du"))}
	var data: Dictionary = res.get("data", {})
	if data.is_empty():
		return {"ok": false, "reason": "khong-lay-duoc-so-du"}
	last_balance = {
		"player_id": String(data.get("playerId", player_id)),
		"cash_vnd": int(data.get("cashVnd", 0)),
		"savings_vnd": int(data.get("savingsVnd", 0)),
	}
	last_balance_at = _now_ms()
	return {
		"ok": true,
		"player_id": String(last_balance["player_id"]),
		"cash_vnd": int(last_balance["cash_vnd"]),
		"savings_vnd": int(last_balance["savings_vnd"]),
	}


# Số dư cache còn hạn không (60 giây, PROVISIONAL) — event dùng để
# quyết có gọi lại server hay hiển thị số cũ.
func cached_balance_fresh() -> bool:
	return not last_balance.is_empty() and (_now_ms() - last_balance_at) < BALANCE_CACHE_MS


# --- Tặng tiền (endpoint thật, có IdempotencyKey + outbox) ---

# Sinh IdempotencyKey mới: "pxb-" + epoch-ms + "-" + số ngẫu nhiên.
# Key duy nhất mỗi lần tặng — server dùng key này để chặn tặng trùng.
func new_idempotency_key() -> String:
	return "pxb-%d-%d" % [_now_ms(), randi_range(0, 999999999)]


func has_sent_key(key: String) -> bool:
	return key in sent_gift_keys


func _remember_sent_key(key: String) -> void:
	if key in sent_gift_keys:
		return
	sent_gift_keys.append(key)
	# Giữ tối đa 200 key (PROVISIONAL) — cắt key cũ nhất.
	while sent_gift_keys.size() > SENT_KEYS_MAX:
		sent_gift_keys.pop_front()


# Xếp 1 món tặng tiền vào outbox (khi offline). Trả true khi xếp
# được, false khi outbox đã đầy 50 món (PROVISIONAL) — món mới bị
# bỏ, không lặng lẽ ghi đè món cũ.
func _enqueue_gift(item: Dictionary) -> bool:
	if outbox.size() >= OUTBOX_MAX:
		return false
	outbox.append(item)
	outbox_changed.emit(outbox.size())
	return true


# Gửi 1 món tặng tiền lên server bằng key của chính món đó (không
# sinh key mới khi gửi lại — server chặn trùng bằng key cũ).
# Trả {ok:true, key} khi server nhận; {ok:false, reason, key} khi
# lỗi. Server trả 409 = key đã có → coi như đã gửi xong.
func _send_gift_once(item: Dictionary) -> Dictionary:
	var res: Dictionary = await _request("POST", base_url + "/ledger/gift", {
		"FromPlayerId": String(item["from_player_id"]),
		"ToPlayerId": String(item["to_player_id"]),
		"AmountVnd": int(item["amount_vnd"]),
		"GameDay": int(item["game_day"]),
		"IdempotencyKey": String(item["key"]),
	})
	if bool(res.get("ok", false)):
		_remember_sent_key(String(item["key"]))
		return {"ok": true, "key": String(item["key"])}
	if int(res.get("status", 0)) == 409:
		# Server đã có key này → đã tặng rồi, không tặng lần 2.
		_remember_sent_key(String(item["key"]))
		return {"ok": true, "key": String(item["key"]), "duplicate": true}
	var data: Dictionary = res.get("data", {})
	var reason := ""
	if data.has("error"):
		reason = String(data["error"])
	elif res.has("reason"):
		reason = String(res["reason"])
	else:
		reason = "gift-that-bai"
	return {"ok": false, "key": String(item["key"]), "reason": reason}


# Tặng tiền trong game (không lãi, không phí — đúng
# EconomyLedger.Gift). amount_vnd phải là số nguyên > 0; chưa có
# giới hạn trên trong PxbBalance (PROVISIONAL: chưa có cap).
# - Key đã gửi rồi → {ok:false, reason:"trung-idempotency-key"},
#   KHÔNG gửi lần 2.
# - Gửi được → {ok:true, key}.
# - Không tới được server → xếp vào outbox, trả
#   {ok:false, reason:"offline-da-luu-outbox", queued:true}.
# - Server từ chối (400: số tiền sai…) → {ok:false, reason}.
# Có thể truyền key riêng (khi gửi lại từ outbox) — event thường
# không truyền, để hàm tự sinh.
func gift(from_player_id: String, to_player_id: String, amount_vnd: Variant,
		game_day: int = 1, key: String = "") -> Dictionary:
	if from_player_id.is_empty() or to_player_id.is_empty():
		return {"ok": false, "reason": "thieu-player-id"}
	if not (amount_vnd is int or amount_vnd is float) \
			or int(amount_vnd) != amount_vnd or int(amount_vnd) <= 0:
		return {"ok": false, "reason": "so-tien-khong-hop-le"}
	var gift_key: String = key if not key.is_empty() else new_idempotency_key()
	if has_sent_key(gift_key):
		return {"ok": false, "key": gift_key, "reason": "trung-idempotency-key"}
	var item := {
		"key": gift_key,
		"from_player_id": from_player_id,
		"to_player_id": to_player_id,
		"amount_vnd": int(amount_vnd),
		"game_day": game_day if game_day > 0 else 1,
		"queued_at": _now_ms(),
	}
	var res: Dictionary = await _send_gift_once(item)
	if bool(res.get("ok", false)):
		return {"ok": true, "key": gift_key}
	if String(res.get("reason", "")) == "khong-toi-duoc-server":
		# Offline: xếp vào outbox để gửi lại khi online. Outbox đầy
		# thì báo rõ, không lặng lẽ mất món tặng.
		if _enqueue_gift(item):
			_set_online(false)
			return {"ok": false, "key": gift_key,
				"reason": "offline-da-luu-outbox", "queued": true}
		return {"ok": false, "key": gift_key, "reason": "outbox-day"}
	return {"ok": false, "key": gift_key, "reason": String(res.get("reason", "gift-that-bai"))}


# Gửi lại toàn bộ outbox khi online. Món gửi được hoặc server báo
# 409 (đã có) thì xóa khỏi outbox; món lỗi mạng thì giữ lại và dừng
# gửi các món sau. Món lỗi không phải do mạng (400…) thì giữ lại
# trong outbox và đếm vào failed.
# Trả {sent, kept, failed} — sent: số món đã gửi xong, kept: số
# món còn chờ, failed: số món lỗi không phải do mạng (400…).
func flush_outbox() -> Dictionary:
	var sent := 0
	var failed := 0
	var before := outbox.size()
	var items: Array = outbox.duplicate()
	for item in items:
		var res: Dictionary = await _send_gift_once(item)
		if bool(res.get("ok", false)):
			outbox.erase(item)
			sent += 1
		elif String(res.get("reason", "")) == "khong-toi-duoc-server":
			_set_online(false)
			# Giữ lại trong outbox, dừng gửi các món sau (xem quirk
			# trong header: JS ghi chú dừng nhưng code không dừng;
			# kết quả {sent, kept, failed} giống hệt nhau).
			break
		else:
			failed += 1
	if outbox.size() != before:
		outbox_changed.emit(outbox.size())
	return {"sent": sent, "kept": outbox.size(), "failed": failed}


# Số món đang chờ trong outbox — event dùng để hiển thị.
func outbox_count() -> int:
	return outbox.size()


# --- Chat online qua server Godot (G4 bước 7, protocol v1) ---
# Client WebSocket dùng WebSocketMultiplayerPeer (đã chứng minh nối
# được PxbServer trong tests/g4_online_server_test.gd). Node này
# thêm _process để tự poll khi đã vào cây scene (Main add_child);
# test headless gọi poll_ws() tay cũng được (poll 2 lần/frame
# không sao — xem PxbServer.poll).
# Trình tự: connect_ws() tạo socket (bất đồng bộ) → poll_ws thấy
# CONNECTED thì gửi hello → server trả welcome → ws_connected=true
# + presence. Gửi chat chỉ sau welcome. Ngắt (bye / mất kết nối /
# server trả error) thì ws_connected=false + xóa presence.
# CHƯA có auth (player_id do client tự khai — chỉ dùng nội bộ,
# giống server); KHÔNG tự reconnect — người chơi bấm nối lại.

func _process(_delta: float) -> void:
	if ws_peer != null:
		poll_ws()


# Đặt trạng thái WS + phát signal chỉ khi giá trị đổi (giống
# _set_online của đường HTTP).
func _set_ws_connected(value: bool) -> void:
	if ws_connected == value:
		return
	ws_connected = value
	ws_status_changed.emit(value)


# Sinh player_id WS mới khi chưa có: "pxb-<epoch-ms>-<rand>".
static func new_ws_player_id() -> String:
	return "pxb-%d-%d" % [_now_ms(), randi_range(0, 999999999)]


# Nối tới server chat WS. url / player_id / tên rỗng thì dùng giá
# trị đã lưu (mặc định ws://localhost:8765, id tự sinh, tên
# "Người chơi"). Trả {ok:true, url, player_id} khi đã tạo socket
# (kết nối bất đồng bộ — hello gửi khi CONNECTED, xem poll_ws),
# {ok:false, reason} khi đã nối rồi / URL sai / tạo socket lỗi.
# Không chặn: gọi xong trả ngay, Main báo "Đang nối…".
func connect_ws(url: String = "", player_id: String = "",
		display_name: String = "") -> Dictionary:
	if ws_peer != null and ws_connected:
		return {"ok": false, "reason": "ws-da-ket-noi"}
	if ws_peer != null:
		return {"ok": false, "reason": "ws-dang-noi"}
	var target_url := url.strip_edges() if not url.is_empty() else ws_url
	if target_url.is_empty():
		return {"ok": false, "reason": "thieu-ws-url"}
	ws_url = target_url
	if not player_id.is_empty():
		ws_player_id = player_id.strip_edges()
	if ws_player_id.is_empty() or ws_player_id.length() > WS_MAX_PLAYER_ID_LEN:
		ws_player_id = new_ws_player_id()
	if not display_name.is_empty():
		ws_display_name = display_name.strip_edges()
	if ws_display_name.is_empty():
		ws_display_name = "Người chơi"
	if ws_display_name.length() > WS_MAX_NAME_LEN:
		ws_display_name = ws_display_name.substr(0, WS_MAX_NAME_LEN)
	ws_last_error = ""
	_ws_hello_sent = false
	_ws_was_connecting = true
	var peer := WebSocketMultiplayerPeer.new()
	var err: Error = peer.create_client(ws_url)
	if err != OK:
		ws_last_error = "ws-khong-tao-duoc"
		_ws_was_connecting = false
		return {"ok": false, "reason": "ws-khong-tao-duoc", "error": err}
	ws_peer = peer
	return {"ok": true, "url": ws_url, "player_id": ws_player_id}


# Ngắt chat WS: gửi bye nếu đã hello, đóng socket, xóa presence +
# trạng thái. Gọi khi chưa nối cũng an toàn.
func disconnect_ws() -> void:
	if ws_peer != null:
		if ws_connected and _ws_hello_sent:
			ws_peer.put_packet(JSON.stringify({"type": "bye"}).to_utf8_buffer())
		ws_peer.close()
		ws_peer = null
	_ws_hello_sent = false
	_ws_was_connecting = false
	ws_peer_id = 0
	ws_players = []
	_set_ws_connected(false)
	ws_presence_changed.emit(ws_players)


# Đã nối chat WS (đã hello + nhận welcome) chưa.
func is_ws_connected() -> bool:
	return ws_connected


# Một nhịp mạng WS: poll socket + xử lý hết gói đang chờ + gửi
# hello ngay khi socket vừa CONNECTED. Gọi từ _process (node trong
# cây) hoặc tay trong test.
func poll_ws() -> void:
	if ws_peer == null:
		return
	ws_peer.poll()
	var status := ws_peer.get_connection_status()
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		if not _ws_hello_sent:
			_ws_hello_sent = true
			_ws_was_connecting = false
			ws_peer.put_packet(JSON.stringify({
				"type": "hello",
				"protocol": WS_PROTOCOL_VERSION,
				"player_id": ws_player_id,
				"name": ws_display_name,
			}).to_utf8_buffer())
		while ws_peer.get_available_packet_count() > 0:
			var raw: PackedByteArray = ws_peer.get_packet()
			_handle_ws_packet(raw)
		return
	if status == MultiplayerPeer.CONNECTION_DISCONNECTED:
		# Nối thất bại (cổng đóng / server sập) hoặc mất kết nối
		# giữa chừng: báo ngoại tuyến, dọn socket để bấm nối lại.
		if _ws_was_connecting:
			ws_last_error = "ws-khong-noi-duoc"
		ws_peer = null
		_ws_hello_sent = false
		_ws_was_connecting = false
		ws_peer_id = 0
		ws_players = []
		_set_ws_connected(false)
		ws_presence_changed.emit(ws_players)


# Nhận 1 gói thô từ server: chặn rác không phải JSON object trước
# khi parse (giống PxbServer — tránh JSON.parse_string in ERROR).
func _handle_ws_packet(raw: PackedByteArray) -> void:
	var text := raw.get_string_from_utf8().strip_edges()
	if not text.begins_with("{") or not text.ends_with("}"):
		return
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return
	_handle_ws_message(parsed)


# Xử lý 1 gói JSON hợp lệ từ server (welcome / presence / chat /
# error). Gói lạ thì bỏ lặng — client độc không phá được phòng.
func _handle_ws_message(msg: Dictionary) -> void:
	match String(msg.get("type", "")):
		"welcome":
			ws_peer_id = int(msg.get("peer_id", 0))
			var plist: Variant = msg.get("players", [])
			ws_players = _clean_presence(plist)
			_set_ws_connected(true)
			ws_presence_changed.emit(ws_players)
		"presence":
			var plist2: Variant = msg.get("players", [])
			ws_players = _clean_presence(plist2)
			ws_presence_changed.emit(ws_players)
		"chat":
			var chat_msg := _clean_chat_message(msg)
			if chat_msg.is_empty():
				return
			ws_chat_log.append(chat_msg)
			while ws_chat_log.size() > WS_CHAT_LOG_MAX:
				ws_chat_log.pop_front()
			ws_chat_received.emit(chat_msg)
		"error":
			ws_last_error = String(msg.get("reason", "ws-loi-server"))
			disconnect_ws()
		_:
			pass


# Chuẩn hóa presence server gửi: chỉ giữ {peer_id, player_id,
# name} hợp lệ, xếp theo peer_id tăng dần.
static func _clean_presence(raw_list: Variant) -> Array:
	var out: Array = []
	if not (raw_list is Array):
		return out
	for item in raw_list:
		if not (item is Dictionary):
			continue
		var pid := String(item.get("player_id", ""))
		var pname := String(item.get("name", ""))
		if pid.is_empty() or pname.is_empty():
			continue
		out.append({
			"peer_id": int(item.get("peer_id", 0)),
			"player_id": pid,
			"name": pname,
		})
	out.sort_custom(func(a, b) -> bool: return int(a["peer_id"]) < int(b["peer_id"]))
	return out


# Chuẩn hóa 1 tin chat server gửi: bỏ tin thiếu tên/text hoặc
# text quá dài (server đáng lẽ đã lọc — client lọc lại cho chắc).
static func _clean_chat_message(msg: Dictionary) -> Dictionary:
	var pname := String(msg.get("name", ""))
	var text := String(msg.get("text", ""))
	if pname.is_empty() or text.is_empty() or text.length() > WS_MAX_CHAT_LEN:
		return {}
	return {
		"player_id": String(msg.get("player_id", "")),
		"name": pname,
		"text": text,
		"at_ms": _clean_ms(msg.get("at_ms", 0)),
	}


# Gửi 1 tin chat lên server (phải đã nối + đã welcome). Trả
# {ok:true} khi đã gửi (server broadcast lại, kể cả cho chính
# mình — tin hiện trong log khi nhận echo), {ok:false, reason}
# khi chưa nối / chat rỗng / chat quá 500 ký tự / socket lỗi.
func send_ws_chat(text: String) -> Dictionary:
	if not ws_connected or ws_peer == null:
		return {"ok": false, "reason": "chua-ket-noi-ws"}
	var clean := text.strip_edges()
	if clean.is_empty():
		return {"ok": false, "reason": "chat-trong"}
	if clean.length() > WS_MAX_CHAT_LEN:
		return {"ok": false, "reason": "chat-qua-dai"}
	var err: Error = ws_peer.put_packet(JSON.stringify(
		{"type": "chat", "text": clean}).to_utf8_buffer())
	if err != OK:
		return {"ok": false, "reason": "ws-gui-that-bai", "error": err}
	return {"ok": true}


# Trạng thái chat WS để hiển thị (Cài đặt / Tin nhắn).
func ws_status_text() -> String:
	if ws_connected:
		return "đã nối (%d người online)" % ws_players.size()
	if ws_peer != null:
		return "đang nối…"
	if not ws_last_error.is_empty():
		return "ngoại tuyến (%s)" % ws_last_error
	return "ngoại tuyến"


# Danh sách người online để hiển thị (tối đa 10 tên).
func ws_presence_text() -> String:
	if ws_players.is_empty():
		return "(chưa thấy ai online)"
	var names: Array[String] = []
	for p in ws_players.slice(0, 10):
		names.append(String((p as Dictionary).get("name", "")))
	var extra := ""
	if ws_players.size() > 10:
		extra = " +%d người nữa" % (ws_players.size() - 10)
	return " • ".join(names) + extra


# Khối chat online để hiển thị trong tab Tin nhắn: trạng thái +
# người online + 8 tin gần nhất (mới nhất cuối).
func ws_phone_text() -> String:
	var lines: Array[String] = [
		"Chat online — %s" % ws_status_text(),
		"Đang online: %s" % ws_presence_text(),
	]
	if ws_chat_log.is_empty():
		lines.append("(chưa có tin nhắn nào — nối chat rồi nhắn thử)")
	else:
		for m in ws_chat_log.slice(maxi(0, ws_chat_log.size() - 8)):
			lines.append("%s: %s" % [
				String((m as Dictionary).get("name", "?")),
				String((m as Dictionary).get("text", ""))])
	return "\n".join(lines)


# --- Trade / đấu giá / công ty=guild: server CHƯA có endpoint ---
# Mọi hàm dưới đây LUÔN trả {ok:false, reason:"server-chua-co-endpoint"}.
# KHÔNG bịa endpoint, KHÔNG giả vờ thành công, KHÔNG tự quyết
# tiền/đồ của người khác ở client. Khi server thêm endpoint thì
# thay từng hàm bằng lệnh gọi thật (giữ nguyên chữ ký trả về).

# Đề nghị đổi đồ với người chơi khác (đổi đồ lấy đồ, không dùng
# tiền — xem PxbEconomy.barter cho đổi đồ offline).
func create_trade_offer(from_player_id: String, to_player_id: String,
		give_item_id: String, receive_item_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Chấp nhận 1 đề nghị đổi đồ (trade_id do server cấp sau này).
func accept_trade(trade_id: String, player_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Từ chối / hủy 1 đề nghị đổi đồ.
func decline_trade(trade_id: String, player_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Xem danh sách đấu giá đang mở (server chưa có endpoint).
func list_auctions() -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Đặt giá đấu giá. Phí sàn 5% (PxbBalance.auction_fee_percent, đã
# chốt) do SERVER tính khi có endpoint — client chỉ trả về
# server-chua-co-endpoint, không tự tính tiền người bán ở đây
# (xem PxbEconomy.auction_seller_receives cho bản offline).
func place_bid(auction_id: String, player_id: String, amount_vnd: int) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Lập công ty (= guild): cần vốn 500 triệu + giấy phép (số ĐÃ
# CHỐT trong PxbBalance.company_capital_vnd) — nhưng server chưa
# có endpoint nên vẫn trả server-chua-co-endpoint, không tự trừ
# tiền hay tạo công ty ở client.
func create_company(founder_player_id: String, company_name: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Xin vào công ty (guild).
func join_company(player_id: String, company_id: String) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Đóng góp điểm / tiền cho công ty — 0 đóng góp 2 tuần thì bị loại
# (luật GDD Mục 6) do server tính khi có endpoint.
func contribute_company(player_id: String, company_id: String, amount_vnd: int) -> Dictionary:
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# --- Lưu / tải (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {
		"base_url": base_url,
		"online": online,
		"last_health_check_at": last_health_check_at,
		"last_health_ok": last_health_ok,
		"outbox": outbox.duplicate(true),
		"sent_gift_keys": sent_gift_keys.duplicate(),
		"last_balance": last_balance.duplicate(),
		"last_balance_at": last_balance_at,
		"ws_url": ws_url,
		"ws_player_id": ws_player_id,
		"ws_display_name": ws_display_name,
		"ws_chat_log": ws_chat_log.duplicate(true),
	}


# Khôi phục từ data(); dữ liệu bẩn bị bỏ: base_url rỗng / không
# phải chuỗi → mặc định; mốc thời gian âm / không phải số → 0;
# món outbox thiếu key / thiếu người chơi / số tiền <= 0 / không
# phải số → bỏ; key đã gửi rỗng / trùng / không phải chuỗi → bỏ;
# số dư thiếu player_id / tiền không phải số → tiền về 0, thiếu
# player_id thì bỏ cả số dư. Outbox giữ tối đa 50 món, key đã gửi
# giữ tối đa 200 key (cắt cũ nhất).
func from_data(d: Dictionary) -> void:
	if d.is_empty():
		reset_state()
		return
	var raw_url: Variant = d.get("base_url", DEFAULT_BASE_URL)
	if raw_url is String and not String(raw_url).is_empty():
		var cleaned := String(raw_url)
		while cleaned.ends_with("/") and cleaned.length() > 1:
			cleaned = cleaned.substr(0, cleaned.length() - 1)
		base_url = cleaned
	else:
		base_url = DEFAULT_BASE_URL
	online = bool(d.get("online", false))
	last_health_check_at = _clean_ms(d.get("last_health_check_at", 0))
	last_health_ok = bool(d.get("last_health_ok", false))
	outbox = []
	var raw_outbox: Variant = d.get("outbox", [])
	if raw_outbox is Array:
		for raw_item in raw_outbox:
			if outbox.size() >= OUTBOX_MAX:
				break
			var item := _clean_outbox_item(raw_item)
			if not item.is_empty():
				outbox.append(item)
	sent_gift_keys = []
	var raw_keys: Variant = d.get("sent_gift_keys", [])
	if raw_keys is Array:
		for raw_key in raw_keys:
			if raw_key is String and not String(raw_key).is_empty() \
					and not (String(raw_key) in sent_gift_keys):
				sent_gift_keys.append(String(raw_key))
		while sent_gift_keys.size() > SENT_KEYS_MAX:
			sent_gift_keys.pop_front()
	last_balance = {}
	var raw_balance: Variant = d.get("last_balance", {})
	if raw_balance is Dictionary and not raw_balance.is_empty():
		var pid := String(raw_balance.get("player_id", ""))
		if not pid.is_empty():
			last_balance = {
				"player_id": pid,
				"cash_vnd": _clean_money(raw_balance.get("cash_vnd", 0)),
				"savings_vnd": _clean_money(raw_balance.get("savings_vnd", 0)),
			}
	last_balance_at = _clean_ms(d.get("last_balance_at", 0))
	# WS chat (G4 bước 7): dữ liệu bẩn bị bỏ giống HTTP — URL rỗng
	# → mặc định; id rỗng / quá dài → rỗng (sinh lại lúc nối);
	# tên rỗng → "Người chơi", dài → cắt 30; tin chat thiếu tên/
	# text hoặc quá 500 ký tự → bỏ; log giữ tối đa 100 tin.
	var raw_ws_url: Variant = d.get("ws_url", DEFAULT_WS_URL)
	ws_url = String(raw_ws_url) if raw_ws_url is String \
		and not String(raw_ws_url).is_empty() else DEFAULT_WS_URL
	var raw_ws_id: Variant = d.get("ws_player_id", "")
	ws_player_id = String(raw_ws_id) if raw_ws_id is String \
		and not String(raw_ws_id).is_empty() \
		and String(raw_ws_id).length() <= WS_MAX_PLAYER_ID_LEN else ""
	var raw_ws_name: Variant = d.get("ws_display_name", "Người chơi")
	ws_display_name = String(raw_ws_name) if raw_ws_name is String \
		and not String(raw_ws_name).is_empty() else "Người chơi"
	if ws_display_name.length() > WS_MAX_NAME_LEN:
		ws_display_name = ws_display_name.substr(0, WS_MAX_NAME_LEN)
	ws_chat_log = []
	var raw_log: Variant = d.get("ws_chat_log", [])
	if raw_log is Array:
		for raw_msg in raw_log:
			if ws_chat_log.size() >= WS_CHAT_LOG_MAX:
				break
			if not (raw_msg is Dictionary):
				continue
			var clean_msg := _clean_chat_message(raw_msg)
			if not clean_msg.is_empty():
				ws_chat_log.append(clean_msg)


# Mốc thời gian bẩn → 0 (âm / không phải số).
static func _clean_ms(value: Variant) -> int:
	if value is int or value is float:
		return maxi(0, int(value))
	return 0


# Số tiền bẩn → 0 (không phải số / âm — số dư cache chỉ để hiển thị,
# lần balance_of sau sẽ lấy lại số thật từ server).
static func _clean_money(value: Variant) -> int:
	if value is int or value is float:
		return maxi(0, int(value))
	return 0


# Kiểm tra + chuẩn hóa 1 món outbox; trả {} khi món bẩn (bỏ).
static func _clean_outbox_item(raw_item: Variant) -> Dictionary:
	if not (raw_item is Dictionary):
		return {}
	var key := String(raw_item.get("key", ""))
	var from_id := String(raw_item.get("from_player_id", ""))
	var to_id := String(raw_item.get("to_player_id", ""))
	var amount: Variant = raw_item.get("amount_vnd", 0)
	if key.is_empty() or from_id.is_empty() or to_id.is_empty():
		return {}
	if not (amount is int or amount is float) or int(amount) != amount \
			or int(amount) <= 0:
		return {}
	var day: Variant = raw_item.get("game_day", 1)
	var clean_day := 1
	if day is int or day is float:
		clean_day = maxi(1, int(day))
	return {
		"key": key,
		"from_player_id": from_id,
		"to_player_id": to_id,
		"amount_vnd": int(amount),
		"game_day": clean_day,
		"queued_at": _clean_ms(raw_item.get("queued_at", 0)),
	}


# Reset state hiện tại về mặc định (event/test dùng để bắt đầu lại).
# Ngắt WS trước (nếu đang nối) rồi mới xóa trạng thái.
func reset_state() -> bool:
	disconnect_ws()
	var d := default_data()
	base_url = String(d["base_url"])
	online = bool(d["online"])
	last_health_check_at = int(d["last_health_check_at"])
	last_health_ok = bool(d["last_health_ok"])
	outbox = []
	sent_gift_keys = []
	last_balance = {}
	last_balance_at = int(d["last_balance_at"])
	ws_url = String(d["ws_url"])
	ws_player_id = String(d["ws_player_id"])
	ws_display_name = String(d["ws_display_name"])
	ws_chat_log = []
	ws_last_error = ""
	return true
