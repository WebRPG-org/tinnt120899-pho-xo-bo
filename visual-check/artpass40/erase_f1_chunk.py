#!/usr/bin/env python3
"""Artpass 40 — REJECTED, DO NOT RUN. Surgical erase of the foreign
basket chunk in walk_chusapdem_f1.png (AFTER watershed slice + cleanup).
REJECTED 25/11: the erase box (x<=26, y>=150) also ate the dark
anti-aliased lower edge of f1's own lantern, leaving only a red
sliver — worse than the chunk. Reverted to the plain-watershed f1
(chunk kept as a documented limitation). Kept as a record of the
failed fix, not part of the pipeline.

Why: on the dense v1 sheet f0's basket touches f1's lantern in 2D, so
the watershed gives f1 a ~189px chunk of f0's basket at the frame's
bottom-left corner (frame x 0..12, y >= 150). Two sheet-level
touch-zone fixes were tried and REJECTED (see slice script comment):
plain x-cut stole f1's lantern; colour-aware cut shredded the lantern
and f0's basket. The chunk sits in a corner box clear of f1's own
figure (lantern at frame x ~10..30, y ~110..160 with red tassel;
feet at x > 30), so it is erased here at frame level: inside the box
x <= 11, y >= 152, zero the alpha of every pixel that is NOT lantern
red/gold (the tassel is protected even if it dips into the box).
Run AFTER cleanup_frames_r40.py; re-runnable (idempotent).
"""
import os

import numpy as np
from PIL import Image

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
PATH = os.path.join(BASE, "src/godot/art/walk_chusapdem_f1.png")
X_MAX, Y_MIN = 26, 150


def main():
    im = Image.open(PATH).convert("RGBA")
    arr = np.asarray(im).copy()
    R, G, B, A = (arr[:, :, i].astype(int) for i in range(4))
    lantern = ((R > 150) & (G < 120) & (B < 120)) | (
        (R > 150) & (G > 100) & (G < 200) & (B < 130))
    box = np.zeros(arr.shape[:2], dtype=bool)
    box[Y_MIN:, :X_MAX + 1] = True
    target = box & (A > 0) & ~lantern
    n = int(target.sum())
    arr[:, :, 3][target] = 0
    Image.fromarray(arr).save(PATH)
    print(f"erased {n}px foreign chunk in walk_chusapdem_f1.png "
          f"(box x<= {X_MAX}, y>= {Y_MIN}, lantern red/gold kept)")
    print("done.")


if __name__ == "__main__":
    main()
