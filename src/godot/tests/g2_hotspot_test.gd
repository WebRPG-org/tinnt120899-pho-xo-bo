extends SceneTree
## G2 hotspot selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_hotspot_test.gd
## Kiem tra: PxbHotspot (bang hotspot slice, nhap dung/sai khung, nhap
## 1 lan/ngay, reset sang ngay moi, has_visited_today, fast travel,
## guide_hint, sparkle, data()/from_data()).
## In "G2 HOTSPOT SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd — file nay chay rieng (tranh xung dot
## voi luong song song).

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
	_test_table()
	_test_explore()
	_test_day_reset()
	_test_fast_travel()
	_test_hint()
	_test_sparkle()
	_test_save()
	print("G2 HOTSPOT SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _test_table() -> void:
	_check("Bang: 5 hotspot slice", PxbHotspot.HOTSPOTS.size() == 5)
	var h := PxbHotspot.get_hotspot("hs-cho-sang")
	_check("get: hs-cho-sang khu 2 / khung Sang / la-chuoi x2",
		String(h.get("name", "")) == "Sạp rau buổi sáng" and int(h.get("district_id", 0)) == 2
		and String(h.get("best_frame", "")) == "Sáng" and String(h.get("material_id", "")) == "la-chuoi"
		and int(h.get("amount", 0)) == 2)
	_check("get: hotspot la tra {}", PxbHotspot.get_hotspot("hs-khong-co").is_empty())
	var d2 := PxbHotspot.hotspots_in_district(2, "Sáng")
	_check("hotspots_in_district: khu 2 co 2 hotspot, khung tot len truoc",
		d2.size() == 2 and String(d2[0]["id"]) == "hs-cho-sang" and String(d2[1]["id"]) == "hs-cho-chieu")
	_check("hotspots_in_district: khu 3 khong co hotspot",
		PxbHotspot.hotspots_in_district(3, "Sáng").is_empty())
	_check("hotspots_in_district: khu 1 khung Toi len truoc",
		PxbHotspot.hotspots_in_district(1, "Tối").size() == 1
		and String(PxbHotspot.hotspots_in_district(1, "Tối")[0]["id"]) == "hs-tro-toi")


func _test_explore() -> void:
	var hs := PxbHotspot.new()
	# Nhat dung khung tra ok + cong vat lieu.
	var r := hs.explore("hs-cho-sang", 1, "Sáng")
	_check("explore dung khung: ok + la-chuoi x2",
		bool(r["ok"]) and String(r["reason"]) == "ok" and String(r["material_id"]) == "la-chuoi"
		and int(r["amount"]) == 2 and int(hs.materials.get("la-chuoi", 0)) == 2)
	# Nhat sai khung tra wrong-frame, khong cong vat lieu.
	var hs2 := PxbHotspot.new()
	var rw := hs2.explore("hs-cho-sang", 1, "Chiều")
	_check("explore sai khung: wrong-frame, khong cong do",
		not bool(rw["ok"]) and String(rw["reason"]) == "wrong-frame" and int(rw["amount"]) == 0
		and int(hs2.materials.get("la-chuoi", 0)) == 0)
	# Sau khi bi wrong-frame van nhat duoc o khung dung (chua tinh la da nhat).
	var rw2 := hs2.explore("hs-cho-sang", 1, "Sáng")
	_check("sau wrong-frame: nhat dung khung van ok",
		bool(rw2["ok"]) and int(hs2.materials.get("la-chuoi", 0)) == 2)
	# Nhat lan 2 cung ngay tra already.
	var r2 := hs.explore("hs-cho-sang", 1, "Sáng")
	_check("explore lan 2 cung ngay: already, khong cong them",
		not bool(r2["ok"]) and String(r2["reason"]) == "already"
		and int(hs.materials.get("la-chuoi", 0)) == 2)
	# Hotspot khong co tra unknown.
	var ru := hs.explore("hs-khong-co", 1, "Sáng")
	_check("explore hotspot la: unknown",
		not bool(ru["ok"]) and String(ru["reason"]) == "unknown")
	# has_visited_today.
	_check("has_visited_today: da nhat true, chua nhat false",
		hs.has_visited_today("hs-cho-sang") and not hs.has_visited_today("hs-cho-chieu"))


func _test_day_reset() -> void:
	var hs := PxbHotspot.new()
	hs.explore("hs-cho-sang", 1, "Sáng")
	_check("ngay 1: da nhat hs-cho-sang", hs.has_visited_today("hs-cho-sang"))
	# Sang ngay game moi (game_day 2) nhat lai duoc.
	var r := hs.explore("hs-cho-sang", 2, "Sáng")
	_check("sang ngay 2: nhat lai duoc (ok), vat lieu cong them",
		bool(r["ok"]) and String(r["reason"]) == "ok" and int(hs.materials.get("la-chuoi", 0)) == 4)
	_check("sang ngay 2: day_number doi theo", hs.day_number == 2)
	# new_game_day() xoa luot trong ngay.
	hs.new_game_day()
	_check("new_game_day: xoa luot da nhat", not hs.has_visited_today("hs-cho-sang"))
	# advance_day() tang ngay + reset.
	hs.explore("hs-cho-chieu", 2, "Chiều")
	var d := hs.advance_day()
	_check("advance_day: ngay 3 + reset luot",
		d == 3 and hs.day_number == 3 and not hs.has_visited_today("hs-cho-chieu"))


func _test_fast_travel() -> void:
	var hs := PxbHotspot.new()
	_check("can_fast_travel: khu 1/2/17/18 da mo",
		hs.can_fast_travel(1) and hs.can_fast_travel(2)
		and hs.can_fast_travel(17) and hs.can_fast_travel(18))
	_check("can_fast_travel: khu 3 chua mo -> false", not hs.can_fast_travel(3))
	_check("can_fast_travel: khu 0 / 19 ngoai 18 khu -> false",
		not hs.can_fast_travel(0) and not hs.can_fast_travel(19))
	_check("can_fast_travel_to (tinh): danh sach rong -> false",
		not PxbHotspot.can_fast_travel_to(1, []))
	_check("can_fast_travel_to (tinh): danh sach mo rong chap nhan",
		PxbHotspot.can_fast_travel_to(5, [5, 6]))


func _test_hint() -> void:
	_check("guide_hint khu 2: Chi Le + muc tieu",
		PxbHotspot.guide_hint(2, "làm xe đẩy").begins_with("Chị Lệ")
		and "làm xe đẩy" in PxbHotspot.guide_hint(2, "làm xe đẩy"))
	_check("guide_hint khu 1: Co Tu", PxbHotspot.guide_hint(1, "").begins_with("Cô Tư"))
	_check("guide_hint khu 17: Ong Ba", PxbHotspot.guide_hint(17, "").begins_with("Ông Ba"))
	_check("guide_hint khu 18: Anh Hai", PxbHotspot.guide_hint(18, "").begins_with("Anh Hải"))
	_check("guide_hint khu khac: Ban than + muc tieu mac dinh",
		PxbHotspot.guide_hint(5, "").begins_with("Bạn thân")
		and "chưa có mục tiêu rõ" in PxbHotspot.guide_hint(5, ""))


func _test_sparkle() -> void:
	_check("min_touch_pt = 44", PxbHotspot.min_touch_pt() == 44)
	var h := PxbHotspot.get_hotspot("hs-cho-sang")
	_check("sparkle_color: hotspot thuong = vang #E0A800",
		PxbHotspot.sparkle_color(h) == "#E0A800")
	_check("sparkle_color: hotspot hiem (PROVISIONAL) = cam #E07800",
		PxbHotspot.sparkle_color({"rarity": "hiem"}) == "#E07800")
	_check("sparkle_brightness: da nhat 0.25",
		is_equal_approx(PxbHotspot.sparkle_brightness(h, "Sáng", true), 0.25))
	_check("sparkle_brightness: dung khung tot 1.5",
		is_equal_approx(PxbHotspot.sparkle_brightness(h, "Sáng", false), 1.5))
	_check("sparkle_brightness: sai khung 0.8",
		is_equal_approx(PxbHotspot.sparkle_brightness(h, "Chiều", false), 0.8))
	_check("sparkle_scale(0) = 0.85",
		is_equal_approx(PxbHotspot.sparkle_scale(0.0), 0.85))


func _test_save() -> void:
	var hs := PxbHotspot.new()
	hs.explore("hs-cho-sang", 1, "Sáng")
	hs.explore("hs-tro-toi", 1, "Tối")
	var d := hs.data()
	_check("data: ngay 1, 2 luot, vat lieu du",
		int(d["day"]) == 1 and (d["visited"] as Array).size() == 2
		and int((d["materials"] as Dictionary).get("la-chuoi", 0)) == 2
		and int((d["materials"] as Dictionary).get("chai-nhua", 0)) == 2)
	var hs2 := PxbHotspot.from_data(d)
	_check("from_data: khoi phuc ngay + luot + vat lieu",
		hs2.day_number == 1 and hs2.has_visited_today("hs-cho-sang")
		and hs2.has_visited_today("hs-tro-toi")
		and int(hs2.materials.get("chai-nhua", 0)) == 2)
	# from_data bo luot cua hotspot la (save sua tay / bang doi).
	var bad := {"day": 0, "visited": ["hs-cho-sang", "hs-khong-co"], "materials": {}, "unlocked": [1, 2]}
	var hs3 := PxbHotspot.from_data(bad)
	_check("from_data: kep ngay >= 1, bo hotspot la",
		hs3.day_number == 1 and hs3.has_visited_today("hs-cho-sang")
		and not hs3.has_visited_today("hs-khong-co"))
