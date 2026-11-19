extends SceneTree
## G2 UI wiring part 2 test — chay scene Main that headless, kiem tra
## PhoneHub (mo/dong/tab/chua doc) + SaveCloud (luu/tai slot 1) +
## Economy (mua/gui/rut, vi chung jobs.gold) + Education (dang ky /
## tot nghiep) + Social (tro chuyen) + Story (len chuong) + Tools
## (nhan/nang cap So Tay) + Online (trang thai ban dau) dung that:
##   godot --headless --path src/godot -s res://tests/g2_ui_wiring2_test.gd

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 900:
		print("G2 UI WIRING2: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("he phan 2 da tao",
					_main.phonehub != null and _main.savecloud != null
					and _main.economy != null and _main.education != null
					and _main.social != null and _main.titles != null
					and _main.story != null and _main.tools != null
					and _main.online != null)
				_check("social seed co Ban than",
					not _main.social.get_rel("ban-than").is_empty())
				_check("story bat dau chuong 1", _main.story.chapter == 1)
				_check("nut dien thoai ban dau", _main._phone_btn.text == "Điện thoại (P)")
				_check("panel dien thoai an", not _main._phone_panel.visible)
				# Chung tui: sua hotspot.materials thi tools thay ngay.
				_main.hotspot.materials["kiem-tra-chung-tui"] = 1
				_check("tools dung chung tui voi hotspot",
					int(_main.tools.materials.get("kiem-tra-chung-tui", 0)) == 1)
				_main.hotspot.materials.erase("kiem-tra-chung-tui")
				_state = 1
		1:
			# Dien thoai: mo -> tab mac dinh -> doi tab Cho -> notify
			# Hoc tap -> mo tab Hoc tap xoa chua doc -> dong.
			_main._open_phone()
			_check("mo dien thoai", _main.phonehub.is_open)
			_check("panel dien thoai hien", _main._phone_panel.visible)
			_check("tab mac dinh Danh ba", _main.phonehub.current_tab == "danh-ba-tin-nhan")
			_main._on_phone_tab_pressed("cho")
			_check("doi tab Cho", _main.phonehub.current_tab == "cho")
			_check("noi dung tab Cho co chu Cho", "Chợ" in _main._phone_content.text)
			_main.phonehub.notify("hoc-tap")
			_check("notify hoc-tap: total 1", _main.phonehub.total_unread() == 1)
			_main._update_hud()
			_check("nut dien thoai hien (1)", _main._phone_btn.text == "Điện thoại (1)")
			_main._on_phone_tab_pressed("hoc-tap")
			_check("mo tab Hoc tap xoa chua doc", _main.phonehub.total_unread() == 0)
			_main._close_phone()
			_check("dong dien thoai", not _main.phonehub.is_open)
			_check("panel dien thoai an lai", not _main._phone_panel.visible)
			_state = 2
		2:
			# Cho + ngan hang, vi chung la jobs.gold.
			_main.jobs.gold = 5000000
			var b1: Dictionary = _main.buy_item("ao-dai")
			_check("mua Ao dai ok", bool(b1.get("ok", false)))
			_check("vi con 3000000", _main.jobs.gold == 3000000)
			_check("da so huu ao-dai", _main.economy.owned.has("ao-dai"))
			_check("ao-dai khong cong danh vong", _main.fame == 0)
			var b2: Dictionary = _main.buy_item("phong-tro")
			_check("thue Phong tro ok", bool(b2.get("ok", false)))
			_check("vi con 1000000", _main.jobs.gold == 1000000)
			var b3: Dictionary = _main.buy_item("xe-dap")
			_check("mua Xe dap 0d ok", bool(b3.get("ok", false)))
			var b4: Dictionary = _main.buy_item("xe-sang")
			_check("xe-sang khong du tien",
				not bool(b4.get("ok", true)) and String(b4.get("reason", "")) == "khong-du-tien")
			_check("khong du tien khong tru vi", _main.jobs.gold == 1000000)
			_check("gui 1000000 tiet kiem", _main.deposit_savings(1000000))
			_check("tien mat ve 0", _main.jobs.gold == 0)
			_check("tiet kiem 1000000", _main.economy.savings == 1000000)
			_check("rut 500000 tiet kiem", _main.withdraw_savings(500000))
			_check("vi lai 500000", _main.jobs.gold == 500000)
			_check("tiet kiem con 500000", _main.economy.savings == 500000)
			_check("rut vuot tiet kiem bi chan", not _main.withdraw_savings(600000))
			_state = 3
		3:
			# Hoc tap: dang ky THPT (0d, 30 ngay) -> tot nghiep ngay 31;
			# dang ky Cao dang (20tr) -> tot nghiep ngay 91 (+500 EXP).
			var e1: Dictionary = _main.enroll_degree(0)
			_check("dang ky THPT ok", bool(e1.get("ok", false)))
			_check("THPT hoc phi 0", int(e1.get("fee_paid", -1)) == 0)
			var e2: Dictionary = _main.enroll_degree(1)
			_check("dang hoc thi chan dang ky moi",
				not bool(e2.get("ok", true)) and String(e2.get("reason", "")) == "dang-hoc")
			_main.education.day_number = 31
			_main._check_graduations()
			_check("tot nghiep THPT", _main.education.has_degree_or_higher(0))
			_check("THPT khong cong EXP", _main.jobs.exp_total == 0)
			_main.jobs.gold = 25000000
			var e3: Dictionary = _main.enroll_degree(1)
			_check("dang ky Cao dang ok", bool(e3.get("ok", false)))
			_check("Cao dang tru hoc phi 20tr", _main.jobs.gold == 5000000)
			_main.education.day_number = 91
			_main._check_graduations()
			_check("tot nghiep Cao dang", _main.education.has_degree_or_higher(1))
			_check("Cao dang +500 EXP", _main.jobs.exp_total == 500)
			# Khoa ngan han mau: Sang tao 3 ngay, 2tr.
			var e4: Dictionary = _main.enroll_short_course()
			_check("dang ky khoa ngan ok", bool(e4.get("ok", false)))
			_check("khoa ngan tru phi 2tr", _main.jobs.gold == 3000000)
			_main.education.day_number = 94
			_main._check_graduations()
			_check("xong khoa ngan: pending sang 10",
				int(_main.education.pending_stat_gain.get("sang", 0)) == 10)
			_state = 4
		4:
			# Xa hoi + cot truyen: tro chuyen Ban than +5; len chuong 2
			# (Tri 100 >= 40); Tools: nhan So Tay roi nang len bac 2.
			var ok_chat: bool = _main.interact_friend("ban-than")
			_check("tro chuyen Ban than ok", ok_chat)
			_check("than thiet 20 -> 25",
				int(_main.social.get_rel("ban-than").get("closeness", 0)) == 25)
			var adv: bool = _main.advance_story_chapter()
			_check("len chuong 2 (Tri 100)", adv)
			_check("dang o chuong 2", _main.story.chapter == 2)
			_main.hotspot.materials["la-chuoi"] = 2
			_main.hotspot.materials["vai-vun"] = 1
			var t1: Dictionary = _main.acquire_tool("SoTay")
			_check("nhan So Tay ok", bool(t1.get("ok", false)))
			_check("So Tay bac 1", _main.tools.tool_tier("SoTay") == 1)
			_main.hotspot.materials["la-chuoi"] = 4
			_main.hotspot.materials["vai-vun"] = 2
			var t2: Dictionary = _main.upgrade_tool("SoTay")
			_check("nang So Tay len bac 2", bool(t2.get("ok", false)))
			_check("So Tay bac 2", _main.tools.tool_tier("SoTay") == 2)
			var t3: Dictionary = _main.acquire_tool("XeDay")
			_check("Xe Day phai che, khong nhan truc tiep",
				not bool(t3.get("ok", true)) and String(t3.get("reason", "")) == "dung-che-tao")
			_state = 5
		5:
			# Save/Load slot 1: luu -> doi state (vi 999, ngay 9, The 50)
			# -> tai -> state khoi phuc dung.
			var s1: Dictionary = _main.save_game(1)
			_check("luu slot 1 ok", bool(s1.get("ok", false)))
			_check("luu xuong file", String(s1.get("where", "")) == "file")
			_main.jobs.gold = 999
			_main.day = 9
			_main.stats.set_stat("the", 50)
			var l0: Dictionary = _main.load_game(2)
			_check("slot 2 trong", not bool(l0.get("ok", true)))
			var l1: Dictionary = _main.load_game(1)
			_check("tai slot 1 ok", bool(l1.get("ok", false)))
			_check("ngay khoi phuc ve 1", _main.day == 1)
			_check("vi khoi phuc 3000000", _main.jobs.gold == 3000000)
			_check("The khoi phuc 100", _main.stats.the == 100)
			_check("chuong khoi phuc 2", _main.story.chapter == 2)
			_check("So Tay khoi phuc bac 2", _main.tools.tool_tier("SoTay") == 2)
			_check("bang Cao dang khoi phuc", _main.education.has_degree_or_higher(1))
			_check("than thiet khoi phuc 25",
				int(_main.social.get_rel("ban-than").get("closeness", 0)) == 25)
			_check("ao-dai khoi phuc", _main.economy.owned.has("ao-dai"))
			_check("tiet kiem khoi phuc 500000", _main.economy.savings == 500000)
			# Sau load, tui chung van dung chung (tools thay doi cua hotspot).
			_main.hotspot.materials["kiem-tra-sau-load"] = 3
			_check("sau load tools van chung tui",
				int(_main.tools.materials.get("kiem-tra-sau-load", 0)) == 3)
			_main.hotspot.materials.erase("kiem-tra-sau-load")
			DirAccess.remove_absolute("user://pxb_savecloud_1.save")
			_state = 6
		6:
			# Online: ban dau ngoai tuyen, outbox trong; upload khi chua
			# dang nhap bi chan dung ly do (khong gia vo dong bo).
			_check("online ban dau ngoai tuyen", not _main.online.is_online())
			_check("outbox ban dau trong", _main.online.outbox_count() == 0)
			_check("cache so du het han", not _main.online.cached_balance_fresh())
			var up: Dictionary = _main.savecloud.upload_save(1)
			_check("upload chua dang nhap -> chua-dang-nhap",
				not bool(up.get("ok", true)) and String(up.get("reason", "")) == "chua-dang-nhap")
			_state = 7
		7:
			print("G2 UI WIRING2: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
