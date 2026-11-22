extends SceneTree
## G4 vong 22 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r22_npc_walk_test.gd
## Kiem tra walk cycle NPC + patrol (Claude uu tien 1, §43.3):
##  1. Du 6 frame walk_<npc>_f0..f5 cho ca 4 NPC Map001-002
##     (co-tu / ban-than / chi-le / anh-hai) -> frame_count 6,
##     di chuyen doi khung, dung yen ve frame 0.
##  2. Thieu frame -> fallback anh don, khong crash.
##  3. Marker patrol: home_tile = o event; walk_to buoc 0.30s/o,
##     doi o logic khi tween xong; lenh chen / cung o bi tu choi.
##  4. Main._npc_patrol_pick: chi tra o ke ben, di duoc, khong
##     event, khong phai o nguoi choi / NPC khac.
##  5. Main._update_npc_patrol: nguoi choi xa (>5 o) thi NPC buoc
##     ra; nguoi choi lai gan (<=5 o) hoac mo hoi thoai thi NPC
##     ve nha — tuong tac E luon gap NPC dung o nha (event_at
##     dung data tinh theo o nha, xem iso_map.gd).

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null
var _art_ok := false
var _cotu = null  # Marker Co Tu trong Main.
var _wait_frames := 0

const NPC_IDS := ["co-tu", "ban-than", "chi-le", "anh-hai"]
const NPC_TEX := {
	"co-tu": "res://art/char_cotu.png",
	"ban-than": "res://art/char_banthan.png",
	"chi-le": "res://art/char_chile.png",
	"anh-hai": "res://art/char_anhhai.png",
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
		print("G4 R22 NPC WALK TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_art_ok = true
				for nid in NPC_IDS:
					for p in _frames_for(nid):
						if not ResourceLoader.exists(p):
							_art_ok = false
				if not _art_ok:
					print("  NOTE art walk NPC chua du — kiem tra fallback thay vi cycle")
				# 1-2. Sprite truc tiep tung NPC.
				for nid in NPC_IDS:
					var s := CharacterSprite.new()
					s.setup({"texture": NPC_TEX[nid], "frames": _frames_for(nid)})
					if _art_ok:
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
					else:
						_check(nid + ": thieu frame -> has_frames false", not s.has_frames())
						_check(nid + ": thieu frame -> frame_count 0", s.frame_count() == 0)
						s.moving = true
						s._process(0.05)
						_check(nid + ": thieu frame -> di khong crash", s.current_frame() == 0)
				# 3. Marker patrol don le (khong vao tree: _process
				# goi tay de xac dinh; tat _process tu dong tranh
				# nhan doi buoc).
				var mk := Marker.new()
				mk.event_data = {"kind": "npc", "id": "co-tu", "name": "Cô Tư", "tile": [8, 6]}
				root.add_child(mk)
				mk.set_process(false)
				_check("marker: home_tile (8,6)", mk.home_tile == Vector2i(8, 6), str(mk.home_tile))
				_check("marker: patrol_tile ban dau = home", mk.patrol_tile() == Vector2i(8, 6))
				if _art_ok:
					_check("marker Co Tu: co walk frames", mk.has_walk_frames())
				var ok := mk.patrol_walk_to(Vector2i(9, 6), Vector2(200, 100))
				_check("marker: walk_to chap nhan", ok)
				_check("marker: dang buoc", mk.patrol_moving())
				_check("marker: lenh chen bi tu choi", not mk.patrol_walk_to(Vector2i(7, 6), Vector2(0, 0)))
				_check("marker: o logic chua doi giua duong", mk.patrol_tile() == Vector2i(8, 6))
				mk._process(0.15)
				_check("marker: nua duong van buoc", mk.patrol_moving())
				mk._process(0.15)
				_check("marker: het 0.30s het buoc", not mk.patrol_moving())
				_check("marker: o logic doi (9,6)", mk.patrol_tile() == Vector2i(9, 6), str(mk.patrol_tile()))
				_check("marker: sprite dung yen sau buoc", mk._sprite != null and not mk._sprite.moving)
				_check("marker: walk_to cung o bi tu choi", not mk.patrol_walk_to(Vector2i(9, 6), Vector2(200, 100)))
				mk.patrol_walk_to(Vector2i(8, 6), Vector2(100, 50))
				mk._process(0.30)
				_check("marker: ve nha (8,6)", mk.patrol_tile() == Vector2i(8, 6))
				mk.queue_free()
				_state = 1
		1:
			# 4. Pick chi tra o hop le (Co Tu (8,6): 4 o ke deu trong).
			var home := Vector2i(8, 6)
			var pick_ok := true
			var picked := {}
			for i in range(20):
				var t: Vector2i = _main._npc_patrol_pick(home)
				if t.x < -100:
					pick_ok = false
					break
				picked[t] = true
				if _main.iso_map == null or not _main.iso_map.is_walkable(t):
					pick_ok = false
				if not _main.iso_map.event_at(t).is_empty():
					pick_ok = false
				if t == _main.player.tile:
					pick_ok = false
				var d: int = absi(t.x - home.x) + absi(t.y - home.y)
				if d != 1:
					pick_ok = false
			_check("pick: 20 lan deu o ke hop le", pick_ok)
			_check("pick: co nhieu hon 1 o dich (ngau nhien)", picked.size() > 1, str(picked.keys()))
			# 5a. Nguoi choi xa -> NPC buoc ra. Title dang mo luc
			# khoi dong (title_open=true) nen patrol bi chan theo
			# thiet ke — tat title nhu da bam Bat dau.
			_main.title_open = false
			_cotu = _npc_marker("co-tu")
			_check("Main co marker Co Tu", _cotu != null)
			if _cotu != null and _art_ok:
				_check("Main Co Tu: co walk frames", _cotu.has_walk_frames())
			_main.player.place(_main.iso_map, Vector2i(1, 1))
			if _cotu != null:
				_main._npc_patrol_wait[_cotu.get_instance_id()] = 0.0
			_wait_frames = 0
			_state = 2
		2:
			# Goi truc tiep moi frame (0.6s tich luy -> quyet dinh
			# ngay, khong cho delta thuc cua Main._process).
			_main._update_npc_patrol(0.6)
			_wait_frames += 1
			if _cotu != null and (_cotu.patrol_moving() or _cotu.patrol_tile() != Vector2i(8, 6)):
				_check("patrol: nguoi choi xa -> Co Tu buoc ra", true)
				_state = 3
				_wait_frames = 0
			elif _wait_frames > 30:
				_check("patrol: nguoi choi xa -> Co Tu buoc ra", false, "timeout 30 frame")
				_state = 6
		3:
			# Doi tween xong (0.30s): day nhanh bang _process tay
			# (delta thuc headless rat nho, cho that co the qua
			# 120 frame) — tree cung goi _process nen chi nhanh hon.
			if _cotu != null and _cotu.patrol_moving():
				_cotu._process(0.35)
			_wait_frames += 1
			if _cotu != null and not _cotu.patrol_moving() and _cotu.patrol_tile() != Vector2i(8, 6):
				_check("patrol: Co Tu dung o ngoai, khong phai nha", true, str(_cotu.patrol_tile()))
				_state = 4
				_wait_frames = 0
			elif _wait_frames > 120:
				_check("patrol: Co Tu dung o ngoai", false, "timeout 120 frame")
				_state = 6
		4:
			# 5b. Nguoi choi lai gan (spawn (4,5), cach nha 5 o)
			# -> NPC ve nha.
			_main.player.place(_main.iso_map, Vector2i(4, 5))
			_main._update_npc_patrol(0.6)
			if _cotu != null and _cotu.patrol_moving():
				_cotu._process(0.35)
			_wait_frames += 1
			if _cotu != null and _cotu.patrol_tile() == Vector2i(8, 6) and not _cotu.patrol_moving():
				_check("patrol: nguoi choi gan -> Co Tu ve nha", true)
				_state = 5
				_wait_frames = 0
			elif _wait_frames > 120:
				_check("patrol: nguoi choi gan -> Co Tu ve nha", false,
					"tile=" + str(_cotu.patrol_tile()) + " moving=" + str(_cotu.patrol_moving()))
				_state = 6
		5:
			# 5c. Mo hoi thoai khi NPC o ngoai -> NPC ve nha.
			_main.player.place(_main.iso_map, Vector2i(1, 1))
			_main._npc_patrol_wait[_cotu.get_instance_id()] = 0.0
			_main._update_npc_patrol(0.6)
			if _cotu != null and _cotu.patrol_moving():
				_cotu._process(0.35)
			_wait_frames += 1
			if _cotu != null and _cotu.patrol_tile() != Vector2i(8, 6) and not _cotu.patrol_moving():
				_main.dialogue_open = true
				_main._update_npc_patrol(0.6)
				_check("patrol: mo hoi thoai -> lenh ve nha", _cotu.patrol_moving() or _cotu.patrol_tile() == Vector2i(8, 6))
				_main.dialogue_open = false
				_state = 6
				_wait_frames = 0
			elif _wait_frames > 120:
				_check("patrol: mo hoi thoai -> NPC ra ngoai truoc", false, "timeout")
				_state = 6
		6:
			print("G4 R22 NPC WALK TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
