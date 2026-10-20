# Hướng dẫn tạo Firebase cho đăng nhập Gmail (bước 2.1)

Mất khoảng 10 phút, làm trên máy tính sẽ dễ hơn. Firebase gói Spark miễn phí, không cần thẻ.

## 1. Tạo dự án

1. Mở https://console.firebase.google.com và đăng nhập Gmail của bạn.
2. Bấm **Create a project** (Tạo dự án), đặt tên `nihongo-n4`.
3. Tắt Google Analytics (không cần), bấm **Create project**.

## 2. Bật đăng nhập Google

1. Menu trái: **Build → Authentication → Get started**.
2. Tab **Sign-in method** → chọn **Google** → bật **Enable** → chọn email hỗ trợ → **Save**.
3. Tab **Settings → Authorized domains** → **Add domain** → nhập `tttan1305-sys.github.io` → **Add**.

## 3. Thêm ứng dụng web

1. Bấm bánh răng ⚙️ cạnh "Project Overview" → **Project settings**.
2. Mục **Your apps** → bấm biểu tượng web `</>`.
3. Đặt tên `Nihongo web`, không tick Firebase Hosting, bấm **Register app**.
4. Firebase hiện một đoạn mã có `const firebaseConfig = { apiKey: ..., authDomain: ..., projectId: ..., ... }`.
   **Sao chép cả đoạn `firebaseConfig` đó và gửi cho Claude trong luồng chat.** (Các giá trị này không phải bí mật.)

## 4. Thêm ứng dụng Android

1. Vẫn ở **Project settings → Your apps** → **Add app** → biểu tượng Android.
2. **Android package name**: `com.tttan.nihongo.nihongo_n4`
3. **App nickname**: `Nihongo Android`
4. **Debug signing certificate SHA-1**:
   `9C:8F:6A:48:BE:91:EE:AB:2F:66:26:B6:1A:F9:25:3C:12:D6:6F:BE`
5. Bấm **Register app** → **Download google-services.json** → **gửi file đó cho Claude** trong luồng chat.
   Các bước còn lại (thêm SDK) bỏ qua, Claude sẽ làm.
6. Trở lại **Project settings → Your apps → Nihongo Android → Add fingerprint**, thêm cả SHA-256:
   `2D:C0:70:34:E5:E4:B8:C5:B6:DA:B6:55:8D:2B:70:C9:A0:21:A1:14:B1:B3:3D:45:C7:A7:C1:53:A1:17:54:03`

## 5. Thêm khóa ký APK vào GitHub (để đăng nhập trên Android chạy được)

Claude đã tạo khóa ký app, nằm trong thư mục `app-secrets` của dự án (không đưa lên GitHub).

1. Mở https://github.com/tttan1305-sys/Nihongo-N4/settings/secrets/actions
2. Bấm **New repository secret**:
   - Name: `ANDROID_KEYSTORE_BASE64`
   - Secret: toàn bộ nội dung file `app-secrets/ANDROID_KEYSTORE_BASE64.txt`
3. Bấm **New repository secret** lần nữa:
   - Name: `ANDROID_KEYSTORE_PASSWORD`
   - Secret: nội dung file `app-secrets/keystore-password.txt`

Hãy tải thư mục `app-secrets` về và cất ở nơi an toàn. Mất khóa này thì không cập nhật được app cho người đã cài.
