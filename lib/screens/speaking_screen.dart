import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/japanese_text.dart';
import '../services/recognizer.dart';
import '../services/speaker.dart';
import '../widgets/listen_button.dart';
import '../widgets/ruby_text.dart';

/// Luyện nói: nghe câu mẫu, đọc theo (shadowing), máy nhận dạng và chấm điểm.
class SpeakingScreen extends StatefulWidget {
  /// Điểm giống câu mẫu từ mức này trở lên thì tính là đạt.
  static const goodScore = 0.8;

  final int lesson;
  final List<Sentence> sentences;
  final Speaker speaker;
  final Recognizer recognizer;

  const SpeakingScreen({
    super.key,
    required this.lesson,
    required this.sentences,
    required this.speaker,
    required this.recognizer,
  });

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  int _index = 0;
  bool _listening = false;
  String? _heard;
  double? _score;
  bool _failed = false;

  Sentence get _current => widget.sentences[_index];

  Future<void> _record() async {
    await widget.speaker.stop();
    setState(() {
      _listening = true;
      _heard = null;
      _score = null;
      _failed = false;
    });
    final heard = await widget.recognizer.listenOnce();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _heard = heard;
      _failed = heard == null;
      if (heard != null) {
        _score = speakingScore(heard: heard, plain: plainText(_current.ja), reading: readingText(_current.ja));
      }
    });
  }

  void _go(int delta) => setState(() {
        _index += delta;
        _heard = null;
        _score = null;
        _failed = false;
      });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final s = _current;
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện nói')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Câu ${_index + 1}/${widget.sentences.length}', style: text.labelLarge),
          const SizedBox(height: 8),
          const Text('Nghe câu mẫu, sau đó bấm micro và đọc theo.'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: RubyText(s.ja, style: const TextStyle(fontSize: 22))),
              ListenButton(speaker: widget.speaker, lesson: widget.lesson, audioId: s.id, text: plainText(s.ja)),
            ],
          ),
          Text(s.vi, style: text.bodySmall),
          const SizedBox(height: 32),
          Center(
            child: IconButton.filled(
              key: const ValueKey('record'),
              iconSize: 56,
              icon: Icon(_listening ? Icons.hearing : Icons.mic),
              onPressed: _listening ? null : _record,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(_listening ? 'Đang nghe…' : 'Bấm để nói')),
          const SizedBox(height: 16),
          if (_failed)
            Text('Không nghe được. Hãy cho app quyền dùng micro, nói to và rõ hơn rồi thử lại.',
                style: TextStyle(color: colors.error)),
          if (_heard != null && _score != null) ...[
            Text('Máy nghe được:', style: text.labelMedium),
            Text(_heard!, key: const ValueKey('heard'), style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              _score! >= SpeakingScreen.goodScore
                  ? 'Tốt lắm! Giống câu mẫu ${(_score! * 100).round()}%'
                  : 'Giống câu mẫu ${(_score! * 100).round()}%. Nghe lại và thử thêm lần nữa nhé.',
              key: const ValueKey('speaking-result'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _score! >= SpeakingScreen.goodScore ? colors.primary : colors.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (_index > 0) OutlinedButton(onPressed: () => _go(-1), child: const Text('Câu trước')),
              const Spacer(),
              if (_index + 1 < widget.sentences.length)
                FilledButton(key: const ValueKey('next-sentence'), onPressed: () => _go(1), child: const Text('Câu tiếp'))
              else
                FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Xong')),
            ],
          ),
        ],
      ),
    );
  }
}
