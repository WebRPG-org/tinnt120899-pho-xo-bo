"""Vong 17 — kiem ban export moi (mat troi Sang sang phai + sao dem neo camera)
tren build local (cong 8172).

- Map001 spawn Sang: mat troi o ben PHAI khung (tren tuong tang tren),
  khong de len mai hien trai / bien PHO BO.
- F x2 -> Toi: sao dem o dai hep ngay duoi HUD, khong roi len mai
  hien/bien hieu; trang van thay.
- Ve Sang + sang Map002 bang cua (5,4): khong hoi quy.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8172/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass17"


async def shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(30000)
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
        page.on("requestfailed", lambda r: errors.append(f"reqfail: {r.url[:120]}"))
        await start_game(page)
        await shot(page, "r17-01-m1-spawn-sun")
        # F x2 -> Toi: sao dem + trang.
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("f")
        await page.wait_for_timeout(2000)
        await shot(page, "r17-02-m1-night-stars")
        # Ve Sang (F) roi sang Map002 bang cua (5,4): phai 1 + len 1.
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(2000)
        await shot(page, "r17-03-m2-arrival")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
