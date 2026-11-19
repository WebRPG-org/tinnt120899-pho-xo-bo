extends SceneTree
## G2 SOCIAL + TITLES + STORY selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_social_titles_story_test.gd
## Kiem tra: PxbSocial (port Social.cs / PXB_Social.js) — quan he, than
## thiet, bo be 7 ngay, stage HenHo/DinhHon/Cuoi, gioi han 3 quan he sau,
## ho tro +20% EXP, solo -40%, tan nhom, ly hon, seed slice, save;
## PxbTitles (port TitleConflict.cs / PXB_Titles.js) — bang chan 7 dong,
## chan 2 chieu, khong phan biet hoa/thuong, quirk Ke Lua Dao, phe
## Chinh/Ta/TrungLap, quest Cai ta quy chinh, save; PxbStory (port
## PlayerProgress.cs / PXB_Story.js) — mo 5 chuong, thu tu uu tien
## ending cung, rank co the tut chuong 3, save.
## In "G2 SOCIAL+TITLES+STORY SELFTEST: n/n PASS".
## KHONG sua cac file test khac (tranh xung dot voi luong song song).

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
	_test_social_create_interact()
	_test_social_neglect()
	_test_social_stage()
	_test_social_book()
	_test_social_save()
	_test_titles_blocked()
	_test_titles_book()
	_test_titles_save()
	_test_story_chapters()
	_test_story_advance()
	_test_story_endings()
	_test_story_save()
	print("G2 SOCIAL+TITLES+STORY SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _test_social_create_interact() -> void:
	var rel := PxbSocial.create_relationship("co-tu", "Cô Tư",
		PxbSocial.KIND_BEST_FRIEND, 1)
	_check("Social: moi quen than thiet 20, stage QuenBiet, ngay 1",
		int(rel["closeness"]) == 20
		and String(rel["stage"]) == PxbSocial.STAGE_QUEN_BIET
		and int(rel["last_interaction_day"]) == 1)
	_check("Social: start_day <= 0 thi lay ngay 1",
		int(PxbSocial.create_relationship("x", "X",
			PxbSocial.KIND_PARENT, 0)["last_interaction_day"]) == 1)
	_check("Social: interact mac dinh +5 va cap nhat ngay",
		PxbSocial.interact(rel, 3) and int(rel["closeness"]) == 25
		and int(rel["last_interaction_day"]) == 3)
	_check("Social: interact gain tuy chinh +10",
		PxbSocial.interact(rel, 3, 10) and int(rel["closeness"]) == 35)
	_check("Social: than thiet kep tran 100",
		PxbSocial.interact(rel, 3, 90) and int(rel["closeness"]) == 100)
	_check("Social: interact quan he rong tra false",
		not PxbSocial.interact({}, 1))
	_check("Social: Lover/Spouse/BestFriend/Parent/Child la quan he sau",
		PxbSocial.is_deep(PxbSocial.create_relationship("a", "A",
			PxbSocial.KIND_LOVER, 1))
		and PxbSocial.is_deep(PxbSocial.create_relationship("b", "B",
			PxbSocial.KIND_SPOUSE, 1))
		and PxbSocial.is_deep(PxbSocial.create_relationship("c", "C",
			PxbSocial.KIND_CHILD, 1)))
	_check("Social: FriendGroup / CompanyPartner KHONG phai quan he sau",
		not PxbSocial.is_deep(PxbSocial.create_relationship("g", "G",
			PxbSocial.KIND_FRIEND_GROUP, 1))
		and not PxbSocial.is_deep(PxbSocial.create_relationship("p", "P",
			PxbSocial.KIND_COMPANY_PARTNER, 1)))
	var tan := PxbSocial.create_relationship("t", "T",
		PxbSocial.KIND_LOVER, 1)
	PxbSocial.break_up(tan)
	_check("Social: da tan thi khong tinh quan he sau",
		not PxbSocial.is_deep(tan))


func _test_social_neglect() -> void:
	var rel := PxbSocial.create_relationship("co-tu", "Cô Tư",
		PxbSocial.KIND_BEST_FRIEND, 1)
	rel["closeness"] = 50
	_check("Social: chua du 7 ngay bo be thi khong giam",
		PxbSocial.apply_neglect(rel, 7) == 0
		and int(rel["closeness"]) == 50)
	_check("Social: dung 7 ngay bo be giam 10",
		PxbSocial.apply_neglect(rel, 8) == 10
		and int(rel["closeness"]) == 40)
	_check("Social: QUIRK goi 2 lan cung ngay thi tru 2 lan (khong cap nhat ngay)",
		PxbSocial.apply_neglect(rel, 8) == 10
		and int(rel["closeness"]) == 30)
	var rel2 := PxbSocial.create_relationship("x", "X",
		PxbSocial.KIND_PARENT, 1)
	rel2["closeness"] = 50
	_check("Social: 14 ngay bo be giam 20",
		PxbSocial.apply_neglect(rel2, 15) == 20
		and int(rel2["closeness"]) == 30)
	_check("Social: than thiet kep san 0 khi bo be lau",
		PxbSocial.apply_neglect(rel2, 100) == 140
		and int(rel2["closeness"]) == 0)
	_check("Social: bo be quan he rong tra 0",
		PxbSocial.apply_neglect({}, 30) == 0)


func _test_social_stage() -> void:
	var rel := PxbSocial.create_relationship("ny", "Người yêu",
		PxbSocial.KIND_LOVER, 1)
	_check("Social: HenHo can than thiet >= 50",
		not PxbSocial.advance_stage(rel, PxbSocial.STAGE_HEN_HO))
	rel["closeness"] = 50
	_check("Social: du 50 thi HenHo duoc",
		PxbSocial.advance_stage(rel, PxbSocial.STAGE_HEN_HO)
		and String(rel["stage"]) == PxbSocial.STAGE_HEN_HO)
	_check("Social: DinhHon can tu HenHo + >= 70",
		not PxbSocial.advance_stage(rel, PxbSocial.STAGE_DINH_HON))
	rel["closeness"] = 70
	_check("Social: du 70 tu HenHo thi DinhHon duoc",
		PxbSocial.advance_stage(rel, PxbSocial.STAGE_DINH_HON))
	_check("Social: Cuoi can tu DinhHon + >= 80",
		not PxbSocial.advance_stage(rel, PxbSocial.STAGE_CUOI))
	rel["closeness"] = 80
	_check("Social: du 80 tu DinhHon thi Cuoi duoc",
		PxbSocial.advance_stage(rel, PxbSocial.STAGE_CUOI))
	_check("Social: advance_stage quan he rong tra false",
		not PxbSocial.advance_stage({}, PxbSocial.STAGE_HEN_HO))
	# QUIRK: advance_stage KHONG kiem tra Kind — Spouse cung di duoc
	# HenHo -> DinhHon -> Cuoi nhu Lover (dung Social.cs).
	var spouse := PxbSocial.create_relationship("vo", "Vợ",
		PxbSocial.KIND_SPOUSE, 1)
	spouse["closeness"] = 80
	_check("Social: QUIRK Spouse van HenHo/DinhHon/Cuoi duoc (khong kiem Kind)",
		PxbSocial.advance_stage(spouse, PxbSocial.STAGE_HEN_HO)
		and PxbSocial.advance_stage(spouse, PxbSocial.STAGE_DINH_HON)
		and PxbSocial.advance_stage(spouse, PxbSocial.STAGE_CUOI))
	var rel2 := PxbSocial.create_relationship("b", "B",
		PxbSocial.KIND_BEST_FRIEND, 1)
	rel2["closeness"] = 90
	PxbSocial.break_up(rel2)
	_check("Social: break_up dua ve TanRa, than thiet 0",
		String(rel2["stage"]) == PxbSocial.STAGE_TAN_RA
		and int(rel2["closeness"]) == 0)


func _test_social_book() -> void:
	var book := PxbSocial.new()
	_check("Social: them quan he moi duoc",
		book.add_rel(PxbSocial.create_relationship("co-tu", "Cô Tư",
			PxbSocial.KIND_BEST_FRIEND, 1)))
	_check("Social: them trung person_id thi false",
		not book.add_rel(PxbSocial.create_relationship("co-tu", "Cô Tư",
			PxbSocial.KIND_BEST_FRIEND, 1)))
	_check("Social: chi co 1 ban than — ban than thu 2 false",
		not book.add_rel(PxbSocial.create_relationship("bt2", "Bạn 2",
			PxbSocial.KIND_BEST_FRIEND, 1)))
	_check("Social: deep_count dem dung quan he sau",
		book.deep_count() == 1 and book.has_best_friend())
	book.add_rel(PxbSocial.create_relationship("me", "Mẹ",
		PxbSocial.KIND_PARENT, 1))
	book.add_rel(PxbSocial.create_relationship("ny", "Người yêu",
		PxbSocial.KIND_LOVER, 1))
	_check("Social: gioi han 3 quan he sau — quan he sau thu 4 false",
		book.deep_count() == 3
		and not book.add_rel(PxbSocial.create_relationship("con", "Con",
			PxbSocial.KIND_CHILD, 1)))
	_check("Social: quan he KHONG sau (hoi ban) van them duoc du da du 3 sau",
		book.add_rel(PxbSocial.create_relationship("hoi", "Hội bạn",
			PxbSocial.KIND_FRIEND_GROUP, 1)))
	_check("Social: chua co supporter khi than thiet < 50",
		not book.has_supporter()
		and book.apply_support_bonus(100) == 100
		and book.apply_solo_penalty(100) == 60)
	var lover := book.get_rel("ny")
	lover["closeness"] = 50
	_check("Social: quan he sau than thiet >= 50 thi co supporter",
		book.has_supporter()
		and book.apply_support_bonus(100) == 120
		and book.apply_solo_penalty(100) == 100)
	lover["closeness"] = 49
	_check("Social: than thiet 49 thi chua du supporter",
		not book.has_supporter())
	_check("Social: hoi ban tan sau 7 ngay khong hop",
		PxbSocial.check_group_dissolved(book.get_rel("hoi"), 8))
	_check("Social: hoi ban chua tan truoc 7 ngay",
		not PxbSocial.check_group_dissolved(book.get_rel("hoi"), 7))
	_check("Social: check_group_dissolved chi ap dung hoi ban",
		not PxbSocial.check_group_dissolved(book.get_rel("ny"), 30))
	# Ly hon: chi Spouse + Cuoi moi duoc.
	var book2 := PxbSocial.new()
	var spouse := PxbSocial.create_relationship("vo", "Vợ",
		PxbSocial.KIND_SPOUSE, 1)
	spouse["closeness"] = 80
	book2.add_rel(spouse)
	PxbSocial.advance_stage(spouse, PxbSocial.STAGE_HEN_HO)
	PxbSocial.advance_stage(spouse, PxbSocial.STAGE_DINH_HON)
	_check("Social: Spouse chua Cuoi thi ly hon false",
		not book2.divorce("vo"))
	PxbSocial.advance_stage(spouse, PxbSocial.STAGE_CUOI)
	book2.record_marriage("vo")
	_check("Social: record/is_married ghi nhan hon nhan",
		book2.is_married_to("vo"))
	_check("Social: Spouse dang Cuoi thi ly hon duoc, xoa khoi marriages",
		book2.divorce("vo")
		and String(spouse["stage"]) == PxbSocial.STAGE_TAN_RA
		and not book2.is_married_to("vo"))
	_check("Social: ly hon nguoi khong co / khong phai Spouse thi false",
		not book2.divorce("khong-co")
		and not book.divorce("ny"))
	_check("Social: seed_slice them NPC ban than tam",
		book2.seed_slice(1)
		and book2.get_rel("ban-than")["display_name"] == "Bạn thân")
	_check("Social: seed_slice lan 2 thi false",
		not book2.seed_slice(1))
	# Bo be toan bo so.
	var book3 := PxbSocial.new()
	var r1 := PxbSocial.create_relationship("a", "A",
		PxbSocial.KIND_PARENT, 1)
	r1["closeness"] = 50
	var r2 := PxbSocial.create_relationship("b", "B",
		PxbSocial.KIND_PARENT, 1)
	r2["closeness"] = 40
	book3.add_rel(r1)
	book3.add_rel(r2)
	_check("Social: apply_neglect_all tra tong so than thiet da giam",
		book3.apply_neglect_all(8) == 20
		and int(r1["closeness"]) == 40 and int(r2["closeness"]) == 30)


func _test_social_save() -> void:
	var book := PxbSocial.new()
	var rel := PxbSocial.create_relationship("co-tu", "Cô Tư",
		PxbSocial.KIND_BEST_FRIEND, 1)
	rel["closeness"] = 65
	book.add_rel(rel)
	book.record_marriage("vo-cu")
	var d := book.data()
	var book2 := PxbSocial.from_data(d)
	_check("Social: save round-trip giu quan he + hon nhan",
		book2.relations.size() == 1
		and int(book2.get_rel("co-tu")["closeness"]) == 65
		and book2.is_married_to("vo-cu"))
	var dirty := {
		"relations": [
			{"person_id": "tot", "display_name": "Tốt",
				"kind": "Lover", "stage": "QuenBiet", "closeness": 150,
				"last_interaction_day": 0},
			{"person_id": "xau-kind", "display_name": "X",
				"kind": "KhongCo", "stage": "QuenBiet", "closeness": 10,
				"last_interaction_day": 1},
			{"person_id": "xau-stage", "display_name": "X",
				"kind": "Lover", "stage": "La", "closeness": 10,
				"last_interaction_day": 1},
			{"display_name": "Thieu id", "kind": "Lover",
				"stage": "QuenBiet", "closeness": 10,
				"last_interaction_day": 1},
			"khong-phai-dict",
		],
		"marriages": ["vo", 123, "", "vo"],
	}
	var book3 := PxbSocial.from_data(dirty)
	_check("Social: from_data bo du lieu ban, kep than thiet 100, ngay >= 1",
		book3.relations.size() == 1
		and int(book3.get_rel("tot")["closeness"]) == 100
		and int(book3.get_rel("tot")["last_interaction_day"]) == 1
		and book3.marriages == ["vo"])


func _test_titles_blocked() -> void:
	_check("Titles: Tuong Cuop chan Cánh sat / Tham phan / Hai quan / Giao vien",
		PxbTitles.is_blocked(["Tướng Cướp"], "Cảnh sát")
		and PxbTitles.is_blocked(["Tướng Cướp"], "Thẩm phán")
		and PxbTitles.is_blocked(["Tướng Cướp"], "Hải quan")
		and PxbTitles.is_blocked(["Tướng Cướp"], "Giáo viên"))
	_check("Titles: chieu nguoc — dang co Canh sat thi khong nhan Tuong Cuop",
		PxbTitles.is_blocked(["Cảnh sát"], "Tướng Cướp")
		and PxbTitles.is_blocked(["Giáo viên"], "Trùm Buôn Lậu"))
	_check("Titles: so sanh khong phan biet hoa/thuong",
		PxbTitles.is_blocked(["tướng cướp"], "CẢNH SÁT")
		and PxbTitles.is_blocked(["Tướng Cướp"], "cảnh sát"))
	_check("Titles: Tham Quan chan Thanh Liem / Nguoi Hung",
		PxbTitles.is_blocked(["Tham Quan"], "Thanh Liêm")
		and PxbTitles.is_blocked(["Tham Quan"], "Người Hùng"))
	_check("Titles: Hoc Gia / Tien si chan Ke Bo Hoc; Ty Phu Tu Thien chan Ke Keo Kiet",
		PxbTitles.is_blocked(["Học Giả"], "Kẻ Bỏ Học")
		and PxbTitles.is_blocked(["Tiến sĩ"], "Kẻ Bỏ Học")
		and PxbTitles.is_blocked(["Tỷ Phú Từ Thiện"], "Kẻ Keo Kiệt"))
	_check("Titles: QUIRK Ke Lua Dao chan Luat Su Chinh Truc nhung KHONG chan Luat Su Bao Chua",
		PxbTitles.is_blocked(["Kẻ Lừa Đảo"], "Luật Sư Chính Trực")
		and not PxbTitles.is_blocked(["Kẻ Lừa Đảo"], "Luật Sư Bào Chữa"))
	_check("Titles: khong bi chan khi khong co xung dot",
		not PxbTitles.is_blocked(["Tướng Cướp"], "Bác sĩ")
		and not PxbTitles.is_blocked(["Học Giả"], "Giáo viên")
		and not PxbTitles.is_blocked([], "Cảnh sát"))
	_check("Titles: null-safe — wanted rong / khong phai string thi false",
		not PxbTitles.is_blocked(["Tướng Cướp"], "")
		and not PxbTitles.is_blocked(["Tướng Cướp"], null)
		and not PxbTitles.is_blocked(["Tướng Cướp"], 123))
	_check("Titles: title rong / khong phai string trong list thi bo qua",
		not PxbTitles.is_blocked(["", null, 123], "Cảnh sát"))


func _test_titles_book() -> void:
	var t := PxbTitles.new()
	_check("Titles: them danh hieu moi duoc",
		t.add_title("Tướng Cướp")
		and t.alignment == PxbTitles.ALIGNMENT_TA)
	_check("Titles: them trung (khong phan biet hoa/thuong) thi false",
		not t.add_title("tướng cướp"))
	_check("Titles: them danh hieu bi chan thi false",
		not t.add_title("Cảnh sát"))
	_check("Titles: them danh hieu rong thi false",
		not t.add_title(""))
	_check("Titles: has khong phan biet hoa/thuong",
		t.has_title("TƯỚNG CƯỚP") and not t.has_title("Thanh Liêm"))
	_check("Titles: can_take_job chan nghe bi xung dot",
		not t.can_take_job("Cảnh sát") and t.can_take_job("Bác sĩ"))
	_check("Titles: phe Ta + phe Chinh cung co thi TrungLap",
		t.add_title("Thanh Liêm")
		and t.alignment == PxbTitles.ALIGNMENT_TRUNG_LAP)
	_check("Titles: can_redeem false khi alignment TrungLap (ca 2 phe)",
		not t.can_redeem() and not t.redeem())
	var t2 := PxbTitles.new()
	t2.add_title("Tướng Cướp")
	t2.add_title("Trùm Buôn Lậu")
	_check("Titles: can_redeem true khi dang phe Ta",
		t2.can_redeem())
	_check("Titles: redeem xoa MOI danh hieu phe Ta, alignment ve TrungLap",
		t2.redeem() and t2.titles.is_empty()
		and t2.alignment == PxbTitles.ALIGNMENT_TRUNG_LAP)
	_check("Titles: redeem lan 2 (khong con phe Ta) thi false",
		not t2.redeem())
	var t3 := PxbTitles.new()
	t3.add_title("Thanh Liêm")
	_check("Titles: phe Chinh thuan thi alignment Chinh, redeem false",
		t3.alignment == PxbTitles.ALIGNMENT_CHINH
		and not t3.can_redeem())
	_check("Titles: remove khong phan biet hoa/thuong, go xong alignment doi",
		t3.remove_title("THANH liêm") and t3.titles.is_empty()
		and t3.alignment == PxbTitles.ALIGNMENT_TRUNG_LAP)
	_check("Titles: remove danh hieu khong co thi false",
		not t3.remove_title("Không Có"))
	var t4 := PxbTitles.new()
	t4.add_title("Kẻ Lừa Đảo")
	_check("Titles: QUIRK trong book — Ke Lua Dao van nhan duoc Luat Su Bao Chua",
		t4.add_title("Luật Sư Bào Chữa")
		and not t4.add_title("Luật Sư Chính Trực"))


func _test_titles_save() -> void:
	var t := PxbTitles.new()
	t.add_title("Tướng Cướp")
	t.add_title("Học Giả")
	var t2 := PxbTitles.from_data(t.data())
	_check("Titles: save round-trip giu danh hieu + alignment",
		t2.titles == ["Tướng Cướp", "Học Giả"]
		and t2.alignment == PxbTitles.ALIGNMENT_TRUNG_LAP)
	var dirty := {"titles": ["Tướng Cướp", "tướng cướp", 123, "",
		"Thanh Liêm", "Thanh Liêm"]}
	var t3 := PxbTitles.from_data(dirty)
	_check("Titles: from_data bo title ban/trung, tinh lai alignment",
		t3.titles == ["Tướng Cướp", "Thanh Liêm"]
		and t3.alignment == PxbTitles.ALIGNMENT_TRUNG_LAP)


func _test_story_chapters() -> void:
	_check("Story: chuong 1 luon mo duoc",
		PxbStory.can_open_chapter(1, 0, 0, 0, false, 0))
	_check("Story: chuong 2 mo khi Tri >= 40 HOAC Danh vong >= 200",
		PxbStory.can_open_chapter(2, 40, 0, 0, false, 0)
		and PxbStory.can_open_chapter(2, 0, 200, 0, false, 0)
		and not PxbStory.can_open_chapter(2, 39, 199, 0, false, 0))
	_check("Story: chuong 3 luon mo duoc (bai kiem tra, dieu kien qua chuong 2 do state kiem)",
		PxbStory.can_open_chapter(3, 0, 0, 0, false, 0))
	_check("Story: chuong 4 can >= 3 quest giup nguoi + 1 quan he than thiet",
		PxbStory.can_open_chapter(4, 0, 0, 0, true, 3)
		and not PxbStory.can_open_chapter(4, 0, 0, 0, true, 2)
		and not PxbStory.can_open_chapter(4, 0, 0, 0, false, 3))
	_check("Story: chuong 5 mo khi Tri >= 60 HOAC Danh vong >= 500 HOAC tai san >= 10 ti",
		PxbStory.can_open_chapter(5, 60, 0, 0, false, 0)
		and PxbStory.can_open_chapter(5, 0, 500, 0, false, 0)
		and PxbStory.can_open_chapter(5, 0, 0, 10000000000, false, 0)
		and not PxbStory.can_open_chapter(5, 59, 499, 9999999999, false, 0))
	_check("Story: chuong la (0/6) thi false",
		not PxbStory.can_open_chapter(0, 99, 9999, 999999999999, true, 99)
		and not PxbStory.can_open_chapter(6, 99, 9999, 999999999999, true, 99))


func _test_story_advance() -> void:
	var s := PxbStory.new()
	_check("Story: ten chuong 1 la Len Pho",
		s.chapter_name() == "Lên Phố")
	_check("Story: 1 -> 2 that bai khi chua du Tri/Danh vong",
		not s.advance_chapter(39, 199, 0, false) and s.chapter == 1)
	_check("Story: 1 -> 2 duoc khi Tri 40",
		s.advance_chapter(40, 0, 0, false) and s.chapter == 2
		and s.unlocked_chapters == [1, 2])
	_check("Story: 2 -> 3 mo luon (bai kiem tra)",
		s.advance_chapter(0, 0, 0, false) and s.chapter == 3)
	_check("Story: pass_chapter3 chi duoc khi dang o chuong 3",
		s.pass_chapter3() and s.chapter3_passed)
	_check("Story: 3 -> 4 that bai khi chua du quest giup nguoi",
		not s.advance_chapter(0, 0, 0, true))
	_check("Story: record_help_quest dem tang dan",
		s.record_help_quest() == 1 and s.record_help_quest() == 2
		and s.record_help_quest() == 3)
	_check("Story: 3 -> 4 that bai khi co quest nhung khong co quan he than thiet",
		not s.advance_chapter(0, 0, 0, false))
	_check("Story: 3 -> 4 duoc khi du 3 quest + co quan he than thiet",
		s.advance_chapter(0, 0, 0, true) and s.chapter == 4)
	_check("Story: 4 -> 5 that bai khi chua du Tri/Danh vong/tai san",
		not s.advance_chapter(59, 499, 9999999999, true))
	_check("Story: 4 -> 5 duoc khi Danh vong 500, unlocked du 5 chuong",
		s.advance_chapter(0, 500, 0, true) and s.chapter == 5
		and s.unlocked_chapters == [1, 2, 3, 4, 5]
		and s.chapter_name() == "Thành Đạt")
	_check("Story: vuot chuong 5 thi false",
		not s.advance_chapter(99, 9999, 999999999999, true))
	var s2 := PxbStory.new()
	s2.advance_chapter(40, 0, 0, false)
	_check("Story: pass_chapter3 false khi khong o chuong 3",
		not s2.pass_chapter3())


func _test_story_endings() -> void:
	_check("Story: uu tien cung — SieuGiau tren GiamDoc/HocGia",
		PxbStory.suggest_ending(100000000000, 90, 1500, 90, true)
			== PxbStory.ENDING_SIEU_GIAU)
	_check("Story: GiamDoc khi tai san >= 10 ti (du du HocGia)",
		PxbStory.suggest_ending(10000000000, 90, 1500, 0, false)
			== PxbStory.ENDING_GIAM_DOC)
	_check("Story: HocGia khi Tri >= 90 VA Danh vong >= 1500",
		PxbStory.suggest_ending(0, 90, 1500, 0, false)
			== PxbStory.ENDING_HOC_GIA
		and PxbStory.suggest_ending(0, 89, 1500, 0, false)
			== PxbStory.ENDING_CHUA_MO
		and PxbStory.suggest_ending(0, 90, 1499, 0, false)
			== PxbStory.ENDING_CHUA_MO)
	_check("Story: GiaDinh khi co vo/chong VA An Yen >= 80",
		PxbStory.suggest_ending(0, 0, 0, 80, true)
			== PxbStory.ENDING_GIA_DINH
		and PxbStory.suggest_ending(0, 0, 0, 79, true)
			== PxbStory.ENDING_CHUA_MO)
	_check("Story: TuDo khi An Yen >= 80 ma khong co vo/chong",
		PxbStory.suggest_ending(0, 0, 0, 80, false)
			== PxbStory.ENDING_TU_DO)
	_check("Story: ChuaMo khi chua du dieu kien ending nao",
		PxbStory.suggest_ending(0, 0, 0, 0, false)
			== PxbStory.ENDING_CHUA_MO)
	_check("Story: rank_at_risk khi Danh vong < 100 HOAC An Yen < 30",
		PxbStory.rank_at_risk(99, 50)
		and PxbStory.rank_at_risk(500, 29)
		and not PxbStory.rank_at_risk(100, 30)
		and not PxbStory.rank_at_risk(500, 80))
	_check("Story: set_ending chi nhan 1 trong 6 gia tri",
		PxbStory.is_valid_ending("HocGia")
		and not PxbStory.is_valid_ending("KhongCo"))
	var s := PxbStory.new()
	_check("Story: set_ending hop le doi state, gia tri la thi false",
		s.set_ending(PxbStory.ENDING_HOC_GIA)
		and s.ending == PxbStory.ENDING_HOC_GIA
		and not s.set_ending("La")
		and s.ending == PxbStory.ENDING_HOC_GIA)
	_check("Story: suggest_ending_now goi y roi LUU vao state",
		s.suggest_ending_now(0, 0, 0, 80, false) == PxbStory.ENDING_TU_DO
		and s.ending == PxbStory.ENDING_TU_DO)


func _test_story_save() -> void:
	var s := PxbStory.new()
	s.advance_chapter(40, 0, 0, false)
	s.advance_chapter(0, 0, 0, false)
	s.record_help_quest()
	s.record_help_quest()
	s.pass_chapter3()
	s.set_ending(PxbStory.ENDING_TU_DO)
	var s2 := PxbStory.from_data(s.data())
	_check("Story: save round-trip giu chuong/quest/pass/ending/unlocked",
		s2.chapter == 3 and s2.help_quests_done == 2
		and s2.chapter3_passed and s2.ending == PxbStory.ENDING_TU_DO
		and s2.unlocked_chapters == [1, 2, 3])
	var dirty := {"chapter": 99, "help_quests_done": -5,
		"chapter3_passed": true, "ending": "La",
		"unlocked_chapters": [1, 1, 9, 3]}
	var s3 := PxbStory.from_data(dirty)
	_check("Story: from_data kep chuong 1..5, ending la ve ChuaMo, unlocked sach + co chuong hien tai",
		s3.chapter == 5 and s3.help_quests_done == 0
		and s3.ending == PxbStory.ENDING_CHUA_MO
		and s3.unlocked_chapters == [1, 3, 5])
