/*:
 * @plugindesc Phố Xô Bồ — 3 nghề slice: lương theo chỉ số chính, khung tốt +25%, quota tuần, cung–cầu, thi chứng chỉ.
 * @author Muse Center
 *
 * @help
 * Port trung thực Jobs.cs (src/client/Assets/Scripts/Jobs.cs).
 *
 * - 3 nghề slice: Bán rong (Thể, khung tốt Chiều, 150.000/ca), Shipper
 *   (Thể, khung tốt Tối, 180.000/ca), Nhân viên quán (Tâm, khung tốt
 *   Sáng, 150.000/ca). Quota mỗi nghề 14 ca/tuần game.
 * - Lương 1 ca = lương ca cơ bản × hệ số chỉ số chính × hệ số khung
 *   giờ × hệ số cung–cầu, làm tròn xuống. Hệ số chỉ số chính:
 *   chỉ số 50 = 1.0; mỗi 10 điểm trên 50 cộng 10% lương, mỗi 10 điểm
 *   dưới 50 trừ 10% (tối thiểu 50% lương ca) — đúng công thức Jobs.cs:
 *   max(0.5, 1.0 + (chỉ số − 50) × 0.01).
 * - Khung giờ tốt của nghề: +25% (Jobs.GoodFrameBonusPercent).
 * - Cung–cầu tuần (GameBalance, đã chốt): nghề thiếu người +30%,
 *   nghề bão hòa −15%, nghề còn lại bình thường.
 * - Thi chứng chỉ (GDD Mục 6, đã chốt): phí thi 5–20 triệu tiền game,
 *   trượt mất phí, chờ tuần sau; nạp chỉ mua thêm 1 lượt thi/tuần,
 *   không mua đậu.
 * - Làm ca trừ khung thời gian: 1 ca chiếm khung hiện tại (đọc từ
 *   PXB_Time khi có); lương trả bằng tiền game ($gameParty.gold()).
 *
 * LƯU Ý — Jobs.cs KHÔNG có logic thi chứng chỉ và KHÔNG chốt cách
 * chọn nghề thiếu/bão hòa mỗi tuần; 2 phần đó lấy từ GDD Mục 6 +
 * docs/architecture-nadia.md §4.4, phần chưa chốt ghi PROVISIONAL
 * dưới đây. Lương ca cơ bản + quota là số cấu hình slice (Jobs.cs),
 * chưa chốt GDD.
 *
 * Lưu: state sống trong $gameSystem.pxbJobs nên đi theo save của MV
 * ($gameSystem vốn đã nằm trong save contents của core). Khi core MV
 * chưa có (repo hiện tại), logic thuần vẫn chạy và test được qua
 * module.exports; hàm install() trả false và không giả vờ đã móc save.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Jobs.payPerShiftCurrent("ban-rong")   // lương ca này, theo chỉ số + khung + cung–cầu
 *   PXB_Jobs.workShift("ban-rong")           // {ok:true, pay:..., ...} hoặc {ok:false, reason:"het-quota"}
 *   PXB_Jobs.shiftsLeft("shipper")           // ca còn lại trong tuần
 *   PXB_Jobs.takeExam("ban-rong", 5000000, true)  // đậu = true, trượt = false (event quyết)
 *   PXB_Jobs.hasCert("ban-rong")
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số với Jobs.cs /
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

  // Fallback chỉ dùng khi PXB_Balance chưa load. Lương ca + quota là
  // số cấu hình slice PROVISIONAL (Jobs.cs); các % còn lại đã chốt.
  var FALLBACK = {
    goodFrameBonusPercent: 25,
    shortageSalaryBonusPercent: 30,
    saturatedSalaryCutPercent: 15,
    examFeeMinVnd: 5000000,
    examFeeMaxVnd: 20000000,
    jobs: [
      { id: "ban-rong",       name: "Bán rong",       mainStat: "the", goodFrame: "Chiều", basePayVnd: 150000, weeklyQuota: 14 },
      { id: "shipper",        name: "Shipper",        mainStat: "the", goodFrame: "Tối",   basePayVnd: 180000, weeklyQuota: 14 },
      { id: "nhan-vien-quan", name: "Nhân viên quán", mainStat: "tam", goodFrame: "Sáng",  basePayVnd: 150000, weeklyQuota: 14 }
    ]
  };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] !== "undefined") return b[key];
    return FALLBACK[key];
  }

  function goodFrameBonusPercent() { return cfg("goodFrameBonusPercent"); }
  function shortageBonusPercent() { return cfg("shortageSalaryBonusPercent"); }
  function saturatedCutPercent() { return cfg("saturatedSalaryCutPercent"); }
  function examFeeMin() { return cfg("examFeeMinVnd"); }
  function examFeeMax() { return cfg("examFeeMaxVnd"); }
  function jobDefs() { return cfg("jobs"); }

  // Cung–cầu tuần: "binh-thuong" | "thieu-nguoi" | "bao-hoa".
  var DEMAND_NORMAL = "binh-thuong";
  var DEMAND_SHORTAGE = "thieu-nguoi";
  var DEMAND_SATURATED = "bao-hoa";

  var JOB_IDS = ["ban-rong", "shipper", "nhan-vien-quan"];

  function getJob(id) {
    var defs = jobDefs();
    for (var i = 0; i < defs.length; i++) {
      if (defs[i].id === id) return defs[i];
    }
    return null;
  }

  function jobList() {
    return jobDefs().slice();
  }

  // Đọc chỉ số chính từ stats: nhận instance PXB_Stats (có .get) hoặc
  // object thuần {the, tri, tam}. Không biết thì trả 50 (hệ số 1.0).
  function mainStatValue(def, stats) {
    if (!stats) return 50;
    if (typeof stats.get === "function") {
      var v = stats.get(def.mainStat);
      return typeof v === "number" ? v : 50;
    }
    var raw = stats[def.mainStat];
    return typeof raw === "number" ? raw : 50;
  }

  // Hệ số chỉ số chính — đúng Jobs.cs: max(0.5, 1.0 + (chỉ số − 50) × 0.01).
  // Chỉ số 50 -> 1.0; 100 -> 1.5; 0 -> 0.5 (sàn).
  function statFactor(mainValue) {
    return Math.max(0.5, 1.0 + (mainValue - 50) * 0.01);
  }

  // Tính lương 1 ca (đồng trong game), làm tròn xuống — port trung thực
  // Jobs.PayPerShift. frameName: "Sáng"/"Chiều"/"Tối" (null = khung
  // thường, không cộng khung tốt). demand: "binh-thuong" | "thieu-nguoi"
  // | "bao-hoa" (mặc định bình thường).
  function payPerShift(jobId, stats, frameName, demand) {
    var def = getJob(jobId);
    if (!def) throw new Error("Không có nghề slice: " + jobId);
    var pay = def.basePayVnd * statFactor(mainStatValue(def, stats));
    if (frameName && frameName === def.goodFrame) {
      pay *= 1 + goodFrameBonusPercent() / 100;
    }
    if (demand === DEMAND_SHORTAGE) {
      pay *= 1 + shortageBonusPercent() / 100;
    } else if (demand === DEMAND_SATURATED) {
      pay *= 1 - saturatedCutPercent() / 100;
    }
    return Math.floor(pay);
  }

  // --- State (sống trong $gameSystem.pxbJobs để vào save) ---

  function defaultState() {
    return {
      weekNumber: 1,
      shifts: {},        // ca đã làm trong tuần, theo jobId
      supplyDemand: {}, // cung–cầu tuần, theo jobId
      certs: {},         // chứng chỉ đã đậu, theo jobId -> true
      examAttempts: {},  // lượt thi đã dùng trong tuần, theo jobId
      extraAttempts: {}, // lượt thi mua thêm trong tuần, theo jobId (tối đa 1)
      lastShift: null    // {jobId, frame, pay, dayNumber} — ca gần nhất
    };
  }

  // Dữ liệu dự phòng khi chưa có core MV (logic thuần vẫn test được).
  var fallbackState = defaultState();

  function state() {
    if (typeof $gameSystem !== "undefined" && $gameSystem) {
      if (!$gameSystem.pxbJobs) {
        $gameSystem.pxbJobs = defaultState();
      }
      return $gameSystem.pxbJobs;
    }
    return fallbackState;
  }

  // Khởi tạo pxbJobs trong $gameSystem (gọi khi new game).
  // Trả false khi chưa có $gameSystem — không giả vờ đã lưu được.
  function initInGameSystem() {
    if (typeof $gameSystem === "undefined" || !$gameSystem) return false;
    if (!$gameSystem.pxbJobs) {
      $gameSystem.pxbJobs = defaultState();
    }
    return true;
  }

  // Số tuần game hiện tại. PROVISIONAL — GDD chưa chốt "tuần game" là
  // gì; tạm tính 1 tuần = 7 ngày game, ngày game 1 = Thứ Hai (khớp
  // quy ước ngày trong tuần của PXB_Time). Đổi thì sửa đúng hàm này.
  function currentWeekNumber() {
    if (typeof $gameSystem !== "undefined" && $gameSystem &&
        typeof $gameSystem.pxbDayNumber === "number") {
      return Math.floor(($gameSystem.pxbDayNumber - 1) / 7) + 1;
    }
    return state().weekNumber;
  }

  function currentDayNumber() {
    if (typeof $gameSystem !== "undefined" && $gameSystem &&
        typeof $gameSystem.pxbDayNumber === "number") {
      return $gameSystem.pxbDayNumber;
    }
    return 1;
  }

  // Khung hiện tại ("Sáng"/"Chiều"/"Tối") qua PXB_Time khi có.
  // Chưa có PXB_Time thì trả null — caller coi như khung thường.
  function currentFrameName() {
    var t = null;
    if (typeof window !== "undefined" && window.PXB_Time) t = window.PXB_Time;
    else if (typeof global !== "undefined" && global.PXB_Time) t = global.PXB_Time;
    if (!t || typeof t.frameName !== "function" ||
        typeof t.elapsedMinutes !== "function") {
      return null;
    }
    return t.frameName(t.elapsedMinutes());
  }

  // Chỉ số hiện tại của người chơi qua PXB_Stats khi có; chưa có thì
  // trả null — caller dùng 50 (hệ số 1.0).
  function currentStats() {
    var s = null;
    if (typeof window !== "undefined" && window.PXB_Stats) s = window.PXB_Stats;
    else if (typeof global !== "undefined" && global.PXB_Stats) s = global.PXB_Stats;
    if (!s || typeof s.current !== "function") return null;
    return s.current();
  }

  // --- Cung–cầu tuần ---

  // PROVISIONAL — GDD + architecture chỉ chốt "1 nghề thiếu người
  // (+30%), 1 nghề bão hòa (−15%)" mỗi tuần, KHÔNG chốt cách chọn nghề
  // nào. Tạm dùng vòng xoay theo số tuần: tuần N thiếu nghề
  // [(N−1) % 3], bão hòa nghề [(N+1) % 3], nghề còn lại bình thường.
  // Server/event có thể ghi đè bằng setDemand(); khi GDD chốt cách
  // chọn thì sửa đúng hàm này.
  function rollSupplyDemand(weekNumber) {
    var n = ((weekNumber - 1) % 3 + 3) % 3;
    var map = {};
    map[JOB_IDS[n]] = DEMAND_SHORTAGE;
    map[JOB_IDS[(n + 1) % 3]] = DEMAND_NORMAL;
    map[JOB_IDS[(n + 2) % 3]] = DEMAND_SATURATED;
    return map;
  }

  function getDemand(jobId) {
    var st = state();
    ensureWeek();
    if (st.supplyDemand[jobId]) return st.supplyDemand[jobId];
    return DEMAND_NORMAL;
  }

  // Ghi đè cung–cầu tuần cho 1 nghề (event/server gọi). kind phải là
  // 1 trong 3 giá trị; sai thì trả false.
  function setDemand(jobId, kind) {
    if (!getJob(jobId)) return false;
    if (kind !== DEMAND_NORMAL && kind !== DEMAND_SHORTAGE &&
        kind !== DEMAND_SATURATED) {
      return false;
    }
    state().supplyDemand[jobId] = kind;
    return true;
  }

  // --- Quota tuần (port trung thực Jobs.WeeklyQuotaTracker) ---

  function shiftsDone(jobId) {
    ensureWeek();
    return state().shifts[jobId] || 0;
  }

  function shiftsLeft(jobId) {
    var def = getJob(jobId);
    if (!def) return 0;
    return def.weeklyQuota - shiftsDone(jobId);
  }

  function canTakeShift(jobId) {
    return shiftsLeft(jobId) > 0;
  }

  // Sang tuần game mới: reset ca đã làm + lượt thi + lượt mua thêm,
  // quay lại cung–cầu tuần mới (theo vòng xoay PROVISIONAL).
  // Chứng chỉ đã đậu GIỮ NGUYÊN (không reset theo tuần).
  function resetWeek(weekNumber) {
    var st = state();
    st.weekNumber = weekNumber;
    st.shifts = {};
    st.examAttempts = {};
    st.extraAttempts = {};
    st.supplyDemand = rollSupplyDemand(weekNumber);
    return true;
  }

  // Tự reset khi tuần game đã đổi (gọi đầu mỗi hàm đọc/ghi state).
  function ensureWeek() {
    var st = state();
    var week = currentWeekNumber();
    if (st.weekNumber !== week) {
      resetWeek(week);
    }
    // Tuần đầu chưa quay cung–cầu lần nào thì quay ngay.
    if (!st.supplyDemand || Object.keys(st.supplyDemand).length === 0) {
      st.supplyDemand = rollSupplyDemand(st.weekNumber);
    }
    return true;
  }

  // --- Tiền game ($gameParty.gold()) ---

  function partyGold() {
    if (typeof $gameParty !== "undefined" && $gameParty &&
        typeof $gameParty.gold === "function") {
      return $gameParty.gold();
    }
    return null; // chưa có core MV — caller không trừ/cộng tiền thật
  }

  function gainGold(amount) {
    if (typeof $gameParty !== "undefined" && $gameParty &&
        typeof $gameParty.gainGold === "function") {
      $gameParty.gainGold(amount);
      return true;
    }
    return false;
  }

  function loseGold(amount) {
    if (typeof $gameParty !== "undefined" && $gameParty &&
        typeof $gameParty.loseGold === "function") {
      $gameParty.loseGold(amount);
      return true;
    }
    return false;
  }

  // --- Làm ca ---

  // Làm 1 ca nghề jobId. Ca chiếm khung hiện tại (frameName truyền vào
  // để test/event ép khung; không truyền thì đọc PXB_Time khi có, chưa
  // có thì coi như khung thường). Trả:
  //   {ok:true, jobId, frame, demand, pay, paid, shiftsLeft}
  //   {ok:false, reason:"het-quota"} — hết quota tuần
  //   {ok:false, reason:"khong-co-nghe"} — jobId sai
  // paid = true khi tiền đã cộng vào $gameParty; false khi chưa có core
  // MV (node test) — khi đó event phải tự cộng pay vào tiền.
  function workShift(jobId, frameName, stats) {
    var def = getJob(jobId);
    if (!def) return { ok: false, reason: "khong-co-nghe" };
    ensureWeek();
    if (!canTakeShift(jobId)) {
      return { ok: false, reason: "het-quota" };
    }
    var frame = frameName || currentFrameName();
    var demand = getDemand(jobId);
    var s = stats || currentStats();
    var pay = payPerShift(jobId, s, frame, demand);
    var st = state();
    st.shifts[jobId] = (st.shifts[jobId] || 0) + 1;
    st.lastShift = {
      jobId: jobId, frame: frame, pay: pay, dayNumber: currentDayNumber()
    };
    var paid = gainGold(pay);
    return {
      ok: true, jobId: jobId, frame: frame, demand: demand,
      pay: pay, paid: paid, shiftsLeft: shiftsLeft(jobId)
    };
  }

  // Lương ca hiện tại của nghề (chỉ tính, không làm ca, không trừ
  // quota): chỉ số hiện tại + khung hiện tại + cung–cầu tuần.
  function payPerShiftCurrent(jobId) {
    var def = getJob(jobId);
    if (!def) throw new Error("Không có nghề slice: " + jobId);
    ensureWeek();
    return payPerShift(jobId, currentStats(), currentFrameName(),
      getDemand(jobId));
  }

  // --- Thi chứng chỉ (GDD Mục 6) ---

  // Nghề đặc biệt mới cần chứng chỉ; 3 nghề slice KHÔNG yêu cầu chứng
  // chỉ (Jobs.cs không định nghĩa chứng chỉ cho nghề nào). PROVISIONAL
  // — GDD chưa nêu tên nghề nào cần thi; khi chốt thì sửa đúng hàm này
  // (trả về id chứng chỉ, vd "chung-chi-bep").
  function certIdFor(jobId) {
    if (!getJob(jobId)) return null;
    return null;
  }

  function hasCert(jobId) {
    ensureWeek();
    return !!state().certs[jobId];
  }

  // Số lượt thi còn lại trong tuần: mặc định 1 lượt/tuần + tối đa 1 lượt
  // mua thêm (GDD: "nạp chỉ mua thêm 1 lượt thi/tuần, không mua đậu").
  function examAttemptsLeft(jobId) {
    ensureWeek();
    var st = state();
    var used = st.examAttempts[jobId] || 0;
    var extra = st.extraAttempts[jobId] || 0;
    return 1 + extra - used;
  }

  // Mua thêm 1 lượt thi trong tuần (nạp). PROVISIONAL — GDD chỉ chốt
  // "nạp mua thêm 1 lượt/tuần", chưa chốt giá + luồng thanh toán; hàm
  // này chỉ cộng lượt, việc trừ tiền nạp do event/IAP xử lý. Trả false
  // nếu tuần này đã mua rồi (tối đa 1 lượt mua thêm/tuần).
  function grantExtraAttempt(jobId) {
    if (!getJob(jobId)) return false;
    ensureWeek();
    var st = state();
    if ((st.extraAttempts[jobId] || 0) >= 1) return false;
    st.extraAttempts[jobId] = (st.extraAttempts[jobId] || 0) + 1;
    return true;
  }

  // Khoảng phí thi đã chốt (đồng trong game) — event lấy để hiển thị.
  function examFeeRange() {
    return { min: examFeeMin(), max: examFeeMax() };
  }

  // Thi chứng chỉ 1 lần. feeVnd: phí event thu (phải trong khoảng
  // 5–20 triệu đã chốt). passed: kết quả do EVENT quyết (đề thi / kiểm
  // tra chỉ số trong event) — plugin KHÔNG tự chốt công thức đậu/trượt
  // vì GDD chưa chốt; đậu thì cấp chứng chỉ, trượt thì mất phí và phải
  // chờ tuần sau (trừ khi đã mua thêm lượt). Trả:
  //   {ok:true, passed, feePaid, charged, attemptsLeft, hasCert}
  //   {ok:false, reason:"het-luot-thi"} — hết lượt tuần này
  //   {ok:false, reason:"phi-thi-ngoai-khoang"} — phí ngoài 5–20 triệu
  //   {ok:false, reason:"khong-du-tien"} — tiền game không đủ phí
  //   {ok:false, reason:"khong-co-nghe"} — jobId sai
  // charged = true khi phí đã trừ khỏi $gameParty; false khi chưa có
  // core MV (node test) — khi đó event phải tự trừ feeVnd.
  function takeExam(jobId, feeVnd, passed) {
    if (!getJob(jobId)) return { ok: false, reason: "khong-co-nghe" };
    ensureWeek();
    feeVnd = feeVnd | 0;
    if (feeVnd < examFeeMin() || feeVnd > examFeeMax()) {
      return { ok: false, reason: "phi-thi-ngoai-khoang" };
    }
    if (examAttemptsLeft(jobId) <= 0) {
      return { ok: false, reason: "het-luot-thi" };
    }
    var gold = partyGold();
    if (gold !== null && gold < feeVnd) {
      return { ok: false, reason: "khong-du-tien" };
    }
    var st = state();
    st.examAttempts[jobId] = (st.examAttempts[jobId] || 0) + 1;
    var charged = loseGold(feeVnd);
    var ok = !!passed;
    if (ok) st.certs[jobId] = true; // đậu: cấp chứng chỉ
    // Trượt: mất phí (đã trừ ở trên), không cấp chứng chỉ, chờ tuần sau.
    return {
      ok: true, passed: ok, feePaid: feeVnd, charged: charged,
      attemptsLeft: examAttemptsLeft(jobId), hasCert: hasCert(jobId)
    };
  }

  // --- Móc vào core MV ---

  // Plugin command cho CommonEvent / event thường:
  //   PXB_Jobs WorkShift ban-rong [Chiều]  — làm 1 ca (khung tùy chọn)
  //   PXB_Jobs RollDemand                   — quay lại cung–cầu tuần này
  //   PXB_Jobs ResetWeek                    — reset sang tuần hiện tại
  // Thi chứng chỉ KHÔNG qua plugin command (cần phí + kết quả đậu/trượt
  // từ event) — event gọi PXB_Jobs.takeExam(jobId, feeVnd, passed).
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
              $gameSystem.pxbJobs) {
            // Điền lại field thiếu khi load save cũ / save sửa tay.
            var d = defaultState();
            var s = $gameSystem.pxbJobs;
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
        if (command === "PXB_Jobs") {
          if (args[0] === "WorkShift") {
            workShift(args[1], args[2] || null);
          } else if (args[0] === "RollDemand") {
            state().supplyDemand = rollSupplyDemand(currentWeekNumber());
          } else if (args[0] === "ResetWeek") {
            resetWeek(currentWeekNumber());
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

  var PXB_Jobs = {
    DEMAND_NORMAL: DEMAND_NORMAL,
    DEMAND_SHORTAGE: DEMAND_SHORTAGE,
    DEMAND_SATURATED: DEMAND_SATURATED,
    JOB_IDS: JOB_IDS,
    jobList: jobList,
    getJob: getJob,
    statFactor: statFactor,
    payPerShift: payPerShift,
    payPerShiftCurrent: payPerShiftCurrent,
    currentFrameName: currentFrameName,
    currentWeekNumber: currentWeekNumber,
    getDemand: getDemand,
    setDemand: setDemand,
    rollSupplyDemand: rollSupplyDemand,
    shiftsDone: shiftsDone,
    shiftsLeft: shiftsLeft,
    canTakeShift: canTakeShift,
    workShift: workShift,
    resetWeek: resetWeek,
    ensureWeek: ensureWeek,
    certIdFor: certIdFor,
    hasCert: hasCert,
    examAttemptsLeft: examAttemptsLeft,
    grantExtraAttempt: grantExtraAttempt,
    examFeeRange: examFeeRange,
    takeExam: takeExam,
    initInGameSystem: initInGameSystem,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Jobs;
  } else if (typeof window !== "undefined") {
    window.PXB_Jobs = PXB_Jobs;
  }
})();
