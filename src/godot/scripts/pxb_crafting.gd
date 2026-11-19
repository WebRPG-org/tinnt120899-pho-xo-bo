class_name PxbCrafting
extends Node
## Phố Xô Bồ — PXB_Crafting (Godot G2, bước 3/17).
## Port trung thực PXB_Crafting.js / Crafting.cs
## (src/nadia/www/js/plugins/PXB_Crafting.js,
##  src/client/Assets/Scripts/Crafting.cs).
##
## - 3 công thức slice (PROVISIONAL, chưa chốt GDD — số lấy từ
##   Crafting.cs, KHÔNG lấy số web cũ): Xe Đẩy Hàng = Khung Sắt 1 +
##   Bánh Xe 2 + Ván Gỗ 2 -> "tool:XeDay:1"; Đèn Soi = Sắt Vụn 2 +
##   Chai Nhựa 2 -> "tool:DenSoi:1"; Quà Tặng Thủ Công = Lá Chuối 2 +
##   Vải Vụn 1 -> "item:qua-tang". Công thức lấy từ PxbBalance.RECIPES.
## - 4 công cụ × 3 bậc, mỗi combo có mô tả hành vi riêng (không chỉ
##   +số): Xe Đẩy / Đèn Soi / Sổ Tay / Xẻng — tool_behaviour() từng chữ
##   đúng Crafting.ToolBehaviour. Bậc/tool lạ trả "Chưa rõ bậc công cụ."
## - can_craft() chỉ kiểm tra, không trừ đồ. craft() trừ trực tiếp
##   trên túi truyền vào; nguyên liệu nào chế hết (về 0) thì XÓA key
##   khỏi túi, không để lại entry 0 (hành vi đã sửa 18/11).
## - missing_ingredients() trả số còn thiếu từng loại (để Sổ Tay gợi ý).
## - Công thức học qua chơi / NPC dạy (C# chỉ ghi UnlockNote bằng chữ,
##   không có cơ chế "đã học"): learned_recipes — mặc định chưa học
##   công thức nào; NPC/event gọi learn_recipe(id) để dạy (vd Cô Tư
##   dạy "che-xe-day" sau quest đầu). craft_current() chặn khi chưa
##   học (reason "chua-hoc-cong-thuc").
## - Túi nguyên liệu dùng CHUNG với PxbHotspot (Hotspot nhặt vào,
##   Crafting trừ ra — như JS $gameSystem.pxbMaterials): gọi
##   bind_materials(hotspot.materials) để hai hệ cùng giữ MỘT túi
##   (Dictionary gán theo tham chiếu). Chưa bind thì craft_current()
##   dùng túi riêng materials của instance này.
## - ResultId "item:qua-tang" chưa có Item tương ứng trong data
##   Items.json nên chưa cộng vào túi đồ người chơi; chỉ đếm số quà
##   đã chế trong crafted_items (PROVISIONAL — chờ Items.json có mục
##   quà tặng thì nối PxbInventory.add).
## - Chỉ có công thức bậc 1. ToolBehaviour có mô tả bậc 2 (Khá) và 3
##   (Tốt) nhưng CHƯA có công thức nào chế ra tool bậc 2/3 — Crafting.cs
##   cũng vậy. Công thức nâng cấp công cụ là việc của PXB_Tools /
##   GDD chưa chốt.
## - Chế tạo là "cổng tiến trình" (không chế được thì không mở khu
##   tiếp) nhưng Crafting.cs không có code mở khu nào. File này chỉ
##   ghi nhận tool đã chế (state.tools); việc mở khu do PxbStory /
##   PxbHotspot giữ (unlocked_districts) — chưa nối.
##
## KHÁC JS/C#: GDScript không có exception — craft() trả "" thay vì
## null khi công thức không có / thiếu nguyên liệu; craft_current()
## trả Dictionary với reason thay vì throw.
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

const TIER_NAMES := {1: "Thô", 2: "Khá", 3: "Tốt"}

# Tên sản phẩm theo ResultId (PxbBalance.RECIPES chỉ giữ needs/result/
# unlock; tên hiển thị lấy ở đây — đúng PXB_Crafting.js FALLBACK_RECIPES).
const RESULT_NAMES := {
	"tool:XeDay:1": "Xe Đẩy Hàng",
	"tool:DenSoi:1": "Đèn Soi",
	"item:qua-tang": "Quà Tặng Thủ Công",
}

# --- State chạy (instance) ---
# Túi nguyên liệu: { material_id: số lượng } — id dùng chung với Hotspot.
var materials: Dictionary = {}
# Bậc công cụ đang có, theo tên tool: {"XeDay": 1}.
var tools: Dictionary = {}
# Công thức đã học, theo id -> true (mặc định chưa học công thức nào).
var learned_recipes: Dictionary = {}
# Số vật phẩm đã chế, theo id: {"qua-tang": 2}.
var crafted_items: Dictionary = {}
# Lần chế gần nhất: {recipe_id, result_id} hoặc {}.
var last_craft: Dictionary = {}


# --- Tra cứu bảng (đọc từ PxbBalance, không hardcode) ---

static func recipe_list() -> Array:
	return PxbBalance.RECIPES.duplicate(true)


static func get_recipe(recipe_id: String) -> Dictionary:
	return PxbBalance.recipe_by_id(recipe_id)


static func result_name(result_id: String) -> String:
	return String(RESULT_NAMES.get(result_id, ""))


# --- Công cụ: mô tả hành vi theo bậc ---

# Chuẩn hóa bậc: int 1/2/3, hoặc String "Tho"/"Kha"/"Tot" (không phân
# biệt hoa/thường) / "1"/"2"/"3". Lạ -> 0.
static func normalize_tier(tier) -> int:
	if tier is int:
		return tier
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
# Bậc/tool lạ thì trả chuỗi mặc định.
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


# --- Logic thuần (port trung thực Crafting.cs) ---

# Nhận recipe Dictionary hoặc id String ("che-xe-day"); id lạ -> {}.
static func resolve_recipe(recipe_or_id) -> Dictionary:
	if recipe_or_id is String:
		return get_recipe(recipe_or_id)
	if recipe_or_id is Dictionary:
		return recipe_or_id
	return {}


# Đủ nguyên liệu để chế không? Không trừ đồ ở đây.
static func can_craft(recipe_or_id, bag: Dictionary) -> bool:
	var recipe := resolve_recipe(recipe_or_id)
	if recipe.is_empty():
		return false
	for material_id in (recipe["needs"] as Dictionary):
		if int(bag.get(material_id, 0)) < int((recipe["needs"] as Dictionary)[material_id]):
			return false
	return true


# Chế 1 món: trừ nguyên liệu TRỰC TIẾP trên túi truyền vào, trả về
# ResultId. Trả "" nếu công thức không có hoặc thiếu nguyên liệu (khi
# đó không trừ gì). Nguyên liệu nào chế hết (về 0) thì XÓA key khỏi
# túi, không để lại entry 0 — sửa 18/11.
static func craft(recipe_or_id, bag: Dictionary) -> String:
	var recipe := resolve_recipe(recipe_or_id)
	if recipe.is_empty():
		return ""
	if not can_craft(recipe, bag):
		return ""
	for material_id in (recipe["needs"] as Dictionary):
		var con_lai := int(bag.get(material_id, 0)) - int((recipe["needs"] as Dictionary)[material_id])
		# Chế hết loại này thì xóa key khỏi túi, không để lại entry 0.
		if con_lai <= 0:
			bag.erase(material_id)
		else:
			bag[material_id] = con_lai
	return String(recipe["result"])


# Nguyên liệu còn thiếu để chế 1 công thức (để Sổ Tay gợi ý).
# Trả Dictionary { material_id: số còn thiếu }; đủ thì Dictionary rỗng.
static func missing_ingredients(recipe_or_id, bag: Dictionary) -> Dictionary:
	var recipe := resolve_recipe(recipe_or_id)
	var missing := {}
	if recipe.is_empty():
		return missing
	for material_id in (recipe["needs"] as Dictionary):
		var have := int(bag.get(material_id, 0))
		var needed := int((recipe["needs"] as Dictionary)[material_id])
		if have < needed:
			missing[material_id] = needed - have
	return missing


# --- Học công thức (NPC dạy / làm quest) ---

func learn_recipe(recipe_id: String) -> bool:
	if get_recipe(recipe_id).is_empty():
		return false
	learned_recipes[recipe_id] = true
	return true


func has_learned(recipe_id: String) -> bool:
	return bool(learned_recipes.get(recipe_id, false))


func known_recipes() -> Array:
	var known: Array = []
	for r in recipe_list():
		if has_learned(String((r as Dictionary)["id"])):
			known.append(r)
	return known


# --- Công cụ đang có ---

# Bậc công cụ đang có (0 = chưa chế được tool này).
func tool_tier(tool: String) -> int:
	return int(tools.get(tool, 0))


func has_tool(tool: String) -> bool:
	return tool_tier(tool) > 0


# Mô tả hành vi của bậc công cụ đang có; chưa có tool thì trả chuỗi
# mặc định (cùng ToolBehaviour với bậc lạ).
func tool_behaviour_current(tool: String) -> String:
	return tool_behaviour(tool, tool_tier(tool))


# Ghi nhận kết quả chế: "tool:XeDay:1" -> tools.XeDay = 1 (chỉ tăng,
# không giảm khi chế lại bậc thấp); "item:qua-tang" -> đếm quà đã chế.
# Trả {kind:"tool"|"item", tool, tier, item_id} hoặc {} khi parse lỗi.
func apply_result(result_id: String) -> Dictionary:
	var parts := result_id.split(":")
	if parts.size() == 3 and parts[0] == "tool":
		var tool := parts[1]
		var tier := int(parts[2]) if parts[2].is_valid_int() else 0
		if tool not in TOOL_IDS or tier < TIER_THO or tier > TIER_TOT:
			return {}
		if tool_tier(tool) < tier:
			tools[tool] = tier
		return {"kind": "tool", "tool": tool, "tier": tier, "item_id": ""}
	if parts.size() == 2 and parts[0] == "item":
		var item_id := parts[1]
		if item_id == "":
			return {}
		crafted_items[item_id] = int(crafted_items.get(item_id, 0)) + 1
		return {"kind": "item", "tool": "", "tier": 0, "item_id": item_id}
	return {}


# --- Chế từ túi chung (đường dùng trong event) ---

# Dùng CHUNG túi nguyên liệu với PxbHotspot (Hotspot nhặt vào,
# Crafting trừ ra). Dictionary gán theo tham chiếu nên sau bind,
# materials của hai hệ là một túi duy nhất.
func bind_materials(bag: Dictionary) -> void:
	materials = bag


func can_craft_current(recipe_id: String) -> bool:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	return can_craft(recipe, materials)


# Chế 1 món từ túi nguyên liệu chung. Trả:
#   {ok:true, recipe_id, result_id, result_name, applied, missing:{}}
#   {ok:false, reason:"khong-co-cong-thuc"}
#   {ok:false, reason:"chua-hoc-cong-thuc", unlock_note}
#   {ok:false, reason:"thieu-nguyen-lieu", missing:{...}}
# applied: kết quả apply_result() (tool đã lên bậc / quà đã đếm).
func craft_current(recipe_id: String) -> Dictionary:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty():
		return {"ok": false, "reason": "khong-co-cong-thuc"}
	if not has_learned(recipe_id):
		return {"ok": false, "reason": "chua-hoc-cong-thuc",
			"unlock_note": String(recipe.get("unlock", ""))}
	if not can_craft(recipe, materials):
		return {"ok": false, "reason": "thieu-nguyen-lieu",
			"missing": missing_ingredients(recipe, materials)}
	var result_id := craft(recipe, materials)
	var applied := apply_result(result_id)
	last_craft = {"recipe_id": recipe_id, "result_id": result_id}
	return {"ok": true, "recipe_id": recipe_id, "result_id": result_id,
		"result_name": result_name(result_id), "applied": applied, "missing": {}}


# Gợi ý Sổ Tay cho 1 công thức: liệt kê nguyên liệu còn thiếu.
# Dùng khi Sổ Tay bậc Tốt (gợi ý cả nguyên liệu còn thiếu); bậc thấp
# hơn thì event tự rút gọn câu trả lời. Công thức lạ -> chuỗi mặc định.
func guide_hint_for_recipe(recipe_id: String) -> String:
	var recipe := get_recipe(recipe_id)
	if recipe.is_empty():
		return "Chưa rõ bậc công cụ."
	var missing := missing_ingredients(recipe, materials)
	if missing.is_empty():
		return "Đủ đồ chế " + result_name(String(recipe["result"])) + " rồi — ghé Góc Chế Tạo làm ngay đi."
	var parts: Array = []
	for material_id in missing:
		parts.append(str(material_id) + " còn thiếu " + str(missing[material_id]))
	return "Để chế " + result_name(String(recipe["result"])) + " còn thiếu: " + ", ".join(parts) + "."


# --- Dữ liệu thuần để lưu (save G2 bước sau) ---

func data() -> Dictionary:
	return {
		"materials": materials.duplicate(),
		"tools": tools.duplicate(),
		"learned_recipes": learned_recipes.duplicate(),
		"crafted_items": crafted_items.duplicate(),
		"last_craft": last_craft.duplicate(),
	}


static func from_data(d: Dictionary) -> PxbCrafting:
	var c := PxbCrafting.new()
	for k in (d.get("materials", {}) as Dictionary):
		c.materials[String(k)] = int((d["materials"] as Dictionary)[k])
	for k in (d.get("tools", {}) as Dictionary):
		var tier := int((d["tools"] as Dictionary)[k])
		if String(k) in TOOL_IDS and tier >= TIER_THO and tier <= TIER_TOT:
			c.tools[String(k)] = tier
	for recipe_id in d.get("learned_recipes", {}):
		if not get_recipe(String(recipe_id)).is_empty():
			c.learned_recipes[String(recipe_id)] = true
	for k in (d.get("crafted_items", {}) as Dictionary):
		c.crafted_items[String(k)] = int((d["crafted_items"] as Dictionary)[k])
	var lc := d.get("last_craft", {}) as Dictionary
	if not lc.is_empty() and not get_recipe(String(lc.get("recipe_id", ""))).is_empty():
		c.last_craft = lc.duplicate()
	return c
