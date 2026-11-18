// Phố Xô Bồ — Server skeleton (.NET 8, modular monolith — xem docs/architecture.md)
// CHƯA CÓ DB THẬT: chưa nối PostgreSQL / Redis, chưa có auth, chưa có ledger.
// File này chỉ là điểm khởi động tối thiểu để `dotnet run` lên được và
// trả health endpoint — mọi logic tiền / inventory / progression sau này
// phải validate ở server (server-authoritative), không tin client.
// Chạy: dotnet run --project src/server/src/PhoXoBo.Server.csproj
// Kiểm: GET http://localhost:5000/health -> {"status":"ok","game":"Pho Xo Bo"}
var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/health", () => Results.Json(new
{
    status = "ok",
    game = "Pho Xo Bo",
    version = "0.1.0-skeleton",
    // Cố tình không trả thêm gì: chưa có DB / session / leaderboard để báo cáo.
    database = "not-connected",
}));

app.Run();
