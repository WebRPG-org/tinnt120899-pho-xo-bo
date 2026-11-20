class_name CharacterSprite
extends Node2D
## CharacterSprite — Nhan vat kieu Nadia: ti le nguoi ro (~1:5.5, cao
## ~72px), co mat/toc/quan ao chi tiet, walk cycle (chan/tay danh
## nguoc nhau + nhun nguoi), bong mem duoi chan, dung dung tren mat
## dat. Ve bang code — khong dung asset ngoai (tranh ban quyen).
## Goc toa do o chan (giua 2 ban chan). API cu giu nguyen: setup(cfg),
## moving / facing / is_player / walk_phase.

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
	_body_style.corner_radius_top_left = 7
	_body_style.corner_radius_top_right = 7
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

func _ellipse_shadow(c: Vector2, rx: float, ry: float, alpha: float) -> void:
	draw_set_transform(c, 0.0, Vector2(1.0, ry / rx))
	draw_circle(Vector2.ZERO, rx, Color(0, 0, 0, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw() -> void:
	# Huong mat: lat ngang khi quay trai (bong doi xung nen khong anh huong).
	scale.x = float(facing)
	var bob := 0.0
	if moving:
		bob = -absf(sin(walk_phase)) * 2.5
	else:
		bob = -sin(_t * 2.0) * 0.8
	# Bong mem duoi chan (nho dan khi nhun len).
	_ellipse_shadow(Vector2(0, 3), 12.0 + bob * 0.4, 4.0, 0.28)
	if is_player:
		draw_set_transform(Vector2(0, 3), 0.0, Vector2(1.0, 0.33))
		draw_arc(Vector2.ZERO, 40, 0, TAU, 24, Color(1.0, 0.8, 0.2, 0.9), 2.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_set_transform(Vector2(0, bob), 0.0, Vector2.ONE)
	# Chan dai: 2 chan danh nguoc nhau khi di (walk cycle ro).
	var leg_swing := sin(walk_phase) * 5.0 if moving else 0.0
	var leg_lift := -absf(cos(walk_phase)) * 2.0 if moving else 0.0
	draw_rect(Rect2(-6 + leg_swing, -24 + leg_lift * 0.5, 5, 21), pants)
	draw_rect(Rect2(1 - leg_swing, -24 - leg_lift * 0.5, 5, 21), pants)
	# Giay co mui + de.
	draw_rect(Rect2(-7 + leg_swing, -3, 8, 3), Color(0.12, 0.10, 0.10, 1))
	draw_rect(Rect2(0 - leg_swing, -3, 8, 3), Color(0.12, 0.10, 0.10, 1))
	draw_rect(Rect2(-7 + leg_swing, -1, 8, 1), Color(0.95, 0.95, 0.9, 0.8))
	draw_rect(Rect2(0 - leg_swing, -1, 8, 1), Color(0.95, 0.95, 0.9, 0.8))
	# Tay: danh nguoc chan, co ban tay.
	var arm_swing := -sin(walk_phase) * 4.0 if moving else sin(_t * 2.0) * 0.8
	draw_rect(Rect2(-16, -46 + arm_swing, 5, 17), shirt.darkened(0.15))
	draw_rect(Rect2(11, -46 - arm_swing, 5, 17), shirt.darkened(0.15))
	draw_circle(Vector2(-13.5, -28 + arm_swing), 2.8, skin)
	draw_circle(Vector2(13.5, -28 - arm_swing), 2.8, skin)
	# Than ao dai: co ao, khuy, tui.
	if _body_style != null:
		draw_style_box(_body_style, Rect2(-12, -48, 24, 26))
	else:
		draw_rect(Rect2(-12, -48, 24, 26), shirt)
	draw_rect(Rect2(-12, -48, 24, 3), shirt.darkened(0.25))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-4, -48), Vector2(4, -48), Vector2(0, -43)]),
		shirt.darkened(0.35))
	for ky in [-38.0, -32.0]:
		draw_circle(Vector2(0, ky), 1.0, shirt.darkened(0.45))
	draw_rect(Rect2(4, -34, 6, 5), shirt.darkened(0.15))
	# Co.
	draw_rect(Rect2(-3, -52, 6, 5), skin)
	# Dau (ti le nguoi: dau ~1/5.5 chieu cao).
	draw_circle(Vector2(0, -59), 8, skin)
	# Toc theo kieu.
	match hair_style:
		"dai":
			_draw_hair_cap()
			# Toc dai xuong vai 2 ben.
			draw_rect(Rect2(-10, -62, 4, 22), hair_color)
			draw_rect(Rect2(6, -62, 4, 22), hair_color)
			draw_colored_polygon(PackedVector2Array([
				Vector2(-6, -66), Vector2(6, -66), Vector2(4, -60), Vector2(-4, -60)]),
				hair_color)
		"bui":
			_draw_hair_cap()
			draw_circle(Vector2(0, -70), 4.5, hair_color)
			draw_circle(Vector2(0, -70), 4.5, hair_color.darkened(0.1))
		"non":
			# Non la: tam giac rom vang + quay.
			draw_colored_polygon(PackedVector2Array([
				Vector2(-14, -60), Vector2(14, -60), Vector2(0, -76)]),
				Color(0.92, 0.80, 0.45, 1))
			draw_arc(Vector2(0, -60), 14, 0, PI, 10, Color(0.75, 0.60, 0.25, 1), 1.5)
			draw_line(Vector2(-7, -68), Vector2(7, -68), Color(0.75, 0.60, 0.25, 0.8), 1.0)
			draw_circle(Vector2(0, -59), 8, skin)
		_:
			_draw_hair_cap()
	# Mat: long may + mat + ma hong + mieng (chop mat moi ~3s).
	var blink := fmod(_t, 3.0) < 0.12
	draw_line(Vector2(-6, -63), Vector2(-2, -63.5), Color(0.12, 0.10, 0.10, 1), 1.0)
	draw_line(Vector2(2, -63.5), Vector2(6, -63), Color(0.12, 0.10, 0.10, 1), 1.0)
	if blink:
		draw_line(Vector2(-5, -60), Vector2(-2, -60), Color(0.12, 0.10, 0.10, 1), 1.2)
		draw_line(Vector2(2, -60), Vector2(5, -60), Color(0.12, 0.10, 0.10, 1), 1.2)
	else:
		draw_circle(Vector2(-3.5, -60), 1.6, Color(0.12, 0.10, 0.10, 1))
		draw_circle(Vector2(3.5, -60), 1.6, Color(0.12, 0.10, 0.10, 1))
		draw_circle(Vector2(-3.0, -60.5), 0.6, Color(1, 1, 1, 0.9))
		draw_circle(Vector2(4.0, -60.5), 0.6, Color(1, 1, 1, 0.9))
	draw_circle(Vector2(-6, -56), 1.6, Color(0.95, 0.55, 0.45, 0.5))
	draw_circle(Vector2(6, -56), 1.6, Color(0.95, 0.55, 0.45, 0.5))
	draw_arc(Vector2(0, -55), 2.5, PI * 0.15, PI * 0.85, 8, Color(0.45, 0.20, 0.15, 1), 1.2)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_hair_cap() -> void:
	# Nua tren dau + mai truoc: da giac vong cung tu PI..TAU.
	var pts := PackedVector2Array()
	pts.append(Vector2(0, -59))
	for i in range(13):
		var a := PI + (PI * float(i) / 12.0)
		pts.append(Vector2(cos(a) * 8.5, -59 + sin(a) * 8.5))
	draw_colored_polygon(pts, hair_color)
	# Mai truoc lech 1 ben.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7, -64), Vector2(2, -66), Vector2(0, -60), Vector2(-7, -60)]),
		hair_color.darkened(0.15))
