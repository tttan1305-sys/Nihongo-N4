import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/n5_repository.dart';
import 'package:nihongo_n4/models/n5.dart';
import 'package:nihongo_n4/screens/n5_screen.dart';
import 'package:nihongo_n4/screens/quiz_screen.dart';

import 'lesson_test.dart' show FakeSpeaker;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late N5Data data;

  setUpAll(() async {
    data = await N5Repository().load();
  });

  ConjugatedVerb verb(String id) =>
      data.forms.verbs.firstWhere((v) => v.id == id);

  test('đọc đủ các thể, ngữ pháp bài 1–25 và từ vựng', () {
    expect(data.forms.verbs, hasLength(17));
    expect(data.grammar.map((l) => l.lesson), [
      for (var i = 1; i <= 25; i++) i,
    ]);
    expect(data.grammarCount, greaterThan(100));
    expect(data.wordCount, greaterThan(300));
  });

  test('bảng chia đúng các trường hợp đặc biệt', () {
    expect(verb('kaku').forms['te'], '{書|か}いて');
    expect(verb('iku').forms['te'], '{行|い}って');
    expect(verb('oyogu').forms['ta'], '{泳|およ}いだ');
    expect(verb('nomu').forms['te'], '{飲|の}んで');
    expect(verb('kau').forms['nai'], '{買|か}わない');
    expect(verb('kaeru').forms['masu'], '{帰|かえ}ります');
    expect(verb('miru').forms['nai'], '{見|み}ない');
    expect(verb('kuru').forms['nai'], '{来|こ}ない');
    expect(verb('kuru').forms['te'], '{来|き}て');
    expect(verb('suru').forms['tara'], 'したら');
  });

  test('câu hỏi luyện tập có 4 đáp án khác nhau và đáp án đúng', () {
    final rnd = Random(1);
    final questions = [
      ...conjugationQuiz(data.forms, rnd: rnd),
      for (final l in data.grammar) ...grammarQuiz(l, data.grammar, rnd: rnd),
      for (final t in data.topics) ...vocabQuiz(t, data.topics, rnd: rnd),
    ];
    expect(questions, hasLength(10 + data.grammarCount + data.wordCount));
    for (final q in questions) {
      expect(q.options.toSet(), hasLength(q.options.length), reason: q.prompt);
      expect(q.options.length, greaterThanOrEqualTo(2), reason: q.prompt);
      expect(q.answer, inInclusiveRange(0, q.options.length - 1));
    }
  });

  testWidgets('mở Tổng hợp N5: các thể, ngữ pháp, từ vựng', (tester) async {
    final repository = N5Repository();
    await tester.runAsync(repository.load);
    final speaker = FakeSpeaker();
    await tester.pumpWidget(
      MaterialApp(
        home: N5Screen(repository: repository, speaker: speaker),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('n5-conjugation-quiz')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('n5-form-masu')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('n5-tab-grammar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('n5-grammar-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('n5-grammar-quiz-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('n5-tab-vocab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('n5-topic-t01')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('listen-n5v001')));
    expect(speaker.spoken.first, ('n5v001', 'わたし'));

    await tester.tap(find.byKey(const ValueKey('n5-vocab-quiz')));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsOneWidget);
  });
}
