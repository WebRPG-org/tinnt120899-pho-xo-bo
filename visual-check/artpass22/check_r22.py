"""Vong 22 — kiem NPC walk cycle + patrol tren build local.

- Spawn Sang Map001: Co Tu + Ban Than dung o nha, nhan hien.
- Nguoi choi di xa ve (1,1) (cach Co Tu 12 o, Ban Than 6 o):
  sau 12s NPC phai buoc ra khoi o nha (patrol 4-9s nghi + 0.30s/o).
- Nguoi choi ve (4,6) (cach nha Co Tu 4 o): NPC phai ve nha.
- 0 console error / pageerror / requestfailed.
"""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8176/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass22"


async def shot(page, name):
    await page.screenshot(path=f"{OUT}/{name}.png")


async def start_game(page):
    """Tra ve 'dom' neu bam nut DOM (nguoi choi o spawn (4,5)),
    'canvas' neu phai bam canvas (nguoi choi di toi (6,7))."""
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


async def walk(page, keys):
    # Moi phim = 1 o; FPS thap (swiftshader) nen cho 1.5s/buoc.
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
        how = await start_game(page)
        await shot(page, "r22-01-m1-home")
        # Di xa: tu spawn (4,5) len (4,1) roi sang trai ve (1,1).
        # Neu start bang canvas thi spawn (6,7): len 6, trai 5.
        keys_far = (["ArrowUp"] * 4 + ["ArrowLeft"] * 3
                    if how == "dom" else ["ArrowUp"] * 6 + ["ArrowLeft"] * 5)
        await walk(page, keys_far)
        # Cho patrol: nghi ngau nhien 4-9s + buoc 0.30s; lay 12s.
        await page.wait_for_timeout(12000)
        await shot(page, "r22-02-m1-away")
        # Ve gan: xuong (1,5), sang (2,5), xuong (2,6), sang (4,6)
        # — cach nha Co Tu (8,6) 4 o nen NPC phai ve nha. Ca 2
        # cach start deu ket o (1,1) nen duong ve giong nhau.
        keys_back = (["ArrowDown"] * 4 + ["ArrowRight",
                     "ArrowDown", "ArrowRight", "ArrowRight"])
        await walk(page, keys_back)
        await page.wait_for_timeout(3000)
        await shot(page, "r22-03-m1-back")
        print("ERRORS:", errors if errors else "none", flush=True)
        await browser.close()


asyncio.run(main())
