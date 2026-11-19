class_name PxbOnline
extends Node
## Phố Xô Bồ — PXB_Online (Godot G2, bước 6/17).
## Port trung thực PXB_Online.js (src/nadia/www/js/plugins/
## PXB_Online.js) — client online: health check, số dư + tặng tiền
## qua server .NET, hàng đợi outbox khi offline; trade / đấu giá /
## công ty=guild CHƯA có endpoint nên luôn trả server-chua-co-endpoint.
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

# Lý do trả về khi server chưa có endpoint — dùng chung cho trade /
# đấu giá / công ty=guild để event / QC bắt được bằng test tĩnh.
const REASON_NO_ENDPOINT := "server-chua-co-endpoint"

## Phát khi trạng thái online đổi (health check / tặng tiền offline).
signal online_changed(is_online: bool)
## Phát khi số món trong outbox đổi (thêm món chờ / gửi xong món).
signal outbox_changed(count: int)

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
func reset_state() -> bool:
	var d := default_data()
	base_url = String(d["base_url"])
	online = bool(d["online"])
	last_health_check_at = int(d["last_health_check_at"])
	last_health_ok = bool(d["last_health_ok"])
	outbox = []
	sent_gift_keys = []
	last_balance = {}
	last_balance_at = int(d["last_balance_at"])
	return true
