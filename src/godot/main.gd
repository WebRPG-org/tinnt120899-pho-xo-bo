extends Node2D
## Main.gd — Dieu khien game G1 (slice parity Map001-002 voi ban MV).
##
## He thoi gian kieu C (da chot, TimeSystem.cs / PXB_Time.js): 1 ngay game =
## 30 phut that, 3 khung Sang/Chieu/Toi, moi khung 10 phut that, miss khung
## khong phat. Phim F (nut "Doi khung") doi khung ngay de test — chi de test.
## G2: khung + do dai khung lay tu PxbBalance / PxbTime (autoload PXB_Time),
## khong hardcode so trong file nay nua.
## Hotspot: nhan 1 lan/ngay game, chi co do dung khung (PXB_Hotspot.js).
## NPC: doi thoai lua chon [Hoi goi y / Tam biet] — goi y lay tu Actors.js.

const MATERIAL_NAMES := {
	"chai-nhua": "Chai Nhựa", "la-chuoi": "Lá Chuối", "sat-vun": "Sắt Vụn",
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
var inventory := {"chai-nhua": 0, "la-chuoi": 0, "sat-vun": 0}
var collected_today := {}
var dialogue_open := false

var _hud_map: Label
var _hud_day: Label
var _hud_bag: Label
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
	load_map(int(maps_data["start"]["map"]),
		Vector2i(int(maps_data["start"]["x"]), int(maps_data["start"]["y"])))

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
		collected_today.clear()
	_update_hud()
	show_toast("Ngày %d • Khung %s" % [day, PxbTime.frame_name(float(frame_idx) * float(PxbBalance.FRAME_MINUTES))])

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
			show_dialogue(String(ev["name"]), String(ev["greet"]), [
				["Hỏi gợi ý", func() -> void: show_dialogue(String(ev["name"]), String(ev["hint"]), [["Đóng", close_dialogue]])],
				["Tạm biệt", close_dialogue],
			])
		"hotspot":
			_collect_hotspot(ev)
		"craft":
			show_dialogue(String(ev["name"]),
				"Chế %s ở đây. Cần: %s. (Chế tạo đầy đủ sẽ có ở G2.)" % [String(ev["recipe"]), String(ev["needs"])],
				[["Đóng", close_dialogue]])
		"door":
			_transfer(int(ev["to_map"]))

func _collect_hotspot(ev: Dictionary) -> void:
	var hid := String(ev["id"])
	var want := String(ev["best_frame"])
	if collected_today.get(hid, false):
		show_toast("%s: đã nhặt hôm nay rồi." % String(ev["name"]))
		return
	if PxbBalance.FRAMES[frame_idx] != want:
		show_toast("%s: chỉ có đồ vào khung %s — giờ đang %s." % [String(ev["name"]), want, PxbBalance.FRAMES[frame_idx]])
		return
	var mat := String(ev["material"])
	inventory[mat] = int(inventory.get(mat, 0)) + int(ev["amount"])
	collected_today[hid] = true
	_update_hud()
	show_toast("Nhặt được %s ×%d!" % [String(MATERIAL_NAMES.get(mat, mat)), int(ev["amount"])])

# --- UI ---
func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_hud_map = _mk_label(layer, font_bold, 34, Vector2(24, 24), "Phố Xô Bồ")
	_hud_day = _mk_label(layer, font, 28, Vector2(24, 70), "")
	_hud_bag = _mk_label(layer, font, 28, Vector2(24, 108), "")
	var frame_btn := Button.new()
	frame_btn.text = "Đổi khung (F)"
	frame_btn.add_theme_font_size_override("font_size", 26)
	frame_btn.add_theme_font_override("font", font)
	frame_btn.position = Vector2(720 - 224, 24)
	frame_btn.size = Vector2(200, 56)
	frame_btn.pressed.connect(func() -> void: _frame_timer = 0.0; _advance_frame())
	layer.add_child(frame_btn)
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

func _update_hud() -> void:
	_hud_day.text = "Ngày %d • Khung %s" % [day, PxbTime.frame_name(float(frame_idx) * float(PxbBalance.FRAME_MINUTES))]
	var parts: Array[String] = []
	for k in inventory.keys():
		if int(inventory[k]) > 0:
			parts.append("%s ×%d" % [String(MATERIAL_NAMES.get(k, k)), int(inventory[k])])
	_hud_bag.text = "Túi: " + (" • ".join(parts) if not parts.is_empty() else "trống")

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
