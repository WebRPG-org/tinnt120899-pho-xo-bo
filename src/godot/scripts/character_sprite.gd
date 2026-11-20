class_name CharacterSprite
extends Node2D
## CharacterSprite — Nhan vat chibi Viet (~1:3, dau to) ve bang code.
## Thay the hinh chu nhat + dau tron placeholder cua player.gd / marker.gd.
## Co mat, toc, tay, chan, bong do, animation di (chan/tay danh + nhun
## nguoi) va chop mat. Goc toa do o chan (giua 2 ban chan), cao ~56px,
## vua o tile iso 64x32. Khong dung asset ngoai — ve bang code de khong
## vuong ban quyen va khong phu thuoc file nhi phan.

var shirt := Color(0.18, 0.44, 0.69, 1)
var pants := Color(0.16, 0.18, 0.24, 1)
var skin := Color(0.96, 0.82, 0.66, 1)
var hair_color := Color(0.12, 0.10, 0.10, 1)
var hair_style := "ngan"  # ngan | dai | bui | non (non la)
var walk_phase := 0.0
var moving := false
var facing := 1  # 1 = phai, -1 = trai
var is_player := false  # Nguoi choi: vong vang duoi chan de nhan ra.

var _t := 0.0
var _body_style: StyleBoxFlat = null

func setup(cfg: Dictionary) -> void:
	shirt = cfg.get("shirt", shirt)
	pants = cfg.get("pants", pants)
	skin = cfg.get("skin", skin)
	hair_color = cfg.get("hair", hair_color)
	hair_style = String(cfg.get("hair_style", hair_style))
	is_player = bool(cfg.get("player", false))
	_body_style = StyleBoxFlat.new()
	_body_style.bg_color = shirt
	_body_style.corner_radius_top_left = 6
	_body_style.corner_radius_top_right = 6
	_body_style.corner_radius_bottom_left = 4
	_body_style.corner_radius_bottom_right = 4
	_body_style.border_color = shirt.darkened(0.35)
	_body_style.set_border_width_all(1)
	queue_redraw()

func _process(delta: float) -> void:
	_t += delta
	if moving:
		walk_phase += delta * 10.0
	queue_redraw()

func _draw() -> void:
	# Huong mat: lat ngang khi quay trai (bong doi xung nen khong anh huong).
	scale.x = float(facing)
	var bob := 0.0
	if moving:
		bob = -absf(sin(walk_phase)) * 3.0
	else:
		bob = -sin(_t * 2.0) * 1.0
	# Bong do duoi chan (mo dan khi nhay len).
	var shadow_scale := 1.0 + bob * 0.03
	draw_set_transform(Vector2(0, 3), 0.0, Vector2(0.33 * shadow_scale, 0.33 * shadow_scale))
	draw_circle(Vector2.ZERO, 34, Color(0, 0, 0, 0.28))
	if is_player:
		draw_arc(Vector2.ZERO, 40, 0, TAU, 24, Color(1.0, 0.8, 0.2, 0.9), 3.0)
	draw_set_transform(Vector2(0, bob), 0.0, Vector2.ONE)
	# Chan: 2 chan danh nguoc nhau khi di.
	var leg_swing := sin(walk_phase) * 4.0 if moving else 0.0
	draw_rect(Rect2(-7 + leg_swing, -11, 6, 11), pants)
	draw_rect(Rect2(1 - leg_swing, -11, 6, 11), pants)
	# Giay.
	draw_rect(Rect2(-8 + leg_swing, -3, 8, 3), Color(0.12, 0.10, 0.10, 1))
	draw_rect(Rect2(0 - leg_swing, -3, 8, 3), Color(0.12, 0.10, 0.10, 1))
	# Tay: danh nguoc chan.
	var arm_swing := -sin(walk_phase) * 3.0 if moving else 0.0
	draw_rect(Rect2(-14, -30 + arm_swing, 5, 15), shirt.darkened(0.15))
	draw_rect(Rect2(9, -30 - arm_swing, 5, 15), shirt.darkened(0.15))
	draw_circle(Vector2(-11.5, -14 + arm_swing), 2.6, skin)
	draw_circle(Vector2(11.5, -14 - arm_swing), 2.6, skin)
	# Than ao.
	if _body_style != null:
		draw_style_box(_body_style, Rect2(-11, -31, 22, 22))
	else:
		draw_rect(Rect2(-11, -31, 22, 22), shirt)
	# Co ao / khuy.
	draw_rect(Rect2(-11, -31, 22, 3), shirt.darkened(0.25))
	# Dau.
	draw_circle(Vector2(0, -40), 10, skin)
	# Toc theo kieu.
	match hair_style:
		"dai":
			_draw_hair_cap()
			draw_rect(Rect2(-11, -42, 4, 16), hair_color)
			draw_rect(Rect2(7, -42, 4, 16), hair_color)
		"bui":
			_draw_hair_cap()
			draw_circle(Vector2(0, -52), 4.5, hair_color)
		"non":
			# Non la: tam giac rom vang + quay.
			draw_colored_polygon(PackedVector2Array([
				Vector2(-13, -42), Vector2(13, -42), Vector2(0, -56)]),
				Color(0.92, 0.80, 0.45, 1))
			draw_arc(Vector2(0, -42), 13, 0, PI, 8, Color(0.75, 0.60, 0.25, 1), 1.5)
			draw_circle(Vector2(0, -40), 10, skin)
		_:
			_draw_hair_cap()
	# Mat + mieng (chop mat moi ~3s).
	var blink := fmod(_t, 3.0) < 0.12
	if blink:
		draw_line(Vector2(-5, -41), Vector2(-2, -41), Color(0.12, 0.10, 0.10, 1), 1.5)
		draw_line(Vector2(2, -41), Vector2(5, -41), Color(0.12, 0.10, 0.10, 1), 1.5)
	else:
		draw_circle(Vector2(-3.5, -41), 1.5, Color(0.12, 0.10, 0.10, 1))
		draw_circle(Vector2(3.5, -41), 1.5, Color(0.12, 0.10, 0.10, 1))
	draw_arc(Vector2(0, -37), 3.0, PI * 0.15, PI * 0.85, 8, Color(0.45, 0.20, 0.15, 1), 1.5)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_hair_cap() -> void:
	# Nua tren dau: da giac vong cung tu PI..TAU.
	var pts := PackedVector2Array()
	pts.append(Vector2(0, -40))
	for i in range(13):
		var a := PI + (PI * float(i) / 12.0)
		pts.append(Vector2(cos(a) * 10.5, -40 + sin(a) * 10.5))
	draw_colored_polygon(pts, hair_color)
