extends SceneTree
## G4 BATTLE HOLD BENEFITS test — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g4_battle_hold_benefits_test.gd
## Kiem tra (G4 buoc 8): quyen loi giu sap ap vao Economy —
## gia si -10% khi mua (Main.buy_item truyen discount tu
## hold_benefits; tien thue phong tro khong giam), thue sap -20%
## (phi dau gia 5% con 4%), Danh vong +10 moi ngay game khi dang
## giu sap; het han thi het quyen loi. In "G4 BATTLE HOLD
## BENEFITS TEST: n/n PASS".

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null
var _fame_before := 0
var _day_before := 0


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)


func _key_b() -> void:
	var ev := InputEventKey.new()
	ev.keycode = KEY_B
	ev.pressed = true
	ev.echo = false
	_main._unhandled_input(ev)


func _finish_current(winner: String) -> void:
	_main.battle_mb._finish_battle(_main.battle_scene.battle, winner)


func _holding_state() -> Dictionary:
	return {"holds": {"sap-cho-dau-moi": {
		"teamId": "doi-ban", "teamName": "Đội Bạn",
		"startGameDay": 1, "untilGameDay": 8}}, "history": []}


func _on_frame() -> void:
	_frame += 1
	if Time.get_ticks_msec() > 90000:
		print("G4 BATTLE HOLD BENEFITS TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# --- Muc tinh: hold_benefits ---
				var st := _holding_state()
				var ben: Dictionary = PxbMarketBattle.hold_benefits(st, "doi-ban", 3)
				_check("hold: dung sap dang giu",
					str(ben.get("stallId", "")) == "sap-cho-dau-moi",
					"ben=%s" % str(ben))
				_check("hold: gia si -10%",
					int(ben.get("wholesaleDiscountPercent", -1)) == 10,
					"ben=%s" % str(ben))
				_check("hold: thue sap -20%",
					int(ben.get("stallTaxCutPercent", -1)) == 20,
					"ben=%s" % str(ben))
				_check("hold: Danh vong +10/ngay",
					int(ben.get("famePerDay", -1)) == 10,
					"ben=%s" % str(ben))
				_check("hold: doi khac khong co quyen loi",
					PxbMarketBattle.hold_benefits(st, "doi-cho", 3).is_empty())
				_check("hold: het han dung ngay het thi het quyen loi",
					PxbMarketBattle.hold_benefits(st, "doi-ban", 8).is_empty())
				_check("hold: khong giu sap thi {}",
					PxbMarketBattle.hold_benefits({}, "doi-ban", 3).is_empty())
				# --- Muc Economy: gia si ---
				var eco := PxbEconomy.new()
				eco.money = 4600000
				var r: Dictionary = eco.buy("dien-thoai-cu", 10)
				_check("eco: giam 10% thi du tien mua",
					bool(r.get("ok", false)), "r=%s" % str(r))
				_check("eco: chi tru 4.500.000",
					eco.money == 100000, "money=%d" % eco.money)
				_check("eco: price_paid 4.500.000",
					int(r.get("price_paid", -1)) == 4500000, "r=%s" % str(r))
				var eco2 := PxbEconomy.new()
				eco2.money = 4600000
				var r2: Dictionary = eco2.buy("dien-thoai-cu")
				_check("eco: khong giam thi khong du tien",
					not bool(r2.get("ok", true))
					and String(r2.get("reason", "")) == "khong-du-tien",
					"r2=%s" % str(r2))
				_check("eco: mua hong khong tru tien",
					eco2.money == 4600000, "money=%d" % eco2.money)
				var eco3 := PxbEconomy.new()
				eco3.money = 2000000
				var r3: Dictionary = eco3.buy("phong-tro", 10)
				_check("eco: thue phong tro khong giam gia",
					bool(r3.get("ok", false))
					and eco3.money == 0
					and int(r3.get("price_paid", -1)) == 2000000,
					"r3=%s money=%d" % [str(r3), eco3.money])
				# --- Muc Economy: thue sap ---
				_check("eco: dau gia mac dinh 1.000.000 -> 950.000",
					PxbEconomy.auction_seller_receives(1000000) == 950000)
				_check("eco: giu sap thue -20% -> phi 4%, nhan 960.000",
					PxbEconomy.auction_seller_receives(1000000, 20) == 960000)
				_check("eco: dau gia le 999.999 mac dinh -> 949.999",
					PxbEconomy.auction_seller_receives(999999) == 949999)
				eco.free()
				eco2.free()
				eco3.free()
				_main._on_start_pressed()
				_key_b()
				_state = 1
		1:
			if _frame >= 6:
				_check("phim B mo tran", _main.battle_open)
				_finish_current("A")
				_state = 2
		2:
			if _frame >= 8:
				_check("thang: giu sap-cho-dau-moi",
					(_main.battle_state.get("holds", {}) as Dictionary).has("sap-cho-dau-moi"))
				var ben: Dictionary = _main._hold_benefits_now()
				_check("main: _hold_benefits_now co quyen loi",
					str(ben.get("stallId", "")) == "sap-cho-dau-moi"
					and int(ben.get("wholesaleDiscountPercent", -1)) == 10,
					"ben=%s" % str(ben))
				_main.jobs.gold = 4600000
				var res: Dictionary = _main.buy_item("dien-thoai-cu")
				_check("main: giu sap mua duoc voi 4.600.000",
					bool(res.get("ok", false)), "res=%s" % str(res))
				_check("main: vi con 100.000 sau khi mua gia si",
					_main.jobs.gold == 100000, "gold=%d" % _main.jobs.gold)
				_check("main: price_paid 4.500.000",
					int(res.get("price_paid", -1)) == 4500000, "res=%s" % str(res))
				_fame_before = _main.fame
				_day_before = _main.day
				_main._advance_frame()
				_main._advance_frame()
				_main._advance_frame()
				_state = 3
		3:
			if _frame >= 10:
				_check("main: sang ngay moi sau 3 khung",
					_main.day == _day_before + 1,
					"day=%d truoc=%d" % [_main.day, _day_before])
				_check("main: giu sap +10 Danh vong/ngay",
					_main.fame == _fame_before + 10,
					"fame=%d truoc=%d" % [_main.fame, _fame_before])
				# Het quyen loi: xoa giu sap -> mua gia day du + khong +fame.
				_main.battle_state = {}
				_check("main: het giu sap thi het quyen loi",
					_main._hold_benefits_now().is_empty())
				_main.jobs.gold = 4600000
				var res2: Dictionary = _main.buy_item("dien-thoai-cu")
				_check("main: het giu sap mua 4.600.000 khong du",
					not bool(res2.get("ok", true))
					and String(res2.get("reason", "")) == "khong-du-tien",
					"res2=%s" % str(res2))
				_main.jobs.gold = 5000000
				var res3: Dictionary = _main.buy_item("dien-thoai-cu")
				_check("main: het giu sap mua gia day 5.000.000 ok",
					bool(res3.get("ok", false))
					and _main.jobs.gold == 0
					and int(res3.get("price_paid", -1)) == 5000000,
					"res3=%s gold=%d" % [str(res3), _main.jobs.gold])
				_fame_before = _main.fame
				_day_before = _main.day
				_main._advance_frame()
				_main._advance_frame()
				_main._advance_frame()
				_state = 4
		4:
			if _frame >= 12:
				_check("main: sang ngay moi (khong giu sap)",
					_main.day == _day_before + 1,
					"day=%d truoc=%d" % [_main.day, _day_before])
				_check("main: khong giu sap thi khong +Danh vong/ngay",
					_main.fame == _fame_before,
					"fame=%d truoc=%d" % [_main.fame, _fame_before])
				_key_b()
				_state = 5
		5:
			if _frame >= 14:
				_check("dong tran cuoi", not _main.battle_open)
				print("G4 BATTLE HOLD BENEFITS TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
