#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Nhúng asset nhị phân (atlas PNG + ảnh hệ thống MV) thành base64 trong 1 file
JS text duy nhất: src/nadia/www/js/pxb-embedded.js

VÌ SAO CẦN FILE NÀY
-------------------
- GitHub snapshot-push chỉ đẩy được file text UTF-8, KHÔNG đẩy được PNG nhị
  phân. Atlas PNG (img/tilesets/atlas-map00X.png) vì vậy chưa bao giờ lên
  được GitHub, dù đã nằm local — game deploy lên Pages sẽ vẽ map trắng.
- RPG Maker MV còn đòi 9 file data/*.json (Skills, Weapons, Armors, Enemies,
  Troops, States, Animations, Tilesets, CommonEvents) và ảnh hệ thống
  img/system/*.png (Window, IconSet, Balloon, Shadow1/2, Damage, States,
  Weapons1-3, ButtonSet). Thiếu data JSON -> Scene_Boot kẹt mãi ở màn hình
  loading (DataManager.isDatabaseLoaded() luôn false, 404 không throw).
  Thiếu ảnh hệ thống -> không crash (Bitmap._onError chỉ đánh dấu lỗi) nhưng
  cửa sổ/menu vẽ trắng, không có khung.
- File này giải quyết cả 2 nhóm bằng text: atlas thật (base64 từ PNG đã đóng)
  + ảnh hệ thống placeholder vẽ bằng PIL (đủ để boot + mở menu, chưa phải
  art thật). Hook ImageManager.loadBitmap để MV load từ data URI thay vì
  file, có cache; đường nào không có trong bảng nhúng thì rơi về load file
  gốc như cũ.

CHẠY LẠI KHI: atlas PNG đổi (đóng atlas mới) hoặc muốn đổi ảnh placeholder.
  python3 tools/tiles/embed_assets.py
  node --check src/nadia/www/js/pxb-embedded.js
"""
import base64
import io
import json
import pathlib

from PIL import Image, ImageDraw

REPO = pathlib.Path(__file__).resolve().parents[2]
WWW = REPO / "src" / "nadia" / "www"
OUT = WWW / "js" / "pxb-embedded.js"

# (key MV "folder+filename", nguồn) — key phải khớp đúng chuỗi MV truyền
# vào ImageManager.loadBitmap(folder, filename): folder kết thúc bằng "/".
SYSTEM_PLACEHOLDERS = {
    # Windowskin MV: 192x192. Nền cửa sổ + khung. Placeholder: nền xanh đậm
    # hơi trong + viền sáng — đủ để cửa sổ/menu đọc được, chưa phải art thật.
    "img/system/Window": ("windowskin", (192, 192)),
    "img/system/IconSet": ("transparent", (512, 512)),
    "img/system/Balloon": ("transparent", (384, 96)),
    "img/system/Shadow1": ("transparent", (96, 48)),
    "img/system/Shadow2": ("transparent", (96, 48)),
    "img/system/Damage": ("transparent", (320, 160)),
    "img/system/States": ("transparent", (96, 96)),
    "img/system/Weapons1": ("transparent", (96, 96)),
    "img/system/Weapons2": ("transparent", (96, 96)),
    "img/system/Weapons3": ("transparent", (96, 96)),
    "img/system/ButtonSet": ("transparent", (144, 96)),
}


def png_bytes(kind, size):
    """Vẽ PNG placeholder bằng PIL, trả bytes PNG."""
    w, h = size
    if kind == "transparent":
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    elif kind == "windowskin":
        img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        # Nền cửa sổ: xanh đậm, alpha 220 (vùng 128x128 góc trên-trái MV dùng
        # làm nền; tô toàn ảnh cho đơn giản — khung và nền cùng tông).
        d.rectangle([0, 0, w - 1, h - 1], fill=(24, 42, 78, 220))
        # Viền sáng 3px + đường gân mờ ngang để cửa sổ không phẳng lì.
        d.rectangle([0, 0, w - 1, h - 1], outline=(150, 180, 220, 255), width=3)
        for y in range(16, h, 32):
            d.line([(8, y), (w - 9, y)], fill=(255, 255, 255, 14), width=1)
    else:  # pragma: no cover - không có kind khác
        raise ValueError(kind)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def b64_png(data: bytes) -> str:
    return "data:image/png;base64," + base64.b64encode(data).decode("ascii")


def main():
    embedded = {}
    # 1. Atlas thật — base64 từ PNG đã đóng (tools/tiles/build_atlas.py).
    for name in ("atlas-map001", "atlas-map002"):
        png = WWW / "img" / "tilesets" / (name + ".png")
        if not png.exists():
            raise SystemExit("thieu atlas PNG: %s (chay build_atlas.py truoc)" % png)
        embedded["img/tilesets/" + name] = b64_png(png.read_bytes())
    # 2. Ảnh hệ thống placeholder.
    for key, (kind, size) in SYSTEM_PLACEHOLDERS.items():
        embedded[key] = b64_png(png_bytes(kind, size))

    js = []
    js.append("// Phố Xô Bồ — asset nhúng base64 (xem tools/tiles/embed_assets.py).")
    js.append("// Sinh tự động, KHÔNG sửa tay — chạy lại script khi atlas đổi.")
    js.append("// Hook ImageManager.loadBitmap: đường nào có trong bảng này thì")
    js.append("// load từ data URI (đẩy được qua snapshot-push dạng text);")
    js.append("// đường nào không có thì rơi về load file gốc như cũ.")
    js.append("\"use strict\";")
    js.append("window.PXB_EMBEDDED = " + json.dumps(embedded, indent=0) + ";")
    js.append("""(function () {
  if (typeof ImageManager === "undefined" || !ImageManager) return;
  if (typeof Bitmap === "undefined" || !Bitmap.load) return;
  var _cache = {};
  var _loadBitmap = ImageManager.loadBitmap;
  ImageManager.loadBitmap = function (folder, filename, hue, smooth) {
    if (filename) {
      var key = folder + filename;
      var dataUrl = window.PXB_EMBEDDED[key];
      if (dataUrl) {
        if (!_cache[key]) {
          var b = Bitmap.load(dataUrl);
          b.smooth = smooth;
          _cache[key] = b;
        }
        return _cache[key];
      }
    }
    return _loadBitmap.call(this, folder, filename, hue, smooth);
  };
})();""")
    OUT.write_text("\n".join(js) + "\n", encoding="utf-8")
    total = sum(len(v) for v in embedded.values())
    print("wrote %s (%d assets, ~%d KB base64)" % (OUT, len(embedded), total // 1024))


if __name__ == "__main__":
    main()
