extends SceneTree
## G4 vong 18 test — chay headless:
##   godot --headless --path src/godot -s res://tests/g4_r18_walkcycle_test.gd
## Kiem tra walk cycle 6 khung nguoi choi (Claude uu tien 2, §35.6):
##  1. Du 6 frame walk_player_f0..f5 nap duoc -> frame_count 6.
##  2. Di chuyen doi khung theo nhip 0.05s/frame (6 frame / 0.30s
##     = 2 o tile / chu trinh, 3 frame / o); dung yen ve frame 0.
##  3. Thieu file frame -> fallback anh don char_player.png,
##     khong crash (clone moi chua co art nhi phan van chay).
##  4. NPC (khong co frames) khong doi hanh vi.
##  5. Player trong Main noi frames khi art co mat.

var _pass := 0
var _fail := 0
var _frame := 0
var _state := 0
var _main: Node = null
var _art_ok := false

const WALK_FRAMES := [
	"res://art/walk_player_f0.png",
	"res://art/walk_player_f1.png",
	"res://art/walk_player_f2.png",
	"res://art/walk_player_f3.png",
	"res://art/walk_player_f4.png",
	"res://art/walk_player_f5.png",
]

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
		print("G4 R18 WALKCYCLE TEST: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_art_ok = true
				for p in WALK_FRAMES:
					if not ResourceLoader.exists(p):
						_art_ok = false
				# 1-2. Sprite truc tiep, co frames (khong vao cay
				# nen engine khong goi _process — goi tay de xac
				# dinh tung buoc).
				var s := CharacterSprite.new()
				s.setup({"texture": "res://art/char_player.png", "frames": WALK_FRAMES, "player": true})
				if _art_ok:
					_check("du 6 frame walk cycle", s.frame_count() == 6, str(s.frame_count()))
					_check("has_frames true", s.has_frames())
					_check("dung yen: frame 0", s.current_frame() == 0)
					s.moving = true
					s._process(0.05)
					_check("buoc 1: frame 1", s.current_frame() == 1, str(s.current_frame()))
					s._process(0.05)
					_check("buoc 2: frame 2", s.current_frame() == 2, str(s.current_frame()))
					s._process(0.05)
					_check("buoc 3: frame 3 + texture f3",
						s.current_frame() == 3 and s._tex.texture.resource_path.ends_with("walk_player_f3.png"),
						"" if s._tex == null else s._tex.texture.resource_path)
					s._process(0.05)
					s._process(0.05)
					_check("buoc 5: frame 5", s.current_frame() == 5, str(s.current_frame()))
					s._process(0.05)
					_check("het 0.30s: quay ve frame 0", s.current_frame() == 0, str(s.current_frame()))
					s.moving = false
					s._process(0.05)
					_check("dung yen tro lai: frame 0", s.current_frame() == 0)
				else:
					print("  NOTE art walk chua co — kiem tra fallback thay vi cycle")
					_check("thieu frame: has_frames false", not s.has_frames())
					_check("thieu frame: frame_count 0", s.frame_count() == 0)
					_check("thieu frame: van anh don char_player",
						s._tex != null and s._tex.texture.resource_path.ends_with("char_player.png"),
						"" if s._tex == null else s._tex.texture.resource_path)
					s.moving = true
					s._process(0.05)
					_check("thieu frame: di chuyen khong crash, frame 0", s.current_frame() == 0)
				# 3. Frames tro toi file khong ton tai -> fallback.
				var s2 := CharacterSprite.new()
				s2.setup({"texture": "res://art/char_player.png",
					"frames": ["res://art/nope_f0.png", "res://art/nope_f1.png"], "player": true})
				_check("frames rac: has_frames false", not s2.has_frames())
				_check("frames rac: van anh don", s2._tex != null and s2._tex.texture.resource_path.ends_with("char_player.png"))
				# 4. NPC: khong co frames.
				var s3 := CharacterSprite.new()
				s3.setup({"texture": "res://art/char_cotu.png", "hair_style": "bui"})
				_check("NPC: has_frames false", not s3.has_frames())
				s3.moving = true
				s3._process(0.05)
				_check("NPC: di chuyen khong crash", s3.current_frame() == 0)
				_state = 1
		1:
			# 5. Player trong Main noi frames khi art co mat.
			var pl = _main.player
			_check("Main co player", pl != null)
			if pl != null and pl._sprite != null:
				if _art_ok:
					_check("player: has_frames true", pl._sprite.has_frames())
					_check("player: du 6 frame", pl._sprite.frame_count() == 6, str(pl._sprite.frame_count()))
				else:
					_check("player (chua co art): fallback anh don",
						not pl._sprite.has_frames() and pl._sprite._tex.texture.resource_path.ends_with("char_player.png"))
			else:
				_check("player co sprite", false)
			print("G4 R18 WALKCYCLE TEST: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
