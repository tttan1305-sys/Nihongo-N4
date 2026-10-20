/// Chuẩn hóa câu tiếng Nhật để so sánh: bỏ dấu câu, khoảng trắng, đổi katakana thành hiragana.
String normalizeJa(String s) {
  final out = StringBuffer();
  for (final r in s.runes) {
    if (_ignored.contains(r) || r == 0x20 || r == 0x3000 || r == 0x0A) continue;
    // Katakana ァ..ヶ → hiragana ぁ..ゖ
    out.writeCharCode(r >= 0x30A1 && r <= 0x30F6 ? r - 0x60 : r);
  }
  return out.toString().toLowerCase();
}

final _ignored = '。、，．,.!?！？「」『』（）()・…〜~：:；;"\'”“'.runes.toSet();

/// Mức giống nhau (0..1) giữa hai chuỗi, dựa trên khoảng cách Levenshtein theo ký tự.
double similarity(String a, String b) {
  final x = a.runes.toList(), y = b.runes.toList();
  if (x.isEmpty && y.isEmpty) return 1;
  var prev = List<int>.generate(y.length + 1, (j) => j);
  for (var i = 1; i <= x.length; i++) {
    final cur = List<int>.filled(y.length + 1, 0)..[0] = i;
    for (var j = 1; j <= y.length; j++) {
      final cost = x[i - 1] == y[j - 1] ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((a, b) => a < b ? a : b);
    }
    prev = cur;
  }
  final longest = x.length > y.length ? x.length : y.length;
  return 1 - prev[y.length] / longest;
}

/// Chấm câu nói: so với câu gốc (chữ Hán) và cách đọc (kana), lấy kết quả cao hơn.
double speakingScore({required String heard, required String plain, required String reading}) {
  final h = normalizeJa(heard);
  final a = similarity(h, normalizeJa(plain));
  final b = similarity(h, normalizeJa(reading));
  return a > b ? a : b;
}
