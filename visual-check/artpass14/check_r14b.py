"""Vong 14 — kiem ban export 9d9896a9 tren build local (cong 8166).

- Map001: tap (200,750) ngoai hinh thoi dat -> phai dang ky dich
  (nhan debug A: khac (-1,-1)) va nhan vat di chuyen.
- Map002 (page moi): len cua (5,4) -> xem nhan Anh Hai/Chi Le
  (khe tren dau ~47px, khong noi cao); mo dien thoai (P) -> nhan
  debug phai AN, xem nen mo sau dien thoai la canh Cho (khong
  phai CA PHE Xom Tro Cu).
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8166/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass14"


async def dbg_shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png",
                          clip={"x": 0, "y": 180, "width": 480, "height": 100})
    await page.screenshot(path=f"{OUT}/{name}-full.png")


async def start_game(page):
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(25000)
    # Build tho (src/godot-build) KHONG co web_shell.html nen khong
    # co nut DOM — nut "Bat dau choi" la Button trong canvas Godot,
    # tam ~(360,1060) theo anh title (khong phai (360,740) nhu
    # ban staging co DOM overlay). Click sai toa do thi game mai
    # o title, moi buoc sau vo nghia (vong 14 lan 1).
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
        # --- Map001: tap ngoai hinh thoi ---
        await start_game(page)
        await dbg_shot(page, "r14b-01-m1-spawn")
        await page.mouse.click(200, 750)
        await page.wait_for_timeout(800)
        await dbg_shot(page, "r14b-02-tap-outside-registered")
        await page.wait_for_timeout(4000)
        await dbg_shot(page, "r14b-03-tap-outside-walked")
        # --- Map002: page moi, di len cua ---
        await start_game(page)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(1500)
        await dbg_shot(page, "r14b-04-m2-arrival")
        # Mo dien thoai tren Map002.
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/r14b-05-m2-phone-full.png")
        await page.screenshot(path=f"{OUT}/r14b-05-m2-phone-top.png",
                              clip={"x": 0, "y": 180, "width": 720, "height": 120})
        await page.keyboard.press("p")
        await page.wait_for_timeout(1200)
        await dbg_shot(page, "r14b-06-m2-phone-closed")
        print("ERRORS:", len(errors))
        for e in errors[:15]:
            print(" -", e[:200])
        await browser.close()


asyncio.run(main())
