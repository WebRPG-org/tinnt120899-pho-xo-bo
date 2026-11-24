#!/usr/bin/env python3
"""Artpass 30 — slice the 6-figure NPC walk-cycle sheets into transparent frames.

Re-runnable: python3 slice_walkcycle_npc_map007.py
Inputs : visual-check/artpass30/walkcycle-sheet-{cudancaocap,baovechungcu}.png
Outputs: src/godot/art/walk_cudancaocap_f0.png .. f5.png (height 208px, RGBA)
         src/godot/art/walk_baovechungcu_f0.png .. f5.png (height 208px, RGBA)
         + walkcycle-check-magenta-{cudancaocap,baovechungcu}.png (6 frames on
           magenta, for eye check)

NPC ids "nhan-vien-van-phong" / "thuc-tap-sinh" -> frame prefixes walk_cudancaocap_ /
walk_baovechungcu_ (hyphens dropped, per the test rule). Standing images stay
char_cudancaocap.png / char_baovechungcu.png.

Method — adapted from artpass29 slice_walkcycle_npc_map007.py:
  1. Split the sheet into figures by CONNECTED COMPONENTS of the non-white
     mask (scipy.ndimage.label), NOT by column projection.
     Artpass28 lesson: column projection merges figures when one figure's
     raised arm overlaps the next figure in x — cudanchungcu fig1's raised
     fist (x~460-510) overlaps fig2's hair (x~480+) in the x-projection
     even though the two figures are disjoint in 2D. Column runs found
     only 5 runs (fig1+fig2 merged into one 897px run).
  2. Drop components whose bbox width is <MIN_FIG_W BEFORE the count check
     (artpass27 lesson: isolated 1px grey specks in the white background;
     artpass29: nhanvienvanphong sheet had two 24-26px dark specks between
     figures, so MIN_FIG_W raised 20 -> 100; real figures are 368-421px wide).
  3. Per figure: mask out all other components (set to white), then
     content bbox = pixels NOT near-white (min(R,G,B)>=235 AND
     max-min<=18). Crop to bbox (+4px padding).
  4. White -> transparent by flood fill from the slice border through
     near-white pixels only, so enclosed white stays opaque. Alpha
     feathered with Gaussian blur radius 1.5.
  5. Resize keeping aspect ratio to height 208 (matches char_*.png).
  6. Normalise: all frames same canvas width, figure centred horizontally
     by bbox so the character does not slide sideways in-game.
"""
import os
from collections import deque

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
HERE = os.path.join(BASE, "visual-check/artpass30")
OUT_DIR = os.path.join(BASE, "src/godot/art")
TARGET_H = 208
WHITE_MIN = 235
WHITE_SPREAD = 18
PAD = 4
MIN_FIG_W = 100
NPCS = ["cudancaocap", "baovechungcu"]


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


def find_figures(arr):
    """Return list of (component_mask, bbox) sorted left-to-right.

    Component = 4-connected run of non-white pixels. Specks narrower than
    MIN_FIG_W are dropped BEFORE the count check (artpass27 lesson).
    """
    mask = ~near_white(arr)
    lab, n = ndimage.label(mask)
    figs = []
    for i in range(1, n + 1):
        ys, xs = np.where(lab == i)
        x0, x1 = int(xs.min()), int(xs.max()) + 1
        y0, y1 = int(ys.min()), int(ys.max()) + 1
        if x1 - x0 < MIN_FIG_W:
            continue
        figs.append(((lab == i), (x0, y0, x1, y1)))
    figs.sort(key=lambda f: f[1][0])
    if len(figs) != 6:
        raise ValueError(
            f"expected 6 figures, found {len(figs)}: "
            f"{[f[1] for f in figs]}")
    return figs


def process_figure(img_arr, comp_mask, bbox, idx):
    # Keep only this figure's pixels; everything else becomes white.
    work = np.where(comp_mask[:, :, None], img_arr,
                    np.full_like(img_arr, 255))
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - PAD)
    y0 = max(0, y0 - PAD)
    x1 = min(img_arr.shape[1], x1 + PAD)
    y1 = min(img_arr.shape[0], y1 + PAD)
    crop = work[y0:y1, x0:x1]
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
        figs = find_figures(arr)
        print(f"  figure bboxes: {[f[1] for f in figs]}")
        frames = []
        for i, (comp_mask, bbox) in enumerate(figs):
            frame, cbbox = process_figure(arr, comp_mask, bbox, i)
            frames.append(frame)
            print(f"  f{i}: bbox={bbox} crop={cbbox} -> "
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
