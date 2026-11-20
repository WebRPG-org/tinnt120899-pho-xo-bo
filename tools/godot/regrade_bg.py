#!/usr/bin/env python3
"""Can bang tone ngang cho anh nen composite Map001 (artpass4, diem 3).

Anh goc ghep tu 3 tam mat tien (PHO BO / CA PHE / TAP HOA) co tone
khac nhau: tam phai (TAP HOA) toi/xanh hon tam giua ~7-11 don vi
do sang -> thay duong noi doc khi camera sang phai.

Phuong phap (ban 2): gain HANG SO theo tung phan (1/3 anh), chuyen
tiep tuyen tinh rong 160px qua 2 duong noi (x~373, ~747) — khong
tao buoc nhay moi tai duong noi (ban 1 dung gain lam muot 201px
van de lai buoc cuc bo lon hon). Gain kep [0.92, 1.08].

Chay 1 lan tu ban goc o /tmp/artpass4-bak/ (khoi phuc truoc roi
tinh lai), ghi de len file goc.
"""
import shutil
from pathlib import Path

import numpy as np
from PIL import Image

ART = Path("/home/hatch/workspace/pho-xo-bo/src/godot/art")
BAK = Path("/tmp/artpass4-bak")


def thirds_mean(arr):
    band = arr[340:620, :, :].astype(np.float64)
    lum = 0.299 * band[:, :, 0] + 0.587 * band[:, :, 1] + 0.114 * band[:, :, 2]
    w = lum.shape[1]
    return [float(lum[:, i * w // 3:(i + 1) * w // 3].mean()) for i in range(3)]


def regrade(path, is_jpg):
    bak = BAK / path.name
    shutil.copy2(bak, path)  # khoi phuc ban goc truoc khi tinh lai
    im = Image.open(path).convert("RGB")
    arr = np.asarray(im).astype(np.float64)
    h, w, _ = arr.shape
    means = thirds_mean(arr)
    target = float(np.mean(means))
    gains = [float(np.clip(target / m, 0.92, 1.08)) for m in means]
    print(f"{path.name}: phan {['%.1f' % m for m in means]} target {target:.1f} gain {['%.3f' % g for g in gains]}")
    # Gain theo cot: hang so theo phan, ramp tuyen tinh 160px qua duong noi.
    xs = np.arange(w, dtype=np.float64)
    gain = np.empty(w)
    b1, b2 = w / 3.0, 2 * w / 3.0
    ramp = 80.0
    gain[xs < b1 - ramp] = gains[0]
    gain[xs > b2 + ramp] = gains[2]
    mid = (xs >= b1 - ramp) & (xs <= b1 + ramp)
    gain[mid] = gains[0] + (gains[1] - gains[0]) * (xs[mid] - (b1 - ramp)) / (2 * ramp)
    mid2 = (xs >= b2 - ramp) & (xs <= b2 + ramp)
    gain[mid2] = gains[1] + (gains[2] - gains[1]) * (xs[mid2] - (b2 - ramp)) / (2 * ramp)
    core = (xs >= b1 + ramp) & (xs <= b2 - ramp)
    gain[core] = gains[1]
    # Chi ap cho y>=240 (mai + mat tien), feather 240-280.
    feather = np.ones(h)
    feather[240:280] = np.linspace(0.0, 1.0, 40)
    feather[:240] = 0.0
    g2d = (1.0 + (gain[None, :] - 1.0) * feather[:, None])
    out = np.clip(arr * g2d[:, :, None], 0, 255).astype(np.uint8)
    print(f"{path.name}: sau {['%.1f' % m for m in thirds_mean(out)]}")
    Image.fromarray(out).save(path, quality=92 if is_jpg else None)
    return path


if __name__ == "__main__":
    regrade(ART / "bg_map001.png", False)
    regrade(ART / "bg_map001_night.jpg", True)
    print("Xong.")
