// Phố Xô Bồ — dữ liệu hệ thống (System), kiểu RPG Maker MV (data/System.json):
// khung ngày, nghề, công thức, tab điện thoại, học vấn. Số khớp GameBalance.cs
// và GDD Mục 5/6; số chưa chốt ghi PROVISIONAL.
window.PHO_SYSTEM = {
  frames: ["Sáng", "Chiều", "Tối"],
  // 1 ngày game = 30 phút thật, 1 khung = 10 phút thật (GDD Mục 1, kiểu C).
  frameMinutes: 10,
  jobs: [
    { id: "ban-rong",       name: "Bán rong",       stat: "tam", basePay: 100000, goodFrame: "Sáng",  goodMap: 2 },
    { id: "shipper",        name: "Shipper",        stat: "the", basePay: 150000, goodFrame: "Tối",   goodMap: 2 },
    { id: "nhan-vien-quan", name: "Nhân viên quán", stat: "tam", basePay: 100000, goodFrame: "Chiều", goodMap: 1 }
  ],
  recipes: [
    { id: "xe-day",  name: "Xe Đẩy Hàng", needs: { "khung-sat": 1, "banh-xe": 1, "van-go": 1 },
      note: "Tương đương Basic Shovel của Nadia. Chế xong mở đường tới Công Viên An Bình." },
    { id: "den-soi", name: "Đèn Soi",     needs: { "sat-vun": 2, "chai-nhua": 1 },
      note: "Thấy hotspot ẩn buổi tối (màu cam)." }
  ],
  // Vật liệu khởi đầu: người chơi mới có sẵn 1 bộ để chế thử sau quest đầu —
  // hotspot trong map cho thêm khi đi nhặt (không bắt phải mua bằng tiền thật).
  starterMaterials: { "khung-sat": 1, "banh-xe": 1, "van-go": 1 },
  phoneTabs: ["Danh bạ/Tin nhắn", "Ngân hàng", "Bản đồ", "Việc làm", "Chợ", "Học tập", "Sức khỏe", "Xã hội", "Cài đặt"],
  education: [
    { name: "THPT",     cost: 0,         days: 30,  tri: 20, exp: 0 },
    { name: "Cao đẳng", cost: 20000000,  days: 60,  tri: 40, exp: 500 },
    { name: "Cử nhân",  cost: 80000000,  days: 120, tri: 60, exp: 1500 },
    { name: "Thạc sĩ",  cost: 200000000, days: 180, tri: 75, exp: 3000 },
    { name: "Tiến sĩ",  cost: 500000000, days: 240, tri: 90, exp: 6000 }
  ],
  // Khóa ngắn hạn: 3–7 ngày, +10 chỉ số phụ, mở nghề phụ (GDD Mục 5).
  shortCourses: [
    { name: "Nấu ăn đường phố", cost: 2000000,  stat: "tam", gain: 10 },
    { name: "Sửa xe máy",       cost: 5000000,  stat: "the", gain: 10 },
    { name: "Kế toán cơ bản",   cost: 3000000,  stat: "tri", gain: 10 }
  ]
};
