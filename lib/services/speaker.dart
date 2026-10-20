import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Phát âm một từ hoặc câu tiếng Nhật.
abstract class Speaker {
  /// [audioId] dùng để tìm file giọng tạo sẵn, [text] là chữ để máy đọc khi chưa có file.
  Future<void> speak({
    required int lesson,
    required String audioId,
    required String text,
  });

  Future<void> stop();
}

/// Ưu tiên file giọng nữ tạo sẵn trong assets/audio/; chưa có thì dùng giọng tiếng Nhật của máy.
class DeviceSpeaker implements Speaker {
  final AssetBundle bundle;
  final _player = AudioPlayer();
  final _tts = FlutterTts();
  Set<String>? _assets;
  bool _ttsReady = false;

  DeviceSpeaker({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  static String assetPath(int lesson, String audioId) =>
      'assets/audio/${lesson}_$audioId.mp3';

  @override
  Future<void> speak({
    required int lesson,
    required String audioId,
    required String text,
  }) async {
    await stop();
    _assets ??= (await AssetManifest.loadFromAssetBundle(bundle))
        .listAssets()
        .toSet();
    final path = assetPath(lesson, audioId);
    if (_assets!.contains(path)) {
      // AssetSource tự thêm tiền tố "assets/".
      await _player.play(AssetSource(path.substring('assets/'.length)));
      return;
    }
    await _prepareTts();
    await _tts.speak(text);
  }

  Future<void> _prepareTts() async {
    if (_ttsReady) return;
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.45);
    final voice = pickJapaneseFemaleVoice(
      (await _tts.getVoices) as List? ?? const [],
    );
    if (voice != null) await _tts.setVoice(voice);
    _ttsReady = true;
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await _tts.stop();
  }
}

/// Chọn giọng nữ tiếng Nhật trong danh sách giọng của máy, null nếu không tìm thấy.
/// Giọng Google trên Android không ghi giới tính trong tên; "jab" và "htm" là giọng nữ.
/// Trên trình duyệt: Nanami (Edge/Windows), Kyoko (Safari/Mac), "Google 日本語" (Chrome) đều là giọng nữ.
Map<String, String>? pickJapaneseFemaleVoice(List<dynamic> voices) {
  final japanese = [
    for (final v in voices)
      if (v is Map &&
          '${v['locale']}'.toLowerCase().replaceAll('_', '-').startsWith('ja'))
        {'name': '${v['name']}', 'locale': '${v['locale']}'},
  ];
  if (japanese.isEmpty) return null;
  for (final hint in _femaleHints) {
    for (final v in japanese) {
      if (v['name']!.toLowerCase().contains(hint)) return v;
    }
  }
  return japanese.first;
}

const _femaleHints = [
  'female',
  'jab',
  'htm',
  'nanami',
  'kyoko',
  'haruka',
  'ayumi',
  'google',
];
