import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo_n4/data/flashcard_store.dart';
import 'package:nihongo_n4/data/lesson_repository.dart';
import 'package:nihongo_n4/data/progress_store.dart';
import 'package:nihongo_n4/main.dart';
import 'package:nihongo_n4/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lesson_test.dart' show FakeRecognizer, FakeSpeaker;

class FakeAuth extends AuthService {
  AppUser? _user;
  bool fail = false;

  @override
  bool get available => true;

  @override
  AppUser? get user => _user;

  @override
  Future<void> signInWithGoogle() async {
    if (fail) throw Exception('popup closed');
    _user = const AppUser(uid: 'u1', name: 'Tấn', email: 'tan@example.com');
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}

Future<ProgressStore> pumpApp(WidgetTester tester, AuthService auth) async {
  SharedPreferences.setMockInitialValues({'settings.textScale': 1.0});
  final prefs = await SharedPreferences.getInstance();
  final progress = ProgressStore(prefs);
  await tester.pumpWidget(
    NihongoApp(
      repository: LessonRepository(),
      progress: progress,
      flashcards: FlashcardStore(prefs),
      speaker: FakeSpeaker(),
      recognizer: FakeRecognizer(),
      auth: auth,
    ),
  );
  await tester.pumpAndSettle();
  return progress;
}

void main() {
  testWidgets(
    'chưa nối Firebase thì vào thẳng trang chủ, không có nút tài khoản',
    (tester) async {
      await pumpApp(tester, NoAuthService());
      expect(find.text('Lộ trình N4'), findsOneWidget);
      expect(find.byKey(const ValueKey('account')), findsNothing);
    },
  );

  testWidgets('đăng nhập Google rồi đăng xuất', (tester) async {
    final auth = FakeAuth();
    await pumpApp(tester, auth);
    expect(find.text('Đăng nhập bằng Google'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('google-sign-in')));
    await tester.pumpAndSettle();
    expect(find.text('Lộ trình N4'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('account')));
    await tester.pumpAndSettle();
    expect(find.text('Tấn\ntan@example.com'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('google-sign-in')), findsOneWidget);
  });

  testWidgets('đăng nhập lỗi thì báo, học thử thì vào trang chủ', (
    tester,
  ) async {
    final auth = FakeAuth()..fail = true;
    final progress = await pumpApp(tester, auth);

    await tester.tap(find.byKey(const ValueKey('google-sign-in')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa đăng nhập được'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('guest')));
    await tester.pumpAndSettle();
    expect(progress.isGuest, isTrue);
    expect(find.text('Lộ trình N4'), findsOneWidget);

    // Từ menu tài khoản có thể quay lại màn hình đăng nhập.
    await tester.tap(find.byKey(const ValueKey('account')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng nhập bằng Google'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('google-sign-in')), findsOneWidget);
  });

  testWidgets('thanh dưới 5 mục, tab Thống kê có cấp độ và chuỗi ngày', (
    tester,
  ) async {
    final auth = FakeAuth();
    await auth.signInWithGoogle();
    final progress = await pumpApp(tester, auth);
    await progress.recordAnswer(true);
    for (final k in ['nav-home', 'nav-vocab', 'nav-practice', 'nav-more']) {
      expect(find.byKey(ValueKey(k)), findsOneWidget);
    }
    await tester.tap(find.byKey(const ValueKey('nav-stats')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('profile-name')), findsOneWidget);
    expect(find.text('Tấn'), findsOneWidget);
    expect(find.text('Lv.1'), findsOneWidget);
    expect(find.text('2 / 500 XP'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Chuỗi ngày'), findsOneWidget);
  });
}
