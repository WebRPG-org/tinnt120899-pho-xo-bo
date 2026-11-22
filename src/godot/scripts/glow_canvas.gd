class_name GlowCanvas
extends Node2D
## GlowCanvas — Vong 19 (22/11): anh sang cong don (ADD) that.
##
## NightGlow ve duoi lop MUL ngay/dem (CanvasLayer layer 1) nen dom
## sang bi nhan toi, phai dung mau HDR >1.0 de "xuyen" qua lop dem.
## Node nay la con cua chinh _overlay_layer, them SAU ColorRect MUL
## nen ve TREN lop nhan, dung BLEND_MODE_ADD: cong anh sang that
## vao anh cuoi — den long/cua so sang han len ro ret ma khong can
## HDR. Chi bat khung Toi (Main goi set_lit). Vi tri nguon lay tu
## NightGlow (lamps + spots, toa do THE GIOI) roi doi sang toa do
## man hinh qua camera (CanvasLayer khong theo viewport nen toa do
## ve la toa do man hinh).
##
## Vi tri trong cay: con cua _overlay_layer (layer 1), sau _daynight
## (MUL) va truoc _label_layer/_ui_layer (cung layer 1, them sau)
## => tren nen/the gioi, duoi nhan/HUD.

var lit := false
var sources: Array[Vector2] = []  # Toa do the gioi cua den/cua so.
var halo_screen_positions: Array[Vector2] = []  # Test doc duoc.
var _last_cam := Vector2.INF

func _init() -> void:
	visible = false
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = add

func set_lit(on: bool) -> void:
	# Luon gan visible (khong chi khi doi): luc dau lit=false nhung
	# visible mac dinh true — set_lit(false) lan dau se la no-op neu
	# chi gan khi doi, de node hien vo dung o khung Sang (test r19).
	lit = on
	visible = on
	queue_redraw()

func set_sources(s: Array[Vector2]) -> void:
	sources = s
	queue_redraw()

## The gioi -> man hinh (nguoc cua SkyEffects._cam_anchor).
func _world_to_screen(w: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return w
	var vp := get_viewport_rect().size
	var top_left := cam.get_screen_center_position() - vp / (2.0 * cam.zoom)
	return (w - top_left) * cam.zoom

func _process(_delta: float) -> void:
	if not lit:
		return
	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var cp := cam.get_screen_center_position()
		if cp.distance_to(_last_cam) > 2.0:
			_last_cam = cp
			queue_redraw()

func _draw() -> void:
	halo_screen_positions.clear()
	if not lit:
		return
	for s in sources:
		var sp := _world_to_screen(s)
		halo_screen_positions.append(sp)
		_draw_halo(sp, 46.0, Color(1.0, 0.72, 0.30))

## Hao quang mem: vong tron alpha giam dan ra ngoai + tam sang.
## (Cung ky thuat vong mem nhu SkyEffects._draw_soft_disc, nhung
## o day BLEND_MODE_ADD cong that vao anh cuoi nen alpha nho cung
## du sang — khong dung HDR >1.)
func _draw_halo(c: Vector2, r: float, warm: Color) -> void:
	var steps := 10
	for i in range(steps, 0, -1):
		var t := float(i) / float(steps)
		var rr := r * (1.0 + 1.4 * t)
		var a := 0.16 * (1.0 - t) + 0.01
		draw_circle(c, rr, Color(warm.r, warm.g, warm.b, a))
	draw_circle(c, r * 0.45, Color(warm.r, warm.g, warm.b, 0.55))
	draw_circle(c, r * 0.22, Color(1.0, 0.95, 0.75, 0.8))
