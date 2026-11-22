"""Vong 24 — kiem "Bien pho dung dua + khoi noi pho ro hon"
o xe do an Map001 (cong 8178).

- Xe do an o o (6,12), vung dat mo rong duoi map.
- Di xuong day map: tu spawn (4,5) bam phim Down 3 lan,
  MOI LAN GIU 400ms (keyboard.down, cho 400ms, keyboard.up —
  bai hoc vong truoc: giu 400ms = dung 1 o; bam nhanh bi miss
  frame) de toi hang 8.
- Zoom vung duoi man hinh chua xe do an
  (clip viewport x=0,y=640,w=720,h=640), chup 2 anh cach nhau
  1500ms va tinh pixel-diff bang PIL — tin hieu chuyen dong
  cua bien dung dua + khoi bay.
"""
import asyncio
import re

from playwright.async_api import async_playwright

try:
    from PIL import Image, ImageChops
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

URL = "http://127.0.0.1:8178/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass24"


async def shot(page, name, clip=None):
    if clip is not None:
        await page.screenshot(path=f"{OUT}/{name}.png", clip=clip)
    else:
        await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    """Tra ve 'dom' neu bam nut DOM (nguoi choi o spawn (4,5)),
    'canvas' neu phai bam canvas (click cham thanh tap, nguoi
    choi di toi (6,7))."""
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(45000)
    for _ in range(3):
        try:
            await page.get_by_text("BẮT ĐẦU CHƠI").click(timeout=10000)
            print("start: DOM button clicked", flush=True)
            await page.wait_for_timeout(6000)
            return "dom"
        except Exception:
            await page.wait_for_timeout(10000)
    await page.mouse.click(360, 1060)
    print("start: canvas button click (360,1060)", flush=True)
    await page.wait_for_timeout(6000)
    return "canvas"


async def print_player_pos(page):
    """In vi tri nguoi choi neu doc duoc nhan debug goc tren-trai,
    khong doc duoc thi bo qua (nhan ve tren canvas Godot, DOM
    thuong khong thay)."""
    try:
        text = await page.evaluate("() => document.body.innerText")
        m = re.search(r"\(?\s*\d+\s*,\s*\d+\s*\)?", text or "")
        if m:
            print("player pos (DOM):", m.group(0), flush=True)
        else:
            print("player pos: khong doc duoc nhan debug (bo qua)",
                  flush=True)
    except Exception as e:
        print("player pos: khong doc duoc nhan debug (bo qua):", e,
              flush=True)


def pixel_diff(path_a, path_b, threshold=10):
    """Dem pixel khac nhau > nguong giua 2 anh (PIL). Tra ve so
    pixel khac, hoac None neu khong tinh duoc."""
    if not HAS_PIL:
        print("pixel-diff: PIL khong co san, bo qua", flush=True)
        return None
    try:
        a = Image.open(path_a).convert("RGB")
        b = Image.open(path_b).convert("RGB")
        if a.size != b.size:
            print(f"pixel-diff: kich thuoc khac nhau {a.size} vs "
                  f"{b.size}", flush=True)
            return None
        diff = ImageChops.difference(a, b).convert("L")
        hist = diff.histogram()
        changed = sum(hist[threshold + 1:])
        total = a.size[0] * a.size[1]
        print(f"pixel-diff: {changed}/{total} pixel khac "
              f"(nguong >{threshold})", flush=True)
        return changed
    except Exception as e:
        print("pixel-diff: loi:", e, flush=True)
        return None


async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=[
            "--no-sandbox", "--disable-dev-shm-usage",
            "--use-gl=angle", "--use-angle=swiftshader",
            "--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width": 720, "height": 1280})
        errors = []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        page.on("requestfailed", lambda r: errors.append(f"reqfail: {r.url[:120]}"))
        how = await start_game(page)
        await shot(page, "r24-01-spawn")
        print("start mode:", how, flush=True)
        # Di xuong day map: tu spawn (4,5) bam Down 3 lan, moi lan
        # GIU 400ms (down -> cho 400ms -> up) = dung 1 o/lan,
        # toi hang 8. Cho on dinh 1500ms sau moi buoc.
        for i in range(3):
            await page.keyboard.down("ArrowDown")
            await page.wait_for_timeout(400)
            await page.keyboard.up("ArrowDown")
            await page.wait_for_timeout(1500)
            print(f"down {i + 1}/3 done", flush=True)
        await print_player_pos(page)
        await page.wait_for_timeout(1000)
        await shot(page, "r24-02-cart")
        # Zoom vung duoi man hinh chua xe do an (viewport 720x1280):
        # clip x=0, y=640, w=720, h=640.
        zoom = {"x": 0, "y": 640, "width": 720, "height": 640}
        await shot(page, "r24-03-cart-zoom", clip=zoom)
        await page.wait_for_timeout(1500)
        await shot(page, "r24-04-cart-zoom2", clip=zoom)
        # Pixel-diff giua 2 anh zoom: tin hieu bien dung dua +
        # khoi noi pho bay (anh tinh thi diff ~0).
        pixel_diff(f"{OUT}/r24-03-cart-zoom.png",
                   f"{OUT}/r24-04-cart-zoom2.png", threshold=10)
        n_console = sum(1 for e in errors if e.startswith("console."))
        n_pageerr = sum(1 for e in errors if e.startswith("pageerror:"))
        n_reqfail = sum(1 for e in errors if e.startswith("reqfail:"))
        print(f"TOM TAT: console error={n_console}, "
              f"pageerror={n_pageerr}, requestfailed={n_reqfail} "
              f"({'PASS' if not errors else 'FAIL'})", flush=True)
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
