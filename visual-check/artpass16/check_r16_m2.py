"""Vong 16 — bu sung: vao Map002 bang cua (5,4) tu spawn (4,5): len + phai."""
import asyncio
from playwright.async_api import async_playwright

URL = "http://127.0.0.1:8171/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass16"


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
        await page.goto(URL, wait_until="load", timeout=120000)
        await page.wait_for_timeout(30000)
        try:
            await page.get_by_text("BẮT ĐẦU CHƠI").click(timeout=5000)
        except Exception:
            await page.mouse.click(360, 1060)
        await page.wait_for_timeout(6000)
        await page.keyboard.press("ArrowUp")
        await page.wait_for_timeout(1500)
        await page.keyboard.press("ArrowRight")
        await page.wait_for_timeout(2500)
        await page.screenshot(path=f"{OUT}/r16-05-m2-arrival.png")
        print("ERRORS:", len(errors))
        for e in errors[:10]:
            print(" -", e[:200])
        await browser.close()


asyncio.run(main())
