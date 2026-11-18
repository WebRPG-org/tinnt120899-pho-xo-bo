# CI build/test — xử lý nút thắt "VM không có dotnet/Unity"

Ngày viết: 18/11/2026. Trạng thái: workflow đã viết xong, **chưa chạy lần nào
trên GitHub** (cần secret Unity của chủ mới chạy được job Unity; job dotnet
chạy được ngay khi push workflow lên main).

## 1. Nút thắt

- VM làm việc: Ubuntu 24.04, 4 CPU, 7.7 GB RAM (lúc kiểm tra chỉ còn ~0.5 GB
  trống), 143 GB disk trống, user root.
- Không có `dotnet`, không có Unity Editor/Hub, `/tmp` chỉ là tmpfs 512 MB.
- Test xUnit server (17 test) + Unity EditMode (26 test) chỉ viết xong, chưa
  biên dịch/chạy lần nào.

## 2. Cách khả thi nhất: GitHub Actions làm máy build (KHUYẾN NGHỊ)

File: `.github/workflows/build-test.yml` (chính) + `.github/workflows/activation.yml`
(lấy file kích hoạt license, chạy tay 1 lần).

| Job | Chạy khi nào | Cần gì | Thời gian ước tính |
|---|---|---|---|
| `dotnet-test` | Mọi push + PR lên main | Không cần secret | Vài phút |
| `unity-test` (EditMode) | Mọi push + PR, sau dotnet-test | Secret Unity | ~10–20 phút |
| `build-webgl` | Chỉ push main | Secret Unity | 60+ phút lần đầu, 30–50 phút khi đã cache Library |
| `deploy-pages` | Sau build-webgl thành công | Bật GitHub Pages (Source: GitHub Actions) | Vài phút |

Link chơi sau khi deploy: `https://tinnt120899.github.io/pho-xo-bo/`

### Secret cần có (repo Settings → Secrets and variables → Actions)

| Secret | Lấy ở đâu |
|---|---|
| `UNITY_LICENSE` | Toàn bộ nội dung file `Unity_lic.ulf` (xem mục 3) |
| `UNITY_EMAIL` | Email tài khoản Unity của chủ |
| `UNITY_PASSWORD` | Mật khẩu (nên dùng app password nếu Unity hỗ trợ) tài khoản Unity |
| `UNITY_SERIAL` | CHỈ khi dùng Unity Pro/Plus — thay cho `UNITY_LICENSE` |

Quy tắc: secret chỉ truyền qua `env:` của từng step game-ci, không echo,
không đưa vào `run:`, không commit vào repo.

### 3. Lấy file license .ulf — các bước cho chủ

1. Push 2 file workflow lên main (parent push, không cần secret).
2. Vào repo → Actions → **Acquire Unity License** → Run workflow.
3. Tải artifact `unity-activation-file` (file `.alf`) về máy.
4. Vào https://license.unity3d.com/manual, upload `.alf`, chọn Unity Personal,
   tải file `.ulf` về.
5. Vào repo Settings → Secrets → Actions → New secret `UNITY_LICENSE`,
   dán toàn bộ nội dung file `.ulf`. Thêm `UNITY_EMAIL`, `UNITY_PASSWORD`.
6. Push 1 commit bất kỳ lên main để workflow `build-test.yml` chạy.

### 4. Nếu Personal bị từ chối (RỦI RO LỚN NHẤT — đã xác minh từ 2 nguồn mâu thuẫn)

- Nguồn A (GameCI devkit skill, xác minh 28/09/2026): kích hoạt offline đã
  đóng với Personal — trang manual trả *"You are not eligible to activate
  your license offline. Offline activation is available only for Enterprise
  and Industry seats."* Hub mới ghi `UnityEntitlementLicense.xml` gắn máy,
  không dùng được trong container CI.
- Nguồn B (PR Unity-MCP, 07/2026; nhiều guide khác): flow .alf → .ulf vẫn
  làm được với Personal, chỉ cần tạo .alf **trong CI** để .ulf gắn đúng
  HardwareId của runner.

Kết luận: **thử flow mục 3 trước (không tốn tiền)**. Nếu Unity từ chối ở
bước 4, các phương án thay thế theo thứ tự:

1. **Unity Pro/Plus** — lấy `UNITY_SERIAL` ở trang subscriptions của Unity ID,
   dùng secret `UNITY_SERIAL` + email/password. Tốn phí thuê bao, nhưng là
   đường chính thức duy nhất được GameCI hỗ trợ chắc chắn.
2. **Self-hosted runner** — 1 máy (PC của chủ hoặc VPS đủ mạnh) cài Unity Hub,
   kích hoạt license Personal bằng Hub 1 lần trên chính máy đó, rồi đăng ký
   làm GitHub self-hosted runner. License gắn máy đó nên CI chạy được.
   Nhược điểm: máy phải online khi CI chạy, chủ tự bảo trì.
3. **Bỏ job Unity trên CI, chỉ chạy dotnet-test trên CI** — Unity test/build
   làm tay trên máy có Unity. Vẫn có CI cho server, nhưng không có link
   WebGL tự động.

## 5. Các cách khác đã kiểm tra (18/11/2026, trên chính VM này)

### 5.1 Cài .NET 8 SDK trên VM — KHẢ THI, ĐÃ LÀM ĐƯỢC (xem mục 6)

- `apt install dotnet-sdk-8.0`: **không có gói** — `apt-cache search` trả rỗng
  trên Ubuntu 24.04 của VM (cần thêm Microsoft repo `noble` mới có).
- **dotnet-install script (khuyến nghị cho VM)**: tải
  https://dot.net/v1/dotnet-install.sh, chạy
  `bash dotnet-install.sh --channel 8.0 --install-dir ~/.dotnet`.
  Không cần sudo, cài vào thư mục home (giữ được qua restart).
- **Bẫy đã gặp 2 lần khi cài trên VM này:**
  1. `/tmp` chỉ 512 MB (tmpfs) → tải file 217 MB rồi giải nén thì hết chỗ.
     Sửa: `export TMPDIR=~/.tmp` (nằm trên disk 143 GB) trước khi cài.
  2. `tar` báo `Cannot change ownership to uid 2001: Operation not permitted`
     → tar thoát lỗi, nhưng file vẫn giải nén đủ và `dotnet --version` chạy
     được. Đây là giới hạn user namespace của VM, không phải lỗi cài đặt.

### 5.2 Cài Unity Hub / Editor headless trên VM — KHÔNG KHẢ THI

- Editor 2022.3.62f1 Linux ~5–8 GB + module WebGL ~1 GB, tải lâu, nhưng disk
  đủ (143 GB).
- **RAM là nút thắt**: VM có 7.7 GB, lúc kiểm tra chỉ còn ~0.5 GB trống;
  Unity Editor + build WebGL cần tối thiểu 8 GB (khuyến nghị 16 GB).
  Build WebGL trên máy này gần như chắc chắn bị OOM-kill.
- License cũng là vấn đề: Hub headless cần kích hoạt online bằng tài khoản
  Unity của chủ (không được đưa mật khẩu qua chat), và license gắn máy ảo
  này — VM thay thế là mất license.
- Kết luận: đừng cài Unity trên VM này.

### 5.3 GitHub Codespaces — KHẢ THI CHO DOTNET, KHÔNG CHẮC CHO UNITY

- Codespaces (máy 4-core/16 GB trở lên): cài dotnet, chạy `dotnet test`
  thoải mái qua devcontainer. Đây là phương án dự phòng tốt nếu VM này
  không cài được dotnet.
- Unity trong Codespaces: về lý thuyết cài được Editor headless như VM,
  nhưng vẫn vướng license Personal như mục 4 + tải Editor nhiều GB mỗi lần
  tạo codespace (trừ khi dùng image tự build sẵn). Chỉ nên thử sau khi
  GitHub Actions đã chạy được dotnet-test.

### 5.4 Replit — KHÔNG KHẢ THI CHO UNITY, CHỈ TẠM CHO DOTNET

- Replit (Nix): cài được dotnet qua Nix, chạy `dotnet test` được.
- Unity: không thực tế — giới hạn disk/RAM gói miễn phí, không tải được
  Editor nhiều GB, không có license flow. Chỉ dùng Replit để demo code
  server, không phải đường build game.

## 6. Kết quả thử trên VM (18/11/2026)

- `dotnet --version` → **8.0.428** (cài bằng dotnet-install script, xem bẫy
  ở 5.1). Đây là lần đầu VM này có dotnet.
- `dotnet test` cho server (chạy thật 2 lần, 18/11/2026):
  - **Restore + build: PASS.** Cả `PhoXoBo.Server` và
    `PhoXoBo.Server.Tests` biên dịch được, DLL tạo ra đầy đủ. Đây là lần
    đầu code server được biên dịch thật (trước đây chỉ kiểm tra tĩnh).
  - **Chạy test: FAIL — testhost không kết nối được.** Lần 1: timeout mặc
    định 90s. Lần 2 với `VSTEST_CONNECTION_TIMEOUT=300`: vẫn
    "vstest.console process failed to connect to testhost process after
    300 seconds". Không có OOM-kill trong `dmesg`.
  - Nguyên nhân khả dĩ nhất: VM chỉ có 1.5 CPU chia sẻ + lúc chạy chỉ còn
    ~175 MB RAM trống / 702 MB khả dụng — testhost + vstest không đủ tài
    nguyên để khởi động trong 300s. Không phải lỗi code (build pass) và
    không phải lỗi test (chưa chạy tới test nào).
  - Kết luận: **VM chạy được `dotnet build`, không chạy được `dotnet test`.**
    Muốn có kết quả test thật thì chạy trên GitHub Actions (job
    `dotnet-test`, runner 2–4 CPU / 7–16 GB RAM) hoặc máy khác đủ RAM.
- Unity: vẫn chưa có cách chạy trên VM (mục 5.2).
- Lưu ý: `bin/` và `obj/` sinh ra khi build đã nằm trong `.gitignore`
  nên không lọt lên GitHub khi push.

## 7. Bước tiếp theo cần chủ làm (theo thứ tự)

1. Push workflow lên main (parent làm, không cần chủ).
2. Chủ tạo 3 secret Unity theo mục 3 (cần tài khoản Unity + file .ulf).
   Nếu Personal bị từ chối ở bước lấy .ulf, chọn 1 trong 3 phương án ở mục 4
   và báo lại để đổi workflow.
3. Bật GitHub Pages: repo Settings → Pages → Source: GitHub Actions.
4. Sau lần chạy CI đầu tiên: đọc log job `dotnet-test` / `unity-test` /
   `build-webgl`, sửa lỗi nếu đỏ, rồi mới có link WebGL thật để test.
