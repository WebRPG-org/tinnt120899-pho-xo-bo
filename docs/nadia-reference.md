# Treasure of Nadia — Chuẩn tham khảo cho Phố Xô Bồ

> Chủ nhắc 18/11/2026 10:41: **phải tham khảo và bám sát Treasure of Nadia trong suốt quá trình làm.**
> File này là lock đối chiếu: mọi hệ mới trong repo phải đối chiếu với bảng này trước khi viết code.
> Nguồn Nadia: fan guide / walkthrough (naguides.com, yekbot.com, gamegoon.net) — KHÔNG phải tài liệu
> chính thức của NLT Media. Engine của Nadia các nguồn mâu thuẫn nhau, nên **chỉ lấy thiết kế hệ
> thống, không lấy kiến trúc kỹ thuật**. Không copy asset, nhạc, lời thoại hay nhân vật của Nadia.
> Cập nhật 18/11/2026 (`docs/tech-switch-nadia.md`): đã xác minh Nadia chạy **RPG Maker MV**
> (xogx.com: "RPG Maker (play in your browser)"; SteamDB: RPGMaker + NWJS + NodeJS) — bản web
> là HTML5/JS (Pixi WebGL renderer), file tĩnh, không phải Unity WebGL `.wasm`.
> Chi tiết đầy đủ hơn (kèm Gánh Phố / Đế Chế Vỉa Hè / Hàng Rong): `docs/references.md` §4.
> GDD Mục 2 tóm tắt ngắn; file này là bản đối chiếu đầy đủ.

## 0. Nguyên tắc bám sát — và ranh giới

- **Bám sát:** đồ họa chi tiết, gameplay thông minh, vòng lặp khám phá → thu thập → chế tạo → mở khu,
  hotspot, inventory + crafting, guidance nhúng trong lore, quest gắn nhân vật, điện thoại làm hub.
- **Chuyển đổi bắt buộc:** cảnh 2D tĩnh trên PC → **2.5D isometric trên mobile** (xem `docs/art-style.md` §7:
  Isometric Z as Y, sort axis (0, 1, −0.26), Cinemachine, atlas theo khu phố). Mọi hệ Nadia phải chạy
  được trên màn hình dọc 9:16, chạm bằng ngón tay, không dùng chuột point-and-click.
- **Thuần Việt:** Cape Vedra (đảo giả tưởng) → thành phố An Bình, 18 khu, 5 tầng lớp (xem
  `docs/districts.md`); đồ vật, nghề, NPC, lễ Tết đều là đời sống Việt, không bê bối cảnh / tên / vật
  phẩm của Nadia sang.
- **Sạch:** game này là life-sim xã hội thuần Việt, **không có nội dung người lớn / harem** — đó là
  ranh giới cứng, không phải chi tiết có thể "lấy một ít".

## 1. Bảng đối chiếu — từng hệ Nadia → Phố Xô Bồ

| # | Hệ Nadia | Áp dụng vào Phố Xô Bồ | File code / docs |
|---|----------|------------------------|------------------|
| 1 | Vòng lặp: Khám phá → Thu thập → Chế tạo → Mở khóa khu vực. Crafting là **cổng tiến trình bắt buộc**, không phải hệ phụ. | Vòng lặp lõi của game: đi phố → nhặt nguyên liệu ở hotspot → chế công cụ / quà → mở khu / nghề / quest mới. Chế tạo không phải mini-game phụ: không chế được đồ cần thì không mở được khu tiếp theo. | `Exploration.cs`, `Crafting.cs`, GDD Mục 2/9/11 |
| 2 | Hotspot lấp lánh (sparkle) + con trỏ đổi dạng; quay lại địa điểm cũ có vật / sự kiện mới. | Hotspot trên bản đồ isometric: điểm sáng lấp lánh, to, chạm được bằng ngón tay, highlight rõ — **không rà từng pixel** (xem hàng KHÔNG LẤY). Mỗi khu có danh sách hotspot theo khung Sáng/Chiều/Tối; quay lại khu cũ sau 1 ngày game có vật / sự kiện mới. | `Exploration.cs` (`Hotspot`, `Explore`) |
| 3 | Inventory + crafting tại Native Crafting Shrine; công thức học qua chơi (vd: Basic Shovel = Shovel Head + Shaft + Iron Ore). | Túi đồ đã có (`Inventory.cs`); chế tạo ở **Góc Chế Tạo** trong nhà / sạp chợ — địa điểm trong thế giới, không phải menu trừu tượng. Công thức học qua chơi / NPC dạy, không mua công thức bằng tiền thật. Ví dụ: Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ (tương đương Basic Shovel của Nadia, đổi sang đồ chợ Việt). | `Crafting.cs` (`RecipeCatalog`), `Inventory.cs` |
| 4 | Chế talisman bán lấy tiền là cách kiếm tiền chính. | Đồ chế ra bán được ở Chợ (qua tab Chợ trên điện thoại + sạp trong thế giới), nhưng **không phải nguồn tiền duy nhất** — nghề / buôn bán / học vấn vẫn là trụ (GDD Mục 5–7). Tránh để crafting thành "máy in tiền" phá kinh tế. | `Crafting.cs`, GDD Mục 7, `docs/economy.md` |
| 5 | 4 công cụ cố định (Boots, Metal Detector, Guide, Shovel), mỗi nâng cấp **đổi rõ hành vi** (miễn nhiễm môi trường, đào nhanh, loot tốt hơn) — không chỉ +5% số. | 4 công cụ Phố Xô Bồ (tên Việt, theo đời chợ): **Xe Đẩy, Đèn Pin / Đèn Soi, Sổ Tay Dẫn Đường, Xẻng / Cuốc Nhặt** — mỗi bậc nâng cấp đổi hành vi thật: Xe Đẩy bậc cao chở được nhiều hơn + đi được đường mưa; Đèn Soi bậc cao thấy hotspot ẩn; Sổ Tay mở thêm gợi ý; Xẻng bậc cao thu thập nhanh hơn / được đồ hiếm. Không làm nâng cấp chỉ +5% số. | `Crafting.cs` (`ToolTier`), `Exploration.cs` |
| 6 | Local Map fast-travel (ô xanh đi được / cửa đỏ chưa mở). | Bản đồ trên điện thoại (tab Bản đồ, `PhoneHub.cs`): khu đã mở = đi ngay (fast travel), khu chưa mở = khóa, ghi rõ điều kiện mở (chế đồ / làm quest / đủ chỉ số). Chỉ fast travel tới khu đã mở — không "dịch chuyển" qua khu chưa khám phá. | `Exploration.cs` (`CanFastTravel`, `FastTravel`), `PhoneHub.cs` |
| 7 | Quest 2 lớp gợi ý: NPC + Soul Crystal / Evie chỉ hướng khi bí (hint nhúng trong lore). | **NPC dẫn đường thay Soul Crystal:** cô Tư (chủ trọ), bạn thân NPC, mentor — khi người chơi bí (không biết làm gì tiếp), NPC quen gợi ý bằng lời thoại trong thế giới, không hiện nút "Gợi ý" khô khan. Gợi ý gắn với mục tiêu hiện tại (quest / chương), không spoil đáp án. | `Exploration.cs` (`GuideHint`), GDD Mục 9 |
| 8 | Điện thoại là hub hệ thống: Save/Load, Settings, Progress, replay — một thiết bị trong thế giới gom mọi menu. | Điện thoại là menu chính của Phố Xô Bồ (GDD Mục 2, đã chốt): 9 tab Danh bạ/Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt. Mọi menu đi qua điện thoại, nhưng điện thoại **không thay thế thế giới** — vẫn phải đi lại trong phố để khám phá / làm việc / gặp NPC. | `PhoneHub.cs` |
| 9 | Quest gắn nhân vật, đồ thất lạc, giúp dân địa phương để mở khu mới. | Side quest kiểu Nadia (GDD Mục 9): tìm đồ thất lạc, chế quà tặng, giúp NPC đang khủng hoảng → mở khu mới / tăng thân thiết / mở nghề. Quest chính 5 chương gắn rank (GDD Mục 9). | GDD Mục 8/9, `Exploration.cs` |
| 10 | Chi tiết đồ họa: nền pre-rendered chi tiết, thấy được khi zoom, vật dụng kể chuyện. | Chuẩn đồ họa Nadia chuyển sang 2.5D: chi tiết thấy được khi zoom (sạp có nồi niêu / lá chuối / ghế nhựa, nhà có đồ nội thất), ngày/đêm, mưa/nắng, Tết. Mỗi vật trên map phải "kể" được đời sống Việt, không phải prop rỗng. Rubric 8 chiều, đủ 12/16 mới ship. | `docs/art-style.md` §1/§4/§6 |
| 11 | Puzzle đền (pressure plate theo thứ tự, khóa/chìa theo biểu tượng). | **Chỉ lấy tinh thần, không bê nguyên:** puzzle trong Phố Xô Bồ là puzzle đời thường — sắp xếp sạp hàng, ghép đơn shipper theo tuyến, mở khóa kho bằng mật mã NPC cho — logic, không dùng đền / biểu tượng huyền bí. Không làm puzzle chặn cốt truyện chính quá lâu. | GDD Mục 9 (side quest) — chưa có code riêng, làm ở phase sau |
| 12 | Hệ phụ sau cốt truyện: câu cá, trồng cây, nâng cấp nhà. | Hệ phụ theo nhịp chữa lành (GDD Mục 12): trồng cây / nuôi thú cưng trong nhà, câu cá ở Công Viên An Bình, nâng cấp nhà — mở dần sau Chương 2, không nhồi vào slice đầu. | GDD Mục 10/12 — phase sau |

## 2. Danh sách KHÔNG lấy từ Nadia

| # | Không lấy | Vì sao |
|---|-----------|--------|
| 1 | Toàn bộ nội dung người lớn / harem | Rủi ro store + pháp lý VN; trái với hướng chữa lành / thuần Việt của game. Ranh giới cứng. |
| 2 | Point-and-click rà từng pixel tìm hotspot | Mobile chạm tay cần hotspot lớn, lấp lánh, highlight rõ. Rà pixel gây ức chế, không hợp 2.5D mobile. |
| 3 | Quest khóa theo ngày/giờ cứng (phải đúng thứ Ba/Năm mới làm được) | Trái luật "không FOMO, miss khung không phạt" (GDD Mục 1/12). Quest mở theo tiến trình, không theo lịch thật cứng. |
| 4 | Mất hệ gợi ý đột ngột giữa game | Nadia bị fan chê mất hint giữa chừng; Phố Xô Bồ giữ NPC dẫn đường suốt 5 chương, gợi ý nhạt dần theo tiến trình chứ không biến mất. |
| 5 | Pacing 50+ giờ kiểu PC, cốt truyện dài lê thê | Phố Xô Bồ chơi 1–2 khung/ngày, 1 ngày game = 30 phút thật. Chương ngắn, mỗi phiên có tiến triển thấy được. |
| 6 | Engine / kiến trúc kỹ thuật của Nadia | Các nguồn mâu thuẫn nhau (RPG Maker MV / Ren'Py / Unity) — không đáng tin. Kiến trúc của Phố Xô Bồ theo `docs/architecture.md` (Unity + .NET 8 modular monolith). |
| 7 | Asset, nhạc, lời thoại, nhân vật, tên địa danh của Nadia | Bản quyền. Mọi art / nhạc / tên trong repo phải tự vẽ hoặc CC0 có nguồn rõ ràng (xem `docs/art-style.md` §5). |

## 3. Checklist bám sát — dùng trước mỗi lần viết hệ mới

Trước khi thêm 1 hệ / 1 khu / 1 quest, đối chiếu:

- [ ] Vòng lặp có đủ Khám phá → Thu thập → Chế tạo → Mở khóa không, hay chỉ là menu bấm nút?
- [ ] Hotspot có nhìn thấy được, chạm được, lấp lánh không — hay phải rà từng pixel?
- [ ] Công cụ nâng cấp có đổi hành vi thật không — hay chỉ +5% số?
- [ ] Có NPC dẫn đường bằng lời thoại khi người chơi bí không?
- [ ] Điện thoại có phải hub (mở tab là tới) nhưng vẫn bắt người chơi đi lại trong phố không?
- [ ] Có chi tiết đồ họa nào lấy từ Nadia mà chưa Việt hoá / chưa chuyển sang 2.5D không?
- [ ] Có nội dung người lớn / harem / asset Nadia nào lọt vào không? (Nếu có: gỡ ngay.)
- [ ] Số liệu mới có mâu thuẫn `GameBalance.cs` / GDD không? Số chưa chốt phải ghi PROVISIONAL.

## 4. Nguồn

- Fan guide / walkthrough Nadia: naguides.com, yekbot.com, gamegoon.net, xmodhub.com (tra cứu 17/11/2026).
- GDD Mục 2, `docs/references.md` §4 (bản tóm tắt lấy/bỏ), `docs/art-style.md` (chuẩn đồ họa Nadia chuyển sang 2.5D).
- Quyết định của chủ 18/11/2026 10:41: tham khảo và bám sát Treasure of Nadia trong suốt quá trình làm.
