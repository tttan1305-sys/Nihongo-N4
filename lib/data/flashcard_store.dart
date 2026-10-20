import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../srs/sm2.dart';

/// Mã thẻ dạng `số bài:id từ`, ví dụ `26:v01`.
class CardId {
  final int lesson;
  final String vocabId;

  const CardId(this.lesson, this.vocabId);

  factory CardId.parse(String s) {
    final i = s.indexOf(':');
    return CardId(int.parse(s.substring(0, i)), s.substring(i + 1));
  }

  @override
  String toString() => '$lesson:$vocabId';
}

/// Bộ flashcard lưu trên máy. Giai đoạn 2 sẽ đồng bộ thêm lên Firestore.
class FlashcardStore extends ChangeNotifier {
  static const _key = 'flashcards';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  final Map<String, CardState> _cards;

  FlashcardStore(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        _cards = _load(_prefs);

  static Map<String, CardState> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((k, v) => MapEntry(k, CardState.fromJson(v as Map<String, dynamic>)));
  }

  Future<void> _save() async {
    await _prefs.setString(_key, jsonEncode(_cards.map((k, v) => MapEntry(k, v.toJson()))));
    notifyListeners();
  }

  DateTime get now => _clock();

  int get totalCount => _cards.length;

  bool contains(int lesson, String vocabId) => _cards.containsKey(CardId(lesson, vocabId).toString());

  CardState? stateOf(CardId id) => _cards[id.toString()];

  /// Thêm một từ vào bộ thẻ (không làm gì nếu đã có).
  Future<void> add(int lesson, String vocabId) async {
    final id = CardId(lesson, vocabId).toString();
    if (_cards.containsKey(id)) return;
    _cards[id] = CardState.fresh(now);
    await _save();
  }

  Future<void> remove(int lesson, String vocabId) async {
    if (_cards.remove(CardId(lesson, vocabId).toString()) != null) await _save();
  }

  /// Thêm toàn bộ từ của bài, giữ nguyên tiến độ của những thẻ đã có.
  Future<void> addLesson(Lesson lesson) async {
    final t = now;
    for (final v in lesson.vocab) {
      _cards.putIfAbsent(CardId(lesson.number, v.id).toString(), () => CardState.fresh(t));
    }
    await _save();
  }

  /// Thẻ cần ôn hôm nay, thẻ đến hạn sớm nhất đứng trước.
  List<CardId> dueCards() {
    final t = now;
    final due = _cards.entries.where((e) => e.value.isDue(t)).toList()
      ..sort((a, b) => a.value.due.compareTo(b.value.due));
    return [for (final e in due) CardId.parse(e.key)];
  }

  Future<void> rate(CardId id, Rating rating) async {
    final s = _cards[id.toString()];
    if (s == null) return;
    _cards[id.toString()] = review(s, rating, now);
    await _save();
  }
}
