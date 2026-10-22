import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/lesson_repository.dart';
import 'package:nihongo_n4/data/n5_repository.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/data/word_bank.dart';
import 'package:nihongo_n4/models/n5.dart';
import 'package:nihongo_n4/screens/grammar_screen.dart';
import 'package:nihongo_n4/screens/kanji_screen.dart';
import 'package:nihongo_n4/screens/sentence_order_screen.dart';
import 'package:nihongo_n4/screens/vocab_list_screen.dart';
import 'package:nihongo_n4/screens/word_study_screen.dart';
import 'package:nihongo_n4/theme.dart';
import 'package:nihongo_n4/widgets/ruby_text.dart';
import 'package:nihongo_n4/widgets/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_test.dart' show FakeSpeaker;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late N5Data n5;
  late WordBank bank;

  setUpAll(() async {
    final repo = N5Repository();
    n5 = await repo.load();
    bank = await WordBank.load(LessonRepository(), repo);
  });

  Future<ProgressStore> progressStore() async {
    SharedPreferences.setMockInitialValues({});
    return ProgressStore(await SharedPreferences.getInstance());
  }

  Widget app(Widget home) => MaterialApp(theme: buildAppTheme(), home: home);

  test('danh sách từ chung gồm bài 26 và từ N5, mã không trùng', () {
    expect(bank.groups.first.title, 'Bài 26');
    expect(bank.groups.first.lesson, isNotNull);
    expect(bank.total, 24 + n5.wordCount);
    final keys = bank.all.map((w) => w.key).toList();
    expect(keys.toSet(), hasLength(keys.length));
  });

  test('từ có chữ Hán đều có âm Hán Việt', () {
    final words = bank.all.toList();
    final w = words.firstWhere((w) => w.word == '{会社員|かいしゃいん}');
    expect(w.hanViet, 'Hội Xã Viên');
    for (final w in words) {
      final hasKanji = RegExp('[一-鿿]').hasMatch(plainText(w.word));
      expect(w.hanViet.isNotEmpty, hasKanji, reason: w.word);
    }
    expect(n5.kanji.first.radicalName, 'Nhất (số một)');
  });

  test('chữ Hán N5 đủ thông tin, không trùng', () {
    expect(n5.kanji.length, greaterThanOrEqualTo(100));
    expect(n5.kanji.map((k) => k.char).toSet(), hasLength(n5.kanji.length));
    for (final k in n5.kanji) {
      expect(k.strokes, greaterThan(0), reason: k.char);
      expect(k.mnemonicVi, isNotEmpty, reason: k.char);
      expect(k.example.ja, contains(k.char), reason: k.char);
    }
  });

  test('bài sắp xếp câu: 3–6 cụm, ghép lại đúng câu gốc', () {
    final items = orderItems(n5.grammar, count: 1000, rnd: Random(1));
    expect(items.length, greaterThanOrEqualTo(30));
    for (final i in items) {
      expect(i.chunks.length, inInclusiveRange(3, 6));
      expect(i.sentence, isNot(contains('　')));
    }
  });

  test('trắc nghiệm nghĩa từ có 4 đáp án khác nhau', () {
    final quiz = meaningQuiz(bank.all.toList(), bank.all.toList());
    expect(quiz, hasLength(10));
    for (final q in quiz) {
      expect(q.options.toSet(), hasLength(4));
      expect(q.answer, inInclusiveRange(0, 3));
    }
  });

  test('tiêu đề ngắn của mẫu ngữ pháp', () {
    expect(grammarTitle('{普通形|ふつうけい} ＋ んです'), '～んです');
    expect(grammarTitle('Vます + てきます'), '～てきます');
    expect(grammarTitle('～か'), '～か');
  });

  test(
    'từ đã học và chữ Hán đã nhớ được đồng bộ, yêu thích thì không',
    () async {
      final p = await progressStore();
      await p.markWordLearned('n5:n5v001');
      await p.markKanjiLearned('家');
      await p.toggleFavorite('n5:n5v001');
      expect(p.exportData(), {'word.n5:n5v001': true, 'kanji.家': true});
      await p.toggleFavorite('n5:n5v001');
      expect(p.isFavorite('n5:n5v001'), isFalse);
    },
  );

  testWidgets('học từ: Tiếp theo đánh dấu đã học, hết thì báo xong', (
    tester,
  ) async {
    final p = await progressStore();
    final speaker = FakeSpeaker();
    final words = bank.groups.last.words.take(2).toList();
    await tester.pumpWidget(
      app(WordStudyScreen(words: words, progress: p, speaker: speaker)),
    );
    expect(find.text('1/2'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('listen-${words[0].audioId}')));
    expect(speaker.spoken.single, (words[0].audioId, words[0].kana));
    await tester.tap(find.byKey(const ValueKey('study-next')));
    await tester.pumpAndSettle();
    expect(p.isWordLearned(words[0].key), isTrue);
    expect(find.text('2/2'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('study-next')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('study-done')), findsOneWidget);
  });

  testWidgets('danh sách từ: bài 26 khóa, N5 tìm kiếm và lọc yêu thích', (
    tester,
  ) async {
    final p = await progressStore();
    await tester.pumpWidget(
      app(VocabListScreen(bank: bank, progress: p, speaker: FakeSpeaker())),
    );
    // Bài 26 chưa học ngữ pháp nên mở sẵn N5.
    expect(find.text('Từ vựng N5'), findsOneWidget);
    await tester.tap(find.text('N4'));
    await tester.pumpAndSettle();
    expect(
      find.text('Học xong phần Ngữ pháp của bài này để mở từ vựng.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('word-26:v01')), findsNothing);

    await tester.tap(find.text('N5'));
    await tester.pumpAndSettle();
    final first = bank.groups.firstWhere((g) => g.level == 'N5').words.first;
    await tester.tap(find.byKey(ValueKey('fav-${first.key}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter-favorite')));
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('word-${first.key}')), findsOneWidget);
    expect(find.byType(NumberBadge), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('filter-all')));
    await tester.enterText(
      find.byKey(const ValueKey('vocab-search')),
      'zzz-không-có',
    );
    await tester.pumpAndSettle();
    expect(find.text('Không có từ nào phù hợp.'), findsOneWidget);
  });

  testWidgets('sắp xếp câu: chọn đúng thứ tự thì báo chính xác', (
    tester,
  ) async {
    final item = orderItems(n5.grammar, rnd: Random(3)).first;
    await tester.pumpWidget(app(SentenceOrderScreen(items: [item])));
    for (var i = 0; i < item.chunks.length; i++) {
      await tester.tap(find.byKey(ValueKey('chunk-$i')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey('order-check')));
    await tester.pump();
    expect(find.text('Chính xác!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('order-next')));
    await tester.pump();
    expect(find.text('Đúng 1/1 câu'), findsOneWidget);
  });

  testWidgets('học Kanji: Đã nhớ thì lưu và sang chữ sau', (tester) async {
    final p = await progressStore();
    await tester.pumpWidget(
      app(KanjiScreen(kanji: n5.kanji, progress: p, speaker: FakeSpeaker())),
    );
    Text shown() =>
        tester.widget<Text>(find.byKey(const ValueKey('kanji-char')));
    expect(shown().data, n5.kanji[0].char);
    await tester.tap(find.byKey(const ValueKey('kanji-learned')));
    await tester.pumpAndSettle();
    expect(p.isKanjiLearned(n5.kanji[0].char), isTrue);
    expect(shown().data, n5.kanji[1].char);
  });

  testWidgets('chi tiết ngữ pháp N5 có cách dùng, cấu trúc, ví dụ', (
    tester,
  ) async {
    final p = await progressStore();
    final point = n5.grammar.first.points.first;
    await tester.pumpWidget(
      app(GrammarScreen.n5(point: point, progress: p, speaker: FakeSpeaker())),
    );
    expect(find.text('Cách dùng'), findsOneWidget);
    expect(find.text('Cấu trúc'), findsOneWidget);
    expect(find.text('Ví dụ'), findsOneWidget);
    expect(find.text(point.meaningVi), findsOneWidget);
    expect(find.byKey(const ValueKey('start-quiz')), findsNothing);
  });
}
