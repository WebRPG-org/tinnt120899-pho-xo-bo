extends SceneTree
## G2 INVENTORY + CRAFTING selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_inventory_crafting_test.gd
## Kiem tra: PxbInventory (port Inventory.cs) — bang 4 vat pham, mua
## stackable / all-or-nothing, dung do + buff tam dung khung catalog,
## het khung het buff; PxbCrafting (port PXB_Crafting.js / Crafting.cs) —
## 3 cong thuc, hoc cong thuc, che tru dung so + xoa key 0, tool 4x3
## doi hanh vi, goi y So Tay, tui chung voi PxbHotspot.
## In "G2 INVENTORY+CRAFTING SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd (tranh xung dot voi luong song song).

var _pass := 0
var _fail := 0


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	_test_inventory_catalog()
	_test_inventory_add_use()
	_test_inventory_buffs()
	_test_inventory_save()
	_test_crafting_catalog()
	_test_crafting_learn()
	_test_crafting_static()
	_test_crafting_current()
	_test_crafting_tools()
	_test_crafting_save()
	_test_crafting_hotspot_bag()
	print("G2 INVENTORY+CRAFTING SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _test_inventory_catalog() -> void:
	# Bang 4 vat pham lay tu PxbBalance (khong hardcode lai o test).
	_check("Inventory: 4 vat pham slice", PxbInventory.item_list().size() == 4)
	var com_tam := PxbInventory.get_item("com-tam")
	_check("Inventory: com tam 35k, xep chong, The +5 khung Chieu",
		int(com_tam["price_vnd"]) == 35000 and bool(com_tam["stackable"])
		and String(com_tam["effect_stat"]) == "the" and int(com_tam["effect_amount"]) == 5
		and String(com_tam["effect_frame"]) == "Chiều")
	_check("Inventory: ca phe 25k, Tri +5 khung Sang",
		int(PxbInventory.get_item("ca-phe")["price_vnd"]) == 25000
		and String(PxbInventory.get_item("ca-phe")["effect_stat"]) == "tri"
		and String(PxbInventory.get_item("ca-phe")["effect_frame"]) == "Sáng")
	_check("Inventory: sach 80k, Tri +5 khung Toi",
		int(PxbInventory.get_item("sach")["price_vnd"]) == 80000
		and String(PxbInventory.get_item("sach")["effect_frame"]) == "Tối")
	var ao_mua := PxbInventory.get_item("ao-mua")
	_check("Inventory: ao mua 120k, khong xep chong, khong buff, mo ca mua",
		int(ao_mua["price_vnd"]) == 120000 and not bool(ao_mua["stackable"])
		and String(ao_mua["effect_stat"]) == ""
		and String(ao_mua["unlock_note"]) == "Làm được ca mưa, không bị ướt")
	_check("Inventory: get_item la tra {}", PxbInventory.get_item("khong-co").is_empty())
	_check("Inventory: item_by_id('sach') dung ten",
		String(PxbBalance.item_by_id("sach")["name"]) == "Sách")


func _test_inventory_add_use() -> void:
	var inv := PxbInventory.new()
	# Them do xep chong duoc.
	_check("Inventory: add com-tam 3 -> true, count 3",
		inv.add("com-tam", 3) and inv.count("com-tam") == 3)
	_check("Inventory: add com-tam them 2 -> count 5",
		inv.add("com-tam", 2) and inv.count("com-tam") == 5)
	# Do khong xep chong: all-or-nothing.
	_check("Inventory: add ao-mua 2 luc tui trong -> false, count 0",
		not inv.add("ao-mua", 2) and inv.count("ao-mua") == 0)
	_check("Inventory: add ao-mua 1 -> true, count 1",
		inv.add("ao-mua", 1) and inv.count("ao-mua") == 1)
	_check("Inventory: add ao-mua lan 2 -> false, van count 1",
		not inv.add("ao-mua", 1) and inv.count("ao-mua") == 1)
	# Id la / so luong sai.
	_check("Inventory: add id la -> false", not inv.add("khong-co", 1))
	_check("Inventory: add so luong 0 / am -> false",
		not inv.add("com-tam", 0) and not inv.add("com-tam", -1))
	# Dung do: tru 1, khong co do -> false.
	_check("Inventory: use sach khi khong co -> false", not inv.use("sach"))
	_check("Inventory: use com-tam -> true, count 5 -> 4",
		inv.use("com-tam") and inv.count("com-tam") == 4)
	_check("Inventory: use ao-mua -> true, count 1 -> 0, khong them buff",
		inv.use("ao-mua") and inv.count("ao-mua") == 0 and inv.active_buffs.size() == 1)
	_check("Inventory: use id la -> false", not inv.use("khong-co"))
	inv.free()


func _test_inventory_buffs() -> void:
	var inv := PxbInventory.new()
	# Buff ap dung khung CATALOG (Chieu), khong phai khung hien tai (Sang).
	inv.add("com-tam", 2)
	inv.use("com-tam", "Sáng")
	_check("Inventory: com-tam dung luc Sang -> buff The Chieu 5, Sang 0",
		inv.buff_for("the", "Chiều") == 5 and inv.buff_for("the", "Sáng") == 0)
	# Dung 2 mon cung khung -> buff cong don.
	inv.use("com-tam", "Chiều")
	_check("Inventory: dung 2 com-tam -> buff The Chieu 10",
		inv.buff_for("the", "Chiều") == 10)
	# Buff khung khac khong anh huong nhau.
	inv.add("ca-phe", 1)
	inv.use("ca-phe", "Sáng")
	_check("Inventory: ca-phe -> buff Tri Sang 5, The Chieu van 10",
		inv.buff_for("tri", "Sáng") == 5 and inv.buff_for("the", "Chiều") == 10)
	# Het khung Chieu: buff Chieu het, buff Sang GIU NGUYEN.
	inv.end_frame("Chiều")
	_check("Inventory: end_frame Chieu -> The Chieu 0, Tri Sang van 5",
		inv.buff_for("the", "Chiều") == 0 and inv.buff_for("tri", "Sáng") == 5)
	inv.end_frame("Sáng")
	_check("Inventory: end_frame Sang -> Tri Sang 0", inv.buff_for("tri", "Sáng") == 0)
	# Sach: Tri +5 khung Toi.
	inv.add("sach", 1)
	inv.use("sach", "Tối")
	_check("Inventory: sach -> buff Tri Toi 5",
		inv.buff_for("tri", "Tối") == 5 and inv.buff_for("tri", "Sáng") == 0)
	inv.free()


func _test_inventory_save() -> void:
	var inv := PxbInventory.new()
	inv.add("com-tam", 2)
	inv.add("ca-phe", 1)
	inv.use("com-tam", "Sáng") # buff The Chieu 5
	var d := inv.data()
	var back := PxbInventory.from_data(d)
	_check("Inventory: from_data khoi phuc so luong + buff",
		back.count("com-tam") == 1 and back.count("ca-phe") == 1
		and back.buff_for("the", "Chiều") == 5)
	var empty := PxbInventory.from_data({})
	_check("Inventory: from_data {} -> tui trong, khong buff",
		empty.count("com-tam") == 0 and empty.active_buffs.is_empty())
	empty.free()
	inv.free()
	back.free()


func _test_crafting_catalog() -> void:
	_check("Crafting: 3 cong thuc slice", PxbCrafting.recipe_list().size() == 3)
	var xe_day := PxbCrafting.get_recipe("che-xe-day")
	_check("Crafting: che-xe-day = khung-sat 1 + banh-xe 2 + van-go 2 -> tool:XeDay:1",
		int((xe_day["needs"] as Dictionary)["khung-sat"]) == 1
		and int((xe_day["needs"] as Dictionary)["banh-xe"]) == 2
		and int((xe_day["needs"] as Dictionary)["van-go"]) == 2
		and String(xe_day["result"]) == "tool:XeDay:1")
	_check("Crafting: che-den-soi = sat-vun 2 + chai-nhua 2 -> tool:DenSoi:1",
		int((PxbCrafting.get_recipe("che-den-soi")["needs"] as Dictionary)["sat-vun"]) == 2
		and int((PxbCrafting.get_recipe("che-den-soi")["needs"] as Dictionary)["chai-nhua"]) == 2
		and String(PxbCrafting.get_recipe("che-den-soi")["result"]) == "tool:DenSoi:1")
	_check("Crafting: che-qua-tang = la-chuoi 2 + vai-vun 1 -> item:qua-tang",
		int((PxbCrafting.get_recipe("che-qua-tang")["needs"] as Dictionary)["la-chuoi"]) == 2
		and int((PxbCrafting.get_recipe("che-qua-tang")["needs"] as Dictionary)["vai-vun"]) == 1
		and String(PxbCrafting.get_recipe("che-qua-tang")["result"]) == "item:qua-tang")
	_check("Crafting: get_recipe la tra {}", PxbCrafting.get_recipe("khong-co").is_empty())
	_check("Crafting: result_name tool:XeDay:1 / item:qua-tang",
		PxbCrafting.result_name("tool:XeDay:1") == "Xe Đẩy Hàng"
		and PxbCrafting.result_name("item:qua-tang") == "Quà Tặng Thủ Công")


func _test_crafting_learn() -> void:
	var c := PxbCrafting.new()
	_check("Crafting: mac dinh chua hoc cong thuc nao",
		not c.has_learned("che-xe-day") and c.known_recipes().is_empty())
	_check("Crafting: learn_recipe id la -> false", not c.learn_recipe("khong-co"))
	_check("Crafting: learn che-xe-day -> true, has_learned true",
		c.learn_recipe("che-xe-day") and c.has_learned("che-xe-day"))
	_check("Crafting: known_recipes 1 mon sau khi hoc",
		c.known_recipes().size() == 1
		and String((c.known_recipes()[0] as Dictionary)["id"]) == "che-xe-day")
	c.free()


func _test_crafting_static() -> void:
	# can_craft: chi kiem tra, khong tru do.
	var full := {"khung-sat": 1, "banh-xe": 2, "van-go": 2}
	_check("Crafting: can_craft du do -> true", PxbCrafting.can_craft("che-xe-day", full))
	var thieu := {"khung-sat": 1, "banh-xe": 1}
	_check("Crafting: can_craft thieu do -> false", not PxbCrafting.can_craft("che-xe-day", thieu))
	_check("Crafting: can_craft cong thuc la -> false",
		not PxbCrafting.can_craft("khong-co", full))
	# craft: tru dung so, nguyen lieu ve 0 thi XOA key.
	var bag := {"khung-sat": 1, "banh-xe": 2, "van-go": 3}
	var result := PxbCrafting.craft("che-xe-day", bag)
	_check("Crafting: craft tra tool:XeDay:1, xoa khung-sat/banh-xe, van-go con 1",
		result == "tool:XeDay:1" and not bag.has("khung-sat") and not bag.has("banh-xe")
		and int(bag.get("van-go", 0)) == 1)
	# craft thieu do: tra "", tui khong doi.
	var bag2 := {"khung-sat": 1, "banh-xe": 1, "van-go": 2}
	_check("Crafting: craft thieu do tra '' va tui khong doi",
		PxbCrafting.craft("che-xe-day", bag2) == ""
		and int(bag2["banh-xe"]) == 1 and int(bag2["van-go"]) == 2)
	_check("Crafting: craft cong thuc la tra ''", PxbCrafting.craft("khong-co", bag2) == "")
	# missing_ingredients: so con thieu tung loai.
	var missing := PxbCrafting.missing_ingredients("che-xe-day", thieu)
	_check("Crafting: missing = banh-xe 1 + van-go 2",
		int(missing.get("banh-xe", 0)) == 1 and int(missing.get("van-go", 0)) == 2
		and not missing.has("khung-sat"))
	_check("Crafting: missing du do -> {}",
		PxbCrafting.missing_ingredients("che-xe-day", full).is_empty())
	_check("Crafting: missing cong thuc la -> {}",
		PxbCrafting.missing_ingredients("khong-co", full).is_empty())


func _test_crafting_current() -> void:
	var c := PxbCrafting.new()
	# Cong thuc la.
	_check("Crafting: craft_current la -> khong-co-cong-thuc",
		String(c.craft_current("khong-co")["reason"]) == "khong-co-cong-thuc")
	# Chua hoc -> chan, kem unlock_note.
	var chua_hoc := c.craft_current("che-den-soi")
	_check("Crafting: chua hoc -> chua-hoc-cong-thuc + unlock_note Anh Hai",
		not bool(chua_hoc["ok"]) and String(chua_hoc["reason"]) == "chua-hoc-cong-thuc"
		and String(chua_hoc["unlock_note"]).contains("Anh Hải"))
	# Hoc xong nhung thieu do.
	c.learn_recipe("che-den-soi")
	var thieu := c.craft_current("che-den-soi")
	_check("Crafting: hoc roi thieu do -> thieu-nguyen-lieu, missing sat-vun 2 + chai-nhua 2",
		not bool(thieu["ok"]) and String(thieu["reason"]) == "thieu-nguyen-lieu"
		and int((thieu["missing"] as Dictionary).get("sat-vun", 0)) == 2
		and int((thieu["missing"] as Dictionary).get("chai-nhua", 0)) == 2)
	# Du do -> che thanh cong, tru dung so, tool len bac.
	c.materials = {"sat-vun": 2, "chai-nhua": 3}
	var ok := c.craft_current("che-den-soi")
	_check("Crafting: che den soi ok, result tool:DenSoi:1, ten Den Soi",
		bool(ok["ok"]) and String(ok["result_id"]) == "tool:DenSoi:1"
		and String(ok["result_name"]) == "Đèn Soi")
	_check("Crafting: applied tool DenSoi bac 1, tool_tier = 1",
		String((ok["applied"] as Dictionary).get("kind", "")) == "tool"
		and int((ok["applied"] as Dictionary).get("tier", 0)) == 1
		and c.tool_tier("DenSoi") == 1)
	_check("Crafting: tui sau che: sat-vun xoa, chai-nhua con 1",
		not c.materials.has("sat-vun") and int(c.materials.get("chai-nhua", 0)) == 1)
	_check("Crafting: last_craft ghi dung lan che",
		String((c.last_craft as Dictionary).get("recipe_id", "")) == "che-den-soi"
		and String((c.last_craft as Dictionary).get("result_id", "")) == "tool:DenSoi:1")
	# Che lai khi het do -> thieu.
	_check("Crafting: che lai het do -> thieu-nguyen-lieu",
		String(c.craft_current("che-den-soi")["reason"]) == "thieu-nguyen-lieu")
	# Che qua tang: dem vao crafted_items.
	c.learn_recipe("che-qua-tang")
	c.materials = {"la-chuoi": 2, "vai-vun": 1}
	var qua := c.craft_current("che-qua-tang")
	_check("Crafting: che qua tang ok, applied item qua-tang, dem 1",
		bool(qua["ok"]) and String((qua["applied"] as Dictionary).get("kind", "")) == "item"
		and String((qua["applied"] as Dictionary).get("item_id", "")) == "qua-tang"
		and int(c.crafted_items.get("qua-tang", 0)) == 1)
	_check("Crafting: tui sau che qua tang rong", c.materials.is_empty())
	# Goi y So Tay.
	c.materials = {}
	var hint_thieu := c.guide_hint_for_recipe("che-xe-day")
	_check("Crafting: hint thieu do liet ke khung-sat/banh-xe/van-go",
		hint_thieu.contains("còn thiếu") and hint_thieu.contains("khung-sat")
		and hint_thieu.contains("banh-xe") and hint_thieu.contains("van-go"))
	c.materials = {"khung-sat": 1, "banh-xe": 2, "van-go": 2}
	_check("Crafting: hint du do -> 'Đủ đồ chế Xe Đẩy Hàng rồi'",
		c.guide_hint_for_recipe("che-xe-day").contains("Đủ đồ chế Xe Đẩy Hàng rồi"))
	_check("Crafting: hint cong thuc la -> chuoi mac dinh",
		c.guide_hint_for_recipe("khong-co") == "Chưa rõ bậc công cụ.")
	c.free()


func _test_crafting_tools() -> void:
	# Mo ta hanh vi 4 tool x 3 bac — tung chu dung Crafting.cs.
	_check("Crafting: XeDay Tho/Kha/Tot",
		PxbCrafting.tool_behaviour("XeDay", 1) == "Chở được ít hàng, không đi được đường mưa."
		and PxbCrafting.tool_behaviour("XeDay", 2) == "Chở được nhiều hàng hơn."
		and PxbCrafting.tool_behaviour("XeDay", 3) == "Chở nhiều + đi được đường mưa, không bị ướt hàng.")
	_check("Crafting: DenSoi Tho/Kha/Tot",
		PxbCrafting.tool_behaviour("DenSoi", 1) == "Thấy hotspot thường."
		and PxbCrafting.tool_behaviour("DenSoi", 2) == "Thấy hotspot thường + hotspot ẩn gần."
		and PxbCrafting.tool_behaviour("DenSoi", 3) == "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.")
	_check("Crafting: SoTay Tho/Kha/Tot",
		PxbCrafting.tool_behaviour("SoTay", 1) == "NPC gợi ý chung chung."
		and PxbCrafting.tool_behaviour("SoTay", 2) == "NPC gợi ý rõ mục tiêu + khu cần tới."
		and PxbCrafting.tool_behaviour("SoTay", 3) == "NPC gợi ý rõ mục tiêu + khu + nguyên liệu còn thiếu.")
	_check("Crafting: Xeng Tho/Kha/Tot",
		PxbCrafting.tool_behaviour("Xeng", 1) == "Nhặt được nguyên liệu thường."
		and PxbCrafting.tool_behaviour("Xeng", 2) == "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu."
		and PxbCrafting.tool_behaviour("Xeng", 3) == "Nhặt nhanh + có cơ hội nhặt được nguyên liệu hiếm.")
	_check("Crafting: tool la / bac 0 / bac 4 -> chuoi mac dinh",
		PxbCrafting.tool_behaviour("KhongCo", 1) == "Chưa rõ bậc công cụ."
		and PxbCrafting.tool_behaviour("XeDay", 0) == "Chưa rõ bậc công cụ."
		and PxbCrafting.tool_behaviour("XeDay", 4) == "Chưa rõ bậc công cụ.")
	_check("Crafting: bac dang chu 'Kha'/'tot' van hieu",
		PxbCrafting.tool_behaviour("XeDay", "Kha") == "Chở được nhiều hàng hơn."
		and PxbCrafting.tool_behaviour("DenSoi", "tot") == "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.")
	# tool_tier / has_tool / apply_result.
	var c := PxbCrafting.new()
	_check("Crafting: chua co tool -> tier 0, has_tool false",
		c.tool_tier("XeDay") == 0 and not c.has_tool("XeDay"))
	_check("Crafting: tool_behaviour_current chua co tool -> mac dinh",
		c.tool_behaviour_current("DenSoi") == "Chưa rõ bậc công cụ.")
	_check("Crafting: apply_result tool:XeDay:1 -> kind tool, tier 1",
		String(c.apply_result("tool:XeDay:1").get("kind", "")) == "tool"
		and c.tool_tier("XeDay") == 1)
	_check("Crafting: apply_result lai bac 1 -> tier giu 1 (chi tang)",
		String(c.apply_result("tool:XeDay:1").get("kind", "")) == "tool"
		and c.tool_tier("XeDay") == 1)
	_check("Crafting: apply_result bac la / chuoi sai -> {}",
		c.apply_result("tool:XeDay:9").is_empty()
		and c.apply_result("khong-dung").is_empty()
		and c.apply_result("tool:KhongCo:1").is_empty())
	_check("Crafting: tool_behaviour_current sau khi co DenSoi 1",
		c.apply_result("tool:DenSoi:1").get("kind", "") == "tool"
		and c.tool_behaviour_current("DenSoi") == "Thấy hotspot thường.")
	_check("Crafting: apply_result item:qua-tang -> dem 1",
		String(c.apply_result("item:qua-tang").get("kind", "")) == "item"
		and int(c.crafted_items.get("qua-tang", 0)) == 1)
	c.free()


func _test_crafting_save() -> void:
	var c := PxbCrafting.new()
	c.learn_recipe("che-xe-day")
	c.learn_recipe("che-den-soi")
	c.materials = {"sat-vun": 5, "chai-nhua": 2}
	c.apply_result("tool:DenSoi:1")
	c.apply_result("item:qua-tang")
	c.last_craft = {"recipe_id": "che-den-soi", "result_id": "tool:DenSoi:1"}
	var d := c.data()
	var back := PxbCrafting.from_data(d)
	_check("Crafting: from_data khoi phuc hoc/tool/qua/tui/last_craft",
		back.has_learned("che-xe-day") and back.has_learned("che-den-soi")
		and back.tool_tier("DenSoi") == 1
		and int(back.crafted_items.get("qua-tang", 0)) == 1
		and int(back.materials.get("sat-vun", 0)) == 5
		and String((back.last_craft as Dictionary).get("result_id", "")) == "tool:DenSoi:1")
	var empty := PxbCrafting.from_data({})
	_check("Crafting: from_data {} -> chua hoc, chua tool, tui trong",
		empty.known_recipes().is_empty() and empty.tool_tier("XeDay") == 0
		and empty.materials.is_empty())
	# from_data bo cong thuc la + bac tool la (save cu / sua tay).
	var dirty := PxbCrafting.from_data({
		"learned_recipes": {"khong-co": true, "che-xe-day": true},
		"tools": {"XeDay": 9, "DenSoi": 2},
	})
	_check("Crafting: from_data bo hoc la + bac tool 9, giu DenSoi 2",
		dirty.has_learned("che-xe-day") and not dirty.has_learned("khong-co")
		and dirty.tool_tier("XeDay") == 0 and dirty.tool_tier("DenSoi") == 2)
	dirty.free()
	empty.free()
	c.free()
	back.free()


func _test_crafting_hotspot_bag() -> void:
	# Tui chung: Hotspot nhat vao, Crafting tru ra (cung 1 Dictionary).
	var h := PxbHotspot.new()
	var c := PxbCrafting.new()
	c.bind_materials(h.materials)
	# Nhat hotspot sang khu 2: la-chuoi x2.
	var pick := h.explore("hs-cho-sang", 1, "Sáng")
	_check("Crafting+Hotspot: nhat hs-cho-sang ok, la-chuoi 2 vao tui chung",
		bool(pick["ok"]) and int(h.materials.get("la-chuoi", 0)) == 2
		and int(c.materials.get("la-chuoi", 0)) == 2)
	# Che qua tang: can them vai-vun 1.
	c.learn_recipe("che-qua-tang")
	_check("Crafting+Hotspot: che qua tang thieu vai-vun 1",
		String(c.craft_current("che-qua-tang")["reason"]) == "thieu-nguyen-lieu"
		and int((c.craft_current("che-qua-tang")["missing"] as Dictionary).get("vai-vun", 0)) == 1)
	h.materials["vai-vun"] = 1
	var ok := c.craft_current("che-qua-tang")
	_check("Crafting+Hotspot: du do -> che ok, qua-tang dem 1",
		bool(ok["ok"]) and int(c.crafted_items.get("qua-tang", 0)) == 1)
	_check("Crafting+Hotspot: tui chung sau che: la-chuoi + vai-vun deu xoa key",
		not h.materials.has("la-chuoi") and not h.materials.has("vai-vun")
		and not c.materials.has("la-chuoi"))
	h.free()
	c.free()
