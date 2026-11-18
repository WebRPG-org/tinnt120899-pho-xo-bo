# Client — Unity 2.5D

Khung placeholder C# (chưa phải project Unity đầy đủ — project Unity sẽ được tạo bằng Unity Hub / Unity 2022 LTS khi bắt đầu làm thật).

## Cấu trúc

```
Assets/Scripts/
  Stats.cs          — Hệ chỉ số 3 gốc + trộn (Mục 4)
  TimeSystem.cs     — Thời gian kiểu C: 1 ngày = 30 phút, 3 khung (Mục 1)
  District.cs       — Đúng 18 khu, 5 tầng (Mục 3)
  TitleConflict.cs  — Xung đột danh hiệu (Mục 3)
  GameBalance.cs    — Bảng số cân bằng: nguồn duy nhất cho số liệu đã chốt (Mục 5–9)
  PhoneHub.cs       — Điện thoại là menu chính: 9 tab overlay (Mục 2)
  Jobs.cs           — 3 nghề slice: bán rong, shipper, nhân viên quán + quota tuần (Mục 11)
  Inventory.cs      — Túi đồ slice: mua/dùng vật phẩm, buff tạm 1 khung (Mục 2 + 7)
  Exploration.cs    — Hotspot khám phá theo khu, fast-travel, NPC dẫn đường (Mục 2, chuẩn Nadia)
  Crafting.cs       — Chế tạo: 4 công cụ Việt nâng cấp đổi hành vi, công thức slice (Mục 2, chuẩn Nadia)
  Social.cs         — Hệ xã hội: người yêu/vợ chồng, bạn thân, hội bạn, gia đình; bỏ bê 7 ngày, +20% EXP (Mục 8)
  Economy.cs        — Ví + tài sản: lãi 0,5%/tháng, đấu giá phí 5%, barter, 4 hành vi cấm luôn trả false (Mục 7)
  PlayerProgress.cs — Tiến trình 5 chương gắn bậc + ending (Mục 9)
```

## Quy tắc

- Code MIT, comment tiếng Việt.
- Không asset có bản quyền trong repo — art / nhạc / model dùng placeholder hoặc asset CC0, ghi rõ nguồn.
- Mọi số liệu gameplay phải khớp `docs/gdd.md`.
- Điện thoại là menu chính (overlay hub), không thay thế thế giới 2.5D.
