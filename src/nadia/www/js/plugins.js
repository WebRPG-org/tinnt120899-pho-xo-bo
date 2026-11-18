// Phố Xô Bồ — khai báo plugin (RPG Maker MV, js/plugins.js).
// Thứ tự load: plugin sau được phép hook plugin trước — PXB_Balance PHẢI
// đứng đầu (mọi plugin khác lấy số từ nó, docs/architecture-nadia.md §6).
// Chỉ bật 2 plugin đã có file thật; plugin khác thêm khi file đã viết.
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
    "description": "Render 2.5D isometric trên Pixi (bản đầu: chỉ phép chiếu + sắp xếp, chưa móc Tilemap).",
    "parameters": {}
  }
];

if (typeof module !== "undefined" && module.exports) {
  module.exports = $plugins;
}
