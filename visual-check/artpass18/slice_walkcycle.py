#!/usr/bin/env python3
"""Artpass 18 — slice the 6-figure walk-cycle sheet into transparent frames.

Re-runnable: python3 slice_walkcycle.py
Input : visual-check/artpass18/media-generation-walkcycle-sheet-v1-*.png (2736x912)
Output: src/godot/art/walk_player_f0.png .. f5.png (height 208px, RGBA)

Method (same spirit as artpass2):
  1. Split sheet into 6 equal vertical slices.
  2. Content bbox per slice = pixels that are NOT near-white background.
     Near-white = min(R,G,B) >= 235 AND (max-min) <= 18 (true white/grey;
     skin is warm so it never matches, shoe white is enclosed by outline).
  3. White -> transparent by flood fill from the slice border through
     near-white pixels only, so enclosed white (inside the sneakers) stays
     opaque. Alpha feathered with a small Gaussian blur (radius 1.5).
  4. Crop to bbox (+4px padding), resize keeping aspect ratio to height 208
     (matches char_player.png, 106x208).
"""
import glob
import os
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
SHEET = sorted(glob.glob(os.path.join(BASE, "visual-check/artpass18",
                                      "media-generation-walkcycle-sheet-v1-*.png")))
assert SHEET, "sheet not found"
SHEET = SHEET[0]
OUT_DIR = os.path.join(BASE, "src/godot/art")
TARGET_H = 208
WHITE_MIN = 235      # min channel for "background white"
WHITE_SPREAD = 18    # max-min for near-grey white
PAD = 4


def near_white(arr):
    """Boolean mask of background-white pixels (H, W)."""
    mn = arr.min(axis=2)
    mx = arr.max(axis=2)
    return (mn >= WHITE_MIN) & ((mx - mn) <= WHITE_SPREAD)


def flood_background(white_mask):
    """Pixels reachable from the border walking only on white pixels."""
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
    """Split the sheet at the midpoints of empty column gaps between figures.

    Equal 1/6 slices cut hands that reach the slice edge and let a neighbour's
    hair bleed in; column projection finds the real white gaps instead.
    Returns a list of (x0, x1) column ranges, one per figure.
    """
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
    # Alpha: background (flood-filled white) -> 0, everything else -> 255,
    # then feather the edge with a small blur.
    bg = flood_background(near_white(crop))
    alpha = np.where(bg, 0, 255).astype(np.uint8)
    alpha_img = Image.fromarray(alpha, "L").filter(ImageFilter.GaussianBlur(1.5))
    out = Image.fromarray(crop, "RGB").convert("RGBA")
    out.putalpha(alpha_img)
    # Resize keeping aspect ratio to TARGET_H.
    w, h = out.size
    nw = max(1, round(w * TARGET_H / h))
    out = out.resize((nw, TARGET_H), Image.LANCZOS)
    return out, (x0, y0, x1, y1)


def main():
    sheet = Image.open(SHEET).convert("RGB")
    W, H = sheet.size
    print(f"sheet: {SHEET}\n  size={W}x{H}")
    print(f"  corner pixels: {sheet.getpixel((0, 0))} {sheet.getpixel((W-1, 0))} "
          f"{sheet.getpixel((0, H-1))} {sheet.getpixel((W-1, H-1))}")
    arr = np.asarray(sheet)
    runs, regions = find_figure_regions(arr)
    print(f"  figure column-runs: {runs}")
    print(f"  split regions: {regions}")
    frames = []
    for i, (rx0, rx1) in enumerate(regions):
        frame, bbox = process_slice(arr[:, rx0:rx1], i)
        frames.append(frame)
        print(f"f{i}: region x={rx0}..{rx1} bbox={bbox} -> {frame.size[0]}x{frame.size[1]}")
    # Normalise: same canvas width for all frames, figure centred horizontally
    # so the character does not slide sideways between frames in-game.
    cw = max(f.width for f in frames)
    for i, f in enumerate(frames):
        canvas = Image.new("RGBA", (cw, TARGET_H), (0, 0, 0, 0))
        canvas.paste(f, ((cw - f.width) // 2, 0), f)
        path = os.path.join(OUT_DIR, f"walk_player_f{i}.png")
        canvas.save(path)
        print(f"f{i}: saved {cw}x{TARGET_H}  {path}")
    print("done.")


if __name__ == "__main__":
    main()
