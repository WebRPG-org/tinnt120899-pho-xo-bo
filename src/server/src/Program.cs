// Phố Xô Bồ — Server skeleton (.NET 8, modular monolith — xem docs/architecture.md)
// CHƯA CÓ DB THẬT: chưa nối PostgreSQL / Redis, chưa có auth.
// Ledger đã nối ở dạng trong bộ nhớ (EconomyLedger, singleton bên dưới) —
// khi nối DB thật, thay singleton này bằng bản ghi PostgreSQL, giữ nguyên
// tên endpoint. Mọi logic tiền / inventory / progression sau này phải
// validate ở server (server-authoritative), không tin client.
// Chạy: dotnet run --project src/server/src/PhoXoBo.Server.csproj
// Kiểm: GET http://localhost:5000/health -> {"status":"ok","game":"Pho Xo Bo"}
using PhoXoBo.Server;

var builder = WebApplication.CreateBuilder(args);

// Sổ cái double-entry trong bộ nhớ (xem EconomyLedger.cs). Đăng ký singleton
// để mọi request dùng chung 1 sổ — chưa phải DB thật, restart server là mất sổ.
builder.Services.AddSingleton<EconomyLedger>();

var app = builder.Build();

app.MapGet("/health", () => Results.Json(new
{
    status = "ok",
    game = "Pho Xo Bo",
    version = "0.1.0-skeleton",
    // Cố tình không trả thêm gì: chưa có DB / session / leaderboard để báo cáo.
    database = "not-connected",
}));

// Số dư tiền mặt + tiết kiệm của 1 người chơi, đọc từ sổ cái.
// BalanceOf() tính Có − Nợ nên người chơi chưa từng giao dịch trả về 0.
app.MapGet("/ledger/balance/{playerId}", (EconomyLedger ledger, string playerId) =>
    Results.Json(new
    {
        playerId,
        cashVnd = ledger.BalanceOf(playerId, LedgerAccount.PlayerCash),
        savingsVnd = ledger.BalanceOf(playerId, LedgerAccount.PlayerSavings),
    }));

// Tặng tiền trong game (không lãi, không phí) — gọi đúng EconomyLedger.Gift().
// Trùng IdempotencyKey -> 409 (đã tặng rồi, không tặng lần 2); số tiền <= 0
// hoặc thiếu key -> 400. Chưa có auth: endpoint này tin playerId trong body,
// chỉ dùng nội bộ cho tới khi có auth (xem docs/architecture.md).
app.MapPost("/ledger/gift", (EconomyLedger ledger, GiftRequest req) =>
{
    try
    {
        var ok = ledger.Gift(req.FromPlayerId, req.ToPlayerId, req.AmountVnd, req.GameDay, req.IdempotencyKey);
        return ok
            ? Results.Json(new { ok = true })
            : Results.Conflict(new { ok = false, error = "duplicate-idempotency-key" });
    }
    catch (ArgumentException ex)
    {
        return Results.BadRequest(new { ok = false, error = ex.Message });
    }
});

app.Run();

// Body JSON cho POST /ledger/gift. Khai báo sau top-level statements theo
// quy tắc C# (type declarations phải đứng sau mọi top-level statement).
public sealed record GiftRequest(
    string FromPlayerId,
    string ToPlayerId,
    long AmountVnd,
    int GameDay,
    string IdempotencyKey);
