// Phố Xô Bồ — PXB_Isometric.js (plugin RPG Maker MV)
// Render 2.5D isometric trên Pixi — điều kiện để giữ mục chốt 2.5D
// (GDD Mục 10, docs/architecture-nadia.md §5). Bản v2 (Giai đoạn 1):
// ĐÃ MÓC vào Tilemap của MV (core MV v1.6.1 đã có trong repo):
//   - PXB_IsoTilemap kế thừa Tilemap, vẽ tile thường (B–E + A5) thành hình
//     thoi 64×32 bằng phép quay 45° + co tỉ lệ trên sprite MV (không sửa
//     core, chỉ alias/hook theo quy ước MV).
//   - Game_CharacterBase.screenX/screenY chiếu isometric — nhân vật, NPC,
//     event tự đứng đúng ô thoi; sắp xếp chiều sâu KHÔNG cần hook thêm vì
//     nhân vật vốn là con của Tilemap (Spriteset_Map.createCharacters,
//     rpg_sprites.js) và Tilemap._sortChildren xếp theo z rồi y — y nay đã
//     là y màn hình isometric nên vật ở dưới tự đè vật ở trên.
//   - Cuộn map: Spriteset_Map.updateTilemap gốc vẫn đặt tilemap.origin theo
//     displayX/displayY; updateTransform của IsoTilemap đổi origin đó thành
//     độ dời (pan) isometric của lớp tile.
// Công thức: sx = ox + (x − y) × tileW/2, sy = oy + (x + y) × tileH/2,
// tile 2:1 (64×32); sắp xếp theo x + y (tương đương sort axis (0, 1, −0.26)
// của Unity, docs/art-style.md §7); màn dọc 9:16, viewport 720×1280.
// Không dùng require, không dùng API chỉ có trên NW.js.
//
// GIỚI HẠN v2 (nói thẳng, chưa giấu):
//   - Autotile A1–A4 (nước, đất...) CHƯA vẽ — _drawTile đếm vào
//     stats.skippedAutotile; cần vẽ autotile isometric ở v3.
//   - Bóng (shadow) + mép bàn (table edge) CHƯA vẽ — đếm vào stats.
//   - Tile data hiện toàn 0 + chưa có tileset CC0 nên bản v2 chưa vẽ được
//     gì lên màn hình thật — chỉ móc đúng + tính đúng; cần tileset + data
//     map thật mới thấy map Xóm Trọ Cũ.
//   - Cuộn map (displayX/displayY) vẫn theo luật MV gốc (tile 48px):
//     nhân vật được giữ gần giữa màn hình ở mức gần đúng, chưa chỉnh tâm
//     cuộn riêng cho isometric — chỉnh ở v3 sau khi chơi thử thật.
//   - Luôn dùng IsoTilemap kể cả khi WebGL bật (không dùng ShaderTilemap):
//     hiệu ứng chỉ có trên shader tilemap không áp dụng ở v2.
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
    skippedNoBitmap: 0
  };

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
    for (var y = 0; y < this._mapHeight; y++) {
      for (var x = 0; x < this._mapWidth; x++) {
        isoPaintTiles.call(this, startX, startY, x, y);
      }
    }
  }

  // Gom tile 1 ô theo đúng luật Tilemap._paintTiles gốc (tầng nào cao thì
  // lên lớp trên, overpass đẩy z = 2/3 lên trên), nhưng chỉ vẽ tile thường;
  // bóng + mép bàn + autotile đếm vào stats, chưa vẽ ở v2.
  function isoPaintTiles(startX, startY, x, y) {
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

  // Vẽ 1 tile vào lớp: số âm = bóng (chưa vẽ), ≥10000 = mép bàn (chưa vẽ),
  // 0/vô hình thì bỏ, autotile thì đếm chưa vẽ; còn lại vẽ hình thoi.
  function isoDrawTile(layer, layerZ, tileId, mx, my) {
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
    var _origCreateTilemap = Spriteset_Map.prototype.createTilemap;
    Spriteset_Map.prototype.createTilemap = function() {
      try {
        this._tilemap = new PXB_IsoTilemap();
        this._tilemap.tileWidth = $gameMap.tileWidth();
        this._tilemap.tileHeight = $gameMap.tileHeight();
        this._tilemap.setData($gameMap.width(), $gameMap.height(), $gameMap.data());
        this._tilemap.horizontalWrap = $gameMap.isLoopHorizontal();
        this._tilemap.verticalWrap = $gameMap.isLoopVertical();
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
