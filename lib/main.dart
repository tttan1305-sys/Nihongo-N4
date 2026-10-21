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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final progress = ProgressStore(prefs);
  final flashcards = FlashcardStore(prefs);
  final auth = await _initAuth();
  runApp(
    NihongoApp(
      repository: LessonRepository(),
      progress: progress,
      flashcards: flashcards,
      speaker: DeviceSpeaker(),
      recognizer: DeviceRecognizer(),
      auth: auth,
      // Có Firebase thì đồng bộ tiến độ lên Firestore khi đăng nhập.
      sync: auth is FirebaseAuthService
          ? SyncService(
              auth: auth,
              progress: progress,
              flashcards: flashcards,
              cloud: FirestoreCloudStore(FirebaseFirestore.instance),
            )
          : null,
    ),
  );
}

/// Nối Firebase nếu đã cấu hình; lỗi hoặc chưa cấu hình thì học không cần đăng nhập.
Future<AuthService> _initAuth() async {
  final options = currentFirebaseOptions;
  if (options == null) return NoAuthService();
  try {
    await Firebase.initializeApp(options: options);
    return FirebaseAuthService(FirebaseAuth.instance);
  } catch (e) {
    debugPrint('Không khởi tạo được Firebase: $e');
    return NoAuthService();
  }
}

class NihongoApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo N4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBC002D)),
        useMaterial3: true,
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
            repository: repository,
            progress: progress,
            flashcards: flashcards,
            speaker: speaker,
            recognizer: recognizer,
            auth: auth,
            sync: sync,
          );
        },
      ),
    );
  }
}
