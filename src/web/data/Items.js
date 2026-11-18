// Phố Xô Bồ — dữ liệu vật phẩm, kiểu RPG Maker MV (data/Items.json).
// Mở file trực tiếp vẫn chạy: dữ liệu nằm trong file .js, không dùng fetch.
// Số liệu khớp GameBalance.cs / docs/economy.md; số chưa chốt ghi PROVISIONAL.
window.PHO_ITEMS = {
  // Nguyên liệu (nhặt ở hotspot, chế tạo, bán ở Chợ)
  "khung-sat":  { id: "khung-sat",  name: "Khung Sắt",  kind: "material", price: 30000,  desc: "Khung sắt cũ, nhặt ở góc phế liệu." },
  "banh-xe":    { id: "banh-xe",    name: "Bánh Xe",    kind: "material", price: 50000,  desc: "Bánh xe đẩy còn lăn tốt." },
  "van-go":     { id: "van-go",     name: "Ván Gỗ",     kind: "material", price: 20000,  desc: "Ván gỗ pallet, phơi khô rồi." },
  "chai-nhua":  { id: "chai-nhua",  name: "Chai Nhựa",  kind: "material", price: 5000,   desc: "Chai nhựa ve chai, bán được ở chợ." },
  "vai-vun":    { id: "vai-vun",    name: "Vải Vụn",    kind: "material", price: 8000,   desc: "Vải vụn may vá, lót xe đẩy." },
  "la-chuoi":   { id: "la-chuoi",   name: "Lá Chuối",   kind: "material", price: 6000,   desc: "Lá chuối gói hàng, chợ nào cũng cần." },
  "sat-vun":    { id: "sat-vun",    name: "Sắt Vụn",    kind: "material", price: 15000,  desc: "Sắt vụn, để dành chế Đèn Soi." },
  // Đồ chế (công cụ — mỗi bậc đổi hành vi thật, như 4 công cụ của Nadia)
  "xe-day":     { id: "xe-day",     name: "Xe Đẩy Hàng", kind: "tool", price: 500000, desc: "Chế từ Khung Sắt + Bánh Xe + Ván Gỗ. Chở nhiều, đi được đường mưa." },
  "den-soi":    { id: "den-soi",    name: "Đèn Soi",     kind: "tool", price: 120000, desc: "Chế từ Sắt Vụn + Chai Nhựa. Thấy hotspot ẩn buổi tối." },
  // Đồ ăn / tiêu dùng (mua ở Chợ, dùng hồi năng lượng hoặc tăng chỉ số)
  "com-tam":    { id: "com-tam",    name: "Cơm Tấm",        kind: "food", price: 25000, energy: 25, desc: "Cơm tấm sườn bì, ăn xong làm tiếp được." },
  "ca-phe":     { id: "ca-phe",     name: "Cà Phê Sữa Đá",  kind: "food", price: 15000, energy: 15, desc: "Cà phê sữa đá, tỉnh táo hẳn." },
  "sach-cu":    { id: "sach-cu",    name: "Sách Cũ",        kind: "book", price: 40000, tri: 2,    desc: "Sách cũ mua ở sạp, đọc lên Trí +2." }
};
