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
| Module theo 12 mục | ✅ PASS | `Stats.cs` (Mục 4), `TimeSystem.cs` (Mục 1), `District.cs` + `TitleConflict.cs` (Mục 3), `GameBalance.cs` (Mục 5–9), `PhoneHub.cs` (Mục 2, điện thoại hub), `Jobs.cs` + `Inventory.cs` (Mục 6/7 slice), `Exploration.cs` + `Crafting.cs` (Mục 2, chuẩn Nadia), `Social.cs` (Mục 8), `Economy.cs` (Mục 7), `PlayerProgress.cs` (Mục 9, 5 chương). |
| Comment tiếng Việt | ✅ PASS | Mọi file `.cs` đều comment tiếng Việt. |
| Không hardcode số mâu thuẫn | ✅ PASS (sau sửa) | Số chốt chỉ nằm ở `GameBalance.cs`; các file khác dùng hằng. Kiểm bằng grep: không còn số tiền / ngày / EXP hardcode ngoài `GameBalance.cs` và docs. Kiểm tra tĩnh tự động: `src/server/tests/check_static.py` (53 mục, xem `docs/test-report.md`). |
| Số ví dụ ghi rõ là ví dụ | ⚠️ ĐÃ SỬA | **Lỗi đã phát hiện và sửa trong đợt này:** `Stats.cs` từng ghi trần tổng 300 như đã chốt, trong khi plan chỉ chốt “có trần” — 300 là số ví dụ. Đã gắn cờ PROVISIONAL + cảnh báo QC. Ngưỡng cân bằng An Yên ±10 cũng là số tạm, đã gắn cờ tương tự. |
| Build được | ❌ CHƯA VERIFY | Máy này **không có dotnet / Unity / csc** — không biên dịch được code C#. Ngoặc cân bằng ở 13/13 file (kiểm bằng script tĩnh `check_static.py`), nhưng đó không phải là build. Server đã có `.csproj` + `Program.cs` (18/11, commit 6b79368) nhưng chưa chạy được trên VM này. Client vẫn chưa có Unity project / scene / prefab. Cần build thật trên máy có Unity 2022 LTS + .NET 8 SDK. |
| Không secret / asset lậu | ✅ PASS | Grep toàn repo: không có `.env`, key, token. `assets/` trống. Kiểm tra tĩnh T4/T6 trong `check_static.py` tự động kiểm lại mỗi lần chạy. |

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

### Lỗi còn tồn (QC) — cập nhật 18/11/2026

1. **✅ Prototype artifact đã sửa về 18 khu (18/11)** — bảng web
   `bang-prototype-game-xa-hoi-viet-2-5d` đã gộp Bến Du Thuyền vào Tầng 5,
   builder đếm bằng grep đúng 18 khu và đã chia sẻ lại link. Repo đã đúng
   18 từ trước.
2. **❌ Chưa build được code** — không có dotnet/Unity trên máy này; server
   đã có `.csproj` + `Program.cs` (18/11) nhưng chưa chạy được ở đây; client
   vẫn chưa có Unity project / scene / prefab. Cần build thật trước khi nhận
   “DEV xong”. Kiểm tra tĩnh 53/53 PASS (`docs/test-report.md`) không thay
   thế được build.
3. **⚠️ Trần tổng chỉ số (300) + ngưỡng An Yên (±10) chưa chốt** — đã gắn cờ
   PROVISIONAL, cần chủ chốt số.
4. **⚠️ 10 nhóm nghề** — roadmap GDD nhắc “10 nhóm nghề” ở MVP nhưng chưa có
   danh sách 10 nhóm nào. Cần chủ / PM chốt danh sách.
5. **⚠️ Chưa có art / nhạc nào** — `assets/` trống (đúng trạng thái, nhưng
   slice đầu cần ít nhất 4 khu + 1 nhân vật placeholder CC0).
6. **❌ Chưa có test chạy được** — chỉ có kiểm tra tĩnh
   (`src/server/tests/check_static.py`, 53 mục PASS). Chưa có test xUnit
   cho server, chưa có Unity Test Framework (EditMode/PlayMode) cho client.
7. **❌ Chưa có bản chơi được thật** — chưa có Unity project đầy đủ, scene
   slice, máy build, link WebGL/APK/TestFlight (xem §6).

## 6. Checklist để ra bản test được (thêm 18/11/2026)

Thứ tự làm — mỗi bước xong thì push 1 commit để GitHub thấy tiến độ liên tục
(theo luật chủ 18/11 14:43: không dừng luồng nào, làm song song nhiều luồng).

| # | Việc | Cần gì | Xong khi nào thì tính là xong |
|---|------|--------|------------------------------|
| C1 | Unity project đầy đủ ở `src/client/` | Máy có Unity 2022 LTS; tạo project, `ProjectSettings/ProjectVersion.txt` ghi đúng version | Mở bằng Unity không lỗi, có `Assets/`, `Packages/`, `ProjectSettings/` |
| C2 | Scene slice đầu tiên | C1 + art placeholder CC0 (4 khu slice: Xóm Trọ Cũ, Chợ Đầu Mối, Công Viên An Bình, Phố Đi Bộ) + 1 nhân vật | Mở scene, bấm Play, nhân vật đứng được trên map isometric, điện thoại mở được |
| C3 | Client `.csproj` / solution | C1; Unity tự sinh `.csproj` khi mở project | `dotnet build` (hoặc Unity build) biên dịch được 13 file `.cs` không lỗi |
| C4 | Build server thật | Máy có .NET 8 SDK | `dotnet run` chạy, `curl localhost:PORT/health` trả `{"status":"ok",...}` |
| C5 | Test chạy được (server) | C4 + xUnit | `dotnet test` chạy, ít nhất các test: lãi 0,5%, phí 5%, bỏ bê 7 ngày, +20% EXP, chặn cash-out |
| C6 | Test chạy được (client) | C2 + Unity Test Framework | EditMode test: tính lương `Jobs.PayPerShift`, cân bằng ngoặc đã có; PlayMode test: mở điện thoại, làm 1 ca, mua 1 món |
| C7 | Link test từ code thật | C2–C4 + GitHub Actions (workflow WebGL trong `docs/test-links.md` §2) + Unity license + secret `UNITY_LICENSE` | Có link WebGL chơi được, build từ code trong repo (không phải HTML viết tay) |
| C8 | Art / nhạc slice | Đồ hoạ + track có bản quyền rõ ràng (vai Đồ hoạ §1) | 4 khu + 1 nhân vật + UI điện thoại, rubric 8 chiều ≥12/16 |
| C9 | Chốt số còn thiếu | Chủ chốt: trần chỉ số, ngưỡng An Yên, 10 nhóm nghề, 6 quyết định kiến trúc | Ghi vào GDD + `GameBalance.cs` cùng lúc, chạy lại `check_static.py` PASS |

**Hiện trạng 18/11/2026 ~21:50:** Follow-up C2 XONG — spec art chi tiết khu
17/18 nay đã có trong `docs/art-assets.md` (§3/§4: verbatim, bố cục, prop,
NPC Ông Ba / Anh Hải khớp `GuideHint`, hotspot khớp `Exploration.cs`,
shot list ≤ 8/khu); kiểm tra tĩnh 167/167 PASS (nhóm T13 mới, 11 mục).
C2 vẫn chưa xong (chưa mở bằng Unity, chưa có art, chưa bấm Play được);
C3–C9 vẫn chưa xong. Việc follow-up C2 tiếp theo: art pass vẽ 4 khu theo
spec (C8) — cần đồ hoạ + track nhạc chốt, chưa có.

**Hiện trạng 19/11/2026 ~09:45 — MAP004 + ĐỒ THỊ MAP 1-2-3-4 ĐÃ NỐI, 268/268 PASS:** Map004 Bến Xe Miền Đông đã có tile data thật (648/108/28, tái dùng atlas-map002.png, đường nhựa dọc x=5, NPC Bác Tài + Anh Bốc Vác, transfer về Map003) + `PXB_Isometric.js` đăng ký map 4; Map003 nay có cửa (5,8) đi Map004 — đồ thị map 1-2-3-4 đã nối được. Kiểm tra tĩnh 268/268 PASS (nhóm T28 mới, 5 mục; T26d cập nhật). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map005–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map005 (Làng Đại Học) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~11:50 — MAP007 + ĐỒ THỊ MAP 1-2-3-4-5-6-7 ĐÃ NỐI, 283/283 PASS:** Map007 Phố Văn Phòng Nhỏ đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Nhân Viên Văn Phòng + Thực Tập Sinh, transfer về Map006) + `PXB_Isometric.js` đăng ký map 7; Map006 nay có cửa (5,8) đi Map007 — đồ thị map 1-2-3-4-5-6-7 đã nối được. Kiểm tra tĩnh 283/283 PASS (nhóm T31 mới, 5 mục; smoke `/tmp/pxb-map007-smoke.js` 22/22 PASS, không commit). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map008–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map008 (Khu Chung Cư Cao Cấp) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~13:45 — MAP009 + ĐỒ THỊ MAP 1-2-3-4-5-6-7-8-9 ĐÃ NỐI, 293/293 PASS:** Map009 Phố Thương Mại đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Chủ Cửa Hàng + Người Bán Hàng, transfer về Map008) + `PXB_Isometric.js` đăng ký map 9; Map008 nay có cửa (5,8) đi Map009 — đồ thị map 1-2-3-4-5-6-7-8-9 đã nối được. Kiểm tra tĩnh 293/293 PASS (nhóm T33 mới, 5 mục; smoke `/tmp/pxb-map009-smoke.js` 23/23 PASS, không commit). PROVISIONAL: code 3/4/5 nhà trọ dùng tạm làm khối cửa hàng, chờ art pass vẽ tile cửa hàng riêng. CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map010–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map010 (Khu Công Nghệ) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~16:50 — MAP012 + ĐỒ THỊ MAP 1-2-3-4-5-6-7-8-9-10-11-12 ĐÃ NỐI, 308/308 PASS:** Map012 Khu Biệt Thự Ven Sông đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Bảo Vệ Biệt Thự + Người Làm Vườn, transfer về Map011) + `PXB_Isometric.js` đăng ký map 12; Map011 nay có cửa (5,8) đi Map012 — đồ thị map 1-2-3-4-5-6-7-8-9-10-11-12 đã nối được. Kiểm tra tĩnh 308/308 PASS (nhóm T36 mới, 5 mục; smoke `/tmp/pxb-map012-smoke.js` 26/26 PASS, không commit). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map013–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map013 (Quận Tài Chính) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~17:45 — MAP013 + ĐỒ THỊ MAP 1-2-3-4-5-6-7-8-9-10-11-12-13 ĐÃ NỐI, 313/313 PASS:** Map013 Quận Tài Chính đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Nhân Viên Ngân Hàng + Môi Giới Chứng Khoán, transfer về Map012) + `PXB_Isometric.js` đăng ký map 13; Map012 nay có cửa (5,8) đi Map013 — đồ thị map 1-2-3-4-5-6-7-8-9-10-11-12-13 đã nối được. Kiểm tra tĩnh 313/313 PASS (nhóm T37 mới, 5 mục; smoke `/tmp/pxb-map013-smoke.js` 27/27 PASS, không commit). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map014–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map014 (Đảo Thượng Lưu) + scene trận MarketBattle sau khi chủ duyệt luật. Godot G1 (slice parity Map001–002) vẫn chờ làm — đường MV giữ song song tới khi Godot đạt parity.

**Hiện trạng 19/11/2026 ~15:50 — MAP011 + ĐỒ THỊ MAP 1-2-3-4-5-6-7-8-9-10-11 ĐÃ NỐI, 303/303 PASS:** Map011 Phố Tây đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Nhân Viên Lễ Tân + Hướng Dẫn Viên, transfer về Map010) + `PXB_Isometric.js` đăng ký map 11; Map010 nay có cửa (5,8) đi Map011 — đồ thị map 1-2-3-4-5-6-7-8-9-10-11 đã nối được. Kiểm tra tĩnh 303/303 PASS (nhóm T35 mới, 5 mục; smoke `/tmp/pxb-map011-smoke.js` 26/26 PASS, không commit). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map012–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map012 (Khu Biệt Thự Ven Sông) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~14:45 — MAP010 + ĐỒ THỊ MAP 1-2-3-4-5-6-7-8-9-10 ĐÃ NỐI, 298/298 PASS:** Map010 Khu Công Nghệ đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Lập Trình Viên + Kỹ Sư Phần Mềm, transfer về Map009) + `PXB_Isometric.js` đăng ký map 10; Map009 nay có cửa (5,8) đi Map010 — đồ thị map 1-2-3-4-5-6-7-8-9-10 đã nối được. Kiểm tra tĩnh 298/298 PASS (nhóm T34 mới, 5 mục; smoke `/tmp/pxb-map010-smoke.js` 29/29 PASS, không commit). PROVISIONAL: code 3/4/5 nhà trọ dùng tạm làm khối công nghệ, chờ art pass vẽ tile công nghệ riêng. CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map011–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map011 (Phố Tây) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~10:50 — MAP006 + ĐỒ THỊ MAP 1-2-3-4-5-6 ĐÃ NỐI, 278/278 PASS:** Map006 Chung Cư Cũ đã có tile data thật (648/108/28, tái dùng atlas-map001.png, không đường nhựa, NPC Cư Dân Chung Cư + Bác Quản Lý, transfer về Map005) + `PXB_Isometric.js` đăng ký map 6; Map005 nay có cửa (5,8) đi Map006 — đồ thị map 1-2-3-4-5-6 đã nối được. Kiểm tra tĩnh 278/278 PASS (nhóm T30 mới, 5 mục). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map007–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map007 (Phố Văn Phòng Nhỏ) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~10:45 — MAP005 + ĐỒ THỊ MAP 1-2-3-4-5 ĐÃ NỐI, 273/273 PASS:** Map005 Làng Đại Học đã có tile data thật (648/108/28, tái dùng atlas-map001.png, SHA khớp §7, NPC Thầy Giáo + Sinh Viên Làm Thêm, transfer về Map004; lời thoại chỉ từ districts.md khu 5 + GDD Mục 5, 5 bậc học đã chốt) + `PXB_Isometric.js` đăng ký map 5; Map004 nay có cửa (5,8) đi Map005 — đồ thị map 1-2-3-4-5 đã nối được. Kiểm tra tĩnh 273/273 PASS (nhóm T29 mới, 5 mục); smoke stub `/tmp/pxb-map005-smoke.js` 24/24 PASS (không commit). PROVISIONAL: code 3/4/5 nhà trọ dùng tạm làm giảng đường / ký túc xá, chờ art pass vẽ tile trường riêng. CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map006–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map006 (Chung Cư Cũ) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~09:05 — MAP003 + PXB_MARKETBATTLE XONG, 263/263 PASS:** Map003 Khu Công Nhân đã có tile data thật (648/108/28, tái dùng atlas-map001.png, transfer về Map002, không hotspot mới) + `PXB_Isometric.js` tôn trọng `mapping.atlasPng`; `PXB_MarketBattle.js` (1.109 dòng, smoke 80/80 PASS) + `docs/market-battle-design.md` (luật chi tiết PROVISIONAL, CHƯA CHỐT — chờ chủ duyệt); `plugins.js` nay 17 plugin. Kiểm tra tĩnh 263/263 PASS (nhóm T26/T27 mới, 10 mục; `node --check` 19/19 file JS). CHƯA chơi được thật: chờ chủ bật GitHub Pages → kiểm chứng Map001; scene trận MarketBattle chưa có; Map004–018 chưa có. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map004 (Bến Xe Miền Đông) + scene trận MarketBattle sau khi chủ duyệt luật.

**Hiện trạng 19/11/2026 ~08:00 — PXB_ISOMETRIC V3.1 (ATLAS FALLBACK) XONG + ĐỢT LINK-CHƠI-THẬT ĐÃ PUSH:** `PXB_Isometric.js` v3.1: atlas PNG lỗi (404) → `Bitmap.isError()` → tắt atlas mode, vẽ lại 1 lần bằng fallback v2 (đếm `stats.atlasFallback`); bitmap đang load vẫn giữ atlas mode. Smoke stub 18/18 PASS. Kiểm tra tĩnh 253/253 PASS (nhóm T25 mới, 5 mục; `node --check` 18/18 file JS). Đợt link-chơi-thật (9 data JSON + `pxb-embedded.js` + `.nojekyll` + `docs/link-choi-that.md`) ĐÃ lên GitHub ở commit 4b277edb998b — chỉ còn chờ chủ bật GitHub Pages để có link chơi. CHƯA chơi được thật: browser task mở Map001 đã trả về BỊ CHẶN — trình duyệt (VM riêng) từ chối loopback (`invalid_request`); tunnel Cloudflare thử 2 lần đều lỗi TLS do egress proxy trả 403 cho api.trycloudflare.com; chờ chủ bật GitHub Pages rồi kiểm chứng lại bằng link Pages. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: chủ bật Pages → kiểm chứng Map001, rồi PXB_MarketBattle (luật chưa chốt) + Map003–018.

**Hiện trạng 19/11/2026 ~06:55 — PXB_ISOMETRIC V3 (ATLAS MODE) XONG + ATLAS PNG ĐÃ VÀO REPO:** `PXB_Isometric.js` v3 (691 dòng, smoke stub 55/55 PASS): registry atlas + load bitmap qua ImageManager + load mapping JSON qua XHR + vẽ sprite từ atlas (frame/tint/neo đáy đúng mapping.layer; code 3 là tường ở Map001 nhưng là đường nhựa ở Map002 — phân lớp theo mapping, không theo layer data MV); fallback v2 giữ nguyên. Atlas PNG map001/map002 đã vào `src/nadia/www/img/tilesets/` (512×64, SHA khớp tileset-plan.md §7); tile data khớp hoàn toàn mapping. Sửa 1 lỗi script: `check_static.py` crash UnicodeDecodeError ở T14ab khi gặp PNG — nay loại file nhị phân khỏi quét text, khóa PNG riêng ở T24. Kiểm tra tĩnh 248/248 PASS (nhóm T24 mới, 5 mục; `node --check` 18/18 file JS). CHƯA chơi được thật: chưa chạy game MV trên trình duyệt để thấy map Xóm Trọ Cũ; nếu thiếu PNG thì sprite atlas vẽ trắng, không tự fallback. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: chạy thử game MV thật trên trình duyệt (mở Map001), rồi PXB_MarketBattle (luật chưa chốt) + Map003–018.

**Hiện trạng 19/11/2026 ~06:30 — TILESET CC0 ĐÃ VỀ + 3 PLUGIN MỚI (TOOLS + ONLINE + SAVECLOUD), 16/16 PLUGIN:** 6 pack CC0 đã tải thật về máy làm việc (5 Kenney + SBS nhỏ, SHA-256 trong tileset-plan.md §7; tile Kenney đo thật 132×~99, SBS là 10 sheet nền đen); 2 atlas theo khu đã đóng (map001 5 tile + map002 6 tile, script tools/tiles/build_atlas.py, mapping JSON đã push, atlas PNG chỉ ở máy làm việc — đưa vào repo bằng git push/upload web); tile data Map001–002 nay thật (layer 0 108/108, layer 1 28/108, scheme atlas-code). `plugins.js` nay 16 plugin: + PXB_Tools.js (977 dòng, 4 công cụ × 3 bậc đổi hành vi thật, 12 câu đúng nguyên văn Crafting.cs, smoke 140/140 PASS; chi phí nâng cấp PROVISIONAL) + PXB_Online.js (623 dòng, health/số dư/tặng tiền qua endpoint .NET thật, IdempotencyKey + outbox; trade/đấu giá/guild trả server-chua-co-endpoint) + PXB_SaveCloud.js (512 dòng, tài khoản tùy chọn + localStorage + LZString; server chưa có endpoint save); smoke Online+SaveCloud 68/68 PASS. Kiểm tra tĩnh 243/243 PASS (nhóm T21/T22/T23 mới, 15 mục; `node --check` 18/18 file JS — đã sửa T14v thiếu Titles/Story). CHƯA chơi được: cần PXB_Isometric v3 (atlas mode) mới vẽ được tile data; atlas PNG chưa vào repo; MarketBattle (luật chưa chốt) + Map003–018 còn lại. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: PXB_Isometric v3 atlas mode, rồi đưa atlas PNG vào repo + art pass chấm rubric.

**Hiện trạng 19/11/2026 ~04:50 — 2 PLUGIN SLICE MỚI (TITLES + STORY), PHASE 1 ĐỦ 13/13:** `PXB_Titles.js` (415 dòng, port TitleConflict.cs / GDD Mục 3, smoke 68/68 PASS) + `PXB_Story.js` (454 dòng, port PlayerProgress.cs / GDD Mục 9, smoke 109/109 PASS), làm song song 2 luồng; `plugins.js` nay 13 plugin. Kiểm tra tĩnh 228/228 PASS (nhóm T20 mới, 5 mục; `node --check` 15/15 file JS nadia; 2 check cũ T18c/T19b nới `== 11` → `>= 11`). Lệch mới: GDD Mục 3 không nhắc tên quest "Cải tà quy chính", không liệt kê phe từng danh hiệu (PROVISIONAL, suy từ bảng chặn), không có "danh hiệu chính"/"yêu cầu chỉ số" trong C#; chương 2/5 GDD ghi thêm điều kiện bằng cấp/rank mà C# không kiểm (thực tế trùng qua Trí/Danh vọng). CHƯA chơi được: tile data toàn 0, chưa có tileset CC0. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: tải tile Kenney/SBS + đóng atlas theo tileset-plan.md §4, rồi tile data thật cho Map001–002 (Phase 2: MarketBattle/Online/SaveCloud còn lại, luật MarketBattle chưa chốt).

**Hiện trạng 19/11/2026 ~03:55 — PLUGIN SLICE MỚI (SOCIAL) + KẾ HOẠCH TILESET:** `PXB_Social.js` (585 dòng, port Social.cs / GDD Mục 8, smoke 85/85 PASS) + `docs/tileset-plan.md` (Kenney CC0 ưu tiên 1, SBS Floor Tiles ưu tiên 2, kết luận không ép tile iso vào tileset MV — dùng atlas theo khu; PNG nhị phân không push được qua snapshot, đưa vào bằng git push/upload web); `plugins.js` nay 11 plugin. Kiểm tra tĩnh 223/223 PASS (nhóm T19 mới, 4 mục; `node --check` 13/13 file JS nadia). CHƯA chơi được: tile data toàn 0, chưa có tileset CC0, plugin Titles/Story chưa viết. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: PXB_Titles.js + PXB_Story.js, rồi tải tile Kenney/SBS + đóng atlas theo tileset-plan.md §4.

**Hiện trạng 19/11/2026 ~02:55 — 2 PLUGIN SLICE MỚI (EDUCATION + ECONOMY):** `PXB_Education.js` (589 dòng, port GDD Mục 5 / GameBalance.Degrees, smoke 89/89 PASS) + `PXB_Economy.js` (577 dòng, port Economy.cs, smoke 78/78 PASS); `plugins.js` nay 10 plugin (…PhoneHub → Education → Economy). Kiểm tra tĩnh 219/219 PASS (nhóm T18 mới, 4 mục; `node --check` 12/12 file JS nadia). 3 check cũ T14t/T16d/T17c bắt đúng 8 plugin đã sửa thành ≥ 8 (chỉ khóa 8 gốc + thứ tự). CHƯA chơi được: tile data toàn 0, chưa có tileset CC0, plugin Social/Titles/Story chưa viết. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: PXB_Social.js, rồi tileset CC0 + tile data thật cho Map001–002.

**Hiện trạng 19/11/2026 ~01:50 — 2 PLUGIN SLICE MỚI (CRAFTING + PHONEHUB):** `PXB_Crafting.js` (537 dòng, port Crafting.cs, smoke 52/52 PASS) + `PXB_PhoneHub.js` (381 dòng, port PhoneHub.cs, smoke 56/56 PASS); `plugins.js` nay 8 plugin (…Hotspot → Crafting → Jobs → PhoneHub). Kiểm tra tĩnh 215/215 PASS (nhóm T17 mới, 4 mục; `node --check` 10/10 file JS nadia). Bug guard `_installed` của PhoneHub đã sửa. Lệch ghi nhận: GDD không có số chế tạo (PROVISIONAL theo C#); chỉ có công thức bậc 1; `item:qua-tang` chưa có trong Items.json; cơ chế "đã học" mặc định chưa học — New Game/PXB_Story phải gọi `learnRecipe`; Notify đếm cả khi đóng giữ đúng C#. CHƯA chơi được: tile data toàn 0, chưa có tileset CC0, plugin Education/Economy/Social/Titles/Story chưa viết. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: PXB_Education.js + PXB_Economy.js, rồi tileset CC0 + tile data thật cho Map001–002.

**Hiện trạng 19/11/2026 ~00:50 — ISOMETRIC V2 ĐÃ MÓC TILEMAP + 2 PLUGIN SLICE:** `PXB_Isometric.js` v2 (456 dòng): `PXB_IsoTilemap` kế thừa `Tilemap`, vẽ tile thường thành thoi 64×32 (quay 45° + co), `screenX/screenY` chiếu isometric, `createTilemap` alias, cuộn map pan theo origin; smoke test stub core MV 36/36 PASS; `install()` false khi không có core. `PXB_Hotspot.js` (484 dòng, port Exploration.cs, smoke 26/26 PASS) + `PXB_Jobs.js` (548 dòng, port Jobs.cs, smoke 40/40 PASS); `plugins.js` nay 6 plugin. Kiểm tra tĩnh 211/211 PASS (nhóm T16 mới, 5 mục). CHƯA chơi được: tile data toàn 0, chưa có tileset CC0, autotile/bóng/mép bàn chưa vẽ, plugin PhoneHub/Crafting/Education/Economy/Social/Titles/Story chưa viết. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: PXB_Crafting.js + PXB_PhoneHub.js, rồi tileset CC0 + tile data thật cho Map001–002 để mở trình duyệt thấy map Xóm Trọ Cũ.

**Hiện trạng 19/11/2026 ~00:05 — CORE MV ĐÃ VỀ + 2 PLUGIN SLICE:** core MV
v1.6.1 (MIT) đủ 12 file trong `src/nadia/www/js/` (tổng 2.341.224 byte,
`node --check` 12/12 PASS; nguồn tag community 1.3b — repo không có tag
v1.6.1); `PXB_Stats.js` + `PXB_Time.js` đã viết (port Stats.cs/TimeSystem.cs,
smoke test logic thuần PASS); `plugins.js` nay 4 plugin. Kiểm tra tĩnh
206/206 PASS (nhóm T15 mới, 8 mục). CHƯA chơi được: `PXB_Isometric` chưa
móc Tilemap (việc tiếp theo lớn nhất, nay core đã có), tile data toàn 0,
img/audio trống. Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án
dự phòng); đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`.

**Hiện trạng 18/11/2026 ~22:45 — ĐỔI HƯỚNG SANG NADIA (chủ cho phép 22:30,
`docs/architecture-nadia.md`):** Giai đoạn 1 khung file XONG — `src/nadia/www/`
đã có index.html (thứ tự load §1.2) + plugins.js + main.js + `PXB_Balance.js`
(port đúng GameBalance/Jobs/Crafting/Stats) + `PXB_Isometric.js` bản đầu
(chiếu 64×32, sort x+y, viewport 720×1280, chưa móc Tilemap) + data tối thiểu
(System, MapInfos đủ 18 khu, Map001–002, Actors, Classes, Items 13 món) +
package.json NW.js + README. Kiểm tra tĩnh 198/198 PASS (nhóm T14 mới,
31 mục); `node --check` 4/4 file JS OK. CHƯA chơi được: core MV
(`js/rpg_*.js` + pixi libs) chưa tải về, `PXB_Isometric.install()` trả false,
tile data toàn 0, img/audio trống. Việc tiếp theo: tải core MV v1.6.1 (MIT)
về js/ + móc Tilemap isometric — rồi mới mở trình duyệt thấy map Xóm Trọ Cũ.
Phát hiện khi port: slice web `src/web/data/*.js` lệch khỏi code C# ở 3 chỗ
(nghề, công thức, hotspot hs-cho-dem/hs-hem-sang) — nadia lấy theo C#,
chi tiết trong `src/nadia/README.md`; web chưa sửa (để GDD/PM xem lại).
Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng); đường
chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`.

**Hiện trạng 18/11/2026 ~20:50:** C2 tiến thêm 1 bước — 4/4 scene slice đầu
nay đã có khung file (thêm `SliceCongVienAnBinh.unity` khu 17, hotspot
`hs-cong-vien` + `SlicePhoDiBoChoDem.unity` khu 18, hotspot `hs-cho-dem`;
mỗi scene có GameManager + Player + CameraFollowBehaviour + camera ortho +
mô tả verbatim `art-style.md` §4); kiểm tra tĩnh 156/156 PASS (nhóm T12 mới,
27 mục, xem `docs/test-report.md`). C2 vẫn chưa xong (chưa mở bằng Unity,
chưa có art, chưa bấm Play được); C3–C9 vẫn chưa xong. Việc follow-up C2:
spec art chi tiết khu 17/18 chưa có trong `docs/art-assets.md` (chỉ có khu 1–2).

**Hiện trạng 18/11/2026 ~19:50:** C1 xong ở mức khung file (10 file
`ProjectSettings/*.asset` + scene `SliceXomTroCu.unity`; chưa verify mở bằng
Unity — cần máy có Unity 2022.3.62f1 sinh `Library/` + `.csproj` và kiểm tra
Play lần đầu). C2–C9 vẫn chưa xong (chưa chạy được).
Đã xong phần chuẩn bị cho C5/C6: kiểm tra tĩnh 129/129 PASS
(`docs/test-report.md`), `Social.cs` + `Economy.cs` đã viết theo đúng số
chốt để test chạy được sau này có cái mà test, test xUnit server
(`EconomyLedgerTests.cs`, 17 test, chưa chạy — cần .NET 8 SDK) +
`Program.cs` đã nối `EconomyLedger` singleton với 2 endpoint
`/ledger/balance` + `/ledger/gift`, test EditMode Unity (`JobsPayTests.cs`
28 test + `TimeSystemTests.cs` 10 test + `SocialTests.cs` 22 test +
`EconomyTests.cs` 22 test + `InventoryTests.cs` 19 test +
`CraftingTests.cs` 18 test + `ExplorationTests.cs` 19 test +
`PlayerProgressTests.cs` 30 test + `DistrictTests.cs` 33 test +
`PhoneHubTests.cs` 18 test = **219 test**, chưa chạy — cần Unity 2022 LTS) +
`PhoXoBo.asmdef`. Đã sửa trong đợt 17:00: `Stats.WithValues` cho phép khởi
tạo Stats tùy ý nên hệ số lương mốc 50/0 nay test được (28 test Jobs, đã
ghi trong `docs/test-report.md`); `TimeSystem` không wrap quá 30 phút vẫn
chưa có chốt GDD — giữ nguyên, không coi là bug. **Đợt 17:50: sửa bug thật
`Social.Divorce` (điều kiện `&&` → `||`, phải vừa Spouse vừa Cuoi mới ly
hôn được) + 2 test hồi quy; nhóm kiểm tra tĩnh T9 mới (17 mục) quét file
test EditMode; ghi nhận quirk `Buy("phong-tro")` tính tiền thuê vào
TotalAssetsVnd để GDD xem lại sau.** **Đợt 19:50: sửa 4 bug ghi nhận ở đợt 18:50 + 12 test hồi quy (tổng EditMode
219 test; kiểm tra tĩnh 129/129 PASS, nhóm T11 mới):** `Inventory.Add` đồ
không stackable nay all-or-nothing (`Add("ao-mua", 2)` trả false, không thêm
lẻ); `Inventory.Use` áp buff đúng khung catalog; `Crafting.Craft` xóa key
nguyên liệu về 0; `Exploration.Explore` tự reset khi đổi ngày (field
`_currentDay`, null = chưa khám phá lần nào thì chỉ ghi nhận ngày, không
reset); `TitleConflict.IsBlocked` chặn cả hai chiều + không phân biệt
hoa/thường. Còn lại chưa sửa (để GDD/PM xem lại — quyết định thiết kế):
`PhoneHub.Notify` đếm cả khi đóng, `SuggestEnding` ưu tiên cứng,
`Buy("phong-tro")` tính tiền thuê vào tài sản, `AdvanceStage` không kiểm
tra Kind.

## 5. Vai PM — Roadmap, owner, việc chờ chốt

Owner = vai chịu trách nhiệm (chưa phải tên người).

### Roadmap Slice → MVP

| Giai đoạn | Nội dung | Owner | Ước tính | Trạng thái |
|-----------|----------|-------|----------|------------|
| 0. Chuẩn bị | GDD + docs + khung repo + references (đợt này) | PM / SA / DEV / QC / Đồ hoạ | Xong 17/11/2026 | ✅ Xong |
| 0b. Khóa số còn thiếu | Trần chỉ số, ngưỡng An Yên, danh sách 10 nhóm nghề, 6 quyết định kiến trúc, chọn track nhạc | Chủ (chốt) + PM (tổng hợp) | Chờ chủ — không ước tính được | ⏳ Chờ chốt |
| 0c. GitHub | Repo `tinnt120899/pho-xo-bo` (private) đã có, đã push nhiều commit (42c68e14 → 4fd0feb1 → 13761c8f) | Chủ (tạo repo) + DEV (push) | ✅ Xong — push tiếp sau mỗi phần việc |
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
5. ~~Chọn installation GitHub~~ — ✅ Xong 18/11: repo private đã có, đã push
   nhiều commit. Việc còn lại: push sau mỗi phần việc xong (luật chủ 18/11 14:43).
6. **Chọn track nhạc / giọng** có bản quyền rõ ràng trước khi sản xuất art có nhạc.
7. **Luật chi tiết Bụi Đời Chợ Cá** — nguồn gốc chỉ có 1 câu teaser, chưa đủ để thiết kế; cần tư liệu Zing Me cũ hoặc người chơi cũ, hoặc chủ chốt luật tự thiết kế (đề xuất hiện tại: đua doanh thu / phục vụ khách theo mùa, không bạo lực).
