import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';

/// Tiến độ học lưu trên máy. Giai đoạn 2 sẽ đồng bộ thêm lên Firestore.
class ProgressStore extends ChangeNotifier {
  /// Điểm tối thiểu để qua một mẫu ngữ pháp.
  static const passMark = 0.8;

  final SharedPreferences _prefs;

  ProgressStore(this._prefs);

  static String _grammarKey(int lesson, String grammarId) =>
      'grammar.$lesson.$grammarId';

  /// Điểm cao nhất (0..1) của bài kiểm tra ngữ pháp, null nếu chưa làm.
  double? grammarScore(int lesson, String grammarId) =>
      _prefs.getDouble(_grammarKey(lesson, grammarId));

  bool isGrammarPassed(int lesson, String grammarId) =>
      (grammarScore(lesson, grammarId) ?? 0) >= passMark;

  /// Lưu điểm, chỉ giữ lại điểm cao nhất.
  Future<void> saveGrammarScore(
    int lesson,
    String grammarId,
    double score,
  ) async {
    final best = grammarScore(lesson, grammarId);
    if (best != null && best >= score) return;
    await _prefs.setDouble(_grammarKey(lesson, grammarId), score);
    notifyListeners();
  }

  static String _vocabDoneKey(int lesson) => 'vocabDone.$lesson';

  bool isVocabDone(int lesson) =>
      _prefs.getBool(_vocabDoneKey(lesson)) ?? false;

  Future<void> markVocabDone(int lesson) async {
    await _prefs.setBool(_vocabDoneKey(lesson), true);
    notifyListeners();
  }

  /// Người dùng chọn "Học không cần đăng nhập".
  bool get isGuest => _prefs.getBool('settings.guest') ?? false;

  Future<void> setGuest(bool value) async {
    await _prefs.setBool('settings.guest', value);
    notifyListeners();
  }

  /// Cài đặt chung: hiện furigana. Tắt đi để tự kiểm tra cách đọc chữ Hán.
  bool get showFurigana => _prefs.getBool('settings.showFurigana') ?? true;

  Future<void> setShowFurigana(bool value) async {
    await _prefs.setBool('settings.showFurigana', value);
    notifyListeners();
  }

  static String _readingKey(int lesson) => 'reading.$lesson';

  /// Điểm cao nhất của câu hỏi đọc hiểu cuối bài.
  double? readingScore(int lesson) => _prefs.getDouble(_readingKey(lesson));

  Future<void> saveReadingScore(int lesson, double score) async {
    final best = readingScore(lesson);
    if (best != null && best >= score) return;
    await _prefs.setDouble(_readingKey(lesson), score);
    notifyListeners();
  }

  /// Bài hoàn thành khi đã qua bài đọc hiểu cuối bài.
  bool isLessonCompleted(int lesson) => (readingScore(lesson) ?? 0) >= passMark;

  /// Bài đầu luôn mở; các bài sau mở khi bài trước đã hoàn thành.
  bool isLessonUnlocked(int lesson, {required int first}) =>
      lesson <= first || isLessonCompleted(lesson - 1);

  int passedGrammarCount(Lesson lesson) =>
      lesson.grammar.where((g) => isGrammarPassed(lesson.number, g.id)).length;

  /// Từ vựng chỉ mở khi mọi mẫu ngữ pháp của bài đều đạt từ [passMark].
  bool isVocabUnlocked(Lesson lesson) =>
      passedGrammarCount(lesson) == lesson.grammar.length;
}
