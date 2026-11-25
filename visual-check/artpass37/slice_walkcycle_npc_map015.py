#!/usr/bin/env python3
"""Artpass 34 — slice the 6-figure NPC walk-cycle sheets into transparent frames.

Re-runnable: python3 slice_walkcycle_npc_map011.py
Inputs : visual-check/artpass37/walkcycle-sheet-{quanlypenthouse,cudanpenthouse}.png
Outputs: src/godot/art/walk_quanlypenthouse_f0.png .. f5.png (height 208px, RGBA)
         src/godot/art/walk_cudanpenthouse_f0.png .. f5.png (height 208px, RGBA)
         + walkcycle-check-magenta-{quanlypenthouse,cudanpenthouse}.png (6 frames on
           magenta, for eye check)

NPC ids "quan-gia-dao" / "chu-biet-thu-dao" -> frame prefixes walk_quanlypenthouse_ /
walk_cudanpenthouse_ (hyphens dropped, per the test rule). Standing images stay
char_quanlypenthouse.png / char_cudanpenthouse.png.

Method — adapted from artpass32 slice_walkcycle_npc_map010.py:
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
HERE = os.path.join(BASE, "visual-check/artpass37")
OUT_DIR = os.path.join(BASE, "src/godot/art")
TARGET_H = 208
WHITE_MIN = 235
WHITE_SPREAD = 18
PAD = 4
MIN_FIG_W = 100
# Artpass36 lesson: the butler sheet has a DETACHED ground shadow under
# fig0 (x297-491, y823-843, w=195, h=21) — wide enough to pass MIN_FIG_W
# but only 21px tall, so find_figures counted 7 figures instead of 6.
# Real figures are ~750px tall; drop components shorter than MIN_FIG_H.
# (Connected shadows stay — they are part of the figure component.)
MIN_FIG_H = 100
# Artpass34 lesson: the gardener's wide conical hat (~450px) + sideways
# arms make neighbouring figures touch in 2D, so one component can hold
# two figures (artpass34: one 913px component = fig2+fig3).
# Single figures are <= ~520px wide, so split any component wider than
# MAX_FIG_W at its lowest-density column in the central 40% of its bbox.
MAX_FIG_W = 600
NPCS = ["quanlypenthouse", "cudanpenthouse"]


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


def split_wide_component(comp_mask, bbox):
    """Split a too-wide component into two masks at its lowest-density
    column inside the central 40% of its bbox (artpass37: two figures
    touching via hat brim / sideways arms). Recurses if a half is still
    too wide. Returns list of (mask, bbox)."""
    x0, y0, x1, y1 = bbox
    if x1 - x0 <= MAX_FIG_W:
        return [(comp_mask, bbox)]
    lo = x0 + int(0.3 * (x1 - x0))
    hi = x0 + int(0.7 * (x1 - x0))
    col_counts = comp_mask.sum(axis=0)
    cut = lo + int(np.argmin(col_counts[lo:hi]))
    left = comp_mask.copy()
    left[:, cut:] = False
    right = comp_mask.copy()
    right[:, :cut] = False
    print(f"  split wide component {bbox} at x={cut} "
          f"(col count {int(col_counts[cut])})")
    out = []
    for m in (left, right):
        ys, xs = np.where(m)
        if len(xs) == 0:
            continue
        b = (int(xs.min()), int(ys.min()), int(xs.max()) + 1,
             int(ys.max()) + 1)
        out.extend(split_wide_component(m, b))
    return out


def find_figures(arr):
    """Return list of (component_mask, bbox) sorted left-to-right.

    Component = 4-connected run of non-white pixels. Specks narrower than
    MIN_FIG_W are dropped BEFORE the count check (artpass27 lesson).
    Components wider than MAX_FIG_W are split at their lowest-density
    column (artpass37 lesson: wide hats / sideways arms touch).
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
        if y1 - y0 < MIN_FIG_H:
            continue  # artpass37: flat detached ground shadow / speck
        figs.extend(split_wide_component(lab == i, (x0, y0, x1, y1)))
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
    # Artpass34: drop LARGE enclosed near-white regions — background seen
    # through a closed loop (flashlight cord loop; triangle between legs
    # closed by the foot shadow; arm-torso gap). Neither Map015 NPC wears
    # white, so enclosed near-white is background, not clothing. Size is
    # judged in FINAL-scale px (component px * (208/crop_h)^2, threshold
    # 100): the flashlight lens is only 16-21 final px and is KEPT, while
    # cord loops (253-393), leg triangles (959-995) and arm gaps
    # (117-369) are removed. A raw-px threshold would misfire because the
    # sheet crop (~745px tall) and the standing source (2080px tall) have
    # very different scales.
    enclosed = near_white(crop) & ~bg
    lab2, n2 = ndimage.label(enclosed)
    area_scale = (TARGET_H / crop.shape[0]) ** 2
    for i in range(1, n2 + 1):
        m = lab2 == i
        final_px = int(m.sum()) * area_scale
        if final_px >= 100:
            alpha[m] = 0
            print(f"    f{idx}: removed enclosed white {int(m.sum())}px "
                  f"(~{final_px:.0f} final px)")
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
