import 'dart:math';

import '../models/lesson.dart';
import '../models/n5.dart';
import 'lesson_repository.dart';
import 'n5_repository.dart';

/// Một từ trong danh sách từ vựng chung (từ bài N4 hoặc từ Tổng hợp N5).
class WordEntry {
  /// Mã duy nhất: `26:v01` cho từ bài 26, `n5:n5v001` cho từ N5.
  final String key;
  final String word;
  final String kana;
  final String meaningVi;
  final String level;
  final Sentence? example;

  /// Tình huống dùng thực tế của câu ví dụ (chỉ từ bài N4 có).
  final String? situationVi;

  /// Dùng để tìm file giọng đọc: `assets/audio/<audioLesson>_<audioId>.mp3`.
  final int audioLesson;
  final String audioId;

  const WordEntry({
    required this.key,
    required this.word,
    required this.kana,
    required this.meaningVi,
    required this.level,
    required this.audioLesson,
    required this.audioId,
    this.example,
    this.situationVi,
  });

  factory WordEntry.fromVocab(int lesson, Vocab v) => WordEntry(
    key: '$lesson:${v.id}',
    word: v.word,
    kana: v.kana,
    meaningVi: v.meaningVi,
    level: 'N4',
    audioLesson: lesson,
    audioId: v.id,
    example: v.practical,
    situationVi: v.practical.situationVi,
  );

  factory WordEntry.fromN5(N5Word w) => WordEntry(
    key: 'n5:${w.id}',
    word: w.word,
    kana: w.kana,
    meaningVi: w.meaningVi,
    level: 'N5',
    audioLesson: n5AudioLesson,
    audioId: w.id,
    example: w.example,
  );
}

/// Một nhóm từ: một bài N4 hoặc một chủ đề N5.
class WordGroup {
  final String id;
  final String title;
  final String subtitle;
  final String level;
  final List<WordEntry> words;

  /// Bài N4 của nhóm, để khóa từ vựng cho đến khi học xong ngữ pháp.
  final Lesson? lesson;

  const WordGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.words,
    this.lesson,
  });
}

/// Toàn bộ từ vựng của ứng dụng, chia theo nhóm.
class WordBank {
  final List<WordGroup> groups;

  const WordBank(this.groups);

  static Future<WordBank> load(
    LessonRepository lessons,
    N5Repository n5,
  ) async {
    final numbers = (await lessons.availableLessons()).toList()..sort();
    final data = await n5.load();
    return WordBank([
      for (final number in numbers) _lesson(await lessons.load(number)),
      for (final t in data.topics) _topic(t),
    ]);
  }

  static WordGroup _lesson(Lesson lesson) => WordGroup(
    id: 'l${lesson.number}',
    title: 'Bài ${lesson.number}',
    subtitle: lesson.titleVi,
    level: 'N4',
    lesson: lesson,
    words: [
      for (final v in lesson.vocab) WordEntry.fromVocab(lesson.number, v),
    ],
  );

  static WordGroup _topic(N5Topic t) => WordGroup(
    id: t.id,
    title: t.titleVi,
    subtitle: '${t.words.length} từ',
    level: 'N5',
    words: [for (final w in t.words) WordEntry.fromN5(w)],
  );

  Iterable<WordEntry> get all => groups.expand((g) => g.words);

  int get total => groups.fold(0, (n, g) => n + g.words.length);
}

/// Trắc nghiệm nghĩa từ: hỏi [count] từ trong [words], đáp án sai lấy từ [pool].
List<Question> meaningQuiz(
  List<WordEntry> words,
  List<WordEntry> pool, {
  int count = 10,
  Random? rnd,
}) {
  rnd ??= Random();
  final picked = [...words]..shuffle(rnd);
  final meanings = {for (final w in pool) w.meaningVi}.toList();
  return [
    for (final w in picked.take(count))
      () {
        final wrong = meanings.where((m) => m != w.meaningVi).toList()
          ..shuffle(rnd);
        final options = [w.meaningVi, ...wrong.take(3)]..shuffle(rnd);
        return Question(
          prompt: w.word,
          options: options,
          answer: options.indexOf(w.meaningVi),
          explanationVi: '${w.kana}: ${w.meaningVi}',
        );
      }(),
  ];
}

/// Một câu cần sắp xếp: các cụm từ đúng thứ tự và nghĩa tiếng Việt.
class OrderItem {
  final String id;
  final List<String> chunks;
  final String vi;

  const OrderItem({required this.id, required this.chunks, required this.vi});

  String get sentence => chunks.join();
}

/// Lấy câu ví dụ ngữ pháp N5 (các cụm từ đã cách bằng dấu cách toàn góc)
/// làm bài sắp xếp câu. Chỉ lấy câu đơn có 3–6 cụm.
List<OrderItem> orderItems(
  List<N5GrammarLesson> lessons, {
  int count = 10,
  Random? rnd,
}) {
  final all = <OrderItem>[];
  for (final l in lessons) {
    for (final p in l.points) {
      for (final e in p.examples) {
        final ja = e.ja.trim();
        final ends = RegExp('[。？！?!]').allMatches(ja).length;
        if (ends > 1 || ja.contains('…') || ja.contains('「')) continue;
        final chunks = ja.split('　').where((c) => c.isNotEmpty).toList();
        if (chunks.length < 3 || chunks.length > 6) continue;
        all.add(OrderItem(id: e.id, chunks: chunks, vi: e.vi));
      }
    }
  }
  all.shuffle(rnd ?? Random());
  return all.take(count).toList();
}
