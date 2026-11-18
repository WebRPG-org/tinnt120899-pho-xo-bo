# Treasure of Nadia — Nghiên cứu scene khám phá, áp vào scene Xóm Trọ Cũ (slice)

> Nghiên cứu 18/11/2026, theo lệnh chủ 17:54: "tự giải quyết hoặc tìm cách hoặc
> hỏi Treasure of Nadia". File này là bản học kỹ cơ chế scene của Nadia để giải
> quyết nút thắt scene slice (C2 trong `docs/roles-qc.md` §6): scene Xóm Trọ Cũ
> chơi được ra sao, không phải chỉ là bản đồ đẹp.
> Chỉ nghiên cứu + viết file local. Không copy asset, nhạc, lời thoại, nhân vật,
> tên địa danh của Nadia. Không lấy nội dung người lớn / harem — ranh giới cứng
> (xem `docs/nadia-reference.md` §2).
> Chuẩn đối chiếu tổng: `docs/nadia-reference.md`. Spec đồ họa 2 khu slice:
> `docs/art-assets.md`. Code khớp file này: `Exploration.cs`, `Crafting.cs`,
> `PhoneHub.cs`, `Inventory.cs`, `Jobs.cs`, `TimeSystem.cs`, `District.cs`.

## 0. Nguồn và độ tin cậy

- Nguồn chính: fan guide / walkthrough, **không phải tài liệu chính thức của
  NLT Media**: yekbot.com (guide 200 giờ, 4 lần chơi 100%),
  gamegoon.net (Game Concepts, 2022), naguides.com / naguide.com (walkthrough
  chính + mục Crafting / Ancient Temple), xmodhub.com (100% Completion Guide),
  gamesfuze.com (cách chế Xẻng), cheatinfo.de (bảng công thức / nâng cấp).
- Tra cứu ngày 18/11/2026 bằng `browser.search` + `browser.open` trực tiếp
  yekbot và gamegoon. Các nguồn fan guide đồng thuận với nhau ở các cơ chế
  dưới đây; chỗ nào chỉ có 1 nguồn nói thì ghi rõ "1 nguồn".
- Engine của Nadia các nguồn mâu thuẫn nhau (RPG Maker MV / Ren'Py / Unity)
  — **chỉ lấy thiết kế hệ thống, không lấy kiến trúc kỹ thuật**.
- Nadia là game PC point-and-click, cảnh 2D tĩnh, chơi bằng chuột. Mọi cơ chế
  dưới đây đều phải qua bước "chuyển đổi bắt buộc" sang 2.5D isometric mobile
  9:16, chạm bằng ngón tay (xem §3, cột "Chuyển đổi").

## 1. Nadia làm scene khám phá như thế nào (đã xác minh từ guide)

### 1.1 Cấu trúc scene: "phòng" + điểm chuyển cảnh

- Thế giới Nadia là tập hợp các **"room" (phòng / địa điểm)**: Home, Estero
  Park, Library, Squallmart, Church, Beach, Cave, Lighthouse… Mỗi room là 1
  ảnh nền chi tiết, người chơi click vào vật / cửa / cầu thang để di chuyển
  trong room hoặc sang room khác (vd: click cầu thang trong Home để lên
  Bedroom; GameGoon, "Map of Cape Vedra").
- Trong room, vật tương tác được chia 2 loại: **vật nhặt được** (Object) và
  **điểm chuyển cảnh** (cửa, cầu thang, lối đi). Người chơi học cách đọc room
  bằng cách click thử — không có danh sách vật hiện sẵn.
- Bài học cho Phố Xô Bồ: mỗi khu (district) là 1 "room" lớn kiểu Nadia, và
  trong khu có các **điểm con** (phòng trọ, sạp chợ, góc chế tạo) đóng vai trò
  "room con". Scene slice Xóm Trọ Cũ vì vậy không phải 1 map trống: nó là
  hẻm chính + 3 phòng (người chơi, cô Tư, bạn thân) + Góc Chế Tạo — mỗi điểm
  con có lối vào nhìn thấy được trên map isometric, không giấu trong menu.

### 1.2 Hotspot lấp lánh (sparkle / twinkle) — trái tim của khám phá

- Dấu hiệu: điểm sáng lấp lánh trên nền. Yekbot Part 1: "Click on the sparkle
  to find your first 'treasure'. Any time you see a sparkle you'll want to
  collect it." GameGoon phân loại: **Blue Twinkles** — thường là Talisman
  hoặc vật nhỏ; **Orange Twinkles** — thưởng tốt hơn (profile / Kama Sutra
  page). Màu sắc = cấp độ thưởng, người chơi học được trong vài phút đầu.
- Luật respawn (yekbot, lặp lại nhiều lần trong guide): sparkle **không biến
  mất nếu không nhặt**, nhưng **không xuất hiện lại ở đúng chỗ đó cho tới khi
  người chơi nhặt nó**. Nói cách khác: hotspot là tài nguyên "chờ người chơi",
  không phải tài nguyên "mất nếu bỏ lỡ". Không có FOMO ở đây.
- Vật nhặt được không chỉ là tiền: chìa khóa (Room Key, Chest Key, Church
  Key), bộ phận công cụ (Shovel Shaft, Shovel Handle), công thức chế tạo
  (Silver Talisman Crafting), bản đồ, vật phẩm quest (Unknown Treasure).
  Hotspot vì vậy vừa là kinh tế, vừa là tiến trình, vừa là cốt truyện.
- Chuyển đổi sang Phố Xô Bồ (§3): hotspot phải **to, lấp lánh, viền sáng,
  ≥ 44×44 pt, màu theo cấp** (thường = vàng, hiếm = cam — khớp Blue/Orange
  của Nadia, đổi sang palette Việt). Luật respawn giữ nguyên tinh thần Nadia
  nhưng theo nhịp game mình: mỗi hotspot chỉ nhặt 1 lần / 1 ngày game, sang
  ngày mới có vật / sự kiện mới (đã có trong `Exploration.cs` — `Explore` +
  `NewGameDay`). Không làm hotspot nhỏ li ti phải rà từng pixel: đó là điểm
  Nadia làm được trên PC chuột nhưng **không hợp mobile chạm tay**.

### 1.3 Local Map + fast travel: ô xanh đi được, cửa đỏ chưa mở

- Yekbot mục "Local Map": "The map will show you the areas available to you.
  The green boxes indicate that you can travel between the two 'rooms'. Red
  'doors' mean that you are unable to currently access the area."
- Fast travel trong Nadia là **đi lại giữa các room đã mở**, không phải dịch
  chuyển tức thời qua khu chưa khám phá. Khu chưa mở luôn hiện rõ là "cửa đỏ"
  kèm điều kiện mở ẩn sau đó (cần đồ / cần quest / cần NPC mở đường).
- Chuyển đổi: tab Bản đồ trên điện thoại (`PhoneHub.cs`) của Phố Xô Bồ làm
  đúng vai trò này — khu đã mở = ô xanh, đi ngay; khu chưa mở = cửa đỏ, ghi
  rõ điều kiện mở (chế đồ / làm quest / đủ chỉ số). Code đã có
  (`Exploration.cs` — `CanFastTravel`, `FastTravelUnlockedSlice` = khu
  1, 2, 17, 18 trong slice). Điều Nadia dạy thêm: **đừng giấu điều kiện mở** —
  người chơi phải biết mình thiếu cái gì thì mới có mục tiêu đi nhặt / chế.

### 1.4 NPC dẫn đường: Soul Crystal / Evie — và lỗi Nadia đã mắc

- Cơ chế (GameGoon, "The Soul Crystal"; yekbot): Soul Crystal là vật phẩm
  trong inventory; mở nó ra, Evie (linh hồn trong đá) cho gợi ý: làm gì tiếp,
  đi đâu, nói chuyện với ai. Yekbot: "If you're stuck, open your Soul Crystal
  and do what Evie tells you to do." / "During the main story, the Soul Stone
  can help point you in the right direction."
- Gợi ý của Evie **nhúng trong lore** (một nhân vật nói chuyện với người chơi),
  không phải nút "Hint" khô khan ngoài thế giới. Evie còn nhắc lưu game, nhắc
  tăng tốc độ di chuyển — tức là hệ gợi ý kiêm luôn hệ onboarding.
- **Lỗi Nadia đã mắc (phải tránh):** GameGoon ghi rõ Soul Crystal bị đánh cắp
  ở khoảng 60–70% tiến trình — "After you finish the main story you will lose
  the Soul Crystal, and Evie's help. The Soul Crystal is replaced with the
  Empty Pocket." Người chơi mất hệ gợi ý đột ngột giữa game; fan guide phải
  dặn "Evie can help you catch up" sau khi skip. Đây là bài học ngược quan
  trọng nhất của file này.
- Chuyển đổi (đã có trong `Exploration.cs` — `GuideHint`): **NPC dẫn đường
  thay Soul Crystal** — cô Tư, chị Lệ, ông Ba, anh Hải, bạn thân NPC — gợi ý
  bằng lời thoại trong thế giới, gắn với mục tiêu hiện tại, không spoil đáp
  án. Gợi ý **nhạt dần theo tiến trình chứ không biến mất**: Sổ Tay bậc cao
  cho gợi ý rõ hơn (mục tiêu + khu + nguyên liệu còn thiếu — xem
  `Crafting.cs` `ToolBehaviour`), không bao giờ cắt hẳn hệ gợi ý như Nadia.

### 1.5 Crafting ở Native Shrine — cổng tiến trình, không phải hệ phụ

- Vị trí: Native Crafting Shrine nằm sâu trong hang (Cave) ở Estero Park —
  **một địa điểm trong thế giới**, phải đi tới mới chế được. Xmodhub: "The
  Native Crafting Shrine, located deep in the jungle, acts as your primary
  progression hub." Không phải menu chế tạo mở ở đâu cũng được.
- Công thức: Basic Shovel = Shovel Head + Shovel Shaft + Iron Ore; Jade
  Shovel = Jade Talisman + Shovel Handle + Shovel Shaft + Shovel Head;
  Silver Talisman = Stone Talisman ×3 + Silver Ore; Gold Talisman = Silver
  Talisman + Gold Ore ×3 (xmodhub + gamesfuze + cheatinfo đồng thuận).
  Công thức học qua chơi: nhặt được tờ công thức trong thế giới, NPC dạy,
  hoặc đọc được ở địa điểm — không mua công thức bằng tiền thật.
- Crafting là **cổng tiến trình bắt buộc**: không chế được Xẻng thì không đào
  được Talisman cấp cao, không mở được khu sâu hơn. Yekbot: "Upgrading your
  basic equipment into the max-level Shovel, Pickaxe, and Grappling Hook is
  mandatory to access late-game temple chambers."
- 4 công cụ cố định — Boots, Metal Detector, Guide, Shovel (yekbot mục
  Inventory Screen): nâng cấp **đổi hành vi thật**, không chỉ +số. Boots:
  miễn nhiễm môi trường (độc, bọ cạp, sàn nứt); Guide: Talisman tìm được tốt
  hơn; Shovel: đào nhanh hơn, Talisman cấp thấp hiện ngay lập tức ("Stone
  Talismans will now instantly pop up" — Jade Shovel; Swift Shovel thì cả
  Stone lẫn Jade đều instant). Metal Detector: nhặt được đống tiền ($5 / $100,
  hiếm $950 / $9,000).
- Kinh tế từ chế tạo: Talisman bán cho Diana ở Library — Stone $10, Jade
  $140, Silver $1,000 (yekbot + scribd guide đồng thuận). Đây là nguồn tiền
  chính của Nadia, nhưng là nguồn tiền **gắn với khám phá**, không phải nút
  bấm in tiền.
- Chuyển đổi: Góc Chế Tạo trong phòng người chơi ở Xóm Trọ Cũ + sạp cuối chợ
  ở Chợ Đầu Mối (đã có trong `docs/art-assets.md` §1.6/§2.6 và
  `Crafting.cs`). Công thức đầu Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ
  tương đương Basic Shovel. 4 công cụ Việt (Xe Đẩy / Đèn Soi / Sổ Tay / Xẻng)
  nâng cấp đổi hành vi thật theo `Crafting.cs` `ToolBehaviour`.

### 1.6 Điện thoại là hub — và nhà là cổng quan hệ

- GameGoon, "Your phone": điện thoại là vật duy nhất có sẵn trong inventory
  trống lúc đầu, là "main game interface mechanic": Load/Save, Settings,
  Progress, replay scene, gọi NPC. Mọi menu hệ thống đi qua điện thoại, nhưng
  điện thoại **không thay thế việc đi lại trong thế giới** — vẫn phải tới
  từng room để nhặt / nói chuyện / chế tạo.
- Quan hệ gắn với nhà: GameGoon mục Booty Calls / Collecting Hearts — nhận
  số điện thoại NPC thì gọi được họ tới nhà, nhưng nhà phải nâng cấp thì NPC
  mới tới (Sofia yêu cầu nhà gần như nâng cấp đầy đủ); 6 hearts / NPC; cần
  Kama Sutra Page mới tương tác được. Bài học: **nhà không phải prop trang
  trí — nhà là điều kiện mở quan hệ**, giống GDD Mục 7 (nhà → hồi năng lượng,
  mở nghề quản lý, mở title Chủ Nhà Trọ).
- Chuyển đổi: điện thoại 9 tab của Phố Xô Bồ (`PhoneHub.cs`) giữ đúng vai
  trò hub của Nadia, nhưng thêm tab Việt (Ngân hàng, Việc làm, Chợ, Học tập).
  Nhà ở Xóm Trọ Cũ là phòng trọ thuê — nâng cấp nhà = mở quan hệ sâu hơn,
  đúng tinh thần Nadia nhưng đổi sang đời Việt.

### 1.7 Chi tiết đồ họa + puzzle đời thường

- Nadia: nền pre-rendered chi tiết, vật dụng kể chuyện (ghi chú của cha trên
  giường, bảng phấn ghi số, ảnh trên bàn). Người chơi đọc được cốt truyện từ
  đồ vật, không chỉ từ thoại. Zoom (F3) để nhìn chi tiết.
- Puzzle đền: pressure plate theo thứ tự, đá chặn đường, khóa/chìa theo biểu
  tượng, đuốc (15 đuốc, cần Lighter mua ở Squallmart; mỗi đuốc mở 1 phần
  thưởng). Puzzle là **logic trong thế giới**, không phải mini-game tách rời.
- Chuyển đổi: chi tiết zoom được giữ nguyên chuẩn (`docs/art-style.md` §1,
  `docs/art-assets.md` §0 — sạp có nồi niêu / lá chuối / ghế nhựa, mỗi vật
  kể đời sống Việt). Puzzle đền **không bê nguyên**: puzzle Phố Xô Bồ là
  puzzle đời thường — sắp xếp sạp hàng, ghép đơn shipper theo tuyến, mở kho
  bằng mật mã NPC cho (`docs/nadia-reference.md` hàng 11). Đuốc của Nadia
  đổi thành **đèn soi / đèn lồng**: thắp đèn ở hẻm tối để thấy hotspot ẩn
  (Đèn Soi bậc cao thấy hotspot ẩn — đã có trong `Crafting.cs`).

### 1.8 Nhịp chơi + tiền: vòng lặp 1 phiên của Nadia

- Một phiên Nadia điển hình (yekbot Part 1, rút gọn): vào Park → nhặt
  sparkle/Talisman → bán cho Diana ở Library lấy tiền → mua đồ cần (Field
  Guide $60, Metal Detector $70, Shovel Head $80, Insurance $60) → quay lại
  Park đào sâu hơn / mở khu mới → gặp NPC → nhận quest → lặp lại, mỗi vòng
  mở thêm 1 khu hoặc 1 công cụ.
- Điểm mấu chốt: **mỗi phiên đều có tiến triển thấy được** (thêm tiền, thêm
  đồ, mở thêm 1 lối đi, gặp thêm 1 NPC). Không có phiên nào chỉ đi lòng vòng.
- Chuyển đổi sang nhịp Phố Xô Bồ (1 ngày game = 30 phút thật, 3 khung
  Sáng/Chiều/Tối, 1–2 khung/ngày là đủ — GDD Mục 1): một phiên = 1 khung:
  vào 1 khu → nhặt 1–2 hotspot → làm 1 ca nghề hoặc 1 quest NPC → chế hoặc
  bán 1 món → thấy tiến triển (tiền / nguyên liệu / thân thiết tăng). Không
  bắt người chơi chơi đủ 3 khung mới có tiến triển.

## 2. Bảng đối chiếu — từng cơ chế Nadia → scene Xóm Trọ Cũ (slice)

| # | Cơ chế Nadia (nguồn) | Áp dụng vào Xóm Trọ Cũ | Chuyển đổi bắt buộc | Code / docs |
|---|----------------------|------------------------|---------------------|-------------|
| 1 | Scene = "room" có vật nhặt + điểm chuyển cảnh (GameGoon) | Hẻm chính là room lớn; 3 phòng (người chơi, cô Tư, bạn thân) + Góc Chế Tạo là room con, có lối vào nhìn thấy được trên map isometric | 2D tĩnh PC → 2.5D isometric mobile; click chuột → chạm tay; room con không giấu trong menu | `docs/art-assets.md` §1.2, scene `SliceXomTroCu.unity` |
| 2 | Sparkle lấp lánh, không biến mất, không respawn cho tới khi nhặt (yekbot) | Hotspot `hs-tro-toi` (Chai nhựa ×2, khung Tối) ở cuối hẻm cạnh thùng rác phân loại; thêm `hs-hem-sang` PROVISIONAL (Vải vụn ×1, khung Sáng, trước cửa phòng trọ — đã ghi trong art-assets §1.5 là "mở sau") | Hotspot to ≥ 44×44 pt, viền sáng vàng, màu theo cấp (thường vàng, hiếm cam); nhặt 1 lần / 1 ngày game, sang ngày có vật mới; không rà pixel | `Exploration.cs` (`Hotspots`, `Explore`) |
| 3 | Blue Twinkle = vật thường, Orange Twinkle = thưởng tốt (GameGoon) | Màu hotspot theo cấp: vàng = nguyên liệu thường (Chai nhựa, Vải vụn); cam = nguyên liệu hiếm / vật quest (chỉ hiện khi có Đèn Soi bậc cao) | Đổi xanh/cam của Nadia sang vàng/cam palette Việt (`docs/art-assets.md` §0); người chơi học được mã màu trong 5 phút đầu, không cần hướng dẫn dài | `Exploration.cs`, `Crafting.cs` (Đèn Soi) |
| 4 | Local Map: ô xanh đi được, cửa đỏ chưa mở (yekbot) | Tab Bản đồ trên điện thoại: Xóm Trọ Cũ + Chợ Đầu Mối + Công Viên + Chợ Đêm = ô xanh (slice); khu khác = cửa đỏ, ghi rõ điều kiện mở (vd: "Chế Xe Đẩy Hàng để mở Làng Đại Học") | Map của Nadia là màn hình riêng; của mình là 1 tab trong điện thoại 9 tab (`PhoneHub.cs`) | `Exploration.cs` (`CanFastTravel`), `PhoneHub.cs` |
| 5 | Soul Crystal / Evie gợi ý khi bí, nhúng trong lore (GameGoon, yekbot) | Cô Tư là NPC dẫn đường ở Xóm Trọ Cũ: khi người chơi bí (đứng yên / không biết làm gì tiếp), cô Tư nói 1 câu gợi ý gắn mục tiêu hiện tại (vd: "Ra chợ sớm mà nhặt đồ. Còn chế Xe Đẩy thì ghé sạp đầu hẻm hỏi thử.") | Evie là linh hồn trong đá → cô Tư là chủ trọ bằng xương bằng thịt; gợi ý nhạt dần theo Sổ Tay bậc cao, **không biến mất giữa game** (lỗi Nadia) | `Exploration.cs` (`GuideHint`) |
| 6 | Native Shrine là địa điểm trong thế giới, phải đi tới mới chế được (xmodhub) | Góc Chế Tạo trong phòng người chơi, cạnh cửa sổ: bàn gỗ cũ, đèn bàn vàng, hộp dụng cụ, ván gỗ dựa tường, khung sắt góc phòng (`docs/art-assets.md` §1.6) | Shrine trong hang sâu → góc chế tạo trong phòng trọ; vẫn giữ nguyên tắc "phải đi tới chỗ chế", không chế từ menu ở đâu cũng được | `Crafting.cs` (`RecipeCatalog`), `docs/art-assets.md` §1.6 |
| 7 | Basic Shovel = Shovel Head + Shaft + Iron Ore; công thức học qua chơi (xmodhub, gamesfuze) | Xe Đẩy Hàng = Khung Sắt + Bánh Xe + Ván Gỗ; công thức do cô Tư dạy sau quest đầu tiên ở Xóm Trọ Cũ (không mua bằng tiền thật) | Đồ đảo giả tưởng → đồ chợ Việt; giữ nguyên cấu trúc "3 nguyên liệu + 1 vật phẩm" của công thức đầu | `Crafting.cs` (`che-xe-day`) |
| 8 | 4 công cụ nâng cấp đổi hành vi: Boots miễn nhiễm, Shovel đào instant, Guide tìm Talisman tốt hơn (yekbot) | Xe Đẩy bậc cao chở nhiều + đi được đường mưa; Đèn Soi bậc cao thấy hotspot ẩn; Sổ Tay bậc cao gợi ý rõ mục tiêu + khu + nguyên liệu thiếu; Xẻng bậc cao nhặt nhanh + có đồ hiếm | Giữ nguyên tắc "đổi hành vi, không +5% số"; tên + bối cảnh Việt hoá hoàn toàn | `Crafting.cs` (`ToolBehaviour`, `ToolTier`) |
| 9 | Talisman bán cho Diana: Stone $10, Jade $140, Silver $1,000 (yekbot) | Đồ chế / nguyên liệu bán ở Chợ qua tab Chợ + sạp trong thế giới; giá theo `docs/economy.md`, phí đấu giá 5% đã chốt — **không phải nguồn tiền duy nhất** (nghề / học vấn vẫn là trụ) | Người mua cố định Diana → chợ người chơi + sạp; tránh "máy in tiền" phá kinh tế (Nadia bị chê farm Talisman) | `Crafting.cs`, `Economy.cs`, `docs/economy.md` |
| 10 | Nhà nâng cấp mở quan hệ (GameGoon: Booty Calls, Hearts) | Phòng trọ thuê là nhà khởi đầu; nâng cấp nhà / thuê nhà tốt hơn mở quan hệ sâu + nghề quản lý + title Chủ Nhà Trọ (GDD Mục 7) | Harem / booty call → quan hệ lành mạnh: người yêu / vợ chồng / bạn thân / gia đình (GDD Mục 8, `Social.cs`) | GDD Mục 7/8, `Social.cs` |
| 11 | Điện thoại là hub: Save/Load, Settings, Progress, replay (GameGoon) | Điện thoại 9 tab (`PhoneHub.cs`): Danh bạ/Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt — mọi menu qua điện thoại, nhưng vẫn phải đi lại trong phố để khám phá / làm việc / gặp NPC | Thêm tab Việt; giữ nguyên tắc "hub không thay thế thế giới" | `PhoneHub.cs` |
| 12 | Chi tiết nền kể chuyện; zoom F3 nhìn chi tiết (GameGoon, yekbot) | Chi tiết zoom được: tường vàng loang lổ, dây điện chằng chịt, xe máy dựng sát tường, chậu cây, ghế nhựa + ly cà phê sữa đá (`docs/art-assets.md` §1.3) | Nền pre-rendered PC → sprite isometric 2.5D; zoom chuột F3 → pinch-zoom chạm tay | `docs/art-assets.md` §1, `docs/art-style.md` §1 |
| 13 | Đuốc (15 đuốc, cần Lighter) mở phần thưởng từng phần (GameGoon) | Đèn soi / đèn lồng ở hẻm tối: thắp đèn để thấy hotspot ẩn buổi tối; Đèn Soi bậc cao thấy hotspot hiếm chỉ xuất hiện 1 khung/ngày | Đuốc đền cổ → đèn hẻm Việt; giữ nguyên tắc "dụng cụ mở vùng tối" | `Crafting.cs` (Đèn Soi), `Exploration.cs` |
| 14 | Mỗi phiên đều có tiến triển thấy được (tiền / đồ / khu mới / NPC mới) | Một phiên = 1 khung: vào 1 khu → nhặt 1–2 hotspot → làm 1 ca nghề hoặc 1 quest NPC → chế hoặc bán 1 món → thấy tiền / nguyên liệu / thân thiết tăng | Nhịp PC dài (50+ giờ) → nhịp mobile 1–2 khung/ngày, 1 ngày game = 30 phút thật (GDD Mục 1) | GDD Mục 1/9, `TimeSystem.cs`, `Jobs.cs` |

## 3. Ba áp dụng cụ thể nhất cho scene slice Xóm Trọ Cũ

Ba điều này là đáp án trực tiếp cho nút thắt C2 (scene slice chơi được) —
làm 3 điều này trước, các điều khác trong bảng §2 làm sau.

### Áp dụng 1 — Hotspot "chờ người chơi", màu theo cấp, nhặt 1 lần/ngày

- **Nadia dạy:** sparkle không biến mất nếu không nhặt, không respawn cho tới
  khi nhặt; Blue = thường, Orange = thưởng tốt (yekbot + GameGoon).
- **Áp vào Xóm Trọ Cũ:** hotspot `hs-tro-toi` ở cuối hẻm (Chai nhựa ×2,
  khung Tối) + thêm `hs-hem-sang` PROVISIONAL (Vải vụn ×1, khung Sáng,
  trước cửa phòng trọ). Hotspot to ≥ 44×44 pt, lấp lánh, viền sáng vàng
  (thường) / cam (hiếm). Nhặt 1 lần / 1 ngày game; sang ngày mới có vật mới.
- **Vì sao là quan trọng nhất:** đây là vòng lặp lõi "đi phố → nhặt → chế".
  Không có hotspot nhìn thấy được + luật respawn rõ ràng thì scene chỉ là bản
  đồ đẹp, người chơi không biết làm gì trong đó. Code đã có
  (`Exploration.cs` — `Explore`, `NewGameDay`); việc còn lại là vẽ hotspot
  đúng spec trong scene `SliceXomTroCu.unity` và gắn đúng id đã có.

### Áp dụng 2 — Cô Tư là Evie của Phố Xô Bồ, nhưng không bao giờ biến mất

- **Nadia dạy:** Soul Crystal / Evie là "lifeline" — mở ra là biết làm gì
  tiếp, đi đâu, gặp ai (GameGoon). **Lỗi Nadia:** Evie biến mất ở 60–70%
  game khi Soul Crystal bị đánh cắp, người chơi mất hệ gợi ý đột ngột.
- **Áp vào Xóm Trọ Cũ:** cô Tư (chủ trọ, áo bà ba nâu, tóc búi) đứng cửa
  phòng, là NPC dẫn đường mặc định của khu. Khi người chơi bí, cô Tư nói 1
  câu gắn mục tiêu hiện tại — đã có trong `Exploration.cs` (`GuideHint`).
  Sổ Tay nâng cấp làm gợi ý rõ dần (mục tiêu → khu → nguyên liệu thiếu),
  nhưng **không bao giờ cắt gợi ý** — trái ngược hoàn toàn lỗi Nadia.
- **Vì sao quan trọng thứ hai:** slice đầu tiên là nơi người chơi mới dễ bí
  nhất. Không có NPC dẫn đường thì người chơi mới bỏ game trong 5 phút đầu;
  có mà làm kiểu nút "Hint" khô khan thì mất hồn Nadia. Cô Tư vừa là lore,
  vừa là tutorial, vừa là quest-giver (dạy chế Xe Đẩy sau quest đầu).

### Áp dụng 3 — Góc Chế Tạo là "Native Shrine" trong phòng trọ, chế là cổng mở khu

- **Nadia dạy:** Native Shrine là địa điểm trong thế giới, phải đi tới mới
  chế được; không chế được Xẻng thì không mở được khu sâu hơn; công thức học
  qua chơi, không mua bằng tiền thật (xmodhub, gamesfuze).
- **Áp vào Xóm Trọ Cũ:** Góc Chế Tạo trong phòng người chơi, cạnh cửa sổ
  (bàn gỗ cũ, đèn bàn vàng, hộp dụng cụ, ván gỗ, khung sắt — xem
  `docs/art-assets.md` §1.6). Công thức đầu Xe Đẩy Hàng = Khung Sắt + Bánh
  Xe + Ván Gỗ (tương đương Basic Shovel), do cô Tư dạy sau quest đầu. Chế
  xong Xe Đẩy mới mở được khu tiếp theo / nghề shipper hiệu quả — tức là
  **chế tạo là cổng tiến trình, không phải mini-game phụ**.
- **Vì sao quan trọng thứ ba:** nếu chế tạo chỉ là menu bấm nút ở đâu cũng
  được thì mất hẳn "đi tới — nhặt — chế — mở khu" của Nadia, và scene Xóm
  Trọ Cũ mất lý do để người chơi quay lại phòng. Góc Chế Tạo buộc người chơi
  phải về phòng, gặp cô Tư, thấy nhà mình thay đổi theo tiến trình — đó là
  cách Nadia biến "nhà" thành một phần của vòng lặp, không phải màn hình chờ.

## 4. Những gì Nadia làm mà Phố Xô Bồ KHÔNG nên copy

| # | Nadia làm | Vì sao không copy | Thay bằng gì |
|---|-----------|-------------------|--------------|
| 1 | Toàn bộ nội dung người lớn / harem (12 nhân vật, Kama Sutra page, booty call) | Rủi ro store + pháp lý VN; trái hướng chữa lành / thuần Việt | Quan hệ lành mạnh GDD Mục 8: người yêu / vợ chồng / bạn thân / gia đình, thân thiết 0–100 (`Social.cs`) |
| 2 | Point-and-click rà từng pixel tìm sparkle / vật | Mobile chạm tay: hotspot nhỏ gây ức chế, bỏ game | Hotspot to ≥ 44×44 pt, lấp lánh, viền sáng, màu theo cấp (§2 hàng 2–3) |
| 3 | Quest khóa theo ngày/giờ cứng trong game (vd: quest Clare phải đúng thứ Ba / thứ Năm trong game mới làm được — xmodhub) | Trái luật "không FOMO, miss khung không phạt" (GDD Mục 1/12) | Quest mở theo tiến trình (chế đồ / thân thiết / chương), không theo lịch thật cứng |
| 4 | Mất hệ gợi ý đột ngột giữa game (Soul Crystal bị đánh cắp 60–70%) | Người chơi bí không biết làm gì tiếp, phải tra guide ngoài | NPC dẫn đường suốt 5 chương, gợi ý nhạt dần theo Sổ Tay, không biến mất (§2 hàng 5) |
| 5 | Pacing 50+ giờ kiểu PC, cốt truyện dài lê thê (yekbot: 200 giờ, 4 lần chơi 100%) | Phố Xô Bồ chơi 1–2 khung/ngày, 1 ngày game = 30 phút thật | Chương ngắn, mỗi phiên 1 khung có tiến triển thấy được (§1.8) |
| 6 | Engine / kiến trúc kỹ thuật của Nadia | Các nguồn mâu thuẫn nhau (RPG Maker MV / Ren'Py / Unity) — không đáng tin | Kiến trúc Phố Xô Bồ theo `docs/architecture.md` (Unity + .NET 8 modular monolith) |
| 7 | Asset, nhạc, lời thoại, nhân vật, tên địa danh của Nadia (Cape Vedra, Estero Park, Diana, Evie…) | Bản quyền | Mọi art / nhạc / tên tự vẽ hoặc CC0 có nguồn rõ ràng; địa danh An Bình, 18 khu Việt |
| 8 | Farm Talisman thành "máy in tiền" (Silver $1,000, Gold cao hơn — bán cho Diana là nguồn tiền chính) | Phá kinh tế game, nghề / học vấn mất giá trị | Đồ chế bán được nhưng không phải nguồn tiền duy nhất; nghề / buôn bán / học vấn vẫn là trụ (GDD Mục 7, `docs/economy.md`); phí đấu giá 5% đã chốt |
| 9 | Sparkle / vật phẩm có thể nhặt nhầm thành vật vô dụng cả game (yekbot Part 2: "Don't click on the sparkle [sách]… you'll have a useless book in your inventory for the rest of the game") | Thiết kế bẫy người chơi mới; inventory rác không xóa được | Mọi hotspot trong slice đều cho nguyên liệu dùng được (theo `MaterialIds`); không có vật "bẫy" vĩnh viễn; vật thừa bán / tặng được |
| 10 | Temple puzzle chặn cốt truyện chính quá lâu (49 puzzle, pressure plate, khóa/chìa) | Người chơi kẹt puzzle thì kẹt luôn cốt truyện | Puzzle đời thường ngắn (sắp xếp sạp, ghép đơn shipper, mật mã NPC cho); không chặn chương chính quá 1 phiên |

## 5. Checklist làm scene slice Xóm Trọ Cũ (dùng file này làm spec)

Trước khi coi C2 xong, kiểm tra từng mục — lấy từ bảng §2 + §3:

- [ ] Hẻm chính + 3 phòng + Góc Chế Tạo đều có lối vào nhìn thấy được trên map isometric (không giấu trong menu)?
- [ ] Hotspot `hs-tro-toi` vẽ đúng spec (to ≥ 44×44 pt, lấp lánh, viền sáng vàng, cuối hẻm cạnh thùng rác)? Hotspot `hs-hem-sang` PROVISIONAL đã thêm vào `Exploration.cs` hay chưa?
- [ ] Màu hotspot theo cấp đã nhất quán (vàng = thường, cam = hiếm / cần Đèn Soi bậc cao)?
- [ ] Nhặt 1 lần / 1 ngày game, sang ngày có vật mới — đã test bằng `Explore` + `NewGameDay`?
- [ ] Cô Tư đứng cửa phòng, có thoại gợi ý khi người chơi bí (`GuideHint`)? Gợi ý có gắn mục tiêu hiện tại không?
- [ ] Góc Chế Tạo trong phòng người chơi (bàn gỗ, đèn vàng, hộp dụng cụ) — chế Xe Đẩy Hàng có mở được khu / nghề tiếp theo không?
- [ ] Tab Bản đồ trên điện thoại: khu slice ô xanh đi ngay, khu chưa mở cửa đỏ + ghi rõ điều kiện mở?
- [ ] Một phiên 1 khung có tiến triển thấy được (tiền / nguyên liệu / thân thiết tăng) — hay đi lòng vòng không được gì?
- [ ] Không có nội dung người lớn / harem / asset Nadia nào lọt vào scene?
- [ ] Không có hotspot rà pixel, không có quest khóa ngày/giờ cứng, không có vật bẫy vĩnh viễn?
- [ ] Rubric soulful_short_video đủ 12/16, không chiều nào 0 (`docs/art-style.md` §6)?

## 6. Nguồn

- Yekbot — Treasure of Nadia: Walkthrough Guide (200 giờ, 4 lần 100%):
  https://www.yekbot.com/treasure-of-nadia-walkthrough-guide/
- GameGoon — Treasure of Nadia: Game Concepts:
  https://gamegoon.net/2022/04/17/treasure-of-nadia-game-concepts/
- NAGuide — Treasure of Nadia Walkthrough Guide:
  https://www.naguide.com/treasure-of-nadia-guide-walkthrough/
- XModHub — Treasure of Nadia Walkthrough: 100% Completion Guide:
  https://www.xmodhub.com/info/guides/treasure-of-nadia-walkthrough/
- GamesFuze — How to Craft a Shovel in Treasure of Nadia:
  https://gamesfuze.com/how-to/treasure-of-nadia-how-to-craft-a-shovel/
- CheatInfo — Treasure of Nadia Cheats / Shovel & boot upgrades / recipes:
  https://www.cheatinfo.de/files/treasureofnadia.htm
- ShowGamer — Treasure of Nadia walkthrough (bản tóm tắt, có cảnh báo nội dung
  người lớn — chỉ dùng để đối chiếu cơ chế, không lấy nội dung):
  https://showgamer.com/en/prohozhdeniya-igr/202-treasure-of-nadia
- Repo: `docs/nadia-reference.md` (lock đối chiếu 12 hệ), `docs/references.md`
  §4 (tóm tắt lấy/bỏ Nadia), `docs/art-assets.md` (spec 2 khu slice),
  `Exploration.cs` / `Crafting.cs` / `PhoneHub.cs` (code khớp file này).
