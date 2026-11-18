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
