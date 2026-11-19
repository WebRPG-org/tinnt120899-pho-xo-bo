# Godot G2 — Port 17 plugin PXB → GDScript (19/11/2026)

> **Kết luận: G2 bước 2/5 XONG (mức headless).** Thêm 2 hệ gameplay:
> `PxbJobs` (làm ca, lương, quota tuần, thi chứng chỉ) +
> `PxbHotspot` (nhặt 1 lần/ngày đúng khung, di chuyển nhanh, gợi ý).
> Selftest mới **56/56 (Jobs) + 37/37 (Hotspot) PASS**, G2 cũ 87/87 +
> G1 42/42 + playtest 14/14 vẫn PASS (không regression), scene chạy
> 120 frame exit 0, export web exit 0 (~9s), http.server 200 đủ 4 file.
> **Chưa kiểm chứng bằng trình duyệt thật** — như G0/G1/G2 bước 1, VM
> không có Chromium/Firefox. Tổng G2: 5/17 plugin → 5 hệ GDScript.
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
| 2 | `PXB_Inventory` / `PXB_Crafting` → Inventory/Crafting | ⏳ tiếp theo |
| 3 | `PXB_Economy` → Economy (lãi 0,5%, phí 5%, 4 hành vi cấm) | ⏳ |
| 3 | `PXB_Education` → Education (5 bậc) | ⏳ |
| 4 | `PXB_Social` → Social; `PXB_Titles` / `PXB_Story` → Titles/Story | ⏳ |
| 4 | `PXB_PhoneHub` → PhoneHub (CanvasLayer, 9 tab) | ⏳ |
| 5 | `PXB_MarketBattle` → MarketBattle (luật chờ chủ duyệt) | ⏳ |
| 5 | `PXB_Online` / `PXB_SaveCloud` → Online/SaveCloud | ⏳ |

`PXB_Isometric` đã có tương đương Godot ở G1
(`iso_map.gd`, hotspot trong `main.gd`); `PXB_Tools` là hàm tiện ích,
port rải rác khi cần. Tổng 17 plugin MV → 14 hệ GDScript + 2 đã xong ở G1.

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

## 6. Bước tiếp theo — G2 bước 3 (Inventory/Crafting)

1. Browser-verify G2 bước 2 (mở link trên, xem HUD Ngày/Khung vẫn đổi
   đúng, không lỗi console).
2. Port `PXB_Inventory` + `PXB_Crafting` → `scripts/pxb_inventory.gd` /
   `pxb_crafting.gd`: túi đồ (stackable/all-or-nothing theo
   `Inventory.cs`), công thức chế tạo dùng nguyên liệu hotspot G1/G2 đã
   nhặt, `learnRecipe` (mặc định chưa học — xem lệch đã ghi ở
   roles-qc.md 19/11 01:50). Thêm nút "Làm ca" ở khu + "Nhặt" hotspot
   vào `main.gd` để Jobs/Hotspot nhìn thấy được (hiện chỉ có logic +
   test headless). Test headless riêng như bước 2.
3. Sau Inventory/Crafting: Economy → Education → Social → Titles/Story
   → PhoneHub → MarketBattle → Online/SaveCloud (xem §1).
