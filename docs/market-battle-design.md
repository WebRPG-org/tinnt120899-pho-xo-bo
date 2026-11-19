# Bụi Đời Chợ Cá — Bản thiết kế luật (ĐỀ XUẤT CHO CHỦ DUYỆT)

> Trạng thái: **CHƯA CHỐT — chờ chủ duyệt.** Mọi số trong file này đều là
> **PROVISIONAL** (đề xuất) trừ những dòng ghi rõ "ĐÃ CHỐT (GDD Mục 11)".
> Nguồn GDD duy nhất: `docs/gdd.md` Mục 11 + `docs/architecture-nadia.md`
> §4.6, dòng 372 (plugin số 14, Phase 2, "luật chưa chốt").
> Triển khai logic lõi: `src/nadia/www/js/plugins/PXB_MarketBattle.js`
> (scene/bản đồ trận là việc sau — xem "Ngoài phạm vi" cuối file).

## 1. Số ĐÃ CHỐT (GDD Mục 11 — không được sửa ở đây)

- Mode chiến thuật vui, theo lượt, trên lưới isometric, **~3 phút/trận**.
- Đội **3v3 hoặc 5v5**.
- Vũ khí hài: **chảo, cá khô, ghế nhựa, loa**.
- Vai theo màu chỉ số: **Đỏ tank, Xanh chiến thuật, Vàng hỗ trợ,
  Tím chính xác, Cam burst, Lục mẹo**.
- Đội thắng **giữ sạp chợ 1 tuần** (giảm giá sỉ, thuế sạp, Danh vọng).
- Gắn **công ty / hợp tác xã** và **xung đột danh hiệu** (Tướng Cướp buff
  ở chợ, Cảnh sát buff khi giữ sạp).
- **Không máu me, không chết, không mất đồ vĩnh viễn.**
- Chữa lành (GDD Mục 12): thất bại không bị phạt.

## 2. Tổng quan trận đấu

- Trận diễn ra tại **Chợ Đầu Mối** (khu slice, GDD Mục 11).
- Hai đội đứng hai đầu lưới, lượt đi xen kẽ theo đội (A1 → B1 → A2 →
  B2 …). Mỗi lượt 1 đấu sĩ được **1 hành động**: di chuyển (tối đa
  tầm di chuyển) + 1 đòn đánh HOẶC 1 lần hỗ trợ.
- Hết HP = **"ngã sạp"** (ngồi bệt xuống, xỉu vì cười — KHÔNG chết, KHÔNG
  mất đồ). Đấu sĩ ngã thì nghỉ hết trận; hết trận hồi đầy HP.
- Hết trận khi: một đội ngã hết, hoặc hết giờ, hoặc quá số vòng tối đa
  (xem §5).

## 3. Lưới + di chuyển — PROVISIONAL

| Hạng mục | Số đề xuất | Nguồn suy ra |
|---|---|---|
| Kích thước lưới | **12 × 9 ô** | PROVISIONAL — chưa có trong GDD. Chọn 12×9 để 5v5 (10 đấu sĩ) còn chỗ xoay xở mà vẫn vừa viewport dọc 9:16 (720×1280, tile 64×32 theo `PXB_Isometric.js`). Chủ duyệt hoặc đổi trước khi làm scene. |
| Xuất phát | Đội A cột x = 0–1, đội B cột x = 10–11, hàng rải đều | PROVISIONAL — đối xứng, không bên nào lợi thế. |
| Tầm di chuyển | **3 ô / lượt** (khoảng cách Manhattan, không đi xuyên đấu sĩ khác, không ra khỏi lưới) | PROVISIONAL — 3 ô đủ để áp sát trong 2 lượt từ vạch xuất phát (khoảng cách giữa 2 đội ~9 ô). |
| Tầm đánh | Theo vũ khí (§4), khoảng cách Manhattan | PROVISIONAL — cùng thước đo với di chuyển cho dễ hiểu. |

## 4. Vai theo màu + vũ khí — PROVISIONAL

Màu chỉ số lấy theo `docs/stats.md`: Đỏ = Thể, Xanh = Trí, Vàng = Tâm,
Tím = Kỷ (Đỏ+Xanh), Cam = Dũng (Đỏ+Vàng), Lục = Sáng (Xanh+Vàng).
Vai của 1 đấu sĩ = màu có **điểm cao nhất** trong 6 màu (hòa thì ưu tiên
vai trộn Tím → Cam → Lục trước vai gốc Đỏ → Xanh → Vàng, vì vai trộn là
trung bình cộng nên chỉ hòa chứ không vượt vai gốc; chỉ số cân bằng cả
3 gốc → Tím); event vẫn được chỉ định vai trực tiếp khi cần (vd NPC test).

### 4.1. Vai (passive)

| Vai | Màu | Passive đề xuất | Nguồn suy ra |
|---|---|---|---|
| Tank | Đỏ | Max HP **×1,5**, sát thương nhận **×0,8** | PROVISIONAL — "tank" theo tên vai GDD; hệ số lấy tròn, chưa playtest. |
| Chiến thuật | Xanh | Di chuyển **+1 ô** (4 ô/lượt) | PROVISIONAL — "chiến thuật" = cơ động, chọn vị trí. |
| Hỗ trợ | Vàng | Hành động **Hỗ trợ**: hồi **12 HP** cho 1 đồng đội kề bên (thay vì đánh) | PROVISIONAL — 12 HP ≈ 1 đòn chảo, để hỗ trợ không lấn át tấn công. |
| Chính xác | Tím | Sát thương gây ra **×1,25** | PROVISIONAL — "chính xác" = đánh trúng chỗ đau. |
| Burst | Cam | **Đòn đầu tiên** của trận **×2** sát thương | PROVISIONAL — "burst" = dồn 1 đòn mở màn; chỉ 1 lần/trận để không vỡ game. |
| Mẹo | Lục | **Né đòn đầu tiên** nhận trong mỗi vòng (sát thương về 0) | PROVISIONAL — "mẹo" = lách khéo; 1 lần/vòng, tính lại mỗi vòng. |

### 4.2. Vũ khí hài

| Vũ khí | Sát thương | Tầm | Hiệu ứng thêm | Nguồn suy ra |
|---|---|---|---|---|
| Chảo | **12** | 1 ô | — | PROVISIONAL — vũ khí cận chiến chuẩn; ~8 đòn hạ 1 đấu sĩ 100 HP. |
| Cá khô | **8** | 2 ô | — | PROVISIONAL — yếu hơn chảo để đổi lấy tầm xa. |
| Ghế nhựa | **15** | 1 ô | **Đẩy lùi** mục tiêu 1 ô (nếu ô sau trống, trong lưới) | PROVISIONAL — mạnh nhất cận chiến, đổi bằng hiệu ứng đẩy (có thể đẩy đối thủ ra khỏi tầm đánh của đồng đội họ). |
| Loa | **10** | 3 ô | — | PROVISIONAL — tầm xa nhất, sát thương thấp nhất. |

- Mỗi đấu sĩ mang **1 vũ khí** suốt trận (chọn lúc lập đội).
- Vũ khí là **đồ mượn của chợ** (chảo/g ghế/loa của sạp) — thua không mất,
  đúng "không mất đồ vĩnh viễn".
- Thứ tự tính sát thương: sát thương vũ khí → × vai Tím/Cam (nếu có)
  → × buff danh hiệu (§7) → làm tròn xuống → × giảm thương của Tank
  (nếu mục tiêu là Đỏ) → trừ vào HP. Không có chí mạng ngẫu nhiên:
  số cố định để test được, để chủ cân bằng sau.

## 5. Lượt, giờ, thắng/thua — PROVISIONAL

| Hạng mục | Số đề xuất | Nguồn suy ra |
|---|---|---|
| Thời gian 1 lượt | Tối đa **10 giây** (hết giờ tự chuyển lượt) | PROVISIONAL — trận ~180s (GDD chốt "~3 phút"), 3v3 có 6 lượt/vòng; lượt trung bình ~5s thì ~6 vòng/trận, đủ đánh ngã 1–2 đấu sĩ mỗi bên. 10s là trần, không phải thời gian bắt buộc. |
| Thời gian trận | Tối đa **180 giây** (3 phút) kể từ lượt đầu | PROVISIONAL — lấy đúng "~3 phút" GDD. Hết 180s thì dừng, không kéo dài. |
| Số vòng tối đa | **12 vòng** (lưới an toàn, trận luôn kết thúc) | PROVISIONAL — 12 vòng × 6 lượt × 10s = 720s là trần lý thuyết; thực tế đồng hồ 180s cắt trước. Vòng 13 không bao giờ tới nếu đồng hồ chạy đúng. |
| Thắng | Đội còn đấu sĩ đứng khi đội kia ngã hết | GDD (đội thắng giữ sạp) — điều kiện thắng suy ra từ thể thức đội. |
| Hết giờ / hết vòng | Đội có **tổng % HP còn lại cao hơn** thắng | PROVISIONAL — thước đo công bằng nhất khi chưa ngã hết; % HP (không phải HP tuyệt đối) để Tank 150 HP không lấn át. |
| Hòa | Tổng % HP bằng nhau (làm tròn 2 chữ số) | PROVISIONAL — hòa thì **không đội nào giữ sạp** (sạp về tay đội đang giữ cũ, hoặc bỏ trống nếu chưa ai giữ). |

## 6. Giữ sạp 1 tuần — PROVISIONAL

Đội thắng giữ sạp **7 ngày game** (1 ngày game = 30 phút thật,
`PXB_Time.js` — đã chốt). Hết 7 ngày thì sạp trống, đội khác được tranh.

| Quyền lợi khi giữ sạp | Số đề xuất | Nguồn suy ra |
|---|---|---|
| Giảm giá sỉ | **−10%** giá mua sỉ tại chợ cho mọi thành viên đội giữ sạp | PROVISIONAL — GDD chỉ chốt "giảm giá sỉ", không chốt %. 10% đủ cảm nhận, không phá kinh tế (so với phí sàn đấu giá 5% đã chốt). |
| Thuế sạp | **−20%** thuế sạp cho mọi thành viên đội giữ sạp | PROVISIONAL — GDD chỉ chốt "thuế sạp", không chốt %. 20% vì thuế sạp là chi phí nhỏ, giảm sâu mới đáng tranh. |
| Danh vọng | **+10 / ngày game** cho mọi thành viên đội giữ sạp (cộng lúc sang ngày) | PROVISIONAL — so với Danh vọng bằng cấp: Cử nhân +200, Thạc sĩ +500 (GDD Mục 5 đã chốt) → 1 tuần giữ sạp = +70, nhỏ hơn 1 bằng, không lạm phát Danh vọng. |

- **1 đội giữ tối đa 1 sạp.** Đội đang giữ sạp A thì **không được thách
  đấu sạp B** — phải đợi sạp A hết hạn, hoặc thua trận thủ sạp (xem §8).
- Sạp đang có đội giữ thì đội khác thách đấu = **trận tranh sạp**: đội
  thách đấu thắng thì cướp sạp (giữ 7 ngày mới từ ngày thắng); đội giữ
  thắng thì giữ tiếp **đến hết hạn cũ** (không cộng thêm 7 ngày).
- Đội thắng trận **không tranh sạp** (trận giao hữu / luyện tập) thì chỉ
  nhận Danh vọng trận (§9), không giữ sạp.
- Ghi giữ sạp vào `$gameSystem.pxbMarketBattle.holds` nên **đi theo
  save** của MV; hết hạn thì `expireHolds(gameDay)` dọn.

## 7. Buff danh hiệu — PROVISIONAL (mức %, không phải sự tồn tại)

GDD chốt **sự tồn tại** của 2 buff: Tướng Cướp buff ở chợ, Cảnh sát buff
khi giữ sạp. Mức % dưới đây là PROVISIONAL.

| Danh hiệu | Buff đề xuất | Nguồn suy ra |
|---|---|---|
| **Tướng Cướp** | Sát thương gây ra trong trận chợ **+10%** (mọi trận Bụi Đời đều ở chợ nên áp dụng mọi trận) | PROVISIONAL — 10% là mức buff nhỏ, tương đương 1 đòn chảo thêm ~1 sát thương; "Tướng Cướp" hợp chợ vì phe Tà quen chợ (xung đột danh hiệu `PXB_Titles.js` đã chốt). |
| **Cảnh sát** | Max HP **+10%** khi **thủ sạp đội mình đang giữ** (trận tranh sạp mà đội mình là bên giữ) | PROVISIONAL — "buff khi giữ sạp" theo đúng chữ GDD: chỉ bật khi thủ sạp, không bật khi đi thách đấu sạp khác. |

- Hai danh hiệu **xung đột nhau** (Tướng Cướp chặn Cảnh sát và ngược lại,
  `PXB_Titles.js` / `TitleConflict.cs` đã chốt) nên 1 đấu sĩ không bao giờ
  hưởng cả 2 buff cùng lúc — không cần luật trừ chồng.
- Buff đọc từ `PXB_Titles` khi plugin đó đã load; khi test thuần thì
  truyền danh sách danh hiệu trực tiếp vào đấu sĩ (xem plugin).

## 8. Điều kiện mở trận — PROVISIONAL

Trận chỉ mở khi đủ **tất cả**:

1. Đội đủ **3 hoặc 5** đấu sĩ, hai đội **bằng nhau** (3v3 hoặc 5v5) —
   GDD chốt thể thức; chặn trận khi thiếu người là luật của plugin.
2. Mọi đấu sĩ cùng **1 công ty / hợp tác xã** (đội = công ty hoặc nhóm
   trong hợp tác xã) — GDD chốt "gắn công ty / hợp tác xã"; Phase 1
   (offline) dùng NPC lấp chỗ như slice online (GDD Mục 11: "NPC đóng
   vai người chơi").
3. Trận ở **Chợ Đầu Mối** (khu slice) — địa điểm theo GDD Mục 11.
4. Đội thách đấu **không đang giữ sạp khác** (§6) — chặn với lý do
   `dang-giu-sap-khac`; đội đã giữ sạp đó rồi thì thách đấu chính sạp
   đó cũng bị chặn (`da-giu-sap-nay`, muốn giữ tiếp thì thủ sạp khi bị
   thách đấu).
5. Trận tranh sạp chỉ mở khi sạp có đội giữ (đội thách đấu đấu với đội
   giữ) hoặc sạp trống (đấu với đội NPC giữ hộ / đội thách đấu khác —
   Phase 1 dùng NPC; Phase 2 online đấu đội người thật).

## 9. Phần thưởng trận — PROVISIONAL

Theo GDD Mục 12 (chữa lành): **thua không bị phạt** — không mất tiền,
không mất đồ, không trừ Danh vọng.

| Kết quả | Danh vọng / người | Ghi chú |
|---|---|---|
| Thắng | **+50** | PROVISIONAL — nhỏ so với bằng cấp (§6), chỉ là ghi nhận. Thắng tranh sạp thì cộng thêm quyền giữ sạp. |
| Hòa | **+20** | PROVISIONAL |
| Thua | **+10** | PROVISIONAL — "đi chợ vui cũng có điểm", đúng tinh thần không phạt. |

- Danh vọng trả về trong kết quả trận (`result.rewards`); việc cộng vào
  sổ Danh vọng làm ở event / `PXB_Economy` sau — plugin trận không tự
  cộng tiền/Danh vọng (không tự quyết kinh tế, theo `architecture-nadia.md` §6).
- Tiền thưởng: **không có** — GDD không chốt tiền thưởng trận; nếu chủ
  muốn thêm thì duyệt bổ sung (tránh phá kinh tế server-authoritative).

## 10. Ngoài phạm vi (việc sau, KHÔNG có trong plugin này)

- **Scene / UI trận** (`Scene_MarketBattle`, vẽ lưới isometric, sprite
  đấu sĩ, animation chảo/cá khô, đồng hồ lượt): plugin hiện tại chỉ là
  **logic lõi thuần** — header plugin ghi rõ.
- **Bản đồ trận** trong MV (`data/MapXXX.json`, `Troops.json`,
  `Enemies.json` làm khung đối thủ — xem `architecture-nadia.md` §4.6).
- **Online Phase 2**: đấu đội người thật, đồng bộ lượt qua server .NET
  (plugin `PXB_Online.js`); Phase 1 chỉ đấu NPC.
- **Cân bằng sau playtest**: mọi số PROVISIONAL trên đây đều có thể đổi
  sau khi test thật — đổi thì sửa đồng thời file này + plugin +
  `docs/gdd.md` Mục 11 (nếu chủ chốt số mới thành số chốt).

## 11. Danh sách cần chủ duyệt (tóm tắt)

1. Lưới 12×9, di chuyển 3 ô, xuất phát 2 đầu — §3.
2. Passive 6 vai + sát thương/tầm/hiệu ứng 4 vũ khí — §4.
3. Lượt 10s, trận 180s, tối đa 12 vòng, thắng bằng % HP khi hết giờ, hòa không giữ sạp — §5.
4. Giữ sạp 7 ngày game: giá sỉ −10%, thuế sạp −20%, Danh vọng +10/ngày; 1 đội 1 sạp; thắng thủ sạp không gia hạn — §6.
5. Buff Tướng Cướp +10% sát thương ở chợ; Cảnh sát +10% Max HP khi thủ sạp — §7.
6. Điều kiện mở trận 5 điểm (đủ người, cùng công ty, ở chợ, không giữ sạp khác) — §8.
7. Danh vọng trận thắng +50 / hòa +20 / thua +10; không tiền thưởng — §9.
