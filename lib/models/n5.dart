// Phần Tổng hợp N5 (Minna bài 1–25), đọc từ assets/n5/*.json.
// Các file này sinh bằng tools/gen_n5_forms.py, tools/gen_n5_vocab.py
// (ngữ pháp viết tay), và cùng cú pháp furigana {漢字|かんじ} với bài học.

import 'lesson.dart';

class VerbGroup {
  final String name;
  final String descVi;

  const VerbGroup({required this.name, required this.descVi});

  factory VerbGroup.fromJson(Map<String, dynamic> j) =>
      VerbGroup(name: j['name'] as String, descVi: j['descVi'] as String);
}

class FormRule {
  final String group;
  final String ruleVi;
  final String example;

  const FormRule({
    required this.group,
    required this.ruleVi,
    required this.example,
  });

  factory FormRule.fromJson(Map<String, dynamic> j) => FormRule(
    group: j['group'] as String,
    ruleVi: j['ruleVi'] as String,
    example: j['example'] as String,
  );
}

/// Một thể (て形, ない形...): cách chia, cách dùng và ví dụ.
class VerbForm {
  final String id;
  final String name;
  final String nameJa;
  final String lesson;
  final String usesVi;
  final List<FormRule> rules;
  final List<Sentence> examples;

  /// Các cột trong bảng chia của thể này (khóa trong [ConjugatedVerb.forms]).
  final List<String> table;

  const VerbForm({
    required this.id,
    required this.name,
    required this.nameJa,
    required this.lesson,
    required this.usesVi,
    required this.rules,
    required this.examples,
    required this.table,
  });

  factory VerbForm.fromJson(Map<String, dynamic> j) => VerbForm(
    id: j['id'] as String,
    name: j['name'] as String,
    nameJa: j['nameJa'] as String,
    lesson: j['lesson'] as String,
    usesVi: j['usesVi'] as String,
    rules: _list(j['rules'], FormRule.fromJson),
    examples: _list(j['examples'], Sentence.fromJson),
    table: List<String>.from(j['table'] as List),
  );
}

/// Một động từ mẫu đã chia sẵn mọi thể.
class ConjugatedVerb {
  final String id;
  final int group;
  final String meaningVi;
  final Map<String, String> forms;

  const ConjugatedVerb({
    required this.id,
    required this.group,
    required this.meaningVi,
    required this.forms,
  });

  String get dictionary => forms['dict']!;

  factory ConjugatedVerb.fromJson(Map<String, dynamic> j) => ConjugatedVerb(
    id: j['id'] as String,
    group: j['group'] as int,
    meaningVi: j['meaningVi'] as String,
    forms: Map<String, String>.from(j['forms'] as Map),
  );
}

class PlainRow {
  final String label;
  final List<String> cells;

  const PlainRow({required this.label, required this.cells});

  factory PlainRow.fromJson(Map<String, dynamic> j) => PlainRow(
    label: j['label'] as String,
    cells: List<String>.from(j['cells'] as List),
  );
}

/// Bảng thể thông thường (普通形) của động từ, tính từ, danh từ.
class PlainForms {
  final String name;
  final String nameJa;
  final String lesson;
  final String usesVi;
  final List<String> columns;
  final List<PlainRow> rows;
  final List<Sentence> examples;

  const PlainForms({
    required this.name,
    required this.nameJa,
    required this.lesson,
    required this.usesVi,
    required this.columns,
    required this.rows,
    required this.examples,
  });

  factory PlainForms.fromJson(Map<String, dynamic> j) => PlainForms(
    name: j['name'] as String,
    nameJa: j['nameJa'] as String,
    lesson: j['lesson'] as String,
    usesVi: j['usesVi'] as String,
    columns: List<String>.from(j['columns'] as List),
    rows: _list(j['rows'], PlainRow.fromJson),
    examples: _list(j['examples'], Sentence.fromJson),
  );
}

class FormsData {
  final List<VerbGroup> groups;
  final Map<String, String> formLabels;
  final List<VerbForm> forms;
  final List<ConjugatedVerb> verbs;
  final PlainForms plain;

  const FormsData({
    required this.groups,
    required this.formLabels,
    required this.forms,
    required this.verbs,
    required this.plain,
  });

  factory FormsData.fromJson(Map<String, dynamic> j) => FormsData(
    groups: _list(j['groups'], VerbGroup.fromJson),
    formLabels: Map<String, String>.from(j['formLabels'] as Map),
    forms: _list(j['forms'], VerbForm.fromJson),
    verbs: _list(j['verbs'], ConjugatedVerb.fromJson),
    plain: PlainForms.fromJson(j['plain'] as Map<String, dynamic>),
  );
}

class N5GrammarPoint {
  final String id;
  final String pattern;
  final String meaningVi;
  final String explanationVi;
  final List<Sentence> examples;

  const N5GrammarPoint({
    required this.id,
    required this.pattern,
    required this.meaningVi,
    required this.explanationVi,
    required this.examples,
  });

  factory N5GrammarPoint.fromJson(Map<String, dynamic> j) => N5GrammarPoint(
    id: j['id'] as String,
    pattern: j['pattern'] as String,
    meaningVi: j['meaningVi'] as String,
    explanationVi: j['explanationVi'] as String,
    examples: _list(j['examples'], Sentence.fromJson),
  );
}

class N5GrammarLesson {
  final int lesson;
  final String titleVi;
  final List<N5GrammarPoint> points;

  const N5GrammarLesson({
    required this.lesson,
    required this.titleVi,
    required this.points,
  });

  factory N5GrammarLesson.fromJson(Map<String, dynamic> j) => N5GrammarLesson(
    lesson: j['lesson'] as int,
    titleVi: j['titleVi'] as String,
    points: _list(j['points'], N5GrammarPoint.fromJson),
  );
}

class N5Word {
  final String id;
  final String word;

  /// Âm Hán Việt, ví dụ 会社員 → "Hội Xã Viên" ("" nếu từ không có chữ Hán).
  final String hanViet;
  final String kana;
  final String meaningVi;
  final Sentence example;

  const N5Word({
    required this.id,
    required this.word,
    this.hanViet = '',
    required this.kana,
    required this.meaningVi,
    required this.example,
  });

  factory N5Word.fromJson(Map<String, dynamic> j) => N5Word(
    id: j['id'] as String,
    word: j['word'] as String,
    hanViet: j['hanViet'] as String? ?? '',
    kana: j['kana'] as String,
    meaningVi: j['meaningVi'] as String,
    example: Sentence.fromJson(j['example'] as Map<String, dynamic>),
  );
}

class N5Topic {
  final String id;
  final String titleVi;
  final List<N5Word> words;

  const N5Topic({required this.id, required this.titleVi, required this.words});

  factory N5Topic.fromJson(Map<String, dynamic> j) => N5Topic(
    id: j['id'] as String,
    titleVi: j['titleVi'] as String,
    words: _list(j['words'], N5Word.fromJson),
  );
}

/// Một ý trong phần Kiến thức cần nhớ.
class NoteItem {
  final String id;
  final String head;
  final String bodyVi;
  final Sentence example;

  const NoteItem({
    required this.id,
    required this.head,
    required this.bodyVi,
    required this.example,
  });

  factory NoteItem.fromJson(Map<String, dynamic> j) => NoteItem(
    id: j['id'] as String,
    head: j['head'] as String,
    bodyVi: j['bodyVi'] as String,
    example: Sentence.fromJson(j['example'] as Map<String, dynamic>),
  );
}

class NoteSection {
  final String id;
  final String titleVi;
  final String introVi;
  final List<NoteItem> items;

  const NoteSection({
    required this.id,
    required this.titleVi,
    required this.introVi,
    required this.items,
  });

  factory NoteSection.fromJson(Map<String, dynamic> j) => NoteSection(
    id: j['id'] as String,
    titleVi: j['titleVi'] as String,
    introVi: j['introVi'] as String,
    items: _list(j['items'], NoteItem.fromJson),
  );
}

/// Một câu trong đề test. Chữ trong 【】 là phần được hỏi (không furigana).
class TestQuestion {
  final String id;
  final String type;
  final String section;
  final String prompt;
  final List<String> options;
  final int answer;
  final String explanationVi;
  final String? passageId;

  const TestQuestion({
    required this.id,
    required this.type,
    required this.section,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.explanationVi,
    this.passageId,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> j) => TestQuestion(
    id: j['id'] as String,
    type: j['type'] as String,
    section: j['section'] as String,
    prompt: j['prompt'] as String,
    options: List<String>.from(j['options'] as List),
    answer: j['answer'] as int,
    explanationVi: j['explanationVi'] as String,
    passageId: j['passage'] as String?,
  );
}

/// Đề test N5: làm hết rồi nộp, sau đó mới xem đáp án và giải thích.
class N5Test {
  final String id;
  final String titleVi;
  final Map<String, String> passages;
  final List<TestQuestion> questions;

  const N5Test({
    required this.id,
    required this.titleVi,
    required this.passages,
    required this.questions,
  });

  factory N5Test.fromJson(Map<String, dynamic> j) => N5Test(
    id: j['id'] as String,
    titleVi: j['titleVi'] as String,
    passages: {
      for (final p in j['passages'] as List)
        (p as Map)['id'] as String: p['ja'] as String,
    },
    questions: _list(j['questions'], TestQuestion.fromJson),
  );
}

/// Một bài kiểm tra Các thể & Ngữ pháp N5 (assets/n5/checks.json).
class N5CheckSet {
  final String id;
  final String titleVi;
  final String subtitleVi;
  final List<N5CheckQuestion> questions;

  const N5CheckSet({
    required this.id,
    required this.titleVi,
    required this.subtitleVi,
    required this.questions,
  });

  factory N5CheckSet.fromJson(Map<String, dynamic> j) => N5CheckSet(
    id: j['id'] as String,
    titleVi: j['titleVi'] as String,
    subtitleVi: j['subtitleVi'] as String? ?? '',
    questions: _list(j['questions'], N5CheckQuestion.fromJson),
  );
}

/// Một câu kiểm tra: đáp án đúng kèm câu hoàn chỉnh, nghĩa, phân tích,
/// lý do từng đáp án sai và mẹo nhớ.
class N5CheckQuestion {
  final String id;

  /// Tên thể hoặc mẫu ngữ pháp câu này kiểm tra.
  final List<String> coversVi;
  final String prompt;
  final List<String> options;
  final int answer;
  final String fullJa;
  final String meaningVi;
  final String explainVi;

  /// Lý do sai của từng đáp án (rỗng ở đáp án đúng).
  final List<String> wrongVi;
  final String tipVi;

  const N5CheckQuestion({
    required this.id,
    required this.coversVi,
    required this.prompt,
    required this.options,
    required this.answer,
    required this.fullJa,
    required this.meaningVi,
    required this.explainVi,
    required this.wrongVi,
    required this.tipVi,
  });

  factory N5CheckQuestion.fromJson(Map<String, dynamic> j) => N5CheckQuestion(
    id: j['id'] as String,
    coversVi: [for (final c in j['coversVi'] as List? ?? const []) c as String],
    prompt: j['prompt'] as String,
    options: [for (final o in j['options'] as List) o as String],
    answer: j['answer'] as int,
    fullJa: j['fullJa'] as String,
    meaningVi: j['meaningVi'] as String,
    explainVi: j['explainVi'] as String,
    wrongVi: [for (final w in j['wrongVi'] as List) w as String],
    tipVi: j['tipVi'] as String? ?? '',
  );
}

/// Một chữ Hán N5 để học: cách đọc, cách nhớ, bộ thủ, số nét, từ ví dụ.
class N5Kanji {
  final String id;
  final String char;
  final String hanViet;
  final String meaningVi;
  final String on;
  final String kun;

  /// Cách đọc hay gặp nhất, dùng để hiện và phát âm.
  final String reading;
  final int strokes;
  final String radical;

  /// Tên bộ theo kiểu bảng bộ thủ: "Miên (mái nhà)".
  final String radicalName;

  /// Tên bộ tiếng Nhật: "うかんむり".
  final String radicalJa;
  final String mnemonicVi;
  final Sentence example;

  const N5Kanji({
    required this.id,
    required this.char,
    required this.hanViet,
    required this.meaningVi,
    required this.on,
    required this.kun,
    required this.reading,
    required this.strokes,
    required this.radical,
    required this.radicalName,
    this.radicalJa = '',
    required this.mnemonicVi,
    required this.example,
  });

  factory N5Kanji.fromJson(Map<String, dynamic> j) => N5Kanji(
    id: j['id'] as String,
    char: j['char'] as String,
    hanViet: j['hanViet'] as String,
    meaningVi: j['meaningVi'] as String,
    on: j['on'] as String,
    kun: j['kun'] as String,
    reading: j['reading'] as String,
    strokes: j['strokes'] as int,
    radical: j['radical'] as String,
    radicalName: j['radicalName'] as String,
    radicalJa: j['radicalJa'] as String? ?? '',
    mnemonicVi: j['mnemonicVi'] as String,
    example: Sentence.fromJson(j['example'] as Map<String, dynamic>),
  );
}

/// Toàn bộ phần Tổng hợp N5.
class N5Data {
  final FormsData forms;
  final List<N5GrammarLesson> grammar;
  final List<N5Topic> topics;
  final List<NoteSection> notes;
  final List<N5Test> tests;
  final List<N5Kanji> kanji;
  final List<N5CheckSet> checks;

  const N5Data({
    required this.forms,
    required this.grammar,
    required this.topics,
    this.notes = const [],
    this.tests = const [],
    this.kanji = const [],
    this.checks = const [],
  });

  int get grammarCount => grammar.fold(0, (n, l) => n + l.points.length);

  int get wordCount => topics.fold(0, (n, t) => n + t.words.length);
}

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) =>
    (raw as List? ?? const [])
        .map((e) => parse(e as Map<String, dynamic>))
        .toList();
