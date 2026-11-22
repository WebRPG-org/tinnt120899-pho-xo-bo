"""Vong 18 — kiem walk cycle 6 khung nguoi choi tren build local (cong 8173).

- Spawn Sang: nguoi choi dung yen = frame 0 (tu the dung).
- Giu D: chup 2 anh giua luc buoc (khung chan phai khac nhau, khac
  anh dung yen); tha phim: ve frame 0 sau khi dung.
- F x2 -> Toi + sang Map002: khong hoi quy.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8173/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass18"


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
        await shot(page, "r18-01-m1-idle")
        # Giu D de di + chup giua luc buoc (game swiftshader chay
        # cham ~0.22x nen giu 600ms wall ~ 0.13s game < 1 o 0.15s:
        # van dang tween, khung chan giua chu trinh).
        await page.keyboard.down("d")
        await page.wait_for_timeout(600)
        await shot(page, "r18-02-m1-walk-a")
        await page.wait_for_timeout(600)
        await shot(page, "r18-03-m1-walk-b")
        await page.keyboard.up("d")
        await page.wait_for_timeout(2000)
        await shot(page, "r18-04-m1-stopped")
        # F x2 -> Toi, roi ve Sang + sang Map002 (khong hoi quy).
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("f")
        await page.wait_for_timeout(2000)
        await shot(page, "r18-05-m1-night")
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(2000)
        await shot(page, "r18-06-m2-arrival")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
