// Phố Xô Bồ — công cụ (Skills), kiểu RPG Maker MV (data/Skills.json).
// 4 công cụ Việt, tương đương 4 công cụ của Nadia (Boots / Metal Detector /
// Guide / Shovel): mỗi bậc nâng cấp ĐỔI HÀNH VI THẬT, không chỉ +5% số.
window.PHO_SKILLS = {
  "xe-day": {
    id: "xe-day", name: "Xe Đẩy Hàng",
    tiers: [
      { tier: 1, name: "Xe Đẩy Gỗ",  behaviour: "Chở được 10kg hàng, đi đường khô ráo." },
      { tier: 2, name: "Xe Đẩy Sắt", behaviour: "Chở được 25kg, đi được đường mưa, bán rong +20% tiền." },
      { tier: 3, name: "Xe Đẩy Đôi", behaviour: "Chở được 50kg, mở nghề buôn sỉ ở Chợ Đầu Mối." }
    ]
  },
  "den-soi": {
    id: "den-soi", name: "Đèn Soi",
    tiers: [
      { tier: 1, name: "Đèn Pin Cũ", behaviour: "Thấy hotspot ẩn buổi tối trong Xóm Trọ Cũ." },
      { tier: 2, name: "Đèn Soi Sáng", behaviour: "Thấy hotspot hiếm (màu cam) ở mọi khu slice." }
    ]
  },
  "so-tay": {
    id: "so-tay", name: "Sổ Tay Dẫn Đường",
    tiers: [
      { tier: 1, name: "Sổ Tay Mỏng", behaviour: "Cô Tư gợi ý mục tiêu hiện tại bằng lời thoại." },
      { tier: 2, name: "Sổ Tay Dày", behaviour: "Gợi ý rõ thêm khu + nguyên liệu còn thiếu." }
    ]
  },
  "xeng": {
    id: "xeng", name: "Xẻng Nhặt",
    tiers: [
      { tier: 1, name: "Xẻng Cũ", behaviour: "Nhặt hotspot nhanh hơn, có lúc được thêm 1 món." },
      { tier: 2, name: "Xẻng Bén", behaviour: "Nhặt được đồ hiếm ở hotspot thường (tỉ lệ nhỏ)." }
    ]
  }
};
