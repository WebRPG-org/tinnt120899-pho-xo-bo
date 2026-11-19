extends SceneTree
## G2 JOBS selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_jobs_test.gd
## Kiem tra: PxbJobs (port PXB_Jobs.js / Jobs.cs) — luong 3 nghe slice,
## bonus khung tot +25%, he so chi so chinh (moc 50/0.5), cung–cau tuan,
## quota tuan 14 ca, EXP, vi tien, thi chung chi, reset tuan.
## In "G2 JOBS SELFTEST: n/n PASS".
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
	_test_pay()
	_test_shift_quota()
	_test_demand()
	_test_exam()
	_test_save()
	print("G2 JOBS SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	quit(0 if _fail == 0 else 1)


func _stats50() -> Dictionary:
	return {"the": 50, "tri": 50, "tam": 50}


func _test_pay() -> void:
	# Dinh nghia nghe lay tu PxbBalance (khong hardcode lai o test).
	_check("Jobs: 3 nghe slice", PxbJobs.job_list().size() == 3)
	_check("Jobs: get_job('shipper') dung ten", String(PxbJobs.get_job("shipper")["name"]) == "Shipper")
	_check("Jobs: get_job la tra {}", PxbJobs.get_job("khong-co").is_empty())
	# Luong 3 nghe slice, chi so 50, khung thuong, cung–cau binh thuong.
	_check("Jobs: ban rong 150k/ca (the 50, khung thuong)",
		PxbJobs.pay_per_shift("ban-rong", _stats50(), "", "binh-thuong") == 150000)
	_check("Jobs: shipper 180k/ca (the 50, khung thuong)",
		PxbJobs.pay_per_shift("shipper", _stats50(), "", "binh-thuong") == 180000)
	_check("Jobs: nhan vien quan 150k/ca (tam 50, khung thuong)",
		PxbJobs.pay_per_shift("nhan-vien-quan", _stats50(), "", "binh-thuong") == 150000)
	# Bonus khung tot +25%.
	_check("Jobs: ban rong khung Chieu +25% = 187500",
		PxbJobs.pay_per_shift("ban-rong", _stats50(), "Chiều", "binh-thuong") == 187500)
	_check("Jobs: shipper khung Toi +25% = 225000",
		PxbJobs.pay_per_shift("shipper", _stats50(), "Tối", "binh-thuong") == 225000)
	_check("Jobs: nhan vien quan khung Sang +25% = 187500",
		PxbJobs.pay_per_shift("nhan-vien-quan", _stats50(), "Sáng", "binh-thuong") == 187500)
	_check("Jobs: ban rong khung Sang khong bonus = 150000",
		PxbJobs.pay_per_shift("ban-rong", _stats50(), "Sáng", "binh-thuong") == 150000)
	# He so chi so chinh: 50 -> 1.0; 100 -> 1.5; 0 -> 0.5 (san); 60 -> 1.1.
	_check("Jobs: stat_factor 50/100/0/60 = 1.0/1.5/0.5/1.1",
		is_equal_approx(PxbJobs.stat_factor(50), 1.0)
		and is_equal_approx(PxbJobs.stat_factor(100), 1.5)
		and is_equal_approx(PxbJobs.stat_factor(0), 0.5)
		and is_equal_approx(PxbJobs.stat_factor(60), 1.1))
	_check("Jobs: the 100 ban rong = 225000",
		PxbJobs.pay_per_shift("ban-rong", {"the": 100, "tri": 50, "tam": 50}, "", "binh-thuong") == 225000)
	_check("Jobs: the 0 ban rong = 75000 (san 50%)",
		PxbJobs.pay_per_shift("ban-rong", {"the": 0, "tri": 50, "tam": 50}, "", "binh-thuong") == 75000)
	_check("Jobs: tam 60 nhan vien quan = 165000",
		PxbJobs.pay_per_shift("nhan-vien-quan", {"the": 50, "tri": 50, "tam": 60}, "", "binh-thuong") == 165000)
	# Cung–cau: thieu +30%, bao hoa -15%.
	_check("Jobs: ban rong thieu nguoi +30% = 195000",
		PxbJobs.pay_per_shift("ban-rong", _stats50(), "", "thieu-nguoi") == 195000)
	_check("Jobs: ban rong bao hoa -15% = 127500",
		PxbJobs.pay_per_shift("ban-rong", _stats50(), "", "bao-hoa") == 127500)
	# Ket hop: the 100 + khung Chieu + thieu nguoi = 150000*1.5*1.25*1.3.
	_check("Jobs: ket hop 100/Chieu/thieu = 365625",
		PxbJobs.pay_per_shift("ban-rong", {"the": 100, "tri": 50, "tam": 50}, "Chiều", "thieu-nguoi") == 365625)
	# Khong co stats -> mac dinh 50 (he so 1.0).
	_check("Jobs: khong stats -> 150000 (mac dinh 50)",
		PxbJobs.pay_per_shift("ban-rong", null, "", "binh-thuong") == 150000)
	# Nghe sai -> -1 (khong throw).
	_check("Jobs: pay nghe sai tra -1", PxbJobs.pay_per_shift("khong-co", _stats50()) == -1)


func _test_shift_quota() -> void:
	var j := PxbJobs.new()
	# Tuan 1: ban rong thieu nguoi (+30%) theo vong xoay PROVISIONAL.
	_check("Jobs: tuan 1 ban rong thieu nguoi, shipper binh thuong, quan bao hoa",
		j.get_demand("ban-rong") == "thieu-nguoi" and j.get_demand("shipper") == "binh-thuong"
		and j.get_demand("nhan-vien-quan") == "bao-hoa")
	# Lam 1 ca ban rong khung Sang (khung thuong): 150000*1.3 = 195000.
	var r := j.work_shift("ban-rong", "Sáng", _stats50())
	_check("Jobs: work_shift ok, pay 195000, exp 10, paid true, con 13 ca",
		bool(r["ok"]) and int(r["pay"]) == 195000 and int(r["exp"]) == 10
		and bool(r["paid"]) and int(r["shifts_left"]) == 13)
	_check("Jobs: vi +195000, EXP +10, da lam 1 ca",
		j.gold == 195000 and j.exp_total == 10 and j.shifts_done("ban-rong") == 1)
	_check("Jobs: last_shift ghi dung ca vua lam",
		String(j.last_shift["job_id"]) == "ban-rong" and int(j.last_shift["pay"]) == 195000
		and String(j.last_shift["frame"]) == "Sáng" and int(j.last_shift["day_number"]) == 1)
	# Lam them 2 ca: EXP cong don, vi cong don.
	j.work_shift("ban-rong", "Sáng", _stats50())
	j.work_shift("ban-rong", "Sáng", _stats50())
	_check("Jobs: 3 ca -> vi 585000, EXP 30, con 11 ca",
		j.gold == 585000 and j.exp_total == 30 and j.shifts_left("ban-rong") == 11)
	# Quota tuan: lam toi 14 ca thi ca 15 bi chan.
	for i in range(11):
		j.work_shift("ban-rong", "Sáng", _stats50())
	_check("Jobs: 14 ca -> het quota (con 0, khong lam duoc)",
		j.shifts_done("ban-rong") == 14 and j.shifts_left("ban-rong") == 0
		and not j.can_take_shift("ban-rong"))
	var blocked := j.work_shift("ban-rong", "Sáng", _stats50())
	_check("Jobs: ca 15 bi chan het-quota, vi/EXP khong doi",
		not bool(blocked["ok"]) and String(blocked["reason"]) == "het-quota"
		and j.gold == 14 * 195000 and j.exp_total == 140)
	# Nghe sai -> khong-co-nghe.
	var bad := j.work_shift("khong-co")
	_check("Jobs: work_shift nghe sai -> khong-co-nghe",
		not bool(bad["ok"]) and String(bad["reason"]) == "khong-co-nghe")
	# Quota rieng tung nghe: shipper van con 14 ca.
	_check("Jobs: quota rieng tung nghe (shipper con 14)",
		j.shifts_left("shipper") == 14 and j.can_take_shift("shipper"))
	# pay_per_shift_current: chi so + khung hien tai + cung–cau tuan.
	var j2 := PxbJobs.new()
	j2.stats = PxbStats.with_values(50, 50, 50)
	j2.time = PxbTime.new()
	j2.time.debug_set_elapsed(15.0) # Chieu: khung tot cua ban rong
	_check("Jobs: pay_current ban rong = 150000*1.25*1.3 = 243750",
		j2.pay_per_shift_current("ban-rong") == 243750)
	_check("Jobs: pay_current nghe sai tra -1", j2.pay_per_shift_current("khong-co") == -1)
	j2.stats.free()
	j2.time.free()
	j2.free()
	j.free()


func _test_demand() -> void:
	# Vong xoay cung–cau theo tuan (PROVISIONAL, xem pxb_jobs.gd).
	_check("Jobs: roll tuan 1 = thieu ban rong / thuong shipper / hoa quan",
		PxbJobs.roll_supply_demand(1) == {"ban-rong": "thieu-nguoi", "shipper": "binh-thuong", "nhan-vien-quan": "bao-hoa"})
	_check("Jobs: roll tuan 2 = thieu shipper / thuong quan / hoa ban rong",
		PxbJobs.roll_supply_demand(2) == {"ban-rong": "bao-hoa", "shipper": "thieu-nguoi", "nhan-vien-quan": "binh-thuong"})
	_check("Jobs: roll tuan 3 = thieu quan / thuong ban rong / hoa shipper",
		PxbJobs.roll_supply_demand(3) == {"ban-rong": "binh-thuong", "shipper": "bao-hoa", "nhan-vien-quan": "thieu-nguoi"})
	_check("Jobs: roll tuan 4 lap lai tuan 1", PxbJobs.roll_supply_demand(4) == PxbJobs.roll_supply_demand(1))
	# set_demand ghi de + kiem tra sai.
	var j := PxbJobs.new()
	_check("Jobs: set_demand hop le -> true, get_demand doi theo",
		j.set_demand("shipper", "bao-hoa") and j.get_demand("shipper") == "bao-hoa")
	_check("Jobs: set_demand kind sai -> false", not j.set_demand("shipper", "khong-co"))
	_check("Jobs: set_demand nghe sai -> false", not j.set_demand("khong-co", "thieu-nguoi"))
	# Reset tuan: ca + luot thi reset, chung chi GIU NGUYEN, cung–cau quay lai.
	j.work_shift("ban-rong", "Sáng", _stats50())
	j.certs["ban-rong"] = true
	j.reset_week(2)
	_check("Jobs: reset tuan 2 -> ca 0, con 14 ca, shipper thieu nguoi",
		j.shifts_done("ban-rong") == 0 and j.shifts_left("ban-rong") == 14
		and j.get_demand("shipper") == "thieu-nguoi" and j.week_number == 2)
	_check("Jobs: reset tuan GIU chung chi da dau", j.has_cert("ban-rong"))
	# Sang tuan tu dong khi doi ngay: ngay 8 = tuan 2.
	var j2 := PxbJobs.new()
	j2.work_shift("shipper", "Tối", _stats50())
	j2.set_day_number(8)
	_check("Jobs: ngay 8 -> tuan 2, ca tuan cu reset ve 0",
		j2.current_week_number() == 2 and j2.shifts_done("shipper") == 0
		and j2.get_demand("shipper") == "thieu-nguoi")
	_check("Jobs: current_week_number ngay 1/7/8 = 1/1/2",
		j2.current_week_number() == 2)
	var j3 := PxbJobs.new()
	j3.set_day_number(7)
	var w7 := j3.current_week_number()
	j3.set_day_number(1)
	var w1 := j3.current_week_number()
	_check("Jobs: ngay 7 tuan 1, ngay 1 tuan 1", w7 == 1 and w1 == 1)
	j3.free()
	j.free()
	j2.free()


func _test_exam() -> void:
	var j := PxbJobs.new()
	_check("Jobs: phi thi 5-20 trieu", j.exam_fee_range() == {"min": 5000000, "max": 20000000})
	_check("Jobs: 3 nghe slice khong can chung chi (cert_id_for = '')",
		j.cert_id_for("ban-rong") == "" and j.cert_id_for("shipper") == "")
	_check("Jobs: chua thi -> has_cert false, con 1 luot",
		not j.has_cert("ban-rong") and j.exam_attempts_left("ban-rong") == 1)
	# Phi ngoai khoang bi chan.
	_check("Jobs: phi 4tr -> phi-thi-ngoai-khoang",
		String(j.take_exam("ban-rong", 4000000, true)["reason"]) == "phi-thi-ngoai-khoang")
	_check("Jobs: phi 21tr -> phi-thi-ngoai-khoang",
		String(j.take_exam("ban-rong", 21000000, true)["reason"]) == "phi-thi-ngoai-khoang")
	# Khong du tien bi chan.
	_check("Jobs: vi 0 thi 5tr -> khong-du-tien",
		String(j.take_exam("ban-rong", 5000000, true)["reason"]) == "khong-du-tien")
	# Nap vi roi thi truot: mat phi, khong co chung chi, het luot.
	j.gold = 20000000
	var fail := j.take_exam("ban-rong", 5000000, false)
	_check("Jobs: thi truot -> ok, mat 5tr, khong chung chi, het luot",
		bool(fail["ok"]) and not bool(fail["passed"]) and int(fail["fee_paid"]) == 5000000
		and j.gold == 15000000 and not j.has_cert("ban-rong") and j.exam_attempts_left("ban-rong") == 0)
	_check("Jobs: het luot -> het-luot-thi",
		String(j.take_exam("ban-rong", 5000000, true)["reason"]) == "het-luot-thi")
	# Mua them 1 luot (toi da 1/tuan), thi dau -> co chung chi.
	_check("Jobs: grant_extra_attempt lan 1 -> true, con 1 luot",
		j.grant_extra_attempt("ban-rong") and j.exam_attempts_left("ban-rong") == 1)
	_check("Jobs: grant_extra_attempt lan 2 -> false (toi da 1/tuan)",
		not j.grant_extra_attempt("ban-rong"))
	var passed := j.take_exam("ban-rong", 5000000, true)
	_check("Jobs: thi dau -> ok, co chung chi, vi con 10tr",
		bool(passed["ok"]) and bool(passed["passed"]) and j.has_cert("ban-rong") and j.gold == 10000000)
	# Nghe sai -> khong-co-nghe.
	_check("Jobs: take_exam nghe sai -> khong-co-nghe",
		String(j.take_exam("khong-co", 5000000, true)["reason"]) == "khong-co-nghe")
	j.free()


func _test_save() -> void:
	var j := PxbJobs.new()
	j.work_shift("shipper", "Tối", _stats50())
	j.gold = 1234567
	j.exp_total = 42
	j.certs["shipper"] = true
	var d := j.data()
	var back := PxbJobs.from_data(d)
	_check("Jobs: from_data khoi phuc vi/EXP/ca/chung chi/tuan",
		back.gold == 1234567 and back.exp_total == 42
		and back.shifts_done("shipper") == 1 and back.has_cert("shipper")
		and back.week_number == j.week_number and back.day_number == j.day_number)
	var empty := PxbJobs.from_data({})
	_check("Jobs: from_data {} -> tuan 1, vi 0", empty.week_number == 1 and empty.gold == 0)
	empty.free()
	j.free()
	back.free()
