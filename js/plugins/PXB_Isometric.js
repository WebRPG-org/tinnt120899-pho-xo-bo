// Phố Xô Bồ — PXB_Isometric.js (plugin RPG Maker MV)
// Render 2.5D isometric trên Pixi — điều kiện để giữ mục chốt 2.5D
// (GDD Mục 10, docs/architecture-nadia.md §5). Bản v3.1 (Giai đoạn 1):
// Chế độ atlas (atlas-code) — data map Map001–Map014 là code 1..6,
// KHÔNG phải tile ID MV (code 1..6 mà đưa vào luật MV sẽ bị hiểu là
// autotile A1 — v3 chặn đúng chỗ này: đường atlas bỏ qua hoàn toàn luật
// MV isAutotile/isVisibleTile/_isHigherTile).
//   - Registry atlas: registerAtlas(mapId, mapping) + atlasFor(mapId);
//     mapping lấy từ data/atlas-map00X.json (scheme "atlas-code", cell
//     64×64, 8 cột), PNG ở img/tilesets/atlas-map00X.png.
//   - IsoTilemap.setAtlas(mapId, mapping, bitmap): Spriteset_Map.
//     createTilemap tự gắn atlas theo $gameMap.mapId() (1 -> Map001,
//     2 -> Map002, 3 -> Map003, 4 -> Map004, …, 10 -> Map010, 11 -> Map011, 12 -> Map012, 13 -> Map013, 14 -> Map014); chưa có
//     mapping thì loadAtlasJson
//     (XMLHttpRequest) rồi setAtlas + refresh khi scene map đang active.
//     Map003/Map005–Map014 tái dùng atlas-map001.png, Map004 tái dùng atlas-map002.png:
//     loadAtlasBitmap tôn trọng mapping.atlasPng khi có (map 1-2 atlasPng
//     khớp tên suy ra từ code nên hành vi không đổi).
//   - Vẽ atlas: sprite lấy đúng frame (x,y,w,h) trong atlas PNG, tint
//     = clamp từng kênh tint*255 về 0..255 thành 0xRRGGBB, không quay
//     45° (atlas đã là hình thoi sẵn). Sàn (mapping.layer 0) neo
//     (0.5, 0.5) tại diamondCenter; tường/sạp (layer 1) neo (0.5, 1.0)
//     tại isoPos (tâm đáy) để nhà/sạp cao vươn lên trên. Phân lớp theo
//     mapping.layer (0 -> lower, 1 -> upper), bỏ qua bóng/mép bàn/
//     overpass của MV (atlas data không có các thứ đó).
//   - Đường fallback MV (v2) giữ nguyên 100% khi atlas mode tắt
//     (không mapping hoặc không bitmap): tile thường B–E + A5 vẽ thoi
//     64×32 bằng quay 45° + co; autotile/bóng/mép bàn vẫn đếm skipped.
//   - Móc Tilemap của MV (core MV v1.6.1): PXB_IsoTilemap kế thừa
//     Tilemap; Game_CharacterBase.screenX/screenY chiếu isometric;
//     cuộn map: updateTransform đổi origin MV thành pan isometric.
// Công thức: sx = ox + (x − y) × tileW/2, sy = oy + (x + y) × tileH/2,
// tile 2:1 (64×32); sắp xếp theo x + y (tương đương sort axis (0, 1, −0.26)
// của Unity, docs/art-style.md §7); màn dọc 9:16, viewport 720×1280.
// Không dùng require, không dùng API chỉ có trên NW.js.
//
// GIỚI HẠN v3 (nói thẳng, chưa giấu):
//   - Autotile A1–A4 MV vẫn chưa vẽ ở đường fallback — _drawTile đếm
//     vào stats.skippedAutotile; đường atlas không dùng autotile MV.
//   - Bóng (shadow) + mép bàn (table edge) MV chưa vẽ — đếm vào stats
//     (đường atlas bỏ qua hẳn vì atlas data không có bóng/mép bàn).
//   - Culling viewport chưa có — map 12×9 nhỏ nên vẽ hết; map lớn hơn
//     cần cắt viewport ở v4.
//   - Xe máy / dây điện / sạp lá chuối vẫn phải vẽ thêm theo
//     docs/tileset-plan.md — chưa có trong atlas-map001/002.
//   - Atlas PNG phải nằm ở img/tilesets/atlas-map00X.png thì bitmap mới
//     load được và thấy art thật (trừ khi mapping.atlasPng chỉ PNG khác
//     đã có trong img/tilesets/ — Map003 tái dùng atlas-map001.png).
//     Bitmap.isError() -> atlasModeOn() tắt, updateTransform vẽ lại
//     1 lần bằng đường fallback v2 (tile MV thường) thay vì sprite
//     atlas vẽ trắng, map trống; đếm vào stats.atlasFallback. Bitmap
//     đang load (chưa ready, chưa lỗi) vẫn giữ atlas mode — sprite MV
//     tự hiện khi bitmap load xong.
//   - Cuộn map (displayX/displayY) vẫn theo luật MV gốc (tile 48px):
//     nhân vật được giữ gần giữa màn hình ở mức gần đúng, chưa chỉnh tâm
//     cuộn riêng cho isometric — chỉnh sau khi chơi thử thật.
//   - Luôn dùng IsoTilemap kể cả khi WebGL bật (không dùng ShaderTilemap):
//     hiệu ứng chỉ có trên shader tilemap không áp dụng ở v3.
(function () {
  "use strict";

  // Hằng đã khóa (docs/architecture-nadia.md §5, docs/art-style.md §7).
  var TILE_W = 64;
  var TILE_H = 32;
  var VIEWPORT_W = 720;
  var VIEWPORT_H = 1280;

  // Kích thước ô nguồn MV: tile tileset MV là 48×48 (Game_Map.tileWidth
  // trả 48, rpg_objects.js). Hình thoi đích 64×32 làm từ ô vuông 48×48
  // bằng cách quay 45° (đường chéo 48×√2) rồi co: ngang 64/(48√2),
  // dọc 32/(48√2).
  var SRC_TILE = 48;
  var DIAMOND_ROTATION = Math.PI / 4;
  var DIAMOND_SCALE_X = TILE_W / (SRC_TILE * Math.SQRT2);
  var DIAMOND_SCALE_Y = TILE_H / (SRC_TILE * Math.SQRT2);

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

  // Gốc vẽ (ox, oy) của map: hình thoi map vừa khít [0, mapPixelW] ×
  // [0, mapPixelH] (ox = (rows−1)×32 để đỉnh trái chạm x = 0, oy = 0),
  // rồi căn giữa trong viewport khi map nhỏ hơn viewport.
  function originFor(cols, rows) {
    var mp = mapPixelSize(cols, rows);
    return {
      ox: (rows - 1) * (TILE_W / 2) + Math.max(0, (VIEWPORT_W - mp.w) / 2),
      oy: Math.max(0, (VIEWPORT_H - mp.h) / 2)
    };
  }

  // Tâm hình thoi của ô (col, row): isoPos trả tâm đáy, tâm thoi cao hơn
  // nửa chiều cao tile (16px) — sprite tile quay 45° neo giữa thì đặt ở đây.
  function diamondCenter(col, row, ox, oy) {
    var foot = isoPos(col, row, ox, oy);
    return { x: foot.x, y: foot.y - TILE_H / 2 };
  }

  // Vùng nguồn của tile thường trong tileset — sao đúng công thức
  // Tilemap._drawNormalTile (rpg_core.js): A5 (1536–2047) ở bitmap số 4,
  // còn lại ở bitmap 5 + floor(tileId / 256); sx/sy theo lưới 8 cột.
  function normalTileSource(tileId, tileW, tileH) {
    var setNumber = (tileId >= 1536 && tileId < 2048)
      ? 4 : 5 + Math.floor(tileId / 256);
    var sx = (Math.floor(tileId / 128) % 2 * 8 + tileId % 8) * tileW;
    var sy = (Math.floor(tileId % 256 / 8) % 16) * tileH;
    return { setNumber: setNumber, sx: sx, sy: sy };
  }

  // Độ dời (pan) của lớp tile theo origin MV (origin.x/y tính bằng pixel
  // MV: displayX × 48, displayY × 48). Một ô dịch đông (1, 0) chiếu thành
  // (+32, +16) nên pan ngược lại: x = −(ox − oy) × 2/3, y = −(ox + oy)/3.
  function panFromOrigin(originX, originY) {
    return {
      x: -(originX - originY) * 2 / 3,
      y: -(originX + originY) / 3
    };
  }

  // Thống kê vẽ của lần refresh gần nhất (để debug, không phải gameplay).
  var stats = {
    refreshed: 0,
    painted: 0,
    skippedAutotile: 0,
    skippedShadow: 0,
    skippedTableEdge: 0,
    skippedInvisible: 0,
    skippedNoBitmap: 0,
    skippedAtlasUnknown: 0,
    atlasFallback: 0
  };

  // ---- Chế độ atlas v3 (atlas-code, data/atlas-map00X.json) ----
  // Data map Map001/Map002/Map003/Map004 chứa code 1..6, KHÔNG phải tile ID MV:
  // code 1..6 mà đi qua luật MV sẽ bị hiểu là autotile A1. Đường atlas
  // tra mapping.tiles[String(code)] để lấy frame/tint/layer, bỏ qua
  // hoàn toàn luật MV (isAutotile/isVisibleTile/_isHigherTile).
  var _atlasRegistry = {}; // mapId (số) -> mapping atlas-code
  var _atlasBitmaps = {}; // mapId (số) -> Bitmap atlas (cache, dùng lại)

  // "Map001"/"Map002"/"Map003"/"Map004"/"Map005"/"Map006"/"Map007"/"Map008"/"Map009"/"Map010"/"Map011"/"Map012"/"Map013"/"Map014" theo
  // mapId; map khác chưa có atlas -> null.
  function atlasCodeFor(mapId) {
    if (mapId === 1) return "Map001";
    if (mapId === 2) return "Map002";
    if (mapId === 3) return "Map003";
    if (mapId === 4) return "Map004";
    if (mapId === 5) return "Map005";
    if (mapId === 6) return "Map006";
    if (mapId === 7) return "Map007";
    if (mapId === 8) return "Map008";
    if (mapId === 9) return "Map009";
    if (mapId === 10) return "Map010";
    if (mapId === 11) return "Map011";
    if (mapId === 12) return "Map012";
    if (mapId === 13) return "Map013";
    if (mapId === 14) return "Map014";
    return null;
  }

  // Lưu mapping atlas cho 1 map. Trả false khi thiếu mapId/mapping.
  function registerAtlas(mapId, mapping) {
    if (mapId == null || !mapping) return false;
    _atlasRegistry[mapId] = mapping;
    return true;
  }

  // Mapping đã đăng ký cho mapId, hoặc null khi chưa có.
  function atlasFor(mapId) {
    return _atlasRegistry[mapId] || null;
  }

  // Tint nhân tử [r, g, b] (mỗi kênh ~1.0) -> 0xRRGGBB cho PIXI.Sprite.
  // Kênh > 1 kẹp về 255, kênh thiếu/không có tint -> 0xFFFFFF (không đổi).
  function tintToHex(tint) {
    if (!tint || tint.length < 3) return 0xFFFFFF;
    var r = Math.max(0, Math.min(255, Math.round(tint[0] * 255)));
    var g = Math.max(0, Math.min(255, Math.round(tint[1] * 255)));
    var b = Math.max(0, Math.min(255, Math.round(tint[2] * 255)));
    return (r << 16) | (g << 8) | b;
  }

  // Load bitmap atlas qua ImageManager MV (chỉ chạy trên trình duyệt).
  // Trong node / kiểm tra tĩnh (không có ImageManager) trả null, không
  // crash. Bitmap được cache theo mapId để dùng lại ở mọi lần vẽ.
  function loadAtlasBitmap(mapId, mapping) {
    if (typeof ImageManager === "undefined" || !ImageManager) {
      return null;
    }
    var code = atlasCodeFor(mapId);
    if (!code) return null;
    if (_atlasBitmaps[mapId]) return _atlasBitmaps[mapId];
    // v3.1 (Map003): tôn trọng mapping.atlasPng khi có — Map003 tái dùng
    // atlas-map001.png; map 1-2 atlasPng khớp đúng tên suy ra từ code nên
    // hành vi không đổi. Không có atlasPng thì suy ra như trước.
    var pngName = "atlas-" + code.toLowerCase();
    if (mapping && mapping.atlasPng) {
      var base = String(mapping.atlasPng).split("/").pop();
      if (base.slice(-4).toLowerCase() === ".png") base = base.slice(0, -4);
      if (base) pngName = base;
    }
    var bitmap = ImageManager.loadBitmap("img/tilesets/", pngName, 0, true);
    if (bitmap) _atlasBitmaps[mapId] = bitmap;
    return bitmap || null;
  }

  // Load mapping JSON qua XMLHttpRequest (async): GET
  // data/atlas-map00X.json, parse, registerAtlas rồi gọi onDone(mapping).
  // Lỗi mạng/parse hoặc không có XMLHttpRequest -> onDone(null).
  function loadAtlasJson(mapId, onDone) {
    var done = function(mapping) {
      if (typeof onDone === "function") {
        try { onDone(mapping); } catch (e) {}
      }
    };
    if (typeof XMLHttpRequest === "undefined") {
      done(null);
      return;
    }
    var code = atlasCodeFor(mapId);
    if (!code) {
      done(null);
      return;
    }
    try {
      var xhr = new XMLHttpRequest();
      xhr.open("GET", "data/atlas-" + code.toLowerCase() + ".json", true);
      xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        if (xhr.status !== 200 && xhr.status !== 0) {
          done(null);
          return;
        }
        try {
          var mapping = JSON.parse(xhr.responseText);
          registerAtlas(mapId, mapping);
          done(mapping);
        } catch (e) {
          done(null);
        }
      };
      xhr.send();
    } catch (e) {
      done(null);
    }
  }

  // Atlas mode bật khi tilemap đã có cả mapping lẫn bitmap. Thiếu 1 trong
  // 2 -> đường fallback MV v2 (giữ nguyên 100% hành vi v2).
  // v3.1: bitmap lỗi (PNG thiếu/404, Bitmap.isError()) cũng tắt atlas
  // mode — sprite atlas vẽ trắng nếu cứ giữ. Bitmap đang load (chưa
  // ready, chưa lỗi) vẫn giữ atlas mode: sprite MV tự hiện khi load xong.
  function atlasModeOn() {
    if (!this._atlasMapping || !this._atlasBitmap) return false;
    if (typeof this._atlasBitmap.isError === "function" &&
        this._atlasBitmap.isError()) {
      return false;
    }
    return true;
  }

  // Gắn atlas cho 1 tilemap: lưu mapId/mapping/bitmap để isoDrawTile và
  // isoPaintTiles dùng. mapping/bitmap null -> tắt atlas mode. Gắn atlas
  // mới thì reset cờ đã vẽ lại do lỗi bitmap (map khác có bitmap khác).
  function isoSetAtlas(mapId, mapping, bitmap) {
    this._atlasMapId = mapId;
    this._atlasMapping = mapping || null;
    this._atlasBitmap = bitmap || null;
    this._atlasBitmapErrorRepainted = false;
  }

  // ---- PXB_IsoTilemap: Tilemap MV vẽ tile thành hình thoi ----
  // Chuỗi prototype chỉ nối trong install() (lúc đó Tilemap mới chắc chắn
  // đã load); các method dưới đây chỉ chạy khi install() đã nối xong.
  function PXB_IsoTilemap() {
    this.initialize.apply(this, arguments);
  }

  // Khởi tạo: dùng initialize gốc của Tilemap (tự gọi _createLayers +
  // refresh đã override), rồi khóa tile iso 64×32.
  function isoInitialize() {
    Tilemap.prototype.initialize.call(this);
    this._tileWidth = TILE_W;
    this._tileHeight = TILE_H;
    this._isoOrigin = { ox: 0, oy: 0 };
  }

  // Tạo lớp vẽ: 2 container Pixi thường (không dùng pixi-tilemap) —
  // lớp dưới z = 0, lớp trên z = 4, đúng bậc z của Tilemap gốc
  // (lower 0 / lower character 1 / normal 3 / upper 4 / upper character 5).
  // Gọi lại được (setter tileWidth/tileHeight của Tilemap cũng gọi nó):
  // lớp cũ (nếu có) bị gỡ trước.
  function isoCreateLayers() {
    if (this._isoLayer) {
      this.removeChild(this._isoLayer);
    }
    if (this._isoUpperLayer) {
      this.removeChild(this._isoUpperLayer);
    }
    this._isoLayer = new PIXI.Container();
    this._isoLayer.z = 0;
    this._isoUpperLayer = new PIXI.Container();
    this._isoUpperLayer.z = 4;
    this.addChild(this._isoLayer);
    this.addChild(this._isoUpperLayer);
  }

  function isoClearLayers() {
    if (this._isoLayer) {
      this._isoLayer.removeChildren();
    }
    if (this._isoUpperLayer) {
      this._isoUpperLayer.removeChildren();
    }
  }

  // Nhận data map: giữ đúng 3 dòng của Tilemap.setData gốc, thêm gốc vẽ
  // theo kích thước map rồi refresh.
  function isoSetData(width, height, data) {
    this._mapWidth = width;
    this._mapHeight = height;
    this._mapData = data;
    this._isoOrigin = originFor(width, height);
    this.refresh();
  }

  // Refresh: xóa hết sprite tile cũ, đánh dấu cần vẽ lại ở updateTransform
  // kế tiếp (không vẽ ngay trong refresh, giống Tilemap gốc).
  function isoRefresh() {
    isoClearLayers.call(this);
    this._needsRepaint = true;
    if (this._lastTiles) {
      this._lastTiles.length = 0;
    }
    stats.refreshed++;
  }

  // Vẽ lại toàn bộ map (v2: vẽ hết, không cắt theo viewport — map slice
  // 12×9 nhỏ; map lớn hơn cần cắt viewport ở v3).
  function isoPaintAllTiles(startX, startY) {
    stats.painted = 0;
    stats.skippedAutotile = 0;
    stats.skippedShadow = 0;
    stats.skippedTableEdge = 0;
    stats.skippedInvisible = 0;
    stats.skippedNoBitmap = 0;
    stats.skippedAtlasUnknown = 0;
    for (var y = 0; y < this._mapHeight; y++) {
      for (var x = 0; x < this._mapWidth; x++) {
        isoPaintTiles.call(this, startX, startY, x, y);
      }
    }
  }

  // Gom tile 1 ô theo đúng luật Tilemap._paintTiles gốc (tầng nào cao thì
  // lên lớp trên, overpass đẩy z = 2/3 lên trên), nhưng chỉ vẽ tile thường;
  // bóng + mép bàn + autotile đếm vào stats, chưa vẽ ở v2.
  // Atlas mode (v3): phân lớp theo mapping.layer (0 -> lower, 1 -> upper),
  // bỏ qua bóng/mép bàn/overpass và layer 2-5 của MV (atlas data không có
  // các thứ đó). Code không có trong mapping được đẩy xuống lower để
  // isoDrawTile đếm 1 lần vào stats.skippedAtlasUnknown.
  function isoPaintTiles(startX, startY, x, y) {
    if (atlasModeOn.call(this)) {
      var lowerTiles = [];
      var upperTiles = [];
      atlasPushTile.call(this, lowerTiles, upperTiles,
        this._readMapData(x, y, 0));
      atlasPushTile.call(this, lowerTiles, upperTiles,
        this._readMapData(x, y, 1));
      var i;
      for (i = 0; i < lowerTiles.length; i++) {
        isoDrawTile.call(this, this._isoLayer, 0, lowerTiles[i], x, y);
      }
      for (i = 0; i < upperTiles.length; i++) {
        isoDrawTile.call(this, this._isoUpperLayer, 4, upperTiles[i], x, y);
      }
      return;
    }
    var tableEdgeVirtualId = 10000;
    var mx = x;
    var my = y;
    var tileId0 = this._readMapData(mx, my, 0);
    var tileId1 = this._readMapData(mx, my, 1);
    var tileId2 = this._readMapData(mx, my, 2);
    var tileId3 = this._readMapData(mx, my, 3);
    var shadowBits = this._readMapData(mx, my, 4);
    var upperTileId1 = this._readMapData(mx, my - 1, 1);
    var lowerTiles = [];
    var upperTiles = [];

    if (this._isHigherTile(tileId0)) {
      upperTiles.push(tileId0);
    } else {
      lowerTiles.push(tileId0);
    }
    if (this._isHigherTile(tileId1)) {
      upperTiles.push(tileId1);
    } else {
      lowerTiles.push(tileId1);
    }
    lowerTiles.push(-shadowBits);
    if (this._isTableTile(upperTileId1) && !this._isTableTile(tileId1)) {
      if (!Tilemap.isShadowingTile(tileId0)) {
        lowerTiles.push(tableEdgeVirtualId + upperTileId1);
      }
    }
    if (this._isOverpassPosition(mx, my)) {
      upperTiles.push(tileId2);
      upperTiles.push(tileId3);
    } else {
      if (this._isHigherTile(tileId2)) {
        upperTiles.push(tileId2);
      } else {
        lowerTiles.push(tileId2);
      }
      if (this._isHigherTile(tileId3)) {
        upperTiles.push(tileId3);
      } else {
        lowerTiles.push(tileId3);
      }
    }

    var i;
    for (i = 0; i < lowerTiles.length; i++) {
      isoDrawTile.call(this, this._isoLayer, 0, lowerTiles[i], mx, my);
    }
    for (i = 0; i < upperTiles.length; i++) {
      isoDrawTile.call(this, this._isoUpperLayer, 4, upperTiles[i], mx, my);
    }
  }

  // Atlas mode: xếp 1 code vào lower/upper theo mapping.layer của nó
  // (không theo layer data MV — cùng code 3 là tường layer 1 ở Map001
  // nhưng là đường nhựa layer 0 ở Map002). Code 0 = ô trống, bỏ qua.
  // Code không có trong mapping -> lower để isoDrawTile đếm unknown.
  function atlasPushTile(lowerTiles, upperTiles, tileId) {
    if (tileId <= 0) return;
    var entry = this._atlasMapping.tiles[String(tileId)];
    if (entry && entry.layer === 1) {
      upperTiles.push(tileId);
    } else {
      lowerTiles.push(tileId);
    }
  }

  // Vẽ 1 tile vào lớp: số âm = bóng (chưa vẽ), ≥10000 = mép bàn (chưa vẽ),
  // 0/vô hình thì bỏ, autotile thì đếm chưa vẽ; còn lại vẽ hình thoi.
  // Atlas mode (v3) rẽ nhánh ngay đầu: mọi tileId > 0 là atlas-code, bỏ
  // qua hoàn toàn luật MV (kể cả isAutotile — code 1..6 của MV là A1).
  function isoDrawTile(layer, layerZ, tileId, mx, my) {
    if (atlasModeOn.call(this)) {
      isoDrawAtlasTile.call(this, layer, layerZ, tileId, mx, my);
      return;
    }
    if (tileId < 0) {
      stats.skippedShadow++;
      return;
    }
    if (tileId >= 10000) {
      stats.skippedTableEdge++;
      return;
    }
    if (!Tilemap.isVisibleTile(tileId)) {
      stats.skippedInvisible++;
      return;
    }
    if (Tilemap.isAutotile(tileId)) {
      stats.skippedAutotile++;
      return;
    }
    isoDrawNormalTile.call(this, layer, layerZ, tileId, mx, my);
  }

  // Vẽ 1 tile atlas-code: tra mapping.tiles[String(tileId)]; không có thì
  // đếm stats.skippedAtlasUnknown và bỏ qua. Có thì vẽ sprite từ atlas
  // bitmap với đúng frame (x,y,w,h), tint = tintToHex(entry.tint), KHÔNG
  // quay 45° (atlas đã là hình thoi sẵn). Sàn (layer 0) neo (0.5, 0.5)
  // tại diamondCenter; tường/sạp (layer 1) neo (0.5, 1.0) tại isoPos
  // (tâm đáy) để nhà/sạp cao vươn lên trên. Ô trống (tileId <= 0) bỏ qua
  // lặng, không đếm (ô trống là bình thường trong data atlas-code).
  function isoDrawAtlasTile(layer, layerZ, tileId, mx, my) {
    if (tileId <= 0) {
      return;
    }
    var entry = this._atlasMapping.tiles[String(tileId)];
    if (!entry) {
      stats.skippedAtlasUnknown++;
      return;
    }
    var sprite = new Sprite();
    sprite.bitmap = this._atlasBitmap;
    sprite.setFrame(entry.x, entry.y, entry.w, entry.h);
    sprite.tint = tintToHex(entry.tint);
    if (entry.layer === 1) {
      sprite.anchor.x = 0.5;
      sprite.anchor.y = 1.0;
      var foot = isoPos(mx, my, this._isoOrigin.ox, this._isoOrigin.oy);
      sprite.x = foot.x;
      sprite.y = foot.y;
    } else {
      sprite.anchor.x = 0.5;
      sprite.anchor.y = 0.5;
      var center = diamondCenter(mx, my, this._isoOrigin.ox, this._isoOrigin.oy);
      sprite.x = center.x;
      sprite.y = center.y;
    }
    sprite.z = layerZ;
    layer.addChild(sprite);
    stats.painted++;
  }

  // Vẽ tile thường: sprite MV lấy đúng vùng nguồn trong tileset (theo
  // normalTileSource), neo giữa, quay 45° + co thành thoi 64×32, đặt ở
  // tâm thoi của ô. Sprite MV có spriteId nên _compareChildOrder dùng được.
  function isoDrawNormalTile(layer, layerZ, tileId, mx, my) {
    var src = normalTileSource(tileId, SRC_TILE, SRC_TILE);
    var bitmap = this.bitmaps[src.setNumber];
    if (!bitmap) {
      stats.skippedNoBitmap++;
      return;
    }
    var sprite = new Sprite();
    sprite.bitmap = bitmap;
    sprite.setFrame(src.sx, src.sy, SRC_TILE, SRC_TILE);
    sprite.anchor.x = 0.5;
    sprite.anchor.y = 0.5;
    sprite.rotation = DIAMOND_ROTATION;
    sprite.scale.x = DIAMOND_SCALE_X;
    sprite.scale.y = DIAMOND_SCALE_Y;
    var center = diamondCenter(mx, my, this._isoOrigin.ox, this._isoOrigin.oy);
    sprite.x = center.x;
    sprite.y = center.y;
    sprite.z = layerZ;
    layer.addChild(sprite);
    stats.painted++;
  }

  // Mỗi frame: đổi origin MV thành độ dời iso của 2 lớp tile, vẽ lại khi
  // cần, rồi xếp con theo z/y như Tilemap gốc (nhân vật là con của
  // tilemap nên được xếp chung — y iso quyết định ai đè ai).
  function isoUpdateTransform() {
    var ox = Math.floor(this.origin.x);
    var oy = Math.floor(this.origin.y);
    var pan = panFromOrigin(ox, oy);
    if (this._isoLayer) {
      this._isoLayer.x = pan.x;
      this._isoLayer.y = pan.y;
    }
    if (this._isoUpperLayer) {
      this._isoUpperLayer.x = pan.x;
      this._isoUpperLayer.y = pan.y;
    }
    // v3.1: atlas bitmap lỗi SAU lần vẽ đầu (lỗi 404 đến muộn, lúc vẽ
    // bitmap còn đang load nên atlas mode vẫn bật) -> vẽ lại 1 lần bằng
    // fallback v2; atlasModeOn() sau đó vẫn false nên không vẽ lại nữa.
    // Bitmap lỗi TRƯỚC lần vẽ đầu thì atlasModeOn() đã false ngay từ
    // đầu, lần vẽ đầu đã là fallback nên cờ này không bật thêm lần nữa.
    if (this._atlasMapping && this._atlasBitmap &&
        !this._atlasBitmapErrorRepainted &&
        typeof this._atlasBitmap.isError === "function" &&
        this._atlasBitmap.isError()) {
      this._atlasBitmapErrorRepainted = true;
      stats.atlasFallback = (stats.atlasFallback || 0) + 1;
      this._needsRepaint = true;
    }
    if (this._needsRepaint) {
      isoPaintAllTiles.call(this, 0, 0);
      this._needsRepaint = false;
    }
    this._sortChildren();
    PIXI.Container.prototype.updateTransform.call(this);
  }

  // Móc vào MV: thay Tilemap mặc định bằng renderer isometric. Trả true
  // khi móc xong, false khi chưa có core MV (không giả vờ render được).
  // Gọi 1 lần duy nhất (cờ _installed); file tự gọi ở cuối khi chạy trên
  // trình duyệt (plugin MV load sau core nên Tilemap đã có).
  function install() {
    if (PXB_Isometric._installed) {
      return true;
    }
    if (typeof Tilemap === "undefined" || typeof Sprite === "undefined" ||
        typeof PIXI === "undefined" ||
        typeof Game_CharacterBase === "undefined" ||
        typeof Spriteset_Map === "undefined") {
      return false;
    }

    // Nối PXB_IsoTilemap vào Tilemap gốc rồi gán method.
    PXB_IsoTilemap.prototype = Object.create(Tilemap.prototype);
    PXB_IsoTilemap.prototype.constructor = PXB_IsoTilemap;
    PXB_IsoTilemap.prototype.initialize = isoInitialize;
    PXB_IsoTilemap.prototype._createLayers = isoCreateLayers;
    PXB_IsoTilemap.prototype.setData = isoSetData;
    PXB_IsoTilemap.prototype.setAtlas = isoSetAtlas;
    PXB_IsoTilemap.prototype.refresh = isoRefresh;
    PXB_IsoTilemap.prototype._paintAllTiles = isoPaintAllTiles;
    PXB_IsoTilemap.prototype._paintTiles = isoPaintTiles;
    PXB_IsoTilemap.prototype.updateTransform = isoUpdateTransform;

    // Nhân vật/NPC/event: vị trí màn hình chiếu isometric. Giữ nguyên
    // screenZ gốc (bậc ưu tiên 1/3/5) — sắp xếp chiều sâu do y iso quyết
    // định qua _compareChildOrder (z bằng nhau thì y lớn vẽ sau).
    var _origScreenX = Game_CharacterBase.prototype.screenX;
    var _origScreenY = Game_CharacterBase.prototype.screenY;
    Game_CharacterBase.prototype.screenX = function() {
      if (typeof $gameMap !== "undefined" && $gameMap &&
          typeof $gameMap.width === "function") {
        var o = originFor($gameMap.width(), $gameMap.height());
        return Math.round(o.ox + (this.scrolledX() - this.scrolledY()) *
          (TILE_W / 2) + TILE_W / 2);
      }
      return _origScreenX.call(this);
    };
    Game_CharacterBase.prototype.screenY = function() {
      if (typeof $gameMap !== "undefined" && $gameMap &&
          typeof $gameMap.width === "function") {
        var o = originFor($gameMap.width(), $gameMap.height());
        return Math.round(o.oy + (this.scrolledX() + this.scrolledY()) *
          (TILE_H / 2) + TILE_H - this.shiftY() - this.jumpHeight());
      }
      return _origScreenY.call(this);
    };

    // Spriteset_Map: dựng IsoTilemap thay cho Tilemap/ShaderTilemap.
    // Hỏng giữa chừng thì về lại cách dựng gốc, không vỡ scene map.
    // v3: gắn atlas theo $gameMap.mapId() — mapping đã đăng ký thì
    // setAtlas ngay; chưa có thì loadAtlasJson rồi setAtlas + refresh
    // (chỉ refresh khi scene map đang active, bọc try/catch).
    var _origCreateTilemap = Spriteset_Map.prototype.createTilemap;
    Spriteset_Map.prototype.createTilemap = function() {
      try {
        this._tilemap = new PXB_IsoTilemap();
        this._tilemap.tileWidth = $gameMap.tileWidth();
        this._tilemap.tileHeight = $gameMap.tileHeight();
        this._tilemap.setData($gameMap.width(), $gameMap.height(), $gameMap.data());
        this._tilemap.horizontalWrap = $gameMap.isLoopHorizontal();
        this._tilemap.verticalWrap = $gameMap.isLoopVertical();
        var mapId = $gameMap.mapId();
        var mapping = atlasFor(mapId);
        var tilemap = this._tilemap;
        if (mapping) {
          tilemap.setAtlas(mapId, mapping, loadAtlasBitmap(mapId, mapping));
        } else {
          loadAtlasJson(mapId, function(loaded) {
            if (!loaded) return;
            try {
              tilemap.setAtlas(mapId, loaded,
                loadAtlasBitmap(mapId, loaded));
              if (typeof SceneManager !== "undefined" && SceneManager &&
                  typeof Scene_Map !== "undefined" &&
                  SceneManager._scene instanceof Scene_Map) {
                tilemap.refresh();
              }
            } catch (e) {}
          });
        }
        this.loadTileset();
        this._baseSprite.addChild(this._tilemap);
      } catch (e) {
        _origCreateTilemap.call(this);
      }
    };

    PXB_Isometric._installed = true;
    return true;
  }

  var PXB_Isometric = {
    TILE_W: TILE_W,
    TILE_H: TILE_H,
    SRC_TILE: SRC_TILE,
    DIAMOND_ROTATION: DIAMOND_ROTATION,
    DIAMOND_SCALE_X: DIAMOND_SCALE_X,
    DIAMOND_SCALE_Y: DIAMOND_SCALE_Y,
    VIEWPORT_W: VIEWPORT_W,
    VIEWPORT_H: VIEWPORT_H,
    isoPos: isoPos,
    screenToTile: screenToTile,
    sortKey: sortKey,
    cameraFor: cameraFor,
    mapPixelSize: mapPixelSize,
    originFor: originFor,
    diamondCenter: diamondCenter,
    normalTileSource: normalTileSource,
    panFromOrigin: panFromOrigin,
    registerAtlas: registerAtlas,
    atlasFor: atlasFor,
    atlasCodeFor: atlasCodeFor,
    loadAtlasBitmap: loadAtlasBitmap,
    loadAtlasJson: loadAtlasJson,
    tintToHex: tintToHex,
    stats: stats,
    IsoTilemap: PXB_IsoTilemap,
    install: install,
    _installed: false
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Isometric;
  } else if (typeof window !== "undefined") {
    window.PXB_Isometric = PXB_Isometric;
    PXB_Isometric.install();
  }
})();
