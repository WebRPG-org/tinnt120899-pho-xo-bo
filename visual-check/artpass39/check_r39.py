"""Vong 39 — kiem NPC Map017 (Co Ban Banh + Ong Lao Tap The Duc) walk cycle tren build local.

- Map017: Co Ban Banh (3,3) + Ong Lao Tap The Duc (8,6)
  phai hien bang anh that (ao ba ba hong dao + tap de xanh la +
  non la, cam gio banh + khay banh / toc bac, ao thun xanh nhat +
  quan the thao xam, khan tap vang cam + binh nuoc xanh),
  khong phai ve code.

- Spawn Map001 -> cua (5,4) sang Map002 -> cua (5,8) sang Map003
  -> cua (5,8) sang Map004 -> cua (5,8) sang Map005
  -> cua (5,8) sang Map006 -> cua (5,8) sang Map007.
  -> cua (5,8) sang Map008 -> cua (5,8) sang Map009
  -> cua (5,8) sang Map010 -> cua (5,8) sang Map011
  -> cua (5,8) sang Map012 -> cua (5,8) sang Map013
  -> cua (5,8) sang Map014 -> cua (5,8) sang Map015
  -> cua (5,8) sang Map016
  -> cua (5,8) sang Map017.
- Nguoi choi di xa ve (10,1) (cach ca 2 nha >5 o — nguong patrol):
  sau 12s NPC phai buoc ra khoi o nha (patrol 4-9s nghi + 0.30s/o,
  walk cycle doi khung).
- Pixel-diff 2 anh Map017 cach nhau 2s > 0 (NPC bob/buoc + khoi/la dong).
- 0 console error / pageerror / requestfailed.
"""
import asyncio
from PIL import Image
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8194/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass39"


async def shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    # Doi nut DOM enable (engine tai xong) toi da 150s — pck nay ~21 MB.
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
        await shot(page, "r39-01-map2")
        # Map002 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map003.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-02-map3")
        # Map003 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map004.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-03-map4")
        # Map004 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map005.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-04-map5")
        # Map005 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map006.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-05-map6")
        # Map006 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map007.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-06-map7")
        # Map007 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map008.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-07-map8")
        # Map008 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map009.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-08-map9")
        # Map009 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map010.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-09-map10")
        # Map010 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map011.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-10-map11")
        # Map011 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map012.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-11-map12")
        # Map012 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map013.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-12-map13")
        # Map013 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map014.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-13-map14-home")
        # Map014 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map015.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-14-map15-home")
        # Map015 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map016.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-15-map16-home")
        # Map016 spawn o cua (5,4) -> xuong x4 toi (5,8) = cua sang Map017.
        await walk(page, ["ArrowDown"] * 4)
        await page.wait_for_timeout(2000)
        await shot(page, "r39-16-map17-home")
        # Di xa: phai x5 + len x3 ve (10,1), cach ca 2 nha >5 o.
        await walk(page, ["ArrowRight"] * 5 + ["ArrowUp"] * 3)
        await page.wait_for_timeout(12000)
        await shot(page, "r39-17-map17-away")
        await page.wait_for_timeout(2000)
        await shot(page, "r39-18-map17-away2")
        print("pixel-diff away shots:", pixel_diff(f"{OUT}/r39-17-map17-away.png", f"{OUT}/r39-18-map17-away2.png"), flush=True)
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
