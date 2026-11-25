#!/usr/bin/env python3
"""Artpass 34 — standing refs for Map017 NPCs (Co Ban Banh + Ong Lao Tap The Duc).

Same white->transparent method as artpass32 process_standing_map010.py:
  near-white = min(R,G,B)>=235 AND max-min<=18; flood fill from border
  through near-white only; alpha feathered Gaussian blur r=1.5.
Resize keeping aspect ratio to height 208 (matches char_cotu.png).

Inputs : visual-check/artpass39/media-generation-char-{cobanbanh,onglaotaptheduc}-0-*.webp
Outputs: src/godot/art/char_{cobanbanh,onglaotaptheduc}.png (RGBA, height 208)
         visual-check/artpass39/char_{cobanbanh,onglaotaptheduc}.png (same, for the record)
         + char_{name}-magenta.png (standing on magenta, for eye check)
"""
import glob
import os
from collections import deque

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
HERE = os.path.join(BASE, "visual-check/artpass39")
OUT_DIR = os.path.join(BASE, "src/godot/art")
TARGET_H = 208
WHITE_MIN = 235
WHITE_SPREAD = 18
PAD = 4

NAMES = ["cobanbanh", "onglaotaptheduc"]


def near_white(arr):
    mn = arr.min(axis=2)
    mx = arr.max(axis=2)
    return (mn >= WHITE_MIN) & ((mx - mn) <= WHITE_SPREAD)


def flood_background(white_mask):
    h, w = white_mask.shape
    bg = np.zeros((h, w), dtype=bool)
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if white_mask[y, x] and not bg[y, x]:
                bg[y, x] = True
                q.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if white_mask[y, x] and not bg[y, x]:
                bg[y, x] = True
                q.append((y, x))
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and white_mask[ny, nx] and not bg[ny, nx]:
                bg[ny, nx] = True
                q.append((ny, nx))
    return bg


def main():
    for name in NAMES:
        cands = sorted(glob.glob(os.path.join(
            HERE, f"media-generation-char-{name}-0-*.webp")))
        assert len(cands) == 1, f"{name}: {cands}"
        img = Image.open(cands[0]).convert("RGB")
        arr = np.asarray(img)
        print(f"== {name}: source {img.size} from {os.path.basename(cands[0])}")
        white = near_white(arr)
        ys, xs = np.where(~white)
        y0, y1 = max(0, ys.min() - PAD), min(arr.shape[0], ys.max() + PAD + 1)
        x0, x1 = max(0, xs.min() - PAD), min(arr.shape[1], xs.max() + PAD + 1)
        crop = arr[y0:y1, x0:x1]
        bg = flood_background(near_white(crop))
        alpha = np.where(bg, 0, 255).astype(np.uint8)
        # Artpass34: drop LARGE enclosed near-white regions — background
        # seen through a closed loop (standing gardener: 115 final px
        # triangle between the legs closed by the foot shadow). Neither
        # Map017 NPC wears white, so enclosed near-white is background,
        # not clothing. Size is judged in FINAL-scale px (threshold 100):
        # small enclosed bits (flashlight lens, watering-can handle loop,
        # finger gaps, <= ~55 final px) are kept.
        enclosed = near_white(crop) & ~bg
        lab2, n2 = ndimage.label(enclosed)
        area_scale = (TARGET_H / crop.shape[0]) ** 2
        for i in range(1, n2 + 1):
            m = lab2 == i
            final_px = int(m.sum()) * area_scale
            if final_px >= 100:
                alpha[m] = 0
                print(f"  removed enclosed white {int(m.sum())}px "
                      f"(~{final_px:.0f} final px)")
        alpha_img = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(1.5))
        out = Image.fromarray(crop, "RGB").convert("RGBA")
        out.putalpha(alpha_img)
        w, h = out.size
        nw = max(1, round(w * TARGET_H / h))
        out = out.resize((nw, TARGET_H), Image.LANCZOS)
        for path in (os.path.join(OUT_DIR, f"char_{name}.png"),
                     os.path.join(HERE, f"char_{name}.png")):
            out.save(path)
            print(f"  saved {out.size[0]}x{out.size[1]} RGBA  {path}")
        # Magenta check: standing figure on magenta.
        check = Image.new("RGBA", out.size, (255, 0, 255, 255))
        check.paste(out, (0, 0), out)
        check.save(os.path.join(HERE, f"char-{name}-magenta.png"))
        print(f"  magenta check: {os.path.join(HERE, f'char-{name}-magenta.png')}")
    print("done.")


if __name__ == "__main__":
    main()
