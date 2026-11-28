/*:
 * @plugindesc Phố Xô Bồ — Hệ thời gian kiểu C: 1 ngày game = 30 phút thật, 3 khung Sáng/Chiều/Tối, miss khung không phạt.
 * @author Muse Center
 *
 * @help
 * Port trung thực TimeSystem.cs (src/client/Assets/Scripts/TimeSystem.cs).
 *
 * - 1 ngày game = 30 phút thật (PXB_Balance.gameDayMinutes, đã chốt).
 * - 3 khung: Sáng / Chiều / Tối, mỗi khung 10 phút thật
 *   (PXB_Balance.frameMinutes = 30/3, đã chốt).
 * - Miss khung KHÔNG phạt: isMissed() chỉ dùng để hiển thị.
 * - Sự kiện chung: thứ 7, 20:00 tại Phố Đi Bộ – Chợ Đêm (khu 18).
 *
 * GIỜ GAME HAY GIỜ THẬT? — GDD Mục 1 chỉ ghi "thứ 7, 20:00", không
 * nói rõ. docs/architecture-nadia.md §3 chốt: Phase 1 (chơi đơn,
 * NPC đóng vai người chơi) sự kiện chung theo GIỜ GAME; Phase 2
 * (online, server chung) theo giờ thật qua server. Plugin này làm
 * theo Phase 1: isSaturdayEventTime() dùng giờ game + ngày game.
 * Ánh xạ "20:00 giờ game" trong 1 ngày game 30 phút: PROVISIONAL —
 * 1 ngày game = 1 vòng 24 giờ game, bắt đầu 00:00, nên 20:00 giờ
 * game rơi vào phút thứ 25 của ngày (25/30 × 24h = 20h). GDD chưa
 * chốt ánh xạ này; đổi thì sửa gameClockMinutes() + ghi chú ở đây.
 * Ngày trong tuần của game cũng PROVISIONAL: ngày game 1 = Thứ Hai.
 * isRealSaturdayEventTime() là bản giờ thật, để dành cho Phase 2
 * (PXB_Online.js) — không dùng ở Phase 1.
 *
 * Đồng hồ chạy bằng Game_Timer + CommonEvent khi có core MV
 * (Game_Timer đếm khung 60fps; CommonEvent Parallel gọi
 * PXB_Time.shouldTriggerSaturdayEvent() mỗi khung). Khi core MV
 * chưa có (repo hiện tại), đồng hồ chạy bằng Date.now() nội bộ và
 * logic thuần vẫn test được qua module.exports; install() trả
 * false và không giả vờ đã móc timer.
 *
 * Dùng trong event (khi có core MV):
 *   PXB_Time.frameName(PXB_Time.elapsedMinutes())  // "Sáng"/"Chiều"/"Tối"
 *   PXB_Time.isMissed(0, elapsed)                  // khung Sáng đã qua chưa
 *   PXB_Time.shouldTriggerSaturdayEvent(day, elapsed)
 */
(function () {
  "use strict";

  // Lấy hằng từ PXB_Balance (plugin #1, load trước). Khi chạy node test
  // mà chưa load PXB_Balance, dùng fallback — cùng số đã chốt trong
  // TimeSystem.cs / GameBalance.cs, để logic vẫn test được.
  function balance() {
    if (typeof window !== "undefined" && window.PXB_Balance) {
      return window.PXB_Balance;
    }
    if (typeof global !== "undefined" && global.PXB_Balance) {
      return global.PXB_Balance;
    }
    return null;
  }

  // Số đã chốt (TimeSystem.cs: GameDayLength 30 phút, FrameLength 10
  // phút = 30/3). Fallback chỉ dùng khi PXB_Balance chưa load.
  var FALLBACK = {
    gameDayMinutes: 30,
    framesPerDay: 3,
    frameMinutes: 10,
    frames: ["Sáng", "Chiều", "Tối"]
  };

  function cfg(key) {
    var b = balance();
    if (b && typeof b[key] !== "undefined") return b[key];
    return FALLBACK[key];
  }

  function gameDayMinutes() { return cfg("gameDayMinutes"); }
  function framesPerDay() { return cfg("framesPerDay"); }
  function frameMinutes() { return cfg("frameMinutes"); }
  function frameNames() { return cfg("frames"); }

  // Khung hiện tại theo số phút thật đã trôi từ đầu ngày game.
  // Port trung thực TimeSystem.CurrentFrame (so sánh với FrameLength).
  // elapsedMinutes: số phút thật từ đầu ngày (có thể lẻ, vd 12.5).
  function frameIndex(elapsedMinutes) {
    var fm = frameMinutes();
    if (elapsedMinutes < fm) return 0; // Sáng
    if (elapsedMinutes < fm * 2) return 1; // Chiều
    return 2; // Tối
  }

  function frameName(elapsedMinutes) {
    return frameNames()[frameIndex(elapsedMinutes)];
  }

  // Miss khung không phạt: chỉ trả về true nếu khung đã qua mà người
  // chơi không vào. CHỈ dùng để hiển thị — KHÔNG trừ điểm / phạt.
  // Port trung thực TimeSystem.IsMissed.
  function isMissed(frame, elapsedMinutes) {
    var fm = frameMinutes();
    if (frame === 0) return elapsedMinutes >= fm;
    if (frame === 1) return elapsedMinutes >= fm * 2;
    return elapsedMinutes >= gameDayMinutes();
  }

  // Số phút thật đã trôi trong khung hiện tại (0..10).
  function minutesIntoFrame(elapsedMinutes) {
    return elapsedMinutes - frameIndex(elapsedMinutes) * frameMinutes();
  }

  // Số phút thật còn lại của khung hiện tại.
  function minutesUntilFrameEnd(elapsedMinutes) {
    return frameMinutes() - minutesIntoFrame(elapsedMinutes);
  }

  // Tiến độ ngày game 0..1 (để vẽ đồng hồ / thanh ngày).
  function dayProgress(elapsedMinutes) {
    var p = elapsedMinutes / gameDayMinutes();
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  // --- Đồng hồ game (PROVISIONAL, xem @help) ---
  // 1 ngày game = 1 vòng 24 giờ game, bắt đầu 00:00 giờ game.
  // Trả về số phút trong ngày theo giờ game (0..1439).
  function gameClockMinutes(elapsedMinutes) {
    return Math.floor(dayProgress(elapsedMinutes) * 24 * 60);
  }

  function gameClockHour(elapsedMinutes) {
    return Math.floor(gameClockMinutes(elapsedMinutes) / 60);
  }

  // Ngày trong tuần của game. PROVISIONAL: ngày game 1 = Thứ Hai.
  // Trả 0 = Thứ Hai ... 6 = Chủ Nhật (dayNumber bắt đầu từ 1).
  function gameWeekday(dayNumber) {
    return (((dayNumber - 1) % 7) + 7) % 7;
  }

  function isSaturday(dayNumber) {
    return gameWeekday(dayNumber) === 5; // 5 = Thứ Bảy
  }

  // Sự kiện chung thứ 7 20:00 giờ game (Phase 1). Cửa sổ sự kiện =
  // giờ 20:00 giờ game, tức phút thật 25..30 của ngày thứ 7.
  // PROVISIONAL — cửa sổ + ánh xạ giờ game chưa chốt trong GDD.
  var EVENT_HOUR = 20; // 20:00 giờ game
  function isSaturdayEventTime(dayNumber, elapsedMinutes) {
    if (!isSaturday(dayNumber)) return false;
    return gameClockHour(elapsedMinutes) === EVENT_HOUR;
  }

  // Bản giờ thật, để dành cho Phase 2 online (server chung):
  // thứ 7 thật, trong giờ 20:00 thật. Không dùng ở Phase 1.
  function isRealSaturdayEventTime(date) {
    date = date || new Date();
    return date.getDay() === 6 && date.getHours() === 20;
  }

  // Có nên kích hoạt sự kiện chung lúc này không — CommonEvent
  // Parallel (chạy mỗi khung khi có core MV) gọi hàm này rồi mở
  // event sự kiện ở Map018 khi trả true.
  function shouldTriggerSaturdayEvent(dayNumber, elapsedMinutes) {
    return isSaturdayEventTime(dayNumber, elapsedMinutes);
  }

  // --- Đồng hồ chạy (Game_Timer khi có core, Date.now() khi chưa) ---
  // MV: $gameTimer đếm ngược theo khung 60fps. 1 ngày game =
  // gameDayMinutes * 60 giây = gameDayMinutes * 3600 khung.
  function dayLengthFrames() {
    return gameDayMinutes() * 60 * 60;
  }

  // Mốc bắt đầu ngày hiện tại (ms epoch) cho đồng hồ nội bộ.
  var _dayStartMs = null;

  // Bắt đầu 1 ngày game mới: chạy Game_Timer khi có core, đồng thời
  // ghi mốc Date.now() để logic thuần vẫn đọc được.
  function startDay() {
    _dayStartMs = Date.now();
    if (typeof $gameTimer !== "undefined" && $gameTimer &&
        typeof $gameTimer.start === "function") {
      $gameTimer.start(dayLengthFrames());
    }
    return true;
  }

  // Số phút thật đã trôi từ đầu ngày game hiện tại.
  // Ưu tiên $gameTimer khi nó đang chạy; nếu không, dùng mốc nội bộ;
  // chưa startDay() lần nào thì trả 0.
  function elapsedMinutes() {
    if (typeof $gameTimer !== "undefined" && $gameTimer &&
        typeof $gameTimer.isWorking === "function" && $gameTimer.isWorking() &&
        typeof $gameTimer.seconds === "function") {
      var remainingSec = $gameTimer.seconds();
      var totalSec = gameDayMinutes() * 60;
      var elapsed = totalSec - remainingSec;
      if (elapsed < 0) elapsed = 0;
      if (elapsed > totalSec) elapsed = totalSec;
      return elapsed / 60;
    }
    if (_dayStartMs === null) return 0;
    var elapsedMs = Date.now() - _dayStartMs;
    var minutes = elapsedMs / 60000;
    if (minutes > gameDayMinutes()) minutes = gameDayMinutes();
    return minutes;
  }

  // Móc vào core MV (chỉ chạy khi core đã có; chưa có thì trả false).
  // Plugin command cho CommonEvent / event thường:
  //   PXB_Time StartDay        — bắt đầu 1 ngày game mới
  //   PXB_Time SaturdayEvent   — kiểm tra rồi bật switch sự kiện chung
  // Switch sự kiện dùng $gameSwitches[1] là PROVISIONAL — chưa chốt
  // số switch trong data/System.json; đổi khi chốt (xem @help).
  var SATURDAY_EVENT_SWITCH_ID = 1; // PROVISIONAL — chưa chốt switch
  function install() {
    if (typeof Game_Interpreter === "undefined") return false;
    if (typeof Game_Interpreter.prototype.pluginCommand === "function") {
      var _pluginCommand = Game_Interpreter.prototype.pluginCommand;
      Game_Interpreter.prototype.pluginCommand = function (command, args) {
        _pluginCommand.call(this, command, args);
        if (command === "PXB_Time") {
          if (args[0] === "StartDay") {
            startDay();
          } else if (args[0] === "SaturdayEvent") {
            if (typeof $gameSystem !== "undefined" && $gameSystem &&
                typeof $gameSwitches !== "undefined" && $gameSwitches) {
              var day = $gameSystem.pxbDayNumber || 1;
              var on = shouldTriggerSaturdayEvent(day, elapsedMinutes());
              $gameSwitches.setValue(SATURDAY_EVENT_SWITCH_ID, on);
            }
          }
        }
      };
    }
    return true;
  }

  // Áp dụng hook ngay khi file load (quy ước MV). Không có core thì
  // install() trả false và không làm gì.
  install();

  var PXB_Time = {
    EVENT_HOUR: EVENT_HOUR,
    SATURDAY_EVENT_SWITCH_ID: SATURDAY_EVENT_SWITCH_ID,
    gameDayMinutes: gameDayMinutes,
    framesPerDay: framesPerDay,
    frameMinutes: frameMinutes,
    frameNames: frameNames,
    frameIndex: frameIndex,
    frameName: frameName,
    isMissed: isMissed,
    minutesIntoFrame: minutesIntoFrame,
    minutesUntilFrameEnd: minutesUntilFrameEnd,
    dayProgress: dayProgress,
    gameClockMinutes: gameClockMinutes,
    gameClockHour: gameClockHour,
    gameWeekday: gameWeekday,
    isSaturday: isSaturday,
    isSaturdayEventTime: isSaturdayEventTime,
    isRealSaturdayEventTime: isRealSaturdayEventTime,
    shouldTriggerSaturdayEvent: shouldTriggerSaturdayEvent,
    dayLengthFrames: dayLengthFrames,
    startDay: startDay,
    elapsedMinutes: elapsedMinutes,
    install: install
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Time;
  } else if (typeof window !== "undefined") {
    window.PXB_Time = PXB_Time;
  }
})();
