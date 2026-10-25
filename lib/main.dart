import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/flashcard_store.dart';
import 'data/lesson_repository.dart';
import 'data/progress_store.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'services/recognizer.dart';
import 'services/speaker.dart';
import 'services/sync_service.dart';
import 'theme.dart';
import 'widgets/content_scale.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bản phát hành mặc định chỉ vẽ ô xám khi một màn hình lỗi; hiện chữ để
  // người dùng chụp lại được.
  ErrorWidget.builder = (details) => Material(
    color: SkinPalette.current.background,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Màn hình này bị lỗi, hãy chụp gửi lại:\n${details.exception}',
        style: const TextStyle(color: Colors.red, fontSize: 14),
      ),
    ),
  );
  // Vẽ ngay màn hình chờ, rồi mới khởi tạo; lỗi khi khởi tạo thì hiện lên
  // màn hình thay vì để trắng.
  runApp(const _Startup());
}

/// Khởi tạo bộ lưu và Firebase, xong thì chuyển sang [NihongoApp].
Future<NihongoApp> _createApp() async {
  final prefs = await SharedPreferences.getInstance();
  final progress = ProgressStore(prefs);
  final flashcards = FlashcardStore(prefs);
  final auth = await _initAuth();
  SyncService? sync;
  if (auth is FirebaseAuthService) {
    try {
      sync = SyncService(
        auth: auth,
        progress: progress,
        flashcards: flashcards,
        cloud: FirestoreCloudStore(FirebaseFirestore.instance),
      );
    } catch (e) {
      debugPrint('Không bật được đồng bộ: $e');
    }
  }
  return NihongoApp(
    repository: LessonRepository(),
    progress: progress,
    flashcards: flashcards,
    speaker: DeviceSpeaker(),
    recognizer: DeviceRecognizer(),
    auth: auth,
    // Có Firebase thì đồng bộ tiến độ lên Firestore khi đăng nhập.
    sync: sync,
  );
}

/// Nối Firebase nếu đã cấu hình; lỗi, quá lâu hoặc chưa cấu hình thì học
/// không cần đăng nhập.
Future<AuthService> _initAuth() async {
  final options = currentFirebaseOptions;
  if (options == null) return NoAuthService();
  try {
    await Firebase.initializeApp(options: options)
        .timeout(const Duration(seconds: 10));
    return FirebaseAuthService(FirebaseAuth.instance);
  } catch (e) {
    debugPrint('Không khởi tạo được Firebase: $e');
    return NoAuthService();
  }
}

class _Startup extends StatefulWidget {
  const _Startup();

  @override
  State<_Startup> createState() => _StartupState();
}

class _StartupState extends State<_Startup> {
  NihongoApp? _app;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    try {
      final app = await _createApp();
      if (mounted) setState(() => _app = app);
    } catch (e, st) {
      debugPrint('Lỗi khởi động: $e\n$st');
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_app != null) return _app!;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _error == null
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'App chưa mở được. Hãy chụp màn hình này gửi lại.',
                      ),
                      const SizedBox(height: 12),
                      SelectableText('$_error'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _start,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class NihongoApp extends StatefulWidget {
  final LessonRepository repository;
  final ProgressStore progress;
  final FlashcardStore flashcards;
  final Speaker speaker;
  final Recognizer recognizer;
  final AuthService auth;
  final SyncService? sync;

  NihongoApp({
    super.key,
    required this.repository,
    required this.progress,
    required this.flashcards,
    required this.speaker,
    required this.recognizer,
    AuthService? auth,
    this.sync,
  }) : auth = auth ?? NoAuthService();

  @override
  State<NihongoApp> createState() => _NihongoAppState();
}

class _NihongoAppState extends State<NihongoApp> with WidgetsBindingObserver {
  NihongoApp get w => widget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Chế độ "Theo máy": máy đổi sáng/tối thì vẽ lại.
  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final progress = w.progress;
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        final b = switch (progress.brightness) {
          'light' => Brightness.light,
          'dark' => Brightness.dark,
          _ => View.of(context).platformDispatcher.platformBrightness,
        };
        final palette = SkinPalette.of(progress.skin, b);
        SkinPalette.current = palette;
        // Đổi key khi đổi giao diện để mọi màn vẽ lại bằng màu mới.
        return _app(
          ValueKey('${palette.skin.name}-${palette.brightness.name}'),
          palette,
        );
      },
    );
  }

  Widget _app(Key key, SkinPalette palette) {
    final progress = w.progress;
    final auth = w.auth;
    return MaterialApp(
      key: key,
      title: 'Nihongo N4',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(palette),
      builder: (context, child) => ListenableBuilder(
        listenable: progress,
        builder: (context, _) =>
            ContentScaleScope(scale: progress.textScale, child: child!),
      ),
      home: ListenableBuilder(
        listenable: Listenable.merge([auth, progress]),
        builder: (context, _) {
          // Chưa đăng nhập và chưa chọn học thử thì hiện màn hình đăng nhập.
          if (auth.available && auth.user == null && !progress.isGuest) {
            return LoginScreen(
              auth: auth,
              onGuest: () => progress.setGuest(true),
            );
          }
          return HomeScreen(
            repository: w.repository,
            progress: progress,
            flashcards: w.flashcards,
            speaker: w.speaker,
            recognizer: w.recognizer,
            auth: auth,
            sync: w.sync,
          );
        },
      ),
    );
  }
}
