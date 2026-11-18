# Bảng kiểm 5 vai — Phố Xô Bồ

> Áp dụng đúng 5 vai: Đồ hoạ, SA, DEV, QC, PM — vào toàn bộ file / docs / code
> trong repo này. Ngày kiểm: 17/11/2026. Vai trò là vai làm việc, chưa phải
> người cụ thể — owner trong roadmap là vai chịu trách nhiệm, không phải tên người.

## 1. Vai Đồ hoạ — PASS có điều kiện

Áp dụng skill `soulful_short_video` (khoá thế giới / diễn viên / giọng trước
khi sản xuất; hỏng thì quay lại, không vá trong edit) + chuẩn 2.5D đã chốt
(Mục 10). Chi tiết lock ở `docs/art-style.md`.

| Kiểm | Kết quả | Ghi chú |
|------|---------|---------|
| Palette khóa + phong cách Việt thống nhất | ✅ PASS | Tường vàng, tôn, lá chuối, nắng vàng; cấm tông neon cyberpunk làm chính. File `docs/art-style.md` §2. |
| Mô tả verbatim 4 khu slice đầu | ✅ PASS | Xóm Trọ Cũ, Chợ Đầu Mối, Công Viên An Bình, Phố Đi Bộ – Chợ Đêm — dùng nguyên văn mọi lần. |
| Mô tả nhân vật verbatim + biểu cảm theo cảnh | ✅ PASS | Người Việt trẻ, dáng bình thường, không mặt Tây; tay đơn giản. |
| Art placeholder rõ nguồn CC0, không asset lậu | ⚠️ PASS có điều kiện | `assets/` đang trống — đúng trạng thái (chưa có art nào, không đưa asset lậu vào). Nguồn CC0 được phép: Kenney.nl, OpenGameArt (tag CC0), Unity Top-Down Starter Kit. Chưa có file art nào để đối chiếu nguồn. |
| Rubric chấm 8 chiều, đủ 12/16 mới ship | ✅ PASS (quy trình) | Chưa có take nào để chấm — rubric đã khóa, áp dụng khi có take đầu tiên. |
| Nhạc / giọng | ❌ CHƯA CÓ | Chưa chọn track nào. Theo skill: phải chọn track có bản quyền rõ ràng trước khi sản xuất; audio gen chỉ là footage câm. Cần chủ chốt. |

## 2. Vai SA (Solution Architect) — PASS

Bám bản Kiến trúc Đa nền tảng (web artifact `kien-truc-pho-xo-bo-da-nen-tang`).
Stack **không đổi**: Unity client + backend .NET 8 modular monolith,
PostgreSQL + Redis, offline-first, kinh tế server-authoritative.

| Quyết định kiến trúc | Trade-off đã ghi | Trạng thái |
|----------------------|------------------|------------|
| Modular monolith thay vì microservices từ đầu | Đơn giản vận hành, deploy 1 lần; tách service sau khi DAU vượt ngưỡng. Đổi lại: module phải khóa biên bằng architecture test, không gọi chéo lén. | ✅ Ghi trong `docs/architecture.md` + `src/server/README.md` |
| PostgreSQL là source of truth; Redis chỉ read model/cache | Mất cache không mất tài sản người chơi. Đổi lại: phải có outbox relay PG → Redis, không dual-write. | ✅ Ghi trong `src/server/README.md`, `docs/references.md` §6 |
| Kinh tế double-entry ledger, server-authoritative | Chống gian lận, reconcile được. Đổi lại: mọi reward offline phải validate/clamp ở server khi sync, code phức tạp hơn. | ✅ Ghi trong `src/server/README.md` |
| Orleans Grain + SignalR cho thực thể stateful | Đã chứng minh ở Halo/Xbox Live; Grain single-threaded nên không race. Đổi lại: thêm Orleans vào stack vận hành, team phải học virtual actor. | ⚠️ Đề xuất từ nghiên cứu — **chưa chốt**, cần chủ chốt trong 6 quyết định kiến trúc |
| Offline-first: SQLite local + outbox + idempotency key | Chơi offline được, sync nền. Đổi lại: conflict policy theo loại dữ liệu, không last-write-wins toàn cục. | ✅ Ghi trong `src/server/README.md` |
| Isometric Z as Y, sort axis (0, 1, –0.26) | Làm được nhà 2 tầng / gác lửng mà không cần 3D thật. Đổi lại: sort sai là lỗi hiển thị khó debug — phải khóa hằng số ngày đầu. | ✅ Ghi trong `docs/art-style.md` §7 |

**Không tự đổi stack:** không có thay đổi stack nào trong đợt này. Mọi đề xuất
mới (Orleans, NavMeshPlus, Tiled) đều ghi là “đề xuất từ nghiên cứu, cần chốt”.

## 3. Vai DEV — PASS có điều kiện

Code sạch, chia module theo 12 mục, comment tiếng Việt, không hardcode số
liệu mâu thuẫn (số chốt tập trung ở `GameBalance.cs`).

| Kiểm | Kết quả | Ghi chú |
|------|---------|---------|
| Module theo 12 mục | ✅ PASS | `Stats.cs` (Mục 4), `TimeSystem.cs` (Mục 1), `District.cs` + `TitleConflict.cs` (Mục 3), `GameBalance.cs` (Mục 5–9). |
| Comment tiếng Việt | ✅ PASS | Mọi file `.cs` đều comment tiếng Việt. |
| Không hardcode số mâu thuẫn | ✅ PASS (sau sửa) | Số chốt chỉ nằm ở `GameBalance.cs`; các file khác dùng hằng. Kiểm bằng grep: không còn số tiền / ngày / EXP hardcode ngoài `GameBalance.cs` và docs. |
| Số ví dụ ghi rõ là ví dụ | ⚠️ ĐÃ SỬA | **Lỗi đã phát hiện và sửa trong đợt này:** `Stats.cs` từng ghi trần tổng 300 như đã chốt, trong khi plan chỉ chốt “có trần” — 300 là số ví dụ. Đã gắn cờ PROVISIONAL + cảnh báo QC. Ngưỡng cân bằng An Yên ±10 cũng là số tạm, đã gắn cờ tương tự. |
| Build được | ❌ CHƯA VERIFY | Máy này **không có dotnet / Unity / csc** — không biên dịch được code C#. Ngoặc cân bằng ở 5/5 file (kiểm bằng đếm `{`/`}`), nhưng đó không phải là build. Cần build thật trên máy có Unity 2022 LTS + .NET 8 SDK. Server hiện chỉ có README, chưa có `.csproj` / solution. |
| Không secret / asset lậu | ✅ PASS | Grep toàn repo: không có `.env`, key, token. `assets/` trống. |

## 4. Vai QC — Checklist chéo số liệu

Kiểm bằng grep + đếm trực tiếp trên repo ngày 17/11/2026.

| # | Kiểm | Kỳ vọng | Thực tế | Kết quả |
|---|------|---------|---------|---------|
| Q1 | Số khu | 18 khu mọi nơi | `District.cs`: 18 entry; `docs/districts.md`: 18 dòng; README/GDD: “18 khu” | ✅ PASS |
| Q2 | Danh sách khu | Khớp danh sách gốc 4+3+3+3+3+2 chung | Khớp đúng thứ tự 1–18, kể cả Phố Đi Bộ – Chợ Đêm là khu 18 | ✅ PASS |
| Q3 | Học vấn | THPT free/30d/Trí 20/EXP 0; CĐ 20tr/60d/Trí 40/EXP 500; CN 80tr/120d/Trí 60/EXP 1500/DV 200; ThS 200tr/180d/Trí 75/EXP 3000/DV 500; TS 500tr/240d/Trí 90/EXP 6000/DV 1500 + mentor | `docs/gdd.md` bảng Mục 5 khớp; `GameBalance.cs` 5 bậc khớp | ✅ PASS |
| Q4 | Thời gian | 1 ngày = 30 phút, 3 khung, miss không phạt, sự kiện thứ 7 20:00 | GDD + stats + `TimeSystem.cs` (FrameLength = 10 phút = 30/3) khớp | ✅ PASS |
| Q5 | Tiền — nhà | Trọ 2tr/tháng → mini 800tr → phố nhỏ 3 tỉ → phố lớn 8 tỉ → biệt thự 25 tỉ → penthouse/đảo 100 tỉ | `docs/economy.md` + `GameBalance.cs` khớp | ✅ PASS |
| Q6 | Tiền — giấy phép / thi / công ty | Sạp 50tr, phòng khám 200tr, thi 5–20tr, công ty 500tr | GDD + economy + `GameBalance.cs` khớp | ✅ PASS |
| Q7 | Tiền — lãi / phí | Lãi 0,5%/tháng game, phí đấu giá 5%, mua lớn +50 Danh vọng | Economy + `GameBalance.cs` khớp | ✅ PASS |
| Q8 | Xã hội | Bỏ bê 7 ngày giảm thân thiết, hỗ trợ +20% EXP, solo chậm 30–50% | GDD + `GameBalance.cs` khớp | ✅ PASS |
| Q9 | Rank Chương 5 | Giám đốc tài sản 10 tỉ, Siêu giàu 100 tỉ, Gia đình An Yên 80 | GDD + `GameBalance.cs` khớp | ✅ PASS |
| Q10 | Trần chỉ số | Plan chỉ chốt “có trần”, chưa chốt số | `Stats.cs` từng ghi 300 như đã chốt → **FAIL, đã sửa thành PROVISIONAL** | ⚠️ ĐÃ SỬA, chờ chủ chốt số |
| Q11 | `docs/references.md` | Có, ghi nguồn + lấy/không lấy | Trước đợt này **thiếu file** → **FAIL, đã bổ sung** | ✅ PASS (sau bổ sung) |
| Q12 | Prototype artifact | 18 khu | Bảng prototype vẫn liệt kê **19 khu** (thừa “Bến Du Thuyền”) — ngoài repo, chưa sửa được từ đây | ❌ LỖI CÒN TỒN |

### Lỗi còn tồn (QC)

1. **❌ Prototype artifact vẫn 19 khu** — repo đã đúng 18, nhưng bảng web
   `bang-prototype-game-xa-hoi-viet-2-5d` vẫn thừa “Bến Du Thuyền”. Cần 1 lượt
   edit artifact riêng (gộp/bỏ khu thừa cho về 18).
2. **❌ Chưa build được code** — không có dotnet/Unity trên máy này; server
   chưa có `.csproj`. Cần build thật trước khi nhận “DEV xong”.
3. **⚠️ Trần tổng chỉ số (300) + ngưỡng An Yên (±10) chưa chốt** — đã gắn cờ
   PROVISIONAL, cần chủ chốt số.
4. **⚠️ 10 nhóm nghề** — roadmap GDD nhắc “10 nhóm nghề” ở MVP nhưng chưa có
   danh sách 10 nhóm nào. Cần chủ / PM chốt danh sách.
5. **⚠️ Chưa có art / nhạc nào** — `assets/` trống (đúng trạng thái, nhưng
   slice đầu cần ít nhất 4 khu + 1 nhân vật placeholder CC0).

## 5. Vai PM — Roadmap, owner, việc chờ chốt

Owner = vai chịu trách nhiệm (chưa phải tên người).

### Roadmap Slice → MVP

| Giai đoạn | Nội dung | Owner | Ước tính | Trạng thái |
|-----------|----------|-------|----------|------------|
| 0. Chuẩn bị | GDD + docs + khung repo + references (đợt này) | PM / SA / DEV / QC / Đồ hoạ | Xong 17/11/2026 | ✅ Xong |
| 0b. Khóa số còn thiếu | Trần chỉ số, ngưỡng An Yên, danh sách 10 nhóm nghề, 6 quyết định kiến trúc, chọn track nhạc | Chủ (chốt) + PM (tổng hợp) | Chờ chủ — không ước tính được | ⏳ Chờ chốt |
| 0c. GitHub | Chọn installation GitHub → tạo repo `pho-xo-bo` public MIT → push khung | Chủ (chọn installation) + DEV (push) | Ngay sau khi chủ chọn xong | ⏳ Chờ chủ |
| 1. Slice (vertical slice) | 1 khu (Xóm Trọ Cũ + Chợ Đầu Mối), 3 nghề (bán rong, shipper, nhân viên quán), chat/trade/thăm nhà, NPC lấp chỗ, server chung, Bụi Đời Chợ Cá bản đầu | DEV + Đồ hoạ + SA | 2–3 tháng từ khi bắt đầu code | Chưa bắt đầu |
| 1b. Art slice | 4 khu + 1 nhân vật + UI điện thoại, theo lock `docs/art-style.md`, chấm rubric ≥12/16 | Đồ hoạ + QC | Song song Giai đoạn 1 | Chưa bắt đầu |
| 2. MVP online | 18 khu, 10 nhóm nghề, công ty=guild, cặp đôi/gia đình, đấu giá, ledger + offline-first | DEV + SA + QC | Sau Slice (chưa ước tính — cần chốt scope 10 nghề trước) | Chưa bắt đầu |
| 3. Mở rộng xã hội | Hội bạn, gia đình, sự kiện Phường theo mùa | PM + DEV | Sau MVP | Chưa bắt đầu |
| 4. Thành phố mới | Thêm thành phố ngoài An Bình | PM + Chủ | Sau Giai đoạn 3 | Chưa bắt đầu |

### Việc còn chờ chủ chốt (tổng hợp)

1. **Gộp hay bỏ khu thừa trong prototype** — bảng web đang 19 khu; repo đã 18. (QC lỗi #1)
2. **Trần tổng chỉ số + ngưỡng An Yên** — hiện là số ví dụ 300 / ±10. (QC lỗi #3)
3. **Danh sách 10 nhóm nghề cho MVP.** (QC lỗi #4)
4. **6 quyết định kiến trúc** trong bản Kiến trúc Đa nền tảng (gồm có dùng Orleans Grain + SignalR hay không).
5. **Chọn installation GitHub** để tạo repo `pho-xo-bo` và push — đang chờ chủ.
6. **Chọn track nhạc / giọng** có bản quyền rõ ràng trước khi sản xuất art có nhạc.
7. **Luật chi tiết Bụi Đời Chợ Cá** — nguồn gốc chỉ có 1 câu teaser, chưa đủ để thiết kế; cần tư liệu Zing Me cũ hoặc người chơi cũ, hoặc chủ chốt luật tự thiết kế (đề xuất hiện tại: đua doanh thu / phục vụ khách theo mùa, không bạo lực).
