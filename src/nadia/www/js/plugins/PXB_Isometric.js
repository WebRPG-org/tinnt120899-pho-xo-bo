// Phố Xô Bồ — PXB_Isometric.js (plugin RPG Maker MV)
// Render 2.5D isometric trên Pixi — điều kiện để giữ mục chốt 2.5D
// (GDD Mục 10, docs/architecture-nadia.md §5). Bản đầu (Giai đoạn 1):
// CHỈ có phép chiếu + sắp xếp + camera thuần — chưa móc vào Tilemap của MV
// (core MV chưa có trong repo; hàm install() không làm gì khi chưa có MV,
// không giả vờ đã render được). Móc Tilemap thật làm ở bước tiếp theo,
// sau khi core MV (rpgtkoolmv/corescript v1.6.1, MIT) được đưa vào js/.
// Công thức: sx = ox + (x − y) × tileW/2, sy = oy + (x + y) × tileH/2,
// tile 2:1 (64×32); sắp xếp theo x + y (tương đương sort axis (0, 1, −0.26)
// của Unity, docs/art-style.md §7); màn dọc 9:16, viewport 720×1280.
// Không dùng require, không dùng API chỉ có trên NW.js.
(function () {
  "use strict";

  // Hằng đã khóa (docs/architecture-nadia.md §5, docs/art-style.md §7).
  var TILE_W = 64;
  var TILE_H = 32;
  var VIEWPORT_W = 720;
  var VIEWPORT_H = 1280;

  // Chiếu ô lưới (col, row) sang tọa độ màn hình. ox/oy là gốc vẽ của map
  // (điểm neo góc trên của tile 0,0). Trả về tâm đáy của tile — nơi đặt
  // chân nhân vật/NPC/đồ vật (neo đáy tile, như chuẩn cũ).
  function isoPos(col, row, ox, oy) {
    return {
      x: ox + (col - row) * (TILE_W / 2) + TILE_W / 2,
      y: oy + (col + row) * (TILE_H / 2) + TILE_H
    };
  }

  // Ngược lại: chạm màn hình -> ô lưới (làm tròn về ô gần nhất).
  function screenToTile(sx, sy, ox, oy) {
    var u = (sx - ox - TILE_W / 2) / (TILE_W / 2);
    var v = (sy - oy - TILE_H) / (TILE_H / 2);
    return { col: Math.round((u + v) / 2), row: Math.round((v - u) / 2) };
  }

  // Khóa sắp xếp: vẽ theo thứ tự x + y tăng dần (vật ở dưới màn hình vẽ sau,
  // đè lên vật ở trên — đúng luật 2.5D). Tương đương sort axis (0, 1, −0.26).
  function sortKey(col, row) {
    return col + row;
  }

  // Camera theo người chơi: giữ player ở giữa viewport (trừ khi map nhỏ hơn
  // viewport thì kẹp biên). mapPixelW/H = kích thước map sau khi chiếu.
  function cameraFor(playerScreenX, playerScreenY, mapPixelW, mapPixelH) {
    var cx = playerScreenX - VIEWPORT_W / 2;
    var cy = playerScreenY - VIEWPORT_H / 2;
    cx = Math.max(0, Math.min(cx, Math.max(0, mapPixelW - VIEWPORT_W)));
    cy = Math.max(0, Math.min(cy, Math.max(0, mapPixelH - VIEWPORT_H)));
    return { x: cx, y: cy };
  }

  // Kích thước pixel của map sau khi chiếu (để kẹp camera + tính scroll).
  // Map lưới cols × rows chiếu thành hình thoi: rộng (cols + rows) × tileW/2,
  // cao (cols + rows) × tileH/2.
  function mapPixelSize(cols, rows) {
    return {
      w: (cols + rows) * (TILE_W / 2),
      h: (cols + rows) * (TILE_H / 2)
    };
  }

  // Móc vào MV (bước tiếp theo): thay Tilemap mặc định bằng renderer
  // isometric. Bản này CHƯA móc — trả false khi chưa có core MV, để
  // Scene_Boot không giả vờ chạy được khi core chưa có.
  function install() {
    if (typeof Tilemap === "undefined" || typeof Sprite === "undefined") {
      return false; // Core MV chưa có — chưa render được, không giấu.
    }
    return false; // TODO (bước tiếp theo): alias Tilemap.prototype, vẽ iso.
  }

  var PXB_Isometric = {
    TILE_W: TILE_W,
    TILE_H: TILE_H,
    VIEWPORT_W: VIEWPORT_W,
    VIEWPORT_H: VIEWPORT_H,
    isoPos: isoPos,
    screenToTile: screenToTile,
    sortKey: sortKey,
    cameraFor: cameraFor,
    mapPixelSize: mapPixelSize,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Isometric;
  } else if (typeof window !== "undefined") {
    window.PXB_Isometric = PXB_Isometric;
  }
})();
