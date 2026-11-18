// Phố Xô Bồ — khai báo plugin (RPG Maker MV, js/plugins.js).
// Thứ tự load: plugin sau được phép hook plugin trước — PXB_Balance PHẢI
// đứng đầu (mọi plugin khác lấy số từ nó, docs/architecture-nadia.md §6).
// Chỉ bật plugin đã có file thật; plugin khác thêm khi file đã viết.
var $plugins = [
  {
    "name": "PXB_Balance",
    "status": true,
    "description": "Hằng số duy nhất cho số đã chốt (tương đương GameBalance.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Stats",
    "status": true,
    "description": "3 chỉ số gốc Thể/Trí/Tâm + 4 pha trộn + trần tổng, lưu vào $gameSystem (port Stats.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Time",
    "status": true,
    "description": "1 ngày game = 30 phút thật, 3 khung Sáng/Chiều/Tối; miss khung không phạt; sự kiện chung thứ 7 20:00 (port TimeSystem.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Isometric",
    "status": true,
    "description": "Render 2.5D isometric trên Pixi (v2: đã móc Tilemap + screenX/screenY, autotile chưa vẽ).",
    "parameters": {}
  },
  {
    "name": "PXB_Hotspot",
    "status": true,
    "description": "Hotspot lấp lánh kiểu Nadia: nhặt 1 lần/ngày game, chỉ đúng khung, NPC dẫn đường (port Exploration.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Crafting",
    "status": true,
    "description": "Chế tạo kiểu Nadia: 3 công thức slice + 4 công cụ × 3 bậc + học qua NPC (port Crafting.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Tools",
    "status": true,
    "description": "4 công cụ × 3 bậc đổi hành vi thật: Xe Đẩy đi được đường mưa, Đèn Soi thấy hotspot ẩn/hiếm, Sổ Tay gợi ý rõ, Xẻng nhặt nhanh + thêm đồ/hiếm (port Crafting.cs ToolBehaviour).",
    "parameters": {}
  },
  {
    "name": "PXB_Jobs",
    "status": true,
    "description": "3 nghề slice + lương theo chỉ số + quota tuần + cung–cầu + thi chứng chỉ (port Jobs.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_PhoneHub",
    "status": true,
    "description": "Điện thoại hub: 9 tab + thông báo chưa đọc + phím P (port PhoneHub.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Education",
    "status": true,
    "description": "Học vấn 5 bậc + khóa ngắn hạn + học bổng (port GDD Mục 5 / GameBalance.Degrees).",
    "parameters": {}
  },
  {
    "name": "PXB_Economy",
    "status": true,
    "description": "Ví + tiết kiệm + catalog 17 món + đấu giá + barter + 4 hành vi cấm (port Economy.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Social",
    "status": true,
    "description": "Người yêu/vợ-chồng, bạn thân/hội bạn, gia đình, đối tác; bỏ bê 7 ngày, hỗ trợ +20% EXP, solo chậm 40% (port Social.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Titles",
    "status": true,
    "description": "Xung đột danh hiệu 2 chiều + phe Chính/Tà/Trung lập + quest đổi phe 'Cải tà quy chính' (port TitleConflict.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Story",
    "status": true,
    "description": "5 chương Lên Phố → Thành Đạt + 6 kết thúc + tụt bậc chương 3 (port PlayerProgress.cs).",
    "parameters": {}
  },
  {
    "name": "PXB_Online",
    "status": true,
    "description": "Online Phase 2: health + số dư + tặng tiền qua server .NET (IdempotencyKey, outbox khi offline); trade/đấu giá/công ty=guild chưa có endpoint nên trả server-chua-co-endpoint.",
    "parameters": {}
  },
  {
    "name": "PXB_SaveCloud",
    "status": true,
    "description": "Đồng bộ save kiểu xenvn: tài khoản tùy chọn, localStorage mặc định khi offline; upload/download lên server chưa có endpoint nên trả server-chua-co-endpoint.",
    "parameters": {}
  }
];

if (typeof module !== "undefined" && module.exports) {
  module.exports = $plugins;
}
