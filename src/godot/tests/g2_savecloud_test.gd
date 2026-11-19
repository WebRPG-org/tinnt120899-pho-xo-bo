extends SceneTree
## G2 SAVECLOUD selftest — chay headless, khong can trinh duyet:
##   godot --headless --path src/godot -s res://tests/g2_savecloud_test.gd
## Kiem tra: PxbSaveCloud (port PXB_SaveCloud.js) — hang PROVISIONAL,
## login/logout, build_save_json, encode/decode (nen + tho + save
## hong + thieu du lieu), save/load local slot 1–3 (file user://),
## apply_save, upload/download (chua co endpoint), sync_status,
## data()/from_data() + bo du lieu ban, reset_state.
## In "G2 SAVECLOUD SELFTEST: n/n PASS".
## KHONG sua g2_selftest.gd (tranh xung dot voi luong song song).
## Test don file user:// no tao sau khi xong (khong de rac).

var _pass := 0
var _fail := 0

var _clouds: Array = [] # cloud da tao — free o cuoi de log sach (khong leak resource)


func _check(name: String, cond: bool, detail: String = "") -> void:
	if cond:
		_pass += 1
		print("  PASS ", name)
	else:
		_fail += 1
		print("  FAIL ", name, " ", detail)


func _init() -> void:
	_delete_slot_files()
	_test_constants()
	_test_login()
	_test_build_save_json()
	_test_encode_decode()
	_test_save_load_local()
	_test_apply_save()
	_test_upload_download()
	_test_sync_status()
	_test_data()
	_test_reset_state()
	_delete_slot_files()
	print("G2 SAVECLOUD SELFTEST: %d/%d PASS" % [_pass, _pass + _fail])
	for c in _clouds:
		c.free()
	quit(0 if _fail == 0 else 1)


func _new_cloud() -> PxbSaveCloud:
	var cloud := PxbSaveCloud.new()
	_clouds.append(cloud)
	return cloud


func _sys(game_day: int) -> Dictionary:
	return {
		"pxb_time": {"game_day": game_day, "gio": 8},
		"pxb_stats": {"suc_khoe": 80},
		"ten_nguoi_choi": "An",
	}


func _delete_slot_files() -> void:
	for slot in [1, 2, 3]:
		var path := PxbSaveCloud.slot_path(slot)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)


func _write_slot_file_raw(slot: int, text: String) -> void:
	var file := FileAccess.open(PxbSaveCloud.slot_path(slot), FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _test_constants() -> void:
	_check("SaveCloud: MAX_LOCAL_SLOTS = 3", PxbSaveCloud.MAX_LOCAL_SLOTS == 3)
	_check("SaveCloud: SAVE_VERSION 0.1.0-skeleton",
		PxbSaveCloud.SAVE_VERSION == "0.1.0-skeleton")
	_check("SaveCloud: SAVE_UPLOAD_PATH /save/upload",
		PxbSaveCloud.SAVE_UPLOAD_PATH == "/save/upload")
	_check("SaveCloud: SAVE_DOWNLOAD_PATH /save/download",
		PxbSaveCloud.SAVE_DOWNLOAD_PATH == "/save/download")
	_check("SaveCloud: REASON_NO_ENDPOINT server-chua-co-endpoint",
		PxbSaveCloud.REASON_NO_ENDPOINT == "server-chua-co-endpoint")
	_check("SaveCloud: SYNC_STATUS dung 4 trang thai",
		PxbSaveCloud.SYNC_STATUS.size() == 4)
	_check("SaveCloud: 4 trang thai dung chuoi (chua-dong-bo/local-ok/da-dong-bo/loi)",
		PxbSaveCloud.SYNC_CHUA_DONG_BO == "chua-dong-bo"
		and PxbSaveCloud.SYNC_LOCAL_OK == "local-ok"
		and PxbSaveCloud.SYNC_DA_DONG_BO == "da-dong-bo"
		and PxbSaveCloud.SYNC_LOI == "loi")


func _test_login() -> void:
	var cloud := _new_cloud()
	_check("SaveCloud: moi tao thi chua dang nhap + accountId rong",
		not cloud.is_logged_in() and cloud.account_id() == "")
	var r1 := cloud.login("")
	_check("SaveCloud: login('') tra thieu-account-id",
		not bool(r1.get("ok", true)) and String(r1.get("reason", "")) == "thieu-account-id",
		str(r1))
	var r2 := cloud.login("nguoi-choi-1")
	_check("SaveCloud: login('nguoi-choi-1') tra ok + accountId",
		bool(r2.get("ok", false)) and String(r2.get("accountId", "")) == "nguoi-choi-1",
		str(r2))
	_check("SaveCloud: sau login thi is_logged_in + account_id() dung",
		cloud.is_logged_in() and cloud.account_id() == "nguoi-choi-1")
	var r3 := cloud.logout()
	_check("SaveCloud: logout tra ok + accountId rong, het dang nhap",
		bool(r3.get("ok", false)) and String(r3.get("accountId", "x")) == ""
		and not cloud.is_logged_in(), str(r3))
	_check("SaveCloud: login lai sau logout van duoc",
		bool(cloud.login("nguoi-choi-2").get("ok", false))
		and cloud.account_id() == "nguoi-choi-2")


func _test_build_save_json() -> void:
	var cloud := _new_cloud()
	var sys := _sys(7)
	var built := cloud.build_save_json(sys)
	_check("SaveCloud: build_save_json ok + gameDay tu pxb_time",
		bool(built.get("ok", false)) and int(built["save"]["gameDay"]) == 7, str(built))
	_check("SaveCloud: build_save_json version dung SAVE_VERSION",
		String(built["save"]["version"]) == PxbSaveCloud.SAVE_VERSION)
	_check("SaveCloud: build_save_json savedAt > 0",
		int(built["save"]["savedAt"]) > 0)
	_check("SaveCloud: build_save_json gameSystem chep du field",
		built["save"]["gameSystem"]["ten_nguoi_choi"] == "An"
		and int(built["save"]["gameSystem"]["pxb_time"]["game_day"]) == 7)
	built["save"]["gameSystem"]["pxb_time"]["game_day"] = 99
	_check("SaveCloud: build_save_json tra ban sao — sua ban sao khong doi goc",
		int(sys["pxb_time"]["game_day"]) == 7)
	var built2 := cloud.build_save_json({"gameDay": 5, "pxb_stats": {}})
	_check("SaveCloud: build_save_json gameDay tu gameDay khi khong co pxb_time",
		bool(built2.get("ok", false)) and int(built2["save"]["gameDay"]) == 5)
	var built3 := cloud.build_save_json({"pxb_stats": {}})
	_check("SaveCloud: build_save_json mac dinh gameDay = 1",
		bool(built3.get("ok", false)) and int(built3["save"]["gameDay"]) == 1)
	var built4 := cloud.build_save_json(null)
	_check("SaveCloud: build_save_json(null) tra khong-co-game-system",
		not bool(built4.get("ok", true))
		and String(built4.get("reason", "")) == "khong-co-game-system", str(built4))
	var built5 := cloud.build_save_json("chuoi-khong-phai-dict")
	_check("SaveCloud: build_save_json(chuoi) tra khong-co-game-system",
		not bool(built5.get("ok", true))
		and String(built5.get("reason", "")) == "khong-co-game-system", str(built5))


func _test_encode_decode() -> void:
	var cloud := _new_cloud()
	var built := cloud.build_save_json(_sys(7))
	var save: Dictionary = built["save"]
	var enc := cloud.encode_save(save)
	_check("SaveCloud: encode_save ok + compressed true + tien to pxb1:",
		bool(enc.get("ok", false)) and bool(enc.get("compressed", false))
		and String(enc.get("data", "")).begins_with("pxb1:"), str(enc))
	var dec := cloud.decode_save(String(enc["data"]), true)
	_check("SaveCloud: decode round-trip (nen) giu gameDay + gameSystem",
		bool(dec.get("ok", false)) and int(dec["save"]["gameDay"]) == 7
		and dec["save"]["gameSystem"]["ten_nguoi_choi"] == "An", str(dec))
	var dec_raw := cloud.decode_save(JSON.stringify(save), false)
	_check("SaveCloud: decode JSON tho (compressed=false) dung",
		bool(dec_raw.get("ok", false)) and int(dec_raw["save"]["gameDay"]) == 7)
	var dec_hong := cloud.decode_save("{khong-phai-json", false)
	_check("SaveCloud: decode JSON tho hong tra save-hong",
		not bool(dec_hong.get("ok", true))
		and String(dec_hong.get("reason", "")) == "save-hong", str(dec_hong))
	var dec_lz := cloud.decode_save("khong-phai-pxb1", true)
	_check("SaveCloud: decode nen khong co tien to pxb1: tra thieu-lzstring",
		not bool(dec_lz.get("ok", true))
		and String(dec_lz.get("reason", "")) == "thieu-lzstring", str(dec_lz))
	var dec_giai1 := cloud.decode_save("pxb1:!!!", true)
	_check("SaveCloud: decode nen base64 sai tra giai-nen-that-bai",
		not bool(dec_giai1.get("ok", true))
		and String(dec_giai1.get("reason", "")) == "giai-nen-that-bai", str(dec_giai1))
	# 4 byte dau = 5 (kich thuoc goc), than chi co "ABC" (3 byte) nen
	# giai nen khong du 5 byte -> giai-nen-that-bai (khong cap bo nho lon).
	var fake := PackedByteArray([5, 0, 0, 0, 65, 66, 67])
	var dec_giai2 := cloud.decode_save(
		"pxb1:" + Marshalls.raw_to_base64(fake), true)
	_check("SaveCloud: decode nen sai dinh dang tra giai-nen-that-bai",
		not bool(dec_giai2.get("ok", true))
		and String(dec_giai2.get("reason", "")) == "giai-nen-that-bai", str(dec_giai2))
	var dec_rong := cloud.decode_save("", false)
	_check("SaveCloud: decode chuoi rong tra save-hong",
		not bool(dec_rong.get("ok", true))
		and String(dec_rong.get("reason", "")) == "save-hong", str(dec_rong))
	var enc_rong := cloud.encode_save({})
	var dec_rong2 := cloud.decode_save(String(enc_rong.get("data", "")), true)
	_check("SaveCloud: encode/decode save rong {} van round-trip",
		bool(enc_rong.get("ok", false)) and bool(dec_rong2.get("ok", false))
		and (dec_rong2["save"] as Dictionary).is_empty())


func _test_save_load_local() -> void:
	var cloud := _new_cloud()
	var r_trong := cloud.load_from_local(1)
	_check("SaveCloud: load slot 1 khi chua luu tra slot-trong",
		not bool(r_trong.get("ok", true))
		and String(r_trong.get("reason", "")) == "slot-trong", str(r_trong))
	var r0 := cloud.save_to_local(0, _sys(7))
	_check("SaveCloud: save slot 0 tra slot-khong-hop-le",
		not bool(r0.get("ok", true))
		and String(r0.get("reason", "")) == "slot-khong-hop-le", str(r0))
	var r4 := cloud.save_to_local(4, _sys(7))
	_check("SaveCloud: save slot 4 tra slot-khong-hop-le",
		not bool(r4.get("ok", true))
		and String(r4.get("reason", "")) == "slot-khong-hop-le", str(r4))
	var s1 := cloud.save_to_local(1, _sys(7))
	_check("SaveCloud: save slot 1 ok, where file, compressed true",
		bool(s1.get("ok", false)) and int(s1.get("slot", 0)) == 1
		and String(s1.get("where", "")) == "file" and bool(s1.get("compressed", false)),
		str(s1))
	var l1 := cloud.load_from_local(1)
	_check("SaveCloud: load slot 1 round-trip giu gameDay + gameSystem",
		bool(l1.get("ok", false)) and int(l1["save"]["gameDay"]) == 7
		and l1["save"]["gameSystem"]["ten_nguoi_choi"] == "An"
		and bool(l1.get("compressed", false)), str(l1))
	var s2 := cloud.save_to_local(2, _sys(9))
	var s3 := cloud.save_to_local(3, _sys(12))
	_check("SaveCloud: save slot 2 + 3 deu ok",
		bool(s2.get("ok", false)) and bool(s3.get("ok", false)))
	var l2 := cloud.load_from_local(2)
	var l3 := cloud.load_from_local(3)
	_check("SaveCloud: load slot 2/3 giu dung gameDay rieng",
		bool(l2.get("ok", false)) and int(l2["save"]["gameDay"]) == 9
		and bool(l3.get("ok", false)) and int(l3["save"]["gameDay"]) == 12)
	var l0 := cloud.load_from_local(0)
	var l4 := cloud.load_from_local(4)
	_check("SaveCloud: load slot 0/4 tra slot-khong-hop-le",
		String(l0.get("reason", "")) == "slot-khong-hop-le"
		and String(l4.get("reason", "")) == "slot-khong-hop-le")
	var slots := cloud.list_local_slots()
	_check("SaveCloud: list_local_slots dung 3 slot, where file, compressed true",
		slots.size() == 3 and String(slots["1"]["where"]) == "file"
		and bool(slots["1"]["compressed"]) and bool(slots["2"]["compressed"])
		and bool(slots["3"]["compressed"]), str(slots))
	cloud.save_to_local(1, _sys(20))
	var l1b := cloud.load_from_local(1)
	_check("SaveCloud: save de len slot 1 ghi de, load ra gameDay moi",
		bool(l1b.get("ok", false)) and int(l1b["save"]["gameDay"]) == 20)
	_write_slot_file_raw(3, "KHONG-PHAI-SAVE{{{")
	var l_hong := cloud.load_from_local(3)
	_check("SaveCloud: file slot 3 bi viet bay tra save-hong",
		not bool(l_hong.get("ok", true))
		and String(l_hong.get("reason", "")) == "save-hong", str(l_hong))
	# Phong bi ghi compressed:false nhung data that la pxb1: -> thu
	# giai nen 1 lan (dung JS) roi van doc duoc.
	var enc := cloud.encode_save(cloud.build_save_json(_sys(9))["save"])
	_write_slot_file_raw(2, JSON.stringify(
		{"compressed": false, "data": String(enc["data"])}))
	var l_retry := cloud.load_from_local(2)
	_check("SaveCloud: phong bi sai compressed=false nhung data nen van doc duoc (thu lai)",
		bool(l_retry.get("ok", false)) and int(l_retry["save"]["gameDay"]) == 9,
		str(l_retry))
	var r_null := cloud.save_to_local(1, null)
	_check("SaveCloud: save_to_local he thong null tra khong-co-game-system",
		not bool(r_null.get("ok", true))
		and String(r_null.get("reason", "")) == "khong-co-game-system", str(r_null))


func _test_apply_save() -> void:
	var cloud := _new_cloud()
	var built := cloud.build_save_json(_sys(7))
	var target := {"ten_nguoi_choi": "Cu", "gi_nguyen": 123}
	var r := cloud.apply_save(built["save"], target)
	_check("SaveCloud: apply_save ok + chep field vao dict dich",
		bool(r.get("ok", false)) and int(target["pxb_time"]["game_day"]) == 7
		and String(target["ten_nguoi_choi"]) == "An", str(target))
	_check("SaveCloud: apply_save giu field hien co khong co trong save",
		int(target["gi_nguyen"]) == 123)
	var r2 := cloud.apply_save({}, target)
	_check("SaveCloud: apply_save({}) tra save-khong-hop-le",
		not bool(r2.get("ok", true))
		and String(r2.get("reason", "")) == "save-khong-hop-le", str(r2))
	var r3 := cloud.apply_save({"version": PxbSaveCloud.SAVE_VERSION}, target)
	_check("SaveCloud: apply_save thieu gameSystem tra save-khong-hop-le",
		not bool(r3.get("ok", true))
		and String(r3.get("reason", "")) == "save-khong-hop-le", str(r3))


func _test_upload_download() -> void:
	var cloud := _new_cloud()
	var up0 := cloud.upload_save(1)
	_check("SaveCloud: upload khi chua login tra chua-dang-nhap",
		not bool(up0.get("ok", true))
		and String(up0.get("reason", "")) == "chua-dang-nhap", str(up0))
	var down0 := cloud.download_save(1)
	_check("SaveCloud: download khi chua login tra chua-dang-nhap",
		not bool(down0.get("ok", true))
		and String(down0.get("reason", "")) == "chua-dang-nhap", str(down0))
	cloud.login("nguoi-choi-1")
	var up1 := cloud.upload_save(1)
	_check("SaveCloud: upload khi da login tra server-chua-co-endpoint",
		not bool(up1.get("ok", true))
		and String(up1.get("reason", "")) == "server-chua-co-endpoint", str(up1))
	var st_up := cloud.sync_status()
	_check("SaveCloud: sau upload loi, sync_status loi + detail ghi endpoint upload",
		String(st_up.get("status", "")) == "loi"
		and String(st_up.get("detail", "")).contains("/save/upload"), str(st_up))
	var down2 := cloud.download_save(2)
	_check("SaveCloud: download khi da login tra server-chua-co-endpoint",
		not bool(down2.get("ok", true))
		and String(down2.get("reason", "")) == "server-chua-co-endpoint", str(down2))
	var up_bad := cloud.upload_save(0)
	var down_bad := cloud.download_save(4)
	_check("SaveCloud: upload/download slot sai tra slot-khong-hop-le",
		String(up_bad.get("reason", "")) == "slot-khong-hop-le"
		and String(down_bad.get("reason", "")) == "slot-khong-hop-le")
	var st := cloud.sync_status()
	_check("SaveCloud: sau download loi, sync_status loi + detail ghi endpoint download",
		String(st.get("status", "")) == "loi"
		and String(st.get("detail", "")).contains("/save/download"), str(st))


func _test_sync_status() -> void:
	var cloud := _new_cloud()
	var st0 := cloud.sync_status()
	_check("SaveCloud: moi tao sync_status chua-dong-bo, at 0, accountId rong",
		String(st0.get("status", "")) == "chua-dong-bo"
		and int(st0.get("at", -1)) == 0 and String(st0.get("accountId", "x")) == "",
		str(st0))
	cloud.save_to_local(1, _sys(7))
	var st1 := cloud.sync_status()
	_check("SaveCloud: sau save local sync_status local-ok, at > 0, detail ghi slot",
		String(st1.get("status", "")) == "local-ok"
		and int(st1.get("at", 0)) > 0
		and String(st1.get("detail", "")).contains("da-luu-local-slot-1"), str(st1))


func _test_data() -> void:
	var cloud := _new_cloud()
	cloud.login("nguoi-choi-1")
	cloud.save_to_local(1, _sys(7))
	var saved: Dictionary = cloud.data()
	var cloud2 := _new_cloud()
	cloud2.from_data(saved)
	_check("SaveCloud: data round-trip giu login + accountId",
		cloud2.is_logged_in() and cloud2.account_id() == "nguoi-choi-1")
	_check("SaveCloud: data round-trip giu localSlots slot 1 (file)",
		cloud2.local_slots.has("1")
		and String(cloud2.local_slots["1"]["where"]) == "file")
	var dirty := {
		"accountId": 123,
		"lastSyncAt": "khong-phai-so",
		"lastSyncStatus": "trang-thai-la",
		"lastSyncDetail": 42,
		"localSlots": {
			"9": {"at": 1, "compressed": true, "where": "file"},
			"1": "khong-phai-dict",
			"2": {"at": -5, "compressed": "yes", "where": "cho-la"},
			"3": {"at": 12345, "compressed": true, "where": "memory"},
		},
	}
	var cloud3 := _new_cloud()
	cloud3.from_data(dirty)
	_check("SaveCloud: from_data bo accountId khong phai chuoi + status la + at/detail ban",
		not cloud3.is_logged_in()
		and cloud3.last_sync_status == "chua-dong-bo"
		and cloud3.last_sync_at == 0 and cloud3.last_sync_detail == "")
	_check("SaveCloud: from_data bo slot la (9) + mo ta slot khong phai dict (1)",
		not cloud3.local_slots.has("9") and not cloud3.local_slots.has("1"))
	_check("SaveCloud: from_data khu ban slot 2 (at am ve 0, compressed ve false, where ve file)",
		cloud3.local_slots.has("2") and int(cloud3.local_slots["2"]["at"]) == 0
		and not bool(cloud3.local_slots["2"]["compressed"])
		and String(cloud3.local_slots["2"]["where"]) == "file")
	_check("SaveCloud: from_data giu slot 3 hop le (memory, at 12345)",
		cloud3.local_slots.has("3") and int(cloud3.local_slots["3"]["at"]) == 12345
		and bool(cloud3.local_slots["3"]["compressed"])
		and String(cloud3.local_slots["3"]["where"]) == "memory")
	var cloud4 := _new_cloud()
	cloud4.login("nguoi-choi-9")
	cloud4.from_data({})
	_check("SaveCloud: from_data({}) reset ve mac dinh (het login, chua-dong-bo, 0 slot)",
		not cloud4.is_logged_in()
		and cloud4.last_sync_status == "chua-dong-bo"
		and cloud4.local_slots.is_empty())
	var copy: Dictionary = cloud.data()
	copy["localSlots"]["1"]["where"] = "DOI"
	_check("SaveCloud: data() tra ban sao — sua ban sao khong doi cloud",
		String(cloud.local_slots["1"]["where"]) == "file")
	_check("SaveCloud: default_data() dung mac dinh",
		PxbSaveCloud.default_data() == {"accountId": "",
			"lastSyncAt": 0, "lastSyncStatus": "chua-dong-bo",
			"lastSyncDetail": "", "localSlots": {}})


func _test_reset_state() -> void:
	var cloud := _new_cloud()
	cloud.login("nguoi-choi-1")
	cloud.save_to_local(1, _sys(7))
	_check("SaveCloud: reset_state tra true",
		cloud.reset_state())
	_check("SaveCloud: reset_state xoa login + sync + localSlots",
		not cloud.is_logged_in()
		and cloud.last_sync_status == "chua-dong-bo"
		and cloud.local_slots.is_empty())
	var l1 := cloud.load_from_local(1)
	_check("SaveCloud: reset_state khong xoa file save (load slot 1 van duoc, dung JS)",
		bool(l1.get("ok", false)) and int(l1["save"]["gameDay"]) == 7, str(l1))
