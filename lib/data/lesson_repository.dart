import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson.dart';

/// Bài đầu và bài cuối của lộ trình N4 (Minna no Nihongo Sơ cấp II).
const firstLesson = 26;
const lastLesson = 50;

/// Đọc bài học đóng gói trong assets/lessons/.
class LessonRepository {
  final AssetBundle bundle;
  final _cache = <int, Lesson>{};

  LessonRepository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;

  static String pathFor(int number) => 'assets/lessons/$number.json';

  /// Số các bài đã soạn xong nội dung.
  Future<Set<int>> availableLessons() async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final pattern = RegExp(r'^assets/lessons/(\d+)\.json$');
    return {
      for (final path in manifest.listAssets())
        if (pattern.firstMatch(path) case final m?) int.parse(m.group(1)!),
    };
  }

  Future<Lesson> load(int number) async {
    final cached = _cache[number];
    if (cached != null) return cached;
    final raw = await bundle.loadString(pathFor(number));
    return _cache[number] = Lesson.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}
