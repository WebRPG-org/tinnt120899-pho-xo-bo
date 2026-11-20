"""Vong 8 — TAI HIEN loi live: chay DUNG ban gh-pages-staging (co chunk
loader) tren Chromium local, viewport 1920x1000 (dung nhu kiem live).
Ghi: console error, pageerror, request that bai, thoi gian nut BAT DAU
enable, anh truoc/sau khi giu D, sau khi bam F, sau khi bam P.
So sanh voi ban raw export (src/godot-build, khong loader) o cung
viewport neu staging loi.
"""
import asyncio, sys
from playwright.async_api import async_playwright

URL = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8162/index.html"
OUT = "/home/hatch/workspace/pho-xo-bo/visual-check/artpass8"

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=[
            "--no-sandbox", "--disable-dev-shm-usage",
            "--use-gl=angle", "--use-angle=swiftshader",
            "--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width": 1920, "height": 1000})
        errors, failed = [], []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type in ("error", "warning") else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        page.on("requestfailed", lambda r: failed.append(f"{r.url} :: {r.failure}"))
        page.on("response", lambda r: failed.append(f"HTTP {r.status} :: {r.url}") if r.status >= 400 else None)
        t0 = asyncio.get_event_loop().time()
        await page.goto(URL, wait_until="load", timeout=120000)
        print("page loaded in %.1fs" % (asyncio.get_event_loop().time() - t0))
        # Doi nut enable, ghi lai nhan nut theo thoi gian.
        btn_texts = []
        for i in range(24):
            try:
                t = await page.text_content("#start-btn", timeout=2000)
                d = await page.get_attribute("#start-btn", "disabled")
                btn_texts.append(f"{i*5}s: disabled={d} text={t!r}")
                if d is None:
                    break
            except Exception as e:
                btn_texts.append(f"{i*5}s: ERR {e}")
            await page.wait_for_timeout(5000)
        print("\n".join(btn_texts))
        await page.screenshot(path=f"{OUT}/r8-01-title.png")
        await page.click("#start-btn")
        await page.wait_for_timeout(6000)
        await page.screenshot(path=f"{OUT}/r8-02-spawn.png")
        # Focus canvas roi giu D 3s.
        await page.mouse.click(960, 500)
        await page.wait_for_timeout(500)
        await page.keyboard.down("d")
        await page.wait_for_timeout(3000)
        await page.keyboard.up("d")
        await page.wait_for_timeout(1200)
        await page.screenshot(path=f"{OUT}/r8-03-after-hold-d.png")
        # Tap-to-move: click vao dat ben phai.
        await page.mouse.click(1400, 700)
        await page.wait_for_timeout(4000)
        await page.screenshot(path=f"{OUT}/r8-04-after-tap.png")
        # F doi khung, P mo dien thoai.
        await page.keyboard.press("f")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/r8-05-frame-chieu.png")
        await page.keyboard.press("p")
        await page.wait_for_timeout(2000)
        await page.screenshot(path=f"{OUT}/r8-06-phone.png")
        await page.keyboard.press("p")
        await page.wait_for_timeout(1000)
        # Trang thai focus + activeElement luc cuoi.
        ae = await page.evaluate("() => ({ae: document.activeElement && document.activeElement.id, aeTag: document.activeElement && document.activeElement.tagName})")
        print("activeElement:", ae)
        print("ERRORS:", len(errors))
        for e in errors[:20]:
            print(" -", e[:300])
        print("FAILED REQUESTS:", len(failed))
        for f in failed[:20]:
            print(" -", f[:300])
        await browser.close()

asyncio.run(main())
