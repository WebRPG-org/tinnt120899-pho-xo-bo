extends SceneTree
## G4 vong 36 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r36_npc_walk_map014_test.gd
## Kiem tra walk cycle NPC Map014 Dao Thuong Luu (§56.5 muc 1):
##  1. Du 6 frame walk_<npc>_f0..f5 cho Quan Gia Dao + Chu Biet Thu Dao
##     (quan-gia-dao / chu-biet-thu-dao) -> frame_count 6,
##     di chuyen doi khung, dung yen ve frame 0.
##  2. Marker: home_tile = o event (Quan Gia Dao (3,3),
##     Chu Biet Thu Dao (8,6)); has_walk_frames true; patrol walk_to
##     0.30s/o.
##  3. Main.load_map(14): 2 marker NPC co walk frames, scene
##     chay 60 frame khong loi, pick patrol tu nha hop le.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null

const NPC_IDS := ["quan-gia-dao", "chu-biet-thu-dao"]
const NPC_TEX := {
	"quan-gia-dao": "res://art/char_quangiadao.png",
	"chu-biet-thu-dao": "res://art/char_chubietthudao.png",
}
const NPC_HOME := {
	"quan-gia-dao": Vector2i(3, 3),
	"chu-biet-thu-dao": Vector2i(8, 6),
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
		print("G4 R36 NPC WALK MAP014 TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# 1. Sprite truc tiep tung NPC Map014.
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
			# 3. Map014 that trong Main.
			_main._on_start_pressed()
			_main.load_map(14, Vector2i(5, 5))
			var tg = _npc_marker("quan-gia-dao")
			var sv = _npc_marker("chu-biet-thu-dao")
			_check("Map014: co marker Quan Gia Dao", tg != null)
			_check("Map014: co marker Chu Biet Thu Dao", sv != null)
			if tg != null:
				_check("Map014: Quan Gia Dao co walk frames", tg.has_walk_frames())
				_check("Map014: Quan Gia Dao o nha (3,3)", tg.home_tile == Vector2i(3, 3), str(tg.home_tile))
			if sv != null:
				_check("Map014: Chu Biet Thu Dao co walk frames", sv.has_walk_frames())
				_check("Map014: Chu Biet Thu Dao o nha (8,6)", sv.home_tile == Vector2i(8, 6), str(sv.home_tile))
			# Pick patrol tu nha Quan Gia Dao chi tra o ke hop le.
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
			_check("Map014: pick patrol tu nha Quan Gia Dao hop le", pick_ok)
			_state = 2
		2:
			if _frame >= 90:
				print("G4 R36 NPC WALK MAP014 TEST: %d/%d PASS" % [_pass, _pass + _fail])
				quit(0 if _fail == 0 else 1)
