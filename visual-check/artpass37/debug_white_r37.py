#!/usr/bin/env python3
"""Artpass 37 — debug: show enclosed-white regions removed by the slice
script for cudanpenthouse frames, and measure largest remaining enclosed
white in the final destination files (both NPCs + standing images).

Replicates slice_walkcycle_npc_map015.process_figure logic per frame and
saves debug-white-walk_cudanpenthouse_f{i}.png with removed regions in red.
"""
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from slice_walkcycle_npc_map015 import (  # noqa: E402
    HERE, OUT_DIR, TARGET_H, find_figures, near_white, flood_background)

BBOXES = {
    # from slice run output
    "quanlypenthouse": [(71, 61, 534, 853), (557, 62, 925, 860),
                        (966, 60, 1380, 860), (1413, 60, 1803, 859),
                        (1837, 59, 2234, 852), (2275, 58, 2659, 862)],
    "cudanpenthouse": [(21, 101, 523, 842), (485, 100, 924, 842),
                       (887, 97, 1356, 843), (1318, 100, 1772, 841),
                       (1758, 99, 2225, 841), (2216, 99, 2667, 840)],
}
PAD = 4


def debug_frame(name, idx, bbox):
    sheet = Image.open(os.path.join(HERE, f"walkcycle-sheet-{name}.png")).convert("RGB")
    arr = np.asarray(sheet)
    figs = find_figures(arr)
    comp_mask, _ = figs[idx]
    work = np.where(comp_mask[:, :, None], arr, np.full_like(arr, 255))
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - PAD); y0 = max(0, y0 - PAD)
    x1 = min(arr.shape[1], x1 + PAD); y1 = min(arr.shape[0], y1 + PAD)
    crop = work[y0:y1, x0:x1]
    bg = flood_background(near_white(crop))
    enclosed = near_white(crop) & ~bg
    lab2, n2 = ndimage.label(enclosed)
    area_scale = (TARGET_H / crop.shape[0]) ** 2
    removed = np.zeros(crop.shape[:2], dtype=bool)
    for i in range(1, n2 + 1):
        m = lab2 == i
        if int(m.sum()) * area_scale >= 100:
            removed |= m
    # Render crop at final scale, removed regions in red.
    h, w = crop.shape[:2]
    nw = max(1, round(w * TARGET_H / h))
    base = Image.fromarray(crop, "RGB").resize((nw, TARGET_H), Image.LANCZOS)
    base = np.asarray(base).astype(np.int32)
    rem_img = Image.fromarray(removed.astype(np.uint8) * 255, "L").resize(
        (nw, TARGET_H), Image.NEAREST)
    rem = np.asarray(rem_img) > 0
    base[rem] = [255, 0, 0]
    Image.fromarray(base.astype(np.uint8)).save(
        os.path.join(HERE, f"debug-white-walk_{name}_f{idx}.png"))
    print(f"  {name} f{idx}: removed {int(removed.sum())}px -> "
          f"debug-white-walk_{name}_f{idx}.png")


def largest_remaining_enclosed(path):
    """Largest enclosed near-white region in final-scale px of a dest file."""
    im = Image.open(path).convert("RGBA")
    arr = np.asarray(im)
    rgb = arr[:, :, :3]
    alpha = arr[:, :, 3]
    white = near_white(rgb) & (alpha > 128)
    bg = flood_background(white | (alpha <= 128))
    enclosed = white & ~bg
    lab, n = ndimage.label(enclosed)
    if n == 0:
        return 0
    return max(int((lab == i).sum()) for i in range(1, n + 1))


def main():
    for name in ["cudanpenthouse"]:
        for i, bbox in enumerate(BBOXES[name]):
            debug_frame(name, i, bbox)
    print("largest remaining enclosed white (final px) in dest files:")
    for p in sorted(os.listdir(OUT_DIR)):
        if p.startswith(("walk_quanlypenthouse_", "walk_cudanpenthouse_",
                         "char_quanlypenthouse", "char_cudanpenthouse")):
            path = os.path.join(OUT_DIR, p)
            print(f"  {p}: {largest_remaining_enclosed(path)}")
    print("done.")


if __name__ == "__main__":
    main()
