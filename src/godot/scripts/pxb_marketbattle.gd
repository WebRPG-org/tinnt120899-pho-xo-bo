class_name PxbMarketBattle
extends Node
## Phố Xô Bồ — PXB_MarketBattle (Godot G2, plugin cuối 17/17).
## Port trung thực PXB_MarketBattle.js (src/nadia/www/js/plugins/
## PXB_MarketBattle.js) + docs/market-battle-design.md — mode chiến
## thuật vui "Bụi Đời Chợ Cá": 3v3/5v5 theo lượt trên lưới
## isometric, vũ khí hài, đội thắng giữ sạp chợ 1 tuần.
##
## - LUẬT ĐÃ CHỐT (chủ duyệt 20/11 06:06, chat Duyệt task, cả 7
##   điểm §11 design doc): lưới 12×9, di chuyển 3 ô; passive 6 vai +
##   4 vũ khí; lượt 10s / trận 180s / tối đa 12 vòng / thắng bằng
##   % HP; giữ sạp 7 ngày: giá sỉ −10%, thuế −20%, Danh vọng
##   +10/ngày; buff Tướng Cướp +10% sát thương / Cảnh sát +10% Max
##   HP khi thủ sạp; điều kiện mở trận 5 điểm; Danh vọng thắng +50 /
##   hòa +20 / thua +10. Mọi số trong file này đều là số ĐÃ CHỐT —
##   không còn số PROVISIONAL nào ở đây.
## - Đây CHỈ là logic lõi thuần (như JS): tạo trận, xếp vai, lượt
##   đi, đánh/hỗ trợ, thắng/thua/hòa, giữ sạp, buff danh hiệu, chặn
##   trận thiếu người. KHÔNG có scene / UI / bản đồ trận — scene
##   riêng (vẽ lưới isometric qua iso_map.gd) là việc sau.
## - Trận đấu sống trong biến instance (không vào save — như battle
##   MV); quyền GIỮ SẠP + lịch sử trận sống trong `_state` (holds +
##   history) và đi theo save qua data() / from_data().
## - Đấu sĩ + trận là Dictionary thuần (JSON-safe), giống JS object:
##   hàm nào cũng nhận/trả Dictionary, không giữ method trong save.
## - Không máu me, không chết, không mất đồ vĩnh viễn (GDD Mục 11 +
##   Mục 12): hết HP = "ngã sạp" (ngồi bệt, xỉu vì cười); hết trận
##   hồi đầy HP. Thua không bị phạt — thua vẫn +10 Danh vọng.
##
## QUIRK GIỮ ĐÚNG JS (không tự sửa — để GDD/PM xem lại):
## - Thứ tự lượt xen kẽ A1 → B1 → A2 → B2 … (không dùng Trí làm
##   sáng kiến).
## - Thứ tự tính sát thương: vũ khí → × Tím/Cam → × Tướng Cướp →
##   làm tròn xuống → × giảm thương Tank → trừ HP. Không chí mạng
##   ngẫu nhiên — số cố định để test được.
## - Ghế nhựa chỉ đẩy lùi khi mục tiêu còn đứng, sát thương > 0 và
##   không bị né; đẩy theo trục chênh lệch lớn hơn (dx vs dy).
## - Hỗ trợ (Vàng) hồi đúng 12 HP, kẹp ở Max HP (hồi thừa mất).
## - Hết giờ / hết vòng: thắng bằng tổng % HP (làm tròn 2 chữ số);
##   bằng nhau thì hòa — hòa = không đội nào giữ sạp.
## - Đội giữ thắng trận thủ sạp thì giữ tiếp đến hết hạn cũ (không
##   cộng thêm 7 ngày): finish_battle ghi hold mới chỉ khi trận có
##   stallId và có đội thắng; đội giữ cũ thắng thì hold được ghi đè
##   với startGameDay = ngày trận — xem khác biệt #4 dưới đây.
## - GDScript không có exception — các hàm trả bool/Dictionary thay
##   vì throw.
##
## LỆCH ĐÃ GHI NHẬN (JS → GDScript):
## 1. `$gameSystem.pxbMarketBattle` → `_state` trong instance +
##    data() / from_data() (save thật là việc SaveCloud).
## 2. `titlesOf()` đọc `PXB_Titles` toàn cục khi đấu sĩ không có
##    danh sách riêng — Godot không có global đó nên chỉ dùng
##    `fighter["titles"]` (mảng truyền trực tiếp, như JS khi test
##    thuần). Event muốn dùng sổ danh hiệu chung thì truyền titles
##    của người chơi vào lúc create_fighter.
## 3. Chia số màu trộn dùng `/ 2.0` (float) thay vì `/ 2` của JS —
##    GDScript chia int ra int (làm tròn xuống), lệch vai khi tổng
##    lẻ; float giữ đúng so sánh của JS.
## 4. Ghi hold khi đội giữ cũ thắng trận thủ sạp: JS ghi đè hold với
##    startGameDay = ngày trận (tức gia hạn ngầm 7 ngày từ ngày
##    trận — mâu thuẫn design doc §6 "không cộng thêm 7 ngày").
##    Port giữ đúng JS (ghi đè) để không lệch logic đã test; design
##    doc §6 cần chủ chốt lại nếu muốn sửa — xem ghi chú cuối file
##    test. TODO: hỏi chủ: thủ sạp thắng có gia hạn không?
## 5. Signal `turn_changed(fighter_id)` / `battle_finished(winner)`
##    thêm cho scene sau nối (JS không có event) — không đổi logic.

# --- Hằng ĐÃ CHỐT (20/11 06:06 — design doc §11, 7 điểm) ---

# Lưới trận 12×9 (điểm 1).
const GRID_W := 12
const GRID_H := 9
# HP gốc 100; Tank Đỏ Max HP ×1,5, sát thương nhận ×0,8.
const BASE_HP := 100
const TANK_HP_MULT := 1.5
const TANK_DMG_TAKEN_MULT := 0.8
# Di chuyển gốc 3 ô/lượt; Xanh chiến thuật +1.
const BASE_MOVE := 3
const TACTICIAN_MOVE_BONUS := 1
# Lượt tối đa 10 giây; trận tối đa 180 giây (~3 phút GDD);
# tối đa 12 vòng (lưới an toàn). (điểm 3)
const TURN_SECONDS := 10
const BATTLE_SECONDS := 180
const MAX_ROUNDS := 12
# Giữ sạp 7 ngày game (1 tuần GDD). (điểm 4)
const HOLD_DAYS := 7
# Quyền lợi giữ sạp: giá sỉ −10%, thuế sạp −20%, Danh vọng +10/ngày.
const WHOLESALE_DISCOUNT_PERCENT := 10
const STALL_TAX_CUT_PERCENT := 20
const HOLD_FAME_PER_DAY := 10
# Danh vọng trận: thắng +50, hòa +20, thua +10 (thua không phạt). (điểm 7)
const FAME_WIN := 50
const FAME_DRAW := 20
const FAME_LOSS := 10
# Buff danh hiệu: Tướng Cướp +10% sát thương ở chợ; Cảnh sát +10%
# Max HP khi thủ sạp đội mình đang giữ. (điểm 5)
const BANDIT_DMG_BONUS_PERCENT := 10
const POLICE_HP_BONUS_PERCENT := 10
# Vai hỗ trợ (Vàng) hồi 12 HP cho đồng đội kề bên.
const SUPPORT_HEAL := 12
# Vai chính xác (Tím) sát thương ×1,25; burst (Cam) đòn đầu ×2.
const SNIPER_DMG_MULT := 1.25
const BURST_FIRST_HIT_MULT := 2.0
# Lịch sử trận giữ tối đa 50 trận gần nhất.
const MAX_HISTORY := 50

# --- Vũ khí hài (điểm 2) ---
# key -> {key, name, dmg, range, knockback}
const WEAPONS: Dictionary = {
	"Chao": {"key": "Chao", "name": "Chảo", "dmg": 12, "range": 1, "knockback": 0},
	"CaKho": {"key": "CaKho", "name": "Cá khô", "dmg": 8, "range": 2, "knockback": 0},
	"GheNhua": {"key": "GheNhua", "name": "Ghế nhựa", "dmg": 15, "range": 1, "knockback": 1},
	"Loa": {"key": "Loa", "name": "Loa", "dmg": 10, "range": 3, "knockback": 0},
}

# --- Vai theo màu chỉ số (điểm 2) ---
# key -> {key, color, name, stat}
const ROLES: Dictionary = {
	"Do": {"key": "Do", "color": "Đỏ", "name": "Tank", "stat": "the"},
	"Xanh": {"key": "Xanh", "color": "Xanh", "name": "Chiến thuật", "stat": "tri"},
	"Vang": {"key": "Vang", "color": "Vàng", "name": "Hỗ trợ", "stat": "tam"},
	"Tim": {"key": "Tim", "color": "Tím", "name": "Chính xác", "stat": "ky"},
	"Cam": {"key": "Cam", "color": "Cam", "name": "Burst", "stat": "dung"},
	"Luc": {"key": "Luc", "color": "Lục", "name": "Mẹo", "stat": "sang"},
}

# Thứ tự ưu tiên khi 2 màu hòa điểm: vai trộn trước vai gốc (vai trộn
# là trung bình cộng nên không bao giờ vượt vai gốc, chỉ hòa được);
# chỉ số cân bằng cả 3 gốc → Tím (Kỷ).
const ROLE_TIE_ORDER: Array[String] = ["Tim", "Cam", "Luc", "Do", "Xanh", "Vang"]

# Đội hợp lệ: 3v3 hoặc 5v5 (GDD đã chốt).
const TEAM_SIZES: Array[int] = [3, 5]

const STATUS_FIGHTING := "dang-danh"
const STATUS_FINISHED := "ket-thuc"

const RESULT_WIN_A := "A"
const RESULT_WIN_B := "B"
const RESULT_DRAW := "hoa"

# Lý do chặn trận (create_battle / can_challenge trả về).
const BLOCK_TEAM_TOO_SMALL := "doi-thieu-nguoi"
const BLOCK_TEAM_UNEQUAL := "doi-khong-bang-nhau"
const BLOCK_TEAM_SIZE_INVALID := "co-doi-khong-hop-le"
const BLOCK_HOLDING_OTHER_STALL := "dang-giu-sap-khac"
const BLOCK_ALREADY_HOLDING_THIS := "da-giu-sap-nay"

# Danh hiệu liên quan (tên đúng PxbTitles / TitleConflict).
const TITLE_BANDIT := "Tướng Cướp"
const TITLE_POLICE := "Cảnh sát"

## Phát khi lượt chuyển sang đấu sĩ khác.
signal turn_changed(fighter_id: String)
## Phát khi trận kết thúc: winner = "A" / "B" / "hoa".
signal battle_finished(winner: String)

# State giữ sạp + lịch sử (đi theo save qua data()/from_data()).
var _state: Dictionary = {
	"holds": {},
	"history": [],
}
# Trận hiện tại (biến instance — như battle MV, không vào save).
var _current_battle: Dictionary = {}


func _state_default() -> Dictionary:
	return {"holds": {}, "history": []}


func reset_state() -> bool:
	_state = _state_default()
	_current_battle = {}
	return true


func data() -> Dictionary:
	return _state.duplicate(true)


func from_data(d: Dictionary) -> void:
	var clean: Dictionary = _state_default()
	if d.has("holds") and d["holds"] is Dictionary:
		var holds: Dictionary = {}
		for stall_id in (d["holds"] as Dictionary).keys():
			var h: Dictionary = (d["holds"] as Dictionary)[stall_id]
			if h is Dictionary and h.has("teamId") and h.has("startGameDay") and h.has("untilGameDay"):
				holds[str(stall_id)] = {
					"stallId": str(h.get("stallId", stall_id)),
					"teamId": str(h["teamId"]),
					"teamName": str(h.get("teamName", "")),
					"startGameDay": int(h["startGameDay"]),
					"untilGameDay": int(h["untilGameDay"]),
				}
		clean["holds"] = holds
	if d.has("history") and d["history"] is Array:
		var hist: Array = []
		for entry in (d["history"] as Array):
			if entry is Dictionary and entry.has("result"):
				hist.append((entry as Dictionary).duplicate(true))
		clean["history"] = hist.slice(0, MAX_HISTORY)
	_state = clean


# --- Vai theo màu chỉ số ---

## Tính 6 màu từ 3 chỉ số gốc (đúng docs/stats.md: Tím=(Thể+Trí)/2,
## Cam=(Thể+Tâm)/2, Lục=(Trí+Tâm)/2) rồi lấy màu cao nhất.
static func role_from_stats(stats: Dictionary) -> String:
	var the: float = float(stats.get("the", 50))
	var tri: float = float(stats.get("tri", 50))
	var tam: float = float(stats.get("tam", 50))
	var values: Dictionary = {
		"Do": the,
		"Xanh": tri,
		"Vang": tam,
		"Tim": (the + tri) / 2.0,
		"Cam": (the + tam) / 2.0,
		"Luc": (tri + tam) / 2.0,
	}
	var best: String = ROLE_TIE_ORDER[0]
	for key in ROLE_TIE_ORDER:
		if float(values[key]) > float(values[best]):
			best = key
	return best


# --- Đấu sĩ (Dictionary thuần, JSON-safe) ---

## Tạo 1 đấu sĩ. role: "Do"|"Xanh"|"Vang"|"Tim"|"Cam"|"Luc" — bỏ
## trống thì tự suy từ stats (role_from_stats). weapon_key:
## "Chao"|"CaKho"|"GheNhua"|"Loa". titles: Array[String] danh hiệu
## đang có (để tính buff; bỏ trống = không buff).
## Max HP tính ở create_battle (vì buff Cảnh sát phụ thuộc đội thủ sạp).
static func create_fighter(id: String, fighter_name: String, role: String, weapon_key: String, stats: Dictionary = {}, titles: Array = []) -> Dictionary:
	var st: Dictionary = {
		"the": int(stats.get("the", 50)),
		"tri": int(stats.get("tri", 50)),
		"tam": int(stats.get("tam", 50)),
	}
	var r: String = role
	if r == "" or not ROLES.has(r):
		r = role_from_stats(st)
	var w: Dictionary = WEAPONS.get(weapon_key, WEAPONS["Chao"])
	var title_list: Array[String] = []
	for t in titles:
		title_list.append(str(t))
	return {
		"id": id,
		"name": fighter_name,
		"role": r,
		"weapon": str(w["key"]),
		"stats": st,
		"titles": title_list,
		"x": -1,
		"y": -1,
		"hp": BASE_HP,
		"maxHp": BASE_HP,
		"alive": true,
		"hasAttackedThisBattle": false,
		"dodgedThisRound": false,
		"movedThisTurn": false,
		"actedThisTurn": false,
	}


## Max HP của đấu sĩ: gốc 100, Đỏ ×1,5; Cảnh sát +10% khi thủ sạp
## đội mình đang giữ.
static func compute_max_hp(fighter: Dictionary, is_defender: bool) -> int:
	var hp: float = float(BASE_HP)
	if str(fighter.get("role", "")) == "Do":
		hp = floor(hp * TANK_HP_MULT)
	if is_defender and has_title(fighter, TITLE_POLICE):
		hp = floor(hp * (100.0 + POLICE_HP_BONUS_PERCENT) / 100.0)
	return int(hp)


## Tầm di chuyển: 3 ô, Xanh chiến thuật +1.
static func move_range_of(fighter: Dictionary) -> int:
	return BASE_MOVE + (TACTICIAN_MOVE_BONUS if str(fighter.get("role", "")) == "Xanh" else 0)


static func has_title(fighter: Dictionary, title: String) -> bool:
	var list: Array = fighter.get("titles", [])
	for t in list:
		if str(t).to_lower() == title.to_lower():
			return true
	return false


# --- Lưới ---

static func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < GRID_W and y >= 0 and y < GRID_H


static func manhattan(ax: int, ay: int, bx: int, by: int) -> int:
	return abs(ax - bx) + abs(ay - by)


func fighter_at(battle: Dictionary, x: int, y: int) -> Dictionary:
	for f in all_fighters(battle):
		if bool(f.get("alive", false)) and int(f.get("x", -1)) == x and int(f.get("y", -1)) == y:
			return f
	return {}


func all_fighters(battle: Dictionary) -> Array:
	var list: Array = []
	if battle.is_empty():
		return list
	var a: Array = (battle.get("teamA", {}) as Dictionary).get("fighters", [])
	var b: Array = (battle.get("teamB", {}) as Dictionary).get("fighters", [])
	list.append_array(a)
	list.append_array(b)
	return list


func find_fighter(battle: Dictionary, fighter_id: String) -> Dictionary:
	for f in all_fighters(battle):
		if str(f.get("id", "")) == fighter_id:
			return f
	return {}


## Vị trí xuất phát: đội A cột 0–1, đội B cột 10–11, hàng rải đều
## giữa lưới (đối xứng, không bên nào lợi thế).
static func spawn_positions(team_size: int, is_team_a: bool) -> Array:
	var positions: Array = []
	var start_row: int = int((GRID_H - team_size) / 2)
	for i in range(team_size):
		var col: int = (i % 2) if is_team_a else (GRID_W - 1 - (i % 2))
		positions.append({"x": col, "y": start_row + i})
	return positions


# --- Tạo trận ---

## Tạo trận mới. options: { teamA: {id, name, fighters[]},
## teamB: {...}, stallId (String, "" = giao hữu, không giữ sạp),
## gameDay (int, mặc định 1), defenderTeam ("A"|"B"|"" — đội nào
## đang giữ sạp khi trận này là trận tranh sạp) }.
## Trả {ok: true, battle} hoặc {ok: false, reason} — chặn khi thiếu
## người / cỡ đội không hợp lệ / 2 đội không bằng nhau. (điểm 6)
func create_battle(options: Dictionary) -> Dictionary:
	var team_a: Dictionary = options.get("teamA", {})
	var team_b: Dictionary = options.get("teamB", {})
	var fa: Array = team_a.get("fighters", [])
	var fb: Array = team_b.get("fighters", [])
	if fa.is_empty() or fb.is_empty():
		return {"ok": false, "reason": BLOCK_TEAM_TOO_SMALL}
	if fa.size() != fb.size():
		return {"ok": false, "reason": BLOCK_TEAM_UNEQUAL}
	if not TEAM_SIZES.has(fa.size()):
		return {"ok": false, "reason": BLOCK_TEAM_SIZE_INVALID}
	var game_day: int = int(options.get("gameDay", 1))
	if game_day <= 0:
		game_day = 1
	var defender_team: String = str(options.get("defenderTeam", ""))
	if defender_team != "A" and defender_team != "B":
		defender_team = ""

	# G4 buoc 9 (vong 68): doi thach dau dang giu sap thi khong mo
	# tran tranh sap moi (luat can_challenge: 1 doi giu toi da 1 sap).
	# Tran khong tranh sap (stallId "") thi khong chan.
	var stall_id: String = str(options.get("stallId", ""))
	if stall_id != "":
		var chk: Dictionary = can_challenge(_state, str(team_a.get("id", "doi-a")), stall_id, game_day)
		if not bool(chk.get("ok", false)):
			return {"ok": false, "reason": str(chk.get("reason", "")), "holdingStallId": str(chk.get("holdingStallId", ""))}

	var battle: Dictionary = {
		"teamA": {"id": str(team_a.get("id", "doi-a")), "name": str(team_a.get("name", "Đội A")), "fighters": []},
		"teamB": {"id": str(team_b.get("id", "doi-b")), "name": str(team_b.get("name", "Đội B")), "fighters": []},
		"stallId": stall_id,
		"gameDay": game_day,
		"defenderTeam": defender_team,
		"gridW": GRID_W,
		"gridH": GRID_H,
		"round": 1,
		"turnIndex": 0,
		"activeFighterId": "",
		"elapsedSeconds": 0,
		"status": STATUS_FIGHTING,
		"winner": "",
		"result": {},
		"hold": {},
		"log": [],
	}

	var pos_a: Array = spawn_positions(fa.size(), true)
	var pos_b: Array = spawn_positions(fb.size(), false)
	for i in range(fa.size()):
		var a: Dictionary = fa[i]
		a["x"] = int((pos_a[i] as Dictionary)["x"])
		a["y"] = int((pos_a[i] as Dictionary)["y"])
		a["maxHp"] = compute_max_hp(a, defender_team == "A")
		a["hp"] = int(a["maxHp"])
		a["alive"] = true
		a["hasAttackedThisBattle"] = false
		a["dodgedThisRound"] = false
		a["movedThisTurn"] = false
		a["actedThisTurn"] = false
		(battle["teamA"] as Dictionary)["fighters"].append(a)
	for i in range(fb.size()):
		var b: Dictionary = fb[i]
		b["x"] = int((pos_b[i] as Dictionary)["x"])
		b["y"] = int((pos_b[i] as Dictionary)["y"])
		b["maxHp"] = compute_max_hp(b, defender_team == "B")
		b["hp"] = int(b["maxHp"])
		b["alive"] = true
		b["hasAttackedThisBattle"] = false
		b["dodgedThisRound"] = false
		b["movedThisTurn"] = false
		b["actedThisTurn"] = false
		(battle["teamB"] as Dictionary)["fighters"].append(b)

	# Thứ tự lượt: xen kẽ A1 → B1 → A2 → B2 …
	var turn_order: Array[String] = []
	for i in range(fa.size()):
		turn_order.append(str(((battle["teamA"] as Dictionary)["fighters"][i] as Dictionary)["id"]))
		turn_order.append(str(((battle["teamB"] as Dictionary)["fighters"][i] as Dictionary)["id"]))
	battle["turnOrder"] = turn_order
	battle["activeFighterId"] = turn_order[0]
	(battle["log"] as Array).append("Trận bắt đầu: %s vs %s (%dv%d)." % [str(battle["teamA"]["name"]), str(battle["teamB"]["name"]), fa.size(), fb.size()])
	return {"ok": true, "battle": battle}


func active_fighter(battle: Dictionary) -> Dictionary:
	if battle.is_empty() or str(battle.get("activeFighterId", "")) == "":
		return {}
	return find_fighter(battle, str(battle["activeFighterId"]))


func team_of(battle: Dictionary, fighter: Dictionary) -> String:
	if battle.is_empty() or fighter.is_empty():
		return ""
	for f in (battle.get("teamA", {}) as Dictionary).get("fighters", []):
		if str((f as Dictionary).get("id", "")) == str(fighter.get("id", "")):
			return "A"
	return "B"


func team_alive_count(battle: Dictionary, team: String) -> int:
	var fighters: Array = ((battle.get("teamA", {}) if team == "A" else battle.get("teamB", {})) as Dictionary).get("fighters", [])
	var count := 0
	for f in fighters:
		if bool((f as Dictionary).get("alive", false)):
			count += 1
	return count


## Tổng % HP còn lại của 1 đội (0..1, làm tròn 2 chữ số) — thước đo
## thắng khi hết giờ. (điểm 3)
func team_hp_percent(battle: Dictionary, team: String) -> float:
	var fighters: Array = ((battle.get("teamA", {}) if team == "A" else battle.get("teamB", {})) as Dictionary).get("fighters", [])
	var hp := 0
	var max_hp := 0
	for f in fighters:
		hp += maxi(0, int((f as Dictionary).get("hp", 0)))
		max_hp += int((f as Dictionary).get("maxHp", 0))
	if max_hp <= 0:
		return 0.0
	return round(float(hp) / float(max_hp) * 100.0) / 100.0


# --- Lượt đi ---

## Di chuyển đấu sĩ đang tới lượt. Trả false nếu: trận đã xong,
## không phải lượt của mình, đã di chuyển rồi, ô đích ngoài lưới /
## quá tầm / có người đứng.
func move_fighter(battle: Dictionary, fighter_id: String, x: int, y: int) -> bool:
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return false
	var f: Dictionary = find_fighter(battle, fighter_id)
	if f.is_empty() or not bool(f.get("alive", false)):
		return false
	if str(battle.get("activeFighterId", "")) != fighter_id:
		return false
	if bool(f.get("movedThisTurn", false)):
		return false
	if not in_bounds(x, y):
		return false
	if manhattan(int(f["x"]), int(f["y"]), x, y) > move_range_of(f):
		return false
	if not fighter_at(battle, x, y).is_empty():
		return false
	f["x"] = x
	f["y"] = y
	f["movedThisTurn"] = true
	return true


## Tính sát thương 1 đòn (chưa trừ vào HP): vũ khí → × vai Tím/Cam →
## × buff Tướng Cướp → làm tròn xuống → × giảm thương Tank.
## Lục né đòn đầu mỗi vòng: sát thương về 0 (xử lý ở attack).
func calc_damage(attacker: Dictionary, defender: Dictionary) -> int:
	var w: Dictionary = WEAPONS.get(str(attacker.get("weapon", "Chao")), WEAPONS["Chao"])
	var dmg: float = float(w["dmg"])
	if str(attacker.get("role", "")) == "Tim":
		dmg = dmg * SNIPER_DMG_MULT
	if str(attacker.get("role", "")) == "Cam" and not bool(attacker.get("hasAttackedThisBattle", false)):
		dmg = dmg * BURST_FIRST_HIT_MULT
	if has_title(attacker, TITLE_BANDIT):
		dmg = dmg * (100.0 + BANDIT_DMG_BONUS_PERCENT) / 100.0
	dmg = floor(dmg)
	if str(defender.get("role", "")) == "Do":
		dmg = floor(dmg * TANK_DMG_TAKEN_MULT)
	return maxi(0, int(dmg))


## Đánh: đấu sĩ đang tới lượt đánh 1 đối thủ trong tầm vũ khí.
## Trả {ok: true, damage, dodged, ko, pushed} hoặc
## {ok: false, reason}. reason: "tran-xong" | "khong-phai-luot" |
## "da-hanh-dong" | "ngoai-tam" | "cung-doi" | "muc-tieu-nga".
func attack(battle: Dictionary, attacker_id: String, target_id: String) -> Dictionary:
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return {"ok": false, "reason": "tran-xong"}
	var atk: Dictionary = find_fighter(battle, attacker_id)
	var def: Dictionary = find_fighter(battle, target_id)
	if atk.is_empty() or not bool(atk.get("alive", false)) or str(battle.get("activeFighterId", "")) != attacker_id:
		return {"ok": false, "reason": "khong-phai-luot"}
	if bool(atk.get("actedThisTurn", false)):
		return {"ok": false, "reason": "da-hanh-dong"}
	if def.is_empty() or not bool(def.get("alive", false)):
		return {"ok": false, "reason": "muc-tieu-nga"}
	if team_of(battle, atk) == team_of(battle, def):
		return {"ok": false, "reason": "cung-doi"}
	var w: Dictionary = WEAPONS.get(str(atk.get("weapon", "Chao")), WEAPONS["Chao"])
	if manhattan(int(atk["x"]), int(atk["y"]), int(def["x"]), int(def["y"])) > int(w["range"]):
		return {"ok": false, "reason": "ngoai-tam"}
	var dmg: int = calc_damage(atk, def)
	var dodged := false
	if str(def.get("role", "")) == "Luc" and not bool(def.get("dodgedThisRound", false)):
		# Lục mẹo: né đòn đầu tiên nhận trong mỗi vòng.
		def["dodgedThisRound"] = true
		dmg = 0
		dodged = true
	def["hp"] = maxi(0, int(def["hp"]) - dmg)
	if int(def["hp"]) <= 0:
		def["alive"] = false # "ngã sạp" — xỉu, KHÔNG chết, hết trận hồi đầy.
		def["hp"] = 0
	# Ghế nhựa: đẩy lùi mục tiêu 1 ô ra xa người đánh (nếu ô trống).
	var pushed := false
	if not dodged and bool(def.get("alive", false)) and int(w["knockback"]) > 0 and dmg > 0:
		var dx: int = int(def["x"]) - int(atk["x"])
		var dy: int = int(def["y"]) - int(atk["y"])
		var nx: int = int(def["x"])
		var ny: int = int(def["y"])
		if absi(dx) >= absi(dy):
			nx = int(def["x"]) + (int(w["knockback"]) if dx >= 0 else -int(w["knockback"]))
		else:
			ny = int(def["y"]) + (int(w["knockback"]) if dy >= 0 else -int(w["knockback"]))
		if in_bounds(nx, ny) and fighter_at(battle, nx, ny).is_empty():
			def["x"] = nx
			def["y"] = ny
			pushed = true
	atk["actedThisTurn"] = true
	atk["hasAttackedThisBattle"] = true
	(battle["log"] as Array).append("%s dùng %s đánh %s%s%s%s" % [
		str(atk["name"]), str(w["name"]), str(def["name"]),
		" — né được!" if dodged else " −%d HP" % dmg,
		" (đẩy lùi 1 ô)" if pushed else "",
		"" if bool(def.get("alive", false)) else " — ngã sạp!",
	])
	_check_end(battle)
	return {"ok": true, "damage": dmg, "dodged": dodged, "ko": not bool(def.get("alive", false)), "pushed": pushed}


## Hỗ trợ (chỉ vai Vàng): hồi SUPPORT_HEAL HP cho 1 đồng đội kề bên
## (Manhattan 1 ô), thay vì đánh. Trả {ok, healed}.
func support(battle: Dictionary, supporter_id: String, ally_id: String) -> Dictionary:
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return {"ok": false, "reason": "tran-xong"}
	var sup: Dictionary = find_fighter(battle, supporter_id)
	var ally: Dictionary = find_fighter(battle, ally_id)
	if sup.is_empty() or not bool(sup.get("alive", false)) or str(battle.get("activeFighterId", "")) != supporter_id:
		return {"ok": false, "reason": "khong-phai-luot"}
	if str(sup.get("role", "")) != "Vang":
		return {"ok": false, "reason": "khong-phai-ho-tro"}
	if bool(sup.get("actedThisTurn", false)):
		return {"ok": false, "reason": "da-hanh-dong"}
	if ally.is_empty() or not bool(ally.get("alive", false)):
		return {"ok": false, "reason": "muc-tieu-nga"}
	if team_of(battle, sup) != team_of(battle, ally):
		return {"ok": false, "reason": "khong-cung-doi"}
	if manhattan(int(sup["x"]), int(sup["y"]), int(ally["x"]), int(ally["y"])) > 1:
		return {"ok": false, "reason": "ngoai-tam"}
	var healed: int = mini(SUPPORT_HEAL, int(ally["maxHp"]) - int(ally["hp"]))
	ally["hp"] = int(ally["hp"]) + healed
	sup["actedThisTurn"] = true
	(battle["log"] as Array).append("%s hỗ trợ %s +%d HP." % [str(sup["name"]), str(ally["name"]), healed])
	_check_end(battle)
	return {"ok": true, "healed": healed}


## Kết thúc lượt của đấu sĩ đang đánh: chuyển sang đấu sĩ còn đứng
## tiếp theo trong thứ tự xen kẽ; hết 1 vòng thì sang vòng mới
## (đặt lại né của Lục + cờ đã di chuyển/hành động).
func end_turn(battle: Dictionary) -> bool:
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return false
	var order: Array = battle.get("turnOrder", [])
	var next: int = int(battle.get("turnIndex", 0)) + 1
	var wrapped := false
	while next < order.size() + order.size():
		var idx: int = next % order.size()
		if idx == 0 and next > 0:
			wrapped = true
		var f: Dictionary = find_fighter(battle, str(order[idx]))
		if not f.is_empty() and bool(f.get("alive", false)):
			battle["turnIndex"] = idx
			battle["activeFighterId"] = str(f["id"])
			f["movedThisTurn"] = false
			f["actedThisTurn"] = false
			if wrapped:
				battle["round"] = int(battle["round"]) + 1
				_reset_round_flags(battle)
			turn_changed.emit(str(f["id"]))
			return true
		next += 1
	return false


## Hết giờ lượt (đồng hồ 10s của scene): tự chuyển lượt.
func expire_turn(battle: Dictionary) -> bool:
	return end_turn(battle)


# --- AI lượt địch (G4 bước 2, 20/11) ---
## Chơi 1 lượt cho đấu sĩ đang tới lượt (đội địch trong demo trận).
## Xác định, không ngẫu nhiên — test được; KHÔNG sửa luật, chỉ gọi
## move_fighter / attack / support / end_turn có sẵn.
## Thứ tự: (1) Vàng hỗ trợ đồng đội kề bên thiếu HP nhất; (2) đánh
## địch trong tầm vũ khí (ưu tiên ít HP nhất, hòa thì id nhỏ);
## (3) chưa hành động thì đi tới ô trong tầm di chuyển gần địch gần
## nhất nhất (chỉ đi khi ô đích gần địch hơn vị trí hiện tại; hòa
## thì x nhỏ, rồi y nhỏ); (4) sau khi đi, đánh nếu có địch vào tầm;
## (5) kết thúc lượt (trừ khi trận đã xong giữa chừng).
## Trả {ok, actions: [chuỗi mô tả], ended} hoặc {ok: false, reason}.
func ai_take_turn(battle: Dictionary, fighter_id: String) -> Dictionary:
	var actions: Array[String] = []
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return {"ok": false, "reason": "tran-xong", "actions": actions, "ended": false}
	var f: Dictionary = find_fighter(battle, fighter_id)
	if f.is_empty() or not bool(f.get("alive", false)):
		return {"ok": false, "reason": "khong-co-dau-si", "actions": actions, "ended": false}
	if str(battle.get("activeFighterId", "")) != fighter_id:
		return {"ok": false, "reason": "khong-phai-luot", "actions": actions, "ended": false}
	# 1. Vang ho tro dong doi ke ben thieu HP nhat.
	if str(f.get("role", "")) == "Vang" and not bool(f.get("actedThisTurn", false)):
		var ally: Dictionary = _ai_best_support_target(battle, f)
		if not ally.is_empty():
			var res: Dictionary = support(battle, fighter_id, str(ally["id"]))
			if bool(res.get("ok", false)):
				actions.append("%s hỗ trợ %s +%d HP." % [str(f["name"]), str(ally["name"]), int(res["healed"])])
	# 2. Danh dich trong tam vu khi (uu tien it HP nhat).
	if not bool(f.get("actedThisTurn", false)):
		_ai_try_attack(battle, f, actions)
	# 3. Chua hanh dong thi di lai gan dich nhat.
	if not bool(f.get("actedThisTurn", false)) and not bool(f.get("movedThisTurn", false)):
		var dest: Vector2i = _ai_best_move_tile(battle, f)
		if dest.x >= 0 and move_fighter(battle, fighter_id, dest.x, dest.y):
			actions.append("%s di chuyển tới (%d,%d)." % [str(f["name"]), dest.x, dest.y])
			# 4. Sau khi di, danh neu co dich vao tam.
			_ai_try_attack(battle, f, actions)
	# 5. Ket thuc luot (tru khi tran da xong giua chung).
	var ended := false
	if str(battle.get("status", "")) == STATUS_FIGHTING:
		ended = end_turn(battle)
	return {"ok": true, "actions": actions, "ended": ended}


## Địch trong tầm vũ khí, ít HP nhất (hòa thì id nhỏ).
func _ai_best_attack_target(battle: Dictionary, f: Dictionary) -> Dictionary:
	var w: Dictionary = WEAPONS.get(str(f.get("weapon", "Chao")), WEAPONS["Chao"])
	var rng: int = int(w["range"])
	var my_team: String = team_of(battle, f)
	var best: Dictionary = {}
	for e in all_fighters(battle):
		if not bool(e.get("alive", false)):
			continue
		if team_of(battle, e) == my_team:
			continue
		if manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])) > rng:
			continue
		if best.is_empty() or int(e["hp"]) < int(best["hp"]) or (int(e["hp"]) == int(best["hp"]) and str(e["id"]) < str(best["id"])):
			best = e
	return best


## Đồng đội kề bên (Manhattan 1) thiếu HP nhiều nhất (hòa thì ít HP
## hơn, rồi id nhỏ). Chỉ Vàng mới hỗ trợ — hàm gọi đã kiểm vai.
func _ai_best_support_target(battle: Dictionary, f: Dictionary) -> Dictionary:
	var my_team: String = team_of(battle, f)
	var best: Dictionary = {}
	var best_missing := 0
	for e in all_fighters(battle):
		if str(e.get("id", "")) == str(f.get("id", "")):
			continue
		if not bool(e.get("alive", false)):
			continue
		if team_of(battle, e) != my_team:
			continue
		if manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])) > 1:
			continue
		var missing: int = int(e["maxHp"]) - int(e["hp"])
		if missing <= 0:
			continue
		if best.is_empty() or missing > best_missing or (missing == best_missing and (int(e["hp"]) < int(best["hp"]) or (int(e["hp"]) == int(best["hp"]) and str(e["id"]) < str(best["id"])))):
			best = e
			best_missing = missing
	return best


## Ô trống trong tầm di chuyển gần địch gần nhất nhất. Chỉ trả ô
## gần địch hơn vị trí hiện tại; không có thì (-1,-1) = đứng yên.
## Hòa thì x nhỏ, rồi y nhỏ (quét x ngoài, y trong, chỉ nhận khi
## gần hơn hẳn).
func _ai_best_move_tile(battle: Dictionary, f: Dictionary) -> Vector2i:
	var my_team: String = team_of(battle, f)
	var enemies: Array = []
	for e in all_fighters(battle):
		if bool(e.get("alive", false)) and team_of(battle, e) != my_team:
			enemies.append(e)
	if enemies.is_empty():
		return Vector2i(-1, -1)
	var cur_dist := 999
	for e in enemies:
		cur_dist = mini(cur_dist, manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])))
	var rng: int = move_range_of(f)
	var best := Vector2i(-1, -1)
	var best_dist := cur_dist
	for x in range(GRID_W):
		for y in range(GRID_H):
			if x == int(f["x"]) and y == int(f["y"]):
				continue
			if manhattan(int(f["x"]), int(f["y"]), x, y) > rng:
				continue
			if not fighter_at(battle, x, y).is_empty():
				continue
			var d := 999
			for e in enemies:
				d = mini(d, manhattan(x, y, int(e["x"]), int(e["y"])))
			if d < best_dist:
				best = Vector2i(x, y)
				best_dist = d
	return best


## Thử đánh 1 đòn theo luật chọn mục tiêu của AI; ghi mô tả vào
## actions. Trả true nếu đã đánh (kể cả địch né).
func _ai_try_attack(battle: Dictionary, f: Dictionary, actions: Array[String]) -> bool:
	var target: Dictionary = _ai_best_attack_target(battle, f)
	if target.is_empty():
		return false
	var res: Dictionary = attack(battle, str(f["id"]), str(target["id"]))
	if not bool(res.get("ok", false)):
		return false
	if bool(res.get("dodged", false)):
		actions.append("%s né đòn của %s!" % [str(target["name"]), str(f["name"])])
	elif bool(res.get("ko", false)):
		actions.append("%s đánh ngã %s (−%d HP)!" % [str(f["name"]), str(target["name"]), int(res["damage"])])
	else:
		actions.append("%s đánh %s −%d HP." % [str(f["name"]), str(target["name"]), int(res["damage"])])
	return true


func _reset_round_flags(battle: Dictionary) -> void:
	for f in all_fighters(battle):
		(f as Dictionary)["dodgedThisRound"] = false


## Đồng hồ trận chạy thêm N giây (scene gọi mỗi giây / mỗi khung).
## Hết 180 giây thì kết thúc trận theo % HP.
func tick(battle: Dictionary, seconds: float) -> bool:
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return false
	var s: float = seconds if seconds > 0.0 else 0.0
	battle["elapsedSeconds"] = int(battle.get("elapsedSeconds", 0)) + int(s)
	_check_end(battle)
	return true


# --- Kết thúc trận ---

## Kiểm tra điều kiện kết thúc sau mỗi hành động / mỗi tick.
func _check_end(battle: Dictionary) -> void:
	if battle.is_empty() or str(battle.get("status", "")) != STATUS_FIGHTING:
		return
	var a_alive: int = team_alive_count(battle, "A")
	var b_alive: int = team_alive_count(battle, "B")
	if a_alive == 0 and b_alive == 0:
		_finish_battle(battle, RESULT_DRAW)
		return
	if a_alive == 0:
		_finish_battle(battle, RESULT_WIN_B)
		return
	if b_alive == 0:
		_finish_battle(battle, RESULT_WIN_A)
		return
	if int(battle.get("elapsedSeconds", 0)) >= BATTLE_SECONDS or int(battle.get("round", 1)) > MAX_ROUNDS:
		var pa: float = team_hp_percent(battle, "A")
		var pb: float = team_hp_percent(battle, "B")
		if pa > pb:
			_finish_battle(battle, RESULT_WIN_A)
		elif pb > pa:
			_finish_battle(battle, RESULT_WIN_B)
		else:
			_finish_battle(battle, RESULT_DRAW)


## Chốt trận: ghi winner, Danh vọng, giữ sạp (nếu tranh sạp và có
## đội thắng), ghi lịch sử vào state. Hồi đầy HP mọi đấu sĩ (không
## chết, không mất đồ — hết trận là khỏe lại).
func _finish_battle(battle: Dictionary, winner: String) -> void:
	battle["status"] = STATUS_FINISHED
	battle["winner"] = winner
	var fame_a: int = FAME_WIN if winner == "A" else (FAME_DRAW if winner == "hoa" else FAME_LOSS)
	var fame_b: int = FAME_WIN if winner == "B" else (FAME_DRAW if winner == "hoa" else FAME_LOSS)
	battle["result"] = {
		"winner": winner,
		"winnerTeamId": (str(battle["teamA"]["id"]) if winner == "A" else (str(battle["teamB"]["id"]) if winner == "B" else "")),
		"winnerTeamName": (str(battle["teamA"]["name"]) if winner == "A" else (str(battle["teamB"]["name"]) if winner == "B" else "")),
		"rounds": int(battle["round"]),
		"elapsedSeconds": int(battle["elapsedSeconds"]),
		"hpPercentA": team_hp_percent(battle, "A"),
		"hpPercentB": team_hp_percent(battle, "B"),
		"rewards": {
			"teamA": {"famePerFighter": fame_a},
			"teamB": {"famePerFighter": fame_b},
		},
	}
	# Đội thắng trận tranh sạp thì giữ sạp 7 ngày game từ hôm nay.
	if str(battle.get("stallId", "")) != "" and winner != "hoa":
		var win_team: Dictionary = battle["teamA"] if winner == "A" else battle["teamB"]
		var hold: Dictionary = {
			"stallId": str(battle["stallId"]),
			"teamId": str(win_team["id"]),
			"teamName": str(win_team["name"]),
			"startGameDay": int(battle["gameDay"]),
			"untilGameDay": int(battle["gameDay"]) + HOLD_DAYS,
		}
		battle["hold"] = hold
		apply_hold_win(_state, hold)
	record_battle(_state, battle)
	for f in all_fighters(battle):
		(f as Dictionary)["hp"] = int((f as Dictionary)["maxHp"]) # hết trận hồi đầy — không chết.
		(f as Dictionary)["alive"] = true
	(battle["log"] as Array).append("Trận kết thúc: %s%s" % [
		"Hòa!" if winner == "hoa" else ("%s thắng!" % (str(battle["teamA"]["name"]) if winner == "A" else str(battle["teamB"]["name"]))),
		(" Giữ sạp %s đến ngày game %d." % [str(battle["stallId"]), int((battle["hold"] as Dictionary)["untilGameDay"])]) if not (battle.get("hold", {}) as Dictionary).is_empty() else "",
	])
	battle_finished.emit(winner)


# --- Giữ sạp (state trong _state, đi theo save) ---

## Sạp này còn đội giữ ở ngày game đó không (giữ từ startGameDay
## đến hết untilGameDay - 1; đến untilGameDay là hết hạn).
static func is_holding(st: Dictionary, stall_id: String, game_day: int) -> bool:
	if st.is_empty() or not (st.get("holds", {}) as Dictionary).has(stall_id):
		return false
	var hold: Dictionary = (st["holds"] as Dictionary)[stall_id]
	return game_day >= int(hold["startGameDay"]) and game_day < int(hold["untilGameDay"])


## Đội này đang giữ sạp nào ở ngày game đó (trả stallId hoặc "").
static func team_holds_stall(st: Dictionary, team_id: String, game_day: int) -> String:
	if st.is_empty():
		return ""
	for stall_id in (st.get("holds", {}) as Dictionary).keys():
		var hold: Dictionary = (st["holds"] as Dictionary)[stall_id]
		if str(hold["teamId"]) == team_id and game_day >= int(hold["startGameDay"]) and game_day < int(hold["untilGameDay"]):
			return str(stall_id)
	return ""


## Đội này có được thách đấu sạp kia không? Chặn khi: đội đang giữ
## sạp KHÁC (1 đội giữ tối đa 1 sạp — phải đợi hết hạn hoặc thua
## trận thủ sạp), hoặc đội đã giữ chính sạp này rồi (muốn giữ tiếp
## thì thủ sạp khi bị thách đấu). Thách đấu sạp đang có đội khác giữ
## là ĐƯỢC — đó là trận tranh sạp.
## Trả {ok: true} hoặc {ok: false, reason, holdingStallId}.
static func can_challenge(st: Dictionary, team_id: String, stall_id: String, game_day: int) -> Dictionary:
	var held: String = team_holds_stall(st, team_id, game_day)
	if held != "" and held != stall_id:
		return {"ok": false, "reason": BLOCK_HOLDING_OTHER_STALL, "holdingStallId": held}
	if held != "" and held == stall_id:
		return {"ok": false, "reason": BLOCK_ALREADY_HOLDING_THIS, "holdingStallId": held}
	return {"ok": true}


## Ghi đội thắng giữ sạp (gọi ở _finish_battle; event cũng gọi được).
static func apply_hold_win(st: Dictionary, hold: Dictionary) -> bool:
	if st.is_empty() or hold.is_empty() or str(hold.get("stallId", "")) == "":
		return false
	if not st.has("holds"):
		st["holds"] = {}
	(st["holds"] as Dictionary)[str(hold["stallId"])] = {
		"stallId": str(hold["stallId"]),
		"teamId": str(hold["teamId"]),
		"teamName": str(hold.get("teamName", "")),
		"startGameDay": int(hold["startGameDay"]),
		"untilGameDay": int(hold["untilGameDay"]),
	}
	return true


## Vong 95: neo lai cua so giu sap theo ngay server — tra hold moi voi
## startGameDay = anchor_day, untilGameDay = anchor_day + HOLD_DAYS,
## giu nguyen stallId/teamId/teamName. Tra {} khi hold rong / thieu
## stallId / anchor_day < 1. Khong doi luat giu 7 ngay, chi doi moc:
## client moi luon bat dau ngay local 1 trong khi server co the da
## ngay 17+ (state ton tai) nen hold [1,8) khong bao gio qua duoc cua
## server (het-han-giu-sap / ngay-server-khong-khop — xem §115.3).
static func reanchor_hold_window(hold: Dictionary, anchor_day: int) -> Dictionary:
	if hold.is_empty() or anchor_day < 1:
		return {}
	var stall_id := str(hold.get("stallId", ""))
	if stall_id.is_empty():
		return {}
	return {
		"stallId": stall_id,
		"teamId": str(hold.get("teamId", "")),
		"teamName": str(hold.get("teamName", "")),
		"startGameDay": anchor_day,
		"untilGameDay": anchor_day + HOLD_DAYS,
	}


## Dọn sạp đã hết hạn ở ngày game đó. Trả số sạp đã dọn.
static func expire_holds(st: Dictionary, game_day: int) -> int:
	if st.is_empty() or not st.has("holds"):
		return 0
	var removed := 0
	var keys: Array = (st["holds"] as Dictionary).keys()
	for stall_id in keys:
		if game_day >= int(((st["holds"] as Dictionary)[stall_id] as Dictionary)["untilGameDay"]):
			(st["holds"] as Dictionary).erase(stall_id)
			removed += 1
	return removed


## Quyền lợi giữ sạp của 1 đội ở ngày game đó ({} nếu không giữ sạp
## nào): giá sỉ −10%, thuế sạp −20%, Danh vọng +10/ngày game.
static func hold_benefits(st: Dictionary, team_id: String, game_day: int) -> Dictionary:
	var stall_id: String = team_holds_stall(st, team_id, game_day)
	if stall_id == "":
		return {}
	return {
		"stallId": stall_id,
		"wholesaleDiscountPercent": WHOLESALE_DISCOUNT_PERCENT,
		"stallTaxCutPercent": STALL_TAX_CUT_PERCENT,
		"famePerDay": HOLD_FAME_PER_DAY,
	}


## Ghi 1 trận đã xong vào lịch sử (tối đa giữ 50 trận gần nhất).
static func record_battle(st: Dictionary, battle: Dictionary) -> bool:
	if st.is_empty() or battle.is_empty():
		return false
	if not st.has("history"):
		st["history"] = []
	(st["history"] as Array).append({
		"gameDay": int(battle.get("gameDay", 1)),
		"stallId": str(battle.get("stallId", "")),
		"winnerTeamId": str((battle.get("result", {}) as Dictionary).get("winnerTeamId", "")),
		"result": str(battle.get("winner", "")),
		"rounds": int(battle.get("round", 1)),
		"elapsedSeconds": int(battle.get("elapsedSeconds", 0)),
	})
	while (st["history"] as Array).size() > MAX_HISTORY:
		(st["history"] as Array).pop_front()
	return true


static func battle_history(st: Dictionary) -> Array:
	if st.is_empty() or not st.has("history"):
		return []
	return ((st["history"] as Array).duplicate(true))


# --- Đội NPC lấp chỗ cho slice (GDD Mục 11: "NPC đóng vai người chơi") ---

## Tạo 1 đội NPC tạm để test / chơi slice Phase 1. Tên + id là TẠM —
## PxbStory sau này thay bằng NPC thật của chợ. Chỉ dùng khi chưa có
## đội người chơi / công ty thật.
static func seed_npc_team(team_id: String, team_name: String, size: int) -> Dictionary:
	var n: int = 5 if size == 5 else 3
	var roles: Array[String] = ["Do", "Xanh", "Vang", "Tim", "Cam"]
	var weapons: Array[String] = ["Chao", "CaKho", "GheNhua", "Loa", "Chao"]
	var fighters: Array = []
	for i in range(n):
		fighters.append(create_fighter(
			"%s-npc-%d" % [team_id, i + 1],
			"Tiểu thương %d" % (i + 1),
			roles[i % roles.size()],
			weapons[i % weapons.size()],
			{"the": 50, "tri": 50, "tam": 50},
			[]))
	return {"id": team_id, "name": team_name, "fighters": fighters}


# --- Trận hiện tại (biến instance — như battle MV, không vào save) ---

func set_current_battle(battle: Dictionary) -> Dictionary:
	_current_battle = battle
	return _current_battle


func get_current_battle() -> Dictionary:
	return _current_battle


# --- Wrapper trên state hiện tại (event gọi trực tiếp) ---

func can_challenge_now(team_id: String, stall_id: String, game_day: int) -> Dictionary:
	return can_challenge(_state, team_id, stall_id, game_day)


func is_holding_now(stall_id: String, game_day: int) -> bool:
	return is_holding(_state, stall_id, game_day)


func team_holds_stall_now(team_id: String, game_day: int) -> String:
	return team_holds_stall(_state, team_id, game_day)


func hold_benefits_now(team_id: String, game_day: int) -> Dictionary:
	return hold_benefits(_state, team_id, game_day)


func expire_holds_now(game_day: int) -> int:
	return expire_holds(_state, game_day)


func battle_history_now() -> Array:
	return battle_history(_state)


func move_fighter_now(fighter_id: String, x: int, y: int) -> bool:
	if _current_battle.is_empty():
		return false
	return move_fighter(_current_battle, fighter_id, x, y)


func attack_now(attacker_id: String, target_id: String) -> Dictionary:
	if _current_battle.is_empty():
		return {"ok": false, "reason": "khong-co-tran"}
	return attack(_current_battle, attacker_id, target_id)


func support_now(supporter_id: String, ally_id: String) -> Dictionary:
	if _current_battle.is_empty():
		return {"ok": false, "reason": "khong-co-tran"}
	return support(_current_battle, supporter_id, ally_id)


func end_turn_now() -> bool:
	if _current_battle.is_empty():
		return false
	return end_turn(_current_battle)


func tick_now(seconds: float) -> bool:
	if _current_battle.is_empty():
		return false
	return tick(_current_battle, seconds)
