#!/usr/bin/env python3
"""Build gh-pages staging cho game Godot Phố Xô Bồ.

Snapshot-push (github push-files) giới hạn 188.416 byte/file nên
index.wasm (~39,5 MB) + index.pck (~1,35 MB) phải tách thành chunk
base64 nhỏ, trình duyệt ráp lại qua fetch giả (loader chèn vào
index.html). Script này tái tạo bản deploy 06:12 20/11 (script cũ
nằm ở /tmp, đã mất) và là bản persistent trong repo.

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
async function assemble(parts) {{
  const bufs = await Promise.all(parts.map(async (u) => {{
    const t = await (await fetch(u)).text();
    const bin = atob(t.trim());
    const b = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) b[i] = bin.charCodeAt(i);
    return b;
  }}));
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
    if (!EMBEDDED[name]) EMBEDDED[name] = assemble(parts);
    return EMBEDDED[name].then((bytes) => new Response(bytes, {{ headers: {{ 'Content-Type': name === 'index.wasm' ? 'application/wasm' : 'application/octet-stream' }} }}));
  }}
  if (name in IMG_PARTS) {{
    if (!EMBEDDED[name]) EMBEDDED[name] = assemble(IMG_PARTS[name]);
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


def build() -> dict:
    wasm = (BUILD_DIR / "index.wasm").read_bytes()
    pck = (BUILD_DIR / "index.pck").read_bytes()
    wasm_names = split_chunks(wasm, STAGING_DIR / "wasm", "wasm")
    pck_names = split_chunks(pck, STAGING_DIR / "pck", "pck")
    # Anh tieu de + nhan vat cho DOM shell (title_bg.jpg + 2 char PNG):
    # file nhi phan khong push truc tiep duoc qua snapshot-push nen
    # chunk base64 nhu wasm/pck, loader rap lai qua fetch gia.
    import json
    img_parts: dict[str, list[str]] = {}
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
        names = split_chunks(data, STAGING_DIR / "img" / name, "img")
        img_parts[name] = [f"img/{name}/{n}" for n in names]
        print(f"img {name}: {len(data)} byte, {len(names)} chunk")
    for f in SMALL_FILES:
        src = BUILD_DIR / f
        if src.exists():
            shutil.copyfile(src, STAGING_DIR / f)
    html = (BUILD_DIR / "index.html").read_text()
    loader = LOADER_TEMPLATE.format(
        wasm_parts=", ".join(f"'wasm/{n}'" for n in wasm_names),
        pck_parts=", ".join(f"'pck/{n}'" for n in pck_names),
        img_parts_json=json.dumps(img_parts, ensure_ascii=False),
    )
    marker = '<script src="index.js"></script>'
    assert marker in html, "khong tim thay <script src=index.js> trong index.html"
    html = html.replace(marker, loader + "\n\t\t" + marker, 1)
    (STAGING_DIR / "index.html").write_text(html)
    return {
        "wasm_bytes": len(wasm),
        "wasm_sha": hashlib.sha256(wasm).hexdigest(),
        "wasm_parts": len(wasm_names),
        "pck_bytes": len(pck),
        "pck_sha": hashlib.sha256(pck).hexdigest(),
        "pck_parts": len(pck_names),
        "img_parts": {k: len(v) for k, v in img_parts.items()},
    }


def verify() -> bool:
    ok = True
    for kind in ("wasm", "pck"):
        src = BUILD_DIR / f"index.{kind}"
        names = sorted(p.name for p in (STAGING_DIR / kind).glob("part-*.txt"))
        data = reassemble(names, STAGING_DIR / kind)
        match = hashlib.sha256(data).hexdigest() == hashlib.sha256(src.read_bytes()).hexdigest()
        print(f"{kind}: {len(names)} chunk, {len(data)} byte, khop byte: {match}")
        ok = ok and match
    # Anh tieu de + nhan vat: rap lai chunk, so voi file goc.
    for name, src in {
        "title_bg.jpg": BUILD_DIR / "title_bg.jpg",
        "char_player.png": ROOT / "src" / "godot" / "art" / "char_player.png",
        "char_banthan.png": ROOT / "src" / "godot" / "art" / "char_banthan.png",
    }.items():
        d = STAGING_DIR / "img" / name
        if not d.exists() or not src.exists():
            print(f"img {name}: khong co trong staging/goc — bo qua")
            continue
        names = sorted(p.name for p in d.glob("part-*.txt"))
        data = reassemble(names, d)
        match = hashlib.sha256(data).hexdigest() == hashlib.sha256(src.read_bytes()).hexdigest()
        print(f"img {name}: {len(names)} chunk, {len(data)} byte, khop byte: {match}")
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
    return ok


def main() -> int:
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
