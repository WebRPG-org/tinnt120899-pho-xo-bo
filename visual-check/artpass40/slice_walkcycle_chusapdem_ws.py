#!/usr/bin/env python3
"""Artpass 40 — watershed re-slice of the chusapdem sheet (v1).

Why: the v1 sheet is DENSE (2240x1120, figures pitch ~365px): the 6
figures touch in 2D (hat brims overlap, f0's basket touches f1's
lantern), so the whole sheet is ONE connected component. The r39
vertical split (split_wide_component, lowest-density column) cuts
THROUGH props: f1's lantern is sliced at x=430 (left half lands in
f0's frame), f4's basket is sliced at x=1800, and a sliver of f2's hat
brim + a fragment of f0's basket land in f1's frame. A vertical line
cannot separate two figures whose props overlap in BOTH x and y.

Fix: geodesic multi-source BFS (watershed) inside the merged
component. Seeds are the 6 figure torsos (centres from the vertical
split bboxes, y=550 in the apron band — verified on non-white
pixels). Every foreground pixel goes to the seed that reaches it
first THROUGH the mask, so a prop stays whole with the figure whose
arm holds it: f1's lantern (connected via f1's arm) goes to f1 even
though it hangs left of the f0/f1 midline, and f0's basket (connected
via f0's arm) goes to f0. The boundary between two hat brims falls
where the two growth fronts meet — each figure keeps its own brim.

Reuses process_figure / flood_background / near_white from
slice_walkcycle_npc_map018.py (same white->transparent + enclosed
white >=100 final px + resize to height 208 + common canvas).
Outputs: src/godot/art/walk_chusapdem_f0..f5.png (OVERWRITES the
vertical-split frames) + walkcycle-check-magenta-chusapdem.png.
"""
import os
import sys
from collections import deque

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from slice_walkcycle_npc_map018 import (  # noqa: E402
    HERE, OUT_DIR, TARGET_H, PAD, near_white, process_figure)

SHEET = os.path.join(HERE, "walkcycle-sheet-chusapdem.png")
# Torso centres from the vertical-split bboxes of the same sheet:
# [(23,430),(430,815),(815,1156),(1156,1450),(1450,1800),(1800,2214)]
SEED_X = [226, 622, 985, 1303, 1625, 2007]
SEED_Y = 550
SEED_R = 15


def watershed_split(mask):
    """mask: bool array of the merged component (bbox crop).
    Returns int8 label array (0=background, 1..6=figure)."""
    h, w = mask.shape
    lab = np.zeros((h, w), dtype=np.int8)
    q = deque()
    for i, cx in enumerate(SEED_X):
        # seed disk must sit on foreground; nudge if the exact centre
        # happens to be white (it is apron for all 6 figures here).
        found = False
        for dy in range(-40, 41):
            for dx in range(-40, 41):
                x, y = cx + dx, SEED_Y + dy
                if 0 <= x < w and 0 <= y < h and mask[y, x] and lab[y, x] == 0:
                    lab[y, x] = i + 1
                    q.append((y, x))
                    found = True
                    break
            if found:
                break
        assert found, f"seed {i} (x={cx}) found no foreground pixel"
        # grow a small disk around the first seed pixel so the front
        # starts inside the torso, not at a single point
        sy, sx = q[-1]
        for dy in range(-SEED_R, SEED_R + 1):
            for dx in range(-SEED_R, SEED_R + 1):
                x, y = sx + dx, sy + dy
                if (0 <= x < w and 0 <= y < h and mask[y, x]
                        and lab[y, x] == 0 and dx * dx + dy * dy <= SEED_R ** 2):
                    lab[y, x] = i + 1
                    q.append((y, x))
    n_seed = len(q)
    print(f"  seeds planted: {n_seed} px")
    while q:
        y, x = q.popleft()
        v = lab[y, x]
        if y > 0 and mask[y - 1, x] and lab[y - 1, x] == 0:
            lab[y - 1, x] = v
            q.append((y - 1, x))
        if y + 1 < h and mask[y + 1, x] and lab[y + 1, x] == 0:
            lab[y + 1, x] = v
            q.append((y + 1, x))
        if x > 0 and mask[y, x - 1] and lab[y, x - 1] == 0:
            lab[y, x - 1] = v
            q.append((y, x - 1))
        if x + 1 < w and mask[y, x + 1] and lab[y, x + 1] == 0:
            lab[y, x + 1] = v
            q.append((y, x + 1))
    return lab


def main():
    sheet = Image.open(SHEET).convert("RGB")
    W, H = sheet.size
    print(f"== chusapdem (watershed): sheet {W}x{H}")
    arr = np.asarray(sheet)
    mask = ~near_white(arr)
    # Restrict to the merged component bbox (23,157,2214,993) — the only
    # big component; specks outside are ignored (same as slice script,
    # which drops components narrower than MIN_FIG_W).
    ys, xs = np.where(mask)
    # Use the known merged bbox from the vertical-split run.
    x0, y0, x1, y1 = 23, 157, 2214, 993
    sub = mask[y0:y1, x0:x1]
    lab = watershed_split(sub)
    # Touch-zone fix: DISABLED (TOUCH_FIX=False). Two attempts failed:
    # (1) plain x<480 cut stole f1's lantern handle + fingertips, the
    # lantern detached from her hand and cleanup dropped it — f1 lost
    # the lantern entirely. (2) colour-aware cut (keep red/gold/skin)
    # misfired on anti-aliased edges: the lantern kept only a sliver,
    # and light wicker strands classified as "skin" stayed with f1,
    # leaving white holes in f0's basket. The touch zone (basket
    # occluding the lantern) cannot be split reliably by colour or by
    # x — the plain watershed result is kept instead, and the single
    # foreign chunk it leaves in f1's frame is erased surgically at
    # frame level afterwards (see erase_f1_chunk.py), where the chunk
    # sits in a corner box clear of f1's own lantern/feet.
    TOUCH_FIX = False
    if TOUCH_FIX:
        raise RuntimeError("touch fix disabled, see comment above")
    counts = [(i, int((lab == i).sum())) for i in range(1, 7)]
    print(f"  watershed pixel counts per figure: {counts}")
    assert all(c > 10000 for _, c in counts), "a figure got too few px"
    frames = []
    for i in range(1, 7):
        comp = np.zeros_like(mask)
        comp[y0:y1, x0:x1] = (lab == i)
        fys, fxs = np.where(comp)
        bbox = (int(fxs.min()), int(fys.min()),
                int(fxs.max()) + 1, int(fys.max()) + 1)
        frame, cbbox = process_figure(arr, comp, bbox, i - 1)
        frames.append(frame)
        print(f"  f{i-1}: bbox={bbox} crop={cbbox} -> "
              f"{frame.size[0]}x{frame.size[1]}")
    cw = max(f.width for f in frames)
    saved = []
    for i, f in enumerate(frames):
        canvas = Image.new("RGBA", (cw, TARGET_H), (0, 0, 0, 0))
        canvas.paste(f, ((cw - f.width) // 2, 0), f)
        path = os.path.join(OUT_DIR, f"walk_chusapdem_f{i}.png")
        canvas.save(path)
        saved.append(canvas)
        print(f"  f{i}: saved {cw}x{TARGET_H}  {path}")
    strip = Image.new("RGBA", (cw * 6, TARGET_H), (255, 0, 255, 255))
    for i, f in enumerate(saved):
        strip.paste(f, (i * cw, 0), f)
    check = os.path.join(HERE, "walkcycle-check-magenta-chusapdem.png")
    strip.save(check)
    print(f"  check strip saved: {check}")
    print("done.")


if __name__ == "__main__":
    main()
