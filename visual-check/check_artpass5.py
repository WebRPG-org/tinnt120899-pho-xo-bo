#!/usr/bin/env python3
"""Di chuyen bang click-to-move (tinh nang game): click vao dat phia phai
nhieu lan, chup anh o khu TAP HOA ca 3 khung + dien thoai."""
import json
from pathlib import Path
from playwright.sync_api import sync_playwright

URL = "http://127.0.0.1:8168/"
OUT = Path("/home/hatch/workspace/pho-xo-bo/visual-check/artpass5")
CHROME = "/home/hatch/.cache/ms-playwright/chromium-1255/chrome-linux64/chrome"
log = {"console": [], "pageerrors": [], "steps": []}

def step(name, ok, detail=""):
    log["steps"].append({"name": name, "ok": bool(ok), "detail": str(detail)[:500]})
    print(f"[{'OK' if ok else 'FAIL'}] {name} {detail}")

def brightness(page):
    return page.evaluate("""() => {
      const c = document.querySelector('#canvas');
      const x = document.createElement('canvas');
      x.width = c.width; x.height = c.height;
      const ctx = x.getContext('2d');
      ctx.drawImage(c, 0, 0);
      function mean(x0, y0, x1, y1) {
        const d = ctx.getImageData(x0, y0, x1 - x0, y1 - y0).data;
        let s = 0, n = 0;
        for (let i = 0; i < d.length; i += 16) { s += d[i] + d[i+1] + d[i+2]; n++; }
        return Math.round(s / n / 3);
      }
      const W = c.width, H = c.height;
      return {
        facade_left: mean(0, Math.round(H*0.25), Math.round(W/3), Math.round(H*0.5)),
        facade_right: mean(Math.round(W*2/3), Math.round(H*0.25), W, Math.round(H*0.5)),
        ground_left: mean(0, Math.round(H*0.72), Math.round(W/3), Math.round(H*0.88)),
        ground_right: mean(Math.round(W*2/3), Math.round(H*0.72), W, Math.round(H*0.88)),
      };
    }""")

with sync_playwright() as pw:
    browser = pw.chromium.launch(executable_path=CHROME, headless=True,
        args=["--no-sandbox", "--disable-dev-shm-usage",
              "--enable-unsafe-swiftshader", "--use-angle=swiftshader",
              "--disable-gpu-sandbox"])
    page = browser.new_page(viewport={"width": 720, "height": 1280})
    page.on("console", lambda m: log["console"].append(f"{m.type}: {m.text}"[:300]))
    page.on("pageerror", lambda e: log["pageerrors"].append(str(e)[:300]))
    page.goto(URL, wait_until="load", timeout=60000)
    page.wait_for_selector("#canvas", timeout=30000)
    for _ in range(24):
        page.wait_for_timeout(5000)
        if page.evaluate("() => { const c = document.querySelector('#canvas'); return c && c.width > 100; }"):
            break
    page.wait_for_selector("#start-btn:not([disabled])", timeout=120000)
    page.click("#start-btn")
    page.wait_for_timeout(5000)
    # Click-to-move sang phai: click vao dat ben phai man hinh, lap lai.
    for i in range(4):
        page.mouse.click(660, 1000)
        page.wait_for_timeout(4000)
    page.wait_for_timeout(2000)
    page.screenshot(path=str(OUT / "v5c-01-sang-taphoa.png"))
    b = brightness(page); print("SANG:", b)
    step("sang-split", abs(b["facade_left"] - b["facade_right"]) < 25 and abs(b["ground_left"] - b["ground_right"]) < 30,
         f"facade L={b['facade_left']} R={b['facade_right']} ground L={b['ground_left']} R={b['ground_right']}")
    page.keyboard.press("f"); page.wait_for_timeout(3000)
    page.screenshot(path=str(OUT / "v5c-02-chieu-taphoa.png"))
    b = brightness(page); print("CHIEU:", b)
    step("chieu-split", abs(b["facade_left"] - b["facade_right"]) < 25 and abs(b["ground_left"] - b["ground_right"]) < 30,
         f"facade L={b['facade_left']} R={b['facade_right']} ground L={b['ground_left']} R={b['ground_right']}")
    page.keyboard.press("f"); page.wait_for_timeout(1200)
    page.screenshot(path=str(OUT / "v5c-03-toi-toast.png"))
    page.wait_for_timeout(8000)
    page.screenshot(path=str(OUT / "v5c-04-toi-taphoa.png"))
    b = brightness(page); print("TOI:", b)
    step("toi-split", abs(b["facade_left"] - b["facade_right"]) < 25 and abs(b["ground_left"] - b["ground_right"]) < 30,
         f"facade L={b['facade_left']} R={b['facade_right']} ground L={b['ground_left']} R={b['ground_right']}")
    # Ve spawn bang click ben trai.
    for i in range(4):
        page.mouse.click(60, 1000)
        page.wait_for_timeout(4000)
    page.wait_for_timeout(2000)
    page.screenshot(path=str(OUT / "v5c-05-toi-spawn.png"))
    page.keyboard.press("p"); page.wait_for_timeout(3000)
    page.screenshot(path=str(OUT / "v5c-06-phone.png"))
    browser.close()
errors = [c for c in log["console"] if c.startswith("error")]
step("console-errors-0", len(errors) == 0, f"{len(errors)} errors")
step("pageerrors-0", len(log["pageerrors"]) == 0, f"{len(log['pageerrors'])}")
(OUT / "console-v5c.json").write_text(json.dumps(log, ensure_ascii=False, indent=1), encoding="utf-8")
print("DONE")
