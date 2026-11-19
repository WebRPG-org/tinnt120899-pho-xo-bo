# Báo cáo kiểm tra — Phố Xô Bồ

> **Đây là kiểm tra TĨNH, chưa phải build / test chạy được.**
> VM này không có dotnet / Unity / csc nên không biên dịch được code C#,
> không chạy được server, không chơi được game. Báo cáo này chỉ chứng minh:
> ngoặc cân bằng, số chốt khớp nhau giữa code và docs, không có secret,
> ranh giới pháp lý bị chặn trong code. Muốn test chạy được thật phải có
> máy build (xem `docs/roles-qc.md` §6).

## Lần chạy mới nhất: 19/11/2026 ~16:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **308/308 PASS, exit 0** — tăng từ 303/303: nhóm T36 mới
  (5 mục, Map012 Khu Biệt Thự Ven Sông).
- **Map012 — Khu Biệt Thự Ven Sông (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map012.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003/
  Map005/Map006/Map007/Map008/Map009/Map010/Map011; layer 1 28/108 —
  biên bắc/tây/đông, biên nam để trống như mặt tiền mở, chỉ 2 ô góc);
  NPC Bảo Vệ Biệt Thự (3,3) + Người Làm Vườn (8,6), lời thoại chỉ từ
  `docs/districts.md` khu 12 ("Nhà ở tầng 4.") + `MapInfos.json` khu 12
  unlock ("Chương 4 — 3 quest giúp người + ≥1 quan hệ thân thiết.") —
  không bịa lương/giá; transfer về Map011 (5,4).
  `data/atlas-map012.json` mới, TÁI DÙNG `atlas-map001.png` (không PNG
  mới, SHA không đổi). `PXB_Isometric.js` đăng ký map 12
  (`atlasCodeFor` + sửa comment header cũ chỉ ghi tới Map011);
  `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng` từ v3.1 nên không
  sửa thêm. **Map011 nay có cửa (5,8) đi Map012** — đồ thị map
  1-2-3-4-5-6-7-8-9-10-11-12 đã nối được. PROVISIONAL: code 3/4/5
  (nhà trọ) dùng tạm làm khối biệt thự ven sông, chờ art pass vẽ tile
  biệt thự riêng. Đã xác minh độc lập: smoke `/tmp/pxb-map012-smoke.js`
  26/26 PASS (không commit) — JSON hợp lệ, đếm tile 648/108/28, event
  không bị tường đè, transfer 2 chiều Map011↔Map012, atlas tái dùng,
  lời thoại đúng nguồn, không có số giá/lương bịa. Script sinh map
  `/tmp/pxb-map012-gen.py` (không commit) clone sâu event cửa của Map010
  để thêm cửa vào Map011 — rút kinh nghiệm lỗi `sed` dồn event ở đợt
  Map011; smoke lúc đầu FAIL 5 mục do chính file smoke viết sai số map
  (chưa sửa), đã sửa smoke rồi chạy lại 26/26 PASS.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map013–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map013 (Quận
  Tài Chính) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~15:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **303/303 PASS, exit 0** — tăng từ 298/298: nhóm T35 mới
  (5 mục, Map011 Phố Tây).
- **Map011 — Phố Tây (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map011.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003/
  Map005/Map006/Map007/Map008/Map009/Map010; layer 1 28/108 — biên
  bắc/tây/đông, biên nam để trống như mặt tiền mở, chỉ 2 ô góc); NPC
  Nhân Viên Lễ Tân (3,3) + Hướng Dẫn Viên (8,6), lời thoại chỉ từ
  `docs/districts.md` khu 11 ("Dịch vụ cao cấp, ngoại ngữ / giao tiếp.")
  + `MapInfos.json` khu 11 unlock ("Chương 4 — 3 quest giúp người +
  ≥1 quan hệ thân thiết.") — không bịa lương/giá; transfer về Map010
  (5,4). `data/atlas-map011.json` mới, TÁI DÙNG `atlas-map001.png`
  (không PNG mới, SHA không đổi). `PXB_Isometric.js` đăng ký map 11
  (`atlasCodeFor` + sửa comment header cũ chỉ ghi tới Map010);
  `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng` từ v3.1 nên không
  sửa thêm. **Map010 nay có cửa (5,8) đi Map011** — đồ thị map
  1-2-3-4-5-6-7-8-9-10-11 đã nối được. PROVISIONAL: code 3/4/5 (nhà trọ)
  dùng tạm làm khối phố Tây, chờ art pass vẽ tile phố Tây riêng. Đã
  xác minh độc lập: smoke `/tmp/pxb-map011-smoke.js` 26/26 PASS (không
  commit) — JSON hợp lệ, đếm tile 648/108/28, event không bị tường đè,
  transfer 2 chiều Map010↔Map011, atlas tái dùng, lời thoại đúng nguồn,
  không có số giá/lương bịa.
- **1 lỗi build script trong lần chạy này (đã sửa, không ảnh hưởng
  dữ liệu):** script tạo map lần đầu dùng `sed` đổi chỉ số event nên cả
  3 `set_event` dồn vào cùng 1 event (evs[3]) — Map011 ghi ra vẫn giữ
  tên NPC cũ; đã viết lại script với chỉ số đúng (events MV có null
  đầu) + clone sâu event khi tách cửa, chạy lại thì Map011/Map010 đúng.
  Đã verify lại từ đĩa: Map010 giữ đủ 4 event (Lập Trình Viên, Kỹ Sư
  Phần Mềm, Cửa về Phố Thương Mại, Cửa đi Phố Tây), Map011 đúng 3 event.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map012–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map012 (Khu
  Biệt Thự Ven Sông) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~14:45 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **298/298 PASS, exit 0** — tăng từ 293/293: nhóm T34 mới
  (5 mục, Map010 Khu Công Nghệ).
- **Map010 — Khu Công Nghệ (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map010.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003/
  Map005/Map006/Map007/Map008/Map009; layer 1 28/108 — biên bắc/tây/đông,
  biên nam để trống như mặt tiền mở, chỉ 2 ô góc); NPC Lập Trình Viên
  (3,3) + Kỹ Sư Phần Mềm (8,6), lời thoại chỉ từ `docs/districts.md`
  khu 10 ("Việc công nghệ, yêu cầu Trí cao.") + `MapInfos.json` khu 10
  unlock ("Chương 3 — bài kiểm tra rank.") — không bịa lương/giá;
  transfer về Map009 (5,4). `data/atlas-map010.json` mới, TÁI DÙNG
  `atlas-map001.png` (không PNG mới, SHA không đổi). `PXB_Isometric.js`
  đăng ký map 10 (`atlasCodeFor` + sửa comment header cũ chỉ ghi tới
  Map009); `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng` từ v3.1
  nên không sửa thêm. **Map009 nay có cửa (5,8) đi Map010** — đồ thị
  map 1-2-3-4-5-6-7-8-9-10 đã nối được. PROVISIONAL: code 3/4/5 (nhà trọ)
  dùng tạm làm khối công nghệ, chờ art pass vẽ tile công nghệ riêng. Đã
  xác minh độc lập: smoke `/tmp/pxb-map010-smoke.js` 29/29 PASS (không
  commit) — JSON hợp lệ, đếm tile 648/108/28, event không bị tường đè,
  transfer 2 chiều Map009↔Map010, atlas tái dùng, lời thoại đúng nguồn,
  không có số giá/lương bịa.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map011–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map011 (Phố Tây)
  + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~13:45 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **293/293 PASS, exit 0** — tăng từ 288/288: nhóm T33 mới
  (5 mục, Map009 Phố Thương Mại).
- **Map009 — Phố Thương Mại (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map009.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003/
  Map005/Map006/Map007/Map008; layer 1 28/108 — biên bắc/tây/đông, biên
  nam để trống như mặt tiền mở, chỉ 2 ô góc); NPC Chủ Cửa Hàng (3,3) +
  Người Bán Hàng (8,6), lời thoại chỉ từ `docs/districts.md` khu 9
  ("Buôn bán quy mô vừa, cửa hàng.") + `MapInfos.json` khu 9 unlock
  ("Chương 3 — bài kiểm tra rank.") — không bịa giá/lương; transfer về
  Map008 (5,4). `data/atlas-map009.json` mới, TÁI DÙNG
  `atlas-map001.png` (không PNG mới, SHA không đổi). `PXB_Isometric.js`
  đăng ký map 9 (`atlasCodeFor` + sửa comment header cũ chỉ ghi tới
  Map004); `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng` từ v3.1
  nên không sửa thêm. **Map008 nay có cửa (5,8) đi Map009** — đồ thị
  map 1-2-3-4-5-6-7-8-9 đã nối được. PROVISIONAL: code 3/4/5 (nhà trọ)
  dùng tạm làm khối cửa hàng, chờ art pass vẽ tile cửa hàng riêng. Đã
  xác minh độc lập: smoke `/tmp/pxb-map009-smoke.js` 23/23 PASS (không
  commit) — JSON hợp lệ, đếm tile 648/108/28, event không bị tường đè,
  transfer 2 chiều Map008↔Map009, atlas tái dùng, lời thoại đúng nguồn,
  không có số giá/lương bịa.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map010–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map010 (Khu
  Công Nghệ) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~12:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **288/288 PASS, exit 0** — tăng từ 283/283: nhóm T32 mới
  (5 mục, Map008 Khu Chung Cư Cao Cấp).
- **Map008 — Khu Chung Cư Cao Cấp (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map008.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003/
  Map005/Map006/Map007; layer 1 28/108 — biên bắc/tây/đông, biên nam để
  trống như mặt tiền mở, chỉ 2 ô góc); NPC Cư Dân Cao Cấp (3,3) + Bảo Vệ
  Chung Cư (8,6), lời thoại chỉ từ `docs/districts.md` khu 8 ("Nhà ở
  tầng 3.") + `MapInfos.json` khu 8 unlock ("Chương 3 — bài kiểm tra
  rank.") — không bịa lương/giá; transfer về Map007 (5,4).
  `data/atlas-map008.json` mới, TÁI DÙNG `atlas-map001.png` (không PNG
  mới, SHA không đổi). `PXB_Isometric.js` đăng ký map 8 (`atlasCodeFor`
  + sửa comment header cũ chỉ ghi tới Map007); `loadAtlasBitmap` đã tôn
  trọng `mapping.atlasPng` từ v3.1 nên không sửa thêm. **Map007 nay có
  cửa (5,8) đi Map008** — đồ thị map 1-2-3-4-5-6-7-8 đã nối được.
  PROVISIONAL: code 3/4/5 (nhà trọ) dùng tạm làm khối chung cư cao cấp,
  chờ art pass vẽ tile chung cư cao cấp riêng. Đã xác minh độc lập:
  smoke `/tmp/pxb-map008-smoke.js` 23/23 PASS (không commit) — JSON hợp
  lệ, đếm tile 648/108/28, event không bị tường đè, transfer 2 chiều
  Map007↔Map008, atlas tái dùng, lời thoại đúng nguồn, không có số
  giá/lương bịa.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map009–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map009 (Phố
  Thương Mại) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~11:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **283/283 PASS, exit 0** — tăng từ 278/278: nhóm T31 mới
  (5 mục, Map007 Phố Văn Phòng Nhỏ).
- **Map007 — Phố Văn Phòng Nhỏ (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map007.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003/
  Map005/Map006; layer 1 28/108 — biên bắc/tây/đông, biên nam để trống
  như mặt tiền mở, chỉ 2 ô góc); NPC Nhân Viên Văn Phòng (3,3) + Thực
  Tập Sinh (8,6), lời thoại chỉ từ `docs/districts.md` khu 7 ("Việc
  văn phòng cấp thấp, thực tập") + `MapInfos.json` khu 7 unlock ("việc
  ổn định, Trí 40 hoặc Cao đẳng, Danh vọng 200") — không bịa lương/
  giá; transfer về Map006 (5,4). `data/atlas-map007.json` mới, TÁI DÙNG
  `atlas-map001.png` (không PNG mới, SHA không đổi). `PXB_Isometric.js`
  đăng ký map 7 (`atlasCodeFor` + sửa comment header cũ chỉ ghi tới
  Map004); `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng` từ v3.1
  nên không sửa thêm. **Map006 nay có cửa (5,8) đi Map007** — đồ thị
  map 1-2-3-4-5-6-7 đã nối được. PROVISIONAL: code 3/4/5 (nhà trọ) dùng
  tạm làm khối văn phòng nhỏ, chờ art pass vẽ tile văn phòng riêng. Đã
  xác minh độc lập: smoke `/tmp/pxb-map007-smoke.js` 22/22 PASS (không
  commit) — JSON hợp lệ, đếm tile 648/108/28, event không bị tường đè,
  transfer 2 chiều Map006↔Map007, atlas tái dùng, lời thoại đúng nguồn.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map008–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map008 (Khu
  Chung Cư Cao Cấp) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~10:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **278/278 PASS, exit 0** — tăng từ 273/273: nhóm T30 mới
  (5 mục, Map006 Chung Cư Cũ).
- **Map006 — Chung Cư Cũ (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map006.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 1/2, không đường nhựa, đúng mẫu Map001/Map003;
  layer 1 28/108 — biên bắc/tây/đông, biên nam để trống như mặt tiền mở,
  chỉ 2 ô góc như Map003); NPC Cư Dân Chung Cư (3,6) + Bác Quản Lý (8,3),
  lời thoại lấy từ `docs/districts.md` khu 6 ("Nhà ở tầng 2, chi phí
  vừa") — không bịa giá thuê/giá nhà (GDD chưa chốt giá chung cư cũ);
  transfer về Map005 (5,4). `data/atlas-map006.json` mới, TÁI DÙNG
  `atlas-map001.png` (không PNG mới, SHA không đổi). `PXB_Isometric.js`
  đăng ký map 6 (`atlasCodeFor`); `loadAtlasBitmap` đã tôn trọng
  `mapping.atlasPng` từ v3.1 nên không sửa thêm. **Map005 nay có cửa
  (5,8) đi Map006** — đồ thị map 1-2-3-4-5-6 đã nối được. PROVISIONAL:
  code 3/4/5 (nhà trọ) dùng tạm làm khối chung cư cũ, chờ art pass vẽ
  tile chung cư riêng. Đã xác minh độc lập: JSON hợp lệ, đếm tile
  648/108/28, event không bị tường đè, smoke `/tmp/pxb-map006-smoke.js`
  19/19 PASS (không commit). Map005 trong cùng đợt: 273/273 PASS
  (nhóm T29, smoke `/tmp/pxb-map005-smoke.js` 24/24 PASS).
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật; Map007–018 chưa có; img/audio còn lại trống;
  luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa có).
  Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map007 (Phố Văn
  Phòng Nhỏ) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~10:45 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **273/273 PASS, exit 0** — tăng từ 268/268: nhóm T29 mới
  (5 mục, Map005 Làng Đại Học).
- **Map005 — Làng Đại Học (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map005.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn xen kẽ 2 mã, không đường nhựa, đúng mẫu Map003; layer 1
  28/108 — biên bắc/tây/đông nhà trọ, biên nam chỉ 2 góc như Map003);
  NPC Thầy Giáo (3,3) + Sinh Viên Làm Thêm (8,6), lời thoại chỉ từ
  `docs/districts.md` khu 5 ("Học vấn, khoá ngắn hạn, việc làm thêm")
  + GDD Mục 5 (5 bậc học đã chốt: THPT Trí 20, Cao đẳng Trí 40, Cử
  nhân Trí 60, Thạc sĩ Trí 75, Tiến sĩ Trí 90 cần mentor; khoá ngắn
  hạn 3–7 ngày, +10 một chỉ số phụ, mở nghề phụ) — không bịa học
  phí/giá/lương mới; transfer về Map004 (5,4).
  `data/atlas-map005.json` mới, TÁI DÙNG `atlas-map001.png` (không PNG
  mới, SHA-256 `971faa8d…15940` đã verify khớp tileset-plan.md §7).
  `PXB_Isometric.js` đăng ký map 5 (`atlasCodeFor` + 1 dòng);
  `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng` từ v3.1 nên không
  sửa thêm. **Map004 nay có cửa (5,8) đi Map005** — đồ thị map
  1-2-3-4-5 đã nối được. PROVISIONAL: code 3/4/5 (nhà trọ) dùng tạm làm
  giảng đường / ký túc xá, chờ art pass vẽ tile trường riêng. Đã xác
  minh độc lập: smoke stub `/tmp/pxb-map005-smoke.js` 24/24 PASS
  (không commit) — JSON hợp lệ, đếm tile 648/108/28, event không bị
  tường đè, transfer đúng Map004 (5,4), SHA atlas-map001.png khớp §7.
- **1 lỗi check trong lần chạy này (đã sửa, chạy lại PASS):** smoke lúc
  đầu FAIL 1 mục — lời thoại Sinh Viên chỉ viết "làm thêm" nên thiếu
  cụm "việc làm thêm" đúng districts.md khu 5. Đã sửa câu thành "nhận
  việc làm thêm…" rồi chạy lại 24/24 PASS.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật (browser task trước đó BỊ CHẶN ở loopback, tunnel
  Cloudflare lỗi TLS — xem mục 08:00); Map006–018 chưa có; img/audio còn
  lại trống; luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa
  có). Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map006 (Chung
  Cư Cũ) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~09:45 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **268/268 PASS, exit 0** — tăng từ 263/263: nhóm T28 mới
  (5 mục, Map004 Bến Xe Miền Đông); T26d cập nhật (Map003 nay có transfer
  đi Map004).
- **Map004 — Bến Xe Miền Đông (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/data/Map004.json` mới (lưới 12×9, data 648, layer 0
  108/108 — sàn 88 + điểm nhấn 11 + đường nhựa dọc x=5 ×9, đúng mẫu
  Map002; layer 1 28/108 — biên bắc quầy vé 4/5/6 + 2 bên vỉa hè, biên
  nam chỉ 2 góc như Map003); NPC Bác Tài (3,2) + Anh Bốc Vác (8,6),
  lời thoại lấy từ `docs/districts.md` khu 4 ("Đi lại liên khu, việc
  shipper / bốc vác") — không bịa giá vé/lương; transfer về Map003
  (5,4). `data/atlas-map004.json` mới, TÁI DÙNG `atlas-map002.png`
  (không PNG mới). `PXB_Isometric.js` đăng ký map 4 (`atlasCodeFor` +
  comment header); `loadAtlasBitmap` đã tôn trọng `mapping.atlasPng`
  từ v3.1 nên không sửa thêm. **Map003 nay có cửa (5,8) đi Map004** —
  đồ thị map 1-2-3-4 đã nối được (trước đây Map003 ghi "không transfer
  tới Map004 chưa có"). PROVISIONAL: code 4/5 (sạp chợ) dùng tạm làm
  quầy vé / nhà chờ, code 6 làm vỉa hè bến, chờ art pass vẽ tile bến xe
  riêng. Đã xác minh độc lập: JSON hợp lệ, đếm tile 648/108/28, event
  không bị tường đè, SHA atlas-map002.png không đổi.
- **1 lỗi check trong lần chạy này (đã sửa, chạy lại PASS):** T28d lúc
  đầu FAIL giả — check tìm "shipper"/"bốc vác" thường trong khi lời
  thoại NPC viết hoa đầu câu ("Shipper…", "Bốc vác…"). Đã sửa check
  thành không phân biệt hoa/thường.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật (browser task trước đó BỊ CHẶN ở loopback, tunnel
  Cloudflare lỗi TLS — xem mục 08:00); Map005–018 chưa có; img/audio còn
  lại trống; luật MarketBattle chi tiết chờ chủ duyệt (scene trận chưa
  có). Checklist C1–C9 (§6 roles-qc) vẫn giữ cho đường Unity (phương án
  dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: Map005 (Làng
  Đại Học) + scene trận MarketBattle sau khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~09:05 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **263/263 PASS, exit 0** — tăng từ 253/253: nhóm T26 mới
  (5 mục, Map003 Khu Công Nhân) + T27 mới (5 mục, PXB_MarketBattle);
  T14v nay `node --check` 19/19 file JS (thêm PXB_MarketBattle.js);
  T22b nới `== 16` → `>= 16` plugin (nay 17 plugin).
- **Map003 — Khu Công Nhân (luồng 1, việc tiếp theo lớn nhất):**
  `src/nadia/www/data/Map003.json` mới (lưới 12×9, data 648, layer 0
  108/108, layer 1 28/108, biên nam để trống như mặt tiền mở); event Anh
  Ba (4,6), Chị Sáu (8,3), transfer về Map002 (5,4) — không hotspot mới,
  không transfer tới Map004 chưa có. `data/atlas-map003.json` mới, TÁI
  DÙNG `atlas-map001.png` (không PNG mới). `PXB_Isometric.js` sửa tối
  thiểu (+13 dòng): `atlasCodeFor` thêm map 3 → "Map003",
  `loadAtlasBitmap` nay tôn trọng `mapping.atlasPng` khi có (trước đây
  suy tên PNG từ mapId nên map 3 sẽ 404); map 1–2 không đổi hành vi.
  PROVISIONAL: code 4 (nhà bắc) dùng tạm làm nhà xưởng, chờ art pass vẽ
  tile xưởng riêng. Đã xác minh độc lập: JSON hợp lệ, đếm tile
  648/108/28, SHA atlas-map001.png vẫn khớp §7.
- **PXB_MarketBattle — Bụi Đời Chợ Cá (luồng 2, song song):**
  `docs/market-battle-design.md` mới (185 dòng, trạng thái CHƯA CHỐT —
  chờ chủ duyệt, mọi số PROVISIONAL) + `src/nadia/www/js/plugins/
  PXB_MarketBattle.js` mới (1.109 dòng, port đúng GDD Mục 11: 3v3/5v5
  theo lượt, lưới 12×9, trận 180s, 4 vũ khí hài Chảo 12/Cá khô 8/Ghế
  nhựa 15 + đẩy lùi/Loa 10, 6 vai màu, thắng giữ sạp 7 ngày game trong
  `$gameSystem.pxbMarketBattle`, buff Tướng Cướp +10% sát thương ở chợ /
  Cảnh sát +10% Max HP khi thủ sạp, không chết/không mất đồ); `plugins.js`
  nay 17 plugin (MarketBattle cuối, sau SaveCloud). Smoke test stub core
  MV (`/tmp/pxb-marketbattle-smoke.js`, không commit): **80/80 PASS**
  (đã chạy lại độc lập để xác minh); `node --check` PASS. 2 lỗi phát
  hiện khi test (đã sửa): hòa điểm vai trộn không bao giờ thắng vai gốc
  → nay ưu tiên vai trộn; `install()` gọi 2 lần bọc hook 2 lần → thêm cờ
  `installed`. Chưa xong: scene/bản đồ trận MV (`Scene_MarketBattle`),
  chưa port ngược sang C# (GDD Mục 11 không có code C# gốc).
- **1 lỗi check trong lần chạy này (đã sửa, chạy lại PASS):** T26c lúc
  đầu FAIL giả — check tìm chuỗi gọi hàm `"atlasCodeFor(3)"` và tên khu
  trong file JS, trong khi code thật viết `if (mapId === 3) return
  "Map003"` và tên khu nằm trong JSON mapping. Đã sửa check theo đúng
  chuỗi code thật.
- **Còn lại chưa xong:** chờ chủ bật GitHub Pages → kiểm chứng Map001
  bằng trình duyệt thật (browser task trước đó BỊ CHẶN ở loopback, tunnel
  Cloudflare lỗi TLS — xem mục 08:00); Map004–018 chưa có; img/audio còn
  lại trống; luật MarketBattle chi tiết chờ chủ duyệt. Checklist C1–C9
  (§6 roles-qc) vẫn giữ cho đường Unity (phương án dự phòng); đường
  chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp
  theo lớn nhất: Map004 (Bến Xe Miền Đông) + scene trận MarketBattle sau
  khi chủ duyệt luật.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~08:00 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **253/253 PASS, exit 0** — tăng từ 248/248: nhóm T25 mới
  (5 mục, PXB_Isometric v3.1 atlas-fallback).
- **PXB_Isometric v3.1 — SỬA GIỚI HẠN v3 (việc tiếp theo lớn nhất, xong):**
  atlas PNG thiếu/lỗi (404) nay rơi về fallback v2 thay vì sprite vẽ
  trắng, map trống: `atlasModeOn()` tắt khi `Bitmap.isError()`; bitmap
  đang load (chưa ready, chưa lỗi) vẫn giữ atlas mode — sprite MV tự
  hiện khi load xong; `isoUpdateTransform` phát hiện bitmap lỗi sau lần
  vẽ đầu thì vẽ lại 1 lần bằng fallback v2 (đếm `stats.atlasFallback`),
  không vẽ lại nữa; `setAtlas` mới reset cờ. Smoke test stub core MV
  (`/tmp/pxb-iso-v31-smoke.js`, không commit): **18/18 PASS** (bitmap
  OK vẽ atlas đủ 112 tile; loading vẫn atlas; lỗi trước vẽ → fallback
  đủ tile + đếm 1; lỗi sau vẽ → vẽ lại 1 lần + không đếm thêm; setAtlas
  reset cờ; không mapping → fallback cũ; bitmap thiếu `isError` không
  crash). `node --check` PASS. Header plugin đã sửa: không còn câu
  "không tự rơi về fallback".
- **Ghi nhận — đợt link-chơi-thật đã push xong:** 9 file data JSON còn
  thiếu (`Skills/Weapons/Armors/Enemies/Troops/States/Animations/
  Tilesets/CommonEvents.json`), `tools/tiles/embed_assets.py`,
  `src/nadia/www/js/pxb-embedded.js` (~52 KB, 13 asset base64),
  `.nojekyll`, `docs/link-choi-that.md` đã lên GitHub ở commit
  `4b277edb998b` (đối chiếu sync record — ghi chú "chưa push" trong
  `docs/link-choi-that.md` đã cũ). Chờ duy nhất chủ bật GitHub Pages
  (Settings → Pages → Deploy from a branch → main, root) để có link
  `https://tinnt120899.github.io/pho-xo-bo/src/nadia/www/`.
- **Còn lại chưa xong — KIỂM CHỨNG TRÌNH DUYỆT BỊ CHẶN (kết quả browser
  task browser-task:4a3735e2, đã trả về trong đợt này):** trình duyệt
  (VM riêng) từ chối mọi địa chỉ loopback (`invalid_request` với
  127.0.0.1/localhost, http/https, `/` và `/index.html`) nên không mở
  được `http://127.0.0.1:8137/` dù server local chạy tốt (curl 200).
  Đã thử tunnel Cloudflare làm URL công khai: tải cloudflared 2026.11.1
  (`~/workspace/tools/cloudflared`, ngoài repo) và chạy 2 lần, cả 2 đều
  lỗi `tls: first record does not look like a TLS handshake` khi gọi
  `api.trycloudflare.com` — egress proxy của VM trả 403 cho domain này
  nên không lập được tunnel; ngrok cũng không có (cần tài khoản/token).
  Không tự bật Pages bằng API thay chủ. Kết luận: game CHƯA kiểm chứng
  được bằng trình duyệt thật; chờ chủ bật GitHub Pages rồi chạy lại
  browser task với link Pages. PXB_MarketBattle (luật chưa chốt),
  Map003–018 chưa có, img/audio còn lại trống. Checklist C1–C9 (§6
  roles-qc) vẫn giữ cho đường Unity (phương án dự phòng); đường chính
  nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`. Việc tiếp theo
  lớn nhất: chủ bật Pages → kiểm chứng Map001, rồi PXB_MarketBattle /
  Map003–018.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~06:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **248/248 PASS, exit 0** — tăng từ 243/243: nhóm T24 mới
  (5 mục, PXB_Isometric v3 atlas mode + atlas PNG trong repo).
- **PXB_Isometric v3 — ATLAS MODE ĐÃ VIẾT (việc tiếp theo lớn nhất, xong):**
  `src/nadia/www/js/plugins/PXB_Isometric.js` nay 691 dòng (v2: 456):
  registry atlas (`registerAtlas`/`atlasFor`/`atlasCodeFor` 1→Map001,
  2→Map002), `loadAtlasBitmap` qua `ImageManager.loadBitmap('img/tilesets/',
  'atlas-map001', 0, true)` + cache theo mapId, `loadAtlasJson` qua
  `XMLHttpRequest` GET `data/atlas-map00X.json` (lỗi → `onDone(null)`),
  `IsoTilemap.setAtlas(mapId, mapping, bitmap)`; `Spriteset_Map.createTilemap`
  tự gắn atlas theo `$gameMap.mapId()`, chưa có mapping thì load JSON rồi
  `setAtlas` + `refresh()` chỉ khi scene map đang active. Vẽ atlas: tra
  `mapping.tiles[String(code)]`, code lạ đếm `stats.skippedAtlasUnknown`;
  sprite lấy đúng frame (x,y,w,h), tint = `tintToHex` (kênh >1 kẹp 255),
  KHÔNG quay 45° (atlas đã là hình thoi sẵn); sàn layer 0 neo (0.5, 0.5)
  tại `diamondCenter`, tường/sạp layer 1 neo (0.5, 1.0) tại `isoPos`;
  phân lớp theo `mapping.layer`, bỏ qua bóng/mép bàn/overpass MV.
  Atlas mode tắt → đường fallback v2 giữ nguyên 100%. Smoke test stub
  core MV (`/tmp/pxb-iso-v3-smoke.js`, không commit): **55/55 PASS** (đã
  chạy lại độc lập để xác minh); `node --check` PASS; API v2 giữ nguyên.
- **Atlas PNG ĐÃ VÀO REPO:** `src/nadia/www/img/tilesets/atlas-map001.png`
  (17.531 byte) + `atlas-map002.png` (17.124 byte), cả 2 đều 512×64 RGBA,
  SHA-256 khớp 100% `docs/tileset-plan.md` §7. Tile data khớp hoàn toàn
  mapping (code + layer + số ô; đường nhựa Map002 đúng 9 ô ở x=5, xuyên
  qua ô cửa (5,4)). Lưu ý nhỏ: mô tả §7.3 "biên nam y=8 để trống" chưa
  chính xác tuyệt đối — layer 1 vẫn có 2 ô góc (0,8) và (11,8); chỉ là
  câu chữ trong doc, không phải lỗi dữ liệu.
- **1 lỗi script đã sửa trong lần chạy này (không phải code game):**
  `check_static.py` crash `UnicodeDecodeError` byte 0x89 ở T14ab ngay khi
  atlas PNG vào repo — `nadia_files` đọc mọi file dưới `src/nadia/` bằng
  `read_text(utf-8)`. Đã sửa: loại đuôi nhị phân (`.png/.jpg/.ogg/.mp3/
  .zip`…) khỏi danh sách quét T14ab/ac; PNG được khóa riêng ở T24b (magic
  bytes + 512×64 + SHA-256). 2 lỗi script mới trong lần chạy này (đã sửa,
  chạy lại PASS): T24b/T24c lúc đầu FAIL giả — đường dẫn `NADIA/"www"/…`
  bị nhân đôi vì `NADIA` đã bao gồm `www`.
- **Giới hạn v3 (nói thẳng, đã ghi trong header plugin):** nếu thiếu file
  PNG, `ImageManager` vẫn trả Bitmap nhưng không bao giờ ready → sprite
  atlas vẽ trắng, map trống, KHÔNG tự rơi về fallback (vì `atlasModeOn`
  chỉ kiểm tra mapping + bitmap non-null). Autotile A1–A4 + bóng + mép
  bàn ở đường fallback MV vẫn chưa vẽ; chưa culling viewport (map 12×9
  nhỏ nên vẽ hết); xe máy/dây điện/sạp lá chuối vẫn phải vẽ thêm.
- **Còn lại chưa xong (Giai đoạn 2–4):** chưa mở trình duyệt chơi được
  thật — cần chạy game MV thật với atlas để thấy map Xóm Trọ Cũ (VM
  không chạy được game); PXB_MarketBattle (luật chưa chốt), Map003–018
  chưa có, img/audio còn lại trống. Checklist C1–C9 (§6 roles-qc) vẫn
  giữ cho đường Unity (phương án dự phòng); đường chính nay là Giai đoạn
  1–5 của `docs/architecture-nadia.md`. Việc tiếp theo lớn nhất: chạy
  thử game MV thật trên trình duyệt (mở Map001 thấy map Xóm Trọ Cũ vẽ
  bằng atlas), rồi PXB_MarketBattle / Map003–018.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~06:30 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **243/243 PASS, exit 0** — tăng từ 228/228: nhóm T21 mới
  (5 mục, tileset/atlas/tile data), T22 mới (5 mục, PXB_Tools), T23 mới
  (5 mục, PXB_Online/SaveCloud); `node --check` nay 18/18 file JS nadia
  (đã sửa T14v: đợt 04:50 ghi "15/15" nhưng danh sách chỉ có 13 file —
  thiếu PXB_Titles.js + PXB_Story.js; nay đủ 16 plugin + plugins.js +
  main.js = 18 file).
- **Tile CC0 đã tải thật + atlas đã đóng + tile data thật (luồng chính):**
  tải 6 pack về máy làm việc `/tmp/pxb-tiles/` (KHÔNG vào repo — PNG nhị
  phân không push được qua snapshot): 5 Kenney (City 990.594 byte,
  Landscape 1.141.541, Buildings 1.706.949, Roads 621.468, Vehicles
  2.269.908) + SBS Floor nhỏ 880.313 byte; SHA-256 cả 6 đã ghi trong
  `docs/tileset-plan.md` §7. Đo thật: tile Kenney canvas 132×~99 (thoi
  128×64 + hông đất), Buildings 132×127 / 99×~60, Roads 100×65, Vehicles
  ~32×30; SBS là 10 sheet (không phải tile lẻ) — Worldmap 384×320
  (lưới 3×5 ô 128×64), Interior 384×192 (3×3), Pathways 512×216
  (ô 128×72), nền đen đặc. Xác định bằng mắt: Landscape 010 cỏ phẳng /
  014 đất phẳng, City 014/015/021 vỉa hè / 022 ngã tư, Buildings
  000/001/009/014/021 nhà-sạp, Roads đặt tên theo nội dung
  (`roadNS.png`...). Vehicles CHỈ CÓ Ô TÔ — không có xe máy (phải vẽ thêm,
  đúng dự báo). Script mới `tools/tiles/build_atlas.py` (mặt nạ hình thoi
  2:1 cho SBS, tint PROVISIONAL theo palette art-style §2, downscale
  NEAREST về footprint 64×32, cell atlas 64×64) + `fill_map_data.py`
  (công thức MV `data[(z*h+y)*w+x]`, giữ nguyên event) + 2 selection JSON.
  Atlas PNG: map001 512×64 (SHA-256
  `971faa8d…15940`, 5 tile) + map002 512×64 (SHA-256 `d1329a32…80949`,
  6 tile) — chỉ nằm ở máy làm việc, đưa vào repo bằng git push / upload
  web (§5). Mapping JSON text đã push (`data/atlas-map*.json`,
  scheme atlas-code). **Tile data thật:** Map001/Map002 layer 0 108/108
  ô (sàn + xen kẽ + dải đường nhựa dọc x=5 ở Map002, xuyên qua ô cửa
  (5,4)), layer 1 28/108 ô (tường/sạp biên bắc/tây/đông; biên nam để trống
  như mặt tiền mở). **CHƯA vẽ được:** cần PXB_Isometric v3 (atlas mode)
  mới đọc atlas-code — v2 đọc theo Tilemap MV. 1 lỗi script đã sửa:
  `build_atlas.py` xếp tile sai trục (`col, row = divmod(i, cols)` phải
  là `row, col`); atlas đầu dồn 1 cột dọc, đã chạy lại đúng 8 cột.
- **3 plugin slice mới (2 luồng song song, Phase 2/4):**
  `PXB_Tools.js` (977 dòng, port `Crafting.cs` ToolBehaviour: 4 công cụ
  × 3 bậc đổi hành vi thật — Xe Đẩy bậc 3 đi được đường mưa, Đèn Soi bậc
  2/3 thấy hotspot ẩn gần/hiếm, Sổ Tay gợi ý rõ mục tiêu/khu/nguyên liệu,
  Xẻng nhặt nhanh + thêm đồ/hiếm; 12 câu hành vi đúng nguyên văn C# —
  kiểm bằng grep; chi phí nâng cấp bậc 2/3 là PROVISIONAL suy từ công
  thức bậc 1, GDD chưa chốt; smoke 140/140 PASS) +
  `PXB_Online.js` (623 dòng, Phase 2: health + số dư + tặng tiền qua
  endpoint server .NET thật `/health`, `/ledger/balance/{playerId}`,
  `/ledger/gift` với IdempotencyKey, outbox khi offline; trade/đấu giá/
  công ty=guild CHƯA có endpoint nên luôn trả `server-chua-co-endpoint`,
  không giả vờ thành công, không tự quyết tiền người khác; base URL qua
  tham số plugin, mặc định `http://localhost:5000` PROVISIONAL) +
  `PXB_SaveCloud.js` (512 dòng: tài khoản tùy chọn, localStorage mặc định
  khi offline, save JSON + LZString, upload/download/apply; server chưa
  có endpoint save nên trả `server-chua-co-endpoint`, không giả vờ đã
  đồng bộ); smoke Online+SaveCloud 68/68 PASS; `plugins.js` nay 16 plugin
  (…Crafting → Tools → Jobs … Story → Online → SaveCloud).
- **Lệch / PROVISIONAL ghi nhận khi port (chưa sửa nguồn):** (1) Tools:
  chi phí nâng cấp bậc 2/3 + nguyên liệu hiếm `da-quy` + sức chở theo bậc
  đều PROVISIONAL; Đèn Soi bậc 3 "hotspot hiếm 1 khung/ngày" chưa có
  hotspot hiếm thật trong `PXB_Hotspot` (cả 5 hotspot đều "thường");
  SoTay bậc 3 gợi ý "nguyên liệu còn thiếu" đọc từ `PXB_Crafting`
  (cần Crafting có nguyên liệu — đã có túi chung `$gameSystem.pxbMaterials`).
  (2) Online/SaveCloud: server chưa có auth (endpoint `/ledger/gift` hiện
  tin playerId trong body — chỉ dùng nội bộ), chưa có endpoint guild/đấu
  giá/save-sync; outbox gift chỉ gửi lại khi online, chưa có giới hạn
  số lần thử lại. (3) Tiles: tint tường vàng/xám ấm chỉ là bước đầu —
  art pass chấm rubric (§4 bước 3) vẫn chưa làm; xe máy + dây điện + sạp
  lá chuối + thùng xốp vẫn phải vẽ thêm.
- **Còn lại chưa xong (Giai đoạn 2–4):** PXB_Isometric v3 (atlas mode —
  việc tiếp theo lớn nhất), PXB_MarketBattle (luật chưa chốt),
  Map003–018 chưa có, img/audio trống (atlas PNG chờ đưa vào repo bằng
  git push / upload web). Checklist C1–C9 (§6 roles-qc) vẫn giữ cho
  đường Unity (phương án dự phòng); đường chính nay là Giai đoạn 1–5 của
  `docs/architecture-nadia.md`.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~03:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **223/223 PASS, exit 0** — tăng từ 219/219: nhóm T19 mới (4 mục)
  khóa plugin mới; `node --check` nay 13/13 file JS nadia.
- **1 plugin slice mới (Giai đoạn 2):** `PXB_Social.js` (585 dòng, port
  `Social.cs` / GDD Mục 8: 7 loại quan hệ, 6 stage, bỏ bê 7 ngày giảm thân
  thiết, hỗ trợ +20% EXP, solo chậm 40%, ly hôn, hội bạn tan sau 7 ngày
  không họp, NPC bạn thân lấp chỗ `seedSlice`; quan hệ lưu object thuần
  trong `$gameSystem.pxbSocial` để vào save; plugin command Interact /
  Neglect / AdvanceStage / Divorce / SeedSlice; smoke 85/85 PASS) +
  `plugins.js` nay 11 plugin (…Economy → Social).
- **Kế hoạch tileset CC0 (luồng song song):** `docs/tileset-plan.md` mới
  (230 dòng): Kenney Isometric Tiles City/Landscape/Buildings/Roads
  (CC0, URL đã verify) là ưu tiên 1; Screaming Brain 1000+ Isometric
  Floor Tiles (OpenGameArt, CC0, 1.049 tile, 256×128 / 128×64) ưu tiên 2
  cho sàn; Unity Top-Down Starter Kit chỉ tham khảo (không phải tileset
  iso). Kết luận kỹ thuật: KHÔNG ép tile iso 64×32 vào layout tileset MV
  (ô vuông 48×48) — dùng atlas theo khu qua `PXB_Isometric.js`, tile
  downscale về 64×32, tường/vật cao vẽ dạng sprite neo đáy. PNG nhị phân
  KHÔNG push được qua snapshot push (chỉ nhận UTF-8) — đưa vào repo bằng
  git push từ máy có git hoặc upload web GitHub; chưa tải file nhị phân
  nào vào repo trong lần này.
- **Lệch / PROVISIONAL ghi nhận khi port (chưa sửa nguồn):** (1) Social:
  `applyNeglect` trả drop tính theo công thức (có thể lớn hơn phần trừ
  thực khi thân thiết kẹp về 0) + KHÔNG cập nhật `lastInteractionGameDay`
  (quirk C# — gọi 2 lần cùng ngày trừ 2 lần, event chỉ gọi 1 lần/ngày);
  `advanceStage` không kiểm tra Kind (để GDD/PM xem lại, như đã ghi từ
  18/11); `divorce` dùng `||` (bug đã sửa 18/11 — T19d khóa hồi quy, chỉ
  Spouse đang Cuoi mới ly hôn được); `seedSlice` thêm NPC "Bạn thân"
  (personId `ban-than`, tên TẠM — GDD Mục 11 chưa chốt tên, PXB_Story
  sau này thay bằng NPC thật); solo penalty 40% là điểm giữa khoảng
  30–50% đã chốt; ngưỡng stage 50/70/80 + thân thiết khởi đầu 20 +
  interact +5 + giảm bỏ bê 10/bước đều PROVISIONAL. (2) Tileset: kích
  thước tile Kenney + tên file thật + checksum SHA-256 CHƯA CÓ (ghi trong
  tileset-plan.md §6, đo sau khi tải).
- **Còn lại chưa xong (Giai đoạn 2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_Titles/Story…) chưa viết. Việc tiếp theo lớn nhất:
  PXB_Titles.js + PXB_Story.js, rồi tải tile Kenney/SBS + đóng atlas theo
  tileset-plan.md §4 (PNG đưa vào repo bằng git push, không qua snapshot).
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~02:55 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **219/219 PASS, exit 0** — tăng từ 215/215: nhóm T18 mới (4 mục)
  khóa 2 plugin mới; `node --check` nay 12/12 file JS nadia.
- **2 plugin slice mới (Giai đoạn 2):** `PXB_Education.js` (589 dòng, port
  GDD Mục 5 / `GameBalance.Degrees`: 5 bậc đúng học phí/ngày/Trí/EXP/Danh
  vọng/mentor; enroll chặn `chua-du-tri` / `can-mentor` (Tiến sĩ) /
  `khong-du-tien` / `da-co-bang` / `dang-hoc`; tiến độ theo ngày game,
  tốt nghiệp ghi `pendingExp`/`pendingFame` để event áp; khóa ngắn hạn
  3–7 ngày, 2–10 triệu, +10 một chỉ số phụ; học bổng xét Trí + tiền;
  ghế/khóa 20–30 + `registerOrder`; smoke 89/89 PASS) +
  `PXB_Economy.js` (577 dòng, port `Economy.cs`: catalog đủ 17 món
  6 nhà + 6 xe + 2 điện thoại + 3 quần áo đúng giá/chỉ số; ví riêng
  tiền mặt/tiết kiệm/`creditScore` 100; lãi 0,5%/tháng game 30 ngày;
  gửi/rút tiết kiệm; mua nhà/xe-sang +50 Danh vọng; đấu giá người bán
  nhận giá − phí 5%; barter; chia tài sản ly hôn; set bonus đủ 3 món;
  dress-code; 4 hàm cấm luôn false; smoke 78/78 PASS); `plugins.js`
  nay 10 plugin (Balance → … → PhoneHub → Education → Economy).
- **3 lỗi script trong lần chạy này (đã sửa, chạy lại PASS):** T14t/T16d/
  T17c lúc đầu FAIL giả — 3 check cũ bắt đúng 8 plugin (`== 8`), nay
  đã 10. Đã sửa thành `>= 8` (chỉ khóa 8 plugin gốc + thứ tự); T18c
  mới đếm đủ 10.
- **Lệch / PROVISIONAL ghi nhận khi port (chưa sửa nguồn):** (1)
  Education: học phí trả 1 lần lúc đăng ký (GDD chưa chốt trả trước
  hay góp); không học lại bằng đã có/bằng cao hơn (GDD chưa chốt học
  nhảy bậc); ngưỡng học bổng Trí ≥ 60 + tiền < 20tr (GDD chỉ nói
  "người nghèo mà Trí cao"); ghế 20–30 + thứ tự đăng ký, plugin không
  tự chặn hết ghế; tốt nghiệp chỉ ghi `pendingExp`/`pendingFame`/
  `pendingStatGain` để event áp (chưa có hệ EXP/Danh vọng chung, không
  tự gọi PXB_Stats); được học song song 1 bằng + 1 khóa ngắn hạn
  (GDD chưa chốt học chồng). (2) Economy: ví riêng trong
  `$gameSystem.pxbEconomy`, KHÔNG dùng `$gameParty.gold()` như Jobs —
  khi nối MV thật cần đồng bộ 1 chiều qua event; quirk
  `Buy("phong-tro")` giữ đúng C# (trừ 2tr thuê nhưng vẫn thêm vào
  Owned nên tổng tài sản không đổi); dress-code chỉ xét đồ loại
  Clothes nên xe sang set "Sang trọng" vẫn KHÔNG qua.
- **Còn lại chưa xong (Giai đoạn 2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_Social/Titles/Story…) chưa viết. Việc tiếp theo lớn nhất:
  PXB_Social.js, rồi tileset CC0 + tile data thật cho Map001–002 để mở
  trình duyệt thấy map Xóm Trọ Cũ.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~01:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **215/215 PASS, exit 0** — tăng từ 211/211: nhóm T17 mới (4 mục)
  khóa 2 plugin mới; `node --check` nay 10/10 file JS nadia.
- **2 plugin slice mới (Giai đoạn 2):** `PXB_Crafting.js` (537 dòng, port
  `Crafting.cs`: 3 công thức đúng số C# — xe-đẩy 1/2/2, đèn-soi 2/2, quà-tặng
  2/1; ToolBehaviour 4 tool × 3 bậc; CanCraft/Craft/MissingIngredients; Craft
  trừ đúng + xóa key về 0; học công thức qua NPC `learnRecipe`/`craftCurrent`
  chặn `chua-hoc-cong-thuc`; túi nguyên liệu chung `$gameSystem.pxbMaterials`
  với Hotspot; smoke 52/52 PASS) + `PXB_PhoneHub.js` (381 dòng, port
  `PhoneHub.cs`: 9 tab đúng thứ tự, Open/Close/Toggle/SelectTab,
  Notify/Unread/TotalUnread, callback `onTabChanged`/`onOpenChanged`, plugin
  command, phím P qua `Scene_Map.update`; smoke 56/56 PASS); `plugins.js`
  nay 8 plugin (Balance → Stats → Time → Isometric → Hotspot → Crafting →
  Jobs → PhoneHub).
- **Bug thật phát hiện khi smoke test PhoneHub (đã sửa bằng code):** gọi
  `install()` 2 lần wrap core 2 lần khiến plugin command/phím P kích hoạt
  2 lần — đã sửa bằng guard `_installed` (chỉ khóa khi lần trước đã móc
  được core), sau đó 56/56 mới đạt.
- **Lệch phát hiện khi port (ghi nhận, chưa sửa nguồn):** (1) Crafting: GDD
  Mục 6/7 không có số chế tạo nào (chỉ nhắc "cổng tiến trình" + side quest
  chế quà tặng) — toàn bộ số lấy từ `Crafting.cs`, PROVISIONAL; chỉ có công
  thức bậc 1 (C# cũng vậy — công thức nâng cấp tool bậc 2/3 thuộc
  `PXB_Tools.js` / GDD chưa chốt); `item:qua-tang` chưa có Item trong
  `data/Items.json` nên plugin chỉ đếm trong `craftedItems`, chưa cộng vào
  `$gameParty`; cơ chế "đã học" là thêm mới (C# chỉ ghi `UnlockNote` bằng
  chữ) — mặc định chưa học công thức nào, New Game / `PXB_Story` sau này
  phải gọi `learnRecipe`, nếu không slice chưa chế được gì; "cổng tiến
  trình" chưa nối mở khu (do `PXB_Story`/`PXB_Hotspot` giữ). (2) PhoneHub:
  Notify đếm cả khi đóng + Open/SelectTab luôn kích hoạt TabChanged kể cả
  đúng tab hiện tại — giữ đúng C#, để GDD/PM xem lại; chính tả "Sức khỏe"
  theo C# (GDD viết "Sức khoẻ"); phím P / nút điện thoại không có trong
  `PhoneHub.cs` — plugin thêm hook phím P, nút trên màn hình là việc của
  lớp UI, chưa làm.
- **Còn lại chưa xong (Giai đoạn 2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_Education/Economy/Social/Titles/Story…) chưa viết. Việc tiếp
  theo lớn nhất: PXB_Education.js + PXB_Economy.js, rồi tileset CC0 + tile
  data thật cho Map001–002 để mở trình duyệt thấy map Xóm Trọ Cũ.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~00:50 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **211/211 PASS, exit 0** — tăng từ 206/206: nhóm T16 mới (5 mục)
  khóa Isometric v2 + 2 plugin mới; `node --check` nay 8/8 file JS nadia.
- **PXB_Isometric v2 — ĐÃ MÓC TILEMAP (việc tiếp theo lớn nhất, xong):**
  `PXB_IsoTilemap` kế thừa `Tilemap` (prototype chain nối trong `install()`),
  vẽ tile thường (B–E + A5) thành hình thoi 64×32 bằng sprite MV quay 45° +
  co (64/(48√2), 32/(48√2)); `Game_CharacterBase.screenX/screenY` chiếu
  isometric (giữ `screenZ` gốc — sắp xếp chiều sâu tự đúng vì nhân vật là
  con của Tilemap và `_sortChildren` xếp theo z rồi y iso);
  `Spriteset_Map.createTilemap` dựng IsoTilemap (fallback về cách dựng gốc
  nếu lỗi); cuộn map đổi `origin` MV thành độ dời iso của lớp tile.
  Smoke test stub core MV (`/tmp/pxb-iso-smoke.js`, không commit): **36/36
  PASS** (origin map 12×9 = {280, 472}, screenX/screenY (5,4) = (344, 648),
  vẽ đúng 2 tile thường + bỏ 1 autotile, sprite thoi đúng frame/quay/tỉ lệ/
  vị trí, pan origin (48,0) = (−32,−16), alias createTilemap);
  `install()` không có core trả false. Giới hạn v2: autotile A1–A4, bóng,
  mép bàn CHƯA vẽ (đếm vào `stats`); vẽ hết map không cắt viewport; cuộn
  vẫn theo luật MV gốc (tile 48px) nên tâm cuộn chỉ gần đúng.
- **2 plugin slice mới (Giai đoạn 2):** `PXB_Hotspot.js` (484 dòng, port
  `Exploration.cs`: 5 hotspot, nhặt 1 lần/ngày game, chặn sai khung
  `wrong-frame`, GuideHint 4 NPC + Bạn thân, lưu `$gameSystem.pxbHotspot`;
  smoke 26/26 PASS) + `PXB_Jobs.js` (548 dòng, port `Jobs.cs`: 3 nghề,
  lương mốc 50/0/100, khung tốt +25%, quota 14, cung–cầu xoay tuần
  PROVISIONAL, thi chứng chỉ theo GDD; smoke 40/40 PASS); `plugins.js`
  nay 6 plugin (Balance → Stats → Time → Isometric → Hotspot → Jobs).
- **Lệch phát hiện khi port (ghi nhận, chưa sửa nguồn):** (1) Hotspot:
  `Exploration.Explore()` KHÔNG kiểm tra khung (chỉ dùng `BestFrame` để
  sắp xếp + sáng hơn) nhưng architecture §6 dòng 5 ghi "chỉ có đồ đúng
  khung" — plugin chặn sai khung theo architecture, khi C# sửa theo thì
  khớp; `districts.md` không có dữ liệu hotspot nào; `Exploration.cs`
  không định nghĩa độ hiếm (cả 5 hotspot đều "thường"). (2) Jobs:
  `Jobs.cs` hoàn toàn không có logic thi chứng chỉ — hệ thi (phí 5–20tr,
  trượt mất phí, chờ tuần sau, nạp mua thêm 1 lượt/tuần) chỉ có trong GDD
  Mục 6 + architecture §4.4; plugin triển khai thi theo GDD. Không lệch
  số nào khác (lương/quota/khung/cung–cầu khớp Jobs.cs + GameBalance +
  PXB_Balance + GDD).
- **Còn lại chưa xong (Giai đoạn 1–2):** tile data toàn 0 (chưa có tileset
  CC0 nên IsoTilemap chưa vẽ được gì thật), img/audio trống, plugin còn
  lại (PXB_PhoneHub/Crafting/Education/Economy/Social/Titles/Story…)
  chưa viết. Mở trình duyệt lúc này hết 404 ở core nhưng vẫn chưa chơi
  được — trạng thái thật, không giấu.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

## Lần chạy mới nhất: 19/11/2026 ~00:05 (giờ VN)

- Lệnh: `python3 src/server/tests/check_static.py` (chạy từ gốc repo)
- Kết quả: **206/206 PASS, exit 0** — tăng từ 198/198: nhóm T15 mới (8 mục)
  khóa core MV + 2 plugin mới.
- **Core MV v1.6.1 ĐÃ VỀ (Giai đoạn 1):** 12/12 file trong `src/nadia/www/`
  (6 `js/rpg_*.js` + 6 `js/libs/*`, tổng 2.341.224 byte), `node --check`
  12/12 PASS. Nguồn: `rpgtkoolmv/corescript` tag community 1.3b — repo
  KHÔNG có tag v1.6.1; tag 1.3b chính là core v1.6.1 (header mỗi file ghi
  "v1.6.1 (community-1.3b)"); 6 file rpg build bằng đúng `concat.js` của
  repo; pixi.js v4.5.4 lấy từ bundle MV 1.6.1 (MIT). Chỉ lấy code core +
  libs MIT — không lấy asset/nhạc/nhân vật/map/cốt truyện của Nadia hay
  RPG Maker. 1 lỗi script trong lần chạy này (đã sửa, chạy lại PASS): T15g
  lúc đầu FAIL giả — check tìm "core MV v1.6.1" thường trong khi comment
  index.html ghi "Core MV v1.6.1" hoa C. 1 lỗi phát hiện khi viết T15 (đã
  sửa trong script, không phải code game): `secret_pat` quét trúng chuỗi
  "password=<redacted>" trong comment ví dụ của pixi.js — T14ab nay chỉ quét file
  do mình viết; code upstream MIT được khóa riêng ở T15a–c (header +
  node --check + UTF-8).
- **2 plugin slice mới (Giai đoạn 2, port từ C#):** `PXB_Stats.js` (261
  dòng: 3 gốc Thể/Trí/Tâm + 4 trộn Kỷ/Dũng/Sáng/An Yên + trần tổng 300
  PROVISIONAL + Train đánh đổi + lưu `$gameSystem.pxbStats` đi theo save)
  + `PXB_Time.js` (268 dòng: 1 ngày 30 phút, 3 khung 10 phút, miss không
  phạt, sự kiện thứ 7 20:00 giờ game); `node --check` PASS; smoke test
  logic thuần qua `module.exports` PASS (ctor tổng = 300, trộn, An Yên,
  Train, biên khung, sự kiện); `plugins.js` nay 4 plugin (Balance → Stats
  → Time → Isometric). Điểm PROVISIONAL mới: ánh xạ "20:00 giờ game" =
  phút thật thứ 25 của ngày; ngày game 1 = Thứ Hai; switch sự kiện = 1;
  phân bổ khởi đầu mặc định 100/100/100 — GDD chưa chốt.
- **Còn lại chưa xong (Giai đoạn 1):** `PXB_Isometric` chưa móc Tilemap
  (nay core đã có — việc tiếp theo lớn nhất); tile data toàn 0 (chưa có
  tileset CC0); img/audio trống; plugin còn lại (PXB_Hotspot/Crafting/
  Jobs/PhoneHub…) chưa viết. Mở trình duyệt lúc này hết 404 ở core nhưng
  vẫn chưa chơi được — trạng thái thật, không giấu.
- **Vẫn chưa chạy được:** xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).

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

## Hiện trạng thật (19/11/2026 ~00:05, lúc viết báo cáo này)

- Kiểm tra tĩnh: **206/206 PASS** (`check_static.py`, gồm nhóm T15 mới khóa
  core MV + 2 plugin mới).
- Core MV v1.6.1 ĐÃ CÓ trong repo (12 file, 2.341.224 byte, MIT, tag
  community 1.3b); plugin `PXB_Stats.js` + `PXB_Time.js` đã viết (port
  Stats.cs/TimeSystem.cs), `node --check` PASS, smoke test logic thuần PASS.
- Chưa chơi được: `PXB_Isometric` chưa móc Tilemap (việc tiếp theo lớn
  nhất, nay core đã có), tile data toàn 0, img/audio trống, plugin
  Hotspot/Crafting/Jobs/PhoneHub chưa viết.
- Điểm PROVISIONAL mới (PXB_Time): ánh xạ 20:00 giờ game = phút thật thứ
  25 của ngày, ngày game 1 = Thứ Hai, switch sự kiện thứ 7 = 1 — GDD chưa chốt.
- Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại): `PhoneHub.Notify` đếm cả
  khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")` tính tiền thuê
  vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: xUnit (17 test) và EditMode test (219 test) chưa biên
  dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test` vẫn kẹt
  RAM — chạy qua GitHub Actions; Unity chưa có).

## Hiện trạng thật (19/11/2026 ~04:50, lúc viết báo cáo này)

- Kiểm tra tĩnh: **228/228 PASS** (`check_static.py`, gồm nhóm T20 mới,
  5 mục; 2 check cũ T18c/T19b nới `== 11` thành `>= 11` theo đúng mẫu
  các đợt trước — T20b đếm đủ 13).
- 2 plugin slice mới, làm song song 2 luồng: `PXB_Titles.js` (415 dòng,
  port TitleConflict.cs / GDD Mục 3: bảng chặn 7 dòng, chặn 2 chiều,
  không phân biệt hoa/thường, phe Chính/Tà/Trung lập, quest đổi phe
  "Cải tà quy chính"; smoke 68/68 PASS) + `PXB_Story.js` (454 dòng,
  port PlayerProgress.cs / GDD Mục 9: 5 chương, 6 kết thúc, tụt bậc
  chương 3; smoke 109/109 PASS); `plugins.js` nay 13 plugin
  (Social → Titles → Story); `node --check` 15/15 file JS nadia.
- Lệch mới phát hiện (đã ghi trong @help của 2 plugin, plugin giữ đúng
  C#): GDD Mục 3 không nhắc tên quest "Cải tà quy chính" (chỉ có trong
  comment C#) và không liệt kê phe của từng danh hiệu (plugin suy ra từ
  bảng chặn, PROVISIONAL); GDD nói danh hiệu có "yêu cầu chỉ số" và
  hiển thị "1 chính + 2–3 phụ" nhưng C# không có logic đó; chương 2
  GDD ghi "Trí 40 hoặc Cao đẳng" nhưng C# chỉ kiểm Trí/Danh vọng
  (Cao đẳng cho Trí 40 nên trùng); chương 5 Học giả GDD ghi cần bằng
  Tiến sĩ nhưng C# chỉ kiểm Trí/Danh vọng; chương 5 Gia đình GDD ghi
  cần rank Trung lưu nhưng C# chỉ kiểm vợ/chồng + An Yên 80.
- Check T20e bắt sai tên chương 1 lần (đòi `LenPho` kiểu PascalCase
  trong khi plugin dùng `CHAPTERS.LEN_PHO` số 1–5, đúng enum C#) — đã
  sửa danh sách token của check, không sửa plugin.
- CHƯA chơi được: tile data toàn 0, chưa có tileset CC0. Plugin Phase 1
  nay ĐÃ ĐỦ 13/13 theo `docs/architecture-nadia.md` §6 (#1–13, Titles
  #11 + Story #12 là 2 cái cuối); còn lại là Phase 2: `PXB_MarketBattle`
  (luật Bụi Đời Chợ Cá chưa chốt), `PXB_Online.js`, `PXB_SaveCloud.js`.
  Checklist C1–C9 (§6) vẫn giữ cho đường Unity (phương án dự phòng);
  đường chính nay là Giai đoạn 1–5 của `docs/architecture-nadia.md`.
  Việc tiếp theo lớn nhất: tải tile Kenney/SBS + đóng atlas theo
  `docs/tileset-plan.md` §4, rồi tile data thật cho Map001–002 để mở
  trình duyệt thấy map Xóm Trọ Cũ.
- Hành vi lạ còn lại (chưa sửa — để GDD/PM xem lại): `PhoneHub.Notify`
  đếm cả khi đóng, `SuggestEnding` ưu tiên cứng, `Buy("phong-tro")`
  tính tiền thuê vào tài sản, `AdvanceStage` không kiểm tra Kind.
- Vẫn chưa chạy được: xUnit (17 test) và EditMode test (219 test) chưa
  biên dịch/chạy lần nào (dotnet 8.0.428 có ở `~/.dotnet`, `dotnet test`
  vẫn kẹt RAM — chạy qua GitHub Actions; Unity chưa có).
