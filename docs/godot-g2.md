# Godot G2 — Port 17 plugin PXB → GDScript (19/11/2026)

> **Kết luận: G2 bước 4/5 XONG (mức headless).** Thêm 2 hệ gameplay:
> `PxbEconomy` (ví, tiết kiệm lãi 0,5%/tháng, catalog 17 món, đấu giá
> phí 5%, đổi đồ, chia tài sản, set bonus, dress-code, 4 hành vi bị
> chặn) + `PxbEducation` (5 bậc học, khóa ngắn hạn, học bổng, ghế /
> thứ tự đăng ký, mentor). Selftest mới **92/92 PASS**, G2 cũ 87/87 +
> Jobs 56/56 + Hotspot 37/37 + Inventory/Crafting 78/78 + G1 42/42 +
> playtest 14/14 vẫn PASS (không regression), scene chạy 120 frame
> exit 0, export web exit 0 (~8s), http.server 200 đủ 6 file.
> **Chưa kiểm chứng bằng trình duyệt thật** — như G0/G1/G2 bước 1–3, VM
> không có Chromium/Firefox. Tổng G2: 9/17 plugin → 9 hệ GDScript.
>
> G2 bước 3/5 XONG trước đó (xem lịch sử file): 2 hệ `PxbInventory` +
> `PxbCrafting`, selftest 78/78 PASS.
>
> G2 bước 1/5 XONG trước đó (xem lịch sử file): 3 hệ nền `PxbBalance` →
> `PxbStats` → `PxbTime`, selftest 87/87 PASS.

## 1. Thứ tự port (docs/opensource-engine.md §4)

| Bước | Hệ | Trạng thái |
|---|---|---|
| 1 | `PXB_Balance` → `PxbBalance` | ✅ XONG đợt này |
| 1 | `PXB_Stats` → `PxbStats` | ✅ XONG đợt này |
| 1 | `PXB_Time` → `PxbTime` | ✅ XONG đợt này |
| 2 | `PXB_Jobs` → Jobs (làm ca, lương, quota) | ✅ XONG đợt này |
| 2 | `PXB_Hotspot` → Hotspot (nhặt 1 lần/ngày đúng khung) | ✅ XONG đợt này (port đầy đủ, thay ghi chú cũ "đã có tương đương ở G1") |
| 2 | `PXB_Inventory` / `PXB_Crafting` → Inventory/Crafting | ✅ XONG đợt này (xem §2e) |
| 3 | `PXB_Economy` → Economy (lãi 0,5%, phí 5%, 4 hành vi cấm) | ✅ XONG đợt này (xem §2h) |
| 3 | `PXB_Education` → Education (5 bậc) | ✅ XONG đợt này (xem §2h) |
| 4 | `PXB_Social` → Social; `PXB_Titles` / `PXB_Story` → Titles/Story | ⏳ |
| 4 | `PXB_PhoneHub` → PhoneHub (CanvasLayer, 9 tab) | ⏳ |
| 5 | `PXB_MarketBattle` → MarketBattle (luật chờ chủ duyệt) | ⏳ |
| 5 | `PXB_Online` / `PXB_SaveCloud` → Online/SaveCloud | ⏳ |

`PXB_Isometric` đã có tương đương Godot ở G1
(`iso_map.gd`, hotspot trong `main.gd`); `PXB_Tools` là hàm tiện ích,
port rải rác khi cần. Tổng 17 plugin MV → 14 hệ GDScript + 2 đã xong ở G1.

## 2e. File mới đợt này (G2 bước 3, 19/11 ~21:50)

| File | Nội dung |
|---|---|
| `scripts/pxb_balance.gd` (sửa) | Thêm `ITEMS` (4 vật phẩm slice: Cơm tấm 35k Thể +5 Chiều, Cà phê 25k Trí +5 Sáng, Sách 80k Trí +5 Tối, Áo mưa 120k không xếp chồng, không buff) + `item_by_id()` — theo quy ước JOBS/RECIPES: số chỉ nằm ở Balance, file khác không hardcode lại. |
| `scripts/pxb_inventory.gd` (`PxbInventory`, ~150 dòng) | Port `Inventory.cs` (không có plugin PXB_Inventory.js ở bản MV — túi đồ MV dùng $gameParty + túi nguyên liệu chung với Hotspot): `add()` stackable / all-or-nothing (đồ không xếp chồng quantity > 1 hoặc đã có → false, không thêm gì), `use()` trừ 1 + buff tạm, `buff_for()` cộng dồn theo chỉ số + khung, `end_frame()` hết khung hết buff, `data()`/`from_data()`. Buff áp đúng khung catalog (cơm tấm dùng lúc Sáng vẫn buff Chiều — bug đã sửa 18/11); C# giữ entry 0 trong túi sau khi dùng hết món cuối nên port giữ nguyên (khác Crafting xóa key 0). Tiền không nằm ở đây (thuộc ví/Economy). |
| `scripts/pxb_crafting.gd` (`PxbCrafting`, ~280 dòng) | Port `PXB_Crafting.js` / `Crafting.cs`: 3 công thức slice từ `PxbBalance.RECIPES`, `can_craft()`/`craft()` (trừ trực tiếp trên túi truyền vào, về 0 thì XÓA key), `missing_ingredients()`, `learn_recipe()` (mặc định chưa học — Cô Tư dạy "che-xe-day" sau quest đầu), `tool_behaviour()` 4 tool × 3 bậc từng chữ đúng C#, `apply_result()` (tool chỉ tăng bậc, item đếm quà), `craft_current()` trả `{ok, reason}` (`khong-co-cong-thuc`/`chua-hoc-cong-thuc`/`thieu-nguyen-lieu`), `guide_hint_for_recipe()` gợi ý Sổ Tay, `bind_materials()` dùng chung túi với `PxbHotspot` (Dictionary gán theo tham chiếu), `data()`/`from_data()` (bỏ công thức lạ + bậc tool lạ khi khôi phục). |
| `tests/g2_inventory_crafting_test.gd` (78 mục) | Kiểm tra headless riêng: catalog 4 món + giá/buff, add stackable/all-or-nothing, use trừ 1 + không có đồ chặn, buff đúng khung catalog + cộng dồn + hết khung hết buff (khung khác giữ nguyên), save round-trip; 3 công thức + nguyên liệu đúng C#, học công thức, craft tĩnh (trừ đúng số, xóa key 0, thiếu đồ không trừ), craft_current (chưa học/thiếu/đủ + applied + last_craft), tool 4×3 từng chữ + bậc lạ/chuỗi bậc, apply_result chỉ tăng, hint Sổ Tay, save round-trip + bỏ dữ liệu bẩn, túi chung Hotspot↔Crafting (nhặt hs-cho-sang → la-chuoi 2 → chế quà tặng → cả hai túi cùng trống key). |

## 2f. Verify thật đợt này (19/11 ~21:50)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 4 file (balance sửa + 2 script mới + test) | PASS, exit 0 (sau `--headless --import` 1 lần để đăng ký class mới) |
| G2 Inventory+Crafting selftest | **78/78 PASS** |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot selftest | **56/56 + 37/37 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~7s; `index.wasm` 39,5 MB, `index.pck` 959 KB (`strings index.pck` thấy `pxb_inventory`/`pxb_crafting`) |
| HTTP 200 | `index.html/js/wasm/pck` đủ 4 file (cổng 8142) |

## 2g. Khác biệt port JS/C# → GDScript đợt này (PROVISIONAL, cần GDD chốt)

**Inventory:**
1. **Không có plugin PXB_Inventory.js** — nguồn duy nhất là `Inventory.cs`; túi đồ MV dùng `$gameParty` + túi nguyên liệu chung với Hotspot. Port theo C#.
2. **Entry 0:** C# giữ entry 0 sau khi dùng hết món cuối (`Count` vẫn 0); port giữ nguyên, không xóa key (khác Crafting).
3. **Buff khung catalog:** `use()` giữ tham số `current_frame` cho API gọi nhưng không dùng để quyết khung buff (bug đã sửa 18/11 trong C#).

**Crafting:**
1. **Tên sản phẩm:** `PxbBalance.RECIPES` chỉ giữ needs/result/unlock; `result_name()` lấy từ bảng `RESULT_NAMES` trong file này (đúng fallback của JS).
2. **Túi chung:** JS dùng `$gameSystem.pxbMaterials` chung Hotspot/Crafting; Godot dùng `bind_materials(hotspot.materials)` — cùng một Dictionary theo tham chiếu (test chứng minh nhặt → chế → cả hai túi cùng trống key).
3. **"item:qua-tang" chưa có Item trong data/Items.json** — chỉ đếm trong `crafted_items`, chưa cộng vào `PxbInventory` (PROVISIONAL, như JS).
4. **Chỉ có công thức bậc 1** — chưa có công thức chế tool bậc 2/3 (C#/JS cũng vậy); công thức nâng cấp công cụ là việc PXB_Tools / GDD chưa chốt.
5. **Chế tạo là cổng tiến trình nhưng chưa nối mở khu** — `tools` chỉ ghi nhận; mở khu do PxbStory/PxbHotspot giữ.

## 2b. File mới đợt này (G2 bước 2, 19/11 ~20:45)

| File | Nội dung |
|---|---|
| `scripts/pxb_jobs.gd` (`PxbJobs`, 358 dòng) | Port `PXB_Jobs.js` / `Jobs.cs`: `pay_per_shift` (cơ bản × hệ số chỉ số chính max(0,5; 1,0+(stat−50)×0,01) × khung tốt × cung–cầu, floor), `work_shift`, `shifts_left`/`can_take_shift` (quota tuần 14), `roll_supply_demand`/`get_demand`/`set_demand`, `reset_week`/`ensure_week`, `take_exam`/`grant_extra_attempt`/`has_cert`, `data()`/`from_data()`. Số lấy từ `PxbBalance` — không hardcode lại. |
| `scripts/pxb_hotspot.gd` (`PxbHotspot`, ~360 dòng) | Port `PXB_Hotspot.js` / `Exploration.cs`: bảng 5 hotspot slice (khu 1/2/17/18, theo `Exploration.cs`), `explore()` trả `{ok, reason, material_id, amount}` (`ok`/`wrong-frame`/`already`), reset sang ngày mới, `has_visited_today`, `can_fast_travel` (chỉ khu đã mở, 1..18), `guide_hint` theo khu + mục tiêu, sparkle (màu/độ sáng/scale, minTouchPt 44), `data()`/`from_data()`. |
| `tests/g2_jobs_test.gd` (233 dòng) | Kiểm tra headless riêng 56 mục: lương 3 nghề, khung tốt +25% (187.500/225.000), hệ số chỉ số (100→1,5×, 0→sàn 0,5×), thiếu +30%/bão hòa −15%, kết hợp 365.625, quota 14 (ca 15 chặn `het-quota`, ví/EXP không đổi), EXP +10/ca, vòng xoay cung–cầu tuần 1–4, `reset_week` giữ chứng chỉ, thi (phí/không đủ tiền/hết lượt/mua thêm/trượt mất phí/đậu cấp chứng chỉ), `data()`/`from_data()`. |
| `tests/g2_hotspot_test.gd` | Kiểm tra headless riêng 37 mục: nhặt đúng khung ok + cộng vật liệu, sai khung `wrong-frame` (không cộng đồ, nhặt lại đúng khung vẫn được), lần 2 cùng ngày `already`, sang ngày mới nhặt lại được, `has_visited_today`, `can_fast_travel` chặn khu chưa mở + ngoài 1..18, `guide_hint` đúng NPC theo khu, sparkle (màu #E0A800, độ sáng 0,25/1,5/0,8, scale, minTouchPt 44), `data()`/`from_data()` round-trip + bỏ hotspot lạ. |

## 2c. Verify thật đợt này (19/11 ~20:45)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 2 script mới | PASS, exit 0 (lần đầu fail vì class mới chưa có trong global class cache — chạy `--headless --import` 1 lần để đăng ký `.uid` rồi pass; `.uid` không push theo quy ước cũ) |
| G2 Jobs selftest | **56/56 PASS** |
| G2 Hotspot selftest | **37/37 PASS** |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0 |
| Export web | exit 0, ~9s; `index.wasm` 39,5 MB, `index.pck` 937 KB (`strings index.pck` thấy `pxb_jobs`/`pxb_hotspot`) |
| HTTP 200 | `index.html/js/wasm/pck` đủ 4 file (cổng 8141) |

**Lỗi đã gặp và sửa trong đợt này:** `reset_week(2)` khi `day_number`
còn ở tuần 1 bị `ensure_week()` reset ngược về tuần 1 — sửa
`reset_week()` đồng bộ `day_number` về đầu tuần khi tuần yêu cầu khác
tuần hiện tại, rồi pass hết.

## 2d. Khác biệt port JS → GDScript đợt này (PROVISIONAL, cần GDD chốt)

**Jobs:**
1. **EXP/ca: cả JS lẫn C# đều KHÔNG định nghĩa.** `EXP_PER_SHIFT = 10`
   là số tạm do bước này đặt — CHƯA CHỐT, cần GDD chốt sau; test chỉ
   kiểm tra cơ chế cộng dồn.
2. **Không có giới hạn ca/ngày ở nguồn nào** — chỉ có quota TUẦN 14
   ca/nghề; port đúng quota tuần, không bịa thêm cap ngày.
3. Vòng xoay cung–cầu theo tuần chỉ có trong JS (PROVISIONAL); C# không
   có logic chọn nghề thiếu/bão hòa. Thi chứng chỉ chỉ có trong
   JS/GDD; C# không có.
4. Ví tiền: Godot chưa có PlayerProgress/`$gameParty` nên `gold` +
   `exp_total` tạm giữ trong `PxbJobs`, `paid` luôn true.
5. Số lương khớp tuyệt đối JS↔C#: 150k/180k/150k, quota 14,
   +25%/+30%/−15%, công thức hệ số — không lệch số nào.

**Hotspot:**
1. Chặn sai khung: JS `explore()` trả `wrong-frame`; C# `Explore()`
   KHÔNG kiểm tra khung (chỉ dùng BestFrame để sắp xếp + sáng hơn).
   Port theo JS (architecture-nadia §6: "chỉ có đồ đúng khung").
2. Reset sang ngày: C# chỉ reset khi `_currentDay` đã có giá trị (lần
   explore đầu sau load save thì giữ lượt đã lưu); JS reset bất cứ khi
   nào `game_day` khác. Port theo JS.
3. Rarity: C# không có trường hiếm; JS thêm `rarity: "thuong"` cho cả 5
   + màu cam hiếm #E07800 PROVISIONAL (chưa dùng).
4. Trả về: C# trả bool; JS trả `{ok, reason, material_id, amount}` —
   port theo JS.
5. `CanFastTravel`: C# kiểm tra khu trong `Districts.All`, JS kiểm tra
   1..18 — cùng kết quả.

## 2. File mới / đổi đợt này

| File | Nội dung |
|---|---|
| `scripts/pxb_balance.gd` (`PxbBalance`, autoload `PXB_Balance`) | Hằng số DUY NHẤT cho số đã chốt, port `PXB_Balance.js` / `GameBalance.cs`: thời gian kiểu C, 5 bậc học vấn, khóa ngắn hạn, cung–cầu, giấy phép/thi, công ty, xã hội, tài chính, thang nhà 6 bậc, rank Chương 5, 3 nghề slice, 3 công thức chế tạo. Số PROVISIONAL giữ nguyên nhãn. Helper `degree()`, `job_by_id()`, `recipe_by_id()`. |
| `scripts/pxb_stats.gd` (`PxbStats`, autoload `PXB_Stats`) | Port `PXB_Stats.js` / `Stats.cs`: 3 gốc Thể/Trí/Tâm 0..100 (setter tự kẹp), 4 trộn Kỷ/Dũng/Sáng/An Yên, `train()` đánh đổi (tổng không đổi), `create()` (tổng khởi đầu phải = trần 300), `with_values()` (chỉ test), `from_data()` / `data()` (để lưu save sau này), `default_data()` (chia đều trần). Autoload giữ bộ chỉ số hiện tại của người chơi. |
| `scripts/pxb_time.gd` (`PxbTime`, autoload `PXB_Time`) | Port `PXB_Time.js` / `TimeSystem.cs`: hàm tĩnh thuần `frame_index` / `frame_name` / `is_missed` (miss không phạt, chỉ hiển thị) / `minutes_into_frame` / `minutes_until_frame_end` / `day_progress` / `game_clock_minutes` / `game_clock_hour` / `game_weekday` / `is_saturday` / `is_saturday_event_time` / `should_trigger_saturday_event` / `day_length_frames` (= 108000) + đồng hồ chạy instance (`start_day`, `elapsed_minutes`, `current_frame_*`, `debug_set_elapsed` chỉ test). Ánh xạ giờ game PROVISIONAL như bản JS (ngày 1 = Thứ Hai; 20:00 giờ game = phút thật 25..26,25 ngày thứ 7). |
| `tests/g2_selftest.gd` | Kiểm tra headless 87 mục (xem §3). |
| `main.gd` | Bỏ `const FRAMES` / `FRAME_SECONDS` hardcode; khung + độ dài khung lấy từ `PxbBalance.FRAMES` / `PxbBalance.FRAME_MINUTES`, tên khung hiển thị qua `PxbTime.frame_name()`. Chỉ dùng class (không phụ thuộc autoload runtime) để `g1_playtest.gd` vẫn chạy được. |
| `project.godot` | Thêm `[autoload]` `PXB_Balance` / `PXB_Stats` / `PXB_Time` (tên autoload khác `class_name` để không đụng global class). |

## 3. Verify thật trên VM — kết quả

```bash
godot --headless --import
godot --headless --check-only --script <moi script>   # 5/5 khong loi
godot --headless --path . -s res://tests/g2_selftest.gd
godot --headless --path . -s res://tests/g1_selftest.gd
godot --headless --path . -s res://tests/g1_playtest.gd
godot --headless --quit-after 120                      # chay scene that
godot --headless --export-release Web ../godot-build/index.html
python3 -m http.server 8141 --bind 127.0.0.1           # curl tung file
```

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 5 script (3 mới + main.gd + test) | PASS, không lỗi |
| G2 selftest (Balance 30 + Stats 22 + Time 35 mục) | **87/87 PASS** |
| G1 selftest | **42/42 PASS** (không regression) |
| G1 playtest | **14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR |
| Export web | exit 0, ~8s; `index.wasm` 39,5 MB, `index.pck` 911 KB (đã chứa 3 script mới + autoload — kiểm bằng `strings index.pck`) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file; `GODOT_THREADS_ENABLED = false` |

**Ghi chú về 3 dòng ERROR trong log selftest:** là `push_error` có chủ
đích khi test `PxbStats.create()` với tổng khởi đầu sai (trả null thay vì
throw — GDScript không có exception; xem `pxb_stats.gd`). Test vẫn PASS.

**Lỗi đã gặp và sửa trong đợt này:** `PxbTime` dùng mốc `-1` làm cờ
"chưa start_day" — `debug_set_elapsed()` đặt mốc về quá khứ nên mốc âm,
bị hiểu nhầm là chưa start → elapsed luôn 0 (3/4 fail đầu là do đây).
Sửa: cờ riêng `_day_started: bool`. Bài học: không dùng giá trị mốc
thời gian làm cờ trạng thái.

## 4. Khác biệt port JS → GDScript (ghi để khỏi thắc mắc sau)

1. **Không có exception:** `create()` sai tổng trả `null` + `push_error`
   thay vì `throw` như JS. Mọi nơi gọi `create()` phải kiểm tra null.
2. **Autoload ≠ class:** script có `class_name PxbBalance` nhưng autoload
   đăng ký tên `PXB_Balance` (khác nhau để không đụng global class).
   Code game dùng `PxbBalance.HANG` / `PxbTime.ham_tinh()` (class, luôn
   có) hoặc `PXB_Stats` (autoload instance, chỉ có khi chạy scene thật).
3. **Setter kẹp:** `the`/`tri`/`tam` là property có setter `clampi`
   0..`STAT_MAX` — gán trực tiếp cũng kẹp, như JS `Object.defineProperty`.
4. **Số nguyên:** phí/tiền dùng `int` (tới 100 tỉ vừa trong int 64-bit);
   lãi 0,5% là `float` 0.005 như `GameBalance.cs` (`double`).

## 5. Giới hạn — nói thẳng

1. **Chưa chạy thử trong trình duyệt thật** (VM không có Chromium/
   Firefox/Playwright). Server http://127.0.0.1:8141/ đã tắt sau khi curl
   xong; parent chạy lại `python3 -m http.server 8141` trong
   `src/godot-build/` rồi mở bằng browser task.
2. **Chưa có gameplay mới nhìn thấy được:** Balance/Stats/Time là hệ nền
   — HUD chưa hiện chỉ số, chưa làm ca/chế tạo. Việc nhìn thấy được đầu
   tiên của G2 là bước Jobs (làm 1 ca, nhận lương, đúng khung tốt +25%).
3. **Chưa có save:** `PxbStats.data()` / `from_data()` đã sẵn sàng cho
   bước SaveCloud, nhưng chưa có nơi nào lưu/load thật.

## 2h. File mới đợt này (G2 bước 4, 19/11 ~22:50)

| File | Nội dung |
|---|---|
| `scripts/pxb_economy.gd` (`PxbEconomy`, ~330 dòng) | Port `Economy.cs` / `PXB_Economy.js`: catalog 17 món (6 nhà / 6 xe / 2 điện thoại / 3 quần áo, 3 dòng chỉ số mỗi món), ví riêng (money/savings/credit_score 100), `total_assets()`, lãi 0,5%/tháng game (30 ngày/tháng), gửi/rút tiết kiệm, `buy()` trả `{ok, fame_gained, reason}` (nhà hoặc xe sang → Danh vọng +50; phòng trọ thuê tháng, fame 0 — nhánh return sớm đúng C#), `auction_seller_receives()` (phí 5%, cắt phần lẻ), `barter()`, `split_assets()` (chia đôi), `set_bonus()` (đủ 3 món/set → +10 Danh vọng/+5 An Yên), `passes_director_dress_code()` (chỉ Clothes set Công sở/Sang trọng — xe Sang trọng KHÔNG tính), 4 hàm bị chặn LUÔN false (`cash_out`/`lend_with_interest`/`gamble`/`buy_with_real_money`), `data()`/`from_data()` (bỏ id món lạ). Giá nhà lấy từ `PxbBalance`; giá + chỉ số xe/điện thoại/quần áo PROVISIONAL theo `Economy.cs` (chưa có trong GameBalance — như JS giữ bảng trong plugin). |
| `scripts/pxb_education.gd` (`PxbEducation`, ~330 dòng) | Port `PXB_Education.js` (không có C# riêng): 5 bậc học từ `PxbBalance.DEGREES`, `can_enroll()`/`enroll()` (lý do chặn `khong-co-bang`/`da-co-bang`/`dang-hoc`/`chua-du-tri`/`can-mentor`/`khong-du-tien`, đúng thứ tự JS), `study_progress()`/`check_graduation()` (tốt nghiệp cộng EXP + Danh vọng vào `pending_exp`/`pending_fame` để event áp), `enroll_short_course()`/`short_course_progress()`/`check_short_course_graduation()` (4 chỉ số phụ, 3–7 ngày, 2–10 triệu, +10 vào `pending_stat_gain`), `scholarship_eligible()` (Trí ≥ 60 + tiền < 20tr → chỉ xét, không tự miễn phí), `seats_per_course()` (20–30), `register_order()`/`set_mentor()`, `data()`/`from_data()` (bỏ bằng/khóa/chỉ số lạ). Học song song 1 bằng chính + 1 khóa ngắn hạn (2 slot riêng). |
| `tests/g2_economy_education_test.gd` (92 mục) | Kiểm tra headless riêng: catalog 17 món + giá/chỉ số, ví + gửi/rút + lãi 0,5% (30/60 ngày, 29 ngày = 0, tiết kiệm 0 = 0), mua (món lạ/không đủ tiền/phòng trọ fame 0 + quirk tổng tài sản/chung cư +50/xe sang +50/xe máy cũ +0), đấu giá 1tr → 950k + cắt lẻ 999999 → 949999, barter đổi/thiếu đồ, chia tài sản, set bonus 1 set → 10/5 và 2 set → 20/10, dress-code (áo dài false, xe sang false, bộ công sở true), 4 hành vi bị chặn luôn false + state không đổi, save round-trip + bỏ dữ liệu bẩn; 5 bậc học + tra cứu theo index/tên, 6 lý do chặn đăng ký, đăng ký (ngày 1 → hết ngày 31, phí 0, charged false), tốt nghiệp THPT/Cao đẳng đúng ngày + pending EXP 500, khóa ngắn hạn (5 lý do chặn, học song song, tốt nghiệp +10), học bổng 4 trường hợp, ghế 20–30, register_order tăng dần, save round-trip + bỏ dữ liệu bẩn. |

## 2i. Verify thật đợt này (19/11 ~22:50)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 3 file (2 script mới + test) | PASS, exit 0 (sau `--headless --import` 1 lần để đăng ký class mới) |
| G2 Economy+Education selftest | **92/92 PASS** (lúc đầu 90/92: 1 lỗi port — `buy("phong-tro")` rơi vào nhánh tính Danh vọng, thiếu return sớm đúng C#; 1 lỗi test — chia tài sản tính nhầm tổng sau khi gửi tiết kiệm; sửa xong pass hết) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot / Inventory+Crafting selftest | **56/56 + 37/37 + 78/78 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR |
| Export web | exit 0, ~8s; `index.wasm` 39,5 MB, `index.pck` 987 KB (`strings index.pck` thấy `pxb_economy`/`pxb_education`, 10 lần) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8143) |

**Lỗi đã gặp đợt này:** export web FAIL lần đầu vì `rm -rf ../godot-build`
trước đó — export preset Web KHÔNG tự tạo thư mục đích (báo
"Project export for preset Web failed"). Sửa: `mkdir -p ../godot-build`
trước khi export. Bài học: không xóa thư mục build trước khi export;
nếu cần build sạch thì tạo lại thư mục rồi mới export.

## 2j. Khác biệt port JS/C# → GDScript đợt này (PROVISIONAL, cần GDD chốt)

**Economy:**
1. **owned lưu id món** (`Array[String]`) thay vì object `OwnedItem`
   — tra cứu đầy đủ qua `get_item()`; `data()`/`from_data()` gọn và
   không lệch object khi load save.
2. **Quirk phòng trọ giữ nguyên:** thuê 2tr/tháng nhưng vẫn cộng 2tr
   vào tổng tài sản (đúng C#/JS — xem ghi chú đầu file).
3. **Giá xe/điện thoại/quần áo PROVISIONAL** — chưa có trong
   GameBalance; khi GDD chốt bảng thì sửa `pxb_economy.gd` (catalog)
   + `Economy.cs` + JS cùng lúc (không sửa `PxbBalance` vì số này
   chưa từng nằm ở đó).
4. **Ví tiền:** Godot chưa có PlayerProgress/`$gameParty` nên ví tạm
   giữ trong `PxbEconomy` (như `PxbJobs.gold`); khi port
   PlayerProgress thì ví chuyển sang đó.

**Education:**
1. **Tiền học phí KHÔNG tự trừ:** JS trừ khỏi `$gameParty` khi có
   core MV; Godot chưa có ví chung nên `enroll()`/
   `enroll_short_course()` trả `charged = false` + `fee_paid` để
   event/caller tự trừ; kiểm tra tiền dùng tham số `gold` (`-1` =
   bỏ qua kiểm tra, như JS khi chưa có core).
2. **Tốt nghiệp không tự cộng EXP/Danh vọng/chỉ số phụ** — chỉ ghi
   vào `pending_exp`/`pending_fame`/`pending_stat_gain` để event áp
   (như JS; chưa có hệ EXP/Danh vọng chung trong Godot).
3. **Ngày game:** `day_number` là biến instance (mặc định 1), event/
   game loop gán khi ngày đổi — JS đọc `$gameSystem.pxbDayNumber`.
4. **Học lại bằng thấp hơn bị chặn** (PROVISIONAL — GDD chưa chốt có
   được học nhảy bậc / học lại bằng thấp hơn không).

## 6. Bước tiếp theo — G2 bước 5 (Social/Titles/Story/PhoneHub/MarketBattle/Online/SaveCloud)

1. Browser-verify G2 bước 4 (mở link trên, xem HUD Ngày/Khung vẫn đổi
   đúng, không lỗi console).
2. Nối gameplay vào `main.gd` để các hệ G2 nhìn thấy được (hiện chỉ có
   logic + test headless): nút "Làm ca" ở khu + "Nhặt" hotspot +
   "Chế tạo" (Jobs/Hotspot/Inventory/Crafting) + cửa hàng / ví /
   "Đăng ký học" (Economy/Education). Đây là việc UI đầu tiên của G2 —
   làm sau khi port xong hết các hệ nền, hoặc làm ngay bước 5 nếu cần
   demo chơi được.
3. G2 bước 5 (cuối): Social → Titles/Story → PhoneHub → MarketBattle
   (luật chờ chủ duyệt) → Online/SaveCloud (xem §1). Sau đó G3: đủ 18
   khu (Map003–014 đã có data MV, Map015–018 mới).
