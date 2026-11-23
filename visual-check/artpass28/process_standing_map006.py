#!/usr/bin/env python3
"""Artpass 28 — standing refs for Map006 NPCs (Cu Dan Chung Cu + Bac Quan Ly).

Same white->transparent method as artpass27 process_standing_map005.py:
  near-white = min(R,G,B)>=235 AND max-min<=18; flood fill from border
  through near-white only; alpha feathered Gaussian blur r=1.5.
Resize keeping aspect ratio to height 208 (matches char_cotu.png).

Inputs : visual-check/artpass28/media-generation-char-{cudanchungcu,bacquanly}-0.png
Outputs: src/godot/art/char_{cudanchungcu,bacquanly}.png (RGBA, height 208)
         visual-check/artpass28/char_{cudanchungcu,bacquanly}.png (same, for the record)
"""
import os
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
HERE = os.path.join(BASE, "visual-check/artpass28")
OUT_DIR = os.path.join(BASE, "src/godot/art")
TARGET_H = 208
WHITE_MIN = 235
WHITE_SPREAD = 18
PAD = 4

SRC = {
    "cudanchungcu": "media-generation-char-cudanchungcu-0.png",
    "bacquanly": "media-generation-char-bacquanly-0.png",
}


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
    for name, src in SRC.items():
        img = Image.open(os.path.join(HERE, src)).convert("RGB")
        arr = np.asarray(img)
        print(f"== {name}: source {img.size}")
        white = near_white(arr)
        ys, xs = np.where(~white)
        y0, y1 = max(0, ys.min() - PAD), min(arr.shape[0], ys.max() + PAD + 1)
        x0, x1 = max(0, xs.min() - PAD), min(arr.shape[1], xs.max() + PAD + 1)
        crop = arr[y0:y1, x0:x1]
        bg = flood_background(near_white(crop))
        alpha = np.where(bg, 0, 255).astype(np.uint8)
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
    print("done.")


if __name__ == "__main__":
    main()
