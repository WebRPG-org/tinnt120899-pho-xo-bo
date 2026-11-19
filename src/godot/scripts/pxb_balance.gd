class_name PxbBalance
extends Node
## Phố Xô Bồ — PXB_Balance (Godot G2, bước 1/17).
## Port trung thực PXB_Balance.js / GameBalance.cs (src/client):
## hằng số DUY NHẤT cho số đã chốt. File khác KHÔNG hardcode số — lấy từ đây.
## Số ghi PROVISIONAL là số ví dụ / cấu hình slice chưa chốt — đổi thì sửa
## ở đây + file C#/JS gốc + docs cùng lúc (xem docs/architecture-nadia.md §2).
## Đăng ký autoload tên PXB_Balance trong project.godot (tên khác class_name
## để không đụng global class). Dùng qua PxbBalance.HANG (class) hoặc
## PXB_Balance (autoload instance) — cùng một script.

# Thời gian kiểu C (GDD Mục 1, đã chốt): 1 ngày game = 30 phút thật, 3 khung.
const GAME_DAY_MINUTES := 30
const FRAMES_PER_DAY := 3
const FRAME_MINUTES := 10
const FRAMES := ["Sáng", "Chiều", "Tối"]

# Học vấn 5 bậc (GDD Mục 5, đã chốt — khớp GameBalance.Degrees).
# name, fee_vnd, days, tri (Trí yêu cầu), exp, fame, mentor.
const DEGREES := [
	{"name": "THPT", "fee_vnd": 0, "days": 30, "tri": 20, "exp": 0, "fame": 0, "mentor": false},
	{"name": "Cao đẳng", "fee_vnd": 20000000, "days": 60, "tri": 40, "exp": 500, "fame": 0, "mentor": false},
	{"name": "Cử nhân", "fee_vnd": 80000000, "days": 120, "tri": 60, "exp": 1500, "fame": 200, "mentor": false},
	{"name": "Thạc sĩ", "fee_vnd": 200000000, "days": 180, "tri": 75, "exp": 3000, "fame": 500, "mentor": false},
	{"name": "Tiến sĩ / Học giả", "fee_vnd": 500000000, "days": 240, "tri": 90, "exp": 6000, "fame": 1500, "mentor": true},
]

# Khóa ngắn hạn (GDD Mục 5, đã chốt).
const SHORT_COURSE_MIN_DAYS := 3
const SHORT_COURSE_MAX_DAYS := 7
const SHORT_COURSE_MIN_FEE_VND := 2000000
const SHORT_COURSE_MAX_FEE_VND := 10000000
const SHORT_COURSE_STAT_GAIN := 10

# Cung – cầu tuần (GDD Mục 5/6, đã chốt).
const SHORTAGE_SALARY_BONUS_PERCENT := 30
const SATURATED_SALARY_CUT_PERCENT := 15
const SCHOOL_SEATS_PER_COURSE_MIN := 20
const SCHOOL_SEATS_PER_COURSE_MAX := 30

# Giấy phép + thi chứng chỉ (GDD Mục 6, đã chốt).
const FOOD_STALL_LICENSE_VND := 50000000
const CLINIC_LICENSE_VND := 200000000
const EXAM_FEE_MIN_VND := 5000000
const EXAM_FEE_MAX_VND := 20000000

# Công ty = guild (GDD Mục 6, đã chốt).
const COMPANY_CAPITAL_VND := 500000000
const COMPANY_INACTIVE_WEEKS_TO_REMOVE := 2

# Xã hội (GDD Mục 8, đã chốt).
const NEGLECT_DAYS_TO_DROP_CLOSENESS := 7
const SUPPORTED_EXP_BONUS_PERCENT := 20
const SOLO_SLOWER_PERCENT_MIN := 30
const SOLO_SLOWER_PERCENT_MAX := 50

# Tài chính (GDD Mục 7, đã chốt).
const BANK_INTEREST_PER_GAME_MONTH := 0.005
const AUCTION_FEE_PERCENT := 5
const BIG_PURCHASE_FAME_BONUS := 50

# Thang nhà 6 bậc (GDD Mục 7, đã chốt) — tiền thuê tháng cho phòng trọ,
# giá mua cho các bậc còn lại.
const ROOM_RENT_PER_MONTH_VND := 2000000
const MINI_APARTMENT_VND := 800000000
const SMALL_TOWNHOUSE_VND := 3000000000
const LARGE_TOWNHOUSE_VND := 8000000000
const VILLA_VND := 25000000000
const PENTHOUSE_ISLAND_VND := 100000000000

# Nhánh rank Chương 5 (GDD Mục 9, đã chốt).
const DIRECTOR_ASSETS_VND := 10000000000
const SUPER_RICH_ASSETS_VND := 100000000000
const FAMILY_ENDING_AN_YEN := 80

# Chỉ số — PROVISIONAL (Stats.cs): GDD chỉ chốt "có trần tổng", chưa chốt số.
# TOTAL_STAT_CAP 300 + STAT_MAX 100 + ngưỡng cân bằng An Yên ±10 là số ví dụ.
const TOTAL_STAT_CAP := 300 # PROVISIONAL — cần chủ chốt
const STAT_MAX := 100 # PROVISIONAL — cần chủ chốt cùng TOTAL_STAT_CAP
const AN_YEN_BALANCE_TOLERANCE := 10 # PROVISIONAL — cần chủ chốt cùng TOTAL_STAT_CAP

# 3 nghề slice (Jobs.cs — PROVISIONAL: lương ca + quota là số cấu hình
# slice, chưa chốt GDD). Khung tốt +25%.
# id, name, main_stat (the/tri/tam), good_frame, base_pay_vnd, weekly_quota.
const GOOD_FRAME_BONUS_PERCENT := 25
const JOBS := [
	{"id": "ban-rong", "name": "Bán rong", "main_stat": "the", "good_frame": "Chiều", "base_pay_vnd": 150000, "weekly_quota": 14},
	{"id": "shipper", "name": "Shipper", "main_stat": "the", "good_frame": "Tối", "base_pay_vnd": 180000, "weekly_quota": 14},
	{"id": "nhan-vien-quan", "name": "Nhân viên quán", "main_stat": "tam", "good_frame": "Sáng", "base_pay_vnd": 150000, "weekly_quota": 14},
]

# Công thức chế tạo slice (Crafting.cs — PROVISIONAL, chưa chốt GDD).
const RECIPES := [
	{"id": "che-xe-day", "name": "Xe Đẩy Hàng (bậc 1)", "needs": {"khung-sat": 1, "banh-xe": 2, "van-go": 2}, "result": "tool:XeDay:1", "unlock": "Cô Tư dạy sau khi làm xong quest đầu tiên ở Xóm Trọ Cũ."},
	{"id": "che-den-soi", "name": "Đèn Soi (bậc 1)", "needs": {"sat-vun": 2, "chai-nhua": 2}, "result": "tool:DenSoi:1", "unlock": "Anh Hải dạy ở Phố Đi Bộ – Chợ Đêm."},
	{"id": "che-qua-tang", "name": "Quà Tặng Thủ Công", "needs": {"la-chuoi": 2, "vai-vun": 1}, "result": "item:qua-tang", "unlock": "Học từ bạn thân NPC — tặng NPC để tăng thân thiết, mở quest (GDD Mục 8/9)."},
]

# Bảng vật phẩm slice (Inventory.cs ItemCatalog — PROVISIONAL, chưa chốt
# GDD: giá + buff là số ví dụ của slice). Vật phẩm tiêu hao chỉ cho
# BUFF TẠM trong 1 khung, KHÔNG đổi chỉ số vĩnh viễn.
# id, name, price_vnd, stackable, effect_stat ("the"/"tri"/"tam", "" =
# không buff), effect_amount, effect_frame ("Sáng"/"Chiều"/"Tối", "" =
# không buff), unlock_note.
const ITEMS := [
	{"id": "com-tam", "name": "Cơm tấm", "price_vnd": 35000, "stackable": true, "effect_stat": "the", "effect_amount": 5, "effect_frame": "Chiều", "unlock_note": ""},
	{"id": "ca-phe", "name": "Cà phê", "price_vnd": 25000, "stackable": true, "effect_stat": "tri", "effect_amount": 5, "effect_frame": "Sáng", "unlock_note": ""},
	{"id": "sach", "name": "Sách", "price_vnd": 80000, "stackable": true, "effect_stat": "tri", "effect_amount": 5, "effect_frame": "Tối", "unlock_note": ""},
	{"id": "ao-mua", "name": "Áo mưa", "price_vnd": 120000, "stackable": false, "effect_stat": "", "effect_amount": 0, "effect_frame": "", "unlock_note": "Làm được ca mưa, không bị ướt"},
]


static func degree(index: int) -> Dictionary:
	if index < 0 or index >= DEGREES.size():
		return {}
	return DEGREES[index]


static func job_by_id(job_id: String) -> Dictionary:
	for j in JOBS:
		if String(j["id"]) == job_id:
			return j
	return {}


static func recipe_by_id(recipe_id: String) -> Dictionary:
	for r in RECIPES:
		if String(r["id"]) == recipe_id:
			return r
	return {}


static func item_by_id(item_id: String) -> Dictionary:
	for it in ITEMS:
		if String(it["id"]) == item_id:
			return it
	return {}
