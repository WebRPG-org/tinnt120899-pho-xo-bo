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
var ground_layer: TileMapLayer
var object_layer: TileMapLayer
var markers: Array = []  # Marker nodes, moi cai giu event_data
var night_glow: NightGlow = null  # Dom sang cua so khung Toi.
var nadia_scene: NadiaScene = null  # Canh ve tay kieu Nadia (chi Map001-002).

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

func build(data: Dictionary, marker_script: Script, font: Font) -> void:
	map_data = data
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
	# Map001-002: canh ve tay kieu Nadia thay tile Kenney (atlas van giu
	# de logic lop 1 / is_walkable dung so lieu cu, chi an hinh).
	var map_id := int(data.get("id", 0))
	if map_id == 1 or map_id == 2:
		ground_layer.visible = false
		object_layer.visible = false
		nadia_scene = NadiaScene.new()
		add_child(nadia_scene)
		nadia_scene.setup(data, font, offset)
	for e in data["events"]:
		var m: Node2D = marker_script.new()
		m.event_data = e
		m.font = font
		m.position = tile_center(Vector2i(e["tile"][0], e["tile"][1]))
		add_child(m)
		markers.append(m)
	# Dom sang cua so (them sau cung de ve tren lop vat, duoi NPC).
	night_glow = NightGlow.new()
	add_child(night_glow)
	night_glow.set_spots(night_spots())
	queue_redraw()

# Nen dat mo rong quanh map: ca viewport la dat duong am chu khong phai
# khoang toi (loi xau nhat tren ban live: ~85% man hinh navy trong).
# Ve truoc TileMapLayer (parent ve truoc children) nen tile map de len tren.
func _draw() -> void:
	var tone_a := Color(0.78, 0.70, 0.55, 1)  # Dat kho am
	var tone_b := Color(0.72, 0.64, 0.49, 1)
	var tone_c := Color(0.66, 0.58, 0.44, 1)  # Diem toi hon (co dai)
	var road := Color(0.42, 0.40, 0.38, 1)  # Duong nhua
	var sidewalk := Color(0.82, 0.78, 0.66, 1)  # Via he
	var grass := Color(0.32, 0.48, 0.22, 1)
	for ty in range(-12, 25):
		for tx in range(-14, 27):
			var c := tile_center_raw(Vector2i(tx, ty))
			var half_w := TILE_W / 2.0
			var half_h := TILE_H / 2.0
			var diamond := PackedVector2Array([
				c + Vector2(0, -half_h), c + Vector2(half_w, 0),
				c + Vector2(0, half_h), c + Vector2(-half_w, 0),
			])
			var tone := tone_a if (tx + ty) % 2 == 0 else tone_b
			if (tx * 7 + ty * 13) % 7 == 0:
				tone = tone_c
			# Duong nhua chay doc (tx - ty khong doi) + via he 2 ben,
			# de nen duoi map khong con la be tron (20/11 10:30).
			var diff := (tx - ty) % 16
			if diff == 0 or diff == 1:
				tone = road
			elif diff == 2 or diff == 15:
				tone = sidewalk
			draw_colored_polygon(diamond, tone)
			# Vach trang giua duong (net dut).
			if (diff == 0 or diff == 1) and (tx + ty) % 4 == 0:
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(0, -4), c + Vector2(8, 0),
					c + Vector2(0, 4), c + Vector2(-8, 0),
				]), Color(0.92, 0.90, 0.82, 0.9))
			# Chi tiet nho (chi tren nen dat, khong ve tren duong/via he).
			if diff != 0 and diff != 1 and diff != 2 and diff != 15:
				var h := _hash(tx, ty)
				if h < 8:
					# Cum co: 3 net ngan.
					for k in range(3):
						var base := c + Vector2(-6 + k * 6, 4)
						draw_line(base, base + Vector2(-2 + k, -8), grass, 2.0)
				elif h < 12:
					# Hoa dai: 3 cham hong/vang/trang.
					var petal := [Color(0.95, 0.55, 0.65, 1), Color(0.98, 0.85, 0.3, 1), Color(0.95, 0.95, 0.9, 1)]
					for k in range(3):
						draw_circle(c + Vector2(-8 + k * 8, -2 + (k % 2) * 5), 2.5, petal[k])
				elif h < 16:
					# Soi da nho.
					draw_circle(c + Vector2(-5, 2), 3.0, Color(0.6, 0.58, 0.54, 1))
					draw_circle(c + Vector2(5, -1), 2.0, Color(0.68, 0.66, 0.62, 1))
				elif h < 19:
					# La roi.
					draw_circle(c + Vector2(-4, 3), 2.5, Color(0.85, 0.55, 0.2, 0.9))
					draw_circle(c + Vector2(6, -3), 2.5, Color(0.75, 0.45, 0.15, 0.9))
