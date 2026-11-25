#!/usr/bin/env python3
"""Artpass 42 — stall sprites (banhmi / giavi / dokho) for Pho Xo Bo (Godot).

Method (adapted from artpass40 process_standing, but for stalls):
  - Raw gen has a near-uniform sky-blue background (sampled from corners).
    Background is removed by colour distance to that blue (NOT by white
    flood-fill: the awning's WHITE stripes must survive, and the middle
    gap between awning and counter is an ENCLOSED background region that
    a border flood-fill could never reach).
  - Alpha is a soft ramp on distance-to-bg so edges anti-alias cleanly.
  - The stall is then re-laid into the 64x96 contract bands by splitting
    the source into 4 horizontal bands and resizing each to its contract
    height: awning -> y34-52 (18px), posts gap -> y52-60 (8px), goods ->
    y60-76 (16px), counter -> y76-96 (20px); y0-33 stays fully transparent
    (code draws the sign + Vietnamese text there). Each band is resized
    to 64px wide, so the posts (near the source edges) land at x~3-5 and
    x~59-61, matching the contract (x2-6 and x58-62).
  - Transparent pixels get their RGB filled from the nearest opaque
    pixel before LANCZOS resize, so no blue halo bleeds into edges.

Inputs : visual-check/artpass42/media-generation-stall-{banhmi,giavi,dokho}-v*.png
Outputs: src/godot/art/stall_{banhmi,giavi,dokho}.png (64x96 RGBA)
         visual-check/artpass42/stall_{banhmi,giavi,dokho}.png (same, record)
         visual-check/artpass42/stall-{name}-magenta.png (on magenta)
         visual-check/artpass42/zoom-stall-{name}.png (3x zoom on magenta)
"""
import glob
import os

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

BASE = os.path.expanduser("~/workspace/pho-xo-bo")
HERE = os.path.join(BASE, "visual-check/artpass42")
OUT_DIR = os.path.join(BASE, "src/godot/art")

# (raw stem pattern, output name, band boundaries in source px or None=auto)
STALLS = [
    ("stall-banhmi-v1", "stall_banhmi"),
    ("stall-giavi-v2", "stall_giavi"),
    ("stall-dokho-v2", "stall_dokho"),
]

BG_T = 40          # distance-to-bg above which a pixel is definitely content
RAMP_LO, RAMP_HI = 30.0, 50.0   # soft-alpha ramp on distance-to-bg
BAND_H = (18, 8, 16, 20)          # awning / gap(posts) / goods / counter
TOP_Y = 34                      # contract: stall starts at y=34


def bg_color(arr):
    h, w = arr.shape[:2]
    patches = [arr[0:12, 0:12], arr[0:12, w - 12:w], arr[h - 12:h, 0:12],
               arr[h - 12:h, w - 12:w], arr[0:12, w // 2 - 6:w // 2 + 6],
               arr[h - 12:h, w // 2 - 6:w // 2 + 6]]
    return np.median(np.concatenate([p.reshape(-1, 3) for p in patches]), axis=0)


def row_profile(mask):
    return mask.sum(axis=1)


def brown_frac_row(arr_row, mask_row):
    """Fraction of non-bg pixels that are wood-brown (counter front)."""
    px = arr_row[mask_row]
    if len(px) == 0:
        return 0.0
    R, G, B = px[:, 0], px[:, 1], px[:, 2]
    m = (R >= 130) & (R <= 215) & (G >= 70) & (G <= 150) & (B >= 25) & (B <= 90) \
        & ((R - G) >= 35) & ((R - G) <= 100) & ((R - B) > 60)
    return float(m.mean())


def detect_bands(mask, arr, x0, x1, y0, y1):
    """Return (awning_bottom, goods_top, counter_top, y1e), source coords.

    - awning_bottom: last row before the long near-empty gap run.
    - goods_top: first row after the awning where the row is wide
      (>0.20*w — goods are wide, posts alone are ~0.06*w).
    - counter_top: first row after the gap whose wood-brown fraction
      is >0.70 and stays >0.70 on average below (basket wicker rows
      reach only ~0.57, counter front ~0.76-0.95). Falls back to the
      sustained-solid test when no row qualifies (cathit: its golden
      sunlit counter never reaches the brown test).
    """
    w = x1 - x0 + 1
    sub = mask[y0:y1 + 1, x0:x1 + 1]
    cnt = row_profile(sub)
    h = len(cnt)
    # Trim trailing sparse rows: the bbox bottom may be a partial edge row
    # (count below 0.85*w), which would poison any "sustained to bottom"
    # test. y1e = last row that is itself >0.85*w solid.
    solid = np.where(cnt > 0.85 * w)[0]
    y1e = int(solid.max()) if len(solid) else h - 1
    # Gap: longest run of near-empty rows in the middle 20%-70% of the stall.
    lo, hi = int(h * 0.20), int(h * 0.70)
    best, cur, cur_start = (0, 0, 0), 0, lo
    gap_start, gap_end = lo, lo
    for i in range(lo, hi + 1):
        if cnt[i] < 0.12 * w:
            if cur == 0:
                cur_start = i
            cur += 1
            if cur > best[0]:
                best = (cur, cur_start)
                gap_start, gap_end = cur_start, i
        else:
            cur = 0
    awning_bottom = y0 + gap_start - 1
    goods_top = y0 + gap_end
    for i in range(gap_end, y1e + 1):
        if cnt[i] > 0.20 * w:
            goods_top = y0 + i
            break
    # Wood-brown profile (only rows from the gap down).
    bf = np.zeros(h)
    for i in range(gap_end, h):
        bf[i] = brown_frac_row(arr[y0 + i, x0:x1 + 1], sub[i])
    counter_top = None
    for i in range(gap_end, y1e + 1):
        if bf[i] > 0.70 and bf[i:y1e + 1].mean() > 0.70:
            counter_top = y0 + i
            break
    if counter_top is None:
        # Fallback (cathit): first row after the gap that stays >0.90*w
        # solid all the way to the last solid row.
        counter_top = y0 + y1e
        for i in range(gap_end, y1e + 1):
            if cnt[i] > 0.90 * w and cnt[i:y1e + 1].min() > 0.85 * w:
                counter_top = y0 + i
                break
    return awning_bottom, goods_top, counter_top, y0 + y1e


def nearest_fill_rgb(rgb, alpha):
    """Fill RGB of transparent pixels from the nearest opaque pixel."""
    opaque = alpha > 0
    _, inds = ndimage.distance_transform_edt(~opaque, return_indices=True)
    filled = rgb[tuple(inds)]
    return filled


def process(name, out_name):
    cands = sorted(glob.glob(os.path.join(HERE, f"media-generation-{name}-*.png")))
    assert len(cands) == 1, f"{name}: {cands}"
    img = Image.open(cands[0]).convert("RGB")
    arr = np.asarray(img).astype(float)
    bg = bg_color(arr)
    dist = np.sqrt(((arr - bg) ** 2).sum(axis=2))
    # Diagnostics: bg separation. Max dist inside known-bg corner patches.
    h, w = dist.shape
    corner_max = max(dist[0:12, 0:12].max(), dist[0:12, w - 12:w].max(),
                     dist[h - 12:h, 0:12].max(), dist[h - 12:h, w - 12:w].max())
    print(f"== {name}: {img.size} bg~{bg.round(1)} corner_max_dist={corner_max:.1f}")
    mask = dist > BG_T
    ys, xs = np.where(mask)
    x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max()
    print(f"   bbox x[{x0},{x1}] y[{y0},{y1}] w={x1-x0+1} h={y1-y0+1}")
    awn_bot, goods_top, cnt_top, y1e = detect_bands(mask, arr, x0, x1, y0, y1)
    print(f"   bands src: awning y{y0}-{awn_bot} ({awn_bot-y0+1}px), "
          f"gap y{awn_bot+1}-{goods_top-1} ({goods_top-awn_bot-1}px), "
          f"goods y{goods_top}-{cnt_top-1} ({cnt_top-goods_top}px), "
          f"counter y{cnt_top}-{y1e} ({y1e-cnt_top+1}px), "
          f"trimmed rows below y{y1e}: {y1-y1e}")
    # Soft alpha + nearest-fill RGB, then crop to bbox x-range.
    alpha = np.clip((dist - RAMP_LO) / (RAMP_HI - RAMP_LO), 0, 1) * 255
    alpha = alpha.astype(np.uint8)
    rgb = nearest_fill_rgb(np.asarray(img), alpha)
    rgba = np.dstack([rgb, alpha])
    crop = rgba[y0:y1e + 1, x0:x1 + 1]
    # Split into 4 bands (relative to crop) and resize each to (64, band_h).
    rel_awn = awn_bot - y0 + 1
    rel_goods = goods_top - y0
    rel_cnt = cnt_top - y0
    bands = [crop[0:rel_awn], crop[rel_awn:rel_goods],
             crop[rel_goods:rel_cnt], crop[rel_cnt:]]
    out = Image.new("RGBA", (64, 96), (0, 0, 0, 0))
    y = TOP_Y
    for band, bh in zip(bands, BAND_H):
        bimg = Image.fromarray(band, "RGBA").resize((64, bh), Image.LANCZOS)
        out.paste(bimg, (0, y), bimg)
        y += bh
    assert y == 96, y
    for path in (os.path.join(OUT_DIR, f"{out_name}.png"),
                 os.path.join(HERE, f"{out_name}.png")):
        out.save(path)
        print(f"   saved {out.size} {out.mode}  {path}  {os.path.getsize(path)} bytes")
    # Magenta check + 3x zoom on magenta.
    check = Image.new("RGBA", out.size, (255, 0, 255, 255))
    check.paste(out, (0, 0), out)
    check.save(os.path.join(HERE, f"{out_name}-magenta.png"))
    zoom = check.resize((64 * 3, 96 * 3), Image.NEAREST)
    zoom.save(os.path.join(HERE, f"zoom-{out_name}.png"))
    # Contract measurements on the final sprite.
    a = np.asarray(out)[:, :, 3]
    print(f"   alpha>0 in y0-33 (must be 0): {int((a[0:34] > 0).sum())}")
    for label, (ya, yb) in {"awning 34-52": (34, 53), "gap 52-60": (52, 61),
                            "goods 60-76": (60, 77),
                            "counter 76-96": (76, 96)}.items():
        print(f"   {label}: opaque px={int((a[ya:yb] > 0).sum())} "
              f"rows_with_content={int((a[ya:yb] > 0).any(axis=1).sum())}/{yb-ya}")
    for yy in (40, 60, 70, 85, 95):
        xs2 = np.where(a[yy] > 0)[0]
        print(f"   row y={yy}: opaque x range "
              f"{(int(xs2.min()), int(xs2.max())) if len(xs2) else None} n={len(xs2)}")
    # Stray-component check: stall should be 1 connected component.
    lab, n = ndimage.label(a > 0)
    sizes = sorted(((lab == i).sum() for i in range(1, n + 1)), reverse=True)
    print(f"   alpha components: {n}, sizes={sizes[:5]}")
    return out


def main():
    for name, out_name in STALLS:
        process(name, out_name)
    print("done.")


if __name__ == "__main__":
    main()
