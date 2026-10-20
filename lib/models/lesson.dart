// Mô hình dữ liệu bài học, đọc từ assets/lessons/<số bài>.json.
// Chuỗi tiếng Nhật dùng cú pháp furigana {漢字|かんじ}, hiển thị bằng RubyText.

class Sentence {
  final String id;
  final String ja;
  final String vi;

  const Sentence({required this.id, required this.ja, required this.vi});

  factory Sentence.fromJson(Map<String, dynamic> j) => Sentence(
    id: j['id'] as String,
    ja: j['ja'] as String,
    vi: j['vi'] as String? ?? '',
  );
}

class Question {
  final String prompt;
  final List<String> options;
  final int answer;
  final String? explanationVi;

  /// Id câu cần phát âm thanh (dùng cho bài luyện nghe).
  final String? audioId;

  const Question({
    required this.prompt,
    required this.options,
    required this.answer,
    this.explanationVi,
    this.audioId,
  });

  factory Question.fromJson(Map<String, dynamic> j) => Question(
    prompt: j['prompt'] as String? ?? '',
    options: List<String>.from(j['options'] as List),
    answer: j['answer'] as int,
    explanationVi: j['explanationVi'] as String?,
    audioId: j['audioId'] as String?,
  );
}

class GrammarPoint {
  final String id;
  final String pattern;
  final String meaningVi;
  final String explanationVi;
  final String usageNoteVi;
  final List<Sentence> examples;
  final List<Question> quiz;

  const GrammarPoint({
    required this.id,
    required this.pattern,
    required this.meaningVi,
    required this.explanationVi,
    required this.usageNoteVi,
    required this.examples,
    required this.quiz,
  });

  factory GrammarPoint.fromJson(Map<String, dynamic> j) => GrammarPoint(
    id: j['id'] as String,
    pattern: j['pattern'] as String,
    meaningVi: j['meaningVi'] as String,
    explanationVi: j['explanationVi'] as String,
    usageNoteVi: j['usageNoteVi'] as String,
    examples: _list(j['examples'], Sentence.fromJson),
    quiz: _list(j['quiz'], Question.fromJson),
  );
}

class PracticalUse extends Sentence {
  final String situationVi;

  const PracticalUse({
    required super.id,
    required super.ja,
    required super.vi,
    required this.situationVi,
  });

  factory PracticalUse.fromJson(Map<String, dynamic> j) => PracticalUse(
    id: j['id'] as String,
    ja: j['ja'] as String,
    vi: j['vi'] as String,
    situationVi: j['situationVi'] as String,
  );
}

class Vocab {
  final String id;
  final String word;
  final String kana;
  final String meaningVi;
  final String pos;
  final PracticalUse practical;

  const Vocab({
    required this.id,
    required this.word,
    required this.kana,
    required this.meaningVi,
    required this.pos,
    required this.practical,
  });

  factory Vocab.fromJson(Map<String, dynamic> j) => Vocab(
    id: j['id'] as String,
    word: j['word'] as String,
    kana: j['kana'] as String,
    meaningVi: j['meaningVi'] as String,
    pos: j['pos'] as String,
    practical: PracticalUse.fromJson(j['practical'] as Map<String, dynamic>),
  );
}

class KanjiItem {
  final String char;
  final String readings;
  final String meaningVi;

  const KanjiItem({
    required this.char,
    required this.readings,
    required this.meaningVi,
  });

  factory KanjiItem.fromJson(Map<String, dynamic> j) => KanjiItem(
    char: j['char'] as String,
    readings: j['readings'] as String,
    meaningVi: j['meaningVi'] as String,
  );
}

class TypingItem {
  final String ja;
  final String answer;
  final String vi;

  const TypingItem({required this.ja, required this.answer, required this.vi});

  factory TypingItem.fromJson(Map<String, dynamic> j) => TypingItem(
    ja: j['ja'] as String,
    answer: j['answer'] as String,
    vi: j['vi'] as String,
  );
}

class Reading {
  final String id;
  final String titleJa;
  final List<String> paragraphs;
  final List<Question> questions;

  const Reading({
    required this.id,
    required this.titleJa,
    required this.paragraphs,
    required this.questions,
  });

  factory Reading.fromJson(Map<String, dynamic> j) => Reading(
    id: j['id'] as String,
    titleJa: j['titleJa'] as String,
    paragraphs: List<String>.from(j['paragraphs'] as List),
    questions: _list(j['questions'], Question.fromJson),
  );
}

class Lesson {
  final String id;
  final int number;
  final String titleJa;
  final String titleVi;
  final List<GrammarPoint> grammar;
  final List<Vocab> vocab;
  final List<Question> listening;
  final List<String> speakingIds;
  final List<KanjiItem> kanji;
  final List<TypingItem> typing;
  final Reading reading;

  const Lesson({
    required this.id,
    required this.number,
    required this.titleJa,
    required this.titleVi,
    required this.grammar,
    required this.vocab,
    required this.listening,
    required this.speakingIds,
    required this.kanji,
    required this.typing,
    required this.reading,
  });

  factory Lesson.fromJson(Map<String, dynamic> j) {
    final writing = j['writing'] as Map<String, dynamic>? ?? const {};
    return Lesson(
      id: j['id'] as String,
      number: j['number'] as int,
      titleJa: j['titleJa'] as String,
      titleVi: j['titleVi'] as String,
      grammar: _list(j['grammar'], GrammarPoint.fromJson),
      vocab: _list(j['vocab'], Vocab.fromJson),
      listening: _list(j['listening'], Question.fromJson),
      speakingIds: List<String>.from(j['speaking'] as List? ?? const []),
      kanji: _list(writing['kanji'], KanjiItem.fromJson),
      typing: _list(writing['typing'], TypingItem.fromJson),
      reading: Reading.fromJson(j['reading'] as Map<String, dynamic>),
    );
  }

  /// Mọi câu có id trong bài (ví dụ ngữ pháp, câu thực tế của từ vựng), để tra theo id.
  Map<String, Sentence> get sentencesById => {
    for (final g in grammar)
      for (final e in g.examples) e.id: e,
    for (final v in vocab) v.practical.id: v.practical,
  };
}

List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) parse) =>
    (raw as List? ?? const [])
        .map((e) => parse(e as Map<String, dynamic>))
        .toList();
