"""Vong 25 — kiem NPC Map003 (Anh Ba + Chi Sau) walk cycle tren build local.

- Spawn Map001 -> cua (5,4) sang Map002 -> cua (5,8) sang Map003.
- Map003: Anh Ba (4,6) + Chi Sau (8,3) phai hien bang anh that
  (mat/toc/ao xanh duong dam / ao ba ba xanh la), khong phai ve code.
- Nguoi choi di xa ve (4,1): sau 12s NPC phai buoc ra khoi o nha
  (patrol 4-9s nghi + 0.30s/o, walk cycle doi khung).
- Pixel-diff 2 anh Map003 cach nhau 2s > 0 (NPC bob/buoc + khoi/la dong).
- 0 console error / pageerror / requestfailed.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8179/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass25"


async def shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(45000)
    for _ in range(3):
        try:
            await page.get_by_text("BẮT ĐẦU CHƠI").click(timeout=10000)
            print("start: DOM button clicked", flush=True)
            await page.wait_for_timeout(6000)
            return
        except Exception:
            await page.wait_for_timeout(10000)
    await page.mouse.click(360, 1060)
    print("start: canvas button click (360,1060)", flush=True)
    await page.wait_for_timeout(6000)


async def walk(page, keys):
    for key in keys:
        await page.keyboard.press(key)
        await page.wait_for_timeout(1500)


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
        await shot(page, "r25-01-map2")
        # Map002 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map003.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r25-02-map3-home")
        # Di xa: len x4 ve (4,1) (cach Anh Ba 5 o doc) -> cho patrol 12s.
        await walk(page, ["ArrowUp"] * 4)
        await page.wait_for_timeout(12000)
        await shot(page, "r25-03-map3-away")
        await page.wait_for_timeout(2000)
        await shot(page, "r25-04-map3-away2")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
