class_name PxbHotspot
extends Node
## Phố Xô Bồ — PXB_Hotspot (Godot G2, bước 2/17).
## Port trung thực PXB_Hotspot.js / Exploration.cs
## (src/nadia/www/js/plugins/PXB_Hotspot.js,
##  src/client/Assets/Scripts/Exploration.cs).
##
## - 5 hotspot slice (PROVISIONAL — danh sách + vật + số lượng chưa chốt
##   GDD; khi GDD chốt bảng hotspot thì sửa đúng bảng HOTSPOTS, không sửa
##   code khám phá — như Exploration.cs đã ghi).
## - Hotspot TO, lấp lánh, chạm được: vùng chạm tối thiểu 44×44 pt
##   (architecture-nadia.md §6 dòng 5; HotspotView.cs).
## - Nhặt 1 lần / 1 ngày game — quay lại ngày sau có vật mới (kiểu Nadia).
##   Sang ngày game mới thì tự reset lượt khám phá trong ngày.
## - CHỈ CHO ĐỒ ĐÚNG KHUNG: hotspot chỉ nhặt được khi khung hiện tại
##   trùng best_frame của nó.
## - Màu lấp lánh: vàng Vàng Tâm #E0A800 (thường) / cam (hiếm) — palette
##   lock, HotspotView.cs. Cả 5 hotspot slice đều là "thuong" (vàng);
##   Exploration.cs KHÔNG có trường hiếm nên chưa hotspot nào là hiếm —
##   mã màu cam dưới đây là PROVISIONAL, chỉ dùng khi GDD chốt hotspot hiếm.
## - Độ sáng lấp lánh (HotspotView.cs): đã nhặt hôm nay 0.25, đúng khung
##   tốt 1.5, còn lại 0.8; nhấp nháy to dần/nhỏ dần theo nhịp sin.
## - NPC dẫn đường guide_hint (thay Soul Crystal / Evie của Nadia):
##   Cô Tư (khu 1), Chị Lệ (khu 2), Ông Ba (khu 17), Anh Hải (khu 18),
##   khu khác: Bạn thân. Gợi ý nhúng trong lời thoại, không spoil đáp án,
##   nhạt dần theo tiến trình — không biến mất đột ngột giữa game.
## - Fast travel chỉ tới khu đã mở (slice: 1, 2, 17, 18); khu chưa mở ghi
##   rõ điều kiện mở (xem docs/districts.md — khu mở theo chương/tầng).
##
## NGUỒN DỮ LIỆU HOTSPOT: bảng HOTSPOTS dưới đây port TRỰC TIẾP từ
## Exploration.cs (Hotspots) — docs/districts.md KHÔNG liệt kê
## hotspot/vật/khung nào nên không lấy từ đó, không bịa thêm hotspot mới.
## Id nguyên liệu dùng chung với Crafting (la-chuoi, van-go, khung-sat,
## banh-xe, vai-vun, chai-nhua, sat-vun).
##
## LỆCH JS-vs-C# (ghi chú PROVISIONAL — xem thêm cuối file):
##   1. Chặn sai khung: JS explore() chặn "wrong-frame"; C# Explore()
##      KHÔNG kiểm tra khung (chỉ dùng BestFrame để sắp xếp + sáng hơn).
##      Port này theo JS (architecture-nadia.md §6 dòng 5: "chỉ có đồ
##      đúng khung"). Khi C# sửa theo thì hai bên khớp.
##   2. Reset khi sang ngày: C# chỉ reset khi _currentDay đã có giá trị
##      (lần explore đầu tiên sau load save thì KHÔNG reset, để khỏi xóa
##      lượt đã lưu); JS reset bất cứ khi nào game_day khác state.day.
##      Port này theo JS (state mới vốn đã rỗng nên thực tế không khác;
##      khác chỉ khi from_data() khôi phục lượt đã nhặt rồi explore với
##      ngày khác ngay lần đầu — lúc đó port này reset, C# thì giữ).
##   3. Rarity: C# Hotspot KHÔNG có trường hiếm; JS thêm rarity "thuong"
##      cho cả 5 + màu cam hiếm PROVISIONAL (chưa dùng trong slice).
##   4. Trả về: C# Explore() trả bool; JS trả {ok, reason, material_id,
##      amount} phân biệt "unknown"/"wrong-frame"/"already". Port này
##      theo JS.
##   5. CanFastTravel: C# kiểm tra khu có trong Districts.All (18 khu);
##      JS kiểm tra 1..DISTRICT_COUNT. Cùng kết quả vì 18 khu là 1..18.
##
## Lưu: khi làm save (G2 bước Online/SaveCloud), data() là dữ liệu thuần
## để lưu; from_data() khôi phục lại (kẹp ngày về >= 1, bỏ lượt đã nhặt
## của hotspot lạ — như JS extractSaveContents).
## Autoload PXB_Hotspot giữ state khám phá hiện tại của người chơi.
## Khác JS/C#: GDScript không có exception — explore() trả Dictionary
## với reason ("ok"/"unknown"/"wrong-frame"/"already") thay vì throw.

# --- Bảng hotspot slice — PORT TRỰC TIẾP Exploration.Hotspots ---
# PROVISIONAL — danh sách hotspot + vật + số lượng là số cấu hình slice,
# chưa chốt GDD (Exploration.cs). Chỉ dùng 4 khu slice: 1 Xóm Trọ Cũ,
# 2 Chợ Đầu Mối, 17 Công Viên An Bình, 18 Phố Đi Bộ – Chợ Đêm.
# id, name, district_id, best_frame ("Sáng"/"Chiều"/"Tối"), material_id,
# amount_per_visit, rarity ("thuong" — cả 5 đều thường; Exploration.cs
# không có trường hiếm).
const HOTSPOTS := [
	{"id": "hs-cho-sang", "name": "Sạp rau buổi sáng", "district_id": 2, "best_frame": "Sáng", "material_id": "la-chuoi", "amount": 2, "rarity": "thuong"},
	{"id": "hs-cho-chieu", "name": "Góc phế liệu chợ", "district_id": 2, "best_frame": "Chiều", "material_id": "sat-vun", "amount": 1, "rarity": "thuong"},
	{"id": "hs-tro-toi", "name": "Hẻm trọ buổi tối", "district_id": 1, "best_frame": "Tối", "material_id": "chai-nhua", "amount": 2, "rarity": "thuong"},
	{"id": "hs-cong-vien", "name": "Ghế đá công viên", "district_id": 17, "best_frame": "Chiều", "material_id": "van-go", "amount": 1, "rarity": "thuong"},
	{"id": "hs-cho-dem", "name": "Sạp đêm cuối phố", "district_id": 18, "best_frame": "Tối", "material_id": "vai-vun", "amount": 2, "rarity": "thuong"},
]

# Khu đã mở fast-travel trong slice (Exploration.FastTravelUnlockedSlice).
# Khu khác mở dần bằng chế tạo / quest (GDD Mục 9) — không hardcode ở đây.
const FAST_TRAVEL_UNLOCKED_SLICE := [1, 2, 17, 18]

# Tổng số khu đã chốt: 18 (docs/districts.md). Dùng để kiểm tra khu
# có thật khi fast travel — tên khu xem districts.md, không hardcode
# tên khu vào script này.
const DISTRICT_COUNT := 18

# --- Hằng hiển thị (không phải số game — lấy từ HotspotView.cs) ---
# Vùng chạm tối thiểu 44×44 pt trên mobile (architecture-nadia §6.5).
const MIN_TOUCH_PT := 44
# Màu Vàng Tâm #E0A800 — palette lock (HotspotView.cs, docs/art-assets.md §0).
const SPARKLE_COLOR_COMMON := "#E0A800" # vàng — thường
# PROVISIONAL — mã màu cam cho hotspot hiếm: GDD chưa chốt hotspot hiếm
# nào (Exploration.cs không có trường hiếm) nên màu này chưa dùng trong
# slice; đổi khi chốt palette hiếm.
const SPARKLE_COLOR_RARE := "#E07800" # cam — hiếm (PROVISIONAL)
# Độ sáng lấp lánh (HotspotView.cs): đã nhặt 0.25 / đúng khung 1.5 / còn lại 0.8.
const BRIGHTNESS_COLLECTED := 0.25
const BRIGHTNESS_BEST_FRAME := 1.5
const BRIGHTNESS_NORMAL := 0.8
# Nhấp nháy kiểu Nadia: to dần / nhỏ dần theo nhịp sin (HotspotView.cs).
const SPARKLE_PULSE_BASE := 0.85
const SPARKLE_PULSE_AMP := 0.15
const SPARKLE_PULSE_SPEED := 3.0

# --- State chạy (instance autoload) ---
# Ngày game đã ghi nhận — explore() tự reset lượt khi game_day khác.
var day_number: int = 1
# Lượt đã nhặt trong ngày game này: { hotspot_id: true }.
var _visited: Dictionary = {}
# Túi nguyên liệu: { material_id: số lượng } — id dùng chung với Crafting.
var materials: Dictionary = {}
# Khu đã mở fast-travel hiện tại (slice). Sau này PXB_Story / quest mở
# thêm khu thì ghi vào đây (tương đương $gameSystem.pxbUnlockedDistricts).
var unlocked_districts: Array[int] = [1, 2, 17, 18]


# --- Tra cứu bảng (hàm tĩnh thuần) ---

# Trả Dictionary hotspot, hoặc {} nếu không có (không throw).
static func get_hotspot(hotspot_id: String) -> Dictionary:
	for h in HOTSPOTS:
		if String(h["id"]) == hotspot_id:
			return (h as Dictionary).duplicate()
	return {}


# Hotspot trong 1 khu, theo khung hiện tại (khung tốt lên trước).
# Port trung thực Exploration.HotspotsInDistrict.
static func hotspots_in_district(district_id: int, frame_name: String) -> Array:
	var best: Array = []
	var rest: Array = []
	for h in HOTSPOTS:
		if int(h["district_id"]) != district_id:
			continue
		if String(h["best_frame"]) == frame_name:
			best.append((h as Dictionary).duplicate())
		else:
			rest.append((h as Dictionary).duplicate())
	best.append_array(rest)
	return best


# Chỉ fast travel tới khu đã mở. Trả false nếu khu chưa mở / không có
# trong 18 khu. Port trung thực Exploration.CanFastTravel.
static func can_fast_travel_to(district_id: int, unlocked: Array) -> bool:
	if district_id < 1 or district_id > DISTRICT_COUNT:
		return false
	return district_id in unlocked


# --- Màu + độ sáng lấp lánh (HotspotView.cs) — phần tính toán thuần ---

static func sparkle_color(hotspot: Dictionary) -> String:
	if String(hotspot.get("rarity", "thuong")) == "hiem":
		return SPARKLE_COLOR_RARE
	return SPARKLE_COLOR_COMMON


# Tỉ lệ nhấp nháy theo thời gian (giây): 0.85 + 0.15 * sin(t * 3).
static func sparkle_scale(elapsed_seconds: float) -> float:
	return SPARKLE_PULSE_BASE + SPARKLE_PULSE_AMP * sin(elapsed_seconds * SPARKLE_PULSE_SPEED)


# Độ sáng: đã nhặt hôm nay 0.25, đúng khung tốt 1.5, còn lại 0.8.
static func sparkle_brightness(hotspot: Dictionary, frame_name: String, collected_today: bool) -> float:
	if collected_today:
		return BRIGHTNESS_COLLECTED
	if not hotspot.is_empty() and frame_name != "" and String(hotspot.get("best_frame", "")) == frame_name:
		return BRIGHTNESS_BEST_FRAME
	return BRIGHTNESS_NORMAL


# Kích thước chạm tối thiểu (pt) — event hotspot phải to ít nhất chừng này.
static func min_touch_pt() -> int:
	return MIN_TOUCH_PT


# --- NPC dẫn đường GuideHint — PORT TRỰC TIẾP Exploration.GuideHint ---
# Tên NPC là NPC Phố Xô Bồ, không phải Nadia. Gợi ý gắn với mục tiêu
# hiện tại, không spoil đáp án.
static func guide_hint(district_id: int, current_goal: String) -> String:
	var goal := current_goal.strip_edges()
	if goal == "":
		goal = "chưa có mục tiêu rõ"
	match district_id:
		1:
			return "Cô Tư (chủ trọ): \"Ở hẻm này thì cứ ra chợ sớm mà nhặt đồ. Còn %s thì ghé sạp đầu hẻm hỏi thử.\"" % goal
		2:
			return "Chị Lệ (sạp rau): \"Chợ sáng nhiều đồ lắm, chiều thì qua góc phế liệu. %s thì cần đồ chế — coi lại túi nguyên liệu đi.\"" % goal
		17:
			return "Ông Ba (công viên): \"Ngồi ghế đá nghĩ cho kỹ đã. %s gấp thì không xong đâu, cứ từng bước.\"" % goal
		18:
			return "Anh Hải (chợ đêm): \"Đêm nay đông khách, vừa bán vừa nhặt được đồ. %s thì để mai sáng làm tiếp cũng được.\"" % goal
		_:
			return "Bạn thân: \"Không biết làm gì tiếp thì mở điện thoại coi Bản đồ với Việc làm đã. Mục tiêu hiện tại: %s.\"" % goal


# --- Logic khám phá (instance) ---

# Sang ngày game mới: reset lượt khám phá trong ngày.
# Port trung thực Exploration.NewGameDay.
func new_game_day() -> void:
	_visited.clear()


# Khám phá 1 hotspot (port JS explore() + chặn sai khung).
# Trả {ok, reason, material_id, amount}:
#   ok=true  — nhặt được; reason "ok".
#   ok=false — reason "unknown" (hotspot không có), "wrong-frame"
#   (sai khung — chỉ cho đồ đúng khung, xem đầu file), "already"
#   (đã nhặt trong ngày game này — mai quay lại có đồ mới).
# Sang ngày mới thì TỰ reset lượt khám phá trong ngày (như C# đã sửa
# 18/11: Explore tự reset khi game_day khác ngày đã lưu).
# frame_name "" = không kiểm tra khung (dùng khi khung chưa xác định).
func explore(hotspot_id: String, game_day: int, frame_name: String) -> Dictionary:
	var hotspot := PxbHotspot.get_hotspot(hotspot_id)
	if hotspot.is_empty():
		return {"ok": false, "reason": "unknown", "material_id": "", "amount": 0}
	if game_day != day_number:
		new_game_day()
		day_number = game_day
	# Chỉ cho đồ đúng khung (architecture-nadia §6 dòng 5). LỆCH VỚI
	# Exploration.Explore() hiện tại — xem ghi chú ở đầu file.
	if frame_name != "" and String(hotspot["best_frame"]) != frame_name:
		return {"ok": false, "reason": "wrong-frame", "material_id": String(hotspot["material_id"]), "amount": 0}
	if has_visited_today(hotspot_id):
		return {"ok": false, "reason": "already", "material_id": String(hotspot["material_id"]), "amount": 0}
	_visited[hotspot_id] = true
	var mat_id := String(hotspot["material_id"])
	materials[mat_id] = int(materials.get(mat_id, 0)) + int(hotspot["amount"])
	return {"ok": true, "reason": "ok", "material_id": mat_id, "amount": int(hotspot["amount"])}


func has_visited_today(hotspot_id: String) -> bool:
	return bool(_visited.get(hotspot_id, false))


# Sang ngày game mới (đường fallback khi không truyền game_day vào
# explore): reset lượt khám phá, tăng ngày, trả ngày mới.
func advance_day() -> int:
	new_game_day()
	day_number += 1
	return day_number


# Fast travel tới khu đã mở chưa (dùng unlocked_districts hiện tại).
func can_fast_travel(district_id: int) -> bool:
	return PxbHotspot.can_fast_travel_to(district_id, unlocked_districts)


# Hotspot trong 1 khu, khung tốt lên trước (dùng khung truyền vào).
func hotspots_here(district_id: int, frame_name: String) -> Array:
	return PxbHotspot.hotspots_in_district(district_id, frame_name)


# Gợi ý NPC theo khu + mục tiêu hiện tại.
func hint(district_id: int, current_goal: String) -> String:
	return PxbHotspot.guide_hint(district_id, current_goal)


# --- Dữ liệu thuần để lưu (save) ---

# Dữ liệu thuần để lưu ({day, visited, materials, unlocked}).
func data() -> Dictionary:
	return {
		"day": day_number,
		"visited": _visited.keys(),
		"materials": materials.duplicate(),
		"unlocked": unlocked_districts.duplicate(),
	}


# Khôi phục từ dữ liệu save (kẹp ngày về >= 1, bỏ lượt đã nhặt của
# hotspot không còn trong bảng — như JS extractSaveContents).
static func from_data(d: Dictionary) -> PxbHotspot:
	var h := PxbHotspot.new()
	h.day_number = maxi(int(d.get("day", 1)), 1)
	for id in d.get("visited", []):
		if not PxbHotspot.get_hotspot(String(id)).is_empty():
			h._visited[String(id)] = true
	for k in (d.get("materials", {}) as Dictionary):
		h.materials[String(k)] = int((d["materials"] as Dictionary)[k])
	var unlocked: Array[int] = []
	for x in d.get("unlocked", FAST_TRAVEL_UNLOCKED_SLICE):
		var n := int(x)
		if n >= 1 and n <= DISTRICT_COUNT and n not in unlocked:
			unlocked.append(n)
	if not unlocked.is_empty():
		h.unlocked_districts = unlocked
	return h
