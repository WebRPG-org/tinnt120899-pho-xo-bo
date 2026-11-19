class_name PxbTools
extends Node
## Phố Xô Bồ — PXB_Tools (Godot G2, bước 6/17).
## Port trung thực PXB_Tools.js (src/nadia/www/js/plugins/
## PXB_Tools.js) / Crafting.cs (src/client/Assets/Scripts/
## Crafting.cs) — 4 công cụ × 3 bậc kiểu Treasure of Nadia, nâng cấp
## ĐỔI HÀNH VI thật (không chỉ +số), đúng 12 câu ToolBehaviour.
##
## - 4 công cụ × 3 bậc (đúng enum GameTool / ToolTier trong
##   Crafting.cs): Xe Đẩy / Đèn Soi / Sổ Tay / Xẻng (Thô 1 / Khá 2 /
##   Tốt 3). Mô tả hành vi từng combo lấy từng chữ từ
##   Crafting.ToolBehaviour — xem tool_behaviour(). Bậc/tool lạ trả
##   "Chưa rõ bậc công cụ." (đúng test ToolBehaviour_BacLa).
## - Hành vi ĐỔI THẬT, không chỉ +số (kiểu Nadia):
##   Xe Đẩy: sức chở tăng theo bậc (PROVISIONAL), bậc 3 đi được
##   đường mưa, không ướt hàng — cart_can_travel().
##   Đèn Soi: bậc 1 thấy hotspot thường; bậc 2 thêm hotspot ẨN GẦN;
##   bậc 3 thấy MỌI hotspot, kể cả hotspot hiếm chỉ xuất hiện 1
##   khung/ngày — sees_hotspot().
##   Sổ Tay: bậc 1 NPC gợi ý chung chung; bậc 2 gợi ý rõ mục tiêu +
##   khu cần tới; bậc 3 thêm nguyên liệu còn thiếu — guide_hint().
##   Xẻng/Cuốc: bậc 1 nhặt thường; bậc 2 nhặt nhanh hơn, thỉnh
##   thoảng +1 nguyên liệu; bậc 3 nhặt nhanh + có cơ hội nhặt được
##   nguyên liệu hiếm — collect_yield() / collect().
## - NÂNG CẤP bậc 2/3: Crafting.cs KHÔNG có công thức nâng cấp nào
##   (chỉ có 2 công thức bậc 1: che-xe-day, che-den-soi; Sổ Tay và
##   Xẻng không có công thức bậc 1 nào). Toàn bộ chi phí nâng cấp
##   trong file này là PROVISIONAL, suy từ công thức bậc 1 theo quy
##   tắc: chi phí nâng lên bậc N = chi phí bậc 1 × N (bậc 2 = ×2,
##   bậc 3 = ×3, cùng loại nguyên liệu) — xem UPGRADE_RECIPES.
##   Khi GDD chốt bảng nâng cấp thì sửa đúng bảng đó, không sửa code.
## - Sổ Tay / Xẻng bậc 1 cũng chưa có công thức trong Crafting.cs nên
##   file này thêm công thức nhận bậc 1 PROVISIONAL cho 2 công cụ đó
##   (ACQUIRE_RECIPES, suy theo kiểu Nadia: Xẻng = đầu sắt + cán gỗ
##   như Basic Shovel; Sổ Tay = lá chuối làm trang + vải vụn làm bìa)
##   qua acquire(). Xe Đẩy / Đèn Soi bậc 1 KHÔNG chế ở đây — phải chế
##   qua PxbCrafting (che-xe-day / che-den-soi, đã học qua NPC).
## - LƯU TRỮ — 1 NGUỒN SỰ THẬT: bậc công cụ sống trong tools của
##   instance này (đi theo save qua data()/from_data(), như
##   PxbCrafting). PxbCrafting vẫn giữ bản sao trong tools của nó
##   (craft_current ghi vào đó). File này ĐỒNG BỘ 2 chiều khi đã
##   bind_crafting(): đọc bậc thì lấy max(tools, crafting) qua
##   sync_from_crafting(); nâng cấp / nhận công cụ ở đây thì ghi đè
##   (mirror) sang crafting.tools để 2 bên không lệch. Không bao giờ
##   để 2 số bậc khác nhau tồn tại. Chưa bind thì mỗi hệ giữ số riêng.
## - Túi nguyên liệu dùng chung với PxbHotspot / PxbCrafting: gọi
##   bind_materials(bag) để hai hệ cùng giữ MỘT túi (Dictionary gán
##   theo tham chiếu). Nguyên liệu nào trừ hết về 0 thì XÓA key khỏi
##   túi, không để lại entry 0 — cùng quy ước Crafting.cs sửa 18/11.
##
## PROVISIONAL — số chưa chốt, đổi thì sửa ở đây + Crafting.cs +
## docs/gdd.md Mục 6 cùng lúc (mọi số đều ghi rõ PROVISIONAL):
##  1. Chi phí nâng cấp bậc 2/3 cả 4 công cụ (quy tắc ×N ở trên).
##  2. Chi phí nhận bậc 1 Sổ Tay (lá chuối 2 + vải vụn 1) và Xẻng
##     (sắt vụn 2 + ván gỗ 1) — Crafting.cs không có công thức nào.
##  3. Sức chở Xe Đẩy: bậc 1 = 5, bậc 2 = 10, bậc 3 = 20 đơn vị hàng
##     mỗi chuyến — Crafting.cs / Jobs.cs không có số sức chở nào.
##  4. Xẻng: hệ số thời gian nhặt 1,0 / 0,75 / 0,5; bậc 2 thỉnh
##     thoảng +1 với tỉ lệ 25%; bậc 3 cơ hội nhặt hiếm 10% — C# chỉ
##     ghi chữ "nhanh hơn / thỉnh thoảng / có cơ hội", không có số.
##  5. Nguyên liệu hiếm "da-quy" (id PROVISIONAL): Exploration.cs
##     không có nguyên liệu hiếm / hotspot hiếm nào — id này chỉ là
##     chỗ giữ, đổi khi GDD chốt bảng nguyên liệu hiếm.
##  6. Đèn Soi bậc 2 "hotspot ẩn GẦN": "gần" = hotspot.near == true
##     (hoặc cùng khu với người chơi khi event truyền districtId) —
##     C# không định nghĩa khoảng cách gần/xa.
##  7. Thời tiết mưa: chưa có hệ thời tiết nào — cart_can_travel()
##     nhận cờ is_raining do event truyền vào; không truyền thì đọc
##     weather_raining (mặc định false, PROVISIONAL) — event / hệ
##     thời tiết sau này gọi set_weather_raining() để cập nhật.
##
## KHÁC JS/C# (không tự sửa số — chỉ khác do nền tảng):
## - Đối chiếu JS-vs-C# (20/11): 12 câu ToolBehaviour trong JS khớp
##   từng chữ với Crafting.cs; chi phí nâng cấp JS khớp đúng quy tắc
##   ×N trên cơ số C# (che-xe-day khung-sat 1 + banh-xe 2 + van-go 2
##   -> nâng bậc 2: 2/4/4, bậc 3: 3/6/6; che-den-soi sat-vun 2 +
##   chai-nhua 2 -> 4/4, 6/6). KHÔNG phát hiện lệch số nào.
## - JS trả null khi không tìm thấy (upgrade_cost / recipe_by_id...);
##   GDScript không có null cho Dictionary nên file này trả {} rỗng
##   (cùng quy ước PxbCrafting.get_recipe).
## - JS TIER_NAMES viết không dấu ("Tho"/"Kha"/"Tot"); file này dùng
##   có dấu ("Thô"/"Khá"/"Tốt") theo quy ước PxbCrafting + luật chữ
##   trên màn hình phải đủ dấu — chỉ khác chính tả, không đổi nghĩa.
## - JS giữ state trong $gameSystem.pxbTools (đi theo save MV);
##   Godot giữ state trong instance này + data()/from_data().
## - JS gọi PXB_Crafting / PXB_Hotspot / PXB_Time toàn cục khi đã
##   load; Godot dùng bind_crafting() / bind_hotspot() / bind_time()
##   (tùy chọn). Chưa bind thì các đường ủy quyền trả về câu mặc định
##   ("Chưa rõ bậc công cụ.") hoặc bỏ qua kiểm tra khung — đúng JS
##   khi plugin kia chưa load.
## - GDScript không có exception — các hàm trả Dictionary với reason
##   thay vì throw; collect() nhận roll do caller truyền để test
##   quyết định được (không truyền thì dùng randf()).
## - Signal tool_changed(tool, from_tier, to_tier) là thêm mới theo
##   quy ước Godot (JS không có event); signal sống ở runtime,
##   KHÔNG nằm trong save.
##
## Dùng: data() / from_data() là dữ liệu thuần để lưu (save G2 bước sau).

const TOOL_XE_DAY := "XeDay"
const TOOL_DEN_SOI := "DenSoi"
const TOOL_SO_TAY := "SoTay"
const TOOL_XENG := "Xeng"

const TOOL_IDS := [TOOL_XE_DAY, TOOL_DEN_SOI, TOOL_SO_TAY, TOOL_XENG]

const TIER_THO := 1
const TIER_KHA := 2
const TIER_TOT := 3

# Tên bậc có dấu — theo quy ước PxbCrafting (JS viết không dấu
# "Tho"/"Kha"/"Tot", xem KHÁC JS/C# trong header).
const TIER_NAMES := {1: "Thô", 2: "Khá", 3: "Tốt"}

# Tên hiển thị tiếng Việt của từng công cụ (chỉ để event / UI dùng).
const TOOL_NAMES := {
	"XeDay": "Xe Đẩy",
	"DenSoi": "Đèn Soi",
	"SoTay": "Sổ Tay",
	"Xeng": "Xẻng/Cuốc",
}

# --- Chi phí nâng cấp / nhận bậc 1 (PROVISIONAL — xem header) ---
#
# QUY TẮC SUY RA (PROVISIONAL, chưa chốt GDD): chi phí nâng lên bậc N
# = chi phí bậc 1 × N (bậc 2 = ×2, bậc 3 = ×3, cùng loại nguyên liệu).
# Cơ số bậc 1: Xe Đẩy / Đèn Soi lấy đúng công thức bậc 1 trong
# Crafting.cs (che-xe-day / che-den-soi); Sổ Tay / Xẻng không có công
# thức bậc 1 trong Crafting.cs nên cơ số cũng là PROVISIONAL (xem
# ACQUIRE_RECIPES). Khi GDD chốt bảng nâng cấp thì sửa đúng 2 bảng
# dưới đây, không sửa code nâng cấp.
#
# id công thức nâng cấp: "nang-cap-<tool>-<tier>".
# cost: { material_id: số lượng } — id nguyên liệu dùng chung với
# Exploration.cs (la-chuoi, van-go, khung-sat, banh-xe, vai-vun,
# chai-nhua, sat-vun).
const UPGRADE_RECIPES: Array[Dictionary] = [
	# Xe Đẩy: cơ số khung-sat 1 + banh-xe 2 + van-go 2 (che-xe-day, C#).
	{"id": "nang-cap-xe-day-2", "tool": TOOL_XE_DAY, "to_tier": TIER_KHA,
		"cost": {"khung-sat": 2, "banh-xe": 4, "van-go": 4}},
	{"id": "nang-cap-xe-day-3", "tool": TOOL_XE_DAY, "to_tier": TIER_TOT,
		"cost": {"khung-sat": 3, "banh-xe": 6, "van-go": 6}},
	# Đèn Soi: cơ số sat-vun 2 + chai-nhua 2 (che-den-soi, C#).
	{"id": "nang-cap-den-soi-2", "tool": TOOL_DEN_SOI, "to_tier": TIER_KHA,
		"cost": {"sat-vun": 4, "chai-nhua": 4}},
	{"id": "nang-cap-den-soi-3", "tool": TOOL_DEN_SOI, "to_tier": TIER_TOT,
		"cost": {"sat-vun": 6, "chai-nhua": 6}},
	# Sổ Tay: cơ số PROVISIONAL la-chuoi 2 + vai-vun 1 (xem ACQUIRE_RECIPES).
	{"id": "nang-cap-so-tay-2", "tool": TOOL_SO_TAY, "to_tier": TIER_KHA,
		"cost": {"la-chuoi": 4, "vai-vun": 2}},
	{"id": "nang-cap-so-tay-3", "tool": TOOL_SO_TAY, "to_tier": TIER_TOT,
		"cost": {"la-chuoi": 6, "vai-vun": 3}},
	# Xẻng: cơ số PROVISIONAL sat-vun 2 + van-go 1 (xem ACQUIRE_RECIPES).
	{"id": "nang-cap-xeng-2", "tool": TOOL_XENG, "to_tier": TIER_KHA,
		"cost": {"sat-vun": 4, "van-go": 2}},
	{"id": "nang-cap-xeng-3", "tool": TOOL_XENG, "to_tier": TIER_TOT,
		"cost": {"sat-vun": 6, "van-go": 3}},
]

# Công thức nhận bậc 1 cho 2 công cụ KHÔNG có công thức bậc 1 trong
# Crafting.cs — PROVISIONAL, suy theo kiểu Nadia:
#  - Sổ Tay: lá chuối làm trang (la-chuoi 2) + vải vụn làm bìa (vai-vun 1).
#  - Xẻng: đầu sắt (sat-vun 2) + cán gỗ (van-go 1), như Basic Shovel
#    của Nadia (Shovel Head + Shaft + Iron Ore) đổi sang đồ chợ Việt.
# Xe Đẩy / Đèn Soi KHÔNG có mục ở đây — bậc 1 của 2 công cụ đó phải
# chế qua PxbCrafting (che-xe-day / che-den-soi).
const ACQUIRE_RECIPES: Array[Dictionary] = [
	{"id": "che-so-tay", "tool": TOOL_SO_TAY, "to_tier": TIER_THO,
		"cost": {"la-chuoi": 2, "vai-vun": 1}},
	{"id": "che-xeng", "tool": TOOL_XENG, "to_tier": TIER_THO,
		"cost": {"sat-vun": 2, "van-go": 1}},
]

# --- Hằng hành vi (PROVISIONAL — xem header mục 3/4/5/6/7) ---

# Sức chở Xe Đẩy theo bậc: số đơn vị hàng chở được mỗi chuyến.
# PROVISIONAL — Crafting.cs / Jobs.cs không có số sức chở nào.
const CARRY_CAPACITY := {1: 5, 2: 10, 3: 20}

# Xẻng: hệ số thời gian nhặt (1,0 = tốc độ thường; càng nhỏ càng nhanh).
# PROVISIONAL — C# chỉ ghi "nhặt nhanh hơn", không có số.
const COLLECT_TIME_FACTOR := {1: 1.0, 2: 0.75, 3: 0.5}

# Xẻng bậc 2: tỉ lệ thỉnh thoảng được +1 nguyên liệu.
# PROVISIONAL — C# chỉ ghi "thỉnh thoảng", không có số.
const COLLECT_BONUS_CHANCE := 0.25

# Xẻng bậc 3: tỉ lệ nhặt được nguyên liệu hiếm (kèm +1 như bậc 2).
# PROVISIONAL — C# chỉ ghi "có cơ hội", không có số.
const RARE_FIND_CHANCE := 0.10

# Nguyên liệu hiếm Xẻng bậc 3 có thể nhặt được — id PROVISIONAL
# (Exploration.cs không có nguyên liệu hiếm nào; đổi khi GDD chốt).
const RARE_MATERIAL_ID := "da-quy"

## Phát khi nâng cấp / nhận công cụ thành công (bậc đổi thật).
## Signal sống ở runtime, KHÔNG nằm trong save.
signal tool_changed(tool: String, from_tier: int, to_tier: int)

# --- State chạy (instance) ---
# Túi nguyên liệu: { material_id: số lượng } — id dùng chung với Hotspot.
var materials: Dictionary = {}
# Bậc công cụ đang có, theo tên tool: {"XeDay": 1}.
var tools: Dictionary = {}
# Lần nâng cấp / nhận công cụ gần nhất: {tool, from_tier, to_tier} hoặc {}.
var last_upgrade: Dictionary = {}
# Trời có đang mưa không (PROVISIONAL #7 — chưa có hệ thời tiết;
# hệ thời tiết sau này gọi set_weather_raining() để cập nhật).
var weather_raining: bool = false

# Liên kết tùy chọn sang hệ khác (đúng JS: chỉ ủy quyền khi đã load).
var _crafting: PxbCrafting = null
var _hotspot: PxbHotspot = null
var _time: PxbTime = null


# --- Tra cứu bảng ---

static func upgrade_recipes() -> Array[Dictionary]:
	return UPGRADE_RECIPES.duplicate(true)


static func acquire_recipes() -> Array[Dictionary]:
	return ACQUIRE_RECIPES.duplicate(true)


static func upgrade_recipe_for(tool: String, to_tier: int) -> Dictionary:
	for r in UPGRADE_RECIPES:
		if String(r["tool"]) == tool and int(r["to_tier"]) == to_tier:
			return (r as Dictionary).duplicate(true)
	return {}


static func acquire_recipe_for(tool: String) -> Dictionary:
	for r in ACQUIRE_RECIPES:
		if String(r["tool"]) == tool:
			return (r as Dictionary).duplicate(true)
	return {}


# Tìm công thức (nâng cấp hoặc nhận bậc 1) theo id — để Sổ Tay gợi ý.
static func recipe_by_id(recipe_id: String) -> Dictionary:
	for r in UPGRADE_RECIPES:
		if String(r["id"]) == recipe_id:
			return (r as Dictionary).duplicate(true)
	for r in ACQUIRE_RECIPES:
		if String(r["id"]) == recipe_id:
			return (r as Dictionary).duplicate(true)
	return {}


static func is_valid_tool(tool: String) -> bool:
	return tool in TOOL_IDS


# Chuẩn hóa bậc: int 1/2/3, hoặc String "Tho"/"Kha"/"Tot" (không phân
# biệt hoa/thường) / "1"/"2"/"3". Lạ -> 0.
static func normalize_tier(tier) -> int:
	if tier is int:
		return tier
	if tier is float:
		return int(tier)
	if tier is String:
		var t := (tier as String).strip_edges()
		match t.to_lower():
			"tho":
				return TIER_THO
			"kha":
				return TIER_KHA
			"tot":
				return TIER_TOT
		if t.is_valid_int():
			return int(t)
	return 0


# Mô tả hành vi đổi theo bậc — đúng Crafting.ToolBehaviour, từng chữ.
# Gọi 1 đối số tool_behaviour(tool) = mô tả bậc đang có thì dùng
# tool_behaviour_current(); gọi 2 đối số = mô tả bậc đó. Bậc/tool lạ
# thì trả chuỗi mặc định.
static func tool_behaviour(tool: String, tier) -> String:
	var t := normalize_tier(tier)
	match tool + ":" + str(t):
		"XeDay:1":
			return "Chở được ít hàng, không đi được đường mưa."
		"XeDay:2":
			return "Chở được nhiều hàng hơn."
		"XeDay:3":
			return "Chở nhiều + đi được đường mưa, không bị ướt hàng."
		"DenSoi:1":
			return "Thấy hotspot thường."
		"DenSoi:2":
			return "Thấy hotspot thường + hotspot ẩn gần."
		"DenSoi:3":
			return "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày."
		"SoTay:1":
			return "NPC gợi ý chung chung."
		"SoTay:2":
			return "NPC gợi ý rõ mục tiêu + khu cần tới."
		"SoTay:3":
			return "NPC gợi ý rõ mục tiêu + khu + nguyên liệu còn thiếu."
		"Xeng:1":
			return "Nhặt được nguyên liệu thường."
		"Xeng:2":
			return "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu."
		"Xeng:3":
			return "Nhặt nhanh + có cơ hội nhặt được nguyên liệu hiếm."
	return "Chưa rõ bậc công cụ."


static func tool_name(tool: String) -> String:
	return String(TOOL_NAMES.get(tool, tool))


# --- Trừ nguyên liệu (cùng quy ước PxbCrafting.craft) ---

# Đủ nguyên liệu cho 1 bảng cost không? Không trừ đồ ở đây.
static func has_materials(cost: Dictionary, bag: Dictionary) -> bool:
	for material_id in cost:
		if int(bag.get(material_id, 0)) < int(cost[material_id]):
			return false
	return true


# Nguyên liệu còn thiếu cho 1 bảng cost: { material_id: số còn thiếu }.
static func missing_for_cost(cost: Dictionary, bag: Dictionary) -> Dictionary:
	var missing := {}
	for material_id in cost:
		var have := int(bag.get(material_id, 0))
		var needed := int(cost[material_id])
		if have < needed:
			missing[material_id] = needed - have
	return missing


# Trừ nguyên liệu TRỰC TIẾP trên túi truyền vào. Nguyên liệu nào trừ
# hết (về 0) thì XÓA key khỏi túi, không để lại entry 0 — cùng quy
# ước Crafting.cs sửa 18/11. Chỉ gọi sau khi has_materials() đã true.
static func deduct_materials(cost: Dictionary, bag: Dictionary) -> void:
	for material_id in cost:
		var con_lai := int(bag.get(material_id, 0)) - int(cost[material_id])
		if con_lai <= 0:
			bag.erase(material_id)
		else:
			bag[material_id] = con_lai


# --- Liên kết hệ khác (đúng JS: chỉ ủy quyền khi đã load) ---

# Dùng CHUNG túi nguyên liệu với PxbHotspot / PxbCrafting (Hotspot
# nhặt vào, Crafting/Tools trừ ra). Dictionary gán theo tham chiếu
# nên sau bind, materials của các hệ là một túi duy nhất.
func bind_materials(bag: Dictionary) -> void:
	materials = bag


# Nối PxbCrafting để đồng bộ bậc 2 chiều (xem header) + ủy quyền gợi
# ý cho công thức của Crafting. Chưa bind thì mỗi hệ giữ số riêng.
func bind_crafting(crafting: PxbCrafting) -> void:
	_crafting = crafting


# Nối PxbHotspot để npc_hint() ủy quyền câu gốc cho Hotspot.
# Chưa bind thì npc_hint() trả câu Sổ Tay thuần (guide_hint).
func bind_hotspot(hotspot: PxbHotspot) -> void:
	_hotspot = hotspot


# Nối PxbTime để sees_hotspot() biết khung hiện tại khi event không
# truyền rõ khung. Chưa bind thì bỏ qua kiểm tra khung.
func bind_time(time_source: PxbTime) -> void:
	_time = time_source


# Trời mưa hay không — hệ thời tiết sau này gọi để cập nhật
# (PROVISIONAL #7; mặc định không mưa).
func set_weather_raining(raining: bool) -> void:
	weather_raining = raining


# Reset bậc công cụ hiện tại (event/test dùng để bắt đầu lại).
# Chỉ reset tools + last_upgrade — túi nguyên liệu giữ nguyên (đúng JS).
func reset_state() -> bool:
	tools = {}
	last_upgrade = {}
	return true


# --- Đồng bộ với PxbCrafting (1 nguồn sự thật — xem header) ---

# Đọc bậc 1 công cụ từ PxbCrafting đã bind (nơi craft_current ghi
# khi chế bậc 1). Trả 0 khi không có / chưa bind.
func crafting_tool_tier(tool: String) -> int:
	if _crafting == null:
		return 0
	return _crafting.tool_tier(tool)


# Ghi đè (mirror) bậc công cụ sang crafting.tools để
# PxbCrafting.tool_tier() thấy cùng 1 số. Chỉ ghi khi đã bind và
# chỉ tăng, không giảm. Trả false khi chưa bind.
func mirror_to_crafting(tool: String, tier: int) -> bool:
	if _crafting == null:
		return false
	if _crafting.tool_tier(tool) < tier:
		_crafting.tools[tool] = tier
	return true


# Đồng bộ bậc từ PxbCrafting sang tools: lấy max 2 bên cho từng
# công cụ (chế bậc 1 ở Crafting thì Tools cũng thấy). Trả true khi
# có ít nhất 1 bậc được đồng bộ lên.
func sync_from_crafting() -> bool:
	if _crafting == null:
		return false
	var changed := false
	for tool in TOOL_IDS:
		var from_crafting := crafting_tool_tier(tool)
		if from_crafting > int(tools.get(tool, 0)):
			tools[tool] = from_crafting
			changed = true
	return changed


# --- Công cụ đang có ---

# Bậc công cụ đang có (0 = chưa có công cụ này). Đồng bộ từ
# PxbCrafting trước khi đọc để không lệch với bản chế ở đó.
func tool_tier(tool: String) -> int:
	if not is_valid_tool(tool):
		return 0
	sync_from_crafting()
	return int(tools.get(tool, 0))


func has_tool(tool: String) -> bool:
	return tool_tier(tool) > 0


# Mô tả hành vi của bậc công cụ đang có; chưa có tool thì trả chuỗi
# mặc định (cùng ToolBehaviour với bậc lạ).
func tool_behaviour_current(tool: String) -> String:
	return tool_behaviour(tool, tool_tier(tool))


# --- Nâng cấp bậc 2/3 ---

# Chi phí nâng công cụ lên bậc đích (2 hoặc 3). Trả bản sao cost hoặc
# {} khi tool/bậc không hợp lệ (tool lạ, đích không phải 2/3).
static func upgrade_cost(tool: String, to_tier) -> Dictionary:
	var t := normalize_tier(to_tier)
	if not is_valid_tool(tool) or (t != TIER_KHA and t != TIER_TOT):
		return {}
	var recipe := upgrade_recipe_for(tool, t)
	if recipe.is_empty():
		return {}
	return (recipe["cost"] as Dictionary).duplicate()


# Nguyên liệu còn thiếu để nâng lên bậc tiếp theo. Truyền bag để test
# với túi riêng; không truyền thì dùng túi chung. Công cụ lạ / chưa
# có / đã max thì {}.
func missing_for_upgrade(tool: String, bag = null) -> Dictionary:
	var cur := tool_tier(tool)
	if not is_valid_tool(tool) or cur <= 0 or cur >= TIER_TOT:
		return {}
	var cost := upgrade_cost(tool, cur + 1)
	if cost.is_empty():
		return {}
	var b: Dictionary = materials if bag == null else bag
	return missing_for_cost(cost, b)


# Có nâng được công cụ lên bậc tiếp theo không? (dùng túi chung mặc
# định; truyền bag để test với túi riêng). Trả:
#   {ok:true, tool, from_tier, to_tier, cost, missing:{}}
#   {ok:false, reason:"cong-cu-la"}
#   {ok:false, reason:"chua-co-cong-cu", to_tier:1} — chưa có bậc 1,
#     phải chế/nhận bậc 1 trước (Xe Đẩy/Đèn Soi qua PxbCrafting,
#     Sổ Tay/Xẻng qua acquire())
#   {ok:false, reason:"da-max", tier:3}
#   {ok:false, reason:"thieu-nguyen-lieu", missing:{...}, cost}
func can_upgrade(tool: String, bag = null) -> Dictionary:
	if not is_valid_tool(tool):
		return {"ok": false, "reason": "cong-cu-la"}
	var cur := tool_tier(tool)
	if cur <= 0:
		return {"ok": false, "reason": "chua-co-cong-cu", "to_tier": TIER_THO}
	if cur >= TIER_TOT:
		return {"ok": false, "reason": "da-max", "tier": cur}
	var next := cur + 1
	var cost := upgrade_cost(tool, next)
	var b: Dictionary = materials if bag == null else bag
	if not has_materials(cost, b):
		return {"ok": false, "reason": "thieu-nguyen-lieu", "to_tier": next,
			"cost": cost, "missing": missing_for_cost(cost, b)}
	return {"ok": true, "tool": tool, "from_tier": cur, "to_tier": next,
		"cost": cost, "missing": {}}


# Nâng công cụ lên 1 bậc: trừ nguyên liệu túi chung, tăng bậc, ghi
# đè sang crafting, lưu last_upgrade, phát tool_changed. Trả như
# can_upgrade(), thêm ok:true khi xong. Thất bại thì KHÔNG trừ gì,
# KHÔNG đổi bậc.
func upgrade(tool: String, bag = null) -> Dictionary:
	var check := can_upgrade(tool, bag)
	if not bool(check.get("ok", false)):
		return check
	var b: Dictionary = materials if bag == null else bag
	deduct_materials(check["cost"], b)
	var from_tier := int(check["from_tier"])
	var to_tier := int(check["to_tier"])
	tools[tool] = to_tier
	last_upgrade = {"tool": tool, "from_tier": from_tier, "to_tier": to_tier}
	mirror_to_crafting(tool, to_tier)
	tool_changed.emit(tool, from_tier, to_tier)
	return {"ok": true, "tool": tool, "from_tier": from_tier,
		"to_tier": to_tier, "cost": check["cost"], "missing": {}}


# --- Nhận bậc 1 Sổ Tay / Xẻng (PROVISIONAL — xem header) ---

# Có nhận được bậc 1 không? Xe Đẩy / Đèn Soi trả reason
# "dung-che-tao" (bậc 1 của 2 công cụ đó chỉ chế qua PxbCrafting).
# Trả cùng dạng can_upgrade().
func can_acquire(tool: String, bag = null) -> Dictionary:
	if not is_valid_tool(tool):
		return {"ok": false, "reason": "cong-cu-la"}
	if tool_tier(tool) > 0:
		return {"ok": false, "reason": "da-co-cong-cu", "tier": tool_tier(tool)}
	var recipe := acquire_recipe_for(tool)
	if recipe.is_empty():
		return {"ok": false, "reason": "dung-che-tao",
			"recipe_id": "che-xe-day" if tool == TOOL_XE_DAY else "che-den-soi"}
	var b: Dictionary = materials if bag == null else bag
	if not has_materials(recipe["cost"], b):
		return {"ok": false, "reason": "thieu-nguyen-lieu", "to_tier": TIER_THO,
			"cost": recipe["cost"], "missing": missing_for_cost(recipe["cost"], b)}
	return {"ok": true, "tool": tool, "from_tier": 0, "to_tier": TIER_THO,
		"cost": recipe["cost"], "missing": {}}


# Nhận bậc 1 Sổ Tay / Xẻng: trừ nguyên liệu túi chung, đặt bậc 1,
# ghi đè sang crafting, phát tool_changed. Thất bại thì KHÔNG trừ gì.
func acquire(tool: String, bag = null) -> Dictionary:
	var check := can_acquire(tool, bag)
	if not bool(check.get("ok", false)):
		return check
	var b: Dictionary = materials if bag == null else bag
	deduct_materials(check["cost"], b)
	tools[tool] = TIER_THO
	last_upgrade = {"tool": tool, "from_tier": 0, "to_tier": TIER_THO}
	mirror_to_crafting(tool, TIER_THO)
	tool_changed.emit(tool, 0, TIER_THO)
	return {"ok": true, "tool": tool, "from_tier": 0,
		"to_tier": TIER_THO, "cost": check["cost"], "missing": {}}


# --- Xe Đẩy: sức chở + đường mưa (móc PxbJobs) ---

# Sức chở theo BẬC (số đơn vị hàng mỗi chuyến). Bậc lạ/0 -> 0.
# PROVISIONAL — xem CARRY_CAPACITY.
static func carry_capacity(tier) -> int:
	var t := normalize_tier(tier)
	return int(CARRY_CAPACITY.get(t, 0))


# Sức chở của Xe Đẩy ĐANG CÓ (chưa có Xe Đẩy -> 0).
func cart_capacity_current() -> int:
	return carry_capacity(tool_tier(TOOL_XE_DAY))


# Trời mưa: chỉ Xe Đẩy bậc 3 đi được, không ướt hàng.
# is_raining: true/false do event truyền vào; không truyền thì đọc
# weather_raining (PROVISIONAL #7), mặc định coi như không mưa.
# Trả {can_travel, wet_goods, tier, reason}:
#   không mưa -> đi được, hàng khô; mưa + bậc 3 -> đi được, hàng khô;
#   mưa + bậc < 3 -> KHÔNG đi được (hàng ướt nếu cố đi).
func cart_can_travel(is_raining = null) -> Dictionary:
	var raining: bool = weather_raining if is_raining == null else bool(is_raining)
	var tier := tool_tier(TOOL_XE_DAY)
	if not raining:
		return {"can_travel": true, "wet_goods": false, "tier": tier,
			"reason": "khong-mua"}
	if tier >= TIER_TOT:
		return {"can_travel": true, "wet_goods": false, "tier": tier,
			"reason": "xe-day-bac-3-di-duoc-duong-mua"}
	return {"can_travel": false, "wet_goods": true, "tier": tier,
		"reason": "xe-day-chua-du-bac-di-duong-mua"}


# Xe Đẩy chở nổi chừng này đơn vị hàng không? (event làm ca shipper /
# bán rong gọi trước khi nhận đơn). Trả {ok, units, capacity, tier}:
#   ok=false khi chưa có Xe Đẩy hoặc đơn hàng vượt sức chở.
func carry_check(units: int) -> Dictionary:
	var capacity := cart_capacity_current()
	var tier := tool_tier(TOOL_XE_DAY)
	return {"ok": capacity > 0 and units <= capacity,
		"units": units, "capacity": capacity, "tier": tier}


# --- Đèn Soi: thấy hotspot ẩn / hiếm (móc PxbHotspot) ---

# Đèn Soi có thấy hotspot này không?
# hotspot: {hidden:bool, rarity:"thuong"|"hiem", near:bool,
#   best_frame:"Sáng"|"Chiều"|"Tối" (tùy chọn), district_id (tùy chọn)}.
# frame_name: khung hiện tại ("Sáng"/"Chiều"/"Tối", tùy chọn — event
# truyền rõ khi PxbTime chưa bind; không truyền thì đọc PxbTime khi
# đã bind, chưa bind thì bỏ qua kiểm tra khung).
#  - Hotspot thường (không ẩn, không hiếm): thấy bằng mắt thường,
#    không cần Đèn Soi (PxbHotspot vốn nhặt được không cần công cụ).
#  - Hotspot hiếm: chỉ Đèn Soi bậc 3 thấy, và chỉ đúng khung nó
#    xuất hiện (1 khung/ngày — ToolBehaviour DenSoi:3).
#  - Hotspot ẩn (không hiếm): bậc 1 không thấy; bậc 2 chỉ thấy khi
#    GẦN (near == true); bậc 3 thấy mọi hotspot ẩn.
#  - Hotspot có best_frame mà sai khung hiện tại: chưa xuất hiện nên
#    không thấy (kiểm tra này chỉ chạy khi biết rõ cả 2 khung).
# PROVISIONAL: "gần" = hotspot.near (C# không định nghĩa gần/xa).
func sees_hotspot(hotspot: Dictionary, frame_name: String = "") -> bool:
	if hotspot.is_empty():
		return false
	var frame := frame_name if frame_name != "" else current_frame_name()
	var best := String(hotspot.get("best_frame", ""))
	if best != "" and frame != "" and best != frame:
		return false
	var tier := tool_tier(TOOL_DEN_SOI)
	if String(hotspot.get("rarity", "thuong")) == "hiem":
		return tier >= TIER_TOT
	if not bool(hotspot.get("hidden", false)):
		return true
	if tier >= TIER_TOT:
		return true
	if tier >= TIER_KHA:
		return bool(hotspot.get("near", false))
	return false


# Lọc danh sách hotspot thành những hotspot Đèn Soi thấy được ở khung
# hiện tại (đường dùng khi PxbHotspot liệt kê hotspot trong khu).
func visible_hotspots(list: Array, frame_name: String = "") -> Array:
	var out: Array = []
	for h in list:
		if h is Dictionary and sees_hotspot(h, frame_name):
			out.append(h)
	return out


# Khung hiện tại ("Sáng"/"Chiều"/"Tối") qua PxbTime khi đã bind.
# Chưa bind PxbTime thì trả "" — caller bỏ qua kiểm tra khung.
func current_frame_name() -> String:
	if _time == null:
		return ""
	return PxbTime.frame_name(_time.elapsed_minutes())


# --- Sổ Tay: gợi ý theo bậc (móc PxbCrafting / PxbHotspot) ---

# Mức chi tiết gợi ý của Sổ Tay đang có: 0 = chưa có Sổ Tay,
# 1 = chung chung, 2 = mục tiêu + khu, 3 = + nguyên liệu thiếu
# (đúng ToolBehaviour SoTay 1/2/3).
func hint_level() -> int:
	return tool_tier(TOOL_SO_TAY)


# Gợi ý Sổ Tay cho 1 công thức (chế tạo / nâng cấp / nhận công cụ):
#  - Bậc 3: liệt kê nguyên liệu còn thiếu (công thức của riêng file
#    này thì tự tính thiếu từ bảng cost; công thức của PxbCrafting
#    thì ủy quyền cho PxbCrafting.guide_hint_for_recipe khi đã bind).
#  - Bậc 2: chỉ tên món + khu cần tới (không liệt kê thiếu từng món).
#  - Bậc 1 trở xuống: câu chung chung, không spoil đáp án.
# recipe_id lạ (không phải công thức Crafting lẫn Tools) -> chuỗi mặc
# định (cùng ToolBehaviour với bậc lạ).
func guide_hint_for_recipe(recipe_id: String) -> String:
	var level := hint_level()
	if level <= 0:
		return "Chưa có Sổ Tay — hỏi NPC trong khu xem cần làm gì trước đã."
	var local := recipe_by_id(recipe_id)
	if not local.is_empty():
		var tool := String(local["tool"])
		var to_tier := int(local["to_tier"])
		if level >= TIER_TOT:
			var missing := missing_for_cost(local["cost"], materials)
			if missing.is_empty():
				return "Đủ đồ nâng " + tool_name(tool) + " lên bậc " + \
					String(TIER_NAMES[to_tier]) + " rồi — ghé Góc Chế Tạo làm ngay đi."
			var parts: Array = []
			for material_id in missing:
				parts.append(str(material_id) + " còn thiếu " + str(missing[material_id]))
			return "Để nâng " + tool_name(tool) + " lên bậc " + \
				String(TIER_NAMES[to_tier]) + " còn thiếu: " + ", ".join(parts) + "."
		if level >= TIER_KHA:
			return "Muốn nâng " + tool_name(tool) + " lên bậc " + \
				String(TIER_NAMES[to_tier]) + " thì ghé Góc Chế Tạo coi lại túi đồ."
		return "Cứ ghé Góc Chế Tạo hỏi thử — có món nâng được công cụ đó."
	# Công thức của PxbCrafting (che-xe-day / che-den-soi / che-qua-tang):
	# ủy quyền cho Crafting khi đã bind, để 1 chỗ tính thiếu.
	if _crafting != null:
		var hint := _crafting.guide_hint_for_recipe(recipe_id)
		if level >= TIER_TOT:
			return hint
		if level >= TIER_KHA:
			return "Muốn chế món đó thì ghé Góc Chế Tạo coi lại túi đồ."
		return "Cứ ghé Góc Chế Tạo hỏi thử — có món chế được đó."
	return "Chưa rõ bậc công cụ."


# Gợi ý Sổ Tay cho mục tiêu hiện tại của người chơi:
#  - Bậc 1: gợi ý chung chung (chỉ nhắc mục tiêu).
#  - Bậc 2: thêm khu cần tới (district_id — số khu, không hardcode
#    tên khu ở đây; tên khu xem docs/districts.md).
#  - Bậc 3: thêm nguyên liệu còn thiếu của công thức recipe_id (khi
#    có recipe_id); không có recipe_id thì như bậc 2.
#  - Chưa có Sổ Tay: câu chung chung nhất, khuyên hỏi NPC.
# goal rỗng -> "chưa có mục tiêu rõ".
func guide_hint(goal: String, district_id: int, recipe_id: String = "") -> String:
	var level := hint_level()
	var g := goal if goal.strip_edges() != "" else "chưa có mục tiêu rõ"
	if level <= 0:
		return "Chưa có Sổ Tay — mục tiêu hiện tại: " + g + \
			". Hỏi NPC trong khu xem cần làm gì trước đã."
	if level >= TIER_TOT and recipe_id != "":
		return "Mục tiêu: " + g + ". Cần tới khu " + str(district_id) + ". " + \
			guide_hint_for_recipe(recipe_id)
	if level >= TIER_KHA:
		return "Mục tiêu: " + g + ". Cần tới khu " + str(district_id) + \
			" — tới đó rồi hỏi NPC trong khu."
	return "Mục tiêu hiện tại: " + g + \
		". Cứ đi loanh quanh hỏi NPC trong khu xem sao."


# Gợi ý NPC dẫn đường, chi tiết theo bậc Sổ Tay: ủy quyền câu gốc
# cho PxbHotspot.guide_hint(district_id, goal) khi đã bind hotspot;
# bậc 2/3 thì nối thêm khu + nguyên liệu thiếu (khi có recipe_id).
# Chưa bind PxbHotspot thì trả câu Sổ Tay thuần (guide_hint).
func npc_hint(district_id: int, goal: String, recipe_id: String = "") -> String:
	if _hotspot == null:
		return guide_hint(goal, district_id, recipe_id)
	var base: String = PxbHotspot.guide_hint(district_id, goal)
	var level := hint_level()
	if level >= TIER_TOT and recipe_id != "":
		return base + " " + guide_hint_for_recipe(recipe_id)
	if level >= TIER_KHA:
		return base + " (Sổ Tay: mục tiêu này cần tới khu " + str(district_id) + ".)"
	return base


# --- Xẻng/Cuốc: nhặt nhanh + thêm đồ / hiếm (móc PxbHotspot) ---

# Tính lượng nhặt được với Xẻng bậc tier (số, không cần state):
# base_amount = lượng hotspot cho mỗi lần nhặt (vd 2).
# roll: số 0..1 do caller truyền (để test quyết định được) — không
# truyền (roll < 0) thì dùng randf(). Trả:
#   {amount, bonus, rare_found, rare_material_id, time_factor}
#   amount = base_amount + bonus (bonus 0/1).
#  - Bậc 1: amount = base_amount, không bonus, không hiếm, chậm nhất.
#  - Bậc 2: nhanh hơn (0,75); roll < 25% (PROVISIONAL) thì +1.
#  - Bậc 3: nhanh nhất (0,5); roll < 25% thì +1; roll < 10%
#    (PROVISIONAL) thì thêm nguyên liệu hiếm (rare_found, id "da-quy").
# Bậc lạ/0: coi như bậc 1 (nhặt thường, không bonus).
static func collect_yield(base_amount: int, tier, roll: float = -1.0) -> Dictionary:
	var t := normalize_tier(tier)
	if t < TIER_THO or t > TIER_TOT:
		t = TIER_THO
	var r := randf() if roll < 0.0 else roll
	var bonus := 0
	var rare_found := false
	if t >= TIER_KHA and r < COLLECT_BONUS_CHANCE:
		bonus = 1
	if t >= TIER_TOT and r < RARE_FIND_CHANCE:
		rare_found = true
	return {
		"amount": base_amount + bonus,
		"bonus": bonus,
		"rare_found": rare_found,
		"rare_material_id": RARE_MATERIAL_ID if rare_found else "",
		"time_factor": float(COLLECT_TIME_FACTOR[t]),
	}


# Nhặt nguyên liệu với Xẻng ĐANG CÓ: cộng amount (+bonus) vào túi
# chung, cộng 1 nguyên liệu hiếm khi rare_found. Trả kết quả
# collect_yield() kèm material_id. (Đường dùng sau khi PxbHotspot
# cho nhặt hotspot — lượng cơ bản base_amount lấy từ hotspot.)
func collect(material_id: String, base_amount: int, roll: float = -1.0) -> Dictionary:
	var y := collect_yield(base_amount, tool_tier(TOOL_XENG), roll)
	materials[material_id] = int(materials.get(material_id, 0)) + int(y["amount"])
	if bool(y["rare_found"]):
		materials[String(y["rare_material_id"])] = \
			int(materials.get(String(y["rare_material_id"]), 0)) + 1
	return {
		"material_id": material_id,
		"amount": y["amount"],
		"bonus": y["bonus"],
		"rare_found": y["rare_found"],
		"rare_material_id": y["rare_material_id"],
		"time_factor": y["time_factor"],
	}


# --- Lưu / tải (dữ liệu thuần, JSON-safe) ---

static func default_data() -> Dictionary:
	return {"materials": {}, "tools": {}, "last_upgrade": {}}


func data() -> Dictionary:
	return {
		"materials": materials.duplicate(),
		"tools": tools.duplicate(),
		"last_upgrade": last_upgrade.duplicate(),
	}


# Khôi phục từ data(); dữ liệu bẩn bị bỏ: công cụ lạ, bậc < 1 (bỏ),
# bậc > 3 (kẹp về 3 — đúng JS khi load save cũ), nguyên liệu âm /
# bằng 0 / không phải số, last_upgrade có tool/bậc lạ.
static func from_data(d: Dictionary) -> PxbTools:
	var t := PxbTools.new()
	var raw_mat = d.get("materials", {})
	if raw_mat is Dictionary:
		for k in raw_mat:
			var v = raw_mat[k]
			if (v is int or v is float) and int(v) > 0:
				t.materials[String(k)] = int(v)
	var raw_tools = d.get("tools", {})
	if raw_tools is Dictionary:
		for k in raw_tools:
			var tk := String(k)
			if tk in TOOL_IDS:
				var v = raw_tools[k]
				var tier := int(v) if (v is int or v is float) else 0
				if tier >= TIER_THO:
					t.tools[tk] = mini(tier, TIER_TOT)
	var lu = d.get("last_upgrade", {})
	if lu is Dictionary and not (lu as Dictionary).is_empty():
		var ltool := String((lu as Dictionary).get("tool", ""))
		var lfrom = (lu as Dictionary).get("from_tier", -1)
		var lto = (lu as Dictionary).get("to_tier", -1)
		if ltool in TOOL_IDS \
			and (lfrom is int or lfrom is float) \
			and (lto is int or lto is float) \
			and int(lfrom) >= 0 and int(lfrom) <= TIER_TOT \
			and int(lto) >= TIER_THO and int(lto) <= TIER_TOT:
			t.last_upgrade = {"tool": ltool, "from_tier": int(lfrom), "to_tier": int(lto)}
	return t
