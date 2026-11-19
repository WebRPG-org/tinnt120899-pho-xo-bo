extends SceneTree
## G2 ONLINE selftest — chay headless, khong can trinh duyet hay server that:
##   godot --headless --path src/godot -s res://tests/g2_online_test.gd
## Kiem tra: PxbOnline (port PXB_Online.js) — hang PROVISIONAL, base URL,
## health check + so du qua stub HTTP (ok / fail / loi mang / http-500),
## cache so du 60 giay, tang tien (hop le / khong hop le / trung key /
## offline vao outbox / outbox day 50 / 409 coi nhu xong), flush_outbox
## (gui duoc + 409 + loi mang giu lai), 8 ham chua-co-endpoint, signal
## online_changed / outbox_changed, save round-trip + bo du lieu ban,
## reset_state.
## In "G2 ONLINE SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd (tranh xung dot voi luong song song).

var _pass := 0
var _fail := 0

# Trang thai stub HTTP: "ok" | "network-fail" | "health-not-ok" |
# "http-500" | "conflict-409" | "bad-request-400".
var _stub_mode: String = "ok"
var _stub_calls: Array = []
var _stub_queue: Array = [] # tra loi dinh san theo thu tu (uu tien hon mode)
var _online_events: Array = []
var _outbox_events: Array = []
var _nodes: Array = [] # node da tao — free o cuoi de log sach (khong leak resource)


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	_test_constants()
	_test_defaults_and_base_url()
	await _test_health()
	await _test_balance()
	await _test_gift()
	await _test_outbox_full()
	await _test_flush()
	await _test_signals()
	_test_no_endpoint()
	_test_save()
	print("G2 ONLINE SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	for n in _nodes:
		n.free()
	quit(0 if _fail == 0 else 1)


func _on_online_changed(is_online: bool) -> void:
	_online_events.append(is_online)


func _on_outbox_changed(count: int) -> void:
	_outbox_events.append(count)


func _new_online() -> PxbOnline:
	var node := PxbOnline.new()
	node.http_transport = _stub_http
	node.online_changed.connect(_on_online_changed)
	node.outbox_changed.connect(_on_outbox_changed)
	_nodes.append(node)
	return node


func _clear_events() -> void:
	_online_events.clear()
	_outbox_events.clear()


func _reset_stub() -> void:
	_stub_mode = "ok"
	_stub_calls.clear()
	_stub_queue.clear()


# Stub HTTP dong bo: tra Dictionary dung dang _request() cua PxbOnline.
func _stub_http(method: String, url: String, body: Dictionary) -> Dictionary:
	_stub_calls.append({"method": method, "url": url, "body": body.duplicate()})
	if not _stub_queue.is_empty():
		var queued: Variant = _stub_queue.pop_front()
		if queued is Dictionary:
			return queued
	match _stub_mode:
		"network-fail":
			return {"ok": false, "status": 0, "reason": "khong-toi-duoc-server"}
		"health-not-ok":
			if url.ends_with("/health"):
				return {"ok": true, "status": 200,
					"data": {"status": "error", "game": "Pho Xo Bo"}}
			return {"ok": false, "status": 500, "reason": "http-500", "data": {}}
		"http-500":
			return {"ok": false, "status": 500, "reason": "http-500", "data": {}}
		"conflict-409":
			if url.ends_with("/ledger/gift"):
				return {"ok": false, "status": 409, "reason": "http-409",
					"data": {"ok": false, "error": "duplicate-idempotency-key"}}
			return {"ok": true, "status": 200,
				"data": {"status": "ok", "game": "Pho Xo Bo", "version": "0.1.0-skeleton"}}
		"bad-request-400":
			if url.ends_with("/ledger/gift"):
				return {"ok": false, "status": 400, "reason": "http-400",
					"data": {"ok": false, "error": "so tien <= 0"}}
			return {"ok": true, "status": 200,
				"data": {"status": "ok", "game": "Pho Xo Bo", "version": "0.1.0-skeleton"}}
		_:
			if url.ends_with("/health"):
				return {"ok": true, "status": 200,
					"data": {"status": "ok", "game": "Pho Xo Bo", "version": "0.1.0-skeleton"}}
			if "/ledger/balance/" in url:
				var marker := "/ledger/balance/"
				var pid: String = url.substr(url.find(marker) + marker.length()).uri_decode()
				return {"ok": true, "status": 200,
					"data": {"playerId": pid, "cashVnd": 123456, "savingsVnd": 7890}}
			if url.ends_with("/ledger/gift"):
				return {"ok": true, "status": 200, "data": {"ok": true}}
			return {"ok": false, "status": 404, "reason": "http-404", "data": {}}


func _test_constants() -> void:
	_check("Online: DEFAULT_BASE_URL dung server local",
		PxbOnline.DEFAULT_BASE_URL == "http://localhost:5000")
	_check("Online: REQUEST_TIMEOUT_MS = 5000 (PROVISIONAL)",
		PxbOnline.REQUEST_TIMEOUT_MS == 5000)
	_check("Online: OUTBOX_MAX = 50 (PROVISIONAL)", PxbOnline.OUTBOX_MAX == 50)
	_check("Online: SENT_KEYS_MAX = 200 (PROVISIONAL)", PxbOnline.SENT_KEYS_MAX == 200)
	_check("Online: BALANCE_CACHE_MS = 60000 (PROVISIONAL)",
		PxbOnline.BALANCE_CACHE_MS == 60000)
	_check("Online: REASON_NO_ENDPOINT dung chuoi chot",
		PxbOnline.REASON_NO_ENDPOINT == "server-chua-co-endpoint")


func _test_defaults_and_base_url() -> void:
	_reset_stub()
	var node := _new_online()
	_check("Online: moi tao thi base_url mac dinh",
		node.base_url == "http://localhost:5000")
	_check("Online: moi tao thi offline + last_health_ok false",
		not node.is_online() and not node.last_health_ok)
	_check("Online: moi tao thi moc health/balance = 0 + outbox rong",
		node.last_health_check_at == 0 and node.last_balance_at == 0
		and node.outbox_count() == 0 and node.last_balance.is_empty())
	_check("Online: moi tao thi chua co key da gui",
		node.sent_gift_keys.is_empty() and not node.has_sent_key("pxb-1"))
	_check("Online: set_base_url cat dau / cuoi + doi base_url",
		node.set_base_url("http://may-chu-rieng:6000///")
		and node.base_url == "http://may-chu-rieng:6000")
	_check("Online: set_base_url('') tra false + khong doi base_url",
		not node.set_base_url("")
		and node.base_url == "http://may-chu-rieng:6000")
	_check("Online: default_data() dung mac dinh",
		PxbOnline.default_data() == {"base_url": "http://localhost:5000",
			"online": false, "last_health_check_at": 0, "last_health_ok": false,
			"outbox": [], "sent_gift_keys": [], "last_balance": {},
			"last_balance_at": 0})


func _test_health() -> void:
	_reset_stub()
	var node := _new_online()
	var res: Dictionary = await node.health_check()
	_check("Online: health_check ok tra status/game/version dung server that",
		bool(res.get("ok", false)) and String(res.get("status", "")) == "ok"
		and String(res.get("game", "")) == "Pho Xo Bo"
		and String(res.get("version", "")) == "0.1.0-skeleton", str(res))
	_check("Online: health_check ok thi online + last_health_ok true + co moc thoi gian",
		node.is_online() and node.last_health_ok and node.last_health_check_at > 0)
	_check("Online: health_check goi GET dung /health",
		_stub_calls.size() == 1 and String(_stub_calls[0]["method"]) == "GET"
		and String(_stub_calls[0]["url"]) == "http://localhost:5000/health",
		str(_stub_calls))
	# Doi base URL thi health check goi dung dia chi moi.
	node.set_base_url("http://may-chu-rieng:6000")
	_reset_stub()
	res = await node.health_check()
	_check("Online: health_check dung base_url moi",
		String(_stub_calls[0]["url"]) == "http://may-chu-rieng:6000/health",
		str(_stub_calls))
	# Server tra status != "ok" thi coi nhu fail.
	_reset_stub()
	_stub_mode = "health-not-ok"
	res = await node.health_check()
	_check("Online: health tra status error thi ok false + reason health-khong-ok",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "health-khong-ok", str(res))
	_check("Online: health fail thi offline + last_health_ok false",
		not node.is_online() and not node.last_health_ok)
	# Loi mang.
	_reset_stub()
	_stub_mode = "network-fail"
	res = await node.health_check()
	_check("Online: health loi mang thi ok false + reason khong-toi-duoc-server",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "khong-toi-duoc-server", str(res))
	_check("Online: health loi mang thi offline",
		not node.is_online() and not node.last_health_ok)
	# HTTP 500.
	_reset_stub()
	_stub_mode = "http-500"
	res = await node.health_check()
	_check("Online: health http-500 thi ok false + reason http-500",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "http-500", str(res))
	# Moc thoi gian cap nhat moi lan goi.
	_reset_stub()
	var node2 := _new_online()
	node2.last_health_check_at = 0
	await node2.health_check()
	var first_mark: int = node2.last_health_check_at
	await node2.health_check()
	_check("Online: health_check cap nhat moc thoi gian moi lan goi",
		first_mark > 0 and node2.last_health_check_at >= first_mark)


func _test_balance() -> void:
	_reset_stub()
	var node := _new_online()
	var res: Dictionary = await node.balance_of("")
	_check("Online: balance_of('') tra thieu-player-id",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "thieu-player-id", str(res))
	res = await node.balance_of("nguoi-choi-1")
	_check("Online: balance_of tra dung playerId/cash/savings tu server",
		bool(res.get("ok", false)) and String(res.get("player_id", "")) == "nguoi-choi-1"
		and int(res.get("cash_vnd", 0)) == 123456
		and int(res.get("savings_vnd", 0)) == 7890, str(res))
	_check("Online: balance_of cache so du + moc thoi gian",
		String(node.last_balance.get("player_id", "")) == "nguoi-choi-1"
		and int(node.last_balance.get("cash_vnd", 0)) == 123456
		and int(node.last_balance.get("savings_vnd", 0)) == 7890
		and node.last_balance_at > 0)
	_check("Online: cache so du vua lay thi con han (fresh)",
		node.cached_balance_fresh())
	_check("Online: balance_of goi GET dung /ledger/balance/{id}",
		String(_stub_calls[_stub_calls.size() - 1]["method"]) == "GET"
		and String(_stub_calls[_stub_calls.size() - 1]["url"])
			== "http://localhost:5000/ledger/balance/nguoi-choi-1",
		str(_stub_calls[_stub_calls.size() - 1]))
	# Cache het han sau 60 giay.
	node.last_balance_at = int(Time.get_unix_time_from_system() * 1000.0) - 60001
	_check("Online: cache so du qua 60 giay thi het han",
		not node.cached_balance_fresh())
	# Node moi chua co cache thi khong fresh.
	var node2 := _new_online()
	_check("Online: chua lay so du lan nao thi cache khong fresh",
		not node2.cached_balance_fresh())
	# Loi mang: khong ghi de cache cu.
	_reset_stub()
	_stub_mode = "network-fail"
	res = await node.balance_of("nguoi-choi-1")
	_check("Online: balance loi mang thi ok false + reason khong-toi-duoc-server",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "khong-toi-duoc-server", str(res))
	_check("Online: balance loi mang khong ghi de cache cu",
		String(node.last_balance.get("player_id", "")) == "nguoi-choi-1"
		and int(node.last_balance.get("cash_vnd", 0)) == 123456)


func _test_gift() -> void:
	_reset_stub()
	var node := _new_online()
	var res: Dictionary = await node.gift("a", "b", 100000, 5)
	_check("Online: gift hop le tra ok true + key bat dau pxb-",
		bool(res.get("ok", false))
		and String(res.get("key", "")).begins_with("pxb-"), str(res))
	var sent_key: String = String(res.get("key", ""))
	_check("Online: gift xong thi nho key da gui (chong gui lan 2)",
		node.has_sent_key(sent_key))
	_check("Online: gift gui dung POST /ledger/gift + body dung server that",
		String(_stub_calls[_stub_calls.size() - 1]["method"]) == "POST"
		and String(_stub_calls[_stub_calls.size() - 1]["url"])
			== "http://localhost:5000/ledger/gift"
		and String(_stub_calls[_stub_calls.size() - 1]["body"]["FromPlayerId"]) == "a"
		and String(_stub_calls[_stub_calls.size() - 1]["body"]["ToPlayerId"]) == "b"
		and int(_stub_calls[_stub_calls.size() - 1]["body"]["AmountVnd"]) == 100000
		and int(_stub_calls[_stub_calls.size() - 1]["body"]["GameDay"]) == 5
		and String(_stub_calls[_stub_calls.size() - 1]["body"]["IdempotencyKey"]) == sent_key,
		str(_stub_calls[_stub_calls.size() - 1]))
	# Gui lai dung key da gui -> chan.
	res = await node.gift("a", "b", 100000, 5, sent_key)
	_check("Online: gift trung key thi tra trung-idempotency-key, khong gui lan 2",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "trung-idempotency-key"
		and String(res.get("key", "")) == sent_key, str(res))
	_check("Online: gift trung key khong goi them HTTP",
		_stub_calls.size() == 1, str(_stub_calls.size()))
	# Thieu id.
	res = await node.gift("", "b", 100000, 5)
	_check("Online: gift thieu from thi thieu-player-id",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "thieu-player-id", str(res))
	res = await node.gift("a", "", 100000, 5)
	_check("Online: gift thieu to thi thieu-player-id",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "thieu-player-id", str(res))
	# So tien khong hop le.
	res = await node.gift("a", "b", 0, 5)
	_check("Online: gift 0 dong thi so-tien-khong-hop-le",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "so-tien-khong-hop-le", str(res))
	res = await node.gift("a", "b", -5000, 5)
	_check("Online: gift so am thi so-tien-khong-hop-le",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "so-tien-khong-hop-le", str(res))
	res = await node.gift("a", "b", 100.5, 5)
	_check("Online: gift so le 100.5 thi so-tien-khong-hop-le",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "so-tien-khong-hop-le", str(res))
	# Offline: vao outbox.
	_reset_stub()
	_stub_mode = "network-fail"
	res = await node.gift("a", "b", 50000, 3)
	_check("Online: gift offline tra offline-da-luu-outbox + queued true",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "offline-da-luu-outbox"
		and bool(res.get("queued", false)), str(res))
	_check("Online: gift offline thi outbox co 1 mon + node offline",
		node.outbox_count() == 1 and not node.is_online())
	_check("Online: mon outbox giu dung nguoi gui/nhan/so tien/ngay",
		String(node.outbox[0]["from_player_id"]) == "a"
		and String(node.outbox[0]["to_player_id"]) == "b"
		and int(node.outbox[0]["amount_vnd"]) == 50000
		and int(node.outbox[0]["game_day"]) == 3)
	# Server 409 (trung key) thi coi nhu xong, khong vao outbox.
	_reset_stub()
	_stub_mode = "conflict-409"
	res = await node.gift("a", "b", 70000, 2, "khoa-409-rieng")
	_check("Online: gift server tra 409 thi coi nhu xong (ok true)",
		bool(res.get("ok", false))
		and String(res.get("key", "")) == "khoa-409-rieng", str(res))
	_check("Online: gift 409 thi nho key + khong vao outbox",
		node.has_sent_key("khoa-409-rieng") and node.outbox_count() == 1)
	# Server 400: tra loi server, khong vao outbox.
	_reset_stub()
	_stub_mode = "bad-request-400"
	res = await node.gift("a", "b", 80000, 2)
	_check("Online: gift server tra 400 thi tra dung loi server, khong vao outbox",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "so tien <= 0"
		and node.outbox_count() == 1, str(res))
	# Key moi sinh: duy nhat + dung dinh dang.
	var k1: String = node.new_idempotency_key()
	var k2: String = node.new_idempotency_key()
	_check("Online: new_idempotency_key sinh key duy nhat, bat dau pxb-",
		k1 != k2 and k1.begins_with("pxb-") and k2.begins_with("pxb-"),
		k1 + " / " + k2)


func _test_outbox_full() -> void:
	_reset_stub()
	_stub_mode = "network-fail"
	var node := _new_online()
	for i in range(PxbOnline.OUTBOX_MAX):
		await node.gift("a", "b", 1000 + i, 1)
	_check("Online: gift offline 50 lan thi outbox day dung 50",
		node.outbox_count() == 50)
	var res: Dictionary = await node.gift("a", "b", 999999, 1)
	_check("Online: outbox day thi mon thu 51 tra outbox-day, khong mat lang",
		not bool(res.get("ok", true))
		and String(res.get("reason", "")) == "outbox-day"
		and node.outbox_count() == 50, str(res))


func _test_flush() -> void:
	# Chuan bi 3 mon trong outbox (key rieng de kiem tra gui lai dung key cu).
	_reset_stub()
	_stub_mode = "network-fail"
	var node := _new_online()
	await node.gift("a", "b", 10000, 1, "khoa-flush-1")
	await node.gift("a", "b", 20000, 1, "khoa-flush-2")
	await node.gift("a", "b", 30000, 1, "khoa-flush-3")
	_check("Online: chuan bi flush: outbox co 3 mon", node.outbox_count() == 3)
	# Lan 1: mon 1 ok, mon 2 tra 409 (coi nhu xong), mon 3 loi mang -> dung lai.
	_reset_stub()
	_stub_queue = [
		{"ok": true, "status": 200, "data": {"ok": true}},
		{"ok": false, "status": 409, "reason": "http-409",
			"data": {"ok": false, "error": "duplicate-idempotency-key"}},
		{"ok": false, "status": 0, "reason": "khong-toi-duoc-server"},
	]
	var res: Dictionary = await node.flush_outbox()
	_check("Online: flush gui duoc 2 (ok + 409), giu lai 1 loi mang, failed 0",
		int(res.get("sent", -1)) == 2 and int(res.get("kept", -1)) == 1
		and int(res.get("failed", -1)) == 0, str(res))
	_check("Online: flush xong outbox chi con mon loi mang",
		node.outbox_count() == 1
		and String(node.outbox[0]["key"]) == "khoa-flush-3")
	_check("Online: flush nho key cua mon gui duoc + mon 409",
		node.has_sent_key("khoa-flush-1") and node.has_sent_key("khoa-flush-2"))
	# Lan 2: mon con lai gui duoc, dung dung key cu (khong sinh key moi).
	_reset_stub()
	res = await node.flush_outbox()
	_check("Online: flush lan 2 gui het mon con lai",
		int(res.get("sent", -1)) == 1 and int(res.get("kept", -1)) == 0
		and int(res.get("failed", -1)) == 0, str(res))
	_check("Online: flush gui lai dung key cu cua mon (khong sinh key moi)",
		String(_stub_calls[_stub_calls.size() - 1]["body"]["IdempotencyKey"])
			== "khoa-flush-3",
		str(_stub_calls[_stub_calls.size() - 1]))
	# Mon loi 400: giu lai trong outbox, dem vao failed.
	_reset_stub()
	_stub_mode = "network-fail"
	var node2 := _new_online()
	await node2.gift("a", "b", 10000, 1, "khoa-flush-400a")
	await node2.gift("a", "b", 20000, 1, "khoa-flush-400b")
	_reset_stub()
	_stub_queue = [
		{"ok": true, "status": 200, "data": {"ok": true}},
		{"ok": false, "status": 400, "reason": "http-400",
			"data": {"ok": false, "error": "so tien <= 0"}},
	]
	res = await node2.flush_outbox()
	_check("Online: flush mon 400 thi sent 1, kept 1, failed 1 (mon loi o lai)",
		int(res.get("sent", -1)) == 1 and int(res.get("kept", -1)) == 1
		and int(res.get("failed", -1)) == 1, str(res))
	_check("Online: flush mon 400 o lai dung mon do trong outbox",
		node2.outbox_count() == 1
		and String(node2.outbox[0]["key"]) == "khoa-flush-400b")
	# Outbox rong thi flush tra 0/0/0.
	_reset_stub()
	var node3 := _new_online()
	res = await node3.flush_outbox()
	_check("Online: flush outbox rong tra sent 0, kept 0, failed 0",
		int(res.get("sent", -1)) == 0 and int(res.get("kept", -1)) == 0
		and int(res.get("failed", -1)) == 0, str(res))


func _test_signals() -> void:
	_reset_stub()
	_clear_events()
	var node := _new_online()
	await node.health_check()
	_check("Online: health ok phat online_changed(true)",
		_online_events == [true], str(_online_events))
	_stub_mode = "network-fail"
	await node.gift("a", "b", 1000, 1)
	_check("Online: gift offline phat online_changed(false) + outbox_changed(1)",
		_online_events == [true, false] and _outbox_events == [1],
		str(_online_events) + " / " + str(_outbox_events))
	_reset_stub()
	await node.flush_outbox()
	_check("Online: flush gui het thi phat outbox_changed(0)",
		_outbox_events == [1, 0], str(_outbox_events))


func _test_no_endpoint() -> void:
	_reset_stub()
	var node := _new_online()
	var reason := PxbOnline.REASON_NO_ENDPOINT
	_check("Online: create_trade_offer tra server-chua-co-endpoint",
		node.create_trade_offer("a", "b", "xe-may-cu", "xe-dap")
			== {"ok": false, "reason": reason})
	_check("Online: accept_trade tra server-chua-co-endpoint",
		node.accept_trade("trade-1", "a") == {"ok": false, "reason": reason})
	_check("Online: decline_trade tra server-chua-co-endpoint",
		node.decline_trade("trade-1", "a") == {"ok": false, "reason": reason})
	_check("Online: list_auctions tra server-chua-co-endpoint",
		node.list_auctions() == {"ok": false, "reason": reason})
	_check("Online: place_bid tra server-chua-co-endpoint",
		node.place_bid("auc-1", "a", 100000) == {"ok": false, "reason": reason})
	_check("Online: create_company tra server-chua-co-endpoint",
		node.create_company("a", "Cong ty A") == {"ok": false, "reason": reason})
	_check("Online: join_company tra server-chua-co-endpoint",
		node.join_company("a", "cty-1") == {"ok": false, "reason": reason})
	_check("Online: contribute_company tra server-chua-co-endpoint",
		node.contribute_company("a", "cty-1", 1000000)
			== {"ok": false, "reason": reason})
	_check("Online: ham chua-co-endpoint khong goi HTTP nao",
		_stub_calls.is_empty(), str(_stub_calls))


func _test_save() -> void:
	_reset_stub()
	var node := _new_online()
	node.set_base_url("http://may-chu-rieng:5000")
	await node.health_check()
	await node.balance_of("nguoi-choi-9")
	_stub_mode = "network-fail"
	await node.gift("a", "b", 50000, 3, "khoa-luu-1")
	_reset_stub()
	await node.gift("a", "b", 1000, 1, "khoa-da-gui")
	# Gift offline o tren da danh online = false (dung JS); health check
	# lai de online ve true truoc khi lay data() lam mau round-trip.
	await node.health_check()
	var saved: Dictionary = node.data()
	var node2 := _new_online()
	node2.from_data(saved)
	_check("Online: save round-trip giu base_url",
		node2.base_url == "http://may-chu-rieng:5000")
	_check("Online: save round-trip giu online + last_health_ok",
		node2.is_online() and node2.last_health_ok)
	_check("Online: save round-trip giu moc health/balance",
		node2.last_health_check_at == node.last_health_check_at
		and node2.last_balance_at == node.last_balance_at)
	_check("Online: save round-trip giu so du cache",
		String(node2.last_balance.get("player_id", "")) == "nguoi-choi-9"
		and int(node2.last_balance.get("cash_vnd", 0)) == 123456
		and node2.cached_balance_fresh())
	_check("Online: save round-trip giu mon outbox + key da gui",
		node2.outbox_count() == 1
		and String(node2.outbox[0]["key"]) == "khoa-luu-1"
		and node2.has_sent_key("khoa-da-gui"))
	var copy: Dictionary = node.data()
	copy["outbox"].append({"key": "khoa-gia", "from_player_id": "a",
		"to_player_id": "b", "amount_vnd": 1, "game_day": 1, "queued_at": 0})
	copy["sent_gift_keys"].append("khoa-gia-2")
	_check("Online: data() tra ban sao — sua ban sao khong doi node",
		node.outbox_count() == 1 and not node.has_sent_key("khoa-gia-2"))
	# Du lieu ban: base_url rong / khong phai chuoi.
	var node3 := _new_online()
	node3.from_data({"base_url": ""})
	_check("Online: from_data base_url rong ve mac dinh",
		node3.base_url == "http://localhost:5000")
	node3.from_data({"base_url": 12345})
	_check("Online: from_data base_url khong phai chuoi ve mac dinh",
		node3.base_url == "http://localhost:5000")
	node3.from_data({"base_url": "http://x:5000///"})
	_check("Online: from_data base_url cat dau / cuoi",
		node3.base_url == "http://x:5000")
	# Du lieu ban: moc thoi gian am / khong phai so.
	node3.from_data({"last_health_check_at": -5, "last_balance_at": "abc"})
	_check("Online: from_data moc thoi gian ban ve 0",
		node3.last_health_check_at == 0 and node3.last_balance_at == 0)
	# Du lieu ban: outbox — mon thieu key / thieu nguoi / tien sai / tien am.
	var dirty_outbox := saved.duplicate(true)
	dirty_outbox["outbox"] = [
		{"key": "khoa-sach", "from_player_id": "a", "to_player_id": "b",
			"amount_vnd": 1000, "game_day": 2, "queued_at": 111},
		{"key": "", "from_player_id": "a", "to_player_id": "b",
			"amount_vnd": 1000, "game_day": 1, "queued_at": 0},
		{"key": "khoa-thieu-nguoi", "from_player_id": "", "to_player_id": "b",
			"amount_vnd": 1000, "game_day": 1, "queued_at": 0},
		{"key": "khoa-tien-am", "from_player_id": "a", "to_player_id": "b",
			"amount_vnd": -5, "game_day": 1, "queued_at": 0},
		{"key": "khoa-tien-chu", "from_player_id": "a", "to_player_id": "b",
			"amount_vnd": "nhieu", "game_day": 1, "queued_at": 0},
		"khoa-khong-phai-dict",
	]
	var node4 := _new_online()
	node4.from_data(dirty_outbox)
	_check("Online: from_data chi giu mon outbox sach, bo mon ban",
		node4.outbox_count() == 1
		and String(node4.outbox[0]["key"]) == "khoa-sach"
		and int(node4.outbox[0]["game_day"]) == 2
		and int(node4.outbox[0]["queued_at"]) == 111)
	# Outbox qua 50 mon thi cat ve 50.
	var big_outbox: Array = []
	for i in range(55):
		big_outbox.append({"key": "khoa-%d" % i, "from_player_id": "a",
			"to_player_id": "b", "amount_vnd": 1000, "game_day": 1,
			"queued_at": 0})
	var node5 := _new_online()
	node5.from_data({"outbox": big_outbox})
	_check("Online: from_data outbox qua 50 mon thi cat ve 50",
		node5.outbox_count() == 50)
	# Du lieu ban: key da gui — rong / trung / khong phai chuoi / qua 200.
	var node6 := _new_online()
	node6.from_data({"sent_gift_keys": ["k1", "k1", "", 123, "k2"]})
	_check("Online: from_data key da gui bo rong/trung/khong-phai-chuoi",
		node6.sent_gift_keys == ["k1", "k2"], str(node6.sent_gift_keys))
	var many_keys: Array = []
	for i in range(205):
		many_keys.append("khoa-%d" % i)
	node6.from_data({"sent_gift_keys": many_keys})
	_check("Online: from_data key da gui qua 200 thi cat cu nhat, giu 200",
		node6.sent_gift_keys.size() == 200
		and String(node6.sent_gift_keys[0]) == "khoa-5"
		and String(node6.sent_gift_keys[199]) == "khoa-204")
	# Du lieu ban: so du — tien khong phai so / am, thieu player_id.
	var node7 := _new_online()
	node7.from_data({"last_balance": {"player_id": "p1",
		"cash_vnd": "nhieu", "savings_vnd": -100}})
	_check("Online: from_data so du ban thi tien ve 0, giu player_id",
		String(node7.last_balance.get("player_id", "")) == "p1"
		and int(node7.last_balance.get("cash_vnd", -1)) == 0
		and int(node7.last_balance.get("savings_vnd", -1)) == 0)
	node7.from_data({"last_balance": {"player_id": ""}})
	_check("Online: from_data so du thieu player_id thi bo ca so du",
		node7.last_balance.is_empty())
	node7.from_data({"last_balance": "khong-phai-dict"})
	_check("Online: from_data so du khong phai dict thi bo",
		node7.last_balance.is_empty())
	# from_data({}) reset ve mac dinh.
	var node8 := _new_online()
	node8.set_base_url("http://x:5000")
	node8.online = true
	node8.sent_gift_keys.append("khoa-x")
	node8.from_data({})
	_check("Online: from_data({}) reset ve mac dinh",
		node8.base_url == "http://localhost:5000" and not node8.is_online()
		and node8.sent_gift_keys.is_empty() and node8.outbox_count() == 0)
	# reset_state().
	var node9 := _new_online()
	node9.set_base_url("http://x:5000")
	node9.online = true
	node9.last_health_ok = true
	node9.last_balance = {"player_id": "p", "cash_vnd": 1, "savings_vnd": 2}
	node9.last_balance_at = 999
	node9.sent_gift_keys.append("khoa-x")
	_check("Online: reset_state() tra true + ve mac dinh",
		node9.reset_state()
		and node9.base_url == "http://localhost:5000"
		and not node9.is_online() and not node9.last_health_ok
		and node9.last_balance.is_empty() and node9.last_balance_at == 0
		and node9.sent_gift_keys.is_empty() and node9.outbox_count() == 0)
