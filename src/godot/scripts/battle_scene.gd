class_name BattleScene
extends Node2D
## Scene trận Bụi Đời Chợ Cá (Godot G4 §4 — code lớn tiếp theo sau G3).
## Vẽ lưới 12×9 isometric + đấu sĩ + HUD trận, nối thẳng logic lõi
## PxbMarketBattle (luật ĐÃ CHỐT 20/11 06:06 — không sửa luật ở đây).
##
## Cách chơi (chuột/chạm): chạm đấu sĩ của mình để xem; chạm ô xanh
## lá để di chuyển (tối đa tầm di chuyển, 1 lần/lượt); chạm địch
## trong tầm vũ khí để đánh; đấu sĩ Vàng chạm đồng đội kề bên để hỗ
## trợ (+12 HP); nút "Kết thúc lượt" hoặc hết 10s thì chuyển lượt.
## Đồng hồ trận 180s — hết giờ thắng bằng tổng % HP (đúng luật).
## Phím B (Main xử lý) đóng scene, trở lại map.
##
## Scene chạy trên CanvasLayer riêng (layer 2, trên HUD) nên vẽ theo
## tọa độ màn hình 720×1280, không bị camera zoom 1.6 kéo theo.
## Mọi hàm hành động đều trả kết quả chữ để test headless gọi trực
## tiếp được (xem tests/g4_battle_scene_test.gd).

signal close_requested

const VIEW_W := 720
const VIEW_H := 1280
const TILE_W := 64
const TILE_H := 32
# Lưới 12×9: chiều rộng thô (12+9-1)*32 = 704, cao (12+9-1)*16+32.
# Tâm lưới đặt ở (360, 560): trên là HUD trận, dưới là panel hành động.
const GRID_CENTER := Vector2(360, 560)

# Màu vai (đúng docs/stats.md): Đỏ Thể, Xanh Trí, Vàng Tâm,
# Tím Kỷ, Cam Dũng, Lục Sáng.
const ROLE_COLORS := {
	"Do": Color(0.84, 0.27, 0.27),
	"Xanh": Color(0.24, 0.49, 0.84),
	"Vang": Color(0.91, 0.73, 0.24),
	"Tim": Color(0.54, 0.37, 0.84),
	"Cam": Color(0.91, 0.48, 0.17),
	"Luc": Color(0.30, 0.69, 0.43),
}
const TEAM_A_COLOR := Color(0.35, 0.62, 0.95)
const TEAM_B_COLOR := Color(0.95, 0.62, 0.25)

var mb: PxbMarketBattle = null
var battle: Dictionary = {}
var font: Font = null
var font_bold: Font = null

var _offset := Vector2.ZERO
var _selected_id := ""
var _turn_elapsed := 0.0
var _match_acc := 0.0
var _last_action := ""
var _end_rect := Rect2(16, 1120, 330, 70)
var _close_rect := Rect2(374, 1120, 330, 70)


## Gắn logic trận + trận đã tạo (create_battle trả về). Tính offset
## lưới từ tâm GRID_CENTER (cùng công thức IsoMap.build).
func setup(p_mb: PxbMarketBattle, p_battle: Dictionary, p_font: Font, p_font_bold: Font) -> void:
	mb = p_mb
	battle = p_battle
	font = p_font
	font_bold = p_font_bold
	var corners: Array[Vector2] = [
		tile_center_raw(Vector2i(0, 0)), tile_center_raw(Vector2i(11, 0)),
		tile_center_raw(Vector2i(0, 8)), tile_center_raw(Vector2i(11, 8)),
	]
	var min_p := corners[0]
	var max_p := corners[0]
	for p in corners:
		min_p = Vector2(minf(min_p.x, p.x), minf(min_p.y, p.y))
		max_p = Vector2(maxf(max_p.x, p.x), maxf(max_p.y, p.y))
	_offset = GRID_CENTER - (min_p + max_p) * 0.5
	_selected_id = str(battle.get("activeFighterId", ""))
	_turn_elapsed = 0.0
	_match_acc = 0.0
	_last_action = "Trận bắt đầu — chạm ô xanh lá để di chuyển."
	if mb != null:
		mb.turn_changed.connect(_on_turn_changed)
		mb.battle_finished.connect(_on_battle_finished)


func _on_turn_changed(_fighter_id: String) -> void:
	_turn_elapsed = 0.0
	_selected_id = str(battle.get("activeFighterId", ""))
	queue_redraw()


func _on_battle_finished(_winner: String) -> void:
	_last_action = result_text()
	queue_redraw()


## --- Toán lưới (cùng công thức IsoMap) ---

static func tile_center_raw(tile: Vector2i) -> Vector2:
	return Vector2((tile.x - tile.y) * (TILE_W / 2), (tile.x + tile.y) * (TILE_H / 2) + TILE_H / 2)

func tile_center(tile: Vector2i) -> Vector2:
	return _offset + tile_center_raw(tile)

func screen_to_tile(pos: Vector2) -> Vector2i:
	var local := pos - _offset
	var dx := local.x / (TILE_W / 2.0)
	var dy := (local.y - TILE_H / 2.0) / (TILE_H / 2.0)
	return Vector2i(int(round((dx + dy) / 2.0)), int(round((dy - dx) / 2.0)))


## --- Trạng thái trận (đọc từ PxbMarketBattle) ---

func is_fighting() -> bool:
	return not battle.is_empty() and str(battle.get("status", "")) == PxbMarketBattle.STATUS_FIGHTING

func active_fighter() -> Dictionary:
	if battle.is_empty() or mb == null:
		return {}
	return mb.active_fighter(battle)

func turn_seconds_left() -> float:
	return maxf(0.0, float(PxbMarketBattle.TURN_SECONDS) - _turn_elapsed)

func match_seconds_left() -> int:
	if battle.is_empty():
		return 0
	return maxi(0, PxbMarketBattle.BATTLE_SECONDS - int(battle.get("elapsedSeconds", 0)))

func selected_fighter() -> Dictionary:
	if battle.is_empty() or mb == null or _selected_id == "":
		return {}
	return mb.find_fighter(battle, _selected_id)


## Ô di chuyển được của đấu sĩ đang tới lượt (chưa di chuyển lượt này).
func reachable_tiles() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var f := active_fighter()
	if f.is_empty() or not is_fighting():
		return out
	if bool(f.get("movedThisTurn", false)):
		return out
	var rng := PxbMarketBattle.move_range_of(f)
	var fx := int(f["x"])
	var fy := int(f["y"])
	for y in range(PxbMarketBattle.GRID_H):
		for x in range(PxbMarketBattle.GRID_W):
			if PxbMarketBattle.manhattan(fx, fy, x, y) > rng:
				continue
			if not mb.fighter_at(battle, x, y).is_empty():
				continue
			out.append(Vector2i(x, y))
	return out


## Địch còn đứng trong tầm vũ khí của đấu sĩ đang tới lượt.
func attackable_targets() -> Array:
	var out: Array = []
	var f := active_fighter()
	if f.is_empty() or not is_fighting():
		return out
	if bool(f.get("actedThisTurn", false)):
		return out
	var w: Dictionary = PxbMarketBattle.WEAPONS.get(str(f.get("weapon", "Chao")), PxbMarketBattle.WEAPONS["Chao"])
	var rng := int(w["range"])
	var my_team := mb.team_of(battle, f)
	for e in mb.all_fighters(battle):
		if not bool(e.get("alive", false)):
			continue
		if mb.team_of(battle, e) == my_team:
			continue
		if PxbMarketBattle.manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])) <= rng:
			out.append(e)
	return out


## Đồng đội kề bên mà đấu sĩ Vàng đang tới lượt có thể hỗ trợ.
func supportable_allies() -> Array:
	var out: Array = []
	var f := active_fighter()
	if f.is_empty() or not is_fighting():
		return out
	if str(f.get("role", "")) != "Vang" or bool(f.get("actedThisTurn", false)):
		return out
	var my_team := mb.team_of(battle, f)
	for e in mb.all_fighters(battle):
		if str(e.get("id", "")) == str(f.get("id", "")):
			continue
		if not bool(e.get("alive", false)):
			continue
		if mb.team_of(battle, e) != my_team:
			continue
		if PxbMarketBattle.manhattan(int(f["x"]), int(f["y"]), int(e["x"]), int(e["y"])) <= 1:
			out.append(e)
	return out


## --- Hành động (gọi từ click/chạm hoặc test) ---
## Trả: "moved" | "attacked" | "supported" | "selected" | "ended" |
## "close" | "none".

func click_tile(tile: Vector2i) -> String:
	if not is_fighting() or mb == null:
		return "none"
	var f := active_fighter()
	if f.is_empty():
		return "none"
	var target: Dictionary = mb.fighter_at(battle, tile.x, tile.y)
	if not target.is_empty():
		var my_team := mb.team_of(battle, f)
		if mb.team_of(battle, target) == my_team:
			if str(target.get("id", "")) == str(f.get("id", "")):
				_selected_id = str(f["id"])
				return "selected"
			# Đồng đội: Vàng kề bên thì hỗ trợ, còn lại chỉ xem.
			for a in supportable_allies():
				if str(a.get("id", "")) == str(target.get("id", "")):
					var res: Dictionary = mb.support(battle, str(f["id"]), str(target["id"]))
					if bool(res.get("ok", false)):
						_last_action = "%s hỗ trợ %s +%d HP." % [str(f["name"]), str(target["name"]), int(res["healed"])]
						_selected_id = str(target["id"])
						queue_redraw()
						return "supported"
			_selected_id = str(target["id"])
			queue_redraw()
			return "selected"
		# Địch: trong tầm thì đánh, ngoài tầm chỉ xem.
		for e in attackable_targets():
			if str(e.get("id", "")) == str(target.get("id", "")):
				var res: Dictionary = mb.attack(battle, str(f["id"]), str(target["id"]))
				if bool(res.get("ok", false)):
					if bool(res.get("dodged", false)):
						_last_action = "%s né đòn của %s!" % [str(target["name"]), str(f["name"])]
					elif bool(res.get("ko", false)):
						_last_action = "%s đánh ngã %s (−%d HP)!" % [str(f["name"]), str(target["name"]), int(res["damage"])]
					else:
						_last_action = "%s đánh %s −%d HP." % [str(f["name"]), str(target["name"]), int(res["damage"])]
					_selected_id = str(target["id"])
					queue_redraw()
					return "attacked"
		_selected_id = str(target["id"])
		queue_redraw()
		return "selected"
	# Ô trống: trong tầm di chuyển thì đi.
	for t in reachable_tiles():
		if t == tile:
			if mb.move_fighter(battle, str(f["id"]), tile.x, tile.y):
				_last_action = "%s di chuyển tới (%d,%d)." % [str(f["name"]), tile.x, tile.y]
				queue_redraw()
				return "moved"
	return "none"


func end_turn_now() -> bool:
	if not is_fighting() or mb == null:
		return false
	var ok := mb.end_turn(battle)
	if ok:
		_last_action = "Hết lượt — tới %s." % str(active_fighter().get("name", ""))
		queue_redraw()
	return ok


## Chạm màn hình: nút trước, lưới sau.
func click_screen(pos: Vector2) -> String:
	if _end_rect.has_point(pos) and is_fighting():
		return "ended" if end_turn_now() else "none"
	if _close_rect.has_point(pos):
		return "close"
	if pos.y < 980.0:
		return click_tile(screen_to_tile(pos))
	return "none"


func _unhandled_input(event: InputEvent) -> void:
	var click_pos := Vector2.INF
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_pos = event.position
	elif event is InputEventScreenTouch and event.pressed:
		click_pos = event.position
	if click_pos == Vector2.INF:
		return
	if click_screen(click_pos) == "close":
		close_requested.emit()


## --- Đồng hồ (gọi mỗi khung; test gọi simulate_seconds) ---

func _process(delta: float) -> void:
	_advance_timers(delta)
	queue_redraw()


func _advance_timers(seconds: float) -> void:
	if not is_fighting() or mb == null:
		return
	_turn_elapsed += seconds
	_match_acc += seconds
	while _match_acc >= 1.0:
		_match_acc -= 1.0
		mb.tick(battle, 1.0)
		if not is_fighting():
			return
	if _turn_elapsed >= float(PxbMarketBattle.TURN_SECONDS):
		_turn_elapsed = 0.0
		mb.expire_turn(battle)


## Test headless: chạy đồng hồ N giây mà không cần _process.
func simulate_seconds(seconds: float) -> void:
	var left := seconds
	while left > 0.0:
		var step := minf(left, 0.5)
		_advance_timers(step)
		left -= step
		if not is_fighting():
			return


## --- Kết quả ---

func result_text() -> String:
	if battle.is_empty():
		return ""
	if is_fighting():
		return ""
	var r: Dictionary = battle.get("result", {})
	var winner := str(r.get("winner", ""))
	var line := ""
	if winner == "hoa":
		line = "Hòa! Không đội nào giữ sạp."
	else:
		line = "%s thắng trận!" % str(r.get("winnerTeamName", ""))
	var rewards: Dictionary = r.get("rewards", {})
	var fa := int((rewards.get("teamA", {}) as Dictionary).get("famePerFighter", 0))
	var fb := int((rewards.get("teamB", {}) as Dictionary).get("famePerFighter", 0))
	line += " Danh vọng: %s +%d, %s +%d." % [str(battle["teamA"]["name"]), fa, str(battle["teamB"]["name"]), fb]
	var hold: Dictionary = battle.get("hold", {})
	if not hold.is_empty():
		line += " Giữ sạp %s đến ngày game %d." % [str(hold["stallId"]), int(hold["untilGameDay"])]
	return line


## --- Vẽ ---

func _role_color(role: String) -> Color:
	return ROLE_COLORS.get(role, Color(0.6, 0.6, 0.6))

func _text(f: Font, pos: Vector2, s: String, size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1) -> void:
	if f == null:
		return
	draw_string_outline(f, pos, s, align, width, size, 6, Color(0, 0, 0, 0.9))
	draw_string(f, pos, s, align, width, size, color)

func _fmt_clock(total_s: int) -> String:
	return "%d:%02d" % [total_s / 60, total_s % 60]

func _draw() -> void:
	if font == null or battle.is_empty():
		return
	# Nền tối phủ map phía sau.
	draw_rect(Rect2(0, 0, VIEW_W, VIEW_H), Color(0.05, 0.06, 0.09, 0.94))
	# Tiêu đề + tỉ số HP 2 đội.
	_text(font_bold, Vector2(24, 52), "BỤI ĐỜI CHỢ CÁ", 36, Color(1, 0.85, 0.3))
	var hp_a := mb.team_hp_percent(battle, "A")
	var hp_b := mb.team_hp_percent(battle, "B")
	_text(font, Vector2(24, 90), "%s %.0f%%  —  %s %.0f%%" % [
		str(battle["teamA"]["name"]), hp_a * 100.0,
		str(battle["teamB"]["name"]), hp_b * 100.0], 24, Color(0.95, 0.95, 0.9))
	# Vòng + đồng hồ lượt/trận (lượt ≤3s thì đỏ).
	var turn_c := Color(1, 0.35, 0.3) if turn_seconds_left() <= 3.0 and is_fighting() else Color(0.95, 0.95, 0.9)
	_text(font, Vector2(24, 126), "Vòng %d/12  •  Lượt còn %ds  •  Trận còn %s" % [
		int(battle.get("round", 1)), int(ceil(turn_seconds_left())), _fmt_clock(match_seconds_left())],
		26, turn_c)
	_draw_grid()
	_draw_fighters()
	_draw_bottom()
	if not is_fighting():
		_draw_result()

func _draw_grid() -> void:
	var reach := reachable_tiles()
	var targets := attackable_targets()
	var target_tiles: Array[Vector2i] = []
	for e in targets:
		target_tiles.append(Vector2i(int(e["x"]), int(e["y"])))
	for y in range(PxbMarketBattle.GRID_H):
		for x in range(PxbMarketBattle.GRID_W):
			var t := Vector2i(x, y)
			var c := tile_center(t)
			var half_w := TILE_W / 2.0
			var half_h := TILE_H / 2.0
			var diamond := PackedVector2Array([
				c + Vector2(0, -half_h), c + Vector2(half_w, 0),
				c + Vector2(0, half_h), c + Vector2(-half_w, 0),
			])
			var tone := Color(0.17, 0.19, 0.24) if (x + y) % 2 == 0 else Color(0.13, 0.15, 0.2)
			if x <= 1:
				tone = tone.lerp(TEAM_A_COLOR, 0.25)
			elif x >= 10:
				tone = tone.lerp(TEAM_B_COLOR, 0.25)
			if reach.has(t):
				tone = Color(0.2, 0.65, 0.3, 0.85)
			draw_colored_polygon(diamond, tone)
			draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
				Color(0.5, 0.55, 0.65, 0.7), 1.0)
			if target_tiles.has(t):
				draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
					Color(1, 0.3, 0.25), 3.0)
			var sel := selected_fighter()
			if not sel.is_empty() and int(sel["x"]) == x and int(sel["y"]) == y:
				draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
					Color(1, 0.85, 0.2), 3.0)

func _draw_fighters() -> void:
	var act := active_fighter()
	# 2 lượt vẽ: vòng tròn trước, thanh HP + tên sau — để tên của
	# đấu sĩ này không bị vòng tròn của đấu sĩ khác đè lên.
	for f in mb.all_fighters(battle):
		var c := tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4)
		var alive := bool(f.get("alive", false))
		var col: Color = _role_color(str(f.get("role", "")))
		if not alive:
			col = Color(0.45, 0.45, 0.48)
		# Vòng vàng = đang tới lượt.
		if not act.is_empty() and str(act.get("id", "")) == str(f.get("id", "")) and is_fighting():
			draw_circle(c, 26, Color(1, 0.85, 0.2, 0.9))
			draw_circle(c, 26, Color(1, 0.85, 0.2, 0.25))
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-10, -34), c + Vector2(10, -34), c + Vector2(0, -22)]),
				Color(1, 0.85, 0.2))
		draw_circle(c, 20, col)
		draw_arc(c, 20, 0, TAU, 32, Color(1, 1, 1, 0.9), 2.0)
		if not alive:
			_text(font, c + Vector2(-60, 8), "ngã", 18, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 120)
	for f in mb.all_fighters(battle):
		var c := tile_center(Vector2i(int(f["x"]), int(f["y"]))) + Vector2(0, -4)
		var alive := bool(f.get("alive", false))
		# Thanh HP + tên. Tên lệch theo chẵn/lẻ của x để 2 đấu sĩ
		# chéo nhau không đè nhãn (lỗi thấy trên screenshot thật).
		var pct := float(int(f.get("hp", 0))) / maxf(1.0, float(int(f.get("maxHp", 1))))
		var bar := Rect2(c.x - 22, c.y - 40, 44, 7)
		draw_rect(bar, Color(0, 0, 0, 0.7))
		var hp_c := Color(0.3, 0.85, 0.35) if pct > 0.5 else (Color(1, 0.75, 0.2) if pct > 0.25 else Color(1, 0.3, 0.25))
		draw_rect(Rect2(bar.position, Vector2(44.0 * pct, 7)), hp_c)
		var name_dy := 44.0 if int(f["x"]) % 2 == 0 else 64.0
		_text(font, c + Vector2(-60, name_dy), str(f["name"]), 18, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 120)

func _draw_bottom() -> void:
	draw_rect(Rect2(16, 1000, 688, 200), Color(0.1, 0.11, 0.15, 0.97))
	draw_rect(Rect2(16, 1000, 688, 200), Color(0.5, 0.55, 0.65, 0.6), false, 2.0)
	var act := active_fighter()
	if not act.is_empty() and is_fighting():
		var w: Dictionary = PxbMarketBattle.WEAPONS.get(str(act.get("weapon", "Chao")), PxbMarketBattle.WEAPONS["Chao"])
		_text(font_bold, Vector2(32, 1036), "Lượt: %s (%s — %s, tầm %d)" % [
			str(act["name"]), str(PxbMarketBattle.ROLES[str(act["role"])]["name"]),
			str(w["name"]), int(w["range"])], 26, Color(1, 0.9, 0.4))
		_text(font, Vector2(32, 1070), "Ô xanh: đi  •  Viền đỏ: đánh  •  Vàng chạm đồng đội kề: +12 HP", 20, Color(0.9, 0.9, 0.85))
	else:
		_text(font_bold, Vector2(32, 1036), "Trận đã kết thúc.", 26, Color(1, 0.9, 0.4))
	_text(font, Vector2(32, 1104), _last_action, 22, Color(0.85, 0.9, 0.85))
	# Nút Kết thúc lượt / Đóng.
	draw_rect(_end_rect, Color(0.2, 0.45, 0.75) if is_fighting() else Color(0.3, 0.3, 0.32))
	draw_rect(_end_rect, Color(1, 1, 1, 0.7), false, 2.0)
	_text(font_bold, _end_rect.position + Vector2(0, 46), "Kết thúc lượt", 26, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 330)
	draw_rect(_close_rect, Color(0.45, 0.45, 0.48))
	draw_rect(_close_rect, Color(1, 1, 1, 0.7), false, 2.0)
	_text(font_bold, _close_rect.position + Vector2(0, 46), "Đóng (B)", 26, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER, 330)

func _draw_result() -> void:
	var panel := Rect2(60, 430, 600, 300)
	draw_rect(panel, Color(0.08, 0.09, 0.13, 0.98))
	draw_rect(panel, Color(1, 0.85, 0.3), false, 3.0)
	_text(font_bold, panel.position + Vector2(0, 60), "KẾT THÚC TRẬN", 34, Color(1, 0.85, 0.3), HORIZONTAL_ALIGNMENT_CENTER, 600)
	_text(font, panel.position + Vector2(20, 120), result_text(), 24, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_LEFT, 560)
	_text(font, panel.position + Vector2(0, 260), "Thua không bị phạt — hết trận hồi đầy HP.", 22, Color(0.85, 0.9, 0.85), HORIZONTAL_ALIGNMENT_CENTER, 600)
