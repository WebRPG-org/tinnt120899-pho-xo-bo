# Báo cáo kiểm tra — Phố Xô Bồ

> **Đây là kiểm tra TĨNH, chưa phải build / test chạy được.**
> VM này không có dotnet / Unity / csc nên không biên dịch được code C#,
> không chạy được server, không chơi được game. Báo cáo này chỉ chứng minh:
> ngoặc cân bằng, số chốt khớp nhau giữa code và docs, không có secret,
> ranh giới pháp lý bị chặn trong code. Muốn test chạy được thật phải có
> máy build (xem `docs/roles-qc.md` §6).

## Lần chạy mới nhất: 18/11/2026 ~22:45 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **198/198 PASS, exit 0** — tăng từ 167/167: nhóm T14 mới (31 mục)
  khóa khung Nadia Giai đoạn 1.
- **ĐỔI HƯỚNG SANG NADIA (chủ cho phép 18/11 22:30, `docs/architecture-nadia.md`):**
  `src/nadia/www/` khung file xong — `index.html` (thứ tự load §1.2) +
  `plugins.js` (PXB_Balance trước PXB_Isometric, cả 2 bật) + `main.js` +
  `PXB_Balance.js` (port đúng GameBalance.cs: 5 bậc học, lãi 0,5%, phí 5%,
  thang nhà, rank; Jobs.cs: 3 nghề Thể/Chiều/150k, Thể/Tối/180k,
  Tâm/Sáng/150k, quota 14, khung tốt +25%; Crafting.cs: xe-đẩy 1/2/2,
  đèn-soi 2/2, quà-tặng 2/1; Stats.cs PROVISIONAL: trần 300, StatMax 100,
  An Yên ±10) + `PXB_Isometric.js` bản đầu (chiếu (x−y)×tileW/2,
  (x+y)×tileH/2, tile 64×32, sort x+y, viewport 720×1280, `install()` trả
  false khi chưa có core — không giả vờ render được) + data tối thiểu:
  System.json (tiền "đồng", map bắt đầu 1), MapInfos.json đủ 18 khu
  (Bến Du Thuyền trong khu 16), Map001.json/Map002.json (lưới 12×9,
  data 648, event đúng Exploration.cs + Actors.js: hotspot hs-tro-toi /
  hs-cho-sang / hs-cho-chieu, NPC cô Tư/bạn thân/chị Lệ/anh Hải đúng tọa độ,
  transfer 2 chiều (5,4), Góc Chế Tạo (2,2)/(7,5)), Actors.json (1 nhân vật
  "Bạn" — tên PROVISIONAL), Classes.json, Items.json (13 món, giá khớp
  Items.js) + package.json NW.js + README. `node --check` 4/4 file JS OK
  (node v24 có sẵn trên VM).
- **Phát hiện khi port — slice web lệch khỏi code C# ở 3 chỗ (nadia lấy
  theo C#, chưa sửa web):** (1) nghề: web ghi bán rong Tâm/100k/Sáng, C#
  ghi Thể/150k/Chiều; shipper web 150k vs C# 180k; nhân viên quán web
  100k/Chiều vs C# 150k/Sáng; (2) công thức: web xe-đẩy 1/1/1, đèn-soi 2/1;
  C# xe-đẩy 1/2/2, đèn-soi 2/2 — bộ vật liệu khởi đầu 1/1/1 của web không đủ
  chế xe-đẩy theo C#; (3) hotspot: web đặt hs-cho-dem ở map 2 (sắt-vụn ×1,
  cần đèn-soi) + thêm hs-hem-sang ở map 1; C# đặt hs-cho-dem ở map 18
  (vải-vụn ×2) và không có hs-hem-sang. Chi tiết trong `src/nadia/README.md`
  — để GDD/PM xem lại.
- **Còn lại chưa xong (Giai đoạn 1):** core MV (`js/rpg_*.js` +
  `js/libs/pixi.js`…) chưa tải về (lấy từ rpgtkoolmv/corescript v1.6.1,
  MIT); `PXB_Isometric` chưa móc Tilemap; tile data toàn 0 (chưa có tileset
  CC0); img/audio trống; plugin còn lại (PXB_Stats/Time/Hotspot/Crafting/
  Jobs/PhoneHub…) chưa viết. Mở trình duyệt lúc này lỗi 404 ở core —
  trạng thái thật, không giấu.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào. Ghi chú mới: dotnet 8.0.428 CÓ ở `~/.dotnet`
  (không trong PATH) — `dotnet test` vẫn kẹt RAM theo ghi nhận cũ, chạy qua
  GitHub Actions; Unity vẫn chưa có.

## Lần chạy mới nhất: 18/11/2026 ~21:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **167/167 PASS, exit 0** — tăng từ 156/156: nhóm T13 mới (11 mục)
  khóa spec art khu 17/18.
- **Follow-up C2 (roles-qc.md §6): spec art chi tiết khu 17/18 đã có trong
  `docs/art-assets.md` (§3 Công Viên An Bình, §4 Phố Đi Bộ – Chợ Đêm):**
  mô tả verbatim nguyên văn `art-style.md` §4; bố cục isometric + điểm neo;
  bảng prop; NPC dẫn đường khớp đúng `Exploration.cs` `GuideHint` (khu 17
  Ông Ba, khu 18 Anh Hải — cùng người với anh Hải ở khu 2, đã ghi rõ không
  vẽ thành 2 người); hotspot khớp đúng code (`hs-cong-vien` Ván gỗ ×1 khung
  Chiều, `hs-cho-dem` Vải vụn ×2 khung Tối); bảng Sáng/Chiều/Tối + mưa/nắng/
  Tết; shot list ≤ 8 shot mỗi khu (PROVISIONAL). Tiêu đề file đổi thành
  "4 khu slice đầu", các mục cũ đánh lại số (§3–§6 cũ thành §5–§8). Header
  2 scene mới nay trỏ thẳng tới đúng mục spec (§3/§4), không còn ghi "chưa
  có mục riêng". Không bịa số mới: mọi vật liệu / khung / NPC đều lấy từ
  `Exploration.cs` + `docs/districts.md` (khu chung luôn mở, khu 18 có sự
  kiện 20:00 thứ 7 + Bụi Đời Chợ Cá).
- **Còn lại chưa xong (C2):** 4/4 scene slice vẫn chỉ là khung file (chưa mở
  bằng Unity, chưa có art, chưa bấm Play được); C3–C9 vẫn chưa xong.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được.

## Lần chạy mới nhất: 18/11/2026 ~20:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **156/156 PASS, exit 0** — tăng từ 129/129: nhóm T12 mới (27 mục)
  khóa 4 scene slice.
- **Luồng song song — 2 scene slice còn lại (C2):**
  `SliceCongVienAnBinh.unity` (khu 17, hotspot `hs-cong-vien` “Ghế đá công
  viên”, khung Chiều, Ván gỗ ×1) + `SlicePhoDiBoChoDem.unity` (khu 18,
  hotspot `hs-cho-dem` “Sạp đêm cuối phố”, khung Tối, Vải vụn ×2) — mỗi scene
  có GameManager + Player + CameraFollowBehaviour + camera ortho + mô tả
  verbatim `docs/art-style.md` §4; `.meta` guid mới, duy nhất; không bịa
  hotspot / prop / màu mới. **Sửa lỗi header cũ:** `SliceChoDauMoi.unity`
  từng ghi nhầm “Xom Tro Cu (khu 1/18” — đã sửa thành khu 2; 2 scene cũ đã
  cập nhật dòng “doi scene khu rieng (chua tao)” → trỏ tới 2 scene mới.
  1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS): T12f lúc đầu FAIL
  giả — chuỗi kiểm tra không dấu trong khi header scene mới ghi đúng mô tả
  verbatim có dấu của `art-style.md` §4.
- **Còn lại chưa xong (C2):** spec art chi tiết khu 17/18 chưa có trong
  `docs/art-assets.md` (hiện chỉ có khu 1–2) — việc follow-up; xử lý sáng
  chiều / tối là việc của art pass sau, khung scene giữ nguyên màu nền đã
  khóa #F9EDCE.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được (4/4 scene slice mới chỉ là khung file).

## Lần chạy mới nhất: 18/11/2026 ~19:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **129/129 PASS, exit 0** — tăng từ 119/119: nhóm T11 mới (10 mục)
  khóa 4 bug đã sửa trong đợt này + tổng EditMode 219 test.
- **Luồng song song — sửa 4 bug đã ghi nhận ở đợt 18:50 (code thật + test hồi quy):**
  1. `Inventory.Add` đồ không stackable: `Add("ao-mua", 2)` lúc túi trống nay
     trả false, không thêm gì (all-or-nothing — nhất quán với hành vi khi túi
     đã có món đó; muốn 1 cái thì gọi lại quantity = 1).
  2. `Inventory.Use`: bỏ `def.Effect with { Frame = currentFrame }` — buff áp
     đúng khung ghi trong catalog (cơm tấm dùng lúc Tối vẫn buff vào Chiều).
  3. `Crafting.Craft`: nguyên liệu về 0 thì `materials.Remove(materialId)` —
     không để lại key = 0 trong Dictionary.
  4. `Exploration.Explore`: tự gọi `NewGameDay(visitedToday)` khi `gameDay`
     khác ngày đã lưu (`_currentDay`, null = chưa khám phá lần nào trong phiên
     thì chỉ ghi nhận ngày, không reset — tránh xóa lượt đã lưu trong save).
  5. `TitleConflict.IsBlocked`: chặn cả hai chiều (tra thẳng
     `BlockedBy[wanted]`, không cần bảng ngược riêng) + so sánh
     `OrdinalIgnoreCase` (dictionary + `string.Equals`); thêm guard null.
  - Test hồi quy mới: Inventory +4 (19), Crafting +2 (18), Exploration +3
    (19), District +4 (33) = **+12 test, tổng EditMode nay 219 test**
    (Jobs 28 + TimeSystem 10 + Social 22 + Economy 22 + Inventory 19 +
    Crafting 18 + Exploration 19 + PlayerProgress 30 + District 33 +
    PhoneHub 18) — vẫn **chưa chạy được** (VM không có Unity; cần Unity
    2022.3.62f1 + Unity Test Runner). 1 lỗi script trong lần chạy này (đã sửa,
    chạy lại PASS): T11b lúc đầu FAIL giả — chuỗi `with { Frame = currentFrame }`
    vẫn còn trong comment nhắc bug cũ; đã sửa chỉ xét code sau khi strip comment.
- **Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại, là quyết định thiết kế
  chứ không phải bug rõ):** `PhoneHub.Notify` đếm cả khi điện thoại đóng
  (thông báo đến khi đóng máy là hành vi bình thường của điện thoại);
  `PlayerProgress.SuggestEnding` thứ tự ưu tiên cứng SieuGiau > GiamDoc >
  HocGia > GiaDinh > TuDo; `Buy("phong-tro")` tính tiền thuê vào
  `TotalAssetsVnd`; `AdvanceStage` không kiểm tra Kind.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được.

## Lần chạy mới nhất: 18/11/2026 ~18:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **119/119 PASS, exit 0** — tăng từ 83/83: nhóm T10 mới quét 6 file
  test EditMode đợt 2 (36 mục: đủ 6 file, số test khớp 15/16/17/30/29/18,
  ngoặc cân bằng, NUnit + namespace, không dùng UnityEngine, nhắc đúng API
  thật). 1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS): T9a cũ bắt
  đúng 4 file test, nay đã có 10 file — đã sửa thành kiểm tra tập con.
- **Luồng song song — test EditMode cho 6 module logic thuần còn lại (chuẩn bị C6):**
  `InventoryTests.cs` 15 test (Add/Use/BuffFor/EndFrame, catalog 4 item slice),
  `CraftingTests.cs` 16 test (ToolBehaviour 12 combo 4 tool × 3 tier, 3 công thức,
  CanCraft/Craft/MissingIngredients), `ExplorationTests.cs` 17 test (5 hotspot,
  HotspotsInDistrict, CanFastTravel, Explore 1 lần/ngày, GuideHint 4 NPC),
  `PlayerProgressTests.cs` 30 test (CanOpenChapter 5 chương, SuggestEnding 6 kết
  thúc, RankAtRisk biên 100/30), `DistrictTests.cs` 29 test (18 khu đúng thứ tự/
  tên/Tier + TitleConflict.IsBlocked 7 danh hiệu), `PhoneHubTests.cs` 18 test
  (9 tab đúng thứ tự, Open/Close/Toggle/SelectTab, Notify/Unread/TotalUnread,
  sự kiện TabChanged/OpenChanged). Tổng EditMode nay **207 test** (82 cũ + 125
  mới) — vẫn **chưa chạy được** (VM không có Unity; cần Unity 2022.3.62f1 +
  Unity Test Runner). Toàn bộ module logic thuần client nay đã có test:
  Jobs, TimeSystem, Social, Economy, Inventory, Crafting, Exploration,
  PlayerProgress, District/TitleConflict, PhoneHub. Chỉ còn các file
  MonoBehaviour (PlayerController, CameraFollowBehaviour, GameManagerBehaviour,
  HotspotView, PhoneHubView) chưa có test — cần Unity để test PlayMode.
- **Hành vi lạ phát hiện khi viết test (ghi nhận, chưa sửa code — để GDD/PM xem lại):**
  1. `Inventory.Use` ghi đè khung buff trong catalog (`def.Effect with { Frame =
     currentFrame }`): cơm tấm catalog ghi khung Chiều nhưng dùng lúc Sáng thì
     buff rơi vào Sáng — khung ghi trong catalog thực tế không có tác dụng lúc dùng.
  2. `Inventory.Add` đồ không stackable chỉ chặn khi túi đã có món đó:
     `Add("ao-mua", 2)` lúc túi trống vẫn trả true và giữ 2 áo mưa.
  3. `Exploration.Explore` nhận tham số `gameDay` nhưng không dùng: ngày mới chỉ
     có hiệu lực khi người gọi tự gọi `NewGameDay` — đổi số ngày lúc gọi Explore
     không tự reset lượt khám phá.
  4. `Crafting.Craft` để lại key nguyên liệu = 0 trong Dictionary sau khi chế hết.
  5. `TitleConflict.IsBlocked` chỉ chặn một chiều: đang có "Cảnh sát" thì nhận
     "Tướng Cướp" vẫn được; so sánh `==` nên phân biệt hoa/thường.
  6. `PhoneHub.SelectTab` luôn kích hoạt `TabChanged` kể cả chọn đúng tab hiện
     tại; `Notify` vẫn đếm khi điện thoại đang đóng (không kiểm tra `IsOpen`).
  7. `PlayerProgress.SuggestEnding` có thứ tự ưu tiên cứng
     SieuGiau > GiamDoc > HocGia > GiaDinh > TuDo.
  8. (ghi nhận từ đợt 17:50, nhắc lại) `Buy("phong-tro")` tính tiền thuê vào
     `TotalAssetsVnd`; `AdvanceStage` không kiểm tra Kind.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (207 test) chưa biên
  dịch/chạy lần nào (VM không có dotnet/Unity). Server chưa chạy; client chưa
  có scene slice chơi được.

## Lần chạy trước: 18/11/2026 ~17:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **83/83 PASS, exit 0** — tăng từ 66/66: nhóm T9 mới quét file test
  EditMode (17 mục: đủ 4 file, số test khớp 28/10/22/22, ngoặc cân bằng,
  NUnit + namespace, hồi quy bug Divorce, UTF-8, không secret).
- **Luồng song song — test EditMode cho Social + Economy (chuẩn bị C6):**
  `SocialTests.cs` 22 test (bỏ bê 7/14/21 ngày, Interact +5, AdvanceStage
  ngưỡng 50/70/80, giới hạn 3 quan hệ sâu, 1 BestFriend, supporter +20% EXP,
  solo penalty 40% PROVISIONAL trong khoảng 30–50% chốt, nhóm tan 7 ngày,
  Divorce, BreakUp) + `EconomyTests.cs` 22 test (lãi 0,5% + làm tròn xuống,
  gửi/rút tiết kiệm, mua đồ + fame 50, đấu giá phí 5% + chia nguyên, barter,
  chia tài sản ly hôn, set bonus, dress-code, 4 hàm cấm, TotalAssetsVnd,
  catalog thang nhà 6 bậc). Tổng EditMode nay **82 test** (28 Jobs + 10
  TimeSystem + 22 Social + 22 Economy) — vẫn **chưa chạy được** (VM không có
  Unity; cần Unity 2022.3.62f1 + Unity Test Runner).
- **BUG THẬT PHÁT HIỆN KHI VIẾT TEST — ĐÃ SỬA BẰNG CODE (18/11):**
  `Social.Divorce` dùng `(Kind != Spouse && Stage != Cuoi)` nên Spouse chưa
  cưới vẫn ly hôn được (chỉ cần 1 trong 2 điều kiện là đủ). Đã sửa thành `||`
  — phải vừa là Spouse vừa đang ở Stage Cuoi mới ly hôn được; thêm 2 test
  (Spouse chưa cưới → false, Lover ở Stage Cuoi → false) + kiểm tra hồi quy
  T9e trong `check_static.py` (dòng điều kiện if, không tính comment nhắc bug cũ).
  Ghi nhận thêm (không phải bug, để GDD xem lại sau): `Buy("phong-tro")`
  thêm phòng trọ vào `Owned` nên `TotalAssetsVnd` tính cả 2tr tiền thuê tháng
  như tài sản; `AdvanceStage` không kiểm tra Kind (Spouse cũng đi được
  HenHo → DinhHon → Cuoi).
- **1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS):** T9e lúc đầu FAIL
  giả — regex lấy cả khối Divorce gồm comment nhắc ký tự `&&` của bug cũ.
  Đã sửa chỉ xét dòng điều kiện `if (...)` thay vì cả khối.

## Lần chạy trước: 18/11/2026 ~17:00 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **66/66 PASS, exit 0** — không vỡ kiểm tra cũ.
- **Luồng A — sửa phát hiện `Stats` (đã ghi ở lần ~15:55, nay đã sửa bằng code):**
  `Stats.cs` thêm factory `Stats.WithValues(the, tri, tam)` — tạo `Stats` với
  giá trị tùy ý, không yêu cầu tổng = 300 (PROVISIONAL); từng chỉ số vẫn kẹp
  0..100; ctor chính giữ nguyên (tổng phải = 300). `JobsPayTests.cs` từ 16
  lên **28 test method** (+12): hệ số lương mốc 50 (1.0) và mốc 0 (sàn 0.5)
  cho cả 3 nghề slice, nhân khung tốt + thiếu người, làm tròn xuống, kiểm tra
  độ dốc tuyến tính mốc 60, `WithValues` kẹp giá trị, và `Stats.Train` đánh
  đổi thật qua `WithValues`. Mốc 50/0 khớp đúng công thức `Jobs.cs`
  (`max(0.5, 1.0 + (chỉ số − 50) × 0.01)`), không bịa số mới.
- **Luồng B — khung Unity C1 (file-level, chưa verify mở bằng Unity):**
  `src/client/ProjectSettings/` thêm 10 file `.asset` tối thiểu
  (ProjectSettings, EditorSettings, GraphicsSettings — đã khóa hằng isometric
  `TransparencySortAxis (0, 1, −0.26)`, QualitySettings 6 mức, TagManager,
  TimeManager, Physics2DSettings, DynamicsManager, AudioManager,
  NavMeshAreas) + scene `Assets/Scenes/SliceXomTroCu.unity` (camera ortho,
  nền vàng nắng #F9EDCE, GO `SliceRoot`, chưa có art). Đã có sẵn từ trước:
  `ProjectVersion.txt` 2022.3.62f1, `Packages/manifest.json` (test-framework
  1.1.33), `Assets/Scenes/Main.unity`, `.gitignore` đủ Library/Temp/Logs.
  **Chưa verify:** Unity lần đầu mở còn phải sinh `Library/`, `*.csproj`
  (C3), `.meta` thư mục, `InputManager.asset` / `EditorBuildSettings.asset`
  và chuẩn hóa lại các `.asset` tối thiểu — cần máy có Unity 2022.3.62f1.
- **Vẫn chưa chạy được:** 28 test EditMode + 17 test xUnit vẫn chưa biên dịch/
  chạy lần nào (VM không có dotnet/Unity). `TimeSystem` không wrap quá 30
  phút vẫn chưa có chốt GDD — giữ nguyên, không coi là bug.

## Lần chạy mới nhất: 18/11/2026 ~15:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **66/66 PASS, exit 0** — tăng từ 53/53: nhóm T8 mới quét file
  server (13 mục: ngoặc Program.cs + EconomyLedger.cs, số chốt khớp
  GameBalance, 4 hàm cấm ném exception, secret, UTF-8) + 2 mục T8h/T8i
  (Program.cs đăng ký EconomyLedger singleton, giữ endpoint /health).

### Chuẩn bị C5/C6 trong đợt này (code test thật, CHƯA chạy được)

- **C5 — test xUnit server:** `src/server/tests/PhoXoBo.Server.Tests/`
  (`PhoXoBo.Server.Tests.csproj` net8.0, xUnit 2.9.2; `EconomyLedgerTests.cs`
  256 dòng, 17 test: lãi 0,5%, phí đấu giá 5%, chặn Nợ == Có / trùng
  IdempotencyKey / số tiền ≤ 0, IsBalanced, Gift qua GiftTransit, 4 hàm cấm
  ném InvalidOperationException). Không có test bỏ bê 7 ngày / +20% EXP vì
  2 số đó thuộc `Social.cs` (client), chưa có API server — không bịa API.
  `Program.cs` (26 → 66 dòng): đăng ký `EconomyLedger` singleton + endpoint
  `GET /ledger/balance/{playerId}` và `POST /ledger/gift` (200/409/400);
  `/health` giữ nguyên; ledger vẫn in-memory, endpoint gift chưa có auth.
- **C6 — test EditMode Unity:** `src/client/Assets/Tests/EditMode/`
  (`JobsPayTests.cs` 190 dòng, 16 test; `TimeSystemTests.cs` 99 dòng,
  10 test) + `PhoXoBo.asmdef` mới cho Scripts (trước đây chưa có asmdef nên
  test không tham chiếu được) + `EditMode.asmdef`. `manifest.json` đã có sẵn
  `com.unity.test-framework 1.1.33` (bản đi kèm Unity 2022 LTS), không sửa.
- **Phát hiện khi viết test (đã ghi, chưa sửa code):** `Stats` chỉ khởi tạo
  được (100,100,100) nên hệ số lương ở mốc 50/0 chưa test được qua API công
  khai; `Stats.Train` từ trạng thái max luôn trả false; `TimeSystem.CurrentFrame`
  không wrap khi elapsed vượt 30 phút (chưa có chốt GDD về wrap, không coi là bug).
- **Chưa chạy được:** VM không có dotnet/Unity nên xUnit và EditMode test
  chưa biên dịch/chạy lần nào — phải chạy `dotnet test` và Unity Test Runner
  trên máy có .NET 8 SDK + Unity 2022.3.62f1 trước khi coi C5/C6 là xong.

## Lần chạy trước: 18/11/2026 ~14:44 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **53/53 PASS, exit 0**
- File kiểm tra: 13 file `.cs` trong `src/client/Assets/Scripts/`
  (gồm `PlayerProgress.cs` — file này do một luồng làm song song thêm vào
  và đã push riêng commit `13761c8f` lúc 14:42, không thuộc đợt này).

### Chi tiết 53 mục

| Nhóm | Mục | Kết quả |
|------|-----|---------|
| T1 — Ngoặc cân bằng (13 file .cs) | Crafting, District, Economy, Exploration, GameBalance, Inventory, Jobs, PhoneHub, PlayerProgress, Social, Stats, TimeSystem, TitleConflict | 13/13 PASS |
| T2 — Số chốt khớp GameBalance ↔ docs | 18 khu (District.cs 18 entry + docs), 5 bậc học, học phí 20/80/200/500tr, lãi 0,5%, phí 5%, bỏ bê 7 ngày, +20% EXP, solo 30–50%, mua lớn +50 Danh vọng, thang nhà 6 bậc, rank Chương 5 (10 tỉ / 100 tỉ / An Yên 80), GDD nhắc đủ lãi/phí/bỏ bê/+20% EXP | 28/28 PASS |
| T3 — Social/Economy dùng đúng hằng | Dùng `NeglectDaysToDropCloseness`, `SupportedExpBonusPercent`, `BankInterestPerGameMonth`, `AuctionFeePercent`, `BigPurchaseFameBonus`; không hardcode số chốt | 7/7 PASS |
| T4 — Secret | Không có password / api-key / secret / token / private key trong file .cs | PASS |
| T5 — Ranh giới pháp lý | `CashOut`, `LendWithInterest`, `Gamble`, `BuyWithRealMoney` trong `Economy.cs` luôn trả `false` | 4/4 PASS |
| T6 — Assets | `assets/` trống — chưa đưa asset nào vào, không asset lậu | PASS |
| T7 — Encoding | Mọi file .cs đều UTF-8 | PASS |

### 2 lỗi gặp trong lần chạy đầu (đã sửa, chạy lại PASS)

1. **T2a FAIL lúc đầu — lỗi ở script kiểm tra, không phải ở code:**
   `District.cs` dùng target-typed `new(1, "Xóm Trọ Cũ", ...)` nên regex
   `new District(` đếm được 0 entry. Đã sửa regex đếm `new(số, "tên", Tier)`.
2. **T2o FAIL lúc đầu — lỗi thật ở docs:** GDD Mục 7 chỉ ghi "Xem
   `docs/economy.md`" mà không nhắc lãi 0,5%/tháng. Đã bổ sung 1 dòng vào
   GDD Mục 7 ghi rõ lãi 0,5%, phí 5%, mua lớn +50 Danh vọng (số đã chốt
   sẵn trong `GameBalance.cs` / `economy.md`, không phải số mới).

### Lần chạy đầu cũng phát hiện 1 lỗi script khác (đã sửa)

- `check_static.py` tính sai thư mục gốc (`parents[2]` ra `src/` thay vì
  repo) → `FileNotFoundError`. Đã sửa thành `parents[3]`.

## Lần chạy bổ sung — EconomyLedger (server), 18/11/2026 ~14:45 (giờ VN)

> Luồng song song 3 (server + test). File mới: `src/server/src/EconomyLedger.cs`
> (228 dòng) — sổ cái double-entry server-authoritative: mỗi bút toán Nợ 1 tài
> khoản / Có 1 tài khoản khác, cùng số tiền; `Post()` chặn Nợ == Có và chặn
> ghi trùng bằng IdempotencyKey; `IsBalanced()` kiểm tra tổng Nợ == tổng Có.

- Lệnh: `python3 src/server/tests/check_static.py` (chạy lại từ gốc repo)
- Kết quả: **53/53 PASS, exit 0** — không vỡ kiểm tra cũ.
- Kiểm tra riêng file server mới (script kiểm tra trong `/tmp`, không commit
  vào repo vì `check_static.py` hiện chỉ quét file `.cs` client):
  **18/18 PASS**, gồm:
  - L1 — Ngoặc cân bằng `EconomyLedger.cs`: `{}` 10/10, `()` 67/67, `[]` 0/0.
  - L2 — Số chốt khớp `GameBalance.cs`: lãi 0,5% (`0.005`), phí đấu giá 5%,
    1 tháng game = 30 ngày (PROVISIONAL, khớp `Economy.cs`).
  - L3 — `Post()` chặn Nợ == Có; chặn trùng IdempotencyKey; `IsBalanced()`;
    `AuctionSale` tính phí `hammer * 5 / 100`, người bán nhận `hammer − phí`;
    `Gift()` đi qua tài khoản trung gian `GiftTransit`, không Post cùng tài
    khoản; `ApplyMonthlyInterest` dùng đúng `BankInterestPerGameMonth`.
  - L4 — Ranh giới pháp lý: `CashOut`, `LendWithInterest`, `Gamble`,
    `BuyWithRealMoney` đều bị chặn bằng `throw InvalidOperationException`.
  - L5/L6 — Không có secret; file UTF-8.
- **1 lỗi thật phát hiện khi viết code, đã sửa trước khi kiểm tra:** bản nháp
  `Gift()` gọi `Post(..., PlayerCash, PlayerCash, ...)` — `Post()` chặn Nợ ==
  Có nên sẽ ném lỗi. Đã sửa bằng tài khoản trung gian `GiftTransit` (người
  tặng Nợ Cash / Có Transit, người nhận Nợ Transit / Có Cash). Hạn chế
  skeleton đã ghi trong comment: `BalanceOf()` tính theo từng người chơi nên
  số dư Transit của từng người không về 0 riêng lẻ — khi nối DB thật phải đối
  chiếu Transit theo Reference, không theo PlayerId.
- Chưa làm trong đợt này: `EconomyLedger` chưa được `Program.cs` gọi (server
  vẫn chỉ có `GET /health`), chưa nối PostgreSQL, chưa có test xUnit chạy
  được — vẫn là kiểm tra tĩnh, chưa phải build/test chạy được.

## Hiện trạng thật (18/11/2026, lúc viết báo cáo này)

- Code: 13 file `.cs` client + server `.NET 8` skeleton (`Program.cs`,
  `GET /health`, ghi rõ `database: not-connected`). **Chưa biên dịch lần nào.**
- Chưa có: Unity project đầy đủ (`.csproj` client, `ProjectSettings/`,
  scene, prefab), asset CC0 nào, test xUnit / Unity Test Framework nào
  **chạy được**, server chạy được, bản chơi được thật.
- Đã có trong đợt này: `Social.cs` (quan hệ, bỏ bê 7 ngày, +20% EXP,
  solo chậm 40% trong khoảng 30–50% đã chốt), `Economy.cs` (ví, lãi 0,5%,
  đấu giá phí 5%, barter, chia tài sản ly hôn, 4 hàm cấm luôn trả false),
  `src/server/tests/check_static.py` + `README.md`, báo cáo này.
- Xem checklist để ra bản test được: `docs/roles-qc.md` §6.

## Hiện trạng thật (18/11/2026 ~15:55, lúc viết báo cáo này)

- Kiểm tra tĩnh: **66/66 PASS** (`check_static.py`, gồm nhóm T8 mới quét
  file server + T8h/T8i nối ledger vào `Program.cs`).
- Chuẩn bị C5: test xUnit server `EconomyLedgerTests.cs` (17 test) +
  `Program.cs` đã nối `EconomyLedger` singleton với 2 endpoint
  `/ledger/balance` + `/ledger/gift`; `/health` giữ nguyên.
- Chuẩn bị C6: test EditMode `JobsPayTests.cs` (16 test) +
  `TimeSystemTests.cs` (10 test) + `PhoXoBo.asmdef` + `EditMode.asmdef`;
  `manifest.json` đã có sẵn test-framework 1.1.33.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit và EditMode test
  chưa biên dịch/chạy lần nào; server chưa chạy; client chưa có scene slice
  chơi được. Cần máy có Unity 2022 LTS + .NET 8 SDK để chạy `dotnet test` và
  Unity Test Runner trước khi coi C5/C6 là xong.

## Hiện trạng thật (18/11/2026 ~18:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **119/119 PASS** (`check_static.py`, gồm nhóm T10 mới quét
  6 file test EditMode đợt 2).
- Test EditMode Unity nay **207 test** (Jobs 28 + TimeSystem 10 + Social 22 +
  Economy 22 + Inventory 15 + Crafting 16 + Exploration 17 + PlayerProgress 30 +
  District 29 + PhoneHub 18) — vẫn chưa chạy được lần nào (VM không có
  dotnet/Unity). Toàn bộ module logic thuần client đã có test; chỉ còn các file
  MonoBehaviour chưa có test (cần Unity PlayMode).
- Hành vi lạ ghi nhận khi viết test (chưa sửa, để GDD/PM xem lại):
  `Inventory.Use` ghi đè khung buff, `Add` áo mưa số lượng 2 vẫn qua,
  `Explore` không dùng tham số `gameDay`, `Craft` để lại key = 0,
  `TitleConflict` chỉ chặn một chiều + phân biệt hoa/thường,
  `PhoneHub.Notify` đếm cả khi đóng, `SuggestEnding` ưu tiên cứng.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (207 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~17:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **83/83 PASS** (`check_static.py`, gồm nhóm T9 mới quét
  file test EditMode).
- Test EditMode Unity nay **82 test** (Jobs 28 + TimeSystem 10 + Social 22 +
  Economy 22) — vẫn chưa chạy được lần nào (VM không có dotnet/Unity).
  Bug `Social.Divorce` (điều kiện `&&` sai) đã sửa thành `||` + 2 test hồi quy.
- Khung Unity C1 đã có ở mức file (`ProjectSettings/` 10 file `.asset` +
  scene `SliceXomTroCu.unity`); **chưa verify mở bằng Unity** — cần máy có
  Unity 2022.3.62f1 sinh `Library/` + `.csproj` và kiểm tra Play lần đầu.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (82 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~17:00, lúc viết báo cáo này)

- Kiểm tra tĩnh: **66/66 PASS** (`check_static.py`).
- `Stats.WithValues` đã sửa xong phát hiện "chỉ khởi tạo được (100,100,100)";
  `JobsPayTests.cs` nay 28 test (mốc lương 50/0 đã test được qua API công khai).
- Khung Unity C1 đã có ở mức file (`ProjectSettings/` 10 file `.asset` +
  scene `SliceXomTroCu.unity`); **chưa verify mở bằng Unity** — cần máy có
  Unity 2022.3.62f1 sinh `Library/` + `.csproj` và kiểm tra Play lần đầu.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (28 + 10 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~19:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **129/129 PASS** (`check_static.py`, gồm nhóm T11 mới khóa
  4 bug đã sửa + tổng EditMode 219 test).
- 4 bug ghi nhận ở đợt 18:50 nay đã sửa bằng code + 12 test hồi quy:
  Inventory.Add đồ không stackable (all-or-nothing), Inventory.Use áp đúng
  khung catalog, Crafting.Craft xóa key nguyên liệu về 0, Exploration.Explore
  tự reset khi đổi ngày, TitleConflict.IsBlocked chặn 2 chiều + không phân
  biệt hoa/thường.
- Hành vi lạ còn lại (chưa sửa, để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (219 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được.

## Hiện trạng thật (18/11/2026 ~20:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **156/156 PASS** (`check_static.py`, gồm nhóm T12 mới khóa
  4 scene slice).
- C2 tiến thêm 1 bước: 4/4 scene slice đầu nay đã có khung file
  (`SliceXomTroCu`, `SliceChoDauMoi`, `SliceCongVienAnBinh` khu 17,
  `SlicePhoDiBoChoDem` khu 18 — mỗi scene GameManager + Player +
  CameraFollowBehaviour + camera ortho + đúng hotspot trong
  `Exploration.cs`); đã sửa header `SliceChoDauMoi.unity` ghi nhầm khu 1.
- Hành vi lạ còn lại (chưa sửa, để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind. Việc follow-up C2: spec art
  chi tiết khu 17/18 chưa có trong `docs/art-assets.md` (chỉ có khu 1–2).
- Vẫn chưa chạy được: không có dotnet/Unity trên VM — xUnit (17 test) và
  EditMode test (219 test) chưa biên dịch/chạy lần nào; server chưa chạy;
  client chưa có scene slice chơi được (4/4 scene mới chỉ là khung file).

## Hiện trạng thật (18/11/2026 ~22:45, lúc viết báo cáo này)

- Kiểm tra tĩnh: **198/198 PASS** (`check_static.py`, gồm nhóm T14 mới khóa
  khung Nadia Giai đoạn 1).
- Khung Nadia Giai đoạn 1 đã có ở mức file (`src/nadia/www/`): index.html,
  plugins.js, main.js, PXB_Balance.js, PXB_Isometric.js (bản đầu), data tối
  thiểu (System, MapInfos đủ 18 khu, Map001–002, Actors, Classes, Items),
  package.json NW.js, README. `node --check` 4/4 file JS OK.
- Chưa chơi được: core MV chưa tải về, PXB_Isometric chưa móc Tilemap, tile
  data toàn 0, img/audio trống. Việc tiếp theo: tải core MV v1.6.1 (MIT) về
  js/ + móc Tilemap isometric — rồi mới mở trình duyệt thấy map Xóm Trọ Cũ.
- Phát hiện khi port: slice web lệch khỏi code C# ở 3 chỗ (nghề, công thức,
  hotspot hs-cho-dem/hs-hem-sang) — nadia lấy theo C#; web chưa sửa, để
  GDD/PM xem lại (chi tiết trong `src/nadia/README.md`).
- Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test` vẫn kẹt
  RAM — chạy qua GitHub Actions; Unity chưa có).
