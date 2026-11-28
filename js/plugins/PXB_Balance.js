// Phố Xô Bồ — PXB_Balance.js (plugin RPG Maker MV)
// Hằng số DUY NHẤT cho số đã chốt — tương đương GameBalance.cs (src/client).
// Plugin khác KHÔNG hardcode số — lấy từ đây. Mọi số phải khớp
// GameBalance.cs / Jobs.cs / Crafting.cs / Stats.cs + docs/gdd.md.
// Số ghi PROVISIONAL là số cấu hình slice / ví dụ chưa chốt — đổi thì sửa
// ở đây + file C# gốc + docs cùng lúc (xem docs/architecture-nadia.md §2, §6.1).
// Không dùng require (web không có Node), không dùng API chỉ có trên NW.js.
(function () {
  "use strict";

  var PXB_Balance = {
    // Thời gian kiểu C (GDD Mục 1, đã chốt): 1 ngày game = 30 phút thật, 3 khung.
    gameDayMinutes: 30,
    framesPerDay: 3,
    frameMinutes: 10,
    frames: ["Sáng", "Chiều", "Tối"],

    // Học vấn 5 bậc (GDD Mục 5, đã chốt — khớp GameBalance.Degrees).
    // name, feeVnd, days, requiredTri, exp, fame, needsMentor.
    degrees: [
      { name: "THPT",             feeVnd: 0,         days: 30,  tri: 20, exp: 0,    fame: 0,    mentor: false },
      { name: "Cao đẳng",         feeVnd: 20000000,  days: 60,  tri: 40, exp: 500,  fame: 0,    mentor: false },
      { name: "Cử nhân",          feeVnd: 80000000,  days: 120, tri: 60, exp: 1500, fame: 200,  mentor: false },
      { name: "Thạc sĩ",          feeVnd: 200000000, days: 180, tri: 75, exp: 3000, fame: 500,  mentor: false },
      { name: "Tiến sĩ / Học giả", feeVnd: 500000000, days: 240, tri: 90, exp: 6000, fame: 1500, mentor: true }
    ],

    // Khóa ngắn hạn (GDD Mục 5, đã chốt).
    shortCourseMinDays: 3,
    shortCourseMaxDays: 7,
    shortCourseMinFeeVnd: 2000000,
    shortCourseMaxFeeVnd: 10000000,
    shortCourseStatGain: 10,

    // Cung – cầu tuần (GDD Mục 5/6, đã chốt).
    shortageSalaryBonusPercent: 30,
    saturatedSalaryCutPercent: 15,
    schoolSeatsPerCourseMin: 20,
    schoolSeatsPerCourseMax: 30,

    // Giấy phép + thi chứng chỉ (GDD Mục 6, đã chốt).
    foodStallLicenseVnd: 50000000,
    clinicLicenseVnd: 200000000,
    examFeeMinVnd: 5000000,
    examFeeMaxVnd: 20000000,

    // Công ty = guild (GDD Mục 6, đã chốt).
    companyCapitalVnd: 500000000,
    companyInactiveWeeksToRemove: 2,

    // Xã hội (GDD Mục 8, đã chốt).
    neglectDaysToDropCloseness: 7,
    supportedExpBonusPercent: 20,
    soloSlowerPercentMin: 30,
    soloSlowerPercentMax: 50,

    // Tài chính (GDD Mục 7, đã chốt).
    bankInterestPerGameMonth: 0.005,
    auctionFeePercent: 5,
    bigPurchaseFameBonus: 50,

    // Thang nhà 6 bậc (GDD Mục 7, đã chốt) — tiền thuê tháng cho phòng trọ,
    // giá mua cho các bậc còn lại.
    roomRentPerMonthVnd: 2000000,
    miniApartmentVnd: 800000000,
    smallTownhouseVnd: 3000000000,
    largeTownhouseVnd: 8000000000,
    villaVnd: 25000000000,
    penthouseIslandVnd: 100000000000,

    // Nhánh rank Chương 5 (GDD Mục 9, đã chốt).
    directorAssetsVnd: 10000000000,
    superRichAssetsVnd: 100000000000,
    familyEndingAnYen: 80,

    // Chỉ số — PROVISIONAL (Stats.cs): GDD chỉ chốt "có trần tổng", chưa chốt số.
    // TotalCap 300 + StatMax 100 + ngưỡng cân bằng An Yên ±10 là số ví dụ.
    totalStatCap: 300, // PROVISIONAL — cần chủ chốt
    statMax: 100, // PROVISIONAL — cần chủ chốt cùng TotalCap
    anYenBalanceTolerance: 10, // PROVISIONAL — cần chủ chốt cùng TotalCap

    // 3 nghề slice (Jobs.cs — PROVISIONAL: lương ca + quota là số cấu hình
    // slice, chưa chốt GDD). Khung tốt +25%.
    // id, name, mainStat (the/tri/tam), goodFrame, basePayVnd, weeklyQuota.
    goodFrameBonusPercent: 25,
    jobs: [
      { id: "ban-rong",       name: "Bán rong",       mainStat: "the", goodFrame: "Chiều", basePayVnd: 150000, weeklyQuota: 14 },
      { id: "shipper",        name: "Shipper",        mainStat: "the", goodFrame: "Tối",   basePayVnd: 180000, weeklyQuota: 14 },
      { id: "nhan-vien-quan", name: "Nhân viên quán", mainStat: "tam", goodFrame: "Sáng",  basePayVnd: 150000, weeklyQuota: 14 }
    ],

    // Công thức chế tạo slice (Crafting.cs — PROVISIONAL, chưa chốt GDD).
    recipes: [
      { id: "che-xe-day",  name: "Xe Đẩy Hàng (bậc 1)", needs: { "khung-sat": 1, "banh-xe": 2, "van-go": 2 },   result: "tool:XeDay:1",   unlock: "Cô Tư dạy sau khi làm xong quest đầu tiên ở Xóm Trọ Cũ." },
      { id: "che-den-soi", name: "Đèn Soi (bậc 1)",     needs: { "sat-vun": 2, "chai-nhua": 2 },               result: "tool:DenSoi:1",  unlock: "Anh Hải dạy ở Phố Đi Bộ – Chợ Đêm." },
      { id: "che-qua-tang", name: "Quà Tặng Thủ Công",   needs: { "la-chuoi": 2, "vai-vun": 1 },               result: "item:qua-tang", unlock: "Học từ bạn thân NPC — tặng NPC để tăng thân thiết, mở quest (GDD Mục 8/9)." }
    ]
  };

  if (typeof module !== "undefined" && module.exports) {
    module.exports = PXB_Balance;
  } else if (typeof window !== "undefined") {
    window.PXB_Balance = PXB_Balance;
  }
})();
