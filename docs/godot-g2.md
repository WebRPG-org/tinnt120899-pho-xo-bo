# Godot G2 — Port 17 plugin PXB → GDScript (19/11/2026)

> **Kết luận: G2 bước 5/5 (phần B, PhoneHub) XONG (mức headless, 20/11 ~00:50).**
> Thêm hệ điện thoại: `PxbPhoneHub` (9 tab đúng thứ tự GDD Mục 2,
> open/close/toggle/select_tab, notify + số chưa đọc, signal
> tab_changed/open_changed đúng thứ tự + quirk C#/JS, save round-trip
> + bỏ dữ liệu bẩn). Selftest mới **66/66 PASS**, G2 cũ 87/87 +
> Jobs 56/56 + Hotspot 37/37 + Inventory/Crafting 78/78 +
> Economy/Education 92/92 + Social/Titles/Story 102/102 + G1 42/42
> + playtest 14/14 vẫn PASS (không regression), scene chạy 120 frame
> exit 0, export web exit 0 (~8s), http.server 200 đủ 6 file.
> **Chưa kiểm chứng bằng trình duyệt thật** — như G0/G1/G2 bước 1–5,
> VM không có Chromium/Firefox. Tổng G2: 13/17 plugin → 13 hệ GDScript.
> Còn lại bước 5 phần B: MarketBattle (luật chờ chủ duyệt) →
> Online/SaveCloud.
>
> **Cập nhật 20/11 ~02:45 — UI wiring phần 1 XONG:** Jobs + Hotspot +
> Crafting + Stats đã nối vào scene thật (`main.gd`): nút "Việc làm"
> làm ca nhận lương thật, nhặt hotspot qua `PxbHotspot`, chế tạo thật
> qua `PxbCrafting` (Cô Tư/Anh Hải dạy công thức), HUD ví/chỉ số.
> Test mới **37/37 PASS**, toàn bộ test cũ vẫn PASS, export web exit 0.
> Phần 2 tiếp theo: PhoneHub + SaveCloud + Economy/Education +
> Social/Titles/Story + Tools + Online.
>
> G2 bước 5/5 (phần A) XONG trước đó (xem lịch sử file): 3 hệ
> `PxbSocial` + `PxbTitles` + `PxbStory`, selftest 102/102 PASS.
>
> G2 bước 4/5 XONG trước đó (xem lịch sử file): 2 hệ `PxbEconomy` +
> `PxbEducation`, selftest 92/92 PASS.
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
| 4 | `PXB_Social` → Social; `PXB_Titles` / `PXB_Story` → Titles/Story | ✅ XONG đợt này (xem §2k) |
| 4 | `PXB_PhoneHub` → PhoneHub (CanvasLayer, 9 tab) | ✅ XONG đợt này (xem §2n) |
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

## 2k. File mới đợt này (G2 bước 5 phần A, 19/11 ~23:50)

| File | Nội dung |
|---|---|
| `scripts/pxb_balance.gd` (sửa) | Thêm 9 hằng cốt truyện ĐÃ CHỐT từ `PlayerProgress.cs`: `CHAPTER2_TRI_MIN` 40, `CHAPTER2_FAME_MIN` 200, `CHAPTER4_HELP_QUESTS_MIN` 3, `CHAPTER5_TRI_MIN` 60, `CHAPTER5_FAME_MIN` 500, `ENDING_HOC_GIA_TRI_MIN` 90, `ENDING_HOC_GIA_FAME_MIN` 1500, `RANK_AT_RISK_FAME_MAX` 100, `RANK_AT_RISK_AN_YEN_MAX` 30 (tài sản 10/100 tỉ + An Yên 80 đã có sẵn: `DIRECTOR_ASSETS_VND` / `SUPER_RICH_ASSETS_VND` / `FAMILY_ENDING_AN_YEN`). |
| `scripts/pxb_social.gd` (`PxbSocial`, ~380 dòng) | Port `PXB_Social.js` / `Social.cs`: 7 kind + 6 stage (string, JSON-safe), `create_relationship()` (thân thiết khởi đầu 20), `is_deep()`, `interact()` (+5, kẹp 0..100), `apply_neglect()` (−10/mỗi 7 ngày, KHÔNG cập nhật ngày — quirk C#), `advance_stage()` (HenHo ≥ 50, DinhHon từ HenHo ≥ 70, Cuoi từ DinhHon ≥ 80, KHÔNG kiểm Kind — quirk C#), `break_up()`, book instance (`relations` + `marriages`): `add_rel()` (trùng/giới hạn 3 sâu/1 bạn thân → false), `deep_count()`, `has_best_friend()`, `has_supporter()` (sâu + thân thiết ≥ 50), `apply_support_bonus()` (+20%), `apply_solo_penalty()` (−40%), `check_group_dissolved()` (7 ngày không họp), `divorce()` (chỉ Spouse + Cuoi), `record_marriage()`/`is_married_to()`, `apply_neglect_all()`, `seed_slice()` (NPC "Bạn thân" tạm), `data()`/`from_data()` (bỏ kind/stage lạ, kẹp thân thiết, bỏ trùng). |
| `scripts/pxb_titles.gd` (`PxbTitles`, ~230 dòng) | Port `PXB_Titles.js` / `TitleConflict.cs`: `BLOCKED_BY` đúng y 7 dòng C#, `is_blocked()` chặn 2 chiều + không phân biệt hoa/thường + null-safe (quirk Kẻ Lừa Đảo chỉ chặn "Luật Sư Chính Trực", KHÔNG chặn "Luật Sư Bào Chữa"), `alignment_of()` (Tà → "Ta", Chính → "Chinh", cả hai/không có → "TrungLap"), `add_title()`/`remove_title()`/`has_title()`/`can_take_job()`, `can_redeem()`/`redeem()` (chỉ khi phe Tà, xóa mọi danh hiệu phe Tà), `alignment` tự cập nhật sau mỗi thay đổi, `data()`/`from_data()` (bỏ title bẩn/trùng, tính lại alignment). |
| `scripts/pxb_story.gd` (`PxbStory`, ~230 dòng) | Port `PXB_Story.js` / `PlayerProgress.cs`: 5 chương + tên tiếng Việt, 6 ending, `can_open_chapter()` (ch.2 Trí 40/Danh vọng 200; ch.3 luôn true; ch.4 ≥ 3 quest + quan hệ thân thiết; ch.5 Trí 60/Danh vọng 500/tài sản 10 tỉ; chương lạ → false), `suggest_ending()` thứ tự ưu tiên cứng SieuGiau → GiamDoc → HocGia → GiaDinh → TuDo → ChuaMo, `rank_at_risk()` (Danh vọng < 100 HOẶC An Yên < 30), `advance_chapter()` (chỉ +1, guard ch.3 cần đã qua ch.2), `record_help_quest()`, `pass_chapter3()` (chỉ ở ch.3), `set_ending()` (chỉ 6 giá trị), `suggest_ending_now()` (gợi ý + lưu), `data()`/`from_data()` (kẹp chương 1..5, ending lạ → ChuaMo, unlocked sạch + luôn chứa chương hiện tại). Ngưỡng đọc từ `PxbBalance`, không hardcode lại. |
| `tests/g2_social_titles_story_test.gd` (102 mục) | Kiểm tra headless riêng: Social (tạo/mặc định, interact +5/kẹp 100, bỏ bê <7 ngày = 0 / 7 ngày −10 / 14 ngày −20 / gọi 2 lần cùng ngày trừ 2 lần / kẹp 0, stage 3 ngưỡng + chuỗi, quirk Spouse đi HenHo→Cuoi, break_up, book: trùng/3 sâu/bạn thân duy nhất/hội bạn không tính sâu, supporter 50 vs 49, bonus 100→120, solo 100→60, tan nhóm 7 ngày, ly hôn 3 trường hợp, hôn nhân, seed_slice, bỏ bê toàn sổ, save round-trip + bỏ dữ liệu bẩn); Titles (chặn xuôi/ngược 7 dòng, không phân biệt hoa/thường, quirk Kẻ Lừa Đảo, không xung đột, null-safe, add/remove/has/can_take_job, alignment 4 trường hợp, redeem chỉ phe Tà + xóa đúng phe Tà, save + bỏ dữ liệu bẩn); Story (mở 5 chương từng ngưỡng + chương lạ, advance cả chuỗi 1→5 + fail từng cửa, pass_chapter3, help quest đếm, thứ tự ưu tiên ending 8 trường hợp, rank_at_risk 4 trường hợp, set_ending, suggest_ending_now lưu state, save + bỏ dữ liệu bẩn). |

## 2l. Verify thật đợt này (19/11 ~23:50)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 5 file (balance sửa + 3 script mới + test) | PASS, exit 0 (sau `--headless --import` 1 lần để đăng ký class mới) |
| G2 Social+Titles+Story selftest | **102/102 PASS** (lần đầu đã pass hết; 1 lỗi tính tay trong test đã sửa trước khi chạy: bỏ bê 99 ngày = 14 bước × 10 = 140, không phải 120) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education selftest | **56/56 + 37/37 + 78/78 + 92/92 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR |
| Export web | exit 0, ~8s; `index.wasm` 39,5 MB, `index.pck` 1019 KB (`strings index.pck` thấy `pxb_social`/`pxb_titles`/`pxb_story`, 15 lần) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8144) |

## 2m. Khác biệt port JS/C# → GDScript đợt này (PROVISIONAL, cần GDD chốt)

**Social:**
1. **Hàm tĩnh trên book Dictionary:** JS dùng hàm module nhận book object thuần; GDScript dùng hàm tĩnh `*_in_book(book)` + hàm instance bao quanh book của node — cùng 1 logic, test gọi được cả 2 đường.
2. **Không có `$gameSystem`:** JS giữ state trong `$gameSystem.pxbSocial` để đi theo save MV; Godot giữ trong instance `PxbSocial` + `data()`/`from_data()` (save thật là việc SaveCloud, bước 5 phần B).
3. **Số PROVISIONAL giữ nguyên nhãn** (xem header file): thân thiết khởi đầu 20, +5/lần, −10/bước, ngưỡng 50/70/80, supporter ≥ 50, solo 40%, tan nhóm 7 ngày, tối đa 3 sâu — chỉ ngưỡng 7 ngày / +20% / 30–50% là số chốt (đọc từ `PxbBalance`).
4. **Quirk giữ đúng C#:** `apply_neglect()` không cập nhật ngày; `advance_stage()` không kiểm Kind; `divorce()` chỉ Spouse + Cuoi.

**Titles:**
1. **Không có `$gameSystem`:** như Social — state trong instance + `data()`/`from_data()`.
2. **So sánh không phân biệt hoa/thường:** C# dùng `StringComparer.OrdinalIgnoreCase`; GDScript dùng `String.to_lower()` — tiếng Việt có dấu lower đúng (vd "Tướng Cướp" → "tướng cướp").
3. **Phe Chính/Tà PROVISIONAL** — suy ra từ bảng chặn, GDD chưa liệt kê; `alignment` là bản sao tính sẵn, nguồn sự thật là `titles`.

**Story:**
1. **Không có số PROVISIONAL:** mọi ngưỡng đều ĐÃ CHỐT; 9 ngưỡng chương/ending chưa từng nằm trong `GameBalance.cs` nên đã thêm vào `PxbBalance` đợt này (xem §2k) thay vì hardcode trong file story.
2. **Không có `$gameSystem` / PlayerProgress:** như Social — state trong instance + `data()`/`from_data()`; chỉ số người chơi (Trí/Danh vọng/tài sản/An Yên) truyền vào làm tham số, event lấy từ `PxbStats`/`PxbEconomy` khi nối UI.
3. **Lệch C# so với GDD giữ đúng C#** (xem header file): ch.2 không có đường riêng bằng Cao đẳng; ch.5 Học giả không kiểm bằng Tiến sĩ; ch.5 Gia đình không kiểm rank Trung lưu.

## 2n. File mới đợt này (G2 bước 5 phần B — PhoneHub, 20/11 ~00:50)

| File | Nội dung |
|---|---|
| `scripts/pxb_phonehub.gd` (`PxbPhoneHub`, ~250 dòng) | Port `PXB_PhoneHub.js` / `PhoneHub.cs`: 9 tab đúng thứ tự GDD Mục 2 (id kebab-case + tên có dấu đầy đủ: Danh bạ / Tin nhắn, Ngân hàng, Bản đồ, Việc làm, Chợ, Học tập, Sức khỏe, Xã hội, Cài đặt), `open(tab)` / `close()` / `toggle()` / `select_tab(tab)` (mở tab thì đánh dấu đã đọc), `notify(tab)` / `unread_count(tab)` / `total_unread()` (chấm đỏ), signal `tab_changed(tab_id)` / `open_changed(is_open)` thay cho event C# (UI kết nối lại sau mỗi lần load), `PHONE_KEY_CODE = KEY_P` để lớp UI dùng (file này không tự bắt phím — đúng ranh giới PhoneHub.cs), `data()`/`from_data()` (bỏ tab lạ, kẹp số âm về 0, current_tab lạ → mặc định). Không dùng PxbBalance, không có số PROVISIONAL nào (PhoneHub.cs không có số cấu hình). |
| `tests/g2_phonehub_test.gd` (66 mục) | Kiểm tra headless riêng: 9 tab + thứ tự + tên có dấu + tab mặc định + PHONE_KEY_CODE, tab_list trả bản sao; open/close/toggle (mở ở tab mặc định, mở thẳng tab, close giữ tab, toggle mở lại đúng tab trước khi đóng, close khi đã đóng vẫn phát signal, open tab lạ vẫn mở + phát open_changed nhưng không đổi tab); select_tab (đúng tab hiện tại vẫn phát signal, tab lạ false + không phát); notify (cộng dồn theo tab, đếm cả khi đang đóng, tab lạ false, total); chuỗi signal đúng thứ tự mở → notify → đổi tab → đóng; hub mới có signal riêng; save round-trip + bỏ dữ liệu bẩn + from_data({}) reset. |

## 2o. Verify thật đợt này (20/11 ~00:50)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 2 file (script mới + test) | PASS, exit 0 (sau `--headless --import` 1 lần để đăng ký class mới) |
| G2 PhoneHub selftest | **66/66 PASS** (chạy đầu đã pass hết; đã sửa log sạch: free hub cuối test để không còn dòng `resources still in use` lúc thoát) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story selftest | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~8s; `index.wasm` 39,5 MB, `index.pck` 1.030.332 byte (`strings index.pck` thấy `pxb_phonehub`, 5 lần) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8145); `GODOT_THREADS_ENABLED = false` |

## 2p. Khác biệt port JS/C# → GDScript đợt này

**PhoneHub:**
1. **Event C# → signal GDScript:** `TabChanged`/`OpenChanged` thành `tab_changed`/`open_changed`; test kết nối Callable và đếm đúng thứ tự phát (open: tab_changed trước, open_changed sau).
2. **Không có `$gameSystem`:** JS giữ state trong `$gameSystem.pxbPhoneHub` để vào save MV; Godot giữ trong instance `PxbPhoneHub` + `data()`/`from_data()` (save thật là việc SaveCloud, bước 5 phần B sau).
3. **Phím P không móc ở đây:** JS `install()` gán `Input.keyMapper[80]` + `Scene_Map.update` kiểm tra phím; Godot không có keyMapper — phím P là việc của input map / `main.gd` khi nối UI (xem §6 bước 2). File này chỉ giữ hằng `PHONE_KEY_CODE = KEY_P` để lớp UI dùng.
4. **Không có số PROVISIONAL:** PhoneHub.cs không có số cấu hình nào nên port không đặt số tạm nào; tên tab "Sức khỏe" theo C# (GDD viết "Sức khoẻ", chỉ khác chính tả).
5. **Quirk giữ đúng C#/JS:** notify đếm cả khi đóng; select_tab/open luôn phát tab_changed kể cả đúng tab hiện tại; open tab lạ vẫn mở + phát open_changed; close luôn phát open_changed(false) kể cả đã đóng sẵn.

## 2q. File mới đợt này (G2 bước 5 phần B cuối — Tools/Online/SaveCloud, 20/11 ~02:05)

| File | Nội dung |
|---|---|
| `scripts/pxb_tools.gd` (`PxbTools`, 845 dòng) | Port `PXB_Tools.js`: 4 công cụ × 3 bậc (Xe Đẩy sức chở 5/10/20 + bậc 3 đi đường mưa; Đèn Soi bậc 2 thấy ẩn gần, bậc 3 thấy mọi hotspot + hiếm 1 khung/ngày; Sổ Tay gợi ý 3 mức chi tiết; Xẻng nhặt nhanh 1,0/0,75/0,5 + bonus 25% bậc 2 + hiếm 10% "da-quy" bậc 3); 12 câu ToolBehaviour đúng nguyên văn Crafting.cs; 8 công thức nâng cấp + 2 công thức nhận bậc 1 Sổ Tay/Xẻng (PROVISIONAL, quy tắc ×N); `can_upgrade`/`upgrade`/`can_acquire`/`acquire` trả reason rõ, thất bại không trừ đồ; đồng bộ 2 chiều + mirror với PxbCrafting, ủy quyền gợi ý cho PxbCrafting/PxbHotspot/PxbTime qua `bind_*()`; `data()`/`from_data()` (bỏ dữ liệu bẩn), `reset_state()` (giữ nguyên túi, đúng JS), signal `tool_changed`. |
| `scripts/pxb_online.gd` (`PxbOnline`, 566 dòng) | Port `PXB_Online.js`: hằng PROVISIONAL (base URL `http://localhost:5000`, timeout 5000 ms, outbox tối đa 50, key đã gửi tối đa 200, cache số dư 60 giây); `health_check()` / `balance_of()` qua endpoint thật `/health`, `/ledger/balance/{id}`; `gift()` qua `/ledger/gift` + IdempotencyKey (trùng key → `trung-idempotency-key`, offline → outbox + `offline-da-luu-outbox`, 409 → coi như xong, outbox đầy → `outbox-day`); `flush_outbox()` trả {sent, kept, failed}; trade/đấu giá/công ty=guild LUÔN trả `server-chua-co-endpoint` (8 hàm); signal `online_changed` / `outbox_changed`; `data()`/`from_data()` (bỏ dữ liệu bẩn, cắt outbox >50 và key >200). HTTP qua HTTPRequest thật (bất đồng bộ, timeout 5s), property `http_transport: Callable` để test chích stub. |
| `scripts/pxb_savecloud.gd` (`PxbSaveCloud`, 488 dòng) | Port `PXB_SaveCloud.js`: hằng PROVISIONAL (tối đa 3 slot, SAVE_VERSION "0.1.0-skeleton", endpoint dự kiến `/save/upload` + `/save/download` — server chưa có); login/logout (tài khoản tùy chọn, chưa có auth thật); `build_save_json` / `encode_save` / `decode_save` (nén DEFLATE + base64, tiền tố `pxb1:` + 4 byte kích thước gốc; không nén được → JSON thô, `compressed:false`); save/load local slot 1–3 qua file `user://pxb_savecloud_<slot>.save` (ghi lỗi → fallback bộ nhớ, `where:"memory"`; slot trống → `slot-trong`, save hỏng → `save-hong`); upload/download LUÔN trả `server-chua-co-endpoint` (chưa login → `chua-dang-nhap` trước); `sync_status()`; `data()`/`from_data()`, `reset_state()`. |
| `tests/g2_tools_test.gd` (155 mục) | Kiểm tra headless riêng: đủ 4 công cụ × 3 bậc, hành vi từng bậc khác nhau thật, nâng cấp đúng/sai điều kiện, 12 câu so chuỗi chính xác, gợi ý Sổ Tay 3 mức + ủy quyền, nhặt Xẻng theo roll cố định, đồng bộ/mirror/chung túi với PxbCrafting, save round-trip + dữ liệu bẩn, reset_state, signal. |
| `tests/g2_online_test.gd` (91 mục) | Kiểm tra headless riêng qua stub HTTP: hằng PROVISIONAL, base_url/set_base_url, health_check (ok + fail), balance_of + cache 60s, gift hợp lệ/không hợp lệ/thiếu id/trùng key/offline vào outbox/outbox đầy 50, flush_outbox (gửi được + 409 coi như xong + lỗi mạng giữ lại), 8 hàm no-endpoint, data()/from_data() round-trip + bỏ dữ liệu bẩn, reset_state. |
| `tests/g2_savecloud_test.gd` (69 mục) | Kiểm tra headless riêng: hằng PROVISIONAL, login/logout/thiếu account-id, build_save_json (game_day từ pxb_time), encode/decode round-trip (nén + thô + save hỏng + thiếu dữ liệu), save/load local slot 1–3 (round-trip giữ nguyên game_system, slot 0/4 → slot-khong-hop-le, slot trống → slot-trong, list_local_slots), apply_save, upload/download (chưa login → chua-dang-nhap; đã login → server-chua-co-endpoint + sync_status loi), sync_status sau save local, data()/from_data() + bỏ dữ liệu bẩn, reset_state. Test dọn file `user://` nó tạo sau khi xong. |

## 2r. Verify thật đợt này (20/11 ~02:05)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` 6 file mới (3 script + 3 test) | PASS, exit 0 (chạy với `--path src/godot` để nạp global class cache; check-only đơn file báo thiếu class là giả) |
| G2 Tools selftest | **155/155 PASS** (vượt mục tiêu ≥40; chạy lại lần 2 vẫn 0 FAIL) |
| G2 Online selftest | **91/91 PASS** (lần đầu 89/91 do 2 lỗi test — key camelCase + round-trip sau gift offline — đã sửa test, chạy lại PASS hết) |
| G2 SaveCloud selftest | **69/69 PASS** (chạy lại lần 2 vẫn 69/69; không còn file save sót trong app_userdata) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub selftest | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~10s; `index.wasm` 39,5 MB, `index.pck` 1.119.672 byte (chứa `pxb_online`, `pxb_savecloud`, `pxb_tools`, mỗi cái 5 lần) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8146); `GODOT_THREADS_ENABLED = false` |

## 2s. Khác biệt port JS → GDScript đợt này

**Tools:**
1. **Không lệch số nào:** 12 câu ToolBehaviour trong JS khớp từng chữ với `Crafting.cs`; chi phí nâng cấp JS khớp đúng quy tắc ×N trên cơ số C# (che-xe-day khung-sat 1 + banh-xe 2 + van-go 2 → bậc 2: 2/4/4, bậc 3: 3/6/6; che-den-soi sat-vun 2 + chai-nhua 2 → 4/4, 6/6). Giữ nguyên theo JS, không sửa số.
2. **Chỉ khác chính tả:** JS `TIER_NAMES` viết không dấu ("Tho"/"Kha"/"Tot"), bản GDScript dùng có dấu ("Thô"/"Khá"/"Tốt") theo quy ước `pxb_crafting.gd` + luật chữ trên màn hình đủ dấu — không đổi nghĩa.
3. **Ủy quyền plugin toàn cục JS → `bind_*()` tùy chọn:** JS gọi trực tiếp `PXB_Crafting`/`PXB_Hotspot`/`PXB_Time` toàn cục; GDScript dùng `bind_crafting()`/`bind_hotspot()`/`bind_time()` (không bind thì gợi ý/nhặt dùng fallback nội bộ, không crash).

**Online:**
1. **HTTP fetch (Promise) → HTTPRequest + `http_transport` chích được:** JS dùng `fetch` + Promise; GDScript dùng HTTPRequest bất đồng bộ (timeout 5s). Để test headless được, thêm property `http_transport: Callable` (mặc định rỗng = đường thật); test gán stub trả Dictionary đồng bộ, `await` hoàn thành ngay trong frame — không hardcode kết quả giả.
2. **Tên:** GDScript cấm trùng tên biến và hàm nên `base_url` là thuộc tính đọc trực tiếp (`node.base_url`), `set_base_url()` / `is_online()` là hàm.
3. **Quirk flush:** JS ghi chú flush "dừng gửi các món sau" khi lỗi mạng nhưng chuỗi Promise thật ra không kiểm tra cờ dừng; bản GDScript dừng thật (`break`) — kết quả {sent, kept, failed} giống hệt nhau, chỉ bớt lần gọi HTTP vô ích.

**SaveCloud:**
1. **localStorage → file `user://`:** Godot không có localStorage; save local ghi file `user://pxb_savecloud_<slot>.save` chứa phong bì JSON `{"compressed", "data"}`. Ghi file lỗi → fallback bộ nhớ trong, trả `where:"memory"` rõ ràng.
2. **LZString → DEFLATE + base64:** `encode_save` dùng `PackedByteArray.compress` (DEFLATE) + base64, tiền tố `"pxb1:"` + 4 byte little-endian kích thước gốc. Dữ liệu nén không có tiền tố `pxb1:` (vd save LZString bên JS) → `"thieu-lzstring"` rõ ràng, không giả vờ giải được.
3. **`$gameSystem` → dict truyền vào:** `build_save_json` nhận dict hệ thống truyền vào, `apply_save` chép field vào dict đích truyền vào; `gameDay` lấy từ `pxb_time.game_day`, rồi `gameDay`, rồi `game_day`, mặc định 1. `accountId` dùng `""` thay cho `null` của JS khi chưa đăng nhập.
4. **Stderr còn 1 dòng lỗi engine `decompress`** từ đúng 1 check cố tình đưa dữ liệu nén sai định dạng — đã được xử lý, check vẫn PASS; lỗi in ra từ bên trong `PackedByteArray.decompress`, không tránh được.

## 2t. File mới đợt này (G2 UI wiring phần 1 — nối Jobs/Hotspot/Crafting/Stats vào scene, 20/11 ~02:45)

| File | Nội dung |
|---|---|
| `main.gd` (sửa) | `_create_systems()`: tạo node con `stats` (ưu tiên autoload `PXB_Stats`, fallback `PxbStats.new()` khi chạy headless `-s` chưa có autoload), `jobs` (gán `stats`, `set_day_number`), `hotspot`, `crafting` (`bind_materials(hotspot.materials)`). `inventory` của Main trỏ tới `hotspot.materials` (cùng Dictionary — nhặt ↔ chế dùng chung túi thật). `_collect_hotspot()` nay gọi `hotspot.explore(id, day, khung)` thay logic G1 (lý do `ok`/`already`/`wrong-frame`/`unknown` giữ nguyên câu toast). `_interact()` craft → `_show_craft_dialogue()` (hiện needs + số đã có, nút "Chế tạo" → `craft_recipe()` trả dict `craft_current()`; chưa học → hiện unlock note). NPC Cô Tư / Anh Hải thêm lựa chọn dạy công thức (`che-xe-day` / `che-den-soi`, đúng unlock note trong Balance). Nút HUD "Việc làm" → `_show_jobs_dialogue()` (liệt kê 3 nghề + lương ca hiện tại + khung tốt + ca còn lại) → `work_job()` trả dict `work_shift()` (khung hiện tại + stats thật). HUD thêm `_hud_gold` ("Ví: …đ • EXP …") + `_hud_stats` ("Thể • Trí • Tâm") + `_fmt_vnd()` (150000 → "150.000"). `_advance_frame()` đồng bộ `jobs.set_day_number(day)`; bỏ `collected_today` (hotspot tự theo dõi lượt theo ngày). Map tên sự kiện craft → recipe_id qua `CRAFT_RECIPE_BY_NAME` (không sửa map data). |
| `tests/g2_ui_wiring_test.gd` (37 mục) | Chạy scene Main thật headless: HUD ban đầu (ví 0đ, chỉ số 100/100/100, túi trống), `_fmt_vnd` 3 trường hợp, làm ca Bán rong tuần 1 thiếu người 292.500đ + Shipper 270.000đ (Thể 100 ×1,5), quota 14 ca (ca 15 `het-quota`, không cộng tiền), nhặt hotspot (đúng khung / nhặt lại / sai khung), chế Đèn Soi (chưa học → thiếu đồ → đủ đồ chế xong, tool bậc 1, túi trừ đúng, HUD túi chỉ còn Lá Chuối ×2), chế Xe Đẩy chưa học bị chặn. |

## 2u. Verify thật đợt này (20/11 ~02:45)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` main.gd + test mới | PASS, exit 0 |
| G2 UI wiring selftest | **37/37 PASS** (lần đầu 32/37: test tính sai lương Bán rong — quên tuần 1 nghề thiếu người +30% cung–cầu, lương thật 292.500đ không phải 225.000đ; sửa test, chạy lại PASS hết) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud selftest | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 PASS** (không regression) |
| G1 selftest / playtest | **42/42 + 14/14 PASS** (không regression — playtest cũ vẫn qua với `_collect_hotspot` mới) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~9s; `index.wasm` 39,5 MB, `index.pck` 1.129.444 byte (`strings index.pck` thấy `pxb_jobs`/`work_job`, 9 lần) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8147); `GODOT_THREADS_ENABLED = false` |

## 2v. Khác biệt / lưu ý đợt này

1. **Stats 2 instance:** autoload `PXB_Stats` tồn tại trong game thật, nhưng Main vẫn tạo fallback `PxbStats.new()` khi chạy test `-s` (autoload chưa đăng ký kịp). Trong game thật Main dùng đúng autoload — không có 2 bộ chỉ số lệch nhau. Khi nối SaveCloud sẽ thống nhất đường lưu duy nhất qua autoload.
2. **Học công thức tại chỗ:** Cô Tư/Anh Hải dạy ngay trong dialogue NPC (đúng unlock note); quest đầu tiên "làm xong" chưa có hệ quest nên chưa kiểm tra điều kiện quest — PROVISIONAL, khi có PxbStory quest thì thêm điều kiện.
3. **Tiền chỉ ở PxbJobs:** ví hiển thị = `jobs.gold`; `PxbEconomy` có ví riêng nhưng chưa nối — khi nối Economy (phần 2) sẽ chuyển ví chung về một chỗ (xem §6 bước 2).

## 2w. File mới đợt này (G2 UI wiring phần 2 — PhoneHub + SaveCloud + Economy + Education + Social/Titles/Story + Tools + Online, 20/11 ~04:00)

| File | Nội dung |
|---|---|
| `main.gd` (sửa) | `_create_systems()` thêm 9 hệ phần 2 (PhoneHub / SaveCloud / Economy / Education / Social + seed_slice "Bạn thân" / Titles / Story / Tools bind túi chung + crafting + hotspot / Online). `fame` (Danh vọng) giữ ở Main vì PxbStats chưa có fame. Ví CHUNG là `jobs.gold`; `economy.money` chỉ là bản đồng bộ tạm trước/sau mỗi giao dịch (`_wallet_to_economy` / `_wallet_from_economy`). `_advance_frame()` sang ngày mới: đồng bộ `education.day_number`, bỏ bê quan hệ 1 lần/ngày, lãi tiết kiệm 0,5% khi sang tháng game (ngày 31/61…), `_check_graduations()` (tốt nghiệp cộng EXP vào `jobs.exp_total` + Danh vọng vào `fame` rồi xóa pending; khóa ngắn chỉ báo + notify vì chỉ số phụ chưa có API áp qua PxbStats). Phím P + nút HUD "Điện thoại (P)" (hiện số chưa đọc) mở panel 9 tab: Danh bạ (trò chuyện +5 thân thiết), Ngân hàng (gửi/rút 100k), Bản đồ (đi nhanh khu đã mở trong maps_data), Việc làm (lương + công cụ: nhận Sổ Tay/Xẻng, nâng cấp), Chợ (4 món rẻ nhất catalog + mua thật), Học tập (đăng ký 5 bậc — học phí tự trừ khỏi ví vì `charged` luôn false — + khóa ngắn mẫu Sáng tạo 3 ngày/2tr), Sức khỏe (luyện Thể/Trí/Tâm đổi nhau +5), Xã hội (chương + ending gợi ý + danh hiệu + lên chương + đổi phe), Cài đặt (lưu/tải slot 1–3, kiểm tra mạng, đồng bộ cloud báo đúng `server-chua-co-endpoint`/`chua-dang-nhap`). Save/Load: `_collect_system_data()` gom đủ 13 hệ + ngày/khung/fame → `savecloud.save_to_local`; load qua `load_from_local` + `_apply_save_data()` (Stats khôi phục tại chỗ qua `set_stat` để không lệch autoload; các hệ khác tạo mới qua `from_data()` tĩnh rồi thay node + bind lại túi/crafting/stats). |
| `tests/g2_ui_wiring2_test.gd` (71 mục) | Chạy scene Main thật headless: hệ phần 2 đã tạo + seed Bạn thân + Tools chung túi thật (đổi hotspot.materials thì tools thấy ngay); điện thoại mở/đóng/tab mặc định/đổi tab Chợ/notify + nút hiện (1)/mở tab xóa chưa đọc; mua Áo dài 2tr + thuê Phòng trọ 2tr + Xe đạp 0đ + Xe sang chặn thiếu tiền + gửi/rút tiết kiệm + rút vượt chặn; đăng ký THPT (0đ) tốt nghiệp ngày 31 + Cao đẳng 20tr tốt nghiệp ngày 91 (+500 EXP) + khóa ngắn Sáng tạo (+10 pending "sang"); trò chuyện Bạn thân 20→25; lên chương 2 (Trí 100); nhận Sổ Tay bậc 1 + nâng bậc 2 + Xe Đẩy phải chế; lưu slot 1 xuống file → đổi ví 999/ngày 9/Thể 50 → tải lại khôi phục đúng (ngày 1, ví 3tr, Thể 100, chương 2, Sổ Tay bậc 2, bằng Cao đẳng, thân thiết 25, Áo dài, tiết kiệm 500k) + sau load Tools vẫn chung túi; online ban đầu ngoại tuyến + outbox trống + upload chưa đăng nhập → `chua-dang-nhap`. Test tự xóa file save nó tạo. |

## 2x. Verify thật đợt này (20/11 ~04:00)

| Kiểm tra | Kết quả |
|---|---|
| `--check-only` main.gd + test mới | PASS, exit 0 (sửa 2 lỗi suy kiểu `:=` ở test: `advance_story_chapter()`/`interact_friend()` trả qua `_main` kiểu Node nên phải ghi rõ `: bool`) |
| G2 UI wiring2 selftest | **71/71 PASS** (chạy đầu đã pass hết) |
| G2 selftest cũ (Balance/Stats/Time) | **87/87 PASS** (không regression) |
| G2 Jobs / Hotspot / Inventory+Crafting / Economy+Education / Social+Titles+Story / PhoneHub / Tools / Online / SaveCloud selftest | **56/56 + 37/37 + 78/78 + 92/92 + 102/102 + 66/66 + 155/155 + 91/91 + 69/69 PASS** (không regression) |
| G1 selftest / playtest + UI wiring phần 1 | **42/42 + 14/14 + 37/37 PASS** (không regression) |
| Scene Main chạy 120 frame | exit 0, không ERROR/warning |
| Export web | exit 0, ~9s; `index.wasm` 39,5 MB, `index.pck` 1.158.900 byte (`strings index.pck` thấy `pxb_phonehub`/`pxb_savecloud`/`pxb_economy`, 15 lần) |
| HTTP 200 | `index.html/js/wasm/pck/audio.worklet.js/png` đủ 6 file (cổng 8148); `GODOT_THREADS_ENABLED = false` |

## 2y. Khác biệt / lưu ý đợt này

1. **Ví chung = `jobs.gold`:** `PxbEconomy` có ví riêng nhưng Main đồng bộ 2 chiều trước/sau mỗi giao dịch — không có 2 ví lệch nhau. Khi port PlayerProgress thì ví chuyển hẳn về đó (xem §2v).
2. **Tốt nghiệp khóa ngắn:** `pending_stat_gain` (+10 "sang") CHƯA áp vào đâu — PxbStats chỉ có `set_stat` cho 3 chỉ số gốc (Thể/Trí/Tâm), 4 chỉ số trộn (Kỷ/Dũng/Sáng/An Yên) là hàm tính sẵn, không set được. Cần API áp chỉ số phụ ở bước sau (hoặc GDD chốt cách tính).
3. **Khóa ngắn mẫu:** UI chỉ có 1 khóa cố định (Sáng tạo, 3 ngày, 2tr) — PROVISIONAL, để chứng minh luồng đăng ký/tốt nghiệp; danh mục khóa ngắn đầy đủ chưa có trong GDD.
4. **Lãi tiết kiệm tự động:** chỉ cộng khi sang tháng game (ngày 31/61…) với đúng 30 ngày — `apply_monthly_interest(30)`; không cộng dồn sai nếu F/bấm đổi khung nhiều lần trong ngày (chỉ chạy khi ngày đổi).
5. **Đi nhanh:** chỉ liệt kê khu có trong `maps_data` (hiện 1–2); khu 17/18 đã mở trong `unlocked_districts` nhưng chưa có data map nên không hiện nút đi — tránh `load_map` vào map rỗng.
6. **Upload cloud:** nút đồng bộ chỉ gọi `upload_save()` và báo đúng lý do (`server-chua-co-endpoint` khi đã đăng nhập, `chua-dang-nhap` khi chưa) — không giả vờ đã đồng bộ.
7. **Load save thay node:** `_replace_system` dùng `queue_free()` (hủy cuối frame) rồi `add_child` node mới ngay — node cũ còn trong cây tới cuối frame nhưng Main đã trỏ sang node mới; không nối signal nào vào các hệ nên không rò rỉ.

## 6. Bước tiếp theo — G2 xong (chỉ còn MarketBattle chờ chủ duyệt) + nối UI

1. Browser-verify G2 (mở link trên, xem HUD Ngày/Khung vẫn đổi
   đúng, không lỗi console).
2. Nối gameplay vào `main.gd` để các hệ G2 nhìn thấy được (hiện chỉ có
   logic + test headless): nút "Làm ca" ở khu + "Nhặt" hotspot +
   "Chế tạo" (Jobs/Hotspot/Inventory/Crafting) + cửa hàng / ví /
   "Đăng ký học" (Economy/Education) + quan hệ / danh hiệu / chương
   (Social/Titles/Story) + nút điện thoại mở hub 9 tab (PhoneHub —
   phím P + CanvasLayer) + dùng công cụ (Tools) + lưu/tải save
   (SaveCloud) + trạng thái online (Online). Đây là việc UI đầu tiên
   của G2 — làm ngay sau khi port xong hết các hệ nền.
   **Tiến độ 20/11 ~02:45 — phần 1 XONG:** Jobs + Hotspot + Crafting +
   Stats đã nối (nút "Việc làm", nhặt qua PxbHotspot, chế tạo thật,
   HUD ví/chỉ số; test mới 37/37). **Phần 2 XONG 20/11 ~04:00:**
   PhoneHub (phím P + panel 9 tab, nội dung + nút thật) + SaveCloud
   (lưu/tải slot 1–3, khôi phục đủ 13 hệ) + Economy (ngân hàng +
   chợ, ví chung jobs.gold) + Education (đăng ký 5 bậc + khóa ngắn +
   tốt nghiệp cộng EXP/Danh vọng thật) + Social/Titles/Story (trò
   chuyện +5, lên chương, ending gợi ý, đổi phe) + Tools (nhận Sổ
   Tay/Xẻng + nâng cấp) + Online (trạng thái + kiểm tra mạng +
   upload báo đúng lý do); test mới 71/71, toàn bộ test cũ PASS,
   export web exit 0. **Phần 3 tiếp theo (nếu cần trước G3):** áp
   `pending_stat_gain` khóa ngắn vào chỉ số phụ (cần API PxbStats)
   + danh mục khóa ngắn đầy đủ + mở khu 17/18 khi có data map.
3. G2 còn lại duy nhất: MarketBattle
   (luật chờ chủ duyệt — CHƯA port cho tới khi chủ duyệt luật, xem
   `docs/market-battle-design.md`). Sau đó G3: đủ 18 khu (Map003–014
   đã có data MV, Map015–018 mới).
