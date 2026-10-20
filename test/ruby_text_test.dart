import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/widgets/ruby_text.dart';

void main() {
  test('tách furigana', () {
    expect(parseRuby('{財布|さいふ}を{拾|ひろ}いました'), const [
      RubySegment('財布', 'さいふ'),
      RubySegment('を'),
      RubySegment('拾', 'ひろ'),
      RubySegment('いました'),
    ]);
  });

  test('chuỗi không có furigana giữ nguyên', () {
    expect(parseRuby('ごみ'), const [RubySegment('ごみ')]);
    expect(parseRuby(''), isEmpty);
  });

  test('bỏ furigana và lấy cách đọc', () {
    expect(plainText('{会議|かいぎ}に{遅|おく}れます'), '会議に遅れます');
    expect(readingText('{会議|かいぎ}に{遅|おく}れます'), 'かいぎにおくれます');
  });
}
