// Phố Xô Bồ — sự kiện chung / quest (CommonEvents), kiểu RPG Maker MV.
// Quest mở theo TIẾN TRÌNH (chế đồ / thân thiết), KHÔNG khóa theo ngày/giờ cứng
// trong game (Nadia khóa quest theo thứ Ba/thứ Năm — mình không copy, trái luật
// "không FOMO, miss khung không phạt" GDD Mục 1/12).
window.PHO_EVENTS = {
  "q-xe-day": {
    id: "q-xe-day", giver: "co-tu", title: "Chế Xe Đẩy Hàng",
    accept: "Con nhặt đủ Khung Sắt + Bánh Xe + Ván Gỗ rồi ra Góc Chế Tạo trong phòng mà chế. Chế xong cô chỉ con đường ra chợ lớn.",
    done: "Giỏi! Có xe đẩy rồi thì đi chợ buôn bán đàng hoàng. Từ nay con mở được đường tới Công Viên An Bình.",
    reward: { money: 50000, closeness: { "co-tu": 15 }, unlock: "park" },
    need: { crafted: "xe-day" }
  },
  "q-sap-le": {
    id: "q-sap-le", giver: "chi-le", title: "Phụ Sạp Chị Lệ",
    accept: "Phụ chị một ca bán rong buổi sáng, chị cho con 2 Lá Chuối với ít tiền công.",
    done: "Con bán khéo lắm! Mai mốt cứ ra sạp chị mà lấy hàng sỉ.",
    reward: { money: 80000, items: { "la-chuoi": 2 }, closeness: { "chi-le": 15 } },
    need: { workedJob: "ban-rong", frame: "Sáng" }
  },
  "q-don-toi": {
    id: "q-don-toi", giver: "anh-hai", title: "Chạy Đơn Buổi Tối",
    accept: "Tối nay chạy một ca shipper khung Tối giúp anh, đường hẻm tối thì nhớ mang Đèn Soi.",
    done: "Chạy nhanh, khách khen. Có đèn soi thì hẻm nào cũng đi được.",
    reward: { money: 100000, closeness: { "anh-hai": 15 } },
    need: { workedJob: "shipper", frame: "Tối" }
  }
};
