// Phố Xô Bồ — dữ liệu nhân vật (Actors), kiểu RPG Maker MV (data/Actors.json).
// NPC dẫn đường thay Soul Crystal / Evie của Nadia: gợi ý bằng lời thoại trong
// thế giới, gắn mục tiêu hiện tại, KHÔNG bao giờ biến mất giữa game (lỗi Nadia).
// Không copy nhân vật / lời thoại của Nadia — toàn bộ NPC là người Việt, đời chợ.
window.PHO_ACTORS = {
  "co-tu": {
    id: "co-tu", name: "Cô Tư", title: "Chủ trọ — NPC dẫn đường",
    mapId: 1, x: 8, y: 6, color: "#8a5a2b",
    greet: "Con mới lên phố hả? Phòng trọ thì có sẵn, việc thì ra chợ mà kiếm. Bí thì cứ hỏi cô.",
    hint: "Ra chợ sớm mà nhặt đồ. Còn chế Xe Đẩy thì ghé Góc Chế Tạo trong phòng con, cô để sẵn bàn gỗ với đèn vàng đó.",
    questGiver: "q-xe-day"
  },
  "ban-than": {
    id: "ban-than", name: "Bạn Thân (Bin)", title: "Bạn thân NPC",
    mapId: 1, x: 3, y: 5, color: "#2b6a8a",
    greet: "Ê, lên phố rồi hả! Tao ở đây lâu rồi, có gì khó cứ rủ tao đi cùng, làm chung nhanh hơn.",
    hint: "Đi hai người vui hơn đi một mình. Mày làm ca nghề xong thì ghé chợ phụ chị Lệ, bả hay cho thêm đồ lắm."
  },
  "chi-le": {
    id: "chi-le", name: "Chị Lệ", title: "Chủ sạp — dạy nghề bán rong",
    mapId: 2, x: 2, y: 2, color: "#3e7a4e",
    greet: "Sạp chị mở từ 5 giờ sáng. Muốn bán rong thì học cách xếp hàng cho đẹp, khách mới ghé.",
    hint: "Buổi sáng chợ đông nhất, bán rong khung Sáng là ngon nhất. Có lá chuối thì để dành gói hàng cho chị.",
    questGiver: "q-sap-le"
  },
  "anh-hai": {
    id: "anh-hai", name: "Anh Hải", title: "Shipper — giao việc shipper",
    mapId: 2, x: 6, y: 3, color: "#b4452f",
    greet: "Shipper thì chạy nhiều, biết đường là tiền về. Tối chạy đơn nhiều hơn, mà phải có đèn soi đường.",
    hint: "Đơn buổi tối trả cao hơn. Mày mà chế được Đèn Soi thì chạy tối khỏi lo hẻm tối.",
    questGiver: "q-don-toi"
  }
};
