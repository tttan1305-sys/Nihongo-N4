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

## Phần Tổng hợp N5 (bạn yêu cầu 2026-10-21)

| Nội dung | Trạng thái | Kết quả |
|---|---|---|
| Các thể: 3 nhóm động từ, ます・て・ない・từ điển・た・たら/ても, thể thông thường, bảng chia 17 động từ mẫu, luyện chia thể | ✅ 2026-10-21 | `assets/n5/forms.json` (sinh bằng `tools/gen_n5_forms.py`) |
| Ngữ pháp Minna bài 1–25: 109 mẫu câu, giải thích, ví dụ, luyện tập từng bài | ✅ 2026-10-21 | `assets/n5/grammar.json` |
| Từ vựng N5: 304 từ, 15 chủ đề, mỗi từ có câu ví dụ, luyện từ theo chủ đề | ✅ 2026-10-21 | `assets/n5/vocab.json` (sinh từ `tools/n5_vocab_data.py`) |

| Kiến thức cần nhớ N5: trợ từ, こそあど, số đếm, thời gian, chia tính từ, điểm hay nhầm (40 ý có ví dụ) | ✅ 2026-10-21 | `assets/n5/notes.json` |
| 5 đề test x 20 câu theo dạng JLPT N5, nộp bài mới hiện đáp án + giải thích từng câu, lưu điểm cao nhất | ✅ 2026-10-21 | `assets/n5/tests.json` (sinh từ `tools/n5_tests_data.py`), `screens/n5_test_screen.dart` |

Màn hình: `screens/n5_screen.dart`, mở từ thẻ "Tổng hợp N5" ở trang chủ, không khóa. Chưa đưa từ N5 vào flashcard (mã thẻ hiện theo số bài N4).

## Giao diện mới theo ảnh mẫu (bạn yêu cầu 2026-10-22)

Chờ bạn duyệt ảnh chụp, **chưa đẩy lên GitHub** (bạn dặn: thấy ổn rồi mới đẩy).

- ✅ Tông xanh, thẻ trắng bo tròn, thanh điều hướng dưới: Trang chủ / Từ vựng / Ngữ pháp / Khác
- ✅ Trang chủ: tranh núi Phú Sĩ, thẻ mục tiêu, nút Học từ vựng, ô Ngữ pháp và Luyện tập, ôn flashcard, Tổng hợp N5, lộ trình bài 26–50
- ✅ Từ vựng: tìm kiếm, lọc Tất cả / Đã học / Chưa học / Yêu thích, N4 và N5; từ bài N4 vẫn khóa đến khi qua ngữ pháp
- ✅ Học từ dạng thẻ (Tiếp theo = đánh dấu đã học), trắc nghiệm A–D có đồng hồ, chi tiết ngữ pháp (Cách dùng, Cấu trúc, Ví dụ, Lưu ý)
- ✅ Luyện tập câu (sắp xếp cụm từ), Học Kanji: 102 chữ N5 có cách nhớ, bộ, số nét, ví dụ (`tools/gen_n5_kanji.py`)
- ✅ Khác: lời chào, mục tiêu, Lộ trình học, Thống kê, Cài đặt, Góp ý
- Từ đã học và Kanji đã nhớ được đồng bộ; Yêu thích chỉ lưu trên máy
- ✅ Văn phong Tổng hợp N5 theo tài liệu bạn gửi (2026-10-22): bảng từ vựng Từ | Hán Việt | Cách đọc | Nghĩa (cột Hán Việt sinh bằng `tools/han_viet.py`), bộ thủ ghi kiểu "Miên (mái nhà)", Kanji ghi On/Kun

## Giao diện tối neon (bạn yêu cầu 2026-10-22, ảnh mẫu 8 màn hình)

Chờ bạn duyệt ảnh `docs/screenshots/giao-dien-toi-*.png`, **chưa đẩy lên GitHub**.

- ✅ Nền xanh đêm, thẻ viền neon phát sáng (`lib/theme.dart`, `AppCard`); trang chủ vẽ cảnh đêm: trăng, sao, Phú Sĩ, tháp chùa, hoa anh đào
- ✅ Thanh dưới 5 mục: Trang chủ / Từ vựng / Luyện tập / Thống kê / Khác; 3 ô Ngữ pháp, Luyện nghe, Kanji
- ✅ Học từ: nghĩa ẩn, nút tròn "Hiển thị nghĩa", "Đã nhớ" (đánh dấu đã học) / "Chưa nhớ"
- ✅ Luyện nghe mới: Nghe hiểu (câu N5 ngắn, chọn nghĩa, hiện lời) và Dictation (nghe từ, gõ kana)
- ✅ Kanji: tab Viết tay (ô tập viết) và Nhìn & Nhớ, mục Ghi nhớ, nút Xem ví dụ
- ✅ Thống kê: cấp độ/XP, từ đã học, % trả lời đúng, giờ học, chuỗi ngày, thành tích (5 ngày liên tục, hoàn thành 1 bài, nhớ 100 từ). Thống kê lưu `stats.*`, ngày học `day.*`, đều được đồng bộ

## Phân tích câu ví dụ (bạn yêu cầu 2026-10-22)

Chờ bạn duyệt ảnh `docs/screenshots/phan-tich-vi-du.png`, **chưa đẩy lên GitHub**.

- ✅ Mỗi câu ví dụ ngữ pháp có nút **Phân tích**: từng cụm (nghĩa và vai trò ngữ pháp), Cách chia (từ thể ます qua từng bước), Lưu ý
- ✅ Đủ 121 câu: 12 câu bài 26, 109 câu N5 bài 1–25. Nội dung viết ở `tools/analysis/*.txt`, gắn vào JSON bằng `python3 tools/apply_analysis.py` (tự thêm furigana, báo chữ Hán nhiều cách đọc)
- Bài N4 soạn sau: viết phân tích cho mọi câu ví dụ ngữ pháp ngay từ đầu, theo mẫu `docs/mau-phan-tich-vi-du.md`

## Giai đoạn 2: Tài khoản Gmail và giọng đọc nữ

| Bước | Nội dung | Trạng thái |
|---|---|---|
| 2.1 | 🔑 Bạn tạo dự án Firebase, gửi `google-services.json`; tôi nối đăng nhập Google | ✅ 2026-10-21 (web + Android nối Firebase, APK ký bằng khóa thật từ bản thử #9) |
| 2.2 | Đồng bộ tiến độ và flashcard lên Firestore | 👉 mã đã xong (2026-10-21), chờ bạn bật Firestore theo mục 6 của `docs/HUONG_DAN_FIREBASE.md` |
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
- **Bước tiếp theo: 2.2** mã đồng bộ đã xong (`services/sync_service.dart`, 35 test đạt); chờ bạn tạo Firestore database + dán `firestore.rules` rồi thử đăng nhập trên 2 máy. Xong thì sang 2.3. 2.1 xong: APK từ bản thử #9 ký bằng khóa thật (gỡ app cũ ký debug trước khi cài).
- Đồng bộ: tài liệu Firestore `users/<uid>` gồm `progress` (khóa `grammar.*`, `vocabDone.*`, `reading.*`) và `flashcards` (mã thẻ → trạng thái SM-2). Gộp khi đăng nhập: điểm lấy cao nhất, đã xong thì giữ, thẻ lấy bản có `reviewed` mới hơn. Sau đó mỗi thay đổi đẩy lên sau 2 giây. Xóa thẻ chưa đồng bộ (thẻ xóa có thể quay lại từ máy khác). Menu tài khoản hiện trạng thái, bấm để đồng bộ lại.
- Khóa ký APK: `/mnt/project-files/app-secrets/` (không đưa lên git), SHA-1 9C:8F:6A:48:BE:91:EE:AB:2F:66:26:B6:1A:F9:25:3C:12:D6:6F:BE. Workflow dùng secret `ANDROID_KEYSTORE_BASE64` + `ANDROID_KEYSTORE_PASSWORD`, thiếu thì ký debug. Khi chuyển từ APK ký debug sang khóa thật phải gỡ app cũ rồi cài lại.
- Đăng nhập: `services/auth_service.dart` dùng FirebaseAuth `signInWithPopup` (web); Android dùng gói google_sign_in 7 (serverClientId = OAuth client Web) rồi `signInWithCredential`, vì `signInWithProvider` qua Chrome báo "missing initial state". Bản phát hành Android tắt R8 (lỗi NoSuchMethodError của shared_preferences).
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
- Đăng store (2026-10-23, đã đẩy, APK thu-21): icon mới (あ + N4 + hoa anh đào, sinh bằng `tools/make_icons.py`), trang `web/privacy.html`, versionCode = số lần chạy GitHub Actions, ảnh và icon store trong `docs/store/`, hướng dẫn ở `docs/HUONG_DAN_DANG_STORE.md`. Samsung Galaxy Store không nhận cá nhân (cần D-U-N-S), nên chọn Huawei AppGallery, Uptodown, APKPure. Tên và mô tả trên store không ghi "Minna no Nihongo".
- Cỡ chữ bài học (2026-10-23, APK thu-21): `widgets/content_scale.dart`. Thân các màn học (ngữ pháp, từ vựng, Kanji, flashcard, quiz, nghe, nói, viết, Tổng hợp N5) bọc `ContentScale`; chữ thường phóng theo Cài đặt (Nhỏ 1×/Vừa 1.5×/Lớn 2×, mặc định Lớn, khóa `settings.textScale`) nhưng tối đa 36, chữ vốn to giữ nguyên. Nút giữ cỡ thường qua `foregroundBuilder` trong theme; nút tự vẽ bọc `NormalTextScale`. RubyText tự tính cỡ furigana. Test đặt `settings.textScale` = 1.0.
- Ô viết Kanji dùng `_InkPanRecognizer` (nhận cử chỉ ngay khi chạm) để nét dọc không bị trang cuộn giành.
