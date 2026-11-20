"""Vong 8 — test TAP (nhu kiem live: bam tung phat, khong giu) + tap-to-move
CHUAN (click trong canvas 679..1241) tren ban staging.
"""
import asyncio, sys
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
        errors = []
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        await page.goto(URL, wait_until="load", timeout=120000)
        await page.wait_for_selector("#start-btn:not([disabled])", timeout=120000)
        await page.click("#start-btn")
        await page.wait_for_timeout(5000)
        await page.mouse.click(960, 500)  # focus canvas
        await page.wait_for_timeout(300)
        # TAP d 10 lan nhu kiem live (khong giu).
        for _ in range(10):
            await page.keyboard.press("d")
            await page.wait_for_timeout(250)
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/r8-10-after-10-taps-d.png")
        # TAP mui ten phai 5 lan.
        for _ in range(5):
            await page.keyboard.press("ArrowRight")
            await page.wait_for_timeout(250)
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/r8-11-after-5-taps-arrow.png")
        # Tap-to-move CHUAN: click dat trong canvas, ben phai nguoi choi.
        await page.mouse.click(1150, 750)
        await page.wait_for_timeout(5000)
        await page.screenshot(path=f"{OUT}/r8-12-after-tap-move.png")
        # E gan Co Tu? di ve phia Co Tu truoc: giu A + W roi bam E.
        await page.keyboard.down("a")
        await page.wait_for_timeout(1500)
        await page.keyboard.up("a")
        await page.keyboard.press("e")
        await page.wait_for_timeout(1500)
        await page.screenshot(path=f"{OUT}/r8-13-after-e.png")
        print("ERRORS:", errors)
        await browser.close()

asyncio.run(main())
