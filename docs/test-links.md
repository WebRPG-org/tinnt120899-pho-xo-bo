# Link test — Phố Xô Bồ

> Tài liệu này chỉ ghi trong repo local, chưa push GitHub trong đợt này.
> Code thật nằm ở repo private https://github.com/tinnt120899/pho-xo-bo.git (main, commit 42c68e14).
> Open-source ở đây = tận dụng thư viện bên thứ 3 mã mở, repo private được.

## 1. Các cách đưa link test — phân loại

### (a) Có ngay hôm nay

| Cách | Link | Test được cái gì | Hạn chế |
|---|---|---|---|
| Bản chơi thử web (HTML, Muse artifact static) | https://muse.ai/s/pho-xo-bo-ban-choi-thu-xgxf6i22xuaxhsxu/esYUW8oGARp1L6UI5xGauZprNmejmMTpQfFkhgYIo_A | Chơi 1 mình, 3 ngày: gacha xuất thân, 3 nghề (bán rong / shipper / nhân viên quán), 2 khu (Xóm Trọ Cũ, Chợ Đầu Mối), điện thoại là menu chính, chỉ số 3 gốc, thời gian 1 ngày = 30 phút / 3 khung, kết toán cuối Ngày 3 (đủ 900.000đ tiền trọ là thắng) | Chơi 1 mình trong phiên trình duyệt, không lưu tiến trình qua phiên, không online nhiều người. Sự kiện ngẫu nhiên (22%/ca) và màn kết toán cuối Ngày 3 đã viết trong code nhưng chưa kích hoạt được trong lần lái thử ngắn — cần chủ chơi thử và báo lại nếu không gặp. |
| Bảng prototype | https://muse.ai/s/bang-prototype-game-xa-hoi-viet-2-5d-nxz6i1xqxtxxxopf/NWOvxDcFu7EbQOHdbQTPTNBTLf2m89RaDsvLfiuFBSM | Xem đủ 12 mục đã chốt, chọn khu / nghề tương tác, máy tính đời sống | Không phải game chơi được. LƯU Ý: bảng vẫn liệt kê 19 khu (thừa Bến Du Thuyền), repo đã đúng 18 khu — cần 1 lượt sửa artifact riêng. |
| Bản kiến trúc đa nền tảng | https://muse.ai/s/kien-truc-pho-xo-bo-da-nen-tang-xfxq6i1xqxupxmxi7/sB0gsJOqpTwieJyGvQlIA9uIDUlqOdE2VsdeZR8I1E0 | Xem kiến trúc Unity + .NET 8, lộ trình scale, kéo thanh DAU xem cấp hạ tầng | Không phải game chơi được. Số DAU / chi phí là mốc quy hoạch ước tính. |
| Repo GitHub (private) | https://github.com/tinnt120899/pho-xo-bo.git | Đọc code thật: Unity C# (Stats, TimeSystem, District, TitleConflict, GameBalance), docs GDD 12 mục, LICENSE MIT | Không chơi được trực tiếp, chỉ xem code. Cần quyền truy cập repo private. |
| Trang test hub (mới) | Xem artifact `pho-xo-bo-link-test` | Tổng hợp tất cả link trên + checklist test | Chỉ là trang tổng hợp, không phải game mới. |

### (b) Cần build / deploy thêm

| Cách | Cần gì | Test được gì thêm |
|---|---|---|
| GitHub Actions build Unity WebGL | Máy runner có Unity 2022 LTS + license, Unity project thật ở `src/client/` (hiện chỉ là skeleton C#, chưa có project Unity đầy đủ: chưa có `.csproj`, scene, prefab, asset), secret `UNITY_LICENSE` / `UNITY_EMAIL` / `UNITY_PASSWORD` trong repo Settings, workflow dưới đây | Link WebGL chơi được trên trình duyệt, build từ code thật trong repo, không phải HTML viết tay. Đây là cách đúng để có link test từ code thật. |
| Muse artifact fullstack | Backend / lưu trữ, chuyển demo tĩnh thành app có lưu tiến trình | Lưu tiến trình qua phiên, sau này thêm online nhiều người. Cần làm sau, không phải hôm nay. |
| Replit / Lovable | Port demo web sang project Replit/Lovable, tài khoản của chủ | Link test chạy liên tục, sửa nhanh. Chỉ phù hợp bản web demo, không build Unity. |
| TestFlight / APK sideload | Unity build iOS/Android, Apple Developer / keystore Android, máy build có Unity | Test trên điện thoại thật. Cần build Unity thật trước. |
| itch.io / Steam | Build PC/WebGL ổn định, tài khoản itch.io/Steam, trang store | Phát hành test công khai / kín. Giai đoạn sau, không phải beta đầu tiên. |

### (c) Không khả thi trên VM này và vì sao

- **Không build được Unity trên VM này:** VM không có Unity Editor, không có .NET 8 SDK. Code C# / server trong repo chưa build / chưa chạy thử được ở đây. Cần máy có Unity 2022 LTS + .NET 8 SDK.
- **Không ký được APK / IPA trên VM này:** cần keystore / Apple Developer và Unity build, VM không có.
- **Không chạy được server .NET thật trên VM này:** backend chỉ là skeleton README, chưa có `.csproj`, chưa có code server chạy được.
- **Không tự tạo API key / PAT bằng tài khoản GitHub của chủ:** secret phải do chủ tạo, không cầm mật khẩu/token qua chat. Tạo repo qua Muse GitHub App đã thử và trả 403 ngay cả khi đã chọn All repositories — chủ phải tự tạo repo, Center push.

## 2. Hướng dẫn build Unity WebGL qua GitHub Actions (cần làm sau)

### Điều kiện tiên quyết (cần chủ / máy build chuẩn bị)

1. Unity project thật trong `src/client/`: mở bằng Unity 2022 LTS, có scene slice đầu tiên (Xóm Trọ Cũ + Chợ Đầu Mối), prefab, asset CC0.
2. Unity license: tài khoản Unity, license Personal/Plus/Pro hợp lệ.
3. Secret trong repo GitHub (Settings → Secrets and variables → Actions):
   - `UNITY_LICENSE` — nội dung file license (lấy bằng Unity License activation, xem docs game-ci/unity-actions)
   - `UNITY_EMAIL`, `UNITY_PASSWORD` — chỉ dùng nếu chọn activation qua tài khoản (khuyến nghị dùng `UNITY_LICENSE` thay vì mật khẩu)
4. Runner: `ubuntu-latest` của GitHub Actions (game-ci dùng Docker image Unity).

### File cần thêm vào repo (skeleton, chưa push)

`.github/workflows/build-webgl.yml` — xem mẫu dưới đây. Đây là skeleton, chưa chạy thử trên repo này vì chưa có Unity project đầy đủ.

```yaml
name: Build WebGL

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build-webgl:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          lfs: true

      - name: Cache Library
        uses: actions/cache@v4
        with:
          path: src/client/Library
          key: Library-WebGL-${{ hashFiles('src/client/Assets/**', 'src/client/Packages/**', 'src/client/ProjectSettings/**') }}
          restore-keys: |
            Library-WebGL-

      - name: Build WebGL
        uses: game-ci/unity-builder@v4
        env:
          UNITY_LICENSE: ${{ secrets.UNITY_LICENSE }}
          UNITY_EMAIL: ${{ secrets.UNITY_EMAIL }}
          UNITY_PASSWORD: ${{ secrets.UNITY_PASSWORD }}
        with:
          projectPath: src/client
          targetPlatform: WebGL
          # Unity version phải khớp ProjectVersion.txt trong src/client/ProjectSettings/
          # unityVersion: 2022.3.xf1

      - name: Upload WebGL build
        uses: actions/upload-artifact@v4
        with:
          name: pho-xo-bo-webgl
          path: build/WebGL
```

### Sau khi build xong, lấy link test ở đâu

1. Vào repo → tab Actions → run `Build WebGL` → tải artifact `pho-xo-bo-webgl`.
2. Deploy artifact đó lên host tĩnh (GitHub Pages / itch.io / Netlify) để có link public chơi được.
3. GitHub Actions không tự cho link chơi trực tiếp — phải deploy thêm 1 bước nữa.

### README test (ghi vào repo khi có Unity project)

- Cách chạy local: mở `src/client/` bằng Unity 2022 LTS → mở scene slice → Play.
- Cách test WebGL: dùng link deploy ở trên, không cần cài Unity.
- Checklist test: xem trang test hub `pho-xo-bo-link-test`.

## 3. Checklist test cho chủ (bản chơi thử web hiện tại)

- [ ] Gacha xuất thân: quay ra 1 trong 6 lá, tiền + chỉ số khởi điểm khác nhau, chỉ số ẩn "—" cho tới khi quay xong
- [ ] Chọn nghề: bán rong / shipper / nhân viên quán
- [ ] Làm ca: lương theo chỉ số chính + khung giờ đẹp +25%, Thể giảm đúng công thức
- [ ] Di chuyển khu: Xóm Trọ Cũ ↔ Chợ Đầu Mối, ảnh khu đổi đúng
- [ ] Điện thoại: 5 tab Nhà / Việc / Shop / Chat / Túi đều mở được
- [ ] Shop + Túi: mua cơm/cà phê/sách/áo mưa, vào Túi, bấm Dùng được
- [ ] Chat NPC: cô Tư, Bin, chị Lệ, anh Hải — chọn thoại, tăng độ thân + chỉ số
- [ ] Thời gian: 1 ngày = 30 phút, 3 khung Sáng / Chiều / Tối, miss không phạt
- [ ] Sự kiện ngẫu nhiên: mưa / kẹt xe / khách boa (xác suất 22%/ca) — báo lại nếu không gặp
- [ ] Kết toán cuối Ngày 3: đủ 900.000đ tiền trọ là thắng, kèm hạng xóm — báo lại nếu không hiện

## 4. Việc cần tiếp theo (không hứa ETA cho build Unity)

- Chủ tạo / xác nhận repo private đã có (đã có: https://github.com/tinnt120899/pho-xo-bo.git).
- Sửa bảng prototype 19 khu → 18 khu (1 lượt edit artifact riêng).
- Chốt trần tổng chỉ số (hiện là số ví dụ 300, PROVISIONAL) + danh sách 10 nhóm nghề MVP + 6 quyết định kiến trúc.
- Khi có Unity project đầy đủ, thêm workflow WebGL trên và chạy thử 1 lần để đo thời gian build thật rồi mới báo ETA.
