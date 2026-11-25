extends SceneTree
## G4 vong 36 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r37_npc_walk_map015_test.gd
## Kiem tra walk cycle NPC Map015 Khu Penthouse (§56.5 muc 1):
##  1. Du 6 frame walk_<npc>_f0..f5 cho Quan Ly Penthouse + Cu Dan Penthouse
##     (quan-ly-penthouse / cu-dan-penthouse) -> frame_count 6,
##     di chuyen doi khung, dung yen ve frame 0.
##  2. Marker: home_tile = o event (Quan Ly Penthouse (3,3),
##     Cu Dan Penthouse (8,6)); has_walk_frames true; patrol walk_to
##     0.30s/o.
##  3. Main.load_map(15): 2 marker NPC co walk frames, scene
##     chay 60 frame khong loi, pick patrol tu nha hop le.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null

const NPC_IDS := ["quan-ly-penthouse", "cu-dan-penthouse"]
const NPC_TEX := {
	"quan-ly-penthouse": "res://art/char_quangiadao.png",
	"cu-dan-penthouse": "res://art/char_chubietthudao.png",
}
const NPC_HOME := {
	"quan-ly-penthouse": Vector2i(3, 3),
	"cu-dan-penthouse": Vector2i(8, 6),
}

func _frames_for(npc_id: String) -> Array:
	var out: Array = []
	for i in range(6):
		out.append("res://art/walk_" + npc_id.replace("-", "") + "_f%d.png" % i)
	return out

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

func _npc_marker(npc_id: String):
	for mk in _main.iso_map.markers:
		if String(mk.event_data.get("kind", "")) == "npc" and String(mk.event_data.get("id", "")) == npc_id:
			return mk
	return null

func _on_frame() -> void:
	_frame += 1
	if _frame > 1200:
		print("G4 R37 NPC WALK MAP015 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Sprite truc tiep tung NPC Map015.
				for nid in NPC_IDS:
					_check(nid + ": texture ton tai", ResourceLoader.exists(NPC_TEX[nid]))
					var all_frames := true
					for p in _frames_for(nid):
						if not ResourceLoader.exists(p):
							all_frames = false
					_check(nid + ": du 6 frame file", all_frames)
					var s := CharacterSprite.new()
					s.setup({"texture": NPC_TEX[nid], "frames": _frames_for(nid)})
					_check(nid + ": du 6 frame", s.frame_count() == 6, str(s.frame_count()))
					_check(nid + ": has_frames true", s.has_frames())
					s.moving = true
					s._process(0.05)
					_check(nid + ": buoc 1 doi frame 1", s.current_frame() == 1, str(s.current_frame()))
					s._process(0.25)
					_check(nid + ": het 0.30s quay ve frame 0", s.current_frame() == 0, str(s.current_frame()))
					s.moving = false
					s._process(0.05)
					_check(nid + ": dung yen frame 0", s.current_frame() == 0)
				# 2. Marker don le (khong vao tree _process tu dong).
				for nid in NPC_IDS:
					var mk := Marker.new()
					mk.event_data = {"kind": "npc", "id": nid, "name": nid, "tile": [int(NPC_HOME[nid].x), int(NPC_HOME[nid].y)]}
					root.add_child(mk)
					mk.set_process(false)
					_check("marker " + nid + ": home_tile " + str(NPC_HOME[nid]), mk.home_tile == NPC_HOME[nid], str(mk.home_tile))
					_check("marker " + nid + ": co walk frames", mk.has_walk_frames())
					var ok := mk.patrol_walk_to(Vector2i(int(NPC_HOME[nid].x) + 1, int(NPC_HOME[nid].y)), Vector2(200, 100))
					_check("marker " + nid + ": walk_to chap nhan", ok)
					mk._process(0.30)
					_check("marker " + nid + ": het 0.30s het buoc", not mk.patrol_moving())
					mk.queue_free()
				_state = 1
		1:
			# 3. Map015 that trong Main.
			_main._on_start_pressed()
			_main.load_map(15, Vector2i(5, 5))
			var tg = _npc_marker("quan-ly-penthouse")
			var sv = _npc_marker("cu-dan-penthouse")
			_check("Map015: co marker Quan Ly Penthouse", tg != null)
			_check("Map015: co marker Cu Dan Penthouse", sv != null)
			if tg != null:
				_check("Map015: Quan Ly Penthouse co walk frames", tg.has_walk_frames())
				_check("Map015: Quan Ly Penthouse o nha (3,3)", tg.home_tile == Vector2i(3, 3), str(tg.home_tile))
			if sv != null:
				_check("Map015: Cu Dan Penthouse co walk frames", sv.has_walk_frames())
				_check("Map015: Cu Dan Penthouse o nha (8,6)", sv.home_tile == Vector2i(8, 6), str(sv.home_tile))
			# Pick patrol tu nha Quan Ly Penthouse chi tra o ke hop le.
			var pick_ok := true
			for i in range(10):
				var t: Vector2i = _main._npc_patrol_pick(Vector2i(3, 3))
				if t.x < -100:
					pick_ok = false
					break
				if not _main.iso_map.is_walkable(t):
					pick_ok = false
				if not _main.iso_map.event_at(t).is_empty():
					pick_ok = false
				var d: int = absi(t.x - 3) + absi(t.y - 3)
				if d != 1:
					pick_ok = false
			_check("Map015: pick patrol tu nha Quan Ly Penthouse hop le", pick_ok)
			_state = 2
		2:
			if _frame >= 90:
				print("G4 R37 NPC WALK MAP015 TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
