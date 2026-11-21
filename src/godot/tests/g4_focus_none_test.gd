extends SceneTree
## Vong 13 — FOCUS_NONE cho moi nut (loi that tim duoc o bao cao
## tai hien r12, 21/11 ~14:00): chi nut D-pad co focus_mode NONE;
## nut "Bat dau choi", "Doi khung (F)", "Viec lam", "Dien thoai (P)",
## tab dien thoai, nut hanh dong dien thoai, lua chon hoi thoai deu
## giu FOCUS_ALL mac dinh — sau khi bam bang chuot, nut giu focus
## ban phim va phim mui ten (ui_*) bi he focus navigation cua Godot
## an mat truoc khi toi Main._unhandled_input -> mui ten khong di
## (F/P van chay vi khong phai ui_* — dung trieu chung live 12:56).
## WASD (KEY_D...) khong phai ui_* nen ly thuyet van toi duoc —
## viec phim D cung chet tren live chua giai thich het (nghi ban
## lai CDN / moi truong checker), nhung sua focus van bat buoc.
## Test: (1) tinh — moi nut trong UI deu FOCUS_NONE; (2) chuc nang
## — nut FOCUS_NONE thi grab_focus KHONG lay duoc focus (truoc sua
## lay duoc — probe 21/11: focus owner = Button). Luu y trung thuc:
## headless KHONG tai hien duoc viec GUI an phim mui ten (event tiem
## qua Input.parse_input_event van toi _unhandled_input du nut dang
## focus) — buoc ArrowRight chi la kiem sanity "van di", khong phai
## bang chung sua; bang chung that phai la kiem live tren web sau
## deploy (bam nut HUD bang chuot that roi bam mui ten).
##   ~/workspace/pho-xo-bo/tools/godot/godot --headless --path src/godot -s res://tests/g4_focus_none_test.gd

var _frame := 0
var _state := 0
var _wait := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)

func _key(k: int, pressed: bool) -> InputEventKey:
	var ev := InputEventKey.new()
	ev.physical_keycode = k
	ev.keycode = k
	ev.pressed = pressed
	ev.echo = false
	return ev

## Tim nut theo doan text trong cay con (nut HUD/title la bien cuc
## bo trong main.gd, khong co ten member de doc truc tiep).
func _find_button(root_node: Node, needle: String) -> Button:
	for c in root_node.get_children():
		if c is Button and needle in (c as Button).text:
			return c as Button
		var found := _find_button(c, needle)
		if found != null:
			return found
	return null

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 1500:
		print("G4 FOCUS-NONE: TIMEOUT o state ", _state)
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				# Kiem tinh truoc khi start (title van mo).
				var start_btn := _find_button(_main._title_panel, "Bắt đầu")
				_check("tim thay nut Bat dau choi", start_btn != null)
				if start_btn != null:
					_check("nut Bat dau choi FOCUS_NONE", start_btn.focus_mode == Control.FOCUS_NONE, str(start_btn.focus_mode))
				var frame_btn := _find_button(_main, "Đổi khung")
				_check("tim thay nut Doi khung", frame_btn != null)
				if frame_btn != null:
					_check("nut Doi khung FOCUS_NONE", frame_btn.focus_mode == Control.FOCUS_NONE, str(frame_btn.focus_mode))
				var jobs_btn := _find_button(_main, "Việc làm")
				_check("tim thay nut Viec lam", jobs_btn != null)
				if jobs_btn != null:
					_check("nut Viec lam FOCUS_NONE", jobs_btn.focus_mode == Control.FOCUS_NONE, str(jobs_btn.focus_mode))
				_check("nut Dien thoai (P) FOCUS_NONE", _main._phone_btn.focus_mode == Control.FOCUS_NONE, str(_main._phone_btn.focus_mode))
				var dpad_ok := true
				for c in _main._dpad.get_children():
					if c is Button and (c as Button).focus_mode != Control.FOCUS_NONE:
						dpad_ok = false
				_check("4 nut D-pad FOCUS_NONE", dpad_ok)
				_main._on_start_pressed()
				_wait = 0
				_state = 1
		1:
			_wait += 1
			if _wait >= 3:
				# Chuc nang: nut HUD FOCUS_NONE thi grab_focus
				# (mo phong click chuot giu focus) phai KHONG lay
				# duoc focus — neu lay duoc (truoc sua) thi phim
				# mui ten se bi focus navigation an tren ban web
				# that (headless khong tai hien duoc phan an phim,
				# chi kiem duoc co che lay focus nay).
				_main._phone_btn.grab_focus()
				_check("nut HUD: grab_focus KHONG lay duoc focus", _main.get_viewport().gui_get_focus_owner() == null, str(_main.get_viewport().gui_get_focus_owner()))
				Input.parse_input_event(_key(KEY_RIGHT, true))
				Input.parse_input_event(_key(KEY_RIGHT, false))
				_wait = 0
				_state = 2
		2:
			_wait += 1
			if not _main.player._moving and _wait >= 3:
				_check("sanity: ArrowRight sau grab_focus van di (5,5)", _main.player.tile == Vector2i(5, 5), str(_main.player.tile))
				# Mo dien thoai: 9 tab + 1 nut hanh dong.
				_main._toggle_phone()
				_wait = 0
				_state = 3
			elif _wait >= 400:
				_check("sanity: ArrowRight sau grab_focus van di (5,5)", false, "ket o " + str(_main.player.tile))
				_state = 99
		3:
			_wait += 1
			if _wait >= 3:
				var tabs_ok := true
				var tab_n := 0
				for t in _main._phone_tab_buttons.values():
					tab_n += 1
					if (t as Button).focus_mode != Control.FOCUS_NONE:
						tabs_ok = false
				_check("9 tab dien thoai FOCUS_NONE", tabs_ok and tab_n == 9, "dem=%d" % tab_n)
				_main._phone_action("Hành động test", func() -> void: pass)
				var act_btn := _main._phone_actions.get_child(_main._phone_actions.get_child_count() - 1) as Button
				_check("nut hanh dong dien thoai FOCUS_NONE", act_btn != null and act_btn.focus_mode == Control.FOCUS_NONE)
				_main._toggle_phone()
				# Hoi thoai: 2 lua chon.
				_main.show_dialogue("Người test", "Nội dung test", [["Lựa chọn A", func() -> void: pass], ["Đóng", func() -> void: pass]])
				_wait = 0
				_state = 4
		4:
			_wait += 1
			if _wait >= 3:
				var dlg_ok := true
				var dlg_n := 0
				for c in _main._dlg_choices.get_children():
					if c is Button:
						dlg_n += 1
						if (c as Button).focus_mode != Control.FOCUS_NONE:
							dlg_ok = false
				_check("nut lua chon hoi thoai FOCUS_NONE", dlg_ok and dlg_n == 2, "dem=%d" % dlg_n)
				_main.close_dialogue()
				_state = 5
		5:
			print("G4 FOCUS-NONE: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
		99:
			print("G4 FOCUS-NONE: %d/%d PASS" % [_pass, _pass + _fail])
			quit(1)
