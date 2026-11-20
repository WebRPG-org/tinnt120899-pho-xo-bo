"""Vong 9 — repro/verify tai game tren URL LIVE that (khong phai staging).
Mo https://tinnt120899.github.io/pho-xo-bo/, ghi console/network,
poll nut start 75s, chup anh, bao cao nut co bat khong + tien do.
Dung: python3 check_live_load.py [url] [outdir] [wait_s]"""
import asyncio, sys, time
from playwright.async_api import async_playwright

URL = sys.argv[1] if len(sys.argv) > 1 else "https://tinnt120899.github.io/pho-xo-bo/"
OUT = sys.argv[2] if len(sys.argv) > 2 else "/home/hatch/workspace/pho-xo-bo/visual-check/artpass9"
WAIT = int(sys.argv[3]) if len(sys.argv) > 3 else 75

async def main():
    t0 = time.time()
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True, args=[
            "--no-sandbox", "--disable-dev-shm-usage",
            "--use-gl=angle", "--use-angle=swiftshader",
            "--enable-unsafe-swiftshader"])
        page = await browser.new_page(viewport={"width": 1920, "height": 1000})
        errors, failed = [], []
        page.on("console", lambda m: errors.append(f"console.{m.type}: {m.text}") if m.type in ("error", "warning") else None)
        page.on("pageerror", lambda e: errors.append(f"pageerror: {e}"))
        page.on("requestfailed", lambda r: failed.append(f"FAILED {r.url} :: {r.failure}"))
        page.on("response", lambda r: failed.append(f"HTTP {r.status} :: {r.url}") if r.status >= 400 else None)
        try:
            await page.goto(URL, wait_until="load", timeout=60000)
        except Exception as e:
            print(f"GOTO FAILED after {time.time()-t0:.1f}s: {e}")
        for i in range(0, WAIT, 5):
            await page.wait_for_timeout(5000)
            try:
                st = await page.evaluate("""() => { const b = document.getElementById('start-btn'); const pr = document.getElementById('status-progress'); return {btn: b ? b.textContent : null, disabled: b ? b.disabled : null, prog: pr ? (pr.value + '/' + pr.max) : null, notice: (document.getElementById('status-notice')||{}).textContent || ''}; }""")
            except Exception as e:
                st = {"eval_error": str(e)}
            print(f"t+{time.time()-t0:5.1f}s {st}")
        await page.screenshot(path=f"{OUT}/live-title.png")
        print("ERRORS:", len(errors))
        for e in errors[:20]: print(" -", e[:300])
        print("FAILED REQUESTS:", len(failed))
        for f in failed[:20]: print(" -", f[:300])
        await browser.close()

asyncio.run(main())
