"""Probe tam vong 15 (lan 2): cau truc Y HET check_r14b (chup truoc
click, chup +800ms, chup +4800ms) cho diem (200,750) tren build moi.
Neu A:(1,1) hien o +800ms thi tap van chay — lan probe truoc la flake.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8167/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass15"


async def dbg(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png",
                          clip={"x": 0, "y": 180, "width": 480, "height": 100})
    await page.screenshot(path=f"{OUT}/{name}-full.png")


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(25000)
    try:
        await page.get_by_text("BẮT ĐẦU CHƠI").click(timeout=5000)
        print("start: DOM button clicked", flush=True)
    except Exception:
        await page.mouse.click(360, 1060)
        print("start: canvas button click (360,1060)", flush=True)
    await page.wait_for_timeout(6000)


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
        await start_game(page)
        await dbg(page, "r15-probe3-01-spawn")
        await page.mouse.click(480, 879)
        await page.wait_for_timeout(800)
        await dbg(page, "r15-probe3-02-registered")
        await page.wait_for_timeout(4000)
        await dbg(page, "r15-probe3-03-walked")
        print("ERRORS:", len(errors))
        for e in errors[:10]:
            print(" -", e[:200])
        await browser.close()


asyncio.run(main())
