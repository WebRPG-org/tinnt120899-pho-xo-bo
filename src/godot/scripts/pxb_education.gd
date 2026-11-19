class_name PxbEducation
extends Node
## Phố Xô Bồ — PXB_Education (Godot G2, bước 4/17).
## Port trung thực PXB_Education.js (src/nadia/www/js/plugins/
## PXB_Education.js) — học vấn GDD Mục 5 + GameBalance.cs (Degrees +
## ShortCourse). Không có file C# riêng cho Education; nguồn số là
## PxbBalance.DEGREES / SHORT_COURSE_* / SCHOOL_SEATS_* (đã chốt).
##
## - 5 bậc học: THPT (0đ, 30 ngày, Trí 20), Cao đẳng (20tr, 60 ngày,
##   Trí 40, EXP 500), Cử nhân (80tr, 120 ngày, Trí 60, EXP 1500,
##   Danh vọng 200), Thạc sĩ (200tr, 180 ngày, Trí 75, EXP 3000,
##   Danh vọng 500), Tiến sĩ / Học giả (500tr, 240 ngày, Trí 90,
##   EXP 6000, Danh vọng 1500, CẦN mentor).
## - Khóa ngắn hạn: 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ
##   (ky/dung/sang/an-yen), mở nghề phụ (event mở nghề sau tốt nghiệp).
## - Trường nhận 20–30 học viên/khóa, ưu tiên thứ tự đăng ký + Trí +
##   Danh vọng; học bổng cho người nghèo mà Trí cao (GDD Mục 5).
## - Tiến độ theo ngày game: đăng ký ngày N, học D ngày thì
##   end_day = N + D, tốt nghiệp khi số ngày game >= end_day. Event
##   gọi check_graduation() + check_short_course_graduation() mỗi
##   ngày game mới.
##
## KHÁC JS — GHI RÕ, KHÔNG GIẢ VỜ ĐÃ CHỐT:
## - Tiền game: JS trừ học phí khỏi $gameParty (loseGold) khi có core
##   MV. Godot chưa có $gameParty / PlayerProgress nên enroll() /
##   enroll_short_course() KHÔNG tự trừ tiền — kết quả trả charged =
##   false và fee_paid để event/caller tự trừ; kiểm tra tiền dùng
##   tham số gold truyền vào (gold = -1 nghĩa là bỏ qua kiểm tra tiền,
##   như JS khi chưa có core).
## - Tốt nghiệp cộng EXP + Danh vọng vào pending_exp / pending_fame
##   để EVENT áp dụng — vì chưa có hệ EXP/Danh vọng chung trong
##   Godot nên KHÔNG tự cộng vào đâu cả. Khóa ngắn hạn cũng vậy: +10
##   ghi vào pending_stat_gain, event áp qua PxbStats.
## - PROVISIONAL (xem @help của JS): học phí trả 1 lần lúc đăng ký;
##   đã có bằng này hoặc bằng CAO HƠN thì không học lại; học bổng Trí
##   >= 60 và tiền game < 20.000.000 chỉ để xét (không tự miễn phí);
##   plugin KHÔNG tự chặn hết ghế (chỉ trả số ghế + register_order để
##   event ưu tiên); được học song song 1 bằng chính + 1 khóa ngắn
##   hạn cùng lúc (2 slot riêng enrolled / short_course).
## - GDScript không có exception — can_enroll()/enroll() trả dict
##   {ok, reason} thay vì throw như JS; enrolled/short_course rỗng
##   là {} thay vì null.
##
## Dùng: education là tiến độ học hiện tại của người chơi. day_number
## là ngày game hiện tại (ngày 1 = Thứ Hai, khớp PxbTime); gán trực
## tiếp khi ngày game đổi, hoặc để mặc định 1 trong test. data() /
## from_data() là dữ liệu thuần để lưu (save G2 bước sau).

# 4 chỉ số phụ của PxbStats (chỉ số trộn: ky/dung/sang/an-yen).
const SUB_STATS := ["ky", "dung", "sang", "an-yen"]
# Ngưỡng học bổng PROVISIONAL: Trí >= 60 và tiền game < 20.000.000.
const SCHOLARSHIP_MIN_TRI := 60
const SCHOLARSHIP_MAX_GOLD := 20000000

var degrees_owned: Array = [] # Array[int] — index các bằng đã tốt nghiệp
var enrolled: Dictionary = {} # {degree_index, start_day, end_day, register_order} hoặc {}
var short_course: Dictionary = {} # {sub_stat, days, start_day, end_day, register_order} hoặc {}
var pending_exp: int = 0 # EXP chờ event áp
var pending_fame: int = 0 # Danh vọng chờ event áp
var pending_stat_gain: Dictionary = {} # +chỉ số phụ chờ event áp, vd {"ky": 10}
var last_register_order: int = 0 # số thứ tự đăng ký đã cấp (tăng dần)
var has_mentor: bool = false # có mentor hay chưa (event/NPC cấp)
var day_number: int = 1 # ngày game hiện tại (ngày 1 = Thứ Hai)


# --- Danh sách bậc học (đọc từ PxbBalance, không hardcode) ---

static func degree_list() -> Array:
	return PxbBalance.DEGREES.duplicate(true)


# Lấy bậc học theo index (0–4) hoặc tên ("Cử nhân", "THPT"...).
# Trả {} khi không có.
static func get_degree(index_or_name: Variant) -> Dictionary:
	var idx := degree_index(index_or_name)
	if idx < 0:
		return {}
	return PxbBalance.degree(idx)


# Index của bậc học theo tên hoặc số; -1 khi không có.
static func degree_index(index_or_name: Variant) -> int:
	if typeof(index_or_name) == TYPE_INT:
		var i := int(index_or_name)
		return i if (i >= 0 and i < PxbBalance.DEGREES.size()) else -1
	if typeof(index_or_name) == TYPE_STRING:
		for j in PxbBalance.DEGREES.size():
			if String((PxbBalance.DEGREES[j] as Dictionary)["name"]) == String(index_or_name):
				return j
	return -1


# Đã có bằng này hoặc bằng CAO HƠN chưa. PROVISIONAL: GDD chưa chốt
# có được học nhảy bậc / học lại bằng thấp hơn không — tạm chặn học
# lại bằng đã có hoặc thấp hơn bằng cao nhất đã có.
func has_degree_or_higher(idx: int) -> bool:
	for owned_idx in degrees_owned:
		if int(owned_idx) >= idx:
			return true
	return false


# --- Đăng ký bằng chính ---

# Kiểm tra có đăng ký được bậc idx không. tri: Trí hiện tại;
# has_mentor: -1 = đọc state.has_mentor, 0/1 = ép giá trị; gold: tiền
# game hiện tại, -1 = bỏ qua kiểm tra tiền (chưa có ví). Trả:
#   {ok:true}
#   {ok:false, reason:"khong-co-bang"} — idx sai
#   {ok:false, reason:"da-co-bang"} — đã có bằng này / bằng cao hơn
#   {ok:false, reason:"dang-hoc"} — đang học 1 bằng khác
#   {ok:false, reason:"chua-du-tri"} — Trí dưới mức yêu cầu
#   {ok:false, reason:"can-mentor"} — bậc này cần mentor
#   {ok:false, reason:"khong-du-tien"} — tiền game không đủ học phí
func can_enroll(idx: Variant, tri: int, has_mentor: int = -1, gold: int = -1) -> Dictionary:
	var i := degree_index(idx)
	if i < 0:
		return {"ok": false, "reason": "khong-co-bang"}
	var def := PxbBalance.degree(i)
	if has_degree_or_higher(i):
		return {"ok": false, "reason": "da-co-bang"}
	if not enrolled.is_empty():
		return {"ok": false, "reason": "dang-hoc"}
	if tri < int(def["tri"]):
		return {"ok": false, "reason": "chua-du-tri"}
	var mentor := self.has_mentor if has_mentor < 0 else bool(has_mentor)
	if bool(def["mentor"]) and not mentor:
		return {"ok": false, "reason": "can-mentor"}
	if gold >= 0 and gold < int(def["fee_vnd"]):
		return {"ok": false, "reason": "khong-du-tien"}
	return {"ok": true, "reason": ""}


# Đăng ký bậc idx. Học phí trả 1 LẦN lúc đăng ký — PROVISIONAL (GDD
# chưa chốt trả trước hay trả góp). Trả:
#   {ok:true, degree, degree_index, start_day, end_day, fee_paid,
#    charged, register_order}
#   {ok:false, reason:"..."} — lý do chặn như can_enroll()
# charged = false khi chưa có ví game (Godot chưa có $gameParty) —
# khi đó event phải tự trừ fee_paid.
func enroll(idx: Variant, tri: int, has_mentor: int = -1, gold: int = -1) -> Dictionary:
	var check := can_enroll(idx, tri, has_mentor, gold)
	if not bool(check["ok"]):
		return check
	var i := degree_index(idx)
	var def := PxbBalance.degree(i)
	last_register_order += 1
	enrolled = {
		"degree_index": i,
		"start_day": day_number,
		"end_day": day_number + int(def["days"]),
		"register_order": last_register_order,
	}
	return {
		"ok": true, "degree": def, "degree_index": i,
		"start_day": day_number, "end_day": int(enrolled["end_day"]),
		"fee_paid": int(def["fee_vnd"]), "charged": false,
		"register_order": last_register_order,
	}


# --- Tiến độ + tốt nghiệp bằng chính ---

# Tiến độ học hiện tại: {enrolled, day_number, days_left}.
# enrolled = {} khi không học bằng nào; days_left = số ngày còn lại
# tới ngày tốt nghiệp (0 khi đã đủ ngày — gọi check_graduation()).
func study_progress() -> Dictionary:
	if enrolled.is_empty():
		return {"enrolled": {}, "day_number": day_number, "days_left": 0}
	var days_left := maxi(int(enrolled["end_day"]) - day_number, 0)
	return {"enrolled": enrolled, "day_number": day_number, "days_left": days_left}


# Kiểm tra tốt nghiệp (event gọi mỗi ngày game mới). Đủ ngày thì: lưu
# bằng vào degrees_owned, cộng EXP + Danh vọng vào pending_exp /
# pending_fame để EVENT áp dụng, xóa enrolled. Trả:
#   {graduated:true, degree, degree_index, exp, fame, pending_exp, pending_fame}
#   {graduated:false, enrolled, days_left} — chưa đủ ngày / không học
func check_graduation() -> Dictionary:
	var prog := study_progress()
	if (prog["enrolled"] as Dictionary).is_empty() or int(prog["days_left"]) > 0:
		return {
			"graduated": false, "enrolled": prog["enrolled"],
			"days_left": int(prog["days_left"]),
		}
	var idx := int((prog["enrolled"] as Dictionary)["degree_index"])
	var def := PxbBalance.degree(idx)
	if idx not in degrees_owned:
		degrees_owned.append(idx)
	pending_exp += int(def["exp"])
	pending_fame += int(def["fame"])
	enrolled = {}
	return {
		"graduated": true, "degree": def, "degree_index": idx,
		"exp": int(def["exp"]), "fame": int(def["fame"]),
		"pending_exp": pending_exp, "pending_fame": pending_fame,
	}


# --- Khóa ngắn hạn ---

# Đăng ký khóa ngắn hạn: +10 một chỉ số phụ, mở nghề phụ (event mở
# nghề sau tốt nghiệp). sub_stat: "ky" | "dung" | "sang" | "an-yen";
# days: 3–7; fee_vnd: 2–10 triệu. gold: tiền game, -1 = bỏ qua kiểm
# tra tiền. Trả:
#   {ok:true, sub_stat, days, start_day, end_day, fee_paid, charged,
#    register_order}
#   {ok:false, reason:"sai-chi-so"} — sub_stat không phải 1 trong 4
#   {ok:false, reason:"sai-so-ngay"} — days ngoài 3–7
#   {ok:false, reason:"phi-ngoai-khoang"} — phí ngoài 2–10 triệu
#   {ok:false, reason:"dang-hoc-khoa-ngan"} — đang học 1 khóa khác
#   {ok:false, reason:"khong-du-tien"} — tiền game không đủ phí
func enroll_short_course(sub_stat: String, days: int, fee_vnd: int, gold: int = -1) -> Dictionary:
	if sub_stat not in SUB_STATS:
		return {"ok": false, "reason": "sai-chi-so"}
	if days < PxbBalance.SHORT_COURSE_MIN_DAYS or days > PxbBalance.SHORT_COURSE_MAX_DAYS:
		return {"ok": false, "reason": "sai-so-ngay"}
	if fee_vnd < PxbBalance.SHORT_COURSE_MIN_FEE_VND or fee_vnd > PxbBalance.SHORT_COURSE_MAX_FEE_VND:
		return {"ok": false, "reason": "phi-ngoai-khoang"}
	if not short_course.is_empty():
		return {"ok": false, "reason": "dang-hoc-khoa-ngan"}
	if gold >= 0 and gold < fee_vnd:
		return {"ok": false, "reason": "khong-du-tien"}
	last_register_order += 1
	short_course = {
		"sub_stat": sub_stat, "days": days,
		"start_day": day_number, "end_day": day_number + days,
		"register_order": last_register_order,
	}
	return {
		"ok": true, "sub_stat": sub_stat, "days": days,
		"start_day": day_number, "end_day": int(short_course["end_day"]),
		"fee_paid": fee_vnd, "charged": false,
		"register_order": last_register_order,
	}


# Tiến độ khóa ngắn hạn: {short_course, day_number, days_left}.
func short_course_progress() -> Dictionary:
	if short_course.is_empty():
		return {"short_course": {}, "day_number": day_number, "days_left": 0}
	var days_left := maxi(int(short_course["end_day"]) - day_number, 0)
	return {"short_course": short_course, "day_number": day_number, "days_left": days_left}


# Tốt nghiệp khóa ngắn hạn (gọi cùng check_graduation() mỗi ngày game
# mới). +10 chỉ số phụ ghi vào pending_stat_gain để EVENT áp qua
# PxbStats. Trả:
#   {graduated:true, sub_stat, gain, pending_stat_gain}
#   {graduated:false, short_course, days_left}
func check_short_course_graduation() -> Dictionary:
	var prog := short_course_progress()
	if (prog["short_course"] as Dictionary).is_empty() or int(prog["days_left"]) > 0:
		return {
			"graduated": false, "short_course": prog["short_course"],
			"days_left": int(prog["days_left"]),
		}
	var sub := String((prog["short_course"] as Dictionary)["sub_stat"])
	var gain := PxbBalance.SHORT_COURSE_STAT_GAIN
	pending_stat_gain[sub] = int(pending_stat_gain.get(sub, 0)) + gain
	short_course = {}
	return {
		"graduated": true, "sub_stat": sub, "gain": gain,
		"pending_stat_gain": pending_stat_gain,
	}


# --- Học bổng ---

# PROVISIONAL: Trí >= 60 và tiền game < 20.000.000 thì đủ điều kiện
# XÉT học bổng. GDD chỉ nói "người nghèo mà Trí cao", chưa chốt ngưỡng.
# Chỉ trả true/false để event quyết — KHÔNG tự miễn học phí. gold = -1
# (chưa có ví + không truyền gold) thì không xét → false.
func scholarship_eligible(tri: int, gold: int = -1) -> bool:
	if gold < 0:
		return false
	return tri >= SCHOLARSHIP_MIN_TRI and gold < SCHOLARSHIP_MAX_GOLD


# --- Số ghế / thứ tự đăng ký ---

# Số ghế mỗi khóa từ PxbBalance: {min:20, max:30}. PROVISIONAL: hệ
# không tự chặn hết ghế — event dùng số này + register_order để ưu tiên.
func seats_per_course() -> Dictionary:
	return {
		"min": PxbBalance.SCHOOL_SEATS_PER_COURSE_MIN,
		"max": PxbBalance.SCHOOL_SEATS_PER_COURSE_MAX,
	}


# Số thứ tự đăng ký đã cấp gần nhất (0 = chưa đăng ký lần nào).
func register_order() -> int:
	return last_register_order


# Ghi nhận có mentor (event/NPC cấp khi người chơi tìm được mentor).
func set_mentor(has: bool) -> bool:
	has_mentor = has
	return true


# --- Dữ liệu thuần để lưu (save G2 bước sau) ---

func data() -> Dictionary:
	return {
		"degrees_owned": degrees_owned.duplicate(),
		"enrolled": enrolled.duplicate(),
		"short_course": short_course.duplicate(),
		"pending_exp": pending_exp,
		"pending_fame": pending_fame,
		"pending_stat_gain": pending_stat_gain.duplicate(),
		"last_register_order": last_register_order,
		"has_mentor": has_mentor,
		"day_number": day_number,
	}


# Khôi phục từ dữ liệu save (bỏ bằng lạ / khóa lạ / chỉ số phụ lạ —
# như JS extractSaveContents điền lại field thiếu).
static func from_data(d: Dictionary) -> PxbEducation:
	var edu := PxbEducation.new()
	edu.day_number = maxi(int(d.get("day_number", 1)), 1)
	for x in d.get("degrees_owned", []):
		var n := int(x)
		if n >= 0 and n < PxbBalance.DEGREES.size() and n not in edu.degrees_owned:
			edu.degrees_owned.append(n)
	var en := d.get("enrolled", {}) as Dictionary
	if not en.is_empty():
		var idx := int(en.get("degree_index", -1))
		if idx >= 0 and idx < PxbBalance.DEGREES.size():
			edu.enrolled = en.duplicate()
	var sc := d.get("short_course", {}) as Dictionary
	if not sc.is_empty():
		var sub := String(sc.get("sub_stat", ""))
		var days := int(sc.get("days", 0))
		if sub in SUB_STATS and days >= PxbBalance.SHORT_COURSE_MIN_DAYS and days <= PxbBalance.SHORT_COURSE_MAX_DAYS:
			edu.short_course = sc.duplicate()
	edu.pending_exp = maxi(int(d.get("pending_exp", 0)), 0)
	edu.pending_fame = maxi(int(d.get("pending_fame", 0)), 0)
	for k in (d.get("pending_stat_gain", {}) as Dictionary):
		if String(k) in SUB_STATS:
			edu.pending_stat_gain[String(k)] = maxi(int((d["pending_stat_gain"] as Dictionary)[k]), 0)
	edu.last_register_order = maxi(int(d.get("last_register_order", 0)), 0)
	edu.has_mentor = bool(d.get("has_mentor", false))
	return edu
