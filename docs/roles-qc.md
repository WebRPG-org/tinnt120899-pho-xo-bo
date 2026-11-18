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
