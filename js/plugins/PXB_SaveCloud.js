/*:
 * @plugindesc Phố Xô Bồ — đồng bộ save kiểu xenvn: tài khoản tùy chọn, save JSON nén LZString, localStorage khi offline; upload/download lên server CHƯA có endpoint nên luôn trả server-chua-co-endpoint.
 * @author Muse Center
 *
 * @help
 * Đồng bộ save kiểu xenvn (docs/architecture-nadia.md §6 #16, §7):
 * bản web Nadia cho đăng ký tài khoản để sao lưu/đồng bộ save lên
 * server của họ — không phải tính năng gốc MV. Phố Xô Bồ làm tương
 * tự: tài khoản là TÙY CHỌN, chưa đăng nhập thì chơi + lưu bình
 * thường bằng localStorage như MV gốc.
 *
 * - Save JSON gom toàn bộ $gameSystem (gồm pxb* của mọi plugin:
 *   pxbStats, pxbEconomy, pxbSocial, pxbStory, pxbOnline,
 *   pxbSaveCloud…) + ngày game hiện tại. Save là object thuần
 *   JSON-safe — không lưu function / class.
 * - Nén bằng LZString.compressToBase64 khi có LZString (MV load
 *   sẵn js/libs/lz-string.js trên web); không có thì fallback JSON
 *   thô, ghi rõ compressed:false — không giả vờ đã nén.
 * - Lưu local: localStorage khóa "pxbSaveCloud_<slot>" khi có
 *   localStorage; không có (node test / trình duyệt chặn) thì giữ
 *   trong bộ nhớ của plugin (memory) — vẫn trả ok nhưng ghi rõ
 *   where:"memory" để event biết save này mất khi đóng trang.
 * - Upload / download save lên server: server CHƯA có endpoint nên
 *   LUÔN trả {ok:false, reason:"server-chua-co-endpoint"} — KHÔNG
 *   giả vờ đã đồng bộ. Chưa đăng nhập thì trả
 *   {ok:false, reason:"chua-dang-nhap"} trước, cũng không gọi server.
 * - Trạng thái đồng bộ lưu trong $gameSystem.pxbSaveCloud
 *   (lastSyncAt, lastSyncStatus, lastSyncDetail) nên đi theo save.
 *
 * PROVISIONAL — chưa chốt, đổi thì sửa ở đây + server +
 * docs/architecture-nadia.md §7 cùng lúc:
 *   - Tài khoản hiện chỉ là accountId (chuỗi do người chơi nhập);
 *     CHƯA có mật khẩu / đăng ký / xác thực thật — server chưa có
 *     auth nên không bịa luồng đăng nhập.
 *   - Số slot lưu local tối đa 3 slot (slot 1–3, như MV gốc).
 *   - Phiên bản save "0.1.0-skeleton" (khớp version server hiện tại).
 *   - Upload/download dùng endpoint /save/upload + /save/download
 *     (TÊN DỰ KIẾN — server chưa có, hàm chỉ giữ tên để sau này nối,
 *     không gọi thật).
 *
 * Lưu: state sống trong $gameSystem.pxbSaveCloud nên đi theo save
 * của MV ($gameSystem vốn đã nằm trong save contents của core). Khi
 * core MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được
 * qua module.exports; hàm install() trả false và không giả vờ đã móc
 * save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_SaveCloud.login("nguoi-choi-1")   // {ok:true, accountId}
 *   PXB_SaveCloud.isLoggedIn()            // true/false
 *   PXB_SaveCloud.saveToLocal(1)          // {ok:true, where, slot, compressed}
 *   PXB_SaveCloud.loadFromLocal(1)        // {ok:true, data, compressed} | {ok:false, reason}
 *   PXB_SaveCloud.uploadSave(1)           // {ok:false, reason:"server-chua-co-endpoint"}
 *   PXB_SaveCloud.downloadSave(1)         // {ok:false, reason:"server-chua-co-endpoint"}
 *   PXB_SaveCloud.syncStatus()            // {status, detail, at}
 */
(function () {
  "use strict";

  // --- Hằng PROVISIONAL (xem @help) ---

  // Số slot lưu local tối đa — MV gốc có 3 slot (file1–3).
  var MAX_LOCAL_SLOTS = 3;
  // Phiên bản save — khớp version server hiện tại (0.1.0-skeleton).
  var SAVE_VERSION = "0.1.0-skeleton";
  // Tên endpoint DỰ KIẾN cho upload/download — server CHƯA có, chỉ
  // giữ tên để sau này nối, hàm upload/download KHÔNG gọi thật.
  var SAVE_UPLOAD_PATH = "/save/upload";
  var SAVE_DOWNLOAD_PATH = "/save/download";

  // Lý do trả về khi server chưa có endpoint — dùng chung với
  // PXB_Online để event / QC bắt được bằng test tĩnh.
  var REASON_NO_ENDPOINT = "server-chua-co-endpoint";

  // Trạng thái đồng bộ (chuỗi cố định để event / QC so sánh).
  var SYNC_STATUS = {
    CHUA_DONG_BO: "chua-dong-bo", // chưa từng đồng bộ
    LOCAL_OK: "local-ok",         // đã lưu local, chưa lên server
    DA_DONG_BO: "da-dong-bo",     // đã đồng bộ lên server (sau này)
    LOI: "loi"                    // lần đồng bộ gần nhất lỗi
  };

  // --- State (sống trong $gameSystem.pxbSaveCloud để vào save) ---

  function defaultState() {
    return {
      accountId: null,      // null = chưa đăng nhập (chỉ lưu local)
      lastSyncAt: 0,        // Date.now() lúc đồng bộ gần nhất
      lastSyncStatus: SYNC_STATUS.CHUA_DONG_BO,
      lastSyncDetail: "",   // ghi chú lần đồng bộ gần nhất
      localSlots: {}        // slot -> {at, compressed, where} (mô tả, không chứa save)
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbSaveCloud) {
        $gameSystem.pxbSaveCloud = defaultState();
      }
      return $gameSystem.pxbSaveCloud;
    }
    return fallbackState;
  }

  // Khởi tạo pxbSaveCloud trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbSaveCloud) {
      $gameSystem.pxbSaveCloud = defaultState();
    }
    return true;
  }

  // Reset state hiện tại (event/test dùng để bắt đầu lại).
  function resetState() {
    var st = state();
    var d = defaultState();
    for (var k in d) st[k] = d[k];
    return true;
  }

  // --- Tài khoản (tùy chọn — chưa đăng nhập vẫn chơi + lưu local) ---

  // Đăng nhập bằng accountId (chuỗi do người chơi nhập). CHƯA có mật
  // khẩu / xác thực thật (PROVISIONAL — server chưa có auth).
  // Trả {ok:true, accountId} hoặc {ok:false, reason:"thieu-account-id"}.
  function login(accountId) {
    if (typeof accountId !== "string" || accountId.length === 0) {
      return { ok: false, reason: "thieu-account-id" };
    }
    state().accountId = accountId;
    return { ok: true, accountId: accountId };
  }

  // Đăng xuất — chỉ xóa accountId, không xóa save local.
  function logout() {
    state().accountId = null;
    return { ok: true, accountId: null };
  }

  function isLoggedIn() {
    return typeof state().accountId === "string" &&
      state().accountId.length > 0;
  }

  function accountId() { return state().accountId; }

  // --- Gom + nén save ---

  // Lấy $gameSystem hiện tại (khi có core MV) hoặc systemObj truyền
  // vào (node test). Trả null khi không có.
  function gameSystemOf(systemObj) {
    if (systemObj && typeof systemObj === "object") return systemObj;
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      return $gameSystem;
    }
    return null;
  }

  // Gom save JSON từ $gameSystem: toàn bộ field pxb* của các plugin
  // + ngày game hiện tại (lấy từ PXB_Time qua $gameSystem khi có,
  // không thì 1). Trả {ok:true, save} hoặc
  // {ok:false, reason:"khong-co-game-system"}.
  // save = {version, savedAt, gameDay, gameSystem} — object thuần,
  // JSON-safe.
  function buildSaveJson(systemObj) {
    var sys = gameSystemOf(systemObj);
    if (!sys) return { ok: false, reason: "khong-co-game-system" };
    var gameDay = 1;
    if (sys.pxbTime && typeof sys.pxbTime.gameDay === "number") {
      gameDay = sys.pxbTime.gameDay;
    } else if (typeof sys.gameDay === "number") {
      gameDay = sys.gameDay;
    }
    // Copy nông $gameSystem để JSON.stringify không chạm field lạ;
    // mọi field pxb* đều là object thuần nên đi theo được.
    var sysCopy = {};
    for (var k in sys) {
      if (Object.prototype.hasOwnProperty.call(sys, k)) {
        sysCopy[k] = sys[k];
      }
    }
    return {
      ok: true,
      save: {
        version: SAVE_VERSION,
        savedAt: Date.now(),
        gameDay: gameDay,
        gameSystem: sysCopy
      }
    };
  }

  // Nén save JSON: dùng LZString.compressToBase64 khi có LZString
  // (MV load sẵn trên web); không có thì fallback JSON thô.
  // Trả {ok:true, data, compressed:true/false}.
  function encodeSave(save) {
    var json = JSON.stringify(save);
    if (typeof LZString !== "undefined" &&
        typeof LZString.compressToBase64 === "function") {
      return {
        ok: true,
        data: LZString.compressToBase64(json),
        compressed: true
      };
    }
    return { ok: true, data: json, compressed: false };
  }

  // Giải nén save đã encode: compressed=true thì dùng
  // LZString.decompressFromBase64; không có LZString thì trả lỗi rõ
  // (không giả vờ đã giải nén). compressed=false thì JSON.parse thô.
  // Trả {ok:true, save} hoặc {ok:false, reason}.
  function decodeSave(data, compressed) {
    try {
      if (compressed) {
        if (typeof LZString === "undefined" ||
            typeof LZString.decompressFromBase64 !== "function") {
          return { ok: false, reason: "thieu-lzstring" };
        }
        var json = LZString.decompressFromBase64(data);
        if (typeof json !== "string") {
          return { ok: false, reason: "giai-nen-that-bai" };
        }
        return { ok: true, save: JSON.parse(json) };
      }
      return { ok: true, save: JSON.parse(data) };
    } catch (e) {
      return { ok: false, reason: "save-hong" };
    }
  }

  // --- Lưu / đọc local (localStorage như MV gốc, fallback memory) ---

  // Bộ nhớ dự phòng khi không có localStorage (node test / trình
  // duyệt chặn) — save trong này mất khi đóng trang, hàm trả về ghi
  // rõ where:"memory".
  var memorySlots = {};

  function localStorageAvailable() {
    try {
      return typeof localStorage !== "undefined" &&
        typeof localStorage.setItem === "function";
    } catch (e) {
      return false;
    }
  }

  function slotKey(slot) { return "pxbSaveCloud_" + slot; }

  function validSlot(slot) {
    return typeof slot === "number" && Math.floor(slot) === slot &&
      slot >= 1 && slot <= MAX_LOCAL_SLOTS;
  }

  // Ghi trạng thái đồng bộ vào state (event đọc bằng syncStatus()).
  function markSync(status, detail) {
    var st = state();
    st.lastSyncAt = Date.now();
    st.lastSyncStatus = status;
    st.lastSyncDetail = detail || "";
  }

  // Lưu save hiện tại vào slot local (1–3). Trả
  // {ok:true, slot, where:"localStorage"|"memory", compressed:true/false}
  // hoặc {ok:false, reason}. Chưa đăng nhập vẫn lưu được — đây là
  // save local kiểu MV gốc.
  function saveToLocal(slot, systemObj) {
    if (!validSlot(slot)) {
      return { ok: false, reason: "slot-khong-hop-le" };
    }
    var built = buildSaveJson(systemObj);
    if (!built.ok) return built;
    var encoded = encodeSave(built.save);
    var key = slotKey(slot);
    var where = "memory";
    if (localStorageAvailable()) {
      try {
        localStorage.setItem(key, encoded.data);
        where = "localStorage";
      } catch (e) {
        memorySlots[key] = encoded.data;
        where = "memory";
      }
    } else {
      memorySlots[key] = encoded.data;
    }
    state().localSlots[String(slot)] = {
      at: Date.now(), compressed: encoded.compressed, where: where
    };
    markSync(SYNC_STATUS.LOCAL_OK,
      "da-luu-local-slot-" + slot + "-qua-" + where);
    return {
      ok: true, slot: slot, where: where,
      compressed: encoded.compressed
    };
  }

  // Đọc save từ slot local. Trả {ok:true, save, slot, compressed}
  // hoặc {ok:false, reason:"slot-trong"} / "save-hong" /
  // "thieu-lzstring". Không tự ghi đè $gameSystem — event quyết có
  // load vào game không (xem applySave).
  function loadFromLocal(slot) {
    if (!validSlot(slot)) {
      return { ok: false, reason: "slot-khong-hop-le" };
    }
    var key = slotKey(slot);
    var raw = null;
    if (localStorageAvailable()) {
      try {
        raw = localStorage.getItem(key);
      } catch (e) {
        raw = null;
      }
    }
    if (raw === null || typeof raw === "undefined") {
      raw = memorySlots[key];
    }
    if (raw === null || typeof raw === "undefined") {
      return { ok: false, reason: "slot-trong" };
    }
    // Không biết chuỗi lưu có nén hay không: thử đọc mô tả slot,
    // không có thì đoán bằng JSON.parse (thô) trước, nén sau.
    var info = state().localSlots[String(slot)];
    var compressed = !!(info && info.compressed);
    var decoded = decodeSave(raw, compressed);
    if (!decoded.ok && !compressed) {
      // Dữ liệu lưu trước đây có thể đã nén nhưng mô tả slot mất
      // (save cũ) — thử giải nén 1 lần rồi thôi.
      decoded = decodeSave(raw, true);
    }
    if (!decoded.ok) return decoded;
    return {
      ok: true, save: decoded.save, slot: slot,
      compressed: compressed
    };
  }

  // Áp save đã đọc vào $gameSystem hiện tại: chép từng field của
  // save.gameSystem vào $gameSystem (giữ lại field hiện có không có
  // trong save). Trả {ok:true} hoặc {ok:false, reason}.
  // Không tự gọi trong loadFromLocal — event quyết khi nào load.
  function applySave(save) {
    if (!save || typeof save !== "object" || !save.gameSystem) {
      return { ok: false, reason: "save-khong-hop-le" };
    }
    if (typeof $gameSystem === "undefined" || !$gameSystem) {
      return { ok: false, reason: "khong-co-game-system" };
    }
    var gs = save.gameSystem;
    for (var k in gs) {
      if (Object.prototype.hasOwnProperty.call(gs, k)) {
        $gameSystem[k] = gs[k];
      }
    }
    return { ok: true };
  }

  // Mô tả các slot local đã lưu (slot -> {at, compressed, where}) —
  // event dùng để hiển thị danh sách save.
  function listLocalSlots() {
    var out = {};
    var slots = state().localSlots;
    for (var k in slots) {
      if (Object.prototype.hasOwnProperty.call(slots, k)) {
        out[k] = slots[k];
      }
    }
    return out;
  }

  // --- Upload / download lên server: CHƯA có endpoint ---
  // Cả 2 hàm LUÔN trả {ok:false, reason:"server-chua-co-endpoint"}.
  // KHÔNG gọi fetch, KHÔNG giả vờ đã đồng bộ. Chưa đăng nhập thì trả
  // {ok:false, reason:"chua-dang-nhap"} trước. Tên endpoint dự kiến
  // SAVE_UPLOAD_PATH / SAVE_DOWNLOAD_PATH chỉ giữ để sau này nối.

  function uploadSave(slot, systemObj) {
    if (!isLoggedIn()) {
      return { ok: false, reason: "chua-dang-nhap" };
    }
    if (!validSlot(slot)) {
      return { ok: false, reason: "slot-khong-hop-le" };
    }
    markSync(SYNC_STATUS.LOI,
      "server-chua-co-endpoint:" + SAVE_UPLOAD_PATH);
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  function downloadSave(slot) {
    if (!isLoggedIn()) {
      return { ok: false, reason: "chua-dang-nhap" };
    }
    if (!validSlot(slot)) {
      return { ok: false, reason: "slot-khong-hop-le" };
    }
    markSync(SYNC_STATUS.LOI,
      "server-chua-co-endpoint:" + SAVE_DOWNLOAD_PATH);
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Trạng thái đồng bộ hiện tại — event / UI đọc để hiển thị.
  function syncStatus() {
    var st = state();
    return {
      status: st.lastSyncStatus,
      detail: st.lastSyncDetail,
      at: st.lastSyncAt,
      accountId: st.accountId
    };
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_SaveCloud Login <accountId>  — đăng nhập (tùy chọn)
  //   PXB_SaveCloud Logout             — đăng xuất
  //   PXB_SaveCloud SaveLocal <slot>   — lưu save vào slot local 1–3
  //   PXB_SaveCloud Upload <slot>      — lên server (chưa có endpoint)
  //   PXB_SaveCloud Download <slot>    — từ server (chưa có endpoint)
  // Đọc save local / áp save / xem trạng thái KHÔNG qua plugin
  // command (cần kết quả trả về) — event gọi trực tiếp
  // PXB_SaveCloud.loadFromLocal(...) / .applySave(...) /
  // .syncStatus() v.v.
  function install() {
    if (typeof DataManager !== "undefined") {
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
              $gameSystem.pxbSaveCloud) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbSaveCloud;
            for (var k in d) {
              if (typeof s[k] === "undefined") s[k] = d[k];
            }
          }
        };
      }
    }
    if (typeof Game_Interpreter !== "undefined" &&
        typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_SaveCloud") {
          if (args[0] === "Login") {
            login(args[1]);
          } else if (args[0] === "Logout") {
            logout();
          } else if (args[0] === "SaveLocal") {
            saveToLocal(parseInt(args[1], 10) || 1);
          } else if (args[0] === "Upload") {
            uploadSave(parseInt(args[1], 10) || 1);
          } else if (args[0] === "Download") {
            downloadSave(parseInt(args[1], 10) || 1);
          }
        }
      };
      return true;
    }
    return typeof DataManager !== "undefined";
  }

  // Áp dụng hook ngay khi file load (quy ước MV: code plugin chạy lúc
  // load). Không có core thì install() trả false và không làm gì.
  install();

  var PXB_SaveCloud = {
    MAX_LOCAL_SLOTS: MAX_LOCAL_SLOTS,
    SAVE_VERSION: SAVE_VERSION,
    SAVE_UPLOAD_PATH: SAVE_UPLOAD_PATH,
    SAVE_DOWNLOAD_PATH: SAVE_DOWNLOAD_PATH,
    REASON_NO_ENDPOINT: REASON_NO_ENDPOINT,
    SYNC_STATUS: SYNC_STATUS,
    login: login,
    logout: logout,
    isLoggedIn: isLoggedIn,
    accountId: accountId,
    buildSaveJson: buildSaveJson,
    encodeSave: encodeSave,
    decodeSave: decodeSave,
    saveToLocal: saveToLocal,
    loadFromLocal: loadFromLocal,
    applySave: applySave,
    listLocalSlots: listLocalSlots,
    uploadSave: uploadSave,
    downloadSave: downloadSave,
    syncStatus: syncStatus,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_SaveCloud;
  } else if (typeof window !== "undefined") {
    window.PXB_SaveCloud = PXB_SaveCloud;
  }
})();
