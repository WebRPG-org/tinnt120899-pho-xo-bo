"""Vong 15 — kiem ban export b6913210 tren build local (cong 8167).

- Map001 spawn: nhan "Ban Than"/"Co Tu" la Label trong the gioi —
  nam sat tren dau NPC (khe ~50px), khong noi cao, tam X trung chan.
- Di phai 3 o (ve phia Co Tu): nhan van di theo NPC (khong troi).
- Map002 (page moi): len cua (5,4) -> nhan "Chi Le"/"Anh Hai" sat
  tren dau; mo dien thoai (P) -> dien thoai mo binh thuong.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8167/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass15"


async def shot(page, name, clip=None):
    kw = {"path": f"{OUT}/{name}.png"}
    if clip:
        kw["clip"] = clip
    await page.screenshot(**kw)


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
        page.on("requestfailed", lambda r: errors.append(f"reqfail: {r.url[:120]}"))
        # --- Map001 spawn: nhan NPC tren dau ---
        await start_game(page)
        await shot(page, "r15-01-m1-spawn")
        # Di phai 3 o (tap-to-move ve phia Co Tu): nhan phai di theo.
        await page.mouse.click(500, 850)
        await page.wait_for_timeout(5000)
        await shot(page, "r15-02-m1-moved-right")
        # --- Map002: page moi, len cua (5,4) ---
        await start_game(page)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(1500)
        await shot(page, "r15-03-m2-arrival")
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await shot(page, "r15-04-m2-phone")
        print("ERRORS:", len(errors))
        for e in errors[:15]:
            print(" -", e[:200])
        await browser.close()


asyncio.run(main())
