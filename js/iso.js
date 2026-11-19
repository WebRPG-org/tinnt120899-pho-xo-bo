// Phố Xô Bồ — chiếu tile 2D sang 2.5D isometric (bước chuyển).
// Hiện game vẽ top-down như Nadia (RPG Maker MV). File này là bước chuyển sang
// 2.5D isometric: cùng một lưới tile, chỉ đổi phép chiếu khi vẽ — logic đi lại,
// va chạm, hotspot, NPC không đổi. Hàm thuần, không dính DOM, test được bằng node.
// Công thức iso chuẩn: screenX = ox + (col - row) * tileW/2,
// screenY = oy + (col + row) * tileH/2. Ngược lại để chạm chọn tile.
(function () {
  "use strict";
  var TILE_W = 40, TILE_H = 20, OX = 22, OY = 96;

  function isoPos(col, row) {
    return { x: OX + (col - row) * (TILE_W / 2) + TILE_W / 2, y: OY + (col + row) * (TILE_H / 2) };
  }
  function screenToTile(sx, sy) {
    var u = (sx - OX - TILE_W / 2) / (TILE_W / 2);
    var v = (sy - OY) / (TILE_H / 2);
    return { col: Math.round((u + v) / 2), row: Math.round((v - u) / 2) };
  }
  function topPos(col, row) {
    return { x: 20 + col * 32 + 16, y: 96 + row * 32 + 16 };
  }
  function topToTile(sx, sy) {
    return { col: Math.floor((sx - 20) / 32), row: Math.floor((sy - 96) / 32) };
  }

  if (typeof module !== "undefined" && module.exports) {
    module.exports = { isoPos: isoPos, screenToTile: screenToTile, topPos: topPos, topToTile: topToTile };
  } else {
    window.PHO_ISO = { isoPos: isoPos, screenToTile: screenToTile, topPos: topPos, topToTile: topToTile };
  }
})();
