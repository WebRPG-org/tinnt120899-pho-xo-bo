#!/usr/bin/env python3
"""Port Map001/Map002 tu RPG Maker MV sang Godot (G1 slice parity).

Doc: python3 tools/godot/convert_maps.py
Nguon (khong sua):  src/nadia/www/data/Map00{1,2}.json (tile data 12x9, events),
                    src/nadia/www/data/atlas-map00{1,2}.json (vi tri tile trong atlas PNG),
                    src/nadia/www/data/Actors.js (greet/hint NPC — doc trong file),
                    src/nadia/www/js/plugins/PXB_Hotspot.js (bang hotspot slice),
                    src/nadia/www/data/System.json (diem bat dau 4,5 Map001).
Dich:                src/godot/data/maps.json + copy atlas PNG vao src/godot/tiles/
                     (PNG la binary — khong push qua snapshot-push, xem docs/godot-g1.md).

Quy uoc event (tu Map JSON):
  NPC     -> {kind:"npc", id, name, tile, greet, hint}
  Hotspot -> {kind:"hotspot", id, name, tile, best_frame, material, amount}
  Craft   -> {kind:"craft", name, tile, recipe}
  Door    -> {kind:"door", name, tile, to_map}
"""
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]  # ~/workspace/pho-xo-bo
MV = ROOT / "src/nadia/www/data"
GODOT = ROOT / "src/godot"

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

DOORS = {1: 2, 2: 1}  # Map001 <-> Map002 (event "Cửa ra..." / "Cửa về...")
START = {"map": 1, "x": 4, "y": 5}  # System.json startMapId/startX/startY


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
                           "to_map": DOORS[map_id]})
        else:
            raise ValueError(f"{tag}: event chua biet cach port: {name!r}")

    return {
        "id": map_id,
        "name": atlas["mapName"],
        "width": 12, "height": 9,
        "tile_w": 64, "tile_h": 32,
        "atlas_png": f"res://tiles/atlas-map{tag[3:]}.png",
        "atlas_tiles": atlas["tiles"],  # id(str) -> {name,x,y,w,h,layer}
        "layers": layers,
        "events": events,
    }


def main() -> None:
    out = {"start": START, "maps": [convert(1), convert(2)]}
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
