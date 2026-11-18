#!/usr/bin/env python3
# Đóng atlas theo khu cho Phố Xô Bồ (đường Nadia, docs/tileset-plan.md §4).
#
# Đọc 1 file selection JSON (tools/tiles/select-mapNNN.json) rồi:
#   - tải tile nguồn (Kenney PNG lẻ / ô trong sheet SBS 128x64),
#   - SBS: cắt ô 128x64 trong sheet + mặt nạ hình thoi (nền đen -> trong
#     suốt; KHÔNG dùng exact-black toàn cục vì ruột tile tối cũng có
#     pixel gần đen),
#   - tint PROVISIONAL theo palette docs/art-style.md §2 (nhân kênh RGB),
#   - downscale footprint về 64 px ngang bằng NEAREST (giữ pixel sắc),
#   - xếp vào atlas PNG: lưới cell 64x64, tile neo đáy cell,
#   - ghi mapping JSON: code -> {source, x, y, w, h, tint, layer}.
#
# Atlas PNG là file nhị phân — KHÔNG push qua snapshot (chỉ nhận UTF-8).
# Chạy script ở máy làm việc, rồi đưa PNG vào repo bằng git push / upload
# web (tileset-plan.md §5). Mapping JSON là text nên push bình thường.
#
# Cách chạy:
#   python3 tools/tiles/build_atlas.py --selection tools/tiles/select-map001.json \
#       --src-dir /tmp/pxb-tiles/extracted --out-png /tmp/pxb-tiles/atlas/atlas-map001.png \
#       --out-json src/nadia/www/data/atlas-map001.json
#
# Yêu cầu: Pillow (PIL). Không cần mạng, không cần Unity/dotent.
"""Đóng atlas tile theo khu (Kenney/SBS -> atlas 64x32 + mapping JSON)."""
import argparse
import hashlib
import json
import sys
from pathlib import Path

from PIL import Image

TARGET_W = 64  # footprint ngang chuẩn game (architecture-nadia §5)


def diamond_mask(w, h):
    """Mặt nạ hình thoi 2:1 trong ô w*h (đỉnh chạm 4 cạnh giữa ô)."""
    mask = Image.new("L", (w, h), 0)
    px = mask.load()
    cx, cy = w / 2.0, h / 2.0
    for y in range(h):
        for x in range(w):
            if abs(x + 0.5 - cx) / (w / 2.0) + abs(y + 0.5 - cy) / (h / 2.0) <= 1.0:
                px[x, y] = 255
    return mask


def load_tile(src_dir, tile):
    """Tải 1 tile nguồn -> ảnh RGBA (chưa tint, chưa scale)."""
    kind = tile["kind"]
    if kind == "file":
        path = src_dir / tile["file"]
        if not path.is_file():
            raise FileNotFoundError(f"tile code {tile['code']}: không có {path}")
        return Image.open(path).convert("RGBA"), str(tile["file"])
    if kind == "sbs-cell":
        path = src_dir / tile["sheet"]
        if not path.is_file():
            raise FileNotFoundError(f"tile code {tile['code']}: không có {path}")
        sheet = Image.open(path).convert("RGBA")
        cw, ch = tile["cellSize"]
        col, row = tile["cell"]
        cell = sheet.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
        # Nền sheet là đen đặc: chỉ giữ pixel trong hình thoi, ngoài -> trong suốt.
        cell.putalpha(diamond_mask(cw, ch))
        return cell, f"{tile['sheet']} cell=({col},{row})"
    raise ValueError(f"tile code {tile.get('code')}: kind lạ {kind!r}")


def apply_tint(img, tint):
    """Nhân kênh RGB theo tint [r, g, b] (PROVISIONAL, art-style §2)."""
    if not tint or tint == [1.0, 1.0, 1.0]:
        return img
    r, g, b, a = img.split()
    r = r.point(lambda v: max(0, min(255, int(v * tint[0]))))
    g = g.point(lambda v: max(0, min(255, int(v * tint[1]))))
    b = b.point(lambda v: max(0, min(255, int(v * tint[2]))))
    return Image.merge("RGBA", (r, g, b, a))


def main():
    ap = argparse.ArgumentParser(description="Đóng atlas tile theo khu.")
    ap.add_argument("--selection", required=True)
    ap.add_argument("--src-dir", required=True,
                    help="Thư mục chứa tile đã giải nén (KHÔNG nằm trong repo).")
    ap.add_argument("--out-png", required=True)
    ap.add_argument("--out-json", required=True)
    args = ap.parse_args()

    sel = json.loads(Path(args.selection).read_text(encoding="utf-8"))
    src_dir = Path(args.src_dir)
    tiles = sel["tiles"]
    cols = sel.get("cols", 8)
    cell_w = sel["cellW"]
    cell_h = sel["cellH"]
    rows = (len(tiles) + cols - 1) // cols
    atlas = Image.new("RGBA", (cols * cell_w, rows * cell_h), (0, 0, 0, 0))

    mapping = {
        "map": sel["map"],
        "mapName": sel["mapName"],
        "atlasPng": sel["atlasPng"],
        "tileW": sel["tileW"],
        "tileH": sel["tileH"],
        "cellW": cell_w,
        "cellH": cell_h,
        "cols": cols,
        # Mã tile trong Map data (layer 0/1) là ATLAS CODE (1..N), KHÔNG phải
        # tile ID MV (B=0/C=256/A5=1536...). PXB_Isometric v3 (atlas mode,
        # chưa viết) mới đọc được; v2 hiện tại đọc theo Tilemap MV nên
        # chưa vẽ được các code này (xem docs/tileset-plan.md §6).
        "scheme": "atlas-code",
        "tiles": {},
    }
    seen_codes = set()
    for i, tile in enumerate(tiles):
        code = tile["code"]
        if code in seen_codes:
            raise ValueError(f"trùng code {code} trong selection")
        seen_codes.add(code)
        img, source = load_tile(src_dir, tile)
        img = apply_tint(img, tile.get("tint"))
        new_w = TARGET_W
        new_h = max(1, round(img.height * TARGET_W / img.width))
        if new_h > cell_h:
            raise ValueError(
                f"tile code {code} cao {new_h}px sau scale, vượt cell {cell_h}px")
        img = img.resize((new_w, new_h), Image.NEAREST)
        row, col = divmod(i, cols)
        x, y = col * cell_w, row * cell_h + (cell_h - new_h)
        atlas.paste(img, (x, y), img)
        mapping["tiles"][str(code)] = {
            "name": tile["name"],
            "source": source,
            "x": x, "y": y, "w": new_w, "h": new_h,
            "tint": tile.get("tint"),
            "layer": tile.get("layer", 0),
        }
        print(f"  code {code} {tile['name']}: {source} -> "
              f"atlas ({x},{y}) {new_w}x{new_h}")

    out_png = Path(args.out_png)
    out_png.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(out_png)
    sha = hashlib.sha256(out_png.read_bytes()).hexdigest()
    out_json = Path(args.out_json)
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_json.write_text(json.dumps(mapping, ensure_ascii=False, indent=2)
                        + "\n", encoding="utf-8")
    print(f"atlas: {out_png} {atlas.size} SHA-256 {sha}")
    print(f"mapping: {out_json} ({len(tiles)} tile)")


if __name__ == "__main__":
    sys.exit(main())
