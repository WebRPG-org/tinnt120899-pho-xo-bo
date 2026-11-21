"""Vong 16 — kiem ban export 34bd6889 (Map001 anh nha ong cao) tren build local (cong 8171).

- Map001 spawn: nha ong cao 4 tang phu kin khung doc, 3 bien hieu
  PHO BO / CA PHE / TAP HOA doc duoc, khong con dai troi trong.
- Di len 4 o (hang tren): mat tien van kin khung, khong ho troi.
- F x2 -> Toi: anh dem (toi + cua so am), trang/sao thay duoc.
- Ve Map002 bang cua (5,4): sky_band + sky_wide nhu cu (khong hoi quy).
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8171/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass16"


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
        # --- Map001 spawn: nha ong cao ---
        await start_game(page)
        await shot(page, "r16-01-m1-spawn")
        # Di len hang tren (4 o len): mat tien van kin khung.
        for _ in range(4):
            await page.keyboard.press("ArrowUp")
            await page.wait_for_timeout(1500)
        await shot(page, "r16-02-m1-top-row")
        # F x2 -> Toi: anh dem.
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("f")
        await page.wait_for_timeout(2000)
        await shot(page, "r16-03-m1-night")
        # Ve Sang (F) roi sang Map002 bang cua (5,4).
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("ArrowDown")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowDown")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(2000)
        await shot(page, "r16-04-m2-arrival")
        print("ERRORS:", len(errors))
        for e in errors[:15]:
            print(" -", e[:200])
        await browser.close()


asyncio.run(main())
