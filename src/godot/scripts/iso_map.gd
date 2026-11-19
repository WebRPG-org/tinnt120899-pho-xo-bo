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
	for e in data["events"]:
		var m: Node2D = marker_script.new()
		m.event_data = e
		m.font = font
		m.position = tile_center(Vector2i(e["tile"][0], e["tile"][1]))
		add_child(m)
		markers.append(m)
