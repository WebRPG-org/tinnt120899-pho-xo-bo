#!/usr/bin/env python3
# Điền tile data thật (atlas code) vào Map001/Map002 của Phố Xô Bồ.
#
# Đọc selection JSON (tools/tiles/select-mapNNN.json) + mapping JSON tương
# ứng, rồi điền vào data của MapNNN.json theo công thức MV
#   data[(z * height + y) * width + x]   (rpg_objects.js:5937)
# layer 0 = sàn (ground + xen kẽ + dải đường), layer 1 = biên (tường/sạp).
# Các layer 2-4 giữ 0. Event giữ nguyên tuyệt đối (chỉ đọc tọa độ để
# tránh rải sàn xen kẽ / tường lên ô event).
#
# Mã trong data là ATLAS CODE (xem mapping JSON "scheme"), KHÔNG phải
# tile ID MV — PXB_Isometric v3 (atlas mode, chưa viết) mới đọc được.
# Ghi chú trong Map*.json "note" được cập nhật theo.
#
# Cách chạy:
#   python3 tools/tiles/fill_map_data.py --selection tools/tiles/select-map001.json \
#       --mapping src/nadia/www/data/atlas-map001.json \
#       --map src/nadia/www/data/Map001.json
"""Điền tile data atlas-code vào Map001/Map002 (giữ nguyên event)."""
import argparse
import json
import sys
from pathlib import Path


def fill(selection, mapping, map_path):
    sel = json.loads(Path(selection).read_text(encoding="utf-8"))
    mp = json.loads(Path(mapping).read_text(encoding="utf-8"))
    m = json.loads(Path(map_path).read_text(encoding="utf-8"))
    w, h = m["width"], m["height"]
    data = m["data"]
    assert len(data) == w * h * 6, f"data dài {len(data)}, kỳ vọng {w*h*6}"
    layout = sel["layout"]
    codes = {int(c) for c in mp["tiles"]}
    for code in (layout["ground"], layout.get("alt", {}).get("code"),
                 layout.get("road", {}).get("code")):
        if code is not None and code not in codes:
            raise ValueError(f"layout dùng code {code} không có trong mapping")
    for side, lst in layout["border"].items():
        for code in lst:
            if code not in codes:
                raise ValueError(f"border {side} dùng code {code} "
                                 f"không có trong mapping")

    def idx(x, y, z):
        return (z * h + y) * w + x

    event_cells = {(e["x"], e["y"]) for e in m["events"] if e}
    ground = layout["ground"]
    alt = layout.get("alt")
    road = layout.get("road")
    for y in range(h):
        for x in range(w):
            code = ground
            if alt and (x, y) not in event_cells:
                if eval(alt["rule"], {}, {"x": x, "y": y}):
                    code = alt["code"]
            # Dải đường đi xuyên cả ô event (cửa (5,4) nằm TRÊN đường);
            # sàn xen kẽ thì tránh ô event.
            if road and x == road["col"]:
                code = road["code"]
            data[idx(x, y, 0)] = code
    # Biên: bắc (y=0), tây (x=0), đông (x=w-1), nam (y=h-1) — danh sách
    # rỗng nghĩa là để trống (mặt tiền mở). Mã xoay vòng theo vị trí.
    borders = layout["border"]
    for side, lst in borders.items():
        if not lst:
            continue
        if side == "north":
            cells = [(x, 0) for x in range(w)]
        elif side == "south":
            cells = [(x, h - 1) for x in range(w)]
        elif side == "west":
            cells = [(0, y) for y in range(h)]
        elif side == "east":
            cells = [(w - 1, y) for y in range(h)]
        else:
            raise ValueError(f"border lạ: {side}")
        for i, (x, y) in enumerate(cells):
            if (x, y) in event_cells:
                continue
            data[idx(x, y, 1)] = lst[i % len(lst)]
    m["note"] = (f"Tile data atlas-code ({mp['atlasPng']}): layer 0 sàn + "
                 f"layer 1 biên theo {Path(selection).name}; scheme atlas-code, "
                 f"cần PXB_Isometric v3 (atlas mode) mới vẽ được — v2 chưa đọc.")
    Path(map_path).write_text(json.dumps(m, ensure_ascii=False),
                             encoding="utf-8")
    nz0 = sum(1 for v in data[0:w * h] if v)
    nz1 = sum(1 for v in data[w * h:2 * w * h] if v)
    print(f"{Path(map_path).name}: layer0 {nz0}/{w*h} ô có tile, "
          f"layer1 {nz1}/{w*h} ô có tile, event giữ nguyên "
          f"{sorted(event_cells)}")
    # In lưới layer 0 để kiểm tra bằng mắt trong log.
    print("layer 0:")
    for y in range(h):
        print("  " + " ".join(str(data[idx(x, y, 0)]) for x in range(w)))
    print("layer 1:")
    for y in range(h):
        print("  " + " ".join(str(data[idx(x, y, 1)]) for x in range(w)))


def main():
    ap = argparse.ArgumentParser(description="Điền tile data vào Map JSON.")
    ap.add_argument("--selection", required=True)
    ap.add_argument("--mapping", required=True)
    ap.add_argument("--map", required=True)
    args = ap.parse_args()
    fill(args.selection, args.mapping, args.map)


if __name__ == "__main__":
    sys.exit(main())
