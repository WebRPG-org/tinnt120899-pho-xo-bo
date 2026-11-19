# Godot G2 — Port 17 plugin PXB → GDScript (19/11/2026)

> **Kết luận: G2 bước 1/5 XONG (mức headless).** 3 hệ nền đã port:
> `PxbBalance` (hằng số chốt) → `PxbStats` (chỉ số) → `PxbTime`
> (thời gian kiểu C), đăng ký autoload `PXB_Balance` / `PXB_Stats` /
> `PXB_Time`, `main.gd` đã bỏ hardcode khung và dùng `PxbBalance` /
> `PxbTime`. Selftest **87/87 PASS**, G1 selftest 42/42 + playtest 14/14
> vẫn PASS (không regression), scene chạy 120 frame exit 0, export web
> exit 0 (~8s), http.server 200 đủ 6 file. **Chưa kiểm chứng bằng trình
> duyệt thật** — như G0/G1, VM không có Chromium/Firefox.

## 1. Thứ tự port (docs/opensource-engine.md §4)

| Bước | Hệ | Trạng thái |
|---|---|---|
| 1 | `PXB_Balance` → `PxbBalance` | ✅ XONG đợt này |
| 1 | `PXB_Stats` → `PxbStats` | ✅ XONG đợt này |
| 1 | `PXB_Time` → `PxbTime` | ✅ XONG đợt này |
| 2 | `PXB_Jobs` → Jobs (làm ca, lương, quota) | ⏳ tiếp theo |
| 2 | `PXB_Inventory` / `PXB_Crafting` → Inventory/Crafting | ⏳ sau Jobs |
| 3 | `PXB_Economy` → Economy (lãi 0,5%, phí 5%, 4 hành vi cấm) | ⏳ |
| 3 | `PXB_Education` → Education (5 bậc) | ⏳ |
| 4 | `PXB_Social` → Social; `PXB_Titles` / `PXB_Story` → Titles/Story | ⏳ |
| 4 | `PXB_PhoneHub` → PhoneHub (CanvasLayer, 9 tab) | ⏳ |
| 5 | `PXB_MarketBattle` → MarketBattle (luật chờ chủ duyệt) | ⏳ |
| 5 | `PXB_Online` / `PXB_SaveCloud` → Online/SaveCloud | ⏳ |

`PXB_Isometric` và `PXB_Hotspot` đã có tương đương Godot ở G1
(`iso_map.gd`, hotspot trong `main.gd`); `PXB_Tools` là hàm tiện ích,
port rải rác khi cần. Tổng 17 plugin MV → 14 hệ GDScript + 2 đã xong ở G1.

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

## 6. Bước tiếp theo — G2 bước 2 (Jobs)

1. Browser-verify G2 bước 1 (mở link trên, xem HUD Ngày/Khung vẫn đổi
   đúng, không lỗi console).
2. Port `PXB_Jobs.js` → `scripts/pxb_jobs.gd`: làm ca (chọn nghề, đúng
   khung tốt +25%, trừ quota tuần), lương về túi, tích hợp `PxbStats`
   (nghề dùng chỉ số chính) + `PxbTime` (khung hiện tại). Thêm nút
   "Làm ca" ở khu + test headless `g2_jobs_selftest` (số khớp
   `GameBalance.cs` / `PXB_Balance.js`: lương 150k/180k/150k, quota 14).
3. Sau Jobs: Inventory/Crafting (dùng nguyên liệu hotspot G1 đã nhặt),
   rồi Economy → Education → Social → Titles/Story → PhoneHub →
   MarketBattle → Online/SaveCloud (xem §1).
