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
```

## Quy tắc

- Code MIT, comment tiếng Việt.
- Không asset có bản quyền trong repo — art / nhạc / model dùng placeholder hoặc asset CC0, ghi rõ nguồn.
- Mọi số liệu gameplay phải khớp `docs/gdd.md`.
- Điện thoại là menu chính (overlay hub), không thay thế thế giới 2.5D.
