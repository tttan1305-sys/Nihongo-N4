import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/flashcard_store.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/models/lesson.dart';
import 'package:nihongo_n4/screens/reading_tab.dart';
import 'package:nihongo_n4/services/japanese_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_test.dart' show FakeRecognizer, FakeSpeaker, openLesson26;

Lesson loadLesson26() =>
    Lesson.fromJson(jsonDecode(File('assets/lessons/26.json').readAsStringSync()) as Map<String, dynamic>);

/// Tiến độ khi đã qua ngữ pháp và học xong từ vựng bài 26.
Future<ProgressStore> progressAfterVocab() async {
  SharedPreferences.setMockInitialValues({});
  final progress = ProgressStore(await SharedPreferences.getInstance());
  for (final g in loadLesson26().grammar) {
    await progress.saveGrammarScore(26, g.id, 1);
  }
  await progress.markVocabDone(26);
  return progress;
}

void main() {
  test('chuẩn hóa và chấm câu tiếng Nhật', () {
    expect(normalizeJa('「サイフ」を、拾いました。'), 'さいふを拾いました');
    expect(similarity('abc', 'abc'), 1);
    expect(similarity('', ''), 1);
    expect(similarity('abcd', 'abcf'), 0.75);
    // Máy nghe ra chữ Hán hay kana đều chấm được.
    const ja = '{財布|さいふ}を{拾|ひろ}いました。';
    expect(speakingScore(heard: '財布を拾いました', plain: '財布を拾いました。', reading: 'さいふをひろいました。'), 1);
    expect(speakingScore(heard: 'さいふをひろいました', plain: '財布を拾いました。', reading: 'さいふをひろいました。'), 1);
    expect(ja, isNotEmpty);
    expect(speakingScore(heard: 'こんにちは', plain: '財布を拾いました', reading: 'さいふをひろいました'), lessThan(0.5));
  });

  test('bài sau chỉ mở khi bài trước qua đọc hiểu', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = ProgressStore(await SharedPreferences.getInstance());
    expect(progress.isLessonUnlocked(26, first: 26), isTrue);
    expect(progress.isLessonUnlocked(27, first: 26), isFalse);
    await progress.saveReadingScore(26, 0.5);
    expect(progress.isLessonUnlocked(27, first: 26), isFalse);
    await progress.saveReadingScore(26, 0.75);
    await progress.saveReadingScore(26, 1);
    expect(progress.isLessonCompleted(26), isTrue);
    expect(progress.isLessonUnlocked(27, first: 26), isTrue);
  });

  testWidgets('Luyện kỹ năng và Đọc hiểu khóa đến khi học xong từ vựng', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await openLesson26(tester, ProgressStore(await SharedPreferences.getInstance()));
    await tester.tap(find.text('Luyện kỹ năng'));
    await tester.pumpAndSettle();
    expect(find.text('Phần Luyện kỹ năng đang khóa'), findsOneWidget);
    await tester.tap(find.text('Đọc hiểu'));
    await tester.pumpAndSettle();
    expect(find.text('Bài đọc hiểu đang khóa'), findsOneWidget);
  });

  testWidgets('luyện nghe: bấm nghe, chọn nghĩa, hiện lại câu', (tester) async {
    final lesson = loadLesson26();
    final speaker = FakeSpeaker();
    await openLesson26(tester, await progressAfterVocab(), speaker: speaker);
    await tester.tap(find.text('Luyện kỹ năng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skill-listening')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quiz-listen')));
    expect(speaker.spoken.single.$1, 'v03_p');
    await tester.tap(find.byKey(ValueKey('option-${lesson.listening.first.answer}')));
    await tester.pumpAndSettle();
    expect(find.text('Đúng rồi!'), findsOneWidget);
    expect(find.text(lesson.sentencesById['v03_p']!.vi), findsOneWidget);
  });

  testWidgets('luyện nói: máy nghe đúng thì khen, không nghe được thì báo', (tester) async {
    final recognizer = FakeRecognizer();
    await openLesson26(tester, await progressAfterVocab(), recognizer: recognizer);
    await tester.tap(find.text('Luyện kỹ năng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skill-speaking')));
    await tester.pumpAndSettle();

    recognizer.next = 'どうしたんですか頭が痛いんです';
    await tester.tap(find.byKey(const ValueKey('record')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tốt lắm!'), findsOneWidget);

    recognizer.next = null;
    await tester.tap(find.byKey(const ValueKey('record')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Không nghe được'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('next-sentence')));
    await tester.pumpAndSettle();
    expect(find.text('Câu 2/6'), findsOneWidget);
  });

  testWidgets('luyện viết: tập viết chữ Hán và gõ hiragana', (tester) async {
    await openLesson26(tester, await progressAfterVocab());
    await tester.tap(find.text('Luyện kỹ năng'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('skill-writing')));
    await tester.pumpAndSettle();

    expect(find.text('探'), findsOneWidget);
    await tester.drag(find.byKey(const ValueKey('kanji-canvas')), const Offset(50, 50));
    await tester.tap(find.byKey(const ValueKey('next-kanji')));
    await tester.pumpAndSettle();
    expect(find.text('遅'), findsOneWidget);

    await tester.tap(find.text('Gõ hiragana'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('typing-input')), 'さいふを ひろいました');
    await tester.tap(find.byKey(const ValueKey('typing-check')));
    await tester.pumpAndSettle();
    expect(find.text('Chính xác!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('typing-next')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('typing-input')), 'かいぎにおくれる');
    await tester.tap(find.byKey(const ValueKey('typing-check')));
    await tester.pumpAndSettle();
    expect(find.text('Chưa đúng. Đáp án: かいぎにおくれます'), findsOneWidget);
  });

  testWidgets('đọc hiểu: trả lời đúng thì hoàn thành bài, trang chủ báo đã hoàn thành', (tester) async {
    final lesson = loadLesson26();
    final progress = await progressAfterVocab();
    final speaker = FakeSpeaker();
    await openLesson26(tester, progress,
        speaker: speaker, flashcards: FlashcardStore(await SharedPreferences.getInstance()));
    await tester.tap(find.text('Đọc hiểu'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('listen-reading')));
    expect(speaker.spoken.single.$2, startsWith('グエンさんは先月ベトナムから来ました。'));

    final scrollable = find.descendant(of: find.byType(ReadingTab), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('reading-quiz')), 500, scrollable: scrollable);
    await tester.tap(find.byKey(const ValueKey('reading-quiz')));
    await tester.pumpAndSettle();
    for (final q in lesson.reading.questions) {
      await tester.tap(find.byKey(ValueKey('option-${q.answer}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('next')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Bạn đã hoàn thành bài 26!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('done')));
    await tester.pumpAndSettle();
    expect(progress.isLessonCompleted(26), isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Đã hoàn thành'), findsOneWidget);
  });
}
