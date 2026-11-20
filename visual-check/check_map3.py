import asyncio, hashlib
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8162/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/map3"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=["--no-sandbox","--disable-dev-shm-usage","--use-gl=angle","--use-angle=swiftshader","--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width":720,"height":1280})
        errors = []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        await page.goto(URL, wait_until="load", timeout=120000)
        await page.wait_for_selector("#start-overlay button:enabled", timeout=120000)
        await page.evaluate("document.getElementById('start-btn').click()")
        await page.wait_for_timeout(6000)
        await page.screenshot(path=f"{OUT}/map3-01-spawn.png")
        before = await page.screenshot(path=f"{OUT}/map3-02-before-d.png")
        await page.keyboard.down("d")
        await page.wait_for_timeout(700)
        await page.keyboard.up("d")
        await page.wait_for_timeout(500)
        after = await page.screenshot(path=f"{OUT}/map3-03-after-d.png")
        print("WASD-D moved pixels differ:", hashlib.md5(before).hexdigest() != hashlib.md5(after).hexdigest())
        await page.keyboard.press("f")
        await page.wait_for_timeout(1500)
        await page.screenshot(path=f"{OUT}/map3-04-chieu.png")
        print("ERRORS:", len(errors))
        for e in errors[:10]:
            print(" -", e[:200])
        await browser.close()

asyncio.run(main())
