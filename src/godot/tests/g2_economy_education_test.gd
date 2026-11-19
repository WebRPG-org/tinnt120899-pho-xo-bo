extends SceneTree
## G2 ECONOMY + EDUCATION selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_economy_education_test.gd
## Kiem tra: PxbEconomy (port Economy.cs / PXB_Economy.js) — catalog 17
## mon, vi + tiet kiem + lai 0,5%/thang, mua + Danh vong mua lon, dau gia
## phi 5%, doi do, chia tai san, set bonus, dress-code, 4 hanh vi bi
## chan; PxbEducation (port PXB_Education.js) — 5 bac hoc, dang ky /
## tot nghiep theo ngay game, khoa ngan han, hoc bong, ghe / thu tu
## dang ky, mentor, save round-trip.
## In "G2 ECONOMY+EDUCATION SELFTEST: n/n PASS".
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
	_test_economy_catalog()
	_test_economy_wallet()
	_test_economy_buy()
	_test_economy_auction_barter_split()
	_test_economy_set_bonus_dress_code()
	_test_economy_blocked()
	_test_economy_save()
	_test_education_degrees()
	_test_education_enroll()
	_test_education_graduation()
	_test_education_short_course()
	_test_education_scholarship_seats()
	_test_education_save()
	print("G2 ECONOMY+EDUCATION SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _test_economy_catalog() -> void:
	# Catalog lay tu PxbBalance (nha) + Economy.cs (xe/dien thoai/quan ao).
	var cat := PxbEconomy.catalog()
	_check("Economy: catalog 6 nha / 6 xe / 2 dien thoai / 3 quan ao",
		(cat["houses"] as Array).size() == 6 and (cat["cars"] as Array).size() == 6
		and (cat["phones"] as Array).size() == 2 and (cat["clothes"] as Array).size() == 3)
	var tro := PxbEconomy.get_item("phong-tro")
	_check("Economy: phong tro thue 2tr/thang, The -5, An Yen +5, set Nha am",
		int(tro["price_vnd"]) == 2000000 and int((tro["stats"] as Dictionary)["the"]) == -5
		and int((tro["stats"] as Dictionary)["an_yen"]) == 5
		and String((tro["stats"] as Dictionary)["set"]) == "Nhà ấm")
	_check("Economy: penthouse 100 ti, Danh vong +50",
		int(PxbEconomy.get_item("penthouse-dao")["price_vnd"]) == 100000000000
		and int((PxbEconomy.get_item("penthouse-dao")["stats"] as Dictionary)["fame"]) == 50)
	_check("Economy: xe sang 5 ti, mo Giam doc can xe, set Sang trong",
		int(PxbEconomy.get_item("xe-sang")["price_vnd"]) == 5000000000
		and String((PxbEconomy.get_item("xe-sang")["stats"] as Dictionary)["unlocks"]) == "Giám đốc cần xe"
		and String((PxbEconomy.get_item("xe-sang")["stats"] as Dictionary)["set"]) == "Sang trọng")
	_check("Economy: xe dap 0d, The +5; vest 20tr, Tam +10, Danh vong +20",
		int(PxbEconomy.get_item("xe-dap")["price_vnd"]) == 0
		and int((PxbEconomy.get_item("xe-dap")["stats"] as Dictionary)["the"]) == 5
		and int(PxbEconomy.get_item("vest-giam-doc")["price_vnd"]) == 20000000
		and int((PxbEconomy.get_item("vest-giam-doc")["stats"] as Dictionary)["fame"]) == 20)
	_check("Economy: mon la tra {}", PxbEconomy.get_item("khong-co-mon").is_empty())
	_check("Economy: diem tin dung khoi dau 100",
		PxbEconomy.new().credit_score == 100)


func _test_economy_wallet() -> void:
	var eco := PxbEconomy.new(10000000)
	_check("Economy: khoi tao 10tr, tiet kiem 0, tai san 10tr",
		eco.money == 10000000 and eco.savings == 0 and eco.total_assets() == 10000000)
	_check("Economy: gui 4tr ok", eco.deposit_savings(4000000)
		and eco.money == 6000000 and eco.savings == 4000000)
	_check("Economy: gui vuot tien mat bi chan, so du khong doi",
		not eco.deposit_savings(7000000) and eco.money == 6000000)
	_check("Economy: gui <= 0 bi chan",
		not eco.deposit_savings(0) and not eco.deposit_savings(-1000))
	_check("Economy: rut 1tr ok", eco.withdraw_savings(1000000)
		and eco.money == 7000000 and eco.savings == 3000000)
	_check("Economy: rut vuot tiet kiem bi chan",
		not eco.withdraw_savings(4000000) and eco.savings == 3000000)
	# Lai: moi truong hop dung instance moi de khong dinh state.
	var e1 := PxbEconomy.new(0)
	e1.savings = 10000000
	_check("Economy: lai 30 ngay = 0,5% tiet kiem (50k)",
		e1.apply_monthly_interest(30) == 50000 and e1.savings == 10050000)
	var e2 := PxbEconomy.new(0)
	e2.savings = 10000000
	_check("Economy: lai 60 ngay = 2 thang (100k)",
		e2.apply_monthly_interest(60) == 100000 and e2.savings == 10100000)
	var e3 := PxbEconomy.new(0)
	e3.savings = 10000000
	_check("Economy: 29 ngay = 0 thang, lai 0",
		e3.apply_monthly_interest(29) == 0 and e3.savings == 10000000)
	var e4 := PxbEconomy.new(0)
	_check("Economy: tiet kiem 0 thi lai 0", e4.apply_monthly_interest(90) == 0)


func _test_economy_buy() -> void:
	var eco := PxbEconomy.new(10000000000)
	var r := eco.buy("khong-co-mon")
	_check("Economy: mua mon la -> khong-co-mon, tien khong doi",
		not bool(r["ok"]) and String(r["reason"]) == "khong-co-mon"
		and eco.money == 10000000000)
	# Khong du tien mua penthouse 100 ti.
	var r2 := eco.buy("penthouse-dao")
	_check("Economy: khong du tien -> khong-du-tien, tien + do khong doi",
		not bool(r2["ok"]) and String(r2["reason"]) == "khong-du-tien"
		and eco.money == 10000000000 and eco.owned.is_empty())
	# Phong tro: tru tien thue thang, them vao owned, khong + Danh vong.
	var r3 := eco.buy("phong-tro")
	_check("Economy: thue phong tro 2tr, vao owned, khong + Danh vong",
		bool(r3["ok"]) and int(r3["fame_gained"]) == 0
		and eco.money == 10000000000 - 2000000 and eco.owned_count("phong-tro") == 1)
	# Quirk C#: phong tro van cong 2tr vao tong tai san.
	_check("Economy: tong tai san gom ca phong tro (quirk C#)",
		eco.total_assets() == eco.money + eco.savings + 2000000)
	# Mua nha -> Danh vong +50 (da chot).
	var r4 := eco.buy("chung-cu-mini")
	_check("Economy: mua chung cu mini 800tr, Danh vong +50",
		bool(r4["ok"]) and int(r4["fame_gained"]) == 50
		and eco.money == 10000000000 - 2000000 - 800000000)
	# Xe sang -> Danh vong +50; xe may cu -> khong + Danh vong.
	var r5 := eco.buy("xe-sang")
	_check("Economy: mua xe sang 5 ti, Danh vong +50",
		bool(r5["ok"]) and int(r5["fame_gained"]) == 50)
	var r6 := eco.buy("xe-may-cu")
	_check("Economy: mua xe may cu 15tr, khong + Danh vong",
		bool(r6["ok"]) and int(r6["fame_gained"]) == 0)
	_check("Economy: tong tai san = tien + tiet kiem + gia do da mua",
		eco.total_assets() == eco.money + eco.savings + 2000000 + 800000000 + 5000000000 + 15000000)


func _test_economy_auction_barter_split() -> void:
	_check("Economy: dau gia 1tr -> nguoi ban nhan 950k",
		PxbEconomy.auction_seller_receives(1000000) == 950000)
	_check("Economy: dau gia 999999 -> cat phan le (949999)",
		PxbEconomy.auction_seller_receives(999999) == 949999)
	_check("Economy: dau gia 0 -> 0", PxbEconomy.auction_seller_receives(0) == 0)
	# Doi do: 2 ben deu co do thi doi, thieu 1 ben thi chan.
	var a := PxbEconomy.new(100000000)
	var b := PxbEconomy.new(100000000)
	a.buy("xe-may-cu")
	b.buy("dien-thoai-cu")
	_check("Economy: barter doi xe may cu lay dien thoai cu ok",
		a.barter("xe-may-cu", "dien-thoai-cu", b)
		and a.owned_count("dien-thoai-cu") == 1 and a.owned_count("xe-may-cu") == 0
		and b.owned_count("xe-may-cu") == 1 and b.owned_count("dien-thoai-cu") == 0)
	_check("Economy: barter thieu do 1 ben -> false, do khong doi",
		not a.barter("xe-may-cu", "dien-thoai-cu", b)
		and a.owned_count("dien-thoai-cu") == 1 and b.owned_count("xe-may-cu") == 1)
	_check("Economy: barter voi null -> false", not a.barter("dien-thoai-cu", "xe-may-cu", null))
	# Chia tai san ly hon: chia doi tien mat + tiet kiem. Sau khi gui
	# 4tr, tien mat 6tr + tiet kiem 4tr = tong 10tr -> chia doi 5tr/5tr.
	var c := PxbEconomy.new(10000000)
	c.deposit_savings(4000000)
	var sp := c.split_assets()
	_check("Economy: chia tai san (6tr mat + 4tr tiet kiem) -> mine 5tr, theirs 5tr",
		int(sp["mine"]) == 5000000 and int(sp["theirs"]) == 5000000
		and c.money == 3000000 and c.savings == 2000000)


func _test_economy_set_bonus_dress_code() -> void:
	var eco := PxbEconomy.new(100000000000)
	_check("Economy: chua co do thi set bonus 0/0",
		int(eco.set_bonus()["fame"]) == 0 and int(eco.set_bonus()["an_yen"]) == 0)
	eco.buy("phong-tro")
	eco.buy("chung-cu-mini")
	_check("Economy: 2 mon Nha am thi chua du set bonus",
		int(eco.set_bonus()["fame"]) == 0)
	eco.buy("nha-pho-nho")
	_check("Economy: du 3 mon Nha am -> Danh vong +10, An Yen +5",
		int(eco.set_bonus()["fame"]) == 10 and int(eco.set_bonus()["an_yen"]) == 5)
	# Them set Cong so: 2 bo cong so + 1 vest = 3 mon.
	eco.buy("bo-cong-so")
	eco.buy("bo-cong-so")
	eco.buy("vest-giam-doc")
	_check("Economy: 2 set du 3 mon -> Danh vong +20, An Yen +10",
		int(eco.set_bonus()["fame"]) == 20 and int(eco.set_bonus()["an_yen"]) == 10)
	# Dress-code: ao dai (Truyen thong) khong dat; xe sang (Car, set
	# Sang trong) khong tinh; bo cong so / vest thi dat.
	var d := PxbEconomy.new(100000000000)
	_check("Economy: khong co do thi dress-code false", not d.passes_director_dress_code())
	d.buy("ao-dai")
	_check("Economy: ao dai set Truyen thong thi dress-code van false",
		not d.passes_director_dress_code())
	d.buy("xe-sang")
	_check("Economy: xe sang set Sang trong (loai Car) khong tinh dress-code",
		not d.passes_director_dress_code())
	d.buy("bo-cong-so")
	_check("Economy: co bo cong so thi dress-code true", d.passes_director_dress_code())


func _test_economy_blocked() -> void:
	var eco := PxbEconomy.new(10000000)
	eco.buy("xe-may-cu")
	var before_money := eco.money
	var before_owned := eco.owned.duplicate()
	_check("Economy: cash-out LUON false, tien khong doi",
		not eco.cash_out(1000000) and eco.money == before_money)
	_check("Economy: cho vay lay lai LUON false",
		not eco.lend_with_interest(PxbEconomy.new(0), 1000000, 0.1))
	_check("Economy: co bac LUON false, tien khong doi",
		not eco.gamble(1000000) and eco.money == before_money)
	_check("Economy: mua bang tien that LUON false, do khong doi",
		not eco.buy_with_real_money("xe-sang", 100.0) and eco.owned == before_owned)


func _test_economy_save() -> void:
	var eco := PxbEconomy.new(20000000)
	eco.deposit_savings(3000000)
	eco.buy("xe-may-cu")
	eco.buy("ao-dai")
	var restored := PxbEconomy.from_data(eco.data())
	_check("Economy: save round-trip giu tien/tiet kiem/do",
		restored.money == 0 and restored.savings == 3000000
		and restored.owned_count("xe-may-cu") == 1 and restored.owned_count("ao-dai") == 1)
	# Tien am / tiet kiem am ve 0; id mon la bi bo khi load.
	var dirty := PxbEconomy.from_data({
		"money": -5, "savings": -10, "credit_score": 80,
		"owned": ["xe-may-cu", "khong-co-mon"],
	})
	_check("Economy: load save ban bo id la, kep tien am ve 0",
		dirty.money == 0 and dirty.savings == 0 and dirty.credit_score == 80
		and dirty.owned_count("xe-may-cu") == 1 and dirty.owned.size() == 1)


func _test_education_degrees() -> void:
	_check("Education: 5 bac hoc", PxbEducation.degree_list().size() == 5)
	var thpt := PxbEducation.get_degree(0)
	_check("Education: THPT 0d, 30 ngay, Tri 20, EXP 0, Danh vong 0, khong can mentor",
		String(thpt["name"]) == "THPT" and int(thpt["fee_vnd"]) == 0
		and int(thpt["days"]) == 30 and int(thpt["tri"]) == 20
		and int(thpt["exp"]) == 0 and int(thpt["fame"]) == 0 and not bool(thpt["mentor"]))
	var ts := PxbEducation.get_degree("Tiến sĩ / Học giả")
	_check("Education: Tien si 500tr, 240 ngay, Tri 90, EXP 6000, Danh vong 1500, CAN mentor",
		int(ts["fee_vnd"]) == 500000000 and int(ts["days"]) == 240
		and int(ts["tri"]) == 90 and int(ts["exp"]) == 6000
		and int(ts["fame"]) == 1500 and bool(ts["mentor"]))
	_check("Education: Cu nhan 80tr, 120 ngay, Tri 60, EXP 1500, Danh vong 200",
		int(PxbEducation.get_degree(2)["fee_vnd"]) == 80000000
		and int(PxbEducation.get_degree(2)["days"]) == 120
		and int(PxbEducation.get_degree("Cử nhân")["exp"]) == 1500
		and int(PxbEducation.get_degree("Cử nhân")["fame"]) == 200)
	_check("Education: bac la / ten la tra {}",
		PxbEducation.get_degree(9).is_empty() and PxbEducation.get_degree("Không có").is_empty())
	_check("Education: degree_index theo ten/so, la tra -1",
		PxbEducation.degree_index("Cử nhân") == 2 and PxbEducation.degree_index(4) == 4
		and PxbEducation.degree_index("x") == -1 and PxbEducation.degree_index(9) == -1)


func _test_education_enroll() -> void:
	var edu := PxbEducation.new()
	_check("Education: idx sai -> khong-co-bang",
		String(edu.can_enroll(9, 100)["reason"]) == "khong-co-bang")
	_check("Education: Tri 10 hoc THPT (can 20) -> chua-du-tri",
		String(edu.can_enroll(0, 10)["reason"]) == "chua-du-tri")
	_check("Education: Tien si khong mentor -> can-mentor",
		String(edu.can_enroll(4, 90)["reason"]) == "can-mentor")
	_check("Education: Cu nhan Tri 65 ma tien 10tr -> khong-du-tien",
		String(edu.can_enroll(2, 65, -1, 10000000)["reason"]) == "khong-du-tien")
	_check("Education: THPT Tri 20, bo qua tien -> ok",
		bool(edu.can_enroll(0, 20)["ok"]))
	var r := edu.enroll(0, 20)
	_check("Education: dang ky THPT ok, ngay 1 -> het ngay 31, phi 0, charged false",
		bool(r["ok"]) and int(r["start_day"]) == 1 and int(r["end_day"]) == 31
		and int(r["fee_paid"]) == 0 and not bool(r["charged"])
		and int(r["register_order"]) == 1)
	_check("Education: dang hoc 1 bang thi dang ky bang khac -> dang-hoc",
		String(edu.can_enroll(1, 40)["reason"]) == "dang-hoc")
	_check("Education: tien do THPT con 30 ngay",
		int(edu.study_progress()["days_left"]) == 30)
	_check("Education: chua du ngay thi tot nghiep false",
		not bool(edu.check_graduation()["graduated"]))
	# Mentor tu state: set_mentor(true) roi dang ky Tien si duoc.
	var edu2 := PxbEducation.new()
	edu2.set_mentor(true)
	_check("Education: co mentor + Tri 90 + du tien thi dang ky Tien si ok",
		bool(edu2.can_enroll(4, 90, -1, 500000000)["ok"]))


func _test_education_graduation() -> void:
	var edu := PxbEducation.new()
	edu.enroll(0, 20)
	edu.day_number = 30
	_check("Education: ngay 30 chua du (het ngay 31) -> chua tot nghiep",
		not bool(edu.check_graduation()["graduated"])
		and int(edu.study_progress()["days_left"]) == 1)
	edu.day_number = 31
	var g := edu.check_graduation()
	_check("Education: ngay 31 tot nghiep THPT, bang vao degrees_owned",
		bool(g["graduated"]) and int(g["degree_index"]) == 0
		and edu.degrees_owned == [0] and edu.enrolled.is_empty())
	_check("Education: THPT EXP 0 / Danh vong 0 -> pending 0/0",
		int(g["exp"]) == 0 and int(g["fame"]) == 0
		and edu.pending_exp == 0 and edu.pending_fame == 0)
	_check("Education: goi tot nghiep lan 2 -> false",
		not bool(edu.check_graduation()["graduated"]))
	_check("Education: da co THPT thi dang ky lai THPT -> da-co-bang",
		String(edu.can_enroll(0, 20)["reason"]) == "da-co-bang")
	_check("Education: da co THPT thi dang ky bang thap hon cung chan (luat tam)",
		String(edu.can_enroll(0, 20)["reason"]) == "da-co-bang")
	# Hoc tiep Cao dang: EXP 500 cong don vao pending.
	edu.enroll(1, 40, -1, 20000000)
	edu.day_number = 31 + 60
	var g2 := edu.check_graduation()
	_check("Education: tot nghiep Cao dang, pending EXP 500, Danh vong 0",
		bool(g2["graduated"]) and edu.degrees_owned == [0, 1]
		and edu.pending_exp == 500 and edu.pending_fame == 0)
	_check("Education: khong hoc bang nao thi tien do enrolled rong, days_left 0",
		(edu.study_progress()["enrolled"] as Dictionary).is_empty()
		and int(edu.study_progress()["days_left"]) == 0)


func _test_education_short_course() -> void:
	var edu := PxbEducation.new()
	_check("Education: khoa ngan chi so la -> sai-chi-so",
		String(edu.enroll_short_course("the", 5, 5000000)["reason"]) == "sai-chi-so")
	_check("Education: khoa ngan 2 ngay -> sai-so-ngay",
		String(edu.enroll_short_course("ky", 2, 5000000)["reason"]) == "sai-so-ngay")
	_check("Education: khoa ngan 8 ngay -> sai-so-ngay",
		String(edu.enroll_short_course("ky", 8, 5000000)["reason"]) == "sai-so-ngay")
	_check("Education: phi 1tr -> phi-ngoai-khoang",
		String(edu.enroll_short_course("ky", 5, 1000000)["reason"]) == "phi-ngoai-khoang")
	_check("Education: phi 11tr -> phi-ngoai-khoang",
		String(edu.enroll_short_course("ky", 5, 11000000)["reason"]) == "phi-ngoai-khoang")
	_check("Education: khoa ngan tien 3tr < phi 5tr -> khong-du-tien",
		String(edu.enroll_short_course("ky", 5, 5000000, 3000000)["reason"]) == "khong-du-tien")
	# Hoc song song: dang ky bang chinh + khoa ngan cung luc duoc.
	edu.enroll(0, 20)
	var r := edu.enroll_short_course("ky", 5, 5000000)
	_check("Education: dang ky khoa ngan ky 5 ngay ok, ngay 1 -> het ngay 6",
		bool(r["ok"]) and int(r["start_day"]) == 1 and int(r["end_day"]) == 6
		and int(r["fee_paid"]) == 5000000 and int(r["register_order"]) == 2)
	_check("Education: dang hoc 1 khoa ngan thi dang ky khoa khac -> dang-hoc-khoa-ngan",
		String(edu.enroll_short_course("dung", 3, 2000000)["reason"]) == "dang-hoc-khoa-ngan")
	_check("Education: tien do khoa ngan con 5 ngay",
		int(edu.short_course_progress()["days_left"]) == 5)
	edu.day_number = 5
	_check("Education: ngay 5 chua tot nghiep khoa ngan",
		not bool(edu.check_short_course_graduation()["graduated"]))
	edu.day_number = 6
	var g := edu.check_short_course_graduation()
	_check("Education: ngay 6 tot nghiep khoa ngan ky +10 vao pending",
		bool(g["graduated"]) and String(g["sub_stat"]) == "ky" and int(g["gain"]) == 10
		and int(edu.pending_stat_gain["ky"]) == 10 and edu.short_course.is_empty())
	_check("Education: goi tot nghiep khoa ngan lan 2 -> false",
		not bool(edu.check_short_course_graduation()["graduated"]))


func _test_education_scholarship_seats() -> void:
	var edu := PxbEducation.new()
	_check("Education: Tri 70 + tien 15tr -> du dieu kien xet hoc bong",
		edu.scholarship_eligible(70, 15000000))
	_check("Education: Tri 50 -> khong du hoc bong",
		not edu.scholarship_eligible(50, 15000000))
	_check("Education: Tri 70 nhung tien 25tr -> khong du hoc bong",
		not edu.scholarship_eligible(70, 25000000))
	_check("Education: khong truyen tien (chua co vi) -> khong xet",
		not edu.scholarship_eligible(70))
	_check("Education: ghe moi khoa 20-30",
		int(edu.seats_per_course()["min"]) == 20 and int(edu.seats_per_course()["max"]) == 30)
	_check("Education: chua dang ky lan nao thi register_order 0",
		edu.register_order() == 0)
	edu.enroll(0, 20)
	edu.enroll_short_course("sang", 3, 2000000)
	_check("Education: 2 lan dang ky thi register_order 2 (tang dan)",
		edu.register_order() == 2)


func _test_education_save() -> void:
	var edu := PxbEducation.new()
	edu.enroll(0, 20)
	edu.enroll_short_course("ky", 5, 5000000)
	edu.day_number = 31
	edu.check_graduation()
	edu.day_number = 6
	var restored := PxbEducation.from_data(edu.data())
	_check("Education: save round-trip giu bang / pending / thu tu dang ky",
		restored.degrees_owned == [0] and restored.pending_exp == 0
		and int(restored.pending_stat_gain.get("ky", 0)) == 0
		and restored.register_order() == 2 and restored.day_number == 6)
	# Khoa ngan van dang hoc (het ngay 6) nhung ngay hien tai 6 -> van giu.
	_check("Education: save round-trip giu khoa ngan dang hoc",
		not restored.short_course.is_empty()
		and String(restored.short_course["sub_stat"]) == "ky")
	# Du lieu ban: bang la / chi so phu la / khoa la bi bo.
	var dirty := PxbEducation.from_data({
		"degrees_owned": [0, 9, -1, 0],
		"enrolled": {"degree_index": 9, "start_day": 1, "end_day": 31, "register_order": 1},
		"short_course": {"sub_stat": "the", "days": 5, "start_day": 1, "end_day": 6, "register_order": 2},
		"pending_exp": -10, "pending_fame": 5,
		"pending_stat_gain": {"ky": 10, "the": 5},
		"last_register_order": 3, "has_mentor": true, "day_number": 0,
	})
	_check("Education: load save ban bo bang/khoa/chi so la, kep so am ve 0, ngay ve >= 1",
		dirty.degrees_owned == [0] and dirty.enrolled.is_empty()
		and dirty.short_course.is_empty()
		and dirty.pending_exp == 0 and dirty.pending_fame == 5
		and dirty.pending_stat_gain == {"ky": 10}
		and dirty.register_order() == 3 and dirty.has_mentor
		and dirty.day_number == 1)
