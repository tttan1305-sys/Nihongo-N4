import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/theme.dart';
import 'package:nihongo_n4/widgets/ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => SkinPalette.current = SkinPalette.neon);

  test('mặc định Neon, lưu được giao diện và chế độ sáng/tối', () async {
    SharedPreferences.setMockInitialValues({});
    final progress = ProgressStore(await SharedPreferences.getInstance());
    expect(progress.skin, AppSkin.neon);
    expect(progress.brightness, 'system');

    await progress.setSkin(AppSkin.anime);
    await progress.setBrightness('light');
    final again = ProgressStore(await SharedPreferences.getInstance());
    expect(again.skin, AppSkin.anime);
    expect(again.brightness, 'light');
  });

  test('AppColors đổi theo bảng màu đang chọn', () {
    expect(AppColors.primary, SkinPalette.neon.primary);
    SkinPalette.current = SkinPalette.of(AppSkin.mechanical, Brightness.dark);
    expect(AppColors.primary, SkinPalette.mechanicalDark.primary);
    expect(AppColors.background, const Color(0xFF0B0E11));
    SkinPalette.current = SkinPalette.of(AppSkin.anime, Brightness.light);
    expect(AppColors.primary, const Color(0xFFD12F68));
    // Neon chỉ có bản tối.
    expect(SkinPalette.of(AppSkin.neon, Brightness.light), SkinPalette.neon);
  });

  testWidgets('thẻ Mechanical có đinh tán, Anime có bóng lệch', (tester) async {
    Future<void> pump() => tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: buildAppTheme(SkinPalette.current),
        home: const Scaffold(body: AppCard(child: Text('thẻ'))),
      ),
    );

    SkinPalette.current = SkinPalette.mechanicalLight;
    await pump();
    expect(find.byType(Rivets), findsOneWidget);

    SkinPalette.current = SkinPalette.animeLight;
    await pump();
    expect(find.byType(Rivets), findsNothing);
    final box = tester.widget<Container>(
      find
          .ancestor(of: find.text('thẻ'), matching: find.byType(Container))
          .last,
    );
    final shadow = (box.decoration! as BoxDecoration).boxShadow!.single;
    expect(shadow.offset, const Offset(4, 4));
    expect(shadow.blurRadius, 0);
  });
}
