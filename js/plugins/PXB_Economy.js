/*:
 * @plugindesc Phố Xô Bồ — hệ kinh tế: ví tiền, tiết kiệm lãi 0,5%/tháng, mua nhà/xe/điện thoại/quần áo, đấu giá, đổi đồ, chia tài sản, set bonus, dress-code.
 * @author Muse Center
 *
 * @help
 * Port trung thực Economy.cs (src/client/Assets/Scripts/Economy.cs).
 *
 * - Catalog đầy đủ từ ItemCatalog: 6 nhà, 6 xe, 2 điện thoại, 3 quần
 *   áo. Mỗi món có 3 dòng chỉ số ItemStats: cộng chỉ số nhân vật
 *   (The/Tri/Tam/AnYen/Fame), mở nghề/danh hiệu (UnlocksJobOrTitle),
 *   tên set (SetName) để tính set bonus.
 * - Thang nhà 6 bậc là số đã chốt (GameBalance / PXB_Balance):
 *   phòng trọ thuê 2 triệu/tháng, chung cư mini 800 triệu, nhà phố
 *   nhỏ 3 tỉ, nhà phố lớn 8 tỉ, biệt thự 25 tỉ, penthouse/đảo 100 tỉ.
 * - Lãi tiết kiệm 0,5%/tháng game (đã chốt), phí đấu giá 5% (đã
 *   chốt), mua lớn (nhà hoặc xe sang) Danh vọng +50 (đã chốt).
 * - Ví tiền RIÊNG của Economy (money/savings trong state plugin),
 *   KHÔNG dùng $gameParty.gold() — vì Economy.cs quản ví riêng.
 *   Khác với PXB_Jobs (lương trả bằng $gameParty.gold()). Khi nối
 *   MV thật thì đồng bộ 1 chiều qua event (event tự cộng/trừ
 *   $gameParty theo kết quả buy/deposit/withdraw trả về).
 *
 * QUIRK GIỮ ĐÚNG C# (không tự sửa): totalAssets() = tiền mặt +
 * tiết kiệm + tổng giá đồ đã sở hữu, nên Buy("phong-tro") trừ tiền
 * thuê tháng nhưng vẫn cộng 2 triệu vào tài sản (phòng trọ nằm trong
 * Owned với PriceVnd = tiền thuê tháng). GDD xem lại thì sửa ở
 * Economy.cs + plugin này cùng lúc.
 *
 * RANH GIỚI PHÁP LÝ (đúng C# — hành vi bị chặn có chủ đích, không
 * phải tính năng thiếu): cashOut(), lendWithInterest(), gamble(),
 * buyWithRealMoney() LUÔN trả false, không làm gì cả. Không cash-out,
 * không giao dịch tiền thật, không cho vay lấy lãi giữa người chơi,
 * không cờ bạc.
 *
 * PROVISIONAL — chưa chốt GDD, đổi thì sửa ở đây + Economy.cs +
 * docs/economy.md cùng lúc:
 *   - 1 tháng game = 30 ngày (DaysPerGameMonth).
 *   - Điểm tín dụng khởi đầu 100 (creditScore).
 *   - Giá + chỉ số xe / điện thoại / quần áo (theo docs/economy.md,
 *     chưa có trong GameBalance).
 *   - Chỉ số ItemStats của nhà (ví dụ trong docs/economy.md).
 *   - Set bonus đủ 3 món cùng set: +10 Danh vọng, +5 An Yên.
 *   - Luật chia tài sản khi ly hôn: chia đôi tiền mặt + tiết kiệm
 *     (SplitAssets — luật slice).
 *   - Phạt dress-code khi phỏng vấn sai chuẩn: Giao tiếp −20
 *     (dressCodePenalty, trừ vào Tam tạm thời trong phiên phỏng vấn).
 *
 * Lưu: state sống trong $gameSystem.pxbEconomy nên đi theo save của
 * MV ($gameSystem vốn đã nằm trong save contents của core). Khi core
 * MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Economy.buy("nha-pho-nho")        // {ok:true, fameGained:50, reason:null}
 *   PXB_Economy.applyMonthlyInterest(60)  // lãi 2 tháng game đã cộng vào tiết kiệm
 *   PXB_Economy.depositSavings(5000000)   // true/false
 *   PXB_Economy.auctionSellerReceives(1000000)  // 950000
 *   PXB_Economy.passesDirectorDressCode() // true khi có đồ set "Công sở"/"Sang trọng"
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số với Economy.cs /
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

  // Fallback chỉ dùng khi PXB_Balance chưa load. Lãi 0,5%, phí 5%,
  // mua lớn +50 Danh vọng và thang nhà 6 bậc là số ĐÃ CHỐT.
  var FALLBACK = {
    bankInterestPerGameMonth: 0.005,
    auctionFeePercent: 5,
    bigPurchaseFameBonus: 50,
    roomRentPerMonthVnd: 2000000,
    miniApartmentVnd: 800000000,
    smallTownhouseVnd: 3000000000,
    largeTownhouseVnd: 8000000000,
    villaVnd: 25000000000,
    penthouseIslandVnd: 100000000000
  };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] !== "undefined") return b[key];
    return FALLBACK[key];
  }

  function bankInterestPerGameMonth() { return cfg("bankInterestPerGameMonth"); }
  function auctionFeePercent() { return cfg("auctionFeePercent"); }
  function bigPurchaseFameBonus() { return cfg("bigPurchaseFameBonus"); }

  // 1 tháng game = 30 ngày game — PROVISIONAL (khớp
  // Economy.DaysPerGameMonth; GDD chưa chốt độ dài tháng game).
  var DAYS_PER_GAME_MONTH = 30;

  // Set bonus: đủ 3 món cùng set → cộng thêm. Số PROVISIONAL.
  var SET_BONUS_FAME = 10;
  var SET_BONUS_AN_YEN = 5;

  // Đồ lệch chuẩn khi phỏng vấn: Giao tiếp −20 (docs/economy.md).
  // Giao tiếp lấy từ Tâm nên trừ vào Tam tạm thời trong phiên phỏng
  // vấn — PROVISIONAL. Export để event dùng.
  var DRESS_CODE_PENALTY = 20;

  // Điểm tín dụng khởi đầu — PROVISIONAL.
  var CREDIT_SCORE_START = 100;

  // --- Catalog (port trung thực ItemCatalog) ---

  // Một món đồ: {id, name, kind, priceVnd, stats}.
  // stats = {the, tri, tam, anYen, fame, unlocksJobOrTitle, setName}
  // khớp ItemStats(The, Tri, Tam, AnYen, Fame, UnlocksJobOrTitle,
  // SetName) trong Economy.cs.
  function item(id, name, kind, priceVnd, the, tri, tam, anYen, fame,
      unlocksJobOrTitle, setName) {
    return {
      id: id, name: name, kind: kind, priceVnd: priceVnd,
      stats: {
        the: the, tri: tri, tam: tam, anYen: anYen, fame: fame,
        unlocksJobOrTitle: unlocksJobOrTitle || null,
        setName: setName || null
      }
    };
  }

  // Thang nhà 6 bậc — giá đã chốt (GameBalance), chỉ số PROVISIONAL
  // theo ví dụ trong docs/economy.md.
  function houses() {
    return [
      item("phong-tro", "Phòng trọ", "House",
        cfg("roomRentPerMonthVnd"),
        -5, 0, 0, 5, 0, null, "Nhà ấm"),
      item("chung-cu-mini", "Chung cư mini", "House",
        cfg("miniApartmentVnd"),
        0, 5, 0, 10, 0, "Quản lý cần có nhà riêng", "Nhà ấm"),
      item("nha-pho-nho", "Nhà phố nhỏ", "House",
        cfg("smallTownhouseVnd"),
        0, 10, 0, 15, 0, "Giám đốc cần nhà phố", "Nhà ấm"),
      item("nha-pho-lon", "Nhà phố lớn", "House",
        cfg("largeTownhouseVnd"),
        0, 10, 10, 20, 0, "Giám đốc cần nhà phố", "Nhà ấm"),
      item("biet-thu", "Biệt thự", "House", cfg("villaVnd"),
        0, 0, 20, 30, 50, "Chủ Nhà Trọ cần 2 nhà cho thuê", "Nhà ấm"),
      item("penthouse-dao", "Penthouse / Đảo", "House",
        cfg("penthouseIslandVnd"),
        0, 10, 20, 30, 50, null, "Nhà ấm")
    ];
  }

  // Thang xe — giá + chỉ số theo docs/economy.md, PROVISIONAL (chưa
  // có trong GameBalance).
  function cars() {
    return [
      item("xe-dap", "Xe đạp", "Car", 0,
        5, 0, 0, 0, 0, null, null),
      item("xe-may-cu", "Xe máy cũ", "Car", 15000000,
        0, 0, 0, 0, 0, "Shipper", null),
      item("xe-may-moi", "Xe máy mới", "Car", 60000000,
        0, 0, 0, 5, 0, "Shipper", null),
      item("o-to-cu", "Ô tô cũ", "Car", 400000000,
        0, 0, 0, 0, 10, "Việc tầng cao", null),
      item("o-to-moi", "Ô tô mới", "Car", 1200000000,
        0, 0, 5, 10, 20, "Giám đốc cần xe", "Sang trọng"),
      item("xe-sang", "Xe sang", "Car", 5000000000,
        0, 0, 10, 10, 50, "Giám đốc cần xe", "Sang trọng")
    ];
  }

  // Điện thoại / quần áo — giá + chỉ số theo docs/economy.md,
  // PROVISIONAL (chưa có trong GameBalance).
  function phones() {
    return [
      item("dien-thoai-cu", "Điện thoại cũ", "Phone", 5000000,
        0, 0, 0, 0, 0, null, null),
      item("dien-thoai-flagship", "Điện thoại flagship", "Phone", 30000000,
        0, 10, 10, 0, 10, "Bác sĩ cần điện thoại tốt để trực", null)
    ];
  }

  function clothes() {
    return [
      item("ao-dai", "Áo dài", "Clothes", 2000000,
        0, 0, 15, 0, 10, null, "Truyền thống"),
      item("bo-cong-so", "Bộ công sở", "Clothes", 5000000,
        0, 0, 10, 0, 10, "Phỏng vấn quản lý", "Công sở"),
      item("vest-giam-doc", "Vest giám đốc", "Clothes", 20000000,
        0, 0, 10, 0, 20, "Giám đốc cần vest", "Công sở")
    ];
  }

  function getItem(id) {
    var lists = [houses(), cars(), phones(), clothes()];
    for (var i = 0; i < lists.length; i++) {
      for (var j = 0; j < lists[i].length; j++) {
        if (lists[i][j].id === id) return lists[i][j];
      }
    }
    return null;
  }

  // Toàn bộ catalog, đủ 4 nhóm — event lấy để hiển thị cửa hàng.
  function catalog() {
    return {
      houses: houses(), cars: cars(), phones: phones(), clothes: clothes()
    };
  }

  // --- State (sống trong $gameSystem.pxbEconomy để vào save) ---

  function defaultState() {
    return {
      money: 0,           // tiền mặt (đồng trong game)
      savings: 0,         // tiền tiết kiệm (đồng trong game)
      creditScore: CREDIT_SCORE_START, // PROVISIONAL — điểm tín dụng khởi đầu
      owned: []           // món đã sở hữu (OwnedItem, theo ItemCatalog)
    };
  }

  // State thuần mới — tương đương `new Economy(startingMoneyVnd)` trong
  // C#. Dùng cho phía đối tác của barter và cho test qua node.
  function createState(startingMoneyVnd) {
    var st = defaultState();
    st.money = (typeof startingMoneyVnd === "number" &&
      startingMoneyVnd > 0) ? Math.floor(startingMoneyVnd) : 0;
    return st;
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbEconomy) {
        $gameSystem.pxbEconomy = defaultState();
      }
      return $gameSystem.pxbEconomy;
    }
    return fallbackState;
  }

  // Khởi tạo pxbEconomy trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbEconomy) {
      $gameSystem.pxbEconomy = defaultState();
    }
    return true;
  }

  // Reset ví hiện tại (event/test dùng để phát tiền khởi đầu — tương
  // đương constructor Economy(startingMoneyVnd) trong C#).
  function resetState(startingMoneyVnd) {
    var st = state();
    st.money = (typeof startingMoneyVnd === "number" &&
      startingMoneyVnd > 0) ? Math.floor(startingMoneyVnd) : 0;
    st.savings = 0;
    st.creditScore = CREDIT_SCORE_START;
    st.owned = [];
    return true;
  }

  // Gán tiền mặt hiện tại (event/test dùng để nạp tiền khởi đầu hoặc
  // đồng bộ 1 chiều từ $gameParty). Trả false khi số tiền không hợp lệ.
  function setMoney(amountVnd) {
    if (typeof amountVnd !== "number" || amountVnd < 0 ||
        Math.floor(amountVnd) !== amountVnd) {
      return false;
    }
    state().money = amountVnd;
    return true;
  }

  // --- Ví tiền ---

  function money() { return state().money; }
  function savings() { return state().savings; }
  function creditScore() { return state().creditScore; }

  function owned() { return state().owned.slice(); }

  // Tổng tài sản = tiền mặt + tiết kiệm + tổng giá đồ đã sở hữu —
  // đúng Economy.TotalAssetsVnd, KỂ CẢ quirk phòng trọ (xem @help).
  function totalAssets() {
    var st = state();
    var total = st.money + st.savings;
    for (var i = 0; i < st.owned.length; i++) {
      total += st.owned[i].priceVnd;
    }
    return total;
  }

  // Lãi tiết kiệm: 0,5%/tháng game (đã chốt). 1 tháng game = 30 ngày
  // (PROVISIONAL). Trả lãi đã cộng vào tiết kiệm; 0 tháng hoặc tiết
  // kiệm = 0 thì trả 0 — đúng Economy.ApplyMonthlyInterest.
  function applyMonthlyInterest(gameDaysElapsed) {
    var st = state();
    var months = Math.floor(gameDaysElapsed / DAYS_PER_GAME_MONTH);
    if (months <= 0 || st.savings <= 0) return 0;
    var interest = Math.floor(
      st.savings * bankInterestPerGameMonth() * months);
    st.savings += interest;
    return interest;
  }

  // Gửi tiết kiệm: trả false khi amount <= 0 hoặc vượt tiền mặt.
  function depositSavings(amount) {
    var st = state();
    if (typeof amount !== "number" || amount <= 0 ||
        amount > st.money) {
      return false;
    }
    st.money -= amount;
    st.savings += amount;
    return true;
  }

  // Rút tiết kiệm: trả false khi amount <= 0 hoặc vượt tiết kiệm.
  function withdrawSavings(amount) {
    var st = state();
    if (typeof amount !== "number" || amount <= 0 ||
        amount > st.savings) {
      return false;
    }
    st.savings -= amount;
    st.money += amount;
    return true;
  }

  // Mua món đồ — đúng Economy.Buy. Trả:
  //   {ok:true, fameGained, reason:null}
  //   {ok:false, fameGained:0, reason:"khong-co-mon"} — món không có
  //   {ok:false, fameGained:0, reason:"khong-du-tien"} — không đủ tiền
  // Phòng trọ chỉ trừ tiền thuê tháng và vẫn thêm vào Owned (đúng C#,
  // xem quirk trong @help); mua nhà hoặc xe sang → fameGained = 50
  // (BigPurchaseFameBonus, đã chốt). Tiền dùng ví riêng của plugin,
  // KHÔNG dùng $gameParty.gold().
  function buy(itemId) {
    var st = state();
    var it = getItem(itemId);
    if (!it) return { ok: false, fameGained: 0, reason: "khong-co-mon" };
    if (it.kind === "House" && it.id === "phong-tro") {
      // Phòng trọ trả thuê tháng, không mua đứt.
      if (st.money < it.priceVnd) {
        return { ok: false, fameGained: 0, reason: "khong-du-tien" };
      }
      st.money -= it.priceVnd;
      st.owned.push(it);
      return { ok: true, fameGained: 0, reason: null };
    }
    if (st.money < it.priceVnd) {
      return { ok: false, fameGained: 0, reason: "khong-du-tien" };
    }
    st.money -= it.priceVnd;
    st.owned.push(it);
    var fameGained = 0;
    if (it.kind === "House" || it.id === "xe-sang") {
      fameGained = bigPurchaseFameBonus();
    }
    return { ok: true, fameGained: fameGained, reason: null };
  }

  // Sàn đấu giá: người bán nhận giá trừ phí 5% (đã chốt). Làm tròn
  // theo phép chia nguyên như C# (hammer × 95 / 100, cắt phần lẻ).
  function auctionSellerReceives(hammerPriceVnd) {
    return Math.trunc(
      hammerPriceVnd * (100 - auctionFeePercent()) / 100);
  }

  // Đồ đổi đồ (barter): không dùng tiền, không phí. otherState là
  // state object thuần của một Economy khác (dạng {money, savings,
  // owned} — xem createState()). Trả false khi 1 bên không có đồ —
  // đúng Economy.Barter.
  function barter(giveItemId, receiveItemId, otherState) {
    var st = state();
    if (!otherState || !Array.isArray(otherState.owned)) return false;
    var giveIndex = -1;
    for (var i = 0; i < st.owned.length; i++) {
      if (st.owned[i].id === giveItemId) { giveIndex = i; break; }
    }
    var receiveIndex = -1;
    for (var j = 0; j < otherState.owned.length; j++) {
      if (otherState.owned[j].id === receiveItemId) {
        receiveIndex = j;
        break;
      }
    }
    if (giveIndex < 0 || receiveIndex < 0) return false;
    var give = st.owned[giveIndex];
    var receive = otherState.owned[receiveIndex];
    st.owned.splice(giveIndex, 1);
    otherState.owned.splice(receiveIndex, 1);
    st.owned.push(receive);
    otherState.owned.push(give);
    return true;
  }

  // Ly hôn chia tài sản: chia đôi tiền mặt + tiết kiệm (luật slice,
  // PROVISIONAL). Trả {mine, theirs} — mine là phần còn lại của mình
  // (tiền mặt + tiết kiệm sau khi chia), theirs là phần chia cho bên
  // kia — đúng Economy.SplitAssets.
  function splitAssets() {
    var st = state();
    var halfMoney = Math.floor(st.money / 2);
    var halfSavings = Math.floor(st.savings / 2);
    st.money -= halfMoney;
    st.savings -= halfSavings;
    return {
      mine: st.money + st.savings,
      theirs: halfMoney + halfSavings
    };
  }

  // Set bonus: đủ 3 món cùng set → cộng thêm Danh vọng + An Yên (số
  // PROVISIONAL). Mỗi set đủ 3 món cộng 1 lần — đúng
  // Economy.SetBonus (chỉ tính, không tự cộng vào chỉ số nhân vật;
  // event lấy kết quả để cộng).
  function setBonus() {
    var st = state();
    var counts = {};
    for (var i = 0; i < st.owned.length; i++) {
      var setName = st.owned[i].stats.setName;
      if (!setName) continue;
      counts[setName] = (counts[setName] || 0) + 1;
    }
    var fame = 0;
    var anYen = 0;
    for (var k in counts) {
      if (counts[k] >= 3) {
        fame += SET_BONUS_FAME;
        anYen += SET_BONUS_AN_YEN;
      }
    }
    return { fame: fame, anYen: anYen };
  }

  // Kiểm tra dress-code: có đồ set "Công sở" hoặc "Sang trọng" thì
  // true — đúng Economy.PassesDirectorDressCode. Lưu ý C# chỉ xét đồ
  // loại Clothes, nên xe "Sang trọng" (o-to-moi, xe-sang) KHÔNG tính.
  function passesDirectorDressCode() {
    var st = state();
    for (var i = 0; i < st.owned.length; i++) {
      var it = st.owned[i];
      if (it.kind === "Clothes" &&
          (it.stats.setName === "Công sở" ||
           it.stats.setName === "Sang trọng")) {
        return true;
      }
    }
    return false;
  }

  // ===== RANH GIỚI PHÁP LÝ — các hành vi này BỊ CHẶN, không phải tính năng =====
  // Mỗi hàm LUÔN trả false, không làm gì cả — đúng Economy.cs. QC kiểm
  // tra tĩnh bắt được nếu ai vô tình "mở" lại chúng.

  // Cash-out: đổi tiền trong game ra tiền thật — CẤM. Luôn trả false.
  function cashOut(amountVnd) { return false; }

  // Cho vay lấy lãi giữa người chơi — CẤM. Luôn trả false.
  function lendWithInterest(borrower, amountVnd, interestRate) {
    return false;
  }

  // Cờ bạc / cá cược bằng tiền trong game — CẤM. Luôn trả false.
  function gamble(stakeVnd) { return false; }

  // Mua nhà / xe / chỉ số bằng tiền thật — CẤM. Nạp chỉ mua gói tháng,
  // mỹ phẩm, lượt thi. Luôn trả false.
  function buyWithRealMoney(itemId, realMoneyAmount) { return false; }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Economy Interest <gameDaysElapsed>  — cộng lãi cuối tháng
  //   PXB_Economy Deposit <amount>            — gửi tiết kiệm
  //   PXB_Economy Withdraw <amount>           — rút tiết kiệm
  // Mua đồ / đấu giá / đổi đồ / chia tài sản / set bonus / dress-code
  // KHÔNG qua plugin command (cần kết quả trả về) — event gọi trực
  // tiếp PXB_Economy.buy(...) v.v.
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
              $gameSystem.pxbEconomy) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbEconomy;
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
        if (command === "PXB_Economy") {
          if (args[0] === "Interest") {
            applyMonthlyInterest(parseInt(args[1], 10) || 0);
          } else if (args[0] === "Deposit") {
            depositSavings(parseInt(args[1], 10) || 0);
          } else if (args[0] === "Withdraw") {
            withdrawSavings(parseInt(args[1], 10) || 0);
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

  var PXB_Economy = {
    DAYS_PER_GAME_MONTH: DAYS_PER_GAME_MONTH,
    SET_BONUS_FAME: SET_BONUS_FAME,
    SET_BONUS_AN_YEN: SET_BONUS_AN_YEN,
    DRESS_CODE_PENALTY: DRESS_CODE_PENALTY,
    CREDIT_SCORE_START: CREDIT_SCORE_START,
    dressCodePenalty: DRESS_CODE_PENALTY,
    catalog: catalog,
    getItem: getItem,
    createState: createState,
    resetState: resetState,
    setMoney: setMoney,
    money: money,
    savings: savings,
    creditScore: creditScore,
    owned: owned,
    totalAssets: totalAssets,
    applyMonthlyInterest: applyMonthlyInterest,
    depositSavings: depositSavings,
    withdrawSavings: withdrawSavings,
    buy: buy,
    auctionSellerReceives: auctionSellerReceives,
    barter: barter,
    splitAssets: splitAssets,
    setBonus: setBonus,
    passesDirectorDressCode: passesDirectorDressCode,
    cashOut: cashOut,
    lendWithInterest: lendWithInterest,
    gamble: gamble,
    buyWithRealMoney: buyWithRealMoney,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Economy;
  } else if (typeof window !== "undefined") {
    window.PXB_Economy = PXB_Economy;
  }
})();
