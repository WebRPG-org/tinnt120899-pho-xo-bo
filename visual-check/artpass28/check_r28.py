"""Vong 28 — kiem NPC Map006 (Cu Dan Chung Cu + Bac Quan Ly) walk cycle tren build local.

- Spawn Map001 -> cua (5,4) sang Map002 -> cua (5,8) sang Map003
  -> cua (5,8) sang Map004 -> cua (5,8) sang Map005
  -> cua (5,8) sang Map006.
- Map006: Cu Dan Chung Cu (3,6) + Bac Quan Ly (8,3) phai hien bang anh that
  (ao thun xam / ao so mi xanh nhat, toc bac), khong phai ve code.
- Nguoi choi di xa ve (10,1) (cach ca 2 nha >5 o — nguong patrol):
  sau 12s NPC phai buoc ra khoi o nha (patrol 4-9s nghi + 0.30s/o,
  walk cycle doi khung).
- Pixel-diff 2 anh Map006 cach nhau 2s > 0 (NPC bob/buoc + khoi/la dong).
- 0 console error / pageerror / requestfailed.
"""
import asyncio
from PIL import Image
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8182/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass28"


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


def pixel_diff(a, b):
    ia = Image.open(a).convert("RGB")
    ib = Image.open(b).convert("RGB")
    if ia.size != ib.size:
        return -1
    pa = list(ia.getdata())
    pb = list(ib.getdata())
    return sum(1 for x, y in zip(pa, pb) if x != y)


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
        await shot(page, "r28-01-map2")
        # Map002 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map003.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r28-02-map3")
        # Map003 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map004.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r28-03-map4")
        # Map004 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map005.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r28-04-map5")
        # Map005 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map006.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r28-05-map6-home")
        # Di xa: phai x5 + len x3 ve (10,1), cach ca 2 nha >5 o.
        await walk(page, ["ArrowRight"] * 5 + ["ArrowUp"] * 3)
        await page.wait_for_timeout(12000)
        await shot(page, "r28-06-map6-away")
        await page.wait_for_timeout(2000)
        await shot(page, "r28-07-map6-away2")
        print("pixel-diff away shots:", pixel_diff(f"{OUT}/r28-06-map6-away.png", f"{OUT}/r28-07-map6-away2.png"), flush=True)
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
