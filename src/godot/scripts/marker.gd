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
var _base_name := ""  # Ten goc tu event_data (vd "Hem tro buoi toi").
var _frame_name := ""  # Khung hien tai ("Sang"/"Chieu"/"Toi") — Main dat.
var _player_on := false  # Nguoi choi dang dung tren o hotspot nay.
var label_override := Rect2()  # Main dat sau khi chong-chong o khong
	# gian man hinh (vong 4, 20/11 14:00): rong = khong dung, tinh
	# nhu cu bang label_screen_rect().

# Nhan NPC trong the gioi (Claude (b), vong 15, 21/11): Label la con
# cua Marker (khong phai Control tren CanvasLayer) — di theo NPC khi
# camera cuon/zoom, khong loi lung tren troi. Chi hien khi nguoi
# choi o gan (Main tinh khoang cach theo o, xem set_label_near).
const NPC_LABEL_TOP := -170.0  # Tren dau anh 104px, cach ~40 world.
const LABEL_NEAR_TILES := 5  # Manhattan <= 5 o moi hien nhan NPC.
var _label_near := true  # Main dat moi frame theo khoang cach.
var _label_world := false  # True: _label la con cua Marker (NPC).

# HUD gon (panel cao thuc te ~157px do min-size cua noi dung, day
# panel y ~173) nen nhan chi can kep duoi y=190px man hinh (truoc
# day HUD cao 236px nen kep 268px).
const HUD_BOTTOM_SCREEN := 190.0
# Cach mep toi thieu ~20px man hinh o zoom 1.6 (13 world units).
const EDGE_MARGIN_WORLD := 13.0

const NPC_STYLE := {
	"co-tu": {"shirt": Color(0.56, 0.27, 0.68, 1), "hair_style": "bui", "texture": "res://art/char_cotu.png",
		"frames": ["res://art/walk_cotu_f0.png", "res://art/walk_cotu_f1.png", "res://art/walk_cotu_f2.png", "res://art/walk_cotu_f3.png", "res://art/walk_cotu_f4.png", "res://art/walk_cotu_f5.png"]},
	"ban-than": {"shirt": Color(0.25, 0.65, 0.35, 1), "hair_style": "ngan", "texture": "res://art/char_banthan.png",
		"frames": ["res://art/walk_banthan_f0.png", "res://art/walk_banthan_f1.png", "res://art/walk_banthan_f2.png", "res://art/walk_banthan_f3.png", "res://art/walk_banthan_f4.png", "res://art/walk_banthan_f5.png"]},
	"chi-le": {"shirt": Color(0.90, 0.45, 0.13, 1), "hair_style": "dai", "texture": "res://art/char_chile.png",
		"frames": ["res://art/walk_chile_f0.png", "res://art/walk_chile_f1.png", "res://art/walk_chile_f2.png", "res://art/walk_chile_f3.png", "res://art/walk_chile_f4.png", "res://art/walk_chile_f5.png"]},
	"anh-hai": {"shirt": Color(0.09, 0.63, 0.52, 1), "hair_style": "ngan", "texture": "res://art/char_anhhai.png",
		"frames": ["res://art/walk_anhhai_f0.png", "res://art/walk_anhhai_f1.png", "res://art/walk_anhhai_f2.png", "res://art/walk_anhhai_f3.png", "res://art/walk_anhhai_f4.png", "res://art/walk_anhhai_f5.png"]},
	# Vong 25 — Map003 Khu Cong Nhan: Anh Ba (cong nhan xuong, ao
	# thun xanh duong dam) + Chi Sau (ao ba ba xanh la hoa nho).
	"anh-ba": {"shirt": Color(0.16, 0.24, 0.45, 1), "hair_style": "ngan", "texture": "res://art/char_anhba.png",
		"frames": ["res://art/walk_anhba_f0.png", "res://art/walk_anhba_f1.png", "res://art/walk_anhba_f2.png", "res://art/walk_anhba_f3.png", "res://art/walk_anhba_f4.png", "res://art/walk_anhba_f5.png"]},
	"chi-sau": {"shirt": Color(0.55, 0.72, 0.55, 1), "hair_style": "bui", "texture": "res://art/char_chisau.png",
		"frames": ["res://art/walk_chisau_f0.png", "res://art/walk_chisau_f1.png", "res://art/walk_chisau_f2.png", "res://art/walk_chisau_f3.png", "res://art/walk_chisau_f4.png", "res://art/walk_chisau_f5.png"]},
	# Vong 26 — Map004 Ben Xe Mien Dong: Bac Tai (tai xe xe khach
	# lon tuoi, ao so mi xanh nhat) + Anh Boc Vac (thanh nien khoe,
	# ao thun trang, khan vat vai).
	"bac-tai": {"shirt": Color(0.55, 0.75, 0.90, 1), "hair_style": "ngan", "texture": "res://art/char_bactai.png",
		"frames": ["res://art/walk_bactai_f0.png", "res://art/walk_bactai_f1.png", "res://art/walk_bactai_f2.png", "res://art/walk_bactai_f3.png", "res://art/walk_bactai_f4.png", "res://art/walk_bactai_f5.png"]},
	"anh-boc-vac": {"shirt": Color(0.95, 0.95, 0.95, 1), "hair_style": "ngan", "texture": "res://art/char_anhbocvac.png",
		"frames": ["res://art/walk_anhbocvac_f0.png", "res://art/walk_anhbocvac_f1.png", "res://art/walk_anhbocvac_f2.png", "res://art/walk_anhbocvac_f3.png", "res://art/walk_anhbocvac_f4.png", "res://art/walk_anhbocvac_f5.png"]},
	# Vong 27 — Map005 Lang Dai Hoc: Thay Giao (giao vien trung
	# nien, ao so mi be, deo kinh) + Sinh Vien Lam Them (nu sinh
	# vien tre, ao thun vang nhat, toc duoi ngua).
	"thay-giao": {"shirt": Color(0.85, 0.78, 0.62, 1), "hair_style": "ngan", "texture": "res://art/char_thaygiao.png",
		"frames": ["res://art/walk_thaygiao_f0.png", "res://art/walk_thaygiao_f1.png", "res://art/walk_thaygiao_f2.png", "res://art/walk_thaygiao_f3.png", "res://art/walk_thaygiao_f4.png", "res://art/walk_thaygiao_f5.png"]},
	"sinh-vien-lam-them": {"shirt": Color(0.95, 0.85, 0.35, 1), "hair_style": "dai", "texture": "res://art/char_sinhvien.png",
		"frames": ["res://art/walk_sinhvienlamthem_f0.png", "res://art/walk_sinhvienlamthem_f1.png", "res://art/walk_sinhvienlamthem_f2.png", "res://art/walk_sinhvienlamthem_f3.png", "res://art/walk_sinhvienlamthem_f4.png", "res://art/walk_sinhvienlamthem_f5.png"]},
	# Vong 28 — Map006 Chung Cu Cu: Cu Dan Chung Cu (nam trung nien,
	# ao thun xam) + Bac Quan Ly (ong lon tuoi, toc bac, ao so mi
	# xanh nhat).
	"cu-dan-chung-cu": {"shirt": Color(0.55, 0.55, 0.58, 1), "hair_style": "ngan", "texture": "res://art/char_cudanchungcu.png",
		"frames": ["res://art/walk_cudanchungcu_f0.png", "res://art/walk_cudanchungcu_f1.png", "res://art/walk_cudanchungcu_f2.png", "res://art/walk_cudanchungcu_f3.png", "res://art/walk_cudanchungcu_f4.png", "res://art/walk_cudanchungcu_f5.png"]},
	"bac-quan-ly": {"shirt": Color(0.62, 0.78, 0.85, 1), "hair_style": "ngan", "texture": "res://art/char_bacquanly.png",
		"frames": ["res://art/walk_bacquanly_f0.png", "res://art/walk_bacquanly_f1.png", "res://art/walk_bacquanly_f2.png", "res://art/walk_bacquanly_f3.png", "res://art/walk_bacquanly_f4.png", "res://art/walk_bacquanly_f5.png"]},
	# Vong 29 — Map007 Pho Van Phong Nho: Nhan Vien Van Phong (nam
	# thanh nien, ao so mi trang dai tay, quan tay toi) + Thuc Tap
	# Sinh (nu tre, ao so mi xanh nhat, toc duoi ngua).
	"nhan-vien-van-phong": {"shirt": Color(0.95, 0.95, 0.95, 1), "hair_style": "ngan", "texture": "res://art/char_nhanvienvanphong.png",
		"frames": ["res://art/walk_nhanvienvanphong_f0.png", "res://art/walk_nhanvienvanphong_f1.png", "res://art/walk_nhanvienvanphong_f2.png", "res://art/walk_nhanvienvanphong_f3.png", "res://art/walk_nhanvienvanphong_f4.png", "res://art/walk_nhanvienvanphong_f5.png"]},
	"thuc-tap-sinh": {"shirt": Color(0.70, 0.82, 0.95, 1), "hair_style": "dai", "texture": "res://art/char_thuctapsinh.png",
		"frames": ["res://art/walk_thuctapsinh_f0.png", "res://art/walk_thuctapsinh_f1.png", "res://art/walk_thuctapsinh_f2.png", "res://art/walk_thuctapsinh_f3.png", "res://art/walk_thuctapsinh_f4.png", "res://art/walk_thuctapsinh_f5.png"]},
	# Vong 30 — Map008 Khu Chung Cu Cao Cap: Cu Dan Cao Cap (nu
	# trung nien kha gia, ao blouse hong nhat, toc bui cao) + Bao
	# Ve Chung Cu (nam trung nien, ao so mi xanh dam dong phuc,
	# mu dong phuc).
	"cu-dan-cao-cap": {"shirt": Color(0.95, 0.75, 0.80, 1), "hair_style": "bui", "texture": "res://art/char_cudancaocap.png",
		"frames": ["res://art/walk_cudancaocap_f0.png", "res://art/walk_cudancaocap_f1.png", "res://art/walk_cudancaocap_f2.png", "res://art/walk_cudancaocap_f3.png", "res://art/walk_cudancaocap_f4.png", "res://art/walk_cudancaocap_f5.png"]},
	"bao-ve-chung-cu": {"shirt": Color(0.15, 0.30, 0.55, 1), "hair_style": "ngan", "texture": "res://art/char_baovechungcu.png",
		"frames": ["res://art/walk_baovechungcu_f0.png", "res://art/walk_baovechungcu_f1.png", "res://art/walk_baovechungcu_f2.png", "res://art/walk_baovechungcu_f3.png", "res://art/walk_baovechungcu_f4.png", "res://art/walk_baovechungcu_f5.png"]},
	# Vong 31 — Map009 Pho Thuong Mai: Chu Cua Hang (nam trung
	# nien, ao xanh nhat, toc diem bac, cam so tay) + Nguoi Ban
	# Hang (nu tre, ao xanh la nhat, vay dai toi, toc duoi ngua).
	"chu-cua-hang": {"shirt": Color(0.70, 0.85, 0.90, 1), "hair_style": "ngan", "texture": "res://art/char_chucuahang.png",
		"frames": ["res://art/walk_chucuahang_f0.png", "res://art/walk_chucuahang_f1.png", "res://art/walk_chucuahang_f2.png", "res://art/walk_chucuahang_f3.png", "res://art/walk_chucuahang_f4.png", "res://art/walk_chucuahang_f5.png"]},
	"nguoi-ban-hang": {"shirt": Color(0.75, 0.90, 0.75, 1), "hair_style": "dai", "texture": "res://art/char_nguoibanhang.png",
		"frames": ["res://art/walk_nguoibanhang_f0.png", "res://art/walk_nguoibanhang_f1.png", "res://art/walk_nguoibanhang_f2.png", "res://art/walk_nguoibanhang_f3.png", "res://art/walk_nguoibanhang_f4.png", "res://art/walk_nguoibanhang_f5.png"]},
	# Vong 32 — Map010 Khu Cong Nghe: Lap Trinh Vien (nam tre, ao
	# polo xanh navy, deo kinh, cam laptop) + Ky Su Phan Mem (nu
	# tre, ao blouse trang xam nhat, toc dai ngang vai, cam may
	# tinh bang).
	"lap-trinh-vien": {"shirt": Color(0.15, 0.25, 0.45, 1), "hair_style": "ngan", "texture": "res://art/char_laptrinhvien.png",
		"frames": ["res://art/walk_laptrinhvien_f0.png", "res://art/walk_laptrinhvien_f1.png", "res://art/walk_laptrinhvien_f2.png", "res://art/walk_laptrinhvien_f3.png", "res://art/walk_laptrinhvien_f4.png", "res://art/walk_laptrinhvien_f5.png"]},
	"ky-su-phan-mem": {"shirt": Color(0.85, 0.85, 0.88, 1), "hair_style": "dai", "texture": "res://art/char_kysuphanmem.png",
		"frames": ["res://art/walk_kysuphanmem_f0.png", "res://art/walk_kysuphanmem_f1.png", "res://art/walk_kysuphanmem_f2.png", "res://art/walk_kysuphanmem_f3.png", "res://art/walk_kysuphanmem_f4.png", "res://art/walk_kysuphanmem_f5.png"]},
	# Vong 33 — Map011 Pho Tay: Nhan Vien Le Tan (nam tre, ao so
	# mi trang + gile toi, cam clipboard) + Huong Dan Vien (nu
	# tre, ao polo xanh duong nhat, toc dai ngang vai, cam co tour
	# do + ban do).
	"nhan-vien-le-tan": {"shirt": Color(0.92, 0.92, 0.95, 1), "hair_style": "ngan", "texture": "res://art/char_nhanvienletan.png",
		"frames": ["res://art/walk_nhanvienletan_f0.png", "res://art/walk_nhanvienletan_f1.png", "res://art/walk_nhanvienletan_f2.png", "res://art/walk_nhanvienletan_f3.png", "res://art/walk_nhanvienletan_f4.png", "res://art/walk_nhanvienletan_f5.png"]},
	"huong-dan-vien": {"shirt": Color(0.55, 0.75, 0.95, 1), "hair_style": "dai", "texture": "res://art/char_huongdanvien.png",
		"frames": ["res://art/walk_huongdanvien_f0.png", "res://art/walk_huongdanvien_f1.png", "res://art/walk_huongdanvien_f2.png", "res://art/walk_huongdanvien_f3.png", "res://art/walk_huongdanvien_f4.png", "res://art/walk_huongdanvien_f5.png"]},
	# Vong 34 — Map012 Khu Biet Thu Ven Song: Bao Ve Biet Thu (nam
	# trung nien, so mi xanh dam dong phuc bao ve, doi mu, cam den
	# pin) + Nguoi Lam Vuon (nam lon tuoi, toc bac, doi non la, ao
	# be/kaki, cam keo cat cay + binh tuoi).
	"bao-ve-biet-thu": {"shirt": Color(0.12, 0.25, 0.45, 1), "hair_style": "ngan", "texture": "res://art/char_baovebietthu.png",
		"frames": ["res://art/walk_baovebietthu_f0.png", "res://art/walk_baovebietthu_f1.png", "res://art/walk_baovebietthu_f2.png", "res://art/walk_baovebietthu_f3.png", "res://art/walk_baovebietthu_f4.png", "res://art/walk_baovebietthu_f5.png"]},
	"nguoi-lam-vuon": {"shirt": Color(0.85, 0.78, 0.60, 1), "hair_style": "ngan", "texture": "res://art/char_nguoilamvuon.png",
		"frames": ["res://art/walk_nguoilamvuon_f0.png", "res://art/walk_nguoilamvuon_f1.png", "res://art/walk_nguoilamvuon_f2.png", "res://art/walk_nguoilamvuon_f3.png", "res://art/walk_nguoilamvuon_f4.png", "res://art/walk_nguoilamvuon_f5.png"]},
	# Vong 35 — Map013 Quan Tai Chinh: Nhan Vien Ngan Hang (nam
	# tre, vest xanh navy + so mi xanh nhat + ca vat do dam, cam
	# giay to ngan hang) + Moi Gioi Chung Khoan (nam, vest xam
	# than + so mi xanh bac ha nhat, deo kinh, cam dien thoai bieu
	# do chung khoan + tap ho so).
	"nhan-vien-ngan-hang": {"shirt": Color(0.12, 0.20, 0.42, 1), "hair_style": "ngan", "texture": "res://art/char_nhanviennganhang.png",
		"frames": ["res://art/walk_nhanviennganhang_f0.png", "res://art/walk_nhanviennganhang_f1.png", "res://art/walk_nhanviennganhang_f2.png", "res://art/walk_nhanviennganhang_f3.png", "res://art/walk_nhanviennganhang_f4.png", "res://art/walk_nhanviennganhang_f5.png"]},
	"moi-gioi-chung-khoan": {"shirt": Color(0.30, 0.30, 0.33, 1), "hair_style": "ngan", "texture": "res://art/char_moigioichungkhoan.png",
		"frames": ["res://art/walk_moigioichungkhoan_f0.png", "res://art/walk_moigioichungkhoan_f1.png", "res://art/walk_moigioichungkhoan_f2.png", "res://art/walk_moigioichungkhoan_f3.png", "res://art/walk_moigioichungkhoan_f4.png", "res://art/walk_moigioichungkhoan_f5.png"]},
}

# Vong 22 — NPC di lang thang (patrol): NPC buoc cham giua o nha
# (event tile) va 1 o dat trong ke ben roi quay ve; Main quyet
# dinh luc nao di (xem Main._update_npc_patrol), Marker chi thuc
# thi tween. 0.30s/o = cham gap doi nguoi choi (0.15s/o), vua
# 1 chu trinh walk cycle 6 khung (FRAME_TIME 0.05).
const PATROL_MOVE_TIME := 0.30
var home_tile := Vector2i(-999, -999)  # O nha (event tile) — noi NPC phai ve khi nguoi choi lai gan.
var _patrol_tile := Vector2i(-999, -999)  # O logic hien tai (doi khi tween xong).
var _patrol_moving := false
var _patrol_from := Vector2.ZERO
var _patrol_to := Vector2.ZERO
var _patrol_t := 0.0
var _patrol_dest := Vector2i(-999, -999)

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
		# Vong 22 — o nha = o event; NPC patrol quay ve day khi
		# nguoi choi lai gan (Main tinh theo home, khong theo
		# vi tri tam thoi — event_at/tuong tac dung data tinh).
		var ht: Array = event_data.get("tile", [0, 0])
		home_tile = Vector2i(int(ht[0]), int(ht[1]))
		_patrol_tile = home_tile
	_base_name = String(event_data.get("name", ""))
	# Nhan NPC trong the gioi (vong 15): Label con cua Marker (xem
	# _make_world_label) — khong can label_layer. Nhan hotspot/
	# che tao/cua van tren CanvasLayer rieng (layer 1, duoi HUD):
	# Control o toa do man hinh, luon nam tren moi Node2D cua the
	# gioi (nhan vat, nha, troi) — nhan khong bao gio bi nhan vat
	# che nua. Khong co lop thi fallback ve _draw_name() cu (ve
	# trong _draw cua marker).
	if font != null and _base_name != "":
		if String(event_data.get("kind", "")) == "npc":
			_make_world_label()
		elif label_layer != null:
			_label = Label.new()
			_label.text = _display_name()
			_label.add_theme_font_override("font", font)
			_label.add_theme_font_size_override("font_size", 32)  # 20 world * zoom 1.6.
			_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.08, 1))
			_label.add_theme_stylebox_override("normal", _label_style)
			_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_label.visible = false
			label_layer.add_child(_label)
			tree_exited.connect(_on_tree_exited)
	queue_redraw()

## Tao nhan NPC trong the gioi (vong 15, Claude (b)): Label con cua
## Marker, dung rect neo tho (_anchor_rect) — khong kep theo camera
## luc tao (camera con truot); an/hien moi frame theo neo co trong
## man hinh + nguoi choi co o gan khong (xem _update_label).
## z_index 10 de nhan luon tren anh nen / mat tien (cung ky thuat
## SkyEffects/NightGlow dung de thoat y-sort cua IsoMap).
func _make_world_label() -> void:
	var r := _anchor_rect()
	if r.size == Vector2.ZERO:
		return
	_label = Label.new()
	_label.text = _display_name()
	_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", 20)  # Don vi world, nhu _draw_name.
	_label.add_theme_color_override("font_color", Color(0.15, 0.12, 0.08, 1))
	_label.add_theme_stylebox_override("normal", _label_style)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.position = r.position
	_label.size = r.size
	_label.z_index = 10
	_label.visible = false
	_label_world = true
	add_child(_label)

func _on_tree_exited() -> void:
	if _label != null and is_instance_valid(_label):
		_label.queue_free()
		_label = null

## Tint theo khung gio — chuyen tiep xuong CharacterSprite (NPC).
func set_tint(c: Color) -> void:
	if _sprite != null:
		_sprite.set_tint(c)

## Bong do theo khung — chuyen tiep xuong CharacterSprite (NPC).
func set_frame(f: int) -> void:
	if _sprite != null:
		_sprite.set_frame(f)

## Vong 22 — Patrol: buoc cham sang o `dest` (toa do world cua tam
## o dich). Tra false neu dang buoc (Main cho tween xong moi lenh
## tiep — khong chen buoc). Huong mat theo dx; frame walk cycle
## chay nho _sprite.moving (CharacterSprite tu doi khung 0.05s).
func patrol_walk_to(dest: Vector2i, world_pos: Vector2) -> bool:
	if _patrol_moving or _sprite == null:
		return false
	if dest == _patrol_tile:
		return false
	_patrol_dest = dest
	_patrol_from = position
	_patrol_to = world_pos
	_patrol_t = 0.0
	_patrol_moving = true
	_sprite.moving = true
	var dx := dest.x - _patrol_tile.x
	if dx < 0:
		_sprite.facing = -1
	elif dx > 0:
		_sprite.facing = 1
	return true

## NPC co dang buoc patrol khong (Main khong lenh moi khi dang buoc).
func patrol_moving() -> bool:
	return _patrol_moving

## O logic hien tai cua NPC (doi ngay khi tween xong, khong phai
## giua duong — de Main tinh o bi chiem + gan/xa dung o nguyen).
func patrol_tile() -> Vector2i:
	return _patrol_tile

## NPC co walk frames khong (dung cho test + Main).
func has_walk_frames() -> bool:
	return _sprite != null and _sprite.has_frames()

## Nguoi choi dung tren o hotspot nay: an quang sang duoi dat (no
## doc nhu bong xanh duoi chan nguoi choi) — sao van hien phia tren.
func set_player_on(b: bool) -> void:
	if _player_on != b:
		_player_on = b
		queue_redraw()

## Ten hien thi cua nhan.
## GOC LOI (20/11 16:26, kiem live): nhan hotspot "Hem tro buoi
## toi" la TEN TINH cua hotspot hs-tro-toi (best_frame Toi, port
## tu Exploration.cs) — khong phai nhan dong ho bi ket. Nguoi choi
## thay "buoi toi" luc Sang thi tuong nhan ket. Sua: nhan hotspot
## doi tu "buoi" theo khung hien tai (buoi sang/chieu/toi) — ten
## goc trong data giu nguyen, chi text hien thi doi. Khung tot van
## bao bang do sang lap lanh (1.5x) + toast khi nhat sai khung.
func _display_name() -> String:
	# Lazy fallback: event_data co the duoc dat sau _ready (vd test
	# headless add_child trong SceneTree._init — node chua vao tree
	# nen _ready chua chay). Trong game that, _ready da set san.
	if _base_name == "":
		_base_name = String(event_data.get("name", ""))
	if _frame_name == "" or String(event_data.get("kind", "")) != "hotspot":
		return _base_name
	for w in ["buổi sáng", "buổi chiều", "buổi tối"]:
		if w in _base_name:
			# Frame goc viet hoa ("Sáng") — ha xuong cho dung chinh
			# ta giua cau ("buổi sáng", khong phai "buổi Sáng").
			return _base_name.replace(w, "buổi " + _frame_name.to_lower())
	return _base_name

## Main goi khi doi khung (qua _update_daynight) — nhan cap nhat
## ngay, khong cho den lan tao marker sau.
func set_frame_name(f: String) -> void:
	if _frame_name == f:
		return
	_frame_name = f
	if _label != null:
		_label.text = _display_name()
	queue_redraw()

## Main goi moi frame: nhan NPC chi hien khi nguoi choi o gan
## (Manhattan <= LABEL_NEAR_TILES o) — Claude (b), vong 15.
## Mac dinh true de marker dung le (khong co Main, vd test
## artpass7) van hien nhan nhu cu.
func set_label_near(b: bool) -> void:
	_label_near = b

## O cua marker tren ban do (tu event_data), de Main tinh khoang cach.
func tile() -> Vector2i:
	var t: Array = event_data.get("tile", [0, 0])
	return Vector2i(int(t[0]), int(t[1]))

## Nhan NPC trong the gioi co nen hien khong: neo (chan NPC) trong
## vung nhin thay cua camera (+-20 world) VA nguoi choi o gan.
## Cung vi tu nay dung cho ca _update_label() lan label_screen_rect()
## de 2 cho khong lech nhau 1 frame.
func _npc_label_should_show() -> bool:
	if not _label_near:
		return false
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return false
	var half := get_viewport_rect().size / (2.0 * cam.zoom)
	var center := cam.get_screen_center_position()
	var vis_min := center - half
	var vis_max := center + half
	var gp := global_position
	return not (gp.x < vis_min.x - 20 or gp.x > vis_max.x + 20 or gp.y < vis_min.y - 20 or gp.y > vis_max.y + 20)

func _process(delta: float) -> void:
	_pulse += delta
	# Vong 22 — tien tween patrol (0.30s/o): xong thi doi o logic,
	# tat moving de sprite ve frame 0 dung yen + nhun nhe.
	if _patrol_moving:
		_patrol_t += delta / PATROL_MOVE_TIME
		if _patrol_t >= 1.0:
			_patrol_t = 1.0
			_patrol_moving = false
			position = _patrol_to
			_patrol_tile = _patrol_dest
			if _sprite != null:
				_sprite.moving = false
		else:
			position = _patrol_from.lerp(_patrol_to, _patrol_t)
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
	# Nhan NPC trong the gioi (vong 15): rect man hinh = bien doi
	# canvas ap len vi tri that cua Label con (khong phai cong thuc
	# CanvasLayer cu — nhan 32px, cao 38px); an (Rect2 rong) khi
	# nhan dang an (xa nguoi choi / neo ngoai man hinh).
	if _label_world:
		if not _npc_label_should_show():
			return Rect2()
		var cam := get_viewport().get_camera_2d()
		if cam == null:
			return Rect2()
		var ct := get_viewport().get_canvas_transform()
		var sp: Vector2 = ct * (global_position + _label.position)
		return Rect2(sp, _label.size * cam.zoom)
	var wr := label_rect()
	if wr.size == Vector2.ZERO:
		return Rect2()
	var cam2 := get_viewport().get_camera_2d()
	if cam2 == null:
		return Rect2()
	# label_rect() kep theo the gioi; doi sang man hinh: tam X giu
	# nguyen, Y giu nguyen (chi doi don vi) — nhan 32px cao 38px.
	var ct2 := get_viewport().get_canvas_transform()
	var sp2: Vector2 = ct2 * (global_position + wr.position)
	var text := _display_name()
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	var w := tw + 20.0
	var h := 38.0
	var pos := Vector2(sp2.x + (wr.size.x * cam2.zoom.x - w) / 2.0, sp2.y + (wr.size.y * cam2.zoom.y - h) / 2.0)
	pos.x = clampf(pos.x, 16.0, 720.0 - 16.0 - w)
	# Day man hinh toi da y=1200 (truoc 1264): nhan cua ra sat mep
	# duoi gan bi cat (kiem live 14:34). Resolver kep lai lan nua.
	pos.y = clampf(pos.y, HUD_BOTTOM_SCREEN, 1200.0 - h)
	# Vi tri co ban (chua chong-chong); Main tinh label_override
	# tu rect nay moi frame (xem _resolve_label_overlaps).
	return Rect2(pos, Vector2(w, h))

func _update_label() -> void:
	if _label == null:
		return
	if _label_world:
		# Nhan trong the gioi: vi tri co dinh theo Marker, chi
		# cap nhat an/hien (neo trong man hinh + nguoi choi o gan).
		_label.visible = _npc_label_should_show()
		return
	# Uu tien vi tri Main da chong-chong (label_override); neu rong
	# thi tinh nhu cu.
	var r := label_override if label_override.size != Vector2.ZERO else label_screen_rect()
	if r.size == Vector2.ZERO:
		_label.visible = false
		return
	_label.visible = true
	_label.position = r.position
	_label.size = r.size

## Hinh chu nhat neo THO cua nhan (toa do cuc bo, chua kep theo
## camera). Nhan NPC trong the gioi dung rect nay lam vi tri that
## (con cua Marker); label_rect() them buoc kep theo camera cho
## nhan CanvasLayer (hotspot/craft/door).
func _anchor_rect() -> Rect2:
	if font == null:
		return Rect2()
	var text := _display_name()
	if text == "":
		return Rect2()
	# Vi tri nhan theo loai (sua 20/11 12:30, kiem live): nhan nam tren
	# CanvasLayer rieng nen KHONG bao gio bi nhan vat che nua — cac
	# muc "che mat" cu het hieu luc. Dat theo vi tri that tren anh:
	#  * NPC -170 (tren dau 104px, cach 40px): -144 cu nam dung tren
	#    duong noi mat tien/dat; day len -170 cho thoat khoi duong noi.
	#  * Goc che tao -40 (TREN bieu tuong): +24 cu de xuong dung
	#    cho nguoi choi spawn (4,5) — nhan che mat nguoi choi luc
	#    spawn (loi 20/11 12:30). Dat tren nhu hotspot: y 316-342,
	#    cach dau nguoi choi ~18px, duoi duong noi mat tien.
	#  * Hotspot -40 (TREN sao): +24 cu nam cung dai y 550-586 voi
	#    nhan cua ra (bi clamp day len) nen chong nhau. Dat tren
	#    sao: y 486-512, cach nhan cua 48px, cach "Goc Che Tao" 54px,
	#    cach "Co Tu" 88px — sach tren Map001.
	#  * Cua ra +130 (duoi bieu tuong): gan day map nen bi clamp day
	#    len y 560-586 luc spawn; khong chong nhan nao sau khi
	#    hotspot doi len tren.
	var kind := String(event_data.get("kind", ""))
	var top := -40.0 if kind == "hotspot" or kind == "craft" else NPC_LABEL_TOP
	if kind == "door":
		top = 130.0
	# Vong 15: nhan NPC trong the gioi co kich thuoc that = minimum
	# size cua Label (chu + content margin cua stylebox: 10+10
	# ngang, 4+4 doc; font cao 24 o co 20) — Label tu tang len
	# minimum size khi vao tree (do: dat (74,26) thi thanh
	# (78,32)), nen rect neo phai tinh dung co do ngay tu dau,
	# neu khong tam nhan lech +2 world khoi chan NPC.
	var size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	if kind == "npc":
		var nw := size.x + 20.0
		var nh := float(font.get_height(20)) + 8.0
		return Rect2(-nw / 2.0, NPC_LABEL_TOP, nw, nh)
	# Vong 14: BO lech chan/le NPC (truoc NPC_PARITY_OFFSET = 40):
	# lech 40 world = +50px man hinh cho NPC o le, lam nhan
	# "Anh Hai" (6,3) noi cao hon "Chi Le" (2,2) 50px ngay tu
	# vi tri muon — cong them drift resolver -100px thi khe tren
	# dau 197px trong khi Chi Le chi 47px (probe 21/11). Tach
	# nhan NPC ke nhau nay la viec cua resolver
	# (Main._resolve_label_overlaps), khong can lech san.
	# Vong 15: nhan NPC trong the gioi cung khong can lech san —
	# neo co dinh tren dau tung NPC, khong qua resolver nua.
	return Rect2(-size.x / 2.0 - 8, top, size.x + 16, 26)

## Hinh chu nhat cua nhan (toa do cuc bo) sau khi da kep trong vung
## nhin thay cua camera, tru vung HUD tren cung va cach mep ~20px
## man hinh. Test dung de kiem tra nhan khong bi cat / che.
func label_rect() -> Rect2:
	var rect := _anchor_rect()
	if rect.size == Vector2.ZERO:
		return Rect2()
	# Kep nhan trong man hinh hien thi (theo camera that, khong dung
	# canvas transform — luc tao marker transform chua co camera nen
	# kep sai va nhan o ria map (vd "Cua ra Cho Dau Moi") bi cat).
	# Meo tren KHONG phai mep man hinh ma la duoi HUD gon (160px man
	# hinh): nhan nao vuot qua day se bi panel HUD che mat nua tren.
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
		_display_name(), HORIZONTAL_ALIGNMENT_LEFT, -1, 20,
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
	# Quang sang mem duoi dat — AN khi nguoi choi dung tren o nay
	# (vong 7: quang xanh nam duoi chan nguoi choi doc nhu bong
	# xanh UI, khong phai bong tu nhien). Sao van hien phia tren.
	if not _player_on:
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
