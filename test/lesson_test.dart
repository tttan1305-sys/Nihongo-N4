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
import 'package:nihongo_n4/services/recognizer.dart';
import 'package:nihongo_n4/services/speaker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Lesson loadLesson26() => Lesson.fromJson(
  jsonDecode(File('assets/lessons/26.json').readAsStringSync())
      as Map<String, dynamic>,
);

Future<ProgressStore> freshProgress() async {
  SharedPreferences.setMockInitialValues({});
  return ProgressStore(await SharedPreferences.getInstance());
}

class FakeSpeaker implements Speaker {
  final spoken = <(String, String)>[];

  @override
  Future<void> speak({
    required int lesson,
    required String audioId,
    required String text,
  }) async => spoken.add((audioId, text));

  @override
  Future<void> stop() async {}
}

class FakeRecognizer implements Recognizer {
  /// Câu "nghe được" lần tới; null là không nghe được gì.
  String? next;

  @override
  Future<String?> listenOnce() async => next;

  @override
  Future<void> stop() async {}
}

Future<void> openLesson26(
  WidgetTester tester,
  ProgressStore progress, {
  Speaker? speaker,
  FlashcardStore? flashcards,
  Recognizer? recognizer,
}) async {
  final repository = LessonRepository();
  // File bài học lớn được đọc trên isolate riêng, phải chờ bằng thời gian thật.
  await tester.runAsync(() => repository.load(26));
  await tester.pumpWidget(
    NihongoApp(
      repository: repository,
      progress: progress,
      flashcards:
          flashcards ?? FlashcardStore(await SharedPreferences.getInstance()),
      speaker: speaker ?? FakeSpeaker(),
      recognizer: recognizer ?? FakeRecognizer(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const ValueKey('lesson-26')));
  await tester.tap(find.byKey(const ValueKey('lesson-26')));
  await tester.pumpAndSettle();
}

void main() {
  test('đọc được bài 26 và mọi id tham chiếu đều tồn tại', () {
    final lesson = loadLesson26();
    expect(lesson.number, 26);
    expect(lesson.grammar, hasLength(4));
    expect(lesson.vocab, hasLength(24));
    expect(lesson.reading.questions, isNotEmpty);
    final ids = lesson.sentencesById;
    for (final id in [
      ...lesson.speakingIds,
      ...lesson.listening.map((q) => q.audioId!),
    ]) {
      expect(ids, contains(id));
    }
    for (final q in [
      ...lesson.grammar.expand((g) => g.quiz),
      ...lesson.reading.questions,
    ]) {
      expect(q.answer, inInclusiveRange(0, q.options.length - 1));
    }
  });

  test(
    'từ vựng chỉ mở khi mọi mẫu ngữ pháp đạt từ 80%, điểm giữ mức cao nhất',
    () async {
      final lesson = loadLesson26();
      final progress = await freshProgress();
      expect(progress.isVocabUnlocked(lesson), isFalse);

      await progress.saveGrammarScore(26, 'g1', 0.5);
      expect(progress.isGrammarPassed(26, 'g1'), isFalse);
      await progress.saveGrammarScore(26, 'g1', 1);
      await progress.saveGrammarScore(26, 'g1', 0.3);
      expect(progress.grammarScore(26, 'g1'), 1);

      for (final g in lesson.grammar.take(3)) {
        await progress.saveGrammarScore(26, g.id, 0.8);
      }
      expect(progress.isVocabUnlocked(lesson), isFalse);
      await progress.saveGrammarScore(26, lesson.grammar.last.id, 1);
      expect(progress.passedGrammarCount(lesson), 4);
      expect(progress.isVocabUnlocked(lesson), isTrue);
    },
  );

  testWidgets('trang chủ mở được bài 26, phần từ vựng đang khóa', (
    tester,
  ) async {
    await openLesson26(tester, await freshProgress());
    expect(find.text('Bài 26'), findsOneWidget);
    expect(
      find.text(
        'Giải thích lý do, hoàn cảnh; hoặc hỏi để người khác giải thích',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Từ vựng'));
    await tester.pumpAndSettle();
    expect(find.text('Phần Từ vựng đang khóa'), findsOneWidget);
    expect(find.textContaining('Đã qua 0/4'), findsOneWidget);
  });

  testWidgets('làm đúng hết bài kiểm tra ngữ pháp thì mở được từ vựng', (
    tester,
  ) async {
    final lesson = loadLesson26();
    final progress = await freshProgress();
    await openLesson26(tester, progress);

    for (final g in lesson.grammar) {
      await tester.tap(find.byKey(ValueKey('grammar-${g.id}')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('start-quiz')),
        300,
      );
      await tester.tap(find.byKey(const ValueKey('start-quiz')));
      await tester.pumpAndSettle();
      for (final q in g.quiz) {
        await tester.tap(find.byKey(ValueKey('option-${q.answer}')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('next')));
        await tester.pumpAndSettle();
      }
      expect(find.textContaining('(100%)'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('done')));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }

    expect(progress.isVocabUnlocked(lesson), isTrue);
    await tester.tap(find.text('Từ vựng'));
    await tester.pumpAndSettle();
    expect(find.text('Phần Từ vựng đang khóa'), findsNothing);
    expect(find.text('khám (bệnh)'), findsOneWidget);
  });

  testWidgets('trả lời sai thì không qua và được làm lại', (tester) async {
    final lesson = loadLesson26();
    final progress = await freshProgress();
    await openLesson26(tester, progress);
    final g = lesson.grammar.first;

    await tester.tap(find.byKey(ValueKey('grammar-${g.id}')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('start-quiz')),
      300,
    );
    await tester.tap(find.byKey(const ValueKey('start-quiz')));
    await tester.pumpAndSettle();
    for (final q in g.quiz) {
      await tester.tap(
        find.byKey(ValueKey('option-${(q.answer + 1) % q.options.length}')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('next')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Làm lại'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('done')));
    await tester.pumpAndSettle();
    expect(progress.grammarScore(26, g.id), 0);
    expect(progress.isGrammarPassed(26, g.id), isFalse);
  });

  testWidgets(
    'phần từ vựng: nghe từ theo kana, nghe câu thực tế, tắt furigana, đánh dấu học xong',
    (tester) async {
      final lesson = loadLesson26();
      final progress = await freshProgress();
      for (final g in lesson.grammar) {
        await progress.saveGrammarScore(26, g.id, 1);
      }
      final speaker = FakeSpeaker();
      await openLesson26(tester, progress, speaker: speaker);
      await tester.tap(find.text('Từ vựng'));
      await tester.pumpAndSettle();

      expect(find.text('khám (bệnh)'), findsOneWidget);
      expect(
        find.text('Dùng thực tế: Gọi điện đặt lịch ở phòng khám'),
        findsOneWidget,
      );
      // Furigana nằm thành chữ riêng phía trên chữ Hán, tắt đi thì số chữ み giảm.
      final withRuby = find.text('み').evaluate().length;

      await tester.tap(find.byKey(const ValueKey('listen-v01')));
      await tester.tap(find.byKey(const ValueKey('listen-v01_p')));
      expect(speaker.spoken, [
        ('v01', 'みます'),
        ('v01_p', '熱があるんですが、今日診ていただけませんか。'),
      ]);

      await tester.tap(find.byKey(const ValueKey('toggle-furigana')));
      await tester.pumpAndSettle();
      expect(progress.showFurigana, isFalse);
      expect(find.text('み').evaluate().length, lessThan(withRuby));

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
      expect(progress.isVocabDone(26), isTrue);
      expect(find.text('Bạn đã học xong từ vựng bài này'), findsOneWidget);
    },
  );

  test('chọn giọng nữ tiếng Nhật của máy', () {
    expect(pickJapaneseFemaleVoice([]), isNull);
    expect(
      pickJapaneseFemaleVoice([
        {'name': 'en-us-x-sfg', 'locale': 'en-US'},
      ]),
      isNull,
    );
    expect(
      pickJapaneseFemaleVoice([
        {'name': 'ja-jp-x-jac-local', 'locale': 'ja-JP'},
        {'name': 'ja-jp-x-htm-network', 'locale': 'ja-JP'},
      ]),
      {'name': 'ja-jp-x-htm-network', 'locale': 'ja-JP'},
    );
    expect(
      pickJapaneseFemaleVoice([
        {'name': 'Kyoko', 'locale': 'ja_JP'},
      ]),
      {'name': 'Kyoko', 'locale': 'ja_JP'},
    );
    // Trình duyệt Edge: chọn Nanami (nữ) thay vì Keita (nam).
    expect(
      pickJapaneseFemaleVoice([
        {'name': 'Microsoft Keita Online', 'locale': 'ja-JP'},
        {'name': 'Microsoft Nanami Online', 'locale': 'ja-JP'},
      ]),
      {'name': 'Microsoft Nanami Online', 'locale': 'ja-JP'},
    );
  });
}
