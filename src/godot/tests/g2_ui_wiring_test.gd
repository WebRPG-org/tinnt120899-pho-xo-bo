extends SceneTree
## G2 UI wiring test — chay scene Main that headless, kiem tra cac he G2
## da noi vao scene (Jobs / Hotspot / Crafting / Stats) dung that:
##   godot --headless --path src/godot -s res://tests/g2_ui_wiring_test.gd
## Buoc: HUD ban dau (vi 0, chi so 100/100/100, tui trong) -> lam ca
## Ban rong + Shipper o khung Sang (luong x1,5 nho The 100) -> het quota
## tuan (14 ca) bi chan -> nhat hotspot qua PxbHotspot (dung khung /
## sai khung / nhan lai) -> che Den Soi: chua hoc -> hoc tu Anh Hai ->
## thieu do -> du do che xong, tool len bac 1, tui tru dung.

var _frame := 0
var _state := 0
var _pass := 0
var _fail := 0
var _main: Node = null

func _check(name: String, cond: bool) -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name)

func _init() -> void:
	process_frame.connect(_on_frame)
	var ps: PackedScene = load("res://Main.tscn")
	_main = ps.instantiate()
	root.add_child(_main)

func _on_frame() -> void:
	_frame += 1
	if _frame > 600:
		print("G2 UI WIRING: TIMEOUT")
		quit(1)
		return
	match _state:
		0:
			if _frame >= 3:
				_check("bat dau Map001", _main.current_map_id == 1)
				_check("he G2 da tao", _main.jobs != null and _main.hotspot != null and _main.crafting != null and _main.stats != null)
				_check("tui Main tro toi hotspot.materials",
					_main.inventory == _main.hotspot.materials)
				_check("HUD vi ban dau 0d", _main._hud_gold.text == "Ví: 0đ • EXP 0")
				_check("HUD chi so 100/100/100", _main._hud_stats.text == "Thể 100 • Trí 100 • Tâm 100")
				_check("HUD tui trong", _main._hud_bag.text == "Túi: trống")
				_check("fmt_vnd 150000", _main._fmt_vnd(150000) == "150.000")
				_check("fmt_vnd 1234567", _main._fmt_vnd(1234567) == "1.234.567")
				_check("fmt_vnd 0", _main._fmt_vnd(0) == "0")
				_state = 1
		1:
			# Khung Sang, tuan 1: Ban rong THIEU NGUOI (+30% cung-cau) —
			# 150000 x 1,5 (The 100) x 1,3 = 292500. Khung tot Chieu
			# khong ap dung o khung Sang.
			_check("tuan 1 Ban rong thieu nguoi", _main.jobs.get_demand("ban-rong") == "thieu-nguoi")
			var r1: Dictionary = _main.work_job("ban-rong")
			_check("lam ca Ban rong ok", bool(r1.get("ok", false)))
			_check("luong Ban rong khung Sang 292500", int(r1.get("pay", 0)) == 292500)
			_check("vi cong 292500", _main.jobs.gold == 292500)
			_check("con 13 ca/tuan", int(r1.get("shifts_left", -1)) == 13)
			_check("EXP +10/ca", _main.jobs.exp_total == 10)
			_check("HUD vi cap nhat", _main._hud_gold.text == "Ví: 292.500đ • EXP 10")
			# Shipper khung Sang, cung-cau binh thuong: 180000 * 1,5 = 270000.
			var r2: Dictionary = _main.work_job("shipper")
			_check("lam ca Shipper ok", bool(r2.get("ok", false)))
			_check("luong Shipper khung Sang 270000", int(r2.get("pay", 0)) == 270000)
			_check("vi cong don 562500", _main.jobs.gold == 562500)
			_state = 2
		2:
			# Lam them 13 ca Ban rong -> du quota 14; ca 15 bi chan.
			for i in 13:
				_main.work_job("ban-rong")
			_check("du 14 ca Ban rong", _main.jobs.shifts_done("ban-rong") == 14)
			var gold_before: int = _main.jobs.gold
			var r3: Dictionary = _main.work_job("ban-rong")
			_check("ca 15 het-quota", not bool(r3.get("ok", true)) and String(r3.get("reason", "")) == "het-quota")
			_check("het-quota khong cong tien", _main.jobs.gold == gold_before)
			_state = 3
		3:
			# Nhat hotspot qua PxbHotspot: dung khung Sang -> ok.
			var ev: Dictionary = {"id": "hs-cho-sang", "name": "Sạp rau buổi sáng", "best_frame": "Sáng"}
			_main._collect_hotspot(ev)
			_check("nhat hs-cho-sang khung Sang: la-chuoi x2",
				int(_main.inventory.get("la-chuoi", 0)) == 2)
			_main._collect_hotspot(ev)
			_check("nhat lai cung ngay bi chan", int(_main.inventory.get("la-chuoi", 0)) == 2)
			# Sai khung: hs-cho-chieu o khung Sang -> wrong-frame, khong cong do.
			var ev2: Dictionary = {"id": "hs-cho-chieu", "name": "Góc phế liệu chợ", "best_frame": "Chiều"}
			_main._collect_hotspot(ev2)
			_check("sai khung khong cong do", int(_main.inventory.get("sat-vun", 0)) == 0)
			_state = 4
		4:
			# Che Den Soi khi chua hoc -> chan; hoc xong van thieu do.
			var c1: Dictionary = _main.craft_recipe("che-den-soi")
			_check("chua hoc cong thuc bi chan",
				not bool(c1.get("ok", true)) and String(c1.get("reason", "")) == "chua-hoc-cong-thuc")
			_main._learn_recipe("che-den-soi")
			_check("hoc cong thuc Den Soi", _main.crafting.has_learned("che-den-soi"))
			_main.hotspot.materials["sat-vun"] = 1
			var c2: Dictionary = _main.craft_recipe("che-den-soi")
			_check("thieu nguyen lieu bi chan",
				not bool(c2.get("ok", true)) and String(c2.get("reason", "")) == "thieu-nguyen-lieu")
			_check("thieu do khong tru tui", int(_main.inventory.get("sat-vun", 0)) == 1)
			_state = 5
		5:
			# Du do: sat-vun 2 + chai-nhua 2 -> che xong, Den Soi bac 1,
			# tui tru dung (crafting xoa key ve 0), HUD tui cap nhat.
			_main.hotspot.materials["sat-vun"] = 2
			_main.hotspot.materials["chai-nhua"] = 2
			var c3: Dictionary = _main.craft_recipe("che-den-soi")
			_check("che Den Soi ok", bool(c3.get("ok", false)))
			_check("ket qua tool:DenSoi:1", String(c3.get("result_id", "")) == "tool:DenSoi:1")
			_check("Den Soi len bac 1", _main.crafting.tool_tier("DenSoi") == 1)
			_check("tui tru sat-vun ve 0", int(_main.inventory.get("sat-vun", 0)) == 0)
			_check("tui tru chai-nhua ve 0", int(_main.inventory.get("chai-nhua", 0)) == 0)
			_check("tui chung Hotspot<->Crafting: la-chuoi con 2",
				int(_main.inventory.get("la-chuoi", 0)) == 2)
			_check("HUD tui chi con la-chuoi", _main._hud_bag.text == "Túi: Lá Chuối ×2")
			# Cong thuc khac chua hoc -> chan (khong che chui).
			var c4: Dictionary = _main.craft_recipe("che-xe-day")
			_check("che-xe-day chua hoc bi chan",
				not bool(c4.get("ok", true)) and String(c4.get("reason", "")) == "chua-hoc-cong-thuc")
			_state = 6
		6:
			print("G2 UI WIRING: %d/%d PASS" % [_pass, _pass + _fail])
			quit(0 if _fail == 0 else 1)
