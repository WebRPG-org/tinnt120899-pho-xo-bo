class_name PxbTitles
extends Node
## Phố Xô Bồ — PXB_Titles (Godot G2, bước 5/17).
## Port trung thực PXB_Titles.js (src/nadia/www/js/plugins/
## PXB_Titles.js) / TitleConflict.cs (src/client/Assets/Scripts/
## TitleConflict.cs) — danh hiệu GDD Mục 3: xung đột chặn lẫn nhau
## 2 chiều, phe Chính / Tà / Trung lập, quest đổi phe
## "Cải tà quy chính".
##
## - Danh hiệu không giới hạn số lượng sưu tầm; hiển thị 1 chính +
##   2–3 phụ (GDD Mục 3, việc của UI sau này — ở đây chỉ giữ sổ).
## - Bảng chặn BlockedBy giữ đúng y C# (7 dòng, so sánh không phân
##   biệt hoa/thường). is_blocked() chặn cả hai chiều: chiều xuôi
##   (danh hiệu đang có chặn danh hiệu/nghề muốn nhận) + chiều ngược
##   (tra BlockedBy[wanted] — không cần bảng ngược riêng).
## - Danh hiệu lưu dạng Array[String] thuần (JSON-safe) trong
##   instance này; alignment là bản sao đã tính sẵn từ titles (nguồn
##   sự thật là titles — add/remove/redeem tự cập nhật lại).
##
## QUIRK GIỮ ĐÚNG C# (không tự sửa):
## - Kẻ Lừa Đảo CHỈ chặn "Luật Sư Chính Trực" — KHÔNG chặn
##   "Luật Sư Bào Chữa". Đây là quirk cố ý trong TitleConflict.cs
##   (có comment ghi rõ), giữ nguyên — đừng "sửa" cho đối xứng.
## - is_blocked() null-safe: wanted rỗng / không phải string → false,
##   title rỗng / không phải string trong list đang có thì bỏ qua.
##
## PROVISIONAL (xem @help của JS — đổi thì sửa ở đây +
## TitleConflict.cs + docs/gdd.md Mục 3 cùng lúc):
## - Danh sách phe Chính / Tà suy ra từ bảng chặn (GDD Mục 3 chỉ
##   chốt "mỗi danh hiệu có phe", chưa liệt kê danh hiệu nào thuộc
##   phe nào): phe Tà: Tướng Cướp, Trùm Buôn Lậu, Tham Quan,
##   Kẻ Lừa Đảo; phe Chính: Thanh Liêm, Người Hùng, Luật Sư Chính
##   Trực, Học Giả, Tiến sĩ, Tỷ Phú Từ Thiện. alignment_of():
##   có danh hiệu phe Tà → "Ta"; có danh hiệu phe Chính → "Chinh";
##   cả hai phe hoặc không có gì → "TrungLap".
## - Quest "Cải tà quy chính": GDD / TitleConflict.cs chỉ nhắc tên,
##   chưa chốt điều kiện chi tiết. Tạm chốt: can_redeem() true khi
##   alignment hiện tại là "Ta"; redeem() xóa mọi danh hiệu phe Tà.

# Phe (port enum TitleConflict.cs).
const ALIGNMENT_CHINH := "Chinh"
const ALIGNMENT_TA := "Ta"
const ALIGNMENT_TRUNG_LAP := "TrungLap"

# Bảng chặn (port đúng y TitleConflict.cs — 7 dòng).
# Danh hiệu -> danh hiệu / nghề bị chặn. So sánh không phân biệt
# hoa/thường.
const BLOCKED_BY := {
	"Tướng Cướp": ["Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên"],
	"Trùm Buôn Lậu": ["Cảnh sát", "Thẩm phán", "Hải quan", "Giáo viên"],
	"Tham Quan": ["Thanh Liêm", "Người Hùng"],
	# QUIRK — giữ đúng C#: chỉ chặn "Luật Sư Chính Trực", KHÔNG chặn
	# "Luật Sư Bào Chữa".
	"Kẻ Lừa Đảo": ["Luật Sư Chính Trực"],
	"Học Giả": ["Kẻ Bỏ Học"],
	"Tiến sĩ": ["Kẻ Bỏ Học"],
	"Tỷ Phú Từ Thiện": ["Kẻ Keo Kiệt"],
}

# Danh sách phe Chính / Tà (PROVISIONAL — xem header).
const EVIL_TITLES := ["Tướng Cướp", "Trùm Buôn Lậu", "Tham Quan",
	"Kẻ Lừa Đảo"]
const GOOD_TITLES := ["Thanh Liêm", "Người Hùng", "Luật Sư Chính Trực",
	"Học Giả", "Tiến sĩ", "Tỷ Phú Từ Thiện"]

var titles: Array = [] # Array[String] — danh hiệu đang có
var alignment: String = ALIGNMENT_TRUNG_LAP # bản sao đã tính từ titles


# --- So sánh không phân biệt hoa/thường ---

static func equals_ignore_case(a: Variant, b: Variant) -> bool:
	if not (a is String) or not (b is String):
		return false
	return (a as String).to_lower() == (b as String).to_lower()


# Tìm key trong BLOCKED_BY khớp không phân biệt hoa/thường.
# Trả "" nếu không có.
static func blocked_by_key(title: Variant) -> String:
	if not (title is String):
		return ""
	var lower := (title as String).to_lower()
	for k in BLOCKED_BY.keys():
		if (k as String).to_lower() == lower:
			return k
	return ""


# --- Xung đột danh hiệu (port TitleConflict.IsBlocked) ---

# True nếu danh hiệu đang có chặn danh hiệu/nghề muốn nhận — chặn
# cả hai chiều của mỗi cặp xung đột, không phân biệt hoa/thường.
# Null-safe: wanted rỗng / không phải string → false, title rỗng /
# không phải string trong list thì bỏ qua (đúng C#).
static func is_blocked(owned_titles: Array, wanted_title_or_job: Variant) -> bool:
	if not (wanted_title_or_job is String) \
			or (wanted_title_or_job as String) == "":
		return false
	if owned_titles.is_empty():
		return false
	for title in owned_titles:
		if not (title is String) or (title as String) == "":
			continue
		# Chiều xuôi: danh hiệu đang có chặn danh hiệu/nghề muốn nhận.
		var key := blocked_by_key(title)
		if key != "":
			for blocked in BLOCKED_BY[key]:
				if equals_ignore_case(blocked, wanted_title_or_job):
					return true
		# Chiều ngược: danh hiệu/nghề muốn nhận chặn danh hiệu đang có
		# (ví dụ muốn nhận "Tướng Cướp" trong khi đang có "Cảnh sát").
		# Không cần bảng ngược riêng: tra thẳng BlockedBy[wanted].
		var wanted_key := blocked_by_key(wanted_title_or_job)
		if wanted_key != "":
			for blocked_by_wanted in BLOCKED_BY[wanted_key]:
				if equals_ignore_case(blocked_by_wanted, title):
					return true
	return false


# Tính phe từ danh hiệu đang có (PROVISIONAL — xem header):
# có phe Tà → "Ta"; có phe Chính → "Chinh"; cả hai phe hoặc
# không có gì → "TrungLap".
static func alignment_of(titles_list: Array) -> String:
	var has_evil := false
	var has_good := false
	for t in titles_list:
		if not (t is String):
			continue
		for e in EVIL_TITLES:
			if equals_ignore_case(e, t):
				has_evil = true
		for g in GOOD_TITLES:
			if equals_ignore_case(g, t):
				has_good = true
	if has_evil and has_good:
		return ALIGNMENT_TRUNG_LAP
	if has_evil:
		return ALIGNMENT_TA
	if has_good:
		return ALIGNMENT_CHINH
	return ALIGNMENT_TRUNG_LAP


# Cập nhật lại field alignment đã tính sẵn (nguồn sự thật vẫn là
# titles — xem header).
func _refresh_alignment() -> void:
	alignment = alignment_of(titles)


# --- Sổ danh hiệu của người chơi ---

# Danh sách danh hiệu (bản sao — sửa bản sao không ảnh hưởng state).
func all_titles() -> Array:
	return titles.duplicate()


# Có danh hiệu này không — không phân biệt hoa/thường.
func has_title(title: String) -> bool:
	for t in titles:
		if equals_ignore_case(t, title):
			return true
	return false


# Thêm danh hiệu. Trả false nếu đã có (không phân biệt hoa/thường)
# hoặc bị chặn bởi danh hiệu đang có (dùng is_blocked — chặn cả hai
# chiều). Title rỗng cũng trả false.
func add_title(title: String) -> bool:
	if title == "":
		return false
	if has_title(title):
		return false
	if is_blocked(titles, title):
		return false
	titles.append(title)
	_refresh_alignment()
	return true


# Gỡ danh hiệu (không phân biệt hoa/thường). Trả false nếu không có.
func remove_title(title: String) -> bool:
	for i in titles.size():
		if equals_ignore_case(titles[i], title):
			titles.remove_at(i)
			_refresh_alignment()
			return true
	return false


# Có nhận được nghề này không — dùng is_blocked: danh hiệu đang có
# chặn nghề thì không nhận được.
func can_take_job(job_name: String) -> bool:
	return not is_blocked(titles, job_name)


# --- Quest đổi phe "Cải tà quy chính" (PROVISIONAL — xem header) ---

# Được đổi phe khi alignment hiện tại là "Ta" (đang có danh hiệu
# phe Tà).
func can_redeem() -> bool:
	return alignment_of(titles) == ALIGNMENT_TA


# Đổi phe: xóa mọi danh hiệu phe Tà. Trả true nếu đã đổi; false
# nếu không phải phe Tà (không xóa gì).
func redeem() -> bool:
	if not can_redeem():
		return false
	var kept: Array = []
	for t in titles:
		var is_evil := false
		if t is String:
			for e in EVIL_TITLES:
				if equals_ignore_case(e, t):
					is_evil = true
		if not is_evil:
			kept.append(t)
	titles = kept
	_refresh_alignment()
	return true


# --- Save / load (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {"titles": titles.duplicate(), "alignment": alignment}


static func from_data(d: Dictionary) -> PxbTitles:
	var s := PxbTitles.new()
	if d.is_empty():
		return s
	if d.get("titles") is Array:
		for t in d["titles"]:
			# Bỏ title bẩn: không phải string, rỗng, trùng
			# (không phân biệt hoa/thường).
			if not (t is String) or (t as String) == "":
				continue
			if s.has_title(t):
				continue
			s.titles.append(t)
		s._refresh_alignment()
	return s
