"""Vong 19 — kiem anh sang ADD + la roi/dom dom tren build local (cong 8174).

- Spawn Sang: la roi (cham vang-xanh) co trong khung.
- F x2 -> Toi: den long Map001 co hao quang am cong don (ADD, tren
  lop MUL), dom dom + sao; chup dem.
- Ve Sang + sang Map002: khong hoi quy; F x2 -> Toi Map002: halo
  cua so sang (spots) + den long.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8174/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass19"


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
        await shot(page, "r19-01-m1-day")
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("f")
        await page.wait_for_timeout(2500)
        await shot(page, "r19-02-m1-night")
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(2000)
        await shot(page, "r19-03-m2-arrival")
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("f")
        await page.wait_for_timeout(2500)
        await shot(page, "r19-04-m2-night")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
