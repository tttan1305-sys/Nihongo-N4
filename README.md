# Nihongo N4

Ứng dụng Android học tiếng Nhật N4 theo lộ trình Minna no Nihongo (bài 26 → 50), viết bằng Flutter.

- Tiến độ và bước tiếp theo: [ROADMAP.md](ROADMAP.md)
- Kế hoạch chi tiết: [docs/KE_HOACH.md](docs/KE_HOACH.md)

## Cấu trúc

| Thư mục | Nội dung |
|---|---|
| `assets/lessons/` | Nội dung từng bài (`26.json`…), furigana viết `{漢字|かんじ}` |
| `lib/models/` | Mô hình dữ liệu bài học |
| `lib/data/` | Đọc bài học từ assets |
| `lib/widgets/ruby_text.dart` | Hiển thị furigana phía trên chữ Hán |
| `lib/screens/` | Trang chủ, màn hình bài học |
| `tools/check_lessons.py` | Kiểm tra mọi chữ Hán đều có furigana |

## Lệnh thường dùng

```
flutter pub get
flutter analyze
flutter test
python3 tools/check_lessons.py assets/lessons/*.json
flutter build apk --release
```
