extends SceneTree
## Vong 15 — Nhan NPC sang Label trong the gioi (Claude (b), 21/11):
##   (1) Nhan NPC la Label con cua Marker (khong tren CanvasLayer),
##       font 20 world, z_index 10, dung rect neo -170 tren dau.
##   (2) Chi hien khi nguoi choi o gan (Manhattan <= 5 o):
##       spawn Map001: Ban Than (1 o) + Co Tu (5 o) deu hien;
##       di xa thi an (Ban Than an o (11,8); Co Tu an o (11,1)).
##   (3) label_screen_rect() = rect man hinh that cua Label con:
##       nam dung tren dau NPC (khe ~50px), tam X trung chan NPC,
##       trong man hinh; resolver khong dat label_override cho NPC.
##   (4) Nhan hotspot/che tao/cua KHONG doi: van tren CanvasLayer.
##   (5) Map002: Chi Le (5 o) + Anh Hai (2 o) hien luc spawn,
##       nhan khong chong nhau (ca nhan NPC + nhan cua/hotspot).
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_r15_label_world_test.gd

var _frame := 0
var _state := 0
var _wait := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _mk(id: String) -> Marker:
	for mk in _main.iso_map.markers:
		if String(mk.event_data.get("id", "")) == id:
			return mk as Marker
	return null

func _mk_kind(kind: String) -> Marker:
	for mk in _main.iso_map.markers:
		if String(mk.event_data.get("kind", "")) == kind:
			return mk as Marker
	return null

func _feet_screen(mk: Marker) -> Vector2:
	return _main.get_viewport().get_canvas_transform() * mk.global_position

func _zoom() -> float:
	return _main.get_viewport().get_canvas_transform().get_scale().x

func _check_npc_label(id: String) -> void:
	var mk := _mk(id)
	_check("nhan %s ton tai" % id, mk != null)
	if mk == null:
		return
	_check("nhan %s la Label con cua Marker" % id, mk._label != null and mk._label.get_parent() == mk, str(mk._label))
	_check("nhan %s la nhan the gioi" % id, mk._label_world == true)
	_check("nhan %s khong tren lop CanvasLayer" % id, not (mk._label in _main._label_layer.get_children()))
	_check("nhan %s z_index 10 (tren the gioi)" % id, mk._label.z_index == 10, str(mk._label.z_index))
	_check("nhan %s font 20 world" % id, mk._label.get_theme_font_size("font_size") == 20, str(mk._label.get_theme_font_size("font_size")))
	var ar: Rect2 = mk._anchor_rect()
	_check("nhan %s dung rect neo" % id, mk._label.position == ar.position and mk._label.size == ar.size, "%s vs %s" % [str(mk._label.position), str(ar.position)])
	_check("nhan %s khong co label_override" % id, mk.label_override.size == Vector2.ZERO, str(mk.label_override))
	_check("nhan %s hien khi o gan" % id, mk._label.visible == true, str(mk._label.visible))
	var r: Rect2 = mk.label_screen_rect()
	_check("nhan %s co rect man hinh" % id, r.size != Vector2.ZERO, str(r))
	if r.size == Vector2.ZERO:
		return
	_check("nhan %s trong man hinh" % id,
		r.position.x >= 16.0 - 0.5 and r.end.x <= 720.0 - 16.0 + 0.5
		and r.position.y >= 190.0 - 0.5 and r.end.y <= 1200.0 + 0.5, str(r))
	# Tam X cua nhan trung chan NPC (neo co dinh, khong qua resolver).
	var feet := _feet_screen(mk)
	_check("nhan %s tam X trung chan NPC" % id, absf(r.get_center().x - feet.x) < 2.0,
		"nhan %.1f chan %.1f" % [r.get_center().x, feet.x])
	# Khe tren dau NPC: day nhan cach dinh dau (104 world) ~50px
	# man hinh (doan: 40 world * zoom 1.25).
	var head_top := feet.y - 104.0 * _zoom()
	var gap := head_top - r.end.y
	_check("nhan %s khe tren dau ~50px" % id, gap >= 40.0 and gap <= 60.0, "khe %.1f" % gap)

func _labels_overlap() -> String:
	var rects := {}
	for mk in _main.iso_map.markers:
		var r: Rect2 = mk.label_override if mk.label_override.size != Vector2.ZERO else mk.label_screen_rect()
		if r.size != Vector2.ZERO:
			rects[String(mk.event_data.get("name", ""))] = r
	var keys := rects.keys()
	for i in range(keys.size()):
		for j in range(i + 1, keys.size()):
			if (rects[keys[i]] as Rect2).intersects(rects[keys[j]] as Rect2):
				return "%s vs %s" % [keys[i], keys[j]]
	return ""

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 2000:
		print("G4 R15-LABEL-WORLD: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_main._on_start_pressed()
				_check("spawn (4,5)", _main.player.tile == Vector2i(4, 5), str(_main.player.tile))
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _wait >= 60:
				# Map001 spawn: Ban Than (3,5) cach 1 o, Co Tu (8,6)
				# cach 5 o (nguong) — ca 2 deu hien.
				_check_npc_label("ban-than")
				_check_npc_label("co-tu")
				# (4) Nhan hotspot/che tao/cua van tren CanvasLayer.
				var hs := _mk("hs-tro-toi")
				_check("nhan hotspot van tren CanvasLayer", hs != null and hs._label != null and hs._label.get_parent() == _main._label_layer and not hs._label_world)
				var cr := _mk_kind("craft")
				_check("nhan che tao van tren CanvasLayer", cr != null and cr._label != null and cr._label.get_parent() == _main._label_layer and not cr._label_world)
				var dr := _mk_kind("door")
				_check("nhan cua van tren CanvasLayer", dr != null and dr._label != null and dr._label.get_parent() == _main._label_layer and not dr._label_world)
				_check("Map001: nhan khong chong nhau", _labels_overlap() == "", _labels_overlap())
				# (2) Di xa: (11,8) cach Ban Than 11 o -> an.
				_main.player.place(_main.iso_map, Vector2i(11, 8))
				_wait = 0
				_state = 2
		2:
			_wait += 1
			if _wait >= 60:
				var bt := _mk("ban-than")
				_check("xa 11 o: nhan Ban Than AN", bt != null and bt._label.visible == false, str(bt._label.visible if bt != null else null))
				_check("xa 11 o: rect man hinh rong", bt != null and bt.label_screen_rect() == Rect2(), str(bt.label_screen_rect() if bt != null else null))
				var ct := _mk("co-tu")
				_check("cach 5 o: nhan Co Tu van hien", ct != null and ct._label.visible == true, str(ct._label.visible if ct != null else null))
				# (11,1) cach Co Tu 8 o -> an.
				_main.player.place(_main.iso_map, Vector2i(11, 1))
				_wait = 0
				_state = 3
		3:
			_wait += 1
			if _wait >= 60:
				var ct2 := _mk("co-tu")
				_check("xa 8 o: nhan Co Tu AN", ct2 != null and ct2._label.visible == false, str(ct2._label.visible if ct2 != null else null))
				_check("xa 8 o: rect man hinh rong", ct2 != null and ct2.label_screen_rect() == Rect2(), str(ct2.label_screen_rect() if ct2 != null else null))
				_main.load_map(2, Vector2i(5, 4))
				_wait = 0
				_state = 4
		4:
			_wait += 1
			if _wait >= 60:
				# Map002 spawn: Chi Le (2,2) cach 5 o, Anh Hai (6,3)
				# cach 2 o — ca 2 deu hien, sat tren dau (khe ~50px).
				_check_npc_label("chi-le")
				_check_npc_label("anh-hai")
				_check("Map002: nhan khong chong nhau", _labels_overlap() == "", _labels_overlap())
				_state = 5
		5:
			print("G4 R15-LABEL-WORLD: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
