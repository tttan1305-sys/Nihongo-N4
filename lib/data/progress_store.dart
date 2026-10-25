import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../skins.dart';

/// Tiến độ học lưu trên máy, đồng bộ lên Firestore qua [SyncService] khi đăng nhập.
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

  /// Cỡ chữ nội dung bài học, nhân với cỡ chữ của máy. Mặc định 2 lần.
  double get textScale => _prefs.getDouble('settings.textScale') ?? 2.0;

  Future<void> setTextScale(double value) async {
    await _prefs.setDouble('settings.textScale', value);
    notifyListeners();
  }

  /// Phong cách giao diện: neon (mặc định), mechanical hoặc anime.
  AppSkin get skin => AppSkin.values.firstWhere(
    (s) => s.name == _prefs.getString('settings.skin'),
    orElse: () => AppSkin.neon,
  );

  Future<void> setSkin(AppSkin value) async {
    await _prefs.setString('settings.skin', value.name);
    notifyListeners();
  }

  /// Chế độ sáng/tối: 'system' (theo máy), 'light' hoặc 'dark'.
  String get brightness => _prefs.getString('settings.brightness') ?? 'system';

  Future<void> setBrightness(String value) async {
    await _prefs.setString('settings.brightness', value);
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

  static String _n5TestKey(String testId) => 'n5test.$testId';

  /// Điểm cao nhất (0..1) của một đề test N5, null nếu chưa làm.
  double? n5TestScore(String testId) => _prefs.getDouble(_n5TestKey(testId));

  Future<void> saveN5TestScore(String testId, double score) async {
    final best = n5TestScore(testId);
    if (best != null && best >= score) return;
    await _prefs.setDouble(_n5TestKey(testId), score);
    notifyListeners();
  }

  static String _wordKey(String key) => 'word.$key';

  /// Từ đã học trong danh sách từ vựng chung ([key] như `26:v01`, `n5:n5v001`).
  bool isWordLearned(String key) => _prefs.getBool(_wordKey(key)) ?? false;

  Future<void> markWordLearned(String key) async {
    if (isWordLearned(key)) return;
    await _prefs.setBool(_wordKey(key), true);
    await markStudyDay(notify: false);
    notifyListeners();
  }

  int learnedCount(Iterable<String> keys) => keys.where(isWordLearned).length;

  // Từ yêu thích chỉ lưu trên máy: bỏ thích phải giữ được, mà phép gộp khi
  // đồng bộ luôn giữ giá trị true.
  static String _favoriteKey(String key) => 'favorite.$key';

  bool isFavorite(String key) => _prefs.getBool(_favoriteKey(key)) ?? false;

  Future<void> toggleFavorite(String key) async {
    await _prefs.setBool(_favoriteKey(key), !isFavorite(key));
    notifyListeners();
  }

  static String _kanjiKey(String char) => 'kanji.$char';

  /// Chữ Hán đã đánh dấu "đã nhớ".
  bool isKanjiLearned(String char) => _prefs.getBool(_kanjiKey(char)) ?? false;

  Future<void> markKanjiLearned(String char) async {
    if (isKanjiLearned(char)) return;
    await _prefs.setBool(_kanjiKey(char), true);
    await markStudyDay(notify: false);
    notifyListeners();
  }

  // Thống kê: số câu đã trả lời/đúng và số giây học lưu dạng số thực để phép
  // gộp khi đồng bộ (lấy giá trị lớn hơn) dùng được; ngày học lưu `day.<ngày>`.
  static const _answeredKey = 'stats.answered';
  static const _correctKey = 'stats.correct';
  static const _secondsKey = 'stats.seconds';

  static String _dayKey(DateTime d) =>
      'day.${d.year}-${_two(d.month)}-${_two(d.day)}';

  static String _two(int n) => n.toString().padLeft(2, '0');

  int get answeredCount => (_prefs.getDouble(_answeredKey) ?? 0).round();

  int get correctCount =>
      (_prefs.getDouble(_correctKey) ?? 0).round().clamp(0, answeredCount);

  /// Tỉ lệ trả lời đúng (0..1), null nếu chưa trả lời câu nào.
  double? get accuracy =>
      answeredCount == 0 ? null : correctCount / answeredCount;

  /// Ghi lại một câu trả lời trong các bài luyện tập.
  Future<void> recordAnswer(bool correct, {DateTime? now}) async {
    await _prefs.setDouble(_answeredKey, answeredCount + 1.0);
    if (correct) await _prefs.setDouble(_correctKey, correctCount + 1.0);
    await markStudyDay(now: now, notify: false);
    notifyListeners();
  }

  Duration get studyTime =>
      Duration(seconds: (_prefs.getDouble(_secondsKey) ?? 0).round());

  /// Cộng thời gian mở ứng dụng để học.
  Future<void> addStudyTime(Duration d, {DateTime? now}) async {
    if (d.inSeconds <= 0) return;
    await _prefs.setDouble(
      _secondsKey,
      studyTime.inSeconds + d.inSeconds + 0.0,
    );
    await markStudyDay(now: now, notify: false);
    notifyListeners();
  }

  bool isStudyDay(DateTime d) => _prefs.getBool(_dayKey(d)) ?? false;

  Future<void> markStudyDay({DateTime? now, bool notify = true}) async {
    final key = _dayKey(now ?? DateTime.now());
    if (_prefs.getBool(key) == true) return;
    await _prefs.setBool(key, true);
    if (notify) notifyListeners();
  }

  /// Số ngày học liên tiếp tính đến hôm nay (hoặc hôm qua nếu hôm nay chưa học).
  int streak({DateTime? now}) {
    var d = now ?? DateTime.now();
    d = DateTime(d.year, d.month, d.day);
    if (!isStudyDay(d)) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (isStudyDay(d)) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
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

  // Các khóa tiến độ được đồng bộ (cài đặt như furigana, học thử thì không).
  static const _syncedPrefixes = [
    'grammar.',
    'vocabDone.',
    'reading.',
    'n5test.',
    'word.',
    'kanji.',
    'stats.',
    'day.',
  ];

  static bool _isSynced(String key) =>
      _syncedPrefixes.any((p) => key.startsWith(p));

  /// Tiến độ dạng {khóa: giá trị}, để đẩy lên máy chủ.
  Map<String, dynamic> exportData() => {
    for (final k in _prefs.getKeys())
      if (_isSynced(k)) k: _prefs.get(k),
  };

  /// Gộp tiến độ từ máy chủ: điểm lấy cao nhất, "đã học xong" thì giữ nếu
  /// một trong hai nơi đã xong. Trả về true nếu tiến độ trên máy thay đổi.
  Future<bool> mergeData(Map<String, dynamic> remote) async {
    var changed = false;
    for (final e in remote.entries) {
      if (!_isSynced(e.key)) continue;
      final v = e.value;
      if (v is num) {
        final mine = _prefs.getDouble(e.key);
        if (mine == null || v > mine) {
          await _prefs.setDouble(e.key, v.toDouble());
          changed = true;
        }
      } else if (v == true && _prefs.getBool(e.key) != true) {
        await _prefs.setBool(e.key, true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
    return changed;
  }
}
