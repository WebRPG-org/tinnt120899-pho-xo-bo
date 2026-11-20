class_name IsoMap
extends Node2D
## IsoMap — Ban do isometric 12x9 port tu RPG Maker MV (G1).
##
## TileSet isometric 64x32 dung atlas PNG hien co (src/nadia/www/img/tilesets/).
## Atlas PNG la luoi cell 64x64 (1 hang, 8 cot): tile nen la hinh thoi 64x32
## nam o nua duoi cell (y=32..64), vat cao (nha/sap) dung gan het cell.
## Vi vay texture_region_size = (64,64), texture_origin = (0,-32) de day
## hinh thoi / chan vat roi dung vao day o tile (xem docs/godot-g1.md §4 —
## day la GIA DINH can verify bang trinh duyet that, chua kiem chung duoc
## tren VM headless).
##
## Lop 0 (nen) + lop 1 (vat) la 2 TileMapLayer rieng, ca 2 bat y_sort de
## nguoi/NPC/hotspot dung truoc/sau vat dung (tieu chuan iso cua Godot).
## Vat o lop 1 tao thanh vong bien quanh map (xem Map JSON) nen cung la
## tuong chan: is_walkable() = trong bien + lop 1 trong + khong co NPC.

const TILE_W := 64
const TILE_H := 32
const CELL_W := 64
const CELL_H := 64

var map_data: Dictionary = {}
var offset := Vector2.ZERO
var label_layer: CanvasLayer = null  # Lop nhan (tren the gioi, duoi HUD) — Main truyen vao.
var ground_layer: TileMapLayer
var object_layer: TileMapLayer
var markers: Array = []  # Marker nodes, moi cai giu event_data
var night_glow: NightGlow = null  # Dom sang cua so khung Toi.
var nadia_scene: NadiaScene = null  # Canh ve tay kieu Nadia (chi Map001-002).
var skyfx: SkyEffects = null  # Mat troi + bong dai theo khung.
var has_night_bg := false  # Map co anh nen dem rieng de doi khi Toi.
var _bg_sprite: Sprite2D = null  # Anh nen mat tien (Map001) / dai troi (Map002+).
var _bg_day_tex: Texture2D = null
var _bg_night_tex: Texture2D = null
var _sky_ext_sprite: Sprite2D = null  # Dai troi mo rong phia tren anh nen (moi map).
var _sky_ext_day_tex: Texture2D = null
var _sky_ext_night_tex: Texture2D = null

## Doi khung (0 Sang, 1 Chieu, 2 Toi): doi anh nen sang ban dem,
## cap nhat mat troi/bong dai. Main goi trong _update_daynight
## (ca khi load map — map moi co the mo o khung Toi).
func set_frame(f: int) -> void:
	if _bg_sprite != null:
		if f == 2 and _bg_night_tex != null:
			_bg_sprite.texture = _bg_night_tex
		elif _bg_day_tex != null:
			_bg_sprite.texture = _bg_day_tex
	if _sky_ext_sprite != null:
		if f == 2 and _sky_ext_night_tex != null:
			_sky_ext_sprite.texture = _sky_ext_night_tex
			_sky_ext_sprite.scale = Vector2(1.0, 400.0 / 280.0)
		elif _sky_ext_day_tex != null:
			_sky_ext_sprite.texture = _sky_ext_day_tex
			_sky_ext_sprite.scale = Vector2.ONE
	if skyfx != null:
		skyfx.frame_idx = f
		skyfx.queue_redraw()

## Hash xac dinh (khong random moi lan ve): 0..99.
static func _hash(tx: int, ty: int) -> int:
	return (int((tx * 73856093) ^ (ty * 19349663)) & 0x7fffffff) % 100

## Vi tri cua so sang vao ban dem: moi o lop 1 o hang tren (ty = 0).
func night_spots() -> Array[Vector2]:
	var spots: Array[Vector2] = []
	for tx in range(12):
		if layer1_at(Vector2i(tx, 0)) > 0:
			spots.append(tile_center(Vector2i(tx, 0)) + Vector2(0, -26))
	return spots

## Chieu tile -> tam hinh thoi (chua cong offset).
static func tile_center_raw(tile: Vector2i) -> Vector2:
	return Vector2((tile.x - tile.y) * (TILE_W / 2), (tile.x + tile.y) * (TILE_H / 2) + TILE_H / 2)

func tile_center(tile: Vector2i) -> Vector2:
	return offset + tile_center_raw(tile)

func world_to_tile(pos: Vector2) -> Vector2i:
	var local := pos - offset
	var dx := local.x / (TILE_W / 2.0)
	var dy := (local.y - TILE_H / 2.0) / (TILE_H / 2.0)
	var tx := int(round((dx + dy) / 2.0))
	var ty := int(round((dy - dx) / 2.0))
	return Vector2i(tx, ty)

func in_bounds(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < 12 and tile.y < 9

func layer1_at(tile: Vector2i) -> int:
	if not in_bounds(tile):
		return -1
	return int(map_data["layers"][1][tile.y * 12 + tile.x])

func npc_at(tile: Vector2i) -> Dictionary:
	for e in map_data["events"]:
		if e["kind"] == "npc" and Vector2i(e["tile"][0], e["tile"][1]) == tile:
			return e
	return {}

func event_at(tile: Vector2i) -> Dictionary:
	for e in map_data["events"]:
		if Vector2i(e["tile"][0], e["tile"][1]) == tile:
			return e
	return {}

func is_walkable(tile: Vector2i) -> bool:
	if not in_bounds(tile):
		return false
	if layer1_at(tile) != 0:
		return false
	if not npc_at(tile).is_empty():
		return false
	return true

func build(data: Dictionary, marker_script: Script, font: Font, p_label_layer: CanvasLayer = null) -> void:
	map_data = data
	label_layer = p_label_layer
	for c in get_children():
		c.queue_free()
	markers.clear()
	nadia_scene = null
	# Can map vao giua man hinh: tam cac tam hinh thoi dat o (360, 470)
	# (chua cho HUD tren + hop thoai duoi).
	var corners: Array[Vector2] = [
		tile_center_raw(Vector2i(0, 0)), tile_center_raw(Vector2i(11, 0)),
		tile_center_raw(Vector2i(0, 8)), tile_center_raw(Vector2i(11, 8)),
	]
	var min_p := corners[0]
	var max_p := corners[0]
	for p in corners:
		min_p = Vector2(minf(min_p.x, p.x), minf(min_p.y, p.y))
		max_p = Vector2(maxf(max_p.x, p.x), maxf(max_p.y, p.y))
	var center := (min_p + max_p) * 0.5
	offset = Vector2(360, 470) - center

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_W, TILE_H)
	tile_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	# DIAMOND_DOWN (khong phai STACKED mac dinh): chi layout nay
	# map_to_local moi khop cong thuc iso co dien tile_center_raw
	# (sai so hang so (32,0) — probe 20/11 12:30). STACKED mac dinh
	# cho toa do lech kieu staggered, tile ve sai cho tren Map003+
	# (loi: map_to_local((5,4))=(352,80) trong khi tile_center=(344,462)).
	tile_set.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	var source := TileSetAtlasSource.new()
	source.texture = load(data["atlas_png"])
	source.texture_region_size = Vector2i(CELL_W, CELL_H)
	tile_set.add_source(source, 0)
	# Moi tile atlas la 1 cell 64x64 o hang 0, cot = x / 64.
	var col_of := {}
	for key in data["atlas_tiles"].keys():
		var t: Dictionary = data["atlas_tiles"][key]
		var col := int(t["x"]) / CELL_W
		col_of[int(key)] = col
		source.create_tile(Vector2i(col, 0), Vector2i(1, 1))
		var td := source.get_tile_data(Vector2i(col, 0), 0)
		td.texture_origin = Vector2i(0, TILE_H - CELL_H)  # (0,-32): day hinh thoi xuong day o
		td.y_sort_origin = TILE_H  # int: sap xep theo day o (32px duoi dinh o)

	ground_layer = TileMapLayer.new()
	ground_layer.tile_set = tile_set
	ground_layer.y_sort_enabled = true
	add_child(ground_layer)
	object_layer = TileMapLayer.new()
	object_layer.tile_set = tile_set
	object_layer.y_sort_enabled = true
	add_child(object_layer)
	# Can lop tile vao he toa do cua marker/nguoi choi (offset+raw):
	# voi DIAMOND_DOWN, tam hinh thoi cua o t trong khong gian lop
	# = map_to_local(t) + (32,16) = raw + (64,16); muon tam do trung
	# tile_center(t) = offset + raw thi lop phai dich offset-(64,16).
	# Khong dich thi tile ve lech khoi NPC/nguoi choi tren Map003+
	# (loi 20/11 12:20; Map001-002 khong thay vi lop bi an).
	ground_layer.position = offset - Vector2(64, 16)
	object_layer.position = offset - Vector2(64, 16)
	for i in range(108):
		var tx := i % 12
		var ty := i / 12
		var g := int(data["layers"][0][i])
		if g > 0:
			ground_layer.set_cell(Vector2i(tx, ty), 0, Vector2i(col_of[g], 0))
		var o := int(data["layers"][1][i])
		if o > 0:
			object_layer.set_cell(Vector2i(tx, ty), 0, Vector2i(col_of[o], 0))

	y_sort_enabled = true
	var map_id := int(data.get("id", 0))
	# Anh nen ve tay (Map001: troi + mat tien composite; Map002+:
	# dai troi rieng — sky_band.png la troi chung, khong rieng
	# Map002, nen Map003+ dung luon lam nen troi mac dinh thay vi
	# de nua tren man hinh la mau clear nau tron (loi 20/11 13:20):
	# day anh o offset.y-50, vua chan mat tien/tile hang tren
	# (~offset.y-48). Sprite2D con cua IsoMap, dat TRUOC NadiaScene
	# trong cay nen canh code ve sau de len tren anh — dung he toa do offset
	# (nhu NadiaScene/marker), khong dung toa do tho cua TileMapLayer.
	# Composite Map001: 1120x630, day o ground row 0 (+20), dinh -610.
	# Troi Map002: 1120x280, dinh -330, day -50.
	# Ban dem doi sang anh dem rieng (set_frame) thay vi chi phu lop
	# MUL — anh ngay ma phu MUL thi troi van sang, may trang nguyen.
	_bg_day_tex = null
	_bg_night_tex = null
	_bg_sprite = null
	if map_id == 1 and ResourceLoader.exists("res://art/bg_map001.png"):
		_bg_day_tex = load("res://art/bg_map001.png")
		if ResourceLoader.exists("res://art/bg_map001_night.jpg"):
			_bg_night_tex = load("res://art/bg_map001_night.jpg")
		_bg_sprite = Sprite2D.new()
		_bg_sprite.texture = _bg_day_tex
		_bg_sprite.position = offset + Vector2(0, -295)
		add_child(_bg_sprite)
	elif map_id >= 2 and ResourceLoader.exists("res://art/sky_band.png"):
		_bg_day_tex = load("res://art/sky_band.png")
		if ResourceLoader.exists("res://art/sky_night.jpg"):
			_bg_night_tex = load("res://art/sky_night.jpg")
		_bg_sprite = Sprite2D.new()
		_bg_sprite.texture = _bg_day_tex
		_bg_sprite.position = offset + Vector2(0, -190)
		add_child(_bg_sprite)
	has_night_bg = _bg_night_tex != null
	# Dai troi mo rong (sky_wide.jpg 1120x400): noi tren dinh anh nen
	# de dai troi cao them 400px — anh goc chi co ~60px troi nen camera
	# nhin len bao nhieu cung khong thay troi luc spawn (loi 20/11 12:30).
	# Tam: Map001 offset+(0,-810) (dinh -1010..-610), Map002+ offset+(0,-530).
	# Map003+ cung co (truoc day chi Map001-002 moi co nen nua tren
	# Map003 la mau clear nau tron — loi 20/11 13:20).
	_sky_ext_day_tex = null
	_sky_ext_night_tex = null
	_sky_ext_sprite = null
	if ResourceLoader.exists("res://art/sky_wide.jpg"):
		_sky_ext_day_tex = load("res://art/sky_wide.jpg")
		if ResourceLoader.exists("res://art/sky_night.jpg"):
			_sky_ext_night_tex = load("res://art/sky_night.jpg")
		_sky_ext_sprite = Sprite2D.new()
		_sky_ext_sprite.texture = _sky_ext_day_tex
		var ext_center_y := -810.0 if map_id == 1 else -530.0
		_sky_ext_sprite.position = offset + Vector2(0, ext_center_y)
		add_child(_sky_ext_sprite)
	# Map001-002: canh ve tay kieu Nadia thay tile Kenney (atlas van giu
	# de logic lop 1 / is_walkable dung so lieu cu, chi an hinh).
	if map_id == 1 or map_id == 2:
		ground_layer.visible = false
		object_layer.visible = false
		nadia_scene = NadiaScene.new()
		add_child(nadia_scene)
		nadia_scene.setup(data, font, offset)
	# Mat troi + bong dai theo khung (ve tren anh troi, duoi HUD):
	# them sau NadiaScene (ve tren canh) nhung truoc marker (duoi NPC).
	skyfx = SkyEffects.new()
	skyfx.offset = offset
	# z_index 10: IsoMap bat y-sort — SkyEffects o y=0 se bi Sprite2D
	# nen composite (y=23, duc) ve DE LEN, che mat troi/trang (cung
	# ho loi NightGlow 20/11 12:20). z_index dua mat troi/trang/bong
	# len tren anh nen; chung o tren troi (y<0) nen khong che NPC.
	skyfx.z_index = 10
	add_child(skyfx)
	for e in data["events"]:
		var m: Node2D = marker_script.new()
		m.event_data = e
		m.font = font
		m.label_layer = label_layer
		m.position = tile_center(Vector2i(e["tile"][0], e["tile"][1]))
		add_child(m)
		markers.append(m)
	skyfx.setup_npcs(markers)
	# Dom sang cua so (them sau cung de ve tren lop vat, duoi NPC).
	night_glow = NightGlow.new()
	add_child(night_glow)
	# z_index 10: IsoMap bat y-sort — NightGlow o y=0 se bi Sprite2D
	# nen composite (y=7, duc) ve DE LEN, che mat trang/sao/dom sang
	# (loi 20/11 12:20: trang ve nhung khong thay). z_index dua dom
	# len tren ca anh nen + NPC (anh sang chong len nhan vat la dung).
	night_glow.z_index = 10
	# Map co anh nen dem rieng (1-2): cua so/den long da sang trong
	# anh — khong ve them cua so sang (de lech vi tri) hay trang/sao
	# (trung voi trang/sao trong anh); chi giu quang den long.
	if map_id == 1 or map_id == 2:
		night_glow.set_spots([])
		night_glow.sky_in_image = true
	else:
		night_glow.set_spots(night_spots())
	# Goc tren-trai DAI TROI (composite 1120x630, tam o offset+(0,-295)
	# -> dinh y = offset.y-610, day y = offset.y+20): trang/sao nam
	# trong dai nay, khong roi xuong mat tien nhu truoc (loi: truyen
	# offset+(-560,-330) la dinh mat tien, sao roi len cua/nen dat).
	night_glow.set_sky(offset + Vector2(-560, -610))
	night_glow.lamps = [tile_center(Vector2i(2, 10)) + Vector2(10, -28)]  # Theo cot den long (NadiaScene, doi tu (10,10) vong 5).
	queue_redraw()

# Nen dat nay la anh ve tay (ground_wide.jpg, Sprite2D cua Main) thay
# cho hinh thoi ve bang code — hinh thoi cu co 3 loi: ve bang
# tile_center_raw (khong cong offset) nen lech he toa do voi marker;
# duong nhua/via he cheo + cum co lo ra thanh mang zigzag o goc
# tren-phai va duong o xanh la cheo o khung Toi; duong noi ngang gat
# voi mat tien (loi 20/11 12:30). Khong ve gi o day nua; neu thieu
# anh thi nen la mau clear am cua project.
func _draw() -> void:
	pass
