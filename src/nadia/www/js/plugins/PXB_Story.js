/*:
 * @plugindesc Phố Xô Bồ — cốt truyện 5 chương + nhiều kết thúc chữa lành: mở chương theo Trí/Danh vọng/tài sản, quest giúp người, gợi ý ending theo thứ tự ưu tiên cứng.
 * @author Muse Center
 *
 * @help
 * Port trung thực PlayerProgress.cs
 * (src/client/Assets/Scripts/PlayerProgress.cs, GDD Mục 9 + Mục 12).
 *
 * - 5 chương gắn bậc: 1 Lên Phố (Lao động) → 2 Lập Nghiệp (Cận trung
 *   lưu) → 3 Khủng Hoảng (bài kiểm tra bậc, có thể tụt nhưng không
 *   phạt nặng) → 4 Vực Dậy (Trung lưu) → 5 Thành Đạt / An Yên (nhiều
 *   kết thúc đều tính là thắng — Mục 12, chữa lành).
 * - Chương 4 cần 3 quest giúp NPC đang khủng hoảng + ít nhất 1 quan
 *   hệ thân thiết (GDD Mục 9; hasCloseRelationship lấy từ PXB_Social
 *   — quan hệ sâu thân thiết ≥ 50 là "có người hỗ trợ").
 * - Bám Nadia (docs/nadia-reference.md): NPC có câu chuyện mất mục
 *   tiêu của riêng họ — giúp họ thì họ giúp lại mình; thất bại không
 *   bị phạt, NPC giúp đỡ và được làm lại.
 * - Số ĐÃ CHỐT (GDD Mục 9 / GameBalance.cs / PlayerProgress.cs):
 *   Trí 40 (mở chương 2) / 60 (mở chương 5) / 90 (Học giả);
 *   Danh vọng 200 (chương 2) / 500 (chương 5) / 1500 (Học giả);
 *   tài sản 10 tỉ (Giám đốc) / 100 tỉ (Siêu giàu);
 *   An Yên 80 (Gia đình / Tự do); Danh vọng 100 / An Yên 30
 *   (ngưỡng rank có thể tụt ở chương 3); 3 quest giúp người (chương 4).
 * - Tiến trình lưu dạng object thuần (JSON-safe) trong
 *   $gameSystem.pxbStory = {chapter, helpQuestsDone, chapter3Passed,
 *   ending, unlockedChapters} nên đi theo save của MV. Mọi hàm đều
 *   nhận object thuần — không dùng class / closure giữ method, vì
 *   method mất khi save/load.
 *
 * QUIRK GIỮ ĐÚNG C# (không tự sửa):
 *   - canOpenChapter(KhungHoang) LUÔN true — chương 3 là bài kiểm
 *     tra, mở khi đã qua chương 2. Điều kiện "đã qua chương 2" do
 *     story state kiểm (advanceChapter chỉ đi chapter+1 nên khi mở
 *     chương 3 thì state.chapter đã = 2), KHÔNG phải hàm này.
 *   - suggestEnding() có THỨ TỰ ƯU TIÊN CỨNG: SieuGiau (≥100 tỉ)
 *     → GiamDoc (≥10 tỉ) → HocGia (Trí ≥ 90 VÀ Danh vọng ≥ 1500)
 *     → GiaDinh (có vợ/chồng VÀ An Yên ≥ 80) → TuDo (An Yên ≥ 80)
 *     → ChuaMo. Người chơi đủ điều kiện nhiều ending cùng lúc vẫn
 *     chỉ nhận ending ưu tiên cao nhất — để GDD/PM xem lại (ghi
 *     trong docs/test-report.md từ 18/11).
 *   - rankAtRisk() chỉ báo "có thể tụt bậc" khi Danh vọng < 100
 *     HOẶC An Yên < 30 — không tự trừ bậc, không phạt (Mục 12).
 *
 * LỆCH C# SO VỚI GDD (ghi để GDD/PM xem lại, plugin giữ đúng C#):
 *   - Chương 2: GDD ghi "Trí 40 hoặc Cao đẳng, Danh vọng 200" —
 *     C# chỉ kiểm Trí ≥ 40 HOẶC Danh vọng ≥ 200, không có đường
 *     riêng cho bằng Cao đẳng. (GameBalance: Cao đẳng cho Trí 40
 *     nên thực tế 2 đường trùng nhau.)
 *   - Chương 5 Học giả: GDD ghi "Tiến sĩ, Trí 90, Danh vọng
 *     1.500" — C# chỉ kiểm Trí ≥ 90 VÀ Danh vọng ≥ 1500, không
 *     kiểm bằng Tiến sĩ. (GameBalance: Tiến sĩ cho Trí 90 /
 *     Danh vọng 1500 nên thực tế cũng trùng.)
 *   - Chương 5 Gia đình: GDD ghi "Trung lưu + vợ/chồng + An Yên
 *     80" — C# chỉ kiểm có vợ/chồng VÀ An Yên ≥ 80, không kiểm
 *     rank Trung lưu.
 *
 * PROVISIONAL — chưa chốt GDD, đổi thì sửa ở đây +
 * PlayerProgress.cs + docs/gdd.md Mục 9 cùng lúc:
 *   - Không có số PROVISIONAL nào trong plugin này: mọi ngưỡng đều
 *     là số ĐÃ CHỐT ở trên. Các hàm wrapper chỉ đọc chỉ số hiện
 *     tại của người chơi (Trí / Danh vọng / tài sản / An Yên lấy từ
 *     PXB_Stats / PXB_Economy khi gọi từ event).
 *
 * Lưu: state sống trong $gameSystem.pxbStory nên đi theo save của
 * MV ($gameSystem vốn đã nằm trong save contents của core). Khi core
 * MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Story.canOpenChapter(2, 35, 210, 0, false, 0) // true (Danh vọng 210)
 *   PXB_Story.advanceChapterNow(45, 0, 0, false)      // 1 → 2 khi Trí 45
 *   PXB_Story.recordHelpQuestNow()                     // giúp 1 NPC, trả số mới
 *   PXB_Story.passChapter3Now()                        // chỉ khi đang ở chương 3
 *   PXB_Story.suggestEndingNow(0, 95, 1600, 50, false) // "HocGia", lưu vào state
 *   PXB_Story.rankAtRiskNow(80, 50)                    // true (Danh vọng < 100)
 */
(function () {
  "use strict";

  // --- Ngưỡng ĐÃ CHỐT (GDD Mục 9 / GameBalance.cs) ---

  // Mở chương 2: Trí ≥ 40 HOẶC Danh vọng ≥ 200.
  var CHAPTER2_TRI_MIN = 40;
  var CHAPTER2_DANH_VONG_MIN = 200;
  // Mở chương 4: giúp ≥ 3 NPC đang khủng hoảng + có quan hệ thân thiết.
  var CHAPTER4_HELP_QUESTS_MIN = 3;
  // Mở chương 5: Trí ≥ 60 HOẶC Danh vọng ≥ 500 HOẶC tài sản ≥ 10 tỉ.
  var CHAPTER5_TRI_MIN = 60;
  var CHAPTER5_DANH_VONG_MIN = 500;
  var CHAPTER5_TAI_SAN_MIN = 10000000000; // 10 tỉ VND
  // Ending Học giả: Trí ≥ 90 VÀ Danh vọng ≥ 1500.
  var ENDING_HOC_GIA_TRI_MIN = 90;
  var ENDING_HOC_GIA_DANH_VONG_MIN = 1500;
  // Ending Siêu giàu: tài sản ≥ 100 tỉ. Giám đốc: tài sản ≥ 10 tỉ
  // (dùng lại CHAPTER5_TAI_SAN_MIN).
  var ENDING_SIEU_GIAU_TAI_SAN_MIN = 100000000000; // 100 tỉ VND
  // Ending Gia đình / Tự do: An Yên ≥ 80.
  var ENDING_AN_YEN_MIN = 80;
  // Rank có thể tụt ở chương 3: Danh vọng < 100 HOẶC An Yên < 30.
  var RANK_AT_RISK_DANH_VONG_MAX = 100;
  var RANK_AT_RISK_AN_YEN_MAX = 30;

  // --- Chương + kết thúc (port enum PlayerProgress.cs) ---

  var CHAPTERS = {
    LEN_PHO: 1,    // Lên Phố — Lao động
    LAP_NGHIEP: 2, // Lập Nghiệp — Cận trung lưu
    KHUNG_HOANG: 3,// Khủng Hoảng — bài kiểm tra bậc
    VUC_DAY: 4,    // Vực Dậy — Trung lưu
    THANH_DAT: 5   // Thành Đạt / An Yên — nhánh rank
  };

  var ENDINGS = {
    GIAM_DOC: "GiamDoc", // Giám đốc — Thượng lưu, tài sản 10 tỉ
    HOC_GIA: "HocGia",   // Học giả — Tiến sĩ, Trí 90, Danh vọng 1500
    GIA_DINH: "GiaDinh", // Gia đình — vợ/chồng + An Yên 80
    TU_DO: "TuDo",       // Tự do — An Yên 80, sống an yên
    SIEU_GIAU: "SieuGiau", // Siêu giàu — tài sản 100 tỉ
    CHUA_MO: "ChuaMo"    // Chưa mở — chưa đủ điều kiện ending nào
  };

  // Tên hiển thị tiếng Việt của từng chương (chỉ để event / UI dùng).
  var CHAPTER_NAMES = {
    1: "Lên Phố",
    2: "Lập Nghiệp",
    3: "Khủng Hoảng",
    4: "Vực Dậy",
    5: "Thành Đạt"
  };

  // --- Điều kiện mở chương — đúng PlayerProgress.CanOpenChapter ---

  // chapter: số 1–5 (CHAPTERS). tri / danhVong / taiSan: chỉ số hiện
  // tại. hasCloseRelationship: có ít nhất 1 quan hệ thân thiết.
  // helpQuestsDone: số quest giúp NPC đã làm xong.
  // Chương lạ (ngoài 1–5) → false.
  function canOpenChapter(chapter, tri, danhVong, taiSan,
      hasCloseRelationship, helpQuestsDone) {
    if (chapter === CHAPTERS.LEN_PHO) return true;
    if (chapter === CHAPTERS.LAP_NGHIEP) {
      return tri >= CHAPTER2_TRI_MIN ||
        danhVong >= CHAPTER2_DANH_VONG_MIN;
    }
    // Chương 3 là bài kiểm tra, mở khi đã qua chương 2 — điều kiện
    // "đã qua chương 2" do story state kiểm (advanceChapter chỉ đi
    // chapter+1), không phải hàm này. Giữ đúng C#.
    if (chapter === CHAPTERS.KHUNG_HOANG) return true;
    if (chapter === CHAPTERS.VUC_DAY) {
      return helpQuestsDone >= CHAPTER4_HELP_QUESTS_MIN &&
        !!hasCloseRelationship;
    }
    if (chapter === CHAPTERS.THANH_DAT) {
      return tri >= CHAPTER5_TRI_MIN ||
        danhVong >= CHAPTER5_DANH_VONG_MIN ||
        taiSan >= CHAPTER5_TAI_SAN_MIN;
    }
    return false;
  }

  // --- Gợi ý kết thúc — đúng PlayerProgress.SuggestEnding ---

  // THỨ TỰ ƯU TIÊN CỨNG (giữ đúng C# — xem quirk trong @help):
  // SieuGiau → GiamDoc → HocGia → GiaDinh → TuDo → ChuaMo.
  function suggestEnding(taiSan, tri, danhVong, anYen, hasSpouse) {
    if (taiSan >= ENDING_SIEU_GIAU_TAI_SAN_MIN) return ENDINGS.SIEU_GIAU;
    if (taiSan >= CHAPTER5_TAI_SAN_MIN) return ENDINGS.GIAM_DOC;
    if (tri >= ENDING_HOC_GIA_TRI_MIN &&
        danhVong >= ENDING_HOC_GIA_DANH_VONG_MIN) {
      return ENDINGS.HOC_GIA;
    }
    if (hasSpouse && anYen >= ENDING_AN_YEN_MIN) return ENDINGS.GIA_DINH;
    if (anYen >= ENDING_AN_YEN_MIN) return ENDINGS.TU_DO;
    return ENDINGS.CHUA_MO;
  }

  // Bậc có thể tụt ở chương 3 nếu Danh vọng / An Yên thấp — chỉ báo
  // nguy cơ, không tự trừ bậc, không phạt (Mục 12: thất bại không bị
  // phạt, NPC giúp đỡ và được làm lại).
  // Đúng PlayerProgress.RankAtRisk.
  function rankAtRisk(danhVong, anYen) {
    return danhVong < RANK_AT_RISK_DANH_VONG_MAX ||
      anYen < RANK_AT_RISK_AN_YEN_MAX;
  }

  // --- Story state thuần (JSON-safe, đi theo save MV) ---

  function defaultState() {
    return {
      chapter: CHAPTERS.LEN_PHO, // chương hiện tại (1–5)
      helpQuestsDone: 0,         // số quest giúp NPC đã làm xong
      chapter3Passed: false,     // đã vượt bài kiểm tra chương 3 chưa
      ending: ENDINGS.CHUA_MO,   // ending đã mở (mặc định chưa mở)
      unlockedChapters: [CHAPTERS.LEN_PHO] // các chương đã mở, không trùng
    };
  }

  // State thuần mới — tương đương `new` story state trong C#.
  function createStoryState() {
    return defaultState();
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbStory) {
        $gameSystem.pxbStory = defaultState();
      }
      return $gameSystem.pxbStory;
    }
    return fallbackState;
  }

  // Khởi tạo pxbStory trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbStory) {
      $gameSystem.pxbStory = defaultState();
    }
    return true;
  }

  // Reset tiến trình hiện tại (event/test dùng để bắt đầu lại).
  function resetState() {
    var st = state();
    st.chapter = CHAPTERS.LEN_PHO;
    st.helpQuestsDone = 0;
    st.chapter3Passed = false;
    st.ending = ENDINGS.CHUA_MO;
    st.unlockedChapters = [CHAPTERS.LEN_PHO];
    return true;
  }

  // --- Thao tác trên 1 story state thuần ---

  // Thử mở chương tiếp theo (chapter+1) bằng canOpenChapter. Nếu đủ
  // điều kiện thì tăng chapter, thêm vào unlockedChapters (không
  // trùng), trả true; không đủ điều kiện trả false.
  // Chương 3 mở được luôn theo canOpenChapter nhưng chỉ advance khi
  // đã qua chương 2: advance chỉ đi chapter+1 nên khi mở chương 3
  // thì state.chapter đã = 2 — guard dưới đây ghi rõ logic này để
  // không ai gọi advanceChapter với state nhảy cóc (ví dụ sửa tay
  // chapter = 1 rồi đòi mở chương 3).
  function advanceChapter(stateObj, tri, danhVong, taiSan,
      hasCloseRelationship) {
    if (!stateObj) return false;
    var next = stateObj.chapter + 1;
    if (next > CHAPTERS.THANH_DAT) return false;
    // Chương 3 chỉ mở khi đã qua chương 2.
    if (next === CHAPTERS.KHUNG_HOANG && stateObj.chapter < 2) {
      return false;
    }
    if (!canOpenChapter(next, tri, danhVong, taiSan,
        hasCloseRelationship, stateObj.helpQuestsDone)) {
      return false;
    }
    stateObj.chapter = next;
    if (!Array.isArray(stateObj.unlockedChapters)) {
      stateObj.unlockedChapters = [];
    }
    if (stateObj.unlockedChapters.indexOf(next) < 0) {
      stateObj.unlockedChapters.push(next);
    }
    return true;
  }

  // Ghi 1 quest giúp NPC đã xong — tăng helpQuestsDone lên 1, trả số
  // mới. (Chương 4 cần ≥ 3.)
  function recordHelpQuest(stateObj) {
    if (!stateObj) return 0;
    if (typeof stateObj.helpQuestsDone !== "number") {
      stateObj.helpQuestsDone = 0;
    }
    stateObj.helpQuestsDone += 1;
    return stateObj.helpQuestsDone;
  }

  // Vượt bài kiểm tra chương 3 — chỉ khi đang ở chương 3 thì đánh
  // dấu chapter3Passed = true, trả true; ngược lại false.
  function passChapter3(stateObj) {
    if (!stateObj) return false;
    if (stateObj.chapter !== CHAPTERS.KHUNG_HOANG) return false;
    stateObj.chapter3Passed = true;
    return true;
  }

  // Đặt ending — chỉ nhận 1 trong 6 giá trị Ending, giá trị lạ trả
  // false (không đổi state).
  function setEnding(stateObj, ending) {
    if (!stateObj) return false;
    var valid = false;
    for (var k in ENDINGS) {
      if (ENDINGS[k] === ending) { valid = true; break; }
    }
    if (!valid) return false;
    stateObj.ending = ending;
    return true;
  }

  // Kiểm tra 1 ending có phải giá trị hợp lệ không.
  function isValidEnding(ending) {
    for (var k in ENDINGS) {
      if (ENDINGS[k] === ending) return true;
    }
    return false;
  }

  // --- Wrapper trên state hiện tại (event gọi trực tiếp) ---

  function chapterNow() { return state().chapter; }
  function advanceChapterNow(tri, danhVong, taiSan, hasCloseRelationship) {
    return advanceChapter(state(), tri, danhVong, taiSan,
      hasCloseRelationship);
  }
  function recordHelpQuestNow() {
    return recordHelpQuest(state());
  }
  function passChapter3Now() { return passChapter3(state()); }
  function setEndingNow(ending) { return setEnding(state(), ending); }
  // Gợi ý ending rồi LƯU vào state.ending, trả ending.
  function suggestEndingNow(taiSan, tri, danhVong, anYen, hasSpouse) {
    var ending = suggestEnding(taiSan, tri, danhVong, anYen, hasSpouse);
    state().ending = ending;
    return ending;
  }
  function rankAtRiskNow(danhVong, anYen) {
    return rankAtRisk(danhVong, anYen);
  }
  function chapterNameNow() {
    return CHAPTER_NAMES[state().chapter] || "";
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Story Advance <tri> <danhVong> <taiSan> <hasClose:0/1>
  //     — thử mở chương tiếp theo
  //   PXB_Story HelpQuest
  //     — ghi 1 quest giúp NPC đã xong
  //   PXB_Story PassChapter3
  //     — vượt bài kiểm tra chương 3 (chỉ khi đang ở chương 3)
  //   PXB_Story SuggestEnding <taiSan> <tri> <danhVong> <anYen> <hasSpouse:0/1>
  //     — gợi ý ending theo thứ tự ưu tiên cứng, lưu vào state
  // Gợi ý ending / kiểm tra rank / đọc chương hiện tại KHÔNG qua
  // plugin command (cần kết quả trả về) — event gọi trực tiếp
  // PXB_Story.suggestEndingNow(...) / .rankAtRiskNow(...) /
  // .chapterNow() v.v.
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
              $gameSystem.pxbStory) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbStory;
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
        if (command === "PXB_Story") {
          if (args[0] === "Advance") {
            advanceChapterNow(
              parseInt(args[1], 10) || 0,
              parseInt(args[2], 10) || 0,
              parseInt(args[3], 10) || 0,
              args[4] === "1");
          } else if (args[0] === "HelpQuest") {
            recordHelpQuestNow();
          } else if (args[0] === "PassChapter3") {
            passChapter3Now();
          } else if (args[0] === "SuggestEnding") {
            suggestEndingNow(
              parseInt(args[1], 10) || 0,
              parseInt(args[2], 10) || 0,
              parseInt(args[3], 10) || 0,
              parseInt(args[4], 10) || 0,
              args[5] === "1");
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

  var PXB_Story = {
    CHAPTER2_TRI_MIN: CHAPTER2_TRI_MIN,
    CHAPTER2_DANH_VONG_MIN: CHAPTER2_DANH_VONG_MIN,
    CHAPTER4_HELP_QUESTS_MIN: CHAPTER4_HELP_QUESTS_MIN,
    CHAPTER5_TRI_MIN: CHAPTER5_TRI_MIN,
    CHAPTER5_DANH_VONG_MIN: CHAPTER5_DANH_VONG_MIN,
    CHAPTER5_TAI_SAN_MIN: CHAPTER5_TAI_SAN_MIN,
    ENDING_HOC_GIA_TRI_MIN: ENDING_HOC_GIA_TRI_MIN,
    ENDING_HOC_GIA_DANH_VONG_MIN: ENDING_HOC_GIA_DANH_VONG_MIN,
    ENDING_SIEU_GIAU_TAI_SAN_MIN: ENDING_SIEU_GIAU_TAI_SAN_MIN,
    ENDING_AN_YEN_MIN: ENDING_AN_YEN_MIN,
    RANK_AT_RISK_DANH_VONG_MAX: RANK_AT_RISK_DANH_VONG_MAX,
    RANK_AT_RISK_AN_YEN_MAX: RANK_AT_RISK_AN_YEN_MAX,
    CHAPTERS: CHAPTERS,
    ENDINGS: ENDINGS,
    CHAPTER_NAMES: CHAPTER_NAMES,
    canOpenChapter: canOpenChapter,
    suggestEnding: suggestEnding,
    rankAtRisk: rankAtRisk,
    createStoryState: createStoryState,
    advanceChapter: advanceChapter,
    recordHelpQuest: recordHelpQuest,
    passChapter3: passChapter3,
    setEnding: setEnding,
    isValidEnding: isValidEnding,
    chapterNow: chapterNow,
    advanceChapterNow: advanceChapterNow,
    recordHelpQuestNow: recordHelpQuestNow,
    passChapter3Now: passChapter3Now,
    setEndingNow: setEndingNow,
    suggestEndingNow: suggestEndingNow,
    rankAtRiskNow: rankAtRiskNow,
    chapterNameNow: chapterNameNow,
    resetState: resetState,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Story;
  } else if (typeof window !== "undefined") {
    window.PXB_Story = PXB_Story;
  }
})();
