// LEGACY — dữ liệu slice cũ, đã chuyển sang kiến trúc data-driven kiểu RPG
// Maker MV: data/Items.js, data/Actors.js, data/Skills.js,
// data/CommonEvents.js, data/MapInfos.js, data/Maps.js, data/System.js.
// File này giữ lại để đối chiếu số liệu cũ, game.js mới KHÔNG dùng nó nữa.
// Phố Xô Bồ — dữ liệu khu slice (cùng số với GameBalance.cs / docs/districts.md)
// Định dạng data-driven kiểu RPG Maker MV (data/*.json): map -> hotspot -> NPC.
// Mở file trực tiếp vẫn chạy (không cần fetch, tránh lỗi CORS khi mở file://).
window.PHO_MAPS = {
  districts: [
    {
      id: 1, name: "Xóm Trọ Cũ", tier: 1,
      color: "#e8c86a", desc: "Hẻm nhỏ Sài Gòn, tường vàng loang lổ, dây điện chằng chịt.",
      npcs: [
        { id: "co-tu", name: "Cô Tư (chủ trọ)", role: "NPC dẫn đường — gợi ý bằng lời thoại, không bao giờ biến mất (khác Soul Crystal của Nadia)." },
        { id: "ban-than", name: "Bạn thân", role: "Bạn thân NPC, hỗ trợ +20% EXP khi đi cùng." }
      ],
      hotspots: [
        { id: "hs-tro-toi", name: "Cuối hẻm", frame: "Tối", item: "Chai nhựa", qty: 2, x: 380, y: 340 },
        { id: "hs-hem-sang", name: "Góc hẻm", frame: "Sáng", item: "Vải vụn", qty: 1, x: 90, y: 120 }
      ],
      craftSpot: "Góc Chế Tạo trong phòng trọ"
    },
    {
      id: 2, name: "Chợ Đầu Mối", tier: 1,
      color: "#3e7a6e", desc: "Chợ đầu mối lúc 5 giờ sáng, sạp rau củ xếp cao, lá chuối, thùng xốp.",
      npcs: [
        { id: "chi-le", name: "Chị Lệ (chủ sạp)", role: "Bán sỉ, dạy nghề bán rong." },
        { id: "anh-hai", name: "Anh Hải (shipper)", role: "Giao việc shipper, gợi ý tuyến đường." }
      ],
      hotspots: [
        { id: "hs-cho-sang", name: "Sạp chị Lệ", frame: "Sáng", item: "Lá chuối", qty: 2, x: 120, y: 200 },
        { id: "hs-cho-chieu", name: "Góc phế liệu", frame: "Chiều", item: "Sắt vụn", qty: 1, x: 360, y: 130 }
      ],
      craftSpot: "Góc Chế Tạo ở sạp chợ"
    }
  ],
  // Công thức chế tạo — tương đương Basic Shovel của Nadia (Shovel Head + Shaft + Iron Ore)
  recipes: [
    { id: "xe-day", name: "Xe Đẩy Hàng", needs: { "Khung Sắt": 1, "Bánh Xe": 1, "Ván Gỗ": 1 },
      note: "Chế xong mới mở khu/nghề tiếp theo (crafting là cổng tiến trình, như Nadia)." },
    { id: "den-soi", name: "Đèn Soi", needs: { "Sắt vụn": 2, "Chai nhựa": 1 },
      note: "Bậc cao thấy hotspot ẩn." }
  ],
  // Nghề slice — lương ca cơ bản (PROVISIONAL, sửa 1 chỗ ở đây khi GDD chốt)
  jobs: [
    { id: "ban-rong", name: "Bán rong", stat: "the", basePay: 120000, goodFrame: "Chiều" },
    { id: "shipper", name: "Shipper", stat: "the", basePay: 150000, goodFrame: "Tối" },
    { id: "nhan-vien-quan", name: "Nhân viên quán", stat: "tam", basePay: 100000, goodFrame: "Sáng" }
  ],
  phoneTabs: ["Danh bạ/Tin nhắn", "Ngân hàng", "Bản đồ", "Việc làm", "Chợ", "Học tập", "Sức khỏe", "Xã hội", "Cài đặt"],
  frames: ["Sáng", "Chiều", "Tối"]
};
