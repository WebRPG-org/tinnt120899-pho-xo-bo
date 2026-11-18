/*:
 * @plugindesc Phố Xô Bồ — Học vấn 5 bậc + khóa ngắn hạn + học bổng: đăng ký, tiến độ ngày game, tốt nghiệp.
 * @author Muse Center
 *
 * @help
 * Port trung thực học vấn GDD Mục 5 + GameBalance.cs
 * (src/client/Assets/Scripts/GameBalance.cs, Degrees + ShortCourse).
 *
 * - 5 bậc học: THPT (0đ, 30 ngày, Trí 20), Cao đẳng (20tr, 60 ngày,
 *   Trí 40, EXP 500), Cử nhân (80tr, 120 ngày, Trí 60, EXP 1500,
 *   Danh vọng 200), Thạc sĩ (200tr, 180 ngày, Trí 75, EXP 3000,
 *   Danh vọng 500), Tiến sĩ / Học giả (500tr, 240 ngày, Trí 90,
 *   EXP 6000, Danh vọng 1500, CẦN mentor).
 * - Khóa ngắn hạn: 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ
 *   (ky/dung/sang/an-yen), mở nghề phụ (event mở nghề sau tốt nghiệp).
 * - Trường nhận 20–30 học viên/khóa, ưu tiên thứ tự đăng ký + Trí +
 *   Danh vọng; học bổng cho người nghèo mà Trí cao (GDD Mục 5).
 *
 * PROVISIONAL — GDD chưa chốt, ghi rõ để chủ chốt sau:
 *   1. Học phí trả 1 lần lúc đăng ký. GDD chưa chốt trả trước hay
 *      trả góp — enroll() trừ 1 lần; nếu chốt trả góp thì sửa enroll().
 *   2. Đã có bằng này hoặc bằng CAO HƠN thì không học lại (canEnroll
 *      trả "da-co-bang"). GDD chưa chốt có được học nhảy bậc hay học
 *      lại bằng thấp hơn không — khi chốt thì sửa canEnroll().
 *   3. Học bổng: Trí >= 60 và tiền game < 20.000.000 thì đủ điều kiện
 *      xét. GDD chỉ nói "người nghèo mà Trí cao", chưa chốt ngưỡng —
 *      scholarshipEligible() chỉ trả true/false để event quyết, KHÔNG
 *      tự miễn học phí.
 *   4. Số ghế/khóa: seatsPerCourse() trả {min:20, max:30} từ
 *      PXB_Balance; registerOrder ghi thứ tự đăng ký vào state để
 *      event ưu tiên. Plugin KHÔNG tự chặn hết ghế vì GDD chưa chốt
 *      số ghế mỗi khóa cụ thể.
 *   5. Tốt nghiệp cộng EXP + Danh vọng vào pendingExp / pendingFame
 *      để EVENT áp dụng — vì chưa có hệ EXP/Danh vọng chung trong
 *      Nadia nên plugin KHÔNG tự cộng vào đâu cả. Khóa ngắn hạn cũng
 *      vậy: +10 ghi vào pendingStatGain, event áp qua PXB_Stats —
 *      plugin KHÔNG tự gọi PXB_Stats vì chưa chắc đã load.
 *   6. Được học song song 1 bằng chính + 1 khóa ngắn hạn cùng lúc
 *      (2 slot riêng enrolled / shortCourse). GDD chưa chốt có được
 *      học chồng hay không.
 *
 * Lưu: state sống trong $gameSystem.pxbEducation nên đi theo save
 * của MV ($gameSystem vốn đã nằm trong save contents của core). Khi
 * core MV chưa có (repo hiện tại), logic thuần vẫn chạy và test được
 * qua module.exports; hàm install() trả false và không giả vờ đã móc
 * save.
 *
 * Tiến độ theo ngày game: đọc $gameSystem.pxbDayNumber khi có (khớp
 * quy ước PXB_Time: ngày 1 = Thứ Hai). Đăng ký ngày N, học D ngày thì
 * endDay = N + D, tốt nghiệp khi số ngày game >= endDay. Event gọi
 * CheckGraduation mỗi ngày game mới.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Education.canEnroll(2, 65, false)      // {ok:true} hoặc {ok:false, reason:"..."}
 *   PXB_Education.enroll(2, 65, false)         // {ok:true, degree, charged, ...}
 *   PXB_Education.studyProgress()              // {enrolled, dayNumber, daysLeft}
 *   PXB_Education.checkGraduation()            // {graduated:true, degree, exp, fame, ...}
 *   PXB_Education.enrollShortCourse("ky", 5, 5000000)
 *   PXB_Education.scholarshipEligible(70, 15000000)  // true/false
 *   PXB_Education.seatsPerCourse()             // {min:20, max:30}
 */
(function () {
  "use strict";

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

  // Fallback chỉ dùng khi PXB_Balance chưa load. Số đã chốt GDD Mục 5
  // (khớp GameBalance.Degrees + ShortCourse + SchoolSeatsPerCourse).
  var FALLBACK = {
    degrees: [
      { name: "THPT",              feeVnd: 0,         days: 30,  tri: 20, exp: 0,    fame: 0,    mentor: false },
      { name: "Cao đẳng",          feeVnd: 20000000,  days: 60,  tri: 40, exp: 500,  fame: 0,    mentor: false },
      { name: "Cử nhân",           feeVnd: 80000000,  days: 120, tri: 60, exp: 1500, fame: 200,  mentor: false },
      { name: "Thạc sĩ",           feeVnd: 200000000, days: 180, tri: 75, exp: 3000, fame: 500,  mentor: false },
      { name: "Tiến sĩ / Học giả", feeVnd: 500000000, days: 240, tri: 90, exp: 6000, fame: 1500, mentor: true }
    ],
    shortCourseMinDays: 3,
    shortCourseMaxDays: 7,
    shortCourseMinFeeVnd: 2000000,
    shortCourseMaxFeeVnd: 10000000,
    shortCourseStatGain: 10,
    schoolSeatsPerCourseMin: 20,
    schoolSeatsPerCourseMax: 30
  };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] !== "undefined") return b[key];
    return FALLBACK[key];
  }

  function degreeDefs() { return cfg("degrees"); }
  function shortCourseMinDays() { return cfg("shortCourseMinDays"); }
  function shortCourseMaxDays() { return cfg("shortCourseMaxDays"); }
  function shortCourseMinFee() { return cfg("shortCourseMinFeeVnd"); }
  function shortCourseMaxFee() { return cfg("shortCourseMaxFeeVnd"); }
  function shortCourseStatGain() { return cfg("shortCourseStatGain"); }

  // Ngưỡng học bổng PROVISIONAL (xem @help mục 3): Trí >= 60 và tiền
  // game < 20.000.000. GDD chưa chốt ngưỡng nên giữ ở đây, sửa 1 chỗ.
  var SCHOLARSHIP_MIN_TRI = 60;
  var SCHOLARSHIP_MAX_GOLD = 20000000;

  // 4 chỉ số phụ của PXB_Stats (chỉ số trộn: ky/dung/sang/an-yen).
  var SUB_STATS = ["ky", "dung", "sang", "an-yen"];

  // --- Danh sách bậc học ---

  function degreeList() {
    return degreeDefs().slice();
  }

  // Lấy bậc học theo index (0–4) hoặc tên ("Cử nhân", "THPT"...).
  // Trả null khi không có.
  function getDegree(indexOrName) {
    var defs = degreeDefs();
    if (typeof indexOrName === "number") {
      var i = indexOrName | 0;
      if (i >= 0 && i < defs.length) return defs[i];
      return null;
    }
    if (typeof indexOrName === "string") {
      for (var j = 0; j < defs.length; j++) {
        if (defs[j].name === indexOrName) return defs[j];
      }
      return null;
    }
    return null;
  }

  // Index của bậc học theo tên; -1 khi không có.
  function degreeIndex(indexOrName) {
    var defs = degreeDefs();
    if (typeof indexOrName === "number") {
      var i = indexOrName | 0;
      return (i >= 0 && i < defs.length) ? i : -1;
    }
    if (typeof indexOrName === "string") {
      for (var j = 0; j < defs.length; j++) {
        if (defs[j].name === indexOrName) return j;
      }
    }
    return -1;
  }

  // --- State (sống trong $gameSystem.pxbEducation để vào save) ---

  function defaultState() {
    return {
      degreesOwned: [],    // index các bằng đã tốt nghiệp, vd [0, 2]
      enrolled: null,      // {degreeIndex, startDay, endDay, registerOrder} hoặc null
      shortCourse: null,   // {subStat, days, startDay, endDay, registerOrder} hoặc null
      pendingExp: 0,       // EXP chờ event áp (chưa có hệ EXP chung)
      pendingFame: 0,      // Danh vọng chờ event áp
      pendingStatGain: {}, // +chỉ số phụ chờ event áp qua PXB_Stats, vd {ky: 10}
      lastRegisterOrder: 0,// số thứ tự đăng ký đã cấp (tăng dần)
      hasMentor: false     // có mentor hay chưa (event/NPC cấp)
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbEducation) {
        $gameSystem.pxbEducation = defaultState();
      }
      return $gameSystem.pxbEducation;
    }
    return fallbackState;
  }

  // Khởi tạo pxbEducation trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbEducation) {
      $gameSystem.pxbEducation = defaultState();
    }
    return true;
  }

  // Số ngày game hiện tại (ngày 1 = Thứ Hai, khớp PXB_Time).
  function currentDayNumber() {
    if (typeof $gameSystem !== "undefined" && $gameSystem &&
        typeof $gameSystem.pxbDayNumber === "number") {
      return $gameSystem.pxbDayNumber;
    }
    return 1;
  }

  // Trí hiện tại qua PXB_Stats khi có; chưa có thì trả null — caller
  // tự quyết (enroll() yêu cầu tri truyền vào rõ ràng).
  function currentTri() {
    var s = null;
    if (typeof window !== "undefined" && window.PXB_Stats) s = window.PXB_Stats;
    else if (typeof global !== "undefined" && global.PXB_Stats) s = global.PXB_Stats;
    if (!s || typeof s.current !== "function") return null;
    var cur = s.current();
    if (!cur) return null;
    if (typeof cur.get === "function") {
      var v = cur.get("tri");
      return typeof v === "number" ? v : null;
    }
    return typeof cur.tri === "number" ? cur.tri : null;
  }

  // --- Tiền game ($gameParty.gold()) ---

  function partyGold() {
    if (typeof $gameParty !== "undefined" && $gameParty &&
        typeof $gameParty.gold === "function") {
      return $gameParty.gold();
    }
    return null; // chưa có core MV — caller không trừ tiền thật
  }

  function loseGold(amount) {
    if (typeof $gameParty !== "undefined" && $gameParty &&
        typeof $gameParty.loseGold === "function") {
      $gameParty.loseGold(amount);
      return true;
    }
    return false;
  }

  // --- Đăng ký bằng chính ---

  // Đã có bằng này hoặc bằng CAO HƠN chưa. PROVISIONAL (xem @help
  // mục 2): GDD chưa chốt có được học nhảy bậc / học lại bằng thấp
  // hơn không; tạm chặn học lại bằng đã có hoặc thấp hơn bằng cao
  // nhất đã có.
  function hasDegreeOrHigher(idx) {
    var owned = state().degreesOwned;
    for (var i = 0; i < owned.length; i++) {
      if (owned[i] >= idx) return true;
    }
    return false;
  }

  // Kiểm tra có đăng ký được bậc idx không. tri: Trí hiện tại;
  // hasMentor: có mentor không (mặc định đọc state.hasMentor);
  // gold: tiền game hiện tại (mặc định đọc $gameParty, null = chưa
  // có core thì bỏ qua kiểm tra tiền). Trả:
  //   {ok:true}
  //   {ok:false, reason:"khong-co-bang"} — idx sai
  //   {ok:false, reason:"da-co-bang"} — đã có bằng này / bằng cao hơn
  //   {ok:false, reason:"dang-hoc"} — đang học 1 bằng khác
  //   {ok:false, reason:"chua-du-tri"} — Trí dưới mức yêu cầu
  //   {ok:false, reason:"can-mentor"} — bậc này cần mentor
  //   {ok:false, reason:"khong-du-tien"} — tiền game không đủ học phí
  function canEnroll(idx, tri, hasMentor, gold) {
    var i = degreeIndex(idx);
    if (i < 0) return { ok: false, reason: "khong-co-bang" };
    var def = degreeDefs()[i];
    if (hasDegreeOrHigher(i)) {
      return { ok: false, reason: "da-co-bang" };
    }
    if (state().enrolled) {
      return { ok: false, reason: "dang-hoc" };
    }
    var t = (typeof tri === "number") ? tri : 0;
    if (t < def.tri) {
      return { ok: false, reason: "chua-du-tri" };
    }
    var mentor = (typeof hasMentor === "boolean")
      ? hasMentor : !!state().hasMentor;
    if (def.mentor && !mentor) {
      return { ok: false, reason: "can-mentor" };
    }
    var g = (typeof gold === "number") ? gold : partyGold();
    if (g !== null && g < def.feeVnd) {
      return { ok: false, reason: "khong-du-tien" };
    }
    return { ok: true };
  }

  // Đăng ký bậc idx. Học phí trả 1 LẦN lúc đăng ký — PROVISIONAL
  // (xem @help mục 1): GDD chưa chốt trả trước hay trả góp.
  // gold: tiền game hiện tại (mặc định đọc $gameParty; truyền vào để
  // test/event ép số tiền). Trả:
  //   {ok:true, degree, degreeIndex, startDay, endDay, feePaid,
  //    charged, registerOrder}
  //   {ok:false, reason:"..."} — lý do chặn như canEnroll()
  // charged = true khi học phí đã trừ khỏi $gameParty; false khi chưa
  // có core MV (node test) — khi đó event phải tự trừ feePaid.
  function enroll(idx, tri, hasMentor, gold) {
    var check = canEnroll(idx, tri, hasMentor, gold);
    if (!check.ok) return check;
    var i = degreeIndex(idx);
    var def = degreeDefs()[i];
    var st = state();
    var startDay = currentDayNumber();
    st.lastRegisterOrder += 1;
    st.enrolled = {
      degreeIndex: i,
      startDay: startDay,
      endDay: startDay + def.days,
      registerOrder: st.lastRegisterOrder
    };
    var charged = loseGold(def.feeVnd);
    return {
      ok: true, degree: def, degreeIndex: i,
      startDay: startDay, endDay: st.enrolled.endDay,
      feePaid: def.feeVnd, charged: charged,
      registerOrder: st.lastRegisterOrder
    };
  }

  // --- Tiến độ + tốt nghiệp bằng chính ---

  // Tiến độ học hiện tại: {enrolled, dayNumber, daysLeft}.
  // enrolled = null khi không học bằng nào; daysLeft = số ngày còn
  // lại tới ngày tốt nghiệp (0 khi đã đủ ngày — gọi checkGraduation).
  function studyProgress() {
    var st = state();
    var day = currentDayNumber();
    if (!st.enrolled) {
      return { enrolled: null, dayNumber: day, daysLeft: 0 };
    }
    var daysLeft = st.enrolled.endDay - day;
    if (daysLeft < 0) daysLeft = 0;
    return { enrolled: st.enrolled, dayNumber: day, daysLeft: daysLeft };
  }

  // Kiểm tra tốt nghiệp (event gọi mỗi ngày game mới). Đủ ngày thì:
  // lưu bằng vào degreesOwned, cộng EXP + Danh vọng vào pendingExp /
  // pendingFame để EVENT áp dụng (chưa có hệ EXP/Danh vọng chung nên
  // KHÔNG tự cộng vào đâu cả), xóa enrolled. Trả:
  //   {graduated:true, degree, degreeIndex, exp, fame,
  //    pendingExp, pendingFame} — vừa tốt nghiệp
  //   {graduated:false, enrolled, daysLeft} — chưa đủ ngày / không học
  function checkGraduation() {
    var st = state();
    var prog = studyProgress();
    if (!prog.enrolled || prog.daysLeft > 0) {
      return {
        graduated: false, enrolled: prog.enrolled,
        daysLeft: prog.daysLeft
      };
    }
    var def = degreeDefs()[prog.enrolled.degreeIndex];
    var idx = prog.enrolled.degreeIndex;
    if (st.degreesOwned.indexOf(idx) < 0) {
      st.degreesOwned.push(idx);
    }
    st.pendingExp += def.exp;
    st.pendingFame += def.fame;
    st.enrolled = null;
    return {
      graduated: true, degree: def, degreeIndex: idx,
      exp: def.exp, fame: def.fame,
      pendingExp: st.pendingExp, pendingFame: st.pendingFame
    };
  }

  // --- Khóa ngắn hạn ---

  // Đăng ký khóa ngắn hạn: +10 một chỉ số phụ, mở nghề phụ (event mở
  // nghề sau tốt nghiệp). subStat: "ky" | "dung" | "sang" | "an-yen";
  // days: 3–7; feeVnd: 2–10 triệu. Trả:
  //   {ok:true, subStat, days, startDay, endDay, feePaid, charged,
  //    registerOrder}
  //   {ok:false, reason:"sai-chi-so"} — subStat không phải 1 trong 4
  //   {ok:false, reason:"sai-so-ngay"} — days ngoài 3–7
  //   {ok:false, reason:"phi-ngoai-khoang"} — phí ngoài 2–10 triệu
  //   {ok:false, reason:"dang-hoc-khoa-ngan"} — đang học 1 khóa khác
  //   {ok:false, reason:"khong-du-tien"} — tiền game không đủ phí
  // charged = true khi phí đã trừ khỏi $gameParty; false khi chưa có
  // core MV — khi đó event phải tự trừ feePaid.
  function enrollShortCourse(subStat, days, feeVnd) {
    if (SUB_STATS.indexOf(subStat) < 0) {
      return { ok: false, reason: "sai-chi-so" };
    }
    days = days | 0;
    if (days < shortCourseMinDays() || days > shortCourseMaxDays()) {
      return { ok: false, reason: "sai-so-ngay" };
    }
    feeVnd = feeVnd | 0;
    if (feeVnd < shortCourseMinFee() || feeVnd > shortCourseMaxFee()) {
      return { ok: false, reason: "phi-ngoai-khoang" };
    }
    var st = state();
    if (st.shortCourse) {
      return { ok: false, reason: "dang-hoc-khoa-ngan" };
    }
    var gold = partyGold();
    if (gold !== null && gold < feeVnd) {
      return { ok: false, reason: "khong-du-tien" };
    }
    var startDay = currentDayNumber();
    st.lastRegisterOrder += 1;
    st.shortCourse = {
      subStat: subStat, days: days,
      startDay: startDay, endDay: startDay + days,
      registerOrder: st.lastRegisterOrder
    };
    var charged = loseGold(feeVnd);
    return {
      ok: true, subStat: subStat, days: days,
      startDay: startDay, endDay: st.shortCourse.endDay,
      feePaid: feeVnd, charged: charged,
      registerOrder: st.lastRegisterOrder
    };
  }

  // Tiến độ khóa ngắn hạn: {shortCourse, dayNumber, daysLeft}.
  function shortCourseProgress() {
    var st = state();
    var day = currentDayNumber();
    if (!st.shortCourse) {
      return { shortCourse: null, dayNumber: day, daysLeft: 0 };
    }
    var daysLeft = st.shortCourse.endDay - day;
    if (daysLeft < 0) daysLeft = 0;
    return {
      shortCourse: st.shortCourse, dayNumber: day, daysLeft: daysLeft
    };
  }

  // Tốt nghiệp khóa ngắn hạn (gọi cùng CheckGraduation mỗi ngày game
  // mới — checkGraduation() đã gọi sẵn hàm này). +10 chỉ số phụ ghi
  // vào pendingStatGain để EVENT áp qua PXB_Stats; plugin KHÔNG tự
  // gọi PXB_Stats vì chưa chắc đã load. Trả:
  //   {graduated:true, subStat, gain, pendingStatGain}
  //   {graduated:false, shortCourse, daysLeft}
  function checkShortCourseGraduation() {
    var st = state();
    var prog = shortCourseProgress();
    if (!prog.shortCourse || prog.daysLeft > 0) {
      return {
        graduated: false, shortCourse: prog.shortCourse,
        daysLeft: prog.daysLeft
      };
    }
    var sub = prog.shortCourse.subStat;
    var gain = shortCourseStatGain();
    st.pendingStatGain[sub] = (st.pendingStatGain[sub] || 0) + gain;
    st.shortCourse = null;
    return {
      graduated: true, subStat: sub, gain: gain,
      pendingStatGain: st.pendingStatGain
    };
  }

  // --- Học bổng ---

  // PROVISIONAL (xem @help mục 3): Trí >= 60 và tiền game
  // < 20.000.000 thì đủ điều kiện XÉT học bổng. GDD chỉ nói "người
  // nghèo mà Trí cao", chưa chốt ngưỡng. Hàm chỉ trả true/false để
  // event quyết — KHÔNG tự miễn học phí.
  function scholarshipEligible(tri, gold) {
    var t = (typeof tri === "number") ? tri : 0;
    var g = (typeof gold === "number") ? gold : partyGold();
    if (g === null) return false; // chưa có core + không truyền gold: không xét
    return t >= SCHOLARSHIP_MIN_TRI && g < SCHOLARSHIP_MAX_GOLD;
  }

  // --- Số ghế / thứ tự đăng ký ---

  // Số ghế mỗi khóa từ PXB_Balance: {min:20, max:30}. PROVISIONAL
  // (xem @help mục 4): plugin không tự chặn hết ghế — event dùng số
  // này + registerOrder để ưu tiên.
  function seatsPerCourse() {
    return {
      min: cfg("schoolSeatsPerCourseMin"),
      max: cfg("schoolSeatsPerCourseMax")
    };
  }

  // Số thứ tự đăng ký đã cấp gần nhất (0 = chưa đăng ký lần nào).
  // PROVISIONAL: event dùng để ưu tiên thứ tự đăng ký + Trí + Danh
  // vọng khi xét ghế (GDD Mục 5).
  function registerOrder() {
    return state().lastRegisterOrder;
  }

  // Ghi nhận có mentor (event/NPC cấp khi người chơi tìm được mentor).
  // Trả true khi ghi xong.
  function setMentor(has) {
    state().hasMentor = !!has;
    return true;
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Education CheckGraduation  — kiểm tra tốt nghiệp bằng chính
  //                                    + khóa ngắn hạn (gọi mỗi ngày
  //                                    game mới)
  //   PXB_Education Enroll <index>   — đăng ký bậc <index> (event đã
  //                                    tự kiểm tra tiền/Trí trước;
  //                                    Trí đọc từ PXB_Stats khi có,
  //                                    mentor đọc từ state.hasMentor)
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
              $gameSystem.pxbEducation) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbEducation;
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
        if (command === "PXB_Education") {
          if (args[0] === "CheckGraduation") {
            checkGraduation();
            checkShortCourseGraduation();
          } else if (args[0] === "Enroll") {
            var idx = parseInt(args[1], 10);
            var tri = currentTri();
            // Event đã kiểm tra Trí trước; chưa có PXB_Stats thì
            // truyền Trí rất cao để không chặn oan ở đây.
            enroll(idx, tri === null ? 100 : tri);
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

  var PXB_Education = {
    SUB_STATS: SUB_STATS,
    SCHOLARSHIP_MIN_TRI: SCHOLARSHIP_MIN_TRI,
    SCHOLARSHIP_MAX_GOLD: SCHOLARSHIP_MAX_GOLD,
    degreeList: degreeList,
    getDegree: getDegree,
    degreeIndex: degreeIndex,
    hasDegreeOrHigher: hasDegreeOrHigher,
    canEnroll: canEnroll,
    enroll: enroll,
    studyProgress: studyProgress,
    checkGraduation: checkGraduation,
    enrollShortCourse: enrollShortCourse,
    shortCourseProgress: shortCourseProgress,
    checkShortCourseGraduation: checkShortCourseGraduation,
    scholarshipEligible: scholarshipEligible,
    seatsPerCourse: seatsPerCourse,
    registerOrder: registerOrder,
    setMentor: setMentor,
    currentDayNumber: currentDayNumber,
    currentTri: currentTri,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Education;
  } else if (typeof window !== "undefined") {
    window.PXB_Education = PXB_Education;
  }
})();
