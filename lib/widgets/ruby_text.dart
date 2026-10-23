import 'package:flutter/material.dart';

/// Một đoạn chữ: [base] là chữ hiển thị, [ruby] là furigana (null nếu không có).
class RubySegment {
  final String base;
  final String? ruby;

  const RubySegment(this.base, [this.ruby]);

  @override
  bool operator ==(Object other) =>
      other is RubySegment && other.base == base && other.ruby == ruby;

  @override
  int get hashCode => Object.hash(base, ruby);

  @override
  String toString() => ruby == null ? base : '{$base|$ruby}';
}

final _rubyPattern = RegExp(r'\{([^|{}]+)\|([^|{}]+)\}');

/// Tách chuỗi "{漢字|かんじ}を書く" thành các đoạn có/không furigana.
List<RubySegment> parseRuby(String text) {
  final segments = <RubySegment>[];
  var last = 0;
  for (final m in _rubyPattern.allMatches(text)) {
    if (m.start > last) {
      segments.add(RubySegment(text.substring(last, m.start)));
    }
    segments.add(RubySegment(m.group(1)!, m.group(2)));
    last = m.end;
  }
  if (last < text.length) segments.add(RubySegment(text.substring(last)));
  return segments;
}

/// Bỏ furigana, giữ chữ Hán: "{漢字|かんじ}" → "漢字". Dùng cho giọng đọc.
String plainText(String text) =>
    text.replaceAllMapped(_rubyPattern, (m) => m.group(1)!);

/// Đổi chữ Hán thành cách đọc: "{漢字|かんじ}" → "かんじ".
String readingText(String text) =>
    text.replaceAllMapped(_rubyPattern, (m) => m.group(2)!);

/// Hiển thị chuỗi có furigana: hiragana nhỏ nằm phía trên chữ Hán.
/// Khi [showRuby] là false (chế độ tự kiểm tra) thì chỉ hiện chữ Hán.
class RubyText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool showRuby;

  const RubyText(this.text, {super.key, this.style, this.showRuby = true});

  @override
  Widget build(BuildContext context) {
    final unscaled = DefaultTextStyle.of(context).style.merge(style);
    final segments = parseRuby(text);
    // Không có furigana thì khỏi chừa chỗ phía trên, vẽ như chữ thường.
    if (segments.every((s) => s.ruby == null)) {
      return Text(text, style: unscaled);
    }

    // Tự tính cỡ chữ đã phóng (cỡ chữ của máy, cỡ chữ bài học) để furigana
    // luôn bằng nửa chữ Hán và khoảng chừa phía trên khớp với furigana.
    final fontSize = MediaQuery.textScalerOf(context)
        .scale(unscaled.fontSize ?? 16);
    final base = unscaled.copyWith(fontSize: fontSize);
    final rubyStyle = base.copyWith(fontSize: fontSize * 0.5, height: 1.1);
    final rubyHeight = fontSize * 0.5 * 1.1;
    const fixed = TextScaler.noScaling;

    final spans = <InlineSpan>[];
    for (final seg in segments) {
      if (seg.ruby == null || !showRuby) {
        // Chừa chỗ phía trên để các dòng không có furigana vẫn thẳng hàng.
        for (final ch in _wrapUnits(seg.base)) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.bottom,
              child: Padding(
                padding: EdgeInsets.only(top: showRuby ? rubyHeight : 0),
                child: Text(ch, style: base, textScaler: fixed),
              ),
            ),
          );
        }
      } else {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  seg.ruby!,
                  style: rubyStyle,
                  softWrap: false,
                  textScaler: fixed,
                ),
                Text(seg.base, style: base, softWrap: false, textScaler: fixed),
              ],
            ),
          ),
        );
      }
    }
    return Text.rich(
      TextSpan(children: spans),
      semanticsLabel: plainText(text),
      textScaler: fixed,
    );
  }
}

/// Chia chữ thành các khối không được ngắt dòng ở giữa: chữ Nhật mỗi ký tự
/// một khối, còn chữ Latin/tiếng Việt giữ nguyên cả từ (kèm dấu cách sau nó)
/// để không bị xuống dòng giữa từ.
List<String> _wrapUnits(String text) {
  final units = <String>[];
  final word = StringBuffer();
  void flush() {
    if (word.isNotEmpty) units.add(word.toString());
    word.clear();
  }

  for (final ch in text.characters) {
    if (ch.runes.first < 0x2E80) {
      word.write(ch);
      if (ch == ' ') flush();
    } else {
      flush();
      units.add(ch);
    }
  }
  flush();
  return units;
}
