extends SceneTree
## G2 selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_selftest.gd
## Kiem tra: PxbBalance (so chot khop GameBalance.cs / PXB_Balance.js),
## PxbStats (3 goc + 4 tron + train danh doi + tran tong),
## PxbTime (khung, miss, dong ho game, su kien thu 7, dong ho chay).
## In "G2 SELFTEST: n/n PASS".

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
	_test_balance()
	_test_stats()
	_test_time()
	print("G2 SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _test_balance() -> void:
	# Thoi gian kieu C (GDD Muc 1, khop GameBalance.cs + TimeSystem.cs).
	_check("Balance: 1 ngay = 30 phut that", PxbBalance.GAME_DAY_MINUTES == 30)
	_check("Balance: 3 khung/ngay", PxbBalance.FRAMES_PER_DAY == 3)
	_check("Balance: 1 khung = 10 phut", PxbBalance.FRAME_MINUTES == 10)
	_check("Balance: ten 3 khung", PxbBalance.FRAMES == ["Sáng", "Chiều", "Tối"])
	# Hoc van 5 bac (khop GameBalance.Degrees).
	_check("Balance: 5 bac hoc van", PxbBalance.DEGREES.size() == 5)
	_check("Balance: THPT free/30d/Tri 20/EXP 0",
		int(PxbBalance.DEGREES[0]["fee_vnd"]) == 0 and int(PxbBalance.DEGREES[0]["days"]) == 30
		and int(PxbBalance.DEGREES[0]["tri"]) == 20 and int(PxbBalance.DEGREES[0]["exp"]) == 0)
	_check("Balance: Cao dang 20tr/60d/Tri 40/EXP 500",
		int(PxbBalance.DEGREES[1]["fee_vnd"]) == 20000000 and int(PxbBalance.DEGREES[1]["days"]) == 60
		and int(PxbBalance.DEGREES[1]["tri"]) == 40 and int(PxbBalance.DEGREES[1]["exp"]) == 500)
	_check("Balance: Cu nhan 80tr/120d/Tri 60/EXP 1500/DV 200",
		int(PxbBalance.DEGREES[2]["fee_vnd"]) == 80000000 and int(PxbBalance.DEGREES[2]["days"]) == 120
		and int(PxbBalance.DEGREES[2]["tri"]) == 60 and int(PxbBalance.DEGREES[2]["exp"]) == 1500
		and int(PxbBalance.DEGREES[2]["fame"]) == 200)
	_check("Balance: Thac si 200tr/180d/Tri 75/EXP 3000/DV 500",
		int(PxbBalance.DEGREES[3]["fee_vnd"]) == 200000000 and int(PxbBalance.DEGREES[3]["days"]) == 180
		and int(PxbBalance.DEGREES[3]["tri"]) == 75 and int(PxbBalance.DEGREES[3]["exp"]) == 3000
		and int(PxbBalance.DEGREES[3]["fame"]) == 500)
	_check("Balance: Tien si 500tr/240d/Tri 90/EXP 6000/DV 1500/mentor",
		int(PxbBalance.DEGREES[4]["fee_vnd"]) == 500000000 and int(PxbBalance.DEGREES[4]["days"]) == 240
		and int(PxbBalance.DEGREES[4]["tri"]) == 90 and int(PxbBalance.DEGREES[4]["exp"]) == 6000
		and int(PxbBalance.DEGREES[4]["fame"]) == 1500 and bool(PxbBalance.DEGREES[4]["mentor"]))
	_check("Balance: degree() tra dung bac", String(PxbBalance.degree(2)["name"]) == "Cử nhân")
	_check("Balance: degree() ngoai bien tra {}",
		PxbBalance.degree(-1).is_empty() and PxbBalance.degree(5).is_empty())
	# Khoa ngan han + cung cau.
	_check("Balance: khoa ngan 3-7 ngay, 2-10tr, +10 chi so",
		PxbBalance.SHORT_COURSE_MIN_DAYS == 3 and PxbBalance.SHORT_COURSE_MAX_DAYS == 7
		and PxbBalance.SHORT_COURSE_MIN_FEE_VND == 2000000 and PxbBalance.SHORT_COURSE_MAX_FEE_VND == 10000000
		and PxbBalance.SHORT_COURSE_STAT_GAIN == 10)
	_check("Balance: thieu nguoi +30%, bao hoa -15%, ghe 20-30",
		PxbBalance.SHORTAGE_SALARY_BONUS_PERCENT == 30 and PxbBalance.SATURATED_SALARY_CUT_PERCENT == 15
		and PxbBalance.SCHOOL_SEATS_PER_COURSE_MIN == 20 and PxbBalance.SCHOOL_SEATS_PER_COURSE_MAX == 30)
	# Giay phep / thi / cong ty.
	_check("Balance: sap 50tr, phong kham 200tr, thi 5-20tr",
		PxbBalance.FOOD_STALL_LICENSE_VND == 50000000 and PxbBalance.CLINIC_LICENSE_VND == 200000000
		and PxbBalance.EXAM_FEE_MIN_VND == 5000000 and PxbBalance.EXAM_FEE_MAX_VND == 20000000)
	_check("Balance: cong ty von 500tr, xoa sau 2 tuan khong hoat dong",
		PxbBalance.COMPANY_CAPITAL_VND == 500000000 and PxbBalance.COMPANY_INACTIVE_WEEKS_TO_REMOVE == 2)
	# Xa hoi + tai chinh.
	_check("Balance: bo be 7 ngay, ho tro +20% EXP, solo cham 30-50%",
		PxbBalance.NEGLECT_DAYS_TO_DROP_CLOSENESS == 7 and PxbBalance.SUPPORTED_EXP_BONUS_PERCENT == 20
		and PxbBalance.SOLO_SLOWER_PERCENT_MIN == 30 and PxbBalance.SOLO_SLOWER_PERCENT_MAX == 50)
	_check("Balance: lai 0,5%/thang, phi dau gia 5%, mua lon +50 DV",
		is_equal_approx(PxbBalance.BANK_INTEREST_PER_GAME_MONTH, 0.005)
		and PxbBalance.AUCTION_FEE_PERCENT == 5 and PxbBalance.BIG_PURCHASE_FAME_BONUS == 50)
	# Thang nha 6 bac.
	_check("Balance: tro 2tr/thang, mini 800tr, pho nho 3 ti",
		PxbBalance.ROOM_RENT_PER_MONTH_VND == 2000000 and PxbBalance.MINI_APARTMENT_VND == 800000000
		and PxbBalance.SMALL_TOWNHOUSE_VND == 3000000000)
	_check("Balance: pho lon 8 ti, biet thu 25 ti, penthouse/dao 100 ti",
		PxbBalance.LARGE_TOWNHOUSE_VND == 8000000000 and PxbBalance.VILLA_VND == 25000000000
		and PxbBalance.PENTHOUSE_ISLAND_VND == 100000000000)
	# Rank Chuong 5.
	_check("Balance: Giam doc 10 ti, Sieu giau 100 ti, An Yen 80",
		PxbBalance.DIRECTOR_ASSETS_VND == 10000000000 and PxbBalance.SUPER_RICH_ASSETS_VND == 100000000000
		and PxbBalance.FAMILY_ENDING_AN_YEN == 80)
	# Chi so PROVISIONAL.
	_check("Balance: tran tong 300 / tran chi so 100 / nguong An Yen 10 (PROVISIONAL)",
		PxbBalance.TOTAL_STAT_CAP == 300 and PxbBalance.STAT_MAX == 100
		and PxbBalance.AN_YEN_BALANCE_TOLERANCE == 10)
	# Nghe slice + cong thuc che tao (PROVISIONAL).
	_check("Balance: khung tot +25%, 3 nghe slice",
		PxbBalance.GOOD_FRAME_BONUS_PERCENT == 25 and PxbBalance.JOBS.size() == 3)
	_check("Balance: ban rong 150k khung Chieu, chi so The",
		int(PxbBalance.JOBS[0]["base_pay_vnd"]) == 150000 and String(PxbBalance.JOBS[0]["good_frame"]) == "Chiều"
		and String(PxbBalance.JOBS[0]["main_stat"]) == "the")
	_check("Balance: shipper 180k khung Toi", int(PxbBalance.JOBS[1]["base_pay_vnd"]) == 180000
		and String(PxbBalance.JOBS[1]["good_frame"]) == "Tối")
	_check("Balance: nhan vien quan 150k khung Sang, chi so Tam",
		int(PxbBalance.JOBS[2]["base_pay_vnd"]) == 150000 and String(PxbBalance.JOBS[2]["good_frame"]) == "Sáng"
		and String(PxbBalance.JOBS[2]["main_stat"]) == "tam")
	_check("Balance: job_by_id('shipper') dung", String(PxbBalance.job_by_id("shipper")["name"]) == "Shipper")
	_check("Balance: job_by_id la tra {}", PxbBalance.job_by_id("khong-co").is_empty())
	_check("Balance: 3 cong thuc che tao slice", PxbBalance.RECIPES.size() == 3)
	_check("Balance: recipe_by_id('che-den-soi') dung",
		String(PxbBalance.recipe_by_id("che-den-soi")["name"]) == "Đèn Soi (bậc 1)")


func _test_stats() -> void:
	# create(): tong khoi dau phai = tran 300.
	var s := PxbStats.create(100, 100, 100)
	_check("Stats: create(100,100,100) tong 300", s != null and s.total() == 300)
	_check("Stats: create tong sai tra null", PxbStats.create(100, 100, 99) == null)
	_check("Stats: create(120,90,90) kep the ve 100 -> tong 280 -> null", PxbStats.create(120, 90, 90) == null)
	var s2 := PxbStats.create(90, 100, 110)
	_check("Stats: create(90,100,110) kep tam 100 -> tong 290 -> null", s2 == null)
	# Chi so tron.
	_check("Stats: Ky/Dung/Sang = 100 khi can bang", s.ky() == 100 and s.dung() == 100 and s.sang() == 100)
	_check("Stats: An Yen = 100 khi 3 goc can bang", s.an_yen() == 100)
	var w := PxbStats.with_values(80, 100, 90)
	_check("Stats: Ky=(80+100)/2=90, Dung=(80+90)/2=85, Sang=(100+90)/2=95",
		w.ky() == 90 and w.dung() == 85 and w.sang() == 95)
	_check("Stats: An Yen = 0 khi lech >10 (80 vs 100)", w.an_yen() == 0)
	var w2 := PxbStats.with_values(95, 100, 90)
	_check("Stats: An Yen = (95+100+90)/3=95 khi lech trong 10", w2.an_yen() == 95)
	# Kep 0..100.
	var w3 := PxbStats.with_values(-5, 150, 50)
	_check("Stats: kep 0..100 (-5->0, 150->100)", w3.the == 0 and w3.tri == 100 and w3.tam == 50)
	w3.the = 200
	_check("Stats: gan truc tiep cung kep (200->100)", w3.the == 100)
	# Train = danh doi, tong khong doi.
	var t := PxbStats.with_values(90, 100, 80)
	_check("Stats: train(the, tri, 5) thanh cong", t.train("the", "tri", 5))
	_check("Stats: sau train the 95 tri 95 tam 80, tong 270", t.the == 95 and t.tri == 95 and t.tam == 80 and t.total() == 270)
	_check("Stats: train trung chi so -> false", not t.train("the", "the", 5))
	_check("Stats: train luong 0 -> false", not t.train("the", "tri", 0))
	_check("Stats: train vuot tran 100 -> false", not PxbStats.with_values(98, 100, 50).train("the", "tri", 5))
	_check("Stats: train giam duoi 0 -> false", not PxbStats.with_values(50, 3, 50).train("the", "tri", 5))
	_check("Stats: train chi so la -> false", not t.train("the", "khong-co", 5))
	# data / from_data / default_data.
	_check("Stats: data() tra dung 3 goc", t.data() == {"the": 95, "tri": 95, "tam": 80})
	var back := PxbStats.from_data({"the": 60, "tri": 70, "tam": 80})
	_check("Stats: from_data khoi phuc dung", back.the == 60 and back.tri == 70 and back.tam == 80)
	_check("Stats: default_data tong = tran 300",
		int(PxbStats.default_data()["the"]) + int(PxbStats.default_data()["tri"]) + int(PxbStats.default_data()["tam"]) == 300)
	_check("Stats: get_stat la tra 0", t.get_stat("khong-co") == 0)
	# Don cac Node tao trong test ( tranh canh bao leak ObjectDB khi thoat).
	for node in [s, w, w2, w3, t, back]:
		if node != null:
			node.free()


func _test_time() -> void:
	# Khung theo phut troi (bien 10 / 20).
	_check("Time: frame 0 phut -> Sang", PxbTime.frame_index(0.0) == 0)
	_check("Time: frame 9.9 phut -> Sang", PxbTime.frame_index(9.9) == 0)
	_check("Time: frame 10 phut -> Chieu", PxbTime.frame_index(10.0) == 1)
	_check("Time: frame 19.9 phut -> Chieu", PxbTime.frame_index(19.9) == 1)
	_check("Time: frame 20 phut -> Toi", PxbTime.frame_index(20.0) == 2)
	_check("Time: frame 29.9 phut -> Toi", PxbTime.frame_index(29.9) == 2)
	_check("Time: frame_name 5/15/25 phut", PxbTime.frame_name(5.0) == "Sáng"
		and PxbTime.frame_name(15.0) == "Chiều" and PxbTime.frame_name(25.0) == "Tối")
	# Miss khung khong phat — chi hien thi.
	_check("Time: miss Sang luc 5 phut = false", not PxbTime.is_missed(0, 5.0))
	_check("Time: miss Sang luc 10 phut = true", PxbTime.is_missed(0, 10.0))
	_check("Time: miss Chieu luc 15 phut = false", not PxbTime.is_missed(1, 15.0))
	_check("Time: miss Chieu luc 20 phut = true", PxbTime.is_missed(1, 20.0))
	_check("Time: miss Toi luc 25 phut = false", not PxbTime.is_missed(2, 25.0))
	_check("Time: miss Toi luc 30 phut = true", PxbTime.is_missed(2, 30.0))
	# Trong khung / con lai / tien do.
	_check("Time: 12.5 phut -> trong khung 2.5, con 7.5",
		is_equal_approx(PxbTime.minutes_into_frame(12.5), 2.5)
		and is_equal_approx(PxbTime.minutes_until_frame_end(12.5), 7.5))
	_check("Time: day_progress 0/15/30/45 phut = 0/0.5/1/1",
		is_equal_approx(PxbTime.day_progress(0.0), 0.0)
		and is_equal_approx(PxbTime.day_progress(15.0), 0.5)
		and is_equal_approx(PxbTime.day_progress(30.0), 1.0)
		and is_equal_approx(PxbTime.day_progress(45.0), 1.0))
	# Dong ho game PROVISIONAL: 1 ngay = 24h game tu 00:00.
	_check("Time: game clock 0 phut = 0 (00:00)", PxbTime.game_clock_minutes(0.0) == 0)
	_check("Time: game clock 15 phut = 720 (12:00)", PxbTime.game_clock_minutes(15.0) == 720)
	_check("Time: game clock 25 phut = 1200 (20:00)", PxbTime.game_clock_minutes(25.0) == 1200)
	_check("Time: game clock hour 25 phut = 20", PxbTime.game_clock_hour(25.0) == 20)
	# Ngay trong tuan PROVISIONAL: ngay 1 = Thu Hai.
	_check("Time: ngay 1 = Thu Hai (0)", PxbTime.game_weekday(1) == 0)
	_check("Time: ngay 6 = Thu Bay (5)", PxbTime.game_weekday(6) == 5)
	_check("Time: ngay 7 = Chu Nhat (6)", PxbTime.game_weekday(7) == 6)
	_check("Time: ngay 8 = Thu Hai lai (0)", PxbTime.game_weekday(8) == 0)
	_check("Time: is_saturday(6) true, is_saturday(5) false",
		PxbTime.is_saturday(6) and not PxbTime.is_saturday(5))
	# Su kien chung thu 7 20:00 gio game (phut that 25..26.25 ngay thu 7:
	# 25/30*24h = 20h; 27 phut da la 21h game nen het cua so su kien).
	_check("Time: su kien thu 7 luc 25 phut = true", PxbTime.is_saturday_event_time(6, 25.0))
	_check("Time: su kien thu 7 luc 15 phut = false", not PxbTime.is_saturday_event_time(6, 15.0))
	_check("Time: su kien ngay 5 luc 25 phut = false", not PxbTime.is_saturday_event_time(5, 25.0))
	_check("Time: su kien thu 7 luc 27 phut = false (da 21h game)",
		not PxbTime.is_saturday_event_time(6, 27.0))
	_check("Time: should_trigger = is_saturday_event_time",
		PxbTime.should_trigger_saturday_event(6, 25.5) and not PxbTime.should_trigger_saturday_event(6, 10.0))
	_check("Time: 1 ngay = 108000 khung (30*60*60)", PxbTime.day_length_frames() == 108000)
	# Dong ho chay (instance).
	var clock := PxbTime.new()
	_check("Time: chua start_day -> elapsed 0", is_equal_approx(clock.elapsed_minutes(), 0.0))
	clock.start_day()
	clock.debug_set_elapsed(12.5)
	_check("Time: debug elapsed 12.5 phut", absf(clock.elapsed_minutes() - 12.5) < 0.05)
	_check("Time: khung hien tai luc 12.5 phut = Chieu (1)",
		clock.current_frame_index() == 1 and clock.current_frame_name() == "Chiều")
	clock.debug_set_elapsed(0.0)
	_check("Time: elapsed 0 -> khung Sang", clock.current_frame_index() == 0)
	clock.day_number = 6
	clock.debug_set_elapsed(25.5)
	_check("Time: ngay 6 luc 25.5 phut = gio su kien", clock.is_current_saturday_event_time())
	clock.free()
