# Hướng dẫn build game phiêu lưu (Unity)

Game 3D nằm ở thư mục `unity/`. GitHub Actions (`.github/workflows/build-game.yml`) build ra file APK mỗi khi đẩy mã trong `unity/` hoặc sửa bài học. Để build được, GitHub cần giấy phép Unity miễn phí (bản Personal) của bạn. Chỉ làm một lần.

## 1. Tạo tài khoản và lấy file giấy phép

Cần một máy tính (Windows, Mac hoặc Linux).

1. Tạo tài khoản Unity miễn phí: https://id.unity.com
2. Tải và cài **Unity Hub**: https://unity.com/download
3. Mở Unity Hub, đăng nhập bằng tài khoản vừa tạo.
4. Vào **Preferences (Cài đặt) → Licenses → Add**, chọn **Get a free personal license**. Làm bước này kể cả khi đã thấy có giấy phép, để Unity tạo file giấy phép.
5. Tìm file `Unity_lic.ulf` (thư mục ẩn, nhớ bật xem tệp ẩn):
   - Windows: `C:\ProgramData\Unity\Unity_lic.ulf`
   - Mac: `/Library/Application Support/Unity/Unity_lic.ulf`
   - Linux: `~/.local/share/unity3d/Unity/Unity_lic.ulf`
6. Mở file bằng Notepad (hoặc TextEdit), chép **toàn bộ** nội dung.

Không cần cài Unity Editor, chỉ cần Unity Hub để lấy giấy phép.

## 2. Thêm vào GitHub

Vào https://github.com/tttan1305-sys/Nihongo-N4/settings/secrets/actions → **New repository secret**, tạo 3 secret:

| Tên | Giá trị |
|---|---|
| `UNITY_LICENSE` | toàn bộ nội dung file `Unity_lic.ulf` |
| `UNITY_EMAIL` | email tài khoản Unity |
| `UNITY_PASSWORD` | mật khẩu tài khoản Unity |

Các giá trị này chỉ GitHub Actions đọc được khi build, không ai xem lại được.

## 3. Build

Mục **Build game** chỉ hiện trên GitHub sau khi mã game (thư mục `unity/`) đã được đẩy lên. Từ đó, mỗi lần đẩy mã game hoặc sửa bài học, GitHub tự build, không cần bấm gì. Muốn build lại bằng tay:

1. Mở https://github.com/tttan1305-sys/Nihongo-N4/actions
2. Cột bên trái, bấm **Build game**.
3. Bên phải có dải màu xanh nhạt ghi "This workflow has a workflow_dispatch event trigger". Bấm nút **Run workflow** ở đó, giữ nhánh **main**, bấm nút xanh **Run workflow**.
4. Sau vài giây có một dòng mới với vòng tròn vàng (đang chạy). Lần đầu mất khoảng 30–60 phút vì GitHub phải tải Unity; các lần sau nhanh hơn.
5. Xong: dấu tích xanh là thành công, dấu X đỏ là lỗi (bấm vào dòng đó để xem; báo lại để sửa).

## 4. Tải game về điện thoại

1. Mở https://github.com/tttan1305-sys/Nihongo-N4/releases
2. Tìm bản tên **Game phiêu lưu, bản thử game-<số>** (số lớn nhất là mới nhất).
3. Mục **Assets**, bấm file `nihongo-phieu-luu-game-<số>.apk` để tải.
4. Mở file vừa tải trên điện thoại. Nếu máy hỏi, cho phép "Cài ứng dụng không rõ nguồn gốc" cho trình duyệt rồi bấm **Cài đặt**.
5. Game mở theo chiều ngang. Chạm và kéo nửa trái màn hình để đi, tới gần quái để vào ải.

## Cấu trúc mã

- `unity/Assets/Scripts/Game.cs`: dựng vùng Kyoto, nhân vật, cửa ải, cần điều khiển, bảng nhiệm vụ, tùy biến nhân vật.
- `Battle.cs`: màn đánh quái bằng câu hỏi.
- `LessonData.cs`: đọc file bài học `assets/lessons/<n>.json` (dùng chung với ứng dụng Flutter), chia thành ải: mỗi mẫu ngữ pháp một lính thường, từ vựng là lính tinh anh, đọc hiểu là boss.
- `Shapes.cs`, `Builders.cs`, `Characters.cs`: dựng nhà, torii, chùa tháp, nhân vật chibi, quái bằng khối đơn giản với shader hoạt hình `Resources/NihongoToon.shader`.
- `unity/Assets/Editor/BuildScript.cs`: chép bài học, tạo cảnh, build APK.
