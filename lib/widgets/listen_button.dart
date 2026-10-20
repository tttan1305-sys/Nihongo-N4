import 'package:flutter/material.dart';

import '../services/speaker.dart';

/// Nút loa: bấm để nghe từ hoặc câu.
class ListenButton extends StatelessWidget {
  final Speaker speaker;
  final int lesson;
  final String audioId;
  final String text;

  const ListenButton({super.key, required this.speaker, required this.lesson, required this.audioId, required this.text});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: ValueKey('listen-$audioId'),
      tooltip: 'Nghe',
      icon: const Icon(Icons.volume_up),
      onPressed: () => speaker.speak(lesson: lesson, audioId: audioId, text: text),
    );
  }
}
