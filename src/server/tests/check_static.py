#!/usr/bin/env python3
"""Kiểm tra tĩnh repo Phố Xô Bồ — CHƯA phải build / test chạy được.

Chạy:  python3 src/server/tests/check_static.py
       (chạy từ thư mục gốc repo ~/workspace/pho-xo-bo)

VM này không có dotnet / Unity / csc nên không biên dịch được code C#.
Script này chỉ kiểm tra được:
  1. Ngoặc {} () [] cân bằng ở mọi file .cs (không chứng minh code đúng ngữ nghĩa).
  2. Số chốt (18 khu, 5 bậc học, lãi 0,5%, phí 5%, bỏ bê 7 ngày, +20% EXP,
     solo 30–50%, thang nhà, rank Chương 5) khớp giữa GameBalance.cs và docs.
  3. Social.cs / Economy.cs dùng đúng hằng GameBalance, không hardcode số chốt.
  4. Không có secret / token / key trong file .cs.
  5. Ranh giới pháp lý: các hàm CashOut / LendWithInterest / Gamble /
     BuyWithRealMoney trong Economy.cs phải luôn trả false.
  6. Không có asset có bản quyền trong repo (assets/ phải trống hoặc chỉ CC0
     có ghi nguồn — hiện tại đang trống, đúng trạng thái).
  8. File .cs server (src/server/src/) cũng được quét: ngoặc cân bằng, số
     chốt khớp GameBalance.cs, ranh giới pháp lý, không secret, UTF-8.
     (Trước 18/11 chỉ quét file client; EconomyLedger.cs từng chỉ được kiểm
     bằng script tạm trong /tmp — nay đã đưa vào script chính.)
  9. File test EditMode (src/client/Assets/Tests/EditMode/): số lượng test
     khớp, dùng NUnit, ngoặc cân bằng, UTF-8 — và kiểm tra hồi quy cho bug
     Divorce đã sửa 18/11 (điều kiện || thay vì &&).

Thoát 0 = tất cả PASS. Thoát 1 = có FAIL — xem docs/test-report.md.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]  # tests -> server -> src -> repo root
SCRIPTS = ROOT / "src" / "client" / "Assets" / "Scripts"
DOCS = ROOT / "docs"

results = []  # (id, name, passed, detail)


def check(cid, name, passed, detail=""):
    results.append((cid, name, passed, detail))


def read(path):
    return path.read_text(encoding="utf-8")


def strip_strings_comments(code):
    # Bỏ chuỗi "..." và comment //... /*...*/ để đếm ngoặc không bị lệch.
    code = re.sub(r'//.*', '', code)
    code = re.sub(r'/\*.*?\*/', '', code, flags=re.S)
    code = re.sub(r'"(?:\\.|[^"\\])*"', '""', code)
    code = re.sub(r"'(?:\\.|[^'\\])*'", "''", code)
    return code


# ---- 1. Ngoặc cân bằng ----
cs_files = sorted(SCRIPTS.glob("*.cs"))
for f in cs_files:
    clean = strip_strings_comments(read(f))
    pairs = [("{", "}"), ("(", ")"), ("[", "]")]
    ok, detail = True, ""
    for o, c in pairs:
        if clean.count(o) != clean.count(c):
            ok = False
            detail += f"{o}{c}: {clean.count(o)} vs {clean.count(c)}; "
    check(f"T1-{f.name}", f"Ngoặc cân bằng {f.name}", ok, detail or "cân bằng")

# ---- 2. Số chốt khớp giữa GameBalance.cs và docs ----
gb = read(SCRIPTS / "GameBalance.cs")
gdd = read(DOCS / "gdd.md")
districts_doc = read(DOCS / "districts.md")
district_cs = read(SCRIPTS / "District.cs")
economy_doc = read(DOCS / "economy.md")

# 2a. 18 khu: District.cs dùng target-typed new(1, ...) — đếm entry new(số, "tên", Tier).
district_entries = len(re.findall(r"new\(\d+,\s*\"", district_cs))
check("T2a", "18 khu — District.cs", district_entries == 18, f"{district_entries} entry")
check("T2b", "18 khu — docs/districts.md nhắc 18 khu", "18 khu" in districts_doc,
      "không thấy chuỗi '18 khu'" if "18 khu" not in districts_doc else "có '18 khu'")

# 2b. 5 bậc học trong GameBalance.cs
degrees = len(re.findall(r'new\("', gb))
check("T2c", "5 bậc học — GameBalance.cs", degrees == 5, f"{degrees} bậc")
for token in ["20_000_000", "80_000_000", "200_000_000", "500_000_000"]:
    check(f"T2d-{token}", f"Học phí {token} có trong GameBalance.cs", token in gb)

# 2c. Lãi / phí / xã hội
check("T2e", "Lãi tiết kiệm 0,5%/tháng", "0.005" in gb and "BankInterestPerGameMonth" in gb)
check("T2f", "Phí đấu giá 5%", "AuctionFeePercent = 5" in gb)
check("T2g", "Bỏ bê 7 ngày", "NeglectDaysToDropCloseness = 7" in gb)
check("T2h", "Hỗ trợ +20% EXP", "SupportedExpBonusPercent = 20" in gb)
check("T2i", "Solo chậm 30–50%", "SoloSlowerPercentMin = 30" in gb and "SoloSlowerPercentMax = 50" in gb)
check("T2j", "Mua lớn +50 Danh vọng", "BigPurchaseFameBonus = 50" in gb)

# 2d. Thang nhà 6 bậc
for token, label in [
    ("RoomRentPerMonthVnd = 2_000_000", "trọ 2tr/tháng"),
    ("MiniApartmentVnd = 800_000_000", "mini 800tr"),
    ("SmallTownhouseVnd = 3_000_000_000", "phố nhỏ 3 tỉ"),
    ("LargeTownhouseVnd = 8_000_000_000", "phố lớn 8 tỉ"),
    ("VillaVnd = 25_000_000_000", "biệt thự 25 tỉ"),
    ("PenthouseIslandVnd = 100_000_000_000", "penthouse/đảo 100 tỉ"),
]:
    check(f"T2k-{label}", f"Thang nhà: {label}", token in gb)

# 2e. Rank Chương 5
check("T2l", "Giám đốc tài sản 10 tỉ", "DirectorAssetsVnd = 10_000_000_000" in gb)
check("T2m", "Siêu giàu tài sản 100 tỉ", "SuperRichAssetsVnd = 100_000_000_000" in gb)
check("T2n", "Ending gia đình An Yên 80", "FamilyEndingAnYen = 80" in gb)

# 2f. GDD nhắc đúng các số chốt chính
for token, label in [("0,5%", "lãi 0,5% trong GDD"), ("5%", "phí 5% trong GDD"),
                     ("7 ngày", "bỏ bê 7 ngày trong GDD"), ("+20% EXP", "+20% EXP trong GDD")]:
    check(f"T2o-{label}", f"GDD nhắc {label}", token in gdd)

# ---- 3. Social.cs / Economy.cs dùng đúng hằng GameBalance ----
social = read(SCRIPTS / "Social.cs")
economy = read(SCRIPTS / "Economy.cs")
check("T3a", "Social.cs dùng NeglectDaysToDropCloseness",
      "GameBalance.NeglectDaysToDropCloseness" in social)
check("T3b", "Social.cs dùng SupportedExpBonusPercent",
      "GameBalance.SupportedExpBonusPercent" in social)
check("T3c", "Social.cs không hardcode số 7 ngày riêng",
      social.count("= 7") == 0, "tìm thấy '= 7' trong Social.cs" if "= 7" in social else "")
check("T3d", "Economy.cs dùng BankInterestPerGameMonth",
      "GameBalance.BankInterestPerGameMonth" in economy)
check("T3e", "Economy.cs dùng AuctionFeePercent",
      "GameBalance.AuctionFeePercent" in economy)
check("T3f", "Economy.cs dùng BigPurchaseFameBonus",
      "GameBalance.BigPurchaseFameBonus" in economy)
check("T3g", "Economy.cs thang nhà dùng GameBalance (không hardcode 800_000_000...)",
      "GameBalance.MiniApartmentVnd" in economy and "800_000_000" not in economy)

# ---- 4. Không có secret trong file .cs ----
secret_pat = re.compile(r"(?i)(password\s*=|api[_-]?key\s*=|secret\s*=|token\s*=\s*[\"'][A-Za-z0-9]{16,}|private\s+key|-----BEGIN)")
bad = [f.name for f in cs_files if secret_pat.search(read(f))]
check("T4", "Không có secret/token/key trong file .cs", not bad, f"nghi ngờ ở: {bad}" if bad else "")

# ---- 5. Ranh giới pháp lý: hàm cấm luôn trả false ----
for fn in ["CashOut", "LendWithInterest", "Gamble", "BuyWithRealMoney"]:
    m = re.search(rf"public bool {fn}\([^)]*\)\s*=>\s*false;", economy)
    check(f"T5-{fn}", f"{fn} luôn trả false (bị chặn)", m is not None,
          f"không tìm thấy '{fn} => false' trong Economy.cs" if m is None else "")

# ---- 6. assets/ trống (chưa có art) hoặc chỉ CC0 có nguồn ----
assets = ROOT / "assets"
asset_files = [p for p in assets.rglob("*") if p.is_file()] if assets.exists() else []
check("T6", "assets/ trống — chưa đưa asset nào vào (không asset lậu)",
      len(asset_files) == 0, f"{len(asset_files)} file" if asset_files else "")

# ---- 7. File .cs đều UTF-8 (đọc được ở trên đã chứng minh một phần) ----
bad_utf8 = []
for f in cs_files:
    try:
        f.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        bad_utf8.append(f.name)
check("T7", "Mọi file .cs đều UTF-8", not bad_utf8, str(bad_utf8) if bad_utf8 else "")

# ---- 8. File .cs server (src/server/src/) ----
# EconomyLedger.cs từng chỉ được kiểm bằng script tạm trong /tmp (xem
# docs/test-report.md) — từ nay quét chung trong script chính.
SERVER_SRC = ROOT / "src" / "server" / "src"
server_cs_files = sorted(SERVER_SRC.glob("*.cs"))
for f in server_cs_files:
    clean = strip_strings_comments(read(f))
    pairs = [("{", "}"), ("(", ")"), ("[", "]")]
    ok, detail = True, ""
    for o, c in pairs:
        if clean.count(o) != clean.count(c):
            ok = False
            detail += f"{o}{c}: {clean.count(o)} vs {clean.count(c)}; "
    check(f"T8a-{f.name}", f"Ngoặc cân bằng server {f.name}", ok, detail or "cân bằng")

ledger = read(SERVER_SRC / "EconomyLedger.cs") if (SERVER_SRC / "EconomyLedger.cs").exists() else ""
check("T8b", "EconomyLedger lãi 0,5% khớp GameBalance",
      "BankInterestPerGameMonth = 0.005" in ledger)
check("T8c", "EconomyLedger phí đấu giá 5% khớp GameBalance",
      "AuctionFeePercent = 5" in ledger)
check("T8d", "EconomyLedger 1 tháng game = 30 ngày (PROVISIONAL, khớp Economy.cs)",
      "DaysPerGameMonth = 30" in ledger)
# Ranh giới pháp lý server: các hàm cấm phải ném InvalidOperationException.
for fn in ["CashOut", "LendWithInterest", "Gamble", "BuyWithRealMoney"]:
    m = re.search(rf"public void {fn}\([^)]*\)\s*=>\s*\n?\s*throw new InvalidOperationException", ledger)
    check(f"T8e-{fn}", f"EconomyLedger.{fn} ném InvalidOperationException (bị chặn)",
          m is not None, f"không tìm thấy '{fn} => throw' trong EconomyLedger.cs" if m is None else "")
bad_server = [f.name for f in server_cs_files if secret_pat.search(read(f))]
check("T8f", "Không có secret/token/key trong file .cs server", not bad_server,
      f"nghi ngờ ở: {bad_server}" if bad_server else "")
bad_server_utf8 = []
for f in server_cs_files:
    try:
        f.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        bad_server_utf8.append(f.name)
check("T8g", "Mọi file .cs server đều UTF-8", not bad_server_utf8,
      str(bad_server_utf8) if bad_server_utf8 else "")
# Program.cs phải nối EconomyLedger (singleton) — C5: ledger chưa nối thì
# endpoint /ledger/* không có gì để gọi; /health vẫn giữ nguyên.
program = read(SERVER_SRC / "Program.cs") if (SERVER_SRC / "Program.cs").exists() else ""
check("T8h", "Program.cs đăng ký EconomyLedger singleton",
      "AddSingleton<EconomyLedger>" in program)
check("T8i", "Program.cs giữ endpoint /health",
      '"/health"' in program)

# ---- 9. File test EditMode (src/client/Assets/Tests/EditMode/) ----
# C6: test chạy được sau này có cái mà test — kiểm tra tĩnh đếm số test,
# bắt đúng framework, và khóa hồi quy bug Divorce đã sửa 18/11.
EDITMODE = ROOT / "src" / "client" / "Assets" / "Tests" / "EditMode"
editmode_files = sorted(EDITMODE.glob("*.cs"))
expected_tests = {
    "JobsPayTests.cs": 28,
    "TimeSystemTests.cs": 10,
    "SocialTests.cs": 22,
    "EconomyTests.cs": 22,
}
check("T9a", "Đủ 4 file test EditMode gốc (Jobs/TimeSystem/Social/Economy)",
      set(expected_tests) <= {f.name for f in editmode_files},
      f"có: {[f.name for f in editmode_files]}" if not set(expected_tests) <= {f.name for f in editmode_files} else "")
for fname, expected in expected_tests.items():
    fpath = EDITMODE / fname
    if not fpath.exists():
        check(f"T9b-{fname}", f"{fname} tồn tại", False, "thiếu file")
        continue
    content = read(fpath)
    n_tests = len(re.findall(r"\[Test\]", content))
    n_methods = len(re.findall(r"public void \w+\(", content))
    check(f"T9b-{fname}", f"{fname}: {expected} test method",
          n_tests == expected and n_methods == expected,
          f"[Test]={n_tests}, public void={n_methods}, kỳ vọng {expected}")
    clean = strip_strings_comments(content)
    ok, detail = True, ""
    for o, c in [("{", "}"), ("(", ")"), ("[", "]")]:
        if clean.count(o) != clean.count(c):
            ok = False
            detail += f"{o}{c}: {clean.count(o)} vs {clean.count(c)}; "
    check(f"T9c-{fname}", f"Ngoặc cân bằng {fname}", ok, detail or "cân bằng")
    check(f"T9d-{fname}", f"{fname} dùng NUnit + namespace PhoXoBo.Tests",
          "using NUnit.Framework;" in content and "namespace PhoXoBo.Tests" in content)
# T9e: hồi quy bug Divorce 18/11 — Social.cs phải dùng || (Spouse VÀ Cuoi),
# không còn && (chỉ cần 1 trong 2 là ly hôn được). Chỉ xét dòng điều kiện if,
# không xét comment (comment vẫn nhắc lại ký tự && của bug cũ).
divorce_m = re.search(r"if \(rel == null[^;]*\) return false;", social)
divorce_ok = divorce_m is not None and "||" in divorce_m.group(0) and "&&" not in divorce_m.group(0)
check("T9e", "Divorce: Spouse VÀ Cuoi mới ly hôn được (||, không &&)",
      divorce_ok, "không tìm thấy điều kiện Divorce dùng ||" if not divorce_ok else "")
# T9f: test EditMode phải có test khóa hành vi đã sửa (Spouse chưa cưới ly hôn false).
social_tests = read(EDITMODE / "SocialTests.cs")
check("T9f", "SocialTests có test Spouse chưa cưới ly hôn false",
      "Divorce_SpouseChuaCuoi_TraFalse" in social_tests)
bad_test_utf8 = []
for f in editmode_files:
    try:
        f.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        bad_test_utf8.append(f.name)
check("T9g", "Mọi file test EditMode đều UTF-8", not bad_test_utf8,
      str(bad_test_utf8) if bad_test_utf8 else "")
bad_test_secret = [f.name for f in editmode_files if secret_pat.search(read(f))]
check("T9h", "Không có secret/token/key trong file test EditMode", not bad_test_secret,
      f"nghi ngờ ở: {bad_test_secret}" if bad_test_secret else "")

# ---- 10. File test EditMode đợt 2 (18/11 ~18:45) ----
# C6 tiếp: phủ nốt 6 module logic thuần còn lại (Inventory/Crafting/
# Exploration/PlayerProgress/District+TitleConflict/PhoneHub) — tổng EditMode
# nay 207 test (82 cũ + 125 mới). Vẫn chưa chạy được (cần Unity 2022 LTS).
expected_tests_2 = {
    "InventoryTests.cs": 19,
    "CraftingTests.cs": 18,
    "ExplorationTests.cs": 19,
    "PlayerProgressTests.cs": 30,
    "DistrictTests.cs": 33,
    "PhoneHubTests.cs": 18,
}
check("T10a", "Đủ 6 file test EditMode đợt 2",
      set(expected_tests_2) <= {f.name for f in editmode_files},
      f"thiếu: {sorted(set(expected_tests_2) - {f.name for f in editmode_files})}" if not set(expected_tests_2) <= {f.name for f in editmode_files} else "")
for fname, expected in expected_tests_2.items():
    fpath = EDITMODE / fname
    if not fpath.exists():
        check(f"T10b-{fname}", f"{fname} tồn tại", False, "thiếu file")
        continue
    content = read(fpath)
    n_tests = len(re.findall(r"\[Test\]", content))
    n_methods = len(re.findall(r"public void \w+\(", content))
    check(f"T10b-{fname}", f"{fname}: {expected} test method",
          n_tests == expected and n_methods == expected,
          f"[Test]={n_tests}, public void={n_methods}, kỳ vọng {expected}")
    clean = strip_strings_comments(content)
    ok, detail = True, ""
    for o, c in [("{", "}"), ("(", ")"), ("[", "]")]:
        if clean.count(o) != clean.count(c):
            ok = False
            detail += f"{o}{c}: {clean.count(o)} vs {clean.count(c)}; "
    check(f"T10c-{fname}", f"Ngoặc cân bằng {fname}", ok, detail or "cân bằng")
    check(f"T10d-{fname}", f"{fname} dùng NUnit + namespace PhoXoBo.Tests",
          "using NUnit.Framework;" in content and "namespace PhoXoBo.Tests" in content)
    check(f"T10e-{fname}", f"{fname} không dùng UnityEngine (logic thuần)",
          "UnityEngine" not in content)
# T10f: mỗi file test đợt 2 phải nhắc đúng API thật đang test (không bịa API).
api_markers = {
    "InventoryTests.cs": ["ItemCatalog", "BuffFor", "EndFrame"],
    "CraftingTests.cs": ["ToolBehaviour", "CanCraft", "MissingIngredients"],
    "ExplorationTests.cs": ["HotspotsInDistrict", "CanFastTravel", "GuideHint"],
    "PlayerProgressTests.cs": ["CanOpenChapter", "SuggestEnding", "RankAtRisk"],
    "DistrictTests.cs": ["Districts.All", "IsBlocked", "ExpectedCount"],
    "PhoneHubTests.cs": ["TabOrder", "SelectTab", "TotalUnread"],
}
for fname, markers in api_markers.items():
    content = read(EDITMODE / fname)
    missing = [m for m in markers if m not in content]
    check(f"T10f-{fname}", f"{fname} nhắc đúng API thật", not missing,
          f"thiếu: {missing}" if missing else "")

# ---- 11. Hồi quy 4 bug đã sửa 18/11 ~19:50 (đợt này) ----
# Các hành vi lạ ghi ở docs/test-report.md đợt 18:50 nay đã sửa bằng code:
# Inventory.Add đồ không stackable, Inventory.Use ghi đè khung buff,
# Crafting.Craft để lại key = 0, Exploration.Explore không dùng gameDay,
# TitleConflict.IsBlocked chỉ chặn một chiều + phân biệt hoa/thường.
inventory = read(SCRIPTS / "Inventory.cs")
crafting = read(SCRIPTS / "Crafting.cs")
exploration = read(SCRIPTS / "Exploration.cs")
title_conflict = read(SCRIPTS / "TitleConflict.cs")
inventory_tests = read(EDITMODE / "InventoryTests.cs")
crafting_tests = read(EDITMODE / "CraftingTests.cs")
exploration_tests = read(EDITMODE / "ExplorationTests.cs")
district_tests = read(EDITMODE / "DistrictTests.cs")

check("T11a", "Inventory.Add: đồ không stackable quantity > 1 trả false (all-or-nothing)",
      "quantity > 1 || Count(itemId) > 0" in inventory)
check("T11b", "Inventory.Use: không còn ghi đè khung buff bằng currentFrame",
      "with { Frame = currentFrame }" not in strip_strings_comments(inventory)
      and "def.Effect" in inventory)
check("T11c", "InventoryTests có 4 test hồi quy Add/Use 18/11",
      all(t in inventory_tests for t in [
          "Add_DoKhongStackable_DaCo1RoiThem2_TraFalseVaGiu1",
          "Add_DoKhongStackable_Them2ThatBai_RoiThem1ThanhCong",
          "Use_BuffCatalogKhungChieu_DungLucToi_VanVaoChieu",
          "Use_BuffCatalogKhungSang_DungLucChieu_EndFrameTheoKhungCatalog"]))
check("T11d", "Crafting.Craft: nguyên liệu về 0 thì xóa key",
      "materials.Remove(materialId)" in crafting)
check("T11e", "CraftingTests có 2 test hồi quy xóa key 18/11",
      "Craft_CheHet1Loai_XoaKey_NguyenLieuKhacConNguyen" in crafting_tests
      and "Craft_Che2LanLienTiep_XoaKeyDanVaTraNullKhiHet" in crafting_tests)
check("T11f", "Exploration.Explore: tự reset khi gameDay khác ngày đã lưu",
      "_currentDay" in exploration and "NewGameDay(visitedToday)" in exploration)
check("T11g", "ExplorationTests có 3 test hồi quy tự reset ngày 18/11",
      all(t in exploration_tests for t in [
          "Explore_DoiGameDay_TuResetVaKhamPhaLaiDuoc",
          "Explore_DoiGameDay_TuResetCaHotspotKhac",
          "Explore_DoiGameDayVeNgayCu_CungTuReset"]))
check("T11h", "TitleConflict.IsBlocked: chặn 2 chiều + không phân biệt hoa/thường",
      "OrdinalIgnoreCase" in title_conflict
      and "BlockedBy.TryGetValue(wantedTitleOrJob" in title_conflict)
check("T11i", "DistrictTests có 4 test hồi quy chặn 2 chiều / hoa-thường 18/11",
      all(t in district_tests for t in [
          "IsBlocked_ChanNguoc_TuongCuopVaTrumBuonLau",
          "IsBlocked_ChanNguoc_CacCapConLai",
          "IsBlocked_ChanNguoc_KhongChanSai",
          "IsBlocked_KhongPhanBietHoaThuong_HonHop"]))
# T11j: tổng EditMode nay 219 test (207 cũ + 12 mới đợt này).
total_tests = sum(len(re.findall(r"\[Test\]", read(f))) for f in editmode_files)
check("T11j", "Tổng test EditMode = 219 (207 + 12 hồi quy đợt này)",
      total_tests == 219, f"đếm được {total_tests}")

# ---- 12. Scene slice C2 (18/11 ~20:50, đợt này) ----
# 4/4 khu slice đầu nay đã có khung scene: Xóm Trọ Cũ, Chợ Đầu Mối,
# Công Viên An Bình, Phố Đi Bộ – Chợ Đêm — mỗi scene có GameManager +
# Player + CameraFollowBehaviour + đúng hotspot trong Exploration.Hotspots.
# Vẫn là khung file, CHƯA verify mở bằng Unity (cần Unity 2022.3.62f1).
SCENES = ROOT / "src" / "client" / "Assets" / "Scenes"
slice_scenes = {
    "SliceXomTroCu.unity": ["hs-tro-toi"],
    "SliceChoDauMoi.unity": ["hs-cho-sang", "hs-cho-chieu"],
    "SliceCongVienAnBinh.unity": ["hs-cong-vien"],
    "SlicePhoDiBoChoDem.unity": ["hs-cho-dem"],
}
check("T12a", "Đủ 4 file scene slice + .meta kèm theo",
      all((SCENES / name).exists() and (SCENES / (name + ".meta")).exists()
          for name in slice_scenes),
      f"thiếu: {[n for n in slice_scenes if not (SCENES / n).exists()]}" if not all((SCENES / n).exists() for n in slice_scenes) else "")
scene_guids = []
for name in slice_scenes:
    meta = SCENES / (name + ".meta")
    if meta.exists():
        m = re.search(r"guid: ([0-9a-f]{32})", read(meta))
        scene_guids.append(m.group(1) if m else "?")
check("T12b", "GUID .meta 4 scene slice khác nhau",
      len(set(scene_guids)) == 4 and "?" not in scene_guids,
      f"guids: {scene_guids}" if len(set(scene_guids)) != 4 else "")
# HotspotId trong Exploration.Hotspots (không bịa hotspot mới).
exploration_ids = set(re.findall(r'new\("(hs-[a-z-]+)"', exploration))
for name, expected_ids in slice_scenes.items():
    content = read(SCENES / name)
    found_ids = re.findall(r"hotspotId: (hs-[a-z-]+)", content)
    check(f"T12c-{name}", f"{name}: đúng hotspot {expected_ids}",
          sorted(found_ids) == sorted(expected_ids),
          f"tìm thấy: {found_ids}" if sorted(found_ids) != sorted(expected_ids) else "")
    missing = [h for h in found_ids if h not in exploration_ids]
    check(f"T12d-{name}", f"{name}: hotspotId có trong Exploration.Hotspots",
          not missing, f"không có trong code: {missing}" if missing else "")
    # Mỗi scene phải có đủ bộ khung C2: GameManager + Player + Camera follow + ortho.
    check(f"T12e-{name}", f"{name}: có GameManager + Player + CameraFollow + ortho",
          "m_Name: GameManagerBehaviour" in content
          and "m_Name: PlayerController" in content
          and "m_Name: CameraFollowBehaviour" in content
          and "m_Orthographic: 1" in content)
# T12f: mô tả verbatim 4 khu (art-style.md §4) có trong đúng scene của nó.
verbatim = {
    "SliceXomTroCu.unity": "hem nho Sai Gon",
    "SliceChoDauMoi.unity": "cho dau moi luc 5 gio sang",
    "SliceCongVienAnBinh.unity": "công viên buổi chiều",
    "SlicePhoDiBoChoDem.unity": "phố đi bộ ban đêm",
}
for name, phrase in verbatim.items():
    check(f"T12f-{name}", f"{name}: có mô tả verbatim khu",
          phrase in read(SCENES / name), f"không thấy '{phrase}'" if phrase not in read(SCENES / name) else "")
# T12g: 2 scene 1-hotspot không còn khối hotspot thừa (fileID 200080–200082).
for name in ["SliceCongVienAnBinh.unity", "SlicePhoDiBoChoDem.unity"]:
    content = read(SCENES / name)
    check(f"T12g-{name}", f"{name}: không còn fileID hotspot thừa 200080–200082",
          "200080" not in content and "200081" not in content and "200082" not in content)
# T12h: không còn dòng "doi scene khu rieng (chua tao)" — 4/4 scene đã có khung.
stale = [n for n in slice_scenes if "doi scene khu rieng (chua tao)" in read(SCENES / n)]
check("T12h", "Không còn ghi 'doi scene khu rieng (chua tao)' trong scene slice",
      not stale, f"còn ở: {stale}" if stale else "")
# T12i: script GUID trong scene khớp GUID .meta của file script (không bịa GUID).
script_guids = {
    "CameraFollowBehaviour": "b47485bf41524aef9420a3919465d89c",
    "GameManagerBehaviour": "765b24e3fb5d469f91aa8ce876756c4d",
    "PlayerController": "23c238a56c0543ec914294648218364d",
    "HotspotView": "b00dbcf48e09433cb7f973d11b2ddec9",
}
for name in slice_scenes:
    content = read(SCENES / name)
    ok_guid = all(g in content for g in script_guids.values())
    check(f"T12i-{name}", f"{name}: script GUID khớp file script thật",
          ok_guid, "thiếu GUID script" if not ok_guid else "")
# T12j: SliceRoot của 2 scene mới liệt kê đúng 3 con (khu + NOTE + 1 hotspot).
for name in ["SliceCongVienAnBinh.unity", "SlicePhoDiBoChoDem.unity"]:
    content = read(SCENES / name)
    m = re.search(r"m_Name: SliceRoot.*?m_Children:\n((?:  - \{fileID: \d+\}\n)+)", content, flags=re.S)
    kids = re.findall(r"\{fileID: (\d+)\}", m.group(1)) if m else []
    check(f"T12j-{name}", f"{name}: SliceRoot có đúng 3 con (200031/200041/200071)",
          kids == ["200031", "200041", "200071"], f"con: {kids}" if kids != ["200031", "200041", "200071"] else "")

# ---- In kết quả ----
passed = sum(1 for _, _, ok, _ in results if ok)
failed = [r for r in results if not r[2]]
print(f"Kiểm tra tĩnh Phố Xô Bồ — {passed}/{len(results)} PASS")
for cid, name, ok, detail in results:
    print(f"  [{'PASS' if ok else 'FAIL'}] {cid} {name}" + (f" — {detail}" if detail else ""))
if failed:
    print(f"\n{len(failed)} FAIL — chưa phải bản test được. Xem docs/test-report.md.")
    sys.exit(1)
print("\nTất cả kiểm tra tĩnh PASS — lưu ý: đây KHÔNG phải build/test chạy được.")
print("Cần máy có Unity 2022 LTS + .NET 8 SDK mới biên dịch và chơi được thật.")
