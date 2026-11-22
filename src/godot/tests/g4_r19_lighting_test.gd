extends SceneTree
## G4 vong 19 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r19_lighting_test.gd
## Kiem tra anh sang + su song vong 19 (muc (3) Claude §35.6):
##  1. GlowCanvas: con cua _overlay_layer, BLEND_MODE_ADD, chi bat
##     khung Toi; halo theo dung vi tri den long/cua so cua NightGlow.
##  2. AmbientLife: 14 la roi cham + lap lai tu tren xuong; dom dom
##     chi hien khung Toi.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _frame_set := 0
var _main: Node = null

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 400:
		print("G4 R19 LIGHTING TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				var gc = _main._glow_canvas
				_check("GlowCanvas ton tai", gc != null)
				_check("GlowCanvas la con cua _overlay_layer",
					gc != null and gc.get_parent() == _main._overlay_layer)
				_check("GlowCanvas dung BLEND_MODE_ADD",
					gc != null and gc.material != null and gc.material.blend_mode == CanvasItemMaterial.BLEND_MODE_ADD)
				_check("khung Sang: glow tat", gc != null and not gc.lit and not gc.visible)
				var am = _main._ambient
				_check("AmbientLife ton tai", am != null)
				_check("AmbientLife: 14 la", am != null and am.leaf_count() == 14)
				_check("khung Sang: dom dom an", am != null and not am.fly_visible)
				_check("AmbientLife z_index 10", am != null and am.z_index == 10)
				_main._on_start_pressed()
				_main._advance_frame()  # Sang -> Chieu.
				_state = 1
		1:
			# Frame sau _advance_frame: glow/ambient da doi theo khung.
			var gc1 = _main._glow_canvas
			_check("khung Chieu: glow van tat", gc1 != null and not gc1.lit)
			_check("khung Chieu: dom dom van an", _main._ambient != null and not _main._ambient.fly_visible)
			_main._advance_frame()  # Chieu -> Toi.
			_state = 2
		2:
			if _frame < 30:
				return
			var gc2 = _main._glow_canvas
			_check("khung Toi: glow bat", gc2 != null and gc2.lit and gc2.visible)
			# Map001: 1 den long + 0 cua so (spots rong) = 1 nguon.
			_check("khung Toi: dung 1 nguon sang (den long Map001)",
				gc2 != null and gc2.sources.size() == 1, "" if gc2 == null else str(gc2.sources.size()))
			_check("khung Toi: 1 halo da ve",
				gc2 != null and gc2.halo_screen_positions.size() == 1, "" if gc2 == null else str(gc2.halo_screen_positions.size()))
			if gc2 != null and gc2.halo_screen_positions.size() == 1:
				var hp: Vector2 = gc2.halo_screen_positions[0]
				_check("halo nam trong man hinh (0..720, 0..1280)",
					hp.x >= 0.0 and hp.x <= 720.0 and hp.y >= 0.0 and hp.y <= 1280.0, str(hp))
			_check("khung Toi: dom dom hien", _main._ambient.fly_visible)
			# La roi xuong: do 1 la cu the (y < 1000, xa day — khong
			# bi lap lai lam nhieu trung binh), khong so trung binh
			# voi baseline cu (la cham day lap ve -30 lam trung
			# binh giam du la van roi — loi test lan dau).
			var li := -1
			for i in range(_main._ambient.leaf_positions.size()):
				if _main._ambient.leaf_positions[i].y < 1000.0:
					li = i
					break
			_check("tim duoc la xa day de do", li >= 0, str(li))
			var y0: float = _main._ambient.leaf_positions[li].y
			_main._ambient.sim_step(1.0)
			_check("la roi xuong sau 1s mo phong", _main._ambient.leaf_positions[li].y > y0,
				"truoc=%f sau=%f" % [y0, _main._ambient.leaf_positions[li].y])
			# La cham day thi lap lai tu tren.
			_main._ambient.leaf_positions[0] = Vector2(360.0, 1295.0)
			_main._ambient.sim_step(0.5)
			_check("la cham day lap lai tu tren (y < 100)",
				_main._ambient.leaf_positions[0].y < 100.0, str(_main._ambient.leaf_positions[0].y))
			# Nguon tong hop: set_sources truc tiep 2 diem -> 2 halo.
			# (Phai dung Array[Vector2] co kieu — literal [] khong
			# kieu bi tu choi o tham so typed, lam _state khong bao
			# gio sang 3 va test lap vo han o state 2.)
			var src: Array[Vector2] = [Vector2(100, 100), Vector2(200, 200)]
			_main._glow_canvas.set_sources(src)
			_frame_set = _frame
			_state = 3
		3:
			# Cho _draw chay (headless co the lech 1 frame sau
			# queue_redraw) roi moi doc halo moi.
			if _frame < _frame_set + 2:
				return
			_check("set_sources 2 diem -> 2 halo",
				_main._glow_canvas.halo_screen_positions.size() == 2,
				str(_main._glow_canvas.halo_screen_positions.size()))
			# Ve Sang: glow tat, dom dom an, la van roi.
			_main._advance_frame()
			_state = 4
		4:
			_check("ve Sang: glow tat", not _main._glow_canvas.lit and not _main._glow_canvas.visible)
			_check("ve Sang: dom dom an", not _main._ambient.fly_visible)
			_check("ve Sang: la van du 14", _main._ambient.leaf_count() == 14)
			print("G4 R19 LIGHTING TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
