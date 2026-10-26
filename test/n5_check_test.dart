import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/n5_repository.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/models/n5.dart';
import 'package:nihongo_n4/screens/n5_check_screen.dart';
import 'package:nihongo_n4/screens/n5_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_test.dart' show FakeSpeaker;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late N5Data data;

  setUpAll(() async {
    data = await N5Repository().load();
  });

  Future<ProgressStore> progressStore() async {
    SharedPreferences.setMockInitialValues({'settings.textScale': 1.0});
    return ProgressStore(await SharedPreferences.getInstance());
  }

  test('bài kiểm tra có đủ đáp án, câu đúng và lý do sai từng đáp án', () {
    expect(data.checks, hasLength(6));
    final all = [for (final s in data.checks) ...s.questions];
    expect(all.length, greaterThanOrEqualTo(data.grammarCount + 7));
    for (final q in all) {
      expect(q.options.toSet(), hasLength(4), reason: q.id);
      expect(q.answer, inInclusiveRange(0, 3), reason: q.id);
      expect(q.wrongVi, hasLength(4), reason: q.id);
      for (var i = 0; i < 4; i++) {
        expect(q.wrongVi[i].isEmpty, i == q.answer, reason: q.id);
      }
      for (final f in [q.fullJa, q.meaningVi, q.explainVi, q.tipVi]) {
        expect(f, isNotEmpty, reason: q.id);
      }
      expect(q.coversVi, isNotEmpty, reason: q.id);
    }
  });

  testWidgets('chọn đáp án là hiện phân tích; làm lại câu sai', (tester) async {
    final progress = await progressStore();
    final source = data.checks.first;
    final set = N5CheckSet(
      id: source.id,
      titleVi: source.titleVi,
      subtitleVi: source.subtitleVi,
      questions: source.questions.take(2).toList(),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: N5CheckScreen(
          set: set,
          progress: progress,
          speaker: FakeSpeaker(),
        ),
      ),
    );

    // Câu 1 chọn sai: hiện đáp án đúng, phân tích, lý do sai, mẹo nhớ.
    final q1 = set.questions[0];
    final wrong = (q1.answer + 1) % 4;
    expect(find.text('Phân tích'), findsNothing);
    await tester.tap(find.byKey(ValueKey('check-option-$wrong')));
    await tester.pump();
    expect(find.textContaining('Chưa đúng'), findsOneWidget);
    for (final title in [
      'Câu đúng và ý nghĩa',
      'Phân tích',
      'Vì sao các đáp án khác sai',
      'Mẹo nhớ',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text(q1.meaningVi), findsOneWidget);
    expect(find.text('Bạn chọn'), findsOneWidget);
    expect(find.byKey(ValueKey('check-wrong-${q1.answer}')), findsNothing);
    // Đã chọn thì không đổi đáp án được nữa.
    await tester.tap(find.byKey(ValueKey('check-option-${q1.answer}')));
    await tester.pump();
    expect(find.textContaining('Chưa đúng'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('check-next')));
    await tester.pump();
    final q2 = set.questions[1];
    await tester.tap(find.byKey(ValueKey('check-option-${q2.answer}')));
    await tester.pump();
    expect(find.text('Chính xác!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('check-next')));
    await tester.pumpAndSettle();

    expect(find.text('Đúng 1/2 câu (50%)'), findsOneWidget);
    expect(progress.n5TestScore(set.id), 0.5);

    // Làm lại câu sai: chỉ còn câu 1, làm đúng không đổi điểm cao nhất.
    await tester.tap(find.byKey(const ValueKey('check-retry-wrong')));
    await tester.pump();
    expect(find.text('${set.titleVi}  (1/1)'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('check-option-${q1.answer}')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('check-next')));
    await tester.pumpAndSettle();
    expect(find.text('Đúng 1/1 câu (100%)'), findsOneWidget);
    expect(progress.n5TestScore(set.id), 0.5);
  });

  testWidgets('tab Kiểm tra liệt kê các bài', (tester) async {
    final repository = N5Repository();
    await tester.runAsync(repository.load);
    await tester.pumpWidget(
      MaterialApp(
        home: N5Screen(
          repository: repository,
          progress: await progressStore(),
          speaker: FakeSpeaker(),
          initialTab: N5Screen.checksTab,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('n5-check-check-forms')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('n5-check-check-forms')));
    await tester.pumpAndSettle();
    expect(find.byType(N5CheckScreen), findsOneWidget);
  });
}
