class_name NadiaScene
extends Node2D
## NadiaScene — Canh khu pho ve tay kieu pre-rendered 2D cua Nadia.
##
## Thay tile Kenney phang bang canh day chi tiet, ve bang code (khong
## dung asset ngoai — tranh ban quyen, khong phu thuoc file nhi phan):
## tuong vang cu loang lo, mai ton ri, bien hieu chu Viet, day dien
## chung chit, cay chuoi, xe may, sap hang, khoi bep, meo ngu tren
## bac cua — moi vat ke duoc doi song Viet (nadia-reference.md §1.10,
## nadia-scene-study.md §2.12). Chi dung cho Map001-002 (slice); cac
## map khac van dung atlas cho toi khi co canh rieng.
##
## Giu nguyen logic gameplay cua IsoMap (o tile, is_walkable, event):
## canh chi la lop ve — nha o vong bien layer-1, do vat lon dat NGOAI
## vung di duoc (dat mo rong duoi map) de nguoi choi khong di xuyen qua.
## Toa do goc o chan vat (nhu CharacterSprite), y tang xuong duoi.

const TILE_W := 64
const TILE_H := 32

var map_id := 1
var map_data: Dictionary = {}
var font: Font = null
var offset := Vector2.ZERO

var _t := 0.0
var _redraw_acc := 0.0

# Bien hieu tieng Viet theo khu (chon xac dinh theo hash — khong random).
# Ten ngan (<= 8 ky tu) de vua bang hieu 58px o co 10.
const SIGNS_MAP1 := ["PHỞ BÒ", "CÀ PHÊ", "TẠP HÓA", "CHO THUÊ",
	"CƠM TẤM", "BÁNH MÌ", "SỬA XE", "CHÁO LÒNG"]
const SIGNS_MAP2 := ["RAU CỦ", "CÁ TƯƠI", "THỊT HEO", "TRÁI CÂY",
	"BÁNH MÌ", "GIA VỊ", "HOA QUẢ", "ĐỒ KHÔ"]
const WALL_TINTS := [
	Color(0.93, 0.82, 0.55, 1), Color(0.88, 0.76, 0.50, 1),
	Color(0.95, 0.87, 0.62, 1), Color(0.85, 0.78, 0.58, 1),
	Color(0.80, 0.85, 0.70, 1),
]
const ROOF_COLORS := [
	Color(0.62, 0.30, 0.22, 1), Color(0.45, 0.50, 0.42, 1),
	Color(0.55, 0.32, 0.24, 1), Color(0.38, 0.42, 0.48, 1),
]

static func _hash(tx: int, ty: int) -> int:
	return (int((tx * 73856093) ^ (ty * 19349663)) & 0x7fffffff) % 100

func tile_center(tile: Vector2i) -> Vector2:
	return offset + IsoMap.tile_center_raw(tile)

func setup(data: Dictionary, p_font: Font, p_offset: Vector2) -> void:
	map_data = data
	map_id = int(data.get("id", 1))
	font = p_font
	offset = p_offset
	queue_redraw()

## Khung hien tai (IsoMap.set_frame goi): anh sang mat tien doi
## theo huong nang — Sang: trai toi dan, phai am nhe (nang tu
## phai-tren); Chieu: am toan mat + trai toi hon; Toi: khong ve
## (lop MUL dem lo).
var frame_idx := 0

func set_frame(f: int) -> void:
	if frame_idx != f:
		frame_idx = f
		queue_redraw()

func _process(delta: float) -> void:
	# Chi ve lai cho khoi bep (~7 lan/giay) — du de thay khoi bay.
	_t += delta
	_redraw_acc += delta
	if _redraw_acc >= 0.15:
		_redraw_acc = 0.0
		queue_redraw()

func _draw() -> void:
	# Map001: anh composite ve thay troi + mai xa + mat tien + day dien.
	# Map002: anh troi ve thay troi code; mai xa + mat tien code giu
	# (ve len tren anh troi). Ground/tuong ben/hang rao/dao cu code giu
	# (dat len tren anh, khop tile).
	# Nen dat (hinh thoi) KHONG ve nua — mat dat la anh ve tay
	# ground_wide.jpg (Sprite2D cua Main): hinh thoi phang tao duong
	# noi ngang gat voi mat tien (loi 20/11 12:30).
	if map_id != 1:
		_draw_far_roofs()
	_draw_shadows()
	# Tuong ben chi ve tu Map002 tro di: Map001 co anh composite ve
	# san tuong/nha 2 ben — tuong code (hinh chu nhat be phang +
	# ap phich trang-do) de len anh dat trong nhu tile placeholder
	# (loi 20/11 12:30).
	if map_id != 1:
		_draw_side_walls()
	if map_id != 1:
		_draw_facades()
	_draw_bottom_fence()
	if map_id != 1:
		_draw_wires()
	_draw_props()
	if map_id == 1:
		_draw_facade_light()

func _draw_sky() -> void:
	# Anh sang am phia sau mai nha: 3 dai vang mo dan xuong.
	var top := offset + Vector2(-560, -330)
	var w := 1120.0
	draw_rect(Rect2(top, Vector2(w, 110)), Color(0.98, 0.90, 0.68, 1))
	draw_rect(Rect2(top + Vector2(0, 110), Vector2(w, 90)), Color(0.97, 0.86, 0.60, 1))
	draw_rect(Rect2(top + Vector2(0, 200), Vector2(w, 80)), Color(0.95, 0.82, 0.55, 1))

func _draw_far_roofs() -> void:
	# Mai nha xa mo — tao chieu sau sau day nha gan.
	var base_y := offset.y - 108.0
	var tones := [Color(0.55, 0.42, 0.34, 0.9), Color(0.48, 0.38, 0.38, 0.9),
		Color(0.60, 0.45, 0.32, 0.9)]
	for i in range(6):
		var x0 := offset.x - 480.0 + float(i) * 175.0 + float(_hash(i, 3) % 40)
		var peak := base_y - 26.0 - float(_hash(i, 7) % 22)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x0, base_y), Vector2(x0 + 165, base_y),
			Vector2(x0 + 125, peak), Vector2(x0 + 40, peak),
		]), tones[i % 3])
		# Ong khoi xa.
		if _hash(i, 11) % 2 == 0:
			draw_rect(Rect2(x0 + 100, peak - 14, 10, 16), tones[i % 3].darkened(0.2))

func _draw_ground() -> void:
	# Nen duong lat da am — moi o co vet nut / reu / la roi / vung nuoc.
	var wet := map_id == 2
	for ty in range(9):
		for tx in range(12):
			var c := tile_center(Vector2i(tx, ty))
			var diamond := PackedVector2Array([
				c + Vector2(0, -16), c + Vector2(32, 0),
				c + Vector2(0, 16), c + Vector2(-32, 0),
			])
			var tone: Color
			if wet:
				tone = Color(0.60, 0.55, 0.46, 1) if (tx + ty) % 2 == 0 else Color(0.58, 0.53, 0.45, 1)
			else:
				# 2 tone gan nhau de mat duong nhu 1 mat ve lien (khong
				# lo o caro nhu tile truoc day).
				tone = Color(0.74, 0.67, 0.52, 1) if (tx + ty) % 2 == 0 else Color(0.72, 0.65, 0.50, 1)
			draw_colored_polygon(diamond, tone)
			# Mach gach (vien mo cua hinh thoi).
			draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
				Color(0, 0, 0, 0.10), 1.0)
			var h := _hash(tx, ty)
			if h < 8:
				# Vet nut.
				draw_line(c + Vector2(-8, -2), c + Vector2(4, 5), Color(0.25, 0.20, 0.15, 0.5), 1.5)
				draw_line(c + Vector2(4, 5), c + Vector2(10, 2), Color(0.25, 0.20, 0.15, 0.4), 1.0)
			elif h < 14:
				# Reu o goc gach.
				draw_circle(c + Vector2(-20, 6), 3.0, Color(0.35, 0.50, 0.25, 0.7))
				draw_circle(c + Vector2(18, -4), 2.5, Color(0.35, 0.50, 0.25, 0.6))
			elif h < 18:
				# Vung nuoc nho phan chieu troi.
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(-12, 2), c + Vector2(10, -2),
					c + Vector2(14, 4), c + Vector2(-6, 7),
				]), Color(0.75, 0.85, 0.90, 0.55))
				draw_line(c + Vector2(-8, 3), c + Vector2(8, 1), Color(1, 1, 1, 0.6), 1.0)
			elif h < 24:
				# La roi.
				draw_circle(c + Vector2(-6, 4), 2.5, Color(0.85, 0.55, 0.2, 0.9))
				draw_circle(c + Vector2(8, -3), 2.5, Color(0.75, 0.45, 0.15, 0.9))
			if wet and h >= 24 and h < 32:
				# Rom ra cho uot.
				for k in range(3):
					var p := c + Vector2(-10 + k * 9, -3 + (k % 2) * 6)
					draw_line(p, p + Vector2(6, 1), Color(0.85, 0.72, 0.35, 0.8), 1.5)
			if not wet and h >= 24 and h < 28:
				# Net phan trang tre con ve.
				draw_arc(c + Vector2(0, 2), 7, PI * 0.1, PI * 0.9, 8, Color(1, 1, 1, 0.55), 1.5)

func _draw_side_walls() -> void:
	# Tuong 2 ben hem: thap, co ap phich / cay leo, khong che tam nhin.
	for ty in range(1, 8):
		for tx in [0, 11]:
			var c := tile_center(Vector2i(tx, ty))
			var h := _hash(tx, ty)
			var tint: Color = WALL_TINTS[h % WALL_TINTS.size()].darkened(0.08)
			draw_rect(Rect2(c + Vector2(-32, -30), Vector2(64, 46)), tint)
			draw_rect(Rect2(c + Vector2(-32, -30), Vector2(64, 5)), tint.lightened(0.15))
			# Bong duoi chan tuong.
			draw_rect(Rect2(c + Vector2(-32, 12), Vector2(64, 4)), Color(0, 0, 0, 0.15))
			if h % 3 == 0:
				# Ap phich.
				draw_rect(Rect2(c + Vector2(-14, -24), Vector2(20, 26)), Color(0.96, 0.94, 0.86, 1))
				draw_rect(Rect2(c + Vector2(-11, -20), Vector2(14, 4)), Color(0.75, 0.25, 0.2, 1))
				draw_rect(Rect2(c + Vector2(-11, -13), Vector2(14, 2)), Color(0.3, 0.35, 0.4, 0.8))
				draw_rect(Rect2(c + Vector2(-11, -8), Vector2(14, 2)), Color(0.3, 0.35, 0.4, 0.8))
			elif h % 3 == 1:
				# Cay leo bo tuong.
				for k in range(4):
					draw_circle(c + Vector2(-18 + k * 10, -6 - (k % 2) * 8), 5.0, Color(0.30, 0.48, 0.22, 0.9))
			else:
				# Vet loang nuoc mua.
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(-10, -28), c + Vector2(-2, -28),
					c + Vector2(-6, -6), c + Vector2(-14, -6),
				]), Color(0.45, 0.38, 0.28, 0.25))

func _draw_facades() -> void:
	# Day nha mat tien (ty=0): tuong vang, mai ton, bien hieu, cua so
	# sang am, cua go, may lanh, day phoi. Map 2 la sap cho: mai hien
	# ke soc + gio hang truoc cua.
	for tx in range(12):
		var c := tile_center(Vector2i(tx, 0))
		var h := _hash(tx, 0)
		var tint: Color = WALL_TINTS[h % WALL_TINTS.size()]
		var roof: Color = ROOF_COLORS[h % ROOF_COLORS.size()]
		# Bong do duoi chan nha.
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-32, 14), c + Vector2(32, 14),
			c + Vector2(26, 20), c + Vector2(-26, 20),
		]), Color(0, 0, 0, 0.18))
		# Tuong.
		draw_rect(Rect2(c + Vector2(-32, -66), Vector2(64, 82)), tint)
		# Vet loang / nut tren tuong.
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-28, -66), c + Vector2(-18, -66),
			c + Vector2(-24, -20), c + Vector2(-30, -20),
		]), Color(0.45, 0.38, 0.28, 0.18))
		if h % 4 == 0:
			draw_line(c + Vector2(20, -60), c + Vector2(14, -30), Color(0.3, 0.25, 0.2, 0.35), 1.0)
		# Mai ton.
		draw_colored_polygon(PackedVector2Array([
			Vector2(c.x - 36, c.y - 66), Vector2(c.x + 36, c.y - 66),
			Vector2(c.x + 27, c.y - 92), Vector2(c.x - 27, c.y - 92),
		]), roof)
		for k in range(5):
			var rx := c.x - 24 + k * 12
			draw_line(Vector2(rx, c.y - 68), Vector2(rx - 4, c.y - 90), roof.darkened(0.25), 1.5)
		if h % 3 == 0:
			# Ong khoi.
			draw_rect(Rect2(c + Vector2(14, -104), Vector2(10, 14)), Color(0.5, 0.42, 0.35, 1))
		# Bien hieu go + chu Viet.
		var signs: Array = SIGNS_MAP2 if map_id == 2 else SIGNS_MAP1
		var text := String(signs[h % signs.size()])
		draw_rect(Rect2(c + Vector2(-29, -62), Vector2(58, 13)), Color(0.42, 0.28, 0.16, 1))
		draw_rect(Rect2(c + Vector2(-29, -62), Vector2(58, 13)), Color(0, 0, 0, 0), false, 1.0)
		if font != null:
			var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x
			draw_string(font, Vector2(c.x - tw / 2.0, c.y - 52), text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.93, 0.70, 1))
		var variant := h % 3
		if map_id == 2:
			_draw_shop_front(c, h)
		elif variant == 0:
			_draw_door(c)
			_draw_window(c + Vector2(0, 0), h)
		elif variant == 1:
			_draw_window(c + Vector2(-16, 0), h)
			_draw_window(c + Vector2(16, 0), h)
		else:
			_draw_gate(c)
			_draw_window(c + Vector2(14, 0), h)

## Mau kinh cua so theo khung (vong 8): ham tinh de test goi truc
## tiep duoc — _draw_window dung ham nay.
static func window_glass_color(f: int) -> Color:
	if f == 1:
		return Color(1.0, 0.84, 0.52, 1)
	if f == 2:
		return Color(1.0, 0.78, 0.38, 1)
	return Color(0.78, 0.84, 0.88, 1)

func _draw_window(c: Vector2, h: int) -> void:
	# Cua so: kinh + khung chu thap + cua chop + chau hoa.
	# Vong 8 — kinh DOI THEO KHUNG (loi cua TAP HOA anh ngay sang
	# cam nhu den toi): Sang = kinh lanh xanh-xam (ban ngay, khong
	# sang den); Chieu = am nhe (nang chieu); Toi = vang cam sang
	# den. Map001 khong dung ham nay (anh composite ve cua so) —
	# cua Map001 sua truc tiep bang PIL tren bg_map001.png.
	var glass := window_glass_color(frame_idx)
	var wx := c.x - 11
	var wy := c.y - 42
	draw_rect(Rect2(wx - 5, wy, 5, 24), Color(0.30, 0.45, 0.35, 1))
	draw_rect(Rect2(wx + 22, wy, 5, 24), Color(0.30, 0.45, 0.35, 1))
	draw_rect(Rect2(wx, wy, 22, 24), glass)
	draw_rect(Rect2(wx + 10, wy, 2, 24), Color(0.45, 0.32, 0.20, 1))
	draw_rect(Rect2(wx, wy + 11, 22, 2), Color(0.45, 0.32, 0.20, 1))
	draw_rect(Rect2(wx - 5, wy - 3, 32, 3), Color(0.55, 0.38, 0.24, 1))
	if h % 2 == 0:
		# Chau hoa duoi cua so.
		draw_rect(Rect2(wx, wy + 24, 22, 5), Color(0.45, 0.30, 0.18, 1))
		draw_circle(Vector2(wx + 5, wy + 22), 3.0, Color(0.85, 0.3, 0.3, 1))
		draw_circle(Vector2(wx + 12, wy + 21), 3.0, Color(0.95, 0.6, 0.3, 1))
		draw_circle(Vector2(wx + 18, wy + 22), 3.0, Color(0.85, 0.3, 0.5, 1))

func _draw_door(c: Vector2) -> void:
	# Cua go + bac them + tay nam.
	draw_rect(Rect2(c + Vector2(-30, -18), Vector2(15, 34)), Color(0.45, 0.30, 0.16, 1))
	draw_rect(Rect2(c + Vector2(-27, -14), Vector2(9, 26)), Color(0.55, 0.38, 0.22, 1))
	draw_circle(Vector2(c.x - 18, c.y + 2), 1.8, Color(0.95, 0.8, 0.3, 1))
	draw_rect(Rect2(c + Vector2(-32, 14), Vector2(19, 4)), Color(0.65, 0.60, 0.52, 1))
	# May lanh ben phai cua.
	draw_rect(Rect2(c + Vector2(16, -16), Vector2(13, 9)), Color(0.85, 0.85, 0.82, 1))
	draw_line(c + Vector2(18, -12), c + Vector2(27, -12), Color(0.5, 0.5, 0.5, 1), 1.0)
	draw_line(c + Vector2(18, -9), c + Vector2(27, -9), Color(0.5, 0.5, 0.5, 1), 1.0)

func _draw_gate(c: Vector2) -> void:
	# Cong sat 2 canh (nha cho thue).
	draw_rect(Rect2(c + Vector2(-30, -30), Vector2(28, 46)), Color(0.25, 0.35, 0.40, 1))
	for k in range(4):
		draw_line(c + Vector2(-26 + k * 7, -28), c + Vector2(-26 + k * 7, 14), Color(0.15, 0.22, 0.26, 1), 1.5)
	draw_line(c + Vector2(-30, -8), c + Vector2(-2, -8), Color(0.15, 0.22, 0.26, 1), 2.0)
	draw_rect(Rect2(c + Vector2(-32, -34), Vector2(32, 4)), Color(0.55, 0.38, 0.24, 1))

func _draw_shop_front(c: Vector2, h: int) -> void:
	# Sap cho: mai hien ke soc do/trang + quay hang + gio trai cay.
	for k in range(4):
		var col := Color(0.80, 0.25, 0.20, 1) if k % 2 == 0 else Color(0.98, 0.95, 0.88, 1)
		draw_colored_polygon(PackedVector2Array([
			Vector2(c.x - 30 + k * 15, c.y - 48), Vector2(c.x - 15 + k * 15, c.y - 48),
			Vector2(c.x - 18 + k * 15, c.y - 34), Vector2(c.x - 33 + k * 15, c.y - 34),
		]), col)
	draw_rect(Rect2(c + Vector2(-30, -34), Vector2(60, 5)), Color(0.45, 0.30, 0.16, 1))
	# Quay hang.
	draw_rect(Rect2(c + Vector2(-28, -6), Vector2(56, 20)), Color(0.55, 0.38, 0.22, 1))
	draw_rect(Rect2(c + Vector2(-28, -6), Vector2(56, 4)), Color(0.65, 0.48, 0.28, 1))
	# Gio hang tren quay: rau / trai cay theo hash.
	var fruit := [Color(0.90, 0.45, 0.15, 1), Color(0.35, 0.65, 0.25, 1), Color(0.95, 0.75, 0.2, 1)]
	for k in range(3):
		var bx := c.x - 20 + k * 20
		draw_arc(Vector2(bx, c.y - 8), 8, 0, PI, 10, Color(0.65, 0.48, 0.28, 1), 2.0)
		draw_circle(Vector2(bx - 3, c.y - 11), 3.0, fruit[(h + k) % 3])
		draw_circle(Vector2(bx + 3, c.y - 12), 3.0, fruit[(h + k + 1) % 3])
		draw_circle(Vector2(bx, c.y - 14), 2.5, fruit[(h + k + 2) % 3])

func _draw_bottom_fence() -> void:
	# Hang rao thap mep gan (ty=8): khong che tam nhin, co chau cay.
	for tx in range(12):
		var c := tile_center(Vector2i(tx, 8))
		var h := _hash(tx, 8)
		# Thanh rao be phang chi ve tu Map002 tro di: Map001 co anh
		# nen ve tay — thanh rao code trong nhu tile placeholder o
		# mep duoi (loi 20/11 12:30). Chau cay + meo giu lai (doc
		# nhu chau cay tren dat, khong can thanh rao).
		if map_id != 1:
			draw_rect(Rect2(c + Vector2(-32, -2), Vector2(64, 18)), Color(0.80, 0.72, 0.55, 1))
			draw_rect(Rect2(c + Vector2(-32, -2), Vector2(64, 4)), Color(0.88, 0.80, 0.62, 1))
		if h % 3 == 0:
			# Chau cay tren hang rao.
			draw_colored_polygon(PackedVector2Array([
				Vector2(c.x - 8, c.y - 2), Vector2(c.x + 8, c.y - 2),
				Vector2(c.x + 5, c.y + 8), Vector2(c.x - 5, c.y + 8),
			]), Color(0.70, 0.40, 0.25, 1))
			draw_circle(Vector2(c.x, c.y - 8), 7.0, Color(0.30, 0.50, 0.22, 1))
			draw_circle(Vector2(c.x - 6, c.y - 4), 5.0, Color(0.35, 0.55, 0.25, 1))
			draw_circle(Vector2(c.x + 6, c.y - 4), 5.0, Color(0.28, 0.48, 0.22, 1))
	# Meo ngu cuon tron tren bac cua (tile 7,8).
	var mc := tile_center(Vector2i(7, 8)) + Vector2(0, 2)
	_draw_ellipse_shadow(mc + Vector2(0, 6), 16, 5)
	draw_circle(mc + Vector2(-4, 0), 9, Color(0.85, 0.60, 0.30, 1))
	draw_circle(mc + Vector2(8, -2), 6, Color(0.85, 0.60, 0.30, 1))
	draw_colored_polygon(PackedVector2Array([
		Vector2(mc.x + 4, -7), Vector2(mc.x + 7, -12), Vector2(mc.x + 10, -6)]),
		Color(0.85, 0.60, 0.30, 1))
	draw_colored_polygon(PackedVector2Array([
		Vector2(mc.x + 9, -7), Vector2(mc.x + 12, -12), Vector2(mc.x + 14, -6)]),
		Color(0.85, 0.60, 0.30, 1))
	draw_arc(mc + Vector2(-10, 4), 7, PI * 0.9, PI * 1.9, 10, Color(0.80, 0.55, 0.28, 1), 2.5)

func _draw_wires() -> void:
	# Cot dien + day chung chit ngang tren mai nha + chim dau day.
	var left := tile_center(Vector2i(0, 0)) + Vector2(-16, -96)
	var right := tile_center(Vector2i(11, 0)) + Vector2(16, -96)
	for p in [left, right]:
		draw_rect(Rect2(p + Vector2(-2, -58), Vector2(4, 58)), Color(0.35, 0.28, 0.20, 1))
		draw_rect(Rect2(p + Vector2(-14, -58), Vector2(28, 4)), Color(0.35, 0.28, 0.20, 1))
		draw_circle(p + Vector2(-12, -56), 2.0, Color(0.2, 0.2, 0.2, 1))
		draw_circle(p + Vector2(12, -56), 2.0, Color(0.2, 0.2, 0.2, 1))
	for sag: float in [14.0, 22.0, 30.0]:
		var pts := PackedVector2Array()
		for i in range(25):
			var f := float(i) / 24.0
			var x := lerpf(left.x, right.x, f)
			var y: float = lerpf(left.y - 56, right.y - 56, f) + sin(f * PI) * sag
			pts.append(Vector2(x, y))
		draw_polyline(pts, Color(0.15, 0.12, 0.10, 0.85), 1.5)
	# 2 con chim dau tren day giua.
	var bx := lerpf(left.x, right.x, 0.38)
	var by := lerpf(left.y - 56, right.y - 56, 0.38) + sin(0.38 * PI) * 22.0
	for d in [0.0, 18.0]:
		draw_polyline(PackedVector2Array([
			Vector2(bx + d - 4, by - 3), Vector2(bx + d, by), Vector2(bx + d + 4, by - 3)]),
			Color(0.15, 0.12, 0.10, 1), 1.5)

func _draw_props() -> void:
	# Do vat lon o dat mo rong DUOI map (khong nam tren o di duoc).
	_draw_motorbike(tile_center(Vector2i(2, 11)) + Vector2(0, 10))
	_draw_banana_tree(tile_center(Vector2i(9, 11)) + Vector2(0, 8))
	_draw_food_cart(tile_center(Vector2i(6, 12)) + Vector2(0, 8))
	_draw_stools(tile_center(Vector2i(3, 13)) + Vector2(0, 6))
	# Den long o (2,10) thay vi (10,10): cot den o (10,10) dung
	# ngay duoi nhan "Cua ra Cho Dau Moi" (nhan kep day y~1200) —
	# cot xuyen qua nhan (kiem live 14:34). Dat o goc trai duoi,
	# xa moi nhan day map.
	_draw_lantern(tile_center(Vector2i(2, 10)) + Vector2(0, 6))
	# Goc duoi-phai truoc day trong — them xe day hang rong + cum chau cay.
	# Vong 6: xe day (8,13) + xe dap (12,9) nam ngay mep duoi vung
	# nhin thay luc spawn (the gioi y 654, mep duoi 631) nen bi cat
	# nua — doi xuong 2 o (y 686/686) de nam han duoi vung nhin thay
	# luc spawn, hien day du khi nguoi choi di xuong cuoi map.
	_draw_pushcart(tile_center(Vector2i(8, 15)) + Vector2(0, 8))
	_draw_pots(tile_center(Vector2i(11, 12)) + Vector2(0, 6))
	# Vung dat mo rong phia duoi-phai (ngoai map) con trong — xe dap
	# dung via he + chong gio hang.
	_draw_bicycle(tile_center(Vector2i(12, 11)) + Vector2(0, 6))
	_draw_baskets(tile_center(Vector2i(13, 10)) + Vector2(0, 6))

func _draw_facade_light() -> void:
	# Shading mat tien theo huong nang (chi Map001 — anh composite
	# 1120x630, tam offset+(0,-295)): nang sang tu phai-tren nen
	# ben trai mat tien toi dan, ben phai am nhe. Alpha thap de
	# khong thanh vet nho — chi them chieu sau.
	if frame_idx == 2:
		return
	var top := offset + Vector2(-560, -610)
	var w := 1120.0
	var h := 630.0
	var strips := 8
	var shade_max := 0.10 if frame_idx == 0 else 0.14
	for i in range(strips):
		var t := float(i) / float(strips)  # 0 trai -> 1 phai.
		var x := top.x + w * t / 2.0  # Nua trai: toi dan ve giua.
		var a := shade_max * (1.0 - t)
		draw_rect(Rect2(x, top.y, w / 2.0 / strips + 1.0, h),
			Color(0.10, 0.08, 0.05, a))
		var xr := top.x + w * (0.5 + 0.5 * t)  # Nua phai: am dan ve giua.
		var aw := (0.05 if frame_idx == 0 else 0.08) * (1.0 - t)
		draw_rect(Rect2(xr, top.y, w / 2.0 / strips + 1.0, h),
			Color(1.0, 0.88, 0.60, aw))

func _draw_shadows() -> void:
	# Bong do mem tren mat dat — nang sang tu phai-tren (mat troi o
	# goc phai tren anh troi) nen bong do le ve trai-duoi. Bong dai nha
	# doc chan mat tien (day anh composite o the gioi y +20) + bong
	# cay chuoi / xe may / xe day / xe dap o dat mo rong duoi map.
	var base := offset + Vector2(0, 30)
	for i in range(6):
		var c := base + Vector2(-560 + i * 200.0 + 60.0, 18.0 + i * 2.0)
		_draw_ellipse_shadow(c, 130.0, 10.0, 0.10)
	_draw_ellipse_shadow(tile_center(Vector2i(9, 11)) + Vector2(-22, 10), 34.0, 8.0, 0.14)
	_draw_ellipse_shadow(tile_center(Vector2i(2, 11)) + Vector2(-18, 12), 26.0, 7.0, 0.14)
	_draw_ellipse_shadow(tile_center(Vector2i(8, 15)) + Vector2(-20, 10), 30.0, 7.0, 0.14)
	_draw_ellipse_shadow(tile_center(Vector2i(12, 11)) + Vector2(-18, 10), 24.0, 6.0, 0.14)

func _draw_ellipse_shadow(c: Vector2, rx: float, ry: float, alpha: float = 0.22) -> void:
	# Bong mem: ve bang vong tron de phang (scale y nho).
	draw_set_transform(c, 0.0, Vector2(1.0, ry / rx))
	draw_circle(Vector2.ZERO, rx, Color(0, 0, 0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_motorbike(c: Vector2) -> void:
	_draw_ellipse_shadow(c + Vector2(0, 10), 26, 6)
	# 2 banh + nan hoa.
	for wx in [-16.0, 16.0]:
		draw_arc(c + Vector2(wx, 2), 8, 0, TAU, 16, Color(0.12, 0.12, 0.12, 1), 3.0)
		draw_circle(c + Vector2(wx, 2), 2.0, Color(0.5, 0.5, 0.5, 1))
	# Than xe.
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-18, 0), c + Vector2(14, -2), c + Vector2(20, -8),
		c + Vector2(8, -10), c + Vector2(-6, -8), c + Vector2(-20, -4),
	]), Color(0.75, 0.20, 0.15, 1))
	draw_rect(Rect2(c + Vector2(-8, -14), Vector2(16, 5)), Color(0.15, 0.12, 0.12, 1))
	# Tay lai + guong + den.
	draw_line(c + Vector2(14, -8), c + Vector2(20, -16), Color(0.2, 0.2, 0.2, 1), 2.0)
	draw_circle(c + Vector2(21, -18), 2.5, Color(0.7, 0.7, 0.7, 1))
	draw_circle(c + Vector2(21, -4), 2.5, Color(1.0, 0.9, 0.5, 1))
	# Chan chong.
	draw_line(c + Vector2(-2, 2), c + Vector2(-8, 10), Color(0.2, 0.2, 0.2, 1), 2.0)

func _draw_banana_tree(c: Vector2) -> void:
	_draw_ellipse_shadow(c + Vector2(0, 4), 24, 6)
	# Than cong.
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-4, 4), c + Vector2(4, 4),
		c + Vector2(2, -34), c + Vector2(-6, -34),
	]), Color(0.55, 0.45, 0.30, 1))
	# 6 la chuoi lon xoe ra.
	var leaf_cols := [Color(0.25, 0.55, 0.20, 1), Color(0.30, 0.60, 0.22, 1),
		Color(0.22, 0.50, 0.18, 1)]
	for i in range(6):
		var a := -PI * 0.85 + float(i) * PI * 0.34
		var tip := c + Vector2(cos(a) * 34, -34 + sin(a) * 22)
		var side := Vector2(-sin(a), cos(a)) * 7.0
		var mid := c + Vector2(cos(a) * 18, -34 + sin(a) * 12)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(-2, -34), mid + side, tip, mid - side,
		]), leaf_cols[i % 3])
		draw_line(c + Vector2(0, -34), tip, Color(0.85, 0.85, 0.55, 0.7), 1.0)

func _draw_food_cart(c: Vector2) -> void:
	_draw_ellipse_shadow(c + Vector2(0, 14), 30, 7)
	# Than xe go + mai hien ke soc.
	draw_rect(Rect2(c + Vector2(-26, -6), Vector2(52, 18)), Color(0.55, 0.38, 0.22, 1))
	draw_rect(Rect2(c + Vector2(-26, -6), Vector2(52, 4)), Color(0.65, 0.48, 0.28, 1))
	for k in range(4):
		var col := Color(0.80, 0.25, 0.20, 1) if k % 2 == 0 else Color(0.98, 0.95, 0.88, 1)
		draw_rect(Rect2(c + Vector2(-28 + k * 14, -18), Vector2(14, 12)), col)
	draw_rect(Rect2(c + Vector2(-28, -18), Vector2(56, 3)), Color(0.45, 0.30, 0.16, 1))
	# 2 banh xe.
	for wx in [-18.0, 18.0]:
		draw_arc(c + Vector2(wx, 14), 6, 0, TAU, 12, Color(0.12, 0.12, 0.12, 1), 2.5)
	# Noi pho + khoi bep bay (dong theo _t).
	var pot := c + Vector2(-8, -24)
	draw_arc(pot, 7, 0, PI, 10, Color(0.25, 0.25, 0.28, 1), 2.0)
	draw_rect(Rect2(pot + Vector2(-7, -9), Vector2(14, 9)), Color(0.35, 0.35, 0.38, 1))
	for i in range(3):
		var ph := fmod(_t * 22.0 + float(i) * 15.0, 45.0)
		var alpha := 0.35 * (1.0 - ph / 45.0)
		draw_circle(pot + Vector2(sin(_t * 2.0 + float(i) * 2.0) * 4.0, -12 - ph),
			3.0 + ph * 0.12, Color(1, 1, 1, alpha))
	# Gio banh + rau tren xe.
	draw_arc(c + Vector2(14, -8), 7, 0, PI, 10, Color(0.65, 0.48, 0.28, 1), 2.0)
	draw_circle(Vector2(c.x + 11, c.y - 11), 2.5, Color(0.95, 0.75, 0.2, 1))
	draw_circle(Vector2(c.x + 17, c.y - 12), 2.5, Color(0.90, 0.45, 0.15, 1))

func _draw_stools(c: Vector2) -> void:
	# Ban nhua + ghe dua + ly ca phe sua da.
	_draw_ellipse_shadow(c + Vector2(0, 8), 24, 5)
	draw_circle(c + Vector2(0, 0), 12, Color(0.25, 0.55, 0.75, 1))
	draw_rect(Rect2(c + Vector2(-2, 0), Vector2(4, 8)), Color(0.20, 0.45, 0.65, 1))
	for sx in [-20.0, 20.0]:
		var col := Color(0.85, 0.25, 0.25, 1) if sx < 0 else Color(0.25, 0.55, 0.75, 1)
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(sx - 7, 4), c + Vector2(sx + 7, 4),
			c + Vector2(sx + 5, 10), c + Vector2(sx - 5, 10),
		]), col)
	# 2 ly ca phe sua da tren ban.
	for lx in [-4.0, 4.0]:
		draw_rect(Rect2(c + Vector2(lx - 2, -10), Vector2(4, 8)), Color(0.95, 0.95, 0.9, 0.9))
		draw_rect(Rect2(c + Vector2(lx - 2, -6), Vector2(4, 4)), Color(0.55, 0.35, 0.18, 1))
		draw_line(c + Vector2(lx + 1, -12), c + Vector2(lx + 3, -15), Color(0.9, 0.3, 0.3, 1), 1.0)

func _draw_pushcart(c: Vector2) -> void:
	# Xe day hang rong: thung go + banh lon + rau cu tren xe.
	_draw_ellipse_shadow(c + Vector2(0, 12), 26, 6)
	draw_rect(Rect2(c + Vector2(-24, -8), Vector2(44, 16)), Color(0.55, 0.38, 0.22, 1))
	draw_rect(Rect2(c + Vector2(-24, -8), Vector2(44, 4)), Color(0.65, 0.48, 0.28, 1))
	draw_arc(c + Vector2(-14, 10), 7, 0, TAU, 12, Color(0.12, 0.12, 0.12, 1), 2.5)
	draw_arc(c + Vector2(12, 10), 7, 0, TAU, 12, Color(0.12, 0.12, 0.12, 1), 2.5)
	draw_line(c + Vector2(20, -6), c + Vector2(28, -14), Color(0.35, 0.25, 0.16, 1), 2.5)
	draw_line(c + Vector2(20, 0), c + Vector2(28, -8), Color(0.35, 0.25, 0.16, 1), 2.0)
	for k in range(3):
		var bx := c.x - 16 + k * 14
		draw_circle(Vector2(bx, c.y - 11), 4.0, [Color(0.35, 0.65, 0.25, 1), Color(0.90, 0.45, 0.15, 1), Color(0.95, 0.75, 0.2, 1)][k])
		draw_circle(Vector2(bx + 4, c.y - 13), 3.0, [Color(0.90, 0.45, 0.15, 1), Color(0.95, 0.75, 0.2, 1), Color(0.35, 0.65, 0.25, 1)][k])

func _draw_pots(c: Vector2) -> void:
	# Cum 3 chau cay goc duong.
	_draw_ellipse_shadow(c + Vector2(0, 8), 22, 5)
	var cols := [Color(0.30, 0.50, 0.22, 1), Color(0.35, 0.55, 0.25, 1), Color(0.28, 0.48, 0.22, 1)]
	for k in range(3):
		var px := c.x - 14 + k * 14
		var py := c.y + (0 if k != 1 else -4)
		draw_colored_polygon(PackedVector2Array([
			Vector2(px - 7, py), Vector2(px + 7, py),
			Vector2(px + 5, py + 9), Vector2(px - 5, py + 9),
		]), Color(0.70, 0.40, 0.25, 1))
		draw_circle(Vector2(px, py - 5), 7.0, cols[k])
		draw_circle(Vector2(px - 5, py - 1), 5.0, cols[(k + 1) % 3])
		if k == 1:
			draw_circle(Vector2(px + 2, py - 9), 3.0, Color(0.85, 0.3, 0.3, 1))

func _draw_bicycle(c: Vector2) -> void:
	# Xe dap dung nghieng via he: 2 banh + khung + ghi-dong + yen.
	_draw_ellipse_shadow(c + Vector2(0, 10), 24, 5)
	draw_arc(c + Vector2(-12, 4), 8, 0, TAU, 14, Color(0.15, 0.15, 0.15, 1), 2.0)
	draw_arc(c + Vector2(12, 4), 8, 0, TAU, 14, Color(0.15, 0.15, 0.15, 1), 2.0)
	draw_line(c + Vector2(-12, 4), c + Vector2(0, -6), Color(0.75, 0.2, 0.2, 1), 2.5)
	draw_line(c + Vector2(12, 4), c + Vector2(0, -6), Color(0.75, 0.2, 0.2, 1), 2.5)
	draw_line(c + Vector2(-12, 4), c + Vector2(2, -10), Color(0.75, 0.2, 0.2, 1), 2.0)
	draw_line(c + Vector2(12, 4), c + Vector2(2, -10), Color(0.75, 0.2, 0.2, 1), 2.0)
	draw_line(c + Vector2(2, -10), c + Vector2(8, -14), Color(0.15, 0.15, 0.15, 1), 2.0)
	draw_line(c + Vector2(2, -10), c + Vector2(-4, -12), Color(0.15, 0.15, 0.15, 1), 2.5)
	draw_rect(Rect2(c + Vector2(-14, -2), Vector2(10, 7)), Color(0.55, 0.42, 0.25, 1))

func _draw_baskets(c: Vector2) -> void:
	# Chong 3 gio hang (rau/cu) ben via he.
	_draw_ellipse_shadow(c + Vector2(0, 8), 20, 5)
	var cols := [Color(0.35, 0.65, 0.25, 1), Color(0.90, 0.45, 0.15, 1), Color(0.95, 0.75, 0.2, 1)]
	for k in range(3):
		var bx := c.x - 12 + k * 12
		var by := c.y + (2 if k != 1 else -4)
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx - 8, by), Vector2(bx + 8, by),
			Vector2(bx + 6, by + 8), Vector2(bx - 6, by + 8),
		]), Color(0.62, 0.48, 0.28, 1))
		draw_circle(Vector2(bx - 3, by - 3), 3.5, cols[k])
		draw_circle(Vector2(bx + 3, by - 3), 3.5, cols[(k + 1) % 3])

func _draw_lantern(c: Vector2) -> void:
	# Cot + den long do treo.
	_draw_ellipse_shadow(c + Vector2(0, 10), 10, 3)
	draw_rect(Rect2(c + Vector2(-2, -44), Vector2(4, 54)), Color(0.30, 0.22, 0.16, 1))
	draw_line(c + Vector2(-2, -44), c + Vector2(10, -44), Color(0.30, 0.22, 0.16, 1), 2.0)
	draw_line(c + Vector2(10, -44), c + Vector2(10, -36), Color(0.6, 0.5, 0.2, 1), 1.0)
	draw_circle(c + Vector2(10, -28), 8, Color(0.85, 0.20, 0.15, 1))
	draw_rect(Rect2(c + Vector2(7, -37), Vector2(6, 3)), Color(0.95, 0.75, 0.2, 1))
	draw_rect(Rect2(c + Vector2(7, -21), Vector2(6, 3)), Color(0.95, 0.75, 0.2, 1))
	draw_line(c + Vector2(10, -18), c + Vector2(10, -12), Color(0.95, 0.75, 0.2, 1), 1.5)
