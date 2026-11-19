class_name PxbJobs
extends Node
## Phố Xô Bồ — PXB_Jobs (Godot G2, bước 2/17).
## Port trung thực PXB_Jobs.js / Jobs.cs (src/client/Assets/Scripts/Jobs.cs).
##
## - 3 nghề slice: Bán rong (Thể, khung tốt Chiều, 150.000/ca), Shipper
##   (Thể, khung tốt Tối, 180.000/ca), Nhân viên quán (Tâm, khung tốt
##   Sáng, 150.000/ca). Quota mỗi nghề 14 ca/tuần game.
## - Lương 1 ca = lương ca cơ bản × hệ số chỉ số chính × hệ số khung
##   giờ × hệ số cung–cầu, làm tròn xuống. Hệ số chỉ số chính:
##   chỉ số 50 = 1.0; mỗi 10 điểm trên 50 cộng 10% lương, mỗi 10 điểm
##   dưới 50 trừ 10% (tối thiểu 50% lương ca) — đúng Jobs.cs:
##   max(0.5, 1.0 + (chỉ số − 50) × 0.01).
## - Khung giờ tốt của nghề: +25% (PxbBalance.GOOD_FRAME_BONUS_PERCENT).
## - Cung–cầu tuần (đã chốt): nghề thiếu người +30%, nghề bão hòa −15%.
## - Thi chứng chỉ (GDD Mục 6, đã chốt): phí thi 5–20 triệu tiền game,
##   trượt mất phí, chờ tuần sau; nạp chỉ mua thêm 1 lượt thi/tuần,
##   không mua đậu.
##
## SỐ LIỆU LẤY TỪ PxbBalance.JOBS / GOOD_FRAME_BONUS_PERCENT /
## SHORTAGE_SALARY_BONUS_PERCENT / SATURATED_SALARY_CUT_PERCENT /
## EXAM_FEE_MIN_VND / EXAM_FEE_MAX_VND — file này KHÔNG hardcode lại
## số tiền/khung. Lương ca + quota là số cấu hình slice PROVISIONAL
## (Jobs.cs), chưa chốt GDD.
##
## KHÁC JS/C# — GHI RÕ, KHÔNG GIẢ VỜ ĐÃ CHỐT:
## - EXP MỖI CA: JS và C# đều KHÔNG định nghĩa EXP cho 1 ca làm việc
##   (chỉ có EXP của bậc học trong GameBalance.Degrees). EXP_PER_SHIFT
##   = 10 là số PROVISIONAL do bước port này đặt tạm để work_shift()
##   trả về exp + cộng vào exp_total cho test được — CHƯA CHỐT, đổi
##   khi GDD chốt EXP/ca. Test chỉ kiểm tra cơ chế cộng dồn, không
##   coi 10 là số chốt.
## - VÍ TIỀN: Godot chưa có PlayerProgress / $gameParty nên ví (gold)
##   + EXP tạm giữ ngay trong PxbJobs (gold / exp_total), work_shift()
##   cộng thật và trả paid = true. Khi port PlayerProgress (G2 bước
##   sau), ví chuyển sang đó — hàm work_shift/take_exam giữ nguyên
##   chữ ký, chỉ đổi chỗ cộng/trừ tiền.
## - GIỚI HẠN CA: JS/C# chỉ có QUOTA TUẦN (14 ca/tuần/nghề), KHÔNG có
##   giới hạn ca/ngày. File này port đúng quota tuần; không tự bịa
##   thêm cap ca/ngày.
## - CUNG–CẦU TUẦN: JS quay theo vòng xoay theo số tuần (tuần N thiếu
##   nghề [(N−1) % 3], bão hòa nghề [(N+1) % 3]) — PROVISIONAL, C#
##   không có logic chọn nghề; GDD chỉ chốt "1 thiếu (+30%), 1 bão
##   hòa (−15%)". Server/event có thể ghi đè bằng set_demand().
## - TUẦN GAME: 1 tuần = 7 ngày game, ngày game 1 = Thứ Hai — khớp
##   quy ước của PxbTime, PROVISIONAL (GDD chưa chốt "tuần game").
## - CHỨNG CHỈ: 3 nghề slice KHÔNG yêu cầu chứng chỉ (Jobs.cs không
##   định nghĩa) nên cert_id_for() trả "" — PROVISIONAL, GDD chưa nêu
##   tên nghề nào cần thi.
## - LỖI: GDScript không có exception — pay_per_shift() /
##   pay_per_shift_current() trả -1 + push_error khi job_id sai (JS/C#
##   throw), các hàm khác trả false / dict {ok:false, reason:...}.
##
## Dùng: gán jobs.stats = PXB_Stats (autoload) và jobs.time = PXB_Time
## (autoload) để work_shift() tự lấy chỉ số + khung hiện tại; không gán
## thì mặc định chỉ số 50 (hệ số 1.0) và khung thường. data() /
## from_data() là dữ liệu thuần để lưu (save G2 bước sau).

const DEMAND_NORMAL := "binh-thuong"
const DEMAND_SHORTAGE := "thieu-nguoi"
const DEMAND_SATURATED := "bao-hoa"
const JOB_IDS := ["ban-rong", "shipper", "nhan-vien-quan"]

# EXP mỗi ca — PROVISIONAL, xem ghi chú đầu file (JS/C# không định nghĩa).
const EXP_PER_SHIFT := 10

var week_number: int = 1
var day_number: int = 1
var shifts: Dictionary = {} # ca đã làm trong tuần, theo job_id
var supply_demand: Dictionary = {} # cung–cầu tuần, theo job_id
var certs: Dictionary = {} # chứng chỉ đã đậu, theo job_id -> true
var exam_attempts: Dictionary = {} # lượt thi đã dùng trong tuần
var extra_attempts: Dictionary = {} # lượt thi mua thêm trong tuần (tối đa 1)
var last_shift: Dictionary = {} # {job_id, frame, pay, day_number} — ca gần nhất
var gold: int = 0 # ví người chơi (tạm giữ ở đây tới khi có PlayerProgress)
var exp_total: int = 0 # EXP tích lũy từ làm ca (tạm giữ ở đây)
var stats: PxbStats = null # chỉ số hiện tại; null = mặc định 50
var time: PxbTime = null # đồng hồ game; null = khung thường


# --- Định nghĩa nghề (đọc từ PxbBalance, không hardcode) ---

static func job_list() -> Array:
	return PxbBalance.JOBS.duplicate(true)


static func get_job(job_id: String) -> Dictionary:
	return PxbBalance.job_by_id(job_id)


# Hệ số chỉ số chính — đúng Jobs.cs: max(0.5, 1.0 + (chỉ số − 50) × 0.01).
# Chỉ số 50 -> 1.0; 100 -> 1.5; 0 -> 0.5 (sàn).
static func stat_factor(main_value: int) -> float:
	return maxf(0.5, 1.0 + (float(main_value) - 50.0) * 0.01)


# Đọc chỉ số chính từ PxbStats hoặc Dictionary thuần {the, tri, tam}.
# Không có stats thì trả 50 (hệ số 1.0) — như PXB_Jobs.js.
static func main_stat_value(def: Dictionary, p_stats) -> int:
	if p_stats == null:
		return 50
	var key := String(def.get("main_stat", "the"))
	if p_stats is PxbStats:
		return p_stats.get_stat(key)
	if p_stats is Dictionary:
		return int(p_stats.get(key, 50))
	return 50


# Tính lương 1 ca (đồng trong game), làm tròn xuống — port trung thực
# Jobs.PayPerShift. frame_name "" = khung thường (không cộng khung tốt).
# demand mặc định bình thường. job_id sai -> -1 + push_error.
static func pay_per_shift(job_id: String, p_stats = null, frame_name: String = "", demand: String = DEMAND_NORMAL) -> int:
	var def := get_job(job_id)
	if def.is_empty():
		push_error("Không có nghề slice: " + job_id)
		return -1
	var pay := float(int(def["base_pay_vnd"])) * stat_factor(main_stat_value(def, p_stats))
	if frame_name != "" and frame_name == String(def["good_frame"]):
		pay *= 1.0 + float(PxbBalance.GOOD_FRAME_BONUS_PERCENT) / 100.0
	if demand == DEMAND_SHORTAGE:
		pay *= 1.0 + float(PxbBalance.SHORTAGE_SALARY_BONUS_PERCENT) / 100.0
	elif demand == DEMAND_SATURATED:
		pay *= 1.0 - float(PxbBalance.SATURATED_SALARY_CUT_PERCENT) / 100.0
	return int(pay)


# --- Cung–cầu tuần ---

# PROVISIONAL — vòng xoay theo số tuần (xem ghi chú đầu file):
# tuần N thiếu nghề [(N−1) % 3], bão hòa nghề [(N+1) % 3], còn lại bình thường.
static func roll_supply_demand(p_week_number: int) -> Dictionary:
	var n := ((p_week_number - 1) % 3 + 3) % 3
	var map := {}
	map[JOB_IDS[n]] = DEMAND_SHORTAGE
	map[JOB_IDS[(n + 1) % 3]] = DEMAND_NORMAL
	map[JOB_IDS[(n + 2) % 3]] = DEMAND_SATURATED
	return map


func get_demand(job_id: String) -> String:
	ensure_week()
	return String(supply_demand.get(job_id, DEMAND_NORMAL))


# Ghi đè cung–cầu tuần cho 1 nghề (event/server gọi). kind sai hoặc
# job_id sai thì trả false.
func set_demand(job_id: String, kind: String) -> bool:
	if get_job(job_id).is_empty():
		return false
	if kind != DEMAND_NORMAL and kind != DEMAND_SHORTAGE and kind != DEMAND_SATURATED:
		return false
	ensure_week()
	supply_demand[job_id] = kind
	return true


# --- Tuần game ---

# Số tuần game hiện tại. PROVISIONAL: 1 tuần = 7 ngày game, ngày 1 = Thứ Hai.
func current_week_number() -> int:
	return (maxi(day_number, 1) - 1) / 7 + 1


# Đặt ngày game hiện tại (game / test gọi khi sang ngày mới).
func set_day_number(n: int) -> void:
	day_number = maxi(n, 1)
	ensure_week()


# Sang tuần game mới: reset ca đã làm + lượt thi + lượt mua thêm,
# quay lại cung–cầu tuần mới. Chứng chỉ đã đậu GIỮ NGUYÊN.
func reset_week(p_week_number: int) -> bool:
	week_number = maxi(p_week_number, 1)
	# Đồng bộ ngày game về ngày đầu tuần được reset tới — chỉ khi tuần
	# yêu cầu khác tuần suy ra từ day_number hiện tại. Nếu không,
	# ensure_week() sẽ reset ngược lại ngay sau đó (tuần trong state
	# lệch với tuần suy ra từ ngày). Khi reset_week() được gọi từ
	# ensure_week() với đúng tuần hiện tại thì day_number giữ nguyên
	# (không mất vị trí ngày trong tuần).
	if current_week_number() != week_number:
		day_number = (week_number - 1) * 7 + 1
	shifts = {}
	exam_attempts = {}
	extra_attempts = {}
	supply_demand = roll_supply_demand(p_week_number)
	return true


# Tự reset khi tuần game đã đổi (gọi đầu mỗi hàm đọc/ghi state).
func ensure_week() -> bool:
	var week := current_week_number()
	if week_number != week:
		reset_week(week)
	# Tuần đầu chưa quay cung–cầu lần nào thì quay ngay.
	if supply_demand.is_empty():
		supply_demand = roll_supply_demand(week_number)
	return true


# --- Quota tuần (port trung thực Jobs.WeeklyQuotaTracker) ---

func shifts_done(job_id: String) -> int:
	ensure_week()
	return int(shifts.get(job_id, 0))


func shifts_left(job_id: String) -> int:
	var def := get_job(job_id)
	if def.is_empty():
		return 0
	return int(def["weekly_quota"]) - shifts_done(job_id)


func can_take_shift(job_id: String) -> bool:
	return shifts_left(job_id) > 0


# --- Làm ca ---

# Khung hiện tại qua PxbTime khi có; chưa gán thì "" = khung thường.
func current_frame_name() -> String:
	if time != null:
		return time.current_frame_name()
	return ""


# Làm 1 ca nghề job_id. frame_name "" = lấy khung hiện tại (qua time
# khi có); p_stats null = dùng stats đã gán, chưa gán thì chỉ số 50.
# Trả:
#   {ok:true, job_id, frame, demand, pay, exp, paid:true, shifts_left}
#   {ok:false, reason:"het-quota"} — hết quota tuần
#   {ok:false, reason:"khong-co-nghe"} — job_id sai
# paid luôn true: ví giữ trong PxbJobs nên tiền cộng thật ngay (khác JS
# khi chưa có core MV thì paid = false và event phải tự cộng).
func work_shift(job_id: String, frame_name: String = "", p_stats = null) -> Dictionary:
	var def := get_job(job_id)
	if def.is_empty():
		return {"ok": false, "reason": "khong-co-nghe"}
	ensure_week()
	if not can_take_shift(job_id):
		return {"ok": false, "reason": "het-quota"}
	var frame := frame_name if frame_name != "" else current_frame_name()
	var demand := get_demand(job_id)
	var s = p_stats if p_stats != null else stats
	var pay := pay_per_shift(job_id, s, frame, demand)
	shifts[job_id] = shifts_done(job_id) + 1
	last_shift = {"job_id": job_id, "frame": frame, "pay": pay, "day_number": day_number}
	gold += pay
	exp_total += EXP_PER_SHIFT
	return {"ok": true, "job_id": job_id, "frame": frame, "demand": demand,
		"pay": pay, "exp": EXP_PER_SHIFT, "paid": true, "shifts_left": shifts_left(job_id)}


# Lương ca hiện tại của nghề (chỉ tính, không làm ca, không trừ quota):
# chỉ số hiện tại + khung hiện tại + cung–cầu tuần. job_id sai -> -1.
func pay_per_shift_current(job_id: String) -> int:
	if get_job(job_id).is_empty():
		push_error("Không có nghề slice: " + job_id)
		return -1
	ensure_week()
	return pay_per_shift(job_id, stats, current_frame_name(), get_demand(job_id))


# --- Thi chứng chỉ (GDD Mục 6) ---

# Nghề slice KHÔNG yêu cầu chứng chỉ (Jobs.cs không định nghĩa chứng
# chỉ cho nghề nào). PROVISIONAL — GDD chưa nêu tên nghề nào cần thi;
# khi chốt thì trả về id chứng chỉ, vd "chung-chi-bep". "" = không cần.
func cert_id_for(job_id: String) -> String:
	if get_job(job_id).is_empty():
		return ""
	return ""


func has_cert(job_id: String) -> bool:
	ensure_week()
	return bool(certs.get(job_id, false))


# Số lượt thi còn lại trong tuần: mặc định 1 lượt/tuần + tối đa 1 lượt
# mua thêm (GDD: "nạp chỉ mua thêm 1 lượt thi/tuần, không mua đậu").
func exam_attempts_left(job_id: String) -> int:
	ensure_week()
	return 1 + int(extra_attempts.get(job_id, 0)) - int(exam_attempts.get(job_id, 0))


# Mua thêm 1 lượt thi trong tuần (nạp). PROVISIONAL — GDD chỉ chốt
# "nạp mua thêm 1 lượt/tuần", chưa chốt giá + luồng thanh toán; hàm
# này chỉ cộng lượt, việc trừ tiền nạp do event/IAP xử lý. Trả false
# nếu tuần này đã mua rồi (tối đa 1 lượt mua thêm/tuần).
func grant_extra_attempt(job_id: String) -> bool:
	if get_job(job_id).is_empty():
		return false
	ensure_week()
	if int(extra_attempts.get(job_id, 0)) >= 1:
		return false
	extra_attempts[job_id] = int(extra_attempts.get(job_id, 0)) + 1
	return true


# Khoảng phí thi đã chốt (đồng trong game) — event lấy để hiển thị.
func exam_fee_range() -> Dictionary:
	return {"min": PxbBalance.EXAM_FEE_MIN_VND, "max": PxbBalance.EXAM_FEE_MAX_VND}


# Thi chứng chỉ 1 lần. fee_vnd: phí event thu (phải trong khoảng
# 5–20 triệu đã chốt). passed: kết quả do EVENT quyết — PxbJobs KHÔNG
# tự chốt công thức đậu/trượt vì GDD chưa chốt; đậu thì cấp chứng chỉ,
# trượt thì mất phí và phải chờ tuần sau (trừ khi đã mua thêm lượt). Trả:
#   {ok:true, passed, fee_paid, charged:true, attempts_left, has_cert}
#   {ok:false, reason:"het-luot-thi"} — hết lượt tuần này
#   {ok:false, reason:"phi-thi-ngoai-khoang"} — phí ngoài 5–20 triệu
#   {ok:false, reason:"khong-du-tien"} — ví không đủ phí
#   {ok:false, reason:"khong-co-nghe"} — job_id sai
func take_exam(job_id: String, fee_vnd: int, passed: bool) -> Dictionary:
	if get_job(job_id).is_empty():
		return {"ok": false, "reason": "khong-co-nghe"}
	ensure_week()
	if fee_vnd < PxbBalance.EXAM_FEE_MIN_VND or fee_vnd > PxbBalance.EXAM_FEE_MAX_VND:
		return {"ok": false, "reason": "phi-thi-ngoai-khoang"}
	if exam_attempts_left(job_id) <= 0:
		return {"ok": false, "reason": "het-luot-thi"}
	if gold < fee_vnd:
		return {"ok": false, "reason": "khong-du-tien"}
	exam_attempts[job_id] = int(exam_attempts.get(job_id, 0)) + 1
	gold -= fee_vnd
	if passed:
		certs[job_id] = true
	return {"ok": true, "passed": passed, "fee_paid": fee_vnd, "charged": true,
		"attempts_left": exam_attempts_left(job_id), "has_cert": has_cert(job_id)}


# --- Dữ liệu thuần để lưu (save G2 bước sau) ---

func data() -> Dictionary:
	return {
		"week_number": week_number, "day_number": day_number,
		"shifts": shifts.duplicate(), "supply_demand": supply_demand.duplicate(),
		"certs": certs.duplicate(), "exam_attempts": exam_attempts.duplicate(),
		"extra_attempts": extra_attempts.duplicate(), "last_shift": last_shift.duplicate(),
		"gold": gold, "exp_total": exp_total,
	}


static func from_data(d: Dictionary) -> PxbJobs:
	var j := PxbJobs.new()
	j.week_number = int(d.get("week_number", 1))
	j.day_number = maxi(int(d.get("day_number", 1)), 1)
	j.shifts = (d.get("shifts", {}) as Dictionary).duplicate()
	j.supply_demand = (d.get("supply_demand", {}) as Dictionary).duplicate()
	j.certs = (d.get("certs", {}) as Dictionary).duplicate()
	j.exam_attempts = (d.get("exam_attempts", {}) as Dictionary).duplicate()
	j.extra_attempts = (d.get("extra_attempts", {}) as Dictionary).duplicate()
	j.last_shift = (d.get("last_shift", {}) as Dictionary).duplicate()
	j.gold = int(d.get("gold", 0))
	j.exp_total = int(d.get("exp_total", 0))
	return j
