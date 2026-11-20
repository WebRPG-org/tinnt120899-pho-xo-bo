import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8162/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=["--no-sandbox","--disable-dev-shm-usage","--use-gl=angle","--use-angle=swiftshader","--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width":720,"height":1280})
        errors = []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        await page.goto(URL, wait_until="load", timeout=120000)
        await page.wait_for_timeout(20000)
        await page.screenshot(path=f"{OUT}/stage-01-loading.png")
        # Godot canvas: click center to start (engine start button is inside canvas)
        await page.mouse.click(360, 640)
        await page.wait_for_timeout(8000)
        await page.screenshot(path=f"{OUT}/stage-02-map.png")
        for key in ["d","d","s"]:
            await page.keyboard.down(key)
            await page.wait_for_timeout(700)
            await page.keyboard.up(key)
            await page.wait_for_timeout(200)
        await page.screenshot(path=f"{OUT}/stage-03-moved.png")
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/stage-04-phone.png")
        print("ERRORS:", len(errors))
        for e in errors[:15]:
            print(" -", e[:200])
        await browser.close()

asyncio.run(main())
