import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/flashcard_store.dart';
import 'package:nihongo_n4/data/lesson_repository.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/main.dart';
import 'package:nihongo_n4/models/lesson.dart';
import 'package:nihongo_n4/screens/vocab_tab.dart';
import 'package:nihongo_n4/srs/sm2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_test.dart' show FakeRecognizer, FakeSpeaker;

Lesson loadLesson26() => Lesson.fromJson(
  jsonDecode(File('assets/lessons/26.json').readAsStringSync())
      as Map<String, dynamic>,
);

void main() {
  var clock = DateTime(2026, 10, 20, 9);

  setUp(() {
    clock = DateTime(2026, 10, 20, 9);
    SharedPreferences.setMockInitialValues({});
  });

  test('thêm bài vào flashcard, ôn, lưu lại sau khi mở lại app', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = FlashcardStore(prefs, clock: () => clock);
    final lesson = loadLesson26();

    await store.add(26, 'v01');
    await store.rate(const CardId(26, 'v01'), Rating.easy);
    await store.addLesson(lesson);
    expect(store.totalCount, 24);
    expect(store.dueCards(), hasLength(23)); // v01 đã ôn, hẹn 4 ngày sau

    await store.rate(const CardId(26, 'v02'), Rating.good);
    final reopened = FlashcardStore(prefs, clock: () => clock);
    expect(reopened.totalCount, 24);
    expect(reopened.dueCards(), hasLength(22));
    expect(reopened.stateOf(const CardId(26, 'v02'))!.intervalDays, 1);

    clock = clock.add(const Duration(days: 4));
    expect(reopened.dueCards(), hasLength(24));
    await reopened.remove(26, 'v01');
    expect(reopened.contains(26, 'v01'), isFalse);
  });

  testWidgets('học xong từ vựng → trang chủ báo 24 thẻ → ôn hết', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final lesson = loadLesson26();
    final progress = ProgressStore(prefs);
    for (final g in lesson.grammar) {
      await progress.saveGrammarScore(26, g.id, 1);
    }
    final flashcards = FlashcardStore(prefs, clock: () => clock);
    final repository = LessonRepository();
    await tester.runAsync(() => repository.load(26));
    await tester.pumpWidget(
      NihongoApp(
        repository: repository,
        progress: progress,
        flashcards: flashcards,
        speaker: FakeSpeaker(),
        recognizer: FakeRecognizer(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có flashcard'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('lesson-26')));
    await tester.tap(find.byKey(const ValueKey('lesson-26')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Từ vựng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deck-v01')));
    await tester.pumpAndSettle();
    expect(flashcards.contains(26, 'v01'), isTrue);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('vocab-done')),
      500,
      scrollable: find
          .descendant(
            of: find.byType(VocabTab),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('vocab-done')));
    await tester.pumpAndSettle();
    expect(flashcards.totalCount, 24);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Hôm nay cần ôn 24 thẻ'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('start-review')));
    await tester.tap(find.byKey(const ValueKey('start-review')));
    await tester.pumpAndSettle();
    expect(find.text('Còn 24 thẻ · Bài 26'), findsOneWidget);

    // Thẻ đầu bấm Quên: quay lại cuối hàng, vẫn còn 24 thẻ.
    await tester.tap(find.byKey(const ValueKey('reveal')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('answer-kana')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('rate-again')));
    await tester.pumpAndSettle();
    expect(find.text('Còn 24 thẻ · Bài 26'), findsOneWidget);

    for (var i = 0; i < 24; i++) {
      await tester.tap(find.byKey(const ValueKey('reveal')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('rate-good')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Hôm nay bạn đã ôn xong!'), findsOneWidget);
    expect(find.text('Đã ôn 25 lượt thẻ.'), findsOneWidget);

    await tester.tap(find.text('Về trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Hôm nay cần ôn 0 thẻ'), findsOneWidget);
  });
}
