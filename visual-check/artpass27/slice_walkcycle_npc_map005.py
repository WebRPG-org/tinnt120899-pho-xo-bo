#!/usr/bin/env python3
"""Artpass 27 — slice the 6-figure NPC walk-cycle sheets into transparent frames.

Re-runnable: python3 slice_walkcycle_npc_map005.py
Inputs : visual-check/artpass27/walkcycle-sheet-{thaygiao,sinhvienlamthem}.png (2736x912)
Outputs: src/godot/art/walk_thaygiao_f0.png .. f5.png (height 208px, RGBA)
         src/godot/art/walk_sinhvienlamthem_f0.png .. f5.png (height 208px, RGBA)
         + walkcycle-check-magenta-{thaygiao,sinhvienlamthem}.png (6 frames on
           magenta, for eye check)

NPC id "sinh-vien-lam-them" -> frame prefix walk_sinhvienlamthem_ (hyphens
dropped, per the test rule). Standing image stays char_sinhvien.png.

Method — same as artpass26 slice_walkcycle_npc_map004.py:
  1. Split sheet at midpoints of empty column gaps (column projection),
     NOT equal 1/6 slices.
  2. Content bbox per slice = pixels NOT near-white (min(R,G,B)>=235 AND
     max-min<=18). Crop to bbox (+4px padding).
  3. White -> transparent by flood fill from the slice border through
     near-white pixels only, so enclosed white (inside sneakers) stays
     opaque. Alpha feathered with Gaussian blur radius 1.5.
  4. Resize keeping aspect ratio to height 208 (matches char_*.png).
  5. Normalise: all frames same canvas width, figure centred horizontally
     by bbox so the character does not slide sideways in-game.
"""
import os
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
HERE = os.path.join(BASE, "visual-check/artpass27")
OUT_DIR = os.path.join(BASE, "src/godot/art")
TARGET_H = 208
WHITE_MIN = 235
WHITE_SPREAD = 18
PAD = 4
NPCS = ["thaygiao", "sinhvienlamthem"]


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


def find_figure_regions(arr):
    col_content = (~near_white(arr)).any(axis=0)
    runs = []
    x = 0
    W = arr.shape[1]
    while x < W:
        if col_content[x]:
            x0 = x
            while x < W and col_content[x]:
                x += 1
            runs.append((x0, x))
        else:
            x += 1
    # Artpass27 fix: drop hairline runs (<20px wide) BEFORE the count check —
    # isolated grey specks in the white background (e.g. sinhvienlamthem
    # cols 536, 2297-2298: 1-3 px each, RGB ~193-230). Real figures are
    # 360-460px wide.
    runs = [r for r in runs if r[1] - r[0] >= 20]
    if len(runs) != 6:
        raise ValueError(f"expected 6 figure column-runs, found {len(runs)}: {runs}")
    regions = []
    for i, (x0, x1) in enumerate(runs):
        left = 0 if i == 0 else (runs[i - 1][1] + x0) // 2
        right = W if i == 5 else (x1 + runs[i + 1][0]) // 2
        regions.append((left, right))
    return runs, regions


def process_slice(img_arr, idx):
    white = near_white(img_arr)
    content = ~white
    ys, xs = np.where(content)
    if len(xs) == 0:
        raise ValueError(f"slice {idx}: no content found")
    y0, y1 = max(0, ys.min() - PAD), min(img_arr.shape[0], ys.max() + PAD + 1)
    x0, x1 = max(0, xs.min() - PAD), min(img_arr.shape[1], xs.max() + PAD + 1)
    crop = img_arr[y0:y1, x0:x1]
    bg = flood_background(near_white(crop))
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    alpha_img = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(1.5))
    out = Image.fromarray(crop, "RGB").convert("RGBA")
    out.putalpha(alpha_img)
    w, h = out.size
    nw = max(1, round(w * TARGET_H / h))
    out = out.resize((nw, TARGET_H), Image.LANCZOS)
    return out, (x0, y0, x1, y1)


def main():
    for name in NPCS:
        sheet_path = os.path.join(HERE, f"walkcycle-sheet-{name}.png")
        sheet = Image.open(sheet_path).convert("RGB")
        W, H = sheet.size
        print(f"== {name}: sheet {W}x{H} corners "
              f"{sheet.getpixel((0, 0))} {sheet.getpixel((W-1, 0))}")
        arr = np.asarray(sheet)
        runs, regions = find_figure_regions(arr)
        print(f"  figure column-runs: {runs}")
        frames = []
        for i, (rx0, rx1) in enumerate(regions):
            frame, bbox = process_slice(arr[:, rx0:rx1], i)
            frames.append(frame)
            print(f"  f{i}: region x={rx0}..{rx1} bbox={bbox} -> "
                  f"{frame.size[0]}x{frame.size[1]}")
        cw = max(f.width for f in frames)
        saved = []
        for i, f in enumerate(frames):
            canvas = Image.new("RGBA", (cw, TARGET_H), (0, 0, 0, 0))
            canvas.paste(f, ((cw - f.width) // 2, 0), f)
            path = os.path.join(OUT_DIR, f"walk_{name}_f{i}.png")
            canvas.save(path)
            saved.append(canvas)
            print(f"  f{i}: saved {cw}x{TARGET_H}  {path}")
        # Magenta check strip: 6 frames on magenta, no gaps.
        strip = Image.new("RGBA", (cw * 6, TARGET_H), (255, 0, 255, 255))
        for i, f in enumerate(saved):
            strip.paste(f, (i * cw, 0), f)
        check = os.path.join(HERE, f"walkcycle-check-magenta-{name}.png")
        strip.save(check)
        print(f"  check strip saved: {check}")
    print("done.")


if __name__ == "__main__":
    main()
