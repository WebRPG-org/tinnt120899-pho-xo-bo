/*:
 * @plugindesc Phố Xô Bồ — client online Phase 2: health check, số dư + tặng tiền qua server .NET, hàng đợi outbox khi offline; trade/đấu giá/công ty=guild CHƯA có endpoint nên luôn trả server-chua-co-endpoint.
 * @author Muse Center
 *
 * @param BaseURL
 * @text Địa chỉ server
 * @desc Base URL của server .NET (mặc định http://localhost:5000).
 * @default http://localhost:5000
 *
 * @help
 * Client online Phase 2 (docs/architecture-nadia.md §6 #15, §7).
 *
 * - Endpoint THẬT đã có trên server (src/server/src/Program.cs):
 *   GET  /health
 *   GET  /ledger/balance/{playerId}
 *   POST /ledger/gift (body FromPlayerId, ToPlayerId, AmountVnd,
 *   GameDay, IdempotencyKey; trùng key → 409, không tặng lần 2).
 * - CHƯA có auth: endpoint /ledger/gift hiện tin playerId trong
 *   body, chỉ dùng nội bộ cho tới khi server có auth. Plugin này
 *   KHÔNG tự thêm auth giả — khi server có auth thì bổ sung sau.
 * - Trade / đấu giá / công ty=guild: server CHƯA có endpoint nên
 *   các hàm này LUÔN trả {ok:false, reason:"server-chua-co-endpoint"}
 *   — KHÔNG bịa endpoint, KHÔNG giả vờ thành công. Client không
 *   bao giờ tự quyết tiền/đồ của người khác: mọi giao dịch tiền
 *   phải qua server, sổ cái EconomyLedger là nguồn sự thật.
 * - Tặng tiền: mỗi lần tặng sinh IdempotencyKey riêng
 *   ("pxb-" + Date.now() + "-" + số ngẫu nhiên); key đã gửi rồi thì
 *   KHÔNG gửi lần 2 (trả {ok:false, reason:"trung-idempotency-key"}).
 * - Offline: tặng tiền khi không tới được server thì lưu vào hàng
 *   đợi outbox trong $gameSystem.pxbOnline và gửi lại khi online
 *   (flushOutbox). Server trả 409 (đã có key này) thì coi như đã
 *   gửi xong, xóa khỏi outbox — không tặng lần 2.
 * - Mọi số tiền lấy từ PXB_Balance (phí đấu giá, vốn lập công ty…)
 *   — plugin này không hardcode số tiền nào khác. Riêng tặng tiền
 *   chưa có giới hạn trong PXB_Balance (PROVISIONAL: chưa có cap).
 *
 * PROVISIONAL — chưa chốt, đổi thì sửa ở đây + server +
 * docs/architecture-nadia.md §7 cùng lúc:
 *   - BaseURL mặc định http://localhost:5000 (server chạy local;
 *     URL deploy thật chưa có).
 *   - Timeout health check / gọi API: 5000 ms.
 *   - Outbox giữ tối đa 50 món chờ; key đã gửi giữ tối đa 200 key.
 *   - Số dư cache trong state chỉ để hiển thị, hết hạn sau 60 giây.
 *
 * Lưu: state sống trong $gameSystem.pxbOnline nên đi theo save của
 * MV ($gameSystem vốn đã nằm trong save contents của core). Khi core
 * MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Online.healthCheck()              // Promise<{ok, status, ...}>
 *   PXB_Online.balance("nguoi-choi-1")    // Promise<{ok, cashVnd, savingsVnd}>
 *   PXB_Online.gift("a", "b", 100000, 5)  // Promise<{ok, key, queued}>
 *   PXB_Online.flushOutbox()              // Promise<{sent, kept, failed}>
 *   PXB_Online.createTradeOffer("a","b","xe-may-cu","xe-dap")
 *     // {ok:false, reason:"server-chua-co-endpoint"}
 */
(function () {
  "use strict";

  // --- Hằng PROVISIONAL (xem @help) ---

  // Base URL mặc định — server .NET chạy local; URL deploy thật
  // chưa có.
  var DEFAULT_BASE_URL = "http://localhost:5000";
  // Timeout mỗi lần gọi API — PROVISIONAL.
  var REQUEST_TIMEOUT_MS = 5000;
  // Outbox giữ tối đa 50 món chờ — PROVISIONAL.
  var OUTBOX_MAX = 50;
  // Key tặng tiền đã gửi giữ tối đa 200 key — PROVISIONAL.
  var SENT_KEYS_MAX = 200;
  // Số dư cache chỉ để hiển thị, hết hạn sau 60 giây — PROVISIONAL.
  var BALANCE_CACHE_MS = 60000;

  // Lý do trả về khi server chưa có endpoint — dùng chung cho trade /
  // đấu giá / công ty=guild để event / QC bắt được bằng test tĩnh.
  var REASON_NO_ENDPOINT = "server-chua-co-endpoint";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số với
  // GameBalance.cs / PXB_Balance.js hiện tại, để logic vẫn test được.
  function balance() {
    if (typeof window !== "undefined" && window.PXB_Balance) {
      return window.PXB_Balance;
    }
    if (typeof global !== "undefined" && global.PXB_Balance) {
      return global.PXB_Balance;
    }
    return null;
  }

  // Fallback chỉ dùng khi PXB_Balance chưa load. Phí đấu giá 5% và
  // vốn lập công ty 500 triệu là số ĐÃ CHỐT.
  var FALLBACK = {
    auctionFeePercent: 5,
    companyCapitalVnd: 500000000
  };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] !== "undefined") return b[key];
    return FALLBACK[key];
  }

  function auctionFeePercent() { return cfg("auctionFeePercent"); }
  function companyCapitalVnd() { return cfg("companyCapitalVnd"); }

  // --- Đọc tham số plugin (quy ước MV: PluginManager.parameters) ---

  // Base URL lấy từ tham số plugin khi có core MV; khi chạy node test
  // (không có PluginManager) dùng giá trị mặc định. Ghi PROVISIONAL:
  // URL deploy thật chưa có.
  function readBaseUrlParam() {
    if (typeof PluginManager !== "undefined" &&
        typeof PluginManager.parameters === "function") {
      var params = PluginManager.parameters("PXB_Online") || {};
      if (params.BaseURL && String(params.BaseURL).length > 0) {
        return String(params.BaseURL).replace(/\/+$/, "");
      }
    }
    return DEFAULT_BASE_URL;
  }

  // --- State (sống trong $gameSystem.pxbOnline để vào save) ---

  function defaultState() {
    return {
      baseUrl: readBaseUrlParam(), // PROVISIONAL — xem readBaseUrlParam
      online: false,        // lần health check gần nhất có tới được server không
      lastHealthCheckAt: 0, // Date.now() lúc health check gần nhất
      lastHealthOk: false,  // health check gần nhất trả ok không
      outbox: [],           // món tặng tiền đang chờ gửi lại khi online
      sentGiftKeys: [],     // IdempotencyKey đã gửi (chống gửi lần 2)
      lastBalance: null,    // {playerId, cashVnd, savingsVnd} cache để hiển thị
      lastBalanceAt: 0      // Date.now() lúc lấy số dư gần nhất
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbOnline) {
        $gameSystem.pxbOnline = defaultState();
      }
      return $gameSystem.pxbOnline;
    }
    return fallbackState;
  }

  // Khởi tạo pxbOnline trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbOnline) {
      $gameSystem.pxbOnline = defaultState();
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

  // Đổi base URL lúc chạy (event/test dùng khi server đổi địa chỉ).
  // Trả false khi URL rỗng. Ghi PROVISIONAL: URL deploy thật chưa có.
  function setBaseUrl(url) {
    if (typeof url !== "string" || url.length === 0) return false;
    state().baseUrl = url.replace(/\/+$/, "");
    return true;
  }

  function baseUrl() { return state().baseUrl; }
  function isOnline() { return !!state().online; }

  // --- Lớp gọi HTTP (fetch của trình duyệt; node test stub fetch) ---

  // fetch có ở trình duyệt hiện đại và Node 18+. Không có fetch thì
  // trả {ok:false, reason:"fetch-khong-co"} — không giả vờ đã gọi.
  function httpFetch(url, options) {
    if (typeof fetch === "undefined") {
      return Promise.resolve({
        ok: false, status: 0,
        json: function () {
          return Promise.resolve({ ok: false, reason: "fetch-khong-co" });
        }
      });
    }
    // Timeout 5000 ms (PROVISIONAL) khi có AbortController; không có
    // thì gọi fetch thường (không timeout).
    if (typeof AbortController !== "undefined") {
      var controller = new AbortController();
      var timer = setTimeout(function () { controller.abort(); },
        REQUEST_TIMEOUT_MS);
      options = options || {};
      options.signal = controller.signal;
      return fetch(url, options).then(function (res) {
        clearTimeout(timer);
        return res;
      }, function (err) {
        clearTimeout(timer);
        throw err;
      });
    }
    return fetch(url, options);
  }

  // Gọi GET JSON, trả {ok:true, status, data} hoặc
  // {ok:false, reason} — không throw ra ngoài (event không cần try).
  function getJson(url) {
    return httpFetch(url, { method: "GET" }).then(function (res) {
      if (!res.ok) {
        return { ok: false, reason: "http-" + res.status };
      }
      return res.json().then(function (data) {
        return { ok: true, status: res.status, data: data };
      });
    }, function () {
      return { ok: false, reason: "khong-toi-duoc-server" };
    });
  }

  // Gọi POST JSON, trả {ok:true, status, data} hoặc
  // {ok:false, reason, status} — giữ status để phân biệt 409 (trùng
  // key) với lỗi mạng. Không throw ra ngoài.
  function postJson(url, body) {
    return httpFetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    }).then(function (res) {
      return res.json().then(function (data) {
        return { ok: res.ok, status: res.status, data: data };
      }, function () {
        return { ok: res.ok, status: res.status, data: null };
      });
    }, function () {
      return { ok: false, status: 0, reason: "khong-toi-duoc-server" };
    });
  }

  // --- Health check + số dư (endpoint thật) ---

  // GET /health — cập nhật state.online / lastHealthCheckAt /
  // lastHealthOk. Trả {ok:true, status, game, version} khi server
  // trả status "ok", ngược lại {ok:false, reason}.
  function healthCheck() {
    var st = state();
    return getJson(st.baseUrl + "/health").then(function (res) {
      st.lastHealthCheckAt = Date.now();
      if (res.ok && res.data && res.data.status === "ok") {
        st.online = true;
        st.lastHealthOk = true;
        return {
          ok: true, status: res.data.status, game: res.data.game,
          version: res.data.version
        };
      }
      st.online = false;
      st.lastHealthOk = false;
      return { ok: false, reason: res.reason || "health-khong-ok" };
    });
  }

  // GET /ledger/balance/{playerId} — số dư tiền mặt + tiết kiệm từ
  // sổ cái server (nguồn sự thật). Cache vào state.lastBalance để
  // hiển thị; cache hết hạn sau 60 giây (PROVISIONAL).
  // Trả {ok:true, playerId, cashVnd, savingsVnd} hoặc
  // {ok:false, reason}.
  function balanceOf(playerId) {
    var st = state();
    if (typeof playerId !== "string" || playerId.length === 0) {
      return Promise.resolve({ ok: false, reason: "thieu-player-id" });
    }
    return getJson(st.baseUrl + "/ledger/balance/" +
      encodeURIComponent(playerId)).then(function (res) {
      if (!res.ok || !res.data) {
        return { ok: false, reason: res.reason || "khong-lay-duoc-so-du" };
      }
      st.lastBalance = {
        playerId: res.data.playerId,
        cashVnd: res.data.cashVnd,
        savingsVnd: res.data.savingsVnd
      };
      st.lastBalanceAt = Date.now();
      return {
        ok: true, playerId: res.data.playerId,
        cashVnd: res.data.cashVnd, savingsVnd: res.data.savingsVnd
      };
    });
  }

  // Số dư cache còn hạn không (60 giây, PROVISIONAL) — event dùng để
  // quyết có gọi lại server hay hiển thị số cũ.
  function cachedBalanceFresh() {
    var st = state();
    return !!st.lastBalance &&
      (Date.now() - st.lastBalanceAt) < BALANCE_CACHE_MS;
  }

  // --- Tặng tiền (endpoint thật, có IdempotencyKey + outbox) ---

  // Sinh IdempotencyKey mới: "pxb-" + Date.now() + "-" + số ngẫu
  // nhiên. Key duy nhất mỗi lần tặng — server dùng key này để chặn
  // tặng trùng.
  function newIdempotencyKey() {
    return "pxb-" + Date.now() + "-" +
      Math.floor(Math.random() * 1000000000);
  }

  function hasSentKey(key) {
    return state().sentGiftKeys.indexOf(key) >= 0;
  }

  function rememberSentKey(key) {
    var st = state();
    if (st.sentGiftKeys.indexOf(key) < 0) {
      st.sentGiftKeys.push(key);
      // Giữ tối đa 200 key (PROVISIONAL) — cắt key cũ nhất.
      while (st.sentGiftKeys.length > SENT_KEYS_MAX) {
        st.sentGiftKeys.shift();
      }
    }
  }

  // Xếp 1 món tặng tiền vào outbox (khi offline). Trả true khi xếp
  // được, false khi outbox đã đầy 50 món (PROVISIONAL) — món mới bị
  // bỏ, không lặng lẽ ghi đè món cũ.
  function enqueueGift(item) {
    var st = state();
    if (st.outbox.length >= OUTBOX_MAX) return false;
    st.outbox.push(item);
    return true;
  }

  // Gửi 1 món tặng tiền lên server bằng key của chính món đó (không
  // sinh key mới khi gửi lại — server chặn trùng bằng key cũ).
  // Trả {ok:true, key} khi server nhận; {ok:false, reason, status}
  // khi lỗi. Server trả 409 = key đã có → coi như đã gửi xong.
  function sendGiftOnce(item) {
    var st = state();
    return postJson(st.baseUrl + "/ledger/gift", {
      FromPlayerId: item.fromPlayerId,
      ToPlayerId: item.toPlayerId,
      AmountVnd: item.amountVnd,
      GameDay: item.gameDay,
      IdempotencyKey: item.key
    }).then(function (res) {
      if (res.ok) {
        rememberSentKey(item.key);
        return { ok: true, key: item.key };
      }
      if (res.status === 409) {
        // Server đã có key này → đã tặng rồi, không tặng lần 2.
        rememberSentKey(item.key);
        return { ok: true, key: item.key, duplicate: true };
      }
      return {
        ok: false, key: item.key,
        reason: (res.data && res.data.error) ||
          res.reason || "gift-that-bai"
      };
    });
  }

  // Tặng tiền trong game (không lãi, không phí — đúng
  // EconomyLedger.Gift). amountVnd phải là số nguyên > 0; chưa có
  // giới hạn trên trong PXB_Balance (PROVISIONAL: chưa có cap).
  // - Key đã gửi rồi → {ok:false, reason:"trung-idempotency-key"},
  //   KHÔNG gửi lần 2.
  // - Gửi được → {ok:true, key}.
  // - Không tới được server → xếp vào outbox, trả
  //   {ok:false, reason:"offline-da-luu-outbox", queued:true}.
  // - Server từ chối (400: số tiền sai…) → {ok:false, reason}.
  // Có thể truyền key riêng (khi gửi lại từ outbox) — event thường
  // không truyền, để hàm tự sinh.
  function gift(fromPlayerId, toPlayerId, amountVnd, gameDay, key) {
    var st = state();
    if (typeof fromPlayerId !== "string" || fromPlayerId.length === 0 ||
        typeof toPlayerId !== "string" || toPlayerId.length === 0) {
      return Promise.resolve({ ok: false, reason: "thieu-player-id" });
    }
    if (typeof amountVnd !== "number" || Math.floor(amountVnd) !== amountVnd ||
        amountVnd <= 0) {
      return Promise.resolve({ ok: false, reason: "so-tien-khong-hop-le" });
    }
    var giftKey = (typeof key === "string" && key.length > 0) ?
      key : newIdempotencyKey();
    if (hasSentKey(giftKey)) {
      return Promise.resolve({
        ok: false, key: giftKey, reason: "trung-idempotency-key"
      });
    }
    var item = {
      key: giftKey,
      fromPlayerId: fromPlayerId,
      toPlayerId: toPlayerId,
      amountVnd: amountVnd,
      gameDay: (typeof gameDay === "number" && gameDay > 0) ?
        Math.floor(gameDay) : 1,
      queuedAt: Date.now()
    };
    return sendGiftOnce(item).then(function (res) {
      if (res.ok) return { ok: true, key: giftKey };
      if (res.reason === "khong-toi-duoc-server") {
        // Offline: xếp vào outbox để gửi lại khi online. Outbox đầy
        // thì báo rõ, không lặng lẽ mất món tặng.
        if (enqueueGift(item)) {
          st.online = false;
          return {
            ok: false, key: giftKey,
            reason: "offline-da-luu-outbox", queued: true
          };
        }
        return {
          ok: false, key: giftKey, reason: "outbox-day"
        };
      }
      return { ok: false, key: giftKey, reason: res.reason };
    });
  }

  // Gửi lại toàn bộ outbox khi online. Món gửi được hoặc server báo
  // 409 (đã có) thì xóa khỏi outbox; món lỗi mạng thì giữ lại.
  // Trả {sent, kept, failed} — sent: số món đã gửi xong, kept: số
  // món còn chờ, failed: số món lỗi không phải do mạng (400…).
  function flushOutbox() {
    var st = state();
    var items = st.outbox.slice();
    var sent = 0;
    var failed = 0;
    var chain = Promise.resolve();
    items.forEach(function (item) {
      chain = chain.then(function () {
        return sendGiftOnce(item).then(function (res) {
          if (res.ok) {
            var idx = st.outbox.indexOf(item);
            if (idx >= 0) st.outbox.splice(idx, 1);
            sent++;
          } else if (res.reason === "khong-toi-duoc-server") {
            st.online = false;
            // Giữ lại trong outbox, dừng gửi các món sau.
            return { stop: true };
          } else {
            failed++;
          }
          return null;
        });
      });
    });
    return chain.then(function () {
      return { sent: sent, kept: st.outbox.length, failed: failed };
    });
  }

  // Số món đang chờ trong outbox — event dùng để hiển thị.
  function outboxCount() { return state().outbox.length; }

  // --- Trade / đấu giá / công ty=guild: server CHƯA có endpoint ---
  // Mọi hàm dưới đây LUÔN trả {ok:false, reason:"server-chua-co-endpoint"}.
  // KHÔNG bịa endpoint, KHÔNG giả vờ thành công, KHÔNG tự quyết
  // tiền/đồ của người khác ở client. Khi server thêm endpoint thì
  // thay từng hàm bằng lệnh gọi thật (giữ nguyên chữ ký trả về).

  // Đề nghị đổi đồ với người chơi khác (đổi đồ lấy đồ, không dùng
  // tiền — xem PXB_Economy.barter cho đổi đồ offline).
  function createTradeOffer(fromPlayerId, toPlayerId, giveItemId,
      receiveItemId) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Chấp nhận 1 đề nghị đổi đồ (tradeId do server cấp sau này).
  function acceptTrade(tradeId, playerId) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Từ chối / hủy 1 đề nghị đổi đồ.
  function declineTrade(tradeId, playerId) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Xem danh sách đấu giá đang mở (server chưa có endpoint).
  function listAuctions() {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Đặt giá đấu giá. Phí sàn 5% (PXB_Balance.auctionFeePercent, đã
  // chốt) do SERVER tính khi có endpoint — client chỉ trả về
  // server-chua-co-endpoint, không tự tính tiền người bán ở đây
  // (xem PXB_Economy.auctionSellerReceives cho bản offline).
  function placeBid(auctionId, playerId, amountVnd) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Lập công ty (= guild): cần vốn 500 triệu + giấy phép (số ĐÃ
  // CHỐT trong PXB_Balance.companyCapitalVnd) — nhưng server chưa
  // có endpoint nên vẫn trả server-chua-co-endpoint, không tự trừ
  // tiền hay tạo công ty ở client.
  function createCompany(founderPlayerId, companyName) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Xin vào công ty (guild).
  function joinCompany(playerId, companyId) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // Đóng góp điểm / tiền cho công ty — 0 đóng góp 2 tuần thì bị loại
  // (luật GDD Mục 6) do server tính khi có endpoint.
  function contributeCompany(playerId, companyId, amountVnd) {
    return { ok: false, reason: REASON_NO_ENDPOINT };
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường (bất đồng bộ: kết
  // quả ghi vào state, event đọc lại bằng hàm đồng bộ):
  //   PXB_Online Health
  //     — health check, cập nhật state.online
  //   PXB_Online Balance <playerId>
  //     — lấy số dư, cache vào state.lastBalance
  //   PXB_Online Gift <from> <to> <amount> <gameDay>
  //     — tặng tiền (offline thì vào outbox)
  //   PXB_Online FlushOutbox
  //     — gửi lại toàn bộ outbox khi online
  // Trade / đấu giá / công ty KHÔNG qua plugin command (server chưa
  // có endpoint — event gọi trực tiếp để nhận reason rõ ràng).
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
              $gameSystem.pxbOnline) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbOnline;
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
        if (command === "PXB_Online") {
          if (args[0] === "Health") {
            healthCheck();
          } else if (args[0] === "Balance") {
            balanceOf(args[1]);
          } else if (args[0] === "Gift") {
            gift(args[1], args[2], parseInt(args[3], 10) || 0,
              parseInt(args[4], 10) || 1);
          } else if (args[0] === "FlushOutbox") {
            flushOutbox();
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

  var PXB_Online = {
    DEFAULT_BASE_URL: DEFAULT_BASE_URL,
    REQUEST_TIMEOUT_MS: REQUEST_TIMEOUT_MS,
    OUTBOX_MAX: OUTBOX_MAX,
    SENT_KEYS_MAX: SENT_KEYS_MAX,
    BALANCE_CACHE_MS: BALANCE_CACHE_MS,
    REASON_NO_ENDPOINT: REASON_NO_ENDPOINT,
    auctionFeePercent: auctionFeePercent,
    companyCapitalVnd: companyCapitalVnd,
    baseUrl: baseUrl,
    setBaseUrl: setBaseUrl,
    isOnline: isOnline,
    healthCheck: healthCheck,
    balanceOf: balanceOf,
    cachedBalanceFresh: cachedBalanceFresh,
    newIdempotencyKey: newIdempotencyKey,
    hasSentKey: hasSentKey,
    gift: gift,
    flushOutbox: flushOutbox,
    outboxCount: outboxCount,
    createTradeOffer: createTradeOffer,
    acceptTrade: acceptTrade,
    declineTrade: declineTrade,
    listAuctions: listAuctions,
    placeBid: placeBid,
    createCompany: createCompany,
    joinCompany: joinCompany,
    contributeCompany: contributeCompany,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Online;
  } else if (typeof window !== "undefined") {
    window.PXB_Online = PXB_Online;
  }
})();
