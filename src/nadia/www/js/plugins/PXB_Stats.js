/*:
 * @plugindesc Phố Xô Bồ — Hệ chỉ số: 3 gốc Thể/Trí/Tâm + 4 pha trộn + trần tổng, lưu vào $gameSystem.
 * @author Muse Center
 *
 * @help
 * Port trung thực Stats.cs (src/client/Assets/Scripts/Stats.cs).
 *
 * - 3 chỉ số gốc: Đỏ Thể / Xanh Trí / Vàng Tâm, mỗi 0..100.
 * - 4 chỉ số pha trộn (tính ra, không lưu riêng): Tím Kỷ = (Thể+Trí)/2,
 *   Cam Dũng = (Thể+Tâm)/2, Lục Sáng = (Trí+Tâm)/2, Trắng An Yên =
 *   trung bình 3 gốc — chỉ khi 3 gốc cân bằng (chênh nhau trong ngưỡng).
 * - Trần tổng: GDD chỉ chốt "có trần", chưa chốt số — lấy từ
 *   PXB_Balance.totalStatCap (300, PROVISIONAL).
 * - Train = đánh đổi: tăng 1 chỉ số phải giảm 1 chỉ số khác cùng lượng.
 * - Tiền / Danh vọng / EXP là tài nguyên, KHÔNG phải chỉ số gốc.
 *
 * Lưu: chỉ số sống trong $gameSystem.pxbStats nên đi theo save của MV
 * ($gameSystem vốn đã nằm trong save contents của core). Khi core MV
 * chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Stats.current().the / .tri / .tam
 *   PXB_Stats.current().ky() / .dung() / .sang() / .anYen()
 *   PXB_Stats.current().train("the", "tri", 5)  // true = thành công
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback PROVISIONAL — cùng số với
  // Stats.cs / PXB_Balance.js hiện tại, để logic vẫn test được.
  function balance() {
    if (typeof window !== "undefined" && window.PXB_Balance) {
      return window.PXB_Balance;
    }
    if (typeof global !== "undefined" && global.PXB_Balance) {
      return global.PXB_Balance;
    }
    return null;
  }

  // PROVISIONAL — fallback chỉ dùng khi PXB_Balance chưa load; số này
  // phải khớp Stats.cs (TotalCap 300, StatMax 100, ngưỡng An Yên ±10).
  var FALLBACK = { totalStatCap: 300, statMax: 100, anYenBalanceTolerance: 10 };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] === "number") return b[key];
    return FALLBACK[key];
  }

  function totalStatCap() { return cfg("totalStatCap"); }
  function statMax() { return cfg("statMax"); }
  function anYenTolerance() { return cfg("anYenBalanceTolerance"); }

  function clamp(v, lo, hi) {
    return Math.max(lo, Math.min(hi, v));
  }

  var BASE_KEYS = ["the", "tri", "tam"]; // Thể (Đỏ), Trí (Xanh), Tâm (Vàng)

  // Một bộ chỉ số. Dữ liệu gốc nằm trong data ({the, tri, tam}) để
  // current() có thể trỏ thẳng vào $gameSystem.pxbStats — sửa chỉ số
  // là sửa luôn dữ liệu save, không cần bước đồng bộ riêng.
  function Stats(data) {
    this._d = data;
  }

  // Đọc/ghi qua _d để instance và dữ liệu save luôn là một.
  Object.defineProperty(Stats.prototype, "the", {
    get: function () { return this._d.the; },
    set: function (v) { this._d.the = clamp(v | 0, 0, statMax()); }
  });
  Object.defineProperty(Stats.prototype, "tri", {
    get: function () { return this._d.tri; },
    set: function (v) { this._d.tri = clamp(v | 0, 0, statMax()); }
  });
  Object.defineProperty(Stats.prototype, "tam", {
    get: function () { return this._d.tam; },
    set: function (v) { this._d.tam = clamp(v | 0, 0, statMax()); }
  });

  Stats.prototype.total = function () {
    return this.the + this.tri + this.tam;
  };

  // Chỉ số trộn = trung bình 2 gốc (làm tròn xuống) — như Stats.cs.
  Stats.prototype.ky = function () {
    return Math.floor((this.the + this.tri) / 2); // Tím — Kỷ
  };
  Stats.prototype.dung = function () {
    return Math.floor((this.the + this.tam) / 2); // Cam — Dũng
  };
  Stats.prototype.sang = function () {
    return Math.floor((this.tri + this.tam) / 2); // Lục — Sáng
  };
  // Trắng — An Yên, chỉ khi 3 gốc cân bằng trong ngưỡng PROVISIONAL ±10.
  Stats.prototype.anYen = function () {
    var tol = anYenTolerance();
    if (Math.abs(this.the - this.tri) <= tol &&
        Math.abs(this.tri - this.tam) <= tol) {
      return Math.floor((this.the + this.tri + this.tam) / 3);
    }
    return 0;
  };

  Stats.prototype.get = function (key) {
    if (key === "the") return this.the;
    if (key === "tri") return this.tri;
    if (key === "tam") return this.tam;
    return 0;
  };

  Stats.prototype.set = function (key, v) {
    if (key === "the") this.the = v;
    else if (key === "tri") this.tri = v;
    else if (key === "tam") this.tam = v;
  };

  // Tăng 1 chỉ số phải giảm 1 chỉ số khác cùng lượng (đánh đổi).
  // Trả false nếu không hợp lệ (trùng chỉ số, lượng <= 0, vượt 0..100).
  // Port trung thực Stats.Train — tổng không đổi nên không cần kiểm
  // tra lại trần tổng ở đây (ctor đã đảm bảo tổng = trần).
  Stats.prototype.train = function (up, down, amount) {
    amount = amount | 0;
    if (up === down || amount <= 0) return false;
    if (BASE_KEYS.indexOf(up) < 0 || BASE_KEYS.indexOf(down) < 0) return false;
    if (this.get(down) - amount < 0) return false;
    if (this.get(up) + amount > statMax()) return false;
    this.set(up, this.get(up) + amount);
    this.set(down, this.get(down) - amount);
    return true;
  };

  // Dữ liệu thuần để lưu ({the, tri, tam}) — cùng tham chiếu với
  // $gameSystem.pxbStats khi current() trỏ vào đó.
  Stats.prototype.data = function () {
    return this._d;
  };

  // Tạo bộ chỉ số mới. Tổng khởi đầu PHẢI bằng trần tổng (gacha chỉ
  // đổi phân bổ, không đổi tổng) — sai thì throw như ctor Stats.cs.
  function create(the, tri, tam) {
    var data = {
      the: clamp(the | 0, 0, statMax()),
      tri: clamp(tri | 0, 0, statMax()),
      tam: clamp(tam | 0, 0, statMax())
    };
    var s = new Stats(data);
    if (s.total() !== totalStatCap()) {
      throw new Error("Tổng chỉ số khởi đầu phải bằng trần " + totalStatCap() +
        " (gacha chỉ đổi phân bổ, không đổi tổng).");
    }
    return s;
  }

  // CHỈ DÙNG CHO TEST: tạo Stats với giá trị tùy ý, không yêu cầu tổng
  // = trần tổng (như Stats.WithValues). Nhân vật thật trong game luôn
  // qua create() — tổng khởi đầu = trần.
  function withValues(the, tri, tam) {
    return new Stats({
      the: clamp(the | 0, 0, statMax()),
      tri: clamp(tri | 0, 0, statMax()),
      tam: clamp(tam | 0, 0, statMax())
    });
  }

  // Khôi phục từ dữ liệu save (kẹp lại 0..100 cho an toàn).
  function fromData(data) {
    data = data || {};
    return withValues(data.the || 0, data.tri || 0, data.tam || 0);
  }

  // Phân bổ khởi đầu mặc định khi new game mà event chưa gacha:
  // chia đều trần tổng cho 3 gốc (300/3 = 100 mỗi chỉ số — chạm trần
  // từng chỉ số; đây chỉ là giá trị dự phòng, nhân vật thật do gacha
  // quyết phân bổ). PROVISIONAL — đổi khi chủ chốt phân bổ khởi đầu.
  function defaultData() {
    var each = Math.floor(totalStatCap() / 3);
    return { the: each, tri: each, tam: totalStatCap() - each * 2 };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackData = defaultData();

  // Bộ chỉ số hiện tại của người chơi. Ưu tiên $gameSystem.pxbStats
  // (đi theo save); chưa có core MV thì dùng dữ liệu dự phòng.
  function current() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbStats) {
        $gameSystem.pxbStats = defaultData();
      }
      return new Stats($gameSystem.pxbStats);
    }
    return new Stats(fallbackData);
  }

  // Khởi tạo pxbStats trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbStats) {
      $gameSystem.pxbStats = defaultData();
    }
    return true;
  }

  // Móc vào core MV (chỉ chạy khi core đã có; chưa có thì trả false).
  // - createGameObjects: new game -> khởi tạo pxbStats trong $gameSystem.
  // - extractSaveContents: load save -> kẹp lại pxbStats 0..100.
  // - makeSaveContents: KHÔNG cần alias — $gameSystem vốn đã nằm trong
  //   save contents của core MV nên pxbStats đi theo save tự động.
  function install() {
    if (typeof DataManager === "undefined") return false;
    if (typeof DataManager.createGameObjects === "function") {
      var _createGameObjects = DataManager.createGameObjects;
      DataManager.createGameObjects = function () {
        _createGameObjects.call(this);
        initInGameSystem();
      };
    }
    if (typeof DataManager.extractSaveContents === "function") {
      var _extractSaveContents = DataManager.extractSaveContents;
      DataManager.extractSaveContents = function (contents) {
        _extractSaveContents.call(this, contents);
        if (typeof $gameSystem !== "undefined" && $gameSystem &&
            $gameSystem.pxbStats) {
          // Kẹp lại cho an toàn khi load save cũ / save sửa tay.
          var s = fromData($gameSystem.pxbStats);
          $gameSystem.pxbStats = s.data();
        }
      };
    }
    return true;
  }

  // Áp dụng hook ngay khi file load (quy ước MV: code plugin chạy lúc
  // load). Không có core thì install() trả false và không làm gì.
  install();

  var PXB_Stats = {
    BASE_KEYS: BASE_KEYS,
    totalStatCap: totalStatCap,
    statMax: statMax,
    anYenTolerance: anYenTolerance,
    create: create,
    withValues: withValues,
    fromData: fromData,
    defaultData: defaultData,
    current: current,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Stats;
  } else if (typeof window !== "undefined") {
    window.PXB_Stats = PXB_Stats;
  }
})();
