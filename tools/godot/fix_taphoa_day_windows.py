#!/usr/bin/env python3
"""Vong 8 — Sua cua so/cua TAP HOA trong anh ngay bg_map001.png.

Loi live 16:52 20/11: cua TAP HOA o khung Sang van sang cam nhu
den buoi toi. Goc: anh ngay ve san cua/cua so TAP HOA bang kinh
cam sang (do pixel: o cua tren R-B +104..+142, cua so +48..+147)
trong khi cua PHO BO (rem xanh) / CA PHE (rem trang) khong sang.
Anh dem rieng (bg_map001_night.png) moi la noi cua sang — anh ngay
phai ve cua TAT (kinh lanh nhu ban ngay).

Sua: chi ha nhiet (cool) cac pixel kinh cam sang trong 2 rect da do,
giu nguyen hoa tiet ke caro/rem + khung go:
- O cua TAP HOA: rect (802,396,878,464), pixel R>145 va R-B>55.
- Cua so TAP HOA: rect (928,402,1052,538), pixel R>150 va R-B>70.
Bien doi: giu do sang (luminance), dua sac ve kinh lanh xanh-xam
(target ~ (0.92L, 0.97L, 1.10L)), blend 0.85 (cua) / 0.6 (cua so).

Kiem: do lai R-B trung binh 2 rect truoc/sau; cua < +45, cua so
vung sang < +70. Anh dem KHONG doi.
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "src" / "godot" / "art" / "bg_map001.png"


def avg(im, box):
    r = im.crop(box)
    px = list(r.getdata())
    n = len(px)
    return tuple(sum(c[i] for c in px) // n for i in range(3))


def cool(px, blend):
    r, g, b, a = px
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    tr, tg, tb = lum * 0.92, lum * 0.97, lum * 1.10
    return (
        int(r + (tr - r) * blend),
        int(g + (tg - g) * blend),
        int(b + (tb - b) * blend),
        a,
    )


def main() -> int:
    im = Image.open(ART).convert("RGBA")
    w, h = im.size
    assert (w, h) == (1120, 630), f"kich thuoc anh doi: {(w, h)}"
    px = im.load()
    for name, box, cond_r, cond_warm, blend in [
        ("o cua TAP HOA", (802, 396, 878, 464), 145, 55, 0.85),
        ("cua so TAP HOA", (928, 402, 1052, 538), 150, 70, 0.60),
    ]:
        x0, y0, x1, y1 = box
        before = avg(im, box)
        n = 0
        for y in range(y0, y1):
            for x in range(x0, x1):
                r, g, b, a = px[x, y]
                if r > cond_r and (r - b) > cond_warm:
                    px[x, y] = cool((r, g, b, a), blend)
                    n += 1
        after = avg(im, box)
        print(f"{name}: doi {n} pixel, R-B trung binh {before[0]-before[2]} -> {after[0]-after[2]}")
    # Vung doi chung (khong duoc doi): cua so PHO BO.
    ctrl = avg(im, (140, 400, 225, 530))
    print(f"doi chung cua so PHO BO R-B: {ctrl[0]-ctrl[2]} (phai ~+80..+120 nhu truoc)")
    im.save(ART)
    print("da ghi", ART)
    # Assert nguong kiem live vong 8.
    door = avg(Image.open(ART).convert("RGB"), (802, 396, 878, 464))
    win = avg(Image.open(ART).convert("RGB"), (928, 402, 1052, 538))
    ok = (door[0] - door[2]) < 45 and (win[0] - win[2]) < 70
    print(f"kiem: o cua R-B={door[0]-door[2]} (<45), cua so R-B={win[0]-win[2]} (<70) -> {'OK' if ok else 'FAIL'}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
