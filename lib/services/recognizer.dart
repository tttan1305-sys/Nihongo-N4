import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// Nhận dạng một câu nói tiếng Nhật.
abstract class Recognizer {
  /// Trả về chữ nghe được, null nếu máy không hỗ trợ hoặc không nghe được gì.
  Future<String?> listenOnce();

  Future<void> stop();
}

/// Dùng bộ nhận dạng giọng nói của điện thoại (cần quyền micro).
class DeviceRecognizer implements Recognizer {
  final _speech = SpeechToText();
  bool? _available;

  @override
  Future<String?> listenOnce() async {
    _available ??= await _speech.initialize();
    if (_available != true) return null;
    final done = Completer<String?>();
    var last = '';
    _speech.statusListener = (status) {
      if ((status == 'done' || status == 'notListening') && !done.isCompleted) {
        done.complete(last.isEmpty ? null : last);
      }
    };
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'ja-JP',
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      ),
      onResult: (r) {
        last = r.recognizedWords;
        if (r.finalResult && !done.isCompleted) done.complete(last);
      },
    );
    return done.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => last.isEmpty ? null : last,
    );
  }

  @override
  Future<void> stop() => _speech.stop();
}
