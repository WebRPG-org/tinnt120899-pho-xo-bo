extends Node2D
## Main.gd — Dieu khien game G1 (slice parity Map001-002 voi ban MV)
## + G2 UI wiring phan 1 (20/11 ~02:45): Jobs / Hotspot / Crafting /
## Stats da noi vao scene that.
## + G2 UI wiring phan 2 (20/11 ~04:00): PhoneHub (phim P + panel 9
## tab) + SaveCloud (luu/tai slot 1-3) + Economy (ngan hang + cho) +
## Education (dang ky hoc) + Social / Titles / Story (hien thi + len
## chuong) + Tools (xem bac + nang cap trong tab Viec lam) + Online
## (trang thai + kiem tra mang trong tab Cai dat).
## Vi: MỘT vi duy nhat la jobs.gold; economy.money chi la ban dong bo
## tam truoc moi giao dich mua/gui/rut (xem _wallet_to_economy).
## Danh vong: bien fame cua Main (PxbStats chua co fame); tot nghiep
## cong EXP vao jobs.exp_total + Danh vong vao fame, roi xoa pending.
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

# Camera nhin lech len 320 world units + zoom 1.4 (thay -230/1.6):
# nguoi choi nam o 2/3 duoi man hinh, dai troi (anh mo rong tren
# mat tien) hien duoc ~60px duoi HUD gon luc spawn (loi 20/11 12:30:
# troi khong thay duoc luc spawn vi HUD cao 236px + camera -230 chi
# thay toi dinh anh). Zoom 1.4 mo rong tam nhin doc 457px moi ben
# (thay 400px) de troi lo them; nhan vat van du lon o 1.4x.
const CAMERA_LOOK_UP := Vector2(0, -320)
# Meo dien thoai xoay theo ngay — lap khoang trong duoi panel
# (art pass Nadia 20/11: panel 1100 cao hon noi dung ~450px).
const PHONE_TIPS := [
	"Nói chuyện với Bạn thân mỗi khung tăng thân thiết +5.",
	"Hotspot xanh là đồ thường, cam là đồ hiếm — nhặt trước khi đổi khung.",
	"Góc Chế Tạo: gom đủ nguyên liệu rồi bấm Chế tạo.",
	"Đổi khung (F) để sang Sáng/Chiều/Tối — mỗi khung có việc khác nhau.",
	"Cửa ra Chợ Đầu Mối dẫn sang khu chợ — đi bộ tới cửa rồi bấm vào.",
]
# Ten ending hien thi cho nguoi choi — suggest_ending() tra ve ID
# noi bo (TuDo/GiamDoc/...), hien thi phai dich sang tieng Viet
# (loi "Ending gợi ý hiện tại: TuDo" o dien thoai, vong 3 art pass).
const ENDING_NAMES := {
	"GiamDoc": "Giám đốc", "HocGia": "Học giả", "GiaDinh": "Gia đình",
	"TuDo": "Tự do", "SieuGiau": "Siêu giàu", "ChuaMo": "Chưa mở",
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
# He G2 phan 2 (PhoneHub / SaveCloud / Economy / Education / Social /
# Titles / Story / Tools / Online).
var phonehub: PxbPhoneHub = null
var savecloud: PxbSaveCloud = null
var economy: PxbEconomy = null
var education: PxbEducation = null
var social: PxbSocial = null
var titles: PxbTitles = null
var story: PxbStory = null
var tools: PxbTools = null
var online: PxbOnline = null
# Danh vong (PxbStats chua co fame) + trang thai dien thoai.
var fame := 0
var phone_open := false
# Scene tran Bui Doi Cho Ca (G4 §4): mo bang phim B (demo 3v3).
var battle_mb: PxbMarketBattle = null
var battle_scene: BattleScene = null
var _battle_layer: CanvasLayer = null
var battle_open := false
## G4 buoc 5: giu sap + lich su tran (PxbMarketBattle.data) — song
## theo save slot, khoi phuc o _apply_save_data, don het han theo
## ngay game o _advance_frame. Chi ghi khi tran ket thuc that.
var battle_state: Dictionary = {}
var _battle_saved := false

var _hud_map: Label
var _hud_day: Label
var _hud_bag: Label
var _hud_gold: Label
var _hud_stats: Label
var _toast: Label
var _camera: Camera2D
var _daynight: ColorRect
var _overlay_layer: CanvasLayer
var _ui_layer: CanvasLayer
var _title_panel: PanelContainer
var _label_layer: CanvasLayer  # Lop nhan tren the gioi (duoi HUD).
var _phone_notch: Panel  # Notch + thanh home cua khung dien thoai.
var _phone_homebar: Panel
var _js_poll := 0.0  # Poll window.__pxb_start (nut DOM "Bat dau").
var title_open := true
var _dlg_panel: PanelContainer
var _dlg_name: Label
var _dlg_text: Label
var _dlg_choices: VBoxContainer
# UI dien thoai (phan 2).
var _phone_btn: Button
var _phone_dim: ColorRect
var _phone_panel: PanelContainer
var _phone_title: Label
var _phone_content: Label
var _phone_hint: Label
var _phone_tip: Label
var _phone_footer: Label
var _phone_actions: VBoxContainer
var _phone_act_scroll: ScrollContainer
var _phone_content_scroll: ScrollContainer  # Vong 4: cao 224 de hien tron dong Chi Le.
var _phone_today: Label  # Khoi "Hom nay" lap khoang trong dien thoai.
var _phone_tab_buttons := {}

# Ten tieng Viet cho loai quan he / giai doan (khong hien ma noi bo
# nhu "BestFriend" / "QuenBiet" cho nguoi choi — loi 20/11 10:30).
const KIND_NAMES := {
	"Lover": "Người yêu", "Spouse": "Vợ/Chồng", "BestFriend": "Bạn thân",
	"FriendGroup": "Hội bạn", "Parent": "Bố/Mẹ", "Child": "Con",
	"CompanyPartner": "Đối tác công ty",
}
const STAGE_NAMES := {
	"QuenBiet": "Quen biết", "ThanThiet": "Thân thiết", "HenHo": "Hẹn hò",
	"DinhHon": "Đính hôn", "Cuoi": "Đã cưới", "TanRa": "Đã tan rã",
}

func _ready() -> void:
	font = load("res://DejaVuSans.ttf")
	font_bold = load("res://DejaVuSans-Bold.ttf")
	var raw := FileAccess.get_file_as_string("res://data/maps.json")
	maps_data = JSON.parse_string(raw)
	_build_ui()
	_create_systems()
	load_map(int(maps_data["start"]["map"]),
		Vector2i(int(maps_data["start"]["x"]), int(maps_data["start"]["y"])))
	# Man hinh title mo san: khoa input cho toi khi bam "Bat dau".
	if player != null:
		player.input_blocked = true


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
	phonehub = PxbPhoneHub.new()
	add_child(phonehub)
	savecloud = PxbSaveCloud.new()
	add_child(savecloud)
	economy = PxbEconomy.new()
	add_child(economy)
	education = PxbEducation.new()
	education.day_number = day
	add_child(education)
	social = PxbSocial.new()
	social.seed_slice(1)
	add_child(social)
	titles = PxbTitles.new()
	add_child(titles)
	story = PxbStory.new()
	add_child(story)
	tools = PxbTools.new()
	tools.bind_materials(hotspot.materials)
	tools.bind_crafting(crafting)
	tools.bind_hotspot(hotspot)
	add_child(tools)
	online = PxbOnline.new()
	add_child(online)

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
	iso_map.build(_map_by_id(map_id), Marker, font, _label_layer)
	player = Player.new()
	add_child(player)
	player.place(iso_map, spawn_tile)
	player.moved_to.connect(_on_player_moved_to)
	if iso_map.skyfx != null:
		iso_map.skyfx.player = player
	if _camera != null:
		_camera.position = player.position + CAMERA_LOOK_UP
		_camera.reset_smoothing()
	_hud_map.text = "Phố Xô Bồ — " + String(_map_by_id(map_id)["name"])
	_fit_hud_map()
	_update_hud()
	_update_daynight()  # Ap khung hien tai cho map moi (anh dem/tint/mat troi).

func _on_player_moved_to(tile: Vector2i) -> void:
	var ev := iso_map.event_at(tile)
	if not ev.is_empty() and String(ev.get("kind", "")) == "door":
		_transfer(int(ev["to_map"]))

func _transfer(to_map: int) -> void:
	var dest := _map_by_id(to_map)
	if dest.is_empty():
		# G3 port theo tung buoc: cua di khu chua co data (vd Map005 -> Map006)
		# thi bao chu chua crash — nguoi choi dung yen o cua.
		show_toast("Khu này chưa mở trong bản Godot — đang làm (G3).")
		return
	var door_tile := Vector2i(5, 4)
	for e in dest["events"]:
		if String(e.get("kind", "")) == "door":
			door_tile = Vector2i(e["tile"][0], e["tile"][1])
			break  # Cua VE (5,4) la cua dau tien — dung break, neu khong
			# vong lap se lay cua CUOI (5,8) lam diem spawn (loi lo ra khi
			# Map002 co them cua di Map003 o G3 buoc 1).
	load_map(to_map, door_tile)
	show_toast("Đã sang " + String(dest["name"]))

# Ten map dai (vd "Khu Công Nhân", "Phố Đi Bộ – Chợ Đêm") bi cat o mep
# panel 452px khi co 30 (loi 20/11 13:20): co chu nho dan toi khi vua
# long panel (412px = 452 - 2x18 content margin), toi thieu 20.
func _fit_hud_map() -> void:
	var size := 30
	while size > 20:
		var w := font_bold.get_string_size(_hud_map.text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if w <= 412.0:
			break
		size -= 2
	_hud_map.add_theme_font_size_override("font_size", size)

# --- Thoi gian ---
func _process(delta: float) -> void:
	# Camera bam theo nguoi choi (zoom 1.4: map lap day viewport).
	if _camera != null and player != null:
		_camera.position = player.position + CAMERA_LOOK_UP
	# Chong-chong nhan o khong gian man hinh (vong 4): chay truoc
	# _process cua Marker (cha chay truoc con) nen override kip dung
	# ngay trong frame nay.
	_resolve_label_overlaps()
	# Nut DOM "Bat dau" tren web (web_shell.html): nut HTML dat
	# window.__pxb_start = true; poll 4 lan/giay (khong dung signal
	# vi JavaScriptBridge chi co eval, khong co callback tu JS).
	if title_open and OS.has_feature("web"):
		_js_poll += delta
		if _js_poll > 0.25:
			_js_poll = 0.0
			if JavaScriptBridge.eval("window.__pxb_start === true"):
				_on_start_pressed()
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
		# G4 buoc 5: sang ngay moi thi don sap tran da het han giu.
		PxbMarketBattle.expire_holds(battle_state, day)
		jobs.set_day_number(day)
		education.day_number = day
		social.apply_neglect_all(day)
		if day > 1 and (day - 1) % 30 == 0:
			# Sang thang game moi: lai 0,5% tren so tiet kiem hien co.
			var interest := economy.apply_monthly_interest(30)
			if interest > 0:
				show_toast("Lãi tiết kiệm tháng mới: +%sđ" % _fmt_vnd(interest))
	_update_hud()
	_update_daynight()
	show_toast("Ngày %d • Khung %s" % [day, _frame_name()])
	# Tot nghiep / khoa ngan han kiem tra sau toast ngay de toast
	# tot nghiep khong bi toast ngay de mat.
	if frame_idx == 0 and day > 1:
		_check_graduations()


# Kiem tra tot nghiep moi ngay game moi (goi 1 lan/ngay): tot nghiep
# bang chinh cong EXP vao jobs.exp_total + Danh vong vao fame roi xoa
# pending (dung hop dong PxbEducation: event tu ap pending); khoa
# ngan han chi bao + notify (chi so phu chua co API ap qua PxbStats).
func _check_graduations() -> void:
	var g := education.check_graduation()
	if bool(g.get("graduated", false)):
		jobs.exp_total += int(g.get("exp", 0))
		fame += int(g.get("fame", 0))
		education.pending_exp = 0
		education.pending_fame = 0
		phonehub.notify(PxbPhoneHub.TAB_HOC_TAP)
		show_toast("Tốt nghiệp %s! +%d EXP, +%d Danh vọng" % [
			String((g.get("degree", {}) as Dictionary).get("name", "")),
			int(g.get("exp", 0)), int(g.get("fame", 0))])
	var sc := education.check_short_course_graduation()
	if bool(sc.get("graduated", false)):
		phonehub.notify(PxbPhoneHub.TAB_HOC_TAP)
		show_toast("Xong khóa ngắn hạn: +%d %s (chờ áp vào chỉ số phụ)" % [
			int(sc.get("gain", 0)), String(sc.get("sub_stat", ""))])

func _unhandled_input(event: InputEvent) -> void:
	if title_open:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B and not dialogue_open and not phone_open:
			if battle_open:
				_close_battle()
			else:
				_start_battle_demo()
			return
		if battle_open:
			return
		if event.keycode == PxbPhoneHub.PHONE_KEY_CODE:
			if not dialogue_open:
				_toggle_phone()
		elif event.keycode == KEY_F:
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
	if click_pos == Vector2.INF or dialogue_open or phone_open or battle_open or iso_map == null:
		return
	# Doi toa do man hinh -> toa do the gioi (camera zoom/follow).
	var world_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * click_pos
	var tile := iso_map.world_to_tile(world_pos)
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

# --- G2 UI wiring phan 2: vi chung, dien thoai, cho, hoc, save ---

# Vi chung: jobs.gold la nguon su that duy nhat. Truoc moi giao dich
# dung economy (mua / gui / rut) thi dong bo tien vao economy.money;
# xong thi dong bo nguoc ve jobs.gold + cap nhat HUD.
func _wallet_to_economy() -> void:
	economy.money = jobs.gold


func _wallet_from_economy() -> void:
	jobs.gold = economy.money
	_update_hud()


# --- Dien thoai (PxbPhoneHub: 9 tab, mo bang phim P / nut) ---

## --- Tran Bui Doi Cho Ca (G4 §4, demo 3v3) ---
## Mo scene tran tren CanvasLayer rieng (layer 2, tren HUD), khoa
## input map + an HUD trong luc danh; dong thi tra lai nhu cu.
## Doi ban: 3 dau si theo chi so nguoi choi (Do/Xanh/Vang); doi cho:
## seed NPC; tranh sap "sap-cho-dau-moi", doi cho dang giu sap (B thu).
func _start_battle_demo() -> void:
	if battle_open:
		return
	battle_mb = PxbMarketBattle.new()
	add_child(battle_mb)
	# G4 buoc 5: khoi phuc giu sap + lich su tu save truoc (neu co),
	# don sap het han theo ngay game hien tai truoc khi nap vao tran.
	PxbMarketBattle.expire_holds(battle_state, day)
	battle_mb.from_data(battle_state)
	_battle_saved = false
	var team_a := {"id": "doi-ban", "name": "Đội Bạn", "fighters": [
		PxbMarketBattle.create_fighter("ban-1", "Bạn", "Do", "Chao",
			{"the": 80, "tri": 40, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-2", "Bạn Thân", "Xanh", "CaKho",
			{"the": 40, "tri": 80, "tam": 50}, []),
		PxbMarketBattle.create_fighter("ban-3", "Cô Tư", "Vang", "Loa",
			{"the": 40, "tri": 50, "tam": 80}, []),
	]}
	var team_b: Dictionary = PxbMarketBattle.seed_npc_team("doi-cho", "Đội Chợ Đầu Mối", 3)
	var res: Dictionary = battle_mb.create_battle({
		"teamA": team_a, "teamB": team_b,
		"stallId": "sap-cho-dau-moi", "gameDay": day, "defenderTeam": "B",
	})
	if not bool(res.get("ok", false)):
		show_toast("Không mở được trận: " + str(res.get("reason", "")))
		battle_mb.queue_free()
		battle_mb = null
		return
	battle_mb.set_current_battle(res["battle"])
	var layer := CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	_battle_layer = layer
	battle_scene = BattleScene.new()
	layer.add_child(battle_scene)
	battle_scene.setup(battle_mb, res["battle"], font, font_bold)
	# G4 bước 2: đội Chợ (B) do AI cầm — tự di chuyển/đánh/hỗ trợ.
	battle_scene.ai_enabled = true
	battle_scene.close_requested.connect(_close_battle)
	# G4 buoc 5: tran xong -> ghi giu sap + Danh vong vao save.
	battle_scene.battle_finished.connect(_on_battle_finished)
	battle_open = true
	if player != null:
		player.input_blocked = true
	_ui_layer.visible = false


## G4 buoc 5: tran ket thuc -> ghi giu sap + lich su vao battle_state
## (di theo save slot), cong Danh vong doi ban (thang +50 / hoa +20 /
## thua +10 — dung luat PxbMarketBattle) vao fame. Chi ap 1 lan/tran.
func _on_battle_finished(_winner: String) -> void:
	if battle_mb == null or _battle_saved:
		return
	_battle_saved = true
	battle_state = battle_mb.data()
	var fame_gain := 0
	var hold: Dictionary = {}
	if battle_scene != null:
		var result: Dictionary = battle_scene.battle.get("result", {})
		var rewards: Dictionary = result.get("rewards", {})
		var team_a: Dictionary = rewards.get("teamA", {})
		fame_gain = int(team_a.get("famePerFighter", 0))
		hold = battle_scene.battle.get("hold", {})
	if fame_gain > 0:
		fame += fame_gain
		_update_hud()
	var msg := "Trận kết thúc — Danh vọng +%d." % fame_gain
	if not hold.is_empty() and str(hold.get("teamId", "")) == "doi-ban":
		msg += " Giữ sạp %s đến ngày %d." % [str(hold.get("stallId", "")), int(hold.get("untilGameDay", 0))]
	show_toast(msg)


func _close_battle() -> void:
	if battle_scene != null:
		battle_scene.queue_free()
		battle_scene = null
	if _battle_layer != null:
		_battle_layer.queue_free()
		_battle_layer = null
	if battle_mb != null:
		battle_mb.queue_free()
		battle_mb = null
	battle_open = false
	if player != null:
		player.input_blocked = false
	_ui_layer.visible = true


func _toggle_phone() -> void:
	if phonehub.is_open:
		_close_phone()
	else:
		_open_phone(phonehub.current_tab)


func _open_phone(tab_id: String = "") -> void:
	phonehub.open(tab_id if tab_id != "" else PxbPhoneHub.DEFAULT_TAB)
	phone_open = true
	if player != null:
		player.input_blocked = true
	_phone_dim.visible = true
	_phone_panel.visible = true
	_phone_notch.visible = true
	_phone_homebar.visible = true
	# Toast doi khung (y=200) de len tieu de "Dien thoai" cua panel
	# (panel y=190) neu mo dien thoai ngay sau khi doi khung — an
	# toast khi mo dien thoai (loi 20/11 12:30).
	_toast.visible = false
	_refresh_phone()
	_update_hud()


func _close_phone() -> void:
	phonehub.close()
	phone_open = false
	if player != null:
		player.input_blocked = false
	_phone_dim.visible = false
	_phone_panel.visible = false
	_phone_notch.visible = false
	_phone_homebar.visible = false
	_update_hud()


func _phone_action(text: String, call: Callable) -> void:
	var b := Button.new()
	b.text = text
	_style_button(b, 24)
	b.custom_minimum_size = Vector2(580, 56)
	b.pressed.connect(call)
	_phone_actions.add_child(b)


func _clear_phone_actions() -> void:
	for c in _phone_actions.get_children():
		c.queue_free()


func _refresh_phone() -> void:
	if not phone_open:
		return
	for tab_id in _phone_tab_buttons:
		var unread := phonehub.unread_count(String(tab_id))
		var base := PxbPhoneHub.tab_name(String(tab_id))
		(_phone_tab_buttons[tab_id] as Button).text = \
			("%s (%d)" % [base, unread]) if unread > 0 else base
	_phone_title.text = "Điện thoại — " + PxbPhoneHub.tab_name(phonehub.current_tab)
	_phone_footer.text = "Ngày %d • Ví %sđ • Danh vọng %d • Chương %d" % [
		day, _fmt_vnd(jobs.gold), fame, story.chapter]
	var sl := _story_text().split("\n")
	_phone_hint.text = "Tiến trình — %s\n%s" % [sl[0], sl[2]] if sl.size() > 2 else "Tiến trình — " + sl[0]
	_phone_tip.text = "Mẹo: " + String(PHONE_TIPS[day % PHONE_TIPS.size()])
	_phone_today.text = _today_text()
	_clear_phone_actions()
	match phonehub.current_tab:
		PxbPhoneHub.TAB_DANH_BA_TIN_NHAN:
			_phone_content.text = _social_text()
			for rel in social.all_relations():
				var pid := String((rel as Dictionary).get("person_id", ""))
				var label := "Trò chuyện: %s" % String((rel as Dictionary).get("display_name", pid))
				_phone_action(label, _on_interact_pressed.bind(pid))
		PxbPhoneHub.TAB_NGAN_HANG:
			_wallet_to_economy()
			_phone_content.text = "Tiền mặt: %sđ\nTiết kiệm: %sđ (lãi 0,5%%/tháng game)\nĐiểm tín dụng: %d" % [
				_fmt_vnd(economy.money), _fmt_vnd(economy.savings), economy.credit_score]
			_phone_action("Gửi tiết kiệm 100.000đ", _on_deposit_pressed.bind(100000))
			_phone_action("Rút tiết kiệm 100.000đ", _on_withdraw_pressed.bind(100000))
		PxbPhoneHub.TAB_BAN_DO:
			var lines: Array[String] = ["Khu đã mở (chạm để đi nhanh):"]
			for m in maps_data["maps"]:
				var mid := int((m as Dictionary)["id"])
				if hotspot.can_fast_travel(mid):
					lines.append("• %s" % String((m as Dictionary)["name"]))
					_phone_action("Về %s" % String((m as Dictionary)["name"]), _on_travel_pressed.bind(mid))
			_phone_content.text = "\n".join(lines)
		PxbPhoneHub.TAB_VIEC_LAM:
			_phone_content.text = _jobs_text() + "\n\n" + _tools_text()
			_phone_action("Mở bảng việc làm", _on_open_jobs_pressed)
			for tool_id in PxbTools.TOOL_IDS:
				var tier := tools.tool_tier(String(tool_id))
				if tier == 0 and (String(tool_id) == "SoTay" or String(tool_id) == "Xeng"):
					_phone_action("Nhận %s (bậc 1)" % PxbTools.tool_name(String(tool_id)),
						_on_tool_acquire_pressed.bind(String(tool_id)))
				elif tier >= 1 and tier < 3:
					_phone_action("Nâng %s lên bậc %d" % [
						PxbTools.tool_name(String(tool_id)), tier + 1],
						_on_tool_upgrade_pressed.bind(String(tool_id)))
		PxbPhoneHub.TAB_CHO:
			_phone_content.text = "Chợ — mua bằng ví (tiền mặt %sđ).\nĐã sở hữu: %s" % [
				_fmt_vnd(jobs.gold), _owned_text()]
			for it in _cheapest_shop_items(4):
				var iid := String((it as Dictionary)["id"])
				_phone_action("Mua %s — %sđ" % [
					String((it as Dictionary)["name"]), _fmt_vnd(int((it as Dictionary)["price_vnd"]))],
					_on_buy_pressed.bind(iid))
		PxbPhoneHub.TAB_HOC_TAP:
			_phone_content.text = _education_text()
			for i in PxbEducation.degree_list().size():
				var d := PxbEducation.get_degree(i)
				_phone_action("Đăng ký %s — %sđ, %d ngày" % [
					String(d["name"]), _fmt_vnd(int(d["fee_vnd"])), int(d["days"])],
					_on_enroll_pressed.bind(i))
			_phone_action("Khóa ngắn: Sáng tạo 3 ngày — 2.000.000đ",
				_on_enroll_short_pressed)
		PxbPhoneHub.TAB_SUC_KHOE:
			_phone_content.text = "Thể %d • Trí %d • Tâm %d (tổng %d, trần %d)\nLuyện tập đổi chỉ số (tổng không đổi):" % [
				stats.the, stats.tri, stats.tam, stats.total(), PxbBalance.TOTAL_STAT_CAP]
			_phone_action("Luyện Thể +5 (Trí −5)", _on_train_pressed.bind(["the", "tri"]))
			_phone_action("Luyện Trí +5 (Thể −5)", _on_train_pressed.bind(["tri", "the"]))
			_phone_action("Luyện Tâm +5 (Thể −5)", _on_train_pressed.bind(["tam", "the"]))
		PxbPhoneHub.TAB_XA_HOI:
			_phone_content.text = _story_text()
			_phone_action("Lên chương tiếp", _on_advance_chapter_pressed)
			if titles.can_redeem():
				_phone_action("Đổi phe: bỏ danh hiệu phe Tà", _on_redeem_pressed)
		PxbPhoneHub.TAB_CAI_DAT:
			_phone_content.text = "Cài đặt — %s" % _online_text()
			for slot in [1, 2, 3]:
				_phone_action("Lưu vào slot %d" % slot, _on_save_pressed.bind(slot))
				_phone_action("Tải slot %d" % slot, _on_load_pressed.bind(slot))
			_phone_action("Kiểm tra mạng (server local)", _on_check_online_pressed)
			_phone_action("Đồng bộ slot 1 lên server", _on_upload_pressed.bind(1))
		_:
			_phone_content.text = "Tab này chưa có nội dung."
	# Chieu cao vung nut theo so nut that (toi da 240): nut it thi
	# vung thu lai, goi y + chan trang noi ngay sau — khong de khoang
	# trong 140-180px nhu truoc (loi 20/11 12:30).
	var n_act := _phone_actions.get_child_count() + 1  # + nut Dong.
	_phone_act_scroll.custom_minimum_size = Vector2(580, clampi(64 * n_act - 8, 64, 240))
	_phone_action("Đóng điện thoại", _close_phone)


func _today_text() -> String:
	# Khoi "Hom nay" trong dien thoai: thong tin that cua khu dang
	# dung + muc tieu truyen — lap khoang trong giua nut bam va khoi
	# Tien trinh (loi 20/11 12:30).
	var npcs := 0
	var total := 0
	if iso_map != null:
		for mk in iso_map.markers:
			total += 1
			if String(mk.event_data.get("kind", "")) == "npc":
				npcs += 1
	var sl := _story_text().split("\n")
	var goal := sl[0] if not sl.is_empty() else ""
	return "Hôm nay — Ngày %d • Khung %s • %s: %d người, %d điểm tương tác\n%s" % [
		day, _frame_name(), String(_map_by_id(current_map_id).get("name", "")), npcs, total, goal]

func _social_text() -> String:
	var lines: Array[String] = ["Danh bạ — trò chuyện tăng thân thiết (+5/lần). Chưa quen thì nói ở ngoài đời:"]
	var known: Dictionary = {}
	for rel in social.all_relations():
		var r := rel as Dictionary
		known[String(r.get("person_id", ""))] = true
		var kind_name := String(KIND_NAMES.get(String(r.get("kind", "")), String(r.get("kind", ""))))
		var name := String(r.get("display_name", ""))
		# Bo lap "Bạn thân — Bạn thân": ten hien thi trung ten loai
		# quan he thi chi in 1 lan (loi 20/11 11:40).
		if name == kind_name:
			lines.append("• %s, thân thiết %d/100 (%s)" % [
				name,
				int(r.get("closeness", 0)),
				String(STAGE_NAMES.get(String(r.get("stage", "")), String(r.get("stage", ""))))])
		else:
			lines.append("• %s — %s, thân thiết %d/100 (%s)" % [
				name,
				kind_name,
				int(r.get("closeness", 0)),
				String(STAGE_NAMES.get(String(r.get("stage", "")), String(r.get("stage", ""))))])
	# Lap khoang trong 1/3 bang: liet ke ca NPC chua quen (toan bo
	# 18 khu) — nguoi choi thay ngay ai co the lam quen.
	var seen_npc: Dictionary = {}
	for m in maps_data["maps"]:
		for e in (m as Dictionary).get("events", []):
			var ev := e as Dictionary
			if String(ev.get("kind", "")) != "npc":
				continue
			var pid := String(ev.get("id", ""))
			if pid == "" or seen_npc.has(pid) or known.has(pid):
				continue
			seen_npc[pid] = true
			# Gon 1 dong (ten NPC dai nhat 20 ky tu + "— chưa quen"
			# = 34 ky tu, vua 1 dong 620px): khong go xuong 2 dong
			# nua — dong 2 bi cat o mep duoi viewport la loi "Chi
			# Le" 20/11 13:53/14:15. Goi y noi chuyen chuyen len
			# dong tieu de.
			lines.append("• %s — chưa quen" % String(ev.get("name", pid)))
	if social.all_relations().is_empty() and seen_npc.is_empty():
		lines.append("(chưa có quan hệ nào)")
	# Dong trong cuoi: khi cuon het xuong, dong that cuoi khong bi
	# cat doi o mep duoi viewport (loi "Chi Le" 20/11 13:53).
	return "\n".join(lines) + "\n "


func _jobs_text() -> String:
	var lines: Array[String] = ["Việc làm — lương ca hiện tại:"]
	for job in PxbBalance.JOBS:
		var j := job as Dictionary
		var jid := String(j["id"])
		lines.append("• %s: %sđ/ca (còn %d ca/tuần)" % [
			String(j["name"]),
			_fmt_vnd(PxbJobs.pay_per_shift(jid, stats, _frame_name(), jobs.get_demand(jid))),
			jobs.shifts_left(jid)])
	return "\n".join(lines)


func _tools_text() -> String:
	var lines: Array[String] = ["Công cụ:"]
	for tool_id in PxbTools.TOOL_IDS:
		var tier := tools.tool_tier(String(tool_id))
		lines.append("• %s: %s" % [PxbTools.tool_name(String(tool_id)),
			("chưa có" if tier == 0 else "bậc %d (%s)" % [tier, String(PxbTools.TIER_NAMES[tier])])])
		if tier >= 1:
			lines.append("  %s" % tools.tool_behaviour_current(String(tool_id)))
	return "\n".join(lines)


func _owned_text() -> String:
	if economy.owned.is_empty():
		return "chưa có"
	var names: Array[String] = []
	for oid in economy.owned:
		var it := PxbEconomy.get_item(String(oid))
		names.append(String(it.get("name", oid)) if not it.is_empty() else String(oid))
	return " • ".join(names)


func _cheapest_shop_items(count: int) -> Array:
	var all: Array = []
	for group in [PxbEconomy.houses(), PxbEconomy.cars(), PxbEconomy.phones(), PxbEconomy.clothes()]:
		all.append_array(group)
	all.sort_custom(func(a, b) -> bool: return int(a["price_vnd"]) < int(b["price_vnd"]))
	return all.slice(0, mini(count, all.size()))


func _education_text() -> String:
	var lines: Array[String] = ["Học tập — 5 bậc (học phí trả 1 lần lúc đăng ký):"]
	for i in PxbEducation.degree_list().size():
		var d := PxbEducation.get_degree(i)
		var owned := "✓ đã có" if education.has_degree_or_higher(i) else ""
		lines.append("• %s: %sđ, %d ngày, Trí ≥ %d, +%d EXP %s" % [
			String(d["name"]), _fmt_vnd(int(d["fee_vnd"])), int(d["days"]),
			int(d["tri"]), int(d["exp"]), owned])
	var prog := education.study_progress()
	if not (prog["enrolled"] as Dictionary).is_empty():
		var e := prog["enrolled"] as Dictionary
		lines.append("Đang học: %s, còn %d ngày (tốt nghiệp ngày %d)" % [
			String(PxbEducation.get_degree(int(e["degree_index"]))["name"]),
			int(prog["days_left"]), int(e["end_day"])])
	if education.pending_exp > 0 or education.pending_fame > 0:
		lines.append("Chờ nhận: +%d EXP, +%d Danh vọng" % [education.pending_exp, education.pending_fame])
	return "\n".join(lines)


func _story_text() -> String:
	_wallet_to_economy()
	var assets := economy.total_assets()
	var ending := PxbStory.suggest_ending(assets, stats.tri, fame, stats.an_yen(), social.is_married_to("ban-than"))
	var lines: Array[String] = [
		"Chương %d: %s" % [story.chapter, story.chapter_name()],
		"Danh vọng: %d • Tài sản: %sđ • An Yên: %d" % [fame, _fmt_vnd(assets), stats.an_yen()],
		"Ending gợi ý hiện tại: %s" % String(ENDING_NAMES.get(ending, ending)),
		"Danh hiệu (%s): %s" % [titles.alignment,
			(" • ".join(titles.all_titles()) if not titles.all_titles().is_empty() else "chưa có")],
		"Quest giúp NPC: %d/3 (cần cho chương 4)" % story.help_quests_done,
	]
	return "\n".join(lines)


func _online_text() -> String:
	var st := savecloud.sync_status()
	return "Online: %s • Đồng bộ: %s (%s)" % [
		("có mạng" if online.is_online() else "ngoại tuyến"),
		String(st["status"]), String(st["detail"])]


# --- Hanh dong tu dien thoai (tra Dictionary de test goi truc tiep) ---

func buy_item(item_id: String) -> Dictionary:
	_wallet_to_economy()
	var res := economy.buy(item_id)
	if bool(res.get("ok", false)):
		fame += int(res.get("fame_gained", 0))
		_wallet_from_economy()
		show_toast("Đã mua %s." % String(PxbEconomy.get_item(item_id).get("name", item_id)))
	else:
		match String(res.get("reason", "")):
			"khong-du-tien":
				show_toast("Không đủ tiền mua món này.")
			"khong-co-mon":
				show_toast("Không có món này trong chợ.")
			_:
				show_toast("Không mua được.")
	_refresh_phone()
	return res


func deposit_savings(amount: int) -> bool:
	_wallet_to_economy()
	var ok := economy.deposit_savings(amount)
	_wallet_from_economy()
	show_toast("Đã gửi tiết kiệm %sđ." % _fmt_vnd(amount) if ok else "Không gửi được (vượt tiền mặt).")
	_refresh_phone()
	return ok


func withdraw_savings(amount: int) -> bool:
	_wallet_to_economy()
	var ok := economy.withdraw_savings(amount)
	_wallet_from_economy()
	show_toast("Đã rút tiết kiệm %sđ." % _fmt_vnd(amount) if ok else "Không rút được (vượt tiết kiệm).")
	_refresh_phone()
	return ok


func enroll_degree(idx: int) -> Dictionary:
	var res := education.enroll(idx, stats.tri, -1, jobs.gold)
	if bool(res.get("ok", false)):
		var fee := int(res.get("fee_paid", 0))
		if fee > 0:
			jobs.gold -= fee
			_wallet_to_economy()
		_update_hud()
		show_toast("Đã đăng ký %s — tốt nghiệp ngày %d." % [
			String(PxbEducation.get_degree(idx).get("name", "")),
			int(res.get("end_day", 0))])
	else:
		match String(res.get("reason", "")):
			"khong-du-tien":
				show_toast("Không đủ tiền đóng học phí.")
			"chua-du-tri":
				show_toast("Chưa đủ Trí để đăng ký bậc này.")
			"can-mentor":
				show_toast("Bậc này cần người hướng dẫn (mentor).")
			"dang-hoc":
				show_toast("Đang học một bằng khác rồi.")
			"da-co-bang":
				show_toast("Đã có bằng này hoặc cao hơn.")
			_:
				show_toast("Không đăng ký được.")
	_refresh_phone()
	return res


# Khoa ngan han mau cua UI (PROVISIONAL): Sang tao, 3 ngay, 2 trieu.
func enroll_short_course() -> Dictionary:
	var res := education.enroll_short_course("sang", 3, 2000000, jobs.gold)
	if bool(res.get("ok", false)):
		var fee := int(res.get("fee_paid", 0))
		if fee > 0:
			jobs.gold -= fee
			_wallet_to_economy()
		_update_hud()
		show_toast("Đã đăng ký khóa ngắn Sáng tạo — xong ngày %d." % int(res.get("end_day", 0)))
	else:
		match String(res.get("reason", "")):
			"khong-du-tien":
				show_toast("Không đủ tiền đóng phí khóa ngắn.")
			"dang-hoc-khoa-ngan":
				show_toast("Đang học một khóa ngắn khác rồi.")
			_:
				show_toast("Không đăng ký được khóa ngắn.")
	_refresh_phone()
	return res


func train_stat(up: String, down: String) -> bool:
	var ok := stats.train(up, down, 5)
	if ok:
		_update_hud()
		show_toast("Luyện tập: %s +5, %s −5." % [up, down])
	else:
		show_toast("Không luyện được (chỉ số đã chạm trần/sàn).")
	_refresh_phone()
	return ok


func interact_friend(person_id: String) -> bool:
	var rel := social.get_rel(person_id)
	if rel.is_empty():
		show_toast("Không tìm thấy người này.")
		return false
	var ok := PxbSocial.interact(rel, day)
	if ok:
		_update_hud()
		show_toast("Trò chuyện xong — thân thiết %d/100." % int(rel.get("closeness", 0)))
	_refresh_phone()
	return ok


func travel_to(map_id: int) -> bool:
	if not hotspot.can_fast_travel(map_id):
		show_toast("Khu này chưa mở.")
		return false
	var dest := _map_by_id(map_id)
	if dest.is_empty():
		show_toast("Chưa có dữ liệu map cho khu này.")
		return false
	_close_phone()
	var door_tile := Vector2i(5, 4)
	for e in dest["events"]:
		if String(e.get("kind", "")) == "door":
			door_tile = Vector2i(e["tile"][0], e["tile"][1])
			break  # Lay cua dau tien (cua ve (5,4)) — xem ghi chu o _transfer.
	load_map(map_id, door_tile)
	show_toast("Đã về " + String(dest["name"]))
	return true


func advance_story_chapter() -> bool:
	_wallet_to_economy()
	var ok := story.advance_chapter(stats.tri, fame, economy.total_assets(),
		social.has_supporter())
	if ok:
		_update_hud()
		show_toast("Lên chương %d: %s!" % [story.chapter, story.chapter_name()])
	else:
		show_toast("Chưa đủ điều kiện lên chương tiếp (xem yêu cầu ở tab Xã hội).")
	_refresh_phone()
	return ok


func redeem_titles() -> bool:
	var ok := titles.redeem()
	show_toast("Đã bỏ danh hiệu phe Tà." if ok else "Chỉ đổi phe được khi đang ở phe Tà.")
	_refresh_phone()
	return ok


func upgrade_tool(tool_id: String) -> Dictionary:
	var res := tools.upgrade(tool_id)
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("%s lên bậc %d!" % [PxbTools.tool_name(tool_id), int(res.get("to_tier", 0))])
	else:
		match String(res.get("reason", "")):
			"thieu-nguyen-lieu":
				show_toast("Thiếu nguyên liệu để nâng cấp.")
			"da-max":
				show_toast("Công cụ đã bậc tối đa.")
			"chua-co-cong-cu":
				show_toast("Chưa có công cụ này.")
			_:
				show_toast("Không nâng cấp được.")
	_refresh_phone()
	return res


func acquire_tool(tool_id: String) -> Dictionary:
	var res := tools.acquire(tool_id)
	if bool(res.get("ok", false)):
		_update_hud()
		show_toast("Đã nhận %s (bậc 1)!" % PxbTools.tool_name(tool_id))
	else:
		match String(res.get("reason", "")):
			"thieu-nguyen-lieu":
				show_toast("Thiếu nguyên liệu để nhận công cụ.")
			"dung-che-tao":
				show_toast("Công cụ này phải chế tạo, không nhận trực tiếp.")
			_:
				show_toast("Không nhận được công cụ.")
	_refresh_phone()
	return res


# --- Save / Load (PxbSaveCloud, slot 1-3, file user://) ---

func _collect_system_data() -> Dictionary:
	return {
		"game_day": day, "day": day, "frame": frame_idx, "fame": fame,
		"pxb_time": {"game_day": day},
		"pxb_stats": stats.data(), "pxb_jobs": jobs.data(),
		"pxb_hotspot": hotspot.data(), "pxb_crafting": crafting.data(),
		"pxb_economy": economy.data(), "pxb_education": education.data(),
		"pxb_social": social.data(), "pxb_titles": titles.data(),
		"pxb_story": story.data(), "pxb_tools": tools.data(),
		"pxb_phonehub": phonehub.data(), "pxb_savecloud": savecloud.data(),
		"pxb_online": online.data(), "pxb_marketbattle": battle_state,
	}


func save_game(slot: int) -> Dictionary:
	var res := savecloud.save_to_local(slot, _collect_system_data())
	if bool(res.get("ok", false)):
		show_toast("Đã lưu vào slot %d (%s)." % [slot, String(res.get("where", ""))])
	else:
		show_toast("Lưu thất bại: %s" % String(res.get("reason", "")))
	_refresh_phone()
	return res


func load_game(slot: int) -> Dictionary:
	var res := savecloud.load_from_local(slot)
	if not bool(res.get("ok", false)):
		show_toast("Không tải được: %s" % String(res.get("reason", "")))
		_refresh_phone()
		return res
	var save: Dictionary = res.get("save", {})
	_apply_save_data(save.get("gameSystem", {}))
	_update_hud()
	_update_daynight()
	_refresh_phone()
	show_toast("Đã tải save slot %d." % slot)
	return {"ok": true, "slot": slot}


# Khoi phuc toan bo state tu dict gameSystem cua save. Stats khoi phuc
# tai cho (autoload-safe); cac he khac tao moi qua from_data() tinh roi
# thay node cu + bind lai (tui chung / crafting / stats).
func _apply_save_data(gs: Dictionary) -> void:
	if gs.is_empty():
		return
	day = maxi(int(gs.get("day", gs.get("game_day", 1))), 1)
	frame_idx = clampi(int(gs.get("frame", 0)), 0, 2)
	fame = maxi(int(gs.get("fame", 0)), 0)
	var sd: Dictionary = gs.get("pxb_stats", {})
	if not sd.is_empty():
		stats.set_stat("the", int(sd.get("the", stats.the)))
		stats.set_stat("tri", int(sd.get("tri", stats.tri)))
		stats.set_stat("tam", int(sd.get("tam", stats.tam)))
	_replace_system("jobs", PxbJobs.from_data(gs.get("pxb_jobs", {})))
	jobs.stats = stats
	jobs.set_day_number(day)
	_replace_system("hotspot", PxbHotspot.from_data(gs.get("pxb_hotspot", {})))
	_replace_system("crafting", PxbCrafting.from_data(gs.get("pxb_crafting", {})))
	crafting.bind_materials(hotspot.materials)
	inventory = hotspot.materials
	_replace_system("economy", PxbEconomy.from_data(gs.get("pxb_economy", {})))
	_replace_system("education", PxbEducation.from_data(gs.get("pxb_education", {})))
	education.day_number = day
	_replace_system("social", PxbSocial.from_data(gs.get("pxb_social", {})))
	_replace_system("titles", PxbTitles.from_data(gs.get("pxb_titles", {})))
	_replace_system("story", PxbStory.from_data(gs.get("pxb_story", {})))
	_replace_system("tools", PxbTools.from_data(gs.get("pxb_tools", {})))
	tools.bind_materials(hotspot.materials)
	tools.bind_crafting(crafting)
	tools.bind_hotspot(hotspot)
	phonehub.from_data(gs.get("pxb_phonehub", {}))
	savecloud.from_data(gs.get("pxb_savecloud", {}))
	online.from_data(gs.get("pxb_online", {}))
	# G4 buoc 5: khoi phuc giu sap + lich su tran (loc qua from_data
	# de loai hold rac), don sap het han theo ngay game vua tai.
	var _mb_tmp := PxbMarketBattle.new()
	_mb_tmp.from_data(gs.get("pxb_marketbattle", {}))
	battle_state = _mb_tmp.data()
	_mb_tmp.free()
	PxbMarketBattle.expire_holds(battle_state, day)
	_wallet_to_economy()


func _replace_system(kind: String, node: Node) -> void:
	match kind:
		"jobs":
			jobs.queue_free()
			jobs = node as PxbJobs
		"hotspot":
			hotspot.queue_free()
			hotspot = node as PxbHotspot
		"crafting":
			crafting.queue_free()
			crafting = node as PxbCrafting
		"economy":
			economy.queue_free()
			economy = node as PxbEconomy
		"education":
			education.queue_free()
			education = node as PxbEducation
		"social":
			social.queue_free()
			social = node as PxbSocial
		"titles":
			titles.queue_free()
			titles = node as PxbTitles
		"story":
			story.queue_free()
			story = node as PxbStory
		"tools":
			tools.queue_free()
			tools = node as PxbTools
	add_child(node)


# Kiem tra mang (PxbOnline la async — can await; chay nen, ket qua
# hien lai khi mo tab Cai dat). Server .NET chua chay tren VM nen
# du kien offline — bao dung that, khong gia vo online.
func _check_online() -> void:
	var res: Dictionary = await online.health_check()
	phonehub.notify(PxbPhoneHub.TAB_CAI_DAT)
	if bool(res.get("ok", false)):
		show_toast("Đã nối server: %s" % String(res.get("status", "")))
	else:
		show_toast("Không tới được server (%s) — chơi ngoại tuyến." % String(res.get("reason", "")))
	_refresh_phone()


# --- Nut bam cua panel dien thoai (goi ham tren, de test goi truc tiep) ---

func _on_phone_tab_pressed(tab_id: String) -> void:
	phonehub.select_tab(tab_id)
	_refresh_phone()


func _on_buy_pressed(item_id: String) -> void:
	buy_item(item_id)


func _on_deposit_pressed(amount: int) -> void:
	deposit_savings(amount)


func _on_withdraw_pressed(amount: int) -> void:
	withdraw_savings(amount)


func _on_enroll_pressed(idx: int) -> void:
	enroll_degree(idx)


func _on_enroll_short_pressed() -> void:
	enroll_short_course()


func _on_train_pressed(pair: Array) -> void:
	train_stat(String(pair[0]), String(pair[1]))


func _on_interact_pressed(person_id: String) -> void:
	interact_friend(person_id)


func _on_travel_pressed(map_id: int) -> void:
	travel_to(map_id)


func _on_advance_chapter_pressed() -> void:
	advance_story_chapter()


func _on_redeem_pressed() -> void:
	redeem_titles()


func _on_tool_upgrade_pressed(tool_id: String) -> void:
	upgrade_tool(tool_id)


func _on_tool_acquire_pressed(tool_id: String) -> void:
	acquire_tool(tool_id)


func _on_save_pressed(slot: int) -> void:
	save_game(slot)


func _on_load_pressed(slot: int) -> void:
	load_game(slot)


func _on_check_online_pressed() -> void:
	_check_online()


func _on_upload_pressed(slot: int) -> void:
	var res := savecloud.upload_save(slot)
	match String(res.get("reason", "")):
		"server-chua-co-endpoint":
			show_toast("Server chưa có endpoint save — chưa đồng bộ lên cloud.")
		"chua-dang-nhap":
			show_toast("Chưa đăng nhập nên chưa đồng bộ được.")
		_:
			show_toast("Đồng bộ: %s" % String(res.get("reason", "")))
	_refresh_phone()


func _on_open_jobs_pressed() -> void:
	_close_phone()
	_show_jobs_dialogue()

# --- UI ---
# Theme chung kieu Nadia: giay vang am + vien go nau + bong mem — 1 theme
# dung cho ca game (HUD / dien thoai / doi thoai / title). Dien thoai
# la hub gon nhu Nadia: khung go dam hon, goc bo tron lon.
func _panel_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 12
	s.corner_radius_top_right = 12
	s.corner_radius_bottom_left = 12
	s.corner_radius_bottom_right = 12
	s.border_color = Color(0.45, 0.30, 0.16, 1)
	s.set_border_width_all(3)
	s.shadow_color = Color(0, 0, 0, 0.25)
	s.shadow_size = 5
	s.shadow_offset = Vector2(0, 3)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

# Khung dien thoai: vo go dam + goc bo tron lon — nhin nhu 1 thiet bi
# trong the gioi (hub cua Nadia), khong phai panel menu thuong.
func _phone_panel_style() -> StyleBoxFlat:
	var s := _panel_style(Color(0.99, 0.97, 0.92, 1.0))
	s.set_corner_radius_all(18)
	s.set_border_width_all(4)
	s.border_color = Color(0.38, 0.24, 0.12, 1)
	return s

func _style_button(b: Button, font_size: int = 26) -> void:
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_font_override("font", font)
	b.add_theme_color_override("font_color", Color(1.0, 0.96, 0.88, 1))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92, 1))
	b.add_theme_color_override("font_pressed_color", Color(0.95, 0.90, 0.80, 1))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.62, 0.42, 0.22, 1)
	normal.set_corner_radius_all(10)
	normal.border_color = Color(0.42, 0.27, 0.13, 1)
	normal.set_border_width_all(2)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.shadow_color = Color(0, 0, 0, 0.25)
	normal.shadow_size = 3
	normal.shadow_offset = Vector2(0, 2)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.72, 0.50, 0.28, 1)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.50, 0.33, 0.16, 1)
	pressed.shadow_size = 0
	pressed.shadow_offset = Vector2.ZERO
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

# --- Anh sang ngay/dem theo khung (art pass 20/11 buoi 2) ---
# Overlay mau phu len the gioi: Sang trong suot, Chieu vang cam
# golden-hour, Toi xanh dem dam.
# Vong 5 (20/11 14:40) — LOI GOC: overlay cu o CanvasLayer layer 0
# (cung lop voi canvas mac dinh): thu tu ve giua lop overlay va
# IsoMap/player phu thuoc thu tu cay — lop phu chi chac chan ap
# cho phan them truoc no, phan them sau (nen/nhan vat) co the thoat
# khoi lop phu -> khung Toi/Chieu chia doi sang/toi theo vung
# (kiem live 14:34: 1/3 phai TAP HOA van sang). Sua tan goc:
# overlay vao CanvasLayer layer 1 RIENG, tao TRUOC lop nhan + lop
# HUD (cung layer 1, ve sau) -> lop phu phu DEU len TOAN BO the
# gioi (nen + dat + nhan vat + dom sang) duoi HUD, khong con
# duong chia. Lop phu la nguon duy nhat doi mau theo khung —
# khong tint rieng nhan vat nua (tint rieng + lop MUL nhan doi
# lam nhan vat thanh bong den, kiem live 14:34).
func _daynight_color(f: int) -> Color:
	# Overlay dung che do NHAN (CanvasItemMaterial BLEND_MODE_MUL):
	# toi di ca anh nhung giu tuong phan — nha/cua van nhin thay,
	# khong bi lop alpha dac nuot (loi khung Toi van sang, 20/11 10:30).
	# Sang = trang (khong doi); Chieu = vang cam; Toi = xanh dem.
	# Toi voi anh nen dem rieng (1-2): anh dem da toi san (~0.65)
	# nen MUL nhe (0.7 thay 0.55): nhan vat (khong tint rieng nua)
	# con ~0.7 do sang — thay ro mat/quan ao, hoa vao canh dem
	# chu khong thanh bong den (loi 20/11 14:34).
	match f:
		1:
			return Color(1.0, 0.82, 0.55, 1.0)
		2:
			if iso_map != null and iso_map.has_night_bg:
				return Color(0.7, 0.78, 0.95, 1.0)
			return Color(0.55, 0.62, 0.9, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)

## Chong-chong nhan (vong 4, 20/11 14:00, sua lan 2; vong 5 tang khe
## ho: LABEL_GAP 4 -> 12, vat can cao hon de nhan khong cham toc
## nhan vat — kiem live 14:34: "Goc Che Tao" gan cham toc, mep nhan
## cham mep nhau khong co khe ho).
const LABEL_GAP := 12.0
const LABEL_MAX_DRIFT := 60.0
# Nhan khong xuong qua y=1200 man hinh (truoc 1264): "Cua ra Cho
# Dau Moi" sat mep duoi gan bi cat (kiem live 14:34); de 80px
# thoang o day man hinh.
const LABEL_BOTTOM_MAX := 1200.0

func _sprite_obstacle_rect(screen_pos: Vector2) -> Rect2:
	# Dau + than tren cua sprite anh cao 104 world (~146px man hinh
	# o zoom 1.4): tam o chan nhan vat, toc o -165, nguc o -50.
	# (Vong 5: -150 cu de nhan cham toc — toc nhon cao hon dinh dau
	# tinh toan, tang them 15px.)
	return Rect2(screen_pos + Vector2(-48, -165), Vector2(96, 115))

func _resolve_label_overlaps() -> void:
	if iso_map == null:
		return
	var ct := get_viewport().get_canvas_transform()
	var obstacles: Array[Rect2] = []
	if player != null:
		obstacles.append(_sprite_obstacle_rect(ct * player.position))
	for mk in iso_map.markers:
		var sp: Vector2 = ct * mk.global_position
		if String(mk.event_data.get("kind", "")) == "npc":
			obstacles.append(_sprite_obstacle_rect(sp))
		elif String(mk.event_data.get("kind", "")) in ["hotspot", "craft", "door"]:
			# Bieu tuong sao/ban/cua (~48x48px man hinh): nhan "Hem
			# tro buoi toi" khong duoc che mui ten xanh / sao
			# (kiem live 14:34). Vat can nho, chi bao ve tam bieu
			# tuong, khong day nhan di xa.
			obstacles.append(Rect2(sp + Vector2(-24, -24), Vector2(48, 48)))
	var entries: Array = []
	for mk in iso_map.markers:
		var r: Rect2 = mk.label_screen_rect()
		if r.size != Vector2.ZERO:
			entries.append({"mk": mk, "rect": r})
		else:
			mk.label_override = Rect2()
	# Nhan NPC truoc (giu tren dau), roi den cac nhan khac; trong
	# cung loai thi nhan tren truoc.
	entries.sort_custom(func(a, b):
		var ka := 0 if String(a["mk"].event_data.get("kind", "")) == "npc" else 1
		var kb := 0 if String(b["mk"].event_data.get("kind", "")) == "npc" else 1
		if ka != kb:
			return ka < kb
		return a["rect"].position.y < b["rect"].position.y)
	var placed: Array[Rect2] = []
	for e in entries:
		var r: Rect2 = e["rect"]
		var want_y := r.position.y
		var best_y := _nearest_free_y(r, obstacles, placed)
		if best_y < 0.0 or absf(best_y - want_y) > LABEL_MAX_DRIFT:
			# Khoang doc gan nhat qua xa — thu dich ngang giu
			# nguyen y (uu tien dich phai, roi dich trai). Dich
			# ngang cung phai giu khe LABEL_GAP voi vat can /
			# nhan da dat (grow 12px roi moi intersects): chi
			# kiem intersects() tho se chap nhan vi tri chi cach
			# 4px (vd "Goc Che Tao" sat "Co Tu", kiem live
			# 14:34) — khong du khe ho nhin.
			var shifted := false
			for dx in [40.0, 80.0, 120.0, 160.0, -40.0, -80.0, -120.0, -160.0]:
				var cand := Rect2(r.position + Vector2(dx, 0), r.size)
				cand.position.x = clampf(cand.position.x, 16.0, 704.0 - r.size.x)
				if cand.position.x == r.position.x:
					continue
				var hit := false
				var grown := cand.grow(LABEL_GAP)
				for o in obstacles:
					if grown.intersects(o):
						hit = true
						break
				if not hit:
					for p in placed:
						if grown.intersects(p):
							hit = true
							break
				if not hit:
					r.position = cand.position
					shifted = true
					break
			if not shifted and best_y >= 0.0:
				r.position.y = best_y
		else:
			r.position.y = best_y
		r.position.x = clampf(r.position.x, 16.0, 704.0 - r.size.x)
		r.position.y = clampf(r.position.y, 190.0, LABEL_BOTTOM_MAX - r.size.y)
		placed.append(r)
		e["mk"].label_override = r

## Top gan nhat trong khoang doc trong (khong de len vat can / nhan
## da dat, cach LABEL_GAP). Tra -1 neu khong co khoang trong nao.
func _nearest_free_y(r: Rect2, obstacles: Array[Rect2], placed: Array[Rect2]) -> float:
	var blockers: Array[Rect2] = []
	for o in obstacles:
		if o.end.x > r.position.x and o.position.x < r.end.x:
			blockers.append(o)
	for p in placed:
		if p.end.x > r.position.x and p.position.x < r.end.x:
			blockers.append(p)
	var top_min := 190.0
	var top_max := LABEL_BOTTOM_MAX - r.size.y
	var intervals: Array = [[top_min, top_max]]
	for b in blockers:
		var next_iv: Array = []
		for iv in intervals:
			var lo: float = iv[0]
			var hi: float = iv[1]
			var b_lo: float = b.position.y - r.size.y - LABEL_GAP
			var b_hi: float = b.end.y + LABEL_GAP
			if b_hi <= lo or b_lo >= hi:
				next_iv.append(iv)
			else:
				if b_lo > lo:
					next_iv.append([lo, minf(hi, b_lo)])
				if b_hi < hi:
					next_iv.append([maxf(lo, b_hi), hi])
		intervals = next_iv
	var best_y := -1.0
	var best_dist := 1.0e9
	for iv in intervals:
		var y := clampf(r.position.y, iv[0], iv[1])
		var d := absf(y - r.position.y)
		if d < best_dist:
			best_dist = d
			best_y = y
	return best_y

func _update_daynight() -> void:
	if _daynight != null:
		_daynight.color = _daynight_color(frame_idx)
	if iso_map != null and iso_map.night_glow != null:
		iso_map.night_glow.set_lit(frame_idx == 2)
	if iso_map != null:
		iso_map.set_frame(frame_idx)
		_update_character_tint()

## Tint nhan vat theo khung: Vong 5 BO tint rieng — lop overlay MUL
## thong nhat (CanvasLayer layer 1, tren toan bo the gioi) da toi
## nhan vat cung muc voi nen. Tint rieng truoc day nhan them 1 nac
## (overlay 0.55 x tint 0.42 = 0.23) lam nhan vat thanh bong den
## chi con mat trang (kiem live 14:34). Giu ham de khong phai sua
## cac noi goi; tra ve trang o moi khung.
func _update_character_tint() -> void:
	var tint := Color(1, 1, 1, 1)
	if player != null:
		player.set_tint(tint)
	if iso_map != null:
		for mk in iso_map.markers:
			if mk.has_method("set_tint"):
				mk.set_tint(tint)

func _build_ui() -> void:
	# Nen dat ve tay (ground_wide.jpg): 1 anh lon co dinh cho moi map,
	# mep tren la via he co bac them nam duoi chan mat tien — thay cho
	# hinh thoi IsoMap._draw cu (le toa do + duong noi gat + mang
	# zigzag). Them o index 0 cua Main (duoi iso_map/player) de
	# khong che vat; vi tri co dinh vi moi map 12x9 deu cung offset.
	if ResourceLoader.exists("res://art/ground_wide.jpg"):
		var gtex := load("res://art/ground_wide.jpg") as Texture2D
		var g := Sprite2D.new()
		g.texture = gtex
		g.scale = Vector2(1400.0 / float(gtex.get_width()), 900.0 / float(gtex.get_height()))
		g.position = Vector2(360, 730)  # Mep tren o y=280, duoi chan mat tien (~322).
		add_child(g)
		move_child(g, 0)
	# Camera bam nguoi choi, zoom 1.4 de map lap day viewport 720x1280
	# (1.6 cu hep tam nhin doc, khong thay troi luc spawn).
	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.4, 1.4)
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 10.0
	add_child(_camera)
	_camera.make_current()
	# Lop overlay ngay/dem: CanvasLayer RIENG, layer 1, tao TRUOC lop
	# nhan + lop HUD (cung layer 1, ve sau) — phu DEU len toan bo
	# the gioi (nen + dat + nhan vat + dom sang), duoi nhan/HUD.
	# Vong 5 (20/11 14:40): layer 0 cu cung lop voi canvas mac
	# dinh, thu tu ve phu thuoc thu tu cay -> khung Toi/Chieu chia
	# doi sang/toi theo vung (1/3 phai TAP HOA van sang, kiem live
	# 14:34). Layer 1 chac chan o tren canvas mac dinh (lop 0) nen
	# khong con truong hop nao thoat khoi lop phu.
	# Vong 6 (20/11 16:xx): LOI GOC THU 2 — follow_viewport_enabled
	# = true khien lop nay BAM THEO CAMERA: ColorRect (0,0)-(720,1280)
	# thanh hinh chu nhat THE GIOI x 0..720, khong phai man hinh.
	# Luc spawn camera x=280, lop phu man hinh -32..976 (du) nen
	# khong thay loi; camera sang phai cuoi map x=600 thi lop chi
	# phu toi man hinh x=528, phan phai x>528 thoat lop phu -> dai
	# doc sang nhu ban ngay, cat doi cua so TAP HOA (do pixel:
	# ran gioi dung x=527 ca Chieu lan Toi, khop (720-600)*1.4+360).
	# SUA: follow_viewport PHAI false (mac dinh) — CanvasLayer
	# khong theo viewport thi o khong gian man hinh, ColorRect
	# 720x1280 phu kin man hinh bat ke camera o dau. KHONG BAO GIO
	# bat follow_viewport cho lop overlay toan man hinh.
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 1
	add_child(_overlay_layer)
	_daynight = ColorRect.new()
	_daynight.position = Vector2.ZERO
	_daynight.size = Vector2(720, 1280)
	_daynight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_daynight.color = _daynight_color(frame_idx)
	# Che do NHAN: toi ca anh nhung giu tuong phan (xem _daynight_color).
	var mul := CanvasItemMaterial.new()
	mul.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	_daynight.material = mul
	_overlay_layer.add_child(_daynight)
	# Lop nhan: CanvasLayer rieng, layer 1, tao TRUOC lop HUD nen ve
	# duoi HUD — nhan luon tren nhan vat + nha (Node2D the gioi o
	# layer 0), khong bi y-sort che mat nua, khong de len panel dien
	# thoai / hop thoai (lop HUD ve sau, tren cung).
	_label_layer = CanvasLayer.new()
	_label_layer.layer = 1
	add_child(_label_layer)
	var layer := CanvasLayer.new()
	_ui_layer = layer
	layer.layer = 1
	add_child(layer)
	# HUD GON 4 dong (panel cao thuc te ~157px do min-size cua noi
	# dung, day panel y ~173 — dat size 124px nhung PanelContainer
	# tu no ra min-size) thay vi 5 dong 236px — HUD cu chiem het dai
	# troi tren cung nen troi khong bao gio thay duoc luc spawn
	# (loi 20/11 12:30). Gop: tui vao dong ngay, vi+EXP vao dong
	# rieng; dong tui rieng (_hud_bag) an di.
	var hud_panel := PanelContainer.new()
	hud_panel.position = Vector2(16, 16)
	hud_panel.size = Vector2(452, 124)
	hud_panel.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.97, 0.88, 0.94)))
	layer.add_child(hud_panel)
	var hvb := VBoxContainer.new()
	hvb.add_theme_constant_override("separation", 2)
	hud_panel.add_child(hvb)
	_hud_map = _mk_label(hvb, font_bold, 30, Vector2.ZERO, "Phố Xô Bồ")
	_hud_day = _mk_label(hvb, font, 24, Vector2.ZERO, "")
	_hud_bag = _mk_label(hvb, font, 24, Vector2.ZERO, "")
	_hud_bag.visible = false
	_hud_gold = _mk_label(hvb, font, 24, Vector2.ZERO, "")
	_hud_stats = _mk_label(hvb, font, 24, Vector2.ZERO, "")
	var frame_btn := Button.new()
	frame_btn.text = "Đổi khung (F)"
	_style_button(frame_btn)
	frame_btn.position = Vector2(720 - 224, 24)
	frame_btn.size = Vector2(200, 56)
	frame_btn.pressed.connect(func() -> void: _frame_timer = 0.0; _advance_frame())
	layer.add_child(frame_btn)
	var jobs_btn := Button.new()
	jobs_btn.text = "Việc làm"
	_style_button(jobs_btn)
	jobs_btn.position = Vector2(720 - 224, 88)
	jobs_btn.size = Vector2(200, 56)
	jobs_btn.pressed.connect(_show_jobs_dialogue)
	layer.add_child(jobs_btn)
	_phone_btn = Button.new()
	_phone_btn.text = "Điện thoại (P)"
	_style_button(_phone_btn)
	_phone_btn.position = Vector2(720 - 224, 152)
	_phone_btn.size = Vector2(200, 56)
	_phone_btn.pressed.connect(_toggle_phone)
	layer.add_child(_phone_btn)
	# Panel dien thoai: KHUNG RIENG 640x1100 (khong full man hinh),
	# tren lop mo toi — map khong xuyen qua, khong con ~60% dien
	# tich trong o duoi (loi 20/11 10:30).
	_phone_dim = ColorRect.new()
	_phone_dim.position = Vector2(0, 0)
	_phone_dim.size = Vector2(720, 1280)
	_phone_dim.color = Color(0, 0, 0, 0.55)
	_phone_dim.visible = false
	layer.add_child(_phone_dim)
	_phone_panel = PanelContainer.new()
	# Panel dien thoai GON (680x900, can giua doc) thay vi 680x1100
	# — noi dung that chi ~720px, panel cu thua ~450px trong
	# (art pass Nadia 20/11, loi goc 20/11 10:30).
	# y=216: duoi day nut "Dien thoai (P)" (nut o y 152-208) + 8px
	# cach — y=190 cu de len nua duoi nut (kiem live 13:53). Panel
	# cu o y=156 de len day HUD (loi 20/11 12:30, do min-size day
	# panel len 157px thay vi 124px dat truoc).
	_phone_panel.position = Vector2(20, 216)
	_phone_panel.size = Vector2(680, 900)
	_phone_panel.add_theme_stylebox_override("panel", _phone_panel_style())
	_phone_panel.visible = false
	layer.add_child(_phone_panel)
	# Khung dien thoai that: notch tren + thanh home duoi (chi hien
	# khi mo dien thoai) — thay cho hinh chu nhat tron tron.
	# y=216 (khong phai 190): mep tren panel cu cat ngang nut
	# "Dien thoai (P)" cua HUD (nut o y 152-208, chi thay nua duoi
	# — kiem live 13:53). Notch o 209 (ngay tren panel), homebar o
	# 1104 (day panel 1116 tru 12).
	_phone_notch = _mk_phone_bar(Vector2(300, 209), Vector2(120, 14))
	layer.add_child(_phone_notch)
	_phone_homebar = _mk_phone_bar(Vector2(290, 1104), Vector2(140, 10))
	layer.add_child(_phone_homebar)
	var pvb := VBoxContainer.new()
	# Separation 8 (khong phai 10): tong chieu cao toi thieu cua VBox
	# (tieu de 36 + luoi tab 172 + 2 scroll 200/240 + hom nay 60 +
	# goi y/meo 57/57 + chan trang 27 + khoang cach) phai <= 896 de
	# panel giu dung 680x900 — separation 10 day panel len 907
	# (loi 20/11 12:00).
	pvb.add_theme_constant_override("separation", 8)
	_phone_panel.add_child(pvb)
	_phone_title = _mk_label(pvb, font_bold, 30, Vector2.ZERO, "Điện thoại")
	var tab_grid := GridContainer.new()
	tab_grid.columns = 3
	tab_grid.add_theme_constant_override("h_separation", 8)
	tab_grid.add_theme_constant_override("v_separation", 8)
	pvb.add_child(tab_grid)
	for t in PxbPhoneHub.tab_list():
		var tb := Button.new()
		tb.text = String(t["name"])
		_style_button(tb, 22)
		tb.custom_minimum_size = Vector2(190, 52)
		tb.pressed.connect(_on_phone_tab_pressed.bind(String(t["id"])))
		tab_grid.add_child(tb)
		_phone_tab_buttons[String(t["id"])] = tb
	_phone_content = _mk_label(pvb, font, 26, Vector2.ZERO, "")
	_phone_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_content.size = Vector2(580, 200)
	# Chieu rong toi thieu 580: Label trong ScrollContainer mac dinh
	# bi ep ve chieu rong toi thieu 1px (autowrap) nen chu xep doc
	# 1 ky tu/dong (loi 20/11 12:10) — dat min width = be rong scroll.
	_phone_content.custom_minimum_size = Vector2(580, 0)
	# Noi dung dai (vd danh ba 16 NPC) phai CUON, khong tran khoi
	# panel: label trong ScrollContainer, chieu cao tu noi dung.
	# Cao 238px (khong phai 224): 7 dong x ~34px — hien tron dong
	# cuoi "Anh Ba" o vi tri cuon mac dinh (224px cat doi dong thu
	# 7, kiem live 14:34: dong cuoi bi cat nua + nut "Tro chuyen"
	# o ngay duoi trong nhu de len no). Bu lai bang actions scroll
	# 216 -> 192 de tong chieu cao VBox khong doi.
	var content_scroll := ScrollContainer.new()
	_phone_content_scroll = content_scroll
	content_scroll.custom_minimum_size = Vector2(580, 238)
	pvb.add_child(content_scroll)
	_phone_content.get_parent().remove_child(_phone_content)
	content_scroll.add_child(_phone_content)
	_phone_act_scroll = ScrollContainer.new()
	_phone_act_scroll.custom_minimum_size = Vector2(580, 192)
	pvb.add_child(_phone_act_scroll)
	_phone_actions = VBoxContainer.new()
	_phone_actions.add_theme_constant_override("separation", 8)
	_phone_act_scroll.add_child(_phone_actions)
	# Khoi "Hom nay" — noi dung that lap khoang trong giua nut bam
	# va khoi Tien trinh (loi 20/11 12:30: khoang trong 140-180px).
	_phone_today = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_today.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_today.size = Vector2(580, 60)
	# KHONG dung spacer day goi y + chan trang xuong day panel nua:
	# spacer chinh la khoang trong 140-180px giua nut "Dong dien
	# thoai" va khoi Tien trinh (loi 20/11 12:30). Bo spacer di, goi y
	# + chan trang noi ngay sau noi dung; phan trong (neu co) nam o
	# DAY panel — nhu man hinh dien thoai that, khong phai giua chung.
	_phone_hint = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_hint.size = Vector2(580, 90)
	_phone_tip = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_phone_tip.size = Vector2(580, 60)
	# Chan trang dien thoai: ngay + vi + danh vong + chuong — lap
	# phan trong o duoi panel (loi 20/11 10:30).
	_phone_footer = _mk_label(pvb, font, 22, Vector2.ZERO, "")
	_phone_footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Toast doi khung o GOC DUOI-TRAI (24,1216), chu nho 24: y=720
	# cu che cua/cua so giua man hinh vai giay sau khi bam F
	# (kiem live 13:53); goc duoi khong de mat troi/trang, nhan
	# cua ra da kep toi da y=1200 nen toast o 1216 khong chong
	# nhan nao (kiem live 14:34 yeu cau doi xuong goc duoi).
	_toast = _mk_label(layer, font_bold, 24, Vector2(24, 1216), "")
	_toast.size = Vector2(440, 40)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.95))
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.visible = false
	_dlg_panel = PanelContainer.new()
	_dlg_panel.position = Vector2(40, 1280 - 330)
	_dlg_panel.size = Vector2(640, 300)
	_dlg_panel.add_theme_stylebox_override("panel", _panel_style(Color(1.0, 0.97, 0.88, 1.0)))
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
	# Man hinh title: tieu de + nut Bat dau (mo san khi vao game).
	_title_panel = PanelContainer.new()
	_title_panel.position = Vector2(0, 0)
	_title_panel.size = Vector2(720, 1280)
	_title_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.99, 0.93, 0.78, 0.55)))
	layer.add_child(_title_panel)
	# Anh nen title (crop giua anh mat tien): len tren panel, duoi chu.
	if ResourceLoader.exists("res://art/title_bg.png"):
		var tbg := TextureRect.new()
		tbg.texture = load("res://art/title_bg.png")
		tbg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tbg.stretch_mode = TextureRect.STRETCH_SCALE
		_title_panel.add_child(tbg)
	var tvb := VBoxContainer.new()
	tvb.add_theme_constant_override("separation", 18)
	tvb.alignment = BoxContainer.ALIGNMENT_CENTER
	_title_panel.add_child(tvb)
	var title := _mk_label(tvb, font_bold, 72, Vector2.ZERO, "PHỐ XÔ BỒ")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub := _mk_label(tvb, font, 30, Vector2.ZERO, "Game xã hội 2.5D Việt Nam")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub2 := _mk_label(tvb, font, 26, Vector2.ZERO, "18 khu phố • Làm việc • Buôn bán • Kết bạn")
	sub2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var start_btn := Button.new()
	start_btn.text = "▶  Bắt đầu chơi"
	_style_button(start_btn, 40)
	# Nut LON (620x110) de bam tren desktop + mobile; tren web con
	# co nut DOM that ngoai canvas (web_shell.html, __pxb_start).
	start_btn.custom_minimum_size = Vector2(620, 110)
	start_btn.pressed.connect(_on_start_pressed)
	var center := CenterContainer.new()
	center.add_child(start_btn)
	tvb.add_child(center)
	var hint := _mk_label(tvb, font, 22, Vector2.ZERO,
		"Di chuyển: WASD / mũi tên / chạm\nE: tương tác • P: điện thoại • F: đổi khung • B: đấu trận chợ (demo)\nGame dọc — chơi trên điện thoại là đẹp nhất")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _on_start_pressed() -> void:
	title_open = false
	_title_panel.visible = false
	if player != null:
		player.input_blocked = false

func _mk_phone_bar(pos: Vector2, size: Vector2) -> Panel:
	# Thanh notch / home cua khung dien thoai: hinh chu nhat bo tron,
	# mau nau dam — giong vien dien thoai that.
	var p := Panel.new()
	p.position = pos
	p.size = size
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.15, 0.10, 0.06, 1)
	st.corner_radius_top_left = 7
	st.corner_radius_top_right = 7
	st.corner_radius_bottom_left = 7
	st.corner_radius_bottom_right = 7
	p.add_theme_stylebox_override("panel", st)
	p.visible = false
	return p

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
	var parts: Array[String] = []
	for k in inventory.keys():
		if int(inventory[k]) > 0:
			parts.append("%s ×%d" % [String(MATERIAL_NAMES.get(k, k)), int(inventory[k])])
	# HUD gon 4 dong: tui gop vao dong ngay (chi dem so loai de khong
	# tran panel 452px); dong tui rieng (_hud_bag) da an trong _build_ui.
	_hud_day.text = "Ngày %d • Khung %s • Túi: %s" % [day, _frame_name(),
		("%d loại" % parts.size()) if not parts.is_empty() else "trống"]
	_hud_gold.text = "Ví: %sđ • EXP %d" % [_fmt_vnd(jobs.gold), jobs.exp_total]
	_hud_stats.text = "Thể %d • Trí %d • Tâm %d" % [stats.the, stats.tri, stats.tam]
	var unread := phonehub.total_unread() if phonehub != null else 0
	_phone_btn.text = ("Điện thoại (%d)" % unread) if unread > 0 else "Điện thoại (P)"

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
		_style_button(b, 28)
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
