# Server — .NET 8 Modular Monolith

Khung placeholder (chưa phải solution .NET đầy đủ — sẽ tạo bằng `dotnet new` khi bắt đầu làm thật).

## File đã có (skeleton chạy được, chưa có DB thật)

```
src/
  PhoXoBo.Server.csproj — project web .NET 8 (net8.0, Nullable, ImplicitUsings)
  Program.cs            — minimal API, chỉ có GET /health -> {"status":"ok", ...}
```

Chạy (cần .NET 8 SDK — máy này chưa có, chỉ viết file, chưa build):

```
dotnet run --project src/server/src/PhoXoBo.Server.csproj
curl http://localhost:5000/health
```

Chưa có: PostgreSQL / Redis, auth, ledger, module Identity / Economy / Inventory /
Social / Leaderboard / Content (xem cấu trúc module dự kiến bên dưới).

## Stack chốt

- .NET 8, modular monolith: 1 deployable, chia module theo business boundary.
- PostgreSQL là source of truth; Redis chỉ là read model / cache (leaderboard, session, rate-limit).
- Kinh tế server-authoritative, double-entry ledger: mọi thay đổi số dư = 1 entry ledger + cập nhật wallet trong cùng 1 DB transaction.
- Offline-first: client ghi local SQLite + outbox, sync nền bằng idempotency key + sync token; conflict policy theo loại dữ liệu, không last-write-wins toàn cục.

## Cấu trúc module (dự kiến)

```
src/
  Modules/
    Identity/     — tài khoản, đăng nhập
    Economy/      — tiền, ledger, ngân hàng, đấu giá
    Inventory/    — vật phẩm, nhà, xe, quần áo
    Social/       — bạn bè, cặp đôi, gia đình, công ty/guild
    Leaderboard/  — xếp hạng (Redis Sorted Set làm read model)
    Content/      — quest, chương truyện, sự kiện
  Shared/         — contract, event in-process, outbox
tests/
  <Module>.Tests/ — architecture test khóa biên module
```

## Quy tắc

- Không microservices từ đầu; tách service chỉ khi DAU vượt ngưỡng (xem `docs/architecture.md`).
- Không tin client: mọi reward / tiền đều validate ở server khi sync.
- Không dùng Redis làm source of truth cho tiền / inventory / progression.
- Chi tiết tham khảo: `docs/references.md` (Orleans, Nakama, Colyseus, Mirror).
