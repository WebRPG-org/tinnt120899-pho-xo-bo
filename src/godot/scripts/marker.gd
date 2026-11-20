class_name Marker
extends Node2D
## Marker — Diem tuong tac tren ban do iso: NPC / hotspot / goc che tao / cua.
## NPC ve bang CharacterSprite (chibi Viet, co mat/toc/tay/chan/bong do,
## lac nhe khi dung yen) thay cho hinh chu nhat placeholder.
## Hotspot nhap nhay kieu Nadia: sao vang + hao quang + tia lanh.
## Nhan ten co nen sang + vien de doc tren moi nen (khong chu tran).

var event_data: Dictionary = {}
var font: Font = null
var label_layer: CanvasLayer = null  # Lop nhan rieng (Main tao): nhan
	# luon ve TREN nhan vat + HUD che, khong bi y-sort che mat nua.
var _pulse := 0.0
var _sprite: CharacterSprite = null
var _label_style: StyleBoxFlat = null
var _label: Label = null  # Nhan Control tren CanvasLayer (neu co).

const NPC_PARITY_OFFSET := 40.0
# HUD chiem 252px tren cung man hinh (panel 16..252); nhan khong duoc
# vuot qua day (cong 16px cach) — truoc day chi kep theo vung nhin
# nen nhan "Goc Che Tao" van chui duoi HUD (20/11 10:30).
const HUD_BOTTOM_SCREEN := 268.0
# Cach mep toi thieu ~20px man hinh o zoom 1.6 (13 world units).
const EDGE_MARGIN_WORLD := 13.0

const NPC_STYLE := {
	"co-tu": {"shirt": Color(0.56, 0.27, 0.68, 1), "hair_style": "bui", "texture": "res://art/char_cotu.png"},
	"ban-than": {"shirt": Color(0.25, 0.65, 0.35, 1), "hair_style": "ngan", "texture": "res://art/char_banthan.png"},
	"chi-le": {"shirt": Color(0.90, 0.45, 0.13, 1), "hair_style": "dai", "texture": "res://art/char_chile.png"},
	"anh-hai": {"shirt": Color(0.09, 0.63, 0.52, 1), "hair_style": "ngan", "texture": "res://art/char_anhhai.png"},
}

func _ready() -> void:
	_label_style = StyleBoxFlat.new()
	_label_style.bg_color = Color(1.0, 0.97, 0.88, 0.92)
	_label_style.corner_radius_top_left = 6
	_label_style.corner_radius_top_right = 6
	_label_style.corner_radius_bottom_left = 6
	_label_style.corner_radius_bottom_right = 6
	_label_style.border_color = Color(0.85, 0.68, 0.35, 1)
	_label_style.set_border_width_all(1)
	_label_style.content_margin_left = 10
	_label_style.content_margin_right = 10
	_label_style.content_margin_top = 4
	_label_style.content_margin_bottom = 4
	if String(event_data.get("kind", "")) == "npc":
		var cfg: Dictionary = NPC_STYLE.get(String(event_data.get("id", "")),
			{"shirt": Color(0.5, 0.5, 0.5, 1), "hair_style": "ngan"})
		_sprite = CharacterSprite.new()
		_sprite.setup(cfg)
		add_child(_sprite)
	# Nhan tren CanvasLayer rieng (layer 1, duoi HUD): Control o toa do
	# man hinh, luon nam tren moi Node2D cua the gioi (nhan vat, nha,
	# troi) — nhan khong bao gio bi nhan vat che nua. Khong co lop
	# thi fallback ve _draw_name() cu (ve trong _draw cua marker).
	if label_layer != null and font != null and String(event_data.get("name", "")) != "":
		_label = Label.new()
		_label.text = String(event_data.get("name", ""))
		_label.add_theme_font_override("font", font)
		_label.add_theme_font_size_override("font_size", 32)  # 20 world * zoom 1.6.
		_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.08, 1))
		_label.add_theme_stylebox_override("normal", _label_style)
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_label.visible = false
		label_layer.add_child(_label)
		tree_exited.connect(_on_tree_exited)
	queue_redraw()

func _on_tree_exited() -> void:
	if _label != null and is_instance_valid(_label):
		_label.queue_free()
		_label = null

func _process(delta: float) -> void:
	_pulse += delta
	# Ve lai moi frame: nhan kẹp theo camera (khi camera truot theo
	# nguoi choi, nhan o ria phai dich theo — ve 1 lan luc tao thi
	# nhan bi cat o mep man hinh).
	queue_redraw()
	_update_label()

func _draw() -> void:
	var kind := String(event_data.get("kind", ""))
	match kind:
		"hotspot":
			_draw_hotspot()
		"craft":
			_draw_craft()
		"door":
			_draw_door()
	if _label == null:
		_draw_name()

## Hinh chu nhat cua nhan TREN MAN HINH (toa do pixel 720x1280),
## sau khi kep trong vung nhin thay cua camera, tru vung HUD tren
## cung va cach mep 16px. Test dung de kiem tra nhan khong bi cat /
## che. Rect2() rong = nhan an (diem neo ngoai man hinh).
func label_screen_rect() -> Rect2:
	if _label == null:
		return Rect2()
	var wr := label_rect()
	if wr.size == Vector2.ZERO:
		return Rect2()
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return Rect2()
	# label_rect() kep theo the gioi; doi sang man hinh: tam X giu
	# nguyen, Y giu nguyen (chi doi don vi) — nhan 32px cao 38px.
	var ct := get_viewport().get_canvas_transform()
	var sp: Vector2 = ct * (global_position + wr.position)
	var text := String(event_data.get("name", ""))
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	var w := tw + 20.0
	var h := 38.0
	var pos := Vector2(sp.x + (wr.size.x * cam.zoom.x - w) / 2.0, sp.y + (wr.size.y * cam.zoom.y - h) / 2.0)
	pos.x = clampf(pos.x, 16.0, 720.0 - 16.0 - w)
	pos.y = clampf(pos.y, HUD_BOTTOM_SCREEN, 1280.0 - 16.0 - h)
	return Rect2(pos, Vector2(w, h))

func _update_label() -> void:
	if _label == null:
		return
	var r := label_screen_rect()
	if r.size == Vector2.ZERO:
		_label.visible = false
		return
	_label.visible = true
	_label.position = r.position
	_label.size = r.size

## Hinh chu nhat cua nhan (toa do cuc bo) sau khi da kep trong vung
## nhin thay cua camera, tru vung HUD tren cung va cach mep ~20px
## man hinh. Test dung de kiem tra nhan khong bi cat / che.
func label_rect() -> Rect2:
	if font == null:
		return Rect2()
	var text := String(event_data.get("name", ""))
	if text == "":
		return Rect2()
	# Nhan cua / hotspot dat DUOI bieu tuong (+24), goc che tao dat
	# TREN (-120) de khong chong nhan NPC dat tren (-84/-124) khi
	# 2 diem ke o (vd "Cua ra Cho Dau Moi" vs "Ban Than" o (5,4)/(3,5)),
	# va khong roi vao cho nguoi choi dung (goc che tao dat duoi se
	# bi nguoi choi spawn (4,5) che mat).
	var kind := String(event_data.get("kind", ""))
	# Nhan cua/goc che tao dat DUOI bieu tuong (+24, nhu hotspot):
	# dat tren (-120) se chong nhan NPC ke ben (vd "Cua ra Cho Dau
	# Moi" chong "Ban Than" o (5,4)/(3,5), vong 2 art pass).
	# Nhan hotspot dat DUOI sao (+24) thay vi tren — sao hotspot o
	# cung do cao voi nhan NPC nen de tren se chong nhau.
	var top := -120.0 if kind == "craft" else (24.0 if kind == "hotspot" else -144.0)
	# Nhan NPC o -144 (khong phai -84 cu): nhan vat anh ve tay cao
	# 104px, dau o -104 — nhan phai nam tren dau, cach 14px, khong
	# de len toc. Goc che tao -120 giu nguyen (tren bieu tuong).
	# Goc che tao dat TREN (-120): dat duoi se roi dung cho nguoi choi
	# spawn (4,5) — nhan bi nguoi choi che mat (vong 3).
	# Cua ra dat DUOI bieu tuong (+70, thap hon hotspot +24) de nhan
	# khong bi Co Tu (8,6) dung ke che mat chu "Đầu" (vong 4: +44
	# van bi chan Co Tu che vi chu nam dung tam chan cua Co Tu).
	if kind == "door":
		top = 70.0
	# Nhan NPC ke o chong nhau (vd "Ban Tro" vs "Co Tu"): le cao nhan
	# theo chan/le cua (tile.x + tile.y) — 2 o ke nhau luon khac chan/le
	# nen nhan lech nhau 40px doc, khong chong nua.
	if kind == "npc" and event_data.has("tile"):
		var t: Array = event_data["tile"]
		if (int(t[0]) + int(t[1])) % 2 == 1:
			top -= NPC_PARITY_OFFSET
	var size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	var rect := Rect2(-size.x / 2.0 - 8, top, size.x + 16, 26)
	# Kep nhan trong man hinh hien thi (theo camera that, khong dung
	# canvas transform — luc tao marker transform chua co camera nen
	# kep sai va nhan o ria map (vd "Cua ra Cho Dau Moi") bi cat).
	# Meo tren KHONG phai mep man hinh ma la duoi HUD (268px man hinh):
	# nhan nao vuot qua day se bi panel HUD che mat nua tren.
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var half := get_viewport_rect().size / (2.0 * cam.zoom)
		var center := cam.get_screen_center_position()
		var vis_min := center - half
		var vis_max := center + half
		var top_min := vis_min.y + HUD_BOTTOM_SCREEN / cam.zoom.y
		var gp := global_position
		# Nhan cua diem ngoai man hinh: AN nhan (truoc day kep dua nhan
		# vao trong man hinh trong khi sao/NPC o ngoai — nhan troi khong
		# co diem neo, vd hs-tro-toi o (10,3) khi moi vao game).
		if gp.x < vis_min.x - 20 or gp.x > vis_max.x + 20 or gp.y < vis_min.y - 20 or gp.y > vis_max.y + 20:
			return Rect2()
		var wrect := Rect2(gp + rect.position, rect.size)
		var shift := Vector2.ZERO
		if wrect.position.x < vis_min.x + EDGE_MARGIN_WORLD:
			shift.x = vis_min.x + EDGE_MARGIN_WORLD - wrect.position.x
		elif wrect.end.x > vis_max.x - EDGE_MARGIN_WORLD:
			shift.x = vis_max.x - EDGE_MARGIN_WORLD - wrect.end.x
		if wrect.position.y < top_min:
			shift.y = top_min - wrect.position.y
		elif wrect.end.y > vis_max.y - EDGE_MARGIN_WORLD:
			shift.y = vis_max.y - EDGE_MARGIN_WORLD - wrect.end.y
		rect.position += shift
	return rect

func _draw_name() -> void:
	var rect := label_rect()
	if rect.size == Vector2.ZERO:
		return
	draw_style_box(_label_style, rect)
	draw_string(font, Vector2(rect.position.x + 8, rect.position.y + 20),
		String(event_data.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 20,
		Color(0.15, 0.12, 0.08, 1))

func _mini_sparkle(pos: Vector2, r: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -r), pos + Vector2(r * 0.3, -r * 0.3),
		pos + Vector2(r, 0), pos + Vector2(r * 0.3, r * 0.3),
		pos + Vector2(0, r), pos + Vector2(-r * 0.3, r * 0.3),
		pos + Vector2(-r, 0), pos + Vector2(-r * 0.3, -r * 0.3),
	]), col)

func _draw_hotspot() -> void:
	# Sao lap lanh kieu Nadia: 4 canh dai, xanh = thuong, cam = thuong
	# tot (mau lay tu PxbHotspot.sparkle_color theo rarity). Khong bien
	# mat khi chua nhat — hotspot "cho nguoi choi" (scene-study §1.2).
	var col := Color.html(PxbHotspot.sparkle_color(event_data))
	var s := 1.0 + 0.18 * sin(_pulse * 3.0)
	var r := 17.0 * s
	# Bong sang mem duoi dat + hao quang.
	draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.0, 0.33))
	draw_circle(Vector2.ZERO, 20, Color(col.r, col.g, col.b, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(Vector2(0, 0), r + 10.0, Color(col.r, col.g, col.b, 0.15))
	# Sao 4 canh lon (>= 44pt cham duoc tren mobile).
	_mini_sparkle(Vector2.ZERO, r * 1.5, col)
	draw_circle(Vector2(0, 0), 4.5, Color(1, 1, 1, 0.95))
	# Tia lanh nho xoay quanh.
	for i in range(3):
		var a := _pulse * 1.5 + float(i) * TAU / 3.0
		var p := Vector2(cos(a), sin(a)) * (r + 13.0)
		_mini_sparkle(p, 2.5 + sin(_pulse * 4.0 + float(i) * 2.0) * 1.0,
			Color(1.0, 0.95, 0.6, 0.9))

func _draw_craft() -> void:
	# Goc Che Tao kieu Nadia (Native Shrine trong phong tro): ban go cu,
	# den ban vang, hop dung cu, van go dua tuong, khung sat goc phong.
	draw_set_transform(Vector2(0, 14), 0.0, Vector2(1.0, 0.33))
	draw_circle(Vector2.ZERO, 22, Color(0, 0, 0, 0.20))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Van go dua tuong (2 tam nghieng).
	draw_set_transform(Vector2(-20, -8), -0.25, Vector2.ONE)
	draw_rect(Rect2(-3, -16, 6, 32), Color(0.70, 0.55, 0.35, 1))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_set_transform(Vector2(22, -6), 0.3, Vector2.ONE)
	draw_rect(Rect2(-3, -14, 6, 28), Color(0.65, 0.50, 0.32, 1))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Khung sat dung goc.
	draw_rect(Rect2(14, -26, 3, 26), Color(0.45, 0.45, 0.48, 1))
	draw_rect(Rect2(14, -26, 10, 3), Color(0.45, 0.45, 0.48, 1))
	# Ban che tao: mat ban + chan + do nghe tren ban.
	draw_rect(Rect2(-18, -12, 36, 22), Color(0.55, 0.38, 0.22, 1))
	draw_rect(Rect2(-22, -18, 44, 8), Color(0.65, 0.48, 0.28, 1))
	draw_rect(Rect2(-16, 10, 5, 8), Color(0.45, 0.30, 0.18, 1))
	draw_rect(Rect2(11, 10, 5, 8), Color(0.45, 0.30, 0.18, 1))
	# Den ban vang: hao quang + chop.
	draw_circle(Vector2(0, -28), 12, Color(1.0, 0.85, 0.4, 0.20))
	draw_line(Vector2(0, -18), Vector2(0, -30), Color(0.3, 0.25, 0.2, 1), 2.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7, -30), Vector2(7, -30), Vector2(0, -38)]),
		Color(0.95, 0.75, 0.25, 1))
	draw_circle(Vector2(0, -29), 2.5, Color(1.0, 0.95, 0.6, 1))
	# Do nghe tren ban: bua + hop dung cu.
	draw_circle(Vector2(-10, -20), 3.5, Color(0.85, 0.85, 0.88, 1))
	draw_circle(Vector2(9, -20), 3.5, Color(0.95, 0.75, 0.1, 1))
	draw_rect(Rect2(2, -22, 8, 4), Color(0.35, 0.55, 0.75, 1))

func _draw_door() -> void:
	# Cua di khu khac: khung cua go + mai che + o cua sang + den long.
	draw_set_transform(Vector2(0, 16), 0.0, Vector2(1.0, 0.33))
	draw_circle(Vector2.ZERO, 20, Color(0, 0, 0, 0.20))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# Mai che ke soc.
	for k in range(3):
		var col := Color(0.80, 0.25, 0.20, 1) if k % 2 == 0 else Color(0.98, 0.95, 0.88, 1)
		draw_rect(Rect2(-21 + k * 14, -46, 14, 8), col)
	draw_rect(Rect2(-21, -46, 42, 3), Color(0.45, 0.30, 0.16, 1))
	# Khung cua + o cua sang am.
	draw_rect(Rect2(-16, -40, 32, 56), Color(0.45, 0.30, 0.16, 1))
	draw_rect(Rect2(-12, -36, 24, 52), Color(0.95, 0.88, 0.65, 1))
	draw_rect(Rect2(-12, -36, 24, 52), Color(0.55, 0.40, 0.20, 1), false, 1.5)
	draw_line(Vector2(0, -36), Vector2(0, 16), Color(0.55, 0.40, 0.20, 1), 1.5)
	# Tay nam + bac them.
	draw_circle(Vector2(-8, -8), 2.0, Color(0.85, 0.65, 0.2, 1))
	draw_circle(Vector2(8, -8), 2.0, Color(0.85, 0.65, 0.2, 1))
	draw_rect(Rect2(-19, 16, 38, 4), Color(0.65, 0.60, 0.52, 1))
	# Den long do treo ben cua.
	draw_line(Vector2(20, -44), Vector2(20, -36), Color(0.6, 0.5, 0.2, 1), 1.0)
	draw_circle(Vector2(20, -32), 5, Color(0.85, 0.20, 0.15, 1))
	draw_rect(Rect2(18, -38, 4, 2), Color(0.95, 0.75, 0.2, 1))
