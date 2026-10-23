import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/theme.dart';
import 'package:nihongo_n4/widgets/content_scale.dart';

void main() {
  testWidgets('cỡ chữ bài học: chữ thường gấp đôi, chữ to và nút giữ nguyên', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: ContentScaleScope(
          scale: 2,
          child: Scaffold(
            body: ContentScale(
              child: Column(
                children: [
                  const Text('nghĩa', key: ValueKey('small')),
                  const Text(
                    '家',
                    key: ValueKey('big'),
                    style: TextStyle(fontSize: 60),
                  ),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Đã nhớ', key: ValueKey('button')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    double size(String key) {
      final element = tester.element(find.byKey(ValueKey(key)));
      final style = DefaultTextStyle.of(element).style
          .merge(tester.widget<Text>(find.byKey(ValueKey(key))).style);
      return MediaQuery.textScalerOf(element).scale(style.fontSize!);
    }

    expect(size('small'), 28);
    expect(size('big'), 60);
    expect(size('button'), 16);
  });
}
