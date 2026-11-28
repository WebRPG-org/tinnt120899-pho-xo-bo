/*:
 * @plugindesc Phố Xô Bồ — hệ xã hội: người yêu/vợ-chồng, bạn thân/hội bạn, gia đình, đối tác; bỏ bê 7 ngày giảm thân thiết, hỗ trợ +20% EXP, solo chậm 40%.
 * @author Muse Center
 *
 * @help
 * Port trung thực Social.cs (src/client/Assets/Scripts/Social.cs,
 * GDD Mục 8).
 *
 * - Ưu tiên theo thứ tự GDD: 1) Người yêu / Vợ – chồng, 2) Bạn thân /
 *   Hội bạn, 3) Gia đình, 4) Công ty / Đối tác làm ăn. Chơi 1 mình
 *   được nhưng chậm hơn, không có ending gia đình / cặp đôi.
 * - Bám Nadia (docs/nadia-reference.md #7, #9): quan hệ gắn nhân
 *   vật — quest giúp NPC đang khủng hoảng, NPC dẫn đường gợi ý bằng
 *   lời thoại, không phải menu quan hệ khô khan. KHÔNG lấy nội dung
 *   người lớn / harem.
 * - Số ĐÃ CHỐT (GameBalance / PXB_Balance): bỏ bê 7 ngày game thì
 *   thân thiết giảm; được hỗ trợ +20% EXP; solo chậm hơn 30–50%;
 *   hội bạn 3–5 người, họp hàng tuần không thì nhóm tan; tối đa
 *   2–3 quan hệ sâu (lấy 3).
 * - Quan hệ lưu dạng object thuần (JSON-safe) trong
 *   $gameSystem.pxbSocial = {relations: [...], marriages: [...]}
 *   nên đi theo save của MV. Mọi hàm đều nhận object thuần — không
 *   dùng class / closure giữ method, vì method mất khi save/load.
 *
 * QUIRK GIỮ ĐÚNG C# (không tự sửa):
 *   - applyNeglect() KHÔNG cập nhật lastInteractionGameDay: gọi 2
 *     lần cùng 1 ngày game thì trừ 2 lần. Event chỉ gọi 1 lần/ngày
 *     (qua plugin command Neglect) — đúng Social.cs.
 *   - advanceStage() KHÔNG kiểm tra Kind: Spouse cũng đi được
 *     HenHo → DinhHon → Cuoi như Lover — Social.cs cũng vậy, để
 *     GDD/PM xem lại (ghi trong docs/test-report.md từ 18/11).
 *   - divorce() CHỈ được khi vừa là Spouse vừa ở Stage Cuoi — đây
 *     là bug đã sửa 18/11 (trước đây dùng && nên Spouse chưa cưới
 *     vẫn ly hôn được). Điều kiện dùng ||, giữ đúng bản sửa.
 *
 * PROVISIONAL — chưa chốt GDD, đổi thì sửa ở đây + Social.cs +
 * docs/gdd.md Mục 8 cùng lúc:
 *   - Thân thiết khởi đầu khi mới quen: 20.
 *   - Mỗi lần gặp / nhắn tăng 5 thân thiết (interact).
 *   - Bỏ bê: giảm 10 thân thiết / mỗi 7 ngày (chỉ ngưỡng 7 ngày là
 *     số chốt).
 *   - Ngưỡng lên stage: HenHo ≥ 50, DinhHon ≥ 70 (phải từ HenHo),
 *     Cuoi ≥ 80 (phải từ DinhHon).
 *   - Có người hỗ trợ: quan hệ sâu có thân thiết ≥ 50.
 *   - Solo penalty: 40% (điểm giữa khoảng 30–50% đã chốt).
 *   - Nhóm tan: 7 ngày game không họp (lấy cùng ngưỡng bỏ bê).
 *   - NPC bạn thân lấp chỗ cho slice (seedSlice): "Bạn thân" là tên
 *     tạm — GDD Mục 11 chỉ chốt "NPC bạn thân lấp chỗ tạm thời",
 *     chưa chốt tên; PXB_Story sau này thay bằng NPC thật.
 *
 * Lưu: state sống trong $gameSystem.pxbSocial nên đi theo save của
 * MV ($gameSystem vốn đã nằm trong save contents của core). Khi core
 * MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Social.add(PXB_Social.createRelationship("co-tu", "Cô Tư", "BestFriend", 1))
 *   PXB_Social.interact("co-tu", 5)              // gặp cô Tư ngày game 5
 *   PXB_Social.applyNeglect(12)                  // trừ thân thiết các quan hệ bỏ bê
 *   PXB_Social.advanceStage("nguoi-yeu", "HenHo") // true/false
 *   PXB_Social.applySupportBonus(100)            // 120 khi có người hỗ trợ
 *   PXB_Social.applySoloPenalty(100)             // 60 khi chơi solo
 *   PXB_Social.divorce("vo")                     // chỉ Spouse đang Cuoi mới được
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số với Social.cs /
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

  // Fallback chỉ dùng khi PXB_Balance chưa load. Bỏ bê 7 ngày, +20%
  // EXP hỗ trợ, solo chậm 30–50% là số ĐÃ CHỐT.
  var FALLBACK = {
    neglectDaysToDropCloseness: 7,
    supportedExpBonusPercent: 20,
    soloSlowerPercentMin: 30,
    soloSlowerPercentMax: 50
  };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] !== "undefined") return b[key];
    return FALLBACK[key];
  }

  function neglectDaysToDropCloseness() {
    return cfg("neglectDaysToDropCloseness");
  }
  function supportedExpBonusPercent() {
    return cfg("supportedExpBonusPercent");
  }

  // --- Hằng PROVISIONAL (xem @help) ---

  // Tối đa 2–3 quan hệ sâu (GDD chốt khoảng 2–3) — lấy 3.
  var MAX_DEEP_RELATIONSHIPS = 3;
  // Hội bạn 3–5 người (GDD Mục 8 đã chốt).
  var MAX_GROUP_MEMBERS = 5;
  var MIN_GROUP_MEMBERS = 3;
  // Thân thiết khởi đầu khi mới quen.
  var CLOSENESS_START = 20;
  // Mỗi lần gặp / nhắn tăng 5 thân thiết.
  var INTERACT_GAIN = 5;
  // Bỏ bê: giảm 10 thân thiết / mỗi 7 ngày.
  var NEGLECT_DROP_PER_STEP = 10;
  // Ngưỡng thân thiết để lên stage hẹn hò / đính hôn / cưới.
  var STAGE_HEN_HO_MIN = 50;
  var STAGE_DINH_HON_MIN = 70;
  var STAGE_CUOI_MIN = 80;
  // Có người hỗ trợ: quan hệ sâu có thân thiết ≥ 50.
  var SUPPORTER_CLOSENESS_MIN = 50;
  // Solo penalty 40% — điểm giữa khoảng 30–50% đã chốt.
  var SOLO_PENALTY_PERCENT = 40;

  // --- Loại quan hệ + giai đoạn (port enum Social.cs) ---

  var KINDS = {
    LOVER: "Lover",              // Người yêu
    SPOUSE: "Spouse",            // Vợ / chồng
    BEST_FRIEND: "BestFriend",   // Bạn thân (tối đa 1)
    FRIEND_GROUP: "FriendGroup", // Hội bạn (nhóm 3–5 người)
    PARENT: "Parent",            // Cha / mẹ
    CHILD: "Child",              // Con cái
    COMPANY_PARTNER: "CompanyPartner" // Đối tác làm ăn / công ty
  };

  var STAGES = {
    QUEN_BIET: "QuenBiet",   // mới quen
    THAN_THIET: "ThanThiet", // thân thiết
    HEN_HO: "HenHo",         // đang hẹn hò (chỉ Lover)
    DINH_HON: "DinhHon",     // đã đính hôn (chỉ Lover)
    CUOI: "Cuoi",            // đã cưới (chỉ Spouse)
    TAN_RA: "TanRa"          // đã tan / ly hôn — giữ lại để tính lịch sử
  };

  // --- Quan hệ (object thuần, JSON-safe) ---

  // Tạo 1 quan hệ mới — tương đương `new Relationship(...)` trong C#.
  // Thân thiết khởi đầu 20 (PROVISIONAL), stage QuenBiet.
  function createRelationship(personId, displayName, kind, startGameDay) {
    return {
      personId: personId,
      displayName: displayName,
      kind: kind,
      stage: STAGES.QUEN_BIET,
      closeness: CLOSENESS_START,
      lastInteractionGameDay: (typeof startGameDay === "number" &&
        startGameDay > 0) ? Math.floor(startGameDay) : 1
    };
  }

  // Quan hệ sâu? Lover / Spouse / BestFriend / Parent / Child, chưa tan.
  // Đúng Relationship.IsDeep trong Social.cs.
  function isDeep(rel) {
    if (!rel || rel.stage === STAGES.TAN_RA) return false;
    return rel.kind === KINDS.LOVER || rel.kind === KINDS.SPOUSE ||
      rel.kind === KINDS.BEST_FRIEND || rel.kind === KINDS.PARENT ||
      rel.kind === KINDS.CHILD;
  }

  // Gặp / nhắn: cập nhật ngày tương tác cuối + tăng thân thiết (kẹp
  // 0..100). gain mặc định 5 (PROVISIONAL) — đúng Relationship.Interact.
  function interact(rel, gameDay, closenessGain) {
    if (!rel) return false;
    var gain = (typeof closenessGain === "number") ?
      closenessGain : INTERACT_GAIN;
    rel.lastInteractionGameDay = gameDay;
    rel.closeness = Math.max(0, Math.min(100, rel.closeness + gain));
    return true;
  }

  // Bỏ bê: quá 7 ngày game không tương tác thì thân thiết giảm 10 /
  // mỗi 7 ngày (chỉ ngưỡng 7 ngày là số chốt). Trả số đã giảm; 0 nếu
  // chưa tới ngưỡng. KHÔNG cập nhật lastInteractionGameDay (đúng C# —
  // xem quirk trong @help: event chỉ gọi 1 lần/ngày).
  function applyNeglect(rel, currentGameDay) {
    if (!rel) return 0;
    var daysIdle = currentGameDay - rel.lastInteractionGameDay;
    if (daysIdle < neglectDaysToDropCloseness()) return 0;
    var steps = Math.floor(daysIdle / neglectDaysToDropCloseness());
    var drop = steps * NEGLECT_DROP_PER_STEP;
    rel.closeness = Math.max(0, Math.min(100, rel.closeness - drop));
    return drop;
  }

  // Lên stage: HenHo cần thân thiết ≥ 50; DinhHon phải từ HenHo +
  // ≥ 70; Cuoi phải từ DinhHon + ≥ 80. Ngưỡng PROVISIONAL. KHÔNG
  // kiểm tra Kind (đúng Social.cs — xem quirk trong @help).
  function advanceStage(rel, next) {
    if (!rel) return false;
    if (next === STAGES.HEN_HO && rel.closeness < STAGE_HEN_HO_MIN) {
      return false;
    }
    if (next === STAGES.DINH_HON &&
        (rel.stage !== STAGES.HEN_HO ||
         rel.closeness < STAGE_DINH_HON_MIN)) {
      return false;
    }
    if (next === STAGES.CUOI &&
        (rel.stage !== STAGES.DINH_HON ||
         rel.closeness < STAGE_CUOI_MIN)) {
      return false;
    }
    rel.stage = next;
    return true;
  }

  // Chia tay / ly hôn ở mức quan hệ: stage TanRa, thân thiết về 0.
  function breakUp(rel) {
    if (!rel) return false;
    rel.stage = STAGES.TAN_RA;
    rel.closeness = 0;
    return true;
  }

  // --- Sổ quan hệ (state thuần, JSON-safe) ---

  function defaultState() {
    return {
      relations: [], // Relationship[] (object thuần)
      marriages: []  // PersonId đã cưới
    };
  }

  // State thuần mới — tương đương `new SocialBook()` trong C#.
  function createBookState() {
    return defaultState();
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbSocial) {
        $gameSystem.pxbSocial = defaultState();
      }
      return $gameSystem.pxbSocial;
    }
    return fallbackState;
  }

  // Khởi tạo pxbSocial trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbSocial) {
      $gameSystem.pxbSocial = defaultState();
    }
    return true;
  }

  // Reset sổ hiện tại (event/test dùng để bắt đầu lại — tương đương
  // new SocialBook() trong C#).
  function resetState() {
    var st = state();
    st.relations = [];
    st.marriages = [];
    return true;
  }

  // --- Sổ quan hệ: thao tác trên 1 book state thuần ---

  function allRelations(book) {
    return (book && Array.isArray(book.relations)) ?
      book.relations.slice() : [];
  }

  function getRel(book, personId) {
    if (!book || !Array.isArray(book.relations)) return null;
    for (var i = 0; i < book.relations.length; i++) {
      if (book.relations[i].personId === personId) {
        return book.relations[i];
      }
    }
    return null;
  }

  function deepCount(book) {
    var count = 0;
    var rels = allRelations(book);
    for (var i = 0; i < rels.length; i++) {
      if (isDeep(rels[i])) count++;
    }
    return count;
  }

  function hasBestFriend(book) {
    var rels = allRelations(book);
    for (var i = 0; i < rels.length; i++) {
      if (rels[i].kind === KINDS.BEST_FRIEND &&
          rels[i].stage !== STAGES.TAN_RA) {
        return true;
      }
    }
    return false;
  }

  // Thêm quan hệ mới. Trả false nếu đã có người đó, đã đủ 3 quan hệ
  // sâu, hoặc đã có bạn thân khác — đúng SocialBook.Add.
  function addRel(book, rel) {
    if (!book || !rel || !rel.personId) return false;
    if (!Array.isArray(book.relations)) book.relations = [];
    if (getRel(book, rel.personId)) return false;
    if (isDeep(rel) && deepCount(book) >= MAX_DEEP_RELATIONSHIPS) {
      return false;
    }
    if (rel.kind === KINDS.BEST_FRIEND && hasBestFriend(book)) {
      return false;
    }
    book.relations.push(rel);
    return true;
  }

  // Có quan hệ sâu thân thiết đang hỗ trợ mình không (thân thiết
  // ≥ 50, PROVISIONAL) — đúng SocialBook.HasSupporter.
  function hasSupporter(book) {
    var rels = allRelations(book);
    for (var i = 0; i < rels.length; i++) {
      if (isDeep(rels[i]) &&
          rels[i].closeness >= SUPPORTER_CLOSENESS_MIN) {
        return true;
      }
    }
    return false;
  }

  // EXP nhận được khi được người thân hỗ trợ: +20% (đã chốt).
  // Đúng SocialBook.ApplySupportBonus.
  function applySupportBonus(book, baseExp) {
    if (hasSupporter(book)) {
      return Math.floor(
        baseExp * (100 + supportedExpBonusPercent()) / 100);
    }
    return baseExp;
  }

  // Solo (không có supporter): chậm hơn 40% — điểm giữa khoảng
  // 30–50% đã chốt, PROVISIONAL. Đúng SocialBook.ApplySoloPenalty.
  function applySoloPenalty(book, baseExp) {
    if (hasSupporter(book)) return baseExp;
    return Math.floor(baseExp * (100 - SOLO_PENALTY_PERCENT) / 100);
  }

  // Hội bạn tan nếu 7 ngày game không họp (PROVISIONAL — lấy cùng
  // ngưỡng bỏ bê 7 ngày). Trả true nếu nhóm đã tan — đúng
  // SocialBook.CheckGroupDissolved.
  function checkGroupDissolved(book, group, currentGameDay) {
    if (!group || group.kind !== KINDS.FRIEND_GROUP) return false;
    return currentGameDay - group.lastInteractionGameDay >=
      neglectDaysToDropCloseness();
  }

  // Ly hôn: chỉ ly hôn được khi vừa là Spouse vừa đang ở Stage Cuoi
  // (bug đã sửa 18/11 — xem @help). Ở đây chỉ đổi trạng thái; việc
  // chia tiền làm ở PXB_Economy.splitAssets — đúng SocialBook.Divorce.
  function divorce(book, personId) {
    var rel = getRel(book, personId);
    if (!rel || rel.kind !== KINDS.SPOUSE ||
        rel.stage !== STAGES.CUOI) {
      return false;
    }
    breakUp(rel);
    if (book && Array.isArray(book.marriages)) {
      var idx = book.marriages.indexOf(personId);
      if (idx >= 0) book.marriages.splice(idx, 1);
    }
    return true;
  }

  function recordMarriage(book, personId) {
    if (!book || !personId) return false;
    if (!Array.isArray(book.marriages)) book.marriages = [];
    if (book.marriages.indexOf(personId) < 0) {
      book.marriages.push(personId);
    }
    return true;
  }

  function isMarriedTo(book, personId) {
    if (!book || !Array.isArray(book.marriages)) return false;
    return book.marriages.indexOf(personId) >= 0;
  }

  // Áp bỏ bê cho TOÀN BỘ quan hệ trong sổ ở ngày game hiện tại.
  // Trả tổng số thân thiết đã giảm — event gọi 1 lần/ngày (xem quirk
  // applyNeglect trong @help).
  function applyNeglectAll(book, currentGameDay) {
    var total = 0;
    var rels = allRelations(book);
    for (var i = 0; i < rels.length; i++) {
      total += applyNeglect(rels[i], currentGameDay);
    }
    return total;
  }

  // NPC bạn thân lấp chỗ cho slice (GDD Mục 11: "NPC bạn thân lấp chỗ
  // tạm thời"). Tên + PersonId là TẠM — PXB_Story sau này thay bằng
  // NPC thật. Chỉ gọi 1 lần khi new game / bắt đầu slice.
  function seedSlice(book, startGameDay) {
    if (!book) return false;
    if (getRel(book, "ban-than")) return false;
    var friend = createRelationship(
      "ban-than", "Bạn thân", KINDS.BEST_FRIEND, startGameDay || 1);
    return addRel(book, friend);
  }

  // --- Wrapper trên state hiện tại (event gọi trực tiếp) ---

  function add(rel) { return addRel(state(), rel); }
  function get(personId) { return getRel(state(), personId); }
  function all() { return allRelations(state()); }
  function deepCountNow() { return deepCount(state()); }
  function hasBestFriendNow() { return hasBestFriend(state()); }
  function hasSupporterNow() { return hasSupporter(state()); }
  function supportBonus(baseExp) {
    return applySupportBonus(state(), baseExp);
  }
  function soloPenalty(baseExp) {
    return applySoloPenalty(state(), baseExp);
  }
  function interactNow(personId, gameDay, closenessGain) {
    var rel = getRel(state(), personId);
    if (!rel) return false;
    return interact(rel, gameDay, closenessGain);
  }
  function applyNeglectNow(currentGameDay) {
    return applyNeglectAll(state(), currentGameDay);
  }
  function advanceStageNow(personId, next) {
    var rel = getRel(state(), personId);
    if (!rel) return false;
    return advanceStage(rel, next);
  }
  function divorceNow(personId) { return divorce(state(), personId); }
  function recordMarriageNow(personId) {
    return recordMarriage(state(), personId);
  }
  function isMarriedToNow(personId) {
    return isMarriedTo(state(), personId);
  }
  function checkGroupDissolvedNow(group, currentGameDay) {
    return checkGroupDissolved(state(), group, currentGameDay);
  }
  function seedSliceNow(startGameDay) {
    return seedSlice(state(), startGameDay);
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Social Interact <personId> <gameDay> [gain] — gặp/nhắn 1 người
  //   PXB_Social Neglect <currentGameDay>              — trừ thân thiết bỏ bê
  //   PXB_Social AdvanceStage <personId> <stage>       — HenHo/DinhHon/Cuoi
  //   PXB_Social Divorce <personId>                    — ly hôn (chỉ Spouse+Cuoi)
  //   PXB_Social SeedSlice [startGameDay]              — thêm NPC bạn thân tạm
  // Thêm / lấy quan hệ, tính EXP bonus / solo penalty KHÔNG qua plugin
  // command (cần kết quả trả về) — event gọi trực tiếp
  // PXB_Social.add(...) / .get(...) / .supportBonus(...) v.v.
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
              $gameSystem.pxbSocial) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbSocial;
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
        if (command === "PXB_Social") {
          if (args[0] === "Interact") {
            interactNow(args[1], parseInt(args[2], 10) || 1,
              args[3] ? parseInt(args[3], 10) : undefined);
          } else if (args[0] === "Neglect") {
            applyNeglectNow(parseInt(args[1], 10) || 1);
          } else if (args[0] === "AdvanceStage") {
            advanceStageNow(args[1], args[2]);
          } else if (args[0] === "Divorce") {
            divorceNow(args[1]);
          } else if (args[0] === "SeedSlice") {
            seedSliceNow(parseInt(args[1], 10) || 1);
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

  var PXB_Social = {
    MAX_DEEP_RELATIONSHIPS: MAX_DEEP_RELATIONSHIPS,
    MAX_GROUP_MEMBERS: MAX_GROUP_MEMBERS,
    MIN_GROUP_MEMBERS: MIN_GROUP_MEMBERS,
    CLOSENESS_START: CLOSENESS_START,
    INTERACT_GAIN: INTERACT_GAIN,
    NEGLECT_DROP_PER_STEP: NEGLECT_DROP_PER_STEP,
    STAGE_HEN_HO_MIN: STAGE_HEN_HO_MIN,
    STAGE_DINH_HON_MIN: STAGE_DINH_HON_MIN,
    STAGE_CUOI_MIN: STAGE_CUOI_MIN,
    SUPPORTER_CLOSENESS_MIN: SUPPORTER_CLOSENESS_MIN,
    SOLO_PENALTY_PERCENT: SOLO_PENALTY_PERCENT,
    KINDS: KINDS,
    STAGES: STAGES,
    createRelationship: createRelationship,
    isDeep: isDeep,
    interact: interact,
    applyNeglect: applyNeglect,
    advanceStage: advanceStage,
    breakUp: breakUp,
    createBookState: createBookState,
    allRelations: allRelations,
    getRel: getRel,
    deepCount: deepCount,
    hasBestFriend: hasBestFriend,
    addRel: addRel,
    hasSupporter: hasSupporter,
    applySupportBonus: applySupportBonus,
    applySoloPenalty: applySoloPenalty,
    checkGroupDissolved: checkGroupDissolved,
    divorce: divorce,
    recordMarriage: recordMarriage,
    isMarriedTo: isMarriedTo,
    applyNeglectAll: applyNeglectAll,
    seedSlice: seedSlice,
    add: add,
    get: get,
    all: all,
    deepCountNow: deepCountNow,
    hasBestFriendNow: hasBestFriendNow,
    hasSupporterNow: hasSupporterNow,
    supportBonus: supportBonus,
    soloPenalty: soloPenalty,
    interactNow: interactNow,
    applyNeglectNow: applyNeglectNow,
    advanceStageNow: advanceStageNow,
    divorceNow: divorceNow,
    recordMarriageNow: recordMarriageNow,
    isMarriedToNow: isMarriedToNow,
    checkGroupDissolvedNow: checkGroupDissolvedNow,
    seedSliceNow: seedSliceNow,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Social;
  } else if (typeof window !== "undefined") {
    window.PXB_Social = PXB_Social;
  }
})();
