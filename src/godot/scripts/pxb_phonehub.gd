class_name PxbPhoneHub
extends Node
## Phố Xô Bồ — PXB_PhoneHub (Godot G2, bước 5/17, phần B).
## Port trung thực PXB_PhoneHub.js (src/nadia/www/js/plugins/
## PXB_PhoneHub.js) / PhoneHub.cs (src/client/Assets/Scripts/PhoneHub.cs)
## — điện thoại là menu chính, GDD Mục 2: overlay hub 9 tab, mở bằng
## phím P / nút điện thoại, KHÔNG thay thế thế giới (vẫn phải đi lại
## trong phố). File này chỉ giữ trạng thái + điều hướng tab (logic
## thuần); lớp UI (CanvasLayer trong main.gd, bước sau) bind vào các
## hàm open/close/select_tab + 2 signal dưới đây.
##
## - 9 tab đúng thứ tự GDD Mục 2 / PhoneHub.cs TabOrder: Danh bạ /
##   Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe,
##   Xã hội, Cài đặt. Tab mặc định khi mở là Danh bạ / Tin nhắn.
## - open(tab) / close() / toggle() / select_tab(tab): mở tab thì đánh
##   dấu đã đọc tab đó (số chưa đọc của tab về 0). close() không đổi
##   tab hiện tại, nên toggle() mở lại giữ đúng tab trước khi đóng.
## - notify(tab) tăng số chưa đọc của tab; unread_count(tab) đọc số
##   đó; total_unread() cộng dồn mọi tab. UI hiển thị chấm đỏ theo
##   số này.
## - Sự kiện C# (TabChanged / OpenChanged) port sang signal GDScript:
##   tab_changed(tab_id) / open_changed(is_open). UI kết nối lại sau
##   mỗi lần load (signal sống ở runtime, KHÔNG nằm trong save).
## - Phím P: PHONE_KEY_CODE = KEY_P để lớp UI / input map dùng; file
##   này không tự bắt phím (đúng ranh giới: PhoneHub.cs cũng không có
##   binding phím hay nút nào, chỉ giữ trạng thái + điều hướng).
##
## QUIRK GIỮ ĐÚNG C# / JS (không tự sửa — để GDD/PM xem lại):
## - notify() đếm cả khi điện thoại đang đóng (không kiểm tra is_open):
##   tin đến lúc đóng vẫn được đếm, mở ra sẽ thấy chấm đỏ.
## - open() luôn phát tab_changed (qua select_tab) rồi mới
##   open_changed(true), kể cả mở đúng tab đang hiển thị; select_tab()
##   cũng luôn phát tab_changed kể cả chọn đúng tab hiện tại (code
##   không kiểm tra tab có đổi không).
## - open(tab lạ): is_open vẫn = true + open_changed(true) vẫn phát,
##   nhưng tab hiện tại không đổi và tab_changed không phát (đúng JS:
##   select_tab trả false nhưng open() bỏ qua kết quả đó).
## - close() luôn phát open_changed(false), kể cả khi đã đóng sẵn.
##
## LỆCH ĐÃ GHI NHẬN (theo @help của JS — không bịa số mới):
## - GDD Mục 2 viết "Sức khoẻ", PhoneHub.cs viết SucKhoe (Sức khỏe).
##   File này dùng "Sức khỏe" theo C#; chỉ khác chính tả.
## - PhoneHub.cs không có số cấu hình nào (không lương, không phí,
##   không thời gian) nên file này không dùng PxbBalance và không có
##   số PROVISIONAL nào.
## - GDScript không có exception — các hàm trả bool/int thay vì throw.
## - State sống trong instance này + data() / from_data() để lưu
##   (save thật là việc SaveCloud, G2 bước 5 phần B sau).

# Phím P mở/đóng điện thoại — đã chốt ở architecture-nadia §6 #4.
# Chỉ là hằng để lớp UI dùng; file này không tự bắt phím.
const PHONE_KEY_CODE := KEY_P

# 9 tab đúng thứ tự GDD Mục 2 / PhoneHub.cs TabOrder.
# id kebab-case theo quy ước plugin PXB_* (vd PXB_Jobs dùng "ban-rong").
const TAB_DANH_BA_TIN_NHAN := "danh-ba-tin-nhan"
const TAB_NGAN_HANG := "ngan-hang"
const TAB_BAN_DO := "ban-do"
const TAB_VIEC_LAM := "viec-lam"
const TAB_CHO := "cho"
const TAB_HOC_TAP := "hoc-tap"
const TAB_SUC_KHOE := "suc-khoe"
const TAB_XA_HOI := "xa-hoi"
const TAB_CAI_DAT := "cai-dat"

const DEFAULT_TAB := TAB_DANH_BA_TIN_NHAN

const TABS: Array[Dictionary] = [
	{"id": TAB_DANH_BA_TIN_NHAN, "name": "Danh bạ / Tin nhắn"},
	{"id": TAB_NGAN_HANG, "name": "Ngân hàng"},
	{"id": TAB_BAN_DO, "name": "Bản đồ"},
	{"id": TAB_VIEC_LAM, "name": "Việc làm"},
	{"id": TAB_CHO, "name": "Chợ"},
	{"id": TAB_HOC_TAP, "name": "Học tập"},
	{"id": TAB_SUC_KHOE, "name": "Sức khỏe"},
	{"id": TAB_XA_HOI, "name": "Xã hội"},
	{"id": TAB_CAI_DAT, "name": "Cài đặt"},
]

## Phát khi tab hiện tại được chọn (kể cả chọn lại đúng tab đang hiển
## thị — đúng C#/JS, xem quirk trong header).
signal tab_changed(tab_id: String)
## Phát khi điện thoại mở (true) / đóng (false) — kể cả đóng khi đã
## đóng sẵn (đúng C#/JS, xem quirk trong header).
signal open_changed(is_open: bool)

var is_open: bool = false
var current_tab: String = DEFAULT_TAB
var unread: Dictionary = {} # tab_id -> int; tab chưa notify thì không có key (= 0)


# --- Tra cứu tab (hàm tĩnh, không cần instance) ---

static func tab_ids() -> Array[String]:
	var out: Array[String] = []
	for t in TABS:
		out.append(String(t["id"]))
	return out


static func tab_exists(tab_id: String) -> bool:
	return tab_id in tab_ids()


static func tab_name(tab_id: String) -> String:
	for t in TABS:
		if String(t["id"]) == tab_id:
			return String(t["name"])
	return ""


# Trả bản sao để caller không sửa được thứ tự chuẩn.
static func tab_list() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for t in TABS:
		out.append({"id": String(t["id"]), "name": String(t["name"])})
	return out


static func default_data() -> Dictionary:
	return {"is_open": false, "current_tab": DEFAULT_TAB, "unread": {}}


# --- Mở / đóng / đổi tab (port trung thực PhoneHub.cs) ---

# Chọn tab. Trả false nếu tab không có trong TabOrder. Mở tab thì
# đánh dấu đã đọc tab đó (unread về 0). Luôn phát tab_changed, kể cả
# chọn đúng tab hiện tại — hành vi theo C#, xem quirk trong header.
func select_tab(tab_id: String) -> bool:
	if not tab_exists(tab_id):
		return false
	current_tab = tab_id
	unread[tab_id] = 0 # Mở tab thì đánh dấu đã đọc.
	tab_changed.emit(tab_id)
	return true


# Mở điện thoại ở tab cho trước (mặc định: tab Danh bạ / Tin nhắn,
# khớp tham số mặc định PhoneTab.DanhBaTinNhan của PhoneHub.Open).
# Luôn phát tab_changed (qua select_tab) rồi open_changed(true).
# Tab lạ: vẫn mở + vẫn phát open_changed, tab không đổi (xem quirk).
func open(tab_id: String = DEFAULT_TAB) -> bool:
	is_open = true
	select_tab(tab_id)
	open_changed.emit(true)
	return true


# Đóng điện thoại. Không đổi current_tab — hành vi theo C#.
# Luôn phát open_changed(false), kể cả khi đã đóng sẵn.
func close() -> bool:
	is_open = false
	open_changed.emit(false)
	return true


# Đang đóng thì mở lại ở tab hiện tại (giữ đúng tab trước khi đóng),
# đang mở thì đóng. Khớp PhoneHub.Toggle dùng CurrentTab.
func toggle() -> bool:
	if is_open:
		close()
	else:
		open(current_tab)
	return true


# --- Tin chưa đọc (port trung thực PhoneHub.cs) ---

# notify() đếm cả khi điện thoại đang đóng (không kiểm tra is_open) —
# hành vi theo C#, xem quirk trong header. Trả false nếu tab sai.
func notify(tab_id: String) -> bool:
	if not tab_exists(tab_id):
		return false
	unread[tab_id] = int(unread.get(tab_id, 0)) + 1
	return true


func unread_count(tab_id: String) -> int:
	if not tab_exists(tab_id):
		return 0
	return int(unread.get(tab_id, 0))


func total_unread() -> int:
	var total := 0
	for tab_id in unread:
		total += int(unread[tab_id])
	return total


# --- Lưu / tải (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {
		"is_open": is_open,
		"current_tab": current_tab,
		"unread": unread.duplicate(),
	}


# Khôi phục từ data(); dữ liệu bẩn bị bỏ: tab lạ trong unread, số
# chưa đọc âm / không phải số, current_tab lạ → tab mặc định.
func from_data(d: Dictionary) -> void:
	if d.is_empty():
		is_open = false
		current_tab = DEFAULT_TAB
		unread = {}
		return
	is_open = bool(d.get("is_open", false))
	var tab := String(d.get("current_tab", DEFAULT_TAB))
	current_tab = tab if tab_exists(tab) else DEFAULT_TAB
	unread = {}
	var raw_unread: Dictionary = d.get("unread", {})
	for tab_id in raw_unread:
		var tid := String(tab_id)
		if not tab_exists(tid):
			continue
		var v = raw_unread[tab_id]
		if v is int or v is float:
			unread[tid] = maxi(0, int(v))
