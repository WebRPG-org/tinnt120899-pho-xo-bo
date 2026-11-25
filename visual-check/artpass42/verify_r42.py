#!/usr/bin/env python3
"""Artpass 42 — verification of the 3 stall sprites (banhmi / giavi / dokho).

Checks on the FINAL 64x96 RGBA files in src/godot/art/:
  - size 64x96 RGBA, y0-33 fully transparent (0 opaque px)
  - posts at y=56: opaque clusters inside x2-6 and x58-62 only
  - exactly 1 connected alpha component (no stray fragments)
  - near-white pixels (min(R,G,B)>=235 among opaque) counted per band,
    saved as debug-white image (near-white -> red) for eyeballing
"""
import os

import numpy as np
from PIL import Image
from scipy import ndimage

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
HERE = os.path.join(BASE, "visual-check/artpass42")
OUT_DIR = os.path.join(BASE, "src/godot/art")
NAMES = ["stall_banhmi", "stall_giavi", "stall_dokho"]
BANDS = {"sign 0-33": (0, 34), "awning 34-52": (34, 53), "gap 52-60": (52, 61),
         "goods 60-76": (60, 77), "counter 76-96": (76, 96)}


def clusters(row):
    """Contiguous opaque x-runs on one row."""
    xs = np.where(row > 0)[0]
    if len(xs) == 0:
        return []
    out, start, prev = [], xs[0], xs[0]
    for x in xs[1:]:
        if x == prev + 1:
            prev = x
        else:
            out.append((int(start), int(prev)))
            start, prev = x, x
    out.append((int(start), int(prev)))
    return out


for name in NAMES:
    path = os.path.join(OUT_DIR, f"{name}.png")
    im = Image.open(path)
    arr = np.asarray(im)
    a = arr[:, :, 3]
    rgb = arr[:, :, :3].astype(int)
    print(f"== {name}: {im.size} {im.mode} {os.path.getsize(path)} bytes")
    print(f"   opaque px y0-33 (must be 0): {int((a[0:34] > 0).sum())}")
    print(f"   row y=56 opaque clusters (want x2-6 + x58-62): {clusters(a[56])}")
    print(f"   row y=70 opaque clusters: {clusters(a[70])}")
    lab, n = ndimage.label(a > 0)
    sizes = sorted(((lab == i).sum() for i in range(1, n + 1)), reverse=True)
    print(f"   alpha components: {n}, sizes={sizes[:5]}")
    # Near-white pixels among opaque.
    near_white = (a > 0) & (rgb.min(axis=2) >= 235)
    print(f"   near-white px total: {int(near_white.sum())}")
    for label, (ya, yb) in BANDS.items():
        print(f"     {label}: {int(near_white[ya:yb].sum())}")
    # Debug-white image: near-white -> red, rest as on magenta.
    dbg = Image.new("RGBA", im.size, (255, 0, 255, 255))
    dbg.paste(im, (0, 0), im)
    darr = np.asarray(dbg).copy()
    darr[near_white] = [255, 0, 0, 255]
    Image.fromarray(darr, "RGBA").save(os.path.join(HERE, f"debug-white-{name}.png"))
    print(f"   saved debug-white-{name}.png")
print("done.")
