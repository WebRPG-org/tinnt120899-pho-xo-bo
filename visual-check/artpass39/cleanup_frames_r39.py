#!/usr/bin/env python3
"""Artpass 38 — cleanup: drop detached stray fragments at frame edges.

The golf sheet v2 figures touch in 2D (bag/cap/shoe of neighbours), so the
column split leaves small detached fragments of the neighbouring figure
at the canvas left/right edge (f1/f3: neighbour shoe tip at right edge;
f2/f4: neighbour cap/bag speck at left edge). The figure itself (body +
club + bag) is one connected mass; the strays are separate components.
Keep only the largest alpha component (>128) plus any component >= 5% of
its area (safety: never delete a real body part); zero out the rest.
Re-runnable; reports what it removed per file.
"""
import os

import numpy as np
from PIL import Image
from scipy import ndimage

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
OUT_DIR = os.path.join(BASE, "src/godot/art")

FILES = ([f"walk_cobanbanh_f{i}.png" for i in range(6)]
         + [f"walk_onglaotaptheduc_f{i}.png" for i in range(6)]
         + ["char_cobanbanh.png", "char_onglaotaptheduc.png"])


def main():
    for fn in FILES:
        path = os.path.join(OUT_DIR, fn)
        im = Image.open(path).convert("RGBA")
        arr = np.asarray(im)
        alpha = arr[:, :, 3]
        mask = alpha > 128
        lab, n = ndimage.label(mask)
        if n <= 1:
            print(f"  {fn}: 1 component, unchanged")
            continue
        sizes = [(i, int((lab == i).sum())) for i in range(1, n + 1)]
        sizes.sort(key=lambda t: -t[1])
        biggest = sizes[0][1]
        keep = {sizes[0][0]}
        removed = 0
        for i, sz in sizes[1:]:
            if sz >= 0.05 * biggest:
                keep.add(i)
                print(f"  {fn}: KEEP secondary component {i} ({sz}px, "
                      f"{sz / biggest:.0%} of biggest)")
            else:
                removed += sz
        drop = ~np.isin(lab, list(keep)) & mask
        if removed:
            arr = arr.copy()
            # Also clear the feather halo (alpha<=128) around the dropped
            # fragment, dilated 2px, so no faint smudge stays on the edge.
            # Only low-alpha pixels are touched: solid figure pixels
            # (alpha>128) are never in the dilated halo region's target.
            halo = ndimage.binary_dilation(drop, iterations=2) & (alpha <= 128)
            arr[:, :, 3][drop] = 0
            arr[:, :, 3][halo] = 0
            Image.fromarray(arr).save(path)
            print(f"  {fn}: removed {removed}px detached fragment(s) "
                  f"(biggest {biggest}px, {n} components)")
        else:
            print(f"  {fn}: {n} components, nothing small enough to drop")
    print("done.")


if __name__ == "__main__":
    main()
