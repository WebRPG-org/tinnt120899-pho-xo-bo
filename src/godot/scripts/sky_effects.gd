class_name SkyEffects
extends Node2D
## SkyEffects — Mat troi + bong dai theo khung gio.
##
## Ve tren anh troi (con cua IsoMap, them sau NadiaScene, truoc
## marker): Sang = mat troi cao + bong ngan (bong san co trong
## NadiaScene/CharacterSprite); Chieu = mat troi thap cam + bong dai
## do ve trai-duoi duoi chan nguoi choi + NPC; Toi = trang tron ve
## bang code (sao nam trong anh nen dem; trang trong anh da xoa vi
## anh gen khong dat dung vi tri).
## Toa do tuyet doi he IsoMap (goc (0,0)); offset lay tu IsoMap.

var frame_idx := 0  # 0 Sang, 1 Chieu, 2 Toi.
var offset := Vector2.ZERO
var sun_pos := Vector2.ZERO  # Vi tri mat troi lan ve gan nhat (de test).
var moon_pos := Vector2.ZERO  # Vi tri trang lan ve gan nhat (de test).
var player: Node2D = null  # Main gan sau khi tao player (Node2D thay
	# vi Player de tranh vong phu thuoc kieu SkyEffects -> Player ->
	# IsoMap -> SkyEffects lam parser khong giai quyet duoc member).
var _npc_positions: Array[Vector2] = []
var _last_player_pos := Vector2.INF
var _last_cam := Vector2.INF  # Vi tri camera lan ve gan nhat (neo mat troi/trang).

func setup_npcs(markers: Array) -> void:
	_npc_positions.clear()
	for mk in markers:
		if String(mk.event_data.get("kind", "")) == "npc":
			_npc_positions.append(mk.position)

## Mat troi/trang neo theo CAMERA (vi tri man hinh co dinh), khong
## neo theo map nua: neo map thi camera sang phai (khu TAP HOA)
## la trang bi cat nua o mep trai, mat troi troi khoi khung
## (kiem live 14:34). Toa do man hinh: duoi HUD (~190), tren mai
## nha — mat troi Sang (170,290), Chieu (330,290), trang (400,300).
func _cam_anchor(screen_pos: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return offset + Vector2(0, -140)
	var vp := get_viewport_rect().size
	var top_left := cam.get_screen_center_position() - vp / (2.0 * cam.zoom)
	return top_left + screen_pos / cam.zoom

func _process(_delta: float) -> void:
	# Ve lai khi camera doi cho (mat troi/trang neo camera) hoac
	# nguoi choi doi cho o khung Chieu (bong dai).
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var cp := cam.get_screen_center_position()
		if cp.distance_to(_last_cam) > 2.0:
			_last_cam = cp
			queue_redraw()
	# Bong dai chi can ve lai khi nguoi choi doi cho (NPC dung yen).
	if frame_idx == 1 and player != null and player.position.distance_to(_last_player_pos) > 2.0:
		_last_player_pos = player.position
		queue_redraw()

func _draw() -> void:
	if frame_idx == 0:
		# Mat troi sang: cao, vang dam — neo camera (170,290).
		sun_pos = _cam_anchor(Vector2(170, 290))
		_draw_sun(sun_pos, 38.0,
			Color(1.0, 0.88, 0.35, 1), Color(1.0, 0.8, 0.3, 1))
	elif frame_idx == 1:
		# Mat troi lan: thap, cam dam — neo camera (330,290).
		sun_pos = _cam_anchor(Vector2(330, 290))
		_draw_sun(sun_pos, 42.0,
			Color(1.0, 0.62, 0.28, 1), Color(1.0, 0.55, 0.2, 1))
		_draw_long_shadows()
	elif frame_idx == 2:
		# Trang tron: ve bang code, neo camera (400,300) — duoi
		# HUD, tren mai nha, giua khung hinh. Mau >1.0 (HDR) de
		# con sang sau lop MUL dem (0.7,0.78,0.95).
		moon_pos = _cam_anchor(Vector2(400, 300))
		_draw_moon(moon_pos)

func _draw_sun(c: Vector2, r: float, core: Color, glow: Color) -> void:
	draw_circle(c, r * 2.6, Color(glow.r, glow.g, glow.b, 0.16))
	draw_circle(c, r * 1.7, Color(glow.r, glow.g, glow.b, 0.28))
	draw_circle(c, r, Color(core.r, core.g, core.b, 0.95))
	draw_circle(c, r * 0.7, Color(1, 1, 1, 0.9))

func _draw_moon(c: Vector2) -> void:
	# Trang tron r=40: quang mo + dia sang + 3 vet lom.
	draw_circle(c, 104.0, Color(1.2, 1.2, 1.0, 0.10))
	draw_circle(c, 68.0, Color(1.2, 1.2, 1.0, 0.18))
	draw_circle(c, 40.0, Color(1.3, 1.3, 1.15, 0.95))
	draw_circle(c + Vector2(-12, -8), 7.0, Color(0.85, 0.85, 0.75, 0.5))
	draw_circle(c + Vector2(10, 6), 5.0, Color(0.85, 0.85, 0.75, 0.5))
	draw_circle(c + Vector2(4, -14), 4.0, Color(0.85, 0.85, 0.75, 0.5))

func _draw_long_shadows() -> void:
	# Bong dai do ve trai-duoi (nang chieu tu phai): ellipse mem
	# dai gap ~2.5 lan bong tron buoi sang.
	var spots: Array[Vector2] = []
	if player != null:
		spots.append(player.position)
	spots.append_array(_npc_positions)
	for p in spots:
		draw_set_transform(p + Vector2(-34, 4), 0.0, Vector2(1.0, 0.22))
		draw_circle(Vector2.ZERO, 34, Color(0.1, 0.08, 0.05, 0.20))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
