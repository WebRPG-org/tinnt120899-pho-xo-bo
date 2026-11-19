class_name PxbTime
extends Node
## Phố Xô Bồ — PXB_Time (Godot G2, bước 3/17).
## Port trung thực PXB_Time.js / TimeSystem.cs.
##
## - 1 ngày game = 30 phút thật (PxbBalance.GAME_DAY_MINUTES, đã chốt).
## - 3 khung: Sáng / Chiều / Tối, mỗi khung 10 phút thật.
## - Miss khung KHÔNG phạt: is_missed() chỉ dùng để hiển thị.
## - Sự kiện chung: thứ 7, 20:00 tại Phố Đi Bộ – Chợ Đêm (khu 18).
##
## GIỜ GAME HAY GIỜ THẬT? — GDD Mục 1 chỉ ghi "thứ 7, 20:00", không
## nói rõ. docs/architecture-nadia.md §3 chốt: Phase 1 (chơi đơn)
## sự kiện chung theo GIỜ GAME; Phase 2 (online) theo giờ thật qua
## server. Hàm tĩnh dưới đây làm theo Phase 1; is_real_saturday_event_time()
## là bản giờ thật, để dành cho Phase 2 (PXB_Online).
## Ánh xạ "20:00 giờ game" trong 1 ngày game 30 phút: PROVISIONAL —
## 1 ngày game = 1 vòng 24 giờ game, bắt đầu 00:00, nên 20:00 giờ game
## rơi vào phút thứ 25 của ngày (25/30 × 24h = 20h). GDD chưa chốt ánh
## xạ này; đổi thì sửa game_clock_minutes() + ghi chú ở đây.
## Ngày trong tuần của game cũng PROVISIONAL: ngày game 1 = Thứ Hai.
##
## Đồng hồ chạy: autoload PXB_Time giữ day_number + mốc bắt đầu ngày
## (Time.get_ticks_msec). main.gd vẫn giữ timer khung riêng của G1;
## bước Jobs (G2) sẽ chuyển hẳn sang đồng hồ này.

const EVENT_HOUR := 20 # 20:00 giờ game
const SATURDAY_EVENT_SWITCH_ID := 1 # PROVISIONAL — chưa chốt switch

var day_number: int = 1
var _day_start_msec: int = 0
var _day_started: bool = false


# --- Hàm tĩnh thuần (test được không cần instance) ---

# Khung hiện tại theo số phút thật đã trôi từ đầu ngày game.
# Port trung thực TimeSystem.CurrentFrame (so sánh với FrameLength).
static func frame_index(elapsed_minutes: float) -> int:
	var fm := float(PxbBalance.FRAME_MINUTES)
	if elapsed_minutes < fm:
		return 0 # Sáng
	if elapsed_minutes < fm * 2.0:
		return 1 # Chiều
	return 2 # Tối


static func frame_name(elapsed_minutes: float) -> String:
	return PxbBalance.FRAMES[frame_index(elapsed_minutes)]


# Miss khung không phạt: chỉ trả về true nếu khung đã qua mà người
# chơi không vào. CHỈ dùng để hiển thị — KHÔNG trừ điểm / phạt.
# Port trung thực TimeSystem.IsMissed.
static func is_missed(frame: int, elapsed_minutes: float) -> bool:
	var fm := float(PxbBalance.FRAME_MINUTES)
	if frame == 0:
		return elapsed_minutes >= fm
	if frame == 1:
		return elapsed_minutes >= fm * 2.0
	return elapsed_minutes >= float(PxbBalance.GAME_DAY_MINUTES)


# Số phút thật đã trôi trong khung hiện tại (0..10).
static func minutes_into_frame(elapsed_minutes: float) -> float:
	return elapsed_minutes - float(frame_index(elapsed_minutes)) * float(PxbBalance.FRAME_MINUTES)


# Số phút thật còn lại của khung hiện tại.
static func minutes_until_frame_end(elapsed_minutes: float) -> float:
	return float(PxbBalance.FRAME_MINUTES) - minutes_into_frame(elapsed_minutes)


# Tiến độ ngày game 0..1 (để vẽ đồng hồ / thanh ngày).
static func day_progress(elapsed_minutes: float) -> float:
	return clampf(elapsed_minutes / float(PxbBalance.GAME_DAY_MINUTES), 0.0, 1.0)


# --- Đồng hồ game (PROVISIONAL, xem đầu file) ---
# 1 ngày game = 1 vòng 24 giờ game, bắt đầu 00:00 giờ game.
# Trả về số phút trong ngày theo giờ game (0..1439).
static func game_clock_minutes(elapsed_minutes: float) -> int:
	return int(day_progress(elapsed_minutes) * 24.0 * 60.0)


static func game_clock_hour(elapsed_minutes: float) -> int:
	return game_clock_minutes(elapsed_minutes) / 60


# Ngày trong tuần của game. PROVISIONAL: ngày game 1 = Thứ Hai.
# Trả 0 = Thứ Hai ... 6 = Chủ Nhật (day_number bắt đầu từ 1).
static func game_weekday(p_day_number: int) -> int:
	return ((p_day_number - 1) % 7 + 7) % 7


static func is_saturday(p_day_number: int) -> bool:
	return game_weekday(p_day_number) == 5 # 5 = Thứ Bảy


# Sự kiện chung thứ 7 20:00 giờ game (Phase 1). Cửa sổ sự kiện =
# giờ 20:00 giờ game, tức phút thật 25..30 của ngày thứ 7.
# PROVISIONAL — cửa sổ + ánh xạ giờ game chưa chốt trong GDD.
static func is_saturday_event_time(p_day_number: int, elapsed_minutes: float) -> bool:
	if not is_saturday(p_day_number):
		return false
	return game_clock_hour(elapsed_minutes) == EVENT_HOUR


# Có nên kích hoạt sự kiện chung lúc này không.
static func should_trigger_saturday_event(p_day_number: int, elapsed_minutes: float) -> bool:
	return is_saturday_event_time(p_day_number, elapsed_minutes)


# Bản giờ thật, để dành cho Phase 2 online (server chung):
# thứ 7 thật, trong giờ 20:00 thật. Không dùng ở Phase 1.
static func is_real_saturday_event_time() -> bool:
	var dt := Time.get_datetime_dict_from_system()
	return int(dt.get("weekday", 0)) == 6 and int(dt.get("hour", 0)) == 20


# MV: $gameTimer đếm ngược theo khung 60fps. 1 ngày game =
# GAME_DAY_MINUTES * 60 giây = GAME_DAY_MINUTES * 3600 khung.
static func day_length_frames() -> int:
	return PxbBalance.GAME_DAY_MINUTES * 60 * 60


# --- Đồng hồ chạy (instance autoload) ---

# Bắt đầu 1 ngày game mới.
func start_day() -> void:
	_day_start_msec = Time.get_ticks_msec()
	_day_started = true


# Số phút thật đã trôi từ đầu ngày game hiện tại.
# Chưa start_day() lần nào thì trả 0.
func elapsed_minutes() -> float:
	if not _day_started:
		return 0.0
	return clampf(float(Time.get_ticks_msec() - _day_start_msec) / 60000.0,
		0.0, float(PxbBalance.GAME_DAY_MINUTES))


func current_frame_index() -> int:
	return PxbTime.frame_index(elapsed_minutes())


func current_frame_name() -> String:
	return PxbTime.frame_name(elapsed_minutes())


func is_current_saturday_event_time() -> bool:
	return PxbTime.should_trigger_saturday_event(day_number, elapsed_minutes())


# CHỈ DÙNG CHO TEST: đặt số phút đã trôi mà không cần chờ thật.
func debug_set_elapsed(minutes: float) -> void:
	_day_start_msec = Time.get_ticks_msec() - int(minutes * 60000.0)
	_day_started = true
