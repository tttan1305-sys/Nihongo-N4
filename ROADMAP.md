# Lộ trình xây dựng theo giai đoạn

Mỗi lần làm việc hoàn thành **một bước**, lưu kết quả vào thư mục `app/`, rồi đánh dấu ở đây. Lần sau chỉ cần nói "làm bước tiếp theo" là tiếp tục từ bước có dấu 👉.

Ký hiệu: ✅ xong · 👉 bước tiếp theo · ⬜ chưa làm · 🔑 cần tài khoản của bạn

Kế hoạch chi tiết: [docs/KE_HOACH.md](docs/KE_HOACH.md)

## Giai đoạn 1: Nền tảng, chạy được không cần mạng

| Bước | Nội dung | Trạng thái | Kết quả |
|---|---|---|---|
| 1.1 | Kế hoạch: công nghệ, mô hình dữ liệu, màn hình, MVP | ✅ 2026-10-19 | `docs/KE_HOACH.md` |
| 1.2 | Nội dung bài 26 mẫu (4 ngữ pháp, 24 từ, bài đọc) + công cụ kiểm tra furigana | ✅ 2026-10-19 | `assets/lessons/26.json`, `tools/check_lessons.py` |
| 1.3 | Dựng khung Flutter Android: pubspec, model đọc JSON, widget hiển thị furigana, trang chủ danh sách bài | ✅ 2026-10-19 | `lib/`, `test/` (analyze sạch, 5 test đạt) |
| 1.4 | Phần ngữ pháp + bài kiểm tra, khóa từ vựng đến khi xong ngữ pháp (≥ 80%) | ✅ 2026-10-19 | `grammar_screen.dart`, `quiz_screen.dart`, `progress_store.dart` (8 test đạt) |
| 1.5 | Phần từ vựng: furigana, nghĩa, câu thực tế, nút nghe (giọng tiếng Nhật của máy tạm thời) | ✅ 2026-10-20 | `vocab_tab.dart`, `services/speaker.dart` (10 test đạt) |
| 1.6 | Flashcard ôn tập SM-2, lưu trên máy | ✅ 2026-10-20 | `srs/sm2.dart`, `flashcard_store.dart`, `flashcard_screen.dart` (18 test đạt) |
| 1.7 | Luyện nghe, nói (nhận dạng giọng), viết, và bài đọc hiểu cuối bài | ✅ 2026-10-20 | `skills_tab.dart`, `speaking_screen.dart`, `writing_screen.dart`, `reading_tab.dart` (25 test đạt) |
| 1.8 | Build file APK để bạn cài thử trên điện thoại | ✅ 2026-10-20 | GitHub Actions build mỗi lần đẩy lên main, APK ở [Releases](https://github.com/tttan1305-sys/Nihongo-N4/releases) |

## Giai đoạn 2: Tài khoản Gmail và giọng đọc nữ

| Bước | Nội dung | Trạng thái |
|---|---|---|
| 2.1 | 🔑 Bạn tạo dự án Firebase, gửi `google-services.json`; tôi nối đăng nhập Google | 👉 mã đã xong, chờ bạn làm theo `docs/HUONG_DAN_FIREBASE.md` |
| 2.2 | Đồng bộ tiến độ và flashcard lên Firestore | ⬜ |
| 2.3 | 🔑 Bạn tạo khóa Google Cloud TTS; tôi tạo file giọng nữ `ja-JP-Neural2-B` cho bài đã soạn | ⬜ |

## Giai đoạn 3: Nội dung N4 (bài 27 → 50)

Mỗi bước soạn 2 bài theo đúng định dạng bài 26, chạy `tools/check_lessons.py` phải 0 lỗi, bạn duyệt rồi tạo giọng đọc.

| Bước | Bài | Trạng thái |
|---|---|---|
| 3.1 | 27, 28 | ⬜ |
| 3.2 | 29, 30 | ⬜ |
| 3.3 | 31, 32 | ⬜ |
| 3.4 | 33, 34 | ⬜ |
| 3.5 | 35, 36 | ⬜ |
| 3.6 | 37, 38 | ⬜ |
| 3.7 | 39, 40 | ⬜ |
| 3.8 | 41, 42 | ⬜ |
| 3.9 | 43, 44 | ⬜ |
| 3.10 | 45, 46 | ⬜ |
| 3.11 | 47, 48 | ⬜ |
| 3.12 | 49, 50 | ⬜ |

## Giai đoạn 4: Phát hành miễn phí (không dùng CH Play)

Đã chọn (2026-10-19): phát hành APK tải trực tiếp trước, sau đó đăng thêm lên kho miễn phí Samsung Galaxy Store và Huawei AppGallery.

| Bước | Nội dung | Trạng thái |
|---|---|---|
| 4.1 | Biểu tượng, tên app, chính sách quyền riêng tư, khóa ký APK | ⬜ |
| 4.2 | Thông báo "có bản mới" trong app, trang tải APK (GitHub Releases hoặc Google Drive) | ⬜ |
| 4.3 | Phát hành bản thử cho vài người, sửa lỗi, phát hành chính thức | ⬜ |
| 4.4 | Đăng thêm lên kho miễn phí Samsung Galaxy Store / Huawei AppGallery | ⬜ |

## Ghi chú cho lần làm tiếp theo

- Mã nguồn chính: https://github.com/tttan1305-sys/Nihongo-N4 (nhánh main). `/mnt/project-files/app` là bản sao, cập nhật cùng lúc.
- **Bước tiếp theo: 2.1** chờ bạn: tạo Firebase, gửi `firebaseConfig` web + `google-services.json`, thêm 2 GitHub Secret khóa ký. Sau đó điền `lib/firebase_options.dart` (đang để null = chạy không đăng nhập).
- Khóa ký APK: `/mnt/project-files/app-secrets/` (không đưa lên git), SHA-1 9C:8F:6A:48:BE:91:EE:AB:2F:66:26:B6:1A:F9:25:3C:12:D6:6F:BE. Workflow dùng secret `ANDROID_KEYSTORE_BASE64` + `ANDROID_KEYSTORE_PASSWORD`, thiếu thì ký debug. Khi chuyển từ APK ký debug sang khóa thật phải gỡ app cũ rồi cài lại.
- Đăng nhập: `services/auth_service.dart` dùng FirebaseAuth `signInWithPopup` (web) / `signInWithProvider` (Android), không dùng gói google_sign_in.
- Máy làm việc không tải được Android SDK (`dl.google.com` bị chặn; maven.google.com và services.gradle.org thì được). Cách build APK: GitHub Actions (`.github/workflows/build-apk.yml`) khi có repository, hoặc thêm `dl.google.com` vào Allowed domains của cloud environment.
- Flutter SDK không có sẵn trong máy làm việc: tải bản stable `flutter_linux_3.47.7` về thư mục tạm (chạy `git config --global --add safe.directory '*'` trước) để chạy `flutter analyze` và `flutter test`. Android SDK chưa có nên chưa build APK được (để bước 1.8).
- Tiến độ lưu trên máy bằng `shared_preferences` (`lib/data/progress_store.dart`); giai đoạn 2 đồng bộ lên Firestore. Tab Luyện kỹ năng còn trống (bước 1.7).
- Giọng đọc: `DeviceSpeaker` phát file `assets/audio/<bài>_<id>.mp3` nếu có, chưa có thì dùng giọng nữ tiếng Nhật của máy (flutter_tts). Từ vựng đọc theo kana, câu đọc theo chữ Hán. Nút "Đã học xong từ vựng" lưu `vocabDone`, bước 1.6 dùng để đưa từ vào flashcard.
- Flashcard: `FlashcardStore` lưu JSON trong `shared_preferences` (khóa `flashcards`, mã thẻ `26:v01`). Thẻ vào bộ khi bấm "Đã học xong, đưa vào flashcard" hoặc nút đánh dấu từng từ. SM-2 4 mức: Quên (10 phút), Khó, Được, Dễ.
- Thứ tự mở khóa trong bài: Ngữ pháp (≥ 80% mỗi mẫu) → Từ vựng → (bấm học xong) Luyện kỹ năng + Đọc hiểu. Bài hoàn thành khi đọc hiểu ≥ 80%; bài sau mở khi bài trước hoàn thành.
- Luyện nói dùng `speech_to_text` (locale ja-JP, cần quyền micro, đã khai báo trong AndroidManifest); chấm bằng độ giống Levenshtein với câu gốc hoặc cách đọc kana (`services/japanese_text.dart`), đạt từ 80%. Tập viết chữ Hán hiện chỉ vẽ trên chữ mờ, chưa chấm nét.
- Mã đã chạy `dart format` (dòng 80 ký tự) và `dart fix --apply` (CI chạy `flutter analyze`, lỗi cả với mức info).
- Bản web: `.github/workflows/deploy-web.yml` đăng lên https://tttan1305-sys.github.io/Nihongo-N4/ (đã bật Pages 2026-10-20, tự đăng lại mỗi lần đẩy lên main).
- `QuizScreen` dùng lại được cho bài đọc hiểu và luyện nghe. Trong widget test, phải nạp trước bài học bằng `tester.runAsync(() => repository.load(26))`.
- Furigana viết theo cú pháp `{漢字|かんじ}`; mọi chuỗi trong file bài học (trừ trường `char`) phải qua `tools/check_lessons.py` với 0 lỗi.
- Nội dung tự viết, chỉ theo thứ tự bài và ngữ pháp của Minna no Nihongo (sách có bản quyền).
