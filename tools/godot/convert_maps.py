#!/usr/bin/env python3
"""Port Map001-Map008 tu RPG Maker MV sang Godot (G1 slice parity + G3 buoc 1-2).

Doc: python3 tools/godot/convert_maps.py
Nguon (khong sua):  src/nadia/www/data/Map00{1..8}.json (tile data 12x9, events),
                    src/nadia/www/data/atlas-map00{1..8}.json (vi tri tile trong atlas PNG),
                    src/nadia/www/data/Actors.js (greet/hint NPC — doc trong file),
                    src/nadia/www/js/plugins/PXB_Hotspot.js (bang hotspot slice),
                    src/nadia/www/data/System.json (diem bat dau 4,5 Map001).
Dich:                src/godot/data/maps.json + copy atlas PNG vao src/godot/tiles/
                     (PNG la binary — khong push qua snapshot-push, xem docs/godot-g1.md).

Quy uoc event (tu Map JSON):
  NPC     -> {kind:"npc", id, name, tile, greet, hint}
  Hotspot -> {kind:"hotspot", id, name, tile, best_frame, material, amount}
  Craft   -> {kind:"craft", name, tile, recipe}
  Door    -> {kind:"door", name, tile, to_map} (to_map doc tu lenh TRANSFER code 201)

G3 buoc 1 (20/11): them Map003 Khu Cong Nhan, Map004 Ben Xe Mien Dong,
Map005 Lang Dai Hoc. Atlas PNG TAI DUNG: Map003/Map005 dung atlas-map001.png,
Map004 dung atlas-map002.png (theo atlas-map00X.json: truong "atlasPng") —
converter lay ten PNG tu truong do, khong doan theo so map.
G3 buoc 2 (20/11): them Map006 Chung Cu Cu, Map007 Pho Van Phong Nho,
Map008 Khu Chung Cu Cao Cap — ca 3 tai dung atlas-map001.png; do thi MV
1-2-3-4-5-6-7-8 da thong 2 chieu san (khong can ADDED_DOORS them), cua
cuoi Map008 -> Map009 chua port (bi chan co bao, nhu Map005 -> Map006 o
buoc 1). Map006-008 khong co hotspot / Goc Che Tao trong MV.
"""
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]  # ~/workspace/pho-xo-bo
MV = ROOT / "src/nadia/www/data"
GODOT = ROOT / "src/godot"

MAP_IDS = [1, 2, 3, 4, 5, 6, 7, 8]  # G3 buoc 2: 1-8 (Map009+ o buoc sau)

# --- Du lieu khong co trong Map JSON, lay tu Actors.js / PXB_Hotspot.js ---
NPC_TEXT = {
    "Cô Tư": {
        "id": "co-tu",
        "greet": "Con mới lên phố hả? Phòng trọ thì có sẵn, việc thì ra chợ mà kiếm. Bí thì cứ hỏi cô.",
        "hint": "Ra chợ sớm mà nhặt đồ. Còn chế Xe Đẩy thì ghé Góc Chế Tạo trong phòng con, cô để sẵn bàn gỗ với đèn vàng đó.",
    },
    "Bạn Thân": {
        "id": "ban-than",
        "greet": "Ê, lên phố rồi hả! Tao ở đây lâu rồi, có gì khó cứ rủ tao đi cùng, làm chung nhanh hơn.",
        "hint": "Đi hai người vui hơn đi một mình. Mày làm ca nghề xong thì ghé chợ phụ chị Lệ, bả hay cho thêm đồ lắm.",
    },
    "Chị Lệ": {
        "id": "chi-le",
        "greet": "Sạp chị mở từ 5 giờ sáng. Muốn bán rong thì học cách xếp hàng cho đẹp, khách mới ghé.",
        "hint": "Buổi sáng chợ đông nhất, bán rong khung Sáng là ngon nhất. Có lá chuối thì để dành gói hàng cho chị.",
    },
    "Anh Hải": {
        "id": "anh-hai",
        "greet": "Shipper thì chạy nhiều, biết đường là tiền về. Tối chạy đơn nhiều hơn, mà phải có đèn soi đường.",
        "hint": "Đơn buổi tối trả cao hơn. Mày mà chế được Đèn Soi thì chạy tối khỏi lo hẻm tối.",
    },
    # --- G3 buoc 1 (Map003-005): greet NGUYEN VAN tu lenh Show Text (code 401)
    # trong Map JSON (bo dau khoang trang thua); hint do port viet moi, noi
    # dung theo districts.md / GDD (ca kip, ben xe, bac hoc, khoa ngan han) —
    # xem docs/godot-g3.md §1. Chua co trong Actors.js / MV.
    "Anh Ba": {
        "id": "anh-ba",
        "greet": "Ca ở xưởng này quen rồi thì khỏe. Mới vào thì theo ca của tổ mình, có gì chưa biết cứ hỏi anh em trong xưởng.",
        "hint": "Ca kíp ở xưởng theo tổ — làm đủ ca thì lương ổn định. Muốn đổi nghề thì qua bến xe hỏi việc shipper, bốc vác.",
    },
    "Chị Sáu": {
        "id": "chi-sau",
        "greet": "Khu này toàn người đi làm ca, sáng ra đông lắm. Tan ca thì ra chợ mua đồ, về trọ nghỉ sớm mai đi làm tiếp.",
        "hint": "Sáng ra chợ sớm, tan ca về trọ nghỉ sớm — giữ sức mai đi làm tiếp. Lá chuối gói hàng thì để dành cho chị Lệ.",
    },
    "Bác Tài": {
        "id": "bac-tai",
        "greet": "Bến này xe đi khắp các khu trong An Bình. Muốn đi đâu thì lên xe, vé tính theo chặng. Shipper chạy tuyến này thì đông khách lắm.",
        "hint": "Xe đi khắp các khu trong An Bình, vé tính theo chặng. Shipper chạy tuyến bến này thì đông khách, đơn nhiều.",
    },
    "Anh Bốc Vác": {
        "id": "anh-boc-vac",
        "greet": "Bốc vác ở bến này việc nhiều, trả theo chuyến. Mới vào thì theo ca của tổ, có gì chưa biết cứ hỏi anh em trong bến.",
        "hint": "Bốc vác trả theo chuyến, việc nhiều nhất lúc xe về bến. Mới vào thì theo ca của tổ mà làm.",
    },
    "Thầy Giáo": {
        "id": "thay-giao",
        "greet": "Làng này học vấn là chính. Muốn lên bậc thì xem đủ Trí chưa: THPT Trí 20, Cao đẳng Trí 40, Cử nhân Trí 60, Thạc sĩ Trí 75, Tiến sĩ Trí 90 — Tiến sĩ cần mentor. Học phí tăng gần gấp đôi mỗi bậc.",
        "hint": "Muốn lên bậc thì mở điện thoại xem mục Học tập — đăng ký đúng bậc đủ Trí, học phí tăng gần gấp đôi mỗi bậc.",
    },
    "Sinh Viên Làm Thêm": {
        "id": "sinh-vien-lam-them",
        "greet": "Ngoài giờ học thì nhận việc làm thêm kiếm tiền trang trải. Khoá ngắn hạn 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ, mở nghề phụ — học xong làm được việc ngay.",
        "hint": "Khóa ngắn hạn 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ — học xong làm được việc ngay, mở nghề phụ.",
    },
    # --- G3 buoc 2 (Map006-008): greet NGUYEN VAN tu lenh Show Text (code 401)
    # trong Map JSON (nhieu dong 401 noi bang dau cach); hint do port viet moi,
    # noi dung theo districts.md / GDD (nha tang 2/3, viec van phong, Chuong 3
    # kiem tra rank) — xem docs/godot-g3.md §1. Chua co trong Actors.js / MV.
    "Cư Dân Chung Cư": {
        "id": "cu-dan-chung-cu",
        "greet": "Chung cư cũ này là nhà ở tầng 2, chi phí vừa. Ở đây lâu rồi, quen hết cả dãy hành lang.",
        "hint": "Nhà tầng 2 chi phí vừa, ở lâu thì giữ nhà cửa gọn gàng, hàng xóm quý nhau. Muốn lên tầng 3 thì qua Chương 3 kiểm tra rank.",
    },
    "Bác Quản Lý": {
        "id": "bac-quan-ly",
        "greet": "Nhà ở đây là tầng 2, chi phí vừa — muốn ở lâu thì giữ nhà cửa gọn gàng, hàng xóm quý nhau.",
        "hint": "Giữ nhà cửa gọn gàng thì ở lâu được, hàng xóm quý nhau. Nhà tầng 3 thì phải qua Chương 3 kiểm tra rank.",
    },
    "Nhân Viên Văn Phòng": {
        "id": "nhan-vien-van-phong",
        "greet": "Việc văn phòng cấp thấp ở phố này nhiều — làm ổn định, chỉ cần chăm chỉ và đúng giờ. Muốn việc ổn định thì cần Trí 40 hoặc bằng Cao đẳng, Danh vọng 200.",
        "hint": "Việc văn phòng cần Trí 40 hoặc bằng Cao đẳng, Danh vọng 200 — đúng ngưỡng mở Chương 2. Làm ổn định, chăm chỉ và đúng giờ.",
    },
    "Thực Tập Sinh": {
        "id": "thuc-tap-sinh",
        "greet": "Em đang thực tập ở công ty nhỏ cuối phố — thực tập xong mới xin được việc văn phòng cấp thấp.",
        "hint": "Thực tập xong mới xin được việc văn phòng cấp thấp — mở điện thoại mục Việc làm xem nghề nào đang tuyển.",
    },
    "Cư Dân Cao Cấp": {
        "id": "cu-dan-cao-cap",
        "greet": "Nhà ở đây là nhà ở tầng 3 — khu chung cư cao cấp. Muốn ở được đây thì phải qua Chương 3 — bài kiểm tra rank.",
        "hint": "Nhà tầng 3 chỉ mở khi qua Chương 3 — bài kiểm tra rank. Qua rồi thì mở điện thoại mục Bản đồ đi nhanh tới đây.",
    },
    "Bảo Vệ Chung Cư": {
        "id": "bao-ve-chung-cu",
        "greet": "Chung cư cao cấp chỉ mở khi qua bài kiểm tra rank ở Chương 3. Qua được bài kiểm tra rank thì khu này mới mở.",
        "hint": "Chưa qua bài kiểm tra rank ở Chương 3 thì khu này chưa mở cho mình — học lên bậc, tích Danh vọng rồi quay lại.",
    },
}

# Bang hotspot slice — PORT TRUC TIEP PXB_Hotspot.js HOTSPOTS (PROVISIONAL, chua chot GDD).
HOTSPOTS = {
    "Hẻm trọ buổi tối": {"id": "hs-tro-toi", "best_frame": "Tối", "material": "chai-nhua", "amount": 2},
    "Sạp rau buổi sáng": {"id": "hs-cho-sang", "best_frame": "Sáng", "material": "la-chuoi", "amount": 2},
    "Góc phế liệu chợ": {"id": "hs-cho-chieu", "best_frame": "Chiều", "material": "sat-vun", "amount": 1},
}

# Goc Che Tao: cong thuc tu PXB_Crafting.js / event text MV.
CRAFT = {
    1: {"recipe": "Xe Đẩy Hàng", "needs": "Khung Sắt + Bánh Xe + Ván Gỗ"},
    2: {"recipe": "Đèn Soi", "needs": "Pin + Bóng Đèn + Vỏ Nhựa"},
}

DOORS = {}  # Khong dung nua: to_map doc tu lenh TRANSFER (code 201) cua event.

# Cua THEM o port (khong co trong MV — xem docs/godot-g3.md §1):
# Map002 trong MV chi co 1 event cua (ve Map001); khong co cua nao di
# Map003 nen do thi MV chi noi 1 chieu (Map003 co cua ve Map002 nhung
# khong co duong di nguoc lai). Them cua (5,8) tren Map002 di Map003
# de chuoi 1-2-3-4-5 thong 2 chieu nhu cac map 3-5 (cua ve (5,4) +
# cua di (5,8)). O (5,8) tren Map002 trong (lop 1 = 0, khong event).
ADDED_DOORS = {
    2: [{"kind": "door", "name": "Cửa đi Khu Công Nhân", "tile": [5, 8], "to_map": 3}],
}
START = {"map": 1, "x": 4, "y": 5}  # System.json startMapId/startX/startY


def transfer_target(ev: dict) -> int:
    """Doc map dich tu lenh TRANSFER (code 201) trong event MV:
    parameters = [mode, mapId, x, y, direction, fade]."""
    for page in ev.get("pages", []):
        for cmd in page.get("list", []):
            if cmd.get("code") == 201:
                params = cmd.get("parameters", [])
                assert len(params) >= 2 and int(params[1]) in MAP_IDS + [9], (
                    f"TRANSFER dich la {params[1]} nam ngoai MAP_IDS")
                return int(params[1])
    raise ValueError(f"event cua {ev.get('name')!r} khong co lenh TRANSFER")


def convert(map_id: int) -> dict:
    tag = f"Map{map_id:03d}"
    m = json.loads((MV / f"{tag}.json").read_text(encoding="utf-8"))
    atlas = json.loads((MV / f"atlas-map{tag[3:]}.json").read_text(encoding="utf-8"))
    assert m["width"] == 12 and m["height"] == 9, f"{tag} khong phai 12x9"
    data = m["data"]
    assert len(data) == 648, f"{tag} data len {len(data)} != 648 (6 lop x 108)"
    layers = [data[0:108], data[108:216]]  # L0 nen, L1 vat — cac lop sau MV de trong

    events = []
    for ev in m["events"]:
        if not ev:
            continue
        name = ev["name"]
        tile = [ev["x"], ev["y"]]
        if name in NPC_TEXT:
            t = NPC_TEXT[name]
            events.append({"kind": "npc", "id": t["id"], "name": name,
                           "tile": tile, "greet": t["greet"], "hint": t["hint"]})
        elif name in HOTSPOTS:
            h = HOTSPOTS[name]
            events.append({"kind": "hotspot", "id": h["id"], "name": name,
                           "tile": tile, "best_frame": h["best_frame"],
                           "material": h["material"], "amount": h["amount"]})
        elif name == "Góc Chế Tạo":
            c = CRAFT[map_id]
            events.append({"kind": "craft", "name": name, "tile": tile,
                           "recipe": c["recipe"], "needs": c["needs"]})
        elif "Cửa" in name:
            events.append({"kind": "door", "name": name, "tile": tile,
                           "to_map": transfer_target(ev)})
        else:
            raise ValueError(f"{tag}: event chua biet cach port: {name!r}")
    events.extend(ADDED_DOORS.get(map_id, []))

    # Ten PNG lay tu atlas-map00X.json (truong "atlasPng"): Map003/Map005
    # tai dung atlas-map001.png, Map004 tai dung atlas-map002.png.
    png_name = str(atlas["atlasPng"]).split("/")[-1]
    return {
        "id": map_id,
        "name": atlas["mapName"],
        "width": 12, "height": 9,
        "tile_w": 64, "tile_h": 32,
        "atlas_png": f"res://tiles/{png_name}",
        "atlas_tiles": atlas["tiles"],  # id(str) -> {name,x,y,w,h,layer}
        "layers": layers,
        "events": events,
    }


def main() -> None:
    out = {"start": START, "maps": [convert(n) for n in MAP_IDS]}
    dest = GODOT / "data" / "maps.json"
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    tiles_dir = GODOT / "tiles"
    tiles_dir.mkdir(exist_ok=True)
    for n in ("001", "002"):
        src = ROOT / f"src/nadia/www/img/tilesets/atlas-map{n}.png"
        shutil.copy2(src, tiles_dir / f"atlas-map{n}.png")
    for mp in out["maps"]:
        print(f"Map{mp['id']:03d} {mp['name']}: L0={sum(1 for v in mp['layers'][0] if v)} "
              f"L1={sum(1 for v in mp['layers'][1] if v)} events={len(mp['events'])} "
              f"({', '.join(e['kind'] + ':' + e['name'] for e in mp['events'])})")
    print("OK ->", dest)


if __name__ == "__main__":
    main()
