class_name PxbEconomy
extends Node
## Phố Xô Bồ — PXB_Economy (Godot G2, bước 4/17).
## Port trung thực Economy.cs (src/client/Assets/Scripts/Economy.cs) /
## PXB_Economy.js (src/nadia/www/js/plugins/PXB_Economy.js).
##
## - Ví tiền RIÊNG của hệ kinh tế (money/savings trong state), KHÔNG
##   dùng túi đồ / ví của hệ khác — như C#/JS. Khi port PlayerProgress
##   (G2 bước sau), ví chuyển sang đó; hàm buy/deposit/withdraw giữ
##   nguyên chữ ký, chỉ đổi chỗ cộng/trừ tiền.
## - Catalog 17 món: 6 nhà / 6 xe / 2 điện thoại / 3 quần áo. Mỗi món
##   có 3 dòng chỉ số ItemStats: cộng chỉ số nhân vật (the/tri/tam/
##   an_yen/fame), mở nghề/danh hiệu (unlocks), tên set (set) để tính
##   set bonus. Giá nhà lấy từ PxbBalance (số ĐÃ CHỐT); giá + chỉ số
##   xe / điện thoại / quần áo theo docs/economy.md, PROVISIONAL (chưa
##   có trong GameBalance — như JS giữ bảng này trong plugin).
## - Lãi tiết kiệm 0,5%/tháng game (đã chốt), phí đấu giá 5% (đã chốt),
##   mua lớn (nhà hoặc xe sang) Danh vọng +50 (đã chốt).
## - QUIRK GIỮ ĐÚNG C#/JS (không tự sửa): total_assets() = tiền mặt +
##   tiết kiệm + tổng giá đồ đã sở hữu, nên buy("phong-tro") trừ tiền
##   thuê tháng nhưng vẫn cộng 2 triệu vào tài sản (phòng trọ nằm trong
##   owned với price_vnd = tiền thuê tháng). GDD xem lại thì sửa ở
##   Economy.cs + plugin JS + file này cùng lúc.
## - RANH GIỚI PHÁP LÝ (đúng C# — hành vi bị chặn có chủ đích, không
##   phải tính năng thiếu): cash_out() / lend_with_interest() /
##   gamble() / buy_with_real_money() LUÔN trả false, không làm gì cả.
##   Không cash-out, không giao dịch tiền thật, không cho vay lấy lãi
##   giữa người chơi, không cờ bạc, không lootbox tiền thật, không
##   crypto/NFT.
##
## KHÁC C#/JS — GHI RÕ, KHÔNG GIẢ VỜ ĐÃ CHỐT:
## - owned lưu id món (Array[String]) thay vì object OwnedItem — tra
##   cứu đầy đủ qua get_item(); data()/from_data() vì thế gọn và
##   không sợ lệch object khi load save.
## - 1 tháng game = 30 ngày (DAYS_PER_GAME_MONTH), điểm tín dụng khởi
##   đầu 100, set bonus đủ 3 món cùng set +10 Danh vọng / +5 An Yên,
##   phạt dress-code Giao tiếp −20, luật chia tài sản ly hôn chia đôi
##   tiền mặt + tiết kiệm — tất cả PROVISIONAL (xem Economy.cs).
## - GDScript không có exception — buy() trả dict {ok, reason} thay vì
##   throw / out param như C#; các hàm chặn trả false.
##
## Dùng: economy là ví + tài sản hiện tại của người chơi (instance
## trong scene / autoload sau này). data() / from_data() là dữ liệu
## thuần để lưu (save G2 bước sau).

# 1 tháng game = 30 ngày game — PROVISIONAL (khớp Economy.cs).
const DAYS_PER_GAME_MONTH := 30
# Set bonus: đủ 3 món cùng set → cộng thêm. Số PROVISIONAL.
const SET_BONUS_FAME := 10
const SET_BONUS_AN_YEN := 5
# Đồ lệch chuẩn khi phỏng vấn: Giao tiếp −20 — PROVISIONAL.
const DRESS_CODE_PENALTY := 20
# Điểm tín dụng khởi đầu — PROVISIONAL.
const CREDIT_SCORE_START := 100

var money: int = 0 # tiền mặt (đồng trong game)
var savings: int = 0 # tiền tiết kiệm (đồng trong game)
var credit_score: int = CREDIT_SCORE_START
var owned: Array = [] # Array[String] — id món đã sở hữu


func _init(starting_money_vnd: int = 0) -> void:
	money = maxi(int(starting_money_vnd), 0)


# --- Catalog (giá nhà từ PxbBalance, còn lại PROVISIONAL theo Economy.cs) ---

static func _item(id: String, item_name: String, kind: String, price_vnd: int,
		the: int, tri: int, tam: int, an_yen: int, fame: int,
		unlocks: String, set_name: String) -> Dictionary:
	return {
		"id": id, "name": item_name, "kind": kind, "price_vnd": price_vnd,
		"stats": {
			"the": the, "tri": tri, "tam": tam, "an_yen": an_yen, "fame": fame,
			"unlocks": unlocks, "set": set_name,
		},
	}


static func houses() -> Array:
	return [
		_item("phong-tro", "Phòng trọ", "House", PxbBalance.ROOM_RENT_PER_MONTH_VND,
			-5, 0, 0, 5, 0, "", "Nhà ấm"),
		_item("chung-cu-mini", "Chung cư mini", "House", PxbBalance.MINI_APARTMENT_VND,
			0, 5, 0, 10, 0, "Quản lý cần có nhà riêng", "Nhà ấm"),
		_item("nha-pho-nho", "Nhà phố nhỏ", "House", PxbBalance.SMALL_TOWNHOUSE_VND,
			0, 10, 0, 15, 0, "Giám đốc cần nhà phố", "Nhà ấm"),
		_item("nha-pho-lon", "Nhà phố lớn", "House", PxbBalance.LARGE_TOWNHOUSE_VND,
			0, 10, 10, 20, 0, "Giám đốc cần nhà phố", "Nhà ấm"),
		_item("biet-thu", "Biệt thự", "House", PxbBalance.VILLA_VND,
			0, 0, 20, 30, 50, "Chủ Nhà Trọ cần 2 nhà cho thuê", "Nhà ấm"),
		_item("penthouse-dao", "Penthouse / Đảo", "House", PxbBalance.PENTHOUSE_ISLAND_VND,
			0, 10, 20, 30, 50, "", "Nhà ấm"),
	]


static func cars() -> Array:
	return [
		_item("xe-dap", "Xe đạp", "Car", 0,
			5, 0, 0, 0, 0, "", ""),
		_item("xe-may-cu", "Xe máy cũ", "Car", 15000000,
			0, 0, 0, 0, 0, "Shipper", ""),
		_item("xe-may-moi", "Xe máy mới", "Car", 60000000,
			0, 0, 0, 5, 0, "Shipper", ""),
		_item("o-to-cu", "Ô tô cũ", "Car", 400000000,
			0, 0, 0, 0, 10, "Việc tầng cao", ""),
		_item("o-to-moi", "Ô tô mới", "Car", 1200000000,
			0, 0, 5, 10, 20, "Giám đốc cần xe", "Sang trọng"),
		_item("xe-sang", "Xe sang", "Car", 5000000000,
			0, 0, 10, 10, 50, "Giám đốc cần xe", "Sang trọng"),
	]


static func phones() -> Array:
	return [
		_item("dien-thoai-cu", "Điện thoại cũ", "Phone", 5000000,
			0, 0, 0, 0, 0, "", ""),
		_item("dien-thoai-flagship", "Điện thoại flagship", "Phone", 30000000,
			0, 10, 10, 0, 10, "Bác sĩ cần điện thoại tốt để trực", ""),
	]


static func clothes() -> Array:
	return [
		_item("ao-dai", "Áo dài", "Clothes", 2000000,
			0, 0, 15, 0, 10, "", "Truyền thống"),
		_item("bo-cong-so", "Bộ công sở", "Clothes", 5000000,
			0, 0, 10, 0, 10, "Phỏng vấn quản lý", "Công sở"),
		_item("vest-giam-doc", "Vest giám đốc", "Clothes", 20000000,
			0, 0, 10, 0, 20, "Giám đốc cần vest", "Công sở"),
	]


static func catalog() -> Dictionary:
	return {
		"houses": houses(), "cars": cars(),
		"phones": phones(), "clothes": clothes(),
	}


static func get_item(item_id: String) -> Dictionary:
	for group in [houses(), cars(), phones(), clothes()]:
		for it in group:
			if String((it as Dictionary)["id"]) == item_id:
				return it
	return {}


# Số món đã sở hữu (kể cả phòng trọ thuê nhiều lần — đúng C# List.Add).
func owned_count(item_id: String) -> int:
	var n := 0
	for id in owned:
		if String(id) == item_id:
			n += 1
	return n


# Tổng tài sản = tiền mặt + tiết kiệm + tổng giá đồ đã sở hữu — đúng
# Economy.TotalAssetsVnd, KỂ CẢ quirk phòng trọ (xem ghi chú đầu file).
func total_assets() -> int:
	var total: int = money + savings
	for id in owned:
		var it := get_item(String(id))
		if not it.is_empty():
			total += int(it["price_vnd"])
	return total


# --- Ví tiền ---

# Lãi tiết kiệm: 0,5%/tháng game (đã chốt). Trả lãi đã cộng vào tiết
# kiệm; 0 tháng hoặc tiết kiệm = 0 thì trả 0 — đúng ApplyMonthlyInterest.
func apply_monthly_interest(game_days_elapsed: int) -> int:
	var months := int(game_days_elapsed) / DAYS_PER_GAME_MONTH
	if months <= 0 or savings <= 0:
		return 0
	var interest := int(float(savings) * PxbBalance.BANK_INTEREST_PER_GAME_MONTH * float(months))
	savings += interest
	return interest


# Gửi tiết kiệm: trả false khi amount <= 0 hoặc vượt tiền mặt.
func deposit_savings(amount: int) -> bool:
	if amount <= 0 or amount > money:
		return false
	money -= amount
	savings += amount
	return true


# Rút tiết kiệm: trả false khi amount <= 0 hoặc vượt tiết kiệm.
func withdraw_savings(amount: int) -> bool:
	if amount <= 0 or amount > savings:
		return false
	savings -= amount
	money += amount
	return true


# Mua món đồ — đúng Economy.Buy / PXB_Economy.buy. Trả:
#   {ok:true, fame_gained, reason:""}
#   {ok:false, fame_gained:0, reason:"khong-co-mon"} — món không có
#   {ok:false, fame_gained:0, reason:"khong-du-tien"} — không đủ tiền
# Phòng trọ chỉ trừ tiền thuê tháng và vẫn thêm vào owned (đúng C#,
# xem quirk đầu file); mua nhà hoặc xe sang → fame_gained = 50.
func buy(item_id: String) -> Dictionary:
	var it := get_item(item_id)
	if it.is_empty():
		return {"ok": false, "fame_gained": 0, "reason": "khong-co-mon"}
	if String(it["kind"]) == "House" and item_id == "phong-tro":
		# Phòng trọ trả thuê tháng, không mua đứt — trả về TRƯỚC khi
		# tính Danh vọng nên fame_gained = 0 (đúng C#/JS).
		if money < int(it["price_vnd"]):
			return {"ok": false, "fame_gained": 0, "reason": "khong-du-tien"}
		money -= int(it["price_vnd"])
		owned.append(item_id)
		return {"ok": true, "fame_gained": 0, "reason": ""}
	if money < int(it["price_vnd"]):
		return {"ok": false, "fame_gained": 0, "reason": "khong-du-tien"}
	money -= int(it["price_vnd"])
	owned.append(item_id)
	var fame_gained := 0
	if String(it["kind"]) == "House" or item_id == "xe-sang":
		fame_gained = PxbBalance.BIG_PURCHASE_FAME_BONUS
	return {"ok": true, "fame_gained": fame_gained, "reason": ""}


# Sàn đấu giá: người bán nhận giá trừ phí 5% (đã chốt). Làm tròn theo
# phép chia nguyên như C# (hammer × 95 / 100, cắt phần lẻ).
static func auction_seller_receives(hammer_price_vnd: int) -> int:
	return int(hammer_price_vnd) * (100 - PxbBalance.AUCTION_FEE_PERCENT) / 100


# Đồ đổi đồ (barter): không dùng tiền, không phí. Trả false khi 1 bên
# không có đồ — đúng Economy.Barter.
func barter(give_item_id: String, receive_item_id: String, other: PxbEconomy) -> bool:
	if other == null:
		return false
	var give_idx := owned.find(give_item_id)
	var receive_idx := other.owned.find(receive_item_id)
	if give_idx < 0 or receive_idx < 0:
		return false
	owned.remove_at(give_idx)
	other.owned.remove_at(receive_idx)
	owned.append(receive_item_id)
	other.owned.append(give_item_id)
	return true


# Ly hôn chia tài sản: chia đôi tiền mặt + tiết kiệm (luật slice,
# PROVISIONAL). Trả {mine, theirs} — mine là phần còn lại của mình
# (tiền mặt + tiết kiệm sau khi chia), theirs là phần chia cho bên kia.
func split_assets() -> Dictionary:
	var half_money := money / 2
	var half_savings := savings / 2
	money -= half_money
	savings -= half_savings
	return {"mine": money + savings, "theirs": half_money + half_savings}


# Set bonus: đủ 3 món cùng set → cộng thêm Danh vọng + An Yên (số
# PROVISIONAL). Mỗi set đủ 3 món cộng 1 lần — chỉ tính, không tự cộng
# vào chỉ số nhân vật; event lấy kết quả để cộng.
func set_bonus() -> Dictionary:
	var counts := {}
	for id in owned:
		var it := get_item(String(id))
		if it.is_empty():
			continue
		var set_name := String((it["stats"] as Dictionary).get("set", ""))
		if set_name == "":
			continue
		counts[set_name] = int(counts.get(set_name, 0)) + 1
	var fame := 0
	var an_yen := 0
	for n in counts.values():
		if int(n) >= 3:
			fame += SET_BONUS_FAME
			an_yen += SET_BONUS_AN_YEN
	return {"fame": fame, "an_yen": an_yen}


# Kiểm tra dress-code: có đồ loại Clothes thuộc set "Công sở" hoặc
# "Sang trọng" thì true — đúng Economy.PassesDirectorDressCode. Lưu ý
# xe "Sang trọng" (o-to-moi, xe-sang) KHÔNG tính vì không phải Clothes.
func passes_director_dress_code() -> bool:
	for id in owned:
		var it := get_item(String(id))
		if it.is_empty():
			continue
		if String(it["kind"]) == "Clothes":
			var set_name := String((it["stats"] as Dictionary).get("set", ""))
			if set_name == "Công sở" or set_name == "Sang trọng":
				return true
	return false


# ===== RANH GIỚI PHÁP LÝ — các hành vi này BỊ CHẶN, không phải tính năng =====
# Mỗi hàm LUÔN trả false, không làm gì cả — đúng Economy.cs. QC kiểm
# tra tĩnh bắt được nếu ai vô tình "mở" lại chúng.

# Cash-out: đổi tiền trong game ra tiền thật — CẤM. Luôn trả false.
func cash_out(_amount_vnd: int) -> bool:
	return false


# Cho vay lấy lãi giữa người chơi — CẤM. Luôn trả false.
func lend_with_interest(_borrower: PxbEconomy, _amount_vnd: int, _interest_rate: float) -> bool:
	return false


# Cờ bạc / cá cược bằng tiền trong game — CẤM. Luôn trả false.
func gamble(_stake_vnd: int) -> bool:
	return false


# Mua nhà / xe / chỉ số bằng tiền thật — CẤM. Nạp chỉ mua gói tháng,
# mỹ phẩm, lượt thi. Luôn trả false.
func buy_with_real_money(_item_id: String, _real_money_amount: float) -> bool:
	return false


# --- Dữ liệu thuần để lưu (save G2 bước sau) ---

func data() -> Dictionary:
	return {
		"money": money,
		"savings": savings,
		"credit_score": credit_score,
		"owned": owned.duplicate(),
	}


# Khôi phục từ dữ liệu save (bỏ id món lạ — như JS extractSaveContents).
static func from_data(d: Dictionary) -> PxbEconomy:
	var eco := PxbEconomy.new()
	eco.money = maxi(int(d.get("money", 0)), 0)
	eco.savings = maxi(int(d.get("savings", 0)), 0)
	eco.credit_score = int(d.get("credit_score", CREDIT_SCORE_START))
	for id in d.get("owned", []):
		if not get_item(String(id)).is_empty():
			eco.owned.append(String(id))
	return eco
