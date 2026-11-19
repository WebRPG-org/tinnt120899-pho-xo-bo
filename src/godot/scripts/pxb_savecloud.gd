class_name PxbSaveCloud
extends Node
## Phố Xô Bồ — PXB_SaveCloud (Godot G2, bước 5/17, phần B).
## Port trung thực PXB_SaveCloud.js (src/nadia/www/js/plugins/
## PXB_SaveCloud.js) — đồng bộ save kiểu xenvn: tài khoản tùy chọn,
## save JSON nén, lưu local khi offline; upload/download lên server
## CHƯA có endpoint nên luôn trả server-chua-co-endpoint.
##
## - Tài khoản là TÙY CHỌN, chưa đăng nhập vẫn chơi + lưu local bình
##   thường. Tài khoản hiện chỉ là accountId (chuỗi do người chơi
##   nhập); CHƯA có mật khẩu / đăng ký / xác thực thật.
## - Save JSON gom toàn bộ dict hệ thống truyền vào (gồm pxb* của mọi
##   plugin: pxbStats, pxbEconomy, pxbSocial, pxbStory, pxbOnline,
##   pxbSaveCloud…) + ngày game hiện tại (lấy từ pxbTime.game_day,
##   không có thì gameDay, không có nữa thì 1). Save là object thuần
##   JSON-safe — không lưu function / class.
## - Nén bằng PackedByteArray.compress (DEFLATE) + Marshalls base64,
##   tương đương vai trò LZString.compressToBase64 bên JS; dữ liệu nén
##   có tiền tố "pxb1:" + 4 byte little-endian ghi kích thước gốc để
##   giải nén biết buffer. Không nén được thì fallback JSON thô, ghi
##   rõ compressed:false — không giả vờ đã nén.
## - Lưu local: Godot không có localStorage — ghi file
##   user://pxb_savecloud_<slot>.save (chạy được headless). File chứa
##   phong bì JSON {"compressed": bool, "data": string} để lúc đọc
##   biết dữ liệu có nén hay không. Ghi file lỗi thì giữ trong bộ nhớ
##   của instance (memory) — vẫn trả ok nhưng ghi rõ where:"memory"
##   để event biết save này mất khi đóng game.
## - Upload / download save lên server: server CHƯA có endpoint nên
##   LUÔN trả {ok:false, reason:"server-chua-co-endpoint"} — KHÔNG
##   giả vờ đã đồng bộ. Chưa đăng nhập thì trả
##   {ok:false, reason:"chua-dang-nhap"} trước, cũng không gọi server.
## - Trạng thái đồng bộ sống trong instance này (last_sync_at,
##   last_sync_status, last_sync_detail) + data() / from_data() để
##   lưu theo save (bên JS state sống trong $gameSystem.pxbSaveCloud).
##
## PROVISIONAL — chưa chốt, đổi thì sửa ở đây + server +
## docs/architecture-nadia.md §7 cùng lúc (xem @help của JS):
##   - Số slot lưu local tối đa 3 slot (slot 1–3, như MV gốc).
##   - Phiên bản save "0.1.0-skeleton" (khớp version server hiện tại).
##   - Upload/download dùng endpoint /save/upload + /save/download
##     (TÊN DỰ KIẾN — server chưa có, hàm chỉ giữ tên để sau này nối,
##     không gọi thật).
##
## LỆCH ĐÃ GHI NHẬN (so với JS — không bịa hành vi mới):
##   - GDScript không có localStorage: lưu file user:// thay cho
##     localStorage; where thành công là "file" (JS: "localStorage"),
##     fallback vẫn là "memory".
##   - GDScript không có LZString: nén bằng DEFLATE có sẵn của Godot,
##     tiền tố "pxb1:" đánh dấu định dạng Godot. Dữ liệu nén mà không
##     có tiền tố này (vd save nén bằng LZString bên JS) thì
##     decode_save trả "thieu-lzstring" — Godot không có LZString để
##     giải, không giả vờ giải được.
##   - GDScript không có $gameSystem toàn cục: build_save_json /
##     save_to_local nhận dict hệ thống truyền vào; apply_save chép
##     field vào dict hệ thống đích truyền vào (Dictionary truyền theo
##     tham chiếu nên caller thấy ngay).
##   - accountId dùng "" thay cho null của JS khi chưa đăng nhập
##     (String-typed, JSON-safe); is_logged_in() kiểm tra chuỗi rỗng.
##   - savedAt / lastSyncAt dùng mili-giây epoch như Date.now() của
##     JS (int(Time.get_unix_time_from_system() * 1000)).
##   - reset_state() chỉ reset state (đúng JS); bộ nhớ memorySlots
##     KHÔNG bị xóa theo — đúng JS (memorySlots là biến riêng).
##   - GDScript không có exception — các hàm trả Dictionary
##     {ok, reason} thay vì throw; JSON hỏng bắt bằng kiểm tra
##     JSON.parse_string thay vì try/catch.

# Số slot lưu local tối đa — MV gốc có 3 slot (file1–3).
const MAX_LOCAL_SLOTS := 3
# Phiên bản save — khớp version server hiện tại (0.1.0-skeleton).
const SAVE_VERSION := "0.1.0-skeleton"
# Tên endpoint DỰ KIẾN cho upload/download — server CHƯA có, chỉ
# giữ tên để sau này nối, hàm upload/download KHÔNG gọi thật.
const SAVE_UPLOAD_PATH := "/save/upload"
const SAVE_DOWNLOAD_PATH := "/save/download"

# Lý do trả về khi server chưa có endpoint — dùng chung với
# PXB_Online để event / QC bắt được bằng test tĩnh.
const REASON_NO_ENDPOINT := "server-chua-co-endpoint"

# Trạng thái đồng bộ (chuỗi cố định để event / QC so sánh).
const SYNC_CHUA_DONG_BO := "chua-dong-bo" # chưa từng đồng bộ
const SYNC_LOCAL_OK := "local-ok" # đã lưu local, chưa lên server
const SYNC_DA_DONG_BO := "da-dong-bo" # đã đồng bộ lên server (sau này)
const SYNC_LOI := "loi" # lần đồng bộ gần nhất lỗi
const SYNC_STATUS: Dictionary = {
	"CHUA_DONG_BO": SYNC_CHUA_DONG_BO,
	"LOCAL_OK": SYNC_LOCAL_OK,
	"DA_DONG_BO": SYNC_DA_DONG_BO,
	"LOI": SYNC_LOI,
}

# Tiền tố đánh dấu dữ liệu nén theo định dạng Godot (xem header).
const COMPRESSED_PREFIX := "pxb1:"

# Đường file lưu local — Godot không có localStorage.
const SLOT_FILE_PATTERN := "user://pxb_savecloud_%d.save"

# --- State (sống trong instance này + data() / from_data() để lưu) ---

var _account_id: String = "" # "" = chưa đăng nhập (chỉ lưu local)
var last_sync_at: int = 0 # mili-giây epoch lúc đồng bộ gần nhất
var last_sync_status: String = SYNC_CHUA_DONG_BO
var last_sync_detail: String = "" # ghi chú lần đồng bộ gần nhất
var local_slots: Dictionary = {} # slot ("1".."3") -> {at, compressed, where}

# Bộ nhớ dự phòng khi ghi file lỗi — save trong này mất khi đóng
# game, hàm trả về ghi rõ where:"memory".
var _memory_slots: Dictionary = {} # "pxb_savecloud_<slot>" -> envelope JSON


static func default_data() -> Dictionary:
	return {
		"accountId": "",
		"lastSyncAt": 0,
		"lastSyncStatus": SYNC_CHUA_DONG_BO,
		"lastSyncDetail": "",
		"localSlots": {},
	}


static func valid_slot(slot: int) -> bool:
	return slot >= 1 and slot <= MAX_LOCAL_SLOTS


static func slot_path(slot: int) -> String:
	return SLOT_FILE_PATTERN % slot


static func slot_key(slot: int) -> String:
	return "pxb_savecloud_%d" % slot


# Mili-giây epoch, tương đương Date.now() của JS.
static func _now_ms() -> int:
	return int(Time.get_unix_time_from_system() * 1000.0)


# JSON.parse_string in ra stderr khi gap JSON hong — dung instance
# JSON de bat loi trong im lang (test duong hong van PASS sach).
static func _parse_json(text: String):
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return null
	return parser.get_data()


# Base64 hop le cho Marshalls.base64_to_raw: chi gom A–Z a–z 0–9
# + / =, do dai chia het cho 4. Kiem tra truoc de base64 sai khong
# in loi xuong stderr (van tra giai-nen-that-bai nhu cu).
static func _is_base64(text: String) -> bool:
	if text.is_empty() or text.length() % 4 != 0:
		return false
	for i in text.length():
		var c: int = text.unicode_at(i)
		var ok_char := (c >= 65 and c <= 90) or (c >= 97 and c <= 122) \
			or (c >= 48 and c <= 57) or c == 43 or c == 47 or c == 61
		if not ok_char:
			return false
	return true

# Đăng nhập bằng accountId (chuỗi do người chơi nhập). CHƯA có mật
# khẩu / xác thực thật (PROVISIONAL — server chưa có auth).
# Trả {ok:true, accountId} hoặc {ok:false, reason:"thieu-account-id"}.
func login(account_id: String) -> Dictionary:
	if account_id.is_empty():
		return {"ok": false, "reason": "thieu-account-id"}
	_account_id = account_id
	return {"ok": true, "accountId": account_id}


# Đăng xuất — chỉ xóa accountId, không xóa save local.
func logout() -> Dictionary:
	_account_id = ""
	return {"ok": true, "accountId": ""}


func is_logged_in() -> bool:
	return not _account_id.is_empty()


func account_id() -> String:
	return _account_id


# Reset state hiện tại (event/test dùng để bắt đầu lại). Không xóa
# bộ nhớ memorySlots — đúng JS (xem LỆCH trong header).
func reset_state() -> bool:
	var d := default_data()
	_account_id = String(d["accountId"])
	last_sync_at = int(d["lastSyncAt"])
	last_sync_status = String(d["lastSyncStatus"])
	last_sync_detail = String(d["lastSyncDetail"])
	local_slots = {}
	return true


# Ghi trạng thái đồng bộ vào state (event đọc bằng sync_status()).
func _mark_sync(status: String, detail: String) -> void:
	last_sync_at = _now_ms()
	last_sync_status = status
	last_sync_detail = detail


# --- Gom + nén save ---

# Gom save JSON từ dict hệ thống truyền vào: toàn bộ field pxb* của
# các plugin + ngày game hiện tại (lấy từ pxbTime.game_day, không có
# thì gameDay, không có nữa thì 1). Trả {ok:true, save} hoặc
# {ok:false, reason:"khong-co-game-system"}.
# save = {version, savedAt, gameDay, gameSystem} — object thuần,
# JSON-safe.
func build_save_json(system_dict) -> Dictionary:
	if system_dict == null or not (system_dict is Dictionary):
		return {"ok": false, "reason": "khong-co-game-system"}
	var sys: Dictionary = system_dict
	var game_day := 1
	var pxb_time = sys.get("pxb_time", null)
	if pxb_time is Dictionary and (pxb_time.get("game_day", null) is int
			or pxb_time.get("game_day", null) is float):
		game_day = int(pxb_time["game_day"])
	elif sys.get("gameDay", null) is int or sys.get("gameDay", null) is float:
		game_day = int(sys["gameDay"])
	elif sys.get("game_day", null) is int or sys.get("game_day", null) is float:
		game_day = int(sys["game_day"])
	# Copy sâu dict hệ thống để JSON.stringify không chạm field lạ;
	# mọi field pxb* đều là object thuần nên đi theo được.
	return {
		"ok": true,
		"save": {
			"version": SAVE_VERSION,
			"savedAt": _now_ms(),
			"gameDay": game_day,
			"gameSystem": sys.duplicate(true),
		},
	}


# Nén save JSON: dùng PackedByteArray.compress (DEFLATE) + base64,
# tương đương vai trò LZString.compressToBase64 bên JS; không nén
# được thì fallback JSON thô.
# Trả {ok:true, data, compressed:true/false}.
func encode_save(save: Dictionary) -> Dictionary:
	var json: String = JSON.stringify(save)
	if json.is_empty():
		return {"ok": false, "reason": "save-hong"}
	var raw: PackedByteArray = json.to_utf8_buffer()
	var compressed: PackedByteArray = raw.compress(FileAccess.COMPRESSION_DEFLATE)
	if not compressed.is_empty():
		# 4 byte đầu little-endian ghi kích thước gốc để lúc giải
		# nén biết buffer cần cấp.
		var out := PackedByteArray()
		out.resize(4)
		out.encode_s32(0, raw.size())
		out.append_array(compressed)
		return {
			"ok": true,
			"data": COMPRESSED_PREFIX + Marshalls.raw_to_base64(out),
			"compressed": true,
		}
	return {"ok": true, "data": json, "compressed": false}


# Giải nén save đã encode: compressed=true thì dữ liệu phải có tiền
# tố "pxb1:" (định dạng Godot); không có tiền tố thì trả
# "thieu-lzstring" — dữ liệu nén bằng LZString bên JS mà Godot
# không có thư viện để giải (không giả vờ giải được).
# compressed=false thì JSON.parse thô.
# Trả {ok:true, save} hoặc {ok:false, reason}.
func decode_save(data: String, compressed: bool) -> Dictionary:
	if compressed:
		if not data.begins_with(COMPRESSED_PREFIX):
			return {"ok": false, "reason": "thieu-lzstring"}
		var b64: String = data.substr(COMPRESSED_PREFIX.length())
		if not _is_base64(b64):
			return {"ok": false, "reason": "giai-nen-that-bai"}
		var packed: PackedByteArray = Marshalls.base64_to_raw(b64)
		if packed.size() < 4:
			return {"ok": false, "reason": "giai-nen-that-bai"}
		var original_size: int = packed.decode_s32(0)
		if original_size <= 0:
			return {"ok": false, "reason": "giai-nen-that-bai"}
		var plain: PackedByteArray = packed.slice(4).decompress(
			original_size, FileAccess.COMPRESSION_DEFLATE)
		if plain.size() != original_size:
			return {"ok": false, "reason": "giai-nen-that-bai"}
		var parsed = _parse_json(plain.get_string_from_utf8())
		if parsed is Dictionary:
			return {"ok": true, "save": parsed}
		return {"ok": false, "reason": "save-hong"}
	var parsed_raw = _parse_json(data)
	if parsed_raw is Dictionary:
		return {"ok": true, "save": parsed_raw}
	return {"ok": false, "reason": "save-hong"}


# --- Lưu / đọc local (file user:// thay localStorage, fallback memory) ---

# Lưu save hiện tại vào slot local (1–3). Trả
# {ok:true, slot, where:"file"|"memory", compressed:true/false}
# hoặc {ok:false, reason}. Chưa đăng nhập vẫn lưu được — đây là
# save local kiểu MV gốc.
func save_to_local(slot: int, system_dict) -> Dictionary:
	if not valid_slot(slot):
		return {"ok": false, "reason": "slot-khong-hop-le"}
	var built := build_save_json(system_dict)
	if not bool(built.get("ok", false)):
		return built
	var encoded := encode_save(built["save"])
	if not bool(encoded.get("ok", false)):
		return encoded
	var envelope: String = JSON.stringify({
		"compressed": bool(encoded["compressed"]),
		"data": String(encoded["data"]),
	})
	var where := "memory"
	var path := slot_path(slot)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(envelope)
		if file.get_error() == OK:
			where = "file"
		file.close()
	if where == "memory":
		_memory_slots[slot_key(slot)] = envelope
		# File ghi dở (nếu có) không được để lại làm bẩn lần đọc sau.
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
	local_slots[str(slot)] = {
		"at": _now_ms(),
		"compressed": bool(encoded["compressed"]),
		"where": where,
	}
	_mark_sync(SYNC_LOCAL_OK, "da-luu-local-slot-%d-qua-%s" % [slot, where])
	return {
		"ok": true,
		"slot": slot,
		"where": where,
		"compressed": bool(encoded["compressed"]),
	}


# Đọc save từ slot local. Trả {ok:true, save, slot, compressed}
# hoặc {ok:false, reason:"slot-trong"} / "save-hong" /
# "thieu-lzstring" / "giai-nen-that-bai". Không tự ghi đè dict hệ
# thống — event quyết có load vào game không (xem apply_save).
func load_from_local(slot: int) -> Dictionary:
	if not valid_slot(slot):
		return {"ok": false, "reason": "slot-khong-hop-le"}
	var path := slot_path(slot)
	var raw := ""
	var found := false
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			raw = file.get_as_text()
			found = true
	if not found and _memory_slots.has(slot_key(slot)):
		raw = String(_memory_slots[slot_key(slot)])
		found = true
	if not found:
		return {"ok": false, "reason": "slot-trong"}
	# Phong bì JSON ghi rõ dữ liệu có nén hay không; file cũ / file
	# sửa tay không có phong bì thì coi là JSON thô.
	var parsed = _parse_json(raw)
	var data_str := raw
	var compressed := false
	var has_envelope := false
	if parsed is Dictionary and parsed.has("data"):
		has_envelope = true
		data_str = String(parsed["data"])
		compressed = bool(parsed.get("compressed", false))
	var decoded := decode_save(data_str, compressed)
	if not bool(decoded.get("ok", false)) and not compressed and has_envelope:
		# Dữ liệu lưu trước đây có thể đã nén nhưng phong bì ghi sai
		# (save cũ) — thử giải nén 1 lần rồi thôi (đúng JS).
		decoded = decode_save(data_str, true)
	if not bool(decoded.get("ok", false)):
		return decoded
	return {
		"ok": true,
		"save": decoded["save"],
		"slot": slot,
		"compressed": compressed,
	}


# Áp save đã đọc vào dict hệ thống đích truyền vào: chép từng field
# của save.gameSystem vào dict đích (giữ lại field hiện có không có
# trong save). Trả {ok:true} hoặc {ok:false, reason}.
# Không tự gọi trong load_from_local — event quyết khi nào load.
func apply_save(save: Dictionary, target: Dictionary) -> Dictionary:
	if save.is_empty() or not save.has("gameSystem") \
			or not (save["gameSystem"] is Dictionary):
		return {"ok": false, "reason": "save-khong-hop-le"}
	var gs: Dictionary = save["gameSystem"]
	for k in gs:
		target[k] = gs[k]
	return {"ok": true}


# Mô tả các slot local đã lưu (slot -> {at, compressed, where}) —
# event dùng để hiển thị danh sách save.
func list_local_slots() -> Dictionary:
	return local_slots.duplicate(true)


# --- Upload / download lên server: CHƯA có endpoint ---
# Cả 2 hàm LUÔN trả {ok:false, reason:"server-chua-co-endpoint"}.
# KHÔNG gọi HTTP, KHÔNG giả vờ đã đồng bộ. Chưa đăng nhập thì trả
# {ok:false, reason:"chua-dang-nhap"} trước. Tên endpoint dự kiến
# SAVE_UPLOAD_PATH / SAVE_DOWNLOAD_PATH chỉ giữ để sau này nối.

func upload_save(slot: int) -> Dictionary:
	if not is_logged_in():
		return {"ok": false, "reason": "chua-dang-nhap"}
	if not valid_slot(slot):
		return {"ok": false, "reason": "slot-khong-hop-le"}
	_mark_sync(SYNC_LOI, "server-chua-co-endpoint:" + SAVE_UPLOAD_PATH)
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


func download_save(slot: int) -> Dictionary:
	if not is_logged_in():
		return {"ok": false, "reason": "chua-dang-nhap"}
	if not valid_slot(slot):
		return {"ok": false, "reason": "slot-khong-hop-le"}
	_mark_sync(SYNC_LOI, "server-chua-co-endpoint:" + SAVE_DOWNLOAD_PATH)
	return {"ok": false, "reason": REASON_NO_ENDPOINT}


# Trạng thái đồng bộ hiện tại — event / UI đọc để hiển thị.
func sync_status() -> Dictionary:
	return {
		"status": last_sync_status,
		"detail": last_sync_detail,
		"at": last_sync_at,
		"accountId": _account_id,
	}


# --- Lưu / tải (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {
		"accountId": _account_id,
		"lastSyncAt": last_sync_at,
		"lastSyncStatus": last_sync_status,
		"lastSyncDetail": last_sync_detail,
		"localSlots": local_slots.duplicate(true),
	}


# Khôi phục từ data(); dữ liệu bẩn bị bỏ: trạng thái đồng bộ lạ về
# "chua-dong-bo", accountId không phải chuỗi về "", slot lạ / mô tả
# slot không phải dict bị bỏ, field trong mô tả slot được khử bẩn
# (at âm về 0, compressed không phải bool về false, where lạ về
# "file").
func from_data(d: Dictionary) -> void:
	if d.is_empty():
		reset_state()
		return
	var raw_account = d.get("accountId", "")
	_account_id = raw_account if raw_account is String else ""
	var raw_at = d.get("lastSyncAt", 0)
	last_sync_at = maxi(0, int(raw_at)) if raw_at is int or raw_at is float else 0
	var raw_status := String(d.get("lastSyncStatus", SYNC_CHUA_DONG_BO))
	last_sync_status = raw_status if raw_status in SYNC_STATUS.values() \
		else SYNC_CHUA_DONG_BO
	var raw_detail = d.get("lastSyncDetail", "")
	last_sync_detail = raw_detail if raw_detail is String else ""
	local_slots = {}
	var raw_slots = d.get("localSlots", {})
	if raw_slots is Dictionary:
		for slot_str in raw_slots:
			var s := String(slot_str)
			if s != "1" and s != "2" and s != "3":
				continue
			var info = raw_slots[slot_str]
			if not (info is Dictionary):
				continue
			var at = info.get("at", 0)
			var comp = info.get("compressed", false)
			var wh := String(info.get("where", "file"))
			local_slots[s] = {
				"at": maxi(0, int(at)) if at is int or at is float else 0,
				"compressed": comp if comp is bool else false,
				"where": wh if wh == "file" or wh == "memory" else "file",
			}
