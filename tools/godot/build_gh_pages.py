#!/usr/bin/env python3
"""Build gh-pages staging cho game Godot Phố Xô Bồ.

Snapshot-push (github push-files) giới hạn 188.416 byte/file nên
index.wasm (~39,5 MB) + index.pck (~1,35 MB) phải tách thành chunk
base64 nhỏ, trình duyệt ráp lại qua fetch giả (loader chèn vào
index.html). Script này tái tạo bản deploy 06:12 20/11 (script cũ
nằm ở /tmp, đã mất) và là bản persistent trong repo.

Vong 8 (20/11 17:30) — CHUNK THEO VERSION (sha8 cua noi dung):
kiem live 16:52–17:10 chay BAN TRON (pck cu + moi): di chuyen
chet, day cat ~200px, cua so van cam — trong khi cung pck do chay
local staging thi di chuyen/tap deu duoc. Goc: chunk o URL CO DINH
(wasm/part-000.txt...) — CDN Pages cache tung chunk rieng (max-age
600s), nen ngay sau deploy trinh duyet rap pck tu chunk cu + moi
tron lan (cron 16:45 tu ghi 4 chunk 019–022 lech luc dau). SUA:
moi asset nam trong thu muc version = 8 ky tu dau sha256 cua chinh
no (wasm/<sha8>/, pck/<sha8>/, img/<ten>/<sha8>/). URL doi theo
noi dung → CDN/browser khong bao gio tra chunk cu cho ban moi;
index.html cu (con cache ≤10 phut) van tro dung chunk cu cua no.
Gia: moi deploy them 1 thu muc version moi (~7MB pck; wasm chi
them khi wasm doi) — thu muc cu mo coi tren gh-pages, don dinh ky.
THU TU DEPLOY: push het chunk version moi truoc, verify, roi moi
push index.html cuoi cung.

Vong 9 (20/11 ~18:15) — KET TAI 15% TREN LIVE, GOC O DEPLOY:
kiem live 17:55–18:02: game ket o 15% >3 phut, nut "Dang tai
cham" khong bao gio bat. Goc: thu muc wasm/fc74679e/ CHUA BAO
GIO duoc push len gh-pages — vong 8 doi sang chunk versioned
nhung chi push pck + img + index.html ("wasm khong push lai
(da co tren gh-pages)" — SAI: tren gh-pages chi co chunk CU
khong version wasm/part-*.txt, chua tung co wasm/fc74679e/).
Deploy G4 buoc 7 (18:03) lap lai dung loi do. He qua: moi
chunk wasm 404 → engine nuot rejection → onProgress dung o
15% (= pck 6,86MB / tong 46,4MB) → watchdog chi doi nhan
thanh "Dang tai cham". SUA LOADER (vong 9): timeout that
30s/chunk (AbortController), tai gioi han 16 song song,
loader TU hien loi that + nut tai lai (khong doi engine),
watchdog tong 120s. LUU Y DEPLOY (khong tai pham): khi
index.html doi sang duong dan version MOI thi THU MUC
VERSION DO PHAI DUOC PUSH — du noi dung khong doi; chay
`--check-live` truoc khi tuyen bo deploy xong.

Chạy từ repo root:
    python3 tools/godot/build_gh_pages.py [--verify-only]

- Đọc src/godot-build/ (kết quả export Godot Web).
- Ghi gh-pages-staging/: index.html (đã chèn loader) + index.js +
  worklets + icons + wasm/part-*.txt + pck/part-*.txt.
- Verify: ráp lại chunk từ staging, so SHA256 với file gốc.
- Chỉ in ra; không tự push (push làm riêng theo lô ~20 file vì
  snapshot giới hạn 16 MiB/lần).
"""
import base64
import hashlib
import shutil
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUILD_DIR = ROOT / "src" / "godot-build"
STAGING_DIR = ROOT / "gh-pages-staging"
RAW_CHUNK = 135_000  # base64 -> 180.000 ký tự, dưới giới hạn 188.416
SMALL_FILES = [
    "index.js",
    "index.audio.position.worklet.js",
    "index.audio.worklet.js",
    "index.png",
    "index.icon.png",
    "index.apple-touch-icon.png",
]

LOADER_TEMPLATE = """<script>
/* Gh-pages build: wasm + pck + anh tieu de tach chunk base64, rap lai qua fetch gia. */
const WASM_PARTS = [{wasm_parts}];
const PCK_PARTS = [{pck_parts}];
const IMG_PARTS = {img_parts_json};
const IMG_TYPES = {{"title_bg.jpg": "image/jpeg", "char_player.png": "image/png", "char_banthan.png": "image/png"}};
const CHUNK_TIMEOUT_MS = 30000;
const CHUNK_CONCURRENCY = 16;
let pxbLoadFailed = false;
// Vong 9 — HIEN LOI TAI THAT len man hinh (20/11 17:55: game ket
// 15% >3 phut, nut khong bao gio bat, khong co bao loi). Goc:
// thu muc wasm/fc74679e/ chua bao gio duoc push len gh-pages
// (vong 8 doi sang chunk versioned nhung chi push pck + img +
// index.html) nen moi chunk wasm 404; engine Godot nuot rejection
// cua fetch wasm (instantiateStreaming khong co catch — promise
// init khong bao gio settle) nen displayFailureNotice khong chay,
// onProgress dung yen o 15% (= pck 6,86MB / tong 46,4MB). SUA:
// loader TU HIEN LOI (khong doi engine), kem ten file loi + nut
// tai lai trang. Anh loi thi khong chan game (chi warn).
function pxbShowLoadError(msg) {{
  pxbLoadFailed = true;
  console.error('[pxb-loader] LOAD FAILED:', msg);
  const apply = () => {{
    try {{
      const btn = document.getElementById('start-btn');
      const notice = document.getElementById('status-notice');
      const prog = document.getElementById('status-progress');
      const overlay = document.getElementById('status');
      if (overlay) overlay.style.visibility = 'visible';
      if (prog) prog.style.display = 'none';
      if (notice) {{ notice.style.display = 'block'; notice.textContent = msg; }}
      if (btn) {{
        btn.disabled = false;
        btn.textContent = '⚠ Không tải được game — bấm để tải lại';
        btn.onclick = () => window.location.reload();
      }}
    }} catch (e) {{ console.error('[pxb-loader] khong hien duoc loi:', e); }}
  }};
  apply();
  setTimeout(apply, 500);  // ap lai sau khi engine (neu co) hien loi rieng.
}}
// Vong 9 — watchdog tong: sau 120s ma nut van chua bat (engine
// chua resolve — fetch treo hoac bien dich ket) thi bao loi that
// thay vi treo mai o "dang tai cham". Bo qua neu engine da hien
// loi rieng (status-notice dang co chu).
setTimeout(() => {{
  if (pxbLoadFailed) return;
  const btn = document.getElementById('start-btn');
  const notice = document.getElementById('status-notice');
  if (btn && btn.disabled && !(notice && notice.style.display !== 'none' && notice.textContent.trim())) {{
    pxbShowLoadError('Tải game quá lâu (>120 giây) mà chưa xong — có thể mạng yếu hoặc một file tải lỗi. Hãy kiểm tra mạng rồi bấm để tải lại trang.');
  }}
}}, 120000);
async function fetchChunk(u) {{
  // Vong 7: chunk fetch co retry — truoc day 1 chunk loi (404 luc
  // Pages dang rebuild / mang chap chon) la ca wasm/pck/anh chet,
  // game ket o 15% ma khong bao loi. Retry 3 lan, backoff tang.
  // Vong 8: chunk nam trong thu muc version theo sha8 cua noi dung
  // (wasm/<sha8>/part-*.txt...) — URL doi theo noi dung nen CDN
  // khong bao gio tra chunk cu tron voi chunk moi nua.
  // Vong 9: them timeout that moi lan thu (AbortController 30s)
  // — fetch treo vinh vien (mang chap chon) truoc day khong bao
  // gio reject nen retry khong chay va game ket mai.
  let lastErr = null;
  for (let attempt = 0; attempt < 3; attempt++) {{
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), CHUNK_TIMEOUT_MS);
    try {{
      const r = await fetch(u, {{ signal: ctrl.signal }});
      if (!r.ok) throw new Error('HTTP ' + r.status + ' ' + u);
      const t = await r.text();
      if (!t || !t.trim()) throw new Error('empty chunk ' + u);
      return t;
    }} catch (e) {{
      lastErr = (e && e.name === 'AbortError')
        ? new Error('timeout ' + CHUNK_TIMEOUT_MS + 'ms ' + u) : e;
      console.warn('[pxb-loader] chunk loi, thu lai ' + (attempt + 1) + '/3:', u, lastErr.message);
      await new Promise((res) => setTimeout(res, 400 * (attempt + 1)));
    }} finally {{
      clearTimeout(timer);
    }}
  }}
  throw lastErr;
}}
async function assemble(parts) {{
  // Vong 9: tai gioi han song song (16 chunk/lan) thay vi
  // Promise.all 293 fetch cung luc — tranh nghet ket noi qua
  // proxy/CDN va de timeout moi chunk co y nghia.
  const bufs = new Array(parts.length);
  let next = 0;
  async function worker() {{
    while (true) {{
      const i = next++;
      if (i >= parts.length) return;
      const t = await fetchChunk(parts[i]);
      const bin = atob(t.trim());
      const b = new Uint8Array(bin.length);
      for (let j = 0; j < bin.length; j++) b[j] = bin.charCodeAt(j);
      bufs[i] = b;
    }}
  }}
  await Promise.all(Array.from({{ length: Math.min(CHUNK_CONCURRENCY, parts.length) }}, () => worker()));
  let total = 0; bufs.forEach((b) => {{ total += b.length; }});
  const out = new Uint8Array(total); let o = 0;
  for (const b of bufs) {{ out.set(b, o); o += b.length; }}
  return out;
}}
const EMBEDDED = {{}};
const _fetch = window.fetch.bind(window);
window.fetch = function (input, init) {{
  const url = (typeof input === 'string') ? input : (input && input.url) || '';
  const name = url.split('/').pop().split('?')[0];
  if (name === 'index.wasm' || name === 'index.pck') {{
    const parts = name === 'index.wasm' ? WASM_PARTS : PCK_PARTS;
    if (!EMBEDDED[name]) {{
      EMBEDDED[name] = assemble(parts);
      // Vong 9: bao loi NGAY khi rap that bai — khong doi engine
      // (no nuot rejection cua fetch wasm, xem pxbShowLoadError).
      EMBEDDED[name].catch((e) => {{
        if (!pxbLoadFailed) pxbShowLoadError('Không tải được ' + name + ': ' + (e && e.message ? e.message : e) + ' — hãy kiểm tra mạng rồi bấm để tải lại trang.');
      }});
    }}
    return EMBEDDED[name].then((bytes) => new Response(bytes, {{ headers: {{ 'Content-Type': name === 'index.wasm' ? 'application/wasm' : 'application/octet-stream' }} }}));
  }}
  if (name in IMG_PARTS) {{
    if (!EMBEDDED[name]) {{
      EMBEDDED[name] = assemble(IMG_PARTS[name]);
      // Anh loi thi khong chan game — chi warn, DOM dung fallback.
      EMBEDDED[name].catch((e) => {{ console.warn('[pxb-loader] khong tai duoc anh:', name, e && e.message); }});
    }}
    return EMBEDDED[name].then((bytes) => new Response(bytes, {{ headers: {{ 'Content-Type': IMG_TYPES[name] }} }}));
  }}
  return _fetch(input, init);
}};
</script>"""


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def split_chunks(data: bytes, out_dir: Path, prefix: str) -> list[str]:
    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("part-*.txt"):
        old.unlink()
    names = []
    for i in range(0, len(data), RAW_CHUNK):
        part = data[i:i + RAW_CHUNK]
        name = f"part-{len(names):03d}.txt"
        (out_dir / name).write_text(base64.b64encode(part).decode())
        names.append(name)
    return names


def reassemble(names: list[str], in_dir: Path) -> bytes:
    out = bytearray()
    for n in names:
        out += base64.b64decode((in_dir / n).read_text().strip())
    return bytes(out)


def _version(data: bytes) -> str:
    # Version = 8 ky tu dau sha256 cua noi dung (vong 8): URL chunk
    # doi theo noi dung nen CDN khong bao gio tra chunk cu cho ban moi.
    return hashlib.sha256(data).hexdigest()[:8]


def build() -> dict:
    wasm = (BUILD_DIR / "index.wasm").read_bytes()
    pck = (BUILD_DIR / "index.pck").read_bytes()
    wasm_ver = _version(wasm)
    pck_ver = _version(pck)
    wasm_names = split_chunks(wasm, STAGING_DIR / "wasm" / wasm_ver, "wasm")
    pck_names = split_chunks(pck, STAGING_DIR / "pck" / pck_ver, "pck")
    # Anh tieu de + nhan vat cho DOM shell (title_bg.jpg + 2 char PNG):
    # file nhi phan khong push truc tiep duoc qua snapshot-push nen
    # chunk base64 nhu wasm/pck, loader rap lai qua fetch gia.
    import json
    img_parts: dict[str, list[str]] = {}
    img_vers: dict[str, str] = {}
    img_srcs = {
        "title_bg.jpg": BUILD_DIR / "title_bg.jpg",
        "char_player.png": ROOT / "src" / "godot" / "art" / "char_player.png",
        "char_banthan.png": ROOT / "src" / "godot" / "art" / "char_banthan.png",
    }
    for name, src in img_srcs.items():
        if not src.exists():
            print(f"CANH BAO: thieu anh {name} ({src}) — bo qua, DOM dung fallback")
            continue
        data = src.read_bytes()
        ver = _version(data)
        img_vers[name] = ver
        names = split_chunks(data, STAGING_DIR / "img" / name / ver, "img")
        img_parts[name] = [f"img/{name}/{ver}/{n}" for n in names]
        print(f"img {name}: {len(data)} byte, {len(names)} chunk, version {ver}")
    for f in SMALL_FILES:
        src = BUILD_DIR / f
        if src.exists():
            shutil.copyfile(src, STAGING_DIR / f)
    html = (BUILD_DIR / "index.html").read_text()
    loader = LOADER_TEMPLATE.format(
        wasm_parts=", ".join(f"'wasm/{wasm_ver}/{n}'" for n in wasm_names),
        pck_parts=", ".join(f"'pck/{pck_ver}/{n}'" for n in pck_names),
        img_parts_json=json.dumps(img_parts, ensure_ascii=False),
    )
    marker = '<script src="index.js"></script>'
    assert marker in html, "khong tim thay <script src=index.js> trong index.html"
    html = html.replace(marker, loader + "\n\t\t" + marker, 1)
    # Vong 9 — inline 3 anh icon/splash dang data URI: snapshot-push
    # chi day duoc file text nen index.png / index.icon.png /
    # index.apple-touch-icon.png khong bao gio co tren gh-pages
    # (404, la console error duy nhat con lai o ban live). Anh nho
    # (5,7 + 11,9 + 21,4 KB -> ~52KB base64), index.html van duoi
    # gioi han 188.416 byte/file.
    for fname, attr in (("index.icon.png", 'href="index.icon.png"'),
                        ("index.apple-touch-icon.png", 'href="index.apple-touch-icon.png"'),
                        ("index.png", 'src="index.png"')):
        src = BUILD_DIR / fname
        if src.exists():
            b64 = base64.b64encode(src.read_bytes()).decode()
            html = html.replace(attr, attr.split("=")[0] + '="data:image/png;base64,' + b64 + '"', 1)
            print(f"inline {fname}: {len(b64)} ky tu base64")
        else:
            print(f"CANH BAO: thieu {fname} — khong inline duoc")
    (STAGING_DIR / "index.html").write_text(html)
    # Ghi version hien tai de buoc deploy biet thu muc nao moi.
    (STAGING_DIR / "versions.json").write_text(json.dumps(
        {"wasm": wasm_ver, "pck": pck_ver, "img": img_vers},
        ensure_ascii=False, indent=2))
    print(f"versions: wasm={wasm_ver} pck={pck_ver} img={img_vers}")
    return {
        "wasm_bytes": len(wasm),
        "wasm_sha": hashlib.sha256(wasm).hexdigest(),
        "wasm_parts": len(wasm_names),
        "wasm_ver": wasm_ver,
        "pck_bytes": len(pck),
        "pck_sha": hashlib.sha256(pck).hexdigest(),
        "pck_parts": len(pck_names),
        "pck_ver": pck_ver,
        "img_parts": {k: len(v) for k, v in img_parts.items()},
        "img_vers": img_vers,
    }


def verify() -> bool:
    ok = True
    for kind in ("wasm", "pck"):
        src = BUILD_DIR / f"index.{kind}"
        data = src.read_bytes()
        ver = _version(data)
        chunk_dir = STAGING_DIR / kind / ver
        names = sorted(p.name for p in chunk_dir.glob("part-*.txt")) if chunk_dir.exists() else []
        data2 = reassemble(names, chunk_dir) if names else b""
        match = names and hashlib.sha256(data2).hexdigest() == hashlib.sha256(data).hexdigest()
        print(f"{kind}: version {ver}, {len(names)} chunk, {len(data2)} byte, khop byte: {bool(match)}")
        ok = ok and bool(match)
    # Anh tieu de + nhan vat: rap lai chunk, so voi file goc.
    for name, src in {
        "title_bg.jpg": BUILD_DIR / "title_bg.jpg",
        "char_player.png": ROOT / "src" / "godot" / "art" / "char_player.png",
        "char_banthan.png": ROOT / "src" / "godot" / "art" / "char_banthan.png",
    }.items():
        if not src.exists():
            print(f"img {name}: khong co file goc — bo qua")
            continue
        ver = _version(src.read_bytes())
        d = STAGING_DIR / "img" / name / ver
        if not d.exists():
            print(f"img {name}: khong co trong staging (version {ver}) — FAIL")
            ok = False
            continue
        names = sorted(p.name for p in d.glob("part-*.txt"))
        data = reassemble(names, d)
        match = hashlib.sha256(data).hexdigest() == hashlib.sha256(src.read_bytes()).hexdigest()
        print(f"img {name}: version {ver}, {len(names)} chunk, {len(data)} byte, khop byte: {match}")
        ok = ok and match
    # Loader + fileSizes trong index.html staging phai khop build hien tai.
    html = (STAGING_DIR / "index.html").read_text()
    build_html = (BUILD_DIR / "index.html").read_text()
    for key in ("index.pck", "index.wasm"):
        import re
        a = re.search(rf'"{key}":(\d+)', html)
        b = re.search(rf'"{key}":(\d+)', build_html)
        print(f"{key} fileSizes staging={a.group(1) if a else '?'} build={b.group(1) if b else '?'}")
        ok = ok and a and b and a.group(1) == b.group(1)
    print("loader co trong index.html staging:", "WASM_PARTS" in html and "window.fetch = function" in html)
    ok = ok and "WASM_PARTS" in html
    # Loader phai tro chunk THEO VERSION (vong 8) — khong con URL co dinh.
    import re as _re
    has_ver = bool(_re.search(r"wasm/[0-9a-f]{8}/part-000\.txt", html)) and \
        bool(_re.search(r"pck/[0-9a-f]{8}/part-000\.txt", html))
    print("loader dung chunk theo version:", has_ver)
    ok = ok and has_ver
    # Vong 9 — loader cung: timeout + hien loi that + watchdog tong.
    for marker in ("pxbShowLoadError", "AbortController", "CHUNK_TIMEOUT_MS",
                   "CHUNK_CONCURRENCY", "120000"):
        has = marker in html
        print(f"loader cung vong 9 [{marker}]:", has)
        ok = ok and has
    # Vong 9 — 3 anh icon/splash phai inline dang data URI (khong
    # con tro file PNG rieng — file nhi phan khong push duoc).
    for bad in ('href="index.icon.png"', 'href="index.apple-touch-icon.png"', 'src="index.png"'):
        gone = bad not in html
        print(f"khong con tro file rieng [{bad}]:", gone)
        ok = ok and gone
    print("icon/splash inline data URI:", html.count("data:image/png;base64,") == 3)
    ok = ok and html.count("data:image/png;base64,") == 3
    return ok


def check_live() -> bool:
    """Kiem tra site live co du moi thu muc chunk version ma
    index.html staging tro toi khong (vong 9: wasm/fc74679e/ thieu
    tren gh-pages ma khong ai biet cho toi khi kiem live). Chi doc
    (GET versions.json + part-000 moi asset + index.html), khong
    push gi. Tra ve True neu tat ca 200 va index.html live khop
    staging."""
    import json as _json
    import urllib.request
    base = "https://tinnt120899.github.io/pho-xo-bo/"
    ok = True

    def get(url: str):
        req = urllib.request.Request(url, headers={"User-Agent": "pxb-check-live"})
        with urllib.request.urlopen(req, timeout=25) as r:
            return r.status, r.read()

    try:
        _s, raw = get(base + "versions.json")
        vers = _json.loads(raw)
        print("live versions.json:", vers)
    except Exception as e:
        print("live versions.json LOI:", e)
        return False
    for kind in ("wasm", "pck"):
        ver = vers.get(kind)
        try:
            s, _b = get(f"{base}{kind}/{ver}/part-000.txt")
            print(f"live {kind}/{ver}/part-000.txt: HTTP {s}")
            ok = ok and s == 200
        except Exception as e:
            print(f"live {kind}/{ver}/part-000.txt LOI:", e)
            ok = False
    for name, ver in (vers.get("img") or {}).items():
        try:
            s, _b = get(f"{base}img/{name}/{ver}/part-000.txt")
            print(f"live img/{name}/{ver}/part-000.txt: HTTP {s}")
            ok = ok and s == 200
        except Exception as e:
            print(f"live img/{name}/{ver}/part-000.txt LOI:", e)
            ok = False
    try:
        _s, live_html = get(base + "index.html")
        staging_html = (STAGING_DIR / "index.html").read_bytes()
        match = hashlib.sha256(live_html).hexdigest() == hashlib.sha256(staging_html).hexdigest()
        print("live index.html khop staging:", match)
        ok = ok and match
    except Exception as e:
        print("live index.html LOI:", e)
        ok = False
    return ok


def main() -> int:
    if "--check-live" in sys.argv:
        ok = check_live()
        print("CHECK-LIVE:", "OK" if ok else "FAIL")
        return 0 if ok else 1
    if "--verify-only" in sys.argv:
        return 0 if verify() else 1
    info = build()
    print(f"wasm: {info['wasm_bytes']} byte, sha {info['wasm_sha'][:16]}…, {info['wasm_parts']} chunk")
    print(f"pck:  {info['pck_bytes']} byte, sha {info['pck_sha'][:16]}…, {info['pck_parts']} chunk")
    ok = verify()
    print("VERIFY:", "OK" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
