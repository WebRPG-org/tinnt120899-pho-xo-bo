class_name Marker
extends Node2D
## Marker — Diem tuong tac tren ban do iso: NPC / hotspot / goc che tao / cua.
## NPC ve bang CharacterSprite (chibi Viet, co mat/toc/tay/chan/bong do,
## lac nhe khi dung yen) thay cho hinh chu nhat placeholder.
## Hotspot nhap nhay kieu Nadia: sao vang + hao quang + tia lanh.
## Nhan ten co nen sang + vien de doc tren moi nen (khong chu tran).

var event_data: Dictionary = {}
var font: Font = null
var _pulse := 0.0
var _sprite: CharacterSprite = null
var _label_style: StyleBoxFlat = null

const NPC_STYLE := {
	"co-tu": {"shirt": Color(0.56, 0.27, 0.68, 1), "hair_style": "bui"},
	"ban-than": {"shirt": Color(0.25, 0.65, 0.35, 1), "hair_style": "ngan"},
	"chi-le": {"shirt": Color(0.90, 0.45, 0.13, 1), "hair_style": "dai"},
	"anh-hai": {"shirt": Color(0.09, 0.63, 0.52, 1), "hair_style": "ngan"},
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
	_label_style.content_margin_left = 6
	_label_style.content_margin_right = 6
	_label_style.content_margin_top = 2
	_label_style.content_margin_bottom = 2
	if String(event_data.get("kind", "")) == "npc":
		var cfg: Dictionary = NPC_STYLE.get(String(event_data.get("id", "")),
			{"shirt": Color(0.5, 0.5, 0.5, 1), "hair_style": "ngan"})
		_sprite = CharacterSprite.new()
		_sprite.setup(cfg)
		add_child(_sprite)
	queue_redraw()

func _process(delta: float) -> void:
	_pulse += delta
	# Ve lai moi frame: nhan kẹp theo camera (khi camera truot theo
	# nguoi choi, nhan o ria phai dich theo — ve 1 lan luc tao thi
	# nhan bi cat o mep man hinh).
	queue_redraw()

func _draw() -> void:
	var kind := String(event_data.get("kind", ""))
	match kind:
		"hotspot":
			_draw_hotspot()
		"craft":
			_draw_craft()
		"door":
			_draw_door()
	_draw_name()

func _draw_name() -> void:
	if font == null:
		return
	var text := String(event_data.get("name", ""))
	if text == "":
		return
	# Nhan cua / goc che tao dat cao hon nhan NPC 86px de khong chong
	# nhau khi 2 diem ke o (vd "Ban Than" vs "Cua ra Cho Dau Moi").
	var kind := String(event_data.get("kind", ""))
	# Nhan cua/goc che tao dat cao (-170) de khong chong nhan NPC
	# (-84/-114) khi 2 diem ke o (vd "Hem tro buoi toi" vs "Co Tu").
	# Nhan hotspot dat DUOI sao (+24) thay vi tren — sao hotspot o
	# cung do cao voi nhan NPC nen de tren se chong nhau.
	var top := -170.0 if kind == "door" or kind == "craft" else -84.0
	if kind == "hotspot":
		top = 24.0
	# Nhan NPC ke o chong nhau (vd "Ban Tro" vs "Co Tu"): le cao nhan
	# theo chan/le cua (tile.x + tile.y) — 2 o ke nhau luon khac chan/le
	# nen nhan lech nhau 30px doc, khong chong nua.
	if kind == "npc" and event_data.has("tile"):
		var t: Array = event_data["tile"]
		if (int(t[0]) + int(t[1])) % 2 == 1:
			top -= 30.0
	var size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	var rect := Rect2(-size.x / 2.0 - 8, top, size.x + 16, 26)
	# Kep nhan trong man hinh hien thi (theo camera that, khong dung
	# canvas transform — luc tao marker transform chua co camera nen
	# kep sai va nhan o ria map (vd "Cua ra Cho Dau Moi") bi cat).
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var half := get_viewport_rect().size / (2.0 * cam.zoom)
		var center := cam.get_screen_center_position()
		var vis_min := center - half
		var vis_max := center + half
		var gp := global_position
		var wrect := Rect2(gp + rect.position, rect.size)
		var shift := Vector2.ZERO
		if wrect.position.x < vis_min.x + 8:
			shift.x = vis_min.x + 8 - wrect.position.x
		elif wrect.end.x > vis_max.x - 8:
			shift.x = vis_max.x - 8 - wrect.end.x
		if wrect.position.y < vis_min.y + 8:
			shift.y = vis_min.y + 8 - wrect.position.y
		elif wrect.end.y > vis_max.y - 8:
			shift.y = vis_max.y - 8 - wrect.end.y
		rect.position += shift
	draw_style_box(_label_style, rect)
	draw_string(font, Vector2(rect.position.x + 8, rect.position.y + 20), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(0.15, 0.12, 0.08, 1))

func _draw_hotspot() -> void:
	var s := 1.0 + 0.18 * sin(_pulse * 4.0)
	var r := 15.0 * s
	var gold := Color(0.88, 0.66, 0.0, 1)
	# Hao quang mo.
	draw_circle(Vector2(0, 0), r + 8.0, Color(1.0, 0.8, 0.2, 0.18))
	# Sao 8 canh.
	var pts := PackedVector2Array([
		Vector2(0, -r), Vector2(r * 0.45, -r * 0.45), Vector2(r, 0),
		Vector2(r * 0.45, r * 0.45), Vector2(0, r),
		Vector2(-r * 0.45, r * 0.45), Vector2(-r, 0), Vector2(-r * 0.45, -r * 0.45),
	])
	draw_colored_polygon(pts, gold)
	draw_circle(Vector2(0, 0), 4.0, Color(1, 1, 1, 0.9))
	# Tia lanh xoay quanh.
	for i in range(4):
		var a := _pulse * 1.5 + float(i) * PI / 2.0
		var p := Vector2(cos(a), sin(a)) * (r + 12.0)
		draw_circle(p, 2.0 + sin(_pulse * 4.0 + float(i)) * 0.8, Color(1, 0.9, 0.4, 0.9))
	# Bong "!" goi tuong tac kieu Nadia.
	draw_circle(Vector2(16, -30), 9, Color(0.95, 0.75, 0.1, 1))
	if font != null:
		draw_string(font, Vector2(12, -23), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.2, 0.1, 0.0, 1))

func _draw_craft() -> void:
	# Ban che tao: mat ban + chan + do nghe tren ban.
	draw_rect(Rect2(-16, -10, 32, 22), Color(0.55, 0.38, 0.22, 1))
	draw_rect(Rect2(-20, -16, 40, 8), Color(0.65, 0.48, 0.28, 1))
	draw_rect(Rect2(-14, 12, 5, 8), Color(0.45, 0.30, 0.18, 1))
	draw_rect(Rect2(9, 12, 5, 8), Color(0.45, 0.30, 0.18, 1))
	draw_circle(Vector2(-8, -20), 4, Color(0.85, 0.85, 0.88, 1))
	draw_circle(Vector2(8, -20), 4, Color(0.95, 0.75, 0.1, 1))
	draw_circle(Vector2(0, -26), 8, Color(0.95, 0.75, 0.1, 1))

func _draw_door() -> void:
	# Cua di khu khac: khung cua + mai tam giac + o cua sang.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20, -28), Vector2(20, -28), Vector2(0, -44)]),
		Color(0.72, 0.27, 0.18, 1))
	draw_rect(Rect2(-16, -30, 32, 44), Color(0.20, 0.55, 0.35, 1))
	draw_rect(Rect2(-8, -14, 16, 28), Color(0.85, 0.95, 0.9, 1))
	draw_circle(Vector2(10, 0), 2, Color(0.95, 0.75, 0.1, 1))
