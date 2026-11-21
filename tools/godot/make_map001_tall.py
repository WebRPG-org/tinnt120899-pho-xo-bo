#!/usr/bin/env python3
"""Vong 16 (22/11): anh nen Map001 moi — nha ong cao phu kin 9:16.
- Nguon: anh gen media-generation-bg-map001-tall-*.webp (1152x2048)
  -> art/bg_map001_tall.png (ngay).
- Ban dem: suy ra tu ban ngay bang PIL (khong gen anh dem rieng):
  toi + lanh toan cuc, giu vung sang am o pixel am sang (cua so/den
  long) de dem van co diem sang — tuong tu cach bg_map001_night.png
  cu co cua so vang.
- Ghi lai mean do sang ngay/dem de test kiem chung.
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "src" / "godot" / "art"
VC = ROOT / "visual-check" / "artpass16"
VC.mkdir(parents=True, exist_ok=True)

keep = VC / "bg-map001-tall-source.webp"
srcs = sorted(ART.glob("media-generation-bg-map001-tall-*.webp"))
if srcs:
    # Luu ban goc ra visual-check (ngoai src/godot de Godot khong import).
    src = srcs[0]
    print("nguon:", src.name)
    if not keep.exists():
        keep.write_bytes(src.read_bytes())
    src.unlink()
assert keep.exists(), "khong tim thay anh goc bg-map001-tall"
print("ban goc giu tai:", keep)

day = Image.open(keep).convert("RGB")
# Thu ve 864x1536 (0.75x): camera chi thay ~576 don vi the gioi
# ngang (zoom 1.25) nen anh 1152 van du thua 2x — thu nho giam pck
# ma van net (van >1.3x oversampling), tranh pck phong tu ~6.5MB
# len ~11MB neu giu nguyen 1152x2048.
day = day.resize((864, 1536), Image.LANCZOS)
print("kich co ngay:", day.size)
day.save(ART / "bg_map001_tall.png")
print("da ghi:", ART / "bg_map001_tall.png")

a = np.asarray(day).astype(np.float32)
# Pixel am sang (cua so/den long): R cao + am hon B ro.
warm = (a[:, :, 0] > 150) & ((a[:, :, 0] - a[:, :, 2]) > 40)
night = np.empty_like(a)
# Nen thuong: toi + lanh.
night[:, :, 0] = a[:, :, 0] * 0.38
night[:, :, 1] = a[:, :, 1] * 0.44
night[:, :, 2] = a[:, :, 2] * 0.58
# Cua so/den long: giu am, chi toi nhe.
night[:, :, 0][warm] = a[:, :, 0][warm] * 0.85
night[:, :, 1][warm] = a[:, :, 1][warm] * 0.70
night[:, :, 2][warm] = a[:, :, 2][warm] * 0.42
Image.fromarray(np.clip(night, 0, 255).astype(np.uint8)).save(
    ART / "bg_map001_tall_night.png")
print("da ghi:", ART / "bg_map001_tall_night.png")

def mean(im):
    return float(np.asarray(im).astype(np.float32).mean())

print("mean ngay: %.1f" % mean(day))
print("mean dem: %.1f" % mean(Image.open(ART / "bg_map001_tall_night.png")))
print("pixel am sang giu lai: %d" % int(warm.sum()))
