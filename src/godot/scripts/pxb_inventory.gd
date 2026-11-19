class_name PxbInventory
extends Node
## Phố Xô Bồ — PXB_Inventory (Godot G2, bước 3/17).
## Port trung thực Inventory.cs (src/client/Assets/Scripts/Inventory.cs).
## Không có plugin PXB_Inventory.js ở bản MV — túi đồ MV dùng $gameParty
## + túi nguyên liệu $gameSystem.pxbMaterials (PXB_Hotspot.js); nguồn
## duy nhất cho túi đồ slice là Inventory.cs dưới đây.
##
## - 4 vật phẩm slice (PROVISIONAL — giá + buff là số ví dụ, chưa chốt
##   GDD; khi GDD chốt bảng vật phẩm thì sửa đúng PxbBalance.ITEMS,
##   không sửa code túi đồ): Cơm tấm 35k (Thể +5, khung Chiều), Cà phê
##   25k (Trí +5, khung Sáng), Sách 80k (Trí +5, khung Tối), Áo mưa
##   120k (không xếp chồng, không buff, mở điều kiện "Làm được ca mưa").
## - Vật phẩm tiêu hao chỉ cho BUFF TẠM trong 1 khung (xem Buff), KHÔNG
##   đổi chỉ số vĩnh viễn — nên không phá trần tổng của PxbStats.
## - Đồ không xếp chồng: chỉ giữ đúng 1 cái; Add với quantity > 1 hoặc
##   khi túi đã có món đó thì trả false, KHÔNG thêm gì (all-or-nothing
##   — hành vi đã sửa 18/11, xem Inventory.cs + InventoryTests.cs).
## - Use(): trừ 1 khỏi túi, kích hoạt buff tạm (nếu có). Buff áp đúng
##   khung ghi trong catalog (def.effect_frame), KHÔNG ghi đè bằng khung
##   hiện tại — cơm tấm (catalog ghi Chiều) dùng lúc Sáng thì buff vẫn
##   rơi vào Chiều (bug đã sửa 18/11). Tham số current_frame giữ lại
##   để không đổi API của người gọi; nó không quyết định khung buff.
## - Tiền KHÔNG nằm ở đây (thuộc ví/Economy — như PxbJobs.gold tạm giữ
##   ở Jobs; khi port PlayerProgress thì ví chuyển sang đó).
## - Vật phẩm gắn chỉ số vĩnh viễn (nhà/xe/điện thoại/quần áo, 3 dòng
##   chỉ số Mục 7) KHÔNG nằm ở đây — thuộc hệ trang bị, làm ở phase sau.
##
## KHÁC C#: GDScript không có exception — add()/use() trả false thay vì
## throw khi id lạ. C# giữ entry 0 trong túi sau khi dùng hết món cuối
## (Count vẫn trả 0); port này giữ nguyên — không xóa key 0 (khác
## Crafting, nơi nguyên liệu về 0 thì XÓA key — xem pxb_crafting.gd).
##
## Dùng: inventory là túi đồ hiện tại của người chơi (autoload sau này
## hoặc instance trong scene). data() / from_data() là dữ liệu thuần
## để lưu (save G2 bước sau).

# Buff tạm: {stat: "the"/"tri"/"tam", amount: int, frame: "Sáng"/"Chiều"/"Tối"}.

var items: Dictionary = {} # {item_id: số lượng} — giữ entry 0 như C#
var active_buffs: Array = [] # Array[Dictionary] — buff tạm đang có


# --- Tra cứu bảng (đọc từ PxbBalance, không hardcode) ---

static func item_list() -> Array:
	return PxbBalance.ITEMS.duplicate(true)


static func get_item(item_id: String) -> Dictionary:
	return PxbBalance.item_by_id(item_id)


# Số lượng đang có của 1 món (0 nếu chưa có / đã dùng hết).
func count(item_id: String) -> int:
	return int(items.get(item_id, 0))


# --- Mua / nhận đồ ---

# Mua vật phẩm (đã trừ tiền ở ngoài — như C# Add). Trả false nếu id
# không có trong catalog, quantity <= 0, hoặc đồ không xếp chồng mà
# quantity > 1 / túi đã có món đó (all-or-nothing: không thêm gì).
func add(item_id: String, quantity: int = 1) -> bool:
	var def := get_item(item_id)
	if def.is_empty() or quantity <= 0:
		return false
	if not bool(def["stackable"]) and (quantity > 1 or count(item_id) > 0):
		return false
	items[item_id] = count(item_id) + quantity
	return true


# --- Dùng đồ / buff tạm ---

# Dùng 1 vật phẩm: trừ khỏi túi, kích hoạt buff tạm (nếu có). Trả false
# nếu id lạ hoặc không có đồ. current_frame giữ lại cho API gọi (như
# C#) nhưng KHÔNG quyết định khung buff — khung lấy từ catalog.
func use(item_id: String, current_frame: String = "") -> bool:
	var def := get_item(item_id)
	if def.is_empty() or count(item_id) <= 0:
		return false
	items[item_id] = count(item_id) - 1
	var stat := String(def.get("effect_stat", ""))
	if stat != "":
		active_buffs.append({
			"stat": stat,
			"amount": int(def["effect_amount"]),
			"frame": String(def["effect_frame"]),
		})
	return true


# Tổng buff đang có hiệu lực cho 1 chỉ số trong 1 khung (cộng dồn nếu
# dùng nhiều món cùng khung — đúng C# BuffFor).
func buff_for(stat: String, frame_name: String) -> int:
	var total := 0
	for b in active_buffs:
		var buff := b as Dictionary
		if String(buff.get("stat", "")) == stat and String(buff.get("frame", "")) == frame_name:
			total += int(buff.get("amount", 0))
	return total


# Hết khung thì buff tạm của khung đó hết hiệu lực (gọi khi chuyển
# khung). Buff khung khác GIỮ NGUYÊN.
func end_frame(frame_name: String) -> void:
	var kept: Array = []
	for b in active_buffs:
		if String((b as Dictionary).get("frame", "")) != frame_name:
			kept.append(b)
	active_buffs = kept


# --- Dữ liệu thuần để lưu (save G2 bước sau) ---

func data() -> Dictionary:
	return {
		"items": items.duplicate(),
		"active_buffs": active_buffs.duplicate(true),
	}


static func from_data(d: Dictionary) -> PxbInventory:
	var inv := PxbInventory.new()
	for k in (d.get("items", {}) as Dictionary):
		inv.items[String(k)] = int((d["items"] as Dictionary)[k])
	for b in d.get("active_buffs", []):
		var buff := (b as Dictionary).duplicate()
		if String(buff.get("stat", "")) != "" and String(buff.get("frame", "")) != "":
			inv.active_buffs.append(buff)
	return inv
