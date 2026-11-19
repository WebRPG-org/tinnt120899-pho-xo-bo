class_name PxbStats
extends Node
## Phố Xô Bồ — PXB_Stats (Godot G2, bước 2/17).
## Port trung thực PXB_Stats.js / Stats.cs (src/client/Assets/Scripts/Stats.cs).
##
## - 3 chỉ số gốc: Đỏ Thể / Xanh Trí / Vàng Tâm, mỗi 0..100.
## - 4 chỉ số pha trộn (tính ra, không lưu riêng): Tím Kỷ = (Thể+Trí)/2,
##   Cam Dũng = (Thể+Tâm)/2, Lục Sáng = (Trí+Tâm)/2, Trắng An Yên =
##   trung bình 3 gốc — chỉ khi 3 gốc cân bằng (chênh nhau trong ngưỡng).
## - Trần tổng: GDD chỉ chốt "có trần", chưa chốt số — lấy từ
##   PxbBalance.TOTAL_STAT_CAP (300, PROVISIONAL).
## - Train = đánh đổi: tăng 1 chỉ số phải giảm 1 chỉ số khác cùng lượng.
## - Tiền / Danh vọng / EXP là tài nguyên, KHÔNG phải chỉ số gốc.
##
## Lưu: khi làm save (G2 bước Online/SaveCloud), data() ({the, tri, tam})
## là dữ liệu thuần để lưu; from_data() khôi phục lại.
## Autoload PXB_Stats giữ bộ chỉ số hiện tại của người chơi; mặc định
## là default_data() (chia đều trần tổng). Nhân vật thật trong game luôn
## qua create() — tổng khởi đầu = trần (gacha chỉ đổi phân bổ).
## Khác JS: GDScript không có exception — create() trả null + push_error
## khi tổng khởi đầu khác trần, thay vì throw.

const BASE_KEYS := ["the", "tri", "tam"] # Thể (Đỏ), Trí (Xanh), Tâm (Vàng)

var the: int = 100:
	set(v):
		the = clampi(v, 0, PxbBalance.STAT_MAX)
var tri: int = 100:
	set(v):
		tri = clampi(v, 0, PxbBalance.STAT_MAX)
var tam: int = 100:
	set(v):
		tam = clampi(v, 0, PxbBalance.STAT_MAX)


func total() -> int:
	return the + tri + tam


# Chỉ số trộn = trung bình 2 gốc (làm tròn xuống) — như Stats.cs.
func ky() -> int:
	return (the + tri) / 2 # Tím — Kỷ


func dung() -> int:
	return (the + tam) / 2 # Cam — Dũng


func sang() -> int:
	return (tri + tam) / 2 # Lục — Sáng


# Trắng — An Yên, chỉ khi 3 gốc cân bằng trong ngưỡng PROVISIONAL ±10.
func an_yen() -> int:
	var tol := PxbBalance.AN_YEN_BALANCE_TOLERANCE
	if absi(the - tri) <= tol and absi(tri - tam) <= tol:
		return (the + tri + tam) / 3
	return 0


func get_stat(key: String) -> int:
	if key == "the":
		return the
	if key == "tri":
		return tri
	if key == "tam":
		return tam
	return 0


func set_stat(key: String, v: int) -> void:
	if key == "the":
		the = v
	elif key == "tri":
		tri = v
	elif key == "tam":
		tam = v


# Tăng 1 chỉ số phải giảm 1 chỉ số khác cùng lượng (đánh đổi).
# Trả false nếu không hợp lệ (trùng chỉ số, lượng <= 0, vượt 0..100).
# Port trung thực Stats.Train — tổng không đổi nên không cần kiểm tra
# lại trần tổng ở đây (create() đã đảm bảo tổng = trần).
func train(up: String, down: String, amount: int) -> bool:
	if up == down or amount <= 0:
		return false
	if up not in BASE_KEYS or down not in BASE_KEYS:
		return false
	if get_stat(down) - amount < 0:
		return false
	if get_stat(up) + amount > PxbBalance.STAT_MAX:
		return false
	set_stat(up, get_stat(up) + amount)
	set_stat(down, get_stat(down) - amount)
	return true


# Dữ liệu thuần để lưu ({the, tri, tam}).
func data() -> Dictionary:
	return {"the": the, "tri": tri, "tam": tam}


# Tạo bộ chỉ số mới. Tổng khởi đầu PHẢI bằng trần tổng (gacha chỉ đổi
# phân bổ, không đổi tổng) — sai thì trả null + push_error.
static func create(p_the: int, p_tri: int, p_tam: int) -> PxbStats:
	var s := PxbStats.new()
	s.the = p_the
	s.tri = p_tri
	s.tam = p_tam
	if s.total() != PxbBalance.TOTAL_STAT_CAP:
		push_error("Tổng chỉ số khởi đầu phải bằng trần %d (gacha chỉ đổi phân bổ, không đổi tổng)." % PxbBalance.TOTAL_STAT_CAP)
		return null
	return s


# CHỈ DÙNG CHO TEST: tạo Stats với giá trị tùy ý, không yêu cầu tổng
# = trần tổng (như Stats.WithValues). Nhân vật thật trong game luôn
# qua create() — tổng khởi đầu = trần.
static func with_values(p_the: int, p_tri: int, p_tam: int) -> PxbStats:
	var s := PxbStats.new()
	s.the = p_the
	s.tri = p_tri
	s.tam = p_tam
	return s


# Khôi phục từ dữ liệu save (kẹp lại 0..100 cho an toàn).
static func from_data(d: Dictionary) -> PxbStats:
	return with_values(int(d.get("the", 0)), int(d.get("tri", 0)), int(d.get("tam", 0)))


# Phân bổ khởi đầu mặc định khi new game mà event chưa gacha:
# chia đều trần tổng cho 3 gốc (300/3 = 100 mỗi chỉ số — chạm trần từng
# chỉ số; đây chỉ là giá trị dự phòng, nhân vật thật do gacha quyết
# phân bổ). PROVISIONAL — đổi khi chủ chốt phân bổ khởi đầu.
static func default_data() -> Dictionary:
	var each := PxbBalance.TOTAL_STAT_CAP / 3
	return {"the": each, "tri": each, "tam": PxbBalance.TOTAL_STAT_CAP - each * 2}
