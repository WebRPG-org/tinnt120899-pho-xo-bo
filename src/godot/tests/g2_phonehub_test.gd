extends SceneTree
## G2 PHONEHUB selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_phonehub_test.gd
## Kiem tra: PxbPhoneHub (port PXB_PhoneHub.js / PhoneHub.cs) — 9 tab
## dung thu tu GDD Muc 2, mo/dong/doi tab, notify + so chua doc,
## signal tab_changed / open_changed (thu tu + quirk giong C#/JS),
## save round-trip + bo du lieu ban.
## In "G2 PHONEHUB SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd (tranh xung dot voi luong song song).

var _pass := 0
var _fail := 0

var _tab_events: Array = []
var _open_events: Array = []
var _seq: Array = []
var _hubs: Array = [] # hub da tao — free o cuoi de log sach (khong leak resource)


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	_test_tabs()
	_test_open_close_toggle()
	_test_select_tab()
	_test_notify()
	_test_signals()
	_test_save()
	print("G2 PHONEHUB SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	for h in _hubs:
		h.free()
	quit(0 if _fail == 0 else 1)


func _on_tab_changed(tab_id: String) -> void:
	_tab_events.append(tab_id)
	_seq.append("tab:" + tab_id)


func _on_open_changed(is_open: bool) -> void:
	_open_events.append(is_open)
	_seq.append("open:" + ("true" if is_open else "false"))


func _new_hub() -> PxbPhoneHub:
	var hub := PxbPhoneHub.new()
	hub.tab_changed.connect(_on_tab_changed)
	hub.open_changed.connect(_on_open_changed)
	_hubs.append(hub)
	return hub


func _clear_events() -> void:
	_tab_events.clear()
	_open_events.clear()
	_seq.clear()


func _test_tabs() -> void:
	_check("PhoneHub: dung 9 tab", PxbPhoneHub.tab_ids().size() == 9)
	_check("PhoneHub: thu tu tab dung GDD Muc 2",
		PxbPhoneHub.tab_ids() == ["danh-ba-tin-nhan", "ngan-hang", "ban-do",
			"viec-lam", "cho", "hoc-tap", "suc-khoe", "xa-hoi", "cai-dat"])
	_check("PhoneHub: tab mac dinh la Danh ba / Tin nhan",
		PxbPhoneHub.DEFAULT_TAB == "danh-ba-tin-nhan")
	_check("PhoneHub: ten tab Danh ba / Tin nhan co dau day du",
		PxbPhoneHub.tab_name("danh-ba-tin-nhan") == "Danh bạ / Tin nhắn")
	_check("PhoneHub: ten tab Ngan hang", PxbPhoneHub.tab_name("ngan-hang") == "Ngân hàng")
	_check("PhoneHub: ten tab Ban do", PxbPhoneHub.tab_name("ban-do") == "Bản đồ")
	_check("PhoneHub: ten tab Viec lam", PxbPhoneHub.tab_name("viec-lam") == "Việc làm")
	_check("PhoneHub: ten tab Cho", PxbPhoneHub.tab_name("cho") == "Chợ")
	_check("PhoneHub: ten tab Hoc tap", PxbPhoneHub.tab_name("hoc-tap") == "Học tập")
	_check("PhoneHub: ten tab Suc khoe (theo C#, khac chinh ta GDD)",
		PxbPhoneHub.tab_name("suc-khoe") == "Sức khỏe")
	_check("PhoneHub: ten tab Xa hoi", PxbPhoneHub.tab_name("xa-hoi") == "Xã hội")
	_check("PhoneHub: ten tab Cai dat", PxbPhoneHub.tab_name("cai-dat") == "Cài đặt")
	_check("PhoneHub: tab_name tab la tra ''", PxbPhoneHub.tab_name("khong-co") == "")
	_check("PhoneHub: tab_exists dung/sai",
		PxbPhoneHub.tab_exists("ban-do") and not PxbPhoneHub.tab_exists("khong-co"))
	_check("PhoneHub: PHONE_KEY_CODE la phim P", PxbPhoneHub.PHONE_KEY_CODE == KEY_P)
	var lst := PxbPhoneHub.tab_list()
	_check("PhoneHub: tab_list dung 9 muc + ten dau dung",
		lst.size() == 9 and String(lst[0]["name"]) == "Danh bạ / Tin nhắn")
	lst[0]["name"] = "DOI"
	_check("PhoneHub: sua tab_list tra ve khong doi TABS goc",
		PxbPhoneHub.tab_name("danh-ba-tin-nhan") == "Danh bạ / Tin nhắn")


func _test_open_close_toggle() -> void:
	var hub := _new_hub()
	_check("PhoneHub: moi tao thi dong + tab mac dinh",
		not hub.is_open and hub.current_tab == "danh-ba-tin-nhan")
	_check("PhoneHub: moi tao thi chua doc = 0", hub.total_unread() == 0)
	_clear_events()
	hub.open()
	_check("PhoneHub: open() mo o tab mac dinh",
		hub.is_open and hub.current_tab == "danh-ba-tin-nhan")
	_check("PhoneHub: open() phat tab_changed roi open_changed(true)",
		_seq == ["tab:danh-ba-tin-nhan", "open:true"], str(_seq))
	_clear_events()
	hub.open("ban-do")
	_check("PhoneHub: open('ban-do') doi tab + van mo",
		hub.is_open and hub.current_tab == "ban-do")
	_check("PhoneHub: open('ban-do') phat dung thu tu",
		_seq == ["tab:ban-do", "open:true"], str(_seq))
	_clear_events()
	hub.close()
	_check("PhoneHub: close() dong nhung GIU tab hien tai",
		not hub.is_open and hub.current_tab == "ban-do")
	_check("PhoneHub: close() phat open_changed(false)",
		_open_events == [false], str(_open_events))
	_check("PhoneHub: close() khong phat tab_changed", _tab_events.is_empty())
	_clear_events()
	hub.toggle()
	_check("PhoneHub: toggle() khi dong thi mo lai dung tab truoc khi dong",
		hub.is_open and hub.current_tab == "ban-do")
	_check("PhoneHub: toggle() mo lai phat dung thu tu",
		_seq == ["tab:ban-do", "open:true"], str(_seq))
	_clear_events()
	hub.toggle()
	_check("PhoneHub: toggle() khi mo thi dong", not hub.is_open)
	_check("PhoneHub: toggle() dong phat open_changed(false)",
		_open_events == [false], str(_open_events))
	_clear_events()
	hub.close()
	_check("PhoneHub: close() khi da dong san van phat open_changed(false) (quirk C#)",
		_open_events == [false], str(_open_events))
	_check("PhoneHub: close() khi da dong san van dong", not hub.is_open)
	_clear_events()
	hub.open("tab-la-khong-co")
	_check("PhoneHub: open(tab la) van mo + phat open_changed (quirk JS)",
		hub.is_open and _open_events == [true], str(_open_events))
	_check("PhoneHub: open(tab la) khong doi tab + khong phat tab_changed",
		hub.current_tab == "ban-do" and _tab_events.is_empty())


func _test_select_tab() -> void:
	var hub := _new_hub()
	_clear_events()
	_check("PhoneHub: select_tab('viec-lam') tra true",
		hub.select_tab("viec-lam") and hub.current_tab == "viec-lam")
	_check("PhoneHub: select_tab phat tab_changed",
		_tab_events == ["viec-lam"], str(_tab_events))
	_clear_events()
	hub.select_tab("viec-lam")
	_check("PhoneHub: select_tab dung tab hien tai van phat tab_changed (quirk C#)",
		_tab_events == ["viec-lam"], str(_tab_events))
	_clear_events()
	_check("PhoneHub: select_tab tab la tra false",
		not hub.select_tab("khong-co"))
	_check("PhoneHub: select_tab tab la khong doi tab + khong phat signal",
		hub.current_tab == "viec-lam" and _tab_events.is_empty() and _open_events.is_empty())
	hub.notify("cho")
	hub.notify("cho")
	_check("PhoneHub: notify Cho 2 lan thi chua doc = 2", hub.unread_count("cho") == 2)
	hub.select_tab("cho")
	_check("PhoneHub: mo tab thi danh dau da doc (chua doc ve 0)",
		hub.unread_count("cho") == 0)


func _test_notify() -> void:
	var hub := _new_hub()
	_check("PhoneHub: notify tab dung tra true", hub.notify("ngan-hang"))
	_check("PhoneHub: unread_count tab chua notify = 0",
		hub.unread_count("danh-ba-tin-nhan") == 0)
	hub.notify("ngan-hang")
	hub.notify("ban-do")
	_check("PhoneHub: notify cong don theo tab",
		hub.unread_count("ngan-hang") == 2 and hub.unread_count("ban-do") == 1)
	_check("PhoneHub: total_unread cong don moi tab", hub.total_unread() == 3)
	_check("PhoneHub: notify tab la tra false", not hub.notify("khong-co"))
	_check("PhoneHub: notify tab la khong doi tong", hub.total_unread() == 3)
	_check("PhoneHub: unread_count tab la = 0", hub.unread_count("khong-co") == 0)
	# Notify dem ca khi dien thoai dang dong (quirk C#).
	_check("PhoneHub: dang dong, notify van dem (quirk C#)",
		not hub.is_open and hub.notify("cho") and hub.unread_count("cho") == 1)
	hub.open()
	_check("PhoneHub: mo ra van thay cham do cua tin den luc dong",
		hub.unread_count("cho") == 1 and hub.total_unread() == 4)


func _test_signals() -> void:
	var hub := _new_hub()
	_clear_events()
	hub.open("hoc-tap")
	hub.notify("xa-hoi")
	hub.select_tab("xa-hoi")
	hub.close()
	_check("PhoneHub: chuoi signal mo -> notify -> doi tab -> dong dung thu tu",
		_seq == ["tab:hoc-tap", "open:true", "tab:xa-hoi", "open:false"], str(_seq))
	_check("PhoneHub: mo tab Xa hoi xoa chua doc cua no",
		hub.unread_count("xa-hoi") == 0)
	# Hai hub khac nhau: signal cua hub nay khong lan sang hub kia
	# (moi hub co signal rieng; test chi kiem tra hub moi khong nhan
	# signal cu — _seq da clear truoc khi mo hub moi).
	var hub2 := _new_hub()
	_clear_events()
	hub2.open("cai-dat")
	_check("PhoneHub: hub moi phat signal rieng",
		_seq == ["tab:cai-dat", "open:true"], str(_seq))
	_check("PhoneHub: hub cu khong doi khi hub moi mo",
		not hub.is_open and hub.current_tab == "xa-hoi")


func _test_save() -> void:
	var hub := _new_hub()
	hub.open("viec-lam")
	hub.notify("cho")
	hub.notify("cho")
	hub.notify("suc-khoe")
	var saved: Dictionary = hub.data()
	var hub2 := _new_hub()
	hub2.from_data(saved)
	_check("PhoneHub: save round-trip giu is_open",
		hub2.is_open == true)
	_check("PhoneHub: save round-trip giu current_tab",
		hub2.current_tab == "viec-lam")
	_check("PhoneHub: save round-trip giu so chua doc theo tab",
		hub2.unread_count("cho") == 2 and hub2.unread_count("suc-khoe") == 1)
	_check("PhoneHub: save round-trip giu tong chua doc",
		hub2.total_unread() == 3)
	var copy: Dictionary = hub.data()
	copy["unread"]["cho"] = 99
	_check("PhoneHub: data() tra ban sao — sua ban sao khong doi hub",
		hub.unread_count("cho") == 2)
	var dirty := saved.duplicate(true)
	dirty["unread"]["tab-la"] = 5
	dirty["unread"]["cho"] = -3
	dirty["unread"]["ngan-hang"] = "khong-phai-so"
	dirty["current_tab"] = "tab-la"
	var hub3 := _new_hub()
	hub3.from_data(dirty)
	_check("PhoneHub: from_data bo tab la trong unread",
		hub3.unread_count("tab-la") == 0)
	_check("PhoneHub: from_data kep so chua doc am ve 0",
		hub3.unread_count("cho") == 0)
	_check("PhoneHub: from_data bo so chua doc khong phai so",
		hub3.unread_count("ngan-hang") == 0)
	_check("PhoneHub: from_data current_tab la ve tab mac dinh",
		hub3.current_tab == "danh-ba-tin-nhan")
	_check("PhoneHub: from_data giu is_open + tab dung con lai",
		hub3.is_open and hub3.unread_count("suc-khoe") == 1)
	var hub4 := _new_hub()
	hub4.open("ban-do")
	hub4.from_data({})
	_check("PhoneHub: from_data({}) reset ve mac dinh (dong + tab dau + 0 chua doc)",
		not hub4.is_open and hub4.current_tab == "danh-ba-tin-nhan"
		and hub4.total_unread() == 0)
	_check("PhoneHub: default_data() dung mac dinh",
		PxbPhoneHub.default_data() == {"is_open": false,
			"current_tab": "danh-ba-tin-nhan", "unread": {}})
