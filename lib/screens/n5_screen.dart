import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../widgets/listen_button.dart';
import '../widgets/ruby_text.dart';
import 'quiz_screen.dart';

/// Tổng hợp N5 (Minna bài 1–25): các thể, ngữ pháp, từ vựng. Mở tự do,
/// không khóa theo thứ tự như lộ trình N4.
class N5Screen extends StatelessWidget {
  final N5Repository repository;
  final Speaker speaker;

  const N5Screen({super.key, required this.repository, required this.speaker});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tổng hợp N5'),
          bottom: const TabBar(
            tabs: [
              Tab(key: ValueKey('n5-tab-forms'), text: 'Các thể'),
              Tab(key: ValueKey('n5-tab-grammar'), text: 'Ngữ pháp'),
              Tab(key: ValueKey('n5-tab-vocab'), text: 'Từ vựng'),
            ],
          ),
        ),
        body: FutureBuilder<N5Data>(
          future: repository.load(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Lỗi đọc dữ liệu: ${snapshot.error}'));
            }
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _FormsTab(data: data.forms, speaker: speaker),
                _GrammarTab(lessons: data.grammar, speaker: speaker),
                _VocabTab(topics: data.topics, speaker: speaker),
              ],
            );
          },
        ),
      ),
    );
  }
}

void _openQuiz(BuildContext context, String title, List<Question> questions) {
  Navigator.of(context).push(
    MaterialPageRoute<double>(
      builder: (_) => QuizScreen(
        title: title,
        questions: questions,
        passMark: ProgressStore.passMark,
        passMessage: 'Giỏi lắm! Bạn đã nắm được phần này.',
      ),
    ),
  );
}

/// Câu ví dụ: tiếng Nhật có furigana, nghĩa, nút nghe.
class _Example extends StatelessWidget {
  final Sentence sentence;
  final Speaker speaker;

  const _Example(this.sentence, this.speaker);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RubyText(sentence.ja, style: const TextStyle(fontSize: 17)),
              Text(sentence.vi, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        ListenButton(
          speaker: speaker,
          lesson: n5AudioLesson,
          audioId: sentence.id,
          text: plainText(sentence.ja),
        ),
      ],
    );
  }
}

class _FormsTab extends StatelessWidget {
  final FormsData data;
  final Speaker speaker;

  const _FormsTab({required this.data, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          key: const ValueKey('n5-conjugation-quiz'),
          icon: const Icon(Icons.quiz),
          label: const Text('Luyện chia thể (10 câu)'),
          onPressed: () =>
              _openQuiz(context, 'Luyện chia thể', conjugationQuiz(data)),
        ),
        const SizedBox(height: 16),
        Text('3 nhóm động từ', style: text.titleMedium),
        for (final g in data.groups)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(g.name),
            subtitle: RubyText(g.descVi),
          ),
        const Divider(),
        for (final f in data.forms)
          ExpansionTile(
            key: ValueKey('n5-form-${f.id}'),
            tilePadding: EdgeInsets.zero,
            title: RubyText('${f.name}　${f.nameJa}'),
            subtitle: Text(f.lesson),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RubyText(f.usesVi),
              const SizedBox(height: 8),
              for (final r in f.rules)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RubyText('${r.group}: ${r.ruleVi}'),
                      RubyText(
                        r.example,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              _VerbTable(data: data, columns: ['dict', ...f.table]),
              const SizedBox(height: 8),
              for (final e in f.examples) _Example(e, speaker),
            ],
          ),
        ExpansionTile(
          key: const ValueKey('n5-form-plain'),
          tilePadding: EdgeInsets.zero,
          title: RubyText('${data.plain.name}　${data.plain.nameJa}'),
          subtitle: Text(data.plain.lesson),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RubyText(data.plain.usesVi),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                dataRowMaxHeight: 64,
                columns: [
                  const DataColumn(label: Text('')),
                  for (final c in data.plain.columns)
                    DataColumn(label: Text(c)),
                ],
                rows: [
                  for (final r in data.plain.rows)
                    DataRow(
                      cells: [
                        DataCell(Text(r.label)),
                        for (final c in r.cells) DataCell(RubyText(c)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final e in data.plain.examples) _Example(e, speaker),
          ],
        ),
        ExpansionTile(
          key: const ValueKey('n5-verb-table'),
          tilePadding: EdgeInsets.zero,
          title: const Text('Bảng chia đầy đủ 17 động từ mẫu'),
          children: [
            _VerbTable(data: data, columns: data.formLabels.keys.toList()),
          ],
        ),
      ],
    );
  }
}

/// Bảng chia động từ mẫu theo các cột [columns], cuộn ngang được.
class _VerbTable extends StatelessWidget {
  final FormsData data;
  final List<String> columns;

  const _VerbTable({required this.data, required this.columns});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        dataRowMaxHeight: 64,
        columns: [
          const DataColumn(label: Text('Nhóm')),
          for (final c in columns)
            DataColumn(label: Text(data.formLabels[c] ?? c)),
          const DataColumn(label: Text('Nghĩa')),
        ],
        rows: [
          for (final v in data.verbs)
            DataRow(
              cells: [
                DataCell(Text('${v.group}')),
                for (final c in columns) DataCell(RubyText(v.forms[c] ?? '')),
                DataCell(Text(v.meaningVi)),
              ],
            ),
        ],
      ),
    );
  }
}

class _GrammarTab extends StatelessWidget {
  final List<N5GrammarLesson> lessons;
  final Speaker speaker;

  const _GrammarTab({required this.lessons, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (final l in lessons)
          ExpansionTile(
            key: ValueKey('n5-grammar-${l.lesson}'),
            tilePadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('${l.lesson}')),
            title: Text(l.titleVi),
            subtitle: Text('${l.points.length} mẫu câu'),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            children: [
              for (final p in l.points)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RubyText(
                        p.pattern,
                        style: text.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(p.meaningVi, style: text.titleSmall),
                      RubyText(p.explanationVi),
                      const SizedBox(height: 4),
                      for (final e in p.examples) _Example(e, speaker),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                key: ValueKey('n5-grammar-quiz-${l.lesson}'),
                icon: const Icon(Icons.quiz),
                label: Text('Luyện ngữ pháp bài ${l.lesson}'),
                onPressed: () => _openQuiz(
                  context,
                  'Ngữ pháp bài ${l.lesson}',
                  grammarQuiz(l, lessons),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _VocabTab extends StatelessWidget {
  final List<N5Topic> topics;
  final Speaker speaker;

  const _VocabTab({required this.topics, required this.speaker});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: topics.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final t = topics[i];
        return ListTile(
          key: ValueKey('n5-topic-${t.id}'),
          title: Text(t.titleVi),
          subtitle: Text('${t.words.length} từ'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  _TopicScreen(topic: t, topics: topics, speaker: speaker),
            ),
          ),
        );
      },
    );
  }
}

class _TopicScreen extends StatelessWidget {
  final N5Topic topic;
  final List<N5Topic> topics;
  final Speaker speaker;

  const _TopicScreen({
    required this.topic,
    required this.topics,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(topic.titleVi)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('n5-vocab-quiz'),
        icon: const Icon(Icons.quiz),
        label: const Text('Luyện từ'),
        onPressed: () => _openQuiz(
          context,
          'Từ vựng: ${topic.titleVi}',
          vocabQuiz(topic, topics),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: topic.words.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final w = topic.words[i];
          return Column(
            key: ValueKey('n5-word-${w.id}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RubyText(w.word, style: const TextStyle(fontSize: 24)),
                        Text(w.meaningVi, style: text.titleSmall),
                      ],
                    ),
                  ),
                  ListenButton(
                    speaker: speaker,
                    lesson: n5AudioLesson,
                    audioId: w.id,
                    text: w.kana,
                  ),
                ],
              ),
              _Example(w.example, speaker),
            ],
          );
        },
      ),
    );
  }
}
