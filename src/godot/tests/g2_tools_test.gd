extends SceneTree
## G2 TOOLS selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_tools_test.gd
## Kiem tra: PxbTools (port PXB_Tools.js / Crafting.cs) — 4 cong cu x 3
## bac, 12 cau ToolBehaviour dung nguyen van, hanh vi tung bac khac
## nhau that (suc cho / duong mua / hotspot an-hiem / goi y So Tay /
## nhặt Xeng), nang cap + nhan bac 1 dung/sai dieu kien, data() /
## from_data() round-trip + bo du lieu ban, reset_state, dong bo 2
## chieu voi PxbCrafting, uy quyen goi y cho PxbCrafting / PxbHotspot.
## In "G2 TOOLS SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd (tranh xung dot voi luong song song).

var _pass := 0
var _fail := 0

var _tool_events: Array = []
var _tools_list: Array = [] # tools da tao — free o cuoi de log sach (khong leak resource)
var _others: Array = [] # crafting / hotspot / time da tao — free o cuoi


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	_test_constants()
	_test_behaviour_12_cau()
	_test_recipes()
	_test_acquire_upgrade()
	_test_carry_rain()
	_test_lamp()
	_test_notebook()
	_test_shovel()
	_test_sync_crafting()
	_test_save()
	print("G2 TOOLS SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	for t in _tools_list:
		t.free()
	for o in _others:
		o.free()
	quit(0 if _fail == 0 else 1)


func _on_tool_changed(tool: String, from_tier: int, to_tier: int) -> void:
	_tool_events.append([tool, from_tier, to_tier])


func _new_tools() -> PxbTools:
	var t := PxbTools.new()
	t.tool_changed.connect(_on_tool_changed)
	_tools_list.append(t)
	return t


func _clear_events() -> void:
	_tool_events.clear()


# Dat truc tiep bac cong cu (state public, nhu PxbCrafting.tools) —
# chi dung de chuan bi hanh vi theo bac; luong nang cap/nhan thi test
# qua acquire()/upgrade() o _test_acquire_upgrade.
func _set_tier(t: PxbTools, tool: String, tier: int) -> void:
	t.tools[tool] = tier


func _test_constants() -> void:
	_check("Tools: dung 4 cong cu", PxbTools.TOOL_IDS.size() == 4)
	_check("Tools: thu tu cong cu XeDay/DenSoi/SoTay/Xeng",
		PxbTools.TOOL_IDS == ["XeDay", "DenSoi", "SoTay", "Xeng"])
	_check("Tools: bac Tho/Kha/Tot = 1/2/3",
		PxbTools.TIER_THO == 1 and PxbTools.TIER_KHA == 2 and PxbTools.TIER_TOT == 3)
	_check("Tools: ten bac co dau day du (Thô/Khá/Tốt)",
		PxbTools.TIER_NAMES == {1: "Thô", 2: "Khá", 3: "Tốt"})
	_check("Tools: ten hien thi 4 cong cu",
		PxbTools.tool_name("XeDay") == "Xe Đẩy"
		and PxbTools.tool_name("DenSoi") == "Đèn Soi"
		and PxbTools.tool_name("SoTay") == "Sổ Tay"
		and PxbTools.tool_name("Xeng") == "Xẻng/Cuốc")
	_check("Tools: tool_name cong cu la tra lai id",
		PxbTools.tool_name("KhongCo") == "KhongCo")
	_check("Tools: is_valid_tool dung/sai",
		PxbTools.is_valid_tool("XeDay") and not PxbTools.is_valid_tool("KhongCo"))
	_check("Tools: id nguyen lieu hiem PROVISIONAL la da-quy",
		PxbTools.RARE_MATERIAL_ID == "da-quy")
	_check("Tools: ti le bonus Xeng bac 2 = 25%, hiem bac 3 = 10%",
		is_equal_approx(PxbTools.COLLECT_BONUS_CHANCE, 0.25)
		and is_equal_approx(PxbTools.RARE_FIND_CHANCE, 0.10))
	_check("Tools: he so thoi gian nhat 1,0 / 0,75 / 0,5",
		is_equal_approx(float(PxbTools.COLLECT_TIME_FACTOR[1]), 1.0)
		and is_equal_approx(float(PxbTools.COLLECT_TIME_FACTOR[2]), 0.75)
		and is_equal_approx(float(PxbTools.COLLECT_TIME_FACTOR[3]), 0.5))
	_check("Tools: suc cho Xe Day 5 / 10 / 20 (PROVISIONAL)",
		PxbTools.CARRY_CAPACITY == {1: 5, 2: 10, 3: 20})
	_check("Tools: normalize_tier nhan int / chuoi Tho-Kha-Tot / so",
		PxbTools.normalize_tier(2) == 2
		and PxbTools.normalize_tier("Tho") == 1
		and PxbTools.normalize_tier("KHA") == 2
		and PxbTools.normalize_tier("tot") == 3
		and PxbTools.normalize_tier("2") == 2)
	_check("Tools: normalize_tier la tra 0",
		PxbTools.normalize_tier("la") == 0 and PxbTools.normalize_tier(9) == 9)


func _test_behaviour_12_cau() -> void:
	# 12 cau dung nguyen van Crafting.ToolBehaviour (doi chieu C# 20/11).
	_check("Tools: XeDay bac 1 dung nguyen van",
		PxbTools.tool_behaviour("XeDay", 1) == "Chở được ít hàng, không đi được đường mưa.")
	_check("Tools: XeDay bac 2 dung nguyen van",
		PxbTools.tool_behaviour("XeDay", 2) == "Chở được nhiều hàng hơn.")
	_check("Tools: XeDay bac 3 dung nguyen van",
		PxbTools.tool_behaviour("XeDay", 3) == "Chở nhiều + đi được đường mưa, không bị ướt hàng.")
	_check("Tools: DenSoi bac 1 dung nguyen van",
		PxbTools.tool_behaviour("DenSoi", 1) == "Thấy hotspot thường.")
	_check("Tools: DenSoi bac 2 dung nguyen van",
		PxbTools.tool_behaviour("DenSoi", 2) == "Thấy hotspot thường + hotspot ẩn gần.")
	_check("Tools: DenSoi bac 3 dung nguyen van",
		PxbTools.tool_behaviour("DenSoi", 3) == "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.")
	_check("Tools: SoTay bac 1 dung nguyen van",
		PxbTools.tool_behaviour("SoTay", 1) == "NPC gợi ý chung chung.")
	_check("Tools: SoTay bac 2 dung nguyen van",
		PxbTools.tool_behaviour("SoTay", 2) == "NPC gợi ý rõ mục tiêu + khu cần tới.")
	_check("Tools: SoTay bac 3 dung nguyen van",
		PxbTools.tool_behaviour("SoTay", 3) == "NPC gợi ý rõ mục tiêu + khu + nguyên liệu còn thiếu.")
	_check("Tools: Xeng bac 1 dung nguyen van",
		PxbTools.tool_behaviour("Xeng", 1) == "Nhặt được nguyên liệu thường.")
	_check("Tools: Xeng bac 2 dung nguyen van",
		PxbTools.tool_behaviour("Xeng", 2) == "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu.")
	_check("Tools: Xeng bac 3 dung nguyen van",
		PxbTools.tool_behaviour("Xeng", 3) == "Nhặt nhanh + có cơ hội nhặt được nguyên liệu hiếm.")
	_check("Tools: bac la / cong cu la tra cau mac dinh",
		PxbTools.tool_behaviour("XeDay", 0) == "Chưa rõ bậc công cụ."
		and PxbTools.tool_behaviour("XeDay", 9) == "Chưa rõ bậc công cụ."
		and PxbTools.tool_behaviour("KhongCo", 1) == "Chưa rõ bậc công cụ.")
	_check("Tools: tool_behaviour nhan chuoi bac (Tot/Kha)",
		PxbTools.tool_behaviour("DenSoi", "Tot") == "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày."
		and PxbTools.tool_behaviour("Xeng", "Kha") == "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu.")
	var t := _new_tools()
	_check("Tools: moi tao thi chua co cong cu nao (bac 0)",
		t.tool_tier("XeDay") == 0 and not t.has_tool("DenSoi"))
	_check("Tools: tool_behaviour_current khi chua co tra cau mac dinh",
		t.tool_behaviour_current("SoTay") == "Chưa rõ bậc công cụ.")
	_set_tier(t, "DenSoi", 3)
	_check("Tools: tool_behaviour_current tra dung cau bac dang co",
		t.tool_behaviour_current("DenSoi") == "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.")


func _test_recipes() -> void:
	_check("Tools: dung 8 cong thuc nang cap (4 cong cu x bac 2/3)",
		PxbTools.upgrade_recipes().size() == 8)
	_check("Tools: chi phi nang XeDay bac 2 = khung-sat 2 + banh-xe 4 + van-go 4 (co so C# x2)",
		PxbTools.upgrade_cost("XeDay", 2) == {"khung-sat": 2, "banh-xe": 4, "van-go": 4})
	_check("Tools: chi phi nang XeDay bac 3 = khung-sat 3 + banh-xe 6 + van-go 6 (co so C# x3)",
		PxbTools.upgrade_cost("XeDay", 3) == {"khung-sat": 3, "banh-xe": 6, "van-go": 6})
	_check("Tools: chi phi nang DenSoi bac 2 = sat-vun 4 + chai-nhua 4",
		PxbTools.upgrade_cost("DenSoi", 2) == {"sat-vun": 4, "chai-nhua": 4})
	_check("Tools: chi phi nang DenSoi bac 3 = sat-vun 6 + chai-nhua 6",
		PxbTools.upgrade_cost("DenSoi", 3) == {"sat-vun": 6, "chai-nhua": 6})
	_check("Tools: chi phi nang SoTay bac 2/3 (PROVISIONAL) = la-chuoi 4/6 + vai-vun 2/3",
		PxbTools.upgrade_cost("SoTay", 2) == {"la-chuoi": 4, "vai-vun": 2}
		and PxbTools.upgrade_cost("SoTay", 3) == {"la-chuoi": 6, "vai-vun": 3})
	_check("Tools: chi phi nang Xeng bac 2/3 (PROVISIONAL) = sat-vun 4/6 + van-go 2/3",
		PxbTools.upgrade_cost("Xeng", 2) == {"sat-vun": 4, "van-go": 2}
		and PxbTools.upgrade_cost("Xeng", 3) == {"sat-vun": 6, "van-go": 3})
	_check("Tools: upgrade_cost bac dich la / cong cu la tra {}",
		PxbTools.upgrade_cost("XeDay", 1).is_empty()
		and PxbTools.upgrade_cost("XeDay", 4).is_empty()
		and PxbTools.upgrade_cost("KhongCo", 2).is_empty())
	_check("Tools: dung 2 cong thuc nhan bac 1 (SoTay + Xeng, PROVISIONAL)",
		PxbTools.acquire_recipes().size() == 2)
	_check("Tools: chi phi nhan SoTay bac 1 = la-chuoi 2 + vai-vun 1",
		(PxbTools.acquire_recipe_for("SoTay")["cost"] as Dictionary) == {"la-chuoi": 2, "vai-vun": 1})
	_check("Tools: chi phi nhan Xeng bac 1 = sat-vun 2 + van-go 1",
		(PxbTools.acquire_recipe_for("Xeng")["cost"] as Dictionary) == {"sat-vun": 2, "van-go": 1})
	_check("Tools: XeDay / DenSoi khong co cong thuc nhan bac 1 (phai che qua Crafting)",
		PxbTools.acquire_recipe_for("XeDay").is_empty()
		and PxbTools.acquire_recipe_for("DenSoi").is_empty())
	_check("Tools: recipe_by_id tim duoc nang-cap + che-so-tay, la tra {}",
		String(PxbTools.recipe_by_id("nang-cap-xeng-3")["tool"]) == "Xeng"
		and String(PxbTools.recipe_by_id("che-so-tay")["tool"]) == "SoTay"
		and PxbTools.recipe_by_id("khong-co").is_empty())
	var rs := PxbTools.upgrade_recipes()
	var first_cost: Dictionary = rs[0]["cost"]
	first_cost["khung-sat"] = 99
	_check("Tools: upgrade_recipes() tra ban sao — sua ban sao khong doi bang goc",
		int((PxbTools.upgrade_cost("XeDay", 2))["khung-sat"]) == 2)


func _test_acquire_upgrade() -> void:
	var t := _new_tools()
	# Chua co cong cu thi khong nang duoc.
	var c0 := t.can_upgrade("XeDay")
	_check("Tools: chua co XeDay thi can_upgrade tra chua-co-cong-cu",
		not bool(c0.get("ok", false)) and String(c0.get("reason", "")) == "chua-co-cong-cu")
	_check("Tools: can_upgrade cong cu la tra cong-cu-la",
		String(t.can_upgrade("KhongCo").get("reason", "")) == "cong-cu-la")
	# Nhan SoTay bac 1: thieu do -> tu choi, khong tru gi.
	var r1 := t.acquire("SoTay")
	_check("Tools: nhan SoTay khi tui trong tra thieu-nguyen-lieu",
		not bool(r1.get("ok", false)) and String(r1.get("reason", "")) == "thieu-nguyen-lieu")
	_check("Tools: nhan SoTay thieu thi bao dung so con thieu",
		(r1.get("missing", {}) as Dictionary) == {"la-chuoi": 2, "vai-vun": 1})
	_check("Tools: nhan that bai khong doi bac", t.tool_tier("SoTay") == 0)
	# Nhan SoTay bac 1: du do -> ok, tru dung so, het thi xoa key.
	t.materials = {"la-chuoi": 2, "vai-vun": 1, "sat-vun": 5}
	_clear_events()
	var r2 := t.acquire("SoTay")
	_check("Tools: nhan SoTay du do thi ok + len bac 1",
		bool(r2.get("ok", false)) and t.tool_tier("SoTay") == 1)
	_check("Tools: nhan SoTay tru dung nguyen lieu, het thi xoa key khoi tui",
		t.materials == {"sat-vun": 5}, str(t.materials))
	_check("Tools: acquire luu last_upgrade {SoTay, 0 -> 1}",
		t.last_upgrade == {"tool": "SoTay", "from_tier": 0, "to_tier": 1})
	_check("Tools: acquire phat signal tool_changed",
		_tool_events == [["SoTay", 0, 1]], str(_tool_events))
	_check("Tools: nhan lai SoTay da co tra da-co-cong-cu",
		String(t.acquire("SoTay").get("reason", "")) == "da-co-cong-cu")
	# XeDay / DenSoi bac 1 khong nhan o day.
	_check("Tools: nhan XeDay tra dung-che-tao + chi dung cong thuc che-xe-day",
		String(t.can_acquire("XeDay").get("reason", "")) == "dung-che-tao"
		and String(t.can_acquire("XeDay").get("recipe_id", "")) == "che-xe-day")
	_check("Tools: nhan DenSoi tra dung-che-tao + chi dung cong thuc che-den-soi",
		String(t.can_acquire("DenSoi").get("reason", "")) == "dung-che-tao"
		and String(t.can_acquire("DenSoi").get("recipe_id", "")) == "che-den-soi")
	_check("Tools: can_acquire cong cu la tra cong-cu-la",
		String(t.can_acquire("KhongCo").get("reason", "")) == "cong-cu-la")
	# Nang SoTay len bac 2: thieu do -> tu choi ro ly do + so thieu.
	t.materials = {"la-chuoi": 3, "vai-vun": 2}
	var c1 := t.can_upgrade("SoTay")
	_check("Tools: nang SoTay bac 2 khi thieu la-chuoi tra thieu-nguyen-lieu + missing dung",
		not bool(c1.get("ok", false)) and String(c1.get("reason", "")) == "thieu-nguyen-lieu"
		and (c1.get("missing", {}) as Dictionary) == {"la-chuoi": 1}
		and int(c1.get("to_tier", 0)) == 2)
	_check("Tools: missing_for_upgrade tra dung so thieu",
		t.missing_for_upgrade("SoTay") == {"la-chuoi": 1})
	_check("Tools: missing_for_upgrade khi du do tra {}",
		t.missing_for_upgrade("SoTay", {"la-chuoi": 9, "vai-vun": 9}).is_empty())
	_check("Tools: missing_for_upgrade cong cu chua co / da max tra {}",
		t.missing_for_upgrade("XeDay").is_empty())
	var before := t.materials.duplicate()
	var u1 := t.upgrade("SoTay")
	_check("Tools: nang that bai KHONG tru do + KHONG doi bac",
		not bool(u1.get("ok", false)) and t.tool_tier("SoTay") == 1
		and t.materials == before)
	# Nang SoTay len bac 2: du do -> ok.
	t.materials = {"la-chuoi": 4, "vai-vun": 2, "sat-vun": 1}
	_clear_events()
	var u2 := t.upgrade("SoTay")
	_check("Tools: nang SoTay len bac 2 ok + tru dung chi phi",
		bool(u2.get("ok", false)) and t.tool_tier("SoTay") == 2
		and t.materials == {"sat-vun": 1}, str(t.materials))
	_check("Tools: upgrade tra dung from/to + cost",
		int(u2.get("from_tier", 0)) == 1 and int(u2.get("to_tier", 0)) == 2
		and (u2.get("cost", {}) as Dictionary) == {"la-chuoi": 4, "vai-vun": 2})
	_check("Tools: upgrade phat signal tool_changed",
		_tool_events == [["SoTay", 1, 2]], str(_tool_events))
	# Nang SoTay len bac 3 roi nang nua -> da-max.
	t.materials = {"la-chuoi": 6, "vai-vun": 3}
	var u3 := t.upgrade("SoTay")
	_check("Tools: nang SoTay len bac 3 ok", bool(u3.get("ok", false)) and t.tool_tier("SoTay") == 3)
	var u4 := t.upgrade("SoTay")
	_check("Tools: da bac 3 thi nang nua tra da-max",
		not bool(u4.get("ok", false)) and String(u4.get("reason", "")) == "da-max"
		and int(u4.get("tier", 0)) == 3)
	_check("Tools: nang cong cu la tra cong-cu-la",
		String(t.upgrade("KhongCo").get("reason", "")) == "cong-cu-la")


func _test_carry_rain() -> void:
	var t := _new_tools()
	_check("Tools: carry_capacity bac 0/1/2/3/4 = 0/5/10/20/0",
		PxbTools.carry_capacity(0) == 0 and PxbTools.carry_capacity(1) == 5
		and PxbTools.carry_capacity(2) == 10 and PxbTools.carry_capacity(3) == 20
		and PxbTools.carry_capacity(4) == 0)
	_check("Tools: carry_capacity nhan chuoi bac",
		PxbTools.carry_capacity("Kha") == 10)
	_check("Tools: chua co XeDay thi suc cho = 0 + carry_check fail",
		t.cart_capacity_current() == 0
		and not bool(t.carry_check(1).get("ok", false)))
	_set_tier(t, "XeDay", 1)
	_check("Tools: XeDay bac 1 suc cho 5 — cho 5 duoc, 6 khong",
		t.cart_capacity_current() == 5
		and bool(t.carry_check(5).get("ok", false))
		and not bool(t.carry_check(6).get("ok", false)))
	_set_tier(t, "XeDay", 2)
	_check("Tools: XeDay bac 2 suc cho 10 — cho 10 duoc, 11 khong",
		t.cart_capacity_current() == 10
		and bool(t.carry_check(10).get("ok", false))
		and not bool(t.carry_check(11).get("ok", false)))
	_set_tier(t, "XeDay", 3)
	_check("Tools: XeDay bac 3 suc cho 20 + carry_check tra dung capacity/tier",
		t.cart_capacity_current() == 20
		and (t.carry_check(20) as Dictionary) == {"ok": true, "units": 20, "capacity": 20, "tier": 3})
	# Duong mua: chi bac 3 di duoc.
	_set_tier(t, "XeDay", 1)
	var rain1 := t.cart_can_travel(true)
	_check("Tools: troi mua + XeDay bac 1 thi KHONG di duoc + hang uot",
		not bool(rain1.get("can_travel", true)) and bool(rain1.get("wet_goods", false))
		and String(rain1.get("reason", "")) == "xe-day-chua-du-bac-di-duong-mua")
	_set_tier(t, "XeDay", 2)
	_check("Tools: troi mua + XeDay bac 2 van KHONG di duoc",
		not bool(t.cart_can_travel(true).get("can_travel", true)))
	_set_tier(t, "XeDay", 3)
	var rain3 := t.cart_can_travel(true)
	_check("Tools: troi mua + XeDay bac 3 thi di duoc + hang kho",
		bool(rain3.get("can_travel", false)) and not bool(rain3.get("wet_goods", true))
		and String(rain3.get("reason", "")) == "xe-day-bac-3-di-duoc-duong-mua")
	_check("Tools: khong mua thi di duoc o moi bac (ke ca chua co xe)",
		bool(t.cart_can_travel(false).get("can_travel", false))
		and String(t.cart_can_travel(false).get("reason", "")) == "khong-mua")
	var t0 := _new_tools()
	_check("Tools: khong truyen co mua + chua co xe -> mac dinh khong mua, di duoc",
		bool(t0.cart_can_travel().get("can_travel", false)))
	# Co mua qua weather_raining (PROVISIONAL #7).
	t0.set_weather_raining(true)
	_check("Tools: set_weather_raining(true) thi cart_can_travel() mac dinh la mua",
		not bool(t0.cart_can_travel().get("can_travel", true)))
	t0.set_weather_raining(false)
	_check("Tools: set_weather_raining(false) thi het mua",
		bool(t0.cart_can_travel().get("can_travel", false)))


func _test_lamp() -> void:
	var t := _new_tools()
	var thuong := {"hidden": false, "rarity": "thuong"}
	var an_gan := {"hidden": true, "near": true, "rarity": "thuong"}
	var an_xa := {"hidden": true, "near": false, "rarity": "thuong"}
	var hiem := {"hidden": true, "near": false, "rarity": "hiem", "best_frame": "Sáng"}
	var hiem_sai_khung := {"hidden": true, "near": false, "rarity": "hiem", "best_frame": "Tối"}
	_check("Tools: hotspot thuong thay bang mat thuong, khong can DenSoi",
		t.sees_hotspot(thuong))
	_check("Tools: hotspot rong tra false", not t.sees_hotspot({}))
	_check("Tools: chua co DenSoi thi khong thay hotspot an",
		not t.sees_hotspot(an_gan) and not t.sees_hotspot(an_xa))
	_check("Tools: chua co DenSoi thi khong thay hotspot hiem",
		not t.sees_hotspot(hiem, "Sáng"))
	_set_tier(t, "DenSoi", 1)
	_check("Tools: DenSoi bac 1 thay thuong, khong thay an/hiem",
		t.sees_hotspot(thuong) and not t.sees_hotspot(an_gan)
		and not t.sees_hotspot(hiem, "Sáng"))
	_set_tier(t, "DenSoi", 2)
	_check("Tools: DenSoi bac 2 thay an GAN, khong thay an XA",
		t.sees_hotspot(an_gan) and not t.sees_hotspot(an_xa))
	_check("Tools: DenSoi bac 2 van khong thay hotspot hiem",
		not t.sees_hotspot(hiem, "Sáng"))
	_set_tier(t, "DenSoi", 3)
	_check("Tools: DenSoi bac 3 thay MOI hotspot an (gan + xa)",
		t.sees_hotspot(an_gan) and t.sees_hotspot(an_xa))
	_check("Tools: DenSoi bac 3 thay hotspot hiem DUNG khung xuat hien",
		t.sees_hotspot(hiem, "Sáng"))
	_check("Tools: DenSoi bac 3 cung KHONG thay hotspot hiem SAI khung",
		not t.sees_hotspot(hiem_sai_khung, "Sáng"))
	_check("Tools: hotspot hiem sai khung thi bac nao cung khong thay",
		not t.sees_hotspot(hiem, "Chiều"))
	# Loc danh sach.
	var list := [thuong, an_gan, an_xa, hiem]
	var thay := t.visible_hotspots(list, "Sáng")
	_check("Tools: visible_hotspots bac 3 + dung khung loc dung 4/4",
		thay.size() == 4)
	_set_tier(t, "DenSoi", 2)
	thay = t.visible_hotspots(list, "Sáng")
	_check("Tools: visible_hotspots bac 2 loc dung thuong + an gan (2/4)",
		thay.size() == 2 and thay[0] == thuong and thay[1] == an_gan)
	_check("Tools: visible_hotspots danh sach rong tra []",
		t.visible_hotspots([]).is_empty())
	# Khung hien tai qua PxbTime da bind; chua bind thi bo qua kiem tra khung.
	var time_source := PxbTime.new()
	_others.append(time_source)
	_check("Tools: chua bind PxbTime thi current_frame_name() tra ''",
		t.current_frame_name() == "")
	time_source.debug_set_elapsed(0.0)
	t.bind_time(time_source)
	_check("Tools: bind PxbTime + elapsed 0 thi khung hien tai la Sáng",
		t.current_frame_name() == "Sáng")
	_set_tier(t, "DenSoi", 3)
	_check("Tools: hotspot hiem dung khung Sáng thay duoc khi khong truyen khung ro",
		t.sees_hotspot(hiem))
	time_source.debug_set_elapsed(float(PxbBalance.FRAME_MINUTES) * 2.0 + 1.0)
	_check("Tools: doi sang khung Toi thi hotspot hiem khung Sáng khong thay nua",
		t.current_frame_name() == "Tối" and not t.sees_hotspot(hiem))


func _test_notebook() -> void:
	var t := _new_tools()
	_check("Tools: chua co SoTay thi hint_level = 0", t.hint_level() == 0)
	_check("Tools: chua co SoTay thi guide_hint khuyen hoi NPC",
		t.guide_hint("làm xe đẩy", 1) == "Chưa có Sổ Tay — mục tiêu hiện tại: làm xe đẩy. Hỏi NPC trong khu xem cần làm gì trước đã.")
	_check("Tools: chua co SoTay + goal rong thi dung cau mac dinh",
		t.guide_hint("", 1) == "Chưa có Sổ Tay — mục tiêu hiện tại: chưa có mục tiêu rõ. Hỏi NPC trong khu xem cần làm gì trước đã.")
	_check("Tools: chua co SoTay thi guide_hint_for_recipe khuyen hoi NPC",
		t.guide_hint_for_recipe("nang-cap-xe-day-2") == "Chưa có Sổ Tay — hỏi NPC trong khu xem cần làm gì trước đã.")
	_set_tier(t, "SoTay", 1)
	_check("Tools: SoTay bac 1 thi hint_level = 1", t.hint_level() == 1)
	_check("Tools: SoTay bac 1 goi y chung chung, chi nhac muc tieu",
		t.guide_hint("làm xe đẩy", 1) == "Mục tiêu hiện tại: làm xe đẩy. Cứ đi loanh quanh hỏi NPC trong khu xem sao.")
	_check("Tools: SoTay bac 1 goi y cong thuc la cau chung chung",
		t.guide_hint_for_recipe("nang-cap-xe-day-2") == "Cứ ghé Góc Chế Tạo hỏi thử — có món nâng được công cụ đó.")
	_set_tier(t, "SoTay", 2)
	_check("Tools: SoTay bac 2 goi y ro muc tieu + khu can toi",
		t.guide_hint("làm xe đẩy", 1) == "Mục tiêu: làm xe đẩy. Cần tới khu 1 — tới đó rồi hỏi NPC trong khu.")
	_check("Tools: SoTay bac 2 goi y cong thuc chi ten mon + noi che, khong liet ke thieu",
		t.guide_hint_for_recipe("nang-cap-xe-day-2") == "Muốn nâng Xe Đẩy lên bậc Khá thì ghé Góc Chế Tạo coi lại túi đồ.")
	_set_tier(t, "SoTay", 3)
	_check("Tools: SoTay bac 3 + khong co recipe_id thi nhu bac 2",
		t.guide_hint("làm xe đẩy", 1) == "Mục tiêu: làm xe đẩy. Cần tới khu 1 — tới đó rồi hỏi NPC trong khu.")
	# Bac 3 + cong thuc rieng: liet ke thieu tung mon.
	t.materials = {"khung-sat": 1, "banh-xe": 4, "van-go": 1}
	_check("Tools: SoTay bac 3 liet ke dung nguyen lieu con thieu",
		t.guide_hint_for_recipe("nang-cap-xe-day-2") == "Để nâng Xe Đẩy lên bậc Khá còn thiếu: khung-sat còn thiếu 1, van-go còn thiếu 3.")
	_check("Tools: SoTay bac 3 + recipe_id thi guide_hint noi them cau thieu do",
		t.guide_hint("làm xe đẩy", 1, "nang-cap-xe-day-2") == "Mục tiêu: làm xe đẩy. Cần tới khu 1. Để nâng Xe Đẩy lên bậc Khá còn thiếu: khung-sat còn thiếu 1, van-go còn thiếu 3.")
	t.materials = {"khung-sat": 2, "banh-xe": 4, "van-go": 4}
	_check("Tools: SoTay bac 3 + du do thi bao du do lam ngay",
		t.guide_hint_for_recipe("nang-cap-xe-day-2") == "Đủ đồ nâng Xe Đẩy lên bậc Khá rồi — ghé Góc Chế Tạo làm ngay đi.")
	_check("Tools: cong thuc la (khong phai Crafting/Tools) + chua bind Crafting tra cau mac dinh",
		t.guide_hint_for_recipe("khong-co") == "Chưa rõ bậc công cụ.")
	# Uy quyen cho PxbCrafting khi da bind.
	var crafting := PxbCrafting.new()
	_others.append(crafting)
	_check("Tools: hoc cong thuc che-xe-day qua Crafting ok",
		crafting.learn_recipe("che-xe-day"))
	crafting.materials = {"khung-sat": 1, "banh-xe": 2, "van-go": 2}
	t.bind_crafting(crafting)
	_check("Tools: SoTay bac 3 + bind Crafting thi goi y cong thuc Crafting (du do)",
		t.guide_hint_for_recipe("che-xe-day") == "Đủ đồ chế Xe Đẩy Hàng rồi — ghé Góc Chế Tạo làm ngay đi.")
	crafting.materials = {"khung-sat": 0, "banh-xe": 1}
	_check("Tools: SoTay bac 3 + bind Crafting thi goi y dung so thieu cua Crafting",
		t.guide_hint_for_recipe("che-xe-day") == "Để chế Xe Đẩy Hàng còn thiếu: khung-sat còn thiếu 1, banh-xe còn thiếu 1, van-go còn thiếu 2.")
	_set_tier(t, "SoTay", 2)
	_check("Tools: SoTay bac 2 + cong thuc Crafting thi cau rut gon, khong liet ke thieu",
		t.guide_hint_for_recipe("che-xe-day") == "Muốn chế món đó thì ghé Góc Chế Tạo coi lại túi đồ.")
	_set_tier(t, "SoTay", 1)
	_check("Tools: SoTay bac 1 + cong thuc Crafting thi cau chung chung",
		t.guide_hint_for_recipe("che-xe-day") == "Cứ ghé Góc Chế Tạo hỏi thử — có món chế được đó.")
	# npc_hint: chua bind hotspot thi tra cau SoTay thuan.
	var t2 := _new_tools()
	_set_tier(t2, "SoTay", 2)
	_check("Tools: npc_hint chua bind Hotspot thi tra cau SoTay thuan",
		t2.npc_hint(1, "làm xe đẩy") == "Mục tiêu: làm xe đẩy. Cần tới khu 1 — tới đó rồi hỏi NPC trong khu.")
	# Bind hotspot: cau goc tu Hotspot + noi them theo bac SoTay.
	var hotspot := PxbHotspot.new()
	_others.append(hotspot)
	t2.bind_hotspot(hotspot)
	var base := PxbHotspot.guide_hint(1, "làm xe đẩy")
	_check("Tools: npc_hint bind Hotspot + SoTay bac 2 thi cau goc + ghi chu khu",
		t2.npc_hint(1, "làm xe đẩy") == base + " (Sổ Tay: mục tiêu này cần tới khu 1.)")
	_set_tier(t2, "SoTay", 3)
	t2.materials = {"la-chuoi": 2, "vai-vun": 1}
	_check("Tools: npc_hint bind Hotspot + SoTay bac 3 + recipe thi noi them cau thieu do",
		t2.npc_hint(1, "làm xe đẩy", "che-so-tay") == base + " Đủ đồ nâng Sổ Tay lên bậc Thô rồi — ghé Góc Chế Tạo làm ngay đi.")
	_set_tier(t2, "SoTay", 1)
	_check("Tools: npc_hint bind Hotspot + SoTay bac 1 thi chi cau goc",
		t2.npc_hint(1, "làm xe đẩy") == base)


func _test_shovel() -> void:
	# collect_yield: bac 1 khong bonus/hiem du roll thap.
	var y1 := PxbTools.collect_yield(2, 1, 0.01)
	_check("Tools: Xeng bac 1 nhat dung 2, khong bonus, khong hiem, cham nhat (1,0)",
		int(y1["amount"]) == 2 and int(y1["bonus"]) == 0
		and not bool(y1["rare_found"]) and is_equal_approx(float(y1["time_factor"]), 1.0))
	# Bac 2: roll 0,5 -> khong bonus; roll 0,1 -> +1.
	var y2a := PxbTools.collect_yield(2, 2, 0.5)
	var y2b := PxbTools.collect_yield(2, 2, 0.1)
	_check("Tools: Xeng bac 2 roll cao thi nhat dung 2, nhanh hon (0,75)",
		int(y2a["amount"]) == 2 and int(y2a["bonus"]) == 0
		and is_equal_approx(float(y2a["time_factor"]), 0.75))
	_check("Tools: Xeng bac 2 roll < 25% thi +1 nguyen lieu",
		int(y2b["amount"]) == 3 and int(y2b["bonus"]) == 1
		and not bool(y2b["rare_found"]))
	# Bac 3: roll 0,2 -> +1 nhung khong hiem; roll 0,05 -> +1 + hiem.
	var y3a := PxbTools.collect_yield(2, 3, 0.2)
	var y3b := PxbTools.collect_yield(2, 3, 0.05)
	_check("Tools: Xeng bac 3 roll 20% thi +1 nhung chua hiem, nhanh nhat (0,5)",
		int(y3a["amount"]) == 3 and int(y3a["bonus"]) == 1
		and not bool(y3a["rare_found"]) and is_equal_approx(float(y3a["time_factor"]), 0.5))
	_check("Tools: Xeng bac 3 roll < 10% thi +1 + nhat duoc da-quy",
		int(y3b["amount"]) == 3 and bool(y3b["rare_found"])
		and String(y3b["rare_material_id"]) == "da-quy")
	_check("Tools: collect_yield bac la/0 coi nhu bac 1 (nhat thuong)",
		int(PxbTools.collect_yield(2, 0, 0.01)["amount"]) == 2
		and int(PxbTools.collect_yield(2, 9, 0.01)["amount"]) == 2)
	_check("Tools: collect_yield nhan chuoi bac",
		int(PxbTools.collect_yield(2, "Tot", 0.05)["amount"]) == 3
		and bool(PxbTools.collect_yield(2, "Tot", 0.05)["rare_found"]))
	# collect(): cong vao tui chung + them da-quy khi hiem.
	var t := _new_tools()
	_set_tier(t, "Xeng", 3)
	t.materials = {"la-chuoi": 1}
	var c1 := t.collect("la-chuoi", 2, 0.05)
	_check("Tools: collect Xeng bac 3 roll hiem thi tui +3 la-chuoi +1 da-quy",
		int(c1["amount"]) == 3 and bool(c1["rare_found"])
		and t.materials == {"la-chuoi": 4, "da-quy": 1}, str(t.materials))
	var c2 := t.collect("la-chuoi", 2, 0.5)
	_check("Tools: collect Xeng bac 3 roll cao thi chi +2, khong them da-quy",
		int(c2["amount"]) == 2 and not bool(c2["rare_found"])
		and t.materials == {"la-chuoi": 6, "da-quy": 1}, str(t.materials))
	_set_tier(t, "Xeng", 1)
	var c3 := t.collect("van-go", 2, 0.01)
	_check("Tools: collect Xeng bac 1 thi nhat dung, khong bonus du roll thap",
		int(c3["amount"]) == 2 and int(t.materials.get("van-go", 0)) == 2)


func _test_sync_crafting() -> void:
	var t := _new_tools()
	var crafting := PxbCrafting.new()
	_others.append(crafting)
	_check("Tools: chua bind Crafting thi crafting_tool_tier tra 0 + mirror tra false",
		t.crafting_tool_tier("XeDay") == 0 and not t.mirror_to_crafting("XeDay", 1))
	t.bind_crafting(crafting)
	_check("Tools: bind Crafting nhung Crafting chua co tool thi sync tra false",
		not t.sync_from_crafting())
	crafting.apply_result("tool:DenSoi:1")
	_check("Tools: Crafting che DenSoi bac 1 thi Tools doc thay qua sync (max 2 ben)",
		t.tool_tier("DenSoi") == 1)
	_check("Tools: sync_from_crafting khi da dong bo tra false",
		not t.sync_from_crafting())
	# Tools nang len thi mirror sang Crafting.
	_set_tier(t, "DenSoi", 2)
	t.mirror_to_crafting("DenSoi", 2)
	_check("Tools: mirror_to_crafting ghi de bac len Crafting",
		crafting.tool_tier("DenSoi") == 2)
	# Mirror chi tang, khong giam.
	t.mirror_to_crafting("DenSoi", 1)
	_check("Tools: mirror chi tang bac, khong giam bac Crafting",
		crafting.tool_tier("DenSoi") == 2)
	# Acquire o Tools thi tu mirror sang Crafting.
	t.materials = {"sat-vun": 2, "van-go": 1}
	var r := t.acquire("Xeng")
	_check("Tools: acquire Xeng ok + tu mirror sang Crafting",
		bool(r.get("ok", false)) and crafting.tool_tier("Xeng") == 1)
	# Bind chung tui: Crafting che dung chung tui voi Tools.
	var bag := {"khung-sat": 1, "banh-xe": 2, "van-go": 2}
	t.bind_materials(bag)
	crafting.bind_materials(bag)
	crafting.learn_recipe("che-xe-day")
	var cc := crafting.craft_current("che-xe-day")
	_check("Tools: Crafting che XeDay dung CHUNG tui voi Tools (tui het sach)",
		bool(cc.get("ok", false)) and bag.is_empty() and t.materials.is_empty())
	_check("Tools: Tools doc thay XeDay bac 1 vua che o Crafting (sync)",
		t.tool_tier("XeDay") == 1)


func _test_save() -> void:
	var t := _new_tools()
	t.materials = {"la-chuoi": 5, "sat-vun": 3}
	_set_tier(t, "SoTay", 2)
	_set_tier(t, "Xeng", 3)
	t.last_upgrade = {"tool": "Xeng", "from_tier": 2, "to_tier": 3}
	var saved: Dictionary = t.data()
	var t2 := PxbTools.from_data(saved)
	_others.append(t2)
	_check("Tools: save round-trip giu tui nguyen lieu",
		t2.materials == {"la-chuoi": 5, "sat-vun": 3})
	_check("Tools: save round-trip giu bac cong cu",
		t2.tool_tier("SoTay") == 2 and t2.tool_tier("Xeng") == 3)
	_check("Tools: save round-trip giu last_upgrade",
		t2.last_upgrade == {"tool": "Xeng", "from_tier": 2, "to_tier": 3})
	_check("Tools: save round-trip giu cong cu chua co = 0",
		t2.tool_tier("XeDay") == 0)
	var copy: Dictionary = t.data()
	var copy_mats: Dictionary = copy["materials"]
	copy_mats["la-chuoi"] = 99
	_check("Tools: data() tra ban sao — sua ban sao khong doi tools",
		int(t.materials.get("la-chuoi", 0)) == 5)
	# Du lieu ban.
	var dirty := saved.duplicate(true)
	var dirty_tools: Dictionary = dirty["tools"]
	dirty_tools["KhongCo"] = 2
	dirty_tools["XeDay"] = 5
	dirty_tools["DenSoi"] = 0
	dirty_tools["SoTay"] = "hai"
	var dirty_mats: Dictionary = dirty["materials"]
	dirty_mats["rac"] = -4
	dirty_mats["het"] = 0
	dirty_mats["chu"] = "khong-phai-so"
	dirty["last_upgrade"] = {"tool": "KhongCo", "from_tier": 1, "to_tier": 2}
	var t3 := PxbTools.from_data(dirty)
	_others.append(t3)
	_check("Tools: from_data bo cong cu la",
		t3.tool_tier("KhongCo") == 0 and not ("KhongCo" in t3.tools))
	_check("Tools: from_data kep bac 5 ve 3 (dung JS load save cu)",
		t3.tool_tier("XeDay") == 3)
	_check("Tools: from_data bo bac 0 + bac khong phai so",
		t3.tool_tier("DenSoi") == 0 and t3.tool_tier("SoTay") == 0)
	_check("Tools: from_data bo nguyen lieu am / 0 / khong phai so",
		not ("rac" in t3.materials) and not ("het" in t3.materials)
		and not ("chu" in t3.materials) and int(t3.materials.get("la-chuoi", 0)) == 5)
	_check("Tools: from_data bo last_upgrade co tool la",
		t3.last_upgrade.is_empty())
	_check("Tools: default_data() dung mac dinh",
		PxbTools.default_data() == {"materials": {}, "tools": {}, "last_upgrade": {}})
	# reset_state.
	var t4 := _new_tools()
	t4.materials = {"la-chuoi": 7}
	_set_tier(t4, "XeDay", 3)
	t4.last_upgrade = {"tool": "XeDay", "from_tier": 2, "to_tier": 3}
	_check("Tools: reset_state tra true + xoa bac + last_upgrade",
		t4.reset_state() and t4.tools.is_empty() and t4.last_upgrade.is_empty())
	_check("Tools: reset_state GIU NGUYEN tui nguyen lieu (dung JS)",
		t4.materials == {"la-chuoi": 7})
	var t5 := PxbTools.from_data({})
	_others.append(t5)
	_check("Tools: from_data({}) tra tools trang sach",
		t5.tools.is_empty() and t5.materials.is_empty() and t5.last_upgrade.is_empty())
