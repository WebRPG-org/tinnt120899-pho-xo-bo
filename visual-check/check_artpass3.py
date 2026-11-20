import asyncio, hashlib
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8161/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass3"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=["--no-sandbox","--disable-dev-shm-usage","--use-gl=angle","--use-angle=swiftshader","--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width":720,"height":1280})
        errors = []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        await page.goto(URL, wait_until="load", timeout=120000)
        # Doi engine tai xong: nut Bat dau duoc enable (wasm 39MB +
        # swiftshader co the mat >20s).
        await page.wait_for_selector("#start-overlay button:enabled", timeout=120000)
        await page.screenshot(path=f"{OUT}/ap3-00-title.png")
        # Nut co animation (pulse) nen Playwright click doi "stable"
        # mai khong xong — bam bang JS truc tiep.
        await page.evaluate("document.getElementById('start-btn').click()")
        await page.wait_for_timeout(6000)
        await page.screenshot(path=f"{OUT}/ap3-01-sang-spawn.png")
        # WASD: giu D 700ms roi chup — so pixel de chung minh di chuyen.
        before = await page.screenshot(path=f"{OUT}/ap3-02-before-d.png")
        await page.keyboard.down("d")
        await page.wait_for_timeout(700)
        await page.keyboard.up("d")
        await page.wait_for_timeout(500)
        after = await page.screenshot(path=f"{OUT}/ap3-03-after-d.png")
        print("WASD-D moved pixels differ:", hashlib.md5(before).hexdigest() != hashlib.md5(after).hexdigest())
        # Chieu -> Toi.
        await page.keyboard.press("f")
        await page.wait_for_timeout(1500)
        await page.screenshot(path=f"{OUT}/ap3-04-chieu.png")
        await page.keyboard.press("f")
        await page.wait_for_timeout(1500)
        await page.screenshot(path=f"{OUT}/ap3-05-toi.png")
        # Ve Sang, mo dien thoai.
        await page.keyboard.press("f")
        await page.wait_for_timeout(1200)
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/ap3-06-phone.png")
        await page.keyboard.press("p")
        await page.wait_for_timeout(1000)
        print("ERRORS:", len(errors))
        for e in errors[:10]:
            print(" -", e[:200])
        # Desktop 1920x1080: side panels.
        await page.set_viewport_size({"width":1920,"height":1080})
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/ap3-07-desktop.png")
        await browser.close()

asyncio.run(main())
