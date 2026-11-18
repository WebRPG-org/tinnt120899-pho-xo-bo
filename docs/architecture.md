# Kiến trúc Phố Xô Bồ — Đa nền tảng

Tóm tắt từ bản Kiến trúc Đa nền tảng (web artifact `kien-truc-pho-xo-bo-da-nen-tang`).

## Nguyên tắc

1. Một codebase, đa nền tảng: iOS / Android / PC / Web, cross-save.
2. Server-authoritative cho kinh tế, chống gian lận tiền/vật phẩm.
3. Offline-first: chơi offline, đồng bộ khi có mạng.
4. Modular monolith trước, tách service khi DAU vượt ngưỡng.
5. Pháp lý VN là ranh giới cứng: không đổi tiền thật, không cờ bạc, không lootbox tiền thật.

## Stack chốt (đề xuất)

- **Client:** Unity, 2.5D isometric
- **Backend:** .NET 8, modular monolith, 6 module
- **DB:** PostgreSQL + read replica, Redis cache
- **Hạ tầng:** CDN + Gateway, auto-scale theo DAU
- **LiveOps:** Remote config, sự kiện theo lịch, A/B test

## Lộ trình scale (4 giai đoạn)

1. Slice online tối thiểu
2. Tăng trưởng — tách Realtime / Economy
3. Mở rộng — Web ra mắt ở giai đoạn này
4. Vận hành lớn — tách service theo nhu cầu thật

Số DAU / chi phí trong bản kiến trúc là mốc quy hoạch ước tính, không phải số liệu thật.

## 6 quyết định cần chốt

Xem bản web kiến trúc — cần chủ chốt trước khi khoá bản sale.
