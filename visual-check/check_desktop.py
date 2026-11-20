import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        b = await p.chromium.launch(args=["--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--no-sandbox"])
        pg = await b.new_page(viewport={"width": 1920, "height": 1080})
        errs = []
        pg.on("pageerror", lambda e: errs.append(str(e)))
        await pg.goto("http://127.0.0.1:8161/index.html")
        await pg.wait_for_timeout(30000)
        # Nut Bat dau o chinh giua game (360,640) trong 720x1280 ->
        # giua canvas; click theo bounding rect chu khong doan toa do.
        r = await pg.evaluate("() => { const c = document.getElementById('canvas').getBoundingClientRect(); return [c.x, c.y, c.width, c.height]; }")
        cx = r[0] + r[2] * 0.5
        cy = r[1] + r[3] * 0.5
        await pg.mouse.click(cx, cy)
        await pg.wait_for_timeout(3000)
        await pg.screenshot(path="after-desktop-1920.png")
        print("ERRORS:", len(errs), errs[:3], "clicked:", round(cx), round(cy))
        await b.close()

asyncio.run(main())
