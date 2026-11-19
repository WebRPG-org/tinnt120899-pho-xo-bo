class_name PxbSocial
extends Node
## Phố Xô Bồ — PXB_Social (Godot G2, bước 5/17).
## Port trung thực PXB_Social.js (src/nadia/www/js/plugins/
## PXB_Social.js) / Social.cs (src/client/Assets/Scripts/Social.cs)
## — hệ xã hội GDD Mục 8: người yêu / vợ-chồng, bạn thân / hội bạn,
## gia đình, đối tác. Bỏ bê 7 ngày game thì thân thiết giảm; được hỗ
## trợ +20% EXP; solo chậm hơn 40% (điểm giữa khoảng 30–50% đã chốt).
##
## - Quan hệ là Dictionary thuần (JSON-safe) — đi theo save: person_id,
##   display_name, kind, stage, closeness (0..100), last_interaction_day.
## - Sổ quan hệ (book) sống trong instance này: relations + marriages.
##   Hàm tĩnh làm việc trên 1 Dictionary quan hệ / 1 book Dictionary
##   để event/test dùng trực tiếp; hàm instance bao quanh book của mình.
##
## QUIRK GIỮ ĐÚNG C# / JS (không tự sửa):
## - apply_neglect() KHÔNG cập nhật last_interaction_day: gọi 2 lần
##   cùng 1 ngày game thì trừ 2 lần. Event chỉ gọi 1 lần/ngày.
## - advance_stage() KHÔNG kiểm tra Kind: Spouse cũng đi được
##   HenHo → DinhHon → Cuoi như Lover — Social.cs cũng vậy, để GDD
##   xem lại (ghi trong docs/test-report.md từ 18/11).
## - divorce() CHỈ được khi vừa là Spouse vừa ở Stage Cuoi (bug đã
##   sửa 18/11 — trước đây dùng && nên Spouse chưa cưới vẫn ly hôn được).
##
## PROVISIONAL (xem @help của JS — đổi thì sửa ở đây + Social.cs +
## docs/gdd.md Mục 8 cùng lúc): thân thiết khởi đầu 20; gặp/nhắn +5;
## bỏ bê −10 / mỗi 7 ngày; ngưỡng stage HenHo ≥ 50, DinhHon ≥ 70
## (phải từ HenHo), Cuoi ≥ 80 (phải từ DinhHon); supporter = quan hệ
## sâu có thân thiết ≥ 50; solo penalty 40%; hội bạn tan sau 7 ngày
## không họp; tối đa 3 quan hệ sâu; NPC "Bạn thân" seed_slice là tên
## tạm — PXB_Story sau này thay bằng NPC thật.
## GDScript không có exception — các hàm trả bool/int thay vì throw.

# Loại quan hệ (port enum Social.cs).
const KIND_LOVER := "Lover"
const KIND_SPOUSE := "Spouse"
const KIND_BEST_FRIEND := "BestFriend"
const KIND_FRIEND_GROUP := "FriendGroup"
const KIND_PARENT := "Parent"
const KIND_CHILD := "Child"
const KIND_COMPANY_PARTNER := "CompanyPartner"
const KINDS := [KIND_LOVER, KIND_SPOUSE, KIND_BEST_FRIEND,
	KIND_FRIEND_GROUP, KIND_PARENT, KIND_CHILD, KIND_COMPANY_PARTNER]

# Giai đoạn quan hệ (port enum Social.cs).
const STAGE_QUEN_BIET := "QuenBiet"
const STAGE_THAN_THIET := "ThanThiet"
const STAGE_HEN_HO := "HenHo"
const STAGE_DINH_HON := "DinhHon"
const STAGE_CUOI := "Cuoi"
const STAGE_TAN_RA := "TanRa"
const STAGES := [STAGE_QUEN_BIET, STAGE_THAN_THIET, STAGE_HEN_HO,
	STAGE_DINH_HON, STAGE_CUOI, STAGE_TAN_RA]

# Tối đa 2–3 quan hệ sâu (GDD chốt khoảng 2–3) — lấy 3.
const MAX_DEEP_RELATIONSHIPS := 3
# Hội bạn 3–5 người (GDD Mục 8 đã chốt).
const MAX_GROUP_MEMBERS := 5
const MIN_GROUP_MEMBERS := 3
# Thân thiết khởi đầu khi mới quen (PROVISIONAL).
const CLOSENESS_START := 20
# Mỗi lần gặp / nhắn tăng 5 thân thiết (PROVISIONAL).
const INTERACT_GAIN := 5
# Bỏ bê: giảm 10 thân thiết / mỗi 7 ngày (chỉ ngưỡng 7 ngày là số chốt).
const NEGLECT_DROP_PER_STEP := 10
# Ngưỡng thân thiết để lên stage (PROVISIONAL).
const STAGE_HEN_HO_MIN := 50
const STAGE_DINH_HON_MIN := 70
const STAGE_CUOI_MIN := 80
# Có người hỗ trợ: quan hệ sâu có thân thiết >= 50 (PROVISIONAL).
const SUPPORTER_CLOSENESS_MIN := 50
# Solo penalty 40% — điểm giữa khoảng 30–50% đã chốt (PROVISIONAL).
const SOLO_PENALTY_PERCENT := 40

var relations: Array = [] # Array[Dictionary] — quan hệ đang có
var marriages: Array = [] # Array[String] — person_id đã cưới


# --- 1 quan hệ (Dictionary thuần, JSON-safe) ---

# Tạo 1 quan hệ mới — tương đương `new Relationship(...)` trong C#.
# Thân thiết khởi đầu 20, stage QuenBiet. start_day <= 0 thì lấy 1.
static func create_relationship(person_id: String, display_name: String,
		kind: String, start_day: int = 1) -> Dictionary:
	return {
		"person_id": person_id,
		"display_name": display_name,
		"kind": kind,
		"stage": STAGE_QUEN_BIET,
		"closeness": CLOSENESS_START,
		"last_interaction_day": start_day if start_day > 0 else 1,
	}


# Quan hệ sâu? Lover / Spouse / BestFriend / Parent / Child, chưa tan.
# Đúng Relationship.IsDeep trong Social.cs.
static func is_deep(rel: Dictionary) -> bool:
	if rel.is_empty() or String(rel.get("stage", "")) == STAGE_TAN_RA:
		return false
	var kind := String(rel.get("kind", ""))
	return kind == KIND_LOVER or kind == KIND_SPOUSE \
		or kind == KIND_BEST_FRIEND or kind == KIND_PARENT \
		or kind == KIND_CHILD


# Gặp / nhắn: cập nhật ngày tương tác cuối + tăng thân thiết (kẹp
# 0..100). gain mặc định 5 (PROVISIONAL) — đúng Relationship.Interact.
static func interact(rel: Dictionary, game_day: int,
		closeness_gain: int = INTERACT_GAIN) -> bool:
	if rel.is_empty():
		return false
	rel["last_interaction_day"] = game_day
	rel["closeness"] = clampi(int(rel.get("closeness", 0)) + closeness_gain, 0, 100)
	return true


# Bỏ bê: quá 7 ngày game không tương tác thì thân thiết giảm 10 /
# mỗi 7 ngày (chỉ ngưỡng 7 ngày là số chốt). Trả số đã giảm; 0 nếu
# chưa tới ngưỡng. KHÔNG cập nhật last_interaction_day (đúng C# —
# xem quirk trong header: event chỉ gọi 1 lần/ngày).
static func apply_neglect(rel: Dictionary, current_day: int) -> int:
	if rel.is_empty():
		return 0
	var days_idle := current_day - int(rel.get("last_interaction_day", 1))
	if days_idle < PxbBalance.NEGLECT_DAYS_TO_DROP_CLOSENESS:
		return 0
	var steps := days_idle / PxbBalance.NEGLECT_DAYS_TO_DROP_CLOSENESS
	var drop := steps * NEGLECT_DROP_PER_STEP
	rel["closeness"] = clampi(int(rel.get("closeness", 0)) - drop, 0, 100)
	return drop


# Lên stage: HenHo cần thân thiết >= 50; DinhHon phải từ HenHo +
# >= 70; Cuoi phải từ DinhHon + >= 80. Ngưỡng PROVISIONAL. KHÔNG
# kiểm tra Kind (đúng Social.cs — xem quirk trong header).
static func advance_stage(rel: Dictionary, next: String) -> bool:
	if rel.is_empty():
		return false
	if next == STAGE_HEN_HO and int(rel.get("closeness", 0)) < STAGE_HEN_HO_MIN:
		return false
	if next == STAGE_DINH_HON and (String(rel.get("stage", "")) != STAGE_HEN_HO
			or int(rel.get("closeness", 0)) < STAGE_DINH_HON_MIN):
		return false
	if next == STAGE_CUOI and (String(rel.get("stage", "")) != STAGE_DINH_HON
			or int(rel.get("closeness", 0)) < STAGE_CUOI_MIN):
		return false
	rel["stage"] = next
	return true


# Chia tay / ly hôn ở mức quan hệ: stage TanRa, thân thiết về 0.
static func break_up(rel: Dictionary) -> bool:
	if rel.is_empty():
		return false
	rel["stage"] = STAGE_TAN_RA
	rel["closeness"] = 0
	return true


# --- Sổ quan hệ: thao tác trên 1 book Dictionary thuần ---

static func _book_relations(book: Dictionary) -> Array:
	if book.is_empty() or not (book.get("relations") is Array):
		return []
	return book["relations"]


static func get_rel_from_book(book: Dictionary, person_id: String) -> Dictionary:
	for rel in _book_relations(book):
		if rel is Dictionary and String(rel.get("person_id", "")) == person_id:
			return rel
	return {}


static func deep_count_in_book(book: Dictionary) -> int:
	var count := 0
	for rel in _book_relations(book):
		if rel is Dictionary and is_deep(rel):
			count += 1
	return count


static func has_best_friend_in_book(book: Dictionary) -> bool:
	for rel in _book_relations(book):
		if rel is Dictionary and String(rel.get("kind", "")) == KIND_BEST_FRIEND \
				and String(rel.get("stage", "")) != STAGE_TAN_RA:
			return true
	return false


# Thêm quan hệ mới vào book. Trả false nếu đã có người đó, đã đủ 3
# quan hệ sâu, hoặc đã có bạn thân khác — đúng SocialBook.Add.
static func add_rel_to_book(book: Dictionary, rel: Dictionary) -> bool:
	if book.is_empty() or rel.is_empty():
		return false
	var person_id := String(rel.get("person_id", ""))
	if person_id == "":
		return false
	if not (book.get("relations") is Array):
		book["relations"] = []
	if not get_rel_from_book(book, person_id).is_empty():
		return false
	if is_deep(rel) and deep_count_in_book(book) >= MAX_DEEP_RELATIONSHIPS:
		return false
	if String(rel.get("kind", "")) == KIND_BEST_FRIEND \
			and has_best_friend_in_book(book):
		return false
	(book["relations"] as Array).append(rel)
	return true


# Có quan hệ sâu thân thiết đang hỗ trợ mình không (thân thiết
# >= 50, PROVISIONAL) — đúng SocialBook.HasSupporter.
static func has_supporter_in_book(book: Dictionary) -> bool:
	for rel in _book_relations(book):
		if rel is Dictionary and is_deep(rel) \
				and int(rel.get("closeness", 0)) >= SUPPORTER_CLOSENESS_MIN:
			return true
	return false


# EXP nhận được khi được người thân hỗ trợ: +20% (đã chốt).
# Đúng SocialBook.ApplySupportBonus.
static func apply_support_bonus_in_book(book: Dictionary, base_exp: int) -> int:
	if has_supporter_in_book(book):
		return base_exp * (100 + PxbBalance.SUPPORTED_EXP_BONUS_PERCENT) / 100
	return base_exp


# Solo (không có supporter): chậm hơn 40% — điểm giữa khoảng
# 30–50% đã chốt, PROVISIONAL. Đúng SocialBook.ApplySoloPenalty.
static func apply_solo_penalty_in_book(book: Dictionary, base_exp: int) -> int:
	if has_supporter_in_book(book):
		return base_exp
	return base_exp * (100 - SOLO_PENALTY_PERCENT) / 100


# Hội bạn tan nếu 7 ngày game không họp (PROVISIONAL — lấy cùng
# ngưỡng bỏ bê 7 ngày). Trả true nếu nhóm đã tan — đúng
# SocialBook.CheckGroupDissolved.
static func check_group_dissolved(group: Dictionary, current_day: int) -> bool:
	if group.is_empty() or String(group.get("kind", "")) != KIND_FRIEND_GROUP:
		return false
	return current_day - int(group.get("last_interaction_day", 1)) \
		>= PxbBalance.NEGLECT_DAYS_TO_DROP_CLOSENESS


# Ly hôn: chỉ ly hôn được khi vừa là Spouse vừa đang ở Stage Cuoi
# (bug đã sửa 18/11 — xem header). Ở đây chỉ đổi trạng thái; việc
# chia tiền làm ở PxbEconomy.split_assets — đúng SocialBook.Divorce.
static func divorce_in_book(book: Dictionary, person_id: String) -> bool:
	var rel := get_rel_from_book(book, person_id)
	if rel.is_empty() or String(rel.get("kind", "")) != KIND_SPOUSE \
			or String(rel.get("stage", "")) != STAGE_CUOI:
		return false
	break_up(rel)
	if book.get("marriages") is Array:
		(book["marriages"] as Array).erase(person_id)
	return true


static func record_marriage_in_book(book: Dictionary, person_id: String) -> bool:
	if book.is_empty() or person_id == "":
		return false
	if not (book.get("marriages") is Array):
		book["marriages"] = []
	if not (book["marriages"] as Array).has(person_id):
		(book["marriages"] as Array).append(person_id)
	return true


static func is_married_to_in_book(book: Dictionary, person_id: String) -> bool:
	if book.is_empty() or not (book.get("marriages") is Array):
		return false
	return (book["marriages"] as Array).has(person_id)


# Áp bỏ bê cho TOÀN BỘ quan hệ trong sổ ở ngày game hiện tại.
# Trả tổng số thân thiết đã giảm — event gọi 1 lần/ngày.
static func apply_neglect_all_in_book(book: Dictionary, current_day: int) -> int:
	var total := 0
	for rel in _book_relations(book):
		if rel is Dictionary:
			total += apply_neglect(rel, current_day)
	return total


# NPC bạn thân lấp chỗ cho slice (GDD Mục 11: "NPC bạn thân lấp chỗ
# tạm thời"). Tên + person_id là TẠM — PxbStory sau này thay bằng
# NPC thật. Chỉ gọi 1 lần khi new game / bắt đầu slice.
static func seed_slice_in_book(book: Dictionary, start_day: int = 1) -> bool:
	if book.is_empty():
		return false
	if not get_rel_from_book(book, "ban-than").is_empty():
		return false
	var friend := create_relationship("ban-than", "Bạn thân",
		KIND_BEST_FRIEND, start_day)
	return add_rel_to_book(book, friend)


# --- Hàm instance: bao quanh book của chính node này ---

func book() -> Dictionary:
	return {"relations": relations, "marriages": marriages}


func all_relations() -> Array:
	return relations.duplicate(true)


func get_rel(person_id: String) -> Dictionary:
	return get_rel_from_book(book(), person_id)


func deep_count() -> int:
	return deep_count_in_book(book())


func has_best_friend() -> bool:
	return has_best_friend_in_book(book())


func add_rel(rel: Dictionary) -> bool:
	var b := book()
	var ok := add_rel_to_book(b, rel)
	relations = b["relations"]
	return ok


func has_supporter() -> bool:
	return has_supporter_in_book(book())


func apply_support_bonus(base_exp: int) -> int:
	return apply_support_bonus_in_book(book(), base_exp)


func apply_solo_penalty(base_exp: int) -> int:
	return apply_solo_penalty_in_book(book(), base_exp)


func divorce(person_id: String) -> bool:
	var b := book()
	var ok := divorce_in_book(b, person_id)
	relations = b["relations"]
	marriages = b["marriages"]
	return ok


func record_marriage(person_id: String) -> bool:
	var b := book()
	var ok := record_marriage_in_book(b, person_id)
	marriages = b["marriages"]
	return ok


func is_married_to(person_id: String) -> bool:
	return is_married_to_in_book(book(), person_id)


func apply_neglect_all(current_day: int) -> int:
	return apply_neglect_all_in_book(book(), current_day)


func seed_slice(start_day: int = 1) -> bool:
	var b := book()
	var ok := seed_slice_in_book(b, start_day)
	relations = b["relations"]
	return ok


func reset_book() -> void:
	relations = []
	marriages = []


# --- Save / load (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {"relations": relations.duplicate(true),
		"marriages": marriages.duplicate()}


static func from_data(d: Dictionary) -> PxbSocial:
	var s := PxbSocial.new()
	if d.is_empty():
		return s
	if d.get("relations") is Array:
		for rel in d["relations"]:
			if not (rel is Dictionary):
				continue
			var r := (rel as Dictionary).duplicate(true)
			# Bỏ quan hệ bẩn: thiếu person_id, kind/stage lạ.
			if String(r.get("person_id", "")) == "":
				continue
			if not KINDS.has(String(r.get("kind", ""))):
				continue
			if not STAGES.has(String(r.get("stage", ""))):
				continue
			r["closeness"] = clampi(int(r.get("closeness", CLOSENESS_START)), 0, 100)
			r["last_interaction_day"] = maxi(1, int(r.get("last_interaction_day", 1)))
			if s.get_rel(String(r["person_id"])).is_empty():
				s.relations.append(r)
	if d.get("marriages") is Array:
		for m in d["marriages"]:
			if m is String and m != "" and not s.marriages.has(m):
				s.marriages.append(m)
	return s
