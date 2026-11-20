"""Vong 8 — verify ban staging MOI (chunk theo version) tren Chromium
local, viewport 1920x1000 (dung nhu kiem live 16:52).
Kiem: title + anh tieu de load duoc, nut BAT DAU enable, vao game
an chu landing 2 ben, giu D + tap D di duoc, tap-to-move trong
canvas, F doi khung, P dien thoai, cua TAP HOA khung Sang het cam
(do pixel tren screenshot), canvas vua tron 1000px (khong cat day).
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8162/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass8"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=[
            "--no-sandbox", "--disable-dev-shm-usage",
            "--use-gl=angle", "--use-angle=swiftshader",
            "--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width": 1920, "height": 1000})
        errors, failed = [], []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        page.on("requestfailed", lambda r: failed.append(f"{r.url} :: {r.failure}"))
        page.on("response", lambda r: failed.append(f"HTTP {r.status} :: {r.url}") if r.status >= 400 else None)
        await page.goto(URL, wait_until="load", timeout=120000)
        await page.wait_for_timeout(8000)
        await page.screenshot(path=f"{OUT}/a8-01-title.png")
        await page.wait_for_selector("#start-btn:not([disabled])", timeout=120000)
        # Canvas box truoc khi vao game.
        box = await page.evaluate("() => { const c = document.getElementById('canvas').getBoundingClientRect(); return {x: c.x, y: c.y, w: c.width, h: c.height}; }")
        print("canvas box:", box)
        await page.click("#start-btn")
        await page.wait_for_timeout(1000)
        in_game = await page.evaluate("() => ({cls: document.body.classList.contains('in-game'), titleHidden: getComputedStyle(document.querySelector('.side-panel .panel-title')).display === 'none'})")
        print("in-game class + title hidden:", in_game)
        await page.wait_for_timeout(5000)
        await page.screenshot(path=f"{OUT}/a8-02-spawn.png")
        # Giu D 3s di phai, roi tap D 10 lan.
        await page.mouse.click(960, 500)
        await page.keyboard.down("d")
        await page.wait_for_timeout(3000)
        await page.keyboard.up("d")
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/a8-03-after-hold-d.png")
        for _ in range(10):
            await page.keyboard.press("d")
            await page.wait_for_timeout(250)
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/a8-04-after-10-taps-d.png")
        # Tap-to-move trong canvas (x 1150 nam trong cot game 679..1241).
        await page.mouse.click(1150, 750)
        await page.wait_for_timeout(5000)
        await page.screenshot(path=f"{OUT}/a8-05-after-tap-move.png")
        # F: Chieu, Toi, Sang ngay 2.
        for name in ["chieu", "toi", "sang2"]:
            await page.keyboard.press("f")
            await page.wait_for_timeout(2500)
            await page.screenshot(path=f"{OUT}/a8-06-frame-{name}.png")
        # P: dien thoai.
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/a8-07-phone.png")
        await page.keyboard.press("p")
        await page.wait_for_timeout(1000)
        print("ERRORS:", len(errors))
        for e in errors[:15]:
            print(" -", e[:250])
        print("FAILED REQUESTS:", len(failed))
        for f in failed[:15]:
            print(" -", f[:250])
        await browser.close()

asyncio.run(main())
