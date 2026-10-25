import 'package:flutter/material.dart';

import '../data/flashcard_store.dart';
import '../data/lesson_repository.dart';
import '../data/progress_store.dart';
import '../models/lesson.dart';
import '../services/speaker.dart';
import '../srs/sm2.dart';
import '../widgets/listen_button.dart';
import '../widgets/content_scale.dart';
import '../theme.dart';
import '../widgets/ruby_text.dart';
import '../widgets/skin_widgets.dart';
import '../widgets/ui.dart';

/// Ôn các thẻ đến hạn hôm nay. Thẻ bấm "Quên" quay lại cuối hàng trong cùng lượt ôn.
class FlashcardScreen extends StatefulWidget {
  final LessonRepository repository;
  final FlashcardStore flashcards;
  final ProgressStore progress;
  final Speaker speaker;

  const FlashcardScreen({
    super.key,
    required this.repository,
    required this.flashcards,
    required this.progress,
    required this.speaker,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final List<CardId> _queue = widget.flashcards.dueCards();
  late final Future<Map<String, Vocab>> _vocab = _loadVocab();
  bool _revealed = false;
  int _reviewed = 0;

  Future<Map<String, Vocab>> _loadVocab() async {
    final result = <String, Vocab>{};
    for (final number in {for (final id in _queue) id.lesson}) {
      final lesson = await widget.repository.load(number);
      for (final v in lesson.vocab) {
        result[CardId(number, v.id).toString()] = v;
      }
    }
    return result;
  }

  Future<void> _rate(Rating rating) async {
    final id = _queue.removeAt(0);
    await widget.flashcards.rate(id, rating);
    setState(() {
      if (rating == Rating.again) _queue.add(id);
      _reviewed++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ôn flashcard')),
      body: SkinBackground(
        child: ContentScale(
          child: FutureBuilder<Map<String, Vocab>>(
            future: _vocab,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Bỏ qua thẻ của từ không còn trong bài (nội dung bài đã sửa).
              _queue.removeWhere(
                (id) => !snapshot.data!.containsKey(id.toString()),
              );
              if (_queue.isEmpty) return _done(context);
              final id = _queue.first;
              final v = snapshot.data![id.toString()]!;
              return SkinPalette.current.skin == AppSkin.neon
                  ? _card(context, id, v)
                  : _skinCard(context, id, v);
            },
          ),
        ),
      ),
    );
  }

  Widget _done(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Hôm nay bạn đã ôn xong!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Đã ôn $_reviewed lượt thẻ.'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context, CardId id, Vocab v) {
    final text = Theme.of(context).textTheme;
    final state = widget.flashcards.stateOf(id)!;
    final now = widget.flashcards.now;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Còn ${_queue.length} thẻ · Bài ${id.lesson}',
          style: text.labelLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                RubyText(
                  v.word,
                  showRuby: widget.progress.showFurigana,
                  style: const TextStyle(fontSize: 36),
                ),
                ListenButton(
                  speaker: widget.speaker,
                  lesson: id.lesson,
                  audioId: v.id,
                  text: v.kana,
                ),
                if (_revealed) ...[
                  const Divider(),
                  Text(
                    v.kana,
                    key: const ValueKey('answer-kana'),
                    style: text.titleMedium,
                  ),
                  Text(
                    v.meaningVi,
                    style: text.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  RubyText(
                    v.practical.ja,
                    style: const TextStyle(fontSize: 17),
                  ),
                  Text(
                    v.practical.vi,
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!_revealed)
          FilledButton(
            key: const ValueKey('reveal'),
            onPressed: () => setState(() => _revealed = true),
            child: const Text('Hiện đáp án'),
          )
        else
          Row(
            children: [
              for (final (rating, label) in [
                (Rating.again, 'Quên'),
                (Rating.hard, 'Khó'),
                (Rating.good, 'Được'),
                (Rating.easy, 'Dễ'),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: OutlinedButton(
                      key: ValueKey('rate-${rating.name}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _rate(rating),
                      child: Column(
                        children: [
                          Text(label),
                          Text(
                            nextIntervalLabel(state, rating, now),
                            style: text.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// Thẻ theo phong cách Mechanical / Anime: chữ trong ô 田 hoặc vòng tia
  /// tốc độ, đáp án hiện sau khi lật, 4 nút đánh giá SM-2.
  Widget _skinCard(BuildContext context, CardId id, Vocab v) {
    final p = SkinPalette.current;
    final mech = p.skin == AppSkin.mechanical;
    final state = widget.flashcards.stateOf(id)!;
    final now = widget.flashcards.now;
    final length = plainText(v.word).characters.length;
    final wordSize = switch (length) {
      1 => 96.0,
      2 => 64.0,
      3 => 46.0,
      _ => 34.0,
    };
    final total = _reviewed + _queue.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Text(
          mech
              ? 'THẺ ÔN // BÀI ${id.lesson} · CÒN ${_queue.length}'
              : 'Bài ${id.lesson} · còn ${_queue.length} thẻ',
          style: skinLabelStyle(),
        ),
        const SizedBox(height: 8),
        mech
            ? SegmentedProgress(
                value: total == 0 ? 0 : _reviewed / total,
                segments: 30,
                height: 8,
              )
            : StripedProgress(value: total == 0 ? 0 : _reviewed / total),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: mech
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MẪU VẬT #${v.id.toUpperCase()}',
                                style: skinLabelStyle(color: p.primaryText),
                              ),
                              Text(
                                'BÀI ${id.lesson} · ${v.pos.toUpperCase()}',
                                style: skinLabelStyle(),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Transform.rotate(
                              angle: -0.1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: p.orangeSoft,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: p.border, width: 2),
                                ),
                                child: Text(
                                  '「おぼえてる？」',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: p.text,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  ListenButton(
                    speaker: widget.speaker,
                    lesson: id.lesson,
                    audioId: v.id,
                    text: v.kana,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: KanjiFrame(
                  size: 210,
                  child: RubyText(
                    v.word,
                    showRuby: widget.progress.showFurigana,
                    style: TextStyle(
                      fontSize: wordSize,
                      fontWeight: FontWeight.w900,
                      color: p.text,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_revealed) ..._answer(v, mech) else _locked(mech),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!_revealed)
          FilledButton(
            key: const ValueKey('reveal'),
            onPressed: () => setState(() => _revealed = true),
            child: Text(mech ? 'LẬT THẺ ▸' : 'Lật thẻ nào!'),
          )
        else
          Row(
            children: [
              for (final (rating, label, color, soft) in [
                (Rating.again, mech ? 'LẠI' : 'Quên', p.red, p.redSoft),
                (Rating.hard, mech ? 'KHÓ' : 'Khó', p.text, p.orangeSoft),
                (Rating.good, mech ? 'ỔN' : 'Ổn', p.onPrimary, p.primary),
                (Rating.easy, mech ? 'DỄ' : 'Dễ', p.green, p.greenSoft),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _rateButton(
                      rating,
                      label,
                      nextIntervalLabel(state, rating, now),
                      color,
                      mech ? (rating == Rating.good ? soft : p.surface) : soft,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  List<Widget> _answer(Vocab v, bool mech) {
    final p = SkinPalette.current;
    Widget chip(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: mech ? null : p.surfaceHigh,
          borderRadius: BorderRadius.circular(mech ? 3 : 14),
          border: Border.all(color: p.border, width: mech ? 1 : 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: skinLabelStyle(size: 10)),
            Text(
              value.isEmpty ? '—' : value,
              key: label == (mech ? 'CÁCH ĐỌC' : 'Cách đọc')
                  ? const ValueKey('answer-kana')
                  : null,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
    return [
      Row(
        children: [
          chip(mech ? 'CÁCH ĐỌC' : 'Cách đọc', v.kana),
          const SizedBox(width: 8),
          chip(mech ? 'HÁN VIỆT' : 'Hán Việt', v.hanViet),
        ],
      ),
      const SizedBox(height: 8),
      mech
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: p.primary,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Text(
                    'NGHĨA',
                    style: skinLabelStyle(color: p.onPrimary, size: 10),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      v.meaningVi.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: p.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Text(
              v.meaningVi,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: p.primaryText,
              ),
            ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RubyText(v.practical.ja, style: const TextStyle(fontSize: 17)),
            Text(
              v.practical.vi,
              style: TextStyle(color: p.muted, fontSize: 13),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _locked(bool mech) {
    final p = SkinPalette.current;
    return Container(
      height: 120,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surfaceHigh,
        borderRadius: BorderRadius.circular(mech ? 3 : 16),
        border: Border.all(color: p.border, width: mech ? 1 : 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mech ? 'DỮ LIỆU ĐANG KHÓA' : '? ? ?',
            style: mech
                ? skinLabelStyle(color: p.primaryText, size: 12)
                : TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: p.primaryText,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            mech
                ? 'Nhớ lại cách đọc và nghĩa trước, rồi lật thẻ để kiểm tra.'
                : 'Cậu còn nhớ chữ này không nè?',
            textAlign: TextAlign.center,
            style: TextStyle(color: p.muted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _rateButton(
    Rating rating,
    String label,
    String interval,
    Color color,
    Color background,
  ) {
    final p = SkinPalette.current;
    final mech = p.skin == AppSkin.mechanical;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mech ? 4 : 18),
        boxShadow: mech || rating != Rating.good
            ? null
            : [BoxShadow(color: p.shadow, offset: const Offset(3, 3))],
      ),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mech ? 4 : 18),
          side: BorderSide(color: p.border, width: mech ? 1 : 2),
        ),
        child: InkWell(
          key: ValueKey('rate-${rating.name}'),
          onTap: () => _rate(rating),
          child: SizedBox(
            height: 62,
            child: NormalTextScale(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    interval,
                    style: skinLabelStyle(
                      size: 9.5,
                      color: rating == Rating.good ? color : p.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
