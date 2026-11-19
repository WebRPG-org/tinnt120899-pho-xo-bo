extends Node2D
## Main.gd — Dieu khien game G1 (slice parity Map001-002 voi ban MV)
## + G2 UI wiring phan 1 (20/11 ~02:45): cac he G2 (Jobs / Hotspot /
## Crafting / Stats) da noi vao scene that — lam ca nhan luong, nhat
## hotspot qua PxbHotspot, che tao that qua PxbCrafting, HUD hien vi +
## chi so. PhoneHub / SaveCloud / Economy / Education / Social /
## Titles / Story noi o phan sau.
##
## He thoi gian kieu C (da chot, TimeSystem.cs / PXB_Time.js): 1 ngay game =
## 30 phut that, 3 khung Sang/Chieu/Toi, moi khung 10 phut that, miss khung
## khong phat. Phim F (nut "Doi khung") doi khung ngay de test — chi de test.
## G2: khung + do dai khung lay tu PxbBalance / PxbTime (autoload PXB_Time),
## khong hardcode so trong file nay nua.
## Hotspot: nhan 1 lan/ngay game, chi co do dung khung (PXB_Hotspot.js).
## NPC: doi thoai lua chon [Hoi goi y / Tam biet] — goi y lay tu Actors.js.
## Co Tu day che Xe Day, Anh Hai day che Den Soi (dung unlock note cua
## PxbBalance.RECIPES).
## Tui nguyen lieu: MỘT Dictionary duy nhat — hotspot.materials, bind
## sang crafting (bind_materials) + bien inventory cua Main tro toi
## cung Dictionary do (gán theo tham chiếu), nen nhat -> che dung chung.

const MATERIAL_NAMES := {
	"chai-nhua": "Chai Nhựa", "la-chuoi": "Lá Chuối", "sat-vun": "Sắt Vụn",
	"van-go": "Ván Gỗ", "vai-vun": "Vải Vụn", "khung-sat": "Khung Sắt",
	"banh-xe": "Bánh Xe",
}

# Map ten hien thi cua su kien "craft" trong data/maps.json -> recipe_id
# trong PxbBalance.RECIPES. Ten su kien do map data quyet dinh; recipe_id
# do Balance quyet dinh — anh xa o day de khong sua map data.
const CRAFT_RECIPE_BY_NAME := {
	"Xe Đẩy Hàng": "che-xe-day",
	"Đèn Soi": "che-den-soi",
}

var font: Font
var font_bold: Font
var maps_data: Dictionary = {}
var current_map_id := 1
var iso_map: IsoMap = null
var player: Player = null
var day := 1
var frame_idx := 0
var _frame_timer := 0.0
var _toast_timer := 0.0
# Tui nguyen lieu — sau _ready() tro toi hotspot.materials (cung
# Dictionary, gán theo tham chiếu); truoc _ready() la Dictionary rong.
var inventory := {}
var dialogue_open := false

# He G2 noi vao scene (tao trong _create_systems, truoc load_map).
var stats: PxbStats = null
var jobs: PxbJobs = null
var hotspot: PxbHotspot = null
var crafting: PxbCrafting = null

var _hud_map: Label
var _hud_day: Label
var _hud_bag: Label
var _hud_gold: Label
var _hud_stats: Label
var _toast: Label
var _dlg_panel: PanelContainer
var _dlg_name: Label
var _dlg_text: Label
var _dlg_choices: VBoxContainer

func _ready() -> void:
	font = load("res://DejaVuSans.ttf")
	font_bold = load("res://DejaVuSans-Bold.ttf")
	var raw := FileAccess.get_file_as_string("res://data/maps.json")
	maps_data = JSON.parse_string(raw)
	_build_ui()
	_create_systems()
	load_map(int(maps_data["start"]["map"]),
		Vector2i(int(maps_data["start"]["x"]), int(maps_data["start"]["y"])))


# Tao cac he G2 lam node con cua Main. Stats uu tien dung autoload
# PXB_Stats (giu 1 bo chi so duy nhat cua nguoi choi); chay headless
# bang script -s ma autoload chua kip dang ky thi tao node rieng de
# scene van chay duoc (fallback nay chi dung khi khong co autoload).
func _create_systems() -> void:
	stats = get_node_or_null("/root/PXB_Stats") as PxbStats
	if stats == null:
		stats = PxbStats.new()
		add_child(stats)
	jobs = PxbJobs.new()
	jobs.stats = stats
	jobs.set_day_number(day)
	add_child(jobs)
	hotspot = PxbHotspot.new()
	add_child(hotspot)
	crafting = PxbCrafting.new()
	crafting.bind_materials(hotspot.materials)
	add_child(crafting)
	inventory = hotspot.materials

func _map_by_id(map_id: int) -> Dictionary:
	for m in maps_data["maps"]:
		if int(m["id"]) == map_id:
			return m
	return {}

func load_map(map_id: int, spawn_tile: Vector2i) -> void:
	current_map_id = map_id
	if iso_map != null:
		iso_map.queue_free()
	if player != null:
		player.queue_free()
	iso_map = IsoMap.new()
	add_child(iso_map)
	iso_map.build(_map_by_id(map_id), Marker, font)
	player = Player.new()
	add_child(player)
	player.place(iso_map, spawn_tile)
	player.moved_to.connect(_on_player_moved_to)
	_hud_map.text = "Phố Xô Bồ — " + String(_map_by_id(map_id)["name"])
	_update_hud()

func _on_player_moved_to(tile: Vector2i) -> void:
	var ev := iso_map.event_at(tile)
	if not ev.is_empty() and String(ev.get("kind", "")) == "door":
		_transfer(int(ev["to_map"]))

func _transfer(to_map: int) -> void:
	var dest := _map_by_id(to_map)
	var door_tile := Vector2i(5, 4)
	for e in dest["events"]:
		if String(e.get("kind", "")) == "door":
			door_tile = Vector2i(e["tile"][0], e["tile"][1])
	load_map(to_map, door_tile)
	show_toast("Đã sang " + String(dest["name"]))

# --- Thoi gian ---
func _process(delta: float) -> void:
	_frame_timer += delta
	if _frame_timer >= float(PxbBalance.FRAME_MINUTES) * 60.0:
		_frame_timer = 0.0
		_advance_frame()
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast.visible = false

func _advance_frame() -> void:
	frame_idx += 1
	if frame_idx >= 3:
		frame_idx = 0
		day += 1
		jobs.set_day_number(day)
	_update_hud()
	show_toast("Ngày %d • Khung %s" % [day, _frame_name()])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			_frame_timer = 0.0
			_advance_frame()
		elif event.keycode == KEY_E:
			_try_interact()
		return
	var click_pos := Vector2.INF
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_pos = event.position
	elif event is InputEventScreenTouch and event.pressed:
		click_pos = event.position
	if click_pos == Vector2.INF or dialogue_open or iso_map == null:
		return
	var tile := iso_map.world_to_tile(click_pos)
	if not iso_map.in_bounds(tile):
		return
	var ev := iso_map.event_at(tile)
	if not ev.is_empty() and _tile_dist(tile, player.tile) <= 1:
		_interact(ev)
	elif iso_map.is_walkable(tile):
		player.set_auto_target(tile)

func _tile_dist(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)

func _try_interact() -> void:
	if dialogue_open or iso_map == null:
		return
	var best := {}
	var best_d := 99
	for d in [Vector2i.ZERO, Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var ev := iso_map.event_at(player.tile + d)
		if not ev.is_empty() and d.length() < best_d:
			best = ev
			best_d = d.length()
	if best.is_empty():
		return
	_interact(best)

func _interact(ev: Dictionary) -> void:
	match String(ev.get("kind", "")):
		"npc":
			var choices: Array = [
				["Hỏi gợi ý", func() -> void: show_dialogue(String(ev["name"]), String(ev["hint"]), [["Đóng", close_dialogue]])],
				["Tạm biệt", close_dialogue],
			]
			# Co Tu day che Xe Day, Anh Hai day che Den Soi — dung unlock
			# note cua PxbBalance.RECIPES, khong tu dat luat hoc moi.
			if String(ev.get("id", "")) == "co-tu" and not crafting.has_learned("che-xe-day"):
				choices.insert(1, ["Nhờ Cô Tư dạy chế Xe Đẩy", func() -> void: _learn_recipe("che-xe-day")])
			if String(ev.get("id", "")) == "anh-hai" and not crafting.has_learned("che-den-soi"):
				choices.insert(1, ["Nhờ Anh Hải dạy chế Đèn Soi", func() -> void: _learn_recipe("che-den-soi")])
			show_dialogue(String(ev["name"]), String(ev["greet"]), choices)
		"hotspot":
			_collect_hotspot(ev)
		"craft":
			_show_craft_dialogue(ev)
		"door":
			_transfer(int(ev["to_map"]))


func _frame_name() -> String:
	return PxbTime.frame_name(float(frame_idx) * float(PxbBalance.FRAME_MINUTES))


func _learn_recipe(recipe_id: String) -> void:
	if crafting.learn_recipe(recipe_id):
		var r := PxbCrafting.get_recipe(recipe_id)
		show_toast("Đã học công thức: %s!" % String(r.get("name", recipe_id)))
	else:
		show_toast("Không học được công thức này.")
	close_dialogue()


func _recipe_id_for_craft_name(craft_name: String) -> String:
	return String(CRAFT_RECIPE_BY_NAME.get(craft_name, ""))


func _needs_text(recipe: Dictionary) -> String:
	var parts: Array[String] = []
	for mat in (recipe.get("needs", {}) as Dictionary).keys():
		var have := int(inventory.get(String(mat), 0))
		var need := int((recipe["needs"] as Dictionary)[mat])
		parts.append("%s %d/%d" % [String(MATERIAL_NAMES.get(String(mat), String(mat))), have, need])
	return " • ".join(parts)


func _show_craft_dialogue(ev: Dictionary) -> void:
	var recipe_id := _recipe_id_for_craft_name(String(ev["recipe"]))
	if recipe_id == "":
		show_dialogue(String(ev["name"]),
			"Chế %s ở đây. Cần: %s. (Chưa có công thức này trong Balance.)" % [String(ev["recipe"]), String(ev["needs"])],
			[["Đóng", close_dialogue]])
		return
	var recipe := PxbCrafting.get_recipe(recipe_id)
	var learned := crafting.has_learned(recipe_id)
	var text := "%s\nCần: %s" % [String(recipe.get("name", "")), _needs_text(recipe)]
	if not learned:
		text += "\nChưa học công thức — %s" % String(recipe.get("unlock", ""))
	show_dialogue(String(ev["name"]), text, [
		["Chế tạo", func() -> void: craft_recipe(recipe_id)],
		["Đóng", close_dialogue],
	])


# Che 1 mon theo cong thuc; tra Dictionary ket qua cua
# PxbCrafting.craft_current() de test goi truc tiep duoc.
func craft_recipe(recipe_id: String) -> Dictionary:
	var res := crafting.craft_current(recipe_id)
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("Chế xong %s!" % String(res.get("result_name", recipe_id)))
	else:
		match String(res.get("reason", "")):
			"chua-hoc-cong-thuc":
				show_toast("Chưa học công thức — %s" % String(res.get("unlock_note", "")))
			"thieu-nguyen-lieu":
				var miss: Array[String] = []
				for mat in (res.get("missing", {}) as Dictionary).keys():
					miss.append("%s ×%d" % [String(MATERIAL_NAMES.get(String(mat), String(mat))), int((res["missing"] as Dictionary)[mat])])
				show_toast("Thiếu nguyên liệu: %s" % " • ".join(miss))
			"khong-co-cong-thuc":
				show_toast("Không có công thức này.")
			_:
				show_toast("Không chế được.")
	close_dialogue()
	return res


# Lam 1 ca nghe job_id o khung hien tai; tra Dictionary ket qua cua
# PxbJobs.work_shift() de test goi truc tiep duoc.
func work_job(job_id: String) -> Dictionary:
	var res := jobs.work_shift(job_id, _frame_name(), stats)
	if bool(res.get("ok", false)):
		_update_hud()
		var job := PxbJobs.get_job(job_id)
		show_toast("Làm ca %s: +%sđ (còn %d ca/tuần)" % [
			String(job.get("name", job_id)), _fmt_vnd(int(res.get("pay", 0))),
			int(res.get("shifts_left", 0))])
	else:
		match String(res.get("reason", "")):
			"het-quota":
				show_toast("Hết quota tuần của nghề này (14 ca/tuần).")
			"khong-co-nghe":
				show_toast("Không có nghề này.")
			_:
				show_toast("Không làm được ca này.")
	close_dialogue()
	return res


func _show_jobs_dialogue() -> void:
	var lines: Array[String] = []
	for job in PxbBalance.JOBS:
		var j := job as Dictionary
		var jid := String(j["id"])
		var pay := PxbJobs.pay_per_shift(jid, stats, _frame_name(), jobs.get_demand(jid))
		lines.append("%s — %sđ/ca (khung tốt: %s, còn %d ca/tuần)" % [
			String(j["name"]), _fmt_vnd(pay), String(j["good_frame"]),
			jobs.shifts_left(jid)])
	show_dialogue("Việc làm", "\n".join(lines), [
		["Bán rong", func() -> void: work_job("ban-rong")],
		["Shipper", func() -> void: work_job("shipper")],
		["Nhân viên quán", func() -> void: work_job("nhan-vien-quan")],
		["Đóng", close_dialogue],
	])


func _collect_hotspot(ev: Dictionary) -> void:
	var res := hotspot.explore(String(ev["id"]), day, _frame_name())
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("Nhặt được %s ×%d!" % [
			String(MATERIAL_NAMES.get(String(res.get("material_id", "")), String(res.get("material_id", "")))),
			int(res.get("amount", 0))])
		return
	match String(res.get("reason", "")):
		"already":
			show_toast("%s: đã nhặt hôm nay rồi." % String(ev["name"]))
		"wrong-frame":
			var want := String(ev["best_frame"])
			show_toast("%s: chỉ có đồ vào khung %s — giờ đang %s." % [String(ev["name"]), want, _frame_name()])
		"unknown":
			show_toast("%s: hotspot này chưa có trong bảng slice." % String(ev["name"]))
		_:
			show_toast("%s: không nhặt được." % String(ev["name"]))

# --- UI ---
func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_map = _mk_label(layer, font_bold, 34, Vector2(24, 24), "Phố Xô Bồ")
	_hud_day = _mk_label(layer, font, 28, Vector2(24, 70), "")
	_hud_bag = _mk_label(layer, font, 28, Vector2(24, 108), "")
	_hud_gold = _mk_label(layer, font, 28, Vector2(24, 146), "")
	_hud_stats = _mk_label(layer, font, 28, Vector2(24, 184), "")
	var frame_btn := Button.new()
	frame_btn.text = "Đổi khung (F)"
	frame_btn.add_theme_font_size_override("font_size", 26)
	frame_btn.add_theme_font_override("font", font)
	frame_btn.position = Vector2(720 - 224, 24)
	frame_btn.size = Vector2(200, 56)
	frame_btn.pressed.connect(func() -> void: _frame_timer = 0.0; _advance_frame())
	layer.add_child(frame_btn)
	var jobs_btn := Button.new()
	jobs_btn.text = "Việc làm"
	jobs_btn.add_theme_font_size_override("font_size", 26)
	jobs_btn.add_theme_font_override("font", font)
	jobs_btn.position = Vector2(720 - 224, 88)
	jobs_btn.size = Vector2(200, 56)
	jobs_btn.pressed.connect(_show_jobs_dialogue)
	layer.add_child(jobs_btn)
	_toast = _mk_label(layer, font_bold, 30, Vector2(60, 560), "")
	_toast.size = Vector2(600, 60)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.visible = false
	_dlg_panel = PanelContainer.new()
	_dlg_panel.position = Vector2(40, 1280 - 330)
	_dlg_panel.size = Vector2(640, 300)
	_dlg_panel.visible = false
	layer.add_child(_dlg_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	_dlg_panel.add_child(vb)
	_dlg_name = _mk_label(vb, font_bold, 30, Vector2.ZERO, "")
	_dlg_text = _mk_label(vb, font, 28, Vector2.ZERO, "")
	_dlg_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dlg_text.size = Vector2(600, 120)
	_dlg_choices = VBoxContainer.new()
	_dlg_choices.add_theme_constant_override("separation", 8)
	vb.add_child(_dlg_choices)

func _mk_label(parent: Node, f: Font, size: int, pos: Vector2, text: String) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", f)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(0.15, 0.12, 0.08, 1))
	l.position = pos
	l.text = text
	parent.add_child(l)
	return l

func _fmt_vnd(n: int) -> String:
	# 150000 -> "150.000". Khong dung locale — dinh dang tay cho chac.
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "." + s.right(3) + out
		s = s.left(s.length() - 3)
	out = s + out
	return ("-" + out) if n < 0 else out


func _update_hud() -> void:
	_hud_day.text = "Ngày %d • Khung %s" % [day, _frame_name()]
	var parts: Array[String] = []
	for k in inventory.keys():
		if int(inventory[k]) > 0:
			parts.append("%s ×%d" % [String(MATERIAL_NAMES.get(k, k)), int(inventory[k])])
	_hud_bag.text = "Túi: " + (" • ".join(parts) if not parts.is_empty() else "trống")
	_hud_gold.text = "Ví: %sđ • EXP %d" % [_fmt_vnd(jobs.gold), jobs.exp_total]
	_hud_stats.text = "Thể %d • Trí %d • Tâm %d" % [stats.the, stats.tri, stats.tam]

func show_toast(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_timer = 3.0

func show_dialogue(who: String, text: String, choices: Array) -> void:
	dialogue_open = true
	if player != null:
		player.input_blocked = true
	_dlg_name.text = who
	_dlg_text.text = text
	for c in _dlg_choices.get_children():
		c.queue_free()
	for ch in choices:
		var b := Button.new()
		b.text = String(ch[0])
		b.add_theme_font_size_override("font_size", 28)
		b.add_theme_font_override("font", font)
		b.custom_minimum_size = Vector2(600, 56)
		var act: Callable = ch[1]
		b.pressed.connect(act)
		_dlg_choices.add_child(b)
	_dlg_panel.visible = true

func close_dialogue() -> void:
	dialogue_open = false
	if player != null:
		player.input_blocked = false
	_dlg_panel.visible = false
