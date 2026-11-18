# GDD — Phố Xô Bồ

> Game Design Document, bám đúng 12 mục đã chốt. Số liệu trong file này là số chốt;
> nếu một file khác ghi khác, lấy file này làm chuẩn và sửa file kia.

## Mục 1 — Tổng quan & vòng lặp 1 ngày

- **Tên:** Phố Xô Bồ. **Thể loại:** game xã hội 2.5D thuần Việt, life-sim online.
- **Nền tảng:** iOS / Android / PC / Web, Unity, cross-save.
- **Xuất thân gacha:** Mặc định / Random / Nạp quay thêm. Tổng chỉ số khởi đầu bằng nhau, chỉ khác phân bổ. Nạp chỉ mua thêm lượt quay / cốt truyện xuất thân, không mua điểm vượt trần.
- **Đa hướng sống:** mỗi nhánh (học, làm thuê, buôn bán, nghệ thuật, gia đình…) có cây tiến triển riêng; người chơi được sống đời mình muốn sống ngoài đời.
- **Thời gian kiểu C:** 1 ngày game = 30 phút thật. 3 khung: Sáng / Chiều / Tối. Chơi 1–2 khung/ngày là đủ. Miss khung không bị phạt. Sự kiện chung: thứ 7, 20:00 tại Phố Đi Bộ – Chợ Đêm (khu 18).
- **Vòng lặp 1 ngày:** chọn khung → làm việc / học / gặp người → kiếm tiền + EXP + quan hệ → về nhà hồi năng lượng → ngủ, sang ngày mới.

## Mục 2 — Lấy / bỏ gì từ game tham khảo

Chi tiết đầy đủ: `docs/references.md`.

- **Lấy từ Gánh Phố:** Việt hoá sâu — mặc cả, bán theo giờ, mưa/nắng đổi nhu cầu, trật tự đô thị, giao thông, Tết, cưới/hỏi.
- **Lấy từ Treasure of Nadia:** khám phá hotspot, inventory + crafting, gợi ý dẫn đường, quest gắn nhân vật, tuỳ chỉnh chi tiết. **Không lấy** nội dung người lớn; chuyển cảnh 2D tĩnh PC sang 2.5D isometric mobile. **Chuẩn tham khảo đầy đủ, bắt buộc đối chiếu suốt quá trình làm: `docs/nadia-reference.md`** — vòng lặp khám phá → thu thập → chế tạo → mở khu (crafting là cổng tiến trình), hotspot lấp lánh to chạm được (không rà pixel), 4 công cụ nâng cấp đổi hành vi thật, fast-travel theo khu đã mở, NPC dẫn đường thay Soul Crystal (gợi ý nhúng trong lời thoại, không biến mất giữa game), điện thoại làm hub. Code: `src/client/Assets/Scripts/Exploration.cs` (hotspot + fast travel + NPC dẫn đường), `Crafting.cs` (công thức chế tạo, vd Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ, tương đương Basic Shovel của Nadia).
- **Lấy từ Đế Chế Vỉa Hè:** NPC có đời sống riêng, sổ sách / thuế minh bạch, quan hệ nhiều tầng.
- **Lấy từ Hàng Rong:** Bụi Đời Chợ Cá — tranh lãnh địa giữa các hợp tác xã.
- **Điện thoại là menu chính:** overlay hub gồm Danh bạ / Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khoẻ, Xã hội, Cài đặt. Điện thoại không thay thế thế giới — vẫn phải đi lại trong phố.

## Mục 3 — Thế giới / khu vực

Đủ 18 khu, 5 tầng lớp — xem `docs/districts.md` (danh sách chuẩn, đã sửa từ 19 về 18).

- **Danh hiệu:** không giới hạn số lượng sưu tầm; hiển thị 1 chính + 2–3 phụ. Mỗi danh hiệu có phe Chính / Tà / Trung lập, yêu cầu chỉ số, khoá nghề. Xung đột chặn lẫn nhau (xem `docs/stats.md` và `src/client/Assets/Scripts/TitleConflict.cs`).

## Mục 4 — Hệ chỉ số

Xem `docs/stats.md`. Tóm tắt: 3 gốc Đỏ Thể / Xanh Trí / Vàng Tâm → trộn ra Tím Kỷ / Cam Dũng / Lục Sáng + Trắng An Yên. Có trần tổng, có đánh đổi, liều mới giàu, người hiền khó làm việc lớn nếu không có đối tác Dũng cao.

## Mục 5 — Học vấn (số đã chốt)

| Bằng | Học phí | Thời gian | Yêu cầu Trí | EXP | Danh vọng | Ghi chú |
|------|---------|-----------|-------------|-----|-----------|---------|
| THPT | Free | 30 ngày game | 20 | 0 | 0 | — |
| Cao đẳng | 20 triệu | 60 ngày | 40 | 500 | 0 | — |
| Cử nhân | 80 triệu | 120 ngày | 60 | 1.500 | 200 | — |
| Thạc sĩ | 200 triệu | 180 ngày | 75 | 3.000 | 500 | — |
| Tiến sĩ / Học giả | 500 triệu | 240 ngày | 90 | 6.000 | 1.500 | Cần mentor |

- **Khoá ngắn hạn:** 3–7 ngày, 2–10 triệu, +10 một chỉ số phụ, mở nghề phụ.
- **EXP** từ học / làm đúng nghề / giúp NPC / thi đậu. Học phí tăng gần gấp đôi mỗi bậc.
- **Cung – cầu:** mỗi tuần 1 nghề thiếu người (lương +30%, dễ trúng) và 1 nghề bão hoà (lương −15%, yêu cầu cao hơn). Trường nhận 20–30 học viên/khoá, ưu tiên thứ tự đăng ký + Trí + Danh vọng; học bổng cho người nghèo mà Trí cao.

## Mục 6 — Nghề & Công ty

- Việc làm có quota theo tuần; giấy phép mua bằng tiền trong game (sạp ăn 50 triệu, phòng khám 200 triệu).
- Nghề đặc biệt cần thi chứng chỉ: phí thi 5–20 triệu tiền trong game, trượt mất phí, chờ tuần sau. Nạp chỉ mua thêm 1 lượt thi/tuần, không mua đậu.
- **Công ty = guild:** lập cần 500 triệu tiền trong game + giấy phép kinh doanh + thuê văn phòng theo tầng khu. Vai trò Giám đốc / Trưởng phòng / Nhân viên / Thực tập. Chia lợi nhuận theo điểm đóng góp, không chia đều; 0 đóng góp 2 tuần → bị loại. Hoạt động: họp thứ 2, hợp đồng chung, đấu thầu, liên minh, cho vay/cứu trợ. Xếp hạng theo doanh thu + Danh vọng; top 3 nhận hợp đồng lớn + văn phòng tầng cao hơn.

## Mục 7 — Tài chính + Nhà / Xe / Điện thoại / Quần áo

Xem `docs/economy.md` (thang nhà/xe, vật phẩm 3 dòng chỉ số, ranh giới pháp lý VN).

## Mục 8 — Xã hội

Ưu tiên theo thứ tự:

1. **Người yêu / Vợ – chồng:** hẹn hò → đính hôn → cưới → nhà chung. Đối tác bù chỉ số cho nhau, chia chi phí nhà, +20% EXP khi được hỗ trợ. Bỏ bê 7 ngày game → thân thiết giảm. Ly hôn chia tài sản.
2. **Bạn thân / Hội bạn:** 1 bạn thân, nhóm 3–5 người, họp hàng tuần không thì nhóm tan.
3. **Gia đình:** cha mẹ cho lời khuyên / Trí + tiền giai đoạn đầu, nhưng gây áp lực cưới / mua nhà. Con cái tốn tiền nhưng cho An Yên cao + ending gia đình.
4. **Công ty / Đối tác làm ăn:** làm chung, hợp đồng, phản bội mất Danh vọng.
- Chỉ duy trì được 2–3 quan hệ sâu trong 3 khung/ngày. Chơi solo được nhưng chậm hơn 30–50%, không có ending gia đình / cặp đôi; game gợi ý nhẹ tìm bạn đồng hành.

## Mục 9 — Cốt truyện + quest (5 chương gắn cấp bậc)

| Chương | Tên | Rank mở | Điều kiện / thưởng |
|--------|-----|---------|-------------------|
| 1 | Lên Phố | Lao động | Đến Sài Gòn, phòng trọ, 7 ngày tiền, việc đầu tiên, bạn đầu tiên. Mở Tầng 1, danh hiệu Tân Binh Phố. |
| 2 | Lập Nghiệp | Cận trung lưu | Chọn học / làm thuê / mở sạp, có mentor, chứng chỉ / hợp đồng / xe máy đầu tiên. Cần việc ổn định, Trí 40 hoặc Cao đẳng, Danh vọng 200. Danh hiệu Nhân Viên Gương Mẫu. |
| 3 | Khủng Hoảng | Bài kiểm tra rank | Công ty phá sản / thi trượt / bị phản bội / nợ đầu tư, muốn bỏ về quê, quest chữa lành về với cha mẹ. Rank có thể tụt nếu Danh vọng / An Yên thấp. Danh hiệu Người Không Gục Ngã, Kỷ +20. |
| 4 | Vực Dậy | Trung lưu | Được người yêu / bạn / gia đình giúp, có thể đổi nghề, giúp 3 NPC khác đang khủng hoảng. Cần 3 quest giúp người + ít nhất 1 quan hệ thân thiết. Danh hiệu Người Vực Dậy, mở quản lý / kỹ sư / bác sĩ và công ty nhỏ. |
| 5 | Thành Đạt / An Yên | Nhánh rank | 4 nhánh: Giám đốc = Thượng lưu (tài sản 10 tỉ, Tầng 4); Học giả = Tiến sĩ, Trí 90, Danh vọng 1.500; Gia đình = Trung lưu + vợ/chồng + An Yên 80; Siêu giàu = tài sản 100 tỉ, Tầng 5. |

- Side quest kiểu Nadia: tìm đồ thất lạc, chế quà tặng, giúp dân địa phương để mở khu mới.

## Mục 10 — Chuẩn đồ hoạ 2.5D

- Chi tiết thấy được khi zoom: sạp hàng có nồi niêu / lá chuối / ghế nhựa, bệnh viện có giường / máy, nhà có đồ nội thất.
- Ngày / đêm, mưa / nắng, trang trí Tết, NPC và giao thông sống động.
- Tuỳ chỉnh nhân vật lúc tạo (mặt, da, tóc, mắt, dáng, giọng) + thay được quần áo / giày / mũ / kính / điện thoại / xe — mỗi món hiện trên bản đồ isometric và mang chỉ số (Mục 7). Phong cách: công sở, đường phố, truyền thống, sang trọng.
- Tuỳ chỉnh nhà (nội thất, tranh, cây, thú cưng — mỗi món An Yên / Trí khác nhau) và điện thoại (hình nền, theme, nhạc chuông, bố cục app).
- Asset modular, nhiều lớp, máy yếu vẫn chạy được.

## Mục 11 — Vertical slice + lộ trình

**Slice tối thiểu (online):** 1 khu (Xóm Trọ Cũ + Chợ Đầu Mối), 3 nghề (bán rong, shipper, nhân viên quán), điện thoại có chat toàn cục / bạn bè / nhắn tin / trade item-to-item / đấu giá nhỏ, thăm nhà nhau, giúp hàng xóm, cặp đôi / bạn thân tối thiểu (NPC bạn thân lấp chỗ tạm thời).

**Chống cold-start:** NPC đóng vai người chơi, 1 server chung (không chia server), sự kiện chung thứ 7 20:00 tại Phố Đi Bộ, quest cần 2 người.

**Bụi Đời Chợ Cá:** mode chiến thuật vui 3v3/5v5 theo lượt trên lưới isometric, ~3 phút, vũ khí hài (chảo, cá khô, ghế nhựa, loa), vai theo màu chỉ số (Đỏ tank, Xanh chiến thuật, Vàng hỗ trợ, Tím chính xác, Cam burst, Lục mẹo), đội thắng giữ sạp chợ 1 tuần (giảm giá sỉ, thuế sạp, Danh vọng). Gắn công ty / hợp tác xã và xung đột danh hiệu (Tướng Cướp buff ở chợ, Cảnh sát buff khi giữ sạp). Không máu me, không chết, không mất đồ vĩnh viễn.

**Lộ trình:** Giai đoạn 1 Slice 2–3 tháng → Giai đoạn 2 MVP online (18 khu, 10 nhóm nghề, công ty=guild, cặp đôi/gia đình, đấu giá) → Giai đoạn 3 mở rộng xã hội → Giai đoạn 4 thành phố mới.

## Mục 12 — Chữa lành

5 điểm đã chốt:

1. Không trừng phạt — thất bại được NPC giúp, tiến chậm vẫn được công nhận.
2. Có chỉ số An Yên / Tự tin riêng — giúp người, học xong, nấu được bữa cơm cũng tăng điểm.
3. NPC có câu chuyện mất mục tiêu của riêng họ — giúp họ thì họ giúp lại mình.
4. Không FOMO — nghỉ ngơi cũng được thưởng, miss 1 ngày không mất gì.
5. Nhiều ending đẹp đều tính là thắng: làm giám đốc, hoặc mở quán nhỏ sống an yên.

## Kiến trúc & vận hành

Xem `docs/architecture.md`. Stack: Unity client, backend .NET 8 modular monolith, PostgreSQL + Redis, offline-first, kinh tế server-authoritative.
