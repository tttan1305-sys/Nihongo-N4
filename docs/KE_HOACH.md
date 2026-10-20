# Kế hoạch: Ứng dụng học tiếng Nhật N4 (Android, phát hành miễn phí)

Tài liệu này mô tả cách ứng dụng được xây dựng, dựa trên 9 yêu cầu của bạn. Những chỗ ghi **(mặc định)** là lựa chọn tôi tự chọn, bạn có thể đổi.

## 1. Công nghệ

| Phần | Lựa chọn | Lý do |
|---|---|---|
| Ứng dụng | **Flutter** (Dart), xuất bản Android trước **(mặc định)** | Một mã nguồn, sau này ra iOS dễ dàng |
| Đăng nhập Gmail | **Firebase Auth + Google Sign-In** | Miễn phí, phổ biến trên Android |
| Lưu tiến độ, flashcard | **Cloud Firestore**, có bộ nhớ trên máy để học offline | Đổi máy vẫn giữ tiến độ |
| Giọng đọc nữ Nhật | **Google Cloud Text-to-Speech, giọng `ja-JP-Neural2-B` (nữ)**, tạo sẵn file mp3 rồi đóng gói vào app **(mặc định)** | Giọng tự nhiên, không cần mạng khi học, chi phí tạo 1 lần |
| Luyện nói | Nhận dạng giọng nói tiếng Nhật trên máy (`speech_to_text`, locale `ja-JP`) | Chấm phát âm bằng cách so câu nói với câu mẫu |
| Luyện viết | Bảng viết tay có chữ Hán mờ bên dưới + gõ hiragana | Đơn giản cho MVP, sau thêm chấm thứ tự nét |

## 2. Bản quyền nội dung (quan trọng)

Sách Minna no Nihongo có bản quyền (3A Corporation). Ứng dụng **đi theo đúng thứ tự bài và thứ tự ngữ pháp** của Minna no Nihongo bản mới (Sơ cấp II, bắt đầu từ bài 26 = đầu N4), nhưng **toàn bộ câu ví dụ, hội thoại, bài đọc đều do mình tự viết**. Không sao chép văn bản, hình ảnh hay file nghe của sách. Tên sách chỉ được nhắc như "theo lộ trình Minna no Nihongo", không dùng logo. Điều này giúp app tránh rắc rối về bản quyền khi phát hành.

## 3. Lộ trình

- Bài 26 → 50 (Minna Sơ cấp II), tương ứng N4. Mỗi bài là một "Bài học".
- Bài sau chỉ mở khi bài trước hoàn thành (đã qua bài đọc hiểu cuối bài).
- Có thể mở rộng sang N3 sau (giáo trình riêng, cùng cấu trúc dữ liệu).

## 4. Cấu trúc một bài học (theo yêu cầu 2 → 5, 8, 9)

Thứ tự bắt buộc trong mỗi bài:

1. **Ngữ pháp** (học trước). Mỗi mẫu câu gồm: cấu trúc, giải thích tiếng Việt, 2–3 câu ví dụ có furigana và giọng đọc, ghi chú "Người Nhật dùng thế nào ngoài đời / ở công ty", và 1 bài kiểm tra nhỏ.
2. **Từ vựng** (khóa cho đến khi xong mọi mẫu ngữ pháp, mỗi bài kiểm tra ngữ pháp đạt từ 80%). Mỗi từ gồm: chữ Hán có furigana, nghĩa, nút nghe giọng nữ, **câu áp dụng thực tế** (một tình huống đời sống hoặc công việc), và nút "Thêm vào flashcard".
3. **Luyện 4 kỹ năng**:
   - Nghe: nghe câu, chọn nghĩa đúng.
   - Nói: nghe câu mẫu, đọc theo (shadowing), máy nhận dạng và chấm.
   - Đọc: bài đọc hiểu cuối bài.
   - Viết: tập viết chữ Hán của bài, gõ lại câu bằng hiragana.
4. **Bài đọc hiểu cuối bài**: 100% tiếng Nhật, furigana trên mọi chữ Hán, dùng hết các mẫu ngữ pháp và phần lớn từ mới trong bài, kèm câu hỏi hiểu bài bằng tiếng Nhật. Có thể bấm nghe cả bài.

Tình huống ví dụ ưu tiên chủ đề người Việt hay gặp ở Nhật: đi làm, nhà trọ, đổ rác, bệnh viện, siêu thị, giao tiếp với cấp trên, đồng nghiệp.

## 5. Mô hình dữ liệu

### 5.1 Nội dung bài học (file JSON đóng gói trong app: `assets/lessons/<số bài>.json`)

Furigana được viết theo cú pháp `{漢字|かんじ}`. Ứng dụng tự hiển thị chữ hiragana nhỏ phía trên chữ Hán. Công cụ kiểm tra (`tools/check_lessons.py`) báo lỗi nếu còn chữ Hán nào không có furigana.

```
Lesson
  id, number, titleJa, titleVi
  grammar: [GrammarPoint]
     id, pattern, meaningVi, explanationVi, usageNoteVi
     examples: [Sentence]          // ja (có furigana), vi, audio
     quiz: [Question]
  vocab: [Vocab]
     id, word (có furigana), kana, meaningVi, partOfSpeech
     audio
     practical: Sentence + situationVi   // cách dùng thực tế
  reading: { title, paragraphs[], audio, questions: [Question] }
  listening: [Question]   speaking: [Sentence]   writing: { kanji[], sentences[] }

Question: { promptJa?, promptVi?, audio?, options[], answer(index), explanationVi }
```

### 5.2 Dữ liệu người dùng (Firestore)

```
users/{uid}
  displayName, email, createdAt, dailyGoal
  progress/{lessonId}
     grammarDone: {grammarId: bestScore}
     vocabDone: bool, readingScore, skills: {listening, speaking, writing}
     completedAt
  cards/{vocabId}
     ease, intervalDays, repetitions, dueAt, lapses
```

## 6. Flashcard và lặp lại ngắt quãng (yêu cầu 6)

- Thuật toán **SM-2** (giống Anki): mỗi lần ôn, người học chọn *Quên / Khó / Được / Dễ*, app tính ngày ôn tiếp theo.
- Từ mới tự vào bộ flashcard khi học xong phần từ vựng.
- Mặt trước: chữ Hán có furigana (có thể ẩn furigana để tự kiểm tra) + nút nghe. Mặt sau: nghĩa + câu thực tế.
- Trang chủ hiện số thẻ cần ôn hôm nay.

## 7. Các màn hình

1. **Đăng nhập**: nút "Đăng nhập bằng Google".
2. **Trang chủ**: lộ trình bài 26 → 50 (khóa/mở), số thẻ cần ôn, nút "Ôn flashcard".
3. **Bài học**: 4 tab theo thứ tự Ngữ pháp → Từ vựng (khóa) → Luyện kỹ năng → Đọc hiểu.
4. **Chi tiết mẫu ngữ pháp** + bài kiểm tra.
5. **Ôn flashcard**.
6. **Hồ sơ**: tiến độ, cài đặt (bật/tắt furigana, tốc độ đọc), đăng xuất.

## 8. Phạm vi bản đầu tiên (MVP)

Có trong MVP:
- Đăng nhập Google, lưu tiến độ trên máy và đồng bộ Firestore.
- Đủ khung bài học và **bài 26 đầy đủ nội dung** làm mẫu.
- Khóa từ vựng cho đến khi xong ngữ pháp.
- Furigana trên mọi chữ Hán, giọng đọc nữ (file tạo sẵn; khi chưa có file thì dùng giọng tiếng Nhật của máy).
- Flashcard SM-2, nghe/nói/đọc/viết ở mức cơ bản.

Để sau MVP:
- Soạn bài 27 → 50 (cùng định dạng JSON, mỗi bài tôi soạn rồi bạn duyệt).
- Chấm thứ tự nét chữ Hán, thống kê học tập, nhắc học hằng ngày, thi thử N4.
- Gói trả phí / quảng cáo nếu bạn muốn kiếm tiền.

## 9. Việc bạn cần làm (cần tài khoản của bạn)

1. Tạo **dự án Firebase**, bật Google Sign-In, tải `google-services.json` vào `android/app/`.
2. Tạo **khóa Google Cloud Text-to-Speech** để tạo file giọng đọc (`tools/gen_audio.py`). Chi phí rất thấp, gói miễn phí hằng tháng đủ cho cả giáo trình.
3. Không dùng Google Play (để không mất phí 25 USD): phát hành file APK tải trực tiếp, có thể đăng thêm lên kho miễn phí Samsung/Huawei.
4. (Nên có) Một repository GitHub để lưu mã nguồn.

## 10. Các bước tiếp theo

1. Bạn duyệt kế hoạch này và bài 26 mẫu.
2. Bạn làm các bước ở mục 9; tôi nối Firebase và tạo file giọng đọc.
3. Tôi soạn tiếp bài 27 → 50 theo từng đợt.
4. Phát hành bản thử APK cho vài người, sửa lỗi, rồi phát hành chính thức.
