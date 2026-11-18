// Phố Xô Bồ — danh sách map (MapInfos), kiểu RPG Maker MV.
// Đúng 18 khu đã chốt (docs/districts.md). Slice này chỉ xây map 1 + 2;
// khu 17/18 mở sau khi chế Xe Đẩy (điều kiện ghi rõ, như "cửa đỏ" của Nadia);
// các khu còn lại khóa, ghi điều kiện mở — không giấu điều kiện.
window.PHO_MAPINFOS = [
  { id: 1,  name: "Xóm Trọ Cũ",          tier: 1, locked: false, note: "Khu bắt đầu — hẻm nhỏ, phòng trọ, Góc Chế Tạo." },
  { id: 2,  name: "Chợ Đầu Mối",         tier: 1, locked: false, note: "Chợ 5 giờ sáng — sạp chị Lệ, anh Hải shipper." },
  { id: 17, name: "Công Viên An Bình",   tier: 0, locked: true,  unlock: "Chế Xe Đẩy Hàng (quest cô Tư)", note: "Câu cá, trồng cây — hệ phụ sau Chương 2." },
  { id: 18, name: "Phố Đi Bộ – Chợ Đêm", tier: 0, locked: true,  unlock: "Chế Xe Đẩy Hàng + thân thiết với anh Hải 30", note: "Sự kiện chung tối thứ Bảy 20:00." },
  { id: 3,  name: "Khu Công Nhân",       tier: 1, locked: true,  unlock: "Chương 2 — Lập Nghiệp", note: "Mở ở phase sau." },
  { id: 4,  name: "Bến Xe Miền Đông",    tier: 1, locked: true,  unlock: "Chương 2 — Lập Nghiệp", note: "Mở ở phase sau." },
  { id: 5,  name: "Làng Đại Học",        tier: 2, locked: true,  unlock: "Cao đẳng trở lên (Trí 40)", note: "Mở ở phase sau." }
];
