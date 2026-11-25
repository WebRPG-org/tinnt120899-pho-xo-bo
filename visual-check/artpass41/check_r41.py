"""Vong 41 — kiem hang sap Map002 tach rieng (o le de trong) tren build local.

- Hang 0 Map002: 6 sap chan [0,2,4,6,8,10] tach rieng nhau,
  o le [1,3,5,7,9,11] de trong (khong tuong/mai/cua so) —
  khong con dai tuong lien tuc; bien hieu 8 loai van doc duoc.
- Neu co sprite (artpass41): 5 bien co sprite (RAU CU, TRAI CAY,
  HOA QUA, CA TUOI, THIT HEO) ve bang anh that; 3 bien con lai
  (BANH MI, GIA VI, DO KHO) ve bang code nhu cu.
- Spawn Map001 -> cua (5,4) sang Map002.
- 0 console error / pageerror / requestfailed.
"""
import asyncio
from PIL import Image
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8196/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass41"


async def shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    # Doi nut DOM enable (engine tai xong) toi da 150s.
    try:
        await page.wait_for_selector("#start-btn:not([disabled])", timeout=150000)
        print("start: DOM button enabled", flush=True)
    except Exception as e:
        print("start: DOM button never enabled:", e, flush=True)
    for _ in range(3):
        try:
            await page.click("#start-btn", timeout=10000)
            await page.wait_for_timeout(2000)
            started = await page.evaluate("window.__pxb_start === true")
            print("start: DOM button clicked, __pxb_start =", started, flush=True)
            if started:
                await page.wait_for_timeout(6000)
                return
        except Exception as e:
            print("start: DOM click failed:", e, flush=True)
            await page.wait_for_timeout(10000)
    await page.mouse.click(360, 1060)
    print("start: canvas button click (360,1060)", flush=True)
    await page.wait_for_timeout(6000)


async def walk(page, keys):
    # Bai hoc G4 §9.1: keyboard.press nhanh bi miss giua cac frame
    # (game ~0.22x thoi gian that); giu phim 400ms = dung 1 o.
    for key in keys:
        await page.keyboard.down(key)
        await page.wait_for_timeout(400)
        await page.keyboard.up(key)
        await page.wait_for_timeout(1200)


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
        await start_game(page)
        # Map001 (4,5) -> len (4,4) -> phai (5,4) = cua sang Map002.
        await walk(page, ["ArrowUp", "ArrowRight"])
        await page.wait_for_timeout(2000)
        await shot(page, "r41-01-map2")
        # Zoom vung hang sap (theo mau check_r23: clip y=640..1000).
        im = Image.open(f"{OUT}/r41-01-map2.png")
        im.crop((0, 600, 720, 1050)).resize((1440, 900)).save(f"{OUT}/r41-02-stall-row-zoom.png")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
