#!/usr/bin/env python3
"""Browser-verify artpass4 (G4 buoc 4) bang Chromium that.

Chup: Sang spawn, di sang phai toi khu TAP HOA (kiem duong noi doc),
Toi ngay sau khi bam F (toast co de mat troi/trang khong) + Toi sau
khi toast tan (nhan vat co toi theo khong, sao co ro khong),
Chieu, dien thoai (P). Ghi console/pageerror.
"""
import json
from pathlib import Path

from playwright.sync_api import sync_playwright

URL = "http://127.0.0.1:8166/"
OUT = Path("/home/hatch/workspace/pho-xo-bo/visual-check/artpass4")
OUT.mkdir(parents=True, exist_ok=True)
CHROME = "/home/hatch/.cache/ms-playwright/chromium-1255/chrome-linux64/chrome"

log = {"url": URL, "console": [], "pageerrors": [], "steps": []}


def step(name, ok, detail=""):
    log["steps"].append({"name": name, "ok": bool(ok), "detail": str(detail)[:500]})
    print(f"[{'OK' if ok else 'FAIL'}] {name} {detail}")


def main():
    with sync_playwright() as pw:
        browser = pw.chromium.launch(
            executable_path=CHROME,
            headless=True,
            args=[
                "--no-sandbox",
                "--disable-dev-shm-usage",
                "--enable-unsafe-swiftshader",
                "--use-angle=swiftshader",
                "--disable-gpu-sandbox",
            ],
        )
        page = browser.new_page(viewport={"width": 720, "height": 1280})
        page.on("console", lambda m: log["console"].append(f"{m.type}: {m.text}"[:500]))
        page.on("pageerror", lambda e: log["pageerrors"].append(str(e)[:500]))

        page.goto(URL, wait_until="load", timeout=60000)
        page.wait_for_selector("#canvas", timeout=30000)
        started = False
        for _i in range(24):
            page.wait_for_timeout(5000)
            started = page.evaluate(
                "() => { const c = document.querySelector('#canvas');"
                " return c && c.width > 100; }")
            if started:
                break
        step("engine-start", started)

        started_game = False
        for attempt in range(3):
            try:
                page.wait_for_selector("#start-btn:not([disabled])", timeout=120000)
            except Exception as e:
                step("start-btn-enabled", False, str(e)[:200])
                break
            page.click("#start-btn")
            page.wait_for_timeout(5000)
            started_game = page.evaluate(
                "() => { const o = document.querySelector('#start-overlay');"
                " return window.__pxb_start === true && (!o || o.style.display === 'none' || getComputedStyle(o).display === 'none'); }")
            if started_game:
                break
            page.wait_for_timeout(5000)
        step("start-pressed", started_game)
        page.wait_for_timeout(3000)
        page.screenshot(path=str(OUT / "ap4-01-sang-spawn.png"))

        # Di sang phai toi khu TAP HOA: giu D ~8s wall (~8-10 o game).
        page.keyboard.down("d")
        page.wait_for_timeout(8000)
        page.keyboard.up("d")
        page.wait_for_timeout(3000)
        page.screenshot(path=str(OUT / "ap4-02-sang-taphoa.png"))

        # Quay lai trai ve gan spawn roi bam F: Sang -> Chieu -> Toi.
        page.keyboard.down("a")
        page.wait_for_timeout(8000)
        page.keyboard.up("a")
        page.wait_for_timeout(2000)
        page.keyboard.press("f")  # -> Chieu
        page.wait_for_timeout(3000)
        page.screenshot(path=str(OUT / "ap4-03-chieu.png"))
        page.keyboard.press("f")  # -> Toi (toast vua hien)
        page.wait_for_timeout(1200)
        page.screenshot(path=str(OUT / "ap4-04-toi-toast.png"))
        page.wait_for_timeout(8000)  # cho toast tan
        page.screenshot(path=str(OUT / "ap4-05-toi.png"))

        # Mo dien thoai (P) o khung Toi.
        page.keyboard.press("p")
        page.wait_for_timeout(3000)
        page.screenshot(path=str(OUT / "ap4-06-phone.png"))
        page.keyboard.press("p")
        page.wait_for_timeout(2000)

        errors = [c for c in log["console"] if c.startswith("error")]
        step("console-errors-0", len(errors) == 0, f"{len(errors)} errors")
        step("pageerrors-0", len(log["pageerrors"]) == 0, f"{len(log['pageerrors'])} pageerrors")
        (OUT / "console-artpass4.json").write_text(
            json.dumps(log, ensure_ascii=False, indent=1), encoding="utf-8")
        browser.close()


if __name__ == "__main__":
    main()
