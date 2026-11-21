"""Probe tam vong 15: click vao GIUA nhan Co Tu co di chuyen khong?
So sanh voi click diem trong (200,750) da biet chay o vong 14.
Doc nhan debug (24,200) qua anh chup de biet o hien tai.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8167/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass15"


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(25000)
    try:
        await page.get_by_text("BẮT ĐẦU CHƠI").click(timeout=5000)
    except Exception:
        await page.mouse.click(360, 1060)
    await page.wait_for_timeout(6000)


async def dbg(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png",
                          clip={"x": 0, "y": 180, "width": 480, "height": 100})


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
        # 1. Diem trong (200,750) — doi chieu.
        await start_game(page)
        await page.mouse.click(200, 750)
        await page.wait_for_timeout(5000)
        await dbg(page, "r15-probe-clear")
        # 2. Giua nhan Co Tu (480,879) — page moi.
        await start_game(page)
        await page.mouse.click(480, 879)
        await page.wait_for_timeout(5000)
        await dbg(page, "r15-probe-on-label")
        print("ERRORS:", len(errors))
        for e in errors[:10]:
            print(" -", e[:200])
        await browser.close()


asyncio.run(main())
