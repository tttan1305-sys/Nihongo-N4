import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/lesson.dart';
import '../models/n5.dart';

/// Số bài dùng cho giọng đọc phần N5 (file `assets/audio/5_<id>.mp3` nếu có).
const n5AudioLesson = 5;

/// Đọc phần Tổng hợp N5 trong assets/n5/.
class N5Repository {
  final AssetBundle bundle;
  N5Data? _cache;

  N5Repository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  Future<Map<String, dynamic>> _json(String name) async =>
      jsonDecode(await bundle.loadString('assets/n5/$name.json'))
          as Map<String, dynamic>;

  Future<N5Data> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final forms = FormsData.fromJson(await _json('forms'));
    final grammar = await _json('grammar');
    final vocab = await _json('vocab');
    return _cache = N5Data(
      forms: forms,
      grammar: [
        for (final l in grammar['lessons'] as List)
          N5GrammarLesson.fromJson(l as Map<String, dynamic>),
      ],
      topics: [
        for (final t in vocab['topics'] as List)
          N5Topic.fromJson(t as Map<String, dynamic>),
      ],
    );
  }
}

/// Tạo câu hỏi trắc nghiệm: đáp án đúng và tối đa 3 đáp án sai, xáo trộn.
Question _question(
  String prompt,
  String answer,
  Iterable<String> pool,
  Random rnd, {
  String? explanationVi,
}) {
  final wrong = pool.where((o) => o != answer).toSet().toList()..shuffle(rnd);
  final options = [answer, ...wrong.take(3)]..shuffle(rnd);
  return Question(
    prompt: prompt,
    options: options,
    answer: options.indexOf(answer),
    explanationVi: explanationVi,
  );
}

/// Luyện chia thể: hỏi thể X của một động từ, đáp án sai là các thể khác.
List<Question> conjugationQuiz(FormsData data, {int count = 10, Random? rnd}) {
  rnd ??= Random();
  final keys = data.formLabels.keys.where((k) => k != 'dict').toList();
  final verbs = [...data.verbs]..shuffle(rnd);
  return [
    for (final v in verbs.take(count))
      () {
        final key = keys[rnd!.nextInt(keys.length)];
        final meaning = v.meaningVi;
        return _question(
          'Thể「${data.formLabels[key]}」của ${v.dictionary} ($meaning) là?',
          v.forms[key]!,
          v.forms.entries.where((e) => e.key != 'dict').map((e) => e.value),
          rnd,
          explanationVi: 'Nhóm ${v.group}',
        );
      }(),
  ];
}

/// Luyện ngữ pháp một bài: hỏi nghĩa của từng mẫu câu.
List<Question> grammarQuiz(
  N5GrammarLesson lesson,
  List<N5GrammarLesson> all, {
  Random? rnd,
}) {
  rnd ??= Random();
  final pool = [
    for (final l in all)
      for (final p in l.points) p.meaningVi,
  ];
  return [
    for (final p in lesson.points)
      _question(
        '「${p.pattern}」nghĩa là gì?',
        p.meaningVi,
        pool,
        rnd,
        explanationVi: p.explanationVi,
      ),
  ]..shuffle(rnd);
}

/// Luyện từ vựng một chủ đề: hỏi nghĩa của từng từ.
List<Question> vocabQuiz(N5Topic topic, List<N5Topic> all, {Random? rnd}) {
  rnd ??= Random();
  // Đáp án sai lấy trong cùng chủ đề trước cho khó hơn, thiếu thì lấy chỗ khác.
  final pool = [
    for (final w in topic.words) w.meaningVi,
    for (final t in all)
      for (final w in t.words) w.meaningVi,
  ];
  return [
    for (final w in topic.words)
      _question(
        '「${w.word}」nghĩa là gì?',
        w.meaningVi,
        pool.take(topic.words.length + 20),
        rnd,
      ),
  ]..shuffle(rnd);
}
