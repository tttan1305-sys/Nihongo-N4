# Hướng dẫn đăng Nihongo N4 lên các store miễn phí

Cập nhật 23/10/2026. Ảnh và icon cho trang store nằm trong `docs/store/`.

## 1. Chọn store nào

| Store | Cá nhân đăng được? | Phí | Ghi chú |
|---|---|---|---|
| Huawei AppGallery | Có, xác minh bằng CCCD/hộ chiếu | Miễn phí | Duyệt vài giờ đến vài ngày |
| Uptodown | Có, chỉ cần tài khoản | Miễn phí | Tải APK lên, đội ngũ Uptodown duyệt |
| APKPure | Có, chỉ cần tài khoản | Miễn phí | Tải APK lên qua trang nhà phát triển |
| Samsung Galaxy Store | **Không** | Miễn phí | Từ 2023 Samsung chỉ nhận người bán là doanh nghiệp có số D-U-N-S. Tài khoản cá nhân không đăng được ứng dụng Android |

Lưu ý: điện thoại Huawei đời mới không có dịch vụ Google, nên nút **Đăng nhập bằng Google** không chạy trên máy Huawei. Người dùng vẫn học được bình thường ở chế độ **Dùng không cần đăng nhập** (tiến độ lưu trên máy).

## 2. Chuẩn bị chung (đã có sẵn)

- **File APK**: lấy bản mới nhất ở trang Releases: https://github.com/tttan1305-sys/Nihongo-N4/releases. Mỗi lần build, số phiên bản (versionCode) tự tăng, nên store sẽ nhận bản cập nhật.
- **Icon**: `docs/store/icon-512.png` (512×512), `docs/store/icon-216.png` (216×216, Huawei).
- **Ảnh chụp màn hình** (1080×1920, dọc): `docs/store/screenshots/01-home.png` đến `08-practice.png`.
- **Chính sách quyền riêng tư**: https://tttan1305-sys.github.io/Nihongo-N4/privacy.html (có sau khi đẩy code lên GitHub).
- **Danh mục**: Giáo dục (Education). **Độ tuổi**: mọi lứa tuổi (3+). **Giá**: miễn phí, không quảng cáo, không mua trong ứng dụng.

### Tên và mô tả

**Tên**: Nihongo N4 – Học tiếng Nhật

**Mô tả ngắn (tiếng Việt, dưới 80 ký tự)**:
Học tiếng Nhật N5, N4: ngữ pháp có phân tích, furigana, flashcard, luyện nghe.

**Mô tả đầy đủ (tiếng Việt)**:

> Nihongo N4 giúp bạn học tiếng Nhật sơ cấp từ N5 lên N4, miễn phí và không quảng cáo.
>
> • Ngữ pháp trước, từ vựng sau: mỗi bài học mẫu câu trước rồi mới học từ mới.
> • Mỗi câu ví dụ đều được phân tích: tách từng cụm, giải thích trợ từ và các bước chia thể từ thể ます.
> • Furigana trên mọi chữ Hán, kèm âm Hán Việt.
> • Giọng đọc nữ người Nhật cho từ vựng, câu ví dụ và bài đọc.
> • Flashcard, luyện nghe, chép chính tả, luyện nói và luyện viết Kanji bằng tay.
> • Phần Tổng hợp N5: ngữ pháp, các thể, 300+ từ vựng và đề thi thử kiểu JLPT có giải thích.
> • Thống kê tiến độ, chuỗi ngày học, huy hiệu.
> • Đăng nhập Google để đồng bộ tiến độ giữa các máy (không bắt buộc).

**Short description (English)**:
Learn Japanese N5–N4: analysed grammar, furigana, flashcards, listening.

**Full description (English)**:

> Nihongo N4 helps Vietnamese speakers learn beginner Japanese from N5 to N4. Free, no ads.
>
> • Grammar first, then vocabulary in every lesson.
> • Every example sentence is broken down: chunks, particles and step-by-step conjugation from the ます form.
> • Furigana on every kanji, with Sino-Vietnamese readings.
> • Native female Japanese voice for words, examples and readings.
> • Flashcards, listening, dictation, speaking practice and handwritten kanji practice.
> • N5 review: grammar, verb forms, 300+ words and JLPT-style mock tests with explanations.
> • Progress stats, study streaks and badges.
> • Optional Google sign-in to sync progress across devices.

Không ghi tên giáo trình "Minna no Nihongo" trong tên hay mô tả, vì đó là nhãn hiệu của nhà xuất bản, store có thể từ chối.

## 3. Huawei AppGallery

1. Vào https://developer.huawei.com/consumer/en/ → **Register**, tạo HUAWEI ID bằng email.
2. Đăng nhập → **Identity verification** → chọn **Individual developer**, chụp CCCD hoặc hộ chiếu theo hướng dẫn. Chờ duyệt (thường 1–2 ngày làm việc).
3. Vào **AppGallery Connect** (https://developer.huawei.com/consumer/en/service/josp/agc/index.html) → **My apps** → **New app**.
   - Platform: Android. Device: Mobile phone. App name: Nihongo N4. Default language: Tiếng Việt. Category: Education.
4. Mục **App information**: dán mô tả ngắn và đầy đủ ở trên, tải icon 216×216 và 3–8 ảnh chụp màn hình. Thêm ngôn ngữ English nếu muốn, dán bản tiếng Anh.
5. Mục **Version information** → **Software version** → tải file APK.
6. Mục **Country/Region**: chọn các nước muốn phát hành (ví dụ Việt Nam và các nước khác), **bỏ chọn Trung Quốc đại lục** (phát hành ở đó cần giấy phép bản quyền phần mềm riêng).
7. **Payment type**: Free. **Content rating**: trả lời bảng câu hỏi (không bạo lực, không quảng cáo, không mua hàng) → ra mức 3+.
8. **Privacy policy URL**: https://tttan1305-sys.github.io/Nihongo-N4/privacy.html
9. **Test account**: không cần, ghi chú cho người duyệt: "Login is optional. Tap 'Dùng không cần đăng nhập' (use without signing in) to use all features."
10. Bấm **Submit**. Kết quả duyệt gửi về email.

## 4. Uptodown

1. Vào https://www.uptodown.com → cuối trang chọn mục dành cho nhà phát triển (Developers) → đăng ký tài khoản (email hoặc Google). Đường dẫn chính xác của trang nhà phát triển có thể thay đổi, nên đi từ trang chủ.
2. **Add new app** → tải file APK. Uptodown tự đọc tên gói và phiên bản.
3. Điền mô tả (có thể dùng bản tiếng Anh, Uptodown sẽ dịch thêm), chọn danh mục Education, tải icon 512 và ảnh chụp.
4. Gửi duyệt. Khi có bản mới, vào app đã đăng → tải APK mới lên.

## 5. APKPure

1. Vào https://apkpure.com → cuối trang chọn mục dành cho nhà phát triển (Developer / Submit App) → đăng ký tài khoản. Đường dẫn chính xác có thể thay đổi, nên đi từ trang chủ.
2. **Submit App** → tải APK, điền tên, mô tả, danh mục Education, icon 512, ảnh chụp, link quyền riêng tư.
3. Gửi duyệt. Bản cập nhật cũng tải lên ở trang quản lý app.

## 6. Khi phát hành bản mới

1. Đẩy code lên GitHub → GitHub Actions build APK mới (versionCode tăng tự động).
2. Tải APK ở trang Releases.
3. Vào từng store → app → tải bản mới lên → gửi duyệt.

Luôn dùng APK ký bằng cùng một khóa (khóa nằm trong secrets của GitHub, bản sao ở `app-secrets`). Đổi khóa thì store sẽ từ chối bản cập nhật.
