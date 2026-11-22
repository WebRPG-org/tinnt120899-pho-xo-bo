"""Vong 20 — kiem dat ve tay Map002 tren build local (cong 8175).

- Spawn Sang Map001: dat ve tay ground_map001 nhu cu.
- Sang Map002 (cua (5,8)): dat ve tay ground_map002 — san cho
  (xi mang loang lo, vung nuoc, la rau) thay anh chup ground_wide.
- Ve Map001: dat lai ground_map001, khong hoi quy.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8175/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass20"


async def shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    """Tra ve 'dom' neu bam nut DOM (nguoi choi o spawn (4,5)),
    'canvas' neu phai bam canvas (click cham thanh tap, nguoi
    choi di toi (6,7))."""
    await page.goto(URL, wait_until="load", timeout=120000)
    await page.wait_for_timeout(45000)
    for _ in range(3):
        try:
            await page.get_by_text("BẮT ĐẦU CHƠI").click(timeout=10000)
            print("start: DOM button clicked", flush=True)
            await page.wait_for_timeout(6000)
            return "dom"
        except Exception:
            await page.wait_for_timeout(10000)
    await page.mouse.click(360, 1060)
    print("start: canvas button click (360,1060)", flush=True)
    await page.wait_for_timeout(6000)
    return "canvas"


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
        how = await start_game(page)
        await shot(page, "r20-01-m1-day")
        # Sang Map002: cua Map001->Map002 o (5,4) (KHONG phai (5,8)
        # — (5,8) la cua di Map003 o Map002 tro di). Tu spawn (4,5)
        # di Phai, Len; tu (6,7) (click canvas) di Trai, Len x3.
        # Moi phim = 1 o; nhan cua noi tren man hinh khong chi dung
        # vi tri o (nhan noi cao), nen dung so lieu maps.json.
        keys = (["ArrowRight", "ArrowUp"]
                if how == "dom" else ["ArrowLeft", "ArrowUp", "ArrowUp", "ArrowUp"])
        for key in keys:
            await page.keyboard.press(key)
            await page.wait_for_timeout(1500)
        await page.wait_for_timeout(3000)
        await shot(page, "r20-02-m2-day")
        # Ve Map001: tai lai trang (spawn moi) — test headless r20
        # da kiem chuyen map 2 chieu bang load_map.
        await start_game(page)
        await shot(page, "r20-03-m1-back")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
