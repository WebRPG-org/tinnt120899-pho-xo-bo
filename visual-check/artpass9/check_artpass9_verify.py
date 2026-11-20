"""Vong 9 — verify ban staging MOI (loader cung) tren Chromium local,
viewport 1920x1000. Kiem: nut BAT DAU bat <20s, vao game, giu D +
tap D di duoc, tap-to-move, F doi khung, P dien thoai, 0 failed.
Dung: python3 check_artpass9_verify.py [url] [outdir]"""
import asyncio, sys, time
from playwright.async_api import async_playwright

URL = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8164/index.html"
OUT = sys.argv[2] if len(sys.argv) > 2 else "/home/hatch/workspace/pho-xo-bo/visual-check/artpass9"

async def main():
    t0 = time.time()
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=[
            "--no-sandbox", "--disable-dev-shm-usage",
            "--use-gl=angle", "--use-angle=swiftshader",
            "--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width": 1920, "height": 1000})
        errors, failed = [], []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type == "error" else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        page.on("requestfailed", lambda r: failed.append(f"FAILED {r.url} :: {r.failure}"))
        page.on("response", lambda r: failed.append(f"HTTP {r.status} :: {r.url}") if r.status >= 400 else None)
        await page.goto(URL, wait_until="load", timeout=120000)
        await page.screenshot(path=f"{OUT}/a9-01-title.png")
        try:
            await page.wait_for_selector("#start-btn:not([disabled])", timeout=120000)
            print(f"nut BAT DAU bat sau {time.time()-t0:.1f}s")
        except Exception:
            st = await page.evaluate("() => { const b = document.getElementById('start-btn'); return {btn: b && b.textContent, notice: (document.getElementById('status-notice')||{}).textContent}; }")
            print(f"nut KHONG bat sau {time.time()-t0:.1f}s:", st)
            await browser.close(); return
        box = await page.evaluate("() => { const c = document.getElementById('canvas').getBoundingClientRect(); return {x: c.x, y: c.y, w: c.width, h: c.height}; }")
        print("canvas box:", box)
        await page.click("#start-btn")
        await page.wait_for_timeout(6000)
        await page.screenshot(path=f"{OUT}/a9-02-spawn.png")
        await page.mouse.click(960, 500)
        await page.keyboard.down("d")
        await page.wait_for_timeout(3000)
        await page.keyboard.up("d")
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/a9-03-after-hold-d.png")
        for _ in range(10):
            await page.keyboard.press("d")
            await page.wait_for_timeout(250)
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/a9-04-after-10-taps-d.png")
        await page.mouse.click(1150, 750)
        await page.wait_for_timeout(5000)
        await page.screenshot(path=f"{OUT}/a9-05-after-tap-move.png")
        for name in ["chieu", "toi"]:
            await page.keyboard.press("f")
            await page.wait_for_timeout(2500)
            await page.screenshot(path=f"{OUT}/a9-06-frame-{name}.png")
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/a9-07-phone.png")
        await page.keyboard.press("p")
        print("ERRORS:", len(errors))
        for e in errors[:10]: print(" -", e[:250])
        print("FAILED REQUESTS:", len(failed))
        for f in failed[:10]: print(" -", f[:250])
        await browser.close()

asyncio.run(main())
