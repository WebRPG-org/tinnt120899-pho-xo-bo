#!/usr/bin/env python3
"""Kiểm tra tĩnh repo Phố Xô Bồ — CHƯA phải build / test chạy được.

Chạy:  python3 src/server/tests/check_static.py
       (chạy từ thư mục gốc repo ~/workspace/pho-xo-bo)

VM này không có Unity / csc nên không biên dịch được code C#.
dotnet 8.0.428 có ở ~/.dotnet (không trong PATH) nhưng `dotnet test` vẫn
kẹt RAM — chạy qua GitHub Actions; node v24 có sẵn nên `node --check`
chạy được cho file JS nadia (nhóm T14).
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
 14. Khung Nadia Giai đoạn 1 (src/nadia/www/): thứ tự load index.html,
     MapInfos đủ 18 khu, Map001/002 đúng hotspot/NPC/cửa theo C#,
     PXB_Balance.js khớp số C#, PXB_Isometric.js đúng phép chiếu 2:1,
     node --check 4 file JS, Actors/Classes/Items chéo tham chiếu.

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

# ---- Nhóm T13: spec art chi tiết khu 17/18 (docs/art-assets.md §3/§4) ----
# Follow-up C2 (roles-qc.md §6): art-assets.md trước đây chỉ có khu 1–2.
art_assets = read(DOCS / "art-assets.md")
check("T13a", "art-assets.md: có mục riêng khu 17 (§3) + khu 18 (§4)",
      "## 3. Khu 17 — Công Viên An Bình" in art_assets
      and "## 4. Khu 18 — Phố Đi Bộ – Chợ Đêm" in art_assets)
check("T13b", "art-assets.md: tiêu đề đã là 4 khu slice đầu",
      "4 khu slice đầu" in art_assets)
# Verbatim 4 khu (art-style.md §4) phải có trong đúng mục spec của nó.
check("T13c", "art-assets.md §3: có mô tả verbatim khu 17",
      "công viên buổi chiều, cây xanh, ghế đá, người già" in art_assets)
check("T13d", "art-assets.md §4: có mô tả verbatim khu 18",
      "phố đi bộ ban đêm, đèn lồng vàng, sạp ăn vặt" in art_assets)
# Hotspot trong spec phải khớp đúng Exploration.cs (id + vật + số lượng + khung).
check("T13e", "art-assets.md §3: hs-cong-vien nhặt Ván gỗ ×1, khung Chiều",
      "hs-cong-vien" in art_assets and "Ván gỗ ×1" in art_assets
      and "Chiều" in art_assets)
check("T13f", "art-assets.md §4: hs-cho-dem nhặt Vải vụn ×2, khung Tối",
      "hs-cho-dem" in art_assets and "Vải vụn ×2" in art_assets
      and "Tối" in art_assets)
# NPC dẫn đường trong spec phải khớp GuideHint trong Exploration.cs.
check("T13g", "art-assets.md: NPC dẫn đường khu 17 là Ông Ba, khu 18 là Anh Hải",
      "Ông Ba" in art_assets and "Anh Hải" in art_assets)
check("T13h", "art-assets.md: Anh Hải khu 18 là cùng người với khu 2",
      "Cùng người với anh Hải ở Chợ Đầu Mối" in art_assets)
# Ghi chú khu chung (districts.md) phải có trong cả 2 mục spec.
check("T13i", "art-assets.md §3/§4: khu chung luôn mở, không phân tầng",
      art_assets.count("luôn mở cho mọi người chơi, không phân tầng") >= 2)
# 2 scene mới trỏ tới đúng mục spec (không còn ghi "chưa có mục riêng").
for name, section in [("SliceCongVienAnBinh.unity", "§3"),
                      ("SlicePhoDiBoChoDem.unity", "§4")]:
    content = read(SCENES / name)
    check(f"T13j-{name}", f"{name}: header trỏ spec art-assets.md {section}",
          f"docs/art-assets.md {section}" in content
          and "chua co muc rieng" not in content)

# ---- 14. Khung Nadia Giai đoạn 1 (18/11 ~22:45, đợt này) ----
# src/nadia/www/ theo docs/architecture-nadia.md §8/§11: index.html +
# plugins.js + main.js + PXB_Balance.js + PXB_Isometric.js (bản đầu) +
# data/ tối thiểu (System, MapInfos đủ 18 khu, Map001–002, Actors, Classes,
# Items). Core MV CHƯA CÓ — checker không đòi file core, chỉ khóa khung đã
# viết + số port đúng từ C# (GameBalance/Jobs/Crafting/Exploration/Stats).
# Tọa độ event lấy từ src/web/data/Maps.js; số nghề/công thức/hotspot lấy
# từ C# — web đã lệch khỏi C# ở 3 chỗ (xem src/nadia/README.md), không
# port từ web.
import json
import subprocess

NADIA = ROOT / "src" / "nadia" / "www"
NADIA_DATA = NADIA / "data"
NADIA_PLUGINS = NADIA / "js" / "plugins"

# T14a: index.html — thứ tự load đúng architecture-nadia.md §1.2.
index_html = read(NADIA / "index.html")
load_order = ["js/libs/pixi.js", "js/rpg_core.js", "js/rpg_managers.js",
              "js/rpg_objects.js", "js/rpg_scenes.js", "js/rpg_sprites.js",
              "js/rpg_windows.js", "js/plugins.js", "js/main.js"]
positions = [index_html.find(src) for src in load_order]
check("T14a", "index.html: thứ tự load đúng §1.2 (pixi → core → plugins → main)",
      all(p >= 0 for p in positions) and positions == sorted(positions),
      f"không thấy/thứ tự sai: {[(s, p) for s, p in zip(load_order, positions) if p < 0]}" if not (all(p >= 0 for p in positions) and positions == sorted(positions)) else "")

# T14b–d: MapInfos.json — đủ 18 khu, đúng thứ tự/tên/tầng, Bến Du Thuyền
# nằm trong khu 16 (không phải khu riêng).
mapinfos = json.loads(read(NADIA_DATA / "MapInfos.json"))
expected_districts = ["Xóm Trọ Cũ", "Chợ Đầu Mối", "Khu Công Nhân", "Bến Xe Miền Đông",
    "Làng Đại Học", "Chung Cư Cũ", "Phố Văn Phòng Nhỏ", "Khu Chung Cư Cao Cấp",
    "Phố Thương Mại", "Khu Công Nghệ", "Phố Tây", "Khu Biệt Thự Ven Sông",
    "Quận Tài Chính", "Đảo Thượng Lưu", "Khu Penthouse", "Khu Sân Golf & Resort",
    "Công Viên An Bình", "Phố Đi Bộ – Chợ Đêm"]
infos = [e for e in mapinfos if e]  # bỏ null đầu (chuẩn MV)
check("T14b", "MapInfos.json: đủ 18 khu, id 1–18 đúng thứ tự",
      len(infos) == 18 and [e["id"] for e in infos] == list(range(1, 19)),
      f"đếm được {len(infos)}" if len(infos) != 18 else "")
check("T14c", "MapInfos.json: tên 18 khu khớp districts.md / architecture §4.1",
      [e["name"] for e in infos] == expected_districts,
      f"sai ở: {[(i + 1, e['name']) for i, e in enumerate(infos) if e['name'] != expected_districts[i]]}" if [e["name"] for e in infos] != expected_districts else "")
check("T14d", "MapInfos.json: Bến Du Thuyền nằm trong khu 16, không phải khu riêng",
      "Bến Du Thuyền" in infos[15].get("unlock", "") and infos[15]["name"] == "Khu Sân Golf & Resort")

# T14e–f: Map001/Map002 — JSON hợp lệ, lưới 12×9, data = 12*9*6 = 648.
maps = {}
maps_ok = True
for mid in [1, 2]:
    try:
        maps[mid] = json.loads(read(NADIA_DATA / f"Map{mid:03d}.json"))
    except Exception as exc:  # noqa: BLE001 — JSON lỗi thì FAIL, không crash script
        maps_ok = False
        maps[mid] = {}
        check(f"T14e-Map{mid:03d}", f"Map{mid:03d}: JSON hợp lệ", False, str(exc))
check("T14e", "Map001/Map002: JSON hợp lệ", maps_ok)
for mid in [1, 2]:
    m = maps[mid]
    check(f"T14f-Map{mid:03d}", f"Map{mid:03d}: lưới 12×9, data = 648 (12*9*6)",
          maps_ok and m.get("width") == 12 and m.get("height") == 9
          and len(m.get("data", [])) == 648,
          f"{m.get('width')}x{m.get('height')}, data {len(m.get('data', []))}" if maps_ok else "JSON lỗi")


def hotspot_notes(m):
    # note event hotspot có dạng: "hotspot <id> <item> <qty> <khung>".
    notes = {}
    for ev in m.get("events", []) or []:
        if not ev:
            continue
        parts = ev.get("note", "").split()
        if len(parts) == 5 and parts[0] == "hotspot":
            notes[parts[1]] = (parts[2], int(parts[3]), parts[4])
    return notes


# T14g: hotspot trong Map001/002 khớp đúng Exploration.cs (id + vật + số + khung).
expected_hotspots = {
    1: {"hs-tro-toi": ("chai-nhua", 2, "Tối")},
    2: {"hs-cho-sang": ("la-chuoi", 2, "Sáng"), "hs-cho-chieu": ("sat-vun", 1, "Chiều")},
}
for mid, expected in expected_hotspots.items():
    found = hotspot_notes(maps[mid])
    check(f"T14g-Map{mid:03d}", f"Map{mid:03d}: hotspot khớp Exploration.cs {sorted(expected)}",
          maps_ok and found == expected,
          f"tìm thấy: {found}" if found != expected else "")
# T14h–i: 2 lệch của web slice KHÔNG được mang sang nadia (xem src/nadia/README.md).
check("T14h", "Map002 KHÔNG có hs-cho-dem (theo Exploration.cs nó thuộc khu 18)",
      maps_ok and "hs-cho-dem" not in hotspot_notes(maps[2]))
check("T14i", "Map001 KHÔNG có hs-hem-sang (không có trong Exploration.cs)",
      maps_ok and "hs-hem-sang" not in hotspot_notes(maps[1]))


def npc_positions(m):
    # note event NPC có dạng: "npc <id>".
    pos = {}
    for ev in m.get("events", []) or []:
        if not ev:
            continue
        parts = ev.get("note", "").split()
        if len(parts) == 2 and parts[0] == "npc":
            pos[parts[1]] = (ev.get("x"), ev.get("y"))
    return pos


# T14j: NPC đúng tọa độ Actors.js (cô Tư 8,6; bạn thân 3,5; chị Lệ 2,2; anh Hải 6,3).
check("T14j", "NPC Map001/002 đúng tọa độ Actors.js",
      maps_ok and npc_positions(maps[1]) == {"co-tu": (8, 6), "ban-than": (3, 5)}
      and npc_positions(maps[2]) == {"chi-le": (2, 2), "anh-hai": (6, 3)},
      f"Map001: {npc_positions(maps[1])}, Map002: {npc_positions(maps[2])}" if maps_ok else "JSON lỗi")


def event_notes(m, prefix):
    out = []
    for ev in m.get("events", []) or []:
        if not ev:
            continue
        note = ev.get("note", "")
        if note == prefix or note.startswith(prefix + " "):
            out.append((note, ev.get("x"), ev.get("y")))
    return out


# T14k–l: cửa chuyển khu 2 chiều + Góc Chế Tạo đúng tọa độ Maps.js.
check("T14k", "Transfer 2 chiều: Map001 (5,4 → Map002 5,4), Map002 (5,4 → Map001 5,4)",
      maps_ok and ("transfer 2 5 4", 5, 4) in event_notes(maps[1], "transfer")
      and ("transfer 1 5 4", 5, 4) in event_notes(maps[2], "transfer"))
check("T14l", "Góc Chế Tạo: Map001 (2,2), Map002 (7,5)",
      maps_ok and ("craft", 2, 2) in event_notes(maps[1], "craft")
      and ("craft", 7, 5) in event_notes(maps[2], "craft"))

# T14m–q: PXB_Balance.js — số khớp GameBalance.cs / Jobs.cs / Crafting.cs / Stats.cs.
balance = read(NADIA_PLUGINS / "PXB_Balance.js")
check("T14m", "PXB_Balance.js: 5 bậc học đúng học phí/ngày/Trí/EXP (GameBalance.cs)",
      all(t in balance for t in ["feeVnd: 0,         days: 30", "feeVnd: 20000000,  days: 60",
                                  "feeVnd: 80000000,  days: 120", "feeVnd: 200000000, days: 180",
                                  "feeVnd: 500000000, days: 240"]))
economy_tokens = [
    "bankInterestPerGameMonth: 0.005", "auctionFeePercent: 5",
    "neglectDaysToDropCloseness: 7", "supportedExpBonusPercent: 20",
    "soloSlowerPercentMin: 30", "soloSlowerPercentMax: 50",
    "roomRentPerMonthVnd: 2000000", "miniApartmentVnd: 800000000",
    "smallTownhouseVnd: 3000000000", "largeTownhouseVnd: 8000000000",
    "villaVnd: 25000000000", "penthouseIslandVnd: 100000000000",
    "directorAssetsVnd: 10000000000", "superRichAssetsVnd: 100000000000",
    "familyEndingAnYen: 80", "foodStallLicenseVnd: 50000000",
    "clinicLicenseVnd: 200000000", "examFeeMinVnd: 5000000",
    "examFeeMaxVnd: 20000000", "companyCapitalVnd: 500000000",
    "shortageSalaryBonusPercent: 30", "saturatedSalaryCutPercent: 15",
    "schoolSeatsPerCourseMin: 20", "schoolSeatsPerCourseMax: 30",
]
missing_economy = [t for t in economy_tokens if t not in balance]
check("T14n", "PXB_Balance.js: lãi/phí/xã hội/thang nhà/rank/giấy phép khớp GameBalance.cs",
      not missing_economy, f"thiếu: {missing_economy}" if missing_economy else "")
check("T14o", "PXB_Balance.js: 3 nghề khớp Jobs.cs (bán rong Thể/Chiều/150k, shipper Thể/Tối/180k, quán Tâm/Sáng/150k, quota 14)",
      all(t in balance for t in [
          '"ban-rong",       name: "Bán rong",       mainStat: "the", goodFrame: "Chiều", basePayVnd: 150000, weeklyQuota: 14',
          '"shipper",        name: "Shipper",        mainStat: "the", goodFrame: "Tối",   basePayVnd: 180000, weeklyQuota: 14',
          '"nhan-vien-quan", name: "Nhân viên quán", mainStat: "tam", goodFrame: "Sáng",  basePayVnd: 150000, weeklyQuota: 14'])
      and "goodFrameBonusPercent: 25" in balance)
check("T14p", "PXB_Balance.js: 3 công thức khớp Crafting.cs (xe-đẩy 1/2/2, đèn-soi 2/2, quà-tặng 2/1)",
      all(t in balance for t in [
          '"khung-sat": 1, "banh-xe": 2, "van-go": 2',
          '"sat-vun": 2, "chai-nhua": 2',
          '"la-chuoi": 2, "vai-vun": 1']))
check("T14q", "PXB_Balance.js: số chưa chốt ghi PROVISIONAL (trần 300, StatMax 100, An Yên ±10)",
      "totalStatCap: 300, // PROVISIONAL" in balance
      and "statMax: 100, // PROVISIONAL" in balance
      and "anYenBalanceTolerance: 10, // PROVISIONAL" in balance)

# T14r–s: PXB_Isometric.js — phép chiếu + sắp xếp + viewport, không require/NW.
iso = read(NADIA_PLUGINS / "PXB_Isometric.js")
check("T14r", "PXB_Isometric.js: chiếu (x−y)×tileW/2, (x+y)×tileH/2; sort x+y; tile 64×32; viewport 720×1280",
      "(col - row) * (TILE_W / 2)" in iso and "(col + row) * (TILE_H / 2)" in iso
      and "return col + row;" in iso and "TILE_W = 64" in iso and "TILE_H = 32" in iso
      and "VIEWPORT_W = 720" in iso and "VIEWPORT_H = 1280" in iso)
check("T14s", "PXB_Isometric.js: 'use strict', không require, không API NW.js",
      '"use strict"' in iso and "require(" not in iso and "process." not in iso and "nw." not in iso)

# T14t–u: plugins.js (Balance → Stats → Time → Isometric → Hotspot → Jobs, cả 6 bật) + main.js.
plugins_js = read(NADIA / "js" / "plugins.js")
check("T14t", "plugins.js: thứ tự Balance < Stats < Time < Isometric < Hotspot < Crafting < Jobs < PhoneHub, 8 plugin gốc đều bật",
      plugins_js.find('"PXB_Balance"') < plugins_js.find('"PXB_Stats"')
      < plugins_js.find('"PXB_Time"') < plugins_js.find('"PXB_Isometric"')
      < plugins_js.find('"PXB_Hotspot"') < plugins_js.find('"PXB_Crafting"')
      < plugins_js.find('"PXB_Jobs"') < plugins_js.find('"PXB_PhoneHub"')
      and plugins_js.count('"status": true') >= 8)  # nay 11 plugin (T19b đếm đủ); T14t chỉ khóa 8 gốc + thứ tự
main_js = read(NADIA / "js" / "main.js")
check("T14u", "main.js: PluginManager.setup($plugins) + SceneManager.run(Scene_Boot)",
      "PluginManager.setup($plugins)" in main_js and "SceneManager.run(Scene_Boot)" in main_js)

# T14v: node --check 19 file JS nadia (node v24 có sẵn trên VM).
node_files = [NADIA_PLUGINS / "PXB_Balance.js", NADIA_PLUGINS / "PXB_Isometric.js",
              NADIA_PLUGINS / "PXB_Stats.js", NADIA_PLUGINS / "PXB_Time.js",
              NADIA_PLUGINS / "PXB_Hotspot.js", NADIA_PLUGINS / "PXB_Jobs.js",
              NADIA_PLUGINS / "PXB_Crafting.js", NADIA_PLUGINS / "PXB_Tools.js",
              NADIA_PLUGINS / "PXB_PhoneHub.js",
              NADIA_PLUGINS / "PXB_Education.js", NADIA_PLUGINS / "PXB_Economy.js",
              NADIA_PLUGINS / "PXB_Social.js", NADIA_PLUGINS / "PXB_Titles.js",
              NADIA_PLUGINS / "PXB_Story.js",
              NADIA_PLUGINS / "PXB_Online.js", NADIA_PLUGINS / "PXB_SaveCloud.js",
              NADIA_PLUGINS / "PXB_MarketBattle.js",
              NADIA / "js" / "plugins.js", NADIA / "js" / "main.js"]
node_ok, node_detail = True, ""
try:
    for jf in node_files:
        r = subprocess.run(["node", "--check", str(jf)], capture_output=True, text=True, timeout=30)
        if r.returncode != 0:
            node_ok = False
            node_detail += f"{jf.name}: {r.stderr.strip()}; "
except FileNotFoundError:
    node_ok = False
    node_detail = "không tìm thấy lệnh node"
check("T14v", "node --check: 19 file JS nadia qua cú pháp", node_ok, node_detail)

# T14w–y: Actors/Classes/Items — chéo tham chiếu + giá khớp Items.js.
actors = json.loads(read(NADIA_DATA / "Actors.json"))
classes = json.loads(read(NADIA_DATA / "Classes.json"))
items = json.loads(read(NADIA_DATA / "Items.json"))
check("T14w", "Actors.json: 1 nhân vật chính, classId có trong Classes.json",
      len([a for a in actors if a]) == 1 and actors[1]["classId"] == 1 and classes[1]["id"] == 1)
item_notes = {}
for it in items:
    if it:
        item_notes[it["note"].split()[1]] = it
check("T14x", "Items.json: đủ 13 item; đủ hotspot item + nguyên liệu chế tạo + quà tặng",
      len([it for it in items if it]) == 13
      and all(k in item_notes for k in ["chai-nhua", "vai-vun", "la-chuoi", "sat-vun",
                                         "khung-sat", "banh-xe", "van-go", "qua-tang"]))
check("T14y", "Items.json: giá khớp Items.js (khung-sat 30000, banh-xe 50000, xe-day 500000, den-soi 120000)",
      item_notes["khung-sat"]["price"] == 30000 and item_notes["banh-xe"]["price"] == 50000
      and item_notes["xe-day"]["price"] == 500000 and item_notes["den-soi"]["price"] == 120000)

# T14z–aa: System.json + package.json NW.js.
system = json.loads(read(NADIA_DATA / "System.json"))
check("T14z", "System.json: gameTitle Phố Xô Bồ, tiền 'đồng', map bắt đầu 1",
      system.get("gameTitle") == "Phố Xô Bồ" and system.get("currencyUnit") == "đồng"
      and system.get("startMapId") == 1)
package = json.loads(read(ROOT / "src" / "nadia" / "package.json"))
check("T14aa", "package.json (NW.js): main = www/index.html",
      package.get("main") == "www/index.html")

# T14ab–ac: không secret + UTF-8 cho file nadia DO MÌNH VIẾT.
# Ngoại lệ: js/rpg_*.js + js/libs/* là code upstream MIT (core MV v1.6.1 /
# pixi v4.5.4) lấy nguyên văn, KHÔNG quét secret ở đây — pixi.js có chuỗi
# "password=<redacted>" trong comment ví dụ của loader (không phải secret thật),
# quét chung sẽ FAIL giả. Nguồn upstream được khóa riêng ở T15a–c
# (header version + node --check + dung lượng).
# Ngoại lệ 19/11 ~06:55: file NHỊ PHÂN (atlas PNG trong img/tilesets/,
# sau này thêm audio) KHÔNG phải text — quét read_text sẽ crash
# UnicodeDecodeError (đã crash thật khi atlas PNG vào repo). Loại khỏi
# danh sách quét; PNG được khóa riêng ở T24 (magic bytes + kích thước + SHA).
_BINARY_SUFFIXES = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".ogg",
                    ".mp3", ".m4a", ".wav", ".zip"}
nadia_files = [p for p in sorted(NADIA.rglob("*")) if p.is_file()
               and p.name not in {"rpg_core.js", "rpg_managers.js", "rpg_objects.js",
                                  "rpg_scenes.js", "rpg_sprites.js", "rpg_windows.js"}
               and "libs" not in p.parts
               and p.suffix.lower() not in _BINARY_SUFFIXES]
bad_nadia_secret = [p.name for p in nadia_files if secret_pat.search(read(p))]
check("T14ab", "Không có secret/token/key trong file nadia (do mình viết)", not bad_nadia_secret,
      f"nghi ngờ ở: {bad_nadia_secret}" if bad_nadia_secret else "")
# T14ac: UTF-8 cho file nadia do mình viết (core/libs upstream kiểm ở T15c).
bad_nadia_utf8 = []
for p in nadia_files:
    try:
        p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        bad_nadia_utf8.append(str(p.relative_to(ROOT)))
check("T14ac", "Mọi file nadia (do mình viết) đều UTF-8", not bad_nadia_utf8,
      str(bad_nadia_utf8) if bad_nadia_utf8 else "")

# ---- Nhóm T15 — core MV v1.6.1 + plugin PXB_Stats / PXB_Time (19/11/2026 ~00:05) ----
# Core lấy từ rpgtkoolmv/corescript tag community 1.3b — header mỗi file
# rpg_*.js ghi "v1.6.1 (community-1.3b)"; repo không có tag v1.6.1.
# Libs lấy từ bundle MV 1.6.1 (pixi v4.5.4, MIT). Chỉ lấy code core + libs,
# không lấy asset/nhạc/nhân vật/map/cốt truyện của Nadia hay RPG Maker.
CORE_JS = ["rpg_core.js", "rpg_managers.js", "rpg_objects.js",
           "rpg_scenes.js", "rpg_sprites.js", "rpg_windows.js"]
CORE_LIBS = ["pixi.js", "pixi-tilemap.js", "pixi-picture.js",
             "fpsmeter.js", "lz-string.js", "iphone-inline-video.browser.js"]
core_paths = [NADIA / "js" / f for f in CORE_JS] + [NADIA / "js" / "libs" / f for f in CORE_LIBS]
core_sizes = {p.name: p.stat().st_size for p in core_paths if p.is_file()}
check("T15a", "Core MV: đủ 12 file (6 js/rpg_*.js + 6 js/libs/*), không file rỗng",
      len(core_sizes) == 12 and all(s > 0 for s in core_sizes.values()),
      f"thiếu/rỗng: {[f for f in CORE_JS + CORE_LIBS if f not in core_sizes or core_sizes.get(f, 0) == 0]}" if len(core_sizes) != 12 or not all(s > 0 for s in core_sizes.values()) else "")
core_headers_ok = all(
    "v1.6.1 (community-1.3b)" in read(NADIA / "js" / f).split("\n")[1]
    for f in CORE_JS)
check("T15b", "Core MV: 6 file rpg_*.js header 'v1.6.1 (community-1.3b)'; pixi.js v4.5.4",
      core_headers_ok and "pixi.js - v4.5.4" in read(NADIA / "js" / "libs" / "pixi.js"),
      "header sai" if not core_headers_ok else "")
core_node_ok, core_node_detail = True, ""
core_utf8_bad = []
for p in core_paths:
    try:
        p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        core_utf8_bad.append(p.name)
    r = subprocess.run(["node", "--check", str(p)], capture_output=True, text=True, timeout=30)
    if r.returncode != 0:
        core_node_ok = False
        core_node_detail += f"{p.name}: {r.stderr.strip()}; "
check("T15c", "Core MV: node --check 12/12 file qua cú pháp + đều UTF-8",
      core_node_ok and not core_utf8_bad,
      (core_node_detail + f" không UTF-8: {core_utf8_bad}") if (not core_node_ok or core_utf8_bad) else "")

# T15d: PXB_Stats.js — port Stats.cs (3 gốc + 4 trộn + trần + Train + save).
stats_js = read(NADIA_PLUGINS / "PXB_Stats.js")
stats_tokens = ["totalStatCap: 300", "statMax: 100", "anYenBalanceTolerance: 10",
                "Stats.prototype.ky", "Stats.prototype.dung", "Stats.prototype.sang",
                "Stats.prototype.anYen", "Stats.prototype.train",
                "$gameSystem.pxbStats", "DataManager.createGameObjects",
                "DataManager.extractSaveContents"]
missing_stats = [t for t in stats_tokens if t not in stats_js]
check("T15d", "PXB_Stats.js: 3 gốc + 4 trộn + trần 300 PROVISIONAL + Train + lưu $gameSystem.pxbStats",
      not missing_stats and '"use strict"' in stats_js and "require(" not in stats_js,
      f"thiếu: {missing_stats}" if missing_stats else "")
# T15e: PXB_Time.js — port TimeSystem.cs (30 phút/3 khung/10 phút, miss không phạt, thứ 7 20:00).
time_js = read(NADIA_PLUGINS / "PXB_Time.js")
time_tokens = ["gameDayMinutes: 30", "framesPerDay: 3", "frameMinutes: 10",
               '"Sáng", "Chiều", "Tối"', "function isMissed",
               "EVENT_HOUR = 20", "isSaturdayEventTime", "shouldTriggerSaturdayEvent",
               "PROVISIONAL"]
missing_time = [t for t in time_tokens if t not in time_js]
check("T15e", "PXB_Time.js: 30 phút/3 khung/10 phút + isMissed + sự kiện thứ 7 20:00 (giờ game, PROVISIONAL)",
      not missing_time and '"use strict"' in time_js and "require(" not in time_js,
      f"thiếu: {missing_time}" if missing_time else "")
# T15f: plugins.js đã khai báo đủ 8 plugin (kiểm thứ tự + số lượng ở T14t).
check("T15f", "plugins.js: khai báo đủ 8 plugin PXB_Balance/Stats/Time/Isometric/Hotspot/Crafting/Jobs/PhoneHub",
      all(f'"{n}"' in plugins_js for n in
          ["PXB_Balance", "PXB_Stats", "PXB_Time", "PXB_Isometric", "PXB_Hotspot",
           "PXB_Crafting", "PXB_Jobs", "PXB_PhoneHub"]))
# T15g–h: index.html + README nadia đã cập nhật trạng thái core (không còn ghi "CHƯA CÓ" cho core).
check("T15g", "index.html: không còn ghi 'CHƯA CÓ FILE CORE' (core đã về)",
      "CHƯA CÓ FILE CORE" not in index_html and "MV v1.6.1" in index_html)
nadia_readme = read(ROOT / "src" / "nadia" / "README.md")
check("T15h", "src/nadia/README.md: ghi core MV v1.6.1 ĐÃ CÓ + nguồn tag community 1.3b",
      "core MV v1.6.1" in nadia_readme and "ĐÃ CÓ" in nadia_readme
      and "community 1.3b" in nadia_readme)

# ---- Nhóm T16 — PXB_Isometric v2 (móc Tilemap) + PXB_Hotspot + PXB_Jobs (19/11/2026 ~00:50) ----
# T16a: PXB_Isometric.js v2 — IsoTilemap kế thừa Tilemap, alias screenX/screenY
# + createTilemap, vẽ tile thường thành thoi (quay 45° + co), bỏ autotile.
iso_v2 = read(NADIA_PLUGINS / "PXB_Isometric.js")
iso_tokens = ["IsoTilemap", "Object.create(Tilemap.prototype)",
              "Game_CharacterBase.prototype.screenX",
              "Game_CharacterBase.prototype.screenY",
              "Spriteset_Map.prototype.createTilemap",
              "DIAMOND_ROTATION = Math.PI / 4", "DIAMOND_SCALE_X",
              "normalTileSource", "originFor", "panFromOrigin",
              "diamondCenter", "skippedAutotile",
              "this.scrolledX()", "this.scrolledY()"]
missing_iso = [t for t in iso_tokens if t not in iso_v2]
check("T16a", "PXB_Isometric v2: IsoTilemap kế thừa Tilemap + alias screenX/screenY/createTilemap + vẽ thoi + bỏ autotile",
      not missing_iso and '"use strict"' in iso_v2 and "require(" not in iso_v2,
      f"thiếu: {missing_iso}" if missing_iso else "")
# T16b: PXB_Hotspot.js — port Exploration.cs (5 hotspot, 1 lần/ngày, đúng khung, GuideHint).
hotspot_js = read(NADIA_PLUGINS / "PXB_Hotspot.js")
hotspot_tokens = ["pxbHotspot", "wrong-frame", "already", "GuideHint",
                  "hotspotsInDistrict", "$gameSystem.pxbHotspot", "PROVISIONAL"]
missing_hotspot = [t for t in hotspot_tokens if t not in hotspot_js]
check("T16b", "PXB_Hotspot.js: 5 hotspot + nhặt 1 lần/ngày + chặn sai khung + GuideHint + lưu $gameSystem",
      not missing_hotspot and '"use strict"' in hotspot_js and "require(" not in hotspot_js,
      f"thiếu: {missing_hotspot}" if missing_hotspot else "")
# T16c: PXB_Jobs.js — port Jobs.cs (3 nghề, lương theo chỉ số, quota 14, cung–cầu, thi).
jobs_js = read(NADIA_PLUGINS / "PXB_Jobs.js")
jobs_tokens = ["pxbJobs", "het-quota", "takeExam", "grantExtraAttempt",
               "setDemand", "$gameSystem.pxbJobs", "PROVISIONAL"]
missing_jobs = [t for t in jobs_tokens if t not in jobs_js]
check("T16c", "PXB_Jobs.js: 3 nghề + lương chỉ số + quota tuần + cung–cầu + thi chứng chỉ + lưu $gameSystem",
      not missing_jobs and '"use strict"' in jobs_js and "require(" not in jobs_js,
      f"thiếu: {missing_jobs}" if missing_jobs else "")
# T16d: plugins.js đủ 8 plugin, thứ tự đúng (kiểm lại độc lập với T14t).
check("T16d", "plugins.js: 8 plugin gốc đủ, Balance đầu, Crafting sau Hotspot, PhoneHub sau Jobs, đều bật",
      plugins_js.count('"status": true') >= 8
      and plugins_js.find('"PXB_Isometric"') < plugins_js.find('"PXB_Hotspot"')
      < plugins_js.find('"PXB_Crafting"') < plugins_js.find('"PXB_Jobs"')
      < plugins_js.find('"PXB_PhoneHub"'))  # nay 11 plugin; T16d chỉ khóa thứ tự 8 gốc
# T16e: 3 file plugin mới/sửa đều UTF-8 (nội dung đã qua node --check ở T14v).
t16_utf8_bad = []
for _p in [NADIA_PLUGINS / "PXB_Isometric.js", NADIA_PLUGINS / "PXB_Hotspot.js",
           NADIA_PLUGINS / "PXB_Jobs.js"]:
    try:
        _p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        t16_utf8_bad.append(_p.name)
check("T16e", "PXB_Isometric/Hotspot/Jobs đều UTF-8", not t16_utf8_bad,
      f"không UTF-8: {t16_utf8_bad}" if t16_utf8_bad else "")

# ---- Nhóm T17 — PXB_Crafting + PXB_PhoneHub (19/11/2026 ~01:50) ----
# T17a: PXB_Crafting.js — port Crafting.cs (3 công thức đúng số C#, ToolBehaviour
# 4 tool × 3 bậc, Craft xóa key 0, học qua NPC, túi chung pxbMaterials).
crafting_js = read(NADIA_PLUGINS / "PXB_Crafting.js")
crafting_tokens = ["pxbCrafting", "learnRecipe", "craftCurrent", "toolBehaviour",
                   "missingIngredients", "$gameSystem.pxbCrafting",
                   "chua-hoc-cong-thuc", "pxbMaterials", "PROVISIONAL"]
missing_crafting = [t for t in crafting_tokens if t not in crafting_js]
check("T17a", "PXB_Crafting.js: 3 công thức + ToolBehaviour + Craft xóa key 0 + học qua NPC + túi chung Hotspot",
      not missing_crafting and '"use strict"' in crafting_js and "require(" not in crafting_js,
      f"thiếu: {missing_crafting}" if missing_crafting else "")
# T17b: PXB_PhoneHub.js — port PhoneHub.cs (9 tab, Open/Close/Toggle/SelectTab,
# Notify/Unread, callback TabChanged/OpenChanged, phím P, guard _installed).
phonehub_js = read(NADIA_PLUGINS / "PXB_PhoneHub.js")
phonehub_tokens = ["pxbPhoneHub", "onTabChanged", "onOpenChanged", "totalUnread",
                   "$gameSystem.pxbPhoneHub", "keyMapper", '"phone"', "_installed"]
missing_phonehub = [t for t in phonehub_tokens if t not in phonehub_js]
check("T17b", "PXB_PhoneHub.js: 9 tab + Open/Close/Toggle + Notify/Unread + callback + phím P + guard install",
      not missing_phonehub and '"use strict"' in phonehub_js and "require(" not in phonehub_js,
      f"thiếu: {missing_phonehub}" if missing_phonehub else "")
# T17c: plugins.js đủ 8 plugin, thứ tự đúng (kiểm lại độc lập với T14t/T16d).
check("T17c", "plugins.js: 8 plugin gốc đủ, Crafting sau Hotspot, PhoneHub sau Jobs, đều bật",
      plugins_js.count('"status": true') >= 8
      and plugins_js.find('"PXB_Hotspot"') < plugins_js.find('"PXB_Crafting"')
      < plugins_js.find('"PXB_Jobs"') < plugins_js.find('"PXB_PhoneHub"'))  # nay 11 plugin; T17c chỉ khóa thứ tự 8 gốc
# T17d: 2 file plugin mới đều UTF-8 (nội dung đã qua node --check ở T14v).
t17_utf8_bad = []
for _p in [NADIA_PLUGINS / "PXB_Crafting.js", NADIA_PLUGINS / "PXB_PhoneHub.js"]:
    try:
        _p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        t17_utf8_bad.append(_p.name)
check("T17d", "PXB_Crafting/PhoneHub đều UTF-8", not t17_utf8_bad,
      f"không UTF-8: {t17_utf8_bad}" if t17_utf8_bad else "")

# ---- Nhóm T18 — PXB_Education + PXB_Economy (19/11/2026 ~02:55) ----
# T18a: PXB_Education.js — port GDD Mục 5 / GameBalance.Degrees (5 bậc,
# khóa ngắn hạn, học bổng PROVISIONAL, tốt nghiệp ghi pendingExp/Fame).
education_js = read(NADIA_PLUGINS / "PXB_Education.js")
education_tokens = ["pxbEducation", "degreeList", "canEnroll", "checkGraduation",
                    "enrollShortCourse", "scholarshipEligible", "seatsPerCourse",
                    "$gameSystem.pxbEducation", "pendingExp", "can-mentor", "PROVISIONAL"]
missing_education = [t for t in education_tokens if t not in education_js]
check("T18a", "PXB_Education.js: 5 bậc + enroll/chặn Trí-mentor-tiền + tốt nghiệp + khóa ngắn hạn + học bổng",
      not missing_education and '"use strict"' in education_js and "require(" not in education_js,
      f"thiếu: {missing_education}" if missing_education else "")
# T18b: PXB_Economy.js — port Economy.cs (catalog 17 món, ví + lãi 0,5%,
# đấu giá 5%, barter, chia tài sản, set bonus, dress-code, 4 hàm cấm).
economy_js = read(NADIA_PLUGINS / "PXB_Economy.js")
economy_tokens = ["pxbEconomy", "applyMonthlyInterest", "depositSavings",
                  "withdrawSavings", "auctionSellerReceives", "barter",
                  "splitAssets", "setBonus", "passesDirectorDressCode",
                  "cashOut", "lendWithInterest", "gamble", "buyWithRealMoney",
                  "$gameSystem.pxbEconomy", "PROVISIONAL"]
missing_economy = [t for t in economy_tokens if t not in economy_js]
check("T18b", "PXB_Economy.js: catalog 17 món + ví/lãi + đấu giá + barter + set bonus + 4 hàm cấm",
      not missing_economy and '"use strict"' in economy_js and "require(" not in economy_js,
      f"thiếu: {missing_economy}" if missing_economy else "")
# T18c: plugins.js đủ 11 plugin, thứ tự đúng (kiểm lại độc lập với T14t/T16d/T17c).
# Nay 13 plugin (T20b đếm đủ); T18c chỉ khóa ≥ 11 gốc + thứ tự.
check("T18c", "plugins.js: đủ 11 plugin, PhoneHub trước Education, Economy trước Social, cả 11 bật",
      plugins_js.count('"status": true') >= 11
      and plugins_js.find('"PXB_PhoneHub"') < plugins_js.find('"PXB_Education"')
      < plugins_js.find('"PXB_Economy"') < plugins_js.find('"PXB_Social"'))
# T18d: 2 file plugin mới đều UTF-8 (nội dung đã qua node --check ở T14v).
t18_utf8_bad = []
for _p in [NADIA_PLUGINS / "PXB_Education.js", NADIA_PLUGINS / "PXB_Economy.js"]:
    try:
        _p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        t18_utf8_bad.append(_p.name)
check("T18d", "PXB_Education/Economy đều UTF-8", not t18_utf8_bad,
      f"không UTF-8: {t18_utf8_bad}" if t18_utf8_bad else "")

# ---- Nhóm T19 — PXB_Social (19/11/2026 ~03:55) ----
# T19a: PXB_Social.js — port Social.cs (7 loại quan hệ, 6 stage, bỏ bê
# 7 ngày, hỗ trợ +20% EXP, solo 40%, ly hôn, hội bạn tan, seedSlice).
social_js = read(NADIA_PLUGINS / "PXB_Social.js")
social_tokens = ["pxbSocial", "createRelationship", "isDeep", "applyNeglect",
                 "advanceStage", "breakUp", "addRel", "hasSupporter",
                 "applySupportBonus", "applySoloPenalty", "checkGroupDissolved",
                 "divorce", "recordMarriage", "isMarriedTo", "seedSlice",
                 "$gameSystem.pxbSocial", "PROVISIONAL"]
missing_social = [t for t in social_tokens if t not in social_js]
check("T19a", "PXB_Social.js: 7 kind + 6 stage + bỏ bê/hỗ trợ/solo/ly hôn/nhóm tan/seedSlice",
      not missing_social and '"use strict"' in social_js and "require(" not in social_js,
      f"thiếu: {missing_social}" if missing_social else "")
# T19b: plugins.js đủ 11 plugin, Social cuối, cả 11 bật (kiểm lại độc lập với T18c).
# Nay 13 plugin (T20b đếm đủ); T19b chỉ khóa ≥ 11 gốc + thứ tự.
check("T19b", "plugins.js: đủ 11 plugin, Economy trước Social, cả 11 bật",
      plugins_js.count('"status": true') >= 11
      and plugins_js.find('"PXB_Economy"') < plugins_js.find('"PXB_Social"'))
# T19c: file plugin mới UTF-8 (nội dung đã qua node --check ở T14v).
try:
    (NADIA_PLUGINS / "PXB_Social.js").read_bytes().decode("utf-8")
    t19_utf8_ok = True
except UnicodeDecodeError:
    t19_utf8_ok = False
check("T19c", "PXB_Social.js UTF-8", t19_utf8_ok)
# T19d: hồi quy bug ly hôn 18/11 — divorce() chặn bằng || (Spouse VÀ
# Cuoi mới được), không dùng && như bản lỗi; ngưỡng stage 50/70/80 có đủ.
_divorce_block = social_js[social_js.find("function divorce("):]
_divorce_block = _divorce_block[:_divorce_block.find("\n  }\n")]
check("T19d", "PXB_Social.divorce: điều kiện || (Spouse + Cuoi) + ngưỡng stage 50/70/80",
      "||" in _divorce_block
      and "rel.kind !== KINDS.SPOUSE" in _divorce_block
      and "rel.stage !== STAGES.CUOI" in _divorce_block
      and "STAGE_HEN_HO_MIN = 50" in social_js
      and "STAGE_DINH_HON_MIN = 70" in social_js
      and "STAGE_CUOI_MIN = 80" in social_js)

# ---- Nhóm T20 — PXB_Titles + PXB_Story (19/11/2026 ~04:50) ----
# T20a: PXB_Titles.js — port TitleConflict.cs (bảng chặn 7 dòng, chặn
# 2 chiều, không phân biệt hoa/thường, phe Chính/Tà, quest đổi phe).
titles_js = read(NADIA_PLUGINS / "PXB_Titles.js")
titles_tokens = ["pxbTitles", "BLOCKED_BY", "isBlocked", "addTitle",
                 "removeTitle", "hasTitle", "canTakeJob", "alignmentOf",
                 "canRedeem", "redeem", "$gameSystem.pxbTitles", "PROVISIONAL"]
missing_titles = [t for t in titles_tokens if t not in titles_js]
check("T20a", "PXB_Titles.js: bảng chặn 7 dòng + chặn 2 chiều + phe + đổi phe",
      not missing_titles and '"use strict"' in titles_js and "require(" not in titles_js,
      f"thiếu: {missing_titles}" if missing_titles else "")
# T20b: plugins.js đủ 13 plugin, Social trước Titles, Titles trước Story, cả 13 bật.
check("T20b", "plugins.js: đủ 13 plugin, Social trước Titles trước Story, cả 13 bật",
      plugins_js.count('"status": true') >= 13
      and plugins_js.find('"PXB_Social"') < plugins_js.find('"PXB_Titles"')
      < plugins_js.find('"PXB_Story"'))
# T20c: 2 file plugin mới đều UTF-8 (nội dung đã qua node --check ở T14v).
t20_utf8_bad = []
for _p in [NADIA_PLUGINS / "PXB_Titles.js", NADIA_PLUGINS / "PXB_Story.js"]:
    try:
        _p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        t20_utf8_bad.append(_p.name)
check("T20c", "PXB_Titles/Story đều UTF-8", not t20_utf8_bad,
      f"không UTF-8: {t20_utf8_bad}" if t20_utf8_bad else "")
# T20d: hồi quy quirk Kẻ Lừa Đảo — chỉ chặn "Luật Sư Chính Trực", KHÔNG
# chặn "Luật Sư Bào Chữa" (bảng BLOCKED_BY chỉ có 1 dòng cho Kẻ Lừa Đảo).
_kld_block = titles_js[titles_js.find('"Kẻ Lừa Đảo"'):]
_kld_block = _kld_block[:_kld_block.find("],")]
check("T20d", "PXB_Titles: Kẻ Lừa Đảo chỉ chặn Luật Sư Chính Trực, không chặn Luật Sư Bào Chữa",
      "Luật Sư Chính Trực" in _kld_block
      and "Luật Sư Bào Chữa" not in _kld_block
      and "Tướng Cướp" in titles_js and "Trùm Buôn Lậu" in titles_js
      and "Tham Quan" in titles_js and "Tỷ Phú Từ Thiện" in titles_js)
# T20e: PXB_Story.js — port PlayerProgress.cs (5 chương, 6 kết thúc,
# tụt bậc chương 3, advance/recordHelpQuest/passChapter3/setEnding).
story_js = read(NADIA_PLUGINS / "PXB_Story.js")
story_tokens = ["pxbStory", "canOpenChapter", "suggestEnding", "rankAtRisk",
                "advanceChapter", "recordHelpQuest", "passChapter3",
                "setEnding", "CHAPTERS", "LEN_PHO", "LAP_NGHIEP",
                "KHUNG_HOANG", "VUC_DAY", "THANH_DAT", "ENDINGS",
                "SieuGiau", "GiamDoc", "HocGia", "GiaDinh",
                "TuDo", "ChuaMo", "$gameSystem.pxbStory"]
missing_story = [t for t in story_tokens if t not in story_js]
check("T20e", "PXB_Story.js: 5 chương + 6 kết thúc + tụt bậc + advance/help/pass/setEnding",
      not missing_story and '"use strict"' in story_js and "require(" not in story_js,
      f"thiếu: {missing_story}" if missing_story else "")

# ---- Nhóm T21: tileset CC0 + atlas theo khu + tile data thật Map001/002 ----
# (19/11/2026 ~06:00 — tải 6 pack Kenney/SBS, đóng atlas, điền Map data.)
TOOLS_TILES = ROOT / "tools" / "tiles"
# T21a: mapping JSON atlas hợp lệ: scheme atlas-code, tile 64x32, code
# liên tục 1..N, mỗi tile đủ source + rect + layer.
def _load_atlas(name):
    try:
        return json.loads(read(NADIA_DATA / name))
    except Exception as e:  # noqa: BLE001 — ghi lỗi vào detail của check
        return {"_error": str(e)}
atlas1 = _load_atlas("atlas-map001.json")
atlas2 = _load_atlas("atlas-map002.json")
def _atlas_ok(a, n):
    if "_error" in a:
        return False
    tiles = a.get("tiles", {})
    if a.get("scheme") != "atlas-code" or a.get("tileW") != 64 \
            or a.get("tileH") != 32 or len(tiles) != n:
        return False
    if sorted(int(k) for k in tiles) != list(range(1, n + 1)):
        return False
    for code, t in tiles.items():
        if not t.get("source") or not t.get("name"):
            return False
        if not all(k in t for k in ("x", "y", "w", "h", "layer")):
            return False
        if t["w"] != 64 or t["h"] > 64 or t["x"] % 64 or t["y"] < 0:
            return False
    return True
check("T21a", "atlas-map001/002.json: scheme atlas-code, tile 64x32, code 1..N đủ rect/layer",
      _atlas_ok(atlas1, 5) and _atlas_ok(atlas2, 6),
      "atlas lỗi: " + str(atlas1.get("_error") or atlas2.get("_error") or ""))
# T21b: Map001/002 data thật: đủ 648, layer 0 108/108 ô, layer 1 28/108 ô,
# mã dùng đều có trong mapping, ô event không có tường layer 1, note ghi atlas-code.
def _map_data_ok(map_name, atlas):
    try:
        m = json.loads(read(NADIA_DATA / f"{map_name}.json"))
    except Exception as e:  # noqa: BLE001
        return False, str(e)
    data = m.get("data", [])
    w, h = m.get("width"), m.get("height")
    if len(data) != 648 or w != 12 or h != 9:
        return False, f"{map_name} data dài {len(data)}"
    codes = {int(k) for k in atlas.get("tiles", {})}
    layer0 = data[0:108]
    layer1 = data[108:216]
    if any(v == 0 for v in layer0) or sum(1 for v in layer1 if v) != 28:
        return False, f"{map_name} layer0/layer1 sai số lượng"
    if any(v not in codes for v in layer0 + layer1 if v):
        return False, f"{map_name} có mã không nằm trong mapping"
    events = {(e["x"], e["y"]) for e in m.get("events", []) if e}
    for y in range(9):
        for x in range(12):
            if (x, y) in events and layer1[y * 12 + x] != 0:
                return False, f"{map_name} tường đè lên event ({x},{y})"
    if "atlas-code" not in m.get("note", ""):
        return False, f"{map_name} note chưa ghi atlas-code"
    return True, ""
_ok1, _d1 = _map_data_ok("Map001", atlas1)
_ok2, _d2 = _map_data_ok("Map002", atlas2)
check("T21b", "Map001/002: layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok1 and _ok2, _d1 or _d2)
# T21c: selection JSON khớp mapping 1:1 (code + tên), tint trong (0, 1.5].
def _sel_ok(sel_name, atlas):
    try:
        sel = json.loads(read(TOOLS_TILES / sel_name))
    except Exception as e:  # noqa: BLE001
        return False, str(e)
    tiles = {t["code"]: t for t in sel.get("tiles", [])}
    amap = {int(k): v for k, v in atlas.get("tiles", {}).items()}
    if set(tiles) != set(amap):
        return False, f"{sel_name} code lệch mapping"
    for code, t in tiles.items():
        if t["name"] != amap[code]["name"]:
            return False, f"{sel_name} code {code} tên lệch mapping"
        tint = t.get("tint") or [1.0, 1.0, 1.0]
        if len(tint) != 3 or any(not (0 < v <= 1.5) for v in tint):
            return False, f"{sel_name} code {code} tint lạ"
        if "file" not in t and "sheet" not in t:
            return False, f"{sel_name} code {code} thiếu nguồn"
    return True, ""
_ok1, _d1 = _sel_ok("select-map001.json", atlas1)
_ok2, _d2 = _sel_ok("select-map002.json", atlas2)
check("T21c", "select-map001/002.json khớp mapping 1:1 (code+tên), tint trong (0,1.5]",
      _ok1 and _ok2, _d1 or _d2)
# T21d: 2 script tile là text UTF-8, có mặt nạ thoi + NEAREST + công thức
# MV, --src-dir bắt buộc (không hardcode đường tải về làm mặc định).
def _tile_script_ok(name, tokens):
    try:
        src = read(TOOLS_TILES / name)
    except Exception as e:  # noqa: BLE001
        return False, str(e)
    missing = [t for t in tokens if t not in src]
    return not missing, f"thiếu: {missing}" if missing else ""
_ok1, _d1 = _tile_script_ok("build_atlas.py",
                            ["diamond_mask", "Image.NEAREST",
                             "TARGET_W = 64", "atlas-code"])
_ok2, _d2 = _tile_script_ok("fill_map_data.py",
                            ["(z * h + y) * w + x", "event_cells",
                             "atlas-code"])
check("T21d", "build_atlas.py/fill_map_data.py: mặt nạ thoi + NEAREST + công thức MV + atlas-code",
      _ok1 and _ok2, _d1 or _d2)
# T21e: tileset-plan.md §7 ghi đủ 6 SHA-256 zip + 2 SHA-256 atlas + v3.
_plan = read(DOCS / "tileset-plan.md")
_shas = ["bea03c38f340af6df14949cc7ca23ac68f30d087d4867350424f08b697a7e01c",
         "18fa4fb22fa18bd4230e2422bc4123c986123c53966846b5a5bc219b331e7d3e",
         "0894214e3b604f3eef53b9fa633340ba4617e24053a6178fa81dab6bac3d6d5e",
         "dc7ffbe7d65c26cb2f46c6ce4beabf07206f410466a31572f572456728ed8f12",
         "b478cf692d936e2cfda2368f8d24505841508907adc343f1068a6b2ea457d3fd",
         "d4d72f52ec543604c0d5a4bf3e4f0807e1000495c873646a3831b97afa7db5db",
         "971faa8da7d2410ec288bedb5bf981440ad5c6e35bfd4e0348d4a98a98715940",
         "d1329a32bd39d5738708375afa0d9759f0b26ebcdc209bc26b45ce4a39080949"]
_missing_shas = [s for s in _shas if s not in _plan]
check("T21e", "tileset-plan.md §7: đủ 6 SHA-256 zip + 2 SHA-256 atlas + nhắc PXB_Isometric v3",
      not _missing_shas and "PXB_Isometric v3" in _plan,
      f"thiếu SHA: {len(_missing_shas)}" if _missing_shas else "")

# ---- Nhóm T22: PXB_Tools.js — 4 công cụ x 3 bậc (port Crafting.cs) ----
# (19/11/2026 ~06:30 — 2 luồng song song: Tools + Online/SaveCloud.)
# T22a: 12 câu ToolBehaviour đúng nguyên văn Crafting.cs + 4 tool + 3 bậc
# + lưu $gameSystem.pxbTools.
tools_js = read(NADIA_PLUGINS / "PXB_Tools.js")
_behaviours = ["Chở được ít hàng, không đi được đường mưa.",
               "Chở được nhiều hàng hơn.",
               "Chở nhiều + đi được đường mưa, không bị ướt hàng.",
               "Thấy hotspot thường.",
               "Thấy hotspot thường + hotspot ẩn gần.",
               "Thấy mọi hotspot, kể cả hotspot hiếm chỉ xuất hiện 1 khung/ngày.",
               "NPC gợi ý chung chung.",
               "NPC gợi ý rõ mục tiêu + khu cần tới.",
               "NPC gợi ý rõ mục tiêu + khu + nguyên liệu còn thiếu.",
               "Nhặt được nguyên liệu thường.",
               "Nhặt nhanh hơn, thỉnh thoảng được thêm 1 nguyên liệu.",
               "Nhặt nhanh + có cơ hội nhặt được nguyên liệu hiếm."]
_missing_beh = [b for b in _behaviours if b not in tools_js]
_tools_tokens = ["pxbTools", "toolTier", "toolBehaviour", "canUpgrade",
                 "acquire", "hasTool", "XeDay", "DenSoi", "SoTay", "Xeng",
                 "Tho", "Kha", "Tot", "$gameSystem.pxbTools"]
_missing_tools = [t for t in _tools_tokens if t not in tools_js]
check("T22a", "PXB_Tools.js: đủ 12 câu ToolBehaviour nguyên văn Crafting.cs + 4 tool x 3 bậc + pxbTools",
      not _missing_beh and not _missing_tools
      and '"use strict"' in tools_js and "require(" not in tools_js,
      f"thiếu hành vi: {_missing_beh} token: {_missing_tools}" if (_missing_beh or _missing_tools) else "")
# T22b: plugins.js đủ 16 plugin, Crafting trước Tools trước Jobs,
# Story trước Online trước SaveCloud, cả 16 bật.
check("T22b", "plugins.js: đủ 16 plugin, Crafting<Tools<Jobs, Story<Online<SaveCloud, cả 16 bật",
      plugins_js.count('"status": true') >= 16  # nay 17 plugin (T27c đếm đủ); T22b chỉ khóa ≥ 16 gốc + thứ tự
      and plugins_js.find('"PXB_Crafting"') < plugins_js.find('"PXB_Tools"')
      < plugins_js.find('"PXB_Jobs"')
      and plugins_js.find('"PXB_Story"') < plugins_js.find('"PXB_Online"')
      < plugins_js.find('"PXB_SaveCloud"'))
# T22c: 3 file plugin mới đều UTF-8 (nội dung đã qua node --check ở T14v).
t22_utf8_bad = []
for _p in [NADIA_PLUGINS / "PXB_Tools.js", NADIA_PLUGINS / "PXB_Online.js",
           NADIA_PLUGINS / "PXB_SaveCloud.js"]:
    try:
        _p.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        t22_utf8_bad.append(_p.name)
check("T22c", "PXB_Tools/Online/SaveCloud đều UTF-8", not t22_utf8_bad,
      f"không UTF-8: {t22_utf8_bad}" if t22_utf8_bad else "")
# T22d: chi phí nâng cấp PROVISIONAL (GDD chưa chốt) + API nâng cấp +
# hành vi đổi thật theo bậc (sức chở / gợi ý / mưa).
check("T22d", "PXB_Tools: chi phí nâng cấp PROVISIONAL + canUpgrade/acquire + carryCapacity/hintLevel/isRaining",
      "PROVISIONAL" in tools_js and "canUpgrade" in tools_js
      and "carryCapacity" in tools_js and "hintLevel" in tools_js
      and "isRaining" in tools_js)
# T22e: móc Đèn Soi vào hotspot (PXB_Hotspot) — bậc cao thấy hotspot ẩn.
check("T22e", "PXB_Tools: móc PXB_Hotspot (Đèn Soi bậc cao thấy hotspot ẩn)",
      "PXB_Hotspot" in tools_js and "hotspot" in tools_js.lower())

# ---- Nhóm T23: PXB_Online.js + PXB_SaveCloud.js — online Phase 2 ----
# T23a: Online gọi đúng endpoint server thật (.NET): /health,
# /ledger/balance, /ledger/gift + IdempotencyKey + outbox khi offline.
online_js = read(NADIA_PLUGINS / "PXB_Online.js")
_online_tokens = ["/health", "/ledger/balance", "/ledger/gift",
                  "IdempotencyKey", "outbox", "server-chua-co-endpoint",
                  "pxbOnline", "baseUrl", "$gameSystem.pxbOnline"]
_missing_online = [t for t in _online_tokens if t not in online_js]
check("T23a", "PXB_Online.js: đúng 3 endpoint server thật + IdempotencyKey + outbox + pxbOnline",
      not _missing_online and '"use strict"' in online_js
      and "require(" not in online_js,
      f"thiếu: {_missing_online}" if _missing_online else "")
# T23b: SaveCloud — tài khoản tùy chọn, localStorage mặc định offline,
# LZString nén save, upload/download/apply + login/logout.
cloud_js = read(NADIA_PLUGINS / "PXB_SaveCloud.js")
_cloud_tokens = ["pxbSaveCloud", "uploadSave", "downloadSave", "applySave",
                 "login", "logout", "localStorage", "LZString",
                 "server-chua-co-endpoint", "isLoggedIn"]
_missing_cloud = [t for t in _cloud_tokens if t not in cloud_js]
check("T23b", "PXB_SaveCloud.js: pxbSaveCloud + upload/download/apply + localStorage + LZString + login/logout",
      not _missing_cloud and '"use strict"' in cloud_js
      and "require(" not in cloud_js,
      f"thiếu: {_missing_cloud}" if _missing_cloud else "")
# T23c: trade/đấu giá/công ty=guild CHƯA có endpoint — luôn trả
# server-chua-co-endpoint, KHÔNG giả vờ thành công, KHÔNG tự quyết tiền.
check("T23c", "PXB_Online: trade/đấu giá/guild chưa có endpoint — luôn trả server-chua-co-endpoint",
      "createTrade" in online_js and "listAuction" in online_js
      and "guild" in online_js
      and online_js.count("server-chua-co-endpoint") >= 3)
# T23d: base URL cấu hình được qua tham số plugin, mặc định localhost:5000
# (PROVISIONAL — server skeleton chạy local, chưa có domain thật).
check("T23d", "PXB_Online: baseUrl qua tham số plugin, mặc định localhost:5000 PROVISIONAL",
      "localhost:5000" in online_js and "PROVISIONAL" in online_js
      and "baseUrl" in online_js)
# T23e: SaveCloud không giả vờ đã đồng bộ — upload/download khi chưa có
# endpoint trả server-chua-co-endpoint (không có "đồng bộ thành công" giả).
check("T23e", "PXB_SaveCloud: chưa có endpoint thì upload/download trả server-chua-co-endpoint",
      cloud_js.count("server-chua-co-endpoint") >= 3
      and "uploadSave" in cloud_js and "downloadSave" in cloud_js)

# ---- Nhóm T24 — PXB_Isometric v3 (atlas mode) + atlas PNG trong repo (19/11/2026 ~06:55) ----
# v3 đọc tile data atlas-code (Map001/002) qua mapping JSON + atlas PNG
# img/tilesets/, thay cho đường tileset MV của v2 (giữ nguyên fallback).
# Smoke test stub core MV: /tmp/pxb-iso-v3-smoke.js 55/55 PASS (không commit).
import hashlib as _hashlib
import struct as _struct
_iso_js = read(NADIA_PLUGINS / "PXB_Isometric.js")
_iso_tokens = ["registerAtlas", "atlasFor", "atlasCodeFor", "loadAtlasBitmap",
               "loadAtlasJson", "tintToHex", "setAtlas", "skippedAtlasUnknown",
               "atlasModeOn", "img/tilesets/", "atlas-map"]
_missing_iso = [t for t in _iso_tokens if t not in _iso_js]
check("T24a", "PXB_Isometric v3: đủ API atlas (register/atlasFor/loadBitmap/loadJson/tintToHex/setAtlas)",
      not _missing_iso and "require(" not in _iso_js
      and "isoPos" in _iso_js and "normalTileSource" in _iso_js
      and "panFromOrigin" in _iso_js,
      f"thiếu: {_missing_iso}" if _missing_iso else "")
# T24b: atlas PNG đã vào repo, đúng magic bytes + 512x64 + SHA-256 khớp
# docs/tileset-plan.md §7 (971faa8d…15940 / d1329a32…80949).
def _png_ok(name, sha):
    p = NADIA / "img" / "tilesets" / name
    if not p.is_file():
        return False, f"thiếu {name}"
    raw = p.read_bytes()
    if raw[:8] != b"\x89PNG\r\n\x1a\n":
        return False, f"{name} không phải PNG"
    w, h = _struct.unpack(">II", raw[16:24])
    if (w, h) != (512, 64):
        return False, f"{name} kích thước {w}x{h}, cần 512x64"
    if _hashlib.sha256(raw).hexdigest() != sha:
        return False, f"{name} SHA-256 lệch §7"
    return True, ""
_ok_png1, _d_png1 = _png_ok("atlas-map001.png",
    "971faa8da7d2410ec288bedb5bf981440ad5c6e35bfd4e0348d4a98a98715940")
_ok_png2, _d_png2 = _png_ok("atlas-map002.png",
    "d1329a32bd39d5738708375afa0d9759f0b26ebcdc209bc26b45ce4a39080949")
check("T24b", "Atlas PNG trong repo: magic bytes + 512x64 + SHA-256 khớp tileset-plan.md §7",
      _ok_png1 and _ok_png2, _d_png1 or _d_png2)
# T24c: mapping JSON trỏ đúng PNG đã có + scheme atlas-code + mọi rect
# nằm trong atlas 512x64; code 3 phân lớp theo mapping (Map001 layer 1
# tường, Map002 layer 0 đường nhựa) — khóa điểm tinh tế của v3.
def _atlas_png_ok(fname):
    try:
        a = json.loads(read(NADIA_DATA / fname))
    except Exception as e:  # noqa: BLE001
        return False, str(e)
    if a.get("scheme") != "atlas-code":
        return False, f"{fname} scheme != atlas-code"
    png_path = NADIA / a.get("atlasPng", "")
    if not png_path.is_file():
        return False, f"{fname} atlasPng không có file: {a.get('atlasPng')}"
    for code, t in a.get("tiles", {}).items():
        if not (0 <= t["x"] and 0 <= t["y"] and t["x"] + t["w"] <= 512
                and t["y"] + t["h"] <= 64):
            return False, f"{fname} tile {code} rect tràn atlas"
    return True, ""
_ok_a1, _d_a1 = _atlas_png_ok("atlas-map001.json")
_ok_a2, _d_a2 = _atlas_png_ok("atlas-map002.json")
_atlas1 = json.loads(read(NADIA_DATA / "atlas-map001.json"))
_atlas2 = json.loads(read(NADIA_DATA / "atlas-map002.json"))
_code3_diff = (_atlas1["tiles"]["3"]["layer"] == 1
               and _atlas2["tiles"]["3"]["layer"] == 0)
check("T24c", "Atlas mapping: scheme atlas-code + atlasPng có file + rect trong 512x64 + code 3 khác layer 2 map",
      _ok_a1 and _ok_a2 and _code3_diff, _d_a1 or _d_a2)
# T24d: v3 vẽ atlas đúng luật — frame từ mapping, tint qua tintToHex,
# sàn neo (0.5, 0.5) tại diamondCenter, tường neo (0.5, 1.0) tại isoPos,
# không quay 45° ở đường atlas; code lạ đếm skippedAtlasUnknown.
check("T24d", "PXB_Isometric v3: vẽ atlas theo mapping.layer + tintToHex + neo sàn/tường đúng",
      "mapping.tiles" in _iso_js and "tintToHex(entry.tint)" in _iso_js
      and "skippedAtlasUnknown++" in _iso_js
      and _iso_js.count("anchor.y = 1.0") >= 1
      and "diamondCenter" in _iso_js and "isoPos" in _iso_js)
# T24e: tile data Map001/002 vẫn khớp mapping sau khi v3 vào (khóa lại
# bằng hàm _map_data_ok của T21, tránh v3 làm lệch data).
_ok_m1, _d_m1 = _map_data_ok("Map001", _atlas1)
_ok_m2, _d_m2 = _map_data_ok("Map002", _atlas2)
check("T24e", "Tile data Map001/002 vẫn khớp mapping atlas (T21 khóa lại sau v3)",
      _ok_m1 and _ok_m2, _d_m1 or _d_m2)

# ---- Nhóm T25 — PXB_Isometric v3.1: atlas PNG lỗi -> rơi về fallback v2 (19/11/2026 ~07:50) ----
# Sửa giới hạn v3 đã ghi trong header plugin: PNG thiếu/404 thì Bitmap
# lỗi (isError) -> atlasModeOn() tắt, updateTransform vẽ lại 1 lần bằng
# đường fallback v2 thay vì sprite atlas vẽ trắng, map trống.
# Smoke test stub core MV: /tmp/pxb-iso-v31-smoke.js 18/18 PASS (không commit).
check("T25a", "PXB_Isometric v3.1: atlasModeOn() tắt khi bitmap lỗi (isError)",
      "this._atlasBitmap.isError()" in _iso_js
      and "typeof this._atlasBitmap.isError" in _iso_js)
check("T25b", "PXB_Isometric v3.1: updateTransform vẽ lại 1 lần khi bitmap lỗi, đếm atlasFallback",
      "_atlasBitmapErrorRepainted" in _iso_js
      and "stats.atlasFallback" in _iso_js
      and "atlasFallback: 0" in _iso_js)
check("T25c", "PXB_Isometric v3.1: setAtlas mới reset cờ vẽ lại do lỗi bitmap",
      "_atlasBitmapErrorRepainted = false" in _iso_js)
check("T25d", "PXB_Isometric v3.1: header ghi rõ v3.1 + không còn 'không tự rơi về fallback'",
      "v3.1" in _iso_js and "không tự rơi về fallback" not in _iso_js
      and "isError()" in _iso_js)
_iso_v31_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _iso_v31_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _iso_v31_ok = False
check("T25e", "PXB_Isometric v3.1: node --check qua cú pháp + UTF-8",
      _iso_v31_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T26 — Map003 Khu Công Nhân (19/11/2026 ~08:50) ----
# Map khu 3 theo đúng mẫu Map001/002: lưới 12×9, tile data thật, atlas
# tái dùng atlas-map001.png (chưa có tile xưởng riêng — code 4 nhà bắc
# dùng tạm làm nhà xưởng, ghi PROVISIONAL). Không hotspot mới (5 hotspot
# đã đủ), transfer duy nhất về Map002. Smoke: đếm tile 648/108/28 (xem
# docs/test-report.md); PXB_Isometric đăng ký map 3 + tôn trọng
# mapping.atlasPng (trước đây suy tên PNG từ mapId nên map 3 sẽ 404).
_atlas3 = json.loads(read(NADIA_DATA / "atlas-map003.json"))
_ok_m3, _d_m3 = _map_data_ok("Map003", _atlas3)
check("T26a", "Map003: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m3, _d_m3)
_atlas1b = json.loads(read(NADIA_DATA / "atlas-map001.json"))
check("T26b", "atlas-map003.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas3.get("scheme") == "atlas-code"
      and _atlas3.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas3["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1b["tiles"].items()})
check("T26c", "PXB_Isometric: đăng ký map 3 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 3) return "Map003"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map003_raw = read(NADIA_DATA / "Map003.json")
_map003 = json.loads(_map003_raw)
_transfer_ok = any(
    c.get("code") == 201 and list(c.get("parameters", []))[:2] == [0, 2]
    for e in _map003.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
_transfer_m4_ok = any(
    c.get("code") == 201 and list(c.get("parameters", []))[:2] == [0, 4]
    for e in _map003.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
check("T26d", "Map003: không hotspot mới + transfer về Map002 (5,4) + đi Map004 (5,8) + code 4 xưởng ghi PROVISIONAL",
      "hs-" not in _map003_raw and _transfer_ok and _transfer_m4_ok
      and "PROVISIONAL" in _map003_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map003.json"))
_mb_v26_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v26_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v26_ok = False
check("T26e", "Map003: node --check PXB_Isometric.js sau sửa đăng ký map 3 + UTF-8",
      _mb_v26_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T27 — PXB_MarketBattle: Bụi Đời Chợ Cá (19/11/2026 ~09:00) ----
# Port GDD Mục 11: 3v3/5v5 theo lượt, lưới 12×9, ~3 phút, 4 vũ khí hài,
# 6 vai theo màu chỉ số, thắng giữ sạp 1 tuần, buff Tướng Cướp/Cảnh sát,
# không chết/không mất đồ. Luật chi tiết CHƯA CHỐT — design doc +
# plugin đều ghi PROVISIONAL, chờ chủ duyệt (xem docs/market-battle-design.md
# §11). Smoke test stub core MV: /tmp/pxb-marketbattle-smoke.js 80/80 PASS
# (không commit). Chưa có scene/bản đồ trận MV.
_mb_js = read(NADIA_PLUGINS / "PXB_MarketBattle.js")
_mb_design = read(ROOT / "docs" / "market-battle-design.md")
check("T27a", "PXB_MarketBattle: 6 vai màu + 4 vũ khí hài + lưới 12×9 + trận 180s + giữ sạp 7 ngày + state pxbMarketBattle",
      "GRID_W = 12" in _mb_js and "GRID_H = 9" in _mb_js
      and "BATTLE_SECONDS = 180" in _mb_js and "HOLD_DAYS = 7" in _mb_js
      and '"Chảo"' in _mb_js and '"Cá khô"' in _mb_js and '"Ghế nhựa"' in _mb_js
      and '"Loa"' in _mb_js and "$gameSystem.pxbMarketBattle" in _mb_js)
check("T27b", "MarketBattle: không chết/không mất đồ + buff Tướng Cướp/Cảnh sát + chưa có scene (logic lõi)",
      "không chết" in _mb_js and "không mất đồ" in _mb_js
      and "KHÔNG có scene" in _mb_js and "Scene_MarketBattle" in _mb_js
      and "Tướng Cướp" in _mb_js and "Cảnh sát" in _mb_js)
check("T27c", "plugins.js: đủ 17 plugin, MarketBattle cuối sau SaveCloud, cả 17 bật",
      plugins_js.count('"status": true') == 17
      and plugins_js.find('"PXB_SaveCloud"') < plugins_js.find('"PXB_MarketBattle"'))
check("T27d", "market-battle-design.md: trạng thái CHƯA CHỐT chờ chủ duyệt + mọi số PROVISIONAL",
      "CHƯA CHỐT" in _mb_design and "PROVISIONAL" in _mb_design
      and "PROVISIONAL" in _mb_js)
_mb_v27_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_MarketBattle.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v27_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v27_ok = False
check("T27e", "PXB_MarketBattle: node --check qua cú pháp + UTF-8",
      _mb_v27_ok and _mb_js == read(NADIA_PLUGINS / "PXB_MarketBattle.js"))

# ---- Nhóm T28 — Map004 Bến Xe Miền Đông (19/11/2026 ~09:45) ----
# Map khu 4 theo đúng mẫu Map002 (đường nhựa dọc x=5 xuyên qua cửa (5,4),
# sàn 88/11/9): lưới 12×9, tile data thật, atlas tái dùng atlas-map002.png
# (có tile đường nhựa + sạp + vỉa hè, đúng bến xe — chưa có tile bến xe
# riêng, code 4/5 sạp dùng tạm làm quầy vé / nhà chờ, ghi PROVISIONAL).
# Không hotspot mới, transfer duy nhất về Map003 (5,4); Map003 nay có
# transfer (5,8) -> Map004 nên đồ thị map 1-2-3-4 đã nối được.
_atlas4 = json.loads(read(NADIA_DATA / "atlas-map004.json"))
_ok_m4, _d_m4 = _map_data_ok("Map004", _atlas4)
check("T28a", "Map004: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m4, _d_m4)
_atlas2b = json.loads(read(NADIA_DATA / "atlas-map002.json"))
check("T28b", "atlas-map004.json: scheme atlas-code + TÁI DÙNG atlas-map002.png + tile 1-6 cùng tên atlas-map002",
      _atlas4.get("scheme") == "atlas-code"
      and _atlas4.get("atlasPng") == "img/tilesets/atlas-map002.png"
      and {k: v["name"] for k, v in _atlas4["tiles"].items()}
      == {k: v["name"] for k, v in _atlas2b["tiles"].items()})
check("T28c", "PXB_Isometric: đăng ký map 4 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 4) return "Map004"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map004_raw = read(NADIA_DATA / "Map004.json")
_map004 = json.loads(_map004_raw)
_transfer_m4_ok = any(
    c.get("code") == 201 and list(c.get("parameters", []))[:2] == [0, 3]
    for e in _map004.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
check("T28d", "Map004: không hotspot mới + transfer duy nhất về Map003 (5,4) + quầy vé/nhà chờ ghi PROVISIONAL + NPC đúng khu 4",
      "hs-" not in _map004_raw and _transfer_m4_ok
      and "PROVISIONAL" in _map004_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map004.json")
      and "Bác Tài" in _map004_raw and "Anh Bốc Vác" in _map004_raw
      and "shipper" in _map004_raw.lower() and "bốc vác" in _map004_raw.lower())
_mb_v28_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v28_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v28_ok = False
check("T28e", "Map004: node --check PXB_Isometric.js sau sửa đăng ký map 4 + UTF-8",
      _mb_v28_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T29 — Map005 Làng Đại Học (19/11/2026 ~10:45) ----
# Map khu 5 theo đúng mẫu Map003 (sàn xen kẽ 2 mã, không đường nhựa;
# biên bắc/tây/đông tường nhà, biên nam để trống như mặt tiền mở, 2 ô
# góc): lưới 12×9, tile data thật, atlas tái dùng atlas-map001.png
# (chưa có tile trường riêng, code 3/4/5 nhà trọ dùng tạm làm giảng
# đường / ký túc xá, ghi PROVISIONAL). Không hotspot mới, transfer duy
# nhất về Map004 (5,4); Map004 nay có transfer (5,8) -> Map005 nên đồ
# thị map 1-2-3-4-5 đã nối được. NPC + lời thoại chỉ từ districts.md
# khu 5 ("Học vấn, khoá ngắn hạn, việc làm thêm") + GDD Mục 5 (5 bậc
# học đã chốt) — không bịa học phí/giá/lương mới.
_atlas5 = json.loads(read(NADIA_DATA / "atlas-map005.json"))
_ok_m5, _d_m5 = _map_data_ok("Map005", _atlas5)
check("T29a", "Map005: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m5, _d_m5)
_atlas1b = json.loads(read(NADIA_DATA / "atlas-map001.json"))
check("T29b", "atlas-map005.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas5.get("scheme") == "atlas-code"
      and _atlas5.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas5["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1b["tiles"].items()})
check("T29c", "PXB_Isometric: đăng ký map 5 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 5) return "Map005"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map005_raw = read(NADIA_DATA / "Map005.json")
_map005 = json.loads(_map005_raw)
_transfer_m5_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 4, 5, 4, 0, 0]
    for e in _map005.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
check("T29d", "Map005: không hotspot mới + transfer duy nhất về Map004 (5,4) + giảng đường/ký túc xá ghi PROVISIONAL + NPC đúng khu 5",
      "hs-" not in _map005_raw and _transfer_m5_ok
      and "PROVISIONAL" in _map005_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map005.json")
      and "Thầy Giáo" in _map005_raw and "Sinh Viên Làm Thêm" in _map005_raw
      and "học vấn" in _map005_raw.lower() and "khoá ngắn hạn" in _map005_raw.lower()
      and "việc làm thêm" in _map005_raw.lower() and "cao đẳng" in _map005_raw.lower()
      and "cử nhân" in _map005_raw.lower() and "thạc sĩ" in _map005_raw.lower()
      and "tiến sĩ" in _map005_raw.lower())
_mb_v29_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v29_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v29_ok = False
check("T29e", "Map005: node --check PXB_Isometric.js sau sửa đăng ký map 5 + UTF-8",
      _mb_v29_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T30 — Map006 Chung Cư Cũ (19/11/2026 ~10:50) ----
# Map khu 6 theo đúng mẫu Map001/003: lưới 12×9, tile data thật, atlas
# tái dùng atlas-map001.png (chưa có tile chung cư riêng — code 3/4/5
# nhà trọ dùng tạm làm khối chung cư cũ, ghi PROVISIONAL). Không hotspot
# mới, transfer duy nhất về Map005 (5,4); Map005 nay có cửa (5,8) ->
# Map006 nên đồ thị map 1-2-3-4-5-6 đã nối được.
_atlas6 = json.loads(read(NADIA_DATA / "atlas-map006.json"))
_ok_m6, _d_m6 = _map_data_ok("Map006", _atlas6)
check("T30a", "Map006: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m6, _d_m6)
_atlas1c = json.loads(read(NADIA_DATA / "atlas-map001.json"))
check("T30b", "atlas-map006.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas6.get("scheme") == "atlas-code"
      and _atlas6.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas6["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1c["tiles"].items()})
check("T30c", "PXB_Isometric: đăng ký map 6 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 6) return "Map006"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map006_raw = read(NADIA_DATA / "Map006.json")
_map006 = json.loads(_map006_raw)
_transfer_m6_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 5, 5, 4, 0, 0]
    for e in _map006.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
check("T30d", "Map006: không hotspot mới + transfer duy nhất về Map005 (5,4) + khối chung cư ghi PROVISIONAL + NPC đúng khu 6",
      "hs-" not in _map006_raw and _transfer_m6_ok
      and "PROVISIONAL" in _map006_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map006.json")
      and "Cư Dân Chung Cư" in _map006_raw and "Bác Quản Lý" in _map006_raw
      and "tầng 2" in _map006_raw.lower() and "chi phí vừa" in _map006_raw.lower())
_mb_v30_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v30_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v30_ok = False
check("T30e", "Map006: node --check PXB_Isometric.js sau sửa đăng ký map 6 + UTF-8",
      _mb_v30_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T31 — Map007 Phố Văn Phòng Nhỏ (19/11/2026 ~11:50) ----
# Map khu 7 theo đúng mẫu Map001/003/005/006: lưới 12×9, tile data thật,
# atlas tái dùng atlas-map001.png (chưa có tile văn phòng riêng — code 3/4/5
# nhà trọ dùng tạm làm khối văn phòng nhỏ, ghi PROVISIONAL). Không hotspot
# mới, transfer duy nhất về Map006 (5,4); Map006 nay có cửa (5,8) ->
# Map007 nên đồ thị map 1-2-3-4-5-6-7 đã nối được. NPC + lời thoại chỉ
# từ docs/districts.md khu 7 + MapInfos[7] unlock (Trí 40 / Cao đẳng /
# Danh vọng 200) — không bịa lương/giá.
_atlas7 = json.loads(read(NADIA_DATA / "atlas-map007.json"))
_ok_m7, _d_m7 = _map_data_ok("Map007", _atlas7)
check("T31a", "Map007: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m7, _d_m7)
_atlas1d = json.loads(read(NADIA_DATA / "atlas-map001.json"))
check("T31b", "atlas-map007.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas7.get("scheme") == "atlas-code"
      and _atlas7.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas7["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1d["tiles"].items()})
check("T31c", "PXB_Isometric: đăng ký map 7 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 7) return "Map007"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map007_raw = read(NADIA_DATA / "Map007.json")
_map007 = json.loads(_map007_raw)
_transfer_m7_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 6, 5, 4, 0, 0]
    for e in _map007.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
_map006_now = json.loads(read(NADIA_DATA / "Map006.json"))
_door_m6_m7_ok = any(
    e and e.get("x") == 5 and e.get("y") == 8
    and any(c.get("code") == 201 and list(c.get("parameters", [])) == [0, 7, 5, 4, 0, 0]
            for p in e.get("pages", []) for c in p.get("list", []))
    for e in _map006_now.get("events", []))
check("T31d", "Map007: không hotspot mới + transfer duy nhất về Map006 (5,4) + Map006 có cửa (5,8) đi Map007 + khối văn phòng ghi PROVISIONAL + NPC đúng khu 7",
      "hs-" not in _map007_raw and _transfer_m7_ok and _door_m6_m7_ok
      and "PROVISIONAL" in _map007_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map007.json")
      and "Nhân Viên Văn Phòng" in _map007_raw and "Thực Tập Sinh" in _map007_raw
      and "việc văn phòng cấp thấp" in _map007_raw.lower() and "thực tập" in _map007_raw.lower()
      and "trí 40" in _map007_raw.lower() and "cao đẳng" in _map007_raw.lower()
      and "danh vọng 200" in _map007_raw.lower())
_mb_v31_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v31_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v31_ok = False
check("T31e", "Map007: node --check PXB_Isometric.js sau sửa đăng ký map 7 + UTF-8",
      _mb_v31_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T32 — Map008 Khu Chung Cư Cao Cấp (19/11/2026 ~12:50) ----
# Map khu 8 theo đúng mẫu Map001/003/005/006/007: lưới 12×9, tile data thật,
# atlas tái dùng atlas-map001.png (chưa có tile chung cư cao cấp riêng —
# code 3/4/5 nhà trọ dùng tạm làm khối chung cư cao cấp, ghi PROVISIONAL).
# Không hotspot mới, transfer duy nhất về Map007 (5,4); Map007 nay có cửa
# (5,8) -> Map008 nên đồ thị map 1-2-3-4-5-6-7-8 đã nối được. NPC + lời
# thoại chỉ từ docs/districts.md khu 8 ("Nhà ở tầng 3.") + MapInfos[8]
# unlock ("Chương 3 — bài kiểm tra rank.") — không bịa lương/giá.
_atlas8 = json.loads(read(NADIA_DATA / "atlas-map008.json"))
_ok_m8, _d_m8 = _map_data_ok("Map008", _atlas8)
check("T32a", "Map008: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m8, _d_m8)
check("T32b", "atlas-map008.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas8.get("scheme") == "atlas-code"
      and _atlas8.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas8["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1d["tiles"].items()})
check("T32c", "PXB_Isometric: đăng ký map 8 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 8) return "Map008"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map008_raw = read(NADIA_DATA / "Map008.json")
_map008 = json.loads(_map008_raw)
_transfer_m8_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 7, 5, 4, 0, 0]
    for e in _map008.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
_map007_now = json.loads(read(NADIA_DATA / "Map007.json"))
_door_m7_m8_ok = any(
    e and e.get("x") == 5 and e.get("y") == 8
    and any(c.get("code") == 201 and list(c.get("parameters", [])) == [0, 8, 5, 4, 0, 0]
            for p in e.get("pages", []) for c in p.get("list", []))
    for e in _map007_now.get("events", []))
check("T32d", "Map008: không hotspot mới + transfer duy nhất về Map007 (5,4) + Map007 có cửa (5,8) đi Map008 + khối chung cư cao cấp ghi PROVISIONAL + NPC đúng khu 8",
      "hs-" not in _map008_raw and _transfer_m8_ok and _door_m7_m8_ok
      and "PROVISIONAL" in _map008_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map008.json")
      and "Cư Dân Cao Cấp" in _map008_raw and "Bảo Vệ Chung Cư" in _map008_raw
      and "nhà ở tầng 3" in _map008_raw.lower() and "chương 3" in _map008_raw.lower()
      and "bài kiểm tra rank" in _map008_raw.lower())
_mb_v32_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v32_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v32_ok = False
check("T32e", "Map008: node --check PXB_Isometric.js sau sửa đăng ký map 8 + UTF-8",
      _mb_v32_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T33 — Map009 Phố Thương Mại (19/11/2026 ~13:45) ----
# Map khu 9 theo đúng mẫu Map001/003/005/006/007/008: lưới 12×9, tile data thật,
# atlas tái dùng atlas-map001.png (chưa có tile cửa hàng riêng —
# code 3/4/5 nhà trọ dùng tạm làm khối cửa hàng, ghi PROVISIONAL).
# Không hotspot mới, transfer duy nhất về Map008 (5,4); Map008 nay có cửa
# (5,8) -> Map009 nên đồ thị map 1-2-3-4-5-6-7-8-9 đã nối được. NPC + lời
# thoại chỉ từ docs/districts.md khu 9 ("Buôn bán quy mô vừa, cửa hàng.")
# + MapInfos[9] unlock ("Chương 3 — bài kiểm tra rank.") — không bịa giá/lương.
_atlas9 = json.loads(read(NADIA_DATA / "atlas-map009.json"))
_ok_m9, _d_m9 = _map_data_ok("Map009", _atlas9)
check("T33a", "Map009: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m9, _d_m9)
check("T33b", "atlas-map009.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas9.get("scheme") == "atlas-code"
      and _atlas9.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas9["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1d["tiles"].items()})
check("T33c", "PXB_Isometric: đăng ký map 9 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 9) return "Map009"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map009_raw = read(NADIA_DATA / "Map009.json")
_map009 = json.loads(_map009_raw)
_transfer_m9_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 8, 5, 4, 0, 0]
    for e in _map009.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
_map008_now = json.loads(read(NADIA_DATA / "Map008.json"))
_door_m8_m9_ok = any(
    e and e.get("x") == 5 and e.get("y") == 8
    and any(c.get("code") == 201 and list(c.get("parameters", [])) == [0, 9, 5, 4, 0, 0]
            for p in e.get("pages", []) for c in p.get("list", []))
    for e in _map008_now.get("events", []))
check("T33d", "Map009: không hotspot mới + transfer duy nhất về Map008 (5,4) + Map008 có cửa (5,8) đi Map009 + khối cửa hàng ghi PROVISIONAL + NPC đúng khu 9",
      "hs-" not in _map009_raw and _transfer_m9_ok and _door_m8_m9_ok
      and "PROVISIONAL" in _map009_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map009.json")
      and "Chủ Cửa Hàng" in _map009_raw and "Người Bán Hàng" in _map009_raw
      and "buôn bán quy mô vừa" in _map009_raw.lower() and "cửa hàng" in _map009_raw.lower()
      and "chương 3" in _map009_raw.lower() and "bài kiểm tra rank" in _map009_raw.lower())
_mb_v33_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v33_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v33_ok = False
check("T33e", "Map009: node --check PXB_Isometric.js sau sửa đăng ký map 9 + UTF-8",
      _mb_v33_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T34 — Map010 Khu Công Nghệ (19/11/2026 ~14:45) ----
# Map khu 10 theo đúng mẫu Map001/003/005/006/007/008/009: lưới 12×9, tile data thật,
# atlas tái dùng atlas-map001.png (chưa có tile công nghệ riêng —
# code 3/4/5 nhà trọ dùng tạm làm khối công nghệ, ghi PROVISIONAL).
# Không hotspot mới, transfer duy nhất về Map009 (5,4); Map009 nay có cửa
# (5,8) -> Map010 nên đồ thị map 1-2-3-4-5-6-7-8-9-10 đã nối được. NPC + lời
# thoại chỉ từ docs/districts.md khu 10 ("Việc công nghệ, yêu cầu Trí cao.")
# + MapInfos[10] unlock ("Chương 3 — bài kiểm tra rank.") — không bịa giá/lương.
_atlas10 = json.loads(read(NADIA_DATA / "atlas-map010.json"))
_ok_m10, _d_m10 = _map_data_ok("Map010", _atlas10)
check("T34a", "Map010: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m10, _d_m10)
check("T34b", "atlas-map010.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas10.get("scheme") == "atlas-code"
      and _atlas10.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas10["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1d["tiles"].items()})
check("T34c", "PXB_Isometric: đăng ký map 10 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 10) return "Map010"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map010_raw = read(NADIA_DATA / "Map010.json")
_map010 = json.loads(_map010_raw)
_transfer_m10_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 9, 5, 4, 0, 0]
    for e in _map010.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
_map009_now = json.loads(read(NADIA_DATA / "Map009.json"))
_door_m9_m10_ok = any(
    e and e.get("x") == 5 and e.get("y") == 8
    and any(c.get("code") == 201 and list(c.get("parameters", [])) == [0, 10, 5, 4, 0, 0]
            for p in e.get("pages", []) for c in p.get("list", []))
    for e in _map009_now.get("events", []))
check("T34d", "Map010: không hotspot mới + transfer duy nhất về Map009 (5,4) + Map009 có cửa (5,8) đi Map010 + khối công nghệ ghi PROVISIONAL + NPC đúng khu 10",
      "hs-" not in _map010_raw and _transfer_m10_ok and _door_m9_m10_ok
      and "PROVISIONAL" in _map010_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map010.json")
      and "Lập Trình Viên" in _map010_raw and "Kỹ Sư Phần Mềm" in _map010_raw
      and "việc công nghệ" in _map010_raw.lower() and "trí cao" in _map010_raw.lower()
      and "chương 3" in _map010_raw.lower() and "bài kiểm tra rank" in _map010_raw.lower())
_mb_v34_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v34_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v34_ok = False
check("T34e", "Map010: node --check PXB_Isometric.js sau sửa đăng ký map 10 + UTF-8",
      _mb_v34_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

# ---- Nhóm T35 — Map011 Phố Tây (19/11/2026 ~15:50) ----
# Map khu 11 theo đúng mẫu Map001/003/005/006/007/008/009/010: lưới 12×9, tile data thật,
# atlas tái dùng atlas-map001.png (chưa có tile phố Tây riêng —
# code 3/4/5 nhà trọ dùng tạm làm khối phố Tây, ghi PROVISIONAL).
# Không hotspot mới, transfer duy nhất về Map010 (5,4); Map010 nay có cửa
# (5,8) -> Map011 nên đồ thị map 1-2-3-4-5-6-7-8-9-10-11 đã nối được. NPC + lời
# thoại chỉ từ docs/districts.md khu 11 ("Dịch vụ cao cấp, ngoại ngữ / giao tiếp.")
# + MapInfos[11] unlock ("Chương 4 — 3 quest giúp người + ≥1 quan hệ thân thiết.")
# — không bịa giá/lương.
_atlas11 = json.loads(read(NADIA_DATA / "atlas-map011.json"))
_ok_m11, _d_m11 = _map_data_ok("Map011", _atlas11)
check("T35a", "Map011: lưới 12×9, data 648, layer0 108/108, layer1 28/108, mã khớp mapping, event không bị tường đè",
      _ok_m11, _d_m11)
check("T35b", "atlas-map011.json: scheme atlas-code + TÁI DÙNG atlas-map001.png + tile 1-5 cùng tên atlas-map001",
      _atlas11.get("scheme") == "atlas-code"
      and _atlas11.get("atlasPng") == "img/tilesets/atlas-map001.png"
      and {k: v["name"] for k, v in _atlas11["tiles"].items()}
      == {k: v["name"] for k, v in _atlas1d["tiles"].items()})
check("T35c", "PXB_Isometric: đăng ký map 11 + loadAtlasBitmap tôn trọng mapping.atlasPng",
      'if (mapId === 11) return "Map011"' in _iso_js
      and "mapping.atlasPng" in _iso_js
      and "mapping && mapping.atlasPng" in _iso_js)
_map011_raw = read(NADIA_DATA / "Map011.json")
_map011 = json.loads(_map011_raw)
_transfer_m11_ok = any(
    c.get("code") == 201 and list(c.get("parameters", [])) == [0, 10, 5, 4, 0, 0]
    for e in _map011.get("events", []) if e
    for p in e.get("pages", []) for c in p.get("list", []))
_map010_now = json.loads(read(NADIA_DATA / "Map010.json"))
_door_m10_m11_ok = any(
    e and e.get("x") == 5 and e.get("y") == 8
    and any(c.get("code") == 201 and list(c.get("parameters", [])) == [0, 11, 5, 4, 0, 0]
            for p in e.get("pages", []) for c in p.get("list", []))
    for e in _map010_now.get("events", []))
check("T35d", "Map011: không hotspot mới + transfer duy nhất về Map010 (5,4) + Map010 có cửa (5,8) đi Map011 + khối phố Tây ghi PROVISIONAL + NPC đúng khu 11",
      "hs-" not in _map011_raw and _transfer_m11_ok and _door_m10_m11_ok
      and "PROVISIONAL" in _map011_raw and "PROVISIONAL" in read(NADIA_DATA / "atlas-map011.json")
      and "Nhân Viên Lễ Tân" in _map011_raw and "Hướng Dẫn Viên" in _map011_raw
      and "dịch vụ cao cấp" in _map011_raw.lower() and "ngoại ngữ" in _map011_raw.lower()
      and "giao tiếp" in _map011_raw.lower()
      and "chương 4" in _map011_raw.lower() and "3 quest giúp người" in _map011_raw.lower()
      and "quan hệ thân thiết" in _map011_raw.lower())
_mb_v35_ok = True
try:
    _r = subprocess.run(["node", "--check", str(NADIA_PLUGINS / "PXB_Isometric.js")],
                        capture_output=True, text=True, timeout=30)
    _mb_v35_ok = _r.returncode == 0
except Exception:  # noqa: BLE001
    _mb_v35_ok = False
check("T35e", "Map011: node --check PXB_Isometric.js sau sửa đăng ký map 11 + UTF-8",
      _mb_v35_ok and _iso_js == read(NADIA_PLUGINS / "PXB_Isometric.js"))

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
print("Unity vẫn chưa có; dotnet 8.0.428 có ở ~/.dotnet; core MV v1.6.1 đã có;")
print("PXB_Isometric v2 đã móc Tilemap (smoke test stub 36/36 PASS), Hotspot/Jobs")
print("đã viết (smoke 26/26 + 40/40 PASS), Crafting/PhoneHub đã viết (smoke")
print("52/52 + 56/56 PASS), Education/Economy đã viết (smoke 89/89 + 78/78")
print("PASS), Social đã viết (smoke 85/85 PASS), Titles/Story đã viết (smoke")
print("68/68 + 109/109 PASS), Tools đã viết (smoke 140/140 PASS, 12 câu")
print("ToolBehaviour đúng nguyên văn Crafting.cs), Online/SaveCloud đã viết")
print("(smoke 68/68 PASS, trade/đấu giá/guild trả server-chua-co-endpoint),")
print("tile data Map001/002 nay thật (atlas-code, layer 0 108/108 + layer 1")
print("28/108), atlas PNG đã vào repo img/tilesets/ (SHA khớp §7) +")
print("PXB_Isometric v3 (atlas mode) đã viết (smoke stub 55/55 PASS) + v3.1")
print("(atlas PNG lỗi -> rơi về fallback v2, smoke stub 18/18 PASS), Map003")
print("Khu Công Nhân đã có tile data thật (648/108/28, tái dùng atlas-map001),")
print("Map004 Bến Xe Miền Đông đã có tile data thật (648/108/28, tái dùng")
print("atlas-map002, đường nhựa dọc x=5, NPC Bác Tài + Anh Bốc Vác, transfer")
print("về Map003; Map003 nay có cửa (5,8) đi Map004; Map005 Làng Đại Học")
print("đã có tile data thật (648/108/28, tái dùng atlas-map001, NPC Thầy Giáo")
print("+ Sinh Viên Làm Thêm, transfer về Map004; Map004 nay có cửa (5,8) đi")
print("Map005; Map006 Chung Cư Cũ đã có tile data thật (648/108/28, tái dùng")
print("atlas-map001, NPC Cư Dân Chung Cư + Bác Quản Lý, transfer về Map005;")
print("Map005 nay có cửa (5,8) đi Map006; Map007 Phố Văn Phòng Nhỏ")
print("đã có tile data thật (648/108/28, tái dùng atlas-map001, NPC Nhân")
print("Viên Văn Phòng + Thực Tập Sinh, transfer về Map006; Map006 nay có")
print("cửa (5,8) đi Map007 — đồ thị map 1-2-3-4-5-6-7 đã nối được), Map008")
print("Khu Chung Cư Cao Cấp đã có tile data thật (648/108/28, tái dùng")
print("atlas-map001, NPC Cư Dân Cao Cấp + Bảo Vệ Chung Cư, transfer về")
print("Map007; Map007 nay có cửa (5,8) đi Map008; Map009 Phố Thương Mại")
print("đã có tile data thật (648/108/28, tái dùng atlas-map001, NPC Chủ")
print("Cửa Hàng + Người Bán Hàng, transfer về Map008; Map008 nay có cửa")
print("(5,8) đi Map009 — đồ thị map 1-2-3-4-5-6-7-8-9 đã nối được), Map010")
print("Khu Công Nghệ đã có tile data thật (648/108/28, tái dùng atlas-map001,")
print("NPC Lập Trình Viên + Kỹ Sư Phần Mềm, transfer về Map009; Map009 nay có")
print("cửa (5,8) đi Map010 — đồ thị map 1-2-3-4-5-6-7-8-9-10 đã nối được), Map011")
print("Phố Tây đã có tile data thật (648/108/28, tái dùng atlas-map001, NPC Nhân")
print("Viên Lễ Tân + Hướng Dẫn Viên, transfer về Map010; Map010 nay có cửa")
print("(5,8) đi Map011 — đồ thị map 1-2-3-4-5-6-7-8-9-10-11 đã nối được), nhưng")
print("PXB_MarketBattle đã viết (Bụi Đời Chợ Cá, smoke stub 80/80 PASS, luật")
print("chi tiết PROVISIONAL chờ chủ duyệt), nhưng")
print("chưa mở trình duyệt chơi được thật — cần chạy game MV thật với atlas")
print("để thấy map Xóm Trọ Cũ (xem docs/test-report.md).")
