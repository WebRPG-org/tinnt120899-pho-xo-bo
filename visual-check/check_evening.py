import asyncio
from playwright.async_api import async_playwright
URL = "http://127.0.0.1:8161/index.html"
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
        await page.mouse.click(360, 740)
        await page.wait_for_timeout(6000)
        await page.keyboard.press("f")  # Sang -> Chieu
        await page.wait_for_timeout(1500)
        await page.screenshot(path=f"{OUT}/after-05-chieu.png")
        await page.keyboard.press("f")  # Chieu -> Toi
        await page.wait_for_timeout(1500)
        await page.screenshot(path=f"{OUT}/after-06-toi.png")
        print("ERRORS:", len(errors))
        for e in errors[:10]:
            print(" -", e[:200])
        await browser.close()
asyncio.run(main())
