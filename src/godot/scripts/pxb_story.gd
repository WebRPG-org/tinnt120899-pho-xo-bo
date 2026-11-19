class_name PxbStory
extends Node
## Phố Xô Bồ — PXB_Story (Godot G2, bước 5/17).
## Port trung thực PXB_Story.js (src/nadia/www/js/plugins/
## PXB_Story.js) / PlayerProgress.cs (src/client/Assets/Scripts/
## PlayerProgress.cs) — cốt truyện 5 chương + nhiều kết thúc chữa
## lành, GDD Mục 9 + Mục 12.
##
## - 5 chương gắn bậc: 1 Lên Phố (Lao động) → 2 Lập Nghiệp (Cận trung
##   lưu) → 3 Khủng Hoảng (bài kiểm tra bậc, có thể tụt nhưng không
##   phạt nặng) → 4 Vực Dậy (Trung lưu) → 5 Thành Đạt / An Yên (nhiều
##   kết thúc đều tính là thắng — Mục 12, chữa lành).
## - Chương 4 cần 3 quest giúp NPC đang khủng hoảng + ít nhất 1 quan
##   hệ thân thiết (GDD Mục 9; has_close_relationship lấy từ PxbSocial
##   — quan hệ sâu thân thiết >= 50 là "có người hỗ trợ").
## - Bám Nadia (docs/nadia-reference.md): NPC có câu chuyện mất mục
##   tiêu của riêng họ — giúp họ thì họ giúp lại mình; thất bại không
##   bị phạt, NPC giúp đỡ và được làm lại.
## - Số ĐÃ CHỐT (GDD Mục 9 / GameBalance.cs / PlayerProgress.cs):
##   Trí 40 (mở chương 2) / 60 (mở chương 5) / 90 (Học giả);
##   Danh vọng 200 (chương 2) / 500 (chương 5) / 1500 (Học giả);
##   tài sản 10 tỉ (Giám đốc) / 100 tỉ (Siêu giàu);
##   An Yên 80 (Gia đình / Tự do); Danh vọng 100 / An Yên 30
##   (ngưỡng rank có thể tụt ở chương 3); 3 quest giúp người (chương 4).
##   Ngưỡng lấy từ PxbBalance (đã thêm đợt này) — không hardcode lại.
## - Tiến trình lưu dạng Dictionary thuần (JSON-safe): chapter,
##   help_quests_done, chapter3_passed, ending, unlocked_chapters.
##
## QUIRK GIỮ ĐÚNG C# (không tự sửa):
## - can_open_chapter(KhungHoang) LUÔN true — chương 3 là bài kiểm
##   tra, mở khi đã qua chương 2. Điều kiện "đã qua chương 2" do
##   story state kiểm (advance_chapter chỉ đi chapter+1 nên khi mở
##   chương 3 thì chapter đã = 2), KHÔNG phải hàm này.
## - suggest_ending() có THỨ TỰ ƯU TIÊN CỨNG: SieuGiau (≥100 tỉ)
##   → GiamDoc (≥10 tỉ) → HocGia (Trí ≥ 90 VÀ Danh vọng ≥ 1500)
##   → GiaDinh (có vợ/chồng VÀ An Yên ≥ 80) → TuDo (An Yên ≥ 80)
##   → ChuaMo. Người chơi đủ điều kiện nhiều ending cùng lúc vẫn
##   chỉ nhận ending ưu tiên cao nhất — để GDD/PM xem lại (ghi
##   trong docs/test-report.md từ 18/11).
## - rank_at_risk() chỉ báo "có thể tụt bậc" khi Danh vọng < 100
##   HOẶC An Yên < 30 — không tự trừ bậc, không phạt (Mục 12).
##
## LỆCH C# SO VỚI GDD (ghi để GDD/PM xem lại, port giữ đúng C#):
## - Chương 2: GDD ghi "Trí 40 hoặc Cao đẳng, Danh vọng 200" —
##   C# chỉ kiểm Trí ≥ 40 HOẶC Danh vọng ≥ 200, không có đường
##   riêng cho bằng Cao đẳng. (GameBalance: Cao đẳng cho Trí 40
##   nên thực tế 2 đường trùng nhau.)
## - Chương 5 Học giả: GDD ghi "Tiến sĩ, Trí 90, Danh vọng 1.500" —
##   C# chỉ kiểm Trí ≥ 90 VÀ Danh vọng ≥ 1500, không kiểm bằng
##   Tiến sĩ. (GameBalance: Tiến sĩ cho Trí 90 / Danh vọng 1500
##   nên thực tế cũng trùng.)
## - Chương 5 Gia đình: GDD ghi "Trung lưu + vợ/chồng + An Yên 80" —
##   C# chỉ kiểm có vợ/chồng VÀ An Yên ≥ 80, không kiểm rank Trung lưu.
##
## Không có số PROVISIONAL nào trong file này: mọi ngưỡng đều là số
## ĐÃ CHỐT ở trên. Các hàm chỉ đọc chỉ số hiện tại của người chơi
## (Trí / Danh vọng / tài sản / An Yên lấy từ PxbStats / PxbEconomy
## khi gọi từ event — ở đây truyền vào làm tham số).

# Chương (port enum PlayerProgress.cs).
const CHAPTER_LEN_PHO := 1 # Lên Phố — Lao động
const CHAPTER_LAP_NGHIEP := 2 # Lập Nghiệp — Cận trung lưu
const CHAPTER_KHUNG_HOANG := 3 # Khủng Hoảng — bài kiểm tra bậc
const CHAPTER_VUC_DAY := 4 # Vực Dậy — Trung lưu
const CHAPTER_THANH_DAT := 5 # Thành Đạt / An Yên — nhánh rank

# Tên hiển thị tiếng Việt của từng chương (chỉ để event / UI dùng).
const CHAPTER_NAMES := {
	1: "Lên Phố",
	2: "Lập Nghiệp",
	3: "Khủng Hoảng",
	4: "Vực Dậy",
	5: "Thành Đạt",
}

# Kết thúc (port enum PlayerProgress.cs).
const ENDING_GIAM_DOC := "GiamDoc" # Giám đốc — Thượng lưu, tài sản 10 tỉ
const ENDING_HOC_GIA := "HocGia" # Học giả — Tiến sĩ, Trí 90, Danh vọng 1500
const ENDING_GIA_DINH := "GiaDinh" # Gia đình — vợ/chồng + An Yên 80
const ENDING_TU_DO := "TuDo" # Tự do — An Yên 80, sống an yên
const ENDING_SIEU_GIAU := "SieuGiau" # Siêu giàu — tài sản 100 tỉ
const ENDING_CHUA_MO := "ChuaMo" # Chưa mở — chưa đủ điều kiện ending nào
const ENDINGS := [ENDING_GIAM_DOC, ENDING_HOC_GIA, ENDING_GIA_DINH,
	ENDING_TU_DO, ENDING_SIEU_GIAU, ENDING_CHUA_MO]

var chapter: int = CHAPTER_LEN_PHO # chương hiện tại (1–5)
var help_quests_done: int = 0 # số quest giúp NPC đã làm xong
var chapter3_passed: bool = false # đã vượt bài kiểm tra chương 3 chưa
var ending: String = ENDING_CHUA_MO # ending đã mở (mặc định chưa mở)
var unlocked_chapters: Array = [CHAPTER_LEN_PHO] # các chương đã mở, không trùng


# --- Điều kiện mở chương — đúng PlayerProgress.CanOpenChapter ---

# chapter: số 1–5. tri / fame / assets: chỉ số hiện tại.
# has_close_relationship: có ít nhất 1 quan hệ thân thiết.
# help_quests_done_param: số quest giúp NPC đã làm xong.
# Chương lạ (ngoài 1–5) → false.
static func can_open_chapter(chapter_num: int, tri: int, fame: int,
		assets: int, has_close_relationship: bool,
		help_quests_done_param: int) -> bool:
	if chapter_num == CHAPTER_LEN_PHO:
		return true
	if chapter_num == CHAPTER_LAP_NGHIEP:
		return tri >= PxbBalance.CHAPTER2_TRI_MIN \
			or fame >= PxbBalance.CHAPTER2_FAME_MIN
	# Chương 3 là bài kiểm tra, mở khi đã qua chương 2 — điều kiện
	# "đã qua chương 2" do story state kiểm (advance_chapter chỉ đi
	# chapter+1), không phải hàm này. Giữ đúng C#.
	if chapter_num == CHAPTER_KHUNG_HOANG:
		return true
	if chapter_num == CHAPTER_VUC_DAY:
		return help_quests_done_param >= PxbBalance.CHAPTER4_HELP_QUESTS_MIN \
			and has_close_relationship
	if chapter_num == CHAPTER_THANH_DAT:
		return tri >= PxbBalance.CHAPTER5_TRI_MIN \
			or fame >= PxbBalance.CHAPTER5_FAME_MIN \
			or assets >= PxbBalance.DIRECTOR_ASSETS_VND
	return false


# --- Gợi ý kết thúc — đúng PlayerProgress.SuggestEnding ---

# THỨ TỰ ƯU TIÊN CỨNG (giữ đúng C# — xem quirk trong header):
# SieuGiau → GiamDoc → HocGia → GiaDinh → TuDo → ChuaMo.
static func suggest_ending(assets: int, tri: int, fame: int,
		an_yen: int, has_spouse: bool) -> String:
	if assets >= PxbBalance.SUPER_RICH_ASSETS_VND:
		return ENDING_SIEU_GIAU
	if assets >= PxbBalance.DIRECTOR_ASSETS_VND:
		return ENDING_GIAM_DOC
	if tri >= PxbBalance.ENDING_HOC_GIA_TRI_MIN \
			and fame >= PxbBalance.ENDING_HOC_GIA_FAME_MIN:
		return ENDING_HOC_GIA
	if has_spouse and an_yen >= PxbBalance.FAMILY_ENDING_AN_YEN:
		return ENDING_GIA_DINH
	if an_yen >= PxbBalance.FAMILY_ENDING_AN_YEN:
		return ENDING_TU_DO
	return ENDING_CHUA_MO


# Bậc có thể tụt ở chương 3 nếu Danh vọng / An Yên thấp — chỉ báo
# nguy cơ, không tự trừ bậc, không phạt (Mục 12: thất bại không bị
# phạt, NPC giúp đỡ và được làm lại).
# Đúng PlayerProgress.RankAtRisk.
static func rank_at_risk(fame: int, an_yen: int) -> bool:
	return fame < PxbBalance.RANK_AT_RISK_FAME_MAX \
		or an_yen < PxbBalance.RANK_AT_RISK_AN_YEN_MAX


# Kiểm tra 1 ending có phải giá trị hợp lệ không.
static func is_valid_ending(ending_value: String) -> bool:
	return ENDINGS.has(ending_value)


# --- Thao tác trên story state của chính node này ---

# Thử mở chương tiếp theo (chapter+1) bằng can_open_chapter. Nếu đủ
# điều kiện thì tăng chapter, thêm vào unlocked_chapters (không
# trùng), trả true; không đủ điều kiện trả false.
# Chương 3 mở được luôn theo can_open_chapter nhưng chỉ advance khi
# đã qua chương 2: advance chỉ đi chapter+1 nên khi mở chương 3
# thì chapter đã = 2 — guard dưới đây ghi rõ logic này để không ai
# gọi advance_chapter với state nhảy cóc (ví dụ sửa tay chapter = 1
# rồi đòi mở chương 3).
func advance_chapter(tri: int, fame: int, assets: int,
		has_close_relationship: bool) -> bool:
	var next := chapter + 1
	if next > CHAPTER_THANH_DAT:
		return false
	# Chương 3 chỉ mở khi đã qua chương 2.
	if next == CHAPTER_KHUNG_HOANG and chapter < CHAPTER_LAP_NGHIEP:
		return false
	if not can_open_chapter(next, tri, fame, assets,
			has_close_relationship, help_quests_done):
		return false
	chapter = next
	if not unlocked_chapters.has(next):
		unlocked_chapters.append(next)
	return true


# Ghi 1 quest giúp NPC đã xong — tăng help_quests_done lên 1, trả số
# mới. (Chương 4 cần >= 3.)
func record_help_quest() -> int:
	help_quests_done += 1
	return help_quests_done


# Vượt bài kiểm tra chương 3 — chỉ khi đang ở chương 3 thì đánh
# dấu chapter3_passed = true, trả true; ngược lại false.
func pass_chapter3() -> bool:
	if chapter != CHAPTER_KHUNG_HOANG:
		return false
	chapter3_passed = true
	return true


# Đặt ending — chỉ nhận 1 trong 6 giá trị Ending, giá trị lạ trả
# false (không đổi state).
func set_ending(ending_value: String) -> bool:
	if not is_valid_ending(ending_value):
		return false
	ending = ending_value
	return true


# Gợi ý ending rồi LƯU vào ending, trả ending.
func suggest_ending_now(assets: int, tri: int, fame: int,
		an_yen: int, has_spouse: bool) -> String:
	ending = suggest_ending(assets, tri, fame, an_yen, has_spouse)
	return ending


func chapter_name() -> String:
	return String(CHAPTER_NAMES.get(chapter, ""))


func reset_story() -> void:
	chapter = CHAPTER_LEN_PHO
	help_quests_done = 0
	chapter3_passed = false
	ending = ENDING_CHUA_MO
	unlocked_chapters = [CHAPTER_LEN_PHO]


# --- Save / load (dữ liệu thuần, JSON-safe) ---

func data() -> Dictionary:
	return {"chapter": chapter, "help_quests_done": help_quests_done,
		"chapter3_passed": chapter3_passed, "ending": ending,
		"unlocked_chapters": unlocked_chapters.duplicate()}


static func from_data(d: Dictionary) -> PxbStory:
	var s := PxbStory.new()
	if d.is_empty():
		return s
	var ch := int(d.get("chapter", CHAPTER_LEN_PHO))
	s.chapter = clampi(ch, CHAPTER_LEN_PHO, CHAPTER_THANH_DAT)
	s.help_quests_done = maxi(0, int(d.get("help_quests_done", 0)))
	s.chapter3_passed = bool(d.get("chapter3_passed", false))
	var e := String(d.get("ending", ENDING_CHUA_MO))
	s.ending = e if is_valid_ending(e) else ENDING_CHUA_MO
	if d.get("unlocked_chapters") is Array:
		for c in d["unlocked_chapters"]:
			var ci := int(c)
			if ci >= CHAPTER_LEN_PHO and ci <= CHAPTER_THANH_DAT \
					and not s.unlocked_chapters.has(ci):
				s.unlocked_chapters.append(ci)
		# Chương hiện tại luôn phải nằm trong danh sách đã mở.
		if not s.unlocked_chapters.has(s.chapter):
			s.unlocked_chapters.append(s.chapter)
		s.unlocked_chapters.sort()
	return s
