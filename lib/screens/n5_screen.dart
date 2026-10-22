import 'package:flutter/material.dart';

import '../data/n5_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../models/n5.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/example_analysis.dart';
import '../widgets/listen_button.dart';
import '../widgets/ruby_text.dart';
import 'n5_test_screen.dart';
import 'quiz_screen.dart';

/// Tổng hợp N5 (Minna bài 1–25): kiến thức cần nhớ, các thể, ngữ pháp,
/// từ vựng, đề test. Mở tự do, không khóa theo thứ tự như lộ trình N4.
class N5Screen extends StatelessWidget {
  final N5Repository repository;
  final ProgressStore progress;
  final Speaker speaker;

  const N5Screen({
    super.key,
    required this.repository,
    required this.progress,
    required this.speaker,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tổng hợp N5'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(key: ValueKey('n5-tab-notes'), text: 'Cần nhớ'),
              Tab(key: ValueKey('n5-tab-forms'), text: 'Các thể'),
              Tab(key: ValueKey('n5-tab-grammar'), text: 'Ngữ pháp'),
              Tab(key: ValueKey('n5-tab-vocab'), text: 'Từ vựng'),
              Tab(key: ValueKey('n5-tab-tests'), text: 'Đề test'),
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
                _NotesTab(sections: data.notes, speaker: speaker),
                _FormsTab(data: data.forms, speaker: speaker),
                _GrammarTab(lessons: data.grammar, speaker: speaker),
                _VocabTab(topics: data.topics, speaker: speaker),
                _TestsTab(tests: data.tests, progress: progress),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RubyText(sentence.ja, style: const TextStyle(fontSize: 17)),
                  Text(
                    sentence.vi,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
        ),
        if (sentence.analysis != null)
          ExampleAnalysis(analysis: sentence.analysis!, id: sentence.id),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
        children: [
          const _VocabRow(
            cells: ['Từ', 'Hán Việt', 'Cách đọc', 'Nghĩa'],
            header: true,
          ),
          for (final w in topic.words)
            _VocabRow(
              key: ValueKey('n5-word-${w.id}'),
              cells: [w.word, w.hanViet, w.kana, w.meaningVi],
              trailing: ListenButton(
                speaker: speaker,
                lesson: n5AudioLesson,
                audioId: w.id,
                text: w.kana,
              ),
              example: _Example(w.example, speaker),
            ),
        ],
      ),
    );
  }
}

/// Một dòng bảng từ vựng theo kiểu sổ tay từ vựng N5:
/// Từ | Hán Việt | Cách đọc | Nghĩa. Bấm vào dòng để xem câu ví dụ.
class _VocabRow extends StatefulWidget {
  final List<String> cells;
  final bool header;
  final Widget? trailing;
  final Widget? example;

  const _VocabRow({
    super.key,
    required this.cells,
    this.header = false,
    this.trailing,
    this.example,
  });

  @override
  State<_VocabRow> createState() => _VocabRowState();
}

class _VocabRowState extends State<_VocabRow> {
  bool _open = false;

  static const _flex = [5, 5, 5, 6];

  @override
  Widget build(BuildContext context) {
    final header = widget.header;
    final style = TextStyle(
      fontSize: header ? 13 : 15,
      fontWeight: header ? FontWeight.w700 : FontWeight.w400,
      color: header ? Colors.white : AppColors.text,
    );
    final row = Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            flex: _flex[i],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: i == 0 && !header
                  ? RubyText(
                      widget.cells[i],
                      showRuby: false,
                      style: style.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(widget.cells[i], style: style),
            ),
          ),
        SizedBox(width: 44, child: widget.trailing),
      ],
    );
    return Container(
      decoration: BoxDecoration(
        color: header
            ? AppColors.primaryDark
            : _open
            ? AppColors.surfaceHigh
            : AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.border)),
        borderRadius: header
            ? const BorderRadius.vertical(top: Radius.circular(12))
            : null,
      ),
      padding: EdgeInsets.symmetric(vertical: header ? 10 : 6),
      child: header || widget.example == null
          ? row
          : InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  row,
                  if (_open)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 6, 0, 2),
                      child: widget.example,
                    ),
                ],
              ),
            ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  final List<NoteSection> sections;
  final Speaker speaker;

  const _NotesTab({required this.sections, required this.speaker});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        for (final s in sections)
          ExpansionTile(
            key: ValueKey('n5-note-${s.id}'),
            tilePadding: EdgeInsets.zero,
            title: Text(s.titleVi, style: text.titleMedium),
            subtitle: RubyText(s.introVi),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            children: [
              for (final item in s.items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RubyText(
                        item.head,
                        style: text.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      RubyText(item.bodyVi),
                      const SizedBox(height: 4),
                      _Example(item.example, speaker),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _TestsTab extends StatelessWidget {
  final List<N5Test> tests;
  final ProgressStore progress;

  const _TestsTab({required this.tests, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Mỗi đề 20 câu theo dạng đề JLPT N5: chữ Hán, từ vựng, ngữ pháp, '
            'đọc hiểu. Làm hết rồi nộp bài để xem đáp án và giải thích từng câu.',
          ),
          const SizedBox(height: 8),
          for (final t in tests)
            Card(
              child: ListTile(
                key: ValueKey('n5-test-${t.id}'),
                leading: const Icon(Icons.assignment, size: 32),
                title: Text(t.titleVi),
                subtitle: Text(switch (progress.n5TestScore(t.id)) {
                  null => '${t.questions.length} câu · chưa làm',
                  final best =>
                    '${t.questions.length} câu · điểm cao nhất '
                        '${(best * t.questions.length).round()}/${t.questions.length}',
                }),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => N5TestScreen(test: t, progress: progress),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
