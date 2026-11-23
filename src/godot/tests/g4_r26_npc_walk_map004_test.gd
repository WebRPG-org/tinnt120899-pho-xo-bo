extends SceneTree
## G4 vong 26 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r26_npc_walk_map004_test.gd
## Kiem tra walk cycle NPC Map004 Ben Xe Mien Dong (§47.5 muc 2):
##  1. Du 6 frame walk_<npc>_f0..f5 cho Bac Tai + Anh Boc Vac
##     (bac-tai / anh-boc-vac) -> frame_count 6, di chuyen doi khung,
##     dung yen ve frame 0.
##  2. Marker: home_tile = o event (Bac Tai (3,2), Anh Boc Vac
##     (8,6)); has_walk_frames true; patrol walk_to 0.30s/o.
##  3. Main.load_map(4): 2 marker NPC co walk frames, scene
##     chay 60 frame khong loi, pick patrol tu nha hop le.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null

const NPC_IDS := ["bac-tai", "anh-boc-vac"]
const NPC_TEX := {
	"bac-tai": "res://art/char_bactai.png",
	"anh-boc-vac": "res://art/char_anhbocvac.png",
}
const NPC_HOME := {
	"bac-tai": Vector2i(3, 2),
	"anh-boc-vac": Vector2i(8, 6),
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
		print("G4 R26 NPC WALK MAP004 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Sprite truc tiep tung NPC Map004.
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
			# 3. Map004 that trong Main.
			_main._on_start_pressed()
			_main.load_map(4, Vector2i(5, 5))
			var bt = _npc_marker("bac-tai")
			var bv = _npc_marker("anh-boc-vac")
			_check("Map004: co marker Bac Tai", bt != null)
			_check("Map004: co marker Anh Boc Vac", bv != null)
			if bt != null:
				_check("Map004: Bac Tai co walk frames", bt.has_walk_frames())
				_check("Map004: Bac Tai o nha (3,2)", bt.home_tile == Vector2i(3, 2), str(bt.home_tile))
			if bv != null:
				_check("Map004: Anh Boc Vac co walk frames", bv.has_walk_frames())
				_check("Map004: Anh Boc Vac o nha (8,6)", bv.home_tile == Vector2i(8, 6), str(bv.home_tile))
			# Pick patrol tu nha Bac Tai chi tra o ke hop le.
			var pick_ok := true
			for i in range(10):
				var t: Vector2i = _main._npc_patrol_pick(Vector2i(3, 2))
				if t.x < -100:
					pick_ok = false
					break
				if not _main.iso_map.is_walkable(t):
					pick_ok = false
				if not _main.iso_map.event_at(t).is_empty():
					pick_ok = false
				var d: int = absi(t.x - 3) + absi(t.y - 2)
				if d != 1:
					pick_ok = false
			_check("Map004: pick patrol tu nha Bac Tai hop le", pick_ok)
			_state = 2
		2:
			if _frame >= 90:
				print("G4 R26 NPC WALK MAP004 TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
